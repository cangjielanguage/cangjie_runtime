// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Collector/FinalizerProcessor.h"

#include "Base/Macros.h"
#include "Common/ScopedObjectAccess.h"
#include "ExceptionManager.inline.h"
#include "Mutator/Mutator.h"
#include "ObjectModel/MObject.h"
#include "CjScheduler.h"
#include "Heap/HeapVerifier.h"

namespace MapleRuntime {
constexpr U32 DEFAULT_FINALIZER_TIMEOUT_MS = 2000;

// Note: can only be called by FinalizerProcessor thread
extern "C" MRT_EXPORT void* MRT_ProcessFinalizers(void* arg)
{
#ifdef __APPLE__
    CHECK_PTHREAD_CALL(pthread_setname_np, ("gc-helper"), "finalizer-processor thread setname");
#elif defined(__linux__) || defined(hongmeng)
    CHECK_PTHREAD_CALL(prctl, (PR_SET_NAME, "gc-helper"), "finalizer-processor thread setname");
#endif
    reinterpret_cast<FinalizerProcessor*>(arg)->Run();
    return nullptr;
}

void FinalizerProcessor::Start()
{
    pthread_t thread;
    pthread_attr_t attr;
    size_t stackSize = CangjieRuntime::GetConcurrencyParam().thStackSize * KB; // default 1MB stacksize
#if defined(__linux__) || defined(hongmeng) || defined(__APPLE__)
    // PTHREAD_STACK_MIN is not supported in Windows.
    const size_t minStackSize = static_cast<size_t>(PTHREAD_STACK_MIN);
    if (stackSize < minStackSize) {
        stackSize = minStackSize;
    }
#endif
    CHECK_PTHREAD_CALL(pthread_attr_init, (&attr), "init pthread attr");
    CHECK_PTHREAD_CALL(pthread_attr_setdetachstate, (&attr, PTHREAD_CREATE_JOINABLE), "set pthread joinable");
    CHECK_PTHREAD_CALL(pthread_attr_setstacksize, (&attr, stackSize), "set pthread stacksize");
    CHECK_PTHREAD_CALL(pthread_create, (&thread, &attr, MRT_ProcessFinalizers, this),
                       "create finalizer-process thread");
#ifdef __WIN64
    CHECK_PTHREAD_CALL(pthread_setname_np, (thread, "gc-helper"), "finalizer-processor thread setname");
#endif
    CHECK_PTHREAD_CALL(pthread_attr_destroy, (&attr), "destroy pthread attr");
    threadHandle = thread;

    WaitStarted();
}

// Stop FinalizerProcessor is only invoked at Fork or Runtime finliazaiton
// Should only invoke once.
void FinalizerProcessor::Stop()
{
    CHECK_DETAIL(running == true, "invalid finalizerProcessor status");
    running = false;
    Notify();
    WaitStop();
}

FinalizerProcessor::FinalizerProcessor()
{
    started = false;
    running = false;
    iterationWaitTime = DEFAULT_FINALIZER_TIMEOUT_MS;
    timeProcessorBegin = 0;
    timeProcessUsed = 0;
    timeCurrentProcessBegin = 0;
    hasFinalizableJob.store(false, std::memory_order_relaxed);
    shouldReclaimHeapGarbage.store(false, std::memory_order_relaxed);
    shouldFeedHungryBuffers.store(false, std::memory_order_relaxed);
}

void FinalizerProcessor::Run()
{
    Init();
    NotifyStarted();
    while (running) {
        bool hasPendingFinalizableJob = false;
        bool hasPendingReclaimHeapGarbage = false;
        bool hasPendingFeedHungryBuffers = false;
        {
            MRT_PHASE_TIMER("finalizerProcessor waitting time", FINALIZE);
            while (running) {
                hasPendingFinalizableJob = hasFinalizableJob.load(std::memory_order_relaxed);
                hasPendingReclaimHeapGarbage = shouldReclaimHeapGarbage.load(std::memory_order_relaxed);
                hasPendingFeedHungryBuffers = shouldFeedHungryBuffers.load(std::memory_order_relaxed);
                if (hasPendingFinalizableJob || hasPendingReclaimHeapGarbage || hasPendingFeedHungryBuffers) {
                    break;
                }
                Wait(iterationWaitTime);
            }
        }

        if (!running) {
            break;
        }

        if (UNLIKELY(!finalizerCJThreadInitialized)) {
            // Delay finalizer CJThread creation until the worker really has something to do,
            // but make all finalizer-side job types share the same one-time initialization.
            InitFinalizerCJThread();
        }

        if (hasPendingFinalizableJob) {
            ProcessFinalizables();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
            LogAfterProcess();
#endif
        }

        if (hasPendingFeedHungryBuffers) {
            FeedHungryBuffers();
        }

        if (hasPendingReclaimHeapGarbage) {
            ReclaimHeapGarbage();
        }
    }
    Fini();
}

void FinalizerProcessor::Init()
{
    // Only start the finalizer worker thread here. Its CJThread identity is created on demand
    // so it does not consume the earliest CJThread id before any finalize work exists.
    MutatorManager::Instance().MutatorManagementRLock();
    fpMutator = nullptr;
    MutatorManager::Instance().MutatorManagementRUnlock();
    running = true;
    timeProcessorBegin = TimeUtil::MicroSeconds();
    timeProcessUsed = 0;
    LOG(RTLOG_INFO, "FinalizerProcessor thread started");
}

void FinalizerProcessor::Fini()
{
    MutatorManager::Instance().MutatorManagementRLock();
    fpMutator = nullptr;
    MutatorManager::Instance().MutatorManagementRUnlock();
    // Finalizer may exit without ever running a finalize task, so only tear down the CJThread
    // context if it was really materialized.
    if (finalizerCJThreadInitialized) {
        EndFinalizerCJThread();
        finalizerCJThreadInitialized = false;
    }
    LOG(RTLOG_INFO, "FinalizerProcessor thread stopped");
}

void FinalizerProcessor::WaitStop()
{
    pthread_t thread = threadHandle;
    int tmpResult = ::pthread_join(thread, nullptr);
    CHECK_DETAIL(tmpResult == 0, "::pthread_join() in FinalizerProcessor::WaitStop() return %d rather than 0. ",
                 tmpResult);
    started = false;
    threadHandle = 0;
}

void FinalizerProcessor::Notify() { wakeCondition.notify_one(); }

void FinalizerProcessor::Wait(U32 timeoutMilliSeconds)
{
    std::unique_lock<std::mutex> lock(wakeLock);
    std::chrono::milliseconds epoch(timeoutMilliSeconds);
    wakeCondition.wait_for(lock, epoch);
}

void FinalizerProcessor::NotifyStarted()
{
    {
        std::unique_lock<std::mutex> lock(startedLock);
        CHECK_DETAIL(started != true, "unpexcted true, FinalizerProcessor might not wait stopped");
        started = true;
    }
    startedCondition.notify_all();
}

void FinalizerProcessor::WaitStarted()
{
    std::unique_lock<std::mutex> lock(startedLock);
    if (started) {
        return;
    }
    startedCondition.wait(lock, [this] { return started; });
}

void FinalizerProcessor::EnqueueFinalizables(const std::function<bool(BaseObject*)>& finalizable, U32 countLimit)
{
    std::lock_guard<std::mutex> l(listLock);
    auto it = finalizers.begin();
    while (it != finalizers.end() && countLimit != 0) {
        RefField<> tmpField(reinterpret_cast<MAddress>(*it));
        BaseObject* obj = tmpField.GetTargetObject();
        --countLimit;
        if (finalizable(obj)) {
            finalizables.push_back(reinterpret_cast<BaseObject*>(tmpField.GetFieldValue()));
            it = finalizers.erase(it);
        } else {
            ++it;
        }
    }

    if (!finalizables.empty()) {
        hasFinalizableJob.store(true, std::memory_order_relaxed);
    }
}

// Process finalizable list
// 1. always process list head
// 2. Leave safe region (calling in finalizerProcessor thread)
// 3. Invoke finalize method
// 4. remove processed finalizables
void FinalizerProcessor::ProcessFinalizableList()
{
    auto itor = workingFinalizables.begin();
    while (itor != workingFinalizables.end() && running) {
        // keep GC thread from visiting roots when workingFinalizables list is updating
        ScopedObjectAccess soa;
        CHECK_DETAIL(ExceptionManager::GetPendingException() == nullptr, "should not exist pending exception");
        RefField<> tmpField(reinterpret_cast<MAddress>(*itor));
        BaseObject* finalizeObjAddr = Heap::GetBarrier().ReadStaticRef(tmpField);

        TypeInfo* classInfo = reinterpret_cast<MObject*>(finalizeObjAddr)->GetTypeInfo();
        FuncRef finalizerMethod = classInfo->GetFinalizeMethod();
        Mutator* mutator = ThreadLocal::GetMutator();

        CHECK_DETAIL(finalizerMethod != nullptr, "%p has no finalize method", finalizeObjAddr);
        void (*finalizer)(BaseObject*, TypeInfo*) = reinterpret_cast<void (*)(BaseObject*, TypeInfo*)>(finalizerMethod);
        // finalize method return void, (moving) gc may take place here
        mutator->SetManagedContext(true);
        DLOG(FINALIZE, "tid %u finalize object %p", tid, finalizeObjAddr);
        uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
        ExecuteCangjieStub(finalizeObjAddr, finalizeObjAddr->GetTypeInfo(), 0, reinterpret_cast<void*>(finalizer),
                           reinterpret_cast<void*>(threadData), 0);
        mutator->SetManagedContext(false);

        if (ExceptionManager::HasFatalException()) {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
            ExceptionManager::DumpException();
#endif
            LOG(RTLOG_FATAL, "FatalException happened in finalizer");
        }
        ExceptionManager::ClearPendingException();
        {
            std::lock_guard<std::mutex> l(listLock);
            itor = workingFinalizables.erase(itor);
        }
    }
}

void FinalizerProcessor::ProcessFinalizables()
{
    MRT_PHASE_TIMER("Finalizer", FINALIZE);
    {
        // we leave saferegion to avoid GC visit those changing queues.
        ScopedObjectAccess soa;
        std::lock_guard<std::mutex> l(listLock);
        // FP will not come here before cleaning up workingFinalizables
        // workingFinalizables is expected empty, thus we could use std::swap here
        workingFinalizables.swap(finalizables);
    }
    DLOG(FINALIZE, "finalizer: working size %zu", workingFinalizables.size());
    ProcessFinalizableList();
    if (finalizables.empty()) {
        hasFinalizableJob.store(false, std::memory_order_relaxed);
    }
}

void FinalizerProcessor::InitFinalizerCJThread()
{
    // Bind the existing finalizer OS thread to a CJThread/scheduler so operations like
    // CJThreadPark can work, but delay this until there is real finalizer-side work to do.
    void* cjthread = NewFinalizerCJThread();
    CHECK_DETAIL(cjthread != nullptr, "create finalizer cjthread failed");
    Mutator* mutator = ThreadLocal::GetMutator();
    CHECK_DETAIL(mutator != nullptr, "create finalizer mutator failed");
    // NewFinalizerCJThread prepares the thread for managed execution. We immediately re-enter
    // saferegion here because the finalizer main loop itself stays idle most of the time and
    // only leaves saferegion again through ScopedObjectAccess when work is processed.
    (void)mutator->EnterSaferegion(true);
    tid = mutator->GetTid();

    MutatorManager::Instance().MutatorManagementRLock();
    fpMutator = mutator;
    MutatorManager::Instance().MutatorManagementRUnlock();
    finalizerCJThreadInitialized = true;
}

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
void FinalizerProcessor::LogAfterProcess()
{
    if (!ENABLE_LOG(FINALIZE)) {
        return;
    }
    uint64_t timeNow = TimeUtil::MicroSeconds();
    uint64_t timeConsumed = timeNow - timeCurrentProcessBegin;
    uint64_t totalTimePassed = timeNow - timeProcessorBegin;
    timeProcessUsed += timeConsumed;
    constexpr float percentageDivend = 100.0f;
    float percentage = (static_cast<float>(TIME_FACTOR * timeProcessUsed) / totalTimePassed) / percentageDivend;
    DLOG(FINALIZE, "[FinalizerProcessor] End (%luus [%luus] [%.2f%%])", timeConsumed, timeProcessUsed, percentage);
}
#endif

void FinalizerProcessor::RegisterFinalizer(BaseObject* obj)
{
    RefField<> tmpField(nullptr);
    Heap::GetBarrier().WriteStaticRef(tmpField, obj);
    std::lock_guard<std::mutex> l(listLock);
    finalizers.push_back(reinterpret_cast<BaseObject*>(tmpField.GetFieldValue()));
}

void FinalizerProcessor::RegisterFinalizers(ManagedList<BaseObject*>& objs)
{
    if (objs.empty()) {
        return;
    }
    std::lock_guard<std::mutex> l(listLock);
    finalizers.splice(finalizers.end(), objs);
}

void FinalizerProcessor::ReclaimHeapGarbage()
{
    ScopedEntryTrace trace("CJRT_GC_RECLAIM");
    auto& allocator = Heap::GetHeap().GetAllocator();
    if (HeapVerifier::IsEnabled()) {
        std::lock_guard<std::mutex> maintenance(heapMaintenanceLock);
        allocator.ReclaimGarbageMemory(false);
    } else {
        allocator.ReclaimGarbageMemory(false);
    }
    shouldReclaimHeapGarbage.store(false, std::memory_order_relaxed);
}

void FinalizerProcessor::FeedHungryBuffers()
{
    Heap::GetHeap().GetAllocator().FeedHungryBuffers();
    shouldFeedHungryBuffers.store(false, std::memory_order_relaxed);
}
} // namespace MapleRuntime
