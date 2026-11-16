# 类

## class AtomicBool

```cangjie
public class AtomicBool {
    public init(val: Bool)
}
```

功能：提供 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型的原子操作相关函数。

### init(Bool)

```cangjie
public init(val: Bool)
```

功能：构造一个封装 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 数据类型的原子类型 [AtomicBool](sync_package_classes.md#class-atomicbool) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("创建了一个 AtomicBool 实例，初始值为: ${atomicBool.load()}")

    // 修改值为 true
    atomicBool.store(true)
    println("修改后的值为: ${atomicBool.load()}")
}
```

运行结果：

```text
创建了一个 AtomicBool 实例，初始值为: false
修改后的值为: true
```

### func compareAndSwap(Bool, Bool)

```cangjie
public func compareAndSwap(old: Bool, new: Bool): Bool
```

功能：CAS（Compare and Swap）操作，采用[默认内存排序方式](sync_package_constants_vars.md#let-defaultmemoryorder-deprecated)。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 与当前原子类型进行比较的值。
- new: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 尝试 CAS 操作：期望当前值为 false，设置新值为 true
    let result1 = atomicBool.compareAndSwap(false, true)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicBool.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 false，但实际已经是 true，所以会失败
    let result2 = atomicBool.compareAndSwap(false, false)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
第一次 CAS 操作结果: true
操作后值: true
第二次 CAS 操作结果: false
操作后值: true
```

### func compareAndSwap(Bool, Bool, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Bool, new: Bool, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Bool, Bool)](#func-compareandswapbool-bool) 替代。

参数：

- old: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 与当前原子类型进行比较的值。
- new: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicBool.compareAndSwap(false, true, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: true
```

### func load()

```cangjie
public func load(): Bool
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 true
    let atomicBool = AtomicBool(true)
    println("AtomicBool 实例的值为: ${atomicBool.load()}")

    // 修改值
    atomicBool.store(false)
    println("修改后的值为: ${atomicBool.load()}")
}
```

运行结果：

```text
AtomicBool 实例的值为: true
修改后的值为: false
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Bool
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 true
    let atomicBool = AtomicBool(true)
    println("AtomicBool 实例的值为: ${atomicBool.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicBool.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicBool 实例的值为: true
使用 deprecated 的 load 方法读取的值: true
```

### func store(Bool)

```cangjie
public func store(val: Bool): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 使用 store 方法修改值为 true
    atomicBool.store(true)
    println("使用 store 方法修改后的值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
使用 store 方法修改后的值: true
```

### func store(Bool, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Bool, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Bool)](#func-storebool) 替代。

参数：

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicBool.store(true, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
使用 deprecated 的 store 方法修改后的值: true
```

### func swap(Bool)

```cangjie
public func swap(val: Bool): Bool
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 使用 swap 方法交换值为 true，返回原始值
    let oldValue = atomicBool.swap(true)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicBool.load()}")

    // 再次交换值为 false
    let oldValue2 = atomicBool.swap(false)
    println("再次交换前的旧值: ${oldValue2}")
    println("再次交换后的当前值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
交换前的旧值: false
交换后的当前值: true
再次交换前的旧值: true
再次交换后的当前值: false
```

### func swap(Bool, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Bool, memoryOrder!: MemoryOrder): Bool
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Bool)](#func-swapbool) 替代。

参数：

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicBool 实例，初始值为 false
    let atomicBool = AtomicBool(false)
    println("初始值: ${atomicBool.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicBool.swap(true, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicBool.load()}")
}
```

运行结果：

```text
初始值: false
使用 deprecated 的 swap 方法交换前的旧值: false
交换后的当前值: true
```

## class AtomicInt16

```cangjie
public class AtomicInt16 {
    public init(val: Int16)
}
```

功能：提供 [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) 类型的原子操作相关函数。

### init(Int16)

```cangjie
public init(val: Int16)
```

功能：构造一个封装 [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) 数据类型的原子类型 [AtomicInt16](sync_package_classes.md#class-atomicint16) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("创建了一个 AtomicInt16 实例，初始值为: ${atomicInt16.load()}")

    // 修改值为 20
    atomicInt16.store(20)
    println("修改后的值为: ${atomicInt16.load()}")
}
```

运行结果：

