/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include "process_ffi.h"
#include <stdint.h>
#include <stdbool.h>
#include <windows.h>
#include <processenv.h>
#include <wchar.h>

#define BUF_LEN (256)
#define EXPAND_MUL (2)
#define WINDOWS_UNIX_EPOCH_DIFF_MILLISECONDS (11644473600000L)

typedef struct ProcessStartInfo {
    char* programeName;
    char* commandLine;
    char* workingDirectory;
    char* environment;
    HANDLE stdIn;
    HANDLE stdOut;
    HANDLE stdErr;
} ProcessStartInfo;

typedef struct ProcessRtnData {
    int32_t pid;
    HANDLE handle;
    HANDLE stdIn;
    HANDLE stdOut;
    HANDLE stdErr;
    int32_t errCode;
    char* errMessage; // returns the error information string.
} ProcessRtnData;

typedef struct ExitInfo {
    int64_t exitCode;
    bool error;
} ExitInfo;

static wchar_t* Char2Widechar(const char* cstr)
{
    if (cstr == NULL) {
        return NULL;
    }

    int length = MultiByteToWideChar(CP_UTF8, 0, cstr, -1, NULL, 0);
    if (length == 0) {
        return NULL;
    }

    wchar_t* wstr = (wchar_t*)malloc(sizeof(wchar_t) * length);
    if (wstr == NULL) {
        return NULL;
    }

    (void)memset_s(wstr, length * sizeof(wchar_t), 0, length * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, cstr, -1, wstr, length);

    return wstr;
}

static wchar_t* Char2WidecharWithLenth(const char* cstr, size_t cstrLen)
{
    if (cstr == NULL || cstrLen == 0) {
        return NULL;
    }

    int length = MultiByteToWideChar(CP_UTF8, 0, cstr, cstrLen, NULL, 0);
    if (length == 0) {
        return NULL;
    }

    wchar_t* wstr = (wchar_t*)malloc(sizeof(wchar_t) * length);
    if (wstr == NULL) {
        return NULL;
    }

    (void)memset_s(wstr, length * sizeof(wchar_t), 0, length * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, cstr, cstrLen, wstr, length);

    return wstr;
}

static char* Wchar2Char(const wchar_t* wstr)
{
    int len = WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);
    if (len == 0) {
        return NULL;
    }

    len += 1;
    char* cstr = (char*)malloc(sizeof(char) * len);
    if (cstr == NULL) {
        return NULL;
    }

    (void)memset_s(cstr, len * sizeof(char), 0, len * sizeof(char));
    WideCharToMultiByte(CP_UTF8, 0, wstr, -1, cstr, len, NULL, NULL);

    return cstr;
}

void FreeTwoDimensionalArray(char** strArray)
{
    if (!strArray) {
        return;
    }

    for (char** item = strArray; *item; ++item) {
        free(*item);
    }
    free(strArray);
}

extern void CJ_OS_FreeProcessRtnData(ProcessRtnData* data)
{
    if (data != NULL) {
        free(data->errMessage);
        data->errMessage = NULL;
        free(data);
    }
}

extern void CJ_OS_FreeProcessInfo(ProcessInfo* info)
{
    if (info != NULL) {
        free(info->command);
        info->command = NULL;
        free(info->workingDirectory);
        info->workingDirectory = NULL;
        FreeTwoDimensionalArray(info->commandLine);
        info->commandLine = NULL;
        FreeTwoDimensionalArray(info->arguments);
        info->arguments = NULL;
        FreeTwoDimensionalArray(info->environment);
        info->environment = NULL;
        free(info);
    }
}

extern ProcessStartInfo* CJ_OS_CreateProcessStartInfo(void)
{
    return (ProcessStartInfo*)malloc(sizeof(ProcessStartInfo));
}

extern void CJ_OS_FreeProcessStartInfo(ProcessStartInfo* startInfo)
{
    free(startInfo);
}

