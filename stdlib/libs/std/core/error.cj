/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

public open class Error <: ToString {
    private var detailMessage: String = String.empty
    var pcArray: RawArray<UInt64> = rawArrayAllocate<UInt64>(0)
    var traceElementArray: Array<StackTraceElement> = []

    init() {
        let arr = rawArrayAllocate<UInt64>(1)
        rawArrayInitByValue(arr, 1, 0)
        pcArray = fillInStackTrace(arr, detailMessage.toArray().rawptr)
    }

    init(message: String) {
        detailMessage = message
        let arr = rawArrayAllocate<UInt64>(1)
        rawArrayInitByValue(arr, 1, 0)
        pcArray = fillInStackTrace(arr, detailMessage.toArray().rawptr)
    }

    protected open func getClassName(): String {
        return "Error"
    }

    public open prop message: String {
        get() {
            return detailMessage
        }
    }

    public open func toString(): String {
        let className: String = getClassName()
        let message: String = this.message
        if (message.isEmpty()) {
            return className
        }
        return "${className}: ${message}"
    }

    public open func printStackTrace(): Unit {
        eprintln("An exception has occurred: ${getStackTraceMessage()}")
    }

    public open func getStackTraceMessage(): String {
        let message = StringBuilder()
        message.append(toString() + "\n")

        traceElementArray = getStackTrace()
        for (element in traceElementArray) {
            var packageDelimiter: String = if (element.declaringClass.isEmpty()) { "" } else { "." }
            message.append(
                "\t at ${element.declaringClass}${packageDelimiter}${element.methodName}(${element.fileName}:${element.lineNumber})\n")
        }

        return message.toString()
    }

    public func getStackTrace(): Array<StackTraceElement> {
        getStackTraceImpl(pcArray)
    }
}
