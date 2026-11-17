// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_SCHEDULE_IMPL_H
#define MRT_SCHEDULE_IMPL_H

#include <atomic>
#include <stdbool.h>
#include <unistd.h>
#include "macro_def.h"
#include "queue.h"
#include "list.h"
#include "schedule.h"
#include "thread.h"
#include "cjthread.h"
#include "processor.h"
#include "netpoll.h"
#include "threadlocal.h"
#include "external.h"
#include "trace_impl.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

#define THSTACK_SIZE_DEFAULT (128*1024)
#define COSTACK_SIZE_DEFAULT (64*1024)
#define COARGS_SIZE_MAX (32)
#define PROCESSOR_NUM_DEFAULT (16)
#define PROCESSOR_NUM_SINGLE_THREAD (1)

#define PROCESSOR_FREE_LIST_CAPACITY (128)
#define PROCESSOR_FREE_LIST_HALF_CAPACITY (PROCESSOR_FREE_LIST_CAPACITY / 2)
#define STACK_DEFAULT_REVERSED (4096)

#define LIBCANGJIE_CJTHREAD_TRACE "libcangjie-trace"

/**
 * @brief Schedule state
 */
enum ScheduleState {
    SCHEDULE_INIT,
    SCHEDULE_RUNNING,
    SCHEDULE_EXITING,
    SCHEDULE_SUSPENDING,
    SCHEDULE_WAITING,
    SCHEDULE_EXITED,
};

/**
 * @brief Schedule global free list
 */
struct ScheduleGfreeList {
    pthread_mutex_t gfreeLock;          /* global free list lock */
    struct Dulink gfreeList;            /* global free list */
    unsigned int freeCJThreadNum;       /* cjthread num of global free list */
};

/**
 * @brief Dispatcher initialization exception handling branch type
 */
enum ScheduleFinishPhase {
    FINI_THREAD0,
    FINI_CJTHREAD,
    FINI_THREAD,
    FINI_PROCESSOR
};

/**
 * @brief Structure of the scheduler cjthread attribute
 */
struct ScheduleCJThread {
    std::atomic<unsigned long long> cjthreadNum;   /* Number of all existing cjthreads, used
                                                    * only for the cjthreadMax decision. */
    std::atomic<unsigned long long> preemptCnt;          /* number of preemption times */
    std::atomic<unsigned long long> preemptSyscallCnt;   /* Number of syscall preemption times */
    size_t stackSize;                         /* default stack size */
    bool stackProtect;                        /* whether to enable cjthread stack protection */
    bool stackGrow;                           /* whether to enable cjthread stack scaling */

    pthread_mutex_t mutex;                    /* locks that protect this variable */
    unsigned long long num;                   /* total number of nodes in runq */
    struct Dulink runq;                       /* cjthread to run(global queue) */
    struct ScheduleGfreeList gfreelist;       /* global cjthread free list */
};

/**
 * @brief Structure of the scheduler thread attribute
 */
struct ScheduleThread {
    pthread_mutex_t mutex;                      /* lock of threadHead */
    size_t stackSize;                           /* default stack size */
    unsigned int freeNum;                       /* free thread number */
    struct Dulink threadHead;                   /* free thread list */
    bool threadExit;                            /* thread exit flag */
    std::atomic<unsigned int> searchingNum;     /* searching thread number */
    pthread_mutex_t allthreadMutex;             /* lock of allThreadDulink */
    struct Dulink allThreadList;                /* all thread list */
};

/**
 * @brief Processor Trigger Timer Function Type
 */
typedef int (*ProcessorCheckFunc)(struct Processor *processor, unsigned long long *now, bool *run);

/**
 * @brief Processor Check Timer Function Type
 */
typedef bool (*ProcessorCheckExistenceFunc)(void *processor);

/**
 * @brief The processor checks the type of the executable timer function
 */
typedef bool (*ProcessorCheckReadyFunc)(struct Processor *processor);

/**
 * @brief Type of the function for the processor to notify the timer to exit
 */
typedef int (*ProcessorExitFunc)(void *processor);

