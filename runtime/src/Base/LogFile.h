// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_LOG_FILE_H
#define MRT_LOG_FILE_H

#include <mutex>

#include "Base/Log.h"
#include "Base/Macros.h"
#include "Base/TimeUtils.h"
#include "Cangjie.h"
#include "Interpreter/Options.h"

namespace MapleRuntime {
enum LogType {
    // for overall brief report
    REPORT = 0,

    // for debug purpose
    DEBUG,

    // for allocator
    ALLOC,
    REGION,
    FRAGMENT,

    // for barriers
    BARRIER,  // idle phase
    EBARRIER, // enum phase
    TBARRIER, // trace phase
    PBARRIER, // preforward phase
    FBARRIER, // forward phase

    // for gc
    GCPHASE,
    ENUM,
    TRACE,
    PREFORWARD,
    FORWARD,
    FIX,
    FINALIZE,

    UNWIND,
    EXCEPTION,
    SIGNAL,

    CJTHREAD,

    INTERPRETER,

#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
    SANITIZER,
#endif
    PROMOTE,
    SWEEP,
    LOCAL_REGION,
    LOG_TYPE_NUMBER
};

#ifndef DEFAULT_MRT_REPORT
#define DEFAULT_MRT_REPORT 0
#endif // DEFAULT_MRT_REPORT

#ifndef DEFAULT_MRT_LOG_ALLOC
#define DEFAULT_MRT_LOG_ALLOC 0
#endif // DEFAULT_MRT_LOG_ALLOC

#ifndef DEFAULT_MRT_LOG_REGION
#define DEFAULT_MRT_LOG_REGION 0
#endif // DEFAULT_MRT_LOG_REGION

#ifndef DEFAULT_MRT_LOG_FRAGMENT
#define DEFAULT_MRT_LOG_FRAGMENT 0
#endif // DEFAULT_MRT_LOG_FRAGMENT

#ifndef DEFAULT_MRT_LOG_DEBUG
#define DEFAULT_MRT_LOG_DEBUG 0
#endif // DEFAULT_MRT_LOG_DEBUG

#ifndef DEFAULT_MRT_LOG_BARRIER
#define DEFAULT_MRT_LOG_BARRIER 0
#endif // DEFAULT_MRT_LOG_BARRIER

#ifndef DEFAULT_MRT_LOG_EBARRIER
#define DEFAULT_MRT_LOG_EBARRIER 0
#endif // DEFAULT_MRT_LOG_EBARRIER

#ifndef DEFAULT_MRT_LOG_TBARRIER
#define DEFAULT_MRT_LOG_TBARRIER 0
#endif // DEFAULT_MRT_LOG_TBARRIER

#ifndef DEFAULT_MRT_LOG_PBARRIER
#define DEFAULT_MRT_LOG_PBARRIER 0
#endif // DEFAULT_MRT_LOG_PBARRIER

#ifndef DEFAULT_MRT_LOG_FBARRIER
#define DEFAULT_MRT_LOG_FBARRIER 0
#endif // DEFAULT_MRT_LOG_FBARRIER

#ifndef DEFAULT_MRT_LOG_GCPHASE
#define DEFAULT_MRT_LOG_GCPHASE 0
#endif // DEFAULT_MRT_LOG_GCPHASE

#ifndef DEFAULT_MRT_LOG_ENUM
#define DEFAULT_MRT_LOG_ENUM 0
#endif // DEFAULT_MRT_LOG_ENUM

#ifndef DEFAULT_MRT_LOG_TRACE
#define DEFAULT_MRT_LOG_TRACE 0
#endif // DEFAULT_MRT_LOG_TRACE

#ifndef DEFAULT_MRT_LOG_PREFORWARD
#define DEFAULT_MRT_LOG_PREFORWARD 0
#endif // DEFAULT_MRT_LOG_PREFORWARD

#ifndef DEFAULT_MRT_LOG_FORWARD
#define DEFAULT_MRT_LOG_FORWARD 0
#endif // DEFAULT_MRT_LOG_FORWARD

#ifndef DEFAULT_MRT_LOG_FIX
#define DEFAULT_MRT_LOG_FIX 0
#endif // DEFAULT_MRT_LOG_FIX

#ifndef DEFAULT_MRT_LOG_FINALIZE
#define DEFAULT_MRT_LOG_FINALIZE 0
#endif // DEFAULT_MRT_LOG_FINALIZE

#ifndef DEFAULT_MRT_LOG_UNWIND
#define DEFAULT_MRT_LOG_UNWIND 0
#endif // DEFAULT_MRT_LOG_UNWIND

#ifndef DEFAULT_MRT_LOG_EXCEPTION
#define DEFAULT_MRT_LOG_EXCEPTION 0
#endif // DEFAULT_MRT_LOG_EXCEPTION

#ifndef DEFAULT_MRT_LOG_SIGNAL
#define DEFAULT_MRT_LOG_SIGNAL 0
#endif // DEFAULT_MRT_LOG_SIGNAL

#ifndef DEFAULT_MRT_LOG_CJTHREAD
#define DEFAULT_MRT_LOG_CJTHREAD 0
#endif // DEFAULT_MRT_LOG_CJTHREAD

#ifndef DEFAULT_MRT_LOG_INTERPRETER
#define DEFAULT_MRT_LOG_INTERPRETER 0
#endif // DEFAULT_MRT_LOG_INTERPRETER

#ifndef DEFAULT_MRT_LOG2STDOUT
#define DEFAULT_MRT_LOG2STDOUT 0
#endif // DEFAULT_MRT_LOG2STDOUT

#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
#ifndef DEFAULT_MRT_LOG_SANITIZER
#define DEFAULT_MRT_LOG_SANITIZER 0
#endif // DEFAULT_MRT_LOG_SANITIZER
#ifndef DEFAULT_MRT_LOG_PROMOTE
#define DEFAULT_MRT_LOG_PROMOTE 0
#endif // DEFAULT_MRT_LOG_PROMOTE
#ifndef DEFAULT_MRT_LOG_SWEEP
#define DEFAULT_MRT_LOG_SWEEP 0
#endif // DEFAULT_MRT_LOG_SWEEP
#endif

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
long GetEnv(const char* envName, long defaultValue); // do not use directly

// Use this macro to get environment variable for log.
// For example: MRT_ENABLED_LOG(MRT_REPORT)
// Will first check if an environment variable "MRT_REPORT" is present,
// and is a valid integer, and use its value. If not present or not a valid
// integer, it will fall back to the default value of the MRT_REPORT
// macro.  This lets the user override configuration at run time, which is useful
// for debugging.
#define MRT_ENABLED_LOG(conf) (MapleRuntime::GetEnv(#conf, DEFAULT_##conf) == 1)
#else
#define MRT_ENABLED_LOG(conf) (0)
#endif

CString Pretty(uint64_t number) noexcept;
CString PrettyOrderInfo(uint64_t number, const char* unit);
CString PrettyOrderMathNano(uint64_t number, const char* unit);
RTLogLevel InitLogLevel();

void WriteLog(bool addPrefix, LogType type, const char* format, ...) noexcept;

#define ENABLE_LOG(type) LogFile::LogIsEnabled(type)

#if defined (__OHOS__)
#define VLOG(type, format...) \
    if (type == LogType::REPORT) { \
        LOG(RTLOG_INFO, format); \
    } else if (LogFile::LogIsEnabled(type)) { \
        WriteLog(true, type, format); \
    }
#else
#define VLOG(type, format...) \
    if (LogFile::LogIsEnabled(type)) { \
        WriteLog(true, type, format); \
    }
#endif

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
#define DLOG(type, format...) VLOG(type, format)
#else
#define DLOG(type, format...) (void)(0)
#endif

// Macro for cjthread log and use it after ENABLE_LOG for judgment.
#define VLOG_CJTHREAD(format...) WriteLog(true, CJTHREAD, format)

class LogFile {
public:
    LogFile() = default;
    ~LogFile() = default;
    static void Init();
    static void Fini();

