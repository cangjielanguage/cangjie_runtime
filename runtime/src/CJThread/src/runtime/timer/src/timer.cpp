// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <cstdio>
#include <ctime>
#include "schedule_impl.h"
#include "cjthread.h"
#include "timer_impl.h"
#include "basetime.h"
#include "log.h"
#include "securec.h"
#include "Common/NativeAllocator.h"

#ifdef __linux__
#include <sys/syscall.h>
#include <unistd.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

const int TIMER_HEAP_SIZE = 256;
const int TIMER_HEAP_EXPAND_MULTIPLE = 2;
const int ADJUST_BREAK_CURRENT_LOOP_NUMBER = -1;
const int RUN_TIMER_NO_MORE_TIMER = -1;

MRT_STATIC_INLINE void OsYield(void)
{
#ifdef __linux__
    syscall(SYS_sched_yield);
#endif
}

static std::atomic<int> g_timerNum(0);

/* Check whether data overflows based on the input. */
unsigned long long TimerDeadlineCheck(unsigned long long now, unsigned long long dur)
{
    unsigned long long deadline = now + dur;
    if (deadline < now) {
        return static_cast<unsigned long long>(-1);
    }
    return deadline;
}

/* Heap maintenance algorithm, check up */
void TimerShiftUp(struct TimerHeap *heap, unsigned long long idx)
{
    unsigned long long parent;
    unsigned long long bufIndex = idx;
    struct TimerNode *timer;
    unsigned long long ddl;
    timer = heap->buf[bufIndex];
    ddl = timer->deadline;
    while (bufIndex > 0) {
        parent = (bufIndex - 1) / FORKS_NUM;
        if (ddl >= heap->buf[parent]->deadline) {
            break;
        }
        heap->buf[bufIndex] = heap->buf[parent];
        bufIndex = parent;
    }
    heap->buf[bufIndex] = timer;
}

/* Heap maintenance algorithm, check down */
void TimerShiftDown(struct TimerHeap *heap, unsigned long long idx)
{
    struct TimerNode *timer;
    unsigned long long ddl;
    bool flag;
    unsigned long long len;
    unsigned long long idxTemp = idx;

    len = heap->numTimers;
    timer = heap->buf[idxTemp];
    ddl = timer->deadline;
    flag = true;
    while (flag) {
        unsigned long long midDdl = ULLONG_MAX;
        unsigned long long minIdx = 0;
        int i;
        unsigned long long child;
        for (i = 1; i <= FORKS_NUM; ++i) {
            child = FORKS_NUM * idxTemp + static_cast<unsigned long long>(i);
            if (child >= len) {
                flag = false;
                break;
            }
            if (((struct TimerNode *)heap->buf[child])->deadline < midDdl) {
                midDdl = ((struct TimerNode *)heap->buf[child])->deadline;
                minIdx = child;
            }
        }
        if (midDdl >= ddl) {
            break;
        }
        heap->buf[idxTemp] = heap->buf[minIdx];
        idxTemp = minIdx;
    }
    heap->buf[idxTemp] = timer;
}

/* Insert a timer into the 4-fork heap */
void TimerDoAdd(struct TimerHeap *heap, struct TimerNode *timer)
{
    // Check the length of the heap. If the length exceeds the range of the heap, expand the capacity.
    if (heap->numTimers == heap->capacity) {
        struct TimerNode **newBuf = static_cast<struct TimerNode **>(
            MapleRuntime::NativeAllocator::NativeAlloc(
                sizeof(struct TimerNode *) * heap->numTimers * TIMER_HEAP_EXPAND_MULTIPLE));
        if (newBuf == nullptr) {
            LOG_ERROR(ERROR_TIMER_ALLOC, "timerheap->buf expand capacity failed ");
            return;
        }
        heap->capacity = heap->numTimers * TIMER_HEAP_EXPAND_MULTIPLE;
        for (unsigned long long i = 0; i < heap->numTimers; i++) {
            newBuf[i] = heap->buf[i];
        }
        MapleRuntime::NativeAllocator::NativeFree(
            heap->buf, sizeof(struct TimerNode *) * heap->numTimers);
        heap->buf = newBuf;
    }
    heap->buf[heap->numTimers] = timer;
    // At this time, numTimers has not increased, so the index of the new function is numTimers.
    TimerShiftUp(heap, heap->numTimers);
    if (timer == heap->buf[0]) {
        heap->timer0Deadline = timer->deadline;
    }
    heap->numTimers++;
}

