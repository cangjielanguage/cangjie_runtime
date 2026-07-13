# Functions

## func abs(Float16)

```cangjie
public func abs(x: Float16): Float16
```

Function: Calculates the absolute value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the absolute value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Float16 = -23.0
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23.000000
```

## func abs(Float32)

```cangjie
public func abs(x: Float32): Float32
```

Function: Calculates the absolute value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the absolute value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Float32 = -23.0
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23.000000
```

## func abs(Float64)

```cangjie
public func abs(x: Float64): Float64
```

Function: Calculates the absolute value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the absolute value of the input parameter.

Example:

<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Float64 = -23.0
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23.000000
```

## func abs(Int16)

```cangjie
public func abs(x: Int16): Int16
```

Function: Calculates the absolute value of a 16-bit signed integer.

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The input 16-bit signed integer.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - Returns the absolute value of the input parameter.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Throws an exception when the input parameter is the minimum value of a signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Int16 = -23
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23
```

The following example throws an exception:
<!-- verify -->
```cangjie
import std.math.abs

main(): Unit {
    try {
        let n = Int16(-2 ** 15)
        let abs: Int16 = abs(n)
        println(abs)
    } catch (e: OverflowException) {
        println("Exception: Input parameter is the minimum value of a signed integer")
    }
}
```

Execution Result:

```text
Exception: Input parameter is the minimum value of a signed integer
```

## func abs(Int32)

```cangjie
public func abs(x: Int32): Int32
```

Function: Calculates the absolute value of a 32-bit signed integer.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The input 32-bit signed integer.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Returns the absolute value of the input parameter.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Throws an exception when the input parameter is the minimum value of a signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Int32 = -23
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23
```

## func abs(Int64)

```cangjie
public func abs(x: Int64): Int64
```

Function: Calculates the absolute value of a 64-bit signed integer.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The input 64-bit signed integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the absolute value of the input parameter.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Throws an exception when the input parameter is the minimum value of a signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Int64 = -23
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23
```

## func abs(Int8)

```cangjie
public func abs(x: Int8): Int8
```

Function: Calculates the absolute value of an 8-bit signed integer.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The input 8-bit signed integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the absolute value of the input parameter.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Throws an exception when the input parameter is the minimum value of a signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.abs

main() {
    let n: Int8 = -23
    let abs = abs(n)
    println(abs)
}
```

Execution Result:

```text
23
```

## func acos(Float16)

```cangjie
public func acos(x: Float16): Float16
```

Function: Calculates the arccosine value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the arccosine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

Example:<!-- verify -->

```cangjie
import std.math.acos

main() {
    let n: Float16 = 1.0
    let acos = acos(n)
    println(acos)
}
```

Execution result:

```text
0.000000
```

The following example will throw an exception:
<!-- run.error -->
```cangjie
import std.math.acos

main(): Unit {
    let n = -1.5
    let acos = acos(n)
    println(acos)
}
```

## func acos(Float32)

```cangjie
public func acos(x: Float32): Float32
```

Function: Calculates the arccosine value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the arccosine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.acos

main() {
    let n: Float32 = 1.0
    let acos = acos(n)
    println(acos)
}
```

Execution result:

```text
0.000000
```

## func acos(Float64)

```cangjie
public func acos(x: Float64): Float64
```

Function: Calculates the arccosine value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the arccosine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.acos

main() {
    let n: Float64 = 1.0
    let acos = acos(n)
    println(acos)
}
```

Execution result:

```text
0.000000
```

## func acosh(Float16)

```cangjie
public func acosh(x: Float16): Float16
```

Function: Calculates the inverse hyperbolic cosine value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the inverse hyperbolic cosine value of the input parameter. `x` >= 1.0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is less than 1.0.

Example:
<!-- verify -->
```cangjie
import std.math.acosh

main() {
    let n: Float16 = 1.0
    let acosh = acosh(n)
    println(acosh)
}
```

Execution result:

```text
0.000000
```

The following example will throw an exception:
<!-- run.error -->
```cangjie
import std.math.acosh

main(): Unit {
    let n = 0.4
    let acosh = acosh(n)
    println(acosh)
}
```

## func acosh(Float32)

```cangjie
public func acosh(x: Float32): Float32
```

Function: Computes the inverse hyperbolic cosine of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number. `x` >= 1.0.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the inverse hyperbolic cosine value of the input parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is less than 1.0.

Example:
<!-- verify -->
```cangjie
import std.math.acosh

main() {
    let n: Float32 = 1.0
    let acosh = acosh(n)
    println(acosh)
}
```

Execution Result:

```text
0.000000
```

## func acosh(Float64)

```cangjie
public func acosh(x: Float64): Float64
```

Function: Computes the inverse hyperbolic cosine of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number. `x` >= 1.0.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the inverse hyperbolic cosine value of the input parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is less than 1.0.

Example:
<!-- verify -->
```cangjie
import std.math.acosh

main() {
    let n: Float64 = 1.0
    let acosh = acosh(n)
    println(acosh)
}
```

Execution Result:

```text
0.000000
```

## func asin(Float16)

```cangjie
public func asin(x: Float16): Float16
```

Function: Computes the arcsine of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the arcsine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.asin

main() {
    let n: Float16 = 0.0
    let asin = asin(n)
    println(asin)
}
```

Execution Result:

```text
0.000000
```

The following example will throw an exception:
<!-- run.error -->
```cangjie
import std.math.asin

main(): Unit {
    let n = 1.4
    let asin = asin(n)
    println(asin)
}
```

## func asin(Float32)

```cangjie
public func asin(x: Float32): Float32
```

Function: Computes the arcsine of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the arcsine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

```}
```

Execution Result:

```text
0.000000
```

## func asin(Float64)

```cangjie
public func asin(x: Float64): Float64
```

Function: Calculates the arcsine value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number. -1.0 <= `x` <= 1.0.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the arcsine value of the input parameter in radians.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than 1.0 or less than -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.asin

main() {
    let n: Float64 = 0.0
    let asin = asin(n)
    println(asin)
}
```

Execution Result:

```text
0.000000
```

## func asinh(Float16)

```cangjie
public func asinh(x: Float16): Float16
```

Function: Calculates the inverse hyperbolic sine value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the inverse hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.asinh

main() {
    let n: Float16 = 0.0
    let asinh = asinh(n)
    println(asinh)
}
```

Execution Result:

```text
0.000000
```

## func asinh(Float32)

```cangjie
public func asinh(x: Float32): Float32
```

Function: Calculates the inverse hyperbolic sine value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the inverse hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.asinh

main() {
    let n: Float32 = 0.0
    let asinh = asinh(n)
    println(asinh)
}
```

Execution Result:

```text
0.000000
```

## func asinh(Float64)

```cangjie
public func asinh(x: Float64): Float64
```

Function: Calculates the inverse hyperbolic sine value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the inverse hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.asinh

main() {
    let n: Float64 = 0.0
    let asinh = asinh(n)
    println(asinh)
```

Execution result:

```text
0.000000
```

## func atan(Float16)

```cangjie
public func atan(x: Float16): Float16
```

Function: Computes the arctangent of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The arctangent value of the input parameter, in radians.

Example:
<!-- verify -->
```cangjie
import std.math.atan

main() {
    let n: Float16 = 0.0
    let atan = atan(n)
    println(atan)
}
```

Execution result:

```text
0.000000
```

## func atan(Float32)

```cangjie
public func atan(x: Float32): Float32
```

Function: Computes the arctangent of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The arctangent value of the input parameter, in radians.

Example:
<!-- verify -->
```cangjie
import std.math.atan

main() {
    let n: Float32 = 0.0
    let atan = atan(n)
    println(atan)
}
```

Execution result:

```text
0.000000
```

## func atan(Float64)

```cangjie
public func atan(x: Float64): Float64
```

Function: Computes the arctangent of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The arctangent value of the input parameter, in radians.

Example:
<!-- verify -->
```cangjie
import std.math.atan

main() {
    let n: Float64 = 0.0
    let atan = atan(n)
    println(atan)
}
```

Execution result:

```text
0.000000
```

## func atan2(Float16, Float16)

```cangjie
public func atan2(y: Float16, x: Float16): Float16
```

Function: Computes the arctangent of y/x for two half-precision floating-point numbers, in radians.