extern DWORD CJ_OS_GetCurrentPid(void)
{
    return GetCurrentProcessId();
}

static char* GetErrMessage(int32_t errCode)
{
    WCHAR* errMsg = (WCHAR*)calloc(BUF_LEN, sizeof(WCHAR));
    if (errMsg == NULL) {
        return NULL;
    }

    if (FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, errCode,
        MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT), errMsg, BUF_LEN, NULL) == 0) {
        free(errMsg);
        return NULL;
    }

    char* errMessage = Wchar2Char(errMsg);
    free(errMsg);

    return errMessage;
}

static void HandleError(ProcessRtnData* processData)
{
    processData->errCode = (int32_t)GetLastError();
    processData->errMessage = GetErrMessage(processData->errCode);
}

static wchar_t* Environment2Widechar(char* environment)
{
    size_t envLen = 0;
    for (size_t i = 0;; i++) {
        if (environment[i] == '\0' && environment[i + 1] == '\0') {
            envLen = i + 1 + 1;
            break;
        }
    }

    wchar_t* environmentW = Char2WidecharWithLenth(environment, envLen);
    if (environmentW == NULL) {
        return NULL;
    }

    return environmentW;
}

static bool InitHandle(ProcessStartInfo* info, HANDLE stdIOE[STD_COUNT][WR_COUNT], HANDLE pipe[STD_COUNT][WR_COUNT])
{
    if (info->stdIn == NULL) {
        if (CreatePipe(&stdIOE[STDIN][READ], &stdIOE[STDIN][WRITE], NULL, 0) == 0) {
            return false;
        }
        pipe[STDIN][READ] = stdIOE[STDIN][READ];
        pipe[STDIN][WRITE] = stdIOE[STDIN][WRITE];
    }

    if (info->stdOut == NULL) {
        if (CreatePipe(&stdIOE[STDOUT][READ], &stdIOE[STDOUT][WRITE], NULL, 0) == 0) {
            return false;
        }
        pipe[STDOUT][READ] = stdIOE[STDOUT][READ];
        pipe[STDOUT][WRITE] = stdIOE[STDOUT][WRITE];
    }

    if (info->stdErr == NULL) {
        if (CreatePipe(&stdIOE[STDERR][READ], &stdIOE[STDERR][WRITE], NULL, 0) == 0) {
            return false;
        }
        pipe[STDERR][READ] = stdIOE[STDERR][READ];
        pipe[STDERR][WRITE] = stdIOE[STDERR][WRITE];
    }

    if (SetHandleInformation(stdIOE[STDIN][READ], HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) == 0) {
        return false;
    }

    if (SetHandleInformation(stdIOE[STDOUT][WRITE], HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) == 0) {
        return false;
    }

    if (SetHandleInformation(stdIOE[STDERR][WRITE], HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT) == 0) {
        return false;
    }

    return true;
}

static void InitStartUpInfoW(STARTUPINFOW* si, HANDLE stdIOE[STD_COUNT][WR_COUNT])
{
    si->cb = sizeof(STARTUPINFOW);
    si->dwFlags = STARTF_USESTDHANDLES;
    si->hStdInput = stdIOE[STDIN][READ];
    si->hStdOutput = stdIOE[STDOUT][WRITE];
    si->hStdError = stdIOE[STDERR][WRITE];
}

static void AfterCreate(
    ProcessStartInfo* info, ProcessRtnData* processData, HANDLE stdIOE[STD_COUNT][WR_COUNT], PROCESS_INFORMATION* pi)
{
    if (info->stdIn == NULL) {
        (void)CloseHandle(stdIOE[STDIN][READ]);
        processData->stdIn = stdIOE[STDIN][WRITE];
    }

    if (info->stdOut == NULL) {
        (void)CloseHandle(stdIOE[STDOUT][WRITE]);
        processData->stdOut = stdIOE[STDOUT][READ];
    }

    if (info->stdErr == NULL) {
        (void)CloseHandle(stdIOE[STDERR][WRITE]);
        processData->stdErr = stdIOE[STDERR][READ];
    }

    (void)CloseHandle(pi->hThread);
    pi->hThread = NULL;
    processData->pid = pi->dwProcessId;
    processData->handle = pi->hProcess;
}