/* Initializes the timer. It is registered with the processor and is invoked during processor initialization. */
void *TimerHeapInit(void)
{
    struct TimerHeap *heap;
    int error;
    heap = (struct TimerHeap *)MapleRuntime::NativeAllocator::NativeAlloc(sizeof(struct TimerHeap));
    if (heap == nullptr) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "timerheap NativeAlloc failed");
        return nullptr;
    }
    error = pthread_mutex_init(&heap->mutex, nullptr);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        MapleRuntime::NativeAllocator::NativeFree(heap, sizeof(struct TimerHeap));
        return nullptr;
    }

    heap->buf = (struct TimerNode **)MapleRuntime::NativeAllocator::NativeAlloc(
        sizeof(struct TimerNode *) * TIMER_HEAP_SIZE);
    if (heap->buf == nullptr) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "timerheap->buf NativeAlloc failed");
        MapleRuntime::NativeAllocator::NativeFree(heap, sizeof(struct TimerHeap));
        return nullptr;
    }
    heap->numTimers = 0;
    heap->adjustTimers = 0;
    heap->stoppedTimers = 0;
    heap->timer0Deadline = 0;
    heap->capacity = TIMER_HEAP_SIZE;
    return reinterpret_cast<void *>(heap);
}

/* Updates the timer0_deadline member of a timer. */
void TimerUpdateTimer0Ddl(struct TimerHeap *heap)
{
    if (heap->numTimers == 0) {
        heap->timer0Deadline = 0;
    } else {
        heap->timer0Deadline = heap->buf[0]->deadline;
    }
}

/* Delete the timer whose index is idx from the specified timer heap. */
void TimerRemove(struct TimerHeap *heap, unsigned long long idx)
{
    unsigned long long last;

    last = heap->numTimers - 1;
    if (idx != last) {
        heap->buf[idx] = heap->buf[last];
        if (idx != 0) {
            TimerShiftUp(heap, idx);
        }
        TimerShiftDown(heap, idx);
    }
    /* If idx is the last element in the array, set heap->numTimers -= 1. */
    heap->numTimers -= 1;
    if (idx == 0) {
        TimerUpdateTimer0Ddl(heap);
    }
}

void TimerStoppedDoRemove(struct TimerHeap *heap, struct TimerNode *timer)
{
    TimerStatus status = TIMER_REMOVING;
    TimerRemove(heap, 0);
    if (timer->autoReleasing) {
        MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
        --g_timerNum;
    } else if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_REMOVED)) {
        // No problem occurs in atomic switching in the timer code. If other problems occur,
        // the code cannot solve the problem. Therefore, only logs are recorded and no information is returned.
        LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", (int)atomic_load(&timer->status));
    }
    atomic_fetch_sub(&heap->stoppedTimers, 1ULL);
}

/*
 * The timer_heap_top_adjust function clears the header of the timer queue.
 * The caller needs to lock the timer.
 **/
void TimerHeapTopAdjust(struct TimerHeap *heap)
{
    struct TimerNode *timer;
    TimerStatus status;
    TimerStatus midStatus;
    while (true) {
        if (heap->numTimers == 0) {
            return;
        }
        timer = heap->buf[0];
        status = atomic_load(&timer->status);
        switch (status) {
            case TIMER_STOPPED: {
                if (!atomic_compare_exchange_weak(&timer->status, &status, TIMER_REMOVING)) {
                    continue;
                }
                TimerStoppedDoRemove(heap, timer);
                break;
            }
            case TIMER_MODIFIED_AHEAD: // fall through
            case TIMER_MODIFIED_DELAYED:
                if (!atomic_compare_exchange_weak(&timer->status, &status, TIMER_MOVING)) {
                    continue;
                }
                midStatus = TIMER_MOVING;
                /* The timer needs to be reused. Therefore, the free timer is not required. */
                timer->deadline = timer->newDeadline;
                TimerRemove(heap, 0);
                TimerDoAdd(heap, timer);
                if (status == TIMER_MODIFIED_AHEAD) {
                    atomic_fetch_sub(&heap->adjustTimers, 1ULL);
                }
                if (!atomic_compare_exchange_strong(&timer->status, &midStatus, TIMER_WAITING)) {
                    // The atomic exchange failure should not occur. If the timer may be overwritten,
                    // record logs and forcibly set the timer to TIMER_WAITING.
                    LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", (int)atomic_load(&timer->status));
                    atomic_store(&timer->status, TIMER_WAITING);
                    return;
                }
                break;
            default:
                return;
        }
    }
}

/*
 * Add a timer to the timer.
 * Ensure that the cjthread is not switched out during the adding process.
 **/
void TimerAdd(struct TimerHeap *heap, struct TimerNode *timer)
{
    pthread_mutex_lock(&heap->mutex);
    TimerHeapTopAdjust(heap);
    TimerDoAdd(heap, timer);
    pthread_mutex_unlock(&heap->mutex);
}

int TimerStopAheadStateAdjust(struct TimerHeap *heap, struct TimerNode *timer, TimerStatus curStatus)
{
    if (atomic_compare_exchange_strong(&timer->status, &curStatus, TIMER_MODIFYING)) {
        curStatus = TIMER_MODIFYING;
        atomic_fetch_sub(&heap->adjustTimers, 1ULL);
        if (!atomic_compare_exchange_strong(&timer->status, &curStatus, TIMER_STOPPED)) {
            LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            // If the modification fails, restore the timer to the original state.
            atomic_store(&timer->status, TIMER_MODIFIED_AHEAD);
            atomic_fetch_add(&heap->adjustTimers, 1ULL);
            return ERROR_TIMER_STATE;
        }
        atomic_fetch_add(&heap->stoppedTimers, 1ULL);
        return 0;
    }
    LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
    return ERROR_TIMER_STATE;
}