Parameters:

- y: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.
- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The arctangent value of y/x, in radians.

Example:
<!-- verify -->
```cangjie
import std.math.*
import std.convert.Formattable

main() {
    let y: Float16 = 1.0
    let x: Float16 = 1.0
    let atan2 = atan2(y, x) / Float16.getPI() * 180.0 // Convert radians to degrees for printing
    println("${atan2.format(".1")}°")
}
```

Execution result:

```text
45.0°
```

## func atan2(Float32, Float32)

```cangjie
public func atan2(y: Float32, x: Float32): Float32
```

Function: Calculates the arctangent of the quotient y/x for single-precision floating-point numbers, in radians.

Parameters:

- y: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number.
- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the arctangent of y/x in radians.

Example:
<!-- verify -->
```cangjie
import std.math.*
import std.convert.Formattable

main() {
    let y: Float32 = 1.0
    let x: Float32 = 1.0
    let atan2 = atan2(y, x) / Float32.getPI() * 180.0 // Convert radians to degrees for printing
    println("${atan2.format(".1")}°")
}
```

Execution Result:

```text
45.0°
```

## func atan2(Float64, Float64)

```cangjie
public func atan2(y: Float64, x: Float64): Float64
```

Function: Calculates the arctangent of the quotient y/x for double-precision floating-point numbers, in radians.

Parameters:

- y: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.
- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the arctangent of y/x in radians.

Example:
<!-- verify -->
```cangjie
import std.math.*
import std.convert.Formattable

main() {
    let y: Float64 = 1.0
    let x: Float64 = 1.0
    let atan2 = atan2(y, x) / Float64.getPI() * 180.0 // Convert radians to degrees for printing
    println("${atan2.format(".1")}°")
}
```

Execution Result:

```text
45.0°
```

## func atanh(Float16)

```cangjie
public func atanh(x: Float16): Float16
```

Function: Calculates the inverse hyperbolic tangent of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number. -1.0 < `x` < 1.0.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the inverse hyperbolic tangent of the input parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than or equal to 1.0 or less than or equal to -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.atanh

main() {
    let n: Float16 = 0.0
    let atanh = atanh(n)
    println(atanh)
}
```

Execution Result:

```text
0.000000
```

The following example will throw an exception:
<!-- run.error -->
```cangjie
import std.math.atanh

main(): Unit {
    let n = -1.4
    let atanh = atanh(n)
    println(atanh)
}
```

## func atanh(Float32)

```cangjie
public func atanh(x: Float32): Float32
```

Function: Calculates the inverse hyperbolic tangent of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number. -1.0 < `x` < 1.0.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the inverse hyperbolic tangent of the input parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when parameter `x` is greater than or equal to 1.0 or less than or equal to -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.atanh

main() {
    let n: Float32 = 0.0
    let atanh = atanh(n)
    println(atanh)
}
```

Execution result:

```text
0.000000
```

## func atanh(Float64)

```cangjie
public func atanh(x: Float64): Float64
```

Function: Calculates the inverse hyperbolic tangent of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number. -1.0 < `x` < 1.0.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the inverse hyperbolic tangent of the input parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the parameter `x` is greater than or equal to 1.0 or less than or equal to -1.0.

Example:
<!-- verify -->
```cangjie
import std.math.atanh

main() {
    let n: Float64 = 0.0
    let atanh = atanh(n)
    println(atanh)
}
```

Execution result:

```text
0.000000
```

## func cbrt(Float16)

```cangjie
public func cbrt(x: Float16): Float16
```

Function: Calculates the cube root of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the cube root of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cbrt

main() {
    let n: Float16 = -1000.0
    let cbrt = cbrt(n)
    println(cbrt)
}
```

Execution result:

```text
-10.000000
```

## func cbrt(Float32)

```cangjie
public func cbrt(x: Float32): Float32
```

Function: Calculates the cube root of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the cube root of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cbrt

main() {
    let n: Float32 = -1000.0
    let cbrt = cbrt(n)
    println(cbrt)
}
```

Execution result:

```text
-10.000000
```

## func cbrt(Float64)

```cangjie
public func cbrt(x: Float64): Float64
```

Function: Calculates the cube root of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the cube root of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cbrt

main() {
    let n: Float64 = -1000.0
    let cbrt = cbrt(n)
    println(cbrt)
}
```

Execution result:

```text
-10.000000
```## func ceil(Float16)

```cangjie
public func ceil(x: Float16): Float16
```

Function: Computes the ceiling value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the ceiling value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.ceil

main() {
    let n: Float16 = 0.7
    let ceil = ceil(n)
    println(ceil)
}
```

Execution Result:

```text
1.000000
```

## func ceil(Float32)

```cangjie
public func ceil(x: Float32): Float32
```

Function: Computes the ceiling value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the ceiling value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.ceil

main() {
    let n: Float32 = 0.7
    let ceil = ceil(n)
    println(ceil)
}
```

Execution Result:

```text
1.000000
```

## func ceil(Float64)

```cangjie
public func ceil(x: Float64): Float64
```

Function: Computes the ceiling value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the ceiling value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.ceil

main() {
    let n: Float64 = 0.7
    let ceil = ceil(n)
    println(ceil)
}
```

Execution Result:

```text
1.000000
```

## func checkedAbs(Int16)

```cangjie
public func checkedAbs(x: Int16): Option<Int16>
```

Function: Computes the absolute value of a 16-bit signed integer. If the input is the minimum value of a 16-bit signed integer, the function returns [None](../../core/core_package_api/core_package_enums.md#none); otherwise, it returns [Some](../../core/core_package_api/core_package_enums.md#somet)(abs(x)).

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The input 16-bit signed integer.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> - Returns the absolute value of the input parameter as an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) type.

Example:
<!-- verify -->
```cangjie
import std.math.checkedAbs

main() {
    let n: Int16 = -23
    let checkedAbs = checkedAbs(n)
    println(checkedAbs)
}
```

Execution Result:

```text
Some(23)
```

## func checkedAbs(Int32)

```cangjie
public func checkedAbs(x: Int32): Option<Int32>
```

