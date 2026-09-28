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
 * This is a library for format class.
 */

package std.convert

@FastNative
foreign func CJ_FORMAT_Float64Formatter(a: Float64, format: CString): CString

public interface Formattable {
    func format(fmt: String): String
}

let signed: Bool = true
let unsigned: Bool = false

const MAX_FORMAT_WIDTH: Int64 = 100000 /* Maximum format width to prevent memory exhaustion. */
const MAX_FLOAT_PRECISION: Int64 = 350 /* Maximum float precision; covers Float64's full range (~1.8e308). */

protected enum Flags {
    | NoFlag
    | Minus
    | Plus
    | Sharp
    | Zero

    public operator func ==(right: Flags): Bool {
        let f = (this, right)
        return match (f) {
            case (NoFlag, NoFlag) => true
            case (Minus, Minus) => true
            case (Plus, Plus) => true
            case (Sharp, Sharp) => true
            case (Zero, Zero) => true
            case _ => false
        }
    }

    public operator func !=(right: Flags): Bool {
        return !(this == right)
    }
}

extend Int64 <: Formattable {

    /**
     * Formatting the Int64 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected int format pattern
     */
    @OverflowWrapping
    public func format(fmt: String): String {
        var format = escapeControlCharacters(fmt)
        if (!(Verify(fmt).verifyIntFormatArg())) {
            throw IllegalArgumentException("Wrong format string '" + format + "' for 'Int' type.")
        }
        var fs = parser(format)
        return fs.fmtInteger(UInt64(this), signed)
    }
}

extend Int32 <: Formattable {

    /**
     * Formatting the Int32 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected int format pattern
     */
    public func format(fmt: String): String {
        Int64(this).format(fmt)
    }
}

extend Int16 <: Formattable {

    /**
     * Formatting the Int16 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected int format pattern
     */
    public func format(fmt: String): String {
        return Int64(this).format(fmt)
    }
}

extend Int8 <: Formattable {

    /**
     * Formatting the Int8 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected int format pattern
     */
    public func format(fmt: String): String {
        return Int64(this).format(fmt)
    }
}

extend UInt64 <: Formattable {

    /**
     * Formatting the UInt64 Type
     *
     * @param fmt formatting string.
     * @return formatted string
     *
     * @throws IllegalArgumentException
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected unit format pattern
     */
    @OverflowWrapping
    public func format(fmt: String): String {
        var format = escapeControlCharacters(fmt)
        if (!(Verify(fmt).verifyIntFormatArg())) {
            throw IllegalArgumentException("Wrong format string '" + format + "' for 'UInt' type.")
        }
        var fs = parser(format)
        return fs.fmtInteger(UInt64(this), unsigned)
    }
}

extend UInt32 <: Formattable {

    /**
     * Formatting the UInt32 Type
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected unit format pattern
     */
    public func format(fmt: String): String {
        UInt64(this).format(fmt)
    }
}

extend UInt16 <: Formattable {

    /**
     * Formatting the UInt16 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected unit format pattern
     */
    public func format(fmt: String): String {
        return UInt64(this).format(fmt)
    }
}

extend UInt8 <: Formattable {

    /**
     * Formatting the UInt8 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected unit format pattern
     */
    public func format(fmt: String): String {
        return UInt64(this).format(fmt)
    }
}

extend Float64 <: Formattable {

    /**
     * Formatting the Float64 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected float format pattern
     */
    public func format(fmt: String): String {
        var format = escapeControlCharacters(fmt)
        if (!(Verify(fmt).verifyFloatFormatArg())) {
            throw IllegalArgumentException("Wrong format string '" + format + "' for 'float' type.")
        }
        var fs = parser(format)
        return fs.fmtFloat(this)
    }
}

extend Float32 <: Formattable {

    /**
     * Formatting the Float32 Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected float format pattern
     */
    public func format(fmt: String): String {
        return Float64(this).format(fmt)
    }
}

extend Float16 <: Formattable {

    /**
     * Formatting the Float16 Type
     *
     * @param fmt formatting string.
     * @return formatted string
     *
     * @throws IllegalArgumentException if fmt is not a valid format pattern.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected float format pattern
     */
    public func format(fmt: String): String {
        return Float64(this).format(fmt)
    }
}

