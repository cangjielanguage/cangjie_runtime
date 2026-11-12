# 类

## class Directory

```cangjie
public class Directory {}
```

功能：对应文件系统中的目录，它提供创建、移动、复制、删除、查询属性以及遍历目录等能力。

> **说明：**
>
> 非法路径指的是以下情况之一：
>
> - 路径中包含非法字符，例如空格、制表符、换行符、特殊字符、控制字符等；
> - 路径中包含不存在的目录或文件；
> - 路径中包含无法访问的目录或文件，例如权限不足或被锁定等。

在输入路径时，应该避免使用非法字符，确保路径的合法性，以便正确地访问目标文件或目录。

### static func create(Path, Bool)

```cangjie
public static func create(path: Path, recursive!: Bool = false): Unit
```

功能：创建目录。

可指定是否递归创建，如果需要递归创建，将逐级创建路径中不存在的目录。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 待创建的目录路径。
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否递归创建目录，true 代表递归创建，false 代表不递归创建，默认 false。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 目录已存在、非递归创建时中间有不存在的目录、权限不足或其他原因导致无法创建目录时，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 目录为空、目录为工作目录、目录为根目录或目录中存在空字符时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_directory")

    // 创建一个测试目录路径
    let testDir = Path("./test_directory")

    // 使用 Directory.create 创建目录
    Directory.create(testDir, recursive: true)

    // 验证目录是否创建成功
    println("Was the directory created successfully? ${exists("./test_directory")}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_directory")
}
```

运行结果：

```text
Was the directory created successfully? true
```

### static func create(String, Bool)

```cangjie
public static func create(path: String, recursive!: Bool = false): Unit
```

功能：创建目录。

可指定是否递归创建，如果需要递归创建，将逐级创建路径中不存在的目录。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待创建的目录路径。
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否递归创建目录，true 代表递归创建，false 代表不递归创建，默认 false。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 目录已存在、非递归创建时中间有不存在的目录、权限不足或其他原因导致无法创建目录时，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 目录为空、目录为工作目录、目录为根目录或目录中存在空字符时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_directory_string")

    // 使用 Directory.create 创建目录（使用字符串路径）
    Directory.create("./test_directory_string", recursive: true)

    // 验证目录是否创建成功
    println("Was the directory created successfully? ${exists("./test_directory_string")}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_directory_string")
}
```

运行结果：

```text
Was the directory created successfully? true
```

### static func createTemp(Path)

```cangjie
public static func createTemp(directoryPath: Path): Path
```

功能：在指定目录下创建临时目录。

参数：

