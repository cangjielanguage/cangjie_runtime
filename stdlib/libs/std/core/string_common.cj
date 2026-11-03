/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

const ASCII_A: UInt8 = 'A'
const ASCII_Z: UInt8 = 'Z'
const ASCII_a: UInt8 = 'a'
const ASCII_z: UInt8 = 'z'
const ASCII_UPPER_LOWER_DIFFERENCE: UInt8 = b'a' - b'A'

const HIGH_1_MASK: UInt32 = 0b10000000 // 0x80
const HIGH_2_MASK: UInt32 = 0b11000000 // 0xc0
const HIGH_3_MASK: UInt32 = 0b11100000 // 0xe0
const HIGH_4_MASK: UInt32 = 0b11110000 // 0xf0
const HIGH_5_MASK: UInt32 = 0b11111000 // 0xf8
const HIGH_6_MASK: UInt32 = 0b11111100 // 0xfc
const SHIFT_30: UInt32 = 30
const SHIFT_24: UInt32 = 24
const SHIFT_18: UInt32 = 18
const SHIFT_12: UInt32 = 12
const SHIFT_6: UInt32 = 6
const LOW_6_MASK: UInt32 = 0b00111111 // 0x3f
const LOW_5_MASK: UInt32 = 0b00011111 // 0x1f
const LOW_4_MASK: UInt32 = 0b00001111 // 0x0f
const LOW_3_MASK: UInt32 = 0b00000111 // 0x07
const LOW_2_MASK: UInt32 = 0b00000011 // 0x03
const LOW_1_MASK: UInt32 = 0b00000001 // 0x01
const UTF8_4_MAX: UInt32 = 0x10FFFF
const UTF8_3_MAX: UInt32 = 0xFFFF
const UTF8_2_MAX: UInt32 = 0x07FF
const UTF8_1_MAX: UInt32 = 0x7F
const HIGH_1_UInt8: UInt8 = 0b10000000 // 0x80
const HIGH_2_UInt8: UInt8 = 0b11000000 // 0xc0
const HIGH_3_UInt8: UInt8 = 0b11100000 // 0xe0
const HIGH_4_UInt8: UInt8 = 0b11110000 // 0xf0
const HIGH_5_UInt8: UInt8 = 0b11111000 // 0xf8
const HIGH_6_UInt8: UInt8 = 0b11111100 // 0xfc

@ConstSafe
const EMPTY_UINT8_ARRAY: Array<UInt8> = Array<UInt8>()
@ConstSafe
const EMPTY_UINT8_RAW_ARRAY: RawArray<UInt8> = rawArrayAllocate<UInt8>(0)
let EMPTY_INT64_ARRAY: Array<Int64> = Array<Int64>()
let EMPTY_STRING_ARRAY: Array<String> = Array<String>()
const STRING_C_THRESHOLD = 32

/**
 * Legal UTF-8 Byte Sequences of 2 bytes
 * Code point      Byte 1	 Byte 2
 * U+0080..U+07FF  110xxxxx   10xxxxxx
 *                 C2..DF     80..BF
 */
func checkUtf8Of2Bytes(arr: RawArray<UInt8> @local?, startIndex: Int64, endIndex: Int64): Rune {
    if (startIndex + 2 > endIndex) {
        throw IllegalArgumentException("Invalid utf8 byte sequence.")
    }
    let byte1 = arrayGetUnchecked3<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked3<UInt8>(arr, startIndex + 1)
    if ((byte1 & 0x1e) == 0 || (byte2 & 0xc0) != 0x80) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }
    Rune(((UInt32(byte1) & LOW_5_MASK) << SHIFT_6) | (UInt32(byte2) & LOW_6_MASK))
}

func checkUtf8Of2BytesWithoutException(arr: RawArray<UInt8>, startIndex: Int64, endIndex: Int64): Bool {
    if (startIndex + 2 > endIndex) {
        return false
    }
    let byte1 = arrayGetUnchecked<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked<UInt8>(arr, startIndex + 1)
    if ((byte1 & 0x1e) == 0 || (byte2 & 0xc0) != 0x80) {
        return false
    }
    true
}

