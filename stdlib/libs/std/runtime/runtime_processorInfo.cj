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

@When[backend == "cjnative"]
@Intrinsic
func startCjCPUProfiling(): Bool

@When[backend == "cjnative"]
func boxStopCjCPUProfiling(fd: Int32): Bool {
    return stopCjCPUProfiling(fd)
}

@When[backend == "cjnative"]
@Intrinsic
func stopCjCPUProfiling(fd: Int32): Bool

@FastNative
foreign func CJ_OS_ProcessorCount(): Int64

class ProfilingInfoException <: Exception {
    init(message: String) {
        super(message)
    }

    protected func getClassName(): String {
        return "ProfilingInfoException"
    }
}

@Deprecated[message: "All static Properties are converted to public functions."]
public struct ProcessorInfo {
    // Get the number of processors
    public static prop processorCount: Int64 {
        get() {
            getProcessorCount()
        }
    }
}

public func getProcessorCount(): Int64 {
    return unsafe { CJ_OS_ProcessorCount() }
}

@When[backend == "cjnative"]
public func startCPUProfiling(): Unit {
    let success = startCjCPUProfiling()
    if (!success) {
        throw ProfilingInfoException("Failed to start cpu profiling.")
    }
    return
}

@When[backend == "cjnative" && os != "Windows"]
public func stopCPUProfiling(path: Path): Unit {
    try (file = File(path, ReadWrite)) {
        let success = stopCjCPUProfiling(Int32(file.fileDescriptor.fileHandle))
        if (!success) {
            throw ProfilingInfoException("Failed to stop cpu profiling.")
        }
    }
}

@When[backend == "cjnative" && os == "Windows"]
public func stopCPUProfiling(path: Path): Unit {
    let success = executeWithWindowsFd(path, boxStopCjCPUProfiling)
    if (!success) {
        throw ProfilingInfoException("Failed to stop cpu profiling.")
    }
}
