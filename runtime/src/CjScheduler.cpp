// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#include "CjScheduler.h"

#include <cstdlib>
#include <cstring>
#include <thread>
#if defined(_WIN64)
#include <windows.h>
#elif defined(__APPLE__)
#include "sys/sysctl.h"
#else
#include "sys/sysinfo.h"
#endif

#include "Base/LogFile.h"
#include "Base/CString.h"
#include "Sync/Sync.h"
#include "Base/Panic.h"
#include "Cangjie.h"
#include "CangjieRuntime.h"
#include "Mutator/MutatorManager.h"
#include "RuntimeConfig.h"
#include "schedule.h"
#include "Concurrency/ConcurrencyModel.h"
#include "ExceptionManager.h"
#include "ExceptionManager.inline.h"
#include "Mutator/Mutator.inline.h"
#if defined(CANGJIE_SANITIZER_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#include "CpuProfiler/CpuProfiler.h"
namespace MapleRuntime {
#ifdef __cplusplus
extern "C" {
#endif

static size_t g_initStackSize = 0;
static size_t g_sysmemSize = 1 * GB;

enum TimeUnit : uint32_t {
    SECOND = 0,
    MILLI_SECOND = 1,
    MICRO_SECOND = 2,
    NANO_SECOND = 3,
};

static void CheckSysmemSize()
{
#if defined(_WIN64)
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    bool ret = GlobalMemoryStatusEx(&memInfo);
    if (ret) {
        g_sysmemSize = memInfo.ullTotalPhys;
    } else {
        LOG(RTLOG_ERROR, "Get system memory failed.\n");
    }
#elif defined(__APPLE__)
    const int sz = 2;
    int mib[sz];
    size_t length = sizeof(g_sysmemSize);
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    sysctl(mib, sz, &g_sysmemSize, &length, nullptr, 0);
#else
    struct sysinfo memInfo;
    int ret = sysinfo(&memInfo);
    if (ret == 0) {
        g_sysmemSize = memInfo.totalram * memInfo.mem_unit;
    } else {
        LOG(RTLOG_ERROR, "Get system memory failed. msg: %s.\n", strerror(errno));
    }
#endif
}

/**
 * Init runtime's heap size from environment variable.
 * The unit must be added when configuring "cjHeapSize", it supports "kb", "mb", "gb".
 * Valid heap size range is [4MB, system memory size].
 * for example:
 *     export cjHeapSize = 32GB
 */
static size_t InitHeapSize(size_t defaultParam)
{
    auto env = std::getenv("cjHeapSize");
    if (env == nullptr) {
        return defaultParam;
    }
    size_t size = CString::ParseSizeFromEnv(env);

#if defined(__OHOS__) || defined(__ANDROID__)
    // 64UL * KB: The minimum heap size in OHOS, measured in KB, the value is 64MB.
    size_t minSize = 64UL * KB;
#else
    // 4UL * KB: The minimum heap size, measured in KB, the value is 4MB.
    size_t minSize = 4UL * KB;
#endif
    size_t maxSize = g_sysmemSize / KB;
    if (size >= minSize && size <= maxSize) {
        return size;
    } else {
        LOG(RTLOG_ERROR,
            "Unsupported cjHeapSize parameter. The unit must be added when configuring with positive integer value, "
            "it supports 'KB', 'MB', 'GB'. Valid cjHeapSize range is [%zuMB, system memory size].\n",
            minSize / KB);
    }
    return defaultParam;
}

static size_t InitRegionSize(size_t defaultParam)
{
    auto env = std::getenv("cjRegionSize");
    if (env == nullptr) {
        return defaultParam;
    }
    size_t size = CString::ParseSizeFromEnv(env);
    // The minimum region size is system page size, measured in KB.
    size_t minSize = MapleRuntime::MRT_PAGE_SIZE / KB;
    // 64UL: The maximum region size, measured in KB, the value is 2048 KB.
    size_t maxSize = 2 * 1024UL;
    if (size >= minSize && size <= maxSize) {
        return size;
    } else {
        LOG(RTLOG_ERROR, "Unsupported cjRegionSize parameter. The unit must be added "
            "when configuring with positive integer value. "
            "Valid cjRegionSize range is [%zuKB, 2048KB].\n", minSize);
    }
    return defaultParam;
}

static double InitPercentParameterIncl(const char* name, double minSize, double maxSize, double defaultParam)
{
    auto env = std::getenv(name);
    if (env == nullptr) {
        return defaultParam;
    }
    double size = CString::ParseValidFromEnv(env);
    if (size - minSize >= 0 && maxSize - size >= 0) {
        return size;
    } else {
        LOG(RTLOG_ERROR, "Unsupported %s parameter. The value must be a positive decimal. "
                "Valid %s range is [%f, %f].\n", name, name, minSize, maxSize);
    }
    return defaultParam;
}

static double InitPercentParameter(const char* name, double minSize, double maxSize, double defaultParam)
{
    auto env = std::getenv(name);
    if (env != nullptr) {
        double parameter = CString::ParsePosDecFromEnv(env);
        if (parameter - minSize > 0 && maxSize - parameter >= 0) {
            return parameter;
        } else {
            LOG(RTLOG_ERROR, "Unsupported %s parameter. The value must be a positive decimal. "
                "Valid %s range is (%f, %f].\n", name, name, minSize, maxSize);
        }
    }
    return defaultParam;
}

static size_t InitSizeParameter(const char* name, size_t minSize, size_t defaultParam)
{
    auto env = std::getenv(name);
    if (env != nullptr) {
        size_t parameter = CString::ParseSizeFromEnv(env);
        if (parameter > minSize) {
            return parameter;
        } else {
            LOG(RTLOG_ERROR, "Unsupported %s parameter. The unit must be added "
                "when configuring with positive integer value. "
                "Valid %s range must be greater than %zuKB.\n",
                name, name, minSize);
        }
    }
    return defaultParam;
}

static uint64_t InitTimeParameter(const char* name, uint64_t minSize, uint64_t defaultParam)
{
    auto env = std::getenv(name);
    if (env != nullptr) {
        uint64_t parameter = CString::ParseTimeFromEnv(env);
        if (parameter > minSize) {
            return parameter;
        } else {
            LOG(RTLOG_ERROR, "Unsupported %s parameter. The unit must be added "
                "when configuring with positive integer value. "
                "Valid %s range must be greater than %lluns.\n", name, name,
                static_cast<unsigned long long>(minSize));
        }
    }
    return defaultParam;
}

static double InitDecParameter(const char* name, double minSize, double defaultParam)
{
    auto env = std::getenv(name);
    if (env != nullptr) {
        double parameter = CString::ParsePosDecFromEnv(env);
        if (parameter - minSize > 0) {
            return parameter;
        } else {
            LOG(RTLOG_ERROR, "Unsupported %s parameter. The value must be a positive decimal. "
                "Valid %s range must be greater than %f.\n", name, name,
                minSize);
        }
    }
    return defaultParam;
}

/**
 * Init light-weight-thread stack size from environment variable.
 * The unit must be added when configuring "cjStackSize", it supports "kb", "mb", "gb".
 * Valid stack size range is [64KB, 1GB].
 * for example:
 *     export cjStackSize = 100kb
 */
static size_t InitCoStackSize()
{
#ifdef _WIN64
    size_t defaultStackSize = 128; // default 128KB in windows, measured in KB
#elif defined(CANGJIE_SANITIZER_SUPPORT)
    // cus sanitizer calls tons of instrumentation, which use more stack memory than normal does
    size_t defaultStackSize = 2048; // default 2MB in sanitizer version, measured in KB
#elif defined(__OHOS__) || defined(__ANDROID__) || defined(__APPLE__)
    size_t defaultStackSize = 1024; // default 1MB in OHOS/ANDROID/MACOS, measured in KB
#else
    size_t defaultStackSize = 128; // default 128KB, measured in KB
#endif
    size_t stackSize = 0;
    auto env = std::getenv("cjStackSize");
    if (env == nullptr) {
        return defaultStackSize;
    }
    stackSize = CString::ParseSizeFromEnv(env);
#ifdef _WIN64
    const size_t minStackSize = 128; // min: 128KB.
#else
    const size_t minStackSize = 64; // min: 64KB.
#endif
    const size_t maxStackSize = 1UL * MB; // max: 1GB.
    if (stackSize >= minStackSize && stackSize <= maxStackSize) {
        return stackSize;
    } else {
        LOG(RTLOG_ERROR,
            "Unsupported cjStackSize parameter. The unit must be added when configuring with positive integer value, "
            "it supports 'KB', 'MB', 'GB'. "
            "Valid cjStackSize range is [128KB, 1GB] in Windows or [64KB, 1GB] in other systems.\n");
    }
    return defaultStackSize;
}

/**
 * Determine the max concurrency processors of cangjie program.
 * If the environment variable `cjProcessorNum` is set, check whether it is in range (0, CPU_CORE * 2], use it if yes.
 * Otherwise check whether the value of CPU_CORE is 0, use it if not.
 * Otherwise use the default value 8.
 */
static uint32_t InitProcessorNum()
{
    unsigned int cpus = std::thread::hardware_concurrency();
    uint32_t defaultProcs = cpus != 0 ? static_cast<uint32_t>(cpus) : 8;
    auto env = CString(std::getenv("cjProcessorNum"));
    if (env.Str() == nullptr) {
        return defaultProcs;
    }
    CString s = env.RemoveBlankSpace();
    if (CString::IsPosNumber(s)) {
        uint32_t custom = std::strtol(s.Str(), nullptr, 0);
        const unsigned int maxMultiple = 2;
        if (custom > 0 && custom <= (cpus * maxMultiple)) {
            return custom;
        } else {
            LOG(RTLOG_ERROR,
                "Unsupported cjProcessorNum parameter. The value must be a positive integer. "
                "Valid cjProcessorNum range is (0, 2 * hardware_concurrency].\n");
        }
    }
    return defaultProcs;
}

void* StartMainTask(void* arg, unsigned int len)
{
    ScheduleHandle scheduler = MapleRuntime::Runtime::Current().GetConcurrencyModel().GetThreadScheduler();
    ASSERT(arg != nullptr);
    auto lwtData = static_cast<LWTData*>(arg);
    auto execute = lwtData->execute;
    Mutator* mutator = MutatorManager::Instance().CreateMutator();
    uintptr_t threadData = MRT_GetThreadLocalData();
    MRT_PreRunManagedCode(mutator, 0, reinterpret_cast<ThreadLocalData*>(threadData));
    reinterpret_cast<ThreadLocalData*>(threadData)->isCJProcessor = true;
    int32_t res = static_cast<int32_t>(
        reinterpret_cast<uintptr_t>(ExecuteCangjieStub(0, 0, 0, execute, reinterpret_cast<void*>(threadData), 0)));
#ifdef CANGJIE_TSAN_SUPPORT
    MapleRuntime::Sanitizer::TsanFinalize();
#endif
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXEC, CJThreadId());
    TRACE_START_ASYNC(TRACE_CJTHREAD_EXIT, CJThreadId());
#elif defined(__ANDROID__)
    TRACE_FINISH();
    MapleRuntime::CString traceInfo = MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXIT, CJThreadId());
    TRACE_START(traceInfo.Str());
#endif
    CpuProfiler::GetInstance().TryStopSampling();
    RTErrorCode rtCode = SetRuntimeFiniFlag();
    if (rtCode != E_OK) {
        LOG(RTLOG_FATAL, "Finish cj runtime failed for %d\n", rtCode);
    }
    MutatorManager::Instance().TransitMutatorToExit();
    ScheduleStop(scheduler);
    CangjieRuntime::FiniAndDelete();
#ifdef __OHOS__
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXIT, CJThreadId());
#elif defined(__ANDROID__)
    TRACE_FINISH();
