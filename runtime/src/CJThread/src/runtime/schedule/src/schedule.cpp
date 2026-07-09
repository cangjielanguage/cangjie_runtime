// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <cstring>
#include <unistd.h>
#include <cstdlib>
#include "schedule_impl.h"
#include "log.h"
#include "schmon.h"
#include "securec.h"
#include "basetime.h"
#include "Base/Log.h"
#if defined(CANGJIE_ASAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#include "StackManager.h"
#include "Common/NativeAllocator.h"
#if defined (MRT_LINUX) || defined (MRT_MACOS)
#include "schdpoll.h"
#endif
#ifdef __IOS__
#include "Mutator/MutatorManager.h"
#include "UnwindStack/PrintStackInfo.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

const int SCHEDULE_PROCESSOR_EXIT_WAIT_TIME = 10;   /* wait 10us */
/* When the non-default scheduler exits, if there are unfinished cjthreads, wait10 us */
const int SCHEDULE_CJTHREAD_EXIT_WAIT_TIME = 10;
const unsigned long long NANO_TO_MILLISECONDS = 1000 * 1000; /* Used to convert nanoseconds to milliseconds */
const unsigned long long MAX_RUN_CJSINGLETHREAD_TIME = 10000000; /* Max run cj single thread time is 10ms */
const size_t MAX_RUN_CJSINGLETHREAD_COUNT = 5; /* Max run cj single thread count is 5 times */
const unsigned int MAX_RETRY_CJSINGLETHREAD_COUNT = 3; /* Max retry cj single thread count is 3 times */
const size_t KB = 1024;

#if defined(TLS_COMMON_DYNAMIC)
GetTlsHookFunc g_getTlsFunc = nullptr;

int ScheduleGetTlsHookRegister(GetTlsHookFunc func)
{
    if (g_getTlsFunc != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_getTlsFunc = func;
    return 0;
}
#endif

struct ScheduleAttrInner g_schdAttr = {
    .thstackSize = THSTACK_SIZE_DEFAULT,
    .costackSize = COSTACK_SIZE_DEFAULT,
    .stackProtect = false,
    .stackGrow = true,
    .processorNum = PROCESSOR_NUM_DEFAULT,
};

struct ScheduleManager g_scheduleManager;

TimerControlFunc g_timerHookFunc[TIMER_HOOK_BUTT];  // timer hooks

size_t g_pageSize = 0;
bool g_tryExit;

/* Initialize the default parameters of the scheduler. */
struct ScheduleAttrInner *ScheduleAttributeGet(void)
{
    struct ScheduleAttrInner *attr;
    long res;
    attr = &g_schdAttr;
    res = GetSystemProcessorsNums();
    if (res == -1) {
        LOG_ERROR(errno, "sysconf failed");
        return nullptr;
    }
    attr->processorNum = static_cast<unsigned int>(res);
    return attr;
}

void SetSchedulerState(int state)
{
    Schedule* scheduler = ScheduleGet();
    scheduler->state = static_cast<ScheduleState>(state);
}

int ScheduleAttrInit(struct ScheduleAttr *usrAttr)
{
    int res;
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->thstackSize = THSTACK_SIZE_DEFAULT;
    attr->costackSize = COSTACK_SIZE_DEFAULT;
    attr->stackProtect = false;
    attr->stackGrow = true;
    res = static_cast<int>(GetSystemProcessorsNums());
    if (res == -1) {
        res = errno;
        LOG_ERROR(errno, "sysconf failed");
        return res;
    }
    attr->processorNum = static_cast<unsigned int>(res);
    return 0;
}

int ScheduleAttrInitWithParams(struct ScheduleAttr *usrAttr, const ConcurrencyParam param,
                               bool stackProtect, bool stackGrow)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->thstackSize = param.thStackSize * KB;
    attr->costackSize = param.coStackSize * KB;
    attr->stackProtect = stackProtect;
    attr->stackGrow = stackGrow;
    attr->processorNum = static_cast<unsigned int>(param.processorNum);
    return 0;
}

int ScheduleAttrCostackSizeSet(struct ScheduleAttr *usrAttr, unsigned int size)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->costackSize = size;

    return 0;
}

int ScheduleAttrThstackSizeSet(struct ScheduleAttr *usrAttr, unsigned int size)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->thstackSize = size;

    return 0;
}

int ScheduleAttrProcessorNumSet(struct ScheduleAttr *usrAttr, unsigned int num)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->processorNum = num;

    return 0;
}

int ScheduleAttrStackProtectSet(struct ScheduleAttr *usrAttr, bool open)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->stackProtect = open;

    return 0;
}

int ScheduleAttrStackGrowSet(struct ScheduleAttr *usrAttr, bool open)
{
    struct ScheduleAttrInner *attr = reinterpret_cast<struct ScheduleAttrInner *>(usrAttr);

    if (attr == nullptr) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    attr->stackGrow = open;

    return 0;
}

int ScheduleRecursiveLockCreate(pthread_mutex_t *mutex)
{
    int error;
    pthread_mutexattr_t mutexAttr;

    error = pthread_mutexattr_init(&mutexAttr);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    error = pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    error = pthread_mutex_init(mutex, &mutexAttr);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    return 0;
}

/**
 * @ingroup schedule
 * @brief Initialize the processor control block.
 * @par Initializes the processor control block bound to the specified scheduler.
 * @attention
 * @param schedule     [IN] Scheduler of the processor to be initialized
 * @param processorNum [IN] Number of initialized processors
 * @see
 */
int ScheduleProcessorInit(struct Schedule *schedule, unsigned int processorNum)
{
    int error;
    size_t mallocSize;
    unsigned int id;
    struct ScheduleProcessor *schdProcessor;
    struct Processor *processorGroup;
    struct Thread *thread;

    if (schedule->scheduleType != SCHEDULE_DEFAULT) {
        processorNum = PROCESSOR_NUM_SINGLE_THREAD;
    }
    // Allocating processor control blocks
    schdProcessor = &(schedule->schdProcessor);
    mallocSize = processorNum * sizeof(struct Processor);
    processorGroup = static_cast<struct Processor *>(MapleRuntime::NativeAllocator::NativeAlloc(mallocSize));
    if (processorGroup == nullptr) {
        return ERRNO_SCHD_MALLOC_FAILED;
    }
    schdProcessor->processorNum = processorNum;
    schdProcessor->processorGroup = processorGroup;

    // Init processor
    for (id = 0; id < processorNum; id++) {
        error = ProcessorInit(schedule, &(processorGroup[id]), ProcessorNewId());
        if (error) {
            LOG_ERROR(error, "processor id:%d init failed", id);
            MapleRuntime::NativeAllocator::NativeFree(processorGroup, mallocSize);
            return error;
        }
    }

    // Exclusive scheduler just bind thread to thread0
    if (schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        thread = CJThreadGet()->thread;
        schedule->thread0 = thread;
    } else {
        // bind processor0 to thread0.
        thread = schedule->thread0;
        thread->processor = &processorGroup[0];
    }
    processorGroup[0].thread = thread;
    processorGroup[0].state = PROCESSOR_RUNNING;
    // free num is processor_num - 1, because processor0 is running.
    schdProcessor->freeNum = processorNum - 1;

    return 0;
}

/**
 * @ingroup schedule
 * @brief Initialize the thread control block.
 * @par Initializes the processor control block bound to the specified scheduler.
 * @attention
 * @param schdThread [IN] Structure used to initialize the thread attributes of the scheduler.
 * @param attr       [IN] Structure used to initialize the attributes of the scheduler.
 * @see
 */
int ScheduleThreadInit(struct ScheduleThread *schdThread, const struct ScheduleAttrInner *attr)
{
    int error;
    schdThread->freeNum = 0;
    schdThread->threadExit = false;
    DulinkInit(&(schdThread->threadHead));
    DulinkInit(&schdThread->allThreadList);
    schdThread->stackSize = attr->thstackSize;

    // init lock
    error = ScheduleRecursiveLockCreate(&(schdThread->mutex));
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    error = ScheduleRecursiveLockCreate(&(schdThread->allthreadMutex));
    if (error) {
        pthread_mutex_destroy(&(schdThread->mutex));
        LOG_ERROR(error, "mutex init failed");
        return error;
    }

    // Add thread0 to all thread list
    ScheduleAllThreadListAdd(ThreadGet(), ScheduleGet());

    return 0;
}

int ScheduleGfreelistInit(struct ScheduleCJThread *schdCJThread)
{
    int error;
    struct ScheduleGfreeList *schGfreelist = &schdCJThread->gfreelist;

    error = ScheduleRecursiveLockCreate(&schGfreelist->gfreeLock);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    DulinkInit(&schGfreelist->gfreeList);
    schGfreelist->freeCJThreadNum = 0;

    return 0;
}

/**
 * @ingroup schedule
 * @brief Initialize the cjthread control block.
 * @par Initializes the cjthread control block of the scheduler.
 * @attention
 * @param schdCJThread [IN] cjthread attributes of the scheduler.
 * @param attr         [IN] attributes of the scheduler.
 */
int ScheduleCJThreadInit(struct ScheduleCJThread *schdCJThread, const struct ScheduleAttrInner *attr)
{
    int error;

    schdCJThread->cjthreadNum = 0;
    schdCJThread->stackProtect = attr->stackProtect;
    schdCJThread->stackGrow = attr->stackGrow;
    schdCJThread->stackSize = STACK_ADDR_ALIGN_UP(attr->costackSize, SchedulePageSize());

    error = ScheduleRecursiveLockCreate(&schdCJThread->mutex);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }

    schdCJThread->num = 0;
    DulinkInit(&schdCJThread->runq);

    error = ScheduleGfreelistInit(schdCJThread);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        pthread_mutex_destroy(&(schdCJThread->mutex));
        return error;
    }
    return 0;
}

