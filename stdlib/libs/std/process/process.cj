/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.process

import std.fs.*
import std.collection.*
import std.io.*
import std.time.*

const MAX_TIMEOUT_NS: Int64 = 0x7FFF_FFFF_FFFF_FFFF
const PROCESS_STATUS_ALIVE: Int8 = 0
const PROCESS_STATUS_NOT_EXIST: Int8 = -1
const PROCESS_STATUS_PID_REUSED: Int8 = -2
const TIME_SECOND_TO_MILLISECOND: Int64 = 1000
const TIME_MILLISECOND_TO_NANOSECOND: Int64 = 1_000_000
let MAX_TIMEOUT_DURATION: Duration = Duration.nanosecond * MAX_TIMEOUT_NS

@When[os == "Windows"]
func closeProcessHandleIfNeeded(handle: IntNative): Unit {
    if (handle != INVALID_HANDLE) {
        unsafe { CJ_OS_CloseProcessHandle(handle) }
    }
}

public open class Process {
    var _pid: Int64 = -1
    var _handle: IntNative = INVALID_HANDLE
    var _name: ?String = ""
    var _command: ?String = ""
    var _arguments: ?Array<String> = Array<String>()
    var _commandLine: ?Array<String> = Array<String>()
    var _workingDirectory: ?Path = Path("")
    var _environment: ?Map<String, String> = HashMap<String, String>()
    // StartTime deal with the scene, old process instance be killed and a new process instance reused the same pid.
    var _startTimeSinceUnixEpoch: Int64 = 0
    var _startTime: Int64 = 0
    /**
     * Constructors
     *
     * @param pid - process instance id
     * @param name - process name, always equals commandLine
     * @param command - process command
     * @param arguments - process command arguments
     * @param commandLine - vm backend: commandLine = command + [programName] + arguments
     *                      non-vm backend: commandLine = command + arguments
     * @param workingDirectory - process working directory
     * @param environment - process working environments
     *
     */
    init(pid: Int64, name: ?String, command: ?String, arguments: ?Array<String>, commandLine: ?Array<String>,
        workingDirectory: ?Path, environment: ?Map<String, String>) {
        this._pid = pid
        this._name = name
        this._command = command
        this._arguments = arguments
        this._commandLine = commandLine
        this._workingDirectory = workingDirectory
        this._environment = environment
        this._startTimeSinceUnixEpoch = unsafe { CJ_OS_GetStartTimeFromUnixEpoch(Int32(pid)) }
        this._startTime = getProcessStartTime(Int32(pid))
    }

    /**
     * return a process instance for current process.The process instance can used to find processInfo and terminate
     * current process. Also the process instance provide stdio, which can be used to read or write message.
     */
    @Deprecated[message: "CurrentProcess has been marked as deprecated, use related global functions in the std.env instead."]
    public static prop current: CurrentProcess {
        get() {
            return buildCurrentProcess()
        }
    }

    public prop pid: Int64 {
        get() {
            this._pid
        }
    }

    public prop name: String {
        get() {
            this._name ?? throw ProcessException("Process name is unavailable.")
        }
    }

    public prop command: String {
        get() {
            this._command ?? throw ProcessException("Process command is unavailable.")
        }
    }

    // Process start time
    public prop startTime: DateTime {
        get() {
            return if (this._startTimeSinceUnixEpoch == -1) {
                DateTime.UnixEpoch
            } else {
                let second = this._startTimeSinceUnixEpoch / TIME_SECOND_TO_MILLISECOND
                let nanosecond = (this._startTimeSinceUnixEpoch - (second * TIME_SECOND_TO_MILLISECOND)) *
                    TIME_MILLISECOND_TO_NANOSECOND
                DateTime.ofEpoch(second: second, nanosecond: nanosecond)
            }
        }
    }

    // Time spent on system calls executed directly or indirectly by the program
    public prop systemTime: Duration {
        get() {
            return unsafe { CJ_OS_GetSystemTime(Int32(this._pid)) } * Duration.millisecond
        }
    }

    // Time spent by the program itself and the subprocesses in the libraries it calls
    public prop userTime: Duration {
        get() {
            return unsafe { CJ_OS_GetUserTime(Int32(this._pid)) } * Duration.millisecond
        }
    }

    @Deprecated
    public open prop arguments: Array<String> {
        get() {
            this._arguments ?? throw ProcessException("Process arguments are unavailable.")
        }
    }

    @Deprecated[message: "Use global function `public func getCommandLine(): Array<String>` in std.env instead."]
    public prop commandLine: Array<String> {
        get() {
            this._commandLine ?? throw ProcessException("Process command line is unavailable.")
        }
    }

    @Deprecated[message: "Use global function `public func getHomeDirectory(): Path` in std.env instead."]
    public prop workingDirectory: Path {
        get() {
            this._workingDirectory ?? throw ProcessException("Process working directory is unavailable.")
        }
    }

    @Deprecated[message: "Use global function `public func getVariables(): Array<(String, String)>` in std.env instead."]
    public prop environment: Map<String, String> {
        get() {
            this.getEnvironments() ?? throw ProcessException("Process environment is unavailable.")
        }
    }

