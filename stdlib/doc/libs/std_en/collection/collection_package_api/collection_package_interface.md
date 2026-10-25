# Interfaces

## interface Deque\<T>

```cangjie
public interface Deque<T> <: Collection<T> {
    prop first: ?T
    prop last: ?T
    func addFirst(element: T): Unit
    func addLast(element: T): Unit
    func removeFirst(): ?T
    func removeLast(): ?T
}
```

Function: Deque (double-ended queue) is a data structure that combines features of both queues and stacks, allowing insertion and deletion of elements from both ends. The main functionalities of the Deque interface include:

- Insertion operations: Elements can be inserted at either the front or rear of the deque. Use `addFirst` to insert at the head, and `addLast` to insert at the tail.
- Access operations: Elements at either end can be accessed without removal. Use `first` to access the head element and `last` to access the tail element.
- Removal operations: Elements can be removed from either end. Use `removeFirst` to remove and return the head element, and `removeLast` to remove and return the tail element.
- Other collection-type supported operations such as element count, emptiness check, and iterator operations.

Parent type:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### prop first

```cangjie
prop first: ?T
```

Function: Accesses the head element of the deque without removing it.

Type: ?T

### prop last

```cangjie
prop last: ?T
```

Function: Accesses the tail element of the deque without removing it.

Type: ?T

### func addFirst(T)

```cangjie
func addFirst(element: T): Unit
```

Function: Inserts the specified element at the head of the deque.

Parameter:

- element: T - The element to be added to the deque.

### func addLast(T)

```cangjie
func addLast(element: T): Unit
```

Function: Inserts the specified element at the tail of the deque.

Parameter:

- element: T - The element to be added to the deque.

### func removeFirst()

```cangjie
func removeFirst(): ?T
```

Function: Removes and returns the head element of the deque.

Returns:

- ?T - The value of the removed element wrapped in Option. Returns None if the deque is empty.

### func removeLast()

```cangjie
func removeLast(): ?T
```

Function: Removes and returns the tail element of the deque.

Returns:

- ?T - The value of the removed element wrapped in Option. Returns None if the deque is empty.

## interface EquatableCollection\<T>

```cangjie
public interface EquatableCollection<T> <: Collection<T> {
    func contains(element: T): Bool
    func contains(all!: Collection<T>): Bool
}
```

Function: Defines collection types that support comparison operations.

Parent type:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### func contains(Collection\<T>)

```cangjie
func contains(all!: Collection<T>): Bool
```

Function: Determines whether the collection contains all elements of the specified collection.

Parameter:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection whose elements are to be checked for presence.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements are present, otherwise false.

### func contains(T)

```cangjie
func contains(element: T): Bool
```

Function: Determines whether the collection contains the specified element.

Parameter:

- element: T - The element to check for presence in the collection.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the element is present, otherwise false.

<!--Del_sink-->

### func contains(Collection\<T>)

```cangjie
func contains(this @local?, all!: Collection<T> @local?): Bool
```

Function: Checks whether the keys of this Keys container contain all elements of the specified collection.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> @local? - The collection `all` to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if contained; otherwise, returns false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ks: EquatableCollection<Int64> @local? = map.keys()
    let arr: Array<Int64> = [1, 2]
    let keys: ArrayList<Int64> = ArrayList<Int64>(arr)
    println("all=${ks.contains(all: keys)}")
}
```

Output:

```text
all=true
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func contains(T)

```cangjie
func contains(this @local?, element: T @local?): Bool
```

Function: Checks whether the keys of this Keys container contain the specified element.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- element: T @local? - The specified element to check for membership in the keys.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if contained; otherwise, returns false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    let ks: EquatableCollection<Int64> @local? = map.keys()
    println("has1=${ks.contains(1)}")
}
```

Output:

```text
has1=true
```

<!--DelEnd_sink-->

## interface List\<T>

```cangjie
public interface List<T> <: ReadOnlyList<T> {
    func add(element: T): Unit
    func add(all!: Collection<T>): Unit
    func add(element: T, at!: Int64): Unit
    func add(all!: Collection<T>, at!: Int64): Unit
    func remove(at!: Int64): T
    func remove(range: Range<Int64>): Unit
    func removeIf(predicate: (T) -> Bool): Unit
    func clear(): Unit

    operator func [](index: Int64, value!: T): Unit
}
```

Function: Defines a list type that provides index-friendly operations.

Parent type:

- [ReadOnlyList](#interface-readonlylistt)\<T>

### func add(Collection\<T>)

```cangjie
func add(all!: Collection<T>): Unit
```

Function: Appends all elements from the specified collection to the end of this list.

Parameter:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be inserted.

### func add(Collection\<T>, Int64)

```cangjie
func add(all!: Collection<T>, at!: Int64): Unit
```

Function: Inserts all elements from the specified collection into this list starting from the specified position.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements of type T to be inserted.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index for insertion.

### func add(T)

```cangjie
func add(element: T): Unit
```

Function: Appends the specified element to the end of this list.

Parameter:

- element: T - The element to be inserted, of type T.

### func add(T, Int64)

```cangjie
func add(element: T, at!: Int64): Unit
```

Function: Inserts the specified element at the specified position in this list.

Parameters:

- element: T - The element of type T to be inserted.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index for insertion.

<!--Del_sink-->

### func add(Collection\<T>)

```cangjie
func add(this @local!, all!: Collection<T> @local!): Unit
```

Function: Appends all elements of the specified collection to the end of this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> @local! - The collection of elements to insert.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    let more: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    more.add(2)
    more.add(3)
    list.add(all: more)
    println("size=${al.size}")
    println("at1=${list[1]}")
}
```

Output:

```text
size=3
at1=2
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func add(Collection\<T>, Int64)

```cangjie
func add(this @local!, all!: Collection<T> @local!, at!: Int64): Unit
```

Function: Inserts all elements of the specified collection into this list, starting at the specified position.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> @local! - The collection of T-type elements to insert.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index at which to insert the collection.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    list.add(5)
    let more: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    more.add(2)
    more.add(3)
    more.add(4)
    list.add(all: more, at: 1)
    println("size=${al.size}")
    println("at1=${list[1]}")
}
```

