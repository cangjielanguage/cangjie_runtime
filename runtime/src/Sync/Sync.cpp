// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Sync.h"
#include <atomic>

#include "Base/TimeUtils.h"
#include "schedule.h"
#include "Concurrency/ConcurrencyModel.h"
#if defined(CANGJIE_TSAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#ifdef _WIN64
#include <windows.h>
#endif

namespace MapleRuntime {
template<typename T>
static T CastToT(const void* ptr)
{
    return reinterpret_cast<T>(const_cast<void*>(ptr));
}

#ifdef __cplusplus
extern "C" {
#endif

static constexpr int64_t INVALID_THREAD_ID = -1LL;

void ReleaseNativeResource(BaseObject* obj)
{
    TypeInfo* typeInfo = obj->GetTypeInfo();
    // Future is a template, so only the first 24 characters are compared
    if (typeInfo->IsFutureClass()) {
        int waitQueue = reinterpret_cast<CJFuture*>(obj)->isWaitQueueInit;
        if (waitQueue == 1) {
            pthread_mutex_destroy(&reinterpret_cast<CJFuture*>(obj)->wq.mutex);
        }
        return;
    }
    if (typeInfo->IsMonitorClass()) {
        if (reinterpret_cast<CJMonitor*>(obj)->isWaitQueueInit) {
            pthread_mutex_destroy(&reinterpret_cast<CJMonitor*>(obj)->wq.mutex);
        }
        return;
    }
    if (typeInfo->IsMutexClass()) {
        if (reinterpret_cast<CJMutex*>(obj)->isSemaInit) {
            pthread_mutex_destroy(&reinterpret_cast<CJMutex*>(obj)->sema.queue.mutex);
        }
        return;
    }
    if (typeInfo->IsWaitQueueClass()) {
        if (reinterpret_cast<CJWaitQueue*>(obj)->isWaitQueueInit) {
            pthread_mutex_destroy(&reinterpret_cast<CJWaitQueue*>(obj)->wq.mutex);
        }
        return;
    }
}

void MCC_FutureInit(void* ptr)
{
    CJFuture* future = reinterpret_cast<CJFuture*>(ptr);
    future->completeFlag = false;
    future->isWaitQueueInit = 0;
    MemorySet(reinterpret_cast<uintptr_t>(&future->spinLock), sizeof(AtomicSpinLock), 0, sizeof(AtomicSpinLock));
}

bool MCC_FutureIsComplete(void* ptr)
{
    CJFuture* future = CastToT<CJFuture*>(ptr);
#if defined(CANGJIE_TSAN_SUPPORT)
    bool res = future->completeFlag.load();
    if (res) {
        Sanitizer::TsanAcquire(future);
    }
    return res;
#else
    return future->completeFlag.load();
#endif
}

void MRT_FutureWait(const void* ptr, int64_t timeout)
{
    CJFuture* future = CastToT<CJFuture*>(ptr);
    constexpr int newWaitQueueMaxTimes = 32;
    for (int i = 0;;) {
        if (i > newWaitQueueMaxTimes) {
            LOG(RTLOG_ERROR, "FutureWait timeout failed.");
            break;
        }
        int oldWaitQueue = future->isWaitQueueInit.load();
        // -1 indicates that another thread is creating a waitqueue.
        if (oldWaitQueue == -1) {
            continue;
        }
        if (oldWaitQueue == 1) {
            break;
        }

        // Set waitQueuePtr to -1 while creating waitqueue
        if (future->isWaitQueueInit.compare_exchange_weak(oldWaitQueue, -1)) {
            if (MRT_NewWaitQueue(reinterpret_cast<void*>(&future->wq)) != 0) {
                LOG(RTLOG_ERROR, "waitqueue init failed!\n");
                future->isWaitQueueInit.store(0);
                ++i;
                continue;
            }
            future->isWaitQueueInit.store(1);
            break;
        }
    }

    Heap::GetHeap().GetCollector().AddRawPointerObject(reinterpret_cast<BaseObject*>(future));
    MRT_SuspendWithTimeout(&future->wq, MCC_FutureIsComplete, future, timeout);
    Heap::GetHeap().GetCollector().RemoveRawPointerObject(reinterpret_cast<BaseObject*>(future));

#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanAcquire(future);
#endif
}

void MCC_FutureNotifyAll(const void* ptr)
{
    CJFuture* future = CastToT<CJFuture*>(ptr);
    // This function will be called just before the cjthread completes.
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanRelease(future, Sanitizer::ReleaseType::K_RELEASE_MERGE);
#endif
    future->completeFlag.store(true);
    int waitQueue = future->isWaitQueueInit.load();
    // Waitqueue hasn't been created or is being created.
    if (waitQueue == 0 || waitQueue == -1) {
        return;
    }

    MRT_ResumeAll(&future->wq, NULL, future);
}

int MCC_MutexInit(void* ptr)
{
    CJMutex* mutex = reinterpret_cast<CJMutex*>(ptr);
    int ret = MRT_NewSem(&mutex->sema);
    if (ret != 0) {
        mutex->isSemaInit = false;
    } else {
        mutex->isSemaInit = true;
        mutex->ownerThreadId = INVALID_THREAD_ID;
        mutex->ownCount = 0;
    }
    return ret;
}

// LOCKED is used in llvm for mutex opt. Don't just modify it here.
const int64_t SPINNING = 0x1;
const int64_t STARVING = 0x2;
const int64_t LOCKED  = 0x4;
const int64_t WAITER_UNIT_SHIFT = 3;
const int64_t WAITER_UNIT = 1 << WAITER_UNIT_SHIFT;
const uint64_t STARVING_THRESHOLD = 1000; // 1000us
const int64_t SPIN_THRESHOLD = 4;

static bool IsSpinning(int64_t state) { return state & SPINNING; }
static bool IsStarving(int64_t state) { return state & STARVING; }
static bool IsLocked(int64_t state) { return state & LOCKED; }
static int64_t GetWaiters(int64_t state) { return state >> WAITER_UNIT_SHIFT; }
static void SetLocked(int64_t& state) { state |= LOCKED; }
static void SetStarving(int64_t& state) { state |= STARVING; }
static void UnsetSpinning(int64_t& state) { state &= ~SPINNING; }
static void IncWaiters(int64_t& state) { state += WAITER_UNIT; }

#if defined(__linux__) || defined(hongmeng) || defined(__APPLE__)
#if defined(__aarch64__) || defined (__arm__)
#define YIELD_PROCESSOR __asm__ __volatile__("yield")
#elif defined(__x86_64__)
#define YIELD_PROCESSOR __asm__ __volatile__("pause")
#endif // endif of Arch
#else // _WIN64
#define YIELD_PROCESSOR YieldProcessor()
#endif // end of OS

#ifndef YIELD_PROCESSOR
#warning "Processor yield not supported on this architecture."
#define YIELD_PROCESSOR ((void)0)
#endif

static void DoSpin()
{
    static const int spinNum = 30;
    for (int i = 0; i < spinNum; ++i) {
        YIELD_PROCESSOR;
    }
}

static bool MCC_MutexLockSlowPathImpl(CJMutex* mutex, uint64_t count)
{
    int64_t currThreadId = MRT_GetCurrentThreadID();
    if (mutex->ownerThreadId.load(std::memory_order_acquire) == currThreadId) {
#if defined(CANGJIE_TSAN_SUPPORT)
        Sanitizer::TsanAcquire(reinterpret_cast<void*>(mutex));
#endif
        mutex->ownCount += count;
        return true;
    }
    bool hasSetSpinFlag = false;
    bool isStarved = false;
    uint64_t firstWaitTime = 0;
    int trySpinCount = 0;
    for (;;) { // The main loop to acquire the mutex
        int64_t currState = mutex->state.load();
        // ========== Do spinning ============
        if (!IsStarving(currState) &&
            IsLocked(currState) &&
            trySpinCount < SPIN_THRESHOLD &&
            ProcessorCanSpin()) {
            // There are four types of threads:
            //   - Owner thread (at most one)
            //   - Newcoming thread
            //   - Spinning thread (at most one)
            //   - Waiter thread (including starved threads)
            // The first newcoming thread may be the spinning thread,
            // or a waked waiter thread will always be the spinning thread.
            if (!hasSetSpinFlag && // If the thread is newcoming (not set the spinning flag),
                !IsSpinning(currState) && // and there are no spinning threads,
                GetWaiters(currState) > 0 && // and there are waiter threads,
                // try to make the current thread as the spinning thread;
                mutex->state.compare_exchange_strong(currState, currState | SPINNING)) {
                // if succeeded, `unlock` will not wake up waiter threads.
                hasSetSpinFlag = true;
            }
            DoSpin();
            trySpinCount += 1;
            continue; // After spinning; restart
        }

        // ========== Prepare new state ==============
        int64_t newState = currState; // Copy the state first
        // If mutex is NOT starving, try to acquire the mutex;
        // so, set LOCKED.
        if (!IsStarving(currState)) {
            SetLocked(newState);
        }
        // If mutex is STARVING or LOCKED, we cannot acquire the mutex;
        // so, increase #waiters.
        if (IsStarving(currState) || IsLocked(currState)) {
            IncWaiters(newState);
        }
        // IF the current thread is starved and mutex is LOCKED,
        // set mutex as STARVING.
        if (isStarved && IsLocked(currState)) {
            SetStarving(newState);
        }
        // Since we have ended up spinning, clear the flag if necessary
        if (hasSetSpinFlag) {
            UnsetSpinning(newState);
        }

        // ========== Set new state ==============
        if (!mutex->state.compare_exchange_strong(currState, newState)) {
            continue; // Fail to set the new state; restart
        }

        // ========== Hold the mutex ==============
        // If the previous state is not LOCKED && STARVING,
        // CAS succeeded in acquiring the mutex.
        if (!IsLocked(currState) && !IsStarving(currState)) {
            mutex->ownCount = count;
            mutex->ownerThreadId.store(currThreadId, std::memory_order_release);
#if defined(CANGJIE_TSAN_SUPPORT)
            Sanitizer::TsanAcquire(reinterpret_cast<void*>(mutex));
#endif
            return true;
        }

        // ========== Put into wait queue ==============
        // If the current thread has already waited,
        // it will be pushed at the front of the queue.
        bool isPushToHead = firstWaitTime != 0;
        if (firstWaitTime == 0) {
            firstWaitTime = TimeUtil::MicroSeconds();
        }
        Heap::GetHeap().GetCollector().AddRawPointerObject(reinterpret_cast<BaseObject*>(mutex));
        MRT_SemAcquire(&mutex->sema, isPushToHead);
        Heap::GetHeap().GetCollector().RemoveRawPointerObject(reinterpret_cast<BaseObject*>(mutex));

        // ========== After wake up ==============
        // If waiting too long, the current thread becomes starved
        isStarved = isStarved || (TimeUtil::MicroSeconds() - firstWaitTime) > STARVING_THRESHOLD;
        // Read the new state
        currState = mutex->state.load();
        if (!IsStarving(currState)) {
            // Retry to acquire the mutex; also, spinning restarts
            trySpinCount = 0;
            // Since The spinning flag is always set by `unlock`,
            // we should set the variable as well.
            hasSetSpinFlag = true;
            continue; // Waked up; restart
        }
        // Mutex is in starvation mode.
        // When the current thread was woken up, ownership was handed off to it directly.
        // There are some invariants:
        //  - only ONE thread can be woken up and reach here,
        //  - mutex cannot be spinning,
        //  - `LOCKED` is not set, and
        //  - #waiters must be positive because `unlock` will not change it under starvation.
        bool valid = !IsLocked(currState) && !IsSpinning(currState) && GetWaiters(currState) > 0;
        MRT_ASSERT(valid, "Sync error: inconsistent mutex state!\n");
        if (!valid) {
            LOG(RTLOG_ERROR, "Sync error: inconsistent mutex state!\n");
            return false;
        }
        // So, the inconsistent state should be fixed here.
        // A trick to use a single statement to fix all states.
        // Fix as: state + LOCKED - WAITER_UNIT
        int64_t delta = LOCKED - WAITER_UNIT;
        // Exit starvation if a non-starved thread is wakeup, or there are no waiters.
        if (!isStarved || GetWaiters(currState) == 1) {
            // Fix as: state + LOCKED - WAITER_UNIT - STARVING
            delta -= STARVING;
        }
        mutex->state.fetch_add(delta);
        MRT_ASSERT(mutex->ownerThreadId.load(std::memory_order_acquire) == INVALID_THREAD_ID,
                   "Sync error: invalid mutex owner\n");
        MRT_ASSERT(mutex->ownCount == 0, "Sync error: invalid mutex owning count\n");
        mutex->ownCount = count;
        mutex->ownerThreadId.store(currThreadId, std::memory_order_release);
#if defined(CANGJIE_TSAN_SUPPORT)
            Sanitizer::TsanAcquire(reinterpret_cast<void*>(mutex));
#endif
        return true;
    }
    return false; // Unreachable
}

/**
 * @brief Acquire the mutex.
 * @param ptr: raw pointer of a `CJMutex`.
 * @param count: number of acquision to hold the mutex.
 * @return true if succeed in holding the mutex.
 * @return false if fail to acquire the mutex.
 */
static bool MCC_MutexLockImpl(const void* ptr, uint64_t count)
{
    CJMutex* mutex = CastToT<CJMutex*>(ptr);
    int64_t expected = 0;
    // Fast path: try to acquire the mutex
    if (mutex->state.compare_exchange_strong(expected, LOCKED)) {
        int64_t currThreadId = MRT_GetCurrentThreadID();
        mutex->ownCount += count;
        mutex->ownerThreadId.store(currThreadId, std::memory_order_release);
#if defined(CANGJIE_TSAN_SUPPORT)
        Sanitizer::TsanAcquire(ptr);
#endif
        return true;
    }
    bool res = MCC_MutexLockSlowPathImpl(mutex, count);
    return res;
}

/**
 * @brief Acquire the mutex.
 * @param ptr: raw pointer of a `CJMutex`.
 * Current thread may be blocked until hold the mutex
 */
void MCC_MutexLock(void* ptr) { MCC_MutexLockImpl(ptr, 1); }

void MCC_MutexLockSlowPath(void* ptr)
{
    MCC_MutexLockSlowPathImpl(CastToT<CJMutex*>(ptr), 1);
}

/**
 * @brief Returns false when fail to hold the mutex.
 * @param ptr: raw pointer of a `CJMutex`.
 * Current thread will never be blocked.
 */
bool MCC_MutexTryLock(void* ptr)
{
    CJMutex* mutex = CastToT<CJMutex*>(ptr);
    int64_t currThreadId = MRT_GetCurrentThreadID();
    int64_t currOwner = mutex->ownerThreadId.load(std::memory_order_acquire);
    // Fast path: try to acquire the mutex
    if (currOwner == currThreadId) {
        mutex->ownCount += 1;
#if defined(CANGJIE_TSAN_SUPPORT)
        Sanitizer::TsanAcquire(ptr);
#endif
        return true;
    } else if (currOwner != INVALID_THREAD_ID) {
        return false;
    }

    int64_t currState = mutex->state.load();
    if (IsLocked(currState) || IsStarving(currState)) {
        return false;
    }
    // There may be some spinning threads or waited threads,
    // but the current thread can still acquire the mutex.
    if (mutex->state.compare_exchange_strong(currState, currState | LOCKED)) {
        mutex->ownCount += 1;
        mutex->ownerThreadId.store(currThreadId, std::memory_order_release);
#if defined(CANGJIE_TSAN_SUPPORT)
        Sanitizer::TsanAcquire(ptr);
#endif
        return true;
    }
    return false;
}

/**
 * @brief Whether current thread held the mutex.
 * @param ptr: raw pointer of a `CJMutex`.
 */
bool MCC_MutexCheckStatus(const void* ptr)
{
    CJMutex* mutex = CastToT<CJMutex*>(ptr);
    int64_t curThreadId = MRT_GetCurrentThreadID();
    return mutex->ownerThreadId.load(std::memory_order_acquire) == curThreadId;
}

/**
 * @brief If mutex is locked recursively, this method should be invoked N times to fully unlock mutex.
 * In Cangjie program, `checkStatus` must be called before this function.
 * @param ptr: raw pointer of a `CJMutex`.
 * @param count: number of acquision to release the mutex.
 */
static void MRT_MutexUnlockImpl(const void* ptr, uint64_t count)
{
    CJMutex* mutex = CastToT<CJMutex*>(ptr);
    MRT_ASSERT(IsLocked(mutex->state.load()), "Sync error: unlock an unlocked mutex");
    // Invariant: ownCount >= count
    uint64_t oldOwnCount = mutex->ownCount;
    mutex->ownCount -= count;
    if (oldOwnCount > count) {
        // Still hold the mutex
        return;
    }
    MRT_ASSERT(oldOwnCount == count, "Incorrect mutex state");
    // Release the mutex
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanRelease(ptr, Sanitizer::ReleaseType::K_RELEASE_MERGE);
#endif
    mutex->ownerThreadId.store(INVALID_THREAD_ID, std::memory_order_release);
    int64_t currState = mutex->state.fetch_sub(LOCKED);
    MRT_ASSERT(IsLocked(currState), "Sync error: unlock an unlocked mutex");
    currState -= LOCKED; // Clear the locked bit
    if (currState == 0) {
        return;
    }
    if (IsStarving(currState)) {
        // Starving mode: handoff mutex ownership to the next waiter.
        // Note 1: LOCKED is not set, the waiter will set it after wakeup.
        // However, mutex is still considered locked because STARVING is set,
        // so, new coming threads will not acquire it.
        // Note 2: #waiters is not decreased.
        MRT_SemRelease(&mutex->sema);
        return;
    }
    for (;;) {
        // If there are no waiters, or a thread has already been woken or held the lock,
        // there is no need to wake anyone.
        if (GetWaiters(currState) == 0 || IsLocked(currState) ||
            IsSpinning(currState) || IsStarving(currState)) {
            return;
        }
        // Wake up a thread and make it as the spinning thread.
        int64_t newState = (currState - WAITER_UNIT) | SPINNING;
        if (mutex->state.compare_exchange_strong(currState, newState)) {
            // After designating the spinning thread,
            //  - newcoming threads may hold the mutex and do `unlock`,
            //  - however, ONLY one waited thread will be waked up by the current thread,
            // because no threads except the waked one can reset the spinning state.
            // Thus, mutex will not be starved until the following `release` is done.
            MRT_SemRelease(&mutex->sema);
            return;
        }
        currState = mutex->state.load();
    }
}

void MCC_MutexUnlock(const void* ptr) { MRT_MutexUnlockImpl(ptr, 1); }

// =====================================================
// Following functions are used to implement monitors.
// =====================================================
static void MRT_MutexFullyLock(void* ptr, uint64_t count) { MCC_MutexLockImpl(ptr, count); }

/**
 * @brief Fully unlock a mutex.
 * @return false. This function return a `false` value
 * Because it is used as an argument (callback function) of `CJ_MRT_SuspendWithTimeout`.
 * If the callback function returns `false`, the caller thread will be suspended.
 */
static bool MRT_MutexFullyUnlock(void* ptr)
{
    CJMutex* mutex = CastToT<CJMutex*>(ptr);
    MRT_MutexUnlockImpl(ptr, mutex->ownCount);
    return false;
}

/**
 * @brief A warpper of concurrency library APIs.
 */
int MCC_WaitQueueForMonitorInit(void* ptr)
{
    CJMonitor* monitor = reinterpret_cast<CJMonitor*>(ptr);
    int ret = MRT_NewWaitQueue(&monitor->wq);
    if (ret == 0) {
        monitor->isWaitQueueInit = true;
    } else {
        monitor->isWaitQueueInit = false;
    }
    return ret;
}

int MCC_WaitQueueInit(void* ptr)
{
    CJWaitQueue* queue = reinterpret_cast<CJWaitQueue*>(ptr);
    int ret = MRT_NewWaitQueue(&queue->wq);
    if (ret == 0) {
        queue->isWaitQueueInit = true;
    } else {
        queue->isWaitQueueInit = false;
    }
    return ret;
}

bool MonitorWait(CJMutex* mutex, void* wq, int64_t timeout)
{
    // 1. Keep the #mutex-hold before release the mutex.
    Heap::GetHeap().GetCollector().AddRawPointerObject(reinterpret_cast<BaseObject*>(mutex));
    uint64_t ownCount = mutex->ownCount;
    // 2. Release and wait
    bool wakeStatus = MRT_SuspendWithTimeout(wq, MRT_MutexFullyUnlock, mutex, timeout);
    // 3. Hold the mutex again
    MRT_MutexFullyLock(mutex, ownCount);
    Heap::GetHeap().GetCollector().RemoveRawPointerObject(reinterpret_cast<BaseObject*>(mutex));
    if (wakeStatus) {
        // Notified by other threads
        return true;
    } else {
        // Timeout
        return false;
    }
}

/**
 * @brief Implemented `Monitor` in C. A monitor is just a wrapper of a mutex and a wait queue.
 * In Cangjie program, `checkStatus` must be called before this function.
 * @param ptr: the "CJMonitor".
 * @param wq: the wait queue.
 * @param timeout: wake up the caller thread after `timeout` nanoseconds if no other threads notify it.
 * @return true if notified by other threads.
 * @return false if timeout.
 */
bool MCC_MonitorWait(const void* ptr, int64_t timeout)
{
    CJMonitor* monitor = CastToT<CJMonitor*>(ptr);
    CJMutex* mutex = monitor->mutexPtr;
    Heap::GetHeap().GetCollector().AddRawPointerObject(reinterpret_cast<BaseObject*>(monitor));
    // MonitorWait pins the mutex through suspension and reacquisition.
    bool ret = MonitorWait(mutex, &monitor->wq, timeout);
    Heap::GetHeap().GetCollector().RemoveRawPointerObject(reinterpret_cast<BaseObject*>(monitor));
    return ret;
}

/**
 * @brief Notify one thread (randomly picked) blocked on the wait queue.
 * In Cangjie program, `checkStatus` must be called before this function.
 */
void MCC_MonitorNotify(const void* ptr)
{
    MRT_ResumeOne(
        &CastToT<CJMonitor*>(ptr)->wq, [](void*) { return false; }, NULL);
}

/**
 * @brief Notify all thread blocked on the wait queue.
 * In Cangjie program, `checkStatus` must be called before this function.
 */
void MCC_MonitorNotifyAll(const void* ptr)
{
    MRT_ResumeAll(
        &CastToT<CJMonitor*>(ptr)->wq, [](void*) { return false; }, NULL);
}

bool MCC_MultiConditionMonitorWait(const void* ptr, void* waitQueuePtr, int64_t timeout)
{
    CJMultiConditionMonitor* monitor = CastToT<CJMultiConditionMonitor*>(ptr);
    CJMutex* mutex = monitor->mutexPtr;
    Heap::GetHeap().GetCollector().AddRawPointerObject(reinterpret_cast<BaseObject*>(waitQueuePtr));
    bool ret = MonitorWait(mutex, &CastToT<CJWaitQueue*>(waitQueuePtr)->wq, timeout);
    Heap::GetHeap().GetCollector().RemoveRawPointerObject(reinterpret_cast<BaseObject*>(waitQueuePtr));
    return ret;
}

/**
 * @brief Notify one thread (randomly picked) blocked on the wait queue.
 * In Cangjie program, `checkStatus` must be called before this function.
 */
void MCC_MultiConditionMonitorNotify(const void* ptr __attribute__((unused)), const void* waitQueuePtr)
{
    MRT_ResumeOne(
        &CastToT<CJWaitQueue*>(waitQueuePtr)->wq, [](void*) { return false; }, NULL);
}

/**
 * @brief Notify all thread blocked on the wait queue.
 * In Cangjie program, `checkStatus` must be called before this function.
 */
void MCC_MultiConditionMonitorNotifyAll(const void* ptr __attribute__((unused)), const void* waitQueuePtr)
{
    MRT_ResumeAll(
        &CastToT<CJWaitQueue*>(waitQueuePtr)->wq, [](void*) { return false; }, NULL);
}

bool MCC_IsThreadObjectInited()
{
    return MRT_GetCurrentCJThreadObject() != nullptr;
}

void* MRT_GetCurrentCJThreadObject()
{
    void* argStart = CJThreadGetArg();
    RefField<false>* refField = reinterpret_cast<RefField<false>*>(
        &reinterpret_cast<LWTData*>(argStart)->threadObject);
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanAcquire();
#endif
    auto res = Heap::GetBarrier().ReadStaticRef(*refField);
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanRelease(Sanitizer::ReleaseType::K_RELEASE_MERGE);
#endif
    return res;
}

void MCC_SetCurrentCJThreadObject(void* ptr)
{
    LWTData* data = reinterpret_cast<LWTData*>(CJThreadGetArg());
    if (data == nullptr) {
        LOG(RTLOG_FATAL, "CJThread or arg of CJThread is nullptr.");
    }
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanAcquire();
#endif
    Heap::GetBarrier().WriteStaticRef(*reinterpret_cast<RefField<false>*>(&data->threadObject),
        reinterpret_cast<BaseObject*>(ptr));
#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanRelease(Sanitizer::ReleaseType::K_RELEASE_MERGE);
#endif
}

void MRT_SetCJThreadName(void* handle, uint8_t* name, size_t len)
{
    CJThreadSetName(handle, reinterpret_cast<const char*>(name), len);
}

int64_t MRT_GetCJThreadId(void* handle)
{
    unsigned long long ret = CJThreadGetId(handle);
    // It's safe to cast the return value as int64
    return static_cast<int64_t>(ret);
}

int64_t MRT_GetCJThreadState(void* handle)
{
    int state = CJThreadGetState(handle);
    if (state == 0) {  // 0: IDLE
        return -1;
    }
    // 4: syscall which we treat as 2: running
    state = state == 4 ? 2 : state;
    return static_cast<int64_t>(state);
}

void* MRT_GetCurrentCJThread()
{
    return CJThreadGetHandle();
}

void MRT_ThreadResumeAndWait(void* handle)
{
    CJThreadResumeAndWait(handle);
}

void MRT_ThreadReady(void* handle)
{
    CJThreadReady(handle);
}

void MRT_ThreadWait()
{
    CJThreadWait();
}
#ifdef __APPLE__
#include "MacAlias.h"
#else
#include "CommonAlias.h"
#endif
#ifdef __cplusplus
};
#endif
} // namespace MapleRuntime