    /**
     * return a process instance for an existing process which pid is giving by user.
     * The process instance can used to find processInfo and terminate the process.
     * We can not get stdio for any pid process, so that do not provide the stream attribute to operate stdio.
     */
    @Deprecated[message: "Use global function `public func findProcess(pid: Int64): Process` instead."]
    public static func of(pid: Int64): Process {
        if (pid > Int64(Int32.Max) || pid < 0) {
            throw IllegalArgumentException("Invalid pid '${pid}'.")
        }

        return buildProcess(Int32(pid))
    }

    /**
     * start a new subProcess using command and arguments which provide by user.
     *
     * @param command - vaild system command, should not be empty string and can not include Null character.
     * @param arguments - command arguments, each of the arguments should not be empty string and can not include Null character.
     * @param workingDirectory - command working directory, if None, means inherit current process working directory.
     * @param environment - command working environment, if None, means inherit current process environment.
     * @param stdIn - stdIn redirect mode.
     * @param stdOut - stdOut redirect mode.
     * @param stdErr - stdErr redirect mode.
     *
     * @return SubProcess - a new subProcess instance.
     */
    @Deprecated[message: "Use global function `public func launch(command: String, arguments: Array<String>, workingDirectory!: ?Path = None, environment!: ?Map<String, String> = None, stdIn!: ProcessRedirect = Inherit, stdOut!: ProcessRedirect = Inherit, stdErr!: ProcessRedirect = Inherit): SubProcess` instead."]
    public static func start(
        command: String,
        arguments: Array<String>,
        workingDirectory!: ?Path = None,
        environment!: ?Map<String, String> = None,
        stdIn!: ProcessRedirect = Inherit,
        stdOut!: ProcessRedirect = Inherit,
        stdErr!: ProcessRedirect = Inherit
    ): SubProcess {
        launchImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr)
    }

    /**
     * func run is combine the start and wait.
     * provide a convenient way for user, which want start a subprocess and wait the command exec return code.
     */
    @Deprecated[message: "Use global function `public func execute(command: String, arguments: Array<String>, workingDirectory!: ?Path = None, environment!: ?Map<String, String> = None, stdIn!: ProcessRedirect = Inherit, stdOut!: ProcessRedirect = Inherit, stdErr!: ProcessRedirect = Inherit, timeout!: ?Duration = None): Int64` instead."]
    public static func run(
        command: String,
        arguments: Array<String>,
        workingDirectory!: ?Path = None,
        environment!: ?Map<String, String> = None,
        stdIn!: ProcessRedirect = Inherit,
        stdOut!: ProcessRedirect = Inherit,
        stdErr!: ProcessRedirect = Inherit,
        timeout!: ?Duration = None
    ): Int64 {
        let subProcess: SubProcess = start(command, arguments, workingDirectory: workingDirectory,
            environment: environment, stdIn: stdIn, stdOut: stdOut, stdErr: stdErr)
        try {
            return subProcess.wait(timeout: timeout)
        } catch (e: TimeoutException) {
            // Only a local reference is held here, so after the timeout the
            // child would otherwise never be reaped on Unix.
            reapSubProcessAfterTimeout(subProcess)
            throw e
        }
    }

    /**
     * func runOutput is combine the start and waitOutput.
     * provide a convenient way for user, which want start a subprocess and wait the command exec output and err result.
     */
    @Deprecated[message: "Use global function `public func executeWithOutput(command: String, arguments: Array<String>, workingDirectory!: ?Path = None, environment!: ?Map<String, String> = None, stdIn!: ProcessRedirect = Inherit, stdOut!: ProcessRedirect = Pipe, stdErr!: ProcessRedirect = Pipe): (Int64, Array<Byte>, Array<Byte>)` instead."]
    public static func runOutput(
        command: String,
        arguments: Array<String>,
        workingDirectory!: ?Path = None,
        environment!: ?Map<String, String> = None,
        stdIn!: ProcessRedirect = Inherit,
        stdOut!: ProcessRedirect = Pipe,
        stdErr!: ProcessRedirect = Pipe
    ): (Int64, Array<Byte>, Array<Byte>) {
        let subProcess: SubProcess = start(command, arguments, workingDirectory: workingDirectory,
            environment: environment, stdIn: stdIn, stdOut: stdOut, stdErr: stdErr)
        return subProcess.waitOutput()
    }

    /**
     * buildCurrentProcess
     *
     * @return CurrentProcess
     */
    static func buildCurrentProcess(): CurrentProcess {
        let current_pid: Int32 = unsafe { CJ_OS_GetCurrentPid() }
        let processInfo_cp: CPointer<ProcessInfo> = unsafe { CJ_OS_GetProcessInfoByPid(current_pid) }
        if (processInfo_cp.isNull()) {
            throw ProcessException("Failed to initialize current process.")
        }

        let processInfo: ProcessInfo = unsafe { processInfo_cp.read() }
        try {
            let (command, name, workDirPath, arguments, commandLine, environments) = getProcessInfo(processInfo)
            let process = CurrentProcess(Int64(current_pid), name, command, arguments, commandLine, workDirPath,
                environments)
            process._handle = unsafe { CJ_OS_GetProcessHandle(current_pid) }
            return process
        } finally {
            unsafe { CJ_OS_FreeProcessInfo(processInfo_cp) }
        }
    }

    /**
     * return a process instance for an existing process which pid is giving by user.
     *
     * @param pid - process instance id
     *
     * @return Process
     */
    static func buildProcess(pid: Int32): Process {
        let processInfo_cp: CPointer<ProcessInfo> = unsafe { CJ_OS_GetProcessInfoByPid(pid) }
        if (processInfo_cp.isNull()) {
            throw ProcessException("Process '${pid}' is not alive.")
        }
        let processInfo: ProcessInfo = unsafe { processInfo_cp.read() }
        try {
            let (command, name, workDirPath, arguments, commandLine, environments) = getProcessInfo(processInfo)
            let process = PidProcess(Int64(pid), name, command, arguments, commandLine, workDirPath, environments)
            process._handle = unsafe { CJ_OS_GetProcessHandle(pid) }
            return process
        } finally {
            unsafe { CJ_OS_FreeProcessInfo(processInfo_cp) }
        }
    }

    func getEnvironments(): ?Map<String, String> {
        let processInfoC: CPointer<ProcessInfo> = unsafe { CJ_OS_GetProcessInfoByPid(Int32(this._pid)) }
        if (processInfoC.isNull()) {
            return None
        }

        try {
            let processInfo: ProcessInfo = unsafe { processInfoC.read() }
            return getEnvirments(processInfo.environment)
        } finally {
            unsafe { CJ_OS_FreeProcessInfo(processInfoC) }
        }
    }

    public func isAlive(): Bool {
        return unsafe { CJ_OS_GetProcessAliveStatus(Int32(this._pid), this._startTime) == PROCESS_STATUS_ALIVE }
    }

    /**
     * terminate process
     * when terminate the subprocess, the spawn which open to wait subprocess
     * will modify status and change stdio stream to ByteBuffer let user can read
     * stdOut & stdErr unread data after subprocess be killed.
     *
     * @param force - true terminated forcibly
     *                false terminated normally
     *
     * @throws ProcessException - if the pid invaild
     * @return Unit
     */
    public func terminate(force!: Bool = false): Unit {
        if (this._pid > Int64(Int32.Max) || this._pid < 0) {
            throw IllegalArgumentException("Invalid pid '${this._pid}'.")
        }

        terminateAliveProcess(Int32(this._pid), force)
    }

    /**
     * terminate alive process
     *
     * @param pid - process id, need to terminate
     * @param force - true terminated forcibly
     *                false terminated normally
     *
     * @throws ProcessException - if the pid invaild
     * @return Unit
     */
    protected open func terminateAliveProcess(pid: Int32, force: Bool): Unit {
        let processStatus: Int8 = unsafe { CJ_OS_GetProcessAliveStatus(pid, this._startTime) }
        // check the process still running, make sure not kill the wrong process.
        if (processStatus == PROCESS_STATUS_ALIVE) {
            unsafe { CJ_OS_Terminate(Int32(pid), force) }
            return
        }

        if (processStatus == PROCESS_STATUS_PID_REUSED) {
            throw ProcessException("Process '${pid}' has been reused: cannot kill the new process.")
        }

        throw ProcessException("Process '${pid}' does not exist.")
    }

    static func hasDiscardMode(std_redirects: Array<ProcessRedirect>): Bool {
        for (stdio in std_redirects) {
            if (let ProcessRedirect.Discard <- stdio) {
                return true
            }
        }
        return false
    }
}

