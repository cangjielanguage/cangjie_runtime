// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <pthread.h>
#include <unistd.h>
#include "schedule_impl.h"
#include "schdpoll.h"
#include "basetime.h"
#include "log.h"
#include "schmon.h"

#if defined (MRT_LINUX)
#include <malloc.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Cyclic inspection interval 10ms */
const int CYCLE_TIME = 10000;

const int PREEMPT_TIME = 10000000;

/* Resource pools are cleared every 5 seconds. */
const unsigned long long POOL_CLEAN_TIME = 5000000000ULL;

/* The preemption check is performed every 10 ms. */
const int PROCESSORS_CHECK_TIME = 10000;

/* Preempts the processor in the syscall state.
 * This function affects the thread bound to the processor. Therefore, the scheduling
 * framework of a single processor does not execute this logic.
 */
void SchmonPreemptSyscall(struct Processor *processor)
{
    struct Schedule *schedule = ScheduleGet();
    ProcessorState processorSyscall = PROCESSOR_SYSCALL;

    if (schedule->schdProcessor.freeNum > 0) {
        return;
    }

    if (atomic_compare_exchange_strong(&processor->state, &processorSyscall, PROCESSOR_RUNNING)) {
        ThreadAllocBindProcessor(processor, false);
        schedule->schdCJThread.preemptSyscallCnt++;
    }
}

/* Preempts the processor in the running state. */
void SchmonPreemptRunning(struct Processor *processor)
{
    struct Thread *thread;
    uintptr_t *preemptFlag;
    SchdCJThreadHookFunc func;
    uintptr_t request;

    // The processor is not initialized.
    thread = processor->thread;
    if (thread == nullptr) {
        return;
    }

    // The thread is not initialized.
    preemptFlag = thread->preemptFlag;
    if (preemptFlag == nullptr) {
        return;
    }

    // Set the preemption flag.
    atomic_store(reinterpret_cast<std::atomic<uintptr_t> *>(preemptFlag), PREEMPT_DO_FLAG);

    // Start preemption request.
    func = g_scheduleManager.schdCJThreadHook[SCHD_PREEMPT_REQ];
    if (func != nullptr && thread->preemptRequest != nullptr) {
        request = func();
        atomic_store(reinterpret_cast<std::atomic<uintptr_t> *>(thread->preemptRequest), request);
    }
}

// Check processor whether has ready cjthread.
bool FastSchmonProcessorPreemptCheck(struct Processor *processor)
{
    if (atomic_load_explicit(&processor->state, std::memory_order_relaxed) == PROCESSOR_IDLE) {
        return false;
    }
    if (processor->cjthreadNext.load() != nullptr) {
        return true;
    }
    if (QueueLength(&processor->runq) != 0) {
        return true;
    }
    return false;
}

/* Check whether a processor requires preemption. */
void SchmonProcessorPreemptCheck(struct Processor *processor, unsigned long long now,  struct Schedule *schedule)
{
    unsigned long schedcnt;
    int state;

    if (atomic_load_explicit(&processor->state, std::memory_order_relaxed) == PROCESSOR_IDLE) {
        return;
    }

    schedcnt = processor->schedCnt;
    if (processor->obRecord.lastSchedCnt == schedcnt) {
        int pTime = schedule->schdCJThread.cjthreadNum.load() != 0 || FastSchmonProcessorPreemptCheck(processor) ?
            PREEMPT_TIME : (PREEMPT_TIME * 100); // 100: When there is few cjthreads waiting, then change preempt time.
        if (processor->obRecord.lastTime + pTime < now) {
            // If the thread is executed on the same cjthread for more than 10 ms, preemption is performed.
            state = atomic_load(&processor->state);
            if (state == PROCESSOR_SYSCALL && ScheduleGet()->scheduleType == SCHEDULE_DEFAULT) {
                SchmonPreemptSyscall(processor);
            } else if (state == PROCESSOR_RUNNING) {
                SchmonPreemptRunning(processor);
            }
        }
    } else {
        processor->obRecord.lastSchedCnt = schedcnt;
        processor->obRecord.lastTime = now;
    }
}

/* 1.Query the global timer. If a timer expires, wake up the corresponding processor and
 * modify the preemption flag. The timer processing is classified into two scenarios:
 * （1）A processor sleeps. As a result, the timer on the processor expires and cannot be
 *     triggered. In this case, the processor is woken up.
 * （2）A processor is occupied by a cjthread and cannot be released or is busy. As a result,
 *     the timer on the processor cannot be triggered when the timer expires. In this case,
 *     an idle cjthread is randomly woken up to steal the timer.
 * 2.Global preemption check, preempting cjthreads that take too long to execute on the
 * same cjthread.
 **/
