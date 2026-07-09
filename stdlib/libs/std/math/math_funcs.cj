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
 * This is a library for math class.
 */

package std.math

/**
 * Returns the cube root of the value.
 * The cube root of a positive value is the positive number
 * of the cube root of the size of the value.
 * That is, the cube root of a negative value is the negative number
 * of the cube root of the size of the value.
 * special cases that arise:
 * If the argument is NaN, the result is NaN.
 * If the argument is infinite, the result is infinity.
 *
 * @param x some value.
 * @return the cube root of @p x.
 *
 * @since 0.17.4
 */
public func cbrt(x: Float64): Float64 {
    unsafe { return CJ_MATH_Cbrt(x) }
}

/**
 * Returns the cube root of the value.
 * The cube root of a positive value is the positive number
 * of the cube root of the size of the value.
 * That is, the cube root of a negative value is the negative number
 * of the cube root of the size of the value.
 * special cases that arise:
 * If the argument is NaN, the result is NaN.
 * If the argument is infinite, the result is infinity.
 *
 * @param x some value.
 * @return the cube root of @p x.
 *
 * @since 0.17.4
 */
public func cbrt(x: Float32): Float32 {
    unsafe { return CJ_MATH_Cbrtf(x) }
}

/**
 * Returns the cube root of the value.
 * The cube root of a positive value is the positive number
 * of the cube root of the size of the value.
 * That is, the cube root of a negative value is the negative number
 * of the cube root of the size of the value.
 * special cases that arise:
 * If the argument is NaN, the result is NaN.
 * If the argument is infinite, the result is infinity.
 *
 * @param x some value.
 * @return the cube root of @p x.
 *
 * @since 0.17.4
 */
public func cbrt(x: Float16): Float16 {
    unsafe { return Float16(CJ_MATH_Cbrt(Float64(x))) }
}

/**
 * Returns the x logarithm of the base of a value.
 * special cases that arise:
 * If the base is 2.
 * @see func log2(x)
 *
 * If the base is 10.
 * @see func log10(x)
 *
 * If the base is e.
 * @see func log(x)
 *
 * @param x some value.
 * @param base base value.
 * @return \f$ \log_{base} {x} \f$
 *
 * @throws IllegalArgumentException if the argument `x` or `base` is not positive, or the `base` is 1.0
 *
 * @since 0.17.4
 */
public func logBase(x: Float32, base: Float32): Float32 {
    if (x <= 0.0 || base <= 0.0 || base == 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return log(x) / log(base) }
}

/**
 * Returns the x logarithm of the base of a value.
 * special cases that arise:
 * If the base is 2.
 * @see func log2(x)
 *
 * If the base is 10.
 * @see func log10(x)
 *
 * If the base is e.
 * @see func log(x)
 *
 * @param x some value.
 * @param base base value.
 * @return \f$ \log_{base} {x} \f$
 *
 * @throws IllegalArgumentException if the argument `x` or `base` is not positive, or the `base` is 1.0
 *
 * @since 0.17.4
 */
