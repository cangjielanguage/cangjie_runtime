# Functions

## func canonicalize(Path)

```cangjie
public func canonicalize(path: Path): Path
```

Function: Normalizes a [Path](fs_package_structs.md#struct-path) instance to obtain its canonical absolute path form.

All intermediate references and symbolic links will be resolved (symbolic links under UNC paths cannot be canonicalized). For example, for the path "/foo/test/../test/bar.txt", this function will return "/foo/test/bar.txt".

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The [Path](fs_package_structs.md#struct-path) instance to be canonicalized.

Returns:

- [Path](fs_package_structs.md#struct-path) - The canonicalized [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the path does not exist or cannot be canonicalized.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func canonicalize(String)

```cangjie
public func canonicalize(path: String): Path
```

Function: Constructs a [Path](fs_package_structs.md#struct-path) instance from the path string and canonicalizes it to obtain its canonical absolute path form.

All intermediate references and symbolic links will be resolved (symbolic links under UNC paths cannot be canonicalized). For example, for the path "/foo/test/../test/bar.txt", this function will return "/foo/test/bar.txt".

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path string to be canonicalized.

Returns:

- [Path](fs_package_structs.md#struct-path) - The canonicalized [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the path does not exist or cannot be canonicalized.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

<!--Del_sink-->
## func canonicalize(String)

```cangjie
public func canonicalize(path: String @local!): Path @local!
```

Function: Constructs a [Path](fs_package_structs.md#struct-path) instance from the path string and canonicalizes it to obtain the canonical path in absolute form; the returned [Path](fs_package_structs.md#struct-path) instance is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - The path string to be canonicalized.

Returns:

- [Path](fs_package_structs.md#struct-path) @local! - The canonicalized [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path does not exist or cannot be canonicalized.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_canonicalize.txt", recursive: true)

    // Create a test file
    let writeData: Array<Byte> = [67, 65, 78] // CAN
    File.writeTo("./test_local_canonicalize.txt", writeData)

    // Canonicalize the path string in the local region
    let path: String @local! = "./test_local_canonicalize.txt"
    let canonicalPath: Path @local! = canonicalize(path)

    // The canonicalized result is an absolute path; print the file name in it for verification
    println("Canonical file name: ${String(canonicalPath.fileName)}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_canonicalize.txt", recursive: true)
}
```

Output:

```text
Canonical file name: test_local_canonicalize.txt
```

<!--DelEnd_sink-->

<!--Del_sink-->
## func canonicalize(Path)

```cangjie
public func canonicalize(path: Path @local!): Path @local!
```

Function: Canonicalizes a [Path](fs_package_structs.md#struct-path) instance to obtain the canonical path in absolute form; the returned [Path](fs_package_structs.md#struct-path) instance is bound to the caller's local region.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) @local! - The [Path](fs_package_structs.md#struct-path) instance to be canonicalized.

Returns:

- [Path](fs_package_structs.md#struct-path) @local! - The canonicalized [Path](fs_package_structs.md#struct-path) instance.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown if the path does not exist or cannot be canonicalized.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_canonicalize_path.txt", recursive: true)

    // Create a test file
    let writeData: Array<Byte> = [80, 65, 84] // PAT
    File.writeTo("./test_local_canonicalize_path.txt", writeData)

    // Canonicalize the Path instance in the local region
    let rawPath: String @local! = "./test_local_canonicalize_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    let canonicalPath: Path @local! = canonicalize(path)

    // The canonicalized result is an absolute path; print the file name in it for verification
    println("Canonical file name: ${String(canonicalPath.fileName)}")

    // Delete; comment out the following line if you want to keep the file
    removeIfExists("./test_local_canonicalize_path.txt", recursive: true)
}
```

Output:

```text
Canonical file name: test_local_canonicalize_path.txt
```

<!--DelEnd_sink-->
## func copy(Path, Path, Bool)

```cangjie
public func copy(sourcePath: Path, to!: Path, overwrite!: Bool = false): Unit
```

Function: Implements file system copy functionality for copying files or directories.

When the target location exists and `overwrite` is `true`, this function requires that the type of `sourcePath` matches the type of `to`. For example, if `sourcePath` is of type `Directory`, `to` should also be of type `Directory`; otherwise, the function will throw an FSException. Currently supported file types include directories (Directory), regular files (Regular file), and symbolic links (SymbolicLink).

Parameters:

- sourcePath: [Path](./fs_package_structs.md#struct-path) - The source file path to be copied.
- to!: [Path](./fs_package_structs.md#struct-path) - The target path.
- overwrite!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to overwrite the target path, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the source and target file types are inconsistent, or when `overwrite` is `false` and the target path exists.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func copy(String, String, Bool)

```cangjie
public func copy(sourcePath: String, to!: String, overwrite!: Bool = false): Unit
```

Function: Implements file system copy functionality for copying files or directories.

When the target location exists and `overwrite` is `true`, this function requires that the type of `sourcePath` matches the type of `to`. For example, if `sourcePath` is of type `Directory`, `to` should also be of type `Directory`; otherwise, the function will throw an FSException. Currently supported file types include directories (Directory), regular files (Regular file), and symbolic links (SymbolicLink).

Parameters:

- sourcePath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The source file path to be copied.
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path.
- overwrite!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to overwrite the target path, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the source and target file types are inconsistent, or when `overwrite` is `false` and the target path exists.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func exists(Path)

```cangjie
public func exists(path: Path): Bool
```

Function: Determines whether the target path exists.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The target path to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func exists(String)

```cangjie
public func exists(path: String): Bool
```

Function: Determines whether the target path exists.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

<!--Del_sink-->
## func exists(Path)

```cangjie
public func exists(path: Path @local?): Bool
```

Function: Determines whether the target path exists.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) @local? - The target path to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_exists_path.txt", recursive: true)

    // Construct the `@local?` Path instance in the local region
    let rawPath: String @local! = "./test_local_exists_path.txt"
    let path: Path @local? = Path(rawPath) @local!

    // Check the file that does not exist
    println("File exists before creation: ${exists(path)}")

    // Create the file
    let writeData: Array<Byte> = [69, 120, 105, 115, 116] // "Exist"
    File.writeTo("./test_local_exists_path.txt", writeData)

    // Check the file that exists
    println("File exists after creation: ${exists(path)}")

    // Clean up the test file
    removeIfExists("./test_local_exists_path.txt", recursive: true)
    println("File exists after removal: ${exists(path)}")
}
```

Output:

```text
File exists before creation: false
File exists after creation: true
File exists after removal: false
```

<!--DelEnd_sink-->

<!--Del_sink-->
## func exists(String)

```cangjie
public func exists(path: String @local?): Bool
```

Function: Determines whether the target path exists.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local? - The target path to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the path is empty or contains a string terminator.

Example:

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // Delete first to avoid creation failure
    removeIfExists("./test_local_exists_string.txt", recursive: true)

    // Bind the `@local?` path string in the local region
    let path: String @local? = "./test_local_exists_string.txt"

    // Check the file that does not exist
    println("File exists before creation: ${exists(path)}")

    // Create the file
    let writeData: Array<Byte> = [69, 120, 105, 115, 116] // "Exist"
    File.writeTo("./test_local_exists_string.txt", writeData)

    // Check the file that exists
    println("File exists after creation: ${exists(path)}")

    // Clean up the test file
    removeIfExists("./test_local_exists_string.txt", recursive: true)
    println("File exists after removal: ${exists(path)}")
}
```

Output:

```text
File exists before creation: false
File exists after creation: true
File exists after removal: false
```

<!--DelEnd_sink-->
## func remove(Path, Bool)

```cangjie
public func remove(path: Path, recursive!: Bool = false): Unit
```

Function: Deletes a file or directory.

When the target is a directory, you can choose whether to recursively delete the directory.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The target path.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively delete the directory, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the specified directory does not exist or deletion fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func remove(String, Bool)

```cangjie
public func remove(path: String, recursive!: Bool = false): Unit
```

Function: Deletes a file or directory.

When the target is a directory, you can choose whether to recursively delete the directory.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively delete the directory, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the specified directory does not exist or deletion fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func removeIfExists(Path, Bool)

```cangjie
public func removeIfExists(path: Path, recursive!: Bool = false): Bool
```

Function: Checks if the target exists, and if it does, executes the [remove](#func-removepath-bool) method and returns `true`.

Parameters:

- path: [Path](./fs_package_structs.md#struct-path) - The target path.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively delete the directory, default value is `false`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when deletion fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func removeIfExists(String, Bool)

```cangjie
public func removeIfExists(path: String, recursive!: Bool = false): Bool
```

Function: Checks if the target exists, and if it does, executes the [remove](#func-removestring-bool) method and returns `true`.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path.
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to recursively delete the directory, default value is `false`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the target path exists.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when deletion fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func rename(Path, Path, Bool)

```cangjie
public func rename(sourcePath: Path, to!: Path, overwrite!: Bool = false): Unit
```

Function: Renames the file or directory specified by `sourcePath` to the name given by `to`. `sourcePath` must be an existing file or directory path. When `to` is an existing file or directory path, the specific behavior is determined by `overwrite`. If `overwrite` is `true`, the existing file or directory will be deleted before performing the rename operation; otherwise, an exception will be thrown.

> **Note:**
>
> When `overwrite` is `true`, an implicit behavior of `rename` is to delete the original file or directory at the target location. If the target location is a directory, all contents within the directory will be recursively deleted. Use with caution.

Parameters:

- sourcePath: [Path](./fs_package_structs.md#struct-path) - The path to be renamed.
- to!: [Path](./fs_package_structs.md#struct-path) - The target path.
- overwrite!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to overwrite the target path, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the operating system fails to execute the rename method.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.

## func rename(String, String, Bool)

```cangjie
public func rename(sourcePath: String, to!: String, overwrite!: Bool = false): Unit
```

Function: Renames the file or directory specified by `sourcePath` to the name given by `to`. `sourcePath` must be an existing file or directory path. When `to` is an existing file or directory path, the specific behavior is determined by `overwrite`. If `overwrite` is `true`, the existing file or directory will be deleted before performing the rename operation; if `overwrite` is `false`, an exception will be thrown.

> **Note:**
>
> When `overwrite` is `true`, an implicit behavior of `rename` is to delete the original file or directory at the target location. If the target location is a directory, all contents within the directory will be recursively deleted. Use with caution.

Parameters:

- sourcePath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The path to be renamed.
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The target path.
- overwrite!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to overwrite the target path, default value is `false`.

Exceptions:

- [FSException](fs_package_exceptions.md#class-fsexception) - Thrown when the operating system fails to execute the rename method.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the path is empty or contains a string terminator.