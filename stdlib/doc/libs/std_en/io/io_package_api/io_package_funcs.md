# Functions

## func copy(InputStream, OutputStream)

```cangjie
public func copy(from: InputStream, to!: OutputStream): Int64
```

Function: Copies unread data from an input stream to an output stream.

Parameters:

- from: [InputStream](io_package_interfaces.md#interface-inputstream) - The input stream to read data from.
- to!: [OutputStream](io_package_interfaces.md#interface-outputstream) - The output stream to copy data to.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of bytes copied.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.copy

main(): Unit {
    let sourceStream = ByteBuffer()
    let targetStream = ByteBuffer()

    /* Write data to source input stream */
    let sourceData = "Hello, World!".toArray()
    sourceStream.write(sourceData)

    /* Use copy function to transfer data from source to target stream */
    let copiedBytes = copy(sourceStream, to: targetStream)
    println("Copied ${copiedBytes} bytes.")

    /* Read data from target output stream */
    let targetData: Array<Byte> = Array<Byte>(sourceData.size, repeat: 0)
    targetStream.read(targetData)
    println("Data copied to target stream: ${String.fromUtf8(targetData)}")
}
```

Execution Result:

```text
Copied 13 bytes.
Data copied to target stream: Hello, World!
```

## func readString\<T>(T) where T <: InputStream & Seekable

```cangjie
public func readString<T>(from: T): String where T <: InputStream & Seekable
```

Function: Reads all remaining content from the parameter and returns a string.

Parameters:

- from: T - The object to read data from.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The resulting string read.

Exceptions:

- [ContentFormatException](io_package_exceptions.md#class-contentformatexception) - Thrown when remaining bytes don't conform to UTF-8 encoding rules.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readString
import std.io.ContentFormatException

main(): Unit {
    let inputStream = ByteBuffer()

    /* Write data to input stream */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* Use readString to read all remaining content */
    try {
        let result = readString(inputStream)
        println("Read string: ${result}")
    } catch (e: ContentFormatException) {
        println("Error: ${e.message}")
    }

    /* Write an invalid UTF-8 string to input stream */
    let sourceDataError: Array<UInt8> = [0xC3, 0x28, 0x48, 0x65, 0x6C, 0x6C, 0x6F]
    inputStream.write(sourceDataError)

    /* Use readString to read all remaining content */
    try {
        let result = readString(inputStream)
        println("Read string: ${result}")
    } catch (e: ContentFormatException) {
        println("Error: ${e.message}")
    }
}
```

Execution Result:

```text
Read string: Hello, World!
Error: Invalid unicode scalar value.
```

## func readStringUnchecked\<T>(T) where T <: InputStream & Seekable

```cangjie
public unsafe func readStringUnchecked<T>(from: T): String where T <: InputStream & Seekable
```

Function: Reads all remaining content from the parameter and returns a string without validation.

Parameters:

- from: T - The object to read data from.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The resulting string read.

Example:

<!-- run -->
```cangjie
import std.io.ByteBuffer
import std.io.readStringUnchecked
import std.io.ContentFormatException

main(): Unit {
    let inputStream = ByteBuffer()

    /* Write data to input stream */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* Use readString to read all remaining content (normal output: Read string: Hello, World!) */
    unsafe {
        let result = readStringUnchecked(inputStream)
        println("Read string: ${result}")
    }

    /* Write an invalid UTF-8 string to input stream */
    let sourceDataError: Array<UInt8> = [0xC3, 0x28, 0x48, 0x65, 0x6C, 0x6C, 0x6F]
    inputStream.write(sourceDataError)

    /* Using readString on invalid UTF-8 will produce unexpected output characters */
    unsafe {
        let result = readStringUnchecked(inputStream)
        println("Read string: ${result}")
    }
}
```

## func readToEnd\<T>(T) where T <: InputStream & Seekable

```cangjie
public func readToEnd<T>(from: T): Array<Byte> where T <: InputStream & Seekable
```

Function: Retrieves all unread data from the parameter.

Parameters:

- from: T - The object to read data from.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - A copy of the unread data.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readToEnd

main(): Unit {
    let inputStream = ByteBuffer()

    /* Write data to input stream */
    let sourceData = "Hello, World!".toArray()
    inputStream.write(sourceData)

    /* Use readToEnd to read all remaining content */
    let data = readToEnd(inputStream)
    println("${String.fromUtf8(data)}")
}
```

Execution Result:

```text
Hello, World!
```
<!--Del_sink-->
## func readToEnd\<T>(T) where T <: InputStream & Seekable

```cangjie
public exclave func readToEnd<T>(from: T @local!): Array<Byte> @local! where T <: InputStream & Seekable
```

Function: Obtains the unread data from the input; the returned byte array is located in the caller's local region. This function first obtains the total stream length through the local variant of the length property and then reads from the current cursor through the local variant of read; the implementation of length in turn depends on the local variant of seek.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- from: T @local! - The object to read data from.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - A copy of the unread data.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when `T` does not override the local variants of read or seek (length depends on seek) and the call hits the interface default implementations; the exception thrown by the default implementation propagates.

Example:

<!-- verify -->
```cangjie
import std.io.ByteBuffer
import std.io.readToEnd

main(): Unit {
    // Create a ByteBuffer instance in the local region as the input stream
    let inputStream: ByteBuffer @local! = ByteBuffer() @local!

    // Write data to the input stream
    let sourceData: Array<Byte> @local! = [72, 73, 74, 75] // HIJK
    inputStream.write(sourceData)

    // Use the readToEnd function to read the unread data in the input stream
    let data: Array<Byte> @local! = readToEnd(inputStream)
    println("Bytes read: ${data.size}")
    println("Content: ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]}")
}
```

Output:

```text
Bytes read: 4
Content: 72, 73, 74, 75
```

<!--DelEnd_sink-->