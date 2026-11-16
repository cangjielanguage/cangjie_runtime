# Functions

## func acquireArrayRawData\<T>(Array\<T>) where T <: CType

```cangjie
public unsafe func acquireArrayRawData<T>(arr: Array<T>): CPointerHandle<T> where T <: CType
```

Function: Obtains a raw pointer instance to the data in an [Array](core_package_structs.md#struct-arrayt)\<T>, where the pointer points to the address of the first element in the array. T must satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint.

> **Note:**
>
> The pointer must be released promptly using the [releaseArrayRawData](core_package_funcs.md#func-releasearrayrawdatatcpointerhandlet-where-t--ctype) function after use.
> Between acquiring and releasing the pointer, only simple foreign C function calls and similar logic should be included. Do not construct Cangjie objects such as [CString](core_package_intrinsics.md#cstring), as this may lead to unexpected behavior.

Parameters:

- arr: [Array](./core_package_structs.md#struct-arrayt)\<T> - The array from which to obtain the raw pointer.

Returns:

- [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype)\<T> - The raw pointer instance of the array.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    var cptr: CPointer<Int64> = cptrHandle.pointer

    let num: Int64 = unsafe { cptr.read() }
    println("The first element of the array is ${num} ")

    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Output:

```text
The first element of the array is 1
```

<!--Del_sink-->
## func acquireArrayRawData\<T>(Array\<T>) where T <: CType

```cangjie
public exclave unsafe func acquireArrayRawData<T>(arr: Array<T> @local?): CPointerHandle<T> @local? where T <: CType
```

Function: Obtains a raw pointer instance to the data in an [Array](core_package_structs.md#struct-arrayt)\<T>; the pointer instance points to the address of the first element of the array, and T must satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - The pointer must be released in time with the [releaseArrayRawData](core_package_funcs.md#func-releasearrayrawdatatcpointerhandlet-where-t--ctype) function after use.
> - Between acquiring and releasing the pointer, only simple logic such as foreign C function calls is allowed; do not construct Cangjie objects such as [CString](core_package_intrinsics.md#cstring), otherwise unpredictable behavior may occur.

Parameters:

- arr: [Array](./core_package_structs.md#struct-arrayt)\<T> @local? - The array whose raw pointer is to be obtained; `@local!` and `@local?` arguments are supported.

Returns:

- [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype)\<T> @local? - The raw pointer instance of the array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3, 4]
    let cptrHandle: CPointerHandle<Int64> @local? = unsafe { acquireArrayRawData(arr) }
    let cptr: CPointer<Int64> = cptrHandle.pointer

    let num: Int64 = unsafe { cptr.read() }
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
    println("The first element of the array is ${num}")
}
```

Output:

```text
The first element of the array is 1
```

<!--DelEnd_sink-->
## func alignOf\<T>() where T <: CType

```cangjie
public func alignOf<T>(): UIntNative where T <: CType
```

Function: Obtains the memory alignment value for type T.

Returns:

- [UIntNative](core_package_intrinsics.md#uintnative) - The number of bytes required for type T to satisfy memory alignment.

Example:

<!-- verify -->
```cangjie
@C
struct Data {
    var a: Int64 = 0
    var b: Float32 = 0.0
}

main() {
    let alignSizeInt8: UIntNative = alignOf<Int8>()
    println("The memory alignment requirement for Int64 type is ${alignSizeInt8} byte")

    let alignSizeInt32: UIntNative = alignOf<Int32>()
    println("The memory alignment requirement for Int64 type is ${alignSizeInt32} bytes")

    let alignSizeInt64: UIntNative = alignOf<Int64>()
    println("The memory alignment requirement for Int64 type is ${alignSizeInt64} bytes")

    let alignSizeData: UIntNative = alignOf<Data>()
    println("The memory alignment requirement for Int64 type is ${alignSizeData} bytes")
}
```

Output:

```text
The memory alignment requirement for Int64 type is 1 byte
The memory alignment requirement for Int64 type is 4 bytes
The memory alignment requirement for Int64 type is 8 bytes
The memory alignment requirement for Int64 type is 8 bytes
```

## func eprint(String, Bool)

```cangjie
public func eprint(str: String, flush!: Bool = true): Unit
```

Function: Prints the specified string to the standard error text stream.

When an exception is thrown, the message will be printed to the standard error text stream (stderr) instead of standard output (stdout).

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to immediately flush the contents of the buffer to the file or device associated with the standard error stream. true means immediate flush, false means no flush (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        eprint("NegativeArraySizeException is caught!", flush: true)
    }
}
```

Output:

```text
NegativeArraySizeException is caught!
```

## func eprint\<T>(T, Bool) where T <: ToString

```cangjie
public func eprint<T>(arg: T, flush!: Bool = false): Unit where T <: ToString
```

Function: Prints the string representation of the specified T-type instance to the standard error text stream.

When an exception is thrown, the message will be printed to the standard error text stream (stderr) instead of standard output (stdout).

Parameters:

- arg: T - The T-type instance to print. The function will print the return value of its toString method.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. true means flush, false means no flush (default: false).

Example:

<!-- verify -->
```cangjie
class Rectangle <: ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        width * height
    }
    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}"
    }
}

main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        eprint<Rectangle>(Rectangle(10, 20), flush: true)
    }
}
```

Output:

```text
width: 10, height: 20
```

## func eprintln(String)

```cangjie
public func eprintln(str: String): Unit
```

Function: Prints the specified string to the standard error text stream with a trailing newline.

When an exception is thrown, the message will be printed to the standard error text stream (stderr) instead of standard output (stdout).

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to output.

Example:

<!-- verify -->
```cangjie
main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        eprintln("NegativeArraySizeException is caught!")
    }
}
```

Output:

```text
NegativeArraySizeException is caught!
```

## func eprintln\<T>(T) where T <: ToString

```cangjie
public func eprintln<T>(arg: T): Unit where T <: ToString
```

Function: Prints the string representation of the specified T-type instance to the standard error text stream with a trailing newline.

When an exception is thrown, the message will be printed to the standard error text stream (stderr) instead of standard output (stdout).

Parameters:

- arg: T - The T-type instance to print. The function will print the return value of its toString method.

Example:

<!-- verify -->
```cangjie
class Rectangle <: ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        width * height
    }
    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}"
    }
}

main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        eprintln<Rectangle>(Rectangle(10, 20))
    }
}
```

Output:

```text
width: 10, height: 20
```

## func exclusiveScope\<T>(( ) -> T)

```cangjie
public func exclusiveScope<T>(fn: () -> T): T
```

Function: Executes a closure in an exclusive scope, ensuring that the closure runs in an isolated context and handling any results or exceptions appropriately. When executing fn, a switch from the cangjie thread stack to the OS thread stack will occur, and the underlying OS thread cannot be preempted by other cangjie threads. After fn returns, it will switch back to the cangjie thread stack, and the preemption will be permitted.

> **Note:**
>
> This function is not available on Windows, macOS, OpenHarmony.

Parameters:

- fn: () -> T - The function/closure to be executed in the exclusive scope.

Return values:

- T - The result of the function execution.

Throws:

- [ExclusiveScopeException](core_package_exceptions.md#class-exclusivescopeexception) - if an exception occurs during execution.

Example:

<!-- verify -->
```cangjie
main() {
    let result = exclusiveScope<Int64> {
        // Execute code in exclusive scope
        return 42
    }
    println("Result: ${result}")
    
    // Can also execute operations without return value
    exclusiveScope<Unit> {
        println("Executing in exclusive scope")
    }
}
```

Output:

```text
Result: 42
Executing in exclusive scope
```

## func ifNone\<T>(Option\<T>, () -> Unit)

```cangjie
public func ifNone<T>(o: Option<T>, action: () -> Unit): Unit
```

Function: Executes the action function if the input is of type [Option](core_package_enums.md#enum-optiont).None.

Parameters:

- o: [Option](core_package_enums.md#enum-optiont)\<T> - The [Option](core_package_enums.md#enum-optiont)\<T> instance to check for [Option](core_package_enums.md#enum-optiont).None.
- action: () ->[Unit](core_package_intrinsics.md#unit) - The function to execute.

Example:

<!-- verify -->
```cangjie
main() {
    let num: Option<Int64> = None
    ifNone<Int64>(num, {=> println("num is None")})
}
```

Output:

```text
num is None
```

## func ifSome\<T>(Option\<T>, (T) -> Unit)

```cangjie
public func ifSome<T>(o: Option<T>, action: (T) -> Unit): Unit
```

Function: Executes the action function if the input is of type [Option](core_package_enums.md#enum-optiont).Some.

Parameters:

- o: [Option](core_package_enums.md#enum-optiont)\<T> - The [Option](core_package_enums.md#enum-optiont)\<T> instance to check for [Option](core_package_enums.md#enum-optiont).Some. The encapsulated `T`-type instance will be passed as input to the action function.
- action: (T) ->[Unit](core_package_intrinsics.md#unit) - The function to execute.<!-- verify -->

```cangjie
main() {
    let num: Option<Int64> = Some(200)
    ifSome<Int64>(num, {numValue: Int64 => println("num is ${numValue}")})
}
```

Execution Result:

```text
num is 200
```

## func max\<T>(T, T, Array\<T>) where T <: Comparable\<T>

```cangjie
public func max<T>(a: T, b: T, others: Array<T>): T where T <: Comparable<T>
```

Function: Returns the maximum value among a set of data based on the implementation of the [Comparable](./core_package_interfaces.md#interface-comparablet) interface for type T. Since the third parameter of this function is a variadic parameter, it supports comparisons of more than two data points.

> **Note:**
>
> Floating-point comparisons will also follow the results of [Comparable](./core_package_interfaces.md#interface-comparablet). If there is a `NaN` (Not a Number) in the floating-point values, the result will be incorrect. In such cases, it is recommended to use the `static func max` method of [Float16](./core_package_intrinsics.md#float16), [Float32](./core_package_intrinsics.md#float32), or [Float64](./core_package_intrinsics.md#float64).

Parameters:

- a: T - The first value to compare.
- b: T - The second value to compare.
- others: [Array](./core_package_structs.md#struct-arrayt)\<T> - Other values to compare.

Returns:

- T - The maximum value among the parameters.

Example:

<!-- verify -->
```cangjie
class Rectangle <: Comparable<Rectangle> & ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public prop area: Int64 {
        get() {
            return this.width * this.height
        }
    }
    public func compare(t: Rectangle): Ordering {
        if (t.area > this.area) {
            return Ordering.LT
        } else if (t.area == this.area) {
            return Ordering.EQ
        } else {
            Ordering.GT
        }
    }
    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}, area: ${this.area}"
    }
}

main() {
    var r1: Rectangle = Rectangle(10, 20)
    var r2: Rectangle = Rectangle(20, 30)
    println("The larger one is ${max(r1, r2)}")
}
```

Execution Result:

```text
The larger one is width: 20, height: 30, area: 600
```

## func min\<T>(T, T, Array\<T>) where T <: Comparable\<T>

```cangjie
public func min<T>(a: T, b: T, others: Array<T>): T where T <: Comparable<T>
```

Function: Returns the minimum value among a set of data based on the implementation of the [Comparable](./core_package_interfaces.md#interface-comparablet) interface for type T. Since the third parameter of this function is a variadic parameter, it supports comparisons of more than two data points.

> **Note:**
>
> Floating-point comparisons will also follow the results of [Comparable](./core_package_interfaces.md#interface-comparablet). If there is a `NaN` (Not a Number) in the floating-point values, the result will be incorrect. In such cases, it is recommended to use the `static func min` method of [Float16](./core_package_intrinsics.md#float16), [Float32](./core_package_intrinsics.md#float32), or [Float64](./core_package_intrinsics.md#float64).

Parameters:

- a: T - The first value to compare.
- b: T - The second value to compare.
- others: [Array](./core_package_structs.md#struct-arrayt)\<T> - Other values to compare.

Returns:

- T - The minimum value among the parameters.

Example:

<!-- verify -->
```cangjie
class Rectangle <: Comparable<Rectangle> & ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }
    public prop area: Int64 {
        get() {
            return this.width * this.height
        }
    }
    public func compare(t: Rectangle): Ordering {
        if (t.area > this.area) {
            return Ordering.LT
        } else if (t.area == this.area) {
            return Ordering.EQ
        } else {
            Ordering.GT
        }
    }
    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}, area: ${this.area}"
    }
}

main() {
    var r1: Rectangle = Rectangle(10, 20)
    var r2: Rectangle = Rectangle(20, 30)
    println("The smaller one is ${min(r1, r2)}")
}
```

Execution Result:

```text
The smaller one is width: 10, height: 20, area: 200
```

## func print(Bool, Bool)

```cangjie
public func print(b: Bool, flush!: Bool = false): Unit
```

Function: Outputs the string representation of a [Bool](core_package_intrinsics.md#bool) type data to the console.

> **Note:**
>
> The following functions—[print](core_package_funcs.md#func-printbool-bool), [println](core_package_funcs.md#func-println), [eprint](core_package_funcs.md#func-eprintstring-bool), and [eprintln](core_package_funcs.md#func-eprintlnstring)—default to UTF-8 encoding.

Parameters:

- b: [Bool](core_package_intrinsics.md#bool) - The [Bool](core_package_intrinsics.md#bool) type data to output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. `true` flushes, `false` does not. Default is `false`.

Example:

<!-- verify -->
```cangjie
main() {
    var flag: Bool = false
    print(flag)
    flag = true
    println()
    print(flag)
}
```

Execution Result:

```text
false
true
```

## func print(Float16, Bool)

```cangjie
public func print(f: Float16, flush!: Bool = false): Unit
```

Function: Outputs the string representation of a [Float16](core_package_intrinsics.md#float16) type data to the console, rounded to six decimal places. Decimal places beyond six will not be displayed, and fewer than six will be padded with zeros.

Parameters:

- f: [Float16](core_package_intrinsics.md#float16) - The [Float16](core_package_intrinsics.md#float16) type data to output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. `true` flushes, `false` does not. Default is `false`.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float16 = 0.76
    var num2: Float16 = 0.68
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
0.759766
0.680176
```

> **Note:**
>
> Cangjie uses the IEEE 754 format to represent floating-point numbers, which may introduce numerical errors.
>
## func print(Float32, Bool)

```cangjie
public func print(f: Float32, flush!: Bool = false): Unit
```

Function: Outputs the string representation of a [Float32](core_package_intrinsics.md#float32) type data to the console, rounded to six decimal places. Decimal places beyond six will not be displayed, and fewer than six will be padded with zeros.

Parameters:

- f: [Float32](core_package_intrinsics.md#float32) - The [Float32](core_package_intrinsics.md#float32) type data to output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. `true` flushes, `false` does not. Default is `false`.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float16 = 0.76
    var num2: Float16 = 0.68
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
0.759766
0.680176
```

## func print(Float64, Bool)

```cangjie
public func print(f: Float64, flush!: Bool = false): Unit
```

Function: Outputs the string representation of a [Float64](core_package_intrinsics.md#float64) type data to the console, rounded to six decimal places. Decimal places beyond six will not be displayed, and fewer than six will be padded with zeros.

Parameters:

- f: [Float64](core_package_intrinsics.md#float64) - The [Float64](core_package_intrinsics.md#float64) type data to output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. `true` flushes, `false` does not. Default is `false`.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float64 = 0.76453
    var num2: Float64 = 0.683456
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
0.764530
0.683456
```

## func print(Int16, Bool)

```cangjie
public func print(i: Int16, flush!: Bool = false): Unit
```

Function: Outputs the string representation of an [Int16](core_package_intrinsics.md#int16) type data to the console.

Parameters:

- i: [Int16](core_package_intrinsics.md#int16) - The [Int16](core_package_intrinsics.md#int16) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 10
    var num2: Int16 = 2222
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
10
2222
```

## func print(Int32, Bool)

```cangjie
public func print(i: Int32, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [Int32](core_package_intrinsics.md#int32) type data to the console.

Parameters:

- i: [Int32](core_package_intrinsics.md#int32) - The [Int32](core_package_intrinsics.md#int32) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int32 = 1024
    var num2: Int32 = 2048
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
1024
2048
```

## func print(Int64, Bool)

```cangjie
public func print(i: Int64, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [Int64](core_package_intrinsics.md#int64) type data to the console.

Parameters:

- i: [Int64](core_package_intrinsics.md#int64) - The [Int64](core_package_intrinsics.md#int64) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int64 = 1024
    var num2: Int64 = 2048
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
1024
2048
```

## func print(Int8, Bool)

```cangjie
public func print(i: Int8, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [Int8](core_package_intrinsics.md#int8) type data to the console.

Parameters:

- i: [Int8](core_package_intrinsics.md#int8) - The [Int8](core_package_intrinsics.md#int8) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int8 = 8
    var num2: Int8 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func print(Rune, Bool)

```cangjie
public func print(c: Rune, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) type data to the console.

Parameters:

- c: [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) - The [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var char: Rune = r'a'
    print(char)
}
```

Execution result:

```text
a
```

## func print(String, Bool)

```cangjie
public func print(str: String, flush!: Bool = false): Unit
```

Function: Outputs the specified string to the console.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var str: String = "I like Cangjie"
    print(str)
}
```

Execution result:

```text
I like Cangjie
```

<!--Del_sink-->
## func print(String, Bool)

```cangjie
public func print(str: String @local?, flush!: Bool = false): Unit
```

Function: Outputs the specified string to the console.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- str: [String](core_package_structs.md#struct-string) @local? - The string to be output; `@local!` and `@local?` arguments are supported.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    let n: Int64 @local! = 123
    let s: String @local! = n.toString()
    print(s)
    println()
}
```

Execution Result:

```text
123
```

<!--DelEnd_sink-->
## func print(UInt16, Bool)

```cangjie
public func print(i: UInt16, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [UInt16](core_package_intrinsics.md#uint16) type data to the console.

Parameters:

- i: [UInt16](core_package_intrinsics.md#uint16) - The [UInt16](core_package_intrinsics.md#uint16) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt16 = 8
    var num2: UInt16 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func print(UInt32, Bool)

```cangjie
public func print(i: UInt32, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [UInt32](core_package_intrinsics.md#uint32) type data to the console.

Parameters:

- i: [UInt32](core_package_intrinsics.md#uint32) - The [UInt32](core_package_intrinsics.md#uint32) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt16 = 8
    var num2: UInt16 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func print(UInt64, Bool)

```cangjie
public func print(i: UInt64, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [UInt64](core_package_intrinsics.md#uint64) type data to the console.

Parameters:

- i: [UInt64](core_package_intrinsics.md#uint64) - The [UInt64](core_package_intrinsics.md#uint64) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt64 = 8
    var num2: UInt64 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func print(UInt8, Bool)

```cangjie
public func print(i: UInt8, flush!: Bool = false): Unit
```

Function: Outputs the string representation of [UInt8](core_package_intrinsics.md#uint8) type data to the console.

Parameters:

- i: [UInt8](core_package_intrinsics.md#uint8) - The [UInt8](core_package_intrinsics.md#uint8) type data to be output.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer: true to flush, false to retain (default: false).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt8 = 8
    var num2: UInt8 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func print\<T>(T, Bool) where T <: ToString

```cangjie
public func print<T>(arg: T, flush!: Bool = false): Unit where T <: ToString
```

Function: Outputs the string representation of an instance of type `T` to the console.

Parameters:

- arg: T - The data to be output, supporting types that implement the [ToString](core_package_interfaces.md#interface-tostring) interface.
- flush!: [Bool](core_package_intrinsics.md#bool) - Whether to flush the buffer. true flushes, false does not (default is false).

Example:

<!-- verify -->
```cangjie
class Rectangle <: ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        width * height
    }
    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}"
    }
}

main() {
    print<Rectangle>(Rectangle(10, 20))
}
```

Execution result:

```text
width: 10, height: 20
```

## func println()

```cangjie
public func println(): Unit
```

Function: Outputs a newline character to standard output (stdout).

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt8 = 8
    var num2: UInt8 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution result:

```text
8
32
```

## func println(Bool)

```cangjie
public func println(b: Bool): Unit
```

Function: Outputs the string representation of a [Bool](core_package_intrinsics.md#bool) type data to the console, followed by a newline.

Parameter:

- b: [Bool](core_package_intrinsics.md#bool) - The [Bool](core_package_intrinsics.md#bool) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var flag1: Bool = true
    var flag2: Bool = false
    println(flag1)
    println(flag2)
}
```

Execution result:

```text
true
false
```

## func println(Float16)

```cangjie
public func println(f: Float16): Unit
```

Function: Outputs the string representation of a [Float16](core_package_intrinsics.md#float16) type data to the console, followed by a newline.

Parameter:

- f: [Float16](core_package_intrinsics.md#float16) - The [Float16](core_package_intrinsics.md#float16) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float16 = 3.1415
    var num2: Float16 = 3.141592
    println(num1)
    println(num2)
}
```

Execution result:

```text
3.140625
3.140625
```

## func println(Float32)

```cangjie
public func println(f: Float32): Unit
```

Function: Outputs the string representation of a [Float32](core_package_intrinsics.md#float32) type data to the console, followed by a newline.

Parameter:

- f: [Float32](core_package_intrinsics.md#float32) - The [Float32](core_package_intrinsics.md#float32) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float32 = 3.1415
    var num2: Float32 = 3.141592
    println(num1)
    println(num2)
}
```

Execution result:

```text
3.141500
3.141592
```

## func println(Float64)

```cangjie
public func println(f: Float64): Unit
```

Function: Outputs the string representation of a [Float64](core_package_intrinsics.md#float64) type data to the console, followed by a newline.

Parameter:

- f: [Float64](core_package_intrinsics.md#float64) - The [Float64](core_package_intrinsics.md#float64) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Float64 = 3.1415
    var num2: Float64 = 3.141592
    println(num1)
    println(num2)
}
```

Execution result:

```text
3.141500
3.141592
```

## func println(Int16)

```cangjie
public func println(i: Int16): Unit
```

Function: Outputs the string representation of an [Int16](core_package_intrinsics.md#int16) type data to the console, followed by a newline.

Parameter:

- i: [Int16](core_package_intrinsics.md#int16) - The [Int16](core_package_intrinsics.md#int16) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int16 = 8
    var num2: Int16 = 32
    println(num1)
    println(num2)
}
```

Execution result:

```text
8
32
```

## func println(Int32)

```cangjie
public func println(i: Int32): Unit
```

Function: Outputs the string representation of an [Int32](core_package_intrinsics.md#int32) type data to the console, followed by a newline.

Parameter:

- i: [Int32](core_package_intrinsics.md#int32) - The [Int32](core_package_intrinsics.md#int32) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int32 = 8
    var num2: Int32 = 32
    println(num1)
    println(num2)
}
```

Execution result:

```text
8
32
```

## func println(Int64)

```cangjie
public func println(i: Int64): Unit
```

Function: Outputs the string representation of an [Int64](core_package_intrinsics.md#int64) type data to the console, followed by a newline.

Parameter:

- i: [Int64](core_package_intrinsics.md#int64) - The [Int64](core_package_intrinsics.md#int64) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int64 = 8
    var num2: Int64 = 32
    println(num1)
    println(num2)
}
```

Execution result:

```text
8
32
```

## func println(Int8)

```cangjie
public func println(i: Int8): Unit
```

Function: Outputs the string representation of an [Int8](core_package_intrinsics.md#int8) type data to the console, followed by a newline.

Parameters:

- i: [Int8](core_package_intrinsics.md#int8) - The [Int8](core_package_intrinsics.md#int8) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: Int8 = 8
    var num2: Int8 = 32
    println(num1)
    println(num2)
}
```

Execution Result:

```text
8
32
```

## func println(Rune)

```cangjie
public func println(c: Rune): Unit
```

Function: Outputs the string representation of a [Rune](core_package_intrinsics.md#rune) type data to the console, followed by a newline.

Parameters:

- c: [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) - The [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var char1: Rune = r'a'
    var char2: Rune = r'b'
    println(char1)
    println(char2)
}
```

Execution Result:

```text
a
b
```

## func println(String)

```cangjie
public func println(str: String): Unit
```

Function: Outputs a specified string to the console, followed by a newline.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var str1: String = "I like Cangjie"
    var str2: String = "I like programming"
    println(str1)
    println(str2)
}
```

Execution Result:

```text
I like Cangjie
I like programming
```

<!--Del_sink-->
## func println(String)

```cangjie
public func println(str: String @local?): Unit
```

Function: Outputs the specified string to the console with a line break at the end.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- str: [String](core_package_structs.md#struct-string) @local? - The string to be output; `@local!` and `@local?` arguments are supported.

Example:

<!-- verify -->
```cangjie
main() {
    let n: Int64 @local! = 123
    let s: String @local! = n.toString()
    println(s)
}
```

Execution Result:

```text
123
```

<!--DelEnd_sink-->
## func println(UInt16)

```cangjie
public func println(i: UInt16): Unit
```

Function: Outputs the string representation of a [UInt16](core_package_intrinsics.md#uint16) type data to the console, followed by a newline.

Parameters:

- i: [UInt16](core_package_intrinsics.md#uint16) - The [UInt16](core_package_intrinsics.md#uint16) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt16 = 8
    var num2: UInt16 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
8
32
```

## func println(UInt32)

```cangjie
public func println(i: UInt32): Unit
```

Function: Outputs the string representation of a [UInt32](core_package_intrinsics.md#uint32) type data to the console, followed by a newline.

Parameters:

- i: [UInt32](core_package_intrinsics.md#uint32) - The [UInt32](core_package_intrinsics.md#uint32) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt32 = 8
    var num2: UInt32 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
8
32
```

## func println(UInt64)

```cangjie
public func println(i: UInt64): Unit
```

Function: Outputs the string representation of a [UInt64](core_package_intrinsics.md#uint64) type data to the console, followed by a newline.

Parameters:

- i: [UInt64](core_package_intrinsics.md#uint64) - The [UInt64](core_package_intrinsics.md#uint64) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt64 = 8
    var num2: UInt64 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
8
32
```

## func println(UInt8)

```cangjie
public func println(i: UInt8): Unit
```

Function: Outputs the string representation of a [UInt8](core_package_intrinsics.md#uint8) type data to the console, followed by a newline.

Parameters:

- i: [UInt8](core_package_intrinsics.md#uint8) - The [UInt8](core_package_intrinsics.md#uint8) type data to be output.

Example:

<!-- verify -->
```cangjie
main() {
    var num1: UInt8 = 8
    var num2: UInt8 = 32
    print(num1)
    println()
    print(num2)
}
```

Execution Result:

```text
8
32
```

## func println\<T>(T) where T <: ToString

```cangjie
public func println<T>(arg: T): Unit where T <: ToString
```

Function: Outputs the string representation of an instance of type `T` to the console, followed by a newline.

Parameters:

- arg: T - The data to be output, supporting types that implement the [ToString](core_package_interfaces.md#interface-tostring) interface.

Example:

<!-- verify -->
```cangjie
class Rectangle <: ToString {
    var width: Int64
    var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func toString(): String {
        return "width: ${this.width}, height: ${this.height}"
    }
}

main() {
    println<Rectangle>(Rectangle(10, 20))
    println<Rectangle>(Rectangle(5, 10))
}
```

Execution Result:

```text
width: 10, height: 20
width: 5, height: 10
```

## func readln()

```cangjie
public func readln(): String
```

Function: Accepts console input until encountering a newline or EOF.

Returns:

- [String](core_package_structs.md#struct-string) - The received string.

Example:

<!-- compile -->
```cangjie
main() {
    var str: String = readln() // Console input 12345 234 and enter
    println(str)
}
```

Execution Result:

```text
12345 234
```

## func refEq(Object, Object)

```cangjie
public func refEq(a: Object, b: Object): Bool
```

Function: Determines whether two [Object](core_package_classes.md#class-object) instances share the same memory address.

Parameters:

- a: [Object](core_package_classes.md#class-object) - One instance.
- b: [Object](core_package_classes.md#class-object) - The other instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the instances share the same memory address; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
main() {
    let first = Object()
    let same = first
    let other = Object()
    println(refEq(first, same))
    println(refEq(first, other))
}
```

Execution Result:

```text
true
false
```

<!--Del_sink-->
## func refEq(Object, Object)

```cangjie
public func refEq(a: Object @local?, b: Object @local?): Bool
```

Function: Determines whether two [Object](core_package_classes.md#class-object) instances share the same memory address.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- a: [Object](core_package_classes.md#class-object) @local? - An [Object](core_package_classes.md#class-object) instance.
- b: [Object](core_package_classes.md#class-object) @local? - Another [Object](core_package_classes.md#class-object) instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the two [Object](core_package_classes.md#class-object) instances share the same memory address, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    let first: Object @local! = Object() @local!
    let other: Object @local! = Object() @local!
    let view: Object @local? = first
    let same: Object @local? = first
    let otherView: Object @local? = other
    println(refEq(view, same))
    println(refEq(view, otherView))
}
```

Execution Result:

```text
true
false
```

<!--DelEnd_sink-->
## func releaseArrayRawData\<T>(CPointerHandle\<T>) where T <: CType

```cangjie
public unsafe func releaseArrayRawData<T>(handle: CPointerHandle<T>): Unit where T <: CType
```

Function: Releases the raw pointer instance obtained via [acquireArrayRawData](core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype).

Parameters:

- handle: [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype)\<T> - The pointer instance to be released.

Example:

<!-- verify -->
```cangjie
main() {
    var arr: Array<Int64> = [1, 2, 3, 4]
    var cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }

    var cptr: CPointer<Int64> = cptrHandle.pointer
    let num: Int64 = unsafe { cptr.read() }
    println("The first element of the array is ${num} ")

    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution Result:

```text
The first element of the array is 1
```

<!--Del_sink-->
## func releaseArrayRawData\<T>(CPointerHandle\<T>) where T <: CType

```cangjie
public unsafe func releaseArrayRawData<T>(handle: CPointerHandle<T> @local?): Unit where T <: CType
```

Function: Releases a raw pointer instance obtained through [acquireArrayRawData](core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- handle: [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype)\<T> @local? - The pointer instance to be released; `@local!` and `@local?` arguments are supported.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3, 4]
    let cptrHandle: CPointerHandle<Int64> @local? = unsafe { acquireArrayRawData(arr) }

    let cptr: CPointer<Int64> = cptrHandle.pointer
    let num: Int64 = unsafe { cptr.read() }
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
    println("The first element of the array is ${num}")
}
```

Execution Result:

```text
The first element of the array is 1
```

<!--DelEnd_sink-->
## func sizeOf\<T>() where T <: CType

```cangjie
public func sizeOf<T>(): UIntNative where T <: CType
```

Function: Retrieves the memory size occupied by type T.

Returns:

- [UIntNative](core_package_intrinsics.md#uintnative) - The number of bytes occupied by type T in memory.

Example:

<!-- verify -->
```cangjie
@C
struct Data {
    var a: Int64 = 0
    var b: Float32 = 0.0
}

main() {
    let sizeInt8: UIntNative = sizeOf<Int8>()
    println("The size of Int8 is ${sizeInt8} byte")

    let sizeInt32: UIntNative = sizeOf<Int32>()
    println("The size of Int32 is ${sizeInt32} bytes")

    let sizeInt64: UIntNative = sizeOf<Int64>()
    println("The size of Int64 is ${sizeInt64} bytes")

    let sizeData: UIntNative = sizeOf<Data>()
    println("The size of Rectangle is ${sizeData} bytes")
}
```

Execution Result:

```text
The size of Int8 is 1 byte
The size of Int32 is 4 bytes
The size of Int64 is 8 bytes
The size of Rectangle is 16 bytes
```

## func sleep(Duration)

```cangjie
public func sleep(dur: Duration): Unit
```

Function: Suspends the current thread.

If `dur` is less than or equal to [Duration.Zero](core_package_structs.md#static-const-zero), the current thread yields execution rights.

Parameters:

- dur: [Duration](core_package_structs.md#struct-duration) - The duration for which the thread will sleep.

Example:

<!-- verify -->
```cangjie
import std.sync.*
import std.time.*

main(): Int64 {
    spawn {
        =>
        println("New thread starts")
        println("New thread ends")
    }

    println("Main thread")
    println("The main thread starts to sleep.")

    /* dur == 1 second */
    sleep(1000 * Duration.millisecond)
    println("The main thread ends sleep.")

    return 0
}
```

After launching the main thread, when execution reaches the sleep function, the main thread yields system execution rights and sleeps for 1 second before reawakening to compete for system execution rights and continue executing remaining logic. During the main thread's sleep period, the custom thread acquires execution rights and begins execution. Execution Result:

```text
Main thread
The main thread starts to sleep.
New thread starts
New thread ends
The main thread ends sleep.
```

## func zeroValue\<T>()

```cangjie
public unsafe func zeroValue<T>(): T
```

Function: Retrieves a zero-initialized instance of type T.

> **Note:**
>
> The instance obtained through this function must be assigned a properly initialized value before use; otherwise, it will cause program crashes.

Returns:

- T - A zero-initialized instance of type T.

Example:

<!-- verify -->

```cangjie
main(): Int64 {
    var m = MyClass<Student>()
    m.set(1, Student())
    var s = m.get(1)
    println(s)
    s = m.get(2)
    // Uncommenting the code below will cause runtime errors since it's not a Student object
    // println(s)
    return 0
}

class MyClass<T> {
    var myData: Array<T>
    public init() {
        // Initialize Array with zeroValue<T>()
        myData = Array<T>(10, repeat: unsafe { zeroValue<T>() })
    }
    public func get(index: Int64): T {
        myData[index]
    }
    public func set(index: Int64, element: T): Unit {
        myData[index] = element
    }
}

class Student <: ToString {
    public func toString() {
        "student"
    }
}
```

Example Result:

```text
student
```

<!--Del_sink-->
## func zeroValue2\<T>()

```cangjie
public unsafe func zeroValue2<T>(): T @local!
```

Function: Retrieves a zero-initialized instance of type T.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.
> - This function only provides a placeholder value for storage that has not been initialized yet. An all-zero byte sequence does not guarantee the invariants of type T, so the value must not be treated as a valid default value of T. The placeholder must not be read, dereferenced, or used to call any member; it must be overwritten with a properly initialized value before use.
> - The placeholder holds no resources that need to be released, so do not release or clean up the placeholder value.

Returns:

- T @local! - A zero-initialized instance of type T, usable only as a placeholder for uninitialized storage.

Example:

<!-- verify -->
```cangjie
main() {
    var value: Int64 @local! = unsafe { zeroValue2<Int64>() }
    // The placeholder cannot be read directly; overwrite it with a properly initialized value first
    value = 42
    let text: String @local! = value.toString()
    println(text)
}
```

Output:

```text
42
```

<!--DelEnd_sink-->