int ScheduleThread0Init(struct Schedule *schedule, const struct ScheduleAttrInner *schedAttr)
{
    struct Thread *thread0;
    struct CJThread *cjthread0;
    struct ArgAttr argAttr;
    struct StackAttr stackAttr;

    argAttr.argStart = nullptr;
    argAttr.argSize = 0;
    stackAttr.stackSizeAlign = STACK_ADDR_ALIGN_UP(schedAttr->costackSize, SchedulePageSize());
    stackAttr.stackGrow = false;
    // init cjthread0
    cjthread0 = CJThreadAlloc(schedule, &argAttr, &stackAttr, NO_BUF);
    if (cjthread0 == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "cjthread0 init failed");
        return ERRNO_SCHD_INIT_FAILED;
    }
    cjthread0->schedule = schedule;
    CJThread0Make(cjthread0);
    // init thread0
    schedule->thread0 = (struct Thread *)malloc(sizeof(struct Thread));
    if (schedule->thread0 == nullptr) {
        LOG_ERROR(ERRNO_SCHD_MALLOC_FAILED, "thread0 malloc failed");
        CJThreadMemFree(cjthread0);
        return ERRNO_SCHD_MALLOC_FAILED;
    }
    thread0 = schedule->thread0;
    (void)memset_s(thread0, sizeof(struct Thread), 0, sizeof(struct Thread));
    DulinkInit(&(thread0->link2schd));
    thread0->state = THREAD_INIT;
    thread0->cjthread0 = cjthread0;
    thread0->boundCJThread = nullptr;
    thread0->nextProcessor = nullptr;
    int error = SemaphoreInit(&(thread0->sem), 0, 0);
    if (error) {
        LOG_ERROR(errno, "semaphore init failed");
        CJThreadMemFree(cjthread0);
        free(schedule->thread0);
        schedule->thread0 = nullptr;
        return errno;
    }
    // thread0 is the main thread to call ScheduleNew()
    thread0->osThread = pthread_self();
    thread0->tid = GetSystemThreadId();
    thread0->cjthread = cjthread0;
    cjthread0->thread = thread0;
    // set cjthread0 to tls to use CJThreadGet() to get the cjthread context
    CJThreadSet(cjthread0);
    ThreadPreemptFlagInit();

    return 0;
}

const struct ScheduleAttrInner *ScheduleAttrCheck(const struct ScheduleAttr *userAttr)
{
    const struct ScheduleAttrInner *attr = reinterpret_cast<const struct ScheduleAttrInner *>(userAttr);
    if (attr == nullptr) {
        return ScheduleAttributeGet();
    }

    if (attr->thstackSize == 0 ||
        attr->costackSize == 0 ||
        attr->costackSize > CJTHREAD_MAX_STACK_SIZE ||
        attr->processorNum == 0) {
        return nullptr;
    }
    return attr;
}

struct Schedule *ScheduleAlloc(ScheduleType scheduleType)
{
    struct Schedule *schedule;

    schedule = (struct Schedule *)MapleRuntime::NativeAllocator::NativeAlloc(sizeof(struct Schedule));
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_MALLOC_FAILED, "schedule malloc failed");
        return nullptr;
    }
    (void)memset_s(schedule, sizeof(struct Schedule), 0, sizeof(struct Schedule));
    schedule->scheduleType = scheduleType;
    ScheduleSet(schedule);
    if (scheduleType == SCHEDULE_DEFAULT && g_scheduleManager.defaultSchedule == nullptr) {
        g_scheduleManager.defaultSchedule = schedule;
    } else if (scheduleType == SCHEDULE_DEFAULT && g_scheduleManager.defaultSchedule != nullptr) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "can't create second default schedule");
        MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
        return nullptr;
    }
    return schedule;
}

void ScheduleThread0Fini(struct Schedule *schedule)
{
    // release thread0
    if (schedule->thread0 != nullptr) {
        SemaphoreDestroy(&(schedule->thread0->sem));
        if (schedule->thread0->cjthread0 != nullptr) {
            CJThreadMemFree(static_cast<struct CJThread*>(schedule->thread0->cjthread0));
            schedule->thread0->cjthread0 = nullptr;
        }
        free(schedule->thread0);
        schedule->thread0 = nullptr;
    }
    CJThreadSet(nullptr);
}

void ScheduleCJThreadFini(struct ScheduleCJThread *schdCJThread)
{
    pthread_mutex_destroy(&schdCJThread->mutex);
    pthread_mutex_destroy(&schdCJThread->gfreelist.gfreeLock);
}

void ScheduleThreadFini(struct ScheduleThread *schdThread)
{
    pthread_mutex_destroy(&schdThread->mutex);
    pthread_mutex_destroy(&schdThread->allthreadMutex);
}

void ScheduleFree(struct Schedule *schedule)
{
    if (schedule != nullptr) {
        if (schedule->scheduleType == SCHEDULE_DEFAULT) {
            g_scheduleManager.defaultSchedule = nullptr;
            ScheduleManagerDestroy();
        }
        MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
    }
    ScheduleSet(nullptr);
}

void ScheduleFini(struct Schedule *schedule, ScheduleFinishPhase phase)
{
    switch (phase) {
        case FINI_PROCESSOR:    // fall through
            ScheduleThreadFini(&(schedule->schdThread));
            [[fallthrough]];
        case FINI_THREAD:       // fall through
            ScheduleThread0Fini(schedule);
            [[fallthrough]];
        case FINI_THREAD0:       // fall through
            ScheduleCJThreadFini(&(schedule->schdCJThread));
            [[fallthrough]];
        default:
            ScheduleFree(schedule);
    }
}

int ScheduleManagerInit(void)
{
    int error;

    error = ScheduleRecursiveLockCreate(&g_scheduleManager.allScheduleListLock);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    error = ScheduleRecursiveLockCreate(&g_scheduleManager.allCJThreadListLock);
    if (error) {
        pthread_mutex_destroy(&g_scheduleManager.allScheduleListLock);
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    // Init scheduler management list
    DulinkInit(&g_scheduleManager.allScheduleList);
    // Init global cjthread management list for default mode
    DulinkInit(&g_scheduleManager.allCJThreadList);
    // Init global cjthread management list for UI mode
    DulinkInit(&g_scheduleManager.cjSingleModeThreadList);
    g_scheduleManager.cjSingleModeThreadRetryTime.store(0);
    g_scheduleManager.cjthreadIdGen = 1;
    g_scheduleManager.processorIdGen = 1;
    g_scheduleManager.initFlag = true;
    memset_s(&g_scheduleManager.trace, sizeof(struct Trace), 0, sizeof(struct Trace));
    // Init SchdfdManager
    struct SchdfdManager *schdfdManager = SchdfdManagerInit();
    if (schdfdManager == nullptr) {
        LOG_ERROR(-1, "schdfdManager init failed");
        return -1;
    }
    g_scheduleManager.schdfdManager = schdfdManager;
    return 0;
}

void ScheduleManagerDestroy(void)
{
    if (g_scheduleManager.initFlag) {
        pthread_mutex_destroy(&g_scheduleManager.allCJThreadListLock);
        pthread_mutex_destroy(&g_scheduleManager.allScheduleListLock);
        FreeSchdfdManager(g_scheduleManager.schdfdManager);
        if (g_scheduleManager.trace.mutexInitFlag) {
            pthread_mutex_destroy(&g_scheduleManager.trace.lock);
            pthread_mutex_destroy(&g_scheduleManager.trace.bufLock);
        }
        (void)memset_s(&g_scheduleManager, sizeof(struct ScheduleManager), 0, sizeof(struct ScheduleManager));
    }
}

ScheduleHandle ScheduleNew(ScheduleType scheduleType, const struct ScheduleAttr *userAttr)
{
    int error;
    struct Schedule *schedule;
    const struct ScheduleAttrInner *schedAttr;

    // When the scheduler is initialized, the created thread is bound to thread0. It is
    // convenient to use CJThreadGet() to obtain the cjthread. Therefore, only one scheduler
    // can be created for a thread.
    if (scheduleType != SCHEDULE_FOREIGN_THREAD && scheduleType != SCHEDULE_EXCLUSIVE &&
        CJThreadGet() != nullptr) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "schedule has been inited");
        return nullptr;
    }

    schedAttr = ScheduleAttrCheck(userAttr);
    if (schedAttr == nullptr) {
        LOG_ERROR(ERRNO_SCHD_ATTR_INVALID, "schedule attr invalid");
        return nullptr;
    }

    // Init schedule structure
    schedule = ScheduleAlloc(scheduleType);
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "schedule malloc failed");
        return nullptr;
    }

    if (scheduleType == SCHEDULE_DEFAULT && !g_scheduleManager.initFlag) {
        error = ScheduleManagerInit();
        if (error) {
            MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
            return nullptr;
        }
    } else if (scheduleType != SCHEDULE_DEFAULT && !g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "default schedule hasn't been inited");
        MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
        return nullptr;
    } else if (scheduleType == SCHEDULE_DEFAULT && g_scheduleManager.initFlag) {
        // Before the default scheduler is created, g_scheduleManager should not be
        // initialized and should not go to this branch. Therefore, g_scheduleManager cannot
        // be created.
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "g_shceduleManager shouldn't have been initialized");
        MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
        return nullptr;
    }

    // Init cjthread structure
    error = ScheduleCJThreadInit(&(schedule->schdCJThread), schedAttr);
    if (error) {
        LOG_ERROR(error, "schedule cjthread control block init failed");
        ScheduleFini(schedule, FINI_CJTHREAD);
        return nullptr;
    }
    // for exclusive schedule, no need to init thread0
    if (schedule->scheduleType != SCHEDULE_EXCLUSIVE) {
        // Init thread0 and cjthread0
        error = ScheduleThread0Init(schedule, schedAttr);
        if (error) {
            LOG_ERROR(error, "thread0 init failed");
            ScheduleFini(schedule, FINI_THREAD0);
            return nullptr;
        }
         // Init thread structure
        error = ScheduleThreadInit(&(schedule->schdThread), schedAttr);
        if (error) {
            LOG_ERROR(error, "schedule thread control block init failed");
            ScheduleFini(schedule, FINI_THREAD);
            return nullptr;
        }
    }

    // Init processor group
    error = ScheduleProcessorInit(schedule, schedAttr->processorNum);
    if (error) {
        LOG_ERROR(error, "schedule processor control block init failed");
        ScheduleFini(schedule, FINI_PROCESSOR);
        return nullptr;
    }
    ScheduleListAdd(schedule);
    RandSeedInit();
    return (ScheduleHandle)schedule;
}