/**
 * Legal UTF-8 Byte Sequences of 3 bytes
 * Code point        Byte 1	   Byte 2     Byte 3
 * U+0800..U+FFFF    1110xxxx   10xxxxxx   10xxxxxx
 * U+0800..U+0FFF    E0         A0..BF     80..BF
 * U+1000..U+FFFF    E1..EF     80..BF     80..BF
 */
func checkUtf8Of3Bytes(arr: RawArray<UInt8> @local?, startIndex: Int64, endIndex: Int64): Rune {
    if (startIndex + 3 > endIndex) {
        throw IllegalArgumentException("Invalid utf8 byte sequence.")
    }
    let byte1 = arrayGetUnchecked3<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked3<UInt8>(arr, startIndex + 1)
    let byte3 = arrayGetUnchecked3<UInt8>(arr, startIndex + 2)
    // ensure b2 and b3 start with 0b10
    if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    // when the first equals E0, second byte cannot less then A0
    if ((byte1 & 0b1111) == 0 && (byte2 & 0b00100000) == 0) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    // Unicode does not have any characters in the range D800-DFFF
    if ((byte1 & 0b1111) == 0b1101 && (byte2 & 0b00100000) != 0) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    let code = ((UInt32(byte1) & LOW_4_MASK) << SHIFT_12) |
                ((UInt32(byte2) & LOW_6_MASK) << SHIFT_6) |
                (UInt32(byte3) & LOW_6_MASK)
    Rune(code)
}

func checkUtf8Of3BytesWithoutException(arr: RawArray<UInt8>, startIndex: Int64, endIndex: Int64): Bool {
    if (startIndex + 3 > endIndex) {
        return false
    }
    let byte1 = arrayGetUnchecked<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked<UInt8>(arr, startIndex + 1)
    let byte3 = arrayGetUnchecked<UInt8>(arr, startIndex + 2)
    // ensure b2 and b3 start with 0b10
    if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80) {
        return false
    }
 
    // when the first equals E0, second byte cannot less then A0
    if ((byte1 & 0b1111) == 0 && (byte2 & 0b00100000) == 0) {
        return false
    }
 
    // Unicode does not have any characters in the range D800-DFFF
    if ((byte1 & 0b1111) == 0b1101 && (byte2 & 0b00100000) != 0) {
        return false
    }
 
    true
}

/**
 * Legal UTF-8 Byte Sequences of 3 bytes
 * Code point        Byte 1	   Byte 2     Byte 3    Byte 4
 * U+10000..U+10FFFF 11110xxx   10xxxxxx   10xxxxxx  10xxxxxx
 * U+10000..U+3FFFF  F0         90..BF     80..BF    80..BF
 * U+40000..U+FFFFF  F1..F3     80..BF     80..BF    80..BF
 * U+100000..U10FFFF F4         80..8F     80..BF    80..BF
 */
func checkUtf8Of4Bytes(arr: RawArray<UInt8> @local?, startIndex: Int64, endIndex: Int64): Rune {
    if (startIndex + 4 > endIndex) {
        throw IllegalArgumentException("Invalid utf8 byte sequence.")
    }

    let byte1 = arrayGetUnchecked3<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked3<UInt8>(arr, startIndex + 1)
    let byte3 = arrayGetUnchecked3<UInt8>(arr, startIndex + 2)
    let byte4 = arrayGetUnchecked3<UInt8>(arr, startIndex + 3)
    if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80 || (byte4 & 0xc0) != 0x80) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    // byte 1 cannot bigger then 0xF4
    if ((byte1 & 0b111) > 0b100) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    // in the range of U+10000..U+3FFFF, when b1 equals 0xF0, b2 should not less then 0x90
    if ((byte1 & 0b111) == 0 && (byte2 & 0b00110000) == 0) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }

    // in the range of U+100000..U10FFFF, when b1 equals 0xF4, b2 no bigger then 8F
    if ((byte1 & 0b111) == 0b100 && (byte2 & 0b00110000) != 0) {
        throw IllegalArgumentException("Invalid unicode scalar value.")
    }
    let code = ((UInt32(byte1) & LOW_3_MASK) << SHIFT_18) |
                ((UInt32(byte2) & LOW_6_MASK) << SHIFT_12) |
                ((UInt32(byte3) & LOW_6_MASK) << SHIFT_6) |
                (UInt32(byte4) & LOW_6_MASK)
    Rune(code)
}

