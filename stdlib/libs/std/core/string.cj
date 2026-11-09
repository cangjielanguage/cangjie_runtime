/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@Intrinsic
func vectorCompare32(arr1: RawArray<Byte> @local?, offset1: Int64, arr2: RawArray<Byte> @local?, offset2: Int64): Int64

@Intrinsic
func vectorIndexByte32(arr: RawArray<Byte>, offset: Int64, target: Byte): Int64

@When[backend == "cjnative"]
const UNICODE_TO_UTF8_MAX_LEN: Int64 = 4
@When[backend == "cjnative"]
@ConstSafe
const IS_SIMD_SUPPORTED: Bool = unsafe { CJ_CORE_CanUseSIMD() }
@When[backend == "cjnative"]
const VECTOR_OFFSET_32: Int64 = 32

@When[backend == "cjnative"]
@ConstSafe
public struct String <: Collection<Byte> & Comparable<String> & Hashable & ToString {
    let myData: RawArray<UInt8>
    let start: UInt32
    let length: UInt32

    public static const empty: String = String()

    /**
     * Constructors
     */

    // Create an empty string which is an empty sequence of character.
    @Frozen
    public const init() {
        (myData, start, length) = (EMPTY_UINT8_RAW_ARRAY, 0u32, 0u32)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave const init(this @local!) {
        myData = rawArrayAllocate2<UInt8>(0)
        start = 0
        length = 0
    }

    @Frozen
    @OverflowWrapping
    public init(value: Array<Rune>) {
        if (value.size == 0) {
            (myData, start, length) = (EMPTY_UINT8_RAW_ARRAY, 0u32, 0u32)
            return
        }
        let data = RunesToUtf8Bytes.getBytes(value)
        if (data.size > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${data.size}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        this.myData = data.rawptr
        this.start = UInt32(data.start)
        this.length = UInt32(data.len)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave init(this @local!, value: Array<Rune> @local?) {
        if (value.size == 0) {
            myData = rawArrayAllocate2<UInt8>(0)
            start = 0u32
            length = 0u32
            return
        }
        let data = RunesToUtf8Bytes.getBytesLocal(value)
        if (data.size > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        this.myData = data.rawptr
        this.start = UInt32(data.start)
        this.length = UInt32(data.len)
    }

    @Frozen
    @OverflowWrapping
    public init(value: Collection<Rune>) {
        let data = RunesToUtf8Bytes.getBytes(value)
        if (data.size > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${data.size}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        this.myData = data.rawptr
        this.start = UInt32(data.start)
        this.length = UInt32(data.len)
    }

    // The compiler does not support dispatching the `size` / `iterator` / `toArray` interface members on
    // a `Collection<Rune> @local?` receiver: match on the concrete type for the data; other implementations rely on the caller to convert to Array<Rune> first.
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave init(this @local!, value: Collection<Rune> @local?) {
        match (value) {
            case runes: Array<Rune> =>
                let data = RunesToUtf8Bytes.getBytesLocal(runes)
                if (data.size > Int64(UInt32.Max)) {
                    throw IllegalArgumentException("The size of String is too large.")
                }
                this.myData = data.rawptr
                this.start = UInt32(data.start)
                this.length = UInt32(data.len)
            case _ =>
                let data = RunesToUtf8Bytes.getBytesLocalCollection(value)
                if (data.size > Int64(UInt32.Max)) {
                    throw IllegalArgumentException("The size of String is too large.")
                }
                this.myData = data.rawptr
                this.start = UInt32(data.start)
                this.length = UInt32(data.len)
        }
    }

    @Frozen
    init(value: RawArray<UInt8>) {
        let len = arraySize(value)
        if (len > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${len}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        (myData, start, length) = (value, 0u32, UInt32(len))
    }

    @When[env != "ohos"]
    @Frozen
    init(this @local!, value: RawArray<UInt8> @local!) {
        exclave {
            let len = arraySize(value)
            if (len > Int64(UInt32.Max)) {
                throw IllegalArgumentException("The size of String is too large.")
            }
            // (myData, start, length) = (value, 0u32, UInt32(len))
            myData = value
            start = 0u32
            length = UInt32(len)
        }
    }

    @Frozen
    init(value: RawArray<UInt8>, start: UInt32, len: UInt32) {
        (this.myData, this.start, this.length) = (value, start, len)
    }

    @When[env != "ohos"]
    public exclave init(this @local!, value: String @local?) {
        let newRawPtr = rawArrayAllocate2<UInt8>(value.size)
        rawArrayInitByValue3<UInt8>(newRawPtr, value.size, 0)
        intrinsicBuiltInCopyTo3<UInt8>(value.myData, newRawPtr, Int64(value.start), 0, Int64(value.length))
        myData = newRawPtr
        start = 0u32
        length = value.length
    }

    @When[env != "ohos"]
    public init(value: String @local?) {
        let newRawPtr = rawArrayAllocate<UInt8>(value.size)
        rawArrayInitByValue3<UInt8>(newRawPtr, value.size, 0)
        intrinsicBuiltInCopyTo3<UInt8>(value.myData, newRawPtr, Int64(value.start), 0, Int64(value.length))
        (this.myData, this.start, this.length) = (newRawPtr, 0u32, value.length)
    }

    @When[env != "ohos"]
    @Frozen
    exclave init(this @local!, value: RawArray<UInt8> @local!, start: UInt32, len: UInt32) {
        myData = value
        this.start = start
        length = len
    }

    @When[env != "ohos"]
    @Frozen
    exclave init(this @local?, value: RawArray<UInt8> @local?, start: UInt32, len: UInt32) {
        (this.myData, this.start, this.length) = (value, start, len)
    }

    /**
     * @throws IllegalMemoryException if memory alloc fails.
     */
    @Frozen
    init(ptr: CPointer<UInt8>, cSize: Int64) {
        if (cSize > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${cSize}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        if (cSize == 0) {
            (myData, start, length) = (EMPTY_UINT8_RAW_ARRAY, 0u32, 0u32)
        } else if (cSize < STRING_C_THRESHOLD) {
            this.myData = rawArrayAllocate<UInt8>(cSize)
            rawArrayInitByValue(this.myData, cSize, 0)
            for (i in 0..cSize) {
                arraySetUnchecked(myData, i, unsafe { ptr.read(i) })
            }
            this.start = 0
            this.length = UInt32(cSize)
        } else {
            this.myData = rawArrayAllocate<UInt8>(cSize)
            rawArrayInitByValue(this.myData, cSize, 0)
            unsafe {
                let itemP: CPointer<UInt8> = acquireRawData(myData)
                memcpy_s(itemP, UIntNative(cSize), ptr, UIntNative(cSize))
                releaseRawData(myData, itemP)
            }
            this.start = 0
            this.length = UInt32(cSize)
        }
    }

    @When[env != "ohos"]
    @Frozen
    exclave init(this @local!, ptr: CPointer<UInt8>, cSize: Int64) {
        if (cSize > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        if (cSize == 0) {
            myData = rawArrayAllocate2<UInt8>(0)
            start = 0
            length = 0
        } else if (cSize < STRING_C_THRESHOLD) {
            this.myData = rawArrayAllocate2<UInt8>(cSize)
            rawArrayInitByValue2(this.myData, cSize, 0)
            for (i in 0..cSize) {
                arraySetUnchecked2(myData, i, unsafe { ptr.read(i) })
            }
            this.start = 0
            this.length = UInt32(cSize)
        } else {
            this.myData = rawArrayAllocate2<UInt8>(cSize)
            rawArrayInitByValue2(this.myData, cSize, 0)
            unsafe {
                let itemP: CPointer<UInt8> = acquireRawData2(myData)
                memcpy_s(itemP, UIntNative(cSize), ptr, UIntNative(cSize))
                releaseRawData2<UInt8>(myData, itemP)
            }
            this.start = 0
            this.length = UInt32(cSize)
        }
    }

    /**
     * Create a local String by copying a null-terminated C string via memcpy.
     * @throws IllegalArgumentException if the C string length exceeds UInt32.Max.
     */
    @Frozen
    @When[env != "ohos"]
    public exclave init(this @local!, ptr: CPointer<UInt8>) {
        let cSize = if (ptr.isNull()) {
            0
        } else {
            unsafe { Int64(strlen(ptr)) }
        }
        if (cSize > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        if (cSize == 0) {
            myData = rawArrayAllocate2<UInt8>(0)
            start = 0
            length = 0
        } else {
            myData = rawArrayAllocate2<UInt8>(cSize)
            unsafe {
                let itemP: CPointer<UInt8> = acquireRawData2(myData)
                memcpy_s(itemP, UIntNative(cSize), ptr, UIntNative(cSize))
                releaseRawData2<UInt8>(myData, itemP)
            }
            start = 0
            length = UInt32(cSize)
        }
    }

    @Frozen
    init(value: Array<UInt8>) {
        if (value.len > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${value.len}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        (myData, start, length) = (value.rawptr, UInt32(value.start), UInt32(value.len))
    }

    @When[env != "ohos"]
    @Frozen
    init(this @local!, value: Array<UInt8> @local!) {
        exclave {
            if (value.len > Int64(UInt32.Max)) {
                throw IllegalArgumentException("The size of String is too large.")
            }
            myData = value.rawptr
            start = UInt32(value.start)
            length = UInt32(value.len)
        }
    }

    @When[env != "ohos"]
    @Frozen
    exclave init(this @local?, value: Array<UInt8> @local?) {
        if (value.len > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        myData = value.rawptr
        start = UInt32(value.start)
        length = UInt32(value.len)
    }

    // Returns the byte at the specified index.
    @Frozen
    @OverflowWrapping
    public func get(index: Int64): Option<Byte> {
        if (UInt64(index) >= UInt64(length)) {
            return None
        }
        return arrayGetUnchecked(this.myData, Int64(this.start) + index)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public func get(this @local?, index: Int64): Option<Byte> {
        if (UInt64(index) >= UInt64(length)) {
            return None<Byte>
        }
        Some<Byte>(arrayGetUnchecked3<Byte>(this.myData, Int64(this.start) + index))
    }
    @Frozen
    @OverflowWrapping
    internal func acquireRaw(): CPointer<UInt8> {
        unsafe { acquireRawData<UInt8>(this.myData) + Int64(this.start) }
    }

    @Frozen
    @OverflowWrapping
    internal func releaseRaw(ptr: CPointer<UInt8>): Unit {
        unsafe { releaseRawData<UInt8>(this.myData, ptr - Int64(start)) }
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    internal func acquireRaw(this @local?): CPointer<UInt8> {
        unsafe { acquireRawData2<UInt8>(this.myData) + Int64(this.start) }
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    internal func releaseRaw(this @local?, ptr: CPointer<UInt8>): Unit {
        unsafe { releaseRawData2<UInt8>(this.myData, ptr - Int64(start)) }
    }

    /**
     * Returns the sequence of characters in this string in the form of an array of characters.
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array `this.myData`.
     */
    @Frozen
    @OverflowWrapping
    public func toRuneArray(): Array<Rune> {
        let runeSize = utf8RuneSize(myData, Int64(start), Int64(length))
        let runes: Array<Rune> = Array<Rune>(runeSize, repeat: unsafe { zeroValue<Rune>() })
        var i: Int64 = Int64(start)
        var end: Int64 = Int64(start) + Int64(length)
        var j: Int64 = 0
        var utf8Size: Int64 = 0
        while (i < end) {
            (runes[j], utf8Size) = Rune.fromUtf8(myData, i, end)
            i = i + utf8Size
            j++
        }
        return runes
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func toRuneArray(this @local!): Array<Rune> @local! {
        var runeSize: Int64 = 0
        for (i in Int64(length) - 1..=0 : -1) {
            if ((arrayGetUnchecked2<UInt8>(myData, Int64(start) + i) & 0xC0) != 0x80) {
                runeSize++
            }
        }
        let runes: Array<Rune> @local! = Array<Rune>(runeSize, repeat: unsafe { zeroValue2<Rune>() })
        var i: Int64 = Int64(start)
        var end: Int64 = Int64(start) + Int64(length)
        var j: Int64 = 0
        var utf8Size: Int64 = 0
        while (i < end) {
            let (r, sz): (Rune, Int64) = Rune.fromUtf8(myData, i, end)
            arraySet2<Rune>(runes.rawptr, j, r)
            i = i + sz
            j++
        }
        runes
    }

    @Frozen
    public func toArray(): Array<Byte> {
        let newRawPtr = rawArrayAllocate<UInt8>(this.size)
        rawArrayInitByValue(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo<Byte>(this.myData, newRawPtr, Int64(this.start), 0, Int64(length))
        return Array<Byte>(newRawPtr, 0, size)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func toArray(this @local!): Array<Byte> @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue2(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo2<Byte>(this.myData, newRawPtr, Int64(this.start), 0, Int64(length))
        return Array<Byte>(newRawPtr, 0, size)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func toArray(this @local?): Array<Byte> @local? {
        let newRawPtr = rawArrayAllocate3<UInt8>(Int64(length))
        rawArrayInitByValue3<UInt8>(newRawPtr, Int64(length), 0)
        intrinsicBuiltInCopyTo3<Byte>(this.myData, newRawPtr, Int64(this.start), 0, Int64(length))
        return Array<Byte>(newRawPtr, 0, Int64(length))
    }

    @Frozen
    public func toString(): String {
        return this
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue3<UInt8>(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo3<UInt8>(this.myData, newRawPtr, Int64(this.start), 0, Int64(this.length))
        String(newRawPtr, 0, this.length)
    }

    @When[env != "ohos"]
    internal exclave func toLocal(): String @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue3<UInt8>(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo3<UInt8>(this.myData, newRawPtr, Int64(start), 0, Int64(length))
        return String(newRawPtr, 0, length)
    }


    @Frozen
    public func iterator(): Iterator<Byte> {
        return StringByteIterator(StringIteratorData(unsafe { rawData() }))
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func iterator(this @local!): Iterator<Byte> @local! {
        return StringByteIterator(StringIteratorData(unsafe { rawData() }) @local!) @local!
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func iterator(this @local?): Iterator<Byte> @local? {
        return StringByteIterator(StringIteratorData(unsafe { rawData() }) @local?) @local?
    }

    @Frozen
    public func runes(): Iterator<Rune> {
        return StringRuneIterator(StringIteratorData(unsafe { rawData() }))
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func runes(this @local!): Iterator<Rune> @local! {
        return StringRuneIterator(StringIteratorData(unsafe { rawData() }) @local!) @local!
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func runes(this @local?): Iterator<Rune> @local? {
        return StringRuneIterator(StringIteratorData(unsafe { rawData() }) @local?) @local?
    }

    @Frozen
    public func lines(): Iterator<String> {
        return StringLineIterator(StringIteratorData(unsafe { rawData() }))
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func lines(this @local!): Iterator<String> @local! {
        return StringLineIterator(StringIteratorData(unsafe { rawData() }) @local!) @local!
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func lines(this @local?): Iterator<String> @local? {
        return StringLineIterator(StringIteratorData(unsafe { rawData() }) @local?) @local?
    }

    // Returns the byte counts of this string.
    @Frozen
    public prop size: Int64 {
        get() {
            Int64(length)
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop size: Int64 @local? {
        get() {
            Int64(length)
        }
    }

    // Returns true if and only if this string is an empty string.
    @Frozen
    public func isEmpty(): Bool {
        return length == 0
    }

    // Returns true if and only if this string is an empty string.
    @Frozen
    @When[env != "ohos"]
    public func isEmpty(this @local?): Bool {
        return length == 0
    }

    /**
     * Determine if the string is an Ascii string,
     * return true if there are no characters other than Ascii in the string,
     * return true if the string is empty.
     */
    @Frozen
    public func isAscii(): Bool {
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in size - 1..=0 : -1) {
            let b = arrayGetUnchecked(this.myData, Int64(start) + i)
            // ascii rune's most significant bit (MSB) is zero
            if ((b >> 7) == 1) {
                return false
            }
        }
        return true
    }

    @Frozen
    @When[env != "ohos"]
    public func isAscii(this @local?): Bool {
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        let b: Int64 = size
        for (i in b - 1..=0 : -1) {
            let b = arrayGetUnchecked3<UInt8>(this.myData, Int64(start) + i)
            // ascii rune's most significant bit (MSB) is zero
            if ((b >> 7) == 1) {
                return false
            }
        }
        return true
    }

    @Frozen
    public func isAsciiBlank(): Bool {
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in size - 1..=0 : -1) {
            if (!arrayGetUnchecked(this.myData, Int64(start) + i).isAsciiWhiteSpace()) {
                return false
            }
        }
        return true
    }
    @Frozen
    @When[env != "ohos"]
    public func isAsciiBlank(this @local?): Bool {
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in size - 1..=0 : -1) {
            if (!arrayGetUnchecked3<UInt8>(this.myData, Int64(start) + i).isAsciiWhiteSpace()) {
                return false
            }
        }
        true
    }

    @Frozen
    public func clone(): String {
        let newRawPtr = rawArrayAllocate<UInt8>(this.size)
        rawArrayInitByValue(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo<UInt8>(this.myData, newRawPtr, Int64(start), 0, Int64(length))
        return String(newRawPtr, 0, length)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func clone(this @local!): String @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue2(newRawPtr, this.size, 0)
        intrinsicBuiltInCopyTo2<UInt8>(this.myData, newRawPtr, Int64(start), 0, Int64(length))
        String(newRawPtr, 0, length)
    }

    /**
     * Use wyhash to generate a hash value for a string.
     */
    @Frozen
    @OverflowWrapping
    public func hashCode(): Int64 {
        return Int64(wyhash(myData, Int64(start), Int64(length), 0))
    }


    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func hashCode(this @local!): Int64 {
        Int64(wyhash(myData, Int64(start), Int64(length), 0))
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public func hashCode(this @local?): Int64 {
        Int64(wyhash(myData, Int64(start), Int64(length), 0))
    }

    /**
     * Construct a string from a utf8-compliant bytecode sequence
     * @Param utf8Data - UTF8 bytecode sequence
     * @throws IllegalArgumentException If the array is an invalid UTF8 sequence
     * @return a String
     */
    @Frozen
    public static func fromUtf8(utf8Data: Array<UInt8>): String {
        checkInvalid(utf8Data.rawptr, utf8Data.start, utf8Data.start + utf8Data.size)
        return String(utf8Data.clone())
    }
    @Frozen
    @When[env != "ohos"]
    public exclave static func fromUtf8(utf8Data: Array<UInt8> @local!): String @local! {
        checkInvalid(utf8Data.rawptr, utf8Data.start, utf8Data.start + utf8Data.size)
        return String(utf8Data.clone())
    }
    @Frozen
    @When[env != "ohos"]
    public exclave static func fromUtf8(utf8Data: Array<UInt8> @local?): String @local! {
        checkInvalid(utf8Data.rawptr, utf8Data.start, utf8Data.start + utf8Data.size)
        let ret: Array<UInt8> @local! = utf8Data.cloneToLocal()
        String(ret)
    }

    @Frozen
    public unsafe func rawData(): Array<Byte> {
        return Array<Byte>(myData, Int64(start), Int64(length))
    }

    @Frozen
    public unsafe static func fromUtf8Unchecked(utf8Data: Array<UInt8>): String {
        return String(utf8Data.clone())
    }

    @Frozen
    @When[env != "ohos"]
    public exclave unsafe func rawData(this @local!): Array<Byte> @local! {
        Array<Byte>(myData, Int64(start), Int64(length))
    }

    @Frozen
    @When[env != "ohos"]
    public exclave unsafe func rawData(this @local?): Array<Byte> @local? {
        Array<Byte>(myData, Int64(start), Int64(length))
    }

    @Frozen
    @When[env != "ohos"]
    public exclave unsafe static func fromUtf8Unchecked(utf8Data: Array<UInt8> @local!): String @local! {
        // `fromUtf8Unchecked` keeps its copy semantics for every receiver mode: the caller may
        // still hold and mutate `utf8Data` after this returns (verified: adopting the array made
        // an existing string change when the buffer was rewritten). Use `withRawData` when the
        // no-copy contract is what you want.
        let ret: Array<UInt8> @local! = utf8Data.cloneToLocal()
        String(ret)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave unsafe static func fromUtf8Unchecked(utf8Data: Array<UInt8> @local?): String @local! {
        let ret: Array<UInt8> @local! = utf8Data.cloneToLocal()
        String(ret)
    }
    // Returns the index of the first occurrence of the specified byte.
    // Return `Option<Int64>.None` if the specified byte is absent.
    @Frozen
    public func indexOf(b: Byte): Option<Int64> {
        return match (indexOfImpl(b, 0)) {
            case -1 => None
            case val => Some(val)
        }
    }
    // The vectorIndexByte32 intrinsic has no @local? form; the @local? indexOf degrades to a byte-by-byte scan.
    @Frozen
    @When[env != "ohos"]
    public func indexOf(this @local?, b: Byte): Option<Int64> {
        var i: Int64 = 0
        while (i < size) {
            if (arrayGetUnchecked3<UInt8>(this.myData, Int64(this.start) + i) == b) {
                return Some<Int64>(i)
            }
            i = i + 1
        }
        return None<Int64>
    }

    // Returns the index of the first occurrence of the specified byte at or after the specified index.
    // Returns `Option<Int64>.None` if the specified byte is absent at or after the specified index.
    @Frozen
    public func indexOf(b: Byte, fromIndex: Int64): Option<Int64> {
        if (fromIndex >= size) {
            return None
        }
        let start = if (fromIndex < 0) { 0 } else { fromIndex }
        return match (indexOfImpl(b, start)) {
            case -1 => None
            case val => Some(val)
        }
    }

    // The parameter `fromIndex` should be [0..size) and will not be checked
    // Returns -1 if the specified byte is absent
    @Frozen
    private func indexOfImpl(b: Byte, fromIndex: Int64): Int64 {
        return if (IS_SIMD_SUPPORTED) {
            indexOfFast(b, fromIndex)
        } else {
            indexOfCommon(b, fromIndex)
        }
    }

    @Frozen
    @OverflowWrapping
    private func indexOfCommon(b: Byte, fromIndex: Int64): Int64 {
        for (i in fromIndex..size) {
            if (arrayGetUnchecked(this.myData, Int64(start) + i) == b) {
                return i
            }
        }
        return -1
    }

    @Frozen
    @OverflowWrapping
    private func indexOfFast(b: Byte, fromIndex: Int64): Int64 {
        var i = fromIndex
        let rawptr = this.myData
        var begin = Int64(this.start) + i
        while (i + VECTOR_OFFSET_32 <= size) {
            let vecCmpRes: Int64 = vectorIndexByte32(rawptr, begin, b)
            // when any position byte is matched, return a value different from 32
            if (vecCmpRes != 32) {
                return i + vecCmpRes
            }
            i += VECTOR_OFFSET_32
            begin += VECTOR_OFFSET_32
        }

        for (j in i..size) {
            if (arrayGetUnchecked(this.myData, Int64(this.start) + j) == b) {
                return j
            }
        }
        return -1
    }

    // Returns the index of the first occurrence of the specified substring `str`.
    // Return `Option<Int64>.None` if `str` is absent.
    @Frozen
    public func indexOf(str: String): Option<Int64> {
        if (str.isEmpty()) {
            return Option<Int64>.Some(0)
        }
        if (str.size == 1) {
            return indexOf(arrayGetUnchecked(str.myData, Int64(str.start)))
        }
        var index: Int64 = indexOfString(str)
        if (index < 0) {
            return Option<Int64>.None
        }
        return Option<Int64>.Some(index)
    }

    // Returns the index of the first occurrence of the specified substring `str` at or after the specified index.
    // Return `Option<Int64>.None` if the specified string is absent at or after the specified index.
    @Frozen
    public func indexOf(str: String, fromIndex: Int64): Option<Int64> {
        if (str.length == 0) {
            if (fromIndex < 0) {
                return Option<Int64>.Some(0)
            } else if (fromIndex > size) {
                return Option<Int64>.None
            } else {
                return Option<Int64>.Some(fromIndex)
            }
        }
        if (str.size == 1) {
            return indexOf(arrayGetUnchecked(str.myData, Int64(str.start)), fromIndex)
        }
        if (fromIndex < 0) {
            return this.indexOf(str)
        } else if (fromIndex >= size) {
            return Option<Int64>.None
        }
        var index: Int64 = indexOfString(str, startIndex: fromIndex)
        if (index < 0) {
            return Option<Int64>.None
        }
        return Option<Int64>.Some(index)
    }

    // Reuses the same native search core as the plain overload: borrowing the backing storage through
    // `acquireRaw` keeps the view origin and length without copying, and `CJ_CORE_IndexOfString` uses
    // FastStrstr or a rolling hash instead of restarting the match at every position. The previous
    // byte-by-byte loop was O(n*m) on inputs sharing a long prefix (measured: 14.40 ms plain vs
    // 1106.91 ms for the identical heap string bound as `@local?`).
    @Frozen
    @When[env != "ohos"]
    public func indexOf(this @local?, str: String @local?): Option<Int64> {
        if (str.size == 0) {
            return Some<Int64>(0)
        }
        if (this.size < str.size) {
            return None<Int64>
        }
        var index: Int64 = -1
        unsafe {
            let org: CPointer<UInt8> = this.acquireRaw()
            let pat: CPointer<UInt8> = str.acquireRaw()
            index = CJ_CORE_IndexOfString(org, pat, this.size, str.size, 0)
            this.releaseRaw(org)
            str.releaseRaw(pat)
        }
        if (index < 0) {
            return None<Int64>
        }
        Some<Int64>(index)
    }

    // Returns the index of the last occurrence of the specified byte.
    // Return `Option<Int64>.None` if specified byte is absent.
    @Frozen
    public func lastIndexOf(b: Byte): Option<Int64> {
        return lastIndexOf(b, 0)
    }

    // Returns the index of the last occurrence of the specified byte at or after the specified index.
    // Return `Option<Int64>.None` if specified byte is absent at or after the specified index.
    @Frozen
    @OverflowWrapping
    public func lastIndexOf(b: Byte, fromIndex: Int64): Option<Int64> {
        if (fromIndex < 0) {
            return lastIndexOf(b, 0)
        } else if (fromIndex >= size) {
            return None
        }
        for (i in size - 1..=fromIndex : -1) {
            if (arrayGetUnchecked(myData, Int64(start) + i) == b) {
                return i
            }
        }
        return None
    }

    // Returns the index of the last occurrence of the specified substring `str`.
    // Return `Option<Int64>.None` if specified substring is absent.
    @Frozen
    public func lastIndexOf(str: String): Option<Int64> {
        if (str.isEmpty()) {
            return Option<Int64>.Some(size)
        }
        var index: Int64 = indexOfString(str, fromLast: true)
        if (index < 0) {
            return Option<Int64>.None
        }
        return Option<Int64>.Some(index)
    }

    // Returns the index of the last occurrence of the specified substring `str` at or after the specified index.
    // Return `Option<Int64>.None` if specified substring is absent at or after the specified index.
    // Search last substring from the beginning when 'fromIndex' is less than 0.
    @Frozen
    public func lastIndexOf(str: String, fromIndex: Int64): Option<Int64> {
        if (str.isEmpty()) {
            if (fromIndex > size) {
                return Option<Int64>.None
            } else {
                return Option<Int64>.Some(size)
            }
        }
        if (fromIndex < 0) {
            return this.lastIndexOf(str)
        } else if (fromIndex >= size) {
            return Option<Int64>.None
        }
        var index: Int64 = indexOfString(str, startIndex: fromIndex, fromLast: true)
        if (index < 0) {
            return Option<Int64>.None
        }
        return Option<Int64>.Some(index)
    }

    // Returns the number of non-overlapping occurrences of the given substring `str` in the string.
    // If `str` is an empty string, returns the number of Unicode code points in this string + 1.
    @Frozen
    @OverflowWrapping
    public func count(str: String): Int64 {
        if (str.length == 0) {
            return utf8RuneSize(myData, Int64(start), Int64(length)) + 1
        }
        unsafe {
            var ptr1: CPointer<UInt8> = this.acquireRaw()
            var ptr2: CPointer<UInt8> = str.acquireRaw()
            var res: Int64 = CJ_CORE_CountString(ptr1, ptr2, size, str.size)
            this.releaseRaw(ptr1)
            str.releaseRaw(ptr2)
            return res
        }
    }

    /**
     * @return an array of strings which are the result of separating this string using the specified
     *         separator. If the separator is not empty and is absent in this string, returns an array
     *         which only contains this string. If the separator is empty, split after each character.
     *         If both this string and separator are empty, returns an empty array.
     * @throws OutOfMemoryError if failed to call `this.splitOfString`.
     */
    @Frozen
    public func split(str: String, removeEmpty!: Bool = false): Array<String> {
        if (size == 0) {
            return EMPTY_STRING_ARRAY
        }
        return this.splitOfString(str, -1, removeEmpty)
    }

    // Count segments before allocating the result array; slices share the source buffer.
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func split(this @local!, str: String @local?, removeEmpty!: Bool = false): Array<String> @local! {
        if (size == 0) {
            return Array<String>()
        }
        let strLen: Int64 = str.size
        var i: Int64 = 0
        if (strLen == 0) {
            // Split at UTF-8 rune boundaries when the separator is empty.
            var count: Int64 = 0
            let runeEnd: Int64 = Int64(start) + Int64(length)
            i = 0
            while (i < size) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, Int64(start) + i, runeEnd)
                count++
                i = i + num
            }
            let ret: Array<String> @local! = Array<String>(count, repeat: unsafe { String() @local! })
            var idx: Int64 = 0
            i = 0
            while (i < size) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, Int64(start) + i, runeEnd)
                ret[idx] = String(myData, start + UInt32(i), UInt32(num)) @local!
                idx++
                i = i + num
            }
            return ret
        }
        // Count segments, including empty ones unless removeEmpty is set.
        var segCount: Int64 = 0
        var segStart: Int64 = 0
        i = 0
        while (i <= size - strLen) {
            var matched: Bool = true
            var j: Int64 = 0
            while (j < strLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(str.myData, Int64(str.start) + j)) {
                    matched = false
                    break
                }
                j = j + 1
            }
            if (matched) {
                let segLen = i - segStart
                if (!removeEmpty || segLen > 0) {
                    segCount++
                }
                i = i + strLen
                segStart = i
            } else {
                i = i + 1
            }
        }
        let tailLen = size - segStart
        if (!removeEmpty || tailLen > 0) {
            segCount++
        }
        // Use the same empty-segment rule as the counting pass.
        let ret: Array<String> @local! = Array<String>(segCount, repeat: unsafe { String() @local! })
        segStart = 0
        var fillIdx: Int64 = 0
        i = 0
        while (i <= size - strLen) {
            var matched: Bool = true
            var j: Int64 = 0
            while (j < strLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(str.myData, Int64(str.start) + j)) {
                    matched = false
                    break
                }
                j = j + 1
            }
            if (matched) {
                let segLen = i - segStart
                if (!removeEmpty || segLen > 0) {
                    ret[fillIdx] = String(myData, start + UInt32(segStart), UInt32(segLen)) @local!
                    fillIdx++
                }
                i = i + strLen
                segStart = i
            } else {
                i = i + 1
            }
        }
        let tailLen2 = size - segStart
        if (!removeEmpty || tailLen2 > 0) {
            ret[fillIdx] = String(myData, start + UInt32(segStart), UInt32(tailLen2)) @local!
        }
        ret
    }

    /**
     * @return an array of strings which are the result of separating this string using the specified
     *         separator with maximum split number `maxSplits`.
     * @throws OutOfMemoryError if failed to call `this.splitOfString`.
     */
    @Frozen
    public func split(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Array<String> {
        if (size == 0 || maxSplits == 0) {
            return EMPTY_STRING_ARRAY
        }
        return this.splitOfString(str, maxSplits, removeEmpty)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func split(this @local!, str: String @local?, maxSplits: Int64, removeEmpty!: Bool = false): Array<String> @local! {
        if (size == 0 || maxSplits == 0) {
            return Array<String>()
        }
        let strLen: Int64 = str.size
        var i: Int64 = 0
        let unlimited: Bool = maxSplits < 0
        let emptyLimit: Int64 = if (!unlimited && maxSplits < size) { maxSplits } else { size }
        if (strLen == 0) {
            var count: Int64 = 0
            let runeEnd: Int64 = Int64(start) + Int64(length)
            i = 0
            while (i < size) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, Int64(start) + i, runeEnd)
                count++
                i = i + num
            }
            let segTotal: Int64 = if (count < emptyLimit) { count } else { emptyLimit }
            let ret: Array<String> @local! = Array<String>(segTotal, repeat: unsafe { String() @local! })
            var idx: Int64 = 0
            i = 0
            while (i < size && idx < segTotal) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, Int64(start) + i, runeEnd)
                if (idx == segTotal - 1) {
                    ret[idx] = String(myData, start + UInt32(i), UInt32(size - i)) @local!
                    idx++
                    break
                }
                ret[idx] = String(myData, start + UInt32(i), UInt32(num)) @local!
                idx++
                i = i + num
            }
            return ret
        }
        var segCount: Int64 = 0
        var segStart: Int64 = 0
        i = 0
        while (i <= size - strLen) {
            var matched: Bool = true
            var j: Int64 = 0
            while (j < strLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(str.myData, Int64(str.start) + j)) {
                    matched = false
                    break
                }
                j = j + 1
            }
            if (matched) {
                let segLen = i - segStart
                if (!removeEmpty || segLen > 0) {
                    segCount++
                }
                i = i + strLen
                segStart = i
            } else {
                i = i + 1
            }
        }
        let tailLen = size - segStart
        if (!removeEmpty || tailLen > 0) {
            segCount++
        }
        // The limit counts retained segments, so empty segments do not consume it.
        let resultCount = if (!unlimited && maxSplits < segCount) { maxSplits } else { segCount }
        let ret: Array<String> @local! = Array<String>(resultCount, repeat: unsafe { String() @local! })
        if (resultCount == 0) {
            return ret
        }
        if (maxSplits == 1) {
            ret[0] = String(myData, start, length) @local!
            return ret
        }
        segStart = 0
        var fillIdx: Int64 = 0
        i = 0
        while (i <= size - strLen) {
            var matched: Bool = true
            var j: Int64 = 0
            while (j < strLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(str.myData, Int64(str.start) + j)) {
                    matched = false
                    break
                }
                j = j + 1
            }
            if (matched) {
                let segLen = i - segStart
                if (!removeEmpty || segLen > 0) {
                    let itemLen = if (fillIdx == resultCount - 1 && segCount > resultCount) {
                        size - segStart
                    } else {
                        segLen
                    }
                    ret[fillIdx] = String(myData, start + UInt32(segStart), UInt32(itemLen)) @local!
                    fillIdx++
                    if (fillIdx == resultCount) {
                        return ret
                    }
                }
                i = i + strLen
                segStart = i
            } else {
                i = i + 1
            }
        }
        let tailLen2 = size - segStart
        if (!removeEmpty || tailLen2 > 0) {
            ret[fillIdx] = String(myData, start + UInt32(segStart), UInt32(tailLen2)) @local!
        }
        ret
    }

    @Frozen
    public func lazySplit(str: String, removeEmpty!: Bool = false): Iterator<String> {
        if (size == 0) {
            return EMPTY_STRING_ARRAY.iterator()
        }
        return StringLazySplitIterator(unsafe { rawData() }, size, str, -1, removeEmpty)
    }

    @Frozen
    public func lazySplit(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Iterator<String> {
        if (size == 0 || maxSplits == 0) {
            return EMPTY_STRING_ARRAY.iterator()
        }
        return StringLazySplitIterator(unsafe { rawData() }, size, str, maxSplits, removeEmpty)
    }

    @Frozen
    public func replace(old: String, new: String): String {
        if (size == 0) {
            if (old.size == 0) {
                return new
            } else {
                return this
            }
        }

        if (old.size == 0) {
            return insertString(new)
        } else {
            return replaceString(old, new)
        }
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func replace(this @local!, old: String @local?, new: String @local?): String @local! {
        let oldLen: Int64 = old.size
        let newLen: Int64 = new.size
        if (size == 0) {
            if (oldLen == 0) {
                return String(new)
            }
            return String() @local!
        }

        var count: Int64 = 0
        var i: Int64 = 0
        if (oldLen == 0) {
            var runeCount: Int64 = 0
            // Scan must start at the view origin: with pos starting at 0 the loop
            // walks the whole backing array up to start+length instead of just this
            // view. That inflates runeCount (so the result length and allocation are
            // sized by the backing array), and can make Rune.fromUtf8 fail when pos
            // lands inside a multi-byte character.
            var pos: Int64 = Int64(start)
            let end: Int64 = Int64(start) + Int64(length)
            while (pos < end) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, pos, end)
                runeCount++
                pos = pos + num
            }

            // Check the multiplication before allocating: with empty `old` the insertion count is
            // runeCount + 1, so a large `new` overflows the byte budget long before the UInt32
            // conversion at the end. Same guard as the plain `insertString`.
            let insertCount: Int64 = runeCount + 1
            let maxSize: Int64 = Int64(UInt32.Max) - size
            if (insertCount > 0 && newLen > maxSize / insertCount) {
                throw IllegalArgumentException("The size of String is too large.")
            }
            let newSize: Int64 = size + newLen * insertCount
            let newRawPtr = rawArrayAllocate2<UInt8>(newSize)
            rawArrayInitByValue2(newRawPtr, newSize, 0)
            var cursor: Int64 = 0
            var j: Int64 = 0
            while (j < newLen) {
                arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked3<UInt8>(new.myData, Int64(new.start) + j))
                j = j + 1
            }
            cursor += newLen
            i = 0
            while (i < size) {
                let (_, num): (Rune, Int64) = Rune.fromUtf8(myData, Int64(start) + i, end)
                j = 0
                while (j < num) {
                    arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j))
                    j = j + 1
                }
                cursor += num
                j = 0
                while (j < newLen) {
                    arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked3<UInt8>(new.myData, Int64(new.start) + j))
                    j = j + 1
                }
                cursor += newLen
                i = i + num
            }
            return String(newRawPtr, 0, UInt32(cursor))
        }

        while (i <= size - oldLen) {
            var matched: Bool = true
            for (j in 0..oldLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(old.myData, Int64(old.start) + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                count++
                i = i + oldLen
            } else {
                i = i + 1
            }
        }
        if (count == 0) {
            let newRawPtr = rawArrayAllocate2<UInt8>(size)
            rawArrayInitByValue2(newRawPtr, size, 0)
            for (j in 0..size) {
                arraySetUnchecked2<UInt8>(newRawPtr, j, arrayGetUnchecked2<UInt8>(myData, Int64(start) + j))
            }
            return String(newRawPtr, 0, length)
        }

        let resultLen: Int64 = size + (newLen - oldLen) * count
        if (resultLen > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        let resultPtr = rawArrayAllocate2<UInt8>(resultLen)
        rawArrayInitByValue2(resultPtr, resultLen, 0)
        var cursor: Int64 = 0
        var srcPos: Int64 = 0
        i = 0
        while (i <= size - oldLen) {
            var matched: Bool = true
            for (j in 0..oldLen) {
                if (arrayGetUnchecked2<UInt8>(myData, Int64(start) + i + j) !=
                    arrayGetUnchecked3<UInt8>(old.myData, Int64(old.start) + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                for (j in 0..(i - srcPos)) {
                    arraySetUnchecked2<UInt8>(resultPtr, cursor + j, arrayGetUnchecked2<UInt8>(myData, Int64(start) + srcPos + j))
                }
                cursor += i - srcPos
                for (j in 0..newLen) {
                    arraySetUnchecked2<UInt8>(resultPtr, cursor + j, arrayGetUnchecked3<UInt8>(new.myData, Int64(new.start) + j))
                }
                cursor += newLen
                i = i + oldLen
                srcPos = i
            } else {
                i = i + 1
            }
        }
        for (j in 0..(size - srcPos)) {
            arraySetUnchecked2<UInt8>(resultPtr, cursor + j, arrayGetUnchecked2<UInt8>(myData, Int64(start) + srcPos + j))
        }
        String(resultPtr, 0, UInt32(resultLen))
    }

    @Frozen
    @OverflowWrapping
    private func insertString(new: String): String {
        let newArr: Array<UInt8> = unsafe { new.rawData() }
        let newSize: Int64 = new.size
        var total: Int64 = this.count("")

        let maxSize = Int64(UInt32.Max) - size
        if (total > 0 && newSize > maxSize / total) {
            throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
        }

        let countSize: Int64 = size + newSize * total
        var itemArray: Array<UInt8> = Array<UInt8>(countSize, repeat: 0)
        var start: Int64 = 0
        var oneSize: Int64 = 0
        var i: Int64 = 0
        itemArray[..newSize] = newArr[..newSize]
        i += newSize
        let data = unsafe { rawData() }
        while (start < size) {
            oneSize = Rune.utf8Size(data, start)
            itemArray[i..(i + oneSize)] = data[start..(start + oneSize)]
            i += oneSize
            itemArray[i..(i + newSize)] = newArr[..newSize]
            i += newSize
            start += oneSize
        }
        return String(itemArray)
    }

    @Frozen
    @OverflowWrapping
    private func replaceString(old: String, new: String): String {
        let oldSize: Int64 = old.size
        let newSize: Int64 = new.size
        var res: CPointer<Int64> = CPointer<Int64>()
        var indexes: CPointer<Int64> = CPointer<Int64>()
        var total: Int64 = 0
        unsafe {
            let org: CPointer<UInt8> = this.acquireRaw()
            let pat: CPointer<UInt8> = old.acquireRaw()
            res = CJ_CORE_CountAndIndexString(org, pat, size, oldSize)
            this.releaseRaw(org)
            old.releaseRaw(pat)
            if (res.isNull()) {
                throw OutOfMemoryError("Failed malloc in C code!")
            }
            total = res.read(0)
            indexes = res + 1
        }
        try {
            if (total == 0) {
                return this
            }

            let diff: Int64 = newSize - oldSize
            let countSize: Int64

            if (diff > 0) {
                let maxSize = Int64(UInt32.Max) - size
                if (diff > maxSize / total) {
                    throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
                }
            }
            countSize = size + diff * total
            var itemArray: Array<UInt8> = Array<UInt8>(countSize, repeat: 0)
            var itemStart: Int64 = 0
            var orgStart: Int64 = 0
            var index: Int64 = 0
            let data = unsafe { this.rawData() }
            let newArr: Array<UInt8> = unsafe { new.rawData() }
            for (i in 0..total) {
                index = unsafe { indexes.read(i) }
                itemArray[itemStart..(itemStart + index - orgStart)] = data[orgStart..index]
                itemStart += index - orgStart
                itemArray[itemStart..(itemStart + newSize)] = newArr
                itemStart += newSize
                orgStart = index + oldSize
            }
            itemArray[itemStart..(itemStart + size - orgStart)] = data[orgStart..]
            return String(itemArray)
        } finally {
            unsafe { LibC.free(res) }
        }
    }

    @Frozen
    @OverflowWrapping
    public func toAsciiLower(): String {
        let newRawPtr = rawArrayAllocate<UInt8>(this.size)
        rawArrayInitByValue(newRawPtr, this.size, 0)
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in Int64(length) - 1..=0 : -1) {
            var c: UInt8 = arrayGetUnchecked(this.myData, i + Int64(start))
            if (ASCII_A <= c && c <= ASCII_Z) {
                arraySetUnchecked(newRawPtr, i, c + ASCII_UPPER_LOWER_DIFFERENCE)
            } else {
                arraySetUnchecked(newRawPtr, i, c)
            }
        }
        return String(newRawPtr, 0, length)
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func toAsciiLower(this @local!): String @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue2(newRawPtr, this.size, 0)
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in Int64(length) - 1..=0 : -1) {
            var c = arrayGetUnchecked2(this.myData, i + Int64(start))
            if (ASCII_A <= c && c <= ASCII_Z) {
                arraySetUnchecked2(newRawPtr, i, c + ASCII_UPPER_LOWER_DIFFERENCE)
            } else {
                arraySetUnchecked2(newRawPtr, i, c)
            }
        }
        String(newRawPtr, 0, length)
    }

    @Frozen
    @OverflowWrapping
    public func toAsciiUpper(): String {
        let newRawPtr = rawArrayAllocate<UInt8>(this.size)
        rawArrayInitByValue(newRawPtr, this.size, 0)
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in Int64(length) - 1..=0 : -1) {
            var c: UInt8 = arrayGetUnchecked(this.myData, i + Int64(start))
            if (ASCII_a <= c && c <= ASCII_z) {
                arraySetUnchecked(newRawPtr, i, c - ASCII_UPPER_LOWER_DIFFERENCE)
            } else {
                arraySetUnchecked(newRawPtr, i, c)
            }
        }
        return String(newRawPtr, 0, length)
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func toAsciiUpper(this @local!): String @local! {
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue2(newRawPtr, this.size, 0)
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in Int64(length) - 1..=0 : -1) {
            var c = arrayGetUnchecked2(this.myData, i + Int64(start))
            if (ASCII_a <= c && c <= ASCII_z) {
                arraySetUnchecked2(newRawPtr, i, c - ASCII_UPPER_LOWER_DIFFERENCE)
            } else {
                arraySetUnchecked2(newRawPtr, i, c)
            }
        }
        String(newRawPtr, 0, length)
    }

    @Frozen
    @OverflowWrapping
    public func toAsciiTitle(): String {
        var i: Int64 = 0
        let newRawPtr = rawArrayAllocate<UInt8>(this.size)
        rawArrayInitByValue(newRawPtr, this.size, 0)
        var next: Bool = true
        while (i < size) {
            var c: UInt8 = arrayGetUnchecked(this.myData, i + Int64(start))
            arraySetUnchecked(newRawPtr, i, c)
            if (ASCII_a <= c && c <= ASCII_z) {
                if (next) {
                    arraySetUnchecked(newRawPtr, i, c - ASCII_UPPER_LOWER_DIFFERENCE)
                    next = false
                }
            } else if (ASCII_A <= c && c <= ASCII_Z) {
                if (!next) {
                    arraySetUnchecked(newRawPtr, i, c + ASCII_UPPER_LOWER_DIFFERENCE)
                } else {
                    next = false
                }
            } else {
                next = true
            }
            i++
        }
        return String(newRawPtr, 0, length)
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func toAsciiTitle(this @local!): String @local! {
        var i: Int64 = 0
        let newRawPtr = rawArrayAllocate2<UInt8>(this.size)
        rawArrayInitByValue2(newRawPtr, this.size, 0)
        var next: Bool = true
        while (i < size) {
            var c = arrayGetUnchecked2(this.myData, i + Int64(start))
            arraySetUnchecked2(newRawPtr, i, c)
            if (ASCII_a <= c && c <= ASCII_z) {
                if (next) {
                    arraySetUnchecked2(newRawPtr, i, c - ASCII_UPPER_LOWER_DIFFERENCE)
                    next = false
                }
            } else if (ASCII_A <= c && c <= ASCII_Z) {
                if (!next) {
                    arraySetUnchecked2(newRawPtr, i, c + ASCII_UPPER_LOWER_DIFFERENCE)
                } else {
                    next = false
                }
            } else {
                next = true
            }
            i++
        }
        String(newRawPtr, 0, length)
    }

    @Frozen
    public func trimAscii(): String {
        this.trimAsciiStart().trimAsciiEnd()
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func trimAscii(this @local!): String @local! {
        trimAsciiStart().trimAsciiEnd()
    }

    @Frozen
    @OverflowWrapping
    public func trimAsciiStart(): String {
        var start: Int64 = 0
        var foundFirst: Bool = false
        for (i in 0..size) {
            if (!arrayGetUnchecked(myData, i + Int64(this.start)).isAsciiWhiteSpace()) {
                start = i
                foundFirst = true
                break
            }
        }
        if (!foundFirst) {
            return String.empty
        }
        String(myData, this.start + UInt32(start), length - UInt32(start))
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func trimAsciiStart(this @local!): String @local! {
        var start: Int64 = 0
        var foundFirst: Bool = false
        for (i in 0..size) {
            if (!arrayGetUnchecked2(myData, i + Int64(this.start)).isAsciiWhiteSpace()) {
                start = i
                foundFirst = true
                break
            }
        }
        if (!foundFirst) {
            return String() @local!
        }
        String(myData, this.start + UInt32(start), length - UInt32(start))
    }

    @Frozen
    @OverflowWrapping
    public func trimAsciiEnd(): String {
        var end: Int64 = size - 1
        var foundLast: Bool = false
        for (i in end..-1 : -1) {
            if (!arrayGetUnchecked(myData, i + Int64(this.start)).isAsciiWhiteSpace()) {
                end = i
                foundLast = true
                break
            }
        }
        if (!foundLast) {
            return String.empty
        }
        String(myData, this.start, UInt32(end) + 1)
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func trimAsciiEnd(this @local!): String @local! {
        var end: Int64 = size - 1
        var foundLast: Bool = false
        for (i in end..-1 : -1) {
            if (!arrayGetUnchecked2(myData, i + Int64(this.start)).isAsciiWhiteSpace()) {
                end = i
                foundLast = true
                break
            }
        }
        if (!foundLast) {
            return String() @local!
        }
        String(myData, this.start, UInt32(end) + 1)
    }

    @Frozen
    @OverflowWrapping
    public func trimStart(set: Array<Rune>): String {
        var start = Int64(this.start)
        let end = start + Int64(this.length)
        var trim = false
        while (start < end) {
            let (rune, utf8Size) = Rune.fromUtf8(myData, start, end)
            for (i in 0..set.size) {
                if (set[i] == rune) {
                    start += utf8Size
                    trim = true
                    break
                }
                trim = false
            }
            if (!trim) {
                return String(myData, UInt32(start), UInt32(end - start))
            }
        }
        return String.empty
    }

    @Frozen
    public func trimEnd(set: Array<Rune>): String {
        String(toRuneArray().trimEnd(set))
    }

    @Frozen
    public func trimStart(set: String): String {
        trimStart(set.toRuneArray())
    }

    @Frozen
    public func trimEnd(set: String): String {
        trimEnd(set.toRuneArray())
    }

    @Frozen
    public func trimStart(predicate: (Rune) -> Bool): String {
        var start = this.start
        var end = start + this.length
        while (start < end) {
            let (rune, utf8Size) = Rune.fromUtf8(myData, Int64(start), Int64(end))
            if (!predicate(rune)) {
                return String(myData, start, end - start)
            }
            start += UInt32(utf8Size)
        }
        return String.empty
    }

    @Frozen
    public func trimEnd(predicate: (Rune) -> Bool): String {
        return String(toRuneArray().trimEnd(predicate))
    }

    @Frozen
    public func removePrefix(prefix: String): String {
        if (this.startsWith(prefix)) {
            return this[prefix.size..]
        }
        return this
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func removePrefix(this @local!, prefix: String @local?): String @local! {
        if (this.startsWith(prefix)) {
            return String(this.myData, this.start + UInt32(prefix.size), this.length - UInt32(prefix.size))
        }
        this
    }

    @Frozen
    public func removeSuffix(suffix: String): String {
        if (this.endsWith(suffix)) {
            return this[0..this.size - suffix.size]
        }
        return this
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func removeSuffix(this @local!, suffix: String @local?): String @local! {
        if (this.endsWith(suffix)) {
            return String(this.myData, this.start, this.length - UInt32(suffix.size))
        }
        this
    }

    @Frozen
    public func contains(str: String): Bool {
        if (str.isEmpty()) {
            return true
        }
        match (this.indexOf(str)) {
            case None => false
            case _ => true
        }
    }
    @Frozen
    @When[env != "ohos"]
    public func contains(this @local?, str: String @local?): Bool {
        // Empty pattern and over-long pattern are already handled by `indexOf`.
        this.indexOf(str).isSome()
    }

    // Returns true if and only if this string starts with the given `prefix`.
    @Frozen
    @OverflowWrapping
    public func startsWith(prefix: String): Bool {
        let strLen: Int64 = prefix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        if (strLen < STRING_C_THRESHOLD) {
            for (i in 0..strLen) {
                if (arrayGetUnchecked(this.myData, Int64(start) + i) !=
                    arrayGetUnchecked(prefix.myData, Int64(prefix.start) + i)) {
                    return false
                }
            }
            return true
        }
        var res: Int64 = 0
        unsafe {
            var handle1: CPointer<UInt8> = acquireRawData<UInt8>(this.myData) + Int64(this.start)
            var handle2: CPointer<UInt8> = acquireRawData<UInt8>(prefix.myData) + Int64(prefix.start)
            res = CJ_CORE_StringMemcmp(handle1, handle2, UIntNative(strLen))
            releaseRawData<UInt8>(this.myData, handle1 - Int64(this.start))
            releaseRawData<UInt8>(prefix.myData, handle2 - Int64(prefix.start))
        }
        return res == 0
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func startsWith(this @local!, prefix: String @local?): Bool {
        let strLen: Int64 = prefix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        compareBytes(this.myData, Int64(this.start), prefix.myData, Int64(prefix.start), strLen) == 0
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public func startsWith(this @local?, prefix: String @local?): Bool {
        let strLen: Int64 = prefix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        compareBytes(this.myData, Int64(this.start), prefix.myData, Int64(prefix.start), strLen) == 0
    }

    // Returns true if and only if this string ends with the given `suffix`.
    @Frozen
    @OverflowWrapping
    public func endsWith(suffix: String): Bool {
        let strLen: Int64 = suffix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        let distance: Int64 = size - strLen
        if (strLen < STRING_C_THRESHOLD) {
            for (i in 0..strLen) {
                if (arrayGetUnchecked(this.myData, Int64(start) + distance + i) !=
                    arrayGetUnchecked(suffix.myData, Int64(suffix.start) + i)) {
                    return false
                }
            }
            return true
        }

        var res: Int64 = 0
        unsafe {
            var handle1: CPointer<UInt8> = acquireRawData<UInt8>(this.myData) + Int64(this.start)
            var handle2: CPointer<UInt8> = acquireRawData<UInt8>(suffix.myData) + Int64(suffix.start)
            res = CJ_CORE_StringMemcmp(handle1 + distance, handle2, UIntNative(strLen))
            releaseRawData<UInt8>(this.myData, handle1 - Int64(this.start))
            releaseRawData<UInt8>(suffix.myData, handle2 - Int64(suffix.start))
        }
        return res == 0
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func endsWith(this @local!, suffix: String @local?): Bool {
        let strLen: Int64 = suffix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        let distance: Int64 = size - strLen
        for (i in 0..strLen) {
            if (arrayGetUnchecked3(this.myData, Int64(start) + distance + i) !=
                arrayGetUnchecked3(suffix.myData, Int64(suffix.start) + i)) {
                return false
            }
        }
        true
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public func endsWith(this @local?, suffix: String @local?): Bool {
        let strLen: Int64 = suffix.size
        if (strLen == 0) {
            return true
        }
        if (size < strLen) {
            return false
        }
        let distance: Int64 = size - strLen
        for (i in 0..strLen) {
            if (arrayGetUnchecked3(this.myData, Int64(start) + distance + i) !=
                arrayGetUnchecked3(suffix.myData, Int64(suffix.start) + i)) {
                return false
            }
        }
        true
    }

    /**
     * @return a new string which is the result of padding zero or more `padding` to this string on the left.
     * @throws IllegalArgumentException if `totalWidth` < 0.
     */
    @Frozen
    public func padStart(totalWidth: Int64, padding!: String = " "): String {
        // Left padding validates width before inspecting the padding bytes.
        if (totalWidth < 0) {
            throw IllegalArgumentException("Invalid argument 'totalWidth': expected a non-negative value, got '${totalWidth}'.")
        }
        if (totalWidth == 0 || this.size > totalWidth) {
            return this
        }
        // Padding length is based on the UTF-8 byte count stored by String.
        let runeLen = padding.size
        // Empty padding cannot advance the prefix fill loop.
        if (runeLen == 0) {
            throw IllegalArgumentException("Padding string cannot be empty.")
        }
        if (totalWidth > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${totalWidth}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        let padLen: Int64 = (totalWidth - this.size + runeLen - 1) / runeLen
        let totalBytes: Int64 = runeLen * padLen + size
        if (totalBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${totalBytes}' exceeds maximum allowed size '${UInt32.Max}'.")
        }

        // padStart reserves the whole result before writing padding and source bytes.
        // Build the prefix padding before appending the receiver bytes.
        var itemBytes: Array<UInt8> = Array<UInt8>(totalBytes, repeat: 0)
        var k: Int64 = 0
        let paddingdata = unsafe { padding.rawData() }
        for (_ in 0..padLen) {
            itemBytes[k..(k + padding.size)] = paddingdata
            k += runeLen
        }
        itemBytes[k..(k + size)] = unsafe { this.rawData() }
        return String(itemBytes)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func padStart(this @local!, totalWidth: Int64, padding!: String @local? = " "): String @local! {
        if (totalWidth < 0) {
            throw IllegalArgumentException("Negative totalWidth.")
        }
        if (totalWidth == 0 || this.size > totalWidth) {
            return this
        }
        let runeLen = padding.size
        if (runeLen == 0) {
            throw IllegalArgumentException("Padding string cannot be empty.")
        }
        if (totalWidth > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        let padLen: Int64 = (totalWidth - this.size + runeLen - 1) / runeLen
        let totalBytes: Int64 = runeLen * padLen + size
        if (totalBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        let newRawPtr = rawArrayAllocate2<UInt8>(totalBytes)
        rawArrayInitByValue2(newRawPtr, totalBytes, 0)
        var k: Int64 = 0
        for (_ in 0..padLen) {
            for (i in 0..runeLen) {
                arraySetUnchecked2<UInt8>(newRawPtr, k + i, arrayGetUnchecked3<UInt8>(padding.myData, Int64(padding.start) + i))
            }
            k += runeLen
        }
        for (i in 0..size) {
            arraySetUnchecked2<UInt8>(newRawPtr, k + i, arrayGetUnchecked3<UInt8>(this.myData, Int64(this.start) + i))
        }
        String(newRawPtr, 0, UInt32(totalBytes))
    }

    /**
     * @return a new string which is the result of padding zero or more `padding` to this string on the right.
     * @throws IllegalArgumentException if `totalWidth` < 0.
     */
    @Frozen
    public func padEnd(totalWidth: Int64, padding!: String = " "): String {
        // Right padding keeps the receiver bytes at the beginning of the result.
        if (totalWidth < 0) {
            throw IllegalArgumentException("Invalid argument 'totalWidth': expected a non-negative value, got '${totalWidth}'.")
        }
        if (totalWidth == 0 || this.size > totalWidth) {
            return this
        }
        // Padding is measured in bytes because String stores UTF-8 data.
        let runeLen = padding.size
        if (runeLen == 0) {
            throw IllegalArgumentException("Padding string cannot be empty.")
        }
        if (totalWidth > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${totalWidth}' exceeds maximum allowed size '${UInt32.Max}'.")
        }
        let padLen: Int64 = (totalWidth - this.size + runeLen - 1) / runeLen
        let totalBytes: Int64 = runeLen * padLen + size
        if (totalBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${totalBytes}' exceeds maximum allowed size '${UInt32.Max}'.")
        }

        // Copy the original bytes first, then append repeated padding bytes.
        var itemBytes: Array<UInt8> = Array<UInt8>(totalBytes, repeat: 0)
        itemBytes[..size] = unsafe { this.rawData() }
        var k: Int64 = size
        let paddingdata = unsafe { padding.rawData() }
        for (_ in 0..padLen) {
            itemBytes[k..(k + padding.size)] = paddingdata
            k += runeLen
        }
        return String(itemBytes)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave func padEnd(this @local!, totalWidth: Int64, padding!: String @local? = " "): String @local! {
        if (totalWidth < 0) {
            throw IllegalArgumentException("Negative totalWidth.")
        }
        if (totalWidth == 0 || this.size > totalWidth) {
            return this
        }
        let runeLen = padding.size
        if (runeLen == 0) {
            throw IllegalArgumentException("Padding string cannot be empty.")
        }
        if (totalWidth > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }
        let padLen: Int64 = (totalWidth - this.size + runeLen - 1) / runeLen
        let totalBytes: Int64 = runeLen * padLen + size
        if (totalBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        let newRawPtr = rawArrayAllocate2<UInt8>(totalBytes)
        rawArrayInitByValue2(newRawPtr, totalBytes, 0)
        var k: Int64 = 0
        for (i in 0..size) {
            arraySetUnchecked2<UInt8>(newRawPtr, k + i, arrayGetUnchecked3<UInt8>(this.myData, Int64(this.start) + i))
        }
        k += size
        for (_ in 0..padLen) {
            for (i in 0..runeLen) {
                arraySetUnchecked2<UInt8>(newRawPtr, k + i, arrayGetUnchecked3<UInt8>(padding.myData, Int64(padding.start) + i))
            }
            k += runeLen
        }
        String(newRawPtr, 0, UInt32(totalBytes))
    }

    @Frozen
    @OverflowWrapping
    public func equalsIgnoreAsciiCase(other: String): Bool {
        if (this.length != other.length) {
            return false
        }
        var idx1 = Int64(this.start)
        var idx2 = Int64(other.start)
        while (idx1 < Int64(this.start + this.length)) {
            let b1 = arrayGetUnchecked(this.myData, idx1)
            let b2 = arrayGetUnchecked(other.myData, idx2)
            if (!byteEqualsIgnoreAsciiCase(b1, b2)) {
                return false
            }
            idx1++
            idx2++
        }
        return true
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public func equalsIgnoreAsciiCase(this @local?, other: String @local?): Bool {
        if (this.length != other.length) {
            return false
        }
        var idx1 = Int64(this.start)
        var idx2 = Int64(other.start)
        while (idx1 < Int64(this.start + this.length)) {
            let b1 = arrayGetUnchecked3<UInt8>(this.myData, idx1)
            let b2 = arrayGetUnchecked3<UInt8>(other.myData, idx2)
            if (!byteEqualsIgnoreAsciiCase(b1, b2)) {
                return false
            }
            idx1++
            idx2++
        }
        true
    }

    @Frozen
    private func byteEqualsIgnoreAsciiCase(b1: Byte, b2: Byte): Bool {
        if (b1 == b2) {
            return true
        }
        // b1 in 'A' ~ 'Z', and the lower case of b1 equals to b2
        if (b1 >= b'A' && b1 <= b'Z' && (b1 + ASCII_UPPER_TO_LOWER_DIFF) == b2) {
            return true
        }
        if (b2 >= b'A' && b2 <= b'Z' && (b2 + ASCII_UPPER_TO_LOWER_DIFF) == b1) {
            return true
        }
        return false
    }
    @When[env != "ohos"]
    @Frozen
    private func byteEqualsIgnoreAsciiCase(this @local?, b1: Byte, b2: Byte): Bool {
        if (b1 == b2) {
            return true
        }
        // b1 in 'A' ~ 'Z', and the lower case of b1 equals to b2
        if (b1 >= b'A' && b1 <= b'Z' && (b1 + ASCII_UPPER_TO_LOWER_DIFF) == b2) {
            return true
        }
        if (b2 >= b'A' && b2 <= b'Z' && (b2 + ASCII_UPPER_TO_LOWER_DIFF) == b1) {
            return true
        }
        return false
    }

    // compare `num` bytes of ptr1[start1..] to ptr2[start2..],
    // returning zero if they are all equal
    // or a positive value representing ptr1[start1..] is greater
    @Frozen
    static const func compareBytes(ptr1: RawArray<Byte>, start1: Int64, ptr2: RawArray<Byte>, start2: Int64, num: Int64): Int64 {
        return if (IS_SIMD_SUPPORTED) {
            compareBytesFast(ptr1, start1, ptr2, start2, num)
        } else {
            compareBytesCommon(ptr1, start1, ptr2, start2, num)
        }
    }

    @Frozen
    @OverflowWrapping
    static const func compareBytesCommon(ptr1: RawArray<Byte>, start1: Int64,
                                    ptr2: RawArray<Byte>, start2: Int64, num: Int64): Int64 {
        var offset1 = start1
        var offset2 = start2
        for (_ in 0..num) {
            let b1 = arrayGetUnchecked(ptr1, offset1)
            let b2 = arrayGetUnchecked(ptr2, offset2)
            if (b1 != b2) {
                return if (b1 > b2) { 1 } else { -1 }
            }
            offset1++
            offset2++
        }
        return 0
    }

    @Frozen
    @OverflowWrapping
    static const func compareBytesFast(ptr1: RawArray<Byte>, start1: Int64,
                                    ptr2: RawArray<Byte>, start2: Int64, num: Int64): Int64 {
        var i = 0
        var offset1 = start1
        var offset2 = start2
        while (i + VECTOR_OFFSET_32 <= num) {
            let vecCmpRes: Int64 = vectorCompare32(ptr1, offset1, ptr2, offset2)
            // If any byte is not matched, return a value different from 32
            if (vecCmpRes != 32) {
                let b1 = arrayGetUnchecked(ptr1, offset1 + vecCmpRes)
                let b2 = arrayGetUnchecked(ptr2, offset2 + vecCmpRes)
                return if (b1 > b2) { 1 } else { -1 }
            }
            i += VECTOR_OFFSET_32
            offset1 += VECTOR_OFFSET_32
            offset2 += VECTOR_OFFSET_32
        }

        for (_ in i..num) {
            let b1 = arrayGetUnchecked(ptr1, offset1)
            let b2 = arrayGetUnchecked(ptr2, offset2)
            if (b2 != b1) {
                return if (b1 > b2) { 1 } else { -1 }
            }
            offset1++
            offset2++
        }
        return 0
    }

    // compare `num` bytes of ptr1[start1..] to ptr2[start2..],
    // returning zero if they are all equal
    // or a positive value representing ptr1[start1..] is greater
    @Frozen
    static const func compareBytes(ptr1: RawArray<Byte> @local?, start1: Int64, ptr2: RawArray<Byte> @local?, start2: Int64, num: Int64): Int64 {
        return if (IS_SIMD_SUPPORTED) {
            compareBytesFast(ptr1, start1, ptr2, start2, num)
        } else {
            compareBytesCommon(ptr1, start1, ptr2, start2, num)
        }
    }

    @Frozen
    @OverflowWrapping
    static const func compareBytesCommon(ptr1: RawArray<Byte> @local?, start1: Int64,
                                    ptr2: RawArray<Byte> @local?, start2: Int64, num: Int64): Int64 {
        var offset1 = start1
        var offset2 = start2
        for (_ in 0..num) {
            let b1 = arrayGetUnchecked3<Byte>(ptr1, offset1)
            let b2 = arrayGetUnchecked3<Byte>(ptr2, offset2)
            if (b1 != b2) {
                return if (b1 > b2) { 1 } else { -1 }
            }
            offset1++
            offset2++
        }
        return 0
    }

    @Frozen
    @OverflowWrapping
    static const func compareBytesFast(ptr1: RawArray<Byte> @local?, start1: Int64,
                                    ptr2: RawArray<Byte> @local?, start2: Int64, num: Int64): Int64 {
        var i = 0
        var offset1 = start1
        var offset2 = start2
        while (i + VECTOR_OFFSET_32 <= num) {
            let vecCmpRes: Int64 = vectorCompare32(ptr1, offset1, ptr2, offset2)
            // If any byte is not matched, return a value different from 32
            if (vecCmpRes != 32) {
                let b1 = arrayGetUnchecked3<Byte>(ptr1, offset1 + vecCmpRes)
                let b2 = arrayGetUnchecked3<Byte>(ptr2, offset2 + vecCmpRes)
                return if (b1 > b2) { 1 } else { -1 }
            }
            i += VECTOR_OFFSET_32
            offset1 += VECTOR_OFFSET_32
            offset2 += VECTOR_OFFSET_32
        }

        for (_ in i..num) {
            let b1 = arrayGetUnchecked3<Byte>(ptr1, offset1)
            let b2 = arrayGetUnchecked3<Byte>(ptr2, offset2)
            if (b2 != b1) {
                return if (b1 > b2) { 1 } else { -1 }
            }
            offset1++
            offset2++
        }
        return 0
    }

    /**
     * Compare the relationship between two instance of String, lexically byte-wise.
     *
     * @param str Instance of String compared with this.
     * @return Value indicating the relationship between two instance of String.
     *
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array `arr1` or `arr2`.
     *
     * @since 0.27.3
     */
    @Frozen
    public func compare(str: String): Ordering {
        var minSize: Int64 = if (this.size < str.size) {
            this.size
        } else {
            str.size
        }

        let res = compareBytes(this.myData, Int64(this.start), str.myData, Int64(str.start), minSize)

        if (res > 0) {
            return Ordering.GT
        } else if (res < 0) {
            return Ordering.LT
        }

        if (this.size > minSize) {
            return Ordering.GT
        } else if (str.size > minSize) {
            return Ordering.LT
        }

        return Ordering.EQ
    }

    @Frozen
    @When[env != "ohos"]
    public func compare(this @local?, str: String @local?): Ordering {
        let minSize: Int64 = if (this.size < str.size) {
            this.size
        } else {
            str.size
        }

        let res = compareBytes(this.myData, Int64(this.start), str.myData, Int64(str.start), minSize)

        if (res > 0) {
            return Ordering.GT
        } else if (res < 0) {
            return Ordering.LT
        }

        if (this.size > minSize) {
            return Ordering.GT
        } else if (str.size > minSize) {
            return Ordering.LT
        }

        return Ordering.EQ
    }

    // Return a string which is the result of concatenating `left` and `right`.
    @Frozen
    @OverflowWrapping
    public operator const func +(other: String): String {
        let newLen = this.size + other.size
        if (newLen > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${newLen}' exceeds maximum allowed size '${UInt32.Max}'.")
        }

        let newData = rawArrayAllocate<Byte>(newLen)
        rawArrayInitByValue(newData, newLen, 0)
        intrinsicBuiltInCopyTo<UInt8>(this.myData, newData, Int64(this.start), 0, this.size)
        intrinsicBuiltInCopyTo<UInt8>(other.myData, newData, Int64(other.start), this.size, other.size)
        return String(newData, 0, UInt32(newLen))
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave operator const func +(this @local!, other: String @local?): String @local! {
        let newLen = size + other.size
        if (newLen > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        let newData = rawArrayAllocate2<Byte>(newLen)
        rawArrayInitByValue2(newData, newLen, 0)
        intrinsicBuiltInCopyTo3<UInt8>(myData, newData, Int64(start), 0, size)
        intrinsicBuiltInCopyTo3<UInt8>(other.myData, newData, Int64(other.start), size, other.size)
        String(newData, 0, UInt32(newLen))
    }

    @Frozen
    public operator const func *(count: Int64): String {
        if (count < 0) {
            throw IllegalArgumentException("Invalid argument 'count': expected a non-negative value, got '${count}'.")
        }
        if (this.size == 0 || count == 0) {
            return String.empty
        }

        if (count > Int64(UInt32.Max) / this.size) {
            throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
        }

        let newLen = this.size * count
        let newData = rawArrayAllocate<Byte>(newLen)
        rawArrayInitByValue(newData, newLen, 0)
        var itemStart: Int64 = 0
        let byteSize: Int64 = size
        for (_ in 0..count) {
            intrinsicBuiltInCopyTo<UInt8>(this.myData, newData, Int64(this.start), itemStart, byteSize)
            itemStart += byteSize
        }
        return String(newData, 0, UInt32(newLen))
    }
    @Frozen
    @When[env != "ohos"]
    public exclave operator const func *(this @local!, count: Int64): String @local! {
        if (count < 0) {
            throw IllegalArgumentException("Negative count.")
        }
        if (this.size == 0 || count == 0) {
            return String() @local!
        }

        if (count > Int64(UInt32.Max) / this.size) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        let newLen = this.size * count
        let newData = rawArrayAllocate2<Byte>(newLen)
        rawArrayInitByValue2(newData, newLen, 0)
        var itemStart: Int64 = 0
        let byteSize: Int64 = size
        for (_ in 0..count) {
            intrinsicBuiltInCopyTo2<UInt8>(this.myData, newData, Int64(this.start), itemStart, byteSize)
            itemStart += byteSize
        }
        String(newData, 0, UInt32(newLen))
    }

    // Returns true if and only if string `left` is less than `right` with the lexicographical order.
    @Frozen
    public operator const func <(other: String): Bool {
        return match (this.compare(other)) {
            case LT => return true
            case _ => return false
        }
    }

    // Returns true if and only if string `left` is less than or equal to `right` with the lexicographical order.
    @Frozen
    public operator const func <=(other: String): Bool {
        return match (this.compare(other)) {
            case GT => return false
            case _ => return true
        }
    }

    // Returns true if and only if string `left` is greater than `right` with the lexicographical order.
    @Frozen
    public operator const func >(other: String): Bool {
        return match (this.compare(other)) {
            case GT => return true
            case _ => return false
        }
    }

    // Returns true if and only if string `left` is greater than or equal to `right` with the lexicographical order.
    @Frozen
    public operator const func >=(other: String): Bool {
        return match (this.compare(other)) {
            case LT => return false
            case _ => return true
        }
    }

    // Returns true if and only if the two string are identical.
    @Frozen
    public operator const func ==(other: String): Bool {
        if (this.length != other.length) {
            return false
        }
        if (intrinsicRefEqRawArray(this.myData, other.myData) && this.start == other.start) {
            return true
        }
        return compareBytes(this.myData, Int64(this.start), other.myData, Int64(other.start), Int64(this.length)) == 0
    }
    @Frozen
    @When[env != "ohos"]
    public exclave operator const func ==(this @local!, other: String @local!): Bool {
        if (this.length != other.length) {
            return false
        }
        if (intrinsicRefEqRawArray(this.myData, other.myData) && this.start == other.start) {
            return true
        }
        return compareBytes(this.myData, Int64(this.start), other.myData, Int64(other.start), Int64(this.length)) == 0
    }

    @Frozen
    @When[env != "ohos"]
    public operator const func ==(this @local?, other: String @local?): Bool {
        if (this.length != other.length) {
            return false
        }
        if (intrinsicRefEqRawArray(this.myData, other.myData) && this.start == other.start) {
            return true
        }
        compareBytes(this.myData, Int64(this.start), other.myData, Int64(other.start), Int64(this.length)) == 0
    }

    // Returns true if and only if the two string are not identical.
    @Frozen
    public operator const func !=(other: String): Bool {
        return !(this == other)
    }
    @Frozen
    @When[env != "ohos"]
    public exclave operator const func !=(this @local!, other: String @local!): Bool {
        return !(this == other)
    }

    @Frozen
    @When[env != "ohos"]
    public operator const func <(this @local?, other: String @local?): Bool {
        return match (this.compare(other)) {
            case LT => true
            case _ => false
        }
    }
    @Frozen
    @When[env != "ohos"]
    public operator const func <=(this @local?, other: String @local?): Bool {
        return match (this.compare(other)) {
            case GT => false
            case _ => true
        }
    }
    @Frozen
    @When[env != "ohos"]
    public operator const func >(this @local?, other: String @local?): Bool {
        return match (this.compare(other)) {
            case GT => true
            case _ => false
        }
    }
    @Frozen
    @When[env != "ohos"]
    public operator const func >=(this @local?, other: String @local?): Bool {
        return match (this.compare(other)) {
            case LT => false
            case _ => true
        }
    }
    @Frozen
    @When[env != "ohos"]
    public operator const func !=(this @local?, other: String @local?): Bool {
        !(this == other)
    }

    /**
     * @return the `Byte` value at the specified index.
     * @throws IndexOutOfBoundsException if `index` is out of bounds.
     */
    @Frozen
    @OverflowWrapping
    public operator const func [](index: Int64): Byte {
        if (index < 0 || index >= size) {
            throw IndexOutOfBoundsException(stringIndexOutOfBoundsExceptionMessage(index, size))
        }
        return arrayGetUnchecked(myData, index + Int64(start))
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public operator const func [](this @local?, index: Int64): Byte {
        if (index < 0 || index >= size) {
            throw IndexOutOfBoundsException(stringIndexOutOfBoundsExceptionMessage(index, size))
        }
        arrayGetUnchecked3<Byte>(myData, index + Int64(start))
    }

    // Considering the performance，this method do not check the parameters.
    // Use this method only with valid parameters.
    @Frozen
    private func sliceUnchecked(startIndex: Int64, len: Int64) {
        return String(Array<Byte>(myData, Int64(this.start) + startIndex, len))
    }

@When[env != "ohos"]
    @Frozen
    private exclave func sliceUnchecked(this @local?, startIndex: Int64, len: Int64): String @local? {
        String(Array<Byte>(myData, Int64(this.start) + startIndex, len) @local?)
    }

@When[env != "ohos"]
    @Frozen
    private exclave func sliceUnchecked(this @local!, startIndex: Int64, len: Int64): String @local! {
        String(Array<Byte>(myData, Int64(this.start) + startIndex, len) @local!) @local!
    }
    /**
     * @return the `String` value at the specified range.
     * @throws IllegalArgumentException if `step` is not equal to one.
     * @throws IndexOutOfBoundsException if `range` is out of bounds.
     * @throws IllegalArgumentException if the start or end point of the range is not the code point boundary.
     */
    @OverflowWrapping
    @Frozen
    public operator const func [](range: Range<Int64>): String {
        let start: Int64 = range.start
        var end: Int64 = range.end
        let step: Int64 = range.step
        let isClosed: Bool = range.isClosed

        if (step != 1) {
            throw IllegalArgumentException("String slice step must be 1, got '${step}'.")
        }

        if (isClosed) {
            end += 1
        }
        // If end is omitted, end = size of array.
        if (!range.hasEnd) {
            end = size
        }

        if (start < 0 || end < start || end > size) {
            throw IndexOutOfBoundsException("Invalid range: start is '${start}', end is '${end}', but size is '${size}'.")
        }
        if (start < size && (arrayGetUnchecked(myData, start + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the start position is not the code point boundary
            throw IllegalArgumentException("Invalid UTF-8 byte sequence: index '${start}' is not a code point boundary.")
        }
        if (end < size && (arrayGetUnchecked(myData, end + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the end position is not the code point boundary
            throw IllegalArgumentException("Invalid UTF-8 byte sequence: index '${end}' is not a code point boundary.")
        }
        if (end - start == 0) {
            return String.empty
        }
        return sliceUnchecked(start, end - start)
    }

    @OverflowWrapping
    @Frozen
    @When[env != "ohos"]
    public operator const func [](this @local?, range: Range<Int64>): String @local? {
        let start: Int64 = range.start
        var end: Int64 = range.end
        let step: Int64 = range.step
        let isClosed: Bool = range.isClosed

        if (step != 1) {
            throw IllegalArgumentException("the value of the step should be '1'")
        }

        if (isClosed) {
            end += 1
        }
        // If end is omitted, end = size of array.
        if (!range.hasEnd) {
            end = size
        }

        if (start < 0 || end < start || end > size) {
            throw IndexOutOfBoundsException("Invalid range start: ${start} or end: ${end}")
        }
        if (start < size && (arrayGetUnchecked3<UInt8>(myData, start + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the start position is not the code point boundary
            throw IllegalArgumentException("Invalid utf8 byte sequence.")
        }
        if (end < size && (arrayGetUnchecked3<UInt8>(myData, end + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the end position is not the code point boundary
            throw IllegalArgumentException("Invalid utf8 byte sequence.")
        }
        if (end - start == 0) {
            return String.empty
        }
        exclave { sliceUnchecked(start, end - start) }
    }

    @OverflowWrapping
    @Frozen
    @When[env != "ohos"]
    public exclave operator const func [](this @local!, range: Range<Int64>): String @local! {
        let start: Int64 = range.start
        var end: Int64 = range.end
        let step: Int64 = range.step
        let isClosed: Bool = range.isClosed

        if (step != 1) {
            throw IllegalArgumentException("the value of the step should be '1'")
        }

        if (isClosed) {
            end += 1
        }
        // If end is omitted, end = size of array.
        if (!range.hasEnd) {
            end = size
        }

        if (start < 0 || end < start || end > size) {
            throw IndexOutOfBoundsException("Invalid range start: ${start} or end: ${end}")
        }
        if (start < size && (arrayGetUnchecked3<UInt8>(myData, start + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the start position is not the code point boundary
            throw IllegalArgumentException("Invalid utf8 byte sequence.")
        }
        if (end < size && (arrayGetUnchecked3<UInt8>(myData, end + Int64(this.start)) >> 6) == 0b10) {
            // 0b10 means the end position is not the code point boundary
            throw IllegalArgumentException("Invalid utf8 byte sequence.")
        }
        if (end - start == 0) {
            return String() @local!
        }
        sliceUnchecked(start, end - start)
    }
    @Frozen
    @OverflowWrapping
    public static func join(strArray: Array<String>, delimiter!: String = String.empty): String {
        let strArraySize: Int64 = strArray.size
        if (strArraySize == 0) {
            return String.empty
        }
        var sizeOfBytes: Int64 = 0
        for (i in strArraySize - 1..=0 : -1) {
            let strSize = strArray[i].size
            if (sizeOfBytes > Int64(UInt32.Max) - strSize) {
                throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
            }
            sizeOfBytes += strSize
        }

        let delimiterCount = strArraySize - 1
        if (delimiterCount > 0 && delimiter.size > Int64(UInt32.Max) / delimiterCount) {
            throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
        }

        let delimiterTotal = delimiter.size * delimiterCount
        if (sizeOfBytes > Int64(UInt32.Max) - delimiterTotal) {
            throw IllegalArgumentException("String size exceeds maximum allowed size '${UInt32.Max}'.")
        }

        sizeOfBytes += delimiterTotal

        if (sizeOfBytes == 0) {
            return String.empty
        } else if (sizeOfBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("String size '${sizeOfBytes}' exceeds maximum allowed size '${UInt32.Max}'.")
        }

        let delimiterBytes: Array<UInt8> = unsafe { delimiter.rawData() }
        let sizeOfDelimiterByte: Int64 = delimiterBytes.size
        let bytes: Array<UInt8> = Array<UInt8>(sizeOfBytes, repeat: 0)
        var cursor: Int64 = 0
        // Concatenate strings and delimiters except the last string
        for (i in 0..(strArraySize - 1)) {
            let sz: Int64 = strArray[i].size
            bytes[cursor..(cursor + sz)] = unsafe { strArray[i].rawData() }
            cursor += sz
            // Append the delimiter
            bytes[cursor..(cursor + sizeOfDelimiterByte)] = delimiterBytes
            cursor += sizeOfDelimiterByte
        }
        // Append the last string
        let lastStr: String = strArray[strArraySize - 1]
        bytes[cursor..(cursor + lastStr.size)] = unsafe { lastStr.rawData() }
        return String(bytes)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave static func join(strArray: Array<String> @local!, delimiter!: String @local?): String @local! {
        let strArraySize: Int64 = strArray.size
        if (strArraySize == 0) {
            return String() @local!
        }
        var sizeOfBytes: Int64 = 0
        for (i in strArraySize - 1..=0 : -1) {
            let strSize = strArray[i].size
            if (sizeOfBytes > Int64(UInt32.Max) - strSize) {
                throw IllegalArgumentException("The size of String is too large.")
            }
            sizeOfBytes += strSize
        }

        let delimiterCount = strArraySize - 1
        if (delimiterCount > 0 && delimiter.size > Int64(UInt32.Max) / delimiterCount) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        let delimiterTotal = delimiter.size * delimiterCount
        if (sizeOfBytes > Int64(UInt32.Max) - delimiterTotal) {
            throw IllegalArgumentException("The size of String is too large.")
        }

        sizeOfBytes += delimiterTotal

        if (sizeOfBytes == 0) {
            return String() @local!
        } else if (sizeOfBytes > Int64(UInt32.Max)) {
            throw IllegalArgumentException("The size of target string is too large.")
        }

        let newRawPtr = rawArrayAllocate2<UInt8>(sizeOfBytes)
        rawArrayInitByValue2(newRawPtr, sizeOfBytes, 0)
        let sizeOfDelimiterByte: Int64 = Int64(delimiter.length)
        var cursor: Int64 = 0
        // Concatenate strings and delimiters except the last string
        for (i in 0..(strArraySize - 1)) {
            let sz: Int64 = Int64(strArray[i].length)
            for (j in 0..sz) {
                arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked3<UInt8>(strArray[i].myData, Int64(strArray[i].start) + j))
            }
            cursor += sz
            // Append the delimiter
            for (j in 0..sizeOfDelimiterByte) {
                arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked3<UInt8>(delimiter.myData, Int64(delimiter.start) + j))
            }
            cursor += sizeOfDelimiterByte
        }
        // Append the last string
        let lastStr: String @local! = strArray[strArraySize - 1]
        for (j in 0..Int64(lastStr.length)) {
            arraySetUnchecked2<UInt8>(newRawPtr, cursor + j, arrayGetUnchecked3<UInt8>(lastStr.myData, Int64(lastStr.start) + j))
        }
        String(newRawPtr, 0, UInt32(sizeOfBytes))
    }

    @Frozen
    @OverflowWrapping
    private func indexOfString(str: String, startIndex!: Int64 = 0, fromLast!: Bool = false): Int64 {
        var index: Int64 = -1
        let strSize: Int64 = str.size
        if (strSize == 0 || strSize > this.size) {
            return index
        }
        unsafe {
            var org: CPointer<UInt8> = acquireRawData<UInt8>(this.myData) + Int64(this.start)
            var pat: CPointer<UInt8> = acquireRawData<UInt8>(str.myData) + Int64(str.start)
            if (fromLast) {
                index = CJ_CORE_LastIndexOfString(org, pat, size, strSize, startIndex)
            } else {
                index = CJ_CORE_IndexOfString(org, pat, size, strSize, startIndex)
            }
            releaseRawData<UInt8>(this.myData, org - Int64(this.start))
            releaseRawData<UInt8>(str.myData, pat - Int64(str.start))
        }
        return index
    }

    /**
     * @throws OutOfMemoryError if failed to call CJ_CORE_CountAndIndexString.
     */
    @Frozen
    @OverflowWrapping
    private func splitOfString(str: String, maxSplits: Int64, removeEmpty: Bool): Array<String> {
        let strLen: Int64 = str.size
        if (strLen == 0) {
            return this.splitOfStringForOneRune(maxSplits)
        }

        var res: CPointer<Int64> = CPointer<Int64>()
        var indexes: CPointer<Int64> = CPointer<Int64>()
        var total: Int64 = 0
        unsafe {
            let org: CPointer<UInt8> = acquireRawData(this.myData) + Int64(this.start)
            let pat: CPointer<UInt8> = acquireRawData(str.myData) + Int64(str.start)
            res = CJ_CORE_CountAndIndexString(org, pat, size, strLen)
            if (res.isNull()) {
                releaseRawData(this.myData, org - Int64(this.start))
                releaseRawData(str.myData, pat - Int64(str.start))
                throw OutOfMemoryError("Failed malloc in C code!")
            }
            total = res.read(0)
            indexes = res + 1
            releaseRawData(this.myData, org - Int64(this.start))
            releaseRawData(str.myData, pat - Int64(str.start))
        }
        if (total == 0) {
            unsafe { LibC.free(res) }
            return [this]
        }
        try {
            return splitAsStringArray(indexes, total, strLen, maxSplits, removeEmpty)
        } finally {
            unsafe { LibC.free(res) }
        }
    }

    /**
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array `this.myData`.
     */
    @Frozen
    @OverflowWrapping
    private func splitOfStringForOneRune(maxSplits: Int64): Array<String> {
        let resLen = if (0 < maxSplits && maxSplits < size) {
            maxSplits
        } else {
            size
        }
        let resArr: Array<String> = Array<String>(resLen, repeat: unsafe { zeroValue<String>() })
        var i: Int64 = 0
        var index: Int64 = 0
        var itemStart: Int64 = 0
        while (index < resLen && i < size) {
            if (index == resLen - 1) {
                resArr[index] = String(this.myData, UInt32(itemStart) + start, length - UInt32(itemStart))
                index++
                break
            }
            let byte = arrayGetUnchecked(myData, i + Int64(start))
            let oneCharLen = if (byte.isAscii()) {
                1
            } else {
                Rune.utf8SizeUnchecked(byte)
            }
            resArr[index] = sliceUnchecked(itemStart, oneCharLen)
            itemStart += oneCharLen
            i += oneCharLen
            index++
        }
        return resArr[..index]
    }

    @Frozen
    private func getRealSplitLenWithRemoveEmpty(indexes: CPointer<Int64>, total: Int64, separatorLen: Int64) {
        var itemTotal: Int64 = 0
        var itemStart: Int64 = 0
        var i: Int64 = 0
        while (i < total) {
            var index = unsafe { indexes.read(i) }
            i++
            if (itemStart == index) {
                itemStart = index + separatorLen
                continue
            }
            itemStart = index + separatorLen
            itemTotal++
        }
        if (itemStart != size) {
            itemTotal++
        }
        return itemTotal
    }

    @Frozen
    @OverflowWrapping
    private func splitAsStringArray(
        indexes: CPointer<Int64>,
        total: Int64,
        separatorLen: Int64,
        maxSplits: Int64,
        removeEmpty: Bool
    ): Array<String> {
        var itemTotal: Int64 = if (removeEmpty) {
            getRealSplitLenWithRemoveEmpty(indexes, total, separatorLen)
        } else {
            total + 1
        }
        var resLen: Int64 = if (0 < maxSplits && maxSplits < itemTotal) {
            maxSplits
        } else {
            itemTotal
        }
        if (resLen == 0) {
            return Array<String>()
        }
        if (maxSplits == 1) {
            return [this]
        }
        let resArr: Array<String> = Array<String>(resLen, repeat: String.empty)
        var (i, j, itemStart, index, resStr) = (0, 0, 0, 0, String.empty)
        while (j < resLen - 1) {
            index = unsafe { indexes.read(i) }
            i++
            if (removeEmpty && itemStart == index) {
                itemStart = index + separatorLen
                continue
            }
            resStr = String(this.myData, UInt32(itemStart) + start, UInt32(index) - UInt32(itemStart))
            resArr[j] = resStr
            j++
            itemStart = index + separatorLen
        }
        // Special Processing Last String
        if (removeEmpty && i < total) {
            while (i < total) {
                index = unsafe { indexes.read(i) }
                i++
                if (itemStart == index) {
                    itemStart = index + separatorLen
                    continue
                }
                break
            }
            if (itemStart > index || (maxSplits > 0 && resLen != itemTotal)) {
                index = size
            }
            resArr[j] = String(this.myData, UInt32(itemStart) + start, UInt32(index) - UInt32(itemStart))
            return resArr
        }
        resArr[j] = String(this.myData, UInt32(itemStart) + start, length - UInt32(itemStart))
        return resArr
    }

    @Frozen
    public static unsafe func withRawData(rawData: Array<UInt8>): String {
        return String(rawData)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave static unsafe func withRawData(rawData: Array<UInt8> @local!): String @local! {
        String(rawData)
    }

    @Frozen
    public static func checkUtf8Encoding(data: Array<UInt8>): Bool {
        let arr = data.rawptr
        let endIndex = data.start + data.size

        var i = data.start
        while (i < endIndex) {
            var nowByte: UInt8 = arrayGetUnchecked<UInt8>(arr, i)
            match {
                case nowByte < HIGH_1_UInt8 => i += 1
                case nowByte < HIGH_2_UInt8 => return false
                case nowByte < HIGH_3_UInt8 =>
                    if (!checkUtf8Of2BytesWithoutException(arr, i, endIndex)) {
                        return false
                    }
                    i += 2
                case nowByte < HIGH_4_UInt8 =>
                    if (!checkUtf8Of3BytesWithoutException(arr, i, endIndex)) {
                        return false
                    }
                    i += 3
                case nowByte < HIGH_5_UInt8 =>
                    if (!checkUtf8Of4BytesWithoutException(arr, i, endIndex)) {
                        return false
                    }
                    i += 4
                case _ => return false
            }
        }
        return true
    }
}

@When[backend == "cjnative"]
@OverflowWrapping
func utf8RuneSize(arr: RawArray<UInt8>, start: Int64, length: Int64): Int64 {
    if (length < STRING_C_THRESHOLD) {
        var utf32Size = 0
        for (i in length - 1..=0 : -1) {
            if ((arrayGet<UInt8>(arr, start + i) & 0xC0) != 0x80) {
                utf32Size++
            }
        }
        return utf32Size
    }

    unsafe {
        let pointer: CPointer<UInt8> = acquireRawData<UInt8>(arr) + start
        let utf32Size = CJ_CORE_StringSize(pointer, length)
        releaseRawData(arr, pointer - start)
        return utf32Size
    }
}

@When[backend == "cjnative"]
struct RunesToUtf8Bytes {
    @OverflowWrapping
    public static func getBytes(runes: Array<Rune>): Array<UInt8> {
        var itemBytes: Array<UInt8> = Array<UInt8>(getSize(runes), repeat: 0)
        var itemLen: Int64 = 0
        for (i in 0..runes.size) {
            let r = runes[i]
            if (r.isAscii()) {
                itemBytes[itemLen] = UInt8(UInt32(r))
                itemLen++
            } else {
                itemLen += Rune.intoUtf8Array(r, itemBytes, itemLen)
            }
        }
        return itemBytes
    }

    @OverflowWrapping
    @When[env != "ohos"]
    public exclave static func getBytesLocal(runes: Array<Rune> @local?): Array<UInt8> @local! {
        var itemBytes: Array<UInt8> @local! = Array<UInt8>(getSize(runes), repeat: 0)
        var itemLen: Int64 = 0
        for (i in 0..Int64(runes.size)) {
            let r = runes[i]
            if (r.isAscii()) {
                itemBytes[itemLen] = UInt8(UInt32(r))
                itemLen++
            } else {
                itemLen += Rune.intoUtf8Array(r, itemBytes, itemLen)
            }
        }
        itemBytes
    }

    @OverflowWrapping
    public static func getBytes(elements: Collection<Rune>): Array<UInt8> {
        let itemBytes: Array<UInt8> = Array<UInt8>(UNICODE_TO_UTF8_MAX_LEN * elements.size, repeat: 0)
        var itemLen: Int64 = 0
        let it = elements.iterator()
        while (true) {
            var c: Rune = match (it.next()) {
                case Some(v) => v
                case None => break
            }
            itemLen += Rune.intoUtf8Array(c, itemBytes, itemLen)
        }
        var bytes: Array<UInt8> = Array<UInt8>(itemLen, repeat: 0)
        bytes[..itemLen] = itemBytes[..itemLen]
        return bytes
    }

    @OverflowWrapping
    @When[env != "ohos"]
    public exclave static func getBytesLocalCollection(value: Collection<Rune> @local?): Array<UInt8> @local! {
        // `size` prop is not dispatchable on a `@local?` interface receiver, so run two
        // passes with fresh iterators: one to count UTF-8 bytes, one to fill the buffer.
        var total: Int64 = 0
        let countIt = value.iterator()
        while (true) {
            let r: Rune = match (countIt.next()) {
                case Some(v) => v
                case None => break
            }
            total += Rune.utf8Size(r)
        }
        var itemBytes: Array<UInt8> @local! = Array<UInt8>(total, repeat: 0)
        var itemLen: Int64 = 0
        let fillIt = value.iterator()
        while (true) {
            let r: Rune = match (fillIt.next()) {
                case Some(v) => v
                case None => break
            }
            itemLen += Rune.intoUtf8Array(r, itemBytes, itemLen)
        }
        itemBytes
    }

    @OverflowWrapping
    public static func getSize(runes: Array<Rune>): Int64 {
        var size: Int64 = 0
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in runes.size - 1..=0 : -1) {
            size += Rune.utf8Size(runes[i])
        }
        return size
    }

    @OverflowWrapping
    @When[env != "ohos"]
    public static func getSize(runes: Array<Rune> @local?): Int64 {
        var size: Int64 = 0
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in runes.size - 1..=0 : -1) {
            size += Rune.utf8Size(runes[i])
        }
        return size
    }
}

private func stringIndexOutOfBoundsExceptionMessage(index: Int64, len: Int64): String {
    "The length of the string is ${len}, but the index is ${index}."
}