class PidProcess <: Process {
    init(pid: Int64, name: ?String, command: ?String, arguments: ?Array<String>, commandLine: ?Array<String>,
        workingDirectory: ?Path, environment: ?Map<String, String>) {
        super(pid, name, command, arguments, commandLine, workingDirectory, environment)
    }

    @When[os == "Windows"]
    ~init() {
        closeProcessHandleIfNeeded(this._handle)
    }
}

/**
 * Supported process redirect mode.
 * Pipe: create a pipe between parent current and child process, which can provide a way to exchange info.
 * Inherit: use the same stdio with the current process.
 * FromFile: redirect stdio to a specified file which define by user.
 * Discard: discard the stdio, redirect to system specific "null file".
 */
public enum ProcessRedirect {
    | Inherit
    | Pipe
    | FromFile(File)
    | Discard
}

enum StdIO {
    | StdIn
    | StdOut
    | StdErr
}

@When[os == "Windows" || os == "macOS" || os == "iOS"]
func getProcessStartTime(pid: Int32): Int64 {
    return unsafe { CJ_OS_GetStartTimeFromUnixEpoch(pid) }
}

@When[os != "Windows" && os != "macOS" && os != "iOS"]
func getProcessStartTime(pid: Int32): Int64 {
    return unsafe { CJ_OS_GetStartTimeFromBoot(pid) }
}