int TimerStopStateAdjust(struct TimerHeap *heap, struct TimerNode *timer)
{
    TimerStatus curStatus;
    while (true) {
        curStatus = atomic_load(&timer->status);
        switch (curStatus) {
            case TIMER_MODIFIED_DELAYED: // fall through
            case TIMER_WAITING:
                if (!atomic_compare_exchange_weak(&timer->status, &curStatus, TIMER_STOPPED)) {
                    LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                    continue;
                }
                atomic_fetch_add(&heap->stoppedTimers, 1ULL);
                return 0;
            case TIMER_RUNNING:  // fall through
            case TIMER_MOVING:  // fall through
            case TIMER_MODIFYING:
                OsYield();
                break;
            case TIMER_IDLE: // fall through
            case TIMER_STOPPED: // fall through
            case TIMER_REMOVING: // fall through
            case TIMER_REMOVED:
                return ERROR_TIMER_STOP_FAILED;
            case TIMER_MODIFIED_AHEAD:
                return TimerStopAheadStateAdjust(heap, timer, curStatus);
            default:
                LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                return ERROR_TIMER_STATE;
        }
    }
}

/* Obtain the heap through the timer. */
int TimerGetHeap(struct TimerNode *timer, struct TimerHeap **heap)
{
    if (timer == nullptr) {
        LOG_ERROR(ERROR_TIMER_HANDLE_INVALID, "illegal timer handle");
        *heap = nullptr;
        return ERROR_TIMER_HANDLE_INVALID;
    }
    *heap = (struct TimerHeap *)ProcessorGetspecific((const struct Processor *)timer->pPtr, KEY_TIMER);
    if (*heap == nullptr) {
        LOG_ERROR(ERROR_TIMER_PPTR, "ProcessorGetspecific heap is null");
        return ERROR_TIMER_PPTR;
    }
    return 0;
}

/* Stop the timer and mark its status as TIMER_STOPMED */
int TimerStop(TimerHandle handle)
{
    struct TimerNode *timer;
    struct TimerHeap *heap;
    int res;

    timer = (struct TimerNode *)handle;
    res = TimerGetHeap(timer, &heap);
    if (res != 0) {
        return res;
    }

    res = TimerStopStateAdjust(heap, timer);

    return res;
}

void TimerResetDoChange(struct TimerNode *timer, struct TimerResetPara *para)
{
    timer->newDeadline = TimerDeadlineCheck(CurrentNanotimeGet(), para->ddl);
    timer->period = para->period;
    if (para->func != nullptr) {
        timer->func = para->func;
        timer->args = para->args;
    }
}

int TimerResetHeapAdjust(struct TimerHeap *heap, struct TimerNode *timer,
                         bool wasRemoved, int init, struct TimerResetPara *para)
{
    TimerStatus midStatus;
    TimerStatus newStatus;

    midStatus = TIMER_MODIFYING;
    if (wasRemoved) {
        return ERROR_TIMER_FREE;
    } else {
        TimerResetDoChange(timer, para);
        newStatus = (timer->newDeadline < timer->deadline) ? TIMER_MODIFIED_AHEAD : TIMER_MODIFIED_DELAYED;
        if (init == TIMER_MODIFIED_AHEAD) {
            atomic_fetch_sub(&heap->adjustTimers, 1ULL);
        }
        if (newStatus == TIMER_MODIFIED_AHEAD) {
            atomic_fetch_add(&heap->adjustTimers, 1ULL);
        }
        if (!atomic_compare_exchange_strong(&timer->status, &midStatus, newStatus)) {
            LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            atomic_store(&timer->status, newStatus);
            return ERROR_TIMER_STATE;
        }
    }
    return 0;
}

int TimerResetStatusAdjust(struct TimerHeap *heap, struct TimerNode *timer,
                           bool *wasRemoved, TimerStatus *status)
{
    bool flag = true;
    while (flag) {
        *status = atomic_load(&timer->status);
        switch (*status) {
            case TIMER_MODIFIED_AHEAD: // fall through
            case TIMER_WAITING: // fall through
            case TIMER_MODIFIED_DELAYED:
                if (atomic_compare_exchange_weak(&timer->status, status, TIMER_MODIFYING)) {
                    flag = false;
                }
                break;
            case TIMER_REMOVED: // fall through
            case TIMER_IDLE:
                if (atomic_compare_exchange_weak(&timer->status, status, TIMER_MODIFYING)) {
                    flag = false;
                    *wasRemoved = true;
                }
                break;
            case TIMER_STOPPED:
                if (atomic_compare_exchange_weak(&timer->status, status, TIMER_MODIFYING)) {
                    atomic_fetch_sub(&heap->stoppedTimers, 1ULL);
                    flag = false;
                }
                break;
            case TIMER_RUNNING: // fall through
            case TIMER_REMOVING: // fall through
            case TIMER_MODIFYING: // fall through
            case TIMER_MOVING:
                OsYield();
                break;
            default:
                LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                return ERROR_TIMER_STATE;
        }
    }
    return 0;
}

