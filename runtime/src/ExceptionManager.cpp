// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.
#include "Base/Log.h"
#include "Base/LogFile.h"
#include "Common/Runtime.h"
#include "Exception/ExceptionCApi.h"
#ifdef __APPLE__
#include "Exception/CFException.h"
#endif
#include "ExceptionManager.inline.h"
#include "Mutator/Mutator.h"
#include "ObjectModel/MObject.h"
#include "UnwindStack/MangleNameHelper.h"
#include "Heap/Collector/CollectorResources.h"
#include "Heap/Collector/GcRequest.h"
#include "Inspector/CjHeapData.h"
namespace MapleRuntime {
std::mutex ExceptionManager::gUncaughtExceptionHandlerMtx;
#if defined(__OHOS__) && (__OHOS__ == 1)
std::mutex ExceptionManager::gEventMtx;
CJEventReportInfo ExceptionManager::eventReportHandler = {nullptr, nullptr};
ExceptionCallbackFunc ExceptionManager::exceptionCallback = nullptr;

void ExceptionManager::RegisterExceptionCallback(ExceptionCallbackFunc callback)
{
    exceptionCallback = callback;
}

ExceptionCallbackFunc ExceptionManager::GetExceptionCallback()
{
    return exceptionCallback;
}
#endif

void ExceptionManager::OutOfMemory()
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    if (!eWrapper.IsThrowingOOME()) {
        eWrapper.SetThrowingOOME(true);
        eWrapper.SetFatalException(false);
        eWrapper.SetExceptionType(ExceptionWrapper::ExceptionType::OUT_OF_MEMORY);

        // ohos Fork child process to perform heap dump asynchronously
        // check environment variable cjHeapDumpOnOOM=on/off
        const char* env = std::getenv("cjHeapDumpOnOOM");
        CString s = CString(env).RemoveBlankSpace();
        env = s.Str();
        if (env && !strcmp(env, "on")) {
#if defined(__OHOS__) && (__OHOS__ == 1)
            // Check cjHeapDumpLog environment variable to trigger oom file dump event
            LOG(RTLOG_INFO, "Check cjHeapDumpLog environment variable to trigger oom file dump event");
            const char* cjHeapDumpLogEnv = std::getenv("cjHeapDumpLog");
            if (cjHeapDumpLogEnv == nullptr || strlen(cjHeapDumpLogEnv) == 0) {
                LOG(RTLOG_INFO, "prepare to report OOM FILEDUMPTASK");
                const char* domain = "FRAMEWORK";
                const char* event = "ARK_STATS_DUMP";

                std::map<std::string, std::string> params;
                params["TYPE"] = "hidumper";
                params["FILE_TYPE"] = "HEAP_DUMP";
                params["DUMP_REASON"] = "OOM";
                params["DUMP_LOG_PATH"] = "EMPTY";

                TriggerEventReport(domain, event, HiSysEventType::FAULT, params);
                LOG(RTLOG_ERROR, "finish reporting OOM FILEDUMPTASK");
                LOG(RTLOG_INFO, "start sleep 5s to wait filedump event to heapdump");
                std::this_thread::sleep_for(std::chrono::seconds(5)); // wait 5s for child process to dump heap
            } else {
                LOG(RTLOG_INFO, "start child process for OOM heap dump");
                pid_t childPid = CjHeapData::ForkAndDumpHeap(-1, true);
                if (childPid < 0) {
                    LOG(RTLOG_ERROR, "Failed to start child process for OOM heap dump");
                } else {
                    LOG(RTLOG_INFO, "start sleep 5s to wait child process finishing OOM heapdump");
                    std::this_thread::sleep_for(std::chrono::seconds(5)); // wait 5s for child process to dump heap
                }
            }
#else
            Heap::GetHeap().GetCollectorResources().RequestHeapDump(GCTask::TaskType::TASK_TYPE_DUMP_HEAP_OOM);
#endif
        }
#if defined(__OHOS__) && (__OHOS__ == 1)
        // Trigger OOM event reporting
        const char* domain = "FRAMEWORK";
        const char* event = "CJ_OOM";
        Heap& heap = Heap::GetHeap();
        size_t activeMemory = heap.GetCurrentCapacity();
        size_t limitSize = heap.GetMaxCapacity();
        LOG(RTLOG_INFO, "OOM: activeMemory=%zu, limitSize=%zu", activeMemory, limitSize);

        std::map<std::string, std::string> params;
        params["LIMIT_SIZE"] = std::to_string(limitSize);
        params["ACTIVE_MEMORY"] = std::to_string(activeMemory);
        params["TYPE"] = "OOMDump";
        params["EVENT_CONFIG"] = "event";
        TriggerEventReport(domain, event, HiSysEventType::FAULT, params);
        LOG(RTLOG_INFO, "OOM event reporting finished");
#endif
        ThrowImplicitException(OOM);
    } else {
        std::vector<uint64_t>& liteFrameInfos = eWrapper.GetLiteFrameInfos();
        liteFrameInfos.clear();
        StackManager::RecordLiteFrameInfos(liteFrameInfos);
        ThrowImplicitException(OOMR);
    }
    eWrapper.SetThrowingOOME(false);
}

