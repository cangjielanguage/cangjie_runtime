// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <cstdio>
#include <sched.h>
#include <unistd.h>
#include <ctime>
#include "schedule_impl.h"
#include "securec.h"
#include "schdpoll.h"
#include "basetime.h"
#include "log.h"
#if defined(CANGJIE_SANITIZER_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ProcessorThreadExit sleep_time */
const int PROCESSOR_RELEASE_SLEEP_TIME = 10;
/* undefault schedule processor_cjthread_get round number */
const int PROCESSOR_CJTHREAD_GET_ROUND_NUM = 20;

unsigned int g_randSeed = 0;

int ProcessorGlobalWrite(struct CJThread *cjthreadList[], unsigned int num)
{
    struct Dulink tempDulink;
    struct Schedule *sch;
    unsigned long length;
    unsigned long i;
    void *buf[PROCESSOR_QUEUE_CAPACITY] = {nullptr};
    struct Processor *processor;

    processor = ProcessorGet();
    sch = static_cast<struct Schedule *>(processor->schedule);
    DulinkInit(&tempDulink);

    // Get 1/4 from the local queue and put it into the global queue.
    length = QueueLength(&processor->runq) / GLOBAL_ADD_RATIO;
    if (length != 0) {
        length = QueuePopHeadBatch(&processor->runq, buf, length);
    }

    // To reduce the occupation time of schdCJThread.mutex, use tempDulink to temporarily
    // store the file, and then move the file to runq.
    for (i = 0; i < length; i++) {
        DulinkPushtail(&tempDulink, buf[i]);
    }

    for (i = 0; i < num; i++) {
        DulinkPushtail(&tempDulink, cjthreadList[i]);
    }

    // Add to the global queue of the schedule.
    pthread_mutex_lock(&sch->schdCJThread.mutex);
    DulinkMove(&sch->schdCJThread.runq, &tempDulink, 0);
    sch->schdCJThread.num += (length + num);
    pthread_mutex_unlock(&sch->schdCJThread.mutex);

    return 0;
}

/* Add the cjthread to the processor's run queue. */
int ProcessorLocalWriteBatch(struct CJThread **cjthread, unsigned int num)
{
    int ret;
    struct Queue *runq;
    unsigned int pushNum;
    struct Processor *processor;

    processor = ProcessorGet();
    runq = &processor->runq;
    pushNum = QueuePushTailBatch(runq, reinterpret_cast<void **>(cjthread), num);
    if (pushNum == num) {
        return 0;
    }

    // If add to local queue fail, add to global queue
    ret = ProcessorGlobalWrite(cjthread + pushNum, num - pushNum);
    if (ret) {
        LOG_ERROR(ret, "write global queue failed!");
        return ret;
    }

    return 0;
}

/* Bulk fetching schedulable cjthreads from the global queue */
struct CJThread *ProcessorGlobalRead(void *schedule, bool batch)
{
    struct ScheduleCJThread *schdCJThread;
    struct Dulink *runDulink;
    struct Dulink tempDulink;
    struct CJThread *cjthreadTemp;
    struct CJThread *cjthreadNext = nullptr;
    void *buf[PROCESSOR_QUEUE_CAPACITY];
    unsigned int i;
    unsigned int readNum = 1;
    struct Processor *processor;
    unsigned int processorNum = ((struct Schedule *)schedule)->schdProcessor.processorNum;

    schdCJThread = &((struct Schedule *)schedule)->schdCJThread;
    if (schdCJThread->num == 0) {
        return nullptr;
    }
    runDulink = &schdCJThread->runq;
    pthread_mutex_lock(&(schdCJThread->mutex));

    if (schdCJThread->num == 0) {
        pthread_mutex_unlock(&(schdCJThread->mutex));
        return nullptr;
    }

    if (batch) {
        // The quantity is the number of processes in the global queue divided by the number
        // of processors. The value must be at least 1.
        readNum = (schdCJThread->num + processorNum - 1) / processorNum;
        if (readNum > PROCESSOR_QUEUE_CAPACITY) {
            readNum = PROCESSOR_QUEUE_CAPACITY;
        }
    }
    schdCJThread->num -= readNum;

    // Get one first
    cjthreadNext = DULINK_ENTRY(runDulink->next, struct CJThread, schdDulink);
    DulinkRemove(&(cjthreadNext->schdDulink));

    if (readNum == 1) {
        pthread_mutex_unlock(&(schdCJThread->mutex));
        return cjthreadNext;
    }
    --readNum;
    DulinkInit(&tempDulink);
    DulinkMove(&tempDulink, runDulink, readNum);
    pthread_mutex_unlock(&(schdCJThread->mutex));

    // The rest of the cjthreads are placed in the local queue. If batch is false or only
    // one cjthread is obtained, the loop will not be entered.
    processor = ProcessorGet();
    for (i = 0; i < readNum; i++) {
        cjthreadTemp = DULINK_ENTRY(tempDulink.next, struct CJThread, schdDulink);
        DulinkRemove(&(cjthreadTemp->schdDulink));
        buf[i] = (void *)cjthreadTemp;
    }

    QueuePushTailBatch(&processor->runq, buf, readNum);

    return cjthreadNext;
}