extend Rune <: Formattable {

    /**
     * Formatting the Rune Type.
     *
     * @param fmt formatting string.
     * @return formatted string.
     *
     * @since 0.17.4
     *
     * @throws IllegalArgumentException if the `fmt` does not match the expected char format pattern
     */
    public func format(fmt: String): String {
        var format = escapeControlCharacters(fmt)
        if (!(Verify(fmt).verifyCharFormatArg())) {
            throw IllegalArgumentException("Wrong format string '" + format + "' for 'Rune' type.")
        }
        var fs = parser(format)
        return fs.fmtCharacter(this)
    }
}

protected class Verify {
    var data: Array<Rune>
    var size: Int64
    var index: Int64 = 0

    protected init(fmt: String) {
        this.data = fmt.toRuneArray()
        this.size = data.size
    }

    func verifyNumFormatArg(): Bool {
        if (size == 0) {
            return true
        }
        if (anyOf([r'-', r'+', r'#', r'0'])) {
            index++
            if (index == size) {
                return true
            }
        }
        var next = lookAhead()
        if (next >= r'1' && next <= r'9') {
            index++
            parseWidthSign()
            if (index == size) {
                return true
            }
        }
        next = lookAhead()
        if (next == r'.') {
            parsePrecisionSign()
            if (index == size) {
                return true
            }
        }
        return false
    }

    /**
     * Verify the Format Parameter of Int.
     * Based on regular expression of the Int type: ^([-|+|#|0])?([1-9][0-9]*)?(\\.[0-9]+)?([b|B|o|O|x|X])?$
     *
     * @return Bool Whether the format string complies with the format of Int.
     */
    public func verifyIntFormatArg(): Bool {
        if (verifyNumFormatArg()) {
            return true
        }
        if (anyOf([r'b', r'B', r'o', r'O', r'x', r'X'])) {
            index++
        }
        return index == size
    }

    /**
     * Verify the Format Parameter of Float.
     * Based on regular expression of the Float type: ^([-|+|#|0])?([1-9][0-9]*)?(\\.[0-9]+)?([e|E|g|G])?$
     *
     * @return Bool Whether the format string complies with the format of Float.
     */
    public func verifyFloatFormatArg(): Bool {
        if (verifyNumFormatArg()) {
            return true
        }
        if (anyOf([r'e', r'E', r'g', r'G'])) {
            index++
        }
        return index == size
    }

    /**
     * Verify the Format Parameter of Rune.
     * Based on regular expression of the Rune type: ^-?([1-9][0-9]*)?$
     *
     * @return Bool Whether the format string complies with the format of Rune.
     */
    func verifyCharFormatArg(): Bool {
        if (size == 0) {
            return true
        }
        var next = lookAhead()
        if (next == r'-') {
            index++
            if (index == size) {
                return true
            }
        }
        next = lookAhead()
        if (next >= r'1' && next <= r'9') {
            index++
            parseWidthSign()
        }
        return index == size
    }

    func lookAhead(): Rune {
        return data[index]
    }

    func anyOf(arr: Array<Rune>): Bool {
        var next = lookAhead()
        for (i in arr) {
            if (next == i) {
                return true
            }
        }
        return false
    }

    /**
     * Match the Width regular expression.
     * Based on regular expression: [0-9]*
     */
    func parseWidthSign(): Unit {
        for (i in index..size) {
            var temp = data[i]
            if (temp < r'0' || temp > r'9') {
                index = i
                return
            }
            if (i == (size - 1)) {
                index = size
                return
            }
        }
    }

    /**
     * Match the Precision regular expression.
     * Based on regular expression: [0-9]+
     */
    func parsePrecisionSign(): Unit {
        for (i in (index + 1)..size) {
            var temp = data[i]
            if (temp < r'0' || temp > r'9') {
                if (i == (index + 1)) {
                    return
                } else {
                    index = i
                    return
                }
            }
            if (i == (size - 1)) {
                index = size
                return
            }
        }
    }
}

/**
 * Find Flags,Width,Precision and specifier in the format string.
 *
 * @param fmt formatting string.
 * @return formatSpecifier Object.
 *
 * @since 0.17.4
 * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+",
 * or if failing to convert to Int64, or if the value after conversion is out of the Int64 range,
 * or if width exceeds the maximum allowed value (100000),
 * or if precision exceeds the maximum allowed value (350),
 * or if precision string is empty (e.g., format string ends with '.' or contains '.' followed by non-digit characters)
 */
func parser(fmt: String): FormatSpecifier {
    let (flags, width, precision, specifier) = parseFormat(fmt)
    return FormatSpecifier(flags, width, precision, specifier)
}

