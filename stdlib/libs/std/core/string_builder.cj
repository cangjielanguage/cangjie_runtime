/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This file defines StringBuilder.
 */
package std.core

let digits100: Array<Byte> = [
    b'0',b'0',b'0',b'1',b'0',b'2',b'0',b'3',b'0',b'4',b'0',b'5',b'0',b'6',b'0',b'7',b'0',b'8',b'0',b'9', //00 ~ 09
    b'1',b'0',b'1',b'1',b'1',b'2',b'1',b'3',b'1',b'4',b'1',b'5',b'1',b'6',b'1',b'7',b'1',b'8',b'1',b'9', //10 ~ 19
    b'2',b'0',b'2',b'1',b'2',b'2',b'2',b'3',b'2',b'4',b'2',b'5',b'2',b'6',b'2',b'7',b'2',b'8',b'2',b'9', //20 ~ 29
    b'3',b'0',b'3',b'1',b'3',b'2',b'3',b'3',b'3',b'4',b'3',b'5',b'3',b'6',b'3',b'7',b'3',b'8',b'3',b'9', //30 ~ 39
    b'4',b'0',b'4',b'1',b'4',b'2',b'4',b'3',b'4',b'4',b'4',b'5',b'4',b'6',b'4',b'7',b'4',b'8',b'4',b'9', //40 ~ 49
    b'5',b'0',b'5',b'1',b'5',b'2',b'5',b'3',b'5',b'4',b'5',b'5',b'5',b'6',b'5',b'7',b'5',b'8',b'5',b'9', //50 ~ 59
    b'6',b'0',b'6',b'1',b'6',b'2',b'6',b'3',b'6',b'4',b'6',b'5',b'6',b'6',b'6',b'7',b'6',b'8',b'6',b'9', //60 ~ 69
    b'7',b'0',b'7',b'1',b'7',b'2',b'7',b'3',b'7',b'4',b'7',b'5',b'7',b'6',b'7',b'7',b'7',b'8',b'7',b'9', //70 ~ 79
    b'8',b'0',b'8',b'1',b'8',b'2',b'8',b'3',b'8',b'4',b'8',b'5',b'8',b'6',b'8',b'7',b'8',b'8',b'8',b'9', //80 ~ 89
    b'9',b'0',b'9',b'1',b'9',b'2',b'9',b'3',b'9',b'4',b'9',b'5',b'9',b'6',b'9',b'7',b'9',b'8',b'9',b'9'] //90 ~ 99

public class StringBuilder <: ToString {
    private var data: Array<UInt8>
    private var endIndex: Int64

    /* defines the buffer defaultCapacity */
    private static const defaultCapacity: Int64 = 32

    /**
     * Constructors
     */
    @Frozen
    public init() {
        this.data = Array<UInt8>(defaultCapacity, repeat: 0)
        this.endIndex = 0
    }

    // The buffer data stays heap-allocated: a plain field cannot hold an @local! array (type mismatch),
    // and the instance may outlive the region, so a local buffer would dangle.
    @When[env != "ohos"]
    public exclave init(this @local!) {
        this.data = Array<UInt8>(defaultCapacity, repeat: 0)
        this.endIndex = 0
    }

    @Frozen
    public init(str: String) {
        let capacity = str.size + defaultCapacity
        this.data = Array<UInt8>(capacity, repeat: 0)
        unsafe { str.rawData().copyTo(this.data, 0, 0, str.size) }
        this.endIndex = str.size
    }

    @Frozen
    public init(r: Rune, n: Int64) {
        if (n < 0) {
            throw IllegalArgumentException("The number of rune should not be negative.")
        }
        var bytesSize = Rune.utf8Size(r)
        let capacity = bytesSize * n + defaultCapacity
        this.data = Array<UInt8>(capacity, repeat: 0)
        var itemLen = 0
        for (_ in 0..n) {
            itemLen += Rune.intoUtf8Array(r, this.data, itemLen)
        }
        this.endIndex = itemLen
    }

    @Frozen
    public init(value: Array<Rune>) {
        if (value.size == 0) {
            this.data = Array<UInt8>(defaultCapacity, repeat: 0)
            this.endIndex = 0
        } else {
            var temp = RunesToUtf8Bytes.getBytes(value)
            let capacity = temp.size + defaultCapacity
            this.data = Array<UInt8>(capacity, repeat: 0)
            unsafe { temp.copyTo(this.data, 0, 0, temp.size) }
            this.endIndex = temp.size
        }
    }

