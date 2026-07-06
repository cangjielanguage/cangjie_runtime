// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <cstring>
#include <cerrno>
#include <csignal>
#include <unistd.h>
#include <cstdint>
#include "processor.h"
#include "schedule_impl.h"
#include "thread.h"
#include "log.h"
#include "securec.h"

#include "Mutator/Mutator.inline.h"

#include "cjthread.h"
#if defined(CANGJIE_SANITIZER_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

#ifndef MRT_WINDOWS
#include <sys/mman.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* attribute is used to optimize performance. When no attribute is added, call get_tls for
 * access. When attributes are added, use the fs register for access. */
#if !defined(TLS_SPEC_OFFSET) && !defined(TLS_COMMON_DYNAMIC)
__thread struct CJThread *g_cjthread __attribute__((tls_model("initial-exec"))) = nullptr;
__thread struct Schedule *g_schedule __attribute__((tls_model("initial-exec"))) = nullptr;
__thread uintptr_t g_preemptFlag __attribute__((tls_model("initial-exec"))) = 0;
__thread uintptr_t g_protectAddr __attribute__((tls_model("initial-exec"))) = 0;
#endif

/* Space reserved for stack overflow check */
uintptr_t g_cjthreadStackReservedSize = STACK_DEFAULT_REVERSED;

#if !defined(MRT_WINDOWS)
constexpr size_t HUGE_PAGE = 2UL * 1024 * 1024; // use mmap when stack size is beyond 2mb.
#endif

#ifdef MRT_WINDOWS
void CJThreadStackMemFree(struct CJThread *cjthread, char *stackTopAddr, size_t stackSize)
{
    char *stackFreeAddr;
    size_t pageSize;
    DWORD oldProt = 0;
    int error;

    if (stackTopAddr == nullptr) {
        return;
    }
    if (cjthread->schedule->schdCJThread.stackProtect == false) {
        stackFreeAddr = stackTopAddr;
        free(stackFreeAddr);
    } else {
        pageSize = SchedulePageSize();
        stackFreeAddr = stackTopAddr - pageSize;
        if (!VirtualProtect(stackFreeAddr, pageSize, PAGE_READWRITE, &oldProt)) {
            error = (int)GetLastError();
            LOG_ERROR(error, "VirtualProtect failed, page_size: %u", pageSize);
        }

        if (!VirtualFree(stackFreeAddr, 0, MEM_RELEASE)) {
            error = (int)GetLastError();
            LOG_ERROR(error, "VirtualFree failed, size: %u", stackSize);
        }
    }
}
#else
void StackMemFreeInternel(void* stackAddr, size_t stackSize)
{
    if (stackSize >= HUGE_PAGE) {
        munmap(stackAddr, stackSize);
    } else {
        free(stackAddr);
    }
}
void CJThreadStackMemFree(struct CJThread *cjthread, char *stackTopAddr, size_t stackSize)
{
    char *stackFreeAddr;
    size_t pageSize;
    int error;

    if (stackTopAddr == nullptr) {
        return;
    }
#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanFree(stackTopAddr, stackSize);
#endif
    if (cjthread->schedule->schdCJThread.stackProtect == false) {
        StackMemFreeInternel(stackTopAddr, stackSize);
    } else {
        pageSize = SchedulePageSize();
        stackFreeAddr = stackTopAddr - pageSize;
        error = mprotect(stackFreeAddr, pageSize, PROT_READ | PROT_WRITE);
        if (error) {
            HILOG_ERROR(errno, "mprotect failed in CJThreadStackMemFree. size is %u", pageSize);
        }
        error = munmap(stackFreeAddr, stackSize + pageSize);
        if (error) {
            HILOG_ERROR(errno, "munmap failed in CJThreadStackMemFree. size is %u", stackSize + pageSize);
        }
    }
}
#endif

void CJThreadMemFree(struct CJThread *cjthread)
{
    CJThreadStackMemFree(cjthread, cjthread->stack.stackTopAddr, cjthread->stack.stackSize);
    free(cjthread);
}

/* Put cjthread to free list or free cjthread */
void CJThreadFree(struct CJThread *cjthread, bool reuse)
{
    struct Processor *processor;
    struct ScheduleCJThread *scheduleCJThread;
    struct ScheduleGfreeList *gfreelist;
    struct Schedule *targetSchedule = cjthread->schedule;
    struct Schedule *schedule = ScheduleGet();

    if (reuse && (schedule == nullptr || targetSchedule == nullptr)) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "schedule not inited");
        return;
    }
#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanDeleteRaceState(cjthread);
#endif
    scheduleCJThread = &(targetSchedule->schdCJThread);
    if (reuse && cjthread->stack.stackSize == scheduleCJThread->stackSize) {
        if (targetSchedule != schedule) {
            gfreelist = &targetSchedule->schdCJThread.gfreelist;
            pthread_mutex_lock(&gfreelist->gfreeLock);
            ScheduleGfreelistPush(gfreelist, cjthread);
            pthread_mutex_unlock(&gfreelist->gfreeLock);
        } else {
            processor = ProcessorGet();
            ProcessorFreelistPut(processor, cjthread);
        }
    } else {
        ScheduleAllCJThreadListRemove(cjthread);
        CJThreadMemFree(cjthread);
    }
}

/* Obtain the cjthread ID in atomic mode. The reentrant lock of the warehouse lock determines
 * whether it is the same cjthread based on cjthreadId. In multi-scheduler scenarios, the
 * unified global variable is used to obtain cjthreadId.
 **/
unsigned long long CJThreadNewId(void)
{
    return atomic_fetch_add(&g_scheduleManager.cjthreadIdGen, 1llu);
}

MRT_STATIC_INLINE int CJThreadInit(struct CJThread *newCJThread, struct ArgAttr *argAttr)
{
    int error;
    char *argBuffer;
    newCJThread->argSize = argAttr->argSize;
    if (argAttr->argStart != nullptr) {
        argBuffer = (char *)newCJThread + sizeof(struct CJThread);
        // Check CJThreadAttrCheck and ensure that argSize <= COARGS_SIZE_MAX. does not
        // cause memory corruption.
        error = memcpy_s(argBuffer, argAttr->argSize, argAttr->argStart, argAttr->argSize);
        if (error) {
            HILOG_ERROR(error, "memcpy cjthread args failed when init cjthread");
            return error;
        }
        newCJThread->argStart = argBuffer;
    } else {
        newCJThread->argStart = nullptr;
    }

    newCJThread->boundThread = nullptr;
    DulinkInit(&(newCJThread->schdDulink));
    atomic_store_explicit(&newCJThread->state, CJTHREAD_IDLE, std::memory_order_relaxed);
    newCJThread->name[0] = '\0';

    return 0;
}

/* Init cjthread_stack related attributes */
MRT_STATIC_INLINE void CJThreadStackAttrInit(struct CJThread *cjthread, size_t totalSize,
                                             char *stackAddr, struct StackAttr *stackAttr)
{
    cjthread->stack.totalSize = totalSize;
    cjthread->stack.stackTopAddr = stackAddr;

    // Reserve a part of the stack size to handle stack overflow.
    cjthread->stack.stackGuard = stackAddr + g_cjthreadStackReservedSize;
    cjthread->stack.stackBaseAddr = stackAddr + stackAttr->stackSizeAlign;
    cjthread->stack.stackSize = stackAttr->stackSizeAlign;
    // 16-byte-aligned. Note that the 64 KB lower stack address is not 0x0 - 0x100000000,
    // but 0x0 - 0xffffff, and the 16 bytes are aligned to 0x0 - 0xfffffff0. The stack
    // address must be 16-byte aligned. Otherwise, an error occurs.
    cjthread->stack.cjthreadStackBaseAddr = (char *)STACK_ADDR_ALIGN_DOWN(
        stackAddr + stackAttr->stackSizeAlign, CJTHREAD_ARG_ALIGN);
#ifdef CANGJIE_SANITIZER_SUPPORT
    // reserve space for sanitizer thread-local variables
    cjthread->stack.cjthreadStackBaseAddr -= CJTHREAD_SANITIZER_CONTEXT_OFFSET;
#endif
    cjthread->stack.stackGrowCnt = stackAttr->stackGrow ? 0 : 1;
}

/* low address----------------------------------high address
* -------------------------------------------
* |                  |                      |
* | cjthread struct |  copy arg(32Bytes)    |
* |                  |                      |
* -------------------------------------------
*/
struct CJThread *CJThreadAndArgsMemAlloc()
{
    int error;
    void *ptr;
    struct CJThread *cjthread;
    size_t corouSize;
    size_t totalSize;

    corouSize = sizeof(struct CJThread);
    totalSize = corouSize + COARGS_SIZE_MAX;

    ptr = malloc(totalSize);
    if (ptr == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED, "cjthread malloc failed, error %d", errno);
        return nullptr;
    }

    cjthread = (struct CJThread *)ptr;
    error = memset_s(cjthread, corouSize, 0, corouSize);
    if (error) {
        free(ptr);
        HILOG_ERROR(error, "cjthread memset_s failed");
        return nullptr;
    }
    return cjthread;
}

