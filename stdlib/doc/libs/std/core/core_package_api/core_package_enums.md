# 枚举

## enum AnnotationKind

```cangjie
public enum AnnotationKind {
    | Type
    | Parameter
    | Init
    | MemberProperty
    | MemberFunction
    | MemberVariable
    | EnumConstructor
    | GlobalFunction
    | GlobalVariable
    | Extension
    | ...
}
```

功能：表示自定义注解希望支持的位置。

### EnumConstructor

```cangjie
EnumConstructor
```

功能：枚举构造器声明。

### Extension

```cangjie
Extension
```

功能：扩展声明。

### GlobalFunction

```cangjie
GlobalFunction
```

功能：全局函数声明。

### GlobalVariable

```cangjie
GlobalVariable
```

功能：全局变量声明。

### Init

```cangjie
Init
```

功能：构造函数声明。

### MemberFunction

```cangjie
MemberFunction
```

功能：成员函数声明。

### MemberProperty

```cangjie
MemberProperty
```

功能：成员属性声明。

### MemberVariable

```cangjie
MemberVariable
```

功能：成员变量声明。

### Parameter

```cangjie
Parameter
```

功能：成员函数/构造函数中的参数（不包括枚举构造器的参数）。

### Type

```cangjie
Type
```

功能：类型声明（class、struct、enum、interface）。

## enum Endian

```cangjie
public enum Endian {
    | Big
    | Little
}
```