@When[os != "iOS"]
func getProcessInfo(processInfo: ProcessInfo): (Option<String>, Option<String>, Option<Path>, Option<Array<String>>, 
    Option<Array<String>>, Option<Map<String, String>>) {
    // Build subProcess instance use processInfo which return from System.
    let command: ?String = cStringToOption(processInfo.command)
    let name: ?String = getNameFromCommand(command)
    let workDir: ?String = cStringToOption(processInfo.workingDirectory)
    let workDirPath: ?Path = match (workDir) {
        case Some(dir) => Path(dir)
        case _ => None
    }
    let arguments: ?Array<String> = cpointerToArray(processInfo.arguments)
    let commandLine: ?Array<String> = cpointerToArray(processInfo.commandLine)
    let environments: ?Map<String, String> = getEnvirments(processInfo.environment)
    return (command, name, workDirPath, arguments, commandLine, environments)
}

@When[os == "iOS"]
func getProcessInfo(processInfo: ProcessInfo): (Option<String>, Option<String>, Option<Path>, Option<Array<String>>, 
    Option<Array<String>>, Option<Map<String, String>>) {
    let workDir: ?String = cStringToOption(processInfo.workingDirectory)
    let name: ?String = processInfo.command.toString()
    let command: ?String = cStringToOption(processInfo.command)
    let commandLine: ?Array<String> = cpointerToArray(processInfo.commandLine)
    let workDirPath: ?Path = match (workDir) {
        case Some(dir) => Path(dir)
        case _ => None
    }
    let environments: ?Map<String, String> = getEnvirments(processInfo.environment)
    let arguments: ?Array<String> = cpointerToArray(processInfo.arguments)
    return (command, name, workDirPath, arguments, commandLine, environments)
}

@When[os == "Windows"]
func getExecutablePath(cmdPath: String): ?Path {
    return try {
        let info: FileInfo = FileInfo(cmdPath)
        if (info.canExecute()) {
            info.path
        } else {
            None
        }
    } catch (_: FSException) { // Any exception except FSException will be throw
        None
    }
}

@When[os == "Windows"]
func searchExecutableInPaths(command: String, paths: String): ?Path {
    for (path in paths.split(";")) {
        if (let Some(cmd) <- getExecutablePath("${path}\\${command}")) {
            return cmd
        }
    }
    return None
}

@When[os == "Windows"]
func searchExecutableInSystemDirectory(command: String): ?Path {
    try (dir = unsafe { CJ_OS_GetSystemDirectory().asResource() }) {
        if (dir.value.isNull()) {
            return None
        } else {
            return getExecutablePath("${dir.value}\\${command}")
        }
    }
    return None
}

@When[os == "Windows"]
func searchExecutableInWindowsDirectory(command: String): ?Path {
    try (dir = unsafe { CJ_OS_GetWindowsDirectory().asResource() }) {
        return if (dir.value.isNull()) {
            None
        } else {
            getExecutablePath("${dir.value}\\${command}")
        }
    }
    return None
}
/**
 * @brief Searches for an executable file in the following directories, according to the default behavior of the CreateProcessW function:
 *
 * 1. The directory from which the application is loaded.
 * 2. The current directory of the parent process.
 * 3. The 32-bit Windows system directory.
 * 4. The 16-bit Windows system directory.
 * 5. The Windows directory.
 * 6. The directories listed in the PATH environment variable.
 *
 * NOTE: For safe reason, we don't search current directory and 16-bit windows system directory.
 */
@When[os == "Windows"]
func resolveExecutable(command: String, environment: ?Map<String, String>, workingDir: CString): ?Path {
    if (command.size == 0) {
        throw ProcessException("Failed to create process: the parameter is incorrect.")
    }

    let has_exe_extention = command.toAsciiLower().endsWith(".exe")

    // If command is an path not filename, like C:\system32\xxx[.exe] or ./xxx[.exe]
    // We will only search this path.
    if (command.contains(":") || command.contains("\\") || command.contains("/")) {
        return if (has_exe_extention) {
            getExecutablePath(command)
        } else {
            getExecutablePath("${command}.exe")
        }
    }

    // Command is a filename, search it by order.
    var newCommand = command
    if (!has_exe_extention) {
        newCommand += ".exe"
    }

    if (let Some(envs) <- environment) {
        if (envs.contains("Path")) {
            if (let Some(path) <- searchExecutableInPaths(newCommand, envs["Path"])) {
                return path
            }
        }
    }

    if (let Some(path) <- getExecutablePath("${workingDir}\\${newCommand}")) {
        return path
    }

    if (let Some(path) <- searchExecutableInSystemDirectory(newCommand)) {
        return path
    }

    if (let Some(path) <- searchExecutableInWindowsDirectory(newCommand)) {
        return path
    }

    try (cStr = unsafe { LibC.mallocCString("Path").asResource() }) {
        let envs: String = nativeGetEnv(cStr.value) ?? ""
        if (let Some(path) <- searchExecutableInPaths(newCommand, envs)) {
            return path
        }
    }

    return None
}

@When[os == "Windows"]
func checkCommandLineLength(command: String, arguments: Array<String>) {
    // MAX_PATH check: refer from chapter: maximum-file-path-limitation
    var length: Int64 = command.size
    let maxLength = Int64(Int16.Max - 1)
    if (length >= maxLength) {
        throw ProcessException("Failed to create process: filename or extension is too long.")
    }

    for (arg in arguments) {
        length += arg.size
        if (length >= maxLength) {
            throw ProcessException("Failed to create process: filename or extension is too long.")
        }
    }
}