```text
创建了一个 AtomicInt16 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(Int16, Int16)

```cangjie
public func compareAndSwap(old: Int16, new: Int16): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与当前原子类型进行比较的值。
- new: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicInt16.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicInt16.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicInt16.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(Int16, Int16, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int16, new: Int16, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Int16, Int16)](#func-compareandswapint16-int16) 替代。

参数：

- old: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与当前原子类型进行比较的值。
- new: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicInt16.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(Int16)

```cangjie
public func fetchAdd(val: Int16): Int16
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行加操作的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicInt16.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(Int16)](#func-fetchaddint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(Int16)

```cangjie
public func fetchAnd(val: Int16): Int16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行与操作的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicInt16.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(Int16)](#func-fetchandint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(Int16)

```cangjie
public func fetchOr(val: Int16): Int16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行或操作的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicInt16.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(Int16)](#func-fetchorint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(Int16)

```cangjie
public func fetchSub(val: Int16): Int16
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行减操作的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 20
    let atomicInt16 = AtomicInt16(20)
    println("初始值: ${atomicInt16.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicInt16.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(Int16)](#func-fetchsubint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 20
    let atomicInt16 = AtomicInt16(20)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(Int16)

```cangjie
public func fetchXor(val: Int16): Int16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行异或操作的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicInt16.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(Int16)](#func-fetchxorint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 15
    let atomicInt16 = AtomicInt16(15)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): Int16
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("AtomicInt16 实例的值为: ${atomicInt16.load()}")

    // 修改值
    atomicInt16.store(20)
    println("修改后的值为: ${atomicInt16.load()}")
}
```

运行结果：

```text
AtomicInt16 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Int16
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-1) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("AtomicInt16 实例的值为: ${atomicInt16.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicInt16.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicInt16 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(Int16)

```cangjie
public func store(val: Int16): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 store 方法修改值为 20
    atomicInt16.store(20)
    println("使用 store 方法修改后的值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Int16, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Int16)](#func-storeint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicInt16.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(Int16)

```cangjie
public func swap(val: Int16): Int16
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入原子类型的值。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicInt16.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Int16, memoryOrder!: MemoryOrder): Int16
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Int16)](#func-swapint16) 替代。

参数：

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt16 实例，初始值为 10
    let atomicInt16 = AtomicInt16(10)
    println("初始值: ${atomicInt16.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt16.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicInt32

```cangjie
public class AtomicInt32 {
    public init(val: Int32)
}
```

功能：提供 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) 类型的原子操作相关函数。

### init(Int32)

```cangjie
public init(val: Int32)
```

功能：构造一个封装 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) 数据类型的原子类型 [AtomicInt32](sync_package_classes.md#class-atomicint32) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("创建了一个 AtomicInt32 实例，初始值为: ${atomicInt32.load()}")

    // 修改值为 20
    atomicInt32.store(20)
    println("修改后的值为: ${atomicInt32.load()}")
}
```

运行结果：

```text
创建了一个 AtomicInt32 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(Int32, Int32)

```cangjie
public func compareAndSwap(old: Int32, new: Int32): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与当前原子类型进行比较的值。
- new: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicInt32.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicInt32.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicInt32.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(Int32, Int32, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int32, new: Int32, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Int32, Int32)](#func-compareandswapint32-int32) 替代。

参数：

- old: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与当前原子类型进行比较的值。
- new: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicInt32.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(Int32)

```cangjie
public func fetchAdd(val: Int32): Int32
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行加操作的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicInt32.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(Int32)](#func-fetchaddint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(Int32)

```cangjie
public func fetchAnd(val: Int32): Int32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行与操作的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicInt32.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(Int32)](#func-fetchandint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(Int32)

```cangjie
public func fetchOr(val: Int32): Int32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行或操作的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicInt32.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(Int32)](#func-fetchorint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(Int32)

```cangjie
public func fetchSub(val: Int32): Int32
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行减操作的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 20
    let atomicInt32 = AtomicInt32(20)
    println("初始值: ${atomicInt32.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicInt32.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(Int32)](#func-fetchsubint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 20
    let atomicInt32 = AtomicInt32(20)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(Int32)

```cangjie
public func fetchXor(val: Int32): Int32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行异或操作的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicInt32.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(Int32)](#func-fetchxorint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 15
    let atomicInt32 = AtomicInt32(15)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): Int32
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("AtomicInt32 实例的值为: ${atomicInt32.load()}")

    // 修改值
    atomicInt32.store(20)
    println("修改后的值为: ${atomicInt32.load()}")
}
```

运行结果：

```text
AtomicInt32 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Int32
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-2) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("AtomicInt32 实例的值为: ${atomicInt32.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicInt32.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicInt32 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(Int32)

```cangjie
public func store(val: Int32): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 store 方法修改值为 20
    atomicInt32.store(20)
    println("使用 store 方法修改后的值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Int32, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Int32)](#func-storeint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicInt32.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(Int32)

```cangjie
public func swap(val: Int32): Int32
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入原子类型的值。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicInt32.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Int32, memoryOrder!: MemoryOrder): Int32
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Int32)](#func-swapint32) 替代。

参数：

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt32 实例，初始值为 10
    let atomicInt32 = AtomicInt32(10)
    println("初始值: ${atomicInt32.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt32.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicInt64

```cangjie
public class AtomicInt64 {
    public init(val: Int64)
}
```

功能：提供 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型的原子操作相关函数。

### init(Int64)

```cangjie
public init(val: Int64)
```

功能：构造一个封装 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 数据类型的原子类型 [AtomicInt64](sync_package_classes.md#class-atomicint64) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("创建了一个 AtomicInt64 实例，初始值为: ${atomicInt64.load()}")

    // 修改值为 20
    atomicInt64.store(20)
    println("修改后的值为: ${atomicInt64.load()}")
}
```

运行结果：

```text
创建了一个 AtomicInt64 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(Int64, Int64)

```cangjie
public func compareAndSwap(old: Int64, new: Int64): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与当前原子类型进行比较的值。
- new: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicInt64.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicInt64.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicInt64.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(Int64, Int64, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int64, new: Int64, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Int64, Int64)](#func-compareandswapint64-int64) 替代。

参数：

- old: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与当前原子类型进行比较的值。
- new: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicInt64.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicInt64.load()}")

    // 失败场景
    let failedResult = atomicInt64.compareAndSwap(10, 30, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法失败场景结果: ${failedResult}")
    println("操作后值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
使用 deprecated 的 compareAndSwap 方法失败场景结果: false
操作后值: 20
```

### func fetchAdd(Int64)

```cangjie
public func fetchAdd(val: Int64): Int64
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行加操作的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicInt64.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(Int64)](#func-fetchaddint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(Int64)

```cangjie
public func fetchAnd(val: Int64): Int64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行与操作的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicInt64.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(Int64)](#func-fetchandint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(Int64)

```cangjie
public func fetchOr(val: Int64): Int64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行或操作的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicInt64.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(Int64)](#func-fetchorint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(Int64)

```cangjie
public func fetchSub(val: Int64): Int64
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行减操作的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 20
    let atomicInt64 = AtomicInt64(20)
    println("初始值: ${atomicInt64.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicInt64.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(Int64)](#func-fetchsubint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 20
    let atomicInt64 = AtomicInt64(20)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(Int64)

```cangjie
public func fetchXor(val: Int64): Int64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行异或操作的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicInt64.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(Int64)](#func-fetchxorint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 15
    let atomicInt64 = AtomicInt64(15)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): Int64
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("AtomicInt64 实例的值为: ${atomicInt64.load()}")

    // 修改值
    atomicInt64.store(20)
    println("修改后的值为: ${atomicInt64.load()}")
}
```

运行结果：

```text
AtomicInt64 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Int64
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-3) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("AtomicInt64 实例的值为: ${atomicInt64.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicInt64.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicInt64 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(Int64)

```cangjie
public func store(val: Int64): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 store 方法修改值为 20
    atomicInt64.store(20)
    println("使用 store 方法修改后的值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Int64, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Int64)](#func-storeint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicInt64.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(Int64)

```cangjie
public func swap(val: Int64): Int64
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入原子类型的值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicInt64.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Int64, memoryOrder!: MemoryOrder): Int64
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Int64)](#func-swapint64) 替代。

参数：

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt64 实例，初始值为 10
    let atomicInt64 = AtomicInt64(10)
    println("初始值: ${atomicInt64.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt64.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicInt8

```cangjie
public class AtomicInt8 {
    public init(val: Int8)
}
```

功能：提供 [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) 类型的原子操作相关函数。

### init(Int8)

```cangjie
public init(val: Int8)
```

功能：构造一个封装 [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) 数据类型的原子类型 [AtomicInt8](sync_package_classes.md#class-atomicint8) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("创建了一个 AtomicInt8 实例，初始值为: ${atomicInt8.load()}")

    // 修改值为 20
    atomicInt8.store(20)
    println("修改后的值为: ${atomicInt8.load()}")
}
```

运行结果：

```text
创建了一个 AtomicInt8 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(Int8, Int8)

```cangjie
public func compareAndSwap(old: Int8, new: Int8): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与当前原子类型进行比较的值。
- new: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicInt8.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicInt8.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicInt8.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(Int8, Int8, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int8, new: Int8, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Int8, Int8)](#func-compareandswapint8-int8) 替代。

参数：

- old: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与当前原子类型进行比较的值。
- new: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicInt8.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(Int8)

```cangjie
public func fetchAdd(val: Int8): Int8
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行加操作的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicInt8.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(Int8)](#func-fetchaddint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(Int8)

```cangjie
public func fetchAnd(val: Int8): Int8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行与操作的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicInt8.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(Int8)](#func-fetchandint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(Int8)

```cangjie
public func fetchOr(val: Int8): Int8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行或操作的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicInt8.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(Int8)](#func-fetchorint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(Int8)

```cangjie
public func fetchSub(val: Int8): Int8
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行减操作的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 20
    let atomicInt8 = AtomicInt8(20)
    println("初始值: ${atomicInt8.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicInt8.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(Int8)](#func-fetchsubint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 20
    let atomicInt8 = AtomicInt8(20)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(Int8)

```cangjie
public func fetchXor(val: Int8): Int8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行异或操作的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicInt8.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(Int8)](#func-fetchxorint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 15
    let atomicInt8 = AtomicInt8(15)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): Int8
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("AtomicInt8 实例的值为: ${atomicInt8.load()}")

    // 修改值
    atomicInt8.store(20)
    println("修改后的值为: ${atomicInt8.load()}")
}
```

运行结果：

```text
AtomicInt8 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Int8
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-4) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("AtomicInt8 实例的值为: ${atomicInt8.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicInt8.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicInt8 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(Int8)

```cangjie
public func store(val: Int8): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 store 方法修改值为 20
    atomicInt8.store(20)
    println("使用 store 方法修改后的值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Int8, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Int8)](#func-storeint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicInt8.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(Int8)

```cangjie
public func swap(val: Int8): Int8
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入原子类型的值。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicInt8.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(Int8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Int8, memoryOrder!: MemoryOrder): Int8
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Int8)](#func-swapint8) 替代。

参数：

- val: [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicInt8 实例，初始值为 10
    let atomicInt8 = AtomicInt8(10)
    println("初始值: ${atomicInt8.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicInt8.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicOptionReference\<T> where T <: Object

```cangjie
public class AtomicOptionReference<T> where T <: Object {
    public init()
    public init(val: Option<T>)
}
```

功能：提供引用类型原子操作相关函数。

该引用类型必须是 [Object](../../core/core_package_api/core_package_classes.md#class-object) 的子类。

### init()

```cangjie
public init()
```

功能：构造一个空的 [AtomicOptionReference](sync_package_classes.md#class-atomicoptionreferencet-where-t--object) 实例。

示例：

<!-- run -->
```cangjie
import std.sync.*

class TestClass {}

main(): Unit {
    // 创建一个空的 AtomicOptionReference 实例
    let atomicOptionRef = AtomicOptionReference<TestClass>()
}
```

### init(Option\<T>)

```cangjie
public init(val: Option<T>)
```

功能：构造一个封装 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> 数据类型的原子类型 [AtomicOptionReference](sync_package_classes.md#class-atomicoptionreferencet-where-t--object) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 原子类型的初始值。

示例：

<!-- run -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 使用 Some 创建一个包含 TestClass 实例的 Option
    let optionObj = Some(testObj)

    // 使用 init(Option<T>) 构造函数创建一个封装 Option 数据的 AtomicOptionReference 实例，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj)
}
```

### func compareAndSwap(Option\<T>, Option\<T>)

```cangjie
public func compareAndSwap(old: Option<T>, new: Option<T>): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 与当前原子类型进行比较的值。
- new: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 compareAndSwap 方法尝试将 optionObj1 替换为 optionObj2
    let result = atomicOptionRef.compareAndSwap(optionObj1, optionObj2)

    println("CAS 操作结果: ${result}")
    println("替换后的值存在: ${atomicOptionRef.load().isSome()}")
}
```

运行结果：

```text
CAS 操作结果: true
替换后的值存在: true
```

### func compareAndSwap(Option\<T>, Option\<T>, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Option<T>, new: Option<T>, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(Option\<T>, Option\<T>)](#func-compareandswapoptiont-optiont) 替代。

参数：

- old: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 与当前原子类型进行比较的值。
- new: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 compareAndSwap 方法尝试将 optionObj1 替换为 optionObj2
    let result = atomicOptionRef.compareAndSwap(optionObj1, optionObj2)

    println("CAS 操作结果: ${result}")
    println("替换后的值: ${atomicOptionRef.load().getOrThrow().value}")
}
```

运行结果：

```text
CAS 操作结果: true
替换后的值: 84
```

### func load()

```cangjie
public func load(): Option<T>
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj = Some(testObj)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj)

    // 使用 load 方法读取原子引用的值
    let loadedValue = atomicOptionRef.load()

    // 使用 match 来处理 Option 值
    match (loadedValue) {
        case Some(obj) => println("加载的值: ${obj.value}")
        case Option.None => println("没有加载到值")
    }
}
```

运行结果：

```text
加载的值: 42
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Option<T>
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-5) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj = Some(testObj)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj)

    // 使用 deprecated 的 load 方法读取原子引用的值
    let loadedValue = atomicOptionRef.load(memoryOrder: SeqCst)

    // 使用 match 来处理 Option 值
    match (loadedValue) {
        case Some(obj) => println("加载的值: ${obj.value}")
        case Option.None => println("没有加载到值")
    }
}
```

运行结果：

```text
加载的值: 42
```

### func store(Option\<T>)

```cangjie
public func store(val: Option<T>): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 load 方法读取初始值
    let initialValue = atomicOptionRef.load()
    match (initialValue) {
        case Some(obj) => println("初始值: ${obj.value}")
        case Option.None => println("没有初始值")
    }

    // 使用 store 方法设置新的值
    atomicOptionRef.store(optionObj2)

    // 使用 load 方法读取新值
    let newValue = atomicOptionRef.load()
    match (newValue) {
        case Some(obj) => println("新值: ${obj.value}")
        case Option.None => println("没有新值")
    }
}
```

运行结果：

```text
初始值: 42
新值: 84
```

### func store(Option\<T>, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Option<T>, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(Option\<T>)](#func-storeoptiont) 替代。

参数：

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 load 方法读取初始值
    let initialValue = atomicOptionRef.load()
    match (initialValue) {
        case Some(obj) => println("初始值: ${obj.value}")
        case Option.None => println("没有初始值")
    }

    // 使用 deprecated 的 store 方法设置新的值
    atomicOptionRef.store(optionObj2, memoryOrder: SeqCst)

    // 使用 load 方法读取新值
    let newValue = atomicOptionRef.load()
    match (newValue) {
        case Some(obj) => println("新值: ${obj.value}")
        case Option.None => println("没有新值")
    }
}
```

运行结果：

```text
初始值: 42
新值: 84
```

### func swap(Option\<T>)

```cangjie
public func swap(val: Option<T>): Option<T>
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入原子类型的值。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 load 方法读取初始值
    let initialValue = atomicOptionRef.load()
    match (initialValue) {
        case Some(obj) => println("初始值: ${obj.value}")
        case Option.None => println("没有初始值")
    }

    // 使用 swap 方法交换值
    let oldValue = atomicOptionRef.swap(optionObj2)

    match (oldValue) {
        case Some(obj) => println("交换前的旧值: ${obj.value}")
        case Option.None => println("没有旧值")
    }

    // 使用 load 方法读取新值
    let newValue = atomicOptionRef.load()
    match (newValue) {
        case Some(obj) => println("新值: ${obj.value}")
        case Option.None => println("没有新值")
    }
}
```

运行结果：

```text
初始值: 42
交换前的旧值: 42
新值: 84
```

### func swap(Option\<T>, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Option<T>, memoryOrder!: MemoryOrder): Option<T>
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(Option\<T>)](#func-swapoptiont) 替代。

参数：

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init() {
    }

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 使用 Some 创建包含 TestClass 实例的 Option
    let optionObj1 = Some(testObj1)
    let optionObj2 = Some(testObj2)

    // 创建一个 AtomicOptionReference 实例，初始值为 optionObj1，此处也可直接传入实例
    let atomicOptionRef = AtomicOptionReference<TestClass>(optionObj1)

    // 使用 load 方法读取初始值
    let initialValue = atomicOptionRef.load()
    match (initialValue) {
        case Some(obj) => println("初始值: ${obj.value}")
        case Option.None => println("没有初始值")
    }

    // 使用 deprecated 的 swap 方法交换值
    let oldValue = atomicOptionRef.swap(optionObj2, memoryOrder: SeqCst)

    match (oldValue) {
        case Some(obj) => println("交换前的旧值: ${obj.value}")
        case Option.None => println("没有旧值")
    }

    // 使用 load 方法读取新值
    let newValue = atomicOptionRef.load()
    match (newValue) {
        case Some(obj) => println("新值: ${obj.value}")
        case Option.None => println("没有新值")
    }
}
```

运行结果：

```text
初始值: 42
交换前的旧值: 42
新值: 84
```

## class AtomicReference\<T> where T <: Object

```cangjie
public class AtomicReference<T> where T <: Object {
    public init(val: T)
}
```

功能：引用类型原子操作相关函数。

该引用类型必须是 [Object](../../core/core_package_api/core_package_classes.md#class-object) 的子类。

### init(T)

```cangjie
public init(val: T)
```

功能：构造一个封装 `T` 数据类型的原子类型 [AtomicReference](sync_package_classes.md#class-atomicreferencet-where-t--object) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: T - 原子类型的初始值。

示例：

<!-- run -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 使用 init(T) 构造函数创建一个封装 TestClass 实例的 AtomicReference
    let atomicRef = AtomicReference<TestClass>(testObj)
}
```

### func compareAndSwap(T, T)

```cangjie
public func compareAndSwap(old: T, new: T): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: T - 与当前原子类型进行比较的值。
- new: T - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj1
    let atomicRef = AtomicReference<TestClass>(testObj1)

    // 使用 compareAndSwap 方法尝试将 testObj1 替换为 testObj2
    let result = atomicRef.compareAndSwap(testObj1, testObj2)

    println("CAS 操作结果: ${result}")
}
```

运行结果：

```text
CAS 操作结果: true
```

### func compareAndSwap(T, T, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: T, new: T, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(T, T)](#func-compareandswapt-t) 替代。

参数：

- old: T - 与当前原子类型进行比较的值。
- new: T - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建两个 TestClass 实例
    let testObj1 = TestClass(42)
    let testObj2 = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj1
    let atomicRef = AtomicReference<TestClass>(testObj1)

    // 使用 deprecated 的 compareAndSwap 方法尝试将 testObj1 替换为 testObj2
    let result = atomicRef.compareAndSwap(testObj1, testObj2, successOrder: SeqCst, failureOrder: SeqCst)

    println("CAS 操作结果: ${result}")
}
```

运行结果：

```text
CAS 操作结果: true
```

### func load()

```cangjie
public func load(): T
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- T - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // 使用 load 方法读取原子引用的值
    let loadedValue = atomicRef.load()

    println("加载的值: ${loadedValue.value}")
}
```

运行结果：

```text
加载的值: 42
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): T
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-6) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- T - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // // 使用 deprecated 的 load 方法读取原子引用的值
    let loadedValue = atomicRef.load(memoryOrder: SeqCst)

    println("加载的值: ${loadedValue.value}")
}
```

运行结果：

```text
加载的值: 42
```

### func store(T)

```cangjie
public func store(val: T): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: T - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建另一个 TestClass 实例
    let newObj = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // 使用 store 方法存储新的值
    atomicRef.store(newObj)

    // 验证存储的值
    let loadedValue = atomicRef.load()
    println("存储后的值: ${loadedValue.value}")
}
```

运行结果：

```text
存储后的值: 84
```

### func store(T, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: T, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(T)](#func-storet) 替代。

参数：

- val: T - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建另一个 TestClass 实例
    let newObj = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // 使用 deprecated 的 store 方法存储新的值
    atomicRef.store(newObj, memoryOrder: SeqCst)

    // 验证存储的值
    let loadedValue = atomicRef.load()
    println("存储后的值: ${loadedValue.value}")
}
```

运行结果：

```text
存储后的值: 84
```

### func swap(T)

```cangjie
public func swap(val: T): T
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: T - 写入原子类型的值。

返回值：

- T - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建另一个 TestClass 实例
    let newObj = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // 使用 swap 方法交换值
    let oldValue = atomicRef.swap(newObj)

    // 验证交换的旧值和新值
    println("交换前的旧值: ${oldValue.value}")
    let newValue = atomicRef.load()
    println("交换后的新值: ${newValue.value}")
}
```

运行结果：

```text
交换前的旧值: 42
交换后的新值: 84
```

### func swap(T, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: T, memoryOrder!: MemoryOrder): T
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(T)](#func-swapt) 替代。

参数：

- val: T - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- T - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

class TestClass {
    var value: Int32 = 0

    public init(val: Int32) {
        value = val
    }
}

main(): Unit {
    // 创建一个 TestClass 实例
    let testObj = TestClass(42)

    // 创建另一个 TestClass 实例
    let newObj = TestClass(84)

    // 创建一个 AtomicReference 实例，初始值为 testObj
    let atomicRef = AtomicReference<TestClass>(testObj)

    // 使用 deprecated 的 swap 方法交换值
    let oldValue = atomicRef.swap(newObj, memoryOrder: SeqCst)

    // 验证交换的旧值和新值
    println("交换前的旧值: ${oldValue.value}")
    let newValue = atomicRef.load()
    println("交换后的新值: ${newValue.value}")
}
```

运行结果：

```text
交换前的旧值: 42
交换后的新值: 84
```

## class AtomicUInt16

```cangjie
public class AtomicUInt16 {
    public init(val: UInt16)
}
```

功能：提供 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 类型的原子操作相关函数。

### init(UInt16)

```cangjie
public init(val: UInt16)
```

功能：构造一个封装 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 数据类型的原子类型 [AtomicUInt16](sync_package_classes.md#class-atomicuint16) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("创建了一个 AtomicUInt16 实例，初始值为: ${atomicUInt16.load()}")

    // 修改值为 20
    atomicUInt16.store(20)
    println("修改后的值为: ${atomicUInt16.load()}")
}
```

运行结果：

```text
创建了一个 AtomicUInt16 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(UInt16, UInt16)