#ifdef MRT_WINDOWS
char *CJThreadStackMemAlloc(struct Schedule *schedule, struct CJThread *cjthread,
                            size_t stackSizeAlign, size_t *totalSize)
{
    size_t pageSize;
    char *addr;
    char *stackAddr;
    DWORD oldProt = 0;
    int error;

    if (schedule->schdCJThread.stackProtect == false) {
        /* low address------------high address
        * ----------------------
        * |                    |
        * |   cjthread stack   |
        * |                    |
        * ----------------------
        */
        *totalSize = stackSizeAlign;
        stackAddr = static_cast<char *>(malloc(*totalSize));
        if (stackAddr == nullptr) {
            HILOG_FATAL(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED, "alloc stack failed,  os memory is not enough size is %zu",
                        *totalSize);
            return nullptr;
        }
        cjthread->stack.protectAddr = 0;
    } else {
        /* low address--------------------------------high address
        * -----------------------------------------
        * |              |                        |
        * | protect page |      cjthread stack    |
        * |              |                        |
        * ------------------------------------------
        */

        pageSize = SchedulePageSize();
        *totalSize = pageSize + stackSizeAlign;
        addr = static_cast<char *>(VirtualAlloc(nullptr, *totalSize,
                                                MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE));
        if (addr == nullptr) {
            error = (int)GetLastError();
            HILOG_FATAL(error, "allocate cj stack failed because the os memory is not enough, size is %u", *totalSize);
            return nullptr;
        }
        if (!VirtualProtect(addr, pageSize, PAGE_NOACCESS, &oldProt)) {
            error = (int)GetLastError();
            LOG_ERROR(error, "VirtualProtect failed, page_size: %u", pageSize);
            if (!VirtualFree(addr, 0, MEM_RELEASE)) {
                error = (int)GetLastError();
                LOG_ERROR(error, "VirtualFree failed, size: %u", *totalSize);
            }
            return nullptr;
        }
        cjthread->stack.protectAddr = addr;
        stackAddr = addr + pageSize;
    }

    return stackAddr;
}
#else
static char* StackMemAllocInternal(size_t allocSize)
{
    if (allocSize >= HUGE_PAGE) {
        void* stackAddr = mmap(nullptr, allocSize, PROT_READ | PROT_WRITE,
                               MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (stackAddr == MAP_FAILED) {
            HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED,
                        "allocate cjthread stack with huge page failed, error %d", errno);
            return nullptr;
        }
#ifdef CANGJIE_HWASAN_SUPPORT
        stackAddr =
            reinterpret_cast<char*>(MapleRuntime::Sanitizer::UntagAddr(reinterpret_cast<uintptr_t>(stackAddr)));
#endif
#if defined (__linux__) || defined(__OHOS__) || defined(__ANDROID__)
        (void)madvise(stackAddr, allocSize, MADV_NOHUGEPAGE);
        MRT_PRCTL(stackAddr, allocSize, "cj-stack");
#endif
        return static_cast<char*>(stackAddr);
    } else {
        char* stackAddr = static_cast<char*>(malloc(allocSize));
        if (stackAddr == nullptr) {
            HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED, "allocate cjthread stack failed, error %d", errno);
            return nullptr;
        }
#ifdef CANGJIE_HWASAN_SUPPORT
        stackAddr =
            reinterpret_cast<char*>(MapleRuntime::Sanitizer::UntagAddr(reinterpret_cast<uintptr_t>(stackAddr)));
#endif
        return stackAddr;
    }
}
char *CJThreadStackMemAlloc(struct Schedule *schedule, struct CJThread *cjthread,
                            size_t stackSizeAlign, size_t *totalSize)
{
    size_t pageSize;
    char *addr;
    char *stackAddr;
    int error;

    if (schedule->schdCJThread.stackProtect == false) {
        /* low address------------high address
        * ----------------------
        * |                    |
        * |   cjthread stack   |
        * |                    |
        * ----------------------
        */
       *totalSize = stackSizeAlign;
        stackAddr = StackMemAllocInternal(*totalSize);
        if (stackAddr == nullptr) {
            return nullptr;
        }
        cjthread->stack.protectAddr = 0;
    } else {
        /* low address--------------------------------high address
        * -----------------------------------------
        * |              |                        |
        * | protect page |      cjthread stack    |
        * |              |                        |
        * ------------------------------------------
        */
        pageSize = SchedulePageSize();
        *totalSize = pageSize + stackSizeAlign;
        addr = (char *)mmap(nullptr, *totalSize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (addr == MAP_FAILED) {
            HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED,
                        "cjthread stack mmap failed, size %u, error %d", *totalSize, errno);
            return nullptr;
        }
#if defined (__linux__) || defined(__OHOS__) || defined(__ANDROID__)
        MRT_PRCTL(addr, *totalSize, "cj-stack");
#endif
#ifdef CANGJIE_HWASAN_SUPPORT
        addr = reinterpret_cast<char*>(MapleRuntime::Sanitizer::UntagAddr(reinterpret_cast<uintptr_t>(addr)));
#endif
        // The stack protection area is set to unreadable and non writable
        error = mprotect(addr, pageSize, PROT_NONE);
        if (error) {
            HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED,
                        "cjthread stack mprotect failed, page_size %u, error %d", pageSize, errno);
            munmap(addr, *totalSize);
            return nullptr;
        }
        cjthread->stack.protectAddr = addr;
        stackAddr = addr + pageSize;
    }

#ifdef CANGJIE_HWASAN_SUPPORT
        MapleRuntime::Sanitizer::UntagMemory(reinterpret_cast<void*>(stackAddr), stackSizeAlign);
#endif
    return stackAddr;
}
#endif

/* stackSizeAlign ensures page alignment before passing in */
struct CJThread *CJThreadMemAlloc(struct Schedule *schedule, struct StackAttr *stackAttr)
{
    size_t totalSize;
    char *stackAddr;
    struct CJThread *cjthread;

    // Allocate structure memory and args memory of CJThread.
    cjthread = CJThreadAndArgsMemAlloc();
    if (cjthread == nullptr) {
        return nullptr;
    }
    // for SCHEDULE_EXCLUSIVE cjthread to use osthread
    if (schedule->scheduleType == SCHEDULE_FOREIGN_THREAD || schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        // should not create new stack when cj thread is created by foreign thread.
        CJThreadStackAttrInit(cjthread, 0, nullptr, stackAttr);
    } else {
        // Allocate stack memeory of CJThread.
        stackAddr = CJThreadStackMemAlloc(schedule, cjthread, stackAttr->stackSizeAlign, &totalSize);
        if (stackAddr == nullptr) {
            free(cjthread);
            return nullptr;
        }
        // Init cjthread stack attributes.
        CJThreadStackAttrInit(cjthread, totalSize, stackAddr, stackAttr);
    }

    // Initializes the global management linked list node for the cjthread that newly
    // applies for memory.
    DulinkInit(&(cjthread->allCJThreadDulink));
    DulinkInit(&(cjthread->cjSingleModeThreadDulink));

    return cjthread;
}

/* Alloc CJThread. */
struct CJThread *CJThreadAlloc(struct Schedule *schedule, struct ArgAttr *argAttr,
                               struct StackAttr *stackAttr, CJThreadBuf coBuf,
                               CJThreadCreateSource createSource)
{
    int error;
    struct CJThread *newCJThread = nullptr;
    struct ScheduleCJThread *scheduleCJThread = &(schedule->schdCJThread);
    bool addToList = false;

    if (stackAttr->stackSizeAlign == schedule->schdCJThread.stackSize && coBuf == LOCAL_BUF) {
        newCJThread = ProcessorFreelistGet(ProcessorGet());
    } else if (stackAttr->stackSizeAlign == schedule->schdCJThread.stackSize && coBuf == GLOBAL_BUF) {
        newCJThread = ScheduleGfreelistGet(&scheduleCJThread->gfreelist);
    }
    if (newCJThread == nullptr) {
        newCJThread = CJThreadMemAlloc(schedule, stackAttr);
        addToList = (coBuf != NO_BUF) ? true : false;
    }
    if (newCJThread == nullptr) {
        HILOG_ERROR(errno, "cjthread memory alloc failed");
        return nullptr;
    }

    newCJThread->schedule = schedule;

    error = CJThreadInit(newCJThread, argAttr);
    if (error) {
        HILOG_ERROR(error, "cjthread init failed");
        CJThreadFree(newCJThread, coBuf);
        return nullptr;
    }

    if (coBuf == NO_BUF) {
        newCJThread->id = 0;
        newCJThread->isCJThread0 = true;
    } else {
        newCJThread->id = CJTHREAD_INIT_ID;
        newCJThread->isCJThread0 = false;
        // co_buf is used to determine whether cjthread0 is used. cjthread0 is not put
        // in the list.
        if (addToList) {
            if (ScheduleAllCJThreadListAdd(newCJThread, createSource) != 0) {
                CJThreadMemFree(newCJThread);
                return nullptr;
            }
        }
    }
    return newCJThread;
}

/* CJThreadMexit */
void *CJThreadMexit(struct CJThread *delCJThread)
{
    unsigned long long cjthreadId = delCJThread->id;
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXEC, cjthreadId);
    TRACE_START_ASYNC(TRACE_CJTHREAD_EXIT, cjthreadId);
#elif defined (__ANDROID__)
    TRACE_FINISH();
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXIT, cjthreadId));
#endif
    struct Schedule *schedule = delCJThread->schedule;
    struct ScheduleCJThread *scheduleCJThread = &schedule->schdCJThread;
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(CJThreadGet());
#endif

    delCJThread->argStart = nullptr;
    atomic_store_explicit(&delCJThread->state, CJTHREAD_IDLE, std::memory_order_relaxed);
    CJThreadKeysClean(delCJThread);
    // Non-default scheduler waits for CJThreadNum == 0 on exit to ensure normal execution
    // of CJThreadFree
    CJThreadFree(delCJThread, true);
    if (schedule->scheduleType != SCHEDULE_DEFAULT) {
        atomic_fetch_sub(&scheduleCJThread->cjthreadNum, 1ULL);
    }
    
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXIT, cjthreadId);
#elif defined (__ANDROID__)
    TRACE_FINISH();
#else
    (void)cjthreadId;
#endif
    // The special stackid of the event is set through hardcode.
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_END)) {
        ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_END, -1, nullptr, 1, SpecialStackId::CJTHREAD_EXIT);
    }
    // This function does not return, get the next cjthread run
    ProcessorSchedule();

    return nullptr;
}

MRT_STATIC_INLINE void CJThreadExit(void)
{
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(CJThreadGet(), ThreadGet()->cjthread0);
#endif
    CJThreadMcallNosave(reinterpret_cast<void *>(CJThreadMexit), CJThreadAddr());
}

void *CJThreadEntry(struct CJThread *cjthread)
{
#ifdef __OHOS__
    PushUIThreadStackTop(GetThreadStackTop());
#endif
    // execute cjtrhead task
    cjthread->func(cjthread->argStart, cjthread->argSize);
#ifdef __OHOS__
    PopUIThreadStackTop();
#endif
    // cjthread exit. Switch cjthread to cjthread0, release cjthread and switch the next
    CJThreadExit();

    // Shouldn't be done here
    return nullptr;
}

#if defined(__OHOS__)
unsigned long long GetThreadStackTop()
{
    Schedule* schedule = ScheduleGet();
    if (schedule == nullptr || schedule->scheduleType != SCHEDULE_UI_THREAD) {
        return 0;
    }
    Thread* thread = ThreadGet();
    if (thread == nullptr) {
        return 0;
    }
#if defined(__aarch64__)
    return thread->context.sp;
#elif defined(__x86_64__)
    return thread->context.rsp;
#else
    return 0;
#endif
}

