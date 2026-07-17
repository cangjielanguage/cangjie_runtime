/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest.common

import std.collection.*
import std.convert.Parsable

private let HEXTABLE = unsafe { "0123456789abcdef".rawData() }
private let MIN_INT_LIT = unsafe { "-9223372036854775808".rawData() }

func stringEscapeCharNumGet(input: String): Int64 {
    var i = 0
    for (byte in input) {
        if (byte == 0x7F) {
            i = i + 6
            continue
        }
        // ASCII code over 32 don't need escape
        if ((byte >= 32) && (byte != b'\"') && (byte != b'\\') && (byte != b'&')) {
            i++
            continue
        }

        match (byte) {
            case b'\b' | b'\f' | b'\n' | b'\r' | b'\t' | b'\\' | b'"' =>
                i += 2
            case _ =>
                i += 6
        }
    }
    return i
}

@OverflowWrapping
func replaceEscapeChar(input: String, output: Array<Byte>, from!: Int64 = 0): Int64 {
    var i = from
    for (byte in input) {
        if (byte == 0x7F) {
            output[i] = b'\\'
            output[i + 1] = b'u'
            output[i + 2] = b'0'
            output[i + 3] = b'0'
            output[i + 4] = b'7'
            output[i + 5] = b'f'
            i = i + 6
            continue
        }
        if ((byte >= 32) && (byte != b'\"') && (byte != b'\\') && (byte != b'&')) { // ASCII code over 32 don't need escape
            output[i] = byte
            i++
            continue
        }

        match (byte) {
            case b'\b' =>
                output[i] = b'\\'
                output[i + 1] = b'b'
                i += 2
            case b'\f' =>
                output[i] = b'\\'
                output[i + 1] = b'f'
                i += 2
            case b'\n' =>
                output[i] = b'\\'
                output[i + 1] = b'n'
                i += 2
            case b'\r' =>
                output[i] = b'\\'
                output[i + 1] = b'r'
                i += 2
            case b'\t' =>
                output[i] = b'\\'
                output[i + 1] = b't'
                i += 2
            case b'\\' =>
                output[i] = b'\\'
                output[i + 1] = b'\\'
                i += 2
            case b'"' =>
                output[i] = b'\\'
                output[i + 1] = b'"'
                i += 2
            case _ =>
                output[i] = b'\\'
                output[i + 1] = b'u'
                output[i + 2] = b'0'
                output[i + 3] = b'0'
                output[i + 4] = HEXTABLE[Int64(byte >> 4)] // num of high 4 bits
                output[i + 5] = HEXTABLE[Int64(byte & 0xF)] // num of low 4 bits
                i += 6
        }
    }
    return i - from
}

const MAX_JSON_PARSE_DEPTH = 100

/**
 * @brief Get rows and columns of the error position
 *
 * @param Array<UInt8> JSON string array
 * @param Int64 The order of the error characters in the string
 * @return (Int64, Int64) Rows and columns of the error position
 * @throws IllegalArgumentException if there is no valid utf8 leading code in array `strArr`.
 */
func getErrRowAndCol(strArr: Array<UInt8>, errPos: Int64): (Int64, Int64) {
    var tempPos: Int64 = 0
    var errRow: Int64 = 1
    var errCol: Int64 = 1
    var lineStartPos: Int64 = 0
    while (tempPos < errPos) {
        let temp = Rune.fromUtf8(strArr, tempPos)
        let tempChr = temp[0]
        if (tempChr == r'\n') {
            errRow += 1
            lineStartPos = tempPos + 1
        }
        tempPos += temp[1]
    }
    while (lineStartPos < errPos) {
        let tempChr = Rune.fromUtf8(strArr, lineStartPos)[0]
        if (tempChr == r' ') {
            lineStartPos += 1
        } else {
            break
        }
    }
    while (lineStartPos < errPos) {
        let temp = Rune.fromUtf8(strArr, lineStartPos)
        let tempSize = temp[1]
        errCol += 1
        lineStartPos += tempSize
    }
    return (errRow, errCol)
}

