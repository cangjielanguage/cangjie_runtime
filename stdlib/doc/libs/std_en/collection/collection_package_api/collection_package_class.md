# Class

## class ArrayDeque\<T>

```cangjie
public class ArrayDeque<T> <: Deque<T> {
    public init()
    public init(capacity: Int64)
}
```

Function: ArrayDeque is an implementation class of a double-ended queue (deque), allowing insertion and deletion operations at both ends. ArrayDeque is implemented based on a resizable array, with its capacity continuously growing during element insertion, defaulting to a 50% expansion each time. The implementation of ArrayDeque adopts a circular queue approach, ensuring that insertion, deletion, and lookup operations have a time complexity of O(1) without expansion.

Parent Types:

- [Deque](./collection_package_interface.md#interface-dequet)\<T>

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Gets the capacity of this deque.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    
    // Initial capacity is 8
    println("Initial capacity: ${deque.capacity}")  // 8
    
    // Construct with specified capacity
    let deque2 = ArrayDeque<Int64>(16)
    println("Specified capacity: ${deque2.capacity}")  // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Specified capacity: 16
```

### prop first

```cangjie
public prop first: ?T
```

Function: Gets the first element of the deque. Returns None if the deque is empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    
    let first = deque.first
    println("First element: ${first}")  // Some(1)
    
    let emptyDeque = ArrayDeque<String>()
    let noneFirst = emptyDeque.first
    println("First element of empty deque: ${noneFirst}")  // None
    
    return 0
}
```

Output:

```text
First element: Some(1)
First element of empty deque: None
```

### prop last

```cangjie
public prop last: ?T
```

Function: Gets the last element of the deque. Returns None if the deque is empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    
    let last = deque.last
    println("Last element: ${last}")  // Some(2)
    
    let emptyDeque = ArrayDeque<String>()
    let noneLast = emptyDeque.last
    println("Last element of empty deque: ${noneLast}")  // None
    
    return 0
}
```

Output:

```text
Last element: Some(2)
Last element of empty deque: None
```

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of elements in this deque.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    println("Initial size: ${deque.size}")  // 0
    
    deque.addLast(1)
    deque.addLast(2)
    println("Size after adding 2 elements: ${deque.size}")  // 2
    
    deque.removeFirst()
    println("Size after removing 1 element: ${deque.size}")  // 1
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding 2 elements: 2
Size after removing 1 element: 1
```

### init()

```cangjie
public init()
```

Function: Constructs an empty deque with a default capacity of 8.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    println("Initial size: ${deque.size}")      // 0
    println("Initial capacity: ${deque.capacity}")  // 8
    println("Is empty: ${deque.isEmpty()}") // true
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 8
Is empty: true
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs a deque with the specified capacity. If capacity is less than the default capacity of 8, the initial capacity of the constructed [ArrayDeque](#class-arraydequet) will be 8.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified initial capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the parameter is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Specified capacity greater than default
    let deque1 = ArrayDeque<Int64>(16)
    println("Initial capacity with specified 16: ${deque1.capacity}")  // 16
    
    // Specified capacity less than default
    let deque2 = ArrayDeque<Int64>(4)
    println("Initial capacity with specified 4: ${deque2.capacity}")   // 8
    
    return 0
}
```

Output:

```text
Initial capacity with specified 16: 16
Initial capacity with specified 4: 8
```

### func addFirst(T)

```cangjie
public func addFirst(element: T): Unit
```

Function: Inserts an element at the head of this deque.

Parameters:

- element: T - The element to be inserted into this deque.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<String>()
    
    // Add elements at the head
    deque.addFirst("world")
    deque.addFirst("hello")
    
    println("Deque contents: ${deque}")
    println("Deque size: ${deque.size}")
    println("First element: ${deque.first}")
    println("Last element: ${deque.last}")
    
    return 0
}
```

Output:

```text
Deque contents: [hello, world]
Deque size: 2
First element: Some(hello)
Last element: Some(world)
```

### func addLast(T)

```cangjie
public func addLast(element: T): Unit
```

Function: Inserts an element at the tail of this deque.

Parameters:

- element: T - The element to be inserted into this deque.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    println(deque)  // [1, 2]
    return 0
}
```

Output:

```text
[1, 2]
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears all elements from this deque.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>(4)
    deque.addLast(1)
    deque.addLast(2)
    deque.clear()
    println("Is deque empty: ${deque.isEmpty()}")  // true
    return 0
}
```

Output:

```text
Is deque empty: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Gets an iterator over the elements in this deque in front-to-back order.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator over the elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    deque.addLast(3)
    
    // Iterate using for loop
    for (element in deque) {
        println(element)
    }
    return 0
}
```

Output:

```text
1
2
3
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Checks if this deque is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if empty, otherwise `false`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque1 = ArrayDeque<Int64>()
    let deque2 = ArrayDeque<Int64>()
    deque2.addLast(1)
    
    println("Is deque1 empty: ${deque1.isEmpty()}")  // true
    println("Is deque2 empty: ${deque2.isEmpty()}")  // false
    return 0
}
```

Output:

```text
Is deque1 empty: true
Is deque2 empty: false
```

### func removeFirst()

```cangjie
public func removeFirst(): ?T
```

Function: Removes and returns the first element of this deque. Returns `None` if the deque is empty.

Returns:

- ?T - The removed first element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    
    let first = deque.removeFirst()
    println("Removed element: ${first}")  // Some(1)
    println("Deque after removal: ${deque}")  // [2]
    
    let emptyDeque = ArrayDeque<Int64>()
    let noneElement = emptyDeque.removeFirst()
    println("Element removed from empty deque: ${noneElement}")  // None
    return 0
}
```

Output:

```text
Removed element: Some(1)
Deque after removal: [2]
Element removed from empty deque: None
```

### func removeLast()

```cangjie
public func removeLast(): ?T
```

Function: Removes and returns the last element of this deque. Returns `None` if the deque is empty.

Returns:

- ?T - The removed last element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    
    let last = deque.removeLast()
    println("Removed element: ${last}")  // Some(2)
    println("Deque after removal: ${deque}")  // [1]
    
    let emptyDeque = ArrayDeque<Int64>()
    let noneElement = emptyDeque.removeLast()
    println("Element removed from empty deque: ${noneElement}")  // None
    return 0
}
```

Output:

```text
Removed element: Some(2)
Deque after removal: [1]
Element removed from empty deque: None
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Increases the capacity of this deque.

Expands the deque by the additional size. No expansion occurs if additional is less than or equal to zero. If the remaining capacity of this deque is greater than or equal to additional, no expansion occurs. If the remaining capacity is less than additional, the expansion size is the maximum of (1.5 times the original capacity rounded down) and (additional + used capacity).

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to expand by.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    
    // Initial capacity is 8
    println("Initial capacity: ${deque.capacity}")  // 8
    
    // Reserve space
    deque.reserve(10)
    println("Capacity after reserving 10 elements: ${deque.capacity}")  // 12
    
    // Add elements
    for (i in 0..5) {
        deque.addLast(i)
    }
    println("Capacity after adding 5 elements: ${deque.capacity}")   // 12
    println("Size after adding 5 elements: ${deque.size}")       // 5
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Capacity after reserving 10 elements: 12
Capacity after adding 5 elements: 12
Size after adding 5 elements: 5
```

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements of this deque in front-to-back order.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    deque.addLast(3)
    
    let array = deque.toArray()
    println(array)  // [1, 2, 3]
    return 0
}
```

Output:

```text
[1, 2, 3]
```

### extend\<T> ArrayDeque\<T> <: ToString where T <: ToString

```cangjie
extend<T> ArrayDeque<T> <: ToString where T <: ToString
```

Function: Extends [ArrayDeque](./collection_package_class.md#class-arraydequet)\<T> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface, supporting string conversion.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Gets the string representation of the current [ArrayDeque](./collection_package_class.md#class-arraydequet)\<T> instance.

The string contains the string representation of each element in the deque in front-to-back order, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let deque = ArrayDeque<Int64>()
    deque.addLast(1)
    deque.addLast(2)
    deque.addLast(3)
    println(deque.toString())  // [1, 2, 3]
    return 0
}
```

Output:

```text
[1, 2, 3]
```

## class ArrayList\<T>

```cangjie
public class ArrayList<T> <: List<T> {
    public init()
    public init(capacity: Int64)
    public init(size: Int64, initElement: (Int64) -> T)
    public init(elements: Collection<T>)
}
```

Function: Provides the capability of a resizable array.

[ArrayList](collection_package_class.md#class-arraylistt) is a linear dynamic array that differs from [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) by automatically resizing as needed and not requiring size specification upon creation.

> **Note:**
>
> - When adding elements to a dynamic array, if the array is full, it will reallocate a larger memory space and copy existing elements to the new space.
>
> - The advantages of dynamic arrays include memory efficiency and automatic resizing, making them ideal for scenarios requiring frequent element additions or removals. However, the drawback is potential performance degradation during memory reallocation, which should be considered when using dynamic arrays.

Parent Types:

- [List](./collection_package_interface.md#interface-listt)\<T>

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of elements in this [ArrayList](collection_package_class.md#class-arraylistt).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    println("Initial size: ${list.size}")  // 0
    
    list.add(1)
    list.add(2)
    println("Size after adding 2 elements: ${list.size}")  // 2
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding 2 elements: 2
```

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Returns the capacity of this [ArrayList](collection_package_class.md#class-arraylistt).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    println("Initial capacity: ${list.capacity}")  // 16
    
    // Add elements until resizing occurs
    for (i in 0..17) {
        list.add(i)
    }
    println("Capacity after adding 17 elements: ${list.capacity}")  // 24
    
    return 0
}
```

Output:

```text
Initial capacity: 16
Capacity after adding 17 elements: 24
```

### prop first

```cangjie
public prop first: ?T
```

Function: Returns the first element of this [ArrayList](collection_package_class.md#class-arraylistt), or None if empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    
    let first = list.first
    println("First element: ${first}")  // Some(1)
    
    let emptyList = ArrayList<String>()
    let noneFirst = emptyList.first
    println("First element of empty list: ${noneFirst}")  // None
    
    return 0
}
```

Output:

```text
First element: Some(1)
First element of empty list: None
```

### prop last

```cangjie
public prop last: ?T
```

Function: Returns the last element of this [ArrayList](collection_package_class.md#class-arraylistt), or None if empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    
    let last = list.last
    println("Last element: ${last}")  // Some(2)
    
    let emptyList = ArrayList<String>()
    let noneLast = emptyList.last
    println("Last element of empty list: ${noneLast}")  // None
    
    return 0
}
```

Output:

```text
Last element: Some(2)
Last element of empty list: None
```

### init()

```cangjie
public init()
```

Function: Constructs an [ArrayList](collection_package_class.md#class-arraylistt) with a default initial capacity of `16`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    println("Initial size: ${list.size}")      // 0
    println("Initial capacity: ${list.capacity}")  // 16
    println("Is empty: ${list.isEmpty()}") // true
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 16
Is empty: true
```

### init(Collection\<T>)

```cangjie
public init(elements: Collection<T>)
```

Function: Constructs an [ArrayList](collection_package_class.md#class-arraylistt) containing all elements from the specified collection, maintaining the order returned by the collection's iterator.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The input collection.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let array = [1, 2, 3]
    let list = ArrayList<Int64>(array)
    println("List contents: ${list}")  // [1, 2, 3]
    println("List size: ${list.size}")  // 3
    return 0
}
```

Output:

```text
List contents: [1, 2, 3]
List size: 3
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs an [ArrayList](collection_package_class.md#class-arraylistt) with the specified initial capacity.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The specified initial capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the capacity is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Capacity larger than default
    let list1 = ArrayList<Int64>(32)
    println("Initial capacity with 32: ${list1.capacity}")  // 32
    
    // Capacity smaller than default
    let list2 = ArrayList<Int64>(8)
    println("Initial capacity with 8: ${list2.capacity}")   // 8
    
    return 0
}
```

Output:

```text
Initial capacity with 32: 32
Initial capacity with 8: 8
```

### init(Int64, (Int64) -> T)

```cangjie
public init(size: Int64, initElement: (Int64) -> T)
```

Function: Constructs an [ArrayList](collection_package_class.md#class-arraylistt) with the specified number of initial elements and initialization function. The constructor sets the capacity based on the `size` parameter.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of initial elements.
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) ->T - The initialization function.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if `size` is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a list with 5 elements, each being the square of its index
    let list = ArrayList<Int64>(5, {
        index: Int64 => 
        index * index
    })
    
    println("List contents: ${list}")  // [0, 1, 4, 9, 16]
    println("List size: ${list.size}")  // 5
    
    return 0
}
```

Output:

```text
List contents: [0, 1, 4, 9, 16]
List size: 5
```

### static func of(Array\<T>)

```cangjie
public static func of(elements: Array<T>): ArrayList<T>
```

Function: Constructs an [ArrayList](collection_package_class.md#class-arraylistt) containing all elements from the specified array.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - The input array (varargs syntax allows omitting array literal `[]`).

Returns:

- [ArrayList](#class-arraylistt)\<T> - An ArrayList containing elements of type T.

> **Note:**
>
> This function supports varargs syntax. For example, `ArrayList.of(1, 2, 3)` is equivalent to `ArrayList.of([1, 2, 3])`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let array = [1, 2, 3, 4, 5]
    let list = ArrayList<Int64>.of(array)
    
    println("Array: ${array}")      // [1, 2, 3, 4, 5]
    println("List: ${list}")       // [1, 2, 3, 4, 5]
    println("List size: ${list.size}")  // 5
    
    return 0
}
```

Output:

```text
Array: [1, 2, 3, 4, 5]
List: [1, 2, 3, 4, 5]
List size: 5
```

### func add(T)

```cangjie
public func add(element: T): Unit
```

Function: Appends the specified element to the end of this [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- element: T - The element to append, of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    println("List contents: ${list}")  // [1, 2, 3]
    println("List size: ${list.size}")  // 3
    
    return 0
}
```

Execution Result:

```text
List content: [1, 2, 3]
List size: 3
```

### func add(Collection\<T>)

```cangjie
public func add(all!: Collection<T>): Unit
```

Function: Appends all elements from the specified collection to the end of this [ArrayList](collection_package_class.md#class-arraylistt).

The function iterates through the input collection in iterator order and inserts all elements to the tail of this [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be inserted.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    
    // Create another list as Collection
    let newElements = ArrayList<Int64>()
    newElements.add(3)
    newElements.add(4)
    newElements.add(5)
    
    // Append new elements to the original list
    list.add(all: newElements)
    
    println("List contents: ${list}")  // [1, 2, 3, 4, 5]
    println("List size: ${list.size}")  // 5
    
    return 0
}
```

Output:

```text
List contents: [1, 2, 3, 4, 5]
List size: 5
```

### func add(T, Int64)

```cangjie
public func add(element: T, at!: Int64): Unit
```

Function: Inserts the specified element at the specified position in this [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- element: T - The element of type T to be inserted.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index for insertion.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when 'at' is out of bounds.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(3)
    
    // Insert element 2 at index 1
    list.add(2, at: 1)
    
    println("List contents: ${list}")  // [1, 2, 3]
    println("List size: ${list.size}")  // 3
    
    return 0
}
```

Output:

```text
List contents: [1, 2, 3]
List size: 3
```

### func add(Collection\<T>, Int64)

```cangjie
public func add(all!: Collection<T>, at!: Int64): Unit
```

Function: Inserts all elements from the specified collection into this [ArrayList](collection_package_class.md#class-arraylistt) starting from the specified position.

The function iterates through the input collection in iterator order and inserts all elements at the specified position, shifting existing elements (if any) to the right.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be inserted.
- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The target index for insertion.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when 'at' is out of bounds.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(5)
    
    // Insert collection [2, 3, 4] at index 1
    let elements = ArrayList<Int64>()
    elements.add(2)
    elements.add(3)
    elements.add(4)
    list.add(all: elements, at: 1)
    
    println("List contents: ${list}")  // [1, 2, 3, 4, 5]
    println("List size: ${list.size}")  // 5
    
    return 0
}
```

Output:

```text
List contents: [1, 2, 3, 4, 5]
List size: 5
```

### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

Function: Determines whether all elements in this [ArrayList](collection_package_class.md#class-arraylistt) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements satisfy the condition, otherwise false.

### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

Function: Determines whether any element in this [ArrayList](collection_package_class.md#class-arraylistt) satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if any element satisfies the condition.

### func clear()

```cangjie
public func clear(): Unit
```

Function: Removes all elements from this [ArrayList](collection_package_class.md#class-arraylistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    println("List contents before clearing: ${list}")  // [1, 2, 3]
    println("List size before clearing: ${list.size}")  // 3
    
    list.clear()
    
    println("List contents after clearing: ${list}")  // []
    println("List size after clearing: ${list.size}")  // 0
    println("Is list empty: ${list.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
List contents before clearing: [1, 2, 3]
List size before clearing: 3
List contents after clearing: []
List size after clearing: 0
Is list empty: true
```

### func clone()

```cangjie
public func clone(): ArrayList<T>
```

Function: Returns a shallow copy of this [ArrayList](collection_package_class.md#class-arraylistt) instance.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - A new [ArrayList](collection_package_class.md#class-arraylistt)\<T>.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let originalList = ArrayList<Int64>()
    originalList.add(1)
    originalList.add(2)
    originalList.add(3)
    
    // Clone the list
    let clonedList = originalList.clone()
    
    println("Original list: ${originalList}")  // [1, 2, 3]
    println("Cloned list: ${clonedList}")    // [1, 2, 3]
    
    // Modifying original list doesn't affect cloned list
    originalList.add(4)
    println("Modified original list: ${originalList}")  // [1, 2, 3, 4]
    println("Cloned list remains unchanged: ${clonedList}")    // [1, 2, 3]
    
    return 0
}
```

Output:

```text
Original list: [1, 2, 3]
Cloned list: [1, 2, 3]
Modified original list: [1, 2, 3, 4]
Cloned list remains unchanged: [1, 2, 3]
```

### func filter((T) -> Bool)
```cangjie
public func filter(predicate: (T) -> Bool): ArrayList<T>
```

Function: Returns a new [ArrayList](collection_package_class.md#class-arraylistt)\<T> containing elements that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - A new collection containing elements that satisfy the condition.

### func filterMap\<R>((T) -> ?R)

```cangjie
public func filterMap<R>(transform: (T) -> ?R): ArrayList<R>
```

Function: Performs both filtering and mapping operations, returning a new [ArrayList](collection_package_class.md#class-arraylistt).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> ?R - The mapping function. A return value of Some corresponds to predicate being true, None corresponds to false.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<R> - A new filtered and mapped [ArrayList](collection_package_class.md#class-arraylistt).

### func flatMap\<R>((T) -> ArrayList\<R>)

```cangjie
public func flatMap<R>(transform: (T) -> ArrayList<R>): ArrayList<R>
```

Function: Applies a transform closure to each element of this [ArrayList](collection_package_class.md#class-arraylistt), where the closure returns a new [ArrayList](collection_package_class.md#class-arraylistt), then flattens and concatenates all returned ArrayLists into a single result [ArrayList](collection_package_class.md#class-arraylistt).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> [ArrayList](collection_package_class.md#class-arraylistt)\<R> - The mapping function.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<R> - A new "mapped" and "flattened" [ArrayList](collection_package_class.md#class-arraylistt).

### func fold\<R>(R, (R, T) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, T) -> R): R
```

Function: Accumulates values starting from the specified initial value, processing elements from left to right.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The initial value of type R.
- operation: (R, T) -> R - The accumulation function.

Returns:

- R - The final accumulated value.

### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

Function: Performs the given action on each element.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The action to be performed.

### func get(Int64)

```cangjie
public func get(index: Int64): ?T
```

Function: Returns the element at the specified position in this [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to return.

Returns:

- ?T - The element at the specified position, or None if index is less than 0 or greater than or equal to the number of elements in this [ArrayList](collection_package_class.md#class-arraylistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(10)
    list.add(20)
    list.add(30)
    
    // Get element at valid index
    let element = list.get(1)
    println("Element at index 1: ${element}")  // Some(20)
    
    // Get element at invalid index
    let noneElement = list.get(5)
    println("Element at index 5: ${noneElement}")  // None
    
    return 0
}
```

Output:

```text
Element at index 1: Some(20)
Element at index 5: None
```

### func getRawArray()

```cangjie
public unsafe func getRawArray(): Array<T>
```

Function: Returns the raw underlying data of this [ArrayList](collection_package_class.md#class-arraylistt).

> **Warning:**
>
> This is an unsafe interface and must be used within an unsafe context.
>
> The raw data refers to the underlying array implementation of [ArrayList](collection_package_class.md#class-arraylistt), whose size may be larger than the number of elements in the [ArrayList](collection_package_class.md#class-arraylistt). Accessing elements at indices greater than or equal to the size of the [ArrayList](collection_package_class.md#class-arraylistt) may contain uninitialized elements and could result in undefined behavior.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - The underlying raw data of this [ArrayList](collection_package_class.md#class-arraylistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    // Get raw array
    unsafe {
        let rawArray = list.getRawArray()
        println("Raw array: ${rawArray}")
        println("Raw array size: ${rawArray.size}")  // May be larger than list size
    }
    
    return 0
}
```

Output:

```text
Raw array: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Raw array size: 16
```

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    // Get raw array
    unsafe {
        let rawArray = list.getRawArray()
        println("Raw array: ${rawArray}")
        println("Raw array size: ${rawArray.size}")  // May be larger than list size
    }
    
    return 0
}
```

Output:

```text
Raw array: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Raw array size: 16
```

### func intersperse(T)

```cangjie
public func intersperse(separator: T): ArrayList<T> 
```

Function: Returns a new [ArrayList](collection_package_class.md#class-arraylistt) with the given element inserted between every two existing elements.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- separator: T - The element to be inserted.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt).

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the [ArrayList](collection_package_class.md#class-arraylistt) is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if empty, otherwise returns `false`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let emptyList = ArrayList<Int64>()
    let nonEmptyList = ArrayList<Int64>()
    nonEmptyList.add(1)
    
    println("Is empty list empty: ${emptyList.isEmpty()}")      // true
    println("Is non-empty list empty: ${nonEmptyList.isEmpty()}")  // false
    
    return 0
}
```

Output:

```text
Is empty list empty: true
Is non-empty list empty: false
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Returns an iterator over the elements in this [ArrayList](collection_package_class.md#class-arraylistt).

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator over the elements in the [ArrayList](collection_package_class.md#class-arraylistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    // Traverse the list using an iterator
    let iter = list.iterator()
    println(iter.next().getOrThrow())
    println(iter.next().getOrThrow())
    println(iter.next().getOrThrow())
    
    return 0
}
```

Output:

```text
1
2
3
```

### func map\<R>((T) -> R)

```cangjie
public func map<R>(transform: (T) -> R): ArrayList<R>
```

Function: Applies a transformation to this [ArrayList](collection_package_class.md#class-arraylistt) and returns a new [ArrayList](collection_package_class.md#class-arraylistt).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) ->R - The transformation function to apply.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<R> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt).

### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

Function: Determines whether none of the elements in the [ArrayList](collection_package_class.md#class-arraylistt) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to test against.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the elements in the current [ArrayList](collection_package_class.md#class-arraylistt) satisfy the condition.

### func reduce((T, T) -> T)

```cangjie
public func reduce(operation: (T, T) -> T): Option<T>
```

Function: Computes from left to right using the first element as the initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (T, T) -> T - The computation function to apply.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - Returns the computation result.

### func remove(Int64)

```cangjie
public func remove(at!: Int64): T
```

Function: Removes the element at the specified position in this [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- at!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element to be removed.

Returns:

- T - The removed element.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when `at` is out of bounds.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    // Remove the element at index 1
    let removedElement = list.remove(at: 1)
    
    println("Removed element: ${removedElement}")  // 2
    println("List after removal: ${list}")         // [1, 3]
    println("List size after removal: ${list.size}") // 2
    
    return 0
}
```

Output:

```text
Removed element: 2
List after removal: [1, 3]
List size after removal: 2
```

### func remove(Range\<Int64>)

```cangjie
public func remove(range: Range<Int64>): Unit
```

Function: Removes all elements in the specified [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) from this [ArrayList](collection_package_class.md#class-arraylistt).

> **Note:**
>
> If the parameter `range` is constructed using the [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor: The `start` value is exactly the value passed to the constructor, unaffected by the `hasStart` parameter. When `hasEnd` is `false`, the `end` value is ignored (regardless of the `isClosed` parameter), and the slice includes all elements up to the last element of the original array.

Parameters:

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The range of elements to be removed.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `range.[step](collection_package_function.md#func-steptint64)` is not equal to 1.
- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when `range.start` or `range.end` is less than 0, or when `range.end` exceeds the length of the [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..6) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3, 4, 5, 6]
    
    // Remove elements from index 1 to 3 (exclusive)
    list.remove(1..3)
    
    println("List after removal: ${list}")      // [0, 3, 4, 5]
    println("List size after removal: ${list.size}") // 4
    
    return 0
}
```

Output:

```text
List after removal: [0, 3, 4, 5]
List size after removal: 4
```

### func removeIf((T) -> Bool)

```cangjie
public func removeIf(predicate: (T) -> Bool): Unit
```

Function: Removes all elements from this [ArrayList](collection_package_class.md#class-arraylistt) that satisfy the given lambda or function.

Parameters:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to determine which elements to remove.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when elements are added or removed within `predicate`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..6) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3, 4, 5, 6]
    
    // Remove all even elements
    list.removeIf({element: Int64 =>
        element % 2 == 0
    })
    
    println("List after removing evens: ${list}")      // [1, 3, 5]
    println("List size after removal: ${list.size}") // 3
    
    return 0
}
```

Output:

```text
List after removing evens: [1, 3, 5]
List size after removal: 3
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Increases the capacity of this [ArrayList](collection_package_class.md#class-arraylistt) instance.

Expands the [ArrayList](collection_package_class.md#class-arraylistt) by `additional` size. No expansion occurs if `additional` is less than or equal to zero. If the remaining capacity of the [ArrayList](collection_package_class.md#class-arraylistt) is greater than or equal to `additional`, no expansion occurs. If the remaining capacity is less than `additional`, the new capacity is set to the maximum of (1.5 times the original capacity, rounded down) or (`additional` + current size).

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The additional capacity to reserve.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when `additional` + current size exceeds `Int64.Max`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    
    // Initial capacity is 16
    println("Initial capacity: ${list.capacity}")  // 16
    
    // Reserve additional space
    list.reserve(20)
    println("Capacity after reserving 20 elements: ${list.capacity}")  // 24
    
    // Add elements
    for (i in 0..10) {
        list.add(i)
    }
    println("Capacity after adding 10 elements: ${list.capacity}")   // 24
    println("Size after adding 10 elements: ${list.size}")       // 10
    
    return 0
}
```

Output:

```text
Initial capacity: 16
Capacity after reserving 20 elements: 24
Capacity after adding 10 elements: 24
Size after adding 10 elements: 10
```

### func reverse()

```cangjie
public func reverse(): Unit
```

Function: Reverses the order of elements in this [ArrayList](collection_package_class.md#class-arraylistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..4) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3]
    println("Before reversal: ${list}")  // [0, 1, 2, 3]
    
    // Reverse the list
    list.reverse()
    
    println("After reversal: ${list}")  // [3, 2, 1, 0]
    
    return 0
}
```

Output:

```text
Before reversal: [0, 1, 2, 3]
After reversal: [3, 2, 1, 0]
```

### func slice(Range\<Int64>)

```cangjie
public func slice(range: Range<Int64>): ArrayList<T>
```

Function: Returns a new [ArrayList](collection_package_class.md#class-arraylistt)\<T> containing elements at the indices specified by `range`.

> **Note:**
>
> If the parameter `range` is constructed using the [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor:
>
> 1. The `start` value is exactly the value passed to the constructor, unaffected by the `hasStart` parameter.
> 2. When `hasEnd` is `false`, the `end` value is ignored (regardless of the `isClosed` parameter), and the slice includes all elements up to the last element of the original array.

Parameters:

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The range to slice.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - The sliced array.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `range.[step](collection_package_function.md#func-steptint64)` is not equal to 1.
- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when `range` is invalid.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..6) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3, 4, 5]
    
    println("Original list: ${list}")  // [0, 1, 2, 3, 4, 5]
    
    // Slice using range operator
    let sliceList = list[1..4]
    
    println("Sliced list: ${sliceList}")     // [1, 2, 3]
    println("Sliced list size: ${sliceList.size}") // 3
    
    return 0
}
```

Output:

```text
Original list: [0, 1, 2, 3, 4, 5]
Sliced list: [1, 2, 3]
Sliced list size: 3
```

### func skip(Int64)

```cangjie
public func skip(count: Int64): ArrayList<T>
```

Function: Skips a specified number of elements and returns a new [ArrayList](collection_package_class.md#class-arraylistt).

Throws an exception when count is less than or equal to 0. When count equals 0, it effectively skips no elements and returns a new [ArrayList](collection_package_class.md#class-arraylistt) containing all elements of the source [ArrayList](collection_package_class.md#class-arraylistt). When count is greater than 0 but less than the size of the source [ArrayList](collection_package_class.md#class-arraylistt), it skips the first count elements and returns a new [ArrayList](collection_package_class.md#class-arraylistt) containing the remaining elements. When count is greater than or equal to the size of the [ArrayList](collection_package_class.md#class-arraylistt), it returns an empty [ArrayList](collection_package_class.md#class-arraylistt).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to skip.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt) with the specified number of elements skipped.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count < 0.

### func sortBy((T, T) -> Ordering) <sup>(deprecated)</sup>

```cangjie
public func sortBy(comparator!: (T, T) -> Ordering): Unit
```

Function: Performs an unstable sort on the elements of the array.

Using the provided comparator function, the array can be custom-sorted based on the return value of type [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering). If the comparator returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).GT, t1 will be placed after t2 after sorting. If it returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).LT, t1 will be placed before t2. If it returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).EQ and the sort is stable, t1 will remain before t2. If the sort is unstable, the order of t1 and t2 is indeterminate.

> **Note:**
>
> This method will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Parameters:

- comparator!: (T, T) -> [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering) - A function of type (T, T) -> [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Sort in descending order
    list.sortBy(comparator: {a: Int64, b: Int64 => 
        if (a > b) {
            return Ordering.GT
        } else if (a < b) {
            return Ordering.LT
        } else {
            return Ordering.EQ
        }
    })
    
    println("After sorting: ${list}")  // [4, 3, 2, 1]
    
    return 0
}
```

Output:

```text
Before sorting: [3, 1, 4, 2]
After sorting: [1, 2, 3, 4]
```

### func sortBy(Bool, (T, T) -> Ordering) <sup>(deprecated)</sup>

```cangjie
public func sortBy(stable!: Bool, comparator!: (T, T) -> Ordering): Unit
```

Function: Sorts the elements of the array.

Using the provided comparator function, the array can be custom-sorted based on the return value of type [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering). If the comparator returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).GT, t1 will be placed after t2 after sorting. If it returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).LT, t1 will be placed before t2. If it returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).EQ and the sort is stable, t1 will remain before t2. If the sort is unstable, the order of t1 and t2 is indeterminate.

