// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "LogFile.h"

#include "Base/SysCall.h"
#include "securec.h"

namespace MapleRuntime {
LogFile::LogFileItem LogFile::logFile[LOG_TYPE_NUMBER];

const char* LOG_TYPE_NAMES[LOG_TYPE_NUMBER] = {
    "report",

    "debug",

    "alloc", "region", "fragment",

    "barrier", "ebarrier", "tbarrier", "pbarrier", "fbarrier",

    "gcphase", "enum", "trace", "preforward", "forward", "fix", "finalize",

    "unwind", "exception", "signal",

    "cjthread",

    "interpreter",

#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
    "sanitizer",
#endif
    "promote",
    "sweep",
    "local_region",
};

RTLogLevel LogFile::logLevel = InitLogLevel();

void LogFile::Init()
{
    SetFlags();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    OpenLogFiles();
#endif
}

void LogFile::Fini() { CloseLogFiles(); }

void LogFile::SetFlagWithEnv(const char* env, LogType type)
{
    CString logPath;
    Logger::GetLogPath(env, logPath);
    if (!logPath.IsEmpty()) {
        logFile[type].file = fopen(logPath.Str(), "w");
        if (logFile[type].file == nullptr) {
            PRINT_ERROR("open log file %s failed. msg: %s\n", logPath.Str(), strerror(errno));
        } else {
            logFile[type].enableLog = true;
            size_t size = Logger::GetLogFileSize();
            if (size != 0) {
                logFile[type].maxFileSize = size;
            }
        }
    }
}

void LogFile::SetFlags()
{
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    logFile[REPORT].enableLog = MRT_ENABLED_LOG(MRT_REPORT);
    logFile[ALLOC].enableLog = MRT_ENABLED_LOG(MRT_LOG_ALLOC);
    logFile[REGION].enableLog = MRT_ENABLED_LOG(MRT_LOG_REGION);
    logFile[FRAGMENT].enableLog = MRT_ENABLED_LOG(MRT_LOG_FRAGMENT);
    logFile[DEBUG].enableLog = MRT_ENABLED_LOG(MRT_LOG_DEBUG);
    logFile[BARRIER].enableLog = MRT_ENABLED_LOG(MRT_LOG_BARRIER);
    logFile[EBARRIER].enableLog = MRT_ENABLED_LOG(MRT_LOG_EBARRIER);
    logFile[TBARRIER].enableLog = MRT_ENABLED_LOG(MRT_LOG_TBARRIER);
    logFile[PBARRIER].enableLog = MRT_ENABLED_LOG(MRT_LOG_PBARRIER);
    logFile[FBARRIER].enableLog = MRT_ENABLED_LOG(MRT_LOG_FBARRIER);
    logFile[GCPHASE].enableLog = MRT_ENABLED_LOG(MRT_LOG_GCPHASE);
    logFile[ENUM].enableLog = MRT_ENABLED_LOG(MRT_LOG_ENUM);
    logFile[TRACE].enableLog = MRT_ENABLED_LOG(MRT_LOG_TRACE);
    logFile[PREFORWARD].enableLog = MRT_ENABLED_LOG(MRT_LOG_PREFORWARD);
    logFile[FORWARD].enableLog = MRT_ENABLED_LOG(MRT_LOG_FORWARD);
    logFile[FIX].enableLog = MRT_ENABLED_LOG(MRT_LOG_FIX);
    logFile[FINALIZE].enableLog = MRT_ENABLED_LOG(MRT_LOG_FINALIZE);
    logFile[UNWIND].enableLog = MRT_ENABLED_LOG(MRT_LOG_UNWIND);
    logFile[EXCEPTION].enableLog = MRT_ENABLED_LOG(MRT_LOG_EXCEPTION);
    logFile[SIGNAL].enableLog = MRT_ENABLED_LOG(MRT_LOG_SIGNAL);
    logFile[CJTHREAD].enableLog = MRT_ENABLED_LOG(MRT_LOG_CJTHREAD);
    logFile[INTERPRETER].enableLog = MRT_ENABLED_LOG(MRT_LOG_INTERPRETER);
#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
    logFile[SANITIZER].enableLog = MRT_ENABLED_LOG(MRT_LOG_SANITIZER);
#endif
    logFile[PROMOTE].enableLog = MRT_ENABLED_LOG(MRT_LOG_PROMOTE);
    logFile[SWEEP].enableLog = MRT_ENABLED_LOG(MRT_LOG_SWEEP);
#else
    SetFlagWithEnv("MRT_REPORT", REPORT);
    SetFlagWithEnv("MRT_LOG_CJTHREAD", CJTHREAD);
    SetFlagWithEnv("MRT_LOG_LOCAL_REGION", LOCAL_REGION);
#endif
}

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
void LogFile::OpenLogFiles()
{
    CString pid = CString(MapleRuntime::GetPid());
    CString dateDigit = TimeUtil::GetDigitDate();
    CString dirName = ".";

    for (int i = 0; i < LOG_TYPE_NUMBER; ++i) {
        if (logFile[i].enableLog) {
            CString fileName = dirName + "/" + LOG_TYPE_NAMES[i] + "." + dateDigit + "_" + pid + ".txt";
            LOG(RTLOG_INFO, "create log file %s", fileName.Str());
            logFile[i].file = fopen(fileName.Str(), "a+"); // Assignment closes the old file.
            if (logFile[i].file == nullptr) {
                LOG(RTLOG_ERROR, "LogFile::OpenLogFiles(): fail to open the file");
                continue;
            }
        }
    }
}
#endif

void LogFile::CloseLogFiles()
{
    for (int i = 0; i < LOG_TYPE_NUMBER; ++i) {
        if (logFile[i].enableLog) {
            logFile[i].enableLog = false;
            fclose(logFile[i].file);
        }
    }
}

static void WriteLogImpl(bool addPrefix, LogType type, const char* format, va_list& args)
{
    char buf[LOG_BUFFER_SIZE];
    if (!LogFile::LogIsEnabled(type)) {
        return;
    }
    int index = 0;
    if (addPrefix) {
        index = sprintf_s(buf, sizeof(buf), "%s %d ", TimeUtil::GetTimestamp().Str(), MapleRuntime::GetTid());
        if (index == -1) {
            PRINT_ERROR("WriteLogImpl sprintf_s failed. msg: %s\n", strerror(errno));
            return;
        }
    }

    int ret = vsprintf_s(buf + index, sizeof(buf) - index, format, args);
    if (ret == -1) {
        PRINT_ERROR("WriteLogImpl vsprintf_s failed. msg: %s\n", strerror(errno));
        return;
    }
    index += ret;

    LogFile::LogFileLock(type);
#if defined(__OHOS__) && (__OHOS__ == 1)
    auto env = CString(std::getenv("MRT_REPORT"));
    if (env.Str() == nullptr && type == LogType::REPORT) {
        if (Logger::GetLogger().GetMinimumLogLevel() == RTLOG_INFO) {
            PRINT_INFO("%{public}s\n", buf);
        }
        LogFile::LogFileUnLock(type);
        return;
    }
#endif
    FILE* file = LogFile::GetFile(type);
    if (file == nullptr) {
        PRINT_ERROR("WriteLog failed. MRT_REPORT is not a valid path. Please check again.");
        LogFile::LogFileUnLock(type);
        return;
    }
    int err = fprintf(file, "%s\n", buf);
    if ((err - 1) != index) { // 1 = '\n'
        PRINT_ERROR("WriteLogImpl fprintf failed. msg: %s\n", strerror(errno));
        LogFile::LogFileUnLock(type);
        return;
    }
#ifndef MRT_DEBUG
    size_t curPos = LogFile::GetCurPosLocation(type);
    LogFile::SetCurPosLocation(type, curPos + index);
    if (Logger::MaybeRotate(curPos + index, LogFile::GetMaxFileSize(type), file)) {
        LogFile::SetCurPosLocation(type, 0);
    }
#endif
    fflush(file);
    LogFile::LogFileUnLock(type);
}

void WriteLog(bool addPrefix, LogType type, const char* format, ...) noexcept
{
    va_list args;
    va_start(args, format);
    WriteLogImpl(addPrefix, type, format, args);
    va_end(args);
}

extern "C" void MRT_DumpLog(const char* message) { VLOG_CJTHREAD("%s", message); }

// Orders of magnitudes.  Note: The upperbound of uint64_t is 16E (16 * (1024 ^ 6))
const char* ORDERS_OF_MAGNITUDE[] = { "", "K", "M", "G", "T", "P", "E" };

// Orders of magnitudes.  Note: The upperbound of uint64_t is 16E (16 * (1024 ^ 6))
const char* ORDERS_OF_MAGNITUDE_FROM_NANO[] = { "n", "u", "m", nullptr };

// number of digits in a pretty format segment (100,000,000 each has three digits)
constexpr int NUM_DIGITS_PER_SEGMENT = 3;

CString Pretty(uint64_t number) noexcept
{
    CString orig = CString(number);
    int pos = static_cast<int>(orig.Length()) - NUM_DIGITS_PER_SEGMENT;
    while (pos > 0) {
        orig.Insert(pos, ",");
        pos -= NUM_DIGITS_PER_SEGMENT;
    }
    return orig;
}

// Useful for informatic units, such as KiB, MiB, GiB, ...
CString PrettyOrderInfo(uint64_t number, const char* unit)
{
    size_t order = 0;
    const uint64_t factor = 1024;

    while (number > factor) {
        number /= factor;
        order += 1;
    }

    const char* prefix = ORDERS_OF_MAGNITUDE[order];
    const char* infix = order > 0 ? "i" : ""; // 1KiB = 1024B, but there is no "1iB"

    return CString(number) + prefix + infix + unit;
}

// Useful for scientific units where number is in nanos: ns, us, ms, s
CString PrettyOrderMathNano(uint64_t number, const char* unit)
{
    size_t order = 0;
    const uint64_t factor = 1000; // show in us if under 10ms

    while (number > factor && ORDERS_OF_MAGNITUDE_FROM_NANO[order] != nullptr) {
        number /= factor;
        order += 1;
    }

    const char* prefix = ORDERS_OF_MAGNITUDE_FROM_NANO[order];
    if (prefix == nullptr) {
        prefix = "";
    }

    return CString(number) + prefix + unit;
}

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
long GetEnv(const char* envName, long defaultValue)
{
    const char* ev = getenv(envName);
    if (ev != nullptr) {
        char* endptr = nullptr;
        long rv = std::strtol(ev, &endptr, 0); // support dec, oct and hex
        if (*endptr == '\0') {
            return rv;
        }
    }

    return defaultValue;
}
#endif

RTLogLevel InitLogLevel()
{
    auto env = CString(std::getenv("MRT_LOG_LEVEL"));
    if (env.Str() == nullptr) {
        return RTLOG_ERROR;
    }

    CString logLevel = env.RemoveBlankSpace();
    if (logLevel.Length() != 1) {
        LOG(RTLOG_ERROR, "Unsupported in MRT_LOG_LEVEL length. Valid length must be 1."
                    " Valid MRT_LOG_LEVEL must be in ['v', 'd', 'i', 'w', 'e', 'f' 's'].\n");
        return RTLOG_ERROR;
    }

    switch (logLevel.Str()[0]) {
        case 'v':
            return RTLOG_VERBOSE;
        case 'd':
            return RTLOG_DEBUG;
        case 'i':
            return RTLOG_INFO;
        case 'w':
            return RTLOG_WARNING;
        case 'e':
            return RTLOG_ERROR;
        case 'f':
            return RTLOG_FATAL;
        case 's':
            return RTLOG_FAIL;
        default:
            LOG(RTLOG_ERROR, "Unsupported in MRT_LOG_LEVEL. Valid MRT_LOG_LEVEL must be in"
                        "['v', 'd', 'i', 'w', 'e', 'f' 's'].\n");
    }
    return RTLOG_ERROR;
}
} // namespace MapleRuntime