Output:

```text
size=5
at1=2
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func add(T)

```cangjie
func add(this @local!, element: T @local!): Unit
```

Function: Appends the specified element to the end of this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- element: T @local! - The element to insert, of type T.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    list.add(2)
    println("size=${al.size}")
}
```

Output:

```text
size=2
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func add(T, Int64)

```cangjie
func add(this @local!, element: T @local!, at!: Int64): Unit
```

Function: Inserts the specified element at the specified position in this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- element: T @local! - The T-type element to insert.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index at which to insert the element.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    list.add(3)
    list.add(2, at: 1)
    println("size=${al.size}")
    println("at1=${list[1]}")
}
```

Output:

```text
size=3
at1=2
```

<!--DelEnd_sink-->

### func clear()

```cangjie
func clear(): Unit
```

Function: Removes all elements from this list.

<!--Del_sink-->

### func clear()

```cangjie
func clear(this @local!): Unit
```

Function: Removes all elements from this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    list.add(2)
    list.clear()
    println("size=${al.size}")
}
```

Output:

```text
size=0
```

<!--DelEnd_sink-->

### func remove(Int64)

```cangjie
func remove(at!: Int64): T
```

Function: Removes the element at the specified position in this list.

Parameter:

- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to be removed.

Returns:

- T - The removed element.

### func remove(Range\<Int64>)

```cangjie
func remove(range: Range<Int64>): Unit
```

Function: Removes all elements in this list that fall within the specified [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet).

Parameter:

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The range of elements to be removed.

<!--Del_sink-->

### func remove(Int64)

```cangjie
func remove(this @local!, at!: Int64): T @local!
```

Function: Removes the element at the specified position in this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to be removed.

Returns:

- T @local! - The removed element.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(1)
    list.add(2)
    list.add(3)
    let removed = list.remove(at: 1)
    println("removed=${removed}")
    println("size=${al.size}")
}
```

Output:

```text
removed=2
size=2
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func remove(Range\<Int64>)

```cangjie
func remove(this @local!, range: Range<Int64>): Unit
```

Function: Removes all elements within the specified [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) from this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The range of elements to be removed.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(0)
    list.add(1)
    list.add(2)
    list.add(3)
    list.add(4)
    list.remove(1..3)
    println("size=${al.size}")
    println("at1=${list[1]}")
}
```

Output:

```text
size=3
at1=3
```

<!--DelEnd_sink-->

### func removeIf((T) -> Bool)

```cangjie
func removeIf(predicate: (T) -> Bool): Unit
```

Function: Removes all elements from this list that satisfy the given lambda expression or function.

Parameter:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition predicate for removal.

<!--Del_sink-->

### func removeIf((T) -> Bool)

```cangjie
func removeIf(this @local!, predicate: ((T @local!) -> Bool) @local?): Unit
```

Function: Removes all elements of this list that satisfy the given lambda expression or function.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- predicate: ((T @local!) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)) @local? - The condition used to decide removal.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let al: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    let list: List<Int64> @local! = al
    list.add(0)
    list.add(1)
    list.add(2)
    list.add(3)
    list.removeIf({e => e % 2 == 0})
    println("size=${al.size}")
    println("first=${list[0]}")
}
```

Output:

```text
size=2
first=1
```

<!--DelEnd_sink-->

### operator func \[](Int64, T)

```cangjie
operator func [](index: Int64, value!: T): Unit
```

Function: Operator overload - set, replaces the element at the specified position in this list with the specified element using the subscript operator.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index value to set.
- value!: T - The value of type T to set.

<!--Del_sink-->

### operator func [](Int64, T)

```cangjie
operator func [](this @local!, index: Int64, value!: T @local!): Unit
```

Function: Operator overload - set. Replaces the element at the specified position in this list with the specified element via the subscript operator.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index to set.
- value!: T @local! - The T-type value to set.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    list[1] = 25
    println("at1=${list[1]}")
}
```

Output:

```text
at1=25
```

<!--DelEnd_sink-->

## interface Map\<K, V>

```cangjie
public interface Map<K, V> <: ReadOnlyMap<K, V> {
    func add(key: K, value: V): ?V
    func add(all!: Collection<(K, V)>): Unit
    func addIfAbsent(key: K, value: V): ?V
    func clear(): Unit
    func entryView(k: K): MapEntryView<K, V>
    func remove(key: K): Option<V>
    func remove(all!: Collection<K>): Unit
    func removeIf(predicate: (K, V) -> Bool): Unit
    func replace(key: K, value: V): ?V
    operator func [](key: K, value!: V): Unit
}
```

