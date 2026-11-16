# 结构体

## struct FileDescriptor

```cangjie
public struct FileDescriptor {}
```

功能：用于获取文件句柄信息。

<!--Del_sink-->
在非 OpenHarmony 平台，该结构体还实现 [Copyable](../../core/core_package_api/core_package_interfaces.md#interface-copyable) 接口。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

<!--DelEnd_sink-->

> **说明：**
>
> 文件句柄（File Handle）是操作系统为了跟踪文件而分配的一种数据结构，用于标识一个打开文件的实例。文件句柄包含了文件的元数据信息（如文件名、路径、大小、修改时间等）以及文件数据在磁盘上的物理位置等信息。
> 在不同的操作系统中，文件句柄的形式可能会有所不同。在 Unix 和 Linux 系统中，文件句柄通常是一个非负整数，由操作系统内核分配，并在打开文件时返回给应用程序。在 Windows 系统中，文件句柄通常是一个指向文件对象的指针，由操作系统内核分配，并在打开文件时返回给应用程序。无论文件句柄的形式是什么，应用程序都可以使用它来执行文件的读取、写入、修改等操作。

### prop fileHandle

```cangjie
public prop fileHandle: IntNative
```

功能：获取文件句柄信息。

类型：[IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative)

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_filedescriptor_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_filedescriptor_file.txt")

    // 获取文件描述符
    let fileDescriptor = file.fileDescriptor

    // 获取文件句柄信息
    println("File fileHandle: ${fileDescriptor.fileHandle}")

    // 删除文件
    removeIfExists("./test_filedescriptor_file.txt", recursive: true)
}
```

可能的运行结果：

```text
File fileHandle: 3
```

<!--Del_sink-->
### prop fileHandle

```cangjie
public prop fileHandle: IntNative @local?
```

功能：获取文件句柄信息。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) @local?

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_fd_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_local_fd_file.txt")

    // 获取文件描述符，并显式绑定 `@local?` 视图
    let fd: FileDescriptor @local? = file.fileDescriptor

    // 句柄数值与平台相关，这里仅验证重复读取结果一致
    let first = fd.fileHandle
    let second = fd.fileHandle
    println("Same handle on repeated reads: ${first == second}")

    // 关闭并删除文件
    file.close()
    removeIfExists("./test_local_fd_file.txt", recursive: true)
}
```

运行结果：

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

功能：对应文件系统中的文件元数据。