static ClosePipe(HANDLE pipe[STD_COUNT][WR_COUNT])
{
    for (int32_t stdIndex = 0; stdIndex < STD_COUNT; stdIndex++) {
        for (int32_t wrIndex = 0; wrIndex < WR_COUNT; wrIndex++) {
            (void)CloseHandle(pipe[stdIndex][wrIndex]);
        }
    }
}

static bool InitProcessArgs(ProcessStartInfo* info, wchar_t** environmentW, wchar_t** workingDirectoryW)
{
    if (info->environment != NULL) {
        *environmentW = Environment2Widechar(info->environment);
        if (*environmentW == NULL) {
            return false;
        }
    }

    if (info->workingDirectory != NULL) {
        *workingDirectoryW = Char2Widechar(info->workingDirectory);
        if (*workingDirectoryW == NULL) {
            return false;
        }
    }

    return true;
}

extern ProcessRtnData* CJ_OS_StartProcess(ProcessStartInfo* info)
{
    ProcessRtnData* processData = (ProcessRtnData*)calloc(1, sizeof(ProcessRtnData));
    if (processData == NULL) {
        return NULL;
    }

    HANDLE stdIOE[STD_COUNT][WR_COUNT] = {
        {info->stdIn, info->stdIn}, {info->stdOut, info->stdOut}, {info->stdErr, info->stdErr}};
    HANDLE pipe[STD_COUNT][WR_COUNT] = {{NULL, NULL}, {NULL, NULL}, {NULL, NULL}};
    if (!InitHandle(info, stdIOE, pipe)) {
        HandleError(processData);
        ClosePipe(pipe);
        return processData;
    }

    wchar_t* environmentW = NULL;
    wchar_t* workingDirectoryW = NULL;
    if (!InitProcessArgs(info, &environmentW, &workingDirectoryW)) {
        free(environmentW);
        free(workingDirectoryW);
        HandleError(processData);
        ClosePipe(pipe);
        return processData;
    }

    wchar_t* programeNameW = Char2Widechar(info->programeName);
    if (programeNameW == NULL) {
        HandleError(processData);
        ClosePipe(pipe);
        return processData;
    }

    wchar_t* commandLineW = Char2Widechar(info->commandLine);
    if (commandLineW == NULL) {
        free(programeNameW);
        HandleError(processData);
        ClosePipe(pipe);
        return processData;
    }

    PROCESS_INFORMATION pi;
    ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
    STARTUPINFOW si;
    ZeroMemory(&si, sizeof(STARTUPINFOW));
    InitStartUpInfoW(&si, stdIOE);
    BOOL ret = CreateProcessW(programeNameW, commandLineW, NULL, NULL, TRUE, CREATE_UNICODE_ENVIRONMENT, environmentW,
        workingDirectoryW, &si, &pi);
    free(programeNameW);
    free(commandLineW);
    free(environmentW);
    free(workingDirectoryW);
    if (ret) {
        AfterCreate(info, processData, stdIOE, &pi);
    } else {
        HandleError(processData);
        ClosePipe(pipe);
    }

    return processData;
}