func checkUtf8Of4BytesWithoutException(arr: RawArray<UInt8>, startIndex: Int64, endIndex: Int64): Bool {
    if (startIndex + 4 > endIndex) {
        return false
    }
 
    let byte1 = arrayGetUnchecked<UInt8>(arr, startIndex)
    let byte2 = arrayGetUnchecked<UInt8>(arr, startIndex + 1)
    let byte3 = arrayGetUnchecked<UInt8>(arr, startIndex + 2)
    let byte4 = arrayGetUnchecked<UInt8>(arr, startIndex + 3)
    if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80 || (byte4 & 0xc0) != 0x80) {
        return false
    }
 
    // byte 1 cannot bigger then 0xF4
    if ((byte1 & 0b111) > 0b100) {
        return false
    }
 
    // in the range of U+10000..U+3FFFF, when b1 equals 0xF0, b2 should not less then 0x90
    if ((byte1 & 0b111) == 0 && (byte2 & 0b00110000) == 0) {
        return false
    }
 
    // in the range of U+100000..U10FFFF, when b1 equals 0xF4, b2 no bigger then 8F
    if ((byte1 & 0b111) == 0b100 && (byte2 & 0b00110000) != 0) {
        return false
    }
 
    true
}

/**
 * The function validates the bytecode and throws an exception if it does not comply with the rules of utf8.
 * If no exception occurs, the number of characters is returned.
 *
 * @param arr : Checked bytecode
 * @throws IllegalArgumentException if Array<Byte> is an Invalid unicode scalar value.
 * @return Int64 : Number of characters
 */
func checkInvalid(arr: RawArray<Byte>, startIndex: Int64, endIndex: Int64): Unit {
    var i = startIndex
    while (i < endIndex) {
        var nowByte: UInt8 = arrayGetUnchecked3<UInt8>(arr, i)
        match {
            case nowByte < HIGH_1_UInt8 => i += 1
            case nowByte < HIGH_2_UInt8 => throw IllegalArgumentException("Invalid utf8 byte sequence.")
            case nowByte < HIGH_3_UInt8 =>
                checkUtf8Of2Bytes(arr, i, endIndex)
                i += 2
            case nowByte < HIGH_4_UInt8 =>
                checkUtf8Of3Bytes(arr, i, endIndex)
                i += 3
            case nowByte < HIGH_5_UInt8 =>
                checkUtf8Of4Bytes(arr, i, endIndex)
                i += 4
            case _ => throw IllegalArgumentException("Invalid unicode scalar value.")
        }
    }
}
func checkInvalid(arr: RawArray<Byte> @local?, startIndex: Int64, endIndex: Int64): Unit {
    var i = startIndex
    while (i < endIndex) {
        var nowByte: UInt8 = arrayGetUnchecked3<UInt8>(arr, i)
        match {
            case nowByte < HIGH_1_UInt8 => i += 1
            case nowByte < HIGH_2_UInt8 => throw IllegalArgumentException("Invalid utf8 byte sequence.")
            case nowByte < HIGH_3_UInt8 =>
                checkUtf8Of2Bytes(arr, i, endIndex)
                i += 2
            case nowByte < HIGH_4_UInt8 =>
                checkUtf8Of3Bytes(arr, i, endIndex)
                i += 3
            case nowByte < HIGH_5_UInt8 =>
                checkUtf8Of4Bytes(arr, i, endIndex)
                i += 4
            case _ => throw IllegalArgumentException("Invalid unicode scalar value.")
        }
    }
}

class StringIteratorData {
    let myData: Array<UInt8>
    var end: Int64
    var nextPos: Int64 = 0

    init(data: Array<UInt8>) {
        this.myData = data
        this.end = myData.size
        this.nextPos = 0
    }

    init(data: RawArray<UInt8>) {
        this.myData = toArray(data)
        this.end = myData.size
        this.nextPos = 0
    }

    @When[env != "ohos"]
    exclave init(this @local!, data: Array<UInt8> @local!) {
        myData = data
        end = myData.size
        nextPos = 0
    }
    @When[env != "ohos"]
    exclave init(this @local!, data: RawArray<UInt8> @local!) {
        this.myData = toArray(data)
        this.end = myData.size
        this.nextPos = 0
    }
    @When[env != "ohos"]
    exclave init(this @local?, data: Array<UInt8> @local?) {
        myData = data
        end = myData.size
        nextPos = 0
    }
    @When[env != "ohos"]
    exclave init(this @local?, data: RawArray<UInt8> @local?) {
        this.myData = toArray(data)
        this.end = myData.size
        this.nextPos = 0
    }
}