/* Add a single cjthread to the local queue */
int ProcessorLocalWrite(struct CJThread *cjthread, bool isReschd)
{
    int error;
    struct Queue *runq;
    struct Processor *processor;

    processor = ProcessorGet();
    runq = &processor->runq;

    while (true) {
        if (isReschd) {
            error = QueuePushTail(runq, cjthread);
            if (error == 0) {
                return 0;
            }
            error = ProcessorGlobalWrite(&cjthread, 1);
            if (error) {
                LOG_ERROR(error, "write global queue failed!");
            }
            return error;
        }

        struct CJThread *obj = atomic_load_explicit(&processor->cjthreadNext, std::memory_order_relaxed);
        if (atomic_compare_exchange_weak(&processor->cjthreadNext, &obj, cjthread)) {
            if (obj == nullptr) {
                return 0;
            }
            error = QueuePushTail(runq, obj);
            if (error == 0) {
                return 0;
            }
            // If add cjthread to local queue fail, add it to global queue
            error = ProcessorGlobalWrite(&obj, 1);
            if (error) {
                LOG_ERROR(error, "write global queue failed!");
            }
            return error;
        }
    }
    return 0;
}

MRT_STATIC_INLINE unsigned long ProcessorQueueSteal(struct Processor *processor,
                                                    void *buf[], unsigned long bufLen)
{
    struct Queue *stealRunq;
    unsigned long length;

    stealRunq = &processor->runq;
    length = (QueueLength(stealRunq) + PROCESSOR_STEAL_RATIO - 1) / PROCESSOR_STEAL_RATIO;
    if (length == 0) {
        return 0;
    }
    if (length > bufLen) {
        length = bufLen;
    }

    return QueuePopHeadBatch(stealRunq, buf, length);
}

struct CJThread *ProcessorCJThreadSteal(struct Processor *localProcessor, struct Processor *stealProcessor)
{
    unsigned long stealNum;
    unsigned long pushNum;
    void *buf[PROCESSOR_QUEUE_CAPACITY] = {nullptr};
    struct Queue *localRunq;

    // Stealing cjthreads from other processor queues.
    stealNum = ProcessorQueueSteal(stealProcessor, buf, PROCESSOR_QUEUE_CAPACITY);
    if (stealNum == 0) {
        return nullptr;
    }

    // Put the stolen cjthread into the local queue.
    localRunq = &localProcessor->runq;
    pushNum = QueuePushTailBatch(localRunq, buf + 1, stealNum - 1);
    if (pushNum != stealNum - 1) {
        LOG_ERROR(ERRNO_SCHD_LOCAL_QUEUE_PUSH_FAILED,
                  "push local queue failed! steal_num: %u, push_num: %u",
                  stealNum, pushNum);
        return nullptr;
    }

    // Return the local cjthread to be run.
    return (struct CJThread *)buf[0];
}

/* Releases processor resources. In the exit process of the scheduling framework, this
 * function may be invoked twice in the same processor. Therefore, the system checks whether
 * the current processor is NULL first. */
int ProcessorRelease(void)
{
    struct Processor *curProcessor;
    struct Thread *curThread;
    struct Schedule *schedule;

    curProcessor = ProcessorGet();
    if (curProcessor == nullptr) {
        return ERRNO_SCHD_PROCESSOR_STATE_INVALID;
    }

    schedule = static_cast<struct Schedule *>(curProcessor->schedule);

    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_STOP)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_STOP, -1, nullptr, 0);
    }
    // Unbind the processor from the thread.
    curThread = curProcessor->thread;

    curProcessor->thread = nullptr;
    curThread->processor = nullptr;

    // Set the status of the processor and increases the number of idle processors.
    if (schedule->state == SCHEDULE_EXITING) {
        atomic_store(&curProcessor->state, PROCESSOR_EXITING);
    } else {
        atomic_store(&curProcessor->state, PROCESSOR_IDLE);
        atomic_fetch_add(&schedule->schdProcessor.freeNum, 1u);
    }
    return 0;
}

/* check again before stop the processor */
int ProcessorStopWithLastCheck(void)
{
    int ret;
    struct Processor *oldProcessor = ProcessorGet();
    struct Processor *newProcessor;
    struct Schedule *schedule = static_cast<struct Schedule *>(oldProcessor->schedule);

    // release current processor
    ret = ProcessorRelease();
    if (ret != 0) {
        LOG_ERROR(ret, "process release failed!");
        return ret;
    }
    // Note: The processor has been released and may be immediately woken up and occupied
    // by other threads. After exiting the search, need to perform a check, because new
    // cjthreads may be generated here. If we don't check here, there will be two situations
    // where the cjthread cannot be executed:
    // 1. ProcessorWake in CJThreadReady does not perform ProcessorWake because it detects
    // that searching_num is greater than or equal to 1, and at this time, the search thread
    // just exits search
    // 2. ProcessorWake in CJThreadReady does not perform ProcessorWake because it detects
    // that the number of idle processors is 0, while all processors are currently undergoing
    // ProcessorRelease
    if (ScheduleAnyCJThread(schedule)) {
        // get a new processor
        newProcessor = static_cast<struct Processor *>(ThreadBindProcessor(static_cast<void *>(oldProcessor)));
        if (newProcessor != nullptr) {
            // Enter the search state again and continue to search for tasks.
            newProcessor->thread->isSearching = true;
            atomic_fetch_add(&schedule->schdThread.searchingNum, 1u);
            if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_WAKE)) {
                ScheduleTraceEventOrigin(TRACE_EV_PROC_WAKE, -1, nullptr, 1,
                                         static_cast<unsigned long long>(ThreadGet()->tid));
            }
            return 0;
        }
    }

    // Release thread-related resources again. The thread has been unbound from the processor.
    // ScheduleGet cannot obtain the current schedule. Parameters need to be transferred.
    ret = ThreadStop(schedule);
    if (ret != 0) {
        LOG_ERROR(ret, "thread stop failed!");
        return ret;
    }

    return 0;
}