protected func parseFormat(fmt: String): (Flags, Int64, Int64, Rune) {
    var flags: Flags = Flags.NoFlag
    var width: Int64 = -1
    var precision: Int64 = -1
    var specifier: Rune = ' '
    var fmtCharArray = fmt.toRuneArray()
    if (fmtCharArray.size <= 0) {
        return (flags, width, precision, specifier)
    }
    /* flags */
    var c = fmtCharArray[0]
    flags = getFlags(c)
    var idx = 0
    var end = fmtCharArray.size
    if (flags != Flags.NoFlag && end > 1) {
        idx = 1
    }
    /* width */
    if (fmtCharArray[idx].isAsciiNumber() && idx < end) {
        var start: Int64 = idx
        var len: Int64 = 0
        for (i in idx..end) {
            var c = fmtCharArray[i]
            if (c.isAsciiLetter() || c == r'.') {
                idx = i
                break
            }
            len++
        }
        if (len > 0) {
            idx = start + len
        }
        var str = fmt[start..start + len]
        width = Int64.parse(str)
        if (width > MAX_FORMAT_WIDTH) {
            throw IllegalArgumentException("Format width ${width} exceeds maximum allowed value ${MAX_FORMAT_WIDTH}.")
        }
    }
    /* precision */
    if (idx < end && fmtCharArray[idx] == r'.') {
        idx++
        var start = idx
        var len = 0
        for (i in idx..end) {
            var c = fmtCharArray[i]
            if (c.isAsciiLetter()) {
                idx = i
                break
            }
            len++
        }
        if (len == 0) {
            throw IllegalArgumentException("Empty precision string in format.")
        }
        idx = start + len
        var str = fmt[start..start + len]
        precision = Int64.parse(str)
    }
    /* specifier */
    if (idx < end && fmtCharArray[idx].isAsciiLetter()) {
        specifier = fmtCharArray[idx]
    }
    return (flags, width, precision, specifier)
}

func getFlags(c: Rune): Flags {
    return match (c) {
        case r'-' => Flags.Minus
        case r'+' => Flags.Plus
        case r'#' => Flags.Sharp
        case r'0' => Flags.Zero
        case _ => Flags.NoFlag
    }
}

/**
 * Handling escape characters.
 * ‘t’ | ‘b’ | ‘r’ | ‘n’ | ‘’’ | ‘”’ | ‘\’ | ‘f’ | ‘v’ | ‘0’ | ‘$'
 * @param str formatted string.
 * @return String Object.
 *
 * @since 0.17.4
 */
protected func escapeControlCharacters(str: String): String {
    var tmp = ""
    for (c in str.runes()) {
        var val = match (c) {
            case r'\t' => "\\t"
            case r'\b' => "\\b"
            case r'\r' => "\\r"
            case r'\n' => "\\n"
            case r'\f' => "\\f"
            case r'\v' => "\\v"
            case r'\0' => "\\0"
            case _ => escapeOtherControlChar(c)
        }
        tmp = tmp + val
    }
    return tmp
}

func escapeOtherControlChar(c: Rune): String {
    let code = UInt32(c)
    if (code == 0x1B) {
        "\\x1b"
    } else if (code == 0x7F) {
        "\\x7f"
    } else if (code >= 0x01 && code <= 0x07) {
        "\\x" + toHexLower(code)
    } else if (code >= 0x0E && code <= 0x1F) {
        "\\x" + toHexLower(code)
    } else {
        "${c}"
    }
}

func toHexLower(n: UInt32): String {
    let hexChars = "0123456789abcdef".toRuneArray()
    let high = Int64((n >> 4) & 0x0F)
    let low = Int64(n & 0x0F)
    let a: Rune = hexChars[high]
    let b: Rune = hexChars[low]
    return "${a}${b}"
}

class FormatSpecifier {

    /* Hexadecimal lowercase */
    private let ldigits = "0123456789abcdef".toRuneArray()

    /* Hexadecimal uppercase */
    private let udigits = "0123456789ABCDEF".toRuneArray()

    /* flags */
    private let flags: Flags

    /* width */
    private let width: Int64

    /* precision */
    private let precision: Int64

    /* specifier */
    private let specifier: Rune

    /**
     * Constructor.
     *
     * @param flags flags.
     * @param width width.
     * @param precision precision.
     * @param specifier specifier.
     *
     * @since 0.17.4
     */
    init(flags: Flags, width: Int64, precision: Int64, specifier: Rune) {
        this.flags = flags
        this.width = width
        this.precision = precision
        this.specifier = specifier
    }