> **Note:**
>
> This method will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Parameters:

- stable!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to use stable sorting.
- comparator!: (T, T) -> [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering) - A function of type (T, T) -> [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Stable sort in descending order
    list.sortBy(stable: true, comparator: {a: Int64, b: Int64 =>
        if (a < b) {
            return Ordering.GT
        } else if (a > b) {
            return Ordering.LT
        } else {
            return Ordering.EQ
        }
    })
    
    println("After stable sorting: ${list}")  // [4, 3, 2, 1]
    
    return 0
}
```

Output:

```text
Before sorting: [3, 1, 4, 2]
After stable sorting: [4, 3, 2, 1]
```

### func step(Int64)
```cangjie
public func step(count: Int64): ArrayList<T>
```

Function: Extracts elements from the [ArrayList](collection_package_class.md#class-arraylistt) at specified intervals and returns a new [ArrayList](collection_package_class.md#class-arraylistt).

Throws an exception when count is less than or equal to 0.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The extraction interval.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - A new [ArrayList](collection_package_class.md#class-arraylistt) containing elements extracted from the source [ArrayList](collection_package_class.md#class-arraylistt) at the specified intervals.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count <= 0.

### func take(Int64)
```cangjie
public func take(count: Int64): ArrayList<T>
```

Function: Takes a specified number of elements from the array and returns a new array.

Throws an exception when count is less than or equal to 0. When count equals 0, no elements are taken, and an empty array is returned. When count is greater than 0 but less than the size of the source array, the first count elements are taken and returned in a new array. When count is greater than or equal to the size of the array, all elements are taken and returned in a new array.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to take.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt) with the specified number of elements taken.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count < 0.

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements of this list in proper sequence.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..4) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3]
    println("List: ${list}")  // [0, 1, 2, 3]
    
    // Convert to array
    let array = list.toArray()
    
    println("Array: ${array}")      // [0, 1, 2, 3]
    println("Array size: ${array.size}") // 4
    
    return 0
}
```

Output:

```text
List: [0, 1, 2, 3]
Array: [0, 1, 2, 3]
Array size: 4
```

### operator func [](Int64)

```cangjie
public operator func [](index: Int64): T
```

Function: Operator overload - get.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index for the get operation.

Returns:

- T - The value of the element at the specified index.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when index is out of bounds.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(10)
    list.add(20)
    list.add(30)
    
    // Access element by index
    let element = list[1]
    println("Element at index 1: ${element}")  // 20
    
    // Modify element at index
    list[1] = 25
    println("Modified element at index 1: ${list[1]}")  // 25
    println("Modified list: ${list}")           // [10, 25, 30]
    
    return 0
}
```

Output:

```text
Element at index 1: 20
Modified element at index 1: 25
Modified list: [10, 25, 30]
```

### operator func [](Int64, T)

```cangjie
public operator func [](index: Int64, value!: T): Unit
```

Function: Operator overload - replaces the element at the specified position in this list with the specified element.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index to set.
- value!: T - The value of type T to set.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when index is out of bounds.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(10)
    list.add(20)
    list.add(30)
    
    println("List before modification: ${list}")  // [10, 20, 30]
    
    // Modify element by index
    list[1] = 25
    
    println("List after modification: ${list}")  // [10, 25, 30]
    println("Element at index 1: ${list[1]}") // 25
    
    return 0
}
```

Output:

```text
List before modification: [10, 20, 30]
List after modification: [10, 25, 30]
Element at index 1: 25
```

### operator func [](Range\<Int64>)

```cangjie
public operator func [](range: Range<Int64>): ArrayList<T>
```

Function: Operator overload - slice.

> **Note:**
>
> - If the parameter range is a [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instance constructed using the [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor:
>     - The value of start is the value passed to the constructor itself, unaffected by the hasStart value during construction.
>     - When hasEnd is false, the end value is not effective, and the array slice includes elements up to the last element of the original array, regardless of the isClosed value during construction.
>
> - The [ArrayList](collection_package_class.md#class-arraylistt) returned by the slice operation is a completely new object with no reference to the original [ArrayList](collection_package_class.md#class-arraylistt).

Parameters:

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The range for slicing.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<T> - The sliced array.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when range.[step](collection_package_function.md#func-steptint64) is not equal to 1.
- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when the range is invalid.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    for (i in 0..5) {
        list.add(i)
    }
    // list is now [0, 1, 2, 3, 4]
    
    println("Original list: ${list}")  // [0, 1, 2, 3, 4]
    
    // Slice using range operator
    let sliceList = list[1..4]
    
    println("Sliced list: ${sliceList}")        // [1, 2, 3]
    println("Sliced list size: ${sliceList.size}") // 3
    
    return 0
}
```

Output:

```text
Original list: [0, 1, 2, 3, 4]
Sliced list: [1, 2, 3]
Sliced list size: 3
```

### extend\<T> ArrayList\<T>

```cangjie
extend<T> ArrayList<T>
```

Function: Extends the [ArrayList](collection_package_class.md#class-arraylistt)\<T> type.

#### func enumerate()

```cangjie
public func enumerate(): ArrayList<(Int64, T)>
```

Function: Returns an [ArrayList](collection_package_class.md#class-arraylistt) with indices.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<([Int64](../../core/core_package_api/core_package_intrinsics.md#int64), T)> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt) with indices.

#### func zip\<R>(ArrayList\<R>)

```cangjie
public func zip<R>(other: ArrayList<R>): ArrayList<(T, R)>
```

Function: Merges two [ArrayList](collection_package_class.md#class-arraylistt)s into a new [ArrayList](collection_package_class.md#class-arraylistt) (length determined by the shorter [ArrayList](collection_package_class.md#class-arraylistt)).


> **Note：**
>
> Unsupported platform：OpenHarmony

Parameters:

- other: [ArrayList](collection_package_class.md#class-arraylistt)\<R> - One of the [ArrayList](collection_package_class.md#class-arraylistt)s to merge.

Returns:

- [ArrayList](collection_package_class.md#class-arraylistt)\<(T, R)> - Returns a new [ArrayList](collection_package_class.md#class-arraylistt).### extend\<T> ArrayList\<T> <: Equatable\<ArrayList\<T>> where T <: Equatable\<T>

```cangjie
extend<T> ArrayList<T> <: Equatable<ArrayList<T>> where T <: Equatable<T>
```

Function: Extends the [ArrayList](./collection_package_class.md#class-arraylistt)\<T> type with the [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[ArrayList](./collection_package_class.md#class-arraylistt)\<T>> interface to support equality comparison operations.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[ArrayList](#class-arraylistt)\<T>>

#### operator func ==(ArrayList\<T>)

```cangjie
public operator func ==(that: ArrayList<T>): Bool
```

Function: Determines whether the current instance is equal to the [ArrayList](./collection_package_class.md#class-arraylistt) instance pointed to by the parameter.

Two arrays are considered equal if their corresponding elements at each position are equal.

Parameters:

- that: [ArrayList](./collection_package_class.md#class-arraylistt)\<T> - The object to be compared.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list1 = ArrayList<Int64>()
    list1.add(1)
    list1.add(2)
    list1.add(3)
    
    let list2 = ArrayList<Int64>()
    list2.add(1)
    list2.add(2)
    list2.add(3)
    
    let list3 = ArrayList<Int64>()
    list3.add(1)
    list3.add(2)
    
    println("list1 == list2: ${list1 == list2}")  // true
    println("list1 == list3: ${list1 == list3}")  // false
    
    return 0
}
```

Execution Result:

```text
list1 == list2: true
list1 == list3: false
```

#### operator func !=(ArrayList\<T>)

```cangjie
public operator func !=(that: ArrayList<T>): Bool
```

Function: Determines whether the current instance is not equal to the [ArrayList](./collection_package_class.md#class-arraylistt) instance pointed to by the parameter.

Parameters:

- that: [ArrayList](./collection_package_class.md#class-arraylistt)\<T> - The object to be compared.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list1 = ArrayList<Int64>()
    list1.add(1)
    list1.add(2)
    list1.add(3)
    
    let list2 = ArrayList<Int64>()
    list2.add(1)
    list2.add(2)
    
    let list3 = ArrayList<Int64>()
    list3.add(1)
    list3.add(2)
    list3.add(3)
    
    println("list1 != list2: ${list1 != list2}")  // true
    println("list1 != list3: ${list1 != list3}")  // false
    
    return 0
}
```

Execution Result:

```text
list1 != list2: true
list1 != list3: false
```

#### func contains(T)

```cangjie
public func contains(element: T): Bool
```

Function: Determines whether the current array contains the specified element `element`.

Parameters:

- element: T - The element to search for.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the array contains the specified element, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    println("List contains element 2: ${list.contains(2)}")  // true
    println("List contains element 5: ${list.contains(5)}")  // false
    
    return 0
}
```

Execution Result:

```text
List contains element 2: true
List contains element 5: false
```

### extend\<T> ArrayList\<T> <: SortExtension where T <: Comparable\<T> <sup>(deprecated)</sup>

```cangjie
extend<T> ArrayList<T> where T <: Comparable<T>
```

Function: Extends the [ArrayList](./collection_package_class.md#class-arraylistt)\<T> with the [SortExtension](../../sort/sort_package_api/sort_package_interfaces.md#interface-sortextension-deprecated) interface to support array sorting.

> **Note:**
>
> This will be deprecated in future versions.

Parent Types:

- [SortExtension](../../sort/sort_package_api/sort_package_interfaces.md#interface-sortextension-deprecated)

#### func sort() <sup>(deprecated)</sup>

```cangjie
public func sort(): Unit
```

Function: Sorts the elements in the current array in ascending order using an unstable sort.

> **Note:**
>
> This will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Sort in ascending order
    list.sort()
    
    println("After sorting: ${list}")  // [1, 2, 3, 4]
    
    return 0
}
```

Execution Result:

```text
Before sorting: [3, 1, 4, 2]
After sorting: [1, 2, 3, 4]
```

#### func sort(Bool) <sup>(deprecated)</sup>

```cangjie
public func sort(stable!: Bool): Unit
```

Function: Sorts the elements in the current array in ascending order.

Parameters:

- stable!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to use a stable sort.

> **Note:**
>
> This will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Sort in ascending order using stable sort
    list.sort(stable: true)
    
    println("After stable sorting: ${list}")  // [1, 2, 3, 4]
    
    return 0
}
```

Execution Result:

```text
Before sorting: [3, 1, 4, 2]
After stable sorting: [1, 2, 3, 4]
```

#### func sortDescending() <sup>(deprecated)</sup>

```cangjie
public func sortDescending(): Unit
```

Function: Sorts the elements in the current array in descending order using an unstable sort.

> **Note:**
>
> This will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Sort in descending order
    list.sortDescending()
    
    println("After descending sort: ${list}")  // [4, 3, 2, 1]
    
    return 0
}
```

Execution Result:

```text
Before sorting: [3, 1, 4, 2]
After descending sort: [4, 3, 2, 1]
```

#### func sortDescending(Bool) <sup>(deprecated)</sup>

```cangjie
public func sortDescending(stable!: Bool): Unit
```

Function: Sorts the elements in the current array in descending order.

Parameters:

- stable!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to use a stable sort.

> **Note:**
>
> This will be deprecated in future versions. Use [sort](../../sort/sort_package_api/sort_package_funcs.md#func-sorttlistt-bool-bool-where-t--comparablet) instead.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(3)
    list.add(1)
    list.add(4)
    list.add(2)
    // list is now [3, 1, 4, 2]
    println("Before sorting: ${list}")  // [3, 1, 4, 2]
    
    // Sort in descending order using stable sort
    list.sortDescending(stable: true)
    
    println("After stable descending sort: ${list}")  // [4, 3, 2, 1]
    
    return 0
}
```

Execution Result:

```text
Before sorting: [3, 1, 4, 2]
After stable descending sort: [4, 3, 2, 1]
```

### extend\<T> ArrayList\<T> <: ToString where T <: ToString

```cangjie
extend<T> ArrayList<T> <: ToString where T <: ToString
```

Function: Extends the [ArrayList](./collection_package_class.md#class-arraylistt)\<T> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface to support string conversion operations.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current array to a string.

The resulting string contains the string representation of each element in the array, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = ArrayList<Int64>()
    list.add(1)
    list.add(2)
    list.add(3)
    
    let str = list.toString()
    
    println("List: ${list}")     // [1, 2, 3]
    println("String: ${str}")    // [1, 2, 3]
    println("String length: ${str.size}") // 9
    
    return 0
}
```

Execution Result:

```text
List: [1, 2, 3]
String: [1, 2, 3]
String length: 9
```

## class ArrayQueue\<T>

```cangjie
public class ArrayQueue<T> <: Queue<T> {
    public init()
    public init(capacity: Int64)
}
```

Function: A circular queue data structure implemented based on arrays.

Parent Types:

- [Queue](./collection_package_interface.md#interface-queuet)\<T>

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Gets the capacity of this queue.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Initial capacity is 8
    println("Initial capacity: ${queue.capacity}")  // 8
    
    // Constructor with specified capacity
    let queue2 = ArrayQueue<Int64>(16)
    println("Specified capacity: ${queue2.capacity}")  // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Specified capacity: 16
```

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of elements in this queue.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Initial size is 0
    println("Initial size: ${queue.size}")  // 0
    
    // Size changes after adding elements
    queue.add(1)
    queue.add(2)
    println("Size after adding elements: ${queue.size}")  // 2
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding elements: 2
```

### init()

```cangjie
public init()
```

Function: Constructs an empty queue with default capacity of 8.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create queue using default constructor
    let queue = ArrayQueue<Int64>()
    
    println("Initial size: ${queue.size}")      // 0
    println("Initial capacity: ${queue.capacity}")  // 8
    println("Is empty: ${queue.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 8
Is empty: true
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs a queue with specified capacity. When capacity is less than the default capacity of 8, the initial capacity of [ArrayQueue](#class-arrayqueuet) will be 8.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Specified initial capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws exception if parameter is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Capacity larger than default
    let queue1 = ArrayQueue<Int64>(16)
    println("Queue capacity with specified 16: ${queue1.capacity}")  // 16
    
    // Capacity smaller than default
    let queue2 = ArrayQueue<Int64>(4)
    println("Queue capacity with specified 4: ${queue2.capacity}")   // 8
    
    // Test adding elements
    queue2.add(1)
    queue2.add(2)
    println("Size after adding elements: ${queue2.size}")  // 2
    
    return 0
}
```

Output:

```text
Queue capacity with specified 16: 16
Queue capacity with specified 4: 8
Size after adding elements: 2
```

### func add(T)

```cangjie
public func add(element: T): Unit
```

Function: Inserts an element at the tail of this queue.

Parameters:

- element: T - The element to be inserted into this deque.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Add elements to queue tail
    queue.add(1)
    queue.add(2)
    queue.add(3)
    
    println("Queue size: ${queue.size}")      // 3
    println("Queue capacity: ${queue.capacity}")  // 8
    
    // Check head element
    let head = queue.peek()
    println("Head element: ${head}")  // Some(1)
    
    return 0
}
```

Output:

```text
Queue size: 3
Queue capacity: 8
Head element: Some(1)
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears all elements from this queue.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Add some elements
    queue.add(1)
    queue.add(2)
    queue.add(3)
    
    println("Size before clearing: ${queue.size}")      // 3
    println("Is empty before clearing: ${queue.isEmpty()}") // false
    
    // Clear the queue
    queue.clear()
    
    println("Size after clearing: ${queue.size}")      // 0
    println("Is empty after clearing: ${queue.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Size before clearing: 3
Is empty before clearing: false
Size after clearing: 0
Is empty after clearing: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Gets an iterator for elements in this queue in front-to-back order.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Add elements
    queue.add(1)
    queue.add(2)
    queue.add(3)
    
    // Iterate through queue
    let iter = queue.iterator()
    println(iter.next())
    println(iter.next())
    println(iter.next())
    
    return 0
}
```

Output:

```text
Some(1)
Some(2)
Some(3)
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Checks if this queue is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if empty, otherwise `false`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Empty queue
    println("Is empty queue empty: ${queue.isEmpty()}")  // true
    
    // After adding elements
    queue.add(1)
    println("Is queue empty after adding: ${queue.isEmpty()}")  // false
    
    // After removing all elements
    queue.remove()
    println("Is queue empty after removing: ${queue.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
Is empty queue empty: true
Is queue empty after adding: false
Is queue empty after removing: true
```

### func peek()

```cangjie
public func peek():?T
```

Function: Views the head element of this queue without removing it.

Returns:

- ?T - The head element of the queue, returns `None` if queue is empty.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Peek empty queue
    let emptyPeek = queue.peek()
    println("Head element of empty queue: ${emptyPeek}")  // None
    
    // Peek after adding elements
    queue.add(10)
    queue.add(20)
    let peekValue = queue.peek()
    println("Head element: ${peekValue}")  // Some(10)
    
    // Peek doesn't remove elements
    println("Queue size after peek: ${queue.size}")  // 2
    
    return 0
}
```

Output:

```text
Head element of empty queue: None
Head element: Some(10)
Queue size after peek: 2
```

### func remove()

```cangjie
public func remove(): ?T
```

Function: Removes and returns the head element of this queue. Returns `None` if queue is empty.

Returns:

- ?T - The removed head element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Remove from empty queue
    let emptyRemove = queue.remove()
    println("Removed from empty queue: ${emptyRemove}")  // None
    
    // Remove after adding elements
    queue.add(10)
    queue.add(20)
    queue.add(30)
    
    let removedElement = queue.remove()
    println("Removed element: ${removedElement}")  // Some(10)
    println("Queue size after removal: ${queue.size}")   // 2
    
    return 0
}
```

Output:

```text
Removed from empty queue: None
Removed element: Some(10)
Queue size after removal: 2
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Increases the capacity of this queue.

Expands the queue by additional size. No expansion occurs when:
1. additional ≤ 0
2. Remaining capacity ≥ additional
When expansion is needed, the new capacity will be the maximum between:
1. Original capacity × 1.5 (rounded down)
2. additional + used capacity

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to expand.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Initial capacity
    println("Initial capacity: ${queue.capacity}")  // 8
    
    // Reserve additional space
    queue.reserve(10)
    println("Capacity after reservation: ${queue.capacity}")  // 16 (expanded to nearest suitable size near 18)
    
    // Test adding elements
    for (i in 0..15) {
        queue.add(i)
    }
    println("Capacity after adding 16 elements: ${queue.capacity}")  // 16
    println("Size after adding 16 elements: ${queue.size}")    // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Capacity after reservation: 12
Capacity after adding 16 elements: 18
Size after adding 16 elements: 15
```

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements of this queue in front-to-back order.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Add elements
    queue.add(1)
    queue.add(2)
    queue.add(3)
    
    println("Queue: ${queue}")  // [1, 2, 3]
    
    // Convert to array
    let array = queue.toArray()
    
    println("Array: ${array}")      // [1, 2, 3]
    println("Array size: ${array.size}") // 3
    
    return 0
}
```

Output:

```text
Queue: [1, 2, 3]
Array: [1, 2, 3]
Array size: 3
```

### extend\<T> ArrayQueue\<T> <: ToString where T <: ToString

```cangjie
extend<T> ArrayQueue<T> <: ToString where T <: ToString
```

Function: Extends [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface for [ArrayQueue](./collection_package_class.md#class-arrayqueuet)\<T>, supporting string conversion.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Gets the string representation of this [ArrayQueue](./collection_package_class.md#class-arrayqueuet)\<T> instance.

The string contains string representations of all elements in front-to-back order, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let queue = ArrayQueue<Int64>()
    
    // Empty queue to string
    let emptyStr = queue.toString()
    println("Empty queue string: ${emptyStr}")  // []
    
    // Queue to string after adding elements
    queue.add(1)
    queue.add(2)
    queue.add(3)
    
    let str = queue.toString()
    println("Queue string: ${str}")      // [1, 2, 3]
    println("String length: ${str.size}")  // 9
    
    return 0
}
```

Output:

```text
Empty queue string: []
Queue string: [1, 2, 3]
String length: 9
```

## class ArrayStack\<T>

```cangjie
public class ArrayStack<T> <: Stack<T> {
    public init(capacity: Int64)
    public init()
}
```

Function: [ArrayStack](#class-arraystackt) is a stack [Stack](./collection_package_interface.md#interface-stackt) data structure implemented based on arrays [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt). ArrayStack uses an array to store stack elements and a pointer to track the position of the top element.

[ArrayStack](#class-arraystackt) only supports Last In First Out (LIFO) operations, allowing insertion and deletion only at the head. Additionally, [ArrayStack](#class-arraystackt) dynamically expands capacity as needed.

Parent Types:

- [Stack](./collection_package_interface.md#interface-stackt)\<T>

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: The capacity size of the stack.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Initial capacity is 8
    println("Initial capacity: ${stack.capacity}")  // 8
    
    // Construct with specified capacity
    let stack2 = ArrayStack<Int64>(16)
    println("Specified capacity: ${stack2.capacity}")  // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Specified capacity: 16
```

### prop size

```cangjie
public prop size: Int64
```

Function: The number of elements in the stack.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Initial size is 0
    println("Initial size: ${stack.size}")  // 0
    
    // Size changes after adding elements
    stack.add(1)
    stack.add(2)
    println("Size after adding elements: ${stack.size}")  // 2
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding elements: 2
```

### func init()

```cangjie
public init()
```

Function: Constructs an empty [ArrayStack](#class-arraystackt) with an initial capacity of 8.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create stack using default constructor
    let stack = ArrayStack<Int64>()
    
    println("Initial size: ${stack.size}")      // 0
    println("Initial capacity: ${stack.capacity}")  // 8
    println("Is empty: ${stack.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 8
Is empty: true
```

### func init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs an empty [ArrayStack](#class-arraystackt) with the specified initial capacity. If capacity is less than the default capacity of 8, the constructed [ArrayStack](#class-arraystackt) will have an initial capacity of 8.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Initial capacity size.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the input parameter is negative.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Specify capacity greater than default
    let stack1 = ArrayStack<Int64>(16)
    println("Stack capacity with specified 16: ${stack1.capacity}")  // 16
    
    // Specify capacity less than default
    let stack2 = ArrayStack<Int64>(4)
    println("Stack capacity with specified 4: ${stack2.capacity}")   // 8
    
    // Test adding elements
    stack2.add(1)
    stack2.add(2)
    println("Size after adding elements: ${stack2.size}")  // 2
    
    return 0
}
```

Output:

```text
Stack capacity with specified 16: 16
Stack capacity with specified 4: 8
Size after adding elements: 2
```

### func add(T)

```cangjie
public func add(element: T): Unit
```

Function: Adds an element to the top of the stack.

Parameters:

- element: T - The element to add.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Add elements to stack top
    stack.add(1)
    stack.add(2)
    stack.add(3)
    
    println("Stack size: ${stack.size}")      // 3
    println("Stack capacity: ${stack.capacity}")  // 8
    
    // View top element
    let top = stack.peek()
    println("Top element: ${top}")  // Some(3)
    
    return 0
}
```

Output:

```text
Stack size: 3
Stack capacity: 8
Top element: Some(3)
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears the current [ArrayStack](#class-arraystackt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Add some elements
    stack.add(1)
    stack.add(2)
    stack.add(3)
    
    println("Size before clearing: ${stack.size}")      // 3
    println("Is empty before clearing: ${stack.isEmpty()}") // false
    
    // Clear stack
    stack.clear()
    
    println("Size after clearing: ${stack.size}")      // 0
    println("Is empty after clearing: ${stack.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Size before clearing: 3
Is empty before clearing: false
Size after clearing: 0
Is empty after clearing: true
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Checks whether this [ArrayStack](#class-arraystackt) is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if empty, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Empty stack
    println("Is empty stack empty: ${stack.isEmpty()}")  // true
    
    // After adding elements
    stack.add(1)
    println("Is empty after adding elements: ${stack.isEmpty()}")  // false
    
    // After removing all elements
    stack.remove()
    println("Is empty after removing elements: ${stack.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
Is empty stack empty: true
Is empty after adding elements: false
Is empty after removing elements: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Returns an iterator over the elements in this [ArrayStack](#class-arraystackt) in the order they would be popped.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator over the stack elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Add elements
    stack.add(1)
    stack.add(2)
    stack.add(3)
    
    // Iterate over stack using iterator
    let iter = stack.iterator()
    println(iter.next())
    println(iter.next())
    println(iter.next())
    
    return 0
}
```

Output:

```text
Some(3)
Some(2)
Some(1)
```

### func peek()

```cangjie
public func peek(): ?T
```

Function: Retrieves the top element of the stack without removing it. Returns `None` if the stack is empty.

Returns:

- ?T - The top element of the stack.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Peek top element of empty stack
    let emptyPeek = stack.peek()
    println("Top element of empty stack: ${emptyPeek}")  // None
    
    // Peek top element after adding elements
    stack.add(10)
    stack.add(20)
    let peekValue = stack.peek()
    println("Top element: ${peekValue}")  // Some(20)
    
    // Peeking doesn't remove elements
    println("Size after peeking: ${stack.size}")  // 2
    
    return 0
}
```

Output:

```text
Top element of empty stack: None
Top element: Some(20)
Size after peeking: 2
```

### func remove()

```cangjie
public func remove(): ?T
```

Function: Performs a pop operation, removing and returning the top element of the stack. Returns `None` if the stack is empty.

Returns:

- ?T - The removed top element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Remove from empty stack
    let emptyRemove = stack.remove()
    println("Removed from empty stack: ${emptyRemove}")  // None
    
    // Remove after adding elements
    stack.add(10)
    stack.add(20)
    stack.add(30)
    
    let removedElement = stack.remove()
    println("Removed element: ${removedElement}")  // Some(30)
    println("Size after removal: ${stack.size}")   // 2
    
    return 0
}
```

Output:

```text
Removed from empty stack: None
Removed element: Some(30)
Size after removal: 2
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Expands the capacity of the current [ArrayStack](#class-arraystackt) by the specified amount. No expansion occurs if additional is less than or equal to zero. If the current remaining space is greater than or equal to additional, no expansion occurs. Otherwise, the current [ArrayStack](#class-arraystackt) expands to size + additional.

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The amount to expand.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Initial capacity
    println("Initial capacity: ${stack.capacity}")  // 8
    
    // Reserve additional space
    stack.reserve(10)
    println("Capacity after reservation: ${stack.capacity}")  // 12 (expands to nearest suitable size around 18)
    
    // Test adding elements
    for (i in 0..15) {
        stack.add(i)
    }
    println("Capacity after adding 16 elements: ${stack.capacity}")  // 18
    println("Size after adding 16 elements: ${stack.size}")    // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 8
Capacity after reservation: 12
Capacity after adding 16 elements: 18
Size after adding 16 elements: 15
```

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing the stack elements in pop order.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Add elements
    stack.add(1)
    stack.add(2)
    stack.add(3)
    
    println("Stack: ${stack}")  // [3, 2, 1]
    
    // Convert to array
    let array = stack.toArray()
    
    println("Array: ${array}")      // [3, 2, 1]
    println("Array size: ${array.size}") // 3
    
    return 0
}
```

Output:

```text
Stack: [3, 2, 1]
Array: [3, 2, 1]
Array size: 3
```

### extend\<T> ArrayStack\<T> <: ToString where T <: ToString

```cangjie
extend<T> ArrayStack<T> <: ToString where T <: ToString
```

Function: Extends ArrayStack with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface to support string conversion.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Gets the string representation of the current [ArrayStack](./collection_package_class.md#class-arraystackt)\<T> instance.

The string contains each element's string representation in reverse order, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation of the stack.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let stack = ArrayStack<Int64>()
    
    // Empty stack to string
    let emptyStr = stack.toString()
    println("Empty stack string: ${emptyStr}")  // []
    
    // Add elements and convert to string
    stack.add(1)
    stack.add(2)
    stack.add(3)
    
    let str = stack.toString()
    println("Stack string: ${str}")      // [3, 2, 1]
    println("String length: ${str.size}")  // 9
    
    return 0
}
```

Output:

```text
Empty stack string: []
Stack string: [3, 2, 1]
String length: 9
```

## class HashMapIterator\<K, V> where K <: Hashable & Equatable\<K>

```cangjie
public class HashMapIterator<K, V> <: Iterator<(K, V)> where K <: Hashable & Equatable<K> {
    public init(map: HashMap<K, V>)
}
```

Function: This class primarily implements the iterator functionality for [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Parent Types:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)>

### init(HashMap\<K, V>)

```cangjie
public init(map: HashMap<K, V>)
```

Function: Creates an instance of [HashMapIterator](collection_package_class.md#class-hashmapiteratork-v-where-k--hashable--equatablek)\<K, V>.

Parameters:

- map: [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> - The input [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V>.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashMap
    let map = HashMap<String, Int64>()
    map["one"] = 1
    map["two"] = 2
    map["three"] = 3
    
    // Create HashMapIterator using HashMap
    let iterator = HashMapIterator<String, Int64>(map)
    
    println("HashMapIterator created successfully")
    return 0
}
```

Output:

```text
HashMapIterator created successfully
```

### func next()

```cangjie
public func next(): ?(K, V)
```

Function: Returns the next element in the iterator.

Returns:

- ?(K, V) - The next element in the iterator, wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).

Exceptions:

- [ConcurrentModificationException](collection_package_exception.md#class-concurrentmodificationexception) - Thrown when the function detects unsynchronized concurrent modifications.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashMap
    let map = HashMap<String, Int64>()
    map["one"] = 1
    map["two"] = 2
    map["three"] = 3
    
    // Create iterator and get the first element
    let iterator = HashMapIterator<String, Int64>(map)
    let firstElement = iterator.next()
    
    if (firstElement.isSome()) {
        println("Successfully retrieved element")
    } else {
        println("No elements")
    }
    return 0
}
```

Output:

```text
Successfully retrieved element
```

### func remove()

```cangjie
public func remove(): Option<(K, V)>
```

Function: Removes the element returned by the next function of this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) iterator. This function can only be called once per call to next.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<(K, V)> - The removed element.

Exceptions:

- [ConcurrentModificationException](collection_package_exception.md#class-concurrentmodificationexception) - Thrown when the function detects unsynchronized concurrent modifications.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashMap
    let map = HashMap<String, Int64>()
    map["one"] = 1
    map["two"] = 2
    
    // Create iterator, retrieve and remove element
    let iterator = HashMapIterator<String, Int64>(map)
    let element = iterator.next()  // First call next to get element
    let removed = iterator.remove()  // Then call remove to delete element
    
    if (element.isSome()) {
        println("Successfully retrieved element")
    }
    
    if (removed.isSome()) {
        println("Successfully removed element")
    }
    return 0
}
```

Output:

```text
Successfully retrieved element
Successfully removed element
```

## class HashMap\<K, V> where K <: Hashable & Equatable\<K>

```cangjie
public class HashMap<K, V> <: Map<K, V> where K <: Hashable & Equatable<K> {
    public init()
    public init(elements: Array<(K, V)>)
    public init(elements: Collection<(K, V)>)
    public init(capacity: Int64)
    public init(size: Int64, initElement: (Int64) -> (K, V))
}
```

Function: Hash table implementation of the [Map](collection_package_interface.md#interface-mapk-v) interface.

A hash table is a commonly used data structure that enables fast lookup, insertion, and deletion of data. The basic principle of a hash table is to map data to an array, known as the hash table. Each data element has a corresponding hash value that determines its position in the hash table.

Hash tables are characterized by fast lookup, insertion, and deletion operations, typically with O(1) time complexity. Since the underlying array size is dynamic, hash tables do not guarantee immutable element order.

Parent Types:

- [Map](collection_package_interface.md#interface-mapk-v)\<K, V>

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Returns the capacity of the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a default HashMap
    let map = HashMap<String, Int64>()
    
    // Check initial capacity
    println("Initial capacity: ${map.capacity}")  // 16
    
    // Create HashMap with specified capacity
    let map2 = HashMap<String, Int64>(32)
    println("Specified capacity: ${map2.capacity}")  // 32
    
    return 0
}
```

Output:

```text
Initial capacity: 16
Specified capacity: 32
```

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of key-value pairs.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashMap
    let map = HashMap<String, Int64>()
    
    // Check initial size
    println("Initial size: ${map.size}")  // 0
    
    // Check size after adding elements
    map["one"] = 1
    map["two"] = 2
    println("Size after adding elements: ${map.size}")  // 2
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding elements: 2
```

### init()

```cangjie
public init()
```

Function: Constructs an empty [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) with the default initial capacity of 16 and default load factor.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap using default constructor
    let map = HashMap<String, Int64>()
    
    println("Initial size: ${map.size}")      // 0
    println("Initial capacity: ${map.capacity}")  // 16
    println("Is empty: ${map.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 16
Is empty: true
```

### init(Array\<(K, V)>)

```cangjie
public init(elements: Array<(K, V)>)
```

Function: Constructs a [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) from an array of key-value pairs.

This constructor sets the capacity of the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) based on the size of the input array. Since duplicate keys are not allowed internally in [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), if duplicate keys exist in the [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt), the later key-value pairs will overwrite the earlier ones according to the iterator order.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<(K, V)> - The array of key-value pairs to initialize this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap from array
    let elements = [("one", 1), ("two", 2), ("three", 3)]
    let map = HashMap<String, Int64>(elements)
    
    println("HashMap size: ${map.size}")      // 3
    println("HashMap capacity: ${map.capacity}")  // 3
    
    // Check if element exists
    if (map.contains("one")) {
        println("Contains key 'one'")
    }
    
    return 0
}
```

Output:

```text
HashMap size: 3
HashMap capacity: 3
Contains key 'one'
```

### init(Collection\<(K, V)>)

```cangjie
public init(elements: Collection<(K, V)>)
```

Function: Constructs a [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) from a collection of key-value pairs.

This constructor sets the capacity of the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) based on the size of the input collection. Since duplicate keys are not allowed internally in [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), if duplicate keys exist in the [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt), the later key-value pairs will overwrite the earlier ones according to the iterator order.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> - The collection of key-value pairs to initialize this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap from collection
    let list = ArrayList<(String, Int64)>([("a", 1), ("b", 2), ("c", 3)])
    let map = HashMap<String, Int64>(list)
    
    println("HashMap size: ${map.size}")  // 3
    
    // Check element
    let value = map.get("b")
    if (value.isSome()) {
        println("Value for key 'b': ${value.getOrThrow()}")  // 2
    }
    
    return 0
}
```