/**
 * @brief Handle Escape Characters and Multibyte Characters
 *
 * @param Rune error characters
 * @return String Escaped character string
 */
func handleErrChr(errChr: Rune): String {
    match (errChr) {
        case r'\0' => return "\\0"
        case r'\b' => return "\\b"
        case r'\t' => return "\\t"
        case r'\n' => return "\\n"
        case r'\f' => return "\\f"
        case r'\r' => return "\\r"
        case r'\v' => return "\\v"
        case _ => return "${errChr}"
    }
}

enum NumberSystem {
    Binary |
    Octal |
    Decimal |
    Hex
}

class JsonParser {
    let data: Array<Byte>
    let size: Int64
    var offset: Int64
    var depth: Int64
    var cache: Array<JsonValue>
    var cacheSize: Int64
    let strCache: ArrayList<Byte>

    init(str: String) {
        this.data = unsafe { str.rawData() }
        this.size = data.size
        this.offset = 0
        this.depth = 0
        if ((size >> 1) > 16) {
            this.cache = Array<JsonValue>(size >> 1, repeat: JsonNull())
        } else {
            this.cache = Array<JsonValue>(16, repeat: JsonNull())
        }
        this.cacheSize = 0
        this.strCache = ArrayList<Byte>()
    }
}

func requireCurrentByte(parser: JsonParser): Byte {
    if (parser.offset >= parser.size) {
        throw JsonException()
    }
    return parser.data[parser.offset]
}

func ensureCacheCapacity(parser: JsonParser, addition: Int64): Unit {
    let minCapacity = parser.cacheSize + addition
    if (minCapacity <= parser.cache.size) {
        return
    }
    var newCapacity = parser.cache.size
    while (newCapacity < minCapacity) {
        newCapacity = newCapacity << 1
    }
    let newCache = Array<JsonValue>(newCapacity, repeat: JsonNull())
    parser.cache.copyTo(newCache, 0, 0, parser.cacheSize)
    parser.cache = newCache
}

func isHighSurrogate(num: UInt32): Bool {
    return num >= 0xD800u32 && num <= 0xDBFFu32
}

func isLowSurrogate(num: UInt32): Bool {
    return num >= 0xDC00u32 && num <= 0xDFFFu32
}

func ensureFiniteJsonFloat(value: Float64): Float64 {
    if (value.isNaN() || value.isInf()) {
        throw JsonException("Invalid float dectected.")
    }
    return value
}

func skipWhiteSpace(parser: JsonParser): Unit {
    if (parser.offset >= parser.size) {
        return
    }
    var tmp = parser.data[parser.offset]
    while (tmp == b' ' || tmp == b'\t' || tmp == b'\n' || tmp == b'\r') {
        parser.offset++
        if (parser.offset >= parser.size) {
            return
        }
        tmp = parser.data[parser.offset]
    }
}

func parseString(str: String): JsonValue {
    if (str.size == 0) {
        throw JsonException("Json String is empty!")
    }
    let parser = JsonParser(str)
    let res = parseJson(parser)
    if (parser.offset <= (parser.size - 1)) {
        skipWhiteSpace(parser)
    }
    if (parser.offset <= (parser.size - 1)) {
        let errRowAndCol = getErrRowAndCol(parser.data, parser.offset)
        let (errChr, _) = Rune.fromUtf8(parser.data, parser.offset)
        let errStr = handleErrChr(errChr)
        let errMsg: String = "Parse Error: [Line]: ${errRowAndCol[0]}, [Pos]: ${errRowAndCol[1]}, [Error]: Unexpected character: \'${errStr}\'."
        throw JsonException("The json data is Non-standard, please check:\n${errMsg}")
    }
    return res
}

