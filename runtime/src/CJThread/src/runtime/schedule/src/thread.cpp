// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <sched.h>
#include <unistd.h>
#include "schedule_impl.h"
#include "log.h"
#if defined(CANGJIE_ASAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

void ThreadWakeIfSleeping(struct Thread *thread)
{
    if (thread == nullptr) {
        return;
    }
    ThreadState expected = THREAD_SLEEP;
    while (atomic_load(&thread->state) == THREAD_PRE_SLEEP) {}
    if (atomic_load(&thread->state) == THREAD_SLEEP) {
        if (atomic_compare_exchange_strong(&thread->state, &expected, THREAD_RUNNING)) {
            int error = SemaphorePost(&(thread->sem));
            if (error != 0) {
                LOG_ERROR(error, "sem post failed");
            }
        }
    }
}

/*
 * sleep the thread
 */
int ThreadSleep(struct Thread *thread)
{
    struct Schedule *schedule = ScheduleGet();
    int error;
    do {
        // If an interrupt is generated during wait, continue to wait.
        error = SemaphoreWaitNoIntr(&(thread->sem));
        if (error != 0) {
            LOG_ERROR(error, "sem_wait failed %d", error);
            return error;
        }

        // During wakeup, it checks whether the thread needs to exit. This function is used to
        // wake up the thread to restore the thread context and return automatically exits.
        if (schedule->state == SCHEDULE_EXITING || schedule->state == SCHEDULE_EXITED) {
            ProcessorThreadExit();
        }
        if (thread->processor != nullptr) {
            ScheduleTraceEvent(TRACE_EV_PROC_WAKE, -1, nullptr, 1, static_cast<unsigned long long>(thread->tid));
            return 0;
        }
        if (thread->boundCJThread != nullptr && thread->nextProcessor != nullptr) {
            // When the thread has a bound cjthread, bind a processor after sleep ends.
            ScheduleTraceEvent(TRACE_EV_PROC_WAKE, -1, nullptr, 1, static_cast<unsigned long long>(thread->tid));
            return 0;
        }
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_INVALID, "processor is null");
    } while (1);

    return 0;
}

/* Pointer to the preemption bit of the current thread structure. */
void ThreadPreemptFlagInit(void)
{
    struct Thread *thread = ThreadGet();
    PreemptFlagSet(0);
    thread->preemptFlag = PreemptFlagAddr();
    thread->preemptRequest = PreemptRequestAddr();
}

void *ThreadEntry(void *arg)
{
    struct Thread *thread;
    struct CJThread *cjthread0;

#ifdef MRT_MACOS
    pthread_setname_np("schd-worker");
#endif

#ifdef MRT_LINUX
    prctl(PR_SET_NAME, "schd-worker");
#endif

    // Before the semaphore is received, thread->processor is NULL. Do not access the semaphore.
    thread = (struct Thread *)arg;
    // This function must be invoked by CJThread, so set "IsCJProcessor" flag be true in ThreadLocalData
    MapleRuntime::ThreadLocal::SetCJProcessorFlag(true);
    // Waiting for semaphore.
    SemaphoreWait(&thread->sem);

    cjthread0 = static_cast<struct CJThread *>(thread->cjthread0);
    if (cjthread0 == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD0_INVALID, "thread cjthread0 is null");
        SemaphoreDestroy(&thread->sem);
        free(thread);
        return nullptr;
    }
    ScheduleSet(cjthread0->schedule);
    if (thread->processor == nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_INVALID, "thread processor is null");
        SemaphoreDestroy(&thread->sem);
        CJThreadMemFree(static_cast<struct CJThread *>(thread->cjthread0));
        free(thread);
        return nullptr;
    }
    cjthread0->thread = thread;

    thread->tid = GetSystemThreadId();

    // Initialize the thread and set the cjthread running context.
    CJThreadSet(cjthread0);
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_WAKE)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_WAKE, -1, nullptr, 1, static_cast<unsigned long long>(thread->tid));
    }
    // Preemption flag initialization.
    ThreadPreemptFlagInit();

    CJThreadContextGet(&thread->context);

    if (ScheduleGet()->state == SCHEDULE_RUNNING || ScheduleGet()->state == SCHEDULE_SUSPENDING) {
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEnterCJThread(ThreadGet());
#endif
        ProcessorSchedule();
    }

    // A thread may enter the exit process without any scheduling.
    // In this case, need to unbind the thread and exit.
    ProcessorRelease();

    return nullptr;
}