#endif
    // If the return value is 0, func may not be successful.
    // If the value of res is a wild value (cj exception), -1 is returned.
    constexpr uint8_t errRet = 255;
    if (res > errRet || res < 0) {
        res = -1;
    }
    exit(res);
}

// The following functions are used to create threads with futures.
#if defined(__APPLE__) && defined(__aarch64__)
using FutureFunc = UnitType (*)(void*, void*, void*);
#else
using FutureFunc = UnitType (*)(...);
#endif
static UnitType g_ut;

void* WrapperTask(void* arg, unsigned int len)
{
    ASSERT(arg != nullptr);
    auto lwtData = static_cast<LWTData*>(arg);
    auto execute = lwtData->execute;
    uintptr_t threadData = MRT_GetThreadLocalData();
    // mutator has been set to a valid pointer before.
    Mutator* mutator = reinterpret_cast<ThreadLocalData*>(threadData)->mutator;
    MRT_PreRunManagedCode(mutator, 0, reinterpret_cast<ThreadLocalData*>(threadData));
    BaseObject* future = Heap::GetBarrier().ReadStaticRef(*(reinterpret_cast<RefField<>*>(&lwtData->obj)));
    TypeInfo* typeInfo = future->GetTypeInfo();
#if defined(__aarch64__)
    ExecuteCangjieStub(future, typeInfo, 0, execute, reinterpret_cast<void*>(threadData), &g_ut);
#elif defined(__arm__)
    ExecuteCangjieStub(&g_ut, future, typeInfo, execute, threadData);
#elif defined(__x86_64__)
    ExecuteCangjieStub(&g_ut, future, typeInfo, execute, threadData);
#endif
    MutatorManager::Instance().TransitMutatorToExit();
    return nullptr;
}