func parseJson(parser: JsonParser): JsonValue {
    try {
        skipWhiteSpace(parser)
        let start = requireCurrentByte(parser)
        match {
            case start == b'{' => return parseNestedJson(parser, {=> parseJsonObject(parser)})
            case start == b'[' => return parseNestedJson(parser, {=> parseJsonArray(parser)})
            case start == b'n' => return parseJsonNull(parser)
            case start == b't' => return parseJsonTrue(parser)
            case start == b'f' => return parseJsonFalse(parser)
            case start == b'\"' => return parseJsonString(parser)
            case start >= b'0' && start <= b'9' || start == b'-' => return parseJsonNumber(parser)
            case _ => throw JsonException()
        }
    } catch (_: Exception) {
        unsafe {
            let strArr = parser.data
            var errPos = parser.offset
            if (errPos >= strArr.size) {
                errPos = strArr.size - 1
            }
            let errRowAndCol = getErrRowAndCol(strArr, errPos)
            let (errChr, _) = Rune.fromUtf8(strArr, errPos)
            let errStr = handleErrChr(errChr)
            let errMsg: String = "Parse Error: [Line]: ${errRowAndCol[0]}, [Pos]: ${errRowAndCol[1]}, [Error]: Unexpected character: \'${errStr}\'."
            throw JsonException("The json data is Non-standard, please check:\n${errMsg}")
        }
    }
}

func parseNestedJson(parser: JsonParser, block: () -> JsonValue): JsonValue {
    parser.depth++
    if (parser.depth > MAX_JSON_PARSE_DEPTH) {
        throw JsonException("Json nested depth exceeds ${MAX_JSON_PARSE_DEPTH}.")
    }
    try {
        return block()
    } finally {
        parser.depth--
    }
}

func parseJsonObject(parser: JsonParser): JsonObject {
    parser.offset++
    skipWhiteSpace(parser)
    var count = 0
    var first = true
    while (requireCurrentByte(parser) != b'}') {
        if (first) {
            first = false
        } else if (requireCurrentByte(parser) == b',') {
            parser.offset++
        } else {
            throw JsonException()
        }
        skipWhiteSpace(parser)
        let key = parseJsonString(parser)
        skipWhiteSpace(parser)
        if (requireCurrentByte(parser) != b':') {
            throw JsonException()
        }
        parser.offset++
        let value = parseJson(parser)
        skipWhiteSpace(parser)
        ensureCacheCapacity(parser, 2)
        parser.cache[parser.cacheSize] = key
        parser.cache[parser.cacheSize + 1] = value
        count++
        parser.cacheSize += 2
    }
    parser.offset++
    let map = HashMap<String, JsonValue>(count)
    for (i in count..0 : -1) {
        let key = parser.cache[parser.cacheSize - (i * 2)].asString().getValue()
        let value = parser.cache[parser.cacheSize - (i * 2) + 1]
        map.add(key, value)
    }
    parser.cacheSize -= (2 * count)
    return JsonObject(map)
}

func parseJsonArray(parser: JsonParser): JsonArray {
    parser.offset++
    skipWhiteSpace(parser)
    var count = 0
    var first = true
    while (requireCurrentByte(parser) != b']') {
        if (first) {
            first = false
        } else if (requireCurrentByte(parser) == b',') {
            parser.offset++
        } else {
            throw JsonException()
        }
        let item = parseJson(parser)
        skipWhiteSpace(parser)
        ensureCacheCapacity(parser, 1)
        parser.cache[parser.cacheSize] = item
        count++
        parser.cacheSize++
    }
    parser.offset++
    let arr = ArrayList<JsonValue>(count)
    for (i in count..0 : -1) {
        let item = parser.cache[parser.cacheSize - i]
        arr.add(item)
    }
    parser.cacheSize -= count
    return JsonArray(arr)
}

func parseJsonNull(parser: JsonParser): JsonNull {
    if (requireCurrentByte(parser) != b'n') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'u') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    return JsonNull()
}

func parseJsonTrue(parser: JsonParser): JsonBool {
    if (requireCurrentByte(parser) != b't') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'r') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'u') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'e') {
        throw JsonException()
    }
    parser.offset++
    return JsonBool(true)
}

func parseJsonFalse(parser: JsonParser): JsonBool {
    if (requireCurrentByte(parser) != b'f') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'a') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b's') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'e') {
        throw JsonException()
    }
    parser.offset++
    return JsonBool(false)
}

