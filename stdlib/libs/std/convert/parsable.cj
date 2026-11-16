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
 * This file defines some base64 convert methods.
 *
 */

package std.convert

@FastNative
foreign func CJ_STRTOD(str: CString): CPointer<Float64>

/**
 * @Description Provide an unified abstraction to support specific types of parsing from strings.
 *
 * @since 0.17.4
 */
public interface Parsable<T> {

    /**
     * @Description Provides an abstract function to support specific types of parsing from strings.
     *
     * @param value of String.
     * @return Parameters of T.
     *
     * @since 0.31.2
     */
    static func parse(value: String): T

    /**
     * @Description Provides an abstract function to support specific types of parsing from strings.
     *
     * @param value of String.
     * @return Parameters of Option<T>.
     *
     * @since 0.31.2
     */
    static func tryParse(value: String): Option<T>
}

public interface RadixConvertible<T> {
    static func parse(value: String, radix!: Int64): T

    static func tryParse(value: String, radix!: Int64): Option<T>

    func toString(radix!: Int64): String
}

@When[env != "ohos"]
func parseCompInt(rawData: Array<Byte> @local?, formatBaseNum: UInt64, multmin: UInt64, maxAbsVal: UInt64, isMark!: Bool = true): UInt64 {
    var num: UInt64 = 0
    var lineLength = 0
    var rawDataSlice = rawData
    if (isMark && formatBaseNum != 10) {
        rawDataSlice = rawData[2..]
    }
    var digitCount: Int64 = 0
    var lastWasUnderscore: Bool = false
    for (i in 0..rawDataSlice.size) {
        var digit: UInt64 = 0
        if (rawDataSlice[i] == b'_') {
            if (digitCount == 0 || lastWasUnderscore) {
                throw IllegalArgumentException("The part of value convert failed.")
            }
            lastWasUnderscore = true
            lineLength++
            continue
        }
        lastWasUnderscore = false
        digit = DIGITS_UI64[Int64(rawDataSlice[i])]
        if (digit >= formatBaseNum || lineLength >= rawDataSlice.size) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        if (num > multmin) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        num *= formatBaseNum
        if (maxAbsVal - num < digit) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        num += digit
        digitCount++
    }
    if (digitCount == 0 || lastWasUnderscore) {
        throw IllegalArgumentException("The part of value convert failed.")
    }
    return num
}

// OHOS excludes local Array accessors, so normal parsing uses heap-mode Array operations.
@When[env == "ohos"]
func parseCompInt(rawData: Array<Byte>, formatBaseNum: UInt64, multmin: UInt64, maxAbsVal: UInt64, isMark!: Bool = true): UInt64 {
    var num: UInt64 = 0
    var lineLength = 0
    var rawDataSlice = rawData
    if (isMark && formatBaseNum != 10) {
        rawDataSlice = rawData[2..]
    }
    var digitCount: Int64 = 0
    var lastWasUnderscore: Bool = false
    for (i in 0..rawDataSlice.size) {
        var digit: UInt64 = 0
        if (rawDataSlice[i] == b'_') {
            if (digitCount == 0 || lastWasUnderscore) {
                throw IllegalArgumentException("The part of value convert failed.")
            }
            lastWasUnderscore = true
            lineLength++
            continue
        }
        lastWasUnderscore = false
        digit = DIGITS_UI64[Int64(rawDataSlice[i])]
        if (digit >= formatBaseNum || lineLength >= rawDataSlice.size) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        if (num > multmin) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        num *= formatBaseNum
        if (maxAbsVal - num < digit) {
            throw IllegalArgumentException("The part of value convert failed.")
        }
        num += digit
        digitCount++
    }
    if (digitCount == 0 || lastWasUnderscore) {
        throw IllegalArgumentException("The part of value convert failed.")
    }
    return num
}