unsigned long long GetUIThreadStackTop()
{
    bool runtimeFinished = MapleRuntime::MRT_CheckRuntimeFinished();
    if (runtimeFinished) {
        return 0;
    }
    Schedule* schedule = ScheduleGet();
    if (schedule == nullptr || schedule->scheduleType != SCHEDULE_UI_THREAD) {
        return 0;
    }
    CJThread* cjthread = CJThreadGet();
    if (cjthread == nullptr || cjthread->threadStackTopList.size() == 0) {
        return 0;
    }
    unsigned long long res = cjthread->threadStackTopList.back();
    return res;
}

void PopUIThreadStackTop()
{
    bool runtimeFinished = MapleRuntime::MRT_CheckRuntimeFinished();
    if (runtimeFinished) {
        return;
    }
    Schedule* schedule = ScheduleGet();
    if (schedule == nullptr || schedule->scheduleType != SCHEDULE_UI_THREAD) {
        return;
    }
    CJThread* cjthread = CJThreadGet();
    if (cjthread == nullptr || cjthread->threadStackTopList.size() == 0) {
        return;
    }
    cjthread->threadStackTopList.pop_back();
}

void PushUIThreadStackTop(unsigned long long stackTop)
{
    bool runtimeFinished = MapleRuntime::MRT_CheckRuntimeFinished();
    if (runtimeFinished) {
        return;
    }
    Schedule* schedule = ScheduleGet();
    if (schedule == nullptr || schedule->scheduleType != SCHEDULE_UI_THREAD) {
        return;
    }
    CJThread* cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return;
    }
    cjthread->threadStackTopList.push_back(stackTop);
}
#endif

/* Creating a cjthread directly from C side without going through Cangjie requires initializing the mutator */
void *CJThreadEntryInitMutator(struct CJThread *cjthread)
{
    SchdCJThreadHookFunc hook_func;

    // mutator need to be initialized before running the cjthread task
    hook_func = g_scheduleManager.schdCJThreadHook[SCHD_CREATE_MUTATOR];
    if (hook_func != nullptr) {
        hook_func();
    }

    // execute cjtrhead task
    cjthread->func(cjthread->argStart, cjthread->argSize);

    hook_func = g_scheduleManager.schdCJThreadHook[SCHD_DESTROY_MUTATOR];
    if (hook_func != nullptr) {
        hook_func();
    }

    CJThreadExit();

    return nullptr;
}

#ifdef MRT_WINDOWS
/*
 * Initializes the GS register. gsStackLow and gsStackDeallocation are initialized to 0,
 * indicating that stack overflow check of Windows is disabled.
 */
static void GsStackContextInit(struct CJThread *newCJThread)
{
    newCJThread->context.gsStackHigh = (unsigned long long)newCJThread->stack.stackBaseAddr;
    newCJThread->context.gsStackLow = 0;
    newCJThread->context.gsStackDeallocation = 0;
}
#endif

/* Generate the context of cjthread. */
MRT_STATIC_INLINE void CJThreadMake(const struct CJThreadAttrInner *attr,
                                    CJThreadFunc func, struct CJThread *newCJThread)
{
    newCJThread->func = func;
    (void)memset_s(&newCJThread->context, sizeof(struct CJThreadContext), 0, sizeof(struct CJThreadContext));

    // foreign thread schedule do not create new stack and not need to init cjthread context.
    if (newCJThread->schedule->scheduleType == SCHEDULE_FOREIGN_THREAD ||
        newCJThread->schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return;
    }
    if (attr != nullptr && attr->cjFromC) {
        CJThreadContextInit(&newCJThread->context, reinterpret_cast<void *>(CJThreadEntryInitMutator),
                            newCJThread->stack.cjthreadStackBaseAddr);
    } else {
        // Initialize the SP, PC, and floating-point environments. Note that rbp must be set
        // to 0 in x86 and lr must be set to 0 in ARM64.
        CJThreadContextInit(&newCJThread->context, reinterpret_cast<void *>(CJThreadEntry),
                            newCJThread->stack.cjthreadStackBaseAddr);
    }
#ifdef MRT_WINDOWS
    GsStackContextInit(newCJThread);
#endif
}

/* The floating-point environment of cjthread0 is initialized only once. */
void CJThread0Make(struct CJThread *cjthread0)
{
    // foreign thread schedule do not create new stack and not need to init cjthread context.
    if (cjthread0->schedule->scheduleType == SCHEDULE_FOREIGN_THREAD ||
        cjthread0->schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return;
    }
    CJThreadContextInit(&cjthread0->context, nullptr, cjthread0->stack.cjthreadStackBaseAddr);
#ifdef MRT_WINDOWS
    GsStackContextInit(cjthread0);
#endif
}

void CJThreadAttrInit(struct CJThreadAttr *attrUser)
{
    struct CJThreadAttrInner *attr = reinterpret_cast<struct CJThreadAttrInner *>(attrUser);

    if (attrUser == nullptr) {
        return;
    }

    attr->stackSize = 0;
    attr->named = false;

    attr->cjFromC = false;
    attr->hasSpecificData = false;
}

int CJThreadAttrNameSet(struct CJThreadAttr *attrUser, const char *name)
{
    struct CJThreadAttrInner *attr = reinterpret_cast<struct CJThreadAttrInner *>(attrUser);
    int ret;

    if (attrUser == nullptr || name == nullptr) {
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }

    ret = strcpy_s(attr->name, CJTHREAD_NAME_SIZE, name);
    if (ret != 0) {
        return ret;
    }
    attr->named = true;
    return 0;
}

void CJThreadAttrStackSizeSet(struct CJThreadAttr *attrUser, unsigned int size)
{
    struct CJThreadAttrInner *attr = reinterpret_cast<struct CJThreadAttrInner *>(attrUser);
    if (attrUser == nullptr) {
        return;
    }
    attr->stackSize = size;
}

void CJThreadAttrCjFromCSet(struct CJThreadAttr *attrUser, bool flag)
{
    struct CJThreadAttrInner *attr = reinterpret_cast<struct CJThreadAttrInner *>(attrUser);
    if (attrUser == nullptr) {
        return;
    }
    attr->cjFromC = flag;
}

/* Set the relevant parameters of the cjthread local variable. */
int CJThreadAttrSpecificSet(struct CJThreadAttr *attrUser, unsigned int num,
                            struct CJThreadSpecificDataInner *data)
{
    struct CJThreadAttrInner *attr = reinterpret_cast<struct CJThreadAttrInner *>(attrUser);
    if (num > CJTHREAD_KEYS_MAX) {
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    if (num == 0) {
        return 0;
    }
    if (attrUser == nullptr || data == nullptr) {
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    int res = memset_s(attr->specificData, CJTHREAD_KEYS_MAX * sizeof(void *), 0,
                       CJTHREAD_KEYS_MAX * sizeof(void *));
    if (res != 0) {
        return res;
    }
    for (unsigned int i = 0; i < num; ++i) {
        if (data[i].key >= CJTHREAD_KEYS_MAX) {
            return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
        }
        attr->specificData[data[i].key] = data[i].value;
    }
    attr->hasSpecificData = true;
    return 0;
}

MRT_STATIC_INLINE int CJThreadAttrCheck(const struct CJThreadAttrInner *attr, CJThreadFunc func,
                                        const void *argStart, unsigned int argSize)
{
    if (func == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "CJThreadFunc is nullptr");
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    if ((argStart != nullptr && argSize == 0) || (argStart == nullptr && argSize != 0)) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "argStart is %s, size is %d",
                    argStart == nullptr ? "nullptr" : "not nullptr", argSize);
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }

    if (attr != nullptr) {
        if (attr->stackSize > CJTHREAD_MAX_STACK_SIZE) {
            HILOG_ERROR(ERRNO_SCHD_CJTHREAD_STACK_SIZE_INVALID, "attr stack size is %lu, max is %lu",
                        attr->stackSize, CJTHREAD_MAX_STACK_SIZE);
            return ERRNO_SCHD_CJTHREAD_STACK_SIZE_INVALID;
        }
    }

    if (argSize > COARGS_SIZE_MAX) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "argSize is %u, max is %u",
                    argSize, COARGS_SIZE_MAX);
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    return 0;
}

/* Set local variables in cjthread through attr. */
MRT_STATIC_INLINE void CJThreadNewSetLocalData(struct CJThread *cjthread, const struct CJThreadAttrInner *attr)
{
    if (attr == nullptr || attr->hasSpecificData == false) {
        return;
    }
    (void)memcpy_s(cjthread->localData, CJTHREAD_KEYS_MAX * sizeof(void *),
                   attr->specificData, CJTHREAD_KEYS_MAX * sizeof(void *));
}

/* Set stack info in cjthread through attr. */
MRT_INLINE static void CJThreadNewSetAttr(const struct CJThreadAttrInner *attr,
                                          struct ScheduleCJThread *scheduleCJThread,
                                          struct StackAttr *stackAttr)
{
    stackAttr->stackSizeAlign = scheduleCJThread->stackSize;
    stackAttr->stackGrow = scheduleCJThread->stackGrow;
    if (attr != nullptr) {
        if (attr->stackSize != 0) {
            // stacksize page alignment
            stackAttr->stackSizeAlign = STACK_ADDR_ALIGN_UP(attr->stackSize, SchedulePageSize());
        }
    }
}

