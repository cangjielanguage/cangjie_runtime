# Class

## class BufferedInputStream\<T> where T <: InputStream

```cangjie
public class BufferedInputStream<T> <: InputStream where T <: InputStream {
    public init(input: T)
    public init(input: T, buffer: Array<Byte>)
    public init(input: T, capacity: Int64)
}
```

Function: Provides a buffered input stream.

Can bind other [InputStream](io_package_interfaces.md#interface-inputstream) type input streams (such as [ByteBuffer](io_package_classes.md#class-bytebuffer)) to a [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream) instance. When reading data from this instance, data is first read from the bound stream into a buffer for temporary storage, then read from the buffer as needed by the user.

Parent Type:

- [InputStream](io_package_interfaces.md#interface-inputstream)

### init(T)

```cangjie
public init(input: T)
```

Function: Creates a [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream) instance with default buffer capacity of 4096.

Parameters:

- input: T - Binds the specified input stream.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedInputStream

main(): Unit {
    let inputData = "Hello World".toArray()
    let inputStream = ByteBuffer(inputData)
    /* Bind the specified input stream */
    let bufferedStream = BufferedInputStream(inputStream)

    /* Read data from the input stream */
    let data = Array<Byte>(inputData.size, repeat: 0)
    bufferedStream.read(data)
    println(String.fromUtf8(data))
}
```

Execution Result:

```text
Hello World
```

### init(T, Array\<Byte>)

```cangjie
public init(input: T, buffer: Array<Byte>)
```

Function: Creates a [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream) instance.

The internal buffer used is determined by the input parameter. In performance-critical scenarios, reusing the passed `buffer` can reduce memory allocation frequency and improve performance.

Parameters:

- input: T - Binds an input stream.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The internal buffer used by [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream).

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when buffer size equals 0.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedInputStream

main(): Unit {
    let inputStream = ByteBuffer()

    /* Create BufferedInputStream instance with valid internal buffer, no exception thrown */
    try {
        let buffer = Array<Byte>(1024, repeat: 0)
        let bufferedStream = BufferedInputStream(inputStream, buffer)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Case where internal buffer size is defined as 0 */
    try {
        let invalidBuffer = Array<Byte>()
        let bufferedStream = BufferedInputStream(inputStream, invalidBuffer)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
Error: Invalid argument 'buffer': buffer size is 0.
```

### init(T, Int64)

```cangjie
public init(input: T, capacity: Int64)
```

Function: Creates a [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream) instance.

Parameters:

- input: T - Binds the specified input stream.
- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Internal buffer capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when capacity is less than or equal to 0.

### func read(Array\<Byte>)

```cangjie
public func read(buffer: Array<Byte>): Int64
```

Function: Reads data from the bound input stream into `buffer`.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer to store the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of bytes read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when buffer is empty.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedInputStream

main(): Unit {
    let inputStream = ByteBuffer()

    /* Creates a BufferedInputStream instance with a valid internal buffer capacity; no exception thrown */
    try {
        let capacity = 2048
        let bufferedStream = BufferedInputStream(inputStream, capacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Throws an exception when internal buffer is set to 0 */
    try {
        let zeroCapacity = 0
        let bufferedStream = BufferedInputStream(inputStream, zeroCapacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Throws an exception when internal buffer is set to a negative value */
    try {
        let negativeCapacity = -1024
        let bufferedStream = BufferedInputStream(inputStream, negativeCapacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
Error: Invalid capacity size: capacity = 0.
Error: Invalid capacity size: capacity = -1024.
```

### func readByte()

```cangjie
public func readByte(): ?Byte
```

Function: Reads a single byte from the input stream.

Returns:

- ?[Byte](../../core/core_package_api/core_package_types.md#type-byte) - The read data. Returns `None` if the read operation fails.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedInputStream

main(): Unit {
    /* Create input stream and write data */
    let inputStream = ByteBuffer()
    let sourceData = "abc".toArray()
    inputStream.write(sourceData)
    let bufferedStream = BufferedInputStream(inputStream)

    /* Read all bytes sequentially */
    while (true) {
        let byte = bufferedStream.readByte()
        if (byte == None) {
            break
        }
        println(String.fromUtf8(byte.getOrThrow()))
    }
}
```

Execution Result:

```text
a
b
c
```

### func reset(T)

```cangjie
public func reset(input: T): Unit
```

Function: Binds a new input stream and resets the state, but does not reset `capacity`.

Parameters:

- input: T - The input stream to be bound.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedInputStream
import std.io.IOException

main(): Unit {
    /* Create first input stream and write data */
    let inputStream1 = ByteBuffer()
    let sourceData1 = "First message: Hello".toArray()
    inputStream1.write(sourceData1)

    /* Create second input stream and write data */
    let inputStream2 = ByteBuffer()
    let sourceData2 = "Second message: World".toArray()
    inputStream2.write(sourceData2)

    /* Wrap the first input stream with BufferedInputStream */
    let bufferedStream = BufferedInputStream(inputStream1)

    /* Read partial data from the first input stream */
    var result1 = ""
    for (_ in 0..sourceData1.size) {
        let byte = bufferedStream.readByte()
        if (byte == None) {
            break
        }
        result1 += String.fromUtf8(byte.getOrThrow())
    }
    println(result1)

    /* Reset the input stream to the second input stream */
    bufferedStream.reset(inputStream2)
    var result2 = ""
    for (_ in 0..sourceData2.size) {
        let byte = bufferedStream.readByte()
        if (byte == None) {
            break
        }
        result2 += String.fromUtf8(byte.getOrThrow())
    }
    println(result2)
}
```

Execution Result:

```text
First message: Hello
Second message: World
```

### extend\<T> BufferedInputStream\<T> <: Resource where T <: Resource

```cangjie
extend<T> BufferedInputStream<T> <: Resource where T <: Resource
```

Function: Implements the [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource) interface for [BufferedInputStream](./io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream), enabling objects of this type to support automatic resource release in `try-with-resource` syntax contexts.

Parent Type:

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)

#### func close()

```cangjie
public func close(): Unit
```

Function: Closes the current stream.

> **Note:**
>
> After calling this method, no other interfaces of [BufferedInputStream](io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream) should be invoked, as it may lead to undefined behavior.

#### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Checks whether the current stream is closed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the current stream has been closed, otherwise returns `false`.

Example:

<!-- verify -->
```cangjie
import std.io.BufferedInputStream
import std.io.InputStream
import std.io.ByteBuffer

/**
 * Custom class A implementing both InputStream and Resource interfaces
 */
public class A <: InputStream & Resource {
    private var closed: Bool = false

    public func read(buffer: Array<Byte>): Int64 {
        let inputData = "Hello World".toArray()
        let inputStream = ByteBuffer(inputData)
        let num = inputStream.read(buffer)
        return num
    }

    public func isClosed(): Bool {
        return closed
    }

    public func close(): Unit {
        println("Resource is closed")
        closed = true
    }
}

main(): Unit {
    let bufferedStream = BufferedInputStream(A())

    /* Acquire resource using try-with-resource syntax */
    try (r = bufferedStream) {
        println("Get the resource")
        let data = Array<Byte>(11, repeat: 0)
        r.read(data)
        println(r.isClosed())
        println(String.fromUtf8(data))
    }

    /* Automatically calls close() to release resources */
    println(bufferedStream.isClosed())
}
```

Execution Result:

```text
Get the resource
false
Hello World
Resource is closed
true
```

### extend\<T> BufferedInputStream\<T> <: Seekable where T <: Seekable

```cangjie
extend<T> BufferedInputStream<T> <: Seekable where T <: Seekable
```

Function: Implements the [Seekable](./io_package_interfaces.md#interface-seekable) interface for [BufferedInputStream](./io_package_classes.md#class-bufferedinputstreamt-where-t--inputstream), supporting operations such as querying data length and moving the cursor.

Parent Types:

- [Seekable](io_package_interfaces.md#interface-seekable)

#### prop length

```cangjie
public prop length: Int64
```

Function: Returns the total amount of data in the current stream (in bytes).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### prop position

```cangjie
public prop position: Int64
```

Function: Returns the current cursor position.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### prop remainLength

```cangjie
public prop remainLength: Int64
```

Function: Returns the amount of unread data in the current stream (in bytes, does not include the data in the buffer).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - The specified position cannot be before the start of the data in the stream.
> - The specified position can exceed the end of the data in the stream.
> - Calling this function will first clear the buffer before moving the cursor position.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the position to move the cursor to.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset from the start of the stream data to the new position (in bytes).

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position is before the start of the data in the stream.

Example:

<!-- verify -->
```cangjie
import std.io.BufferedInputStream
import std.io.InputStream
import std.io.ByteBuffer
import std.io.Seekable
import std.io.SeekPosition
import std.io.IOException
import std.io.readToEnd

/**
 * Custom class A implementing InputStream and Seekable interfaces
 */
public class A <: InputStream & Seekable {
    public var inputStream: ByteBuffer = ByteBuffer()

    public func read(buffer: Array<Byte>): Int64 {
        let inputData = "Hello World".toArray()
        inputStream = ByteBuffer(inputData)
        let num = inputStream.read(buffer)
        return num
    }

    public func seek(sp: SeekPosition): Int64 {
        return inputStream.seek(sp)
    }
}

main(): Unit {
    let seekableStream = A()
    let bufferedStream = BufferedInputStream(seekableStream)
    let buffer = Array<Byte>(11, repeat: 0)
    bufferedStream.read(buffer)
    /* Output the total data volume in the current stream, current cursor position, and unread data volume in the stream */
    println("Length : " + bufferedStream.length.toString())
    println("Position : " + bufferedStream.position.toString())
    println("Remain Length : " + bufferedStream.remainLength.toString())

    /* Move cursor to specified position (legal even if exceeding the end of stream data) */
    println("Position after seek() : " + bufferedStream.seek(SeekPosition.Current(11)).toString())

    /* Attempt to move before data head (throws exception) */
    try {
        bufferedStream.seek(SeekPosition.Begin(-1))
    } catch (e: IOException) {
        println("Error: " + e.message)
    }

    /* Move cursor after the first word and read subsequent data */
    bufferedStream.seek(SeekPosition.Begin(6))
    println(String.fromUtf8(readToEnd(seekableStream.inputStream)))
}
```

Execution result:

```text
Length : 11
Position : 11
Remain Length : 0
Position after seek() : 22
Error: Can't move the position before the beginning of the stream.
World
```

## class BufferedOutputStream\<T> where T <: OutputStream

```cangjie
public class BufferedOutputStream<T> <: OutputStream where T <: OutputStream {
    public init(output: T)
    public init(output: T, buffer: Array<Byte>)
    public init(output: T, capacity: Int64)
}
```

Function: Provides buffered output stream functionality.

Can bind other [OutputStream](io_package_interfaces.md#interface-outputstream) type input streams (e.g., [ByteBuffer](io_package_classes.md#class-bytebuffer)) to [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream) instances. When writing data through this instance, data is first written to a buffer before being flushed to the underlying stream.

Parent types:

- [OutputStream](io_package_interfaces.md#interface-outputstream)

### init(T)

```cangjie
public init(output: T)
```

Function: Creates a [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream) instance with default buffer capacity of 4096.

Parameters:

- output: T - Binds the specified output stream.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream
import std.io.readToEnd

main(): Unit {
    let outputStream = ByteBuffer()
    /* Bind specified output stream */
    let bufferedStream = BufferedOutputStream(outputStream)

    /* Write output data to buffered stream and flush to internally bound output stream */
    let outputData = "Hello World".toArray()
    bufferedStream.write(outputData)
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream)))
}
```

Execution result:

```text
Hello World
```

### init(T, Array\<Byte>)

```cangjie
public init(output: T, buffer: Array<Byte>)
```

Function: Creates a [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream) instance.

The internal buffer is determined by the input parameter. In performance-critical scenarios, reusing the input `buffer` can reduce memory allocation frequency and improve performance.

Parameters:

- output: T - Binds an output stream.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The internal buffer used by [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream).

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the buffer size equals 0.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream

main(): Unit {
    let outputStream = ByteBuffer()

    /* Creates a BufferedOutputStream instance with a valid internal buffer, no exception thrown */
    try {
        let buffer = Array<Byte>(1024, repeat: 0)
        let bufferedStream = BufferedOutputStream(outputStream, buffer)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Case where internal buffer size is defined as 0 */
    try {
        let invalidBuffer = Array<Byte>()
        let bufferedStream = BufferedOutputStream(outputStream, invalidBuffer)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
Error: Invalid argument 'buffer': buffer size is 0.
```

### init(T, Int64)

```cangjie
public init(output: T, capacity: Int64)
```

Function: Creates a [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream) instance.

Parameters:

- output: T - Binds the specified output stream.
- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Internal buffer capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when capacity is less than or equal to 0.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream

main(): Unit {
    let outputStream = ByteBuffer()

    /* Creates a BufferedOutputStream instance with valid internal buffer capacity, no exception thrown */
    try {
        let capacity = 2048
        let bufferedStream = BufferedOutputStream(outputStream, capacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Throws exception when internal buffer is set to 0 */
    try {
        let zeroCapacity = 0
        let bufferedStream = BufferedOutputStream(outputStream, zeroCapacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }

    /* Throws exception when internal buffer is set to a negative value */
    try {
        let negativeCapacity = -1024
        let bufferedStream = BufferedOutputStream(outputStream, negativeCapacity)
    } catch (e: IllegalArgumentException) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
Error: Invalid capacity size: capacity = 0.
Error: Invalid capacity size: capacity = -1024.
```

### func flush()

```cangjie
public func flush(): Unit
```

Function: Flushes the [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream): Writes any remaining data from the internal buffer to the bound output stream and flushes the [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream).

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream
import std.io.readToEnd

main(): Unit {
    let outputStream = ByteBuffer()
    /* Bind the specified output stream */
    let bufferedStream = BufferedOutputStream(outputStream)

    /* Write output data to the buffered stream bufferedStream and flush the internally bound output stream outputStream */
    let outputData = "Hello World".toArray()
    bufferedStream.write(outputData)
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream)))
}
```

Execution Result:

```text
Hello World
```

### func reset(T)

```cangjie
public func reset(output: T): Unit
```

Function: Binds a new output stream and resets the state, but does not reset the `capacity`.

Parameters:

- output: T - The output stream to be bound.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream
import std.io.IOException
import std.io.readToEnd

main(): Unit {
    /* Create the first output stream */
    let outputStream1 = ByteBuffer()
    let sourceData1 = "First message: Hello".toArray()

    /* Create the second output stream */
    let outputStream2 = ByteBuffer()
    let sourceData2 = "Second message: World".toArray()

    /* Wrap the first output stream with BufferedOutputStream */
    let bufferedStream = BufferedOutputStream(outputStream1)

    /* Write the first source data to the bound first output stream and flush */
    bufferedStream.write(sourceData1)
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream1)))

    /* Reset the output stream to the second output stream, write the second source data to the bound second output stream, and flush */
    bufferedStream.reset(outputStream2)
    bufferedStream.write(sourceData2)
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream2)))
}
```

Execution Result:

```text
First message: Hello
Second message: World
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Writes the data from `buffer` to the bound output stream.

Parameters:- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer containing data to be written.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream
import std.io.readToEnd

main(): Unit {
    let outputStream = ByteBuffer()
    /* Bind the specified output stream */
    let bufferedStream = BufferedOutputStream(outputStream)

    /* Write output data to the buffered stream bufferedStream and flush the internally bound output stream outputStream */
    let outputData = "Hello World".toArray()
    bufferedStream.write(outputData)
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream)))
}
```

Execution Result:

```text
Hello World
```

### func writeByte(Byte)

```cangjie
public func writeByte(v: Byte): Unit
```

Function: Writes a single byte to the bound output stream.

Parameters:

- v: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - The byte to be written.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.BufferedOutputStream
import std.io.readToEnd

main(): Unit {
    let outputStream = ByteBuffer()
    /* Bind the specified output stream */
    let bufferedStream = BufferedOutputStream(outputStream)

    /* Write output data byte by byte to the buffered stream bufferedStream and flush the internally bound output stream outputStream */
    let outputData = "Hello World".toArray()
    for (byte in outputData) {
        bufferedStream.writeByte(byte)
    }
    bufferedStream.flush()
    println(String.fromUtf8(readToEnd(outputStream)))
}
```

Execution Result:

```text
Hello World
```

### extend\<T> BufferedOutputStream\<T> <: Resource where T <: Resource

```cangjie
extend<T> BufferedOutputStream<T> <: Resource where T <: Resource
```

Function: Implements the [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource) interface for [BufferedOutputStream](./io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream), enabling automatic resource release in `try-with-resource` syntax contexts.

Parent Type:

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)

#### func close()

```cangjie
public func close(): Unit
```

Function: Closes the current stream.

> **Note:**
>
> After calling this method, no other interfaces of [BufferedOutputStream](io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream) should be invoked, as it may lead to undefined behavior.

#### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Determines whether the current stream is closed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the current stream is closed, otherwise returns `false`.

Example:

<!-- verify -->
```cangjie
import std.io.BufferedOutputStream
import std.io.OutputStream
import std.io.ByteBuffer
import std.io.readToEnd

/**
 * Custom class A implementing the OutputStream and Resource interfaces
 */
public class A <: OutputStream & Resource {
    private var closed: Bool = false
    public var outputStream = ByteBuffer()

    public func write(buffer: Array<Byte>): Unit {
        this.outputStream = ByteBuffer(buffer)
    }

    public func isClosed(): Bool {
        return closed
    }

    public func close(): Unit {
        println("Resource is closed")
        closed = true
    }
}

main(): Unit {
    let resourceStream = A()
    let bufferedStream = BufferedOutputStream(resourceStream)

    /* Acquire resource using try-with-resource syntax */
    try (r = bufferedStream) {
        println("Get the resource")
        let data = "Hello World".toArray()
        r.write(data)
        r.flush()
        println(r.isClosed())
        println(String.fromUtf8(readToEnd(resourceStream.outputStream)))
    }

    /* Automatically calls close() to release resources */
    println(bufferedStream.isClosed())
}
```

Execution Result:

```text
Get the resource
false
Hello World
Resource is closed
true
```

### extend\<T> BufferedOutputStream\<T> <: Seekable where T <: Seekable

```cangjie
extend<T> BufferedOutputStream<T> <: Seekable where T <: Seekable
```

Function: Implements the [Seekable](./io_package_interfaces.md#interface-seekable) interface for [BufferedOutputStream](./io_package_classes.md#class-bufferedoutputstreamt-where-t--outputstream), supporting operations such as querying data length and moving the cursor.

Parent Type:

- [Seekable](io_package_interfaces.md#interface-seekable)

#### prop length

```cangjie
public prop length: Int64
```

Function: Returns the total amount of data in the current stream (in bytes).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### prop position

```cangjie
public prop position: Int64
```

Function: Returns the current cursor position.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### prop remainLength

```cangjie
public prop remainLength: Int64
```

Function: Returns the amount of unread data remaining in the current stream (in bytes).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - The specified position cannot be before the beginning of the stream data.
> - The specified position can exceed the end of the stream data.
> - Calling this function will first write buffered data to the bound output stream before moving the cursor position.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the target position after cursor movement.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the start of the stream data to the new cursor position.

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position is before the beginning of the stream data.

Example:

<!-- verify -->
```cangjie
import std.io.BufferedOutputStream
import std.io.OutputStream
import std.io.ByteBuffer
import std.io.Seekable
import std.io.SeekPosition
import std.io.IOException
import std.io.readToEnd

/**
 * Custom class A implementing OutputStream and Seekable interfaces
 */
public class A <: OutputStream & Seekable {
    public var outputStream: ByteBuffer = ByteBuffer()

    public func write(buffer: Array<Byte>): Unit {
        this.outputStream = ByteBuffer(buffer)
    }

    public func seek(sp: SeekPosition): Int64 {
        return outputStream.seek(sp)
    }
}

main(): Unit {
    let seekableStream = A()
    let bufferedStream = BufferedOutputStream(seekableStream)
    let data = "Hello World".toArray()
    bufferedStream.write(data)
    bufferedStream.flush()

    /* Output total data length, current cursor position, and remaining unread data length */
    println("Length : " + bufferedStream.length.toString())
    println("Position : " + bufferedStream.position.toString())
    println("Remain Length : " + bufferedStream.remainLength.toString())

    /* Move cursor to specified position (legal even when exceeding stream end) */
    println("Position after seek() : " + bufferedStream.seek(SeekPosition.Current(11)).toString())

    /* Attempt to move before stream beginning (throws exception) */
    try {
        bufferedStream.seek(SeekPosition.Begin(-1))
    } catch (e: IOException) {
        println("Error: " + e.message)
    }

    /* Move cursor after first word and read subsequent data */
    bufferedStream.seek(SeekPosition.Begin(6))
    println(String.fromUtf8(readToEnd(seekableStream.outputStream)))
}
```

Execution Result:

```text
Length : 11
Position : 0
Remain Length : 11
Position after seek() : 11
Error: Can't move the position before the beginning of the stream.
World
```

## class ByteBuffer

```cangjie
public class ByteBuffer <: IOStream & Seekable {
    public init()
    public init(capacity: Int64)
    public init(source: Array<Byte>)
}
```

Function: Based on the [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> data type, provides operations for reading and writing byte streams.

Parent Types:

- [IOStream](io_package_interfaces.md#interface-iostream)
- [Seekable](io_package_interfaces.md#interface-seekable)

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Gets the current buffer capacity.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The current buffer capacity.

### init()

```cangjie
public init()
```

Function: Creates a [ByteBuffer](io_package_classes.md#class-bytebuffer) instance with a default initial capacity of 32.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer()
    println(buffer.capacity)
}
```

Execution Result:

```text
32
```

<!--Del_sink-->
### init(this @local!)

```cangjie
public exclave init(this @local!)
```

Function: Creates a [ByteBuffer](io_package_classes.md#class-bytebuffer) instance. The default initial capacity is 32.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region
    let buffer: ByteBuffer @local! = ByteBuffer() @local!

    // Write data
    let data: Array<Byte> @local! = [72, 73] // HI
    buffer.write(data)

    // Read data
    buffer.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    let bytesRead = buffer.read(readBuf)
    println("Bytes read: ${bytesRead}")
    println("Content: ${readBuf[0]}, ${readBuf[1]}")
}
```

Output:

```text
Bytes read: 2
Content: 72, 73
```

<!--DelEnd_sink-->
### init(Array\<Byte>)

```cangjie
public init(source: Array<Byte>)
```

Function: Constructs a [ByteBuffer](io_package_classes.md#class-bytebuffer) instance from the provided array.

Parameters:

- source: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The input array.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let buffer = ByteBuffer(inputData)
    println(buffer.capacity)

    /* Read data from the buffer */
    println(String.fromUtf8(buffer.bytes()))
}
```

Execution Result:

```text
11
Hello World
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Creates a [ByteBuffer](io_package_classes.md#class-bytebuffer) instance.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified initial capacity.Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when capacity is less than 0.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer(1024)
    println(buffer.capacity)

    try {
        let errorBuffer = ByteBuffer(-1024)
        println(errorBuffer.capacity)
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
1024
Error: The capacity must be greater than or equal to 0: -1024.
```

<!--Del_sink-->
### init(this @local!, Int64)

```cangjie
public exclave init(this @local!, capacity: Int64)
```

Function: Creates a [ByteBuffer](io_package_classes.md#class-bytebuffer) instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.
- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified initial capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when capacity is less than 0.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance with the specified capacity in the local region
    let buffer: ByteBuffer @local! = ByteBuffer(16) @local!

    // Write data
    let data: Array<Byte> @local! = [82, 83] // RS
    buffer.write(data)

    // Read data
    buffer.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    let bytesRead = buffer.read(readBuf)
    println("Bytes read: ${bytesRead}")
    println("Content: ${readBuf[0]}, ${readBuf[1]}")

    // Thrown when capacity is less than 0
    try {
        let errorBuffer: ByteBuffer @local! = ByteBuffer(-1) @local!
        println("This line is unreachable")
    } catch (e: IllegalArgumentException) {
        println("Caught: ${e.message}")
    }
}
```

Output:

```text
Bytes read: 2
Content: 82, 83
Caught: The capacity must be greater than or equal to 0: -1.
```

<!--DelEnd_sink-->
### func bytes()

```cangjie
public func bytes(): Array<Byte>
```

Function: Gets a slice of the unread data in the current [ByteBuffer](io_package_classes.md#class-bytebuffer).

> **Note:**
>
> - Modifying operations on the buffer such as reading, writing, or resetting will invalidate this slice.
> - Modifications to the slice will affect the buffer's content.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - A slice of the unread data in the current stream.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let buffer = ByteBuffer(inputData)

    /* Read data from the buffer */
    println(String.fromUtf8(buffer.bytes()))
}
```

Execution Result:

```text
Hello World
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears all data in the current [ByteBuffer](io_package_classes.md#class-bytebuffer).

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let buffer = ByteBuffer(inputData)
    println(buffer.capacity)

    /* Read original data */
    println(String.fromUtf8(buffer.bytes()))

    /* Clear the buffer */
    buffer.clear()

    /* Read the cleared buffer */
    println("buffer after clear: " + String.fromUtf8(buffer.bytes()))
    println("capacity after clear: ${buffer.capacity}")
}
```

Execution Result:

```text
11
Hello World
buffer after clear:
capacity after clear: 11
```

### func clone()

```cangjie
public func clone(): ByteBuffer
```

Function: Constructs a new [ByteBuffer](io_package_classes.md#class-bytebuffer) using the data from the current [ByteBuffer](io_package_classes.md#class-bytebuffer).

Returns:

- [ByteBuffer](io_package_classes.md#class-bytebuffer) - The newly constructed [ByteBuffer](io_package_classes.md#class-bytebuffer) object.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let originalBuffer = ByteBuffer(inputData)

    /* Clone the original buffer */
    let clonedBuffer = originalBuffer.clone()

    println("originalBuffer: " + String.fromUtf8(originalBuffer.bytes()))
    println("clonedBuffer: " + String.fromUtf8(clonedBuffer.bytes()))

    /* Modify the data in the original buffer */
    originalBuffer.write(" New Data".toArray())

    println("originalBuffer: " + String.fromUtf8(originalBuffer.bytes()))
    println("clonedBuffer: " + String.fromUtf8(clonedBuffer.bytes()))
}
```

Execution Result:

```text
originalBuffer: Hello World
clonedBuffer: Hello World
originalBuffer: Hello World New Data
clonedBuffer: Hello World
```

### func read(Array\<Byte>)

```cangjie
public func read(buffer: Array<Byte>): Int64
```

Function: Reads data from the input stream into the specified buffer.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer to store the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of bytes read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the cursor is not at the end of the data and either `buffer` is empty or seek has moved the cursor past the end of the data (the internal remaining length is then negative, even when `buffer` is non-empty).

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let buffer = ByteBuffer(inputData)

    /* Create a target buffer and read data into it */
    let targetBuffer = Array<Byte>(5, repeat: 0)
    buffer.read(targetBuffer)
    println(String.fromUtf8(targetBuffer))

    /* Attempt to read into an empty buffer */
    try {
        let emptyBuffer = Array<Byte>()
        buffer.read(emptyBuffer)
    } catch (e: IllegalArgumentException) {
        println("Error: " + e.message)
    }
}
```

Execution Result:

```text
Hello
Error: Invalid argument 'buffer': buffer size is 0.
```

<!--Del_sink-->
### func read(Array\<Byte>)

```cangjie
public exclave func read(this @local!, buffer: Array<Byte> @local!): Int64
```

Function: Reads data from the bound input stream into `buffer`. When the cursor is exactly at the end of the data, this function directly returns 0 without checking whether `buffer` is empty.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The buffer that holds the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of bytes read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the cursor is not at the end of the data and either `buffer` is empty or seek has moved the cursor past the end of the data (the internal remaining length is then negative, even when `buffer` is non-empty).

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 3 bytes
    let buffer: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [65, 66, 67] // ABC
    buffer.write(data)

    // Move the cursor to the beginning of the data
    buffer.seek(SeekPosition.Begin(0))

    // Allocate the `@local!` buffer and read data
    let readBuf: Array<Byte> @local! = [0, 0]
    println("First read: ${buffer.read(readBuf)}")
    println("Second read: ${buffer.read(readBuf)}")
    println("Third read: ${buffer.read(readBuf)}")
}
```

Output:

```text
First read: 2
Second read: 1
Third read: 0
```

<!--DelEnd_sink-->
### func readByte()

```cangjie
public func readByte(): ?Byte
```

Function: Reads one byte from the input stream.

Returns:

- ?[Byte](../../core/core_package_api/core_package_types.md#type-byte) - The read data. Returns `None` if reading fails.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let inputData = "Hello World".toArray()
    let buffer = ByteBuffer(inputData)

    for (_ in 0..inputData.size) {
        print(String.fromUtf8(buffer.readByte().getOrThrow()))
    }
    println()

    /* Attempt to read the next non-existent byte */
    let nextByte = buffer.readByte()
    match (nextByte) {
        case None => println("nextByte: None")
        case _ => println("nextByte: ${nextByte.getOrThrow()}")
    }
}
```

Execution result:

```text
Hello World
nextByte: None
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Expands the buffer by the specified size.

> **Note:**
>
> - No expansion occurs when the remaining bytes in the buffer are greater than or equal to `additional`.
> - When the remaining bytes in the buffer are less than `additional`, the buffer is expanded to the maximum value between (`additional` + `capacity`) and (1.5 times `capacity` rounded down).

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to expand.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `additional` is less than 0.
- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when the expanded buffer size exceeds the maximum value of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer(11)
    println("initial capacity: " + buffer.capacity.toString())
    buffer.write("Hello World".toArray())

    /* Attempt to expand; required additional capacity exceeds remaining space, expansion occurs */
    buffer.reserve(5)
    println("reserve 5: " + buffer.capacity.toString())

    /* Attempt to expand; required additional capacity is less than remaining space, no expansion occurs */
    buffer.reserve(2)
    println("reserve 2: " + buffer.capacity.toString())

    /* Attempt to expand with negative additional value */
    try {
        buffer.reserve(-1)
    } catch (e: IllegalArgumentException) {
        println("Error: " + e.message)
    }

    /* Attempt to expand, causing capacity to exceed Int64 maximum value */
    try {
        buffer.reserve(Int64.Max - buffer.capacity + 1)
    } catch (e: OverflowException) {
        println("Error: " + e.message)
    }
}
```

Execution Result:

```text
initial capacity: 11
reserve 5: 16
reserve 2: 16
Error: The additional must be greater than or equal to 0.
Error: The maximum value for capacity expansion cannot exceed the maximum value of Int64.
```

<!--Del_sink-->
### func reserve(Int64)

```cangjie
public exclave func reserve(this @local!, additional: Int64): Unit
```

Function: Grows the buffer by the specified size.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - If the cursor has not passed the end of the data and the remaining capacity after the end of the data ≥ additional, the buffer is not grown and the function returns directly.
> - If the cursor has passed the end of the data and the remaining space from the cursor position to the end of the current capacity ≥ additional, the buffer is not grown and the function returns directly.
> - Otherwise the buffer is grown; the capacity after growth is the larger of the following two values:
>     1. 1.5 times the current capacity (the capacity of the buffer before growth), rounded down.
>     2. The minimum required capacity: the current capacity + additional if the cursor has not passed the end of the data; the cursor position + additional if the cursor has passed the end of the data.
> - additional being 0 does not guarantee no growth: if the cursor has been seeked to a position beyond the current capacity, the buffer is still grown by the rules above even when additional is 0.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to grow by.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when additional is less than 0.
- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when the grown buffer size exceeds the maximum value of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region
    let buffer: ByteBuffer @local! = ByteBuffer() @local!

    // Grow the buffer
    buffer.reserve(64)

    // Write data
    let data: Array<Byte> @local! = [84, 85] // TU
    buffer.write(data)

    // Read data
    buffer.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    buffer.read(readBuf)
    println("Content: ${readBuf[0]}, ${readBuf[1]}")

    // Thrown when additional is less than 0
    try {
        buffer.reserve(-1)
    } catch (e: IllegalArgumentException) {
        println("Caught: ${e.message}")
    }
}
```

Output:

```text
Content: 84, 85
Caught: The additional must be greater than or equal to 0.
```

<!--DelEnd_sink-->
### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - The specified position cannot be before the start of the data in the stream.
> - The specified position can exceed the end of the data in the stream.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the position after the cursor jump.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The offset in bytes from the start of the data in the stream to the new position after the jump.

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position is before the start of the data in the stream.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.SeekPosition
import std.io.IOException

main(): Unit {
    let buffer = ByteBuffer("Hello World".toArray())
    println("initial position: ${buffer.position}")

    /* Move 6 bytes forward from the current position */
    buffer.seek(SeekPosition.Current(6))
    println(String.fromUtf8(buffer.bytes()))

    /* Move position beyond the end of the stream data, which is a valid operation */
    println(buffer.seek(SeekPosition.End(1)))

    /* Attempt to move before the start of the data, throws an exception */
    try {
        buffer.seek(SeekPosition.Begin(-1))
    } catch (e: IOException) {
        println("Error: " + e.message)
    }
}
```

Execution Result:

```text
initial position: 0
World
12
Error: Can't move the position before the beginning of the stream.
```

<!--Del_sink-->
### func seek(SeekPosition)

```cangjie
public func seek(this @local!, sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - The specified position cannot precede the beginning of the data in the stream.
> - The specified position may exceed the end of the data in the stream.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - The position to move the cursor to.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The offset (in bytes) from the beginning of the data in the stream to the position after the jump.

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position precedes the beginning of the data in the stream.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 3 bytes
    let buffer: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [86, 87, 88] // VWX
    buffer.write(data)

    // Move the cursor to the beginning of the data and read the first byte
    let pos = buffer.seek(SeekPosition.Begin(0))
    println("Position after seek: ${pos}")
    let readBuf: Array<Byte> @local! = [0]
    buffer.read(readBuf)
    println("First byte: ${readBuf[0]}")
}
```

Output:

```text
Position after seek: 0
First byte: 86
```

<!--DelEnd_sink-->
### func setLength(Int64)

```cangjie
public func setLength(length: Int64): Unit
```

Function: Modifies the current data to the specified length. This operation does not change the seek offset.

Parameters:

- length: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The length to modify.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `length` is less than 0.
- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when the length is too large, causing the expanded buffer size to exceed the maximum value of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer("Hello World".toArray())
    println("initial length: " + buffer.length.toString())

    /* Set the length to 5 and read all the content in the buffer */
    buffer.setLength(5)
    println("set length to 5: " + String.fromUtf8(buffer.bytes()))

    /* An exception is thrown when trying to set the size of the expanded buffer to exceed the maximum value of Int64 */
    try {
        buffer.setLength(Int64.Max + 1)
    } catch (e: OverflowException) {
        println("Error: " + e.message)
    }

    /* Attempt to set length to -1, throw an exception */
    try {
        buffer.setLength(-1)
    } catch (e: IllegalArgumentException) {
        println("Error: " + e.message)
    }
}
```

Execution Result:

```text
initial length: 11
set length to 5: Hello
Error: add
Error: The length must be greater than or equal to 0.
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Write the data in `buffer` to the output stream.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer for writing data.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer()
    let dataToWrite = "Hello World".toArray()

    /* Write data */
    buffer.write(dataToWrite)
    println(String.fromUtf8(buffer.bytes()))
}
```

Execution Result:

```text
Hello World
```

<!--Del_sink-->
### func write(Array\<Byte>)

```cangjie
public exclave func write(this @local!, buffer: Array<Byte>): Unit
```

Function: Writes the data in `buffer` to the bound output stream.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer that holds the data to be written.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region
    let buffer: ByteBuffer @local! = ByteBuffer() @local!

    // Write the byte array on the heap
    let data: Array<Byte> = [77, 78] // MN
    buffer.write(data)

    // Read data
    buffer.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    let bytesRead = buffer.read(readBuf)
    println("Bytes read: ${bytesRead}")
    println("Content: ${readBuf[0]}, ${readBuf[1]}")
}
```

Output:

```text
Bytes read: 2
Content: 77, 78
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func write(Array\<Byte>)

```cangjie
public exclave func write(this @local!, buffer: Array<Byte> @local!): Unit
```

Function: Writes the data in `buffer` to the bound output stream.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The buffer that holds the data to be written.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region
    let buffer: ByteBuffer @local! = ByteBuffer() @local!

    // Write the `@local!` byte array
    let data: Array<Byte> @local! = [75, 76] // KL
    buffer.write(data)

    // Read data
    buffer.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    let bytesRead = buffer.read(readBuf)
    println("Bytes read: ${bytesRead}")
    println("Content: ${readBuf[0]}, ${readBuf[1]}")
}
```

Output:

```text
Bytes read: 2
Content: 75, 76
```

<!--DelEnd_sink-->
### func writeByte(Byte)

```cangjie
public func writeByte(v: Byte): Unit
```

Function: Writes a single byte to the output stream.

Parameters:

- v: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - The byte to be written.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer

main(): Unit {
    let buffer = ByteBuffer()
    let dataToWrite: Array<Byte> = "Hello World".toArray()

    /* Writing one byte at a time */
    for (i in 0..dataToWrite.size) {
        buffer.writeByte(dataToWrite[i])
    }

    println(String.fromUtf8(buffer.bytes()))
}
```

Execution Result:

```text
Hello World
```

## class ChainedInputStream\<T> where T <: InputStream

```cangjie
public class ChainedInputStream<T> <: InputStream where T <: InputStream {
    public init(input: Array<T>)
}
```

Function: Provides the capability to sequentially read data from an array of [InputStream](io_package_interfaces.md#interface-inputstream).

Parent Types:

- [InputStream](io_package_interfaces.md#interface-inputstream)

### init(Array\<T>)

```cangjie
public init(input: Array<T>)
```

Function: Creates an instance of [ChainedInputStream](io_package_classes.md#class-chainedinputstreamt-where-t--inputstream).

Parameters:

- input: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - Binds the specified input stream array.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when input is empty.

### func read(Array\<Byte>)

```cangjie
public func read(buffer: Array<Byte>): Int64
```

Function: Sequentially reads data from the bound [InputStream](io_package_interfaces.md#interface-inputstream) array into the buffer.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer for storing the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of bytes read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when buffer is empty.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    let inputData = "Hello World".toArray()
    let bufferInput = ByteBuffer(inputData)
    let cis = ChainedInputStream(bufferInput)

    // Buffer capacity is 7
    let bufferOutput = Array<Byte>(7, repeat: 0)
    cis.read(bufferOutput)
    let result = String.fromUtf8(bufferOutput)
    println(result)
}
```

Execution Result:

```text
Hello W
```

## class MultiOutputStream\<T> where T <: OutputStream

```cangjie
public class MultiOutputStream<T> <: OutputStream where T <: OutputStream {
    public init(output: Array<T>)
}
```

Function: Provides the capability to simultaneously write data to each output stream in the [OutputStream](io_package_interfaces.md#interface-outputstream) array.

Parent Types:

- [OutputStream](io_package_interfaces.md#interface-outputstream)

### init(Array\<T>)

```cangjie
public init(output: Array<T>)
```

Function: Create an instance of [MultiOutputStream](io_package_classes.md#class-multioutputstreamt-where-t--outputstream).

Parameters:

- output: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - Binds the specified array of output streams.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when output is empty.

### func flush()

```cangjie
public func flush(): Unit
```

Function: Flushes each output stream in the bound array of output streams.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Writes the buffer simultaneously to each output stream in the bound [OutputStream](io_package_interfaces.md#interface-outputstream) array.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer storing the data to be written.

## class StringReader\<T> where T <: InputStream

```cangjie
public class StringReader<T> where T <: InputStream {
    public init(input: T)
}
```

Function: Provides the capability to read data from an [InputStream](io_package_interfaces.md#interface-inputstream) and convert it into characters or strings.

> **Note:**
>
> - [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream) has a default internal buffer with a capacity of 4096 bytes.
> - [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream) currently only supports UTF-8 encoding and does not yet support UTF-16 or UTF-32.

### init(T)

```cangjie
public init(input: T)
```

Function: Creates an instance of [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream).

Parameters:

- input: T - The input stream from which data will be read.

### func lines()

```cangjie
public func lines(): Iterator<String>
```

Function: Obtains a line iterator for [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream).

Equivalent to repeatedly calling `func readln()`, and internally throws an exception when encountering illegal characters.

> **Note:**
>
> - Each line is separated by a line terminator.
> - Line terminators can be `\n`, `\r`, or `\r\n`.
> - Each line does not include the line terminator.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - A line iterator for strings.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Throws an exception when illegal characters are encountered during `for-in` or when calling the `next()` method.

### func read()

```cangjie
public func read(): ?Rune
```

Function: Reads data from the stream character by character.

Returns:

- ?[Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) - If the read is successful, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune)>.Some(c), where c is the character read; otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune)>.None.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Throws an exception when illegal characters are encountered during reading.

### func readToEnd()

```cangjie
public func readToEnd(): String
```

Function: Reads all remaining data from the stream.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - All remaining data in the stream.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when illegal characters are encountered during reading.

### func readUntil((Rune)->Bool)

```cangjie
public func readUntil(predicate: (Rune)->Bool): Option<String>
```

Function: Reads data from the stream up to (and including) the character position where `predicate` returns true or until the end of the stream.

Parameters:

- predicate: ([Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune))->Bool - An expression that returns `true` when a certain condition is met.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - If successful, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.Some(str), where str is the read string; otherwise returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.None.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when illegal characters are encountered during reading.

### func readUntil(Rune)

```cangjie
public func readUntil(v: Rune): Option<String>
```

Function: Reads data from the stream up to (and including) the specified character or until the end of the stream.

Parameters:

- v: [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) - The specified character.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - If successful, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.Some(str), where str is the read string; otherwise returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.None.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when illegal characters are encountered during reading.

### func readln()

```cangjie
public func readln(): Option<String>
```

Function: Reads data from the stream line by line.

> **Note:**
>
> - The read data will have the original line break characters removed.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - If successful, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.Some(str), where str is the read string; otherwise returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)>.None.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when illegal characters are encountered during reading.

### func runes()

```cangjie
public func runes(): Iterator<Rune>
```

Function: Obtains a [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) iterator for the [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream).

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<[Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune)> - A [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) iterator for the string.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when illegal characters are encountered during `for-in` iteration or when calling the `next()` method.

### extend\<T> StringReader\<T> <: Resource where T <: Resource

```cangjie
extend<T> StringReader<T> <: Resource where T <: Resource
```

Function: Implements the [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource) interface for [StringReader](./io_package_classes.md#class-stringreadert-where-t--inputstream), enabling automatic resource release in `try-with-resource` syntax contexts.

Parent Type:

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)

#### func close()

```cangjie
public func close(): Unit
```

Function: Closes the current stream.

> **Note:**
>
> After calling this method, no other interfaces of [StringReader](io_package_classes.md#class-stringreadert-where-t--inputstream) should be invoked, otherwise undefined behavior may occur.

#### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Determines whether the current stream is closed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the current stream has been closed, otherwise returns `false`.

### extend\<T> StringReader\<T> <: Seekable where T <: Seekable

```cangjie
extend<T> StringReader<T> <: Seekable where T <: Seekable
```

Function: Implements the [Seekable](./io_package_interfaces.md#interface-seekable) interface for [StringReader](./io_package_classes.md#class-stringreadert-where-t--inputstream), supporting operations such as querying data length and moving the cursor.

Parent Type:

- [Seekable](io_package_interfaces.md#interface-seekable)

#### prop position

```cangjie
public prop position: Int64
```

Function: Returns the current cursor position.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

#### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - The specified position cannot be before the start of the stream data.
> - The specified position can exceed the end of the stream data.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the position to which the cursor will be moved.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the start of the stream data to the new cursor position.

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position is before the start of the stream data.

## class StringWriter\<T> where T <: OutputStream

```cangjie
public class StringWriter<T> where T <: OutputStream {
    public init(output: T)
}
```

Function: Provides the capability to convert [String](../../core/core_package_api/core_package_structs.md#struct-string) and certain [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) types into strings with specified encoding formats and endian configurations, and write them to an output stream.

> **Note:**
>
> - [StringWriter](io_package_classes.md#class-stringwritert-where-t--outputstream) has an internal buffer by default, with a capacity of 4096 bytes.
> - [StringWriter](io_package_classes.md#class-stringwritert-where-t--outputstream) currently only supports UTF-8 encoding and does not yet support UTF-16 or UTF-32.

### init(T)

```cangjie
public init(output: T)
```

Function: Creates a [StringWriter](io_package_classes.md#class-stringwritert-where-t--outputstream) instance.

Parameters:

- output: T - The output stream to which data will be written.

### func flush()

```cangjie
public func flush(): Unit
```

Function: Flushes the internal buffer, writes the buffered data to the output, and flushes the output.

### func write(Bool)

```cangjie
public func write(v: Bool): Unit
```

Function: Writes a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type.

Parameters:

- v: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - An instance of the [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type.

### func write(Float16)

```cangjie
public func write(v: Float16): Unit
```

Function: Writes a [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) type.

Parameters:

- v: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - An instance of the [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) type.

### func write(Float32)

```cangjie
public func write(v: Float32): Unit
```

Function: Writes a [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) type.

Parameters:

- v: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - An instance of the [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) type.

### func write(Float64)

```cangjie
public func write(v: Float64): Unit
```

Function: Writes a [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type.

Parameters:

- v: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - An instance of the [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type.

### func write(Int16)

```cangjie
public func write(v: Int16): Unit
```

Function: Writes an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) type.

Parameters:

- v: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - An instance of the [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) type.

### func write(Int32)

```cangjie
public func write(v: Int32): Unit
```

Function: Writes an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) type.

Parameters:

- v: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - An instance of the [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) type.

### func write(Int64)

```cangjie
public func write(v: Int64): Unit
```

Function: Writes an [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type.

Parameters:

- v: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - An instance of the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type.

### func write(Int8)

```cangjie
public func write(v: Int8): Unit
```

Function: Writes an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) type.

Parameters:- v: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - An instance of [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) type.

### func write(Rune)

```cangjie
public func write(v: Rune): Unit
```

Function: Writes a [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) type.

Parameters:

- v: [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) - An instance of [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) type.

### func write(String)

```cangjie
public func write(v: String): Unit
```

Function: Writes a string.

Parameters:

- v: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be written.

### func write(UInt16)

```cangjie
public func write(v: UInt16): Unit
```

Function: Writes a [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) type.

Parameters:

- v: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - An instance of [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) type.

### func write(UInt32)

```cangjie
public func write(v: UInt32): Unit
```

Function: Writes a [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) type.

Parameters:

- v: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - An instance of [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) type.

### func write(UInt64)

```cangjie
public func write(v: UInt64): Unit
```

Function: Writes a [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type.

Parameters:

- v: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - An instance of [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type.

### func write(UInt8)

```cangjie
public func write(v: UInt8): Unit
```

Function: Writes a [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type.

Parameters:

- v: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - An instance of [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type.

### func write\<T>(T) where T <: ToString

```cangjie
public func write<T>(v: T): Unit where T <: ToString
```

Function: Writes a [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) type.

Parameters:

- v: T - An instance of [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) type.

### func writeln()

```cangjie
public func writeln(): Unit
```

Function: Writes a newline character.

### func writeln(Bool)

```cangjie
public func writeln(v: Bool): Unit
```

Function: Writes a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type + newline character.

Parameters:

- v: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - An instance of the [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type.

### func writeln(Float16)

```cangjie
public func writeln(v: Float16): Unit
```

Function: Writes a [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) type + newline character.

Parameters:

- v: [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) - An instance of the [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) type.

### func writeln(Float32)

```cangjie
public func writeln(v: Float32): Unit
```

Function: Writes a [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) type + newline character.

Parameters:

- v: [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) - An instance of the [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) type.

### func writeln(Float64)

```cangjie
public func writeln(v: Float64): Unit
```

Function: Writes a [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type + newline character.

Parameters:

- v: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - An instance of the [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type.

### func writeln(Int16)

```cangjie
public func writeln(v: Int16): Unit
```

Function: Writes an [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) type + newline character.

Parameters:

- v: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - An instance of the [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) type.

### func writeln(Int32)

```cangjie
public func writeln(v: Int32): Unit
```

Function: Writes an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) type + newline character.

Parameters:

- v: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - An instance of the [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) type.

### func writeln(Int64)

```cangjie
public func writeln(v: Int64): Unit
```

Function: Writes an [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type + newline character.

Parameters:

- v: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - An instance of the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type.

### func writeln(Int8)

```cangjie
public func writeln(v: Int8): Unit
```

Function: Writes an [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) type + newline character.

Parameters:

- v: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - An instance of the [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) type.

### func writeln(Rune)

```cangjie
public func writeln(v: Rune): Unit
```

Function: Writes a [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) type + newline character.

Parameters:- v: [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) - An instance of the [Rune](../../../std_en/core/core_package_api/core_package_intrinsics.md#rune) type.

### func writeln(String)

```cangjie
public func writeln(v: String): Unit
```

Function: Writes a string followed by a newline character.

Parameters:

- v: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be written.

### func writeln(UInt16)

```cangjie
public func writeln(v: UInt16): Unit
```

Function: Writes a [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) value followed by a newline character.

Parameters:

- v: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - An instance of the [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) type.

### func writeln(UInt32)

```cangjie
public func writeln(v: UInt32): Unit
```

Function: Writes a [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value followed by a newline character.

Parameters:

- v: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - An instance of the [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) type.

### func writeln(UInt64)

```cangjie
public func writeln(v: UInt64): Unit
```

Function: Writes a [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) value followed by a newline character.

Parameters:

- v: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - An instance of the [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) type.

### func writeln(UInt8)

```cangjie
public func writeln(v: UInt8): Unit
```

Function: Writes a [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) value followed by a newline character.

Parameters:

- v: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - An instance of the [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) type.

### func writeln\<T>(T) where T <: ToString

```cangjie
public func writeln<T>(v: T): Unit where T <: ToString
```

Function: Writes a [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) value followed by a newline character.

Parameters:

- v: T - An instance of the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) type.

### extend\<T> StringWriter\<T> <: Resource where T <: Resource

```cangjie
extend<T> StringWriter<T> <: Resource where T <: Resource
```

Function: Implements the [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource) interface for [StringWriter](./io_package_classes.md#class-stringwritert-where-t--outputstream), enabling automatic resource release in `try-with-resource` syntax contexts.

Parent Type:

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)

#### func close()

```cangjie
public func close(): Unit
```

Function: Closes the current stream.

> **Note:**
>
> After calling this method, no other interfaces of [StringWriter](io_package_classes.md#class-stringwritert-where-t--outputstream) should be invoked, as it may lead to undefined behavior.

#### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Determines whether the current stream is closed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the current stream has been closed, otherwise returns `false`.

### extend\<T> StringWriter\<T> <: Seekable where T <: Seekable

```cangjie
extend<T> StringWriter<T> <: Seekable where T <: Seekable
```

Function: Implements the [Seekable](./io_package_interfaces.md#interface-seekable) interface for [StringWriter](./io_package_classes.md#class-stringwritert-where-t--outputstream), supporting operations such as querying data length and moving the cursor.

Parent Type:

- [Seekable](io_package_interfaces.md#interface-seekable)

#### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

> **Note:**
>
> - The specified position cannot be before the head of the data in the stream.
> - The specified position can exceed the end of the data in the stream.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the position to which the cursor will be moved.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the start of the stream data to the new cursor position.

Exceptions:

- [IOException](io_package_exceptions.md#class-ioexception) - Thrown when the specified position is before the head of the data in the stream.