void RegisterEventHandlerCallbacks(PostTaskFunc pFunc, HasHigherPriorityTaskFunc hFunc)
{
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "schedule manager is not init");
        return;
    }
    g_scheduleManager.postTaskFunc = pFunc;
    g_scheduleManager.hasHigherPriorityTaskFunc = hFunc;
}

void CJRegisterStackInfoCallbacks(UpdateStackInfoFunc uFunc)
{
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "schedule manager is not init");
        return;
    }
    g_scheduleManager.updateStackInfoFunc = uFunc;
}

void CJRegisterArkVMInRuntime(unsigned long long vm)
{
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_INIT_FAILED, "schedule manager is not init");
        return;
    }
    g_scheduleManager.arkVM = vm;
}

int ScheduleNetpollInit(void)
{
    struct Schedule *schedule = ScheduleGet();
    int error;
    // Reentry lock. The lock may reentrant in rpc.
    error = ScheduleRecursiveLockCreate(&schedule->netpoll.pollMutex);
    if (error) {
        LOG_ERROR(error, "mutex init failed");
        return error;
    }
    error = PthreadSpinInit(&schedule->netpoll.closingLock);
    if (error) {
        pthread_mutex_destroy(&schedule->netpoll.pollMutex);
        LOG_ERROR(error, "pthread spin init failed");
        return error;
    }
    return 0;
}

void ScheduleNetpollDestroy(void)
{
    struct Schedule *schedule = ScheduleGet();
    pthread_mutex_destroy(&schedule->netpoll.pollMutex);
    PthreadSpinDestroy(&schedule->netpoll.closingLock);
}

#ifdef __OHOS__
void StoreNativeSPForUIThread(void* sp)
{
    g_scheduleManager.nativeSPForUIThread = sp;
}

void* GetNativeSPForUIThread()
{
    return g_scheduleManager.nativeSPForUIThread;
}

bool IsForeignThread()
{
    struct CJThread *cjthread = CJThreadGet();
    ScheduleType type = cjthread->schedule->scheduleType;
    switch (type) {
        case SCHEDULE_DEFAULT:
            HILOG_FATAL(ERRNO_SCHD_WRONG_TYPE, "Forbidden to use JSRuntime() in a spawn!");
        case SCHEDULE_UI_THREAD:
            return false;
        case SCHEDULE_FOREIGN_THREAD:
            return true;
    }
}
#endif

/* Scheduler startup process
 * 1. Call ScheduleNew() to create a scheduler
 * 2. Call CJThreadNew() to create main
 * 3. Call ScheduleStart() to execute main
 **/
int ScheduleStart(void)
{
    struct Schedule *schedule;
    int ret;

    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }
    if (schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_IS_RUNNING;
    }
    ScheduleNetpollInit();
    if (schedule->scheduleType == SCHEDULE_DEFAULT) {
        ret = SchmonStart(schedule);
        if (ret != 0) {
            ScheduleNetpollDestroy();
            return ret;
        }
    }

    schedule->state = SCHEDULE_RUNNING;

    g_tryExit = false;
    CJThreadContextGet(&ThreadGet()->context);
    // The judgment is used when the schedule_try_exit interface is invoked.
    if (g_tryExit || (schedule->scheduleType != SCHEDULE_DEFAULT &&
                      (schedule->state == SCHEDULE_EXITING || schedule->state == SCHEDULE_EXITED))) {
        return 0;
    }
    // consider delete it because trace start is later than schedule start.
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_PROC_WAKE)) {
        ScheduleTraceEventOrigin(TRACE_EV_PROC_WAKE, -1, nullptr, 1,
                                 static_cast<unsigned long long>(ThreadGet()->tid));
    }
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEnterCJThread(ThreadGet());
#endif
    ProcessorSchedule();

    return 0;
}

bool ScheduleExistTask(void)
{
    ProcessorCheckReadyFunc checkFunc;
    struct Schedule *schedule = ScheduleGet();
    if (ScheduleAnyCJThread(schedule)) {
        return true;
    }
    checkFunc = g_scheduleManager.checkReady;
    if (checkFunc != nullptr) {
        return checkFunc(ProcessorGet());
    }

    return false;
}

int ScheduleStartNoWait(unsigned long long timeout)
{
    struct Schedule *schedule;

    schedule = ScheduleGet();
    if (schedule == nullptr || schedule->scheduleType == SCHEDULE_DEFAULT || schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_ATTR_INVALID;
    }
    if (!schedule->noWaitAttr.netpollInit) {
        ScheduleNetpollInit();
        schedule->noWaitAttr.netpollInit = true;
    }
    if (!ScheduleExistTask()) {
        return 0;
    }
    schedule->state = SCHEDULE_RUNNING;

    CJThreadContextGet(&ThreadGet()->context);
    if (schedule->noWaitAttr.nowait) {
        schedule->state = SCHEDULE_INIT;
        schedule->noWaitAttr.nowait = false;
        return 0;
    }
    schedule->noWaitAttr.nowait = true;
    schedule->noWaitAttr.timeout = timeout * NANO_TO_MILLISECONDS;
    schedule->noWaitAttr.startTime = CurrentNanotimeGet();
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEnterCJThread(ThreadGet());
#endif
    ProcessorSchedule();

    return 0;
}

/* Non-default scheduler thread exits */
void ScheduleNonDefaultThreadExit(struct Schedule *schedule, bool wait)
{
    while (atomic_load(&schedule->thread0->state) == THREAD_PRE_SLEEP) {}
    if (atomic_load(&schedule->thread0->state) == THREAD_SLEEP) {
        int error = SemaphorePost(&(schedule->thread0->sem));
        if (error != 0) {
            LOG_ERROR(error, "sem post failed");
            return;
        }
    }
    if (wait) {
        pthread_join(schedule->thread0->osThread, nullptr);
    }
}

/* Releases thread resources in the thread pool. Note: This interface needs to be invoked
 * only in schedule_try_exit, not in schedule_stop.
 */
void ScheduleThreadsFree(struct Schedule *schedule)
{
    struct ScheduleThread *schdThread;
    struct Thread *thread;

    schdThread = &schedule->schdThread;
    while (!DulinkIsEmpty(&schdThread->threadHead)) {
        thread = DULINK_ENTRY(schdThread->threadHead.next, struct Thread, link2schd);
        DulinkRemove(&thread->link2schd);
        // Wakes up the thread. The thread checks the exit flag and exits.
        SemaphorePost(&thread->sem);
        pthread_join(thread->osThread, nullptr);
        CJThreadMemFree(static_cast<struct CJThread*>(thread->cjthread0));
        free(thread);
    }
}

void ScheduleProcessorFree(struct Schedule *schedule)
{
    struct Processor *processor;
    struct CJThread *cjthread;
    ProcessorExitFunc func;
    unsigned int i;
    unsigned int j;

    for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
        processor = &schedule->schdProcessor.processorGroup[i];
        while (1) {
            cjthread = ProcessorFreelistGet(processor);
            if (cjthread == nullptr) {
                break;
            }
            CJThreadFree(cjthread, false);
        }
        free(processor->runq.buf);

        // Release the timer of processors.
        for (j = 0; j < PROCESSOR_PARRAY_NUM; ++j) {
            func = g_scheduleManager.exit[j];
            if (func != nullptr) {
                func(processor);
            }
        }
    }

    // Release processor.
    MapleRuntime::NativeAllocator::NativeFree(schedule->schdProcessor.processorGroup,
        schedule->schdProcessor.processorNum * sizeof(struct Processor));
}

void ScheduleSchmonExit(void)
{
    if (g_scheduleManager.schmon.schmonId != 0) {
        pthread_join(g_scheduleManager.schmon.schmonId, nullptr);
        g_scheduleManager.schmon.schmonId = 0;
    }
}