struct CJThread* CJThreadBuild(ScheduleHandle schedule, const struct CJThreadAttr *attrUser, CJThreadFunc func,
                               const void *argStart, unsigned int argSize, CJThreadCreateSource createSource)
{
    struct StackAttr stackAttr;
    struct CJThread *newCJThread;
    struct Schedule *currentSchedule;
    struct Schedule *targetSchedule = (struct Schedule *)schedule;
    struct ArgAttr argAttr;
    struct ScheduleCJThread *scheduleCJThread;
    const struct CJThreadAttrInner *attr = reinterpret_cast<const struct CJThreadAttrInner *>(attrUser);

    currentSchedule = ScheduleGet();
    argAttr.argStart = argStart;
    argAttr.argSize = argSize;
    if (targetSchedule == nullptr || (targetSchedule->scheduleType != SCHEDULE_DEFAULT &&
                                   targetSchedule->state == SCHEDULE_WAITING)) {
        HILOG_ERROR(ERRNO_SCHD_INVALID, "can't new cjthread because schedule state is waiting");
        return nullptr;
    }
    scheduleCJThread = &targetSchedule->schdCJThread;
    if (CJThreadAttrCheck(attr, func, argStart, argSize) != 0) {
        return nullptr;
    }

    // Set stack info in cjthread through attr or default value
    CJThreadNewSetAttr(attr, scheduleCJThread, &stackAttr);
    // Method of obtaining the cjthread control block
    CJThreadBuf buf =
        (CJThreadGet() == nullptr || currentSchedule != targetSchedule ||
         createSource == CJTHREAD_CREATE_SOURCE_SIGNAL) ? GLOBAL_BUF : LOCAL_BUF;

    // scheduleCJThread increases by 1. The count is calculated when the cjthread upper limit
    // exists. The count is mandatory for a non-default scheduler. The count is used to
    // determine whether a cjthread is being executed when the scheduler exits.
    if (targetSchedule->scheduleType != SCHEDULE_DEFAULT) {
        atomic_fetch_add(&scheduleCJThread->cjthreadNum, 1ULL);
    }
    newCJThread = CJThreadAlloc(targetSchedule, &argAttr, &stackAttr, buf, createSource);
    if (newCJThread == nullptr) {
        if (targetSchedule->scheduleType != SCHEDULE_DEFAULT) {
            atomic_fetch_sub(&scheduleCJThread->cjthreadNum, 1ULL);
        }
        return nullptr;
    }

    CJThreadNewSetLocalData(newCJThread, attr);

#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanNewRaceState(newCJThread, CJThreadGet(), __builtin_return_address(0));
    MapleRuntime::Sanitizer::TsanCleanShadow(newCJThread->stack.stackTopAddr, newCJThread->stack.totalSize);
#endif

    CJThreadMake(attr, func, newCJThread);

    atomic_store_explicit(&newCJThread->state, CJTHREAD_READY, std::memory_order_relaxed);

    return newCJThread;
}

void ExclusiveExecutor(struct Thread* thread, struct CJThread* newCJThread)
{
    // Save old scheduler and processor before switching
    struct Schedule* newSchedule = newCJThread->schedule;
    thread->cjthread = newCJThread;
    newCJThread->thread = thread;
    // Temporarily switch thread->processor to EXCLUSIVE processor for timer wake to work
    struct Processor* exclusiveProcessor = &newSchedule->schdProcessor.processorGroup[0];
    thread->processor = exclusiveProcessor;
    // Switch to new scheduler
    ScheduleSet(newSchedule);
    CJThreadSet(newCJThread);
    MapleRuntime::ThreadLocal::SetProtectAddr(nullptr);
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
    MapleRuntime::ThreadLocalData* tlData = reinterpret_cast<MapleRuntime::ThreadLocalData*>(threadData);
    tlData->cjthread = reinterpret_cast<uint8_t*>(newCJThread);
    MapleRuntime::Mutator* mutator = newCJThread->mutator;
    tlData->SetMutator(mutator);
    mutator->PreparedToRun(tlData);
#if defined(__ANDROID__)
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, CJThreadGetId(newCJThread)));
#endif
    newCJThread->func(newCJThread->argStart, newCJThread->argSize);
    return;
}

// Called from ExclusiveScope.S assembly to avoid hardcoding of thread context offset,
//  which differs across platforms due to sizeof(sem_t)
void* ExclusiveGetThreadContext(struct Thread* thread)
{
    if (thread == nullptr) {
        LOG(RTLOG_ERROR, "ExclusiveGetThreadContext received null thread.");
        return nullptr;
    }
    return static_cast<void*>(&thread->context);
}

int IsExclusiveCJThread(struct CJThread* cjthread)
{
    if (cjthread == nullptr || cjthread->schedule == nullptr) {
        return 0;
    }
    return cjthread->schedule->scheduleType == SCHEDULE_EXCLUSIVE ? 1 : 0;
}

// ExclusiveRestore restore from exclusive cjthread
void ExclusiveRestore(struct CJThread* oldCJThread, struct Thread* thread,
                      struct CJThread* newCJThread, struct Processor* oldProcessor)
{
    if (oldCJThread == nullptr || thread == nullptr || newCJThread == nullptr || oldProcessor == nullptr) {
        LOG(RTLOG_ERROR, "ExclusiveRestore received null parameter. oldCJThread=%p, thread=%p, newCJThread=%p, oldProcessor=%p",
            oldCJThread, thread, newCJThread, oldProcessor);
        return;
    }

    struct Schedule* oldSchedule = oldCJThread->schedule;
    struct Schedule* newSchedule = newCJThread->schedule;

    if (oldSchedule == nullptr || newSchedule == nullptr) {
        LOG(RTLOG_ERROR, "ExclusiveRestore: invalid schedule detected. oldSchedule=%p, newSchedule=%p",
            oldSchedule, newSchedule);
        return;
    }

    // Get saved values
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
    MapleRuntime::ThreadLocalData* tlData = reinterpret_cast<MapleRuntime::ThreadLocalData*>(threadData);

    // Restore thread's original processor (passed from assembly)
    thread->processor = oldProcessor;
    oldProcessor->thread = thread;

    // Restore TLS
    ScheduleSet(oldSchedule);
    CJThreadSet(oldCJThread);

    // Restore thread data
    thread->cjthread = oldCJThread;
    tlData->SetMutator(oldCJThread->mutator);
    ProtectAddrSet(reinterpret_cast<uintptr_t>(oldCJThread->stack.stackGuard));

#if defined(__ANDROID__)
    TRACE_FINISH();
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXIT, CJThreadGetId(newCJThread)));
#endif
    // Free cjthread and scheduler
    ScheduleAllCJThreadListRemove(newCJThread);
    free(newCJThread);
    ExclusiveScheduleFree(newSchedule);
#if defined(__ANDROID__)
    TRACE_FINISH();
#endif
}

CJThreadHandle ExclusiveCJThreadNew(CJThreadFunc func,
                                    const void *argStart, unsigned int argSize)
{
    struct StackAttr stackAttr;
    stackAttr.stackGrow = false;
    
    struct ArgAttr argAttr;
    argAttr.argStart = argStart;
    argAttr.argSize = argSize;

    // Use CreateSubSchedulerAndInit to properly initialize the exclusive scheduler
    auto runtime = reinterpret_cast<MapleRuntime::CangjieRuntime*>(&MapleRuntime::Runtime::Current());
    ScheduleHandle scheduler = runtime->CreateSubSchedulerAndInit(SCHEDULE_EXCLUSIVE);
    if (scheduler == nullptr) {
        HILOG_ERROR(errno, "failed to create exclusive scheduler");
        return nullptr;
    }
    
    // Set scheduler state to RUNNING to allow timer wake to work
    struct Schedule* schedule = reinterpret_cast<struct Schedule*>(scheduler);
    schedule->state = SCHEDULE_RUNNING;

    CJThreadHandle newCJThread = CJThreadNew(scheduler, nullptr, func, argStart, argSize);
    if (newCJThread == nullptr) {
        LOG(RTLOG_FATAL, "failed to create exclusive cjthread");
    }
    return newCJThread;
}

/* Create a cjthread in the cjthread context. */
CJThreadHandle CJThreadNew(ScheduleHandle schedule, const struct CJThreadAttr *attrUser, CJThreadFunc func,
                           const void *argStart, unsigned int argSize, CJThreadCreateSource createSource)
{
    unsigned long long cjthreadId = CJThreadNewId();
#ifdef __OHOS__
    TRACE_START_ASYNC(TRACE_CJTHREAD_NEW, cjthreadId);
#elif defined(__ANDROID__)
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_NEW, cjthreadId));
#endif
    int error = 0;
    struct Schedule *currentSchedule;
    struct Schedule *targetSchedule = (struct Schedule *)schedule;
    struct ScheduleCJThread *scheduleCJThread = &targetSchedule->schdCJThread;
    currentSchedule = ScheduleGet();
    struct CJThread* newCJThread = CJThreadBuild(schedule, attrUser, func, argStart, argSize, createSource);
    if (newCJThread == nullptr) {
        HILOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "build cjthread failed");
        return nullptr;
    }
    // Set cjthread id in CJThreadNew
    CJThreadSetId(newCJThread, cjthreadId);
    CJThreadBuf buf = (CJThreadGet() == nullptr || currentSchedule != targetSchedule ||
                       createSource == CJTHREAD_CREATE_SOURCE_SIGNAL) ? GLOBAL_BUF : LOCAL_BUF;
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_NEW, cjthreadId);
#elif defined(__ANDROID__)
    TRACE_FINISH();
#endif
    // Put new cjthread into the running queue of processor
    if (targetSchedule->scheduleType == SCHEDULE_UI_THREAD &&
        g_scheduleManager.postTaskFunc != nullptr) {
        error = AddToCJSingleModeThreadList(newCJThread);
    } else if (targetSchedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        // Exclusive cjthread will not be written into the scheduler's scheduling queue.
        error = 0;
    } else if (buf == GLOBAL_BUF) {
        error = ScheduleGlobalWrite(&newCJThread, 1);
    } else {
        error = ProcessorLocalWrite(newCJThread);
    }
    if (error) {
        atomic_store_explicit(&newCJThread->state, CJTHREAD_IDLE, std::memory_order_relaxed);
        CJThreadFree(newCJThread, true);
        if (targetSchedule->scheduleType != SCHEDULE_DEFAULT) {
            atomic_fetch_sub(&scheduleCJThread->cjthreadNum, 1ULL);
        }
        HILOG_ERROR(error, "cjthread add to running queue failed");
        return nullptr;
    }

    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_CREATE)) {
        ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_CREATE, TRACE_STACK_10, nullptr, 1, cjthreadId);
    }

    if (targetSchedule->scheduleType == SCHEDULE_UI_THREAD &&
        g_scheduleManager.postTaskFunc != nullptr) {
        return newCJThread;
    }
    
    // Attempt to start a thread to perform scheduling.
    ProcessorWake(targetSchedule, nullptr);
    return newCJThread;
}

/* Submit tasks from an external thread to the scheduling framework. */
CJThreadHandle CJThreadNewToSchedule(ScheduleHandle schedule, const struct CJThreadAttr *attr,
                                     CJThreadFunc func, const void *argStart, unsigned int argSize,
                                     CJThreadCreateSource createSource)
{
    if (schedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "schedule null invalid");
        return nullptr;
    }
    return CJThreadNew(schedule, attr, func, argStart, argSize, createSource);
}