```cangjie
public func compareAndSwap(old: UInt16, new: UInt16): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与当前原子类型进行比较的值。
- new: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicUInt16.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicUInt16.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicUInt16.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(UInt16, UInt16, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt16, new: UInt16, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(UInt16, UInt16)](#func-compareandswapuint16-uint16) 替代。

参数：

- old: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与当前原子类型进行比较的值。
- new: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicUInt16.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(UInt16)

```cangjie
public func fetchAdd(val: UInt16): UInt16
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行加操作的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicUInt16.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(UInt16)](#func-fetchadduint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(UInt16)

```cangjie
public func fetchAnd(val: UInt16): UInt16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行与操作的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicUInt16.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(UInt16)](#func-fetchanduint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(UInt16)

```cangjie
public func fetchOr(val: UInt16): UInt16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行或操作的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicUInt16.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(UInt16)](#func-fetchoruint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(UInt16)

```cangjie
public func fetchSub(val: UInt16): UInt16
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行减操作的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 20
    let atomicUInt16 = AtomicUInt16(20)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicUInt16.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(UInt16)](#func-fetchsubuint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 20
    let atomicUInt16 = AtomicUInt16(20)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(UInt16)

```cangjie
public func fetchXor(val: UInt16): UInt16
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行异或操作的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicUInt16.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(UInt16)](#func-fetchxoruint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 15
    let atomicUInt16 = AtomicUInt16(15)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): UInt16
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("AtomicUInt16 实例的值为: ${atomicUInt16.load()}")

    // 修改值
    atomicUInt16.store(20)
    println("修改后的值为: ${atomicUInt16.load()}")
}
```

运行结果：

```text
AtomicUInt16 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): UInt16
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-7) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("AtomicUInt16 实例的值为: ${atomicUInt16.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicUInt16.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicUInt16 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(UInt16)

```cangjie
public func store(val: UInt16): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 store 方法修改值为 20
    atomicUInt16.store(20)
    println("使用 store 方法修改后的值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: UInt16, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(UInt16)](#func-storeuint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicUInt16.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(UInt16)

```cangjie
public func swap(val: UInt16): UInt16
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入原子类型的值。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicUInt16.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(UInt16)](#func-swapuint16) 替代。

参数：

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt16 实例，初始值为 10
    let atomicUInt16 = AtomicUInt16(10)
    println("初始值: ${atomicUInt16.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt16.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt16.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicUInt32

```cangjie
public class AtomicUInt32 {
    public init(val: UInt32)
}
```

功能：提供 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 类型的原子操作相关函数。

### init(UInt32)

```cangjie
public init(val: UInt32)
```

功能：构造一个封装 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 数据类型的原子类型 [AtomicUInt32](sync_package_classes.md#class-atomicuint32) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("创建了一个 AtomicUInt32 实例，初始值为: ${atomicUInt32.load()}")

    // 修改值为 20
    atomicUInt32.store(20)
    println("修改后的值为: ${atomicUInt32.load()}")
}
```

运行结果：

```text
创建了一个 AtomicUInt32 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(UInt32, UInt32)

```cangjie
public func compareAndSwap(old: UInt32, new: UInt32): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与当前原子类型进行比较的值。
- new: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicUInt32.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicUInt32.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicUInt32.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(UInt32, UInt32, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt32, new: UInt32, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(UInt32, UInt32)](#func-compareandswapuint32-uint32) 替代。

参数：

- old: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与当前原子类型进行比较的值。
- new: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicUInt32.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(UInt32)

```cangjie
public func fetchAdd(val: UInt32): UInt32
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行加操作的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicUInt32.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(UInt32)](#func-fetchadduint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(UInt32)

```cangjie
public func fetchAnd(val: UInt32): UInt32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行与操作的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicUInt32.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(UInt32)](#func-fetchanduint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(UInt32)

```cangjie
public func fetchOr(val: UInt32): UInt32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行或操作的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicUInt32.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(UInt32)](#func-fetchoruint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(UInt32)

```cangjie
public func fetchSub(val: UInt32): UInt32
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行减操作的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 20
    let atomicUInt32 = AtomicUInt32(20)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicUInt32.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(UInt32)](#func-fetchsubuint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 20
    let atomicUInt32 = AtomicUInt32(20)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(UInt32)

```cangjie
public func fetchXor(val: UInt32): UInt32
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行异或操作的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicUInt32.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(UInt32)](#func-fetchxoruint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 15
    let atomicUInt32 = AtomicUInt32(15)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): UInt32
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("AtomicUInt32 实例的值为: ${atomicUInt32.load()}")

    // 修改值
    atomicUInt32.store(20)
    println("修改后的值为: ${atomicUInt32.load()}")
}
```

运行结果：

```text
AtomicUInt32 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): UInt32
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-8) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("AtomicUInt32 实例的值为: ${atomicUInt32.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicUInt32.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicUInt32 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(UInt32)

```cangjie
public func store(val: UInt32): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 store 方法修改值为 20
    atomicUInt32.store(20)
    println("使用 store 方法修改后的值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: UInt32, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(UInt32)](#func-storeuint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicUInt32.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(UInt32)

```cangjie
public func swap(val: UInt32): UInt32
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入原子类型的值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicUInt32.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(UInt32)](#func-swapuint32) 替代。

参数：

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt32 实例，初始值为 10
    let atomicUInt32 = AtomicUInt32(10)
    println("初始值: ${atomicUInt32.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt32.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt32.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicUInt64

```cangjie
public class AtomicUInt64 {
    public init(val: UInt64)
}
```

功能：提供 [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) 类型的原子操作相关函数。

### init(UInt64)

```cangjie
public init(val: UInt64)
```

功能：构造一个封装 [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) 数据类型的原子类型 [AtomicUInt64](sync_package_classes.md#class-atomicuint64) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("创建了一个 AtomicUInt64 实例，初始值为: ${atomicUInt64.load()}")

    // 修改值为 20
    atomicUInt64.store(20)
    println("修改后的值为: ${atomicUInt64.load()}")
}
```

运行结果：

```text
创建了一个 AtomicUInt64 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(UInt64, UInt64)

```cangjie
public func compareAndSwap(old: UInt64, new: UInt64): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与当前原子类型进行比较的值。
- new: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicUInt64.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicUInt64.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicUInt64.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(UInt64, UInt64, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt64, new: UInt64, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(UInt64, UInt64)](#func-compareandswapuint64-uint64) 替代。

参数：

- old: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与当前原子类型进行比较的值。
- new: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicUInt64.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(UInt64)

```cangjie
public func fetchAdd(val: UInt64): UInt64
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行加操作的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicUInt64.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(UInt64)](#func-fetchadduint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(UInt64)

```cangjie
public func fetchAnd(val: UInt64): UInt64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行与操作的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicUInt64.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(UInt64)](#func-fetchanduint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(UInt64)

```cangjie
public func fetchOr(val: UInt64): UInt64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行或操作的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicUInt64.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(UInt64)](#func-fetchoruint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(UInt64)

```cangjie
public func fetchSub(val: UInt64): UInt64
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行减操作的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 20
    let atomicUInt64 = AtomicUInt64(20)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicUInt64.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(UInt64)](#func-fetchsubuint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 20
    let atomicUInt64 = AtomicUInt64(20)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(UInt64)

```cangjie
public func fetchXor(val: UInt64): UInt64
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行异或操作的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicUInt64.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(UInt64)](#func-fetchxoruint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 15
    let atomicUInt64 = AtomicUInt64(15)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): UInt64
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("AtomicUInt64 实例的值为: ${atomicUInt64.load()}")

    // 修改值
    atomicUInt64.store(20)
    println("修改后的值为: ${atomicUInt64.load()}")
}
```

运行结果：

```text
AtomicUInt64 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): UInt64
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-9) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("AtomicUInt64 实例的值为: ${atomicUInt64.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicUInt64.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicUInt64 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(UInt64)

```cangjie
public func store(val: UInt64): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 store 方法修改值为 20
    atomicUInt64.store(20)
    println("使用 store 方法修改后的值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: UInt64, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(UInt64)](#func-storeuint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicUInt64.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(UInt64)

```cangjie
public func swap(val: UInt64): UInt64
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入原子类型的值。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicUInt64.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(UInt64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: UInt64, memoryOrder!: MemoryOrder): UInt64
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(UInt64)](#func-swapuint64) 替代。

参数：

- val: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt64 实例，初始值为 10
    let atomicUInt64 = AtomicUInt64(10)
    println("初始值: ${atomicUInt64.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt64.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt64.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class AtomicUInt8

```cangjie
public class AtomicUInt8 {
    public init(val: UInt8)
}
```

功能：提供 [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) 类型的原子操作相关函数。

### init(UInt8)

```cangjie
public init(val: UInt8)
```

功能：构造一个封装 [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) 数据类型的原子类型 [AtomicUInt8](sync_package_classes.md#class-atomicuint8) 的实例，其内部数据初始值为入参 `val` 的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 原子类型的初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("创建了一个 AtomicUInt8 实例，初始值为: ${atomicUInt8.load()}")

    // 修改值为 20
    atomicUInt8.store(20)
    println("修改后的值为: ${atomicUInt8.load()}")
}
```

运行结果：

```text
创建了一个 AtomicUInt8 实例，初始值为: 10
修改后的值为: 20
```

### func compareAndSwap(UInt8, UInt8)

```cangjie
public func compareAndSwap(old: UInt8, new: UInt8): Bool
```

功能：CAS 操作，采用默认内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，则写入参数 `new` 指定的值，并返回 `true`；否则，不写入值，并返回 `false`。

参数：

- old: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与当前原子类型进行比较的值。
- new: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 比较结果相等时，写入原子类型的值。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 尝试 CAS 操作：期望当前值为 10，设置新值为 20
    let result1 = atomicUInt8.compareAndSwap(10, 20)
    println("第一次 CAS 操作结果: ${result1}")
    println("操作后值: ${atomicUInt8.load()}")

    // 再次尝试 CAS 操作：期望当前值仍为 10，但实际已经是 20，所以会失败
    let result2 = atomicUInt8.compareAndSwap(10, 30)
    println("第二次 CAS 操作结果: ${result2}")
    println("操作后值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
第一次 CAS 操作结果: true
操作后值: 20
第二次 CAS 操作结果: false
操作后值: 20
```

### func compareAndSwap(UInt8, UInt8, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt8, new: UInt8, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

功能：CAS 操作，成功时使用 `successOrder` 指定的内存排序方式，失败时则使用 `failureOrder` 指定的内存排序方式。

比较当前原子类型的值与参数 `old` 指定的值是否相等。若相等，写入参数 `new` 指定的值，返回 `true`；否则，不写入值，并返回 `false`。

> **注意：**
>
> 未来版本即将废弃，使用 [compareAndSwap(UInt8, UInt8)](#func-compareandswapuint8-uint8) 替代。

参数：

- old: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与当前原子类型进行比较的值。
- new: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 比较结果相等时，写入原子类型的值。
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作成功时，执行“读 > 修改 > 写”操作需要的内存排序方式。
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - CAS 操作失败时，执行“读”操作需要的内存排序方式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 比较后交换成功返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 compareAndSwap 方法（带 MemoryOrder 参数）
    let result = atomicUInt8.compareAndSwap(10, 20, successOrder: SeqCst, failureOrder: SeqCst)
    println("使用 deprecated 的 compareAndSwap 方法结果: ${result}")
    println("操作后值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 compareAndSwap 方法结果: true
操作后值: 20
```

### func fetchAdd(UInt8)

```cangjie
public func fetchAdd(val: UInt8): UInt8
```

功能：采用默认内存排序方式，将原子类型的值与参数 `val` 进行加操作，将结果写入当前原子类型实例，并返回加操作前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行加操作的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 fetchAdd 方法将值增加 5，返回增加前的值
    let oldValue = atomicUInt8.fetchAdd(5)
    println("增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAdd(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将原子类型的值与参数 `val` 进行加操作。将结果写入当前原子类型实例，并返回加法运算前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAdd(UInt8)](#func-fetchadduint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行加操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行加操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 fetchAdd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.fetchAdd(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAdd 方法增加前的旧值: ${oldValue}")
    println("增加后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 fetchAdd 方法增加前的旧值: 10
增加后的当前值: 15
```

### func fetchAnd(UInt8)

```cangjie
public func fetchAnd(val: UInt8): UInt8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行与操作的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 fetchAnd 方法将值与 7 进行按位与操作，返回操作前的值
    let oldValue = atomicUInt8.fetchAnd(7)
    println("按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchAnd(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行与操作。将结果写入当前原子类型实例，并返回与操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchAnd(UInt8)](#func-fetchanduint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行与操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行与操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 fetchAnd 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.fetchAnd(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: ${oldValue}")
    println("按位与操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchAnd 方法按位与操作前的旧值: 15
按位与操作后的当前值: 7
```

### func fetchOr(UInt8)

```cangjie
public func fetchOr(val: UInt8): UInt8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行或操作的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 fetchOr 方法将值与 7 进行按位或操作，返回操作前的值
    let oldValue = atomicUInt8.fetchOr(7)
    println("按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchOr(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行或操作。将结果写入当前原子类型实例，并返回或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchOr(UInt8)](#func-fetchoruint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 fetchOr 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.fetchOr(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchOr 方法按位或操作前的旧值: ${oldValue}")
    println("按位或操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchOr 方法按位或操作前的旧值: 15
按位或操作后的当前值: 15
```

### func fetchSub(UInt8)

```cangjie
public func fetchSub(val: UInt8): UInt8
```

功能：采用默认内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行减操作的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 20
    let atomicUInt8 = AtomicUInt8(20)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 fetchSub 方法将值减去 5，返回减操作前的值
    let oldValue = atomicUInt8.fetchSub(5)
    println("减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 20
减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchSub(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，以原子类型的值为被减数，参数 `val` 为减数，做减操作。将结果写入当前原子类型实例，并返回减操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchSub(UInt8)](#func-fetchsubuint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行减操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行减操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 20
    let atomicUInt8 = AtomicUInt8(20)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 fetchSub 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.fetchSub(5, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchSub 方法减操作前的旧值: ${oldValue}")
    println("减操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 20
使用 deprecated 的 fetchSub 方法减操作前的旧值: 20
减操作后的当前值: 15
```

### func fetchXor(UInt8)

```cangjie
public func fetchXor(val: UInt8): UInt8
```

功能：采用默认内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行异或操作的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 fetchXor 方法将值与 7 进行按位异或操作，返回操作前的值
    let oldValue = atomicUInt8.fetchXor(7)
    println("按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func fetchXor(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：采用参数 `memoryOrder` 指定的内存排序方式，将当前原子类型实例的值与参数 `val` 进行异或操作。将结果写入当前原子类型实例，并返回异或操作前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [fetchXor(UInt8)](#func-fetchxoruint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 与原子类型进行异或操作的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 执行异或操作前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 15
    let atomicUInt8 = AtomicUInt8(15)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 fetchXor 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.fetchXor(7, memoryOrder: SeqCst)
    println("使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: ${oldValue}")
    println("按位异或操作后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 15
使用 deprecated 的 fetchXor 方法按位异或操作前的旧值: 15
按位异或操作后的当前值: 8
```

### func load()

```cangjie
public func load(): UInt8
```

功能：读取操作，采用默认内存排序方式，读取原子类型的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("AtomicUInt8 实例的值为: ${atomicUInt8.load()}")

    // 修改值
    atomicUInt8.store(20)
    println("修改后的值为: ${atomicUInt8.load()}")
}
```

运行结果：

```text
AtomicUInt8 实例的值为: 10
修改后的值为: 20
```

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): UInt8
```

功能：读取操作，采用参数 `memoryOrder` 指定的内存排序方式，读取原子类型的值。

> **注意：**
>
> 未来版本即将废弃，使用 [load()](#func-load-10) 替代。

参数：

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 当前原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("AtomicUInt8 实例的值为: ${atomicUInt8.load()}")

    // 使用 deprecated 的 load 方法（带 MemoryOrder 参数）
    let value = atomicUInt8.load(memoryOrder: SeqCst)
    println("使用 deprecated 的 load 方法读取的值: ${value}")
}
```

运行结果：

```text
AtomicUInt8 实例的值为: 10
使用 deprecated 的 load 方法读取的值: 10
```

### func store(UInt8)

```cangjie
public func store(val: UInt8): Unit
```

功能：写入操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入原子类型的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 store 方法修改值为 20
    atomicUInt8.store(20)
    println("使用 store 方法修改后的值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 store 方法修改后的值: 20
```

### func store(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: UInt8, memoryOrder!: MemoryOrder): Unit
```

功能：写入操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型。

> **注意：**
>
> 未来版本即将废弃，使用 [store(UInt8)](#func-storeuint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 store 方法（带 MemoryOrder 参数）
    atomicUInt8.store(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 store 方法修改后的值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 store 方法修改后的值: 20
```

### func swap(UInt8)

```cangjie
public func swap(val: UInt8): UInt8
```

功能：交换操作，采用默认内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入原子类型的值。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 swap 方法交换值为 20，返回原始值
    let oldValue = atomicUInt8.swap(20)
    println("交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
交换前的旧值: 10
交换后的当前值: 20
```

### func swap(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

功能：交换操作，采用参数 `memoryOrder` 指定的内存排序方式，将参数 `val` 指定的值写入原子类型，并返回写入前的值。

> **注意：**
>
> 未来版本即将废弃，使用 [swap(UInt8)](#func-swapuint8) 替代。

参数：

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入原子类型的值。
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - 当前操作的内存排序方式。

返回值：

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 写入前的值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 AtomicUInt8 实例，初始值为 10
    let atomicUInt8 = AtomicUInt8(10)
    println("初始值: ${atomicUInt8.load()}")

    // 使用 deprecated 的 swap 方法（带 MemoryOrder 参数）
    let oldValue = atomicUInt8.swap(20, memoryOrder: SeqCst)
    println("使用 deprecated 的 swap 方法交换前的旧值: ${oldValue}")
    println("交换后的当前值: ${atomicUInt8.load()}")
}
```

运行结果：

```text
初始值: 10
使用 deprecated 的 swap 方法交换前的旧值: 10
交换后的当前值: 20
```

## class Barrier

```cangjie
public class Barrier {
    public init(count: Int64)
}
```

功能：提供协调多个线程一起执行到某一个程序点的功能。

率先到达程序点的线程将进入阻塞状态，当所有线程都到达程序点后，才一起继续执行。

### init(Int64)

```cangjie
public init(count: Int64)
```

功能：创建 [Barrier](sync_package_classes.md#class-barrier) 对象。

参数：

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 表示需要协调的线程数。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) 为负数。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 Barrier 对象，需要协调 3 个线程
    let barrier = Barrier(3)
    println("Barrier 实例创建成功，需要协调 3 个线程")
}
```

运行结果：

```text
Barrier 实例创建成功，需要协调 3 个线程
```

### func wait(Duration)

```cangjie
public func wait(timeout!: Duration = Duration.Max): Unit
```

功能：线程进入 [Barrier](sync_package_classes.md#class-barrier) 等待点。

如果 [Barrier](sync_package_classes.md#class-barrier) 对象所有调用 `wait` 的次数（即进入等待点的线程数）等于初始值，那么唤醒所有等待的线程；如果调用 `wait` 方法次数仍小于初始值，那么当前线程进入阻塞状态直到被唤醒或者等待时间超过 `timeout`；如果调用 `wait` 次数已大于初始值，那么线程继续执行。

参数：

- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 阻塞时等待的最大时长，其默认值为 [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

main(): Unit {
    // 创建一个 Barrier 对象，需要协调 3 个线程
    let barrier = Barrier(3)
    let list = ArrayList<Future<Unit>>()

    // 创建 3 个线程
    for (i in 0..3) {
        let fut = spawn {
            println("开始执行的线程: 线程 ${i}")
            sleep(100 * Duration.millisecond) // 模拟一些工作
            println("到达屏障点的线程: 线程 ${i}")
            barrier.wait() // 等待所有线程到达屏障点
            println("继续执行的线程: 线程 ${i}")
        }
        list.add(fut)
    }

    // 等待所有线程完成
    for (f in list) {
        f.get()
    }

    println("所有线程执行完成")
}
```

可能的运行结果：

```text
开始执行的线程: 线程 2
开始执行的线程: 线程 0
开始执行的线程: 线程 1
到达屏障点的线程: 线程 1
到达屏障点的线程: 线程 0
到达屏障点的线程: 线程 2
继续执行的线程: 线程 2
继续执行的线程: 线程 1
继续执行的线程: 线程 0
所有线程执行完成
```

## class Monitor <sup>(deprecated)</sup>

```cangjie
public class Monitor <: ReentrantMutex {
    public init()
}
```

功能：提供使线程阻塞并等待来自另一个线程的信号以恢复执行的功能。

这是一种利用共享变量进行线程同步的机制，当一些线程因等待共享变量的某个条件成立而挂起时，另一些线程改变共享的变量，使条件成立，
然后执行唤醒操作。这使得挂起的线程被唤醒后可以继续执行。

> **注意：**
>
> 未来版本即将废弃，使用 [Condition](./sync_package_interfaces.md#interface-condition) 替代。

父类型：

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### init()

```cangjie
public init()
```

功能：通过默认构造函数创建 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated)。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 Monitor 对象
    let monitor = Monitor()
}
```

### func notify()

```cangjie
public func notify(): Unit
```

功能：唤醒一个等待在该 `Montior` 上的线程。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*
import std.time.*
import std.collection.*

var mon = Monitor()
var flag: Bool = true

main(): Int64 {
    let fut = spawn {
        mon.lock()
        while (flag) {
            println("New thread: before wait")
            mon.wait()
            println("New thread: after wait")
        }
        mon.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    mon.lock()
    println("Main thread: set flag")
    flag = false
    mon.unlock()

    println("Main thread: notify")
    mon.lock()
    mon.notify() // 唤醒一个等待的线程
    mon.unlock()

    /* 等待新线程完成 */
    fut.get()
    return 0
}
```

运行结果：

```text
New thread: before wait
Main thread: set flag
Main thread: notify
New thread: after wait
```

### func notifyAll()

```cangjie
public func notifyAll(): Unit
```

功能：唤醒所有等待在该 `Montior` 上的线程。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

var mon = Monitor()
var flag: Bool = true

main(): Int64 {
    // 创建两个等待线程
    let fut1 = spawn {
        mon.lock()
        while (flag) {
            println("before wait: Thread 1")
            mon.wait()
            println("after wait: Thread 1")
        }
        mon.unlock()
    }

    let fut2 = spawn {
        mon.lock()
        while (flag) {
            println("before wait: Thread 2")
            mon.wait()
            println("after wait: Thread 2")
        }
        mon.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    mon.lock()
    println("Main thread: set flag")
    flag = false
    mon.unlock()

    println("Main thread: notifyAll")
    mon.lock()
    mon.notifyAll() // 唤醒所有等待的线程
    mon.unlock()

    /* 等待新线程完成 */
    fut1.get()
    fut2.get()
    return 0
}
```

可能的运行结果：

```text
before wait: Thread 1
before wait: Thread 2
Main thread: set flag
Main thread: notifyAll
after wait: Thread 2
after wait: Thread 1
```

### func wait(Duration)

```cangjie
public func wait(timeout!: Duration = Duration.Max): Bool
```

功能：当前线程挂起，直到对应的 `notify` 函数被调用，或者挂起时间超过 `timeout`。

> **说明：**
>
> 线程在进入等待时会释放对应的互斥锁，被唤醒后再次持有互斥锁。

参数：

- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 挂起时间，其默认值为 [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) 被其他线程唤醒，返回 `true`；如果超时，则返回 `false`。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 `timeout` 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero)，抛出异常。
- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var mon = Monitor()
var flag: Bool = true

main(): Int64 {
    let fut = spawn {
        mon.lock()
        while (flag) {
            println("New thread: before wait")
            // 等待最多 1 秒钟
            let result = mon.wait(timeout: 1 * Duration.second)
            if (result) {
                println("New thread: awakened by notify")
            } else {
                println("New thread: timeout")
            }
        }
        mon.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    mon.lock()
    println("Main thread: set flag")
    flag = false
    mon.unlock()

    println("Main thread: notify")
    mon.lock()
    mon.notify() // 唤醒等待的线程
    mon.unlock()

    /* 等待新线程完成 */
    fut.get()
    return 0
}
```

运行结果：

```text
New thread: before wait
Main thread: set flag
Main thread: notify
New thread: awakened by notify
```

## class MultiConditionMonitor <sup>(deprecated)</sup>

```cangjie
public class MultiConditionMonitor <: ReentrantMutex {
    public init()
}
```

功能：提供对同一个互斥锁绑定多个条件变量的功能。

> **注意：**
>
> - 未来版本即将废弃，使用 [Mutex](#class-mutex) 替代。
> - 该类应仅当在 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) 类不足以实现高级并发算法时被使用。
> - 初始化时，[MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) 没有与之相关的条件变量。
> - 每次调用 `newCondition` 将创建一个新的等待队列并与当前对象关联，并返回[ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated)类型实例作为唯一标识符。

父类型：

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### init()

```cangjie
public init()
```

功能：通过默认构造函数创建 [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated)。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 MultiConditionMonitor 对象
    let monitor = MultiConditionMonitor()
}
```

### func newCondition()

```cangjie
public func newCondition(): ConditionID
```

功能：创建一个与该 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) 相关的 [ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated)，可能被用来实现 “单互斥体多等待队列” 的并发原语。

返回值：

- [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - 新的 [ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated)。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 MultiConditionMonitor 对象
    let monitor = MultiConditionMonitor()

    // 创建一个条件变量
    monitor.lock()
    let conditionID = monitor.newCondition()
    monitor.unlock()
}
```

### func notify(ConditionID)

```cangjie
public func notify(condID: ConditionID): Unit
```

功能：唤醒等待在所指定的条件变量的线程（如果有）。

参数：

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - 条件变量。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，或 `condID` 不是由该 [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) 实例通过 `newCondition` 函数创建时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var monitor = MultiConditionMonitor()
var flag: Bool = true

main(): Int64 {
    // 创建一个条件变量
    monitor.lock()
    let conditionID = monitor.newCondition()
    monitor.unlock()

    let fut = spawn {
        monitor.lock()
        while (flag) {
            println("New thread: before wait")
            monitor.wait(conditionID)
            println("New thread: after wait")
        }
        monitor.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    monitor.lock()
    println("Main thread: set flag")
    flag = false
    monitor.unlock()

    println("Main thread: notify")
    monitor.lock()
    monitor.notify(conditionID) // 唤醒指定条件变量上的一个线程
    monitor.unlock()

    /* 等待新线程完成 */
    fut.get()
    return 0
}
```

运行结果：

```text
New thread: before wait
Main thread: set flag
Main thread: notify
New thread: after wait
```

### func notifyAll(ConditionID)

```cangjie
public func notifyAll(condID: ConditionID): Unit
```

功能：唤醒所有等待在所指定的条件变量的线程（如果有）。

参数：

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - 条件变量。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，或 `condID` 不是由该 [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) 实例通过 `newCondition` 函数创建时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

var monitor = MultiConditionMonitor()
var flag: Bool = true

main(): Int64 {
    // 创建一个条件变量
    monitor.lock()
    let conditionID = monitor.newCondition()
    monitor.unlock()

    // 创建两个等待线程
    let fut1 = spawn {
        monitor.lock()
        while (flag) {
            println("before wait: Thread 1")
            monitor.wait(conditionID)
            println("after wait: Thread 1")
        }
        monitor.unlock()
    }

    let fut2 = spawn {
        monitor.lock()
        while (flag) {
            println("before wait: Thread 2")
            monitor.wait(conditionID)
            println("after wait: Thread 2")
        }
        monitor.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    monitor.lock()
    println("Main thread: set flag")
    flag = false
    monitor.unlock()

    println("Main thread: notifyAll")
    monitor.lock()
    monitor.notifyAll(conditionID) // 唤醒指定条件变量上的所有线程
    monitor.unlock()

    /* 等待新线程完成 */
    fut1.get()
    fut2.get()
    return 0
}
```

可能的运行结果：

```text
before wait: Thread 2
before wait: Thread 1
Main thread: set flag
Main thread: notifyAll
after wait: Thread 1
after wait: Thread 2
```

### func wait(ConditionID, Duration)

```cangjie
public func wait(condID: ConditionID, timeout!: Duration = Duration.Max): Bool
```

功能：当前线程挂起，直到对应的 `notify` 函数被调用。

> **说明：**
>
> 线程在进入等待时会释放对应的互斥锁，被唤醒后再次持有互斥锁。

参数：

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - 条件变量。
- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 挂起时间，其默认值为 [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果该 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) 指定的条件变量被其他线程唤醒，返回 `true`；如果超时，则返回 `false`。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，或 `condID` 不是由该 [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) 实例通过 `newCondition` 函数创建时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 `timeout` 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero)，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var monitor = MultiConditionMonitor()
var flag: Bool = true

main(): Int64 {
    // 创建一个条件变量
    monitor.lock()
    let conditionID = monitor.newCondition()
    monitor.unlock()

    let fut = spawn {
        monitor.lock()
        while (flag) {
            println("New thread: before wait")
            // 等待最多 1 秒钟
            let result = monitor.wait(conditionID, timeout: 1 * Duration.second)
            if (result) {
                println("New thread: awakened by notify")
            } else {
                println("New thread: timeout")
            }
        }
        monitor.unlock()
    }

    /* 睡眠 10 毫秒，以确保新线程可以执行 */
    sleep(10 * Duration.millisecond)

    monitor.lock()
    println("Main thread: set flag")
    flag = false
    monitor.unlock()

    println("Main thread: notify")
    monitor.lock()
    monitor.notify(conditionID) // 唤醒指定条件变量上的一个线程
    monitor.unlock()

    /* 等待新线程完成 */
    fut.get()
    return 0
}
```

运行结果：

```text
New thread: before wait
Main thread: set flag
Main thread: notify
New thread: awakened by notify
```

## class Mutex

```cangjie
public class Mutex <: UniqueLock {
    public init()
}
```

功能：提供可重入互斥锁相关功能。

可重入互斥锁的作用是对临界区加以保护，使得任意时刻最多只有一个线程能够执行临界区的代码。
当一个线程试图获取一个已被其他线程持有的锁时，该线程会被阻塞，直到锁被释放，该线程才会被唤醒，可重入是指线程获取该锁后可再次获得该锁。

> **注意：**
>
> - 在访问共享数据之前，必须尝试获取锁。
> - 处理完共享数据后，必须进行解锁，以便其他线程可以获得锁。

父类型：

- [UniqueLock](./sync_package_interfaces.md#interface-uniquelock)

### init()

```cangjie
public init()
```

功能：创建可重入互斥锁。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 当出现系统错误时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 Mutex 对象
    let mutex = Mutex()
}
```

### func condition()

```cangjie
public func condition(): Condition
```

功能：创建一个与该 [Mutex](#class-mutex) 相关的 [Condition](./sync_package_interfaces.md#interface-condition)。

可能被用来实现 “单 Lock 多等待队列” 的并发原语。

返回值：

- [Condition](./sync_package_interfaces.md#interface-condition) - 创建的与该 [Mutex](#class-mutex) 相关的 [Condition](./sync_package_interfaces.md#interface-condition) 实例。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 Mutex 对象
    let mutex = Mutex()

    // 创建一个条件变量
    mutex.lock()
    let condition = mutex.condition()
    mutex.unlock()
}
```

### func lock()

```cangjie
public func lock(): Unit
```

功能：锁定互斥体，如果互斥体已被锁定，则阻塞。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

var mutex = Mutex()
var sharedData: Int32 = 0

main(): Int64 {
    let list = ArrayList<Future<Unit>>()

    // 创建 3 个线程并发访问共享数据
    for (i in 0..3) {
        let fut = spawn {
            mutex.lock()
            // 临界区：访问共享数据
            sharedData = sharedData + 1
            println("sharedData = ${sharedData}, 线程: ${i}")
            mutex.unlock()
        }
        list.add(fut)
    }

    // 等待所有线程完成
    for (f in list) {
        f.get()
    }

    println("所有线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

可能的运行结果：

```text
sharedData = 1, 线程: 2
sharedData = 2, 线程: 1
sharedData = 3, 线程: 0
所有线程执行完成，最终 sharedData = 3
```

### func tryLock()

```cangjie
public func tryLock(): Bool
```

功能：尝试锁定互斥体。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果互斥体已被锁定，则返回 `false`；反之，则锁定互斥体并返回 `true`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var mutex = Mutex()
var sharedData: Int32 = 0

main(): Int64 {
    // 先锁定互斥体
    mutex.lock()
    println("主线程已锁定互斥体")

    // 启动一个新线程尝试锁定互斥体
    let fut = spawn {
        // 尝试锁定互斥体（应该会失败，因为主线程已锁定）
        let result = mutex.tryLock()
        if (result) {
            println("子线程 tryLock 成功")
            sharedData = sharedData + 1
            mutex.unlock()
        } else {
            println("子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待子线程完成
    fut.get()

    // 主线程解锁
    mutex.unlock()
    println("主线程已解锁互斥体")

    // 再次启动一个线程尝试锁定互斥体
    let fut2 = spawn {
        // 尝试锁定互斥体（应该会成功，因为主线程已解锁）
        let result = mutex.tryLock()
        if (result) {
            println("第二个子线程 tryLock 成功")
            sharedData = sharedData + 1
            mutex.unlock()
        } else {
            println("第二个子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待第二个子线程完成
    fut2.get()

    println("最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
主线程已锁定互斥体
子线程 tryLock 失败，互斥体已被其他线程锁定
主线程已解锁互斥体
第二个子线程 tryLock 成功
最终 sharedData = 1
```

### func unlock()

```cangjie
public func unlock(): Unit
```

功能：解锁互斥体。

如果互斥体被重复加锁了 N 次，那么需要调用 N 次该函数来完全解锁，一旦互斥体被完全解锁，如果有其他线程阻塞在此锁上，那么唤醒它们中的一个。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var mutex = Mutex()
var sharedData: Int32 = 0

main(): Int64 {
    // 创建两个线程，演示锁的获取和释放
    let fut1 = spawn {
        mutex.lock()
        println("线程1: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程1: 修改 sharedData = ${sharedData}")

        // 释放锁
        mutex.unlock()
        println("线程1: 已释放锁")
    }

    let fut2 = spawn {
        // 等待一段时间，确保线程1先获取锁
        sleep(10 * Duration.millisecond)

        mutex.lock()
        println("线程2: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程2: 修改 sharedData = ${sharedData}")

        // 释放锁
        mutex.unlock()
        println("线程2: 已释放锁")
    }

    // 等待所有线程完成
    fut1.get()
    fut2.get()

    println("所有线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
线程1: 已获取锁
线程1: 修改 sharedData = 1
线程1: 已释放锁
线程2: 已获取锁
线程2: 修改 sharedData = 2
线程2: 已释放锁
所有线程执行完成，最终 sharedData = 2
```

## class ReadWriteLock

```cangjie
public class ReadWriteLock {
    public init(fair!: Bool = false)
}
```

功能：提供可重入读写锁相关功能。

它和普通互斥锁的差异在于：读写锁同时携带两个互斥锁，分别为“读锁”以及“写锁”，并且它允许多个线程同时持有读锁。

读写锁的特殊性质说明：

- 写互斥性：只有唯一的线程能够持有写锁。当一个线程持有写锁，而其他线程再次获取锁（读锁或是写锁）时将被阻塞。
- 读并发性：允许多个线程同时持有读锁。当一个线程持有读锁，其他线程仍然可以获取读锁。但其他线程获取写锁时将被阻塞。
- 可重入性：一个线程可以重复获取锁。
    - 当线程已持有写锁时，它可以继续获取写锁或者读锁。只有当锁释放操作和获取操作一一对应时，锁才被完全释放。
    - 当线程已持有读锁时，它可以继续获取读锁。当锁释放操作和获取操作一一对应时，锁才被完全释放。注意，不允许在持有读锁的情况下获取写锁，这将抛出异常。
- 锁降级：一个线程在经历“持有写锁--持有读锁--释放写锁”后，它持有的是读锁而不再是写锁。
- 读写公平性：读写锁支持两种不同的模式，分别为“公平”及“非公平”模式。
    - 在非公平模式下，读写锁对线程获取锁的顺序不做任何保证。持续竞争的非公平锁可能会无限期推迟一个或多个读 / 写线程。
    - 在公平模式下，当线程获取读锁时（当前线程未持有读锁），如果写锁已被获取或是存在线程等待写锁，那么当前线程无法获取读锁并进入等待。
    - 在公平模式下，写锁释放会优先唤醒所有读线程、读锁释放会优先唤醒一个等待写锁的线程。当存在多个线程等待写锁，它们之间被唤醒的先后顺序并不做保证。

### prop readLock

```cangjie
public prop readLock: Lock
```

功能：获取读锁。

类型：[Lock](./sync_package_interfaces.md#interface-lock)

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

var rwLock = ReadWriteLock()
var sharedData: Int32 = 0

main(): Int64 {
    let list = ArrayList<Future<Unit>>()

    // 创建多个读线程，同时读取共享数据
    for (i in 0..3) {
        let fut = spawn {
            // 获取读锁
            let readLock = rwLock.readLock
            readLock.lock()

            // 读取共享数据（读操作）
            println("读取 sharedData = ${sharedData}, 线程: ${i}")

            // 模拟读操作需要一些时间，这里发现，多线程同时进行了读操作，没有发生冲突
            sleep(2 * Duration.second)

            readLock.unlock()
        }
        list.add(fut)
    }

    // 等待所有读线程完成
    for (f in list) {
        f.get()
    }

    println("所有读线程执行完成")
    return 0
}
```

可能的运行结果：

```text
读取 sharedData = 0, 线程: 2
读取 sharedData = 0, 线程: 0
读取 sharedData = 0, 线程: 1
所有读线程执行完成
```

### prop writeLock

```cangjie
public prop writeLock: UniqueLock
```

功能：获取写锁。

类型：[UniqueLock](./sync_package_interfaces.md#interface-uniquelock)

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

var rwLock = ReadWriteLock()
var sharedData: Int32 = 0

main(): Int64 {
    let list = ArrayList<Future<Unit>>()

    // 创建多个写线程，同时写入共享数据
    for (i in 0..3) {
        let fut = spawn {
            // 获取写锁
            let writeLock = rwLock.writeLock
            writeLock.lock()

            // 写入共享数据（写操作）
            sharedData++
            println("写入之后 sharedData = ${sharedData}, 线程: ${i}")

            // 模拟写操作需要一些时间，这里发现，需要前面的写操作完成之后，后面的写操作才能开始
            sleep(1 * Duration.second)

            writeLock.unlock()
        }
        list.add(fut)
    }

    // 等待所有读线程完成
    for (f in list) {
        f.get()
    }

    println("所有写线程执行完成")
    return 0
}
```

可能的运行结果：

```text
写入之后 sharedData = 1, 线程: 2
写入之后 sharedData = 2, 线程: 1
写入之后 sharedData = 3, 线程: 0
所有写线程执行完成
```

### init(Bool)

```cangjie
public init(fair!: Bool = false)
```

功能：构造读写锁。

参数：

- fair!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 读写锁是否为公平模式，默认值为 `false`，即构造 “非公平” 的读写锁。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个非公平模式的 ReadWriteLock 对象
    let rwLock1 = ReadWriteLock()

    // 创建一个公平模式的 ReadWriteLock 对象
    let rwLock2 = ReadWriteLock(fair: true)
}
```

### func isFair()

```cangjie
public func isFair(): Bool
```

功能：获取读写锁是否为 “公平” 模式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` 表示 “公平” 模式，否则表示 “非公平” 模式。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个非公平模式的 ReadWriteLock 对象
    let rwLock1 = ReadWriteLock()
    println("rwLock1 是否为公平模式: ${rwLock1.isFair()}")

    // 创建一个公平模式的 ReadWriteLock 对象
    let rwLock2 = ReadWriteLock(fair: true)
    println("rwLock2 是否为公平模式: ${rwLock2.isFair()}")
}
```

运行结果：

```text
rwLock1 是否为公平模式: false
rwLock2 是否为公平模式: true
```

## class ReentrantMutex <sup>(deprecated)</sup>

```cangjie
public open class ReentrantMutex <: Lock {
    public init()
}
```

功能：提供可重入锁相关功能。

可重入互斥锁的作用是对临界区加以保护，使得任意时刻最多只有一个线程能够执行临界区的代码。
当一个线程试图获取一个已被其他线程持有的锁时，该线程会被阻塞，直到锁被释放，该线程才会被唤醒，可重入是指线程获取该锁后可再次获得该锁。

> **注意：**
>
> - 未来版本即将废弃，使用 [Mutex](#class-mutex) 替代。
> - [ReentrantMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantmutex-deprecated) 是内置的互斥锁，开发者需要保证不继承它。
> - 在访问共享数据之前，必须尝试获取锁。
> - 处理完共享数据后，必须进行解锁，以便其他线程可以获得锁。

父类型：

- [Lock](sync_package_interfaces.md#interface-lock)

### init()

```cangjie
public init()
```

功能：创建可重入互斥锁。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 当出现系统错误时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个可重入互斥锁
    let reentrantMutex = ReentrantMutex()
}
```

### func lock()

```cangjie
public open func lock(): Unit
```

功能：锁定互斥体，如果互斥体已被锁定，则阻塞。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var reentrantMutex = ReentrantMutex()
var sharedData: Int32 = 0

main(): Int64 {
    // 创建两个线程，演示锁的获取和释放
    let fut1 = spawn {
        reentrantMutex.lock()
        println("线程1: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程1: 修改 sharedData = ${sharedData}")

        // 释放锁
        reentrantMutex.unlock()
        println("线程1: 已释放锁")
    }

    let fut2 = spawn {
        // 等待一段时间，确保线程1先获取锁
        sleep(10 * Duration.millisecond)

        reentrantMutex.lock()
        println("线程2: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程2: 修改 sharedData = ${sharedData}")

        // 释放锁
        reentrantMutex.unlock()
        println("线程2: 已释放锁")
    }

    // 等待所有线程完成
    fut1.get()
    fut2.get()

    println("所有线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
线程1: 已获取锁
线程1: 修改 sharedData = 1
线程1: 已释放锁
线程2: 已获取锁
线程2: 修改 sharedData = 2
线程2: 已释放锁
所有线程执行完成，最终 sharedData = 2
```

### func tryLock()

```cangjie
public open func tryLock(): Bool
```

功能：尝试锁定互斥体。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果互斥体已被锁定，则返回 `false`；反之，则锁定互斥体并返回 `true`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var reentrantMutex = ReentrantMutex()
var sharedData: Int32 = 0

main(): Int64 {
    // 先获取锁
    reentrantMutex.lock()
    println("主线程: 已获取锁")

    // 创建一个线程，尝试获取已被占用的锁
    let fut = spawn {
        // 尝试获取锁，应该会失败
        let result = reentrantMutex.tryLock()
        if (result) {
            println("子线程: 成功获取锁")
            sharedData = sharedData + 1
            reentrantMutex.unlock()
        } else {
            println("子线程: 获取锁失败，锁已被占用")
        }
    }

    // 等待一段时间，让子线程执行
    sleep(10 * Duration.millisecond)

    // 释放锁
    reentrantMutex.unlock()
    println("主线程: 已释放锁")

    // 再次尝试获取锁，应该会成功
    let result = reentrantMutex.tryLock()
    if (result) {
        println("主线程: 再次成功获取锁")
        sharedData = sharedData + 1
        reentrantMutex.unlock()
    } else {
        println("主线程: 再次获取锁失败")
    }

    // 等待子线程完成
    fut.get()

    println("所有线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
主线程: 已获取锁
子线程: 获取锁失败，锁已被占用
主线程: 已释放锁
主线程: 再次成功获取锁
所有线程执行完成，最终 sharedData = 1
```

### func unlock()

```cangjie
public open func unlock(): Unit
```

功能：解锁互斥体。

如果互斥体被重复加锁了 N 次，那么需要调用 N 次该函数来完全解锁，一旦互斥体被完全解锁，如果有其他线程阻塞在此锁上，那么唤醒它们中的一个。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 如果当前线程没有持有该互斥体，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var reentrantMutex = ReentrantMutex()
var sharedData: Int32 = 0

main(): Int64 {
    // 创建两个线程，演示锁的获取和释放
    let fut1 = spawn {
        reentrantMutex.lock()
        println("线程1: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程1: 修改 sharedData = ${sharedData}")

        // 释放锁
        reentrantMutex.unlock()
        println("线程1: 已释放锁")
    }

    let fut2 = spawn {
        // 等待一段时间，确保线程1先获取锁
        sleep(10 * Duration.millisecond)

        reentrantMutex.lock()
        println("线程2: 已获取锁")

        // 模拟一些工作
        sharedData = sharedData + 1
        println("线程2: 修改 sharedData = ${sharedData}")

        // 释放锁
        reentrantMutex.unlock()
        println("线程2: 已释放锁")
    }

    // 等待所有线程完成
    fut1.get()
    fut2.get()

    println("所有线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
线程1: 已获取锁
线程1: 修改 sharedData = 1
线程1: 已释放锁
线程2: 已获取锁
线程2: 修改 sharedData = 2
线程2: 已释放锁
所有线程执行完成，最终 sharedData = 2
```

## class ReentrantReadMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantReadMutex <: ReentrantMutex {}
```

功能：提供可重入读写锁中的读锁类型。

> **注意：**
>
> 未来版本即将废弃，使用 [Lock](./sync_package_interfaces.md#interface-lock) 替代。

父类型：

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### func lock()

```cangjie
public func lock(): Unit
```

功能：获取读锁。

> **注意：**
>
> - 在公平模式下，如果没有其他线程持有或等待写锁，或是当前线程已持有读锁，则立即持有读锁；否则，当前线程进入等待状态。
> - 在非公平模式下，如果没有其他线程持有或等待写锁，则立即持有读锁；如果有其他线程持有写锁，当前线程进入等待状态；否则，线程是否能立即持有读锁不做保证。
> - 多个线程可以同时持有读锁并且一个线程可以重复多次持有读锁；如果一个线程持有写锁，那么它仍可以持有读锁。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

// 注意：ReentrantReadWriteMutex 已废弃
var readLock = ReentrantReadWriteMutex().readMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 创建多个读线程，演示读锁的并发性
    let list = ArrayList<Future<Unit>>()

    for (i in 0..3) {
        let fut = spawn {
            readLock.lock()
            println("读取 sharedData = ${sharedData}, 线程: ${i} 获取读锁成功")

            // 模拟读操作需要一些时间
            sleep(10 * Duration.millisecond)

            // 释放读锁
            readLock.unlock()
            println("释放读锁, 线程: ${i}")
        }
        list.add(fut)
    }

    // 等待所有读线程完成
    for (f in list) {
        f.get()
    }

    println("所有读线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

可能的运行结果：

```text
读取 sharedData = 0, 线程: 2 获取读锁成功
读取 sharedData = 0, 线程: 0 获取读锁成功
读取 sharedData = 0, 线程: 1 获取读锁成功
释放读锁, 线程: 2
释放读锁, 线程: 1
释放读锁, 线程: 0
所有读线程执行完成，最终 sharedData = 0
```

### func tryLock()

```cangjie
public func tryLock(): Bool
```

功能：尝试获取读锁。该方法获取读锁时并不遵循公平模式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 若成功获取读锁，返回 `true`；若未能获取读锁，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

// 注意：ReentrantReadWriteMutex 已废弃
var readLock = ReentrantReadWriteMutex().readMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 先锁定互斥体
    readLock.lock()
    println("主线程已锁定互斥体")

    // 启动一个新线程尝试锁定互斥体
    let fut = spawn {
        // 尝试锁定互斥体（应该会失败，因为主线程已锁定，但是因为读锁特性，此会成功）
        let result = readLock.tryLock()
        if (result) {
            println("子线程 tryLock 成功")
            sharedData = sharedData + 1
            readLock.unlock()
        } else {
            println("子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待子线程完成
    fut.get()

    // 主线程解锁
    readLock.unlock()
    println("主线程已解锁互斥体")

    // 再次启动一个线程尝试锁定互斥体
    let fut2 = spawn {
        // 尝试锁定互斥体（应该会成功，因为主线程已解锁）
        let result = readLock.tryLock()
        if (result) {
            println("第二个子线程 tryLock 成功")
            sharedData = sharedData + 1
            readLock.unlock()
        } else {
            println("第二个子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待第二个子线程完成
    fut2.get()

    println("最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
主线程已锁定互斥体
子线程 tryLock 成功
主线程已解锁互斥体
第二个子线程 tryLock 成功
最终 sharedData = 2
```

### func unlock()

```cangjie
public func unlock(): Unit
```

功能：释放读锁。如果一个线程多次持有读锁，那么仅当释放操作和获取操作数量相同时才释放读锁；如果读锁被释放并且存在线程等待写锁，那么唤醒其中一个线程。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 当前线程未持有读锁，那么将抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

// 注意：ReentrantReadWriteMutex 已废弃
var readLock = ReentrantReadWriteMutex().readMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 先锁定互斥体
    readLock.lock()
    println("主线程已锁定互斥体")

    // 启动一个新线程尝试锁定互斥体
    let fut = spawn {
        // 尝试锁定互斥体（应该会失败，因为主线程已锁定）
        let result = readLock.tryLock()
        if (result) {
            println("子线程 tryLock 成功")
            sharedData = sharedData + 1
            readLock.unlock()
        } else {
            println("子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待子线程完成
    fut.get()

    // 主线程解锁
    readLock.unlock()
    println("主线程已解锁互斥体")

    // 再次启动一个线程尝试锁定互斥体
    let fut2 = spawn {
        // 尝试锁定互斥体（应该会成功，因为主线程已解锁）
        let result = readLock.tryLock()
        if (result) {
            println("第二个子线程 tryLock 成功")
            sharedData = sharedData + 1
            readLock.unlock()
        } else {
            println("第二个子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待第二个子线程完成
    fut2.get()

    println("最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
主线程已锁定互斥体
子线程 tryLock 成功
主线程已解锁互斥体
第二个子线程 tryLock 成功
最终 sharedData = 2
```

## class ReentrantReadWriteMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantReadWriteMutex {
    public init(mode!: ReadWriteMutexMode = ReadWriteMutexMode.Unfair)
}
```

功能：提供可重入读写锁相关功能。

它和普通互斥锁的差异在于：读写锁同时携带两个互斥锁，分别为“读锁”以及“写锁”，并且它允许多个线程同时持有读锁。

> **注意：**
>
> 未来版本即将废弃，使用 [ReadWriteLock](#class-readwritelock) 替代。

读写锁的特殊性质说明：

- 写互斥性：只有唯一的线程能够持有写锁。当一个线程持有写锁，而其他线程再次获取锁（读锁或是写锁）时将被阻塞。
- 读并发性：允许多个线程同时持有读锁。当一个线程持有读锁，其他线程仍然可以获取读锁。但其他线程获取写锁时将被阻塞。
- 可重入性：一个线程可以重复获取锁。
    - 当线程已持有写锁时，它可以继续获取写锁或者读锁。只有当锁释放操作和获取操作一一对应时，锁才被完全释放。
    - 当线程已持有读锁时，它可以继续获取读锁。当锁释放操作和获取操作一一对应时，锁才被完全释放。注意，不允许在持有读锁的情况下获取写锁，这将抛出异常。
- 锁降级：一个线程在经历“持有写锁--持有读锁--释放写锁”后，它持有的是读锁而不再是写锁。
- 读写公平性：读写锁支持两种不同的模式，分别为“公平”及“非公平”模式。
    - 在非公平模式下，读写锁对线程获取锁的顺序不做任何保证。持续竞争的非公平锁可能会无限期推迟一个或多个读 / 写线程。
    - 在公平模式下，当线程获取读锁时（当前线程未持有读锁），如果写锁已被获取或是存在线程等待写锁，那么当前线程无法获取读锁并进入等待。
    - 在公平模式下，写锁释放会优先唤醒所有读线程、读锁释放会优先唤醒一个等待写锁的线程。当存在多个线程等待写锁，它们之间被唤醒的先后顺序并不做保证。

### prop readMutex

```cangjie
public prop readMutex: ReentrantReadMutex
```

功能：获取读锁。

类型：[ReentrantReadMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantreadmutex-deprecated)

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 ReentrantReadWriteMutex 对象
    var rwMutex = ReentrantReadWriteMutex()

    // 获取读锁
    let readMutex = rwMutex.readMutex
}
```

### prop writeMutex

```cangjie
public prop writeMutex: ReentrantWriteMutex
```

功能：获取写锁。

类型：[ReentrantWriteMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantwritemutex-deprecated)

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个 ReentrantReadWriteMutex 对象
    var rwMutex = ReentrantReadWriteMutex()

    // 获取写锁
    let writeMutex = rwMutex.writeMutex
}
```

### init(ReadWriteMutexMode)

```cangjie
public init(mode!: ReadWriteMutexMode = ReadWriteMutexMode.Unfair)
```

功能：构造读写锁。

参数：

- mode!: [ReadWriteMutexMode <sup>(deprecated)</sup>](sync_package_enums.md#enum-readwritemutexmode-deprecated) - 读写锁模式，默认值为 `Unfair`，即构造“非公平”的读写锁。

示例：

<!-- run -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个非公平模式的 ReentrantReadWriteMutex 对象
    var rwMutex1 = ReentrantReadWriteMutex()

    // 创建一个公平模式的 ReentrantReadWriteMutex 对象
    var rwMutex2 = ReentrantReadWriteMutex(mode: ReadWriteMutexMode.Fair)
}
```

## class ReentrantWriteMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantWriteMutex <: ReentrantMutex {}
```

功能：提供可重入读写锁中的写锁类型。

> **注意：**
>
> 未来版本即将废弃，使用 [UniqueLock](./sync_package_interfaces.md#interface-uniquelock) 替代。

父类型：

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### func lock()

```cangjie
public func lock(): Unit
```

功能：获取写锁。只允许唯一线程能够持有写锁，且该线程能多次重复持有写锁。如果存在其他线程持有写锁或是读锁，那么当前线程进入等待状态。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 当前线程已持有读锁。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

// 注意：ReentrantReadWriteMutex 已废弃
var writeLock = ReentrantReadWriteMutex().writeMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 创建多个读线程，演示写锁的并发性
    let list = ArrayList<Future<Unit>>()

    for (i in 0..3) {
        let fut = spawn {
            writeLock.lock()
            sharedData++
            println("读取 sharedData = ${sharedData}, 线程: ${i} 获取写锁成功")

            // 模拟读操作需要一些时间
            sleep(10 * Duration.millisecond)

            // 释放写锁
            writeLock.unlock()
            println("释放写锁, 线程: ${i}")
        }
        list.add(fut)
    }

    // 等待所有写线程完成
    for (f in list) {
        f.get()
    }

    println("所有写锁线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

可能的运行结果：

```text
读取 sharedData = 1, 线程: 2 获取写锁成功
释放写锁, 线程: 2
读取 sharedData = 2, 线程: 1 获取写锁成功
释放写锁, 线程: 1
读取 sharedData = 3, 线程: 0 获取写锁成功
释放写锁, 线程: 0
所有写锁线程执行完成，最终 sharedData = 3
```

### func tryLock()

```cangjie
public func tryLock(): Bool
```

功能：尝试获取写锁。该方法获取读锁时并不遵循公平模式。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 若成功获取写锁，返回 `true`；若未能获取写锁，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

// 注意：ReentrantReadWriteMutex 已废弃
var writeLock = ReentrantReadWriteMutex().writeMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 先锁定互斥体
    writeLock.lock()
    println("主线程已锁定互斥体")

    // 启动一个新线程尝试锁定互斥体
    let fut = spawn {
        // 尝试锁定互斥体（应该会失败，因为主线程已锁定）
        let result = writeLock.tryLock()
        if (result) {
            println("子线程 tryLock 成功")
            sharedData = sharedData + 1
            writeLock.unlock()
        } else {
            println("子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待子线程完成
    fut.get()

    // 主线程解锁
    writeLock.unlock()
    println("主线程已解锁互斥体")

    // 再次启动一个线程尝试锁定互斥体
    let fut2 = spawn {
        // 尝试锁定互斥体（应该会成功，因为主线程已解锁）
        let result = writeLock.tryLock()
        if (result) {
            println("第二个子线程 tryLock 成功")
            sharedData = sharedData + 1
            writeLock.unlock()
        } else {
            println("第二个子线程 tryLock 失败，互斥体已被其他线程锁定")
        }
    }

    // 等待第二个子线程完成
    fut2.get()

    println("最终 sharedData = ${sharedData}")
    return 0
}
```

运行结果：

```text
主线程已锁定互斥体
子线程 tryLock 失败，互斥体已被其他线程锁定
主线程已解锁互斥体
第二个子线程 tryLock 成功
最终 sharedData = 1
```

### func unlock()

```cangjie
public func unlock(): Unit
```

功能：释放写锁。

> **注意：**
>
> - 如果一个线程多次持有读锁，那么仅当释放操作和获取操作数量相同时才释放读锁；如果读锁被释放并且存在线程等待写锁，那么唤醒其中一个线程。
> - 在公平模式下，如果写锁被释放并且存在线程等待读锁，那么优先唤醒这些等待线程；如果没有线程等待读锁，但存在线程等待写锁，那么唤醒其中一个线程。
> - 在非公平模式下，如果写锁被释放，优先唤醒等待写锁的线程还是等待读锁的线程不做保证，交由具体实现决定。

异常：

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - 当前线程未持有写锁。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

// 注意：ReentrantReadWriteMutex 已废弃
var writeLock = ReentrantReadWriteMutex().writeMutex
var sharedData: Int32 = 0

main(): Int64 {
    // 创建多个读线程，演示写锁的并发性
    let list = ArrayList<Future<Unit>>()

    for (i in 0..3) {
        let fut = spawn {
            writeLock.lock()
            sharedData++
            println("读取 sharedData = ${sharedData}, 线程: ${i} 获取写锁成功")

            // 模拟读操作需要一些时间
            sleep(10 * Duration.millisecond)

            // 释放写锁
            writeLock.unlock()
            println("释放写锁, 线程: ${i}")
        }
        list.add(fut)
    }

    // 等待所有写线程完成
    for (f in list) {
        f.get()
    }

    println("所有写锁线程执行完成，最终 sharedData = ${sharedData}")
    return 0
}
```

可能的运行结果：

```text
读取 sharedData = 1, 线程: 2 获取写锁成功
释放写锁, 线程: 2
读取 sharedData = 2, 线程: 1 获取写锁成功
释放写锁, 线程: 1
读取 sharedData = 3, 线程: 0 获取写锁成功
释放写锁, 线程: 0
所有写锁线程执行完成，最终 sharedData = 3
```

## class Semaphore

```cangjie
public class Semaphore {
    public init(count: Int64)
}
```

功能：提供信号量相关功能。

[Semaphore](sync_package_classes.md#class-semaphore) 可以被视为携带计数器的 [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated)，常用于控制并发访问共享资源的线程数量。

### prop count

```cangjie
public prop count: Int64
```

功能：返回当前内部计数器的值。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个计数器初始值为 5 的信号量
    var semaphore = Semaphore(5)

    // 获取当前计数器的值
    let count = semaphore.count

    println("信号量创建成功，当前计数器值为: ${count}")
}
```

运行结果：

```text
信号量创建成功，当前计数器值为: 5
```

### init(Int64)

```cangjie
public init(count: Int64)
```

功能：创建一个 [Semaphore](sync_package_classes.md#class-semaphore) 对象并初始化内部计数器的值。

参数：

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 计数器初始值, 取值范围 [0, [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).Max]。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) 为负数时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Unit {
    // 创建一个计数器初始值为 5 的信号量
    var semaphore = Semaphore(5)

    println("信号量创建成功，初始计数器值为: ${semaphore.count}")

    // 尝试创建一个计数器初始值为 0 的信号量
    var semaphore2 = Semaphore(0)

    println("信号量创建成功，初始计数器值为: ${semaphore2.count}")
}
```

运行结果：

```text
信号量创建成功，初始计数器值为: 5
信号量创建成功，初始计数器值为: 0
```

### func acquire(Int64)

```cangjie
public func acquire(amount!: Int64 = 1): Unit
```

功能：向 [Semaphore](sync_package_classes.md#class-semaphore) 对象获取指定值。

如果当前计数器小于要求的数值，那么当前线程将被阻塞，直到获取满足数量的值后才被唤醒。

参数：

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 向对象内部计数器中获取的数值，默认值为 1。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数 `amount` 为负数，或大于初始值。

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.collection.*

var semaphore = Semaphore(2) // 创建一个计数器初始值为 2 的信号量

main(): Int64 {
    let list = ArrayList<Future<Unit>>()

    // 创建多个线程，演示信号量的获取和释放
    for (i in 0..5) {
        let fut = spawn {
            println("线程: ${i}, 尝试获取信号量")
            semaphore.acquire() // 获取信号量
            println("线程: ${i}, 成功获取信号量，开始执行任务")

            // 模拟执行任务
            sleep(10 * Duration.millisecond)

            println("线程: ${i}, 任务执行完成，释放信号量")
            semaphore.release() // 释放信号量
        }
        list.add(fut)
    }

    // 等待所有线程完成
    for (f in list) {
        f.get()
    }

    println("所有线程执行完成")
    return 0
}
```

可能的运行结果：

```text
线程: 4, 尝试获取信号量
线程: 4, 成功获取信号量，开始执行任务
线程: 0, 尝试获取信号量
线程: 0, 成功获取信号量，开始执行任务
线程: 1, 尝试获取信号量
线程: 3, 尝试获取信号量
线程: 2, 尝试获取信号量
线程: 4, 任务执行完成，释放信号量
线程: 2, 成功获取信号量，开始执行任务
线程: 0, 任务执行完成，释放信号量
线程: 1, 成功获取信号量，开始执行任务
线程: 2, 任务执行完成，释放信号量
线程: 3, 成功获取信号量，开始执行任务
线程: 1, 任务执行完成，释放信号量
线程: 3, 任务执行完成，释放信号量
所有线程执行完成
```

### func release(Int64)

```cangjie
public func release(amount!: Int64 = 1): Unit
```

功能：向 [Semaphore](sync_package_classes.md#class-semaphore) 对象释放指定值。

如果内部计数器在累加释放值后能够满足当前阻塞在 [Semaphore](sync_package_classes.md#class-semaphore) 对象的线程，那么将得到满足的线程唤醒；内部计数器的值不会大于初始值，即如果计数器的值在累加后大于初始值，那么仍被设置为初始值。所有在调用 `release` 之前的操作都先发生于调用 `acquire/tryAcquire` 之后的操作。

参数：

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 向对象内部计数器中释放的数值，默认值为 1。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数 `amount` 为负数，或大于初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var semaphore = Semaphore(1) // 创建一个计数器初始值为 1 的信号量

main(): Unit {
    println("初始信号量计数器值: ${semaphore.count}")

    // 获取信号量
    semaphore.acquire()
    println("获取信号量后计数器值: ${semaphore.count}")

    // 释放信号量
    semaphore.release()
    println("释放信号量后计数器值: ${semaphore.count}")

    // 再次释放信号量（计数器值不会超过初始值）
    semaphore.release()
    println("再次释放信号量后计数器值: ${semaphore.count}")
}
```

运行结果：

```text
初始信号量计数器值: 1
获取信号量后计数器值: 0
释放信号量后计数器值: 1
再次释放信号量后计数器值: 1
```

### func tryAcquire(Int64)

```cangjie
public func tryAcquire(amount!: Int64 = 1): Bool
```

功能：尝试向 [Semaphore](sync_package_classes.md#class-semaphore) 对象获取指定值。

该方法不会阻塞线程。如果有多个线程并发执行获取操作，则无法保证线程间的获取顺序。

参数：

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 向对象内部计数器中获取的数值，默认值为 1。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果当前计数器小于要求的数值，则获取失败并返回 `false`；成功获取值时返回 `true`。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 参数 `amount` 为负数，或大于初始值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

var semaphore = Semaphore(1) // 创建一个计数器初始值为 1 的信号量

main(): Unit {
    println("初始信号量计数器值: ${semaphore.count}")

    // 尝试获取信号量，应该成功
    let result1 = semaphore.tryAcquire()
    println("第一次尝试获取信号量结果: ${result1}, 计数器值: ${semaphore.count}")

    // 再次尝试获取信号量，应该失败
    let result2 = semaphore.tryAcquire()
    println("第二次尝试获取信号量结果: ${result2}, 计数器值: ${semaphore.count}")

    // 释放信号量
    semaphore.release()
    println("释放信号量后计数器值: ${semaphore.count}")

    // 再次尝试获取信号量，应该成功
    let result3 = semaphore.tryAcquire()
    println("第三次尝试获取信号量结果: ${result3}, 计数器值: ${semaphore.count}")
}
```

运行结果：

```text
初始信号量计数器值: 1
第一次尝试获取信号量结果: true, 计数器值: 0
第二次尝试获取信号量结果: false, 计数器值: 0
释放信号量后计数器值: 1
第三次尝试获取信号量结果: true, 计数器值: 0
```

## class SyncCounter

```cangjie
public class SyncCounter {
    public init(count: Int64)
}
```

功能：提供倒数计数器功能。

线程可以等待计数器变为零。

### prop count

```cangjie
public prop count: Int64
```

功能：获取计数器的当前值。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    // 创建一个初始值为10的SyncCounter
    let counter = SyncCounter(10)
    println("初始计数: ${counter.count}")

    // 减少计数器
    counter.dec()
    println("减少后的计数: ${counter.count}")

    return 0
}
```

运行结果：

```text
初始计数: 10
减少后的计数: 9
```

### init(Int64)

```cangjie
public init(count: Int64)
```

功能：创建倒数计数器。

参数：

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 倒数计数器的初始值。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果参数 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) 为负数。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    // 创建一个初始值为5的SyncCounter
    let counter = SyncCounter(5)
    println("创建SyncCounter，初始计数: ${counter.count}")
    return 0
}
```

运行结果：

```text
创建SyncCounter，初始计数: 5
```

### func dec()

```cangjie
public func dec(): Unit
```

功能：计数器减一。

如果计数器变为零，那么唤醒所有等待的线程；如果计数器已经为零，那么数值保持不变。

示例：

<!-- verify -->
```cangjie
import std.sync.*
import std.time.*

main(): Int64 {
    // 创建一个初始值为2的SyncCounter
    let counter = SyncCounter(2)
    println("初始计数: ${counter.count}")

    // 创建一个线程来减少计数器
    let future = spawn {
        sleep(100 * Duration.millisecond) // 等待100毫秒
        counter.dec()
        println("第一次减少，当前计数: ${counter.count}")

        sleep(100 * Duration.millisecond) // 再等待100毫秒
        counter.dec()
        println("第二次减少，当前计数: ${counter.count}")
        return 0
    }

    // 主线程等待计数器变为零
    println("等待计数器变为零...")
    counter.waitUntilZero()
    println("计数器已变为零！")

    // 等待子线程完成
    future.get()
    return 0
}
```

运行结果：

```text
初始计数: 2
等待计数器变为零...
第一次减少，当前计数: 1
第二次减少，当前计数: 0
计数器已变为零！
```

### func waitUntilZero(Duration)

```cangjie
public func waitUntilZero(timeout!: Duration = Duration.Max): Unit
```

功能：当前线程等待直到计数器变为零，或等待时间超过 `timeout`。

参数：

- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 阻塞时等待的最大时长，其默认值为 [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)。

示例：

<!-- verify -->
```cangjie
import std.sync.*
import std.time.*

main(): Int64 {
    // 创建一个初始值为2的SyncCounter
    let counter = SyncCounter(2)
    println("初始计数: ${counter.count}")

    // 创建一个线程来减少计数器
    let future = spawn {
        sleep(100 * Duration.millisecond) // 等待100毫秒
        counter.dec()
        println("第一次减少，当前计数: ${counter.count}")

        sleep(100 * Duration.millisecond) // 再等待100毫秒
        counter.dec()
        println("第二次减少，当前计数: ${counter.count}")
        return 0
    }

    // 主线程等待计数器变为零
    println("等待计数器变为零...")
    counter.waitUntilZero()
    println("计数器已变为零！")

    // 等待子线程完成
    future.get()
    return 0
}
```

运行结果：

```text
初始计数: 2
等待计数器变为零...
第一次减少，当前计数: 1
第二次减少，当前计数: 0
计数器已变为零！
```

## class Timer

```cangjie
public class Timer <: Equatable<Timer> & Hashable {}
```

功能：提供定时器功能。

用于在指定时间点或指定时间间隔后，执行指定任务一次或多次。

> **注意：**
>
> - [Timer](sync_package_classes.md#class-timer) 隐式包含了 `spawn` 操作，即，每个 [Timer](sync_package_classes.md#class-timer) 会创建一个线程用于执行该 [Timer](sync_package_classes.md#class-timer) 关联的 Task。
> - 每个 [Timer](sync_package_classes.md#class-timer) 只能在初始化时绑定一个 Task，初始化完成后，无法重置关联的 Task。
> - 只有关联 Task 执行完毕，或 使用 `cancel` 接口主动取消 [Timer](sync_package_classes.md#class-timer)，[Timer](sync_package_classes.md#class-timer) 的生命周期才会结束，之后才能被 [GC](../../runtime/runtime_package_api/runtime_package_funcs.md#func-gcbool) 回收。换句话说，在 [Timer](sync_package_classes.md#class-timer) 关联的 Task 执行完毕或 [Timer](sync_package_classes.md#class-timer) 被主动取消前，[Timer](sync_package_classes.md#class-timer) 实例均不会被 [GC](../../runtime/runtime_package_api/runtime_package_funcs.md#func-gcbool) 回收，从而确保关联 Task 可以被正常执行。
> - 系统繁忙时，Task 的触发时间可能会被影响。[Timer](sync_package_classes.md#class-timer) 不保证 Task 的触发时间一定准时。[Timer](sync_package_classes.md#class-timer) 保证 Task 的触发时间小于等于当前时间。
> - [Timer](sync_package_classes.md#class-timer) 不会主动捕获关联 Task 抛出的异常。只要 Task 有未被捕获的异常，[Timer](sync_package_classes.md#class-timer) 就会失效。
> - [Timer](sync_package_classes.md#class-timer) 通常按使用方式分为 一次性任务定时器 和 重复性任务定时器两种，一次性任务定时器 Task 只会执行一次，重复性任务定时器 Task 会按指定周期执行, 直到使用 `cancel` 接口主动取消 或者 达到 [Timer](sync_package_classes.md#class-timer) 创建时指定的结束条件。

父类型：

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[Timer](#class-timer)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### static func after(Duration, ()->Option\<Duration>)

```cangjie
public static func after(delay: Duration, task: () -> Option<Duration>): Timer
```

功能：初始化一个 [Timer](sync_package_classes.md#class-timer)，关联的 Task 被调度执行的次数取决于它的返回值。如果定时器第一次触发的时间点小于当前时间，关联的 Task 会立刻被调度执行。如果关联 Task 的返回值为 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).None，该 [Timer](sync_package_classes.md#class-timer) 将会失效，并停止调度关联 Task。如果关联 Task 的返回值为 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).Some(v) 且 `v` 大于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero)，下次运行前的最小时间间隔将被设置为 v。否则，关联 Task 会立刻再次被调度执行。

参数：

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 从现在开始到关联 Task 首次被调度执行的时间间隔
- task: () ->[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)> - 该 [Timer](sync_package_classes.md#class-timer) 调度执行的 Task

返回值：

- [Timer](sync_package_classes.md#class-timer) - 一个 [Timer](sync_package_classes.md#class-timer) 实例

示例：

<!-- run -->
```cangjie
import std.sync.*
import std.time.*

main(): Int64 {
    let startTime = MonoTime.now()
    println("开始创建定时器...")

    // 使用 Timer.after 创建一个定时器，首次延迟100毫秒执行
    // 任务返回 Some(200ms) 表示每隔200毫秒重复执行
    let timer = Timer.after(
        100 * Duration.millisecond,
        {
            =>
                let elapsed = MonoTime.now() - startTime
                println("定时器触发，耗时: ${elapsed}")
                // 返回 Some(200ms) 表示200毫秒后再次执行
                return Option.Some(200 * Duration.millisecond)
        }
    )

    // 等待1秒让定时器执行几次
    sleep(Duration.second)

    // 取消定时器
    timer.cancel()
    println("定时器已取消")

    return 0
}
```

运行结果：

```text
开始创建定时器...
定时器触发，耗时: 100ms447us651ns
定时器触发，耗时: 302ms92us694ns
定时器触发，耗时: 503ms681us331ns
定时器触发，耗时: 707ms981us827ns
定时器触发，耗时: 911ms38us917ns
定时器已取消
```

### static func once(Duration, ()->Unit)

```cangjie
public static func once(delay: Duration, task: ()->Unit): Timer
```

功能：设置并启动一次性定时任务，返回控制这个任务的 [Timer](sync_package_classes.md#class-timer) 对象实例。

参数：

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 从现在开始到 Task 被执行的时间间隔。取值范围 [[Duration.Min](../../core/core_package_api/core_package_structs.md#static-const-min), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]，小于或等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时 Task 将立即被执行。
- task: ()->Unit - 待定时执行的任务。

返回值：

- [Timer](sync_package_classes.md#class-timer) - 生成的对象实例。

示例：

<!-- run -->

```cangjie
import std.time.MonoTime
import std.sync.Timer

main() {
    let start = MonoTime.now()
    Timer.once(Duration.second, {
        => println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 2)
    0
}
```

可能的运行结果：

```text
Tick at: 1s2ms74us551ns
```

### static func repeat(Duration, Duration, ()->Unit, CatchupStyle)

```cangjie
public static func repeat(delay: Duration, interval: Duration, task: ()->Unit, style!: CatchupStyle = Burst): Timer
```

功能：设置并启动重复性定时任务，返回控制这个任务的 [Timer](sync_package_classes.md#class-timer) 对象实例。

参数：

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 从现在开始到 Task 被执行的时间间隔。取值范围 [[Duration.Min](../../core/core_package_api/core_package_structs.md#static-const-min), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]，小于或等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时 Task 将立即被执行。
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 两次 Task 之间的时间间隔。取值范围 ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]。
- task: ()->Unit - 待定时执行的任务。
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - 追平策略，默认 Burst。当 Task 执行时间过长时，后续任务执行时间点可能发生延迟，不同的追平策略适用于不同的场景，详见 [CatchupStyle](sync_package_enums.md#enum-catchupstyle) 说明。

返回值：

- [Timer](sync_package_classes.md#class-timer) - 生成的对象实例。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `interval` 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时，抛出异常。

示例：

<!-- run -->

```cangjie
import std.sync.Timer
import std.time.MonoTime

main() {
    let start = MonoTime.now()
    let timer = Timer.repeat(Duration.second, Duration.second, {
        => println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 5)
    timer.cancel()
    0
}
```

可能的运行结果：

```text
Tick at: 1s2ms72us188ns
Tick at: 2s4ms185us160ns
Tick at: 3s6ms275us464ns
Tick at: 4s8ms18us399ns
```

### static func repeatDuring(Duration, Duration, Duration, ()->Unit, CatchupStyle)

```cangjie
public static func repeatDuring(period: Duration, delay: Duration, interval: Duration, task: () -> Unit, style!: CatchupStyle = Burst): Timer
```

功能：设置并启动重复性定时任务，指定重复周期的最大持续时间，返回控制这个任务的 [Timer](sync_package_classes.md#class-timer) 对象实例。

参数：

- period: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 重复周期的最大持续时间，从 delay 之后开始计时。取值范围 ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]。
- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 从现在开始到 Task 被执行的时间间隔。取值范围 [Duration.Min, [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]，小于或等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero)时 Task 将立即被执行。
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 两次 Task 之间的时间间隔。取值范围 ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]。
- task: ()->Unit - 待定时执行的任务。
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - 追平策略，默认 Burst。当 Task 执行时间过长时，后续任务执行时间点可能发生延迟，不同的追平策略适用于不同的场景，详见 [CatchupStyle](sync_package_enums.md#enum-catchupstyle) 说明。

返回值：

- [Timer](sync_package_classes.md#class-timer) - 生成的对象实例。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception): 当 period 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 或 interval 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时，抛出异常。

示例：

<!-- run -->

```cangjie
import std.sync.Timer
import std.time.MonoTime

main() {
    let start = MonoTime.now()
    Timer.repeatDuring(Duration.second * 5, Duration.second, Duration.second, {
        => println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 7)
    0
}
```

可能的运行结果：

```text
Tick at: 1s2ms372us626ns
Tick at: 2s4ms714us879ns
Tick at: 3s6ms769us623ns
Tick at: 4s8ms780us235ns
Tick at: 5s660us104ns
Tick at: 6s3ms257us508ns
```

### static func repeatTimes(Int64, Duration, Duration, ()->Unit, CatchupStyle)

```cangjie
public static func repeatTimes(count: Int64, delay: Duration, interval: Duration, task: () -> Unit, style!: CatchupStyle = Burst): Timer
```

功能：设置并启动重复性定时任务，指定 Task 最大执行次数，返回控制这个任务的 [Timer](sync_package_classes.md#class-timer) 对象实例。

参数：

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Task 最大执行次数。取值范围 (0, [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).Max]。
- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 从现在开始到 Task 被执行的时间间隔。取值范围 [Duration.Min, [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]，小于或等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时 Task 将立即被执行。
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 两次 Task 之间的时间间隔。取值范围 ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]。
- task: ()->Unit - 待定时执行的任务。
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - 追平策略，默认 Burst。当 Task 执行时间过长时，后续任务执行时间点可能发生延迟，不同的追平策略适用于不同的场景，详见 [CatchupStyle](sync_package_enums.md#enum-catchupstyle) 说明。

返回值：

- [Timer](sync_package_classes.md#class-timer) - 生成的对象实例。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) <= 0 或 interval 小于等于 [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero) 时，抛出异常。

示例：

<!-- run -->

```cangjie
import std.sync.Timer
import std.time.MonoTime

main() {
    let start = MonoTime.now()
    Timer.repeatTimes(3, Duration.second, Duration.second, {
        => println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 4)
    0
}
```

可能的运行结果：

```text
Tick at: 1s2ms855us251ns
Tick at: 2s5ms390us18ns
Tick at: 3s7ms935us552ns
```

### func cancel()

```cangjie
public func cancel(): Unit
```

功能：取消该 [Timer](sync_package_classes.md#class-timer)，关联 Task 将不再被调度执行。

如果调用该函数时关联 Task 正在执行，不会打断当前运行。该函数不会阻塞当前线程。调用该函数多次等同于只调用一次。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    println("创建一个3秒后执行的定时器...")

    // 创建一个3秒后执行的定时器
    let timer = Timer.once(3 * Duration.second, {
        => println("定时器任务执行了！这不应该发生，因为我们会取消它。")
    })

    println("定时器已创建，将在3秒后执行")
    println("等待1秒后取消定时器...")

    // 等待1秒
    sleep(1 * Duration.second)

    // 取消定时器
    timer.cancel()
    println("定时器已取消")

    println("再等待3秒以验证定时器确实被取消了...")
    sleep(3 * Duration.second)
    println("程序结束，定时器任务没有执行。")

    return 0
}
```

运行结果：

```text
创建一个3秒后执行的定时器...
定时器已创建，将在3秒后执行
等待1秒后取消定时器...
定时器已取消
再等待3秒以验证定时器确实被取消了...
程序结束，定时器任务没有执行。
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 [Timer](sync_package_classes.md#class-timer) 对象的哈希值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 对象的哈希值。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    // 创建一个定时器
    let timer = Timer.once(Duration.second, {=>})

    // 获取哈希值
    let hash = timer.hashCode()

    println("timer 的哈希值: ${hash}")

    // 取消定时器
    timer.cancel()

    return 0
}
```

运行结果：

```text
timer 的哈希值: 1
```

### operator func !=(Timer)

```cangjie
public operator func !=(other: Timer): Bool
```

功能：判断当前 [Timer](sync_package_classes.md#class-timer) 与另一个指定的 [Timer](sync_package_classes.md#class-timer) 是否不是同一个实例。

参数：

- other: [Timer](#class-timer) - 待比较的另一个 [Timer](#class-timer) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 若两个 [Timer](sync_package_classes.md#class-timer) 不是同一个实例，则返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    // 创建两个不同的定时器
    let timer1 = Timer.once(Duration.second, {=>})
    let timer2 = Timer.once(Duration.second, {=>})

    // 检查它们是否不是同一个实例
    if (timer1 != timer2) {
        println("timer1 和 timer2 不是同一个实例")
    } else {
        println("timer1 和 timer2 是同一个实例")
    }

    // 创建一个指向 timer1 的引用
    let timer3 = timer1

    // 检查 timer1 和 timer3 是否不是同一个实例
    if (timer1 != timer3) {
        println("timer1 和 timer3 不是同一个实例")
    } else {
        println("timer1 和 timer3 是同一个实例")
    }

    // 取消定时器
    timer1.cancel()
    timer2.cancel()

    return 0
}
```

运行结果：

```text
timer1 和 timer2 不是同一个实例
timer1 和 timer3 是同一个实例
```

### operator func ==(Timer)

```cangjie
public operator func ==(other: Timer): Bool
```

功能：判断当前 [Timer](sync_package_classes.md#class-timer) 与另一个指定的 [Timer](sync_package_classes.md#class-timer) 是否是同一个实例。

参数：

- other: [Timer](#class-timer) - 待比较的另一个 [Timer](#class-timer) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 若两个 [Timer](sync_package_classes.md#class-timer) 是同一个实例，则返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.sync.*

main(): Int64 {
    // 创建两个不同的定时器
    let timer1 = Timer.once(Duration.second, {=>})
    let timer2 = Timer.once(Duration.second, {=>})

    // 检查它们是否是同一个实例
    if (timer1 == timer2) {
        println("timer1 和 timer2 是同一个实例")
    } else {
        println("timer1 和 timer2 不是同一个实例")
    }

    // 创建一个指向 timer1 的引用
    let timer3 = timer1

    // 检查 timer1 和 timer3 是否是同一个实例
    if (timer1 == timer3) {
        println("timer1 和 timer3 是同一个实例")
    } else {
        println("timer1 和 timer3 不是同一个实例")
    }

    // 取消定时器
    timer1.cancel()
    timer2.cancel()

    return 0
}
```

运行结果：

```text
timer1 和 timer2 不是同一个实例
timer1 和 timer3 是同一个实例
```