int TimerReset(TimerHandle handle, unsigned long long ddl,
               unsigned long long period, TimerFunc fun, void *args)
{
    int res;
    TimerStatus status;
    struct TimerNode *timer;
    struct TimerHeap *heap;
    struct TimerResetPara para;
    bool wasRemoved = false;

    timer = (struct TimerNode *)handle;
    res = TimerGetHeap(timer, &heap);
    if (res != 0) {
        return res;
    }

    para.ddl = ddl;
    para.period = period;
    para.func = fun;
    para.args = args;
    res = TimerResetStatusAdjust(heap, timer, &wasRemoved, &status);
    if (res != 0) {
        return res;
    }
    res = TimerResetHeapAdjust(heap, timer, wasRemoved, status, &para);
    return res;
}

/* Help processing timer, return ADJUDGED_BREAK_current_LOOP_NUMBER to exit the loop,
 * return 0 to process the current timer, return 1 to process the next timer
 */
int TimerTriggerHeapStateAdjust(struct TimerHeap *heap, unsigned long long idx, struct MoveItem *needMove)
{
    struct TimerNode *timer;
    TimerStatus status;
    timer = heap->buf[idx];
    status = atomic_load(&timer->status);
    switch (status) {
        case TIMER_STOPPED: {
            if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_REMOVING)) {
                return 1;
            }
            TimerRemove(heap, idx);
            status = TIMER_REMOVING;
            if (timer->autoReleasing) {
                MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
                --g_timerNum;
            } else if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_REMOVED)) {
                // No problem occurs in atomic switching in the timer code. If other problems occur,
                // the code cannot solve the problem. Therefore, only logs are recorded and no information is returned.
                LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            }
            atomic_fetch_sub(&heap->stoppedTimers, 1ULL);
            return 0;
        }
        case TIMER_MODIFIED_AHEAD: // fall through
        case TIMER_MODIFIED_DELAYED: {
            if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_MOVING)) {
                return 1;
            }
            timer->deadline = timer->newDeadline;
            TimerRemove(heap, idx);
            needMove->buf[needMove->len++] = timer;
            if (status == TIMER_MODIFIED_AHEAD) {
                atomic_fetch_sub(&heap->adjustTimers, 1ULL);
                if (heap->adjustTimers <= 0) {
                    return ADJUST_BREAK_CURRENT_LOOP_NUMBER;
                }
            }
            return 0;
        }
        case TIMER_MODIFYING:
            OsYield();
            return 0;
        case TIMER_WAITING:
            return 1;
        default:
            LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            return ADJUST_BREAK_CURRENT_LOOP_NUMBER;
    }
}

/*
 * Adjust the timer that is triggered earlier in the timer. Place the timer in the correct position.
 * If the value of adjust_timers of timer heap is 0, the value of adjust_timers is returned.
 * The timer that runs later will be adjusted and the timer marked as TIMER_STOPMED will be deleted.
 **/
void TimerTriggerHeapAdjust(struct TimerHeap *heap)
{
    int ret;
    TimerStatus midStatus;
    unsigned long long i;
    struct TimerNode *timer;
    struct MoveItem needMove;
    if (heap->numTimers == 0 || heap->adjustTimers == 0) {
        return;
    }
    // Keep the allocation size because adjustment can remove stopped timers.
    const size_t needMoveBytes = sizeof(void *) * heap->numTimers;
    needMove.buf = (void **)MapleRuntime::NativeAllocator::NativeAlloc(needMoveBytes);
    if (needMove.buf == nullptr) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "struct MoveItem.buf alloc failed");
        return;
    }
    needMove.len = 0;
    ret = memset_s(needMove.buf, needMoveBytes, 0, needMoveBytes);
    if (ret != 0) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "needMove.buf memset failed");
        MapleRuntime::NativeAllocator::NativeFree(needMove.buf, needMoveBytes);
        return;
    }
    for (i = 0; i < heap->numTimers;) {
        int then = TimerTriggerHeapStateAdjust(heap, i, &needMove);
        if (then == ADJUST_BREAK_CURRENT_LOOP_NUMBER) {
            break;
        }
        i += static_cast<unsigned long long>(then);
    }
    for (i = 0; i < needMove.len; i++) {
        timer = (struct TimerNode *)needMove.buf[i];
        midStatus = TIMER_MOVING;
        TimerDoAdd(heap, timer);
        if (!atomic_compare_exchange_strong(&timer->status, &midStatus, TIMER_WAITING)) {
            // To avoid massive logs, if the switchover fails, the system records logs and then
            // sets the status to TIMER_WAITING.
            LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            atomic_store(&timer->status, TIMER_WAITING);
        }
    }
    MapleRuntime::NativeAllocator::NativeFree(needMove.buf, needMoveBytes);
}

/* When a timer is executed, the caller must lock the timer. During the running of the timer,
 * the timer is temporarily unlocked.
 */