void ExceptionManager::LocalRegionOutOfMemory()
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    eWrapper.SetFatalException(false);
    eWrapper.SetExceptionType(ExceptionWrapper::ExceptionType::LOCAL_REGION_OUT_OF_MEMORY);
    ThrowImplicitException(LOCAL_REGION_OOM);
}

MRT_OPTIONAL_DISABLE_TAIL_CALL
void ExceptionManager::StackOverflow(uint32_t adjustedSize __attribute__((unused)), void* ip)
{
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return;
    }
    mutator->StackGuardExpand();
    ExceptionWrapper& eWrapper = mutator->GetExceptionWrapper();
    eWrapper.SetThrowingSOFFramePc(ip);
    eWrapper.SetFatalException(true);
    eWrapper.SetExceptionType(ExceptionWrapper::ExceptionType::STACK_OVERFLOW);
#if defined(__x86_64__)
    if (CangjieRuntime::stackGrowConfig == StackGrowConfig::STACK_GROW_ON) {
        eWrapper.SetAdjustedStackSize(adjustedSize);
    } else {
        eWrapper.SetAdjustedStackSize(COMPENSATE_SIZE);
    }
#elif defined(__aarch64__) || defined(__arm__)
    eWrapper.SetAdjustedStackSize(adjustedSize);
#endif
    ThrowImplicitException(SOF);

    MRT_ThrowPendingException();
}

MRT_OPTIONAL_DISABLE_TAIL_CALL void ExceptionManager::IncompatiblePackageExpection(CString msg)
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    eWrapper.SetExceptionType(ExceptionWrapper::ExceptionType::INCOMPATIBILE_PACKAGE);
    eWrapper.SetExceptionMessage(msg.Str(), strlen(msg.Str()));
    ExceptionRaiser func = Runtime::Current().GetExceptionManager().GetExceptionRaiser();
    if (func == nullptr) {
        LOG(RTLOG_FATAL, "Cangjie initialization failed, implicit exception is nullptr.");
    }
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
    ExecuteCangjieStub(reinterpret_cast<void*>(static_cast<intptr_t>(INCOMP)),  reinterpret_cast<void*>(msg.GetStr()),
                       0, reinterpret_cast<void*>(func), reinterpret_cast<void*>(threadData), 0);

    MRT_ThrowPendingException();
}

#if defined(__OHOS__) && (__OHOS__ == 1)
void ExceptionManager::RegisterUncaughtExceptionHandler(const CJUncaughtExceptionInfo& handler)
{
    std::lock_guard<std::mutex> lock(gUncaughtExceptionHandlerMtx);
    uncaughtExceptionHandler = handler;
}

void ExceptionManager::RegisterEventHandler(const CJEventReportInfo& handler)
{
    std::lock_guard<std::mutex> lock(gEventMtx);
    eventReportHandler = handler;
}

void ExceptionManager::TriggerEventReport(const char* domain, const char* event, size_t hiSysEventType,
    const std::map<std::string, std::string>& params)
{
    std::lock_guard<std::mutex> lock(gEventMtx);
    if (eventReportHandler.reportInfoTask != nullptr) {
        eventReportHandler.reportInfoTask(domain, event, hiSysEventType, params);
    }
}
#endif

#ifdef __IOS__
void ExceptionManager::DefaultUncaughtTask(const char* sunmary, const CJErrorObject errorObj)
{
    (void)sunmary;
    (void)errorObj;
    abort();
}
#endif

#if defined(__ANDROID__)
void ExceptionManager::AndroidDefaultUncaughtTask(const char* summary, const CJErrorObject errorObj)
{
    (void)summary;
    (void)errorObj;
    abort();
}
#endif