/**
 * @brief Retrieves the specified time information for a given process, including the process creation time,
 * exit time, kernel time, and user time.
 *
 * The function first checks whether the process is still active. If the process has exited, it immediately returns
 * a failure code. If the process is still running, it calls the Windows API `GetProcessTimes` to obtain the
 * process's time information. The returned timestamp is in milliseconds, and it is adjusted from the Windows
 * epoch (1601-01-01) to the Unix epoch (1970-01-01).
 *
 * @param pid The process ID (PID) of the target process. Type: `int32_t`.
 * @param kind The type of time to retrieve, which can be one of the following:
 *          - `TIMEKIND_CREATE` (0): Retrieve the process's creation time.
 *          - `TIMEKIND_EXIT` (1): Retrieve the process's exit time.
 *          - `TIMEKIND_SYSTEM` (2): Retrieve the process's kernel time.
 *          - `TIMEKIND_USER` (3): Retrieve the process's user time.
 *
 * @return
 *   - On success: The requested timestamp in milliseconds.
 *   - On failure (e.g., process exited or API call failed): Returns `ERROR_GET_PROCESS_TIME_FAILED` (-1).
 *
 * Notes:
 *   - This function may require elevated permissions (e.g., administrator privileges) to access time information
 *   - If the process has exited, the function will not return valid time information.
 *   - The returned timestamp is adjusted for the Unix epoch (1970-01-01) and is in milliseconds.
 */
int64_t GetProcessTime(int32_t pid, int8_t kind)
{
    DWORD pidW = (DWORD)pid;
    HANDLE processHandle = OpenProcess(THREAD_QUERY_INFORMATION | PROCESS_QUERY_LIMITED_INFORMATION, false, pidW);
    if (processHandle == NULL) {
        return ERROR_GET_PROCESS_TIME_FAILED;
    }

    DWORD exitStatus;
    if (!GetExitCodeProcess(processHandle, &exitStatus)) {
        CloseHandle(processHandle);
        return ERROR_GET_PROCESS_TIME_FAILED;
    }

    if (exitStatus != STILL_ACTIVE) {
        CloseHandle(processHandle);
        return ERROR_GET_PROCESS_TIME_FAILED;
    }

    FILETIME processTime[PROCESS_TIME_ARRAY_LENGTH + 1]; // [creationTime, exitTime, kernelTime, userTime]
    if (!GetProcessTimes(processHandle, &processTime[TIMEKIND_CREATE], &processTime[TIMEKIND_EXIT],
        &processTime[TIMEKIND_SYSTEM], &processTime[TIMEKIND_USER])) {
        CloseHandle(processHandle);
        return ERROR_GET_PROCESS_TIME_FAILED;
    }

    int64_t high = (int64_t)processTime[kind].dwHighDateTime;
    int64_t low = (int64_t)processTime[kind].dwLowDateTime;
    int64_t res = (high << 32) | (low & 0x00000000ffffffff);
    res /= MILLI_SECOND_TO_HUNDRED_NANO_SECOND; // convert from 100ns to 1ms

    // For creation time, adjust to Unix epoch
    if (kind == TIMEKIND_CREATE || kind == TIMEKIND_EXIT) {
        res -= WINDOWS_UNIX_EPOCH_DIFF_MILLISECONDS;
    }

    CloseHandle(processHandle);
    return res;
}

/**
 * @brief Retrieves the start time of a process in milliseconds since the Unix epoch.
 *
 * This function provides the creation time of a process based on its PID.
 *
 * @param pid The process ID (PID) of the target process.
 * @return The process start time in milliseconds since the Unix epoch,
 *         or `ERROR_GET_PROCESS_TIME_FAILED` if the process does not exist.
 */
extern int64_t CJ_OS_GetStartTimeFromUnixEpoch(int32_t pid)
{
    return GetProcessTime(pid, TIMEKIND_CREATE);
}

/**
 * @brief Retrieves Windows kernel-mode CPU time for a process in milliseconds.
 *
 * This function reads the system-time field returned by the Windows process time query.
 *
 * @param pid The process ID (PID) of the target process.
 * @return The kernel-mode time in milliseconds, or `ERROR_GET_PROCESS_TIME_FAILED`
 *         if the process does not exist.
 */
extern int64_t CJ_OS_GetSystemTime(int32_t pid)
{
    return GetProcessTime(pid, TIMEKIND_SYSTEM);
}