void RandSeedInit(void)
{
    g_randSeed = CurrentNanotimeGet();
}

MRT_STATIC_INLINE unsigned int RandomPseudo(unsigned int range)
{
    if (range == 0) {
        return 0;
    }
#ifdef MRT_WINDOWS
    errno_t ret;
    unsigned int number;
    ret = rand_s(&number);
    if (ret != 0) {
        return 0;
    }
    return number % range;
#else
    return static_cast<unsigned int>(rand_r(&g_randSeed)) % range;
#endif
}

/* steal timer */
MRT_STATIC_INLINE struct CJThread *ProcessorTimerSteal(struct Processor *stealProcessor,
                                                       unsigned long long now)
{
    bool run = false;
    struct CJThread *stealCJThread;
    ProcessorCheckFunc checkFunc;
    Processor *curProcessor;

    checkFunc = g_scheduleManager.check[PROCESSOR_TIMER_HOOK];
    if (checkFunc == nullptr) {
        return nullptr;
    }
    checkFunc(stealProcessor, &now, &run);

    if (run) {
        curProcessor = ProcessorGet();
        stealCJThread = ProcessorCJhreadNextRead(curProcessor);
        if (stealCJThread != nullptr) {
            return stealCJThread;
        }
        // check_func is timer_trigger. Here may generate new cjthread
        stealCJThread = ProcessorLocalRead(curProcessor);
        if (stealCJThread != nullptr) {
            return stealCJThread;
        }
    }

    return nullptr;
}

struct CJThread *ProcessorSteal(unsigned long long now)
{
    unsigned long stealNum;
    unsigned long  processorId;
    struct Processor *localProcessor = ProcessorGet();
    struct Schedule *schedule = static_cast<struct Schedule *>(localProcessor->schedule);
    struct Processor *stealProcessor;
    struct CJThread *stealCJThread;
    struct ScheduleProcessor *schdProcessor = &schedule->schdProcessor;
    unsigned long processorNum = schdProcessor->processorNum;
    bool stealTimersOrRunNext;
    processorId = RandomPseudo(processorNum);
    for (unsigned int i = 0; i < PROCESSOR_STEAL_ROUNDS; ++i) {
        stealTimersOrRunNext = (i == (PROCESSOR_STEAL_ROUNDS - 1));
        for (stealNum = 0; stealNum < processorNum; stealNum++) {
            // get steal processor
            stealProcessor = &schdProcessor->processorGroup[((stealNum + processorId) % processorNum)];
            if (stealProcessor == localProcessor) {
                continue;
            }

            // Trying to steal cjthreads from other processors
            stealCJThread = ProcessorCJThreadSteal(localProcessor, stealProcessor);
            if (stealCJThread != nullptr) {
                return stealCJThread;
            }

            // Determine whether to steal the timer or nextCJthread
            if (!stealTimersOrRunNext) {
                continue;
            }
            stealCJThread = ProcessorTimerSteal(stealProcessor, now);
            if (stealCJThread != nullptr) {
                return stealCJThread;
            }
            stealCJThread = ProcessorCJhreadNextRead(stealProcessor);
            if (stealCJThread != nullptr) {
                return stealCJThread;
            }
        }
        // In multi-thread scenario, the competition caused by theft of processors need be reduced.
        // In single-thread scenario, avoid sleep to improve read and write performance.
        if (schedule->schdThread.searchingNum.load(std::memory_order_relaxed) > PROCESSOR_STEAL_SLEEP_THRESHOLD) {
            usleep(1);
        }
    }
    return nullptr;
}

/* Stealing schedulable cjthreads from other processors */
struct CJThread *ProcessorSearchingSteal(unsigned long long now)
{
    struct CJThread *stealCJThread;
    struct Schedule *schedule = ScheduleGet();
    struct Thread *thread = ThreadGet();
    struct ScheduleProcessor *schdProcessor = &schedule->schdProcessor;
    unsigned long processorNum;

    // The total number of search threads is less than or equal to half of the number of
    // running processors. However, if the current thread is assigned the search state,
    // the system directly enters the search process regardless of the number of threads.
    processorNum = schdProcessor->processorNum;
    if (thread->isSearching == false &&
        RUNNING_PROCESSOR_SEARCHING_NUM_MULTIPLE * schedule->schdThread.searchingNum
        > processorNum - schdProcessor->freeNum) {
        return nullptr;
    }

    // enter searching
    if (!thread->isSearching) {
        thread->isSearching = true;
        atomic_fetch_add(&schedule->schdThread.searchingNum, 1u);
    }

    stealCJThread = ProcessorSteal(now);

    // No matter whether it is stolen or not, you need to exit the search.
    thread->isSearching = false;
    atomic_fetch_sub(&schedule->schdThread.searchingNum, 1u);
    // If a task is stolen, a new thread needs to be waked to ensure the concurrency.
    if (stealCJThread != nullptr) {
        ProcessorWake(schedule, nullptr);
        return stealCJThread;
    }