Function: Computes the absolute value of a 32-bit signed integer. If the input is the minimum value of a 32-bit signed integer, the function returns [None](../../core/core_package_api/core_package_enums.md#none); otherwise, it returns [Some](../../core/core_package_api/core_package_enums.md#somet)(abs(x)).

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The input 32-bit signed integer.

Returns:- [Option](../../../std_en/core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> - Returns the absolute value of the input parameter as an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) type.

Example:
<!-- verify -->
```cangjie
import std.math.checkedAbs

main() {
    let n: Int32 = -23
    let checkedAbs = checkedAbs(n)
    println(checkedAbs)
}
```

Output:

```text
Some(23)
```

## func checkedAbs(Int64)

```cangjie
public func checkedAbs(x: Int64): Option<Int64>
```

Function: Calculates the absolute value of a 64-bit signed integer. If the input is the minimum value of a 64-bit signed integer, the function returns [None](../../core/core_package_api/core_package_enums.md#none); otherwise, it returns [Some](../../core/core_package_api/core_package_enums.md#somet)(abs(x)).

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The input 64-bit signed integer.

Returns:

- [Option](../../../std_en/core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - Returns the absolute value of the input parameter as an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) type.

Example:
<!-- verify -->
```cangjie
import std.math.checkedAbs

main() {
    let n: Int64 = -23
    let checkedAbs = checkedAbs(n)
    println(checkedAbs)
}
```

Output:

```text
Some(23)
```

## func checkedAbs(Int8)

```cangjie
public func checkedAbs(x: Int8): Option<Int8>
```

Function: Calculates the absolute value of an 8-bit signed integer. If the input is the minimum value of an 8-bit signed integer, the function returns [None](../../core/core_package_api/core_package_enums.md#none); otherwise, it returns [Some](../../core/core_package_api/core_package_enums.md#somet)(abs(x)).

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The input 8-bit signed integer.

Returns:

- [Option](../../../std_en/core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> - Returns the absolute value of the input parameter as an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) type.

Example:
<!-- verify -->
```cangjie
import std.math.checkedAbs

main() {
    let n: Int8 = -23
    let checkedAbs = checkedAbs(n)
    println(checkedAbs)
}
```

Output:

```text
Some(23)
```

## func clamp(Float16, Float16, Float16)

```cangjie
public func clamp(v: Float16, min: Float16, max: Float16): Float16
```

Function: Clamps a floating-point number within a specified range. If the number is within the range, it returns the number; if the number is less than the minimum value of the range, it returns the minimum value; if the number is greater than the maximum value of the range, it returns the maximum value; if the number is `NaN`, it returns `NaN`.

Parameters:

- v: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input floating-point number.
- min: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The specified minimum value.
- max: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The specified maximum value.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns `v` if `v` is between `min` and `max`; returns `min` if `v` is less than or equal to `min`; returns `max` if `v` is greater than or equal to `max`; returns `NaN` if `v` is `NaN`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if `min` is greater than `max` or if `min` and `max` are `NaN`.

Example:
<!-- verify -->
```cangjie
import std.math.clamp

main() {
    let n: Float16 = -23.0
    let clamp = clamp(n, -100.0, 100.0)
    println(clamp)
}
```

Output:

```text
-23.000000
```

## func clamp(Float32, Float32, Float32)

```cangjie
public func clamp(v: Float32, min: Float32, max: Float32): Float32
```

Function: Clamps a floating-point number within a specified range. If the number is within the range, it returns the number; if the number is less than the minimum value of the range, it returns the minimum value; if the number is greater than the maximum value of the range, it returns the maximum value; if the number is `NaN`, it returns `NaN`.

Parameters:

- v: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input floating-point number.
- min: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The specified minimum value.
- max: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The specified maximum value.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns `v` if `v` is between `min` and `max`; returns `min` if `v` is less than or equal to `min`; returns `max` if `v` is greater than or equal to `max`; returns `NaN` if `v` is `NaN`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if `min` is greater than `max` or if `min` and `max` are `NaN`.- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cos

main() {
    let n: Float64 = 3.14159265
    let cos = cos(n)
    println(cos)
}
```

Execution Result:

```text
-1.000000
```

## func cos(Float16)

```cangjie
public func cos(x: Float16): Float16
```

Function: Computes the cosine of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number in radians.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cos

main() {
    let n: Float16 = 3.14159265
    let cos = cos(n)
    println(cos)
}
```

Execution Result:

```text
-1.000000
```

## func cos(Float32)

```cangjie
public func cos(x: Float32): Float32
```

Function: Computes the cosine of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number in radians.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cos

main() {
    let n: Float32 = 3.14159265
    let cos = cos(n)
    println(cos)
}
```

Execution Result:

```text
-1.000000
```

## func cos(Float64)

```cangjie
public func cos(x: Float64): Float64
```

Function: Computes the cosine of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number in radians.

Returns:- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cos

main() {
    let n: Float64 = 3.14159265
    let cos = cos(n)
    println(cos)
}
```

Execution result:

```text
-1.000000
```

## func cosh(Float16)

```cangjie
public func cosh(x: Float16): Float16
```

Function: Computes the hyperbolic cosine of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the hyperbolic cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cosh

main() {
    let n: Float16 = 0.0
    let cosh = cosh(n)
    println(cosh)
}
```

Execution result:

```text
1.000000
```

## func cosh(Float32)

```cangjie
public func cosh(x: Float32): Float32
```

Function: Computes the hyperbolic cosine of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the hyperbolic cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cosh

main() {
    let n: Float32 = 0.0
    let cosh = cosh(n)
    println(cosh)
}
```

Execution result:

```text
1.000000
```

## func cosh(Float64)

```cangjie
public func cosh(x: Float64): Float64
```

Function: Computes the hyperbolic cosine of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the hyperbolic cosine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.cosh

main() {
    let n: Float64 = 0.0
    let cosh = cosh(n)
    println(cosh)
}
```

Execution result:

```text
1.000000
```

## func countOne(Int16) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: Int16): Int8
```

Function: Counts the number of 1 bits in the binary representation of a 16-bit integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(Int16)](#func-countonesint16) instead.

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - Input 16-bit signed integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of 1 bits in the binary representation of the input parameter.

## func countOnes(Int16)

```cangjie
public func countOnes(x: Int16): Int64
```

Function: Counts the number of 1 bits in the binary representation of a 16-bit integer.Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The input 16-bit signed integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of set bits (1s) in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: Int16 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(Int32) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: Int32): Int8
```

Function: Counts the number of set bits (1s) in the binary representation of a 32-bit integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(Int32)](#func-countonesint32) instead.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The input 32-bit signed integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of set bits (1s) in the binary representation of the input parameter.

## func countOnes(Int32)

```cangjie
public func countOnes(x: Int32): Int64
```

Function: Counts the number of set bits (1s) in the binary representation of a 32-bit integer.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The input 32-bit signed integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of set bits (1s) in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: Int32 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(Int64) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: Int64): Int8
```

Function: Counts the number of set bits (1s) in the binary representation of a 64-bit integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(Int64)](#func-countonesint64) instead.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The input 64-bit signed integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of set bits (1s) in the binary representation of the input parameter.

## func countOnes(Int64)

```cangjie
public func countOnes(x: Int64): Int64
```

Function: Counts the number of set bits (1s) in the binary representation of a 64-bit integer.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The input 64-bit signed integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of set bits (1s) in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: Int64 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(Int8) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: Int8): Int8
```

Function: Counts the number of set bits (1s) in the binary representation of an 8-bit integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(Int8)](#func-countonesint8) instead.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The input 8-bit signed integer.Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of '1' bits in the binary representation of the input parameter.

## func countOnes(Int8)

```cangjie
public func countOnes(x: Int8): Int64
```

Function: Counts the number of '1' bits in the binary representation of an 8-bit integer.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The input 8-bit signed integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of '1' bits in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: Int8 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(UInt16) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: UInt16): Int8
```

Function: Counts the number of '1' bits in the binary representation of a 16-bit unsigned integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(UInt16)](#func-countonesuint16) instead.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The input 16-bit unsigned integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of '1' bits in the binary representation of the input parameter.

## func countOnes(UInt16)

```cangjie
public func countOnes(x: UInt16): Int64
```

Function: Counts the number of '1' bits in the binary representation of a 16-bit unsigned integer.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The input 16-bit unsigned integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of '1' bits in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: UInt16 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(UInt32) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: UInt32): Int8
```

Function: Counts the number of '1' bits in the binary representation of a 32-bit unsigned integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(UInt32)](#func-countonesuint32) instead.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The input 32-bit unsigned integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of '1' bits in the binary representation of the input parameter.

## func countOnes(UInt32)

```cangjie
public func countOnes(x: UInt32): Int64
```

Function: Counts the number of '1' bits in the binary representation of a 32-bit unsigned integer.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The input 32-bit unsigned integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of '1' bits in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: UInt32 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(UInt64) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: UInt64): Int8
```