@When[os == "Windows"]
func buildSubProcess(command: String, arguments: Array<String>, workingDir_c: CString, environment: ?Map<String, String>,
    std_redirects: Array<ProcessRedirect>): SubProcess {
    checkCommandLineLength(command, arguments)
    // If no valid path is found, preemptively throw an exception with the error message
    // that would be returned by CreateProcessW when it fails to find the specified file.
    let program = match (resolveExecutable(command, environment, workingDir_c)) {
        case Some(programe) => programe.toString()
        case _ => throw ProcessException("Failed to create process: the system cannot find the file specified.")
    }

    // convert attribute from String to CString
    let subProcess: SubProcess
    var processRtnData_cp: CPointer<ProcessRtnData> = CPointer<ProcessRtnData>()
    var processInfo_cp: CPointer<ProcessInfo> = CPointer<ProcessInfo>()
    var processStartInfo_cp: CPointer<ProcessStartInfo> = CPointer<ProcessStartInfo>()
    // build commandLine and convert to CString
    // build envBlock and convert to CString
    var commandLine_c: CStringResource = CString(CPointer()).asResource()
    var envBlock_c: CStringResource = CString(CPointer()).asResource()
    var program_c: CStringResource = CString(CPointer()).asResource()

    try {
        program_c = unsafe { LibC.mallocCString(program).asResource() }
        commandLine_c = buildCommandLine(command, arguments)
        envBlock_c = createEnvironmentBlock(environment)
        let stdIn_fd = matchRedirectFileHandle(std_redirects[0], StdIO.StdIn)
        let stdOut_fd = matchRedirectFileHandle(std_redirects[1], StdIO.StdOut)
        let stdErr_fd = matchRedirectFileHandle(std_redirects[2], StdIO.StdErr)
        let processStartInfo: ProcessStartInfo = ProcessStartInfo(program_c.value, commandLine_c.value, workingDir_c,
            envBlock_c.value, stdIn_fd, stdOut_fd, stdErr_fd)
        processStartInfo_cp = unsafe { CJ_OS_CreateProcessStartInfo() }
        unsafe { processStartInfo_cp.write(processStartInfo) }
        processRtnData_cp = unsafe { CJ_OS_StartProcess(processStartInfo_cp) }
        // processRtnData errcode not 0 means not success, and it's should not go on.
        // should deal with the errcode give detail message.
        if (processRtnData_cp.isNull()) {
            throw ProcessException("Failed to create process.")
        }

        let processRtnData = unsafe { processRtnData_cp.read() }
        if (processRtnData.errCode != 0) {
            throw ProcessException("Failed to create process: ${processRtnData.errMessage}.")
        }

        processInfo_cp = unsafe { CJ_OS_GetProcessInfoByPid(processRtnData.pid) }
        if (processInfo_cp.isNull()) {
            throw ProcessException("Failed to create process.")
        }
        let processInfo = unsafe { processInfo_cp.read() }
        let pid: Int32 = processRtnData.pid
        let (commandInfo, name, workDirPath, argumentsInfo, commandLine, environments) = getProcessInfo(processInfo)
        let (stdInStream, stdOutStream, stdErrStream) = initStdStream(processRtnData)
        subProcess = SubProcess(Int64(pid), name, commandInfo, argumentsInfo, commandLine, workDirPath, environments,
            stdInStream, stdOutStream, stdErrStream)
        subProcess._handle = processRtnData.handle
    } finally {
        if (!program_c.isClosed()) {
            program_c.close()
        }
        if (!commandLine_c.isClosed()) {
            commandLine_c.close()
        }
        if (!envBlock_c.isClosed()) {
            envBlock_c.close()
        }
        unsafe {
            CJ_OS_FreeProcessInfo(processInfo_cp)
            CJ_OS_FreeProcessRtnData(processRtnData_cp)
            CJ_OS_FreeProcessStartInfo(processStartInfo_cp)
        }
    }

    return subProcess
}

// check and concat command，arguments to commandLine
@When[os == "Windows"]
func buildCommandLine(command: String, arguments: Array<String>): CStringResource {
    let cmdLineBuilder: StringBuilder = StringBuilder()
    // concatenate command
    let escapeCommand = escapeArgument(command)
    cmdLineBuilder.append(escapeCommand)
    // concatenate arguments
    for (arg in arguments) {
        cmdLineBuilder.append(r' ')
        cmdLineBuilder.append(escapeArgument(arg))
    }

    return unsafe { LibC.mallocCString(cmdLineBuilder.toString()).asResource() }
}