    return nullptr;
}

/* By default, the scheduler searches for other processors and steals cjthread tasks.
 * Because other schedulers have only one processor, they can only obtain tasks from the
 * global queue. */
struct CJThread *ProcessorSearchingGlobal(void)
{
    struct CJThread *stealCJThread;
    struct Schedule *schedule = ScheduleGet();
    struct Thread *thread = ThreadGet();

    if (!thread->isSearching) {
        thread->isSearching = true;
        atomic_fetch_add(&schedule->schdThread.searchingNum, 1u);
    }
    for (int i = 0; i < PROCESSOR_CJTHREAD_GET_ROUND_NUM; ++i) {
        stealCJThread = ProcessorGlobalRead(schedule, true);
        if (stealCJThread != nullptr) {
            break;
        }
    }
    thread->isSearching = false;
    atomic_fetch_sub(&schedule->schdThread.searchingNum, 1u);

    return stealCJThread;
}

MRT_STATIC_INLINE unsigned long long ProcessorTimerCheck(void)
{
    ProcessorCheckFunc checkFunc;
    unsigned long long now = 0;

    checkFunc = g_scheduleManager.check[PROCESSOR_TIMER_HOOK];
    if (checkFunc != nullptr) {
        checkFunc(ProcessorGet(), &now, nullptr);
    }

    return now;
}

/* This function is similar to the wake function in ProcessorSearchingSteal. It exits the
 * search function and starts a new thread. However, the branch is different. Here is the
 * branch of the global queue and network IO, and the other is the branch of task theft. */
MRT_INLINE static void ProcessorSearchingMore(void)
{
    struct Schedule *schedule;
    struct Thread *thread;
    // If a task is obtained through search, a new thread needs to be started to execute the task.
    thread = ThreadGet();
    if (thread->isSearching) {
        thread->isSearching = false;
        schedule = ScheduleGet();
        atomic_fetch_sub(&schedule->schdThread.searchingNum, 1u);
        ProcessorWake(schedule, nullptr);
    }
}

/* Find the next cjthread to be scheduled. */
struct CJThread *ProcessorCJThreadGet(void)
{
    int ret;
    int num;
    struct CJThread *nextCJThread = nullptr;
    struct Processor *curProcessor;
    struct Schedule *schedule;
    void *buf[SCHDPOLL_ACQUIRE_MAX_NUM];
    unsigned long long now;
    struct CJThread *expected;

    do {
        // Note: The curProcessor may change in each loop. Therefore, the value must be
        // assigned in the loop and cannot be placed outside the loop.
        curProcessor = ProcessorGet();
        schedule = static_cast<struct Schedule *>(curProcessor->schedule);
        if (schedule->scheduleType != SCHEDULE_DEFAULT &&
            (atomic_load_explicit(&schedule->state, std::memory_order_relaxed) == SCHEDULE_EXITING ||
             atomic_load_explicit(&schedule->state, std::memory_order_relaxed) == SCHEDULE_EXITED)) {
            if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_STOP)) {
                ScheduleTraceEventOrigin(TRACE_EV_PROC_STOP, -1, nullptr, 0);
            }
            auto *thread = ThreadGet();
#ifdef CANGJIE_ASAN_SUPPORT
            // return to ThreadEntry, switch to original thread
            MapleRuntime::Sanitizer::AsanExitCJThread(thread);
#endif
            CJThreadContextSet(&thread->context);
        }
        if (schedule->noWaitAttr.nowait && schedule->noWaitAttr.timeout != 0 &&
            (CurrentNanotimeGet() - schedule->noWaitAttr.startTime >= schedule->noWaitAttr.timeout)) {
            auto *thread = ThreadGet();
#ifdef CANGJIE_ASAN_SUPPORT
            // return to ThreadEntry, switch to original thread
            MapleRuntime::Sanitizer::AsanExitCJThread(thread);
#endif
            CJThreadContextSet(&thread->context);
        }

        // check timer first
        now = ProcessorTimerCheck();

        if (g_scheduleManager.trace.openType || g_scheduleManager.trace.shutdown) {
            nextCJThread = ScheduleGetTraceReader();
            if (nextCJThread != nullptr) {
                ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_UNBLOCK, -1, nullptr, TraceArgNum::TRACE_ARGS_2,
                                         CJThreadGetId(static_cast<CJThreadHandle>(nextCJThread)),
                                         SpecialStackId::UNKNOWN);
                break;
            }
        }

        // Obtain cjthread to be scheduled from the global queue or local queue every 32 times.
        if ((curProcessor->schedCnt & (GLOBAL_SCH_NUM - 1)) == GLOBAL_SCH_NUM - 1) {
            nextCJThread = ProcessorGlobalRead(schedule, false);
            if (nextCJThread != nullptr) {
                break;
            }
            // Obtain the cjthread to be scheduled from the local queue to prevent tasks in
            // the local queue from being executed due to continuous next invoking.
            nextCJThread = reinterpret_cast<struct CJThread *>(QueuePopHead(&curProcessor->runq));
            if (nextCJThread != nullptr) {
                break;
            }
        }

        // Check the CJthreadNext corresponding to the current processor. Do not need to execute
        // the cnt+1 because the processor does not need to be switched.
        nextCJThread = ProcessorCJhreadNextRead(curProcessor);
        if (nextCJThread != nullptr) {
            ProcessorSearchingMore();
            return nextCJThread;
        }

        // Attempt to get schedulable cjthread from local queue.
        nextCJThread = ProcessorLocalRead(curProcessor);
        if (nextCJThread != nullptr) {
            break;
        }

        // Attempt to get the last cjthread from the scheduler.
        expected = atomic_load_explicit(&schedule->lastCJThread, std::memory_order_relaxed);
        if (expected && atomic_compare_exchange_strong(&schedule->lastCJThread,
                                                       &expected, static_cast<struct CJThread *>(nullptr))) {
            nextCJThread = expected;
            break;
        }

        // Attempt to get schedulable cjthread from global queue.
        nextCJThread = ProcessorGlobalRead(schedule, true);
        if (nextCJThread != nullptr) {
            break;
        }

        // Attempt to get ready events from netpoll. This interface may return a failure less
        // than zero. For example, fd is disabled when the scheduling framework exits.
        if (schedule->netpoll.npfd != nullptr) {
            num = SchdpollAcquire(schedule, buf, SCHDPOLL_ACQUIRE_MAX_NUM, 0);
            if (num > 0) {
                // After successfully fetching the cjthread from netpoll, review the local
                // and global queues again.
                CJThreadAddBatch(buf, num);
                continue;
            }
        }

        if (schedule->scheduleType == SCHEDULE_DEFAULT) {
            // Attempt to steal cjthreads from other processors
            nextCJThread = ProcessorSearchingSteal(now);
            if (nextCJThread != nullptr) {
                break;
            }
            // If all previous attempts fail, only the current processor can be hibernated.
            // The last check is performed before hibernation.
            ret = ProcessorStopWithLastCheck();
            if (ret) {
                LOG_ERROR(-1, "ProcessorStopWithLastCheck failed");
            }
        } else {
            // Attempt to steal cjthreads from global
            nextCJThread = ProcessorSearchingGlobal();
            if (nextCJThread != nullptr) {
                break;
            }
            ret = ThreadWaitWithLastCheck();
            if (ret) {
                LOG_ERROR(-1, "ThreadWaitWithLastCheck failed");
            }
        }
    } while (1);

    ProcessorSearchingMore();

    // Update the number of processor switchover times.
    curProcessor->schedCnt++;

    // nextCJThread cannont be null.
    return nextCJThread;
}