Output:

```text
HashMap size: 3
Value for key 'b': 2
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs an empty [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) with the specified initial capacity.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The initial capacity.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if capacity is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap with specified capacity
    let map = HashMap<String, Int64>(32)
    
    println("HashMap capacity: ${map.capacity}")  // 32
    println("HashMap size: ${map.size}")      // 0
    
    // Add elements
    map["key1"] = 100
    map["key2"] = 200
    println("Size after adding elements: ${map.size}")    // 2
    
    return 0
}
```

Output:

```text
HashMap capacity: 32
HashMap size: 0
Size after adding elements: 2
```

### init(Int64, (Int64) -> (K, V))

```cangjie
public init(size: Int64, initElement: (Int64) -> (K, V))
```

Function: Constructs a [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) using the specified size and initialization function.

The capacity of the constructed [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) is influenced by the size parameter. Since [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) internally does not allow duplicate keys, when the initElement function generates identical keys, the later key-value pair will overwrite the previously generated one.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size parameter for initializing this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) -> (K, V) - The initialization function rule for this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if size is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap using size and initialization function
    let map = HashMap<String, Int64>(3, {index => 
        let keys = ["first", "second", "third"]
        return (keys[index], index * 10)
    })
    
    println("HashMap size: ${map.size}")  // 3
    
    // Check elements
    let value = map.get("second")
    if (value.isSome()) {
        println("Value for key 'second': ${value.getOrThrow()}")  // 10
    }
    
    return 0
}
```

Output:

```text
HashMap size: 3
Value for key 'second': 10
```

### func add(K, V)

```cangjie
public func add(key: K, value: V): Option<V>
```

Function: Inserts a key-value pair into the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

For keys already present in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), the existing value will be replaced by the new value, and the old value will be returned.

Parameters:

- key: K - The key to insert.
- value: V - The value to assign.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - If the key existed prior to assignment, the old value is wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    
    // Add new key-value pair
    let result1 = map.add("first", 100)
    println("Return value for adding new key 'first': ${result1.isSome()}")  // false
    
    // Replace existing key
    let result2 = map.add("first", 200)
    if (result2.isSome()) {
        println("Old value for replaced key 'first': ${result2.getOrThrow()}")  // 100
    }
    
    println("Current value for 'first': ${map["first"]}")  // 200
    
    return 0
}
```

Output:

```text
Return value for adding new key 'first': false
Old value for replaced key 'first': 100
Current value for 'first': 200
```

### func add(Collection\<(K, V)>)

```cangjie
public func add(all!: Collection<(K, V)>): Unit
```

Function: Inserts a collection of new key-value pairs into the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) in the order of the elements' iterator.

For keys already present in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), the existing values will be replaced by the new values.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> - The collection of key-value pairs to add to the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    
    // Create collection to add
    let newElements = ArrayList<(String, Int64)>([("b", 2), ("c", 3), ("a", 10)])
    
    println("Size before adding collection: ${map.size}")  // 1
    println("Value for 'a' before adding collection: ${map["a"]}")  // 1
    
    // Add key-value pair collection
    map.add(all: newElements)
    
    println("Size after adding collection: ${map.size}")  // 3
    println("Value for 'a' after adding collection: ${map["a"]}")  // 10
    
    return 0
}
```

Output:

```text
Size before adding collection: 1
Value for 'a' before adding collection: 1
Size after adding collection: 3
Value for 'a' after adding collection: 10
```

### func all((K, V) -> Bool)

```cangjie
public func all(predicate: (K, V) -> Bool): Bool
```

Function: Determines whether all key-value pairs in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all key-value pairs satisfy the condition; otherwise, returns false.

### func any((K, V) -> Bool)

```cangjie
public func any(predicate: (K, V) -> Bool): Bool
```

Function: Determines whether any key-value pair in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether any key-value pair satisfies the condition.

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears all key-value pairs.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap and add elements
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    
    println("Size before clearing: ${map.size}")  // 3
    println("Is empty before clearing: ${map.isEmpty()}")  // false
    
    // Clear all key-value pairs
    map.clear()
    
    println("Size after clearing: ${map.size}")  // 0
    println("Is empty after clearing: ${map.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
Size before clearing: 3
Is empty before clearing: false
Size after clearing: 0
Is empty after clearing: true
```

### func clone()

```cangjie
public func clone(): HashMap<K, V>
```

Function: Clones the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Returns:

- [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> - Returns a [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create original HashMap
    let originalMap = HashMap<String, Int64>()
    originalMap["a"] = 1
    originalMap["b"] = 2
    
    // Clone HashMap
    let clonedMap = originalMap.clone()
    
    println("Original HashMap size: ${originalMap.size}")  // 2
    println("Cloned HashMap size: ${clonedMap.size}")    // 2
    
    // Modify cloned HashMap
    clonedMap["c"] = 3
    println("Original HashMap size after modification: ${originalMap.size}")  // 2
    println("Cloned HashMap size after modification: ${clonedMap.size}")    // 3
    
    return 0
}
```

Output:

```text
Original HashMap size: 2
Cloned HashMap size: 2
Original HashMap size after modification: 2
Cloned HashMap size after modification: 3
```

### func contains(K)

```cangjie
public func contains(key: K): Bool
```

Function: Determines whether the map contains a mapping for the specified key.

Parameters:

- key: K - The key to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the key exists; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["apple"] = 1
    map["banana"] = 2
    
    // Check if specified keys exist
    let hasApple = map.contains("apple")
    let hasOrange = map.contains("orange")
    
    println("Contains key 'apple': ${hasApple}")  // true
    println("Contains key 'orange': ${hasOrange}")  // false
    
    return 0
}
```

Output:

```text
Contains key 'apple': true
Contains key 'orange': false
```

### func contains(Collection\<K>)

```cangjie
public func contains(all!: Collection<K>): Bool
```

Function: Determines whether the map contains mappings for all keys in the specified collection.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys to check.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all keys are present; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    
    // Check if specified key collections exist
    let keys1 = ArrayList<String>(["a", "b"])
    let result1 = map.contains(all: keys1)
    println("Contains keys [a, b]: ${result1}")  // true
    
    let keys2 = ArrayList<String>(["a", "d"])
    let result2 = map.contains(all: keys2)
    println("Contains keys [a, d]: ${result2}")  // false
    
    return 0
}
```

Output:

```text
Contains keys [a, b]: true
Contains keys [a, d]: false
```

### func entryView(K)

```cangjie
public func entryView(key: K): MapEntryView<K, V>
```

Function: Returns an empty reference view if the specified key is not present. If the key exists, returns a reference view of the corresponding element.

Parameters:

- key: K - The key of the key-value pair to add.

Returns:

- [MapEntryView](./collection_package_interface.md#interface-mapentryviewk-v)\<K, V> - A reference view.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["key1"] = 100
    
    // Get reference view for existing key
    let view1 = map.entryView("key1")
    if (view1.value.isSome()) {
        println("Found key 'key1' with value: ${view1.value.getOrThrow()}")  // 100
    }
    
    // Set value via entryView
    view1.value = Some(150)
    println("Modified value for key 'key1': ${map["key1"]}")  // 150
    
    return 0
}
```

Output:

```text
Found key 'key1' with value: 100
Modified value for key 'key1': 150
```

### func filter((K, V) -> Bool)
```cangjie
public func filter(predicate: (K, V) -> Bool): HashMap<K, V>
```

Function: Returns a new [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> containing key-value pairs that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> - A new collection containing key-value pairs that satisfy the predicate.

### func fold\<R>(R, (R, K, V) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, K, V) -> R): R
```

Function: Accumulates values starting from the given initial value, processing from left to right.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The initial value of type R.
- operation: (R, K, V) -> R - The given accumulation function.

Returns:

- R - The final accumulated value.

### func forEach((K, V) -> Unit)

```cangjie
public func forEach(action: (K, V) -> Unit): Unit
```

Function: Performs the given action on each key-value pair.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (K, V) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The given action function.

### func get(K)

```cangjie
public func get(key: K): ?V
```

Function: Returns the value associated with the specified key, or [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V>.None if the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) contains no mapping for the key.

Parameters:

- key: K - The input key.

Returns:

- ?V - The value associated with the key, wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["name"] = 100
    map["age"] = 25
    
    // Get existing key
    let nameValue = map.get("name")
    if (nameValue.isSome()) {
        println("Value for key 'name': ${nameValue.getOrThrow()}")  // 100
    }
    
    // Get non-existent key
    let heightValue = map.get("height")
    if (heightValue.isNone()) {
        println("Key 'height' does not exist")
    }
    
    return 0
}
```

Output:

```text
Value for key 'name': 100
Key 'height' does not exist
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Returns true if the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) is empty, false otherwise.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the HashMap is empty.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create empty HashMap
    let map = HashMap<String, Int64>()
    
    // Check if empty
    println("Is empty HashMap empty: ${map.isEmpty()}")  // true
    
    // Check after adding elements
    map["key"] = 100
    println("Is empty after adding elements: ${map.isEmpty()}")  // false
    
    // Check after clearing
    map.clear()
    println("Is empty after clearing: ${map.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
Is empty HashMap empty: true
Is empty after adding elements: false
Is empty after clearing: true
```

### func iterator()

```cangjie
public func iterator(): HashMapIterator<K, V>
```

Function: Returns an iterator over the HashMap.

Returns:

- [HashMapIterator](collection_package_class.md#class-hashmapiteratork-v-where-k--hashable--equatablek)\<K, V> - An iterator for the HashMap.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    
    // Get iterator
    let iterator = map.iterator()
    
    // Iterate elements
    var count = 0
    while (true) {
        let element = iterator.next()
        if (element.isNone()) {
            break
        }
        count += 1
    }
    
    println("Number of elements iterated: ${count}")  // 3
    
    return 0
}
```

Output:

```text
Number of elements iterated: 3
```

### func keys()

```cangjie
public func keys(): EquatableCollection<K>
```

Function: Returns all keys in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), stored in a Keys container.

Returns:

- [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> - A container holding all returned keys.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    
    // Get all keys
    let keys = map.keys()
    
    println("Number of keys: ${keys.size}")  // 3
    
    // Check if contains specific key
    if (keys.contains("b")) {
        println("Contains key 'b'")  // Contains key 'b'
    }
    
    return 0
}
```

Output:

```text
Number of keys: 3
Contains key 'b'
```

### func mapValues\<R>((K, V) -> R)

```cangjie
public func mapValues<R>(transform: (K, V) -> R): HashMap<K, R>
```

Function: Transforms this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) and returns a new [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (K, V) -> R - The given transformation function.

Returns:

- [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, R> - A new transformed HashMap.

### func mapValues\<R>((V) -> R)

```cangjie
public func mapValues<R>(transform: (V) -> R): HashMap<K, R>
```

Function: Transforms this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) and returns a new [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (V) -> R - The given transformation function.

Returns:

- [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, R> - A new transformed HashMap.

### func none((K, V) -> Bool)

```cangjie
public func none(predicate: (K, V) -> Bool): Bool
```

Function: Returns true if no key-value pairs satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether no key-value pairs satisfy the condition.

### func reduce((V, V) -> V)

```cangjie
public func reduce(operation: (V, V) -> V): Option<V>
```

Function: Accumulates values using the first value as initial value, processing from left to right.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (V, V) -> V - The given accumulation function.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - The result of accumulation.

### func remove(Collection\<K>)

```cangjie
public func remove(all!: Collection<K>): Unit
```

Function: Removes mappings for all specified keys in the collection from this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) (if they exist).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys to remove.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    map["d"] = 4
    
    println("Size before removal: ${map.size}")  // 4
    
    // Create keys to remove
    let keysToRemove = ArrayList<String>(["a", "c", "e"])
    
    // Remove specified keys
    map.remove(all: keysToRemove)
    
    println("Size after removal: ${map.size}")  // 2
    println("Contains 'b': ${map.contains("b")}")  // true
    println("Contains 'a': ${map.contains("a")}")  // false
    
    return 0
}
```

Output:

```text
Size before removal: 4
Size after removal: 2
Contains 'b': true
Contains 'a': false
```

### func remove(K)

```cangjie
public func remove(key: K): Option<V>
```

Function: Removes the mapping for the specified key from this [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) (if it exists).

Parameters:

- key: K - The key to remove.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - The value associated with the removed key, wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont). Returns None if the key doesn't exist.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["x"] = 10
    map["y"] = 20
    map["z"] = 30
    
    println("Size before removal: ${map.size}")  // 3
    
    // Remove existing key
    let removedValue = map.remove("y")
    if (removedValue.isSome()) {
        println("Removed key 'y', returned value: ${removedValue.getOrThrow()}")  // 20
    }
    
    // Remove non-existent key
    let nonExistValue = map.remove("w")
    if (nonExistValue.isNone()) {
        println("Key 'w' doesn't exist, returns None")
    }
    
    println("Size after removal: ${map.size}")  // 2
    
    return 0
}
```

Output:

```text
Size before removal: 3
Removed key 'y', returned value: 20
Key 'w' doesn't exist, returns None
Size after removal: 2
```

### func removeIf((K, V) -> Bool)

```cangjie
public func removeIf(predicate: (K, V) -> Bool): Unit
```

Function: Takes a lambda expression as input and removes key-value pairs that satisfy the condition.

This function traverses the entire [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), so all key-value pairs where `predicate(K, V) == true` will be removed.

Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - A lambda expression used for evaluation.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when key-value pairs in [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) are added or removed within the `predicate`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    map["d"] = 4
    
    println("Size before removal: ${map.size}")  // 4
    
    // Remove key-value pairs where value > 2
    map.removeIf({_: String, value: Int64 => value > 2})
    
    println("Size after removal: ${map.size}")  // 2
    
    // Check remaining elements
    let remaining = map.get("b")
    if (remaining.isSome()) {
        println("Key 'b' still exists with value: ${remaining.getOrThrow()}")  // 2
    }
    
    return 0
}
```

Output:

```text
Size before removal: 4
Size after removal: 2
Key 'b' still exists with value: 2
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Expands the current [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Expands the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) by the specified `additional` size. No expansion occurs if:
- `additional` ≤ 0
- The remaining capacity of [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek) ≥ `additional`

When expansion is needed, the new capacity is set to the maximum of:
1. Original capacity × 1.5 (rounded down)
2. `additional` + used capacity

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to expand by.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when `additional` + used capacity exceeds Int64.Max.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    
    println("Initial capacity: ${map.capacity}")  // 16
    
    // Reserve additional space
    map.reserve(20)
    
    println("Capacity after reservation: ${map.capacity}")  // 24 (expanded to appropriate size)
    
    // Add elements for testing
    for (i in 0..30) {
        map["key${i}"] = i
    }
    
    println("Capacity after adding elements: ${map.capacity}")  // 36
    println("Size after adding elements: ${map.size}")    // 30
    
    return 0
}
```

Output:

```text
Initial capacity: 16
Capacity after reservation: 24
Capacity after adding elements: 36
Size after adding elements: 30
```

### func toArray()

```cangjie
public func toArray(): Array<(K, V)>
```

Function: Constructs and returns an array containing all key-value pairs from the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<(K, V)> - An array containing all key-value pairs in the container.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["a"] = 1
    map["b"] = 2
    map["c"] = 3
    
    // Convert to array
    let array = map.toArray()
    
    println("Array size: ${array.size}")  // 3
    
    // Iterate through array elements
    for (i in 0..array.size) {
        let (key, value) = array[i]
        println("Key: ${key}, Value: ${value}")
    }
    
    return 0
}
```

Output:

```text
Array size: 3
Key: a, Value: 1
Key: b, Value: 2
Key: c, Value: 3
```

### func values()

```cangjie
public func values(): Collection<V>
```

Function: Returns all values in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), stored in a Values container.

Returns:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> - A container holding all returned values.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["apple"] = 10
    map["banana"] = 20
    map["orange"] = 30
    
    // Get all values
    let values = map.values()
    
    println("Number of values: ${values.size}")  // 3
    
    // Iterate through all values
    println("All values: ")
    for (i in values) {
        println(i)
    }
    return 0
}
```

Output:

```text
Number of values: 3
All values: 
10
20
30
```

### operator func \[](K, V)

```cangjie
public operator func [](key: K, value!: V): Unit
```

Function: Operator overload for add method. If the key exists, the new value overwrites the old one; if the key doesn't exist, the key-value pair is added.

Parameters:

- key: K - The key to evaluate.
- value!: V - The value to set.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    
    // Use [] operator to set key-value pairs
    map["first"] = 100
    map["second"] = 200
    
    println("Size after setting: ${map.size}")  // 2
    
    // Overwrite existing key
    map["first"] = 150
    
    println("Value of 'first' after overwrite: ${map["first"]}")  // 150
    println("Value of 'second': ${map["second"]}")  // 200
    
    return 0
}
```

Output:

```text
Size after setting: 2
Value of 'first' after overwrite: 150
Value of 'second': 200
```

### operator func \[](K)

```cangjie
public operator func [](key: K): V
```

Function: Operator overload for get method. Returns the value associated with the key if it exists.

Parameters:

- key: K - The key to evaluate.

Returns:

- V - The value associated with the key.

Exceptions:

- [NoneValueException](../../core/core_package_api/core_package_exceptions.md#class-nonevalueexception) - Thrown if the key doesn't exist in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["data1"] = 100
    map["data2"] = 200
    
    // Use [] operator to get values
    let value1 = map["data1"]
    let value2 = map["data2"]
    
    println("Value of key 'data1': ${value1}")  // 100
    println("Value of key 'data2': ${value2}")  // 200
    
    return 0
}
```

Output:

```text
Value of key 'data1': 100
Value of key 'data2': 200
```

### extend\<K, V> HashMap\<K, V> <: Equatable\<HashMap\<K, V>> where V <: Equatable\<V>

```cangjie
extend<K, V> HashMap<K, V> <: Equatable<HashMap<K, V>> where V <: Equatable<V>
```

Function: Extends [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> with the [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V>> interface, enabling equality comparison.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V>>

#### operator func ==(HashMap\<K, V>)

```cangjie
public operator func ==(right: HashMap<K, V>): Bool
```

Function: Determines whether the current instance is equal to the parameter's [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> instance.

Two [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> instances are considered equal if they contain identical key-value pairs.

Parameters:

- right: [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two HashMaps
    let map1 = HashMap<String, Int64>()
    map1["a"] = 1
    map1["b"] = 2
    
    let map2 = HashMap<String, Int64>()
    map2["b"] = 2
    map2["a"] = 1
    
    let map3 = HashMap<String, Int64>()
    map3["a"] = 1
    map3["b"] = 3
    
    // Compare equal HashMaps
    println("map1 == map2: ${map1 == map2}")  // true
    
    // Compare unequal HashMaps
    println("map1 == map3: ${map1 == map3}")  // false
    
    return 0
}
```

Output:

```text
map1 == map2: true
map1 == map3: false
```

#### operator func !=(HashMap\<K, V>)

```cangjie
public operator func !=(right: HashMap<K, V>): Bool
```

Function: Determines whether the current instance is not equal to the parameter's [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> instance.

Parameters:

- right: [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two HashMaps
    let map1 = HashMap<String, Int64>()
    map1["x"] = 10
    map1["y"] = 20
    
    let map2 = HashMap<String, Int64>()
    map2["x"] = 10
    map2["y"] = 30
    
    let map3 = HashMap<String, Int64>()
    map3["y"] = 20
    map3["x"] = 10
    
    // Compare unequal HashMaps
    println("map1 != map2: ${map1 != map2}")  // true
    
    // Compare equal HashMaps
    println("map1 != map3: ${map1 != map3}")  // false
    
    return 0
}
```

Output:

```text
map1 != map2: true
map1 != map3: false
```

### extend\<K, V> HashMap\<K, V> <: ToString where V <: ToString, K <: ToString

```cangjie
extend<K, V> HashMap<K, V> <: ToString where V <: ToString, K <: ToString
```

Function: Extends [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface, enabling string conversion.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current [HashMap](./collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek)\<K, V> instance to a string.

The resulting string contains string representations of all key-value pairs in the format: "[(k1, v1), (k2, v2), (k3, v3)]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashMap
    let map = HashMap<String, Int64>()
    map["apple"] = 5
    map["banana"] = 3
    map["orange"] = 8
    
    // Convert to string
    let mapString = map.toString()
    
    println("String representation of empty collection: ${HashMap<String, Int64>().toString()}")  // []
    println("String representation of HashMap: ${mapString}")
    
    return 0
}
```

Output:

```text
String representation of empty collection: []
String representation of HashMap: [(apple, 5), (banana, 3), (orange, 8)]
```

## class HashSet\<T> where T <: Hashable & Equatable\<T>

```cangjie
public class HashSet<T> <: Set<T> where T <: Hashable & Equatable<T> {
    public init()
    public init(elements: Collection<T>)
    public init(elements: Array<T>)
    public init(capacity: Int64)
    public init(size: Int64, initElement: (Int64) -> T)
}
```