void ExceptionManager::DumpException()
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    std::vector<uint64_t>& liteFrameInfos = eWrapper.GetLiteFrameInfos();
    LOG(RTLOG_ERROR, "An exception has occurred:\n");
    MObject* exceptionObject = eWrapper.GetExceptionRef();
    MangleNameHelper helper(exceptionObject->GetTypeInfo()->GetName());
    CString clsName(helper.GetSimpleClassName());
    std::vector<StackTraceElement> stackTrace;
    StackManager::GetStackTraceByLiteFrameInfos(liteFrameInfos, stackTrace);
    if (stackTrace.empty()) {
        LOG(RTLOG_ERROR, "Stacetrace is empty.");
    }
    // If uncaughtExceptionHandler is registered, then execute the handler.
    // Otherwise, dump the exception information.
    std::lock_guard<std::mutex> lock(gUncaughtExceptionHandlerMtx);
    if (Runtime::Current().GetExceptionManager().GetUncaughtExceptionHandler().uncaughtTask) {
#if (defined(__OHOS__) && (__OHOS__ == 1)) || defined(__APPLE__) || defined(__ANDROID__)
        const char* summary = "Uncaught exception was found.";
        CString exceptionMsg(eWrapper.GetExceptionMessage());
#if defined(__APPLE__) && defined(__IOS__) && (__IOS__ == 1)
        CFException::ReportBacktraceToIosIpsLog(eWrapper);
#endif
#if (defined(__APPLE__) && defined(__IOS__) && (__IOS__ == 1)) || defined(__ANDROID__)
        LOG(RTLOG_ERROR, summary);
        CString exceptionInfo(clsName);
        if (!exceptionMsg.IsEmpty()) {
            exceptionInfo += ": ";
            exceptionInfo += exceptionMsg;
        }
        LOG(RTLOG_ERROR, exceptionInfo.Str());
#endif
        CString exceptionStack;
        const int strLen = 10;
        char* str = static_cast<char*>(NativeAllocator::NativeAlloc(strLen * sizeof(char)));
        if (str == nullptr) {
            LOG(RTLOG_FATAL, "Alloca memory failed when Cangjie dump uncaught exception.");
        }
        for (const auto& ste : stackTrace) {
            const int strLen = 10;
            char* str = static_cast<char*>(malloc(strLen * sizeof(char)));
            sprintf_s(str, strLen, "%ld", ste.lineNumber);
            exceptionStack += "\t at ";
            exceptionStack += ste.className.Str();
            exceptionStack += (ste.className.Length() > 0 ? "." : "");
            exceptionStack += ste.methodName.Str();
            exceptionStack += "(";
            exceptionStack += ste.fileName.Str();
            exceptionStack += +":";
            exceptionStack += str;
            exceptionStack += ")\n";
#if defined(__APPLE__) || defined(__ANDROID__)
            LOG(RTLOG_ERROR, exceptionStack.Str());
            exceptionStack = "";
#endif
        }
        CJErrorObject errObj = {clsName.Str(), exceptionMsg.Str(), exceptionStack.Str()};
        eWrapper.ClearInfo();
        Runtime::Current().GetExceptionManager().GetUncaughtExceptionHandler().uncaughtTask(summary, errObj);
#endif
    } else {
#ifdef __APPLE__
        PRINT_ERROR("%s", clsName.Str());
#endif
        LOG(RTLOG_ERROR, clsName.Str());
        if (eWrapper.GetExceptionMessage() != nullptr && eWrapper.GetExceptionMessageLength() != 0) {
            const char* linkStr = ": ";
#ifdef __APPLE__
            PRINT_ERROR("%s", linkStr);
            PRINT_ERROR("%s", eWrapper.GetExceptionMessage());
#endif
            LOG(RTLOG_ERROR, linkStr);
            LOG(RTLOG_ERROR, eWrapper.GetExceptionMessage());
        }
#ifdef __APPLE__
        PRINT_ERROR("\n");
#endif
        LOG(RTLOG_ERROR, "\n");
        constexpr int32_t frameInfoPairLen = 3; // function PC and startpc form one pair in liteFrameInfos
        // When some frames are folded, arraySize is an odd number and the last frame is invalid.
        // In this case, the last frame is discarded.
        SofStackFlag sofFoldedFlag = SofStackFlag::NOT_FOLDED;
        if (liteFrameInfos.size() % frameInfoPairLen == 1) {
            sofFoldedFlag = SofStackFlag(liteFrameInfos.back());
            liteFrameInfos.pop_back();
        }

        if (sofFoldedFlag == SofStackFlag::TOP_FOLDED) {
#ifdef __APPLE__
            PRINT_ERROR("\t ... Some frames are not displayed ...\n");
#endif
            LOG(RTLOG_ERROR, "\t ... Some frames are not displayed ...\n");
        }
        for (const auto& ste : stackTrace) {
#ifdef __APPLE__
            PRINT_ERROR("\t at %s%s%s(%s:%lld)\n", ste.className.Str(), ste.className.Length() > 0 ? "." : "",
                ste.methodName.Str(), ste.fileName.Str(), ste.lineNumber);
#endif
            LOG(RTLOG_ERROR, "\t at %s%s%s(%s:%ld)\n", ste.className.Str(), ste.className.Length() > 0 ? "." : "",
                ste.methodName.Str(), ste.fileName.Str(), ste.lineNumber);
        }
        if (sofFoldedFlag == SofStackFlag::BOTTOM_FOLDED) {
#ifdef __APPLE__
            PRINT_ERROR("\t ... Some frames are not displayed ...\n");
#endif
            LOG(RTLOG_ERROR, "\t ... Some frames are not displayed ...\n");
        }
#if defined(__OHOS__) && (__OHOS__ == 1)
        // In OHOS, C calling Cangjie: uncaught exception allow C-side execution to continue without proactive exit,
        // leading to unexpected behavior. Proactive exit is required.
        LOG(RTLOG_FATAL, "Uncaught exception: %s. Terminate required.", clsName.Str());
#endif
    }
}

