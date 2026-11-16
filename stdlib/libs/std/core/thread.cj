/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@When[backend == "cjnative"]
@Intrinsic
func isThreadObjectInited(): Bool

@When[backend == "cjnative"]
@Intrinsic
func getThreadObject(): Thread

@When[backend == "cjnative"]
@Intrinsic
func dumpAllThreadsInfo(): RawArray<ThreadSnapshotInfo>

@When[backend == "cjnative"]
@Intrinsic
func dumpCurrentThreadInfo(): ThreadSnapshotInfo

@FastNative
foreign func CJ_MRT_SetCJThreadName(handle: CPointer<Unit>, name: CPointer<UInt8>, len: UIntNative): Unit

@FastNative
foreign func CJ_MRT_GetCJThreadId(handle: CPointer<Unit>): Int64

@FastNative
foreign func CJ_MRT_GetCurrentCJThread(): CPointer<Unit>

@FastNative
foreign func CJ_MRT_GetCJThreadState(handle: CPointer<Unit>): Int64

const INVALID_ID: Int64 = -1

/**
 * Enum representing the possible states of a thread.
 * Implements ToString for human-readable representation.
 */
public enum ThreadState <: ToString {
    Ready | Running | Pending | Terminated | ...

    /**
     * Converts the enum value to its string representation
     * @return String representation of the thread state
     */
    public func toString(): String {
        match (this) {
            case Ready => "Ready"
            case Running => "Running"
            case Pending => "Pending"
            case Terminated => "Terminated"
            case _ => "Unknown"
        }
    }

    /**
     * Parses an integer value into a ThreadState enum.
     * @param value Integer value representing the thread state
     * @return Corresponding ThreadState enum value
     * @throws IllegalArgumentException if the value is not supported
     */
    static func parse(value: Int64): ThreadState {
        match (value) {
            case 0 => Terminated
            case 1 => Ready
            case 2 => Running
            case 3 => Pending
            case _ => throw IllegalArgumentException("Thread state value '${value}' is not supported.")
        }
    }
}

/**
 * Structure containing information about a thread snapshot.
 * Used for debugging and monitoring thread states.
 */
struct ThreadSnapshotInfo {
    let name: RawArray<UInt8> = EMPTY_UINT8_RAW_ARRAY
    let id: Int64 = 0
    let stackTrace: RawArray<StackTraceData> = rawArrayAllocate<StackTraceData>(0)
    let state: Int64 = 0
}

/**
 * Class representing a snapshot of a thread's state at a point in time.
 * Provides functionality for retrieving and printing thread information.
 */
public class ThreadSnapshot <: ToString {
    public let id: Int64
    public let name: String
    public let stackTrace: Array<StackTraceElement>
    public let state: ThreadState

    /**
     * Constructor for ThreadSnapshot.
     * @param id Thread identifier
     * @param name Thread name
     * @param state Current thread state
     * @param stackTrace Stack trace elements
     */
    init(id: Int64, name: String, state: ThreadState, stackTrace: Array<StackTraceElement>) {
        this.id = id
        this.name = name
        this.state = state
        this.stackTrace = stackTrace
    }

    /**
     * Converts the thread snapshot information to a string representation
     * 
     * @return Returns a formatted string containing thread ID, name, state and stack trace information
     */
    public func toString(): String {
        var stringBuffer = "ThreadSnapshot(id=${id}, name=${name}, state=${state})\n"
        stringBuffer = stringBuffer + "stack trace:\n"
        for (element in stackTrace) {
            if (element.declaringClass.isEmpty() && element.methodName.isEmpty()) { // simple stack trace format
                stringBuffer = stringBuffer + "\t at ${element.fileName}:${element.lineNumber}\n"
            } else {
                let packageDelimiter: String = if (element.declaringClass.isEmpty()) { "" } else { "." }
                stringBuffer = stringBuffer +
                    "\t at ${element.declaringClass}${packageDelimiter}${element.methodName}(${element.fileName}:${element.lineNumber})\n"
            }
        }
        return stringBuffer
    }
    
