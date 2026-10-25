# 异常类

## class ArithmeticException

```cangjie
public open class ArithmeticException <: Exception {
    public init()
    public init(message: String)
}
```

功能：算术异常类，发生算术异常时使用。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ArithmeticException](core_package_exceptions.md#class-arithmeticexception) 实例，默认异常信息为空。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用默认构造函数创建ArithmeticException
    let exception = ArithmeticException()

    println("成功创建了ArithmeticException实例")
    println("ArithmeticException的init()构造函数用于创建一个默认的算术异常实例")
}
```

运行结果：

```text
成功创建了ArithmeticException实例
ArithmeticException的init()构造函数用于创建一个默认的算术异常实例
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [ArithmeticException](core_package_exceptions.md#class-arithmeticexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用带消息的构造函数创建ArithmeticException
    let exception = ArithmeticException("除零错误")

    println("成功创建了ArithmeticException实例")
    println("异常信息: 除零错误")
    println("ArithmeticException的init(String)构造函数用于根据异常信息创建算术异常实例")
}
```

运行结果：

```text
成功创建了ArithmeticException实例
异常信息: 除零错误
ArithmeticException的init(String)构造函数用于根据异常信息创建算术异常实例
```

## class Exception

<!--RP1-->
```cangjie
public open class Exception <: ToString {
    public init()
    public init(message: String)
    public init(message: String, causedBy: Exception)
    public init(causedBy: Exception)
}
```
<!--RP1End-->

功能：[Exception](core_package_exceptions.md#class-exception) 是所有异常类的父类。

支持构造一个异常类，设置、获取异常信息，转换为字符串，获取、打印堆栈，设置异常名（用于字符串表示）。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

<!--Del-->
### prop causedBy

```cangjie
public mut prop causedBy: ?Exception
```

功能：异常的触发原因。

类型：?[Exception](core_package_exceptions.md#class-exception)

> **注意：**
>
> 不支持平台：OpenHarmony

示例：

<!-- verify -->
```cangjie
main() {
    try {
        throwException()
    } catch (e: Exception) {
        println(e)
        if (let Some(cause) <- e.causedBy) {
            println(cause)
        }
    }
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        let exception = Exception("这是一个异常")
        exception.causedBy = e
        throw exception
    }
}

func throwCause() {
    throw Exception("这是一个cause")
}
```

运行结果：

```text
Exception: 这是一个异常
Exception: 这是一个cause
```

> **注意：**
>
> 不支持平台：OpenHarmony
<!--DelEnd-->
### prop message

```cangjie
public open prop message: String
```

功能：获取异常信息。

类型：[String](core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Exception实例并访问message属性
    let exception = Exception("这是一个异常信息")
    println("异常信息: " + exception.message)

    // 使用默认构造函数创建Exception实例
    let defaultException = Exception()
    println("默认异常信息: '" + defaultException.message + "'")
}
```

运行结果：

```text
异常信息: 这是一个异常信息
默认异常信息: ''
```

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Exception](core_package_exceptions.md#class-exception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建Exception实例
    let exception = Exception()
}
```

<!--Del-->
### init(Exception)

```cangjie
public init(causedBy: Exception)
```

功能：根据触发原因构造一个 [Exception](core_package_exceptions.md#class-exception) 实例，异常信息为空。

> **注意：**
>
> 不支持平台：OpenHarmony

参数：

- causedBy: [Exception](core_package_exceptions.md#class-exception) - 触发原因。

示例：

<!-- verify -->
```cangjie
main() {
    try {
        throwException()
    } catch (e: Exception) {
        println(e)
        if (let Some(cause) <- e.causedBy) {
            println(cause)
        }
    }
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        throw Exception(e)
    }
}

func throwCause() {
    throw Exception("这是一个cause")
}
```

运行结果：

```text
Exception
Exception: 这是一个cause
```

> **注意：**
>
> 不支持平台：OpenHarmony
<!--DelEnd-->
### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [Exception](core_package_exceptions.md#class-exception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建Exception实例
    let exception = Exception("自定义异常信息")
}
```