Function: An implementation of the [Set](collection_package_interface.md#interface-sett) interface based on [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Elements in [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) are unordered and do not allow duplicates. When adding elements to [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet), the position of each element in the hash table is determined by its hash value.

> **Tip:**
>
> [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) is implemented based on [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek), therefore its capacity, memory layout, and time performance are identical to [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Parent Types:

- [Set](collection_package_interface.md#interface-sett)\<T>

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of elements in this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create empty HashSet
    let set = HashSet<String>()
    
    println("Initial size: ${set.size}")  // 0
    
    // Check size after adding elements
    set.add("apple")
    set.add("banana")
    set.add("apple")  // Duplicate element, not added
    
    println("Size after adding elements: ${set.size}")  // 2
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding elements: 2
```

### init(Int64, (Int64) -> T)

```cangjie
public init(size: Int64, initElement: (Int64) -> T)
```

Function: Constructs a [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) using the specified size and initialization function. The capacity of the constructed [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) is influenced by the size parameter.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of elements in the initialization function.
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) ->T - Initialization function rule.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if size is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet using size and initialization function
    let set = HashSet<String>(3, {index => 
        let fruits = ["apple", "banana", "orange"]
        return fruits[index]
    })
    
    println("HashSet size: ${set.size}")  // 3
    
    // Check if element exists
    if (set.contains("banana")) {
        println("Contains 'banana'")
    }
    
    return 0
}
```

Output:

```text
HashSet size: 3
Contains 'banana'
```

### init()

```cangjie
public init()
```

Function: Constructs an empty [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) with an initial capacity of 16.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet using default constructor
    let set = HashSet<String>()
    
    println("Initial size: ${set.size}")      // 0
    println("Initial capacity: ${set.capacity}")  // 16
    println("Is empty: ${set.isEmpty()}") // true
    
    return 0
}
```

Output:

```text
Initial size: 0
Initial capacity: 16
Is empty: true
```

### init(Array\<T>)

```cangjie
public init(elements: Array<T>)
```

Function: Constructs a [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) using the specified array. The constructor sets the capacity of [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) based on the size of the input array.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - Array used to initialize the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet from array
    let elements = ["apple", "banana", "orange", "apple"]  // Contains duplicates
    let set = HashSet<String>(elements)
    
    println("HashSet size: ${set.size}")      // 3 (no duplicates)
    println("HashSet capacity: ${set.capacity}")  // 4 (set based on array size)
    
    // Check if element exists
    if (set.contains("apple")) {
        println("Contains 'apple'")
    }
    
    return 0
}
```

Output:

```text
HashSet size: 3
HashSet capacity: 4
Contains 'apple'
```

### init(Collection\<T>)

```cangjie
public init(elements: Collection<T>)
```

Function: Constructs a [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) using the specified collection. The constructor sets the capacity of [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) based on the size of the input collection.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - Collection used to initialize the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet from collection
    let list = ArrayList<String>(["red", "green", "blue", "red"])
    let set = HashSet<String>(list)
    
    println("HashSet size: ${set.size}")  // 3
    
    // Check element
    if (set.contains("green")) {
        println("Contains 'green'")
    }
    
    return 0
}
```

Output:

```text
HashSet size: 3
Contains 'green'
```

### init(Int64)

```cangjie
public init(capacity: Int64)
```

Function: Constructs a [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) with the specified capacity.

Parameters:

- capacity: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Initial capacity size.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if capacity is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet with specified capacity
    let set = HashSet<String>(32)
    
    println("Initial capacity: ${set.capacity}")  // 32
    println("Initial size: ${set.size}")      // 0
    println("Is empty: ${set.isEmpty()}") // true
    
    // Add some elements
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    println("\nAfter adding elements:")
    println("Capacity: ${set.capacity}")      // 32
    println("Size: ${set.size}")          // 3
    println("Is empty: ${set.isEmpty()}") // false
    
    // Compare with default capacity HashSet
    let defaultSet = HashSet<String>()
    println("\nDefault capacity HashSet: ${defaultSet.capacity}") // 16
    
    return 0
}
```

Output:

```text
Initial capacity: 32
Initial size: 0
Is empty: true

After adding elements:
Capacity: 32
Size: 3
Is empty: false

Default capacity HashSet: 16
```

### func add(T)

```cangjie
public func add(element: T): Bool
```

Function: Adds the specified element to the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet). If the element already exists in the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet), the addition fails.

Parameters:

- element: T - The element to add.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the element was added successfully; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet
    let set = HashSet<String>()
    
    // Add new element
    let result1 = set.add("apple")
    println("Result of adding 'apple': ${result1}")  // true
    
    // Add duplicate element
    let result2 = set.add("apple")
    println("Result of adding 'apple' again: ${result2}")  // false
    
    println("Set size: ${set.size}")  // 1
    
    return 0
}
```

Output:

```text
Result of adding 'apple': true
Result of adding 'apple' again: false
Set size: 1
```

### func add(Collection\<T>)

```cangjie
public func add(all!: Collection<T>): Unit
```

Function: Adds all elements from the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont) to this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet). Existing elements will not be added.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to add.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet
    let set = HashSet<String>()
    set.add("existing")
    
    // Create collection of elements to add
    let newElements = ArrayList<String>(["apple", "banana", "existing", "orange"])
    
    println("Size before adding collection: ${set.size}")  // 1
    
    // Add element collection
    set.add(all: newElements)
    
    println("Size after adding collection: ${set.size}")  // 4
    
    return 0
}
```

Output:

```text
Size before adding collection: 1
Size after adding collection: 4
```

### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

Function: Determines whether all elements in the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to test.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements satisfy the condition; otherwise, returns false.
### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

Function: Determines whether there exists any element in the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) that satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether any element satisfies the condition.

### prop capacity

```cangjie
public prop capacity: Int64
```

Function: Returns the internal array capacity of this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

> **Note:**
>
> The capacity does not necessarily equal the size of the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a default HashSet
    let set = HashSet<String>()
    println("Default capacity: ${set.capacity}")  // 16
    
    // Create a HashSet with specified capacity
    let set2 = HashSet<String>(32)
    println("Specified capacity: ${set2.capacity}")  // 32
    
    // Capacity remains unchanged after adding elements
    set.add("test")
    println("Capacity after adding elements: ${set.capacity}")  // 16
    
    return 0
}
```

Output:

```text
Default capacity: 16
Specified capacity: 32
Capacity after adding elements: 16
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Removes all elements from this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    println("Size before clearing: ${set.size}")  // 3
    println("Is empty before clearing: ${set.isEmpty()}")  // false
    
    // Clear all elements
    set.clear()
    
    println("Size after clearing: ${set.size}")  // 0
    println("Is empty after clearing: ${set.isEmpty()}")  // true
    
    return 0
}
```

Output:

```text
Size before clearing: 3
Is empty before clearing: false
Size after clearing: 0
Is empty after clearing: true
```

### func clone()

```cangjie
public func clone(): HashSet<T>
```

Function: Clones the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Returns:

- [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - Returns the cloned [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create the original HashSet
    let originalSet = HashSet<String>()
    originalSet.add("apple")
    originalSet.add("banana")
    
    // Clone the HashSet
    let clonedSet = originalSet.clone()
    
    println("Original HashSet size: ${originalSet.size}")  // 2
    println("Cloned HashSet size: ${clonedSet.size}")    // 2
    
    // Modify the cloned HashSet
    clonedSet.add("orange")
    println("Original HashSet size after modification: ${originalSet.size}")  // 2
    println("Cloned HashSet size after modification: ${clonedSet.size}")    // 3
    
    return 0
}
```

Output:

```text
Original HashSet size: 2
Cloned HashSet size: 2
Original HashSet size after modification: 2
Cloned HashSet size after modification: 3
```

### func contains(T)

```cangjie
public func contains(element: T): Bool
```

Function: Determines whether the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) contains the specified element.

Parameters:

- element: T - The specified element.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the element is contained; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    // Check for existing element
    if (set.contains("apple")) {
        println("Contains 'apple'")
    }
    
    // Check for non-existing element
    if (!set.contains("grape")) {
        println("Does not contain 'grape'")
    }
    
    // Use contains to check multiple elements
    let elements = ["apple", "grape", "banana"]
    for (element in elements) {
        let exists = set.contains(element)
        println("'${element}': ${exists}")
    }
    
    return 0
}
```

Output:

```text
Contains 'apple'
Does not contain 'grape'
'apple': true
'grape': false
'banana': true
```

### func contains(Collection\<T>)

```cangjie
public func contains(all!: Collection<T>): Bool
```

Function: Determines whether the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) contains all elements from the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The specified collection of elements.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) contains all elements from the [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont); otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    set.add("grape")
    
    // Check for a subset of elements
    let subset1 = ["apple", "banana"]
    if (set.contains(all: subset1)) {
        println("Contains all elements: ${subset1}")
    }
    
    // Check for a collection with non-existing elements
    let subset2 = ["apple", "cantaloupe"]
    if (!set.contains(all: subset2)) {
        println("Does not contain all elements: ${subset2}")
    }
    
    // Check for an empty collection
    let emptyList = Array<String>()
    if (set.contains(all: emptyList)) {
        println("Contains empty collection")
    }
    
    // Use another HashSet as the check collection
    let otherSet = HashSet<String>()
    otherSet.add("orange")
    otherSet.add("grape")
    if (set.contains(all: otherSet)) {
        println("Contains all elements from the other HashSet")
    }
    
    return 0
}
```

Output:

```text
Contains all elements: [apple, banana]
Does not contain all elements: [apple, cantaloupe]
Contains empty collection
Contains all elements from the other HashSet
```

### func filter((T) -> Bool)
```cangjie
public func filter(predicate: (T) -> Bool): HashSet<T>
```

Function: Returns a new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> containing elements that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - Returns a new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) containing elements that satisfy the condition.

### func filterMap\<R>((T) -> ?R)

```cangjie
public func filterMap<R>(transform: (T) -> ?R): HashSet<R>
```

Function: Performs both filtering and mapping operations, returning a new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> ?R - The specified mapping function. A return value of Some corresponds to a predicate of true for filtering, while None indicates false.

Returns:

- [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<R> - Returns a new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) after filtering and mapping.

### func fold\<R>(R, (R, T) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, T) -> R): R
```

Function: Computes from left to right using the specified initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The initial value of type R.
- operation: (R, T) -> R - The specified computation function.

Returns:

- R - Returns the final computed value.

### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

Function: Iterates over all elements, executing the given action.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The specified action function.

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if empty; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty HashSet
    let set = HashSet<String>()
    
    // Check initial state
    println("Initially empty: ${set.isEmpty()}")
    println("Initial size: ${set.size}")
    
    // Check after adding elements
    set.add("apple")
    set.add("banana")
    println("Empty after adding elements: ${set.isEmpty()}")
    println("Size after adding elements: ${set.size}")
    
    // Check after clearing
    set.clear()
    println("Empty after clearing: ${set.isEmpty()}")
    println("Size after clearing: ${set.size}")
    
    return 0
}
```

Output:

```text
Initially empty: true
Initial size: 0
Empty after adding elements: false
Size after adding elements: 2
Empty after clearing: true
Size after clearing: 0
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Returns an iterator for this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - Returns an iterator for this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    // Traverse elements using iterator
    println("Traversing with iterator:")
    let iter = set.iterator()
    while (true) {
        match (iter.next()) {
            case Some(element) => println("- ${element}")
            case None => break
        }
    }
    
    // Traverse elements using for-in loop (internally uses iterator)
    println("\nTraversing with for-in loop:")
    for (element in set) {
        println("- ${element}")
    }
    
    return 0
}
```

Output:

```text
Traversing with iterator:
- apple
- banana
- orange

Traversing with for-in loop:
- apple
- banana
- orange
```

### func map\<R>((T)->R)

```cangjie
public func map<R>(transform: (T) -> R): HashSet<R> where R <: Hashable & Equatable<R>
```

Function: Maps all elements of type T in the current [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) to elements of type R according to the transform function, forming a new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T)->R - The mapping function.

Returns:

- [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<R> - A new [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) composed of all elements from the original [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) after mapping.

### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

Function: Determines whether none of the elements in the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the elements in the current [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) satisfy the condition.

### func reduce((T, T) -> T)

```cangjie
public func reduce(operation: (T, T) -> T): Option<T>
```

Function: Computes from left to right using the first element as the initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (T, T) -> T - The specified computation function.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The computation result.

### func remove(T)

```cangjie
public func remove(element: T): Bool
```

Function: Removes the specified element from this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) if it exists.

Parameters:

- element: T - The element to be removed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true indicates successful removal; false indicates removal failure.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    println("Initial size: ${set.size}")
    
    // Remove existing element
    let result1 = set.remove("banana")
    println("Result of removing 'banana': ${result1}")
    println("Size after removal: ${set.size}")
    
    // Remove non-existent element
    let result2 = set.remove("grape")
    println("Result of removing 'grape': ${result2}")
    println("Final size: ${set.size}")
    
    // Check remaining elements
    println("Remaining elements:")
    for (element in set) {
        println("- ${element}")
    }
    
    return 0
}
```

Execution Result:

```text
Initial size: 3
Result of removing 'banana': true
Size after removal: 2
Result of removing 'grape': false
Final size: 2
Remaining elements:
- apple
- orange
```

### func remove(Collection\<T>)

```cangjie
public func remove(all!: Collection<T>): Unit
```

Function: Removes all elements from this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) that are also contained in the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be removed from this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    set.add("grape")
    set.add("cantaloupe")
    
    println("Initial size: ${set.size}")
    println("Initial elements:")
    for (element in set) {
        println("- ${element}")
    }
    
    // Remove elements from array
    let toRemove = ["apple", "grape", "mango"]  // Includes non-existent element
    set.remove(all: toRemove)
    
    println("\nAfter removing ${toRemove}:")
    println("Size after removal: ${set.size}")
    println("Remaining elements:")
    for (element in set) {
        println("- ${element}")
    }
    
    // Remove elements using another HashSet
    let otherSet = HashSet<String>()
    otherSet.add("banana")
    otherSet.add("cantaloupe")
    
    set.remove(all: otherSet)
    
    println("\nAfter further removing ${otherSet}:")
    println("Final size: ${set.size}")
    println("Final elements:")
    for (element in set) {
        println("- ${element}")
    }
    
    return 0
}
```

Execution Result:

```text
Initial size: 5
Initial elements:
- apple
- banana
- orange
- grape
- cantaloupe

After removing [apple, grape, mango]:
Size after removal: 3
Remaining elements:
- banana
- orange
- cantaloupe

After further removing [banana, cantaloupe]:
Final size: 1
Final elements:
- orange
```

### func removeIf((T) -> Bool)

```cangjie
public func removeIf(predicate: (T) -> Bool): Unit
```

Function: Takes a lambda expression and removes corresponding elements if they satisfy the `true` condition.

Parameters:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to determine whether to remove the element.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when elements are added or removed within the `predicate` in the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet and add numbers
    let set = HashSet<Int64>()
    set.add(1)
    set.add(2)
    set.add(3)
    set.add(4)
    set.add(5)
    set.add(6)
    
    println("Initial set:")
    for (element in set) {
        println("- ${element}")
    }
    println("Initial size: ${set.size}")
    
    // Remove even numbers
    set.removeIf({num: Int64 => num % 2 == 0})
    
    println("\nAfter removing even numbers:")
    for (element in set) {
        println("- ${element}")
    }
    println("Size after removal: ${set.size}")
    
    // Remove elements greater than 3
    set.removeIf({num: Int64 => num > 3})
    
    println("\nAfter removing elements > 3:")
    for (element in set) {
        println("- ${element}")
    }
    println("Final size: ${set.size}")
    
    return 0
}
```

Execution Result:

```text
Initial set:
- 1
- 2
- 3
- 4
- 5
- 6
Initial size: 6

After removing even numbers:
- 1
- 3
- 5
Size after removal: 3

After removing elements > 3:
- 1
- 3
Final size: 2
```

### func reserve(Int64)

```cangjie
public func reserve(additional: Int64): Unit
```

Function: Expands the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) by the additional size. No expansion occurs if additional is less than or equal to zero. No expansion occurs if the remaining capacity of the [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) is greater than or equal to additional. If the remaining capacity is less than additional, the maximum of (1.5 times the original capacity rounded down) and (additional + used capacity) is used for expansion.

Parameters:

- additional: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size to expand.

Exceptions:

- [OverflowException](../../core/core_package_api/core_package_exceptions.md#class-overflowexception) - Thrown when additional + used capacity exceeds Int64.Max.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    
    println("Initial capacity: ${set.capacity}")
    println("Initial size: ${set.size}")
    
    // Reserve additional capacity
    set.reserve(10)
    
    println("Capacity after reservation: ${set.capacity}")
    println("Size after reservation: ${set.size}")
    
    // Add more elements to test expansion
    for (i in 0..5) {
        set.add("item${i}")
    }
    
    println("Capacity after adding elements: ${set.capacity}")
    println("Size after adding elements: ${set.size}")
    
    // Attempt to reserve smaller capacity (no effect)
    let beforeCapacity = set.capacity
    set.reserve(1)
    
    println("Capacity after small reservation: ${set.capacity}")
    println("Whether changed: ${beforeCapacity != set.capacity}")
    
    return 0
}
```

Execution Result:

```text
Initial capacity: 16
Initial size: 2
Capacity after reservation: 16
Size after reservation: 2
Capacity after adding elements: 16
Size after adding elements: 7
Capacity after small reservation: 16
Whether changed: false
```

### func retain(Set\<T>)

```cangjie
public func retain(all!: Set<T>): Unit
```

Function: Retains only the elements in this [HashSet](collection_package_class.md#class-hashsett-where-t--hashable--equatablet) that are contained in the specified [Set](collection_package_interface.md#interface-sett).

Parameters:

- all!: [Set](collection_package_interface.md#interface-sett)\<T> - The [Set](collection_package_interface.md#interface-sett) whose elements are to be retained.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create original HashSet
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    set.add("grape")
    set.add("cantaloupe")
    
    println("Original set:")
    for (element in set) {
        println("- ${element}")
    }
    println("Original size: ${set.size}")
    
    // Create set of elements to retain
    let toRetain = HashSet<String>()
    toRetain.add("apple")
    toRetain.add("orange")
    toRetain.add("mango")  // Not present in original set
    
    println("\nElements to retain:")
    for (element in toRetain) {
        println("- ${element}")
    }
    
    // Retain specified elements
    set.retain(all: toRetain)
    
    println("\nSet after retention:")
    for (element in set) {
        println("- ${element}")
    }
    println("Size after retention: ${set.size}")
    
    return 0
}
```

Execution Result:

```text
Original set:
- apple
- banana
- orange
- grape
- cantaloupe
Original size: 5

Elements to retain:
- apple
- orange
- mango

Set after retention:
- apple
- orange
Size after retention: 2
```

### func subsetOf(ReadOnlySet\<T>)

```cangjie
public func subsetOf(other: ReadOnlySet<T>): Bool
```

Function: Checks whether this set is a subset of another [ReadOnlySet](collection_package_interface.md#interface-readonlysett).

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set to compare against.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this [Set](collection_package_interface.md#interface-sett) is a subset of the specified [ReadOnlySet](collection_package_interface.md#interface-readonlysett); otherwise returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create parent set
    let superSet = HashSet<String>()
    superSet.add("apple")
    superSet.add("banana")
    superSet.add("orange")
    superSet.add("grape")
    
    // Create subset
    let subSet = HashSet<String>()
    subSet.add("apple")
    subSet.add("banana")
    
    println("Parent set: ${superSet}")
    println("Subset: ${subSet}")
    println("Is subset of parent: ${subSet.subsetOf(superSet)}")
    
    // Test non-subset relationship
    let nonSubSet = HashSet<String>()
    nonSubSet.add("apple")
    nonSubSet.add("cantaloupe")  // Not present in parent set
    
    println("\nNon-subset: ${nonSubSet}")
    println("Is non-subset of parent: ${nonSubSet.subsetOf(superSet)}")
    
    // Test empty set (empty set is subset of any set)
    let emptySet = HashSet<String>()
    println("\nEmpty set: ${emptySet}")
    println("Is empty set subset of parent: ${emptySet.subsetOf(superSet)}")
    
    // Test self-subset relationship
    println("Is parent set subset of itself: ${superSet.subsetOf(superSet)}")
    
    return 0
}
```

Execution Result:

```text
Parent set: [apple, banana, orange, grape]
Subset: [apple, banana]
Is subset of parent: true

Non-subset: [apple, cantaloupe]
Is non-subset of parent: false

Empty set: []
Is empty set subset of parent: true
Is parent set subset of itself: true
```

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements in the container.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create HashSet and add elements
    let set = HashSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("orange")
    
    println("Set size: ${set.size}")
    
    // Convert to array
    let array = set.toArray()
    
    println("Array size: ${array.size}")
    println("Array elements:")
    for (i in 0..array.size) {
        println("[${i}] = ${array[i]}")
    }
    
    // Verify array contains all set elements
    println("\nElement verification:")
    for (element in set) {
        var found = false
        for (i in 0..array.size) {
            if (array[i] == element) {
                found = true
                break
            }
        }
        println("'${element}' in array: ${found}")
    }
    
    return 0
}
```

Execution Result:

```text
Set size: 3
Array size: 3
Array elements:
[0] = apple
[1] = banana
[2] = orange

Element verification:
'apple' in array: true
'banana' in array: true
'orange' in array: true
```

### operator func &(ReadOnlySet\<T>)

```cangjie
public operator func &(other: ReadOnlySet<T>): HashSet<T>
```

Function: Returns a new set containing the intersection of two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two sets
    let set1 = HashSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("orange")
    
    let set2 = HashSet<String>()
    set2.add("banana")
    set2.add("orange")
    set2.add("grape")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate intersection (common elements)
    let intersection = set1 & set2
    println("Intersection (set1 & set2): ${intersection}")
    println("Intersection size: ${intersection.size}")
    
    // Test empty intersection
    let set3 = HashSet<String>()
    set3.add("cantaloupe")
    set3.add("mango")
    
    let emptyIntersection = set1 & set3
    println("\nSet 3: ${set3}")
    println("Empty intersection (set1 & set3): ${emptyIntersection}")
    println("Empty intersection size: ${emptyIntersection.size}")
    
    // Test self-intersection
    let selfIntersection = set1 & set1
    println("\nSelf-intersection (set1 & set1): ${selfIntersection}")
    println("Self-intersection size: ${selfIntersection.size}")
    
    return 0
}
```

Execution Result:

```text
Set 1: [apple, banana, orange]
Set 2: [banana, orange, grape]
Intersection (set1 & set2): [banana, orange]
Intersection size: 2

Set 3: [cantaloupe, mango]
Empty intersection (set1 & set3): []
Empty intersection size: 0

Self-intersection (set1 & set1): [apple, banana, orange]
Self-intersection size: 3
```

### operator func |(ReadOnlySet\<T>)

```cangjie
public operator func |(other: ReadOnlySet<T>): HashSet<T>
```

Function: Returns a new set containing the union of two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two sets
    let set1 = HashSet<String>()
    set1.add("apple")
    set1.add("banana")
    
    let set2 = HashSet<String>()
    set2.add("banana")
    set2.add("orange")
    set2.add("grape")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate union (all elements without duplicates)
    let union = set1 | set2
    println("Union (set1 | set2): ${union}")
    println("Union size: ${union.size}")
    
    // Test union with empty set
    let emptySet = HashSet<String>()
    let unionWithEmpty = set1 | emptySet
    println("\nEmpty set: ${emptySet}")
    println("Union with empty set (set1 | empty): ${unionWithEmpty}")
    println("Union with empty set size: ${unionWithEmpty.size}")
    
    // Test self-union
    let selfUnion = set1 | set1
    println("\nSelf-union (set1 | set1): ${selfUnion}")
    println("Self-union size: ${selfUnion.size}")
    
    // Test completely distinct sets
    let set3 = HashSet<String>()
    set3.add("cantaloupe")
    set3.add("mango")
    
    let disjointUnion = set1 | set3
    println("\nSet 3: ${set3}")
    println("Union of distinct sets (set1 | set3): ${disjointUnion}")
    println("Union of distinct sets size: ${disjointUnion.size}")
    
    return 0
}
```

Execution Result:

```text
Set 1: [apple, banana]
Set 2: [banana, orange, grape]
Union (set1 | set2): [apple, banana, orange, grape]
Union size: 4

Empty set: []
Union with empty set (set1 | empty): [apple, banana]
Union with empty set size: 2

Self-union (set1 | set1): [apple, banana]
Self-union size: 2

Set 3: [cantaloupe, mango]
Union of distinct sets (set1 | set3): [apple, banana, cantaloupe, mango]
Union of distinct sets size: 4
```

### operator func -(ReadOnlySet\<T>)

```cangjie
public operator func -(other: ReadOnlySet<T>): HashSet<T>
```

Function: Returns a new set containing the difference between two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two overlapping sets
    let set1 = HashSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("orange")
    
    let set2 = HashSet<String>()
    set2.add("banana")
    set2.add("grape")
    set2.add("cantaloupe")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate difference (set1 - set2)
    let difference = set1 - set2
    println("Difference (set1 - set2): ${difference}")
    println("Difference size: ${difference.size}")
    
    // Calculate reverse difference (set2 - set1)
    let reverseDifference = set2 - set1
    println("\nReverse difference (set2 - set1): ${reverseDifference}")
    println("Reverse difference size: ${reverseDifference.size}")
    
    // Difference with empty set
    let emptySet = HashSet<String>()
    let diffWithEmpty = set1 - emptySet
    println("\nDifference with empty set (set1 - empty): ${diffWithEmpty}")
    println("Difference with empty set size: ${diffWithEmpty.size}")
    
    // Self-difference
    let selfDiff = set1 - set1
    println("\nSelf-difference (set1 - set1): ${selfDiff}")
    println("Self-difference size: ${selfDiff.size}")
    
    return 0
}
```

Execution Result:

```text
Set 1: [apple, banana, orange]
Set 2: [banana, grape, cantaloupe]
Difference (set1 - set2): [apple, orange]
Difference size: 2

Reverse difference (set2 - set1): [grape, cantaloupe]
Reverse difference size: 2

Difference with empty set (set1 - empty): [apple, banana, orange]
Difference with empty set size: 3

Self-difference (set1 - set1): []
Self-difference size: 0
```

### extend\<T> HashSet\<T> <: Equatable\<HashSet\<T>>

```cangjie
extend<T> HashSet<T> <: Equatable<HashSet<T>>
```