@When[os == "Windows"]
func escapeArgument(arg: String): String {
    if (arg.size == 0) {
        return "\"\""
    }

    var needBackslash: Bool = false
    var hasSpace: Bool = false
    let argRuneArr: Array<Rune> = arg.toRuneArray()
    for (argRune in argRuneArr) {
        if (argRune == r'"' || argRune == r'\\') {
            needBackslash = true
        }

        if (argRune == r' ' || argRune == r'\t') {
            hasSpace = true
        }
    }

    if (!needBackslash && !hasSpace) {
        return arg
    }

    if (!needBackslash && hasSpace) {
        let sb = StringBuilder(r'"')
        sb.append(arg)
        sb.append(r'"')
        return sb.toString()
    }

    var escapeArgBuilder: StringBuilder = StringBuilder()
    var slashCount = 0
    for (argRune in argRuneArr) {
        match (argRune) {
            case r'\\' => slashCount++
            case r'"' =>
                while (slashCount > 0) {
                    escapeArgBuilder.append(r'\\')
                    slashCount--
                }
                escapeArgBuilder.append(r'\\')
            case _ => slashCount = 0
        }
        escapeArgBuilder.append(argRune)
    }

    var escapeArg = escapeArgBuilder.toString()
    if (hasSpace) {
        while (slashCount > 0) {
            escapeArgBuilder.append(r'\\')
            slashCount--
        }
        let sb = StringBuilder(r'"')
        sb.append(escapeArgBuilder)
        sb.append(r'"')
        escapeArg = sb.toString()
    }
    return escapeArg
}

@When[os == "Windows"]
func createEnvironmentBlock(environments: ?Map<String, String>): CStringResource {
    let environmentMap: Map<String, String> = environments ?? return CString(CPointer()).asResource()

    if (environmentMap.isEmpty()) {
        return unsafe { LibC.mallocCString(String.fromUtf8Unchecked([0u8, 0u8])).asResource() }
    }

    let environment_arr: Array<String> = environmentMap |> map<(String, String), String> {
        envEntry: (String, String) =>
            let sb = StringBuilder(envEntry[0])
            sb.append(r'=')
            sb.append(envEntry[1])
            sb.append(r'\0')
            sb.toString()
    } |> collectArray
    let envBlockBuilder: StringBuilder = StringBuilder()
    environment_arr |> forEach<String> {
        envElement => envBlockBuilder.append(envElement)
    }
    envBlockBuilder.append(r'\0')
    return unsafe { LibC.mallocCString(envBlockBuilder.toString()).asResource() }
}

func initStdStream(processRtnData: ProcessRtnData): (OutputStream, InputStream, InputStream) {
    let stdInStream: OutputStream
    if (processRtnData.stdInHandle == INVALID_HANDLE) {
        stdInStream = NullProcessStream()
    } else {
        stdInStream = ProcessOutputStream(FileDescriptor(processRtnData.stdInHandle))
    }

    let stdOutStream: InputStream
    if (processRtnData.stdOutHandle == INVALID_HANDLE) {
        stdOutStream = NullProcessStream()
    } else {
        stdOutStream = ProcessInputStream(FileDescriptor(processRtnData.stdOutHandle))
    }

    let stdErrStream: InputStream
    if (processRtnData.stdErrHandle == INVALID_HANDLE) {
        stdErrStream = NullProcessStream()
    } else {
        stdErrStream = ProcessInputStream(FileDescriptor(processRtnData.stdErrHandle))
    }

    return (stdInStream, stdOutStream, stdErrStream)
}