    /**
     * Formats a signed or unsigned integer.
     *
     * @param arg formatting parameter.
     * @param isSigned signed or not.
     * @return String after integer formatting.
     *
     * @since 0.17.4
     * @throws IllegalArgumentException if the string is empty, or if the string is starting with "+" or "-",
     * or if failing to convert to UInt64, or if the value after conversion is out of the UInt64 range
     */
    @OverflowWrapping
    func fmtInteger(arg: UInt64, isSigned: Bool): String {
        var u: UInt64 = 0
        var negative = isSigned && Int64(arg) < 0
        /* Obtains the absolute value of the arg parameter. */
        if (negative) {
            var intVal = Int64(arg)
            var s = "${intVal}"
            s = s[1..]
            u = UInt64.parse(s)
        } else {
            u = arg
        }
        var val = convertNumberSystem(u)
        var len = val.size
        if (precision != -1) {
            var tmp = ""
            if (len < precision) {
                var sp = precision - len
                for (_ in 0..sp) {
                    tmp = tmp + "0"
                }
                val = tmp + val
            }
        }
        var prefix = ""
        if (flags == Flags.Sharp) {
            prefix = getPrefixFromSharp()
        } else if ((flags == Flags.Plus) && !negative) {
            prefix = "+"
        } else if (flags == Flags.Zero) {
            prefix = paddingZero(negative, len)
        }
        val = prefix + val
        if (negative) {
            val = "-" + val
        }
        val = writePadding(val)
        return val
    }

    func convertNumberSystem(u: UInt64): String {
        return match (specifier) {
            case r'b' | r'B' => toBinaryString(u)
            case r'o' | r'O' => toOctalString(u)
            case r'x' => toHexString(u, false)
            case r'X' => toHexString(u, true)
            case r' ' => "${u}"
            case _ => ""
        }
    }

    func getPrefixFromSharp(): String {
        return match (specifier) {
            case r'b' => "0b"
            case r'B' => "0B"
            case r'o' => "0o"
            case r'O' => "0O"
            case r'x' => "0x"
            case r'X' => "0X"
            case _ => ""
        }
    }

    func paddingZero(negative: Bool, len: Int64): String {
        var sp = 0
        if (precision == -1) {
            var tmp = ""
            if (negative) {
                sp = width - len - 1
            } else {
                sp = width - len
            }
            if (sp > 0) {
                for (_ in 0..sp) {
                    tmp = tmp + "0"
                }
                return tmp
            }
        }
        return ""
    }

    /**
     * Formats floating-point number.
     *
     * @param arg formatting parameter.
     * @return formatted string after float formatting.
     * throws IllegalMemoryException if there are some system errors.
     *
     * @since 0.17.4
     */
    func fmtFloat(arg: Float64): String {
        if (precision > MAX_FLOAT_PRECISION) {
            throw IllegalArgumentException(
                "Format precision ${precision} exceeds maximum allowed value ${MAX_FLOAT_PRECISION}.")
        }
        var negative = false
        var str = "${arg}".toRuneArray()
        /* Negative numbers, including -0.0 */
        if (str[0] == r'-') {
            negative = true
        }
        var u = arg
        if (negative) {
            u = -u
        }
        var prec = precision
        if (precision == -1) {
            prec = 6
        }
        var val = match (specifier) {
            case r'g' => toGeneralString(u, false, prec)
            case r'G' => toGeneralString(u, true, prec)
            case r'e' => toScientificString(u, false, prec)
            case r'E' => toScientificString(u, true, prec)
            case r' ' => toDecimalString(u, prec)
            case _ => ""
        }
        if (negative && val.size > 0 && val[0] == 45) {
            negative = false
        }
        var prefix = ""
        var len = val.size
        if ((flags == Flags.Plus) && !negative) {
            prefix = "+"
        }
        if (flags == Flags.Zero) {
            var sp = 0
            if (negative) {
                sp = width - len - 1
            } else {
                sp = width - len
            }
            var tmp = ""
            if (sp > 0) {
                for (_ in 0..sp) {
                    tmp = tmp + "0"
                }
                prefix = tmp
            }
        }
        val = prefix + val
        if (negative) {
            val = "-" + val
        }
        val = writePadding(val)
        return val
    }

    func fmtCharacter(arg: Rune): String {
        var val = "${arg}"
        return writePadding(val)
    }

