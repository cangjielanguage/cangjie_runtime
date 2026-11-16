/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <errno.h>
#include <fcntl.h>
#include <pwd.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stddef.h>
#include <stdint.h>
#include "securec.h"
#include "process_ffi_unix.h"

// posix envrionment variables: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
extern char** environ;

#define INVALID_PID (-1)
#define INVALID_FD (-1)
#define ERRMSG_LEN (200)

typedef struct ProcessStartInfo {
    char* command;
    char** arguments;
    size_t argSize;
    char* workingDirectory;
    char** environment;
    size_t envSize;
    intptr_t stdIn;
    intptr_t stdOut;
    intptr_t stdErr;
} ProcessStartInfo;

typedef struct ProcessRtnData {
    int32_t pid;
    intptr_t stdIn;
    intptr_t stdOut;
    intptr_t stdErr;
    int32_t errCode;
    char* errMessage; // returns the error information string.
} ProcessRtnData;

extern ProcessStartInfo* CJ_OS_CreateProcessStartInfo(void)
{
    return (ProcessStartInfo*)malloc(sizeof(ProcessStartInfo));
}

extern void CJ_OS_FreeProcessStartInfo(ProcessStartInfo* startInfo)
{
    free(startInfo);
}

static char* GetErrMessage(int32_t errCode)
{
    char* buffer = strerror(errCode); // no need to free
    if (buffer == NULL) {
        return NULL;
    }

    char* errMsg = (char*)calloc(ERRMSG_LEN, sizeof(char));
    if (errMsg == NULL) {
        return NULL;
    }

    if (strcpy_s(errMsg, ERRMSG_LEN, buffer) != EOK) {
        free(errMsg);
        return NULL;
    }
    return errMsg;
}

extern int64_t CJ_OS_FileRead(int32_t fd, char* buffer, size_t maxLen)
{
    return (int64_t)read(fd, (char*)buffer, maxLen);
}

extern bool CJ_OS_FileWrite(int32_t fd, const char* buffer, size_t maxLen)
{
    const char* ptr = buffer;
    size_t remainingLen = maxLen;
    while (remainingLen > 0) {
        ssize_t writeSize = write(fd, (char*)ptr, remainingLen);
        if (writeSize <= 0) {
            break;
        }
        remainingLen -= (size_t)writeSize;
        ptr += writeSize;
    }
    return (int64_t)remainingLen == 0;
}

extern int64_t CJ_OS_CloseFile(int32_t fd)
{
    return (int64_t)close(fd);
}

void FreeTwoDimensionalArray(char** strArray)
{
    if (!strArray) {
        return;
    }

    for (char** p = strArray; *p; ++p) {
        free(*p);
    }
    free(strArray);
}

static char** CopyTwoDimensionalArray(char** strArray, size_t arrSize)
{
    char** result = (char**)calloc(arrSize + 1, sizeof(char*));
    if (result == NULL) {
        return NULL;
    }

    for (size_t i = 0; i < arrSize + 1; i++) {
        if (i == arrSize) {
            result[i] = NULL;
            break;
        }

        char* temp = (char*)calloc(1, strlen(strArray[i]) + 1);
        if (temp == NULL) {
            FreeTwoDimensionalArray(result);
            return NULL;
        }

        if (strcpy_s(temp, strlen(strArray[i]) + 1, strArray[i]) != EOK) {
            FreeTwoDimensionalArray(result);
            free(temp);
            return NULL;
        }

        result[i] = temp;
    }

    return result;
}

static void ReadError(int32_t fd, uint8_t* errCode, size_t maxLen)
{
    for (;;) {
        ssize_t readSize = read(fd, (char*)errCode, sizeof(char));
        if (!(readSize < 0 && errno == EINTR)) {
            return;
        }
    }
}

static void WriteError(int32_t fd, const int32_t* errNum)
{
    char errCode = (char)(*errNum);
    for (;;) {
        ssize_t writeSize = write(fd, &errCode, sizeof(char));
        if (!(writeSize < 0 && errno == EINTR)) {
            return;
        }
    }
}