/* Switch out the bound thread and replace it with a common thread. */
void ProcessorStopBoundCJThread(void)
{
    int error;
    struct Thread *thread;
    struct Processor *processor;
    struct Processor *nextProcessor;

    thread = ThreadGet();
    processor = static_cast<struct Processor *>(thread->processor);
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_STOP)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_STOP, -1, nullptr, 0);
    }
    // The processor and thread are unbound from each other.
    processor->thread = nullptr;
    thread->processor = nullptr;

    // Bind a new thread for processor and start it.
    ThreadAllocBindProcessor(processor, false);

    // Sleep current thread
    error = ThreadSleep(thread);
    if (error != 0) {
        LOG_ERROR(error, "ThreadSleep failed");
        return;
    }
    // After the current thread wakes up, bind the processor.
    nextProcessor = static_cast<struct Processor *>(thread->nextProcessor);
    thread->processor = nextProcessor;
    nextProcessor->thread = thread;
    thread->nextProcessor = nullptr;
}

/* Switch to the thread bound to cjthread and execute the binding cjthread. */
void ProcessorStartBoundCJThread(struct CJThread *cjthread)
{
    int error;
    struct Thread *thread;
    struct Thread *curThread = ThreadGet();
    struct Processor *processor = nullptr;
    struct Processor *curProcessor = ProcessorGet();
    struct Schedule *schedule = ScheduleGet();

    // When there is a free processor, it is used to execute the binding cjthread.
    if (schedule->schdProcessor.freeNum != 0) {
        processor = ProcessorAlloc(schedule, nullptr);
    }
    // When there is no free processor, free the current processor to execute the
    // binding cjthread.
    if (processor == nullptr) {
        processor = curProcessor;
        curThread->processor = nullptr;
        curThread->cjthread = nullptr;
    }

    thread = cjthread->boundThread;
    thread->nextProcessor = processor;
    // Wakes up the thread and executes the bound cjthread.
    error = SemaphorePost(&(thread->sem));
    if (error != 0) {
        LOG_ERROR(error, "sem post failed");
    }
    // If the current processor is released, the current thread needs to be stopped and the
    // thread is put in the free list.
    if (processor == curProcessor) {
        error = ThreadStop(schedule);
        if (error != 0) {
            LOG_ERROR(error, "thread stop failed!");
        }
    }
}