func tryParseCompInt(rawData: Array<Byte>, formatBaseNum: UInt64, multmin: UInt64, maxAbsVal: UInt64,
    isMark!: Bool = true): ConvertResult<UInt64> {
    var num: UInt64 = 0
    var lineLength = 0
    var rawDatas = rawData
    if (isMark && formatBaseNum != 10) {
        rawDatas = rawData[2..]
    }
    var digitCount: Int64 = 0
    var lastWasUnderscore: Bool = false
    for (i in 0..rawDatas.size) {
        var digit: UInt64 = 0
        if (rawDatas[i] == b'_') {
            if (digitCount == 0 || lastWasUnderscore) {
                return Failure("The part of value convert failed.")
            }
            lastWasUnderscore = true
            lineLength++
            continue
        }
        lastWasUnderscore = false
        digit = DIGITS_UI64[Int64(rawDatas[i])]
        if (digit >= formatBaseNum || lineLength >= rawDatas.size) {
            return Failure("The part of value convert failed.")
        }
        if (num > multmin) {
            return Failure("The part of value convert failed.")
        }
        num *= formatBaseNum
        if (maxAbsVal - num < digit) {
            return Failure("The part of value convert failed.")
        }
        num += digit
        digitCount++
    }
    if (digitCount == 0 || lastWasUnderscore) {
        return Failure("The part of value convert failed.")
    }
    return Success(num)
}

/*
 * @Description The Int8 is extended to provide the functions of parsing a string into Int8 or Option<Int8> type.
 *
 * @since 0.17.4
 */
extend Int8 <: Parsable<Int8> {

    /**
     * @Description Convert a string of Int8 literals to an Int8 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Int8.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+",
     * or if failing to convert to Int8, or if the value after conversion is out of the Int8 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): Int8 {
        let (rawData, isNegative) = getDataAndFlag(data, true, "Int8")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = if (isNegative == 0) {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_MAXABSVAL_I8, MAXABSVAL_I8)
        } else {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_I8, MAXVAL_I8)
        }
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.I8, isNegative, rawData)
        }
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)
        if (isNegative == 0) {
            return Int8(-num)
        }
        return Int8(num)
    }

    /**
     * @Description Convert a string of Int8 literals to an Option<Int8> value. If the failure occurs, Option<Int8>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Int8>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<Int8> {
        let (rawData, isNegative) = getTryDataAndFlag(data, true, "Int8")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosInt8[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.I8, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int8(-n)
                } else {
                    return Int8(n)
                }
            case Failure(_) => None
        }
    }
}

extend Int8 <: RadixConvertible<Int8> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): Int8 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, true, "Int8", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I8,
            isNegative, radix)
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)
        if (isNegative == 0) {
            return Int8(-num)
        }
        return Int8(num)
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<Int8> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, true, "Int8", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I8,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int8(-n)
                } else {
                    return Int8(n)
                }
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return Int64(this).toString(radix: radix)
    }
}

/*
 * @Description The UInt8 is extended to provide the functions of parsing a string into UInt8 type or Option<UInt8> type.
 *
 * @since 0.17.4
 */
extend UInt8 <: Parsable<UInt8> {

    /**
     * @Description Convert a string of UInt8 literals to a UInt8 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of UInt8.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+" or "-",
     * or if failing to convert to UInt8, or if the value after conversion is out of the UInt8 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): UInt8 {
        let (rawData, isNegative) = getDataAndFlag(data, false, "UInt8")
        /* Processes binary underscores separately. */
        var (formatBaseNum, multmin): (UInt64, UInt64) = (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_UI8)
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, _) = getBaseInfos(TypeBase.UI8, isNegative, rawData)
        }
        return UInt8(parseCompInt(rawData, formatBaseNum, multmin, MAXVAL_UI8))
    }

    /**
     * @Description Convert a string of UInt8 literals to an Option<UInt8> value. If the failure occurs, Option<UInt8>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<UInt8>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<UInt8> {
        let (rawData, isNegative) = getTryDataAndFlag(data, false, "UInt8")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosUInt8[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.UI8, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) => UInt8(n)
            case Failure(_) => None
        }
    }
}

extend UInt8 <: RadixConvertible<UInt8> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): UInt8 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, false, "UInt8", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI8,
            isNegative, radix)
        return UInt8(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false))
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<UInt8> {
        let (u8RawData, u8SignFlag) = getTryDataAndFlagWithRadix(value, false, "UInt8", radix)
        if (u8RawData.size == 0) {
            return None
        }
        var (u8FormatBaseNum, u8Multmin, u8MaxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI8,
            u8SignFlag, radix)
        match (tryParseCompInt(u8RawData, u8FormatBaseNum, u8Multmin, u8MaxAbsVal, isMark: false)) {
            case Success(u8Parsed) => UInt8(u8Parsed)
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return UInt64(this).toString(radix: radix)
    }
}

/*
 * @Description The Int16 is extended to provide the functions of parsing a character string into Int16 type or Option<Int16> type.
 *
 * @since 0.17.4
 */