void* MCC_NewCJThread(void* execute, void* future, void* scheduler)
{
#if defined(CANGJIE_TSAN_SUPPORT)
    void* pc = __builtin_return_address(0);
    MapleRuntime::Sanitizer::TsanFuncEntry(pc);
#endif
    LWTData data;
    data.execute = execute;
    data.threadObject = nullptr;
    data.obj = nullptr;
    RefField<>* runtimeRootField = reinterpret_cast<RefField<>*>(&data.obj);
    Heap::GetBarrier().WriteStaticRef(*runtimeRootField, reinterpret_cast<BaseObject*>(future));
    if (!scheduler) {
        scheduler = MapleRuntime::Runtime::Current().GetConcurrencyModel().GetThreadScheduler();
    }
    CJThreadHandle handle = CJThreadNew(scheduler, nullptr, WrapperTask, &data, sizeof(LWTData));
    if (handle == nullptr) {
#if defined(CANGJIE_TSAN_SUPPORT)
        MapleRuntime::Sanitizer::TsanFuncExit();
#endif
        return nullptr;
    }
#if defined(CANGJIE_TSAN_SUPPORT)
    MapleRuntime::Sanitizer::TsanFuncExit();
#endif
    return handle;
}

bool MRT_NewForeignCJThread()
{
    if (ThreadLocal::IsCJProcessor() || ThreadLocal::GetMutator() != nullptr) {
        return false;
    }
    TRACE_START("CJRT_INVOKE_CJTASK");
    ScheduleHandle scheduler = nullptr;
    if (ThreadLocal::GetForeignCJThread() == nullptr) {
        auto runtime = reinterpret_cast<MapleRuntime::CangjieRuntime*>(&MapleRuntime::Runtime::Current());
        scheduler = runtime->CreateSubSchedulerAndInit(SCHEDULE_FOREIGN_THREAD);
        CJThreadAttr attr;
        CJThreadAttrInit(&attr);
        CJThreadAttrNameSet(&attr, "cangjie");
        LWTData data = {};
        CJThreadHandle cjthread =
            CJThreadNewToSchedule(scheduler, (const struct CJThreadAttr*)(&attr), WrapperTask, &data, sizeof(LWTData));
        MutatorManager::Instance().SetMainThreadHandle(cjthread);
        CJThreadPreemptOffCntAdd();
        RebindCJThread(cjthread);
        ThreadLocal::SetForeignCJThread(cjthread);
        ThreadLocal::SetSchedule(scheduler);
        ThreadLocal::SetProtectAddr(nullptr);
        ScheduleNetpollInit(); // Initializes netpool only on the first execution.
    }

    void* cjthread = ThreadLocal::GetForeignCJThread();
    ThreadLocal::SetCJThread(cjthread);
    Mutator* mutator = reinterpret_cast<Mutator*>(CJThreadGetMutator());
    MutatorManager::Instance().BindMutator(*mutator);
    if (scheduler == nullptr) {
        scheduler = GetCJThreadScheduler();
        ThreadLocal::SetSchedule(scheduler);
        ThreadLocal::SetProtectAddr(nullptr);
    }
    mutator->InitForeignCJThread();
    // 1: state is SCHEDULE_RUNNING
    SetSchedulerState(1);
#ifdef __OHOS__
    TRACE_START_ASYNC(TRACE_CJTHREAD_EXEC, CJThreadGetId(cjthread));
#elif defined(__ANDROID__)
    MapleRuntime::CString traceInfo = MapleRuntime::TraceInfoFormat(TRACE_CJTHREAD_EXEC, CJThreadGetId(cjthread));
    TRACE_START(traceInfo.Str());
#endif
    return true;
}