void ProcessorSchedule(void)
{
    struct CJThread *nextCJThread;
    struct Schedule *schedule;
    struct Processor *processor;
    struct Thread *thread;
    do {
        processor = ProcessorGet();
        schedule = static_cast<struct Schedule *>(processor->schedule);
        thread = processor->thread;
        if (schedule->scheduleType == SCHEDULE_DEFAULT &&
            atomic_load_explicit(&schedule->state, std::memory_order_relaxed) == SCHEDULE_EXITING) {
            ProcessorThreadExit();
        }
        // Check whether the current thread has a bound cjthread. If yes, it indicates that
        // the cjthread has been suspended and the current thread needs to be suspended.
        nextCJThread = thread->boundCJThread;
        if (nextCJThread != nullptr) {
            ProcessorStopBoundCJThread();
            // Because the binding thread is switched, preemption flag needs to be reset.
            ProtectAddrSet((uintptr_t)nextCJThread->stack.stackGuard);
            MapleRuntime::Mutator* mutator = nextCJThread->mutator;
            MapleRuntime::ThreadLocalData* tlData = MapleRuntime::ThreadLocal::GetThreadLocalData();
            tlData->SetMutator(mutator);
            mutator->PreparedToRun(tlData);
            if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_START)) {
                ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_START, -1, nullptr, 1,
                                         CJThreadGetId(static_cast<CJThreadHandle>(nextCJThread)));
            }
#ifdef CANGJIE_ASAN_SUPPORT
            // target to next cj thread, just switch
            MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(CJThreadGet(), nextCJThread);
            MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(nextCJThread);
#endif
#ifdef __OHOS__
            TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, nextCJThread->id);
#elif defined (__ANDROID__)
            MapleRuntime::CString traceInfo = MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, nextCJThread->id);
            TRACE_START(traceInfo.Str());
#endif
#ifdef __OHOS__
            if (nextCJThread->schedule->scheduleType == SCHEDULE_UI_THREAD) {
                SingleCJThreadStoreSP();
            }
#endif
            CJThreadExecute(nextCJThread, (void**)&tlData->cjthread);
            continue;
        }
        // Finds a dispatchable cjthread and switches its state to RUNNING.
        nextCJThread = ProcessorCJThreadGet();
        atomic_store_explicit(&nextCJThread->state, CJTHREAD_RUNNING, std::memory_order_relaxed);
        ProtectAddrSet((uintptr_t)nextCJThread->stack.stackGuard);
        if (nextCJThread->boundThread != nullptr) {
            ProcessorStartBoundCJThread(nextCJThread);
        } else {
            MapleRuntime::Mutator* mutator = nextCJThread->mutator;
            MapleRuntime::ThreadLocalData* tlData = MapleRuntime::ThreadLocal::GetThreadLocalData();
            tlData->SetMutator(mutator);
            mutator->PreparedToRun(tlData);
            if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_START)) {
                ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_START, -1, nullptr, 1,
                                         CJThreadGetId(static_cast<CJThreadHandle>(nextCJThread)));
            }
#ifdef CANGJIE_ASAN_SUPPORT
            // target to next cj thread, just switch
            MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(CJThreadGet(), nextCJThread);
            MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(nextCJThread);
#endif
#ifdef __OHOS__
            TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, nextCJThread->id);
#elif defined (__ANDROID__)
            MapleRuntime::CString traceInfo = MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, nextCJThread->id);
            TRACE_START(traceInfo.Str());
#endif
#ifdef __OHOS__
            if (nextCJThread->schedule->scheduleType == SCHEDULE_UI_THREAD) {
                SingleCJThreadStoreSP();
            }
#endif
            // The execution context of ProcessorWake must be in cjthread0. Do not need to
            // change the status of the current cjthread and directly switch to nextCJThread.
            CJThreadExecute(nextCJThread, (void**)&tlData->cjthread);
            return;
        }
    } while (true);
}

/* Init a processor */
int ProcessorInit(void *schedule, struct Processor *processor, unsigned int processorId)
{
    memset_s(processor, sizeof(struct Processor),
             0, sizeof(struct Processor));
    processor->processorId = processorId;
    processor->state = PROCESSOR_IDLE;
    processor->schedule = schedule;
    std::atomic_store_explicit(&processor->cjthreadNext, (CJThread *)nullptr, std::memory_order_relaxed);

    // Init processor running queue
    QueueInit(&processor->runq, PROCESSOR_QUEUE_CAPACITY);

    // Init local cjthread free list
    processor->freelist.cjthreadNum = 0;
    DulinkInit(&processor->freelist.freeList);
    PthreadSpinInit(&processor->lock);

#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanNewRaceProc(processor);
#endif

    return 0;
}

/* Free a processor */
void ProcessorFree(struct Schedule *schedule, struct Processor *processor)
{
    struct ScheduleProcessor *schdProcessor;

    schdProcessor = &(schedule->schdProcessor);

    atomic_store(&processor->state, PROCESSOR_IDLE);
    atomic_fetch_add(&schdProcessor->freeNum, 1u);
}

void ProcessorNonDefaultScheduleWake(struct Schedule *schedule)
{
    ThreadState expectedThreadState = THREAD_SLEEP;

    while (atomic_load(&schedule->thread0->state) == THREAD_PRE_SLEEP) {}
    if (atomic_load(&schedule->thread0->state) == THREAD_SLEEP) {
        if (atomic_compare_exchange_strong(&schedule->thread0->state, &expectedThreadState, THREAD_RUNNING)) {
            int error = SemaphorePost(&(schedule->thread0->sem));
            if (error != 0) {
                LOG_ERROR(error, "sem post failed");
            }
        }
    }
}