/* Executing a new process with information in info. */
static void Execvpe(char* command, char** arguments, char** environment)
{
    char** tmp = environ;
    if (environment != NULL) {
        environ = (char**)environment;
    }
    (void)execvp(command, arguments);
    environ = tmp;
}

/* Modifying the Working Directory. */
static int32_t ChangeDir(ProcessStartInfo* info)
{
    if (info->workingDirectory != NULL) {
        if (chdir(info->workingDirectory) < 0) {
            return -1;
        }
    }
    return 0;
}

/* Put the information in info into filedes. */
static int32_t HandleFileDescriptor(int32_t infoFd, int32_t* filedes)
{
    if (infoFd == -1) { // Pipe mode
        if (pipe(filedes) < 0) {
            return -1;
        }
    } else { // File mode
        filedes[0] = infoFd;
        filedes[1] = infoFd;
    }
    return 0;
}

static int32_t Redirect(const ProcessStartInfo* info, int32_t filedes[STD_COUNT][WR_COUNT], int32_t error[WR_COUNT])
{
    // Close redundant file descriptors in pipe mode.
    if (info->stdIn == -1) {
        if (close(filedes[STDIN][WRITE]) < 0) {
            WriteError(error[WRITE], &errno);
            return -1;
        }
    }
#if defined(__ANDROID__) || defined(__OHOS__)
    if (filedes[STDIN][READ] != STDIN) {
        (void)fclose(stdin);
    }
#endif
    if (dup2(filedes[STDIN][READ], STDIN) < 0) { // Redirect stdIn.
        WriteError(error[WRITE], &errno);
        return -1;
    }

    if (info->stdOut == -1) {
        if (close(filedes[STDOUT][READ]) < 0) {
            WriteError(error[WRITE], &errno);
            return -1;
        }
    }
#if defined(__ANDROID__) || defined(__OHOS__)
    if (filedes[STDOUT][WRITE] != STDOUT) {
        (void)fclose(stdout);
    }
#endif
    if (dup2(filedes[STDOUT][WRITE], STDOUT) < 0) { // Redirect stdOut.
        WriteError(error[WRITE], &errno);
        return -1;
    }

    if (info->stdErr == -1) {
        if (close(filedes[STDERR][READ]) < 0) {
            WriteError(error[WRITE], &errno);
            return -1;
        }
    }
#if defined(__ANDROID__) || defined(__OHOS__)
    if (filedes[STDERR][WRITE] != STDERR) {
        (void)fclose(stderr);
    }
#endif
    if (dup2(filedes[STDERR][WRITE], STDERR) < 0) { // Redirect stdErr.
        WriteError(error[WRITE], &errno);
        return -1;
    }
    return 0;
}

static int32_t UnBlockSignals(void)
{
    sigset_t emptySet;
    if (sigemptyset(&emptySet) < 0) {
        return -1;
    }
    if (sigprocmask(SIG_SETMASK, &emptySet, NULL) < 0) {
        return -1;
    }
    return 0;
}

static void ChildProcess(
    ProcessStartInfo* info, char** arguments, char** environment, 
    int32_t filedes[STD_COUNT][WR_COUNT], int32_t* error, int32_t errorSize)
{
    if (errorSize < WR_COUNT) {
        return;
    }

    if (UnBlockSignals() < 0) {
        WriteError(error[WRITE], &errno);
        return;
    }

    if (close(error[READ]) < 0) {
        WriteError(error[WRITE], &errno);
        return;
    }

    if (Redirect(info, filedes, error) < 0) {
        return;
    }

    if (ChangeDir(info) < 0) {
        WriteError(error[WRITE], &errno);
        return;
    }

    if (fcntl(error[WRITE], F_SETFD, FD_CLOEXEC) < 0) {
        WriteError(error[WRITE], &errno);
        return;
    }

    Execvpe(info->command, arguments, environment);
    WriteError(error[WRITE], &errno);
}

static int32_t InitFiledes(ProcessStartInfo* info, int32_t filedes[STD_COUNT][WR_COUNT])
{
    if (HandleFileDescriptor((int32_t)info->stdIn, filedes[STDIN]) < 0) {
        return -1;
    }
    if (HandleFileDescriptor((int32_t)info->stdOut, filedes[STDOUT]) < 0) {
        return -1;
    }
    if (HandleFileDescriptor((int32_t)info->stdErr, filedes[STDERR]) < 0) {
        return -1;
    }
    return 0;
}