<!--Del-->
### init(String, Exception)

```cangjie
public init(message: String, causedBy: Exception)
```

功能：根据异常信息和触发原因构造一个 [Exception](core_package_exceptions.md#class-exception) 实例。

> **注意：**
>
> 不支持平台：OpenHarmony

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。
- causedBy: [Exception](core_package_exceptions.md#class-exception) - 触发原因。

示例：

<!-- run -->
```cangjie
main(): Unit {
    try {
        throwException()
    } catch (e: Exception) {
        throw Exception("这是被抛出的异常", e)
    }

    ()
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        throw Exception("这是一个异常", e)
    }
}

func throwCause() {
    throw Exception("这是一个cause")
}
```

可能的运行结果：

```text
An exception has occurred:
Exception: 这是被抛出的异常
	 at default::main()(/tmp/test-exception-chain.cj:5)
Caused by: Exception: 这是一个异常
	 at default::throwException()(/tmp/test-exception-chain.cj:15)
	 at default::main()(/tmp/test-exception-chain.cj:3)
Caused by: Exception: 这是一个cause
	 at default::throwCause()(/tmp/test-exception-chain.cj:20)
	 at default::throwException()(/tmp/test-exception-chain.cj:13)
	 ... 1 more
```

> **注意：**
>
> 不支持平台：OpenHarmony
<!--DelEnd-->
### func getStackTrace()

```cangjie
public func getStackTrace(): Array<StackTraceElement>
```

功能：获取堆栈信息，每一条堆栈信息用一个 [StackTraceElement](core_package_classes.md#class-stacktraceelement) 实例表示，最终返回一个 [StackTraceElement](core_package_classes.md#class-stacktraceelement) 的数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[StackTraceElement](core_package_classes.md#class-stacktraceelement)> - 堆栈信息数组。

示例：

<!-- verify -->
```cangjie
main() {
    try {
        // 创建一个异常并抛出
        throw Exception("测试异常")
    } catch (e: Exception) {
        // 获取堆栈信息
        let stackTrace = e.getStackTrace()
        println("堆栈跟踪元素数量: ${stackTrace.size}")
        // 打印第一个堆栈元素（如果存在）
        if (stackTrace.size > 0) {
            let element = stackTrace[0]
            println("第一个堆栈元素的类名: ${element.declaringClass}")
            println("第一个堆栈元素的方法名: ${element.methodName}")
        }
    }
}
```

运行结果：

```text
堆栈跟踪元素数量: 1
第一个堆栈元素的类名: default
第一个堆栈元素的方法名: main()
```

### func printStackTrace()

```cangjie
public func printStackTrace(): Unit
```

功能：向控制台打印堆栈信息。

示例：

<!-- run -->
```cangjie
main() {
    try {
        // 创建一个异常并抛出
        throw Exception("测试异常")
    } catch (e: Exception) {
        // 打印堆栈信息到控制台
        println("打印异常堆栈信息:")
        e.printStackTrace()
    }
}
```

可能的运行结果：

```text
打印异常堆栈信息:
An exception has occurred:
Exception: 测试异常
	 at default.main()(/path/path/temp_printStackTrace_example.cj:4)
```

### func toString()

```cangjie
public open func toString(): String
```

功能：获取当前 [Exception](core_package_exceptions.md#class-exception) 实例的字符串值，包括类名和异常信息。

返回值：

- [String](core_package_structs.md#struct-string) - 异常字符串。
示例：

<!-- verify -->
```cangjie
main() {
    // 创建Exception实例
    let exception1 = Exception()
    let exception2 = Exception("自定义异常信息")

    // 使用toString()方法获取异常的字符串表示
    println("默认异常的字符串表示: " + exception1.toString())
    println("带消息异常的字符串表示: " + exception2.toString())
}
```

运行结果：

```text
默认异常的字符串表示: Exception
带消息异常的字符串表示: Exception: 自定义异常信息
```

<!--Del-->
## class ExclusiveScopeException

```cangjie
public class ExclusiveScopeException <: Exception {}
```

功能：自定义异常类，用于包装在独占作用域中抛出的异常。它保留了原始异常的堆栈信息，不支持主动构造该异常，但是可以被捕获到。

父类型：

- [Exception](#class-exception)

### func toString()

```cangjie
public override func toString(): String
```

功能：获得类名。

返回值：

- [String](core_package_structs.md#struct-string) - 类名。

示例：

<!-- code_no_check -->
```cangjie
// 此示例只做展示，假设抛出 ExclusiveScopeException
main() {
    try {
    // 假设出现内存错误
    } catch (e: ExclusiveScopeException) {
        println(e.message)
    }
}
```

<!--DelEnd-->
## class IllegalArgumentException

```cangjie
public open class IllegalArgumentException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示参数非法的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IllegalArgumentException实例
    let exception = IllegalArgumentException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IllegalArgumentException实例
    let exception = IllegalArgumentException("自定义异常信息")
}
```

## class IllegalFormatException

```cangjie
public open class IllegalFormatException <: IllegalArgumentException {
    public init()
    public init(message: String)
}
```

功能：表示变量的格式无效或不标准时的异常类。

父类型：

- [IllegalArgumentException](#class-illegalargumentexception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IllegalFormatException](core_package_exceptions.md#class-illegalformatexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IllegalFormatException实例
    let exception = IllegalFormatException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [IllegalFormatException](core_package_exceptions.md#class-illegalformatexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IllegalFormatException实例
    let exception = IllegalFormatException("自定义异常信息")
}
```

## class IllegalMemoryException

```cangjie
public class IllegalMemoryException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示内存操作错误的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IllegalMemoryException实例
    let exception = IllegalMemoryException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据指定异常信息构造 [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IllegalMemoryException实例
    let exception = IllegalMemoryException("自定义异常信息")
}
```

## class IllegalStateException

```cangjie
public class IllegalStateException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示状态非法的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IllegalStateException](core_package_exceptions.md#class-illegalstateexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IllegalStateException实例
    let exception = IllegalStateException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [IllegalStateException](core_package_exceptions.md#class-illegalstateexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IllegalStateException实例
    let exception = IllegalStateException("自定义异常信息")
}
```

## class IncompatiblePackageException

```cangjie
public class IncompatiblePackageException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示包不兼容的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IncompatiblePackageException](core_package_exceptions.md#class-incompatiblepackageexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IncompatiblePackageException实例
    let exception = IncompatiblePackageException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [IncompatiblePackageException](core_package_exceptions.md#class-incompatiblepackageexception)实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IncompatiblePackageException实例
    let exception = IncompatiblePackageException("自定义异常信息")
}
```

## class IndexOutOfBoundsException

```cangjie
public class IndexOutOfBoundsException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示索引越界的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建IndexOutOfBoundsException实例
    let exception = IndexOutOfBoundsException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建IndexOutOfBoundsException实例
    let exception = IndexOutOfBoundsException("自定义异常信息")
}
```

## class NegativeArraySizeException

```cangjie
public class NegativeArraySizeException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示数组大小为负数的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建NegativeArraySizeException实例
    let exception = NegativeArraySizeException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建NegativeArraySizeException实例
    let exception = NegativeArraySizeException("自定义异常信息")
}
```

## class NoneValueException

```cangjie
public class NoneValueException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示 [Option](core_package_enums.md#enum-optiont)\<T> 实例的值为 `None` 的异常类，通常在 `getOrThrow` 函数中被抛出。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [NoneValueException](core_package_exceptions.md#class-nonevalueexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建NoneValueException实例
    let exception = NoneValueException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [NoneValueException](core_package_exceptions.md#class-nonevalueexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建NoneValueException实例
    let exception = NoneValueException("自定义异常信息")
}
```

## class OverflowException

```cangjie
public class OverflowException <: ArithmeticException {
    public init()
    public init(message: String)
}
```

功能：表示算术运算溢出的异常类。

父类型：

- [ArithmeticException](#class-arithmeticexception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [OverflowException](core_package_exceptions.md#class-overflowexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建OverflowException实例
    let exception = OverflowException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据指定异常信息构造 [OverflowException](core_package_exceptions.md#class-overflowexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建OverflowException实例
    let exception = OverflowException("自定义异常信息")
}
```

## class SpawnException

```cangjie
public class SpawnException <: Exception {
    public init()
    public init(message: String)
}
```

功能：线程异常类，表示线程处理过程中发生异常。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [SpawnException](core_package_exceptions.md#class-spawnexception) 实例，默认错误信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建SpawnException实例
    let exception = SpawnException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造一个 [SpawnException](core_package_exceptions.md#class-spawnexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建SpawnException实例
    let exception = SpawnException("自定义异常信息")
}
```

## class TimeoutException

```cangjie
public class TimeoutException <: Exception {
    public init()
    public init(message: String)
}
```

功能：当阻塞操作超时时引发异常。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TimeoutException](core_package_exceptions.md#class-timeoutexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建TimeoutException实例
    let exception = TimeoutException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据指定异常信息构造 [TimeoutException](core_package_exceptions.md#class-timeoutexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建TimeoutException实例
    let exception = TimeoutException("自定义异常信息")
}
```

<!--Del_sink-->
## class UnimplementedException

```cangjie
public class UnimplementedException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示当前类型尚未提供部分接口所需的 `@local!` 或 `@local?` 适配实现的异常。

[ToString](core_package_interfaces.md#interface-tostring)、[Hashable](core_package_interfaces.md#interface-hashable) 等接口在类型未提供对应的 local 实现时，其默认实现抛出该异常。[Iterable](core_package_interfaces.md#interface-iterablee) 和 [Iterator](core_package_classes.md#class-iteratort) 的 local 默认实现则抛出 [IllegalStateException](#class-illegalstateexception)。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [UnimplementedException](core_package_exceptions.md#class-unimplementedexception) 实例，默认异常信息为 "UnimplementedException"。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用默认构造函数创建UnimplementedException实例
    let exception = UnimplementedException()
    println("created: ${exception.message}")
}
```

运行结果：

```text
created: UnimplementedException
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据指定异常信息构造 [UnimplementedException](core_package_exceptions.md#class-unimplementedexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- verify -->
```cangjie
main() {
    try {
        throw UnimplementedException("test message")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
caught: test message
```

### func getClassName()

```cangjie
protected override func getClassName(): String
```

功能：获得类名。

该函数为 `protected` 成员，仅可在类内部或其子类中访问；外部代码需要展示异常信息时，可使用公开的 `toString` 函数。

返回值：

- [String](core_package_structs.md#struct-string) - 类名 "UnimplementedException"。

示例：

<!-- verify -->
```cangjie
main() {
    try {
        throw UnimplementedException("test message")
    } catch (e: UnimplementedException) {
        // 使用公开的 toString 获取包含类名的异常信息
        println(e.toString())
    }
}
```

运行结果：

```text
UnimplementedException: test message
```

<!--DelEnd_sink-->
## class UnsupportedException

```cangjie
public class UnsupportedException <: Exception {
    public init()
    public init(message: String)
}
```

功能：表示功能未支持的异常类。

父类型：

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [UnsupportedException](core_package_exceptions.md#class-unsupportedexception) 实例，默认异常信息为空。

示例：

<!-- run -->
```cangjie
main() {
    // 使用默认构造函数创建UnsupportedException实例
    let exception = UnsupportedException()
}
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据指定异常信息构造 [UnsupportedException](core_package_exceptions.md#class-unsupportedexception) 实例。

参数：

- message: [String](core_package_structs.md#struct-string) - 异常提示信息。

示例：

<!-- run -->
```cangjie
main() {
    // 使用带消息的构造函数创建UnsupportedException实例
    let exception = UnsupportedException("自定义异常信息")
}
```

## class Error

```cangjie
public open class Error <: ToString {}
```

功能：[Error](core_package_exceptions.md#class-error) 是所有错误类的基类。该类不可被继承，不可初始化，但是可以被捕获到。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

### prop message

```cangjie
public open prop message: String
```

功能：获取错误信息。

类型：[String](core_package_structs.md#struct-string)

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设抛出 Error
main() {
    try {
    // 假设出现内存错误或栈溢出错误
    } catch (e: Error) {
        println(e.message)
    }
}
```

### func getStackTrace()

```cangjie
public func getStackTrace(): Array<StackTraceElement>
```

功能：获取堆栈信息，每一条堆栈信息用一个 [StackTraceElement](core_package_classes.md#class-stacktraceelement) 实例表示，最终返回一个 [StackTraceElement](core_package_classes.md#class-stacktraceelement) 的数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[StackTraceElement](core_package_classes.md#class-stacktraceelement)> - 堆栈信息数组。

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设内部抛出 Error
main() {
    try {
    // 假设出现内存错误，栈溢出错误，或者内部错误
    } catch (e: Error) {
        println(e.getStackTrace()[0].methodName)
    }
}
```

### func getStackTraceMessage()

```cangjie
public open func getStackTraceMessage(): String
```

功能：获取堆栈信息。

返回值：

- [String](core_package_structs.md#struct-string) - 堆栈信息。

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设内部抛出 Error
main() {
    try {
    // 假设出现内存错误，栈溢出错误，或者内部错误
    } catch (e: Error) {
        println(e.getStackTraceMessage())
    }
}
```

### func printStackTrace()

```cangjie
public open func printStackTrace(): Unit
```

功能：向控制台打印堆栈信息。

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设内部抛出 Error
main() {
    try {
    // 假设出现内存错误，栈溢出错误，或者内部错误
    } catch (e: Error) {
        println(e.printStackTrace())
    }
}
```

### func toString()

```cangjie
public open func toString(): String
```

功能：获取当前 [Error](core_package_exceptions.md#class-error) 实例的字符串值，包括类名和错误信息。

返回值：

- [String](core_package_structs.md#struct-string) - 错误信息字符串。

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设内部抛出 Error
main() {
    try {
    // 假设出现内存错误，栈溢出错误，或者内部错误
    } catch (e: Error) {
        println(e)
    }
}
```

<!--Del_sink-->
## class LocalRegionOutOfMemoryError

```cangjie
public class LocalRegionOutOfMemoryError <: Error {}
```

功能：表示 local region 内存分配失败的错误。当运行时在 local region 中为对象分配内存失败时，抛出该错误。

局部对象的内存使用量不计入 `getAllocatedHeapSize` 的统计结果。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

父类型：

- [Error](#class-error)

示例：

<!-- verify -->
```cangjie
func allocateAndPrint() {
    // 在 local region 中分配小容量数组，正常情况下分配成功
    let arr: Array<Int64> @local! = [1, 2, 3]
    println("allocated: ${arr.size}")
}

main() {
    try {
        allocateAndPrint()
    } catch (e: LocalRegionOutOfMemoryError) {
        // local region 内存分配失败时抛出该错误
        println("local region out of memory")
    }
}
```

运行结果：

```text
allocated: 3
```

<!--DelEnd_sink-->

## class OutOfMemoryError

```cangjie
public class OutOfMemoryError <: Error {}
```

功能：表示内存不足错误的错误类，该类不可被继承，不可初始化，但是可以被捕获到。

父类型：

- [Error](#class-error)

<!-- associated_example -->

## class StackOverflowError

```cangjie
public class StackOverflowError <: Error {}
```

功能：表示堆栈溢出错误的错误类，该类不可被继承，不可初始化，但是可以被捕获到。

父类型：

- [Error](#class-error)

### func printStackTrace()

```cangjie
public override func printStackTrace(): Unit
```

功能：向控制台打印堆栈信息。

示例：

<!-- compile -->
```cangjie
// 此示例只做展示，假设抛出 StackOverflowError
main() {
    try {
    // 假设出现栈溢出错误
    } catch (e: StackOverflowError) {
        println(e.printStackTrace())
    }
}
```