void TimerTimer0Run(struct TimerHeap *heap, struct TimerNode *timer, unsigned long long now)
{
    unsigned long long dur;
    TimerStatus status = TIMER_RUNNING;
    if (timer->period > 0) {
        unsigned long long delta = now - timer->deadline;
        dur = timer->period * (1 + delta / timer->period);
        timer->deadline = TimerDeadlineCheck(timer->deadline, dur);
        TimerShiftDown(heap, 0);
        if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_WAITING)) {
            LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
            return;
        }
        TimerUpdateTimer0Ddl(heap);
        pthread_mutex_unlock(&heap->mutex);
        timer->func(timer->args);
        pthread_mutex_lock(&heap->mutex);
    } else {
        TimerRemove(heap, 0);
        pthread_mutex_unlock(&heap->mutex);
        timer->func(timer->args);
        pthread_mutex_lock(&heap->mutex);
        if (timer->autoReleasing) {
            MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
            --g_timerNum;
        } else {
            atomic_store(&timer->status, TIMER_IDLE);
        }
    }
}

int TimerTimer0StateAdjust(struct TimerHeap *heap, struct TimerNode *timer, TimerStatus status)
{
    TimerStatus newStatus;
    if (status == TIMER_STOPPED) {
        if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_REMOVING)) {
            return 0;
        }
        TimerStoppedDoRemove(heap, timer);
        if (heap->numTimers == 0) {
            return RUN_TIMER_NO_MORE_TIMER;
        }
        return 0;
    }
    if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_MOVING)) {
        return 0;
    }
    newStatus = TIMER_MOVING;
    timer->deadline = timer->newDeadline;
    TimerRemove(heap, 0);
    TimerDoAdd(heap, timer);
    if (status == TIMER_MODIFIED_AHEAD) {
        atomic_fetch_sub(&heap->adjustTimers, 1ULL);
    }
    // The atomic exchange failure should not occur. If the timer may be overwritten,
    // record logs and forcibly set the timer to TIMER_WAITING.
    if (!atomic_compare_exchange_strong(&timer->status, &newStatus, TIMER_WAITING)) {
        LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
        atomic_store(&timer->status, TIMER_WAITING);
    }
    return 0;
}

/*
 * The runtime checks the first timer in the timer, runs the timer and updates or deletes it
 * if it is ready. If the timer is running, 0 is returned. If there are no more timers,
 * RUN_TIMER_NO_ MORE_TIMER is returned. If the time is not ready, the time when the first
 * timer is triggered is returned. The timer must be locked before invoking. If the timer is
 * run, the timer is temporarily unlocked.
 */
unsigned long long TimerTimer0StateAdjustAndRun(struct TimerHeap *heap, unsigned long long now)
{
    TimerStatus status;
    int res;
    while (true) {
        struct TimerNode *timer = heap->buf[0];
        status = atomic_load(&timer->status);
        switch (status) {
            case TIMER_WAITING: {
                if (timer->deadline > now) {
                    return timer->deadline;
                }
                if (!atomic_compare_exchange_weak(&timer->status, &status, TIMER_RUNNING)) {
                    continue;
                }
                TimerTimer0Run(heap, timer, now);
                return 0;
            }
            case TIMER_STOPPED:  // fall through
            case TIMER_MODIFIED_AHEAD:  // fall through
            case TIMER_MODIFIED_DELAYED: {
                res = TimerTimer0StateAdjust(heap, timer, status);
                if (res != 0) {
                    return static_cast<unsigned long long>(res);
                }
                break;
            }
            case TIMER_MODIFYING: {
                OsYield();
                break;
            }
            default: {
                LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", status);
                return ERROR_TIMER_STATE;
            }
        }
    }
}

int TimerStoppedWaitingAdjust(struct TimerHeap *heap, struct TimerNode *timer, bool changed,
                              unsigned long long int *bufIndex)
{
    if (changed) {
        heap->buf[*bufIndex] = timer;
        TimerShiftUp(heap, *bufIndex);
    }
    ++(*bufIndex);
    return 0;
}

/*
 * Return ERROR_TIMER_STATE indicates that the status is incorrect.
 * Return 0 to proceed to the next
 * Return 1 indicates that the timer has been changed
 */