void SchmonCheckAllprocessors(unsigned long long now)
{
    static unsigned long long lastTime = 0;
    struct Processor *processor;
    unsigned long i;
    SchmonCheckFunc timerCheckFunc;
    struct Dulink *scheduleNode;
    struct Schedule *schedule;
    if (lastTime + PROCESSORS_CHECK_TIME > now) {
        return;
    }

    lastTime = now;
    timerCheckFunc = g_scheduleManager.schmon.checkFunc[SCHMON_TIMER_HOOK];
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        /* if schedule is from foreign thread, do not check preempt */
        if (schedule->scheduleType == SCHEDULE_FOREIGN_THREAD) {
            if (timerCheckFunc != nullptr) {
                timerCheckFunc(&schedule->schdProcessor.processorGroup[0], now);
            }
            continue;
        }
        if (schedule->scheduleType == SCHEDULE_UI_THREAD &&
            g_scheduleManager.postTaskFunc != nullptr) {
            processor = &schedule->schdProcessor.processorGroup[0];

            // if schedule is single thread type, do not need to check timer,
            // but should trigger timer by processor.
            ProcessorCheckFunc checkFunc;
            unsigned long long nowTime = 0;
            checkFunc = g_scheduleManager.check[PROCESSOR_TIMER_HOOK];
            if (checkFunc != nullptr) {
                checkFunc(processor, &nowTime, nullptr);
            }
            continue;
        }
        for (i = 0; i < schedule->schdProcessor.processorNum; i++) {
            processor = &schedule->schdProcessor.processorGroup[i];
            // Skip preempt while the running cjthread is inside exclusiveScope.
            // TimerSchmonCheck wakes cjthread->thread when a timer is due (park sem).
            struct Thread *thread = processor->thread;
            struct CJThread *running = (thread != nullptr)
                ? static_cast<struct CJThread *>(thread->cjthread) : nullptr;
            if (running == nullptr || running->exclusiveScopeCnt == 0) {
                SchmonProcessorPreemptCheck(processor, now, schedule);
            }
            if (timerCheckFunc != nullptr) {
                timerCheckFunc(processor, now);
            }
        }
    }
}

void SchmonRemovelistClear(struct Dulink *removeList)
{
    struct CJThread *waitRemoveCJThread;
    while (!DulinkIsEmpty(removeList)) {
        waitRemoveCJThread = DULINK_ENTRY(removeList->next, struct CJThread, schdDulink);
        DulinkRemove(&(waitRemoveCJThread->schdDulink));
        CJThreadFree(waitRemoveCJThread, false);
    }
}

/* Clean up cjthread resource pool */
void SchmonCJThreadPoolClean(unsigned long long now)
{
    static unsigned long long lastTime = 0;
    unsigned long schdCJThreadNum;
    unsigned long length;
    struct ScheduleGfreeList *gfreelist;
    struct Dulink removeList;
    const int multiple = 2;
    unsigned int i;
    struct ScheduleProcessor *schdProcessor;
    struct Processor *processor;
    struct Dulink *scheduleNode;
    struct Schedule *schedule;

    if (lastTime + POOL_CLEAN_TIME > now) {
        return;
    }
    /* Not triggered for the first access */
    if (lastTime == 0) {
        lastTime = now;
        return;
    }
    lastTime = now;

    DulinkInit(&removeList);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        // Obtain some cjthreads from the global queue and release them.
        gfreelist = &schedule->schdCJThread.gfreelist;
        pthread_mutex_lock(&gfreelist->gfreeLock);
        schdCJThreadNum = schedule->schdCJThread.num;

        // If the number of cjthreads in the global free list is greater than twice the
        // number of cjthreads to be run, clear the global resource pool.
        if (gfreelist->freeCJThreadNum && gfreelist->freeCJThreadNum >= schdCJThreadNum * multiple) {
            DulinkMove(&removeList, &(gfreelist->gfreeList), -schdCJThreadNum);
            gfreelist->freeCJThreadNum = schdCJThreadNum;
        }
        pthread_mutex_unlock(&gfreelist->gfreeLock);

        // If the number of cjthreads in the free list of a processor is greater than twice the
        // number of cjthreads to be run locally, clear the free list.
        schdProcessor = &(schedule->schdProcessor);
        for (i = 0; i < schdProcessor->processorNum; i++) {
            processor = &(schdProcessor->processorGroup[i]);
            PthreadSpinLock(&processor->lock);
            length = QueueLength(&processor->runq);
            if (processor->freelist.cjthreadNum && processor->freelist.cjthreadNum >= length * multiple) {
                DulinkMove(&removeList, &processor->freelist.freeList, -length);
                processor->freelist.cjthreadNum = length;
            }
            PthreadSpinUnlock(&processor->lock);
        }
    }
    SchmonRemovelistClear(&removeList);
    // After the resource pool is cleared, the actual physical memory need to be released.
    // Only the Linux platform is supported.