CJThreadHandle CJThreadNewToDefault(const struct CJThreadAttr *attr, CJThreadFunc func,
                                    const void *argStart, unsigned int argSize)
{
    if (g_scheduleManager.defaultSchedule == nullptr) {
        LOG_ERROR(ERRNO_SCHD_INVALID, "schedule null invalid");
        return nullptr;
    }
    return CJThreadNew(g_scheduleManager.defaultSchedule, attr, func, argStart, argSize);
}

/* Hook registered externally with the scheduling framework. */
int CJThreadSchdHookRegister(SchdCJThreadHookFunc func, CJThreadSchdHook type)
{
    struct Schedule *schedule;

    if (type >= SCHD_HOOK_BUTT) {
        return ERRNO_SCHD_HOOK_INVLAID;
    }
    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }
    if (schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_IS_RUNNING;
    }

    g_scheduleManager.schdCJThreadHook[type] = func;
    return 0;
}

int CJThreadStateHookRegister(SchdCJThreadStateHookFunc func, CJThreadStateHook type)
{
    struct Schedule *schedule;

    if (type >= CJTHREAD_STATE_HOOK_BUTT) {
        return ERRNO_SCHD_HOOK_INVLAID;
    }
    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }
    if (schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_IS_RUNNING;
    }

    g_scheduleManager.schdCJThreadStateHook[type] = func;
    return 0;
}

void *CJThreadMpark(struct CJThread *parkCJThread)
{
    int error;
    struct CJThread *cjthread0;
    ParkCallbackFunc callbackFunc;
    // Update cjthread status to PENDING
    MapleRuntime::Mutator* mutator = parkCJThread->mutator;
    if (parkCJThread->schedule->scheduleType == SCHEDULE_UI_THREAD) {
        MapleRuntime::ThreadLocal::SetMutator(nullptr);
    }
    auto& context = parkCJThread->context;
    mutator->PreparedToPark((void*)context.GetPC(), (void*)context.GetFrameAddress());
    atomic_store_explicit(&parkCJThread->state, CJTHREAD_PENDING, std::memory_order_relaxed);
    cjthread0 = CJThreadGet();
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(cjthread0);
#endif
    callbackFunc = (ParkCallbackFunc)(cjthread0->func);
    if (callbackFunc != nullptr) {
        // Note: park_cjthread cannot be accessed when the callback function succeeds. After
        // the callback is successful, park_cjthread may be taken by other threads and then
        // freed. In this case, park_cjthread is a wild pointer.
        error = callbackFunc(cjthread0->argStart, (CJThreadHandle)parkCJThread);
        if (error != 0) {
            // If the callback function fails, roll back to park_cjthread.
            atomic_store_explicit(&parkCJThread->state, CJTHREAD_RUNNING, std::memory_order_relaxed);
            parkCJThread->result = error;
            MapleRuntime::ThreadLocalData* tlData = MapleRuntime::ThreadLocal::GetThreadLocalData();
            tlData->SetMutator(mutator);
            mutator->PreparedToRun(tlData);
            if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_UNBLOCK)) {
                ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_UNBLOCK, TRACE_STACK_1, nullptr, 1,
                                         CJThreadGetId(static_cast<CJThreadHandle>(parkCJThread)));
                ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_START, -1, nullptr, 1,
                                         CJThreadGetId(static_cast<CJThreadHandle>(parkCJThread)));
            }
#ifdef CANGJIE_ASAN_SUPPORT
            // target to next cj thread, just switch
            MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(cjthread0, parkCJThread);
            MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(parkCJThread);
#endif
            TRACE_FINISH_ASYNC(TRACE_CJTHREAD_PARK, parkCJThread->id);
#ifdef __OHOS__
            TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, parkCJThread->id);
#elif defined(__ANDROID__)
            TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, parkCJThread->id));
#endif
            CJThreadExecute(parkCJThread, (void**)&tlData->cjthread);
        }
    }

    // Search a schedulable cjthread
    ProcessorSchedule();
    return nullptr;
}

int CJThreadParkInForeignThread(CJThread* cjthread, ParkCallbackFunc func, void *arg)
{
    // cjthread park in foreign thread do not call CJThreadMCall,
    // so we should update the cjthread context by call CJThreadContextGet
    CJThreadContextGet(&cjthread->context);
    // Update cjthread status to PENDING
    MapleRuntime::Mutator* mutator = cjthread->mutator;
    auto& context = cjthread->context;
    mutator->PreparedToPark((void*)context.GetPC(), (void*)context.GetFrameAddress());
    Thread* thread = cjthread->thread;
    thread->state = THREAD_PRE_SLEEP;
    atomic_store_explicit(&cjthread->state, CJTHREAD_PENDING, std::memory_order_relaxed);
    int error = func(arg, (CJThreadHandle)cjthread);
    if (error != 0) {
        return cjthread->result;
    }

    // Wait for the semaphor, do not schedule in foreign thread.
    thread->state = THREAD_SLEEP;
    int ret = SemaphoreWait(&(thread->sem));
    if (ret != 0) {
        LOG_ERROR(ret, "sem_wait failed");
    }
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_PARK, cjthread->id);
#ifdef __OHOS__
    TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, cjthread->id);
#elif defined(__ANDROID__)
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, cjthread->id));
#endif

    // Check the timer.
    ProcessorCheckFunc checkFunc;
    unsigned long long now = 0;
    checkFunc = g_scheduleManager.check[PROCESSOR_TIMER_HOOK];
    if (checkFunc != nullptr) {
            checkFunc(ProcessorGet(), &now, nullptr);
    }

    atomic_store_explicit(&cjthread->state, CJTHREAD_RUNNING, std::memory_order_relaxed);
    MapleRuntime::ThreadLocalData* tlData = MapleRuntime::ThreadLocal::GetThreadLocalData();
    tlData->SetMutator(mutator);
    mutator->PreparedToRun(tlData);
    thread->state = THREAD_RUNNING;
    return cjthread->result;
}

/* Park the current cjthread and schedule the next cjthread. */
int CJThreadPark(ParkCallbackFunc func, TraceEvent waitReason, void *arg)
{
    struct CJThread *cjthread0;
    struct CJThread *cjthread;

    cjthread = CJThreadGet();
    if (UNLIKELY(cjthread == nullptr)) {
        MapleRuntime::ThreadType threadType = MapleRuntime::ThreadLocal::GetThreadType();
        HILOG_FATAL(ERRNO_SCHD_CJTHREAD_PARK_FAILED,
                    "cjthread park failed because of null cjthread, current thread type is %d",
                    static_cast<int>(threadType));
    }
    cjthread->result = 0;

#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXEC, cjthread->id);
#elif defined(__ANDROID__)
    TRACE_FINISH();
#endif
    TRACE_START_ASYNC(TRACE_CJTHREAD_PARK, cjthread->id);
#ifdef __OHOS__
    // cjthread is with foreign context if threadStackTopList size greater than 1.
    // cjthread is on UI thread if schedule type is SCHEDULE_UI_THREAD.
    if (cjthread->schedule->scheduleType == SCHEDULE_UI_THREAD && cjthread->threadStackTopList.size() > 1) {
        HILOG_WARN(ERRNO_SCHD_UITHREAD_ERROR,
                   "parking cjthread with foreign function context on UI thread is not permitted.");
        return CJThreadParkInForeignThread(cjthread, func, arg);
    }
#endif

    // If cjthread is in exclusive thread schedule, do not schedule, just park.
    if (cjthread->schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return CJThreadParkInForeignThread(cjthread, func, arg);
    }

    // If cjthread is in foregin thread schedule, do not schedule, just park.
    if (cjthread->schedule->scheduleType == SCHEDULE_FOREIGN_THREAD) {
        return CJThreadParkInForeignThread(cjthread, func, arg);
    }
    cjthread0 = static_cast<struct CJThread *>(ThreadGet()->cjthread0);
    // The func field of cjthread0 is used to store callback functions.
    cjthread0->func = (CJThreadFunc)func;
    cjthread0->argStart = arg;
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(cjthread, cjthread0);
#endif
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & waitReason)) {
        if (waitReason == TRACE_EV_CJTHREAD_BLOCK_NET) {
            ScheduleTraceEventOrigin(waitReason, -1, nullptr, 1, SpecialStackId::CJTHREAD_NET_BLOCK);
        } else {
            ScheduleTraceEventOrigin(waitReason, TRACE_STACK_1, nullptr, 0);
        }
    }
    CJThreadMcall(reinterpret_cast<void *>(CJThreadMpark), CJThreadAddr());
    return cjthread->result;
}

void CJThreadWait()
{
    CJThreadPark(NULL, TRACE_EV_CJTHREAD_BLOCK, NULL);
}

/**
 * CJThreadMRAW Parks the given thread, and executes the next thread specified in
 * cjthread0->argStart.
 * It does this without going through the scheduler, but deterministically choosing the next
 * cjthread to execute.
 *
 * Note: the implementation is based on CJThreadMPark and ProcessorSchedule
 */
void *CJThreadMRAW(struct CJThread *parkCJThread)
{
    /* COPIED AND MODIFIED FROM CJThreadMpark */
    {
        // Park parkCJThread
        MapleRuntime::Mutator* mutator = parkCJThread->mutator;
        auto& context = parkCJThread->context;
        mutator->PreparedToPark((void*)context.GetPC(), (void*)context.GetFrameAddress());
        atomic_store_explicit(&parkCJThread->state, CJTHREAD_PENDING, std::memory_order_relaxed);
    }
    /* END COPY */

    struct CJThread *cjthread0 = CJThreadGet();
    // Recover the next thread to run from `argStart`
    // See the invocation from CJThreadResumeAndWait
    struct CJThread *nextCJThread = static_cast<struct CJThread *>(cjthread0->argStart);

    /* COPIED AND MODIFIED FROM ProcessorSchedule() */
    {
        atomic_store_explicit(&nextCJThread->state, CJTHREAD_RUNNING, std::memory_order_relaxed);
        ProtectAddrSet((uintptr_t)nextCJThread->stack.stackGuard);
        if (nextCJThread->boundThread != nullptr) {
            LOG_ERROR(-1, "BOUND THREADS NOT SUPPORTED WITH EFFECTS");
        } else {
            // Execute the thread
            MapleRuntime::Mutator* mutator = nextCJThread->mutator;
            MapleRuntime::ThreadLocalData* tlData = MapleRuntime::ThreadLocal::GetThreadLocalData();
            tlData->SetMutator(mutator);
            mutator->PreparedToRun(tlData);
#ifdef CANGJIE_ASAN_SUPPORT
            // target to next cj thread, just switch
            MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(CJThreadGet(), nextCJThread);
            MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(nextCJThread);
#endif
#ifdef __OHOS__
            TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, nextCJThread->id);
#elif defined (__ANDROID__)
            TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, nextCJThread->id));