/**
 * @brief Retrieves Windows user-mode CPU time for a process in milliseconds.
 *
 * This function reads the user-time field returned by the Windows process time query.
 *
 * @param pid The process ID (PID) of the target process.
 * @return The user-mode time in milliseconds, or `ERROR_GET_PROCESS_TIME_FAILED`
 *         if the process does not exist.
 */
extern int64_t CJ_OS_GetUserTime(int32_t pid)
{
    return GetProcessTime(pid, TIMEKIND_USER);
}

/**
 * @brief Checks the alive status of a process based on its PID and last known start time.
 *
 * This function determines if a process is still running, if its PID has been reused,
 * or if it no longer exists by comparing the process's current start time to a given
 * last known start time.
 *
 * @param pid The process ID (PID) of the target process.
 * @param lastTime The last known start time of the process (in milliseconds since unix epoch).
 *                 If `lastTime` is 0, it is treated as unknown.
 * @return One of the following status codes:
 *         - `PROCESS_STATUS_ALIVE` (0): The process is alive, and its start time matches the `lastTime`.
 *         - `PROCESS_STATUS_PID_REUSED` (1): The PID has been reused by a new process (new start time detected).
 *         - `PROCESS_STATUS_NOT_EXIST` (2): The process does not exist.
 */
extern int8_t CJ_OS_GetProcessAliveStatus(int32_t pid, int64_t lastTime)
{
    int64_t newTime = CJ_OS_GetStartTimeFromUnixEpoch(pid);
    if ((lastTime > 0 && lastTime == newTime) || (lastTime == 0 || newTime == 0)) {
        return PROCESS_STATUS_ALIVE;
    }

    return newTime > PROCESS_STATUS_ALIVE ? PROCESS_STATUS_PID_REUSED : PROCESS_STATUS_NOT_EXIST;
}

extern ExitInfo* CJ_OS_WaitSubProcessExit(HANDLE processHandle)
{
    ExitInfo* exitInfo = (ExitInfo*)malloc(sizeof(ExitInfo));
    if (exitInfo == NULL) {
        return NULL;
    }

    exitInfo->exitCode = 0;
    exitInfo->error = false;
    DWORD exitCode = 0;
    BOOL error = FALSE;
    if (processHandle == NULL) {
        exitInfo->exitCode = -1;
        return exitInfo;
    }

    if (!GetExitCodeProcess(processHandle, &exitCode)) {
        exitInfo->error = true;
        return exitInfo;
    }

    while (exitCode == STILL_ACTIVE) {
        DWORD waitRes = WaitForMultipleObjects(1, &processHandle, false, INFINITE);
        if (waitRes == WAIT_FAILED) {
            exitInfo->error = true;
            return exitInfo;
        }

        if (!GetExitCodeProcess(processHandle, &exitCode)) {
            exitInfo->error = true;
            return exitInfo;
        }
    }

    exitInfo->exitCode = (int64_t)exitCode;
    exitInfo->error = (bool)error;
    return exitInfo;
}

/**
 * @brief Waits for a process to exit, blocking the caller for at most the given timeout.
 *
 * This is the Windows building block for a timeout-correct `SubProcess.wait(timeout:)`.
 * Unlike CJ_OS_WaitSubProcessExit(), it never spawns a background waiter thread and
 * never allocates an ExitInfo, so a timed-out wait leaves no residual thread behind
 * and leaks no memory; a later wait can still observe the real exit code because the
 * process handle stays open until the SubProcess is destroyed.
 *
 * @param processHandle The process handle to wait on (from CreateProcess).
 * @param timeoutMilliseconds Maximum time to wait, in milliseconds. Pass INFINITE
 *                            (UInt32.Max) to wait indefinitely.
 * @param exitCode Out parameter receiving the process exit code when it exits.
 * @return One of the following status codes:
 *         - `1`: the process has exited and *exitCode is set.
 *         - `0`: the wait timed out; the process is still running, *exitCode untouched.
 *         - `-1`: error (NULL handle or GetExitCodeProcess failure).
 */