    /**
     * Parses ThreadSnapshotInfo into a ThreadSnapshot object.
     * @param info ThreadSnapshotInfo to parse
     * @return ThreadSnapshot object
     */
    private static func parseThreadInfo(info: ThreadSnapshotInfo): ThreadSnapshot {
        let infoSize = arraySize(info.stackTrace)
        let emptyStackTrace = StackTraceElement("", "", "", 0)
        let stackTraceArray = Array<StackTraceElement>(infoSize, repeat: emptyStackTrace)
        var eleSize = 0
        for (i in 0..infoSize) {
            let data = arrayGet(info.stackTrace, i)
            if (data.lineNumber == 0 || data.lineNumber == -1 || arraySize(data.fileName) == 0) {
                continue
            }
            let stkElem = StackTraceElement(
                String(data.className),
                String(data.methodName),
                String(data.fileName),
                data.lineNumber
            )
            stackTraceArray[eleSize] = stkElem
            eleSize++
        }
        return ThreadSnapshot(info.id, String(info.name), ThreadState.parse(info.state), stackTraceArray.clone(0..eleSize))
    }

    /**
     * Retrieves snapshots of all currently active threads.
     * @return Array of ThreadSnapshot objects
     */
    public static func dumpAllThreads(): Array<ThreadSnapshot> {
        let dumpInfo: RawArray<ThreadSnapshotInfo> = dumpAllThreadsInfo()
        let threadNum = arraySize(dumpInfo)
        let emptySnapshot = ThreadSnapshot(0, "", Terminated, [])
        let allThreadArray = Array<ThreadSnapshot>(threadNum, repeat: emptySnapshot)
        for (i in 0..threadNum) {
            allThreadArray[i] = parseThreadInfo(arrayGet(dumpInfo, i))
        }
        return allThreadArray
    }

    /**
     * Retrieves a snapshot of the current thread.
     * @return ThreadSnapshot of the current thread
     */
    public static func dumpCurrentThread(): ThreadSnapshot {
        let dumpInfo: ThreadSnapshotInfo = dumpCurrentThreadInfo()
        return parseThreadInfo(dumpInfo)
    }

}

public class Thread {
    static let exceptionHandler = AtomicBox<Option<(Thread, Exception) -> Unit>>(None)
    static let errorHandler = AtomicBox<Option<(Error) -> Unit>>(None)

    private let _name = AtomicBox<String>("")
    private let _hasCancellation = AtomicBool(false)
    private let _id = AtomicInt64(INVALID_ID)
    var _threadLocalMap: Option<ThreadLocalMap> = None
    // The `_rtCJThreadHandle` is a pointer to the underlying CJ thread,
    // when the CJ thread terminates, it will reclaim the memory pointered to by this pointer.
    // So, we should avoid the concurrent "use-after-free" problem.
    // The problem may occur when a thread access the pointer via a future object.
    // ---------------------------------------------------
    //   Thread 1                            Target thread
    // future.thread.name = "..."         Terminates and frees memory
    // ---------------------------------------------------
    // The solution is that we manage "reference counts" of the pointer,
    // and make sure freeing the memory only after there is no reference counts.
    // Note that the concurrent access problem occurs only when spawning a thread with a future object.
    private var _rtCJThreadHandle = CPointer<Unit>()
    // When the count == -1, it means the target thread has been terminated.
    private let _rtCJThreadHandleRefCount = AtomicInt64(0)

    // Should only be called within core package
    init() {}

    /**
     * Set the CJThread handle and get the CJThread id.
     * Note that this method will be imported implicitly and called when creating a thread with a future.
     */
    protected func setRuntimeCJThreadHandle(handle: CPointer<Unit>): Unit {
        _rtCJThreadHandle = handle
        let cjThreadId = unsafe { CJ_MRT_GetCJThreadId(handle) }
        _id.store(cjThreadId)
    }

    /**
     * Wait until CJThread handle is set properly.
     * This method will be called by the entry function (i.e., `Future.execute`)
     * when creating a thread with a future to avoid a potential data race,
     * where the new thread may exit and destroy CJThreadHandle before setting it.
     *         T1                                      T2
     *  let fut = Future();
     *  CJ_MRT_RuntimeNewTask(Future.execute)
     *  fut.thread.setRuntimeCJThreadHandle()
     *                                          waitForCJThreadHandle()
     *                                          ...
     *                                          exit
     */
    func waitForCJThreadHandle(): Unit {
        while (_id.load() == INVALID_ID) {
            // sleep(0) is equivalent to yielding the current thread
            intrinsicSleep(0)
        }
    }