// String's Rune Iterator.
class StringRuneIterator <: Iterator<Rune> {
    @Frozen
    StringRuneIterator(let iteratorData: StringIteratorData) {}
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local!, iteratorData: StringIteratorData @local!) {
        this.iteratorData = iteratorData
    }
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local?, iteratorData: StringIteratorData @local?) {
        this.iteratorData = iteratorData
    }
    /**
     * @return the next element in the iteration.
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array `myData`.
     */
    @OverflowWrapping
    @Frozen
    public func next(): Option<Rune> {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var (rune, num): (Rune, Int64) = Rune.fromUtf8(iteratorData.myData, iteratorData.nextPos)
        iteratorData.nextPos += num
        return Some<Rune>(rune)
    }
    @When[env != "ohos"]
    @OverflowWrapping
    @Frozen
    public exclave func next(this @local!): Option<Rune> @local! {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var (rune, num): (Rune, Int64) = Rune.fromUtf8(iteratorData.myData, iteratorData.nextPos)
        iteratorData.nextPos += num
        return Some<Rune>(rune)
    }
    @When[env != "ohos"]
    @OverflowWrapping
    @Frozen
    public exclave func next(this @local?): Option<Rune> @local? {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var (rune, num): (Rune, Int64) = Rune.fromUtf8(iteratorData.myData, iteratorData.nextPos)
        iteratorData.nextPos += num
        return Some<Rune>(rune)
    }
}

// String's Byte Iterator.
class StringByteIterator <: Iterator<Byte> {
    @Frozen
    StringByteIterator(let iteratorData: StringIteratorData) {}
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local!, iteratorData: StringIteratorData @local!) {
        this.iteratorData = iteratorData
    }
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local?, iteratorData: StringIteratorData @local?) {
        this.iteratorData = iteratorData
    }
    /**
     * @return the next element in the iteration.
     * @throws IllegalArgumentException if there is an invalid utf8 leading code
     *         in array `myData`.
     */
    @Frozen
    @OverflowWrapping
    public func next(): Option<Byte> {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        let byte = iteratorData.myData.get(iteratorData.nextPos)
        iteratorData.nextPos = iteratorData.nextPos + 1
        return byte
    }
    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    public exclave func next(this @local!): Option<Byte> @local! {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        let byte = iteratorData.myData.get(iteratorData.nextPos)
        iteratorData.nextPos = iteratorData.nextPos + 1
        return byte
    }
    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    public exclave func next(this @local?): Option<Byte> @local? {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        let byte = iteratorData.myData.get(iteratorData.nextPos)
        iteratorData.nextPos = iteratorData.nextPos + 1
        return byte
    }
}

// String's Line `Iterator`.
// '/nr','/r', "/r/n" means ends of a line.
class StringLineIterator <: Iterator<String> {
    @Frozen
    StringLineIterator(let iteratorData: StringIteratorData) {}
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local!, iteratorData: StringIteratorData @local!) {
        this.iteratorData = iteratorData
    }
    @Frozen
    @When[env != "ohos"]
    exclave init(this @local?, iteratorData: StringIteratorData @local?) {
        this.iteratorData = iteratorData
    }

    @Frozen
    @OverflowWrapping
    public func next(): Option<String> {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var pos = iteratorData.nextPos
        var haveCR = false
        while (pos < iteratorData.end) {
            match (iteratorData.myData[pos]) {
                case '\r' =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some(str)
                    }
                    haveCR = true
                case '\n' =>
                    let str = if (haveCR) {
                        String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                    } else {
                        String(iteratorData.myData[iteratorData.nextPos..pos])
                    }
                    iteratorData.nextPos = pos + 1
                    return Some(str)
                case _ =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some(str)
                    }
            }
            pos++
        }
        let end = if (haveCR) { iteratorData.end - 1 } else { iteratorData.end }
        let str = String(iteratorData.myData[iteratorData.nextPos..end])
        iteratorData.nextPos = iteratorData.end
        return Some(str)
    }

