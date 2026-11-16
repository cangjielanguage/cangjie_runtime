/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.process

@C
struct ProcessInfo {
    let command: CString = CString(CPointer())
    let commandLine: CPointer<CString> = CPointer<CString>()
    let arguments: CPointer<CString> = CPointer<CString>()
    let workingDirectory: CString = CString(CPointer())
    let environment: CPointer<CString> = CPointer<CString>()
}

foreign {
    // Process
    func CJ_OS_GetProcessHandle(pid: Int32): IntNative

    func CJ_OS_CloseProcessHandle(handle: IntNative): Unit

    func CJ_OS_GetProcessInfoByPid(pid: Int32): CPointer<ProcessInfo>

    func CJ_OS_Terminate(pid: Int32, force: Bool): Int32

    func CJ_OS_GetCurrentPid(): Int32

    func CJ_OS_FreeProcessInfo(processInfo_cp: CPointer<ProcessInfo>): Unit

    func CJ_OS_FreeProcessRtnData(processRtnData_cp: CPointer<ProcessRtnData>): Unit

    func CJ_OS_CreateProcessStartInfo(): CPointer<ProcessStartInfo>

    func CJ_OS_FreeProcessStartInfo(startInfo: CPointer<ProcessStartInfo>): Unit

    func CJ_OS_GetStartTimeFromUnixEpoch(pid: Int32): Int64

    func CJ_OS_GetUserTime(pid: Int32): Int64

    func CJ_OS_GetSystemTime(pid: Int32): Int64

    func CJ_OS_GetProcessAliveStatus(pid: Int32, lastStartTime: Int64): Int8

    /*
     * terminate the calling Process
     * Before exiting the Process, invoke all functions registered through the atexit and on_exit functions.
     * Flush and fend off all standard io streams that are still open;
     * Delete all files created by using the tmpfile function
     *
     * @param Normal end status value
     *
     * manual: https://man7.org/linux/man-pages/man2/exit.2.html
     * signature: void exit(int status);
     */
    @FastNative
    func exit(status: Int32): Unit
}

@When[backend == "cjnative"]
foreign func FiniCJRuntime(): Int32

@When[os != "Windows"]
foreign {
    // Process
    func CJ_OS_StartProcess(startInfo: CPointer<ProcessStartInfo>): CPointer<ProcessRtnData>

    func CJ_OS_WaitSubProcessExit(pid: Int32): Int64

    /*
     * Non-blocking waitpid(WNOHANG) wrapper used by the timeout-correct
     * SubProcess.wait(timeout:) on the non-Windows (Linux/macOS) path. Windows
     * uses CJ_OS_WaitSubProcessExitTimeout instead. Return values:
     *   1  - child reaped, *exitCode set (exit code or terminating signal number)
     *   0  - child still running
     *  -1  - error (ECHILD etc.)
     */
    func CJ_OS_WaitSubProcessExitNonBlocking(pid: Int32, exitCode: CPointer<Int64>): Int32

    // File
    func CJ_OS_CloseFile(fd: IntNative): Int64 // -1: failed, (>= 0): success

    func CJ_OS_FileRead(fd: IntNative, buffer: CPointer<Byte>, maxLen: UIntNative): Int64 // -1: failed, 0: end, (>0): the size of buffer be read

    func CJ_OS_FileWrite(fd: IntNative, buffer: CPointer<Byte>, maxLen: UIntNative): Bool // -1: failed, (>=0): the size of buffer be written

    func getenv(name: CString): CString

    func setenv(name: CString, value: CString, overwrite: Int32): Int32

    func unsetenv(name: CString): Int32
}

@When[os != "Windows" && os != "macOS" && os != "iOS"]
foreign func CJ_OS_GetStartTimeFromBoot(pid: Int32): Int64

@When[os != "Windows"]
@C
struct ProcessStartInfo {
    let _command: CString
    let _arguments: CPointer<CString>
    let _arguments_size: UIntNative
    let _workingDirectory: CString
    let _environment: CPointer<CString>
    let _environment_size: UIntNative
    let _stdIn: IntNative
    let _stdOut: IntNative
    let _stdErr: IntNative

    init(command: CString, arguments: CPointer<CString>, arguments_size: UIntNative, workingDirectory: CString,
        environment: CPointer<CString>, environment_size: UIntNative, stdIn: IntNative, stdOut: IntNative,
        stdErr: IntNative) {
        this._command = command
        this._arguments = arguments
        this._arguments_size = arguments_size
        this._workingDirectory = workingDirectory
        this._environment = environment
        this._environment_size = environment_size
        this._stdIn = stdIn
        this._stdOut = stdOut
        this._stdErr = stdErr
    }
}

@When[os != "Windows"]
@C
struct ProcessRtnData {
    let pid: Int32 = -1
    let stdInHandle: IntNative = INVALID_HANDLE
    let stdOutHandle: IntNative = INVALID_HANDLE
    let stdErrHandle: IntNative = INVALID_HANDLE
    let errCode: Int32 = -1
    let errMessage: CString = CString(CPointer<UInt8>())
}