    /*
     * Generates n bytes of padding.
     *
     * @param s original string.
     * @return padded string.
     *
     * @since 0.17.4
     */
    private func writePadding(s: String): String {
        var sCharArray = s.toRuneArray()
        var result = ""
        var pad = (flags == Flags.Minus)
        var sp = width - sCharArray.size
        if (sp > 0) {
            var arr = Array<Rune>(sp, repeat: r' ')
            var padString = String(arr)
            if (!pad) {
                result = padString + s
            } else {
                result = s + padString
            }
        } else {
            result = s
        }
        return result
    }

    /*
     * Returns a string representation of the argument as an unsigned integer in base 2.
     *
     * @param u original number.
     * @return binary string.
     *
     * @since 0.17.4
     */
    private func toBinaryString(u: UInt64): String {
        var v: UInt64 = u
        var str = ""
        if (u > 0) {
            while (v > 0) {
                var a = Int8(v & 1)
                var tmp = "${a}"
                str = str + tmp
                v = (v >> 1)
            }
            let temp = str.toRuneArray()
            temp.reverse()
            return String(temp)
        } else {
            return "0"
        }
    }

    /*
     * Returns a string representation of the argument as an unsigned integer in base 8.
     *
     * @param u original number.
     * @return octal string.
     *
     * @since 0.17.4
     */
    private func toOctalString(u: UInt64): String {
        if (u == 0) {
            return "0"
        }
        var v: UInt64 = u
        var str = ""
        while (v != 0) {
            var a = Int8(v & 7)
            var tmp = "${a}"
            str = str + tmp
            v = (v >> 3)
        }
        let temp = str.toRuneArray()
        temp.reverse()
        return String(temp)
    }

    /*
     * Returns a string representation of the argument as an unsigned integer in base 16.
     *
     * @param u original number.
     * @param isUpper uppercase or not.
     * @return hex string.
     *
     * @since 0.17.4
     */
    private func toHexString(u: UInt64, isUpper: Bool): String {
        var v: UInt64 = u
        if (u > 0) {
            let sb = StringBuilder()
            while (v > 0) {
                var index = Int64(v & 0xF)
                let a: Rune = if (isUpper) {
                    udigits[index]
                } else {
                    ldigits[index]
                }
                sb.append(a)
                v >>= 4
            }
            let temp = sb.toString().toRuneArray()
            temp.reverse()
            return String(temp)
        } else {
            return "0"
        }
    }

    /*
     * Conversion of floating-point numbers to scientific notation.
     *
     * @param u original float number.
     * @Param isUpper uppercase or not.
     * @Param precision precision.
     * @return scientific notation string.
     * @throws IllegalMemoryException if failed to call float64Formatter.
     *
     * @since 0.17.4
     */
    private func toScientificString(u: Float64, isUpper: Bool, precision: Int64): String {
        var v: Float64 = u
        var fmt = ""
        if (isUpper) {
            fmt = "%.${precision}E"
        } else {
            fmt = "%.${precision}e"
        }
        return float64Formatter(v, fmt)
    }

    /*
     * Conversion of floating-point numbers to General string.
     *
     * @param u original float number.
     * @Param isUpper uppercase or not.
     * @Param precision Precision.
     * @return general string.
     * @throws IllegalMemoryException if failed to call float64Formatter.
     *
     * @since 0.17.4
     */
    private func toGeneralString(u: Float64, isUpper: Bool, precision: Int64): String {
        var v: Float64 = u
        var fmt = ""
        if (isUpper) {
            fmt = "%.${precision}G"
        } else {
            fmt = "%.${precision}g"
        }
        return float64Formatter(v, fmt)
    }

    /*
     * Converting a Floating-Point Number to a Decimal Type.
     *
     * @param u original float number.
     * @Param precision precision.
     * @return general string.
     * @throws IllegalMemoryException if failed to call float64Formatter.
     *
     * @since 0.17.4
     */
    private func toDecimalString(u: Float64, precision: Int64): String {
        var v: Float64 = u
        var fmt = "%.${precision}f"
        return float64Formatter(v, fmt)
    }

    /*
     * Formating floating-point numbers.
     *
     * @param a original float number.
     * @Param format formatting string.
     * @return formatted string.
     * @throws IllegalMemoryException if malloc failed.
     *
     * @since 0.17.4
     */
    private func float64Formatter(a: Float64, format: String): String {
        var f = unsafe { LibC.mallocCString(format) }
        var res: CString = unsafe { CJ_FORMAT_Float64Formatter(a, f) }
        unsafe { LibC.free(f) }
        if (res.isNull()) {
            throw IllegalMemoryException("Failed to allocate memory.")
        }
        try {
            return res.toString()
        } finally {
            unsafe { LibC.free(res) }
        }
    }
}