/* Number of checks run in processor */
#define PROCESSOR_HOOK_NUM 2
/* The timer hook is placed at index 0 */
#define PROCESSOR_TIMER_HOOK 0

/**
 * @brief Structure of the scheduler processor attribute
 */
struct ScheduleProcessor {
    unsigned int processorNum;                         /* processor number */
    std::atomic<unsigned int> freeNum;                      /* free processor number */
    struct Processor *processorGroup;                  /* processor group */
};

/**
 * @brief Function pointer defined for the timer hook
 */
typedef int (*SchmonCheckFunc)(void *processor, unsigned long long now);

/* Number of checks running in the monitoring thread */
#define SCHMON_HOOK_NUM 2
/* The timer hook is placed at index 0 */
#define SCHMON_TIMER_HOOK 0

/**
 * @brief Schmon
 */
struct Schmon {
    pthread_t schmonId;                                 /* thread tid */
    SchmonCheckFunc checkFunc[SCHMON_HOOK_NUM];         /* timer hooks */
};

/* nepoll */
struct Netpoll {
    pthread_mutex_t pollMutex;          /* locks that prevent concurrent epoll operations */
    NetpollFd npfd;                     /* fd used by cjthread asynchronous I/O */
    struct CJthreadSpinLock closingLock;     /* lock of closingPd */
    struct SchdpollDesc *closingPd;     /* pd to be closed is cleared after each acquire. */
};

/**
 * @brief Scheduler attribute structure
 */
struct ScheduleAttrInner {
    size_t thstackSize;                /* default thread stack size */
    size_t costackSize;                /* default cjthread stack size */
    bool stackProtect;                 /* whether to enable cjthread stack protection */
    bool stackGrow;                    /* whether to enable cjthread stack scaling */
    unsigned int processorNum;         /* processor number */
};

/**
 * @brief ScheduleManager
 */
struct ScheduleManager {
    bool initFlag;                                             /* init flag */
    struct Schedule *defaultSchedule;                          /* default scheduler handle */
    std::atomic<unsigned long long> cjthreadIdGen;             /* cjthread id generator. 0 is for cjthread0 */
    std::atomic<unsigned int> processorIdGen;                  /* processor id generator */
    struct Dulink allScheduleList;                             /* all schedule list */
    pthread_mutex_t allScheduleListLock;                       /* lock of allScheduleListLock */
    pthread_mutex_t allCJThreadListLock;                       /* lock of allCJThreadListLock */
    struct Dulink allCJThreadList;                             /* all cjthread list */
    pthread_mutex_t cjSingleModeThreadListLock;                /* lock of cjSingleModeThreadList */
    struct Dulink cjSingleModeThreadList;                      /* All cj single mode thread list */
    PostTaskFunc postTaskFunc;                                 /* Post Task function for event handler system */
    /* Check whether has higher priority task in event handler system */
    HasHigherPriorityTaskFunc hasHigherPriorityTaskFunc;
    /* Update arkts stack info when single model cjthread stack changed */
    UpdateStackInfoFunc updateStackInfoFunc;
    /* Register the arkVM that be created by UI Thread */
    unsigned long long arkVM = 0;

    struct Schmon schmon;
    ProcessorCheckFunc check[PROCESSOR_HOOK_NUM];               /* check timer */
    ProcessorExitFunc exit[PROCESSOR_PARRAY_NUM];               /* notify the timer exit */
    /* Check whether a timer exists in a processor. Currently, the timer is used only for
     * exiting the non-default scheduler. */
    ProcessorCheckExistenceFunc checkExistence;
    /* Check whether an executable timer exists in a processor. Currently, the timer is
     * used only for exiting the non-default scheduler. */
    ProcessorCheckReadyFunc checkReady;

    /* Hooks for dispatching cjthread */
    SchdCJThreadHookFunc schdCJThreadHook[SCHD_HOOK_BUTT];
    SchdCJThreadStateHookFunc schdCJThreadStateHook[CJTHREAD_STATE_HOOK_BUTT];
    SchdDestructorHookFunc destructorFunc;
    SchdMutatorStatusHookFunc mutatorStatusFunc;
    std::atomic<unsigned int> cjSingleModeThreadRetryTime;