/* Create a new os thread */
int ThreadOsnew(pthread_t *thread, const char *name, size_t stackSize,
                void *(*startRoutine)(void *), void *arg)
{
    int error;
    pthread_attr_t pthreadAttr;

    error = pthread_attr_init(&pthreadAttr);
    if (error) {
        LOG_ERROR(error, "pthread_attr_init failed");
        return error;
    }
    pthread_attr_setdetachstate(&pthreadAttr, PTHREAD_CREATE_JOINABLE);
    error = pthread_attr_setstacksize(&pthreadAttr, stackSize);
    if (error != 0) {
        LOG_ERROR(ERRNO_SCHD_ARG_INVALID, "thstacksize too small ,or not a multiple of page size");
        pthread_attr_setstacksize(&pthreadAttr, THSTACK_SIZE_DEFAULT);
    }

    error = pthread_create(thread, &pthreadAttr, startRoutine, arg);
    if (error != 0) {
        LOG_ERROR(ERRNO_SCHD_THREAD_CREATE_FAILED, "pthread_create failed");
        return error;
    }
    (void)name;

    return error;
}

/* Create a thread */
struct Thread *ThreadCreate(void *schedule)
{
    int error;
    size_t stackSize;
    struct Thread *newThread;
    struct CJThread *cjthread0;
    struct Schedule *curSchedule = (struct Schedule *)schedule;
    struct ArgAttr argAttr;
    struct StackAttr stackAttr;

    argAttr.argStart = nullptr;
    argAttr.argSize = 0;
    stackAttr.stackSizeAlign = curSchedule->schdCJThread.stackSize;
    stackAttr.stackGrow = false;
    newThread = (struct Thread *)malloc(sizeof(struct Thread));
    if (newThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_THREAD_ALLOC_FAILED, "thread alloc failed");
        return nullptr;
    }
    memset_s(newThread, sizeof(struct Thread), 0, sizeof(struct Thread));

    // Allocate an idle cjthread0 control block
    cjthread0 = CJThreadAlloc(curSchedule, &argAttr, &stackAttr, NO_BUF);
    if (cjthread0 == nullptr) {
        LOG_ERROR(ERRNO_SCHD_THREAD_CJTHREAD0_ALLOC_FAILED, "thread cjthread0 alloc failed");
        free(newThread);
        return nullptr;
    }
    CJThread0Make(cjthread0);

    // Initialize thread-related fields.
    DulinkInit(&newThread->link2schd);
    newThread->state = THREAD_INIT;
    newThread->boundCJThread = nullptr;
    newThread->nextProcessor = nullptr;
    newThread->cjthread0 = cjthread0;
    SemaphoreInit(&newThread->sem, 0, 0);

    // Invoke the interface of the operating system to create a os thread
    stackSize = curSchedule->schdThread.stackSize;
    error = ThreadOsnew(&(newThread->osThread), "schd-worker", stackSize,
                        ThreadEntry, newThread);
    if (error != 0) {
        SemaphoreDestroy(&newThread->sem);
        CJThreadMemFree(cjthread0);
        free(newThread);
        return nullptr;
    }
    DulinkInit(&newThread->allThreadDulink);
    ScheduleAllThreadListAdd(newThread, curSchedule);

    return newThread;
}

/* Search for free threads from the thread pool. */
struct Thread *ThreadFromSchedule(struct Schedule *schedule)
{
    struct ScheduleThread *threadPool;
    struct Thread *thread;
    struct Dulink *runq;
    int error;

    threadPool = &schedule->schdThread;
    if (threadPool->freeNum == 0) {
        return nullptr;
    }

    error = pthread_mutex_lock(&threadPool->mutex);
    if (error != 0) {
        LOG_ERROR(error, "pthread_mutex_lock failed");
    }
    if (threadPool->freeNum == 0) {
        pthread_mutex_unlock(&threadPool->mutex);
        return nullptr;
    }

    runq = &threadPool->threadHead;
    thread = DULINK_ENTRY(runq->next, struct Thread, link2schd);
    DulinkRemove(&(thread->link2schd));
    threadPool->freeNum--;

    pthread_mutex_unlock(&threadPool->mutex);

    return thread;
}