#if defined(MRT_LINUX) && !defined (__OHOS__) && !defined (__ANDROID__)
    (void)malloc_trim(0);
#endif
}

void SchmonCycle(void)
{
    int num;
    unsigned long long now;
    unsigned int delay = CYCLE_TIME;
    struct Dulink *scheduleNode;
    struct Schedule *schedule;
    CJThreadHandle buf[SCHDPOLL_ACQUIRE_MAX_NUM];
    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        // Schmon needs to sleep or wait for 10ms in SchdpollAcquire when checking the default
        // scheduler, and holding a lock at this time can seriously affect performance.
        // Therefore, no lock is held when checking the default scheduler. When schmon does not
        // exit, the default scheduler must exist in allScheduleList, so there is no problem of
        // waiting for schedule changes during the waiting period. And non default schedulers
        // do not set a timeout when executing SchdpollAcquire, otherwise it will affect the
        // network task performance of the default scheduler.
        if (schedule->scheduleType == SCHEDULE_DEFAULT) {
            pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
        }
#ifdef MRT_WINDOWS
        if (schedule->scheduleType == SCHEDULE_DEFAULT) {
            usleep(delay);
        }
        if (schedule->netpoll.npfd != nullptr) {
            num = SchdpollAcquire(schedule, buf, SCHDPOLL_ACQUIRE_MAX_NUM, 0);
            if (num > 0) {
                CJThreadAddBatch(buf, num);
            }
        }
#else
        /* Waiting time of schmon waits for a network event is 10ms */
        const int NETPOLL_WAIT_TIME = 10;
        if (schedule->netpoll.npfd != nullptr && schedule->scheduleType == SCHEDULE_DEFAULT) {
            num = SchdpollAcquire(schedule, buf, SCHDPOLL_ACQUIRE_MAX_NUM, NETPOLL_WAIT_TIME);
            if (num > 0) {
                CJThreadAddBatch(buf, num);
            }
        } else if (schedule->netpoll.npfd == nullptr && schedule->scheduleType == SCHEDULE_DEFAULT) {
            usleep(delay);
        } else if (schedule->netpoll.npfd != nullptr && schedule->scheduleType != SCHEDULE_DEFAULT) {
            num = SchdpollAcquire(schedule, buf, SCHDPOLL_ACQUIRE_MAX_NUM, 0);
            if (num > 0) {
                CJThreadAddBatch(buf, num);
            }
        }
#endif
        if (schedule->scheduleType == SCHEDULE_DEFAULT) {
            pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
        }
    }
    now = CurrentNanotimeGet();
    // Timer check.
    SchmonCheckAllprocessors(now);
    SchmonCJThreadPoolClean(now);
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
}

/* Schedule monitor thread entry function */
void *SchmonEntry(ScheduleHandle handle)
{
    Schedule* schedule;

    schedule = static_cast<Schedule*>(handle);
    if (schedule == nullptr) {
        return nullptr;
    }
    ScheduleSet(schedule);

#ifdef MRT_LINUX
    prctl(PR_SET_NAME, "schmon");
#elif defined (MRT_MACOS)
    pthread_setname_np("schmon");
#endif

    while (1) {
        if (schedule->state == SCHEDULE_EXITING) {
            return nullptr;
        }
        SchmonCycle();
    }
}

int SchmonStart(ScheduleHandle handle)
{
    pthread_attr_t pthreadAttr;
    Schedule* schedule;
    int error;

    schedule = static_cast<Schedule*>(handle);
    if (schedule == nullptr) {
        return ERRNO_SCHMON_ARG_INVALID;
    }

    error = pthread_attr_init(&pthreadAttr);
    if (error) {
        LOG_ERROR(error, "pthread_attr_init failed");
        return error;
    }
    pthread_attr_setdetachstate(&pthreadAttr, PTHREAD_CREATE_JOINABLE);

    error = pthread_create(&g_scheduleManager.schmon.schmonId, &pthreadAttr, SchmonEntry, schedule);
    if (error != 0) {
        LOG_ERROR(ERRNO_SCHD_THREAD_CREATE_FAILED, "pthread_create failed");
        return error;
    }

    return 0;
}

#ifdef __cplusplus
}
#endif