    struct SchdfdManager *schdfdManager = nullptr;

    struct Trace trace;
#ifdef __OHOS__
    void* nativeSPForUIThread = nullptr;
#endif
};

/**
 * @brief Function pointer to the timer-related hook
 */
typedef int (*TimerControlFunc)(void);

/**
 * @brief Timer hook type registered in the schedule
 */
enum ScheduleTimerHookT {
    ANY_TIMER_HOOK = 0,       /* AnyTimer hook, which is invoked in ScheduleAnyCjthreadOrTimer */
    TIMER_HOOK_BUTT,
};

struct ScheduleNoWaitAttr {
    bool nowait;
    bool netpollInit;
    unsigned long long timeout;
    unsigned long long startTime;
};

/**
 * @brief schedule structure
 */
struct Schedule {
    std::atomic<ScheduleState> state;               /* schedule state */
    struct Thread *thread0;                         /* initial thread of the scheduler */
    std::atomic<struct CJThread *> lastCJThread;    /* previous cjthread for quick scheduling */
    struct ScheduleProcessor schdProcessor;         /* schdedule processor */
    enum ScheduleType scheduleType;                 /* schedule yype */
    struct Netpoll netpoll;                         /* netpoll */
    struct ScheduleCJThread schdCJThread;           /* schedule cjthread resource */
    struct ScheduleThread schdThread;               /* schedule thread resource */
    struct Dulink allScheduleDulink;                /* all schedule list */
    struct ScheduleNoWaitAttr noWaitAttr;
};

extern size_t g_pageSize;

extern struct ScheduleManager g_scheduleManager;

/**
 * @brief Obtain the processor of the current thread.
 * @retval Pointer to the processor bound to the current cjthread.
 */
MRT_INLINE static struct Processor *ProcessorGet(void)
{
    return (struct Processor *)((struct Thread *)(CJThreadGet()->thread))->processor;
}

/**
 * @brief Obtain the thread that hosts the current cjthread and return
 * @retval Point to the thread that hosts the current cjthread.
 */
MRT_INLINE static struct Thread *ThreadGet(void)
{
    return (struct Thread *)(CJThreadGet()->thread);
}

/**
 * @brief Get current processor of the thread.
 * @retval Return processor pointer of current cjthread.
 */
MRT_INLINE static struct Processor *ProcessorGetWithCheck(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return nullptr;
    }
    struct Thread *thread = reinterpret_cast<struct Thread *>(cjthread->thread);
    if (thread == nullptr) {
        return nullptr;
    }

    return reinterpret_cast<struct Processor *>(thread->processor);
}

/**
 * @brief Adds a cjthread to the global queue in the scheduling framework.
 * @param cjthreadList     [IN] cjthread array to be added
 * @param num    [IN] Number of cjthread
 * @retval 0 or error code
 */
int ScheduleGlobalWrite(struct CJThread *cjthreadList[], unsigned int num);

/**
 * @brief Obtain the address of the array registered in the processor.
 * @par Description: Obtain the address of the array registered in the processor. Index 0 is
 * fixed for storing the timer heap structure, and the other three indexes are reserved.
 * @param processor    [IN] Processor of the element to be obtained
 * @param key    [IN] Index
 * @retval Return the value stored in the key corresponding to the array in the processor.
 */
void *ProcessorGetspecific(const struct Processor *processor, int key);

/**
* @brief Store the value to the key index of the array in the processor.
* @par Description: Stores values to the key index of the array in the processor. Index 0 is
* used to store the timer heap structure, and the other three indexes are reserved.
* @param processor    [IN] Processor of the element to be stored
* @param key    [IN] Index
* @param value    [IN] Value to be stored
 */
void ProcessorSetspecific(struct Processor *processor, int key, void *value);