@When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    public exclave func next(this @local!): Option<String> @local! {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var pos = iteratorData.nextPos
        var haveCR = false
        while (pos < iteratorData.end) {
            match (iteratorData.myData[pos]) {
                case '\r' =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some<String>(str)
                    }
                    haveCR = true
                case '\n' =>
                    let str = if (haveCR) {
                        String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                    } else {
                        String(iteratorData.myData[iteratorData.nextPos..pos])
                    }
                    iteratorData.nextPos = pos + 1
                    return Some<String>(str)
                case _ =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some<String>(str)
                    }
            }
            pos++
        }
        let end = if (haveCR) { iteratorData.end - 1 } else { iteratorData.end }
        let str = String(iteratorData.myData[iteratorData.nextPos..end])
        iteratorData.nextPos = iteratorData.end
        Some<String>(str)
    }

@When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    public exclave func next(this @local?): Option<String> @local? {
        if (iteratorData.nextPos >= iteratorData.end) {
            return None
        }
        var pos = iteratorData.nextPos
        var haveCR = false
        while (pos < iteratorData.end) {
            match (iteratorData.myData[pos]) {
                case '\r' =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some<String>(str)
                    }
                    haveCR = true
                case '\n' =>
                    let str = if (haveCR) {
                        String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                    } else {
                        String(iteratorData.myData[iteratorData.nextPos..pos])
                    }
                    iteratorData.nextPos = pos + 1
                    return Some<String>(str)
                case _ =>
                    if (haveCR) {
                        let str = String(iteratorData.myData[iteratorData.nextPos..pos - 1])
                        iteratorData.nextPos = pos
                        return Some<String>(str)
                    }
            }
            pos++
        }
        let end = if (haveCR) { iteratorData.end - 1 } else { iteratorData.end }
        let str = String(iteratorData.myData[iteratorData.nextPos..end])
        iteratorData.nextPos = iteratorData.end
        Some<String>(str)
    }
}

// String lazySplit Iterator.
class StringLazySplitIterator <: Iterator<String> {
    private let orgData: Array<UInt8>
    private let separatorLen: Int64
    private var itemArr: Array<Int64>
    private var maxSplits: Int64
    private var removeEmpty: Bool
    private var resLen: Int64 = 0
    private var nextPos: Int64 = 0
    private var itemStart: Int64 = 0
    private var itemIndex: Int64 = 0
    private var itemTotal: Int64 = 0

    /**
     * @throws OutOfMemoryError if failed to call CJ_CORE_CountAndIndexString.
     */
    init(orgStrData: Array<UInt8>, orgStrSize: Int64, str: String, maxSplits: Int64, removeEmpty: Bool) {
        this.orgData = orgStrData
        this.separatorLen = str.size
        this.maxSplits = maxSplits
        this.removeEmpty = removeEmpty
        this.itemArr = EMPTY_INT64_ARRAY
        if (this.separatorLen == 0) {
            if (0 < maxSplits && maxSplits < orgStrSize) {
                this.resLen = maxSplits
            } else {
                this.resLen = orgStrSize
            }
        } else {
            unsafe {
                let org: CPointerHandle<UInt8> = acquireArrayRawData<UInt8>(this.orgData)
                let pat: CPointerHandle<UInt8> = acquireArrayRawData<UInt8>(str.rawData())
                var res: CPointer<Int64> = CJ_CORE_CountAndIndexString(
                    org.pointer,
                    pat.pointer,
                    this.orgData.size,
                    this.separatorLen
                )
                releaseArrayRawData(org)
                releaseArrayRawData(pat)
                if (res.isNull()) {
                    throw OutOfMemoryError("Failed to allocate memory in C code.")
                }
                try {
                    convertCPointer2Array(res, maxSplits, removeEmpty)
                } finally {
                    LibC.free(res)
                }
            }
        }
    }