bool MRT_EndForeignCJThread()
{
    if (ThreadLocal::IsCJProcessor()) {
        return false;
    }
#if defined(__OHOS__)
    unsigned long long cjthreadId = CJThreadGetId(ThreadLocal::GetForeignCJThread());
    TRACE_FINISH_ASYNC(TRACE_CJTHREAD_EXEC, cjthreadId);
#elif defined(__ANDROID__)
    TRACE_FINISH();
#endif
    MapleRuntime::ExceptionManager::CheckAndDumpException();
    MapleRuntime::Runtime::Current().GetMutatorManager().TransitMutatorToExit();
    ThreadLocal::SetCJThread(nullptr);
    // 0: state is SCHEDULE_INIT
    SetSchedulerState(0);
    TRACE_FINISH();
    return true;
}

static void* WrapperExclusiveClosure(void* arg, unsigned int len)
{
    ASSERT(arg != nullptr);
    auto lwtData = static_cast<LWTData*>(arg);
    uintptr_t threadData = MRT_GetThreadLocalData();
    Mutator* mutator = reinterpret_cast<ThreadLocalData*>(threadData)->mutator;
    MRT_PreRunManagedCode(mutator, 0, reinterpret_cast<ThreadLocalData*>(threadData));
    lwtData->threadObject = nullptr;
    BaseObject* executeClosure = Heap::GetBarrier().ReadStaticRef(reinterpret_cast<RefField<false>&>(lwtData->execute));
    BaseObject* closureObj = Heap::GetBarrier().ReadStaticRef(reinterpret_cast<RefField<false>&>(lwtData->obj));
#if defined(__aarch64__)
    ExecuteExclusiveCangjieStub(closureObj, nullptr, executeClosure, reinterpret_cast<void*>(threadData), &g_ut);
#elif defined(__x86_64__)
    ExecuteExclusiveCangjieStub(&g_ut, nullptr, closureObj, executeClosure, reinterpret_cast<void*>(threadData));
#elif defined(__arm__)
    TypeInfo* ti = closureObj->GetTypeInfo();
    ExecuteExclusiveCangjieStub(&g_ut, ti, closureObj, executeClosure, reinterpret_cast<void*>(threadData));
#endif
    MutatorManager::Instance().TransitMutatorToExit();
    return nullptr;
}

void* MCC_NewExclusiveCJThread(void* executeClosure, void* closurePtr, void* futureTi)
{
    LWTData data;
    data.execute = nullptr;
    data.obj = nullptr;
    data.threadObject = futureTi;
    RefField<>* executeRootField = reinterpret_cast<RefField<>*>(&data.obj);
    Heap::GetBarrier().WriteStaticRef(*executeRootField, reinterpret_cast<BaseObject*>(closurePtr));
    RefField<>* objRootField = reinterpret_cast<RefField<>*>(&data.execute);
    Heap::GetBarrier().WriteStaticRef(*objRootField, reinterpret_cast<BaseObject*>(executeClosure));
    return ExclusiveCJThreadNew(WrapperExclusiveClosure, &data, sizeof(LWTData));
}

static void ResetFinalizerThreadLocal()
{
    ThreadLocal::SetCJThread(nullptr);
    ThreadLocal::SetForeignCJThread(nullptr);
    ThreadLocal::SetSchedule(nullptr);
    ThreadLocal::SetAllocBuffer(nullptr);
    ThreadLocal::SetMutator(nullptr);
    ThreadLocal::SetProtectAddr(nullptr);
    ThreadLocal::SetCJProcessorFlag(false);
    ThreadLocal::SetThreadType(ThreadType::CJ_PROCESSOR);
}