    @Frozen
    public init(capacity: Int64) {
        if (capacity <= 0) {
            throw IllegalArgumentException("The capacity should be positive.")
        }
        this.data = Array<UInt8>(capacity, repeat: 0)
        this.endIndex = 0
    }

    @When[env != "ohos"]
    public exclave init(this @local!, capacity: Int64) {
        if (capacity <= 0) {
            throw IllegalArgumentException("The capacity should be positive.")
        }
        this.data = Array<UInt8>(capacity, repeat: 0)
        this.endIndex = 0
    }

    /**
     * Get UTF-8 code unit size.
     */
    @Frozen
    public prop size: Int64 {
        get() {
            return this.endIndex
        }
    }

    /**
     * Get capacity of this instance.
     */
    @Frozen
    public prop capacity: Int64 {
        get() {
            return this.data.size
        }
    }

    /**
     * Return a String managed by StringBuilder.
     *
     * @return a String managed by StringBuilder.
     */
    @Frozen
    public func toString(): String {
        return String(this.data[0..this.endIndex])
    }

    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let itemData: Array<UInt8> @local! = Array<UInt8>(this.endIndex, repeat: 0)
        this.data.copyTo(itemData, 0, 0, this.endIndex)
        String(itemData)
    }

    @When[env != "ohos"]
    internal exclave func toStringLocal(this @local!): String @local! {
        let itemData: Array<UInt8> @local! = Array<UInt8>(this.endIndex, repeat: 0)
        this.data.copyTo(itemData, 0, 0, this.endIndex)
        String(itemData)
    }

    /**
     * @throws IllegalMemoryException if there are some system errors.
     */
    @Frozen
    public func reset(capacity!: Option<Int64> = None): Unit {
        let newCapacity = if (let Some(v) <- capacity) {
            if (v <= 0) {
                throw IllegalArgumentException("The capacity should be positive.")
            }
            v
        } else {
            defaultCapacity
        }
        this.data = Array<UInt8>(newCapacity, repeat: 0)
        this.endIndex = 0
    }

    @OverflowWrapping
    @Frozen
    public func append(r: Rune): Unit {
        let byte = UInt32(r)
        if (byte <= UTF8_1_MAX) {
            this.grow(1)
            data[endIndex] = UInt8(byte)
            this.endIndex++
            return
        }
        var itemLen = Rune.utf8Size(r)
        this.grow(itemLen)
        var _ = Rune.intoUtf8Array(r, this.data, this.endIndex)
        this.endIndex += itemLen
    }

    // Note: do not implement it by delegating to a same-named plain method — under an @local! receiver a same-named call resolves recursively to itself.
    @When[env != "ohos"]
    internal exclave func growLocal(this @local!, minCapacity: Int64): Unit {
        if (this.data.size - this.endIndex >= minCapacity) {
            return
        }
        let oldCapacity = this.data.size
        var newCapacity = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < this.endIndex + minCapacity) {
            newCapacity = this.endIndex + minCapacity + (oldCapacity >> 1)
        }
        let itemData: Array<UInt8> @local! = Array<UInt8>(newCapacity, repeat: 0) @local!
        this.data.copyTo(itemData, 0, 0, this.endIndex)
        this.data = itemData
    }

    @OverflowWrapping
    @When[env != "ohos"]
    internal exclave func appendRune(this @local!, r: Rune): Unit {
        let byte = UInt32(r)
        if (byte <= UTF8_1_MAX) {
            this.growLocal(1)
            data[endIndex] = UInt8(byte)
            this.endIndex++
            return
        }
        let itemLen = Rune.utf8Size(r)
        this.growLocal(itemLen)
        var _ = Rune.intoUtf8Array(r, this.data, this.endIndex)
        this.endIndex += itemLen
    }

    @OverflowWrapping
    @When[env != "ohos"]
    internal exclave func appendString(this @local!, str: String @local?): Unit {
        if (str.isEmpty()) {
            return
        }
        let strData = unsafe { str.rawData() }
        let itemLen = strData.size
        this.growLocal(itemLen)
        strData.copyTo(this.data, 0, this.endIndex, itemLen)
        this.endIndex += itemLen
    }

    // Do not assign a local array to the plain field data (it confuses field metadata during GC scanning; SIGSEGV observed);
    // uniformly follow the "format into a String @local! -> appendString copies the bytes" template.
    @When[env != "ohos"]
    internal exclave func appendValue<T>(this @local!, v: T @local?): Unit where T <: ToString {
        this.appendString(v.toString())
    }

    @OverflowWrapping
    @Frozen
    public func append(str: String): Unit {
        if (str.isEmpty()) {
            return
        }
        var strData = unsafe { str.rawData() }
        var itemLen = strData.size
        this.grow(itemLen)
        strData.copyTo(this.data, 0, this.endIndex, itemLen)
        this.endIndex += itemLen
    }

    @OverflowWrapping
    @Frozen
    @When[env != "ohos"]
    public func append(str: String @local?): Unit {
        if (str.isEmpty()) {
            return
        }
        let strData = unsafe { str.rawData() }
        let itemLen = strData.size
        this.grow(itemLen)
        strData.copyTo(this.data, 0, this.endIndex, itemLen)
        this.endIndex += itemLen
    }

    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func append(this @local!, str: String @local?): Unit {
        this.appendString(str)
    }

    @OverflowWrapping
    @Frozen
    public func append(sb: StringBuilder): Unit {
        let itemLen = sb.endIndex
        if (itemLen == 0) {
            return
        }
        this.grow(itemLen)
        sb.data.copyTo(this.data, 0, this.endIndex, itemLen)
        this.endIndex += itemLen
    }

    /*
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array "arr[i]".
     */
    @OverflowWrapping
    @Frozen
    public func appendFromUtf8(arr: Array<Byte>): Unit {
        if (arr.size == 0) {
            return
        }
        checkInvalid(arr.rawptr, arr.start, arr.start + arr.size)
        var arrSize = arr.size
        this.grow(arrSize)
        arr.copyTo(this.data, 0, this.endIndex, arrSize)
        this.endIndex += arrSize
    }

    @OverflowWrapping
    @Frozen
    public unsafe func appendFromUtf8Unchecked(arr: Array<Byte>): Unit {
        if (arr.size == 0) {
            return
        }
        var itemLen = arr.size
        this.grow(itemLen)
        arr.copyTo(this.data, 0, this.endIndex, itemLen)
        this.endIndex += itemLen
        return
    }

    @Frozen
    public func append(runeArr: Array<Rune>): Unit {
        for (c in runeArr) {
            this.append(c)
        }
        return
    }

    @Frozen
    public func append(cstr: CString): Unit {
        this.append(cstr.toString())
    }

    @Frozen
    public func append<T>(v: T): Unit where T <: ToString {
        match (v) {
            case i64: Int64 => this.append(i64)
            case i32: Int32 => this.append(i32)
            case i16: Int16 => this.append(i16)
            case i8: Int8 => this.append(i8)
            case u64: UInt64 => this.append(u64)
            case u32: UInt32 => this.append(u32)
            case u16: UInt16 => this.append(u16)
            case u8: UInt8 => this.append(u8)
            case r: Rune => this.append(r)
            case b: Bool => this.append(b)
            case _ => this.append(v.toString())
        }
    }

    @When[env != "ohos"]
    public exclave func append<T>(this @local!, v: T @local?): Unit where T <: ToString {
        this.appendValue<T>(v)
    }

    @Frozen
    public func append<T>(val: Array<T>): Unit where T <: ToString {
        for (v in val) {
            this.append(v)
        }
    }

    @Frozen
    public func append(b: Bool): Unit {
        if (b) {
            this.append("true")
        } else {
            this.append("false")
        }
    }

    @Frozen
    @OverflowWrapping
    public func append(n: Int64): Unit {
        if (n == Int64.Min) {
            this.append("-9223372036854775808") // the Int64.Min cannot be negated, so append the string directly
            return
        }
        var numLen: Int64 = 0
        var unum: UInt64 = if (n < 0) {
            UInt64(-n)
        } else {
            UInt64(n)
        }
        numLen += calcNumLen(unum)

        if (n < 0) {
            this.grow(numLen + 1)
            this.data[this.endIndex] = b'-'
            this.endIndex++
        } else {
            this.grow(numLen)
        }

        numberToString(unum, numLen, Array<Byte>(this.data.rawptr, this.endIndex, numLen))
        this.endIndex += numLen
    }

    @Frozen
    public func append(n: Int32): Unit {
        return this.append(Int64(n))
    }

    @Frozen
    public func append(n: Int16): Unit {
        return this.append(Int64(n))
    }

    @Frozen
    public func append(n: Int8): Unit {
        return this.append(Int64(n))
    }

    @OverflowWrapping
    @Frozen
    public func append(n: UInt64): Unit {
        var numLen = calcNumLen(n)
        this.grow(numLen)
        numberToString(n, numLen, Array<Byte>(this.data.rawptr, this.endIndex, numLen))
        this.endIndex += numLen
    }

    @Frozen
    public func append(n: UInt32): Unit {
        return this.append(UInt64(n))
    }

    @Frozen
    public func append(n: UInt16): Unit {
        return this.append(UInt64(n))
    }

    @Frozen
    public func append(n: UInt8): Unit {
        return this.append(UInt64(n))
    }

    @Frozen
    public func append(n: Float64): Unit {
        unsafe {
            let p: CPointer<UInt8> = CJ_CORE_Float64ToCPointer(n)
            if (p.isNull()) {
                return
            }
            append(p)
            LibC.free(p)
        }
    }

    @Frozen
    public func append(n: Float32): Unit {
        return this.append(Float64(n))
    }

    @Frozen
    public func append(n: Float16): Unit {
        return this.append(Float64(n))
    }

    @Frozen
    @OverflowThrowing
    public func reserve(additional: Int64): Unit {
        if (this.data.size - this.endIndex >= additional) {
            return
        }
        let oldCapacity = this.data.size
        var newCapacity = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < this.endIndex + additional) {
            newCapacity = this.endIndex + additional
        }
        var itemData = Array<UInt8>(newCapacity, repeat: 0)
        this.data.copyTo(itemData, 0, 0, this.endIndex)
        this.data = itemData
    }

    @OverflowWrapping
    @Frozen
    private func grow(minCapacity: Int64): Unit {
        if (this.data.size - this.endIndex >= minCapacity) {
            return
        }
        let oldCapacity = this.data.size
        var newCapacity = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < this.endIndex + minCapacity) {
            newCapacity = this.endIndex + minCapacity + (oldCapacity >> 1)
        }
        var itemData = Array<UInt8>(newCapacity, repeat: 0)
        this.data.copyTo(itemData, 0, 0, this.endIndex)
        this.data = itemData
    }

    /**
     * To use this method, ensure that the input complies with the UTF-8 code.
     * Otherwise, an error occurs.
     */
    @Frozen
    private unsafe func append(cp: CPointer<UInt8>): Unit {
        let cpSize = Int64(strlen(cp))
        if (cpSize <= 0) {
            return
        }
        this.grow(cpSize)
        var index = 0
        while (index < cpSize) {
            let c = UInt8(cp.read(index))
            this.data[index + this.endIndex] = c
            index++
        }
        this.endIndex += cpSize
    }
}

