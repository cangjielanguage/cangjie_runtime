/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * The following functions are used by cjnative.
 */
var globalOutOfMemoryError = OutOfMemoryError()

@When[env != "ohos"]
@C
func throwImplicitException(id: Int64, args: CPointer<Unit>): Unit {
    match (id) {
        case 0 => throw OutOfMemoryError()
        case 1 => throw StackOverflowError()
        case 2 => throw globalOutOfMemoryError
        case 3 =>
            var msg = (args as CPointer<UInt8>).getOrThrow()
            throw IncompatiblePackageException(createStrFromCPointer(msg))
        case 4 => throw LocalRegionOutOfMemoryError()
        case _ => ()
    }
}

@When[env == "ohos"]
@C
func throwImplicitException(id: Int64, args: CPointer<Unit>): Unit {
    match (id) {
        case 0 => throw OutOfMemoryError()
        case 1 => throw StackOverflowError()
        case 2 => throw globalOutOfMemoryError
        case 3 =>
            var msg = (args as CPointer<UInt8>).getOrThrow()
            throw IncompatiblePackageException(createStrFromCPointer(msg))
        case _ => ()
    }
}

/*
 * @throws ArithmeticException if divided by zero
 */
func throwArithmeticException(): Unit {
    throw ArithmeticException("Division by zero.")
}

func createArithmeticExceptionMsg(msg: String): ArithmeticException {
    ArithmeticException(msg)
}

func throwArithmeticExceptionMsg(msg: String) {
    throw ArithmeticException(msg)
}

func createOverflowExceptionMsg(msg: String): OverflowException {
    OverflowException(msg)
}

/**
 * The following functions are used by the interpreter.
 */
func throwOverflowException(): Unit {
    throw OverflowException()
}

func throwIndexOutOfBoundsException(): Unit {
    throw IndexOutOfBoundsException()
}

func throwNegativeArraySizeException(): Unit {
    throw NegativeArraySizeException()
}

func callToString(e: ToString): String {
    e.toString()
}

func checkIsError(e: Object): Bool {
    e is Error
}

func throwError(msg: String): Unit {
    throw Error(msg)
}

func callPrintStackTrace(e: Exception): Unit {
    e.printStackTrace()
}

func callPrintStackTraceError(e: Error): Unit {
    e.printStackTrace()
}
