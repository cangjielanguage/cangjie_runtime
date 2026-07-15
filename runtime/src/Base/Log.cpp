// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Log.h"

#include <sys/stat.h>
#include <unistd.h>

#include "Base/CString.h"
#include "Base/Globals.h"
#include "Base/ImmortalWrapper.h"
#include "Base/SysCall.h"
#include "Base/TimeUtils.h"
#include "os/Path.h"
#include "securec.h"
#include "Base/LogFile.h"
namespace MapleRuntime {
static ImmortalWrapper<Logger> g_loggerInstance;

Logger& Logger::GetLogger() noexcept { return *g_loggerInstance; }

#if defined(_WIN64) || defined(__APPLE__)
static LogHandle g_logHandle = nullptr;
void Logger::RegisterLogHandle(LogHandle handle)
{
    if (handle == nullptr) {
        PRINT_ERROR("logHandle is nullptr\n");
    }
    g_logHandle = handle;
}

void Logger::InvokeLogHandle(const char* msg)
{
    if (g_logHandle != nullptr) {
        g_logHandle(msg);
    } else {
        PRINT_INFO("%s\n", msg);
    }
}
#endif

size_t Logger::GetLogFileSize()
{
    auto env = std::getenv("MRT_LOG_FILE_SIZE");
    if (env == nullptr) {
        return DEFAULT_MAX_FILE_SIZE;
    }
    size_t size = CString::ParseSizeFromEnv(env) * KB;
    if (size != 0) {
        return size;
    } else {
        LOG(RTLOG_ERROR,
            "Unsupported MRT_LOG_FILE_SIZE parameter. The unit must be added when configuring, "
            "it supports 'kb', 'mb', 'gb'. \n");
    }
    return DEFAULT_MAX_FILE_SIZE;
}

void ATraceBeginAsync(const char* name, int32_t taskId)
{
#if defined(__ANDROID_API__) && (__ANDROID_API__ >= 28)
    ATrace_beginAsyncSection(name, taskId);
#else
    // ATrace_beginAsyncSection were offically added to the android NDK only in API level 28.
    (void)name;
    (void)taskId;
#endif
}

void ATraceEndAsync(const char* name, int32_t taskId) {
#if defined(__ANDROID_API__) && (__ANDROID_API__ >= 28)
    ATrace_endAsyncSection(name, taskId);
#else
    // ATrace_endAsyncSection were offically added to the android NDK only in API level 28.
    (void)name;
    (void)taskId;
#endif
}

void ATraceSetCounter(const char* name, int64_t value)
{
#if defined(__ANDROID_API__) && (__ANDROID_API__ >= 28)
    ATrace_setCounter(name, value);
#else
    // ATrace_setCounter were offically added to the android NDK only in API level 28.
    (void)name;
    (void)value;
#endif
}

bool IsHaveCommandInjection(const CString& logPath)
{
#if defined(_WIN64)
    std::vector<const char*> injectionChar = { "|", ";", "&", "$", ">", "<", "`", "!", "\n" };
#else
    std::vector<const char*> injectionChar = { "|", ";", "&", "$", ">", "<", "`", "\\", "!", "\n" };
#endif
    for (size_t i = 0; i < injectionChar.size(); ++i) {
        if (strstr(logPath.Str(), injectionChar[i]) != nullptr) {
            return true;
        }
    }
    return false;
}

void Logger::GetLogPath(const char* env, CString& logPath)
{
    const char* envPath = ::getenv(env);
    if (envPath == nullptr) {
        return;
    }
    CString s = CString(envPath).RemoveBlankSpace();
    envPath = s.Str();
    size_t envPathLen = strlen(envPath);
    if (envPathLen < 2 || envPathLen >= PATH_MAX) { // 2 is path minimum size
        LOG(RTLOG_ERROR, "Unsupported %s parameter. The length should be in [2, 4096).\n", env);
        return;
    }
#if defined(_WIN64)
    const char* separator = "\\";
#else
    const char* separator = "/";
#endif
    logPath = CString();
    int pos = CString(envPath).RFind(separator);
    if (pos < 0) {
        LOG(RTLOG_ERROR, "%s is not a valid path . Please check again.\n", env);
        return;
    }

    char pathBuf[PATH_MAX + 1] = { 0x00 };
    if (pos != static_cast<int>(envPathLen - 1)) {
        // path ends with name (could be a directory or a file)
        CString path = CString(envPath).SubStr(0, pos + 1);
        CString name = CString(envPath).SubStr(pos + 1);
        if ((!name.IsEmpty()) && Os::Path::GetRealPath(path.Str(), pathBuf)) {
            logPath = CString(pathBuf);
            int separatorPos = logPath.RFind(separator);
            if (separatorPos < 0 || separatorPos != static_cast<int>(logPath.Length() - 1)) {
                logPath.Append(separator);
            }
            logPath.Append(name);
        }
    } else {
        // path ends with '/' (must be directory)
        if (Os::Path::GetRealPath(envPath, pathBuf)) {
            logPath = CString(pathBuf);
        }
    }

    if (IsHaveCommandInjection(logPath)) {
        LOG(RTLOG_ERROR, "Unsupported %s parameter. %s has command injection risk.\n", env, env);
        return;
    }
    if (logPath.IsEmpty()) {
        LOG(RTLOG_ERROR, "Unsupported %s parameter. %s is empty.\n", env, env);
    }
}

Logger::Logger()
{
    maxFileSize = GetLogFileSize();

    GetLogPath("MRT_LOG_PATH", filePath);
    minimumLogLevel = RTLOG_ERROR;
}

bool Logger::InitLog()
{
    FILE* newFd = fopen(filePath.Str(), "w");
    if (newFd == nullptr) {
        PRINT_ERROR("open log file %s failed. msg: %s\n", filePath.Str(), strerror(errno));
        filePath = CString();
        return false;
    }
    fd = newFd;
    curPosLocation = 0;
    return true;
}

RTLogLevel Logger::GetMinimumLogLevel() const { return minimumLogLevel; }

void Logger::SetMinimumLogLevel(RTLogLevel level)
{
    if (level < minimumLogLevel) {
        minimumLogLevel = level;
    }
}

bool Logger::MaybeRotate(size_t curPos, size_t maxSize, FILE* file)
{
    if (curPos < maxSize) {
        return false;
    }
    fflush(file);
    (void)ftruncate(fileno(file), ftell(file));
    rewind(file);
    return true;
}

const char LOG_LEVEL[] = { 'V', 'D', 'I', 'I', 'W', 'E', 'F', 'F' };
const uint64_t ERROR_MSG_SIZE = 128;

void WriteStr(int fd, const char* str, bool notInSigHandler)
{
    if (notInSigHandler) {
        if (fd >= STDERR_FILENO) {
            PRINT_ERROR("%s", str);
        } else {
            PRINT_INFO("%s", str);
        }
    } else {
        if (write(fd, str, strlen(str)) == -1) {
            return;
        }
    }
}

#if (defined(__OHOS__) && (__OHOS__ == 1))
bool Logger::CheckLogLevel(RTLogLevel level)
{
    if ((level == RTLOG_DEBUG) && level < GetMinimumLogLevel()) {
        return false;
    }
    if ((!filePath.IsEmpty()) && fd == nullptr) {
        std::lock_guard<std::recursive_mutex> lock(logMutex);
        if (fd == nullptr && (!InitLog())) {
            if (level == RTLOG_FATAL) {
                std::abort();
            }
            return false;
        }
    }
    return true;
}
#else
bool Logger::CheckLogLevel(RTLogLevel level)
{
    if (level < GetMinimumLogLevel()) {
        return false;
    }
    if ((!filePath.IsEmpty()) && fd == nullptr) {
        std::lock_guard<std::recursive_mutex> lock(logMutex);
        if (fd == nullptr && (!InitLog())) {
            if (level == RTLOG_FATAL) {
                std::abort();
            }
            return false;
        }
    }
    return true;
}
#endif

#if (defined(__OHOS__) && (__OHOS__ == 1))
static inline void WriteLogOnOhos(RTLogLevel level, const char* buf, bool printTerminal)
{
    switch (level) {
        case RTLOG_ERROR: {
            if (printTerminal) {
                printf("%s\n", buf); // Print error messages to the terminal
            }
            PRINT_ERROR("%{public}s\n", buf);
            break;
        }
        case RTLOG_FAIL:
        case RTLOG_FATAL:
            PRINT_FATAL("%{public}s\n", buf);
            break;
        case RTLOG_DEBUG:
            PRINT_DEBUG("%{public}s\n", buf);
            break;
        case RTLOG_WARNING:
            PRINT_WARN("%{public}s\n", buf);
            break;
        case RTLOG_REPORT:
            VLOG(REPORT, "%{public}s\n", buf)
        default:
            PRINT_INFO("%{public}s\n", buf);
    }
}
#endif

#if defined(__ANDROID__)
static inline void WriteLogOnAndroid(RTLogLevel level, const char* buf)
{
    switch (level) {
        case RTLOG_DEBUG:
            PRINT_DEBUG("%s\n", buf);
            break;
        case RTLOG_WARNING:
            PRINT_WARN("%s\n", buf);
            break;
        case RTLOG_ERROR: {
            PRINT_ERROR("%s\n", buf);
            break;
        }
        case RTLOG_FAIL:
        case RTLOG_FATAL:
            PRINT_FATAL("%s\n", buf);
            break;
        case RTLOG_REPORT:
            VLOG(REPORT, "%{public}s\n", buf)
        default:
            PRINT_INFO("%s\n", buf);
    }
}
#endif

#if defined(__IOS__)
static inline void WriteLogOnIos(RTLogLevel level, const char* buf)
{
    switch (level) {
        case RTLOG_DEBUG:
            PRINT_DEBUG("%{public}s", buf);
            break;
        case RTLOG_WARNING:
            PRINT_WARN("%{public}s", buf);
            break;
        case RTLOG_ERROR: {
            PRINT_ERROR("%{public}s", buf);
            break;
        }
        case RTLOG_FAIL:
        case RTLOG_FATAL: {
            PRINT_FATAL("%{public}s", buf);
            break;
        }
        case RTLOG_REPORT:
            VLOG(REPORT, "%{public}s\n", buf)
        default:
            PRINT_INFO("%{public}s", buf);
    }
}
#endif

void Logger::FormatLog(RTLogLevel level, bool notInSigHandler, const char* format, ...) noexcept
{
    if (!CheckLogLevel(level)) {
        return;
    }
    char buf[LOG_BUFFER_SIZE];
    int index;
#if defined (__OHOS__) || defined (__ANDROID__)
    index = 0;
    (void)LOG_LEVEL[level];
#else
    if (notInSigHandler) {
        index = sprintf_s(buf, sizeof(buf), "%s %d %c ", TimeUtil::GetTimestamp().Str(), MapleRuntime::GetTid(),
                          LOG_LEVEL[level]);
    } else {
        index = sprintf_s(buf, sizeof(buf), "%d %c ", MapleRuntime::GetTid(), LOG_LEVEL[level]);
    }
#endif
    va_list args;
    va_start(args, format);
    int ret = vsprintf_s(buf + index, sizeof(buf) - index, format, args);
    if (ret == -1) {
        char errMsg[ERROR_MSG_SIZE];
        int errMsgRet = sprintf_s(errMsg, ERROR_MSG_SIZE, "FormatLog vsprintf_s failed. msg: %s\n", strerror(errno));
        if (errMsgRet == -1) {
            PRINT_ERROR("FormatLog sprintf_s failed\n");
            return;
        }
        WriteStr(STDOUT_FILENO, errMsg, notInSigHandler);
        return;
    }
    index += ret;
    va_end(args);
#if (defined(__OHOS__) && (__OHOS__ == 1))
    WriteLogOnOhos(level, buf, true);
#elif defined(__ANDROID__)
    WriteLogOnAndroid(level, buf);
#elif defined (__IOS__)
    WriteLogOnIos(level, buf);
#else
    if (filePath.IsEmpty()) {
        std::lock_guard<std::recursive_mutex> lock(logMutex);
        PRINT_FATAL_IF(sprintf_s(buf, LOG_BUFFER_SIZE, "%s\n", buf) == -1, "FormatLog sprintf_s failed.\n");
        if (level >= RTLOG_ERROR) {
            WriteStr(STDERR_FILENO, buf, notInSigHandler);
        } else {
            WriteStr(STDOUT_FILENO, buf, notInSigHandler);
        }
    } else {
        std::lock_guard<std::recursive_mutex> lock(logMutex);
        int err;
        PRINT_FATAL_IF(sprintf_s(buf, LOG_BUFFER_SIZE, "%s\n", buf) == -1, "FormatLog sprintf_s failed.\n");
        if (notInSigHandler) {
            err = fprintf(fd, "%s", buf);
        } else {
            err = write(reinterpret_cast<uint64_t>(fd), buf, strlen(buf));
        }
        if ((err - 1) != index) { // 1 = '\n'
            char errMsg[ERROR_MSG_SIZE];
            PRINT_FATAL_IF(sprintf_s(errMsg, ERROR_MSG_SIZE, "FormatLog fprintf failed. msg: %s\n",
                strerror(errno)) == -1, "FormatLog sprintf_s failed.\n");
            WriteStr(STDERR_FILENO, errMsg, notInSigHandler);
        } else {
            curPosLocation += index;
            if (MaybeRotate(curPosLocation, maxFileSize, fd)) {
                curPosLocation = 0;
            }
        }
        if (level == RTLOG_REPORT) {
            VLOG(REPORT, "%{public}s\n", buf);
        }
        if (level == RTLOG_FATAL || level == RTLOG_ERROR) {
            fflush(fd);
        }
    }
#endif
    if (level == RTLOG_FATAL) {
        std::abort();
    }
}

void HiLogForCJThread(RTLogLevel level, const char* format, va_list args)
{
    if (!Logger::GetLogger().CheckLogLevel(level)) {
        return;
    }
    char buf[LOG_BUFFER_SIZE / 2];  // 2 means cjthread may do not need that much space
    int ret = vsprintf_s(buf, sizeof(buf), format, args);
    if (ret == -1) {
        char errMsg[ERROR_MSG_SIZE];
        int errMsgRet = sprintf_s(errMsg, ERROR_MSG_SIZE, "FormatLog vsprintf_s failed. msg: %s\n", strerror(errno));
        if (errMsgRet == -1) {
            PRINT_ERROR("FormatLog sprintf_s failed\n");
            return;
        }
        WriteStr(STDOUT_FILENO, errMsg, true);
        return;
    }
#if (defined(__OHOS__) && (__OHOS__ == 1))
    WriteLogOnOhos(level, buf, false);
#elif defined(__ANDROID__)
    WriteLogOnAndroid(level, buf);
#elif defined (__IOS__)
    WriteLogOnIos(level, buf);
#endif
    if (level == RTLOG_FATAL) {
        std::abort();
    }
}

#ifdef __ANDROID__
// The trace info format: "name arg1 ... cjthreadId"
CString TraceInfoFormat(const char* name, unsigned long long id, unsigned int argNum, ...)
{
    if (name == nullptr || *name == '\0') {
        return CString("null info");
    }
    CString nameStr(name);
    CString idStr(static_cast<uint32_t>(id));
    if (argNum > 0) {
        va_list args;
        va_start(args, argNum);
        for (unsigned int i = 0; i < argNum; i++) {
            const char* arg = va_arg(args, const char*);
            if (arg != nullptr && *arg != '\0') {
                CString argStr(arg);
                nameStr = nameStr.Append(" ");
                nameStr = nameStr.Append(argStr);
            }
        }
        va_end(args);
    }
    nameStr = nameStr.Append(" ");
    nameStr = nameStr.Append(idStr);
    return nameStr;
}
#endif

#if defined(__ANDROID__)
ATraceWrapper::ATraceWrapper()
{
    libHandle = dlopen("libandroid.so", RTLD_LAZY);
    if (!libHandle) {
        PRINT_ERROR("Failed to dlopen libandroid.so: %s\n", dlerror());
        return;
    }

    beginAsyncFunc = reinterpret_cast<ATraceBeginAsyncSectionFunc>(dlsym(libHandle, "ATrace_beginAsyncSection"));
    endAsyncFunc = reinterpret_cast<ATraceEndAsyncSectionFunc>(dlsym(libHandle, "ATrace_endAsyncSection"));
    setCounterFunc = reinterpret_cast<ATraceSetCounterFunc>(dlsym(libHandle, "ATrace_setCounter"));
    if (beginAsyncFunc && endAsyncFunc && setCounterFunc) {
        PRINT_ERROR("ATrace functions all loaded successfully \n");
    } else {
        PRINT_ERROR("Failed to load some ATrace functions: begin=%p, end=%p, counter=%p \n",
                    beginAsyncFunc, endAsyncFunc, setCounterFunc);
    }
}

ATraceWrapper::~ATraceWrapper()
{
    if (libHandle) {
        dlclose(libHandle);
        libHandle = nullptr;
    }

    beginAsyncFunc = nullptr;
    endAsyncFunc = nullptr;
    setCounterFunc = nullptr;
}

ATraceWrapper& ATraceWrapper::GetInstance()
{
    static ATraceWrapper instance;
    return instance;
}

void ATraceWrapper::BeginAsyncSection(const char* name, int32_t taskId)
{
    if (beginAsyncFunc) {
        beginAsyncFunc(name, taskId);
    }
}

void ATraceWrapper::EndAsyncSection(const char* name, int32_t taskId)
{
    if (endAsyncFunc) {
        endAsyncFunc(name, taskId);
    }
}

void ATraceWrapper::SetCounter(const char* name, int64_t count)
{
    if (setCounterFunc) {
        setCounterFunc(name, count);
    }
}
#endif

#if defined(__IOS__)
SignpostWrapper::SignpostWrapper()
{
    libHandle = dlopen("libSystem.dylib", RTLD_LAZY);
    if (!libHandle) {
        PRINT_ERROR("Failed to dlopen libSystem.dylib: %{public}s \n", dlerror());
        return;
    }

    emitWithNameImplFunc = reinterpret_cast<EmitWithNameImplFunc>(dlsym(libHandle, "_os_signpost_emit_with_name_impl"));
    idGenerateFunc = reinterpret_cast<IdGenerateFunc>(dlsym(libHandle, "os_signpost_id_generate"));
    idMakeWithPointerFunc = reinterpret_cast<IdMakeWithPointerFunc>(dlsym(libHandle,
                                                                          "os_signpost_id_make_with_pointer"));
    osSignpostEnabledFunc = reinterpret_cast<OsSignpostEnabledFunc>(dlsym(libHandle, "os_signpost_enabled"));
    if (emitWithNameImplFunc && idGenerateFunc && idMakeWithPointerFunc && osSignpostEnabledFunc) {
        isAvailable = true;
        PRINT_ERROR("signpost functions all loaded successfully \n");
    } else {
        PRINT_ERROR("Failed to load some signpost functions: impl=%p, idGen=%p, idPointer=%p, enabled=%p \n",
                    emitWithNameImplFunc, idGenerateFunc, idMakeWithPointerFunc, osSignpostEnabledFunc);
    }
}

SignpostWrapper::~SignpostWrapper()
{
    isAvailable = false;
    if (libHandle) {
        dlclose(libHandle);
        libHandle = nullptr;
    }

    emitWithNameImplFunc = nullptr;
    idGenerateFunc = nullptr;
    idMakeWithPointerFunc = nullptr;
    osSignpostEnabledFunc = nullptr;
    endName = nullptr;
}

SignpostWrapper& SignpostWrapper::GetInstance()
{
    static SignpostWrapper instance;
    return instance;
}

bool SignpostWrapper::IsIdValid(os_signpost_id_t spId)
{
    if (spId == OS_SIGNPOST_ID_NULL || spId == OS_SIGNPOST_ID_INVALID) {
        PRINT_WARN("id is null or invalid \n");
        return false;
    }
    return true;
}

bool SignpostWrapper::IsLogValid(os_log_t osLog)
{
    if (osSignpostEnabledFunc(osLog)) {
        return true;
    }

    return false;
}

std::pair<size_t, void *> SignpostWrapper::FormatArgs(SignpostType type, const char* name, int64_t value)
{
    size_t alignment = 16;
    size_t bufferSize = 0;
    void *buffer = nullptr;
    switch (type) {
        case SignpostType::SIGNPOST_TYPE_EVENT: {
            if (value >= 0) {
                bufferSize = __builtin_os_log_format_buffer_size(EVENT_FORMAT_STR, name, value);
            } else {
                bufferSize = __builtin_os_log_format_buffer_size(NEG_NUM_FORMAT_STR, name, SignpostInt(value, false));
            }
            break;
        }
        case SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN:
        case SignpostType::SIGNPOST_TYPE_INTERVAL_END: {
            bufferSize = __builtin_os_log_format_buffer_size(INTERVAL_FORMAT_STR, name);
            break;
        }
        case SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN_ASYNC:
        case SignpostType::SIGNPOST_TYPE_INTERVAL_END_ASYNC: {
            if (value >= 0) {
                bufferSize = __builtin_os_log_format_buffer_size(INTERVAL_ASYNC_FORMAT_STR, name,
                                                                 static_cast<int32_t>(value));
            } else {
                bufferSize = __builtin_os_log_format_buffer_size(NEG_NUM_FORMAT_STR, name, SignpostInt(value));
            }
            break;
        }
        default:
            break;
    }
    if (bufferSize == 0) {
        PRINT_ERROR("Error: buffer size calculation failed \n");
        return {0, nullptr};
    }

    // buffer's address need to be aligned
    int retVal = posix_memalign(&buffer, alignment, bufferSize);
    if (!buffer || retVal != 0) {
        PRINT_ERROR("Error: buffer malloc failed, retVal: %d \n", retVal);
        return {0, nullptr};
    }

    switch (type) {
        case SignpostType::SIGNPOST_TYPE_EVENT: {
            if (value >= 0) {
                __builtin_os_log_format(buffer, EVENT_FORMAT_STR, name, value);
            } else {
                __builtin_os_log_format(buffer, NEG_NUM_FORMAT_STR, name, SignpostInt(value, false));
            }
            break;
        }
        case SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN:
        case SignpostType::SIGNPOST_TYPE_INTERVAL_END: {
            __builtin_os_log_format(buffer, INTERVAL_FORMAT_STR, name);
            break;
        }
        case SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN_ASYNC:
        case SignpostType::SIGNPOST_TYPE_INTERVAL_END_ASYNC: {
            if (value >= 0) {
                __builtin_os_log_format(buffer, INTERVAL_ASYNC_FORMAT_STR, name, static_cast<int32_t>(value));
            } else {
                __builtin_os_log_format(buffer, NEG_NUM_FORMAT_STR, name, SignpostInt(value));
            }

            break;
        }
        default:
            break;
    }
    return {bufferSize, buffer};
}

void SignpostWrapper::IntervalBegin(const char* name)
{
    if (!isAvailable) {
        return;
    }

    os_log_t osLog = GetLog();
    os_signpost_id_t spId = idGenerateFunc(osLog);
    GetId() = spId;
    if (!IsIdValid(spId) || !IsLogValid(osLog)) {
        return;
    }

    endName = ((name == nullptr || name[0] == '\0') ? "unnamedOperation" : name);
    SetName(endName);
    auto bufferPair = FormatArgs(SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN, endName);
    size_t bufferSize = bufferPair.first;
    void *buffer = bufferPair.second;
    if (bufferSize == 0 || buffer == nullptr) {
        return;
    }
    emitWithNameImplFunc(&__dso_handle, osLog, OS_SIGNPOST_INTERVAL_BEGIN, spId, "Operation",
                         "name:%{public}s", static_cast<uint8_t*>(buffer), static_cast<uint32_t>(bufferSize));
    std::free(buffer);
}

void SignpostWrapper::IntervalEnd()
{
    if (!isAvailable) {
        return;
    }

    os_log_t osLog = GetLog();
    os_signpost_id_t spId = GetId();
    if (!IsIdValid(spId) || !IsLogValid(osLog)) {
        return;
    }

    const char* taskName = GetName();
    taskName = ((taskName == nullptr || taskName[0] == '\0') ? "unnamedOperation" : taskName);
    auto bufferPair = FormatArgs(SignpostType::SIGNPOST_TYPE_INTERVAL_END, taskName);
    size_t bufferSize = bufferPair.first;
    void *buffer = bufferPair.second;
    if (bufferSize == 0 || buffer == nullptr) {
        return;
    }
    emitWithNameImplFunc(&__dso_handle, osLog, OS_SIGNPOST_INTERVAL_END, spId, "Operation",
                         "name:%{public}s", static_cast<uint8_t*>(buffer), static_cast<uint32_t>(bufferSize));
    std::free(buffer);
}

void SignpostWrapper::IntervalBeginAsync(const char* name, int32_t taskId)
{
    if (!isAvailable) {
        return;
    }

    os_log_t osLog = GetLog();
    uintptr_t ptrVal = static_cast<uintptr_t>(taskId);
    os_signpost_id_t spId = idMakeWithPointerFunc(osLog, reinterpret_cast<void*>(ptrVal));
    if (!IsIdValid(spId) || !IsLogValid(osLog)) {
        return;
    }

    const char* taskName = ((name == nullptr || name[0] == '\0') ? "unnamedOperationAsync" : name);
    auto bufferPair = FormatArgs(SignpostType::SIGNPOST_TYPE_INTERVAL_BEGIN_ASYNC, taskName, taskId);
    size_t bufferSize = bufferPair.first;
    void *buffer = bufferPair.second;
    if (bufferSize == 0 || buffer == nullptr) {
        return;
    }
    emitWithNameImplFunc(&__dso_handle, osLog, OS_SIGNPOST_INTERVAL_BEGIN, spId, "AsyncOperation",
                         ((taskId >= 0) ? "name:%{public}s, taskId:%d" : PRINT_NEG_NUM_FMT),
                         static_cast<uint8_t*>(buffer), static_cast<uint32_t>(bufferSize));
    std::free(buffer);
}

void SignpostWrapper::IntervalEndAsync(const char* name, int32_t taskId)
{
    if (!isAvailable) {
        return;
    }

    os_log_t osLog = GetLog();
    intptr_t ptrVal = static_cast<uintptr_t>(taskId);
    os_signpost_id_t spId = idMakeWithPointerFunc(osLog, reinterpret_cast<void*>(ptrVal));
    if (!IsIdValid(spId) || !IsLogValid(osLog)) {
        return;
    }

    const char* taskName = ((name == nullptr || name[0] == '\0') ? "unnamedOperationAsync" : name);
    auto bufferPair = FormatArgs(SignpostType::SIGNPOST_TYPE_INTERVAL_END_ASYNC, taskName, taskId);
    size_t bufferSize = bufferPair.first;
    void *buffer = bufferPair.second;
    if (bufferSize == 0 || buffer == nullptr) {
        return;
    }
    emitWithNameImplFunc(&__dso_handle, osLog, OS_SIGNPOST_INTERVAL_END, spId, "AsyncOperation",
                         ((taskId >= 0) ? "name:%{public}s, taskId:%d" : PRINT_NEG_NUM_FMT),
                         static_cast<uint8_t*>(buffer), static_cast<uint32_t>(bufferSize));
    std::free(buffer);
}

void SignpostWrapper::EventEmit(const char* name, int64_t count)
{
    if (!isAvailable) {
        return;
    }

    os_log_t osLog = GetLog();
    os_signpost_id_t spId = idGenerateFunc(osLog);
    if (!IsIdValid(spId) || !IsLogValid(osLog)) {
        return;
    }

    const char* taskName = ((name == nullptr || name[0] == '\0') ? "unnamedOperationEmit" : name);
    auto bufferPair = FormatArgs(SignpostType::SIGNPOST_TYPE_EVENT, taskName, count);
    size_t bufferSize = bufferPair.first;
    void *buffer = bufferPair.second;
    if (bufferSize == 0 || buffer == nullptr) {
        return;
    }
    emitWithNameImplFunc(&__dso_handle, osLog, OS_SIGNPOST_EVENT, spId, "OperationEmit",
                         ((count >= 0) ? "name:%{public}s, count: %lld" : PRINT_NEG_NUM_FMT),
                         static_cast<uint8_t*>(buffer), static_cast<uint32_t>(bufferSize));
    std::free(buffer);
}
#endif
} // namespace MapleRuntime
