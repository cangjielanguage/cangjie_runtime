/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

public open class StackTraceElement <: ToString {
    public let declaringClass: String
    public let methodName: String
    public let fileName: String
    public let lineNumber: Int64

    public init(declaringClass: String, methodName: String, fileName: String, lineNumber: Int64) {
        this.declaringClass = declaringClass
        this.methodName = methodName
        this.fileName = fileName
        this.lineNumber = lineNumber
    }

    /**
     * Converts the call point information to a string representation
     * 
     * @return Returns a formatted string containing class name, method name, file name and line number information
     */
    public func toString(): String { 
        if (declaringClass.isEmpty() && methodName.isEmpty()) {
            return("${fileName}:${lineNumber}")
        } else {
            let packageDelimiter: String = if (declaringClass.isEmpty()) { "" } else { "." }
            return(
                "${declaringClass}${packageDelimiter}${methodName}(${fileName}:${lineNumber})")
        }
    }

    func equals(other: StackTraceElement): Bool {
        return this.declaringClass == other.declaringClass &&
            this.methodName == other.methodName &&
            this.fileName == other.fileName &&
            this.lineNumber == other.lineNumber
    }
}

// Workaround to avoid llvm back-end crash while compiling several `decodeStackTrace` instrinsic invocations
let decodeStackTraceWrapper = { pcArray: RawArray<UInt64>, j: Int64 =>
    return decodeStackTrace(
        arrayGet(pcArray, j * 3), arrayGet(pcArray, j * 3 + 1), arrayGet(pcArray, j * 3 + 2))
}

protected func getRawStackTrace(): Array<UInt64> {
    let arr = rawArrayAllocate<UInt64>(1)
    rawArrayInitByValue(arr, 1, 0)
    let stackTrace = fillInStackTrace(arr, String.empty.toArray().rawptr)
    return Array(stackTrace, 0, arraySize(stackTrace))
}

protected func decodeRawStackTrace(rawStackTrace: Array<UInt64>, frameIndex: Int64): Option<StackTraceElement> {
    let data = decodeStackTraceWrapper(rawStackTrace.rawptr, frameIndex)

    if ((data.lineNumber == 0 && arraySize(data.fileName) == 0) || data.lineNumber == -1) {
        return Option<StackTraceElement>.None
    }
    return StackTraceElement(
        String(data.className), String(data.methodName), String(data.fileName), data.lineNumber)
}
