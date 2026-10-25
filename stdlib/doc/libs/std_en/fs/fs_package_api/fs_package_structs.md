# Structures

## struct FileDescriptor

```cangjie
public struct FileDescriptor
```

Function: Used to obtain file handle information.

<!--Del_sink-->
On platforms other than OpenHarmony, this structure also implements the [Copyable](../../core/core_package_api/core_package_interfaces.md#interface-copyable) interface.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

<!--DelEnd_sink-->

> **Description:**
>
> A file handle (File Handle) is a data structure allocated by the operating system to track files, used to identify an instance of an opened file. The file handle contains file metadata (such as filename, path, size, modification time, etc.) and the physical location of file data on disk.
>
> The form of file handles may vary across operating systems. In Unix and Linux systems, file handles are typically non-negative integers allocated by the OS kernel and returned to applications when opening files. In Windows systems, file handles are usually pointers to file objects, allocated by the OS kernel and returned to applications when opening files. Regardless of the form, applications can use file handles to perform operations like reading, writing, and modifying files.

### prop fileHandle

```cangjie
public prop fileHandle: IntNative
```

Function: Obtains file handle information.

Type: [IntNative](../../core/core_package_api/core_package_intrinsics.md#IntNative)

<!--Del_sink-->
### prop fileHandle

```cangjie
public prop fileHandle: IntNative @local?
```

Function: Obtains the file handle information.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) @local?

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_fd_file.txt", recursive: true)

    // Create a file
    let file = File.create("./test_local_fd_file.txt")

    // Obtain the file descriptor and explicitly bind the `@local?` view
    let fd: FileDescriptor @local? = file.fileDescriptor

    // The handle value is platform-dependent; here we only verify that repeated reads are consistent
    let first = fd.fileHandle
    let second = fd.fileHandle
    println("Same handle on repeated reads: ${first == second}")

    // Close and delete the file
    file.close()
    removeIfExists("./test_local_fd_file.txt", recursive: true)
}
```

Output:

```text
Same handle on repeated reads: true
```

<!--DelEnd_sink-->
## struct FileInfo

```cangjie
public struct FileInfo <: Equatable<FileInfo> {
    public init(path: Path)
    public init(path: String)
}
```

Function: Corresponds to file metadata in the file system.

> **Note:**
>
> File metadata refers to information related to files in the file system, including filename, file size, creation time, modification time, access time, file permissions, file owner, etc.
>
> The underlying implementation of [FileInfo](fs_package_structs.md#struct-fileinfo) does not directly cache file attributes. Each time the [FileInfo](fs_package_structs.md#struct-fileinfo) API is called, the latest file attributes are retrieved on the spot.
>
> Therefore, special attention is required: for the same [FileInfo](fs_package_structs.md#struct-fileinfo) instance, if the corresponding file entity is modified or replaced by other users or processes between two attribute retrieval operations, the latter retrieval may not yield the expected file attributes.
>
> If specific file operations require avoiding such scenarios, file permissions can be set or critical file operations can be locked to ensure consistency.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[FileInfo](#struct-fileinfo)>

### prop creationTime

```cangjie
public prop creationTime: DateTime
```

Function: Obtains the creation time.

Type: [DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### prop lastAccessTime

```cangjie
public prop lastAccessTime: DateTime
```

Function: Obtains the last access time.

Type: [DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### prop lastModificationTime

```cangjie
public prop lastModificationTime: DateTime
```

Function: Obtains the last modification time.

Type: [DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### prop name

```cangjie
public prop name: String
```

Function: Obtains the filename or directory name corresponding to the current instance.

This property is equivalent to `this.path.fileName`. For path resolution rules, refer to the [fileName](./fs_package_structs.md#prop-filename) property of the [Path](./fs_package_structs.md#struct-path) structure.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

<!--Del_sink-->
### prop name

```cangjie
public prop name: String @local?
```

Function: Obtains the filename or directory name corresponding to the current instance.

This property is equivalent to `this.path.fileName`. For path resolution rules, refer to the [fileName](./fs_package_structs.md#prop-filename) property of the [Path](./fs_package_structs.md#struct-path) structure.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local?

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_info_name.txt", recursive: true)

    // Create a file
    let file = File.create("./test_local_info_name.txt")

    // Create a FileInfo instance in the local region, explicitly bind the receiver as `@local?`,
    // and obtain the file name
    let path: String @local! = "./test_local_info_name.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // Delete; comment out the following line if you want to keep the file
    file.close()
    removeIfExists("./test_local_info_name.txt", recursive: true)
}
```