static void FiniAndFreeFinalizerScheduler(ScheduleHandle scheduler)
{
    if (scheduler == nullptr) {
        return;
    }
    auto runtime = reinterpret_cast<MapleRuntime::CangjieRuntime*>(&MapleRuntime::Runtime::Current());
    if (!runtime->FiniSubScheduler(scheduler)) {
        LOG(RTLOG_ERROR, "failed to fini finalizer sub scheduler");
    }
    SetSchedulerState(5); // 5: state is SCHEDULE_EXITED.
    ScheduleNonDefaultFree(scheduler);
}

void* NewFinalizerCJThread()
{
    // prepare foreign scheduler
    ScheduleHandle scheduler = nullptr;
    auto runtime = reinterpret_cast<MapleRuntime::CangjieRuntime*>(&MapleRuntime::Runtime::Current());
    scheduler = runtime->CreateSubSchedulerAndInit(SCHEDULE_FOREIGN_THREAD);
    if (scheduler == nullptr) {
        LOG(RTLOG_ERROR, "failed to create finalizer scheduler");
        return nullptr;
    }

    // Init finalizer cjthread
    CJThreadAttr attr;
    CJThreadAttrInit(&attr);
    CJThreadAttrNameSet(&attr, "cangjie");
    LWTData data = {};
    CJThreadHandle cjthread = CJThreadNewToSchedule(scheduler, (const struct CJThreadAttr*)(&attr),
                                                    WrapperTask, &data, sizeof(LWTData),
                                                    CJTHREAD_CREATE_SOURCE_FINALIZER);
    if (cjthread == nullptr) {
        LOG(RTLOG_ERROR, "failed to create finalizer cjthread");
        FiniAndFreeFinalizerScheduler(scheduler);
        return nullptr;
    }

    // Init finalizer thread local
    ThreadLocal::SetThreadType(ThreadType::FP_THREAD);
    ThreadLocal::SetCJProcessorFlag(true);
    ThreadLocal::SetCJThread(cjthread);
    CJThreadPreemptOffCntAdd();
    RebindCJThread(cjthread);
    ThreadLocal::SetForeignCJThread(cjthread);
    ThreadLocal::SetSchedule(scheduler);
    ThreadLocal::SetProtectAddr(nullptr);
    ScheduleNetpollInit(); // Initializes netpool only on the first execution.

    // Init finalizer mutator
    Mutator* mutator = static_cast<Mutator*>(CJThreadGetMutator());
    CHECK_DETAIL(mutator != nullptr, "create is null when create finalizer cjthread");
    MutatorManager::Instance().MutatorManagementRLock();
    mutator->InitTid();
    mutator->SetManagedContext(false);
    MutatorManager::Instance().BindMutator(*mutator);
    ThreadLocal::SetMutator(mutator);
    MutatorManager::Instance().MutatorManagementRUnlock();
    ThreadLocalData* threadData = reinterpret_cast<ThreadLocalData*>(MRT_GetThreadLocalData());
    // Managed-entry setup may block on sync/STW, so do not hold the mutator
    // management lock across it.
    MRT_PreRunManagedCode(mutator, 2, threadData); // 2 layers

    SetSchedulerState(1);
    return cjthread;
}

void EndFinalizerCJThread()
{
    auto* schedule = reinterpret_cast<ScheduleHandle>(ThreadLocal::GetSchedule());
    Mutator* mutator = ThreadLocal::GetMutator();
    CHECK_DETAIL(mutator != nullptr, "EndFinalizerCJThread with null mutator");
    MutatorManager::Instance().MutatorManagementRLock();
    (void)mutator->LeaveSaferegion();
    mutator->ResetMutator();
    MutatorManager::Instance().UnbindMutator(*mutator);
    MutatorManager::Instance().MutatorManagementRUnlock();

    // Free finalizer scheduler, cjthread and mutator
    FiniAndFreeFinalizerScheduler(schedule);
    ResetFinalizerThreadLocal();
}

/**
 * The thread entry function provided by runtime.
 * It is a wrapper function of the entry function from Cangjie frontend.
 */
static void* WrapperOfExecuteClosure(void* arg, unsigned int len)
{
    ASSERT(arg != nullptr);
    auto lwtData = static_cast<LWTData*>(arg);
    auto executeClosure = lwtData->execute;
    uintptr_t threadData = MRT_GetThreadLocalData();
    // mutator has been set to a valid pointer before.
    Mutator* mutator = reinterpret_cast<ThreadLocalData*>(threadData)->mutator;
    MRT_PreRunManagedCode(mutator, 0, reinterpret_cast<ThreadLocalData*>(threadData));
    TypeInfo* futureTi = static_cast<TypeInfo*>(lwtData->threadObject);
    // threadObject is used to pass TypeInfo of future. After use, need set to nullptr.
    lwtData->threadObject = nullptr;
    BaseObject* closureObj = Heap::GetBarrier().ReadStaticRef(reinterpret_cast<RefField<false>&>(lwtData->obj));
#if defined(__aarch64__)
    ExecuteCangjieStub(closureObj, futureTi, 0, executeClosure, reinterpret_cast<void*>(threadData), &g_ut);
#elif defined(__arm__)
    ExecuteCangjieStub(&g_ut, closureObj, futureTi, executeClosure, threadData);
#elif defined(__x86_64__)
    ExecuteCangjieStub(&g_ut,      /* arg0: sret */
                       closureObj, /* arg1 */
                       futureTi,
                       executeClosure, threadData);
#endif
    MutatorManager::Instance().TransitMutatorToExit();
    return nullptr;
}

