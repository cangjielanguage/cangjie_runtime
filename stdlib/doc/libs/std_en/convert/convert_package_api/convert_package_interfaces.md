# Interfaces

## interface Formattable

```cangjie
public interface Formattable {
    func format(fmt: String): String
}
```

Function: This interface defines a formatting function that converts an instance of the specified type into a string of corresponding format based on formatting parameters.

For detailed descriptions of formatting parameters, please refer to the [Function Introduction](./../convert_package_overview.md#功能介绍) in the convert package.

Other types can provide formatting functionality by implementing this interface.

### func format(String)

```cangjie
func format(fmt: String): String
```

Function: Formats the current instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current instance.

### extend Float16 <: Formattable

```cangjie
extend Float16 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) to enable formatting [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var f: Float16 = -0.34
    var res1 = f.format("-20")  // Left-aligned, width 20
    var res2 = f.format("20")   // Right-aligned, width 20
    var res3 = f.format("g")    // General format
    var res4 = f.format("e")    // Scientific notation
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"-0.340088           "
"           -0.340088"
"-0.340088"
"-3.400879e-01"
```

### extend Float32 <: Formattable

```cangjie
extend Float32 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) to enable formatting [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var f: Float32 = 3.14159
    var res1 = f.format("-20")   // Left-aligned, width 20
    var res2 = f.format("+20")   // Right-aligned with sign, width 20
    var res3 = f.format("10")    // Right-aligned, width 10
    var res4 = f.format("e")     // Scientific notation
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"3.141590            "
"           +3.141590"
"  3.141590"
"3.141590e+00"
```

### extend Float64 <: Formattable

```cangjie
extend Float64 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) to enable formatting [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var f: Float64 = 3.141592653589793
    var res1 = f.format("-20")   // Left-aligned, width 20
    var res2 = f.format("+20")   // Right-aligned with sign, width 20
    var res3 = f.format("15")    // Right-aligned, width 15
    var res4 = f.format("g")     // General format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"3.141593            "
"           +3.141593"
"       3.141593"
"3.14159"
```

### extend Int16 <: Formattable

```cangjie
extend Int16 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) to enable formatting [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: Int16 = 20
    var res1 = u.format("-10")   // Left-aligned, width 10
    var res2 = u.format("+10")   // Right-aligned with sign, width 10
    var res3 = u.format("10")    // Right-aligned, width 10
    var res4 = u.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"20        "
"       +20"
"        20"
"10100"
```

### extend Int32 <: Formattable

```cangjie
extend Int32 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) to enable formatting [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: Int32 = 20
    var res1 = u.format("-10")   // Left-aligned, width 10
    var res2 = u.format("+10")   // Right-aligned with sign, width 10
    var res3 = u.format("10")    // Right-aligned, width 10
    var res4 = u.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"20        "
"       +20"
"        20"
"10100"
```

### extend Int64 <: Formattable

```cangjie
extend Int64 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) to enable formatting [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var i: Int64 = -123456789
    var res1 = i.format("-20")   // Left-aligned, width 20
    var res2 = i.format("+20")   // Right-aligned with sign, width 20
    var res3 = i.format("20")    // Right-aligned, width 20
    var res4 = i.format("#x")    // Hexadecimal format with prefix
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"-123456789          "
"          -123456789"
"          -123456789"
"-0x75bcd15"
```

### extend Int8 <: Formattable

```cangjie
extend Int8 <: Formattable
```

Function: Extends the [Formattable](convert_package_interfaces.md#interface-formattable) interface for [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) to enable formatting [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) instance into a string of corresponding format based on formatting parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string obtained from the current [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when fmt is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: Int8 = 20
    var res1 = u.format("-10")   // Left-aligned, width 10
    var res2 = u.format("+10")   // Right-aligned with sign, width 10
    var res3 = u.format("10")    // Right-aligned, width 10
    var res4 = u.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Execution Result:

```text
"20        "
"       +20"
"        20"
"10100"
```

### extend Rune <: Formattable

```cangjie
extend Rune <: Formattable
```

Function: Extends the [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) type with the [Formattable](convert_package_interfaces.md#interface-formattable) interface to enable formatting Rune instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) instance into a string according to the specified format parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string representation of the current [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the fmt parameter is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var r: Rune = 'A'
    var res1 = r.format("-10")   // Left-aligned, width 10
    var res2 = r.format("10")    // Right-aligned, width 10
    
    println("\"${res1}\"")
    println("\"${res2}\"")
}
```

Output:

```text
"A         "
"         A"
```

### extend UInt16 <: Formattable

```cangjie
extend UInt16 <: Formattable
```

Function: Extends the [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) type with the [Formattable](convert_package_interfaces.md#interface-formattable) interface to enable formatting UInt16 instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) instance into a string according to the specified format parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string representation of the current [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the fmt parameter is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var i: UInt16 = 123
    var res1 = i.format("-10")   // Left-aligned, width 10
    var res2 = i.format("+10")   // Right-aligned with sign, width 10
    var res3 = i.format("10")    // Right-aligned, width 10
    var res4 = i.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Output:

```text
"123       "
"      +123"
"       123"
"1111011"
```

### extend UInt32 <: Formattable

```cangjie
extend UInt32 <: Formattable
```

Function: Extends the [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) type with the [Formattable](convert_package_interfaces.md#interface-formattable) interface to enable formatting UInt32 instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) instance into a string according to the specified format parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string representation of the current [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the fmt parameter is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: UInt32 = 200
    var res1 = u.format("-10")   // Left-aligned, width 10
    var res2 = u.format("+10")   // Right-aligned with sign, width 10
    var res3 = u.format("10")    // Right-aligned, width 10
    var res4 = u.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Output:

```text
"200       "
"      +200"
"       200"
"11001000"
```

### extend UInt64 <: Formattable

```cangjie
extend UInt64 <: Formattable
```

Function: Extends the [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type with the [Formattable](convert_package_interfaces.md#interface-formattable) interface to enable formatting UInt64 instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) instance into a string according to the specified format parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string representation of the current [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the fmt parameter is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: UInt64 = 18446744073709551615
    var res1 = u.format("-20")   // Left-aligned, width 20
    var res2 = u.format("20")    // Right-aligned, width 20
    var res3 = u.format("#x")    // Hexadecimal format with prefix
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
}
```

Output:

```text
"18446744073709551615"
"18446744073709551615"
"0xffffffffffffffff"
```

### extend UInt8 <: Formattable

```cangjie
extend UInt8 <: Formattable
```

Function: Extends the [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type with the [Formattable](convert_package_interfaces.md#interface-formattable) interface to enable formatting UInt8 instances into strings.

Parent Type:

- [Formattable](#interface-formattable)

#### func format(String)

```cangjie
public func format(fmt: String): String
```

Function: Formats the current [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) instance into a string according to the specified format parameters.

Parameters:

- fmt: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Formatting parameters.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted string representation of the current [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the fmt parameter is invalid.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var u: UInt8 = 200
    var res1 = u.format("-10")   // Left-aligned, width 10
    var res2 = u.format("+10")   // Right-aligned with sign, width 10
    var res3 = u.format("10")    // Right-aligned, width 10
    var res4 = u.format("b")     // Binary format
    
    println("\"${res1}\"")
    println("\"${res2}\"")
    println("\"${res3}\"")
    println("\"${res4}\"")
}
```

Output:

```text
"200       "
"      +200"
"       200"
"11001000"
```

## interface Parsable\<T>

```cangjie
public interface Parsable<T> {
    static func parse(value: String): T
    static func tryParse(value: String): Option<T>
}
```

Function: This interface provides unified methods to support parsing strings into specific types.

The interface provides two sets of methods: parse and tryParse. The parse method throws an exception on parsing failure, while tryParse wraps the return value in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) and returns None on failure.
This package already implements this interface for basic types such as [Bool](../../core/core_package_api/core_package_intrinsics.md#bool), [Rune](../../core/core_package_api/core_package_intrinsics.md#rune), [Float16](../../core/core_package_api/core_package_intrinsics.md#float16), and [Int64](../../core/core_package_api/core_package_intrinsics.md#int64), enabling string conversion to these types.

### static func parse(String)

```cangjie
static func parse(value: String): T
```

Function: Parses a specific type from a string.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be parsed.

Returns:

- T - The converted value.

### static func tryParse(String)

```cangjie
static func tryParse(value: String): Option<T>
```

Function: Parses a specific type from a string.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be parsed.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The converted value, or [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>.None if conversion fails.

### extend Bool <: Parsable\<Bool>

```cangjie
extend Bool <: Parsable<Bool>
```

Function: This extension primarily implements functions for converting [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type literal strings into [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Bool
```

Function: Converts a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type literal string into a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The converted [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty or conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strTrue: String = "true"
    var strFalse: String = "false"
    var res1 = Bool.parse(strTrue)
    var res2 = Bool.parse(strFalse)
    
    println("After the conversion of parse, \"true\" became ${res1}")
    println("After the conversion of parse, \"false\" became ${res2}")
}
```

Output:

```text
After the conversion of parse, "true" became true
After the conversion of parse, "false" became false
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Bool>
```

Function: Converts a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type literal string into an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)> - The converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)> value, or [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strTrue: String = "true"
    var strFalse: String = "false"
    var res1 = Bool.tryParse(strTrue)
    var res2 = Bool.tryParse(strFalse)
    
    println("After the conversion of tryParse, \"true\" became ${res1}")
    println("After the conversion of tryParse, \"false\" became ${res2}")
}
```

Output:

```text
After the conversion of tryParse, "true" became Some(true)
After the conversion of tryParse, "false" became Some(false)
```

### extend Float16 <: Parsable\<Float16>

```cangjie
extend Float16 <: Parsable<Float16>
```

Function: This extension primarily implements operations for converting string literals of type [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) to [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) values.

> **Note:**
>
> Binary and octal floating-point conversions are currently not supported.

Parent Type:

- [Parsable](#interface-parsablet)\<[Float16](../../core/core_package_api/core_package_intrinsics.md#float16)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Float16
```

Function: Converts a string literal of type [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) to a [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - Returns the converted [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string does not conform to floating-point syntax.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.14159"
    var res = Float16.parse(strFloat)
    
    println("After the conversion of parse, \"3.14159\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "3.14159" became 3.140625
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Float16
```

Function: Converts a string literal of type [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float16](../../core/core_package_api/core_package_intrinsics.md#float16)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float16](../../core/core_package_api/core_package_intrinsics.md#float16)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float16](../../core/core_package_api/core_package_intrinsics.md#float16)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float16](../../core/core_package_api/core_package_intrinsics.md#float16)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.14159"
    var res = Float16.tryParse(strFloat)
    
    println("After the conversion of tryParse, \"3.14159\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "3.14159" became Some(3.140625)
```

### extend Float32 <: Parsable\<Float32>

```cangjie
extend Float32 <: Parsable<Float32>
```

Function: This extension primarily implements operations for converting string literals of type [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) to [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) values.

> **Note:**
>
> Binary and octal floating-point conversions are currently not supported.

Parent Type:

- [Parsable](#interface-parsablet)\<[Float32](../../core/core_package_api/core_package_intrinsics.md#float32)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Float32
```

Function: Converts a string literal of type [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) to a [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - Returns the converted [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string does not conform to floating-point syntax.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.14159"
    var res = Float32.parse(strFloat)
    
    println("After the conversion of parse, \"3.14159\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "3.14159" became 3.141590
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Float32>
```

Function: Converts a string literal of type [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float32](../../core/core_package_api/core_package_intrinsics.md#float32)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float32](../../core/core_package_api/core_package_intrinsics.md#float32)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float32](../../core/core_package_api/core_package_intrinsics.md#float32)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float32](../../core/core_package_api/core_package_intrinsics.md#float32)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.14159"
    var res = Float32.tryParse(strFloat)
    
    println("After the conversion of tryParse, \"3.14159\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "3.14159" became Some(3.141590)
```

### extend Float64 <: Parsable\<Float64>

```cangjie
extend Float64 <: Parsable<Float64>
```

Function: This extension primarily implements operations for converting string literals of type [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) to [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) values.

> **Note:**
>
> Binary and octal floating-point conversions are currently not supported.

Parent Type:

- [Parsable](#interface-parsablet)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Float64
```

Function: Converts a string literal of type [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) to a [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - Returns the converted [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string does not conform to floating-point syntax.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.141592653589793"
    var res = Float64.parse(strFloat)
    
    println("After the conversion of parse, \"3.141592653589793\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "3.141592653589793" became 3.141593
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Float64>
```

Function: Converts a string literal of type [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strFloat: String = "3.141592653589793"
    var res = Float64.tryParse(strFloat)
    
    println("After the conversion of tryParse, \"3.141592653589793\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "3.141592653589793" became Some(3.141593)
```

### extend Int16 <: Parsable\<Int16>

```cangjie
extend Int16 <: Parsable<Int16>
```

Function: This extension primarily implements operations for converting string literals of type [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) to [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Int16
```

Function: Converts a string literal of type [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) to an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - Returns the converted [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+`, conversion fails, the converted value exceeds the [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-32768"
    var res = Int16.parse(strInt)
    
    println("After the conversion of parse, \"-32768\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "-32768" became -32768
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Int16>
```

Function: Converts a string literal of type [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-32768"
    var res = Int16.tryParse(strInt)
    
    println("After the conversion of tryParse, \"-32768\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "-32768" became Some(-32768)
```

### extend Int32 <: Parsable\<Int32>

```cangjie
extend Int32 <: Parsable<Int32>
```

Function: This extension primarily implements operations for converting string literals of type [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) to [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Int32
```

Function: Converts a string literal of type [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) to an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Returns the converted [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+`, conversion fails, the converted value exceeds the [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-2147483648"
    var res = Int32.parse(strInt)
    
    println("After the conversion of parse, \"-2147483648\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "-2147483648" became -2147483648
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Int32>
```

Function: Converts a string literal of type [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-2147483648"
    var res = Int32.tryParse(strInt)
    
    println("After the conversion of tryParse, \"-2147483648\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "-2147483648" became Some(-2147483648)
```

### extend Int64 <: Parsable\<Int64>

```cangjie
extend Int64 <: Parsable<Int64>
```

Function: This extension primarily implements operations for converting string literals of type [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) to [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Int64
```

Function: Converts a string literal of type [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) to an [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the converted [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+`, conversion fails, the converted value exceeds the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-9223372036854775808"
    var res = Int64.parse(strInt)
    
    println("After the conversion of parse, \"-9223372036854775808\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "-9223372036854775808" became -9223372036854775808
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Int64>
```

Function: Converts a string literal of type [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-9223372036854775808"
    var res = Int64.tryParse(strInt)
    
    println("After the conversion of tryParse, \"-9223372036854775808\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "-9223372036854775808" became Some(-9223372036854775808)
```

### extend Int8 <: Parsable\<Int8>

```cangjie
extend Int8 <: Parsable<Int8>
```

Function: This extension primarily implements operations for converting string literals of type [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) to [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Int8
```

Function: Converts a string literal of type [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) to an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - Returns the converted [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+`, conversion fails, the converted value exceeds the [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-128"
    var res = Int8.parse(strInt)
    
    println("After the conversion of parse, \"-128\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "-128" became -128
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Int8>
```

Function: Converts a string literal of type [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt: String = "-128"
    var res = Int8.tryParse(strInt)
    
    println("After the conversion of tryParse, \"-128\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "-128" became Some(-128)
```

### extend Rune <: Parsable\<Rune>

```cangjie
extend Rune <: Parsable<Rune>
```

Function: This extension primarily implements operations for converting string literals of type [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) to [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[Rune](../../core/core_package_api/core_package_intrinsics.md#rune)>

#### static func parse(String)

```cangjie
public static func parse(data: String): Rune
```

Function: Converts a string literal of type [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) to an [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) - Returns the converted [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, conversion fails, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strRune: String = "'A'"
    var res = Rune.parse(strRune)
    
    println("After the conversion of parse, \"'A'\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "'A'" became A
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<Rune>
```

Function: Converts a string literal of type [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../core/core_package_api/core_package_intrinsics.md#rune)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../core/core_package_api/core_package_intrinsics.md#rune)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../core/core_package_api/core_package_intrinsics.md#rune)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../core/core_package_api/core_package_intrinsics.md#rune)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strRune: String = "'A'"
    var res = Rune.tryParse(strRune)
    
    println("After the conversion of tryParse, \"'A'\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "'A'" became Some(A)
```

### extend UInt16 <: Parsable\<UInt16>

```cangjie
extend UInt16 <: Parsable<UInt16>
```

Function: This extension primarily implements operations for converting string literals of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)>

#### static func parse(String)

```cangjie
public static func parse(data: String): UInt16
```

Function: Converts a string literal of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to an [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Returns the converted [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+` or `-`, conversion fails, the converted value exceeds the [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "65535"
    var res = UInt16.parse(strUInt)
    
    println("After the conversion of parse, \"65535\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "65535" became 65535
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<UInt16>
```

Function: Converts a string literal of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "65535"
    var res = UInt16.tryParse(strUInt)
    
    println("After the conversion of tryParse, \"65535\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "65535" became Some(65535)
```

### extend UInt32 <: Parsable\<UInt32>

```cangjie
extend UInt32 <: Parsable<UInt32>
```

Function: This extension primarily implements operations for converting string literals of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) values.

Parent Type:

- [Parsable](#interface-parsablet)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)>

#### static func parse(String)

```cangjie
public static func parse(data: String): UInt32
```

Function: Converts a string literal of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to an [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Returns the converted [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, starts with `+` or `-`, conversion fails, the converted value exceeds the [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "4294967295"
    var res = UInt32.parse(strUInt)
    
    println("After the conversion of parse, \"4294967295\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "4294967295" became 4294967295
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<UInt32>
```

Function: Converts a string literal of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "4294967295"
    var res = UInt32.tryParse(strUInt)
    
    println("After the conversion of tryParse, \"4294967295\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "4294967295" became Some(4294967295)
```

### extend UInt64 <: Parsable\<UInt64>

```cangjie
extend UInt64 <: Parsable<UInt64>
```

Function: This extension primarily implements operations for converting string literals of type [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) to [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) values.

Parent Types:

- [Parsable](#interface-parsablet)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)>

#### static func parse(String)

```cangjie
public static func parse(data: String): UInt64
```

Function: Converts a string literal of type [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) to a [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - Returns the converted [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the string is empty, starts with `+` or `-`, conversion fails, the converted value exceeds the [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "18446744073709551615"
    var res = UInt64.parse(strUInt)
    
    println("After the conversion of parse, \"18446744073709551615\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "18446744073709551615" became 18446744073709551615
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<UInt64>
```

Function: Converts a string literal of type [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "18446744073709551615"
    var res = UInt64.tryParse(strUInt)
    
    println("After the conversion of tryParse, \"18446744073709551615\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "18446744073709551615" became Some(18446744073709551615)
```

### extend UInt8 <: Parsable\<UInt8>

```cangjie
extend UInt8 <: Parsable<UInt8>
```

Function: This extension primarily implements operations for converting string literals of type [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) to [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) values.

Parent Types:

- [Parsable](#interface-parsablet)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)>

#### static func parse(String)

```cangjie
public static func parse(data: String): UInt8
```

Function: Converts a string literal of type [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) to a [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Returns the converted [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the string is empty, starts with `+` or `-`, conversion fails, the converted value exceeds the [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) range, or the string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "255"
    var res = UInt8.parse(strUInt)
    
    println("After the conversion of parse, \"255\" became ${res}")
}
```

Execution Result:

```text
After the conversion of parse, "255" became 255
```

#### static func tryParse(String)

```cangjie
public static func tryParse(data: String): Option<UInt8>
```

Function: Converts a string literal of type [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> value.

Parameters:

- data: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)>.None if conversion fails.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strUInt: String = "255"
    var res = UInt8.tryParse(strUInt)
    
    println("After the conversion of tryParse, \"255\" became ${res}")
}
```

Execution Result:

```text
After the conversion of tryParse, "255" became Some(255)
```

## interface RadixConvertible\<T>

```cangjie
public interface RadixConvertible<T> {
    
    static func parse(value: String, radix!: Int64): T

    static func tryParse(value: String, radix!: Int64): Option<T>

    func toString(radix!: Int64): String
}
```

Function: This interface provides unified methods to support parsing strings of specified radix into specific types.

The radix is specified via parameters rather than string prefixes, with a valid range of 2-36. Values beyond decimal are represented using uppercase or lowercase English letters in alphabetical order (10 digits + 26 letters = base-36). For Int series strings, they may start with `+` or `-`; if neither is present, they are treated as `+`. UInt series strings may start with `+`, but will throw an exception if starting with `-`. Returns the string representation in specified radix, with values beyond decimal represented using lowercase English letters (10 digits + 26 lowercase letters = base-36).

This interface provides two sets of methods: parse and tryParse. The parse method throws exceptions on parsing failures, while tryParse wraps the return value in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont), returning None on failure.
The package has already implemented this interface for basic types like [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) and [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64), enabling string conversion to these types.

### static func parse(String, Int64)

```cangjie
static func parse(value: String, radix!: Int64): T
```

Function: Parses a specific type from a string of specified radix.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be parsed.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- T - The converted value.

### static func tryParse(String, Int64)

```cangjie
static func tryParse(value: String, radix!: Int64): Option<T>
```

Function: Parses a specific type from a string of specified radix.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be parsed.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The converted value, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>.None on failure.

### func toString(Int64)

```cangjie
func toString(radix!: Int64): String
```

Function: Returns the string representation in specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in specified radix.

### extend Int8 <: RadixConvertible\<Int8>

```cangjie
extend Int8 <: RadixConvertible<Int8>
```

Function: This extension primarily implements operations for converting [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) literal strings to [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) values.

Parent type:

- [RadixConvertible](#interface-radixconvertiblet)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): Int8
```

Function: Converts an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) literal string to an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - The converted [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the string is empty, radix is out of range, converted value exceeds [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) range, or string contains invalid UTF-8 characters.

Example:

<!-- verify -->
```cangjie
import std.convert.*

main() {
    var strInt8: String = "A"
    var res = Int8.parse(strInt8, radix: 16)
    
    println("After the conversion of parse, \"A\" became ${res}")
}
```

Execution result:

```text
After the conversion of parse, "A" became 10
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<Int8>
```

Function: Converts an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) literal string to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> - The converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)> value, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int8](../../core/core_package_api/core_package_intrinsics.md#int8)>.None on failure.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "7a"
    var res = Int8.tryParse(strInt, radix: 16)
    
    println("After the conversion of tryParse, \"7a\" in hexadecimal became ${res}")
    return 0
}
```

Execution result:

```text
After the conversion of tryParse, "7a" in hexadecimal became Some(122)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns the string representation in specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: Int8 = 122
    var res = value.toString(radix: 16)
    
    println("After the conversion of toString, 122 in hexadecimal became \"${res}\"")
    return 0
}
```

Execution result:

```text
After the conversion of toString, 122 in hexadecimal became "7a"
```

### extend Int16 <: RadixConvertible\<Int16>

```cangjie
extend Int16 <: RadixConvertible<Int16>
```

Function: This extension primarily implements operations for converting [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) literal strings to [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) values.

Parent type:

- [RadixConvertible](#interface-radixconvertiblet)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): Int16
```

Function: Converts an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) literal string to an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Int16](../../core/core极package_api/core_package_intrinsics.md#int16) - The converted [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the string is empty, radix is out of range, converted value exceeds [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) range, or string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "7fff"
    var res = Int16.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"7fff\" in hexadecimal became ${res}")
    return 0
}
```

Execution result:

```text
After the conversion of parse, "7fff" in hexadecimal became 32767
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<Int16>
```

Function: Converts an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) literal string to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> - The converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)> value, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int16](../../core/core_package_api/core_package_intrinsics.md#int16)>.None on failure.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "7B"
    var res = Int16.tryParse(strInt, radix: 16)
    
    println("After the conversion of tryParse, \"7B\" in hexadecimal became ${res}")
    return 0
}
```

Execution result:

```text
After the conversion of tryParse, "7B" in hexadecimal became Some(123)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns the string representation in specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: Int16 = 123
    var res = value.toString(radix: 16)
    
    println("After the conversion of toString, 123 in hexadecimal became \"${res}\"")
    return 0
}
```

Execution result:

```text
After the conversion of toString, 123 in hexadecimal became "7b"
```

### extend Int32 <: RadixConvertible\<Int32>

```cangjie
extend Int32 <: RadixConvertible<Int32>
```

Function: This extension primarily implements operations for converting [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) literal strings to [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) values.

Parent type:

- [RadixConvertible](#interface-radixconvertiblet)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): Int32
```

Function: Converts an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) literal string to an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#极64) - The specified radix.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The converted [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the string is empty, radix is out of range, converted value exceeds [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) range, or string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "7fffffff"
    var res = Int32.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"7fffffff\" in hexadecimal became ${res}")
    return 0
}
```

Execution result:

```text
After the conversion of parse, "7fffffff" in hexadecimal became 2147483647
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<Int32>
```

Function: Converts an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) literal string to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to convert.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> - The converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> value, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)>.None on failure.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "1z"
    var res = Int32.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"1z\" in base-36 became ${res}")
    return 0
}
```

Execution result:

```text
After the conversion of tryParse, "1z" in base-36 became Some(71)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns the string representation in specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: Int32 = 71
    var res = value.toString(radix: 36)
    
    println("After the conversion of toString, 71 in base-36 became \"${res}\"")
    return 0
}
```

Execution result:

```text
After the conversion of toString, 71 in base-36 became "1z"
```

### extend Int64 <: RadixConvertible\<Int64>

```cangjie
extend Int64 <: RadixConvertible<Int64>
```

Purpose: This extension primarily implements functions for converting string literals of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type to [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) values.

Parent Type:

- [RadixConvertible](#interface-radixconvertiblet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): Int64
```

Purpose: Converts a string literal of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type to an [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the converted [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, the radix is out of range, the converted value exceeds [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) range, the string contains invalid UTF-8 characters, or the conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "7fffffffffffffff"
    var res = Int64.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"7fffffffffffffff\" in hexadecimal became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of parse, "7fffffffffffffff" in hexadecimal became 9223372036854775807
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<Int64>
```

Purpose: Converts a string literal of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)>.None if conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "1y2p0ij32e8e7"
    var res = Int64.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"1y2p0ij32e8e7\" in base-36 became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of tryParse, "1y2p0ij32e8e7" in base-36 became Some(9223372036854775807)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Purpose: Returns a string representation in the specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in the specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: Int64 = 9223372036854775807
    var res = value.toString(radix: 16)
    
    println("After the conversion of toString, 9223372036854775807 in hexadecimal became \"${res}\"")
    return 0
}
```

Execution Result:

```text
After the conversion of toString, 9223372036854775807 in hexadecimal became "7fffffffffffffff"
```

### extend UInt8 <: RadixConvertible\<UInt8>

```cangjie
extend UInt8 <: RadixConvertible<UInt8>
```

Purpose: This extension primarily implements functions for converting string literals of [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type to [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) values.

Parent Type:

- [RadixConvertible](#interface-radixconvertiblet)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): UInt8
```

Purpose: Converts a string literal of [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type to a [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Returns the converted [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the string is empty, the radix is out of range, the first character is '-', the converted value exceeds [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) range, or the string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "ff"
    var res = UInt8.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"ff\" in hexadecimal became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of parse, "ff" in hexadecimal became 255
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<UInt8>
```

Function: Converts a string literal of type [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)>.None if conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "1z"
    var res = UInt8.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"1z\" in base-36 became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of tryParse, "1z" in base-36 became Some(71)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns a string representation in the specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in the specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: UInt8 = 71
    var res = value.toString(radix: 36)
    
    println("After the conversion of toString, 71 in base-36 became \"${res}\"")
    return 0
}
```

Execution Result:

```text
After the conversion of toString, 71 in base-36 became "1z"
```

### extend UInt16 <: RadixConvertible\<UInt16>

```cangjie
extend UInt16 <: RadixConvertible<UInt16>
```

Function: This extension primarily implements operations for converting string literals of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) values.

Parent Type:

- [RadixConvertible](#interface-radixconvertiblet)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): UInt16
```

Function: Converts a string literal of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to a [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Returns the converted [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the string is empty, the radix is out of range, the first character is `-`, the converted value exceeds [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) range, or the string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "ffff"
    var res = UInt16.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"ffff\" in hexadecimal became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of parse, "ffff" in hexadecimal became 65535
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<UInt16>
```

Function: Converts a string literal of type [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)>.None if conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "1yz"
    var res = UInt16.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"1yz\" in base-36 became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of tryParse, "1yz" in base-36 became Some(2555)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns a string representation in the specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in the specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: UInt16 = 2555
    var res = value.toString(radix: 36)
    
    println("After the conversion of toString, 2555 in base-36 became \"${res}\"")
    return 0
}
```

Execution Result:

```text
After the conversion of toString, 2555 in base-36 became "1yz"
```

### extend UInt32 <: RadixConvertible\<UInt32>

```cangjie
extend UInt32 <: RadixConvertible<UInt32>
```

Function: This extension primarily implements operations for converting string literals of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) values.

Parent Type:

- [RadixConvertible](#interface-radixconvertiblet)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): UInt32
```

Function: Converts a string literal of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to a [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Returns the converted [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the string is empty, the radix is out of range, the first character is `-`, the converted value exceeds [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) range, or the string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "ffffffff"
    var res = UInt32.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"ffffffff\" in hexadecimal became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of parse, "ffffffff" in hexadecimal became 4294967295
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<UInt32>
```

Function: Converts a string literal of type [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)>.None if conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "1z141z3"
    var res = UInt32.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"1z141z3\" in base-36 became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of tryParse, "1z141z3" in base-36 became Some(4294967295)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns a string representation in the specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in the specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: UInt32 = 4294967295
    var res = value.toString(radix: 16)
    
    println("After the conversion of toString, 4294967295 in hexadecimal became \"${res}\"")
    return 0
}
```

Execution Result:

```text
After the conversion of toString, 4294967295 in hexadecimal became "ffffffff"
```

### extend UInt64 <: RadixConvertible\<UInt64>

```cangjie
extend UInt64 <: RadixConvertible<UInt64>
```

Function: This extension primarily implements operations for converting string literals of [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type to [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) values.

Parent Type:

- [RadixConvertible](#interface-radixconvertiblet)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)>

#### static func parse(String, Int64)

```cangjie
public static func parse(value: String, radix!: Int64): UInt64
```

Function: Converts a string literal of [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type to a [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - Returns the converted [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) value.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the string is empty, the radix is out of range, the first character is `-`, the converted value exceeds the [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) range, or the string contains invalid UTF-8 characters.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "ffffffffffffffff"
    var res = UInt64.parse(strInt, radix: 16)
    
    println("After the conversion of parse, \"ffffffffffffffff\" in hexadecimal became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of parse, "ffffffffffffffff" in hexadecimal became 18446744073709551615
```

#### static func tryParse(String, Int64)

```cangjie
public static func tryParse(value: String, radix!: Int64): Option<UInt64>
```

Function: Converts a string literal of [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type to an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> value.

Parameters:

- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be converted.
- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> - Returns the converted [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)> value. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64)>.None if conversion fails.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var strInt: String = "3w5e11264sgsf"
    var res = UInt64.tryParse(strInt, radix: 36)
    
    println("After the conversion of tryParse, \"3w5e11264sgsf\" in base-36 became ${res}")
    return 0
}
```

Execution Result:

```text
After the conversion of tryParse, "3w5e11264sgsf" in base-36 became Some(18446744073709551615)
```

#### func toString(Int64)

```cangjie
public func toString(radix!: Int64): String
```

Function: Returns a string representation in the specified radix.

Parameters:

- radix!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified radix.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation in the specified radix.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the radix is invalid.

<!-- verify -->
```cangjie
import std.convert.*

main(): Int64 {
    var value: UInt64 = 18446744073709551615
    var res = value.toString(radix: 16)
    
    println("After the conversion of toString, 18446744073709551615 in hexadecimal became \"${res}\"")
    return 0
}
```

Execution Result:

```text
After the conversion of toString, 18446744073709551615 in hexadecimal became "ffffffffffffffff"
```