@When[os == "Windows"]
foreign {
    // Process
    func CJ_OS_StartProcess(startInfo: CPointer<ProcessStartInfo>): CPointer<ProcessRtnData>

    func CJ_OS_WaitSubProcessExit(handle: IntNative): CPointer<ExitInfo>

    /*
     * Bounded wait for the subprocess to exit, used by the timeout-correct
     * SubProcess.wait(timeout:) on Windows. It blocks the calling thread for at
     * most timeoutMilliseconds (UInt32.Max means INFINITE) and writes the exit
     * code through exitCode. Unlike CJ_OS_WaitSubProcessExit it spawns no
     * background thread and allocates no ExitInfo, so a timed-out wait leaves no
     * residual thread behind and leaks nothing. Return values:
     *   1  - process exited, *exitCode set
     *   0  - timed out, process still running, *exitCode untouched
     *  -1  - error (invalid handle / GetExitCodeProcess failure)
     */
    func CJ_OS_WaitSubProcessExitTimeout(handle: IntNative, timeoutMilliseconds: UInt32,
        exitCode: CPointer<Int64>): Int32

    // Directory
    func CJ_OS_GetSystemDirectory(): CString

    func CJ_OS_GetWindowsDirectory(): CString
    // File
    func CJ_OS_CloseFile(fd: IntNative): Int64 // -1: failed, (>= 0): success

    func CJ_OS_FileRead(fd: IntNative, buffer: CPointer<Byte>, maxLen: UIntNative): Int64 // -1: failed, 0: end, (>0): the size of buffer be read

    func CJ_OS_FileWrite(fd: IntNative, buffer: CPointer<Byte>, maxLen: UIntNative): Bool // -1: failed, (>=0): the size of buffer be written

    func CJ_OS_GetStdHandle(fd: IntNative): IntNative

    func CJ_OS_OpenFile(): IntNative

    func CJ_OS_GetNulFileHandle(): IntNative

    func CJ_OS_GetEnvVal(envName: CString): CString

    func CJ_OS_SetEnvEntry(envEntry: CString): Int32
}

@When[os == "Windows"]
@C
struct ProcessStartInfo {
    let _programName: CString
    let _commandLine: CString
    let _workingDirectory: CString
    let _environment: CString
    let _stdIn: IntNative
    let _stdOut: IntNative
    let _stdErr: IntNative

    init(programName: CString, commandLine: CString, workingDirectory: CString, environment: CString, stdIn: IntNative,
        stdOut: IntNative, stdErr: IntNative) {
        this._programName = programName
        this._commandLine = commandLine
        this._workingDirectory = workingDirectory
        this._environment = environment
        this._stdIn = stdIn
        this._stdOut = stdOut
        this._stdErr = stdErr
    }
}

@When[os == "Windows"]
@C
struct ProcessRtnData {
    let pid: Int32 = -1
    let handle: IntNative = INVALID_HANDLE
    let stdInHandle: IntNative = INVALID_HANDLE
    let stdOutHandle: IntNative = INVALID_HANDLE
    let stdErrHandle: IntNative = INVALID_HANDLE
    let errCode: Int32 = 0
    let errMessage: CString = CString(CPointer<UInt8>())
}

@When[os == "Windows"]
@C
struct ExitInfo {
    let exitCode: Int64 = -1
    let error: Bool = false
}

foreign func CJ_OS_HomeDir(): CString

@When[os == "Windows"]
func nativeGetEnv(name: CString): Option<String> {
    var res: CString = unsafe { CJ_OS_GetEnvVal(name) }
    if (res.isNull()) {
        return None
    }
    try {
        return res.toString()
    } finally {
        unsafe { LibC.free(res) }
    }
}

@When[os != "Windows"]
func nativeGetEnv(name: CString): Option<String> {
    if (name.isNull()) {
        return None
    }

    var res: CString = unsafe { getenv(name) }
    if (res.isNull()) {
        return None
    } else {
        var resStr: String = res.toString()
        return resStr
    }
}

@When[os != "Windows"]
func nativeSetEnv(name: CString, value: CString, overwrite: Int32): Int32 {
    return unsafe { setenv(name, value, overwrite) }
}

@When[os == "Windows"]
func nativeSetEnv(name: CString, value: CString, _: Int32): Int32 {
    var envstr: CString = unsafe { LibC.mallocCString(name.toString() + "=" + value.toString()) }
    let ret = unsafe { CJ_OS_SetEnvEntry(envstr) }
    unsafe { LibC.free(envstr) }
    return ret
}

@When[os != "Windows"]
func nativeRemoveEnv(name: CString): Int32 {
    return unsafe { unsetenv(name) }
}

@When[os == "Windows"]
func nativeRemoveEnv(name: CString): Int32 {
    var envstr: CString = unsafe { LibC.mallocCString(name.toString() + "=") }
    let ret = unsafe { CJ_OS_SetEnvEntry(envstr) }
    unsafe { LibC.free(envstr) }
    return ret
}

// std.process needs its own binding to the runtime symbol also declared in std.core.
@When[backend == "cjnative"]
@FastNative
foreign func CJ_MRT_GetCommandLineArgs(): CPointer<CPointer<UInt8>> // cjlint-ignore !G.FUN.03

@FastNative
foreign func strlen(str: CPointer<UInt8>): UIntNative