static void CloseFiledes(int32_t filedes[STD_COUNT][WR_COUNT])
{
    for (int32_t i = STDIN; i <= STDERR; i++) {
        if (filedes[i][READ] != filedes[i][WRITE]) {
            (void)close(filedes[i][READ]);
            (void)close(filedes[i][WRITE]);
        }
    }
}

static void InitProcessRtnData(ProcessRtnData* processData)
{
    processData->pid = INVALID_PID;
    processData->stdIn = INVALID_FD;
    processData->stdOut = INVALID_FD;
    processData->stdErr = INVALID_FD;
    processData->errCode = 0;
    processData->errMessage = NULL;
}

static int32_t HandleFd(const ProcessStartInfo* info, int32_t filedes[STD_COUNT][WR_COUNT], ProcessRtnData* processData)
{
    if (info->stdIn == -1) {
        processData->stdIn = (intptr_t)filedes[STDIN][WRITE];
        if (close(filedes[STDIN][READ]) < 0) {
            return -1;
        }
    }
    if (info->stdOut == -1) {
        processData->stdOut = (intptr_t)filedes[STDOUT][READ];
        if (close(filedes[STDOUT][WRITE]) < 0) {
            return -1;
        }
    }
    if (info->stdErr == -1) {
        processData->stdErr = (intptr_t)filedes[STDERR][READ];
        if (close(filedes[STDERR][WRITE]) < 0) {
            return -1;
        }
    }
    return 0;
}

/* Create and execute a child process. */
extern ProcessRtnData* CJ_OS_StartProcess(ProcessStartInfo* info)
{
    ProcessRtnData* processData = (ProcessRtnData*)calloc(1, sizeof(ProcessRtnData));
    if (processData == NULL) {
        return NULL;
    }

    InitProcessRtnData(processData);
    // filedes: Descriptors for storing process redirection standard input, output and errors.
    int32_t filedes[STD_COUNT][WR_COUNT] = {
        {INVALID_FD, INVALID_FD}, {INVALID_FD, INVALID_FD}, {INVALID_FD, INVALID_FD}};
    if (InitFiledes(info, filedes) < 0) {
        CloseFiledes(filedes);
        processData->errMessage = GetErrMessage(errno);
        processData->errCode = errno;
        return processData;
    }

    int32_t error[WR_COUNT] = {INVALID_FD, INVALID_FD};
    if (pipe(error) < 0) {
        CloseFiledes(filedes);
        processData->errMessage = GetErrMessage(errno);
        processData->errCode = errno;
        return processData;
    }

    (void)fflush(stdout);
    (void)fflush(stderr);

    // Allocate memory before fork() to avoid calling non-async-signal-safe functions in child process
    char** arguments = CopyTwoDimensionalArray(info->arguments, info->argSize);
    if (arguments == NULL) {
        CloseFiledes(filedes);
        (void)close(error[READ]);
        (void)close(error[WRITE]);
        processData->errMessage = GetErrMessage(errno);
        processData->errCode = errno;
        return processData;
    }

    char** environment = NULL;
    if (info->environment != NULL) {
        environment = CopyTwoDimensionalArray(info->environment, info->envSize);
        if (environment == NULL) {
            FreeTwoDimensionalArray(arguments);
            CloseFiledes(filedes);
            (void)close(error[READ]);
            (void)close(error[WRITE]);
            processData->errMessage = GetErrMessage(errno);
            processData->errCode = errno;
            return processData;
        }
    }

    // Create a child process.
    pid_t pid = fork();
    if (pid < 0) {
        FreeTwoDimensionalArray(arguments);
        FreeTwoDimensionalArray(environment);
        CloseFiledes(filedes);
        (void)close(error[READ]);
        (void)close(error[WRITE]);
        processData->errMessage = GetErrMessage(errno);
        processData->errCode = errno;
        return processData;
    }

    if (pid == 0) { // Child process.
        ChildProcess(info, arguments, environment, filedes, error, WR_COUNT);
        (void)close(error[WRITE]);
        _exit(-1); // Child process should not return to Cangjie.
    } else {       // Parents process.
        FreeTwoDimensionalArray(arguments);
        FreeTwoDimensionalArray(environment);
        // Close redundant file descriptors in pipe mode.
        if (HandleFd(info, filedes, processData) < 0) {
            processData->errMessage = GetErrMessage(errno);
            processData->errCode = errno;
            return processData;
        }
        (void)close(error[WRITE]);
        processData->pid = pid;
        uint8_t errCode = 0;
        ReadError(error[READ], &errCode, sizeof(errCode));
        (void)close(error[READ]);
        processData->errMessage = GetErrMessage((int32_t)errCode);
        processData->errCode = errCode;
    }

    return processData;
}