- directoryPath: [Path](fs_package_structs.md#struct-path) - [Path](fs_package_structs.md#struct-path) 形式的目录路径。

返回值：

- [Path](./fs_package_structs.md#struct-path) - 临时目录对应的路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 目录不存在或其他原因导致创建失败时抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 目录为空或包含空字符时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./temp_base_directory", recursive: true)

    // 创建一个目录路径用于创建临时目录
    let baseDir = Path("./temp_base_directory")

    // 确保基础目录存在
    Directory.create(baseDir, recursive: true)

    // 使用 Directory.createTemp 在指定目录下创建临时目录
    let tempDir = Directory.createTemp(baseDir)

    // 临时目录创建成功
    println("The temporary directory has been created successfully.")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./temp_base_directory", recursive: true)
}
```

运行结果：

```text
The temporary directory has been created successfully.
```

### static func createTemp(String)

```cangjie
public static func createTemp(directoryPath: String): Path
```

功能：在指定目录下创建临时目录。

参数：

- directoryPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 字符串形式的目录路径。

返回值：

- [Path](./fs_package_structs.md#struct-path) - 临时目录对应的路径。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 目录不存在或其他原因导致创建失败时抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 目录为空或包含空字符时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./temp_base_directory_string", recursive: true)

    // 确保基础目录存在
    Directory.create("./temp_base_directory_string", recursive: true)

    // 使用 Directory.createTemp 在指定目录下创建临时目录（使用字符串路径）
    let tempDir = Directory.createTemp("./temp_base_directory_string")

    // 临时目录创建成功
    println("The temporary directory has been created successfully.")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./temp_base_directory_string", recursive: true)
}
```

运行结果：

```text
The temporary directory has been created successfully.
```

### static func isEmpty(Path)

```cangjie
public static func isEmpty(path: Path): Bool
```

功能：判断指定目录是否为空。

参数：

- path: [Path](./fs_package_structs.md#struct-path) - 待判断是否为空的目录对应的路径。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 为 true 时目录为空，为 false 时不为空。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果指定路径不存在、指定路径不是目录或判断过程中底层接口发生错误，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./empty_directory")

    // 创建一个空目录
    let emptyDir = Path("./empty_directory")
    Directory.create(emptyDir, recursive: true)

    // 检查目录是否为空
    let isEmpty = Directory.isEmpty(emptyDir)
    println("Is directory empty: ${isEmpty}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./empty_directory")
}
```

运行结果：

```text
Is directory empty: true
```

### static func isEmpty(String)

```cangjie
public static func isEmpty(path: String): Bool
```

功能：判断指定目录是否为空。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待判断是否为空的目录对应的路径。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 为 true 时目录为空，为 false 时不为空。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果指定路径不存在、指定路径不是目录或判断过程中底层接口发生错误，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./empty_directory_string")

    // 创建一个空目录（使用字符串路径）
    Directory.create("./empty_directory_string", recursive: true)

    // 检查目录是否为空（使用字符串路径）
    let isEmpty = Directory.isEmpty("./empty_directory_string")
    println("Is directory empty: ${isEmpty}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./empty_directory_string")
}
```

运行结果：

```text
Is directory empty: true
```

### static func readFrom(Path)

```cangjie
public static func readFrom(path: Path): Array<FileInfo>
```

功能：读取指定路径对应目录下所有子项目的信息。

子项目在数组中的顺序取决于文件在系统中的排序。

参数：

- path: [Path](./fs_package_structs.md#struct-path) - 目录路径。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[FileInfo](fs_package_structs.md#struct-fileinfo)> - 包含子项目文件信息的数组。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 当指定路径不存在、指定路径不是目录或获取目录的成员信息失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_read_directory_string")

    // 创建一个测试目录（使用字符串路径）
    Directory.create("./test_read_directory_string", recursive: true)

    // 读取目录内容（使用Path路径）
    let files = Directory.readFrom(Path("./test_read_directory_string"))
    println("Number of files in directory: ${files.size}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_read_directory_string")
}
```

运行结果：

```text
Number of files in directory: 0
```

### static func readFrom(String)

```cangjie
public static func readFrom(path: String): Array<FileInfo>
```

功能：读取指定路径对应目录下所有子项目的信息。

子项目在数组中的顺序取决于文件在系统中的排序。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 目录路径。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[FileInfo](./fs_package_structs.md#struct-fileinfo)> - 包含子项目文件信息的数组。

异常：

- [FSException](./fs_package_exceptions.md#class-fsexception) - 当指定路径不存在、指定路径不是目录或获取目录的成员信息失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_read_directory_string")

    // 创建一个测试目录（使用字符串路径）
    Directory.create("./test_read_directory_string", recursive: true)

    // 读取目录内容（使用字符串路径）
    let files = Directory.readFrom("./test_read_directory_string")
    println("Number of files in directory: ${files.size}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_read_directory_string")
}
```

运行结果：

```text
Number of files in directory: 0
```

### static func walk(Path, (FileInfo) -> Bool)

```cangjie
public static func walk(path: Path, f: (FileInfo) -> Bool): Unit
```

功能：遍历指定目录下的子项目（非递归，即不包含子目录的子项目），对每一个子项目执行回调函数。

该函数退出条件为遍历结束或指定回调函数返回 false。遍历顺序取决于文件在系统中的排序。

参数：

- path: [Path](./fs_package_structs.md#struct-path) - 目录路径。
- f: ([FileInfo](./fs_package_structs.md#struct-fileinfo)) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 对每一个子项目执行的回调函数，回调函数入参为子项目对应的元信息，返回值表示是否继续遍历。

异常：

- [FSException](./fs_package_exceptions.md#class-fsexception) - 当指定路径不存在、指定路径不是目录或获取目录的成员信息失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_walk_directory", recursive: true)

    // 创建一个测试目录
    let path = Path("./test_walk_directory")
    Directory.create(path, recursive: true)

    // 在目录下创建多个文件
    File.create("./test_walk_directory/abc.txt")
    File.create("./test_walk_directory/bcd.txt")
    File.create("./test_walk_directory/cde.txt")
    File.create("./test_walk_directory/def.txt")

    // 使用 walk 遍历目录，把名字中带b的文件删除
    Directory.walk(
        path,
        {
            fileinfo: FileInfo =>
                if (fileinfo.name.contains("b")) {
                    remove(fileinfo.path)
                }
                return true // 注意：walk 函数退出条件为遍历结束或回调函数 f 返回 false，所以这里写死true，遍历每一个文件
        }
    )

    // 查询是否存在 abc.txt 这个文件
    let isExists = exists("./test_walk_directory/abc.txt")
    println("查询是否存在 abc.txt 这个文件: ${isExists}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_walk_directory", recursive: true)
}
```

运行结果：

```text
查询是否存在 abc.txt 这个文件: false
```

### static func walk(String, (FileInfo) -> Bool)

```cangjie
public static func walk(path: String, f: (FileInfo) -> Bool): Unit
```

功能：遍历指定目录下的子项目（非递归，即不包含子目录的子项目），对每一个子项目执行回调函数。

该函数退出条件为遍历结束或指定回调函数返回 false。遍历顺序取决于文件在系统中的排序。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 目录路径。
- f: ([FileInfo](./fs_package_structs.md#struct-fileinfo)) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 对每一个子项目执行的回调函数，回调函数入参为子项目对应的元信息，返回值表示是否继续遍历。

异常：

- [FSException](./fs_package_exceptions.md#class-fsexception) - 当指定路径不存在、指定路径不是目录或获取目录的成员信息失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除目录，以防创建失败
    removeIfExists("./test_walk_directory", recursive: true)

    // 创建一个测试目录
    Directory.create("./test_walk_directory", recursive: true)

    // 在目录下创建多个文件
    File.create("./test_walk_directory/abc.txt")
    File.create("./test_walk_directory/bcd.txt")
    File.create("./test_walk_directory/cde.txt")
    File.create("./test_walk_directory/def.txt")

    // 使用 walk 遍历目录，把名字中带b的文件删除
    Directory.walk(
        "./test_walk_directory",
        {
            fileinfo: FileInfo =>
                if (fileinfo.name.contains("b")) {
                    remove(fileinfo.path)
                }
                return true // 注意：walk 函数退出条件为遍历结束或回调函数 f 返回 false，所以这里写死true，遍历每一个文件
        }
    )

    // 查询是否存在 abc.txt 这个文件
    let isExists = exists("./test_walk_directory/abc.txt")
    println("查询是否存在 abc.txt 这个文件: ${isExists}")

    // 删除目录，如果想保留目录就注释下面这行代码
    removeIfExists("./test_walk_directory", recursive: true)
}
```

运行结果：

```text
查询是否存在 abc.txt 这个文件: false
```

## class File

```cangjie
public class File <: Resource & IOStream & Seekable {
    public init(path: String, mode: OpenMode)
    public init(path: Path, mode: OpenMode)
}
```

功能：提供一些对文件进行操作的函数，包括文件的打开、创建、关闭、移动、复制、删除，文件的流式读写操作，查询属性以及一些其他函数。

> **注意：**
>
> 创建的 [File](fs_package_classes.md#class-file) 对象会默认打开对应的文件，当使用结束后需要及时调用 [close](fs_package_classes.md#func-close) 函数关闭文件，否则会造成资源泄露。

> **说明：**
>
> 非法路径指的是以下情况之一：
>
> - 路径中包含非法字符，例如空格、制表符、换行符、特殊字符、控制字符等；
> - 路径中包含不存在的目录或文件；
> - 路径中包含无法访问的目录或文件，例如权限不足或被锁定等。
>
> 在输入路径时，应该避免使用非法字符，确保路径的合法性，以便正确地访问目标文件或目录。

父类型：

- [Resource](../../core/core_package_api/core_package_interfaces.md#interface-resource)
- [IOStream](../../io/io_package_api/io_package_interfaces.md#interface-iostream)
- [Seekable](../../io/io_package_api/io_package_interfaces.md#interface-seekable)

### prop fileDescriptor

```cangjie
public prop fileDescriptor: FileDescriptor
```

功能：获取文件描述符信息。

类型：[FileDescriptor](fs_package_structs.md#struct-filedescriptor)

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
    file.fileDescriptor

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_filedescriptor_file.txt", recursive: true)
}
```

### prop info

```cangjie
public prop info: FileInfo
```

功能：获取文件元数据信息。

类型：[FileInfo](fs_package_structs.md#struct-fileinfo)

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_info_file.txt", recursive: true)

    // 创建一个文件并写入一些数据
    var data: Array<Byte> = [73, 110, 102, 111] // "Info"
    File.writeTo("./test_info_file.txt", data)

    // 打开文件
    let file = File("./test_info_file.txt", OpenMode.Read)

    // 获取文件信息
    let fileInfo = file.info

    // 验证文件信息
    println("File name: ${fileInfo.path.fileName}")
    println("File size: ${fileInfo.size}")

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_info_file.txt", recursive: true)
}
```

运行结果：

```text
File name: test_info_file.txt
File size: 4
```

### prop length

```cangjie
public prop length: Int64
```

功能：获取文件头至文件尾的数据字节数。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_length_file.txt", recursive: true)

    // 创建一个文件并写入一些数据
    var data: Array<Byte> = [76, 101, 110, 103, 116, 104] // "Length"
    File.writeTo("./test_length_file.txt", data)

    // 打开文件
    let file = File("./test_length_file.txt", OpenMode.Read)

    // 获取文件长度
    let fileLength = file.length

    // 验证文件长度
    println("File length: ${fileLength}")

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_length_file.txt", recursive: true)
}
```

运行结果：

```text
File length: 6
```

<!--Del_sink-->
### prop length

```cangjie
public prop length: Int64 @local!
```

功能：获取文件头至文件尾的数据字节数。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64) @local!

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_length_file.txt", recursive: true)

    // 创建一个文件并写入 3 个字节
    let writeData: Array<Byte> = [65, 66, 67] // ABC
    File.writeTo("./test_local_length_file.txt", writeData)

    // 打开 `@local!` 文件并获取文件长度
    let path: String @local! = "./test_local_length_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!
    println("File length: ${file.length}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_length_file.txt", recursive: true)
}
```

运行结果：

```text
File length: 3
```

<!--DelEnd_sink-->
### init(Path, OpenMode)

```cangjie
public init(path: Path, mode: OpenMode)
```

功能：创建一个 [File](fs_package_classes.md#class-file) 对象。

需指定文件路径和文件打开方式（读写权限），路径支持相对路径和绝对路径。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 文件路径。
- mode: [OpenMode](fs_package_enums.md#enum-openmode) - 文件打开模式。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果以只读方式打开文件但文件不存在、文件的父目录不存在或其他原因导致无法打开文件，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 path 为空路径或者 path 路径中包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_init_file.txt", recursive: true)

    // 打开文件
    let file = File(Path("./test_init_file.txt"), OpenMode.ReadWrite)

    // 验证文件是否创建成功
    println("Was the file created successfully? ${exists("./test_init_file.txt")}")

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_init_file.txt", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

### init(String, OpenMode)

```cangjie
public init(path: String, mode: OpenMode)
```

功能：创建 [File](fs_package_classes.md#class-file) 对象。

需指定文件路径和文件打开方式（读写权限），路径支持相对路径和绝对路径。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件路径字符串。
- mode: [OpenMode](fs_package_enums.md#enum-openmode) - 文件打开模式。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果以只读方式打开文件但文件不存在、文件的父目录不存在或其他原因导致无法打开文件，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 path 是空字符串或者 path 包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_init_file.txt", recursive: true)

    // 打开文件
    let file = File("./test_init_file.txt", OpenMode.ReadWrite)

    // 验证文件是否创建成功
    println("Was the file created successfully? ${exists("./test_init_file.txt")}")

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_init_file.txt", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

<!--Del_sink-->
### init(this @local!, String @local!, OpenMode @local!)

```cangjie
public exclave init(this @local!, path: String @local!, mode: OpenMode @local!)
```

功能：创建 [File](fs_package_classes.md#class-file) 对象。

需指定文件路径和文件打开方式（读写权限），路径支持相对路径和绝对路径。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 待构造的 `@local!` 实例。
- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - 文件路径字符串。
- mode: [OpenMode](fs_package_enums.md#enum-openmode) @local! - 文件打开模式。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果以只读方式打开文件但文件不存在、文件的父目录不存在或其他原因导致无法打开文件，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 path 是空字符串或者 path 包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_init_file.txt", recursive: true)

    // 在 local region 中创建 File 对象
    let path: String @local! = "./test_local_init_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // 验证文件是否创建成功
    println("Was the file created successfully? ${exists("./test_local_init_file.txt")}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_init_file.txt", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

<!--DelEnd_sink-->
### static func appendTo(Path, Array\<Byte>)

```cangjie
public static func appendTo(path: Path, buffer: Array<Byte>): Unit
```

功能：打开指定路径的文件并将 buffer 以追加的方式写入，文件不存在则将创建文件。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 文件路径。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 待写入的 bytes。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件打开失败或写入失败，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建一个测试文件路径
    let testFile = Path("./test_append_file.txt")

    // 创建要写入的数据
    var data: Array<Byte> = [65, 66, 67] // ABC

    // 使用 File.appendTo 将数据追加到文件
    File.appendTo(testFile, data)

    // 验证文件是否append成功
    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_append_file.txt")

    // 验证文件内容是否正确
    println("Is the file content correct? result: ${readData == data}")

    // 删除文件，如果想保留文件就注释下面这行代码
    removeIfExists("./test_append_file.txt")
}
```

运行结果：

```text
Is the file content correct? result: true
```

### static func appendTo(String, Array\<Byte>)

```cangjie
public static func appendTo(path: String, buffer: Array<Byte>): Unit
```

功能：打开指定路径的文件并将 buffer 以追加的方式写入，文件不存在则将创建文件。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件路径字符串。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 待写入的 bytes。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件打开失败或写入失败，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建要写入的数据
    var data: Array<Byte> = [65, 66, 67] // ABC

    // 使用 File.appendTo 将数据追加到文件
    File.appendTo("./test_append_file.txt", data)

    // 验证文件是否append成功
    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_append_file.txt")

    // 验证文件内容是否正确
    println("Is the file content correct? result: ${readData == data}")

    // 删除文件，如果想保留文件就注释下面这行代码
    removeIfExists("./test_append_file.txt")
}
```

运行结果：

```text
Is the file content correct? result: true
```

### static func create(Path)

```cangjie
public static func create(path: Path): File
```

功能：创建指定路径的文件并返回只写模式的 [File](#class-file) 实例。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 文件路径。

返回值：

- [File](fs_package_classes.md#class-file) - [File](fs_package_classes.md#class-file) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果路径指向的文件的上级目录不存在或文件已存在，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_create_path_file.txt", recursive: true)

    // 创建一个测试文件路径
    let testFile = Path("./test_create_path_file.txt")

    // 使用 File.create 创建文件
    let file = File.create(testFile)

    // 验证文件是否创建成功
    println("Was the file created successfully? ${exists(testFile)}")

    // 关闭文件
    file.close()

    // 删除文件
    removeIfExists("./test_create_path_file.txt", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

### static func create(String)

```cangjie
public static func create(path: String): File
```

功能：创建指定路径的文件并返回只写模式的 [File](#class-file) 实例。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件路径字符串。

返回值：

- [File](fs_package_classes.md#class-file) - [File](fs_package_classes.md#class-file) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果路径指向的文件的上级目录不存在或文件已存在，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空字符串或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_create_file.txt")

    // 使用 File.create 创建文件
    let file = File.create("./test_create_file.txt")

    // 验证文件是否创建成功
    println("Was the file created successfully? ${exists("./test_create_file.txt")}")

    // 关闭文件
    file.close()

    // 删除文件，如果想保留文件就注释下面这行代码
    removeIfExists("./test_create_file.txt")
}
```

运行结果：

```text
Was the file created successfully? true
```

### static func createTemp(Path)

```cangjie
public static func createTemp(directoryPath: Path): File
```

功能：在指定目录下创建临时文件。

创建的文件名称是 tmpFileXXXXXX 形式，不使用的临时文件应手动删除。

参数：

- directoryPath: [Path](fs_package_structs.md#struct-path) - 目录路径。

返回值：

- [File](fs_package_classes.md#class-file) - 临时文件 [File](fs_package_classes.md#class-file) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 创建文件失败或路径不存在则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./temp_directory", recursive: true)

    // 创建一个目录路径
    let directory = Path("./temp_directory")

    // 确保目录存在
    Directory.create(directory, recursive: true)

    // 使用 File.createTemp 创建临时文件
    let tempFile = File.createTemp(directory)

    // 验证临时文件是否创建成功
    println("Was the file created successfully? ${exists(tempFile.info.path)}")

    // 关闭文件
    tempFile.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./temp_directory", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

### static func createTemp(String)

```cangjie
public static func createTemp(directoryPath: String): File
```

功能：在指定目录下创建临时文件。

创建的文件名称是 tmpFileXXXXXX 形式，不使用的临时文件应手动删除。

参数：

- directoryPath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 目录路径字符串。

返回值：

- [File](fs_package_classes.md#class-file) - 临时文件 [File](fs_package_classes.md#class-file) 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 创建文件失败或路径不存在则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空字符串或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./temp_directory", recursive: true)

    // 确保目录存在
    Directory.create("./temp_directory", recursive: true)

    // 使用 File.createTemp 创建临时文件
    let tempFile = File.createTemp("./temp_directory")

    // 验证临时文件是否创建成功
    println("Was the file created successfully? ${exists(tempFile.info.path)}")

    // 关闭文件
    tempFile.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./temp_directory", recursive: true)
}
```

运行结果：

```text
Was the file created successfully? true
```

### static func readFrom(Path)

```cangjie
public static func readFrom(path: Path): Array<Byte>
```

功能：根据指定路径读取文件全部内容，以字节数组的形式返回其内容。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 文件路径。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 字节数组形式的文件全部内容。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件路径为空、文件不可读、文件读取失败，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 文件路径包含空字符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_read_file.txt", recursive: true)

    // 创建一个测试文件路径
    let testFile = Path("./test_read_file.txt")

    // 先创建一个文件并写入一些数据
    var writeData: Array<Byte> = [71, 72, 73] // GHI
    File.writeTo(testFile, writeData)

    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom(testFile)

    // 验证文件内容是否正确读取
    println("Is the file content correct? result: ${readData == writeData}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_read_file.txt", recursive: true)
}
```

运行结果：

```text
Is the file content correct? result: true
```

### static func readFrom(String)

```cangjie
public static func readFrom(path: String): Array<Byte>
```

功能：根据指定路径读取文件全部内容，以字节数组的形式返回其内容。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件路径字符串。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 字节数组形式的文件全部内容。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件读取失败、文件关闭失败、文件路径为空、文件不可读，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 文件路径包含空字符则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_read_file.txt", recursive: true)

    // 先创建一个文件并写入一些数据
    var writeData: Array<Byte> = [71, 72, 73] // GHI
    File.writeTo("./test_read_file.txt", writeData)

    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_read_file.txt")

    // 验证文件内容是否正确读取
    println("Is the file content correct? result: ${readData == writeData}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_read_file.txt", recursive: true)
}
```

运行结果：

```text
Is the file content correct? result: true
```

<!--Del_sink-->
### static func readFrom(String)

```cangjie
public static exclave func readFrom(path: String @local!): Array<Byte> @local!
```

功能：读取指定路径对应文件的全部内容，返回的字节数组绑定在调用者的 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) @local! - 文件路径字符串。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - 文件内容的字节数组。

异常：

- [FSException](./fs_package_exceptions.md#class-fsexception) - 当指定路径不存在或读取文件内容失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当指定路径为空或包含空字符时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_read_from.txt", recursive: true)

    // 先创建文件并写入数据
    let writeData: Array<Byte> = [74, 75, 76] // JKL
    File.writeTo("./test_local_read_from.txt", writeData)

    // 在 local region 中读取文件全部内容
    let path: String @local! = "./test_local_read_from.txt"
    let readData: Array<Byte> @local! = File.readFrom(path)
    println("Bytes read: ${readData.size}")
    println("Content: ${readData[0]}, ${readData[1]}, ${readData[2]}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_read_from.txt", recursive: true)
}
```

运行结果：

```text
Bytes read: 3
Content: 74, 75, 76
```

<!--DelEnd_sink-->
### static func writeTo(Path, Array\<Byte>)

```cangjie
public static func writeTo(path: Path, buffer: Array<Byte>): Unit
```

功能：打开指定路径的文件并将 buffer 以覆盖的方式写入，即文件存在时会将该文件截断为零字节大小，文件不存在则将创建文件。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 文件路径。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 待写入的 bytes。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件打开失败或写入失败，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_write_file.txt", recursive: true)

    // 创建一个测试文件路径
    let testFile = Path("./test_write_file.txt")

    // 创建要写入的数据
    var data: Array<Byte> = [77, 78, 79] // MNO

    // 使用 File.writeTo 将数据写入文件
    File.writeTo(testFile, data)

    // 验证文件是否写入成功
    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_write_file.txt")

    // 验证文件内容是否正确
    println("Is the file content correct? result: ${readData == data}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_write_file.txt", recursive: true)
}
```

运行结果：

```text
Is the file content correct? result: true
```

### static func writeTo(String, Array\<Byte>)

```cangjie
public static func writeTo(path: String, buffer: Array<Byte>): Unit
```

功能：打开指定路径的文件并将 buffer 以覆盖的方式写入，即文件存在时会将该文件截断为零字节大小，文件不存在则将创建文件。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件路径字符串。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 待写入的 bytes。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 文件打开失败或写入失败，则抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果文件路径为空字符串或包含空字符，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_write_file.txt", recursive: true)

    // 创建要写入的数据
    var data: Array<Byte> = [77, 78, 79] // MNO

    // 使用 File.writeTo 将数据写入文件
    File.writeTo("./test_write_file.txt", data)

    // 验证文件是否写入成功
    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_write_file.txt")

    // 验证文件内容是否正确
    println("Is the file content correct? result: ${readData == data}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_write_file.txt", recursive: true)
}
```

运行结果：

```text
Is the file content correct? result: true
```

### func canRead()

```cangjie
public func canRead(): Bool
```

功能：判断当前 [File](fs_package_classes.md#class-file) 对象是否可读。

该函数返回值由创建文件对象的 openMode 所决定，文件对象关闭后返回 false。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示可读，返回 false 表示不可读或文件对象已关闭。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_canread_file.txt", recursive: true)

    // 创建一个测试文件
    let file = File("./test_canread_file.txt", OpenMode.ReadWrite)

    // 检查文件是否可读
    let readable = file.canRead()

    // 验证结果
    println("File is readable: ${readable}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_canread_file.txt", recursive: true)
}
```

运行结果：

```text
File is readable: true
```

### func canWrite()

```cangjie
public func canWrite(): Bool
```

功能：判断当前 [File](fs_package_classes.md#class-file) 对象是否可写。

该函数返回值由创建文件对象的 openMode 所决定，文件对象关闭后返回 false。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示可写，false 表示不可写或文件对象已关闭。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_canwrite_file.txt", recursive: true)

    // 创建一个测试文件
    let file = File.create("./test_canwrite_file.txt")

    // 检查文件是否可写
    let writable = file.canWrite()

    // 验证结果
    println("File is writable: ${writable}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_canwrite_file.txt", recursive: true)
}
```

运行结果：

```text
File is writable: true
```

### func close()

```cangjie
public func close(): Unit
```

功能：关闭当前 [File](fs_package_classes.md#class-file) 对象。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果关闭失败，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_close_file.txt", recursive: true)

    // 创建一个测试文件
    let file = File.create("./test_close_file.txt")

    // 检查文件是否关闭
    let isClosedBefore = file.isClosed()
    println("File is closed before close: ${isClosedBefore}")

    // 关闭文件
    file.close()

    // 检查文件是否关闭
    let isClosedAfter = file.isClosed()
    println("File is closed after close: ${isClosedAfter}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_close_file.txt", recursive: true)
}
```

运行结果：

```text
File is closed before close: false
File is closed after close: true
```

<!--Del_sink-->
### func close()

```cangjie
public exclave func close(this @local!): Unit
```

功能：关闭当前 [File](fs_package_classes.md#class-file) 对象。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果关闭失败，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_close_file.txt", recursive: true)

    // 在 local region 中创建 File 对象
    let path: String @local! = "./test_local_close_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // 关闭文件
    file.close()
    println("File is closed after close: ${file.isClosed()}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_close_file.txt", recursive: true)
}
```

运行结果：

```text
File is closed after close: true
```

<!--DelEnd_sink-->
### func flush()

```cangjie
public func flush(): Unit
```

功能：将缓冲区数据写入流。由于 [File](fs_package_classes.md#class-file) 不存在缓冲区，所以该函数没有具体作用。

示例：

<!-- run -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_flush_file.txt", recursive: true)

    // 创建一个测试文件
    let file = File.create("./test_flush_file.txt")

    // 写入一些数据
    var data: Array<Byte> = [86, 87, 88] // VWX
    file.write(data)

    // 刷新缓冲区
    file.flush()

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_flush_file.txt", recursive: true)
}
```

<!--Del_sink-->
### func flush()

```cangjie
public func flush(this @local?): Unit
```

功能：将缓冲区数据写入流。由于 [File](fs_package_classes.md#class-file) 不存在缓冲区，所以该函数没有具体作用。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_flush_file.txt", recursive: true)

    // 在 local region 中创建 File 对象
    let path: String @local! = "./test_local_flush_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // 显式绑定 `@local?` 接收者
    let localFile: File @local? = file

    // 刷新缓冲区（File 不存在缓冲区，该函数没有具体作用）
    localFile.flush()
    println("File is open after flush: ${!localFile.isClosed()}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_flush_file.txt", recursive: true)
}
```

运行结果：

```text
File is open after flush: true
```

<!--DelEnd_sink-->
### func isClosed()

```cangjie
public func isClosed(): Bool
```

功能：判断当前 [File](fs_package_classes.md#class-file) 对象是否已关闭。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示已关闭，false 表示未关闭。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_isclosed_file.txt", recursive: true)

    // 创建一个测试文件
    let file = File.create("./test_isclosed_file.txt")

    // 检查文件是否关闭
    let isClosedBefore = file.isClosed()
    println("File is closed before close: ${isClosedBefore}")

    // 关闭文件
    file.close()

    // 检查文件是否关闭
    let isClosedAfter = file.isClosed()
    println("File is closed after close: ${isClosedAfter}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_isclosed_file.txt", recursive: true)
}
```

运行结果：

```text
File is closed before close: false
File is closed after close: true
```

<!--Del_sink-->
### func isClosed()

```cangjie
public func isClosed(this @local?): Bool
```

功能：判断当前 [File](fs_package_classes.md#class-file) 对象是否已关闭。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示已关闭，false 表示未关闭。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_isclosed_file.txt", recursive: true)

    // 在 local region 中创建 File 对象
    let path: String @local! = "./test_local_isclosed_file.txt"
    let file: File @local! = File(path, OpenMode.ReadWrite) @local!

    // 显式绑定 `@local?` 接收者
    let localFile: File @local? = file

    // 检查文件是否关闭
    println("File is closed before close: ${localFile.isClosed()}")

    // 关闭文件
    file.close()
    println("File is closed after close: ${localFile.isClosed()}")

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_isclosed_file.txt", recursive: true)
}
```

运行结果：

```text
File is closed before close: false
File is closed after close: true
```

<!--DelEnd_sink-->
### func read(Array\<Byte>)

```cangjie
public func read(buffer: Array<Byte>): Int64
```

功能：从文件中读出数据到 buffer 中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 读取数据存放的缓冲区。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取成功，返回读取字节数，如果文件被读完，返回 0。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 buffer 为空，则抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 读取失败、文件已关闭或文件不可读，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_read_file.txt", recursive: true)

    // 创建一个测试文件并写入数据
    var writeData: Array<Byte> = [89, 90, 91] // YZ[
    File.writeTo("./test_read_file.txt", writeData)

    // 打开文件进行读取
    let file = File("./test_read_file.txt", OpenMode.Read)

    // 创建缓冲区
    var buffer: Array<Byte> = [0, 0, 0]

    // 读取数据
    let bytesRead = file.read(buffer)

    // 验证结果
    println("Bytes read: ${bytesRead}")
    println("Buffer content matches: ${buffer == writeData}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_read_file.txt", recursive: true)
}
```

运行结果：

```text
Bytes read: 3
Buffer content matches: true
```

<!--Del_sink-->
### func read(Array\<Byte>)

```cangjie
public exclave func read(this @local!, buffer: Array<Byte> @local!): Int64
```

功能：从文件中读出数据到 buffer 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> @local! - 读取数据存放的缓冲区。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取成功，返回读取字节数，如果文件被读完，返回 0。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 buffer 为空，则抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 读取失败、文件已关闭或文件不可读，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_read_file.txt", recursive: true)

    // 先创建文件并写入数据
    let writeData: Array<Byte> = [89, 90, 91] // YZ[
    File.writeTo("./test_local_read_file.txt", writeData)

    // 打开 `@local!` 文件进行读取
    let path: String @local! = "./test_local_read_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!

    // 分配 `@local!` 缓冲区
    let buffer: Array<Byte> @local! = [0, 0, 0]

    // 读取数据
    let bytesRead = file.read(buffer)
    println("Bytes read: ${bytesRead}")
    println("Content: ${buffer[0]}, ${buffer[1]}, ${buffer[2]}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_read_file.txt", recursive: true)
}
```

运行结果：

```text
Bytes read: 3
Content: 89, 90, 91
```

<!--DelEnd_sink-->
### func seek(SeekPosition)

```cangjie
public func seek(sp: SeekPosition): Int64
```

功能：将光标跳转到指定位置。

指定的位置不能位于文件头部之前，指定位置可以超过文件末尾，但指定位置到文件头部的最大偏移量不能超过当前文件系统允许的最大值，这个最大值接近当前文件系统的所允许的最大文件大小，一般为最大文件大小减去 4096 个字节。

参数：

- sp: [SeekPosition](../../io/io_package_api/io_package_enums.md#enum-seekposition) - 指定光标跳转后的位置。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 返回文件头部到跳转后位置的偏移量（以字节为单位）。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 指定位置不满足以上情况时或文件不能 seek 时均会抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*
import std.io.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_seek_file.txt", recursive: true)

    // 创建一个测试文件并写入数据
    var writeData: Array<Byte> = [65, 66, 67, 68, 69] // ABCDE
    File.writeTo("./test_seek_file.txt", writeData)

    // 打开文件进行读取
    let file = File("./test_seek_file.txt", OpenMode.ReadWrite)

    // 读取第一个字节
    var buffer: Array<Byte> = [0]
    file.read(buffer)
    println("First byte: ${buffer[0]}")

    // 将光标跳转到文件开头
    file.seek(SeekPosition.Begin(0))

    // 再次读取第一个字节
    file.read(buffer)
    println("First byte after seek: ${buffer[0]}")

    // 将光标跳转到文件末尾前一个字节
    file.seek(SeekPosition.End(-1))

    // 读取最后一个字节
    file.read(buffer)
    println("Last byte: ${buffer[0]}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_seek_file.txt", recursive: true)
}
```

运行结果：

```text
First byte: 65
First byte after seek: 65
Last byte: 69
```

<!--Del_sink-->
### func seek(SeekPosition)

```cangjie
public func seek(this @local!, sp: SeekPosition): Int64
```

功能：将光标跳转到指定位置。

指定的位置不能位于文件头部之前，指定位置可以超过文件末尾，但指定位置到文件头部的最大偏移量不能超过当前文件系统允许的最大值，这个最大值接近当前文件系统的所允许的最大文件大小，一般为最大文件大小减去 4096 个字节。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- sp: [SeekPosition](../../io/io_package_api/io_package_enums.md#enum-seekposition) - 指定光标跳转后的位置。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 返回文件头部到跳转后位置的偏移量（以字节为单位）。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 指定位置不满足以上情况时或文件不能 seek 时均会抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*
import std.io.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_local_seek_file.txt", recursive: true)

    // 先创建文件并写入数据
    let writeData: Array<Byte> = [65, 66, 67] // ABC
    File.writeTo("./test_local_seek_file.txt", writeData)

    // 打开 `@local!` 文件进行读取
    let path: String @local! = "./test_local_seek_file.txt"
    let file: File @local! = File(path, OpenMode.Read) @local!

    // 分配 `@local!` 缓冲区
    let buffer: Array<Byte> @local! = [0]

    // 读取一个字节，光标位于 1
    file.read(buffer)
    println("First byte: ${buffer[0]}")

    // 将光标跳转回文件开头
    let pos = file.seek(SeekPosition.Begin(0))
    println("Position after seek: ${pos}")

    // 再次读取第一个字节
    file.read(buffer)
    println("First byte after seek: ${buffer[0]}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_local_seek_file.txt", recursive: true)
}
```

运行结果：

```text
First byte: 65
Position after seek: 0
First byte after seek: 65
```

<!--DelEnd_sink-->
### func setLength(Int64)

```cangjie
public func setLength(length: Int64): Unit
```

功能：将当前文件截断为指定长度。当 length 大于当前文件长度时，则将使用 0 填充文件直到目标长度。此方法不会改变文件光标的位置。

参数：

- length: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 指定截断的长度。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 指定的长度为负数时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 文件截断操作失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*
import std.io.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_setlength_file.txt", recursive: true)

    // 创建一个测试文件并写入数据
    var writeData: Array<Byte> = [65, 66, 67, 68, 69] // ABCDE
    File.writeTo("./test_setlength_file.txt", writeData)

    // 打开文件
    let file = File("./test_setlength_file.txt", OpenMode.ReadWrite)

    // 获取文件原始长度
    let originalLength = file.length
    println("Original file length: ${originalLength}")

    // 将文件长度截断为3字节
    file.setLength(3)

    // 获取文件新长度
    let newLength = file.length
    println("New file length: ${newLength}")

    // 读取截断后的文件内容
    file.seek(SeekPosition.Begin(0))
    var buffer: Array<Byte> = [0, 0, 0]
    file.read(buffer)
    println("File content after truncation: ${buffer}")

    // 将文件长度扩展到6字节
    file.setLength(6)

    // 获取文件扩展后的长度
    let extendedLength = file.length
    println("Extended file length: ${extendedLength}")

    // 关闭文件
    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_setlength_file.txt", recursive: true)
}
```

运行结果：

```text
Original file length: 5
New file length: 3
File content after truncation: [65, 66, 67]
Extended file length: 6
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：将 buffer 中的数据写入到文件中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 待写入数据的缓冲区，若 buffer 为空则直接返回。

异常：

- [FSException](fs_package_exceptions.md#class-fsexception) - 如果写入失败、只写入了部分数据、文件已关闭或文件不可写则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_write_file.txt", recursive: true)

    // 创建要写入的数据
    var data: Array<Byte> = [77, 78, 79] // MNO

    // 打开文件
    let file = File("./test_write_file.txt", OpenMode.ReadWrite)
    // 使用 write 将数据写入文件
    file.write(data)

    // 使用 File.readFrom 读取文件内容
    let readData = File.readFrom("./test_write_file.txt")

    // 验证文件内容是否正确
    println("Is the file content correct? result: ${readData == data}")

    file.close()

    // 删除，如果想保留就注释下面这行代码
    removeIfExists("./test_write_file.txt", recursive: true)
}
```

运行结果：

```text
Is the file content correct? result: true
```

## class HardLink

```cangjie
public class HardLink {}
```

功能：提供处理文件系统硬链接相关接口。

### static func create(Path, Path)

```cangjie
public static func create(link: Path, to!: Path): Unit
```

功能：创建一个新的硬链接到现有路径。如果新的路径存在，则不会覆盖。

参数：

- link: [Path](fs_package_structs.md#struct-path) - 新路径的名称。
- to!: [Path](fs_package_structs.md#struct-path) - 现有路径的名称。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 创建硬链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists(Path("./test_hardlink_source.txt"), recursive: true)
    removeIfExists(Path("./test_hardlink_target.txt"), recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [72, 97, 114, 100, 76, 105, 110, 107] // "HardLink"
    File.writeTo(Path("./test_hardlink_source.txt"), data)

    // 创建硬链接
    HardLink.create(Path("./test_hardlink_target.txt"), to: Path("./test_hardlink_source.txt"))

    // 验证硬链接是否创建成功
    println("Hard link created successfully")

    // 检查硬链接文件是否存在
    if (exists(Path("./test_hardlink_target.txt"))) {
        println("Hard link file exists")
        // 读取硬链接文件内容
        let content = File.readFrom(Path("./test_hardlink_target.txt"))
        println("Hard link file content: ${content}")
    }

    // 删除文件
    removeIfExists(Path("./test_hardlink_source.txt"), recursive: true)
    removeIfExists(Path("./test_hardlink_target.txt"), recursive: true)
}
```

运行结果：

```text
Hard link created successfully
Hard link file exists
Hard link file content: [72, 97, 114, 100, 76, 105, 110, 107]
```

### static func create(String, String)

```cangjie
public static func create(link: String, to!: String): Unit
```

功能：创建一个新的硬链接到现有路径。如果新的路径存在，则不会覆盖。

参数：

- link: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 新路径的名称。
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 现有路径的名称。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 创建硬链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_hardlink_source.txt", recursive: true)
    removeIfExists("./test_hardlink_target.txt", recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [72, 97, 114, 100, 76, 105, 110, 107] // "HardLink"
    File.writeTo("./test_hardlink_source.txt", data)

    // 创建硬链接
    HardLink.create("./test_hardlink_target.txt", to: "./test_hardlink_source.txt")

    // 验证硬链接是否创建成功
    println("Hard link created successfully")

    // 检查硬链接文件是否存在
    if (exists("./test_hardlink_target.txt")) {
        println("Hard link file exists")
        // 读取硬链接文件内容
        let content = File.readFrom("./test_hardlink_target.txt")
        println("Hard link file content: ${content}")
    }

    // 删除文件
    removeIfExists("./test_hardlink_source.txt", recursive: true)
    removeIfExists("./test_hardlink_target.txt", recursive: true)
}
```

运行结果：

```text
Hard link created successfully
Hard link file exists
Hard link file content: [72, 97, 114, 100, 76, 105, 110, 107]
```

## class SymbolicLink

```cangjie
public class SymbolicLink {}
```

功能：提供处理文件系统符号链接相关接口。

### static func create(Path, Path)

```cangjie
public static func create(link: Path, to!: Path): Unit
```

功能：创建一个新的符号链接到现有路径。

> **说明：**
>
> 在 Windows 上，创建一个目标不存在的符号链接时，会创建一个文件符号链接，如果目标路径后来被创建为目录，则符号链接将不起作用。

参数：

- link: [Path](fs_package_structs.md#struct-path) - 待创建的符号链接。
- to!: [Path](fs_package_structs.md#struct-path) - 待创建的符号链接的目标的路径。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 创建符号链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107] // "SymbolicLink"
    File.writeTo("./test_symlink_source.txt", data)

    // 创建符号链接
    SymbolicLink.create(Path("./test_symlink_target.txt"), to: Path("./test_symlink_source.txt"))

    // 验证符号链接是否创建成功
    println("Symbolic link created successfully")

    // 检查符号链接文件是否存在
    if (exists("./test_symlink_target.txt")) {
        println("Symbolic link file exists")
        // 读取符号链接文件内容
        let content = File.readFrom("./test_symlink_target.txt")
        println("Symbolic link file content: ${content}")
    }

    // 删除文件
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)
}
```

运行结果：

```text
Symbolic link created successfully
Symbolic link file exists
Symbolic link file content: [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107]
```

### static func create(String, String)

```cangjie
public static func create(link: String, to!: String): Unit
```

功能：创建一个新的符号链接到现有路径。

> **说明：**
>
> 在 Windows 上，创建一个目标不存在的符号链接时，会创建一个文件符号链接，如果目标路径后来被创建为目录，则符号链接将不起作用。

参数：

- link: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待创建的符号链接。
- to!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待创建的符号链接的目标的路径。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 创建符号链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107] // "SymbolicLink"
    File.writeTo("./test_symlink_source.txt", data)

    // 创建符号链接
    SymbolicLink.create("./test_symlink_target.txt", to: "./test_symlink_source.txt")

    // 验证符号链接是否创建成功
    println("Symbolic link created successfully")

    // 检查符号链接文件是否存在
    if (exists("./test_symlink_target.txt")) {
        println("Symbolic link file exists")
        // 读取符号链接文件内容
        let content = File.readFrom("./test_symlink_target.txt")
        println("Symbolic link file content: ${content}")
    }

    // 删除文件
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)
}
```

运行结果：

```text
Symbolic link created successfully
Symbolic link file exists
Symbolic link file content: [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107]
```

### static func readFrom(Path, Bool)

```cangjie
public static func readFrom(path: Path, recursive!: Bool = false): Path
```

功能：获取指定符号链接的目标。当指定 'recursive' 为 'true' 时，表示跟踪指向最终目标的链接，并且返回目标的全路径，当指定 'recursive' 为 'false' 时，读取当前目标链接并且返回。

参数：

- path: [Path](fs_package_structs.md#struct-path) - 符号链接的地址。
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否递归读取目标地址，默认为 'false'。

返回值：

- [Path](fs_package_structs.md#struct-path) - 符号链接的目标地址。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 读取符号链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107] // "SymbolicLink"
    File.writeTo("./test_symlink_source.txt", data)

    // 创建符号链接
    SymbolicLink.create("./test_symlink_target.txt", to: "./test_symlink_source.txt")

    // 读取符号链接的目标
    let targetPath = SymbolicLink.readFrom(Path("./test_symlink_target.txt"))

    // 验证读取结果
    println("Symbolic link target: ${targetPath}")

    // 删除文件
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)
}
```

运行结果：

```text
Symbolic link target: ./test_symlink_source.txt
```

### static func readFrom(String, Bool)

```cangjie
public static func readFrom(path: String, recursive!: Bool = false): Path
```

功能：获取指定符号链接的目标。当指定 'recursive' 为 'true' 时，表示跟踪指向最终目标的链接，并且返回目标的全路径，当指定 'recursive' 为 'false' 时，读取当前目标链接并且返回。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 符号链接的地址。
- recursive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否递归读取目标地址，默认为 'false'。

返回值：

- [Path](fs_package_structs.md#struct-path) - 符号链接的目标地址。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数中路径为空、或者包含空字符时抛出异常。
- [FSException](fs_package_exceptions.md#class-fsexception) - 读取符号链接失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.fs.*

main(): Unit {
    // 创建前先删除，以防创建失败
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)

    // 创建一个源文件
    var data: Array<Byte> = [83, 121, 109, 98, 111, 108, 105, 99, 76, 105, 110, 107] // "SymbolicLink"
    File.writeTo("./test_symlink_source.txt", data)

    // 创建符号链接
    SymbolicLink.create("./test_symlink_target.txt", to: "./test_symlink_source.txt")

    // 读取符号链接的目标
    let targetPath = SymbolicLink.readFrom("./test_symlink_target.txt")

    // 验证读取结果
    println("Symbolic link target: ${targetPath}")

    // 删除文件
    removeIfExists("./test_symlink_source.txt", recursive: true)
    removeIfExists("./test_symlink_target.txt", recursive: true)
}
```

运行结果：

```text
Symbolic link target: ./test_symlink_source.txt
```