public func logBase(x: Float64, base: Float64): Float64 {
    if (x <= 0.0 || base <= 0.0 || base == 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    return unsafe { log(x) / log(base) }
}

/**
 * Returns the x logarithm of the base of a value.
 * special cases that arise:
 * If the base is 2.
 * @see func log2(x)
 *
 * If the base is 10.
 * @see func log10(x)
 *
 * If the base is e.
 * @see func log(x)
 *
 * @param x some value.
 * @param base base value.
 * @return \f$ \log_{base} {x} \f$
 *
 * @throws IllegalArgumentException if the argument `x` or `base` is not positive, or the `base` is 1.0
 *
 * @since 0.17.4
 */
public func logBase(x: Float16, base: Float16): Float16 {
    if (x <= 0.0 || base <= 0.0 || base == 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return log(x) / log(base) }
}

/**
 * Returns the gamma function value of @p x.
 *
 * @param x some value.
 * @return the gamma function value of @p x.
 *
 * @since 0.17.4
 */
public func gamma(x: Float64): Float64 {
    unsafe { return CJ_MATH_Tgamma(x) }
}

/**
 * Returns the gamma function value of @p x.
 *
 * @param x some value.
 * @return the gamma function value of @p x.
 *
 * @since 0.17.4
 */
public func gamma(x: Float32): Float32 {
    unsafe { return CJ_MATH_Tgammaf(x) }
}

/**
 * Returns the gamma function value of @p x.
 *
 * @param x some value.
 * @return the gamma function value of @p x.
 *
 * @since 0.17.4
 */
public func gamma(x: Float16): Float16 {
    unsafe { return Float16(CJ_MATH_Tgamma(Float64(x))) }
}

/**
 * Returns the Gauss error function of @p x.
 * The related definition is: \f$ {erf} x={\frac {2}{\sqrt {\pi }}}\int _{0}^{x}e^{-t^{2}}\,dt \f$
 *
 * @param x some value.
 * @return the Gauss error function of @p x.
 *
 * @since 0.17.4
 */
public func erf(x: Float64): Float64 {
    unsafe { return CJ_MATH_Erf(x) }
}

/**
 * Returns the Gauss error function of @p x.
 * The related definition is: \f$ {erf} x={\frac {2}{\sqrt {\pi }}}\int _{0}^{x}e^{-t^{2}}\,dt \f$
 *
 * @param x some value.
 * @return the Gauss error function of @p x.
 *
 * @since 0.17.4
 */
public func erf(x: Float32): Float32 {
    unsafe { return CJ_MATH_Erff(x) }
}

/**
 * Returns the Gauss error function of @p x.
 * The related definition is: \f$ {erf} x={\frac {2}{\sqrt {\pi }}}\int _{0}^{x}e^{-t^{2}}\,dt \f$
 *
 * @param x some value.
 * @return the Gauss error function of @p x.
 *
 * @since 0.17.4
 */
public func erf(x: Float16): Float16 {
    unsafe { return Float16(CJ_MATH_Erf(Float64(x))) }
}

/********************* Trigonometric functions *********************/

/**
 * Returns the trigonometric tangent of an angle.
 *
 * @param x an angle, in radians.
 * @return the tangent of @p x.
 *
 * @since 0.17.4
 */
public func tan(x: Float64): Float64 {
    unsafe { return CJ_MATH_Tan(x) }
}

/**
 * Returns the trigonometric tangent of an angle.
 *
 * @param x an angle, in radians.
 * @return the tangent of @p x.
 *
 * @since 0.17.4
 */
public func tan(x: Float32): Float32 {
    unsafe { return CJ_MATH_Tanf(x) }
}

/**
 * Returns the trigonometric tangent of an angle.
 *
 * @param x an angle, in radians.
 * @return the tangent of @p x.
 *
 * @since 0.17.4
 */
public func tan(x: Float16): Float16 {
    unsafe { return Float16(CJ_MATH_Tan(Float64(x))) }
}

/**
 * Returns the arc sine of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc sine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func asin(x: Float64): Float64 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Asin(x) }
}

/**
 * Returns the arc sine of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc sine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func asin(x: Float32): Float32 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Asinf(x) }
}

/**
 * Returns the arc sine of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc sine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func asin(x: Float16): Float16 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return Float16(CJ_MATH_Asin(Float64(x))) }
}

/**
 * Returns the arc cosine of a value, the returned angle is in the range 0.0 through π.
 *
 * @param x some value.
 * @return the arc cosine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func acos(x: Float64): Float64 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Acos(x) }
}

/**
 * Returns the arc cosine of a value, the returned angle is in the range 0.0 through π.
 *
 * @param x some value.
 * @return the arc cosine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func acos(x: Float32): Float32 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Acosf(x) }
}

/**
 * Returns the arc cosine of a value; the returned angle is in the range 0.
 *
 * @param Float16 of x.
 * @return Float16 type of number.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is larger than 1.0 or less than -1.0
 */
public func acos(x: Float16): Float16 {
    if (x > 1.0 || x < -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return Float16(CJ_MATH_Acos(Float64(x))) }
}

/**
 * Returns the arc tangent of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc tangent of @p x.
 *
 * @since 0.17.4
 */
public func atan(x: Float64): Float64 {
    unsafe { return CJ_MATH_Atan(x) }
}

/**
 * Returns the arc tangent of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc tangent of @p x.
 *
 * @since 0.17.4
 */
public func atan(x: Float32): Float32 {
    unsafe { return CJ_MATH_Atanf(x) }
}

/**
 * Returns the arc tangent of a value, the returned angle is in the range -π/2 through π/2.
 *
 * @param x some value.
 * @return the arc tangent of @p x.
 *
 * @since 0.17.4
 */
public func atan(x: Float16): Float16 {
    unsafe { return Float16(CJ_MATH_Atan(Float64(x))) }
}

/********************* Hiberbolic functions *********************/

/**
 * Returns the hyperbolic sine of a float64 value.
 *
 * @param x some value.
 * @return the hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func sinh(x: Float64): Float64 {
    if (x.isNaN()) {
        return Float64.NaN
    }
    unsafe { return CJ_MATH_Sinh(x) }
}

/**
 * Returns the hyperbolic sine of a float32 value.
 *
 * @param x some value.
 * @return the hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func sinh(x: Float32): Float32 {
    if (x.isNaN()) {
        return Float32.NaN
    }
    unsafe { return CJ_MATH_Sinhf(x) }
}

/**
 * Returns the hyperbolic sine of a float16 value.
 *
 * @param x some value.
 * @return the hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func sinh(x: Float16): Float16 {
    if (x.isNaN()) {
        return Float16.NaN
    }
    unsafe { return Float16(CJ_MATH_Sinh(Float64(x))) }
}

/**
 * Returns the hyperbolic cosine of a float64 value.
 *
 * @param x some value.
 * @return the hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 */
public func cosh(x: Float64): Float64 {
    if (x.isNaN()) {
        return Float64.NaN
    }
    unsafe { return CJ_MATH_Cosh(x) }
}

/**
 * Returns the hyperbolic cosine of a float32 value.
 *
 * @param x some value.
 * @return the hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 */
public func cosh(x: Float32): Float32 {
    if (x.isNaN()) {
        return Float32.NaN
    }
    unsafe { return Float32(CJ_MATH_Cosh(Float64(x))) }
}

/**
 * Returns the hyperbolic cosine of a float16 value.
 *
 * @param x some value.
 * @return the hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 */
public func cosh(x: Float16): Float16 {
    if (x.isNaN()) {
        return Float16.NaN
    }
    unsafe { return Float16(CJ_MATH_Cosh(Float64(x))) }
}

/**
 * Returns the hyperbolic tangent of a float64 value.
 *
 * @param x some value.
 * @return the hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 */
public func tanh(x: Float64): Float64 {
    if (x.isNaN()) {
        return Float64.NaN
    }
    unsafe { return CJ_MATH_Tanh(x) }
}

/**
 * Returns the hyperbolic tangent of a float32 value.
 *
 * @param x some value.
 * @return the hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 */
public func tanh(x: Float32): Float32 {
    if (x.isNaN()) {
        return Float32.NaN
    }
    unsafe { return CJ_MATH_Tanhf(x) }
}

/**
 * Returns the hyperbolic tangent of a float16 value.
 *
 * @param x some value.
 * @return the hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 */
public func tanh(x: Float16): Float16 {
    if (x.isNaN()) {
        return Float16.NaN
    }
    unsafe { return Float16(CJ_MATH_Tanh(Float64(x))) }
}

/**
 * Returns the inverse hyperbolic sine of a float64 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func asinh(x: Float64): Float64 {
    if (x.isNaN()) {
        return Float64.NaN
    }
    unsafe { return CJ_MATH_Asinh(x) }
}

/**
 * Returns the inverse hyperbolic sine of a float32 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func asinh(x: Float32): Float32 {
    if (x.isNaN()) {
        return Float32.NaN
    }
    unsafe { return CJ_MATH_Asinhf(x) }
}

/**
 * Returns the inverse hyperbolic sine of a float16 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic sine of @p x.
 *
 * @since 0.17.4
 */
public func asinh(x: Float16): Float16 {
    if (x.isNaN()) {
        return Float16.NaN
    }
    unsafe { return Float16(CJ_MATH_Asinh(Float64(x))) }
}

/**
 * Returns the inverse hyperbolic cosine of a float64 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is less than 1.0
 */
public func acosh(x: Float64): Float64 {
    if (x < 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Acosh(x) }
}

/**
 * Returns the inverse hyperbolic cosine of a float32 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is less than 1.0
 */
public func acosh(x: Float32): Float32 {
    if (x < 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Acoshf(x) }
}

/**
 * Returns the inverse hyperbolic cosine of a float16 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic cosine of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is less than 1.0
 */
public func acosh(x: Float16): Float16 {
    if (x < 1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return Float16(CJ_MATH_Acosh(Float64(x))) }
}

/**
 * Returns the inverse hyperbolic tangent of a float64 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is not larger than -1.0 and less than 1.0
 */
public func atanh(x: Float64): Float64 {
    if (x >= 1.0 || x <= -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Atanh(x) }
}

/**
 * Returns the inverse hyperbolic tangent of a float32 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is not larger than -1.0 and less than 1.0
 */
public func atanh(x: Float32): Float32 {
    if (x >= 1.0 || x <= -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return CJ_MATH_Atanhf(x) }
}

/**
 * Returns the inverse hyperbolic tangent of a float16 value.
 *
 * @param x some value.
 * @return the inverse hyperbolic tangent of @p x.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `x` is not in range (-1.0, 1.0)
 */
public func atanh(x: Float16): Float16 {
    if (x >= 1.0 || x <= -1.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    unsafe { return Float16(CJ_MATH_Atanh(Float64(x))) }
}

/**
 * bit manipulation
 */

/**
 * Number of leading zero bits
 */
var uint8len: Array<Int64> = [0x00, 0x01, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
    0x04, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x06, 0x06,
    0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
    0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
    0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
    0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
    0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08]

/**
 * Poptab for Int8-of array
 */
var poptab: Array<Int64> = [0x00, 0x01, 0x01, 0x02, 0x01, 0x02, 0x02, 0x03, 0x01, 0x02, 0x02, 0x03, 0x02, 0x03, 0x03,
    0x04, 0x01, 0x02, 0x02, 0x03, 0x02, 0x03, 0x03, 0x04, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x01, 0x02,
    0x02, 0x03, 0x02, 0x03, 0x03, 0x04, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x02, 0x03, 0x03, 0x04, 0x03,
    0x04, 0x04, 0x05, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x01, 0x02, 0x02, 0x03, 0x02, 0x03, 0x03, 0x04,
    0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x03, 0x04, 0x04,
    0x05, 0x04, 0x05, 0x05, 0x06, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05,
    0x05, 0x06, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x04, 0x05, 0x05, 0x06, 0x05, 0x06, 0x06, 0x07, 0x01,
    0x02, 0x02, 0x03, 0x02, 0x03, 0x03, 0x04, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x02, 0x03, 0x03, 0x04,
    0x03, 0x04, 0x04, 0x05, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04,
    0x05, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x04, 0x05,
    0x05, 0x06, 0x05, 0x06, 0x06, 0x07, 0x02, 0x03, 0x03, 0x04, 0x03, 0x04, 0x04, 0x05, 0x03, 0x04, 0x04, 0x05, 0x04,
    0x05, 0x05, 0x06, 0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x04, 0x05, 0x05, 0x06, 0x05, 0x06, 0x06, 0x07,
    0x03, 0x04, 0x04, 0x05, 0x04, 0x05, 0x05, 0x06, 0x04, 0x05, 0x05, 0x06, 0x05, 0x06, 0x06, 0x07, 0x04, 0x05, 0x05,
    0x06, 0x05, 0x06, 0x06, 0x07, 0x05, 0x06, 0x06, 0x07, 0x06, 0x07, 0x07, 0x08]

/**
 * Revtab for Int8 of array
 */
var revtab: Array<UInt8> = [0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0, 0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70,
    0xf0, 0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8, 0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8, 0x04, 0x84,
    0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4, 0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4, 0x0c, 0x8c, 0x4c, 0xcc, 0x2c,
    0xac, 0x6c, 0xec, 0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc, 0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,
    0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2, 0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea, 0x1a, 0x9a, 0x5a,
    0xda, 0x3a, 0xba, 0x7a, 0xfa, 0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6, 0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6,
    0x76, 0xf6, 0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee, 0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe, 0x01,
    0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1, 0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1, 0x09, 0x89, 0x49, 0xc9,
    0x29, 0xa9, 0x69, 0xe9, 0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9, 0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65,
    0xe5, 0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5, 0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed, 0x1d, 0x9d,
    0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd, 0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3, 0x13, 0x93, 0x53, 0xd3, 0x33,
    0xb3, 0x73, 0xf3, 0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb, 0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
    0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7, 0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7, 0x0f, 0x8f, 0x4f,
    0xcf, 0x2f, 0xaf, 0x6f, 0xef, 0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff]
/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param xx some value.
 * @return number of zero bits before the most significant bit of @p xx.
 *
 * @since 0.17.4
 */
public func leadingZeros(x: UInt64): Int64 {
    var n: Int64 = 0
    var xx = x
    if (xx > UInt64(UInt32.Max)) {
        n = n + 32
        xx = xx >> UInt64(32)
    }
    if (xx > UInt64(UInt16.Max)) {
        n = n + 16
        xx = xx >> UInt64(16)
    }
    if (xx > UInt64(UInt8.Max)) {
        n = n + 8
        xx = xx >> UInt64(8)
    }
    return 64 - n - uint8len[Int64(xx)]
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param xx some value.
 * @return number of zero bits before the most significant bit of @p xx.
 *
 * @since 0.17.4
 */
public func leadingZeros(x: UInt32): Int64 {
    var n: Int64 = 0
    var xx = x
    if (xx > UInt32(UInt16.Max)) {
        n = n + 16
        xx = xx >> UInt32(16)
    }
    if (xx > UInt32(UInt8.Max)) {
        n = n + 8
        xx = xx >> UInt32(8)
    }
    return 32 - n - uint8len[Int64(xx)]
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param xx some value.
 * @return number of zero bits before the most significant bit of @p xx.
 *
 * @since 0.17.4
 */
public func leadingZeros(x: UInt16): Int64 {
    var n: Int64 = 0
    var xx = x
    if (xx > UInt16(UInt8.Max)) {
        xx = xx >> UInt16(8)
        n = n + 8
    }
    return 16 - n - uint8len[Int64(xx)]
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param x some value.
 * @return number of zero bits before the most significant bit of @p xx.
 *
 * @since 0.17.4
 */
public func leadingZeros(x: UInt8): Int64 {
    return 8 - uint8len[Int64(x)]
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param x some value.
 * @return number of zero bits before the most significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func leadingZeros(x: Int8): Int64 {
    return if (x >= 0) {
        leadingZeros(UInt8(x))
    } else if (x == Int8.Min) {
        0x0
    } else {
        leadingZeros(UInt8(-x) + UInt8(Int8.Min))
    }
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param x some value.
 * @return number of zero bits before the most significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func leadingZeros(x: Int16): Int64 {
    return if (x >= 0) {
        leadingZeros(UInt16(x))
    } else if (x == Int16.Min) {
        0x0
    } else {
        leadingZeros(UInt16(-x) + UInt16(Int16.Min))
    }
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param x some value.
 * @return number of zero bits before the most significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func leadingZeros(x: Int32): Int64 {
    return if (x >= 0) {
        leadingZeros(UInt32(x))
    } else if (x == Int32.Min) {
        0x0
    } else {
        leadingZeros(UInt32(-x) + UInt32(Int32.Min))
    }
}

/**
 * Number of zero bits returned before the most significant (leftmost) bit.
 *
 * @param x some value.
 * @return number of zero bits before the most significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func leadingZeros(x: Int64): Int64 {
    return if (x >= 0) {
        leadingZeros(UInt64(x))
    } else if (x == Int64.Min) {
        0x0
    } else {
        leadingZeros(UInt64(-x) + UInt64(Int64.Min))
    }
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.17.4
 */
public func trailingZeros(x: UInt64): Int64 {
    if (x == 0) {
        return 64
    }

    var t = x & (!x + 1)
    var count: Int64 = 0
    while (t > 1) {
        t = t / 2
        count = count + 1
    }

    return count
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.17.4
 */
public func trailingZeros(x: UInt32): Int64 {
    if (x == 0) {
        return 32
    }

    return trailingZeros(UInt64(x))
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.17.4
 */
public func trailingZeros(x: UInt16): Int64 {
    if (x == 0) {
        return 16
    }

    return trailingZeros(UInt64(x))
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.17.4
 */
public func trailingZeros(x: UInt8): Int64 {
    if (x == 0) {
        return 8
    }

    return trailingZeros(UInt64(x))
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func trailingZeros(x: Int8): Int64 {
    return if (x >= 0) {
        trailingZeros(UInt8(x))
    } else if (x == Int8.Min) {
        0x7
    } else {
        trailingZeros(UInt8(-x) + UInt8(Int8.Min))
    }
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func trailingZeros(x: Int16): Int64 {
    return if (x >= 0) {
        trailingZeros(UInt16(x))
    } else if (x == Int16.Min) {
        0xF
    } else {
        trailingZeros(UInt16(-x) + UInt16(Int16.Min))
    }
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func trailingZeros(x: Int32): Int64 {
    return if (x >= 0) {
        trailingZeros(UInt32(x))
    } else if (x == Int32.Min) {
        0x1F
    } else {
        trailingZeros(UInt32(-x) + UInt32(Int32.Min))
    }
}

/**
 * Obtains the number of consecutive 0s starting from the least significant bits.
 *
 * @param x some value.
 * @return number of consecutive 0s starting from the least significant bit of @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func trailingZeros(x: Int64): Int64 {
    return if (x >= 0) {
        trailingZeros(UInt64(x))
    } else if (x == Int64.Min) {
        0x3F
    } else {
        trailingZeros(UInt64(-x) + UInt64(Int64.Min))
    }
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.17.4
 */
public func countOnes(x: UInt64): Int64 {
    return countOnes(UInt32(x >> 32)) + countOnes(UInt32(x & 0xFFFFFFFF))
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.17.4
 */
public func countOnes(x: UInt32): Int64 {
    return countOnes(UInt16(x >> 16)) + countOnes(UInt16(x & 0xFFFF))
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.17.4
 */
public func countOnes(x: UInt16): Int64 {
    return poptab[Int64(x >> 8)] + poptab[Int64(x & 0xFF)]
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.17.4
 */
public func countOnes(x: UInt8): Int64 {
    return poptab[Int64(x)]
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func countOnes(x: Int8): Int64 {
    return countOnes(UInt8(x))
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func countOnes(x: Int16): Int64 {
    return countOnes(UInt16(x))
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func countOnes(x: Int32): Int64 {
    return countOnes(UInt32(x))
}

/**
 * Calculate the number of one.
 *
 * @param x some value.
 * @return the number of one in @p x.
 *
 * @since 0.18.4
 */
@OverflowWrapping
public func countOnes(x: Int64): Int64 {
    return countOnes(UInt64(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: Int8): Int64` instead."]
public func countOne(x: Int8): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: Int16): Int64` instead."]
public func countOne(x: Int16): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: Int32): Int64` instead."]
public func countOne(x: Int32): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: Int64): Int64` instead."]
public func countOne(x: Int64): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: UInt8): Int64` instead."]
public func countOne(x: UInt8): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: UInt16): Int64` instead."]
public func countOne(x: UInt16): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: UInt32): Int64` instead."]
public func countOne(x: UInt32): Int8 {
    Int8(countOnes(x))
}

@Deprecated[message: "Use global funtion `public func countOnes(x: UInt64): Int64` instead."]
public func countOne(x: UInt64): Int8 {
    Int8(countOnes(x))
}

/**
 * Reverse bit pattern.
 *
 * @param x some value.
 * @return reverse bits of @p x.
 *
 * @since 0.17.4
 */
public func reverse(x: UInt64): UInt64 {
    return UInt64(reverse(UInt32(x & 0xFFFFFFFF))) << UInt64(32) | UInt64(reverse(UInt32(x >> UInt64(32))))
}

/**
 * Reverse bit pattern.
 *
 * @param x some value.
 * @return reverse bits of @p x.
 *
 * @since 0.17.4
 */
public func reverse(x: UInt32): UInt32 {
    return UInt32(reverse(UInt16(x & 0xFFFF))) << UInt32(16) | UInt32(reverse(UInt16(x >> UInt32(16))))
}

/**
 * Reverse bit pattern.
 *
 * @param x some value.
 * @return reverse bits of @p x.
 *
 * @since 0.17.4
 */
public func reverse(x: UInt16): UInt16 {
    return (UInt16(revtab[Int64(x & 0xFF)]) << UInt16(8)) | UInt16(revtab[Int64(x >> UInt16(8))])
}

/**
 * Reverse bit pattern.
 *
 * @param x some value.
 * @return reverse bits of @p x.
 *
 * @since 0.17.4
 */
public func reverse(x: UInt8): UInt8 {
    return revtab[Int64(x)]
}

/**
 * Determine the absolute value of the Int8 type.
 *
 * @param x some value.
 * @return absolute value of @p x or None.
 *
 * @throws OverflowException if the argument `x` is the minimum value of Int8
 *
 * @since 0.17.4
 */
public func checkedAbs(x: Int8): Option<Int8> {
    return if (x == Int8.Min) {
        None
    } else {
        abs(x)
    }
}

/**
 * Determine the absolute value of the Int16 type.
 *
 * @param x some value.
 * @return absolute value of @p x or None.
 *
 * @throws OverflowException if the argument `x` is the min value of Int16
 *
 * @since 0.17.4
 */
public func checkedAbs(x: Int16): Option<Int16> {
    return if (x == Int16.Min) {
        None
    } else {
        abs(x)
    }
}

/**
 * Determine the absolute value of the Int32 type.
 *
 * @param x some value.
 * @return absolute value of @p x or None.
 *
 * @throws OverflowException if the argument `x` is the minimum value of Int32
 *
 * @since 0.17.4
 */
public func checkedAbs(x: Int32): Option<Int32> {
    return if (x == Int32.Min) {
        None
    } else {
        abs(x)
    }
}

/**
 * Determine the absolute value of the Int64 type.
 *
 * @param x some value.
 * @return absolute value of @p x or None.
 *
 * @throws OverflowException if the argument `x` is the minimum value of Int64
 *
 * @since 0.17.4
 */
public func checkedAbs(x: Int64): Option<Int64> {
    return if (x == Int64.Min) {
        None
    } else {
        abs(x)
    }
}

/**
 * Rotation UInt8 type calculation
 * If the length of the number of digits is exceeded,
 * 0 of the same number of digits is returned.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 *
 * @param num an UInt8 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: UInt8, d: Int8): UInt8 {
    let numberWidth: Int8 = 8
    let rotateMid: Int8 = d & (numberWidth - 1)
    if (rotateMid == 0) {
        return num
    }
    return num << rotateMid | num >> (numberWidth - rotateMid)
}

/**
 * Rotation UInt16 type calculation
 * If the length of the number of digits is exceeded,
 * 0 of the same number of digits is returned.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 *
 * @param num an UInt16 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: UInt16, d: Int8): UInt16 {
    let numberWidth: Int16 = 16
    let rotateMid: Int16 = Int16(d) & (numberWidth - 1)
    if (rotateMid == 0) {
        return num
    }
    return num << rotateMid | num >> (numberWidth - rotateMid)
}

/**
 * Rotation UInt32 type calculation
 * If the length of the number of digits is exceeded,
 * 0 of the same number of digits is returned.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 *
 * @param num an UInt32 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: UInt32, d: Int8): UInt32 {
    let numberWidth: Int32 = 32
    let rotateMid: Int32 = Int32(d) & (numberWidth - 1)
    if (rotateMid == 0) {
        return num
    }
    return num << rotateMid | num >> (numberWidth - rotateMid)
}

/**
 * Rotation UInt64 type calculation
 * If the length of the number of digits is exceeded,
 * 0 of the same number of digits is returned.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 *
 * @param num an UInt64 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: UInt64, d: Int8): UInt64 {
    let numberWidth: Int64 = 64
    let rotateMid: Int64 = Int64(d) & (numberWidth - 1)
    if (rotateMid == 0) {
        return num
    }
    return num << rotateMid | num >> (numberWidth - rotateMid)
}

/**
 * Rotate Int8 type calculation.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 * Note: Binary negative numbers are taken as complements.
 *
 * @param num an Int8 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: Int8, d: Int8): Int8 {
    return Int8(rotate(UInt8(num), d))
}

/**
 * Rotate Int16 type calculation.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 * Note: Binary negative numbers are taken as complements.
 *
 * @param num an Int16 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: Int16, d: Int8): Int16 {
    return Int16(rotate(UInt16(num), d))
}

/**
 * Rotate Int32 type calculation.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 * Note: Binary negative numbers are taken as complements.
 *
 * @param num an Int32 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: Int32, d: Int8): Int32 {
    return Int32(rotate(UInt32(num), d))
}

/**
 * Rotate Int64 type calculation.
 * Returns the result of rotating the number of the first operand by one amount specified by the second operand.
 * The second operand must be an integer range in - precision to precision.
 * The absolute operand of seconds gives the number of positions to rotate.
 * If the second operand is positive, rotate to the left; Otherwise, rotate to the right.
 * The coefficient of the first operand is padded to the left with 0 to length precision,
 * if necessary. The sign and exponent of the first operand remain unchanged.
 * Note: Binary negative numbers are taken as complements.
 *
 * @param num an Int64 argument.
 * @param d number of Rotated Bits.
 * @return rotated Value.
 *
 * @since 0.17.4
 */
@OverflowWrapping
public func rotate(num: Int64, d: Int8): Int64 {
    return Int64(rotate(UInt64(num), d))
}

/**
 * Returns the largest of the commonfactors of two Int8 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @throws OverflowException if the argument `x` or `y` is the minimum value of Int8
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int8,
 * or if one argument is the minimum value of Int8 and the other is 0
 */
@OverflowWrapping
public func gcd(x: Int8, y: Int8): Int8 {
    return match {
        case y == x && y == Int8.Min => throw IllegalArgumentException(
            "Both parameters x and y are minimum boundary values.")
        case (y == Int8.Min && x == 0) || (y == 0 && x == Int8.Min) => throw IllegalArgumentException(
            "One of the parameters is minimum boundary value, and another is 0.")
        case (y == Int8.Min && x != 0) || (y != 0 && x == Int8.Min) => return Int8(gcd(UInt8(x), UInt8(y)))
        case x == 0 && y != 0 => abs(y)
        case y == 0 && x != 0 => abs(x)
        case _ =>
            var x = if (x < 0) {
                UInt8(-x)
            } else {
                UInt8(x)
            }
            var y = if (y < 0) {
                UInt8(-y)
            } else {
                UInt8(y)
            }
            return Int8(gcd(x, y))
    }
}

/**
 * Returns the largest of the commonfactors of two Int16 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @throws OverflowException if the argument `x` or `y` is the minimum value of Int16
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int16,
 * or if one argument is the minimum value of Int16 and the other is 0
 *
 * @since 0.17.4
 *
 */
@OverflowWrapping
public func gcd(x: Int16, y: Int16): Int16 {
    return match {
        case y == x && y == Int16.Min => throw IllegalArgumentException(
            "Both parameters x and y are minimum boundary values.")
        case (y == Int16.Min && x == 0) || (y == 0 && x == Int16.Min) => throw IllegalArgumentException(
            "One of the parameters is minimum boundary value, and another is 0.")
        case (y == Int16.Min && x != 0) || (y != 0 && x == Int16.Min) => return Int16(gcd(UInt16(x), UInt16(y)))
        case x == 0 && y != 0 => abs(y)
        case y == 0 && x != 0 => abs(x)
        case _ =>
            var x = if (x < 0) {
                UInt16(-x)
            } else {
                UInt16(x)
            }
            var y = if (y < 0) {
                UInt16(-y)
            } else {
                UInt16(y)
            }
            return Int16(gcd(x, y))
    }
}

/**
 * Returns the largest of the commonfactors of two Int32 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @throws OverflowException if the argument `x` or `y` is the minimum value of Int32
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int32,
 * or if one argument is the minimum value of Int32 and the other is 0
 *
 * @since 0.17.4
 *
 */
@OverflowWrapping
public func gcd(x: Int32, y: Int32): Int32 {
    return match {
        case y == x && y == Int32.Min => throw IllegalArgumentException(
            "Both parameters x and y are minimum boundary values.")
        case (y == Int32.Min && x == 0) || (y == 0 && x == Int32.Min) => throw IllegalArgumentException(
            "One of the parameters is minimum boundary value, and another is 0.")
        case (y == Int32.Min && x != 0) || (y != 0 && x == Int32.Min) => return Int32(gcd(UInt32(x), UInt32(y)))
        case x == 0 && y != 0 => abs(y)
        case y == 0 && x != 0 => abs(x)
        case _ =>
            var x = if (x < 0) {
                UInt32(-x)
            } else {
                UInt32(x)
            }
            var y = if (y < 0) {
                UInt32(-y)
            } else {
                UInt32(y)
            }
            return Int32(gcd(x, y))
    }
}

/**
 * Returns the largest of the commonfactors of two Int64 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @throws OverflowException if the argument `x` or `y` is the minimum value of Int64
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int64,
 * or if one argument is the minimum value of Int64 and the other is 0
 *
 * @since 0.17.4
 *
 */
@OverflowWrapping
public func gcd(x: Int64, y: Int64): Int64 {
    return match {
        case y == x && y == Int64.Min => throw IllegalArgumentException(
            "Both parameters x and y are minimum boundary values.")
        case (y == Int64.Min && x == 0) || (y == 0 && x == Int64.Min) => throw IllegalArgumentException(
            "One of the parameters is minimum boundary value, and another is 0.")
        case (y == Int64.Min && x != 0) || (y != 0 && x == Int64.Min) => return Int64(gcd(UInt64(x), UInt64(y)))
        case x == 0 && y != 0 => abs(y)
        case y == 0 && x != 0 => abs(x)
        case _ =>
            var x = if (x < 0) {
                UInt64(-x)
            } else {
                UInt64(x)
            }
            var y = if (y < 0) {
                UInt64(-y)
            } else {
                UInt64(y)
            }
            return Int64(gcd(x, y))
    }
}

/**
 * Returns the largest of the commonfactors of two UInt8 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @since 0.17.4
 */
public func gcd(x: UInt8, y: UInt8): UInt8 {
    if (y == 0) {
        return x
    }

    if (x == 0) {
        return y
    }

    var left = x;
    var right = y;
    var commonPower = 0;
    while (left != right) {
        if (left < right) {
            left = left ^ right
            right = left ^ right
            left = left ^ right
        }

        if (UInt8(left & 1) == 1) {
            if (UInt8(right & 1) == 1) {
                right = (left - right) >> 1
                left -= right
            } else {
                right >>= 1
            }
        } else {
            left >>= 1
            if (UInt8(right & 1) != 1) {
                right >>= 1
                commonPower++;
            }
        }
    }

    left << commonPower;
}

/**
 * Returns the largest of the commonfactors of two UInt16 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @since 0.17.4
 */
public func gcd(x: UInt16, y: UInt16): UInt16 {
    if (y == 0) {
        return x
    }

    if (x == 0) {
        return y
    }

    var left = x;
    var right = y;
    var commonPower = 0;
    while (left != right) {
        if (left < right) {
            left = left ^ right
            right = left ^ right
            left = left ^ right
        }

        if (UInt16(left & 1) == 1) {
            if (UInt16(right & 1) == 1) {
                right = (left - right) >> 1
                left -= right
            } else {
                right >>= 1
            }
        } else {
            left >>= 1
            if (UInt16(right & 1) != 1) {
                right >>= 1
                commonPower++;
            }
        }
    }

    left << commonPower;
}

/**
 * Returns the largest of the commonfactors of two UInt32 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @since 0.17.4
 */
public func gcd(x: UInt32, y: UInt32): UInt32 {
    if (y == 0) {
        return x
    }

    if (x == 0) {
        return y
    }

    var left = x;
    var right = y;
    var commonPower = 0;
    while (left != right) {
        if (left < right) {
            left = left ^ right
            right = left ^ right
            left = left ^ right
        }

        if (UInt32(left & 1) == 1) {
            if (UInt32(right & 1) == 1) {
                right = (left - right) >> 1
                left -= right
            } else {
                right >>= 1
            }
        } else {
            left >>= 1
            if (UInt32(right & 1) != 1) {
                right >>= 1
                commonPower++;
            }
        }
    }

    left << commonPower;
}

/**
 * Returns the largest of the commonfactors of two UInt64 numbers.
 * Using a modified version of the Euclidean algorithm: Stein.
 *
 * @param x an argument.
 * @param y another argument.
 * @return a maximum common divisor.
 *
 * @since 0.17.4
 */
public func gcd(x: UInt64, y: UInt64): UInt64 {
    if (y == 0) {
        return x
    }

    if (x == 0) {
        return y
    }

    var left = x;
    var right = y;
    var commonPower = 0;
    while (left != right) {
        if (left < right) {
            left = left ^ right
            right = left ^ right
            left = left ^ right
        }

        if (UInt64(left & 1) == 1) {
            if (UInt64(right & 1) == 1) {
                right = (left - right) >> 1
                left -= right
            } else {
                right >>= 1
            }
        } else {
            left >>= 1
            if (UInt64(right & 1) != 1) {
                right >>= 1
                commonPower++;
            }
        }
    }

    left << commonPower;
}

/**
 * Calculation of the least common multiple of the Int8 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int8,
 * or if one argument is the minimum value of Int8 and the other is 0.
 * @throws IllegalArgumentException if the result is out of the Int8 range.
 */
public func lcm(x: Int8, y: Int8): Int8 {
    if (x == 0 || y == 0) {
        return 0
    }

    let xDivGcd = x / gcd(x, y)
    if (xDivGcd == Int8.Min || y == Int8.Min) {
        throw IllegalArgumentException("The result is out of the Int8 range.")
    }

    let xDivGcdAbs = abs(xDivGcd)
    let yAbs = abs(y)
    if (yAbs > Int8.Max / xDivGcdAbs) {
        throw IllegalArgumentException("The result is out of the Int8 range.")
    } else {
        return abs(xDivGcdAbs * yAbs)
    }
}

/**
 * Calculation of the least common multiple of the Int16 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int16,
 * or if one argument is the minimum value of Int16 and the other is 0.
 * @throws IllegalArgumentException if the result is out of the Int16 range.
 */
public func lcm(x: Int16, y: Int16): Int16 {
    if (x == 0 || y == 0) {
        return 0
    }

    let xDivGcd = x / gcd(x, y)
    if (xDivGcd == Int16.Min || y == Int16.Min) {
        throw IllegalArgumentException("The result is out of the Int16 range.")
    }

    let xDivGcdAbs = abs(xDivGcd)
    let yAbs = abs(y)
    if (yAbs > Int16.Max / xDivGcdAbs) {
        throw IllegalArgumentException("The result is out of the Int16 range.")
    } else {
        return abs(xDivGcdAbs * yAbs)
    }
}

/**
 * Calculation of the least common multiple of the Int32 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int32,
 * or if one argument is the minimum value of Int32 and the other is 0.
 * @throws IllegalArgumentException if the result is out of the Int32 range.
 */
public func lcm(x: Int32, y: Int32): Int32 {
    if (x == 0 || y == 0) {
        return 0
    }

    let xDivGcd = x / gcd(x, y)
    if (xDivGcd == Int32.Min || y == Int32.Min) {
        throw IllegalArgumentException("The result is out of the Int32 range.")
    }

    let xDivGcdAbs = abs(xDivGcd)
    let yAbs = abs(y)
    if (yAbs > Int32.Max / xDivGcdAbs) {
        throw IllegalArgumentException("The result is out of the Int32 range.")
    } else {
        return abs(xDivGcdAbs * yAbs)
    }
}

/**
 * Calculation of the least common multiple of the Int64 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if argument `x` and `y` are minimum values of Int64,
 * or if one argument is the minimum value of Int64 and the other is 0.
 * @throws IllegalArgumentException if the result is out of the Int64 range.
 */
public func lcm(x: Int64, y: Int64): Int64 {
    if (x == 0 || y == 0) {
        return 0
    }

    let xDivGcd = x / gcd(x, y)
    if (xDivGcd == Int64.Min || y == Int64.Min) {
        throw IllegalArgumentException("The result is out of the Int64 range.")
    }

    let xDivGcdAbs = abs(xDivGcd)
    let yAbs = abs(y)
    if (yAbs > Int64.Max / xDivGcdAbs) {
        throw IllegalArgumentException("The result is out of the Int64 range.")
    } else {
        return abs(xDivGcdAbs * yAbs)
    }
}

/**
 * Calculation of the least common multiple of the UInt8 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 * @throws IllegalArgumentException if the result is out of the UInt8 range
 *
 * @since 0.17.4
 *
 */
public func lcm(x: UInt8, y: UInt8): UInt8 {
    if (x == 0 || y == 0) {
        return 0
    }

    let a = x / gcd(x, y)
    let c = UInt8.Max / a
    if (y > c) {
        throw IllegalArgumentException("The result is out of the UInt8 range.")
    } else {
        return x / gcd(x, y) * y
    }
}

/**
 * Calculation of the least common multiple of the UInt16 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the result is out of the UInt16 range
 */
public func lcm(x: UInt16, y: UInt16): UInt16 {
    if (x == 0 || y == 0) {
        return 0
    }

    let a = x / gcd(x, y)
    let c = UInt16.Max / a
    if (y > c) {
        throw IllegalArgumentException("The result is out of the UInt16 range.")
    } else {
        return x / gcd(x, y) * y
    }
}
/**
 * Calculation of the least common multiple of the UInt32 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the result is out of the UInt32 range
 */
public func lcm(x: UInt32, y: UInt32): UInt32 {
    if (x == 0 || y == 0) {
        return 0
    }

    var a = x / gcd(x, y)
    var c = UInt32.Max / a
    if (y > c) {
        throw IllegalArgumentException("The result is out of the UInt32 range.")
    } else {
        return x / gcd(x, y) * y
    }
}

/**
 * Calculation of the least common multiple of the UInt64 type.
 *
 * @param x some value.
 * @param y another value.
 * @return the least common multiple value of @p x and @p y.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the result is out of the UInt64 range
 */
public func lcm(x: UInt64, y: UInt64): UInt64 {
    if (x == 0 || y == 0) {
        return 0
    }

    let a = x / gcd(x, y)
    let c = UInt64.Max / a
    if (y > c) {
        throw IllegalArgumentException("The result is out of the UInt64 range.")
    } else {
        return x / gcd(x, y) * y
    }
}

/**
 * Panics if min > max, min is NaN, or max is NaN.
 * Restrict a value to a certain Interval unless it is NaN.
 * Returns max if self is greater than max, and min if self is less than min.
 * Otherwise this returns self. Note that this function returns NaN if the initial value was NaN as well.
 *
 * @brief  Returns a number between the maximum and minimum values.
 *
 * @param   v   an argument.
 * @param   min   a minimum argument.
 * @param   max   a maximum argument.
 * @return  restricted value between @p min and @p max.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `min` is larger than `max`, or `min` or `max` is NaN
 */
public func clamp(v: Float16, min: Float16, max: Float16): Float16 {
    if (!isEqual(min, min) || !isEqual(max, max) || min > max) {
        throw IllegalArgumentException("Check parameter min:'${min}' or max:'${max}'.\n")
    }
    if (v < min) {
        return min
    }
    if (v > max) {
        return max
    }
    return v
}

/**
 * Panics if min > max, min is NaN, or max is NaN.
 * Restrict a value to a certain Interval unless it is NaN.
 * Returns max if self is greater than max, and min if self is less than min.
 * Otherwise this returns self. Note that this function returns NaN if the initial value was NaN as well.
 *
 * @brief  Returns a number between the maximum and minimum values.
 *
 * @param   v   an argument.
 * @param   min   a minimum argument.
 * @param   max   a maximum argument.
 * @return  restricted value between @p min and @p max.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `min` is larger than `max`, or `min` or `max` is NaN
 */
public func clamp(v: Float32, min: Float32, max: Float32): Float32 {
    if (!isEqual(min, min) || !isEqual(max, max) || min > max) {
        throw IllegalArgumentException("Check parameter min:'${min}' or max:'${max}'.\n")
    }
    if (v < min) {
        return min
    }
    if (v > max) {
        return max
    }
    return v
}

/**
 * Panics if min > max, min is NaN, or max is NaN.
 * Restrict a value to a certain Interval unless it is NaN.
 * Returns max if self is greater than max, and min if self is less than min.
 * Otherwise this returns self. Note that this function returns NaN if the initial value was NaN as well.
 * @brief  Returns a number between the maximum and minimum values.
 *
 * @param   v   an argument.
 * @param   min   a minimum argument.
 * @param   max   a maximum argument.
 * @return  restricted value between @p min and @p max.
 *
 * @since 0.17.4
 *
 * @throws IllegalArgumentException if the argument `min` is larger than `max`, or `min` or `max` is NaN
 */
public func clamp(v: Float64, min: Float64, max: Float64): Float64 {
    if (!isEqual(min, min) || !isEqual(max, max) || min > max) {
        throw IllegalArgumentException("Check parameter min:'${min}' or max:'${max}'.\n")
    }
    if (v < min) {
        return min
    }
    if (v > max) {
        return max
    }
    return v
}

/**
 * The banker algorithm is an IEEE-754 specification.
 * If the value of the rounding bit is less than 5, the rounding bit is directly performed.
 * If the value of the rounding bit is greater than 5, the value of the rounding bit is incremented by 1.
 * When the number of rounded bits is equal to 5, there are two cases:
 *    If 5 is followed by other non-zero digits (that is, 5 is not the last digit), the carry value increases by 1.
 *    If there is only 0 after 5 (that is, 5 is the last digit), the system determines whether the first digit is an odd number.
 *    If the first digit is an odd number, the system adds 1 to the carry value. If the first digit is an even number, the system rounds it off.
 *
 * @param x Floating point value
 * @return Float64 Rounded value of @x
 *
 * @since 0.25.2
 */
public func round(x: Float64): Float64 {
    if (x.isNaN()) {
        return Float64.NaN
    }
    var result: Float64 = abs(x)
    // note: if result >= 1e16, Float64(1e16) + 1 = ceil(Float64(1e16) + 0.9)
    if (result >= 1e16) {
        return x
    }

    let integer: Float64 = floor(result)
    let decimal: Float64 = result - integer
    result = match {
        case decimal < 0.5 => integer
        case decimal > 0.5 => integer + 1.0
        case Int64(integer) % 2 == 0 => integer
        case _ => integer + 1.0
    }

    return match (x < 0.0) {
        case true => -result
        case false => result
    }
}

/**
 * The banker algorithm is an IEEE-754 specification.
 * If the value of the rounding bit is less than 5, the rounding bit is directly performed.
 * If the value of the rounding bit is greater than 5, the value of the rounding bit is incremented by 1.
 * When the number of rounded bits is equal to 5, there are two cases:
 *    If 5 is followed by other non-zero digits (that is, 5 is not the last digit), the carry value increases by 1.
 *    If there is only 0 after 5 (that is, 5 is the last digit), the system determines whether the first digit is an odd number.
 *    If the first digit is an odd number, the system adds 1 to the carry value. If the first digit is an even number, the system rounds it off.
 *
 * @param x Floating point value
 * @return Float64 Rounded value of @x
 *
 * @since 0.25.2
 */
public func round(x: Float32): Float32 {
    if (x.isNaN()) {
        return Float32.NaN
    }
    var rounded: Float32 = abs(x)
    // note: if rounded >= 1e8, Float32(1e8) + 1 = ceil(Float32(1e8) + 0.9)
    if (rounded >= 1e8) {
        return x
    }

    let whole: Float32 = floor(rounded)
    let fraction: Float32 = rounded - whole
    rounded = match {
        case fraction < 0.5 => whole
        case fraction > 0.5 => whole + 1.0
        case Int64(whole) % 2 == 0 => whole
        case _ => whole + 1.0
    }

    return match (x < 0.0) {
        case true => -rounded
        case false => rounded
    }
}

/**
 * The banker algorithm is an IEEE-754 specification.
 * If the value of the rounding bit is less than 5, the rounding bit is directly performed.
 * If the value of the rounding bit is greater than 5, the value of the rounding bit is incremented by 1.
 * When the number of rounded bits is equal to 5, there are two cases:
 *    If 5 is followed by other non-zero digits (that is, 5 is not the last digit), the carry value increases by 1.
 *    If there is only 0 after 5 (that is, 5 is the last digit), the system determines whether the first digit is an odd number.
 *    If the first digit is an odd number, the system adds 1 to the carry value. If the first digit is an even number, the system rounds it off.
 *
 * @param x Floating point value
 * @return Float64 Rounded value of @x
 *
 * @since 0.25.2
 */
public func round(x: Float16): Float16 {
    if (x.isNaN()) {
        return Float16.NaN
    }
    var nearest: Float16 = abs(x)
    // note: if nearest >= 1e4, Float16(1e4) + 1 = ceil(Float16(1e4) + 0.9)
    if (nearest >= 1e4) {
        return x
    }

    let integral: Float16 = floor(nearest)
    let remainder: Float16 = nearest - integral
    nearest = match {
        case remainder < 0.5 => integral
        case remainder > 0.5 => integral + 1.0
        case Int64(integral) % 2 == 0 => integral
        case _ => integral + 1.0
    }

    return match (x < 0.0) {
        case true => -nearest
        case false => nearest
    }
}

/**
 * These functions shall compute the principal value of the arc tangent of y/x, using the signs of both arguments to determine the quadrant of the return value.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9799919799/functions/atan2.html
 */
public func atan2(y: Float64, x: Float64): Float64 {
    return unsafe { CJ_MATH_Atan2(y, x) }
}

/**
 * These functions shall compute the principal value of the arc tangent of y/x, using the signs of both arguments to determine the quadrant of the return value.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9799919799/functions/atan2.html
 */
public func atan2(y: Float32, x: Float32): Float32 {
    return unsafe { CJ_MATH_Atan2f(y, x) }
}

/**
 * These functions shall compute the principal value of the arc tangent of y/x, using the signs of both arguments to determine the quadrant of the return value.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9799919799/functions/atan2.html
 */
public func atan2(y: Float16, x: Float16): Float16 {
    return unsafe { Float16(CJ_MATH_Atan2(Float64(y), Float64(x))) }
}

/**
 * These functions shall return the floating-point remainder of the division of x by y.
 * These functions shall return the value x- i* y, for some integer i such that, if y is non-zero, the result has the same sign as x and magnitude less than the magnitude of y.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9699919799/functions/fmod.html
 */
public func fmod(x: Float64, y: Float64): Float64 {
    if (x.isNaN() || y.isNaN()) {
        return Float64.NaN
    }
    if (x.isInf() || y == 0.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    return unsafe { CJ_MATH_Fmod(x, y) }
}

/**
 * These functions shall return the floating-point remainder of the division of x by y.
 * These functions shall return the value x- i* y, for some integer i such that, if y is non-zero, the result has the same sign as x and magnitude less than the magnitude of y.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9699919799/functions/fmod.html
 */
public func fmod(x: Float32, y: Float32): Float32 {
    if (x.isNaN() || y.isNaN()) {
        return Float32.NaN
    }
    if (x.isInf() || y == 0.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    return unsafe { CJ_MATH_Fmodf(x, y) }
}

/**
 * These functions shall return the floating-point remainder of the division of x by y.
 * These functions shall return the value x- i* y, for some integer i such that, if y is non-zero, the result has the same sign as x and magnitude less than the magnitude of y.
 *
 * ref: https://pubs.opengroup.org/onlinepubs/9699919799/functions/fmod.html
 */
public func fmod(x: Float16, y: Float16): Float16 {
    if (x.isNaN() || y.isNaN()) {
        return Float16.NaN
    }
    if (x.isInf() || y == 0.0) {
        throw IllegalArgumentException("The input parameter is invalid. Please enter a correct parameter.")
    }
    return unsafe { Float16(CJ_MATH_Fmod(Float64(x), Float64(y))) }
}

func isEqual(a: Float16, b: Float16): Bool {
    if (a.isInf() || b.isInf() || a.isNaN() || b.isNaN()) {
        return a == b
    }
    return abs(a - b) <= 1e-3
}

func isEqual(a: Float32, b: Float32): Bool {
    if (a.isInf() || b.isInf() || a.isNaN() || b.isNaN()) {
        return a == b
    }
    return abs(a - b) <= 1e-6
}

func isEqual(a: Float64, b: Float64): Bool {
    if (a.isInf() || b.isInf() || a.isNaN() || b.isNaN()) {
        return a == b
    }
    return abs(a - b) <= 1e-15
}
