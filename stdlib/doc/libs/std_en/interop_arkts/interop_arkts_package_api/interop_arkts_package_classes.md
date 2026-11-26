# Classes

## class ArkTSArray\<T>

```cangjie
public class ArkTSArray<T> where T <: JSInteropType<T> {
    public init(arrayLength: Float64)
    public init(items: Array<T>)
}
```

Function: the Cangjie-side type of an ArkTS `Array<T>`/`T[]` object. It references the same ArkTS array object, so modifications on either side are visible on the other; member calls act on that same array object.

This version delivers the reference semantics and the member-level conversion: the class is a compiler-prepared generic wrapper (the compiler installs the `JSObject` reference storage, the wrapping constructors and the accessor), the member bodies are implemented by this package's source, and the element conversions follow the hidden `T <: JSInteropType<T>` runtime contract (`T.fromJSValue` / `toJSValue`). An `ArkTSArray<T>` position in an `@ArkTS foreign` signature (parameter, return or nested position) maps as a reference type. An element type that does not satisfy the constraint - a user class without a `JSInteropType` conformance included - is rejected at the use site with the ordinary generic-constraint diagnostic.

This version ships 12 members (the two constructors plus `length`/`pop`/`push`/`join`/`reverse`/`shift`/`unshift`/`slice`/`indexOf`/`lastIndexOf`) out of the 30 designed members; the static members that depend on `ArkTSType` values (`isArray`, `prototype`) and the rest will be available in a later release. Every member is implemented on the ArkTS side; the member descriptions below describe the ArkTS-side semantics. `push`/`unshift` take `Array<T>` in this version (the variadic `@RestParam` spelling ships with its call-site packing in a later release).

### init(Float64)

```cangjie
public init(arrayLength: Float64)
```

Function: constructs an ArkTS array object of the given length (the ArkTS `new Array(n)` semantics); the added elements are ArkTS-side holes.

Parameters:

- arrayLength: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the array length.

### init(Array\<T>)

```cangjie
public init(items: Array<T>)
```

Function: constructs an ArkTS array object from the given elements.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the array elements; each element converts through its `JSInteropType` conformance.

### static func isArray(ArkTSType)

```cangjie
public static func isArray(arg: ArkTSType): Bool
```

Description: checks whether the given value is an ArkTS array object.

Note: this member is not delivered in this version and will be available in a later release.

Parameters:

- arg: [ArkTSType](interop_arkts_package_interfaces.md#interface-arktstype) - the value to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` if the value is an array object, `false` otherwise.

### static prop prototype

```cangjie
public static prop prototype: ArkTSArray<ArkTSType>
```

Description: the prototype object of the ArkTS `Array` constructor. It is a static member of the constructor, accessed through the type name; instances do not expose it.

Note: this member is not delivered in this version and will be available in a later release.

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
public func push(items: Array<T>): Float64
```

Description: appends elements to the end of the array.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the elements to append. This version takes `Array<T>`; the variadic `@RestParam` syntax arrives in a later release.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - the new array length.

Example:

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

main() {
    unsafe {
        // Construct from an element array
        let arr = ArkTSArray<Float64>([1.0, 2.0, 3.0])
        let length = arr.push([4.0, 5.0])
        let text = arr.join(separator: "-")
        let index = arr.indexOf(3.0, fromIndex: 0.0)
        println("${length} ${text} ${index}")

        // Construct from a length (the ArkTS new Array(n) semantics)
        let sized = ArkTSArray<Float64>(3.0)
        println(sized.length)
    }
}
```

Note: the example shows the run-time call shape. This version ships the two constructors and 12 members, and the cross-boundary calls run on the ArkTS side; `push`/`unshift` take `Array<T>`, while the variadic `@RestParam` syntax and the static members such as `isArray`/`prototype` arrive in a later release.


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
public func unshift(items: Array<T>): Float64
```

Description: inserts elements at the beginning of the array and shifts the existing elements back.

Parameters:

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - the elements to insert. This version takes `Array<T>`; the variadic `@RestParam` syntax arrives in a later release.

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

## class ArkTSString

```cangjie
public foreign class ArkTSString {
    public init(value!: Option<String> = None)
}
```

Description: the Cangjie-side type of an ArkTS `string`. It is a handle to a JS string value and carries a JS string primitive (it is not a JS object). Crossing the boundary does not copy the string contents, and the string operations run on the ArkTS side. `charAt`/`toString` return a Cangjie `String` by value and necessarily copy the contents; `slice`/`substring`/`toUpperCase`/`toLowerCase` return a primitive JS string, carried by the returned `ArkTSString` handle.

This version delivers the member-level conversion and a constructible prepared wrapper: `ArkTSString` is an ordinary (non-generic) wrapper prepared by the compiler, the compiler generates its member bodies onto the prepared wrapper, and both construction and member calls are usable. An `ArkTSString` position in an `@ArkTS foreign` signature (a parameter, the return value, or a nested position) maps as a reference type.

This version ships 11 members (the constructor plus `length`/`charAt`/`charCodeAt`/`indexOf`/`lastIndexOf`/`slice`/`substring`/`toUpperCase`/`toLowerCase`/`toString`) out of the 47 designed members; the remaining 36 arrive in a later release. Every member is implemented on the ArkTS side, and the member descriptions below state the ArkTS-side semantics.

### init(Option\<String>)

```cangjie
public init(value!: Option<String> = None)
```

Description: constructs an `ArkTSString` handle carrying the given string value.

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

Note: the example shows the run-time call shape. This version ships the constructible `ArkTSString` wrapper and 11 members, and the cross-boundary calls run on the ArkTS side.

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

## class ExternConversionException

```cangjie
public class ExternConversionException <: Exception {
    public init(message: String)
}
```

Description: the named exception thrown when a cross-boundary conversion fails, whose message distinguishes "type mismatch" from "invalid value".

This package hosts the type: the wrapper bodies the compiler generates for the preset types belong to this package and throw the exception by name, while the `arkts.lang` facade re-exports it through its `public import std.interop.arkts.*`, so applications reaching it through `arkts.lang` can `throw`/`catch` it by name. The facade does not declare the type itself: a facade-side declaration would force the generated preset wrappers to import `arkts.lang`, creating the same-package cycle (`std.interop.arkts` → `arkts.lang` → `std.interop.arkts`).

Note: this is an ordinary public exception class, not one of the three preset external ArkTS types (`ArkTSArray`/`ArkTSString`/`ArkTSType`), and it takes no part in the signature-position rejection. `std.core`'s `Extern` mechanism also exports an exception of the same name (present when `env != "ohos"`); a name reached through an explicit import of this package or of `arkts.lang` takes precedence over the implicitly pre-imported `std.core`, and code facing both can qualify the name. This version ships the exception type itself; the actual throw sites are provided by the compiler-generated conversion points, and this package carries no conversion logic.
