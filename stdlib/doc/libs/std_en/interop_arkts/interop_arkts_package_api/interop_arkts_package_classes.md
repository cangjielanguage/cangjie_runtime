# Classes

## class ArkTSArray\<T\>

```cangjie
@ArkTS[foreignName: "Array"]
public foreign class ArkTSArray<T> {
    public init(arrayLength: Float64)
    public init(@RestParam items: Array<T>)
    public static func isArray(arg: ArkTSType): Bool
    public static prop prototype: ArkTSType
    public prop length: Float64
    public func pop(): Option<T>
    public func push(@RestParam items: Array<T>): Float64
    public func join(separator!: Option<String> = None): String
    public func reverse(): ArkTSArray<T>
    public func shift(): Option<T>
    public func unshift(@RestParam items: Array<T>): Float64
    public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSArray<T>
    public func indexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
    public func lastIndexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
}
```

Description: the Cangjie-side type of an ArkTS `Array<T>`/`T[]` object. By design it references the same instance as the ArkTS array object, so a modification on either side is visible on the other.

The reference semantics and member-level conversion arrive with AR-05/06; they are not implemented in this version. Within AR-03, when an `ArkTSArray<T>` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version.

This version declares 14 body-less members out of the 30 designed members; the remaining 16 come with AR-05/06. Every member is implemented on the ArkTS side, and the member descriptions below state the ArkTS-side semantics. This version ships the declarations only: no cross-boundary path exists yet to create an instance or call a member.

### init(Float64)

```cangjie
public init(arrayLength: Float64)
```

Description: constructs an ArkTS array object of the given length, with new elements left as ArkTS-side holes.

Parameters:

- arrayLength: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the array length.

### init(Array\<T>)

```cangjie
public init(@RestParam items: Array<T>)
```

Description: constructs an ArkTS array object from the given elements.

Note: how the `@RestParam items` list is passed to the ArkTS `Array` constructor is not settled yet and is an AR-05/06 open item. ArkTS/JS `new Array(...items)` hits the length-constructor overload when `items` is exactly one numeric element (for example, `new Array(3.0)` yields a hole-filled array of length 3), so the construction rule must avoid that trap.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the array elements; the variadic syntax allows the array literal brackets `[]` to be omitted.

### static func isArray(ArkTSType)

```cangjie
public static func isArray(arg: ArkTSType): Bool
```

Description: checks whether the given value is an ArkTS array object.

Parameters:

- arg: [ArkTSType](interop_arkts_package_interfaces.md#interface-arktstype) - the value to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` if the value is an array object, `false` otherwise.

### static prop prototype

```cangjie
public static prop prototype: ArkTSType
```

Description: the prototype object of the ArkTS `Array` constructor. It is a static member of the constructor, accessed through the type name; instances do not expose it.

Type: [ArkTSType](interop_arkts_package_interfaces.md#interface-arktstype)

### prop length

```cangjie
public prop length: Float64
```

Description: the number of elements in the array.

Type: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64)

### func pop()

```cangjie
public func pop(): Option<T>
```

Description: removes and returns the last element of the array.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - the removed element, or `None` when the array is empty.

### func push(Array\<T>)

```cangjie
public func push(@RestParam items: Array<T>): Float64
```

Description: appends elements to the end of the array.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the elements to append; the variadic syntax allows the array literal brackets `[]` to be omitted.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the new array length.

### func join(Option\<String>)

```cangjie
public func join(separator!: Option<String> = None): String
```

Description: converts the array elements to strings and joins them with a separator, following the ArkTS `Array.prototype.join` semantics.

Parameters:

- separator!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - the separator between elements, defaults to `None`.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - the joined string.

### func reverse()

```cangjie
public func reverse(): ArkTSArray<T>
```

Description: reverses the element order in place.

Returns:

- [ArkTSArray](#class-arktsarrayt)\<T> - the array object itself, so calls can be chained.

### func shift()

```cangjie
public func shift(): Option<T>
```

Description: removes and returns the first element of the array.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - the removed element, or `None` when the array is empty.

### func unshift(Array\<T>)

```cangjie
public func unshift(@RestParam items: Array<T>): Float64
```

Description: inserts elements at the beginning of the array and shifts the existing elements back.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the elements to insert; the variadic syntax allows the array literal brackets `[]` to be omitted.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the new array length.

### func slice(Option\<Float64>, Option\<Float64>)

```cangjie
public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSArray<T>
```

Description: copies the elements in the index range `[start, end)` into a new ArkTS array, following the ArkTS `Array.prototype.slice` semantics (including negative indices).

Parameters:

- start!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the start index, defaults to `None`.
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the end index (exclusive), defaults to `None`.

Returns:

- [ArkTSArray](#class-arktsarrayt)\<T> - a new array object holding the copied elements.

### func indexOf(T, Option\<Float64>)

```cangjie
public func indexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
```

Description: searches from `fromIndex` for the first occurrence of an element.

Note: on the ArkTS side `indexOf` compares with strict equality (`===`). Whether a cross-boundary handle preserves the identity of the same ArkTS object when `T` is a reference type is not settled yet and is an AR-05/06 open item; such lookups are not guaranteed to return the expected result before then.

Parameters:

- searchElement: T - the element to find.
- fromIndex!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the index to start from, defaults to `None`.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the first index of the element, or `-1` when it is absent.

### func lastIndexOf(T, Option\<Float64>)

```cangjie
public func lastIndexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
```

Description: searches backwards from `fromIndex` for the last occurrence of an element.

Note: on the ArkTS side `lastIndexOf` compares with strict equality (`===`). Whether a cross-boundary handle preserves the identity of the same ArkTS object when `T` is a reference type is not settled yet and is an AR-05/06 open item; such lookups are not guaranteed to return the expected result before then.

Parameters:

- searchElement: T - the element to find.
- fromIndex!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the index to start from, defaults to `None`.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the last index of the element, or `-1` when it is absent.

## class ArkTSString

```cangjie
@ArkTS[foreignName: "String"]
public foreign class ArkTSString {
    public init(value!: Option<String> = None)
    public prop length: Float64
    public func charAt(pos: Float64): String
    public func charCodeAt(pos: Float64): Float64
    public func indexOf(searchString: String, position!: Option<Float64> = None): Float64
    public func lastIndexOf(searchString: String, position!: Option<Float64> = None): Float64
    public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
    public func substring(start: Float64, end!: Option<Float64> = None): ArkTSString
    public func toUpperCase(): ArkTSString
    public func toLowerCase(): ArkTSString
    public func toString(): String
}
```

Description: the Cangjie-side type of an ArkTS `string`. It is a handle to a JS string value and can carry either a primitive string or a `String` wrapper object. By design it carries the value by reference, so crossing the boundary does not copy the contents and the string operations run on the ArkTS side. `charAt`/`toString` return a Cangjie `String` by value and necessarily copy the contents; `slice`/`substring`/`toUpperCase`/`toLowerCase` return a primitive JS string, carried by the returned `ArkTSString` handle.

The reference semantics and member-level conversion arrive with AR-05/06; they are not implemented in this version. Within AR-03, when an `ArkTSString` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version.

This version declares 11 body-less members out of the 47 designed members; the remaining 36 come with AR-05/06. Every member is implemented on the ArkTS side, and the member descriptions below state the ArkTS-side semantics. This version ships the declarations only: no cross-boundary path exists yet to create an instance or call a member.

### init(Option\<String>)

```cangjie
public init(value!: Option<String> = None)
```

Description: constructs an ArkTS string object from the given value.

Parameters:

- value!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - the initial string value, defaults to `None`.

### prop length

```cangjie
public prop length: Float64
```

Description: the string length, counted in ArkTS UTF-16 code units.

Type: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64)

### func charAt(Float64)

```cangjie
public func charAt(pos: Float64): String
```

Description: returns the character at the given index.

Parameters:

- pos: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the character index.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - the character at that index, or an empty string when the index is out of range.

### func charCodeAt(Float64)

```cangjie
public func charCodeAt(pos: Float64): Float64
```

Description: returns the UTF-16 code unit value of the character at the given index.

Parameters:

- pos: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the character index.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the code unit value, or `NaN` when the index is out of range.

### func indexOf(String, Option\<Float64>)

```cangjie
public func indexOf(searchString: String, position!: Option<Float64> = None): Float64
```

Description: searches from `position` for the first occurrence of a substring.

Parameters:

- searchString: [String](../../core/core_package_api/core_package_structs.md#struct-string) - the substring to find.
- position!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the index to start from, defaults to `None`.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the first index of the substring, or `-1` when it is absent.

### func lastIndexOf(String, Option\<Float64>)

```cangjie
public func lastIndexOf(searchString: String, position!: Option<Float64> = None): Float64
```

Description: searches backwards from `position` for the last occurrence of a substring.

Parameters:

- searchString: [String](../../core/core_package_api/core_package_structs.md#struct-string) - the substring to find.
- position!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the index to start from, defaults to `None`.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the last index of the substring, or `-1` when it is absent.

### func slice(Option\<Float64>, Option\<Float64>)

```cangjie
public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
```

Description: copies the characters in the index range `[start, end)` into a new ArkTS string, following the ArkTS `String.prototype.slice` semantics (including negative indices).

Parameters:

- start!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the start index, defaults to `None`.
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the end index (exclusive), defaults to `None`.

Returns:

- [ArkTSString](#class-arktsstring) - a new string object holding the copied characters.

### func substring(Float64, Option\<Float64>)

```cangjie
public func substring(start: Float64, end!: Option<Float64> = None): ArkTSString
```

Description: copies the characters in the index range `[start, end)` into a new ArkTS string, following the ArkTS `String.prototype.substring` semantics (a negative index is treated as `0`).

Parameters:

- start: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the start index.
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the end index (exclusive), defaults to `None`.

Returns:

- [ArkTSString](#class-arktsstring) - a new string object holding the copied characters.

### func toUpperCase()

```cangjie
public func toUpperCase(): ArkTSString
```

Description: converts the string to upper case.

Returns:

- [ArkTSString](#class-arktsstring) - a new string object with the converted content.

### func toLowerCase()

```cangjie
public func toLowerCase(): ArkTSString
```

Description: converts the string to lower case.

Returns:

- [ArkTSString](#class-arktsstring) - a new string object with the converted content.

### func toString()

```cangjie
public func toString(): String
```

Description: returns the string contents by value.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - the string contents.

## class ArkTSFunc\<F\>

```cangjie
@ArkTS
public class ArkTSFunc<F> {
    private init()
}
```

Description: the Cangjie-side type of an ArkTS function value; `F` is a Cangjie function type.

In this version it is an empty shell: it has no public members and a private constructor, so it cannot be constructed and cannot be called directly. `F` must be a Cangjie function type that satisfies the `ArkTSType` constraint; constructing a value, calling it, and checking the constraint are designed as compiler built-ins (not a where-clause) and arrive with AR-05/06, so they are not guaranteed in this version. Because the parent type `Function` is not in the standard library yet, the inheritance `ArkTSFunc<F> <: Function` is not declared for now.

## class ArkTSFuncWithThis\<ThisT, F\>

```cangjie
@ArkTS
public class ArkTSFuncWithThis<ThisT, F> {
    private init()
}
```

Description: the Cangjie-side type of an ArkTS function value that declares a `this` parameter; `ThisT` is the mapped type of that `this` parameter and `F` is a Cangjie function type.

Like [ArkTSFunc](#class-arktsfuncf), it is an empty shell in this version: no public members, a private constructor, no construction, no direct call. The constraints on `ThisT` and `F` are designed as compiler built-ins and arrive with AR-05/06, so they are not guaranteed in this version.