    @When[env != "ohos"]
    init(orgStrData: Array<UInt8>, orgStrSize: Int64, str: String @local?, maxSplits: Int64, removeEmpty: Bool) {
        this.orgData = orgStrData
        this.separatorLen = str.size
        this.maxSplits = maxSplits
        this.removeEmpty = removeEmpty
        this.itemArr = EMPTY_INT64_ARRAY
        if (this.separatorLen == 0) {
            if (0 < maxSplits && maxSplits < orgStrSize) {
                this.resLen = maxSplits
            } else {
                this.resLen = orgStrSize
            }
        } else {
            unsafe {
                let org: CPointerHandle<UInt8> @local? = acquireArrayRawData<UInt8>(this.orgData)
                let pat: CPointerHandle<UInt8> @local? = acquireArrayRawData<UInt8>(str.rawData())
                var res: CPointer<Int64> = CJ_CORE_CountAndIndexString(
                    org.pointer,
                    pat.pointer,
                    this.orgData.size,
                    this.separatorLen
                )
                releaseArrayRawData(org)
                releaseArrayRawData(pat)
                if (res.isNull()) {
                    throw OutOfMemoryError("Failed malloc in C code!")
                }
                try {
                    convertCPointer2Array(res, maxSplits, removeEmpty)
                } finally {
                    LibC.free(res)
                }
            }
        }
    }

    @OverflowWrapping
    public func next(): Option<String> {
        if (this.separatorLen == 0) {
            if (itemStart >= orgData.size || nextPos >= resLen) {
                return None
            }
            if (nextPos == resLen - 1) {
                let res: String
                unsafe {
                    res = String.fromUtf8Unchecked(this.orgData.slice(this.itemStart, this.orgData.size - this.itemStart
                    ))
                }
                nextPos++
                return res
            }
            var oneCharLen = Rune.utf8Size(this.orgData, this.itemStart)
            let res: String
            unsafe { res = String.fromUtf8Unchecked(this.orgData.slice(this.itemStart, oneCharLen)) }
            this.itemStart += oneCharLen
            nextPos++
            return res
        }
        if (this.nextPos >= this.resLen) {
            return None
        }
        var str = getString()
        this.nextPos++
        return Some<String>(str)
    }

    /**
     * @throws IllegalArgumentException if `this.orgData[this.itemStart]` is an
     *         invalid utf8 leading code.
     */
    @OverflowWrapping
    private func getString(): String {
        if (this.resLen == 1 && this.itemArr.isEmpty()) {
            return unsafe { String.fromUtf8Unchecked(this.orgData) }
        }
        while (this.nextPos < this.resLen - 1) {
            var index = this.itemArr[this.itemIndex]
            this.itemIndex++
            if (removeEmpty && this.itemStart == index) {
                this.itemStart = index + this.separatorLen
                continue
            }
            let res: String
            unsafe { res = String.fromUtf8Unchecked(this.orgData.slice(this.itemStart, index - this.itemStart)) }
            this.itemStart = index + this.separatorLen
            return res
        }
        if (removeEmpty && this.itemIndex < this.itemArr.size && resLen != 1) {
            var index: Int64 = 0
            while (this.itemIndex < this.itemArr.size) {
                index = this.itemArr[this.itemIndex]
                this.itemIndex++
                if (this.itemStart == index) {
                    this.itemStart = index + this.separatorLen
                    continue
                }
                break
            }
            if (this.itemStart > index || (this.maxSplits > 0 && this.resLen != itemTotal)) {
                index = this.orgData.size
            }
            return unsafe { String.fromUtf8Unchecked(this.orgData.slice(this.itemStart, index - this.itemStart)) }
        }
        return unsafe { String.fromUtf8Unchecked(this.orgData.slice(this.itemStart, this.orgData.size - this.itemStart)) }
    }

    @OverflowWrapping
    private func convertCPointer2Array(res: CPointer<Int64>, maxSplits: Int64, removeEmpty: Bool) {
        var total = unsafe { res.read(0) }
        var indexes: CPointer<Int64> = unsafe { res + 1 }
        if (total == 0) {
            this.resLen = 1
            return
        }
        let resArr: Array<Int64> = Array<Int64>(total, repeat: 0)
        var itemStart: Int64 = 0
        var i: Int64 = 0
        while (i < total) {
            var index = unsafe { indexes.read(i) }
            resArr[i] = index
            i++
            if (removeEmpty && itemStart == index) {
                itemStart = index + separatorLen
                continue
            }
            itemStart = index + separatorLen
            this.itemTotal++
        }
        if (removeEmpty) {
            if (itemStart != this.orgData.size) {
                this.itemTotal++
            }
        } else {
            this.itemTotal = total + 1
        }
        if (0 < maxSplits && maxSplits < itemTotal) {
            this.resLen = maxSplits
        } else {
            this.resLen = itemTotal
        }
        this.itemArr = resArr
    }
}
