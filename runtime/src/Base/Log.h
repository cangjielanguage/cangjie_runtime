// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_BASE_LOG_H
#define MRT_BASE_LOG_H

#include <atomic>
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <mutex>

#include "Base/CString.h"
#include "Base/Macros.h"
#include "Cangjie.h"
#if defined(__OHOS__) && (__OHOS__ == 1)
#include "hitrace/trace.h"
#elif defined(__ANDROID__)
#include <dlfcn.h>
#include "android/trace.h"
#elif defined(__IOS__)
#include <dlfcn.h>
#include <os/signpost.h>
#endif

namespace MapleRuntime {
#define LOG(level, format...) ::MapleRuntime::Logger::GetLogger().FormatLog(level, true, format)
#define FLOG(level, format...) ::MapleRuntime::Logger::GetLogger().FormatLog(level, false, format)

void HiLogForCJThread(RTLogLevel level, const char* format, va_list args);

void ATraceBeginAsync(const char* name, int32_t taskId);

void ATraceEndAsync(const char* name, int32_t taskId);

void ATraceSetCounter(const char* name, int64_t value);

#if defined(__ANDROID__)
class ATraceWrapper {
public:
    static ATraceWrapper& GetInstance();

    void BeginAsyncSection(const char* name, int32_t taskId);
    void EndAsyncSection(const char* name, int32_t taskId);
    void SetCounter(const char* name, int64_t count);

private:
    ATraceWrapper();
    ~ATraceWrapper();

    ATraceWrapper(const ATraceWrapper&) = delete;
    ATraceWrapper& operator=(const ATraceWrapper&) = delete;

    using ATraceBeginAsyncSectionFunc = void(*)(const char*, int32_t);
    using ATraceEndAsyncSectionFunc = void(*)(const char*, int32_t);
    using ATraceSetCounterFunc = void(*)(const char*, int64_t);

    ATraceBeginAsyncSectionFunc beginAsyncFunc = nullptr;
    ATraceEndAsyncSectionFunc endAsyncFunc = nullptr;
    ATraceSetCounterFunc setCounterFunc = nullptr;

    void* libHandle = nullptr;
};
#endif

#if defined(__IOS__)
typedef uint64_t os_signpost_id_t;
enum class SignpostType: uint8_t {
    SIGNPOST_TYPE_EVENT                = 0x00,
    SIGNPOST_TYPE_INTERVAL_BEGIN       = 0x01,
    SIGNPOST_TYPE_INTERVAL_END         = 0x02,
    SIGNPOST_TYPE_INTERVAL_BEGIN_ASYNC = 0x03,
    SIGNPOST_TYPE_INTERVAL_END_ASYNC   = 0x04,
};
#define OS_SIGNPOST_ID_NULL ((os_signpost_id_t)0)
#define OS_SIGNPOST_ID_INVALID ((os_signpost_id_t)~0)
#define INTERVAL_FORMAT_STR "name:%s"
#define INTERVAL_ASYNC_FORMAT_STR "name:%s, taskId: %d"
#define EVENT_FORMAT_STR "name:%s, count: %lld"
#define NEG_NUM_FORMAT_STR "name:%s, taskId/count: %s"

#define OS_LOG_FMT(name, str) \
    __attribute__((section("__TEXT, __oslogstring, cstring_literals"), internal_linkage)) \
    static const char name[] = str
OS_LOG_FMT(PRINT_NEG_NUM_FMT, "name:%{public}s, taskId/count:%{public}s");

#ifdef __cplusplus
extern "C" {
#endif
extern struct mach_header __dso_handle;
#ifdef __cplusplus
}
#endif

class SignpostWrapper {
public:
    static SignpostWrapper& GetInstance();

    void IntervalBegin(const char* name);
    void IntervalEnd();
    void IntervalBeginAsync(const char* name, int32_t taskId);
    void IntervalEndAsync(const char* name, int32_t taskId);
    void EventEmit(const char* name, int64_t count);

private:
    SignpostWrapper();
    ~SignpostWrapper();

    SignpostWrapper(const SignpostWrapper&) = delete;
    SignpostWrapper& operator=(const SignpostWrapper&) = delete;