/* Releasing global and local cjthreads */
void ScheduleCJThreadFree(struct Schedule *schedule)
{
    struct CJThread *cjthread;
    struct Processor *processor;
    unsigned int i;

    // Release cjthreads in the global queue
    while (1) {
        cjthread = ProcessorGlobalRead(schedule, false);
        if (cjthread == nullptr) {
            break;
        }
        CJThreadFree(cjthread, false);
    }

    // Release cjthreads in the local queues
    for (i = 0; i < schedule->schdProcessor.processorNum; i++) {
        processor = &schedule->schdProcessor.processorGroup[i];

        cjthread = ProcessorCJhreadNextRead(processor);
        if (cjthread != nullptr) {
            CJThreadFree(cjthread, false);
        }

        while (1) {
            cjthread = ProcessorLocalRead(processor);
            if (cjthread == nullptr) {
                break;
            }
            CJThreadFree(cjthread, false);
        }
    }
}

void ScheduleNetpollExit(struct Schedule *schedule)
{
    if (schedule->netpoll.npfd != nullptr) {
        NetpollExit(schedule->netpoll.npfd);
    }
#if defined (MRT_LINUX) || defined (MRT_MACOS)
    SchdpollFreePd();
#endif
}

/* Checks for unfinished cjthread tasks on a non-default scheduler */
bool ScheduleAnyCJThreadRunning(struct Schedule *schedule)
{
    struct ScheduleCJThread *schdCJThread;
    struct CJThread *cjthread;
    struct Processor *processor;
    ProcessorCheckExistenceFunc func;
    struct ScheduleGfreeList *gfreelist;

    schdCJThread = &schedule->schdCJThread;
    gfreelist = &schedule->schdCJThread.gfreelist;
    while (1) {
        cjthread = ScheduleGfreelistGet(gfreelist);
        if (cjthread == nullptr) {
            break;
        }
        CJThreadFree(cjthread, false);
    }
    processor = &schedule->schdProcessor.processorGroup[0];
    while (1) {
        cjthread = ProcessorFreelistGet(processor);
        if (cjthread == nullptr) {
            break;
        }
        CJThreadFree(cjthread, false);
    }
    if (atomic_load(&schdCJThread->cjthreadNum) != 0) {
        return true;
    }
    // Check whether a timer exists.
    func = g_scheduleManager.checkExistence;
    if (func != nullptr) {
        return func(processor);
    }
    return false;
}

// free exclusive scheduler
void ExclusiveScheduleFree(struct Schedule *schedule)
{
    ScheduleListRemove(schedule);
    ScheduleProcessorFree(schedule);
    MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
}

void ScheduleNonDefaultFree(ScheduleHandle scheduleHandle)
{
    auto* schedule = reinterpret_cast<Schedule*>(scheduleHandle);
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "schedule is null in ScheduleNonDefaultFree");
        return;
    }
    ScheduleListRemove(schedule);
    // The network module exits after the processor stops. Otherwise, the processor is still
    // accessing the network, and problems occur.
    ScheduleNetpollExit(schedule);
    // Release global and local cjthreads.
    ScheduleCJThreadFree(schedule);
    // Release processor resources and auxiliary resources, including timers.
    ScheduleProcessorFree(schedule);
    // EXCLUSIVE scheduler doesn't have thread0
    if (schedule->scheduleType != SCHEDULE_EXCLUSIVE && schedule->thread0 != nullptr) {
        CJThreadMemFree(static_cast<struct CJThread*>(schedule->thread0->cjthread0));
        free(schedule->thread0);
        schedule->thread0 = nullptr;
    }
    MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
}

/* Check whether the current processor is in the FFI state. The processor is in ScheduleStop
 * and will not be scheduled again.
 */
bool ScheduleProcessorSkipFFI(struct Processor *processor)
{
    SchdMutatorStatusHookFunc hookFunc;
    struct Thread *thread;
    struct CJThread *cjthread;

    thread = processor->thread;

    if (thread == nullptr) {
        return false;
    }
    cjthread = static_cast<struct CJThread*>(thread->cjthread);

    if (cjthread == nullptr) {
        return false;
    }

    hookFunc = g_scheduleManager.mutatorStatusFunc;
    if (hookFunc == nullptr || cjthread->mutator == nullptr) {
        return false;
    }
    return hookFunc(cjthread->mutator);
}

void ScheduleAllNonDefaultExit(void)
{
    struct Schedule *schedule;
    struct Schedule *curschdeule = ScheduleGet();
    struct Dulink *scheduleNode;

    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    // Set the exit status bit for all non-default schedulers without confirming the end of
    // thread execution.
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        if (schedule == curschdeule) {
            continue;
        }
        atomic_store(&schedule->state, SCHEDULE_EXITING);
        ScheduleNonDefaultThreadExit(schedule, false);
        // Preemption is set only for threads of the non-default scheduler. Do not change the
        // processor state in the syscall state to exiting. Otherwise, the thread cannot exit
        // after executing ThreadStop.
        SchmonPreemptRunning(&(schedule->schdProcessor.processorGroup[0]));
    }
    // Confirm that all default scheduler threads are executed.
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        if (schedule == curschdeule) {
            continue;
        }
        if (schedule->scheduleType != SCHEDULE_EXCLUSIVE &&
            pthread_self() != schedule->thread0->osThread &&
            !ScheduleProcessorSkipFFI(&(schedule->schdProcessor.processorGroup[0]))) {
            pthread_join(schedule->thread0->osThread, nullptr);
            atomic_store(&schedule->schdProcessor.processorGroup[0].state, PROCESSOR_EXITING);
        }
        atomic_store(&schedule->state, SCHEDULE_EXITED);
        // Because the current node is released when resources are released, the next element
        // traversed after the current node is released should be the next node of the
        // previous node of the current node.
        scheduleNode = scheduleNode->prev;
        // Releasing Non-Default Scheduler Resources
        ScheduleNonDefaultFree(reinterpret_cast<ScheduleHandle>(schedule));
    }
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
}

/* Preempt and stop all worker threads */
void ScheduleProcessorExit(struct Schedule *schedule)
{
    unsigned int i;
    struct Processor *processor;
    struct Processor *curProcessor;
    const int waitTime = SCHEDULE_PROCESSOR_EXIT_WAIT_TIME; // wait 10us
    ProcessorState pstate = PROCESSOR_IDLE;

    // If processor is NULL, the call is made outside the scheduling framework.
    if (CJThreadGet() == nullptr) {
        curProcessor = nullptr;
    } else {
        curProcessor = ProcessorGet();
    }
    for (i = 0; i < schedule->schdProcessor.processorNum; i++) {
        processor = &schedule->schdProcessor.processorGroup[i];
        if (processor == curProcessor) {
            continue;
        }
        // Set the idle state to the exit state, and notify the preemption of the running state.
        // Change the status of the processor in the syscall state to exit. When the thread
        // finishes executing from the syscall, it searches for an idle processor. If it cannot
        // find an idle processor, it sleeps itself.
        pstate = processor->state;
        if (pstate == PROCESSOR_IDLE || pstate == PROCESSOR_SYSCALL) {
            atomic_compare_exchange_strong(&processor->state, &pstate, PROCESSOR_EXITING);
        } else if (pstate == PROCESSOR_RUNNING) {
            SchmonPreemptRunning(processor);
        }
    }
    // Traversal check. The setting and check are divided into two cycles because preemption
    // usually takes a period of time after the setting. If the setting is combined into one
    // cycle, the preemption needs to be repeated for n times.
    for (i = 0; i < schedule->schdProcessor.processorNum; i++) {
        processor = &schedule->schdProcessor.processorGroup[i];
        if (processor == curProcessor) {
            continue;
        }

        while (atomic_load(&processor->state) != PROCESSOR_EXITING || processor->thread != nullptr) {
            pstate = processor->state;
            if (pstate == PROCESSOR_IDLE || pstate == PROCESSOR_SYSCALL) {
                atomic_compare_exchange_strong(&processor->state, &pstate, PROCESSOR_EXITING);
            } else if (pstate == PROCESSOR_RUNNING) {
                SchmonPreemptRunning(processor);
            }

            // Detects that the current processor is running FFI and exits directly. If the
            // FFI ends and is ready to leave the security zone, the stw mechanism is triggered
            // and the thread is blocked.
            if (ScheduleProcessorSkipFFI(processor)) {
                break;
            }
            usleep(waitTime);
        }
    }
    ScheduleAllNonDefaultExit();

    return;
}

void ScheduleExitMode(struct Schedule *schedule, bool threadExit)
{
    SchdCJThreadHookFunc hookFunc;

    // Set state to exit state
    schedule->schdThread.threadExit = threadExit;

    // Ensure that all processors are stopped. When the system exits, the processor is not
    // woken up. The non-default scheduler has only one processor and does not sleep.
    if (schedule->scheduleType == SCHEDULE_DEFAULT) {
        schedule->state = SCHEDULE_EXITING;
        // Ensure that the monitoring thread is stopped.
        ScheduleSchmonExit();
        hookFunc = g_scheduleManager.schdCJThreadHook[SCHD_STOP];
        if (hookFunc != nullptr) {
            hookFunc();
        }
        ScheduleProcessorExit(schedule);
        // All processors enter the PROCESSOR_EXITING state in ScheduleProcessorExit. The
        // processors in ffi are blocked in the stub of the warehouse program. At this time,
        // the scheduling framework does not run the cjthread and can exit safely.
        schedule->state = SCHEDULE_EXITED;
    } else {
        // The non-default scheduling framework exits actively. The framework has gone through
        // the Schedule_WAITING phase. At this time, no cjthread is running and no cjthread
        // can be created. You can switch the Schedule_EXITED state. You can safely exit.
        schedule->state = SCHEDULE_EXITED;
        ScheduleNonDefaultThreadExit(schedule, true);
    }

    ScheduleListRemove(schedule);

    // The network module exits after the processor stops. Otherwise, the processor is still
    // accessing the network, and problems occur.
    ScheduleNetpollExit(schedule);

    // Release global and local cjthreads
    ScheduleCJThreadFree(schedule);

    /*  */
    if (threadExit) {
        ScheduleThreadsFree(schedule);
    }

    // No other worker thread is running except the current thread. If thread_exit == false,
    // the function will not be executed. Releases processor resources and auxiliary resources,\
    // including timers.
    ScheduleProcessorFree(schedule);
}