    struct LogFileItem {
        bool enableLog = false;
        std::mutex fileMutex;
        FILE* file = nullptr;
        size_t maxFileSize = DEFAULT_MAX_FILE_SIZE;
        size_t curPosLocation = 0;
    };

    static FILE* GetFile(LogType type) { return logFile[type].file; }

    static void LogFileLock(LogType type) { logFile[type].fileMutex.lock(); }

    static void LogFileUnLock(LogType type) { logFile[type].fileMutex.unlock(); }

    static bool LogIsEnabled(LogType type) noexcept
    {
#if (defined(__OHOS__) && (__OHOS__ == 1))
        if (type == REPORT) {
            return true;
        }
#endif
        return logFile[type].enableLog;
    }

    static void EnableLog(LogType type, bool key) { logFile[type].enableLog = key; }

    static size_t GetMaxFileSize(LogType type) { return logFile[type].maxFileSize; }

    static size_t GetCurPosLocation(LogType type) { return logFile[type].curPosLocation; }

    static void SetCurPosLocation(LogType type, size_t curPos)
    {
        logFile[type].curPosLocation = curPos;
    }

    static RTLogLevel GetLogLevel() { return logLevel; }

private:
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    static void OpenLogFiles();
#endif
    static void CloseLogFiles();

    static void SetFlagWithEnv(const char* env, LogType type);

    static void SetFlags();
    static LogFileItem logFile[LOG_TYPE_NUMBER];

    static RTLogLevel logLevel;
};

#define MRT_PHASE_TIMER(...) Timer MRT_pt_##__LINE__(__VA_ARGS__)

class Timer {
public:
    explicit Timer(const CString& pName, LogType type = REPORT) : name(pName), logType(type)
    {
        if (ENABLE_LOG(type)) {
            startTime = TimeUtil::MicroSeconds();
        }
    }

    ~Timer()
    {
        if (ENABLE_LOG(logType)) {
            uint64_t stopTime = TimeUtil::MicroSeconds();
            uint64_t diffTime = stopTime - startTime;
            WriteLog(true, logType, "%s time: %sus", name.Str(), Pretty(diffTime).Str());
        }
    }

private:
    CString name;
    uint64_t startTime = 0;
    LogType logType;
};
} // namespace MapleRuntime
#endif // MRT_LOG_FILE_H