#endif
#ifdef __OHOS__
            if (nextCJThread->schedule->scheduleType == SCHEDULE_UI_THREAD) {
                SingleCJThreadStoreSP();
            }
#endif

            CJThreadExecute(nextCJThread, (void**)&tlData->cjthread);
        }
    }
    /* END COPY */

    return nullptr;
}

void CJThreadResumeAndWait(CJThreadHandle readyThread)
{
    struct CJThread *cjthread0 = static_cast<struct CJThread *>(ThreadGet()->cjthread0);
    /* This is a trick to pass an extra argument to CJThreadMRAW */
    cjthread0->argStart = readyThread;
    CJThreadMcall(reinterpret_cast<void *>(CJThreadMRAW), CJThreadAddr());
}

void *CJThreadMresched(struct CJThread *reCJThread)
{
    struct Schedule *schedule = reCJThread->schedule;
    MapleRuntime::Mutator* mutator = reCJThread->mutator;
    auto& context = reCJThread->context;
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(CJThreadGet());
#endif
    mutator->PreparedToPark((void*)context.GetPC(), (void*)context.GetFrameAddress());
    struct CJThread *lastCJThread;
    atomic_store_explicit(&reCJThread->state, CJTHREAD_READY, std::memory_order_relaxed);
    // If the global queue is not empty, the cjthread is added into the global queue.
    // Otherwise, the cjthread is recorded in lastCJThread of the scheduler and the last
    // reschedule cjthread is added to the local queue. Minimize access to global queues
    // while ensuring fairness. The scheduler searches for cjthreads in the following
    // sequence: local -> lastCJThread -> global
    if (schedule->schdCJThread.num != 0) {
        ScheduleGlobalWrite(&reCJThread, 1);
    } else {
        lastCJThread = reinterpret_cast<struct CJThread *>(atomic_exchange(&schedule->lastCJThread,
                                                                           reCJThread));
        if (lastCJThread) {
            ProcessorLocalWrite(lastCJThread, true);
        }
    }
    ProcessorSchedule();
    return nullptr;
}

/* Change the cjthread from running to ready and put it back at the running queue.
 * Note: This function always returns 0. The return value is meaningless. However, the function
 * definition must return int and cannot be defined as void. This is mainly to prevent compiler
 * optimizations. If void is returned, the compiler exits the stack before calling the second
 * hook function. The instruction for calling the hook is jmp instead of call, which causes
 * the stack frame to change. If the return value is int, the compiler does not perform this
 * optimization, the instruction that calls the hook is still call, and the stack is not
 * dropped first.
 * Disables inlining of this function. The same problem also occurs if the function is called
 * by another function and is inline. For example, CJThreadPreempt.
 **/
__attribute__((noinline)) int CJThreadResched(void)
{
    // If cjthread is in foreign or exclusive thread schedule, do not reschedule.
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread->schedule->scheduleType == SCHEDULE_FOREIGN_THREAD ||
        cjthread->schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return 0;
    }
    if (UNLIKELY(cjthread->boundThread)) {
        return 0;
    }
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(CJThreadGet(), ThreadGet()->cjthread0);
#endif
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXEC, cjthread->id);
#elif defined(__ANDROID__)
    TRACE_FINISH();
#endif
    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_RESCHED)) {
        ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_RESCHED, -1, nullptr,
                                 1, SpecialStackId::CJTHREAD_RESCHED);
    }
    CJThreadMcall(reinterpret_cast<void *>(CJThreadMresched), CJThreadAddr());
    return 0;
}

int CJThreadTryResched(void)
{
    struct Processor* processor = ProcessorGet();
    unsigned long overload = processor->schedCnt - processor->obRecord.lastSchedCnt;
    if (overload > PROCESSOR_SCHED_COUNT_THRESHOLD && overload % PROCESSOR_SCHED_COUNT_THRESHOLD != 0) {
        return 1;
    }
    return CJThreadResched();
}

/* Collaborative preemption. The current cjthread abandons the execution. */
void CJThreadPreemptResched(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (PreemptFlagGet() != PREEMPT_DO_FLAG) {
        return;
    }
    PreemptFlagSet(0);
    if (cjthread->preemptOffCnt != 0) {
        return;
    }
    ScheduleGet()->schdCJThread.preemptCnt++;
    CJThreadResched();
}

bool ShouldWakeDirectly(Schedule* schedule, CJThread* cjthread)
{
    // If cj thread is in foreign or exclusive thread schedule, just wake this schedule.
    if (schedule->scheduleType == SCHEDULE_FOREIGN_THREAD || schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return true;
    }
#ifdef __OHOS__
    // If cj thread is in UI Thread schedule and the post task fun is registered,
    // and C2N count is greater than 0(there are native func in stack),
    // just wake this schedule.
    if (schedule->scheduleType == SCHEDULE_UI_THREAD &&
        g_scheduleManager.postTaskFunc != nullptr &&
        cjthread->threadStackTopList.size() > 1) {
        return true;
    }
#else
    (void)cjthread;
#endif
    return false;
}

/* CJThread ready, adds the specified cjthread to the running queue. */
void CJThreadReady(CJThreadHandle readyCJThread)
{
    struct CJThread *cjthread = (struct CJThread *)readyCJThread;
    CJThreadState expected = CJTHREAD_PENDING;
    struct Schedule *schedule;
    if (readyCJThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "ready_cjthread is null");
        return;
    }

    if (g_scheduleManager.trace.openType && (g_scheduleManager.trace.openType & TRACE_EV_CJTHREAD_UNBLOCK)) {
        struct CJThread *currCJThread = CJThreadGet();
        if (currCJThread != nullptr && currCJThread->isCJThread0) {
            ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_UNBLOCK, -1, nullptr, TRACE_ARGS_2,
                                     CJThreadGetId(readyCJThread), SpecialStackId::CJTHREAD_UNBLOCK);
        } else {
            ScheduleTraceEventOrigin(TRACE_EV_CJTHREAD_UNBLOCK, TRACE_STACK_10, nullptr,
                                     TRACE_ARGS_1, CJThreadGetId(readyCJThread));
        }
    }
    schedule = cjthread->schedule;
    // Use CAS to prevent CJThreadReady concurrency. CAS may fail, which is normal.
    if (atomic_compare_exchange_strong(&cjthread->state, &expected, CJTHREAD_READY)) {
        // If cj thread is in foreign thread schedule, just wake this schedule,
        // do not push cjthread to global or local list.
        if (ShouldWakeDirectly(schedule, cjthread)) {
            ProcessorWake(schedule, nullptr);
            return;
        }
        TRACE_FINISH_ASYNC(TRACE_CJTHREAD_PARK, cjthread->id);
        if (schedule->scheduleType == SCHEDULE_UI_THREAD &&
            g_scheduleManager.postTaskFunc != nullptr) {
            AddToCJSingleModeThreadList(cjthread);
            return;
        }
        if (ScheduleGet() != schedule || CJThreadGet() == nullptr) {
            ScheduleGlobalWrite(&cjthread, 1);
        } else {
            ProcessorLocalWrite(cjthread);
        }
        ProcessorWake(schedule, nullptr);
    }
}

/* Add cjthreads to the running queue in batches. Cjthreads have been set to the ready
 * state before calling this function. */
int CJThreadAddBatch(CJThreadHandle *list, unsigned int num)
{
    int error;
    struct CJThread *cjthread;
    struct Schedule *schedule;
    unsigned int proNum;
    unsigned int i;

    if (num == 0) {
        return 0;
    }
    schedule = ((struct CJThread **)list)[0]->schedule;
    cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        // The current context is not a cjthread. All are put into the global queue.
        error = ScheduleGlobalWrite((struct CJThread **) list, num);
        if (error) {
            LOG_ERROR(error, "ScheduleGlobalWrite failed");
            return error;
        }
        for (i = 0; i < num; i++) {
            ProcessorWake(schedule, nullptr);
        }
    } else {
        proNum = schedule->schdProcessor.freeNum;
        if (proNum >= num) {
            // If the number of free processors is greater than the number of cjthreads, all
            // the cjthreads are put into the global queue.
            error = ScheduleGlobalWrite((struct CJThread **) list, num);
            if (error) {
                LOG_ERROR(error, "ScheduleGlobalWrite failed");
                return error;
            }
            for (i = 0; i < num; i++) {
                ProcessorWake(schedule, nullptr);
            }
        } else {
            // If the number of free processors is less than the number of cjthreads, n cjthreads
            // are selected to enter the global queue (n indicates the number of idle processors
            // currently), and others enter the local queue.
            error = ScheduleGlobalWrite((struct CJThread **) list, proNum);
            if (error) {
                LOG_ERROR(error, "ScheduleGlobalWrite failed");
                return error;
            }
            error = ProcessorLocalWriteBatch((struct CJThread **)(list + proNum), num - proNum);
            if (error) {
                LOG_ERROR(error, "ProcessorLocalWriteBatch failed");
                return error;
            }
            for (i = 0; i < proNum; i++) {
                ProcessorWake(schedule, nullptr);
            }
        }
    }
    return 0;
}

unsigned long long int CJThreadId(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return 0;
    }
    if (cjthread->id == CJTHREAD_INIT_ID) {
        cjthread->id = CJThreadNewId();
    }

    return cjthread->id;
}

char* CJThreadGetName(void* cjthreadPtr)
{
    struct CJThread *cjthread = reinterpret_cast<struct CJThread *>(cjthreadPtr);
    if (cjthread == nullptr) {
        return nullptr;
    }
    return cjthread->name;
}

int CJThreadGetState(void* cjthreadPtr)
{
    struct CJThread *cjthread = reinterpret_cast<struct CJThread *>(cjthreadPtr);
    if (cjthread == nullptr) {
        return -1;
    }
    return cjthread->state.load();
}

unsigned long long int CJThreadGetId(CJThreadHandle handle)
{
    struct CJThread *cjthread = (struct CJThread*)(handle);
    if (cjthread == nullptr) {
        return 0;
    }
    if (cjthread->id == CJTHREAD_INIT_ID) {
        cjthread->id = CJThreadNewId();
    }
    return cjthread->id;
}