/* Waiting for the process to end. */
extern int64_t CJ_OS_WaitSubProcessExit(int32_t pid)
{
    errno = 0;
    int status;
    while (waitpid(pid, &status, 0) < 0) {
        switch (errno) {
            case ECHILD:
                return -1; // No child process
            case EINTR:
                break;
            default:
                return -1; // Unknown error
        }
    }

    if (WIFEXITED(status)) {
        return WEXITSTATUS(status);
    }

    if (WIFSIGNALED(status)) {
        return WTERMSIG(status);
    }

    return status;
}

/*
 * Non-blocking wait for process exit (Linux/macOS).
 *
 * Polls the child once with waitpid(pid, &status, WNOHANG) and parses the raw
 * status, so the caller never needs to spawn a background reaper thread. This is
 * the building block for a timeout-correct `SubProcess.wait(timeout:)`:
 * a timed-out poll leaves NO residual waiter behind, and a subsequent wait()
 * can still reap the (possibly already-zombie) child and read its real exit code.
 *
 * Return values:
 *    1  - child has been reaped; *exitCode is set to the exit code (normal exit)
 *         or the terminating signal number (killed by signal), matching the
 *         documented semantics of SubProcess.wait().
 *    0  - child is still running (or the wait was interrupted by a signal;
 *         caller should poll again later).
 *   -1  - error (e.g. ECHILD, meaning the child was already reaped elsewhere);
 *         *exitCode is untouched.
 */
extern int32_t CJ_OS_WaitSubProcessExitNonBlocking(int32_t pid, int64_t* exitCode)
{
    errno = 0;
    int status;
    pid_t ret = waitpid(pid, &status, WNOHANG);
    if (ret == pid) {
        if (WIFEXITED(status)) {
            *exitCode = WEXITSTATUS(status);
        } else if (WIFSIGNALED(status)) {
            *exitCode = WTERMSIG(status);
        } else {
            *exitCode = (int64_t)status;
        }
        return 1;
    }
    if (ret == 0 || errno == EINTR) {
        return 0;
    }
    return -1;
}

/* Terminate a process. */
extern int32_t CJ_OS_Terminate(int32_t pid, bool force)
{
    int32_t signal = force ? SIGKILL : SIGTERM;
    return kill(pid, signal);
}

extern int32_t CJ_OS_GetCurrentPid(void)
{
    return getpid(); // This function will never fail.
}

extern void CJ_OS_FreeProcessRtnData(ProcessRtnData* data)
{
    if (data != NULL) {
        free(data->errMessage);
        data->errMessage = NULL;
        free(data);
    }
}

extern char* CJ_OS_HomeDir(void)
{
#ifdef __ios__
    return getenv("HOME");
#else
    struct passwd* pw = getpwuid(getuid());
    if (pw == NULL) {
        return NULL;
    }
    return pw->pw_dir;
#endif
}

char** GetCurrentProcessEnvironment(int32_t pid)
{
    if (pid != getpid() || environ == NULL) {
        return NULL;
    }

    size_t envCount = 0;
    char** envPtr = environ;
    while (*envPtr++) {
        envCount++;
    }

    char** environment = calloc(envCount + 1, sizeof(char*));
    if (!environment) {
        return NULL;
    }

    for (size_t i = 0; i < envCount; i++) {
        environment[i] = strdup(environ[i]);
    }

    return environment;
}