int TimerStoppedStateAdjust(struct TimerHeap *heap, struct TimerNode *timer,
                            bool changed, struct TimerStoppedPara *timerStoppedPara)
{
    TimerStatus midStatus;
    TimerStatus status;
    while (true) {
        status = atomic_load(&timer->status);
        switch (status) {
            case TIMER_WAITING:
                return TimerStoppedWaitingAdjust(heap, timer, changed, &(timerStoppedPara->bufIndex));
            case TIMER_MODIFIED_AHEAD:
            case TIMER_MODIFIED_DELAYED:
                if (!atomic_compare_exchange_weak(&timer->status, &status, TIMER_MOVING)) {
                    continue;
                }
                midStatus = TIMER_MOVING;
                timer->deadline = timer->newDeadline;
                heap->buf[timerStoppedPara->bufIndex] = timer;
                TimerShiftUp(heap, (timerStoppedPara->bufIndex)++);
                if (!atomic_compare_exchange_strong(&timer->status, &midStatus, TIMER_WAITING)) {
                    // The atomic exchange failure should not occur. If the timer may be overwritten,
                    // record logs and forcibly set the timer to TIMER_WAITING.
                    LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                    atomic_store(&timer->status, TIMER_WAITING);
                    return ERROR_TIMER_STATE;
                }
                if (status == TIMER_MODIFIED_AHEAD) {
                    (timerStoppedPara->aheadcnt)++;
                }
                return 1;
            case TIMER_STOPPED:
                if (!atomic_compare_exchange_weak(&timer->status, &status, TIMER_REMOVING)) {
                    continue;
                }
                status = TIMER_REMOVING;
                (timerStoppedPara->delcnt)++;
                if (timer->autoReleasing) {
                    MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
                    --g_timerNum;
                } else if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_REMOVED)) {
                    // The atomic exchange failure should not occur. If the timer may be overwritten,
                    // record logs and forcibly set the timer to TIMER_WAITING.
                    LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                    atomic_store(&timer->status, TIMER_REMOVED);
                    return ERROR_TIMER_STATE;
                }
                return 1;
            case TIMER_MODIFYING:
                OsYield();
                break;
            default:
                LOG_ERROR(ERROR_TIMER_STATE, "time state: %d", atomic_load(&timer->status));
                return ERROR_TIMER_STATE;
        }
    }
}

void TimerStoppedClear(struct TimerHeap *heap)
{
    struct TimerStoppedPara timerStoppedPara = {0, 0, 0};
    unsigned long long i;
    int res;
    bool changed = false;
    for (i = 0; i < heap->numTimers; i++) {
        res = TimerStoppedStateAdjust(heap, heap->buf[i], changed, &timerStoppedPara);
        if (res == ERROR_TIMER_STATE) {
            return;
        }
        if (res == 1) {
            changed = true;
        }
    }
    atomic_fetch_sub(&heap->stoppedTimers, timerStoppedPara.delcnt);
    heap->numTimers -= timerStoppedPara.delcnt;
    atomic_fetch_sub(&heap->adjustTimers, timerStoppedPara.aheadcnt);
    TimerUpdateTimer0Ddl(heap);
}

/* Check the now pointer of timer_trigger. If the value of now is not 0,
 * use now as the current time. Otherwise, use a new time.
 */
unsigned long long TimerTriggerNowCheck(unsigned long long *now)
{
    unsigned long long rnow;
    if (now == nullptr) {
        rnow = CurrentNanotimeGet();
    } else if (*now == 0) {
        rnow = CurrentNanotimeGet();
        *now = rnow;
    } else {
        rnow = *now;
    }
    return rnow;
}

/*
 * Check that all timers are placed in the correct position and run the timer for the prepared
 * timers. If 0 is returned, the timer is successfully executed or the triggering time is not
 * reached. If an error occurs, an error code is returned. The purpose of passing in now is to
 * avoid getting stuck in duplicate system calls CurrentNanotimeGet at some point.
 */
int TimerTrigger(struct Processor *processor, unsigned long long *now, bool *run)
{
    struct TimerHeap *heap;
    unsigned long long timer0Deadline;
    unsigned long long rnow = 0;
    unsigned long long ret;

    if (processor == nullptr) {
        return ERROR_TIMER_PTR_INVALID;
    }

    if (run != nullptr) {
        *run = false;
    }

    // check whether the timer heap of some processors is initialized, because some timer
    // heaps of processors may be initialized and some are not initialized. If the system
    // is not initialized, the system returns.
    heap = (struct TimerHeap *)ProcessorGetspecific(processor, KEY_TIMER);
    if (heap == nullptr || heap->numTimers == 0) {
        if (now != nullptr) {
            *now = 0;
        }
        return 0;
    }
    if (heap->adjustTimers == 0) {
        timer0Deadline = heap->timer0Deadline;
        if (timer0Deadline == 0) {
            return 0;
        }
        rnow = TimerTriggerNowCheck(now);
        if (rnow < timer0Deadline) {
            return 0;
        }
    }
    pthread_mutex_lock(&heap->mutex);
    TimerTriggerHeapAdjust(heap);
    while (heap->numTimers > 0) {
        rnow = CurrentNanotimeGet();
        ret = TimerTimer0StateAdjustAndRun(heap, rnow);
        if (ret != 0) {
            break;
        }
        if (run != nullptr) {
            *run = true;
        }
    }
    if (now != nullptr) {
        *now = rnow;
    }
    if (atomic_load(&heap->stoppedTimers) > heap->numTimers / FORKS_NUM) {
        TimerStoppedClear(heap);
    }
    pthread_mutex_unlock(&heap->mutex);
    return 0;
}

