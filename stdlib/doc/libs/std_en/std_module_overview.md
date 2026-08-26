# Cangjie Programming Language Standard Library Overview

The Cangjie Programming Language Standard Library (std) is a default library included with the Cangjie SDK installation. The standard library predefines a set of functions, classes, structures, etc., designed to provide commonly used functionalities and utilities, enabling developers to write programs more quickly and efficiently.

The Cangjie Standard Library has three key characteristics and objectives:

- **Ease of Use**: The standard library is distributed with the compiler and toolchain, requiring no additional downloads—ready to use out of the box.
- **General Functionality**: The standard library offers the most frequently used library capabilities, aiming to solve most fundamental problems for developers.
- **Quality Benchmark**: The standard library strives to set examples and benchmarks in performance, coding style, and other aspects for other Cangjie libraries.

## Platform Support

The APIs provided by the standard library support running on the following operating systems:

> **Note:**
>
> Some APIs do not support running on specific operating systems. For details, please refer to the corresponding API descriptions.

| OS            | CPU Arch  | Environment and Version Requirements |
| ------------- | --------- | --------------- |
| Linux         | x86_64    | glibc 2.22; Linux Kernel 4.12 or later; libstdc++ 6.0.24 or later installed |
| Linux         | aarch64   | glibc 2.27; Linux Kernel 4.15 or later; libstdc++ 6.0.24 or later installed |
| Windows       | x86_64    | Windows 10 or later |
| macOS         | aarch64   | macOS 12.0 or later |
| macOS         | x86_64    | macOS 12.0 or later |
| OpenHarmony   | aarch64   | OpenHarmony 5.1 or later |
| OpenHarmony   | arm32     | OpenHarmony 5.1 or later |
| OpenHarmony   | x86_64    | OpenHarmony 5.1 or later |
| HarmonyOS     | aarch64   | HarmonyOS 5.1 or later |
| iOS           | aarch64   | iOS 11 or later (ast library requires iOS 12 or later) |
| iOS           | x86_64    | iOS 11 or later (simulator, ast library requires iOS 12 or later) |
| Android       | aarch64   | Android API 23 or later |
| Android       | x86_64    | Android API 26 or later |
| Android       | arm32     | Android API 23 or later |

## Usage Guide

In the Cangjie programming language, the standard library consists of several packages, where a package is the smallest compilation unit. Each package can independently produce outputs such as AST (Abstract Syntax Trees) files, static library files, dynamic library files, etc. Packages can define sub-packages, forming a tree-like structure. A package without a parent is called a root package, and the entire tree formed by the root package and its sub-packages (including sub-packages of sub-packages) is called a module. The module's name is the same as the root package and represents the smallest unit for developer releases.

Package import rules are as follows:

- You can import a top-level declaration or definition from a package using the following syntax:

    ```cangjie
    import fullPackageName.itemName
    ```

    Here, `fullPackageName` is the complete path of the package name, and `itemName` is the name of the declaration. For example:

    ```cangjie
    import std.collection.ArrayList
    ```

- If multiple `itemName`s belong to the same `fullPackageName`, you can use:

    ```cangjie
    import fullPackageName.{itemName[, itemName]*}
    ```

    For example:

    ```cangjie
    import std.collection.{ArrayList, HashMap}
    ```

- You can also import all top-level declarations or definitions marked as `public` from the `fullPackageName` package using:

    ```cangjie
    import fullPackageName.*
    ```

    For example:

    ```cangjie
    import std.collection.*
    ```

## Package List

The std library includes several packages that provide rich foundational functionalities:

| Package Name | Functionality |
|-------------|--------------|
| [core](./core/core_package_overview.md) | The core package of the standard library, providing the most fundamental API capabilities for Cangjie programming. |
| [argopt](./argopt/argopt_package_overview.md) | The argopt package provides capabilities for parsing parameter names and values from command-line argument strings. |
| [ast](./ast/ast_package_overview.md) | The ast package mainly includes Cangjie source code syntax parsers and Cangjie syntax tree nodes, offering syntax parsing functions. |
| [binary](./binary/binary_package_overview.md) | The binary package provides interfaces for converting between basic data types and binary byte arrays with different endianness, as well as endianness reversal. |
| [collection](./collection/collection_package_overview.md) | The collection package offers efficient implementations of common data structures, definitions of related abstract interfaces, and frequently used functions in collection types. |
| [collection.concurrent](./collection_concurrent/collection_concurrent_package_overview.md) | The collection.concurrent package provides thread-safe implementations of collection types. |
| [console](./console/console_package_overview.md) | The console package provides methods for interacting with standard input, output, and error streams. |
| [convert](./convert/convert_package_overview.md) | The convert package offers Convert series functions for converting strings to specific types, as well as formatting capabilities, primarily for converting Cangjie type instances to formatted strings. |
| [crypto.cipher](./crypto/cipher/cipher_package_overview.md) | The crypto.cipher package provides generic interfaces for symmetric encryption and decryption. |
| [crypto.digest](./crypto/digest/digest_package_overview.md) | The crypto.digest package offers generic interfaces for common digest algorithms, including MD5, SHA1, SHA224, SHA256, SHA384, SHA512, HMAC, and SM3. |
| [database.sql](./database_sql/database_sql_package_overview.md) | The database.sql package provides interfaces for Cangjie to access databases. |
| [deriving](./deriving/deriving_package_overview.md) | The deriving package provides a set of macros for automatically generating interface implementations. |
| [env](./env/env_package_overview.md) | The env package offers information and functionalities related to the current process, including environment variables, command-line arguments, standard streams, and program termination. |
| [fs](./fs/fs_package_overview.md) | The fs (file system) package provides functions for operating on files, directories, paths, and file metadata. |
| [io](./io/io_package_overview.md) | The io package enables data exchange between programs and external devices. |
| [math](./math/math_package_overview.md) | The math package provides common mathematical operations, constant definitions, floating-point number handling, and other functionalities. |
| [math.numeric](./math_numeric/math_numeric_package_overview.md) | The math.numeric package extends capabilities beyond the expressible range of basic types. |
| [net](./net/net_package_overview.md) | The net package provides common network communication functionalities. |
| [objectpool](./objectpool/objectpool_package_overview.md) | The objectpool package offers capabilities for object caching and reuse. |
| [overflow](./overflow/overflow_package_overview.md) | The overflow package provides functionalities related to overflow handling. |
| [posix](./posix/posix_package_overview.md) | The posix package encapsulates POSIX system calls, offering cross-platform system operation interfaces. |
| [process](./process/process_package_overview.md) | The process package mainly provides Process operation interfaces, including process creation, standard stream acquisition, process waiting, and process information querying. |
| [random](./random/random_package_overview.md) | The random package provides capabilities for generating pseudo-random numbers. |
| [reflect](./reflect/reflect_package_overview.md) | The reflect package offers reflection functionalities, enabling programs to obtain type information of various instances at runtime and perform read/write and invocation operations. |
| [regex](./regex/regex_package_overview.md) | The regex package provides capabilities for analyzing and processing text using regular expressions (supporting UTF-8 encoded Unicode strings), including search, split, replace, and validation functionalities. |
| [runtime](./runtime/runtime_package_overview.md) | The runtime package interacts with the program's runtime environment, providing a series of functions and variables for controlling, managing, and monitoring program execution. |
| [sort](./sort/sort_package_overview.md) | The sort package provides sorting functions for array types. |
| [sync](./sync/sync_package_overview.md) | The sync package offers capabilities related to concurrent programming. |
| [time](./time/time_package_overview.md) | The time package provides time-related types, including date-time, time intervals, monotonic time, and time zones, along with functionalities for calculation and comparison. |
| [unicode](./unicode/unicode_package_overview.md) | The unicode package provides capabilities for handling characters according to the Unicode encoding standard. |
| [unittest](./unittest/unittest_package_overview.md) | The unittest package is used for writing unit test code for Cangjie projects, providing basic functionalities including code writing, execution, and debugging. |
| [unittest.mock](./unittest_mock/unittest_mock_package_overview.md) | The unittest.mock package provides a mock framework for Cangjie unit tests, offering APIs to create and configure mock objects that have API signatures consistent with real objects. |
| [unittest.testmacro](./unittest_testmacro/unittest_testmacro_package_overview.md) | The unittest.testmacro package provides macros required by users for the unit testing framework. |
| [unittest.mock.mockmacro](./unittest_mock_mockmacro/unittest_mock_mockmacro_package_overview.md) | The unittest.mock.mockmacro package provides macros required by users for the mock framework. |
| [unittest.common](./unittest_common/unittest_common_package_overview.md) | The unittest.common package provides types and general methods required for printing in the unit testing framework. |
| [unittest.diff](./unittest_diff/unittest_diff_package_overview.md) | The unittest.diff package provides APIs required for printing difference comparison information in the unit testing framework. |
| [unittest.prop_test](./unittest_prop_test/unittest_prop_test_package_overview.md) | The unittest.prop_test package provides types and general methods required for parameterized testing in the unit testing framework. |