/**
 * @brief Wakes up threads to perform related tasks.
 * @par Description: Instruct the thread of the processor to execute the task. If the processor
 * has no working thread, an idle thread is started.
 * @param schedule    [IN] Current scheduler
 * @param specPro    [IN] Processor to be woken up. If the value is NULL, a processor is
 * randomly woken up.
 */
void ProcessorWake(struct Schedule *schedule, void *specPro);

/**
 * @brief Allocate an processor.
 * @par Description: Find a free processor in the processor resource group of the current
 * scheduler and return a pointer.
 * @param schedule    [IN] Current scheduler
 * @param specPro    [IN] Processor that is expected to be allocated. If the value is NULL,
 * a processor is randomly allocated.
 * @retval Pointer to an idle processor.
 */
struct Processor *ProcessorAlloc(struct Schedule *schedule, struct Processor *specPro);

/**
 * @brief free processor。
 * @param  schedule         [IN]  current scheduler
 * @param  processor        [IN]  the processor to be released
 */
void ProcessorFree(struct Schedule *schedule, struct Processor *processor);

/**
* @brief The processor of the schedule provides the registration function for external systems.
* @param func    [IN] Function to be registered
* @param key    [IN] Register the index.
* @retval 0 or error code
 */
int SchdProcessorHookRegister(ProcessorCheckFunc func, unsigned int key);

/**
 * @brief The schmon of the schedule provides the registration function for external systems.
 * @param func    [IN] Function to be registered
 * @param key     [IN] Register the index.
 * @retval 0 or error code
 */
int SchdSchmonHookRegister(SchmonCheckFunc func, unsigned int key);

/**
 * @brief schedule The registration function provided for external systems is invoked when
 * the system exits.
 * @param func    [IN] Function to be registered
 * @param key     [IN] Register the index.
 * @retval 0 or error code
 */
int SchdExitHookRegister(ProcessorExitFunc func, unsigned int key);

/**
 * @brief The timer hook of the schedule is provided for external registration to check
 * whether a timer exists.
 * @param func    [IN] Function to be registered
 * @retval 0 or error code
 */
int SchdCheckExistenceHookRegister(ProcessorCheckExistenceFunc func);

/**
 * @brief The timer hook of the schedule is provided for external registration to check
 * whether an executable timer exists.
 * @param func    [IN] Function to be registered
 * @retval 0 or error code
 */
int SchdCheckReadyHookRegister(ProcessorCheckReadyFunc func);

/**
 * @brief The timer hook of the scheduler provides the registration function for
 * external systems.
 * @param func   [IN] Function to be registered
 * @param key    [IN] Register the index.
 * @retval 0 or error code
 */
int ScheduleTimerHookRegister(TimerControlFunc func, unsigned int key);

/**
 * @brief Exit the scheduler.
 * @par Description: Exit the current scheduler and return to the context when ScheduleStart
 * is invoked.
 * Ensure that all cjthreads in the scheduler have ended except the cjthread that invokes
 * the interface.
 * @retval If the operation is successful, the context is switched and no value is returned.
 * If the operation fails, an error code is returned.
 */
int ScheduleTryExit(void);

/**
 * @brief After exiting the scheduler, clear the resources of the scheduler.
 */
void ScheduleClean(void);

/**
 * @brief Get page size
 */
MRT_INLINE static size_t SchedulePageSize(void)
{
    return g_pageSize;
}

/**
 * @brief Insert the cjthread control block into the global idle queue.
 * @par Description: Insert cjthread control blocks into the global free queue and update
 * the number of control blocks in the global free linked list.
 * @param gfreelist   [IN] Global idle cjthread queue
 * @param cjthread    [IN] Idle cjthread to be inserted
 */
void ScheduleGfreelistPush(struct ScheduleGfreeList *gfreelist, struct CJThread *cjthread);

/**
 * @brief Obtain the free cjthread control block from the global free linked list without
 * locking it.
 * @attention To ensure thread security, users should lock gfreeLock.
 * @param gfreelist    [IN] Global idle cjthread queue
 * @retval If the operation succeeds, the obtained cjthread control block pointer is returned.
 * If the operation fails, NULL is returned.
 */