int TimerHeapInitAndAdd(struct TimerNode *timer)
{
    struct TimerHeap *timers;
    struct Processor *processor = ProcessorGet();

    // Check whether the timer of the current processor is initialized. If the timer is
    // initialized, insert the timer into the timer. If the timer is not initialized
    // insert the timer after initialization.
    timers = (struct TimerHeap *)ProcessorGetspecific(processor, KEY_TIMER);
    timer->pPtr = processor;
    if (timers != nullptr) {
        TimerAdd(timers, timer);
    } else {
        timers = (struct TimerHeap *)TimerHeapInit();
        if (timers == nullptr) {
            LOG_ERROR(ERROR_TIMER_ALLOC, "timer heap alloc failed");
            return ERROR_TIMER_ALLOC;
        }
        // Put the timer heap into the array of the processor.
        ProcessorSetspecific(processor, KEY_TIMER, timers);
        TimerAdd(timers, timer);
    }
    return 0;
}

struct TimerNode *TimerInit(unsigned long long dur, unsigned long long period, TimerFunc func, void *args)
{
    struct TimerNode *timer;
    // create and init timer
    timer = (struct TimerNode *)MapleRuntime::NativeAllocator::NativeAlloc(sizeof(struct TimerNode));
    if (timer == nullptr) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "timer alloc failed");
        return nullptr;
    }
    timer->deadline = TimerDeadlineCheck(CurrentNanotimeGet(), dur);
    timer->newDeadline = 0;
    timer->period = period;
    timer->func = func;
    timer->args = args;
    timer->autoReleasing = false;
    atomic_store(&timer->status, TIMER_WAITING);

    return timer;
}

/* create a timer */
TimerHandle TimerNew(unsigned long long dur, unsigned long long period, TimerFunc fun, void *args)
{
    struct TimerNode *timer = nullptr;
    int error;

    ++g_timerNum;
    // ++g_timerNum is used before the schedule is suspended. This ensures that the actual number
    // of timers does not increase compared with the value returned by TimerNum() when the schedule
    // is suspended. Consider the following concurrency scenarios:
    // 1. After the determination is passed, the schedule status changes to Suspending.
    //    g_timerNum does not increase no matter whether the TimerNew is successful or not.
    // 2. If the status of the schedule changes to Suspending before the check is passed,
    //    the check fails and the actual number of timers does not increase.
    if (CJThreadGet() == nullptr || ScheduleGet()->state == SCHEDULE_SUSPENDING ||
        ScheduleGet()->state == SCHEDULE_WAITING) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "timer new failed, schd suspend or cjthread is nullptr");
        --g_timerNum;
        return nullptr;
    }

    if (fun == nullptr) {
        LOG_ERROR(ERROR_TIMER_NEW_PARA_INVALID, "timer new para func not allow nullptr");
        --g_timerNum;
        return nullptr;
    }

    timer = TimerInit(dur, period, fun, args);
    if (timer == nullptr) {
        --g_timerNum;
        return nullptr;
    }

    // Check whether the check_timer function hook of the scheduling framework is initialized for multiple times.
    error = SchdProcessorHookRegister(TimerTrigger, PROCESSOR_TIMER_HOOK);
    if (error == 0) {
        SchdSchmonHookRegister(TimerSchmonCheck, SCHMON_TIMER_HOOK);
        SchdCheckExistenceHookRegister(TimerCheckExistence);
        SchdCheckReadyHookRegister(TimerCheckReady);
        SchdExitHookRegister(TimerExit, KEY_TIMER);
    }
    if (TimerHeapInitAndAdd(timer) != 0) {
        LOG_ERROR(ERROR_TIMER_ALLOC, "timer heap alloc failed");
        --g_timerNum;
        MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
        return nullptr;
    }
    return (TimerHandle)timer;
}

void TimerSleepCoreadyCallback(void *args)
{
    CJThreadHandle sleepCJThread = (CJThreadHandle)args;
    CJThreadReady(sleepCJThread);
}

int TimerSleepCoparkCallback(void *sleepTime, CJThreadHandle sleep_cjthread)
{
    TimerHandle timer = TimerNew(*(unsigned long long *) sleepTime,
                                 0, TimerSleepCoreadyCallback, (void *) sleep_cjthread);
    if (timer == nullptr) {
        LOG_ERROR(ERROR_TIMER_PTR_INVALID, "timer new failed");
        return ERROR_TIMER_PTR_INVALID;
    }
    TimerRelease(timer);
    return 0;
}

/*
 * Process: Invoke CJThreadPark and transfer the TimerSleepCoparkCallback callback function to
 * create a timer after switching to cjthread_0. The timer transfers the callback function
 * TimerSleepCoreadyCallback, and the parameter is cjthread_handle. After the timer is triggered,
 * call CJThreadReady to wake up the sleeping cjthread.
 */
int TimerSleep(long long duration)
{
    int res;
    if (CJThreadGet() == nullptr) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "cjthread is nullptr");
        return ERRNO_SCHD_UNINITED;
    }
    if (duration <= 0) {
        CJThreadResched();
        return 0;
    }
    res = CJThreadPark(TimerSleepCoparkCallback, TRACE_EV_CJTHREAD_SLEEP, (void *)&duration);
    if (res != 0) {
        LOG_ERROR(res, "callback func failed");
        return res;
    }
    return 0;
}