/* Stops the current scheduling framework. Note: This interface suspends the thread without
 * exiting, so that the thread exits with the process. This interface cannot be used outside
 * the scheduling framework. */
void ScheduleStop(ScheduleHandle scheduleHandle)
{
    struct CJThread *cjthread = CJThreadGet();
    struct Schedule *schedule = (struct Schedule *)scheduleHandle;
    // The default scheduler exits in the cjthread context, not the default scheduler exits
    // specific context requirements, but cannot exit in its own cjthread task.
    if (schedule == nullptr || (schedule->scheduleType == SCHEDULE_DEFAULT && cjthread == nullptr)) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "cjthread or schedule not exist!\n");
        return;
    }

    // The non-default scheduler needs to wait for all cjthreads run to finish when shutting down.
    if (schedule->scheduleType != SCHEDULE_DEFAULT) {
        schedule->state = SCHEDULE_WAITING;
        while (ScheduleAnyCJThreadRunning(schedule)) {
            usleep(SCHEDULE_CJTHREAD_EXIT_WAIT_TIME);
        }
    }
    ScheduleExitMode(schedule, false);
    if (schedule->scheduleType == SCHEDULE_DEFAULT) {
        ScheduleAllCJThreadListRemove(cjthread);
        g_scheduleManager.defaultSchedule = nullptr;
        ScheduleManagerDestroy();
    } else {
        CJThreadMemFree(static_cast<struct CJThread*>(schedule->thread0->cjthread0));
        free(schedule->thread0);
        MapleRuntime::NativeAllocator::NativeFree(schedule, sizeof(struct Schedule));
    }
}

/* Stops the scheduling framework. Note: This interface suspends the thread without exiting,
 * so that the thread exits with the process. This interface can be used outside the scheduling framework. */
int ScheduleStopOutside(ScheduleHandle scheduleHandle)
{
    struct Schedule *oldSchedule;
    struct Schedule *schedule = reinterpret_cast<Schedule *>(scheduleHandle);

    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "no schedule");
        return ERRNO_SCHD_INVALID;
    }

    ScheduleType scheduleType = schedule->scheduleType;
    oldSchedule = ScheduleGet();
    ScheduleSet(schedule);
    ScheduleExitMode(schedule, false);
    // This parameter is added to solve the memory leakage problem when the dlclose exits in
    // the macro expansion scenario.
    if (scheduleType == SCHEDULE_DEFAULT && g_scheduleManager.initFlag) {
        FreeSchdfdManager(g_scheduleManager.schdfdManager);
    }
    ScheduleSet(oldSchedule);
    return 0;
}

/* It is invoked in a cjthread to exit the scheduling framework and each worker thread. */
int ScheduleTryExit(void)
{
    struct Schedule *schedule;
    struct ScheduleCJThread *schdCJThread;
    struct CJThread *cjthread;
    unsigned long long cjthreadNum = 0;
    struct Dulink *scheduleCJThreadNode = nullptr;

    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }

    schdCJThread = &schedule->schdCJThread;
    if (ThreadGet() != schedule->thread0) {
        return ERRNO_SCHD_EXIT_FAILED;
    }

    // Need to ensure that only the current cjthread is running and there are no other cjthreads left.
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
        cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
        if (cjthread->state != CJTHREAD_IDLE) {
            ++cjthreadNum;
            if (cjthreadNum > 1) {
                pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);
                LOG_INFO(ERRNO_SCHD_EXIT_FAILED, "now cjthreadNum is %lld", atomic_load(&schdCJThread->cjthreadNum));
                return ERRNO_SCHD_EXIT_FAILED;
            }
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);

    ScheduleExitMode(schedule, true);

    // Switch back to the context in which the main thread invokes schedule start.
    g_tryExit = true;
    auto *thread = ThreadGet();
#ifdef CANGJIE_ASAN_SUPPORT
    // return to ThreadEntry, switch to original thread
    MapleRuntime::Sanitizer::AsanExitCJThread(thread);
#endif
    CJThreadContextSet(&thread->context);

    return 0;
}

/* After the schedule_try_exit exits, the last cjthread exists and thread0 is not cleared.
 * This interface is invoked to clear the cjthread. */
void ScheduleClean(void)
{
    struct CJThread *cjthread;
    struct Schedule *schedule;
    struct Thread *thread;

    cjthread = CJThreadGet();
    if (cjthread != nullptr) {
        thread = cjthread->thread;
        CJThreadFree(cjthread, false);
        CJThreadSet(nullptr);
        if (thread != nullptr) {
            CJThreadMemFree(static_cast<struct CJThread*>(thread->cjthread0));
            free(thread);
        }
    }

    schedule = ScheduleGet();
    ScheduleFree(schedule);
}

int ScheduleGlobalWrite(struct CJThread *cjthreadList[], unsigned int num)
{
    struct Dulink *globalQueue;
    struct Schedule *schedule;
    unsigned long i;

    if (num == 0) {
        return 0;
    }

    schedule = cjthreadList[0]->schedule;
    globalQueue = &schedule->schdCJThread.runq;

    pthread_mutex_lock(&schedule->schdCJThread.mutex);
    for (i = 0; i < num; i++) {
        DulinkPushtail(globalQueue, cjthreadList[i]);
    }
    schedule->schdCJThread.num += num;
    pthread_mutex_unlock(&schedule->schdCJThread.mutex);

    return 0;
}

/* Check whether there are any cjthreads waiting to run in the schedule. */
bool ScheduleAnyCJThread(ScheduleHandle scheduleHandle)
{
    unsigned int i;
    struct Schedule *schedule = (struct Schedule *)scheduleHandle;
    struct Processor *processor;

    for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
        processor = &schedule->schdProcessor.processorGroup[i];
        if (QueueLength(&processor->runq) != 0) {
            return true;
        }
    }

    if (atomic_load(&schedule->lastCJThread) != static_cast<struct CJThread *>(nullptr)) {
        return true;
    }
    return schedule->schdCJThread.num != 0;
}

unsigned long long ScheduleCJThreadCount(void)
{
    struct CJThread *cjthread = nullptr;
    unsigned long long cjthreadNum = 0;
    struct Dulink *scheduleCJThreadNode = nullptr;
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "allCJThreadList haven't init");
        return static_cast<unsigned long long>(-1);
    }
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
        cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
        if (cjthread->state != CJTHREAD_IDLE) {
            ++cjthreadNum;
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);
    TRACE_COUNT("CJRT_cjthreadNum", cjthreadNum);
    return cjthreadNum;
}