/* Wakes up a processor or randomly selects a free processor for startup. */
void ProcessorWake(struct Schedule *schedule, void *specPro)
{
    struct Processor *processor;
    unsigned int expected = 0;

    if (schedule->state == SCHEDULE_INIT || schedule->state == SCHEDULE_EXITING  ||
        schedule->state == SCHEDULE_EXITED) {
        return;
    }
    if (schedule->scheduleType != SCHEDULE_DEFAULT) {
        ProcessorNonDefaultScheduleWake(schedule);
        return;
    }

    // Check whether the processor is free.
    if (schedule->schdProcessor.freeNum == 0) {
        return;
    }
    // The search thread exists. Do not need to start a new thread.
    if (atomic_load(&schedule->schdThread.searchingNum) != 0 ||
        atomic_compare_exchange_strong(&schedule->schdThread.searchingNum, &expected, 1u) == false) {
        return;
    }

    // Allocate a new processor and set the processor status to running.
    processor = ProcessorAlloc(schedule, (struct Processor *)specPro);
    if (processor == nullptr) {
        atomic_fetch_sub(&schedule->schdThread.searchingNum, 1u);
        return;
    }
    if (processor->thread == nullptr) {
        ThreadAllocBindProcessor(processor, true);
    } else {
        // During sleep, the processor is unbound from the thread. Therefore, the processor
        // should not go to this branch.
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_INVALID, "Processor's thread is not null");
    }
}

/* Randomly allocate an idle processor. or assign a processor. */
struct Processor *ProcessorAlloc(struct Schedule *schedule, struct Processor *specPro)
{
    unsigned long idx;
    struct Processor *newProcessor;
    struct ScheduleProcessor *schdProcessor;
    ProcessorState pidle = PROCESSOR_IDLE;

    schdProcessor = &(schedule->schdProcessor);
    if (schdProcessor->freeNum == 0) {
        return nullptr;
    }

    if (specPro != nullptr && atomic_compare_exchange_strong(&specPro->state, &pidle, PROCESSOR_RUNNING)) {
        // Specify to retrieve a certain processor
        atomic_fetch_sub(&schdProcessor->freeNum, 1u);
        return specPro;
    }

    // Randomly allocate an idle processor
    for (idx = 0; idx < schdProcessor->processorNum; ++idx) {
        newProcessor = &(schdProcessor->processorGroup[idx]);
        pidle = PROCESSOR_IDLE;
        if (atomic_compare_exchange_strong(&newProcessor->state, &pidle, PROCESSOR_RUNNING)) {
            atomic_fetch_sub(&schdProcessor->freeNum, 1u);
            return newProcessor;
        }
    }
    return nullptr;
}

/* Unbind processor and thread and exit */
void ProcessorThreadExit(void)
{
    struct Thread *thread;
    const int sleepTime = PROCESSOR_RELEASE_SLEEP_TIME;

    thread = ThreadGet();

    // Return to the context of the thread_dentry thread and exit safely
    if (ScheduleGet()->schdThread.threadExit) {
#ifdef CANGJIE_ASAN_SUPPORT
        // return to ThreadEntry, switch to original thread
        MapleRuntime::Sanitizer::AsanExitCJThread(thread);
#endif
        CJThreadContextSet(&thread->context);
    } else {
        // Suspend only, do not exit, exit automatically with the process.
        ProcessorRelease();
        while (1) {
            sleep(sleepTime);
        }
    }
}

/* Retrieve the address of the register array in the current processor */
void *ProcessorGetspecific(const struct Processor *processor, int key)
{
    return processor->pArray[key];
}

void ProcessorSetspecific(struct Processor *processor, int key, void *value)
{
    processor->pArray[key] = value;
}

int ProcessorGetInfoAll(struct ProcessorInfo *processorBuf, unsigned int num)
{
    struct ScheduleProcessor *schdProcessor;
    struct ProcessorInfo *info;
    struct Processor *processor;
    unsigned int index = 0;
    unsigned int count = 0;
    struct Schedule *schedule = ScheduleGet();

    if (schedule == nullptr || processorBuf == nullptr) {
        return 0;
    }
    schdProcessor = &(schedule->schdProcessor);

    while (count < num && index < schdProcessor->processorNum) {
        processor = &(schdProcessor->processorGroup[index]);
        index++;
        if (processor->state == PROCESSOR_IDLE) {
            continue;
        }
        info = &processorBuf[count];
        info->processorId = processor->processorId;
        info->schedCnt = processor->schedCnt;
        if (processor->thread != nullptr) {
#ifdef MRT_MACOS
            info->threadId = 0;
#else
            info->threadId = static_cast<unsigned long>(processor->thread->osThread);
#endif
        } else {
            info->threadId = 0;
        }
        info->state = processor->state;
        info->runqCnt = static_cast<int>(QueueLength(&processor->runq));
        count++;
    }

    return count;
}

MRT_STATIC_INLINE void ProcessorFreelistPush(struct ProcessorFreelist *pfreelist,
                                             struct CJThread *cjthread)
{
    DulinkAdd(&cjthread->schdDulink, &pfreelist->freeList);
    pfreelist->cjthreadNum++;
}

/* The caller needs to ensure that the pfreelist is not empty */
MRT_STATIC_INLINE struct CJThread *ProcessorFreelistPop(struct ProcessorFreelist *pfreelist)
{
    struct CJThread *cjthread;
    cjthread = DULINK_ENTRY(pfreelist->freeList.next, struct CJThread, schdDulink);
    DulinkRemove(&(cjthread->schdDulink));
    pfreelist->cjthreadNum--;
    return cjthread;
}