func parseJsonNumber(parser: JsonParser): JsonValue {
    var isFloat = false
    let leftIndex = parser.offset
    var rightIndex = parser.offset
    parseSign(parser)
    let numSystem = parseNumberSystem(parser)
    let isNumber = checkNumberSystem(numSystem)
    parseInteger(parser, isNumber)
    isFloat = parseDecimal(parser, numSystem)
    if (isFloat) {
        parseExponent(parser, numSystem)
    } else {
        isFloat = parseExponent(parser, numSystem)
    }
    rightIndex = parser.offset
    let numStr = unsafe { String.fromUtf8Unchecked(parser.data[leftIndex..rightIndex]) }
    if (isFloat) {
        return JsonFloat(ensureFiniteJsonFloat(Float64.parse(numStr)))
    }
    return JsonInt(Int64.parse(numStr))
}

func parseSign(parser: JsonParser): Unit {
    if (parser.offset < parser.size && parser.data[parser.offset] == b'-') {
        parser.offset++
    }
}

func parseNumberSystem(parser: JsonParser): NumberSystem {
    if (requireCurrentByte(parser) == b'0') {
        parser.offset++
        if (parser.offset >= parser.size) {
            parser.offset--
            return Decimal
        }
        match (parser.data[parser.offset]) {
            case 'b' | 'B' =>
                parser.offset++
                return Binary
            case 'o' | 'O' =>
                parser.offset++
                return Octal
            case 'x' | 'X' =>
                parser.offset++
                return Hex
            case _ => parser.offset--
        }
    }
    return Decimal
}

func checkNumberSystem(numSystem: NumberSystem): (Byte) -> Bool {
    match (numSystem) {
        case Binary => return {byte: Byte => byte >= b'0' && byte <= b'1'}
        case Octal => return {byte: Byte => byte >= b'0' && byte <= b'7'}
        case Decimal => return {byte: Byte => byte >= b'0' && byte <= b'9'}
        case Hex => return {
            byte: Byte => byte >= b'0' && byte <= b'9' || byte >= b'a' &&
                byte <= b'f' || byte >= b'A' && byte <= b'F'
        }
    }
}

func parseInteger(parser: JsonParser, isNumber: (Byte) -> Bool): Unit {
    var nextByte = requireCurrentByte(parser)
    var hasNumber = false
    if (nextByte == b'0') {
        parser.offset++
        return
    }
    while (isNumber(nextByte)) {
        hasNumber = true
        parser.offset++
        if (parser.offset >= parser.size) {
            return
        }
        nextByte = parser.data[parser.offset]
    }
    if (!hasNumber) {
        throw JsonException()
    }
}

func parseDecimal(parser: JsonParser, numSystem: NumberSystem): Bool {
    if (parser.offset >= parser.size) {
        return false
    }
    if (parser.data[parser.offset] != b'.') {
        return false
    }
    match (numSystem) {
        case Decimal => ()
        case _ => throw JsonException()
    }
    parser.offset++
    return parseDigit(parser)
}

func parseExponent(parser: JsonParser, numSystem: NumberSystem): Bool {
    if (parser.offset >= parser.size) {
        return false
    }
    var nextByte = requireCurrentByte(parser)
    if (nextByte != b'e' && nextByte != b'E') {
        return false
    }
    match (numSystem) {
        case Decimal => ()
        case _ => throw JsonException()
    }
    parser.offset++
    nextByte = requireCurrentByte(parser)
    if (nextByte == b'+' || nextByte == b'-') {
        parser.offset++
    }
    return parseDigit(parser)
}

func parseDigit(parser: JsonParser): Bool {
    var nextByte = requireCurrentByte(parser)
    var hasNumber = false
    while (nextByte >= b'0' && nextByte <= b'9') {
        hasNumber = true
        parser.offset++
        if (parser.offset >= parser.size) {
            return true
        }
        nextByte = parser.data[parser.offset]
    }
    if (!hasNumber) {
        throw JsonException()
    }
    return true
}

