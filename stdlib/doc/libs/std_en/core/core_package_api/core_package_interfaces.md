# Interface

## interface Any

```cangjie
public interface Any
```

Function: [Any](core_package_interfaces.md#interface-any) is the parent type of all types. All `interface` types implicitly inherit from it, and all non-`interface` types implicitly implement it.

### extend Byte

```cangjie
extend Byte
```

Function: Implements a series of extension methods for the [Byte](core_package_types.md#type-byte) type, primarily providing character judgment and conversion operations within the ASCII character set range.

#### func isAscii()

```cangjie
public func isAscii(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAscii() method
    let byte1: Byte = 65  // ASCII value of 'A'
    let byte2: Byte = 200 // Value outside ASCII range
    
    println("Is byte1 (${byte1}) within ASCII range: ${byte1.isAscii()}")
    println("Is byte2 (${byte2}) within ASCII range: ${byte2.isAscii()}")
}
```

Output:

```text
Is byte1 (65) within ASCII range: true
Is byte2 (200) within ASCII range: false
```

#### func isAsciiControl()

```cangjie
public func isAsciiControl(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII control character range. The valid range is the union of [00, 1F] and {7F}.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII control character range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiControl() method
    let byte1: Byte = 0x09  // Tab '\t', an ASCII control character
    let byte2: Byte = 0x20  // Space ' ', not an ASCII control character
    let byte3: Byte = 0x7F  // DEL, an ASCII control character
    
    println("Is byte1 (0x${byte1}) an ASCII control character: ${byte1.isAsciiControl()}")
    println("Is byte2 (0x${byte2}) an ASCII control character: ${byte2.isAsciiControl()}")
    println("Is byte3 (0x${byte3}) an ASCII control character: ${byte3.isAsciiControl()}")
}
```

Output:

```text
Is byte1 (0x9) an ASCII control character: true
Is byte2 (0x32) an ASCII control character: false
Is byte3 (0x127) an ASCII control character: true
```

#### func isAsciiGraphic()

```cangjie
public func isAsciiGraphic(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII graphic character range. The valid range is [21, 7E].

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII graphic character range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiGraphic() method
    let byte1: Byte = 0x21  // '!', an ASCII graphic character
    let byte2: Byte = 0x7E  // '~', an ASCII graphic character
    let byte3: Byte = 0x20  // ' ', space, not an ASCII graphic character
    
    println("Is byte1 (0x${byte1}) an ASCII graphic character: ${byte1.isAsciiGraphic()}")
    println("Is byte2 (0x${byte2}) an ASCII graphic character: ${byte2.isAsciiGraphic()}")
    println("Is byte3 (0x${byte3}) an ASCII graphic character: ${byte3.isAsciiGraphic()}")
}
```

Output:

```text
Is byte1 (0x33) an ASCII graphic character: true
Is byte2 (0x126) an ASCII graphic character: true
Is byte3 (0x32) an ASCII graphic character: false
```

#### func isAsciiHex()

```cangjie
public func isAsciiHex(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII hexadecimal digit range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII hexadecimal digit range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiHex() method
    let byte1: Byte = 0x30  // '0', an ASCII hexadecimal digit
    let byte2: Byte = 0x46  // 'F', an ASCII hexadecimal digit
    let byte3: Byte = 0x67  // 'g', not an ASCII hexadecimal digit
    
    println("Is byte1 (0x${byte1}) an ASCII hexadecimal digit: ${byte1.isAsciiHex()}")
    println("Is byte2 (0x${byte2}) an ASCII hexadecimal digit: ${byte2.isAsciiHex()}")
    println("Is byte3 (0x${byte3}) an ASCII hexadecimal digit: ${byte3.isAsciiHex()}")
}
```

Output:

```text
Is byte1 (0x48) an ASCII hexadecimal digit: true
Is byte2 (0x70) an ASCII hexadecimal digit: true
Is byte3 (0x103) an ASCII hexadecimal digit: false
```

#### func isAsciiLetter()

```cangjie
public func isAsciiLetter(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII Latin letter range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII Latin letter range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiLetter() method
    let byte1: Byte = 0x41  // 'A', an ASCII Latin letter
    let byte2: Byte = 0x7A  // 'z', an ASCII Latin letter
    let byte3: Byte = 0x30  // '0', digit, not an ASCII Latin letter
    
    println("Is byte1 (0x${byte1}) an ASCII Latin letter: ${byte1.isAsciiLetter()}")
    println("Is byte2 (0x${byte2}) an ASCII Latin letter: ${byte2.isAsciiLetter()}")
    println("Is byte3 (0x${byte3}) an ASCII Latin letter: ${byte3.isAsciiLetter()}")
}
```

Output:

```text
Is byte1 (0x65) an ASCII Latin letter: true
Is byte2 (0x122) an ASCII Latin letter: true
Is byte3 (0x48) an ASCII Latin letter: false
```

#### func isAsciiLowerCase()

```cangjie
public func isAsciiLowerCase(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII lowercase Latin letter range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII lowercase Latin letter range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiLowerCase() method
    let byte1: Byte = 0x61  // 'a', an ASCII lowercase Latin letter
    let byte2: Byte = 0x7A  // 'z', an ASCII lowercase Latin letter
    let byte3: Byte = 0x41  // 'A', uppercase letter, not an ASCII lowercase Latin letter
    
    println("Is byte1 (0x${byte1}) an ASCII lowercase Latin letter: ${byte1.isAsciiLowerCase()}")
    println("Is byte2 (0x${byte2}) an ASCII lowercase Latin letter: ${byte2.isAsciiLowerCase()}")
    println("Is byte3 (0x${byte3}) an ASCII lowercase Latin letter: ${byte3.isAsciiLowerCase()}")
}
```

Output:

```text
Is byte1 (0x97) an ASCII lowercase Latin letter: true
Is byte2 (0x122) an ASCII lowercase Latin letter: true
Is byte3 (0x65) an ASCII lowercase Latin letter: false
```

#### func isAsciiNumber()

```cangjie
public func isAsciiNumber(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII decimal digit range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII decimal digit range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiNumber() method
    let byte1: Byte = 0x30  // '0', an ASCII decimal digit
    let byte2: Byte = 0x39  // '9', an ASCII decimal digit
    let byte3: Byte = 0x41  // 'A', letter, not an ASCII decimal digit
    
    println("Is byte1 (0x${byte1}) an ASCII decimal digit: ${byte1.isAsciiNumber()}")
    println("Is byte2 (0x${byte2}) an ASCII decimal digit: ${byte2.isAsciiNumber()}")
    println("Is byte3 (0x${byte3}) an ASCII decimal digit: ${byte3.isAsciiNumber()}")
}
```

Output:

```text
Is byte1 (0x48) an ASCII decimal digit: true
Is byte2 (0x57) an ASCII decimal digit: true
Is byte3 (0x65) an ASCII decimal digit: false
```

#### func isAsciiNumberOrLetter()

```cangjie
public func isAsciiNumberOrLetter(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII decimal digit or Latin letter range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII decimal digit or Latin letter range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiNumberOrLetter() method
    let byte1: Byte = 0x30  // '0', digit, within ASCII decimal digit and Latin letter range
    let byte2: Byte = 0x41  // 'A', letter, within ASCII decimal digit and Latin letter range
    let byte3: Byte = 0x20  // ' ', space, not within ASCII decimal digit and Latin letter range
    
    println("Is byte1 (0x${byte1}) an ASCII decimal digit or Latin letter: ${byte1.isAsciiNumberOrLetter()}")
    println("Is byte2 (0x${byte2}) an ASCII decimal digit or Latin letter: ${byte2.isAsciiNumberOrLetter()}")
    println("Is byte3 (0x${byte3}) an ASCII decimal digit or Latin letter: ${byte3.isAsciiNumberOrLetter()}")
}
```

Output:

```text
Is byte1 (0x48) an ASCII decimal digit or Latin letter: true
Is byte2 (0x65) an ASCII decimal digit or Latin letter: true
Is byte3 (0x32) an ASCII decimal digit or Latin letter: false
```

#### func isAsciiOct()

```cangjie
public func isAsciiOct(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII octal digit range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII octal digit range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiOct() method
    let byte1: Byte = 0x30  // '0', an ASCII octal digit
    let byte2: Byte = 0x37  // '7', an ASCII octal digit
    let byte3: Byte = 0x38  // '8', not an ASCII octal digit
    
    println("Is byte1 (0x${byte1}) an ASCII octal digit: ${byte1.isAsciiOct()}")
    println("Is byte2 (0x${byte2}) an ASCII octal digit: ${byte2.isAsciiOct()}")
    println("Is byte3 (0x${byte3}) an ASCII octal digit: ${byte3.isAsciiOct()}")
}
```

Output:

```text
Is byte1 (0x48) an ASCII octal digit: true
Is byte2 (0x55) an ASCII octal digit: true
Is byte3 (0x56) an ASCII octal digit: false
```

#### func isAsciiPunctuation()

```cangjie
public func isAsciiPunctuation(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII punctuation range. The valid range is the union of [21, 2F], [3A, 40], [5B, 60], and [7B, 7E].

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII punctuation range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiPunctuation() method
    let byte1: Byte = 0x21  // '!', an ASCII punctuation
    let byte2: Byte = 0x2C  // ',', an ASCII punctuation
    let byte3: Byte = 0x30  // '0', digit, not an ASCII punctuation
    
    println("Is byte1 (0x${byte1}) an ASCII punctuation: ${byte1.isAsciiPunctuation()}")
    println("Is byte2 (0x${byte2}) an ASCII punctuation: ${byte2.isAsciiPunctuation()}")
    println("Is byte3 (0x${byte3}) an ASCII punctuation: ${byte3.isAsciiPunctuation()}")
}
```

Output:

```text
Is byte1 (0x33) an ASCII punctuation: true
Is byte2 (0x44) an ASCII punctuation: true
Is byte3 (0x48) an ASCII punctuation: false
```

#### func isAsciiUpperCase()

```cangjie
public func isAsciiUpperCase(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII uppercase Latin letter range.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII uppercase Latin letter range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiUpperCase() method
    let byte1: Byte = 0x41  // 'A', an ASCII uppercase Latin letter
    let byte2: Byte = 0x5A  // 'Z', an ASCII uppercase Latin letter
    let byte3: Byte = 0x61  // 'a', lowercase letter, not an ASCII uppercase Latin letter
    
    println("Is byte1 (0x${byte1}) an ASCII uppercase Latin letter: ${byte1.isAsciiUpperCase()}")
    println("Is byte2 (0x${byte2}) an ASCII uppercase Latin letter: ${byte2.isAsciiUpperCase()}")
    println("Is byte3 (0x${byte3}) an ASCII uppercase Latin letter: ${byte3.isAsciiUpperCase()}")
}
```

Output:

```text
Is byte1 (0x65) an ASCII uppercase Latin letter: true
Is byte2 (0x90) an ASCII uppercase Latin letter: true
Is byte3 (0x97) an ASCII uppercase Latin letter: false
```

#### func isAsciiWhiteSpace()

```cangjie
public func isAsciiWhiteSpace(): Bool
```

Function: Determines whether the [Byte](core_package_types.md#type-byte) is within the ASCII whitespace character range. The valid range is the union of [09, 0D] and {20}.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the [Byte](core_package_types.md#type-byte) is within the ASCII whitespace character range, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Test isAsciiWhiteSpace() method
    let byte1: Byte = 0x09  // '\t', tab, an ASCII whitespace character
    let byte2: Byte = 0x20  // ' ', space, an ASCII whitespace character
    let byte3: Byte = 0x41  // 'A', letter, not an ASCII whitespace character
    
    println("Is byte1 (0x${byte1}) an ASCII whitespace character: ${byte1.isAsciiWhiteSpace()}")
    println("Is byte2 (0x${byte2}) an ASCII whitespace character: ${byte2.isAsciiWhiteSpace()}")
    println("Is byte3 (0x${byte3}) an ASCII whitespace character: ${byte3.isAsciiWhiteSpace()}")
}
```

Output:

```text
Is byte1 (0x9) an ASCII whitespace character: true
Is byte2 (0x32) an ASCII whitespace character: true
Is byte3 (0x65) an ASCII whitespace character: false
```

#### func toAsciiLowerCase()

```cangjie
public func toAsciiLowerCase(): Byte
```

Function: Converts the [Byte](core_package_types.md#type-byte) to its corresponding ASCII lowercase character [Byte](core_package_types.md#type-byte). If conversion is not## interface CType

Returns:

- [Byte](core_package_types.md#type-byte) - The converted [Byte](core_package_types.md#type-byte), or the original [Byte](core_package_types.md#type-byte) if conversion is not possible.

Example:

<!-- verify -->
```cangjie
main() {
    // Test the toAsciiLowerCase() method
    let byte1: Byte = 0x41  // 'A', uppercase letter
    let byte2: Byte = 0x5A  // 'Z', uppercase letter
    let byte3: Byte = 0x30  // '0', digit, cannot be converted
    
    let lower1 = byte1.toAsciiLowerCase()
    let lower2 = byte2.toAsciiLowerCase()
    let lower3 = byte3.toAsciiLowerCase()
    
    println("byte1 (0x${byte1}) converted to lowercase: 0x${lower1}")
    println("byte2 (0x${byte2}) converted to lowercase: 0x${lower2}")
    println("byte3 (0x${byte3}) converted to lowercase: 0x${lower3} (unchanged)")
}
```

Execution Result:

```text
byte1 (0x65) converted to lowercase: 0x97
byte2 (0x90) converted to lowercase: 0x122
byte3 (0x48) converted to lowercase: 0x48 (unchanged)
```

#### func toAsciiUpperCase()

```cangjie
public func toAsciiUpperCase(): Byte
```

Function: Converts the [Byte](core_package_types.md#type-byte) to its corresponding ASCII uppercase character [Byte](core_package_types.md#type-byte), or leaves it unchanged if conversion is not possible.

Returns:

- [Byte](core_package_types.md#type-byte) - The converted [Byte](core_package_types.md#type-byte), or the original [Byte](core_package_types.md#type-byte) if conversion is not possible.

Example:

<!-- verify -->
```cangjie
main() {
    // Test the toAsciiUpperCase() method
    let byte1: Byte = 0x61  // 'a', lowercase letter
    let byte2: Byte = 0x7A  // 'z', lowercase letter
    let byte3: Byte = 0x30  // '0', digit, cannot be converted
    
    let upper1 = byte1.toAsciiUpperCase()
    let upper2 = byte2.toAsciiUpperCase()
    let upper3 = byte3.toAsciiUpperCase()
    
    println("byte1 (0x${byte1}) converted to uppercase: 0x${upper1}")
    println("byte2 (0x${byte2}) converted to uppercase: 0x${upper2}")
    println("byte3 (0x${byte3}) converted to uppercase: 0x${upper3} (unchanged)")
}
```

Execution Result:

```text
byte1 (0x97) converted to uppercase: 0x65
byte2 (0x122) converted to uppercase: 0x90
byte3 (0x48) converted to uppercase: 0x48 (unchanged)
```

## interface CType

```cangjie
sealed interface CType
```

Function: Represents an interface that supports interoperability with the C language.

The [CType](core_package_interfaces.md#interface-ctype) interface is a built-in empty interface in the language. It is a concrete implementation of the [CType](core_package_interfaces.md#interface-ctype) constraint. All C-interoperable types implicitly implement this interface, thus all C-interoperable types can be used as subtypes of the [CType](core_package_interfaces.md#interface-ctype) type.

> **Note:**
>
> - The [CType](core_package_interfaces.md#interface-ctype) interface is an interface type in Cangjie and does not itself satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint.
> - The [CType](core_package_interfaces.md#interface-ctype) interface cannot be inherited or extended by users.
> - The [CType](core_package_interfaces.md#interface-ctype) interface does not bypass subtype usage restrictions.

Example:

<!-- run -->
```cangjie
@C
struct Data {}

@C
func foo() {}

main() {
    var c: CType = Data() // ok
    c = 0 // ok
    c = true // ok
    c = CString(CPointer<UInt8>()) // ok
    c = CPointer<Int8>() // ok
    c = foo // ok
}
```

## interface Collection\<T>

```cangjie
public interface Collection<T> <: Iterable<T> {
    prop size: Int64
    func isEmpty(): Bool
    func toArray(): Array<T>
}
```

Function: This interface represents a collection. Container types should generally implement this interface.

Parent Types:

- [Iterable](#interface-iterablee)\<T>

### prop size

```cangjie
prop size: Int64
```

Function: Gets the size of the current collection, i.e., the number of elements in the collection.

Type: [Int64](core_package_intrinsics.md#int64)

### func isEmpty()

```cangjie
func isEmpty(): Bool
```

Function: Determines whether the current collection is empty.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if empty, otherwise `false`.

<!--Del_sink-->
### func isEmpty()

```cangjie
func isEmpty(this @local?): Bool
```

Function: Determines whether the current collection is empty.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if empty, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    println("arr isEmpty: ${arr.isEmpty()}")
    let empty: Array<Int64> @local? = []
    println("empty isEmpty: ${empty.isEmpty()}")
}
```

Output:

```text
arr isEmpty: false
empty isEmpty: true
```

<!--DelEnd_sink-->

### func toArray()

```cangjie
func toArray(): Array<T>
```

Function: Converts the current collection to an array type.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The resulting array after conversion.

<!--Del_sink-->
### func toArray()

```cangjie
func toArray(this @local?): Array<T> @local?
```

Function: Converts the current collection to an array.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> @local? - The resulting `@local?` array.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    let collection: Collection<Int64> @local? = arr
    let copied: Array<Int64> @local? = collection.toArray()
    println("size=${copied.size}")
}
```

Output:

```text
size=3
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func toArray()

```cangjie
func toArray(this @local!): Array<T> @local!
```

Function: Converts the current collection to an array.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> @local! - The resulting `@local!` array.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3]
    let copied: Array<Int64> @local! = arr.toArray()
    match (copied.first) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