/* Allocate a free thread. */
struct Thread *ThreadAlloc(struct Schedule *schedule)
{
    // Obtain a free thread from the schedule. If the obtaining fails, create a new thread.
    struct Thread *thread = ThreadFromSchedule(schedule);
    if (thread == nullptr) {
        thread = ThreadCreate(schedule);
    }

    return thread;
}

/* Allocate a thread, bind it to the specified processor, and start the thread. */
void ThreadAllocBindProcessor(void *processor, bool searching)
{
    struct Thread *thread;
    struct Schedule *schedule = static_cast<struct Schedule *>(static_cast<struct Processor *>(processor)->schedule);
    int error;

    thread = ThreadAlloc(schedule);
    if (thread == nullptr) {
        ProcessorFree(schedule, (struct Processor *)processor);
        return;
    }
    thread->processor = processor;
    thread->isSearching = searching;
    ((struct Processor *)processor)->thread = thread;

    // Wakes up the thread to execute related tasks.
    error = SemaphorePost(&(thread->sem));
    if (error) {
        LOG_ERROR(error, "sem post failed");
    }
}

/* Stop the current thread and put the thread into the free list. */
int ThreadStop(ScheduleHandle handle)
{
    struct Thread *thread;
    struct ScheduleThread *schdThread;
    struct Schedule *schedule = (struct Schedule *)handle;
    int error;

    // When a thread stops, it cannot be bound to a processor.
    thread = ThreadGet();
    if (thread->processor != nullptr) {
        LOG_ERROR(ERRNO_SCHD_PROCESSOR_NOT_NULL, "when thread stop, thread->processor is not null");
        return ERRNO_SCHD_PROCESSOR_NOT_NULL;
    }

    // Put free thread into the free list of the scheduler.
    thread->state = THREAD_INIT;
    schdThread = &(schedule->schdThread);
    error = pthread_mutex_lock(&(schdThread->mutex));
    if (error != 0) {
        LOG_ERROR(error, "pthread_mutex_lock failed");
    }
    DulinkAdd(&(thread->link2schd), &(schdThread->threadHead));
    schdThread->freeNum++;
    pthread_mutex_unlock(&(schdThread->mutex));

    // sleep thread
    error = ThreadSleep(thread);
    if (error != 0) {
        LOG_ERROR(error, "ThreadSleep failed");
        return error;
    }

    return 0;
}

/* Obtains a processor from the current thread. */
void *ThreadBindProcessor(void *processor)
{
    struct Processor *allocProcessor;
    struct Thread *thread = ThreadGet();

    allocProcessor = ProcessorAlloc(ScheduleGet(), static_cast<struct Processor *>(processor));
    if (allocProcessor == nullptr) {
        return nullptr;
    }
    thread->processor = allocProcessor;
    allocProcessor->thread = thread;
    return allocProcessor;
}

/* The non-default scheduler last checks whether a cjthread exists in the scheduler. */
int ThreadWaitWithLastCheck(void)
{
    int ret;
    struct Thread *thread = ThreadGet();
    struct Schedule *schedule = ScheduleGet();
    thread->state = THREAD_PRE_SLEEP;
    if (ScheduleAnyCJThread(schedule) || schedule->state == SCHEDULE_EXITING || schedule->state == SCHEDULE_EXITED) {
        thread->state = THREAD_RUNNING;
        return 0;
    }
    if (schedule->noWaitAttr.nowait) {
        // When the schedule is executed in nowait mode, the thread is still executing other logic
        // when the thread exits. Do not change the status to Sleep. Otherwise, running
        // ProcessorWake in the schmon or other places may cause problems.
        thread->state = THREAD_RUNNING;
        auto *targetThread = ThreadGet();
#ifdef CANGJIE_ASAN_SUPPORT
        // return to ThreadEntry, switch to original thread
        MapleRuntime::Sanitizer::AsanExitCJThread(thread);
#endif
        CJThreadContextSet(&targetThread->context);
    }
    thread->state = THREAD_SLEEP;
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_STOP)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_STOP, -1, nullptr, 0);
    }
    ret = SemaphoreWait(&(thread->sem));
    if (ret != 0) {
        LOG_ERROR(ret, "sem_wait failed");
    }
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_WAKE)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_WAKE, -1, nullptr, 1, static_cast<unsigned long long>(thread->tid));
    }
    thread->state = THREAD_RUNNING;
    return 0;
}

#ifdef __cplusplus
}
#endif