Function: Extends [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> with [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T>> interface to support equality comparison.

Parent Type:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T>>

#### operator func ==(HashSet\<T>)

```cangjie
public operator func ==(that: HashSet<T>): Bool
```

Function: Determines whether the current instance is equal to the specified [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> instance.

Two [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> instances are considered equal if they contain identical elements.

Parameters:

- that: [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two identical HashSets
    let set1 = HashSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("orange")
    
    let set2 = HashSet<String>()
    set2.add("banana")
    set2.add("apple")  // Different order but same elements
    set2.add("orange")
    
    // Compare identical sets
    println("Set 1 size: ${set1.size}")
    println("Set 2 size: ${set2.size}")
    println("Set 1 == Set 2: ${set1 == set2}")
    
    // Create different HashSet
    let set3 = HashSet<String>()
    set3.add("apple")
    set3.add("grape")  // Different element
    
    println("\nSet 3 size: ${set3.size}")
    println("Set 1 == Set 3: ${set1 == set3}")
    
    // Test empty sets
    let emptySet1 = HashSet<String>()
    let emptySet2 = HashSet<String>()
    
    println("\nEmpty set 1 == Empty set 2: ${emptySet1 == emptySet2}")
    println("Empty set == Non-empty set: ${emptySet1 == set1}")
    
    return 0
}
```

Execution Result:

```text
Set 1 size: 3
Set 2 size: 3
Set 1 == Set 2: true

Set 3 size: 2
Set 1 == Set 3: false

Empty set 1 == Empty set 2: true
Empty set == Non-empty set: false
```

#### operator func !=(HashSet\<T>)

```cangjie
public operator func !=(that: HashSet<T>): Bool
```

Function: Determines whether the current instance is not equal to the specified [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> instance.

Parameters:

- that: [HashSet](./collection_package_class.md#class-hashsett-wwhere-t--hashable--equatablet)\<T> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two different HashSets
    let set1 = HashSet<String>()
    set1.add("apple")
    set1.add("banana")
    
    let set2 = HashSet<String>()
    set2.add("apple")
    set2.add("orange")  // Different element
    
    println("Set 1: [apple, banana]")
    println("Set 2: [apple, orange]")
    println("Set 1 != Set 2: ${set1 != set2}")
    
    // Test identical sets
    let set3 = HashSet<String>()
    set3.add("apple")
    set3.add("banana")
    
    println("\nSet 3: [apple, banana]")
    println("Set 1 != Set 3: ${set1 != set3}")
    
    // Test empty vs non-empty sets
    let emptySet = HashSet<String>()
    
    println("\nEmpty set != Non-empty set: ${emptySet != set1}")
    
    // Test two empty sets
    let anotherEmptySet = HashSet<String>()
    println("Empty set 1 != Empty set 2: ${emptySet != anotherEmptySet}")
    
    return 0
}
```

Execution Result:

```text
Set 1: [apple, banana]
Set 2: [apple, orange]
Set 1 != Set 2: true

Set 3: [apple, banana]
Set 1 != Set 3: false

Empty set != Non-empty set: true
Empty set 1 != Empty set 2: false
```

### extend\<T> HashSet\<T> <: ToString where T <: ToString

```cangjie
extend<T> HashSet<T> <: ToString where T <: ToString
```

Function: Extends [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> with [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface to support string conversion.

Parent Type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T> instance to a string.

The resulting string contains string representations of all elements in the [HashSet](./collection_package_class.md#class-hashsett-where-t--hashable--equatablet)\<T>, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty HashSet
    let emptySet = HashSet<String>()
    println("Empty set: ${emptySet.toString()}")
    
    // Create a single-element HashSet
    let singleSet = HashSet<String>()
    singleSet.add("apple")
    println("Single-element set: ${singleSet.toString()}")
    
    // Create a multi-element HashSet
    let multiSet = HashSet<String>()
    multiSet.add("apple")
    multiSet.add("banana")
    multiSet.add("orange")
    
    println("Multi-element set: ${multiSet.toString()}")
    
    // Use numeric type HashSet
    let numSet = HashSet<Int64>()
    numSet.add(1)
    numSet.add(2)
    numSet.add(3)
    
    println("Numeric set: ${numSet.toString()}")
    
    // Direct usage in println (automatically calls toString)
    println("Automatic toString call: ${multiSet}")
    
    return 0
}
```

Execution results:

```text
Empty set: []
Single-element set: [apple]
Multi-element set: [apple, banana, orange]
Numeric set: [1, 2, 3]
Automatic toString call: [apple, banana, orange]
```

## class LinkedListNode\<T>

```cangjie
public class LinkedListNode<T>
```

Function: [LinkedListNode](collection_package_class.md#class-linkedlistnodet) is a node in [LinkedList](collection_package_class.md#class-linkedlistt).

Through [LinkedListNode](collection_package_class.md#class-linkedlistnodet), you can perform forward and backward traversal operations on [LinkedList](collection_package_class.md#class-linkedlistt), as well as access and modify element values.

[LinkedListNode](collection_package_class.md#class-linkedlistnodet) can only be obtained via the 'nodeAt', 'firstNode', or 'lastNode' methods of the corresponding [LinkedList](collection_package_class.md#class-linkedlistt). When a node is removed from [LinkedList](collection_package_class.md#class-linkedlistt), it becomes a dangling node. Any operation on a dangling node will throw an '[IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception)' exception.

### prop next

```cangjie
public prop next: Option<LinkedListNode<T>>
```

Function: Gets the next node of the current node, returns None if there isn't one.

Type: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T>>

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    
    // Get first node and check its next property
    let firstNode = list.firstNode
    if (let Some(node) <- firstNode) {
        let nextNode = node.next
        if (let Some(next) <- nextNode) {
            println("Next node value: ${next.value}")
        } else {
            println("No next node")
        }
    } else {
        println("List is empty")
    }
    
    // Get last node and check its next property
    let lastNode = list.lastNode
    if (let Some(node) <- lastNode) {
        let nextNode = node.next
        if (let Some(next) <- nextNode) {
            println("Next node value: ${next.value}")
        } else {
            println("No next node")
        }
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
Next node value: 20
No next node
```

### prop prev

```cangjie
public prop prev: Option<LinkedListNode<T>>
```

Function: Gets the previous node of the current node, returns None if there isn't one.

Type: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T>>

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    
    // Get last node and check its prev property
    let lastNode = list.lastNode
    if (let Some(node) <- lastNode) {
        let prevNode = node.prev
        if (let Some(prev) <- prevNode) {
            println("Previous node value: ${prev.value}")
        } else {
            println("No previous node")
        }
    } else {
        println("List is empty")
    }
    
    // Get first node and check its prev property
    let firstNode = list.firstNode
    if (let Some(node) <- firstNode) {
        let prevNode = node.prev
        if (let Some(prev) <- prevNode) {
            println("Previous node value: ${prev.value}")
        } else {
            println("No previous node")
        }
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
Previous node value: 20
No previous node
```

### prop value

```cangjie
public mut prop value: T
```

Function: Gets or modifies the value of the element.

Type: T

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    
    // Get first node and access its value property
    let firstNode = list.firstNode
    if (let Some(node) <- firstNode) {
        println("First node value: ${node.value}")
        
        // Modify node's value
        node.value = 100
        println("Modified first node value: ${node.value}")
    } else {
        println("List is empty")
    }
    
    // Verify first node's value was modified
    if (let Some(node) <- list.firstNode) {
        println("Confirmed first node value: ${node.value}")
    }
    
    return 0
}
```

Output:

```text
First node value: 10
Modified first node value: 100
Confirmed first node value: 100
```

## class LinkedList\<T>

```cangjie
public class LinkedList<T> <: Collection<T> {
    public init()
    public init(elements: Collection<T>)
    public init(elements: Array<T>)
    public init(size: Int64, initElement: (Int64)-> T)
}
```

Function: Implements a doubly linked list data structure.

A doubly linked list is a common data structure consisting of a sequence of nodes, where each node contains two pointers: one pointing to the previous node and another pointing to the next node. This structure allows bidirectional traversal from any node, either forward from the head or backward from the tail.

[LinkedList](collection_package_class.md#class-linkedlistt) does not support concurrent operations. Modifications to elements in the collection will not invalidate iterators, but adding or removing elements will.

Parent Types:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T>

### prop first

```cangjie
public prop first: ?T
```

Function: The value of the first element in the linked list, returns None if the list is empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Empty list case
    let firstValue1 = list.first
    if (let Some(value) <- firstValue1) {
        println("First element: ${value}")
    } else {
        println("List is empty")
    }
    
    // After adding elements
    list.addLast(100)
    list.addLast(200)
    list.addLast(300)
    
    let firstValue2 = list.first
    if (let Some(value) <- firstValue2) {
        println("First element: ${value}")
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
List is empty
First element: 100
```

### prop firstNode

```cangjie
public prop firstNode: ?LinkedListNode<T>
```

Function: Gets the node of the first element in the linked list.

Type: ?[LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T>

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Empty list case
    let firstNode1 = list.firstNode
    if (let Some(node) <- firstNode1) {
        println("First node value: ${node.value}")
    } else {
        println("List is empty")
    }
    
    // After adding elements
    list.addLast(100)
    list.addLast(200)
    list.addLast(300)
    
    let firstNode2 = list.firstNode
    if (let Some(node) <- firstNode2) {
        println("First node value: ${node.value}")
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
List is empty
First node value: 100
```

### prop last

```cangjie
public prop last: ?T
```

Function: The value of the last element in the linked list, returns None if the list is empty.

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Empty list case
    let lastValue1 = list.last
    if (let Some(value) <- lastValue1) {
        println("Last element: ${value}")
    } else {
        println("List is empty")
    }
    
    // After adding elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    
    let lastValue2 = list.last
    if (let Some(value) <- lastValue2) {
        println("Last element: ${value}")
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
List is empty
Last element: 30
```

### prop lastNode

```cangjie
public prop lastNode: ?LinkedListNode<T>
```

Function: Gets the node of the last element in the linked list.

Type: ?[LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T>

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Empty list case
    let lastNode1 = list.lastNode
    if (let Some(node) <- lastNode1) {
        println("Last node value: ${node.value}")
    } else {
        println("List is empty")
    }
    
    // After adding elements
    list.addLast(100)
    list.addLast(200)
    list.addLast(300)
    
    let lastNode2 = list.lastNode
    if (let Some(node) <- lastNode2) {
        println("Last node value: ${node.value}")
    } else {
        println("List is empty")
    }
    
    return 0
}
```

Output:

```text
List is empty
Last node value: 300
```

### prop size

```cangjie
public prop size: Int64
```

Function: The number of elements in the linked list.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Check size of empty list
    println("Empty list size: ${list.size}")
    
    // Add elements and observe size changes
    list.addLast("First")
    println("Size after adding one element: ${list.size}")
    
    list.addLast("Second")
    list.addLast("Third")
    println("Size after adding three elements: ${list.size}")
    
    // Remove element and observe size change
    list.removeFirst()
    println("Size after removing one element: ${list.size}")
    
    // Clear the list
    list.clear()
    println("Size after clearing: ${list.size}")
    
    return 0
}
```

Output:

```text
Empty list size: 0
Size after adding one element: 1
Size after adding three elements: 3
Size after removing one element: 2
Size after clearing: 0
```

### init()

```cangjie
public init()
```

Function: Constructs an empty linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty LinkedList
    let list = LinkedList<Int64>()
    
    // Check properties of empty list
    println("Newly created list size: ${list.size}")
    println("Is empty: ${list.isEmpty()}")
    
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    } else {
        println("List is empty, no first element")
    }
    
    // Validate by adding elements
    list.addLast(42)
    println("Size after adding element: ${list.size}")
    
    return 0
}
```

Output:

```text
Newly created list size: 0
Is empty: true
List is empty, no first element
Size after adding element: 1
```

### init(Array\<T>)

```cangjie
public init(elements: Array<T>)
```

Function: Constructs a [LinkedList](collection_package_class.md#class-linkedlistt) instance containing elements from the specified array in traversal order.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - The array of elements to be placed in this linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create LinkedList from Array
    let arr = [10, 20, 30, 40, 50]
    let list = LinkedList<Int64>(arr)
    
    // Check list properties
    println("List size created from array: ${list.size}")
    
    // Check first and last elements
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    }
    
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    }
    
    // Verify order: iterate all elements
    print("All elements in list: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    return 0
}
```

Output:

```text
List size created from array: 5
First element: 10
Last element: 50
All elements in list: 10 20 30 40 50 
```

### init(Collection\<T>)

```cangjie
public init(elements: Collection<T>)
```

Function: Constructs a linked list containing elements from the specified collection in the order returned by the collection's iterator.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be placed in this linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // First create an ArrayList as Collection
    let arrayList = ArrayList<Int64>()
    arrayList.add(100)
    arrayList.add(200)
    arrayList.add(300)
    
    // Create LinkedList from Collection
    let list = LinkedList<Int64>(arrayList)
    
    // Check list properties
    println("List size created from Collection: ${list.size}")
    
    // Check first and last elements
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    }
    
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    }
    
    // Verify order: iterate all elements
    print("All elements in list: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    return 0
}
```

Output:

```text
List size created from Collection: 3
First element: 100
Last element: 300
All elements in list: 100 200 300 
```

### init(Int64, (Int64)-> T)

```cangjie
public init(size: Int64, initElement: (Int64)-> T)
```

Function: Creates a linked list containing 'size' elements where the nth element satisfies the ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64))-> T condition.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of elements to create in the linked list.
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) ->T - The element initialization parameter.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified list length is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create LinkedList using lambda function
    let list = LinkedList<Int64>(5, {index: Int64 => index * 10})
    
    // Check list properties
    println("List size created with lambda: ${list.size}")
    
    // Check first and last elements
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    }
    
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    }
    
    // Verify all elements
    print("All elements in list: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    return 0
}
```

Output:

```text
List size created with lambda: 5
First element: 0
Last element: 40
All elements in list: 0 10 20 30 40 
```

### func addLast(T)

```cangjie
public func addLast(element: T): LinkedListNode<T>
```

Function: Adds an element at the tail position of the linked list and returns the node of this element.

Parameters:

- element: T - The element to be added to the linked list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The node pointing to this element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add element to empty list
    let node1 = list.addLast("First")
    println("List size after adding first element: ${list.size}")
    println("Returned node value: ${node1.value}")
    
    // Add more elements
    list.addLast("Second")
    list.addLast("Third")
    
    println("List size after adding three elements: ${list.size}")
    
    // Verify element order
    print("All elements in list: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Verify last node
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    }
    
    return 0
}
```

Output:

```text
List size after adding first element: 1
Returned node value: First
List size after adding three elements: 3
All elements in list: First Second Third 
Last element: Third
```

### func backward(LinkedListNode\<T>)

```cangjie
public func backward(mark: LinkedListNode<T>): Iterator<T>
```

Function: Gets an iterator for all elements starting from the mark node to the head node of the corresponding linked list.

Parameters:

- mark: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The starting element node.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - The iterator for corresponding elements.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node doesn't belong to any linked list instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    list.addLast(40)
    list.addLast(50)
    
    // Get a middle node (index 2, value 30)
    let middleNode = list.nodeAt(2)
    if (let Some(node) <- middleNode) {
        println("Backward traversal starting from node value ${node.value}:")
        
        // Use backward method to traverse from middle node to head
        let iterator = list.backward(node)
        for (element in iterator) {
            print("${element} ")
        }
        println()
    }
    
    // Traverse backward from last node
    let lastNode = list.lastNode
    if (let Some(node) <- lastNode) {
        println("Backward traversal starting from last node value ${node.value}:")
        
        let iterator = list.backward(node)
        for (element in iterator) {
            print("${element} ")
        }
        println()
    }
    
    return 0
}
```

Output:

```text
Backward traversal starting from node value 30:
30 20 10 
Backward traversal starting from last node value 50:
50 40 30 20 10 
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Removes all elements from the linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("Element1")
    list.addLast("Element2")
    list.addLast("Element3")
    list.addLast("Element4")
    
    println("List size before clearing: ${list.size}")
    println("Is empty before clearing: ${list.isEmpty()}")
    
    // Display elements before clearing
    print("Elements before clearing: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Clear all elements
    list.clear()
    
    println("List size after clearing: ${list.size}")
    println("Is empty after clearing: ${list.isEmpty()}")
    
    // Verify first and last elements are null
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    } else {
        println("No first element")
    }
    
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    } else {
        println("No last element")
    }
    
    return 0
}
```

Execution Result:

```text
List size before clearing: 4
Is empty before clearing: false
Elements before clearing: Element1 Element2 Element3 Element4 
List size after clearing: 0
Is empty after clearing: true
No first element
No last element
```

### func forward(LinkedListNode\<T>)

```cangjie
public func forward(mark: LinkedListNode<T>): Iterator<T>
```

Function: Obtains an iterator for all elements starting from the mark node to the tail node of the corresponding linked list.

Parameters:

- mark: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The starting element node.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - Iterator for corresponding elements.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add elements
    list.addLast(10)
    list.addLast(20)
    list.addLast(30)
    list.addLast(40)
    list.addLast(50)
    
    // Get first node and traverse forward from it
    let firstNode = list.firstNode
    if (let Some(node) <- firstNode) {
        println("Forward traversal starting from node value ${node.value}:")
        
        let iterator = list.forward(node)
        for (element in iterator) {
            print("${element} ")
        }
        println()
    }
    
    // Get a middle node (node at index 2 with value 30)
    let middleNode = list.nodeAt(2)
    if (let Some(node) <- middleNode) {
        println("Forward traversal starting from node value ${node.value}:")
        
        // Use forward method to traverse from middle node to tail
        let iterator = list.forward(node)
        for (element in iterator) {
            print("${element} ")
        }
        println()
    }
    
    return 0
}
```

Execution Result:

```text
Forward traversal starting from node value 10:
10 20 30 40 50 
Forward traversal starting from node value 30:
30 40 50 
```

### func addAfter(LinkedListNode\<T>,T)

```cangjie
public func addAfter(node: LinkedListNode<T>, element: T): LinkedListNode<T>
```

Function: Inserts an element after the specified node in the linked list and returns the node of the inserted element.

Parameters:

- node: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The specified node.
- element: T - Element to be added to the linked list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - Node pointing to the inserted element.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified node does not belong to this linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add initial elements
    list.addLast("First")
    list.addLast("Second")
    list.addLast("Fourth")
    
    println("Linked list before insertion:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Get second node (index 1, value "Second")
    let secondNode = list.nodeAt(1)
    if (let Some(node) <- secondNode) {
        println("Insert 'Third' after node '${node.value}'")
        
        // Insert new element after second node
        let newNode = list.addAfter(node, "Third")
        println("Insertion successful, new node value: ${newNode.value}")
    }
    
    println("Linked list after insertion:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    println("List size: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
Linked list before insertion:
First Second Fourth 
Insert 'Third' after node 'Second'
Insertion successful, new node value: Third
Linked list after insertion:
First Second Third Fourth 
List size: 4
```

### func addBefore(LinkedListNode\<T>,T)

```cangjie
public func addBefore(node: LinkedListNode<T>, element: T): LinkedListNode<T>
```

Function: Inserts an element before the specified node in the linked list and returns the node of the inserted element.

Parameters:

- node: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The specified node.
- element: T - Element to be added to the linked list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - Node pointing to the inserted element.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified node does not belong to this linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add initial elements
    list.addLast("First")
    list.addLast("Third")
    list.addLast("Fourth")
    
    println("Linked list before insertion:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Get second node (index 1, value "Third")
    let thirdNode = list.nodeAt(1)
    if (let Some(node) <- thirdNode) {
        println("Insert 'Second' before node '${node.value}'")
        
        // Insert new element before third node
        let newNode = list.addBefore(node, "Second")
        println("Insertion successful, new node value: ${newNode.value}")
    }
    
    println("Linked list after insertion:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    println("List size: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
Linked list before insertion:
First Third Fourth 
Insert 'Second' before node 'Third'
Insertion successful, new node value: Second
Linked list after insertion:
First Second Third Fourth 
List size: 4
```

### func addFirst(T)

```cangjie
public func addFirst(element: T): LinkedListNode<T>
```

Function: Inserts an element at the head of the linked list and returns the node of the inserted element.

Parameters:

- element: T - Element to be added to the linked list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - Node pointing to the element.

### func addLast(T)

```cangjie
public func addLast(element: T): LinkedListNode<T>
```

Function: Appends an element at the tail of the linked list and returns the node of the inserted element.

Parameters:

- element: T - Element to be added to the linked list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - Node pointing to the element.

### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

Function: Determines whether all elements in the linked list satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements satisfy the condition, otherwise false.

### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

Function: Determines whether any element in the linked list satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether any element satisfies the condition.

### func backward(LinkedListNode\<T>)

```cangjie
public func backward(mark: LinkedListNode<T>): Iterator<T>
```

Function: Obtains an iterator for all elements starting from the mark node to the head node of the corresponding linked list.

Parameters:

- mark: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The starting element node.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - Iterator for corresponding elements.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

### func clear()

```cangjie
public func clear(): Unit
```

Function: Removes all elements from the linked list.

### func filter((T) -> Bool)
```cangjie
public func filter(predicate: (T) -> Bool): LinkedList<T>
```

Function: Returns a new linked list containing elements that satisfy the filtering condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<T> - Returns a new linked list containing elements that satisfy the condition.### func filterMap\<R>((T) -> ?R)

```cangjie
public func filterMap<R>(transform: (T) -> ?R): LinkedList<R>
```

Function: Performs both filtering and mapping operations simultaneously, returning a new [LinkedList](collection_package_class.md#class-linkedlistt).

Parameters:

- transform: (T) -> ?R - The given mapping function. A return value of Some corresponds to the filter's predicate being true, while None indicates false.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<R> - Returns a new linked list after filtering and mapping.

### func flatMap\<R>((T) -> LinkedList\<R>)

```cangjie
public func flatMap<R>(transform: (T) -> LinkedList<R>): LinkedList<R> 
```

Function: Applies a transform closure to each element in the linked list, which returns a new linked list, then flattens and concatenates all returned linked lists into a single resulting linked list.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> [LinkedList](collection_package_class.md#class-linkedlistt)\<R> - The given mapping function.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<R> - A new linked list after being "mapped" and "flattened."

### func fold\<R>(R, (R, T) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, T) -> R): R
```

Function: Computes from left to right using the specified initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The given initial value of type R.
- operation: (R, T) -> R - The given computation function.

Returns:

- R - The final computed value.

### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

Function: Iterates over all elements and executes the given action.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The given action function.

### func forward(LinkedListNode\<T>)

```cangjie
public func forward(mark: LinkedListNode<T>): Iterator<T>
```

Function: Retrieves an iterator for all elements starting from the `mark` node to the tail node of the corresponding linked list.

Parameters:

- mark: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The starting element node.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the corresponding elements.

Exceptions:

- [IllegalStateException](../../core/core_package_api/core_package_exceptions.md#class-illegalstateexception) - Thrown if the node does not belong to any linked list instance.

### func intersperse(T)

```cangjie
public func intersperse(separator: T): LinkedList<T> 
```

Function: Returns a new [LinkedList](collection_package_class.md#class-linkedlistt) with the given new element inserted between every two existing elements.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- separator: T - The given element.

Returns:

- LinkedList\<T> - Returns a new linked list.

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether this linked list is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this linked list contains no elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Check empty linked list
    println("Is the newly created linked list empty: ${list.isEmpty()}")
    println("Linked list size: ${list.size}")
    
    // Add an element
    list.addLast(10)
    println("Is the linked list empty after adding one element: ${list.isEmpty()}")
    println("Linked list size: ${list.size}")
    
    // Add more elements
    list.addLast(20)
    list.addLast(30)
    println("Is the linked list empty after adding more elements: ${list.isEmpty()}")
    println("Linked list size: ${list.size}")
    
    // Clear the linked list
    list.clear()
    println("Is the linked list empty after clearing: ${list.isEmpty()}")
    println("Linked list size: ${list.size}")
    
    return 0
}
```

Output:

```text
Is the newly created linked list empty: true
Linked list size: 0
Is the linked list empty after adding one element: false
Linked list size: 1
Is the linked list empty after adding more elements: false
Linked list size: 3
Is the linked list empty after clearing: true
Linked list size: 0
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Returns an iterator for the elements in the current collection, ordered from the first node to the last node of the linked list.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the elements in the current collection.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("Apple")
    list.addLast("Banana")
    list.addLast("Orange")
    list.addLast("Grape")
    
    println("Traversing the linked list using iterator():")
    
    // Get the iterator and traverse all elements
    let iter = list.iterator()
    for (element in iter) {
        print("${element} ")
    }
    println()
    
    // Verify iterator order (from first to last)
    println("Verify iteration order:")
    println("First element: ${list.first}")
    println("Last element: ${list.last}")
    
    // Use for-in syntax (internally uses iterator())
    println("Traversing using for-in syntax:")
    for (fruit in list) {
        print("${fruit} ")
    }
    println()
    
    return 0
}
```

Output:

```text
Traversing the linked list using iterator():
Apple Banana Orange Grape 
Verify iteration order:
First element: Some(Apple)
Last element: Some(Grape)
Traversing using for-in syntax:
Apple Banana Orange Grape 
```

### func map\<R>((T) -> R)

```cangjie
public func map<R>(transform: (T) -> R): LinkedList<R>
```

Function: Maps this [LinkedList](collection_package_class.md#class-linkedlistt) and returns a new [LinkedList](collection_package_class.md#class-linkedlistt).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> R - The given mapping function.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<R> - Returns a new [LinkedList](collection_package_class.md#class-linkedlistt).

### func nodeAt(Int64)

```cangjie
public func nodeAt(index: Int64): Option<LinkedListNode<T>>
```

Function: Retrieves the node of the element at the specified `index` in the linked list, where indexing starts from 0.

This function has a time complexity of O(n).

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the element node to retrieve.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T>> - The node at the specified `index`, or None if it does not exist.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("Index0")
    list.addLast("Index1")
    list.addLast("Index2")
    list.addLast("Index3")
    list.addLast("Index4")
    
    println("Linked list size: ${list.size}")
    
    // Retrieve nodes at valid indices
    let node0 = list.nodeAt(0)
    if (let Some(node) <- node0) {
        println("Node value at index 0: ${node.value}")
    } else {
        println("No node at index 0")
    }
    
    let node2 = list.nodeAt(2)
    if (let Some(node) <- node2) {
        println("Node value at index 2: ${node.value}")
    } else {
        println("No node at index 2")
    }
    
    let node4 = list.nodeAt(4)
    if (let Some(node) <- node4) {
        println("Node value at index 4: ${node.value}")
    } else {
        println("No node at index 4")
    }
    
    // Attempt to retrieve an out-of-bounds index
    let node5 = list.nodeAt(5)
    if (let Some(node) <- node5) {
        println("Node value at index 5: ${node.value}")
    } else {
        println("No node at index 5 (out of bounds)")
    }
    
    // Attempt a negative index
    let nodeNeg = list.nodeAt(-1)
    if (let Some(node) <- nodeNeg) {
        println("Node value at index -1: ${node.value}")
    } else {
        println("No node at index -1 (negative index)")
    }
    
    return 0
}
```

Output:

```text
Linked list size: 5
Node value at index 0: Index0
Node value at index 2: Index2
Node value at index 4: Index4
No node at index 5 (out of bounds)
No node at index -1 (negative index)
```

### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

Function: Determines whether none of the elements in this linked list satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the elements in the current linked list satisfy the condition.

### func reduce((T, T) -> T)

```cangjie
public func reduce(operation: (T, T) -> T): Option<T>
```

Function: Computes from left to right using the first element as the initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (T, T) -> T - The given computation function.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - Returns the computation result.

### func removeFirst()

```cangjie
public func removeFirst(): ?T
```

Function: Removes the first element of the linked list and returns its value.

Returns:

- ?T - The value of the removed element, or None if the linked list is empty.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Attempt to remove from an empty linked list
    let removedFromEmpty = list.removeFirst()
    if (let Some(value) <- removedFromEmpty) {
        println("Element removed from empty linked list: ${value}")
    } else {
        println("Cannot remove from an empty linked list")
    }
    
    // Add some elements
    list.addLast("First")
    list.addLast("Second")
    list.addLast("Third")
    list.addLast("Fourth")
    
    println("Linked list before removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Linked list size before removal: ${list.size}")
    
    // Remove the first element
    let removed1 = list.removeFirst()
    if (let Some(value) <- removed1) {
        println("First removed element: ${value}")
    }
    
    println("Linked list after one removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Linked list size after removal: ${list.size}")
    
    // Remove the first element again
    let removed2 = list.removeFirst()
    if (let Some(value) <- removed2) {
        println("Second removed element: ${value}")
    }
    
    println("Final linked list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Final linked list size: ${list.size}")
    
    return 0
}
```

Output:

```text
Cannot remove from an empty linked list
Linked list before removal:
First Second Third Fourth 
Linked list size before removal: 4
First removed element: First
Linked list after one removal:
Second Third Fourth 
Linked list size after removal: 3
Second removed element: Second
Final linked list:
Third Fourth 
Final linked list size: 2
```

### func removeLast()

```cangjie
public func removeLast(): ?T
```

Function: Removes the last element from the linked list and returns its value.

Returns:

- ?T - The value of the removed element, or None if the list is empty.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Attempt to remove from an empty list
    let removedFromEmpty = list.removeLast()
    if (let Some(value) <- removedFromEmpty) {
        println("Removed element from empty list: ${value}")
    } else {
        println("Cannot remove from empty list")
    }
    
    // Add some elements
    list.addLast("First")
    list.addLast("Second")
    list.addLast("Third")
    list.addLast("Fourth")
    
    println("List before removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size before removal: ${list.size}")
    
    // Remove the last element
    let removed1 = list.removeLast()
    if (let Some(value) <- removed1) {
        println("Removed last element: ${value}")
    }
    
    println("List after first removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size after first removal: ${list.size}")
    
    // Remove the last element again
    let removed2 = list.removeLast()
    if (let Some(value) <- removed2) {
        println("Removed last element again: ${value}")
    }
    
    println("Final list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Final list size: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
Cannot remove from empty list
List before removal:
First Second Third Fourth 
List size before removal: 4
Removed last element: Fourth
List after first removal:
First Second Third 
List size after first removal: 3
Removed last element again: Third
Final list:
First Second 
Final list size: 2
```

### func addFirst(T)

```cangjie
public func addFirst(element: T): LinkedListNode<T>
```

Function: Inserts an element at the head of the linked list and returns the node of that element.

Parameters:

- element: T - The element to be added to the list.

Returns:

- [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The node pointing to the element.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add first element to empty list
    let node1 = list.addFirst("Third")
    println("List size after adding first element: ${list.size}")
    println("Returned node value: ${node1.value}")
    
    // Add more elements at the head
    list.addFirst("Second")
    list.addFirst("First")
    
    println("List size after adding three elements: ${list.size}")
    
    // Verify element order (last added is first)
    print("All elements in list: ")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Verify first node
    let firstValue = list.first
    if (let Some(value) <- firstValue) {
        println("First element: ${value}")
    }
    
    // Verify last node
    let lastValue = list.last
    if (let Some(value) <- lastValue) {
        println("Last element: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
List size after adding first element: 1
Returned node value: Third
List size after adding three elements: 3
All elements in list: First Second Third 
First element: First
Last element: Third
```

### func remove(LinkedListNode\<T>)

```cangjie
public func remove(node: LinkedListNode<T>): T
```

Function: Removes the specified node from the linked list.

Parameters:

- node: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The node to be removed.

Returns:

- T - The value of the removed node.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified node does not belong to this list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("First")
    list.addLast("Second")
    list.addLast("Third")
    list.addLast("Fourth")
    
    println("List before removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size before removal: ${list.size}")
    
    // Get the second node (index 1, value "Second")
    let secondNode = list.nodeAt(1)
    if (let Some(node) <- secondNode) {
        println("Node to be removed: ${node.value}")
        
        // Remove the node
        let removedValue = list.remove(node)
        println("Removed node value: ${removedValue}")
    }
    
    println("List after removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size after removal: ${list.size}")
    
    // Remove the first node
    let firstNode = list.firstNode
    if (let Some(node) <- firstNode) {
        let removedValue = list.remove(node)
        println("Removed first node: ${removedValue}")
    }
    
    println("Final list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Final list size: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
List before removal:
First Second Third Fourth 
List size before removal: 4
Node to be removed: Second
Removed node value: Second
List after removal:
First Third Fourth 
List size after removal: 3
Removed first node: First
Final list:
Third Fourth 
Final list size: 2
```

### func removeIf((T)-> Bool)

```cangjie
public func removeIf(predicate: (T)-> Bool): Unit
```

Function: Removes all elements from this list that satisfy the given predicate function.

Parameters:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true for elements to be removed.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when nodes are added or removed within the `predicate` function while iterating through the [LinkedList](./collection_package_class.md#class-linkedlistt).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add some elements
    list.addLast(1)
    list.addLast(2)
    list.addLast(3)
    list.addLast(4)
    list.addLast(5)
    list.addLast(6)
    list.addLast(7)
    list.addLast(8)
    
    println("List before removal:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size before removal: ${list.size}")
    
    // Remove all even numbers
    list.removeIf({x: Int64 => x % 2 == 0})
    
    println("List after removing even numbers:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size after removal: ${list.size}")
    
    // Remove all elements greater than 3
    list.removeIf({x: Int64 => x > 3})
    
    println("List after removing elements > 3:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Final list size: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
List before removal:
1 2 3 4 5 6 7 8 
List size before removal: 8
List after removing even numbers:
1 3 5 7 
List size after removal: 4
List after removing elements > 3:
1 3 
Final list size: 2
```

### func reverse()

```cangjie
public func reverse(): Unit
```

Function: Reverses the order of elements in this linked list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("First")
    list.addLast("Second")
    list.addLast("Third")
    list.addLast("Fourth")
    list.addLast("Fifth")
    
    println("Original list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Verify original first and last elements
    let firstValue1 = list.first
    if (let Some(value) <- firstValue1) {
        println("Original first element: ${value}")
    }
    
    let lastValue1 = list.last
    if (let Some(value) <- lastValue1) {
        println("Original last element: ${value}")
    }
    
    // Reverse the list
    list.reverse()
    
    println("Reversed list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    
    // Verify reversed first and last elements
    let firstValue2 = list.first
    if (let Some(value) <- firstValue2) {
        println("First element after reversal: ${value}")
    }
    
    let lastValue2 = list.last
    if (let Some(value) <- lastValue2) {
        println("Last element after reversal: ${value}")
    }
    
    println("List size remains unchanged: ${list.size}")
    
    return 0
}
```

Execution Result:

```text
Original list:
First Second Third Fourth Fifth 
Original first element: First
Original last element: Fifth
Reversed list:
Fifth Fourth Third Second First 
First element after reversal: Fifth
Last element after reversal: First
List size remains unchanged: 5
```

### func skip(Int64)

```cangjie
public func skip(count: Int64): LinkedList<T>
```

Function: Skips a specified number of elements and returns a new linked list.

Throws an exception when count is less than or equal to 0. When count equals 0, it effectively skips no elements and returns a new list containing all elements of the source list. When count is greater than 0 but less than the size of the source list, it skips the first 'count' elements and returns a new list containing the remaining elements. When count is greater than or equal to the size of the source list, returns an empty list.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to skip.

Returns:

- [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> - Returns a new linked list with the specified number of elements skipped.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count < 0.

### func splitOff(LinkedListNode\<T>)

```cangjie
public func splitOff(node: LinkedListNode<T>): LinkedList<T>
```

Function: Splits the linked list starting from the specified node into two lists. If the split is successful, the node is no longer part of the current list but becomes the first node of the new list.

Parameters:

- node: [LinkedListNode](collection_package_class.md#class-linkedlistnodet)\<T> - The position at which to split.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<T> - The newly created list resulting from the split of the original list.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the specified node does not belong to this list.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<Int64>()
    
    // Add some elements
    list.addLast(1)
    list.addLast(2)
    list.addLast(3)
    list.addLast(4)
    list.addLast(5)
    list.addLast(6)
    
    println("Original list before split:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("Original list size: ${list.size}")
    
    // Get the third node (index 2, value 3) as the split point
    let thirdNode = list.nodeAt(2)
    if (let Some(node) <- thirdNode) {
        println("Splitting list at node ${node.value}")
        
        // Split the list
        let newList = list.splitOff(node)
        
        println("Original list after split:")
        for (element in list) {
            print("${element} ")
        }
        println()
        println("Original list size: ${list.size}")
        
        println("New list:")
        for (element in newList) {
            print("${element} ")
        }
        println()
        println("New list size: ${newList.size}")
        
        // Verify the first element of the new list
        let newFirstValue = newList.first
        if (let Some(value) <- newFirstValue) {
            println("First element of new list: ${value}")
        }
        
        // Verify the last element of the original list
        let originalLastValue = list.last
        if (let Some(value) <- originalLastValue) {
            println("Last element of original list: ${value}")
        }
    }
    
    return 0
}
```

Output:

```text
Original list before split:
1 2 3 4 5 6 
Original list size: 6
Splitting list at node 3
Original list after split:
1 2 
Original list size: 2
New list:
3 4 5 6 
New list size: 4
First element of new list: 3
Last element of original list: 2
```

### func step(Int64)
```cangjie
public func step(count: Int64): LinkedList<T>
```

Function: Extracts elements from the linked list at specified intervals and returns a new list.

Throws an exception when count is less than or equal to 0.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The extraction interval.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<T> - A new [LinkedList](collection_package_class.md#class-linkedlistt) containing elements extracted from the source [LinkedList](collection_package_class.md#class-linkedlistt) at the specified intervals.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count <= 0.

### func take(Int64)
```cangjie
public func take(count: Int64): LinkedList<T>
```

Function: Takes a specified number of elements from the linked list and returns a new list.

Throws an exception when count is less than or equal to 0. When count equals 0, takes no elements and returns an empty list. When count is greater than 0 but less than the size of the source list, takes the first 'count' elements and returns a new list. When count is greater than or equal to the size of the source list, takes all elements and returns a new list.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to take.

Returns:

- [LinkedList](collection_package_class.md#class-linkedlistt)\<T> - Returns a new list with the specified number of elements taken.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when count < 0.

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements of the linked list in the same order.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list = LinkedList<String>()
    
    // Add some elements
    list.addLast("Apple")
    list.addLast("Banana")
    list.addLast("Orange")
    list.addLast("Grape")
    list.addLast("Strawberry")
    
    println("Original list:")
    for (element in list) {
        print("${element} ")
    }
    println()
    println("List size: ${list.size}")
    
    // Convert list to array
    let array = list.toArray()
    println("Converted array size: ${array.size}")
    
    // Verify array content and order
    println("Array content:")
    for (i in 0..array.size) {
        print("[${i}]: ${array[i]} ")
    }
    println()
    
    // Verify first and last elements
    println("First element of array: ${array[0]}")
    println("Last element of array: ${array[array.size - 1]}")
    
    // Verify consistency with the list
    let listFirst = list.first
    if (let Some(value) <- listFirst) {
        println("First element of list: ${value}")
    }
    
    let listLast = list.last
    if (let Some(value) <- listLast) {
        println("Last element of list: ${value}")
    }
    
    return 0
}
```

Output:

```text
Original list:
Apple Banana Orange Grape Strawberry 
List size: 5
Converted array size: 5
Array content:
[0]: Apple [1]: Banana [2]: Orange [3]: Grape [4]: Strawberry 
First element of array: Apple
Last element of array: Strawberry
First element of list: Apple
Last element of list: Strawberry
```

### extend\<T> LinkedList\<T> <: Equatable\<LinkedList\<T>> where T <: Equatable\<T>

```cangjie
extend<T> LinkedList<T> <: Equatable<LinkedList<T>> where T <: Equatable<T>
```

Function: Extends the [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> type with the [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[LinkedList](./collection_package_class.md#class-linkedlistt)\<T>> interface, supporting equality comparison.

Parent Type:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[LinkedList](#class-linkedlistt)\<T>>

#### operator func ==(LinkedList\<T>)

```cangjie
public operator func ==(right: LinkedList<T>): Bool
```

Function: Determines whether the current instance is equal to the [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> instance specified by the parameter.

Two [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> instances are considered equal if they contain exactly the same elements.

Parameters:

- right: [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list1 = LinkedList<Int64>()
    let list2 = LinkedList<Int64>()
    let list3 = LinkedList<Int64>()
    
    // Test equality of empty lists
    println("Two empty lists are equal: ${list1 == list2}")
    
    // Add identical elements to list1 and list2
    list1.addLast(1)
    list1.addLast(2)
    list1.addLast(3)
    
    list2.addLast(1)
    list2.addLast(2)
    list2.addLast(3)
    
    println("Lists with identical elements are equal: ${list1 == list2}")
    
    // Add different elements to list3
    list3.addLast(1)
    list3.addLast(2)
    list3.addLast(4) // Different element
    
    println("Lists with different elements are not equal: ${list1 == list3}")
    
    // Test lists of different sizes
    let list4 = LinkedList<Int64>()
    list4.addLast(1)
    list4.addLast(2)
    
    println("Lists of different sizes are not equal: ${list1 == list4}")
    
    // Test lists with same elements but different order
    let list5 = LinkedList<Int64>()
    list5.addLast(3)
    list5.addLast(2)
    list5.addLast(1)
    
    println("Lists with same elements but different order are not equal: ${list1 == list5}")
    
    // Display list contents for verification
    print("list1: ")
    for (element in list1) {
        print("${element} ")
    }
    println()
    
    print("list5: ")
    for (element in list5) {
        print("${element} ")
    }
    println()
    
    return 0
}
```

Output:

```text
Two empty lists are equal: true
Lists with identical elements are equal: true
Lists with different elements are not equal: false
Lists of different sizes are not equal: false
Lists with same elements but different order are not equal: false
list1: 1 2 3 
list5: 3 2 1 
```

#### operator func !=(LinkedList\<T>)

```cangjie
public operator func !=(right: LinkedList<T>): Bool
```

Function: Determines whether the current instance is not equal to the [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> instance specified by the parameter.

Parameters:

- right: [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let list1 = LinkedList<String>()
    let list2 = LinkedList<String>()
    
    // Test inequality of empty lists
    println("Two empty lists are not equal: ${list1 != list2}")
    
    // Add elements to list1
    list1.addLast("First")
    list1.addLast("Second")
    
    // Test lists of different sizes
    println("Lists of different sizes are not equal: ${list1 != list2}")
    
    // Add identical elements to list2
    list2.addLast("First")
    list2.addLast("Second")
    
    println("Lists with identical elements are not equal: ${list1 != list2}")
    
    // Create a list with different elements
    let list3 = LinkedList<String>()
    list3.addLast("First")
    list3.addLast("Third") // Different element
    
    println("Lists with different elements are not equal: ${list1 != list3}")
    
    // Create a list with same elements but different order
    let list4 = LinkedList<String>()
    list4.addLast("Second")
    list4.addLast("First")
    
    println("Lists with same elements but different order are not equal: ${list1 != list4}")
    
    // Display all list contents for verification
    print("list1: ")
    for (element in list1) {
        print("${element} ")
    }
    println()
    
    print("list2: ")
    for (element in list2) {
        print("${element} ")
    }
    println()
    
    print("list3: ")
    for (element in list3) {
        print("${element} ")
    }
    println()
    
    print("list4: ")
    for (element in list4) {
        print("${element} ")
    }
    println()
    
    return 0
}
```

Output:

```text
Two empty lists are not equal: false
Lists of different sizes are not equal: true
Lists with identical elements are not equal: false
Lists with different elements are not equal: true
Lists with same elements but different order are not equal: true
list1: First Second 
list2: First Second 
list3: First Third 
list4: Second First 
```

### extend\<T> LinkedList\<T>

```cangjie
extend<T> LinkedList<T>
```

Function: Extends the [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> type.

#### func enumerate()

```cangjie
public func enumerate(): LinkedList<(Int64, T)>
```

Function: Returns an indexed linked list.

Returns:

- [LinkedList](./collection_package_class.md#class-linkedlistt)\<([Int64](../../core/core_package_api/core_package_intrinsics.md#int64), T)> - Returns a new indexed [LinkedList](./collection_package_class.md#class-linkedlistt).

#### func zip\<R>(LinkedList\<R>)

```cangjie
public func zip<R>(other: LinkedList<R>): LinkedList<(T, R)>
```

Function: Combines two [LinkedList](./collection_package_class.md#class-linkedlistt) instances into a new [LinkedList](./collection_package_class.md#class-linkedlistt) (length determined by the shorter list).


> **Note：**
>
> Unsupported platform：OpenHarmony

Parameters:

- other: [LinkedList](./collection_package_class.md#class-linkedlistt)\<R> - One of the lists to combine.

Returns:

- [LinkedList](./collection_package_class.md#class-linkedlistt)\<(T, R)> - Returns a new list.

### extend\<T> LinkedList\<T> <: ToString where T <: ToString

```cangjie
extend<T> LinkedList<T> <: ToString where T <: ToString
```

Function: Extends [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface, supporting string conversion.

Parent Type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current [LinkedList](./collection_package_class.md#class-linkedlistt)\<T> instance to a string.

The string contains the string representation of each element in the [LinkedList](./collection_package_class.md#class-linkedlistt)\<T>, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The resulting string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Test empty list
    let emptyList = LinkedList<Int64>()
    println("toString of empty list: ${emptyList.toString()}")
    
    // Test single-element list
    let singleList = LinkedList<String>()
    singleList.addLast("SingleElement")
    println("toString of single-element list: ${singleList.toString()}")
    
    // Test multiple-element list
    let numberList = LinkedList<Int64>()
    numberList.addLast(10)
    numberList.addLast(20)
    numberList.addLast(30)
    numberList.addLast(40)
    println("toString of number list: ${numberList.toString()}")
    
    // Test string list
    let stringList = LinkedList<String>()
    stringList.addLast("Apple")
    stringList.addLast("Banana")
    stringList.addLast("Orange")
    println("toString of string list: ${stringList.toString()}")
    
    // Verify toString matches manually constructed string
    print("Manual traversal of number list: [")
    var isFirst = true
    for (element in numberList) {
        if (!isFirst) {
            print(", ")
        }
        print("${element}")
        isFirst = false
    }
    println("]")
    
    // Test modified toString
    numberList.addFirst(5)
    numberList.addLast(50)
    println("Modified number list toString: ${numberList.toString()}")
    
    return 0
}
```

Output:

```text
toString of empty list: []
toString of single-element list: [SingleElement]
toString of number list: [10, 20, 30, 40]
toString of string list: [Apple, Banana, Orange]
Manual traversal of number list: [10, 20, 30, 40]
Modified number list toString: [5, 10, 20, 30, 40, 50]
```

## class TreeMap\<K, V> where K <: Comparable\<K>

```cangjie
public class TreeMap<K, V> <: OrderedMap<K, V> where K <: Comparable<K> {
    public init()
    public init(elements: Collection<(K, V)>)
    public init(elements: Array<(K,V)>)
    public init(size: Int64, initElement: (Int64) -> (K, V))
}
```

Function: An implementation of the [OrderedMap](collection_package_interface.md#interface-orderedmapk-v) interface based on a balanced multi-way search tree.

The primary purpose of this class is to provide an ordered key-value storage structure that supports fast insertion, deletion, and lookup operations.

[TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) can be used in any scenario requiring ordered key-value pair storage, such as databases, caches, lookup tables, etc.

Parent Types:

- [OrderedMap](collection_package_interface.md#interface-orderedmapk-v)\<K, V>

### prop first

```cangjie
public prop first: ?(K, V)
```

Function: Retrieves the first key-value pair in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Type: ?(K, V)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Case with empty TreeMap
    let firstValue1 = map.first
    if (let Some((key, value)) <- firstValue1) {
        println("First element: (${key}, ${value})")
    } else {
        println("TreeMap is empty")
    }
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    // Get first element (sorted by key's lexicographical order)
    let firstValue2 = map.first
    if (let Some((key, value)) <- firstValue2) {
        println("First element: (${key}, ${value})")
    } else {
        println("TreeMap is empty")
    }
    
    return 0
}
```

Execution Result:

```text
TreeMap is empty
First element: (apple, 10)
```

### prop last

```cangjie
public prop last: ?(K, V)
```

Function: Retrieves the last key-value pair in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Type: ?(K, V)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Case with empty TreeMap
    let lastValue1 = map.last
    if (let Some((key, value)) <- lastValue1) {
        println("Last element: (${key}, ${value})")
    } else {
        println("TreeMap is empty")
    }
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    // Get last element (sorted by key's lexicographical order)
    let lastValue2 = map.last
    if (let Some((key, value)) <- lastValue2) {
        println("Last element: (${key, ${value})")
    } else {
        println("TreeMap is empty")
    }
    
    return 0
}
```

Execution Result:

```text
TreeMap is empty
Last element: (cherry, 30)
```

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of key-value pairs.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Size of empty TreeMap
    println("Empty TreeMap size: ${map.size}")
    
    // Add some elements
    map.add("apple", 10)
    println("Size after adding 1 element: ${map.size}")
    
    map.add("banana", 20)
    map.add("cherry", 30)
    println("Size after adding 3 elements: ${map.size}")
    
    // Overwriting existing key doesn't increase size
    map.add("apple", 15)
    println("Size after overwriting: ${map.size}")
    
    return 0
}
```

Execution Result:

```text
Empty TreeMap size: 0
Size after adding 1 element: 1
Size after adding 3 elements: 3
Size after overwriting: 3
```

### init()

```cangjie
public init()
```

Function: Constructs an empty [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty TreeMap
    let map = TreeMap<String, Int64>()
    
    println("Initial size: ${map.size}")
    println("Is empty: ${map.isEmpty()}")
    
    // Add some elements
    map.add("key1", 100)
    map.add("key2", 200)
    
    println("Size after adding elements: ${map.size}")
    println("Is empty after adding: ${map.isEmpty()}")
    
    return 0
}
```

Execution Result:

```text
Initial size: 0
Is empty: true
Size after adding elements: 2
Is empty after adding: false
```

### init(Array\<(K,V)>)

```cangjie
public init(elements: Array<(K,V)>)
```

Function: Constructs a [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) from an array of key-value pairs.

Elements are inserted into the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) in the order they appear in the elements array. Since duplicate keys are not allowed in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), if duplicate keys exist in elements, later key-value pairs will overwrite earlier ones.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<(K, V)> - The array of key-value pairs used to initialize this [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Initialize TreeMap with array
    let array: Array<(String, Int64)> = [("banana", 20), ("apple", 10), ("cherry", 30)]
    let map = TreeMap<String, Int64>(array)
    
    println("Size after initialization: ${map.size}")
    
    // Iterate elements (TreeMap orders elements by key's lexicographical order)
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    // Test overwrite behavior
    let arrayWithDup: Array<(String, Int64)> = [("apple", 5), ("apple", 15), ("banana", 25)]
    let mapWithDup = TreeMap<String, Int64>(arrayWithDup)
    
    println("\nInitialization with duplicate keys:")
    for ((key, value) in mapWithDup) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
Size after initialization: 3
apple: 10
banana: 20
cherry: 30

Initialization with duplicate keys:
apple: 15
banana: 25
```

### init(Collection\<(K, V)>)

```cangjie
public init(elements: Collection<(K, V)>)
```

Function: Constructs a [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) from a collection of key-value pairs.

Elements are inserted into the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) in the iterator order of elements. Since duplicate keys are not allowed in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), if duplicate keys exist in elements, later key-value pairs (in iterator order) will overwrite earlier ones.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> - The collection of key-value pairs used to initialize this [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Initialize TreeMap with ArrayList
    let list = ArrayList<(String, Int64)>()
    list.add(("dog", 40))
    list.add(("cat", 30))
    list.add(("bird", 50))
    
    let map = TreeMap<String, Int64>(list)
    println("TreeMap size initialized with ArrayList: ${map.size}")
    
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    // Initialize with another TreeMap
    let originalMap = TreeMap<String, Int64>()
    originalMap.add("x", 100)
    originalMap.add("y", 200)
    originalMap.add("z", 300)
    
    let newMap = TreeMap<String, Int64>(originalMap)
    println("\nNew TreeMap size initialized with TreeMap: ${newMap.size}")
    
    for ((key, value) in newMap) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
TreeMap size initialized with ArrayList: 3
bird: 50
cat: 30
dog: 40

New TreeMap size initialized with TreeMap: 3
x: 100
y: 200
z: 300
```

### init(Int64, (Int64) -> (K, V))

```cangjie
public init(size: Int64, initElement: (Int64) -> (K, V))
```

Function: Constructs a [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) using a size parameter and initialization function.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of elements to initialize.
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) -> (K, V) - The initialization function that generates key-value pairs.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if size is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Initialize TreeMap with function rule. The function takes an index parameter and returns key-value pairs
    let map = TreeMap<String, Int64>(3, {i: Int64 => ("key${i}", i * 10)})
    
    println("Size after initialization: ${map.size}")
    
    // Iterate all elements
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    // Use more complex function rule
    let map2 = TreeMap<String, Int64>(4, {i: Int64 => 
        let alphabet = ["A", "B", "C", "D"]
        (alphabet[i], (i + 1) * (i + 1))
    })
    
    println("\nSecond map:")
    for ((key, value) in map2) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
Size after initialization: 3
key0: 0
key1: 10
key2: 20

Second map:
A: 1
B: 4
C: 9
D: 16
```

### func add(K, V)

```cangjie
public func add(key: K, value: V): Option<V>
```

Function: Inserts a new key-value pair into the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek). For existing keys in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), the key's value will be replaced with the new value.

Parameters:

- key: K - The key to insert.
- value: V - The value to assign.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - If the key existed before assignment, the old value is wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont) and returned; otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Add new key-value pairs
    let result1 = map.add("apple", 10)
    if (let Some(oldValue) <- result1) {
        println("Overwrote old value: ${oldValue}")
    } else {
        println("Added new key: apple")
    }
    
    let result2 = map.add("banana", 20)
    if (let Some(oldValue) <- result2) {
        println("Overwrote old value: ${oldValue}")
    } else {
        println("Added new key: banana")
    }
    
    // Overwrite existing key
    let result3 = map.add("apple", 15)
    if (let Some(oldValue) <- result3) {
        println("Overwrote old value: ${oldValue}")
    } else {
        println("Added new key: apple")
    }
    
    println("\nFinal TreeMap:")
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
Added new key: apple
Added new key: banana
Overwrote old value: 10

Final TreeMap:
apple: 15
banana: 20
```

### func add(Collection\<(K, V)>)

```cangjie
public func add(all!: Collection<(K, V)>): Unit
```

Function: Inserts a new collection of key-value pairs into [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek). For keys already existing in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), their values will be overwritten by the new values.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<(K, V)> - The collection of key-value pairs to be added to [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Initial addition of one element
    map.add("a", 1)
    println("Initial state: size=${map.size}")
    
    // Adding multiple key-value pairs using ArrayList
    let list = ArrayList<(String, Int64)>()
    list.add(("b", 2))
    list.add(("c", 3))
    list.add(("d", 4))
    
    map.add(all: list)
    println("After adding ArrayList: size=${map.size}")
    
    // Adding elements from another TreeMap
    let anotherMap = TreeMap<String, Int64>()
    anotherMap.add("a", 10)  // Overwriting existing key
    anotherMap.add("e", 5)   // New key
    
    map.add(all: anotherMap)
    println("After adding TreeMap: size=${map.size}")
    
    println("\nFinal TreeMap:")
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Output:

```text
Initial state: size=1
After adding ArrayList: size=4
After adding TreeMap: size=5

Final TreeMap:
a: 10
b: 2
c: 3
d: 4
e: 5
```

### func all((K, V) -> Bool)

```cangjie
public func all(predicate: (K, V) -> Bool): Bool
```

Function: Determines whether all key-value pairs in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to be evaluated.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all key-value pairs satisfy the condition, otherwise returns false.

### func any((K, V) -> Bool)

```cangjie
public func any(predicate: (K, V) -> Bool): Bool
```

Function: Determines whether any key-value pair in [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition to be evaluated.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if any key-value pair satisfies the condition.

### func backward(K, Bool)

```cangjie
public func backward(mark: K, inclusive!: Bool = true): Iterator<(K, V)>
```

Function: Obtains an iterator that traverses from the first node with a key less than or equal to `mark` in descending order to [first](./collection_package_class.md#prop-first-3). If the node's key equals `mark`, the `inclusive!` parameter determines whether to include that node.

Parameters:

- mark: K - The key used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the key of the first element in the iterator, specifies whether to include `mark` as the starting point (default: `true`).

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)> - An iterator for the corresponding elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    map.add("elderberry", 50)
    map.add("fig", 60)
    map.add("grape", 70)
    
    println("TreeMap contents: ${map}")
    
    // Descending traversal starting from "elderberry" (inclusive)
    println("\nDescending traversal from 'elderberry' (inclusive):")
    let backwardIter1 = map.backward("elderberry", inclusive: true)
    for ((key, value) in backwardIter1) {
        println("${key}: ${value}")
    }
    
    // Descending traversal starting from "elderberry" (exclusive)
    println("\nDescending traversal from 'elderberry' (exclusive):")
    let backwardIter2 = map.backward("elderberry", inclusive: false)
    for ((key, value) in backwardIter2) {
        println("${key}: ${value}")
    }
    
    // Descending traversal starting from "fig" (default inclusive)
    println("\nDescending traversal from 'fig' (default inclusive):")
    let backwardIter3 = map.backward("fig")
    for ((key, value) in backwardIter3) {
        println("${key}: ${value}")
    }
    
    // Descending traversal starting from non-existent key "coconut"
    println("\nDescending traversal from non-existent key 'coconut':")
    let backwardIter4 = map.backward("coconut")
    for ((key, value) in backwardIter4) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Output:

```text
TreeMap contents: [(apple, 10), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50), (fig, 60), (grape, 70)]

Descending traversal from 'elderberry' (inclusive):
elderberry: 50
date: 40
cherry: 30
banana: 20
apple: 10

Descending traversal from 'elderberry' (exclusive):
date: 40
cherry: 30
banana: 20
apple: 10

Descending traversal from 'fig' (default inclusive):
fig: 60
elderberry: 50
date: 40
cherry: 30
banana: 20
apple: 10

Descending traversal from non-existent key 'coconut':
cherry: 30
banana: 20
apple: 10
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Clears all key-value pairs.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    println("Size before clearing: ${map.size}")
    println("Is empty before clearing: ${map.isEmpty()}")
    
    // Clear all elements
    map.clear()
    
    println("Size after clearing: ${map.size}")
    println("Is empty after clearing: ${map.isEmpty()}")
    
    // Verify elements can be added again
    map.add("new_key", 100)
    println("Size after re-adding elements: ${map.size}")
    
    return 0
}
```

Output:

```text
Size before clearing: 3
Is empty before clearing: false
Size after clearing: 0
Is empty after clearing: true
Size after re-adding elements: 1
```

### func clone()

```cangjie
public func clone(): TreeMap<K, V>
```

Function: Creates a clone of [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Returns:

- [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> - Returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create original TreeMap
    let originalMap = TreeMap<String, Int64>()
    originalMap.add("apple", 10)
    originalMap.add("banana", 20)
    originalMap.add("cherry", 30)
    
    println("Original map size: ${originalMap.size}")
    
    // Clone TreeMap
    let clonedMap = originalMap.clone()
    
    println("Cloned map size: ${clonedMap.size}")
    
    // Verify data independence after cloning
    clonedMap.add("date", 40)
    originalMap.add("elderberry", 50)
    
    println("\nModified original map:")
    for ((key, value) in originalMap) {
        println("${key}: ${value}")
    }
    
    println("\nModified cloned map:")
    for ((key, value) in clonedMap) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Output:

```text
Original map size: 3
Cloned map size: 3

Modified original map:
apple: 10
banana: 20
cherry: 30
elderberry: 50

Modified cloned map:
apple: 10
banana: 20
cherry: 30
date: 40
```

### func contains(K)

```cangjie
public func contains(key: K): Bool
```

Function: Determines whether the map contains a mapping for the specified key.

Parameters:

- key: K - The key to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the key exists, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    // Check existing keys
    println("contains 'apple': ${map.contains("apple")}")
    println("contains 'banana': ${map.contains("banana")}")
    
    // Check non-existent keys
    println("contains 'grape': ${map.contains("grape")}")
    println("contains 'orange': ${map.contains("orange")}")
    
    return 0
}
```

Output:

```text
contains 'apple': true
contains 'banana': true
contains 'grape': false
contains 'orange': false
```

### func contains(Collection\<K>)

```cangjie
public func contains(all!: Collection<K>): Bool
```

Function: Determines whether the map contains mappings for all keys in the specified collection.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all keys exist, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    map.add("elderberry", 50)
    
    println("TreeMap contents: ${map}")
    
    // Create first key collection to check using ArrayList
    let keysToCheck1 = ArrayList<String>()
    keysToCheck1.add("apple")
    keysToCheck1.add("banana")
    keysToCheck1.add("cherry")
    
    println("\nCheck collection 1: [apple, banana, cherry]")
    let contains1 = map.contains(all: keysToCheck1)
    println("Contains all keys: ${contains1}")
    
    // Check collection with some non-existent keys
    let keysToCheck2 = ArrayList<String>()
    keysToCheck2.add("apple")
    keysToCheck2.add("grape")  // Non-existent key
    keysToCheck2.add("cherry")
    
    println("\nCheck collection 2: [apple, grape, cherry]")
    let contains2 = map.contains(all: keysToCheck2)
    println("Contains all keys: ${contains2}")
    
    // Check collection with all non-existent keys
    let keysToCheck3 = ArrayList<String>()
    keysToCheck3.add("grape")
    keysToCheck3.add("orange")
    keysToCheck3.add("peach")
    
    println("\nCheck collection 3: [grape, orange, peach]")
    let contains3 = map.contains(all: keysToCheck3)
    println("Contains all keys: ${contains3}")
    
    // Check empty collection
    let emptyKeys = ArrayList<String>()
    println("\nCheck empty collection: []")
    let contains4 = map.contains(all: emptyKeys)
    println("Contains all keys: ${contains4}")
    
    return 0
}
```

Output:

```text
TreeMap contents: [(apple, 10), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50)]

Check collection 1: [apple, banana, cherry]
Contains all keys: true

Check collection 2: [apple, grape, cherry]
Contains all keys: false

Check collection 3: [grape, orange, peach]
Contains all keys: false

Check empty collection: []
Contains all keys: true
```

### func entryView(K)

```cangjie
public func entryView(k: K): MapEntryView<K, V>
```

Function: Returns an empty reference view if the specified key is not present. If the key exists, returns a reference view of the corresponding element.

Parameters:

- k: K - The key of the key-value pair to be added.

Returns:

- [MapEntryView](./collection_package_interface.md#interface-mapentryviewk-v)\<K, V> - A reference view.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    println("TreeMap contents: ${map}")
    
    // Get reference view for existing key
    let entryView1 = map.entryView("apple")
    println("Obtained reference view for apple")
    
    // Get reference view for non-existent key
    let entryView2 = map.entryView("grape")
    println("Obtained reference view for grape")
    
    // Note: MapEntryView is a reference view interface
    // It provides view access to specific key-value pairs
    // If the key exists, the view contains that key-value pair; otherwise, it's an empty view
    
    println("\nentryView provides reference view access to specific key-value pairs in TreeMap")
    
    return 0
}
```

Execution Result:

```text
TreeMap contents: [(apple, 10), (banana, 20), (cherry, 30)]
Obtained reference view for apple
Obtained reference view for grape

entryView provides reference view access to specific key-value pairs in TreeMap
```

### func filter((K, V) -> Bool)
```cangjie
public func filter(predicate: (K, V) -> Bool): TreeMap<K, V>
```

Function: Returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> containing key-value pairs that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> - Returns a new collection containing key-value pairs that satisfy the filter condition.

### func fold\<R>(R, (R, K, V) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, K, V) -> R): R
```

Function: Computes from left to right using the specified initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The given initial value of type R.
- operation: (R, K, V) -> R - The given computation function.

Returns:

- R - Returns the final computed value.

### func forEach((K, V) -> Unit)

```cangjie
public func forEach(action: (K, V) -> Unit): Unit
```

Function: Iterates over all key-value pairs and executes the given action.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (K, V) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The given action function.

### func forward(K, Bool)

```cangjie
public func forward(mark: K, inclusive!: Bool = true): Iterator<(K, V)>
```

Function: Obtains an iterator that traverses from the first node with a key greater than or equal to `mark` in ascending order until [last](./collection_package_class.md#prop-last-3). If the node's key equals `mark`, the `inclusive!` parameter determines whether to include that node.

Parameters:

- mark: K - The key used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the key of the first element in the iterator, specifies whether to include `mark` as the starting point, defaults to `true`.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)> - The iterator for corresponding elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    map.add("elderberry", 50)
    map.add("fig", 60)
    map.add("grape", 70)
    
    println("TreeMap contents: ${map}")
    
    // Traverse from "cherry" in ascending order (including cherry)
    println("\nTraverse from 'cherry' in ascending order (including cherry):")
    let forwardIter1 = map.forward("cherry", inclusive: true)
    for ((key, value) in forwardIter1) {
        println("${key}: ${value}")
    }
    
    // Traverse from "cherry" in ascending order (excluding cherry)
    println("\nTraverse from 'cherry' in ascending order (excluding cherry):")
    let forwardIter2 = map.forward("cherry", inclusive: false)
    for ((key, value) in forwardIter2) {
        println("${key}: ${value}")
    }
    
    // Traverse from "banana" in ascending order (default inclusive)
    println("\nTraverse from 'banana' in ascending order (default inclusive):")
    let forwardIter3 = map.forward("banana")
    for ((key, value) in forwardIter3) {
        println("${key}: ${value}")
    }
    
    // Traverse from non-existent key "coconut" in ascending order
    println("\nTraverse from non-existent key 'coconut' in ascending order:")
    let forwardIter4 = map.forward("coconut")
    for ((key, value) in forwardIter4) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
TreeMap contents: [(apple, 10), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50), (fig, 60), (grape, 70)]

Traverse from 'cherry' in ascending order (including cherry):
cherry: 30
date: 40
elderberry: 50
fig: 60
grape: 70

Traverse from 'cherry' in ascending order (excluding cherry):
date: 40
elderberry: 50
fig: 60
grape: 70

Traverse from 'banana' in ascending order (default inclusive):
banana: 20
cherry: 30
date: 40
elderberry: 50
fig: 60
grape: 70

Traverse from non-existent key 'coconut' in ascending order:
date: 40
elderberry: 50
fig: 60
grape: 70
```

### func get(K)

```cangjie
public func get(key: K): ?V
```

Function: Returns the value mapped to the specified key.

Parameters:

- key: K - The specified key.

Returns:

- ?V - If such a value exists, returns the value encapsulated in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    
    // Get value for existing key
    let value1 = map.get("apple")
    if (let Some(val) <- value1) {
        println("Value for apple: ${val}")
    } else {
        println("Apple not found")
    }
    
    let value2 = map.get("banana")
    if (let Some(val) <- value2) {
        println("Value for banana: ${val}")
    } else {
        println("Banana not found")
    }
    
    // Get value for non-existent key
    let value3 = map.get("grape")
    if (let Some(val) <- value3) {
        println("Value for grape: ${val}")
    } else {
        println("Grape not found")
    }
    
    return 0
}
```

Execution Result:

```text
Value for apple: 10
Value for banana: 20
Grape not found
```

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if empty, otherwise returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Initial empty state
    println("Is empty initially: ${map.isEmpty()}")
    println("Initial size: ${map.size}")
    
    // After adding elements
    map.add("apple", 10)
    map.add("banana", 20)
    
    println("Is empty after adding elements: ${map.isEmpty()}")
    println("Size after adding elements: ${map.size}")
    
    // After clearing
    map.clear()
    
    println("Is empty after clearing: ${map.isEmpty()}")
    println("Size after clearing: ${map.size}")
    
    return 0
}
```

Execution Result:

```text
Is empty initially: true
Initial size: 0
Is empty after adding elements: false
Size after adding elements: 2
Is empty after clearing: true
Size after clearing: 0
```

### func iterator()

```cangjie
public func iterator(): Iterator<(K, V)>
```

Function: Returns an iterator for the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), which iterates in ascending order of Key values.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<(K, V)> - The iterator for the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("date", 40)
    
    // Manual traversal using iterator
    let iter = map.iterator()
    
    println("Manual traversal using iterator:")
    for (entry in iter) {
        let (key, value) = entry
        println("${key}: ${value}")
    }
    
    // Automatic traversal using for-in loop (internally uses iterator)
    println("\nTraversal using for-in loop:")
    for ((key, value) in map) {
        println("${key}: ${value}")
    }
    
    return 0
}
```

Execution Result:

```text
Manual traversal using iterator:
apple: 10
banana: 20
cherry: 30
date: 40

Traversal using for-in loop:
apple: 10
banana: 20
cherry: 30
date: 40
```

### func keys()

```cangjie
public func keys(): EquatableCollection<K>
```

Function: Returns all keys in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), stored in a container.

Returns:

- [EquatableCollection](collection_package_interface.md#interface-equatablecollectiont)\<K> - A collection containing all keys.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("date", 40)
    
    // Get all keys
    let keyCollection = map.keys()
    
    println("All keys:")
    for (key in keyCollection) {
        println("Key: ${key}")
    }
    
    // Verify key count
    println("\nKey count: ${keyCollection.size}")
    println("TreeMap size: ${map.size}")
    
    return 0
}
```

Execution Result:

```text
All keys:
Key: apple
Key: banana
Key: cherry
Key: date

Key count: 4
TreeMap size: 4
```

### func mapValues\<R>((K, V) -> R)

```cangjie
public func mapValues<R>(transform: (K, V) -> R): TreeMap<K, R>
```

Function: Maps this [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) and returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (K, V) -> R - The given mapping function.

Returns:

- [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, R> - Returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

### func mapValues\<R>((V) -> R)

```cangjie
public func mapValues<R>(transform: (V) -> R): TreeMap<K, R>
```

Function: Maps this [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, R> and returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, R>.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (V) -> R - The given mapping function.

Returns:

- [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, R> - Returns a new [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, R>.

### func none((K, V) -> Bool)

```cangjie
public func none(predicate: (K, V) -> Bool): Bool
```

Function: Determines whether none of the key-value pairs in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the key-value pairs in the current [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek) satisfy the condition.

### func reduce((V, V) -> V)

```cangjie
public func reduce(operation: (V, V) -> V): Option<V>
```

Function: Computes from left to right using the first value as the initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (V, V) -> V - The given computation function.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - Returns the computation result.

### func removeFirst()

```cangjie
public func removeFirst(): ?(K, V)
```

Function: Removes the first element of the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Returns:

- ?(K, V) - If the first element exists, it is removed and returned wrapped in an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<(K, V)>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Remove first element from an empty TreeMap
    let result1 = map.removeFirst()
    if (let Some((key, value)) <- result1) {
        println("Removed first element: (${key}, ${value})")
    } else {
        println("TreeMap is empty, cannot remove")
    }
    
    // Add some elements
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("date", 40)
    
    println("\nTreeMap before removal: ${map}")
    println("Size before removal: ${map.size}")
    
    // Remove the first element (first in lexicographical order)
    let result2 = map.removeFirst()
    if (let Some((key, value)) <- result2) {
        println("Removed first element: (${key}, ${value})")
    }
    
    println("TreeMap after removal: ${map}")
    println("Size after removal: ${map.size}")
    
    // Remove the first element again
    let result3 = map.removeFirst()
    if (let Some((key, value)) <- result3) {
        println("Removed first element again: (${key}, ${value})")
    }
    
    println("Final TreeMap: ${map}")
    
    return 0
}
```

Output:

```text
TreeMap is empty, cannot remove

TreeMap before removal: [(apple, 10), (banana, 20), (cherry, 30), (date, 40)]
Size before removal: 4
Removed first element: (apple, 10)
TreeMap after removal: [(banana, 20), (cherry, 30), (date, 40)]
Size after removal: 3
Removed first element again: (banana, 20)
Final TreeMap: [(cherry, 30), (date, 40)]
```

### func removeLast()

```cangjie
public func removeLast(): ?(K, V)
```

Function: Removes the last element of the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Returns:

- ?(K, V) - If the last element exists, it is removed and returned wrapped in an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise, returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<(K, V)>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Remove last element from an empty TreeMap
    let result1 = map.removeLast()
    if (let Some((key, value)) <- result1) {
        println("Removed last element: (${key, ${value})")
    } else {
        println("TreeMap is empty, cannot remove")
    }
    
    // Add some elements
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("date", 40)
    
    println("\nTreeMap before removal: ${map}")
    println("Size before removal: ${map.size}")
    
    // Remove the last element (last in lexicographical order)
    let result2 = map.removeLast()
    if (let Some((key, value)) <- result2) {
        println("Removed last element: (${key}, ${value})")
    }
    
    println("TreeMap after removal: ${map}")
    println("Size after removal: ${map.size}")
    
    // Remove the last element again
    let result3 = map.removeLast()
    if (let Some((key, value)) <- result3) {
        println("Removed last element again: (${key}, ${value})")
    }
    
    println("Final TreeMap: ${map}")
    
    return 0
}
```

Output:

```text
TreeMap is empty, cannot remove

TreeMap before removal: [(apple, 10), (banana, 20), (cherry, 30), (date, 40)]
Size before removal: 4
Removed last element: (date, 40)
TreeMap after removal: [(apple, 10), (banana, 20), (cherry, 30)]
Size after removal: 3
Removed last element again: (cherry, 30)
Final TreeMap: [(apple, 10), (banana, 20)]
```

### func remove(K)

```cangjie
public func remove(key: K): Option<V>
```

Function: Removes the mapping for the specified key from this map if present.

Parameters:

- key: K - The key to be removed.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<V> - The value of the removed mapping wrapped in an [Option](../../core/core_package_api/core_package_enums.md#enum-optiont). Returns None if the key is not found in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Remove from an empty TreeMap
    let result1 = map.remove("nonexistent")
    if (let Some(value) <- result1) {
        println("Removed element with value: ${value}")
    } else {
        println("Key not found: nonexistent")
    }
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    
    println("\nTreeMap before removal: ${map}")
    println("Size before removal: ${map.size}")
    
    // Remove an existing key
    let result2 = map.remove("banana")
    if (let Some(value) <- result2) {
        println("Removed key 'banana' with value: ${value}")
    } else {
        println("Key not found: banana")
    }
    
    println("TreeMap after removal: ${map}")
    println("Size after removal: ${map.size}")
    
    // Attempt to remove a non-existent key
    let result3 = map.remove("grape")
    if (let Some(value) <- result3) {
        println("Removed key 'grape' with value: ${value}")
    } else {
        println("Key not found: grape")
    }
    
    // Remove another existing key
    let result4 = map.remove("apple")
    if (let Some(value) <- result4) {
        println("Removed key 'apple' with value: ${value}")
    }
    
    println("Final TreeMap: ${map}")
    println("Final size: ${map.size}")
    
    return 0
}
```

Output:

```text
Key not found: nonexistent

TreeMap before removal: [(apple, 10), (banana, 20), (cherry, 30), (date, 40)]
Size before removal: 4
Removed key 'banana' with value: 20
TreeMap after removal: [(apple, 10), (cherry, 30), (date, 40)]
Size after removal: 3
Key not found: grape
Removed key 'apple' with value: 10
Final TreeMap: [(cherry, 30), (date, 40)]
Final size: 2
```

### func remove(Collection\<K>)

```cangjie
public func remove(all!: Collection<K>): Unit
```

Function: Removes mappings for all keys in the specified collection from this map if they exist.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<K> - The collection of keys to be removed.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    map.add("elderberry", 50)
    
    println("TreeMap before removal: ${map}")
    println("Size before removal: ${map.size}")
    
    // Create a collection of keys to remove using ArrayList
    let keysToRemove = ArrayList<String>()
    keysToRemove.add("banana")
    keysToRemove.add("date")
    keysToRemove.add("nonexistent")  // Non-existent key
    
    println("\nKeys to remove:")
    for (key in keysToRemove) {
        println("  ${key}")
    }
    
    // Remove the keys from the collection
    map.remove(all: keysToRemove)
    
    println("\nTreeMap after removal: ${map}")
    println("Size after removal: ${map.size}")
    
    // Use keys from another TreeMap for removal
    let anotherMap = TreeMap<String, Int64>()
    anotherMap.add("apple", 100)
    anotherMap.add("cherry", 300)
    anotherMap.add("grape", 600)  // This key doesn't exist in the original map
    
    let keysFromAnotherMap = anotherMap.keys()
    println("\nKeys from another TreeMap:")
    for (key in keysFromAnotherMap) {
        println("  ${key}")
    }
    
    map.remove(all: keysFromAnotherMap)
    
    println("\nFinal TreeMap: ${map}")
    println("Final size: ${map.size}")
    
    return 0
}
```

Output:

```text
TreeMap before removal: [(apple, 10), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50)]
Size before removal: 5

Keys to remove:
  banana
  date
  nonexistent

TreeMap after removal: [(apple, 10), (cherry, 30), (elderberry, 50)]
Size after removal: 3

Keys from another TreeMap:
  apple
  cherry
  grape

Final TreeMap: [(elderberry, 50)]
Final size: 1
```

### func removeIf((K, V) -> Bool)

```cangjie
public func removeIf(predicate: (K, V) -> Bool): Unit
```

Function: Takes a lambda expression and removes key-value pairs that satisfy the condition.

Parameters:

- predicate: (K, V) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - A lambda expression for condition evaluation.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when `predicate` adds or removes key-value pairs within the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Add some elements
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    map.add("elderberry", 50)
    map.add("fig", 60)
    
    println("TreeMap before removal: ${map}")
    println("Size before removal: ${map.size}")
    
    // Remove key-value pairs where value > 30
    map.removeIf({_: String, value: Int64 => value > 30})
    
    println("\nAfter removing elements with value > 30:")
    println("TreeMap: ${map}")
    println("Size: ${map.size}")
    
    // Remove key-value pairs where key length <= 5
    map.removeIf({key: String, _: Int64 => key.size <= 5})
    
    println("\nAfter removing elements with key length <= 5:")
    println("TreeMap: ${map}")
    println("Size: ${map.size}")
    
    // Add more elements for demonstration
    map.add("avocado", 15)
    map.add("blueberry", 25)
    map.add("coconut", 35)
    
    println("\nAfter adding new elements:")
    println("TreeMap: ${map}")
    println("Size: ${map.size}")
    
    // Remove key-value pairs where key starts with 'b'
    map.removeIf({key: String, _: Int64 => key.startsWith("b")})
    
    println("\nAfter removing elements with keys starting with 'b':")
    println("TreeMap: ${map}")
    println("Size: ${map.size}")
    
    return 0
}
```

Output:

```text
TreeMap before removal: [(apple, 10), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50), (fig, 60)]
Size before removal: 6

After removing elements with value > 30:
TreeMap: [(apple, 10), (banana, 20), (cherry, 30)]
Size: 3

After removing elements with key length <= 5:
TreeMap: [(banana, 20), (cherry, 30)]
Size: 2

After adding new elements:
TreeMap: [(avocado, 15), (banana, 20), (blueberry, 25), (cherry, 30), (coconut, 35)]
Size: 5

After removing elements with keys starting with 'b':
TreeMap: [(avocado, 15), (cherry, 30), (coconut, 35)]
Size: 3
```

### func values()

```cangjie
public func values(): Collection<V>
```

Function: Returns the values contained in the [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek), storing all values in a container.

Returns:

- [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<V> - A collection containing all values.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("date", 40)
    
    // Get all values
    let valueCollection = map.values()
    
    println("All values:")
    for (value in valueCollection) {
        println("Value: ${value}")
    }
    
    // Verify the count of values
    println("\nValue count: ${valueCollection.size}")
    println("TreeMap size: ${map.size}")
    
    return 0
}
```

Execution Result:

```text
All values:
Value: 10
Value: 20
Value: 30
Value: 40

Value count: 4
TreeMap size: 4
```

### operator func \[](K, V)

```cangjie
public operator func [](key: K, value!: V): Unit
```

Function: Operator overload for collections. If the key exists, the new value overwrites the old value; if the key does not exist, adds this key-value pair.

Parameters:

- key: K - The key to evaluate.
- value!: V - The value to set.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // Use operator overload to set key-value pairs
    map["apple"] = 10
    map["banana"] = 20
    map["cherry"] = 30
    
    println("TreeMap after setting: ${map}")
    println("Size: ${map.size}")
    
    // Overwrite the value of an existing key
    map["apple"] = 15  // Overwrites the original value 10
    
    println("\nAfter overwriting apple's value:")
    println("TreeMap: ${map}")
    
    // Add new key-value pairs
    map["date"] = 40
    map["elderberry"] = 50
    
    println("\nAfter adding more key-value pairs:")
    println("TreeMap: ${map}")
    println("Size: ${map.size}")
    
    // Overwrite again
    map["banana"] = 25
    map["cherry"] = 35
    
    println("\nAfter modifying values again:")
    println("TreeMap: ${map}")
    
    return 0
}
```

Execution Result:

```text
TreeMap after setting: [(apple, 10), (banana, 20), (cherry, 30)]
Size: 3

After overwriting apple's value:
TreeMap: [(apple, 15), (banana, 20), (cherry, 30)]

After adding more key-value pairs:
TreeMap: [(apple, 15), (banana, 20), (cherry, 30), (date, 40), (elderberry, 50)]
Size: 5

After modifying values again:
TreeMap: [(apple, 15), (banana, 25), (cherry, 35), (date, 40), (elderberry, 50)]
```

### operator func \[](K)

```cangjie
public operator func [](key: K): V
```

Function: Operator overload for collections. If the key exists, returns the corresponding value.

Parameters:

- key: K - The key to evaluate.

Returns:

- V - The value corresponding to the key.

Exceptions:

- [NoneValueException](../../core/core_package_api/core_package_exceptions.md#class-nonevalueexception) - Thrown if the key does not exist in the [HashMap](collection_package_class.md#class-hashmapk-v-where-k--hashable--equatablek).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let map = TreeMap<String, Int64>()
    
    // First, add some key-value pairs
    map.add("apple", 10)
    map.add("banana", 20)
    map.add("cherry", 30)
    map.add("date", 40)
    
    println("TreeMap contents: ${map}")
    
    // Use operator overload to get values
    let appleValue = map["apple"]
    let bananaValue = map["banana"]
    let cherryValue = map["cherry"]
    
    println("\nUsing [] operator to get values:")
    println("apple's value: ${appleValue}")
    println("banana's value: ${bananaValue}")
    println("cherry's value: ${cherryValue}")
    
    // Get all values and calculate the sum
    let total = map["apple"] + map["banana"] + map["cherry"] + map["date"]
    println("\nTotal of all values: ${total}")
    
    // Attempt to access a non-existent key (will throw an exception)
    println("\nAttempting to access a non-existent key:")
    try {
        let value = map["nonexistent"]
        println("Got value: ${value}")
    } catch (e: Exception) {
        println("Caught exception: ${e}")
    }
    
    return 0
}
```

Execution Result:

```text
TreeMap contents: [(apple, 10), (banana, 20), (cherry, 30), (date, 40)]

Using [] operator to get values:
apple's value: 10
banana's value: 20
cherry's value: 30

Total of all values: 100

Attempting to access a non-existent key:
Caught exception: NoneValueException: Value does not exist!
```

### extend\<K, V> TreeMap\<K, V> <: Equatable\<TreeMap\<K, V>> where V <: Equatable\<V>

```cangjie
extend<K, V> TreeMap<K, V> <: Equatable<TreeMap<K, V>> where V <: Equatable<V>
```

Function: Extends the [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> type with the [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V>> interface, supporting equality comparison.

Parent Type:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V>>

#### operator func ==(TreeMap\<K, V>)

```cangjie
public operator func ==(right: TreeMap<K, V>): Bool
```

Function: Determines whether the current instance is equal to the parameter's [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> instance.

Two [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> instances are considered equal if they contain identical key-value pairs.

Parameters:

- right: [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two identical TreeMaps
    let map1 = TreeMap<String, Int64>()
    map1.add("apple", 10)
    map1.add("banana", 20)
    map1.add("cherry", 30)
    
    let map2 = TreeMap<String, Int64>()
    map2.add("apple", 10)
    map2.add("banana", 20)
    map2.add("cherry", 30)
    
    println("map1: ${map1}")
    println("map2: ${map2}")
    println("map1 == map2: ${map1 == map2}")
    
    // Create a different TreeMap
    let map3 = TreeMap<String, Int64>()
    map3.add("apple", 10)
    map3.add("banana", 20)
    map3.add("date", 40)  // Different key-value pair
    
    println("\nmap3: ${map3}")
    println("map1 == map3: ${map1 == map3}")
    
    // Create a TreeMap with the same keys but different values
    let map4 = TreeMap<String, Int64>()
    map4.add("apple", 15)  // Different value
    map4.add("banana", 20)
    map4.add("cherry", 30)
    
    println("\nmap4: ${map4}")
    println("map1 == map4: ${map1 == map4}")
    
    // Compare empty TreeMaps
    let emptyMap1 = TreeMap<String, Int64>()
    let emptyMap2 = TreeMap<String, Int64>()
    
    println("\nemptyMap1: ${emptyMap1}")
    println("emptyMap2: ${emptyMap2}")
    println("emptyMap1 == emptyMap2: ${emptyMap1 == emptyMap2}")
    println("map1 == emptyMap1: ${map1 == emptyMap1}")
    
    return 0
}
```

Execution Result:

```text
map1: [(apple, 10), (banana, 20), (cherry, 30)]
map2: [(apple, 10), (banana, 20), (cherry, 30)]
map1 == map2: true

map3: [(apple, 10), (banana, 20), (date, 40)]
map1 == map3: false

map4: [(apple, 15), (banana, 20), (cherry, 30)]
map1 == map4: false

emptyMap1: []
emptyMap2: []
emptyMap1 == emptyMap2: true
map1 == emptyMap1: false
```

#### operator func !=(TreeMap\<K, V>)

```cangjie
public operator func !=(right: TreeMap<K, V>): Bool
```

Function: Determines whether the current instance is not equal to the parameter's [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> instance.

Parameters:

- right: [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> - The object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create two identical TreeMaps
    let map1 = TreeMap<String, Int64>()
    map1.add("apple", 10)
    map1.add("banana", 20)
    map1.add("cherry", 30)
    
    let map2 = TreeMap<String, Int64>()
    map2.add("apple", 10)
    map2.add("banana", 20)
    map2.add("cherry", 30)
    
    println("map1: ${map1}")
    println("map2: ${map2}")
    println("map1 != map2: ${map1 != map2}")
    
    // Create a different TreeMap
    let map3 = TreeMap<String, Int64>()
    map3.add("apple", 10)
    map3.add("banana", 20)
    map3.add("date", 40)  // Different key-value pair
    
    println("\nmap3: ${map3}")
    println("map1 != map3: ${map1 != map3}")
    
    // Create a TreeMap with the same keys but different values
    let map4 = TreeMap<String, Int64>()
    map4.add("apple", 15)  // Different value
    map4.add("banana", 20)
    map4.add("cherry", 30)
    
    println("\nmap4: ${map4}")
    println("map1 != map4: ${map1 != map4}")
    
    // Compare empty and non-empty TreeMaps
    let emptyMap = TreeMap<String, Int64>()
    println("\nemptyMap: ${emptyMap}")
    println("map1 != emptyMap: ${map1 != emptyMap}")
    
    // Compare two empty TreeMaps
    let anotherEmptyMap = TreeMap<String, Int64>()
    println("emptyMap != anotherEmptyMap: ${emptyMap != anotherEmptyMap}")
    
    return 0
}
```

Execution Result:

```text
map1: [(apple, 10), (banana, 20), (cherry, 30)]
map2: [(apple, 10), (banana, 20), (cherry, 30)]
map1 != map2: false

map3: [(apple, 10), (banana, 20), (date, 40)]
map1 != map3: true

map4: [(apple, 15), (banana, 20), (cherry, 30)]
map1 != map4: true

emptyMap: []
map1 != emptyMap: true
emptyMap != anotherEmptyMap: false
```

### extend\<K, V> TreeMap\<K, V> <: ToString where V <: ToString, K <: ToString & Comparable\<K>

```cangjie
extend<K, V> TreeMap<K, V> <: ToString where V <: ToString, K <: ToString & Comparable<K>
```

Function: Extends the [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface, supporting string conversion.

Parent Type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current [TreeMap](./collection_package_class.md#class-treemapk-v-where-k--comparablek)\<K, V> instance to a string.

The string includes the string representation of each key-value pair in the [TreeMap](./collection_package_class.md#class-treemapk-v-wwhere-k--comparablek)\<K, V>, formatted as: "[(k1, v1), (k2, v2), (k3, v3)]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The resulting string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // String representation of an empty TreeMap
    let emptyMap = TreeMap<String, Int64>()
    println("Empty TreeMap: ${emptyMap.toString()}")
    
    // String representation of a non-empty TreeMap
    let map = TreeMap<String, Int64>()
    map.add("cherry", 30)
    map.add("apple", 10)
    map.add("banana", 20)
    
    println("Non-empty TreeMap: ${map.toString()}")
    
    // Direct printing (automatically calls toString)
    println("Direct print: ${map}")
    
    return 0
}
```

Execution Result:

```text
Empty TreeMap: []
Non-empty TreeMap: [(apple, 10), (banana, 20), (cherry, 30)]
Direct print: [(apple, 10), (banana, 20), (cherry, 30)]
```

## class TreeSet\<T> where T <: Comparable\<T>

```cangjie
public class TreeSet<T> <: OrderedSet<T> where T <: Comparable<T> {
    public init()
    public init(elements: Collection<T>)
    public init(size: Int64, initElement: (Int64) -> T)
}
```

Function: An implementation of the [Set](collection_package_interface.md#interface-sett) interface based on [TreeMap](collection_package_class.md#class-treemapk-v-where-k--comparablek).

The primary purpose of this class is to provide an ordered element storage structure that enables fast insertion, deletion, and lookup of elements.

[TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) can be used in any scenario requiring ordered element storage, such as databases, caches, lookup tables, etc.

Parent Types:

- [OrderedSet](collection_package_interface.md#interface-orderedsett)\<T>

### prop first

```cangjie
public prop first: ?T
```

Function: Retrieves the first element of the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty TreeSet
    let emptySet = TreeSet<String>()
    println("First element of empty set: ${emptySet.first}")
    
    // Create a TreeSet with elements
    let set = TreeSet<String>()
    set.add("banana")
    set.add("apple") 
    set.add("cherry")
    
    println("First element of populated set: ${set.first}")
    
    return 0
}
```

Output:

```text
First element of empty set: None
First element of populated set: Some(apple)
```

### prop last

```cangjie
public prop last: ?T
```

Function: Retrieves the last element of the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Type: ?T

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty TreeSet
    let emptySet = TreeSet<String>()
    println("Last element of empty set: ${emptySet.last}")
    
    // Create a TreeSet with elements
    let set = TreeSet<String>()
    set.add("banana")
    set.add("apple") 
    set.add("cherry")
    
    println("Last element of populated set: ${set.last}")
    
    return 0
}
```

Output:

```text
Last element of empty set: None
Last element of populated set: Some(cherry)
```

### prop size

```cangjie
public prop size: Int64
```

Function: Returns the number of elements.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty TreeSet
    let emptySet = TreeSet<String>()
    println("Size of empty set: ${emptySet.size}")
    
    // Create a TreeSet with elements
    let set = TreeSet<String>()
    set.add("banana")
    set.add("apple") 
    set.add("cherry")
    
    println("Size of populated set: ${set.size}")
    
    return 0
}
```

Output:

```text
Size of empty set: 0
Size of populated set: 3
```

### init()

```cangjie
public init()
```

Function: Constructs an empty [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an empty TreeSet using parameterless constructor
    let set = TreeSet<String>()
    println("Initial size: ${set.size}")
    
    // Add elements
    set.add("hello")
    set.add("world")
    println("Size after adding elements: ${set.size}")
    
    return 0
}
```

Output:

```text
Initial size: 0
Size after adding elements: 2
```

### init(Collection\<T>)

```cangjie
public init(elements: Collection<T>)
```

Function: Constructs a [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) from a collection of elements.

Elements are inserted into the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) in the order of the elements' iterator. Since duplicate elements are not allowed in a [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet), only one instance of each element will be retained if duplicates exist in the input collection.

Parameters:

- elements: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to initialize this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create an array as initial elements
    let arr = ["apple", "banana", "cherry", "apple", "banana"] // Contains duplicates
    
    // Create a set using Collection constructor
    let set = TreeSet<String>(arr)
    println("Set size: ${set.size}")
    println("Set contents: ${set}")
    
    return 0
}
```

Output:

```text
Set size: 3
Set contents: [apple, banana, cherry]
```

### init(Int64, (Int64) -> T)

```cangjie
public init(size: Int64, initElement: (Int64) -> T)
```

Function: Constructs a [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) with a specified number of elements generated by a function.

Parameters:

- size: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The number of elements to generate.
- initElement: ([Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) -> T - The function rule to generate elements for this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if size is less than 0.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a TreeSet using size and generation function
    let set = TreeSet<String>(5, {i => "item${i}"})
    println("TreeSet size: ${set.size}")
    println("TreeSet contents: ${set}")
    
    return 0
}
```

Output:

```text
TreeSet size: 5
TreeSet contents: [item0, item1, item2, item3, item4]
```

### static func of(Array\<T>)

```cangjie
public static func of(elements: Array<T>): TreeSet<T>
```

Function: Constructs a [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) containing all elements from the specified array.

Elements are inserted into the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) in the order they appear in the array. Since duplicate elements are not allowed in a [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet), only one instance of each element will be retained if duplicates exist in the input array.