extern int32_t CJ_OS_WaitSubProcessExitTimeout(HANDLE processHandle, uint32_t timeoutMilliseconds, int64_t* exitCode)
{
    if (processHandle == NULL || exitCode == NULL) {
        return -1;
    }

    DWORD waitRes = WaitForSingleObject(processHandle, (DWORD)timeoutMilliseconds);
    if (waitRes == WAIT_TIMEOUT) {
        return 0;
    }

    if (waitRes != WAIT_OBJECT_0) {
        return -1;
    }

    DWORD processExitCode = 0;
    if (!GetExitCodeProcess(processHandle, &processExitCode)) {
        return -1;
    }

    *exitCode = (int64_t)processExitCode;
    return 1;
}

extern int32_t CJ_OS_Terminate(int32_t pid, bool force)
{
    DWORD pidW = (DWORD)pid;
    HANDLE processHandle = OpenProcess(PROCESS_TERMINATE, false, pidW);
    if (processHandle == NULL) {
        return 0;
    }

    BOOL res = TerminateProcess(processHandle, 1);
    CloseHandle(processHandle);
    return (int32_t)res;
}

static char* GetProcessCommand(HANDLE processHandle)
{
    DWORD bufLen = BUF_LEN;
    WCHAR* cmdLineW = (WCHAR*)calloc(bufLen, sizeof(WCHAR));
    if (cmdLineW == NULL) {
        return NULL;
    }

    while (!QueryFullProcessImageNameW(processHandle, 0, cmdLineW, &bufLen)) {
        if (GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
            free(cmdLineW);
            bufLen *= EXPAND_MUL;
            cmdLineW = (WCHAR*)calloc(bufLen, sizeof(WCHAR));
            if (cmdLineW == NULL) {
                return NULL;
            }
        } else {
            free(cmdLineW);
            return NULL;
        }
    }

    char* cmdLine = Wchar2Char(cmdLineW);
    free(cmdLineW);
    return cmdLine;
}

static char** GetProcessCommandLine(void)
{
    wchar_t* cmdLineW = GetCommandLineW();
    if (cmdLineW == NULL) {
        return NULL;
    }

    int32_t cmdLineSize = 0;
    wchar_t** commandLineW = CommandLineToArgvW(cmdLineW, &cmdLineSize);
    if (commandLineW == NULL) {
        return NULL;
    }

    char** commandLine = (char**)calloc(((size_t)cmdLineSize + 1), sizeof(char*));
    if (commandLine == NULL) {
        LocalFree(commandLineW);
        return NULL;
    }

    for (size_t i = 0; i < cmdLineSize; i++) {
        if (commandLineW[i] == NULL) {
            FreeTwoDimensionalArray(commandLine);
            LocalFree(commandLineW);
            return NULL;
        }

        commandLine[i] = Wchar2Char(commandLineW[i]);
        if (commandLine[i] == NULL) {
            FreeTwoDimensionalArray(commandLine);
            LocalFree(commandLineW);
            return NULL;
        }
    }

    LocalFree(commandLineW);
    return commandLine;
}

static char* GetProcessWorkingDir(void)
{
    DWORD bufLen = BUF_LEN;
    wchar_t* workingDirW = (wchar_t*)calloc(bufLen, sizeof(wchar_t));
    if (workingDirW == NULL) {
        return NULL;
    }

    DWORD len = GetCurrentDirectoryW(bufLen, workingDirW);
    if (len > bufLen) {
        free(workingDirW);
        bufLen = len + 1;
        workingDirW = (wchar_t*)calloc(bufLen, sizeof(wchar_t));
        if (workingDirW == NULL) {
            return NULL;
        }

        len = GetCurrentDirectoryW(bufLen, workingDirW);
    }
    if (len > bufLen || len == 0) {
        free(workingDirW);
        return NULL;
    }

    char* workingDir = Wchar2Char(workingDirW);
    free(workingDirW);
    return workingDir;
}

