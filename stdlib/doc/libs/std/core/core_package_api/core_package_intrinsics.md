# 内置类型

## Bool

功能：表示布尔类型，有 `true` 和 `false` 两种取值。

### extend Bool <: Equatable\<Bool>

```cangjie
extend Bool <: Equatable<Bool>
```

功能：为 [Bool](core_package_intrinsics.md#bool) 类型扩展 [Equatable](core_package_interfaces.md#interface-equatablet)\<[Bool](core_package_intrinsics.md#bool)> 接口，支持判等操作。

父类型：

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Bool](#bool)>

### extend Bool <: Hashable

```cangjie
extend Bool <: Hashable
```

功能：为 [Bool](core_package_intrinsics.md#bool) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var flag: Bool = false
    println(flag.hashCode())
    flag = true
    println(flag.hashCode())
}
```

运行结果：

```text
0
1
```

### extend Bool <: ToString

```cangjie
extend Bool <: ToString
```

功能：为 [Bool](core_package_intrinsics.md#bool) 类型其扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Bool](core_package_intrinsics.md#bool) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

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

运行结果：

```text
false
true
```

## CPointer\<T>

功能：表示 `T` 类型实例的指针，在与 C 语言互操作的场景下使用，对应 C 语言的 `T*`。

其中 `T` 必须满足 [CType](core_package_interfaces.md#interface-ctype) 约束。

[CPointer](core_package_intrinsics.md#cpointert) 类型必须满足：

- 大小和对齐与平台相关。
- 对它做加减法算术运算、读写内存，是需要在 unsafe 上下文操作的。
- [CPointer](core_package_intrinsics.md#cpointert)\<T1> 可以在 unsafe 上下文中使用类型强制转换，变成 [CPointer](core_package_intrinsics.md#cpointert)\<T2> 类型。

### extend\<T> CPointer\<T>

```cangjie
extend<T> CPointer<T>
```

功能：为 [CPointer](core_package_intrinsics.md#cpointert)\<T> 扩展一些必要的指针使用相关接口，包含判空、读写数据等接口。

其中泛型 `T` 为指针类型，其满足 [CType](core_package_interfaces.md#interface-ctype) 约束。对 [CPointer](core_package_intrinsics.md#cpointert) 做运算需要在 `unsafe` 上下文中进行。

#### func asResource()

```cangjie
public func asResource(): CPointerResource<T>
```

功能：获取该指针 [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype) 实例，该实例可以在 `try-with-resource` 语法上下文中实现内容自动释放。

返回值：

- [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype)\<T> - 当前指针对应的 [CPointerResource](core_package_structs.md#struct-cpointerresourcet-where-t--ctype) 实例。

示例：

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

运行结果：

```text
10
true
```

#### func isNotNull()

```cangjie
public func isNotNull(): Bool
```

功能：判断指针是否不为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不为空返回 true，否则返回 false。

示例：

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

运行结果：

```text
false
true
```

#### func isNull()

```cangjie
public func isNull(): Bool
```

功能：判断指针是否为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空返回 true，否则返回 false。

示例：

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

运行结果：

```text
10
```

#### func read()

```cangjie
public unsafe func read(): T
```

功能：读取第一个数据，该接口需要用户保证指针的合法性，否则发生未定义行为。

返回值：

- T - 该对象类型的第一个数据。

示例：

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

运行结果：

```text
true
false
```

#### func read(Int64)

```cangjie
public unsafe func read(idx: Int64): T
```

功能：根据下标读取对应的数据，该接口需要用户保证指针的合法性，否则发生未定义行为。

参数：

- idx: [Int64](core_package_intrinsics.md#int64) - 要获取数据的下标。

返回值：

- T - 输入下标对应的数据。

示例：

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

运行结果：

```text
The third element of the array is 3
```

#### func toUIntNative()

```cangjie
public func toUIntNative(): UIntNative
```

功能：获取该指针的整型形式。

返回值：

- [UIntNative](core_package_intrinsics.md#uintnative) - 该指针的整型形式。

示例：

<!-- run -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

main() {
    let sizeofInt64: UIntNative = 8
    var p = unsafe { malloc(sizeofInt64) }
    var p1 = unsafe { CPointer<Int64>(p) }
    unsafe { p1.write(8) }
    println("toUIntNative: ${p1.toUIntNative()}")
    unsafe { free(p) }
}
```

运行结果：

```text
toUIntNative: 94019473199456
```

#### func write(Int64, T)

```cangjie
public unsafe func write(idx: Int64, value: T): Unit
```

功能：在指定下标位置写入一个数据，该接口需要用户保证指针的合法性，否则发生未定义行为。

参数：

- idx: [Int64](core_package_intrinsics.md#int64) - 指定的下标位置。
- value: T - 写入的数据。

示例：

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

运行结果：

```text
The third element of the array is 6
```

#### func write(T)

```cangjie
public unsafe func write(value: T): Unit
```

功能：写入一个数据，该数据总是在第一个，该接口需要用户保证指针的合法性，否则发生未定义行为。

参数：

- value: T - 要写入的数据。

示例：

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

运行结果：

```text
8
```

#### operator func +(Int64)

```cangjie
public unsafe operator func +(offset: Int64): CPointer<T>
```

功能：[CPointer](core_package_intrinsics.md#cpointert) 对象指针后移，同 C 语言的指针加法操作。

参数：

- offset: [Int64](core_package_intrinsics.md#int64) - 偏移量。

返回值：

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - 返回偏移后的指针。

示例：

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

运行结果：

```text
1
2
```

#### operator func -(Int64)

```cangjie
public unsafe operator func -(offset: Int64): CPointer<T>
```

功能：[CPointer](core_package_intrinsics.md#cpointert) 对象指针前移，同 C 语言的指针减法操作。

参数：

- offset: [Int64](core_package_intrinsics.md#int64) - 偏移量。

返回值：

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - 返回偏移后的指针。

示例：

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

运行结果：

```text
1
2
1
```

## CString

功能：表示 C 风格字符串，在与 C 语言互操作的场景下使用。

可以通过 [CString](core_package_intrinsics.md#cstring) 的构造函数或 [LibC](core_package_structs.md#struct-libc) 的 `mallocCString` 创建 C 风格字符串，如需在仓颉端释放，则调用 [LibC](core_package_structs.md#struct-libc) 的 free 方法。

### extend CString <: ToString

```cangjie
extend CString <: ToString
```

功能：为 [CString](core_package_intrinsics.md#cstring) 类型扩展一些字符串指针常用方法，包括判空、获取长度、判等、获取子串等。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func asResource()

```cangjie
public func asResource(): CStringResource
```

功能：获取当前 [CString](core_package_intrinsics.md#cstring) 实例对应的 [CStringResource](core_package_structs.md#struct-cstringresource) C 字符串资源类型实例。

[CStringResource](core_package_structs.md#struct-cstringresource) 实现了 [Resource](core_package_interfaces.md#interface-resource) 接口，可以在 `try-with-resource` 语法上下文中实现资源自动释放。

返回值：

- [CStringResource](core_package_structs.md#struct-cstringresource) - 对应的 [CStringResource](core_package_structs.md#struct-cstringresource) C 字符串资源类型实例。

示例：

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

运行结果：

```text
5
true
```

#### func compare(CString)

```cangjie
public func compare(str: CString): Int32
```

功能：按字典序比较两个字符串，同 C 语言中的 `strcmp`。

参数：

- str: [CString](core_package_intrinsics.md#cstring) - 比较的目标字符串。

返回值：

- [Int32](core_package_intrinsics.md#int32) - 两者相等返回 0，如果当前字符串比参数 str 小，返回 -1，否则返回 1。

异常：

- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - 如果被比较的两个 [CString](core_package_intrinsics.md#cstring) 中存在空指针，抛出异常。

示例：

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

运行结果：

```text
0
-1
1
```

#### func endsWith(CString)

```cangjie
public func endsWith(suffix: CString): Bool
```

功能：判断字符串是否包含指定后缀。

参数：

- suffix: [CString](core_package_intrinsics.md#cstring) - 匹配的目标后缀字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果该字符串包含 suffix 后缀，返回 true，如果该字符串不包含 suffix 后缀，返回 false，特别地，如果原字符串或者 suffix 后缀字符串指针为空，均返回 false。

示例：

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

运行结果：

```text
true
false
```

#### func equals(CString)

```cangjie
public func equals(other: CString): Bool
```

功能：判断两个字符串是否相等。

参数：

- other: [CString](core_package_intrinsics.md#cstring) - 比较的目标字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果两个字符串相等，返回 true，否则返回 false。

示例：

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

运行结果：

```text
true
false
```

#### func equalsLower(CString)

```cangjie
public func equalsLower(other: CString): Bool
```

功能：判断两个字符串是否相等，忽略大小写。

参数：

- other: [CString](core_package_intrinsics.md#cstring) - 匹配的目标字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果两个字符串忽略大小写相等，返回 true，否则返回 false。

示例：

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

运行结果：

```text
true
true
```

#### func getChars()

```cangjie
public func getChars(): CPointer<UInt8>
```

功能：获取该字符串的指针。

返回值：

- [CPointer](./core_package_intrinsics.md#cpointert)\<[UInt8](./core_package_intrinsics.md#uint8)> - 该字符串的指针。

示例：

<!-- verify -->
```cangjie
main() {
    var str1: CString = unsafe { LibC.mallocCString("hello") }
    var ptr: CPointer<UInt8> = unsafe { str1.getChars() }
    var c: UInt8 = unsafe { ptr.read() }
    println(c) // h的ascii码为104
    unsafe {
        LibC.free(str1)
    }
}
```

运行结果：

```text
104
```

#### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

功能：判断字符串是否为空字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空字符串或字符串指针为空，返回 true，否则返回 false。

示例：

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

运行结果：

```text
false
```

#### func isNotEmpty()

```cangjie
public func isNotEmpty(): Bool
```

功能：判断字符串是否不为空字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不为空字符串，返回 true，如果字符串指针为空，返回 false。

示例：

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

运行结果：

```text
true
```

#### func isNull()

```cangjie
public func isNull(): Bool
```

功能：判断字符串指针是否为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果字符串指针为空，返回 true，否则返回 false。

示例：

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

运行结果：

```text
false
```

#### func size()

```cangjie
public func size(): Int64
```

功能：返回该字符串长度，同 C 语言中的 `strlen`。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 字符串长度。

示例：

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

运行结果：

```text
5
```

#### func startsWith(CString)

```cangjie
public func startsWith(prefix: CString): Bool
```

功能：判断字符串是否包含指定前缀。

参数：

- prefix: [CString](core_package_intrinsics.md#cstring) - 匹配的目标前缀字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果该字符串包含 prefix 前缀，返回 true，如果该字符串不包含 prefix 前缀，返回 false，特别地，如果原字符串或者 prefix 前缀字符串指针为空，均返回 false。

示例：

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

运行结果：

```text
true
```

#### func subCString(UIntNative)

```cangjie
public func subCString(beginIndex: UIntNative): CString
```

功能：截取指定位置开始至字符串结束的子串。

> **注意：**
>
> 1. 该接口返回为字符串的副本，返回的子串使用完后需要手动 free。
> 2. 如果 beginIndex 与字符串长度相等，将返回空指针。

参数：

- beginIndex: [UIntNative](core_package_intrinsics.md#uintnative) - 截取的起始位置，取值范围为 [0, this.size()]。

返回值：

- [CString](core_package_intrinsics.md#cstring) - 截取的子串。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 beginIndex 大于字符串长度，抛出异常。
- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - 如果内存申请失败或内存拷贝失败时，抛出异常。

示例：

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

运行结果：

```text
llo
```

#### func subCString(UIntNative, UIntNative)

```cangjie
public func subCString(beginIndex: UIntNative, subLen: UIntNative): CString
```

功能：截取字符串的子串，指定起始位置和截取长度。

如果截取的末尾位置超出字符串长度，截取至字符串末尾。

> **注意：**
>
> 1. 该接口返回为字符串的副本，返回的子串使用完后需要手动 free。
> 2. 如果 beginIndex 等于于字符串长度，或 subLen 等于 0，返回空指针。

参数：

- beginIndex: [UIntNative](core_package_intrinsics.md#uintnative) - 截取的起始位置，取值范围为 [0, this.size()]。
- subLen: [UIntNative](core_package_intrinsics.md#uintnative) - 截取长度，取值范围为 [0, [UIntNative](core_package_intrinsics.md#uintnative).Max]。

返回值：

- [CString](core_package_intrinsics.md#cstring) - 截取的子串。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 beginIndex 大于字符串长度，抛出异常。
- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - 如果内存申请失败或内存拷贝失败时，抛出异常。

示例：

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

运行结果：

```text
ll
```

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [CString](core_package_intrinsics.md#cstring) 类型转为仓颉的 [String](core_package_structs.md#struct-string) 类型。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 不合法的 UTF-8 字节序列。

示例：

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

运行结果：

```text
hello
```

## Float16

功能：表示 16 位浮点数，符合 `IEEE 754` 中的半精度格式（`binary16`）。

### extend Float16

```cangjie
extend Float16
```

功能：拓展半精度浮点数以支持一些数学常数。

#### static prop Inf

```cangjie
public static prop Inf: Float16
```

功能：获取半精度浮点数的无穷数。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.Inf 属性
    let infValue = Float16.Inf
    println("Float16.Inf 的值: ${infValue}")

    // 验证它确实是无穷大
    println("Float16.Inf 是否为无穷大: ${infValue.isInf()}")
}
```

运行结果：

```text
Float16.Inf 的值: inf
Float16.Inf 是否为无穷大: true
```

#### static prop Max

```cangjie
public static prop Max: Float16
```

功能：获取半精度浮点数的最大值。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.Max 属性
    let maxValue = Float16.Max
    println("Float16.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Float16.Max 是否为常规数值: ${maxValue.isNormal()}")
}
```

运行结果：

```text
Float16.Max 的值: 65504.000000
Float16.Max 是否为常规数值: true
```

#### static prop Min

```cangjie
public static prop Min: Float16
```

功能：获取半精度浮点数的最小值。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.Min 属性
    let minValue = Float16.Min
    println("Float16.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Float16.Min 是否为常规数值: ${minValue.isNormal()}")
}
```

运行结果：

```text
Float16.Min 的值: -65504.000000
Float16.Min 是否为常规数值: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float16
```

功能：获取半精度浮点数的最小次正规数。最小的正的次正规数是以 IEEE 双精度格式表示的最小正数。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.MinDenormal 属性
    let minDenormalValue = Float16.MinDenormal
    println("Float16.MinDenormal 的值: ${minDenormalValue}")

    // 验证它确实是最小次正规数
    println("Float16.MinDenormal 是否为常规数值: ${minDenormalValue.isNormal()}")
}
```

运行结果：

```text
Float16.MinDenormal 的值: 0.000000
Float16.MinDenormal 是否为常规数值: true
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float16
```

功能：获取半精度浮点数的最小正规数。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.MinNormal 属性
    let minNormalValue = Float16.MinNormal
    println("Float16.MinNormal 的值: ${minNormalValue}")

    // 验证它确实是最小正规数
    println("Float16.MinNormal 是否为常规数值: ${minNormalValue.isNormal()}")
}
```

运行结果：

```text
Float16.MinNormal 的值: 0.000061
Float16.MinNormal 是否为常规数值: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float16
```

功能：获取半精度浮点数的非数。

类型：[Float16](./core_package_intrinsics.md#float16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.NaN 属性
    let nanValue = Float16.NaN
    println("Float16.NaN 的值: ${nanValue}")

    // 验证它确实是 NaN
    println("Float16.NaN 是否为非数值: ${nanValue.isNaN()}")
}
```

运行结果：

```text
Float16.NaN 的值: nan
Float16.NaN 是否为非数值: true
```

#### static func max(Float16, Float16, Array\<Float16>)

```cangjie
public static func max(a: Float16, b: Float16, others: Array<Float16>): Float16
```

功能：返回一组[Float16](./core_package_intrinsics.md#float16)中的最大值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float16](./core_package_intrinsics.md#float16)最大值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float16](./core_package_intrinsics.md#float16) - 第一个待比较的数。
- b: [Float16](./core_package_intrinsics.md#float16) - 第二个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float16](./core_package_intrinsics.md#float16)> - 其他待比较的数。

返回值：

- [Float16](./core_package_intrinsics.md#float16) - 返回参数中的最大值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.max 静态方法
    let a: Float16 = 1.5f16
    let b: Float16 = 2.7f16
    let c: Float16 = 0.8f16
    let d: Float16 = 3.2f16
    let e: Float16 = 3.4f16
    let f: Float16 = 3.8f16
    let g: Float16 = 3.9f16

    // 使用 max 方法找出最大值
    let maxValue = Float16.max(a, b, c, d, e, f, g)
    println("Float16.max(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9) 的结果: ${maxValue}")

    // 验证结果
    println("最大值是否正确: ${maxValue == g}")
}
```

运行结果：

```text
Float16.max(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9) 的结果: 3.900391
最大值是否正确: true
```

#### static func min(Float16, Float16, Array\<Float16>)

```cangjie
public static func min(a: Float16, b: Float16, others: Array<Float16>): Float16
```

功能：返回一组[Float16](./core_package_intrinsics.md#float16)中的最小值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float16](./core_package_intrinsics.md#float16)最小值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float16](./core_package_intrinsics.md#float16) - 第一个待比较的数。
- b: [Float16](./core_package_intrinsics.md#float16) - 第一个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float16](./core_package_intrinsics.md#float16)> - 其他待比较的数。

返回值：

- [Float16](./core_package_intrinsics.md#float16) - 返回参数中的最小值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.min 静态方法
    let a: Float16 = 1.5f16
    let b: Float16 = 2.7f16
    let c: Float16 = 0.8f16
    let d: Float16 = 3.2f16
    let e: Float16 = 3.4f16
    let f: Float16 = 3.8f16
    let g: Float16 = 3.9f16

    // 使用 min 方法找出最小值
    let minValue = Float16.min(a, b, c, d, e, f, g)
    println("Float16.min(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9) 的结果: ${minValue}")

    // 验证结果
    println("最小值是否正确: ${minValue == c}")
}
```

运行结果：

```text
Float16.min(1.5, 2.7, 0.8, 3.2, 3.4, 3.8, 3.9) 的结果: 0.799805
最小值是否正确: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

功能：判断某个浮点数 [Float16](./core_package_intrinsics.md#float16) 是否为无穷数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float16](./core_package_intrinsics.md#float16) 的值正无穷大或负无穷大，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.isInf 方法
    let normalValue: Float16 = 1.5f16
    let infValue = Float16.Inf
    let negInfValue = -Float16.Inf

    // 检查普通值是否为无穷
    println("1.5f16.isInf() 的结果: ${normalValue.isInf()}")

    // 检查正无穷是否为无穷
    println("Float16.Inf.isInf() 的结果: ${infValue.isInf()}")

    // 检查负无穷是否为无穷
    println("(-Float16.Inf).isInf() 的结果: ${negInfValue.isInf()}")
}
```

运行结果：

```text
1.5f16.isInf() 的结果: false
Float16.Inf.isInf() 的结果: true
(-Float16.Inf).isInf() 的结果: true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

功能：判断某个浮点数 [Float16](./core_package_intrinsics.md#float16) 是否为非数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float16](./core_package_intrinsics.md#float16) 的值为非数值，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.isNaN 方法
    let normalValue: Float16 = 1.5f16
    let nanValue = Float16.NaN

    // 检查普通值是否为 NaN
    println("1.5f16.isNaN() 的结果: ${normalValue.isNaN()}")

    // 检查 NaN 值是否为 NaN
    println("Float16.NaN.isNaN() 的结果: ${nanValue.isNaN()}")
}
```

运行结果：

```text
1.5f16.isNaN() 的结果: false
Float16.NaN.isNaN() 的结果: true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

功能：判断某个浮点数 [Float16](./core_package_intrinsics.md#float16) 是否为常规数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float16](./core_package_intrinsics.md#float16) 的值是正常的浮点数，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.isNormal 方法
    let normalValue: Float16 = 1.5f16
    let zeroValue: Float16 = 0.0f16
    let infValue = Float16.Inf
    let nanValue = Float16.NaN

    // 检查普通值是否为常规数值
    println("1.5f16.isNormal() 的结果: ${normalValue.isNormal()}")

    // 检查零值是否为常规数值
    println("0.0f16.isNormal() 的结果: ${zeroValue.isNormal()}")

    // 检查无穷值是否为常规数值
    println("Float16.Inf.isNormal() 的结果: ${infValue.isNormal()}")

    // 检查 NaN 值是否为常规数值
    println("Float16.NaN.isNormal() 的结果: ${nanValue.isNormal()}")
}
```

运行结果：

```text
1.5f16.isNormal() 的结果: true
0.0f16.isNormal() 的结果: false
Float16.Inf.isNormal() 的结果: false
Float16.NaN.isNormal() 的结果: false
```

### extend Float16

```cangjie
extend Float16
```

功能：支持与 [UInt16](core_package_intrinsics.md#uint16) 互相转换。

#### static func fromBits(UInt16)

```cangjie
public static func fromBits(bits: UInt16): Float16
```

功能：将指定的 [UInt16](core_package_intrinsics.md#uint16) 按照 `IEEE 754` 标准中 float16 的二进制位表示形式，直接转换为对应的 [Float16](core_package_intrinsics.md#float16) 浮点数。

参数：

- bits: [UInt16](core_package_intrinsics.md#uint16) - 要转换的数字。

返回值：

- [Float16](core_package_intrinsics.md#float16) - 转换结果，其位与参数 bits 值相同。

示例：

<!-- verify -->
```cangjie
main() {
    let v = Float16.fromBits(0x4A40u16)
    println(v)
}
```

运行结果：

```text
12.500000
```

#### func toBits()

```cangjie
public func toBits(): UInt16
```

功能：将指定的 [Float16](core_package_intrinsics.md#float16) 数转换为以位表示的对应 [UInt16](core_package_intrinsics.md#uint16) 数。

返回值：

- [UInt16](core_package_intrinsics.md#uint16) - 转换结果，其值与 [Float16](core_package_intrinsics.md#float16) 的位表示相同。

示例：

<!-- verify -->
```cangjie
main() {
    println(12.5f16.toBits()) // 0x4A40 19008
}
```

运行结果：

```text
19008
```

### extend Float16 <: Comparable\<Float16>

```cangjie
extend Float16 <: Comparable<Float16>
```

功能：为 [Float16](core_package_intrinsics.md#float16) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float16](core_package_intrinsics.md#float16)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float16](#float16)>

#### func compare(Float16)

```cangjie
public func compare(other: Float16): Ordering
```

功能：判断当前 [Float16](core_package_intrinsics.md#float16) 值与指定 [Float16](core_package_intrinsics.md#float16) 值的大小关系。`NaN` 无法参与比较，返回值无意义。

参数：

- other: [Float16](core_package_intrinsics.md#float16) - 待比较的另一个 [Float16](core_package_intrinsics.md#float16) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Float16 = 0.12
    var num2: Float16 = 0.234
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Float16 <: Hashable

```cangjie
extend Float16 <: Hashable
```

功能：为 [Float16](core_package_intrinsics.md#float16) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.hashCode 方法
    let value1: Float16 = 1.5f16
    let value2: Float16 = 1.5f16
    let value3: Float16 = 2.0f16

    // 计算哈希值
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()

    println("1.5f16 的哈希值: ${hash1}")
    println("1.5f16 的哈希值: ${hash2}")
    println("2.0f16 的哈希值: ${hash3}")

    // 验证相等的值具有相同的哈希值
    println("相等值的哈希值是否相同: ${hash1 == hash2}")
}
```

运行结果：

```text
1.5f16 的哈希值: 7729828949621302189
1.5f16 的哈希值: 7729828949621302189
2.0f16 的哈希值: 396734039217596648
相等值的哈希值是否相同: true
```

### extend Float16 <: ToString

```cangjie
extend Float16 <: ToString
```

功能：为 [Float16](core_package_intrinsics.md#float16) 类型其扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。默认保留 6 位小数。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Float16](core_package_intrinsics.md#float16) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float16.toString 方法
    let value1: Float16 = 1.5f16
    let value2: Float16 = 123.456f16
    let value3: Float16 = -0.001f16

    // 转换为字符串
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()

    println("1.5f16 转换为字符串: \"${str1}\"")
    println("123.456f16 转换为字符串: \"${str2}\"")
    println("-0.001f16 转换为字符串: \"${str3}\"")

    // 验证类型
    println("转换后的类型是否为 String: ${str1 is String}")
}
```

运行结果：

```text
1.5f16 转换为字符串: "1.500000"
123.456f16 转换为字符串: "123.437500"
-0.001f16 转换为字符串: "-0.001000"
转换后的类型是否为 String: true
```

## Float32

功能：表示 32 位浮点数，符合 `IEEE 754` 中的单精度格式（`binary32`）。

### extend Float32

```cangjie
extend Float32
```

功能：拓展单精度浮点数以支持一些数学常数。

#### static prop Inf

```cangjie
public static prop Inf: Float32
```

功能：获取单精度浮点数的无穷数。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.Inf 属性
    let infValue = Float32.Inf
    println("Float32.Inf 的值: ${infValue}")

    // 验证它确实是无穷大
    println("Float32.Inf 是否为无穷大: ${infValue.isInf()}")
}
```

运行结果：

```text
Float32.Inf 的值: inf
Float32.Inf 是否为无穷大: true
```

#### static prop Max

```cangjie
public static prop Max: Float32
```

功能：获取单精度浮点数的最大值。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.Max 属性
    let maxValue = Float32.Max
    println("Float32.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Float32.Max 是否为常规数值: ${maxValue.isNormal()}")
}
```

运行结果：

```text
Float32.Max 的值: 340282346638528859811704183484516925440.000000
Float32.Max 是否为常规数值: true
```

#### static prop Min

```cangjie
public static prop Min: Float32
```

功能：获取单精度浮点数的最小值。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.Min 属性
    let minValue = Float32.Min
    println("Float32.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Float32.Min 是否为常规数值: ${minValue.isNormal()}")
}
```

运行结果：

```text
Float32.Min 的值: -340282346638528859811704183484516925440.000000
Float32.Min 是否为常规数值: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float32
```

功能：获取单精度浮点数的最小次正规数。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.MinDenormal 属性
    let minDenormalValue = Float32.MinDenormal
    println("Float32.MinDenormal 的值: ${minDenormalValue}")

    // 验证它确实是最小次正规数
    println("Float32.MinDenormal 是否为常规数值: ${minDenormalValue.isNormal()}")
}
```

运行结果：

```text
Float32.MinDenormal 的值: 0.000000
Float32.MinDenormal 是否为常规数值: false
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float32
```

功能：获取单精度浮点数的最小正规数。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.MinNormal 属性
    let minNormalValue = Float32.MinNormal
    println("Float32.MinNormal 的值: ${minNormalValue}")

    // 验证它确实是最小正规数
    println("Float32.MinNormal 是否为常规数值: ${minNormalValue.isNormal()}")
}
```

运行结果：

```text
Float32.MinNormal 的值: 0.000000
Float32.MinNormal 是否为常规数值: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float32
```

功能：获取单精度浮点数的非数。

类型：[Float32](./core_package_intrinsics.md#float32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.NaN 属性
    let nanValue = Float32.NaN
    println("Float32.NaN 的值: ${nanValue}")

    // 验证它确实是 NaN
    println("Float32.NaN 是否为非数值: ${nanValue.isNaN()}")
}
```

运行结果：

```text
Float32.NaN 的值: nan
Float32.NaN 是否为非数值: true
```

#### static func max(Float32, Float32, Array\<Float32>)

```cangjie
public static func max(a: Float32, b: Float32, others: Array<Float32>): Float32
```

功能：返回一组[Float32](./core_package_intrinsics.md#float32)中的最大值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float32](./core_package_intrinsics.md#float32)最大值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float32](./core_package_intrinsics.md#float32) - 第一个待比较的数。
- b: [Float32](./core_package_intrinsics.md#float32) - 第二个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float32](./core_package_intrinsics.md#float32)> - 其他待比较的数。

返回值：

- [Float32](./core_package_intrinsics.md#float32) - 返回参数中的最大值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.max 静态方法
    let a: Float32 = 1.5f32
    let b: Float32 = 2.7f32
    let c: Float32 = 0.8f32
    let d: Float32 = 3.2f32

    // 使用 max 方法找出最大值
    let maxValue = Float32.max(a, b, c, d)
    println("Float32.max(1.5, 2.7, 0.8, 3.2) 的结果: ${maxValue}")

    // 验证结果
    println("最大值是否正确: ${maxValue == d}")
}
```

运行结果：

```text
Float32.max(1.5, 2.7, 0.8, 3.2) 的结果: 3.200000
最大值是否正确: true
```

#### static func min(Float32, Float32, Array\<Float32>)

```cangjie
public static func min(a: Float32, b: Float32, others: Array<Float32>): Float32
```

功能：返回一组[Float32](./core_package_intrinsics.md#float32)中的最小值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float32](./core_package_intrinsics.md#float32)最小值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float32](./core_package_intrinsics.md#float32) - 第一个待比较的数。
- b: [Float32](./core_package_intrinsics.md#float32) - 第二个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float32](./core_package_intrinsics.md#float32)> - 其他待比较的数。

返回值：

- [Float32](./core_package_intrinsics.md#float32) - 返回参数中的最小值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.min 静态方法
    let a: Float32 = 1.5f32
    let b: Float32 = 2.7f32
    let c: Float32 = 0.8f32
    let d: Float32 = 3.2f32

    // 使用 min 方法找出最小值
    let minValue = Float32.min(a, b, c, d)
    println("Float32.min(1.5, 2.7, 0.8, 3.2) 的结果: ${minValue}")

    // 验证结果
    println("最小值是否正确: ${minValue == c}")
}
```

运行结果：

```text
Float32.min(1.5, 2.7, 0.8, 3.2) 的结果: 0.800000
最小值是否正确: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

功能：判断某个浮点数 [Float32](./core_package_intrinsics.md#float32) 是否为无穷数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float32](./core_package_intrinsics.md#float32) 的值正无穷大或负无穷大，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.isInf 方法
    let normalValue: Float32 = 1.5f32
    let infValue = Float32.Inf
    let negInfValue = -Float32.Inf

    // 检查普通值是否为无穷
    println("1.5f32.isInf() 的结果: ${normalValue.isInf()}")

    // 检查正无穷是否为无穷
    println("Float32.Inf.isInf() 的结果: ${infValue.isInf()}")

    // 检查负无穷是否为无穷
    println("(-Float32.Inf).isInf() 的结果: ${negInfValue.isInf()}")
}
```

运行结果：

```text
1.5f32.isInf() 的结果: false
Float32.Inf.isInf() 的结果: true
(-Float32.Inf).isInf() 的结果: true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

功能：判断某个浮点数 [Float32](./core_package_intrinsics.md#float32) 是否为非数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float32](./core_package_intrinsics.md#float32) 的值为非数值，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.isNaN 方法
    let normalValue: Float32 = 1.5f32
    let nanValue = Float32.NaN

    // 检查普通值是否为 NaN
    println("1.5f32.isNaN() 的结果: ${normalValue.isNaN()}")

    // 检查 NaN 值是否为 NaN
    println("Float32.NaN.isNaN() 的结果: ${nanValue.isNaN()}")
}
```

运行结果：

```text
1.5f32.isNaN() 的结果: false
Float32.NaN.isNaN() 的结果: true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

功能：判断某个浮点数 [Float32](./core_package_intrinsics.md#float32) 是否为常规数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float32](./core_package_intrinsics.md#float32) 的值是正常的浮点数，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.isNormal 方法
    let normalValue: Float32 = 1.5f32
    let zeroValue: Float32 = 0.0f32
    let infValue = Float32.Inf
    let nanValue = Float32.NaN

    // 检查普通值是否为常规数值
    println("1.5f32.isNormal() 的结果: ${normalValue.isNormal()}")

    // 检查零值是否为常规数值
    println("0.0f32.isNormal() 的结果: ${zeroValue.isNormal()}")

    // 检查无穷值是否为常规数值
    println("Float32.Inf.isNormal() 的结果: ${infValue.isNormal()}")

    // 检查 NaN 值是否为常规数值
    println("Float32.NaN.isNormal() 的结果: ${nanValue.isNormal()}")
}
```

运行结果：

```text
1.5f32.isNormal() 的结果: true
0.0f32.isNormal() 的结果: false
Float32.Inf.isNormal() 的结果: false
Float32.NaN.isNormal() 的结果: false
```

### extend Float32

```cangjie
extend Float32
```

功能：支持与 [UInt32](core_package_intrinsics.md#uint32) 互相转换。

#### static func fromBits(UInt32)

```cangjie
public static func fromBits(bits: UInt32): Float32
```

功能：将指定的 [UInt32](core_package_intrinsics.md#uint32)按照 `IEEE 754` 标准中 float32 的二进制位表示形式，直接转换为对应的[Float32](core_package_intrinsics.md#float32)浮点数。

参数：

- bits: [UInt32](core_package_intrinsics.md#uint32) - 要转换的数字。

返回值：

- [Float32](core_package_intrinsics.md#float32) - 转换结果，其位与参数 bits 值相同。

示例：

<!-- verify -->
```cangjie
main() {
    let v = Float32.fromBits(0x415E147Bu32)
    println(v)
}
```

运行结果：

```text
13.880000
```

#### func toBits()

```cangjie
public func toBits(): UInt32
```

功能：将指定的 [Float32](core_package_intrinsics.md#float32) 数转换为以位表示的对应 [UInt32](core_package_intrinsics.md#uint32) 数。

返回值：

- [UInt32](core_package_intrinsics.md#uint32) - 转换结果，其值与 [Float32](core_package_intrinsics.md#float32) 的位表示相同。

示例：

<!-- verify -->
```cangjie
main() {
    println(13.88f32.toBits()) // 0x415E147B 1096684667
}
```

运行结果：

```text
1096684667
```

### extend Float32 <: Comparable\<Float32>

```cangjie
extend Float32 <: Comparable<Float32>
```

功能：为 [Float32](core_package_intrinsics.md#float32) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float32](core_package_intrinsics.md#float32)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float32](#float32)>

#### func compare(Float32)

```cangjie
public func compare(other: Float32): Ordering
```

功能：判断当前 [Float32](core_package_intrinsics.md#float32) 值与指定 [Float32](core_package_intrinsics.md#float32) 值的大小关系。`NaN` 无法参与比较，返回值无意义。

参数：

- other: [Float32](core_package_intrinsics.md#float32) - 待比较的另一个 [Float32](core_package_intrinsics.md#float32) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Float32 = 0.12
    var num2: Float32 = 0.234
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Float32 <: Hashable

```cangjie
extend Float32 <: Hashable
```

功能：为 [Float32](core_package_intrinsics.md#float32) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.hashCode 方法
    let value1: Float32 = 1.5f32
    let value2: Float32 = 1.5f32
    let value3: Float32 = 2.0f32

    // 计算哈希值
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()

    println("1.5f32 的哈希值: ${hash1}")
    println("1.5f32 的哈希值: ${hash2}")
    println("2.0f32 的哈希值: ${hash3}")

    // 验证相等的值具有相同的哈希值
    println("相等值的哈希值是否相同: ${hash1 == hash2}")
}
```

运行结果：

```text
1.5f32 的哈希值: 7729828949621302189
1.5f32 的哈希值: 7729828949621302189
2.0f32 的哈希值: 396734039217596648
相等值的哈希值是否相同: true
```

### extend Float32 <: ToString

```cangjie
extend Float32 <: ToString
```

功能：为 [Float32](core_package_intrinsics.md#float32) 类型其扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。默认保留 6 位小数。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Float32](core_package_intrinsics.md#float32) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float32.toString 方法
    let value1: Float32 = 1.5f32
    let value2: Float32 = 123.456f32
    let value3: Float32 = -0.001f32

    // 转换为字符串
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()

    println("1.5f32 转换为字符串: \"${str1}\"")
    println("123.456f32 转换为字符串: \"${str2}\"")
    println("-0.001f32 转换为字符串: \"${str3}\"")

    // 验证类型
    println("转换后的类型是否为 String: ${str1 is String}")
}
```

运行结果：

```text
1.5f32 转换为字符串: "1.500000"
123.456f32 转换为字符串: "123.456001"
-0.001f32 转换为字符串: "-0.001000"
转换后的类型是否为 String: true
```

## Float64

功能：表示 64 位浮点数，符合 `IEEE 754` 中的双精度格式（`binary64`）。

### extend Float64

```cangjie
extend Float64
```

功能：拓展双精度浮点数以支持一些数学常数。

#### static prop Inf

```cangjie
public static prop Inf: Float64
```

功能：获取双精度浮点数的无穷数。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.Inf 属性
    let infValue = Float64.Inf
    println("Float64.Inf 的值: ${infValue}")

    // 验证它确实是无穷大
    println("Float64.Inf 是否为无穷大: ${infValue.isInf()}")
}
```

运行结果：

```text
Float64.Inf 的值: inf
Float64.Inf 是否为无穷大: true
```

#### static prop Max

```cangjie
public static prop Max: Float64
```

功能：获取双精度浮点数的最大值。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.Max 属性
    let maxValue = Float64.Max
    println("Float64.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Float64.Max 是否为常规数值: ${maxValue.isNormal()}")
}
```

运行结果：

```text
Float64.Max 的值: 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000
Float64.Max 是否为常规数值: true
```

#### static prop Min

```cangjie
public static prop Min: Float64
```

功能：获取双精度浮点数的最小值。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.Min 属性
    let minValue = Float64.Min
    println("Float64.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Float64.Min 是否为常规数值: ${minValue.isNormal()}")
}
```

运行结果：

```text
Float64.Min 的值: -179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000
Float64.Min 是否为常规数值: true
```

#### static prop MinDenormal

```cangjie
public static prop MinDenormal: Float64
```

功能：获取双精度浮点数的最小次正规数。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.MinDenormal 属性
    let minDenormalValue = Float64.MinDenormal
    println("Float64.MinDenormal 的值: ${minDenormalValue}")

    // 验证它确实是最小次正规数
    println("Float64.MinDenormal 是否为常规数值: ${minDenormalValue.isNormal()}")
}
```

运行结果：

```text
Float64.MinDenormal 的值: 0.000000
Float64.MinDenormal 是否为常规数值: false
```

#### static prop MinNormal

```cangjie
public static prop MinNormal: Float64
```

功能：获取双精度浮点数的最小正规数。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.MinNormal 属性
    let minNormalValue = Float64.MinNormal
    println("Float64.MinNormal 的值: ${minNormalValue}")

    // 验证它确实是最小正规数
    println("Float64.MinNormal 是否为常规数值: ${minNormalValue.isNormal()}")
}
```

运行结果：

```text
Float64.MinNormal 的值: 0.000000
Float64.MinNormal 是否为常规数值: true
```

#### static prop NaN

```cangjie
public static prop NaN: Float64
```

功能：获取双精度浮点数的非数。

类型：[Float64](./core_package_intrinsics.md#float64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.NaN 属性
    let nanValue = Float64.NaN
    println("Float64.NaN 的值: ${nanValue}")

    // 验证它确实是 NaN
    println("Float64.NaN 是否为非数值: ${nanValue.isNaN()}")
}
```

运行结果：

```text
Float64.NaN 的值: nan
Float64.NaN 是否为非数值: true
```

#### static func max(Float64, Float64, Array\<Float64>)

```cangjie
public static func max(a: Float64, b: Float64, others: Array<Float64>): Float64
```

功能：返回一组[Float64](./core_package_intrinsics.md#float64)中的最大值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float64](./core_package_intrinsics.md#float64)最大值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float64](./core_package_intrinsics.md#float64) - 第一个待比较的数。
- b: [Float64](./core_package_intrinsics.md#float64) - 第二个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float64](./core_package_intrinsics.md#float64)> - 其他待比较的数。

返回值：

- [Float64](./core_package_intrinsics.md#float64) - 返回参数中的最大值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.max 静态方法
    let a: Float64 = 1.5f64
    let b: Float64 = 2.7f64
    let c: Float64 = 0.8f64
    let d: Float64 = 3.2f64

    // 使用 max 方法找出最大值
    let maxValue = Float64.max(a, b, [c, d])
    println("Float64.max(1.5, 2.7, [0.8, 3.2]) 的结果: ${maxValue}")

    // 验证结果
    println("最大值是否正确: ${maxValue == d}")
}
```

运行结果：

```text
Float64.max(1.5, 2.7, [0.8, 3.2]) 的结果: 3.200000
最大值是否正确: true
```

#### static func min(Float64, Float64, Array\<Float64>)

```cangjie
public static func min(a: Float64, b: Float64, others: Array<Float64>): Float64
```

功能：返回一组[Float64](./core_package_intrinsics.md#float64)中的最小值，此函数的第三个参数是一个变长参数，可以获取二个以上的[Float64](./core_package_intrinsics.md#float64)最小值，如果参数中有 `NaN`，该函数会返回 `NaN`。

参数：

- a: [Float64](./core_package_intrinsics.md#float64) - 第一个待比较的数。
- b: [Float64](./core_package_intrinsics.md#float64) - 第二个待比较的数。
- others: [Array](core_package_structs.md#struct-arrayt)\<[Float64](./core_package_intrinsics.md#float64)> - 其他待比较的数。

返回值：

- [Float64](./core_package_intrinsics.md#float64) - 返回参数中的最小值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.min 静态方法
    let a: Float64 = 1.5f64
    let b: Float64 = 2.7f64
    let c: Float64 = 0.8f64
    let d: Float64 = 3.2f64

    // 使用 min 方法找出最小值
    let minValue = Float64.min(a, b, [c, d])
    println("Float64.min(1.5, 2.7, [0.8, 3.2]) 的结果: ${minValue}")

    // 验证结果
    println("最小值是否正确: ${minValue == c}")
}
```

运行结果：

```text
Float64.min(1.5, 2.7, [0.8, 3.2]) 的结果: 0.800000
最小值是否正确: true
```

#### func isInf()

```cangjie
public func isInf(): Bool
```

功能：判断某个浮点数 [Float64](./core_package_intrinsics.md#float64) 是否为无穷数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float64](./core_package_intrinsics.md#float64) 的值正无穷大或负无穷大，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.isInf 方法
    let normalValue: Float64 = 1.5f64
    let infValue = Float64.Inf
    let negInfValue = -Float64.Inf

    // 检查普通值是否为无穷
    println("1.5f64.isInf() 的结果: ${normalValue.isInf()}")

    // 检查正无穷是否为无穷
    println("Float64.Inf.isInf() 的结果: ${infValue.isInf()}")

    // 检查负无穷是否为无穷
    println("(-Float64.Inf).isInf() 的结果: ${negInfValue.isInf()}")
}
```

运行结果：

```text
1.5f64.isInf() 的结果: false
Float64.Inf.isInf() 的结果: true
(-Float64.Inf).isInf() 的结果: true
```

#### func isNaN()

```cangjie
public func isNaN(): Bool
```

功能：判断某个浮点数 [Float64](./core_package_intrinsics.md#float64) 是否为非数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float64](./core_package_intrinsics.md#float64) 的值为非数值，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.isNaN 方法
    let normalValue: Float64 = 1.5f64
    let nanValue = Float64.NaN

    // 检查普通值是否为 NaN
    println("1.5f64.isNaN() 的结果: ${normalValue.isNaN()}")

    // 检查 NaN 值是否为 NaN
    println("Float64.NaN.isNaN() 的结果: ${nanValue.isNaN()}")
}
```

运行结果：

```text
1.5f64.isNaN() 的结果: false
Float64.NaN.isNaN() 的结果: true
```

#### func isNormal()

```cangjie
public func isNormal(): Bool
```

功能：判断某个浮点数 [Float64](./core_package_intrinsics.md#float64) 是否为常规数值。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果 [Float64](./core_package_intrinsics.md#float64) 的值是正常的浮点数，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.isNormal 方法
    let normalValue: Float64 = 1.5f64
    let zeroValue: Float64 = 0.0f64
    let infValue = Float64.Inf
    let nanValue = Float64.NaN

    // 检查普通值是否为常规数值
    println("1.5f64.isNormal() 的结果: ${normalValue.isNormal()}")

    // 检查零值是否为常规数值
    println("0.0f64.isNormal() 的结果: ${zeroValue.isNormal()}")

    // 检查无穷值是否为常规数值
    println("Float64.Inf.isNormal() 的结果: ${infValue.isNormal()}")

    // 检查 NaN 值是否为常规数值
    println("Float64.NaN.isNormal() 的结果: ${nanValue.isNormal()}")
}
```

运行结果：

```text
1.5f64.isNormal() 的结果: true
0.0f64.isNormal() 的结果: false
Float64.Inf.isNormal() 的结果: false
Float64.NaN.isNormal() 的结果: false
```

### extend Float64

```cangjie
extend Float64
```

功能：支持与 [UInt64](core_package_intrinsics.md#uint64) 互相转换。

#### static func fromBits(UInt64)

```cangjie
public static func fromBits(bits: UInt64): Float64
```

功能：将指定的 [UInt64](core_package_intrinsics.md#uint64)按照 `IEEE 754` 标准中 float64 的二进制位表示形式，直接转换为对应的[Float64](core_package_intrinsics.md#float64)浮点数。

参数：

- bits: [UInt64](core_package_intrinsics.md#uint64) - 要转换的数字。

返回值：

- [Float64](core_package_intrinsics.md#float64) - 转换结果，其位与参数 bits 值相同。

示例：

<!-- verify -->
```cangjie
main() {
    let v = Float64.fromBits(0x402BC28F5C28F5C3u64)
    println(v)
}
```

运行结果：

```text
13.880000
```

#### func toBits()

```cangjie
public func toBits(): UInt64
```

功能：将指定的 Float64 数转换为以位表示的对应 [UInt64](core_package_intrinsics.md#uint64) 数。

返回值：

- [UInt64](core_package_intrinsics.md#uint64) - 转换结果，其值与 [Float64](core_package_intrinsics.md#float64) 的位表示相同。

示例：

<!-- verify -->
```cangjie
main() {
    println(13.88f64.toBits()) // 0x402BC28F5C28F5C3 4624003363408246211
}
```

运行结果：

```text
4624003363408246211
```

### extend Float64 <: Comparable\<Float64>

```cangjie
extend Float64 <: Comparable<Float64>
```

功能：为 [Float64](core_package_intrinsics.md#float64) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float64](core_package_intrinsics.md#float64)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Float64](#float64)>

#### func compare(Float64)

```cangjie
public func compare(other: Float64): Ordering
```

功能：判断当前 [Float64](core_package_intrinsics.md#float64) 值与指定 [Float64](core_package_intrinsics.md#float64) 值的大小关系。`NaN` 无法参与比较，返回值无意义。

参数：

- other: [Float64](core_package_intrinsics.md#float64) - 待比较的另一个 [Float64](core_package_intrinsics.md#float64) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Float64 = 0.12
    var num2: Float64 = 0.234
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Float64 <: Hashable

```cangjie
extend Float64 <: Hashable
```

功能：为 [Float64](core_package_intrinsics.md#float64) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.hashCode 方法
    let value1: Float64 = 1.5f64
    let value2: Float64 = 1.5f64
    let value3: Float64 = 2.0f64

    // 计算哈希值
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()

    println("1.5f64 的哈希值: ${hash1}")
    println("1.5f64 的哈希值: ${hash2}")
    println("2.0f64 的哈希值: ${hash3}")

    // 验证相等的值具有相同的哈希值
    println("相等值的哈希值是否相同: ${hash1 == hash2}")
}
```

运行结果：

```text
1.5f64 的哈希值: -991904502584296975
1.5f64 的哈希值: -991904502584296975
2.0f64 的哈希值: 8889205371494514623
相等值的哈希值是否相同: true
```

### extend Float64 <: ToString

```cangjie
extend Float64 <: ToString
```

功能：为 [Float64](core_package_intrinsics.md#float64) 类型其扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。默认保留 6 位小数。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Float64](core_package_intrinsics.md#float64) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64.toString 方法
    let value1: Float64 = 1.5f64
    let value2: Float64 = 123.456f64
    let value3: Float64 = -0.001f64

    // 转换为字符串
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()

    println("1.5f64 转换为字符串: \"${str1}\"")
    println("123.456f64 转换为字符串: \"${str2}\"")
    println("-0.001f64 转换为字符串: \"${str3}\"")

    // 验证类型
    println("转换后的类型是否为 String: ${str1 is String}")
}
```

运行结果：

```text
1.5f64 转换为字符串: "1.500000"
123.456f64 转换为字符串: "123.456000"
-0.001f64 转换为字符串: "-0.001000"
转换后的类型是否为 String: true
```

## Int16

功能：表示 16 位有符号整型，表示范围为 [-2^{15}, 2^{15} - 1]。

### extend Int16

```cangjie
extend Int16
```

功能：拓展 16 位有符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: Int16
```

功能：获取 16 位有符号整数的最大值。

类型：[Int16](./core_package_intrinsics.md#int16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int16.Max 属性
    let maxValue = Int16.Max
    println("Int16.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Int16.Max 是否等于 32767: ${maxValue == 32767}")
}
```

运行结果：

```text
Int16.Max 的值: 32767
Int16.Max 是否等于 32767: true
```

#### static prop Min

```cangjie
public static prop Min: Int16
```

功能：获取 16 位有符号整数的最小值。

类型：[Int16](./core_package_intrinsics.md#int16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int16.Min 属性
    let minValue = Int16.Min
    println("Int16.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Int16.Min 是否等于 -32768: ${minValue == -32768}")
}
```

运行结果：

```text
Int16.Min 的值: -32768
Int16.Min 是否等于 -32768: true
```

### extend Int16 <: Comparable\<Int16>

```cangjie
extend Int16 <: Comparable<Int16>
```

功能：为 [Int16](core_package_intrinsics.md#int16) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int16](core_package_intrinsics.md#int16)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int16](#int16)>

#### func compare(Int16)

```cangjie
public func compare(other: Int16): Ordering
```

功能：判断当前 [Int16](core_package_intrinsics.md#int16) 值与指定 [Int16](core_package_intrinsics.md#int16) 值的大小关系。

参数：

- other: [Int16](core_package_intrinsics.md#int16) - 待比较的另一个 [Int16](core_package_intrinsics.md#int16) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 2
    var num2: Int16 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Int16 <: Countable\<Int16>

```cangjie
extend Int16 <: Countable<Int16>
```

功能：为 [Int16](core_package_intrinsics.md#int16) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[Int16](core_package_intrinsics.md#int16)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int16](#int16)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int16
```

功能：获取在数轴上当前 [Int16](core_package_intrinsics.md#int16) 位置往右移动 `right` 后对应位置的 [Int16](core_package_intrinsics.md#int16) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [Int16](core_package_intrinsics.md#int16) - 往右数 `right` 后所到位置的 [Int16](core_package_intrinsics.md#int16) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 32767
    var num2: Int16 = 3
    println(num1.next(5))
    println(num2.next(10))
}
```

运行结果：

```text
-32764
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [Int16](core_package_intrinsics.md#int16) 值的位置信息，即将该 [Int16](core_package_intrinsics.md#int16) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [Int16](core_package_intrinsics.md#int16) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 32767
    var num2: Int16 = 3
    println(num1.position())
    println(num2.position())
}
```

运行结果：

```text
32767
3
```

### extend Int16 <: Hashable

```cangjie
extend Int16 <: Hashable
```

功能：为 [Int16](core_package_intrinsics.md#int16) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int16.hashCode 方法
    let value1: Int16 = 42
    let value2: Int16 = 42
    let value3: Int16 = -100

    // 计算哈希值
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()

    println("42 的哈希值: ${hash1}")
    println("42 的哈希值: ${hash2}")
    println("-100 的哈希值: ${hash3}")

    // 验证相等的值具有相同的哈希值
    println("相等值的哈希值是否相同: ${hash1 == hash2}")
}
```

运行结果：

```text
42 的哈希值: 42
42 的哈希值: 42
-100 的哈希值: -100
相等值的哈希值是否相同: true
```

### extend Int16 <: ToString

```cangjie
extend Int16 <: ToString
```

功能：这里为 [Int16](core_package_intrinsics.md#int16) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Int16](core_package_intrinsics.md#int16) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int16.toString 方法
    let value1: Int16 = 42
    let value2: Int16 = -123
    let value3: Int16 = 0

    // 转换为字符串
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()

    println("42 转换为字符串: \"${str1}\"")
    println("-123 转换为字符串: \"${str2}\"")
    println("0 转换为字符串: \"${str3}\"")

    // 验证类型
    println("转换后的类型是否为 String: ${str1 is String}")
}
```

运行结果：

```text
42 转换为字符串: "42"
-123 转换为字符串: "-123"
0 转换为字符串: "0"
转换后的类型是否为 String: true
```

## Int32

功能：表示 32 位有符号整型，表示范围为 [-2^{31}, 2^{31} - 1]。

### extend Int32

```cangjie
extend Int32
```

功能：拓展 32 位有符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: Int32
```

功能：获取 32 位有符号整数的最大值。

类型：[Int32](./core_package_intrinsics.md#int32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int32.Max 属性
    let maxValue = Int32.Max
    println("Int32.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Int32.Max 是否等于 2147483647: ${maxValue == 2147483647}")
}
```

运行结果：

```text
Int32.Max 的值: 2147483647
Int32.Max 是否等于 2147483647: true
```

#### static prop Min

```cangjie
public static prop Min: Int32
```

功能：获取 32 位有符号整数的最小值。

类型：[Int32](./core_package_intrinsics.md#int32)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int32.Min 属性
    let minValue = Int32.Min
    println("Int32.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Int32.Min 是否等于 -2147483648: ${minValue == -2147483648}")
}
```

运行结果：

```text
Int32.Min 的值: -2147483648
Int32.Min 是否等于 -2147483648: true
```

### extend Int32 <: Comparable\<Int32>

```cangjie
extend Int32 <: Comparable<Int32>
```

功能：为 [Int32](core_package_intrinsics.md#int32) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int32](core_package_intrinsics.md#int32)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int32](#int32)>

#### func compare(Int32)

```cangjie
public func compare(other: Int32): Ordering
```

功能：判断当前 [Int32](core_package_intrinsics.md#int32) 值与指定 [Int32](core_package_intrinsics.md#int32) 值的大小关系。

参数：

- other: [Int32](core_package_intrinsics.md#int32) - 待比较的另一个 [Int32](core_package_intrinsics.md#int32) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int32 = 8
    var num2: Int32 = 10
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Int32 <: Countable\<Int32>

```cangjie
extend Int32 <: Countable<Int32>
```

功能：为 [Int32](core_package_intrinsics.md#int32) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[Int32](core_package_intrinsics.md#int32)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int32](#int32)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int32
```

功能：获取在数轴上当前 [Int32](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [Int32](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [Int32](core_package_intrinsics.md#int32) - 往右数 `right` 后所到位置的 [Int32](core_package_intrinsics.md#int32) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int32 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [Int32](core_package_intrinsics.md#int32) 值的位置信息，即将该 [Int32](core_package_intrinsics.md#int32) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [Int32](core_package_intrinsics.md#int32) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int32 = 3
    println(num.position())
}
```

运行结果：

```text
3
```

### extend Int32 <: Hashable

```cangjie
extend Int32 <: Hashable
```

功能：为 [Int32](core_package_intrinsics.md#int32) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int32.hashCode 方法
    let value1: Int32 = 42
    let value2: Int32 = 42
    let value3: Int32 = -100

    // 计算哈希值
    let hash1 = value1.hashCode()
    let hash2 = value2.hashCode()
    let hash3 = value3.hashCode()

    println("42 的哈希值: ${hash1}")
    println("42 的哈希值: ${hash2}")
    println("-100 的哈希值: ${hash3}")

    // 验证相等的值具有相同的哈希值
    println("相等值的哈希值是否相同: ${hash1 == hash2}")
}
```

运行结果：

```text
42 的哈希值: 42
42 的哈希值: 42
-100 的哈希值: -100
相等值的哈希值是否相同: true
```

### extend Int32 <: ToString

```cangjie
extend Int32 <: ToString
```

功能：这里为 [Int32](core_package_intrinsics.md#int32) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Int32](core_package_intrinsics.md#int32) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int32.toString 方法
    let value1: Int32 = 42
    let value2: Int32 = -123
    let value3: Int32 = 0

    // 转换为字符串
    let str1 = value1.toString()
    let str2 = value2.toString()
    let str3 = value3.toString()

    println("42 转换为字符串: \"${str1}\"")
    println("-123 转换为字符串: \"${str2}\"")
    println("0 转换为字符串: \"${str3}\"")

    // 验证类型
    println("转换后的类型是否为 String: ${str1 is String}")
}
```

运行结果：

```text
42 转换为字符串: "42"
-123 转换为字符串: "-123"
0 转换为字符串: "0"
转换后的类型是否为 String: true
```

## Int64

功能：表示 64 位有符号整型，表示范围为 [-2^{63}, 2^{63} - 1]。

### extend Int64

```cangjie
extend Int64
```

功能：拓展 64 位有符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: Int64
```

功能：获取 64 位有符号整数的最大值。

类型：[Int64](./core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int64.Max 属性
    let maxValue = Int64.Max
    println("Int64.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Int64.Max 是否等于 9223372036854775807: ${maxValue == 9223372036854775807}")
}
```

运行结果：

```text
Int64.Max 的值: 9223372036854775807
Int64.Max 是否等于 9223372036854775807: true
```

#### static prop Min

```cangjie
public static prop Min: Int64
```

功能：获取 64 位有符号整数的最小值。

类型：[Int64](./core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int64.Min 属性
    let minValue = Int64.Min
    println("Int64.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Int64.Min 是否等于 -9223372036854775808: ${minValue == -9223372036854775808}")
}
```

运行结果：

```text
Int64.Min 的值: -9223372036854775808
Int64.Min 是否等于 -9223372036854775808: true
```

### extend Int64 <: Comparable\<Int64>

```cangjie
extend Int64 <: Comparable<Int64>
```

功能：为 [Int64](core_package_intrinsics.md#int64) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int64](core_package_intrinsics.md#int64)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int64](#int64)>

#### func compare(Int64)

```cangjie
public func compare(other: Int64): Ordering
```

功能：判断当前 [Int64](core_package_intrinsics.md#int64) 值与指定 [Int64](core_package_intrinsics.md#int64) 值的大小关系。

参数：

- other: [Int64](core_package_intrinsics.md#int64) - 待比较的另一个 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ 如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int64 = 2
    var num2: Int64 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Int64 <: Countable\<Int64>

```cangjie
extend Int64 <: Countable<Int64>
```

功能：为 [Int64](core_package_intrinsics.md#int64) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[Int64](core_package_intrinsics.md#int64)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int64](#int64)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int64
```

功能：获取在数轴上当前 [Int64](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [Int64](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 往右数 `right` 后所到位置的 [Int64](core_package_intrinsics.md#int64) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int64 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [Int64](core_package_intrinsics.md#int64) 值的位置信息，即返回该 [Int64](core_package_intrinsics.md#int64) 值本身。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [Int64](core_package_intrinsics.md#int64) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int64 = 3
    println(num.position())
}
```

运行结果：

```text
3
```

### extend Int64 <: Hashable

```cangjie
extend Int64 <: Hashable
```

功能：为 [Int64](core_package_intrinsics.md#int64) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int64.hashCode() 方法
    let num: Int64 = 42
    let hash = num.hashCode()
    println("Int64 值: ${num}")
    println("hashCode: ${hash}")

    // 测试不同值的哈希码
    let negativeNum: Int64 = -42
    let negativeHash = negativeNum.hashCode()
    println("Int64 值: ${negativeNum}")
    println("hashCode: ${negativeHash}")

    // 测试零值
    let zero: Int64 = 0
    let zeroHash = zero.hashCode()
    println("Int64 值: ${zero}")
    println("hashCode: ${zeroHash}")
}
```

运行结果：

```text
Int64 值: 42
hashCode: 42
Int64 值: -42
hashCode: -42
Int64 值: 0
hashCode: 0
```

### extend Int64 <: ToString

```cangjie
extend Int64 <: ToString
```

功能：这里为 [Int64](core_package_intrinsics.md#int64) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Int64](core_package_intrinsics.md#int64) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int64.toString() 方法
    let num: Int64 = 42
    let str = num.toString()
    println("Int64 值: ${num}")
    println("转换为字符串: ${str}")

    // 测试负数
    let negativeNum: Int64 = -42
    let negativeStr = negativeNum.toString()
    println("Int64 值: ${negativeNum}")
    println("转换为字符串: ${negativeStr}")

    // 测试零值
    let zero: Int64 = 0
    let zeroStr = zero.toString()
    println("Int64 值: ${zero}")
    println("转换为字符串: ${zeroStr}")

    // 测试最大值和最小值
    let maxVal = Int64.Max
    let maxStr = maxVal.toString()
    println("Int64 最大值: ${maxVal}")
    println("转换为字符串: ${maxStr}")

    let minVal = Int64.Min
    let minStr = minVal.toString()
    println("Int64 最小值: ${minVal}")
    println("转换为字符串: ${minStr}")
}
```

运行结果：

```text
Int64 值: 42
转换为字符串: 42
Int64 值: -42
转换为字符串: -42
Int64 值: 0
转换为字符串: 0
Int64 最大值: 9223372036854775807
转换为字符串: 9223372036854775807
Int64 最小值: -9223372036854775808
转换为字符串: -9223372036854775808
```

## Int8

功能：表示 8 位有符号整型，表示范围为 [-2^7, 2^7 - 1]。

### extend Int8

```cangjie
extend Int8
```

功能：拓展 8 位有符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: Int8
```

功能：获取 8 位有符号整数的最大值。

类型：[Int8](./core_package_intrinsics.md#int8)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int8.Max 属性
    let maxValue = Int8.Max
    println("Int8.Max 的值: ${maxValue}")

    // 验证它确实是最大值
    println("Int8.Max 是否等于 127: ${maxValue == 127}")
}
```

运行结果：

```text
Int8.Max 的值: 127
Int8.Max 是否等于 127: true
```

#### static prop Min

```cangjie
public static prop Min: Int8
```

功能：获取 8 位有符号整数的最小值。

类型：[Int8](./core_package_intrinsics.md#int8)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int8.Min 属性
    let minValue = Int8.Min
    println("Int8.Min 的值: ${minValue}")

    // 验证它确实是最小值
    println("Int8.Min 是否等于 -128: ${minValue == -128}")
}
```

运行结果：

```text
Int8.Min 的值: -128
Int8.Min 是否等于 -128: true
```

### extend Int8 <: Comparable\<Int8>

```cangjie
extend Int8 <: Comparable<Int8>
```

功能：为 [Int8](core_package_intrinsics.md#int8) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int8](core_package_intrinsics.md#int8)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Int8](#int8)>

#### func compare(Int8)

```cangjie
public func compare(other: Int8): Ordering
```

功能：判断当前 [Int8](core_package_intrinsics.md#int8) 值与指定 [Int8](core_package_intrinsics.md#int8) 值的大小关系。

参数：

- other: [Int8](core_package_intrinsics.md#int8) - 待比较的另一个 [Int8](core_package_intrinsics.md#int8) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: Int8 = 2
    var num2: Int8 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Int8 <: Countable\<Int8>

```cangjie
extend Int8 <: Countable<Int8>
```

功能：为 [Int8](core_package_intrinsics.md#int8) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[Int8](core_package_intrinsics.md#int8)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[Int8](#int8)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Int8
```

功能：获取在数轴上当前 [Int8](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [Int8](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [Int8](core_package_intrinsics.md#int8) - 往右数 `right` 后所到位置的 [Int8](core_package_intrinsics.md#int8) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int8 = 3
    println(num.next(5))
}
```

运行结果：

```text
8
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [Int8](core_package_intrinsics.md#int8) 值的位置信息，即将该 [Int8](core_package_intrinsics.md#int8) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [Int8](core_package_intrinsics.md#int8) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: Int8 = 3
    println(num.position())
}
```

运行结果：

```text
3
```

### extend Int8 <: Hashable

```cangjie
extend Int8 <: Hashable
```

功能：为 [Int8](core_package_intrinsics.md#int8) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int8.hashCode() 方法
    let num: Int8 = 42
    let hash = num.hashCode()
    println("Int8 值: ${num}")
    println("hashCode: ${hash}")

    // 测试不同值的哈希码
    let negativeNum: Int8 = -42
    let negativeHash = negativeNum.hashCode()
    println("Int8 值: ${negativeNum}")
    println("hashCode: ${negativeHash}")

    // 测试零值
    let zero: Int8 = 0
    let zeroHash = zero.hashCode()
    println("Int8 值: ${zero}")
    println("hashCode: ${zeroHash}")

    // 测试最大值和最小值
    let maxVal = Int8.Max
    let maxHash = maxVal.hashCode()
    println("Int8 最大值: ${maxVal}")
    println("hashCode: ${maxHash}")

    let minVal = Int8.Min
    let minHash = minVal.hashCode()
    println("Int8 最小值: ${minVal}")
    println("hashCode: ${minHash}")
}
```

运行结果：

```text
Int8 值: 42
hashCode: 42
Int8 值: -42
hashCode: -42
Int8 值: 0
hashCode: 0
Int8 最大值: 127
hashCode: 127
Int8 最小值: -128
hashCode: -128
```

### extend Int8 <: ToString

```cangjie
extend Int8 <: ToString
```

功能：这里为 [Int8](core_package_intrinsics.md#int8) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Int8](core_package_intrinsics.md#int8) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int8.toString() 方法
    let num: Int8 = 42
    let str = num.toString()
    println("Int8 值: ${num}")
    println("转换为字符串: ${str}")

    // 测试负数
    let negativeNum: Int8 = -42
    let negativeStr = negativeNum.toString()
    println("Int8 值: ${negativeNum}")
    println("转换为字符串: ${negativeStr}")

    // 测试零值
    let zero: Int8 = 0
    let zeroStr = zero.toString()
    println("Int8 值: ${zero}")
    println("转换为字符串: ${zeroStr}")

    // 测试最大值和最小值
    let maxVal = Int8.Max
    let maxStr = maxVal.toString()
    println("Int8 最大值: ${maxVal}")
    println("转换为字符串: ${maxStr}")

    let minVal = Int8.Min
    let minStr = minVal.toString()
    println("Int8 最小值: ${minVal}")
    println("转换为字符串: ${minStr}")
}
```

运行结果：

```text
Int8 值: 42
转换为字符串: 42
Int8 值: -42
转换为字符串: -42
Int8 值: 0
转换为字符串: 0
Int8 最大值: 127
转换为字符串: 127
Int8 最小值: -128
转换为字符串: -128
```

## IntNative

功能：表示平台相关的有符号整型，其长度与当前系统的位宽一致。

### extend IntNative

```cangjie
extend IntNative
```

功能：拓展平台相关有符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: IntNative
```

功能：获取平台相关有符号整数的最大值。

类型：[IntNative](./core_package_intrinsics.md#intnative)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 IntNative.Max 属性
    let maxValue = IntNative.Max
    println("IntNative.Max 的值: ${maxValue}")

    // 验证它确实是最大值（在64位系统上应该是 9223372036854775807）
    println("IntNative.Max 是否等于 9223372036854775807: ${maxValue == 9223372036854775807}")
}
```

运行结果：

```text
IntNative.Max 的值: 9223372036854775807
IntNative.Max 是否等于 9223372036854775807: true
```

#### static prop Min

```cangjie
public static prop Min: IntNative
```

功能：获取平台相关有符号整数的最小值。

类型：[IntNative](./core_package_intrinsics.md#intnative)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 IntNative.Min 属性
    let minValue = IntNative.Min
    println("IntNative.Min 的值: ${minValue}")

    // 验证它确实是最小值（在64位系统上应该是 -9223372036854775808）
    println("IntNative.Min 是否等于 -9223372036854775808: ${minValue == -9223372036854775808}")
}
```

运行结果：

```text
IntNative.Min 的值: -9223372036854775808
IntNative.Min 是否等于 -9223372036854775808: true
```

### extend IntNative <: Comparable\<IntNative>

```cangjie
extend IntNative <: Comparable<IntNative>
```

功能：为 [IntNative](core_package_intrinsics.md#intnative) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[IntNative](core_package_intrinsics.md#intnative)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[IntNative](#intnative)>

#### func compare(IntNative)

```cangjie
public func compare(other: IntNative): Ordering
```

功能：判断当前 [IntNative](core_package_intrinsics.md#intnative) 值与指定 [IntNative](core_package_intrinsics.md#intnative) 值的大小关系。

参数：

- other: [IntNative](core_package_intrinsics.md#intnative) - 待比较的另一个 [IntNative](core_package_intrinsics.md#intnative) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: IntNative = 8
    var num2: IntNative = 10
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend IntNative <: Countable\<IntNative>

```cangjie
extend IntNative <: Countable<IntNative>
```

功能：为 [IntNative](core_package_intrinsics.md#intnative) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[IntNative](core_package_intrinsics.md#intnative)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[IntNative](#intnative)>

#### func next(Int64)

```cangjie
public func next(right: Int64): IntNative
```

功能：获取在数轴上当前 [IntNative](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [IntNative](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [IntNative](core_package_intrinsics.md#intnative) - 往右数 `right` 后所到位置的 [IntNative](core_package_intrinsics.md#intnative) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: IntNative = 8
    println(num.next(4))
}
```

运行结果：

```text
12
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [IntNative](core_package_intrinsics.md#intnative) 值的位置信息，即将该 [IntNative](core_package_intrinsics.md#intnative) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [IntNative](core_package_intrinsics.md#intnative) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: IntNative = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend IntNative <: Hashable

```cangjie
extend IntNative <: Hashable
```

功能：为 [IntNative](core_package_intrinsics.md#intnative) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 IntNative.hashCode() 方法
    let num: IntNative = 42
    let hash = num.hashCode()
    println("IntNative 值: ${num}")
    println("hashCode: ${hash}")

    // 测试不同值的哈希码
    let negativeNum: IntNative = -42
    let negativeHash = negativeNum.hashCode()
    println("IntNative 值: ${negativeNum}")
    println("hashCode: ${negativeHash}")

    // 测试零值
    let zero: IntNative = 0
    let zeroHash = zero.hashCode()
    println("IntNative 值: ${zero}")
    println("hashCode: ${zeroHash}")

    // 测试最大值和最小值
    let maxVal = IntNative.Max
    let maxHash = maxVal.hashCode()
    println("IntNative 最大值: ${maxVal}")
    println("hashCode: ${maxHash}")

    let minVal = IntNative.Min
    let minHash = minVal.hashCode()
    println("IntNative 最小值: ${minVal}")
    println("hashCode: ${minHash}")
}
```

运行结果：

```text
IntNative 值: 42
hashCode: 42
IntNative 值: -42
hashCode: -42
IntNative 值: 0
hashCode: 0
IntNative 最大值: 9223372036854775807
hashCode: 9223372036854775807
IntNative 最小值: -9223372036854775808
hashCode: -9223372036854775808
```

### extend IntNative <: ToString

```cangjie
extend IntNative <: ToString
```

功能：这里为 [IntNative](core_package_intrinsics.md#intnative) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [IntNative](core_package_intrinsics.md#intnative) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 IntNative.toString() 方法
    let num: IntNative = 42
    let str = num.toString()
    println("IntNative 值: ${num}")
    println("转换为字符串: ${str}")

    // 测试负数
    let negativeNum: IntNative = -42
    let negativeStr = negativeNum.toString()
    println("IntNative 值: ${negativeNum}")
    println("转换为字符串: ${negativeStr}")

    // 测试零值
    let zero: IntNative = 0
    let zeroStr = zero.toString()
    println("IntNative 值: ${zero}")
    println("转换为字符串: ${zeroStr}")

    // 测试最大值和最小值
    let maxVal = IntNative.Max
    let maxStr = maxVal.toString()
    println("IntNative 最大值: ${maxVal}")
    println("转换为字符串: ${maxStr}")

    let minVal = IntNative.Min
    let minStr = minVal.toString()
    println("IntNative 最小值: ${minVal}")
    println("转换为字符串: ${minStr}")
}
```

运行结果：

```text
IntNative 值: 42
转换为字符串: 42
IntNative 值: -42
转换为字符串: -42
IntNative 值: 0
转换为字符串: 0
IntNative 最大值: 9223372036854775807
转换为字符串: 9223372036854775807
IntNative 最小值: -9223372036854775808
转换为字符串: -9223372036854775808
```

## Rune

功能：表示 unicode 字符集中的字符。

表示范围为 `Unicode scalar value`，即从 `\u{0000}` 到 `\u{D7FF}`，以及从 `\u{E000}` 到 `\u{10FFF}` 的字符。

### extend Rune

```cangjie
extend Rune
```

功能：为 [Rune](core_package_intrinsics.md#rune) 类型实现一系列扩展方法，主要为在 Ascii 字符集范围内的一些字符判断、转换等操作。

#### static func fromUtf8(Array\<UInt8>, Int64)

```cangjie
public static func fromUtf8(arr: Array<UInt8>, index: Int64): (Rune, Int64)
```

功能：将字节数组中的指定元素，根据 UTF-8 编码规则转换成字符，并告知字符占用字节长度。

参数：

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 待转换字节所在的字节数组。
- index: [Int64](core_package_intrinsics.md#int64) - 待转换字节在数组中的下标。

返回值：

- ([Rune](core_package_intrinsics.md#rune), [Int64](core_package_intrinsics.md#int64)) - 转换得到的字符，以及该字符占用的字节长度。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 不合法的 UTF-8 字节序列。

示例：

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [4, 8, 65] // A <=> 65
    var tuple = Rune.fromUtf8(arr, 2)
    println(tuple[0]) // Rune
    println(tuple[1]) // len
}
```

运行结果：

```text
A
1
```

#### static func getPreviousFromUtf8(Array\<UInt8>, Int64)

```cangjie
public static func getPreviousFromUtf8(arr: Array<UInt8>, index: Int64): (Rune, Int64)
```

功能：获取字节数组中索引 `index` 前一个字节（即 `arr[index - 1]`）所在的 UTF-8 编码字符，同时返回该字符字节的长度。

函数从 `arr[index - 1]` 开始，根据 UTF-8 规则判断该字节是否为字符的首字节码，如果不是则继续向前遍历，直到找到首字节码，然后利用字节码序列解码对应的字符。参数 `index` 的有效取值范围为 `[1, arr.size]`。

参数：

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 待从中获取字符的字节数组。
- index: [Int64](core_package_intrinsics.md#int64) - 字节数组中的索引，函数将查找 `arr[index - 1]` 所在的字符，取值范围为 `[1, arr.size]`。

返回值：

- ([Rune](core_package_intrinsics.md#rune), [Int64](core_package_intrinsics.md#int64)) - 找到的字符，以及该字符字节码的长度。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 `index` 小于等于 0，不存在前一个字节，抛出异常；如果找不到对应首字节码，即 `arr[index - 1]` 所在位置的字节不符合 UTF-8 编码，抛出异常。
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 `index` 大于 `arr.size`，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个包含中文字符的字节数组
    var arr: Array<UInt8> = [72, 101, 108, 108, 111, 231, 136, 177] // "Hello爱" 的 UTF-8 编码
    println("字节数组: ${arr}")

    // 获取索引为 7（即中文字符"爱"的第二个字节）对应的字符
    var tuple = Rune.getPreviousFromUtf8(arr, 7)
    println("获取的字符: ${tuple[0]}")
    println("字符的字节长度: ${tuple[1]}")
}
```

运行结果：

```text
字节数组: [72, 101, 108, 108, 111, 231, 136, 177]
获取的字符: 爱
字符的字节长度: 3
```

#### static func intoUtf8Array(Rune, Array\<UInt8>, Int64)

```cangjie
public static func intoUtf8Array(c: Rune, arr: Array<UInt8>, index: Int64): Int64
```

功能：该函数会把字符转成字节码序列然后覆盖 [Array](core_package_structs.md#struct-arrayt) 数组内指定位置的字节码。

参数：

- c: [Rune](core_package_intrinsics.md#rune) - 待转换的字符。
- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 待覆盖的 [Array](core_package_structs.md#struct-arrayt) 数组。
- index: [Int64](core_package_intrinsics.md#int64) - 目标位置的起始索引。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 字符的字节码长度，例如中文是三个字节码长度。

示例：

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [1, 2, 3, 230, 136, 145]
    var len: Int64 = Rune.intoUtf8Array(r'爱', arr, 2)
    println(len)
    println(arr[2]) // 字符爱的utf-8编码的第一个字节
}
```

运行结果：

```text
3
231
```

#### static func utf8Size(Array\<UInt8>, Int64)

```cangjie
public static func utf8Size(arr: Array<UInt8>, index: Int64): Int64
```

功能：该函数会返回字节数组指定索引位置为起始的字符占用的字节数。

在 UTF-8 编码中，ASCII 码首位字节第一位不为 1，其他长度的字符首位字节开头 1 的个数表明了该字符对应的字节码长度，该函数通过扫描首位，判断字节码长度。如果索引对应的不是首位字节码，就会抛出异常。

参数：

- arr: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 待获取字符的字节数组。
- index: [Int64](core_package_intrinsics.md#int64) - 指定字符的索引。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 字符的字节码长度，例如中文是三个字节码长度。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果索引位置的字节码不符合首位字节码规则，会抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    var arr: Array<UInt8> = [1, 2, 231, 136, 177, 145]
    var len: Int64 = Rune.utf8Size(arr, 2)
    println(len) // 索引为2-4的数组元素为中文字符爱的utf-8编码，占用三字节
}
```

运行结果：

```text
3
```

#### static func utf8Size(Rune)

```cangjie
public static func utf8Size(c: Rune): Int64
```

功能：返回字符对应的 UTF-8 编码的字节码长度，例如中文字符的字节码长度是 3。

参数：

- c: [Rune](core_package_intrinsics.md#rune) - 待计算 UTF-8 字节码长度的字符。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 字符的 UTF-8 字节码长度。

示例：

<!-- verify -->
```cangjie
main() {
    var char: Rune = r'爱'
    var len: Int64 = Rune.utf8Size(char)
    println(len) // 中文字符爱的utf-8编码，占用三字节
}
```

运行结果：

```text
3
```

#### func isAscii()

```cangjie
public func isAscii(): Bool
```

功能：判断字符是否是 Ascii 中的字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAscii() 方法
    var asciiChar: Rune = r'A' // ASCII 字符
    var nonAsciiChar: Rune = r'爱' // 非 ASCII 字符

    println("字符 '${asciiChar}' 是 ASCII 字符吗? ${asciiChar.isAscii()}")
    println("字符 '${nonAsciiChar}' 是 ASCII 字符吗? ${nonAsciiChar.isAscii()}")
}
```

运行结果：

```text
字符 'A' 是 ASCII 字符吗? true
字符 '爱' 是 ASCII 字符吗? false
```

#### func isAsciiControl()

```cangjie
public func isAsciiControl(): Bool
```

功能：判断字符是否是 Ascii 控制字符。其取值范围为 [00, 1F] 和 {7F} 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 控制字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiControl() 方法
    var controlChar: Rune = r'\n' // ASCII 控制字符
    var nonControlChar: Rune = r'A' // 非控制字符

    println("字符 '${controlChar}' 是 ASCII 控制字符吗? ${controlChar.isAsciiControl()}")
    println("字符 '${nonControlChar}' 是 ASCII 控制字符吗? ${nonControlChar.isAsciiControl()}")
}
```

运行结果：

```text
字符 '
' 是 ASCII 控制字符吗? true
字符 'A' 是 ASCII 控制字符吗? false
```

#### func isAsciiGraphic()

```cangjie
public func isAsciiGraphic(): Bool
```

功能：判断字符是否是 Ascii 图形字符。其取值范围为 [21, 7E]。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 图形字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiGraphic() 方法
    var graphicChar: Rune = r'A' // ASCII 图形字符
    var nonGraphicChar: Rune = r'\n' // 非图形字符（控制字符）

    println("字符 '${graphicChar}' 是 ASCII 图形字符吗? ${graphicChar.isAsciiGraphic()}")
    println("字符 '${nonGraphicChar}' 是 ASCII 图形字符吗? ${nonGraphicChar.isAsciiGraphic()}")
}
```

运行结果：

```text
字符 'A' 是 ASCII 图形字符吗? true
字符 '
' 是 ASCII 图形字符吗? false
```

#### func isAsciiHex()

```cangjie
public func isAsciiHex(): Bool
```

功能：判断字符是否是 Ascii 十六进制字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 十六进制字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiHex() 方法
    var hexChar: Rune = r'A' // ASCII 十六进制字符
    var nonHexChar: Rune = r'G' // 非十六进制字符

    println("字符 '${hexChar}' 是 ASCII 十六进制字符吗? ${hexChar.isAsciiHex()}")
    println("字符 '${nonHexChar}' 是 ASCII 十六进制字符吗? ${nonHexChar.isAsciiHex()}")
}
```

运行结果：

```text
字符 'A' 是 ASCII 十六进制字符吗? true
字符 'G' 是 ASCII 十六进制字符吗? false
```

#### func isAsciiLetter()

```cangjie
public func isAsciiLetter(): Bool
```

功能：判断字符是否是 Ascii 字母字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 字母字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiLetter() 方法
    var letterChar: Rune = r'A' // ASCII 字母字符
    var nonLetterChar: Rune = r'1' // 非字母字符

    println("字符 '${letterChar}' 是 ASCII 字母字符吗? ${letterChar.isAsciiLetter()}")
    println("字符 '${nonLetterChar}' 是 ASCII 字母字符吗? ${nonLetterChar.isAsciiLetter()}")
}
```

运行结果：

```text
字符 'A' 是 ASCII 字母字符吗? true
字符 '1' 是 ASCII 字母字符吗? false
```

#### func isAsciiLowerCase()

```cangjie
public func isAsciiLowerCase(): Bool
```

功能：判断字符是否是 Ascii 小写字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 小写字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiLowerCase() 方法
    var lowerCaseChar: Rune = r'a' // ASCII 小写字符
    var upperCaseChar: Rune = r'A' // ASCII 大写字符

    println("字符 '${lowerCaseChar}' 是 ASCII 小写字符吗? ${lowerCaseChar.isAsciiLowerCase()}")
    println("字符 '${upperCaseChar}' 是 ASCII 小写字符吗? ${upperCaseChar.isAsciiLowerCase()}")
}
```

运行结果：

```text
字符 'a' 是 ASCII 小写字符吗? true
字符 'A' 是 ASCII 小写字符吗? false
```

#### func isAsciiNumber()

```cangjie
public func isAsciiNumber(): Bool
```

功能：判断字符是否是 Ascii 数字字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 数字字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiNumber() 方法
    var numberChar: Rune = r'1' // ASCII 数字字符
    var nonNumberChar: Rune = r'A' // 非数字字符

    println("字符 '${numberChar}' 是 ASCII 数字字符吗? ${numberChar.isAsciiNumber()}")
    println("字符 '${nonNumberChar}' 是 ASCII 数字字符吗? ${nonNumberChar.isAsciiNumber()}")
}
```

运行结果：

```text
字符 '1' 是 ASCII 数字字符吗? true
字符 'A' 是 ASCII 数字字符吗? false
```

#### func isAsciiNumberOrLetter()

```cangjie
public func isAsciiNumberOrLetter(): Bool
```

功能：判断字符是否是 Ascii 数字或拉丁字母字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 数字或拉丁字母字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiNumberOrLetter() 方法
    var numberChar: Rune = r'1' // ASCII 数字字符
    var letterChar: Rune = r'A' // ASCII 字母字符
    var specialChar: Rune = r'!' // 特殊字符

    println("字符 '${numberChar}' 是 ASCII 数字或字母字符吗? ${numberChar.isAsciiNumberOrLetter()}")
    println("字符 '${letterChar}' 是 ASCII 数字或字母字符吗? ${letterChar.isAsciiNumberOrLetter()}")
    println("字符 '${specialChar}' 是 ASCII 数字或字母字符吗? ${specialChar.isAsciiNumberOrLetter()}")
}
```

运行结果：

```text
字符 '1' 是 ASCII 数字或字母字符吗? true
字符 'A' 是 ASCII 数字或字母字符吗? true
字符 '!' 是 ASCII 数字或字母字符吗? false
```

#### func isAsciiOct()

```cangjie
public func isAsciiOct(): Bool
```

功能：判断字符是否是 Ascii 八进制字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 八进制字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiOct() 方法
    var octChar: Rune = r'7' // ASCII 八进制字符
    var nonOctChar: Rune = r'8' // 非八进制字符

    println("字符 '${octChar}' 是 ASCII 八进制字符吗? ${octChar.isAsciiOct()}")
    println("字符 '${nonOctChar}' 是 ASCII 八进制字符吗? ${nonOctChar.isAsciiOct()}")
}
```

运行结果：

```text
字符 '7' 是 ASCII 八进制字符吗? true
字符 '8' 是 ASCII 八进制字符吗? false
```

#### func isAsciiPunctuation()

```cangjie
public func isAsciiPunctuation(): Bool
```

功能：判断字符是否是 Ascii 标点符号字符。其取值范围为 [21, 2F]、[3A, 40]、[5B, 60] 和 [7B, 7E] 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 标点符号字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiPunctuation() 方法
    var punctuationChar: Rune = r'!' // ASCII 标点符号字符
    var nonPunctuationChar: Rune = r'A' // 非标点符号字符

    println("字符 '${punctuationChar}' 是 ASCII 标点符号字符吗? ${punctuationChar.isAsciiPunctuation()}")
    println("字符 '${nonPunctuationChar}' 是 ASCII 标点符号字符吗? ${nonPunctuationChar.isAsciiPunctuation()}")
}
```

运行结果：

```text
字符 '!' 是 ASCII 标点符号字符吗? true
字符 'A' 是 ASCII 标点符号字符吗? false
```

#### func isAsciiUpperCase()

```cangjie
public func isAsciiUpperCase(): Bool
```

功能：判断字符是否是 Ascii 大写字符。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 大写字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiUpperCase() 方法
    var upperCaseChar: Rune = r'A' // ASCII 大写字符
    var lowerCaseChar: Rune = r'a' // ASCII 小写字符

    println("字符 '${upperCaseChar}' 是 ASCII 大写字符吗? ${upperCaseChar.isAsciiUpperCase()}")
    println("字符 '${lowerCaseChar}' 是 ASCII 大写字符吗? ${lowerCaseChar.isAsciiUpperCase()}")
}
```

运行结果：

```text
字符 'A' 是 ASCII 大写字符吗? true
字符 'a' 是 ASCII 大写字符吗? false
```

#### func isAsciiWhiteSpace()

```cangjie
public func isAsciiWhiteSpace(): Bool
```

功能：判断字符是否是 Ascii 空白字符。其取值范围为 [09, 0D] 和 {20} 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是 Ascii 空白字符返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.isAsciiWhiteSpace() 方法
    var whiteSpaceChar: Rune = r' ' // ASCII 空白字符
    var nonWhiteSpaceChar: Rune = r'A' // 非空白字符

    println("字符 '${whiteSpaceChar}' 是 ASCII 空白字符吗? ${whiteSpaceChar.isAsciiWhiteSpace()}")
    println("字符 '${nonWhiteSpaceChar}' 是 ASCII 空白字符吗? ${nonWhiteSpaceChar.isAsciiWhiteSpace()}")
}
```

运行结果：

```text
字符 ' ' 是 ASCII 空白字符吗? true
字符 'A' 是 ASCII 空白字符吗? false
```

#### func toAsciiLowerCase()

```cangjie
public func toAsciiLowerCase(): Rune
```

功能：将字符转换为 Ascii 小写字符，如果无法转换则保持现状。

返回值：

- [Rune](core_package_intrinsics.md#rune) - 转换后的字符，如果无法转换则返回原来的 [Rune](core_package_intrinsics.md#rune)。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.toAsciiLowerCase() 方法
    var upperCaseChar: Rune = r'A' // ASCII 大写字符
    var lowerCaseChar: Rune = r'a' // ASCII 小写字符
    var nonLetterChar: Rune = r'1' // 非字母字符

    var convertedUpper = upperCaseChar.toAsciiLowerCase()
    var convertedLower = lowerCaseChar.toAsciiLowerCase()
    var convertedNonLetter = nonLetterChar.toAsciiLowerCase()

    println("大写字符 '${upperCaseChar}' 转换为小写: ${convertedUpper}")
    println("小写字符 '${lowerCaseChar}' 转换为小写: ${convertedLower}")
    println("非字母字符 '${nonLetterChar}' 转换为小写: ${convertedNonLetter}")
}
```

运行结果：

```text
大写字符 'A' 转换为小写: a
小写字符 'a' 转换为小写: a
非字母字符 '1' 转换为小写: 1
```

#### func toAsciiUpperCase()

```cangjie
public func toAsciiUpperCase(): Rune
```

功能：将字符转换为 Ascii 大写字符，如果无法转换则保持现状。

返回值：

- [Rune](core_package_intrinsics.md#rune) - 转换后的字符，如果无法转换则返回原来的 [Rune](core_package_intrinsics.md#rune)。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.toAsciiUpperCase() 方法
    var lowerCaseChar: Rune = r'a' // ASCII 小写字符
    var upperCaseChar: Rune = r'A' // ASCII 大写字符
    var nonLetterChar: Rune = r'1' // 非字母字符

    var convertedLower = lowerCaseChar.toAsciiUpperCase()
    var convertedUpper = upperCaseChar.toAsciiUpperCase()
    var convertedNonLetter = nonLetterChar.toAsciiUpperCase()

    println("小写字符 '${lowerCaseChar}' 转换为大写: ${convertedLower}")
    println("大写字符 '${upperCaseChar}' 转换为大写: ${convertedUpper}")
    println("非字母字符 '${nonLetterChar}' 转换为大写: ${convertedNonLetter}")
}
```

运行结果：

```text
小写字符 'a' 转换为大写: A
大写字符 'A' 转换为大写: A
非字母字符 '1' 转换为大写: 1
```

### extend Rune <: Comparable\<Rune>

```cangjie
extend Rune <: Comparable<Rune>
```

功能：为 [Rune](core_package_intrinsics.md#rune) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Rune](core_package_intrinsics.md#rune)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Rune](#rune)>

#### func compare(Rune)

```cangjie
public func compare(other: Rune): Ordering
```

功能：判断当前 [Rune](core_package_intrinsics.md#rune) 实例与指定 [Rune](core_package_intrinsics.md#rune) 实例的大小关系。

[Rune](core_package_intrinsics.md#rune) 的大小关系指的是它们对应的 unicode 码点的大小关系。

参数：

- other: [Rune](core_package_intrinsics.md#rune) - 待比较的另一个 [Rune](core_package_intrinsics.md#rune) 实例。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var char1: Rune = r'i'
    var char2: Rune = r'j'
    println(char1.compare(char2))
}
```

运行结果：

```text
Ordering.LT
```

### extend Rune <: Countable\<Rune>

```cangjie
extend Rune <: Countable<Rune>
```

功能：为 [Rune](core_package_intrinsics.md#rune) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[Rune](core_package_intrinsics.md#rune)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[Rune](#rune)>

#### func next(Int64)

```cangjie
public func next(right: Int64): Rune
```

功能：获取当前 [Rune](core_package_intrinsics.md#rune) 值往右数 `right` 后所到位置的 [Rune](core_package_intrinsics.md#rune) 值。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [Rune](core_package_intrinsics.md#rune) - 往右数 `right` 后所到位置的 [Rune](core_package_intrinsics.md#rune) 值。

异常：

- [OverflowException](core_package_exceptions.md#class-overflowexception) - 如果与 [Int64](core_package_intrinsics.md#int64) 数进行加法运算后为不合法的 Unicode 值，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.next 方法
    var char: Rune = r'A'
    var nextChar = char.next(1)
    println("字符: ${char}")
    println("下一个字符: ${nextChar}")

    // 测试向后移动
    var prevChar = char.next(-1)
    println("前一个字符: ${prevChar}")
}
```

运行结果：

```text
字符: A
下一个字符: B
前一个字符: @
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [Rune](core_package_intrinsics.md#rune) 值的位置信息，即将该 [Rune](core_package_intrinsics.md#rune) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [Rune](core_package_intrinsics.md#rune) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.position 方法
    var char: Rune = r'A'
    var position = char.position()
    println("字符: ${char}")
    println("Unicode码点位置: ${position}")

    // 测试中文字符
    var chineseChar: Rune = r'爱'
    var chinesePosition = chineseChar.position()
    println("字符: ${chineseChar}")
    println("Unicode码点位置: ${chinesePosition}")
}
```

运行结果：

```text
字符: A
Unicode码点位置: 65
字符: 爱
Unicode码点位置: 29233
```

### extend Rune <: Hashable

```cangjie
extend Rune <: Hashable
```

功能：为 [Rune](core_package_intrinsics.md#rune) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.hashCode 方法
    var char: Rune = r'A'
    var hash = char.hashCode()
    println("字符: ${char}")
    println("哈希值: ${hash}")

    // 测试中文字符
    var chineseChar: Rune = r'爱'
    var chineseHash = chineseChar.hashCode()
    println("字符: ${chineseChar}")
    println("哈希值: ${chineseHash}")
}
```

运行结果：

```text
字符: A
哈希值: 65
字符: 爱
哈希值: 29233
```

### extend Rune <: ToString

```cangjie
extend Rune <: ToString
```

功能：这里为 [Rune](core_package_intrinsics.md#rune) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Rune](core_package_intrinsics.md#rune) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Rune.toString 方法
    var char: Rune = r'A'
    var str = char.toString()
    println("字符: ${char}")
    println("转换为字符串: ${str}")

    // 测试中文字符
    var chineseChar: Rune = r'爱'
    var chineseStr = chineseChar.toString()
    println("字符: ${chineseChar}")
    println("转换为字符串: ${chineseStr}")
}
```

运行结果：

```text
字符: A
转换为字符串: A
字符: 爱
转换为字符串: 爱
```

## UInt16

功能：表示 16 位无符号整型，表示范围为 [0, 2^{16} - 1]。

### extend UInt16

```cangjie
extend UInt16
```

功能：拓展 16 位无符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: UInt16
```

功能：获取 16 位无符号整数的最大值。

类型：[UInt16](./core_package_intrinsics.md#uint16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 UInt16.Max 属性
    var maxVal = UInt16.Max
    println("UInt16的最大值: ${maxVal}")

    // 验证最大值是否正确
    if (maxVal == 65535) {
        println("验证通过: UInt16.Max 等于 65535")
    } else {
        println("验证失败: UInt16.Max 不等于 65535")
    }
}
```

运行结果：

```text
UInt16的最大值: 65535
验证通过: UInt16.Max 等于 65535
```

#### static prop Min

```cangjie
public static prop Min: UInt16
```

功能：获取 16 位无符号整数的最小值。

类型：[UInt16](./core_package_intrinsics.md#uint16)

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 UInt16.Min 属性
    var minVal = UInt16.Min
    println("UInt16的最小值: ${minVal}")

    // 验证最小值是否正确
    if (minVal == 0) {
        println("验证通过: UInt16.Min 等于 0")
    } else {
        println("验证失败: UInt16.Min 不等于 0")
    }
}
```

运行结果：

```text
UInt16的最小值: 0
验证通过: UInt16.Min 等于 0
```

### extend UInt16 <: Comparable\<UInt16>

```cangjie
extend UInt16 <: Comparable<UInt16>
```

功能：为 [UInt16](core_package_intrinsics.md#uint16) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt16](core_package_intrinsics.md#uint16)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt16](#uint16)>

#### func compare(UInt16)

```cangjie
public func compare(other: UInt16): Ordering
```

功能：判断当前 [UInt16](core_package_intrinsics.md#uint16) 值与指定 [UInt16](core_package_intrinsics.md#uint16) 值的大小关系。

参数：

- other: [UInt16](core_package_intrinsics.md#uint16) - 待比较的另一个 [UInt16](core_package_intrinsics.md#uint16) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: UInt16 = 2
    var num2: UInt16 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend UInt16 <: Countable\<UInt16>

```cangjie
extend UInt16 <: Countable<UInt16>
```

功能：为 [UInt16](core_package_intrinsics.md#uint16) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[UInt16](core_package_intrinsics.md#uint16)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt16](#uint16)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt16
```

功能：获取在数轴上当前 [UInt16](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [UInt16](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [UInt16](core_package_intrinsics.md#uint16) - 往右数 `right` 后所到位置的 [UInt16](core_package_intrinsics.md#uint16) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt16 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [UInt16](core_package_intrinsics.md#uint16) 值的位置信息，即将该 [UInt16](core_package_intrinsics.md#uint16) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [UInt16](core_package_intrinsics.md#uint16) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt16 = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend UInt16 <: Hashable

```cangjie
extend UInt16 <: Hashable
```

功能：为 [UInt16](core_package_intrinsics.md#uint16) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 UInt16.hashCode 方法
    var num: UInt16 = 42
    var hash = num.hashCode()
    println("UInt16值: ${num}")
    println("哈希值: ${hash}")

    // 测试最大值
    var maxNum: UInt16 = UInt16.Max
    var maxHash = maxNum.hashCode()
    println("最大UInt16值: ${maxNum}")
    println("哈希值: ${maxHash}")
}
```

运行结果：

```text
UInt16值: 42
哈希值: 42
最大UInt16值: 65535
哈希值: 65535
```

### extend UInt16 <: ToString

```cangjie
extend UInt16 <: ToString
```

功能：这里为 [UInt16](core_package_intrinsics.md#uint16) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [UInt16](core_package_intrinsics.md#uint16) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 UInt16.toString 方法
    var num: UInt16 = 42
    var str = num.toString()
    println("UInt16值: ${num}")
    println("转换为字符串: ${str}")

    // 测试最大值
    var maxNum: UInt16 = UInt16.Max
    var maxStr = maxNum.toString()
    println("最大UInt16值: ${maxNum}")
    println("转换为字符串: ${maxStr}")
}
```

运行结果：

```text
UInt16值: 42
转换为字符串: 42
最大UInt16值: 65535
转换为字符串: 65535
```

## UInt32

功能：表示 32 位无符号整型，表示范围为 [0, 2^{32} - 1]。

### extend UInt32

```cangjie
extend UInt32
```

功能：拓展 32 位无符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: UInt32
```

功能：获取 32 位无符号整数的最大值。

类型：[UInt32](./core_package_intrinsics.md#uint32)

示例：

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt32.Max
    println(maxValue)
}
```

运行结果：

```text
4294967295
```

#### static prop Min

```cangjie
public static prop Min: UInt32
```

功能：获取 32 位无符号整数的最小值。

类型：[UInt32](./core_package_intrinsics.md#uint32)

示例：

<!-- verify -->
```cangjie
main() {
    var minValue = UInt32.Min
    println(minValue)
}
```

运行结果：

```text
0
```

### extend UInt32 <: Comparable\<UInt32>

```cangjie
extend UInt32 <: Comparable<UInt32>
```

功能：为 [UInt32](core_package_intrinsics.md#uint32) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt32](core_package_intrinsics.md#uint32)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt32](#uint32)>

#### func compare(UInt32)

```cangjie
public func compare(other: UInt32): Ordering
```

功能：判断当前 [UInt32](core_package_intrinsics.md#uint32) 值与指定 [UInt32](core_package_intrinsics.md#uint32) 值的大小关系。

参数：

- other: [UInt32](core_package_intrinsics.md#uint32) - 待比较的另一个 [UInt32](core_package_intrinsics.md#uint32) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: UInt32 = 2
    var num2: UInt32 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend UInt32 <: Countable\<UInt32>

```cangjie
extend UInt32 <: Countable<UInt32>
```

功能：为 [UInt32](core_package_intrinsics.md#uint32) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[UInt32](core_package_intrinsics.md#uint32)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt32](#uint32)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt32
```

功能：获取在数轴上当前 [UInt32](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [UInt32](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [UInt32](core_package_intrinsics.md#uint32) - 往右数 `right` 后所到位置的 [UInt32](core_package_intrinsics.md#uint32) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [UInt32](core_package_intrinsics.md#uint32) 值的位置信息，即将该 [UInt32](core_package_intrinsics.md#uint32) 转换为 [UInt64](core_package_intrinsics.md#uint64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [UInt32](core_package_intrinsics.md#uint32) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend UInt32 <: Hashable

```cangjie
extend UInt32 <: Hashable
```

功能：为 [UInt32](core_package_intrinsics.md#uint32) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 42
    var hash = num.hashCode()
    println(hash)
}
```

运行结果：

```text
42
```

### extend UInt32 <: ToString

```cangjie
extend UInt32 <: ToString
```

功能：这里为 [UInt32](core_package_intrinsics.md#uint32) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [UInt32](core_package_intrinsics.md#uint32) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt32 = 42
    var str = num.toString()
    println(str)
}
```

运行结果：

```text
42
```

## UInt64

功能：表示 64 位无符号整型，表示范围为 [0, 2^{64} - 1]。

### extend UInt64

```cangjie
extend UInt64
```

功能：拓展 64 位无符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: UInt64
```

功能：获取 64 位无符号整数的最大值。

类型：[UInt64](./core_package_intrinsics.md#uint64)

示例：

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt64.Max
    println(maxValue)
}
```

运行结果：

```text
18446744073709551615
```

#### static prop Min

```cangjie
public static prop Min: UInt64
```

功能：获取 64 位无符号整数的最小值。

类型：[UInt64](./core_package_intrinsics.md#uint64)

示例：

<!-- verify -->
```cangjie
main() {
    var minValue = UInt64.Min
    println(minValue)
}
```

运行结果：

```text
0
```

### extend UInt64 <: Comparable\<UInt64>

```cangjie
extend UInt64 <: Comparable<UInt64>
```

功能：为 [UInt64](core_package_intrinsics.md#uint64) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt64](core_package_intrinsics.md#uint64)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt64](#uint64)>

#### func compare(UInt64)

```cangjie
public func compare(other: UInt64): Ordering
```

功能：判断当前 [UInt64](core_package_intrinsics.md#uint64) 值与指定 [UInt64](core_package_intrinsics.md#uint64) 值的大小关系。

参数：

- other: [UInt64](core_package_intrinsics.md#uint64) - 待比较的另一个 [UInt64](core_package_intrinsics.md#uint64) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: UInt64 = 2
    var num2: UInt64 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend UInt64 <: Countable\<UInt64>

```cangjie
extend UInt64 <: Countable<UInt64>
```

功能：为 [UInt64](core_package_intrinsics.md#uint64) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[UInt64](core_package_intrinsics.md#uint64)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt64](#uint64)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt64
```

功能：获取在数轴上当前 [UInt64](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [UInt64](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [UInt64](core_package_intrinsics.md#uint64) - 往右数 `right` 后所到位置的 [UInt64](core_package_intrinsics.md#uint64) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [UInt64](core_package_intrinsics.md#uint64) 值的位置信息，即将该 [UInt64](core_package_intrinsics.md#uint64) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [UInt64](core_package_intrinsics.md#uint64) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend UInt64 <: Hashable

```cangjie
extend UInt64 <: Hashable
```

功能：为 [UInt64](core_package_intrinsics.md#uint64) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 42
    var hash = num.hashCode()
    println(hash)
}
```

运行结果：

```text
42
```

### extend UInt64 <: ToString

```cangjie
extend UInt64 <: ToString
```

功能：这里为 [UInt64](core_package_intrinsics.md#uint64) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [UInt64](core_package_intrinsics.md#uint64) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt64 = 42
    var str = num.toString()
    println(str)
}
```

运行结果：

```text
42
```

## UInt8

功能：表示 8 位无符号整型，表示范围为 [0, 2^8 - 1]。

### extend UInt8

```cangjie
extend UInt8
```

功能：拓展 8 位无符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: UInt8
```

功能：获取 8 位无符号整数的最大值。

类型：[UInt8](./core_package_intrinsics.md#uint8)

示例：

<!-- verify -->
```cangjie
main() {
    var maxValue = UInt8.Max
    println(maxValue)
}
```

运行结果：

```text
255
```

#### static prop Min

```cangjie
public static prop Min: UInt8
```

功能：获取 8 位无符号整数的最小值。

类型：[UInt8](./core_package_intrinsics.md#uint8)

示例：

<!-- verify -->
```cangjie
main() {
    var minValue = UInt8.Min
    println(minValue)
}
```

运行结果：

```text
0
```

### extend UInt8 <: Comparable\<UInt8>

```cangjie
extend UInt8 <: Comparable<UInt8>
```

功能：为 [UInt8](core_package_intrinsics.md#uint8) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt8](core_package_intrinsics.md#uint8)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UInt8](#uint8)>

#### func compare(UInt8)

```cangjie
public func compare(other: UInt8): Ordering
```

功能：判断当前 [UInt8](core_package_intrinsics.md#uint8) 值与指定 [UInt8](core_package_intrinsics.md#uint8) 值的大小关系。

参数：

- other: [UInt8](core_package_intrinsics.md#uint8) - 待比较的另一个 [UInt8](core_package_intrinsics.md#uint8) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: UInt8 = 2
    var num2: UInt8 = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend UInt8 <: Countable\<UInt8>

```cangjie
extend UInt8 <: Countable<UInt8>
```

功能：为 [UInt8](core_package_intrinsics.md#uint8) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[UInt8](core_package_intrinsics.md#uint8)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[UInt8](#uint8)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UInt8
```

功能：获取在数轴上当前 [UInt8](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [UInt8](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [UInt8](core_package_intrinsics.md#uint8) - 往右数 `right` 后所到位置的 [UInt8](core_package_intrinsics.md#uint8) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [UInt8](core_package_intrinsics.md#uint8) 值的位置信息，即将该 [UInt8](core_package_intrinsics.md#uint8) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [UInt8](core_package_intrinsics.md#uint8) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend UInt8 <: Hashable

```cangjie
extend UInt8 <: Hashable
```

功能：为 [UInt8](core_package_intrinsics.md#uint8) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 42
    var hash = num.hashCode()
    println(hash)
}
```

运行结果：

```text
42
```

### extend UInt8 <: ToString

```cangjie
extend UInt8 <: ToString
```

功能：这里为 [UInt8](core_package_intrinsics.md#uint8) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [UInt8](core_package_intrinsics.md#uint8) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UInt8 = 42
    var str = num.toString()
    println(str)
}
```

运行结果：

```text
42
```

## UIntNative

功能：表示平台相关的无符号整型，其长度与当前系统的位宽一致。

### extend UIntNative

```cangjie
extend UIntNative
```

功能：拓展平台相关无符号整数以支持一些数学常数。

#### static prop Max

```cangjie
public static prop Max: UIntNative
```

功能：获取平台相关无符号整数的最大值。

类型：[UIntNative](./core_package_intrinsics.md#uintnative)

示例：

<!-- verify -->
```cangjie
main() {
    var maxValue = UIntNative.Max
    println(maxValue)
}
```

运行结果：

```text
18446744073709551615
```

#### static prop Min

```cangjie
public static prop Min: UIntNative
```

功能：获取平台相关无符号整数的最小值。

类型：[UIntNative](./core_package_intrinsics.md#uintnative)

示例：

<!-- verify -->
```cangjie
main() {
    var minValue = UIntNative.Min
    println(minValue)
}
```

运行结果：

```text
0
```

### extend UIntNative <: Comparable\<UIntNative>

```cangjie
extend UIntNative <: Comparable<UIntNative>
```

功能：为 [UIntNative](core_package_intrinsics.md#uintnative) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[UIntNative](core_package_intrinsics.md#uintnative)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[UIntNative](#uintnative)>

#### func compare(UIntNative)

```cangjie
public func compare(other: UIntNative): Ordering
```

功能：判断当前 [UIntNative](core_package_intrinsics.md#uintnative) 值与指定 [UIntNative](core_package_intrinsics.md#uintnative) 值的大小关系。

参数：

- other: [UIntNative](core_package_intrinsics.md#uintnative) - 待比较的另一个 [UIntNative](core_package_intrinsics.md#uintnative) 值。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    var num1: UIntNative = 2
    var num2: UIntNative = 3
    println(num1.compare(num2))
}
```

运行结果：

```text
Ordering.LT
```

### extend UIntNative <: Countable

```cangjie
extend UIntNative <: Countable<UIntNative>
```

功能：为 [UIntNative](core_package_intrinsics.md#uintnative) 类型扩展 [Countable](core_package_interfaces.md#interface-countablet)\<[UIntNative](core_package_intrinsics.md#uintnative)> 接口，支持计数操作。

父类型：

- [Countable](core_package_interfaces.md#interface-countablet)\<[UIntNative](#uintnative)>

#### func next(Int64)

```cangjie
public func next(right: Int64): UIntNative
```

功能：获取在数轴上当前 [UIntNative](core_package_intrinsics.md#int32) 位置往右移动 `right` 后对应位置的 [UIntNative](core_package_intrinsics.md#int32) 值。如果值溢出，则会从数轴最左边继续移动。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- [UIntNative](core_package_intrinsics.md#uintnative) - 往右数 `right` 后所到位置的 [UIntNative](core_package_intrinsics.md#uintnative) 值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 3
    println(num.next(10))
}
```

运行结果：

```text
13
```

#### func position()

```cangjie
public func position(): Int64
```

功能：获取当前 [UIntNative](core_package_intrinsics.md#uintnative) 值的位置信息，即将该 [UIntNative](core_package_intrinsics.md#uintnative) 转换为 [Int64](core_package_intrinsics.md#int64) 值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 当前 [UIntNative](core_package_intrinsics.md#uintnative) 值的位置信息。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 8
    println(num.position())
}
```

运行结果：

```text
8
```

### extend UIntNative <: Hashable

```cangjie
extend UIntNative <: Hashable
```

功能：为 [UIntNative](core_package_intrinsics.md#uintnative) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 42
    var hash = num.hashCode()
    println(hash)
}
```

运行结果：

```text
42
```

### extend UIntNative <: ToString

```cangjie
extend UIntNative <: ToString
```

功能：这里为 [UIntNative](core_package_intrinsics.md#uintnative) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [UIntNative](core_package_intrinsics.md#uintnative) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var num: UIntNative = 12345
    var str = num.toString()
    println("The string representation is: " + str)
}
```

运行结果：

```text
The string representation is: 12345
```

## Unit

功能：表示仓颉语言中只关心副作用而不关心值的表达式的类型。

例如，print 函数、赋值表达式、复合赋值表达式、自增和自减表达式、循环表达式，它们的类型都是 [Unit](core_package_intrinsics.md#unit)。

[Unit](core_package_intrinsics.md#unit) 类型只有一个值，也是它的字面量：()。除了赋值、判等和判不等外，[Unit](core_package_intrinsics.md#unit) 类型不支持其他操作。

### extend Unit <: Equatable\<Unit>

```cangjie
extend Unit <: Equatable<Unit>
```

功能：为 [Unit](core_package_intrinsics.md#unit) 类型扩展 [Equatable](core_package_interfaces.md#interface-equatablet)\<[Unit](core_package_intrinsics.md#unit)> 接口。

父类型：

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Unit](#unit)>

### extend Unit <: Hashable

```cangjie
extend Unit <: Hashable
```

功能：为 [Unit](core_package_intrinsics.md#unit) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值，[Unit](core_package_intrinsics.md#unit) 的哈希值为 0。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    var unitValue = ()
    var hash = unitValue.hashCode()
    println(hash)
}
```

运行结果：

```text
0
```

### extend Unit <: ToString

```cangjie
extend Unit <: ToString
```

功能：为 [Unit](core_package_intrinsics.md#unit) 类型其扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，实现向 [String](core_package_structs.md#struct-string) 类型的转换。

[Unit](core_package_intrinsics.md#unit) 的字符串表示是 "()"。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Unit](core_package_intrinsics.md#unit) 值转换为可输出的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var unitValue = ()
    var str = unitValue.toString()
    println("The string representation is: " + str)
}
```

运行结果：

```text
The string representation is: ()
```