/* ensure cjthread is not nullptr */
void CJThreadSetId(struct CJThread *cjthread, unsigned long long id)
{
    if (cjthread->id == CJTHREAD_INIT_ID) {
        cjthread->id = id;
    }
}

CJThreadHandle CJThreadGetHandle()
{
    return CJThreadGet();
}

void CJThreadSetName(CJThreadHandle handle, const char *name, size_t len)
{
    int error = 0;
    struct CJThread *cjthread = (struct CJThread*)(handle);
    if (cjthread == nullptr || name == nullptr) {
        return;
    }
    if (len > CJTHREAD_NAME_SIZE - 1) {
        len = CJTHREAD_NAME_SIZE - 1;
    }

    error = memcpy_s(cjthread->name, CJTHREAD_NAME_SIZE, name, len);
    if (error) {
        LOG_ERROR(error, "cjthread name set failed");
        return;
    } else {
        cjthread->name[len] = '\0';
    }
#ifdef __OHOS__
    MapleRuntime::ScopedEntryAsyncTrace(TRACE_CJTHREAD_SETNAME, cjthread->id, cjthread->name);
#elif defined(__ANDROID__)
    TRACE_START(MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_SETNAME, cjthread->id, 1, cjthread->name));
    TRACE_FINISH();
#endif
}

void CJThreadGetInfo(struct CJThread *cjthread, struct CJThreadInfo *cjthreadInfo)
{
    struct Processor *processor = nullptr;
    unsigned int processorId = static_cast<unsigned int>(-1);
    struct Thread *thread = static_cast<struct Thread *>(cjthread->thread);

    if (cjthread->id == CJTHREAD_INIT_ID) {
        cjthread->id = CJThreadNewId();
    }
    cjthreadInfo->state = cjthread->state;
    cjthreadInfo->id = cjthread->id;

    CHECK_DETAIL(strcpy_s(cjthreadInfo->name, CJTHREAD_NAME_SIZE, cjthread->name) == EOK,
                 "strcpy_s failed when copy func or file names.\n");

    if (thread != nullptr) {
        processor = static_cast<struct Processor *>(thread->processor);
#ifdef MRT_MACOS
        cjthreadInfo->pthreadId = 0;
#else
        cjthreadInfo->pthreadId = static_cast<unsigned long long>(thread->osThread);
#endif
        cjthreadInfo->tid = static_cast<unsigned int>(thread->tid);
        if (processor != nullptr) {
            processorId = processor->processorId;
        }
    } else {
        cjthreadInfo->pthreadId = 0;
        cjthreadInfo->tid = 0;
    }
    cjthreadInfo->processorId = processorId;
    cjthreadInfo->argSize = cjthread->argSize;
    cjthreadInfo->argStart = cjthread->argStart;
    cjthreadInfo->context = cjthread->context;
}

int CJThreadStackReversedSet(uintptr_t size)
{
    struct Schedule *schedule = ScheduleGet();
    // Not allowed to modify at runtime
    if (schedule != nullptr) {
        return ERRNO_SCHD_IS_RUNNING;
    }

    // The value cannot be smaller than the default value because space needs to be reserved
    // for stack overflow processing.
    if (size < STACK_DEFAULT_REVERSED) {
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    g_cjthreadStackReservedSize = size;
    return 0;
}

uintptr_t CJThreadStackReversedGet(void)
{
    return g_cjthreadStackReservedSize;
}

/* This function is used for the exception try catch mechanism of cangjie. After the stack
 * overflow exception is caught, the stack boundary needs to be temporarily extended. */
void CJThreadStackGuardExpand(void)
{
    struct CJThread *cjthread = CJThreadGet();
    cjthread->stack.stackGuard -= g_cjthreadStackReservedSize;
    ProtectAddrSet(reinterpret_cast<uintptr_t>(cjthread->stack.stackGuard));
}

/* This function is used for the exception try catch mechanism of cangjie. After the stack
 * overflow exception is caught, the stack boundary needs to be restored. */
void CJThreadStackGuardRecover(void)
{
    struct CJThread *cjthread = CJThreadGet();
    cjthread->stack.stackGuard += g_cjthreadStackReservedSize;
    ProtectAddrSet(reinterpret_cast<uintptr_t>(cjthread->stack.stackGuard));
}

int CJBindOSThread(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is null");
        return -1;
    }
    struct Thread *thread = ThreadGet();
    if (cjthread->boundThread != nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_HAS_BEEN_BOUND_TO_THREAD, "cjthread has been bound to thread");
        return -1;
    }
    cjthread->boundThread = thread;
    thread->boundCJThread = cjthread;
    return 0;
}

int CJUnbindOSThread(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is null");
        return -1;
    }
    struct Thread *thread = ThreadGet();
    if (cjthread->boundThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NOT_BOUND_TO_THREAD, "cjthread not bound to thread");
        return -1;
    }
    cjthread->boundThread = nullptr;
    thread->boundCJThread = nullptr;
    return 0;
}

void *CJThreadStackGuardGet(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return nullptr;
    }

    // EXCLUSIVE uses OS thread stack which doesn't need checking
    struct Schedule *schedule = ScheduleGet();
    if (schedule != nullptr && schedule->scheduleType == SCHEDULE_EXCLUSIVE) {
        return nullptr;
    }

#ifdef __arm__
    if (schedule == nullptr) {
        return nullptr;
    }
    if (schedule->scheduleType == SCHEDULE_FOREIGN_THREAD) {
        return nullptr;
    }
#endif
    return cjthread->stack.stackGuard;
}

void *CJThreadStackAddrGet(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return nullptr;
    }
    return cjthread->stack.stackTopAddr;
}

void *CJThreadStackBaseAddrGet(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return nullptr;
    }
    return cjthread->stack.cjthreadStackBaseAddr;
}

void *CJThreadStackAddrGetByCJThrd(struct CJThread *cjthread)
{
    if (cjthread == nullptr) {
        cjthread = CJThreadGet();
    }
    if (cjthread == nullptr) {
        return nullptr;
    }
    return cjthread->stack.stackTopAddr;
}

void *CJThreadStackBaseAddrGetByCJThrd(struct CJThread *cjthread)
{
    if (cjthread == nullptr) {
        cjthread = CJThreadGet();
    }
    if (cjthread == nullptr) {
        return nullptr;
    }
    return cjthread->stack.cjthreadStackBaseAddr;
}

int CJThreadPreemptOffCntAdd(void)
{
    struct CJThread *cjthread = CJThreadGet();

    if (cjthread == nullptr) {
        return ERRNO_SCHD_PREEMPT_CNT_INVALID;
    }
    if (cjthread->preemptOffCnt == UINT_MAX) {
        LOG_ERROR(ERRNO_SCHD_PREEMPT_CNT_INVALID, "preempt_off_cnt overflow");
        return ERRNO_SCHD_PREEMPT_CNT_INVALID;
    }
    cjthread->preemptOffCnt++;
    return 0;
}

int CJThreadPreemptOffCntSub(void)
{
    struct CJThread *cjthread = CJThreadGet();

    if (cjthread == nullptr) {
        return ERRNO_SCHD_PREEMPT_CNT_INVALID;
    }
    if (cjthread->preemptOffCnt == 0) {
        LOG_ERROR(ERRNO_SCHD_PREEMPT_CNT_INVALID, "preempt_off_cnt flip");
        return ERRNO_SCHD_PREEMPT_CNT_INVALID;
    }
    cjthread->preemptOffCnt--;
    return 0;
}


int CJThreadDestructorHookRegister(SchdDestructorHookFunc func)
{
    struct Schedule *schedule;

    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }
    if (schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_IS_RUNNING;
    }

    g_scheduleManager.destructorFunc = func;
    return 0;
}

int CJThreadGetMutatorStatusHookRegister(SchdMutatorStatusHookFunc func)
{
    struct Schedule *schedule;

    schedule = ScheduleGet();
    if (schedule == nullptr) {
        return ERRNO_SCHD_UNINITED;
    }
    if (schedule->state != SCHEDULE_INIT) {
        return ERRNO_SCHD_IS_RUNNING;
    }

    g_scheduleManager.mutatorStatusFunc = func;
    return 0;
}

int CJThreadSetMutator(void *mutator)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return ERRNO_SCHD_CJTHREAD_NULL;
    }
    cjthread->mutator = reinterpret_cast<MapleRuntime::Mutator*>(mutator);
    cjthread->mutator->SetCjthreadPtr(cjthread);
    return 0;
}

void *CJThreadGetMutator(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return nullptr;
    }
    return cjthread->mutator;
}

void* GetCJThreadScheduler()
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return nullptr;
    }
    return cjthread->schedule;
}

void RebindCJThread(void* cjthread)
{
    CJThread* cjRebindThread = reinterpret_cast<CJThread*>(cjthread);
    if (cjRebindThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return;
    }
    cjRebindThread->thread = cjRebindThread->schedule->thread0;
}

/* lua cjthreads run wrapper functions for user tasks */
void *LuaFuncWrap(void *arg, unsigned int size)
{
    (void)size;
    struct CJThread *cjthread = CJThreadGet();
    struct LuaCJThread *luaCJThread = *(struct LuaCJThread **)arg;

    cjthread->isLuaCJThread = true;
    luaCJThread->result = luaCJThread->func(luaCJThread->arg);
    cjthread->isLuaCJThread = false;
    luaCJThread->state = LUA_CJTHREAD_DONE;
    // Wake up the caller after the lua cjthread ends
    SemaphorePost(&luaCJThread->sem);
    return nullptr;
}

CJThreadHandle CJThreadCreate(const struct CJThreadAttr *attrUser, LuaCJThreadFunc func, void *arg)
{
    struct LuaCJThread *luaCJThread;

    if (func == nullptr || attrUser == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "arg invalid");
        return nullptr;
    }

    if (ScheduleGet() == nullptr) {
        LOG_ERROR(ERRNO_SCHD_UNINITED, "schedule not inited");
        return nullptr;
    }

    luaCJThread = (struct LuaCJThread*)malloc(sizeof(struct LuaCJThread));
    if (luaCJThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED, "malloc failed");
        return nullptr;
    }

    (void)memset_s(luaCJThread, sizeof(struct LuaCJThread), 0, sizeof(struct LuaCJThread));
    luaCJThread->func = func;
    luaCJThread->arg = arg;
    luaCJThread->state = LUA_CJTHREAD_INIT;
    (void)memcpy_s(&luaCJThread->attrUser, sizeof(struct CJThreadAttr),
                   attrUser, sizeof(struct CJThreadAttr));

    // The C side thread invokes this interface and uses semaphore for synchronization control.
    if (SemaphoreInit(&luaCJThread->sem, 0, 0) != 0) {
        LOG_ERROR(errno, "sem_init failed");
        free(luaCJThread);
        return nullptr;
    }

    return luaCJThread;
}