@When[os != "Windows"]
func buildSubProcess(command: String, arguments: Array<String>, workingDir_c: CString, environment: ?Map<String, String>,
    std_redirects: Array<ProcessRedirect>): SubProcess {
    let cmdArgCombinList: ArrayList<String> = ArrayList<String>.of(command)
    cmdArgCombinList.add(all: arguments)
    var cmdArg_cArr: Array<CString> = cmdArgCombinList |> map {arg: String => unsafe { LibC.mallocCString(arg) }} |>
        collectCStringArray
    var environment_cArr: Array<CString> = Array<CString>()
    try {
        // if environment is None, it will be use current environment which from it's parent's process.
        environment_cArr = match (environment) {
            case Some(env) => env |> map<(String, String), CString> {
                envEntry: (String, String) =>
                    let sb: StringBuilder = StringBuilder(envEntry[0])
                    sb.append(r'=')
                    sb.append(envEntry[1])
                    unsafe { LibC.mallocCString(sb.toString()) }
            } |> collectCStringArray
            case _ => Array<CString>()
        }
    } catch (e: IllegalMemoryException) {
        for (arg_cStr in cmdArg_cArr) {
            unsafe { LibC.free(arg_cStr) }
        }
        throw e
    }

    let cmdArg_cpHandle: CPointerHandle<CString> = unsafe { acquireArrayRawData<CString>(cmdArg_cArr) }
    let environment_cpHandle: CPointerHandle<CString> = unsafe { acquireArrayRawData<CString>(environment_cArr) }
    var environment_pt: CPointer<CString> = CPointer<CString>()
    if (let Some(_) <- environment) {
        environment_pt = environment_cpHandle.pointer
    }
    let subProcess: SubProcess
    var processRtnData_cp: CPointer<ProcessRtnData> = CPointer<ProcessRtnData>()
    var processInfo_cp: CPointer<ProcessInfo> = CPointer<ProcessInfo>()
    var processStartInfo_cp: CPointer<ProcessStartInfo> = CPointer<ProcessStartInfo>()
    // convert attribute from String to CString
    var command_c: CString = CString(CPointer<UInt8>())
    try {
        let stdIn_fd = matchRedirectFileHandle(std_redirects[0], StdIO.StdIn)
        let stdOut_fd = matchRedirectFileHandle(std_redirects[1], StdIO.StdOut)
        let stdErr_fd = matchRedirectFileHandle(std_redirects[2], StdIO.StdErr)

        command_c = unsafe { LibC.mallocCString(command) }
        let processStartInfo: ProcessStartInfo = ProcessStartInfo(command_c, cmdArg_cpHandle.pointer,
            UIntNative(cmdArg_cArr.size), workingDir_c, environment_pt, UIntNative(environment_cArr.size), stdIn_fd,
            stdOut_fd, stdErr_fd)
        processStartInfo_cp = unsafe { CJ_OS_CreateProcessStartInfo() }
        unsafe { processStartInfo_cp.write(processStartInfo) }
        processRtnData_cp = unsafe { CJ_OS_StartProcess(processStartInfo_cp) }
        // processRtnData errcode not 0 means not success, and it's should not go on.
        // should deal with the errcode give detail message.
        if (processRtnData_cp.isNull()) {
            throw ProcessException("Failed to create process.")
        }

        let processRtnData: ProcessRtnData = unsafe { processRtnData_cp.read() }
        if (processRtnData.errCode != 0) {
            throw ProcessException("Failed to create process: ${processRtnData.errMessage}.")
        }

        processInfo_cp = unsafe { CJ_OS_GetProcessInfoByPid(processRtnData.pid) }
        if (processInfo_cp.isNull()) {
            throw ProcessException("Failed to create process.")
        }

        let processInfo = unsafe { processInfo_cp.read() }
        let pid: Int32 = processRtnData.pid
        let (commandInfo, name, workDirPath, argumentsInfo, commandLine, environments) = getProcessInfo(processInfo)
        let (stdInStream, stdOutStream, stdErrStream) = initStdStream(processRtnData)
        subProcess = SubProcess(Int64(pid), name, commandInfo, argumentsInfo, commandLine, workDirPath, environments,
            stdInStream, stdOutStream, stdErrStream)
    } catch (e: Exception) {
        if (!processRtnData_cp.isNull()) {
            let processRtnData: ProcessRtnData = unsafe { processRtnData_cp.read() }
            if (processRtnData.pid != 0) {
                unsafe { CJ_OS_WaitSubProcessExit(processRtnData.pid) }
            }
        }
        throw e
    } finally {
        unsafe {
            if (!command_c.isNull()) {
                LibC.free(command_c)
            }
            for (arg_cStr in cmdArg_cArr) {
                LibC.free(arg_cStr)
            }
            releaseArrayRawData<CString>(cmdArg_cpHandle)
            for (env_cStr in environment_cArr) {
                LibC.free(env_cStr)
            }
            releaseArrayRawData<CString>(environment_cpHandle)
            CJ_OS_FreeProcessInfo(processInfo_cp)
            CJ_OS_FreeProcessRtnData(processRtnData_cp)
            CJ_OS_FreeProcessStartInfo(processStartInfo_cp)
        }
    }

    return subProcess
}

/**
 * matchRedirectFileHandle
 *
 * @param redirect - process redirect mode, include pipe, inherit, discard and fromfile
 * @param stdio    - stdio type, include stdin, stdout and stderr
 *
 * @return IntNative
 */
func matchRedirectFileHandle(redirect: ProcessRedirect, stdio: StdIO): IntNative {
    return match (redirect) {
        case ProcessRedirect.Pipe => INVALID_HANDLE
        case ProcessRedirect.Inherit => match (stdio) {
            case StdIO.StdIn => getStdInHandle()
            case StdIO.StdOut => getStdOutHandle()
            case StdIO.StdErr => getStdErrHandle()
        }
        case ProcessRedirect.Discard =>
            if (let Some(fileHandle) <- getNulFileHandle()) {
                fileHandle
            } else {
                throw ProcessException("Failed to open null file: cannot redirect stdio to discard mode.")
            }
        case ProcessRedirect.FromFile(file: File) =>
            let fileUnavailable: Bool = if (exists(file.info.path)) {
                file.isClosed()
            } else {
                true
            }
            if (fileUnavailable) {
                throw ProcessException("Redirect file is closed or does not exist.")
            }
            file.fileDescriptor.fileHandle
    }
}

public func findProcess(pid: Int64): Process {
    if (pid > Int64(Int32.Max) || pid < 0) {
        throw IllegalArgumentException("Invalid pid '${pid}'.")
    }
    return Process.buildProcess(Int32(pid))
}

