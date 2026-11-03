/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@Frozen
public func print(str: String, flush!: Bool = false): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_PrintUTF8(cp.pointer, str.size, false, flush)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

@Frozen
@When[env != "ohos"]
public func print(str: String @local?, flush!: Bool = false): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_PrintUTF8(cp.pointer, str.size, false, flush)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

@Frozen
public func println(): Unit {
    unsafe {
        CJ_CORE_PrintChar(UInt32(r'\n'), false, false)
    }
}

@Frozen
public func println(str: String): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_PrintUTF8(cp.pointer, str.size, true, false)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

@Frozen
@When[env != "ohos"]
public func println(str: String @local?): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_PrintUTF8(cp.pointer, str.size, true, false)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

// The `eprint` is used to print error message, such as exception throwing.
// The message will be printed to standard error text stream rather than standard output.
@Frozen
public func eprint(str: String, flush!: Bool = true): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_ErrorPrintUTF8(cp.pointer, str.size, false, flush)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

// The `eprintln` is used to print error message, such as exception throwing.
// The message will be printed to standard error text stream rather than standard output.
@Frozen
public func eprintln(str: String): Unit {
    unsafe {
        var cp = acquireArrayRawData(str.rawData())
        let ret = CJ_CORE_ErrorPrintUTF8(cp.pointer, str.size, true, true)
        releaseArrayRawData(cp)
        if (ret == -1) {
            throw OutOfMemoryError()
        }
    }
}

@Frozen
public func eprint<T>(arg: T, flush!: Bool = false): Unit where T <: ToString {
    eprint(arg.toString(), flush: flush)
}

@Frozen
public func eprintln<T>(arg: T): Unit where T <: ToString {
    eprintln(arg.toString())
}

@Frozen
public func print<T>(arg: T, flush!: Bool = false): Unit where T <: ToString {
    print(arg.toString(), flush: flush)
}

@Frozen
public func println<T>(arg: T): Unit where T <: ToString {
    println(arg.toString())
}

public func readln(): String {
    let ln = readFromConsole()
    if (ln.endsWith("\r\n")) {
        return ln[..ln.size - 2]
    } else if (ln.endsWith('\n')) {
        return ln[..ln.size - 1]
    }
    return ln
}

private func readFromConsole(): String {
    let build: StringBuilder = StringBuilder()
    let line: CPointer<StructureString> = unsafe { CJ_CONSOLE_Readline() }
    if (line.isNull()) {
        unsafe { CJ_CONSOLE_ClearstdInerr() }
        throw IllegalStateException("Failed to read from console: I/O error or EOF.")
    }
    let str = unsafe { line.read() }
    var itemLen = Int64(str.length)
    try {
        var buffer: Array<Byte> = Array<Byte>(itemLen, repeat: 0)
        var i: Int64 = 0
        while (i < itemLen) {
            var c = unsafe { str.buffer.read(i) }
            buffer[i] = c
            i++
        }
        build.appendFromUtf8(buffer)
    } finally {
        unsafe {
            LibC.free(str.buffer)
            LibC.free(line)
        }
    }
    return build.toString()
}

/**
 * overload primitive types for performance optimization
 * For example, when using `Bool` type as the argument of `print` function, there are two steps:
 * 1. call `toString()` method to create a String
 * 2. call `print(String)` function to do the printing
 * A few temporary objects like `Array<UInt8>` and `String` are created in above process.
 * If we provide a few overloaded `print` function below, these temporary objects can be avoided.
 */
@Frozen
public func print(b: Bool, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintBool(b, false, flush) }
}

@Frozen
public func println(b: Bool): Unit {
    unsafe { CJ_CORE_PrintBool(b, true, false) }
}

@Frozen
public func print(c: Rune, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintChar(UInt32(c), false, flush) }
}

@Frozen
public func println(c: Rune): Unit {
    unsafe { CJ_CORE_PrintChar(UInt32(c), true, false) }
}

@Frozen
public func print(f: Float16, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintFloat(Float64(f), false, flush) }
}

@Frozen
public func println(f: Float16): Unit {
    unsafe { CJ_CORE_PrintFloat(Float64(f), true, false) }
}

@Frozen
public func print(f: Float32, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintFloat(Float64(f), false, flush) }
}

@Frozen
public func println(f: Float32): Unit {
    unsafe { CJ_CORE_PrintFloat(Float64(f), true, false) }
}

@Frozen
public func print(f: Float64, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintFloat(f, false, flush) }
}

@Frozen
public func println(f: Float64): Unit {
    unsafe { CJ_CORE_PrintFloat(f, true, false) }
}

@Frozen
public func print(i: Int8, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), false, flush) }
}

@Frozen
public func print(i: Int16, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), false, flush) }
}

@Frozen
public func print(i: Int32, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), false, flush) }
}

@Frozen
public func print(i: Int64, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintSigned(i, false, flush) }
}

@Frozen
public func print(i: UInt8, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), false, flush) }
}

@Frozen
public func print(i: UInt16, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), false, flush) }
}

@Frozen
public func print(i: UInt32, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), false, flush) }
}

@Frozen
public func print(i: UInt64, flush!: Bool = false): Unit {
    unsafe { CJ_CORE_PrintUnsigned(i, false, flush) }
}

@Frozen
public func println(i: Int8): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), true, false) }
}

@Frozen
public func println(i: Int16): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), true, false) }
}

@Frozen
public func println(i: Int32): Unit {
    unsafe { CJ_CORE_PrintSigned(Int64(i), true, false) }
}

@Frozen
public func println(i: Int64): Unit {
    unsafe { CJ_CORE_PrintSigned(i, true, false) }
}

@Frozen
public func println(i: UInt8): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), true, false) }
}

@Frozen
public func println(i: UInt16): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), true, false) }
}

@Frozen
public func println(i: UInt32): Unit {
    unsafe { CJ_CORE_PrintUnsigned(UInt64(i), true, false) }
}

@Frozen
public func println(i: UInt64): Unit {
    unsafe { CJ_CORE_PrintUnsigned(i, true, false) }
}