    bool IsIdValid(os_signpost_id_t spId);
    bool IsLogValid(os_log_t osLog);
    std::pair<size_t, void *> FormatArgs(SignpostType type, const char* name, int64_t value = 0);

    os_log_t GetLog()
    {
        os_log_t log = os_log_create("com.cangjie.trace", "ios-tracing");
        return log;
    }
    os_signpost_id_t& GetId()
    {
        thread_local os_signpost_id_t id = 0;
        return id;
    }
    const char* GetName()
    {
        return endName;
    }
    void SetName(const char* name)
    {
        endName = name;
    }

    static char* SignpostInt(int64_t val, bool isInt32 = true)
    {
        static char buf[64];
        size_t maxLen32 = 32;
        size_t maxLen64 = 64;
        if (isInt32) {
            snprintf(buf, maxLen32, "%d", (static_cast<int32_t>(val)));
        } else {
            snprintf(buf, maxLen64, "%lld", val);
        }
        return buf;
    }

    using EmitWithNameImplFunc = void(*)(void*, os_log_t, os_signpost_type_t, os_signpost_id_t,
                                         const char*, const char*, uint8_t*, uint32_t);
    using IdGenerateFunc = os_signpost_id_t(*)(os_log_t);
    using IdMakeWithPointerFunc = os_signpost_id_t(*)(os_log_t, const void*);
    using OsSignpostEnabledFunc = bool(*)(os_log_t);

    EmitWithNameImplFunc emitWithNameImplFunc = nullptr;
    IdGenerateFunc idGenerateFunc = nullptr;
    IdMakeWithPointerFunc idMakeWithPointerFunc = nullptr;
    OsSignpostEnabledFunc osSignpostEnabledFunc = nullptr;

    void* libHandle = nullptr;
    bool isAvailable = false;
    const char* endName = nullptr; // used in TRACE_FINISH
};
#endif

#if defined(__OHOS__) && (__OHOS__ == 1)
    /**
     * Sample code: \n
     * Synchronous timeslice trace event: \n
     *     TRACE_START("hitraceTest"); \n
     *     TRACE_FINISH();\n
     * Output: \n
     *     <...>-1668    (-------) [003] ....   135.059377: tracing_mark_write: B|1668|H:hitraceTest \n
     *     <...>-1668    (-------) [003] ....   135.059415: tracing_mark_write: E|1668| \n
     * Asynchronous timeslice trace event: \n
     *     TRACE_START_ASYNC("hitraceTest", 123); \n
     *     TRACE_FINISH_ASYNC("hitraceTest", 123); \n
     * Output: \n
     *     <...>-2477    (-------) [001] ....   396.427165: tracing_mark_write: S|2477|H:hitraceTest 123 \n
     *     <...>-2477    (-------) [001] ....   396.427196: tracing_mark_write: F|2477|H:hitraceTest 123 \n
     * Integer value trace event: \n
     *     TRACE_COUNT("hitraceTest", 500); \n
     * Output: \n
     *     <...>-2638    (-------) [002] ....   458.904382: tracing_mark_write: C|2638|H:hitraceTest 500 \n
     */
    #define TRACE_START(name)                    OH_HiTrace_StartTrace(name)
    #define TRACE_FINISH()                       OH_HiTrace_FinishTrace()
    #define TRACE_START_ASYNC(name, taskId)      OH_HiTrace_StartAsyncTrace(name, static_cast<int32_t>(taskId))
    #define TRACE_FINISH_ASYNC(name, taskId)     OH_HiTrace_FinishAsyncTrace(name, static_cast<int32_t>(taskId))
    #define TRACE_COUNT(name, count)             OH_HiTrace_CountTrace(name, static_cast<int64_t>(count))
#elif defined(__ANDROID__)
    #define TRACE_START(name)                    ATrace_beginSection(name)
    #define TRACE_FINISH()                       ATrace_endSection()
    #define TRACE_START_ASYNC(name, taskId)      \
        MapleRuntime::ATraceWrapper::GetInstance().BeginAsyncSection(name, static_cast<int32_t>(taskId))
    #define TRACE_FINISH_ASYNC(name, taskId)     \
        MapleRuntime::ATraceWrapper::GetInstance().EndAsyncSection(name, static_cast<int32_t>(taskId))
    #define TRACE_COUNT(name, count)             \
        MapleRuntime::ATraceWrapper::GetInstance().SetCounter(name, static_cast<int64_t>(count))
#elif defined(__IOS__)
    #define TRACE_START(name)                    MapleRuntime::SignpostWrapper::GetInstance().IntervalBegin(name)
    #define TRACE_FINISH()                       MapleRuntime::SignpostWrapper::GetInstance().IntervalEnd()
    #define TRACE_START_ASYNC(name, taskId)      \
        MapleRuntime::SignpostWrapper::GetInstance().IntervalBeginAsync(name, static_cast<int32_t>(taskId))
    #define TRACE_FINISH_ASYNC(name, taskId)     \
        MapleRuntime::SignpostWrapper::GetInstance().IntervalEndAsync(name, static_cast<int32_t>(taskId))
    #define TRACE_COUNT(name, count)             \
        MapleRuntime::SignpostWrapper::GetInstance().EventEmit(name, static_cast<int64_t>(count))
#else
    #define TRACE_START(name)
    #define TRACE_FINISH()
    #define TRACE_START_ASYNC(name, taskId)
    #define TRACE_FINISH_ASYNC(name, taskId)
    #define TRACE_COUNT(name, count)
#endif

#define TRACE_CJTHREAD_NEW                           "CJTHREAD_CJThreadNew READY"
#define TRACE_CJTHREAD_EXEC                          "CJTHREAD_CJThreadExecute RUNNING"
#define TRACE_CJTHREAD_PARK                          "CJTHREAD_CJThreadPark PENDING"
#define TRACE_CJTHREAD_EXIT                          "CJTHREAD_CJThreadExit IDLE"
#define TRACE_CJTHREAD_SETNAME                       "CJTHREAD_CJThreadSetName"

#ifdef __ANDROID__
CString TraceInfoFormat(const char* name, unsigned long long id, unsigned int argNum = 0, ...);
#endif

class ScopedEntryTrace {
public:
    explicit ScopedEntryTrace(CString name)
    {
        (void)name;
        TRACE_START(name.Str());
    }

