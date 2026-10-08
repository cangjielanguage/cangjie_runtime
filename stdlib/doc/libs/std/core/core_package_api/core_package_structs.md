# 结构体

## struct Array\<T>

```cangjie
public struct Array<T> {
    public const init()
    public init(size: Int64, repeat!: T)
    public init(size: Int64, initElement: (Int64) -> T)
}
```

功能：仓颉数组类型，用来表示单一类型的元素构成的有序序列。

T 表示数组的元素类型，T 可以是任意类型。

### prop first

```cangjie
public prop first: Option<T>
```

功能：获取当前数组的第一个元素，如果当前数组为空，返回 None。

类型：[Option](core_package_enums.md#enum-optiont)\<T>

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]
    let first = arr.first
    println(first)

    // 测试空数组的情况
    let emptyArr: Array<Int64> = []
    let emptyFirst = emptyArr.first
    println(emptyFirst)
}
```

运行结果：

```text
Some(1)
None
```

### prop last

```cangjie
public prop last: Option<T>
```

功能：获取当前数组的最后一个元素，如果当前数组为空，返回 None。

类型：[Option](core_package_enums.md#enum-optiont)\<T>

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]
    let last = arr.last
    println(last)

    // 测试空数组的情况
    let emptyArr: Array<Int64> = []
    let emptyLast = emptyArr.last
    println(emptyLast)
}
```

运行结果：

```text
Some(3)
None
```

### init()

```cangjie
public const init()
```

功能：构造一个空数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> = Array()
    println("Empty array size: ${arr.size}")

    // 创建一个新的数组并添加元素
    let newArr = [1, 2, 3]
    println("New array: ${newArr}")
}
```

运行结果：

```text
Empty array size: 0
New array: [1, 2, 3]
```

### init(Int64, (Int64) -> T)

```cangjie
public init(size: Int64, initElement: (Int64) -> T)
```

功能：创建指定长度的数组，其中元素根据初始化函数计算获取。

即：将 [0, size) 范围内的值分别传入初始化函数 initElement，执行得到数组对应下标的元素。

参数：

- size: [Int64](core_package_intrinsics.md#int64) - 数组大小。
- initElement: ([Int64](core_package_intrinsics.md#int64)) ->T - 初始化函数。

异常：

- [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) - 当 size 小于 0，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个长度为5的数组，每个元素的值为其下标的平方
    let arr = Array<Int64>(5, {index => index * index})
    println("Array with squares: ${arr}")

    // 创建一个长度为3的字符串数组，每个元素都是"Hello"
    let strArr = Array<String>(3, {_ => "Hello"})
    println("String array: ${strArr}")
}
```

运行结果：

```text
Array with squares: [0, 1, 4, 9, 16]
String array: [Hello, Hello, Hello]
```

### init(Int64, T)

```cangjie
public init(size: Int64, repeat!: T)
```

功能：构造一个指定长度的数组，其中元素都用指定初始值进行初始化。

> **注意：**
>
> 该构造函数不会拷贝 repeat， 如果 repeat 是一个引用类型，构造后数组的每一个元素都将指向相同的引用。

参数：

- size: [Int64](core_package_intrinsics.md#int64) - 数组大小，取值范围为 [0, [Int64](core_package_intrinsics.md#int64).Max]。
- repeat!: T - 数组元素初始值。

异常：

- [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) - 当 size 小于 0，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用命名参数repeat来初始化数组
    let arr = Array<Int64>(5, repeat: 42)
    println("Array with repeated value 42: ${arr}")

    // 创建一个长度为3的字符串数组，所有元素都初始化为"Hello"
    let strArr = Array<String>(3, repeat: "Hello")
    println("String array with repeated value: ${strArr}")

    // 创建一个长度为4的布尔数组，所有元素都初始化为true
    let boolArr = Array<Bool>(4, repeat: true)
    println("Boolean array with repeated value: ${boolArr}")
}
```

运行结果：

```text
Array with repeated value 42: [42, 42, 42, 42, 42]
String array with repeated value: [Hello, Hello, Hello]
Boolean array with repeated value: [true, true, true, true]
```

<!--Del-->
### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

功能：判断数组所有元素是否都满足条件。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 给定的条件。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果数组所有元素都满足条件，返回 true，否则返回 false

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [2, 4, 6, 8, 10]

    println("数组: ${arr}")

    // 检查数组中所有元素是否都是偶数
    let allEven = arr.all({num => num % 2 == 0})
    println("所有元素都是偶数: ${allEven}")

    // 检查数组中所有元素是否都大于5
    let allGreaterThanFive = arr.all({num => num > 5})
    println("所有元素都大于5: ${allGreaterThanFive}")

    return 0
}
```

运行结果：

```text
数组: [2, 4, 6, 8, 10]
所有元素都是偶数: true
所有元素都大于5: false
```

<!--DelEnd-->

<!--Del-->
### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

功能：判断数组是否存在任意一个满足条件的元素。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 给定的条件。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是否存在任意满足条件的元素。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 3, 5, 8, 9]

    println("数组: ${arr}")

    // 检查数组中是否存在偶数
    let hasEven = arr.any({num => num % 2 == 0})
    println("存在偶数: ${hasEven}")

    // 检查数组中是否存在大于10的元素
    let hasGreaterThanTen = arr.any({num => num > 10})
    println("存在大于10的元素: ${hasGreaterThanTen}")

    return 0
}
```

运行结果：

```text
数组: [1, 3, 5, 8, 9]
存在偶数: true
存在大于10的元素: false
```

<!--DelEnd-->
### func clone()

```cangjie
public func clone(): Array<T>
```

功能：克隆数组，将对数组数据进行深拷贝。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 克隆得到的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    let clonedArr = arr.clone()

    println("Original array: ${arr}")
    println("Cloned array: ${clonedArr}")

    // 验证克隆后的数组是独立的
    clonedArr[0] = 10
    println("After modifying cloned array:")
    println("Original array: ${arr}")
    println("Cloned array: ${clonedArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
Cloned array: [1, 2, 3, 4, 5]
After modifying cloned array:
Original array: [1, 2, 3, 4, 5]
Cloned array: [10, 2, 3, 4, 5]
```

### func clone(Range\<Int64>)

```cangjie
public func clone(range: Range<Int64>): Array<T>
```

功能：克隆数组的指定区间。

> **注意：**
>
> 1. 如果参数 range 是使用 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 构造函数构造的 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例，有如下行为：
>    - start 的值就是构造函数传入的值本身，不受构造时传入的 hasStart 的值的影响。
>    - hasEnd 为 false 时，end 值不生效，且不受构造时传入的 isClosed 的值的影响，数组切片取到原数组最后一个元素。
> 2. range 的步长只能为 1。

参数：

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - 克隆的区间。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 克隆得到的新数组。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - range 超出数组范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = arr.clone(1..4)
    println(new)
}
```

运行结果：

```text
[1, 2, 3]
```

### func concat(Array\<T>)

```cangjie
public func concat(other: Array<T>): Array<T>
```

功能：该函数将创建一个新的数组，数组内容是当前数组后面串联 other 指向的数组。

参数：

- other: [Array](core_package_structs.md#struct-arrayt)\<T> - 串联到当前数组末尾的数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 串联得到的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = arr.concat([6, 7, 8, 9, 10])
    println(new)
}
```

运行结果：

```text
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

### func copyTo(Array\<T>)

```cangjie
public func copyTo(dst: Array<T>): Unit
```

功能：将当前数组的全部元素拷贝到目标数组 dst 中。

拷贝长度为当前数组的长度，从目标数组的起始位置开始写入，要求当前数组的长度不大于目标数组的长度。

参数：

- dst: [Array](core_package_structs.md#struct-arrayt)\<T> - 目标数组。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当前数组的长度大于目标数组的长度。

示例：

<!-- verify -->
```cangjie
main() {
    let srcArr = [1, 2, 3, 4, 5]
    let dstArr = [0, 0, 0, 0, 0, 0, 0]

    println("Before copy:")
    println("Source array: ${srcArr}")
    println("Destination array: ${dstArr}")

    // 将源数组拷贝到目标数组
    srcArr.copyTo(dstArr)

    println("After copy:")
    println("Source array: ${srcArr}")
    println("Destination array: ${dstArr}")
}
```

运行结果：

```text
Before copy:
Source array: [1, 2, 3, 4, 5]
Destination array: [0, 0, 0, 0, 0, 0, 0]
After copy:
Source array: [1, 2, 3, 4, 5]
Destination array: [1, 2, 3, 4, 5, 0, 0]
```

### func copyTo(Array\<T>, Int64, Int64, Int64)

```cangjie
public func copyTo(dst: Array<T>, srcStart: Int64, dstStart: Int64, copyLen: Int64): Unit
```

功能：将当前数组中的一段数据拷贝到目标数组中。

参数：

- dst: [Array](core_package_structs.md#struct-arrayt)\<T> - 目标数组。
- srcStart: [Int64](core_package_intrinsics.md#int64) - 从 this 数组的 srcStart 下标开始拷贝，取值范围为 [0, this.size)。
- dstStart: [Int64](core_package_intrinsics.md#int64) - 从目标数组的 dstStart 下标开始写入，取值范围为 [0, dst.size)。
- copyLen: [Int64](core_package_intrinsics.md#int64) - 拷贝数组的长度，取值要求为 copyLen + srcStart < this.size，copyLen + dstStart < dst.size。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - copyLen 小于 0 则抛出此异常。
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果参数不满足上述取值范围，抛出此异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = [0, 0, 0, 0, 0, 0]
    arr.copyTo(new, 2, 2, 4)
    println(new)
}
```

运行结果：

```text
[0, 0, 2, 3, 4, 5]
```

### func fill(T)

```cangjie
public func fill(value: T): Unit
```

功能：将当前数组内所有元素都替换成指定的 value。

参数：

- value: T - 修改的目标值。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Before fill: ${arr}")

    // 将数组中的所有元素都替换成0
    arr.fill(0)

    println("After fill: ${arr}")

    // 创建另一个数组并只填充部分元素
    let arr2 = [1, 2, 3, 4, 5]
    println("Before partial fill: ${arr2}")

    // 只填充索引1到3的元素
    arr2[1..4].fill(-1)

    println("After partial fill: ${arr2}")
}
```

运行结果：

```text
Before fill: [1, 2, 3, 4, 5]
After fill: [0, 0, 0, 0, 0]
Before partial fill: [1, 2, 3, 4, 5]
After partial fill: [1, -1, -1, -1, 5]
```

<!--Del-->
### func filter((T) -> Bool)

```cangjie
public func filter(predicate: (T) -> Bool): Array<T> 
```

功能： 返回一个满足筛选条件的元素的新数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 给定的条件。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 返回一个满足筛选条件的元素的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    println("原数组: ${arr}")

    // 筛选偶数
    let evenNumbers = arr.filter({num => num % 2 == 0})
    println("偶数: ${evenNumbers}")
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
偶数: [2, 4, 6, 8, 10]
```

<!--DelEnd-->

<!--Del-->
### func filterMap\<R>((T) -> ?R)

```cangjie
public func filterMap<R>(transform: (T) -> ?R): Array<R>
```

功能：同时进行筛选操作和映射操作，返回一个新数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- transform: (T) -> ?R - 给定的映射函数。函数返回值为 Some 对应 filter 的 predicate 为 true，反之表示 false。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<R> - 返回一个筛选和映射的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = ["123", "abcd", "45", ""]

    println("原数组: ${arr}")

    // 使用filterMap筛选非空字符串并转换为其长度
    let lengths = arr.filterMap({
        s: String => if (!s.isEmpty()) {
            Some(s.size)
        } else {
            Option<Int64>.None
        }
    })
    println("非空字符串的长度: ${lengths}")

    return 0
}
```

运行结果：

```text
原数组: [123, abcd, 45, ]
非空字符串的长度: [3, 4, 2]
```

<!--DelEnd-->

<!--Del-->
### func flatMap\<R>((T) -> Array\<R>)

```cangjie
public func flatMap<R>(transform: (T) -> Array<R>): Array<R>
```

功能：对数组中的每个元素应用一个转换闭包（transform），该闭包返回一个数组，然后将所有返回的数组“压平”（flatten）并连接成一个单一的结果数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- transform: (T) -> [Array](core_package_structs.md#struct-arrayt)\<R> - 给定的映射函数。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<R> -  被“映射（map）”和“压平（flatten）”后的新数组

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]

    println("原数组: ${arr}")

    // 使用flatMap将每个数字扩展为多个元素的数组
    let expanded = arr.flatMap({
        num: Int64 => ["数字: ${num}", "数字的平方: ${num * num}"]
    })
    println("扩展后: ${expanded}")
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3]
扩展后: [数字: 1, 数字的平方: 1, 数字: 2, 数字的平方: 4, 数字: 3, 数字的平方: 9]
```

<!--DelEnd-->

<!--Del-->
### func fold\<R>(R, (R, T) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, T) -> R): R
```

功能：使用指定初始值，从左向右计算。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- initial: R - 给定的 R 类型的初始值。
- operation: (R, T) -> R - 给定的计算函数。

返回值：

- R - 返回最终计算得到的值。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("原数组: ${arr}")

    // 使用fold计算数组元素之和
    let sum = arr.fold(0, {acc: Int64, num: Int64 => acc + num})
    println("数组元素之和: ${sum}")
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5]
数组元素之和: 15
```

<!--DelEnd-->

<!--Del-->
### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

功能：遍历所有元素，执行给定的操作。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - 给定的操作函数。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = ["apple", "banana", "cherry"]

    println("原数组: ${arr}")

    // 使用forEach遍历数组并打印每个元素
    println("遍历结果:")
    arr.forEach({
        item => println(" ${item}")
    })
    return 0
}
```

运行结果：

```text
原数组: [apple, banana, cherry]
遍历结果:
 apple
 banana
 cherry
```

<!--DelEnd-->
### func get(Int64)

```cangjie
public func get(index: Int64): Option<T>
```

功能：获取数组中下标 index 对应的元素。

该函数结果将用 [Option](core_package_enums.md#enum-optiont) 封装，如果 index 越界，将返回 None。

也可以通过 [] 操作符获取数组指定下标的元素，该接口将在 index 越界时抛出异常。

参数：

- index: [Int64](core_package_intrinsics.md#int64) - 要获取的值的下标。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<T> - 当前数组中下标 index 对应的值。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2]
    let num = arr.get(0)
    println(num)
}
```

运行结果：

```text
Some(0)
```

<!--Del-->
### func intersperse(T)

```cangjie
public func intersperse(separator: T): Array<T>
```

功能：返回每两个元素之间插入一个给定的新元素后的新数组

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- separator: T - 给定的元素。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 返回一个新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4]

    println("原数组: ${arr}")

    // 使用intersperse在元素之间插入分隔符
    let result = arr.intersperse(0)
    println("插入分隔符0后: ${result}")
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4]
插入分隔符0后: [1, 0, 2, 0, 3, 0, 4]
```

<!--DelEnd-->
### func map\<R>((T)->R)

```cangjie
public func map<R>(transform: (T)->R): Array<R>
```

功能：将当前数组内所有 T 类型元素根据 transform 映射为 R 类型的元素，组成新的数组。

参数：

- transform: (T)->R - 映射函数。

返回值：

- [Array](./core_package_structs.md#struct-arrayt)\<R> - 原数组中所有元素映射后得到的元素组成的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 将数组中的每个元素都加1
    let mappedArr = arr.map({value => value + 1})

    println("Mapped array (each element + 1): ${mappedArr}")

    // 将整数数组转换为字符串数组
    let strArr = arr.map({value => "Number: ${value}"})

    println("String array: ${strArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
Mapped array (each element + 1): [2, 3, 4, 5, 6]
String array: [Number: 1, Number: 2, Number: 3, Number: 4, Number: 5]
```

<!--Del-->
### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

功能：判断数组中所有元素是否都不满足条件。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 给定的条件。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 当前数组中元素是否都不满足条件。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 3, 5, 7, 9] // 全是奇数

    println("数组: ${arr}")

    // 检查数组中是否所有元素都不是偶数（即没有偶数）
    let noEven = arr.none({num => num % 2 == 0})
    println("没有偶数: ${noEven}")

    // 检查数组中是否所有元素都不大于10
    let noGreaterThanTen = arr.none({num => num > 10})
    println("没有大于10的数: ${noGreaterThanTen}")

    return 0
}
```

运行结果：

```text
数组: [1, 3, 5, 7, 9]
没有偶数: true
没有大于10的数: true
```

<!--DelEnd-->

<!--Del-->
### func reduce((T, T) -> T)

```cangjie
public func reduce(operation: (T, T) -> T): Option<T>
```

功能：使用第一个元素作为初始值，从左向右计算。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- operation: (T, T) -> T - 给定的计算函数。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 返回计算结果。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("原数组: ${arr}")

    // 使用reduce计算数组元素之和
    let sumResult = arr.reduce({acc, num => acc + num})
    if (let Some(sum) <- sumResult) {
        println("数组元素之和: ${sum}")
    } else {
        println("数组为空")
    }
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5]
数组元素之和: 15
```

<!--DelEnd-->
### func repeat(Int64)

```cangjie
public func repeat(n: Int64): Array<T>
```

功能：重复当前数组若干次，得到新数组。

参数：