Parameters:

- elements: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - The input array (varargs syntax allows omitting array literal `[]`).

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - A TreeSet containing elements of type T.

> **Note:**
>
> This function supports varargs parameter passing. For example, `TreeSet.of(1, 2, 3)` is equivalent to `TreeSet.of([1, 2, 3])`.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create a set using static method of
    let arr = ["banana", "apple", "cherry", "apple", "banana"] // Contains duplicates
    let set = TreeSet.of(arr)
    
    println("Original array length: ${arr.size}")
    println("Set size: ${set.size}")
    println("Set contents: ${set}")
    
    return 0
}
```

Output:

```text
Original array length: 5
Set size: 3
Set contents: [apple, banana, cherry]
```

### func add(T)

```cangjie
public func add(element: T): Bool
```

Function: Adds a new element to the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet). Fails if the element already exists.

Parameters:

- element: T - The element to add.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the element was added successfully; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    
    // Add new element (returns true)
    let result1 = set.add("apple")
    println("Added 'apple': ${result1}")
    println("Current set: ${set}")
    
    // Attempt to add existing element (returns false)
    let result2 = set.add("apple")
    println("Added 'apple' again: ${result2}")
    println("Current set: ${set}")
    
    // Add more elements
    set.add("banana")
    set.add("cherry")
    println("Final set: ${set}")
    
    return 0
}
```

