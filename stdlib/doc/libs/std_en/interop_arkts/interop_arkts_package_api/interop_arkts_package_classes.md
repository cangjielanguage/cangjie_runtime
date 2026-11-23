# Classes

## class ArkTSArray\<T>

```cangjie
public foreign class ArkTSArray<T> {
    public init(arrayLength: Float64)
    public init(@RestParam items: Array<T>)
}
```

Description: the Cangjie-side type of an ArkTS `Array<T>`/`T[]` object. By design it references the same instance as the ArkTS array object, so a modification on either side is visible on the other.

The reference semantics and member-level conversion arrive in a later release; they are not implemented in this version. In this version, when an `ArkTSArray<T>` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version.

This version declares 14 body-less members out of the 30 designed members; the remaining 16 come in a later release. Every member is implemented on the ArkTS side, and the member descriptions below state the ArkTS-side semantics. This version ships the declarations only: no cross-boundary path exists yet to create an instance or call a member.

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

Note: how the `@RestParam items` list is passed to the ArkTS `Array` constructor is not settled yet and is an open item for a later release. ArkTS/JS `new Array(...items)` hits the length-constructor overload when `items` is exactly one numeric element (for example, `new Array(3.0)` yields a hole-filled array of length 3), so the construction rule must avoid that trap.

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
public static prop prototype: ArkTSArray<ArkTSType>
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
public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
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

Note: on the ArkTS side `indexOf` compares with strict equality (`===`). Whether a cross-boundary handle preserves the identity of the same ArkTS object when `T` is a reference type is not settled yet and is an open item for a later release; such lookups are not guaranteed to return the expected result before then.

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

Note: on the ArkTS side `lastIndexOf` compares with strict equality (`===`). Whether a cross-boundary handle preserves the identity of the same ArkTS object when `T` is a reference type is not settled yet and is an open item for a later release; such lookups are not guaranteed to return the expected result before then.

Parameters:

- searchElement: T - the element to find.
- fromIndex!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - the index to start from, defaults to `None`.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the last index of the element, or `-1` when it is absent.

Example:

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

main() {
    unsafe {
        // Variadic construction: three arguments do not hit the length overload init(Float64)
        let arr = ArkTSArray<Float64>(1.0, 2.0, 3.0)
        let length = arr.push(4.0, 5.0)
        let text = arr.join(separator: "-")
        let index = arr.indexOf(3.0, fromIndex: 0.0)
        println("${length} ${text} ${index}")
    }
}
```

Note: the example shows the call shape. This version ships the declarations only; the cross-boundary calls at run time are out of scope for this version.

## class ArkTSString

```cangjie
public foreign class ArkTSString {
    public init(value!: Option<String> = None)
}
```

Description: the Cangjie-side type of an ArkTS `string`. It is a handle to a JS string value and can carry either a primitive string or a `String` wrapper object. By design it carries the value by reference, so crossing the boundary does not copy the contents and the string operations run on the ArkTS side. `charAt`/`toString` return a Cangjie `String` by value and necessarily copy the contents; `slice`/`substring`/`toUpperCase`/`toLowerCase` return a primitive JS string, carried by the returned `ArkTSString` handle.

The reference semantics and member-level conversion arrive in a later release; they are not implemented in this version. In this version, when an `ArkTSString` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version.

This version declares 11 body-less members out of the 47 designed members; the remaining 36 come in a later release. Every member is implemented on the ArkTS side, and the member descriptions below state the ArkTS-side semantics. This version ships the declarations only: no cross-boundary path exists yet to create an instance or call a member.

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

Example:

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

main() {
    unsafe {
        let s = ArkTSString(value: "Hello")
        let length = s.length
        let ch = s.charAt(1.0)
        let sub = s.substring(1.0, end: 4.0)
        let index = s.indexOf("ll", position: 0.0)
        println("${length} ${ch} ${sub.toString()} ${index}")
    }
}
```

Note: the example shows the call shape. This version ships the declarations only; the cross-boundary calls at run time are out of scope for this version.

## class ArkTSFunc\<F>

```cangjie
public foreign class ArkTSFunc<F> {
    public init(f: F)
}
```

Description: the Cangjie-side type of an ArkTS function value; `F` is a Cangjie function type.

`F` must be a Cangjie function type that satisfies the `ArkTSType` constraint; the constraint check, the construction of a value, and the direct call are designed as compiler built-ins (not a where-clause). This version provides construction only; the direct call depends on the parent type `Function`. Because the parent type `Function` is not in the standard library yet, the inheritance `ArkTSFunc<F> <: Function` is not declared for now.

### init(F)

```cangjie
public init(f: F)
```

Description: explicitly constructs an `ArkTSFunc<F>` from a Cangjie function value, in the form `ArkTSFunc<F>(f)`. `f` can be a function name, a lambda, a method reference, or a variable of type `F`.

Parameters:

- f: `F` - the Cangjie function value.

Description: implicit conversion from a Cangjie function value to `ArkTSFunc<F>` and variance are not supported.

Example:

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

func addOne(x: Float64): Float64 {
    return x + 1.0
}

main() {
    unsafe {
        // Only explicit construction is supported; implicit conversion and variance are not
        let fn = ArkTSFunc<(Float64) -> Float64>(addOne)
        println(fn is ArkTSFunc<(Float64) -> Float64>)
    }
}
```

Note: this version supports explicit construction of an `ArkTSFunc<F>` only. Directly calling the value depends on the parent type `Function`, is not implemented yet, and will be provided in a later version; the `is` check merely keeps the variable used in the example.

## class ArkTSFuncWithThis\<ThisT, F>

```cangjie
public foreign class ArkTSFuncWithThis<ThisT, F> {
}
```

Description: the Cangjie-side type of an ArkTS function value that declares a `this` parameter; `ThisT` is the mapped type of that `this` parameter and `F` is a Cangjie function type.

`ArkTSFuncWithThis<ThisT, F>` has no public constructor, and its values can only come from a `foreign func` declaration annotated with `@HasThis`. The constraints on `ThisT` and `F` are designed as compiler built-in checks.

### func bind(ThisT)

```cangjie
public func bind(thisArg: ThisT): ArkTSFunc<F>
```

Description: binds `thisArg` as the ArkTS-side `this` to the function value and returns the bound `ArkTSFunc<F>`. Calling `bind` several times on the same value yields independent results.

Parameters:

- thisArg: `ThisT` - the value of the ArkTS-side `this` parameter.

Returns:

- [ArkTSFunc\<F>](#class-arktsfuncf) - the function value bound to `thisArg`.

Note: in this version `bind` performs member lookup and type checking only, and calling `bind` reports "not supported"; the direct call of an `ArkTSFunc<F>` is not implemented either. Both will be provided in a later version, so no runnable example is possible in this version.
