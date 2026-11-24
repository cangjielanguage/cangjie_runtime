# 类

## class ArkTSArray\<T>

```cangjie
public foreign class ArkTSArray<T> {
    public init(arrayLength: Float64)
    public init(@RestParam items: Array<T>)
}
```

功能：ArkTS `Array<T>`/`T[]` 对象的仓颉侧类型。设计上它与 ArkTS 数组对象引用同一实例，任一侧的修改对另一侧可见。

引用语义和成员级转换尚未实现，将在后续版本提供。本版本内，`ArkTSArray<T>` 出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器会拒绝该用法，并提示该类型的引用语义在当前版本不可用。

本版本声明 14 个无体成员，设计共 30 个，其余 16 个将在后续版本提供。所有成员在 ArkTS 侧实现，下面的成员说明描述 ArkTS 侧语义。本版本只交付声明，尚未提供创建实例或调用成员的跨边界路径。

### init(Float64)

```cangjie
public init(arrayLength: Float64)
```

功能：构造一个指定长度的 ArkTS 数组对象，新增元素为 ArkTS 侧的默认空位。

参数：

- arrayLength: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 数组长度。

### init(Array\<T>)

```cangjie
public init(@RestParam items: Array<T>)
```

功能：用给定元素构造一个 ArkTS 数组对象。

说明：`@RestParam items` 到 ArkTS `Array` 构造器的发射形态尚未定稿，属于后续版本的开放项。ArkTS/JS 的 `new Array(...items)` 在 `items` 恰为单个数字元素时会命中「长度构造」重载（例如 `new Array(3.0)` 得到长度为 3 的空位数组），构造方式须避开该陷阱。

参数：

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - 数组元素，变长参数语法支持省略数组字面量的 `[]`。

### static func isArray(ArkTSType)

```cangjie
public static func isArray(arg: ArkTSType): Bool
```

功能：判断给定值是否为 ArkTS 数组对象。

参数：