> **说明：**
>
> 文件元数据是指文件系统中与文件相关的信息，包括文件名、文件大小、创建时间、修改时间、访问时间、文件权限、文件所有者等。
>
> [FileInfo](fs_package_structs.md#struct-fileinfo) 的底层实现是没有直接缓存文件属性的，每次通过 [FileInfo](fs_package_structs.md#struct-fileinfo) 的 API 都是现场获取的最新的文件属性。
>
> 因此这里有需要注意的情况，对于创建的同一 [FileInfo](fs_package_structs.md#struct-fileinfo) 实例，如果在两次获取其文件属性操作期间，对应的文件实体可能会被其他用户或进程做了修改或者替换等不期望的操作，就会导致后一次获取的可能不是期望的文件属性。
> 如果有特殊文件操作需求需要避免上述情况的产生，可以采用设置文件权限或者给关键文件操作加锁的方式来保证。

父类型：

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[FileInfo](#struct-fileinfo)>

### prop creationTime

```cangjie
public prop creationTime: DateTime
```

功能：获取创建时间。

类型：[DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_info_file.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 创建时间
    println("File creationTime: ${fileInfo.creationTime}")

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

可能的运行结果：

```text
File creationTime: 2025-09-29T08:44:09Z
```

### prop lastAccessTime

```cangjie
public prop lastAccessTime: DateTime
```

功能：获取最后访问时间。

类型：[DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_info_file.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 获取最后访问时间
    let lastAccessTime = fileInfo.lastAccessTime
    println("File lastAccessTime: ${lastAccessTime}")

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

可能的运行结果：

```text
File lastAccessTime: 2025-09-29T09:25:43Z
```

### prop lastModificationTime

```cangjie
public prop lastModificationTime: DateTime
```

功能：获取最后修改时间。

类型：[DateTime](../../time/time_package_api/time_package_structs.md#struct-datetime)

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_info_file.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 获取最后访问时间
    let lastModificationTime = fileInfo.lastModificationTime
    println("File lastModificationTime: ${lastModificationTime}")

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

可能的运行结果：

```text
File lastModificationTime: 2025-09-29T09:25:43Z
```

### prop name

```cangjie
public prop name: String
```

功能：获取当前实例对应的文件名或目录名。

该属性与 this.path.fileName 等价，路径解析规则详见 [Path](./fs_package_structs.md#struct-path) 结构体的 [fileName](./fs_package_structs.md#prop-filename) 属性。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_info_file.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 获取文件名
    let name = fileInfo.name
    println("File name: ${name}")

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

运行结果：

```text
File name: test_info_file.txt
```

<!--Del_sink-->
### prop name

```cangjie
public prop name: String @local?
```

功能：获取当前实例对应的文件名或目录名。

该属性与 this.path.fileName 等价，路径解析规则详见 [Path](./fs_package_structs.md#struct-path) 结构体的 [fileName](./fs_package_structs.md#prop-filename) 属性。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string) @local?

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_info_name.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_local_info_name.txt")

    // 在 local region 中构造 FileInfo 实例，接收者显式绑定为 `@local?` 后获取文件名
    let path: String @local! = "./test_local_info_name.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // 删除，如果想保留就注释下面这行代码
    file.close()
    removeIfExists("./test_local_info_name.txt", recursive: true)
}
```

运行结果：

```text
File name: test_local_info_name.txt
```

<!--DelEnd_sink-->
### prop parentDirectory

```cangjie
public prop parentDirectory: Option<FileInfo>
```

功能：获得父级目录元数据，以 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)> 形式返回，有父级返回 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>.Some(v)；否则返回 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>.None。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FileInfo](fs_package_structs.md#struct-fileinfo)>

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_parentdirectory", recursive: true)

    // 先创建一个目录
    Directory.create("./test_parentdirectory")

    // 目录内再创建一个文件
    let file = File.create("./test_parentdirectory/test_info_file.txt")

    // 获取该文件的父级目录信息
    let parentDirectory = file.info.parentDirectory
    println("Parent directory info name: ${parentDirectory?.name}")

    // 删除文件
    removeIfExists("./test_parentdirectory", recursive: true)
}
```

运行结果：

```text
Parent directory info name: Some(test_parentdirectory)
```

### prop path

```cangjie
public prop path: Path
```

功能：获得当前文件路径，以 [Path](fs_package_structs.md#struct-path) 形式返回。

类型：[Path](fs_package_structs.md#struct-path)

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_info_file.txt")

    // 获取文件信息
    let fileInfo = file.info

    println("File path: ${fileInfo.path}") // 输出文件路径

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

可能的运行结果：

```text
File path: /home/user/test_info_file.txt
```

<!--Del_sink-->
### prop path

```cangjie
public prop path: Path @local?
```

功能：获得当前文件路径，以 [Path](fs_package_structs.md#struct-path) 形式返回。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Path](fs_package_structs.md#struct-path) @local?

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_info_path.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_local_info_path.txt")

    // 在 local region 中构造 FileInfo 实例，接收者显式绑定为 `@local?` 后获取文件路径
    let path: String @local! = "./test_local_info_path.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    let infoPath: Path @local? = info.path
    println("File name in path: ${String(infoPath.fileName)}")

    // 删除，如果想保留就注释下面这行代码
    file.close()
    removeIfExists("./test_local_info_path.txt", recursive: true)
}
```

运行结果：

```text
File name in path: test_local_info_path.txt
```

<!--DelEnd_sink-->
### prop size

```cangjie
public prop size: Int64
```

功能：返回当前文件大小。

> **说明：**
>
> - 当前是文件时，表示单个文件占用磁盘空间的大小。
> - 当前是目录时，表示当前目录的所有文件占用磁盘空间的大小。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_size.txt", recursive: true)

    // 创建一个文件并写入一些数据
    var data: Array<Byte> = [83, 105, 122, 101] // "Size"
    File.writeTo("./test_size.txt", data)

    // 创建 FileInfo 实例
    let fileInfo = FileInfo("./test_size.txt")

    // 获取文件大小
    let size = fileInfo.size
    println("File size: ${size} bytes")

    // 删除文件
    removeIfExists("./test_size.txt", recursive: true)
}
```

运行结果：

```text
File size: 4 bytes
```

<!--Del_sink-->
### prop size

```cangjie
public prop size: Int64 @local?
```

功能：返回当前文件大小。

> **说明：**
>
> - 当前是文件时，表示单个文件占用磁盘空间的大小。
> - 当前是目录时，表示当前目录的所有文件占用磁盘空间的大小。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local?

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_info_size.txt", recursive: true)

    // 创建一个文件并写入 4 个字节
    let writeData: Array<Byte> = [83, 105, 122, 101] // "Size"
    File.writeTo("./test_local_info_size.txt", writeData)

    // 在 local region 中构造 FileInfo 实例，接收者显式绑定为 `@local?` 后获取文件大小
    let path: String @local! = "./test_local_info_size.txt"
    let info: FileInfo @local? = FileInfo(path) @local!
    println("File size equals written bytes: ${info.size == 4}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_info_size.txt", recursive: true)
}
```

运行结果：

```text
File size equals written bytes: true
```

<!--DelEnd_sink-->
### init(Path)

```cangjie
public init(path: Path)
```

功能：创建 [FileInfo](fs_package_structs.md#struct-fileinfo) 实例。

参数：

- path: [Path](fs_package_structs.md#struct-path) - [Path](fs_package_structs.md#struct-path) 形式的目录路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 当路径非法时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空，或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_init_path.txt", recursive: true)

    // 创建一个文件
    File.create("./test_init_path.txt")

    // 使用 Path 创建 FileInfo 实例
    let path = Path("./test_init_path.txt")
    let fileInfo = FileInfo(path)

    // 验证创建成功
    println("File name: ${fileInfo.name}")

    // 删除文件
    removeIfExists("./test_init_path.txt", recursive: true)
}
```

运行结果：

```text
File name: test_init_path.txt
```

### init(String)

```cangjie
public init(path: String)
```

功能：创建 [FileInfo](fs_package_structs.md#struct-fileinfo) 实例。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - [String](../../core/core_package_api/core_package_structs.md#struct-string) 形式的目录路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 当路径非法时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空，或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_init_string.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_init_string.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 验证创建成功
    println("File name: ${fileInfo.name}")

    // 删除文件
    removeIfExists("./test_init_string.txt", recursive: true)
}
```

运行结果：

```text
File name: test_init_string.txt
```

<!--Del_sink-->
### init(this @local!, Path @local!)

```cangjie
public exclave init(this @local!, path: Path @local!)
```

功能：创建 [FileInfo](fs_package_structs.md#struct-fileinfo) 实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 待构造的 `@local!` 实例。
- path: [Path](fs_package_structs.md#struct-path) @local! - [Path](fs_package_structs.md#struct-path) 形式的目录路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 当路径非法时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空，或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_info_init_path.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_local_info_init_path.txt")

    // 在 local region 中根据 Path 实例创建 FileInfo 实例
    let rawPath: String @local! = "./test_local_info_init_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    let info: FileInfo @local! = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // 删除，如果想保留就注释下面这行代码
    file.close()
    removeIfExists("./test_local_info_init_path.txt", recursive: true)
}
```

运行结果：

```text
File name: test_local_info_init_path.txt
```

<!--DelEnd_sink-->

<!--Del_sink-->
### init(this @local!, String @local!)

```cangjie
public exclave init(this @local!, path: String @local!)
```

功能：创建 [FileInfo](fs_package_structs.md#struct-fileinfo) 实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 待构造的 `@local!` 实例。
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - [String](../../core/core_package_api/core_package_structs.md#struct-string) 形式的目录路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 当路径非法时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空，或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_info_init_string.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_local_info_init_string.txt")

    // 在 local region 中根据路径字符串创建 FileInfo 实例
    let path: String @local! = "./test_local_info_init_string.txt"
    let info: FileInfo @local! = FileInfo(path) @local!
    println("File name: ${String(info.name)}")

    // 删除，如果想保留就注释下面这行代码
    file.close()
    removeIfExists("./test_local_info_init_string.txt", recursive: true)
}
```

运行结果：

```text
File name: test_local_info_init_string.txt
```

<!--DelEnd_sink-->
### func canExecute()

```cangjie
public func canExecute(): Bool
```

功能：判断当前用户是否有权限执行该实例对应的文件。

> **说明：**
>
> - 对文件而言，判断用户是否有执行文件的权限。
> - 对目录而言，判断用户是否有进入目录的权限。
> - 在 Windows 环境下，用户对于文件的执行权限由文件扩展名决定而对于目录的执行权限将始终拥有并且调用该函数不会生效，固定返回 true。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示有权限；false 表示无权限。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_can_execute.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_can_execute.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查是否可执行
    let canExecute = fileInfo.canExecute()
    println("File can execute: ${canExecute}")

    // 删除文件
    removeIfExists("./test_can_execute.txt", recursive: true)
}
```

运行结果：

```text
File can execute: false
```

### func canRead()

```cangjie
public func canRead(): Bool
```

功能：判断当前用户是否有权限读取该实例对应的文件。

> **说明：**
>
> - 对文件而言，判断用户是否有读取文件的权限。
> - 对目录而言，判断用户是否有浏览目录的权限。
> - 在 Windows 环境下，用户始终拥有对于文件和目录的可读权限，调用该函数将不会生效，固定返回 true。
> - 在 Linux 和 macOS 环境下，该函数正常使用。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示有权限；false 表示无权限。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_can_read.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_can_read.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查是否可读
    let canRead = fileInfo.canRead()
    println("File can read: ${canRead}")

    // 删除文件
    removeIfExists("./test_can_read.txt", recursive: true)
}
```

运行结果：

```text
File can read: true
```

### func canWrite()

```cangjie
public func canWrite(): Bool
```

功能：判断当前用户是否有权限写入该实例对应的文件。

> **说明：**
>
> - 对文件而言，判断用户是否有写入文件的权限。
> - 对目录而言，判断用户是否有删除、移动、创建目录内文件的权限。
> - 在 Windows 环境下，用户对于文件的可写权限可正常使用，而对于目录的可写权限将始终拥有，调用该函数不会生效，固定返回 true。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示有权限；false 表示无权限。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_can_write.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_can_write.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查是否可写
    let canWrite = fileInfo.canWrite()
    println("File can write: ${canWrite}")

    // 删除文件
    removeIfExists("./test_can_write.txt", recursive: true)
}
```

运行结果：

```text
File can write: true
```

### func isDirectory()

```cangjie
public func isDirectory(): Bool
```

功能：判断当前文件是否是目录。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示是目录；false 表示不是目录。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_is_directory", recursive: true)

    // 创建一个目录
    Directory.create("./test_is_directory")

    // 创建 FileInfo 实例
    let fileInfo = FileInfo("./test_is_directory")

    // 检查是否为目录
    let isDirectory = fileInfo.isDirectory()
    println("Is directory: ${isDirectory}")

    // 删除目录
    removeIfExists("./test_is_directory", recursive: true)
}
```

运行结果：

```text
Is directory: true
```

### func isHidden()

```cangjie
public func isHidden(): Bool
```

功能：判断当前文件是否隐藏。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示隐藏；false 表示未隐藏。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_is_hidden.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_is_hidden.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查是否为隐藏文件
    let isHidden = fileInfo.isHidden()
    println("Is hidden file: ${isHidden}")

    // 删除文件
    removeIfExists("./test_is_hidden.txt", recursive: true)
}
```

运行结果：

```text
Is hidden file: false
```

### func isReadOnly()

```cangjie
public func isReadOnly(): Bool
```

功能：判断当前文件是否只读。

> **说明：**
>
> - 在 Windows 环境下，用户对于文件的只读权限可正常使用而对于目录的删除修改权限将始终拥有，调用该函数不会生效，固定返回 false。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示是只读；false 表示不是只读。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_isreadonly.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_isreadonly.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查文件是否只读
    let isReadOnly = fileInfo.isReadOnly()
    println("File is read-only: ${isReadOnly}")

    // 删除文件
    removeIfExists("./test_isreadonly.txt", recursive: true)
}
```

运行结果：

```text
File is read-only: false
```

### func isRegular()

```cangjie
public func isRegular(): Bool
```

功能：判断当前文件是否是普通文件。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示是文件；false 表示不是文件。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_is_regular.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_is_regular.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 检查是否为普通文件
    let isRegular = fileInfo.isRegular()
    println("Is regular file: ${isRegular}")

    // 删除文件
    removeIfExists("./test_is_regular.txt", recursive: true)
}
```

运行结果：

```text
Is regular file: true
```

### func isSymbolicLink()

```cangjie
public func isSymbolicLink(): Bool
```

功能：判断当前文件是否是软链接。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示是软链接；false 表示不是软链接。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果判断过程中底层接口发生错误，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_symlink_source.txt", recursive: true)

    // 创建一个source文件
    let file = File.create("./test_symlink_source.txt")

    // 同时创建符号链接
    SymbolicLink.create("./test_symlink_target.txt", to: "./test_symlink_source.txt")

    // 获取source文件信息
    let fileInfo = file.info

    // 获取symbolicLink信息
    let symbolicLinkInfo = FileInfo("./test_symlink_target.txt")

    // 检查文件是否是软链接
    let isSymbolicLink01 = fileInfo.isSymbolicLink()
    println("File is symbolic link: ${isSymbolicLink01}")

    // 检查符号链接文件是否是软链接
    let isSymbolicLink02 = symbolicLinkInfo.isSymbolicLink()
    println("File is symbolic link: ${isSymbolicLink02}")

    // 删除文件
    removeIfExists("./test_symlink_target.txt", recursive: true)
    // 删除文件
    removeIfExists("./test_symlink_source.txt", recursive: true)
}
```

运行结果：

```text
File is symbolic link: false
File is symbolic link: true
```

### func setExecutable(Bool)

```cangjie
public func setExecutable(executable: Bool): Bool
```

功能：对当前实例对应的文件设置文件所有者是否可执行的权限。

> **说明：**
>
> - 对文件而言，设置用户是否有执行文件的权限，对目录而言，设置用户是否有进入目录的权限。
> - 在 Windows 环境下，用户对于文件的执行权限由文件扩展名决定而对于目录的执行权限将始终拥有，调用该函数不会生效，固定返回 false。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。如果在此函数调用期间，该 [FileInfo](fs_package_structs.md#struct-fileinfo) 对应的文件实体被其他用户或者进程修改，有可能因为竞争条件(Race Condition)导致其他修改不能生效。以特权用户运行的进程可能绕过此权限设置。

参数：

- executable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否设置可执行。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，操作成功；false，操作失败。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果用户没有权限修改，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_setexecutable.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_setexecutable.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 设置文件可执行权限
    let result = fileInfo.setExecutable(true)
    println("Set executable permission result: ${result}")

    // 删除文件
    removeIfExists("./test_setexecutable.txt", recursive: true)
}
```

运行结果：

```text
Set executable permission result: true
```

### func setReadable(Bool)

```cangjie
public func setReadable(readable: Bool): Bool
```

功能：对当前实例对应的文件设置文件所有者是否可读取的权限。

> **说明：**
>
> - 对文件而言，设置用户是否有读取文件的权限。
> - 对目录而言，设置用户是否有浏览目录的权限。
> - 在 Windows 环境下，用户始终拥有对于文件以及目录的可读权限，不可更改，调用该函数将不会生效。当 readable 为 true 时，函数返回 true，当 readable 为 false 时，函数返回 false。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。如果在此函数调用期间，该 [FileInfo](fs_package_structs.md#struct-fileinfo) 对应的文件实体被其他用户或者进程修改，有可能因为竞争条件(Race Condition)导致其他修改不能生效。以特权用户运行的进程可能绕过此权限设置。

参数：

- readable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否设置可读。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，操作成功；false，操作失败。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果用户没有权限修改，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_setreadable.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_setreadable.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 设置文件可读权限
    let result = fileInfo.setReadable(true)
    println("Set readable permission result: ${result}")

    // 删除文件
    removeIfExists("./test_setreadable.txt", recursive: true)
}
```

运行结果：

```text
Set readable permission result: true
```

### func setWritable(Bool)

```cangjie
public func setWritable(writable: Bool): Bool
```

功能：对当前实例对应的文件设置文件所有者是否可写入的权限。

> **说明：**
>
> - 对文件而言，设置用户是否有写入文件的权限。
> - 对目录而言，设置用户是否有删除、移动、创建目录内文件的权限。
> - 在 Windows 环境下，用户对于文件的可写权限可正常使用而对于目录的可写权限将始终拥有，不可更改，执行该函数不会生效，固定返回 false。
> - 在 Linux 和 macOS 环境下，该函数可正常使用。如果在此函数调用期间，该 [FileInfo](fs_package_structs.md#struct-fileinfo) 对应的文件实体被其他用户或者进程修改，有可能因为竞争条件(Race Condition)导致其他修改不能生效。

参数：

- writable: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否设置可写。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，操作成功；false，操作失败。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果用户没有权限修改，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_setwritable.txt", recursive: true)

    // 创建一个文件
    let file = File.create("./test_setwritable.txt")

    // 获取文件信息
    let fileInfo = file.info

    // 设置文件可写权限
    let result = fileInfo.setWritable(true)
    println("Set writable permission result: ${result}")

    // 删除文件
    removeIfExists("./test_setwritable.txt", recursive: true)
}
```

运行结果：

```text
Set writable permission result: true
```

### operator func ==(FileInfo)

```cangjie
public operator func ==(other: FileInfo): Bool
```

功能：判断当前 [FileInfo](fs_package_structs.md#struct-fileinfo) 和另一个 [FileInfo](fs_package_structs.md#struct-fileinfo) 是否对应同一文件。

参数：

- other: [FileInfo](fs_package_structs.md#struct-fileinfo) - 另一个 [FileInfo](fs_package_structs.md#struct-fileinfo)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，是同一文件；false，不是同一文件。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_equal1.txt", recursive: true)
    removeIfExists("./test_equal2.txt", recursive: true)

    // 创建两个文件并写入相同的数据
    var data: Array<Byte> = [69, 113, 117, 97] // "Equa"
    File.writeTo("./test_equal1.txt", data)
    File.writeTo("./test_equal2.txt", data)

    // 创建两个 FileInfo 实例
    let fileInfo1 = FileInfo("./test_equal1.txt")
    let fileInfo2 = FileInfo("./test_equal2.txt")

    // 比较两个 FileInfo 实例是否相等
    let isEqual = fileInfo1 == fileInfo2
    println("File infos are equal: ${isEqual}")

    // 删除文件
    removeIfExists("./test_equal1.txt", recursive: true)
    removeIfExists("./test_equal2.txt", recursive: true)
}
```

运行结果：

```text
File infos are equal: false
```

## struct Path

```cangjie
public struct Path <: Equatable<Path> & Hashable & ToString {
    public static const Separator: String = PATH_SEPARATOR
    public static const ListSeparator: String = PATH_LISTSEPARATOR
    public init(rawPath: String)
}
```

功能：提供路径相关的函数。

Path 用来表示本地路径（Windows 平台已支持 DOS 设备路径和 UNC 路径，长度限制跟随系统）。 路径的字符串最大支持 4096 个字节（包括结束符 `\0`）。

> **说明：**
>
> 非法路径指的是以下情况之一：
>
> - 路径中包含非法字符，例如空格、制表符、换行符、特殊字符、控制字符等；
> - 路径中包含不存在的目录或文件；
> - 路径中包含无法访问的目录或文件，例如权限不足或被锁定等。

在输入路径时，应该避免使用非法字符，确保路径的合法性，以便正确地访问目标文件或目录。

父类型：

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[Path](#struct-path)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

### static const ListSeparator

```cangjie
public static const ListSeparator: String = PATH_LISTSEPARATOR
```

功能：获取路径列表分隔符，用于分隔路径列表中的不同路径。

Windows 系统中路径列表分隔符为 ";"，非 Windows 系统中为 ":"。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 获取路径列表分隔符
    let listSeparator = Path.ListSeparator
    println("Path list separator: ${listSeparator}")
}
```

运行结果：

```text
Path list separator: :
```

### static const Separator

```cangjie
public static const Separator: String = PATH_SEPARATOR
```

功能：获取路径分隔符，用于分隔多级目录。

Windows 系统中分隔符为 "\\"，非 Windows 系统中为 "/"。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 获取路径分隔符
    let separator = Path.Separator
    println("Path separator: ${separator}")
}
```

运行结果：

```text
Path separator: /
```

### prop extensionName

```cangjie
public prop extensionName: String
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的文件扩展名部分。

文件名 fileName 根据最后一个 r'.' 被划分为不带扩展名的文件名 fileNameWithoutExtension 和扩展名 extensionName 两部分。无扩展名时返回空字符串。

- 对于路径 "./NewFile.txt"，此属性返回 `"txt"`。
- 对于路径 "./.gitignore"，此属性返回 `"gitignore"`。
- 对于路径 "./noextension"，此属性返回 `""`。
- 对于路径 "./a.b.c"，此属性返回 `"c"`。
- 对于路径 "./NewFile.txt/"，此属性返回 `"txt"`。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("./test_file.txt")

    // 获取文件扩展名
    let extensionName = path.extensionName
    println("File extension name: ${extensionName}")
}
```

运行结果：

```text
File extension name: txt
```

### prop fileName

```cangjie
public prop fileName: String
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的文件名（含扩展名）部分。

整个路径字符串被划分为 parent 和 fileName 两部分，详见 [parent](./fs_package_structs.md#prop-parent)。无文件名时返回空字符串。

以下示例适用于所有系统：

- 对于路径 "./NewFile.txt"，此属性返回 "NewFile.txt"；
- 对于路径 "./.gitignore"，此属性返回 ".gitignore"；
- 对于路径 "./noextension"，此属性返回 "noextension"；
- 对于路径 "./a.b.c"，此属性返回 "a.b.c"；
- 对于路径 "./NewDir/"，此属性返回 "NewDir"；

特别地，在 Windows 文件系统中，fileName 不包括卷名部分。

以下示例仅适用于 Windows 系统：

- 对于路径 "c:\\a.txt"，此属性返回 "a.txt"；
- 对于路径 "c:"，此属性返回 ""；
- 对于路径 "\\\\Server\\Share\\a.txt"，此属性返回 "a.txt"；
- 对于路径 "\\\\Server\\Share\\"，此属性返回 ""；
- 对于路径 "\\\\?\\C:a\\b.txt"，此属性返回 "b.txt"；
- 对于路径 "\\\\?\\C:"，此属性返回 ""。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("./test_file.txt")

    // 获取文件名
    let fileName = path.fileName
    println("File name: ${fileName}")
}
```

运行结果：

```text
File name: test_file.txt
```

<!--Del_sink-->
### prop fileName

```cangjie
public prop fileName: String @local?
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的文件名（含扩展名）部分。

整个路径字符串被划分为 parent 和 fileName 两部分，详见 [parent](./fs_package_structs.md#prop-parent)。无文件名时返回空字符串。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string) @local?

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中创建 Path 实例，接收者显式绑定为 `@local?` 后获取文件名
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    println("File name: ${String(path.fileName)}")
}
```

运行结果：

```text
File name: test_local_path.txt
```

<!--DelEnd_sink-->
### prop fileNameWithoutExtension

```cangjie
public prop fileNameWithoutExtension: String
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的文件名（不含扩展名）部分。

文件名 fileName 根据最后一个 r'.' 被划分为不带扩展名的文件名 fileNameWithoutExtension 和扩展名 extensionName 两部分。无文件名（不含扩展名）时返回空字符串。

- 对于路径 "./NewFile.txt"，此属性返回 `"NewFile"`。
- 对于路径 "./.gitignore"，此属性返回 `""`。
- 对于路径 "./noextension"，此属性返回 `"noextension"`。
- 对于路径 "./a.b.c"，此属性返回 `"a.b"`。
- 对于路径 "./NewFile/"，此属性返回 `"NewFile"`。

类型：[String](../../core/core_package_api/core_package_structs.md#struct-string)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("./test_file.txt")

    // 获取不带扩展名的文件名
    let fileNameWithoutExtension = path.fileNameWithoutExtension
    println("File name without extension: ${fileNameWithoutExtension}")
}
```

运行结果：

```text
File name without extension: test_file
```

### prop parent

```cangjie
public prop parent: Path
```

功能：获得该 [Path](fs_package_structs.md#struct-path) 实例的父路径。

整个路径字符串被划分为 parent 和 fileName，以最后一个有效文件分隔符（末尾的分隔符会被忽略）作为分界。如果 parent 不存在，就返回空字符串构造的 Path 实例。parent 和 fileName 部分都不包含末尾分隔符，parent 保留表示根目录的分隔符。无父目录时返回空的 [Path](./fs_package_structs.md#struct-path) 实例。

该属性不会访问文件系统，也不会消除特殊名称。如果有需要可以跟规范化搭配使用。

该属性在不同操作系统行为有差异，在 Windows 系统中，文件分隔符为 "\\" 或 "/"（规范化时会统一转换为 "\\"），在 Linux、macOS 系统中，文件分隔符为 "/"。

以下示例适用于所有系统：

- 对于路径 "/a/b/c"，此属性返回 Path("/a/b")；
- 对于路径 "/a/b/"，此属性返回 Path("/a")；
- 对于路径 "/a"，此属性返回 Path("/")；
- 对于路径 "/"，此属性返回 Path("/")；
- 对于路径 "./a/b"，此属性返回 Path("./a")；
- 对于路径 "./"，此属性返回 Path("")；
- 对于路径 ".gitignore"，此属性返回 Path("")；
- 对于路径 "/a/./../b"，此属性返回 Path("/a/./..")。

此外，在 Windows 系统中，path 被分为卷名、目录名和文件名，详情请参见微软官方文档。属性 parent 包含卷名和目录名。

以下示例仅适用于 Windows 系统：

- 对于路径 "C:"，此属性返回 Path("C:")；
- 对于路径 "C:\\a\\b"，此属性返回 Path("C:\\a")；
- 对于路径 "\\\\Server\\Share\\xx\\yy"，此属性返回 Path("\\\\Server\\Share\\xx")；
- 对于路径 "\\\\?\\UNC\\Server\\Share\\xx\\yy"，此属性返回 Path("\\\\?\\UNC\\Server\\Share\\xx")；
- 对于路径 "\\\\?\\c:\\xx\\yy"，此属性返回 Path("\\\\?\\c:\\xx")。

类型：[Path](fs_package_structs.md#struct-path)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("/home/user/test_file.txt")

    // 获取父路径
    let parent = path.parent
    println("Parent path: ${parent}")
}
```

运行结果：

```text
Parent path: /home/user
```

<!--Del_sink-->
### prop parent

```cangjie
public prop parent: Path @local!
```

功能：获得该 [Path](fs_package_structs.md#struct-path) 实例的父路径，返回的 [Path](fs_package_structs.md#struct-path) 实例绑定在调用者的 local region 中。

整个路径字符串被划分为 parent 和 fileName，以最后一个有效文件分隔符（末尾的分隔符会被忽略）作为分界。如果 parent 不存在，就返回空字符串构造的 Path 实例。parent 和 fileName 部分都不包含末尾分隔符，parent 保留表示根目录的分隔符。无父目录时返回空的 [Path](./fs_package_structs.md#struct-path) 实例。

该属性不会访问文件系统，也不会消除特殊名称。如果有需要可以跟规范化搭配使用。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Path](fs_package_structs.md#struct-path) @local!

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中创建 Path 实例并获取父路径
    let rawPath: String @local! = "./dir/test_local_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    let parent: Path @local! = path.parent
    println("Parent path: ${String(parent.toString())}")
}
```

运行结果：

```text
Parent path: ./dir
```

<!--DelEnd_sink-->
### init(String)

```cangjie
public init(rawPath: String)
```

功能：创建 [Path](fs_package_structs.md#struct-path) 实例时不检查路径字符串是否合法，支持绝对路径和相对路径。

参数：

- rawPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 路径的字符串。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 使用字符串创建 Path 实例
    let path = Path("/home/user/test_file.txt")

    // 输出路径
    println("Path: ${path}")
}
```

运行结果：

```text
Path: /home/user/test_file.txt
```

<!--Del_sink-->
### init(this @local!, String @local!)

```cangjie
public exclave init(this @local!, rawPath: String @local!)
```

功能：创建 [Path](fs_package_structs.md#struct-path) 实例，创建时不检查路径字符串是否合法，支持绝对路径和相对路径；创建的实例绑定在调用者的 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 待构造的 `@local!` 实例。
- rawPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - 路径的字符串。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中根据字符串创建 Path 实例
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local! = Path(rawPath) @local!
    println("Path: ${String(path.toString())}")
}
```

运行结果：

```text
Path: ./test_local_path.txt
```

<!--DelEnd_sink-->
### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的哈希值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - [Path](fs_package_structs.md#struct-path) 的哈希值。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("/home/user/test_file.txt")

    // 获取路径的哈希值
    let hashCode = path.hashCode()
    println("Path hash code: ${hashCode}")
}
```

运行结果：

```text
Path hash code: 1680923330550157156
```

### func isAbsolute()

```cangjie
public func isAbsolute(): Bool
```

功能：判断 [Path](fs_package_structs.md#struct-path) 是否是绝对路径。在 Unix 中，以 `/` 开头的路径为绝对路径。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，是绝对路径；false，不是绝对路径。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个绝对路径实例
    let absolutePath = Path("/home/user/test_file.txt")

    // 创建一个相对路径实例
    let relativePath = Path("./test_file.txt")

    // 检查路径是否为绝对路径
    let isAbsolute1 = absolutePath.isAbsolute()
    let isAbsolute2 = relativePath.isAbsolute()

    println("Path '${absolutePath}' is absolute: ${isAbsolute1}")
    println("Path '${relativePath}' is absolute: ${isAbsolute2}")
}
```

运行结果：

```text
Path '/home/user/test_file.txt' is absolute: true
Path './test_file.txt' is absolute: false
```

<!--Del_sink-->
### func isAbsolute()

```cangjie
public func isAbsolute(this @local?): Bool
```

功能：判断 [Path](fs_package_structs.md#struct-path) 是否是绝对路径。在 Unix 中，以 `/` 开头的路径为绝对路径。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，是绝对路径；false，不是绝对路径。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中创建相对路径实例并判断是否为绝对路径
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    println("Is absolute path: ${path.isAbsolute()}")
}
```

运行结果：

```text
Is absolute path: false
```

<!--DelEnd_sink-->
### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

功能：判断当前实例是否为空路径。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果当前实例为空路径，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个空路径实例
    let emptyPath = Path("")

    // 创建一个非空路径实例
    let nonEmptyPath = Path("/home/user/test_file.txt")

    // 检查路径是否为空
    let isEmpty1 = emptyPath.isEmpty()
    let isEmpty2 = nonEmptyPath.isEmpty()

    println("Path '${emptyPath}' is empty: ${isEmpty1}")
    println("Path '${nonEmptyPath}' is empty: ${isEmpty2}")
}
```

运行结果：

```text
Path '' is empty: true
Path '/home/user/test_file.txt' is empty: false
```

<!--Del_sink-->
### func isEmpty()

```cangjie
public func isEmpty(this @local?): Bool
```

功能：判断当前实例是否为空路径。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果当前实例为空路径，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中创建空路径与非空路径实例并判断是否为空路径
    let rawEmpty: String @local! = ""
    let emptyPath: Path @local? = Path(rawEmpty) @local!
    let rawNonEmpty: String @local! = "./test_local_path.txt"
    let nonEmptyPath: Path @local? = Path(rawNonEmpty) @local!
    println("Empty path is empty: ${emptyPath.isEmpty()}")
    println("Non-empty path is empty: ${nonEmptyPath.isEmpty()}")
}
```

运行结果：

```text
Empty path is empty: true
Non-empty path is empty: false
```

<!--DelEnd_sink-->
### func isRelative()

```cangjie
public func isRelative(): Bool
```

功能：判断 [Path](fs_package_structs.md#struct-path) 是否是相对路径，其结果与函数 [isAbsolute](fs_package_structs.md#func-isabsolute) 结果相反。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，是相对路径；false，不是相对路径。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当路径为空或包含字符串结束符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个相对路径实例
    let relativePath = Path("./test_file.txt")

    // 创建一个绝对路径实例
    let absolutePath = Path("/home/user/test_file.txt")

    // 检查路径是否为相对路径
    let isRelative1 = relativePath.isRelative()
    let isRelative2 = absolutePath.isRelative()

    println("Path '${relativePath}' is relative: ${isRelative1}")
    println("Path '${absolutePath}' is relative: ${isRelative2}")
}
```

运行结果：

```text
Path './test_file.txt' is relative: true
Path '/home/user/test_file.txt' is relative: false
```

### func join(Path)

```cangjie
public func join(path: Path): Path
```

功能：在当前路径后拼接另一个路径字符串形成新路径。

- 对于路径 "a/b"，"c"，返回 "a/b/c"。
- 对于路径 "a"，"b/c"，返回 "a/b/c"。

> **注意：**
>
> 本方法仅进行字符串拼接，不处理 ".." 等路径遍历组件。如需安全验证，请先调用 [func canonicalize](./fs_package_funcs.md#func-canonicalizepath) 并检查路径范围。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 另一个 [Path](fs_package_structs.md#struct-path)。

返回值：

- [Path](fs_package_structs.md#struct-path) - 新路径的 [Path](fs_package_structs.md#struct-path) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果参数 path 是绝对路径则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当前路径为空或当前路径、入参路径非法时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个基础路径实例
    let basePath = Path("/home/user")

    // 创建要拼接的路径实例
    let subPath = Path("documents")

    // 使用join(Path)函数拼接路径
    let joinedPath = basePath.join(subPath)

    println("Base path: ${basePath}")
    println("Sub path: ${subPath}")
    println("Joined path: ${joinedPath}")
}
```

运行结果：

```text
Base path: /home/user
Sub path: documents
Joined path: /home/user/documents
```

### func join(String)

```cangjie
public func join(path: String): Path
```

功能：在当前路径后拼接另一个路径字符串形成新路径。

- 对于路径 "a/b"，"c"，返回 "a/b/c"。
- 对于路径 "a"，"b/c"，返回 "a/b/c"。

> **注意：**
>
> 本方法仅进行字符串拼接，不处理 ".." 等路径遍历组件。如需安全验证，请先调用 [func canonicalize](./fs_package_funcs.md#func-canonicalizestring) 并检查路径范围。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 另一个路径的字符串。

返回值：

- [Path](fs_package_structs.md#struct-path) - 新路径的 [Path](fs_package_structs.md#struct-path) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果参数 path 是绝对路径则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当前路径为空或当前路径、入参路径非法时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个基础路径实例
    let basePath = Path("/home/user")

    // 使用join(String)函数拼接路径字符串
    let joinedPath = basePath.join("documents/file.txt")

    println("Base path: ${basePath}")
    println("Joined path: ${joinedPath}")
}
```

运行结果：

```text
Base path: /home/user
Joined path: /home/user/documents/file.txt
```

<!--Del_sink-->
### func join(String)

```cangjie
public func join(this @local!, path: String @local!): Path @local!
```

功能：在当前路径后拼接另一个路径字符串形成新路径；结果 [Path](fs_package_structs.md#struct-path) 实例绑定在调用者的 local region 中。

- 对于路径 "a/b"，"c"，返回 "a/b/c"。
- 对于路径 "a"，"b/c"，返回 "a/b/c"。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。
> - 本方法仅进行字符串拼接，不处理 ".." 等路径遍历组件。如需安全验证，请先调用 [func canonicalize](./fs_package_funcs.md#func-canonicalizestring) 并检查路径范围。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - 另一个路径的字符串。

返回值：

- [Path](fs_package_structs.md#struct-path) @local! - 新路径的 [Path](fs_package_structs.md#struct-path) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果参数 path 是绝对路径则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当前路径为空或当前路径、入参路径非法时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中拼接路径字符串
    let basePath: String @local! = "./dir"
    let base: Path @local! = Path(basePath) @local!
    let part: String @local! = "test_local_path.txt"
    let joined: Path @local! = base.join(part)
    println("Joined path: ${String(joined.toString())}")
}
```

运行结果：

```text
Joined path: ./dir/test_local_path.txt
```

<!--DelEnd_sink-->

<!--Del_sink-->
### func join(Path)

```cangjie
public func join(this @local!, path: Path @local!): Path @local!
```

功能：在当前路径后拼接另一个路径字符串形成新路径；结果 [Path](fs_package_structs.md#struct-path) 实例绑定在调用者的 local region 中。

- 对于路径 "a/b"，"c"，返回 "a/b/c"。
- 对于路径 "a"，"b/c"，返回 "a/b/c"。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。
> - 本方法仅进行字符串拼接，不处理 ".." 等路径遍历组件。如需安全验证，请先调用 [func canonicalize](./fs_package_funcs.md#func-canonicalizepath) 并检查路径范围。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- path: [Path](fs_package_structs.md#struct-path) @local! - 另一个 [Path](fs_package_structs.md#struct-path)。

返回值：

- [Path](fs_package_structs.md#struct-path) @local! - 新路径的 [Path](fs_package_structs.md#struct-path) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果参数 path 是绝对路径则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当前路径为空或当前路径、入参路径非法时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中拼接 Path 实例
    let basePath: String @local! = "./dir"
    let base: Path @local! = Path(basePath) @local!
    let partPath: String @local! = "test_local_path.txt"
    let part: Path @local! = Path(partPath) @local!
    let joined: Path @local! = base.join(part)
    println("Joined path: ${String(joined.toString())}")
}
```

运行结果：

```text
Joined path: ./dir/test_local_path.txt
```

<!--DelEnd_sink-->
### func normalize()

```cangjie
public func normalize(): Path
```

功能：将路径字符串进行规范化处理，并用规范化后的字符串构造新的 [Path](./fs_package_structs.md#struct-path) 实例。该函数仅做字符串解析，不会进行 io 操作。

规范化规则：

- 将连续的多个路径分隔符替换为单个路径分隔符；
- 删除末尾的路径分隔符（不删除作为根目录的路径分隔符或卷名中的字符）；
- 删除每一个 "." 路径名元素（代表当前目录）；
- 删除每一个路径内的 ".." 路径名元素（代表父目录）和它前面的非 ".." 路径名元素；
- 删除开始于根路径的 ".." 路径名元素，即将路径开始处的 "/.." 替换为 "/"（Windows 系统中还会将 "\\.." 替换为 "\\"）；
- 相对路径保留开头的 "../"（Windows 系统中还将保留 "..\\"）;
- 最后如果得到空路径，返回 Path(".")。

特别地，Windows 文件系统中，卷名部分仅做分隔符转换，即 "/" 转换为 "\\"。

返回值：

- [Path](./fs_package_structs.md#struct-path) - 规范化后的 [Path](./fs_package_structs.md#struct-path) 实例。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个需要规范化的路径实例
    let path1 = Path("/home/user/../user/documents/./file.txt")
    let path2 = Path("/home//user///documents////file.txt")
    let path3 = Path("/home/user/documents/")

    // 使用normalize()函数规范化路径
    let normalizedPath1 = path1.normalize()
    let normalizedPath2 = path2.normalize()
    let normalizedPath3 = path3.normalize()

    println("Original path 1: ${path1}")
    println("Normalized path 1: ${normalizedPath1}")
    println("Original path 2: ${path2}")
    println("Normalized path 2: ${normalizedPath2}")
    println("Original path 3: ${path3}")
    println("Normalized path 3: ${normalizedPath3}")
}
```

运行结果：

```text
Original path 1: /home/user/../user/documents/./file.txt
Normalized path 1: /home/user/documents/file.txt
Original path 2: /home//user///documents////file.txt
Normalized path 2: /home/user/documents/file.txt
Original path 3: /home/user/documents/
Normalized path 3: /home/user/documents
```

### func toString()

```cangjie
public func toString(): String
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的路径字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - [Path](fs_package_structs.md#struct-path) 的路径字符串。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个路径实例
    let path = Path("/home/user/documents/file.txt")

    // 使用toString()函数获取路径字符串
    let pathString = path.toString()

    println("Path: ${path}")
    println("Path string: ${pathString}")
}
```

运行结果：

```text
Path: /home/user/documents/file.txt
Path string: /home/user/documents/file.txt
```

<!--Del_sink-->
### func toString()

```cangjie
public exclave func toString(this @local?): String @local!
```

功能：获得 [Path](fs_package_structs.md#struct-path) 的路径字符串，返回的字符串绑定在调用者的 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - [Path](fs_package_structs.md#struct-path) 的路径字符串。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 在 local region 中获取路径字符串
    let rawPath: String @local! = "./test_local_path.txt"
    let path: Path @local? = Path(rawPath) @local!
    let pathString: String @local! = path.toString()
    println("Path string: ${String(pathString)}")
}
```

运行结果：

```text
Path string: ./test_local_path.txt
```

<!--DelEnd_sink-->
### operator func ==(Path)

```cangjie
public operator func ==(other: Path): Bool
```

功能：判断 [Path](fs_package_structs.md#struct-path) 是否相等。

判等时将对 [Path](fs_package_structs.md#struct-path) 进行规范化，如果规范化后的字符串相等，则认为两个 [Path](fs_package_structs.md#struct-path) 实例相等。规范化规则详见函数 [normalize](./fs_package_structs.md#func-normalize)。

参数：

- other: [Path](fs_package_structs.md#struct-path) - 另一个 [Path](fs_package_structs.md#struct-path)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true，是同一路径；false，不是同一路径。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建两个相同的路径实例
    let path1 = Path("/home/user/documents/file.txt")
    let path2 = Path("/home/user/documents/file.txt")

    // 创建一个不同的路径实例
    let path3 = Path("/home/user/documents/another_file.txt")

    // 创建一个需要规范化的路径实例
    let path4 = Path("/home/user/../user/documents/file.txt")

    // 使用==操作符比较路径
    let isEqual1 = path1 == path2
    let isEqual2 = path1 == path3
    let isEqual3 = path1 == path4

    println("Path1: ${path1}")
    println("Path2: ${path2}")
    println("Path3: ${path3}")
    println("Path4: ${path4}")
    println("Path1 == Path2: ${isEqual1}")
    println("Path1 == Path3: ${isEqual2}")
    println("Path1 == Path4 (normalized): ${isEqual3}")
}
```

运行结果：

```text
Path1: /home/user/documents/file.txt
Path2: /home/user/documents/file.txt
Path3: /home/user/documents/another_file.txt
Path4: /home/user/../user/documents/file.txt
Path1 == Path2: true
Path1 == Path3: false
Path1 == Path4 (normalized): true
```