static char** GetProcessEnvironment(void)
{
    wchar_t* envW = GetEnvironmentStringsW();
    if (envW == NULL) {
        return NULL;
    }

    size_t envCount = 0;
    for (size_t i = 0;; i++) {
        if (envW[i] == L'\0') {
            envCount++;
            if (envW[i + 1] == L'\0') {
                break;
            }
        }
    }

    char** environments = (char**)calloc(envCount + 1, sizeof(char*));
    if (environments == NULL) {
        (void)FreeEnvironmentStringsW(envW);
        return NULL;
    }

    size_t left = 0;
    size_t right = 0;
    for (size_t i = 0; i < envCount;) {
        right++;
        if (envW[right] == L'\0') {
            char* environment = Wchar2Char(envW + left);
            if (environment == NULL) {
                (void)FreeEnvironmentStringsW(envW);
                FreeTwoDimensionalArray(environments);
                return NULL;
            }
            left = right + 1;
            right = left;
            environments[i] = environment;
            i++;
        }
    }

    (void)FreeEnvironmentStringsW(envW);
    environments[envCount] = NULL;
    return environments;
}

extern HANDLE CJ_OS_GetProcessHandle(int32_t pid)
{
    DWORD pidW = (DWORD)pid;
    return OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pidW);
}

extern void CJ_OS_CloseProcessHandle(HANDLE handle)
{
    CloseHandle(handle);
}

extern ProcessInfo* CJ_OS_GetProcessInfoByPid(int32_t pid)
{
    int64_t firstTime = CJ_OS_GetStartTimeFromUnixEpoch(pid);
    if (firstTime == ERROR_GET_PROCESS_TIME_FAILED) {
        return NULL;
    }

    DWORD pidW = (DWORD)pid;
    HANDLE processHandle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pidW);
    if (processHandle == NULL) {
        return NULL;
    }

    ProcessInfo* info = (ProcessInfo*)calloc(1, sizeof(ProcessInfo));
    if (info == NULL) {
        CloseHandle(processHandle);
        return NULL;
    }

    info->command = GetProcessCommand(processHandle);
    info->commandLine = NULL;
    info->arguments = NULL;
    info->workingDirectory = NULL;
    info->environment = NULL;
    if (pidW == CJ_OS_GetCurrentPid()) {
        info->commandLine = GetProcessCommandLine();
        info->workingDirectory = GetProcessWorkingDir();
        info->environment = GetProcessEnvironment();
    }
    CloseHandle(processHandle);
    int64_t lastTime = CJ_OS_GetStartTimeFromUnixEpoch(pid);
    if (firstTime != lastTime || lastTime == ERROR_GET_PROCESS_TIME_FAILED) {
        CJ_OS_FreeProcessInfo(info);
        return NULL;
    }

    return info;
}

extern int64_t CJ_OS_CloseFile(HANDLE fd)
{
    return CloseHandle(fd) ? 0 : -1;
}

extern int64_t CJ_OS_FileRead(HANDLE fd, char* buffer, size_t maxLen)
{
    DWORD numOfBytesToRead = (DWORD)maxLen;
    DWORD numOfBytesRead = 0;
    BOOL success = ReadFile(fd, buffer, numOfBytesToRead, &numOfBytesRead, NULL);
    if (!success) {
        if (GetLastError() == ERROR_BROKEN_PIPE) {
            return 0;
        }
        return -1;
    }

    return (int64_t)numOfBytesRead;
}

extern bool CJ_OS_FileWrite(HANDLE fd, const char* buffer, size_t maxLen)
{
    DWORD numOfBytesToWrite = (DWORD)maxLen;
    DWORD numOfWritenBytes = 0;
    WriteFile(fd, buffer, numOfBytesToWrite, &numOfWritenBytes, NULL);
    return (int64_t)(numOfWritenBytes - numOfBytesToWrite) == 0;
}