Output:

```text
Added 'apple': true
Current set: [apple]
Added 'apple' again: false
Current set: [apple]
Final set: [apple, banana, cherry]
```

### func add(Collection\<T>)

```cangjie
public func add(all!: Collection<T>): Unit
```

Function: Adds all elements from the [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont) to this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet). Existing elements will not be added.

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to add.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    println("Initial set: ${set}")
    
    // Create a collection to add
    let toAdd = ["banana", "cherry", "apple", "date"]
    set.add(all: toAdd)
    
    println("Set after addition: ${set}")
    println("Set size: ${set.size}")
    
    return 0
}
```

Output:

```text
Initial set: [apple]
Set after addition: [apple, banana, cherry, date]
Set size: 4
```

### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

Function: Determines whether all elements in the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements in the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) satisfy the condition; otherwise, returns false.

### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

Function: Determines whether any element in the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) satisfies the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if any element satisfies the condition; otherwise, returns false.

### func backward(T, Bool)

```cangjie
public func backward(mark: T, inclusive!: Bool = true): Iterator<T>
```

Function: Obtains an iterator that traverses from the first node with a key less than or equal to `mark` in descending order to [first](./collection_package_class.md#prop-first-4). If the node's key equals `mark`, the `inclusive!` parameter determines whether to include the node.

Parameters:

- mark: T - The element used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the first element of the iterator, specifies whether to include `mark` as the starting point. Defaults to `true`.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the corresponding elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana") 
    set.add("cherry")
    set.add("date")
    set.add("elderberry")
    
    println("Complete set: ${set}")
    
    // Traverse backward from "cherry" (including cherry)
    println("Backward traversal from cherry (inclusive):")
    for (item in set.backward("cherry", inclusive: true)) {
        println("  ${item}")
    }
    
    // Traverse backward from "cherry" (excluding cherry)
    println("Backward traversal from cherry (exclusive):")
    for (item in set.backward("cherry", inclusive: false)) {
        println("  ${item}")
    }
    
    return 0
}
```

Output:

```text
Complete set: [apple, banana, cherry, date, elderberry]
Backward traversal from cherry (inclusive):
  cherry
  banana
  apple
Backward traversal from cherry (exclusive):
  banana
  apple
```

### func clear()

```cangjie
public func clear(): Unit
```

Function: Removes all elements from the set.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana") 
    set.add("cherry")
    
    println("Set before clearing: ${set}")
    println("Size before clearing: ${set.size}")
    
    // Clear all elements
    set.clear()
    
    println("Set after clearing: ${set}")
    println("Size after clearing: ${set.size}")
    println("Is set empty: ${set.isEmpty()}")
    
    return 0
}
```

Output:

```text
Set before clearing: [apple, banana, cherry]
Size before clearing: 3
Set after clearing: []
Size after clearing: 0
Is set empty: true
```

### func clone()

```cangjie
public func clone(): TreeSet<T>
```

Function: Creates a clone of the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - Returns a new [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) instance.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let originalSet = TreeSet<String>()
    originalSet.add("apple")
    originalSet.add("banana") 
    originalSet.add("cherry")
    
    println("Original set: ${originalSet}")
    
    // Clone the set
    let clonedSet = originalSet.clone()
    println("Cloned set: ${clonedSet}")
    
    // Modify original and cloned sets to verify independence
    originalSet.add("date")
    clonedSet.add("elderberry")
    
    println("Modified original set: ${originalSet}")
    println("Modified cloned set: ${clonedSet}")
    
    return 0
}
```

Output:

```text
Original set: [apple, banana, cherry]
Cloned set: [apple, banana, cherry]
Modified original set: [apple, banana, cherry, date]
Modified cloned set: [apple, banana, cherry, elderberry]
```

### func contains(T)

```cangjie
public func contains(element: T): Bool
```

Function: Checks whether the set contains the specified element.

Parameters:

- element: T - The specified element.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the element is present; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana") 
    set.add("cherry")
    
    println("Set contents: ${set}")
    
    // Check existing elements
    println("Contains 'apple': ${set.contains("apple")}")
    println("Contains 'banana': ${set.contains("banana")}")
    
    // Check non-existing elements
    println("Contains 'date': ${set.contains("date")}")
    println("Contains 'elderberry': ${set.contains("elderberry")}")
    
    return 0
}
```

Output:

```text
Set contents: [apple, banana, cherry]
Contains 'apple': true
Contains 'banana': true
Contains 'date': false
Contains 'elderberry': false
```

### func contains(Collection\<T>)

```cangjie
public func contains(all!: Collection<T>): Bool
```

Function: Determines whether the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) contains all elements from the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The specified collection of elements.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements from the [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont) are present; otherwise, returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana") 
    set.add("cherry")
    set.add("date")
    
    println("Main set: ${set}")
    
    // Create test collections
    let checkSet1 = ["apple", "banana"]
    let checkSet2 = ["apple", "elderberry"]
    let checkSet3 = ["fig", "grape"]
    
    println("Contains all ['apple', 'banana']: ${set.contains(all: checkSet1)}")
    println("Contains all ['apple', 'elderberry']: ${set.contains(all: checkSet2)}")
    println("Contains all ['fig', 'grape']: ${set.contains(all: checkSet3)}")
    
    return 0
}
```

Output:

```text
Main set: [apple, banana, cherry, date]
Contains all ['apple', 'banana']: true
Contains all ['apple', 'elderberry']: false
Contains all ['fig', 'grape']: false
```

### func filter((T) -> Bool)
```cangjie
public func filter(predicate: (T) -> Bool): TreeSet<T>
```

Function: Returns a new [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> containing elements that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified condition.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - A new set containing filtered elements.

### func filterMap\<R>((T) -> Option\<R>)

```cangjie
public func filterMap<R>(transform: (T) -> Option<R>): TreeSet<R> where R <: Comparable<R>
```

Function: Performs both filtering and mapping operations, returning a new [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Parameters:

- transform: (T) -> Option\<R> - The mapping function. A return value of Some corresponds to a predicate of true, while None corresponds to false.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<R> - A new set containing filtered and mapped elements.

### func fold\<R>(R, (R, T) -> R)

```cangjie
public func fold<R>(initial: R, operation: (R, T) -> R): R
```

Function: Computes a value by applying an operation from left to right with the specified initial value.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- initial: R - The initial value of type R.
- operation: (R, T) -> R - The computation function.

Returns:

- R - The final computed value.

### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

Function: Iterates over all elements and applies the given action.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The specified action function.

### func forward(T, Bool)

```cangjie
public func forward(mark: T, inclusive!: Bool = true): Iterator<T>
```

Function: Obtains an iterator that traverses from the first element greater than or equal to `mark` in ascending order to [last](./collection_package_class.md#prop-last-3). If the element equals `mark`, the `inclusive!` parameter determines whether to include the element.

Parameters:

- mark: T - The element used to determine the starting point.
- inclusive!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - When `mark` is the first element of the iterator, specifies whether to include `mark` as the starting point. Defaults to `true`.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the corresponding elements.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana") 
    set.add("cherry")
    set.add("date")
    set.add("elderberry")
    
    println("Complete set: ${set}")
    
    // Traverse forward from "cherry" (including cherry)
    println("Forward traversal from cherry (inclusive):")
    for (item in set.forward("cherry", inclusive: true)) {
        println("  ${item}")
    }
    
    // Traverse forward from "cherry" (excluding cherry)
    println("Forward traversal from cherry (exclusive):")
    for (item in set.forward("cherry", inclusive: false)) {
        println("  ${item}")
    }
    
    return 0
}
```

Output:

```text
Complete set: [apple, banana, cherry, date, elderberry]
Forward traversal from cherry (inclusive):
  cherry
  date
  elderberry
Forward traversal from cherry (exclusive):
  date
  elderberry
```Here is the professional translation of the provided Markdown content from Chinese to English, maintaining all structural and formatting elements:


### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) is empty.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if empty, otherwise false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    // Create empty set
    let emptySet = TreeSet<String>()
    println("Is empty set empty: ${emptySet.isEmpty()}")
    
    // Create non-empty set
    let nonEmptySet = TreeSet<String>()
    nonEmptySet.add("apple")
    println("Is non-empty set empty: ${nonEmptySet.isEmpty()}")
    
    // Check after clearing set
    nonEmptySet.clear()
    println("Is set empty after clearing: ${nonEmptySet.isEmpty()}")
    
    return 0
}
```

Execution Result:

```text
Is empty set empty: true
Is non-empty set empty: false
Is set empty after clearing: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Returns an iterator for the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) that iterates elements in ascending order.

Returns:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<T> - An iterator for the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("cherry")
    set.add("apple") 
    set.add("banana")
    set.add("date")
    
    println("Set contents: ${set}")
    println("Iterating with iterator:")
    
    // Iterate using iterator
    for (item in set.iterator()) {
        println("  ${item}")
    }
    
    return 0
}
```

Execution Result:

```text
Set contents: [apple, banana, cherry, date]
Iterating with iterator:
  apple
  banana
  cherry
  date
```

### func map\<R>((T)->R)

```cangjie
public func map<R>(transform: (T) -> R): TreeSet<R> where R <: Comparable<R>
```

Function: Transforms all elements of type T in the current [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) into elements of type R using the transform function, forming a new [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T)->R - The transformation function.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<R> - A new [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) containing all transformed elements from the original set.

### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

Function: Determines whether none of the elements in the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the elements in the current [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) satisfy the condition.

### func reduce((T, T) -> T)

```cangjie
public func reduce(operation: (T, T) -> T): Option<T>
```

Function: Uses the first element as the initial value and computes from left to right.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- operation: (T, T) -> T - The given computation function.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - Returns the computation result.

### func removeFirst()

```cangjie
public func removeFirst(): ?T
```

Function: Removes the first element from the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Returns:

- ?T - If the first element exists, removes it and returns the element wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("cherry")
    set.add("apple") 
    set.add("banana")
    set.add("date")
    
    println("Original set: ${set}")
    
    // Remove first element
    let first = set.removeFirst()
    println("Removed first element: ${first}")
    println("Set after removal: ${set}")
    
    // Remove next first element
    let second = set.removeFirst()
    println("Removed second element: ${second}")
    println("Set after second removal: ${set}")
    
    return 0
}
```

Execution Result:

```text
Original set: [apple, banana, cherry, date]
Removed first element: Some(apple)
Set after removal: [banana, cherry, date]
Removed second element: Some(banana)
Set after second removal: [cherry, date]
```

### func removeLast()

```cangjie
public func removeLast(): ?T
```

Function: Removes the last element from the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Returns:

- ?T - If the last element exists, removes it and returns the element wrapped in [Option](../../core/core_package_api/core_package_enums.md#enum-optiont); otherwise returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>.None.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("cherry")
    set.add("apple") 
    set.add("banana")
    set.add("date")
    
    println("Original set: ${set}")
    
    // Remove last element
    let last = set.removeLast()
    println("Removed last element: ${last}")
    println("Set after removal: ${set}")
    
    // Remove next last element
    let secondLast = set.removeLast()
    println("Removed second last element: ${secondLast}")
    println("Set after second removal: ${set}")
    
    return 0
}
```

Execution Result:

```text
Original set: [apple, banana, cherry, date]
Removed last element: Some(date)
Set after removal: [apple, banana, cherry]
Removed second last element: Some(cherry)
Set after second removal: [apple, banana]
```

### func remove(T)

```cangjie
public func remove(element: T): Bool
```

Function: Removes the specified element if it exists in this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Parameters:

- element: T - The element to be removed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true if removal was successful; false otherwise.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    
    println("Initial set: ${set}")
    
    // Remove existing element, returns true
    let result1 = set.remove("banana")
    println("Remove 'banana': ${result1}")
    println("Set after removal: ${set}")
    
    // Remove non-existent element, returns false
    let result2 = set.remove("date")
    println("Remove 'date': ${result2}")
    println("Set after removal: ${set}")
    
    return 0
}
```

Execution Result:

```text
Initial set: [apple, banana, cherry]
Remove 'banana': true
Set after removal: [apple, cherry]
Remove 'date': false
Set after removal: [apple, cherry]
```

### func remove(Collection\<T>)

```cangjie
public func remove(all!: Collection<T>): Unit
```

Function: Removes from this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) all elements that are also contained in the specified [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont).

Parameters:

- all!: [Collection](../../core/core_package_api/core_package_interfaces.md#interface-collectiont)\<T> - The collection of elements to be removed from this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    set.add("date")
    set.add("elderberry")
    
    println("Initial set: ${set}")
    
    // Create collection of elements to remove
    let toRemove = ["banana", "date", "fig"] // "fig" doesn't exist in original set
    
    // Remove elements
    set.remove(all: toRemove)
    
    println("Set after removal: ${set}")
    
    return 0
}
```

Execution Result:

```text
Initial set: [apple, banana, cherry, date, elderberry]
Set after removal: [apple, cherry, elderberry]
```

### func removeIf((T) -> Bool)

```cangjie
public func removeIf(predicate: (T) -> Bool): Unit
```

Function: Takes a lambda expression and removes elements that satisfy the `true` condition.

Parameters:

- predicate: (T) ->[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The condition determining whether to remove an element.

Exceptions:

- [ConcurrentModificationException](./collection_package_exception.md#class-concurrentmodificationexception) - Thrown when elements are added or removed within the `predicate` while iterating the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet).

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    set.add("date")
    set.add("elderberry")
    
    println("Initial set: ${set}")
    
    // Remove elements with length > 5
    set.removeIf({s => s.size > 5})
    
    println("Set after removing elements with length > 5: ${set}")
    
    return 0
}
```

Execution Result:

```text
Initial set: [apple, banana, cherry, date, elderberry]
Set after removing elements with length > 5: [apple, date]
```

### func retain(Set\<T>)

```cangjie
public func retain(all!: Set<T>): Unit
```

Function: Retains only the elements in this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) that are contained in the specified [Set](collection_package_interface.md#interface-sett), removing all others.

Parameters:

- all!: [Set](collection_package_interface.md#interface-sett)\<T> - The [Set](collection_package_interface.md#interface-sett) containing elements to be retained.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    set.add("date")
    set.add("elderberry")
    
    println("Initial set: ${set}")
    
    // Create set of elements to retain
    let toRetain = TreeSet.of(["banana", "date", "fig"]) // "fig" doesn't exist in original set
    
    // Retain specified elements
    set.retain(all: toRetain)
    
    println("Set after retaining elements: ${set}")
    
    return 0
}
```

Execution Result:

```text
Initial set: [apple, banana, cherry, date, elderberry]
Set after retaining elements: [banana, date]
```

### func subsetOf(ReadOnlySet\<T>)

```cangjie
public func subsetOf(other: ReadOnlySet<T>): Bool
```

Function: Checks whether this set is a subset of another [ReadOnlySet](collection_package_interface.md#interface-readonlysett).

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set to compare against.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if this [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet) is a subset of the specified [ReadOnlySet](collection_package_interface.md#interface-readonlysett); otherwise returns false.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    
    let set2 = TreeSet<String>()
    set2.add("apple")
    set2.add("banana")
    set2.add("cherry")
    set2.add("date")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Check if set1 is a subset of set2
    let result1 = set1.subsetOf(set2)
    println("set1 is subset of set2: ${result1}")
    
    // Check if set2 is a subset of set1
    let result2 = set2.subsetOf(set1)
    println("set2 is subset of set1: ${result2}")
    
    // Check if empty set is a subset of set1
    let emptySet = TreeSet<String>()
    let result3 = emptySet.subsetOf(set1)
    println("empty set is subset of set1: ${result3}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana]
Set 2: [apple, banana, cherry, date]
set1 is subset of set2: true
set2 is subset of set1: false
empty set is subset of set1: true
```

### func toArray()

```cangjie
public func toArray(): Array<T>
```

Function: Returns an array containing all elements in the container.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> - An array of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    set.add("date")
    
    println("TreeSet contents: ${set}")
    
    // Convert to array
    let array = set.toArray()
    
    println("Converted array: ${array}")
    println("Array length: ${array.size}")
    
    // Iterate through array
    println("Array elements:")
    for (item in array) {
        println("  ${item}")
    }
    
    return 0
}
```

Output:

```text
TreeSet contents: [apple, banana, cherry, date]
Converted array: [apple, banana, cherry, date]
Array length: 4
Array elements:
  apple
  banana
  cherry
  date
```

### operator func &(ReadOnlySet\<T>)

```cangjie
public operator func &(other: ReadOnlySet<T>): TreeSet<T>
```

Function: Returns a new set containing the intersection of two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("cherry")
    
    let set2 = TreeSet<String>()
    set2.add("banana")
    set2.add("cherry")
    set2.add("date")
    set2.add("elderberry")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate intersection
    let intersection = set1 & set2
    
    println("Intersection result: ${intersection}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana, cherry]
Set 2: [banana, cherry, date, elderberry]
Intersection result: [banana, cherry]
```

### operator func |(ReadOnlySet\<T>)

```cangjie
public operator func |(other: ReadOnlySet<T>): TreeSet<T>
```

Function: Returns a new set containing the union of two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("cherry")
    
    let set2 = TreeSet<String>()
    set2.add("banana")
    set2.add("cherry")
    set2.add("date")
    set2.add("elderberry")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate union
    let union = set1 | set2
    
    println("Union result: ${union}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana, cherry]
Set 2: [banana, cherry, date, elderberry]
Union result: [apple, banana, cherry, date, elderberry]
```

### operator func -(ReadOnlySet\<T>)

```cangjie
public operator func -(other: ReadOnlySet<T>): TreeSet<T>
```

Function: Returns a new set containing the difference between two sets.

Parameters:

- other: [ReadOnlySet](collection_package_interface.md#interface-readonlysett)\<T> - The input set.

Returns:

- [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - A set of type T.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("cherry")
    
    let set2 = TreeSet<String>()
    set2.add("banana")
    set2.add("cherry")
    set2.add("date")
    set2.add("elderberry")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    
    // Calculate difference (set1 - set2)
    let difference = set1 - set2
    
    println("Difference result (set1 - set2): ${difference}")
    
    // Calculate difference (set2 - set1)
    let difference2 = set2 - set1
    
    println("Difference result (set2 - set1): ${difference2}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana, cherry]
Set 2: [banana, cherry, date, elderberry]
Difference result (set1 - set2): [apple]
Difference result (set2 - set1): [date, elderberry]
```

### extend\<T> TreeSet\<T> <: Equatable\<TreeSet\<T>>

```cangjie
extend<T> TreeSet<T> <: Equatable<TreeSet<T>>
```

Function: Extends [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> with [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T>> interface to support equality comparison.

Parent Type:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T>>

#### operator func ==(TreeSet\<T>)

```cangjie
public operator func ==(that: TreeSet<T>): Bool
```

Function: Determines whether the current instance is equal to the specified [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> instance.

Two [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> instances are considered equal if they contain exactly the same elements.

Parameters:

- that: [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - The set to compare with.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("cherry")
    
    let set2 = TreeSet<String>()
    set2.add("apple")
    set2.add("banana")
    set2.add("cherry")
    
    let set3 = TreeSet<String>()
    set3.add("apple")
    set3.add("banana")
    set3.add("date")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    println("Set 3: ${set3}")
    
    // Compare equal sets
    let result1 = set1 == set2
    println("set1 == set2: ${result1}")
    
    // Compare unequal sets
    let result2 = set1 == set3
    println("set1 == set3: ${result2}")
    
    // Compare with self
    let result3 = set1 == set1
    println("set1 == set1: ${result3}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana, cherry]
Set 2: [apple, banana, cherry]
Set 3: [apple, banana, date]
set1 == set2: true
set1 == set3: false
set1 == set1: true
```

#### operator func !=(TreeSet\<T>)

```cangjie
public operator func !=(that: TreeSet<T>): Bool
```

Function: Determines whether the current instance is not equal to the specified [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> instance.

Parameters:

- that: [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> - The set to compare with.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if not equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set1 = TreeSet<String>()
    set1.add("apple")
    set1.add("banana")
    set1.add("cherry")
    
    let set2 = TreeSet<String>()
    set2.add("apple")
    set2.add("banana")
    set2.add("cherry")
    
    let set3 = TreeSet<String>()
    set3.add("apple")
    set3.add("banana")
    set3.add("date")
    
    println("Set 1: ${set1}")
    println("Set 2: ${set2}")
    println("Set 3: ${set3}")
    
    // Compare unequal sets
    let result1 = set1 != set3
    println("set1 != set3: ${result1}")
    
    // Compare equal sets
    let result2 = set1 != set2
    println("set1 != set2: ${result2}")
    
    // Compare with self
    let result3 = set1 != set1
    println("set1 != set1: ${result3}")
    
    return 0
}
```

Output:

```text
Set 1: [apple, banana, cherry]
Set 2: [apple, banana, cherry]
Set 3: [apple, banana, date]
set1 != set3: true
set1 != set2: false
set1 != set1: false
```

### extend\<T> TreeSet\<T> <: ToString where T <: ToString

```cangjie
extend<T> TreeSet<T> <: ToString where T <: ToString
```

Function: Extends the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> with the [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring) interface to support string conversion operations.

Parent Type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the current [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T> instance into a string.

The resulting string contains the string representation of each element in the [TreeSet](collection_package_class.md#class-treesett-where-t--comparablet)\<T>, formatted as: "[elem1, elem2, elem3]".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

Example:

<!-- verify -->
```cangjie
import std.collection.*

main() {
    let set = TreeSet<String>()
    set.add("apple")
    set.add("banana")
    set.add("cherry")
    
    println("TreeSet contents: ${set}")
    
    // Convert to string
    let str = set.toString()
    
    println("Converted string: ${str}")
    
    // String representation of an empty set
    let emptySet = TreeSet<String>()
    let emptyStr = emptySet.toString()
    
    println("Empty set string: ${emptyStr}")
    
    return 0
}
```

Execution Result:

```text
TreeSet contents: [apple, banana, cherry]
Converted string: [apple, banana, cherry]
Empty set string: []
```
