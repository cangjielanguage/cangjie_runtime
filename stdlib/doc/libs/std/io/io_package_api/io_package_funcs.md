# 函数

## func copy(InputStream, OutputStream)

```cangjie
public func copy(from: InputStream, to!: OutputStream): Int64
```

功能：将一个输入流中未被读取的数据拷贝到另一个输出流中。

参数：

- from: [InputStream](io_package_interfaces.md#interface-inputstream) - 待读取数据的输入流。
- to!: [OutputStream](io_package_interfaces.md#interface-outputstream) - 数据将要拷贝到的输出流。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 拷贝数据的字节数。

示例：

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.copy

main(): Unit {
    let sourceStream = ByteBuffer()
    let targetStream = ByteBuffer()

    /* 向源输入流写入数据 */
    let sourceData = "Hello, World!".toArray()
    sourceStream.write(sourceData)

    /* 使用 copy 函数将源输入流的数据拷贝到目标输出流 */
    let copiedBytes = copy(sourceStream, to: targetStream)
    println("Copied ${copiedBytes} bytes.")

    /* 读取目标输出流中的数据 */
    let targetData: Array<Byte> = Array<Byte>(sourceData.size, repeat: 0)
    targetStream.read(targetData)
    println("Data copied to target stream: ${String.fromUtf8(targetData)}")
}
```

运行结果：

```text
Copied 13 bytes.
Data copied to target stream: Hello, World!
```

## func readString\<T>(T) where T <: InputStream & Seekable

```cangjie
public func readString<T>(from: T): String where T <: InputStream & Seekable
```

功能：读取入参中的所有剩余内容，并返回一个字符串。

参数：

- from: T - 要读取数据的对象。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 读取到的结果字符串。

异常：

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - 当剩余字节不符合 UTF-8 编码规则时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readString
import std.io.ContentFormatException

main(): Unit {
    let inputStream = ByteBuffer()

    /* 向输入流写入数据 */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* 使用 readString 函数读取输入流中的所有剩余内容 */
    try {
        let result = readString(inputStream)
        println("Read string: ${result}")
    } catch (e: ContentFormatException) {
        println("Error: ${e.message}")
    }

    /* 向输入流写入一个不合法的 UTF-8 字符串 */
    let sourceDataError: Array<UInt8> = [0xC3, 0x28, 0x48, 0x65, 0x6C, 0x6C, 0x6F]
    inputStream.write(sourceDataError)

    /* 使用 readString 函数读取输入流中的所有剩余内容 */
    try {
        let result = readString(inputStream)
        println("Read string: ${result}")
    } catch (e: ContentFormatException) {
        println("Error: ${e.message}")
    }
}
```

运行结果：

```text
Read string: Hello, World!
Error: Invalid UTF-8: byte sequence starting at index '0' is not a valid 2-byte UTF-8 encoding.
```

## func readStringUnchecked\<T>(T) where T <: InputStream & Seekable

```cangjie
public unsafe func readStringUnchecked<T>(from: T): String where T <: InputStream & Seekable
```

功能：读取入参中的所有剩余内容，并返回一个字符串。该函数不会检查字符串的合法性。

参数：

- from: T - 要读取数据的对象。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 读取到的结果字符串。

示例：

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readStringUnchecked
import std.io.ContentFormatException

main(): Unit {
    let inputStream = ByteBuffer()

    /* 向输入流写入数据 */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* 使用 readString 函数读取输入流中的所有剩余内容，可以正常输出：Read string: Hello, World! */
    unsafe {
        let result = readStringUnchecked(inputStream)
        println("Read string: ${result}")
    }
}
```

运行结果：

```text
Read string: Hello, World!
```

## func readToEnd\<T>(T) where T <: InputStream & Seekable

```cangjie
public func readToEnd<T>(from: T): Array<Byte> where T <: InputStream & Seekable
```

功能：获取入参中未被读取的数据。

参数：

- from: T - 要读取数据的对象。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 未被读取的数据的拷贝。

示例：

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readToEnd

main(): Unit {
    let inputStream = ByteBuffer()

    /* 向输入流写入数据 */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* 使用 readToEnd 函数读取输入流中的所有剩余内容 */
    let data = readToEnd(inputStream)
    println("${String.fromUtf8(data)}")
}
```

运行结果：

```text
Hello, World!
```

<!--Del_sink-->
## func readToEnd\<T>(T) where T <: InputStream & Seekable

```cangjie
public exclave func readToEnd<T>(from: T @local!): Array<Byte> @local! where T <: InputStream & Seekable
```

功能：获取入参中未被读取的数据；返回的字节数组位于调用者的 local region 中。本函数先通过 local 版本的 length 属性获取流的总长度，再通过 local 版本的 read 从当前光标开始读取数据；length 的实现又依赖 local 版本的 seek。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- from: T @local! - 要读取数据的对象。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - 未被读取的数据的拷贝。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当 `T` 未覆写 local 版本的 read 或 seek（length 依赖 seek）而命中接口默认实现时，该默认实现抛出的异常随之传播。

示例：

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readToEnd

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例作为输入流
    let inputStream: ByteBuffer @local! = ByteBuffer() @local!

    // 向输入流写入数据
    let sourceData: Array<Byte> @local! = [72, 73, 74, 75] // HIJK
    inputStream.write(sourceData)

    // 使用 readToEnd 函数读取输入流中未被读取的数据
    let data: Array<Byte> @local! = readToEnd(inputStream)
    println("Bytes read: ${data.size}")
    println("Content: ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]}")
}
```

运行结果：

```text
Bytes read: 4
Content: 72, 73, 74, 75
```

<!--DelEnd_sink-->