- arg: [ArkTSType](interop_arkts_package_interfaces.md#interface-arktstype) - 待判断的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是数组对象返回 `true`，否则返回 `false`。

### static prop prototype

```cangjie
public static prop prototype: ArkTSArray<ArkTSType>
```

功能：ArkTS `Array` 构造函数的原型对象。该属性是构造函数上的静态成员，通过类名访问，实例上不提供。

类型：[ArkTSArray\<T>](#class-arktsarrayt)\<[ArkTSType](interop_arkts_package_interfaces.md#interface-arktstype)>

### prop length

```cangjie
public prop length: Float64
```

功能：数组的元素个数。

类型：[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)

### func pop()

```cangjie
public func pop(): Option<T>
```

功能：移除并返回数组的最后一个元素。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 被移除的元素；数组为空时返回 `None`。

### func push(Array\<T>)

```cangjie
public func push(@RestParam items: Array<T>): Float64
```

功能：在数组末尾追加元素。

参数：

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - 待追加的元素，变长参数语法支持省略数组字面量的 `[]`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 追加后的数组长度。

示例：

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

main() {
    unsafe {
        // 变长参数构造：传 3 个实参不会命中 init(Float64) 的长度构造重载
        let arr = ArkTSArray<Float64>(1.0, 2.0, 3.0)
        let length = arr.push(4.0, 5.0)
        let text = arr.join(separator: "-")
        let index = arr.indexOf(3.0, fromIndex: 0.0)
        println("${length} ${text} ${index}")
    }
}
```

说明：示例给出调用形态。本版本只交付声明，运行期的跨边界调用不在本版本范围内。


### func join(Option\<String>)

```cangjie
public func join(separator!: Option<String> = None): String
```

功能：把数组各元素转换为字符串后用分隔符连接，语义与 ArkTS `Array.prototype.join` 一致。

参数：

- separator!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - 连接各元素的分隔符，默认值为 `None`。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 连接结果。

### func reverse()

```cangjie
public func reverse(): ArkTSArray<T>
```

功能：原地反转数组元素顺序。

返回值：

- [ArkTSArray](#class-arktsarrayt)\<T> - 该数组对象本身，便于链式调用。

### func shift()

```cangjie
public func shift(): Option<T>
```

功能：移除并返回数组的第一个元素。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 被移除的元素；数组为空时返回 `None`。

### func unshift(Array\<T>)

```cangjie
public func unshift(@RestParam items: Array<T>): Float64
```

功能：在数组开头插入元素，原有元素依次后移。

参数：

- items: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - 待插入的元素，变长参数语法支持省略数组字面量的 `[]`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 插入后的数组长度。

### func slice(Option\<Float64>, Option\<Float64>)

```cangjie
public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
```

功能：截取下标区间 `[start, end)` 内的元素，组成新的 ArkTS 数组，语义与 ArkTS `Array.prototype.slice` 一致（包含负下标处理）。

参数：

- start!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 区间起始下标，默认值为 `None`。
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 区间结束下标（不含），默认值为 `None`。

返回值：

- [ArkTSArray](#class-arktsarrayt)\<T> - 截取结果组成的新数组对象。

### func indexOf(T, Option\<Float64>)

```cangjie
public func indexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
```

功能：从 `fromIndex` 开始查找元素首次出现的下标。

说明：ArkTS 侧 `indexOf` 按严格相等（`===`）比较。`T` 为引用类型时，跨边界句柄是否保持同一 ArkTS 对象身份尚未定稿，属于后续版本的开放项；定稿前不保证这类查找返回预期结果。

参数：

- searchElement: T - 待查找的元素。
- fromIndex!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 查找起始下标，默认值为 `None`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 首次出现的下标；未找到时返回 `-1`。

### func lastIndexOf(T, Option\<Float64>)

```cangjie
public func lastIndexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
```

功能：从 `fromIndex` 开始向前查找元素最后一次出现的下标。

说明：ArkTS 侧 `lastIndexOf` 按严格相等（`===`）比较。`T` 为引用类型时，跨边界句柄是否保持同一 ArkTS 对象身份尚未定稿，属于后续版本的开放项；定稿前不保证这类查找返回预期结果。

参数：

- searchElement: T - 待查找的元素。
- fromIndex!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 查找起始下标，默认值为 `None`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 最后一次出现的下标；未找到时返回 `-1`。

## class ArkTSString

```cangjie
public foreign class ArkTSString {
    public init(value!: Option<String> = None)
}
```

功能：ArkTS `string` 的仓颉侧类型，是 JS 字符串值的句柄，可承载原始字符串或 `String` 包装对象。设计上它以引用方式承载该字符串值，跨边界传递时不拷贝内容，字符串运算在 ArkTS 侧完成。`charAt`/`toString` 按值返回仓颉 `String`，必然发生内容拷贝；`slice`/`substring`/`toUpperCase`/`toLowerCase` 返回 JS 原始字符串，由返回的 `ArkTSString` 句柄承载。

引用语义和成员级转换尚未实现，将在后续版本提供。本版本内，`ArkTSString` 出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器会拒绝该用法，并提示该类型的引用语义在当前版本不可用。

本版本声明 11 个无体成员，设计共 47 个，其余 36 个将在后续版本提供。所有成员在 ArkTS 侧实现，下面的成员说明描述 ArkTS 侧语义。本版本只交付声明，尚未提供创建实例或调用成员的跨边界路径。

### init(Option\<String>)

```cangjie
public init(value!: Option<String> = None)
```

功能：用给定字符串值构造 ArkTS 字符串对象。

参数：

- value!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[String](../../core/core_package_api/core_package_structs.md#struct-string)> - 初始字符串值，默认值为 `None`。

### prop length

```cangjie
public prop length: Float64
```

功能：字符串的长度，按 ArkTS 的 UTF-16 编码单元计数。

类型：[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)

### func charAt(Float64)

```cangjie
public func charAt(pos: Float64): String
```

功能：返回指定下标处的字符。

参数：

- pos: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 字符下标。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 该下标处的字符；下标越界时返回空字符串。

### func charCodeAt(Float64)

```cangjie
public func charCodeAt(pos: Float64): Float64
```

功能：返回指定下标处字符的 UTF-16 编码单元值。

参数：

- pos: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 字符下标。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 该位置的编码单元值；下标越界时返回 `NaN`。

### func indexOf(String, Option\<Float64>)

```cangjie
public func indexOf(searchString: String, position!: Option<Float64> = None): Float64
```

功能：从 `position` 开始查找子串首次出现的下标。

参数：

- searchString: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待查找的子串。
- position!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 查找起始下标，默认值为 `None`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 首次出现的下标；未找到时返回 `-1`。

### func lastIndexOf(String, Option\<Float64>)

```cangjie
public func lastIndexOf(searchString: String, position!: Option<Float64> = None): Float64
```

功能：从 `position` 开始向前查找子串最后一次出现的下标。

参数：

- searchString: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 待查找的子串。
- position!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 查找起始下标，默认值为 `None`。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 最后一次出现的下标；未找到时返回 `-1`。

### func slice(Option\<Float64>, Option\<Float64>)

```cangjie
public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
```

功能：截取下标区间 `[start, end)` 内的字符，组成新的 ArkTS 字符串，语义与 ArkTS `String.prototype.slice` 一致（包含负下标处理）。

参数：

- start!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 区间起始下标，默认值为 `None`。
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 区间结束下标（不含），默认值为 `None`。

返回值：

- [ArkTSString](#class-arktsstring) - 截取结果组成的新字符串对象。

### func substring(Float64, Option\<Float64>)

```cangjie
public func substring(start: Float64, end!: Option<Float64> = None): ArkTSString
```

功能：截取下标区间 `[start, end)` 内的字符，组成新的 ArkTS 字符串，语义与 ArkTS `String.prototype.substring` 一致（负下标按 `0` 处理）。

参数：

- start: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 区间起始下标。
- end!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Float64](../../core/core_package_api/core_package_intrinsics.md#float64)> - 区间结束下标（不含），默认值为 `None`。

返回值：

- [ArkTSString](#class-arktsstring) - 截取结果组成的新字符串对象。

### func toUpperCase()

```cangjie
public func toUpperCase(): ArkTSString
```

功能：把字符串转换为大写形式。

返回值：

- [ArkTSString](#class-arktsstring) - 转换后的新字符串对象。

### func toLowerCase()

```cangjie
public func toLowerCase(): ArkTSString
```

功能：把字符串转换为小写形式。

返回值：

- [ArkTSString](#class-arktsstring) - 转换后的新字符串对象。

### func toString()

```cangjie
public func toString(): String
```

功能：按值取出字符串内容。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 字符串内容。

示例：

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

main() {
    unsafe {
        let s = ArkTSString(value: "Hello")
        let length = s.length
        let ch = s.charAt(1.0)
        let sub = s.substring(1.0, end: 4.0)
        let index = s.indexOf("ll", position: 0.0)
        println("${length} ${ch} ${sub.toString()} ${index}")
    }
}
```

说明：示例给出调用形态。本版本只交付声明，运行期的跨边界调用不在本版本范围内。

## class ArkTSFunc\<F>

```cangjie
public foreign class ArkTSFunc<F> {
    public init(f: F)
}
```

功能：ArkTS 函数值的仓颉侧类型，`F` 为仓颉函数类型。

`F` 必须是满足 `ArkTSType` 约束的仓颉函数类型；该约束检查、构造函数值与直接调用均设计为编译器内建行为（不走 where 子句）。本版本只提供构造；直接调用依赖父类型 `Function`。由于父类型 `Function` 尚未加入标准库，`ArkTSFunc<F> <: Function` 的继承关系暂不声明。

### init(F)

```cangjie
public init(f: F)
```

功能：由仓颉函数值显式构造 `ArkTSFunc<F>`，构造形式为 `ArkTSFunc<F>(f)`。`f` 可以是函数名、lambda、方法引用或类型为 `F` 的变量。

参数：

- f: `F` - 仓颉函数值。

说明：不支持从仓颉函数值隐式转换到 `ArkTSFunc<F>`，也不支持型变。

示例：

<!-- compile -->
<!-- cfg="--experimental" -->
```cangjie
import std.interop.arkts.*

func addOne(x: Float64): Float64 {
    return x + 1.0
}

main() {
    unsafe {
        // 只支持显式构造，不支持隐式转换与型变
        let fn = ArkTSFunc<(Float64) -> Float64>(addOne)
        println(fn is ArkTSFunc<(Float64) -> Float64>)
    }
}
```

说明：本版本只支持显式构造 `ArkTSFunc<F>`。直接调用该值依赖父类型 `Function`，尚未实现，将在后续版本提供；`is` 检查仅用于让示例中的变量被使用。

## class ArkTSFuncWithThis\<ThisT, F>

```cangjie
public foreign class ArkTSFuncWithThis<ThisT, F> {
}
```

功能：带 `this` 参数的 ArkTS 函数值的仓颉侧类型，`ThisT` 为该 `this` 参数映射后的类型，`F` 为仓颉函数类型。

`ArkTSFuncWithThis<ThisT, F>` 没有公开构造函数，其值只可能来自带 `@HasThis` 的 `foreign func` 声明。`ThisT` 与 `F` 的约束设计为编译器内建检查。

### func bind(ThisT)

```cangjie
public func bind(thisArg: ThisT): ArkTSFunc<F>
```

功能：把 `thisArg` 作为 ArkTS 侧的 `this` 绑定到函数值，返回绑定后的 `ArkTSFunc<F>`。对同一个值多次调用 `bind` 得到互相独立的结果。

参数：

- thisArg: `ThisT` - ArkTS 侧 `this` 参数的值。

返回值：

- [ArkTSFunc\<F>](#class-arktsfuncf) - 绑定 `thisArg` 后的函数值。

说明：本版本 `bind` 只做成员查找与类型检查，调用 `bind` 会报“暂不支持”；`ArkTSFunc<F>` 的直接调用也尚未实现，两者都将在后续版本提供，因此本版本无法给出可运行示例。
