# Classes

## class Directory

```cangjie
public class Directory {}
```

Function: Represents a directory in the file system, providing capabilities for creation, movement, copying, deletion, attribute querying, and directory traversal.

> **Note:**
>
> An illegal path refers to any of the following cases:
>
> - Path contains illegal characters such as spaces, tabs, line breaks, etc.
> - Path contains invalid characters such as special characters or control characters.
> - Path contains non-existent directories or files.
> - Path contains inaccessible directories or files due to insufficient permissions or being locked.

When inputting paths, avoid using illegal characters to ensure path validity for correct access to target files or directories.

### static func create(Path, Bool)

```cangjie
public static func create(path: Path, recursive!: Bool = false): Unit
```

Function: Creates a directory.

Specifies whether to create recursively. If recursive creation is required, non-existent directories in the path will be created level by level.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - The directory path to be created.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to create directories recursively. true for recursive creation, false for non-recursive creation (default: false).

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the directory already exists, intermediate directories do not exist during non-recursive creation, insufficient permissions, or other reasons prevent directory creation.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the directory is empty, the current directory, the root directory, or contains null characters.

### static func create(String, Bool)

```cangjie
public static func create(path: String, recursive!: Bool = false): Unit
```

Function: Creates a directory.

Specifies whether to create recursively. If recursive creation is required, non-existent directories in the path will be created level by level.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The directory path string to be created.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to create directories recursively. true for recursive creation, false for non-recursive creation (default: false).

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the directory already exists, intermediate directories do not exist during non-recursive creation, insufficient permissions, or other reasons prevent directory creation.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the directory is empty, the current directory, the root directory, or contains null characters.

### static func createTemp(Path)

```cangjie
public static func createTemp(directoryPath: Path): Path
```

Function: Creates a temporary directory under the specified directory.

Parameters:

- directoryPath: [Path](fs_package_structs.md#struct-path) - The directory path in [Path](fs_package_structs.md#struct-path) format.

Returns:

- [Path](./fs_package_structs.md#struct-path) - The path corresponding to the temporary directory.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the directory does not exist or creation fails for other reasons.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the directory is empty or contains null characters.

### static func createTemp(String)

```cangjie
public static func createTemp(directoryPath: String): Path
```

Function: Creates a temporary directory under the specified directory.

Parameters:

- directoryPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The directory path string.

Returns:

- [Path](./fs_package_structs.md#struct-path) - The path corresponding to the temporary directory.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the directory does not exist or creation fails for other reasons.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the directory is empty or contains null characters.

### static func isEmpty(Path)

```cangjie
public static func isEmpty(path: Path): Bool
```

Function: Checks if the specified directory is empty.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The path corresponding to the directory to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the directory is empty, false otherwise.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or an error occurs in the underlying interface during checking.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

### static func isEmpty(String)

```cangjie
public static func isEmpty(path: String): Bool
```

Function: Checks if the specified directory is empty.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string corresponding to the directory to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the directory is empty, false otherwise.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or an error occurs in the underlying interface during checking.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

### static func readFrom(Path)

```cangjie
public static func readFrom(path: Path): Array<FileInfo>
```

Function: Retrieves the list of sub-items in the current directory.

The order of sub-items in the array depends on the system's file sorting.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The path corresponding to the directory whose sub-items are to be read.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[FileInfo](fs_package_structs.md#struct-fileinfo)> - The list of sub-items in the current directory.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or fails to retrieve member information.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

### static func readFrom(String)

```cangjie
public static func readFrom(path: String): Array<FileInfo>
```

Function: Retrieves the list of sub-items in the current directory.

The order of sub-items in the array depends on the system's file sorting.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string corresponding to the directory whose sub-items are to be read.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[FileInfo](./fs_package_structs.md#struct-fileinfo)> - The list of sub-items in the current directory.

Exceptions:

- [FSException](./fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or fails to retrieve member information.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

### static func walk(Path, (FileInfo)->Bool)

```cangjie
public static func walk(path: Path, f: (FileInfo)->Bool): Unit
```

Function: Traverses sub-items (non-recursive, excluding sub-directories' sub-items) under the directory corresponding to `path` and executes a callback function for each sub-item.

The `walk` function exits when traversal completes or the callback function `f` returns false. The traversal order depends on the system's file sorting.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The path corresponding to the directory to be traversed.
- f: ([FileInfo](./fs_package_structs.md#struct-fileinfo)) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The callback function executed for each sub-item. The input parameter is the metadata of the sub-item, and the return value indicates whether to continue traversal.

Exceptions:

- [FSException](./fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or fails to retrieve member information.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

### static func walk(String, (FileInfo)->Bool)

```cangjie
public static func walk(path: String, f: (FileInfo)->Bool): Unit
```

Function: Traverses sub-items (non-recursive, excluding sub-directories' sub-items) under the directory corresponding to `path` and executes a callback function for each sub-item.

The `walk` function exits when traversal completes or the callback function `f` returns false. The traversal order depends on the system's file sorting.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string corresponding to the directory to be traversed.
- f: ([FileInfo](./fs_package_structs.md#struct-fileinfo)) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The callback function executed for each sub-item. The input parameter is the metadata of the sub-item, and the return value indicates whether to continue traversal.

Exceptions:

- [FSException](./fs_package_exceptions.md#class-fsexception) - Throws an exception if the specified path does not exist, is not a directory, or fails to retrieve member information.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the specified path is empty or contains null characters.

## class File

```cangjie
public class File <: Resource & IOStream & Seekable {
    public init(path: String, mode: OpenMode)
    public init(path: Path, mode: OpenMode)
}
```

Function: Provides functions for file operations, including opening, creating, closing, moving, copying, deleting, stream-based read/write operations, attribute querying, and other functions.

> **Note:**
>
> An illegal path refers to any of the following cases:
>
> - Path contains illegal characters such as spaces, tabs, line breaks, etc.
> - Path contains invalid characters such as special characters or control characters.
> - Path contains non-existent directories or files.
> - Path contains inaccessible directories or files due to insufficient permissions or being locked.

When inputting paths, avoid using illegal characters to ensure path validity for correct access to target files or directories.

> **Warning:**
>
> The created [File](fs_package_classes.md#class-file) object will open the corresponding file by default. Call the [close](fs_package_classes.md#func-close) function promptly after use to avoid resource leaks.

Parent Types:

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)
- [IOStream](../../io/io_package_api/io_package_interfaces.md#interface-iostream)
- [Seekable](../../io/io_package_api/io_package_interfaces.md#interface-seekable)

### prop fileDescriptor

```cangjie
public prop fileDescriptor: FileDescriptor
```

Function: Retrieves file descriptor information.

Type: [FileDescriptor](fs_package_structs.md#struct-filedescriptor)

### prop info

```cangjie
public prop info: FileInfo
```

Function: Retrieves file metadata information.

Type: [FileInfo](fs_package_structs.md#struct-fileinfo)

### prop length

```cangjie
public prop length: Int64
```

Function: Retrieves the byte count of data from the file header to the file tail.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

<!--Del_sink-->
### prop length

```cangjie
public prop length: Int64 @local!
```

Function: Obtains the number of data bytes from the beginning to the end of the file.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_length_file.txt", recursive: true)

    // Create a file and write 3 bytes
    let writeData: Array<Byte> = [65, 66, 67] // ABC
    File.writeTo("./test_local_length_file.txt", writeData)

    // Open the `@local!` file and obtain the file length
    let path: String @local! = "./test_local_length_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!
    println("File length: ${file.length}")

    // Close the file
    file.close()

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_length_file.txt", recursive: true)
}
```

Output:

```text
File length: 3
```

<!--DelEnd_sink-->
### init(Path, OpenMode)

```cangjie
public init(path: Path, mode: OpenMode)
```

Function: Creates a [File](fs_package_classes.md#class-file) object.

Specifies the file path and opening mode (read/write permissions). The path supports both relative and absolute paths.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - The file path.
- mode: [OpenMode](fs_package_enums.md#enum-openmode) - The file opening mode.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the file does not exist when opened in read-only mode, the parent directory does not exist, or other reasons prevent file opening.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the path is empty or contains null characters.

### init(String, OpenMode)

```cangjie
public init(path: String, mode: OpenMode)
```

Function: Creates a [File](fs_package_classes.md#class-file) object.

Specifies the file path and opening mode (read/write permissions). The path supports both relative and absolute paths.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file path string.
- mode: [OpenMode](fs_package_enums.md#enum-openmode) - The file opening mode.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the file does not exist when opened in read-only mode, the parent directory does not exist, or other reasons prevent file opening.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the path is an empty string or contains null characters.

<!--Del_sink-->
### init(this @local!, String @local!, OpenMode @local!)

```cangjie
public exclave init(this @local!, path: String @local!, mode: OpenMode @local!)
```

Function: Creates a [File](fs_package_classes.md#class-file) object.

The file path and the file open mode (read/write permission) must be specified; both relative and absolute paths are supported.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The file path string.
- mode: [OpenMode](fs_package_enums.md#enum-openmode) @local! - The file open mode.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the file is opened in read-only mode but does not exist, if the parent directory of the file does not exist, or if the file cannot be opened for other reasons.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if path is an empty string or path contains a null character.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_init_file.txt", recursive: true)

    // Create a File object in the local region
    let path: String @local! = "./test_local_init_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // Verify that the file is created successfully
    println("Was the file created successfully? ${exists("./test_local_init_file.txt")}")

    // Close the file
    file.close()

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_init_file.txt", recursive: true)
}
```

Output:

```text
Was the file created successfully? true
```

<!--DelEnd_sink-->
### static func appendTo(Path, Array\<Byte>)

```cangjie
public static func appendTo(path: Path, buffer: Array<Byte>): Unit
```

Function: Opens the file at the specified path and writes the buffer in append mode. Creates the file if it does not exist.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - The file path.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The bytes to be written.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if file opening or writing fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the file path is empty or contains null characters.

### static func appendTo(String, Array\<Byte>)

```cangjie
public static func appendTo(path: String, buffer: Array<Byte>): Unit
```

Function: Opens the file at the specified path and writes the buffer in append mode. Creates the file if it does not exist.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file path string.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The bytes to be written.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if file opening or writing fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the file path is an empty string or contains null characters.

### static func create(Path)

```cangjie
public static func create(path: Path): File
```

Function: Creates a file at the specified path and returns a [File](#class-file) instance in write-only mode.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - The file path.

Returns:

- [File](fs_package_classes.md#class-file) - The [File](fs_package_classes.md#class-file) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the parent directory of the path does not exist or the file already exists.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the file path is empty or contains null characters.

### static func create(String)

```cangjie
public static func create(path: String): File
```

Function: Creates a file at the specified path and returns a [File](#class-file) instance in write-only mode.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file path string.

Returns:

- [File](fs_package_classes.md#class-file) - The [File](fs_package_classes.md#class-file) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Throws an exception if the parent directory of the path does not exist or the file already exists.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the file path is an empty string or contains null characters.

### static func createTemp(Path)

```cangjie
public static func createTemp(directoryPath: Path): File
```

Function: Creates a temporary file under the specified directory.

<!--Del_sink-->
### static func readFrom(String)

```cangjie
public static exclave func readFrom(path: String @local!): Array<Byte> @local!
```

Function: Reads the entire content of the file corresponding to the specified path; the returned byte array is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The file path string.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The byte array of the file content.

Exceptions:

- [FSException](./fs_package_exceptions.md#class-fsexception) - Thrown if the specified path does not exist or reading the file content fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified path is empty or contains a null character.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_read_from.txt", recursive: true)

    // Create the file and write data first
    let writeData: Array<Byte> = [74, 75, 76] // JKL
    File.writeTo("./test_local_read_from.txt", writeData)

    // Read the entire file content in the local region
    let path: String @local! = "./test_local_read_from.txt"
    let readData: Array<Byte> @local! = File.readFrom(path)
    println("Bytes read: ${readData.size}")
    println("Content: ${readData[0]}, ${readData[1]}, ${readData[2]}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_read_from.txt", recursive: true)
}
```

Output:

```text
Bytes read: 3
Content: 74, 75, 76
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func close()

```cangjie
public exclave func close(this @local!): Unit
```

Function: Closes the current [File](fs_package_classes.md#class-file) object.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the close fails.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_close_file.txt", recursive: true)

    // Create a File object in the local region
    let path: String @local! = "./test_local_close_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // Close the file
    file.close()
    println("File is closed after close: ${file.isClosed()}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_close_file.txt", recursive: true)
}
```

Output:

```text
File is closed after close: true
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func flush()

```cangjie
public func flush(this @local?): Unit
```

Function: Writes the buffered data to the stream. Since [File](fs_package_classes.md#class-file) has no buffer, this function has no actual effect.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_flush_file.txt", recursive: true)

    // Create a File object in the local region
    let path: String @local! = "./test_local_flush_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // Explicitly bind the `@local?` receiver
    let localFile: File @local? = file

    // Flush the buffer (File has no buffer, so this function has no actual effect)
    localFile.flush()
    println("File is open after flush: ${!localFile.isClosed()}")

    // Close the file
    file.close()

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_flush_file.txt", recursive: true)
}
```

Output:

```text
File is open after flush: true
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func isClosed()

```cangjie
public func isClosed(this @local?): Bool
```

Function: Determines whether the current [File](fs_package_classes.md#class-file) object is closed.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if closed, false if not closed.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_isclosed_file.txt", recursive: true)

    // Create a File object in the local region
    let path: String @local! = "./test_local_isclosed_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // Explicitly bind the `@local?` receiver
    let localFile: File @local? = file

    // Check whether the file is closed
    println("File is closed before close: ${localFile.isClosed()}")

    // Close the file
    file.close()
    println("File is closed after close: ${localFile.isClosed()}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_isclosed_file.txt", recursive: true)
}
```

Output:

```text
File is closed before close: false
File is closed after close: true
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func read(Array\<Byte>)

```cangjie
public exclave func read(this @local!, buffer: Array<Byte> @local!): Int64
```

Function: Reads data from the file into buffer.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - The buffer that holds the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - If the read succeeds, returns the number of bytes read; returns 0 if the file has been fully read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if buffer is empty.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the read fails, the file is closed, or the file is not readable.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_read_file.txt", recursive: true)

    // Create the file and write data first
    let writeData: Array<Byte> = [89, 90, 91] // YZ[
    File.writeTo("./test_local_read_file.txt", writeData)

    // Open the `@local!` file for reading
    let path: String @local! = "./test_local_read_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!

    // Allocate the `@local!` buffer
    let buffer: Array<Byte> @local! = [0, 0, 0]

    // Read data
    let bytesRead = file.read(buffer)
    println("Bytes read: ${bytesRead}")
    println("Content: ${buffer[0]}, ${buffer[1]}, ${buffer[2]}")

    // Close the file
    file.close()

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_read_file.txt", recursive: true)
}
```

Output:

```text
Bytes read: 3
Content: 89, 90, 91
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func seek(SeekPosition)

```cangjie
public func seek(this @local!, sp: SeekPosition): Int64
```

Function: Moves the cursor to the specified position.

The specified position cannot precede the beginning of the file; the position may exceed the end of the file, but the maximum offset from the beginning of the file must not exceed the maximum value allowed by the current file system, which is close to the maximum file size allowed by the current file system, generally the maximum file size minus 4096 bytes.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- sp: [SeekPosition](../../io/io_package_api/io_package_enums.md#enum-seekposition) - The position to move the cursor to.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the offset (in bytes) from the beginning of the file to the position after the jump.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the specified position does not satisfy the above conditions or the file cannot seek.

Example:

<!-- verify -->
```cangjie
import std.fs.*
import std.io.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_seek_file.txt", recursive: true)

    // Create the file and write data first
    let writeData: Array<Byte> = [65, 66, 67] // ABC
    File.writeTo("./test_local_seek_file.txt", writeData)

    // Open the `@local!` file for reading
    let path: String @local! = "./test_local_seek_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!

    // Allocate the `@local!` buffer
    let buffer: Array<Byte> @local! = [0]

    // Read one byte; the cursor is at 1
    file.read(buffer)
    println("First byte: ${buffer[0]}")

    // Move the cursor back to the beginning of the file
    let pos = file.seek(SeekPosition.Begin(0))
    println("Position after seek: ${pos}")

    // Read the first byte again
    file.read(buffer)
    println("First byte after seek: ${buffer[0]}")

    // Close the file
    file.close()

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_seek_file.txt", recursive: true)
}
```

Output:

```text
First byte: 65
Position after seek: 0
First byte after seek: 65
```

<!--DelEnd_sink-->

## class HardLink

```cangjie
public class HardLink
```

Function: Provides interfaces for handling filesystem hard links.

### static func create(Path, Path)

```cangjie
public static func create(link: Path, to!: Path): Unit
```

Function: Creates a new hard link to an existing path. If the new path already exists, it will not be overwritten.

Parameters:

- link: [Path](fs_package_structs.md#struct-path) - Name of the new path.
- to!: [Path](fs_package_structs.md#struct-path) - Name of the existing path.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when hard link creation fails.

### static func create(String, String)

```cangjie
public static func create(link: String, to!: String): Unit
```

Function: Creates a new hard link to an existing path. If the new path already exists, it will not be overwritten.

Parameters:

- link: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Name of the new path.
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Name of the existing path.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when hard link creation fails.

## class SymbolicLink

```cangjie
public class SymbolicLink
```

Function: Provides interfaces for handling filesystem symbolic links.

### static func create(Path, Path)

```cangjie
public static func create(link: Path, to!: Path): Unit
```

Function: Creates a new symbolic link to an existing path.

> **Note:**
>
> On Windows, when creating a symbolic link to a non-existent target, a file symbolic link will be created. If the target path is later created as a directory, the symbolic link will not function.

Parameters:

- link: [Path](fs_package_structs.md#struct-path) - The symbolic link to be created.
- to!: [Path](fs_package_structs.md#struct-path) - The target path of the symbolic link to be created.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when symbolic link creation fails.

### static func create(String, String)

```cangjie
public static func create(link: String, to!: String): Unit
```

Function: Creates a new symbolic link to an existing path.

> **Note:**
>
> On Windows, when creating a symbolic link to a non-existent target, a file symbolic link will be created. If the target path is later created as a directory, the symbolic link will not function.

Parameters:

- link: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The symbolic link to be created.
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path of the symbolic link to be created.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when symbolic link creation fails.

### static func readFrom(Path, Bool)

```cangjie
public static func readFrom(path: Path, recursive!: Bool = false): Path
```

Function: Retrieves the target of the specified symbolic link. When 'recursive' is set to 'true', it follows the link to the final target and returns the full path of the target. When 'recursive' is set to 'false', it reads the current target link and returns it.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - Address of the symbolic link.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively read the target address. Default is 'false'.

Returns:

- [Path](fs_package_structs.md#struct-path) - Target address of the symbolic link.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when reading the symbolic link fails.

### static func readFrom(String, Bool)

```cangjie
public static func readFrom(path: String, recursive!: Bool = false): Path
```

Function: Retrieves the target of the specified symbolic link. When 'recursive' is set to 'true', it follows the link to the final target and returns the full path of the target. When 'recursive' is set to 'false', it reads the current target link and returns it.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Address of the symbolic link.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively read the target address. Default is 'false'.

Returns:

- [Path](fs_package_structs.md#struct-path) - Target address of the symbolic link.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path parameter is empty or contains null characters.
- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when reading the symbolic link fails.