int SchdProcessorHookRegister(ProcessorCheckFunc func, unsigned int key)
{
    if (g_scheduleManager.check[key] != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_scheduleManager.check[key] = func;
    return 0;
}

int SchdSchmonHookRegister(SchmonCheckFunc func, unsigned int key)
{
    if (g_scheduleManager.schmon.checkFunc[key] != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_scheduleManager.schmon.checkFunc[key] = func;
    return 0;
}

int SchdExitHookRegister(ProcessorExitFunc func, unsigned int key)
{
    if (g_scheduleManager.exit[key] != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_scheduleManager.exit[key] = func;
    return 0;
}

int SchdCheckExistenceHookRegister(ProcessorCheckExistenceFunc func)
{
    if (g_scheduleManager.checkExistence != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_scheduleManager.checkExistence = func;
    return 0;
}

int SchdCheckReadyHookRegister(ProcessorCheckReadyFunc func)
{
    if (g_scheduleManager.checkReady != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_scheduleManager.checkReady = func;
    return 0;
}

int ScheduleTimerHookRegister(TimerControlFunc func, unsigned int key)
{
    if (g_timerHookFunc[key] != nullptr) {
        return ERRNO_SCHD_HOOK_REGISTED;
    }
    g_timerHookFunc[key] = func;
    return 0;
}

void ScheduleGfreelistPush(struct ScheduleGfreeList *gfreelist, struct CJThread *cjthread)
{
    DulinkAdd(&cjthread->schdDulink, &(gfreelist->gfreeList));
    gfreelist->freeCJThreadNum++;
}

struct CJThread *ScheduleGfreelistPop(struct ScheduleGfreeList *gfreelist)
{
    struct CJThread *cjthread;
    if (gfreelist->freeCJThreadNum != 0) {
        cjthread = DULINK_ENTRY(gfreelist->gfreeList.next,
                                 struct CJThread, schdDulink);
        DulinkRemove(&(cjthread->schdDulink));
        gfreelist->freeCJThreadNum--;

        return cjthread;
    }
    return nullptr;
}

struct CJThread *ScheduleGfreelistGet(struct ScheduleGfreeList *gfreelist)
{
    struct CJThread *cjthread;
    pthread_mutex_lock(&gfreelist->gfreeLock);
    cjthread = ScheduleGfreelistPop(gfreelist);
    pthread_mutex_unlock(&gfreelist->gfreeLock);
    return cjthread;
}

void ScheduleListAdd(struct Schedule *schedule)
{
    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DulinkAdd(&(schedule->allScheduleDulink), &(g_scheduleManager.allScheduleList));
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
}

void ScheduleListRemove(struct Schedule *schedule)
{
    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DulinkRemove(&(schedule->allScheduleDulink));
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
}

void ScheduleAllThreadListAdd(struct Thread *thread, struct Schedule *schedule)
{
    pthread_mutex_lock(&(schedule->schdThread.allthreadMutex));
    DulinkAdd(&(thread->allThreadDulink), &(schedule->schdThread.allThreadList));
    pthread_mutex_unlock(&(schedule->schdThread.allthreadMutex));
}

int ScheduleAllCJThreadListAdd(struct CJThread *cjthread, CJThreadCreateSource createSource)
{
    ScheduleState scheduleState = cjthread->schedule->state.load();
    if (scheduleState != SCHEDULE_RUNNING &&
        scheduleState != SCHEDULE_INIT &&
        scheduleState != SCHEDULE_EXITING) {
        HILOG_ERROR(ERRNO_SCHD_INVALID,
                    "can't add cjthread to the target scheduler, schedule type %d, schedule state %d",
                    cjthread->schedule->scheduleType, scheduleState);
        return -1;
    }
    cjthread->mutator = MapleRuntime::Mutator::NewMutator();
    cjthread->mutator->MapleRuntime::Mutator::SetCjthreadPtr(static_cast<void*>(cjthread));
    // Finalizer cjthread is not added to the list to avoid accessing the finalizer mutator twice in
    // VisitAllMutators, and to prevent cjthread dfx from counting the cjthread of the finalizer
    if (UNLIKELY(createSource == CJTHREAD_CREATE_SOURCE_FINALIZER)) {
        return 0;
    }
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DulinkAdd(&(cjthread->allCJThreadDulink), &(g_scheduleManager.allCJThreadList));
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);

    return 0;
}

int AddToCJSingleModeThreadList(struct CJThread *cjthread)
{
    if (cjthread == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr when add to cjSingleModeThreadList.");
        return -1;
    }
    PostTaskFunc PostTask = g_scheduleManager.postTaskFunc;
    if (PostTask == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_EVENT_HANDLER_FUNC_NULL,
                    "The event handler function is nullptr when add to cjSingleModeThreadList.");
        return -1;
    }

    pthread_mutex_lock(&g_scheduleManager.cjSingleModeThreadListLock);
    int isEmpty = DulinkIsEmpty(&(g_scheduleManager.cjSingleModeThreadList));
    DulinkAdd(&(cjthread->cjSingleModeThreadDulink), &(g_scheduleManager.cjSingleModeThreadList));
    pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);
    if (isEmpty) {
        while (!PostTask(reinterpret_cast<void*>(TryRunCJSingleModeThread))) {}
    }
    return 0;
}

extern "C" void CJ_MRT_RolveCycleRef();

void RunResolveCycle(void* funcPtr)
{
    PostTaskFunc PostTask = g_scheduleManager.postTaskFunc;
    if (PostTask == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_UITHREAD_ERROR,
                    "The event handler function is nullptr when try run cjSingleModeThread.");
        return;
    }
    while (!PostTask(funcPtr)) {}
}

void TryRunCJSingleModeThread()
{
    PostTaskFunc PostTask = g_scheduleManager.postTaskFunc;
    HasHigherPriorityTaskFunc HasHigherPriorityTask = g_scheduleManager.hasHigherPriorityTaskFunc;
    if (PostTask == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_UITHREAD_ERROR,
                    "The event handler function is nullptr when try run cjSingleModeThread.");
        return;
    }
    unsigned long long startTime = CurrentNanotimeGet();
    size_t runCount = 0;
    pthread_mutex_lock(&g_scheduleManager.cjSingleModeThreadListLock);
    if (DulinkIsEmpty(&(g_scheduleManager.cjSingleModeThreadList))) {
        pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);
        return;
    }
    pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);
    while (true) {
        // if TryRunCJSingleModeThread run for 10ms or 5 times or there are more higher priority tasks,
        // then stop it and trigger event handler func.
        if (g_scheduleManager.cjSingleModeThreadRetryTime.load() < MAX_RETRY_CJSINGLETHREAD_COUNT &&
            (CurrentNanotimeGet() - startTime > MAX_RUN_CJSINGLETHREAD_TIME ||
            runCount >= MAX_RUN_CJSINGLETHREAD_COUNT ||
            HasHigherPriorityTask == nullptr ? false : HasHigherPriorityTask())) {
            atomic_fetch_add(&g_scheduleManager.cjSingleModeThreadRetryTime, 1U);
            while (!PostTask(reinterpret_cast<void*>(TryRunCJSingleModeThread))) {}
            break;
        }
        
        g_scheduleManager.cjSingleModeThreadRetryTime.store(0);
        pthread_mutex_lock(&g_scheduleManager.cjSingleModeThreadListLock);
        struct Dulink* scheduleCJUIThreadNode = (&(g_scheduleManager.cjSingleModeThreadList))->prev;
        struct CJThread* cjthread = DULINK_ENTRY(scheduleCJUIThreadNode, struct CJThread, cjSingleModeThreadDulink);
        DulinkRemove(&(cjthread->cjSingleModeThreadDulink));
        pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);

        Schedule* schedule = cjthread->schedule;
        CJThreadSet(reinterpret_cast<CJThread*>(schedule->thread0->cjthread0));
        ScheduleSet(schedule);
        ScheduleGlobalWrite(&cjthread, 1);
        ProcessorWake(schedule, nullptr);
        ScheduleStartNoWait(0);
        runCount++;
        pthread_mutex_lock(&g_scheduleManager.cjSingleModeThreadListLock);
        if (DulinkIsEmpty(&(g_scheduleManager.cjSingleModeThreadList))) {
            pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);
            break;
        }
        pthread_mutex_unlock(&g_scheduleManager.cjSingleModeThreadListLock);
    }
}

void ScheduleAllCJThreadListRemove(struct CJThread *cjthread)
{
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DulinkRemove(&(cjthread->allCJThreadDulink));
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);

    // Cooperate with Cangjie GC to release the mutator.
    SchdDestructorHookFunc hook_func = g_scheduleManager.destructorFunc;
    if (hook_func != nullptr && cjthread->mutator) {
        hook_func(cjthread->mutator);
    }
}

/* When type is set to 1, the visited object is arg_start. When type is set to 0, the visited
 * object is mutator.
 */
void ScheduleAllCJThreadVisitImpl(AllCJThreadListProcFunc visitor, void *handle, int type)
{
    struct CJThread *cjthread;
    struct Dulink *scheduleCJThreadNode = nullptr;
    // This function is not invoked when the scheduler exits. Do not need to add lock.
    if (visitor == nullptr) {
        return;
    }
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    if (type == 1) {
        DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
            cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
            void *arg = cjthread->argStart;
            if (arg != nullptr) {
                visitor(arg, handle);
            }
        }
    } else {
        DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
            cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
            void *mutator = cjthread->mutator;
            if (cjthread->state != CJTHREAD_IDLE && mutator != nullptr) {
                visitor(mutator, handle);
            }
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);
}

unsigned long long ScheduleCJThreadCountPublic(CJthreadStatePublic state)
{
    struct CJThread *cjthread;
    struct Dulink *scheduleCJThreadNode = nullptr;
    unsigned long long cjthreadNum = 0;
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "allCJThreadList haven't init");
        return static_cast<unsigned long long>(-1);
    }

    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
        cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
        if (state == CJTHREAD_PSTATE_ALL && cjthread->state != CJTHREAD_IDLE) {
            cjthreadNum++;
        } else if (state == CJTHREAD_PSTATE_RUNNING &&
                   (cjthread->state == CJTHREAD_READY ||
                    cjthread->state == CJTHREAD_RUNNING || cjthread->state == CJTHREAD_SYSCALL)) {
            cjthreadNum++;
        } else if (state == CJTHREAD_PSTATE_BLOCKING && cjthread->state == CJTHREAD_PENDING) {
            cjthreadNum++;
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);

    return cjthreadNum;
}

/* Collects statistics on the number of running processors. */
unsigned int ScheduleRunningOSThreadCount(void)
{
    struct Schedule *schedule = ScheduleGet();
    struct Dulink *scheduleNode;
    unsigned int processorNum = 0;
    struct Processor *processor;
    unsigned int i;

    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "schedule is null");
        return -1;
    }

    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
            processor = &schedule->schdProcessor.processorGroup[i];
            processorNum = (processor->state == PROCESSOR_RUNNING) ? processorNum + 1 : processorNum;
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
    return processorNum;
}

void ScheduleAllCJThreadVisit(AllCJThreadListProcFunc visitor, void *handle)
{
    ScheduleAllCJThreadVisitImpl(visitor, handle, 1);
}

void ScheduleAllCJThreadVisitMutator(AllCJThreadListProcFunc visitor, void *handle)
{
    ScheduleAllCJThreadVisitImpl(visitor, handle, 0);
}