void* MCC_NewCJThreadNoReturn(void* executeClosure, void* closurePtr, void* scheduler, void* futureTi)
{
    LWTData data;
    data.execute = executeClosure;
    data.obj = nullptr;
    data.threadObject = futureTi; // used to pass TypeInfo of future
    RefField<>* runtimeRootField = reinterpret_cast<RefField<>*>(&data.obj);
    Heap::GetBarrier().WriteStaticRef(*runtimeRootField, reinterpret_cast<BaseObject*>(closurePtr));
    if (!scheduler) {
        scheduler = MapleRuntime::Runtime::Current().GetConcurrencyModel().GetThreadScheduler();
    }
    CJThreadHandle handle =
        CJThreadNewToSchedule(scheduler, nullptr, WrapperOfExecuteClosure, &data, sizeof(LWTData));
    return handle;
}

/**
 * Determine the default stack size and heap size according to system memory.
 * If system memory size is less then 1GB, heap size is 64MB and stack size is 64KB.
 * Otherwise heap size is 256MB and stack size is 1MB.
 */
static RuntimeParam InitRuntimeParam()
{
    CheckSysmemSize();
    size_t initHeapSize = InitHeapSize(g_sysmemSize > 1 * GB ? 256 * KB : 64 * KB);
    RuntimeParam param = {
        .heapParam = {
#if defined(__OHOS__) || defined(__ANDROID__)
                // Default region size is 1024KB.
                .regionSize = InitRegionSize(1024UL),
#else
                // Default region size is 64KB.
                .regionSize = InitRegionSize(64UL),
#endif
                // Default heap size is 256MB if system memory size is greater than 1GB, otherwise is 64MB.
                .heapSize = initHeapSize,
                /*
                 * The minimux live region threshold is 0% of region,
                 * the maximum is 100% of region, default to 80% of region.
                 */
                .exemptionThreshold = InitPercentParameter("cjExemptionThreshold", 0.0, 1.0, 0.8),
                /*
                 * The minimux heap utilization is 0% of heap,
                 * the maximum is 100% of heap, default to 80% of heap.
                 */
                .heapUtilization = InitPercentParameter("cjHeapUtilization", 0.0, 1.0, 0.8),
                // Default heap growth is (1 + 0.15) = 1.15.
                .heapGrowth = InitDecParameter("cjHeapGrowth", 0.0, 0.15),
                // Default allocation rate is 10240MB/s.
                .allocationRate = InitDecParameter("cjAllocationRate", 0.0, 10240),
                // Default allocation wait time is 1000ns.
                .allocationWaitTime = static_cast<size_t>(InitTimeParameter("cjAllocationWaitTime", 0, 1000)),
            },
        .gcParam = {
                // Default gc threshold is heapSize.
                .gcThreshold = InitSizeParameter("cjGCThreshold", 0, initHeapSize) * KB,
                // Default garbage ration is 50% of from space.
                .garbageThreshold = InitPercentParameterIncl("cjGarbageThreshold", 0.0, 1.0, 0.5),
                // Default GC interval is 150ms.
                .gcInterval = InitTimeParameter("cjGCInterval", 0, 150 * MILLI_SECOND_TO_NANO_SECOND),
                // Default backup GC interval is 240s.
                .backupGCInterval = InitTimeParameter("cjBackupGCInterval", 0, 240 * SECOND_TO_NANO_SECOND),
                // Default GC thread factor is 2.
                .gcThreads = 2,
            },
        .logParam = {
            .logLevel = LogFile::GetLogLevel(),
        },
        .coParam = {
                // Default thread stack size is 1 * KB KB = 1MB.
                .thStackSize = 1 * KB,
                .coStackSize = InitCoStackSize(),
                .processorNum = InitProcessorNum(),
            },
    };
    return param;
}

void MRT_CjRuntimeInit()
{
    RuntimeParam param = InitRuntimeParam();
    CangjieRuntime::CreateAndInit(param);
    RTErrorCode rtCode = SetRuntimeInitFlag();
    if (rtCode != E_OK) {
        LOG(RTLOG_FATAL, "Init cj runtime failed for %d\n", rtCode);
    }
}

void MRT_SetCommandLineArgs(int argc, const char* argv[])
{
    reinterpret_cast<CangjieRuntime*>(&MapleRuntime::Runtime::Current())->SetCommandLinesArgs(argc, argv);
    return;
}

const char** MRT_GetCommandLineArgs()
{
    return reinterpret_cast<CangjieRuntime*>(&MapleRuntime::Runtime::Current())->GetCommandLineArgs();
}

