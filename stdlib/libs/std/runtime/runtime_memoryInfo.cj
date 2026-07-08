/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.runtime

@When[backend == "cjnative"]
import std.fs.*

@When[os == "Windows"]
foreign func CJ_Runtime_OpenFileForFd(path: CString): Int32

@When[os == "Windows"]
foreign func CJ_Runtime_CloseFd(fd: Int32): Int32

@Intrinsic
func getMaxCjHeapSize(): UIntNative

@Intrinsic
func getAllocatedCjHeapSize(): UIntNative

@Intrinsic
func getRealHeapSize(): UIntNative

@When[backend == "cjnative"]
@Intrinsic
func dumpCjHeapData(fd: Int32): Bool

@When[backend == "cjnative"]
func boxDumpCjHeapData(fd: Int32): Bool {
    return dumpCjHeapData(fd)
}

@When[backend == "cjnative"]
@Frozen
@Intrinsic
public func blackBox<T>(input: T): T

class MemoryInfoException <: Exception {
    init(message: String) {
        super(message)
    }

    protected func getClassName(): String {
        return "MemoryInfoException"
    }
}

@Deprecated[message: "All static Properties are converted to public functions."]
public struct MemoryInfo {
    /**
     * Get the maximum heap size that can be used.
     */
    public static prop maxHeapSize: Int64 {
        get() {
            Int64(getMaxHeapSize())
        }
    }

    /**
     * Get the heap size that is allocated.
     */
    public static prop allocatedHeapSize: Int64 {
        get() {
            Int64(getAllocatedHeapSize())
        }
    }

    /**
     * Get the physical memory that is used by heap.
     */
    public static prop heapPhysicalMemory: Int64 {
        get() {
            getUsedHeapSize()
        }
    }
}

public func getMaxHeapSize(): Int64 {
    return Int64(getMaxCjHeapSize())
}

public func getAllocatedHeapSize(): Int64 {
    return Int64(getAllocatedCjHeapSize())
}

public func getUsedHeapSize(): Int64 {
    var ret = Int64(getRealHeapSize())
    match {
        case ret >= 0 => return ret
        case ret == -1 => throw MemoryInfoException("Failed to open the smaps file.")
        case ret == -2 => throw MemoryInfoException("Failed to get vaild value.")
        case _ => throw MemoryInfoException("Failed to get vaild errorcode.")
    }
}

@When[backend == "cjnative"]
private const MAX_PATH_LENGTH: Int64 = 4096

/**
 * Security checks to prevent path injection attacks:
 * 1. Empty path check - prevents null/empty path vulnerabilities
 * 2. Path length check - prevents buffer overflow and DoS attacks (>4096 chars)
 * 3. Null byte injection check - prevents path truncation attacks
 */
@When[backend == "cjnative"]
func validatePathString(pathStr: String): Bool {
    if (pathStr.isEmpty() || pathStr.size > MAX_PATH_LENGTH) {
        return false
    }
    if (pathStr.contains("\0")) {
        return false
    }
    return true
}

@When[backend == "cjnative"]
func resolvePath(path: Path): Path {
    let absolutePath = if (path.isAbsolute()) {
        path
    } else {
        canonicalize(Path(".")).join(path)
    }

    let resolvedPath = try {
        let parentDir = absolutePath.parent
        if (exists(parentDir)) {
            let resolvedParent = canonicalize(parentDir)
            let candidatePath = resolvedParent.join(absolutePath.fileName)
            if (exists(candidatePath) && FileInfo(candidatePath).isSymbolicLink()) {
                canonicalize(candidatePath)
            } else {
                candidatePath
            }
        } else {
            absolutePath
        }
    } catch (e: Exception) {
        absolutePath
    }

    return resolvedPath
}

@When[backend == "cjnative"]
func validateAndResolvePath(path: Path, invalidPathMsg: String): Path {
    let pathStr = path.toString()
    if (!validatePathString(pathStr)) {
        throw IllegalArgumentException(invalidPathMsg)
    }
    return resolvePath(path)
}

@When[backend == "cjnative" && os == "Windows"]
func executeWithWindowsFd(path: Path, action: (Int32) -> Bool): Bool {
    unsafe {
        var success = false
        try (cPath = LibC.mallocCString(path.toString()).asResource()) {
            let fd = CJ_Runtime_OpenFileForFd(cPath.value)
            if (fd == -1) {
                return false
            }
            success = action(fd)
            CJ_Runtime_CloseFd(fd)
        }
        return success
    }
}

@When[backend == "cjnative" && os != "Windows"]
public func dumpHeapData(path: Path): Unit {
    let resolvedPath = validateAndResolvePath(path,
        "Heap dump path is invalid or contains forbidden characters for security reasons.")
    try (file = File(resolvedPath, ReadWrite)) {
        let success = dumpCjHeapData(Int32(file.fileDescriptor.fileHandle))
        if (!success) {
            throw MemoryInfoException("Failed to dump heap data.")
        }
    }
}

@When[backend == "cjnative" && os == "Windows"]
public func dumpHeapData(path: Path): Unit {
    let resolvedPath = validateAndResolvePath(path,
        "Heap dump path is invalid or contains forbidden characters for security reasons.")
    let success = executeWithWindowsFd(resolvedPath, boxDumpCjHeapData)
    if (!success) {
        throw MemoryInfoException("Failed to dump heap data.")
    }
}