Output:

```text
first=1
```

<!--DelEnd_sink-->
## interface Comparable\<T>

```cangjie
public interface Comparable<T> <: Equatable<T> & Less<T> & Greater<T> & LessOrEqual<T> & GreaterOrEqual<T> {
    func compare(that: T): Ordering
    operator func <(rhs: T): Bool
    operator func <=(rhs: T): Bool
    operator func ==(rhs: T): Bool
    operator func >(rhs: T): Bool
    operator func >=(rhs: T): Bool
}
```

Function: This interface represents comparison operations and is a composite of equality, inequality, less-than, greater-than, less-than-or-equal, and greater-than-or-equal interfaces.

This interface provides default implementations for the operator overloads `==`, `!=`, `<`, `<=`, `>`, and `>=`. The default implementations determine their return values based on the return value of the `compare` function. For example: if `a.compare(b)` returns `EQ`, then `a == b` returns `true`; otherwise, it returns `false`.

Parent Types:

- [Equatable](#interface-equatablet)\<T>
- [Less](#interface-lesst)\<T>
- [Greater](#interface-greatert)\<T>
- [LessOrEqual](#interface-lessorequalt)\<T>
- [GreaterOrEqual](#interface-greaterorequalt)\<T>

### func compare(T)

```cangjie
func compare(that: T): Ordering
```

Function: Determines the size relationship between the current instance of type `T` and another instance of type `T` pointed to by the parameter.

Parameters:

- that: T - Another instance to compare with the current instance.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

### operator func <(T)

```cangjie
operator func <(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is less than another instance of type `T` pointed to by the parameter. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if less, otherwise `false`.

### operator func <=(T)

```cangjie
operator func <=(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is less than or equal to another instance of type `T` pointed to by the parameter. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if less than or equal, otherwise `false`.

### operator func ==(T)

```cangjie
operator func ==(rhs: T): Bool
```

Function: Determines whether two instances are equal. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if equal, otherwise `false`.

### operator func >(T)

```cangjie
operator func >(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is greater than another instance of type `T` pointed to by the parameter. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if greater, otherwise `false`.

### operator func >=(T)

```cangjie
operator func >=(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is greater than or equal to another instance of type `T` pointed to by the parameter. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if greater than or equal, otherwise `false`.

<!--Del_sink-->
### func compare(T)

```cangjie
func compare(this @local?, other: T @local?): Ordering
```

Function: Determines the size relationship between the current instance and the instance specified by the parameter.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - The comparison result.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    let r: Ordering = a.compare(c)
    println("compare: ${r}")
}
```

Output:

```text
compare: Ordering.LT
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func ==(T)

```cangjie
operator func ==(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is equal to the instance specified by the parameter. This function is the default implementation of this interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if equal to, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let b: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("a == b: ${a == b}")
    println("a == c: ${a == c}")
}
```

Output:

```text
a == b: true
a == c: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func <(T)

```cangjie
operator func <(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is less than the instance specified by the parameter. This function is the default implementation of this interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if less than, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("a < c: ${a < c}")
    println("c < a: ${c < a}")
}
```

Output:

```text
a < c: true
c < a: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func >(T)

```cangjie
operator func >(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is greater than the instance specified by the parameter. This function is the default implementation of this interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if greater than, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("c > a: ${c > a}")
    println("a > c: ${a > c}")
}
```

Output:

```text
c > a: true
a > c: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func <=(T)

```cangjie
operator func <=(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is less than or equal to the instance specified by the parameter. This function is the default implementation of this interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if less than or equal to, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("a <= c: ${a <= c}")
    println("c <= a: ${c <= a}")
}
```

Output:

```text
a <= c: true
c <= a: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func >=(T)

```cangjie
operator func >=(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is greater than or equal to the instance specified by the parameter. This function is the default implementation of this interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if greater than or equal to, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("c >= a: ${c >= a}")
    println("a >= c: ${a >= c}")
}
```

Output:

```text
c >= a: true
a >= c: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
## interface Copyable

```cangjie
public interface Copyable {}
```

Function: An empty interface that marks copyable types.

Part of the local-mode extension families are constrained by `T <: Copyable` (for example, the `@local` member extensions of [Array](core_package_structs.md#struct-arrayt)); only types implementing this interface can use those local extension members.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Example:

<!-- verify -->
```cangjie
main() {
    // Int64 implements Copyable, enabling the constrained fill extension on a @local? array.
    let arr: Array<Int64> @local? = [1, 2, 3]
    arr.fill(0)
    let f: Option<Int64> @local? = arr.first
    match (f) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

Output:

```text
first=0
```

<!--DelEnd_sink-->

## interface Countable\<T>

```cangjie
public interface Countable<T> {
    func next(right: Int64): T
    func position(): Int64
}
```

Function: This interface indicates that a type is countable.

Each instance of a countable type corresponds to a position value (an [Int64](core_package_intrinsics.md#int64) value). Other instances of the type can be obtained by counting forward.

### func next(Int64)

```cangjie
func next(right: Int64): T
```

Function: Gets the instance of type `T` at the position obtained by moving `right` positions to the right from the current instance.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of positions to count to the right.

Returns:

- T - The instance of type `T` at the position obtained by moving `right` positions to the right.

### func position()

```cangjie
func position(): Int64
```

Function: Gets the position information of the current countable instance, i.e., converts the current instance to an [Int64](core_package_intrinsics.md#int64) type.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The converted [Int64](core_package_intrinsics.md#int64) value.

### extend Float64

```cangjie
extend Float64
```

Function: Extends the [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type as the left operand and the [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) type as the right operand for multiplication.

#### operator func *(Duration)

```cangjie
public operator func *(r: Duration): Duration
```

Function: Implements multiplication between [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) and [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) types, i.e., the [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) operation.

Parameters:

- r: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - A [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) instance.

Returns:

- [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The product of the [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the multiplication result exceeds the representable range of [Duration](../../core/core_package_api/core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64 * Duration operation
    let floatVal: Float64 = 2.5
    let duration: Duration = Duration.second
    
    let result = floatVal * duration
    
    println("Float64 value: ${floatVal}")
    println("Duration value: ${duration}")
    println("Operation result: ${result}")
}
```

Output:

```text
Float64 value: 2.500000
Duration value: 1s
Operation result: 2s500ms
```

### extend Int64

```cangjie
extend Int64
```

Function: Extends the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type as the left operand and the [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) type as the right operand for multiplication.

#### operator func *(Duration)

```cangjie
public operator func *(r: Duration): Duration
```

Function: Implements multiplication between [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) and [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) types, i.e., the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) operation.

For example, `2 * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration).second` returns a [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) instance representing a time interval of 2 seconds.

Parameters:

- r: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The right operand of the multiplication.

Returns:

- [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The product of the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the multiplication result exceeds the representable range of [Duration](../../core/core_package_api/core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int64 * Duration operation
    let intVal: Int64 = 3
    let duration: Duration = Duration.second
    
    let result = intVal * duration
    
    println("Int64 value: ${intVal}")
    println("Duration value: ${duration}")
    println("Operation result: ${result}")
    
    // Test example of 2 * Duration.second
    let result2 = 2 * Duration.second
    println("2 * Duration.second = ${result2}")
}
```

Output:

```text
Int64 value: 3
Duration value: 1s
Operation result: 3s
2 * Duration.second = 2s
```

## interface Equal\<T>

```cangjie
public interface Equal<T> {
    operator func ==(rhs: T): Bool
}
```

Function: This interface supports equality comparison operations.

### operator func ==(T)

```cangjie
operator func ==(rhs: T): Bool
```

Function: Determines whether two instances are equal.

Parameters:

- rhs: T - Another instance to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if equal, otherwise `false`.

<!--Del_sink-->
### operator func ==(T)

```cangjie
operator func ==(this @local!, other: T @local!): Bool
```

Function: Determines whether the current instance is equal to the specified instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- other: T @local! - The other `@local!` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    // Array does not provide the @local! implementation of ==; the call hits the default implementation of the Equal interface
    try {
        println("eq=${a == b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '==' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func ==(T)

```cangjie
operator func ==(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is equal to the specified instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let x: Array<Int64> @local? = a
    let y: Array<Int64> @local? = b
    // Array does not provide the @local? implementation of ==; the call hits the default implementation of the Equal interface
    try {
        println("eq=${x == y}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '==' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Equatable\<T>

```cangjie
public interface Equatable<T> <: Equal<T> & NotEqual<T> {
    operator func !=(rhs: T): Bool
}
```

Function: This interface is a composite of equality and inequality comparison interfaces.

This interface provides a default implementation for the `!=` operator overload. The default implementation determines its return value based on the return value of the `==` operation. For example: if `a == b` returns `true`, then `a != b` returns `false`; otherwise, it returns `true`.

This interface has been implemented for some Cangjie types, including: [Unit](core_package_intrinsics.md#unit), [Bool](core_package_intrinsics.md#bool), [Rune](core_package_intrinsics.md#rune), [Int64](core_package_intrinsics.md#int64), [Int32](core_package_intrinsics.md#int32), [Int16](core_package_intrinsics.md#int16), [Int8](core_package_intrinsics.md#int8), [UIntNative](core_package_intrinsics.md#uintnative), [UInt64](core_package_intrinsics.md#uint64), [UInt32](core_package_intrinsics.md#uint32), [UInt16](core_package_intrinsics.md#uint16), [UInt8](core_package_intrinsics.md#uint8), [Float64](core_package_intrinsics.md#float64), [Float32](core_package_intrinsics.md#float32), [Float16](core_package_intrinsics.md#float16), [String](core_package_structs.md#struct-string), [Array](core_package_structs.md#struct-arrayt), [Box](core_package_classes.md#class-boxt), [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt), [HashSet](../../collection/collection_package_api/collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Parent Types:

- [Equal](#interface-equalt)\<T>
- [NotEqual](#interface-notequalt)\<T>

### operator func !=(T)

```cangjie
operator func !=(rhs: T): Bool
```

Function: Determines whether two instances are not equal. This function is a default implementation of this interface.

Parameters:

- rhs: T - Another instance to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if not equal, otherwise `false`.

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local!, other: T @local!): Bool
```

Function: Determines whether the current instance is not equal to the specified instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- other: T @local! - The other `@local!` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    // Array does not provide the @local! implementation of !=; the call hits the default implementation of the Equatable interface
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '!=' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is not equal to the specified instance. This function is a default implementation of this interface; the default implementation delegates the result to the `==` operation (i.e., `!(this == other)`).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - The default implementation itself does not throw directly; the exception propagates when the delegated `==` implementation throws it, for example when the type does not provide the `@local?` implementation of `==` and the default implementation of the [Equal](#interface-equalt) interface is hit.

Example:

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let x: Array<Int64> @local? = a
    let y: Array<Int64> @local? = b
    // The default implementation delegates to ==; Array does not provide the @local? implementation of ==, so the call finally hits the default implementation of the Equal interface
    try {
        println("ne=${x != y}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '==' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Greater\<T>

```cangjie
public interface Greater<T> {
    operator func >(rhs: T): Bool
}
```

Function: This interface represents the greater-than operation.

### operator func >(T)

```cangjie
operator func >(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is greater than the instance of type `T` pointed to by the parameter.

Parameters:

- rhs: T - Another instance to be compared with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if greater, otherwise returns false.

## interface GreaterOrEqual\<T>

```cangjie
public interface GreaterOrEqual<T> {
    operator func >=(rhs: T): Bool
}
```

Function: This interface represents the greater-than-or-equal-to operation.

### operator func >=(T)

```cangjie
operator func >=(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is greater than or equal to the instance of type `T` pointed to by the parameter.

Parameters:

- rhs: T - Another instance to be compared with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if greater than or equal, otherwise returns false.

## interface Hashable

```cangjie
public interface Hashable {
    func hashCode(): Int64
}
```

Function: This interface is used for computing hash values.

It has been implemented for some Cangjie types, including: [Bool](core_package_intrinsics.md#bool), [Rune](core_package_intrinsics.md#rune), [IntNative](core_package_intrinsics.md#intnative), [Int64](core_package_intrinsics.md#int64), [Int32](core_package_intrinsics.md#int32), [Int16](core_package_intrinsics.md#int16), [Int8](core_package_intrinsics.md#int8), [UIntNative](core_package_intrinsics.md#uintnative), [UInt64](core_package_intrinsics.md#uint64), [UInt32](core_package_intrinsics.md#uint32), [UInt16](core_package_intrinsics.md#uint16), [UInt8](core_package_intrinsics.md#uint8), [Float64](core_package_intrinsics.md#float64), [Float32](core_package_intrinsics.md#float32), [Float16](core_package_intrinsics.md#float16), [String](core_package_structs.md#struct-string), [Box](core_package_classes.md#class-boxt).

### func hashCode()

```cangjie
func hashCode(): Int64
```

Function: Obtains the hash value of the instance type.

Returns:

- [Int64](core_package_intrinsics.md#int64) - Returns the hash value of the instance type.

<!--Del_sink-->
### func hashCode()

```cangjie
func hashCode(this @local?): Int64
```

Function: Computes the hash value of the current instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Int64](core_package_intrinsics.md#int64) - Returns the hash value of the instance type.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local? = Ordering.LT
    // Ordering provides the @local? implementation of hashCode
    println("h=${ord.hashCode()}")
}
```

Output:

```text
h=1
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func hashCode()

```cangjie
func hashCode(this @local!): Int64
```

Function: Computes the hash value of the current instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Returns:

- [Int64](core_package_intrinsics.md#int64) - Returns the hash value of the instance type.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local! = Ordering.GT
    // Ordering provides the @local! implementation of hashCode
    println("h=${ord.hashCode()}")
}
```

Output:

```text
h=3
```

<!--DelEnd_sink-->
## interface Hasher

```cangjie
public interface Hasher {
    func finish(): Int64
    mut func reset(): Unit
    mut func write(value: Bool): Unit
    mut func write(value: Rune): Unit
    mut func write(value: Int8): Unit
    mut func write(value: Int16): Unit
    mut func write(value: Int32): Unit
    mut func write(value: Int64): Unit
    mut func write(value: UInt8): Unit
    mut func write(value: UInt16): Unit
    mut func write(value: UInt32): Unit
    mut func write(value: UInt64): Unit
    mut func write(value: Float16): Unit
    mut func write(value: Float32): Unit
    mut func write(value: Float64): Unit
    mut func write(value: String): Unit
}
```

Function: This interface is used for handling combined hash operations.

A series of write functions can be used to pass instances of different data types and compute their combined hash values.

### func finish()

```cangjie
func finish(): Int64
```

Function: Obtains the result of the hash operation.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The computed hash value.

### func reset()

```cangjie
mut func reset(): Unit
```

Function: Resets the hash value to 0.

### func write(Bool)

```cangjie
mut func write(value: Bool): Unit
```

Function: Passes the [Bool](core_package_intrinsics.md#bool) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Bool](core_package_intrinsics.md#bool) - The value to be hashed.

### func write(Float16)

```cangjie
mut func write(value: Float16): Unit
```

Function: Passes the [Float16](core_package_intrinsics.md#float16) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Float16](core_package_intrinsics.md#float16) - The value to be hashed.

### func write(Float32)

```cangjie
mut func write(value: Float32): Unit
```

Function: Passes the [Float32](core_package_intrinsics.md#float32) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Float32](core_package_intrinsics.md#float32) - The value to be hashed.

### func write(Float64)

```cangjie
mut func write(value: Float64): Unit
```

Function: Passes the [Float64](core_package_intrinsics.md#float64) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Float64](core_package_intrinsics.md#float64) - The value to be hashed.

### func write(Int16)

```cangjie
mut func write(value: Int16): Unit
```

Function: Passes the [Int16](core_package_intrinsics.md#int16) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Int16](core_package_intrinsics.md#int16) - The value to be hashed.

### func write(Int32)

```cangjie
mut func write(value: Int32): Unit
```

Function: Passes the [Int32](core_package_intrinsics.md#int32) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Int32](core_package_intrinsics.md#int32) - The value to be hashed.

### func write(Int64)

```cangjie
mut func write(value: Int64): Unit
```

Function: Passes the [Int64](core_package_intrinsics.md#int64) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Int64](core_package_intrinsics.md#int64) - The value to be hashed.

### func write(Int8)

```cangjie
mut func write(value: Int8): Unit
```

Function: Passes the [Int8](core_package_intrinsics.md#int8) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Int8](core_package_intrinsics.md#int8) - The value to be hashed.

### func write(Rune)

```cangjie
mut func write(value: Rune): Unit
```

Function: Passes the [Rune](core_package_intrinsics.md#rune) value to be hashed and performs the combined hash operation.

Parameters:

- value: [Rune](core_package_intrinsics.md#rune) - The value to be hashed.

### func write(String)

```cangjie
mut func write(value: String): Unit
```

Function: Passes the [String](core_package_structs.md#struct-string) value to be hashed and performs the combined hash operation.

Parameters:

- value: [String](core_package_structs.md#struct-string) - The value to be hashed.

### func write(UInt16)

```cangjie
mut func write(value: UInt16): Unit
```

Function: Passes the [UInt16](core_package_intrinsics.md#uint16) value to be hashed and performs the combined hash operation.

Parameters:

- value: [UInt16](core_package_intrinsics.md#uint16) - The value to be hashed.

### func write(UInt32)

```cangjie
mut func write(value: UInt32): Unit
```

Function: Passes the [UInt32](core_package_intrinsics.md#uint32) value to be hashed and performs the combined hash operation.

Parameters:

- value: [UInt32](core_package_intrinsics.md#uint32) - The value to be hashed.

### func write(UInt64)

```cangjie
mut func write(value: UInt64): Unit
```

Function: Passes the [UInt64](core_package_intrinsics.md#uint64) value to be hashed and performs the combined hash operation.

Parameters:

- value: [UInt64](core_package_intrinsics.md#uint64) - The value to be hashed.

### func write(UInt8)

```cangjie
mut func write(value: UInt8): Unit
```

Function: Passes the [UInt8](core_package_intrinsics.md#uint8) value to be hashed and performs the combined hash operation.

Parameters:

- value: [UInt8](core_package_intrinsics.md#uint8) - The value to be hashed.

## interface Iterable\<E>

```cangjie
public interface Iterable<E> {
    func iterator(): Iterator<E>
}
```

Function: This interface represents iterability. Types implementing this interface (typically container types) can be iterated over in `for-in` statements or obtain corresponding iterator instances to implement iteration by calling the `next` function.

This package has already implemented this interface for basic container types such as [Array](core_package_structs.md#struct-arrayt), [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt), [HashMap](../../collection/collection_package_api/collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek). Users can implement this interface for other types to support iteration functionality.

### func iterator()

```cangjie
func iterator(): Iterator<E>
```

Function: Obtains the iterator.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<E> - The iterator.

<!--Del_sink-->
### func iterator()

```cangjie
func iterator(this @local!): Iterator<E> @local!
```

Function: Obtains the iterator of the current instance; the returned iterator is bound to the same local region as the current instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<E> @local! - The iterator.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3]
    // Array provides the @local! implementation of iterator
    let it: Iterator<Int64> @local! = arr.iterator()
    match (it.next()) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

Output:

```text
first=1
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func iterator()

```cangjie
func iterator(this @local?): Iterator<E> @local?
```

Function: Obtains the iterator of the current instance; the returned iterator is bound to the same local region as the current instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<E> @local? - The iterator.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    // Array provides the @local? implementation of iterator
    let it: Iterator<Int64> @local? = arr.iterator()
    match (it.next()) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

Output:

```text
first=1
```

<!--DelEnd_sink-->
## interface Less\<T>

```cangjie
public interface Less<T> {
    operator func <(rhs: T): Bool
}
```

Function: This interface represents the less-than operation.

### operator func <(T)

```cangjie
operator func <(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is less than the instance of type `T` pointed to by the parameter.

Parameters:

- rhs: T - Another instance to be compared with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if less, otherwise returns false.

## interface LessOrEqual\<T>

```cangjie
public interface LessOrEqual<T> {
    operator func <=(rhs: T): Bool
}
```

Function: This interface represents the less-than-or-equal-to operation.

### operator func <=(T)

```cangjie
operator func <=(rhs: T): Bool
```

Function: Determines whether the current instance of type `T` is less than or equal to the instance of type `T` pointed to by the parameter.

Parameters:

- rhs: T - Another instance to be compared with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if less than or equal, otherwise returns false.

## interface NotEqual\<T>

```cangjie
public interface NotEqual<T> {
    operator func !=(rhs: T): Bool
}
```

Function: This interface is used to support inequality operations.

### operator func !=(T)

```cangjie
operator func !=(rhs: T): Bool
```

Function: Determines whether two instances are not equal.

Parameters:

- rhs: T - Another instance to be compared.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, otherwise returns false.

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local!, other: T @local!): Bool
```

Function: Determines whether the current instance is not equal to the specified instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- other: T @local! - The other `@local!` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
class MyType <: NotEqual<MyType> {
    public operator func !=(other: MyType): Bool {
        true
    }
    public exclave init(this @local!) {}
}

main() {
    let a: MyType @local! = MyType() @local!
    let b: MyType @local! = MyType() @local!
    // MyType does not provide the @local! implementation of !=; the call hits the default implementation of the NotEqual interface
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '!=' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local?, other: T @local?): Bool
```

Function: Determines whether the current instance is not equal to the specified instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- other: T @local? - The other `@local?` instance to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
class MyType <: NotEqual<MyType> {
    public operator func !=(other: MyType): Bool {
        true
    }
    public exclave init(this @local!) {}
    public exclave init(this @local?) {}
}

main() {
    let a: MyType @local? = MyType() @local?
    let b: MyType @local? = MyType() @local?
    // MyType does not provide the @local? implementation of !=; the call hits the default implementation of the NotEqual interface
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Output:

```text
caught: Current Type does not implement '!=' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Resource

```cangjie
public interface Resource {
    func close(): Unit
    func isClosed(): Bool
}
```

Function: This interface is used for resource management, typically for closing and releasing resources such as memory and handles.

Types implementing this interface can achieve automatic resource release in `try-with-resource` syntax contexts.

### func close()

```cangjie
func close(): Unit
```

Function: Closes the resource.

### func isClosed()

```cangjie
func isClosed(): Bool
```

Function: Determines whether the resource has been closed.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if already closed, otherwise returns false.

## interface ThreadContext

```cangjie
public interface ThreadContext {
    func end(): Unit
    func hasEnded(): Bool
}
```

Function: Cangjie thread context interface.

When users create a `thread`, in addition to the default `spawn` expression parameters, they can also pass instances of different [ThreadContext](core_package_interfaces.md#interface-threadcontext) types to select different thread contexts, thereby controlling concurrent behavior to some extent.

Currently, users are not allowed to implement the [ThreadContext](core_package_interfaces.md#interface-threadcontext) interface themselves. The Cangjie language provides `MainThreadContext` based on usage scenarios. For specific definitions, please refer to the terminal framework library.

### func end()

```cangjie
func end(): Unit
```

Function: Termination method, used to send a termination request to the current context.

### func hasEnded()

```cangjie
func hasEnded(): Bool
```

Function: Check method, used to verify whether the current context has terminated.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if terminated, otherwise returns false.

## interface ToString

```cangjie
public interface ToString {
    func toString(): String
}
```

Function: This interface provides string representation for concrete types.

### func toString()

```cangjie
func toString(): String
```

Function: Obtains the string representation of an instance type.

Returns:

- [String](core_package_structs.md#struct-string) - Returns the string representation of the instance type.
<!--Del_sink-->
### func toString()

```cangjie
func toString(this @local?): String @local!
```

Function: Converts the current instance to an outputtable string; the returned string is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [String](core_package_structs.md#struct-string) @local! - Returns the string representation of the instance type.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
main() {
    let n: Int64 @local? = 42
    // Int64 provides the @local? implementation of toString
    let s: String @local! = n.toString()
    println(s)
}
```

Output:

```text
42
```

<!--DelEnd_sink-->