void MRT_CjRuntimeStart(void* execute)
{
    ScheduleHandle scheduler = MapleRuntime::Runtime::Current().GetConcurrencyModel().GetThreadScheduler();
    LWTData lwtData;
    lwtData.execute = execute;
    lwtData.fn = nullptr;
    lwtData.obj = nullptr;
    lwtData.threadObject = nullptr;
    CJThreadAttr attr;
    CJThreadAttrInit(&attr);
    CJThreadAttrStackSizeSet(&attr, g_initStackSize * KB); // Set main task stack size.
    CJThreadAttrNameSet(&attr, "cangjie");
    CJThreadHandle cjthread = CJThreadNew(scheduler, &attr, StartMainTask, &lwtData, sizeof(LWTData));
    MutatorManager::Instance().SetMainThreadHandle(cjthread);
    ScheduleStart();
}

int MRT_NewWaitQueue(void* waitQueuePtr) { return WaitqueueNew(reinterpret_cast<Waitqueue*>(waitQueuePtr)); }

bool ReportWaitQueueRetMsg(int err)
{
    if (err == 0) {
        return true;
    }
    if (err == WAIT_QUEUE_TIMEOUT) {
        return false;
    }
    if (err == ERRNO_QUEUE_DOESNT_EXIST) {
        LOG(RTLOG_INFO, "The waiting queue passed by the user does not exist!\n");
    }
    if (err == ERRNO_TIMER_STOP_FAILED) {
    }
    if (err == ERRNO_QUEUE_IS_EMPTY) {
    }
    if (err == ERRNO_CALLBACK_RETURN_TRUE) {
    }
    if (err == ERRNO_MALLOC_FAILED) {
        LOG(RTLOG_INFO, "Memory allocation failed!\n");
    }
    if (err == ERRNO_TIMER_STATE_INVALID) {
        LOG(RTLOG_INFO, "Illegal waiting time: time cannot be negative!\n");
    }
    return true;
}

void ReportSemRetMsg(int err)
{
    if (err == 0) {
        return;
    }
    if (err == ERRNO_SEMA_DOESNT_EXIST) {
        LOG(RTLOG_ERROR, "The semaphore transferred by the user does not exist!\n");
    }
}

bool MRT_SuspendWithTimeout(void* wq, WqCallbackFunc callBack, void* callBackObj, int64_t timeOut)
{
    auto handle = reinterpret_cast<Waitqueue*>(wq);
    return ReportWaitQueueRetMsg(WaitqueuePark(handle, timeOut, callBack, callBackObj, false));
}

void MRT_ResumeOne(void* wq, WqCallbackFunc callBack, void* callBackObj)
{
    auto handle = reinterpret_cast<Waitqueue*>(wq);
    ReportWaitQueueRetMsg(WaitqueueWakeOne(handle, callBack, callBackObj));
}

void MRT_ResumeAll(void* wq, WqCallbackFunc callBack, void* callBackObj)
{
    auto handle = reinterpret_cast<Waitqueue*>(wq);
    ReportWaitQueueRetMsg(WaitqueueWakeAll(handle, callBack, callBackObj));
}

int MRT_NewSem(void* semPtr) { return SemaNew(reinterpret_cast<Sema*>(semPtr), 0); }

void MRT_SemAcquire(void* sem, bool isPushToHead)
{
    auto handle = reinterpret_cast<Sema*>(sem);
    ReportSemRetMsg(SemaAcquire(handle, isPushToHead));
}

void MRT_SemRelease(void* sem)
{
    auto handle = reinterpret_cast<Sema*>(sem);
    ReportSemRetMsg(SemaRelease(handle));
}

int64_t MRT_GetCurrentThreadID() { return static_cast<int64_t>(CJThreadId()); }

struct SubSchedulerContextData {
    ScheduleHandle schedule;
    std::condition_variable* conditionVar;
    std::atomic_bool* inited;
    std::string threadName;
};

void* MRT_StartSubScheduler(void* args)
{
    auto runtime = reinterpret_cast<CangjieRuntime*>(&MapleRuntime::Runtime::Current());
    struct SubSchedulerContextData* data = static_cast<struct SubSchedulerContextData*>(args);
    void* schedule = runtime->CreateSubSchedulerAndInit();
#ifdef __APPLE__
    CHECK_PTHREAD_CALL(pthread_setname_np, (data->threadName.c_str()), "set sub-scheduler thread name");
#elif defined(__linux__) || defined(hongmeng)
    CHECK_PTHREAD_CALL(prctl, (PR_SET_NAME, data->threadName.c_str()), "set sub-scheduler thread name");
#endif
    data->schedule = schedule;
    data->inited->store(true);
    data->conditionVar->notify_all();
    ThreadLocal::SetCJProcessorFlag(true);
    ScheduleStart();
    return nullptr;
}

int8_t MRT_StopSubScheduler(void* schedule)
{
    auto runtime = reinterpret_cast<CangjieRuntime*>(&MapleRuntime::Runtime::Current());
    if (!runtime->FiniSubScheduler(schedule)) {
        LOG(RTLOG_ERROR, "Fail to stop sub-scheduler");
        return 1;
    }
    return 0;
}

static void ResolveCycleRefImpl()
{
    Heap::GetHeap().GetCollector().ResolveCycleRef();
}
extern "C" void CJ_MRT_RolveCycleRef()
{
    RunResolveCycle(reinterpret_cast<void*>(&ResolveCycleRefImpl));
}