Function: The [Map](collection_package_interface.md#interface-mapk-v) interface provides a way to map keys to values. It allows lookup of values using keys, enabling storage and manipulation of key-value pairs.

A [Map](collection_package_interface.md#interface-mapk-v) cannot contain duplicate keys; each key maps to at most one value.

Parent type:

- [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v)\<K, V>

### func add(Collection\<(K, V)>)

```cangjie
func add(all!: Collection<(K, V)>): Unit
```

Function: Places new key-value pairs into the [Map](collection_package_interface.md#interface-mapk-v). For existing keys in the map, their mapped values will be replaced with new values.

Parameter:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> - The collection of key-value pairs to be placed into the map.

### func add(K, V)

```cangjie
func add(key: K, value: V): ?V
```

Function: Places the specified key-value pair into this [Map](collection_package_interface.md#interface-mapk-v). For existing keys in the map, their mapped values will be replaced with the new value.

Parameters:

- key: K - The key to place.
- value: V - The value to assign.

Returns:

- ?V - Returns the old value if the key previously existed, otherwise returns None.

<!--Del_sink-->

### func add(Collection\<(K, V)>)

```cangjie
func add(this @local!, all!: Collection<(K, V)> @local!): Unit
```

Function: Puts the new key-value pairs into this [Map](collection_package_interface.md#interface-mapk-v). For keys already present in the [Map](collection_package_interface.md#interface-mapk-v), the value mapped to the key is replaced by the new value.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> @local! - The collection of key-value pairs to put into the [Map](collection_package_interface.md#interface-mapk-v).

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    let pairs: ArrayList<(Int64, Int64)> @local! = ArrayList<(Int64, Int64)>() @local!
    pairs.add((1, 10))
    pairs.add((2, 20))
    map.add(all: pairs)
    println("size=${hm.size}")
}
```

Output:

```text
size=2
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func add(K, V)

```cangjie
func add(this @local!, key: K @local!, value: V @local!): ?V @local!
```

Function: Puts the specified key-value pair into this [Map](collection_package_interface.md#interface-mapk-v). For keys already present in the [Map](collection_package_interface.md#interface-mapk-v), the value mapped to the key is replaced by the new value.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local! - The key to put.
- value: V @local! - The value to assign.

Returns:

- ?V @local! - If the key existed before the assignment, the old value is returned; otherwise, None is returned.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    let old = map.add(1, 100)
    match (old) {
        case Some(v) => println("old=${v}")
        case None => println("old=none")
    }
    let prev = map.add(1, 200)
    match (prev) {
        case Some(v) => println("prev=${v}")
        case None => println("prev=none")
    }
    println("size=${hm.size}")
}
```

Output:

```text
old=none
prev=100
size=1
```

<!--DelEnd_sink-->

### func addIfAbsent(K, V)

```cangjie
func addIfAbsent(key: K, value: V): ?V
```

Function: Adds the specified key-value pair if the key is not already present in the current [Map](collection_package_interface.md#interface-mapk-v). Otherwise, makes no modifications.

Parameters:

- key: K - The key of the key-value pair to be added.
- value: V - The value of the key-value pair to be added.

Returns:

- ?V - Returns the old value if the key was already present in the map, otherwise returns None.

<!--Del_sink-->

### func addIfAbsent(K, V)

```cangjie
func addIfAbsent(this @local!, key: K @local!, value: V @local!): ?V @local!
```

Function: If the key is not in this [Map](collection_package_interface.md#interface-mapk-v), adds the specified key-value pair. Otherwise, makes no modification.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local! - The key of the key-value pair to add.
- value: V @local! - The value of the key-value pair to add.

Returns:

- ?V @local! - If the specified key already exists in the current [Map](collection_package_interface.md#interface-mapk-v) when this function is called, the old value of the key is returned; otherwise, None is returned.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    let exists = map.addIfAbsent(1, 999)
    match (exists) {
        case Some(v) => println("exists=${v}")
        case None => println("exists=none")
    }
    let absent = map.addIfAbsent(2, 200)
    match (absent) {
        case Some(v) => println("absent=${v}")
        case None => println("absent=none")
    }
    println("size=${hm.size}")
}
```

Output:

```text
exists=100
absent=none
size=2
```

<!--DelEnd_sink-->

### func clear()

```cangjie
func clear(): Unit
```

Function: Clears all key-value pairs.

<!--Del_sink-->

### func clear()

```cangjie
func clear(this @local!): Unit
```

Function: Clears all key-value pairs from this [Map](collection_package_interface.md#interface-mapk-v).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    map.add(2, 200)
    map.clear()
    println("size=${hm.size}")
}
```

Output:

```text
size=0
```

<!--DelEnd_sink-->

### func entryView(K)

```cangjie
func entryView(k: K): MapEntryView<K, V>
```

Function: Gets the view corresponding to the specified key k.

Parameter:

- k: K - The key whose view is to be obtained.

Returns:

- [MapEntryView](#interface-mapentryviewk-v)\<K, V> - The view corresponding to key k.

<!--Del_sink-->

### func entryView(K)

```cangjie
func entryView(this @local!, k: K @local!): MapEntryView<K, V> @local!
```

Function: Gets the view corresponding to key k in this [Map](collection_package_interface.md#interface-mapk-v).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- k: K @local! - The key whose view is to be obtained.

Returns:

- [MapEntryView](collection_package_interface.md#interface-mapentryviewk-v)\<K, V> @local! - The view corresponding to key k.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let view: MapEntryView<Int64, Int64> @local! = map.entryView(1)
    println("hasValue=${view.value.isSome()}")
}
```

Output:

```text
hasValue=true
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func entryView(K)

```cangjie
func entryView(this @local?, k: K @local!): MapEntryView<K, V> @local?
```

Function: Gets the view corresponding to key k in this [Map](collection_package_interface.md#interface-mapk-v).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- k: K @local! - The key whose view is to be obtained.

Returns:

- [MapEntryView](collection_package_interface.md#interface-mapentryviewk-v)\<K, V> @local? - The view corresponding to key k.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    let shared: Map<Int64, Int64> @local? = map
    try {
        let view: MapEntryView<Int64, Int64> @local? = shared.entryView(1)
        println("unexpected=${view.key}")
    } catch (e: UnimplementedException) {
        println("caught UnimplementedException")
    }
}
```

Output:

```text
caught UnimplementedException
```

<!--DelEnd_sink-->

### func remove(Collection\<K>)

```cangjie
func remove(all!: Collection<K>): Unit
```

Function: Removes mappings for all keys in the specified collection from this map if present.

Parameter:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys whose mappings are to be removed.

### func remove(K)

```cangjie
func remove(key: K): Option<V>
```

Function: Removes the mapping for the specified key from this [Map](collection_package_interface.md#interface-mapk-v) if present.

Parameter:

- key: K - The key whose mapping is to be removed.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - The value associated with the removed key, wrapped in Option.

<!--Del_sink-->

### func remove(Collection\<K>)

```cangjie
func remove(this @local!, all!: Collection<K> @local?): Unit
```

Function: Removes the mappings of the specified collection from this map, if present.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> @local? - The collection to remove.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    map.add(2, 200)
    map.add(3, 300)
    let keys: ArrayList<Int64> @local! = ArrayList<Int64>() @local!
    keys.add(1)
    keys.add(3)
    map.remove(all: keys)
    println("size=${hm.size}")
}
```

Output:

```text
size=1
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func remove(K)

```cangjie
func remove(this @local!, key: K @local?): Option<V> @local!
```

Function: Removes the mapping for the specified key from this [Map](collection_package_interface.md#interface-mapk-v), if present.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local? - The key to remove.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> @local! - The value corresponding to the key removed from the [Map](collection_package_interface.md#interface-mapk-v), wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    let removed = map.remove(1)
    match (removed) {
        case Some(v) => println("removed=${v}")
        case None => println("removed=none")
    }
    println("size=${hm.size}")
}
```

Output:

```text
removed=100
size=0
```

<!--DelEnd_sink-->

### func removeIf((K, V) -> Bool)

```cangjie
func removeIf(predicate: (K, V) -> Bool): Unit
```

Function: Removes all key-value pairs that satisfy the given lambda expression.

Parameter:

- predicate: (K, V) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition predicate for removal.

<!--Del_sink-->

### func removeIf((K, V) -> Bool)

```cangjie
func removeIf(this @local!, predicate: ((K @local?, V @local?) -> Bool) @local?): Unit
```

Function: Passes a lambda expression and deletes the corresponding key-value pairs in this [Map](collection_package_interface.md#interface-mapk-v) if the condition is satisfied.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- predicate: ((K @local?, V @local?) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)) @local? - The lambda expression used for the test.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    map.add(2, 200)
    map.add(3, 300)
    map.removeIf({k, v => v > 100})
    println("size=${hm.size}")
}
```

Output:

```text
size=1
```

<!--DelEnd_sink-->

### func replace(K, V)

```cangjie
func replace(key: K, value: V): ?V
```

Function: Replaces the value for the specified key with the new value if the key is present in the current [Map](collection_package_interface.md#interface-mapk-v). Otherwise, makes no modifications.

Parameters:

- key: K - The key of the key-value pair to be modified.
- value: V - The new value for the key-value pair.

Returns:

- ?V - Returns the old value if the key was present in the map, otherwise returns None.

<!--Del_sink-->

### func replace(K, V)

```cangjie
func replace(this @local!, key: K @local!, value: V @local!): ?V @local!
```

Function: If the specified key already exists in this [Map](collection_package_interface.md#interface-mapk-v), modifies its value to value. Otherwise, makes no modification.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local! - The key of the key-value pair to modify.
- value: V @local! - The new value of the key-value pair.

Returns:

- ?V @local! - If the specified key already exists in the current [Map](collection_package_interface.md#interface-mapk-v), its old value is returned. Otherwise, None is returned.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    let old = map.replace(1, 150)
    match (old) {
        case Some(v) => println("old=${v}")
        case None => println("old=none")
    }
    let absent = map.replace(9, 900)
    match (absent) {
        case Some(v) => println("absent=${v}")
        case None => println("absent=none")
    }
    println("size=${hm.size}")
}
```

Output:

```text
old=100
absent=none
size=1
```

<!--DelEnd_sink-->

### operator func \[](K, V)

```cangjie
operator func [](key: K, value!: V): Unit
```

Function: Operator overload collection. If the key exists, the new value overwrites the old value. If the key doesn't exist, adds this key-value pair.

Parameters:

- key: K - The key to be set.
- value!: V - The value to be set.

<!--Del_sink-->

### operator func [](K, V)

```cangjie
operator func [](this @local!, key: K @local!, value!: V @local!): Unit
```

Function: Operator overload collection. If the key exists, the new value overwrites the old value in this [Map](collection_package_interface.md#interface-mapk-v); if the key does not exist, this key-value pair is added.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local! - The key to set.
- value!: V @local! - The value to set.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map[1] = 100
    println("size=${hm.size}")
    println("v=${map[1]}")
}
```

Output:

```text
size=1
v=100
```

<!--DelEnd_sink-->

## interface MapEntryView\<K, V>

```cangjie
public interface MapEntryView<K, V> {
    public prop key: K
    public mut prop value: ?V
}
```

Function: Provides a view of the key-value mapping in a map.

### prop key

```cangjie
public prop key: K
```

Function: Returns the key stored in the view.

Type: K

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown on platforms other than OpenHarmony when the current type does not provide the property implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = HashMap<String, Int64>()
    map["a"] = 1
    let view = map.entryView("a")
    println("key=${view.key}")
}
```

Output:

```text
key=a
```

<!--Del_sink-->

### prop key

```cangjie
prop key: K @local?
```

Function: Returns the key stored in this view.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: K @local?

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let view: MapEntryView<Int64, Int64> @local? = map.entryView(1)
    println("key=${view.key}")
}
```

Output:

```text
key=1
```

<!--DelEnd_sink-->

### prop value

```cangjie
public mut prop value: ?V
```

Function: Reads or modifies the value corresponding to the view in the original map.

When setting a non-null value, if the view's value does not exist, a new element will be added to the original map corresponding to this view.
When set to `None`, the current Entry will be deleted. After deletion, the view can still be used.

Type: ?V

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown on platforms other than OpenHarmony when the current type does not provide the property implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = HashMap<String, Int64>()
    map["a"] = 1
    let view = map.entryView("a")
    match (view.value) {
        case Some(v) => println("value=${v}")
        case None => println("value=none")
    }
    view.value = Some(2)
    println("after=${map["a"]}")
}
```

Output:

```text
value=1
after=2
```

<!--Del_sink-->

### prop value

```cangjie
mut prop value: ?V @local!
```

Function: Reads or modifies the value of the original map corresponding to this view.
When setting a non-null value, if the value of the view does not exist, a new element is added to the original map corresponding to this view.
When set to `None`, the current Entry is deleted. After deletion, the view can still be used.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: ?V @local!

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let hm: HashMap<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    let map: Map<Int64, Int64> @local! = hm
    map.add(1, 100)
    let view: MapEntryView<Int64, Int64> @local! = map.entryView(1)
    view.value = Some(200)
    println("v=${map[1]}")
    view.value = None
    println("size=${hm.size}")
}
```

Output:

```text
v=200
size=0
```

<!--DelEnd_sink-->

## interface OrderedMap\<K, V>

```cangjie
public interface OrderedMap<K, V> <: Map<K, V> {
    public prop first: ?(K, V)
    public prop last: ?(K, V)
    public func removeFirst(): ?(K, V)
    public func removeLast(): ?(K, V)

    public func backward(mark: K, inclusive!: Bool): Iterator<(K, V)>
    public func forward(mark: K, inclusive!: Bool): Iterator<(K, V)>
}
```

Function: The [OrderedMap](collection_package_interface.md#interface-orderedmapk-v) interface provides a way to map keys to values. It allows us to use keys to look up values, making it suitable for storing and manipulating key-value pairs.

In instances of the [OrderedMap](collection_package_interface.md#interface-orderedmapk-v) interface, the internal elements are ordered.

Parent Types:

- [Map](collection_package_interface.md#interface-mapk-v)\<K, V>

### prop first

```cangjie
public prop first: ?(K, V)
```

Function: Gets the first element of the [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v).

Type: ?(K, V)

### prop last

```cangjie
public prop last: ?(K, V)
```

Function: Gets the last element of the [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v).

Type: ?(K, V)

### func backward(K, Bool)

```cangjie
public func backward(mark: K, inclusive!: Bool): Iterator<(K, V)>
```

Function: Gets an iterator that traverses from the first node with a key less than or equal to `mark` in descending order to [first](./collection_package_interface.md#prop-first). If the node's key equals `mark`, the inclusion of that node is determined by `inclusive!`.

Parameters:

- mark: K - The key used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the key of the first element in the iterator, specifies whether to include `mark` as the starting point.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)> - The iterator.

### func forward(K, Bool)

```cangjie
public func forward(mark: K, inclusive!: Bool): Iterator<(K, V)>
```

Function: Gets an iterator that traverses from the first node with a key greater than or equal to `mark` in ascending order to [last](./collection_package_interface.md#prop-last). If the node's key equals `mark`, the inclusion of that node is determined by `inclusive!`.

Parameters:

- mark: K - The key used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the key of the first element in the iterator, specifies whether to include `mark` as the starting point.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)> - The iterator.

### func removeFirst()

```cangjie
public func removeFirst(): ?(K, V)
```

Function: Removes the first element of the [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v).

Returns:

- ?(K, V) - If the current [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v) is not empty, returns the removed key-value pair encapsulated in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns `None`.

### func removeLast()

```cangjie
public func removeLast(): ?(K, V)
```

Function: Removes the last element of the [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v).

Returns:

- ?(K, V) - If the current [OrderedMap](./collection_package_interface.md#interface-orderedmapk-v) is not empty, returns the removed key-value pair encapsulated in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns `None`.

## interface OrderedSet\<T>

```cangjie
public interface OrderedSet<T> <: Set<T> {
    public prop first: ?T
    public prop last: ?T
    public func removeFirst(): ?T
    public func removeLast(): ?T

    public func backward(mark: T, inclusive!: Bool): Iterator<T>
    public func forward(mark: T, inclusive!: Bool): Iterator<T>
}
```

Function: The [OrderedSet](collection_package_interface.md#interface-orderedsett) interface provides a set of operations for collections, allowing us to manipulate internal elements in a read-write manner.

In instances of the [OrderedSet](collection_package_interface.md#interface-orderedsett) interface, the internal elements are ordered.

Parent Types:

- [Set](collection_package_interface.md#interface-sett)\<T>

### prop first

```cangjie
public prop first: ?T
```

Function: Gets the first element of the [OrderedSet](collection_package_interface.md#interface-orderedsett).

Type: ?T

### prop last

```cangjie
public prop last: ?T
```

Function: Gets the last element of the [OrderedSet](collection_package_interface.md#interface-orderedsett).

Type: ?T

### func backward(T, Bool)

```cangjie
public func backward(mark: T, inclusive!: Bool): Iterator<T>
```

Function: Gets an iterator that traverses from the first node with an element less than or equal to `mark` in descending order to [first](./collection_package_interface.md#prop-first). If the node's element equals `mark`, the inclusion of that node is determined by `inclusive!`.

Parameters:

- mark: T - The element used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the first element in the iterator, specifies whether to include `mark` as the starting point.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - The iterator.

### func forward(T, Bool)

```cangjie
public func forward(mark: T, inclusive!: Bool): Iterator<T>
```

Function: Gets an iterator that traverses from the first node with an element greater than or equal to `mark` in ascending order to [last](./collection_package_interface.md#prop-last). If the node's element equals `mark`, the inclusion of that node is determined by `inclusive!`.

Parameters:

- mark: T - The element used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the first element in the iterator, specifies whether to include `mark` as the starting point.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - The iterator.

### func removeFirst()

```cangjie
public func removeFirst(): ?T
```

Function: Removes the first element of the [OrderedSet](collection_package_interface.md#interface-orderedsett).

Returns:

- ?T - If the current [OrderedSet](collection_package_interface.md#interface-orderedsett) is not empty, returns the removed element encapsulated in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns `None`.

### func removeLast()

```cangjie
public func removeLast(): ?T
```

Function: Removes the last element of the [OrderedSet](collection_package_interface.md#interface-orderedsett).

Returns:

- ?T - If the current [OrderedSet](collection_package_interface.md#interface-orderedsett) is not empty, returns the removed element encapsulated in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns `None`.

## interface Queue\<T>

```cangjie
public interface Queue<T> <: Collection<T> {
    func add(element: T): Unit
    func peek(): ?T
    func remove(): ?T
}
```

Function: A queue data structure that follows the First-In-First-Out (FIFO) principle. The main functionalities of Queue include:

- Adding elements: Appends the specified element to the tail of the queue.
- Access operations: Accesses the front element of the queue without removing it.
- Removal operations: Removes the front element of the queue.
- Other operations supported by collection types, such as element count, emptiness check, and iterator operations.

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### func add(T)

```cangjie
func add(element: T): Unit
```

Function: Inserts the specified element at the tail of the queue.

Parameters:

- element: T - The element to be added to the queue.

### func peek()

```cangjie
func peek(): ?T
```

Function: Accesses the front element of the queue without removing it.

Returns:

- ?T - The value of the front element encapsulated in Option. If the queue is empty, returns `None`.

### func remove()

```cangjie
func remove(): ?T
```

Function: Removes the front element of the queue and returns its value.

Returns:

- ?T - The value of the removed element encapsulated in Option. If the queue is empty, returns `None`.

## interface ReadOnlyList\<T>

```cangjie
public interface ReadOnlyList<T> <: Collection<T> {
    prop first: ?T
    prop last: ?T
    func get(index: Int64): ?T
    operator func [](index: Int64): T
}
```

Function: Defines a read-only list.

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### prop first

```cangjie
prop first: ?T
```

Function: Returns the first element in this list, or None if there is none.

Type: ?T

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown on platforms other than OpenHarmony when the current type does not provide the property implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let ro: ReadOnlyList<Int64> = ArrayList<Int64>([1, 2, 3])
    let f = ro.first
    match (f) {
        case Some(v) => println("first=${v}")
        case None => println("first=none")
    }
}
```

Output:

```text
first=1
```

<!--Del_sink-->

### prop first

```cangjie
prop first: ?T @local!
```

Function: Returns the first element of this list, or None if there is no such element.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: ?T @local!

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local! = list
    let f = ro.first
    match (f) {
        case Some(v) => println("first=${v}")
        case None => println("first=none")
    }
}
```

Output:

```text
first=10
```

<!--DelEnd_sink-->

<!--Del_sink-->

### prop first

```cangjie
prop first: ?T @local?
```

Function: Returns the first element of this list, or None if there is no such element.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: ?T @local?

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local? = list
    let f = ro.first
    match (f) {
        case Some(v) => println("first=${v}")
        case None => println("first=none")
    }
}
```

Output:

```text
first=10
```

<!--DelEnd_sink-->

### prop last

```cangjie
prop last: ?T
```

Function: Returns the last element in this list, or None if there is none.

Type: ?T

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown on platforms other than OpenHarmony when the current type does not provide the property implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let ro: ReadOnlyList<Int64> = ArrayList<Int64>([1, 2, 3])
    let t = ro.last
    match (t) {
        case Some(v) => println("last=${v}")
        case None => println("last=none")
    }
}
```

Output:

```text
last=3
```

<!--Del_sink-->

### prop last

```cangjie
prop last: ?T @local!
```

Function: Returns the last element of this list, or None if there is no such element.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: ?T @local!

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local! = list
    let t = ro.last
    match (t) {
        case Some(v) => println("last=${v}")
        case None => println("last=none")
    }
}
```

Output:

```text
last=20
```

<!--DelEnd_sink-->

<!--Del_sink-->

### prop last

```cangjie
prop last: ?T @local?
```

Function: Returns the last element of this list, or None if there is no such element.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Type: ?T @local?

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local? = list
    let t = ro.last
    match (t) {
        case Some(v) => println("last=${v}")
        case None => println("last=none")
    }
}
```

Output:

```text
last=20
```

<!--DelEnd_sink-->

### func get(Int64)

```cangjie
func get(index: Int64): ?T
```

Function: Returns the element at the specified position in this list.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to return.

Returns:

- ?T - The element at the specified position. If the index is less than 0 or greater than or equal to the number of elements in this list, returns None.

<!--Del_sink-->

### func get(Int64)

```cangjie
func get(this @local!, index: Int64): ?T @local!
```

Function: Returns the element at the specified position in this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to return.

Returns:

- ?T @local! - Returns the element at the specified position. If `index` is less than 0 or greater than or equal to the number of elements in this list, None is returned.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local! = list
    let g0 = ro.get(0)
    match (g0) {
        case Some(v) => println("g0=${v}")
        case None => println("g0=none")
    }
    let g5 = ro.get(5)
    match (g5) {
        case Some(v) => println("g5=${v}")
        case None => println("g5=none")
    }
}
```

Output:

```text
g0=10
g5=none
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func get(Int64)

```cangjie
func get(this @local?, index: Int64): ?T @local?
```

Function: Returns the element at the specified position in this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to return.

Returns:

- ?T @local? - Returns the element at the specified position. If `index` is less than 0 or greater than or equal to the number of elements in this list, None is returned.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local? = list
    let g1 = ro.get(1)
    match (g1) {
        case Some(v) => println("g1=${v}")
        case None => println("g1=none")
    }
}
```

Output:

```text
g1=20
```

<!--DelEnd_sink-->

### operator func \[](Int64)

```cangjie
operator func [](index: Int64): T
```

Function: Operator overload - get.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index for the get operation.

Returns:

- T - The value of the element at the specified index.

<!--Del_sink-->

### operator func [](Int64)

```cangjie
operator func [](this @local!, index: Int64): T @local!
```

Function: Operator overload - get. Accesses the element at the specified index of this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index for the get interface.

Returns:

- T @local! - The value of the element at the index position.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local! = list
    println("idx1=${ro[1]}")
}
```

Output:

```text
idx1=20
```

<!--DelEnd_sink-->

<!--Del_sink-->

### operator func [](Int64)

```cangjie
operator func [](this @local?, index: Int64): T @local?
```

Function: Operator overload - get. Accesses the element at the specified index of this list.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index for the get interface.

Returns:

- T @local? - The value of the element at the index position.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list: List<Int64> @local! = ArrayList<Int64>() @local!
    list.add(10)
    list.add(20)
    let ro: ReadOnlyList<Int64> @local? = list
    println("idx1=${ro[1]}")
}
```

Output:

```text
idx1=20
```

<!--DelEnd_sink-->

## interface ReadOnlyMap\<K, V>

```cangjie
public interface ReadOnlyMap<K, V> <: Collection<(K, V)> {
    func get(key: K): ?V
    func contains(key: K): Bool
    func contains(all!: Collection<K>): Bool
    func keys(): EquatableCollection<K>
    func values(): Collection<V>

    operator func [](key: K): V
}
```

Function: The [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) interface provides a way to map keys to values. It allows us to use keys to look up values, making it suitable for storing key-value pairs.

A [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) cannot contain duplicate keys; each key can map to at most one value.

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)>

### func contains(Collection\<K>)

```cangjie
func contains(all!: Collection<K>): Bool
```

Function: Determines whether mappings for all keys in the specified collection exist.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all keys exist; otherwise, returns false.

### func contains(K)

```cangjie
func contains(key: K): Bool
```

Function: Determines whether a mapping for the specified key exists.

Parameters:

- key: K - The key to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the key exists; otherwise, returns false.

<!--Del_sink-->

### func contains(Collection\<K>)

```cangjie
func contains(this @local?, all!: Collection<K> @local?): Bool
```

Function: Checks whether this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) contains mappings for the keys of the specified collection.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> @local? - The collection to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if present; otherwise, returns false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    let arr: Array<Int64> = [1, 2]
    let keys: ArrayList<Int64> = ArrayList<Int64>(arr)
    println("all=${ro.contains(all: keys)}")
}
```

Output:

```text
all=true
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func contains(K)

```cangjie
func contains(this @local?, key: K @local?): Bool
```

Function: Checks whether this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) contains the mapping for the specified key.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- key: K @local? - The key to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if present; otherwise, returns false.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    println("has1=${ro.contains(1)}")
}
```

Output:

```text
has1=true
```

<!--DelEnd_sink-->

### func get(K)

```cangjie
func get(key: K): ?V
```

Function: Gets the value mapped to the key in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v).

Parameters:

- key: K - The key used to look up the value.

Returns:

- ?V - The value corresponding to the key in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v).

<!--Del_sink-->

### func get(K)

```cangjie
func get(this @local!, key: K @local?): ?V @local!
```

Function: Gets the value mapped in this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) according to the key.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local? - The key used to get the value.

Returns:

- ?V @local! - The value corresponding to the Key in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v).

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let ro: ReadOnlyMap<Int64, Int64> @local! = map
    let g1 = ro.get(1)
    match (g1) {
        case Some(v) => println("g1=${v}")
        case None => println("g1=none")
    }
    let g9 = ro.get(9)
    match (g9) {
        case Some(v) => println("g9=${v}")
        case None => println("g9=none")
    }
}
```

Output:

```text
g1=100
g9=none
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func get(K)

```cangjie
func get(this @local?, key: K @local?): ?V @local?
```

Function: Gets the value mapped in this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) according to the key.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- key: K @local? - The key used to get the value.

Returns:

- ?V @local? - The value corresponding to the Key in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v).

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    let g1 = ro.get(1)
    match (g1) {
        case Some(v) => println("g1=${v}")
        case None => println("g1=none")
    }
}
```

Output:

```text
g1=100
```

<!--DelEnd_sink-->

### func keys()

```cangjie
func keys(): EquatableCollection<K>
```

Function: Returns all keys in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v), stored in an [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> container.

Returns:

- [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> - Contains all returned keys.

<!--Del_sink-->

### func keys()

```cangjie
func keys(this @local!): EquatableCollection<K> @local!
```

Function: Returns all keys of this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) and stores them in an [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> container.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Returns:

- [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> @local! - Holds all returned keys.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let ro: ReadOnlyMap<Int64, Int64> @local! = map
    let ks: EquatableCollection<Int64> @local! = ro.keys()
    println("has1=${ks.contains(1)}")
}
```

Output:

```text
has1=true
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func keys()

```cangjie
func keys(this @local?): EquatableCollection<K> @local?
```

Function: Returns all keys of this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) and stores them in an [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> container.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> @local? - Holds all returned keys.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    let ks: EquatableCollection<Int64> @local? = ro.keys()
    println("has1=${ks.contains(1)}")
}
```

Output:

```text
has1=true
```

<!--DelEnd_sink-->

### func values()

```cangjie
func values(): Collection<V>
```

Function: Returns all values in the [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v), stored in a [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> container.

Returns:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> - Contains all returned values.

<!--Del_sink-->

### func values()

```cangjie
func values(this @local!): Collection<V> @local!
```

Function: Returns all values of this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) and stores them in a [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> container.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.

Returns:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> @local! - Holds all returned values.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let ro: ReadOnlyMap<Int64, Int64> @local! = map
    let vs: Collection<Int64> @local! = ro.values()
    println("empty=${vs.isEmpty()}")
}
```

Output:

```text
empty=false
```

<!--DelEnd_sink-->

<!--Del_sink-->

### func values()

```cangjie
func values(this @local?): Collection<V> @local?
```

Function: Returns all values of this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) and stores them in a [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> container.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.

Returns:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> @local? - Holds all returned values.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    let vs: Collection<Int64> @local? = ro.values()
    println("empty=${vs.isEmpty()}")
}
```

Output:

```text
empty=false
```

<!--DelEnd_sink-->

### operator func \[](K)

```cangjie
operator func [](key: K): V
```

Function: Operator overload for collection access. If the key exists, returns the corresponding value; otherwise, throws an exception.

Parameters:

- key: K - The key to look up.

Returns:

- V - The value corresponding to the key.

<!--Del_sink-->

### operator func [](K)

```cangjie
operator func [](this @local!, key: K @local?): V @local!
```

Function: Operator overload collection. If the key exists, the value corresponding to the key in this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) is returned; if it does not exist, an exception is thrown.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local! - The current `@local!` instance on which the method is called.
- key: K @local? - The key to look up.

Returns:

- V @local! - The value corresponding to the key.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local!` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 100)
    let ro: ReadOnlyMap<Int64, Int64> @local! = map
    println("v=${ro[1]}")
}
```

Output:

```text
v=100
```

<!--DelEnd_sink-->

<!--Del_sink-->

### operator func [](K)

```cangjie
operator func [](this @local?, key: K @local?): V @local?
```

Function: Operator overload collection. If the key exists, the value corresponding to the key in this [ReadOnlyMap](collection_package_interface.md#interface-readonlymapk-v) is returned; if it does not exist, an exception is thrown.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parameters:

- this @local? - The current `@local?` instance on which the method is called.
- key: K @local? - The key to look up.

Returns:

- V @local? - The value corresponding to the key.

Exceptions:

- [UnimplementedException](../../core/core_package_api/core_package_exceptions.md#class-unimplementedexception) - Thrown when the current type does not provide the corresponding `@local?` implementation.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map: Map<Int64, Int64> @local! = HashMap<Int64, Int64>() @local!
    map.add(1, 10)
    map.add(2, 20)
    let ro: ReadOnlyMap<Int64, Int64> @local? = map
    println("v=${ro[1]}")
}
```

Output:

```text
v=10
```

<!--DelEnd_sink-->

## interface ReadOnlySet\<T>

```cangjie
public interface ReadOnlySet<T> <: Collection<T> {
    func contains(element: T): Bool
    func contains(all!: Collection<T>): Bool
    func subsetOf(other: ReadOnlySet<T>): Bool
}
```

Description: The [ReadOnlySet](collection_package_interface.md#interface-readonlysett) interface provides a set of collection operations, allowing read-only manipulation of internal elements.

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### func contains(T)

```cangjie
func contains(element: T): Bool
```

Description: Returns true if this set contains the specified element.

Parameters:

- element: T - The element to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if contained; otherwise, returns false.

### func contains(Collection\<T>)

```cangjie
func contains(all!: Collection<T>): Bool
```

Description: Checks whether this set contains another collection.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - Another collection.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this set contains the specified collection; otherwise, returns false.

### func subsetOf(ReadOnlySet\<T>)

```cangjie
func subsetOf(other: ReadOnlySet<T>): Bool
```

Description: Checks whether this set is a subset of another set.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - Another set.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this set is a subset of the specified set; otherwise, returns false.

## interface Set\<T>

```cangjie
public interface Set<T> <: ReadOnlySet<T> {
    func add(element: T): Bool
    func add(all!: Collection<T>): Unit
    func remove(element: T): Bool
    func remove(all!: Collection<T>): Unit
    func removeIf(predicate: (T) -> Bool): Unit
    func clear(): Unit
    func retain(all!: Set<T>): Unit
}
```

Description: The [Set](collection_package_interface.md#interface-sett) interface provides a set of collection operations, allowing read-write manipulation of internal elements.

The [Set](collection_package_interface.md#interface-sett) interface does not specify internal implementation. In instances of the [Set](collection_package_interface.md#interface-sett) interface, internal elements are typically unordered, cannot be accessed by index, and do not guarantee insertion order.

Parent Types:

- [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T>

### func add(T)

```cangjie
func add(element: T): Bool
```

Description: Adds an element. If the element already exists, it will not be added.

Parameters:

- element: T - The element to be added.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if added successfully; otherwise, returns false.

### func add(Collection\<T>)

```cangjie
func add(all!: Collection<T>): Unit
```

Description: Adds all elements from the [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont) to this [Set](collection_package_interface.md#interface-sett). Existing elements will not be added.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be added.

### func clear()

```cangjie
func clear(): Unit
```

Description: Clears all key-value pairs.

### func remove(T)

```cangjie
func remove(element: T): Bool
```

Description: Removes the specified element from this set (if present).

Parameters:

- element: T - The element to be removed.

Returns:

- Bool - Returns `true` if the element existed and was removed successfully; otherwise, returns `false`.

### func remove(Collection\<T>)

```cangjie
func remove(all!: Collection<T>): Unit
```

Description: Removes all elements from this [Set](collection_package_interface.md#interface-sett) that are also contained in the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The input [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>.

### func removeIf((T) -> Bool)

```cangjie
func removeIf(predicate: (T) -> Bool): Unit
```

Description: Takes a lambda expression and removes elements that satisfy the `true` condition.

Parameters:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - A lambda expression for evaluation.

### func retain(Set\<T>)

```cangjie
func retain(all!: Set<T>): Unit
```

Description: Retains only the elements in this [Set](collection_package_interface.md#interface-sett) that are also present in the input [Set](collection_package_interface.md#interface-sett).

Parameters:

- all!: [Set](collection_package_interface.md#interface-sett)\<T> - The collection of elements to retain.

## interface Stack\<T>

```cangjie
public interface Stack<T> <: Collection<T> {
    func add(element: T): Unit
    func peek(): ?T
    func remove(): ?T
}
```

Description: A Stack is a data structure that follows the Last In First Out (LIFO) principle. Insertion and deletion operations are performed at one end (called the top), while the other end (called the bottom) remains inactive.

Basic stack operations include push (add), pop (remove), and peek (view the top element).

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### func add(T)

```cangjie
func add(element: T): Unit
```

Description: Adds an element to the stack.

Parameters:

- element: T - The element to be placed at the top of the stack.

### func peek()

```cangjie
func peek(): ?T
```

Description: Views the top element without removing it.

Returns:

- ?T - The top element of the stack. Returns `None` if the stack is empty.

### func remove()

```cangjie
func remove(): ?T
```

Description: Removes and returns the top element of the stack.

Returns:

- ?T - The removed top element. Returns `None` if the stack is empty.