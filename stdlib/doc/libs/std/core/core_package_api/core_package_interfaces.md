# 接口

## interface Any

```cangjie
public interface Any {}
```

功能：[Any](core_package_interfaces.md#interface-any) 是所有类型的父类型，所有 `interface` 都默认继承它，所有非 `interface` 类型都默认实现它。

### extend Byte

```cangjie
extend Byte
```

功能：为 [Byte](core_package_types.md#type-byte) 类型实现一系列扩展方法，主要为在 Ascii 字符集范围内的一些字符判断、转换等操作。

#### func isAscii()

```cangjie
public func isAscii(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAscii() 方法
    let byte1: Byte = 65 // 'A' 的 ASCII 值
    let byte2: Byte = 200 // 超出 ASCII 范围的值

    println("byte1 (${byte1}) 是否在 ASCII 范围内: ${byte1.isAscii()}")
    println("byte2 (${byte2}) 是否在 ASCII 范围内: ${byte2.isAscii()}")
}
```

运行结果：

```text
byte1 (65) 是否在 ASCII 范围内: true
byte2 (200) 是否在 ASCII 范围内: false
```

#### func isAsciiControl()

```cangjie
public func isAsciiControl(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 控制字符范围内。其取值范围为 [00, 1F] 和 {7F} 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 控制字符范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiControl() 方法
    let byte1: Byte = 0x09 // 制表符 '\t'，属于 ASCII 控制字符
    let byte2: Byte = 0x20 // 空格 ' '，不属于 ASCII 控制字符
    let byte3: Byte = 0x7F // DEL，属于 ASCII 控制字符

    println("byte1 (0x${byte1}) 是否是 ASCII 控制字符: ${byte1.isAsciiControl()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 控制字符: ${byte2.isAsciiControl()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 控制字符: ${byte3.isAsciiControl()}")
}
```

运行结果：

```text
byte1 (0x9) 是否是 ASCII 控制字符: true
byte2 (0x32) 是否是 ASCII 控制字符: false
byte3 (0x127) 是否是 ASCII 控制字符: true
```

#### func isAsciiGraphic()

```cangjie
public func isAsciiGraphic(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 图形字符范围内。其取值范围为 [21, 7E]。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 图形字符范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiGraphic() 方法
    let byte1: Byte = 0x21 // '!'，属于 ASCII 图形字符
    let byte2: Byte = 0x7E // '~'，属于 ASCII 图形字符
    let byte3: Byte = 0x20 // ' '，空格，不属于 ASCII 图形字符

    println("byte1 (0x${byte1}) 是否是 ASCII 图形字符: ${byte1.isAsciiGraphic()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 图形字符: ${byte2.isAsciiGraphic()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 图形字符: ${byte3.isAsciiGraphic()}")
}
```

运行结果：

```text
byte1 (0x33) 是否是 ASCII 图形字符: true
byte2 (0x126) 是否是 ASCII 图形字符: true
byte3 (0x32) 是否是 ASCII 图形字符: false
```

#### func isAsciiHex()

```cangjie
public func isAsciiHex(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 十六进制数字范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 十六进制数字范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiHex() 方法
    let byte1: Byte = 0x30 // '0'，属于 ASCII 十六进制数字
    let byte2: Byte = 0x46 // 'F'，属于 ASCII 十六进制数字
    let byte3: Byte = 0x67 // 'g'，不属于 ASCII 十六进制数字

    println("byte1 (0x${byte1}) 是否是 ASCII 十六进制数字: ${byte1.isAsciiHex()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 十六进制数字: ${byte2.isAsciiHex()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 十六进制数字: ${byte3.isAsciiHex()}")
}
```

运行结果：

```text
byte1 (0x48) 是否是 ASCII 十六进制数字: true
byte2 (0x70) 是否是 ASCII 十六进制数字: true
byte3 (0x103) 是否是 ASCII 十六进制数字: false
```

#### func isAsciiLetter()

```cangjie
public func isAsciiLetter(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 拉丁字母范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 拉丁字母范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiLetter() 方法
    let byte1: Byte = 0x41 // 'A'，属于 ASCII 拉丁字母
    let byte2: Byte = 0x7A // 'z'，属于 ASCII 拉丁字母
    let byte3: Byte = 0x30 // '0'，数字，不属于 ASCII 拉丁字母

    println("byte1 (0x${byte1}) 是否是 ASCII 拉丁字母: ${byte1.isAsciiLetter()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 拉丁字母: ${byte2.isAsciiLetter()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 拉丁字母: ${byte3.isAsciiLetter()}")
}
```

运行结果：

```text
byte1 (0x65) 是否是 ASCII 拉丁字母: true
byte2 (0x122) 是否是 ASCII 拉丁字母: true
byte3 (0x48) 是否是 ASCII 拉丁字母: false
```

#### func isAsciiLowerCase()

```cangjie
public func isAsciiLowerCase(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 小写拉丁字母范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 小写拉丁字母范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiLowerCase() 方法
    let byte1: Byte = 0x61 // 'a'，属于 ASCII 小写拉丁字母
    let byte2: Byte = 0x7A // 'z'，属于 ASCII 小写拉丁字母
    let byte3: Byte = 0x41 // 'A'，大写字母，不属于 ASCII 小写拉丁字母

    println("byte1 (0x${byte1}) 是否是 ASCII 小写拉丁字母: ${byte1.isAsciiLowerCase()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 小写拉丁字母: ${byte2.isAsciiLowerCase()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 小写拉丁字母: ${byte3.isAsciiLowerCase()}")
}
```

运行结果：

```text
byte1 (0x97) 是否是 ASCII 小写拉丁字母: true
byte2 (0x122) 是否是 ASCII 小写拉丁字母: true
byte3 (0x65) 是否是 ASCII 小写拉丁字母: false
```

#### func isAsciiNumber()

```cangjie
public func isAsciiNumber(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 十进制数字范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 十进制数字范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiNumber() 方法
    let byte1: Byte = 0x30 // '0'，属于 ASCII 十进制数字
    let byte2: Byte = 0x39 // '9'，属于 ASCII 十进制数字
    let byte3: Byte = 0x41 // 'A'，字母，不属于 ASCII 十进制数字

    println("byte1 (0x${byte1}) 是否是 ASCII 十进制数字: ${byte1.isAsciiNumber()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 十进制数字: ${byte2.isAsciiNumber()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 十进制数字: ${byte3.isAsciiNumber()}")
}
```

运行结果：

```text
byte1 (0x48) 是否是 ASCII 十进制数字: true
byte2 (0x57) 是否是 ASCII 十进制数字: true
byte3 (0x65) 是否是 ASCII 十进制数字: false
```

#### func isAsciiNumberOrLetter()

```cangjie
public func isAsciiNumberOrLetter(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 十进制数字或拉丁字母范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 十进制数字或拉丁字母范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiNumberOrLetter() 方法
    let byte1: Byte = 0x30 // '0'，数字，属于 ASCII 十进制数字和拉丁字母范围
    let byte2: Byte = 0x41 // 'A'，字母，属于 ASCII 十进制数字和拉丁字母范围
    let byte3: Byte = 0x20 // ' '，空格，不属于 ASCII 十进制数字和拉丁字母范围

    println("byte1 (0x${byte1}) 是否是 ASCII 十进制数字和拉丁字母: ${byte1.isAsciiNumberOrLetter()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 十进制数字和拉丁字母: ${byte2.isAsciiNumberOrLetter()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 十进制数字和拉丁字母: ${byte3.isAsciiNumberOrLetter()}")
}
```

运行结果：

```text
byte1 (0x48) 是否是 ASCII 十进制数字和拉丁字母: true
byte2 (0x65) 是否是 ASCII 十进制数字和拉丁字母: true
byte3 (0x32) 是否是 ASCII 十进制数字和拉丁字母: false
```

#### func isAsciiOct()

```cangjie
public func isAsciiOct(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 八进制数字范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 八进制数字范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiOct() 方法
    let byte1: Byte = 0x30 // '0'，属于 ASCII 八进制数字
    let byte2: Byte = 0x37 // '7'，属于 ASCII 八进制数字
    let byte3: Byte = 0x38 // '8'，不属于 ASCII 八进制数字

    println("byte1 (0x${byte1}) 是否是 ASCII 八进制数字: ${byte1.isAsciiOct()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 八进制数字: ${byte2.isAsciiOct()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 八进制数字: ${byte3.isAsciiOct()}")
}
```

运行结果：

```text
byte1 (0x48) 是否是 ASCII 八进制数字: true
byte2 (0x55) 是否是 ASCII 八进制数字: true
byte3 (0x56) 是否是 ASCII 八进制数字: false
```

#### func isAsciiPunctuation()

```cangjie
public func isAsciiPunctuation(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 标点符号范围内。其取值范围为 [21, 2F]、[3A, 40]、[5B, 60] 和 [7B, 7E] 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 标点符号范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiPunctuation() 方法
    let byte1: Byte = 0x21 // '!'，属于 ASCII 标点符号
    let byte2: Byte = 0x2C // ','，属于 ASCII 标点符号
    let byte3: Byte = 0x30 // '0'，数字，不属于 ASCII 标点符号

    println("byte1 (0x${byte1}) 是否是 ASCII 标点符号: ${byte1.isAsciiPunctuation()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 标点符号: ${byte2.isAsciiPunctuation()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 标点符号: ${byte3.isAsciiPunctuation()}")
}
```

运行结果：

```text
byte1 (0x33) 是否是 ASCII 标点符号: true
byte2 (0x44) 是否是 ASCII 标点符号: true
byte3 (0x48) 是否是 ASCII 标点符号: false
```

#### func isAsciiUpperCase()

```cangjie
public func isAsciiUpperCase(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 大写拉丁字母范围内。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 大写拉丁字母范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiUpperCase() 方法
    let byte1: Byte = 0x41 // 'A'，属于 ASCII 大写拉丁字母
    let byte2: Byte = 0x5A // 'Z'，属于 ASCII 大写拉丁字母
    let byte3: Byte = 0x61 // 'a'，小写字母，不属于 ASCII 大写拉丁字母

    println("byte1 (0x${byte1}) 是否是 ASCII 大写拉丁字母: ${byte1.isAsciiUpperCase()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 大写拉丁字母: ${byte2.isAsciiUpperCase()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 大写拉丁字母: ${byte3.isAsciiUpperCase()}")
}
```

运行结果：

```text
byte1 (0x65) 是否是 ASCII 大写拉丁字母: true
byte2 (0x90) 是否是 ASCII 大写拉丁字母: true
byte3 (0x97) 是否是 ASCII 大写拉丁字母: false
```

#### func isAsciiWhiteSpace()

```cangjie
public func isAsciiWhiteSpace(): Bool
```

功能：判断 [Byte](core_package_types.md#type-byte) 是否是在 Ascii 空白字符范围内。其取值范围为 [09, 0D] 和 {20} 的并集。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 [Byte](core_package_types.md#type-byte) 在 Ascii 空白字符范围内返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 isAsciiWhiteSpace() 方法
    let byte1: Byte = 0x09 // '\t'，制表符，属于 ASCII 空白字符
    let byte2: Byte = 0x20 // ' '，空格，属于 ASCII 空白字符
    let byte3: Byte = 0x41 // 'A'，字母，不属于 ASCII 空白字符

    println("byte1 (0x${byte1}) 是否是 ASCII 空白字符: ${byte1.isAsciiWhiteSpace()}")
    println("byte2 (0x${byte2}) 是否是 ASCII 空白字符: ${byte2.isAsciiWhiteSpace()}")
    println("byte3 (0x${byte3}) 是否是 ASCII 空白字符: ${byte3.isAsciiWhiteSpace()}")
}
```

运行结果：

```text
byte1 (0x9) 是否是 ASCII 空白字符: true
byte2 (0x32) 是否是 ASCII 空白字符: true
byte3 (0x65) 是否是 ASCII 空白字符: false
```

#### func toAsciiLowerCase()

```cangjie
public func toAsciiLowerCase(): Byte
```

功能：将 [Byte](core_package_types.md#type-byte) 转换为对应的 Ascii 小写字符 [Byte](core_package_types.md#type-byte)，如果无法转换则保持现状。

返回值：

- [Byte](core_package_types.md#type-byte) - 转换后的 [Byte](core_package_types.md#type-byte)，如果无法转换则返回原来的 [Byte](core_package_types.md#type-byte)。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 toAsciiLowerCase() 方法
    let byte1: Byte = 0x41 // 'A'，大写字母
    let byte2: Byte = 0x5A // 'Z'，大写字母
    let byte3: Byte = 0x30 // '0'，数字，无法转换

    let lower1 = byte1.toAsciiLowerCase()
    let lower2 = byte2.toAsciiLowerCase()
    let lower3 = byte3.toAsciiLowerCase()

    println("byte1 (0x${byte1}) 转换为小写: 0x${lower1}")
    println("byte2 (0x${byte2}) 转换为小写: 0x${lower2}")
    println("byte3 (0x${byte3}) 转换为小写: 0x${lower3} (保持不变)")
}
```

运行结果：

```text
byte1 (0x65) 转换为小写: 0x97
byte2 (0x90) 转换为小写: 0x122
byte3 (0x48) 转换为小写: 0x48 (保持不变)
```

#### func toAsciiUpperCase()

```cangjie
public func toAsciiUpperCase(): Byte
```

功能：将 [Byte](core_package_types.md#type-byte) 转换为对应的 Ascii 大写字符 [Byte](core_package_types.md#type-byte)，如果无法转换则保持现状。

返回值：

- [Byte](core_package_types.md#type-byte) - 转换后的 [Byte](core_package_types.md#type-byte)，如果无法转换则返回原来的 [Byte](core_package_types.md#type-byte)。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 toAsciiUpperCase() 方法
    let byte1: Byte = 0x61 // 'a'，小写字母
    let byte2: Byte = 0x7A // 'z'，小写字母
    let byte3: Byte = 0x30 // '0'，数字，无法转换

    let upper1 = byte1.toAsciiUpperCase()
    let upper2 = byte2.toAsciiUpperCase()
    let upper3 = byte3.toAsciiUpperCase()

    println("byte1 (0x${byte1}) 转换为大写: 0x${upper1}")
    println("byte2 (0x${byte2}) 转换为大写: 0x${upper2}")
    println("byte3 (0x${byte3}) 转换为大写: 0x${upper3} (保持不变)")
}
```

运行结果：

```text
byte1 (0x97) 转换为大写: 0x65
byte2 (0x122) 转换为大写: 0x90
byte3 (0x48) 转换为大写: 0x48 (保持不变)
```

## interface Collection\<T>

```cangjie
public interface Collection<T> <: Iterable<T> {
    prop size: Int64
    func isEmpty(): Bool
    func toArray(): Array<T>
}
```

功能：该接口用来表示集合，通常容器类型应该实现该接口。

父类型：

- [Iterable](#interface-iterablee)\<T>

### prop size

```cangjie
prop size: Int64
```

功能：获取当前集合的大小，即集合中元素的个数。

类型：[Int64](core_package_intrinsics.md#int64)

### func isEmpty()

```cangjie
func isEmpty(): Bool
```

功能：判断当前集合是否为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空返回 true，否则返回 false。

<!--Del_sink-->
### func isEmpty()

```cangjie
func isEmpty(this @local?): Bool
```

功能：判断当前集合是否为空。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    println("arr isEmpty: ${arr.isEmpty()}")
    let empty: Array<Int64> @local? = []
    println("empty isEmpty: ${empty.isEmpty()}")
}
```

运行结果：

```text
arr isEmpty: false
empty isEmpty: true
```

<!--DelEnd_sink-->

### func toArray()

```cangjie
func toArray(): Array<T>
```

功能：将当前集合转为数组类型。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 转换得到的数组。

<!--Del_sink-->

### func toArray()

```cangjie
func toArray(this @local?): Array<T> @local?
```

功能：将当前集合转为数组类型。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> @local? - 转换得到的 `@local?` 数组。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    let collection: Collection<Int64> @local? = arr
    let copied: Array<Int64> @local? = collection.toArray()
    println("size=${copied.size}")
}
```

运行结果：

```text
size=3
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func toArray()

```cangjie
func toArray(this @local!): Array<T> @local!
```

功能：将当前集合转为数组类型。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> @local! - 转换得到的 `@local!` 数组。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

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

运行结果：

```text
first=1
```

<!--DelEnd_sink-->
## interface Comparable\<T>

```cangjie
public interface Comparable<T> <: Equatable<T> & Less<T> & Greater<T> & LessOrEqual<T> & GreaterOrEqual<T> {
    func compare(other: T): Ordering
    operator func ==(other: T): Bool
    operator func <(other: T): Bool
    operator func >(other: T): Bool
    operator func <=(other: T): Bool
    operator func >=(other: T): Bool
}
```

功能：该接口表示比较运算，是等于、不等于、小于、大于、小于等于、大于等于接口的集合体。

该接口中提供运算符 ==、!=、<、<=、>、>= 重载的默认实现，默认实现根据 compare 函数的返回值来确定其返回值。例如：如果 a.compare(b) 的返回值为 EQ，则 a == b 返回 true，否则返回 false。

父类型：

- [Equatable](#interface-equatablet)\<T>
- [Less](#interface-lesst)\<T>
- [Greater](#interface-greatert)\<T>
- [LessOrEqual](#interface-lessorequalt)\<T>
- [GreaterOrEqual](#interface-greaterorequalt)\<T>

### func compare(T)

```cangjie
func compare(other: T): Ordering
```

功能：判断当前 `T` 类型实例与参数指向的 `T` 类型实例的大小关系。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT，如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ，如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

### operator func <(T)

```cangjie
operator func <(other: T): Bool
```

功能：判断当前 `T` 类型实例是否小于参数指向的 `T` 类型实例，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于，返回 true，否则返回 false。

### operator func <=(T)

```cangjie
operator func <=(other: T): Bool
```

功能：判断当前 `T` 类型实例是否小于等于参数指向的 `T` 类型实例，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于等于，返回 true，否则返回 false。

### operator func ==(T)

```cangjie
operator func ==(other: T): Bool
```

功能：判断两个实例是否相等，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

### operator func >(T)

```cangjie
operator func >(other: T): Bool
```

功能：判断当前 `T` 类型实例是否大于参数指向的 `T` 类型实例，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于，返回 true，否则返回 false。

### operator func >=(T)

```cangjie
operator func >=(other: T): Bool
```

功能：判断当前 `T` 类型实例是否大于等于参数指向的 `T` 类型实例，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于等于，返回 true，否则返回 false。

<!--Del_sink-->
### func compare(T)

```cangjie
func compare(this @local?, other: T @local?): Ordering
```

功能：判断当前实例与参数指定的实例的大小关系。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 大小比较结果。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    let r: Ordering = a.compare(c)
    println("compare: ${r}")
}
```

运行结果：

```text
compare: Ordering.LT
```

<!--DelEnd_sink-->

<!--Del_sink-->

### operator func ==(T)

```cangjie
operator func ==(this @local?, other: T @local?): Bool
```

功能：判断当前实例与参数指定的实例是否相等，该函数是此接口的默认实现函数，基于 `compare(this @local?, other @local?)` 的返回值确定结果。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

示例：

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

运行结果：

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

功能：判断当前实例是否小于参数指定的实例，该函数是此接口的默认实现函数。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("a < c: ${a < c}")
    println("c < a: ${c < a}")
}
```

运行结果：

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

功能：判断当前实例是否大于参数指定的实例，该函数是此接口的默认实现函数。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("c > a: ${c > a}")
    println("a > c: ${a > c}")
}
```

运行结果：

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

功能：判断当前实例是否小于等于参数指定的实例，该函数是此接口的默认实现函数。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于等于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("a <= c: ${a <= c}")
    println("c <= a: ${c <= a}")
}
```

运行结果：

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

功能：判断当前实例是否大于等于参数指定的实例，该函数是此接口的默认实现函数。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于等于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Int64 @local? = 3
    let c: Int64 @local? = 5
    println("c >= a: ${c >= a}")
    println("a >= c: ${a >= c}")
}
```

运行结果：

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

功能：用于标记可复制类型的空接口。

local mode 的部分扩展族以 `T <: Copyable` 为约束（例如 [Array](core_package_structs.md#struct-arrayt) 的 `@local` 成员扩展），只有实现该接口的类型才能使用这些局部扩展成员。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

示例：

<!-- verify -->
```cangjie
main() {
    // Int64 实现 Copyable，可在 @local? 数组上调用受此约束的 fill 扩展
    let arr: Array<Int64> @local? = [1, 2, 3]
    arr.fill(0)
    let f: Option<Int64> @local? = arr.first
    match (f) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

运行结果：

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

功能：该接口表示类型可数。

可数类型的每一个实例都对应一个位置信息（[Int64](core_package_intrinsics.md#int64) 值），可以通过往后数数得到其他的该类型实例。

### func next(Int64)

```cangjie
func next(right: Int64): T
```

功能：获取当前实例向右移动 `right` 后对应位置的 `T` 类型实例。

参数：

- right: [Int64](core_package_intrinsics.md#int64) - 往右数的个数。

返回值：

- T - 向右移动 `right` 后对应位置的 `T` 类型实例。

### func position()

```cangjie
func position(): Int64
```

功能：获取当前可数实例的位置信息，即将当前实例转为 [Int64](core_package_intrinsics.md#int64) 类型。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 转换后的 [Int64](core_package_intrinsics.md#int64) 值。

### extend Float64

```cangjie
extend Float64
```

功能：拓展了 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型作为左操作数和 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 类型作为右操作数的乘法运算。

#### operator func *(Duration)

```cangjie
public operator func *(r: Duration): Duration
```

功能：实现 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型和 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 类型的乘法，即 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 运算。

参数：

- r: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 实例。

返回值：

- [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型实例和 `r` 的乘积。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相乘后的结果超出 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Float64 * Duration 运算
    let floatVal: Float64 = 2.5
    let duration: Duration = Duration.second

    let result = floatVal * duration

    println("Float64值: ${floatVal}")
    println("Duration值: ${duration}")
    println("运算结果: ${result}")
}
```

运行结果：

```text
Float64值: 2.500000
Duration值: 1s
运算结果: 2s500ms
```

### extend Int64

```cangjie
extend Int64
```

功能：拓展了 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型作为左操作数和 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 类型作为右操作数的乘法运算。

#### operator func *(Duration)

```cangjie
public operator func *(r: Duration): Duration
```

功能：实现 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型和 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 类型的乘法，即 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 运算。

例如 2 * [Duration](../../core/core_package_api/core_package_structs.md#struct-duration).second 返回表示时间间隔为 2 秒的 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 实例。

参数：

- r: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 乘法的右操作数。

返回值：

- [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型实例和 `r` 的乘积。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相乘后的结果超出 [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 测试 Int64 * Duration 运算
    let intVal: Int64 = 3
    let duration: Duration = Duration.second

    let result = intVal * duration

    println("Int64值: ${intVal}")
    println("Duration值: ${duration}")
    println("运算结果: ${result}")

    // 测试 2 * Duration.second 的示例
    let result2 = 2 * Duration.second
    println("2 * Duration.second = ${result2}")
}
```

运行结果：

```text
Int64值: 3
Duration值: 1s
运算结果: 3s
2 * Duration.second = 2s
```

## interface CType

```cangjie
sealed interface CType {}
```

功能：表示支持与 C 语言互操作的接口。

[CType](core_package_interfaces.md#interface-ctype) 接口是一个语言内置的空接口，它是 [CType](core_package_interfaces.md#interface-ctype) 约束的具体实现，所有 C 互操作支持的类型都隐式地实现了该接口，因此所有 C 互操作支持的类型都可以作为 [CType](core_package_interfaces.md#interface-ctype) 类型的子类型使用。

> **注意：**
>
> - [CType](core_package_interfaces.md#interface-ctype) 接口是仓颉中的一个接口类型，它本身不满足 [CType](core_package_interfaces.md#interface-ctype) 约束。
> - [CType](core_package_interfaces.md#interface-ctype) 接口不允许被用户继承、扩展。
> - [CType](core_package_interfaces.md#interface-ctype) 接口不会突破子类型的使用限制。

示例：

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

## interface Equal\<T>

```cangjie
public interface Equal<T> {
    operator func ==(other: T): Bool
}
```

功能：该接口用于支持判等操作。

### operator func ==(T)

```cangjie
operator func ==(other: T): Bool
```

功能：判断两个实例是否相等。

参数：

- other: T - 待比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

<!--Del_sink-->
### operator func ==(T)

```cangjie
operator func ==(this @local!, other: T @local!): Bool
```

功能：判断当前实例与指定实例是否相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- other: T @local! - 待比较的另一个 `@local!` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    // Array 未提供 == 的 @local! 实现，调用命中 Equal 接口默认实现
    try {
        println("eq=${a == b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '==' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->

### operator func ==(T)

```cangjie
operator func ==(this @local?, other: T @local?): Bool
```

功能：判断当前实例与指定实例是否相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let x: Array<Int64> @local? = a
    let y: Array<Int64> @local? = b
    // Array 未提供 == 的 @local? 实现，调用命中 Equal 接口默认实现
    try {
        println("eq=${x == y}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '==' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Equatable\<T>

```cangjie
public interface Equatable<T> <: Equal<T> & NotEqual<T> {
    operator func !=(other: T): Bool
}
```

功能：该接口是判等和判不等两个接口的集合体。

该接口中提供运算符 != 重载的默认实现。`@local!` 形式的默认实现直接抛出 [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception)；其余形式的默认实现将运算结果委托给 == 运算（即 `!(this == other)`），其失败行为取决于被委托的 == 实现。例如：如果 a == b 的返回值为 true，则 a != b 返回 false，否则返回 true。

已为部分仓颉类型实现该接口，包括：[Unit](core_package_intrinsics.md#unit)、[Bool](core_package_intrinsics.md#bool) 、[Rune](core_package_intrinsics.md#rune)、[Int64](core_package_intrinsics.md#int64)、[Int32](core_package_intrinsics.md#int32)、[Int16](core_package_intrinsics.md#int16)、[Int8](core_package_intrinsics.md#int8)、[UIntNative](core_package_intrinsics.md#uintnative)、[UInt64](core_package_intrinsics.md#uint64)、[UInt32](core_package_intrinsics.md#uint32)、[UInt16](core_package_intrinsics.md#uint16)、[UInt8](core_package_intrinsics.md#uint8)、[Float64](core_package_intrinsics.md#float64)、[Float32](core_package_intrinsics.md#float32)、[Float16](core_package_intrinsics.md#float16)、[String](core_package_structs.md#struct-string)、[Array](core_package_structs.md#struct-arrayt)、[Box](core_package_classes.md#class-boxt)、[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)、[HashSet](../../collection/collection_package_api/collection_package_class.md#class-hashsett-where-t--hashable--equatablet)。

父类型：

- [Equal](#interface-equalt)\<T>
- [NotEqual](#interface-notequalt)\<T>

### operator func !=(T)

```cangjie
operator func !=(other: T): Bool
```

功能：判断两个实例是否不相等，该函数是此接口的一个默认实现函数。

参数：

- other: T - 待比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local!, other: T @local!): Bool
```

功能：判断当前实例与指定实例是否不相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- other: T @local! - 待比较的另一个 `@local!` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    // Array 未提供 != 的 @local! 实现，调用命中 Equatable 接口默认实现
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '!=' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->

### operator func !=(T)

```cangjie
operator func !=(this @local?, other: T @local?): Bool
```

功能：判断当前实例与指定实例是否不相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 默认实现自身不直接抛出异常；当被委托的 == 实现抛出该异常时随之传播，例如类型未提供 == 的 `@local?` 实现而命中 [Equal](#interface-equalt) 接口的默认实现时。

示例：

<!-- verify -->
```cangjie
main() {
    let a: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let b: Array<Int64> @local! = Array<Int64>(1) {i => i}
    let x: Array<Int64> @local? = a
    let y: Array<Int64> @local? = b
    // 默认实现将运算委托给 ==，Array 未提供 == 的 @local? 实现，最终命中 Equal 接口默认实现
    try {
        println("ne=${x != y}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '==' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Greater\<T>

```cangjie
public interface Greater<T> {
    operator func >(other: T): Bool
}
```

功能：该接口表示大于计算。

### operator func >(T)

```cangjie
operator func >(other: T): Bool
```

功能：判断当前 `T` 类型实例是否大于参数指向的 `T` 类型实例。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于，返回 true，否则返回 false。

## interface GreaterOrEqual\<T>

```cangjie
public interface GreaterOrEqual<T> {
    operator func >=(other: T): Bool
}
```

功能：该接口表示大于等于计算。

### operator func >=(T)

```cangjie
operator func >=(other: T): Bool
```

功能：判断当前 `T` 类型实例是否大于等于参数指向的 `T` 类型实例。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于等于，返回 true，否则返回 false。

## interface Hashable

```cangjie
public interface Hashable {
    func hashCode(): Int64
}
```

功能：该接口用于计算哈希值。

已为部分仓颉类型实现该接口，包括：[Bool](core_package_intrinsics.md#bool)、[Rune](core_package_intrinsics.md#rune)、[IntNative](core_package_intrinsics.md#intnative)、[Int64](core_package_intrinsics.md#int64)、[Int32](core_package_intrinsics.md#int32)、[Int16](core_package_intrinsics.md#int16)、[Int8](core_package_intrinsics.md#int8)、[UIntNative](core_package_intrinsics.md#uintnative)、[UInt64](core_package_intrinsics.md#uint64)、[UInt32](core_package_intrinsics.md#uint32)、[UInt16](core_package_intrinsics.md#uint16)、[UInt8](core_package_intrinsics.md#uint8)、[Float64](core_package_intrinsics.md#float64)、[Float32](core_package_intrinsics.md#float32)、[Float16](core_package_intrinsics.md#float16)、[String](core_package_structs.md#struct-string)、[Box](core_package_classes.md#class-boxt)。

### func hashCode()

```cangjie
func hashCode(): Int64
```

功能：获得实例类型的哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 返回实例类型的哈希值。

<!--Del_sink-->
### func hashCode()

```cangjie
func hashCode(this @local?): Int64
```

功能：计算当前实例的哈希值。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 返回实例类型的哈希值。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local? = Ordering.LT
    // Ordering 提供了 hashCode 的 @local? 实现
    println("h=${ord.hashCode()}")
}
```

运行结果：

```text
h=1
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func hashCode()

```cangjie
func hashCode(this @local!): Int64
```

功能：计算当前实例的哈希值。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 返回实例类型的哈希值。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local! = Ordering.GT
    // Ordering 提供了 hashCode 的 @local! 实现
    println("h=${ord.hashCode()}")
}
```

运行结果：

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

功能：该接口用于处理哈希组合运算。

可以使用一系列 write 函数传入不同数据类型实例，并计算它们的组合哈希值。

### func finish()

```cangjie
func finish(): Int64
```

功能：获取哈希运算的结果。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 经过计算后的哈希值。

### func reset()

```cangjie
mut func reset(): Unit
```

功能：重置哈希值到 0。

### func write(Bool)

```cangjie
mut func write(value: Bool): Unit
```

功能：把想要哈希运算的 [Bool](core_package_intrinsics.md#bool) 值传入，然后进行哈希组合运算。

参数：

- value: [Bool](core_package_intrinsics.md#bool) - 待运算的值。

### func write(Float16)

```cangjie
mut func write(value: Float16): Unit
```

功能：通过该函数把想要哈希运算的 [Float16](core_package_intrinsics.md#float16) 值传入，然后进行哈希组合运算。

参数：

- value: [Float16](core_package_intrinsics.md#float16) - 待运算的值。

### func write(Float32)

```cangjie
mut func write(value: Float32): Unit
```

功能：通过该函数把想要哈希运算的 [Float32](core_package_intrinsics.md#float32) 值传入，然后进行哈希组合运算。

参数：

- value: [Float32](core_package_intrinsics.md#float32) - 待运算的值。

### func write(Float64)

```cangjie
mut func write(value: Float64): Unit
```

功能：通过该函数把想要哈希运算的 [Float64](core_package_intrinsics.md#float64) 值传入，然后进行哈希组合运算。

参数：

- value: [Float64](core_package_intrinsics.md#float64) - 待运算的值。

### func write(Int16)

```cangjie
mut func write(value: Int16): Unit
```

功能：通过该函数把想要哈希运算的 [Int16](core_package_intrinsics.md#int16) 值传入，然后进行哈希组合运算。

参数：

- value: [Int16](core_package_intrinsics.md#int16) - 待运算的值。

### func write(Int32)

```cangjie
mut func write(value: Int32): Unit
```

功能：通过该函数把想要哈希运算的 [Int32](core_package_intrinsics.md#int32) 值传入，然后进行哈希组合运算。

参数：

- value: [Int32](core_package_intrinsics.md#int32) - 待运算的值。

### func write(Int64)

```cangjie
mut func write(value: Int64): Unit
```

功能：通过该函数把想要哈希运算的 [Int64](core_package_intrinsics.md#int64) 值传入，然后进行哈希组合运算。

参数：

- value: [Int64](core_package_intrinsics.md#int64) - 待运算的值。

### func write(Int8)

```cangjie
mut func write(value: Int8): Unit
```

功能：通过该函数把想要哈希运算的 [Int8](core_package_intrinsics.md#int8) 值传入，然后进行哈希组合运算。

参数：

- value: [Int8](core_package_intrinsics.md#int8) - 待运算的值。

### func write(Rune)

```cangjie
mut func write(value: Rune): Unit
```

功能：通过该函数把想要哈希运算的 [Rune](core_package_intrinsics.md#rune) 值传入，然后进行哈希组合运算。

参数：

- value: [Rune](core_package_intrinsics.md#rune) - 待运算的值。

### func write(String)

```cangjie
mut func write(value: String): Unit
```

功能：通过该函数把想要哈希运算的 [String](core_package_structs.md#struct-string) 值传入，然后进行哈希组合运算。

参数：

- value: [String](core_package_structs.md#struct-string) - 待运算的值。

### func write(UInt16)

```cangjie
mut func write(value: UInt16): Unit
```

功能：通过该函数把想要哈希运算的 [UInt16](core_package_intrinsics.md#uint16) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt16](core_package_intrinsics.md#uint16) - 待运算的值。

### func write(UInt32)

```cangjie
mut func write(value: UInt32): Unit
```

功能：通过该函数把想要哈希运算的 [UInt32](core_package_intrinsics.md#uint32) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt32](core_package_intrinsics.md#uint32) - 待运算的值。

### func write(UInt64)

```cangjie
mut func write(value: UInt64): Unit
```

功能：通过该函数把想要哈希运算的 [UInt64](core_package_intrinsics.md#uint64) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt64](core_package_intrinsics.md#uint64) - 待运算的值。

### func write(UInt8)

```cangjie
mut func write(value: UInt8): Unit
```

功能：通过该函数把想要哈希运算的 [UInt8](core_package_intrinsics.md#uint8) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt8](core_package_intrinsics.md#uint8) - 待运算的值。

## interface Iterable\<E>

```cangjie
public interface Iterable<E> {
    func iterator(): Iterator<E>
}
```

功能：该接口表示可迭代，实现了该接口的类型（通常为容器类型）可以在 `for-in` 语句中实现迭代，也可以获取其对应的迭代器类型实例，调用 `next` 函数实现迭代。

本包已经为 [Array](core_package_structs.md#struct-arrayt)、[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)、[HashMap](../../collection/collection_package_api/collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) 等基础容器类型实现了该接口，用户可以为其他类型实现该接口，使之支持迭代遍历的功能。

### func iterator()

```cangjie
func iterator(): Iterator<E>
```

功能：获取迭代器。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<E> - 迭代器。

<!--Del_sink-->
### func iterator()

```cangjie
func iterator(this @local!): Iterator<E> @local!
```

功能：获取当前实例的迭代器，返回的迭代器与当前实例绑定在同一个 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<E> @local! - 迭代器。

异常：

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3]
    // Array 提供了 iterator 的 @local! 实现
    let it: Iterator<Int64> @local! = arr.iterator()
    match (it.next()) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

运行结果：

```text
first=1
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func iterator()

```cangjie
func iterator(this @local?): Iterator<E> @local?
```

功能：获取当前实例的迭代器，返回的迭代器与当前实例绑定在同一个 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<E> @local? - 迭代器。

异常：

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [1, 2, 3]
    // Array 提供了 iterator 的 @local? 实现
    let it: Iterator<Int64> @local? = arr.iterator()
    match (it.next()) {
        case Some(v) => println("first=${v}")
        case None => println("none")
    }
}
```

运行结果：

```text
first=1
```

<!--DelEnd_sink-->
## interface Less\<T>

```cangjie
public interface Less<T> {
    operator func <(other: T): Bool
}
```

功能：该接口表示小于计算。

### operator func <(T)

```cangjie
operator func <(other: T): Bool
```

功能：判断当前 `T` 类型实例是否小于参数指向的 `T` 类型实例。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于，返回 true，否则返回 false。

## interface LessOrEqual\<T>

```cangjie
public interface LessOrEqual<T> {
    operator func <=(other: T): Bool
}
```

功能：该接口表示小于等于计算。

### operator func <=(T)

```cangjie
operator func <=(other: T): Bool
```

功能：判断当前 `T` 类型实例是否小于等于参数指向的 `T` 类型实例。

参数：

- other: T - 待与当前实例比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于等于，返回 true，否则返回 false。

## interface NotEqual\<T>

```cangjie
public interface NotEqual<T> {
    operator func !=(other: T): Bool
}
```

功能：该接口用于支持判不等操作。

### operator func !=(T)

```cangjie
operator func !=(other: T): Bool
```

功能：判断两个实例是否不相等。

参数：

- other: T - 待比较的另一个实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local!, other: T @local!): Bool
```

功能：判断当前实例与指定实例是否不相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- other: T @local! - 待比较的另一个 `@local!` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local!` 实现时抛出。

示例：

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
    // MyType 未提供 != 的 @local! 实现，调用命中 NotEqual 接口默认实现
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '!=' method for its @local! instance
```

<!--DelEnd_sink-->

<!--Del_sink-->
### operator func !=(T)

```cangjie
operator func !=(this @local?, other: T @local?): Bool
```

功能：判断当前实例与指定实例是否不相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: T @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

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
    // MyType 未提供 != 的 @local? 实现，调用命中 NotEqual 接口默认实现
    try {
        println("ne=${a != b}")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: Current Type does not implement '!=' method for its @local? instance
```

<!--DelEnd_sink-->
## interface Resource

```cangjie
public interface Resource {
    func isClosed(): Bool
    func close(): Unit
}
```

功能：该接口用于资源管理，通常用于内存、句柄等资源的关闭和释放。

实现了该接口的类型可以在 `try-with-resource` 语法上下文中实现自动资源释放。

### func close()

```cangjie
func close(): Unit
```

功能：关闭资源。

### func isClosed()

```cangjie
func isClosed(): Bool
```

功能：判断资源是否已经关闭。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果已经关闭返回 true，否则返回 false。

## interface ThreadContext

```cangjie
public interface ThreadContext {
    func end(): Unit
    func hasEnded(): Bool
}
```

功能：仓颉线程上下文接口。

用户创建 `thread` 时，除了缺省 `spawn` 表达式入参，也可以通过传入不同 [ThreadContext](core_package_interfaces.md#interface-threadcontext) 类型的实例，选择不同的线程上下文，然后一定程度上控制并发行为。

目前不允许用户自行实现 [ThreadContext](core_package_interfaces.md#interface-threadcontext) 接口，仓颉语言根据使用场景，提供了 `MainThreadContext`, 具体定义可在终端框架库中查阅。

### func end()

```cangjie
func end(): Unit
```

功能：结束方法，用于向当前 context 发送结束请求。

### func hasEnded()

```cangjie
func hasEnded(): Bool
```

功能：检查方法，用于检查当前 context 是否已结束。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果结束返回 true，否则返回 false。

## interface ToString

```cangjie
public interface ToString {
    func toString(): String
}
```

功能：该接口用来提供具体类型的字符串表示。

### func toString()

```cangjie
func toString(): String
```

功能：获取实例类型的字符串表示。

返回值：

- [String](core_package_structs.md#struct-string) - 返回实例类型的字符串表示。

<!--Del_sink-->
### func toString()

```cangjie
func toString(this @local?): String @local!
```

功能：将当前实例转换为可输出的字符串，返回的字符串绑定在调用者的 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [String](core_package_structs.md#struct-string) @local! - 返回实例类型的字符串表示。

异常：

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - 当前类型未提供该 `@local?` 实现时抛出。

示例：

<!-- verify -->
```cangjie
main() {
    let n: Int64 @local? = 42
    // Int64 提供了 toString 的 @local? 实现
    let s: String @local! = n.toString()
    println(s)
}
```

运行结果：

```text
42
```

<!--DelEnd_sink-->