func isHexNum(char: UInt8): Bool {
    if (!((char >= b'0' && char <= b'9') || (char >= b'a' && char <= b'f') ||
        (char >= b'A' && char <= b'F'))) {
        return false
    }
    return true
}

func parseJsonString(parser: JsonParser): JsonString {
    if (requireCurrentByte(parser) != b'\"') {
        throw JsonException("Fail to parseJsonString")
    }
    parser.offset++
    let start = parser.offset
    var next = requireCurrentByte(parser)
    var needEscape = false
    var tmpStart = start
    while (next != b'\"') {
        if (next == b'\\') {
            if (!needEscape) {
                needEscape = true
            }
            parser.strCache.add(all: parser.data[tmpStart..parser.offset])
            parser.offset++
            handleEscape(parser)
            tmpStart = parser.offset + 1
        }
        parser.offset++
        next = requireCurrentByte(parser)
    }
    parser.offset++
    if (!needEscape) {
        return unsafe { JsonString(String.fromUtf8Unchecked(parser.data[start..(parser.offset - 1)])) }
    } else {
        parser.strCache.add(all: parser.data[tmpStart..parser.offset - 1])
        let res = unsafe { JsonString(String.fromUtf8Unchecked(parser.strCache.getRawArray()[0..parser.strCache.size])) }
        parser.strCache.clear()
        return res
    }
}

func getNextHexNum(parser: JsonParser): Byte {
    parser.offset++
    let byte = requireCurrentByte(parser)
    if (!isHexNum(byte)) {
        throw JsonException()
    }
    return byte
}

func handleEscape(parser: JsonParser): Unit {
    match (requireCurrentByte(parser)) {
        case '\"' => parser.strCache.add(b'\"')
        case '\\' => parser.strCache.add(b'\\')
        case '/' => parser.strCache.add(b'/')
        case 'b' => parser.strCache.add(b'\b')
        case 'f' => parser.strCache.add(b'\f')
        case 'n' => parser.strCache.add(b'\n')
        case 'r' => parser.strCache.add(b'\r')
        case 't' => parser.strCache.add(b'\t')
        case 'u' =>
            let byte1 = getNextHexNum(parser)
            let byte2 = getNextHexNum(parser)
            let byte3 = getNextHexNum(parser)
            let byte4 = getNextHexNum(parser)
            let arr: Array<Byte> = [b'\'', b'\\', b'u', b'{',
                byte1, byte2, byte3, byte4, b'}', b'\'']
            try {
                let chr = unsafe { Rune.parse(String.fromUtf8Unchecked(arr)) }
                if (UInt32(chr) <= 127) {
                    parser.strCache.add(UInt8(UInt32(chr)))
                } else {
                    let str = chr.toString()
                    unsafe { parser.strCache.add(all: str.rawData()) }
                }
            } catch (_: Exception) {
                parser.offset++
                if (requireCurrentByte(parser) != b'\\') {
                    throw JsonException()
                }
                parser.offset++
                if (requireCurrentByte(parser) != b'u') {
                    throw JsonException()
                }
                let byte5 = getNextHexNum(parser)
                let byte6 = getNextHexNum(parser)
                let byte7 = getNextHexNum(parser)
                let byte8 = getNextHexNum(parser)
                let str1 = unsafe { String.fromUtf8Unchecked([b'0', b'x', byte1, byte2, byte3, byte4]) }
                let str2 = unsafe { String.fromUtf8Unchecked([b'0', b'x', byte5, byte6, byte7, byte8]) }
                let rawNum1 = UInt32.parse(str1)
                let rawNum2 = UInt32.parse(str2)
                if (!isHighSurrogate(rawNum1) || !isLowSurrogate(rawNum2)) {
                    throw JsonException()
                }
                let num1 = rawNum1 & 0b0000001111111111
                let num2 = rawNum2 & 0b0000001111111111
                let str = Rune((((UInt32(num1)) << 10) | (UInt32(num2))) + 0x10000).toString()
                unsafe { parser.strCache.add(all: str.rawData()) }
            }
        case _ => throw JsonException("Fail to parseJsonString")
    }
}