    ~ScopedEntryTrace()
    {
        TRACE_FINISH();
    }
};

class ScopedEntryAsyncTrace {
public:
    explicit ScopedEntryAsyncTrace(CString n, int32_t id, const char *arg = nullptr)
        : name(n), taskId(id), extraArg(arg)
    {
        (void)name;
        (void)taskId;
        (void)extraArg;
        if (extraArg != nullptr && *extraArg != '\0') {
            name = name.Append(" ");
            name = name.Append(extraArg);
        }
        TRACE_START_ASYNC(name.Str(), static_cast<int32_t>(taskId));
    }

    ~ScopedEntryAsyncTrace()
    {
        TRACE_FINISH_ASYNC(name.Str(), static_cast<int32_t>(taskId));
    }
private:
    CString name;
    int32_t taskId;
    const char *extraArg = nullptr;
};

#define CHECK(x) \
    do { \
        if (UNLIKELY(!(x))) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FATAL, true, "Check failed: %s", #x); \
        } \
    } while (false)

#define CHECK_IN_SIG(x) \
    do { \
        if (UNLIKELY(!(x))) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FATAL, false, "Check failed: %s", #x); \
        } \
    } while (false)

#define CHECK_DETAIL(x, format...) \
    do { \
        if (UNLIKELY(!(x))) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FAIL, true, "Check failed: %s", #x); \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FATAL, true, format); \
        } \
    } while (false)

#define CHECK_E(x, format...) \
    do { \
        if (x) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_ERROR, true, format); \
        } \
    } while (false)