- n: [Int64](core_package_intrinsics.md#int64) - 重复次数。

返回值：

- [Array](./core_package_structs.md#struct-arrayt)\<T> - 重复当前数组 n 次得到的新数组。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 参数 n 小于等于 0。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]

    println("Original array: ${arr}")

    // 将数组重复3次
    let repeatedArr = arr.repeat(3)

    println("Repeated array (3 times): ${repeatedArr}")

    // 重复一个包含字符串的数组
    let strArr = ["Hello", "World"]
    let repeatedStrArr = strArr.repeat(2)

    println("Repeated string array (2 times): ${repeatedStrArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3]
Repeated array (3 times): [1, 2, 3, 1, 2, 3, 1, 2, 3]
Repeated string array (2 times): [Hello, World, Hello, World]
```

### func reverse()

```cangjie
public func reverse(): Unit
```

功能：反转数组，将数组中元素的顺序进行反转。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 反转数组
    arr.reverse()

    println("Reversed array: ${arr}")

    // 反转包含字符串的数组
    let strArr = ["Hello", "World", "Cangjie"]
    println("Original string array: ${strArr}")

    strArr.reverse()

    println("Reversed string array: ${strArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
Reversed array: [5, 4, 3, 2, 1]
Original string array: [Hello, World, Cangjie]
Reversed string array: [Cangjie, World, Hello]
```

<!--Del-->
### func skip(Int64)

```cangjie
public func skip(count: Int64): Array<T>
```

功能： 跳过特定个数元素并返回一个新数组。

当 count 小于等于 0 时，抛出异常。当 count 等于 0 时，相当没有跳过任何元素，返回包含源数组所有元素的新数组。当 count 大于 0 小于源数组的大小时，跳过前 count 个元素，返回包含剩下的元素的新数组。当 count 大于等于数组的大小时，返回空数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- count: [Int64](core_package_intrinsics.md#int64) - 要跳过的个数。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 返回一个跳过指定数量元素的新数组。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 count < 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 6, 7, 8]

    println("原数组: ${arr}")

    // 跳过前3个元素
    let skipped = arr.skip(3)
    println("跳过前3个元素后: ${skipped}")

    // 跳过前0个元素（相当于不跳过）
    let noSkip = arr.skip(0)
    println("跳过前0个元素后: ${noSkip}")

    // 跳过超过数组长度的元素
    let skipAll = arr.skip(10)
    println("跳过前10个元素后: ${skipAll}")

    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5, 6, 7, 8]
跳过前3个元素后: [4, 5, 6, 7, 8]
跳过前0个元素后: [1, 2, 3, 4, 5, 6, 7, 8]
跳过前10个元素后: []
```

<!--DelEnd-->
### func slice(Int64, Int64)

```cangjie
public func slice(start: Int64, len: Int64): Array<T>
```

功能：获取数组切片。

> **注意：**
>
> 切片不会对数组数据进行拷贝，是对原数据特定区间的引用。

参数：

- start: [Int64](core_package_intrinsics.md#int64) - 切片的起始位置，取值需大于等于 0，且 start + len 小于等于当前 [Array](core_package_structs.md#struct-arrayt) 实例的长度。
- len: [Int64](core_package_intrinsics.md#int64) - 切片的长度，取值需大于 0。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 返回切片后的数组。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果参数不符合上述取值范围，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    println("Original array: ${arr}")

    // 获取从索引2开始，长度为4的切片
    let slice = arr.slice(2, 4)

    println("Slice from index 2, length 4: ${slice}")

    // 验证切片是原数组的引用
    slice[0] = -1
    println("After modifying slice:")
    println("Original array: ${arr}")
    println("Slice: ${slice}")
}
```

运行结果：

```text
Original array: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
Slice from index 2, length 4: [2, 3, 4, 5]
After modifying slice:
Original array: [0, 1, -1, 3, 4, 5, 6, 7, 8, 9]
Slice: [-1, 3, 4, 5]
```

### func splitAt(Int64)

```cangjie
public func splitAt(mid: Int64): (Array<T>, Array<T>)
```

功能：从指定位置 mid 处分割数组。

得到的两个数组是原数组的切片，取值范围为 [0, mid), [mid, this.size)。

参数：

- mid: [Int64](core_package_intrinsics.md#int64) - 分割的位置，取值范围为 [0, this.size]。

返回值：

- ([Array](./core_package_structs.md#struct-arrayt)\<T>, [Array](./core_package_structs.md#struct-arrayt)\<T>) - 分割原数组得到的两个切片。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - mid 小于 0 或大于 this.size。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 在索引3处分割数组
    let (left, right) = arr.splitAt(3)

    println("Left slice: ${left}")
    println("Right slice: ${right}")

    // 验证切片是原数组的引用
    left[0] = -1
    println("After modifying left slice:")
    println("Original array: ${arr}")
    println("Left slice: ${left}")
    println("Right slice: ${right}")
}
```

运行结果：

```text
Original array: [0, 1, 2, 3, 4, 5]
Left slice: [0, 1, 2]
Right slice: [3, 4, 5]
After modifying left slice:
Original array: [-1, 1, 2, 3, 4, 5]
Left slice: [-1, 1, 2]
Right slice: [3, 4, 5]
```

<!--Del-->
### func step(Int64)

```cangjie
public func step(count: Int64): Array<T>
```

功能：以指定的间隔从数组中提取元素，并返回一个新数组。

当 count 小于等于 0 时，抛出异常

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- count: [Int64](core_package_intrinsics.md#int64) - 选取的间隔

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 一个新的数组，包含了按间隔从源数组中提取出的所有元素。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 count <= 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    println("原数组: ${arr}")

    // 以步长为3提取元素
    let stepped3 = arr.step(3)
    println("步长为3提取的元素: ${stepped3}")
    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
步长为3提取的元素: [1, 4, 7, 10]
```

<!--DelEnd-->
### func swap(Int64, Int64)

```cangjie
public func swap(index1: Int64, index2: Int64): Unit
```

功能：交换指定位置的两个元素。

如果 index1 和 index2 指向同一个位置，将不做交换。

参数：

- index1: [Int64](core_package_intrinsics.md#int64) - 需要交换的两个元素的下标之一，取值范围为 [0, this.size)。
- index2: [Int64](core_package_intrinsics.md#int64) - 需要交换的两个元素的下标之一，取值范围为 [0, this.size)。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - index1 / index2 小于 0 或大于等于 this.size。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 交换索引1和索引3的元素
    arr.swap(1, 3)

    println("After swapping indices 1 and 3: ${arr}")

    // 交换相同索引的元素（应该没有变化）
    arr.swap(2, 2)

    println("After swapping index 2 with itself: ${arr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
After swapping indices 1 and 3: [1, 4, 3, 2, 5]
After swapping index 2 with itself: [1, 4, 3, 2, 5]
```

<!--Del-->
### func take(Int64)

```cangjie
public func take(count: Int64): Array<T>
```

功能： 从数组取出特定个数元素并返回一个新数组。

当 count 小于等于 0 时，抛出异常。当 count 等于 0 时，不取元素，返回空数组。当 count 大于 0 小于源数组的大小时，取前 count 个元素，返回新数组。当 count 大于等于数组的大小时，取所有元素，返回新数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

参数：

- count: [Int64](core_package_intrinsics.md#int64) - 要取出的个数。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 返回一个取出指定数量元素的新数组。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 count < 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 6, 7, 8]

    println("原数组: ${arr}")

    // 取前3个元素
    let taken = arr.take(3)
    println("取前3个元素: ${taken}")

    // 取超过数组长度的元素（返回整个数组）
    let takeAll = arr.take(10)
    println("取前10个元素: ${takeAll}")

    return 0
}
```

运行结果：

```text
原数组: [1, 2, 3, 4, 5, 6, 7, 8]
取前3个元素: [1, 2, 3]
取前10个元素: [1, 2, 3, 4, 5, 6, 7, 8]
```

<!--DelEnd-->
### operator func \[](Int64)

```cangjie
public operator func [](index: Int64): T
```

功能：获取数组下标 index 对应的值。

该函数中如果 index 越界，将抛出异常。

也可以通过 get 函数获取数组指定下标的元素，get 函数将在 index 越界时返回 None。

参数：

- index: [Int64](core_package_intrinsics.md#int64) - 要获取的值的下标，取值范围为 [0, [Int64](core_package_intrinsics.md#int64).Max]。

返回值：

- T - 数组中下标 index 对应的值。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 index 小于 0，或大于等于数组长度，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [10, 20, 30, 40, 50]

    println("Array: ${arr}")

    // 获取索引为2的元素
    let element = arr[2]

    println("Element at index 2: ${element}")
}
```

运行结果：

```text
Array: [10, 20, 30, 40, 50]
Element at index 2: 30
```

### operator func \[](Int64, T)

```cangjie
public operator func [](index: Int64, value!: T): Unit
```

功能：修改数组中下标 index 对应的值。

参数：

- index: [Int64](core_package_intrinsics.md#int64) - 需要修改值的下标，取值范围为 [0, [Int64](core_package_intrinsics.md#int64).Max]。
- value!: T - 修改的目标值。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 index 小于 0，或大于等于数组长度，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 修改索引为2的元素
    arr[2] = 100

    println("Array after setting index 2 to 100: ${arr}")

    // 修改索引为0的元素
    arr[0] = -1

    println("Array after setting index 0 to -1: ${arr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
Array after setting index 2 to 100: [1, 2, 100, 4, 5]
Array after setting index 0 to -1: [-1, 2, 100, 4, 5]
```

### operator func \[](Range\<Int64>)

```cangjie
public operator func [](range: Range<Int64>): Array<T>
```

功能：根据给定区间获取数组切片。

> **注意：**
>
> 1. 如果参数 range 是使用 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 构造函数构造的 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例，有如下行为：
>    - start 的值就是构造函数传入的值本身，不受构造时传入的 hasStart 的值的影响。
>    - hasEnd 为 false 时，end 值不生效，且不受构造时传入的 isClosed 的值的影响，该数组切片取到原数组最后一个元素。
> 2. range 的步长只能为 1。

参数：

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - 切片的范围，range 表示的范围不能超过数组范围。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 数组切片。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 range 的步长不等于 1，抛出异常。
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 range 表示的数组范围无效，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let slice = arr[1..4]
    arr[3] = 10
    println(slice)
}
```

运行结果：

```text
[1, 2, 10]
```

### operator func \[](Range\<Int64>, Array\<T>)

```cangjie
public operator func [](range: Range<Int64>, value!: Array<T>): Unit
```

功能：用指定的数组对本数组一个连续范围的元素赋值。

range 表示的区见的长度和目标数组 value 的大小需相等。

> **注意：**
>
> 1. 如果参数 range 是使用 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 构造函数构造的 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例，有如下行为：
>    - start 的值就是构造函数传入的值本身，不受构造时传入的 hasStart 的值的影响。
>    - hasEnd 为 false 时，end 值不生效，且不受构造时传入的 isClosed 的值的影响，该数组切片取到原数组最后一个元素。
> 2. range 的步长只能为 1。

参数：

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - 需要修改的数组范围，range 表示的范围不能超过数组范围。
- value!: [Array](core_package_structs.md#struct-arrayt)\<T> - 修改的目标值。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 range 的步长不等于 1，或 range 长度不等于 value 长度，抛出异常。
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 range 表示的数组范围无效，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    arr[1..3] = [10, 11]
    println(arr)
}
```

运行结果：

```text
[0, 10, 11, 3, 4, 5]
```

### extend\<T> Array\<Array\<T>>

```cangjie
extend<T> Array<Array<T>>
```

功能：为二维数组进行扩展，提供将其展开为一维数组的方法。

#### func flatten()

```cangjie
public func flatten(): Array<T>
```

功能：将当前二维数组展开为一维数组。

例如将 [[1, 2], [3, 4]] 展开为 [1, 2, 3, 4]。

返回值：

- [Array](./core_package_structs.md#struct-arrayt)\<T> - 展开后的一维数组。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [[1, 2], [3, 4]].flatten()
    println(arr)
    return 0
}
```

运行结果：

```text
[1, 2, 3, 4]
```

<!--Del-->
### extend\<T> Array\<T>

```cangjie
extend<T> Array<T>
```

功能：为 [Array](core_package_structs.md#struct-arrayt)\<T> 类型进行拓展

#### func enumerate()

```cangjie
public func enumerate(): Array<(Int64, T)>
```

功能：用于获取带索引的数组。

> **注意：**
>
> 不支持平台：OpenHarmony。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<([Int64](../../core/core_package_api/core_package_intrinsics.md#int64), T)> - 返回一个带索引的新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = ["apple", "banana", "cherry"]

    println("原数组: ${arr}")

    // 使用enumerate获取带索引的数组
    let enumerated = arr.enumerate()

    // 遍历带索引的数组
    println("遍历带索引的数组:")
    for (pair in enumerated) {
        let (index, value) = pair
        println(" (${index}, ${value})")
    }
    return 0
}
```

运行结果：

```text
原数组: [apple, banana, cherry]
遍历带索引的数组:
 (0, apple)
 (1, banana)
 (2, cherry)
```

#### func zip\<R>(Array\<R>)

```cangjie
public func zip<R>(other: Array<R>): Array<(T, R)>
```

功能：将两个数组合并成一个新数组（长度取决于短的那个数组）。

参数：

- other: [Array](core_package_structs.md#struct-arrayt)\<R> - 要合并的其中一个数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<(T, R)> - 返回一个新数组。

示例：

<!-- verify -->
```cangjie
main() {
    let arr1 = [1, 2, 3, 4]
    let arr2 = ["apple", "banana", "cherry", "date"]

    println("数组1: ${arr1}")
    println("数组2: ${arr2}")

    // 使用zip合并两个数组
    let zipped = arr1.zip(arr2)
    println("合并后的数组:")
    for (pair in zipped) {
        let (index, value) = pair
        println(" (${index}, ${value})")
    }
    return 0
}
```

运行结果：

```text
数组1: [1, 2, 3, 4]
数组2: [apple, banana, cherry, date]
合并后的数组:
 (1, apple)
 (2, banana)
 (3, cherry)
 (4, date)
```

<!--DelEnd-->
### extend\<T> Array\<T> <: Collection\<T>

```cangjie
extend<T> Array<T> <: Collection<T>
```

功能：为 [Array](core_package_structs.md#struct-arrayt)\<T> 类型实现 [Collection](core_package_interfaces.md#interface-collectiont) 接口。

父类型：

- [Collection](core_package_interfaces.md#interface-collectiont)\<T>

#### prop size

```cangjie
public prop size: Int64
```

功能：获取元素数量。

类型：[Int64](core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Array: ${arr}")
    println("Size of array: ${arr.size}")

    // 创建一个空数组
    let emptyArr: Array<Int64> = []

    println("Empty array: ${emptyArr}")
    println("Size of empty array: ${emptyArr.size}")

    // 创建一个包含字符串的数组
    let strArr = ["Hello", "World", "Cangjie", "Language"]

    println("String array: ${strArr}")
    println("Size of string array: ${strArr.size}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 5]
Size of array: 5
Empty array: []
Size of empty array: 0
String array: [Hello, World, Cangjie, Language]
Size of string array: 4
```

#### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

功能：判断数组是否为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果数组为空，返回 true，否则，返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Array: ${arr}")
    println("Is array empty? ${arr.isEmpty()}")

    // 创建一个空数组
    let emptyArr: Array<Int64> = []

    println("Empty array: ${emptyArr}")
    println("Is empty array empty? ${emptyArr.isEmpty()}")

    // 创建一个包含字符串的数组
    let strArr = ["Hello", "World"]

    println("String array: ${strArr}")
    println("Is string array empty? ${strArr.isEmpty()}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 5]
Is array empty? false
Empty array: []
Is empty array empty? true
String array: [Hello, World]
Is string array empty? false
```

#### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

功能：获取当前数组的迭代器，用于遍历数组。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<T> - 当前数组的迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Array: ${arr}")

    // 获取数组的迭代器
    let iter = arr.iterator()

    println("Using iterator to traverse the array:")

    // 使用迭代器遍历数组
    while (true) {
        match (iter.next()) {
            case Some(value) => println("Element: ${value}")
            case None => break
        }
    }

    // 创建另一个数组并演示迭代器的其他用法
    let arr2 = ["Hello", "World", "Cangjie"]
    let iter2 = arr2.iterator()

    println("\nSecond array: ${arr2}")
    println("Using iterator with for-in loop:")

    // 也可以使用for-in循环遍历迭代器
    for (element in iter2) {
        println("Element: ${element}")
    }
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 5]
Using iterator to traverse the array:
Element: 1
Element: 2
Element: 3
Element: 4
Element: 5

Second array: [Hello, World, Cangjie]
Using iterator with for-in loop:
Element: Hello
Element: World
Element: Cangjie
```

#### func toArray()

```cangjie
public func toArray(): Array<T>
```

功能：根据当前 [Array](core_package_structs.md#struct-arrayt) 实例拷贝一个新的 [Array](core_package_structs.md#struct-arrayt) 实例。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 拷贝得到的新的 [Array](core_package_structs.md#struct-arrayt) 实例。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]

    println("Original array: ${arr}")

    // 使用toArray()方法创建数组的副本
    let copiedArr = arr.toArray()

    println("Copied array: ${copiedArr}")

    // 验证拷贝后的数组是独立的
    copiedArr[0] = 10
    println("After modifying copied array:")
    println("Original array: ${arr}")
    println("Copied array: ${copiedArr}")

    // 创建一个包含字符串的数组并测试toArray()
    let strArr = ["Hello", "World", "Cangjie"]
    let copiedStrArr = strArr.toArray()

    println("\nString array: ${strArr}")
    println("Copied string array: ${copiedStrArr}")

    // 验证拷贝后的字符串数组是独立的
    copiedStrArr[0] = "Hi"
    println("After modifying copied string array:")
    println("Original string array: ${strArr}")
    println("Copied string array: ${copiedStrArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5]
Copied array: [1, 2, 3, 4, 5]
After modifying copied array:
Original array: [1, 2, 3, 4, 5]
Copied array: [10, 2, 3, 4, 5]

String array: [Hello, World, Cangjie]
Copied string array: [Hello, World, Cangjie]
After modifying copied string array:
Original string array: [Hello, World, Cangjie]
Copied string array: [Hi, World, Cangjie]
```

### extend\<T> Array\<T> <: Equatable\<Array\<T>> where T <: Equatable\<T>

```cangjie
extend<T> Array<T> <: Equatable<Array<T>> where T <: Equatable<T>
```

功能：为 [Array](core_package_structs.md#struct-arrayt)\<T> 类型扩展 [Equatable](core_package_interfaces.md#interface-equatablet)\<[Array](core_package_structs.md#struct-arrayt)\<T>> 接口实现，支持判等操作。

父类型：

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Array](#struct-arrayt)\<T>>

#### func contains(T)

```cangjie
public func contains(element: T): Bool
```

功能：查找当前数组是否包含指定元素。

参数：

- element: T - 需要查找的目标元素。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果存在，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4]
    println(arr.contains(1))
    return 0
}
```

运行结果：

```text
true
```

#### func indexOf(Array\<T>)

```cangjie
public func indexOf(elements: Array<T>): Option<Int64>
```

功能：返回数组中子数组 `elements` 出现的第一个位置，如果数组中不包含此数组，返回 None。

> **注意：**
>
> 当 T 的类型是 [Int64](core_package_intrinsics.md#int64) 时，此函数的变长参数语法糖版本可能会和 `public func indexOf(element: T, fromIndex: Int64): Option<Int64>` 产生歧义，根据优先级，当参数数量是 2 个时，会优先调用 `public func indexOf(element: T, fromIndex: Int64): Option<Int64>`。

参数：

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - 需要定位的目标数组。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 数组中子数组 `elements` 出现的第一个位置，如果数组中不包含此数组，返回 None。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4]
    let subArr = [2, 3]
    println(arr.indexOf(subArr))
    return 0
}
```

运行结果：

```text
Some(1)
```

#### func indexOf(Array\<T>, Int64)

```cangjie
public func indexOf(elements: Array<T>, fromIndex: Int64): Option<Int64>
```

功能：返回数组中在 `fromIndex`之后，子数组`elements` 出现的第一个位置，未找到返回 None。

函数会对 `fromIndex` 范围进行检查，`fromIndex` 小于 0 时，将会从第 0 位开始搜索，当 `fromIndex` 大于等于本数组的大小时，结果为 None。

参数：

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - 需要定位的元素。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 开始搜索的起始位置。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 数组中在 `fromIndex`之后，子数组 `elements` 出现的第一个位置，未找到返回 None。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4, 2, 3]
    let subArr = [2, 3]
    println(arr.indexOf(subArr, 3))
    return 0
}
```

运行结果：

```text
Some(4)
```

#### func indexOf(T)

```cangjie
public func indexOf(element: T): Option<Int64>
```

功能：获取数组中 `element` 出现的第一个位置，如果数组中不包含此元素，返回 None。

参数：

- element: T - 需要定位的元素。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 数组中 `element` 出现的第一个位置，如果数组中不包含此元素，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5]

    println("Array: ${arr}")

    // 查找元素2第一次出现的位置
    let index1 = arr.indexOf(2)
    println("First occurrence of 2: ${index1}")

    // 查找元素6第一次出现的位置（不存在）
    let index2 = arr.indexOf(6)
    println("First occurrence of 6: ${index2}")

    // 创建一个包含字符串的数组并测试indexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie"]

    println("\nString array: ${strArr}")

    // 查找字符串"Hello"第一次出现的位置
    let strIndex1 = strArr.indexOf("Hello")
    println("First occurrence of \"Hello\": ${strIndex1}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 2, 5]
First occurrence of 2: Some(1)
First occurrence of 6: None

String array: [Hello, World, Hello, Cangjie]
First occurrence of "Hello": Some(0)
```

#### func indexOf(T, Int64)

```cangjie
public func indexOf(element: T, fromIndex: Int64): Option<Int64>
```

功能：返回数组中在 `fromIndex`之后， `element` 出现的第一个位置，未找到返回 None。

函数会从下标 `fromIndex` 开始查找，`fromIndex` 小于 0 时，将会从第 0 位开始搜索，当 `fromIndex` 大于等于本数组的大小时，结果为 None。

参数：

- element: T - 需要定位的元素。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 查找的起始位置。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 返回数组中在 `fromIndex`之后， `element` 出现的第一个位置，未找到返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5]

    println("Array: ${arr}")

    // 从索引2开始查找元素2第一次出现的位置
    let index1 = arr.indexOf(2, 2)
    println("First occurrence of 2 starting from index 2: ${index1}")

    // 从索引5开始查找元素2第一次出现的位置（不存在）
    let index2 = arr.indexOf(2, 5)
    println("First occurrence of 2 starting from index 5: ${index2}")

    // 创建一个包含字符串的数组并测试indexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie"]

    println("\nString array: ${strArr}")

    // 从索引1开始查找字符串"Hello"第一次出现的位置
    let strIndex = strArr.indexOf("Hello", 1)
    println("First occurrence of \"Hello\" starting from index 1: ${strIndex}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 2, 5]
First occurrence of 2 starting from index 2: Some(4)
First occurrence of 2 starting from index 5: None

String array: [Hello, World, Hello, Cangjie]
First occurrence of "Hello" starting from index 1: Some(2)
```

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4, 2, 3]
    let subArr = [2, 3]
    println(arr.lastIndexOf(subArr, 3))
    return 0
}
```

运行结果：

```text
Some(4)
```

#### func lastIndexOf(Array\<T>)

```cangjie
public func lastIndexOf(elements: Array<T>): Option<Int64>
```

功能：返回数组中子数组 `elements` 出现的最后一个位置，如果数组中不存在此子数组，返回 None。

参数：

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - 需要定位的目标数组。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 数组中 `elements` 出现的最后一个位置，如果数组中不存在此子数组，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 2, 3, 4, 2, 3]
    let subArr = [2, 3]

    println("Array: ${arr}")
    println("Sub-array: ${subArr}")

    // 查找子数组[2, 3]最后一次出现的位置
    let lastIndex = arr.lastIndexOf(subArr)
    println("Last occurrence of [2, 3]: ${lastIndex}")

    // 查找不存在的子数组
    let notExist = [5, 6]
    let notExistIndex = arr.lastIndexOf(notExist)
    println("Last occurrence of [5, 6]: ${notExistIndex}")
}
```

运行结果：

```text
Array: [1, 2, 3, 2, 3, 4, 2, 3]
Sub-array: [2, 3]
Last occurrence of [2, 3]: Some(6)
Last occurrence of [5, 6]: None
```

#### func lastIndexOf(Array\<T>, Int64)

```cangjie
public func lastIndexOf(elements: Array<T>, fromIndex: Int64): Option<Int64>
```

功能：从 `fromIndex` 开始向后搜索，返回数组中子数组 `elements` 出现的最后一个位置，如果数组中不存在此子数组，返回 None。

函数会对 `fromIndex` 范围进行检查，`fromIndex` 小于 0 时，将会从第 0 位开始搜索，当 `fromIndex` 大于等于本数组的大小时，结果为 None。

参数：

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - 需要定位的目标数组。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 搜索开始的位置。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 从 `fromIndex` 开始向后搜索，数组中子数组 `elements` 出现的最后一个位置，如果数组中不存在此子数组，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 2, 3, 4, 3, 3]
    let subArr = [2, 3]

    println("Array: ${arr}")
    println("Sub-array: ${subArr}")

    // 从索引4开始向后搜索，查找子数组[2, 3]最后一次出现的位置
    let lastIndex = arr.lastIndexOf(subArr, 4)
    println("Last occurrence of [2, 3] starting from index 4: ${lastIndex}")

    // 从索引2开始向后搜索，查找子数组[2, 3]最后一次出现的位置
    let lastIndex2 = arr.lastIndexOf(subArr, 2)
    println("Last occurrence of [2, 3] starting from index 2: ${lastIndex2}")
}
```

运行结果：

```text
Array: [1, 2, 3, 2, 3, 4, 3, 3]
Sub-array: [2, 3]
Last occurrence of [2, 3] starting from index 4: None
Last occurrence of [2, 3] starting from index 2: Some(3)
```

#### func lastIndexOf(T)

```cangjie
public func lastIndexOf(element: T): Option<Int64>
```

功能：返回数组中 `element` 出现的最后一个位置，如果数组中不存在此元素，返回 None。

参数：

- element: T - 需要定位的目标元素。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 数组中 `element` 出现的最后一个位置，如果数组中不存在此元素，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5, 2]

    println("Array: ${arr}")

    // 查找元素2最后一次出现的位置
    let lastIndex = arr.lastIndexOf(2)
    println("Last occurrence of 2: ${lastIndex}")

    // 查找元素6最后一次出现的位置（不存在）
    let notExistIndex = arr.lastIndexOf(6)
    println("Last occurrence of 6: ${notExistIndex}")

    // 创建一个包含字符串的数组并测试lastIndexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie", "Hello"]

    println("\nString array: ${strArr}")

    // 查找字符串"Hello"最后一次出现的位置
    let strLastIndex = strArr.lastIndexOf("Hello")
    println("Last occurrence of \"Hello\": ${strLastIndex}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 2, 5, 2]
Last occurrence of 2: Some(6)
Last occurrence of 6: None

String array: [Hello, World, Hello, Cangjie, Hello]
Last occurrence of "Hello": Some(4)
```

#### func lastIndexOf(T, Int64)

```cangjie
public func lastIndexOf(element: T, fromIndex: Int64): Option<Int64>
```

功能：从 `fromIndex` 开始向后搜索，返回数组中 `element` 出现的最后一个位置，如果数组中不存在此元素，返回 None。

函数会对 `fromIndex` 范围进行检查，`fromIndex` 小于 0 时，将会从第 0 位开始搜索，当 `fromIndex` 大于等于本数组的大小时，结果为 None。

参数：

- element: T - 需要定位的目标元素。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 搜索开始的位置。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 从 `fromIndex` 开始向后搜索，返回数组中 `element` 出现的最后一个位置，如果数组中不存在此元素，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5, 3]

    println("Array: ${arr}")

    // 从索引5开始向后搜索，查找元素2最后一次出现的位置
    let lastIndex = arr.lastIndexOf(2, 5)
    println("Last occurrence of 2 starting from index 5: ${lastIndex}")

    // 从索引3开始向后搜索，查找元素2最后一次出现的位置
    let lastIndex2 = arr.lastIndexOf(2, 3)
    println("Last occurrence of 2 starting from index 3: ${lastIndex2}")

    // 创建一个包含字符串的数组并测试lastIndexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie", "Hello"]

    println("\nString array: ${strArr}")

    // 从索引2开始向后搜索，查找字符串"Hello"最后一次出现的位置
    let strLastIndex = strArr.lastIndexOf("Hello", 2)
    println("Last occurrence of \"Hello\" starting from index 2: ${strLastIndex}")
}
```

运行结果：

```text
Array: [1, 2, 3, 4, 2, 5, 3]
Last occurrence of 2 starting from index 5: None
Last occurrence of 2 starting from index 3: Some(4)

String array: [Hello, World, Hello, Cangjie, Hello]
Last occurrence of "Hello" starting from index 2: Some(4)
```

#### func removePrefix(Array\<T>)

```cangjie
public func removePrefix(prefix: Array<T>): Array<T>
```

功能：删除前缀。

如果当前数组开头与 prefix 完全匹配，删除其前缀。返回值为当前数组删除前缀后得到的切片。

参数：

- prefix: [Array](./core_package_structs.md#struct-arrayt)\<T> - 待删除的前缀。

返回值：

- [Array](./core_package_structs.md#struct-arrayt)\<T> - 删除前缀后得到的原数组切片。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 1, 2, 3].removePrefix([1, 2])
    println(arr)
    return 0
}
```

运行结果：

```text
[1, 2, 3]
```

#### func removeSuffix(Array\<T>)

```cangjie
public func removeSuffix(suffix: Array<T>): Array<T>
```

功能：删除后缀。

如果当前数组结尾与 suffix 完全匹配，删除其后缀。返回值为当前数组删除后缀后得到的切片。

参数：

- suffix: [Array](./core_package_structs.md#struct-arrayt)\<T> - 待删除的后缀。

返回值：

- [Array](./core_package_structs.md#struct-arrayt)\<T> - 删除后缀后得到的原数组切片。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 2, 3].removeSuffix([2, 3])
    println(arr)
    return 0
}
```

运行结果：

```text
[1, 2, 3]
```

#### func trimEnd((T)->Bool)

```cangjie
public func trimEnd(predicate: (T)->Bool): Array<T>
```

功能：修剪当前数组，从尾开始删除符合过滤条件的函数，直到第一个不符合的元素为止，并返回当前数组的切片。

参数：

- predicate: (T)->[Bool](./core_package_intrinsics.md#bool) - 过滤条件。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 修剪后的数组切片。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 4, 3, 2, 1]

    println("Original array: ${arr}")

    // 从尾部开始删除所有小于4的元素
    let trimmedArr = arr.trimEnd({x => x < 4})
    println("Array after trimming elements less than 4 from the end: ${trimmedArr}")

    // 创建一个包含字符串的数组并测试trimEnd
    let strArr = ["a", "b", "c", "d", "c", "b", "a"]

    println("\nString array: ${strArr}")

    // 从尾部开始删除所有不等于"c"的元素
    let trimmedStrArr = strArr.trimEnd({s => s != "c"})
    println("String array after trimming elements not equal to \"c\" from the end: ${trimmedStrArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5, 4, 3, 2, 1]
Array after trimming elements less than 4 from the end: [1, 2, 3, 4, 5, 4]

String array: [a, b, c, d, c, b, a]
String array after trimming elements not equal to "c" from the end: [a, b, c, d, c]
```

#### func trimEnd(Array\<T>)

```cangjie
public func trimEnd(set: Array<T>): Array<T>
```

功能：修剪当前数组，从尾开始删除在指定集合 set 中的元素，直到第一个不在 set 中的元素为止，并返回当前数组的切片。

参数：

- set: [Array](core_package_structs.md#struct-arrayt)\<T> - 待删除的元素的集合。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 修剪后的数组切片。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [2, 1, 2, 2, 3].trimEnd([2, 3])
    println(arr)
    return 0
}
```

运行结果：

```text
[2, 1]
```

#### func trimStart((T)->Bool)

```cangjie
public func trimStart(predicate: (T)->Bool): Array<T>
```

功能：修剪当前数组，从头开始删除符合过滤条件的函数，直到第一个不符合的元素为止，并返回当前数组的切片。

参数：

- predicate: (T)->[Bool](./core_package_intrinsics.md#bool) - 过滤条件。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 修剪后的数组切片。

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 4, 3, 2, 1]

    println("Original array: ${arr}")

    // 从头部开始删除所有小于4的元素
    let trimmedArr = arr.trimStart({x => x < 4})
    println("Array after trimming elements less than 4 from the start: ${trimmedArr}")

    // 创建一个包含字符串的数组并测试trimStart
    let strArr = ["a", "b", "c", "d", "c", "b", "a"]

    println("\nString array: ${strArr}")

    // 从头部开始删除所有不等于"c"的元素
    let trimmedStrArr = strArr.trimStart({s => s != "c"})
    println("String array after trimming elements not equal to \"c\" from the start: ${trimmedStrArr}")
}
```

运行结果：

```text
Original array: [1, 2, 3, 4, 5, 4, 3, 2, 1]
Array after trimming elements less than 4 from the start: [4, 5, 4, 3, 2, 1]

String array: [a, b, c, d, c, b, a]
String array after trimming elements not equal to "c" from the start: [c, d, c, b, a]
```

#### func trimStart(Array\<T>)

```cangjie
public func trimStart(set: Array<T>): Array<T>
```

功能：修剪当前数组，从头开始删除在指定集合 set 中的元素，直到第一个不在 set 中的元素为止，并返回当前数组的切片。

参数：

- set: [Array](core_package_structs.md#struct-arrayt)\<T> - 待删除的元素的集合。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<T> - 修剪后的数组切片。

示例：

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 1, 3, 1].trimStart([1, 2])
    println(arr)
    return 0
}
```

运行结果：

```text
[3, 1]
```

#### operator func !=(Array\<T>)

```cangjie
public operator const func !=(other: Array<T>): Bool
```

功能：判断当前实例与指定 [Array](core_package_structs.md#struct-arrayt)\<T> 实例是否不等。

参数：

- other: [Array](core_package_structs.md#struct-arrayt)\<T> - 用于与当前实例比较的另一个 [Array](core_package_structs.md#struct-arrayt)\<T> 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果不相等，则返回 true；相等则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let arr1 = [1, 2, 3, 4, 5]
    let arr2 = [1, 2, 3, 4, 5]
    let arr3 = [1, 2, 3, 4, 6]
    let arr4 = [1, 2, 3]

    println("Array 1: ${arr1}")
    println("Array 2: ${arr2}")
    println("Array 3: ${arr3}")
    println("Array 4: ${arr4}")

    // 比较相等的数组
    println("arr1 != arr2: ${arr1 != arr2}")

    // 比较不相等的数组（元素不同）
    println("arr1 != arr3: ${arr1 != arr3}")

    // 比较不相等的数组（长度不同）
    println("arr1 != arr4: ${arr1 != arr4}")

    // 创建包含字符串的数组并测试!=操作符
    let strArr1 = ["Hello", "World"]
    let strArr2 = ["Hello", "World"]
    let strArr3 = ["Hello", "Cangjie"]

    println("\nString array 1: ${strArr1}")
    println("String array 2: ${strArr2}")
    println("String array 3: ${strArr3}")

    // 比较相等的字符串数组
    println("strArr1 != strArr2: ${strArr1 != strArr2}")

    // 比较不相等的字符串数组
    println("strArr1 != strArr3: ${strArr1 != strArr3}")
}
```

运行结果：

```text
Array 1: [1, 2, 3, 4, 5]
Array 2: [1, 2, 3, 4, 5]
Array 3: [1, 2, 3, 4, 6]
Array 4: [1, 2, 3]
arr1 != arr2: false
arr1 != arr3: true
arr1 != arr4: true

String array 1: [Hello, World]
String array 2: [Hello, World]
String array 3: [Hello, Cangjie]
strArr1 != strArr2: false
strArr1 != strArr3: true
```

#### operator func ==(Array\<T>)

```cangjie
public operator const func ==(other: Array<T>): Bool
```

功能：判断当前实例与指定 [Array](core_package_structs.md#struct-arrayt)\<T> 实例是否相等。

两个 [Array](core_package_structs.md#struct-arrayt)\<T> 相等指的是其中的每个元素都相等。

参数：

- other: [Array](core_package_structs.md#struct-arrayt)\<T> - 用于与当前实例比较的另一个 [Array](core_package_structs.md#struct-arrayt)\<T> 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果相等，则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    let arr1 = [1, 2, 3, 4, 5]
    let arr2 = [1, 2, 3, 4, 5]
    let arr3 = [1, 2, 3, 4, 6]
    let arr4 = [1, 2, 3]

    println("Array 1: ${arr1}")
    println("Array 2: ${arr2}")
    println("Array 3: ${arr3}")
    println("Array 4: ${arr4}")

    // 比较相等的数组
    println("arr1 == arr2: ${arr1 == arr2}")

    // 比较不相等的数组（元素不同）
    println("arr1 == arr3: ${arr1 == arr3}")

    // 比较不相等的数组（长度不同）
    println("arr1 == arr4: ${arr1 == arr4}")

    // 创建包含字符串的数组并测试==操作符
    let strArr1 = ["Hello", "World"]
    let strArr2 = ["Hello", "World"]
    let strArr3 = ["Hello", "Cangjie"]

    println("\nString array 1: ${strArr1}")
    println("String array 2: ${strArr2}")
    println("String array 3: ${strArr3}")

    // 比较相等的字符串数组
    println("strArr1 == strArr2: ${strArr1 == strArr2}")

    // 比较不相等的字符串数组
    println("strArr1 == strArr3: ${strArr1 == strArr3}")
}
```

运行结果：

```text
Array 1: [1, 2, 3, 4, 5]
Array 2: [1, 2, 3, 4, 5]
Array 3: [1, 2, 3, 4, 6]
Array 4: [1, 2, 3]
arr1 == arr2: true
arr1 == arr3: false
arr1 == arr4: false

String array 1: [Hello, World]
String array 2: [Hello, World]
String array 3: [Hello, Cangjie]
strArr1 == strArr2: true
strArr1 == strArr3: false
```

### extend\<T> Array\<T> where T <: ToString

```cangjie
extend<T> Array<T> <: ToString where T <: ToString
```

功能：为 [Array](core_package_structs.md#struct-arrayt)\<T> 类型扩展 [ToString](core_package_interfaces.md#interface-tostring) 接口，支持转字符串操作。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

功能：将数组转换为可输出的字符串。

字符串形如 "[1, 2, 3, 4, 5]"

返回值：

- [String](core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    let arr1 = [1, 2, 3, 4, 5]
    let arr2: Array<Int64> = []
    let arr3 = ["Hello", "World", "Cangjie"]

    println("Integer array: ${arr1}")
    println("toString() result: ${arr1.toString()}")

    println("\nEmpty array: ${arr2}")
    println("toString() result: ${arr2.toString()}")

    println("\nString array: ${arr3}")
    println("toString() result: ${arr3.toString()}")

    // 创建二维数组并测试toString()
    let arr4 = [[1, 2], [3, 4], [5, 6]]

    println("\n2D array: ${arr4}")
    println("toString() result: ${arr4.toString()}")
}
```

运行结果：

```text
Integer array: [1, 2, 3, 4, 5]
toString() result: [1, 2, 3, 4, 5]

Empty array: []
toString() result: []

String array: [Hello, World, Cangjie]
toString() result: [Hello, World, Cangjie]

2D array: [[1, 2], [3, 4], [5, 6]]
toString() result: [[1, 2], [3, 4], [5, 6]]
```

## struct CPointerHandle\<T> where T <: CType

```cangjie
public struct CPointerHandle<T> where T <: CType {
    public let pointer: CPointer<T>
    public let array: Array<T>
    public init()
    public init(ptr: CPointer<T>, arr: Array<T>)
}
```

功能：表示 [Array](core_package_structs.md#struct-arrayt) 数组的原始指针，该类型中的泛型参数应该满足 [CType](core_package_interfaces.md#interface-ctype) 约束。

### let array

```cangjie
public let array: Array<T>
```

功能：原始指针对应的 [Array](core_package_structs.md#struct-arrayt) 数组实例。

类型：[Array](core_package_structs.md#struct-arrayt)\<T>

示例：

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    // 通过acquireArrayRawData获得一个CPointerHandle实例
    let handle = unsafe { acquireArrayRawData(arr) }

    // 获取array本身
    let arrItself = handle.array
    // 修改一处，同时查看是否是同一个array
    arrItself[0] = 2

    // 查看数值
    println("数值是${arrItself}, 确实是原来的数组")
}
```

运行结果：

```text
数值是[2, 2, 3, 4, 5], 确实是原来的数组
```

### let pointer

```cangjie
public let pointer: CPointer<T>
```

功能：获取指定 [Array](core_package_structs.md#struct-arrayt) 数组对应的原始指针。

类型：[CPointer](core_package_intrinsics.md#cpointert)\<T>

示例：

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> = [1, 2, 3, 4]
    // 获取CPointerHandle
    let cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    // 获取pointer
    let cptr: CPointer<Int64> = cptrHandle.pointer

    // 获取指针下标的元素的值，这里获取第三个元素的值
    let num: Int64 = unsafe { cptr.read(2) }
    println("The third element of the array is ${num} ")

    // 释放CPointerHandle
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

运行结果：

```text
The third element of the array is 3
```

### init() <sup>(deprecated)</sup>

```cangjie
public init()
```

功能：构造一个默认 [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype) 实例，其中原始指针为空指针，仓颉数组为空数组。

> **注意：**
>
> 未来版本即将废弃，可使用 [acquireArrayRawData](./core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype) 函数构造 CPointerHandle 实例。

示例：

<!-- verify -->
```cangjie
main() {
    // 注意：此构造函数已被标记为废弃，未来版本将不再使用
    let handle = CPointerHandle<Int64>()

    println("Created a default CPointerHandle instance")
    println("The raw pointer is null and the Cangjie array is empty")

    // 在实际使用中，推荐使用acquireArrayRawData函数来创建CPointerHandle实例
}
```

运行结果：

```text
Created a default CPointerHandle instance
The raw pointer is null and the Cangjie array is empty
```

### init(CPointer\<T>, Array\<T>) <sup>(deprecated)</sup>

```cangjie
public init(ptr: CPointer<T>, arr: Array<T>)
```

功能：通过传入的 [CPointer](core_package_intrinsics.md#cpointert) 和 [Array](core_package_structs.md#struct-arrayt) 初始化一个 [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype)。

> **注意：**
>
> 未来版本即将废弃，可使用 [acquireArrayRawData](./core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype) 函数构造 CPointerHandle 实例。

参数：

- ptr: [CPointer](core_package_intrinsics.md#cpointert)\<T> - 数组原始指针。
- arr: [Array](core_package_structs.md#struct-arrayt)\<T> - 指针对应的仓颉数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个整数数组
    let arr = [1, 2, 3, 4, 5]

    // 创建一个指针
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }

    // 通过传入指针和数组初始化一个CPointerHandle实例
    // 注意：此构造函数已被标记为废弃，未来版本将不再使用
    // 在实际使用中，推荐使用acquireArrayRawData函数来创建CPointerHandle实例
    let handle = CPointerHandle(ptr, arr)

    // 通过handle获取原array
    let arr1 = handle.array

    // 释放指针
    unsafe { free(p1) }
    println(arr1)
}

foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit
```

运行结果：

```text
[1, 2, 3, 4, 5]
```

## struct CPointerResource\<T> where T <: CType

```cangjie
public struct CPointerResource<T> <: Resource where T <: CType {
    public let value: CPointer<T>
}
```

功能：该结构体表示 [CPointer](core_package_intrinsics.md#cpointert) 对应的资源管理类型，其实例可以通过 [CPointer](core_package_intrinsics.md#cpointert) 的成员函数 `asResource` 获取。

父类型：

- [Resource](core_package_interfaces.md#interface-resource)

### let value

```cangjie
public let value: CPointer<T>
```

功能：表示当前实例管理的 [CPointer](core_package_intrinsics.md#cpointert)\<T> 类型实例。

类型：[CPointer](core_package_intrinsics.md#cpointert)\<T>

示例：

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

main() {
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    unsafe { ptr.write(10) }
    var ptrResource: CPointerResource<Int64> = ptr.asResource()
    try (r = ptrResource) {
        var p = r.value
        let num: Int64 = unsafe { p.read() }
        println(num)
    }
    println(ptrResource.isClosed())
}
```

运行结果：

```text
10
true
```

### func close()

```cangjie
public func close(): Unit
```

功能：释放其管理的 [CPointer](core_package_intrinsics.md#cpointert)\<T> 实例指向的内容。

示例：

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

main() {
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    unsafe { ptr.write(10) }
    var ptrResource: CPointerResource<Int64> = ptr.asResource()
    var p = ptrResource.value
    let num: Int64 = unsafe { p.read() }
    println(num)
    ptrResource.close()
    println(ptrResource.isClosed())
}
```

运行结果：

```text
10
true
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

功能：判断该指针内容是否已被释放。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 返回 true 为已释放。.

示例：

<!-- verify -->
```cangjie
foreign func malloc(size: UIntNative): CPointer<Unit>

main() {
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    unsafe { ptr.write(10) }
    var ptrResource: CPointerResource<Int64> = ptr.asResource()
    try (r = ptrResource) {
        var p = r.value
        let num: Int64 = unsafe { p.read() }
        println(num)
    }
    println(ptrResource.isClosed())
}
```

运行结果：

```text
10
true
```

## struct CStringResource

```cangjie
public struct CStringResource <: Resource {
    public let value: CString
}
```

功能：该结构体表示 [CString](core_package_intrinsics.md#cstring) 对应的资源管理类型，其实例可以通过 [CString](core_package_intrinsics.md#cstring) 的成员函数 `asResource` 获取。

父类型：

- [Resource](core_package_interfaces.md#interface-resource)

### let value

```cangjie
public let value: CString
```

功能：表示当前实例管理的 [CString](core_package_intrinsics.md#cstring) 资源。

类型：[CString](core_package_intrinsics.md#cstring)

示例：

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    // try块结束自动释放ctr
    try (r = ctrResource) {
        println(r.value)
    }
    println(ctrResource.isClosed())
}
```

运行结果：

```text
Hello
true
```

### func close()

```cangjie
public func close(): Unit
```

功能：释放当前实例管理的 [CString](core_package_intrinsics.md#cstring) 类型实例指向的内容。

示例：

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    println(ctrResource.value)
    ctrResource.close()
    println(ctrResource.isClosed())
}
```

运行结果：

```text
Hello
true
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

功能：判断该字符串是否被释放。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 返回 true 为已释放。

示例：

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    // try块结束自动释放ctr
    try (r = ctrResource) {
        println(r.value)
    }
    println(ctrResource.isClosed())
}
```

运行结果：

```text
Hello
true
```

## struct DefaultHasher

```cangjie
public struct DefaultHasher <: Hasher {
    public init(res!: Int64 = 0)
}
```

功能：该结构体提供了默认哈希算法实现。

可以使用一系列 write 函数传入不同数据类型实例，并计算它们的组合哈希值。

父类型：

- [Hasher](core_package_interfaces.md#interface-hasher)

### init(Int64)

```cangjie
public init(res!: Int64 = 0)
```

功能：构造函数，创建一个 [DefaultHasher](core_package_structs.md#struct-defaulthasher)。

参数：

- res!: [Int64](core_package_intrinsics.md#int64) - 初始哈希值，默认为 0。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例，使用默认初始值0
    var hasher1 = DefaultHasher()
    println("Created DefaultHasher with default initial value: 0")

    // 创建一个DefaultHasher实例，使用自定义初始值
    var hasher2 = DefaultHasher(res: 12345)
    println("Created DefaultHasher with custom initial value: 12345")

    // 使用hasher进行一些操作
    hasher1.write(42)
    hasher2.write(42)

    let result1 = hasher1.finish()
    let result2 = hasher2.finish()

    println("Hash result 1: ${result1}")
    println("Hash result 2: ${result2}")
}
```

运行结果：

```text
Created DefaultHasher with default initial value: 0
Created DefaultHasher with custom initial value: 12345
Hash result 1: -7046029254386353089
Hash result 2: -7046029254385555788
```

### func finish()

```cangjie
public func finish(): Int64
```

功能：获取哈希运算的结果。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希运算的结果。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入一些数据
    hasher.write(42)
    hasher.write("Hello")

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result: ${result}")
}
```

运行结果：

```text
Hash result: -2412057441983859926
```

### func reset()

```cangjie
public mut func reset(): Unit
```

功能：重置哈希值为 0。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入一些数据并获取哈希结果
    hasher.write(42)
    let result1 = hasher.finish()
    println("Hash result 1: ${result1}")

    // 重置哈希器
    hasher.reset()

    // 再次写入相同数据并获取哈希结果
    hasher.write(42)
    let result2 = hasher.finish()
    println("Hash result 2 (after reset): ${result2}")
}
```

运行结果：

```text
Hash result 1: -7046029254386353089
Hash result 2 (after reset): -7046029254386353089
```

### func write(Bool)

```cangjie
public mut func write(value: Bool): Unit
```

功能：通过该函数把想要哈希运算的 [Bool](core_package_intrinsics.md#bool) 值传入，然后进行哈希组合运算。

参数：

- value: [Bool](core_package_intrinsics.md#bool) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入布尔值
    hasher.write(true)
    hasher.write(false)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for boolean values: ${result}")
}
```

运行结果：

```text
Hash result for boolean values: -8244754741327405940
```

### func write(Float16)

```cangjie
public mut func write(value: Float16): Unit
```

功能：通过该函数把想要哈希运算的 [Float16](core_package_intrinsics.md#float16) 值传入，然后进行哈希组合运算。

参数：

- value: [Float16](core_package_intrinsics.md#float16) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Float16值
    let f16Value: Float16 = 3.14
    hasher.write(f16Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Float16 value: ${result}")
}
```

运行结果：

```text
Hash result for Float16 value: -1791342501213198195
```

### func write(Float32)

```cangjie
public mut func write(value: Float32): Unit
```

功能：通过该函数把想要哈希运算的 [Float32](core_package_intrinsics.md#float32) 值传入，然后进行哈希组合运算。

参数：

- value: [Float32](core_package_intrinsics.md#float32) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Float32值
    let f32Value: Float32 = 3.14159
    hasher.write(f32Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Float32 value: ${result}")
}
```

运行结果：

```text
Hash result for Float32 value: 7713830965842221811
```

### func write(Float64)

```cangjie
public mut func write(value: Float64): Unit
```

功能：通过该函数把想要哈希运算的 [Float64](core_package_intrinsics.md#float64) 值传入，然后进行哈希组合运算。

参数：

- value: [Float64](core_package_intrinsics.md#float64) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Float64值
    let f64Value: Float64 = 3.141592653589793
    hasher.write(f64Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Float64 value: ${result}")
}
```

运行结果：

```text
Hash result for Float64 value: 6866262051846751989
```

### func write(Int16)

```cangjie
public mut func write(value: Int16): Unit
```

功能：通过该函数把想要哈希运算的 [Int16](core_package_intrinsics.md#int16) 值传入，然后进行哈希组合运算。

参数：

- value: [Int16](core_package_intrinsics.md#int16) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Int16值
    let i16Value: Int16 = 1234
    hasher.write(i16Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Int16 value: ${result}")
}
```

运行结果：

```text
Hash result for Int16 value: -7046029254386351897
```

### func write(Int32)

```cangjie
public mut func write(value: Int32): Unit
```

功能：通过该函数把想要哈希运算的 [Int32](core_package_intrinsics.md#int32) 值传入，然后进行哈希组合运算。

参数：

- value: [Int32](core_package_intrinsics.md#int32) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Int32值
    let i32Value: Int32 = 123456
    hasher.write(i32Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Int32 value: ${result}")
}
```

运行结果：

```text
Hash result for Int32 value: -7046029254386229675
```

### func write(Int64)

```cangjie
public mut func write(value: Int64): Unit
```

功能：通过该函数把想要哈希运算的 [Int64](core_package_intrinsics.md#int64) 值传入，然后进行哈希组合运算。

参数：

- value: [Int64](core_package_intrinsics.md#int64) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Int64值
    let i64Value: Int64 = 123456789
    hasher.write(i64Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Int64 value: ${result}")
}
```

运行结果：

```text
Hash result for Int64 value: -7046029254262896342
```

### func write(Int8)

```cangjie
public mut func write(value: Int8): Unit
```

功能：通过该函数把想要哈希运算的 [Int8](core_package_intrinsics.md#int8) 值传入，然后进行哈希组合运算。

参数：

- value: [Int8](core_package_intrinsics.md#int8) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Int8值
    let i8Value: Int8 = 123
    hasher.write(i8Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Int8 value: ${result}")
}
```

运行结果：

```text
Hash result for Int8 value: -7046029254386353008
```

### func write(Rune)

```cangjie
public mut func write(value: Rune): Unit
```

功能：通过该函数把想要哈希运算的 [Rune](core_package_intrinsics.md#rune) 值传入，然后进行哈希组合运算。

参数：

- value: [Rune](core_package_intrinsics.md#rune) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入Rune值
    let runeValue: Rune = 'A'
    hasher.write(runeValue)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for Rune value: ${result}")
}
```

运行结果：

```text
Hash result for Rune value: -7046029254386353066
```

### func write(String)

```cangjie
public mut func write(value: String): Unit
```

功能：通过该函数把想要哈希运算的 [String](core_package_structs.md#struct-string) 值传入，然后进行哈希组合运算。

参数：

- value: [String](core_package_structs.md#struct-string) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入字符串值
    hasher.write("Hello, World!")

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for string value: ${result}")
}
```

运行结果：

```text
Hash result for string value: 6543264553144952043
```

### func write(UInt16)

```cangjie
public mut func write(value: UInt16): Unit
```

功能：通过该函数把想要哈希运算的 [UInt16](core_package_intrinsics.md#uint16) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt16](core_package_intrinsics.md#uint16) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入UInt16值
    let u16Value: UInt16 = 1234
    hasher.write(u16Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for UInt16 value: ${result}")
}
```

运行结果：

```text
Hash result for UInt16 value: -7046029254386351897
```

### func write(UInt32)

```cangjie
public mut func write(value: UInt32): Unit
```

功能：通过该函数把想要哈希运算的 [UInt32](core_package_intrinsics.md#uint32) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt32](core_package_intrinsics.md#uint32) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入UInt32值
    let u32Value: UInt32 = 123456
    hasher.write(u32Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for UInt32 value: ${result}")
}
```

运行结果：

```text
Hash result for UInt32 value: -7046029254386229675
```

### func write(UInt64)

```cangjie
public mut func write(value: UInt64): Unit
```

功能：通过该函数把想要哈希运算的 [UInt64](core_package_intrinsics.md#uint64) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt64](core_package_intrinsics.md#uint64) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入UInt64值
    let u64Value: UInt64 = 123456789
    hasher.write(u64Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for UInt64 value: ${result}")
}
```

运行结果：

```text
Hash result for UInt64 value: -7046029254262896342
```

### func write(UInt8)

```cangjie
public mut func write(value: UInt8): Unit
```

功能：通过该函数把想要哈希运算的 [UInt8](core_package_intrinsics.md#uint8) 值传入，然后进行哈希组合运算。

参数：

- value: [UInt8](core_package_intrinsics.md#uint8) - 待运算的值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个DefaultHasher实例
    var hasher = DefaultHasher()

    // 写入UInt8值
    let u8Value: UInt8 = 123
    hasher.write(u8Value)

    // 获取哈希结果
    let result = hasher.finish()
    println("Hash result for UInt8 value: ${result}")
}
```

运行结果：

```text
Hash result for UInt8 value: -7046029254386353008
```

## struct Duration

```cangjie
public struct Duration <: ToString & Hashable & Comparable<Duration> {
    public static const Max: Duration = Duration(0x7FFF_FFFF_FFFF_FFFF, 999999999)
    public static const Min: Duration = Duration(-0x8000_0000_0000_0000, 0)
    public static const Zero: Duration = Duration(0, 0)
    public static const day: Duration = Duration(24 * 60 * 60, 0)
    public static const hour: Duration = Duration(60 * 60, 0)
    public static const microsecond: Duration = Duration(0, 1000u32)
    public static const millisecond: Duration = Duration(0, 1000000u32)
    public static const minute: Duration = Duration(60, 0)
    public static const nanosecond: Duration = Duration(0, 1)
    public static const second: Duration = Duration(1, 0)
}
```

功能：[Duration](core_package_structs.md#struct-duration) 表示时间间隔，是一个描述一段时间的时间类型，提供了常用的静态实例，以及计算、比较等功能。

> **说明：**
>
> - [Duration](core_package_structs.md#struct-duration) 表示范围为 [Duration](core_package_structs.md#struct-duration).Min 至 [Duration](core_package_structs.md#struct-duration).Max，数值表示为[-2<sup>63</sup>, 2<sup>63</sup>)（单位为秒），精度为纳秒。
> - [Duration](core_package_structs.md#struct-duration) 每个时间单位均用整数表示，如果实际值不为整数，则向绝对值小的方向取整。例如表示 `1小时30分46秒` 的 [Duration](core_package_structs.md#struct-duration) 实例调用 `toHours` 方法，将返回结果 1 而不是 1.5 或 2。

父类型：

- [ToString](core_package_interfaces.md#interface-tostring)
- [Hashable](core_package_interfaces.md#interface-hashable)
- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Duration](#struct-duration)>

### static const day

```cangjie
public static const day: Duration = Duration(24 * 60 * 60, 0)
```

功能：表示 1 天时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.day静态常量
    let oneDay = Duration.day
    println("One day duration: ${oneDay}")

    // 使用一天的持续时间进行计算
    let twoDays = oneDay + oneDay
    println("Two days duration: ${twoDays}")
}
```

运行结果：

```text
One day duration: 1d
Two days duration: 2d
```

### static const hour

```cangjie
public static const hour: Duration = Duration(60 * 60, 0)
```

功能：表示 1 小时时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.hour静态常量
    let oneHour = Duration.hour
    println("One hour duration: ${oneHour}")

    // 计算一天有多少小时
    let hoursInDay = Duration.day / oneHour
    println("Hours in a day: ${hoursInDay}")
}
```

运行结果：

```text
One hour duration: 1h
Hours in a day: 24.000000
```

### static const Max

```cangjie
public static const Max: Duration = Duration(0x7FFF_FFFF_FFFF_FFFF, 999999999)
```

功能：表示最大时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.Max静态常量
    let maxDuration = Duration.Max
    println("Maximum duration: ${maxDuration}")
}
```

运行结果：

```text
Maximum duration: 106751991167300d15h30m7s999ms999us999ns
```

### static const microsecond

```cangjie
public static const microsecond: Duration = Duration(0, 1000u32)
```

功能：表示 1 微秒时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.microsecond静态常量
    let oneMicrosecond = Duration.microsecond
    println("One microsecond duration: ${oneMicrosecond}")

    // 计算一毫秒有多少微秒
    let microsecondsInMillisecond = Duration.millisecond / oneMicrosecond
    println("Microseconds in a millisecond: ${microsecondsInMillisecond}")
}
```

运行结果：

```text
One microsecond duration: 1us
Microseconds in a millisecond: 1000.000000
```

### static const millisecond

```cangjie
public static const millisecond: Duration = Duration(0, 1000000u32)
```

功能：表示 1 毫秒时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.millisecond静态常量
    let oneMillisecond = Duration.millisecond
    println("One millisecond duration: ${oneMillisecond}")

    // 计算一秒有多少毫秒
    let millisecondsInSecond = Duration.second / oneMillisecond
    println("Milliseconds in a second: ${millisecondsInSecond}")
}
```

运行结果：

```text
One millisecond duration: 1ms
Milliseconds in a second: 1000.000000
```

### static const Min

```cangjie
public static const Min: Duration = Duration(-0x8000_0000_0000_0000, 0)
```

功能：表示最小时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.Min静态常量
    let minDuration = Duration.Min
    println("Minimum duration: ${minDuration}")
}
```

运行结果：

```text
Minimum duration: -106751991167300d15h30m8s
```

### static const minute

```cangjie
public static const minute: Duration = Duration(60, 0)
```

功能：表示 1 分钟时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.minute静态常量
    let oneMinute = Duration.minute
    println("One minute duration: ${oneMinute}")

    // 计算一小时有多少分钟
    let minutesInHour = Duration.hour / oneMinute
    println("Minutes in an hour: ${minutesInHour}")
}
```

运行结果：

```text
One minute duration: 1m
Minutes in an hour: 60.000000
```

### static const nanosecond

```cangjie
public static const nanosecond: Duration = Duration(0, 1)
```

功能：表示 1 纳秒时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.nanosecond静态常量
    let oneNanosecond = Duration.nanosecond
    println("One nanosecond duration: ${oneNanosecond}")

    // 计算一微秒有多少纳秒
    let nanosecondsInMicrosecond = Duration.microsecond / oneNanosecond
    println("Nanoseconds in a microsecond: ${nanosecondsInMicrosecond}")
}
```

运行结果：

```text
One nanosecond duration: 1ns
Nanoseconds in a microsecond: 1000.000000
```

### static const second

```cangjie
public static const second: Duration = Duration(1, 0)
```

功能：表示 1 秒时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.second静态常量
    let oneSecond = Duration.second
    println("One second duration: ${oneSecond}")

    // 计算一分钟有多少秒
    let secondsInMinute = Duration.minute / oneSecond
    println("Seconds in a minute: ${secondsInMinute}")
}
```

运行结果：

```text
One second duration: 1s
Seconds in a minute: 60.000000
```

### static const Zero

```cangjie
public static const Zero: Duration = Duration(0, 0)
```

功能：表示 0 纳秒时间间隔的 [Duration](core_package_structs.md#struct-duration) 实例。

类型：[Duration](core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.Zero静态常量
    let zeroDuration = Duration.Zero
    println("Zero duration: ${zeroDuration}")
}
```

运行结果：

```text
Zero duration: 0s
```

### func abs()

```cangjie
public func abs(): Duration
```

功能：返回一个新的 [Duration](core_package_structs.md#struct-duration) 实例，其值大小为当前 [Duration](core_package_structs.md#struct-duration) 实例绝对值。

返回值：

- [Duration](core_package_structs.md#struct-duration) - 当前 [Duration](core_package_structs.md#struct-duration) 实例取绝对值的结果。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 如果当前 [Duration](core_package_structs.md#struct-duration) 实例等于 [Duration](core_package_structs.md#struct-duration).Min，会因为取绝对值超出 [Duration](core_package_structs.md#struct-duration) 表示范围而抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用Duration.second创建一个持续时间
    let tenSeconds = Duration.second * 10
    println("Ten seconds duration: ${tenSeconds}")

    // 创建一个负数持续时间（通过减法）
    let zeroDuration = Duration.Zero
    let negativeDuration = zeroDuration - tenSeconds
    println("Negative duration: ${negativeDuration}")

    // 使用abs()函数获取绝对值
    let absoluteDuration = negativeDuration.abs()
    println("Absolute duration: ${absoluteDuration}")
}
```

运行结果：

```text
Ten seconds duration: 10s
Negative duration: -10s
Absolute duration: 10s
```

### func compare(Duration)

```cangjie
public func compare(other: Duration): Ordering
```

功能：比较当前 [Duration](core_package_structs.md#struct-duration) 实例与另一个 [Duration](core_package_structs.md#struct-duration) 实例的大小关系。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - 参与比较的 [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering) - 当前 [Duration](core_package_structs.md#struct-duration) 实例与另一个实例的大小关系。如果大于，返回 [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).GT；如果等于，返回 [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).EQ；如果小于，返回 [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).LT。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个不同的持续时间
    let duration1 = Duration.second * 5 // 5秒
    let duration2 = Duration.second * 10 // 10秒

    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用compare函数比较两个持续时间
    let comparison = duration1.compare(duration2)
    println("Comparison result: ${comparison}")

    // 检查不同的比较结果
    if (comparison == Ordering.LT) {
        println("Duration 1 is less than Duration 2")
    } else if (comparison == Ordering.EQ) {
        println("Duration 1 is equal to Duration 2")
    } else if (comparison == Ordering.GT) {
        println("Duration 1 is greater than Duration 2")
    }
}
```

运行结果：

```text
Duration 1: 5s
Duration 2: 10s
Comparison result: Ordering.LT
Duration 1 is less than Duration 2
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例的哈希值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例的哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间
    let duration = Duration.second * 30 // 30秒
    println("Duration: ${duration}")

    // 使用hashCode()函数获取哈希值
    let hash = duration.hashCode()
    println("Hash code: ${hash}")

    // 创建另一个相同的持续时间
    let sameDuration = Duration.second * 30 // 30秒
    let sameHash = sameDuration.hashCode()
    println("Same duration hash code: ${sameHash}")

    // 验证相同持续时间的哈希值相同
    if (hash == sameHash) {
        println("Same durations have the same hash code")
    }

    // 创建一个不同的持续时间
    let differentDuration = Duration.minute * 1 // 1分钟
    let differentHash = differentDuration.hashCode()
    println("Different duration: ${differentDuration}")
    println("Different duration hash code: ${differentHash}")
}
```

运行结果：

```text
Duration: 30s
Hash code: -8244754741327406126
Same duration hash code: -8244754741327406126
Same durations have the same hash code
Different duration: 1m
Different duration hash code: -8244754741327408328
```

### func toDays()

```cangjie
public func toDays(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以天为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以天为单位的大小。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（3天5小时）
    let duration = Duration.day * 3 + Duration.hour * 5
    println("Duration: ${duration}")

    // 使用toDays()函数获取天数
    let days = duration.toDays()
    println("Days: ${days}")

    // 创建一个较小的持续时间（5小时）
    let smallDuration = Duration.hour * 5
    println("Small duration: ${smallDuration}")
    let smallDays = smallDuration.toDays()
    println("Days in small duration: ${smallDays}")
}
```

运行结果：

```text
Duration: 3d5h
Days: 3
Small duration: 5h
Days in small duration: 0
```

### func toHours()

```cangjie
public func toHours(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以小时为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以小时为单位的大小。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（2天3小时）
    let duration = Duration.day * 2 + Duration.hour * 3
    println("Duration: ${duration}")

    // 使用toHours()函数获取小时数
    let hours = duration.toHours()
    println("Hours: ${hours}")

    // 创建一个较小的持续时间（30分钟）
    let smallDuration = Duration.minute * 30
    println("Small duration: ${smallDuration}")
    let smallHours = smallDuration.toHours()
    println("Hours in small duration: ${smallHours}")
}
```

运行结果：

```text
Duration: 2d3h
Hours: 51
Small duration: 30m
Hours in small duration: 0
```

### func toMicroseconds()

```cangjie
public func toMicroseconds(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以微秒为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以微秒为单位的大小。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当 [Duration](core_package_structs.md#struct-duration) 实例以微秒为单位的大小超过 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（5秒）
    let duration = Duration.second * 5
    println("Duration: ${duration}")

    // 使用toMicroseconds()函数获取微秒数
    let microseconds = duration.toMicroseconds()
    println("Microseconds: ${microseconds}")

    // 创建一个较小的持续时间（500毫秒）
    let smallDuration = Duration.millisecond * 500
    println("Small duration: ${smallDuration}")
    let smallMicroseconds = smallDuration.toMicroseconds()
    println("Microseconds in small duration: ${smallMicroseconds}")
}
```

运行结果：

```text
Duration: 5s
Microseconds: 5000000
Small duration: 500ms
Microseconds in small duration: 500000
```

### func toMilliseconds()

```cangjie
public func toMilliseconds(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以毫秒为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以毫秒为单位的大小。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当 [Duration](core_package_structs.md#struct-duration) 实例以毫秒为单位的大小超过 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（3秒）
    let duration = Duration.second * 3
    println("Duration: ${duration}")

    // 使用toMilliseconds()函数获取毫秒数
    let milliseconds = duration.toMilliseconds()
    println("Milliseconds: ${milliseconds}")

    // 创建一个较小的持续时间（500000微秒）
    let smallDuration = Duration.microsecond * 500000
    println("Small duration: ${smallDuration}")
    let smallMilliseconds = smallDuration.toMilliseconds()
    println("Milliseconds in small duration: ${smallMilliseconds}")
}
```

运行结果：

```text
Duration: 3s
Milliseconds: 3000
Small duration: 500ms
Milliseconds in small duration: 500
```

### func toMinutes()

```cangjie
public func toMinutes(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以分钟为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以分钟为单位的大小。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（2小时）
    let duration = Duration.hour * 2
    println("Duration: ${duration}")

    // 使用toMinutes()函数获取分钟数
    let minutes = duration.toMinutes()
    println("Minutes: ${minutes}")

    // 创建一个较小的持续时间（30秒）
    let smallDuration = Duration.second * 30
    println("Small duration: ${smallDuration}")
    let smallMinutes = smallDuration.toMinutes()
    println("Minutes in small duration: ${smallMinutes}")
}
```

运行结果：

```text
Duration: 2h
Minutes: 120
Small duration: 30s
Minutes in small duration: 0
```

### func toNanoseconds()

```cangjie
public func toNanoseconds(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以纳秒为单位的整数大小，向绝对值小的方向取整。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以纳秒为单位的大小。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当 [Duration](core_package_structs.md#struct-duration) 实例以“纳秒”为单位的大小超过 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（2秒）
    let duration = Duration.second * 2
    println("Duration: ${duration}")

    // 使用toNanoseconds()函数获取纳秒数
    let nanoseconds = duration.toNanoseconds()
    println("Nanoseconds: ${nanoseconds}")

    // 创建一个较小的持续时间（500微秒）
    let smallDuration = Duration.microsecond * 500
    println("Small duration: ${smallDuration}")
    let smallNanoseconds = smallDuration.toNanoseconds()
    println("Nanoseconds in small duration: ${smallNanoseconds}")
}
```

运行结果：

```text
Duration: 2s
Nanoseconds: 2000000000
Small duration: 500us
Nanoseconds in small duration: 500000
```

### func toSeconds()

```cangjie
public func toSeconds(): Int64
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例以秒为单位的整数大小。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前 [Duration](core_package_structs.md#struct-duration) 实例以秒为单位的大小。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间（3分钟）
    let duration = Duration.minute * 3
    println("Duration: ${duration}")

    // 使用toSeconds()函数获取秒数
    let seconds = duration.toSeconds()
    println("Seconds: ${seconds}")

    // 创建一个较小的持续时间（500毫秒）
    let smallDuration = Duration.millisecond * 500
    println("Small duration: ${smallDuration}")
    let smallSeconds = smallDuration.toSeconds()
    println("Seconds in small duration: ${smallSeconds}")
}
```

运行结果：

```text
Duration: 3m
Seconds: 180
Small duration: 500ms
Seconds in small duration: 0
```

### func toString()

```cangjie
public func toString(): String
```

功能：获得当前 [Duration](core_package_structs.md#struct-duration) 实例的字符串表示，格式形如："1d2h3m4s5ms6us7ns"，表示“1 天 2 小时 3 分钟 4 秒 5 毫秒 6 微秒 7 纳秒”。某个单位下数值为 0 时此项会被省略，特别地，当所有单位下数值都为 0 时，返回 "0s"。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [Duration](core_package_structs.md#struct-duration) 实例的字符串表示。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个复杂的持续时间
    let duration = Duration.day * 2 + Duration.hour * 3 + Duration.minute * 30 + Duration.second * 45 +
        Duration.millisecond * 123 + Duration.microsecond * 456 + Duration.nanosecond * 789
    println("Duration: ${duration}")

    // 使用toString()函数获取字符串表示
    let durationString = duration.toString()
    println("String representation: ${durationString}")

    // 创建一个简单的持续时间
    let simpleDuration = Duration.hour * 2
    println("Simple duration: ${simpleDuration}")
    let simpleString = simpleDuration.toString()
    println("Simple string representation: ${simpleString}")
}
```

运行结果：

```text
Duration: 2d3h30m45s123ms456us789ns
String representation: 2d3h30m45s123ms456us789ns
Simple duration: 2h
Simple string representation: 2h
```

### operator func !=(Duration)

```cangjie
public operator func !=(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否不等于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例不等于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个相同的持续时间
    let duration1 = Duration.second * 30
    let duration2 = Duration.second * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用!=操作符比较两个持续时间
    if (duration1 != duration2) {
        println("Duration 1 is not equal to Duration 2")
    } else {
        println("Duration 1 is equal to Duration 2")
    }

    // 创建两个不同的持续时间
    let duration3 = Duration.minute * 1
    println("Duration 3: ${duration3}")

    // 使用!=操作符比较不同的持续时间
    if (duration1 != duration3) {
        println("Duration 1 is not equal to Duration 3")
    } else {
        println("Duration 1 is equal to Duration 3")
    }
}
```

运行结果：

```text
Duration 1: 30s
Duration 2: 30s
Duration 1 is equal to Duration 2
Duration 3: 1m
Duration 1 is not equal to Duration 3
```

### operator func *(Float64)

```cangjie
public operator func *(multiplier: Float64): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型与 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型的乘法，即 [Duration](core_package_structs.md#struct-duration) * [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 运算。

参数：

- multiplier: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 乘法的右操作数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的乘积。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相乘后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间
    let duration = Duration.second * 10
    println("Original duration: ${duration}")

    // 使用*操作符与Float64相乘
    let multipliedDuration = duration * 2.5
    println("Multiplied duration: ${multipliedDuration}")

    // 使用*操作符与Float64相乘（小于1的数）
    let dividedDuration = duration * 0.5
    println("Divided duration: ${dividedDuration}")
}
```

运行结果：

```text
Original duration: 10s
Multiplied duration: 25s
Divided duration: 5s
```

### operator func *(Int64)

```cangjie
public operator func *(multiplier: Int64): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型与 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型的乘法，即 [Duration](core_package_structs.md#struct-duration) * [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 运算。

参数：

- multiplier: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 乘法的右操作数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的乘积。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相乘后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间
    let duration = Duration.minute * 5
    println("Original duration: ${duration}")

    // 使用*操作符与Int64相乘
    let multipliedDuration = duration * 3
    println("Multiplied duration: ${multipliedDuration}")

    // 使用*操作符与Int64相乘
    let dividedDuration = duration * 2
    println("Multiplied duration (2): ${dividedDuration}")
}
```

运行结果：

```text
Original duration: 5m
Multiplied duration: 15m
Multiplied duration (2): 10m
```

### operator func +(Duration)

```cangjie
public operator func +(other: Duration): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型之间的加法，即 [Duration](core_package_structs.md#struct-duration) + [Duration](core_package_structs.md#struct-duration) 运算。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - 加法的右操作数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的和。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相加后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用+操作符相加两个持续时间
    let sumDuration = duration1 + duration2
    println("Sum duration: ${sumDuration}")

    // 创建更多的持续时间并相加
    let duration3 = Duration.second * 45
    println("Duration 3: ${duration3}")
    let totalDuration = duration1 + duration2 + duration3
    println("Total duration: ${totalDuration}")
}
```

运行结果：

```text
Duration 1: 2h
Duration 2: 30m
Sum duration: 2h30m
Duration 3: 45s
Total duration: 2h30m45s
```

### operator func -(Duration)

```cangjie
public operator func -(other: Duration): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型之间的减法，即 [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 运算。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - 减法的右操作数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的差。

异常：

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相减后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.hour * 3
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用-操作符相减两个持续时间
    let diffDuration = duration1 - duration2
    println("Difference duration: ${diffDuration}")

    // 创建更多的持续时间并进行减法运算
    let duration3 = Duration.second * 45
    println("Duration 3: ${duration3}")
    let resultDuration = duration1 - duration2 - duration3
    println("Result duration: ${resultDuration}")
}
```

运行结果：

```text
Duration 1: 3h
Duration 2: 30m
Difference duration: 2h30m
Duration 3: 45s
Result duration: 2h29m15s
```

### operator func /(Duration)

```cangjie
public operator func /(other: Duration): Float64
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型与 [Duration](core_package_structs.md#struct-duration) 类型的除法，即 [Duration](core_package_structs.md#struct-duration) / [Duration](core_package_structs.md#struct-duration) 运算。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - 除数。

返回值：

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的商。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `r` 等于 [Duration](core_package_structs.md#struct-duration).Zero 时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用/操作符计算两个持续时间的商
    let quotient = duration1 / duration2
    println("Quotient: ${quotient}")

    // 创建更多的持续时间并进行除法运算
    let duration3 = Duration.second * 45
    let duration4 = Duration.second * 15
    println("Duration 3: ${duration3}")
    println("Duration 4: ${duration4}")
    let quotient2 = duration3 / duration4
    println("Quotient 2: ${quotient2}")
}
```

运行结果：

```text
Duration 1: 2h
Duration 2: 30m
Quotient: 4.000000
Duration 3: 45s
Duration 4: 15s
Quotient 2: 3.000000
```

### operator func /(Float64)

```cangjie
public operator func /(divisor: Float64): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型与 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型的除法，即 [Duration](core_package_structs.md#struct-duration) / [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 运算。

参数：

- divisor: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - 除数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的商。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `r` 等于 0 时，抛出异常。
- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相除后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间
    let duration = Duration.hour * 2
    println("Original duration: ${duration}")

    // 使用/操作符与Float64相除
    let dividedDuration = duration / 2.0
    println("Divided duration: ${dividedDuration}")

    // 使用/操作符与Float64相除（大于1的数）
    let smallerDuration = duration / 4.0
    println("Smaller duration: ${smallerDuration}")
}
```

运行结果：

```text
Original duration: 2h
Divided duration: 1h
Smaller duration: 30m
```

### operator func /(Int64)

```cangjie
public operator func /(divisor: Int64): Duration
```

功能：实现 [Duration](core_package_structs.md#struct-duration) 类型与 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型的除法，即 [Duration](core_package_structs.md#struct-duration) / [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 运算。

参数：

- divisor: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 除数。

返回值：

- [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 类型实例和 `r` 的商。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `r` 等于 0 时，抛出异常。
- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - 当相除后的结果超出 [Duration](core_package_structs.md#struct-duration) 的表示范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个持续时间
    let duration = Duration.hour * 3
    println("Original duration: ${duration}")

    // 使用/操作符与Int64相除
    let dividedDuration = duration / 3
    println("Divided duration: ${dividedDuration}")

    // 使用/操作符与Int64相除（大于1的数）
    let smallerDuration = duration / 6
    println("Smaller duration: ${smallerDuration}")
}
```

运行结果：

```text
Original duration: 3h
Divided duration: 1h
Smaller duration: 30m
```

### operator func <(Duration)

```cangjie
public operator func <(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否小于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例小于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.minute * 30
    let duration2 = Duration.hour * 1
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用<操作符比较两个持续时间
    if (duration1 < duration2) {
        println("Duration 1 is less than Duration 2")
    } else {
        println("Duration 1 is not less than Duration 2")
    }

    // 创建相同的持续时间并比较
    let duration3 = Duration.minute * 30
    println("Duration 3: ${duration3}")

    if (duration1 < duration3) {
        println("Duration 1 is less than Duration 3")
    } else {
        println("Duration 1 is not less than Duration 3")
    }
}
```

运行结果：

```text
Duration 1: 30m
Duration 2: 1h
Duration 1 is less than Duration 2
Duration 3: 30m
Duration 1 is not less than Duration 3
```

### operator func <=(Duration)

```cangjie
public operator func <=(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否小于等于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例小于等于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.minute * 30
    let duration2 = Duration.hour * 1
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用<=操作符比较两个持续时间
    if (duration1 <= duration2) {
        println("Duration 1 is less than or equal to Duration 2")
    } else {
        println("Duration 1 is not less than or equal to Duration 2")
    }

    // 创建相同的持续时间并比较
    let duration3 = Duration.minute * 30
    println("Duration 3: ${duration3}")

    if (duration1 <= duration3) {
        println("Duration 1 is less than or equal to Duration 3")
    } else {
        println("Duration 1 is not less than or equal to Duration 3")
    }

    // 创建更大的持续时间并比较
    let duration4 = Duration.minute * 20
    println("Duration 4: ${duration4}")

    if (duration1 <= duration4) {
        println("Duration 1 is less than or equal to Duration 4")
    } else {
        println("Duration 1 is not less than or equal to Duration 4")
    }
}
```

运行结果：

```text
Duration 1: 30m
Duration 2: 1h
Duration 1 is less than or equal to Duration 2
Duration 3: 30m
Duration 1 is less than or equal to Duration 3
Duration 4: 20m
Duration 1 is not less than or equal to Duration 4
```

### operator func ==(Duration)

```cangjie
public operator func ==(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否等于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例等于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个相同的持续时间
    let duration1 = Duration.minute * 30
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用==操作符比较两个持续时间
    if (duration1 == duration2) {
        println("Duration 1 is equal to Duration 2")
    } else {
        println("Duration 1 is not equal to Duration 2")
    }

    // 创建不同的持续时间并比较
    let duration3 = Duration.hour * 1
    println("Duration 3: ${duration3}")

    if (duration1 == duration3) {
        println("Duration 1 is equal to Duration 3")
    } else {
        println("Duration 1 is not equal to Duration 3")
    }
}
```

运行结果：

```text
Duration 1: 30m
Duration 2: 30m
Duration 1 is equal to Duration 2
Duration 3: 1h
Duration 1 is not equal to Duration 3
```

### operator func >(Duration)

```cangjie
public operator func >(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否大于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例大于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用>操作符比较两个持续时间
    if (duration1 > duration2) {
        println("Duration 1 is greater than Duration 2")
    } else {
        println("Duration 1 is not greater than Duration 2")
    }

    // 创建相同的持续时间并比较
    let duration3 = Duration.hour * 2
    println("Duration 3: ${duration3}")

    if (duration1 > duration3) {
        println("Duration 1 is greater than Duration 3")
    } else {
        println("Duration 1 is not greater than Duration 3")
    }
}
```

运行结果：

```text
Duration 1: 2h
Duration 2: 30m
Duration 1 is greater than Duration 2
Duration 3: 2h
Duration 1 is not greater than Duration 3
```

### operator func >=(Duration)

```cangjie
public operator func >=(other: Duration): Bool
```

功能：判断当前 [Duration](core_package_structs.md#struct-duration) 实例是否大于等于 `r`。

参数：

- other: [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 或 `false`。当前 [Duration](core_package_structs.md#struct-duration) 实例大于等于 `r` 时，返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个持续时间
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")

    // 使用>=操作符比较两个持续时间
    if (duration1 >= duration2) {
        println("Duration 1 is greater than or equal to Duration 2")
    } else {
        println("Duration 1 is not greater than or equal to Duration 2")
    }

    // 创建相同的持续时间并比较
    let duration3 = Duration.hour * 2
    println("Duration 3: ${duration3}")

    if (duration1 >= duration3) {
        println("Duration 1 is greater than or equal to Duration 3")
    } else {
        println("Duration 1 is not greater than or equal to Duration 3")
    }

    // 创建更小的持续时间并比较
    let duration4 = Duration.hour * 3
    println("Duration 4: ${duration4}")

    if (duration1 >= duration4) {
        println("Duration 1 is greater than or equal to Duration 4")
    } else {
        println("Duration 1 is not greater than or equal to Duration 4")
    }
}
```

运行结果：

```text
Duration 1: 2h
Duration 2: 30m
Duration 1 is greater than or equal to Duration 2
Duration 3: 2h
Duration 1 is greater than or equal to Duration 3
Duration 4: 3h
Duration 1 is not greater than or equal to Duration 4
```

## struct LibC

```cangjie
public struct LibC {}
```

功能：提供了仓颉中较为高频使用的 C 接口，如申请、释放堆上 [CType](core_package_interfaces.md#interface-ctype) 实例。

### static func free(CString)

```cangjie
public unsafe static  func free(cstr: CString): Unit
```

功能：释放 C 风格字符串。

参数：

- cstr: [CString](core_package_intrinsics.md#cstring) - 需要释放的 C 风格字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var str = unsafe { LibC.mallocCString("I like Cangjie") }
    println(str)
    unsafe { LibC.free(str) }
}
```

运行结果：

```text
I like Cangjie
```

### static func free\<T>(CPointer\<T>) where T <: CType

```cangjie
public unsafe static  func free<T>(p: CPointer<T>): Unit where T <: CType
```

功能：释放指针 p 指向的堆内存。

参数：

- p: [CPointer](core_package_intrinsics.md#cpointert)\<T> - 表示需要被释放的内存地址。

示例：

<!-- verify -->
```cangjie
main() {
    var p = unsafe { LibC.malloc<Int64>(count: 1) }
    unsafe { p.write(8) }
    let value: Int64 = unsafe { p.read() }
    println(value)
    unsafe { LibC.free<Int64>(p) }
}
```

运行结果：

```text
8
```

### static func malloc\<T>(Int64) where T <: CType

```cangjie
public static func malloc<T>(count!: Int64 = 1): CPointer<T> where T <: CType
```

功能：在堆中申请指定个数的 `T` 实例，并返回其起始指针。

申请内存长度为 [sizeOf](core_package_funcs.md#func-sizeoft-where-t--ctype)\<T>() * [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet)。

参数：

- count!: [Int64](core_package_intrinsics.md#int64) - 为可选参数，默认为 1，表示申请 T 类型的个数。

返回值：

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - 申请的 T 类型指针。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 入参为负数时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    var p = unsafe { LibC.malloc<Int64>(count: 1) }
    unsafe { p.write(8) }
    let value: Int64 = unsafe { p.read() }
    println(value)
    unsafe { LibC.free<Int64>(p) }
}
```

运行结果：

```text
8
```

### static func mallocCString(String)

```cangjie
public unsafe static  func mallocCString(str: String): CString
```

功能：通过 [String](core_package_structs.md#struct-string) 申请与之字符内容相同的 C 风格字符串。

构造的 C 风格字符串将以 '\0' 结束。当异常场景如系统内存不足时，返回字符串指针可能为空，故使用前需要进行空指针检查。

参数：

- str: [String](core_package_structs.md#struct-string) - 根据该仓颉字符串构造 C 字符串。

返回值：

- [CString](core_package_intrinsics.md#cstring) - 新构造的 C 风格字符串。

异常：

- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - 内存不足时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    var str = unsafe { LibC.mallocCString("I like Cangjie") }
    println(str)
    unsafe { LibC.free(str) }
}
```

运行结果：

```text
I like Cangjie
```

## struct Range\<T> where T <: Countable\<T> & Comparable\<T> & Equatable\<T>

```cangjie
public struct Range<T> <: Iterable<T> where T <: Countable<T> & Comparable<T> & Equatable<T> {
    public let start: T
    public let end: T
    public let step: Int64
    public let hasStart: Bool
    public let hasEnd: Bool
    public let isClosed: Bool
    public const init(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool)
}
```

功能：该类是区间类型，用于表示一个拥有固定范围和步长的 `T` 的序列，要求 `T` 是可数的，有序的。

区间类型有对应的字面量表示，其格式为：

- 左闭右开区间：`start..end : step`，它表示一个从 start 开始，以 [step](#let-step) 为步长，到 end（不包含 end）为止的区间。
- 左闭右闭区间：`start..=end : step`，它表示一个从 start 开始，以 [step](#let-step) 为步长，到 end（包含 end）为止的区间。

> **注意：**
>
> - 当 [step](#let-step) > 0 且 start >= end，或者 [step](#let-step) < 0 且 start <= end 时，该 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例将是一个空区间。
> - 当 [step](#let-step) > 0 且 start > end，或者 [step](#let-step) < 0 且 start < end 时，该 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例将是一个空区间。

父类型：

- [Iterable](core_package_interfaces.md#interface-iterablee)\<T>

### let end

```cangjie
public let end: T
```

功能：表示结束值。

类型：T

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Range实例
    let range = Range<Int32>(1, 10, 1, true, false, false)

    // 访问end属性
    println("Range end value: ${range.end}")
}
```

运行结果：

```text
Range end value: 10
```

### let hasEnd

```cangjie
public let hasEnd: Bool
```

功能：表示是否包含结束值。

类型：[Bool](core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个有结束值的Range实例
    let rangeWithEnd = Range<Int32>(1, 10, 1, true, true, false)

    // 访问hasEnd属性
    println("Range has end value: ${rangeWithEnd.hasEnd}")

    // 创建一个没有结束值的Range实例
    let rangeWithoutEnd = Range<Int32>(1, 10, 1, true, false, false)

    // 访问hasEnd属性
    println("Range without end value: ${rangeWithoutEnd.hasEnd}")
}
```

运行结果：

```text
Range has end value: true
Range without end value: false
```

### let hasStart

```cangjie
public let hasStart: Bool
```

功能：表示是否包含开始值。

类型：[Bool](core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个有开始值的Range实例
    let rangeWithStart = Range<Int32>(1, 10, 1, true, true, false)

    // 访问hasStart属性
    println("Range has start value: ${rangeWithStart.hasStart}")

    // 创建一个没有开始值的Range实例
    let rangeWithoutStart = Range<Int32>(1, 10, 1, false, true, false)

    // 访问hasStart属性
    println("Range without start value: ${rangeWithoutStart.hasStart}")
}
```

运行结果：

```text
Range has start value: true
Range without start value: false
```

### let isClosed

```cangjie
public let isClosed: Bool
```

功能：表示区间开闭情况，为 true 表示左闭右闭，为 false 表示左闭右开。

类型：[Bool](core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个闭区间Range实例
    let closedRange = Range<Int32>(1, 10, 1, true, true, true)

    // 访问isClosed属性
    println("Closed range: ${closedRange.isClosed}")

    // 创建一个开区间Range实例
    let openRange = Range<Int32>(1, 10, 1, true, true, false)

    // 访问isClosed属性
    println("Open range: ${openRange.isClosed}")
}
```

运行结果：

```text
Closed range: true
Open range: false
```

### let start

```cangjie
public let start: T
```

功能：表示开始值。

类型：T

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Range实例
    let range = Range<Int32>(5, 15, 1, true, true, false)

    // 访问start属性
    println("Range start value: ${range.start}")
}
```

运行结果：

```text
Range start value: 5
```

### let step

```cangjie
public let step: Int64
```

功能：表示步长。

类型：[Int64](core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个步长为2的Range实例
    let range = Range<Int32>(1, 10, 2, true, true, false)

    // 访问step属性
    println("Range step value: ${range.step}")
}
```

运行结果：

```text
Range step value: 2
```

### init(T, T, Int64, Bool, Bool, Bool)

```cangjie
public const init(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool)
```

功能：使用该构造函数创建 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 序列。

参数：

- start: T - 开始值。
- end: T - 结束值。
- step: [Int64](core_package_intrinsics.md#int64) - 步长，取值不能为 0。
- hasStart: [Bool](core_package_intrinsics.md#bool) - 是否有开始值。
- hasEnd: [Bool](core_package_intrinsics.md#bool) - 是否有结束值。
- isClosed: [Bool](core_package_intrinsics.md#bool) - true 代表左闭右闭，false 代表左闭右开。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当 [step](#let-step) 等于 0 时, 抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 使用构造函数创建一个Range实例
    let range = Range<Int32>(1, 10, 1, true, true, false)

    println("Range start: ${range.start}")
    println("Range end: ${range.end}")
    println("Range step: ${range.step}")
    println("Has start: ${range.hasStart}")
    println("Has end: ${range.hasEnd}")
    println("Is closed: ${range.isClosed}")
}
```

运行结果：

```text
Range start: 1
Range end: 10
Range step: 1
Has start: true
Has end: true
Is closed: false
```

### func isEmpty()

```cangjie
public const func isEmpty(): Bool
```

功能：判断该区间是否为空。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个非空的Range实例
    let nonEmptyRange = Range<Int32>(1, 10, 1, true, true, false)
    println("Non-empty range is empty: ${nonEmptyRange.isEmpty()}")

    // 创建一个空的Range实例（start >= end 且 step > 0）
    let emptyRange = Range<Int32>(10, 5, 1, true, true, false)
    println("Empty range is empty: ${emptyRange.isEmpty()}")
}
```

运行结果：

```text
Non-empty range is empty: false
Empty range is empty: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

功能：获取当前区间的迭代器。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<T> - 当前区间的迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Range实例
    let range = Range<Int32>(1, 5, 1, true, false, false)

    // 使用for循环遍历Range（Range实现了Iterable接口）
    println("Range values:")
    for (value in range) {
        println("${value}")
    }
}
```

运行结果：

```text
Range values:
1
2
3
4
```

### extend\<T> Range\<T> <: Equatable\<Range\<T>> where T <: Countable\<T> & Comparable\<T> & Equatable\<T>

```cangjie
extend<T> Range<T> <: Equatable<Range<T>> where T <: Countable<T> & Comparable<T> & Equatable<T>
```

功能：为 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T> 类型扩展 [Equatable](core_package_interfaces.md#interface-equatablet)\<[Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T>> 接口。

父类型：

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Range](#struct-ranget-where-t--countablet--comparablet--equatablet)\<T>>

#### operator func ==(Range\<T>)

```cangjie
public operator func ==(other: Range<T>): Bool
```

功能：判断两个 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例是否相等。

两个 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例相等指的是它们表示同一个区间，即 `start`、`end`、[step](#let-step)、`isClosed` 值相等。

参数：

- other: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T> - 待比较的 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - true 代表相等，false 代表不相等。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建两个相同的Range实例
    let range1 = Range<Int32>(1, 5, 1, true, false, false)
    let range2 = Range<Int32>(1, 5, 1, true, false, false)

    // 使用==操作符比较两个Range实例
    if (range1 == range2) {
        println("Range1 is equal to Range2")
    } else {
        println("Range1 is not equal to Range2")
    }

    // 创建一个不同的Range实例
    let range3 = Range<Int32>(1, 6, 1, true, false, false)

    // 使用==操作符比较两个不同的Range实例
    if (range1 == range3) {
        println("Range1 is equal to Range3")
    } else {
        println("Range1 is not equal to Range3")
    }
}
```

运行结果：

```text
Range1 is equal to Range2
Range1 is not equal to Range3
```

### extend\<T> Range\<T> <: Hashable where T <: Hashable & Countable\<T> & Comparable\<T> & Equatable\<T>

```cangjie
extend<T> Range<T> <: Hashable where T <: Hashable & Countable<T> & Comparable<T> & Equatable<T>
```

功能：为 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 类型扩展 [Hashable](core_package_interfaces.md#interface-hashable) 接口，支持计算哈希值。

父类型：

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取哈希值，该值为 `start`、`end`、[step](#let-step)、`isClosed` 的组合哈希运算结果。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Range实例
    let range = Range<Int32>(1, 5, 1, true, false, false)

    // 获取哈希值
    let hash = range.hashCode()
    println("Range hash code: ${hash}")

    // 创建另一个相同的Range实例
    let sameRange = Range<Int32>(1, 5, 1, true, false, false)
    let sameHash = sameRange.hashCode()
    println("Same range hash code: ${sameHash}")

    // 验证相同Range实例的哈希值相同
    if (hash == sameHash) {
        println("Same ranges have the same hash code")
    }
}
```

运行结果：

```text
Range hash code: -1988359251787629792
Same range hash code: -1988359251787629792
Same ranges have the same hash code
```

## struct String

```cangjie
public struct String <: Collection<Byte> & Comparable<String> & Hashable & ToString {
    public static const empty: String = String()
    public const init()
    public init(value: Array<Rune>)
    public init(value: Collection<Rune>)
}
```

功能：该结构体表示仓颉字符串，提供了构造、查找、拼接等一系列字符串操作。

> **注意：**
>
> - `String` 类型仅支持 UTF-8 编码。
> - `String` 的 `size`、下标访问（`[]`）、切片和迭代均基于 UTF-8 编码后的**字节**，而非字符。一个多字节字符（例如中文字符）由多个字节组成，字节下标可能落在某个字符的中间。
> - 如需按字符（[Rune](./core_package_intrinsics.md#rune)）遍历或处理字符串，请使用 [runes](#func-runes) / [toRuneArray](#func-torunearray)。
> - 出于 `String` 对象内存开销方面的优化，`String` 的长度被限制在 `4GB`大小，即 `String`的最大长度不超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32)。

父类型：

- [Collection](core_package_interfaces.md#interface-collectiont)\<Byte>
- [Comparable](core_package_interfaces.md#interface-comparablet)\<[String](#struct-string)>
- [Hashable](core_package_interfaces.md#interface-hashable)
- [ToString](core_package_interfaces.md#interface-tostring)

### static const empty

```cangjie
public static const empty: String = String()
```

功能：创建一个空的字符串并返回。

类型：[String](core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
main() {
    // 使用String.empty创建一个空字符串
    let emptyString = String.empty
    println("Empty string: '${emptyString}'")
    println("Empty string length: ${emptyString.size}")
}
```

运行结果：

```text
Empty string: ''
Empty string length: 0
```

### prop size

```cangjie
public prop size: Int64
```

功能：获取字符串 UTF-8 编码后的字节长度。

类型：[Int64](core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"
    println("String: '${str}'")

    // 获取字符串的字节长度
    let size = str.size
    println("String size (bytes): ${size}")

    // 创建一个空字符串
    let emptyStr = String.empty
    println("Empty string size: ${emptyStr.size}")
}
```

运行结果：

```text
String: 'Hello, 世界'
String size (bytes): 13
Empty string size: 0
```

### init()

```cangjie
public const init()
```

功能：构造一个空的字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个空字符串
    let str = String()
    println("String: '${str}'")

    // 获取字符串的字节长度
    let size = str.size
    println("String size (bytes): ${size}")
}
```

运行结果：

```text
String: ''
String size (bytes): 0
```

### init(Array\<Rune>)

```cangjie
public init(value: Array<Rune>)
```

功能：根据字符数组构造一个字符串，字符串内容为数组中的所有字符。

参数：

- value: [Array](core_package_structs.md#struct-arrayt)\<Rune> - 根据该字符数组构造字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Rune数组
    let runes = [r'H', r'e', r'l', r'l', r'o', r' ', r'世', r'界']

    // 使用init(Array<Rune>)构造函数创建字符串
    let str = String(runes)

    println("String from Rune array: '${str}'")
    println("String size: ${str.size}")
}
```

运行结果：

```text
String from Rune array: 'Hello 世界'
String size: 12
```

### init(Collection\<Rune>)

```cangjie
public init(value: Collection<Rune>)
```

功能：据字符集合构造一个字符串，字符串内容为集合中的所有字符。

参数：

- value: [Collection](core_package_interfaces.md#interface-collectiont)\<Rune> - 根据该字符集合构造字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个Array<Rune>作为Collection<Rune>
    let runeArray: Array<Rune> = [r'H', r'e', r'l', r'l', r'o', r' ', r'世', r'界']

    // 使用init(Collection<Rune>)构造函数创建字符串
    let str = String(runeArray)

    println("String from Collection<Rune>: '${str}'")
    println("String size: ${str.size}")
}
```

运行结果：

```text
String from Collection<Rune>: 'Hello 世界'
String size: 12
```

### static func checkUtf8Encoding(Array\<UInt8>)

```cangjie
public static func checkUtf8Encoding(data: Array<UInt8>): Bool
```

功能：检查一个 Byte 数组是否符合 UTF-8 编码。

参数：

- data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 根据该字节数组构造字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果 Byte 数组符合 UTF-8 编码，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个UTF-8编码的字节数组，表示"仓颉"
    let utf8Bytes: Array<UInt8> = [228, 187, 147, 233, 162, 137]

    // 使用checkUtf8Encoding函数检查字节数组是否为有效的UTF-8编码
    let isValid = String.checkUtf8Encoding(utf8Bytes)
    println("字节数组是否为有效的UTF-8编码: ${isValid}")

    // 创建一个不是UTF-8编码的字节数组
    let invalidUtf8Bytes: Array<UInt8> = [100, 187, 147, 233, 162, 137]
    let isInvalid = String.checkUtf8Encoding(invalidUtf8Bytes)
    println("字节数组是否为有效的UTF-8编码: ${isInvalid}")
}
```

运行结果：

```text
字节数组是否为有效的UTF-8编码: true
字节数组是否为有效的UTF-8编码: false
```

### static func fromUtf8(Array\<UInt8>)

```cangjie
public static func fromUtf8(utf8Data: Array<UInt8>): String
```

功能：根据 UTF-8 编码的字节数组构造一个字符串。

参数：

- utf8Data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 根据该字节数组构造字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 构造的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 入参不符合 utf-8 序列规则，或者试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个UTF-8编码的字节数组，表示"Hello 世界"
    let utf8Bytes: Array<UInt8> = [72, 101, 108, 108, 111, 32, 228, 184, 150, 231, 149, 140]

    // 使用fromUtf8函数创建字符串
    let str = String.fromUtf8(utf8Bytes)

    println("String from UTF-8 bytes: '${str}'")
    println("String size: ${str.size}")
}
```

运行结果：

```text
String from UTF-8 bytes: 'Hello 世界'
String size: 12
```

### static func fromUtf8Unchecked(Array\<UInt8>)

```cangjie
public unsafe static  func fromUtf8Unchecked(utf8Data: Array<UInt8>): String
```

功能：根据字节数组构造一个字符串。

相较于 [fromUtf8](core_package_structs.md#static-func-fromutf8arrayuint8) 函数，fromUtf8Unchecked 并没有针对于字节数组进行 UTF-8 相关规则的检查，所以它所构建的字符串并不一定保证是合法的，甚至出现非预期的异常，如果不是某些场景下的性能考虑，请优先使用安全的 fromUtf8 函数。

参数：

- utf8Data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 根据该字节数组构造字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 构造的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个UTF-8编码的字节数组，表示"仓颉"
    let utf8Bytes: Array<UInt8> = [228, 187, 147, 233, 162, 137]

    // 使用fromUtf8Unchecked函数创建字符串（不进行UTF-8验证）
    let str = unsafe { String.fromUtf8Unchecked(utf8Bytes) }

    println("结果: ${str}")
}
```

运行结果：

```text
结果: 仓颉
```

### static func join(Array\<String>, String)

```cangjie
public static func join(strArray: Array<String>, delimiter!: String = String.empty): String
```

功能：连接字符串列表中的所有字符串，以指定分隔符分隔。

参数：

- strArray: [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - 需要被连接的字符串数组，当数组为空时，返回空字符串。
- delimiter!: [String](core_package_structs.md#struct-string) - 用于连接的中间字符串，其默认值为 [String](core_package_structs.md#struct-string).empty。

返回值：

- [String](core_package_structs.md#struct-string) - 连接后的新字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    var arr = ["I", "like", "Cangjie"]
    var str = String.join(arr, delimiter: " ")
    println(str)
}
```

运行结果：

```text
I like Cangjie
```

### static func withRawData(Array\<UInt8>)

```cangjie
public static unsafe func withRawData(rawData: Array<UInt8>): String
```

功能：根据字节数组构造一个字符串。

相较于 [fromUtf8Unchecked](core_package_structs.md#static-func-fromutf8uncheckedarrayuint8) 函数，withRawData 没有做数组的拷贝，直接用传入的数组构造了字符串。

> **注意：**
>
> 用户应该保证：
>
> 1. rawData 在字符串构造后永远不会被修改。
> 2. rawData 符合 UTF-8 编码。
>
> 否则程序行为是未定义的。
>
> 如果不是某些场景下的性能考虑，请优先使用安全的 fromUtf8 函数。

参数：

- rawData: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - 根据该字节数组构造字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 构造的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个UTF-8编码的字节数组，表示"仓颉"
    let utf8Bytes: Array<UInt8> = [228, 187, 147, 233, 162, 137]

    // 使用withRawData函数创建字符串
    let str = unsafe { String.withRawData(utf8Bytes) }

    println("结果: ${str}")
}
```

运行结果：

```text
结果: 仓颉
```

### func clone()

```cangjie
public func clone(): String
```

功能：返回原字符串的拷贝。

返回值：

- [String](core_package_structs.md#struct-string) - 拷贝得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let originalStr = "Hello, 世界"

    // 使用clone函数创建字符串的拷贝
    let clonedStr = originalStr.clone()

    println("Original string: '${originalStr}'")
    println("Cloned string: '${clonedStr}'")
    println("Are they equal? ${originalStr == clonedStr}")
}
```

运行结果：

```text
Original string: 'Hello, 世界'
Cloned string: 'Hello, 世界'
Are they equal? true
```

### func compare(String)

```cangjie
public func compare(str: String): Ordering
```

功能：按字典序比较当前字符串和参数指定的字符串。

参数：

- str: [String](core_package_structs.md#struct-string) - 被比较的字符串。

返回值：

- [Ordering](core_package_enums.md#enum-ordering) - 返回 enum 值 [Ordering](core_package_enums.md#enum-ordering) 表示结果，[Ordering](core_package_enums.md#enum-ordering).GT 表示当前字符串字典序大于 str 字符串，[Ordering](core_package_enums.md#enum-ordering).LT 表示当前字符串字典序小于 str 字符串，[Ordering](core_package_enums.md#enum-ordering).EQ 表示两个字符串字典序相等。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果两个字符串的原始数据中存在无效的 UTF-8 编码，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于比较
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"

    // 使用compare函数比较字符串
    let result1 = str1.compare(str2)
    let result2 = str2.compare(str1)
    let result3 = str1.compare(str3)

    println("Comparing '${str1}' to '${str2}': ${result1}")
    println("Comparing '${str2}' to '${str1}': ${result2}")
    println("Comparing '${str1}' to '${str3}': ${result3}")
}
```

运行结果：

```text
Comparing 'apple' to 'banana': Ordering.LT
Comparing 'banana' to 'apple': Ordering.GT
Comparing 'apple' to 'apple': Ordering.EQ
```

### func contains(String)

```cangjie
public func contains(str: String): Bool
```

功能：判断原字符串中是否包含指定字符串。

参数：

- str: [String](core_package_structs.md#struct-string) - 待搜索的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果指定字符串在原字符串中，返回 true，否则返回 false。特别地，如果指定字符串长度为 0，返回 true。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 检查字符串是否包含特定子串
    let contains1 = str.contains("Hello")
    let contains2 = str.contains("世界")
    let contains3 = str.contains("World")
    let contains4 = str.contains("")

    println("String: '${str}'")
    println("Contains 'Hello': ${contains1}")
    println("Contains '世界': ${contains2}")
    println("Contains 'World': ${contains3}")
    println("Contains empty string: ${contains4}")
}
```

运行结果：

```text
String: 'Hello, 世界'
Contains 'Hello': true
Contains '世界': true
Contains 'World': false
Contains empty string: true
```

### func count(String)

```cangjie
public func count(str: String): Int64
```

功能：返回子字符串 str 在原字符串中出现的次数。

参数：

- str: [String](core_package_structs.md#struct-string) - 被搜索的子字符串。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 出现的次数，当 str 为空字符串时，返回原字符串中 Rune 的数量加一。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello, 世界, Hello"

    // 计算子串在字符串中出现的次数
    let count1 = str.count("Hello")
    let count2 = str.count("世界")
    let count3 = str.count("World")
    let count4 = str.count("")

    println("String: '${str}'")
    println("Count of 'Hello': ${count1}")
    println("Count of '世界': ${count2}")
    println("Count of 'World': ${count3}")
    println("Count of empty string: ${count4}")
}
```

运行结果：

```text
String: 'Hello, Hello, 世界, Hello'
Count of 'Hello': 3
Count of '世界': 1
Count of 'World': 0
Count of empty string: 24
```

### func endsWith(String)

```cangjie
public func endsWith(suffix: String): Bool
```

功能：判断原字符串是否以 suffix 字符串为后缀结尾。

参数：

- suffix: [String](core_package_structs.md#struct-string) - 被判断的后缀字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果字符串 str 是原字符串的后缀，返回 true，否则返回 false，特别地，如果 str 字符串长度为 0，返回 true。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, 世界"
    let str2 = "world"
    let str3 = ""

    // 检查字符串是否以特定后缀结尾
    let endsWith1 = str1.endsWith("世界")
    let endsWith2 = str1.endsWith("Hello")
    let endsWith3 = str2.endsWith("world")
    let endsWith4 = str3.endsWith("")
    let endsWith5 = str1.endsWith("")

    println("String 1: '${str1}'")
    println("Ends with '世界': ${endsWith1}")
    println("Ends with 'Hello': ${endsWith2}")
    println("String 2: '${str2}'")
    println("Ends with 'world': ${endsWith3}")
    println("Empty string ends with empty string: ${endsWith4}")
    println("String 1 ends with empty string: ${endsWith5}")
}
```

运行结果：

```text
String 1: 'Hello, 世界'
Ends with '世界': true
Ends with 'Hello': false
String 2: 'world'
Ends with 'world': true
Empty string ends with empty string: true
String 1 ends with empty string: true
```

### func equalsIgnoreAsciiCase(String): Bool

```cangjie
public func equalsIgnoreAsciiCase(other: String): Bool
```

功能：判断当前字符串和指定字符串是否相等，忽略大小写。

参数：

- other: [String](./core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](./core_package_intrinsics.md#bool) - 如果当前字符串与待比较字符串相等，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "HELLO"
    let str3 = "hello"
    let str4 = "Hello, World"
    let str5 = "Hello, world"
    let str6 = "Hello, 世界"
    let str7 = "HELLO, 世界"

    // 检查字符串是否相等（忽略ASCII大小写）
    let equals1 = str1.equalsIgnoreAsciiCase(str2)
    let equals2 = str1.equalsIgnoreAsciiCase(str3)
    let equals3 = str4.equalsIgnoreAsciiCase(str5)
    let equals4 = str6.equalsIgnoreAsciiCase(str7)
    let equals5 = str1.equalsIgnoreAsciiCase(str4)

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("Equals ignore case (str1, str2): ${equals1}")
    println("String 3: '${str3}'")
    println("Equals ignore case (str1, str3): ${equals2}")
    println("String 4: '${str4}'")
    println("String 5: '${str5}'")
    println("Equals ignore case (str4, str5): ${equals3}")
    println("String 6: '${str6}'")
    println("String 7: '${str7}'")
    println("Equals ignore case (str6, str7): ${equals4}")
    println("Equals ignore case (str1, str4): ${equals5}")
}
```

运行结果：

```text
String 1: 'Hello'
String 2: 'HELLO'
Equals ignore case (str1, str2): true
String 3: 'hello'
Equals ignore case (str1, str3): true
String 4: 'Hello, World'
String 5: 'Hello, world'
Equals ignore case (str4, str5): true
String 6: 'Hello, 世界'
String 7: 'HELLO, 世界'
Equals ignore case (str6, str7): true
Equals ignore case (str1, str4): false
```

### func get(Int64)

```cangjie
public func get(index: Int64): Option<Byte>
```

功能：返回字符串下标 index 对应的 UTF-8 编码字节值。

参数：

- index: [Int64](core_package_intrinsics.md#int64) - 要获取的字节值的下标。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Byte](core_package_types.md#type-byte)> - 获取得到下标对应的 UTF-8 编码字节值，当 index 小于 0 或者大于等于字符串长度，则返回 [Option](core_package_enums.md#enum-optiont)\<[Byte](core_package_types.md#type-byte)>.None。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 获取指定索引的字节值
    let byte1 = str.get(0) // 'H' 的ASCII码
    let byte2 = str.get(7) // '世' 的UTF-8编码的第一个字节
    let byte3 = str.get(100) // 超出范围的索引

    println("String: '${str}'")
    println("Byte at index 0: ${byte1}")
    println("Byte at index 7: ${byte2}")
    println("Byte at index 100: ${byte3}")
}
```

运行结果：

```text
String: 'Hello, 世界'
Byte at index 0: Some(72)
Byte at index 7: Some(228)
Byte at index 100: None
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取字符串的哈希值。

返回值：

- [Int64](core_package_intrinsics.md#int64) - 返回字符串的哈希值。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 获取哈希值
    let hashCode = str.hashCode()
    println("hashCode: ${hashCode}")
}
```

运行结果：

```text
hashCode: -255291815105879447
```

### func indexOf(Byte)

```cangjie
public func indexOf(b: Byte): Option<Int64>
```

功能：获取指定字节 b 第一次出现的在原字符串内的索引。

参数：

- b: [Byte](core_package_types.md#type-byte) - 待搜索的字节。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果原字符串中包含指定字节，返回其第一次出现的索引，如果原字符串中没有此字节，返回 [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)>.None。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 查找字符 'l' 第一次出现的位置
    let index1 = str.indexOf(108u8) // 'l' 的ASCII码是108

    // 查找字符 '世' 第一次出现的位置
    let index2 = str.indexOf(228u8) // '世' 的UTF-8编码的第一个字节是228

    // 查找不存在的字符
    let index3 = str.indexOf(122u8) // 'z' 的ASCII码是122

    println("String: '${str}'")
    println("Index of 'l' (108u8): ${index1}")
    println("Index of '世' first byte (228u8): ${index2}")
    println("Index of 'z' (122u8): ${index3}")
}
```

运行结果：

```text
String: 'Hello, 世界'
Index of 'l' (108u8): Some(2)
Index of '世' first byte (228u8): Some(7)
Index of 'z' (122u8): None
```

### func indexOf(Byte, Int64)

```cangjie
public func indexOf(b: Byte, fromIndex: Int64): Option<Int64>
```

功能：从原字符串指定索引开始搜索，获取指定字节第一次出现的在原字符串内的索引。

参数：

- b: [Byte](core_package_types.md#type-byte) - 待搜索的字节。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 以指定的索引 fromIndex 开始搜索。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果搜索成功，返回指定字节第一次出现的索引，否则返回 `None`。特别地，当 fromIndex 小于零，效果同 0，当 fromIndex 大于等于原字符串长度，返回 [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)>.None。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello"

    // 从指定索引开始查找字符 'l' 第一次出现的位置
    let index1 = str.indexOf(108u8, 3) // 'l' 的ASCII码是108，从索引3开始查找

    // 从指定索引开始查找字符 'H' 第一次出现的位置
    let index2 = str.indexOf(72u8, 1) // 'H' 的ASCII码是72，从索引1开始查找

    // 查找不存在的字符
    let index3 = str.indexOf(122u8, 0) // 'z' 的ASCII码是122

    println("String: '${str}'")
    println("Index of 'l' (108u8) from index 3: ${index1}")
    println("Index of 'H' (72u8) from index 1: ${index2}")
    println("Index of 'z' (122u8) from index 0: ${index3}")
}
```

运行结果：

```text
String: 'Hello, Hello'
Index of 'l' (108u8) from index 3: Some(3)
Index of 'H' (72u8) from index 1: Some(7)
Index of 'z' (122u8) from index 0: None
```

### func indexOf(String)

```cangjie
public func indexOf(str: String): Option<Int64>
```

功能：返回指定字符串 str 在原字符串中第一次出现的起始索引。

参数：

- str: [String](core_package_structs.md#struct-string) - 待搜索的字符串。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果原字符串包含 str 字符串，返回其第一次出现的索引，如果原字符串中没有 str 字符串，返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello, 世界"

    // 查找子串 "Hello" 第一次出现的位置
    let index1 = str.indexOf("Hello")

    // 查找子串 "世界" 第一次出现的位置
    let index2 = str.indexOf("世界")

    // 查找不存在的子串
    let index3 = str.indexOf("World")

    println("String: '${str}'")
    println("Index of 'Hello': ${index1}")
    println("Index of '世界': ${index2}")
    println("Index of 'World': ${index3}")
}
```

运行结果：

```text
String: 'Hello, Hello, 世界'
Index of 'Hello': Some(0)
Index of '世界': Some(14)
Index of 'World': None
```

### func indexOf(String, Int64)

```cangjie
public func indexOf(str: String, fromIndex: Int64): Option<Int64>
```

功能：从原字符串 fromIndex 索引开始搜索，获取指定字符串 str 第一次出现的在原字符串的起始索引。

参数：

- str: [String](core_package_structs.md#struct-string) - 待搜索的字符串。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 以指定的索引 fromIndex 开始搜索。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果搜索成功，返回 str 第一次出现的索引，否则返回 None。特别地，当 str 是空字符串时，如果 fromIndex 大于 0，返回 None，否则返回 Some(0)。当 fromIndex 小于零，效果同 0，当 fromIndex 大于等于原字符串长度返回 None。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello, 世界"

    // 从指定索引开始查找子串 "Hello" 第一次出现的位置
    let index1 = str.indexOf("Hello", 1)

    // 从指定索引开始查找子串 "llo" 第一次出现的位置
    let index2 = str.indexOf("llo", 5)

    // 从指定索引开始查找不存在的子串
    let index3 = str.indexOf("World", 0)

    println("String: '${str}'")
    println("Index of 'Hello' from index 1: ${index1}")
    println("Index of 'llo' from index 5: ${index2}")
    println("Index of 'World' from index 0: ${index3}")
}
```

运行结果：

```text
String: 'Hello, Hello, 世界'
Index of 'Hello' from index 1: Some(7)
Index of 'llo' from index 5: Some(9)
Index of 'World' from index 0: None
```

### func isAscii()

```cangjie
public func isAscii(): Bool
```

功能：判断字符串是否是一个 Ascii 字符串，如果字符串为空或没有 Ascii 以外的字符，则返回 true。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 是则返回 true，不是则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "Hello, 世界"
    let str3 = ""
    let str4 = "123456"

    // 检查字符串是否为ASCII字符串
    let isAscii1 = str1.isAscii()
    let isAscii2 = str2.isAscii()
    let isAscii3 = str3.isAscii()
    let isAscii4 = str4.isAscii()

    println("String 1: '${str1}', is ASCII: ${isAscii1}")
    println("String 2: '${str2}', is ASCII: ${isAscii2}")
    println("String 3: '${str3}', is ASCII: ${isAscii3}")
    println("String 4: '${str4}', is ASCII: ${isAscii4}")
}
```

运行结果：

```text
String 1: 'Hello', is ASCII: true
String 2: 'Hello, 世界', is ASCII: false
String 3: '', is ASCII: true
String 4: '123456', is ASCII: true
```

### func isAsciiBlank()

```cangjie
public func isAsciiBlank(): Bool
```

功能：判断字符串是否为空或者字符串中的所有 Rune 都是 ascii 码的空白字符（包括：0x09、0x10、0x11、0x12、0x13、0x20）。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果是返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = ""
    let str2 = "   "
    let str3 = "\t\n\r"
    let str4 = "Hello"
    let str5 = " \t\n\r "

    // 检查字符串是否为空或只包含ASCII空白字符
    let isAsciiBlank1 = str1.isAsciiBlank()
    let isAsciiBlank2 = str2.isAsciiBlank()
    let isAsciiBlank3 = str3.isAsciiBlank()
    let isAsciiBlank4 = str4.isAsciiBlank()
    let isAsciiBlank5 = str5.isAsciiBlank()

    println("String 1: '${str1}', is ASCII blank: ${isAsciiBlank1}")
    println("String 2: '${str2}', is ASCII blank: ${isAsciiBlank2}")
    println("String 3: '${str3}', is ASCII blank: ${isAsciiBlank3}")
    println("String 4: '${str4}', is ASCII blank: ${isAsciiBlank4}")
    println("String 5: '${str5}', is ASCII blank: ${isAsciiBlank5}")
}
```

运行结果：

```text
String 1: '', is ASCII blank: true
String 2: '   ', is ASCII blank: true
String 3: '	

', is ASCII blank: true
String 4: 'Hello', is ASCII blank: false
String 5: ' 	

 ', is ASCII blank: true
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

功能：判断原字符串是否为空字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果为空返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = ""
    let str2 = "Hello"
    let str3 = " "

    // 检查字符串是否为空
    let isEmpty1 = str1.isEmpty()
    let isEmpty2 = str2.isEmpty()
    let isEmpty3 = str3.isEmpty()

    println("String 1: '${str1}', is empty: ${isEmpty1}")
    println("String 2: '${str2}', is empty: ${isEmpty2}")
    println("String 3: '${str3}', is empty: ${isEmpty3}")
}
```

运行结果：

```text
String 1: '', is empty: true
String 2: 'Hello', is empty: false
String 3: ' ', is empty: false
```

### func iterator()

```cangjie
public func iterator(): Iterator<Byte>
```

功能：获取字符串的 UTF-8 编码字节迭代器，可用于支持 for-in 循环。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<[Byte](core_package_types.md#type-byte)> - 字符串的 UTF-8 编码字节迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "abc"

    /* 迭代器元素为每个字符的 utf-8 编码 */
    for (i in str) {
        println(i)
    }
}
```

运行结果：

```text
97
98
99
```

### func lastIndexOf(Byte)

```cangjie
public func lastIndexOf(b: Byte): Option<Int64>
```

功能：返回指定字节 b 最后一次出现的在原字符串内的索引。

参数：

- b: [Byte](core_package_types.md#type-byte) - 待搜索的字节。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果原字符串中包含此字节，返回其最后一次出现的索引，否则返回 `None`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 查找字符 'l' 最后一次出现的位置
    let lastIndex1 = str.lastIndexOf(108u8) // 'l' 的ASCII码是108

    // 查找字符 '世' 最后一次出现的位置
    let lastIndex2 = str.lastIndexOf(228u8) // '世' 的UTF-8编码的第一个字节是228

    // 查找不存在的字符
    let lastIndex3 = str.lastIndexOf(122u8) // 'z' 的ASCII码是122

    println("String: '${str}'")
    println("Last index of 'l' (108u8): ${lastIndex1}")
    println("Last index of '世' first byte (228u8): ${lastIndex2}")
    println("Last index of 'z' (122u8): ${lastIndex3}")
}
```

运行结果：

```text
String: 'Hello, 世界'
Last index of 'l' (108u8): Some(3)
Last index of '世' first byte (228u8): Some(7)
Last index of 'z' (122u8): None
```

### func lastIndexOf(Byte, Int64)

```cangjie
public func lastIndexOf(b: Byte, fromIndex: Int64): Option<Int64>
```

功能：从原字符串 fromIndex 索引开始搜索，返回指定 UTF-8 编码字节 b 最后一次出现的在原字符串内的索引。

参数：

- b: [Byte](core_package_types.md#type-byte) - 待搜索的字节。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 以指定的索引 fromIndex 开始搜索。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果搜索成功，返回指定字节最后一次出现的索引，否则返回 `None`。特别地，当 fromIndex 小于零，效果同 0，当 fromIndex 大于等于原字符串长度，返回 `None`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello"

    // 从指定索引开始查找字符 'l' 最后一次出现的位置
    let lastIndex1 = str.lastIndexOf(108u8, 10) // 'l' 的ASCII码是108，从索引10开始查找

    // 从指定索引开始查找字符 'H' 最后一次出现的位置
    let lastIndex2 = str.lastIndexOf(72u8, 5) // 'H' 的ASCII码是72，从索引5开始查找

    // 查找不存在的字符
    let lastIndex3 = str.lastIndexOf(122u8, 5) // 'z' 的ASCII码是122，从索引5开始查找

    println("String: '${str}'")
    println("Last index of 'l' (108u8) from index 10: ${lastIndex1}")
    println("Last index of 'H' (72u8) from index 5: ${lastIndex2}")
    println("Last index of 'z' (122u8) from index 5: ${lastIndex3}")
}
```

运行结果：

```text
String: 'Hello, Hello'
Last index of 'l' (108u8) from index 10: Some(10)
Last index of 'H' (72u8) from index 5: Some(7)
Last index of 'z' (122u8) from index 5: None
```

### func lastIndexOf(String)

```cangjie
public func lastIndexOf(str: String): Option<Int64>
```

功能：返回指定字符串 str 最后一次出现的在原字符串的起始索引。

参数：

- str: [String](core_package_structs.md#struct-string) - 待搜索的字符串。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果原字符串中包含 str 字符串，返回其最后一次出现的索引，否则返回 `None`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello, 世界"

    // 查找子串 "Hello" 最后一次出现的位置
    let lastIndex1 = str.lastIndexOf("Hello")

    // 查找子串 "世界" 最后一次出现的位置
    let lastIndex2 = str.lastIndexOf("世界")

    // 查找不存在的子串
    let lastIndex3 = str.lastIndexOf("World")

    println("String: '${str}'")
    println("Last index of 'Hello': ${lastIndex1}")
    println("Last index of '世界': ${lastIndex2}")
    println("Last index of 'World': ${lastIndex3}")
}
```

运行结果：

```text
String: 'Hello, Hello, 世界'
Last index of 'Hello': Some(7)
Last index of '世界': Some(14)
Last index of 'World': None
```

### func lastIndexOf(String, Int64)

```cangjie
public func lastIndexOf(str: String, fromIndex: Int64): Option<Int64>
```

功能：从原字符串指定索引开始搜索，获取指定字符串 str 最后一次出现的在原字符串的起始索引。

参数：

- str: [String](core_package_structs.md#struct-string) - 待搜索的字符串。
- fromIndex: [Int64](core_package_intrinsics.md#int64) - 以指定的索引 fromIndex 开始搜索。

返回值：

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - 如果这个字符串在位置 fromIndex 及其之后没有出现，则返回 `None`。特别地，当 str 是空字符串时，如果 fromIndex 大于 0，返回 `None`，否则返回 `Some(0)`，当 fromIndex 小于零，效果同 0，当 fromIndex 大于等于原字符串长度返回 `None`。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, Hello, 世界"

    // 从指定索引开始查找子串 "Hello" 最后一次出现的位置
    let lastIndex1 = str.lastIndexOf("Hello", 6)

    // 从指定索引开始查找子串 "llo" 最后一次出现的位置
    let lastIndex2 = str.lastIndexOf("llo", 6)

    // 从指定索引开始查找不存在的子串
    let lastIndex3 = str.lastIndexOf("World", 10)

    println("String: '${str}'")
    println("Last index of 'Hello' from index 6: ${lastIndex1}")
    println("Last index of 'llo' from index 6: ${lastIndex2}")
    println("Last index of 'World' from index 10: ${lastIndex3}")
}
```

运行结果：

```text
String: 'Hello, Hello, 世界'
Last index of 'Hello' from index 6: Some(7)
Last index of 'llo' from index 6: Some(9)
Last index of 'World' from index 10: None
```

### func lazySplit(String, Bool)

```cangjie
public func lazySplit(str: String, removeEmpty!: Bool = false): Iterator<String>
```

功能：对原字符串按照字符串 str 分隔符分割，该函数不立即对字符串进行分割，而是返回迭代器，使用迭代器进行遍历时再实际执行分隔操作。

当 str 未出现在原字符串中，返回大小为 1 的字符串迭代器，唯一的元素为原字符串。

参数：

- str: [String](core_package_structs.md#struct-string) - 字符串分隔符。
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - 移除分割结果中的空字符串，默认值为 false。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - 分割后的字符串迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "I like Cangjie"
    var iter = str.lazySplit(" ")
    while (true) {
        match (iter.next()) {
            case Some(i) => println(i)
            case None => break
        }
    }
}
```

运行结果：

```text
I
like
Cangjie
```

### func lazySplit(String, Int64, Bool)

```cangjie
public func lazySplit(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Iterator<String>
```

功能：对原字符串按照字符串 str 分隔符分割，该函数不立即对字符串进行分割，而是返回迭代器，使用迭代器进行遍历时再实际执行分隔操作。

- 当 maxSplit 为 0 时，返回空的字符串迭代器；
- 当 maxSplit 为 1 时，返回大小为 1 的字符串迭代器，唯一的元素为原字符串；
- 当 maxSplit 为负数时，直接返回分割后的字符串迭代器；
- 当 maxSplit 大于完整分割出来的子字符串数量时，返回完整分割的字符串迭代器；
- 当 str 未出现在原字符串中，返回大小为 1 的字符串迭代器，唯一的元素为原字符串；
- 当 str 为空时，对每个字符进行分割；当原字符串和分隔符都为空时，返回空字符串迭代器。

参数：

- str: [String](core_package_structs.md#struct-string) - 字符串分隔符。
- maxSplits: [Int64](core_package_intrinsics.md#int64) - 最多分割为 maxSplit 个子字符串。
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - 移除分割结果中的空字符串，默认值为 false。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - 分割后的字符串迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "I like Cangjie"
    var iter = str.lazySplit(" ", 2, removeEmpty: true)
    while (true) {
        match (iter.next()) {
            case Some(i) => println(i)
            case None => break
        }
    }
}
```

运行结果：

```text
I
like Cangjie
```

### func lines()

```cangjie
public func lines(): Iterator<String>
```

功能：获取字符串的行迭代器，每行都由换行符进行分隔，换行符是 `\n` `\r` `\r\n` 之一，结果中每行不包括换行符。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - 字符串的行迭代器。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "I\rlike\nCangjie\r"
    var iter = str.lines()
    while (true) {
        match (iter.next()) {
            case Some(i) => println(i)
            case None => break
        }
    }
}
```

运行结果：

```text
I
like
Cangjie
```

### func padEnd(Int64, String)

```cangjie
public func padEnd(totalWidth: Int64, padding!: String = " "): String
```

功能：按指定长度左对齐原字符串，如果原字符串长度小于指定长度，在其右侧添加指定字符串。

当指定长度小于字符串长度时，返回字符串本身，不会发生截断；当指定长度大于字符串长度时，在右侧添加 padding 字符串，当 padding 长度大于 1 时，返回字符串的长度可能大于指定长度。

参数：

- totalWidth: [Int64](core_package_intrinsics.md#int64) - 指定对齐后字符串长度，取值需大于等于 0。
- padding!: [String](core_package_structs.md#struct-string) - 当长度不够时，在右侧用指定的字符串 padding 进行填充。

返回值：

- [String](core_package_structs.md#struct-string) - 填充后的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 totalWidth 小于 0，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "World"

    // 使用padEnd函数在右侧填充字符串
    let padded1 = str1.padEnd(10, padding: "-")
    let padded2 = str2.padEnd(10, padding: " ")
    let padded3 = str1.padEnd(3, padding: "-") // 长度小于原字符串长度

    println("Original string 1: '${str1}'")
    println("Padded string 1: '${padded1}'")
    println("Original string 2: '${str2}'")
    println("Padded string 2: '${padded2}'")
    println("String padded to smaller width: '${padded3}'")
}
```

运行结果：

```text
Original string 1: 'Hello'
Padded string 1: 'Hello-----'
Original string 2: 'World'
Padded string 2: 'World     '
String padded to smaller width: 'Hello'
```

### func padStart(Int64, String)

```cangjie
public func padStart(totalWidth: Int64, padding!: String = " "): String
```

功能：按指定长度右对齐原字符串，如果原字符串长度小于指定长度，在其左侧添加指定字符串。

当指定长度小于字符串长度时，返回字符串本身，不会发生截断；当指定长度大于字符串长度时，在左侧添加 padding 字符串，当 padding 长度大于 1 时，返回字符串的长度可能大于指定长度。

参数：

- totalWidth: [Int64](core_package_intrinsics.md#int64) - 指定对齐后字符串长度，取值需大于等于 0。
- padding!: [String](core_package_structs.md#struct-string) - 当长度不够时，在左侧用指定的字符串 padding 进行填充

返回值：

- [String](core_package_structs.md#struct-string) - 填充后的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 totalWidth 小于 0，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "World"

    // 使用padStart函数在左侧填充字符串
    let padded1 = str1.padStart(10, padding: "-")
    let padded2 = str2.padStart(10, padding: " ")
    let padded3 = str1.padStart(3, padding: "-") // 长度小于原字符串长度

    println("Original string 1: '${str1}'")
    println("Padded string 1: '${padded1}'")
    println("Original string 2: '${str2}'")
    println("Padded string 2: '${padded2}'")
    println("String padded to smaller width: '${padded3}'")
}
```

运行结果：

```text
Original string 1: 'Hello'
Padded string 1: '-----Hello'
Original string 2: 'World'
Padded string 2: '     World'
String padded to smaller width: 'Hello'
```

### func rawData()

```cangjie
public unsafe func rawData(): Array<Byte>
```

功能：获取字符串的 UTF-8 编码的原始字节数组。

> **注意：**
>
> 用户不应该对获取的数组进行修改，这将破坏字符串的不可变性。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[Byte](core_package_types.md#type-byte)> - 当前字符串对应的原始字节数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "Hello, 世界"

    // 获取字符串的原始字节数组
    let rawData = unsafe { str.rawData() }

    println("String: '${str}'")
    println("Raw data length: ${rawData.size}")
    println("Raw data bytes:")
    for (i in 0..rawData.size) {
        println("  Index ${i}: ${rawData[i]}")
    }
}
```

运行结果：

```text
String: 'Hello, 世界'
Raw data length: 13
Raw data bytes:
  Index 0: 72
  Index 1: 101
  Index 2: 108
  Index 3: 108
  Index 4: 111
  Index 5: 44
  Index 6: 32
  Index 7: 228
  Index 8: 184
  Index 9: 150
  Index 10: 231
  Index 11: 149
  Index 12: 140
```

### func removePrefix(String)

```cangjie
public func removePrefix(prefix: String): String
```

功能：去除字符串的 prefix 前缀。

参数：

- prefix: [String](core_package_structs.md#struct-string) - 待去除的前缀。

返回值：

- [String](core_package_structs.md#struct-string) - 去除前缀后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = "Hello"

    // 使用removePrefix函数去除前缀
    let removed1 = str1.removePrefix("Hello")
    let removed2 = str2.removePrefix("Hello")
    let removed3 = str3.removePrefix("Hello")
    let removed4 = str1.removePrefix("World") // 不存在的前缀

    println("Original string 1: '${str1}'")
    println("After removing 'Hello': '${removed1}'")
    println("Original string 2: '${str2}'")
    println("After removing 'Hello': '${removed2}'")
    println("Original string 3: '${str3}'")
    println("After removing 'Hello': '${removed3}'")
    println("Original string 1: '${str1}'")
    println("After removing 'World': '${removed4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World'
After removing 'Hello': ', World'
Original string 2: 'Hello, 世界'
After removing 'Hello': ', 世界'
Original string 3: 'Hello'
After removing 'Hello': ''
Original string 1: 'Hello, World'
After removing 'World': 'Hello, World'
```

### func removeSuffix(String)

```cangjie
public func removeSuffix(suffix: String): String
```

功能：去除字符串的 suffix 后缀。

参数：

- suffix: [String](core_package_structs.md#struct-string) - 待去除的后缀。

返回值：

- [String](core_package_structs.md#struct-string) - 去除后缀后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = "World"

    // 使用removeSuffix函数去除后缀
    let removed1 = str1.removeSuffix("World")
    let removed2 = str2.removeSuffix("世界")
    let removed3 = str3.removeSuffix("World")
    let removed4 = str1.removeSuffix("Hello") // 不存在的后缀

    println("Original string 1: '${str1}'")
    println("After removing 'World': '${removed1}'")
    println("Original string 2: '${str2}'")
    println("After removing '世界': '${removed2}'")
    println("Original string 3: '${str3}'")
    println("After removing 'World': '${removed3}'")
    println("Original string 1: '${str1}'")
    println("After removing 'Hello': '${removed4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World'
After removing 'World': 'Hello, '
Original string 2: 'Hello, 世界'
After removing '世界': 'Hello, '
Original string 3: 'World'
After removing 'World': ''
Original string 1: 'Hello, World'
After removing 'Hello': 'Hello, World'
```

### func replace(String, String)

```cangjie
public func replace(old: String, new: String): String
```

功能：使用新字符串替换原字符串中旧字符串。

参数：

- old: [String](core_package_structs.md#struct-string) - 旧字符串。
- new: [String](core_package_structs.md#struct-string) - 新字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 替换后的新字符串。

异常：

- [OutOfMemoryError](core_package_exceptions.md#class-outofmemoryerror) - 如果此函数分配内存时产生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "Hello, Hello, World"
    let str3 = "Hello"

    // 使用replace函数替换字符串
    let replaced1 = str1.replace("World", "Cangjie")
    let replaced2 = str2.replace("Hello", "Hi")
    let replaced3 = str3.replace("World", "Cangjie") // 不存在的子串
    let replaced4 = str1.replace("Hello", "") // 替换为空字符串

    println("Original string 1: '${str1}'")
    println("After replacing 'World' with 'Cangjie': '${replaced1}'")
    println("Original string 2: '${str2}'")
    println("After replacing 'Hello' with 'Hi': '${replaced2}'")
    println("Original string 3: '${str3}'")
    println("After replacing 'World' with 'Cangjie': '${replaced3}'")
    println("Original string 1: '${str1}'")
    println("After replacing 'Hello' with empty string: '${replaced4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World'
After replacing 'World' with 'Cangjie': 'Hello, Cangjie'
Original string 2: 'Hello, Hello, World'
After replacing 'Hello' with 'Hi': 'Hi, Hi, World'
Original string 3: 'Hello'
After replacing 'World' with 'Cangjie': 'Hello'
Original string 1: 'Hello, World'
After replacing 'Hello' with empty string: ', World'
```

### func runes()

```cangjie
public func runes(): Iterator<Rune>
```

功能：获取字符串的 Rune 迭代器。

返回值：

- [Iterator](core_package_classes.md#class-iteratort)\<Rune> - 字符串的 Rune 迭代器。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 使用 `for-in` 或者 `next()` 方法遍历迭代器时，如果读取到非法字符，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个包含中英文的字符串
    let str = "Hello, 世界"

    // 使用runes函数获取字符串的Rune迭代器
    let runesIter = str.runes()

    println("String: '${str}'")
    println("Runes:")

    // 遍历Rune迭代器并打印每个字符
    var index = 0
    while (true) {
        let next = runesIter.next()
        match (next) {
            case Some(rune) => println("  Index ${index}: ${rune}")
            case None => break
        }
        index = index + 1
    }
}
```

运行结果：

```text
String: 'Hello, 世界'
Runes:
  Index 0: H
  Index 1: e
  Index 2: l
  Index 3: l
  Index 4: o
  Index 5: ,
  Index 6:  
  Index 7: 世
  Index 8: 界
```

### func split(String, Bool)

```cangjie
public func split(str: String, removeEmpty!: Bool = false): Array<String>
```

功能：对原字符串按照分隔符分割。可以指定是否删除空串。

> **说明：**
>
> - 原字符串为空时，返回数组长度一律为 0。
> - 当分隔符未出现在原字符串（非空）中，返回长度为 1 的字符串数组，唯一的元素为原字符串。

参数：

- str: [String](core_package_structs.md#struct-string) - 字符串分隔符。
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - 移除分割结果中的空字符串，默认值为 false。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - 分割后的字符串数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "one,two,,three"

    // 使用split函数分割字符串
    let result1 = str.split(",")

    println("原字符串: '${str}'")
    println("分割结果:")
    for (i in result1) {
        println(" '${i}'")
    }
    // 使用split函数分割字符串，并移除空串
    let result2 = str.split(",", removeEmpty: true)
    println("分割结果(移除空串):")
    for (i in result2) {
        println(" '${i}'")
    }
}
```

运行结果：

```text
原字符串: 'one,two,,three'
分割结果:
 'one'
 'two'
 ''
 'three'
分割结果(移除空串):
 'one'
 'two'
 'three'
```

### func split(String, Int64, Bool)

```cangjie
public func split(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Array<String>
```

功能：对原字符串按照分隔符分割。需指定最多分隔子串数，并可以指定是否删除空串。

> **说明：**
>
> - 原字符串为空时，返回数组长度一律为 0。
> - 当最多分隔子串数为 0 时，返回空的字符串数组。
> - 当最多分隔子串数为 1 时（原字符串非空），返回长度为 1 的字符串数组，唯一的元素为原字符串。
> - 当最多分隔子串数为负数时，返回完整分割后的字符串数组。
> - 当最多分隔子串数大于完整分割出来的子字符串数量时，返回完整分割的字符串数组。
> - 当分隔符未出现在原字符串（非空）中，返回长度为 1 的字符串数组，唯一的元素为原字符串。
> - 当分隔符为空时，对每个字符进行分割。

参数：

- str: [String](core_package_structs.md#struct-string) - 字符串分隔符。
- maxSplits: [Int64](core_package_intrinsics.md#int64) - 最多分割为 maxSplit 个子字符串。
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - 移除分割结果中的空字符串，默认值为 false。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - 分割后的字符串数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串
    let str = "one,two,three,four,five"

    // 使用split函数分割字符串，最多分割为3个子字符串
    let result1 = str.split(",", 3)

    println("原字符串: '${str}'")
    println("分割结果:")
    for (i in result1) {
        println(" '${i}'")
    }
}
```

运行结果：

```text
原字符串: 'one,two,three,four,five'
分割结果:
 'one'
 'two'
 'three,four,five'
```

### func startsWith(String)

```cangjie
public func startsWith(prefix: String): Bool
```

功能：判断原字符串是否以 prefix 字符串为前缀。

参数：

- prefix: [String](core_package_structs.md#struct-string) - 被判断的前缀字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 如果字符串 str 是原字符串的前缀，返回 true，否则返回 false，特别地，如果 str 字符串长度为 0，返回 true。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = ""

    // 使用startsWith函数检查字符串前缀
    let startsWith1 = str1.startsWith("Hello")
    let startsWith2 = str1.startsWith("World")
    let startsWith3 = str2.startsWith("Hello")
    let startsWith4 = str2.startsWith("世界")
    let startsWith5 = str3.startsWith("")
    let startsWith6 = str1.startsWith("")

    println("String 1: '${str1}'")
    println("Starts with 'Hello': ${startsWith1}")
    println("Starts with 'World': ${startsWith2}")

    println("String 2: '${str2}'")
    println("Starts with 'Hello': ${startsWith3}")
    println("Starts with '世界': ${startsWith4}")

    println("Empty string starts with empty string: ${startsWith5}")
    println("String 1 starts with empty string: ${startsWith6}")
}
```

运行结果：

```text
String 1: 'Hello, World'
Starts with 'Hello': true
Starts with 'World': false
String 2: 'Hello, 世界'
Starts with 'Hello': true
Starts with '世界': false
Empty string starts with empty string: true
String 1 starts with empty string: true
```

### func toArray()

```cangjie
public func toArray(): Array<Byte>
```

功能：获取字符串的 UTF-8 编码的字节数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<[Byte](core_package_types.md#type-byte)> - 字符串的 UTF-8 编码的字节数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "Hello, 世界"

    // 使用toArray函数获取字符串的UTF-8编码字节数组
    let byteArray = str.toArray()

    println("String: '${str}'")
    println("Byte array size: ${byteArray.size}")
    println("Byte array elements:")
    for (i in 0..byteArray.size) {
        println("  Index ${i}: ${byteArray[i]}")
    }
}
```

运行结果：

```text
String: 'Hello, 世界'
Byte array size: 13
Byte array elements:
  Index 0: 72
  Index 1: 101
  Index 2: 108
  Index 3: 108
  Index 4: 111
  Index 5: 44
  Index 6: 32
  Index 7: 228
  Index 8: 184
  Index 9: 150
  Index 10: 231
  Index 11: 149
  Index 12: 140
```

### func toAsciiLower()

```cangjie
public func toAsciiLower(): String
```

功能：将该字符串中所有 Ascii 大写字母转化为 Ascii 小写字母。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "CANGJIE Programming"
    let str3 = "123ABC456"
    let str4 = "你好World"

    // 使用toAsciiLower函数将ASCII大写字母转换为小写
    let lower1 = str1.toAsciiLower()
    let lower2 = str2.toAsciiLower()
    let lower3 = str3.toAsciiLower()
    let lower4 = str4.toAsciiLower()

    println("Original string 1: '${str1}'")
    println("To ASCII lower 1: '${lower1}'")

    println("Original string 2: '${str2}'")
    println("To ASCII lower 2: '${lower2}'")

    println("Original string 3: '${str3}'")
    println("To ASCII lower 3: '${lower3}'")

    println("Original string 4: '${str4}'")
    println("To ASCII lower 4: '${lower4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World'
To ASCII lower 1: 'hello, world'
Original string 2: 'CANGJIE Programming'
To ASCII lower 2: 'cangjie programming'
Original string 3: '123ABC456'
To ASCII lower 3: '123abc456'
Original string 4: '你好World'
To ASCII lower 4: '你好world'
```

### func toAsciiTitle()

```cangjie
public func toAsciiTitle(): String
```

功能：将该字符串标题化。

该函数只转换 Ascii 英文字符，当该英文字符是字符串中第一个字符或者该字符的前一个字符不是英文字符，则该字符大写，其他英文字符小写。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "hello world"
    let str2 = "CANGJIE programming"
    let str3 = "123abc456"
    let str4 = "你好world"

    // 使用toAsciiTitle函数将字符串标题化
    let title1 = str1.toAsciiTitle()
    let title2 = str2.toAsciiTitle()
    let title3 = str3.toAsciiTitle()
    let title4 = str4.toAsciiTitle()

    println("Original string 1: '${str1}'")
    println("To ASCII title 1: '${title1}'")

    println("Original string 2: '${str2}'")
    println("To ASCII title 2: '${title2}'")

    println("Original string 3: '${str3}'")
    println("To ASCII title 3: '${title3}'")

    println("Original string 4: '${str4}'")
    println("To ASCII title 4: '${title4}'")
}
```

运行结果：

```text
Original string 1: 'hello world'
To ASCII title 1: 'Hello World'
Original string 2: 'CANGJIE programming'
To ASCII title 2: 'Cangjie Programming'
Original string 3: '123abc456'
To ASCII title 3: '123Abc456'
Original string 4: '你好world'
To ASCII title 4: '你好World'
```

### func toAsciiUpper()

```cangjie
public func toAsciiUpper(): String
```

功能：将该字符串中所有 Ascii 小写字母转化为 Ascii 大写字母。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World"
    let str2 = "cangjie programming"
    let str3 = "123abc456"
    let str4 = "你好world"

    // 使用toAsciiUpper函数将ASCII小写字母转换为大写
    let upper1 = str1.toAsciiUpper()
    let upper2 = str2.toAsciiUpper()
    let upper3 = str3.toAsciiUpper()
    let upper4 = str4.toAsciiUpper()

    println("Original string 1: '${str1}'")
    println("To ASCII upper 1: '${upper1}'")

    println("Original string 2: '${str2}'")
    println("To ASCII upper 2: '${upper2}'")

    println("Original string 3: '${str3}'")
    println("To ASCII upper 3: '${upper3}'")

    println("Original string 4: '${str4}'")
    println("To ASCII upper 4: '${upper4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World'
To ASCII upper 1: 'HELLO, WORLD'
Original string 2: 'cangjie programming'
To ASCII upper 2: 'CANGJIE PROGRAMMING'
Original string 3: '123abc456'
To ASCII upper 3: '123ABC456'
Original string 4: '你好world'
To ASCII upper 4: '你好WORLD'
```

### func toRuneArray()

```cangjie
public func toRuneArray(): Array<Rune>
```

功能：获取字符串的 Rune 数组。如果原字符串为空字符串，则返回空数组。

返回值：

- [Array](core_package_structs.md#struct-arrayt)\<Rune> - 字符串的 Rune 数组。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个包含中英文的字符串
    let str = "Hello, 世界"

    // 使用toRuneArray函数获取字符串的Rune数组
    let runeArray = str.toRuneArray()

    println("String: '${str}'")
    println("Rune array size: ${runeArray.size}")
    println("Rune array elements:")
    for (i in 0..runeArray.size) {
        println("  Index ${i}: ${runeArray[i]}")
    }
}
```

运行结果：

```text
String: 'Hello, 世界'
Rune array size: 9
Rune array elements:
  Index 0: H
  Index 1: e
  Index 2: l
  Index 3: l
  Index 4: o
  Index 5: ,
  Index 6:  
  Index 7: 世
  Index 8: 界
```

### func toString()

```cangjie
public func toString(): String
```

功能：获得字符串本身。

返回值：

- [String](core_package_structs.md#struct-string) - 返回字符串本身。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "Hello, World"

    // 使用toString函数获取字符串本身
    let strSelf = str.toString()

    println("Original string: '${str}'")
    println("String from toString(): '${strSelf}'")
    println("Are they equal? ${str == strSelf}")
}
```

运行结果：

```text
Original string: 'Hello, World'
String from toString(): 'Hello, World'
Are they equal? true
```

### func trimAscii()

```cangjie
public func trimAscii(): String
```

功能：去除原字符串开头结尾以 ASCII 空白字符组成的子字符串。

ASCII 空白字符包括 ASCII 码在区间 [0x09, 0x0D] 范围内的字符以及 ASCII 码为 0x20 的字符。具体字符见下表。

| 字符含义 | ASCII 码 |
| --- | --- |
| 水平制表符 (\t, HT) | 0x09 |
| 换行符 (\n, LF) | 0x0A |
| 垂直制表符 (\v, VT) | 0x0B |
| 换页符 (\f, FF) | 0x0C |
| 回车符 (\r, CR) | 0x0D |
| 空格 (Space) | 0x20 |

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "  Hello, World  "
    let str2 = "\t\n Hello, 世界 \r\n"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "

    // 使用trimAscii函数去除字符串开头和结尾的ASCII空白字符
    let trimmed1 = str1.trimAscii()
    let trimmed2 = str2.trimAscii()
    let trimmed3 = str3.trimAscii()
    let trimmed4 = str4.trimAscii()

    println("Original string 1: '${str1}'")
    println("Trimmed string 1: '${trimmed1}'")

    println("Original string 2: '${str2}'")
    println("Trimmed string 2: '${trimmed2}'")

    println("Original string 3: '${str3}'")
    println("Trimmed string 3: '${trimmed3}'")

    println("Original string 4: '${str4}'")
    println("Trimmed string 4: '${trimmed4}'")
}
```

运行结果：

```text
Original string 1: '  Hello, World  '
Trimmed string 1: 'Hello, World'
Original string 2: '	
 Hello, 世界 
'
Trimmed string 2: 'Hello, 世界'
Original string 3: 'Hello'
Trimmed string 3: 'Hello'
Original string 4: '   	

  '
Trimmed string 4: ''
```

### func trimAsciiEnd()

```cangjie
public func trimAsciiEnd(): String
```

功能：去除原字符串结尾以 ASCII 空白字符组成的子字符串。

ASCII 空白字符包括 ASCII 码在区间 [0x09, 0x0D] 范围内的字符以及 ASCII 码为 0x20 的字符。具体字符见 [trimAscii()](#func-trimascii)。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello, World  "
    let str2 = "Hello, 世界\t\n\r"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "

    // 使用trimAsciiEnd函数去除字符串结尾的ASCII空白字符
    let trimmed1 = str1.trimAsciiEnd()
    let trimmed2 = str2.trimAsciiEnd()
    let trimmed3 = str3.trimAsciiEnd()
    let trimmed4 = str4.trimAsciiEnd()

    println("Original string 1: '${str1}'")
    println("Trimmed end string 1: '${trimmed1}'")

    println("Original string 2: '${str2}'")
    println("Trimmed end string 2: '${trimmed2}'")

    println("Original string 3: '${str3}'")
    println("Trimmed end string 3: '${trimmed3}'")

    println("Original string 4: '${str4}'")
    println("Trimmed end string 4: '${trimmed4}'")
}
```

运行结果：

```text
Original string 1: 'Hello, World  '
Trimmed end string 1: 'Hello, World'
Original string 2: 'Hello, 世界	

'
Trimmed end string 2: 'Hello, 世界'
Original string 3: 'Hello'
Trimmed end string 3: 'Hello'
Original string 4: '   	

  '
Trimmed end string 4: ''
```

### func trimAsciiStart()

```cangjie
public func trimAsciiStart(): String
```

功能：去除原字符串开头以 ASCII 空白字符组成的子字符串。

ASCII 空白字符包括 ASCII 码在区间 [0x09, 0x0D] 范围内的字符以及 ASCII 码为 0x20 的字符。具体字符见 [trimAscii()](#func-trimascii)。

返回值：

- [String](core_package_structs.md#struct-string) - 转换后的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "  Hello, World"
    let str2 = "\t\n\rHello, 世界"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "

    // 使用trimAsciiStart函数去除字符串开头的ASCII空白字符
    let trimmed1 = str1.trimAsciiStart()
    let trimmed2 = str2.trimAsciiStart()
    let trimmed3 = str3.trimAsciiStart()
    let trimmed4 = str4.trimAsciiStart()

    println("Original string 1: '${str1}'")
    println("Trimmed start string 1: '${trimmed1}'")

    println("Original string 2: '${str2}'")
    println("Trimmed start string 2: '${trimmed2}'")

    println("Original string 3: '${str3}'")
    println("Trimmed start string 3: '${trimmed3}'")

    println("Original string 4: '${str4}'")
    println("Trimmed start string 4: '${trimmed4}'")
}
```

运行结果：

```text
Original string 1: '  Hello, World'
Trimmed start string 1: 'Hello, World'
Original string 2: '	

Hello, 世界'
Trimmed start string 2: 'Hello, 世界'
Original string 3: 'Hello'
Trimmed start string 3: 'Hello'
Original string 4: '   	

  '
Trimmed start string 4: ''
```

### func trimEnd((Rune)->Bool)

```cangjie
public func trimEnd(predicate: (Rune)->Bool): String
```

功能：修剪当前字符串，从尾开始删除符合过滤条件的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不符合过滤条件的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

参数：

- predicate: ([Rune](./core_package_intrinsics.md#rune))->[Bool](./core_package_intrinsics.md#bool) - 过滤条件。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd({c => c == r'2'})
    println(subStr)
}
```

运行结果：

```text
141
```

### func trimEnd(Array\<Rune>)

```cangjie
public func trimEnd(set: Array<Rune>): String
```

功能：修剪当前字符串，从尾开始删除在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

参数：

- set: [Array](./core_package_structs.md#struct-arrayt)\<[Rune](./core_package_intrinsics.md#rune)> - 待删除的字符的集合。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd([r'1', r'2'])
    println(subStr)
}
```

运行结果：

```text
14
```

### func trimEnd(String)

```cangjie
public func trimEnd(set: String): String
```

功能：修剪当前字符串，从尾开始删除在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

参数：

- set: [String](./core_package_structs.md#struct-string) - 待删除的字符的集合。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd("12")
    println(subStr)
}
```

运行结果：

```text
14
```

### func trimStart((Rune)->Bool)

```cangjie
public func trimStart(predicate: (Rune)->Bool): String
```

功能：修剪当前字符串，从头开始删除符合过滤条件的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不符合过滤条件的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

参数：

- predicate: ([Rune](./core_package_intrinsics.md#rune))->[Bool](./core_package_intrinsics.md#bool) - 过滤条件。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "123456789"

    // 删除开头所有小于'5'的数字字符
    let trimmed = str.trimStart({c => c < r'5'})

    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

运行结果：

```text
Original string: '123456789'
Trimmed string: '56789'
```

### func trimStart(Array\<Rune>)

```cangjie
public func trimStart(set: Array<Rune>): String
```

功能：修剪当前字符串，从头开始删除在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

例如 "12241".trimStart([r'1', r'2']) = "41"。

参数：

- set: [Array](./core_package_structs.md#struct-arrayt)\<[Rune](./core_package_intrinsics.md#rune)> - 待删除的字符的集合。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "12241"

    // 删除开头所有'1'和'2'字符
    let trimmed = str.trimStart([r'1', r'2'])

    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

运行结果：

```text
Original string: '12241'
Trimmed string: '41'
```

### func trimStart(String)

```cangjie
public func trimStart(set: String): String
```

功能：修剪当前字符串，从头开始删除在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符，直到第一个不在 set 中的 [Rune](./core_package_intrinsics.md#rune) 字符为止。

例如 "12241".trimStart("12") = "41"。

参数：

- set: [String](./core_package_structs.md#struct-string) - 待删除的字符的集合。

返回值：

- [String](./core_package_structs.md#struct-string) - 修剪后得到的新字符串。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "12241"

    // 删除开头所有'1'和'2'字符
    let trimmed = str.trimStart("12")

    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

运行结果：

```text
Original string: '12241'
Trimmed string: '41'
```

### operator func !=(String)

```cangjie
public operator const func !=(other: String): Bool
```

功能：判断两个字符串是否不相等。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的 [String](core_package_structs.md#struct-string) 实例。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 不相等返回 true，相等返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "Hello"
    let str3 = "World"

    // 使用!=运算符比较字符串
    let result1 = str1 != str2
    let result2 = str1 != str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 != str2: ${result1}")
    println("str1 != str3: ${result2}")
}
```

运行结果：

```text
String 1: 'Hello'
String 2: 'Hello'
String 3: 'World'
str1 != str2: false
str1 != str3: true
```

### operator func *(Int64)

```cangjie
public operator const func *(count: Int64): String
```

功能：原字符串重复 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) 次。

参数：

- count: [Int64](core_package_intrinsics.md#int64) - 原字符串重复的次数。

返回值：

- [String](core_package_structs.md#struct-string) - 返回重复 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) 次后的新字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "Hello"

    // 使用*运算符重复字符串
    let repeated1 = str * 3
    let repeated2 = str * 0
    let repeated3 = str * 1

    println("Original string: '${str}'")
    println("str * 3: '${repeated1}'")
    println("str * 0: '${repeated2}'")
    println("str * 1: '${repeated3}'")
}
```

运行结果：

```text
Original string: 'Hello'
str * 3: 'HelloHelloHello'
str * 0: ''
str * 1: 'Hello'
```

### operator func +(String)

```cangjie
public operator const func +(other: String): String
```

功能：两个字符串相加，将 right 字符串拼接在原字符串的末尾。

参数：

- other: [String](core_package_structs.md#struct-string) - 待追加的字符串。

返回值：

- [String](core_package_structs.md#struct-string) - 返回拼接后的字符串。

异常：

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 当试图构造长度超过 [UInt32 的最大值](./core_package_intrinsics.md#uint32) 的字符串时，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "World"
    let str3 = ", "

    // 使用+运算符连接字符串
    let result1 = str1 + str3 + str2
    let result2 = str1 + " " + str2
    let result3 = "" + str1

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 + str3 + str2: '${result1}'")
    println("str1 + \" \" + str2: '${result2}'")
    println("\"\" + str1: '${result3}'")
}
```

运行结果：

```text
String 1: 'Hello'
String 2: 'World'
String 3: ', '
str1 + str3 + str2: 'Hello, World'
str1 + " " + str2: 'Hello World'
"" + str1: 'Hello'
```

### operator func <(String)

```cangjie
public operator const func <(other: String): Bool
```

功能：判断两个字符串大小。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 原字符串字典序小于 right 时，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"

    // 使用<运算符比较字符串
    let result1 = str1 < str2
    let result2 = str2 < str1
    let result3 = str1 < str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 < str2: ${result1}")
    println("str2 < str1: ${result2}")
    println("str1 < str3: ${result3}")
}
```

运行结果：

```text
String 1: 'apple'
String 2: 'banana'
String 3: 'apple'
str1 < str2: true
str2 < str1: false
str1 < str3: false
```

### operator func <=(String)

```cangjie
public operator const func <=(other: String): Bool
```

功能：判断两个字符串大小。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 原字符串字典序小于或等于 right 时，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"

    // 使用<=运算符比较字符串
    let result1 = str1 <= str2
    let result2 = str2 <= str1
    let result3 = str1 <= str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 <= str2: ${result1}")
    println("str2 <= str1: ${result2}")
    println("str1 <= str3: ${result3}")
}
```

运行结果：

```text
String 1: 'apple'
String 2: 'banana'
String 3: 'apple'
str1 <= str2: true
str2 <= str1: false
str1 <= str3: true
```

### operator func ==(String)

```cangjie
public operator const func ==(other: String): Bool
```

功能：判断两个字符串是否相等。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 相等返回 true，不相等返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "Hello"
    let str2 = "Hello"
    let str3 = "World"

    // 使用==运算符比较字符串
    let result1 = str1 == str2
    let result2 = str1 == str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 == str2: ${result1}")
    println("str1 == str3: ${result2}")
}
```

运行结果：

```text
String 1: 'Hello'
String 2: 'Hello'
String 3: 'World'
str1 == str2: true
str1 == str3: false
```

### operator func >(String)

```cangjie
public operator const func >(other: String): Bool
```

功能：判断两个字符串大小。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 原字符串字典序大于 right 时，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "banana"
    let str2 = "apple"
    let str3 = "banana"

    // 使用>运算符比较字符串
    let result1 = str1 > str2
    let result2 = str2 > str1
    let result3 = str1 > str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 > str2: ${result1}")
    println("str2 > str1: ${result2}")
    println("str1 > str3: ${result3}")
}
```

运行结果：

```text
String 1: 'banana'
String 2: 'apple'
String 3: 'banana'
str1 > str2: true
str2 > str1: false
str1 > str3: false
```

### operator func >=(String)

```cangjie
public operator const func >=(other: String): Bool
```

功能：判断两个字符串大小。

参数：

- other: [String](core_package_structs.md#struct-string) - 待比较的字符串。

返回值：

- [Bool](core_package_intrinsics.md#bool) - 原字符串字典序大于或等于 right 时，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建几个字符串用于测试
    let str1 = "banana"
    let str2 = "apple"
    let str3 = "banana"

    // 使用>=运算符比较字符串
    let result1 = str1 >= str2
    let result2 = str2 >= str1
    let result3 = str1 >= str3

    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 >= str2: ${result1}")
    println("str2 >= str1: ${result2}")
    println("str1 >= str3: ${result3}")
}
```

运行结果：

```text
String 1: 'banana'
String 2: 'apple'
String 3: 'banana'
str1 >= str2: true
str2 >= str1: false
str1 >= str3: true
```

### operator func \[](Int64)

```cangjie
public operator const func [](index: Int64): Byte
```

功能：返回指定索引 index 处的 UTF-8 编码字节。

参数：

- index: [Int64](core_package_intrinsics.md#int64) - 要获取 UTF-8 编码字节的下标。

返回值：

- [Byte](core_package_types.md#type-byte) - 获取得到下标对应的 UTF-8 编码字节。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果 index 小于 0 或大于等于字符串长度，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "Hello, 世界"

    // 使用[]运算符获取指定索引处的字节
    let byte1 = str[0]
    let byte2 = str[7]

    println("String: '${str}'")
    println("str[0]: ${byte1}")
    println("str[7]: ${byte2}")
}
```

运行结果：

```text
String: 'Hello, 世界'
str[0]: 72
str[7]: 228
```

### operator func \[](Range\<Int64>)

```cangjie
public operator const func [](range: Range<Int64>): String
```

功能：根据给定区间获取当前字符串的切片。区间为 UTF-8 编码后的字节下标范围，起止点必须位于字符边界上，否则将切在某个多字节字符的中间。

> **注意：**
>
> 1. 如果参数 range 是使用 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 构造函数构造的 [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例，有如下行为：
>    - start 的值就是构造函数传入的值本身，不受构造时传入的 hasStart 的值的影响。
>    - hasEnd 为 false 时，end 值不生效，且不受构造时传入的 isClosed 的值的影响，该字符串切片取到原字符串最后一个元素。
> 2. range 的步长只能为 1。

参数：

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - 切片的区间。

返回值：

- [String](core_package_structs.md#struct-string) - 字符串切片。

异常：

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - 如果切片范围超过原字符串边界，抛出异常。
- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - 如果 range.[step](#let-step) 不等于 1 或者范围起止点不是字符边界，抛出异常。

示例：

<!-- verify -->
```cangjie
main() {
    // 创建一个字符串用于测试
    let str = "Hello, 世界"

    // 使用[]运算符根据区间获取字符串切片
    let slice1 = str[0..5] // 获取前5个字节（此处恰好为前5个ASCII字符）
    let slice2 = str[7..] // 从字节下标7开始到末尾

    println("String: '${str}'")
    println("str[0..5]: '${slice1}'")
    println("str[7..]: '${slice2}'")
}
```

运行结果：

```text
String: 'Hello, 世界'
str[0..5]: 'Hello'
str[7..]: '世界'
```