bool ScheduleAnyCJThreadOrTimer(void)
{
    struct Schedule *schedule;
    if (g_scheduleManager.defaultSchedule == nullptr) {
        return false;
    }
    struct CJThread *cjthread;
    struct Processor *processor;
    struct ScheduleGfreeList *gfreelist;
    bool flag = false;
    unsigned int i;
    struct Dulink *scheduleNode = nullptr;

    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        gfreelist = &schedule->schdCJThread.gfreelist;
        // Clear the global resource pool and local resource pool. This operation is performed
        // only when the scheduler is in Schedule_SUSPEND state.
        if (schedule->state != SCHEDULE_SUSPENDING) {
            continue;
        }
        while (1) {
            cjthread = ScheduleGfreelistGet(gfreelist);
            if (cjthread == nullptr) {
                break;
            }
            CJThreadFree(cjthread, false);
        }
        for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
            processor = &schedule->schdProcessor.processorGroup[i];
            cjthread = ProcessorFreelistGet(processor);
            while (cjthread != nullptr) {
                CJThreadFree(cjthread, false);
                cjthread = ProcessorFreelistGet(processor);
            }
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
    // After the local and global resource pools are cleared, cjthread_free will not be
    // reclaimed to the resource pool in the suspended state. If cjthread_num is 0, the
    // resource pool and existing cjthreads have ended and cannot be added.
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    if (!DulinkIsEmpty(&g_scheduleManager.allCJThreadList)) {
        flag = true;
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);
    if (g_timerHookFunc[ANY_TIMER_HOOK]() != 0) {
        flag = true;
    }
    return flag;
}

void ScheduleLockAll(void)
{
    struct Schedule *schedule;
    struct Processor *processor;
    unsigned int i;
    struct Dulink *scheduleNode;

    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    pthread_mutex_lock(&g_scheduleManager.allCJThreadListLock);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
            processor = &schedule->schdProcessor.processorGroup[i];
            PthreadSpinLock(&processor->lock);
        }
        pthread_mutex_lock(&schedule->schdCJThread.gfreelist.gfreeLock);
        pthread_mutex_lock(&schedule->netpoll.pollMutex);
    }
}

void ScheduleUnlockAll(void)
{
    struct Schedule *schedule;
    struct Processor *processor;
    unsigned int i;
    struct Dulink *scheduleNode;

    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        pthread_mutex_unlock(&schedule->netpoll.pollMutex);
        pthread_mutex_unlock(&schedule->schdCJThread.gfreelist.gfreeLock);
        for (i = 0; i < schedule->schdProcessor.processorNum; ++i) {
            processor = &schedule->schdProcessor.processorGroup[i];
            PthreadSpinUnlock(&processor->lock);
        }
    }
    pthread_mutex_unlock(&g_scheduleManager.allCJThreadListLock);
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
}

int ScheduleSuspend(void)
{
    struct Schedule *schedule;
    if (g_scheduleManager.defaultSchedule == nullptr) {
        LOG_ERROR(ERRNO_SCHED_SUSPEND_WHEN_NOT_RUNNING, "schedule is null");
        return -1;
    }
    ScheduleLockAll();

    ScheduleState value = SCHEDULE_RUNNING;
    struct Dulink *scheduleNode;

    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        /* After the scheduler status is marked as SCHEDULE_SUSPENDING, cjthreads will no
         * longer be reclaimed and will be released uniformly, and cjthreads cannot be added.
         * At this point, the concurrent cjthread_alloc can obtain free cjthreads, but after
         * clearing, it can no longer be obtained. The local free list has temporarily added
         * muetx to avoid concurrency with any_cjthread recycling, which needs to be optimized. */
        if (!atomic_compare_exchange_strong(&schedule->state, &value, SCHEDULE_SUSPENDING)) {
            value = SCHEDULE_RUNNING;
            scheduleNode = schedule->allScheduleDulink.prev;
            while (scheduleNode != &g_scheduleManager.allScheduleList) {
                schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
                atomic_store(&schedule->state, value);
                scheduleNode = schedule->allScheduleDulink.prev;
            }
            ScheduleUnlockAll();
            LOG_ERROR(ERRNO_SCHED_SUSPEND_WHEN_NOT_RUNNING, "suspend when schedule is not running");
            return -1;
        }
    }
    ScheduleUnlockAll();

    // clear cjthread free list.
    (void)ScheduleAnyCJThreadOrTimer();
    return 0;
}

int ScheduleResume(void)
{
    struct Schedule *schedule;
    if (g_scheduleManager.defaultSchedule == nullptr) {
        LOG_ERROR(ERRNO_SCHED_RESUME_WHEN_NOT_SUSPENDING, "schedule is null");
        return -1;
    }
    ScheduleLockAll();
    ScheduleState value = SCHEDULE_SUSPENDING;
    struct Dulink *scheduleNode;

    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        if (!atomic_compare_exchange_strong(&schedule->state, &value, SCHEDULE_RUNNING)) {
            value = SCHEDULE_SUSPENDING;
            scheduleNode = schedule->allScheduleDulink.prev;
            while (scheduleNode != &g_scheduleManager.allScheduleList) {
                schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
                atomic_store(&schedule->state, value);
                scheduleNode = schedule->allScheduleDulink.prev;
            }
            ScheduleUnlockAll();
            LOG_ERROR(ERRNO_SCHED_RESUME_WHEN_NOT_SUSPENDING, "resume when schedule is not suspending");
            return -1;
        }
    }
    ScheduleUnlockAll();

    return 0;
}

void SchedulePreemptCheck(void)
{
    struct CJThread *curCJThread;
    uintptr_t spAddress = -1;
    uintptr_t preemptFlag;

    curCJThread = CJThreadGet();
    if (curCJThread == nullptr) {
        return;
    }
#ifdef MRT_HARDWARE_PLATFORM

#if (MRT_HARDWARE_PLATFORM == MRT_ARM) && (VOS_WORDSIZE == 64)
    asm volatile (
    "mov %0, sp \n"
    :"=r"(spAddress)
    );
#endif

#if (MRT_HARDWARE_PLATFORM == MRT_ARM) && (VOS_WORDSIZE == 32)
    asm volatile (
    "mov %0, sp \n"
    :"=r"(spAddress)
    );
#endif

#if ((MRT_HARDWARE_PLATFORM == MRT_X86) || (MRT_HARDWARE_PLATFORM == MRT_WINDOWS_X86)) && (VOS_WORDSIZE == 64)
    asm volatile (
    "mov %%rsp, %0 \n"
    :"=r"(spAddress)
    );
#endif

#endif

    preemptFlag = PreemptFlagGet();
    if (spAddress <= preemptFlag) {
        CJThreadPreemptResched();
    }
}

bool ScheduleIsRunning(ScheduleHandle scheduleHandle)
{
    struct Schedule *schedule = (struct Schedule *)scheduleHandle;
    if (schedule == nullptr) {
        return false;
    }
    if (schedule->state == SCHEDULE_RUNNING) {
        return true;
    }

    return false;
}

void ScheduleSetToCurrentThread(ScheduleHandle schedule)
{
    ScheduleSet((struct Schedule *)schedule);
}

unsigned int ScheduleGetProcessorNum(void)
{
    unsigned int processorNum = 0;
    struct Schedule *schedule = g_scheduleManager.defaultSchedule;
    struct Dulink *scheduleNode;
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "default schedule is null");
        return 0;
    }

    pthread_mutex_lock(&g_scheduleManager.allScheduleListLock);
    DULINK_FOR_EACH_ITEM(scheduleNode, &g_scheduleManager.allScheduleList) {
        schedule = DULINK_ENTRY(scheduleNode, struct Schedule, allScheduleDulink);
        processorNum += schedule->schdProcessor.processorNum;
    }
    pthread_mutex_unlock(&g_scheduleManager.allScheduleListLock);
    return processorNum;
}

/* cjthread trace is open for linux or win. */
#if defined (MRT_LINUX) || defined (MRT_WINDOWS)
int ScheduleTraceDlclose(DlHandle dlHandle)
{
#ifdef MRT_WINDOWS
    return FreeLibrary(dlHandle);
#elif defined (MRT_LINUX)
    return dlclose(dlHandle);
#endif
}

#if defined (MRT_WINDOWS)
FARPROC ScheduleLoadTraceForWin(char* dlPath, DlHandle *dlHandlePtr)
{
    FARPROC traceRegister;
    *dlHandlePtr = LoadLibrary(dlPath);
    if (*dlHandlePtr == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "trace dlopen failed");
        return nullptr;
    }
    traceRegister= GetProcAddress(*dlHandlePtr, "CJ_TraceRegister");
    if (traceRegister == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "trace dlopen failed");
        ScheduleTraceDlclose(*dlHandlePtr);
        return nullptr;
    }
    return traceRegister;
}
#endif

#if defined (MRT_LINUX)
TraceRegisterFunc ScheduleLoadTrace(char* dlPath, DlHandle *dlHandlePtr)
{
    TraceRegisterFunc traceRegister;
    *dlHandlePtr = dlopen(dlPath, RTLD_LAZY);
    if (*dlHandlePtr == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, dlerror());
        return nullptr;
    }
    MapleRuntime::InitAddressScopeForCJthreadTrace();
    traceRegister = reinterpret_cast<TraceRegisterFunc>(dlsym(*dlHandlePtr, "CJ_TraceRegister"));
    if (traceRegister == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, dlerror());
        ScheduleTraceDlclose(*dlHandlePtr);
        return nullptr;
    }
    return traceRegister;
}
#endif