@OverflowWrapping
func calcNumLen(num: UInt64): Int64 {
    var p: UInt64 = 10
    for (i in 1..19) {
        if (num < p) {
            return i
        }
        p = p * UInt64(10)
    }
    if (num >= 10000000000000000000) {
        return 20
    }
    return 19
}

@OverflowWrapping
func numberToString(number: UInt64, endIndex: Int64, buffer: Array<Byte>): Unit {
    //make sure endindex is smaller then buffer.size
    var next = endIndex - 1
    var value = number
    var i = 0
    while (value >= 100) {
        let remain = value / 100
        i = Int64((value - 100 * remain) * 2)
        value = remain
        buffer[next] = digits100[i + 1]
        buffer[next - 1] = digits100[i]
        next = next - 2
    }
    if (value < 10) {
        buffer[next] = b'0' + UInt8(value)
    } else {
        i = Int64(value * 2)
        buffer[next] = digits100[i + 1]
        buffer[next - 1] = digits100[i]
    }
}

@OverflowWrapping
@When[env != "ohos"]
exclave func numberToString(number: UInt64, endIndex: Int64, buffer: Array<Byte> @local!): Unit {
    //make sure endindex is smaller then buffer.size
    var next = endIndex - 1
    var value = number
    var i = 0
    while (value >= 100) {
        let remain = value / 100
        i = Int64((value - 100 * remain) * 2)
        value = remain
        buffer[next] = digits100[i + 1]
        buffer[next - 1] = digits100[i]
        next = next - 2
    }
    if (value < 10) {
        buffer[next] = b'0' + UInt8(value)
    } else {
        i = Int64(value * 2)
        buffer[next] = digits100[i + 1]
        buffer[next - 1] = digits100[i]
    }
}