#define CHECK_OP(LHS, RHS, OP) \
    do { \
        for (auto _values = ::MapleRuntime::CreateValueHolder(LHS, RHS); \
             UNLIKELY(!(_values.GetLHS() OP _values.GetRHS()));) { \
            Logger::GetLogger().FormatLog(RTLOG_FATAL, true, "Check failed: %s %s %s (%s=%s, %s=%s)", #LHS, #OP, #RHS, \
                                          #LHS, _values.GetLHS(), #RHS, _values.GetRHS()); \
        } \
    } while (false)

#define CHECK_EQ(x, y) CHECK_OP(x, y, ==)
#define CHECK_NE(x, y) CHECK_OP(x, y, !=)

#define CHECK_PTHREAD_CALL(call, args, what) \
    do { \
        int rc = call args; \
        if (rc != 0) { \
            errno = rc; \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FATAL, true, "%s failed for %s reason %s return %d", \
                                                          #call, (what), strerror(errno), errno); \
        } \
    } while (false)

#define CHECK_SIGNAL_CALL(call, args, what) \
    do { \
        int rc = call args; \
        if (rc != 0) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_FATAL, true, "%s failed for %s reason %s return %d", \
                                                          #call, (what), strerror(errno), errno); \
        } \
    } while (false)

#define CHECK_FWRITE_CALL(call, args, check) \
    do { \
        size_t rc = call args; \
        if (rc != (check)) { \
            ::MapleRuntime::Logger::GetLogger().FormatLog(RTLOG_ERROR, true, "%s failed", #call); \
        } \
    } while (false)

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
constexpr bool ENABLE_DEBUG_CHECKS = true;
#else
constexpr bool ENABLE_DEBUG_CHECKS = false;
#endif

#define DCHECK_D(x, y) \
    if (::MapleRuntime::ENABLE_DEBUG_CHECKS) \
    CHECK_DETAIL(x, y)
#define DCHECK(x) \
    if (::MapleRuntime::ENABLE_DEBUG_CHECKS) \
    CHECK(x)
#define DCHECK_NE(x, y) \
    if (::MapleRuntime::ENABLE_DEBUG_CHECKS) \
    CHECK_NE(x, y)

template<typename LHS, typename RHS>
class ValueHolder {
public:
    constexpr ValueHolder(LHS l, RHS r) : lhs(l), rhs(r) {}
    ~ValueHolder() = default;

    LHS GetLHS() { return lhs; }

    RHS GetRHS() { return rhs; }
private:
    LHS lhs;
    RHS rhs;
};

template<typename LHS, typename RHS>
ValueHolder<LHS, RHS> CreateValueHolder(LHS lhs, RHS rhs)
{
    return ValueHolder<LHS, RHS>(lhs, rhs);
}

#if (defined(__OHOS__) && (__OHOS__ == 1)) || (defined(_WIN64)) || defined(__APPLE__)
using LogHandle = void (*)(const char* msg);
#endif

constexpr size_t DEFAULT_MAX_FILE_SIZE = 10 * 1024 * 1024;
constexpr size_t LOG_BUFFER_SIZE = 1024;

class Logger {
public:
    Logger();
    ~Logger()
    {
        if (fd != nullptr) {
            fflush(fd);
            fclose(fd);
        }
    }

    MRT_EXPORT static Logger& GetLogger() noexcept;
    bool InitLog();
    MRT_EXPORT void FormatLog(RTLogLevel level, bool notInSigHandler, const char* format, ...) noexcept;
    RTLogLevel GetMinimumLogLevel() const;
    void SetMinimumLogLevel(RTLogLevel level);
    static bool MaybeRotate(size_t curPos, size_t maxSize, FILE* file);
    static size_t GetLogFileSize();
    static void GetLogPath(const char* env, CString& logPath);
    bool CheckLogLevel(RTLogLevel level);
#if  (defined(_WIN64)) || defined(__APPLE__)
    MRT_EXPORT static void RegisterLogHandle(LogHandle handle);
    static void InvokeLogHandle(const char* msg);
#endif
private:
    FILE* fd = nullptr;
    RTLogLevel minimumLogLevel;
    size_t maxFileSize;
    std::recursive_mutex logMutex;
    CString filePath = nullptr;
    size_t curPosLocation = 0;
};
} // namespace MapleRuntime

#endif // MRT_BASE_LOG_H