int CJThreadYieldCallback(void *arg, CJThreadHandle handle)
{
    (void)handle;
    struct LuaCJThread *luaCJThread = (struct LuaCJThread *)arg;
    luaCJThread->state = LUA_CJTHREAD_SUSPENDING;
    SemaphorePost(&luaCJThread->sem);
    return 0;
}

int CJThreadYield(void)
{
    struct CJThread *cjthread;
    struct LuaCJThread *luaCJThread;
    int state;

    cjthread = CJThreadGet();
    if (cjthread == nullptr || cjthread->argStart == nullptr || cjthread->isLuaCJThread == false) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "not in lua cjthread");
        return ERRNO_SCHD_CJTHREAD_NULL;
    }
    luaCJThread = *static_cast<struct LuaCJThread **>(cjthread->argStart);

    state = luaCJThread->state;
    if (state == LUA_CJTHREAD_RUNNING) {
        CJThreadPark(CJThreadYieldCallback, TRACE_EV_CJTHREAD_BLOCK, (void *)luaCJThread);
        return 0;
    } else {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_STATE_INVALID, "cjthread state wrong: %d", state);
        return ERRNO_SCHD_CJTHREAD_STATE_INVALID;
    }
}

int CJThreadResume(CJThreadHandle cjthread)
{
    struct LuaCJThread *luaCJThread;
    int state;

    luaCJThread = (struct LuaCJThread *)cjthread;
    if (luaCJThread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return ERRNO_SCHD_CJTHREAD_NULL;
    }
    state = luaCJThread->state;
    switch (state) {
        case LUA_CJTHREAD_INIT: {
            luaCJThread->state = LUA_CJTHREAD_RUNNING;
            luaCJThread->cjthread = CJThreadNewToDefault((const struct CJThreadAttr *)(&luaCJThread->attrUser),
                                                         LuaFuncWrap, (void *)&luaCJThread, sizeof(void *));
            if (luaCJThread->cjthread == nullptr) {
                luaCJThread->state = LUA_CJTHREAD_INIT;
                LOG_ERROR(ERRNO_SCHD_CJTHREAD_ALLOC_FAILED, "CJThreadNew failed");
                return ERRNO_SCHD_CJTHREAD_ALLOC_FAILED;
            }
            SemaphoreWait(&luaCJThread->sem);
            return 0;
        }
        case LUA_CJTHREAD_SUSPENDING: {
            luaCJThread->state = LUA_CJTHREAD_RUNNING;
            CJThreadReady(luaCJThread->cjthread);
            SemaphoreWait(&luaCJThread->sem);
            return 0;
        }
        default: {
            LOG_ERROR(ERRNO_SCHD_CJTHREAD_STATE_INVALID, "cjthread state wrong: %d", state);
            return ERRNO_SCHD_CJTHREAD_STATE_INVALID;
        }
    }
}

int CJThreadStateGet(CJThreadHandle handle)
{
    struct LuaCJThread *cjthread = (struct LuaCJThread *)handle;
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return ERRNO_SCHD_CJTHREAD_NULL;
    }
    return cjthread->state;
}

int CJThreadDestroy(CJThreadHandle handle)
{
    struct LuaCJThread *cjthread = (struct LuaCJThread *)handle;
    // Resources can be released only in the initial and end states to avoid resource leakage.
    if (cjthread == nullptr || cjthread->state == LUA_CJTHREAD_SUSPENDING ||
        cjthread->state == LUA_CJTHREAD_RUNNING) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "cjthread is nullptr, or not finished");
        return ERRNO_SCHD_CJTHREAD_ARG_INVALID;
    }
    SemaphoreDestroy(&cjthread->sem);
    free(cjthread);
    return 0;
}

void *CJThreadResultGet(CJThreadHandle handle)
{
    struct LuaCJThread *cjthread = (struct LuaCJThread *)handle;
    if (cjthread == nullptr || cjthread->state != LUA_CJTHREAD_DONE) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_ARG_INVALID, "cjthread is nullptr, or not finished");
        return nullptr;
    }
    return cjthread->result;
}

void *CJThreadGetArg(void)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread != nullptr) {
        return cjthread->argStart;
    }
    return nullptr;
}

int CJThreadSetStackGrow(bool enableStackGrow)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return ERRNO_SCHD_CJTHREAD_NULL;
    }

    // The stack scaling function is disabled globally. This interface is directly returned.
    if (!cjthread->schedule->schdCJThread.stackGrow) {
        return 0;
    }

    if (enableStackGrow) {
        if (cjthread->stack.stackGrowCnt == 0) {
            return 0;
        }
        cjthread->stack.stackGrowCnt--;
    } else {
        if (cjthread->stack.stackGrowCnt == UINT_MAX) {
            LOG_ERROR(ERRNO_SCHD_STACKGROW_CNT_INVALID, "stackGrow_cnt overflow");
            return ERRNO_SCHD_STACKGROW_CNT_INVALID;
        }
        cjthread->stack.stackGrowCnt++;
    }
    
    return 0;
}

size_t CJThreadStackSizeGet()
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return static_cast<size_t>(-1);
    }

    return cjthread->stack.stackSize;
}

size_t CJThreadStackSizeGetByCJThrd(struct CJThread *cjthread)
{
    if (cjthread == nullptr) {
        cjthread = CJThreadGet();
    }
    if (cjthread == nullptr) {
        return static_cast<size_t>(-1);
    }

    return cjthread->stack.stackSize;
}

void CJThreadOldStackFree(void *stackAddr, size_t stackSize)
{
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return;
    }

    CJThreadStackMemFree(cjthread, (char *)stackAddr, stackSize);
}

intptr_t CJThreadStackAdjust(struct CJThread *cjthread, size_t newStackSizeAlign)
{
    struct Schedule *schedule = cjthread->schedule;
    struct StackAttr newStackAttr;
    char *newStackAddr;
    char *spAddress = nullptr;
    char *oldStackBaseAddr;
    char *newStackBaseAddr;
    size_t totalSize;
    size_t stackUsed;

#ifdef CANGJIE_SANITIZER_SUPPORT
    // make sure sanitizer context is copied to new stack as well
    oldStackBaseAddr = cjthread->stack.cjthreadStackBaseAddr + CJTHREAD_SANITIZER_CONTEXT_OFFSET;
#else
    oldStackBaseAddr = cjthread->stack.cjthreadStackBaseAddr;
#endif
    // Allocate new cjthread stack memory
    newStackAttr.stackGrow = true;
    newStackAttr.stackSizeAlign = newStackSizeAlign;
    newStackAddr = CJThreadStackMemAlloc(schedule, cjthread, newStackSizeAlign, &totalSize);
    if (newStackAddr == nullptr) {
        return -1;
    }
    // Update stack attr
    CJThreadStackAttrInit(cjthread, totalSize, newStackAddr, &newStackAttr);
#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanCleanShadow(cjthread->stack.stackTopAddr, cjthread->stack.totalSize);
#endif
    // Update the thread local variable protected by the stack.
    ProtectAddrSet(reinterpret_cast<uintptr_t>(cjthread->stack.stackGuard));
#ifdef CANGJIE_SANITIZER_SUPPORT
    // make sure sanitizer context is copied to new stack as well
    newStackBaseAddr = cjthread->stack.cjthreadStackBaseAddr + CJTHREAD_SANITIZER_CONTEXT_OFFSET;
#else
    newStackBaseAddr = cjthread->stack.cjthreadStackBaseAddr;
#endif

#if (VOS_WORDSIZE == 64) && (MRT_HARDWARE_PLATFORM == MRT_ARM)
    asm volatile (
    "mov %0, sp \n"
    :"=r"(spAddress)
    );
#endif

#if (VOS_WORDSIZE == 32) && (MRT_HARDWARE_PLATFORM == MRT_ARM)
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

    // Calculate the total used size of the old stack.(CjthreadEntry to the stack size used
    // by the current function)
    stackUsed = oldStackBaseAddr - spAddress;
    if (memmove_s(newStackBaseAddr - stackUsed, stackUsed, oldStackBaseAddr - stackUsed, stackUsed) != EOK) {
        LOG_ERROR(-1, "memmove_s failed");
        return -1;
    }

    return newStackBaseAddr - oldStackBaseAddr;
}

intptr_t CJThreadStackGrow(size_t stackSize)
{
    size_t newStackSize;
    size_t oldStackSize;
    size_t newStackSizeAlign;
    struct CJThread *cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_NULL, "cjthread is nullptr");
        return -1;
    }
    // Check whether the stack scaling function is disabled.
    if (cjthread->stack.stackGrowCnt != 0) {
        return 0;
    }

    oldStackSize = cjthread->stack.stackSize;
    newStackSize = (stackSize == 0) ? oldStackSize << 1 : stackSize;
    if (newStackSize <= oldStackSize) {
        return 0;
    }

    // cjthread stack size requires page alignment.
    newStackSizeAlign = STACK_ADDR_ALIGN_UP(newStackSize, SchedulePageSize());
    if (newStackSizeAlign > CJTHREAD_MAX_STACK_SIZE || newStackSizeAlign <= oldStackSize) {
        LOG_ERROR(ERRNO_SCHD_CJTHREAD_STACK_EXPAND_FAILED,
                  "cjthread stack overflow, newStackSizeAlign = %u", newStackSizeAlign);
        return -1;
    }

    return CJThreadStackAdjust(cjthread, newStackSizeAlign);
}

#ifdef CANGJIE_SANITIZER_SUPPORT
void* CJThreadGetSanitizerContext(void* cjthread)
{
    CJThread* thread = static_cast<CJThread*>(cjthread);
    return *reinterpret_cast<void**>(thread->stack.cjthreadStackBaseAddr);
}

void CJThreadSetSanitizerContext(void *cjthread, void *state)
{
    CJThread *thread = static_cast<CJThread *>(cjthread);
    *reinterpret_cast<void **>(thread->stack.cjthreadStackBaseAddr) = state;
}
#endif
#ifdef __cplusplus
}
#endif