private func launchImpl(
    command: String,
    arguments: Array<String>,
    workingDirectory: ?Path,
    environment: ?Map<String, String>,
    stdIn: ProcessRedirect,
    stdOut: ProcessRedirect,
    stdErr: ProcessRedirect
): SubProcess {
    var std_redirects: Array<ProcessRedirect> = [stdIn, stdOut, stdErr]
    // check command, arguments and environment, can not be empty or Null.
    // workingDirectory must be directory.
    if (command.contains("\0")) {
        throw IllegalArgumentException("Command '${command}' contains null character.")
    }

    for (arg in arguments) {
        if (arg.contains("\0")) {
            throw IllegalArgumentException("Argument '${arg}' contains null character.")
        }
    }

    if (let Some(envMap) <- environment) {
        for (envEntry in envMap) {
            if (envEntry[0].contains("\0") || envEntry[0].contains("=") || envEntry[1].contains("\0")) {
                throw IllegalArgumentException("Environment entry '${envEntry[0]}' contains invalid character.")
            }
        }
    }

    if (let Some(dir) <- workingDirectory) {
        try {
            if (!FileInfo(dir).isDirectory()) {
                throw IllegalArgumentException("Working directory '${dir}' must be a directory.")
            }
        } catch (_: FSException) {
            throw IllegalArgumentException("Working directory '${dir}' does not exist.")
        }
    }

    if (getNulFileHandle().isNone() && Process.hasDiscardMode(std_redirects)) {
        throw IllegalArgumentException("Failed to open null file: cannot redirect stdio to discard mode.")
    }

    // convert attribute from String to CString
    // if workingDir is None, it means exec the command in current dir.
    let workingDir_c: CString = match (workingDirectory) {
        case Some(dir) => unsafe { LibC.mallocCString(dir.toString()) }
        case _ => CString(CPointer())
    }

    try {
        return buildSubProcess(command, arguments, workingDir_c, environment, std_redirects)
    } finally {
        // release malloc space
        unsafe {
            workingDir_c.asResource().close()
        }
    }
}

/**
 * start a new subProcess using command and arguments which provide by user.
 *
 * @param command - vaild system command, should not be empty string and can not include Null character.
 * @param arguments - command arguments, each of the arguments should not be empty string and can not include Null character.
 * @param workingDirectory - command working directory, if None, means inherit current process working directory.
 * @param environment - command working environment, if None, means inherit current process environment.
 * @param stdIn - stdIn redirect mode.
 * @param stdOut - stdOut redirect mode.
 * @param stdErr - stdErr redirect mode.
 *
 * @return SubProcess - a new subProcess instance.
 */
@When[os != "iOS"]
public func launch(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Inherit,
    stdErr!: ProcessRedirect = Inherit
): SubProcess {
    launchImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr)
}

@When[os == "iOS"]
@Deprecated
public func launch(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Inherit,
    stdErr!: ProcessRedirect = Inherit
): SubProcess {
    launchImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr)
}

/**
 * func execute is combine the launch and wait.
 * provide a convenient way for user, which want start a subprocess and wait the command exec return code.
 */
@When[os != "iOS"]
public func execute(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Inherit,
    stdErr!: ProcessRedirect = Inherit,
    timeout!: ?Duration = None
): Int64 {
    let exitCode = executeImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr, timeout)
    exitCode
}

@When[os == "iOS"]
@Deprecated
public func execute(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Inherit,
    stdErr!: ProcessRedirect = Inherit,
    timeout!: ?Duration = None
): Int64 {
    executeImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr, timeout)
}

private func executeImpl(
    command: String,
    arguments: Array<String>,
    workingDirectory: ?Path,
    environment: ?Map<String, String>,
    stdIn: ProcessRedirect,
    stdOut: ProcessRedirect,
    stdErr: ProcessRedirect,
    timeout: ?Duration
): Int64 {
    let subProcess = launch(command, arguments, workingDirectory: workingDirectory, environment: environment,
        stdIn: stdIn, stdOut: stdOut, stdErr: stdErr)
    try {
        return subProcess.wait(timeout: timeout)
    } catch (e: TimeoutException) {
        // Only a local reference is held here, so after the timeout the child
        // would otherwise never be reaped on Unix.
        reapSubProcessAfterTimeout(subProcess)
        throw e
    }
}

/**
 * func executeWithOutput is combine the start and waitOutput.
 * provide a convenient way for user, which want start a subprocess and wait the command exec output and err result.
 */
@When[os != "iOS"]
public func executeWithOutput(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Pipe,
    stdErr!: ProcessRedirect = Pipe
): (Int64, Array<Byte>, Array<Byte>) {
    let output = executeWithOutputImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr)
    output
}

@When[os == "iOS"]
@Deprecated
public func executeWithOutput(
    command: String,
    arguments: Array<String>,
    workingDirectory!: ?Path = None,
    environment!: ?Map<String, String> = None,
    stdIn!: ProcessRedirect = Inherit,
    stdOut!: ProcessRedirect = Pipe,
    stdErr!: ProcessRedirect = Pipe
): (Int64, Array<Byte>, Array<Byte>) {
    executeWithOutputImpl(command, arguments, workingDirectory, environment, stdIn, stdOut, stdErr)
}

private func executeWithOutputImpl(
    command: String,
    arguments: Array<String>,
    workingDirectory: ?Path,
    environment: ?Map<String, String>,
    stdIn: ProcessRedirect,
    stdOut: ProcessRedirect,
    stdErr: ProcessRedirect
): (Int64, Array<Byte>, Array<Byte>) {
    let subProcess = launch(command, arguments, workingDirectory: workingDirectory, environment: environment,
        stdIn: stdIn, stdOut: stdOut, stdErr: stdErr)
    subProcess.waitOutput()
}