    /**
     * Called by the thread entry function `Future.execute`.
     * Wait until the reference count == 0, and mark it as terminated.
     */
    func clearRuntimeCJThreadHandle(): Unit {
        while (true) {
            let old = _rtCJThreadHandleRefCount.load()
            if (old == 0 && _rtCJThreadHandleRefCount.compareAndSwap(0, -1)) {
                _rtCJThreadHandle = CPointer<Unit>()
                return
            }
        }
    }

    /**
     * If the thread is running,
     * hold the thread handle and increase the count to keep it available.
     */
    private func acquireCJThreadHandle(): CPointer<Unit> {
        while (true) {
            let old = _rtCJThreadHandleRefCount.load()
            if (old == -1) { // `-1` means the thread has been terminated
                return CPointer<Unit>()
            } else if (_rtCJThreadHandleRefCount.compareAndSwap(old, old + 1)) {
                // `_rtCJThreadHandle` is always not null
                if (_rtCJThreadHandle.isNull()) {
                    throw Error("Internal error: invalid CJThread handle!")
                }
                return _rtCJThreadHandle
            }
        }
        throw Error("Internal error: unreachable code!")
    }

    private func releaseCJThreadHandle(): Unit {
        _rtCJThreadHandleRefCount.fetchAdd(-1)
    }

    // If a Cangjie thread is created without a Future object,
    // its Thread object will be lazy-constructed.
    public static prop currentThread: Thread {
        get() {
            if (isThreadObjectInited()) {
                return getThreadObject()
            } else {
                let thread = Thread()
                // We should also set the runtime CJThread handle here
                let rtCJThreadHandle = unsafe { CJ_MRT_GetCurrentCJThread() }
                // `rtCJThreadHandle` is always not null.
                if (rtCJThreadHandle.isNull()) {
                    throw Error("Internal error: invalid CJThread handle!")
                }
                thread.setRuntimeCJThreadHandle(rtCJThreadHandle)
                setThreadObject(thread)
                thread
            }
        }
    }

    public prop id: Int64 {
        get() {
            var cjThreadId = _id.load()
            // Since we assign `_rtCJThreadHandle` and `_id` at the same time,
            // `_id` is always invalid.
            if (cjThreadId == INVALID_ID) {
                throw Error("Internal error: invalid thread ID!")
            }
            return cjThreadId
        }
    }

    public mut prop name: String {
        get() {
            _name.load()
        }
        set(newName) {
            _name.store(newName)
            // Assign the name to the underlying CJ thread if possible.
            let handle: CPointerHandle<Byte> = unsafe { acquireArrayRawData(newName.rawData()) }
            let rtCJThreadHandle = acquireCJThreadHandle()
            if (!rtCJThreadHandle.isNull()) {
                unsafe {
                    CJ_MRT_SetCJThreadName(rtCJThreadHandle, handle.pointer, UIntNative(newName.size))
                }
                releaseCJThreadHandle()
            }
            unsafe { releaseArrayRawData(handle) }
        }
    }

    /**
     * Check whether the current Cangjie thread has termination requests,
     * i.e., whether its future has been marked as cancelled.
     */
    public prop hasPendingCancellation: Bool {
        get() {
            _hasCancellation.load()
        }
    }

    func setCancellationRequest(): Unit {
        this._hasCancellation.store(true)
    }

    public static func handleUncaughtExceptionBy(exHandler: (Thread, Exception) -> Unit): Unit {
        Thread.exceptionHandler.store(exHandler)
    }

    @When[env != "ohos"]
    public static func handleUncaughtErrorBy(erHandler: (Error) -> Unit): Unit {
        Thread.errorHandler.store(erHandler)
    }
    
    /**
     * Get thread state
     * 
     * Returns the current thread's state by querying the underlying CJ thread.
     * Returns Terminated if thread handle is invalid.
     * 
     * @return ThreadState Current thread state
     */
    public prop state: ThreadState {
        get() {
            let handle = acquireCJThreadHandle()
            if (handle.isNull()) {
                return ThreadState.Terminated
            }
            let state = unsafe { CJ_MRT_GetCJThreadState(handle) }
            releaseCJThreadHandle()

            return ThreadState.parse(state)
        }
    }
}