/* TimerTryStop provided for mutex */
int TimerTryStop(TimerHandle handle)
{
    struct TimerNode *timer;
    struct TimerHeap *heap;
    TimerStatus status;
    int res;

    timer = (struct TimerNode *)handle;
    res = TimerGetHeap(timer, &heap);
    if (res != 0) {
        return res;
    }

    while (true) {
        status = atomic_load(&timer->status);
        if (status == TIMER_WAITING) {
            if (!atomic_compare_exchange_strong(&timer->status, &status, TIMER_STOPPED)) {
                continue;
            }
            atomic_fetch_add(&heap->stoppedTimers, 1ULL);
            return 0;
        } else {
            return ERROR_TIMER_IS_NOT_WAITING;
        }
    }
    return 0;
}

int TimerExit(void *processor)
{
    struct TimerHeap *heap;

    heap = (struct TimerHeap *)ProcessorGetspecific((const struct Processor *)processor, KEY_TIMER);
    if (heap != nullptr) {
        if (heap->buf != nullptr) {
            pthread_mutex_lock(&heap->mutex);
            unsigned long long numTimers = heap->numTimers;
            heap->numTimers = 0;
            while (numTimers > 0) {
                MapleRuntime::NativeAllocator::NativeFree(heap->buf[--numTimers], sizeof(struct TimerNode));
                --g_timerNum;
            }
            pthread_mutex_unlock(&heap->mutex);
            MapleRuntime::NativeAllocator::NativeFree(heap->buf, sizeof(struct TimerNode *) * heap->capacity);
        }
        MapleRuntime::NativeAllocator::NativeFree(heap, sizeof(struct TimerHeap));
    }

    return 0;
}

/* check timer in schmon */
int TimerSchmonCheck(void *pro, unsigned long long now)
{
    struct TimerHeap *timer;
    struct Processor *processor = (struct Processor *)pro;

    timer = (struct TimerHeap *)ProcessorGetspecific(processor, KEY_TIMER);
    if (timer == nullptr) {
        return 0;
    }
    struct Schedule* schedule = reinterpret_cast<struct Schedule*>(processor->schedule);
    struct Schedule* wakeSchedule = schedule == nullptr ? ScheduleGet() : schedule;
    /* If timer0_deadline is 0, there is no timer in heap. */
    if (timer->timer0Deadline != 0 && now >= timer->timer0Deadline) {
        if (processor->state == PROCESSOR_RUNNING) {
            ProcessorWake(wakeSchedule, nullptr);
        } else if (processor->state == PROCESSOR_IDLE) {
            ProcessorWake(wakeSchedule, processor);
        }
    }
    return 0;
}

/* Check whether a timer that can be triggered exists in the processor. */
bool TimerCheckReady(struct Processor *processor)
{
    struct TimerHeap *timer;

    timer = static_cast<struct TimerHeap *>(ProcessorGetspecific(processor, KEY_TIMER));
    if (timer == nullptr) {
        return false;
    }
    if (timer->timer0Deadline != 0 && CurrentNanotimeGet() >= timer->timer0Deadline) {
        return true;
    }
    return false;
}

/* Check whether the timer exists in the processor. */
bool TimerCheckExistence(void *processor)
{
    struct TimerHeap *heap;

    heap = (struct TimerHeap *)ProcessorGetspecific((const struct Processor *)processor,
                                                    KEY_TIMER);
    if (heap != nullptr) {
        return heap->numTimers != 0;
    }
    return false;
}

/*
 * Returns the number of existing timers. The schedule function is invoked to check whether
 * a timer exists when the schedule is in the Suspended state. In this case, TimerNum ensures
 * that the actual number of timers does not increase after the number of timers is returned.
 */
int TimerNum(void)
{
    return g_timerNum;
}

int TimerRelease(TimerHandle handle)
{
    struct TimerNode *timer;
    struct TimerHeap *heap;
    int res;

    timer = (struct TimerNode *)handle;
    res = TimerGetHeap(timer, &heap);
    if (res != 0) {
        return res;
    }

    // During heap adjustment, the timer that is in autoReleasing mode and is about to be
    // removed from the heap is released. In this function, the timer is released in the case
    // of TIMER_REMOVE or TIMER_IDLE. A lock is added here to ensure that curStatus does not
    // change to TIMER_REMOTED during execution. In this case, memory leakage occurs (removed
    // and autoReleasing).
    pthread_mutex_lock(&heap->mutex);
    TimerStatus curStatus = atomic_load(&timer->status);
    if (curStatus == TIMER_REMOVED || curStatus == TIMER_IDLE) {
        MapleRuntime::NativeAllocator::NativeFree(timer, sizeof(struct TimerNode));
        --g_timerNum;
    } else {
        timer->autoReleasing = true;
    }
    pthread_mutex_unlock(&heap->mutex);

    return 0;
}

__attribute__((constructor)) int ScheduleTimerHookInit(void)
{
    ScheduleTimerHookRegister(TimerNum, ANY_TIMER_HOOK);
    return 0;
}

#ifdef __cplusplus
}
#endif