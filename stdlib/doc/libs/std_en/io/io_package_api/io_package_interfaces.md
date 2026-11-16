# Interface

## interface IOStream

```cangjie
public interface IOStream <: InputStream & OutputStream {}
```

Function: Input/output stream interface.

Parent types:

- [InputStream](#interface-inputstream)
- [OutputStream](#interface-outputstream)

## interface InputStream

```cangjie
public interface InputStream {
    func read(buffer: Array<Byte>): Int64
}
```

Function: Input stream interface.

### func read(Array\<Byte>)

```cangjie
func read(buffer: Array<Byte>): Int64
```

Function: Reads data from the input stream into `buffer`.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer for storing data read from the input stream.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of bytes read.

<!--Del_sink-->
### func read(Array\<Byte>)

```cangjie
func read(this @local!, buffer: Array<Byte> @local!): Int64
```

Function: Reads data from the input stream into `buffer`. When the current type does not override this local variant, the call hits the interface default implementation and no data is read.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The buffer that holds the data read from the input stream.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of bytes read.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override this local variant; the interface default implementation does not read any data and directly throws this exception.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region as the input stream
    let stream: ByteBuffer @local! = ByteBuffer() @local!

    // Write data
    let data: Array<Byte> @local! = [65, 66] // AB
    stream.write(data)

    // Move the cursor to the beginning of the data
    stream.seek(SeekPosition.Begin(0))

    // Allocate the `@local!` buffer and read data through read
    let buffer: Array<Byte> @local! = [0, 0]
    let bytesRead = stream.read(buffer)
    println("Bytes read: ${bytesRead}")
    println("Content: ${buffer[0]}, ${buffer[1]}")
}
```

Output:

```text
Bytes read: 2
Content: 65, 66
```

<!--DelEnd_sink-->
## interface OutputStream

```cangjie
public interface OutputStream {
    func write(buffer: Array<Byte>): Unit
    func flush(): Unit
}
```

Function: Output stream interface.

### func flush()

```cangjie
func flush(): Unit
```

Function: Flushes the buffer. The default implementation of this function is empty.

### func write(Array\<Byte>)

```cangjie
func write(buffer: Array<Byte>): Unit
```

Function: Writes data from `buffer` to the output stream.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer containing data to be written to the output stream.

<!--Del_sink-->
### func write(Array\<Byte>)

```cangjie
func write(this @local!, buffer: Array<Byte> @local!): Unit
```

Function: Writes the data in `buffer` to the output stream. When the current type does not override this local variant, the call hits the interface default implementation and no data is written.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The buffer that holds the data to be written to the output stream.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override this local variant; the interface default implementation does not write any data and directly throws this exception.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region as the output stream
    let stream: ByteBuffer @local! = ByteBuffer() @local!

    // Allocate the `@local!` buffer and write data through write
    let buffer: Array<Byte> @local! = [67, 68] // CD
    stream.write(buffer)

    // Read data to verify the write result
    stream.seek(SeekPosition.Begin(0))
    let readBuf: Array<Byte> @local! = [0, 0]
    stream.read(readBuf)
    println("Content: ${readBuf[0]}, ${readBuf[1]}")
}
```

Output:

```text
Content: 67, 68
```

<!--DelEnd_sink-->
## interface Seekable

```cangjie
public interface Seekable {
    prop length: Int64
    prop position: Int64
    prop remainLength: Int64
    func seek(sp: SeekPosition): Int64
}
```

Function: Cursor positioning interface.

### prop length

```cangjie
prop length: Int64
```

Function: Returns the total amount of data in the current stream (in bytes).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop length

```cangjie
prop length: Int64 @local!
```

Function: Returns the total amount of data in the current stream (in bytes). This property is implemented by calling the local variant of seek; when the current type does not override the local variant of seek, reading this property hits the interface default implementation of seek.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override the local variant of seek; reading the property propagates the exception thrown by the seek default implementation.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 3 bytes
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [69, 70, 71] // EFG
    stream.write(data)

    // Obtain the total amount of data in the stream
    println("Length: ${stream.length}")
}
```

Output:

```text
Length: 3
```

<!--DelEnd_sink-->
### prop position

```cangjie
prop position: Int64
```

Function: Returns the current cursor position.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop position

```cangjie
prop position: Int64 @local!
```

Function: Returns the current cursor position. This property is implemented by calling the local variant of seek; when the current type does not override the local variant of seek, reading this property hits the interface default implementation of seek.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override the local variant of seek; reading the property propagates the exception thrown by the seek default implementation.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 3 bytes
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [72, 73, 74] // HIJ
    stream.write(data)

    // Obtain the current cursor position
    println("Position before seek: ${stream.position}")

    // Move the cursor to position 2
    stream.seek(SeekPosition.Begin(2))
    println("Position after seek: ${stream.position}")
}
```

Output:

```text
Position before seek: 0
Position after seek: 2
```

<!--DelEnd_sink-->
### prop remainLength

```cangjie
prop remainLength: Int64
```

Function: Returns the amount of unread data in the current stream (in bytes).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop remainLength

```cangjie
prop remainLength: Int64 @local!
```

Function: Returns the amount of unread data in the current stream (in bytes). This property obtains the cursor position and the end of the data by calling the local variant of seek and computes the amount of unread data; when the current type does not override the local variant of seek, reading this property hits the interface default implementation of seek.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override the local variant of seek; reading the property propagates the exception thrown by the seek default implementation.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 3 bytes
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [75, 76, 77] // KLM
    stream.write(data)

    // Obtain the amount of unread data
    println("Remain length before seek: ${stream.remainLength}")

    // Move the cursor to position 2
    stream.seek(SeekPosition.Begin(2))
    println("Remain length after seek: ${stream.remainLength}")
}
```

Output:

```text
Remain length before seek: 3
Remain length after seek: 1
```

<!--DelEnd_sink-->
### func seek(SeekPosition)

```cangjie
func seek(sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

Parameters:

- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - Specifies the target position after cursor movement.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the start of the stream data to the new position.
<!--Del_sink-->
### func seek(SeekPosition)

```cangjie
func seek(this @local!, sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position. When the current type does not override this local variant, the call hits the interface default implementation and the cursor is not moved.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- sp: [SeekPosition](io_package_enums.md#enum-seekposition) - The position to move the cursor to.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the start of the data in the stream to the position after the move.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Thrown when the current type does not override this local variant; the interface default implementation does not move the cursor and directly throws this exception.

Example:

<!-- verify -->
```cangjie
import std.io.*

main(): Unit {
    // Create a ByteBuffer instance in the local region and write 2 bytes
    let stream: ByteBuffer @local! = ByteBuffer() @local!
    let data: Array<Byte> @local! = [78, 79] // NO
    stream.write(data)

    // Move the cursor to the beginning of the data and read the first byte
    let pos = stream.seek(SeekPosition.Begin(0))
    println("Position after seek: ${pos}")
    let buffer: Array<Byte> @local! = [0]
    stream.read(buffer)
    println("First byte: ${buffer[0]}")
}
```

Output:

```text
Position after seek: 0
First byte: 78
```

<!--DelEnd_sink-->