const void* MRT_RuntimeNewSubScheduler()
{
    static int id = 0;
    std::condition_variable conditionVariable;
    std::atomic_bool subScheduleInited = ATOMIC_VAR_INIT(false);
    std::mutex mtx;
    struct SubSchedulerContextData args = {
        .schedule = nullptr,
        .conditionVar = &conditionVariable,
        .inited = &subScheduleInited,
        .threadName = ""
    };

    pthread_t thread;
    pthread_attr_t attr;
    size_t stackSize = CangjieRuntime::GetConcurrencyParam().thStackSize * MapleRuntime::KB;
    std::string threadName = "sub-schedule" + std::to_string(id++);
    args.threadName = threadName;

    CHECK_PTHREAD_CALL(pthread_attr_init, (&attr), "init pthread attr");
    CHECK_PTHREAD_CALL(pthread_attr_setdetachstate, (&attr, PTHREAD_CREATE_JOINABLE), "set pthread joinable");
    CHECK_PTHREAD_CALL(pthread_attr_setstacksize, (&attr, stackSize), "set pthread stacksize");
    CHECK_PTHREAD_CALL(pthread_create, (&thread, &attr, MRT_StartSubScheduler, &args), "create sub-scheduler thread");
#ifdef __WIN64
    CHECK_PTHREAD_CALL(pthread_setname_np, (thread, threadName.c_str()), "set sub-scheduler thread name");
#endif
    CHECK_PTHREAD_CALL(pthread_attr_destroy, (&attr), "destroy pthread attr");
    // Waiting for runtime initialize completely before continue.
    std::unique_lock<std::mutex> lck(mtx);
    conditionVariable.wait(lck, [&subScheduleInited]() { return subScheduleInited.load(); });
    return args.schedule;
}

#ifdef __APPLE__
MRT_EXPORT void CJ_MRT_CjRuntimeInit();
__asm__(".global _CJ_MRT_CjRuntimeInit\n\t.set _CJ_MRT_CjRuntimeInit, _MRT_CjRuntimeInit");
MRT_EXPORT void CJ_MRT_CjRuntimeStart(void* execute);
__asm__(".global _CJ_MRT_CjRuntimeStart\n\t.set _CJ_MRT_CjRuntimeStart, _MRT_CjRuntimeStart");
MRT_EXPORT void* CJ_MCC_NewCJThread(void* execute, void* future, void* scheduler);
__asm__(
    ".global _CJ_MCC_NewCJThread\n\t.set _CJ_MCC_NewCJThread, _MCC_NewCJThread");
MRT_EXPORT void* CJ_MCC_NewCJThreadNoReturn(void* executeClosure, void* closurePtr, void* scheduler);
__asm__(
    ".global _CJ_MCC_NewCJThreadNoReturn\n\t.set _CJ_MCC_NewCJThreadNoReturn, "
        "_MCC_NewCJThreadNoReturn");
MRT_EXPORT void CJ_MRT_SetCommandLineArgs(int argc, const char* argv[]);
__asm__(".global _CJ_MRT_SetCommandLineArgs\n\t.set _CJ_MRT_SetCommandLineArgs, _MRT_SetCommandLineArgs");
MRT_EXPORT const char** CJ_MRT_GetCommandLineArgs();
__asm__(".global _CJ_MRT_GetCommandLineArgs\n\t.set _CJ_MRT_GetCommandLineArgs, _MRT_GetCommandLineArgs");
MRT_EXPORT const void* CJ_MRT_RuntimeNewSubScheduler();
__asm__(".global _CJ_MRT_RuntimeNewSubScheduler\n\t.set _CJ_MRT_RuntimeNewSubScheduler, _MRT_RuntimeNewSubScheduler");
MRT_EXPORT int8_t CJ_MRT_StopSubScheduler(void* schedule);
__asm__(".global _CJ_MRT_StopSubScheduler\n\t.set _CJ_MRT_StopSubScheduler, _MRT_StopSubScheduler");
#else
MRT_EXPORT void CJ_MRT_CjRuntimeInit() __attribute__((alias("MRT_CjRuntimeInit")));
MRT_EXPORT void CJ_MRT_CjRuntimeStart(void* execute)
    __attribute__((alias("MRT_CjRuntimeStart")));
MRT_EXPORT void* CJ_MCC_NewCJThread(void* execute, void* future, void *scheduler)
    __attribute__((alias("MCC_NewCJThread")));
MRT_EXPORT void* CJ_MCC_NewCJThreadNoReturn(void* executeClosure, void* closurePtr, void* scheduler)
    __attribute__((alias("MCC_NewCJThreadNoReturn")));
MRT_EXPORT void CJ_MRT_SetCommandLineArgs(int argc, const char* argv[])
    __attribute__((alias("MRT_SetCommandLineArgs")));
MRT_EXPORT const char** CJ_MRT_GetCommandLineArgs() __attribute__((alias("MRT_GetCommandLineArgs")));
MRT_EXPORT const void* CJ_MRT_RuntimeNewSubScheduler() __attribute__((alias("MRT_RuntimeNewSubScheduler")));
MRT_EXPORT int8_t CJ_MRT_StopSubScheduler(void* schedule) __attribute__((alias("MRT_StopSubScheduler")));
#endif
#ifdef __cplusplus
};
#endif
} // namespace MapleRuntime