struct CJThread *ScheduleGfreelistPop(struct ScheduleGfreeList *gfreelist);

/**
 * @brief Obtain an idle cjthread control block from the global free linked list and lock it.
 * @param gfreelist    [IN] Global idle cjthread queue
 * @retval If the operation succeeds, the obtained cjthread control block pointer is returned.
 * If the operation fails, NULL is returned.
 */
struct CJThread *ScheduleGfreelistGet(struct ScheduleGfreeList *gfreelist);

/**
 * @brief Add the scheduler to the global scheduler control queue.
 * @param schedule    [IN] Scheduler to be added
 */
void ScheduleListAdd(struct Schedule *schedule);

/**
 * @brief Remove the scheduler from the global scheduler control queue.
 * @param schedule    [IN] Scheduler to be removed
 */
void ScheduleListRemove(struct Schedule *schedule);

/**
 * @brief Add the cjthread to the global cjthread control queue.
 * @param cjthread [IN] cjthread to be added
 * @retval 0 or -1
 */
int ScheduleAllCJThreadListAdd(struct CJThread *cjthread, CJThreadCreateSource createSource);

/**
 * @brief  Add cjSingleModeThread to cjSingleModeThreadList.
 * @param  cjthread         [IN]  cjSingleModeThread
 * @retval return 0 if success, -1 if fail.
 */
int AddToCJSingleModeThreadList(struct CJThread *cjthread);

/**
 * @brief Single Thread Schedule try to run cjSingleModeThread.
 */
void TryRunCJSingleModeThread();

/**
 * @brief Remove a cjthread from the global cjthread control queue
 * @param  cjthread         [IN]  cjthread to be removed
 */
void ScheduleAllCJThreadListRemove(struct CJThread *cjthread);

/**
 * @brief Create a recursive lock.
 * @retval 0 or error code
 */
int ScheduleRecursiveLockCreate(pthread_mutex_t *mutex);

/**
 * @brief Obtain the total number of cjthreads in the scheduling framework.
 * @retval If g_scheduleManager is not initialized, 0xffffffff is returned. Otherwise,
 * the sum of the number of cjthreads for all existing schedulers is returned.
 */
unsigned long long ScheduleCJThreadCount(void);

/**
 * @brief Initializing Global Variables Before Scheduler Creation
 */
int ScheduleManagerInit(void);

/**
 * @brief Destroy global variables after the scheduler exits.
 */
void ScheduleManagerDestroy(void);

/**
 * @brief Add the thread to the global thread control queue
 * @param thread     [IN] Thread to be added
 * @param schedule   [IN] cjthread framework added to
 */
void ScheduleAllThreadListAdd(struct Thread *thread, struct Schedule *schedule);

/**
 * @brief Disable the trace dynamic library
 * @par Disable the trace dynamic library
 */
int ScheduleTraceDlclose(DlHandle dlHandle);

/**
 * @brief Obtain the cjthread of the blocked dump trace event.
 * @par Obtain the cjthread of the blocked dump trace event. If the traceReader is being
 * executed or fullTraceBuf is used, NULL is returned.
 * @retval NULL or CJThreadPointer
 */
struct CJThread *ScheduleGetTraceReader(void);

/**
 * @ingroup Interface for recording trace events in the scheduler
 * @brief Interface for the scheduler to record trace events
 * @attention The events that need to store the call stack must be in the context of the cjthread.
 * Ensure that the number of argNum is the same as the number of input extra parameters.
 * @param event     [IN] Event type
 * @param skip      [IN] When skip is greater than or equal to 0, the call stack needs to be
 * stored. The value indicates the number of layers to be returned to the stack.
 * @param cjthread  [IN] Obtains the mutator. If the value is empty, the stack does not need
 * to be returned.
 * @param argNum    [IN] Number of extra parameters, indicating the number of parameters of args
 * @param ...       [IN] Additional parameters
 */
void ScheduleTraceEventOrigin(TraceEvent event, int skip, struct CJThread *cjthread, int argNum, ...);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif
#endif /* MRT_SCHEDULE_IMPL_H */