bool ScheduleStartTrace(unsigned short traceType)
{
    DlHandle dlHandle = nullptr;
    char dlPath[TRACE_PATH_LENGTH];
#ifdef MRT_WINDOWS
    char tracePathFormat[] = "%s\\runtime\\lib\\%s_cjnative\\libcangjie-trace.dll";
#elif defined (MRT_LINUX)
    char tracePathFormat[] = "%s/runtime/lib/%s_cjnative/libcangjie-trace.so";
#endif
    if (g_scheduleManager.trace.openType) {
        LOG_ERROR(ERRNO_SCHD_TRACE_ALREADY_START, "trace is already start");
        return false;
    }
    // Static memory is used and does not need to be manually released
    char *envCangjieHome = std::getenv("CANGJIE_HOME");
    if (envCangjieHome == nullptr) {
        LOG_ERROR(ERRNO_SCHD_GET_ENV_FAILED, "CANGJIE_HOME is not set");
        return false;
    }
    int ret = sprintf_s(dlPath, TRACE_PATH_LENGTH, tracePathFormat, envCangjieHome, TRACE_FOLDER_PREFIX);
    if (ret == -1) {
        LOG_ERROR(errno, "sprintf_s failed");
        return false;
    }
#ifdef MRT_WINDOWS
    FARPROC traceRegister = ScheduleLoadTraceForWin(dlPath, &dlHandle);
#elif defined (MRT_LINUX)
    TraceRegisterFunc traceRegister = ScheduleLoadTrace(dlPath, &dlHandle);
#endif
    if (traceRegister == nullptr) {
        return false;
    }
    traceRegister();
    if (g_scheduleManager.trace.hooks.traceStart == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "trace traceRegister failed");
        ScheduleTraceDlclose(dlHandle);
        return false;
    }
    bool result = g_scheduleManager.trace.hooks.traceStart(traceType);
    if (!result) {
        g_scheduleManager.trace.hooks.traceDeregister();
        ScheduleTraceDlclose(dlHandle);
        return false;
    }
    g_scheduleManager.trace.dlHandle = dlHandle;
    return true;
}

bool ScheduleStopTrace()
{
    bool result;
    if (g_scheduleManager.trace.hooks.traceStop == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "func not register");
        return false;
    }
    result = g_scheduleManager.trace.hooks.traceStop();
    if (!result) {
        return false;
    }
    ScheduleTraceDlclose(g_scheduleManager.trace.dlHandle);
    g_scheduleManager.trace.dlHandle = nullptr;
    return result;
}

unsigned char *ScheduleDumpTrace(int *len)
{
    if (g_scheduleManager.trace.hooks.traceDump == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "func not register");
        return nullptr;
    }
    return g_scheduleManager.trace.hooks.traceDump(len);
}

#else
bool ScheduleStartTrace(unsigned short traceType)
{
    (void)traceType;
    return false;
}

bool ScheduleStopTrace()
{
    return false;
}

unsigned char *ScheduleDumpTrace(int *len)
{
    (void)len;
    return nullptr;
}
#endif

struct CJThread *ScheduleGetTraceReader()
{
    if (g_scheduleManager.trace.hooks.traceReaderGet == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "func not register");
        return nullptr;
    }
    return g_scheduleManager.trace.hooks.traceReaderGet();
}

/* Entry function for recording trace events in schedule logic. */
void ScheduleTraceEventOrigin(TraceEvent event, int skip, struct CJThread *cjthread, int argNum, ...)
{
    va_list args;
    if (g_scheduleManager.trace.hooks.traceRecordEvent == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "func not register");
        return;
    }
    auto mutator = (cjthread == nullptr) ? nullptr : static_cast<void *>(cjthread->mutator);
    va_start(args, argNum);
    g_scheduleManager.trace.hooks.traceRecordEvent(event, skip, mutator, argNum, args);
    va_end(args);
}

void ScheduleTraceEvent(TraceEvent event, int skip, struct CJThread *cjthread, int argNum, ...)
{
    va_list args;
    if (!g_scheduleManager.trace.openType || !(g_scheduleManager.trace.openType & event)) {
        return;
    }
    if (g_scheduleManager.trace.hooks.traceRecordEvent == nullptr) {
        LOG_ERROR(ERRNO_SCHD_TRACE_DL_FAILED, "func not register");
        return;
    }
    auto mutator = (cjthread == nullptr) ? nullptr : static_cast<void *>(cjthread->mutator);
    va_start(args, argNum);
    g_scheduleManager.trace.hooks.traceRecordEvent(event, skip, mutator, argNum, args);
    va_end(args);
}

#ifdef __cplusplus
}
#endif
// The method is presented in c++ to implement cjthead functions of cjdb in debug mode.
unsigned long long CJ_MRT_GetCJThreadNumberUnsafe(void)
{
    unsigned long long cjthreadNum = 0;
    struct CJThread *cjthread;
    struct Dulink *scheduleCJThreadNode = nullptr;
    if (!g_scheduleManager.initFlag) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "allCJThreadList haven't init");
        return static_cast<unsigned long long>(-1);
    }

    DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
        cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
        if (cjthread->state != CJTHREAD_IDLE) {
            ++cjthreadNum;
        }
    }

    return cjthreadNum;
}

// The method is presented in c++ to implement cjthead functions of cjdb in debug mode.
// cjthreadBufPtr must be void*, cannot be uintptr or CJThreadInfo*.
int CJ_MRT_GetAllCJThreadInfo(void *cjthreadBufPtr, unsigned int num)
{
    unsigned int index = 0;
    struct Schedule *schedule;
    struct Dulink *scheduleCJThreadNode = nullptr;
    struct CJThread *cjthread;
    struct CJThreadInfo *cjthreadBuf = reinterpret_cast<struct CJThreadInfo *>(cjthreadBufPtr);

    schedule = ScheduleGet();
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "schedule is null");
        return 0;
    }

    if (CJThreadGet() == nullptr || cjthreadBuf == nullptr) {
        return 0;
    }
    DULINK_FOR_EACH_ITEM(scheduleCJThreadNode, &g_scheduleManager.allCJThreadList) {
        if (index == num) {
            break;
        }
        cjthread = DULINK_ENTRY(scheduleCJThreadNode, struct CJThread, allCJThreadDulink);
        if (cjthread->state == CJTHREAD_IDLE) {
            continue;
        }
        CJThreadGetInfo(cjthread, &(cjthreadBuf[index]));
        index++;
    }
    return index;
}

void CJForeignThreadExit(CJThreadHandle foreignThread)
{
    auto* foreignCJThread = reinterpret_cast<CJThread*>(foreignThread);
    Schedule* schedule = foreignCJThread->schedule;
    if (schedule->scheduleType != SCHEDULE_FOREIGN_THREAD) {
        LOG_FATAL(ERRNO_SCHD_WRONG_TYPE, "foreign cj thread has wrong scheduler");
    }
    MapleRuntime::Mutator* mutator = foreignCJThread->mutator;
    if (mutator != nullptr && mutator->IsForeignThread()) {
        mutator->ReleaseForeignThread();
    }
    ScheduleNonDefaultFree(schedule);
}

#ifdef __IOS__
MapleRuntime::CString GetThreadStateString(void *cjthreadPtr)
{
    if (cjthreadPtr == nullptr) {
        return MapleRuntime::CString();
    }
    struct CJThread *cjthread = static_cast<struct CJThread*>(cjthreadPtr);
    if (cjthread->state == CJTHREAD_IDLE) {
        return MapleRuntime::CString("idle");
    } else if (cjthread->state == CJTHREAD_READY) {
        return MapleRuntime::CString("ready");
    } else if (cjthread->state == CJTHREAD_RUNNING) {
        return MapleRuntime::CString("running");
    } else if (cjthread->state == CJTHREAD_PENDING) {
        return MapleRuntime::CString("pending");
    } else if (cjthread->state == CJTHREAD_SYSCALL) {
        return MapleRuntime::CString("syscall");
    } else {
        LOG_FATAL(ERRNO_SCHD_CJTHREAD_STATE_INVALID, "cjthread has wrong state");
    }
}

bool IsPendingThread(void *cjthreadPtr)
{
    if (cjthreadPtr == nullptr) {
        return false;
    }
    struct CJThread *cjthread = static_cast<struct CJThread*>(cjthreadPtr);
    return (cjthread->state == CJTHREAD_READY || cjthread->state == CJTHREAD_PENDING);
}

int CJ_MRT_GetAllCJThreadStackTrace(void *cjStackTraceBufPtr, unsigned int num)
{
    unsigned int recordCnt = 0;
    char *cjStackTraceBuffer = reinterpret_cast<char*>(cjStackTraceBufPtr);
    MapleRuntime::MutatorManager::Instance().VisitAllMutatorsExceptFinalizer(
        [&recordCnt, num, cjStackTraceBuffer](MapleRuntime::Mutator &mutator) {
            if (!mutator.IsVaildCJThread() || recordCnt == num ||
                !IsPendingThread(mutator.GetCjthreadPtr())) {
                return;
            }
            uint32_t threadId = static_cast<uint32_t>(mutator.GetCJThreadId());
            MapleRuntime::CString threadState = GetThreadStateString(mutator.GetCjthreadPtr());
            MapleRuntime::CString threadName;
            if (mutator.GetCJThreadName() != nullptr) {
                threadName = MapleRuntime::CString(mutator.GetCJThreadName());
            }
            MapleRuntime::CString get;
            get.Append(MapleRuntime::CString::FormatString("cjthread #%d state: %s name: %s\n",
                                                           threadId, threadState.Str(), threadName.Str()));
            MapleRuntime::PrintStackInfo printStackInfo(&(mutator.GetUnwindContext()));
            get.Append(printStackInfo.GetStackTraceString());
            snprintf_s(cjStackTraceBuffer + recordCnt * CJTHREAD_STACK_STRING_SIZE,
                       CJTHREAD_STACK_STRING_SIZE, CJTHREAD_STACK_STRING_SIZE - 1, "%s", get.Str());
            recordCnt++;
        }
    );
    return recordCnt;
}
#endif