// To ensure compatibility with Cangjie.IntNative, intptr_t is used here.
extern intptr_t CJ_OS_GetStdHandle(ssize_t fd)
{
    switch (fd) {
        case STDIN:
            return (intptr_t)GetStdHandle(STD_INPUT_HANDLE);
        case STDOUT:
            return (intptr_t)GetStdHandle(STD_OUTPUT_HANDLE);
        case STDERR:
            return (intptr_t)GetStdHandle(STD_ERROR_HANDLE);
        default:
            return NULL;
    }
}

extern HANDLE CJ_OS_GetNulFileHandle(void)
{
    HANDLE hFile = CreateFile("NUL", // FileName
        GENERIC_WRITE,               // DesiredAccess, only write operation in nul pipe.
        0,                           // ShareMode
        NULL,                        // SecurityAttributes
        OPEN_EXISTING,               // CreationDisposition
        FILE_ATTRIBUTE_NORMAL,       // FlagsAndAttributes
        NULL);                       // TemplateFile
    // System resource, no need to free.
    if (hFile == INVALID_HANDLE_VALUE) {
        return NULL;
    }
    return hFile;
}

static wchar_t* GetWPath(const char* cstr)
{
    if (cstr == NULL) {
        return NULL;
    }

    int length = MultiByteToWideChar(CP_UTF8, 0, cstr, -1, NULL, 0);
    if (length == 0) {
        return NULL;
    }

    length += 1;
    wchar_t* wstr = (wchar_t*)malloc(sizeof(wchar_t) * length);
    if (wstr == NULL) {
        return NULL;
    }

    (void)memset_s(wstr, length * sizeof(wchar_t), 0, length * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, cstr, -1, wstr, length);
    return wstr;
}

extern HANDLE CJ_OS_OpenFile(void)
{
    const wchar_t* wPath = GetWPath("NUL");
    if (wPath == NULL) {
        return NULL;
    }

    DWORD access = OPEN_EXISTING;
    DWORD mode = GENERIC_READ | GENERIC_WRITE;
    HANDLE fd = CreateFileW(
        wPath, mode, FILE_SHARE_DELETE | FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, access, FILE_ATTRIBUTE_NORMAL, NULL);

    free((void*)wPath);
    if (fd == INVALID_HANDLE_VALUE) {
        return NULL;
    }
    return fd;
}

static char* GetEnvValByName(char* envName)
{
    if (envName != NULL) {
        wchar_t* envNameW = Char2Widechar(envName);
        if (envNameW == NULL) {
            return NULL;
        }

        wchar_t* envValueW = _wgetenv(envNameW);
        char* envValue = Wchar2Char(envValueW);
        free(envNameW);
        return envValue;
    }

    return NULL;
}

extern char* CJ_OS_HomeDir(void)
{
    return GetEnvValByName("USERPROFILE");
}

extern int32_t CJ_OS_SetEnvEntry(char* envEntry)
{
    if (envEntry == NULL) {
        return -1;
    }

    wchar_t* envEntryW = Char2Widechar(envEntry);
    if (envEntryW == NULL) {
        return -1;
    }

    int32_t retCode = _wputenv(envEntryW);
    free(envEntryW);
    return retCode;
}

extern char* CJ_OS_GetEnvVal(char* envName)
{
    return GetEnvValByName(envName);
}

extern char* CJ_OS_GetSystemDirectory(void)
{
    wchar_t systemDir[MAX_PATH];
    DWORD result = GetSystemDirectoryW(systemDir, MAX_PATH);
    if (result == 0) {
        return NULL;
    }

    return Wchar2Char(systemDir);
}

extern char* CJ_OS_GetWindowsDirectory(void)
{
    wchar_t windowsDir[MAX_PATH];
    DWORD result = GetWindowsDirectoryW(windowsDir, MAX_PATH);
    if (result == 0) {
        return NULL;
    }

    return Wchar2Char(windowsDir);
}