Function: Counts the number of 1 bits in the binary representation of a 64-bit unsigned integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(UInt64)](#func-countonesuint64) instead.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The input 64-bit unsigned integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of 1 bits in the binary representation of the input parameter.

## func countOnes(UInt64)

```cangjie
public func countOnes(x: UInt64): Int64
```

Function: Counts the number of 1 bits in the binary representation of a 64-bit unsigned integer.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The input 64-bit unsigned integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of 1 bits in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: UInt64 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func countOne(UInt8) <sup>(deprecated)</sup>

```cangjie
public func countOne(x: UInt8): Int8
```

Function: Counts the number of 1 bits in the binary representation of an 8-bit unsigned integer.

> **Note:**
>
> This function will be deprecated in future versions. Use [countOnes(UInt8)](#func-countonesuint8) instead.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The input 8-bit unsigned integer.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the count of 1 bits in the binary representation of the input parameter.

## func countOnes(UInt8)

```cangjie
public func countOnes(x: UInt8): Int64
```

Function: Counts the number of 1 bits in the binary representation of an 8-bit unsigned integer.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The input 8-bit unsigned integer.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the count of 1 bits in the binary representation of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.countOnes

main() {
    let n: UInt8 = 15
    let countOnes = countOnes(n)
    println(countOnes)
}
```

Execution Result:

```text
4
```

## func erf(Float16)

```cangjie
public func erf(x: Float16): Float16
```

Function: Calculates the error function value for a half-precision floating-point number. The definition is: $$erf(x) = \frac{2}{\sqrt{\pi}}\int_0^xe^{-t^2}dt$$.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the error function value of the input half-precision floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.erf

main() {
    let n: Float16 = 5.0
    let erf = erf(n)
    println(erf)
}
```

Execution Result:

```text
1.000000
```

## func erf(Float32)

```cangjie
public func erf(x: Float32): Float32
```

Function: Calculates the error function value for a single-precision floating-point number. The definition is: $$erf(x) = \frac{2}{\sqrt{\pi}}\int_0^xe^{-t^2}dt$$.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the error function value of the input single-precision floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.erf

main() {
    let n: Float32 = 5.0
    let erf = erf(n)
    println(erf)
}
```

Execution Result:

```text
1.000000
```

## func erf(Float64)

```cangjie
public func erf(x: Float64): Float64
```

Function: Computes the error function value of a double-precision floating-point number. The mathematical definition is: $$erf(x) = \frac{2}{\sqrt{\pi}}\int_0^xe^{-t^2}dt$$.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the error function value of the input double-precision floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.erf

main() {
    let n: Float64 = 5.0
    let erf = erf(n)
    println(erf)
}
```

Execution Result:

```text
1.000000
```

## func exp(Float16)

```cangjie
public func exp(x: Float16): Float16
```

Function: Computes the natural constant e raised to the power of `x`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point exponent.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns e raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp

main() {
    let n: Float16 = 1.0
    let exp = exp(n)
    println(exp)
}
```

Execution Result:

```text
2.718750
```

## func exp(Float32)

```cangjie
public func exp(x: Float32): Float32
```

Function: Computes the natural constant e raised to the power of `x`.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point exponent.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns e raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp

main() {
    let n: Float32 = 1.0
    let exp = exp(n)
    println(exp)
}
```

Execution Result:

```text
2.718282
```

## func exp(Float64)

```cangjie
public func exp(x: Float64): Float64
```

Function: Computes the natural constant e raised to the power of `x`.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point exponent.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns e raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp

main() {
    let n: Float64 = 1.0
    let exp = exp(n)
    println(exp)
```

Running result:

```text
2.718282
```

## func exp2(Float16)

```cangjie
public func exp2(x: Float16): Float16
```

Function: Calculate 2 raised to the power of `x`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point exponent.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns 2 raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp2

main() {
    let n: Float16 = 10.0
    let exp2 = exp2(n)
    println(exp2)
}
```

Running result:

```text
1024.000000
```

## func exp2(Float32)

```cangjie
public func exp2(x: Float32): Float32
```

Function: Calculate 2 raised to the power of `x`.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point exponent.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns 2 raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp2

main() {
    let n: Float32 = 10.0
    let exp2 = exp2(n)
    println(exp2)
}
```

Running result:

```text
1024.000000
```

## func exp2(Float64)

```cangjie
public func exp2(x: Float64): Float64
```

Function: Calculate 2 raised to the power of `x`.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point exponent.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns 2 raised to the power of `x`.

Example:
<!-- verify -->
```cangjie
import std.math.exp2

main() {
    let n: Float64 = 10.0
    let exp = exp2(n)
    println(exp)
}
```

Running result:

```text
1024.000000
```

## func floor(Float16)

```cangjie
public func floor(x: Float16): Float16
```

Function: Calculate the floor value of a floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number to be floored.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the floor value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.floor

main() {
    let n: Float16 = 10.5
    let floor = floor(n)
    println(floor)
}
```

Running result:

```text
10.000000
```

## func floor(Float32)

```cangjie
public func floor(x: Float32): Float32
```

Function: Compute the floor value of a floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The single-precision floating-point number to be floored.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the floor value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.floor

main() {
    let n: Float32 = 10.5
    let floor = floor(n)
    println(floor)
}
```

Execution Result:

```text
10.000000
```

## func floor(Float64)

```cangjie
public func floor(x: Float64): Float64
```

Function: Compute the floor value of a floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The double-precision floating-point number to be floored.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the floor value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.floor

main() {
    let n: Float64 = 10.5
    let floor = floor(n)
    println(floor)
}
```

Execution Result:

```text
10.000000
```

## func fmod(Float16, Float16)

```cangjie
public func fmod(x: Float16, y: Float16): Float16
```

Function: Compute the remainder of two half-precision floating-point numbers x/y.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The dividend.
- y: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The divisor.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the remainder of x/y. Returns `NaN` when either x or y is `NaN`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when x is `Inf` or y is 0.

Example:
<!-- verify -->
```cangjie
import std.math.fmod
import std.convert.Formattable

main() {
    let x: Float16 = 3.3
    let y: Float16 = 2.2
    let fmod = fmod(x, y)
    println(fmod.format(".1"))
}
```

Execution Result:

```text
1.1
```

## func fmod(Float32, Float32)

```cangjie
public func fmod(x: Float32, y: Float32): Float32
```

Function: Compute the remainder of two single-precision floating-point numbers x/y.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The dividend.
- y: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The divisor.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the remainder of x/y. Returns `NaN` when either x or y is `NaN`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when x is `Inf` or y is 0.

Example:
<!-- verify -->
```cangjie
import std.math.fmod
import std.convert.Formattable

main() {
    let x: Float32 = 3.3
    let y: Float32 = 2.2
    let fmod = fmod(x, y)
    println(fmod.format(".1"))
}
```

Execution Result:

```text
1.1
```

## func fmod(Float64, Float64)

```cangjie
public func fmod(x: Float64, y: Float64): Float64
```

Function: Computes the remainder of two double-precision floating-point numbers x/y.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The dividend.
- y: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The divisor.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the remainder of x/y. Returns `NaN` if x or y is `NaN`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if x is `Inf` or y is 0.

Example:
<!-- verify -->
```cangjie
import std.math.fmod
import std.convert.Formattable

main() {
    let x: Float64 = 3.3
    let y: Float64 = 2.2
    let fmod = fmod(x, y)
    println(fmod.format(".1"))
}
```

Output:

```text
1.1
```

## func gamma(Float16)

```cangjie
public func gamma(x: Float16): Float16
```

Function: Computes the gamma function value of a floating-point number, which extends the factorial concept to real numbers. The evaluation formula is:

$${\Gamma (x)=\int _{0}^{\infty }t^{x-1}{e}^{-t}{\rm {{d}t,}}}$$

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The half-precision floating-point number for which the gamma function value is to be computed.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the gamma function value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.gamma

main() {
    let n: Float16 = -1.1
    let gamma = gamma(n)
    println(gamma)
}
```

Output:

```text
9.750000
```

## func gamma(Float32)

```cangjie
public func gamma(x: Float32): Float32
```

Function: Computes the gamma function value of a floating-point number, which extends the factorial concept to real numbers.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The single-precision floating-point number for which the gamma function value is to be computed.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the gamma function value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.gamma

main() {
    let n: Float32 = -1.1
    let gamma = gamma(n)
    println(gamma)
}
```

Output:

```text
9.714804
```

## func gamma(Float64)

```cangjie
public func gamma(x: Float64): Float64
```

Function: Computes the gamma function value of a floating-point number, which extends the factorial concept to real numbers.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The double-precision floating-point number for which the gamma function value is to be computed.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the gamma function value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.gamma

main() {
    let n: Float64 = -1.1
    let gamma = gamma(n)
    println(gamma)
}
```

Output:

```text
9.714806
```

## func gcd(Int16, Int16)

```cangjie
public func gcd(x: Int16, y: Int16): Int16
```

Function: Computes the greatest common divisor (GCD) of two 16-bit signed integers.

Parameters:- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The first integer for GCD calculation.

- y: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The second integer for GCD calculation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - Returns the greatest common divisor of the two integers.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when both parameters are the minimum value of signed integers, or when one parameter is the minimum value of signed integers and the other is 0.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: Int16 = 15
    let y: Int16 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Execution Result:

```text
3
```

## func gcd(Int32, Int32)

```cangjie
public func gcd(x: Int32, y: Int32): Int32
```

Function: Calculates the greatest common divisor of two 32-bit signed integers.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The first integer for GCD calculation.
- y: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The second integer for GCD calculation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Returns the greatest common divisor of the two integers.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when both parameters are the minimum value of signed integers, or when one parameter is the minimum value of signed integers and the other is 0.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: Int32 = 15
    let y: Int32 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Execution Result:

```text
3
```

## func gcd(Int64, Int64)

```cangjie
public func gcd(x: Int64, y: Int64): Int64
```

Function: Calculates the greatest common divisor of two 64-bit signed integers.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The first integer for GCD calculation.
- y: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The second integer for GCD calculation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the greatest common divisor of the two integers.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when both parameters are the minimum value of signed integers, or when one parameter is the minimum value of signed integers and the other is 0.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: Int64 = 15
    let y: Int64 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Execution Result:

```text
3
```

## func gcd(Int8, Int8)

```cangjie
public func gcd(x: Int8, y: Int8): Int8
```

Function: Calculates the greatest common divisor of two 8-bit signed integers.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The first integer for GCD calculation.
- y: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The second integer for GCD calculation.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the greatest common divisor of the two integers.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when both parameters are the minimum value of signed integers, or when one parameter is the minimum value of signed integers and the other is 0.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: Int8 = 15
    let y: Int8 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Execution Result:

```text
3
```

## func gcd(UInt16, UInt16)

```cangjie
public func gcd(x: UInt16, y: UInt16): UInt16
```

Function: Calculates the greatest common divisor (GCD) of two 16-bit unsigned integers.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The first integer for GCD calculation.
- y: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The second integer for GCD calculation.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The greatest common divisor of the two integers.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: UInt16 = 15
    let y: UInt16 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Output:

```text
3
```

## func gcd(UInt32, UInt32)

```cangjie
public func gcd(x: UInt32, y: UInt32): UInt32
```

Function: Calculates the greatest common divisor (GCD) of two 32-bit unsigned integers.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The first integer for GCD calculation.
- y: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The second integer for GCD calculation.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The greatest common divisor of the two integers.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: UInt32 = 15
    let y: UInt32 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Output:

```text
3
```

## func gcd(UInt64, UInt64)

```cangjie
public func gcd(x: UInt64, y: UInt64): UInt64
```

Function: Calculates the greatest common divisor (GCD) of two 64-bit unsigned integers.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The first integer for GCD calculation.
- y: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The second integer for GCD calculation.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The greatest common divisor of the two integers.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: UInt64 = 15
    let y: UInt64 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Output:

```text
3
```

## func gcd(UInt8, UInt8)

```cangjie
public func gcd(x: UInt8, y: UInt8): UInt8
```

Function: Calculates the greatest common divisor (GCD) of two 8-bit unsigned integers.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The first integer for GCD calculation.
- y: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The second integer for GCD calculation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The greatest common divisor of the two integers.

Example:
<!-- verify -->
```cangjie
import std.math.gcd

main() {
    let x: UInt8 = 15
    let y: UInt8 = 9
    let gcd = gcd(x, y)
    println(gcd)
}
```

Output:

```text
3
```

## func lcm(Int16, Int16)

```cangjie
public func lcm(x: Int16, y: Int16): Int16
```

Function: Computes the least common non-negative multiple of two 16-bit signed integers. Returns 0 only when either input is 0.

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The first integer for LCM calculation.
- y: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The second integer for LCM calculation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 16-bit signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: Int16 = -15
    let y: Int16 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(Int32, Int32)

```cangjie
public func lcm(x: Int32, y: Int32): Int32
```

Function: Computes the least common non-negative multiple of two 32-bit signed integers. Returns 0 only when either input is 0.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The first integer for LCM calculation.
- y: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The second integer for LCM calculation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 32-bit signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: Int32 = -15
    let y: Int32 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(Int64, Int64)

```cangjie
public func lcm(x: Int64, y: Int64): Int64
```

Function: Computes the least common non-negative multiple of two 64-bit signed integers. Returns 0 only when either input is 0.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The first integer for LCM calculation.
- y: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The second integer for LCM calculation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 64-bit signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: Int64 = 15
    let y: Int64 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(Int8, Int8)

```cangjie
public func lcm(x: Int8, y: Int8): Int8
```

Function: Computes the least common non-negative multiple of two 8-bit signed integers. Returns 0 only when either input is 0.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The first integer for LCM calculation.
- y: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The second integer for LCM calculation.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of an 8-bit signed integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: Int8 = 15
    let y: Int8 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(UInt16, UInt16)

```cangjie
public func lcm(x: UInt16, y: UInt16): UInt16
```

Function: Calculates the least common non-negative multiple of two 16-bit unsigned integers. Returns 0 only when either input is 0.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The first integer for LCM calculation.
- y: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The second integer for LCM calculation.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 16-bit unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: UInt16 = 15
    let y: UInt16 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(UInt32, UInt32)

```cangjie
public func lcm(x: UInt32, y: UInt32): UInt32
```

Function: Calculates the least common non-negative multiple of two 32-bit unsigned integers. Returns 0 only when either input is 0.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The first integer for LCM calculation.
- y: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The second integer for LCM calculation.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 32-bit unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: UInt32 = 15
    let y: UInt32 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(UInt64, UInt64)

```cangjie
public func lcm(x: UInt64, y: UInt64): UInt64
```

Function: Calculates the least common non-negative multiple of two 64-bit unsigned integers. Returns 0 only when either input is 0.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The first integer for LCM calculation.
- y: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The second integer for LCM calculation.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of a 64-bit unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm

main() {
    let x: UInt64 = 15
    let y: UInt64 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Output:

```text
45
```

## func lcm(UInt8, UInt8)

```cangjie
public func lcm(x: UInt8, y: UInt8): UInt8
```

Function: Calculates the least common non-negative multiple of two 8-bit unsigned integers. Returns 0 only when either input is 0.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The first integer for LCM calculation.
- y: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The second integer for LCM calculation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The least common non-negative multiple of the two integers. Returns 0 only when either input is 0.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the return value exceeds the maximum value of an 8-bit unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.lcm
main() {
    let x: UInt8 = 15
    let y: UInt8 = 9
    let lcm = lcm(x, y)
    println(lcm)
}
```

Execution result:

```text
45
```

## func leadingZeros(Int16)

```cangjie
public func leadingZeros(x: Int16): Int64
```

Function: Calculates the number of consecutive zero bits starting from the most significant bit in the binary representation of a 16-bit signed integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: Int16 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution result:

```text
6
```

## func leadingZeros(Int32)

```cangjie
public func leadingZeros(x: Int32): Int64
```

Function: Calculates the number of consecutive zero bits starting from the most significant bit in the binary representation of a 32-bit signed integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: Int32 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution result:

```text
22
```

## func leadingZeros(Int64)

```cangjie
public func leadingZeros(x: Int64): Int64
```

Function: Calculates the number of consecutive zero bits starting from the most significant bit in the binary representation of a 64-bit signed integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: Int64 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution result:

```text
54
```

## func leadingZeros(Int8)

```cangjie
public func leadingZeros(x: Int8): Int64
```

Function: Calculates the number of consecutive zero bits starting from the most significant bit in the binary representation of an 8-bit signed integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: Int8 = 4
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution result:

```text
5
```

## func leadingZeros(UInt16)

```cangjie
public func leadingZeros(x: UInt16): Int64
```

Function: Counts the number of consecutive zero bits starting from the most significant bit in the binary representation of a 16-bit unsigned integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: UInt16 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution Result:

```text
6
```

## func leadingZeros(UInt32)

```cangjie
public func leadingZeros(x: UInt32): Int64
```

Function: Counts the number of consecutive zero bits starting from the most significant bit in the binary representation of a 32-bit unsigned integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: UInt32 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution Result:

```text
22
```

## func leadingZeros(UInt64)

```cangjie
public func leadingZeros(x: UInt64): Int64
```

Function: Counts the number of consecutive zero bits starting from the most significant bit in the binary representation of a 64-bit unsigned integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: UInt64 = 512
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution Result:

```text
54
```

## func leadingZeros(UInt8)

```cangjie
public func leadingZeros(x: UInt8): Int64
```

Function: Counts the number of consecutive zero bits starting from the most significant bit in the binary representation of an 8-bit unsigned integer. Returns 0 if the most significant bit is not 0.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The integer for which to count leading zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of leading zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.leadingZeros

main() {
    let x: UInt8 = 64
    let leadingZeros = leadingZeros(x)
    println(leadingZeros)
}
```

Execution Result:

```text
1
```

## func log(Float16)

```cangjie
public func log(x: Float16): Float16
```

Function: Computes the natural logarithm (base e) of `x`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The antilogarithm.

Returns:- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the natural logarithm of `x` (base e).

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).

Example:
<!-- verify -->
```cangjie
import std.math.log

main() {
    let x: Float16 = 2.718282
    let log1 = log(x)
    let log2 = log(-x)
    let log3 = log(0.0)

    println(log1)
    println(log2)
    println(log3)

    let log4 = -log3
    println(log4)
}
```

Output:

```text
1.000000
nan
-inf
inf
```

## func log(Float32)

```cangjie
public func log(x: Float32): Float32
```

Function: Computes the natural logarithm of `x` (base e).

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The argument.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The natural logarithm of `x` (base e).

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).

Example:
<!-- verify -->
```cangjie
import std.math.log

main() {
    let x: Float32 = 2.718282
    let log = log(x)
    println(log)
}
```

Output:

```text
1.000000
```

## func log(Float64)

```cangjie
public func log(x: Float64): Float64
```

Function: Computes the natural logarithm of `x` (base e).

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The argument.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The natural logarithm of `x` (base e).

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).

Example:
<!-- verify -->
```cangjie
import std.math.log

main() {
    let x: Float64 = 2.718282
    let log = log(x)
    println(log)
}
```

Output:

```text
1.000000
```

## func log10(Float16)

```cangjie
public func log10(x: Float16): Float16
```

Function: Computes the base-10 logarithm of `x`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The argument.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The base-10 logarithm of `x`.

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).

Example:
<!-- verify -->
```cangjie
import std.math.log10

main() {
    let x: Float16 = 1000.0
    let log10 = log10(x)
    println(log10)
}
```

Execution result:

```text
3.000000
```

## func log10(Float32)

```cangjie
public func log10(x: Float32): Float32
```

Function: Computes the base-10 logarithm of `x`.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The argument (antilogarithm).

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the base-10 logarithm of `x`.

> **Note:**
>
> Special return value cases:
>
> - If `x` is negative or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).

Example:
<!-- verify -->
```cangjie
import std.math.log10

main() {
    let x: Float32 = 1000.0
    let log10 = log10(x)
    println(log10)
}
```

Execution result:

```text
3.000000
```

## func log10(Float64)

```cangjie
public func log10(x: Float64): Float64
```

Function: Computes the base-10 logarithm of `x`.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The argument (antilogarithm).

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the base-10 logarithm of `x`.

> **Note:**
>
> Special return value cases:
>
> - If `x` is negative or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).

Example:
<!-- verify -->
```cangjie
import std.math.log10

main() {
    let x: Float64 = 1000.0
    let log10 = log10(x)
    println(log10)
}
```

Execution result:

```text
3.000000
```

## func log2(Float16)

```cangjie
public func log2(x: Float16): Float16
```

Function: Computes the base-2 logarithm of `x`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The argument (antilogarithm).

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the base-2 logarithm of `x`.

> **Note:**
>
> Special return value cases:
>
> - If `x` is negative or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf).

Example:
<!-- verify -->
```cangjie
import std.math.log2

main() {
    let x: Float16 = 1024.0
    let log2 = log2(x)
    println(log2)
}
```

Execution result:

```text
10.000000
```

## func log2(Float32)

```cangjie
public func log2(x: Float32): Float32
```

Function: Computes the base-2 logarithm of `x`.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The argument.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the base-2 logarithm of `x`.

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-1).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-1).

Example:
<!-- verify -->
```cangjie
import std.math.log2

main() {
    let x: Float32 = 1024.0
    let log2 = log2(x)
    println(log2)
}
```

Output:

```text
10.000000
```

## func log2(Float64)

```cangjie
public func log2(x: Float64): Float64
```

Function: Computes the base-2 logarithm of `x`.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The argument.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the base-2 logarithm of `x`.

> **Note:**
>
> The return value has the following special cases:
>
> - If `x` is less than 0 or [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2), returns [NaN](../../core/core_package_api/core_package_intrinsics.md#static-prop-nan-2).
> - If `x` equals 0, returns -[Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).
> - If `x` is [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2), returns [Inf](../../core/core_package_api/core_package_intrinsics.md#static-prop-inf-2).

Example:
<!-- verify -->
```cangjie
import std.math.log2

main() {
    let x: Float64 = 1024.0
    let log2 = log2(x)
    println(log2)
}
```

Output:

```text
10.000000
```

## func logBase(Float16, Float16)

```cangjie
public func logBase(x: Float16, base: Float16): Float16
```

Function: Computes the logarithm of `x` with base `base`.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The argument. Must be greater than 0.
- base: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The base. Must be greater than 0 and not equal to 1.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the logarithm of `x` with base `base`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the argument or base is not positive, or if the base equals 1.

Example:
<!-- verify -->
```cangjie
import std.math.logBase

main() {
    let x: Float16 = 512.0
    let base: Float16 = 2.0
    let logBase = logBase(x, base)
    println(logBase)
}
```

Output:

```text
9.000000
```

The following examples will throw corresponding exceptions:
<!-- verify -->
```cangjie
import std.math.logBase

main() {
    let x: Float16 = 512.0
    let base: Float16 = -2.0

    // Example 1: Negative base
    try {
        let logBase1 = logBase(x, base)
        println(logBase1)
    } catch (e: IllegalArgumentException) {
        println("Exception 1: Negative base")
    }

    // Example 2: Negative argument
    try {
        let logBase2 = logBase(-x, base)
        println(logBase2)
    } catch (e: IllegalArgumentException) {
        println("Exception 2: Negative argument")
    }

    // Example 3: Base equals 1
    try {
        let logBase3 = logBase(x, 1.0)
        println(logBase3)
    } catch (e: IllegalArgumentException) {
        println("Exception 3: Base equals 1")
    }
}
```

Execution Result:

```text
Exception 1: Base is negative
Exception 2: Antilogarithm is negative
Exception 3: Base equals 1
```

## func logBase(Float32, Float32)

```cangjie
public func logBase(x: Float32, base: Float32): Float32
```

Function: Calculates the logarithm of `x` with base `base`.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Antilogarithm. Must be greater than 0.
- base: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Base. Must be greater than 0 and not equal to 1.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the logarithm of `x` with base `base`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws exception when antilogarithm or base is non-positive, or base equals 1.

Example:
<!-- verify -->
```cangjie
import std.math.logBase

main() {
    let x: Float32 = 1024.0
    let base: Float32 = 2.0
    let logBase = logBase(x, base)
    println(logBase)
}
```

Execution Result:

```text
10.000000
```

## func logBase(Float64, Float64)

```cangjie
public func logBase(x: Float64, base: Float64): Float64
```

Function: Calculates the logarithm of `x` with base `base`.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Antilogarithm. Must be greater than 0.
- base: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Base. Must be greater than 0 and not equal to 1.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the logarithm of `x` with base `base`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws exception when antilogarithm or base is non-positive, or base equals 1.

Example:
<!-- verify -->
```cangjie
import std.math.logBase

main() {
    let x: Float64 = 1024.0
    let base: Float64 = 2.0
    let logBase = logBase(x, base)
    println(logBase)
}
```

Execution Result:

```text
10.000000
```

## func pow(Float32, Float32)

```cangjie
public func pow(base: Float32, exponent: Float32): Float32
```

Function: Calculates the `exponent` power of floating-point number `base`.

Parameters:

- base: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Base number.
- exponent: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Exponent.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the `exponent` power of the input floating-point number `base`. Returns `nan` if the value doesn't exist.

Example:
<!-- verify -->
```cangjie
import std.math.pow

main() {
    let base: Float32 = -1.0
    let exponent: Float32 = 0.5
    let pow = pow(base, exponent)
    println(pow)
}
```

Execution Result:

```text
nan
```

## func pow(Float32, Int32)

```cangjie
public func pow(base: Float32, exponent: Int32): Float32
```

Function: Calculates the `exponent` power of floating-point number `base`.

Parameters:

- base: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Base number.
- exponent: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Exponent.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the `exponent` power of the input floating-point number `base`.

Example:
<!-- verify -->
```cangjie
import std.math.pow

main() {
    let base: Float32 = -1.0
    let exponent: Int32 = 2
    let pow = pow(base, exponent)
    println(pow)
}
```

Execution result:

```text
1.000000
```

## func pow(Float64, Float64)

```cangjie
public func pow(base: Float64, exponent: Float64): Float64
```

Function: Calculates the power of floating-point number `base` raised to `exponent`.

Parameters:

- base: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The base number.
- exponent: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The exponent.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the result of `base` raised to `exponent`. Returns `nan` if the value does not exist.

Example:
<!-- verify -->
```cangjie
import std.math.pow

main() {
    let base: Float64 = -1.0
    let exponent: Float64 = 0.5
    let pow = pow(base, exponent)
    println(pow)
}
```

Execution result:

```text
nan
```

## func pow(Float64, Int64)

```cangjie
public func pow(base: Float64, exponent: Int64): Float64
```

Function: Calculates the power of floating-point number `base` raised to `exponent`.

Parameters:

- base: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The base number.
- exponent: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The exponent.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the result of `base` raised to `exponent`.

Example:
<!-- verify -->
```cangjie
import std.math.pow

main() {
    let base: Float64 = -1.0
    let exponent: Int64 = 2
    let pow = pow(base, exponent)
    println(pow)
}
```

Execution result:

```text
1.000000
```

## func reverse(UInt16)

```cangjie
public func reverse(x: UInt16): UInt16
```

Function: Reverses the bits of an unsigned integer.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The unsigned integer to be reversed.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Returns the reversed unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.reverse

main() {
    let n: UInt16 = 0x8000
    let reverse = reverse(n)
    println(reverse)
}
```

Execution result:

```text
1
```

## func reverse(UInt32)

```cangjie
public func reverse(x: UInt32): UInt32
```

Function: Reverses the bits of an unsigned integer.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The unsigned integer to be reversed.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Returns the reversed unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.reverse

main() {
    let n: UInt32 = 0x8000_0000
    let reverse = reverse(n)
    println(reverse)
}
```

Execution result:

```text
1
```

## func reverse(UInt64)

```cangjie
public func reverse(x: UInt64): UInt64
```

Function: Returns the bitwise reversed value of an unsigned integer.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The unsigned integer to be reversed.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The reversed unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.reverse

main() {
    let n: UInt64 = 0x8000_0000_0000_0000
    let reverse = reverse(n)
    println(reverse)
}
```

Output:

```text
1
```

## func reverse(UInt8)

```cangjie
public func reverse(x: UInt8): UInt8
```

Function: Returns the bitwise reversed value of an unsigned integer.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The unsigned integer to be reversed.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The reversed unsigned integer.

Example:
<!-- verify -->
```cangjie
import std.math.reverse

main() {
    let n: UInt8 = 0x80
    let reverse = reverse(n)
    println(reverse)
}
```

Output:

```text
1
```

## func rotate(Int16, Int8)

```cangjie
public func rotate(num: Int16, d: Int8): Int16
```

Function: Returns the bitwise rotated value of an integer.

Parameters:

- num: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate (negative for right shift, positive for left shift).

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: Int16 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Output:

```text
4
```

## func rotate(Int32, Int8)

```cangjie
public func rotate(num: Int32, d: Int8): Int32
```

Function: Returns the bitwise rotated value of an integer.

Parameters:

- num: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate (negative for right shift, positive for left shift).

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: Int32 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Output:

```text
4
```

## func rotate(Int64, Int8)

```cangjie
public func rotate(num: Int64, d: Int8): Int64
```

Function: Performs bitwise rotation on an integer and returns the result.

Parameters:

- num: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: Int64 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func rotate(Int8, Int8)

```cangjie
public func rotate(num: Int8, d: Int8): Int8
```

Function: Computes the result of bitwise rotation of an integer.

Parameters:

- num: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: Int8 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func rotate(UInt16, Int8)

```cangjie
public func rotate(num: UInt16, d: Int8): UInt16
```

Function: Computes the result of bitwise rotation of an integer.

Parameters:

- num: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: UInt16 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func rotate(UInt32, Int8)

```cangjie
public func rotate(num: UInt32, d: Int8): UInt32
```

Function: Computes the result of bitwise rotation of an integer.

Parameters:

- num: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: UInt32 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func rotate(UInt64, Int8)

```cangjie
public func rotate(num: UInt64, d: Int8): UInt64
```

Function: Computes the result of bitwise rotation of an integer.

Parameters:

- num: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: UInt64 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func rotate(UInt8, Int8)

```cangjie
public func rotate(num: UInt8, d: Int8): UInt8
```

Function: Computes the result of bitwise rotation of an integer.

Parameters:

- num: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Input integer.
- d: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Number of bits to rotate. Negative values indicate right shift, positive values indicate left shift.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Returns the rotated integer.

Example:
<!-- verify -->
```cangjie
import std.math.rotate

main() {
    let n: UInt8 = 1
    let rotate = rotate(n, 2)
    println(rotate)
}
```

Execution Result:

```text
4
```

## func round(Float16)

```cangjie
public func round(x: Float16): Float16
```

Function: This function uses IEEE-754's round-to-nearest rule to compute the rounded value of a floating-point number. If the number is exactly halfway between two integers, it rounds to the nearest even integer.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The floating-point number to be rounded.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the rounded value of the floating-point number. If the number is exactly halfway between two integers, it returns the nearest even integer.

Example:
<!-- verify -->
```cangjie
import std.math.round

main() {
    let n: Float16 = 1.5
    let round = round(n)
    println(round)
}
```

Execution Result:

```text
2.000000
```

## func round(Float32)

```cangjie
public func round(x: Float32): Float32
```

Function: This function uses IEEE-754's round-to-nearest rule to compute the rounded value of a floating-point number. If the number is exactly halfway between two integers, it rounds to the nearest even integer.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The floating-point number to be rounded.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the rounded value of the floating-point number. If the number is exactly halfway between two integers, it returns the nearest even integer.

Example:
<!-- verify -->
```cangjie
import std.math.round

main() {
    let n: Float32 = 1.5
    let round = round(n)
    println(round)
}
```

Execution Result:

```text
2.000000
```

## func round(Float64)

```cangjie
public func round(x: Float64): Float64
```

Function: This function uses IEEE-754's round-to-nearest rule to compute the rounded value of a floating-point number. If the number is exactly halfway between two integers, it rounds to the nearest even integer.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The floating-point number to be rounded.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the rounded value of the floating-point number. If the number is exactly halfway between two integers, it returns the nearest even integer.

Example:
<!-- verify -->
```cangjie
import std.math.round

main() {
    let n: Float64 = 1.5
    let round = round(n)
    println(round)
}
```

Execution Result:

```text
2.000000
```

## func sin(Float16)

```cangjie
public func sin(x: Float16): Float16
```

Function: Computes the sine value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number in radians.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sin

main() {
    let n: Float16 = 3.1415926 / 2.0
    let sin = sin(n)
    println(sin)
}
```

Execution Result:

```text
1.000000
```

## func sin(Float32)

```cangjie
public func sin(x: Float32): Float32
```

Function: Computes the sine value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number in radians.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sin

main() {
    let n: Float32 = 3.1415926 / 2.0
    let sin = sin(n)
    println(sin)
}
```

Execution Result:

```text
1.000000
```

## func sin(Float64)

```cangjie
public func sin(x: Float64): Float64
```

Function: Computes the sine value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number in radians.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sin

main() {
    let n: Float64 = 3.1415926 / 2.0
    let sin = sin(n)
    println(sin)
}
```

Execution Result:

```text
1.000000
```

## func sinh(Float16)

```cangjie
public func sinh(x: Float16): Float16
```

Function: Computes the hyperbolic sine value of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sinh

main() {
    let n: Float16 = 0.0
    let sinh = sinh(n)
    println(sinh)
}
```

Execution Result:

```text
0.000000
```

## func sinh(Float32)

```cangjie
public func sinh(x: Float32): Float32
```

Function: Computes the hyperbolic sine value of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sinh

main() {
    let n: Float32 = 0.0
    let sinh = sinh(n)
    println(sinh)
}
```

Execution Result:

```text
0.000000
```

## func sinh(Float64)

```cangjie
public func sinh(x: Float64): Float64
```

Function: Computes the hyperbolic sine of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sinh

main() {
    let n: Float64 = 0.0
    let sinh = sinh(n)
    println(sinh)
}
```

Execution Result:

```text
0.000000
```

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sinh

main() {
    let n: Float32 = 0.0
    let sinh = sinh(n)
    println(sinh)
}
```

Execution result:

```text
0.000000
```

## func sinh(Float64)

```cangjie
public func sinh(x: Float64): Float64
```

Function: Calculates the hyperbolic sine value of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the hyperbolic sine value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.sinh

main() {
    let n: Float64 = 0.0
    let sinh = sinh(n)
    println(sinh)
}
```

Execution result:

```text
0.000000
```

## func sqrt(Float16)

```cangjie
public func sqrt(x: Float16): Float16
```

Function: Calculates the arithmetic square root of a floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The floating-point number for which to calculate the arithmetic square root. `x` must be greater than or equal to 0.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the arithmetic square root of the input floating-point number.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the parameter is negative.

Example:
<!-- verify -->
```cangjie
import std.math.sqrt

main() {
    let n: Float16 = 16.0
    let sqrt = sqrt(n)
    println(sqrt)
}
```

Execution result:

```text
4.000000
```

## func sqrt(Float32)

```cangjie
public func sqrt(x: Float32): Float32
```

Function: Calculates the arithmetic square root of a floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The floating-point number for which to calculate the arithmetic square root. `x` must be greater than or equal to 0.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the arithmetic square root of the input floating-point number.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the parameter is negative.

Example:
<!-- verify -->
```cangjie
import std.math.sqrt

main() {
    let n: Float32 = 16.0
    let sqrt = sqrt(n)
    println(sqrt)
}
```

Execution result:

```text
4.000000
```

## func sqrt(Float64)

```cangjie
public func sqrt(x: Float64): Float64
```

Function: Calculates the arithmetic square root of a floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The floating-point number for which to calculate the arithmetic square root. `x` must be greater than or equal to 0.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the arithmetic square root of the input floating-point number.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the parameter is negative.

Example:
<!-- verify -->
```cangjie
import std.math.sqrt

main() {
    let n: Float64 = 16.0
    let sqrt = sqrt(n)
    println(sqrt)
}
```

Execution result:

```text
4.000000
```

## func tan(Float16)

```cangjie
public func tan(x: Float16): Float16
```

Function: Computes the tangent of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number in radians.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the tangent of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tan

main() {
    let n: Float16 = 0.0
    let tan = tan(n)
    println(tan)
}
```

Execution Result:

```text
0.000000
```

## func tan(Float32)

```cangjie
public func tan(x: Float32): Float32
```

Function: Computes the tangent of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number in radians.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the tangent of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tan

main() {
    let n: Float32 = 0.0
    let tan = tan(n)
    println(tan)
}
```

Execution Result:

```text
0.000000
```

## func tan(Float64)

```cangjie
public func tan(x: Float64): Float64
```

Function: Computes the tangent of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number in radians.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the tangent of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tan

main() {
    let n: Float64 = 0.0
    let tan = tan(n)
    println(tan)
}
```

Execution Result:

```text
0.000000
```

## func tanh(Float16)

```cangjie
public func tanh(x: Float16): Float16
```

Function: Computes the hyperbolic tangent of a half-precision floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Input half-precision floating-point number.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the hyperbolic tangent of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tanh

main() {
    let n: Float16 = 0.0
    let tanh = tanh(n)
    println(tanh)
}
```

Execution Result:

```text
0.000000
```

## func tanh(Float32)

```cangjie
public func tanh(x: Float32): Float32
```

Function: Computes the hyperbolic tangent of a single-precision floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Input single-precision floating-point number.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Hyperbolic tangent value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tanh

main() {
    let n: Float32 = 0.0
    let tanh = tanh(n)
    println(tanh)
}
```

Execution Result:

```text
0.000000
```

## func tanh(Float64)

```cangjie
public func tanh(x: Float64): Float64
```

Function: Computes the hyperbolic tangent of a double-precision floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Input double-precision floating-point number.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Hyperbolic tangent value of the input parameter.

Example:
<!-- verify -->
```cangjie
import std.math.tanh

main() {
    let n: Float64 = 0.0
    let tanh = tanh(n)
    println(tanh)
}
```

Execution Result:

```text
0.000000
```

## func trailingZeros(Int16)

```cangjie
public func trailingZeros(x: Int16): Int64
```

Function: Counts the number of trailing zero bits (starting from the least significant bit) in the binary representation of a 16-bit signed integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - Input integer for counting trailing zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of trailing zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: Int16 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution Result:

```text
9
```

## func trailingZeros(Int32)

```cangjie
public func trailingZeros(x: Int32): Int64
```

Function: Counts the number of trailing zero bits (starting from the least significant bit) in the binary representation of a 32-bit signed integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Input integer for counting trailing zeros.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of trailing zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: Int32 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution Result:

```text
9
```

## func trailingZeros(Int64)

```cangjie
public func trailingZeros(x: Int64): Int64
```

Function: Counts the number of trailing zero bits (starting from the least significant bit) in the binary representation of a 64-bit signed integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of trailing zeros.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: Int64 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
9
```

## func trailingZeros(Int8)

```cangjie
public func trailingZeros(x: Int8): Int64
```

Function: Counts the number of consecutive least significant bits set to 0 in the binary representation of a 16-bit signed integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of trailing zeros.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: Int8 = 64
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
6
```

## func trailingZeros(UInt16)

```cangjie
public func trailingZeros(x: UInt16): Int64
```

Function: Counts the number of consecutive least significant bits set to 0 in the binary representation of a 16-bit unsigned integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of trailing zeros.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: UInt16 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
9
```

## func trailingZeros(UInt32)

```cangjie
public func trailingZeros(x: UInt32): Int64
```

Function: Counts the number of consecutive least significant bits set to 0 in the binary representation of a 32-bit unsigned integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of trailing zeros.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: UInt32 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
9
```

## func trailingZeros(UInt64)

```cangjie
public func trailingZeros(x: UInt64): Int64
```

Function: Counts the number of consecutive least significant bits set to 0 in the binary representation of a 64-bit unsigned integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of trailing zeros.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: UInt64 = 512
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
9
```

## func trailingZeros(UInt8)

```cangjie
public func trailingZeros(x: UInt8): Int64
```

Function: Calculates the number of consecutive least significant bits set to 0 in the binary representation of an 8-bit unsigned integer. Returns 0 if the least significant bit is not 0.

Parameters:

- x: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The integer for which trailing zeros are to be counted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of trailing zero bits.

Example:
<!-- verify -->
```cangjie
import std.math.trailingZeros

main() {
    let x: UInt8 = 64
    let trailingZeros = trailingZeros(x)
    println(trailingZeros)
}
```

Execution result:

```text
6
```

## func trunc(Float16)

```cangjie
public func trunc(x: Float16): Float16
```

Function: Computes the truncated integer value of a floating-point number.

Parameters:

- x: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The floating-point number to be truncated.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - The truncated value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.trunc

main() {
    let x: Float16 = 64.555566
    let trunc = trunc(x)
    println(trunc)
}
```

Execution result:

```text
64.000000
```

## func trunc(Float32)

```cangjie
public func trunc(x: Float32): Float32
```

Function: Computes the truncated integer value of a floating-point number.

Parameters:

- x: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The floating-point number to be truncated.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - The truncated value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.trunc

main() {
    let x: Float32 = 64.555566
    let trunc = trunc(x)
    println(trunc)
}
```

Execution result:

```text
64.000000
```

## func trunc(Float64)

```cangjie
public func trunc(x: Float64): Float64
```

Function: Computes the truncated integer value of a floating-point number.

Parameters:

- x: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The floating-point number to be truncated.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The truncated value of the input floating-point number.

Example:
<!-- verify -->
```cangjie
import std.math.trunc

main() {
    let x: Float64 = 64.555566
    let trunc = trunc(x)
    println(trunc)
}
```

Execution result:

```text
64.000000
```