Output:

```text
File name: test_local_info_name.txt
```

<!--DelEnd_sink-->
### prop parentDirectory

```cangjie
public prop parentDirectory: Option<FileInfo>
```

Function: Obtains the parent directory metadata, returned as [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>. Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>.Some(v) if a parent exists; otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>.None.

Type: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>

### prop path

```cangjie
public prop path: Path
```

Function: Obtains the current file path, returned as a [Path](fs_package_structs.md#struct-path).

Type: [Path](fs_package_structs.md#struct-path)

<!--Del_sink-->
### prop path

```cangjie
public prop path: Path @local?
```

Function: Obtains the current file path, returned as a [Path](fs_package_structs.md#struct-path).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Path](fs_package_structs.md#struct-path) @local?

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_info_path.txt", recursive: true)

    // Create a file
    let file = File.create("./test_local_info_path.txt")

    // Create a FileInfo instance in the local region, explicitly bind the receiver as `@local?`,
    // and obtain the file path
    let path: String @local! = "./test_local_info_path.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    let infoPath: Path @local? = info.path
    println("File name in path: ${String(infoPath.fileName)}")

    // Delete; comment out the following line if you want to keep the file
    file.close()
    removeIfExists("./test_local_info_path.txt", recursive: true)
}
```

Output:

```text
File name in path: test_local_info_path.txt
```

<!--DelEnd_sink-->
### prop size

```cangjie
public prop size: Int64
```

Function: Returns the current file size.

- For files, this represents the disk space occupied by the file.
- For directories, this represents the total disk space occupied by all files in the directory.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

<!--Del_sink-->
### prop size

```cangjie
public prop size: Int64 @local?
```

Function: Returns the current file size.

- For a file, this represents the disk space occupied by the single file.
- For a directory, this represents the total disk space occupied by all files in the directory.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local?

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_info_size.txt", recursive: true)

    // Create a file and write 4 bytes
    let writeData: Array<Byte> = [83, 105, 122, 101] // "Size"
    File.writeTo("./test_local_info_size.txt", writeData)

    // Create a FileInfo instance in the local region, explicitly bind the receiver as `@local?`,
    // and obtain the file size
    let path: String @local! = "./test_local_info_size.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    println("File size equals written bytes: ${info.size == 4}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_info_size.txt", recursive: true)
}
```

Output:

```text
File size equals written bytes: true
```

<!--DelEnd_sink-->
### init(Path)

```cangjie
public init(path: Path)
```

Function: Creates a [FileInfo](fs_package_structs.md#struct-fileinfo) instance.

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - The directory path in [Path](fs_package_structs.md#struct-path) form.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path is invalid.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

### init(String)

```cangjie
public init(path: String)
```

Function: Creates a [FileInfo](fs_package_structs.md#struct-fileinfo) instance.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The directory path in [String](../../core/core_package_api/core_package_structs.md#struct-string) form.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path is invalid.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

<!--Del_sink-->
### init(this @local!, Path @local!)

```cangjie
public exclave init(this @local!, path: Path @local!)
```

Function: Creates a [FileInfo](fs_package_structs.md#struct-fileinfo) instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.
- path: [Path](fs_package_structs.md#struct-path) @local! - The directory path in [Path](fs_package_structs.md#struct-path) form.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path is invalid.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_info_init_path.txt", recursive: true)

    // Create a file
    let file = File.create("./test_local_info_init_path.txt")

    // Create a FileInfo instance from the Path instance in the local region
    let rawPath: String @local! = "./test_local_info_init_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    let info: FileInfo @local! = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // Delete; comment out the following line if you want to keep the file
    file.close()
    removeIfExists("./test_local_info_init_path.txt", recursive: true)
}
```

Output:

```text
File name: test_local_info_init_path.txt
```

<!--DelEnd_sink-->

<!--Del_sink-->
### init(this @local!, String @local!)

```cangjie
public exclave init(this @local!, path: String @local!)
```

Function: Creates a [FileInfo](fs_package_structs.md#struct-fileinfo) instance.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The directory path in [String](../../core/core_package_api/core_package_structs.md#struct-string) form.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path is invalid.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_info_init_string.txt", recursive: true)

    // Create a file
    let file = File.create("./test_local_info_init_string.txt")

    // Create a FileInfo instance from the path string in the local region
    let path: String @local! = "./test_local_info_init_string.txt"
    let info: FileInfo @local! = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // Delete; comment out the following line if you want to keep the file
    file.close()
    removeIfExists("./test_local_info_init_string.txt", recursive: true)
}
```

Output:

```text
File name: test_local_info_init_string.txt
```

<!--DelEnd_sink-->
### func canExecute()

```cangjie
public func canExecute(): Bool
```

Function: Determines whether the current user has permission to execute the file corresponding to this instance.

- For files, checks if the user has execute permission.
- For directories, checks if the user has permission to enter the directory.
- On Windows, execute permission for files is determined by the file extension; users always have execute permission for directories, and this function returns true without effect.
- On Linux and macOS, this function works as expected.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates permission; false indicates no permission.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func canRead()

```cangjie
public func canRead(): Bool
```

Function: Determines whether the current user has permission to read the file corresponding to this instance.

- For files, checks if the user has read permission.
- For directories, checks if the user has permission to browse the directory.
- On Windows, users always have read permission for files and directories, and this function returns true without effect.
- On Linux and macOS, this function works as expected.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates permission; false indicates no permission.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func canWrite()

```cangjie
public func canWrite(): Bool
```

Function: Determines whether the current user has permission to write to the file corresponding to this instance.

- For files, checks if the user has write permission.
- For directories, checks if the user has permission to delete, move, or create files within the directory.
- On Windows, write permission for files works as expected; users always have write permission for directories, and this function returns true without effect.
- On Linux and macOS, this function works as expected.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates permission; false indicates no permission.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func isDirectory()

```cangjie
public func isDirectory(): Bool
```

Function: Determines whether the current file is a directory.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates a directory; false indicates not a directory.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func isHidden()

```cangjie
public func isHidden(): Bool
```

Function: Determines whether the current file is hidden.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates hidden; false indicates not hidden.

### func isReadOnly()

```cangjie
public func isReadOnly(): Bool
```

Function: Determines whether the current file is read-only.

- On Windows, read-only permission for files works as expected; users always have delete/modify permission for directories, and this function returns false without effect.
- On Linux and macOS, this function works as expected.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates read-only; false indicates not read-only.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func isRegular()

```cangjie
public func isRegular(): Bool
```

Function: Determines whether the current file is a regular file.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates a file; false indicates not a file.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func isSymbolicLink()

```cangjie
public func isSymbolicLink(): Bool
```

Function: Determines whether the current file is a symbolic link.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates a symbolic link; false indicates not a symbolic link.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if an error occurs in the underlying interface during the operation.

### func setExecutable(Bool)

```cangjie
public func setExecutable(executable: Bool): Bool
```

Function: Sets whether the file owner has execute permission for the file corresponding to this instance. Throws an exception if the current user lacks permission to modify.

- For files, sets execute permission.
- For directories, sets permission to enter the directory.
- On Windows, execute permission for files is determined by the file extension; users always have execute permission for directories, and this function returns false without effect.
- On Linux and macOS, this function works as expected. If the file entity corresponding to this [FileInfo](fs_package_structs.md#struct-fileinfo) is modified by other users or processes during this function call, race conditions may cause other modifications to fail. Processes running as a privileged user may bypass this permission setting.

Parameters:

- executable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to set as executable.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates success; false indicates failure.

### func setReadable(Bool)

```cangjie
public func setReadable(readable: Bool): Bool
```

Function: Sets whether the file owner has read permission for the file corresponding to this instance. Throws an exception if the current user lacks permission to modify.

- For files, sets read permission.
- For directories, sets permission to browse the directory.
- On Windows, users always have read permission for files and directories, and this function returns true if `readable` is true, otherwise false.
- On Linux and macOS, this function works as expected. If the file entity corresponding to this [FileInfo](fs_package_structs.md#struct-fileinfo) is modified by other users or processes during this function call, race conditions may cause other modifications to fail. Processes running as a privileged user may bypass this permission setting.

Parameters:

- readable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to set as readable.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates success; false indicates failure.

### func setWritable(Bool)

```cangjie
public func setWritable(writable: Bool): Bool
```

Function: Sets whether the file owner has write permission for the file corresponding to this instance. Throws an exception if the current user lacks permission to modify.

- For files, sets write permission.
- For directories, sets permission to delete, move, or create files within the directory.
- On Windows, write permission for files works as expected; users always have write permission for directories, and this function returns false without effect.
- On Linux and macOS, this function works as expected. If the file entity corresponding to this [FileInfo](fs_package_structs.md#struct-fileinfo) is modified by other users or processes during this function call, race conditions may cause other modifications to fail.

Parameters:

- writable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to set as writable.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates success; false indicates failure.

### operator func ==(FileInfo)

```cangjie
public operator func ==(that: FileInfo): Bool
```

Function: Determines whether the current [FileInfo](fs_package_structs.md#struct-fileinfo) and another [FileInfo](fs_package_structs.md#struct-fileinfo) correspond to the same file.

Parameters:

- that: [FileInfo](fs_package_structs.md#struct-fileinfo) - Another [FileInfo](fs_package_structs.md#struct-fileinfo).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates the same file; false indicates different files.

## struct Path

```cangjie
public struct Path <: Equatable<Path> & Hashable & ToString {
    public static const Separator: String = PATH_SEPARATOR
    public static const ListSeparator: String = PATH_LISTSEPARATOR
    public init(rawPath: String)
}
```

Function: Provides path-related functions.

Path is used to represent local paths (DOS device paths and UNC paths are supported on Windows, with length limits following the system). The maximum supported string length is 4096 bytes (including the terminator `\0`).

> **Note:**
>
> An illegal path refers to any of the following:
>
> - The path contains illegal characters, such as spaces, tabs, or newlines.
> - The path contains invalid characters, such as special or control characters.
> - The path contains non-existent directories or files.
> - The path contains inaccessible directories or files, such as due to insufficient permissions or locks.
>
> When entering paths, avoid illegal characters to ensure path validity and correct access to target files or directories.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[Path](#struct-path)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)### static const ListSeparator

```cangjie
public static const ListSeparator: String = PATH_LISTSEPARATOR
```

Function: Retrieves the path list separator used to delimit different paths in a path list.

On Windows systems, the path list separator is ";", while on non-Windows systems it is ":".

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

### static const Separator

```cangjie
public static const Separator: String = PATH_SEPARATOR
```

Function: Retrieves the path separator used to delimit directory levels.

On Windows systems, the separator is "\\", while on non-Windows systems it is "/".

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

### prop extensionName

```cangjie
public prop extensionName: String
```

Function: Gets the file extension part of the [Path](fs_package_structs.md#struct-path).

The filename `fileName` is divided into two parts based on the last occurrence of r'.': the filename without extension `fileNameWithoutExtension` and the extension `extensionName`. Returns an empty string if no extension exists.

- For path "./NewFile.txt", this property returns `"txt"`.
- For path "./.gitignore", this property returns `"gitignore"`.
- For path "./noextension", this property returns `""`.
- For path "./a.b.c", this property returns `"c"`.
- For path "./NewFile.txt/", this property returns `"txt"`.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

### prop fileName

```cangjie
public prop fileName: String
```

Function: Gets the filename part (including extension) of the [Path](fs_package_structs.md#struct-path).

The entire path string is divided into `parent` and `fileName` parts. See [parent](./fs_package_structs.md#prop-parent) for details. Returns an empty string if no filename exists.

Examples applicable to all systems:

- For path "./NewFile.txt", this property returns "NewFile.txt";
- For path "./.gitignore", this property returns ".gitignore";
- For path "./noextension", this property returns "noextension";
- For path "./a.b.c", this property returns "a.b.c";
- For path "./NewDir/", this property returns "NewDir";

Note: In Windows file systems, `fileName` does not include the volume name part.

Windows-specific examples:

- For path "c:\\a.txt", this property returns "a.txt";
- For path "c:", this property returns "";
- For path "\\\\Server\\Share\\a.txt", this property returns "a.txt";
- For path "\\\\Server\\Share\\", this property returns "";
- For path "\\\\?\\C:a\\b.txt", this property returns "b.txt";
- For path "\\\\?\\C:", this property returns "".

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

<!--Del_sink-->
### prop fileName

```cangjie
public prop fileName: String @local?
```

Function: Obtains the filename (including extension) part of the [Path](fs_package_structs.md#struct-path).

The entire path string is divided into parent and fileName parts; see [parent](./fs_package_structs.md#prop-parent). Returns an empty string when there is no filename.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local?

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Create a Path instance in the local region, explicitly bind the receiver as `@local?`,
    // and obtain the file name
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    println("File name: ${String(path.fileName)}")
}
```

Output:

```text
File name: test_local_path.txt
```

<!--DelEnd_sink-->
### prop fileNameWithoutExtension

```cangjie
public prop fileNameWithoutExtension: String
```

Function: Gets the filename part (excluding extension) of the [Path](fs_package_structs.md#struct-path).

The filename `fileName` is divided into two parts based on the last occurrence of r'.': the filename without extension `fileNameWithoutExtension` and the extension `extensionName`. Returns an empty string if no filename (without extension) exists.

- For path "./NewFile.txt", this property returns `"NewFile"`.
- For path "./.gitignore", this property returns `""`.
- For path "./noextension", this property returns `"noextension"`.
- For path "./a.b.c", this property returns `"a.b"`.
- For path "./NewFile/", this property returns `"NewFile"`.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

### prop parent

```cangjie
public prop parent: Path
```

Function: Gets the parent path of this [Path](fs_package_structs.md#struct-path) instance.

The entire path string is divided into `parent` and `fileName`, using the last valid file separator (trailing separators are ignored) as the boundary. If `parent` doesn't exist, returns a Path instance constructed with an empty string. Neither `parent` nor `fileName` includes trailing separators, but `parent` retains the root directory separator. Returns an empty [Path](./fs_package_structs.md#struct-path) instance when no parent directory exists.

This property does not access the file system or resolve special names. Use with normalization if needed.

Behavior varies by OS: On Windows, file separators are "\\" or "/" (normalized to "\\"); on Linux/macOS, it's "/".

Examples applicable to all systems:

- For path "/a/b/c", returns Path("/a/b");
- For path "/a/b/", returns Path("/a");
- For path "/a", returns Path("/");
- For path "/", returns Path("/");
- For path "./a/b", returns Path("./a");
- For path "./", returns Path("");
- For path ".gitignore", returns Path("");
- For path "/a/./../b", returns Path("/a/./..").

Windows-specific behavior: Paths are divided into volume name, directory name, and filename (see Microsoft documentation). The `parent` property includes volume and directory names.

Windows-specific examples:

- For path "C:", returns Path("C:");
- For path "C:\\a\\b", returns Path("C:\\a");
- For path "\\\\Server\\Share\\xx\\yy", returns Path("\\\\Server\\Share\\xx");
- For path "\\\\?\\UNC\\Server\\Share\\xx\\yy", returns Path("\\\\?\\UNC\\Server\\Share\\xx");
- For path "\\\\?\\c:\\xx\\yy", returns Path("\\\\?\\c:\\xx").

Type: [Path](fs_package_structs.md#struct-path)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

<!--Del_sink-->
### prop parent

```cangjie
public prop parent: Path @local!
```

Function: Obtains the parent path of this [Path](fs_package_structs.md#struct-path) instance; the returned [Path](fs_package_structs.md#struct-path) instance is bound to the caller's local region.

The entire path string is divided into parent and fileName, delimited by the last valid file separator (trailing separators are ignored). If parent does not exist, a Path instance constructed from an empty string is returned. Neither the parent nor the fileName part contains a trailing separator, and parent keeps the separator that represents the root directory. When there is no parent directory, an empty [Path](./fs_package_structs.md#struct-path) instance is returned.

This property does not access the file system and does not eliminate special names. If needed, it can be used together with canonicalization.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: [Path](fs_package_structs.md#struct-path) @local!

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Create a Path instance in the local region and obtain the parent path
    let rawPath: String @local! = "./dir/test_local_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    let parent: Path @local! = path.parent
    println("Parent path: ${String(parent.toString())}")
}
```

Output:

```text
Parent path: ./dir
```

<!--DelEnd_sink-->
### init(String)

```cangjie
public init(rawPath: String)
```

Function: Creates a [Path](fs_package_structs.md#struct-path) instance without validating path string legality. Supports both absolute and relative paths.

Parameters:

- rawPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string.

<!--Del_sink-->
### init(this @local!, String @local!)

```cangjie
public exclave init(this @local!, rawPath: String @local!)
```

Function: Creates a [Path](fs_package_structs.md#struct-path) instance; the path string is not checked for validity at creation time, and both absolute and relative paths are supported. The created instance is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The `@local!` instance being constructed.
- rawPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The path string.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Create a Path instance from the string in the local region
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    println("Path: ${String(path.toString())}")
}
```

Output:

```text
Path: ./test_local_path.txt
```

<!--DelEnd_sink-->
### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value of the [Path](fs_package_structs.md#struct-path).

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The hash value of the [Path](fs_package_structs.md#struct-path).

### func isAbsolute()

```cangjie
public func isAbsolute(): Bool
```

Function: Determines whether the [Path](fs_package_structs.md#struct-path) is absolute. On Unix systems, paths starting with `/` are absolute.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if absolute; false otherwise.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

<!--Del_sink-->
### func isAbsolute()

```cangjie
public func isAbsolute(this @local?): Bool
```

Function: Determines whether the [Path](fs_package_structs.md#struct-path) is an absolute path. In Unix, a path starting with `/` is an absolute path.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if it is an absolute path; false if not.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Create a relative path instance in the local region and check whether it is an absolute path
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    println("Is absolute path: ${path.isAbsolute()}")
}
```

Output:

```text
Is absolute path: false
```

<!--DelEnd_sink-->
### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the current instance is an empty path.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the current instance is an empty path; otherwise, false.

<!--Del_sink-->
### func isEmpty()

```cangjie
public func isEmpty(this @local?): Bool
```

Function: Determines whether the current instance is an empty path.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the current instance is an empty path, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Create empty and non-empty path instances in the local region and check whether they are empty paths
    let rawEmpty: String @local! = ""
    let emptyPath: Path @local? = Path(rawEmpty) @local!
    let rawNonEmpty: String @local! = "./test_local_path.txt"
    let nonEmptyPath: Path @local? = Path(rawNonEmpty) @local!
    println("Empty path is empty: ${emptyPath.isEmpty()}")
    println("Non-empty path is empty: ${nonEmptyPath.isEmpty()}")
}
```

Output:

```text
Empty path is empty: true
Non-empty path is empty: false
```

<!--DelEnd_sink-->
### func isRelative()

```cangjie
public func isRelative(): Bool
```

Function: Determines whether the [Path](fs_package_structs.md#struct-path) is relative. The result is opposite to [isAbsolute](fs_package_structs.md#func-isAbsolute).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if relative; false otherwise.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

### func join(Path)

```cangjie
public func join(path: Path): Path
```

Function: Concatenates another path string to the current path to form a new path.

- For paths "a/b" and "c", returns "a/b/c".
- For paths "a" and "b/c", returns "a/b/c".

Parameters:

- path: [Path](fs_package_structs.md#struct-path) - Another [Path](fs_package_structs.md#struct-path).

Returns:

- [Path](fs_package_structs.md#struct-path) - A new [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the parameter `path` is absolute.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the current path is empty or either path is invalid.

### func join(String)

```cangjie
public func join(path: String): Path
```

Function: Concatenates another path string to the current path to form a new path.

- For paths "a/b" and "c", returns "a/b/c".
- For paths "a" and "b/c", returns "a/b/c".

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Another path string.

Returns:

- [Path](fs_package_structs.md#struct-path) - A new [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the parameter `path` is absolute.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the current path is empty or either path is invalid.

<!--Del_sink-->
### func join(String)

```cangjie
public func join(this @local!, path: String @local!): Path @local!
```

Function: Concatenates another path string after the current path to form a new path; the resulting [Path](fs_package_structs.md#struct-path) instance is bound to the caller's local region.

- For paths "a/b" and "c", returns "a/b/c".
- For paths "a" and "b/c", returns "a/b/c".

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - This method only performs string concatenation and does not handle path traversal components such as "..". For security verification, call [func canonicalize](./fs_package_funcs.md#func-canonicalizestring) first and check the path range.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The string of the other path.

Returns:

- [Path](fs_package_structs.md#struct-path) @local! - The [Path](fs_package_structs.md#struct-path) instance of the new path.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the parameter path is an absolute path.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the current path is empty or the current path or the input path is invalid.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Concatenate the path string in the local region
    let basePath: String @local! = "./dir"
    let base: Path @local! = Path(basePath) @local!
    let part: String @local! = "test_local_path.txt"
    let joined: Path @local! = base.join(part)
    println("Joined path: ${String(joined.toString())}")
}
```

Output:

```text
Joined path: ./dir/test_local_path.txt
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func join(Path)

```cangjie
public func join(this @local!, path: Path @local!): Path @local!
```

Function: Concatenates another path string after the current path to form a new path; the resulting [Path](fs_package_structs.md#struct-path) instance is bound to the caller's local region.

- For paths "a/b" and "c", returns "a/b/c".
- For paths "a" and "b/c", returns "a/b/c".

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - This method only performs string concatenation and does not handle path traversal components such as "..". For security verification, call [func canonicalize](./fs_package_funcs.md#func-canonicalizepath) first and check the path range.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- path: [Path](fs_package_structs.md#struct-path) @local! - The other [Path](fs_package_structs.md#struct-path).

Returns:

- [Path](fs_package_structs.md#struct-path) @local! - The [Path](fs_package_structs.md#struct-path) instance of the new path.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the parameter path is an absolute path.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the current path is empty or the current path or the input path is invalid.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Concatenate the Path instances in the local region
    let basePath: String @local! = "./dir"
    let base: Path @local! = Path(basePath) @local!
    let partPath: String @local! = "test_local_path.txt"
    let part: Path @local! = Path(partPath) @local!
    let joined: Path @local! = base.join(part)
    println("Joined path: ${String(joined.toString())}")
}
```

Output:

```text
Joined path: ./dir/test_local_path.txt
```

<!--DelEnd_sink-->
### func normalize()

```cangjie
public func normalize(): Path
```

Function: Normalizes the path string and constructs a new [Path](./fs_package_structs.md#struct-path) instance with the normalized string. This function only performs string parsing without IO operations.

Normalization rules:

1. Replace consecutive path separators with a single separator;
2. Remove trailing separators (except root directory separators or volume name characters);
3. Remove each "." path element (current directory);
4. Remove each ".." path element (parent directory) and its preceding non-".." element;
5. Remove ".." elements starting from root (e.g., "/.." becomes "/"; "\\.." becomes "\\" on Windows);
6. Preserve leading "../" in relative paths (and "..\\" on Windows);
7. If the result is empty, return Path(".").

Windows-specific: Volume names only undergo separator conversion (/ to \\).

Returns:

- [Path](./fs_package_structs.md#struct-path) - Normalized [Path](./fs_package_structs.md#struct-path) instance.

### func toString()

```cangjie
public func toString(): String
```

Function: Gets the path string of the [Path](fs_package_structs.md#struct-path).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string of the [Path](fs_package_structs.md#struct-path).

<!--Del_sink-->
### func toString()

```cangjie
public exclave func toString(this @local?): String @local!
```

Function: Obtains the path string of the [Path](fs_package_structs.md#struct-path); the returned string is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The path string of the [Path](fs_package_structs.md#struct-path).

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Obtain the path string in the local region
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    let pathString: String @local! = path.toString()
    println("Path string: ${String(pathString)}")
}
```

Output:

```text
Path string: ./test_local_path.txt
```

<!--DelEnd_sink-->
### operator func ==(Path)

```cangjie
public operator func ==(that: Path): Bool
```

Function: Determines whether two [Path](fs_package_structs.md#struct-path) instances are equal.

Equality is determined by comparing normalized strings. Normalization rules: see [normalize](./fs_package_structs.md#func-normalize).

Parameters:

- that: [Path](fs_package_structs.md#struct-path) - Another [Path](fs_package_structs.md#struct-path).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if paths are identical; false otherwise.