extend Int16 <: Parsable<Int16> {

    /**
     * @Description Convert a string of Int16 literals to an Int16 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Int16.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+",
     * or if failing to convert to Int16, or if the value after conversion is out of the Int16 range,
     * @or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): Int16 {
        let (rawData, isNegative) = getDataAndFlag(data, true, "Int16")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = if (isNegative == 0) {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_MAXABSVAL_I16, MAXABSVAL_I16)
        } else {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_I16, MAXVAL_I16)
        }
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.I16, isNegative, rawData)
        }
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)
        if (isNegative == 0) {
            return Int16(-num)
        }
        return Int16(num)
    }

    /**
     * @Description Convert a string of Int16 literals to an Option<Int16> value. If the failure occurs, Option<Int16>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Int16>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<Int16> {
        let (rawData, isNegative) = getTryDataAndFlag(data, true, "Int16")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosInt16[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.I16, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int16(-n)
                } else {
                    return Int16(n)
                }
            case Failure(_) => None
        }
    }
}

extend Int16 <: RadixConvertible<Int16> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): Int16 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, true, "Int16", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I16,
            isNegative, radix)
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)
        if (isNegative == 0) {
            return Int16(-num)
        }
        return Int16(num)
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<Int16> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, true, "Int16", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I16,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int16(-n)
                } else {
                    return Int16(n)
                }
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return Int64(this).toString(radix: radix)
    }
}

/*
 * @Description The UInt16 is extended to provide the functions of parsing character strings to UInt16 type or Option<UInt16> type.
 *
 * @since 0.17.4
 */
extend UInt16 <: Parsable<UInt16> {

    /**
     * @Description Convert a string of UInt16 literals to a UInt16 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of UInt16.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+" or "-",
     * or if failing to convert to UInt16, or if the value after conversion is out of the UInt16 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): UInt16 {
        let (rawData, isNegative) = getDataAndFlag(data, false, "UInt16")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = (FOTMAT_BASE_NUM_UI64_10,
            DECIMAL_OVERFLOW_LIMIT_UI16, MAXVAL_UI16)
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.UI16, isNegative, rawData)
        }
        return UInt16(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal))
    }

    /**
     * @Description Convert a string of UInt16 literals to an Option<UInt16> value. If the failure occurs, Option<UInt16>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<UInt16>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<UInt16> {
        let (rawData, isNegative) = getTryDataAndFlag(data, false, "UInt16")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosUInt16[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.UI16, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) => UInt16(n)
            case Failure(_) => None
        }
    }
}

extend UInt16 <: RadixConvertible<UInt16> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): UInt16 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, false, "UInt16", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI16,
            isNegative, radix)
        return UInt16(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false))
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<UInt16> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, false, "UInt16", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI16,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) => UInt16(n)
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return UInt64(this).toString(radix: radix)
    }
}
/*
 * @Description The Int32 is extended to provide the function of parsing a character string into Int32 type or Option<Int32> type.
 *
 * @since 0.17.4
 */
extend Int32 <: Parsable<Int32> {

    /**
     * @Description Convert a string of Int32 literals to an Int32 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Int32.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+",
     * or if failing to convert to Int32, or if the value after conversion is out of the Int32 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): Int32 {
        let (rawData, isNegative) = getDataAndFlag(data, true, "Int32")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = if (isNegative == 0) {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_MAXABSVAL_I32, MAXABSVAL_I32)
        } else {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_I32, MAXVAL_I32)
        }
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.I32, isNegative, rawData)
        }
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)
        if (isNegative == 0) {
            return Int32(-num)
        }
        return Int32(num)
    }

    /**
     * @Description Convert a string of Int32 literals to an Option<Int32> value. If the failure occurs, Option<Int32>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Int32>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<Int32> {
        let (rawData, isNegative) = getTryDataAndFlag(data, true, "Int32")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosInt32[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.I32, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int32(-n)
                } else {
                    return Int32(n)
                }
            case Failure(_) => None
        }
    }
}

extend Int32 <: RadixConvertible<Int32> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): Int32 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, true, "Int32", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I32,
            isNegative, radix)
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)
        if (isNegative == 0) {
            return Int32(-num)
        }
        return Int32(num)
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<Int32> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, true, "Int32", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I32,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int32(-n)
                } else {
                    return Int32(n)
                }
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return Int64(this).toString(radix: radix)
    }
}

/*
 * @Description The UInt32 is extended to provide the functions of parsing a character string into UInt32 type or Option<UInt32> type.
 *
 * @since 0.17.4.
 */
extend UInt32 <: Parsable<UInt32> {

    /**
     * @Description Convert a string of UInt32 literals to a UInt32 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of UInt32.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+" or "-",
     * or if failing to convert to UInt32, or if the value after conversion is out of the UInt32 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): UInt32 {
        let (rawData, isNegative) = getDataAndFlag(data, false, "UInt32")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = (FOTMAT_BASE_NUM_UI64_10,
            DECIMAL_OVERFLOW_LIMIT_UI32, MAXVAL_UI32)
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.UI32, isNegative, rawData)
        }
        return UInt32(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal))
    }

    /**
     * @Description Convert a string of UInt32 literals to an Option<UInt32> value. If the failure occurs, Option<UInt32>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<UInt32>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<UInt32> {
        let (rawData, isNegative) = getTryDataAndFlag(data, false, "UInt32")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosUInt32[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.UI32, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) => UInt32(n)
            case Failure(_) => None
        }
    }
}

extend UInt32 <: RadixConvertible<UInt32> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): UInt32 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, false, "UInt32", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI32,
            isNegative, radix)
        return UInt32(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false))
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<UInt32> {
        let (u32RawData, u32SignFlag) = getTryDataAndFlagWithRadix(value, false, "UInt32", radix)
        if (u32RawData.size == 0) {
            return None
        }
        var (u32FormatBaseNum, u32Multmin, u32MaxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(
            TypeBase.UI32, u32SignFlag, radix)
        match (tryParseCompInt(u32RawData, u32FormatBaseNum, u32Multmin, u32MaxAbsVal, isMark: false)) {
            case Success(u32Parsed) => UInt32(u32Parsed)
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        return UInt64(this).toString(radix: radix)
    }
}

/*
 * @Description The Int64 is extended to provide the functions of parsing a character string to Int64 type or Option<Int64> type.
 *
 * @since 0.17.4
 */
extend Int64 <: Parsable<Int64> {

    /**
     * @Description Convert a string of Int64 literals to an Int64 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Int64.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+",
     * or if failing to convert to Int64, or if the value after conversion is out of the Int64 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): Int64 {
        let (rawData, isNegative) = getDataAndFlag(data, true, "Int64")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = if (isNegative == 0) {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_MAXABSVAL_I64, MAXABSVAL_I64)
        } else {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_I64, MAXVAL_I64)
        }
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.I64, isNegative, rawData)
        }
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)
        if (isNegative == 0) {
            return Int64(-num)
        }
        return Int64(num)
    }

    @When[env != "ohos"]
    @OverflowWrapping
    public static func parse(data: String @local?): Int64 {
        let (rawData, isNegative) = getDataAndFlag(data, true, "Int64")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = if (isNegative == 0) {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_MAXABSVAL_I64, MAXABSVAL_I64)
        } else {
            (FOTMAT_BASE_NUM_UI64_10, DECIMAL_OVERFLOW_LIMIT_I64, MAXVAL_I64)
        }
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.I64, isNegative, rawData)
        }
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)
        if (isNegative == 0) {
            return Int64(-num)
        }
        return Int64(num)
    }

    /**
     * @Description Convert a string of Int64 literals to an Option<Int64> value. If the failure occurs, Option<Int64>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Int64>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<Int64> {
        let (rawData, isNegative) = getTryDataAndFlag(data, true, "Int64")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosInt64[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.I64, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int64(-n)
                } else {
                    return Int64(n)
                }
            case Failure(_) => None
        }
    }
}

extend Int64 <: RadixConvertible<Int64> {
    @OverflowWrapping
    public static func parse(value: String, radix!: Int64): Int64 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, true, "Int64", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I64,
            isNegative, radix)
        var num: UInt64 = parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)
        if (isNegative == 0) {
            return Int64(-num)
        }
        return Int64(num)
    }

    @OverflowWrapping
    public static func tryParse(value: String, radix!: Int64): Option<Int64> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, true, "Int64", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.I64,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) =>
                if (isNegative == 0) {
                    return Int64(-n)
                } else {
                    return Int64(n)
                }
            case Failure(_) => None
        }
    }

    @OverflowWrapping
    public func toString(radix!: Int64): String {
        if (radix == 10) {
            return this.toString()
        }
        if (radix < 2 || radix > 36) {
            throw IllegalArgumentException("The radix out of range.")
        }
        var unum: UInt64 = 0
        var isNegative = 1
        if (this < 0) {
            unum = UInt64(-this)
            isNegative = 0
        } else {
            unum = UInt64(this)
            isNegative = 1
        }
        var nums = match (radix) {
            case 2 | 4 | 8 | 16 | 32 => toRadixString(unum, radix)
            case _ => toRadixStringCom(unum, radix)
        }
        if (isNegative == 0) {
            return "-${nums}"
        }
        return "${nums}"
    }
}

/*
 * @Description The UInt64 is extended to provide the functions of parsing character strings to UInt64 type or Option<UInt64> type.
 *
 * @since 0.17.4.
 */
extend UInt64 <: Parsable<UInt64> {

    /**
     * @Description Convert a string of UInt64 literals to a UInt64 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of UInt64.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+" or "-",
     * or if failing to convert to UInt64, or if the value after conversion is out of the UInt64 range,
     * or if there is an invalid utf8 code in the string.
     */
    @OverflowWrapping
    public static func parse(data: String): UInt64 {
        let (rawData, isNegative) = getDataAndFlag(data, false, "UInt64")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = (FOTMAT_BASE_NUM_UI64_10,
            DECIMAL_OVERFLOW_LIMIT_UI64, MAXVAL_UI64)
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.UI64, isNegative, rawData)
        }
        return UInt64(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal))
    }

    @When[env != "ohos"]
    @OverflowWrapping
    public static func parse(data: String @local?): UInt64 {
        let (rawData, isNegative) = getDataAndFlag(data, false, "UInt64")
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = (FOTMAT_BASE_NUM_UI64_10,
            DECIMAL_OVERFLOW_LIMIT_UI64, MAXVAL_UI64)
        if (rawData.size > 1 && rawData[0] == b'0') {
            (formatBaseNum, multmin, maxAbsVal) = getBaseInfos(TypeBase.UI64, isNegative, rawData)
        }
        return UInt64(parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal))
    }

    /**
     * @Description Convert a string of UInt64 literals to an Option<UInt64> value. If the failure occurs, Option<UInt64>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<UInt64>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    @OverflowWrapping
    public static func tryParse(data: String): Option<UInt64> {
        let (rawData, isNegative) = getTryDataAndFlag(data, false, "UInt64")
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = baseInfosUInt64[isNegative][10]
        if (rawData.size > 1 && rawData[0] == b'0') {
            match (tryGetBaseInfos(TypeBase.UI64, isNegative, rawData)) {
                case Some(info) => (formatBaseNum, multmin, maxAbsVal) = info
                case None => return None
            }
        }
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal)) {
            case Success(n) => UInt64(n)
            case Failure(_) => None
        }
    }
}

extend UInt64 <: RadixConvertible<UInt64> {
    public static func parse(value: String, radix!: Int64): UInt64 {
        let (rawData, isNegative) = getDataAndFlagWithRadix(value, false, "UInt64", radix)
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI64,
            isNegative, radix)
        return parseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)
    }

    public static func tryParse(value: String, radix!: Int64): Option<UInt64> {
        let (rawData, isNegative) = getTryDataAndFlagWithRadix(value, false, "UInt64", radix)
        if (rawData.size == 0) {
            return None
        }
        var (formatBaseNum, multmin, maxAbsVal): (UInt64, UInt64, UInt64) = getBaseInfosWithRadix(TypeBase.UI64,
            isNegative, radix)
        match (tryParseCompInt(rawData, formatBaseNum, multmin, maxAbsVal, isMark: false)) {
            case Success(n) => n
            case Failure(_) => None
        }
    }

    public func toString(radix!: Int64): String {
        if (radix == 10) {
            return this.toString()
        }
        if (radix < 2 || radix > 36) {
            throw IllegalArgumentException("The radix out of range.")
        }
        var nums = match (radix) {
            case 2 | 4 | 8 | 16 | 32 => toRadixString(this, radix)
            case _ => toRadixStringCom(this, radix)
        }
        return "${nums}"
    }
}

func getDataAndFlag(data: String, isSigned: Bool, typeName: String): (Array<Byte>, Int64) {
    checkParseDataNotEmpty(data)
    getDataAndFlagCore(data, isSigned, typeName, false)
}

@When[env != "ohos"]
exclave func getDataAndFlag(data: String @local?, isSigned: Bool, typeName: String): (Array<Byte>, Int64) @local? {
    if (data.isEmpty()) {
        throw IllegalArgumentException("The string is empty.")
    }
    let (rawData, isNegative) = match (data[0]) {
        case '+' => throw IllegalArgumentException("Starting with \"+\" is illegal in ${typeName}.") // r'+'
        case '-' =>
            if (isSigned) {
                (unsafe { data.rawData() }[1..], 0)
            } else {
                throw IllegalArgumentException("Starting with \"-\" is illegal in ${typeName}.")
            }
        case _ => (unsafe { data.rawData() }, 1)
    }
    if (rawData.size == 0) {
        throw IllegalArgumentException("The value part is empty.")
    }
    return (rawData, isNegative)
}

func getTryDataAndFlag(data: String, isSigned: Bool, _: String): (Array<Byte>, Int64) {
    getTryDataAndFlagCore(data, isSigned, false)
}

func getDataAndFlagWithRadix(data: String, isSigned: Bool, typeName: String, radix: Int64): (Array<Byte>, Int64) {
    checkParseDataNotEmpty(data)
    checkParseRadix(radix)
    getDataAndFlagCore(data, isSigned, typeName, true)
}

func getTryDataAndFlagWithRadix(data: String, isSigned: Bool, _: String, radix: Int64): (Array<Byte>, Int64) {
    if (!isValidParseRadix(radix)) {
        return ([], 1)
    }
    getTryDataAndFlagCore(data, isSigned, true)
}

private func checkParseDataNotEmpty(data: String): Unit {
    if (data.isEmpty()) {
        throw IllegalArgumentException("The string is empty.")
    }
}

private func isValidParseRadix(radix: Int64): Bool {
    radix >= 2 && radix <= 36
}

private func checkParseRadix(radix: Int64): Unit {
    if (!isValidParseRadix(radix)) {
        throw IllegalArgumentException("The radix out of range.")
    }
}

private func getDataAndFlagCore(
    data: String,
    isSigned: Bool,
    typeName: String,
    prefixPlusAllowed: Bool
): (Array<Byte>, Int64) {
    let dataBytes = unsafe { data.rawData() }
    let (rawData, isNegative) = match (data[0]) {
        case '+' =>
            if (prefixPlusAllowed) {
                (dataBytes[1..], 1)
            } else {
                throw IllegalArgumentException("Starting with \"+\" is illegal in ${typeName}.") // r'+'
            }
        case '-' =>
            if (isSigned) {
                (dataBytes[1..], 0)
            } else {
                throw IllegalArgumentException("Starting with \"-\" is illegal in ${typeName}.")
            }
        case _ => (dataBytes, 1)
    }
    if (rawData.size == 0) {
        throw IllegalArgumentException("The value part is empty.")
    }
    return (rawData, isNegative)
}

private func getTryDataAndFlagCore(data: String, isSigned: Bool, prefixPlusAllowed: Bool): (Array<Byte>, Int64) {
    if (data.isEmpty()) {
        return ([], 1)
    }
    let dataBytes = unsafe { data.rawData() }
    let (rawData, isNegative) = match (data[0]) {
        case '+' =>
            if (prefixPlusAllowed) {
                (dataBytes[1..], 1)
            } else {
                return ([], 0)
            }
        case '-' =>
            if (isSigned) {
                (dataBytes[1..], 0)
            } else {
                return ([], 0)
            }
        case _ => (dataBytes, 1)
    }
    if (rawData.size == 0) {
        return ([], 1)
    }
    return (rawData, isNegative)
}

func toRadixString(u: UInt64, radix: Int64): String {
    var v: UInt64 = u
    var str = ""
    if (u > 0) {
        while (v > 0) {
            var index = Int64(v & UInt64(radix - 1))
            var tmp = "${DIGITS[index]}"
            str = str + tmp
            v = (v >> MOVE_RADIX[radix])
        }
        let temp = str.toRuneArray()
        temp.reverse()
        return String(temp)
    } else {
        return "0"
    }
}

func toRadixStringCom(u: UInt64, radix: Int64): String {
    var v: UInt64 = u
    var r: UInt64 = UInt64(radix)
    var str = ""
    if (u > 0) {
        while (v >= r) {
            var q = v / r
            var tmp = "${DIGITS[Int64(v - q * r)]}"
            str = str + tmp
            v = q
        }
        str = str + "${DIGITS[Int64(v)]}"
        let temp = str.toRuneArray()
        temp.reverse()
        return String(temp)
    } else {
        return "0"
    }
}

interface FloatParsable<T> {
    static func fromFloat64(n: Float64): T
}

func parseFloat<T>(data: String): T where T <: FloatParsable<T> {
    match (doParseFloat<T>(data)) {
        case Success(n) => n
        case Failure(str) => throw IllegalArgumentException(str)
    }
}

func tryParseFloat<T>(data: String): Option<T> where T <: FloatParsable<T> {
    match (doParseFloat<T>(data)) {
        case Success(n) => Some(n)
        case _ => None
    }
}

func doParseFloat<T>(data: String): ConvertResult<T> where T <: FloatParsable<T> {
    if (data.isEmpty()) {
        return Failure("The string is empty.")
    }
    var inputStr = data.trimAscii()
    if (inputStr.isEmpty()) {
        return Failure("The string does not comply with the floating point number syntax.")
    }
    let trimmedStr = inputStr

    var result: Float64 = 0.0
    var pointNum = 0
    var isNative = false
    var formatBaseNum: Float64 = 10.0
    var digitCount = 0
    match (inputStr[0]) {
        case '-' =>
            isNative = true
            inputStr = inputStr[1..]
        case '+' => inputStr = inputStr[1..]
        case _ => ()
    }
    if (inputStr.isEmpty()) {
        return Failure("The string does not comply with the floating point number syntax.")
    }
    var pointIndex = inputStr.size - 1

    for (index in 0..inputStr.size) {
        if (pointNum > 1) {
            return Failure("The string does not comply with the floating point number syntax.")
        }
        if (inputStr[index] >= b'0' && inputStr[index] <= b'9') {
            result = result * formatBaseNum + Float64(inputStr[index] - b'0')
            digitCount++
        } else if (inputStr[index] == b' ') {
            return Failure("The string does not comply with the floating point number syntax.")
        } else if (inputStr[index] == b'.') {
            pointNum++
            pointIndex = index
            continue
        } else {
            return doParseFloatFromCffi<T>(trimmedStr)
        }
    }
    if (pointNum > 1) {
        return Failure("The string does not comply with the floating point number syntax.")
    }
    if (digitCount == 0) {
        return Failure("The string does not comply with the floating point number syntax.")
    }
    if (digitCount > FLOAT64_MAX_DECIMAL_DIGITS) {
        return doParseFloatFromCffi<T>(trimmedStr)
    }
    
    var df = inputStr.size - pointIndex - 1
    var leftMove: Float64 = 1.0
    for (_ in 0..df) {
        leftMove *= formatBaseNum
    }
    if (isNative) {
        result = -(result / leftMove)
    } else {
        result = result / leftMove
    }
    return Success(T.fromFloat64(result))
}

func doParseFloatFromCffi<T>(data: String): ConvertResult<T> where T <: FloatParsable<T> {
    var result: Float64
    unsafe {
        let cStr = LibC.mallocCString(data)
        let resultPtr = CJ_STRTOD(cStr)
        LibC.free(cStr)
        if (resultPtr.isNull()) {
            return Failure("The string does not comply with the floating point number syntax.")
        }
        result = resultPtr.read()
        LibC.free(resultPtr)
    }
    Success(T.fromFloat64(result))
}

extend Float16 <: FloatParsable<Float16> {
    public static func fromFloat64(n: Float64): Float16 {
        if (n >= Float64(MINVAL_F16) && n <= Float64(MAXVAL_F16)) {
            Float16(n)
        } else if (n > 0.0) {
            Float16_INF
        } else {
            -Float16_INF
        }
    }
}

extend Float32 <: FloatParsable<Float32> {
    public static func fromFloat64(n: Float64): Float32 {
        if (n >= Float64(Float32.Min) && n <= Float64(Float32.Max)) {
            Float32(n)
        } else if (n > 0.0) {
            Float32_INF
        } else {
            -Float32_INF
        }
    }
}

extend Float64 <: FloatParsable<Float64> {
    public static func fromFloat64(n: Float64): Float64 {
        n
    }
}

/*
 * @Description The Float16 is extended to provide the functions of parsing a character string into Float16 type or Option<Float16> type.
 *
 * @since 0.17.4
 */
extend Float16 <: Parsable<Float16> {

    /**
     * @Description Convert a string of Float16 literals to a Float16 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Float16.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string does not comply with the floating point number syntax.
     */
    @Frozen
    public static func parse(data: String): Float16 {
        parseFloat<Float16>(data)
    }

    /**
     * @Description Convert a string of Float16 literals to an Option<Float16> value. If the failure occurs, Option<Float16>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Float16>.
     *
     * @since 0.31.2
     */
    public static func tryParse(data: String): Option<Float16> {
        tryParseFloat<Float16>(data)
    }
}

/*
 * @Description The Float32 is extended to provide the functions of parsing a character string to Float32 type or Option<Float32> type.
 *
 * @since 0.17.4
 */
extend Float32 <: Parsable<Float32> {

    /**
     * @Description Convert a string of Float32 literals to a Float32 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Float32.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string does not comply with the floating point number syntax.
     */
    @Frozen
    public static func parse(data: String): Float32 {
        parseFloat<Float32>(data)
    }

    /**
     * @Description Convert a string of Float32 literals to an Option<Float32> value. If the failure occurs, Option<Float32>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Float32>.
     *
     * @since 0.31.2
     */
    public static func tryParse(data: String): Option<Float32> {
        tryParseFloat<Float32>(data)
    }
}

/*
 * @Description The Float64 is extended to provide the functions of parsing a character string to Float64 type or Option<Float64> type.
 *
 * @since 0.17.4
 */
extend Float64 <: Parsable<Float64> {

    /**
     * @Description Convert a string of Float64 literals to a Float64 value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Float64.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string does not comply with the floating point number syntax.
     */
    @Frozen
    public static func parse(data: String): Float64 {
        parseFloat<Float64>(data)
    }

    @When[env != "ohos"]
    @Frozen
    public static func parse(data: String @local?): Float64 {
        parseFloat<Float64>(String(data))
    }

    /**
     * @Description Convert a string of Float64 literals to an Option<Float64> value. If the failure occurs, Option<Float64>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Float64>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    public static func tryParse(data: String): Option<Float64> {
        tryParseFloat<Float64>(data)
    }
}

/*
 * @Description The Rune is extended to provide the functions of parsing a character string into Rune type or Option<Rune> type.
 *
 * @since 0.17.4
 */
extend Rune <: Parsable<Rune> {

    /**
     * @Description Convert a string of Rune literals to a Rune value. If the failure occurs, Exception will be throwed.
     *
     * @param data of String.
     * @return Parameters of Rune.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if failing to convert to Rune,
     * or if there is an invalid utf8 code in the string.
     */
    public static func parse(data: String): Rune {
        if (data.isEmpty()) {
            throw IllegalArgumentException("The string is empty.")
        }
        (strToChar(data.toRuneArray())) ?? throw IllegalArgumentException("Fail to convert to Rune.")
    }

    /**
     * @Description Convert a string of Rune literals to an Option<Rune> value. If the failure occurs, Option<Rune>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Rune>.
     * @throws IllegalArgumentException if there is an invalid utf8 code in the string
     *
     * @since 0.31.2
     */
    public static func tryParse(data: String): Option<Rune> {
        strToChar(data.toRuneArray())
    }
}

/*
 * @Description The Bool is extended to provide the functions of parsing a character string into Bool type or Option<Bool> type.
 *
 * @since 0.17.4
 */
extend Bool <: Parsable<Bool> {

    /**
     * @Description Convert a string of Boolean literals to a Boolean value. If the failure occurs, IllegalArgumentException will be throwed.
     *
     * @param data of String.
     * @return Parameters of Bool.
     *
     * @since 0.31.2
     *
     * @throws IllegalArgumentException if the string is empty, or if failing to convert to Bool,
     */
    public static func parse(data: String): Bool {
        match (tryParse(data)) {
            case Some(v) => return v
            case None => throw IllegalArgumentException("Fail to convert to Bool.")
        }
    }

    /**
     * @Description Convert a string of Boolean literals to an Option<Bool> value. If the failure occurs, Option<Rune>.None will be returned.
     *
     * @param data of String.
     * @return Parameters of Option<Bool>.
     *
     * @since 0.31.2
     */
    public static func tryParse(data: String): Option<Bool> {
        var strData = unsafe { data.rawData() }
        if (strData.size == 4 && strData[3] == b'e' && strData[2] == b'u' && strData[1] == b'r' && strData[0] == b't') {
            return Some(true)
        }
        if (strData.size == 5 && strData[4] == b'e' && strData[3] == b's' && strData[2] == b'l' && strData[1] == b'a' &&
            strData[0] == b'f') {
            return Some(false)
        }
        return None
    }
}