// Throw exception using managed ExceptionRaiser.
// Since RUNRIME -> MANAGED transition is threated like N2C, stack-unwinding will stop at that managed function. See
// `StackInfo::IsN2CContext`. Because of that, caller of this function should explicitly throw pending exception after
// call.
void ExceptionManager::ThrowImplicitException(ImplicitExceptionType type)
{
    MRT_SetStackGrow(false);
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    eWrapper.SetExceptionMessage(nullptr, 0);
    ExceptionRaiser func = Runtime::Current().GetExceptionManager().GetExceptionRaiser();
    if (func == nullptr) {
        LOG(RTLOG_FATAL, "Cangjie initialization failed, implicit exception is nullptr.");
    }
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
    ExecuteCangjieStub(reinterpret_cast<void*>(static_cast<intptr_t>(type)), 0, 0, reinterpret_cast<void*>(func),
        reinterpret_cast<void*>(threadData), 0);
}

#ifndef _WIN64
static bool HandleAbortSignal(int sig, siginfo_t* info, void* context)
{
    LOG(RTLOG_ERROR, "Two pending exceptions are thrown when a C function calls Cangjie function. Program will abort.");
    return true;
}

static void InstallExceptionAbortHandler()
{
    sigset_t mask;
    CHECK_SIGNAL_CALL(sigemptyset, (&mask), "sigemptyset failed");
    SignalAction sa;
    sa.saSignalAction = HandleAbortSignal;
    sa.scMask = mask;
    sa.scFlags = SA_SIGINFO | SA_ONSTACK;

    AddHandlerToSignalStack(SIGABRT, &sa);
}
#endif

void ExceptionManager::ThrowException(const ExceptionRef& exception)
{
    ScopedEntryTrace trace("CJRT_THROW_EXCEPTION");
    MRT_SetStackGrow(true);
    ExceptionWrapper& mExceptionWrapper = Mutator::GetMutator()->GetExceptionWrapper();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    DLOG(EXCEPTION, "start throw exception");
    DLOG(EXCEPTION, "Struct ExceptionWrapper");
    DLOG(EXCEPTION, "  ExceptionRef\t:\t%p", mExceptionWrapper.GetExceptionRef());
    DLOG(EXCEPTION, "  isCaught\t:\t%d", mExceptionWrapper.IsCaught());
    DLOG(EXCEPTION, "  typeIndex\t:\t%lu", mExceptionWrapper.GetTypeIndex());
    DLOG(EXCEPTION, "  throwingOOME\t:\t%d", mExceptionWrapper.IsThrowingOOME());
    DLOG(EXCEPTION, "  fatalException\t:\t%d", mExceptionWrapper.IsFatalException());
    DLOG(EXCEPTION, "  ExceptionType\t:\t%s", mExceptionWrapper.GetExceptionTypeName());
#endif
    if (mExceptionWrapper.GetExceptionRef() != nullptr) {
#ifndef _WIN64
        // Because the throwing of exceptions has already modified the rbp and pc of some frames,
        // it is impossible to correctly complete the stack unwind. Here, an empty handler is added to exit directly.
        InstallExceptionAbortHandler();
#endif
        LOG(RTLOG_FATAL, "ThrowException fail, abort.");
    }

    // Keep an in-flight unwind intact until the conflicting throw has been rejected.
    mExceptionWrapper.Reset();
    mExceptionWrapper.SetExceptionRef(exception);
    ExceptionHandling eh(mExceptionWrapper, nullptr);
}

void* ExceptionManager::BeginCatch(ExceptionWrapper* mExceptionWrapper __attribute__((unused)))
{
    ScopedEntryTrace trace("CJRT_CATCH_EXCEPTION");
    Mutator* mutator = Mutator::GetMutator();
    ExceptionWrapper& eWrapper = mutator->GetExceptionWrapper();
    if (eWrapper.IsThrowingSOFE()) {
        mutator->StackGuardRecover();
        eWrapper.SetThrowingSOFFramePc(nullptr);
        eWrapper.SetAdjustedStackSize(0);
    }
    eWrapper.SetFatalException(false);
    eWrapper.SetExceptionType(ExceptionWrapper::ExceptionType::UNKNOWN);
    ExceptionRef thrown = eWrapper.GetExceptionRef();
    eWrapper.SetExceptionRef(nullptr);
    return thrown;
}
} // namespace MapleRuntime
