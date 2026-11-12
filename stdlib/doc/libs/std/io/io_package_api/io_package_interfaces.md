# 接口

## interface InputStream

```cangjie
public interface InputStream {
    func read(buffer: Array<Byte>): Int64
}
```

功能：输入流接口。

### func read(Array\<Byte>)

```cangjie
func read(buffer: Array<Byte>): Int64
```

功能：从输入流中读取数据放到 `buffer` 中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放从输入流中读取的数据。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取的数据的字节数。

<!--Del_sink-->
### func read(Array\<Byte>)

```cangjie
func read(this @local!, buffer: Array<Byte> @local!): Int64
```

功能：从输入流中读取数据放到 `buffer` 中。具体类型未覆写该 local 版本时，调用命中接口默认实现，不会读取任何数据。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - 缓冲区，用于存放从输入流中读取的数据。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取的数据的字节数。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写该 local 版本时，接口默认实现直接抛出该异常，不会读取任何数据。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例作为输入流
    let stream: ByteBuffer @local! = ByteBuffer() @local!

    // 写入数据
    let data: Array<Byte> @local! = [65, 66] // AB
    stream.write(data)

    // 将光标移动到数据头部
    stream.seek(SeekPosition.Begin(0))

    // 分配 `@local!` 缓冲区并通过 read 读取数据
    let buffer: Array<Byte> @local! = [0, 0]
    let bytesRead = stream.read(buffer)
    println("Bytes read: ${bytesRead}")
    println("Content: ${buffer[0]}, ${buffer[1]}")
}
```

运行结果：

```text
Bytes read: 2
Content: 65, 66
```

<!--DelEnd_sink-->
## interface IOStream

```cangjie
public interface IOStream <: InputStream & OutputStream {}
```

功能：输入输出流接口。

父类型：

- [InputStream](#interface-inputstream)
- [OutputStream](#interface-outputstream)

## interface OutputStream

```cangjie
public interface OutputStream {
    func write(buffer: Array<Byte>): Unit
    func flush(): Unit
}
```

功能：输出流接口。

### func flush()

```cangjie
func flush(): Unit
```

功能：清空缓冲区。该函数的默认实现为空。

### func write(Array\<Byte>)

```cangjie
func write(buffer: Array<Byte>): Unit
```

功能：将 `buffer` 中的数据写入到输出流中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待写入输出流的数据。

<!--Del_sink-->
### func write(Array\<Byte>)

```cangjie
func write(this @local!, buffer: Array<Byte> @local!): Unit
```

功能：将 `buffer` 中的数据写入到输出流中。具体类型未覆写该 local 版本时，调用命中接口默认实现，不会写入任何数据。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - 缓冲区，用于存放待写入输出流的数据。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写该 local 版本时，接口默认实现直接抛出该异常，不会写入任何数据。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例作为输出流
    let stream: ByteBuffer @local! = ByteBuffer() @local!

    // 分配 `@local!` 缓冲区并通过 write 写入数据
    let buffer: Array<Byte> @local! = [67, 68] // CD
    stream.write(buffer)

    // 读取数据以验证写入结果
    stream.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    stream.read(readBuf)
    println("Content: ${readBuf[0]}, ${readBuf[1]}")
}
```

运行结果：

```text
Content: 67, 68
```

<!--DelEnd_sink-->
## interface Seekable

```cangjie
public interface Seekable {
    func seek(sp: SeekPosition): Int64
    prop position: Int64
    prop remainLength: Int64
    prop length: Int64
}
```

功能：移动光标接口。

### prop length

```cangjie
prop length: Int64
```

功能：返回当前流中的总数据量（以字节为单位）。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop length

```cangjie
prop length: Int64 @local!
```

功能：返回当前流中的总数据量（以字节为单位）。该属性通过调用 local 版本的 seek 实现；具体类型未覆写 local 版本的 seek 时，读取该属性将命中 seek 的接口默认实现。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写 local 版本的 seek 时，读取该属性随 seek 默认实现抛出该异常。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例并写入 3 个字节
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [69, 70, 71] // EFG
    stream.write(data)

    // 获取流中的总数据量
    println("Length: ${stream.length}")
}
```

运行结果：

```text
Length: 3
```

<!--DelEnd_sink-->
### prop position

```cangjie
prop position: Int64
```

功能：返回当前光标位置。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop position

```cangjie
prop position: Int64 @local!
```

功能：返回当前光标位置。该属性通过调用 local 版本的 seek 实现；具体类型未覆写 local 版本的 seek 时，读取该属性将命中 seek 的接口默认实现。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写 local 版本的 seek 时，读取该属性随 seek 默认实现抛出该异常。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例并写入 3 个字节
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [72, 73, 74] // HIJ
    stream.write(data)

    // 获取当前光标位置
    println("Position before seek: ${stream.position}")

    // 将光标移动到位置 2
    stream.seek(SeekPosition.Begin(2))
    println("Position after seek: ${stream.position}")
}
```

运行结果：

```text
Position before seek: 0
Position after seek: 2
```

<!--DelEnd_sink-->
### prop remainLength

```cangjie
prop remainLength: Int64
```

功能：返回当前流中未读的数据量（以字节为单位）。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop remainLength

```cangjie
prop remainLength: Int64 @local!
```

功能：返回当前流中未读的数据量（以字节为单位）。该属性通过调用 local 版本的 seek 获取光标位置与数据末尾并计算未读数据量；具体类型未覆写 local 版本的 seek 时，读取该属性将命中 seek 的接口默认实现。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写 local 版本的 seek 时，读取该属性随 seek 默认实现抛出该异常。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例并写入 3 个字节
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [75, 76, 77] // KLM
    stream.write(data)

    // 获取未读的数据量
    println("Remain length before seek: ${stream.remainLength}")

    // 将光标移动到位置 2
    stream.seek(SeekPosition.Begin(2))
    println("Remain length after seek: ${stream.remainLength}")
}
```

运行结果：

```text
Remain length before seek: 3
Remain length after seek: 1
```

<!--DelEnd_sink-->
### func seek(SeekPosition)

```cangjie
func seek(sp: SeekPosition): Int64
```

功能：移动光标到指定的位置。

参数：

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - 指定光标移动后的位置。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 返回流中数据的起点到移动后位置的偏移量（以字节为单位）。

<!--Del_sink-->
### func seek(SeekPosition)

```cangjie
func seek(this @local!, sp: SeekPosition): Int64
```

功能：移动光标到指定的位置。具体类型未覆写该 local 版本时，调用命中接口默认实现，不会移动光标。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - 指定光标移动后的位置。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 返回流中数据的起点到移动后位置的偏移量（以字节为单位）。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当具体类型未覆写该 local 版本时，接口默认实现直接抛出该异常，不会移动光标。

示例：

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // 在 local region 中创建 ByteBuffer 实例并写入 2 个字节
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [78, 79] // NO
    stream.write(data)

    // 将光标移动到数据头部并读取第一个字节
    let pos = stream.seek(SeekPosition.Begin(0))
    println("Position after seek: ${pos}")
    let buffer: Array<Byte> @local! = [0]
    stream.read(buffer)
    println("First byte: ${buffer[0]}")
}
```

运行结果：

```text
Position after seek: 0
First byte: 78
```

<!--DelEnd_sink-->