void ProcessorFreelistPut(struct Processor *processor, struct CJThread *freeCJThread)
{
    struct Schedule *schedule = static_cast<struct Schedule *>(processor->schedule);
    struct ScheduleGfreeList *gfreelist;
    struct ProcessorFreelist *pfreelist = &processor->freelist;

    if (schedule->state == SCHEDULE_WAITING || schedule->state == SCHEDULE_SUSPENDING) {
        CJThreadFree(freeCJThread, false);
        return;
    }
    PthreadSpinLock(&processor->lock);

    ProcessorFreelistPush(pfreelist, freeCJThread);

    if (pfreelist->cjthreadNum >= PROCESSOR_FREE_LIST_CAPACITY) {
        gfreelist = &schedule->schdCJThread.gfreelist;
        pthread_mutex_lock(&gfreelist->gfreeLock);
        unsigned int count = PROCESSOR_FREE_LIST_HALF_CAPACITY;

        DulinkMove(&gfreelist->gfreeList, &pfreelist->freeList, static_cast<int>(count));

        gfreelist->freeCJThreadNum += count;
        pfreelist->cjthreadNum -= count;

        pthread_mutex_unlock(&gfreelist->gfreeLock);
    }

    PthreadSpinUnlock(&processor->lock);
}

struct CJThread *ProcessorFreelistGet(struct Processor *processor)
{
    struct CJThread *cjthread = nullptr;
    struct Schedule *schedule = static_cast<struct Schedule *>(processor->schedule);
    struct ScheduleGfreeList *gfreelist = &schedule->schdCJThread.gfreelist;
    struct ProcessorFreelist *pfreelist = &processor->freelist;
    unsigned int count;
    unsigned int rest = 0;

    if (pfreelist->cjthreadNum == 0 && gfreelist->freeCJThreadNum == 0) {
        return nullptr;
    }

    PthreadSpinLock(&processor->lock);

    if (pfreelist->cjthreadNum == 0 && gfreelist->freeCJThreadNum != 0) {
        pthread_mutex_lock(&gfreelist->gfreeLock);
        count = gfreelist->freeCJThreadNum;
        // Local/global resource pools are both empty, return directly
        if (count == 0) {
            pthread_mutex_unlock(&gfreelist->gfreeLock);
            PthreadSpinUnlock(&processor->lock);
            return nullptr;
        }
        if (count > PROCESSOR_FREE_LIST_HALF_CAPACITY) {
            count = PROCESSOR_FREE_LIST_HALF_CAPACITY;
            rest = gfreelist->freeCJThreadNum - count;
        }
        if (count < rest) {
            DulinkMove(&pfreelist->freeList, &gfreelist->gfreeList, static_cast<int>(count));
        } else {
            DulinkMove(&pfreelist->freeList, &gfreelist->gfreeList, -static_cast<int>(rest));
        }
        gfreelist->freeCJThreadNum -= count;
        pthread_mutex_unlock(&gfreelist->gfreeLock);
        pfreelist->cjthreadNum += count;
    }
    if (pfreelist->cjthreadNum != 0) {
        cjthread = ProcessorFreelistPop(pfreelist);
    }
    PthreadSpinUnlock(&processor->lock);
    return cjthread;
}

/* Atomic method to obtain the ID of the processor, using a unified global variable to obtain
 * the processorId under multiple schedulers. */
unsigned int ProcessorNewId(void)
{
    return atomic_fetch_add(&g_scheduleManager.processorIdGen, 1u);
}

unsigned int ProcessorId(void)
{
    struct CJThread *cjthread = CJThreadGet();
    struct Thread *thread;
    struct Processor *processor;
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "cjthread is nullptr");
        return 0;
    }
    thread = cjthread->thread;
    if (thread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "thread is nullptr");
        return 0;
    }
    processor = static_cast<struct Processor *>(thread->processor);
    if (processor == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "processor is nullptr");
        return 0;
    }
    return processor->processorId;
}

#if defined(CANGJIE_TSAN_SUPPORT)

void* ProcessorGetHandle(void)
{
    return ProcessorGetWithCheck();
}

#endif

bool ProcessorCanSpin(void)
{
    struct CJThread *cjthread = CJThreadGet();
    struct Schedule *schedule;
    struct Thread *thread;
    struct Processor *processor;

    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "cjthread is nullptr");
        return false;
    }
    schedule = cjthread->schedule;
    unsigned int totalProcessorNum = schedule->schdProcessor.processorNum;
    unsigned int freeProcessorNum =
        atomic_load(&schedule->schdProcessor.freeNum) + atomic_load(&schedule->schdThread.searchingNum);
    if (totalProcessorNum <= 1 || // Single processor shuold not spin
        totalProcessorNum - 1 <= freeProcessorNum) { // No other running processors
        return false;
    }

    thread = cjthread->thread;
    if (thread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "thread is nullptr");
        return false;
    }
    processor = static_cast<struct Processor *>(thread->processor);
    if (processor == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_GET_FAILED, "processor is nullptr");
        return false;
    }
    // If the current processor has other cjthreads to run,
    // there is no need to spin.
    if (QueueLength(&processor->runq) != 0) {
        return false;
    }
    return true;
}

#ifdef __cplusplus
}
#endif