功能：枚举类型 [Endian](core_package_enums.md#enum-endian) 表示运行平台的端序，分为大端序和小端序。

### Big

```cangjie
Big
```

功能：表示大端序。

### Little

```cangjie
Little
```

功能：表示小端序。

### static prop Platform

```cangjie
public static prop Platform: Endian
```

功能：获取所在运行平台的端序。

类型：[Endian](core_package_enums.md#enum-endian)

异常：

- [UnsupportedException](core_package_exceptions.md#class-unsupportedexception) - 当所运行平台返回的端序无法识别时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let e = Endian.Platform
    match (e) {
        case Big => println("BigEndian")
        case Little => println("LittleEndian")
    }
}
```

运行结果：

```text
LittleEndian
```

## enum Option\<T>

```cangjie
public enum Option<T> {
    | Some(T)
    | None
}
```

功能：[Option](core_package_enums.md#enum-optiont)\<T> 是对 `T` 类型的封装，表示可能有值也可能无值。

它包含两个构造器：[Some](#somet) 和 [None](#none)。其中，[Some](#somet) 会携带一个参数，表示有值；[None](#none) 不带参数，表示无值。当需要表示某个类型可能有值，也可能没有值的时候，可选择使用 [Option](core_package_enums.md#enum-optiont) 类型。

[Option](core_package_enums.md#enum-optiont) 类型的另一种写法是在类型名前加 `?`，即对于任意类型 `Type`，`?Type` 等价于 [Option](core_package_enums.md#enum-optiont)\<Type>。

### None

```cangjie
None
```

功能：构造一个不带参数的 [Option](core_package_enums.md#enum-optiont)\<T> 实例，表示无值。

### Some(T)

```cangjie
Some(T)
```

功能：构造一个携带参数的 [Option](core_package_enums.md#enum-optiont)\<T> 实例，表示有值。

### func filter((T)->Bool)

```cangjie
public func filter(predicate: (T) -> Bool): Option<T>
```

功能：提供 [Option](core_package_enums.md#enum-optiont) 类型的“过滤”功能。

参数：

- predicate: (T) -> [Bool](core_package_intrinsics.md#bool) - 过滤函数。

返回值：

- Option\<T> - 如果 [Option](core_package_enums.md#enum-optiont) 值是 [Some](#somet)(v)，并且 v 满足 `predicate(v) = true` 时，返回 [Some](#somet)(v)， 否则返回 [None](#none)。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(5)

    // 使用filter过滤大于3的值
    var filtered1 = someValue.filter({x => x > 3})
    println("过滤大于3的值: ${filtered1}")

    // 使用filter过滤小于3的值
    var filtered2 = someValue.filter({x => x < 3})
    println("过滤小于3的值: ${filtered2}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 对None值使用filter
    var filtered3 = noneValue.filter({x => x > 3})
    println("对None值过滤: ${filtered3}")
}
```

运行结果：

```text
过滤大于3的值: Some(5)
过滤小于3的值: None
对None值过滤: None
```

### func flatMap\<R>((T) -> Option\<R>)

```cangjie
public func flatMap<R>(transform: (T) -> Option<R>): Option<R>
```

功能：提供从 [Option](core_package_enums.md#enum-optiont)\<T> 类型到 [Option](core_package_enums.md#enum-optiont)\<R> 类型的映射函数，如果当前实例值是 [Some](#somet)，执行 transform 函数，并且返回结果，否则返回 [None](#none)。

参数：

- transform: (T) -> [Option](core_package_enums.md#enum-optiont)\<R> - 映射函数。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<R> - 如果当前实例值是 [Some](#somet)，执行 transform 函数并返回，否则返回 [None](#none)。

示例：

<!-- verify -->
```cangjie
// 定义一个函数，将Int64转换为Option<String>
func intToStringOption(x: Int64): Option<String> {
    if (x > 0) {
        return Some("Positive: ${x}")
    } else {
        return None
    }
}

main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(5)

    // 使用flatMap将Int64转换为String
    var flatMapped1 = someValue.flatMap(intToStringOption)
    println("对Some值使用flatMap: ${flatMapped1}")

    // 创建一个负数的Some值
    var someNegativeValue: Option<Int64> = Some(-3)

    // 使用flatMap处理负数
    var flatMapped2 = someNegativeValue.flatMap(intToStringOption)
    println("对负数Some值使用flatMap: ${flatMapped2}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 对None值使用flatMap
    var flatMapped3 = noneValue.flatMap(intToStringOption)
    println("对None值使用flatMap: ${flatMapped3}")
}
```

运行结果：

```text
对Some值使用flatMap: Some(Positive: 5)
对负数Some值使用flatMap: None
对None值使用flatMap: None
```

### func getOrDefault(() -> T)

```cangjie
public func getOrDefault(other: () -> T): T
```

功能：获得值或返回默认值。如果 [Option](core_package_enums.md#enum-optiont) 值是 [Some](#somet)，则返回类型为 `T` 的实例，如果 [Option](core_package_enums.md#enum-optiont) 值是 [None](#none)，则调用入参，返回类型 `T` 的值。

参数：

- other: () -> T - 默认函数，如果当前实例的值是 [None](#none)，调用该函数得到类型为 `T` 的实例，并将其返回。

返回值：

- T - 如果当前实例的值是 [Some](#somet)\<T>，则返回当前实例携带的类型为 `T` 的实例，如果 [Option](core_package_enums.md#enum-optiont) 值是 [None](#none)，调用入参指定的函数，得到类型为 `T` 的实例，并将其返回。

示例：

<!-- verify -->
```cangjie
main() {
    var value1: Option<Int64> = Some(2)
    println(value1.getOrDefault({=> 0}))

    var value2: Option<Int64> = None
    println(value2.getOrDefault({=> 0}))
}
```

运行结果：

```text
2
0
```

### func getOrThrow(() -> Exception)

```cangjie
public func getOrThrow(exception: ()->Exception): T
```

功能：获得值或抛出指定异常。

参数：

- exception: () ->[Exception](core_package_exceptions.md#class-exception) - 异常函数，如果当前实例值是 [None](#none)，将执行该函数并将其返回值作为异常抛出。

返回值：

- T - 如果当前实例值是 [Some](#somet)\<T>，返回类型为 `T` 的实例。

异常：

- [Exception](core_package_exceptions.md#class-exception) - 如果当前实例是 [None](#none)，抛出异常函数返回的异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(42)

    // 对Some值使用getOrThrow，应该返回值
    var value1 = someValue.getOrThrow({=> Exception("Value is None")})
    println("从Some值获取的值: ${value1}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 对None值使用getOrThrow，应该抛出异常
    try {
        noneValue.getOrThrow({=> Exception("Value is None")})
        println("这行不会被执行")
    } catch (e: Exception) {
        println("捕获到异常: ${e.message}")
    }
}
```

运行结果：

```text
从Some值获取的值: 42
捕获到异常: Value is None
```

<!--Del_sink-->
### func getOrThrow(() -> Exception)

```cangjie
public exclave func getOrThrow(this @local!, exception: () -> Exception): T @local!
```

功能：获得值或抛出指定异常。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。
- exception: () ->[Exception](core_package_exceptions.md#class-exception) - 异常函数，如果当前实例值是 [None](#none)，将执行该函数并将其返回值作为异常抛出。

返回值：

- T @local! - 如果当前实例值是 [Some](#somet)\<T>，返回类型为 `T` 的实例。

异常：

- [Exception](core_package_exceptions.md#class-exception) - 如果当前实例是 [None](#none)，抛出异常函数返回的异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3]
    let o: Option<Int64> @local! = arr.first
    let v: Int64 @local! = o.getOrThrow({=> IllegalArgumentException("empty option")})
    println("v=${v}")
    let empty: Array<Int64> @local! = []
    let n: Option<Int64> @local! = empty.first
    try {
        n.getOrThrow({=> IllegalArgumentException("empty option")})
        println("no exception")
    } catch (e: IllegalArgumentException) {
        println("caught: ${e.message}")
    }
}
```

运行结果：

```text
v=1
caught: empty option
```

<!--DelEnd_sink-->
### func getOrThrow()

```cangjie
public func getOrThrow(): T
```

功能：获得值或抛出异常。

返回值：

- T - 如果当前实例值是 [Some](#somet)\<T>，返回类型为 `T` 的实例。

异常：

- [NoneValueException](core_package_exceptions.md#class-nonevalueexception) - 如果当前实例是 [None](#none)，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(42)

    // 对Some值使用getOrThrow，应该返回值
    var value1 = someValue.getOrThrow()
    println("从Some值获取的值: ${value1}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 对None值使用getOrThrow，应该抛出NoneValueException
    try {
        noneValue.getOrThrow()
        println("这行不会被执行")
    } catch (e: NoneValueException) {
        println("捕获到NoneValueException异常")
    }
}
```

运行结果：

```text
从Some值获取的值: 42
捕获到NoneValueException异常
```

<!--Del_sink-->
### func getOrThrow()

```cangjie
public exclave func getOrThrow(this @local!): T @local!
```

功能：获得值或抛出异常。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

返回值：

- T @local! - 如果当前实例值是 [Some](#somet)\<T>，返回类型为 `T` 的实例。

异常：

- [NoneValueException](core_package_exceptions.md#class-nonevalueexception) - 如果当前实例是 [None](#none)，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local! = [1, 2, 3]
    let o: Option<Int64> @local! = arr.first
    let v: Int64 @local! = o.getOrThrow()
    println("v=${v}")
    let empty: Array<Int64> @local! = []
    let n: Option<Int64> @local! = empty.first
    try {
        n.getOrThrow()
        println("no exception")
    } catch (e: NoneValueException) {
        println("caught NoneValueException")
    }
}
```

运行结果：

```text
v=1
caught NoneValueException
```

<!--DelEnd_sink-->
### func isNone()

```cangjie
public func isNone(): Bool
```

功能：判断当前实例值是否为 [None](#none)。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果当前实例值是 [None](#none)，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(42)

    // 检查是否为None
    println("Some(42) is None: ${someValue.isNone()}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 检查是否为None
    println("None is None: ${noneValue.isNone()}")
}
```

运行结果：

```text
Some(42) is None: false
None is None: true
```

<!--Del_sink-->
### func isNone()

```cangjie
public func isNone(this @local?): Bool
```

功能：判断当前实例值是否为 [None](#none)。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果当前实例值是 [None](#none)，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [5, 6, 7]
    let o: Option<Int64> @local? = arr.first
    println("o isNone: ${o.isNone()}")
    let empty: Array<Int64> @local? = []
    let n: Option<Int64> @local? = empty.first
    println("n isNone: ${n.isNone()}")
}
```

运行结果：

```text
o isNone: false
n isNone: true
```

<!--DelEnd_sink-->
### func isSome()

```cangjie
public func isSome(): Bool
```

功能：判断当前实例值是否为 [Some](#somet)。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果当前实例值是 [Some](#somet)，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(42)

    // 检查是否为Some
    println("Some(42) is Some: ${someValue.isSome()}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 检查是否为Some
    println("None is Some: ${noneValue.isSome()}")
}
```

运行结果：

```text
Some(42) is Some: true
None is Some: false
```

<!--Del_sink-->
### func isSome()

```cangjie
public func isSome(this @local?): Bool
```

功能：判断当前实例值是否为 [Some](#somet)。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果当前实例值是 [Some](#somet)，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [5, 6, 7]
    let o: Option<Int64> @local? = arr.first
    println("o isSome: ${o.isSome()}")
    let empty: Array<Int64> @local? = []
    let n: Option<Int64> @local? = empty.first
    println("n isSome: ${n.isSome()}")
}
```

运行结果：

```text
o isSome: true
n isSome: false
```

<!--DelEnd_sink-->
### func map\<R>((T)->R)

```cangjie
public func map<R>(transform: (T)-> R): Option<R>
```

功能：提供从 [Option](#enum-optiont)\<T> 类型到 [Option](#enum-optiont)\<R> 类型的映射函数，如果当前实例值是 [Some](#somet)，执行 transform 函数，并且返回 [Some](#somet) 封装的结果，否则返回 [None](#none)。

参数：

- transform: (T)-> R - 映射函数。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<R> - 如果当前实例值是 [Some](#somet)，执行 transform 函数，并且返回 [Option](#enum-optiont)\<R> 类型的结果，否则返回 [None](#none)。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Some值
    var someValue: Option<Int64> = Some(42)

    // 使用map将Int64转换为String
    var mapped1 = someValue.map({x => "Number: ${x}"})
    println("对Some值使用map: ${mapped1}")

    // 创建一个None值
    var noneValue: Option<Int64> = None

    // 对None值使用map
    var mapped2 = noneValue.map({x => "Number: ${x}"})
    println("对None值使用map: ${mapped2}")
}
```

运行结果：

```text
对Some值使用map: Some(Number: 42)
对None值使用map: None
```

### extend\<T> Option\<Option\<T>>

```cangjie
extend<T> Option<Option<T>>
```

功能：为 Option\<Option\<T>> 类型扩展实现某些功能。

#### func flatten()

```cangjie
public func flatten(): Option<T>
```

功能：将 [Option](core_package_enums.md#enum-optiont)\<[Option](core_package_enums.md#enum-optiont)\<T>> 类型展开，如果当前实例是 [Some](#somet)([Option](core_package_enums.md#enum-optiont)\<T>.[Some](#somet)(v)), 展开后的结果为 [Some](#somet)(v)。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<T> - [Option](core_package_enums.md#enum-optiont)\<[Option](core_package_enums.md#enum-optiont)\<T>> 类型展开后的结果。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Option<Option<Int64>>类型的Some(Some(42))值
    var nestedSome: Option<Option<Int64>> = Some(Some(42))

    // 展开嵌套的Option
    var flattened1 = nestedSome.flatten()
    println("Some(Some(42))展开后: ${flattened1}")

    // 创建Option<Option<Int64>>类型的Some(None)值
    var someNone: Option<Option<Int64>> = Some(None)

    // 展开嵌套的Option
    var flattened2 = someNone.flatten()
    println("Some(None)展开后: ${flattened2}")

    // 创建Option<Option<Int64>>类型的None值
    var noneValue: Option<Option<Int64>> = None

    // 展开嵌套的Option
    var flattened3 = noneValue.flatten()
    println("None展开后: ${flattened3}")

    // 演示链式调用
    var chainedValue: Option<Option<Option<String>>> = Some(Some(Some("Hello")))
    var flattenedChained = chainedValue.flatten().flatten()
    println("链式展开Some(Some(Some(\"Hello\"))): ${flattenedChained}")
}
```

运行结果：

```text
Some(Some(42))展开后: Some(42)
Some(None)展开后: None
None展开后: None
链式展开Some(Some(Some("Hello"))): Some(Hello)
```

### extend\<T> Option\<T> <: Equatable\<Option\<T>> where T <: Equatable\<T>

```cangjie
extend<T> Option<T> <: Equatable<Option<T>> where T <: Equatable<T>
```

功能：为 [Option](core_package_enums.md#enum-optiont)\<T> 枚举扩展 [Equatable](core_package_interfaces.md#interface-equatablet)\<[Option](core_package_enums.md#enum-optiont)\<T>> 接口，支持判等操作。

父类型：

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Option](#enum-optiont)\<T>>

#### operator func !=(Option\<T>)

```cangjie
public operator func !=(other: Option<T>): Bool
```

功能：判断当前实例与参数指向的 [Option](core_package_enums.md#enum-optiont)\<T> 实例是否不等。

参数：

- other: [Option](core_package_enums.md#enum-optiont)\<T> - 待比较的 [Option](core_package_enums.md#enum-optiont)\<T> 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建相同的Some值
    var someValue1: Option<Int64> = Some(42)
    var someValue2: Option<Int64> = Some(42)

    // 比较两个相同的Some值
    println("Some(42) != Some(42): ${someValue1 != someValue2}")

    // 创建不同的Some值
    var someValue3: Option<Int64> = Some(42)
    var someValue4: Option<Int64> = Some(24)

    // 比较两个不同的Some值
    println("Some(42) != Some(24): ${someValue3 != someValue4}")

    // 创建一个Some值和一个None值
    var someValue5: Option<Int64> = Some(42)
    var noneValue1: Option<Int64> = None

    // 比较Some值和None值
    println("Some(42) != None: ${someValue5 != noneValue1}")

    // 创建两个None值
    var noneValue2: Option<Int64> = None
    var noneValue3: Option<Int64> = None

    // 比较两个None值
    println("None != None: ${noneValue2 != noneValue3}")
}
```

运行结果：

```text
Some(42) != Some(42): false
Some(42) != Some(24): true
Some(42) != None: true
None != None: false
```

#### operator func ==(Option\<T>)

```cangjie
public operator func ==(other: Option<T>): Bool
```

功能：判断当前实例与参数指向的 [Option](core_package_enums.md#enum-optiont)\<T> 实例是否相等。

如果两者同为 None，则相等；如果两者为 Some(v1) 和 Some(v2)，且 v1 和 v2 相等，则相等。

参数：

- other: [Option](core_package_enums.md#enum-optiont)\<T> - 待比较的 [Option](core_package_enums.md#enum-optiont)\<T> 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建相同的Some值
    var someValue1: Option<Int64> = Some(42)
    var someValue2: Option<Int64> = Some(42)

    // 比较两个相同的Some值
    println("Some(42) == Some(42): ${someValue1 == someValue2}")

    // 创建不同的Some值
    var someValue3: Option<Int64> = Some(42)
    var someValue4: Option<Int64> = Some(24)

    // 比较两个不同的Some值
    println("Some(42) == Some(24): ${someValue3 == someValue4}")

    // 创建一个Some值和一个None值
    var someValue5: Option<Int64> = Some(42)
    var noneValue1: Option<Int64> = None

    // 比较Some值和None值
    println("Some(42) == None: ${someValue5 == noneValue1}")

    // 创建两个None值
    var noneValue2: Option<Int64> = None
    var noneValue3: Option<Int64> = None

    // 比较两个None值
    println("None == None: ${noneValue2 == noneValue3}")
}
```

运行结果：

```text
Some(42) == Some(42): true
Some(42) == Some(24): false
Some(42) == None: false
None == None: true
```

### extend\<T> Option\<T> <: Hashable where T <: Hashable

```cangjie
extend<T> Option<T> <: Hashable where T <: Hashable
```

功能：为 [Option](core_package_enums.md#enum-optiont) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口。

[Some](#somet)\<T> 的哈希值等于 `T` 的值对应的哈希值，[None](#none) 的哈希值等于 [Int64](core_package_intrinsics.md#int64)(0)。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Some值
    var someValue: Option<Int64> = Some(42)

    // 获取Some值的哈希码
    var someHashCode = someValue.hashCode()
    println("Some(42)的哈希码: ${someHashCode}")

    // 创建None值
    var noneValue: Option<Int64> = None

    // 获取None值的哈希码
    var noneHashCode = noneValue.hashCode()
    println("None的哈希码: ${noneHashCode}")

    // 比较两个相同的Some值的哈希码
    var someValue1: Option<Int64> = Some(42)
    var someValue2: Option<Int64> = Some(42)

    println("Some(42)和Some(42)的哈希码是否相等: ${someValue1.hashCode() == someValue2.hashCode()}")

    // 比较两个不同的Some值的哈希码
    var someValue3: Option<Int64> = Some(42)
    var someValue4: Option<Int64> = Some(24)

    println("Some(42)和Some(24)的哈希码是否相等: ${someValue3.hashCode() == someValue4.hashCode()}")
}
```

运行结果：

```text
Some(42)的哈希码: 42
None的哈希码: 0
Some(42)和Some(42)的哈希码是否相等: true
Some(42)和Some(24)的哈希码是否相等: false
```

<!--Del_sink-->
#### func hashCode()

```cangjie
public func hashCode(this @local?): Int64
```

功能：计算当前实例的哈希值。

[Some](#somet)\<T> 的哈希值等于 `T` 的值对应的哈希值，[None](#none) 的哈希值等于 [Int64](core_package_intrinsics.md#int64)(0)。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> @local? = [5, 6, 7]
    let o: Option<Int64> @local? = arr.first
    println("h=${o.hashCode()}")
    let empty: Array<Int64> @local? = []
    let n: Option<Int64> @local? = empty.first
    println("h2=${n.hashCode()}")
}
```

运行结果：

```text
h=5
h2=0
```

<!--DelEnd_sink-->
### extend\<T> Option\<T> <: ToString where T <: ToString

```cangjie
extend<T> Option<T> <: ToString where T <: ToString
```

功能：为 [Option](core_package_enums.md#enum-optiont)\<T> 枚举实现 [ToString](core_package_interfaces.md#interface-tostring) 接口，支持转字符串操作。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Option](core_package_enums.md#enum-optiont) 转换为字符串，字符串内容为 "Some(${T.toString()})" 或 "None"。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Some值
    var someValue: Option<Int64> = Some(42)

    // 将Some值转换为字符串
    var someStr = someValue
    println("Some(42)转换为字符串: ${someStr}")

    // 创建None值
    var noneValue: Option<Int64> = None

    // 将None值转换为字符串
    var noneStr = noneValue
    println("None转换为字符串: ${noneStr}")

    // 创建字符串类型的Some值
    var someStringValue: Option<String> = Some("Hello")

    // 将字符串类型的Some值转换为字符串
    var someStringStr = someStringValue
    println("Some(\"Hello\")转换为字符串: ${someStringStr}")
}
```

运行结果：

```text
Some(42)转换为字符串: Some(42)
None转换为字符串: None
Some("Hello")转换为字符串: Some(Hello)
```

## enum Ordering

```cangjie
public enum Ordering {
    | LT
    | GT
    | EQ
}
```

功能：[Ordering](core_package_enums.md#enum-ordering) 表示比较大小的结果，它包含三种情况：小于，大于和等于。

### EQ

```cangjie
EQ
```

功能：构造一个 [Ordering](core_package_enums.md#enum-ordering) 实例，表示等于。

### GT

```cangjie
GT
```

功能：构造一个 [Ordering](core_package_enums.md#enum-ordering) 实例，表示大于。

### LT

```cangjie
LT
```

功能：构造一个 [Ordering](core_package_enums.md#enum-ordering) 实例，表示小于。

### extend Ordering <: Comparable

```cangjie
extend Ordering <: Comparable<Ordering>
```

功能：为 [Ordering](core_package_enums.md#enum-ordering) 类型扩展 [Comparable](core_package_interfaces.md#interface-comparablet)\<[Ordering](core_package_enums.md#enum-ordering)> 接口，支持比较操作。

父类型：

- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Ordering](#enum-ordering)>

#### func compare(Ordering)

```cangjie
public func compare(other: Ordering): Ordering
```

功能：判断当前 [Ordering](core_package_enums.md#enum-ordering) 实例与参数指定的 [Ordering](core_package_enums.md#enum-ordering) 实例的大小关系。

[Ordering](core_package_enums.md#enum-ordering) 枚举的大小关系为：GT > EQ > LT。

参数：

- other: [Ordering](core_package_enums.md#enum-ordering) - 待比较的 [Ordering](core_package_enums.md#enum-ordering) 实例。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 GT；如果等于，返回 EQ；如果小于，返回 LT。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Ordering实例
    var gt: Ordering = GT
    var eq: Ordering = EQ
    var lt: Ordering = LT

    // 测试GT与EQ的比较
    var result1 = gt.compare(eq)
    println("GT.compare(EQ): ${result1}")

    // 测试EQ与LT的比较
    var result2 = eq.compare(lt)
    println("EQ.compare(LT): ${result2}")

    // 测试LT与GT的比较
    var result3 = lt.compare(gt)
    println("LT.compare(GT): ${result3}")

    // 测试相等的情况
    var result4 = gt.compare(gt)
    println("GT.compare(GT): ${result4}")
}
```

运行结果：

```text
GT.compare(EQ): Ordering.GT
EQ.compare(LT): Ordering.GT
LT.compare(GT): Ordering.LT
GT.compare(GT): Ordering.EQ
```

<!--Del_sink-->
#### func compare(Ordering)

```cangjie
public func compare(this @local?, other: Ordering @local?): Ordering
```

功能：判断当前 [Ordering](core_package_enums.md#enum-ordering) 实例与指定实例的大小关系。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 如果大于，返回 [Ordering](core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let gt: Ordering @local? = Ordering.GT
    let eq: Ordering @local? = Ordering.EQ
    let r1 = lt.compare(gt)
    println("LT.compare(GT): ${r1}")
    let r2 = gt.compare(eq)
    println("GT.compare(EQ): ${r2}")
    let r3 = eq.compare(eq)
    println("EQ.compare(EQ): ${r3}")
}
```

运行结果：

```text
LT.compare(GT): Ordering.LT
GT.compare(EQ): Ordering.GT
EQ.compare(EQ): Ordering.EQ
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func ==(Ordering)

```cangjie
public operator func ==(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例与指定实例是否相等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let gt: Ordering @local? = Ordering.GT
    let lt2: Ordering @local? = Ordering.LT
    println("lt == lt2: ${lt == lt2}")
    println("lt == gt: ${lt == gt}")
}
```

运行结果：

```text
lt == lt2: true
lt == gt: false
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func !=(Ordering)

```cangjie
public operator func !=(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例与指定实例是否不等。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let gt: Ordering @local? = Ordering.GT
    let lt2: Ordering @local? = Ordering.LT
    println("lt != lt2: ${lt != lt2}")
    println("lt != gt: ${lt != gt}")
}
```

运行结果：

```text
lt != lt2: false
lt != gt: true
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func <(Ordering)

```cangjie
public operator func <(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例是否小于指定实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let gt: Ordering @local? = Ordering.GT
    println("lt < gt: ${lt < gt}")
    println("gt < lt: ${gt < lt}")
}
```

运行结果：

```text
lt < gt: true
gt < lt: false
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func >(Ordering)

```cangjie
public operator func >(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例是否大于指定实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let gt: Ordering @local? = Ordering.GT
    println("gt > lt: ${gt > lt}")
    println("lt > gt: ${lt > gt}")
}
```

运行结果：

```text
gt > lt: true
lt > gt: false
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func <=(Ordering)

```cangjie
public operator func <=(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例是否小于等于指定实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果小于等于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let lt: Ordering @local? = Ordering.LT
    let eq: Ordering @local? = Ordering.EQ
    println("lt <= eq: ${lt <= eq}")
    println("eq <= lt: ${eq <= lt}")
}
```

运行结果：

```text
lt <= eq: true
eq <= lt: false
```

<!--DelEnd_sink-->

<!--Del_sink-->

#### operator func >=(Ordering)

```cangjie
public operator func >=(this @local?, other: Ordering @local?): Bool
```

功能：判断当前实例是否大于等于指定实例。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。
- other: [Ordering](core_package_enums.md#enum-ordering) @local? - 待比较的另一个 `@local?` 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果大于等于，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let gt: Ordering @local? = Ordering.GT
    let eq: Ordering @local? = Ordering.EQ
    println("gt >= eq: ${gt >= eq}")
    println("eq >= gt: ${eq >= gt}")
}
```

运行结果：

```text
gt >= eq: true
eq >= gt: false
```

<!--DelEnd_sink-->
### extend Ordering <: Hashable

```cangjie
extend Ordering <: Hashable
```

功能：为 [Ordering](core_package_enums.md#enum-ordering) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值，GT 的哈希值是 3，EQ 的哈希值是 2，LT 的哈希值是 1。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Ordering实例
    var gt: Ordering = GT
    var eq: Ordering = EQ
    var lt: Ordering = LT

    // 获取哈希值
    var gtHash = gt.hashCode()
    var eqHash = eq.hashCode()
    var ltHash = lt.hashCode()

    println("GT的哈希值: ${gtHash}")
    println("EQ的哈希值: ${eqHash}")
    println("LT的哈希值: ${ltHash}")
}
```

运行结果：

```text
GT的哈希值: 3
EQ的哈希值: 2
LT的哈希值: 1
```

<!--Del_sink-->
#### func hashCode()

```cangjie
public func hashCode(this @local?): Int64
```

功能：计算当前实例的哈希值，GT 的哈希值是 3，EQ 的哈希值是 2，LT 的哈希值是 1。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local? = Ordering.LT
    let h = ord.hashCode()
    println("h=${h}")
}
```

运行结果：

```text
h=1
```

<!--DelEnd_sink-->

<!--Del_sink-->
#### func hashCode()

```cangjie
public func hashCode(this @local!): Int64
```

功能：计算当前实例的哈希值，GT 的哈希值是 3，EQ 的哈希值是 2，LT 的哈希值是 1。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。

参数：

- this @local! - 调用该方法的当前 `@local!` 实例。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local! = Ordering.GT
    println("h=${ord.hashCode()}")
}
```

运行结果：

```text
h=3
```

<!--DelEnd_sink-->
### extend Ordering <: ToString

```cangjie
extend Ordering <: ToString
```

功能：为 [Ordering](core_package_enums.md#enum-ordering) 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，支持转字符串操作。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将 [Ordering](core_package_enums.md#enum-ordering) 转换为字符串。

转换结果如下：

- GT: "[Ordering](core_package_enums.md#enum-ordering).GT"。
- LT: "[Ordering](core_package_enums.md#enum-ordering).LT"。
- EQ: "[Ordering](core_package_enums.md#enum-ordering).EQ"。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建Ordering实例
    var gt: Ordering = GT
    var eq: Ordering = EQ
    var lt: Ordering = LT

    // 转换为字符串
    var gtStr = gt.toString()
    var eqStr = eq.toString()
    var ltStr = lt.toString()

    println("GT转换为字符串: ${gtStr}")
    println("EQ转换为字符串: ${eqStr}")
    println("LT转换为字符串: ${ltStr}")
}
```

运行结果：

```text
GT转换为字符串: Ordering.GT
EQ转换为字符串: Ordering.EQ
LT转换为字符串: Ordering.LT
```

<!--Del_sink-->
#### func toString()

```cangjie
public func toString(this @local?): String @local!
```

功能：将当前 [Ordering](core_package_enums.md#enum-ordering) 实例转换为可输出的字符串（`Ordering.GT`、`Ordering.LT` 或 `Ordering.EQ`），结果字符串绑定在调用者的 local region 中。

> **注意：**
>
> - 实验性 API，仅用于测试验证，规范和实现仍可能发生变化，请谨慎使用。
> - 不支持平台：OpenHarmony。
> - 当前编译器/运行时版本下，`Ordering` 枚举的 `@local?` 分派存在已知缺陷：在部分调用形态下该方法可能抛出 [UnimplementedException](core_package_exceptions.md#class-unimplementedexception)（默认实现未被覆写分派命中），请以实际 SDK 版本行为为准。

参数：

- this @local? - 调用该方法的当前 `@local?` 实例。

返回值：

- [String](core_package_structs.md#struct-string) @local! - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    let ord: Ordering @local? = Ordering.LT
    let s: String @local! = ord.toString()
    println(s)
}
```

运行结果：

```text
Ordering.LT
```

<!--DelEnd_sink-->
## enum ThreadState

```cangjie
public enum ThreadState <: ToString {
    | Ready
    | Running
    | Pending
    | Terminated
    | ...
}
```

功能：表示线程的状态。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

### Pending

```cangjie
Pending
```

功能：表示线程正被挂起。

### Ready

```cangjie
Ready
```

功能：表示线程刚创建或结束挂起，正在等待被调度执行。

### Running

```cangjie
Running
```

功能：表示线程正在执行。

### Terminated

```cangjie
Terminated
```

功能：表示线程已结束执行。

### func toString()

```cangjie
public func toString(): String
```

功能：将 [ThreadState](core_package_enums.md#enum-threadstate) 转换为字符串。

转换结果如下：

- Ready: "Ready"。
- Running: "Running"。
- Pending: "Pending"。
- Terminated: "Terminated"。

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    let t = ThreadState.Running
    println("Thread State: ${t}")
}
```

运行结果：

```text
Thread State: Running
```
