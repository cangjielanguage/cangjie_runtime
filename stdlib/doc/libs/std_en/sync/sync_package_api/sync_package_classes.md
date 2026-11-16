# Classes

## class AtomicBool

```cangjie
public class AtomicBool {
    public init(val: Bool)
}
```

Function: Provides atomic operation functions for the [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type.

### init(Bool)

```cangjie
public init(val: Bool)
```

Function: Constructs an instance of the atomic type [AtomicBool](sync_package_classes.md#class-atomicbool) encapsulating a [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The initial value of the atomic type.

### func compareAndSwap(Bool, Bool)

```cangjie
public func compareAndSwap(old: Bool, new: Bool): Bool
```

Function: CAS (Compare and Swap) operation using the [default memory ordering](sync_package_constants_vars.md#let-defaultmemoryorder-deprecated).

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

Parameters:

- old: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to compare with the current atomic type.
- new: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type if the comparison is equal.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the compare-and-swap succeeds, otherwise returns `false`.

### func compareAndSwap(Bool, Bool, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Bool, new: Bool, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using the memory ordering specified by `successOrder` on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(Bool, Bool)](#func-compareandswapbool-bool) instead.

Parameters:

- old: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to compare with the current atomic type.
- new: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type if the comparison is equal.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read-modify-write" operation if the CAS succeeds.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read" operation if the CAS fails.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the compare-and-swap succeeds, otherwise returns `false`.

### func load()

```cangjie
public func load(): Bool
```

Function: Read operation using default memory ordering to read the value of the atomic type.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The current value of the atomic type.

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Bool
```

Function: Read operation using the memory ordering specified by parameter `memoryOrder` to read the value of the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [load()](#func-load) instead.

Parameters:

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The current value of the atomic type.

### func store(Bool)

```cangjie
public func store(val: Bool): Unit
```

Function: Write operation using default memory ordering to write the value specified by parameter `val` to the atomic type.

Parameters:

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type.

### func store(Bool, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Bool, memoryOrder!: MemoryOrder): Unit
```

Function: Write operation using the memory ordering specified by parameter `memoryOrder` to write the value specified by parameter `val` to the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [store(Bool)](#func-storebool) instead.

Parameters:

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

### func swap(Bool)

```cangjie
public func swap(val: Bool): Bool
```

Function: Swap operation using default memory ordering to write the value specified by parameter `val` to the atomic type and return the value before the write.

Parameters:

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value before the write.

### func swap(Bool, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Bool, memoryOrder!: MemoryOrder): Bool
```

Function: Swap operation using the memory ordering specified by parameter `memoryOrder` to write the value specified by parameter `val` to the atomic type and return the value before the write.

> **Note:**
>
> This will be deprecated in future versions. Use [swap(Bool)](#func-swapbool) instead.

Parameters:

- val: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The value before the write.

## class AtomicInt16

```cangjie
public class AtomicInt16 {
    public init(val: Int16)
}
```

Function: Provides atomic operation functions for the [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) type.

### init(Int16)

```cangjie
public init(val: Int16)
```

Function: Constructs an instance of the atomic type [AtomicInt16](sync_package_classes.md#class-atomicint16) encapsulating a [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The initial value of the atomic type.

### func compareAndSwap(Int16, Int16)

```cangjie
public func compareAndSwap(old: Int16, new: Int16): Bool
```

Function: CAS operation using default memory ordering.

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

Parameters:

- old: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to compare with the current atomic type.
- new: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to write to the atomic type if the comparison is equal.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the compare-and-swap succeeds, otherwise returns `false`.

### func compareAndSwap(Int16, Int16, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int16, new: Int16, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using the memory ordering specified by `successOrder` on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(Int16, Int16)](#func-compareandswapint16-int16) instead.

Parameters:

- old: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to compare with the current atomic type.
- new: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to write to the atomic type if the comparison is equal.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read-modify-write" operation if the CAS succeeds.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read" operation if the CAS fails.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the compare-and-swap succeeds, otherwise returns `false`.

### func fetchAdd(Int16)

```cangjie
public func fetchAdd(val: Int16): Int16
```

Function: Using default memory ordering, performs an addition operation between the atomic type's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the addition.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to add to the atomic type.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the addition.

### func fetchAdd(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int16, memoryOrder!: MemoryOrder): Int16
```

Function: Using the memory ordering specified by parameter `memoryOrder`, performs an addition operation between the atomic type's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the addition.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAdd(Int16)](#func-fetchaddint16) instead.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to add to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the addition.

### func fetchAnd(Int16)

```cangjie
public func fetchAnd(val: Int16): Int16
```

Function: Using default memory ordering, performs a bitwise AND operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bitwise AND with the atomic type.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the operation.

### func fetchAnd(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int16, memoryOrder!: MemoryOrder): Int16
```

Function: Using the memory ordering specified by parameter `memoryOrder`, performs a bitwise AND operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAnd(Int16)](#func-fetchandint16) instead.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bitwise AND with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the operation.

### func fetchOr(Int16)

```cangjie
public func fetchOr(val: Int16): Int16
```

Function: Using default memory ordering, performs a bitwise OR operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bitwise OR with the atomic type.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the operation.

### func fetchOr(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int16, memoryOrder!: MemoryOrder): Int16
```

Function: Using the memory ordering specified by parameter `memoryOrder`, performs a bitwise OR operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchOr(Int16)](#func-fetchorint16) instead.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bitwise OR with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the operation.

### func fetchSub(Int16)

```cangjie
public func fetchSub(val: Int16): Int16
```

Function: Using default memory ordering, performs a subtraction operation with the atomic type's value as the minuend and parameter `val` as the subtrahend, writes the result to the current atomic type instance, and returns the value before the subtraction.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to subtract from the atomic type.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the subtraction.

### func fetchSub(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int16, memoryOrder!: MemoryOrder): Int16
```

Function: Using the memory ordering specified by parameter `memoryOrder`, performs a subtraction operation with the atomic type's value as the minuend and parameter `val` as the subtrahend, writes the result to the current atomic type instance, and returns the value before the subtraction.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchSub(Int16)](#func-fetchsubint16) instead.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to subtract from the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the current operation.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the subtraction.

### func fetchXor(Int16)

```cangjie
public func fetchXor(val: Int16): Int16
```

Function: Using default memory ordering, performs a bitwise XOR operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bitwise XOR with the atomic type.

Returns:

- [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value before the operation.

### func fetchXor(Int16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int16, memoryOrder!: MemoryOrder): Int16
```

Function: Using the memory ordering specified by parameter `memoryOrder`, performs a bitwise XOR operation between the current atomic type instance's value and parameter `val`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchXor(Int16)](#func-fetchxorint16) instead.

Parameters:

- val: [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) - The value to perform bit## class AtomicInt32

```cangjie
public class AtomicInt32 {
    public init(val: Int32)
}
```

Function: Provides atomic operation functions for the [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) data type.

### init(Int32)

```cangjie
public init(val: Int32)
```

Function: Constructs an instance of the atomic type [AtomicInt32](sync_package_classes.md#class-atomicint32) encapsulating an [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The initial value of the atomic type.

### func compareAndSwap(Int32, Int32)

```cangjie
public func compareAndSwap(old: Int32, new: Int32): Bool
```

Function: CAS (Compare-And-Swap) operation using default memory ordering.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to compare with the current atomic type.
- new: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(Int32, Int32, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int32, new: Int32, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(Int32, Int32)](#func-compareandswapint32-int32) instead.

Parameters:

- old: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to compare with the current atomic type.
- new: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for "read-modify-write" operations on CAS success.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for "read" operations on CAS failure.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func fetchAdd(Int32)

```cangjie
public func fetchAdd(val: Int32): Int32
```

Function: Performs an atomic addition using default memory ordering. Adds the value `val` to the atomic type, stores the result, and returns the value before the addition.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to add to the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the addition.

### func fetchAdd(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Performs an atomic addition using specified `memoryOrder`. Adds the value `val` to the atomic type, stores the result, and returns the value before the addition.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAdd(Int32)](#func-fetchaddint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to add to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the addition.

### func fetchAnd(Int32)

```cangjie
public func fetchAnd(val: Int32): Int32
```

Function: Performs an atomic AND operation using default memory ordering. ANDs the value `val` with the atomic type, stores the result, and returns the value before the operation.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to AND with the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchAnd(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Performs an atomic AND operation using specified `memoryOrder`. ANDs the value `val` with the atomic type, stores the result, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAnd(Int32)](#func-fetchandint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to AND with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchOr(Int32)

```cangjie
public func fetchOr(val: Int32): Int32
```

Function: Performs an atomic OR operation using default memory ordering. ORs the value `val` with the atomic type, stores the result, and returns the value before the operation.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to OR with the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchOr(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Performs an atomic OR operation using specified `memoryOrder`. ORs the value `val` with the atomic type, stores the result, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchOr(Int32)](#func-fetchorint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to OR with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchSub(Int32)

```cangjie
public func fetchSub(val: Int32): Int32
```

Function: Performs an atomic subtraction using default memory ordering. Subtracts the value `val` from the atomic type, stores the result, and returns the value before the operation.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to subtract from the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchSub(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Performs an atomic subtraction using specified `memoryOrder`. Subtracts the value `val` from the atomic type, stores the result, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchSub(Int32)](#func-fetchsubint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to subtract from the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchXor(Int32)

```cangjie
public func fetchXor(val: Int32): Int32
```

Function: Performs an atomic XOR operation using default memory ordering. XORs the value `val` with the atomic type, stores the result, and returns the value before the operation.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to XOR with the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func fetchXor(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Performs an atomic XOR operation using specified `memoryOrder`. XORs the value `val` with the atomic type, stores the result, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchXor(Int32)](#func-fetchxorint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to XOR with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the operation.

### func load()

```cangjie
public func load(): Int32
```

Function: Atomic load operation using default memory ordering. Reads the value of the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The current value of the atomic type.

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Int32
```

Function: Atomic load operation using specified `memoryOrder`. Reads the value of the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [load()](#func-load-2) instead.

Parameters:

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The current value of the atomic type.

### func store(Int32)

```cangjie
public func store(val: Int32): Unit
```

Function: Atomic store operation using default memory ordering. Writes the value `val` to the atomic type.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type.

### func store(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Int32, memoryOrder!: MemoryOrder): Unit
```

Function: Atomic store operation using specified `memoryOrder`. Writes the value `val` to the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [store(Int32)](#func-storeint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

### func swap(Int32)

```cangjie
public func swap(val: Int32): Int32
```

Function: Atomic swap operation using default memory ordering. Writes the value `val` to the atomic type and returns the previous value.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the swap.

### func swap(Int32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Int32, memoryOrder!: MemoryOrder): Int32
```

Function: Atomic swap operation using specified `memoryOrder`. Writes the value `val` to the atomic type and returns the previous value.

> **Note:**
>
> This will be deprecated in future versions. Use [swap(Int32)](#func-swapint32) instead.

Parameters:

- val: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the operation.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The value before the swap.

## class AtomicInt64

```cangjie
public class AtomicInt64 {
    public init(val: Int64)
}
```

Function: Provides atomic operation functions for the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) data type.

### init(Int64)

```cangjie
public init(val: Int64)
```

Function: Constructs an instance of the atomic type [AtomicInt64](sync_package_classes.md#class-atomicint64) encapsulating an [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The initial value of the atomic type.

### func compareAndSwap(Int64, Int64)

```cangjie
public func compareAndSwap(old: Int64, new: Int64): Bool
```

Function: CAS (Compare-And-Swap) operation using default memory ordering.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to compare with the current atomic type.
- new: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(Int64, Int64, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Int64, new: Int64, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(Int64, Int64)](#func-compareandswapint64-int64) instead.

Parameters:

- old: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to compare with the current atomic type.
- new: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for "read-modify-write" operations on CAS success.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for "read" operations on CAS failure.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.### func fetchAdd(Int64)

```cangjie
public func fetchAdd(val: Int64): Int64
```

Function: Performs an atomic addition operation using the default memory ordering, adds the parameter `val` to the atomic type's value, writes the result back to the current atomic type instance, and returns the value before the addition.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be added to the atomic type.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the addition operation.

### func fetchAdd(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: Int64, memoryOrder!: MemoryOrder): Int64
```

Function: Performs an atomic addition operation using the memory ordering specified by the parameter `memoryOrder`, adds the parameter `val` to the atomic type's value, writes the result back to the current atomic type instance, and returns the value before the addition.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAdd(Int64)](#func-fetchaddint64) instead.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be added to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the addition operation.

### func fetchAnd(Int64)

```cangjie
public func fetchAnd(val: Int64): Int64
```

Function: Performs an atomic AND operation using the default memory ordering, applies the parameter `val` to the current atomic type's value, writes the result back to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be ANDed with the atomic type.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the AND operation.

### func fetchAnd(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: Int64, memoryOrder!: MemoryOrder): Int64
```

Function: Performs an atomic AND operation using the memory ordering specified by the parameter `memoryOrder`, applies the parameter `val` to the current atomic type's value, writes the result back to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAnd(Int64)](#func-fetchandint64) instead.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be ANDed with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the AND operation.

### func fetchOr(Int64)

```cangjie
public func fetchOr(val: Int64): Int64
```

Function: Performs an atomic OR operation using the default memory ordering, applies the parameter `val` to the current atomic type's value, writes the result back to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be ORed with the atomic type.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the OR operation.

### func fetchOr(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: Int64, memoryOrder!: MemoryOrder): Int64
```

Function: Performs an atomic OR operation using the memory ordering specified by the parameter `memoryOrder`, applies the parameter `val` to the current atomic type's value, writes the result back to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchOr(Int64)](#func-fetchorint64) instead.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be ORed with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the OR operation.

### func fetchSub(Int64)

```cangjie
public func fetchSub(val: Int64): Int64
```

Function: Performs an atomic subtraction operation using the default memory ordering, subtracts the parameter `val` from the atomic type's value, writes the result back to the current atomic type instance, and returns the value before the subtraction.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be subtracted from the atomic type.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the subtraction operation.

### func fetchSub(Int64, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: Int64, memoryOrder!: MemoryOrder): Int64
```

Function: Performs an atomic subtraction operation using the memory ordering specified by the parameter `memoryOrder`, subtracts the parameter `val` from the atomic type's value, writes the result back to the current atomic type instance, and returns the value before the subtraction.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchSub(Int64)](#func-fetchsubint64) instead.

Parameters:

- val: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to be subtracted from the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value before the subtraction operation.

## class AtomicOptionReference\<T> where T <: Object

```cangjie
public class AtomicOptionReference<T> where T <: Object {
    public init()
    public init(val: Option<T>)
}
```

Function: Provides atomic operation functions for reference types.

The reference type must be a subclass of [Object](../../core/core_package_api/core_package_classes.md#class-object).

### init()

```cangjie
public init()
```

Function: Constructs an empty [AtomicOptionReference](sync_package_classes.md#class-atomicoptionreferencet-where-t--object) instance.

### init(Option\<T>)

```cangjie
public init(val: Option<T>)
```

Function: Constructs an atomic type [AtomicOptionReference](sync_package_classes.md#class-atomicoptionreferencet-where-t--object) instance encapsulating the [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The initial value of the atomic type.

### func compareAndSwap(Option\<T>, Option\<T>)

```cangjie
public func compareAndSwap(old: Option<T>, new: Option<T>): Bool
```

Function: CAS (Compare-And-Swap) operation using default memory ordering.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to compare with the current atomic type.
- new: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(Option\<T>, Option\<T>, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: Option<T>, new: Option<T>, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(Option\<T>, Option\<T>)](#func-compareandswapoptiont-optiont) instead.

Parameters:

- old: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to compare with the current atomic type.
- new: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read-modify-write" operation on successful CAS.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read" operation on failed CAS.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func load()

```cangjie
public func load(): Option<T>
```

Function: Read operation using default memory ordering to retrieve the atomic type's value.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The current value of the atomic type.

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): Option<T>
```

Function: Read operation using the memory ordering specified by parameter `memoryOrder` to retrieve the atomic type's value.

> **Note:**
>
> This will be deprecated in future versions. Use [load()](#func-load-5) instead.

Parameters:

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The current value of the atomic type.

### func store(Option\<T>)

```cangjie
public func store(val: Option<T>): Unit
```

Function: Write operation using default memory ordering to store the value specified by parameter `val` into the atomic type.

Parameters:

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type.

### func store(Option\<T>, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: Option<T>, memoryOrder!: MemoryOrder): Unit
```

Function: Write operation using the memory ordering specified by parameter `memoryOrder` to store the value specified by parameter `val` into the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [store(Option\<T>)](#func-storeoptiont) instead.

Parameters:

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

### func swap(Option\<T>)

```cangjie
public func swap(val: Option<T>): Option<T>
```

Function: Swap operation using default memory ordering to store the value specified by parameter `val` into the atomic type and return the previous value.

Parameters:

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The previous value before writing.

### func swap(Option\<T>, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: Option<T>, memoryOrder!: MemoryOrder): Option<T>
```

Function: Swap operation using the memory ordering specified by parameter `memoryOrder` to store the value specified by parameter `val` into the atomic type and return the previous value.

> **Note:**
>
> This will be deprecated in future versions. Use [swap(Option\<T>)](#func-swapoptiont) instead.

Parameters:

- val: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The previous value before writing.

## class AtomicReference\<T> where T <: Object

```cangjie
public class AtomicReference<T> where T <: Object {
    public init(val: T)
}
```

Function: Provides atomic operation functions for reference types.

The reference type must be a subclass of [Object](../../core/core_package_api/core_package_classes.md#class-object).

### init(T)

```cangjie
public init(val: T)
```

Function: Constructs an atomic type [AtomicReference](sync_package_classes.md#class-atomicreferencet-where-t--object) instance encapsulating the `T` data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: T - The initial value of the atomic type.

### func compareAndSwap(T, T)

```cangjie
public func compareAndSwap(old: T, new: T): Bool
```

Function: CAS operation using default memory ordering.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: T - The value to compare with the current atomic type.
- new: T - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(T, T, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: T, new: T, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(T, T)](#func-compareandswapt-t) instead.

Parameters:

- old: T - The value to compare with the current atomic type.
- new: T - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read-modify-write" operation on successful CAS.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read" operation on failed CAS.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func load()

```cangjie
public func load(): T
```

Function: Read operation using default memory ordering to retrieve the atomic type's value.

Returns:

- T - The current value of the atomic type.

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): T
```

Function: Read operation using the memory ordering specified by parameter `memoryOrder` to retrieve the atomic type's value.

> **Note:**
>
> This will be deprecated in future versions. Use [load()](#func-load-6) instead.

Parameters:

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- T - The current value of the atomic type.

### func store(T)

```cangjie
public func store(val: T): Unit
```

Function: Write operation using default memory ordering to store the value specified by parameter `val` into the atomic type.

Parameters:

- val: T - The value to write to the atomic type.

### func store(T, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: T, memoryOrder!: MemoryOrder): Unit
```

Function: Write operation using the memory ordering specified by parameter `memoryOrder` to store the value specified by parameter `val` into the atomic type.

> **Note:**
>
> This will be deprecated in future versions. Use [store(T)](#func-storet) instead.

Parameters:

- val: T - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

### func swap(T)

```cangjie
public func swap(val: T): T
```

Function: Swap operation using default memory ordering to store the value specified by parameter `val` into the atomic type and return the previous value.

Parameters:

- val: T - The value to write to the atomic type.

Returns:

- T - The previous value before writing.

### func swap(T, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: T, memoryOrder!: MemoryOrder): T
```

Function: Swap operation using the memory ordering specified by parameter `memoryOrder` to store the value specified by parameter `val` into the atomic type and return the previous value.

> **Note:**
>
> This will be deprecated in future versions. Use [swap(T)](#func-swapt) instead.

Parameters:

- val: T - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- T - The previous value before writing.

## class AtomicUInt16

```cangjie
public class AtomicUInt16 {
    public init(val: UInt16)
}
```

Function: Provides atomic operation functions for [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) type.

### init(UInt16)

```cangjie
public init(val: UInt16)
```

Function: Constructs an atomic type [AtomicUInt16](sync_package_classes.md#class-atomicuint16) instance encapsulating the [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The initial value of the atomic type.

### func compareAndSwap(UInt16, UInt16)

```cangjie
public func compareAndSwap(old: UInt16, new: UInt16): Bool
```

Function: CAS operation using default memory ordering.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to compare with the current atomic type.
- new: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(UInt16, UInt16, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt16, new: UInt16, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current atomic type's value with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This will be deprecated in future versions. Use [compareAndSwap(UInt16, UInt16)](#func-compareandswapuint16-uint16) instead.

Parameters:

- old: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to compare with the current atomic type.
- new: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read-modify-write" operation on successful CAS.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read" operation on failed CAS.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func fetchAdd(UInt16)

```cangjie
public func fetchAdd(val: UInt16): UInt16
```

Function: Performs an addition operation using default memory ordering between the atomic type's value and parameter `val`, stores the result in the current atomic type instance, and returns the value before the addition.

Parameters:

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to add to the atomic type.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value before the addition operation.

### func fetchAdd(UInt16, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt16, memoryOrder!: MemoryOrder): UInt16
```

Function: Performs an addition operation using the memory ordering specified by parameter `memoryOrder` between the atomic type's value and parameter `val`, stores the result in the current atomic type instance, and returns the value before the addition.

> **Note:**
>
> This will be deprecated in future versions. Use [fetchAdd(UInt16)](#func-fetchadduint16) instead.

Parameters:

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to add to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for this operation.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value before the addition operation.

### func fetchAnd(UInt16)

```cangjie
public func fetchAnd(val: UInt16): UInt16
```

Function: Performs a bitwise AND operation using default memory ordering, applies `val` to the atomic value, stores the result, and returns the value before the operation.

Parameters:

- val: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value to AND with the atomic type.

Returns:

- [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The value before the operation.

## class AtomicUInt32

```cangjie
public class AtomicUInt32 {
    public init(val: UInt32)
}
```

Function: Provides atomic operation functions for the [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) data type.

### init(UInt32)

```cangjie
public init(val: UInt32)
```

Function: Constructs an instance of the atomic type [AtomicUInt32](sync_package_classes.md#class-atomicuint32) encapsulating a [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The initial value of the atomic type.

### func compareAndSwap(UInt32, UInt32)

```cangjie
public func compareAndSwap(old: UInt32, new: UInt32): Bool
```

Function: CAS (Compare-And-Swap) operation using the default memory ordering.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

Parameters:

- old: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to compare with the current atomic type.
- new: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to write to the atomic type if the comparison succeeds.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func compareAndSwap(UInt32, UInt32, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt32, new: UInt32, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: CAS operation using `successOrder` memory ordering on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write and returns `false`.

> **Note:**
>
> This method is deprecated and will be removed in a future version. Use [compareAndSwap(UInt32, UInt32)](#func-compareandswapuint32-uint32) instead.

Parameters:

- old: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to compare with the current atomic type.
- new: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to write to the atomic type if the comparison succeeds.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read-modify-write" operation on success.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering for the "read" operation on failure.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap succeeds, otherwise `false`.

### func fetchAdd(UInt32)

```cangjie
public func fetchAdd(val: UInt32): UInt32
```

Function: Performs an atomic addition using the default memory ordering. Adds `val` to the atomic type's value, stores the result, and returns the value before the addition.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to add to the atomic type.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value before the addition.

### func fetchAdd(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

Function: Performs an atomic addition using the specified `memoryOrder`. Adds `val` to the atomic type's value, stores the result, and returns the value before the addition.

> **Note:**
>
> This method is deprecated and will be removed in a future version. Use [fetchAdd(UInt32)](#func-fetchadduint32) instead.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to add to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value before the addition.

### func fetchAnd(UInt32)

```cangjie
public func fetchAnd(val: UInt32): UInt32
```

Function: Performs an atomic AND operation using the default memory ordering. ANDs `val` with the atomic type's value, stores the result, and returns the value before the operation.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to AND with the atomic type.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value before the AND operation.

### func fetchAnd(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

Function: Performs a bitwise AND operation on the current atomic type instance's value with the parameter `val` using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the AND operation.

> **Note:**
>
> This method is deprecated and will be removed in a future version. Use [fetchAnd(UInt32)](#func-fetchanduint32) instead.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to AND with the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Value before performing the 'AND' operation

## class AtomicUInt32

```cangjie
public class AtomicUInt32 {
    public init(val: UInt32)
}
```

Function: Provides atomic operation functions for the [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) data type.

### init(UInt32)

```cangjie
public init(val: UInt32)
```

Function: Constructs an instance of the atomic type [AtomicUInt32](sync_package_classes.md#class-atomicuint32) encapsulating a [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The initial value of the atomic type.

## class AtomicUInt32

```cangjie
public class AtomicUInt32 {
    public init(val: UInt32)
}
```

Function: Provides atomic operation functions for [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) type.

### func fetchAdd(UInt32)

```cangjie
public func fetchAdd(val: UInt32): UInt32
```

Function: Performs atomic addition using default memory ordering. Adds `val` to the atomic value, stores the result, and returns the pre-operation value.

Parameters:
- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to add

Returns:
- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value before addition

### func fetchAdd(UInt32, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt32, memoryOrder!: MemoryOrder): UInt32
```

Function: Performs atomic addition using specified memory ordering.

> **Note:**
> 
> Will be deprecated in future versions. Use [fetchAdd(UInt32)](#func-fetchadduint32) instead.

Parameters:
- val: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value to add
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - Memory ordering mode

Returns:
- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The value before addition

## class AtomicUInt8

```cangjie
public class AtomicUInt8 {
    public init(val: UInt8)
}
```

Function: Provides atomic operation functions for the [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) data type.

### init(UInt8)

```cangjie
public init(val: UInt8)
```

Function: Constructs an instance of the atomic type [AtomicUInt8](sync_package_classes.md#class-atomicuint8) encapsulating a [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) data type, with its internal data initialized to the value of parameter `val`.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The initial value of the atomic type.

### func compareAndSwap(UInt8, UInt8)

```cangjie
public func compareAndSwap(old: UInt8, new: UInt8): Bool
```

Function: Performs a CAS (Compare-And-Swap) operation using the default memory ordering.

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

Parameters:

- old: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to compare with the current atomic type.
- new: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type if the comparison is successful.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap is successful, otherwise `false`.

### func compareAndSwap(UInt8, UInt8, MemoryOrder, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func compareAndSwap(old: UInt8, new: UInt8, successOrder!: MemoryOrder, failureOrder!: MemoryOrder): Bool
```

Function: Performs a CAS operation using the memory ordering specified by `successOrder` on success and `failureOrder` on failure.

Compares the current value of the atomic type with the value specified by parameter `old`. If they are equal, writes the value specified by parameter `new` and returns `true`; otherwise, does not write the value and returns `false`.

> **Note:**
>
> This method will be deprecated in future versions. Use [compareAndSwap(UInt8, UInt8)](#func-compareandswapuint8-uint8) instead.

Parameters:

- old: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to compare with the current atomic type.
- new: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type if the comparison is successful.
- successOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read-modify-write" operation on success.
- failureOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the "read" operation on failure.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the swap is successful, otherwise `false`.

### func fetchAdd(UInt8)

```cangjie
public func fetchAdd(val: UInt8): UInt8
```

Function: Performs an addition operation on the atomic type's value with parameter `val` using the default memory ordering, writes the result to the current atomic type instance, and returns the value before the addition.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to add to the atomic type.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the addition operation.

### func fetchAdd(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAdd(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs an addition operation on the atomic type's value with parameter `val` using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the addition.

> **Note:**
>
> This method will be deprecated in future versions. Use [fetchAdd(UInt8)](#func-fetchadduint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to add to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the addition operation.

### func fetchAnd(UInt8)

```cangjie
public func fetchAnd(val: UInt8): UInt8
```

Function: Performs a bitwise AND operation on the current atomic type's value with parameter `val` using the default memory ordering, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the AND operation with.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the AND operation.

### func fetchAnd(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchAnd(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a bitwise AND operation on the current atomic type's value with parameter `val` using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This method will be deprecated in future versions. Use [fetchAnd(UInt8)](#func-fetchanduint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the AND operation with.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the AND operation.

### func fetchOr(UInt8)

```cangjie
public func fetchOr(val: UInt8): UInt8
```

Function: Performs a bitwise OR operation on the current atomic type's value with parameter `val` using the default memory ordering, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the OR operation with.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the OR operation.

### func fetchOr(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchOr(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a bitwise OR operation on the current atomic type's value with parameter `val` using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This method will be deprecated in future versions. Use [fetchOr(UInt8)](#func-fetchoruint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the OR operation with.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the OR operation.

### func fetchSub(UInt8)

```cangjie
public func fetchSub(val: UInt8): UInt8
```

Function: Performs a subtraction operation using the atomic type's value as the minuend and parameter `val` as the subtrahend, using the default memory ordering, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to subtract from the atomic type.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the subtraction operation.

### func fetchSub(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchSub(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a subtraction operation using the atomic type's value as the minuend and parameter `val` as the subtrahend, using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This method will be deprecated in future versions. Use [fetchSub(UInt8)](#func-fetchsubuint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to subtract from the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the subtraction operation.

### func fetchXor(UInt8)

```cangjie
public func fetchXor(val: UInt8): UInt8
```

Function: Performs a bitwise XOR operation on the current atomic type's value with parameter `val` using the default memory ordering, writes the result to the current atomic type instance, and returns the value before the operation.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the XOR operation with.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the XOR operation.

### func fetchXor(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func fetchXor(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a bitwise XOR operation on the current atomic type's value with parameter `val` using the memory ordering specified by `memoryOrder`, writes the result to the current atomic type instance, and returns the value before the operation.

> **Note:**
>
> This method will be deprecated in future versions. Use [fetchXor(UInt8)](#func-fetchxoruint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to perform the XOR operation with.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the XOR operation.

### func load()

```cangjie
public func load(): UInt8
```

Function: Performs a read operation using the default memory ordering to read the value of the atomic type.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The current value of the atomic type.

### func load(MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func load(memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a read operation using the memory ordering specified by `memoryOrder` to read the value of the atomic type.

> **Note:**
>
> This method will be deprecated in future versions. Use [load()](#func-load-10) instead.

Parameters:

- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The current value of the atomic type.

### func store(UInt8)

```cangjie
public func store(val: UInt8): Unit
```

Function: Performs a write operation using the default memory ordering to write the value specified by parameter `val` to the atomic type.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type.

### func store(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func store(val: UInt8, memoryOrder!: MemoryOrder): Unit
```

Function: Performs a write operation using the memory ordering specified by `memoryOrder` to write the value specified by parameter `val` to the atomic type.

> **Note:**
>
> This method will be deprecated in future versions. Use [store(UInt8)](#func-storeuint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

### func swap(UInt8)

```cangjie
public func swap(val: UInt8): UInt8
```

Function: Performs a swap operation using the default memory ordering to write the value specified by parameter `val` to the atomic type and returns the value before the write.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the write.

### func swap(UInt8, MemoryOrder) <sup>(deprecated)</sup>

```cangjie
public func swap(val: UInt8, memoryOrder!: MemoryOrder): UInt8
```

Function: Performs a swap operation using the memory ordering specified by `memoryOrder` to write the value specified by parameter `val` to the atomic type and returns the value before the write.

> **Note:**
>
> This method will be deprecated in future versions. Use [swap(UInt8)](#func-swapuint8) instead.

Parameters:

- val: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value to write to the atomic type.
- memoryOrder!: [MemoryOrder <sup>(deprecated)</sup>](sync_package_enums.md#enum-memoryorder-deprecated) - The memory ordering for the operation.

Returns:

- [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - The value before the write.

## class Barrier

```cangjie
public class Barrier {
    public init(count: Int64)
}
```

Function: Provides functionality to coordinate multiple threads to reach a specific program point.

Threads that reach the program point first will block until all threads have reached the point, after which they will continue execution together.

### init(Int64)

```cangjie
public init(count: Int64)
```

Function: Creates a [Barrier](sync_package_classes.md#class-barrier) object.

Parameters:

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of threads to coordinate.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if parameter [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) is negative.

### func wait(Duration)

```cangjie
public func wait(timeout!: Duration = Duration.Max): Unit
```

Function: A thread enters the [Barrier](sync_package_classes.md#class-barrier) wait point.

If the total number of `wait` calls (i.e., the number of threads that have entered the wait point) equals the initial value, all waiting threads are awakened. If the number of `wait` calls is still less than the initial value, the current thread blocks until awakened or the wait time exceeds `timeout`. If the number of `wait` calls exceeds the initial value, the thread continues execution.

Parameters:

- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The maximum duration to block, with a default value of [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max).

## class Monitor <sup>(deprecated)</sup>

```cangjie
public class Monitor <: ReentrantMutex {
    public init()
}
```

Function: Provides functionality for threads to block and wait for signals from other threads to resume execution.

This is a synchronization mechanism using shared variables. When some threads are suspended waiting for a condition on a shared variable to be met, other threads modify the shared variable to satisfy the condition and then perform a wake-up operation. This allows the suspended threads to resume execution when awakened.

> **Note:**
>
> This class will be deprecated in future versions. Use [Condition](./sync_package_interfaces.md#interface-condition) instead.

Parent Type:

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

##### class MultiConditionMonitor <sup>(deprecated)</sup>

```cangjie
public class MultiConditionMonitor <: ReentrantMutex {
    public init()
}
```

Function: Provides the ability to bind multiple condition variables to the same mutex lock.

> **Note:**
>
> - Will be deprecated in future versions, use [Mutex](#class-mutex) instead.
> - This class should only be used when the [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) class is insufficient for implementing advanced concurrency algorithms.
> - Upon initialization, [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) has no associated condition variables.
> - Each call to `newCondition` creates a new wait queue associated with the current object and returns a [ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated) type instance as a unique identifier.

Parent Types:

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### init()

```cangjie
public init()
```

Function: Creates a [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) via the default constructor.

### func newCondition()

```cangjie
public func newCondition(): ConditionID
```

Function: Creates a [ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated) associated with this [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated), which can be used to implement "single mutex with multiple wait queues" concurrency primitives.

Returns:

- [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - A new [ConditionID <sup>(deprecated)</sup>](sync_package_structs.md#struct-conditionid-deprecated).

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex.

### func notify(ConditionID)

```cangjie
public func notify(condID: ConditionID): Unit
```

Function: Wakes up threads waiting on the specified condition variable (if any).

Parameters:

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - The condition variable.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex, or if `condID` was not created by this [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) instance via the `newCondition` function.

### func notifyAll(ConditionID)

```cangjie
public func notifyAll(condID: ConditionID): Unit
```

Function: Wakes up all threads waiting on the specified condition variable (if any).

Parameters:

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - The condition variable.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex, or if `condID` was not created by this [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) instance via the `newCondition` function.

### func wait(CConditionID, Duration)

```cangjie
public func wait(condID: ConditionID, timeout!: Duration = Duration.Max): Bool
```

Function: Suspends the current thread until the corresponding `notify` function is called.

> **Note:**
>
> The thread releases the associated mutex lock when entering the wait state and reacquires it upon being awakened.

Parameters:

- condID: [ConditionID](sync_package_structs.md#struct-conditionid-deprecated) - The condition variable.
- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The suspension duration, with a default value of [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) specified condition variable is awakened by another thread; returns `false` if the operation times out.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex, or `condID` was not created by this [MultiConditionMonitor <sup>(deprecated)</sup>](sync_package_classes.md#class-multiconditionmonitor-deprecated) instance via the `newCondition` function.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if `timeout` is less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero).

## class Mutex

```cangjie
public class Mutex <: UniqueLock {
    public init()
}
```

Function: Provides reentrant mutex lock functionality.

A reentrant mutex lock protects critical sections by ensuring that only one thread can execute the critical section code at any given time. When a thread attempts to acquire a lock held by another thread, it blocks until the lock is released. Reentrancy means a thread can acquire the same lock multiple times.

> **Note:**
>
> - The lock must be acquired before accessing shared data.
> - The lock must be released after processing shared data to allow other threads to acquire it.

Parent Types:

- [UniqueLock](./sync_package_interfaces.md#interface-uniquelock)

### init()

```cangjie
public init()
```

Function: Creates a reentrant mutex lock.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown when a system error occurs.

### func condition()

```cangjie
public func condition(): Condition
```

Function: Creates a [Condition](./sync_package_interfaces.md#interface-condition) associated with this [Mutex](#class-mutex).

Can be used to implement "single Lock with multiple wait queues" concurrency primitives.

Returns:

- [Condition](./sync_package_interfaces.md#interface-condition) - The created [Condition](./sync_package_interfaces.md#interface-condition) instance associated with this [Mutex](#class-mutex).

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex.

### func lock()

```cangjie
public func lock(): Unit
```

Function: Locks the mutex. If the mutex is already locked, the thread blocks.

### func tryLock()

```cangjie
public func tryLock(): Bool
```

Function: Attempts to lock the mutex.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `false` if the mutex is already locked; otherwise, locks the mutex and returns `true`.

### func unlock()

```cangjie
public func unlock(): Unit
```

Function: Unlocks the mutex.

If the mutex has been locked N times recursively, this function must be called N times to fully unlock it. Once fully unlocked, if other threads are blocked on this lock, one of them will be awakened.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex.

## class ReadWriteLock

```cangjie
public class ReadWriteLock {
    public init(fair!: Bool = false)
}
```

Function: Provides reentrant read-write lock functionality.

The difference from a regular mutex lock is that a read-write lock carries two mutex locks: a "read lock" and a "write lock," allowing multiple threads to hold the read lock simultaneously.

Special properties of read-write locks:

- Write exclusivity: Only one thread can hold the write lock. When a thread holds the write lock, other threads attempting to acquire any lock (read or write) will block.
- Read concurrency: Multiple threads can hold the read lock simultaneously. When a thread holds the read lock, other threads can still acquire the read lock but will block when attempting to acquire the write lock.
- Reentrancy: A thread can acquire the same lock multiple times.
    - When a thread holds the write lock, it can continue to acquire the write lock or the read lock. The lock is fully released only when unlock operations match the lock operations.
    - When a thread holds the read lock, it can continue to acquire the read lock. The lock is fully released only when unlock operations match the lock operations. Note: Attempting to acquire the write lock while holding the read lock will throw an exception.
- Lock downgrade: A thread can transition from "holding the write lock" to "holding the read lock" by first acquiring the read lock and then releasing the write lock.
- Read-write fairness: Read-write locks support two modes: "fair" and "non-fair."
    - In non-fair mode, the order in which threads acquire locks is not guaranteed.A nonfair lock that is continuously contended may indefinitely postpone one or more reader or writer threads.
    - In fair mode, when a thread attempts to acquire the read lock (and does not already hold it), if the write lock is held or there are threads waiting for the write lock, the thread will block.
    - In fair mode, releasing the write lock prioritizes waking all waiting read threads, while releasing the read lock prioritizes waking one waiting write thread. The order in which multiple waiting write threads are awakened is not guaranteed.

### prop readLock

```cangjie
public prop readLock: Lock
```

Function: Gets the read lock.

Type: [Lock](./sync_package_interfaces.md#interface-lock)

### prop writeLock

```cangjie
public prop writeLock: UniqueLock
```

Function: Gets the write lock.

Type: [UniqueLock](./sync_package_interfaces.md#interface-uniquelock)

### init(Bool)

```cangjie
public init(fair!: Bool = false)
```

Function: Constructs a read-write lock.

Parameters:

- fair!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the read-write lock is in fair mode. Defaults to `false` (non-fair mode).

### func isFair()

```cangjie
public func isFair(): Bool
```

Function: Checks whether the read-write lock is in "fair" mode.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` indicates fair mode; otherwise, indicates non-fair mode.

## class ReentrantMutex <sup>(deprecated)</sup>

```cangjie
public open class ReentrantMutex <: Lock {
    public init()
}
```

Function: Provides reentrant lock functionality.

A reentrant mutex lock protects critical sections by ensuring that only one thread can execute the critical section code at any given time. When a thread attempts to acquire a lock held by another thread, it blocks until the lock is released. Reentrancy means a thread can acquire the same lock multiple times.

> **Note:**
>
> - Will be deprecated in future versions, use [Mutex](#class-mutex) instead.
> - [ReentrantMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantmutex-deprecated) is a built-in mutex lock, and developers must ensure they do not inherit from it.
> - The lock must be acquired before accessing shared data.
> - The lock must be released after processing shared data to allow other threads to acquire it.

Parent Types:

- [Lock](sync_package_interfaces.md#interface-lock)

### init()

```cangjie
public init()
```

Function: Creates a reentrant mutex lock.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown when a system error occurs.

### func lock()

```cangjie
public open func lock(): Unit
```

Function: Locks the mutex. If the mutex is already locked, the thread blocks.

### func tryLock()

```cangjie
public open func tryLock(): Bool
```

Function: Attempts to lock the mutex.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `false` if the mutex is already locked; otherwise, locks the mutex and returns `true`.

### func unlock()

```cangjie
public open func unlock(): Unit
```

Function: Unlocks the mutex.

If the mutex has been locked N times recursively, this function must be called N times to fully unlock it. Once fully unlocked, if other threads are blocked on this lock, one of them will be awakened.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the mutex.

## class ReentrantReadMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantReadMutex <: ReentrantMutex
```

Function: Provides the read lock type for reentrant read-write locks.

> **Note:**
>
> Will be deprecated in future versions, use [Lock](./sync_package_interfaces.md#interface-lock) instead.

Parent Types:

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### func lock()

```cangjie
public func lock(): Unit
```

Function: Acquires the read lock.

> **Note:**
>
> - In fair mode, if no other thread holds or is waiting for the write lock, or if the current thread already holds the read lock, the read lock is acquired immediately; otherwise, the thread blocks.
> - In non-fair mode, if no other thread holds or is waiting for the write lock, the read lock is acquired immediately; if another thread holds the write lock, the thread blocks; otherwise, whether the thread can acquire the read lock immediately is not guaranteed.
> - Multiple threads can hold the read lock simultaneously, and a thread can acquire the read lock multiple times; a thread holding the write lock can still acquire the read lock.

### func tryLock()

```cangjie
public func tryLock(): Bool
```

Function: Attempts to acquire the read lock. This method does not follow fair mode when acquiring the read lock.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the read lock is acquired successfully; otherwise, returns `false`.

### func unlock()

```cangjie
public func unlock(): Unit
```

Function: Releases the read lock. If a thread has acquired the read lock multiple times, the lock is only released when the number of unlock operations matches the number of lock operations. If the read lock is released and there are threads waiting for the write lock, one of them is awakened.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the read lock.

## class ReentrantReadWriteMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantReadWriteMutex {
    public init(mode!: ReadWriteMutexMode = ReadWriteMutexMode.Unfair)
}
```

Function: Provides reentrant read-write lock functionality.

The difference from a regular mutex lock is that a read-write lock carries two mutex locks: a "read lock" and a "write lock," allowing multiple threads to hold the read lock simultaneously.

> **Note:**
>
> Will be deprecated in future versions, use [ReadWriteLock](#class-readwritelock) instead.

Special properties of read-write locks:

- Write exclusivity: Only one thread can hold the write lock. When a thread holds the write lock, other threads attempting to acquire any lock (read or write) will block.
- Read concurrency: Multiple threads can hold the read lock simultaneously. When a thread holds the read lock, other threads can still acquire the read lock but will block when attempting to acquire the write lock.
- Reentrancy: A thread can acquire the same lock multiple times.
    - When a thread holds the write lock, it can continue to acquire the write lock or the read lock. The lock is fully released only when unlock operations match the lock operations.
    - When a thread holds the read lock, it can continue to acquire the read lock. The lock is fully released only when unlock operations match the lock operations. Note: Attempting to acquire the write lock while holding the read lock will throw an exception.
- Lock downgrade: A thread can transition from "holding the write lock" to "holding the read lock" by first acquiring the read lock and then releasing the write lock.
- Read-write fairness: Read-write locks support two modes: "fair" and "non-fair."
    - In non-fair mode, the order in which threads acquire locks is not guaranteed.A nonfair lock that is continuously contended may indefinitely postpone one or more reader or writer threads.
    - In fair mode, when a thread attempts to acquire the read lock (and does not already hold it), if the write lock is held or there are threads waiting for the write lock, the thread will block.
    - In fair mode, releasing the write lock prioritizes waking all waiting read threads, while releasing the read lock prioritizes waking one waiting write thread. The order in which multiple waiting write threads are awakened is not guaranteed.

### prop readMutex

```cangjie
public prop readMutex: ReentrantReadMutex
```

Function: Gets the read lock.

Type: [ReentrantReadMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantreadmutex-deprecated)

### prop writeMutex

```cangjie
public prop writeMutex: ReentrantWriteMutex
```

Function: Gets the write lock.

Type: [ReentrantWriteMutex <sup>(deprecated)</sup>](sync_package_classes.md#class-reentrantwritemutex-deprecated)

## class ReentrantWriteMutex <sup>(deprecated)</sup>

```cangjie
public class ReentrantWriteMutex <: ReentrantMutex
```

Function: Provides the write lock type in a reentrant read-write lock.

> **Note:**
>
> This will be deprecated in future versions. Use [UniqueLock](./sync_package_interfaces.md#interface-uniquelock) instead.

Parent Types:

- [ReentrantMutex <sup>(deprecated)</sup>](#class-reentrantmutex-deprecated)

### func lock()

```cangjie
public func lock(): Unit
```

Function: Acquires the write lock. Only one thread can hold the write lock at a time, and the same thread can hold it multiple times. If another thread holds either a write lock or a read lock, the current thread will enter a waiting state.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread already holds a read lock.

### func tryLock()

```cangjie
public func tryLock(): Bool
```

Function: Attempts to acquire the write lock. This method does not follow fair mode when acquiring the write lock.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the write lock is successfully acquired; otherwise, returns `false`.

### func unlock()

```cangjie
public func unlock(): Unit
```

Function: Releases the write lock.

> **Note:**
>
> - If a thread holds the read lock multiple times, the read lock is only released when the number of release operations matches the number of acquire operations. If the read lock is released and there are threads waiting for the write lock, one of them will be awakened.
> - In fair mode, if the write lock is released and there are threads waiting for the read lock, those waiting threads will be awakened first. If no threads are waiting for the read lock but there are threads waiting for the write lock, one of them will be awakened.
> - In non-fair mode, if the write lock is released, there is no guarantee whether waiting write-lock threads or read-lock threads will be awakened first; this is implementation-dependent.

Exceptions:

- [IllegalSynchronizationStateException](sync_package_exceptions.md#class-illegalsynchronizationstateexception) - Thrown if the current thread does not hold the write lock.

## class Semaphore

```cangjie
public class Semaphore {
    public init(count: Int64)
}
```

Function: Provides semaphore-related functionality.

[Semaphore](sync_package_classes.md#class-semaphore) can be viewed as a [Monitor <sup>(deprecated)</sup>](sync_package_classes.md#class-monitor-deprecated) with a counter, commonly used to control the number of threads accessing shared resources concurrently.

### prop count

```cangjie
public prop count: Int64
```

Function: Returns the current value of the internal counter.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init(Int64)

```cangjie
public init(count: Int64)
```

Function: Creates a [Semaphore](sync_package_classes.md#class-semaphore) object and initializes the value of the internal counter.

Parameters:

- [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet): [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The initial value of the counter, ranging from [0, [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).Max].

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) is negative.

### func acquire(Int64)

```cangjie
public func acquire(amount!: Int64 = 1): Unit
```

Function: Acquires the specified value from the [Semaphore](sync_package_classes.md#class-semaphore) object.

If the current counter value is less than the requested amount, the current thread will be blocked until the required amount is available.

Parameters:

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to acquire from the internal counter. Defaults to 1.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter `amount` is negative or exceeds the initial value.

### func release(Int64)

```cangjie
public func release(amount!: Int64 = 1): Unit
```

Function: Releases the specified value to the [Semaphore](sync_package_classes.md#class-semaphore) object.

If the internal counter, after incrementing by the released value, satisfies any threads blocked on the [Semaphore](sync_package_classes.md#class-semaphore) object, those threads will be awakened. The internal counter value will not exceed the initial value; if the incremented value would exceed the initial value, it will be set to the initial value. All operations before calling `release` happen before any operations after calling `acquire/tryAcquire`.

Parameters:

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to release to the internal counter. Defaults to 1.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter `amount` is negative or exceeds the initial value.

### func tryAcquire(Int64)

```cangjie
public func tryAcquire(amount!: Int64 = 1): Bool
```

Function: Attempts to acquire the specified value from the [Semaphore](sync_package_classes.md#class-semaphore) object.

This method does not block the thread. If multiple threads concurrently attempt to acquire the value, the order of acquisition is not guaranteed.

Parameters:

- amount!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The value to acquire from the internal counter. Defaults to 1.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `false` if the current counter value is less than the requested amount; otherwise, returns `true`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter `amount` is negative or exceeds the initial value.

## class SyncCounter

```cangjie
public class SyncCounter {
    public init(count: Int64)
}
```

Function: Provides countdown counter functionality.

Threads can wait for the counter to reach zero.

### prop count

```cangjie
public prop count: Int64
```

Function: Gets the current value of the counter.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init(Int64)

```cangjie
public init(count: Int64)
```

Function: Creates a countdown counter.

Parameters:

- [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet): [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The initial value of the countdown counter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) is negative.

### func dec()

```cangjie
public func dec(): Unit
```

Function: Decrements the counter by one.

If the counter reaches zero, all waiting threads are awakened. If the counter is already zero, the value remains unchanged.

### func waitUntilZero(Duration)

```cangjie
public func waitUntilZero(timeout!: Duration = Duration.Max): Unit
```

Function: The current thread waits until the counter reaches zero or the waiting time exceeds `timeout`.

Parameters:

- timeout!: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The maximum duration to wait while blocked. Defaults to [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max).

## class Timer

```cangjie
public class Timer <: Equatable<Timer> & Hashable
```

Function: Provides timer functionality.

Used to execute a specified task once or multiple times at a specified time or after a specified interval.

> **Note:**
>
> - [Timer](sync_package_classes.md#class-timer) implicitly includes a `spawn` operation, meaning each [Timer](sync_package_classes.md#class-timer) creates a thread to execute the associated Task.
> - Each [Timer](sync_package_classes.md#class-timer) can only bind to one Task during initialization. After initialization, the associated Task cannot be reset.
> - The lifecycle of a [Timer](sync_package_classes.md#class-timer) ends only when the associated Task completes or the [Timer](sync_package_classes.md#class-timer) is actively canceled using the `cancel` interface. After that, it can be garbage collected by [GC](../../runtime/runtime_package_api/runtime_package_funcs.md#func-gcbool). In other words, a [Timer](sync_package_classes.md#class-timer) instance will not be garbage collected until its associated Task completes or it is actively canceled, ensuring the Task is executed normally.
> - When the system is busy, the Task's trigger time may be affected. [Timer](sync_package_classes.md#class-timer) does not guarantee that the Task will be triggered exactly on time. It ensures the Task is triggered no later than the current time.
> - [Timer](sync_package_classes.md#class-timer) does not actively catch exceptions thrown by the associated Task. If the Task throws an uncaught exception, the [Timer](sync_package_classes.md#class-timer) becomes invalid.
> - [Timer](sync_package_classes.md#class-timer) is typically categorized into one-shot timers and recurring timers. A one-shot timer executes its Task only once, while a recurring timer executes its Task at specified intervals until canceled or meeting the termination conditions specified during creation.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[Timer](#class-timer)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### static func after(Duration, ()->Option\<Duration>)

```cangjie
public static func after(delay: Duration, task: () -> Option<Duration>): Timer
```

Function: Initializes a [Timer](sync_package_classes.md#class-timer). The number of times the associated Task is scheduled depends on its return value. If the first trigger time is earlier than the current time, the Task will be executed immediately. If the Task returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).None, the [Timer](sync_package_classes.md#class-timer) will become invalid and stop scheduling the Task. If the Task returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).Some(v) and `v` is greater than [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), the minimum interval before the next execution will be set to `v`. Otherwise, the Task will be scheduled again immediately.

Parameters:

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval from now until the first execution of the Task.
- task: () ->[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)> - The Task to be scheduled by this [Timer](sync_package_classes.md#class-timer).

Returns:

- [Timer](sync_package_classes.md#class-timer) - A [Timer](sync_package_classes.md#class-timer) instance.

### static func once(Duration, ()->Unit)

```cangjie
public static func once(delay: Duration, task: ()->Unit): Timer
```

Function: Sets and starts a one-shot timer task, returning the [Timer](sync_package_classes.md#class-timer) instance controlling this task.

Parameters:

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval from now until the Task is executed. Valid range: [[Duration.Min](../../core/core_package_api/core_package_structs.md#static-const-min), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]. If less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), the Task will be executed immediately.
- task: ()->Unit - The task to be executed.

Returns:

- [Timer](sync_package_classes.md#class-timer) - The created instance.

Example:

<!-- run -->

```cangjie
import std.time.MonoTime
import std.sync.Timer

main() {
    let start = MonoTime.now()
    Timer.once(Duration.second, {=>
        println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 2)
    0
}
```

Possible output:

```text
Tick at: 1s2ms74us551ns
```

### static func repeat(Duration, Duration, ()->Unit, CatchupStyle)

```cangjie
public static func repeat(delay: Duration, interval: Duration, task: ()->Unit, style!: CatchupStyle = Burst): Timer
```

Function: Sets and starts a recurring timer task, returning the [Timer](sync_package_classes.md#class-timer) instance controlling this task.

Parameters:

- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval from now until the first execution of the Task. Valid range: [[Duration.Min](../../core/core_package_api/core_package_structs.md#static-const-min), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]. If less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), the Task will be executed immediately.
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The interval between two Task executions. Valid range: ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)].
- task: ()->Unit - The task to be executed.
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - The catch-up strategy, defaulting to Burst. If the Task execution time is too long, subsequent executions may be delayed. Different strategies suit different scenarios. See [CatchupStyle](sync_package_enums.md#enum-catchupstyle) for details.

Returns:

- [Timer](sync_package_classes.md#class-timer) - The created instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if `interval` is less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero).

Example:

<!-- run -->

```cangjie
import std.sync.Timer
import std.time.MonoTime

main() {
    let start = MonoTime.now()
    let timer = Timer.repeat(Duration.second, Duration.second, {=>
        println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 5)
    timer.cancel()
    0
}
```

Possible output:

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

Function: Sets and starts a recurring timer task with a maximum duration for the repetition period, returning the [Timer](sync_package_classes.md#class-timer) instance controlling this task.

Parameters:

- period: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The maximum duration for the repetition period, starting after the delay. Valid range: ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)].
- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval from now until the first execution of the Task. Valid range: [Duration.Min, [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]. If less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), the Task will be executed immediately.
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The interval between two Task executions. Valid range: ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)].
- task: ()->Unit - The task to be executed.
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - The catch-up strategy, defaulting to Burst. If the Task execution time is too long, subsequent executions may be delayed. Different strategies suit different scenarios. See [CatchupStyle](sync_package_enums.md#enum-catchupstyle) for details.

Returns:

- [Timer](sync_package_classes.md#class-timer) - The created instance.

Exceptions:

- [Illegal### static func repeatTimes(Int64, Duration, Duration, ()->Unit, CatchupStyle)

```cangjie
public static func repeatTimes(count: Int64, delay: Duration, interval: Duration, task: () -> Unit, style!: CatchupStyle = Burst): Timer
```

Function: Sets up and starts a recurring timed task with a specified maximum execution count for the Task, returning a [Timer](sync_package_classes.md#class-timer) object instance that controls this task.

Parameters:

- count: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The maximum number of times the Task will be executed. Valid range: (0, [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).Max].
- delay: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval from now until the Task is first executed. Valid range: [Duration.Min, [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)]. If less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), the Task will be executed immediately.
- interval: [Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The time interval between two consecutive Task executions. Valid range: ([Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero), [Duration.Max](../../core/core_package_api/core_package_structs.md#static-const-max)].
- task: ()->Unit - The task to be executed on schedule.
- style!: [CatchupStyle](./sync_package_enums.md#enum-catchupstyle) - The catch-up strategy, defaulting to Burst. When Task execution takes too long, subsequent execution time points may be delayed. Different catch-up strategies suit different scenarios. For details, see [CatchupStyle](sync_package_enums.md#enum-catchupstyle) description.

Returns:

- [Timer](sync_package_classes.md#class-timer) - The generated object instance.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) <= 0 or interval is less than or equal to [Duration.Zero](../../core/core_package_api/core_package_structs.md#static-const-zero).

Example:

<!-- run -->

```cangjie
import std.sync.Timer
import std.time.MonoTime

main() {
    let start = MonoTime.now()
    Timer.repeatTimes(3, Duration.second, Duration.second, {=>
        println("Tick at: ${MonoTime.now() - start}")
    })

    sleep(Duration.second * 4)
    0
}
```

Possible output:

```text
Tick at: 1s2ms855us251ns
Tick at: 2s5ms390us18ns
Tick at: 3s7ms935us552ns
```

### func cancel()

```cangjie
public func cancel(): Unit
```

Function: Cancels this [Timer](sync_package_classes.md#class-timer), and the associated Task will no longer be scheduled for execution.

If the associated Task is currently executing when this function is called, the current execution will not be interrupted. This function does not block the current thread. Calling this function multiple times is equivalent to calling it once.

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value of the [Timer](sync_package_classes.md#class-timer) object.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The hash value of the object.

### operator func !=(Timer)

```cangjie
public operator func !=(rhs: Timer): Bool
```

Function: Determines whether the current [Timer](sync_package_classes.md#class-timer) and the [Timer](sync_package_classes.md#class-timer) specified by the parameter `rhs` are not the same instance.

Parameters:

- rhs: [Timer](#class-timer) - Another [Timer](#class-timer) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [Timer](sync_package_classes.md#class-timer) instances are not the same, otherwise returns `false`.

### operator func ==(Timer)

```cangjie
public operator func ==(rhs: Timer): Bool
```

Function: Determines whether the current [Timer](sync_package_classes.md#class-timer) and the [Timer](sync_package_classes.md#class-timer) specified by the parameter `rhs` are the same instance.

Parameters:

- rhs: [Timer](#class-timer) - Another [Timer](#class-timer) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [Timer](sync_package_classes.md#class-timer) instances are the same, otherwise returns `false`.