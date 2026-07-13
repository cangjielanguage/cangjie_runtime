# Built-in Types

## Bool

Function: Represents the boolean type with two possible values: `true` and `false`.

### extend Bool <: Equatable\<Bool>

```cangjie
extend Bool <: Equatable<Bool>
```

Function: Extends the [Bool](core_package_intrinsics.md#bool) type with the [Equatable](core_package_interfaces.md#interface-equatablet)\<[Bool](core_package_intrinsics.md#bool)> interface to support equality comparison.

Parent types:

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Bool](#bool)>

### extend Bool <: Hashable

```cangjie
extend Bool <: Hashable
```

Function: Extends the [Bool](core_package_intrinsics.md#bool) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var flag: Bool = false
    println(flag.hashCode())
    flag = true
    println(flag.hashCode())
}
```

Execution result:

```text
0
1
```

### extend Bool <: ToString

```cangjie
extend Bool <: ToString
```

Function: Extends the [Bool](core_package_intrinsics.md#bool) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts a [Bool](core_package_intrinsics.md#bool) value to an output-ready string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var flag: Bool = false
    let str1: String = flag.toString()
    println(str1)
    flag = true
    let str2: String = flag.toString()
    println(str2)
}
```

Execution result:

```text
false
true
```

## CPointer\<T>

Function: Represents a pointer to an instance of type `T`, used for interoperability with C language, corresponding to C's `T*`.

The type `T` must satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint.

The [CPointer](core_package_intrinsics.md#cpointert) type must satisfy:

- Size and alignment are platform-dependent.
- Pointer arithmetic operations and memory read/write require an unsafe context.
- [CPointer](core_package_intrinsics.md#cpointert)\<T1> can be type-cast to [CPointer](core_package_intrinsics.md#cpointert)\<T2> in an unsafe context.

### extend\<T> CPointer\<T>

```cangjie
extend<T> CPointer<T>
```

Function: Extends [CPointer](core_package_intrinsics.md#cpointert)\<T> with essential pointer-related interfaces including null checks and data read/write operations.

The generic type `T` represents the pointer type and must satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint. Operations on [CPointer](core_package_intrinsics.md#cpointert) must be performed in an `unsafe` context.

#### func asResource()

```cangjie
public func asResource(): CPointerResource<T>
```

Function: Gets the [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype) instance for this pointer, which enables automatic resource release in `try-with-resource` syntax contexts.

Returns:

- [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype)\<T> - The corresponding [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype) instance for the current pointer.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

main() {
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    unsafe { ptr.write(10) }
    var ptrResource: CPointerResource<Int64> = ptr.asResource()
    try (r = ptrResource) {
        var p = r.value
        let num: Int64 = unsafe { p.read() }
        println(num)
    }
    println(ptrResource.isClosed())
}
```

Execution result:

```text
10
true
```

#### func isNotNull()

```cangjie
public func isNotNull(): Bool
```

Function: Checks if the pointer is not null.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not null, otherwise false.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let p1 = CPointer<Int64>()
    println(p1.isNotNull())
    let sizeofInt64: UIntNative = 8
    var p2 = unsafe { malloc(sizeofInt64) }
    println(p2.isNotNull())
    unsafe { free(p2) }
}
```

Execution result:

```text
false
true
```

#### func isNull()

```cangjie
public func isNull(): Bool
```

Function: Checks if the pointer is null.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if null, otherwise false.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    unsafe { ptr.write(10) }
    let num: Int64 = unsafe { ptr.read() }
    println(num)
    unsafe { free(p1) }
}
```

Execution result:

```text
10
```

#### func read()

```cangjie
public unsafe func read(): T
```

Function: Reads the first data element. Users must ensure pointer validity to avoid undefined behavior.

Returns:

- T - The first data element of the object type.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let p1 = CPointer<Int64>()
    println(p1.isNull())
    let sizeofInt64: UIntNative = 8
    var p2 = unsafe { malloc(sizeofInt64) }
    println(p2.isNull())
    unsafe { free(p2) }
}
```

Execution result:

```text
true
false
```

#### func read(Int64)

```cangjie
public unsafe func read(idx: Int64): T
```

Function: Reads data at the specified index. Users must ensure pointer validity to avoid undefined behavior.

Parameters:

- idx: [Int64](core_package_intrinsics.md#int64) - The index of the data to read.

Returns:

- T - The data at the specified index.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    var cptr: CPointer<Int64> = cptrHandle.pointer

    let num: Int64 = unsafe { cptr.read(2) }
    println("The third element of the array is ${num} ")

    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution result:

```text
The third element of the array is 3
```

#### func toUIntNative()

```cangjie
public func toUIntNative(): UIntNative
```

Function: Gets the integer representation of the pointer.

Returns:

- [UIntNative](core_package_intrinsics.md#uintnative) - The integer representation of the pointer.

Example:

<!-- run -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let sizeofInt64: UIntNative = 8
    var p = unsafe { malloc(sizeofInt64) }
    var p1 = unsafe { CPointer<Int64>(p) }
    unsafe { p1.write(8) }
    println(p1.toUIntNative())
    unsafe { free(p) }
}
```

Execution result:

```text
93954490863648
```

#### func write(Int64, T)

```cangjie
public unsafe func write(idx: Int64, value: T): Unit
```

Function: Writes data at the specified index. Users must ensure pointer validity to avoid undefined behavior.

Parameters:

- idx: [Int64](core_package_intrinsics.md#int64) - The index position to write.
- value: T - The data to write.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }

    var cptr: CPointer<Int64> = cptrHandle.pointer

    unsafe { cptr.write(2, 6) }

    println("The third element of the array is ${arr[2]} ")
    // The first element of the array is 1
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution result:

```text
The third element of the array is 6
```

#### func write(T)

```cangjie
public unsafe func write(value: T): Unit
```

Function: Writes data at the first position. Users must ensure pointer validity to avoid undefined behavior.

Parameters:

- value: T - The data to write.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let sizeofInt64: UIntNative = 8
    var p = unsafe { malloc(sizeofInt64) }
    var p1 = unsafe { CPointer<Int64>(p) }
    unsafe { p1.write(8) }
    let value: Int64 = unsafe { p1.read() }
    println(value)
    unsafe { free(p) }
}
```

Execution result:

```text
8
```

#### operator func +(Int64)

```cangjie
public unsafe operator func +(offset: Int64): CPointer<T>
```

Function: Moves the [CPointer](core_package_intrinsics.md#cpointert) pointer forward, equivalent to C's pointer addition operation.

Parameters:

- offset: [Int64](core_package_intrinsics.md#int64) - The offset value.

Returns:

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - The pointer after offset.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    var cptr: CPointer<Int64> = cptrHandle.pointer

    let num1: Int64 = unsafe { cptr.read() }
    println(num1)
    cptr = unsafe { cptr + 1 }
    let num2: Int64 = unsafe { cptr.read() }
    println(num2)
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution result:

```text
1
2
```

#### operator func -(Int64)

```cangjie
public unsafe operator func -(offset: Int64): CPointer<T>
```

Function: Moves the [CPointer](core_package_intrinsics.md#cpointert) pointer backward, equivalent to C's pointer subtraction operation.

Parameters:

- offset: [Int64](core_package_intrinsics.md#int64) - The offset value.

Returns:

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - The pointer after offset.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    var cptr: CPointer<Int64> = cptrHandle.pointer

    let num1: Int64 = unsafe { cptr.read() }
    println(num1)
    cptr = unsafe { cptr + 1 }
    let num2: Int64 = unsafe { cptr.read() }
    println(num2)
    cptr = unsafe { cptr - 1 }
    let num3: Int64 = unsafe { cptr.read() }
    println(num3)
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution result:

```text
1
2
1
```

## CString

Function: Represents C-style strings, used in scenarios requiring interoperability with C language.

C-style strings can be created through the constructor of [CString](core_package_intrinsics.md#cstring) or the `mallocCString` method of [LibC](core_package_structs.md#struct-libc). To release memory on the Cangjie side, call the free method of [LibC](core_package_structs.md#struct-libc).

### extend CString <: ToString

```cangjie
extend CString <: ToString
```

Function: Extends common methods for string pointers to the [CString](core_package_intrinsics.md#cstring) type, including null checks, length retrieval, equality checks, substring extraction, etc.

Parent Type:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func asResource()

```cangjie
public func asResource(): CStringResource
```

Function: Obtains the [CStringResource](core_package_structs.md#struct-cstringresource) instance corresponding to the current [CString](core_package_intrinsics.md#cstring) instance.

[CStringResource](core_package_structs.md#struct-cstringresource) implements the [Resource](core_package_interfaces.md#interface-resource) interface, enabling automatic resource release in `try-with-resource` syntax contexts.

Returns:

- [CStringResource](core_package_structs.md#struct-cstringresource) - The corresponding [CStringResource](core_package_structs.md#struct-cstringresource) C-string resource type instance.

Example:

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

main() {
    var str: CString = unsafe { LibC.mallocCString("hello") }
    var ptrResource: CStringResource = str.asResource()
    try (r = ptrResource) {
        var p = r.value
        println(p.size())
    }
    println(ptrResource.isClosed())
}
```

Execution Result:

```text
5
true
```

#### func compare(CString)

```cangjie
public func compare(str: CString): Int32
```

Function: Compares two strings lexicographically, equivalent to C's `strcmp`.

Parameters:

- str: [CString](core_package_intrinsics.md#cstring) - The target string to compare.

Returns:

- [Int32](core_package_intrinsics.md#int32) - Returns 0 if equal, -1 if the current string is lexicographically smaller than str, otherwise 1.

Exceptions:

- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - Thrown if either [CString](core_package_intrinsics.md#cstring) being compared is a null pointer.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.compare(str2))

    var str3: CString = unsafe { LibC.mallocCString("hello") }
    var str4: CString = unsafe { LibC.mallocCString("hellow") }
    println(str3.compare(str4))

    var str5: CString = unsafe { LibC.mallocCString("hello") }
    var str6: CString = unsafe { LibC.mallocCString("allow") }
    println(str5.compare(str6))

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
        LibC.free(str3)
        LibC.free(str4)
        LibC.free(str5)
        LibC.free(str6)
    }
}
```

Execution Result:

```text
0
-1
1
```

#### func endsWith(CString)

```cangjie
public func endsWith(suffix: CString): Bool
```

Function: Checks if the string ends with the specified suffix.

Parameters:

- suffix: [CString](core_package_intrinsics.md#cstring) - The target suffix string to match.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string ends with suffix, false otherwise. Returns false if either string pointer is null.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = unsafe { LibC.mallocCString("lo") }
    var str3: CString = unsafe { LibC.mallocCString("ao") }

    println(str1.endsWith(str2))
    println(str1.endsWith(str3))

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
        LibC.free(str3)
    }
}
```

Execution Result:

```text
true
false
```

#### func equals(CString)

```cangjie
public func equals(rhs: CString): Bool
```

Function: Checks if two strings are equal.

Parameters:

- rhs: [CString](core_package_intrinsics.md#cstring) - The target string to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the strings are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = unsafe { LibC.mallocCString("hello") }
    var str3: CString = unsafe { LibC.mallocCString("Hello") }
    println(str1.equals(str2))
    println(str1.equals(str3))

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
        LibC.free(str3)
    }
}
```

Execution Result:

```text
true
false
```

#### func equalsLower(CString)

```cangjie
public func equalsLower(rhs: CString): Bool
```

Function: Checks if two strings are equal, ignoring case.

Parameters:

- rhs: [CString](core_package_intrinsics.md#cstring) - The target string to match.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the strings are equal ignoring case, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = unsafe { LibC.mallocCString("HELLO") }
    var str3: CString = unsafe { LibC.mallocCString("Hello") }
    println(str1.equalsLower(str2))
    println(str1.equalsLower(str3))

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
        LibC.free(str3)
    }
}
```

Execution Result:

```text
true
true
```

#### func getChars()

```cangjie
public func getChars(): CPointer<UInt8>
```

Function: Retrieves the pointer to the string.

Returns:

- [CPointer](./core_package_intrinsics.md#cpointert)\<[UInt8](./core_package_intrinsics.md#uint8)> - The pointer to the string.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var ptr: CPointer<UInt8> = unsafe { str1.getChars() }
    var c: UInt8 = unsafe { ptr.read() }
    println(c) // ASCII code of 'h' is 104
    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
104
```

#### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Checks if the string is empty.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string is empty or the pointer is null, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.isEmpty())

    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
false
```

#### func isNotEmpty()

```cangjie
public func isNotEmpty(): Bool
```

Function: Checks if the string is not empty.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string is not empty, false if the pointer is null.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.isNotEmpty())

    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
true
```

#### func isNull()

```cangjie
public func isNull(): Bool
```

Function: Checks if the string pointer is null.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the pointer is null, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.isNull())

    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
false
```

#### func size()

```cangjie
public func size(): Int64
```

Function: Returns the length of the string, equivalent to C's `strlen`.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The length of the string.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.size())

    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
5
```

#### func startsWith(CString)

```cangjie
public func startsWith(prefix: CString): Bool
```

Function: Checks if the string starts with the specified prefix.

Parameters:

- prefix: [CString](core_package_intrinsics.md#cstring) - The target prefix string to match.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string starts with prefix, false otherwise. Returns false if either string pointer is null.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = unsafe { LibC.mallocCString("he") }
    println(str1.startsWith(str2))

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
    }
}
```

Execution Result:

```text
true
```

#### func subCString(UIntNative)

```cangjie
public func subCString(beginIndex: UIntNative): CString
```

Function: Extracts a substring starting from the specified position to the end of the string.

> **Note:**
>
> 1. This method returns a copy of the substring, which must be manually freed after use.
> 2. Returns a null pointer if beginIndex equals the string length.

Parameters:

- beginIndex: [UIntNative](core_package_intrinsics.md#uintnative) - The starting position for extraction, range [0, this.size()].

Returns:

- [CString](core_package_intrinsics.md#cstring) - The extracted substring.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if beginIndex exceeds the string length.
- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - Thrown if memory allocation or copying fails.

Example:

<!-- verify -->
```cangjie
main() {
    let index: UIntNative = 2
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = str1.subCString(index)
    println(str2)

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
    }
}
```

Execution Result:

```text
llo
```

#### func subCString(UIntNative, UIntNative)

```cangjie
public func subCString(beginIndex: UIntNative, subLen: UIntNative): CString
```

Function: Extracts a substring with specified starting position and length.

If the end position exceeds the string length, extraction stops at the string end.

> **Note:**
>
> 1. This method returns a copy of the substring, which must be manually freed after use.
> 2. Returns a null pointer if beginIndex equals the string length or subLen is 0.

Parameters:

- beginIndex: [UIntNative](core_package_intrinsics.md#uintnative) - The starting position for extraction, range [0, this.size()].
- subLen: [UIntNative](core_package_intrinsics.md#uintnative) - The length to extract, range [0, [UIntNative](core_package_intrinsics.md#uintnative).Max].

Returns:

- [CString](core_package_intrinsics.md#cstring) - The extracted substring.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if beginIndex exceeds the string length.
- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - Thrown if memory allocation or copying fails.

Example:

<!-- verify -->
```cangjie
main() {
    let index: UIntNative = 2
    let len: UIntNative = 2
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var str2: CString = str1.subCString(index, len)
    println(str2)

    unsafe {
        LibC.free(str1)
        LibC.free(str2)
    }
}
```

Execution Result:

```text
ll
```

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts [CString](core_package_intrinsics.md#cstring) to Cangjie's [String](core_package_structs.md#struct-string) type.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown for invalid UTF-8 byte sequences.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    println(str1.toString())

    unsafe {
        LibC.free(str1)
    }
}
```

Execution Result:

```text
hello
```

## Float16

Function: Represents a 16-bit floating-point number conforming to the half-precision format (`binary16`) in `IEEE 754`.

### extend Float16

```cangjie
extend Float16
```

Function: Extends half-precision floating-point numbers to support certain mathematical constants.

#### static prop Inf

```cangjie
public static prop Inf: Float16
```

Function: Gets the infinity value for half-precision floating-point numbers.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.Inf property
    let infValue = Float16.Inf
    println("Value of Float16.Inf: ${infValue}")
    
    // Verify it is indeed infinity
    println("Is Float16.Inf infinity: ${infValue.isInf()}")
}
```

Output:

```text
Value of Float16.Inf: inf
Is Float16.Inf infinity: true
```

#### static prop Max

```cangjie
public static prop Max: Float16
```

Function: Gets the maximum value for half-precision floating-point numbers.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.Max property
    let maxValue = Float16.Max
    println("Value of Float16.Max: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Float16.Max a normal number: ${maxValue.isNormal()}")
}
```

Output:

```text
Value of Float16.Max: 65504.000000
Is Float16.Max a normal number: true
```

#### static prop Min

```cangjie
public static prop Min: Float16
```

Function: Gets the minimum value for half-precision floating-point numbers.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.Min property
    let minValue = Float16.Min
    println("Value of Float16.Min: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Float16.Min a normal number: ${minValue.isNormal()}")
}
```

Output:

```text
Value of Float16.Min: -65504.000000
Is Float16.Min a normal number: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float16
```

Function: Gets the smallest denormal number for half-precision floating-point numbers. The smallest positive denormal number is the smallest positive number representable in IEEE double-precision format.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.MinDenormal property
    let minDenormalValue = Float16.MinDenormal
    println("Value of Float16.MinDenormal: ${minDenormalValue}")
    
    // Verify it is indeed the smallest denormal number
    println("Is Float16.MinDenormal a normal number: ${minDenormalValue.isNormal()}")
}
```

Output:

```text
Value of Float16.MinDenormal: 0.000000
Is Float16.MinDenormal a normal number: true
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float16
```

Function: Gets the smallest normal number for half-precision floating-point numbers.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.MinNormal property
    let minNormalValue = Float16.MinNormal
    println("Value of Float16.MinNormal: ${minNormalValue}")
    
    // Verify it is indeed the smallest normal number
    println("Is Float16.MinNormal a normal number: ${minNormalValue.isNormal()}")
}
```

Output:

```text
Value of Float16.MinNormal: 0.000061
Is Float16.MinNormal a normal number: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float16
```

Function: Gets the Not-a-Number (NaN) value for half-precision floating-point numbers.

Type: [Float16](./core_package_intrinsics.md#float16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.NaN property
    let nanValue = Float16.NaN
    println("Value of Float16.NaN: ${nanValue}")
    
    // Verify it is indeed NaN
    println("Is Float16.NaN Not-a-Number: ${nanValue.isNaN()}")
}
```

Output:

```text
Value of Float16.NaN: nan
Is Float16.NaN Not-a-Number: true
```

#### static func max(Float16, Float16, Array\<Float16>)

```cangjie
public static func max(a: Float16, b: Float16, others: Array<Float16>): Float16
```

Function: Returns the maximum value among a set of [Float16](./core_package_intrinsics.md#float16) numbers. The third parameter is a variadic argument that allows comparing more than two [Float16](./core_package_intrinsics.md#float16) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float16](./core_package_intrinsics.md#float16) - First number to compare.
- b: [Float16](./core_package_intrinsics.md#float16) - Second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float16](./core_package_intrinsics.md#float16)> - Additional numbers to compare.

Return:

- [Float16](./core_package_intrinsics.md#float16) - The maximum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.max static method
    let a: Float16 = 1.5f16
    let b: Float16 = 2.7f16
    let c: Float16 = 0.8f16
    let d: Float16 = 3.2f16
    let e: Float16 = 3.4f16
    let f: Float16 = 3.8f16
    let g: Float16 = 3.9f16
    
    // Find the maximum value using max method
    let maxValue = Float16.max(a, b, c, d, e, f, g)
    println("Result of Float16.max(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9): ${maxValue}")
    
    // Verify the result
    println("Is the maximum value correct: ${maxValue == g}")
}
```

Output:

```text
Result of Float16.max(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9): 3.900391
Is the maximum value correct: true
```

#### static func min(Float16, Float16, Array\<Float16>)

```cangjie
public static func min(a: Float16, b: Float16, others: Array<Float16>): Float16
```

Function: Returns the minimum value among a set of [Float16](./core_package_intrinsics.md#float16) numbers. The third parameter is a variadic argument that allows comparing more than two [Float16](./core_package_intrinsics.md#float16) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float16](./core_package_intrinsics.md#float16) - First number to compare.
- b: [Float16](./core_package_intrinsics.md#float16) - Second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float16](./core_package_intrinsics.md#float16)> - Additional numbers to compare.

Return:

- [Float16](./core_package_intrinsics.md#float16) - The minimum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.min static method
    let a: Float16 = 1.5f16
    let b: Float16 = 2.7f16
    let c: Float16 = 0.8f16
    let d: Float16 = 3.2f16
    let e: Float16 = 3.4f16
    let f: Float16 = 3.8f16
    let g: Float16 = 3.9f16
    
    // Find the minimum value using min method
    let minValue = Float16.min(a, b, c, d, e, f, g)
    println("Result of Float16.min(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9): ${minValue}")
    
    // Verify the result
    println("Is the minimum value correct: ${minValue == c}")
}
```

Output:

```text
Result of Float16.min(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9): 0.799805
Is the minimum value correct: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

Function: Determines whether a [Float16](./core_package_intrinsics.md#float16) value is infinity.

Return:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float16](./core_package_intrinsics.md#float16) value is positive or negative infinity; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.isInf method
    let normalValue: Float16 = 1.5f16
    let infValue = Float16.Inf
    let negInfValue = -Float16.Inf
    
    // Check if a normal value is infinity
    println("Result of 1.5f16.isInf(): ${normalValue.isInf()}")
    
    // Check if positive infinity is infinity
    println("Result of Float16.Inf.isInf(): ${infValue.isInf()}")
    
    // Check if negative infinity is infinity
    println("Result of (-Float16.Inf).isInf(): ${negInfValue.isInf()}")
}
```

Output:

```text
Result of 1.5f16.isInf(): false
Result of Float16.Inf.isInf(): true
Result of (-Float16.Inf).isInf(): true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

Function: Determines whether a [Float16](./core_package_intrinsics.md#float16) value is Not-a-Number (NaN).

Return:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float16](./core_package_intrinsics.md#float16) value is NaN; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.isNaN method
    let normalValue: Float16 = 1.5f16
    let nanValue = Float16.NaN
    
    // Check if a normal value is NaN
    println("Result of 1.5f16.isNaN(): ${normalValue.isNaN()}")
    
    // Check if NaN value is NaN
    println("Result of Float16.NaN.isNaN(): ${nanValue.isNaN()}")
}
```

Output:

```text
Result of 1.5f16.isNaN(): false
Result of Float16.NaN.isNaN(): true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

Function: Determines whether a [Float16](./core_package_intrinsics.md#float16) value is a normal number.

Return:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float16](./core_package_intrinsics.md#float16) value is a normal floating-point number; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.isNormal method
    let normalValue: Float16 = 1.5f16
    let zeroValue: Float16 = 0.0f16
    let infValue = Float16.Inf
    let nanValue = Float16.NaN
    
    // Check if a normal value is normal
    println("Result of 1.5f16.isNormal(): ${normalValue.isNormal()}")
    
    // Check if zero is normal
    println("Result of 0.0f16.isNormal(): ${zeroValue.isNormal()}")
    
    // Check if infinity is normal
    println("Result of Float16.Inf.isNormal(): ${infValue.isNormal()}")
    
    // Check if NaN is normal
    println("Result of Float16.NaN.isNormal(): ${nanValue.isNormal()}")
}
```

Output:

```text
Result of 1.5f16.isNormal(): true
Result of 0.0f16.isNormal(): false
Result of Float16.Inf.isNormal(): false
Result of Float16.NaN.isNormal(): false
```

### extend Float16 <: Comparable\<Float16>

```cangjie
extend Float16 <: Comparable<Float16>
```

Function: Extends the [Float16](core_package_intrinsics.md#float16) type to implement the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float16](core_package_intrinsics.md#float16)> interface, supporting comparison operations.

Parent Type:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float16](#float16)>

#### func compare(Float16)

```cangjie
public func compare(rhs: Float16): Ordering
```

Function: Compares the current [Float16](core_package_intrinsics.md#float16) value with another specified [Float16](core_package_intrinsics.md#float16) value. `NaN` cannot participate in the comparison, the return value is meaningless.

Parameter:

- rhs: [Float16](core_package_intrinsics.md#float16) - Another [Float16](core_package_intrinsics.md#float16) value to compare.

Return:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, or [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float16 = 0.12
    var num2: Float16 = 0.234
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Float16

```cangjie
extend Float16
```

Function: Supports conversion between [Float16](core_package_intrinsics.md#float16) and [UInt16](core_package_intrinsics.md#uint16).

#### static func fromBits(UInt16)

```cangjie
public static func fromBits(bits: UInt16): Float16
```

Function: Converts the specified [UInt16](core_package_intrinsics.md#uint16) to a [Float16](core_package_intrinsics.md#float16) floating-point number according to the binary representation of float16 in the `IEEE 754` standard.

Parameter:

- bits: [UInt16](core_package_intrinsics.md#uint16) - The number to convert.

Return:

- [Float16](core_package_intrinsics.md#float16) - The conversion result, with the same bits as the parameter.

Example:

<!-- verify -->
```cangjie
main() {
    let v = Float16.fromBits(0x4A40u16)
    println(v)
}
```

Output:

```text
12.500000
```

#### func toBits()

```cangjie
public func toBits(): UInt16
```

Function: Converts the specified [Float16](core_package_intrinsics.md#float16) number to a [UInt16](core_package_intrinsics.md#uint16) number representing its bits.

Return:

- [UInt16](core_package_intrinsics.md#uint16) - The conversion result, with the same bits as the [Float16](core_package_intrinsics.md#float16) value.

Example:

<!-- verify -->
```cangjie
main() {
    println(12.5f16.toBits()) // 0x4A40 19008
}
```

Output:

```text
19008
```

### extend Float16 <: Hashable

```cangjie
extend Float16 <: Hashable
```

Function: Extends the [Float16](core_package_intrinsics.md#float16) type to implement the [Hashable](core_package_interfaces.md#interface-hashable) interface, supporting hash value computation.

Parent Type:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Computes the hash value.

Return:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.hashCode method
    let value1: Float16 = 1.5f16
    let value2: Float16 = 1.5f16
    let value3: Float16 = 2.0f16
    
    // Compute hash values
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()
    
    println("Hash value of 1.5f16: ${hash1}")
    println("Hash value of 1.5f16: ${hash2}")
    println("Hash value of 2.0f16: ${hash3}")
    
    // Verify equal values have the same hash
    println("Do equal values have the same hash: ${hash1 == hash2}")
}
```

Output:

```text
Hash value of 1.5f16: 7729828949621302189
Hash value of 1.5f16: 772982894962130## Float32

Function: Represents a 32-bit floating-point number, conforming to the single-precision format (`binary32`) in `IEEE 754`.

### extend Float16 <: ToString

```cangjie
extend Float16 <: ToString
```

Function: Extends the [Float16](core_package_intrinsics.md#float16) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to enable conversion to [String](core_package_structs.md#struct-string) type. By default, it retains 6 decimal places.

Parent Type:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts a [Float16](core_package_intrinsics.md#float16) value into an output-ready string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float16.toString method
    let value1: Float16 = 1.5f16
    let value2: Float16 = 123.456f16
    let value3: Float16 = -0.001f16
    
    // Convert to strings
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()
    
    println("1.5f16 converted to string: \"${str1}\"")
    println("123.456f16 converted to string: \"${str2}\"")
    println("-0.001f16 converted to string: \"${str3}\"")
    
    // Verify type
    println("Is the converted type String: ${str1 is String}")
}
```

Execution Result:

```text
1.5f16 converted to string: "1.500000"
123.456f16 converted to string: "123.437500"
-0.001f16 converted to string: "-0.001000"
Is the converted type String: true
```

## Float32

Function: Represents a 32-bit floating-point number, conforming to the single-precision format (`binary32`) in `IEEE 754`.

### extend Float32

```cangjie
extend Float32
```

Function: Extends single-precision floating-point numbers to support certain mathematical constants.

#### static prop Inf

```cangjie
public static prop Inf: Float32
```

Function: Gets the infinity value for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.Inf property
    let infValue = Float32.Inf
    println("Value of Float32.Inf: ${infValue}")
    
    // Verify it is indeed infinity
    println("Is Float32.Inf infinity: ${infValue.isInf()}")
}
```

Output:

```text
Value of Float32.Inf: inf
Is Float32.Inf infinity: true
```

#### static prop Max

```cangjie
public static prop Max: Float32
```

Function: Gets the maximum value for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.Max property
    let maxValue = Float32.Max
    println("Value of Float32.Max: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Float32.Max a normal number: ${maxValue.isNormal()}")
}
```

Output:

```text
Value of Float32.Max: 340282346638528859811704183484516925440.000000
Is Float32.Max a normal number: true
```

#### static prop Min

```cangjie
public static prop Min: Float32
```

Function: Gets the minimum value for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.Min property
    let minValue = Float32.Min
    println("Value of Float32.Min: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Float32.Min a normal number: ${minValue.isNormal()}")
}
```

Output:

```text
Value of Float32.Min: -340282346638528859811704183484516925440.000000
Is Float32.Min a normal number: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float32
```

Function: Gets the smallest denormal number for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.MinDenormal property
    let minDenormalValue = Float32.MinDenormal
    println("Value of Float32.MinDenormal: ${minDenormalValue}")
    
    // Verify it is indeed the smallest denormal number
    println("Is Float32.MinDenormal a normal number: ${minDenormalValue.isNormal()}")
}
```

Output:

```text
Value of Float32.MinDenormal: 0.000000
Is Float32.MinDenormal a normal number: false
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float32
```

Function: Gets the smallest normal number for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.MinNormal property
    let minNormalValue = Float32.MinNormal
    println("Value of Float32.MinNormal: ${minNormalValue}")
    
    // Verify it is indeed the smallest normal number
    println("Is Float32.MinNormal a normal number: ${minNormalValue.isNormal()}")
}
```

Output:

```text
Value of Float32.MinNormal: 0.000000
Is Float32.MinNormal a normal number: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float32
```

Function: Gets the Not-a-Number (NaN) value for single-precision floating-point numbers.

Type: [Float32](./core_package_intrinsics.md#float32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.NaN property
    let nanValue = Float32.NaN
    println("Value of Float32.NaN: ${nanValue}")
    
    // Verify it is indeed NaN
    println("Is Float32.NaN Not-a-Number: ${nanValue.isNaN()}")
}
```

Output:

```text
Value of Float32.NaN: nan
Is Float32.NaN Not-a-Number: true
```

#### static func max(Float32, Float32, Array\<Float32>)

```cangjie
public static func max(a: Float32, b: Float32, others: Array<Float32>): Float32
```

Function: Returns the maximum value among a set of [Float32](./core_package_intrinsics.md#float32) numbers. The third parameter is a variadic argument that allows comparing more than two [Float32](./core_package_intrinsics.md#float32) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float32](./core_package_intrinsics.md#float32) - The first number to compare.
- b: [Float32](./core_package_intrinsics.md#float32) - The second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float32](./core_package_intrinsics.md#float32)> - Additional numbers to compare.

Returns:

- [Float32](./core_package_intrinsics.md#float32) - The maximum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.max static method
    let a: Float32 = 1.5f32
    let b: Float32 = 2.7f32
    let c: Float32 = 0.8f32
    let d: Float32 = 3.2f32
    
    // Find the maximum value using max method
    let maxValue = Float32.max(a, b, c, d)
    println("Result of Float32.max(1.5, 2.7, 0.8, 3.2): ${maxValue}")
    
    // Verify the result
    println("Is the maximum value correct: ${maxValue == d}")
}
```

Output:

```text
Result of Float32.max(1.5, 2.7, 0.8, 3.2): 3.200000
Is the maximum value correct: true
```

#### static func min(Float32, Float32, Array\<Float32>)

```cangjie
public static func min(a: Float32, b: Float32, others: Array<Float32>): Float32
```

Function: Returns the minimum value among a set of [Float32](./core_package_intrinsics.md#float32) numbers. The third parameter is a variadic argument that allows comparing more than two [Float32](./core_package_intrinsics.md#float32) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float32](./core_package_intrinsics.md#float32) - The first number to compare.
- b: [Float32](./core_package_intrinsics.md#float32) - The second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float32](./core_package_intrinsics.md#float32)> - Additional numbers to compare.

Returns:

- [Float32](./core_package_intrinsics.md#float32) - The minimum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.min static method
    let a: Float32 = 1.5f32
    let b: Float32 = 2.7f32
    let c: Float32 = 0.8f32
    let d: Float32 = 3.2f32
    
    // Find the minimum value using min method
    let minValue = Float32.min(a, b, c, d)
    println("Result of Float32.min(1.5, 2.7, 0.8, 3.2): ${minValue}")
    
    // Verify the result
    println("Is the minimum value correct: ${minValue == c}")
}
```

Output:

```text
Result of Float32.min(1.5, 2.7, 0.8, 3.2): 0.800000
Is the minimum value correct: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

Function: Determines whether a floating-point number [Float32](./core_package_intrinsics.md#float32) is infinite.

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float32](./core_package_intrinsics.md#float32) value is positive or negative infinity; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.isInf method
    let normalValue: Float32 = 1.5f32
    let infValue = Float32.Inf
    let negInfValue = -Float32.Inf
    
    // Check if a normal value is infinite
    println("Result of 1.5f32.isInf(): ${normalValue.isInf()}")
    
    // Check if positive infinity is infinite
    println("Result of Float32.Inf.isInf(): ${infValue.isInf()}")
    
    // Check if negative infinity is infinite
    println("Result of (-Float32.Inf).isInf(): ${negInfValue.isInf()}")
}
```

Output:

```text
Result of 1.5f32.isInf(): false
Result of Float32.Inf.isInf(): true
Result of (-Float32.Inf).isInf(): true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

Function: Determines whether a floating-point number [Float32](./core_package_intrinsics.md#float32) is Not-a-Number (NaN).

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float32](./core_package_intrinsics.md#float32) value is NaN; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.isNaN method
    let normalValue: Float32 = 1.5f32
    let nanValue = Float32.NaN
    
    // Check if a normal value is NaN
    println("Result of 1.5f32.isNaN(): ${normalValue.isNaN()}")
    
    // Check if NaN value is NaN
    println("Result of Float32.NaN.isNaN(): ${nanValue.isNaN()}")
}
```

Output:

```text
Result of 1.5f32.isNaN(): false
Result of Float32.NaN.isNaN(): true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

Function: Determines whether a floating-point number [Float32](./core_package_intrinsics.md#float32) is a normal number.

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float32](./core_package_intrinsics.md#float32) value is a normal floating-point number; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.isNormal method
    let normalValue: Float32 = 1.5f32
    let zeroValue: Float32 = 0.0f32
    let infValue = Float32.Inf
    let nanValue = Float32.NaN
    
    // Check if a normal value is normal
    println("Result of 1.5f32.isNormal(): ${normalValue.isNormal()}")
    
    // Check if zero is normal
    println("Result of 0.0f32.isNormal(): ${zeroValue.isNormal()}")
    
    // Check if infinity is normal
    println("Result of Float32.Inf.isNormal(): ${infValue.isNormal()}")
    
    // Check if NaN is normal
    println("Result of Float32.NaN.isNormal(): ${nanValue.isNormal()}")
}
```

Output:

```text
Result of 1.5f32.isNormal(): true
Result of 0.0f32.isNormal(): false
Result of Float32.Inf.isNormal(): false
Result of Float32.NaN.isNormal(): false
```

### extend Float32 <: Comparable\<Float32>

```cangjie
extend Float32 <: Comparable<Float32>
```

Function: Extends the [Float32](core_package_intrinsics.md#float32) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float32](core_package_intrinsics.md#float32)> interface to support comparison operations.

Parent Type:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float32](#float32)>

#### func compare(Float32)

```cangjie
public func compare(rhs: Float32): Ordering
```

Function: Determines the relationship between the current [Float32](core_package_intrinsics.md#float32) value and the specified [Float32](core_package_intrinsics.md#float32) value. `NaN` cannot participate in the comparison, the return value is meaningless.

Parameters:

- rhs: [Float32](core_package_intrinsics.md#float32) - Another [Float32](core_package_intrinsics.md#float32) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater; [Ordering](core_package_enums.md#enum-ordering).EQ if equal; [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float32 = 0.12
    var num2: Float32 = 0.234
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Float32

```cangjie
extend Float32
```

Function: Supports conversion between [Float32](core_package_intrinsics.md#float32) and [UInt32](core_package_intrinsics.md#uint32).

#### static func fromBits(UInt32)

```cangjie
public static func fromBits(bits: UInt32): Float32
```

Function: Converts the specified [UInt32](core_package_intrinsics.md#uint32) to the corresponding [Float32](core_package_intrinsics.md#float32) floating-point number according to the `IEEE 754` standard's binary representation for float32.

Parameters:

- bits: [UInt32](core_package_intrinsics.md#uint32) - The number to convert.

Returns:

- [Float32](core_package_intrinsics.md#float32) - The conversion result, with the same bits as the parameter bits.

Example:

<!-- verify -->
```cangjie
main() {
    let v = Float32.fromBits(0x415E147Bu32)
    println(v)
}
```

Output:

```text
13.880000
```

#### func toBits()

```cangjie
public func toBits(): UInt32
```

Function: Converts the specified [Float32](core_package_intrinsics.md#float32) number to its bit representation as a [UInt32](core_package_intrinsics.md#uint32) number.

Returns:

- [UInt32](core_package_intrinsics.md#uint32) - The conversion result, with the same value as the bit representation of [Float32](core_package_intrinsics.md#float32).

Example:

<!-- verify -->
```cangjie
main() {
    println(13.88f32.toBits()) // 0x415E147B 1096684667
}
```

Output:

```text
1096684667
```

### extend Float32 <: Hashable

```cangjie
extend Float32 <: Hashable
```

Function: Extends the [Float32](core_package_intrinsics.md#float32) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Type:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float32.hashCode method
    let value1: Float32 = 1.5f32
    let value2: Float32 = 1.5f32
    let value3: Float32 = 2.0f32
    
    // Compute hash values
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()
    
    println("Hash value of 1.5f32: ${hash1}")
    println("Hash value of 1.5f32: ${hash2}")
    println("Hash value of 2.0f32: ${hash3}")
    
    // Verify equal values have the same hash value
    println("Do equal values have the same hash: ${hash1 == hash2}")
}
```

Output:

```text
Hash value of 1.5f32: 7729828949621302189
Hash value of 1.5f32: 7729828949621302189
Hash value of 2.0f32: 396734039217596648
Do equal values have the same hash: true
```

### extend Float32 <: ToString

```cangjie
extend Float32 <: ToString
```

Function: Extends the [Float32](core_package_intrinsics.md#float32) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type. By default, retains 6 decimal places.

Parent Type:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts a [Float32](core_package_intrinsics.md#float32) value to a printable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Float32.toString method
    let value1: Float32 = 1.5f32
    let value2: Float32 = 123.456f32
    let value3: Float32 = -0.001f32
    
    // Convert to strings
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()
    
    println("1.5f32 converted to string: \"${str1}\"")
    println("123.456f32 converted to string: \"${str2}\"")
    println("-0.001f32 converted to string: \"${str3}\"")
    
    // Verify type
    println("Is converted type String: ${str1 is String}")
}
```

Execution Result:

```text
1.5f32 converted to string: "1.500000"
123.456f32 converted to string: "123.456001"
-0.001f32 converted to string: "-0.001000"
Is converted type String: true
```

## Float64

Function: Represents a 64-bit floating-point number, conforming to the double-precision format (`binary64`) in `IEEE 754`.

### extend Float64

```cangjie
extend Float64
```

Function: Extends double-precision floating-point numbers to support certain mathematical constants.

#### static prop Inf

```cangjie
public static prop Inf: Float64
```

Function: Gets the infinity value for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.Inf property
    let infValue = Float64.Inf
    println("Value of Float64.Inf: ${infValue}")
    
    // Verify it is indeed infinity
    println("Is Float64.Inf infinite: ${infValue.isInf()}")
}
```

Output:

```text
Value of Float64.Inf: inf
Is Float64.Inf infinite: true
```

#### static prop Max

```cangjie
public static prop Max: Float64
```

Function: Gets the maximum value for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.Max property
    let maxValue = Float64.Max
    println("Value of Float64.Max: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Float64.Max a normal number: ${maxValue.isNormal()}")
}
```

Output:

```text
Value of Float64.Max: 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000
Is Float64.Max a normal number: true
```

#### static prop Min

```cangjie
public static prop Min: Float64
```

Function: Gets the minimum value for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.Min property
    let minValue = Float64.Min
    println("Value of Float64.Min: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Float64.Min a normal number: ${minValue.isNormal()}")
}
```

Output:

```text
Value of Float64.Min: -179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000
Is Float64.Min a normal number: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float64
```

Function: Gets the smallest denormal number for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.MinDenormal property
    let minDenormalValue = Float64.MinDenormal
    println("Value of Float64.MinDenormal: ${minDenormalValue}")
    
    // Verify it is indeed the smallest denormal number
    println("Is Float64.MinDenormal a normal number: ${minDenormalValue.isNormal()}")
}
```

Output:

```text
Value of Float64.MinDenormal: 0.000000
Is Float64.MinDenormal a normal number: false
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float64
```

Function: Gets the smallest normal number for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.MinNormal property
    let minNormalValue = Float64.MinNormal
    println("Value of Float64.MinNormal: ${minNormalValue}")
    
    // Verify it is indeed the smallest normal number
    println("Is Float64.MinNormal a normal number: ${minNormalValue.isNormal()}")
}
```

Output:

```text
Value of Float64.MinNormal: 0.000000
Is Float64.MinNormal a normal number: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float64
```

Function: Gets the Not-a-Number (NaN) value for double-precision floating-point numbers.

Type: [Float64](./core_package_intrinsics.md#float64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.NaN property
    let nanValue = Float64.NaN
    println("Value of Float64.NaN: ${nanValue}")
    
    // Verify it is indeed NaN
    println("Is Float64.NaN a NaN: ${nanValue.isNaN()}")
}
```

Output:

```text
Value of Float64.NaN: nan
Is Float64.NaN a NaN: true
```

#### static func max(Float64, Float64, Array\<Float64>)

```cangjie
public static func max(a: Float64, b: Float64, others: Array<Float64>): Float64
```

Function: Returns the maximum value among a set of [Float64](./core_package_intrinsics.md#float64) numbers. The third parameter is a variadic argument that allows comparing more than two [Float64](./core_package_intrinsics.md#float64) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float64](./core_package_intrinsics.md#float64) - The first number to compare.
- b: [Float64](./core_package_intrinsics.md#float64) - The second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float64](./core_package_intrinsics.md#float64)> - Additional numbers to compare.

Returns:

- [Float64](./core_package_intrinsics.md#float64) - The maximum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.max static method
    let a: Float64 = 1.5f64
    let b: Float64 = 2.7f64
    let c: Float64 = 0.8f64
    let d: Float64 = 3.2f64
    
    // Use max method to find the maximum value
    let maxValue = Float64.max(a, b, [c, d])
    println("Result of Float64.max(1.5, 2.7, [0.8, 3.2]): ${maxValue}")
    
    // Verify the result
    println("Is the maximum value correct: ${maxValue == d}")
}
```

Output:

```text
Result of Float64.max(1.5, 2.7, [0.8, 3.2]): 3.200000
Is the maximum value correct: true
```

#### static func min(Float64, Float64, Array\<Float64>)

```cangjie
public static func min(a: Float64, b: Float64, others: Array<Float64>): Float64
```

Function: Returns the minimum value among a set of [Float64](./core_package_intrinsics.md#float64) numbers. The third parameter is a variadic argument that allows comparing more than two [Float64](./core_package_intrinsics.md#float64) numbers. If any parameter is `NaN`, the function returns `NaN`.

Parameters:

- a: [Float64](./core_package_intrinsics.md#float64) - The first number to compare.
- b: [Float64](./core_package_intrinsics.md#float64) - The second number to compare.
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float64](./core_package_intrinsics.md#float64)> - Additional numbers to compare.

Returns:

- [Float64](./core_package_intrinsics.md#float64) - The minimum value among the parameters.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.min static method
    let a: Float64 = 1.5f64
    let b: Float64 = 2.7f64
    let c: Float64 = 0.8f64
    let d: Float64 = 3.2f64
    
    // Use min method to find the minimum value
    let minValue = Float64.min(a, b, [c, d])
    println("Result of Float64.min(1.5, 2.7, [0.8, 3.2]): ${minValue}")
    
    // Verify the result
    println("Is the minimum value correct: ${minValue == c}")
}
```

Output:

```text
Result of Float64.min(1.5, 2.7, [0.8, 3.2]): 0.800000
Is the minimum value correct: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

Function: Determines whether a floating-point number [Float64](./core_package_intrinsics.md#float64) is infinite.

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float64](./core_package_intrinsics.md#float64) value is positive or negative infinity; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.isInf method
    let normalValue: Float64 = 1.5f64
    let infValue = Float64.Inf
    let negInfValue = -Float64.Inf
    
    // Check if a normal value is infinite
    println("Result of 1.5f64.isInf(): ${normalValue.isInf()}")
    
    // Check if positive infinity is infinite
    println("Result of Float64.Inf.isInf(): ${infValue.isInf()}")
    
    // Check if negative infinity is infinite
    println("Result of (-Float64.Inf).isInf(): ${negInfValue.isInf()}")
}
```

Output:

```text
Result of 1.5f64.isInf(): false
Result of Float64.Inf.isInf(): true
Result of (-Float64.Inf).isInf(): true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

Function: Determines whether a floating-point number [Float64](./core_package_intrinsics.md#float64) is Not-a-Number (NaN).

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float64](./core_package_intrinsics.md#float64) value is NaN; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.isNaN method
    let normalValue: Float64 = 1.5f64
    let nanValue = Float64.NaN
    
    // Check if a normal value is NaN
    println("Result of 1.5f64.isNaN(): ${normalValue.isNaN()}")
    
    // Check if NaN value is NaN
    println("Result of Float64.NaN.isNaN(): ${nanValue.isNaN()}")
}
```

Output:

```text
Result of 1.5f64.isNaN(): false
Result of Float64.NaN.isNaN(): true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

Function: Determines whether a floating-point number [Float64](./core_package_intrinsics.md#float64) is a normal number.

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns `true` if the [Float64](./core_package_intrinsics.md#float64) value is a normal floating-point number; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.isNormal method
    let normalValue: Float64 = 1.5f64
    let zeroValue: Float64 = 0.0f64
    let infValue = Float64.Inf
    let nanValue = Float64.NaN
    
    // Check if a normal value is normal
    println("Result of 1.5f64.isNormal(): ${normalValue.isNormal()}")
    
    // Check if zero is normal
    println("Result of 0.0f64.isNormal(): ${zeroValue.isNormal()}")
    
    // Check if infinity is normal
    println("Result of Float64.Inf.isNormal(): ${infValue.isNormal()}")
    
    // Check if NaN is normal
    println("Result of Float64.NaN.isNormal(): ${nanValue.isNormal()}")
}
```

Output:

```text
Result of 1.5f64.isNormal(): true
Result of 0.0f64.isNormal(): false
Result of Float64.Inf.isNormal(): false
Result of Float64.NaN.isNormal(): false
```

### extend Float64 <: Comparable\<Float64>

```cangjie
extend Float64 <: Comparable<Float64>
```

Function: Extends the [Float64](core_package_intrinsics.md#float64) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float64](core_package_intrinsics.md#float64)> interface to support comparison operations.

Parent Type:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float64](#float64)>

#### func compare(Float64)

```cangjie
public func compare(rhs: Float64): Ordering
```

Function: Determines the relationship between the current [Float64](core_package_intrinsics.md#float64) value and the specified [Float64](core_package_intrinsics.md#float64) value. `NaN` cannot participate in the comparison, the return value is meaningless.

Parameter:

- rhs: [Float64](core_package_intrinsics.md#float64) - Another [Float64](core_package_intrinsics.md#float64) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater than, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less than.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float64 = 0.12
    var num2: Float64 = 0.234
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Float64

```cangjie
extend Float64
```

Function: Supports mutual conversion with [UInt64](core_package_intrinsics.md#uint64).

#### static func fromBits(UInt64)

```cangjie
public static func fromBits(bits: UInt64): Float64
```

Function: Converts the specified [UInt64](core_package_intrinsics.md#uint64) to the corresponding [Float64](core_package_intrinsics.md#float32) floating-point number according to the binary representation of float64 in the `IEEE 754` standard.

Parameter:

- bits: [UInt64](core_package_intrinsics.md#uint64) - The number to convert.

Returns:

- [Float64](core_package_intrinsics.md#float64) - The conversion result, whose bits are identical to the parameter bits.

Example:

<!-- verify -->
```cangjie
main() {
    let v = Float64.fromBits(0x402BC28F5C28F5C3u64)
    println(v)
}
```

Output:

```text
13.880000
```

#### func toBits()

```cangjie
public func toBits(): UInt64
```

Function: Converts the specified Float64 number to the corresponding [UInt64](core_package_intrinsics.md#uint64) number represented by its bits.

Returns:

- [UInt64](core_package_intrinsics.md#uint64) - The conversion result, whose value is identical to the bit representation of the [Float64](core_package_intrinsics.md#float64).

Example:

<!-- verify -->
```cangjie
main() {
    println(13.88f64.toBits()) // 0x402BC28F5C28F5C3 4624003363408246211
}
```

Output:

```text
4624003363408246211
```

### extend Float64 <: Hashable

```cangjie
extend Float64 <: Hashable
```

Function: Extends the [Float64](core_package_intrinsics.md#float64) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Type:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.hashCode method
    let value1: Float64 = 1.5f64
    let value2: Float64 = 1.5f64
    let value3: Float64 = 2.0f64
    
    // Compute hash values
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()
    
    println("Hash value of 1.5f64: ${hash1}")
    println("Hash value of 1.5f64: ${hash2}")
    println("Hash value of 2.0f64: ${hash3}")
    
    // Verify that equal values have the same hash value
    println("Do equal values have the same hash: ${hash1 == hash2}")
}
```

Execution result:

```text
Hash value of 1.5f64: -991904502584296975
Hash value of 1.5f64: -991904502584296975
Hash value of 2.0f64: 8889205371494514623
Do equal values have the same hash: true
```

### extend Float64 <: ToString

```cangjie
extend Float64 <: ToString
```

Function: Extends the [Float64](core_package_intrinsics.md#float64) type to implement the [ToString](core_package_interfaces.md#interface-tostring) interface, enabling conversion to [String](core_package_structs.md#struct-string) type. By default retains 6 decimal places.

Parent type:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts a [Float64](core_package_intrinsics.md#float64) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Float64.toString method
    let value1: Float64 = 1.5f64
    let value2: Float64 = 123.456f64
    let value3: Float64 = -0.001f64
    
    // Convert to string
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()
    
    println("1.5f64 converted to string: \"${str1}\"")
    println("123.456f64 converted to string: \"${str2}\"")
    println("-0.001f64 converted to string: \"${str3}\"")
    
    // Verify type
    println("Is converted type String: ${str1 is String}")
}
```

Execution result:

```text
1.5f64 converted to string: "1.500000"
123.456f64 converted to string: "123.456000"
-0.001f64 converted to string: "-0.001000"
Is converted type String: true
```

## Int16

Function: Represents a 16-bit signed integer with a range of [-2^{15}, 2^{15} - 1].

### extend Int16

```cangjie
extend Int16
```

Function: Extends 16-bit signed integers to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: Int16
```

Function: Gets the maximum value of a 16-bit signed integer.

Type: [Int16](./core_package_intrinsics.md#int16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int16.Max property
    let maxValue = Int16.Max
    println("Int16.Max value: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Int16.Max equal to 32767: ${maxValue == 32767}")
}
```

Output:

```text
Int16.Max value: 32767
Is Int16.Max equal to 32767: true
```

#### static prop Min

```cangjie
public static prop Min: Int16
```

Function: Gets the minimum value of a 16-bit signed integer.

Type: [Int16](./core_package_intrinsics.md#int16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int16.Min property
    let minValue = Int16.Min
    println("Int16.Min value: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Int16.Min equal to -32768: ${minValue == -32768}")
}
```

Output:

```text
Int16.Min value: -32768
Is Int16.Min equal to -32768: true
```

### extend Int16 <: Comparable\<Int16>

```cangjie
extend Int16 <: Comparable<Int16>
```

Function: Extends the [Int16](core_package_intrinsics.md#int16) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int16](core_package_intrinsics.md#int16)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int16](#int16)>

#### func compare(Int16)

```cangjie
public func compare(rhs: Int16): Ordering
```

Function: Determines the relationship between the current [Int16](core_package_intrinsics.md#int16) value and the specified [Int16](core_package_intrinsics.md#int16) value.

Parameters:

- rhs: [Int16](core_package_intrinsics.md#int16) - Another [Int16](core_package_intrinsics.md#int16) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, or [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 2
    var num2: Int16 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Int16 <: Countable\<Int16>

```cangjie
extend Int16 <: Countable<Int16>
```

Function: Extends the [Int16](core_package_intrinsics.md#int16) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[Int16](core_package_intrinsics.md#int16)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int16](#int16)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int16
```

Function: Gets the [Int16](core_package_intrinsics.md#int16) value at the position `right` units to the right of the current [Int16](core_package_intrinsics.md#int16) position on the number axis. If overflow occurs, counting continues from the leftmost end of the axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [Int16](core_package_intrinsics.md#int16) - The [Int16](core_package_intrinsics.md#int16) value at the new position.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 32767
    var num2: Int16 = 3
    println(num1.next(5))
    println(num2.next(10))
}
```

Output:

```text
-32764
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [Int16](core_package_intrinsics.md#int16) value, i.e., converts the [Int16](core_package_intrinsics.md#int16) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [Int16](core_package_intrinsics.md#int16) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 32767
    var num2: Int16 = 3
    println(num1.position())
    println(num2.position())
}
```

Output:

```text
32767
3
```

### extend Int16 <: Hashable

```cangjie
extend Int16 <: Hashable
```

Function: Extends the [Int16](core_package_intrinsics.md#int16) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Computes the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int16.hashCode method
    let value1: Int16 = 42
    let value2: Int16 = 42
    let value3: Int16 = -100
    
    // Compute hash values
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()
    
    println("Hash value of 42: ${hash1}")
    println("Hash value of 42: ${hash2}")
    println("Hash value of -100: ${hash3}")
    
    // Verify equal values have the same hash
    println("Do equal values have the same hash: ${hash1 == hash2}")
}
```

Output:

```text
Hash value of 42: 42
Hash value of 42: 42
Hash value of -100: -100
Do equal values have the same hash: true
```

### extend Int16 <: ToString

```cangjie
extend Int16 <: ToString
```

Function: Extends the [Int16](core_package_intrinsics.md#int16) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string).

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [Int16](core_package_intrinsics.md#int16) value to an output-ready string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int16.toString method
    let value1: Int16 = 42
    let value2: Int16 = -123
    let value3: Int16 = 0
    
    // Convert to strings
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()
    
    println("42 converted to string: \"${str1}\"")
    println("-123 converted to string: \"${str2}\"")
    println("0 converted to string: \"${str3}\"")
    
    // Verify type
    println("Is converted type String: ${str1 is String}")
}
```

Output:

```text
42 converted to string: "42"
-123 converted to string: "-123"
0 converted to string: "0"
Is converted type String: true
```

## Int32

Function: Represents a 32-bit signed integer with a range of [-2^{31}, 2^{31} - 1].

### extend Int32

```cangjie
extend Int32
```

Function: Extends 32-bit signed integers to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: Int32
```

Function: Gets the maximum value of a 32-bit signed integer.

Type: [Int32](./core_package_intrinsics.md#int32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int32.Max property
    let maxValue = Int32.Max
    println("Int32.Max value: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Int32.Max equal to 2147483647: ${maxValue == 2147483647}")
}
```

Output:

```text
Int32.Max value: 2147483647
Is Int32.Max equal to 2147483647: true
```

#### static prop Min

```cangjie
public static prop Min: Int32
```

Function: Gets the minimum value of a 32-bit signed integer.

Type: [Int32](./core_package_intrinsics.md#int32)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int32.Min property
    let minValue = Int32.Min
    println("Int32.Min value: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Int32.Min equal to -2147483648: ${minValue == -2147483648}")
}
```

Output:

```text
Int32.Min value: -2147483648
Is Int32.Min equal to -2147483648: true
```

### extend Int32 <: Comparable\<Int32>

```cangjie
extend Int32 <: Comparable<Int32>
```

Function: Extends the [Int32](core_package_intrinsics.md#int32) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int32](core_package_intrinsics.md#int32)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int32](#int32)>

#### func compare(Int32)

```cangjie
public func compare(rhs: Int32): Ordering
```

Function: Determines the relationship between the current [Int32](core_package_intrinsics.md#int32) value and the specified [Int32](core_package_intrinsics.md#int32) value.

Parameters:

- rhs: [Int32](core_package_intrinsics.md#int32) - Another [Int32](core_package_intrinsics.md#int32) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, or [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int32 = 8
    var num2: Int32 = 10
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Int32 <: Countable\<Int32>

```cangjie
extend Int32 <: Countable<Int32>
```

Function: Extends the [Int32](core_package_intrinsics.md#int32) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[Int32](core_package_intrinsics.md#int32)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int32](#int32)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int32
```

Function: Gets the [Int32](core_package_intrinsics.md#int32) value at the position `right` units to the right of the current [Int32](core_package_intrinsics.md#int32) position on the number axis. If overflow occurs, counting continues from the leftmost end of the axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [Int32](core_package_intrinsics.md#int32) - The [Int32](core_package_intrinsics.md#int32) value at the new position.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int32 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [Int32](core_package_intrinsics.md#int32) value, i.e., converts the [Int32](core_package_intrinsics.md#int32) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [Int32](core_package_intrinsics.md#int32) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int32 = 3
    println(num.position())
}
```

Output:

```text
3
```

### extend Int32 <: Hashable

```cangjie
extend Int32 <: Hashable
```

Function: Extends the [Int32](core_package_intrinsics.md#int32) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Computes the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int32.hashCode method
    let value1: Int32 = 42
    let value2: Int32 = 42
    let value3: Int32 = -100
    
    // Compute hash values
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()
    
    println("Hash value of 42: ${hash1}")
    println("Hash value of 42: ${hash2}")
    println("Hash value of -100: ${hash3}")
    
    // Verify equal values have the same hash
    println("Do equal values have the same hash: ${hash1 == hash2}")
}
```

Output:

```text
Hash value of 42: 42
Hash value of 42: 42
Hash value of -100: -100
Do equal values have the same hash: true
```

### extend Int32 <: ToString

```cangjie
extend Int32 <: ToString
```

Function: Extends the [Int32](core_package_intrinsics.md#int32) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string).

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [Int32](core_package_intrinsics.md#int32) value to an output-ready string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int32.toString method
    let value1: Int32 = 42
    let value2: Int32 = -123
    let value3: Int32 = 0
    
    // Convert to strings
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()
    
    println("42 converted to string: \"${str1}\"")
    println("-123 converted to string: \"${str2}\"")
    println("0 converted to string: \"${str3}\"")
    
    // Verify type
    println("Is converted type String: ${str1 is String}")
}
```

Output:

```text
42 converted to string: "42"
-123 converted to string: "-123"
0 converted to string: "0"
Is converted type String: true
```

## Int64

Function: Represents a 64-bit signed integer with a range of [-2^{63}, 2^{63} - 1].

### extend Int64

```cangjie
extend Int64
```

Function: Extends the 64-bit signed integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: Int64
```

Function: Gets the maximum value of a 64-bit signed integer.

Type: [Int64](./core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int64.Max property
    let maxValue = Int64.Max
    println("Int64.Max value: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Int64.Max equal to 9223372036854775807: ${maxValue == 9223372036854775807}")
}
```

Output:

```text
Int64.Max value: 9223372036854775807
Is Int64.Max equal to 9223372036854775807: true
```

#### static prop Min

```cangjie
public static prop Min: Int64
```

Function: Gets the minimum value of a 64-bit signed integer.

Type: [Int64](./core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int64.Min property
    let minValue = Int64.Min
    println("Int64.Min value: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Int64.Min equal to -9223372036854775808: ${minValue == -9223372036854775808}")
}
```

Output:

```text
Int64.Min value: -9223372036854775808
Is Int64.Min equal to -9223372036854775808: true
```

### extend Int64 <: Comparable\<Int64>

```cangjie
extend Int64 <: Comparable<Int64>
```

Function: Extends the [Int64](core_package_intrinsics.md#int64) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int64](core_package_intrinsics.md#int64)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int64](#int64)>

#### func compare(Int64)

```cangjie
public func compare(rhs: Int64): Ordering
```

Function: Determines the relationship between the current [Int64](core_package_intrinsics.md#int64) value and the specified [Int64](core_package_intrinsics.md#int64) value.

Parameters:

- rhs: [Int64](core_package_intrinsics.md#int64) - Another [Int64](core_package_intrinsics.md#int64) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater; [Ordering](core_package_enums.md#enum-ordering).EQ if equal; [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int64 = 2
    var num2: Int64 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Int64 <: Countable\<Int64>

```cangjie
extend Int64 <: Countable<Int64>
```

Function: Extends the [Int64](core_package_intrinsics.md#int64) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[Int64](core_package_intrinsics.md#int64)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int64](#int64)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int64
```

Function: Gets the [Int64](core_package_intrinsics.md#int32) value at the position `right` units to the right on the number axis from the current [Int64](core_package_intrinsics.md#int32) position. If overflow occurs, it continues from the leftmost position of the number axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to count to the right.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The [Int64](core_package_intrinsics.md#int64) value at the position after counting `right` units to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int64 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [Int64](core_package_intrinsics.md#int64) value, i.e., returns the [Int64](core_package_intrinsics.md#int64) value itself.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [Int64](core_package_intrinsics.md#int64) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int64 = 3
    println(num.position())
}
```

Output:

```text
3
```

### extend Int64 <: Hashable

```cangjie
extend Int64 <: Hashable
```

Function: Extends the [Int64](core_package_intrinsics.md#int64) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int64.hashCode() method
    let num: Int64 = 42
    let hash = num.hashCode()
    println("Int64 value: ${num}")
    println("hashCode: ${hash}")
    
    // Test hash codes for different values
    let negativeNum: Int64 = -42
    let negativeHash = negativeNum.hashCode()
    println("Int64 value: ${negativeNum}")
    println("hashCode: ${negativeHash}")
    
    // Test zero value
    let zero: Int64 = 0
    let zeroHash = zero.hashCode()
    println("Int64 value: ${zero}")
    println("hashCode: ${zeroHash}")
}
```

Output:

```text
Int64 value: 42
hashCode: 42
Int64 value: -42
hashCode: -42
Int64 value: 0
hashCode: 0
```

### extend Int64 <: ToString

```cangjie
extend Int64 <: ToString
```

Function: Extends the [Int64](core_package_intrinsics.md#int64) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [Int64](core_package_intrinsics.md#int64) value to an output string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int64.toString() method
    let num: Int64 = 42
    let str = num.toString()
    println("Int64 value: ${num}")
    println("Converted string: ${str}")
    
    // Test negative number
    let negativeNum: Int64 = -42
    let negativeStr = negativeNum.toString()
    println("Int64 value: ${negativeNum}")
    println("Converted string: ${negativeStr}")
    
    // Test zero value
    let zero: Int64 = 0
    let zeroStr = zero.toString()
    println("Int64 value: ${zero}")
    println("Converted string: ${zeroStr}")
    
    // Test maximum and minimum values
    let maxVal = Int64.Max
    let maxStr = maxVal.toString()
    println("Int64 maximum value: ${maxVal}")
    println("Converted string: ${maxStr}")
    
    let minVal = Int64.Min
    let minStr = minVal.toString()
    println("Int64 minimum value: ${minVal}")
    println("Converted string: ${minStr}")
}
```

Output:

```text
Int64 value: 42
Converted string: 42
Int64 value: -42
Converted string: -42
Int64 value: 0
Converted string: 0
Int64 maximum value: 9223372036854775807
Converted string: 9223372036854775807
Int64 minimum value: -9223372036854775808
Converted string: -9223372036854775808
```

## Int8

Function: Represents an 8-bit signed integer with a range of [-2^7, 2^7 - 1].

### extend Int8

```cangjie
extend Int8
```

Function: Extends the 8-bit signed integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: Int8
```

Function: Gets the maximum value of an 8-bit signed integer.

Type: [Int8](./core_package_intrinsics.md#int8)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int8.Max property
    let maxValue = Int8.Max
    println("Int8.Max value: ${maxValue}")
    
    // Verify it is indeed the maximum value
    println("Is Int8.Max equal to 127: ${maxValue == 127}")
}
```

Output:

```text
Int8.Max value: 127
Is Int8.Max equal to 127: true
```

#### static prop Min

```cangjie
public static prop Min: Int8
```

Function: Gets the minimum value of an 8-bit signed integer.

Type: [Int8](./core_package_intrinsics.md#int8)

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int8.Min property
    let minValue = Int8.Min
    println("Int8.Min value: ${minValue}")
    
    // Verify it is indeed the minimum value
    println("Is Int8.Min equal to -128: ${minValue == -128}")
}
```

Output:

```text
Int8.Min value: -128
Is Int8.Min equal to -128: true
```

### extend Int8 <: Comparable\<Int8>

```cangjie
extend Int8 <: Comparable<Int8>
```

Function: Extends the [Int8](core_package_intrinsics.md#int8) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int8](core_package_intrinsics.md#int8)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int8](#int8)>

#### func compare(Int8)

```cangjie
public func compare(rhs: Int8): Ordering
```

Function: Determines the relationship between the current [Int8](core_package_intrinsics.md#int8) value and the specified [Int8](core_package_intrinsics.md#int8) value.

Parameters:

- rhs: [Int8](core_package_intrinsics.md#int8) - Another [Int8](core_package_intrinsics.md#int8) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater; [Ordering](core_package_enums.md#enum-ordering).EQ if equal; [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int8 = 2
    var num2: Int8 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend Int8 <: Countable\<Int8>

```cangjie
extend Int8 <: Countable<Int8>
```

Function: Extends the [Int8](core_package_intrinsics.md#int8) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[Int8](core_package_intrinsics.md#int8)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int8](#int8)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int8
```

Function: Gets the [Int8](core_package_intrinsics.md#int32) value at the position `right` units to the right on the number axis from the current [Int8](core_package_intrinsics.md#int32) position. If overflow occurs, it continues from the leftmost position of the number axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to count to the right.

Returns:

- [Int8](core_package_intrinsics.md#int8) - The [Int8](core_package_intrinsics.md#int8) value at the position after counting `right` units to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int8 = 3
    println(num.next(5))
}
```

Output:

```text
8
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [Int8](core_package_intrinsics.md#int8) value, i.e., converts the [Int8](core_package_intrinsics.md#int8) value to [Int64](core_package_intrinsics.md#int64).

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [Int8](core_package_intrinsics.md#int8) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: Int8 = 3
    println(num.position())
}
```

Output:

```text
3
```

### extend Int8 <: Hashable

```cangjie
extend Int8 <: Hashable
```

Function: Extends the [Int8](core_package_intrinsics.md#int8) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int8.hashCode() method
    let num: Int8 = 42
    let hash = num.hashCode()
    println("Int8 value: ${num}")
    println("hashCode: ${hash}")
    
    // Test hash codes for different values
    let negativeNum: Int8 = -42
    let negativeHash = negativeNum.hashCode()
    println("Int8 value: ${negativeNum}")
    println("hashCode: ${negativeHash}")
    
    // Test zero value
    let zero: Int8 = 0
    let zeroHash = zero.hashCode()
    println("Int8 value: ${zero}")
    println("hashCode: ${zeroHash}")
    
    // Test maximum and minimum values
    let maxVal = Int8.Max
    let maxHash = maxVal.hashCode()
    println("Int8 maximum value: ${maxVal}")
    println("hashCode: ${maxHash}")
    
    let minVal = Int8.Min
    let minHash = minVal.hashCode()
    println("Int8 minimum value: ${minVal}")
    println("hashCode: ${minHash}")
}
```

Output:

```text
Int8 value: 42
hashCode: 42
Int8 value: -42
hashCode: -42
Int8 value: 0
hashCode: 0
Int8 maximum value: 127
hashCode: 127
Int8 minimum value: -128
hashCode: -128
```

### extend Int8 <: ToString

```cangjie
extend Int8 <: ToString
```

Function: Extends the [Int8](core_package_intrinsics.md#int8) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [Int8](core_package_intrinsics.md#int8) value to an output string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Int8.toString() method
    let num: Int8 = 42
    let str = num.toString()
    println("Int8 value: ${num}")
    println("Converted string: ${str}")
    
    // Test negative number
    let negativeNum: Int8 = -42
    let negativeStr = negativeNum.toString()
    println("Int8 value: ${negativeNum}")
    println("Converted string: ${negativeStr}")
    
    // Test zero value
    let zero: Int8 = 0
    let zeroStr = zero.toString()
    println("Int8 value: ${zero}")
    println("Converted to string: ${zeroStr}")
    
    // Testing maximum and minimum values
    let maxVal = Int8.Max
    let maxStr = maxVal.toString()
    println("Int8 maximum value: ${maxVal}")
    println("Converted to string: ${maxStr}")
    
    let minVal = Int8.Min
    let minStr = minVal.toString()
    println("Int8 minimum value: ${minVal}")
    println("Converted to string: ${minStr}")
}
```

Execution results:

```text
Int8 value: 42
Converted to string: 42
Int8 value: -42
Converted to string: -42
Int8 value: 0
Converted to string: 0
Int8 maximum value: 127
Converted to string: 127
Int8 minimum value: -128
Converted to string: -128
```

## IntNative

Function: Represents a platform-dependent signed integer type whose length matches the bit width of the current system.

### extend IntNative

```cangjie
extend IntNative
```

Function: Extends the platform-dependent signed integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: IntNative
```

Function: Gets the maximum value of the platform-dependent signed integer.

Type: [IntNative](./core_package_intrinsics.md#intnative)

Example:

<!-- verify -->
```cangjie
main() {
    // Test the IntNative.Max property
    let maxValue = IntNative.Max
    println("Value of IntNative.Max: ${maxValue}")
    
    // Verify it is indeed the maximum value (should be 9223372036854775807 on 64-bit systems)
    println("Is IntNative.Max equal to 9223372036854775807: ${maxValue == 9223372036854775807}")
}
```

Output:

```text
Value of IntNative.Max: 9223372036854775807
Is IntNative.Max equal to 9223372036854775807: true
```

#### static prop Min

```cangjie
public static prop Min: IntNative
```

Function: Gets the minimum value of the platform-dependent signed integer.

Type: [IntNative](./core_package_intrinsics.md#intnative)

Example:

<!-- verify -->
```cangjie
main() {
    // Test the IntNative.Min property
    let minValue = IntNative.Min
    println("Value of IntNative.Min: ${minValue}")
    
    // Verify it is indeed the minimum value (should be -9223372036854775808 on 64-bit systems)
    println("Is IntNative.Min equal to -9223372036854775808: ${minValue == -9223372036854775808}")
}
```

Output:

```text
Value of IntNative.Min: -9223372036854775808
Is IntNative.Min equal to -9223372036854775808: true
```

### extend IntNative <: Comparable\<IntNative>

```cangjie
extend IntNative <: Comparable<IntNative>
```

Function: Extends the [IntNative](core_package_intrinsics.md#intnative) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[IntNative](core_package_intrinsics.md#intnative)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[IntNative](#intnative)>

#### func compare(IntNative)

```cangjie
public func compare(rhs: IntNative): Ordering
```

Function: Determines the size relationship between the current [IntNative](core_package_intrinsics.md#intnative) value and the specified [IntNative](core_package_intrinsics.md#intnative) value.

Parameters:

- rhs: [IntNative](core_package_intrinsics.md#intnative) - Another [IntNative](core_package_intrinsics.md#intnative) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: IntNative = 8
    var num2: IntNative = 10
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend IntNative <: Countable\<IntNative>

```cangjie
extend IntNative <: Countable<IntNative>
```

Function: Extends the [IntNative](core_package_intrinsics.md#intnative) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[IntNative](core_package_intrinsics.md#intnative)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[IntNative](#intnative)>

#### func next(Int64)

```cangjie
public func next(right: Int64): IntNative
```

Function: Gets the [IntNative](core_package_intrinsics.md#int32) value at the position `right` units to the right of the current [IntNative](core_package_intrinsics.md#int32) value on the number line. If overflow occurs, counting continues from the leftmost position of the number line.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to count to the right.

Returns:

- [IntNative](core_package_intrinsics.md#intnative) - The [IntNative](core_package_intrinsics.md#intnative) value at the position `right` units to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: IntNative = 8
    println(num.next(4))
}
```

Output:

```text
12
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [IntNative](core_package_intrinsics.md#intnative) value, i.e., converts the [IntNative](core_package_intrinsics.md#intnative) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [IntNative](core_package_intrinsics.md#intnative) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: IntNative = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend IntNative <: Hashable

```cangjie
extend IntNative <: Hashable
```

Function: Extends the [IntNative](core_package_intrinsics.md#intnative) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test the IntNative.hashCode() method
    let num: IntNative = 42
    let hash = num.hashCode()
    println("IntNative value: ${num}")
    println("hashCode: ${hash}")
    
    // Test hash codes for different values
    let negativeNum: IntNative = -42
    let negativeHash = negativeNum.hashCode()
    println("IntNative value: ${negativeNum}")
    println("hashCode: ${negativeHash}")
    
    // Test zero value
    let zero: IntNative = 0
    let zeroHash = zero.hashCode()
    println("IntNative value: ${zero}")
    println("hashCode: ${zeroHash}")
    
    // Test maximum and minimum values
    let maxVal = IntNative.Max
    let maxHash = maxVal.hashCode()
    println("IntNative maximum value: ${maxVal}")
    println("hashCode: ${maxHash}")
    
    let minVal = IntNative.Min
    let minHash = minVal.hashCode()
    println("IntNative minimum value: ${minVal}")
    println("hashCode: ${minHash}")
}
```

Output:

```text
IntNative value: 42
hashCode: 42
IntNative value: -42
hashCode: -42
IntNative value: 0
hashCode: 0
IntNative maximum value: 9223372036854775807
hashCode: 9223372036854775807
IntNative minimum value: -9223372036854775808
hashCode: -9223372036854775808
```

### extend IntNative <: ToString

```cangjie
extend IntNative <: ToString
```

Function: Extends the [IntNative](core_package_intrinsics.md#intnative) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [IntNative](core_package_intrinsics.md#intnative) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test the IntNative.toString() method
    let num: IntNative = 42
    let str = num.toString()
    println("IntNative value: ${num}")
    println("Converted string: ${str}")
    
    // Test negative numbers
    let negativeNum: IntNative = -42
    let negativeStr = negativeNum.toString()
    println("IntNative value: ${negativeNum}")
    println("Converted string: ${negativeStr}")
    
    // Test zero value
    let zero: IntNative = 0
    let zeroStr = zero.toString()
    println("IntNative value: ${zero}")
    println("Converted string: ${zeroStr}")
    
    // Test maximum and minimum values
    let maxVal = IntNative.Max
    let maxStr = maxVal.toString()
    println("IntNative maximum value: ${maxVal}")
    println("Converted string: ${maxStr}")
    
    let minVal = IntNative.Min
    let minStr = minVal.toString()
    println("IntNative minimum value: ${minVal}")
    println("Converted string: ${minStr}")
}
```

Output:

```text
IntNative value: 42
Converted string: 42
IntNative value: -42
Converted string: -42
IntNative value: 0
Converted string: 0
IntNative maximum value: 9223372036854775807
Converted string: 9223372036854775807
IntNative minimum value: -9223372036854775808
Converted string: -9223372036854775808
```

## Rune

Function: Represents a character in the Unicode character set.

The range is `Unicode scalar value`, i.e., characters from `\u{0000}` to `\u{D7FF}`, and from `\u{E000}` to `\u{10FFF}`.

### extend Rune

```cangjie
extend Rune
```

Function: Implements a series of extension methods for the [Rune](core_package_intrinsics.md#rune) type, primarily for character judgment and conversion within the ASCII character set.

#### static func fromUtf8(Array\<UInt8>, Int64)

```cangjie
public static func fromUtf8(arr: Array<UInt8>, index: Int64): (Rune, Int64)
```

Function: Converts the specified element in a byte array to a character according to UTF-8 encoding rules and returns the byte length occupied by the character.

Parameters:

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array containing the bytes to convert.
- index: [Int64](core_package_intrinsics.md#int64) - The index of the byte to convert in the array.

Returns:

- ([Rune](core_package_intrinsics.md#rune), [Int64](core_package_intrinsics.md#int64)) - The converted character and the byte length occupied by the character.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Invalid UTF-8 byte sequence.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [4, 8, 65] // A <=> 65
    var tuple = Rune.fromUtf8(arr, 2)
    println(tuple[0]) // Rune
    println(tuple[1]) // len
}
```

Output:

```text
A
1
```

#### static func getPreviousFromUtf8(Array\<UInt8>, Int64)

```cangjie
public static func getPreviousFromUtf8(arr: Array<UInt8>, index: Int64): (Rune, Int64)
```

Function: Gets the UTF-8 encoded character that the byte at position `index - 1` (i.e., `arr[index - 1]`) belongs to, along with the byte length of the character.

Starting from `arr[index - 1]`, the function checks whether that byte is the leading byte of a UTF-8 character. If not, it continues searching backward until the leading byte is found, then decodes the byte sequence into the corresponding character. The valid range for `index` is `[1, arr.size]`.

Parameters:

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array to search for the character.
- index: [Int64](core_package_intrinsics.md#int64) - The index in the byte array; the function finds the character that `arr[index - 1]` belongs to. Valid range: `[1, arr.size]`.

Returns:

- ([Rune](core_package_intrinsics.md#rune), [Int64](core_package_intrinsics.md#int64)) - The found character and the byte length of the character.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - If `index` is less than or equal to 0, there is no preceding byte and an exception is thrown; if the leading byte cannot be found, i.e., the byte at `arr[index - 1]` does not conform to UTF-8 encoding, an exception is thrown.
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - If `index` is greater than `arr.size`, an exception is thrown.

Example:

<!-- verify -->
```cangjie
main() {
    // Test the Rune.getPreviousFromUtf8 method
    // Create a byte array containing a Chinese character
    var arr: Array<UInt8> = [72, 101, 108, 108, 111, 231, 136, 177] // UTF-8 encoding for "Hello爱"
    println("Byte array: ${arr}")
    
    // Get the character corresponding to index 7 (the second byte of the Chinese character "爱")
    var tuple = Rune.getPreviousFromUtf8(arr, 7)
    println("Found character: ${tuple[0]}")
    println("Byte length of character: ${tuple[1]}")
}
```

Output:

```text
Byte array: [72, 101, 108, 108, 111, 231, 136, 177]
Found character: 爱
Byte length of character: 3
```

#### static func intoUtf8Array(Rune, Array\<UInt8>, Int64)

```cangjie
public static func intoUtf8Array(c: Rune, arr: Array<UInt8>, index: Int64): Int64
```

Function: Converts a character to a byte sequence and overwrites the bytes in the specified position of the [Array](core_package_structs.md#struct-arrayt) array.

Parameters:

- c: [Rune](core_package_intrinsics.md#rune) - The character to convert.
- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The [Array](core_package_structs.md#struct-arrayt) array to overwrite.
- index: [Int64](core_package_intrinsics.md#int64) - The starting index of the target position.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The byte length of the character, e.g., 3 for Chinese characters.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [1, 2, 3, 230, 136, 145]
    var len: Int64 = Rune.intoUtf8Array(r'爱', arr, 2)
    println(len)
    println(arr[2]) // First byte of the UTF-8 encoding for "爱"
}
```

Output:

```text
3
231
```

#### static func utf8Size(Array\<UInt8>, Int64)

```cangjie
public static func utf8Size(arr: Array<UInt8>, index: Int64): Int64
```

Function: Returns the number of bytes occupied by the character starting at the specified index in the byte array.

In UTF-8 encoding, the leading byte of an ASCII character does not start with 1, while the leading byte of other characters starts with a number of 1s indicating the byte length of the character. This function determines the byte length by scanning the leading byte. If the index does not point to a leading byte, an exception is thrown.

Parameters:

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array to get the character from.
- index: [Int64](core_package_intrinsics.md#int64) - The index of the character.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The byte length of the character, e.g., 3 for Chinese characters.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - If the byte at the index does not conform to the leading byte rules.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [1, 2, 231, 136, 177, 145]
    var len: Int64 = Rune.utf8Size(arr, 2)
    println(len) // The array elements at indices 2-4 are the UTF-8 encoding for the Chinese character "爱", occupying 3 bytes
}
```

Output:

```text
3
```

#### static func utf8Size(Rune)

```cangjie
public static func utf8Size(c: Rune): Int64
```

Function: Returns the byte length of the UTF-8 encoding for the character, e.g., 3 for Chinese characters.

Parameters:

- `c`: [Rune](core_package_intrinsics.md#rune) - The character whose UTF-8 byte length is to be calculated.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The UTF-8 byte length of the character.

Example:

<!-- verify -->
```cangjie
main() {
    var char: Rune = r'爱'
    var len: Int64 = Rune.utf8Size(char)
    println(len) // The Chinese character '爱' occupies 3 bytes in UTF-8 encoding
}
```

Execution Result:

```text
3
```

#### func isAscii()

```cangjie
public func isAscii(): Bool
```

Function: Determines whether the character is an ASCII character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is ASCII, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAscii() method
    var asciiChar: Rune = r'A'  // ASCII character
    var nonAsciiChar: Rune = r'爱'  // Non-ASCII character
    
    println("Is character '${asciiChar}' ASCII? ${asciiChar.isAscii()}")
    println("Is character '${nonAsciiChar}' ASCII? ${nonAsciiChar.isAscii()}")
}
```

Execution Result:

```text
Is character 'A' ASCII? true
Is character '爱' ASCII? false
```

#### func isAsciiControl()

```cangjie
public func isAsciiControl(): Bool
```

Function: Determines whether the character is an ASCII control character. The valid range is the union of [00, 1F] and {7F}.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII control character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiControl() method
    var controlChar: Rune = r'\n'  // ASCII control character
    var nonControlChar: Rune = r'A'  // Non-control character
    
    println("Is character '${controlChar}' an ASCII control character? ${controlChar.isAsciiControl()}")
    println("Is character '${nonControlChar}' an ASCII control character? ${nonControlChar.isAsciiControl()}")
}
```

Execution Result:

```text
Is character '
' an ASCII control character? true
Is character 'A' an ASCII control character? false
```

#### func isAsciiGraphic()

```cangjie
public func isAsciiGraphic(): Bool
```

Function: Determines whether the character is an ASCII graphic character. The valid range is [21, 7E].

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII graphic character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiGraphic() method
    var graphicChar: Rune = r'A'  // ASCII graphic character
    var nonGraphicChar: Rune = r'\n'  // Non-graphic character (control character)
    
    println("Is character '${graphicChar}' an ASCII graphic character? ${graphicChar.isAsciiGraphic()}")
    println("Is character '${nonGraphicChar}' an ASCII graphic character? ${nonGraphicChar.isAsciiGraphic()}")
}
```

Execution Result:

```text
Is character 'A' an ASCII graphic character? true
Is character '
' an ASCII graphic character? false
```

#### func isAsciiHex()

```cangjie
public func isAsciiHex(): Bool
```

Function: Determines whether the character is an ASCII hexadecimal character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII hexadecimal character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiHex() method
    var hexChar: Rune = r'A'  // ASCII hexadecimal character
    var nonHexChar: Rune = r'G'  // Non-hexadecimal character
    
    println("Is character '${hexChar}' an ASCII hexadecimal character? ${hexChar.isAsciiHex()}")
    println("Is character '${nonHexChar}' an ASCII hexadecimal character? ${nonHexChar.isAsciiHex()}")
}
```

Execution Result:

```text
Is character 'A' an ASCII hexadecimal character? true
Is character 'G' an ASCII hexadecimal character? false
```

#### func isAsciiLetter()

```cangjie
public func isAsciiLetter(): Bool
```

Function: Determines whether the character is an ASCII alphabetic character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII alphabetic character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiLetter() method
    var letterChar: Rune = r'A'  // ASCII alphabetic character
    var nonLetterChar: Rune = r'1'  // Non-alphabetic character
    
    println("Is character '${letterChar}' an ASCII alphabetic character? ${letterChar.isAsciiLetter()}")
    println("Is character '${nonLetterChar}' an ASCII alphabetic character? ${nonLetterChar.isAsciiLetter()}")
}
```

Execution Result:

```text
Is character 'A' an ASCII alphabetic character? true
Is character '1' an ASCII alphabetic character? false
```

#### func isAsciiLowerCase()

```cangjie
public func isAsciiLowerCase(): Bool
```

Function: Determines whether the character is an ASCII lowercase character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII lowercase character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiLowerCase() method
    var lowerCaseChar: Rune = r'a'  // ASCII lowercase character
    var upperCaseChar: Rune = r'A'  // ASCII uppercase character
    
    println("Is character '${lowerCaseChar}' an ASCII lowercase character? ${lowerCaseChar.isAsciiLowerCase()}")
    println("Is character '${upperCaseChar}' an ASCII lowercase character? ${upperCaseChar.isAsciiLowerCase()}")
}
```

Execution Result:

```text
Is character 'a' an ASCII lowercase character? true
Is character 'A' an ASCII lowercase character? false
```

#### func isAsciiNumber()

```cangjie
public func isAsciiNumber(): Bool
```

Function: Determines whether the character is an ASCII numeric character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII numeric character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiNumber() method
    var numberChar: Rune = r'1'  // ASCII numeric character
    var nonNumberChar: Rune = r'A'  // Non-numeric character
    
    println("Is character '${numberChar}' an ASCII numeric character? ${numberChar.isAsciiNumber()}")
    println("Is character '${nonNumberChar}' an ASCII numeric character? ${nonNumberChar.isAsciiNumber()}")
}
```

Execution Result:

```text
Is character '1' an ASCII numeric character? true
Is character 'A' an ASCII numeric character? false
```

#### func isAsciiNumberOrLetter()

```cangjie
public func isAsciiNumberOrLetter(): Bool
```

Function: Determines whether the character is an ASCII numeric or Latin alphabetic character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII numeric or Latin alphabetic character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiNumberOrLetter() method
    var numberChar: Rune = r'1'  // ASCII numeric character
    var letterChar: Rune = r'A'  // ASCII alphabetic character
    var specialChar: Rune = r'!'  // Special character
    
    println("Is character '${numberChar}' an ASCII numeric or alphabetic character? ${numberChar.isAsciiNumberOrLetter()}")
    println("Is character '${letterChar}' an ASCII numeric or alphabetic character? ${letterChar.isAsciiNumberOrLetter()}")
    println("Is character '${specialChar}' an ASCII numeric or alphabetic character? ${specialChar.isAsciiNumberOrLetter()}")
}
```

Execution Result:

```text
Is character '1' an ASCII numeric or alphabetic character? true
Is character 'A' an ASCII numeric or alphabetic character? true
Is character '!' an ASCII numeric or alphabetic character? false
```

#### func isAsciiOct()

```cangjie
public func isAsciiOct(): Bool
```

Function: Determines whether the character is an ASCII octal character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII octal character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiOct() method
    var octChar: Rune = r'7'  // ASCII octal character
    var nonOctChar: Rune = r'8'  // Non-octal character
    
    println("Is character '${octChar}' an ASCII octal character? ${octChar.isAsciiOct()}")
    println("Is character '${nonOctChar}' an ASCII octal character? ${nonOctChar.isAsciiOct()}")
}
```

Execution Result:

```text
Is character '7' an ASCII octal character? true
Is character '8' an ASCII octal character? false
```

#### func isAsciiPunctuation()

```cangjie
public func isAsciiPunctuation(): Bool
```

Function: Determines whether the character is an ASCII punctuation character. The valid range is the union of [21, 2F], [3A, 40], [5B, 60], and [7B, 7E].

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII punctuation character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiPunctuation() method
    var punctuationChar: Rune = r'!'  // ASCII punctuation character
    var nonPunctuationChar: Rune = r'A'  // Non-punctuation character
    
    println("Is character '${punctuationChar}' an ASCII punctuation character? ${punctuationChar.isAsciiPunctuation()}")
    println("Is character '${nonPunctuationChar}' an ASCII punctuation character? ${nonPunctuationChar.isAsciiPunctuation()}")
}
```

Execution Result:

```text
Is character '!' an ASCII punctuation character? true
Is character 'A' an ASCII punctuation character? false
```

#### func isAsciiUpperCase()

```cangjie
public func isAsciiUpperCase(): Bool
```

Function: Determines whether the character is an ASCII uppercase character.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII uppercase character, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiUpperCase() method
    var upperCaseChar: Rune = r'A'  // ASCII uppercase character
    var lowerCaseChar: Rune = r'a'  // ASCII lowercase character
    
    println("Is character '${upperCaseChar}' an ASCII uppercase character? ${upperCaseChar.isAsciiUpperCase()}")
    println("Is character '${lowerCaseChar}' an ASCII uppercase character? ${lowerCaseChar.isAsciiUpperCase()}")
}
```

Execution Result:

```text
Is character 'A' an ASCII uppercase character? true
Is character 'a' an ASCII uppercase character? false
```

#### func isAsciiWhiteSpace()

```cangjie
public func isAsciiWhiteSpace(): Bool
```

Function: Determines whether the character is an ASCII whitespace character. The valid range is the union of [09, 0D] and {20}.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the character is an ASCII whitespace character, otherwise `false`.Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if it's an ASCII whitespace character, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.isAsciiWhiteSpace() method
    var whiteSpaceChar: Rune = r' '  // ASCII whitespace character
    var nonWhiteSpaceChar: Rune = r'A'  // Non-whitespace character
    
    println("Is character '${whiteSpaceChar}' an ASCII whitespace? ${whiteSpaceChar.isAsciiWhiteSpace()}")
    println("Is character '${nonWhiteSpaceChar}' an ASCII whitespace? ${nonWhiteSpaceChar.isAsciiWhiteSpace()}")
}
```

Execution Result:

```text
Is character ' ' an ASCII whitespace? true
Is character 'A' an ASCII whitespace? false
```

#### func toAsciiLowerCase()

```cangjie
public func toAsciiLowerCase(): Rune
```

Function: Converts the character to ASCII lowercase. If conversion is not possible, returns the original character unchanged.

Returns:

- [Rune](core_package_intrinsics.md#rune) - The converted character, or the original [Rune](core_package_intrinsics.md#rune) if conversion is not possible.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.toAsciiLowerCase() method
    var upperCaseChar: Rune = r'A'  // ASCII uppercase character
    var lowerCaseChar: Rune = r'a'  // ASCII lowercase character
    var nonLetterChar: Rune = r'1'  // Non-letter character
    
    var convertedUpper = upperCaseChar.toAsciiLowerCase()
    var convertedLower = lowerCaseChar.toAsciiLowerCase()
    var convertedNonLetter = nonLetterChar.toAsciiLowerCase()
    
    println("Uppercase '${upperCaseChar}' converted to lowercase: ${convertedUpper}")
    println("Lowercase '${lowerCaseChar}' converted to lowercase: ${convertedLower}")
    println("Non-letter '${nonLetterChar}' converted to lowercase: ${convertedNonLetter}")
}
```

Execution Result:

```text
Uppercase 'A' converted to lowercase: a
Lowercase 'a' converted to lowercase: a
Non-letter '1' converted to lowercase: 1
```

#### func toAsciiUpperCase()

```cangjie
public func toAsciiUpperCase(): Rune
```

Function: Converts the character to ASCII uppercase. If conversion is not possible, returns the original character unchanged.

Returns:

- [Rune](core_package_intrinsics.md#rune) - The converted character, or the original [Rune](core_package_intrinsics.md#rune) if conversion is not possible.

Example:

<!-- verify -->
```cangjie
main() {
    // Testing Rune.toAsciiUpperCase() method
    var lowerCaseChar: Rune = r'a'  // ASCII lowercase character
    var upperCaseChar: Rune = r'A'  // ASCII uppercase character
    var nonLetterChar: Rune = r'1'  // Non-letter character
    
    var convertedLower = lowerCaseChar.toAsciiUpperCase()
    var convertedUpper = upperCaseChar.toAsciiUpperCase()
    var convertedNonLetter = nonLetterChar.toAsciiUpperCase()
    
    println("Lowercase '${lowerCaseChar}' converted to uppercase: ${convertedLower}")
    println("Uppercase '${upperCaseChar}' converted to uppercase: ${convertedUpper}")
    println("Non-letter '${nonLetterChar}' converted to uppercase: ${convertedNonLetter}")
}
```

Execution Result:

```text
Lowercase 'a' converted to uppercase: A
Uppercase 'A' converted to uppercase: A
Non-letter '1' converted to uppercase: 1
```

### extend Rune <: Comparable\<Rune>

```cangjie
extend Rune <: Comparable<Rune>
```

Function: Extends the [Rune](core_package_intrinsics.md#rune) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[Rune](core_package_intrinsics.md#rune)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Rune](#rune)>

#### func compare(Rune)

```cangjie
public func compare(rhs: Rune): Ordering
```

Function: Determines the size relationship between the current [Rune](core_package_intrinsics.md#rune) instance and the specified [Rune](core_package_intrinsics.md#rune) instance.

The size relationship of [Rune](core_package_intrinsics.md#rune) refers to the comparison of their corresponding Unicode code points.

Parameters:

- rhs: [Rune](core_package_intrinsics.md#rune) - Another [Rune](core_package_intrinsics.md#rune) instance to compare with.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var char1: Rune = r'i'
    var char2: Rune = r'j'
    println(char1.compare(char2))
}
```

Output:

```text
Ordering.LT
```

### extend Rune <: Countable\<Rune>

```cangjie
extend Rune <: Countable<Rune>
```

Function: Extends the [Rune](core_package_intrinsics.md#rune) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[Rune](core_package_intrinsics.md#rune)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[Rune](#rune)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Rune
```

Function: Gets the [Rune](core_package_intrinsics.md#rune) value `right` positions to the right of the current [Rune](core_package_intrinsics.md#rune) value.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of positions to move right.

Returns:

- [Rune](core_package_intrinsics.md#rune) - The [Rune](core_package_intrinsics.md#rune) value `right` positions to the right.

Exceptions:

- [OverflowException](core_package_exceptions.md#class-overflowexception) - Thrown if the result of the addition with [Int64](core_package_intrinsics.md#int64) is an invalid Unicode value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Rune.next method
    var char: Rune = r'A'
    var nextChar = char.next(1)
    println("Character: ${char}")
    println("Next character: ${nextChar}")
    
    // Test moving backward
    var prevChar = char.next(-1)
    println("Previous character: ${prevChar}")
}
```

Output:

```text
Character: A
Next character: B
Previous character: @
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [Rune](core_package_intrinsics.md#rune) value, i.e., converts the [Rune](core_package_intrinsics.md#rune) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [Rune](core_package_intrinsics.md#rune) value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Rune.position method
    var char: Rune = r'A'
    var position = char.position()
    println("Character: ${char}")
    println("Unicode code point position: ${position}")
    
    // Test Chinese character
    var chineseChar: Rune = r'爱'
    var chinesePosition = chineseChar.position()
    println("Character: ${chineseChar}")
    println("Unicode code point position: ${chinesePosition}")
}
```

Output:

```text
Character: A
Unicode code point position: 65
Character: 爱
Unicode code point position: 29233
```

### extend Rune <: Hashable

```cangjie
extend Rune <: Hashable
```

Function: Extends the [Rune](core_package_intrinsics.md#rune) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Rune.hashCode method
    var char: Rune = r'A'
    var hash = char.hashCode()
    println("Character: ${char}")
    println("Hash value: ${hash}")
    
    // Test Chinese character
    var chineseChar: Rune = r'爱'
    var chineseHash = chineseChar.hashCode()
    println("Character: ${chineseChar}")
    println("Hash value: ${chineseHash}")
}
```

Output:

```text
Character: A
Hash value: 65
Character: 爱
Hash value: 29233
```

### extend Rune <: ToString

```cangjie
extend Rune <: ToString
```

Function: Extends the [Rune](core_package_intrinsics.md#rune) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string).

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [Rune](core_package_intrinsics.md#rune) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test Rune.toString method
    var char: Rune = r'A'
    var str = char.toString()
    println("Character: ${char}")
    println("Converted string: ${str}")
    
    // Test Chinese character
    var chineseChar: Rune = r'爱'
    var chineseStr = chineseChar.toString()
    println("Character: ${chineseChar}")
    println("Converted string: ${chineseStr}")
}
```

Output:

```text
Character: A
Converted string: A
Character: 爱
Converted string: 爱
```

## UInt16

Function: Represents a 16-bit unsigned integer with a range of [0, 2^{16} - 1].

### extend UInt16

```cangjie
extend UInt16
```

Function: Extends the 16-bit unsigned integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: UInt16
```

Function: Gets the maximum value of a 16-bit unsigned integer.

Type: [UInt16](./core_package_intrinsics.md#uint16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test UInt16.Max property
    var maxVal = UInt16.Max
    println("Maximum value of UInt16: ${maxVal}")
    
    // Verify the maximum value
    if (maxVal == 65535) {
        println("Verification passed: UInt16.Max equals 65535")
    } else {
        println("Verification failed: UInt16.Max does not equal 65535")
    }
}
```

Output:

```text
Maximum value of UInt16: 65535
Verification passed: UInt16.Max equals 65535
```

#### static prop Min

```cangjie
public static prop Min: UInt16
```

Function: Gets the minimum value of a 16-bit unsigned integer.

Type: [UInt16](./core_package_intrinsics.md#uint16)

Example:

<!-- verify -->
```cangjie
main() {
    // Test UInt16.Min property
    var minVal = UInt16.Min
    println("Minimum value of UInt16: ${minVal}")
    
    // Verify the minimum value
    if (minVal == 0) {
        println("Verification passed: UInt16.Min equals 0")
    } else {
        println("Verification failed: UInt16.Min does not equal 0")
    }
}
```

Output:

```text
Minimum value of UInt16: 0
Verification passed: UInt16.Min equals 0
```

### extend UInt16 <: Comparable\<UInt16>

```cangjie
extend UInt16 <: Comparable<UInt16>
```

Function: Extends the [UInt16](core_package_intrinsics.md#uint16) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt16](core_package_intrinsics.md#uint16)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt16](#uint16)>

#### func compare(UInt16)

```cangjie
public func compare(rhs: UInt16): Ordering
```

Function: Determines the size relationship between the current [UInt16](core_package_intrinsics.md#uint16) value and the specified [UInt16](core_package_intrinsics.md#uint16) value.

Parameters:

- rhs: [UInt16](core_package_intrinsics.md#uint16) - Another [UInt16](core_package_intrinsics.md#uint16) value to compare with.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt16 = 2
    var num2: UInt16 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend UInt16 <: Countable\<UInt16>

```cangjie
extend UInt16 <: Countable<UInt16>
```

Function: Extends the [UInt16](core_package_intrinsics.md#uint16) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[UInt16](core_package_intrinsics.md#uint16)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt16](#uint16)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt16
```

Function: Gets the [UInt16](core_package_intrinsics.md#int32) value `right` positions to the right of the current [UInt16](core_package_intrinsics.md#int32) value on the number line. If the value overflows, it wraps around from the leftmost position.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of positions to move right.

Returns:

- [UInt16](core_package_intrinsics.md#uint16) - The [UInt16](core_package_intrinsics.md#uint16) value `right` positions to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt16 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [UInt16](core_package_intrinsics.md#uint16) value, i.e., converts the [UInt16](core_package_intrinsics.md#uint16) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [UInt16](core_package_intrinsics.md#uint16) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt16 = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend UInt16 <: Hashable

```cangjie
extend UInt16 <: Hashable
```

Function: Extends the [UInt16](core_package_intrinsics.md#uint16) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Test UInt16.hashCode method
    var num: UInt16 = 42
    var hash = num.hashCode()
    println("UInt16 value: ${num}")
    println("Hash value: ${hash}")
    
    // Test maximum value
    var maxNum: UInt16 = UInt16.Max
    var maxHash = maxNum.hashCode()
    println("Maximum UInt16 value: ${maxNum}")
    println("Hash value: ${maxHash}")
}
```

Output:

```text
UInt16 value: 42
Hash value: 42
Maximum UInt16 value: 65535
Hash value: 65535
```

### extend UInt16 <: ToString

```cangjie
extend UInt16 <: ToString
```

Function: Extends the [UInt16](core_package_intrinsics.md#uint16) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string).

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [UInt16](core_package_intrinsics.md#uint16) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    // Test UInt16.toString method
    var num: UInt16 = 42
    var str = num.toString()
    println("UInt16 value: ${num}")
    println("Converted string: ${str}")
    
    // Test maximum value
    var maxNum: UInt16 = UInt16.Max
    var maxStr = maxNum.toString()
    println("Maximum UInt16 value: ${maxNum}")
    println("Converted string: ${maxStr}")
}
```

Output:

```text
UInt16 value: 42
Converted string: 42
Maximum UInt16 value: 65535
Converted string: 65535
```

## UInt32

Function: Represents a 32-bit unsigned integer with a range of [0, 2^32 - 1].

### extend UInt32

```cangjie
extend UInt32
```

Function: Extends 32-bit unsigned integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: UInt32
```

Function: Gets the maximum value of a 32-bit unsigned integer.

Type: [UInt32](./core_package_intrinsics.md#uint32)

Example:

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt32.Max
    println(maxValue)
}
```

Output:

```text
4294967295
```

#### static prop Min

```cangjie
public static prop Min: UInt32
```

Function: Gets the minimum value of a 32-bit unsigned integer.

Type: [UInt32](./core_package_intrinsics.md#uint32)

Example:

<!-- verify -->
```cangjie
main() {
    var minValue = UInt32.Min
    println(minValue)
}
```

Output:

```text
0
```

### extend UInt32 <: Comparable\<UInt32>

```cangjie
extend UInt32 <: Comparable<UInt32>
```

Function: Extends the [UInt32](core_package_intrinsics.md#uint32) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt32](core_package_intrinsics.md#uint32)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt32](#uint32)>

#### func compare(UInt32)

```cangjie
public func compare(rhs: UInt32): Ordering
```

Function: Determines the relationship between the current [UInt32](core_package_intrinsics.md#uint32) value and the specified [UInt32](core_package_intrinsics.md#uint32) value.

Parameters:

- rhs: [UInt32](core_package_intrinsics.md#uint32) - Another [UInt32](core_package_intrinsics.md#uint32) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt32 = 2
    var num2: UInt32 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend UInt32 <: Countable\<UInt32>

```cangjie
extend UInt32 <: Countable<UInt32>
```

Function: Extends the [UInt32](core_package_intrinsics.md#uint32) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[UInt32](core_package_intrinsics.md#uint32)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt32](#uint32)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt32
```

Function: Gets the [UInt32](core_package_intrinsics.md#uint32) value at the position `right` units to the right of the current [UInt32](core_package_intrinsics.md#uint32) position on the number line. If the value overflows, it continues moving from the leftmost position of the number line.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [UInt32](core_package_intrinsics.md#uint32) - The [UInt32](core_package_intrinsics.md#uint32) value at the new position after moving right by `right` units.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [UInt32](core_package_intrinsics.md#uint32) value, i.e., converts the [UInt32](core_package_intrinsics.md#uint32) to a [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [UInt32](core_package_intrinsics.md#uint32) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend UInt32 <: Hashable

```cangjie
extend UInt32 <: Hashable
```

Function: Extends the [UInt32](core_package_intrinsics.md#uint32) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 42
    var hash = num.hashCode()
    println(hash)
}
```

Output:

```text
42
```

### extend UInt32 <: ToString

```cangjie
extend UInt32 <: ToString
```

Function: Extends the [UInt32](core_package_intrinsics.md#uint32) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [UInt32](core_package_intrinsics.md#uint32) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 42
    var str = num.toString()
    println(str)
}
```

Output:

```text
42
```

## UInt64

Function: Represents a 64-bit unsigned integer with a range of [0, 2^64 - 1].

### extend UInt64

```cangjie
extend UInt64
```

Function: Extends 64-bit unsigned integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: UInt64
```

Function: Gets the maximum value of a 64-bit unsigned integer.

Type: [UInt64](./core_package_intrinsics.md#uint64)

Example:

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt64.Max
    println(maxValue)
}
```

Output:

```text
18446744073709551615
```

#### static prop Min

```cangjie
public static prop Min: UInt64
```

Function: Gets the minimum value of a 64-bit unsigned integer.

Type: [UInt64](./core_package_intrinsics.md#uint64)

Example:

<!-- verify -->
```cangjie
main() {
    var minValue = UInt64.Min
    println(minValue)
}
```

Output:

```text
0
```

### extend UInt64 <: Comparable\<UInt64>

```cangjie
extend UInt64 <: Comparable<UInt64>
```

Function: Extends the [UInt64](core_package_intrinsics.md#uint64) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt64](core_package_intrinsics.md#uint64)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt64](#uint64)>

#### func compare(UInt64)

```cangjie
public func compare(rhs: UInt64): Ordering
```

Function: Determines the relationship between the current [UInt64](core_package_intrinsics.md#uint64) value and the specified [UInt64](core_package_intrinsics.md#uint64) value.

Parameters:

- rhs: [UInt64](core_package_intrinsics.md#uint64) - Another [UInt64](core_package_intrinsics.md#uint64) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater, [Ordering](core_package_enums.md#enum-ordering).EQ if equal, and [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt64 = 2
    var num2: UInt64 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend UInt64 <: Countable\<UInt64>

```cangjie
extend UInt64 <: Countable<UInt64>
```

Function: Extends the [UInt64](core_package_intrinsics.md#uint64) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[UInt64](core_package_intrinsics.md#uint64)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt64](#uint64)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt64
```

Function: Gets the [UInt64](core_package_intrinsics.md#uint64) value at the position `right` units to the right of the current [UInt64](core_package_intrinsics.md#uint64) position on the number line. If the value overflows, it continues moving from the leftmost position of the number line.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [UInt64](core_package_intrinsics.md#uint64) - The [UInt64](core_package_intrinsics.md#uint64) value at the new position after moving right by `right` units.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [UInt64](core_package_intrinsics.md#uint64) value, i.e., converts the [UInt64](core_package_intrinsics.md#uint64) to a [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [UInt64](core_package_intrinsics.md#uint64) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend UInt64 <: Hashable

```cangjie
extend UInt64 <: Hashable
```

Function: Extends the [UInt64](core_package_intrinsics.md#uint64) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 42
    var hash = num.hashCode()
    println(hash)
}
```

Output:

```text
42
```

### extend UInt64 <: ToString

```cangjie
extend UInt64 <: ToString
```

Function: Extends the [UInt64](core_package_intrinsics.md#uint64) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [UInt64](core_package_intrinsics.md#uint64) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 42
    var str = num.toString()
    println(str)
}
```

Output:

```text
42
```

## UInt8

Function: Represents an 8-bit unsigned integer with a range of [0, 2^8 - 1].

### extend UInt8

```cangjie
extend UInt8
```

Function: Extends the 8-bit unsigned integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: UInt8
```

Function: Gets the maximum value of an 8-bit unsigned integer.

Type: [UInt8](./core_package_intrinsics.md#uint8)

Example:

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt8.Max
    println(maxValue)
}
```

Output:

```text
255
```

#### static prop Min

```cangjie
public static prop Min: UInt8
```

Function: Gets the minimum value of an 8-bit unsigned integer.

Type: [UInt8](./core_package_intrinsics.md#uint8)

Example:

<!-- verify -->
```cangjie
main() {
    var minValue = UInt8.Min
    println(minValue)
}
```

Output:

```text
0
```

### extend UInt8 <: Comparable\<UInt8>

```cangjie
extend UInt8 <: Comparable<UInt8>
```

Function: Extends the [UInt8](core_package_intrinsics.md#uint8) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt8](core_package_intrinsics.md#uint8)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt8](#uint8)>

#### func compare(UInt8)

```cangjie
public func compare(rhs: UInt8): Ordering
```

Function: Determines the size relationship between the current [UInt8](core_package_intrinsics.md#uint8) value and the specified [UInt8](core_package_intrinsics.md#uint8) value.

Parameters:

- rhs: [UInt8](core_package_intrinsics.md#uint8) - Another [UInt8](core_package_intrinsics.md#uint8) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater; [Ordering](core_package_enums.md#enum-ordering).EQ if equal; [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt8 = 2
    var num2: UInt8 = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend UInt8 <: Countable\<UInt8>

```cangjie
extend UInt8 <: Countable<UInt8>
```

Function: Extends the [UInt8](core_package_intrinsics.md#uint8) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[UInt8](core_package_intrinsics.md#uint8)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt8](#uint8)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt8
```

Function: Gets the [UInt8](core_package_intrinsics.md#uint8) value at the position `right` units to the right of the current [UInt8](core_package_intrinsics.md#int32) position on the number axis. If the value overflows, it continues moving from the leftmost position of the axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [UInt8](core_package_intrinsics.md#uint8) - The [UInt8](core_package_intrinsics.md#uint8) value at the position after moving `right` units to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [UInt8](core_package_intrinsics.md#uint8) value, i.e., converts the [UInt8](core_package_intrinsics.md#uint8) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [UInt8](core_package_intrinsics.md#uint8) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend UInt8 <: Hashable

```cangjie
extend UInt8 <: Hashable
```

Function: Extends the [UInt8](core_package_intrinsics.md#uint8) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 42
    var hash = num.hashCode()
    println(hash)
}
```

Output:

```text
42
```

### extend UInt8 <: ToString

```cangjie
extend UInt8 <: ToString
```

Function: Extends the [UInt8](core_package_intrinsics.md#uint8) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to the [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [UInt8](core_package_intrinsics.md#uint8) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 42
    var str = num.toString()
    println(str)
}
```

Output:

```text
42
```

## UIntNative

Function: Represents a platform-dependent unsigned integer whose length matches the current system's bit width.

### extend UIntNative

```cangjie
extend UIntNative
```

Function: Extends the platform-dependent unsigned integer to support certain mathematical constants.

#### static prop Max

```cangjie
public static prop Max: UIntNative
```

Function: Gets the maximum value of a platform-dependent unsigned integer.

Type: [UIntNative](./core_package_intrinsics.md#uintnative)

Example:

<!-- verify -->
```cangjie
main() {
    var maxValue = UIntNative.Max
    println(maxValue)
}
```

Output:

```text
18446744073709551615
```

#### static prop Min

```cangjie
public static prop Min: UIntNative
```

Function: Gets the minimum value of a platform-dependent unsigned integer.

Type: [UIntNative](./core_package_intrinsics.md#uintnative)

Example:

<!-- verify -->
```cangjie
main() {
    var minValue = UIntNative.Min
    println(minValue)
}
```

Output:

```text
0
```

### extend UIntNative <: Comparable\<UIntNative>

```cangjie
extend UIntNative <: Comparable<UIntNative>
```

Function: Extends the [UIntNative](core_package_intrinsics.md#uintnative) type with the [Comparable](core_package_interfaces.md#interface-comparablet)\<[UIntNative](core_package_intrinsics.md#uintnative)> interface to support comparison operations.

Parent Types:

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UIntNative](#uintnative)>

#### func compare(UIntNative)

```cangjie
public func compare(rhs: UIntNative): Ordering
```

Function: Determines the size relationship between the current [UIntNative](core_package_intrinsics.md#uintnative) value and the specified [UIntNative](core_package_intrinsics.md#uintnative) value.

Parameters:

- rhs: [UIntNative](core_package_intrinsics.md#uintnative) - Another [UIntNative](core_package_intrinsics.md#uintnative) value to compare.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns [Ordering](core_package_enums.md#enum-ordering).GT if greater; [Ordering](core_package_enums.md#enum-ordering).EQ if equal; [Ordering](core_package_enums.md#enum-ordering).LT if less.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UIntNative = 2
    var num2: UIntNative = 3
    println(num1.compare(num2))
}
```

Output:

```text
Ordering.LT
```

### extend UIntNative <: Countable

```cangjie
extend UIntNative <: Countable<UIntNative>
```

Function: Extends the [UIntNative](core_package_intrinsics.md#uintnative) type with the [Countable](core_package_interfaces.md#interface-countablet)\<[UIntNative](core_package_intrinsics.md#uintnative)> interface to support counting operations.

Parent Types:

- [Countable](core_package_interfaces.md#interface-countablet)\<[UIntNative](#uintnative)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UIntNative
```

Function: Gets the [UIntNative](core_package_intrinsics.md#uintnative) value at the position `right` units to the right of the current [UIntNative](core_package_intrinsics.md#int32) position on the number axis. If the value overflows, it continues moving from the leftmost position of the axis.

Parameters:

- right: [Int64](core_package_intrinsics.md#int64) - The number of units to move right.

Returns:

- [UIntNative](core_package_intrinsics.md#uintnative) - The [UIntNative](core_package_intrinsics.md#uintnative) value at the position after moving `right` units to the right.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 3
    println(num.next(10))
}
```

Output:

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

Function: Gets the position information of the current [UIntNative](core_package_intrinsics.md#uintnative) value, i.e., converts the [UIntNative](core_package_intrinsics.md#uintnative) to an [Int64](core_package_intrinsics.md#int64) value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The position information of the current [UIntNative](core_package_intrinsics.md#uintnative) value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 8
    println(num.position())
}
```

Output:

```text
8
```

### extend UIntNative <: Hashable

```cangjie
extend UIntNative <: Hashable
```

Function: Extends the [UIntNative](core_package_intrinsics.md#uintnative) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface to support hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 42
    var hash = num.hashCode()
    println(hash)
}
```

Output:

```text
42
```

### extend UIntNative <: ToString

```cangjie
extend UIntNative <: ToString
```

Function: Extends the [UIntNative](core_package_intrinsics.md#uintnative) type with the [ToString](core_package_interfaces.md#interface-tostring) interface to support conversion to the [String](core_package_structs.md#struct-string) type.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [UIntNative](core_package_intrinsics.md#uintnative) value to an outputtable string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 12345
    var str = num.toString()
    println("The string representation is: " + str)
}
```

Output:

```text
The string representation is: 12345
```

## Unit

Function: Represents the type of expressions in Cangjie language that only care about side effects and not about values.

For example, the `print` function, assignment expressions, compound assignment expressions, increment and decrement expressions, and loop expressions all have the type [Unit](core_package_intrinsics.md#unit).

The [Unit](core_package_intrinsics.md#unit) type has only one value, which is also its literal: `()`. Apart from assignment, equality, and inequality comparisons, the [Unit](core_package_intrinsics.md#unit) type does not support other operations.

### extend Unit <: Equatable\<Unit>

```cangjie
extend Unit <: Equatable<Unit>
```

Function: Extends the [Equatable](core_package_interfaces.md#interface-equatablet)\<[Unit](core_package_intrinsics.md#unit)> interface for the [Unit](core_package_intrinsics.md#unit) type.

Parent Types:

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Unit](#unit)>

### extend Unit <: Hashable

```cangjie
extend Unit <: Hashable
```

Function: Extends the [Hashable](core_package_interfaces.md#interface-hashable) interface for the [Unit](core_package_intrinsics.md#unit) type, enabling hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Retrieves the hash value. The hash value of [Unit](core_package_intrinsics.md#unit) is 0.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    var unitValue = ()
    var hash = unitValue.hashCode()
    println(hash)
}
```

Output:

```text
0
```

### extend Unit <: ToString

```cangjie
extend Unit <: ToString
```

Function: Extends the [ToString](core_package_interfaces.md#interface-tostring) interface for the [Unit](core_package_intrinsics.md#unit) type, enabling conversion to the [String](core_package_structs.md#struct-string) type.

The string representation of [Unit](core_package_intrinsics.md#unit) is `"()"`.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts a [Unit](core_package_intrinsics.md#unit) value to an output-ready string.

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
main() {
    var unitValue = ()
    var str = unitValue.toString()
    println("The string representation is: " + str)
}
```

Output:

```text
The string representation is: ()
```