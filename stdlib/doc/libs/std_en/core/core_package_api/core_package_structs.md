# Structs

## struct Array\<T>

```cangjie
public struct Array<T> {
    public const init()
    public init(size: Int64, repeat!: T)
    public init(size: Int64, initElement: (Int64) -> T)
}
```

Function: The Cangjie array type, used to represent an ordered sequence of elements of a single type.

T represents the element type of the array, which can be any type.

### prop first

```cangjie
public prop first: Option<T>
```

Function: Gets the first element of the current array. Returns None if the array is empty.

Type: [Option](core_package_enums.md#enum-optiont)\<T>

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]
    let first = arr.first
    println(first)
    
    // Test empty array case
    let emptyArr: Array<Int64> = []
    let emptyFirst = emptyArr.first
    println(emptyFirst)
}
```

Output:

```text
Some(1)
None
```

### prop last

```cangjie
public prop last: Option<T>
```

Function: Gets the last element of the current array. Returns None if the array is empty.

Type: [Option](core_package_enums.md#enum-optiont)\<T>

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]
    let last = arr.last
    println(last)
    
    // Test empty array case
    let emptyArr: Array<Int64> = []
    let emptyLast = emptyArr.last
    println(emptyLast)
}
```

Output:

```text
Some(3)
None
```

### init()

```cangjie
public const init()
```

Function: Constructs an empty array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> = Array()
    println("Empty array size: ${arr.size}")
    
    // Create a new array and add elements
    let newArr = [1, 2, 3]
    println("New array: ${newArr}")
}
```

Output:

```text
Empty array size: 0
New array: [1, 2, 3]
```

### init(Int64, (Int64) -> T)

```cangjie
public init(size: Int64, initElement: (Int64) -> T)
```

Function: Creates an array of specified length, where elements are obtained by computing the initialization function.

That is: Pass values in the range [0, size) to the initialization function initElement in sequence to obtain the elements at corresponding indices.

Parameters:

- size: [Int64](core_package_intrinsics.md#int64) - Array size.
- initElement: ([Int64](core_package_intrinsics.md#int64)) ->T - Initialization function.

Exceptions:

- [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) - Throws an exception when size is less than 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an array of length 5 where each element is the square of its index
    let arr = Array<Int64>(5, {index => index * index})
    println("Array with squares: ${arr}")
    
    // Create a string array of length 3 where each element is "Hello"
    let strArr = Array<String>(3, {_ => "Hello"})
    println("String array: ${strArr}")
}
```

Output:

```text
Array with squares: [0, 1, 4, 9, 16]
String array: [Hello, Hello, Hello]
```

### init(Int64, T)

```cangjie
public init(size: Int64, repeat!: T)
```

Function: Constructs an array of specified length where all elements are initialized with the specified value.

> **Note:**
>
> This constructor does not copy repeat. If repeat is a reference type, every element of the constructed array will point to the same reference.

Parameters:

- size: [Int64](core_package_intrinsics.md#int64) - Array size, valid range is [0, [Int64](core_package_intrinsics.md#int64).Max].
- repeat!: T - Initial value for array elements.

Exceptions:

- [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) - Throws an exception when size is less than 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Use named parameter repeat to initialize the array
    let arr = Array<Int64>(5, repeat: 42)
    println("Array with repeated value 42: ${arr}")
    
    // Create a string array of length 3 where all elements are initialized to "Hello"
    let strArr = Array<String>(3, repeat: "Hello")
    println("String array with repeated value: ${strArr}")
    
    // Create a boolean array of length 4 where all elements are initialized to true
    let boolArr = Array<Bool>(4, repeat: true)
    println("Boolean array with repeated value: ${boolArr}")
}
```

Output:

```text
Array with repeated value 42: [42, 42, 42, 42, 42]
String array with repeated value: [Hello, Hello, Hello]
Boolean array with repeated value: [true, true, true, true]
```

### func all((T) -> Bool)

```cangjie
public func all(predicate: (T) -> Bool): Bool
```

Function: Determines whether all elements in the array satisfy the condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if all elements satisfy the condition, otherwise returns false.

### func any((T) -> Bool)

```cangjie
public func any(predicate: (T) -> Bool): Bool
```

Function: Determines whether any element in the array satisfies the condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether any element satisfies the condition.

### func clone()

```cangjie
public func clone(): Array<T>
```

Function: Clones the array, performing a deep copy of the array data.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The newly cloned array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    let clonedArr = arr.clone()
    
    println("Original array: ${arr}")
    println("Cloned array: ${clonedArr}")
    
    // Verify the cloned array is independent
    clonedArr[0] = 10
    println("After modifying cloned array:")
    println("Original array: ${arr}")
    println("Cloned array: ${clonedArr}")
}
```

Output:

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

Function: Clones the specified range of the array.

> **Note:**
>
> 1. If the parameter range is constructed using the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor:
>    - The value of start is exactly the value passed to the constructor, unaffected by the hasStart parameter.
>    - When hasEnd is false, the end value is not effective (regardless of the isClosed parameter), and the slice includes all elements up to the last element of the original array.
> 2. The step size of range can only be 1.

Parameters:

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - The range to clone.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The newly cloned array.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Throws an exception when range exceeds the array bounds.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = arr.clone(1..4)
    println(new)
}
```

Output:

```text
[1, 2, 3]
```

### func concat(Array\<T>)

```cangjie
public func concat(other: Array<T>): Array<T>
```

Function: Creates a new array by concatenating the current array with the other array.

Parameters:

- other: [Array](core_package_structs.md#struct-arrayt)\<T> - The array to concatenate to the end of the current array.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The newly concatenated array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = arr.concat([6, 7, 8, 9, 10])
    println(new)
}
```

Output:

```text
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

### func copyTo(Array\<T>)

```cangjie
public func copyTo(dst: Array<T>): Unit
```

Function: Copies all elements of the current array to the destination array dst.

The copy length equals the length of the current array, starting from the beginning of the destination array. The current array's length must not exceed the destination array's length.

Parameters:

- dst: [Array](core_package_structs.md#struct-arrayt)\<T> - The destination array.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the current array's length exceeds the destination array's length.

Example:

<!-- verify -->
```cangjie
main() {
    let srcArr = [1, 2, 3, 4, 5]
    let dstArr = [0, 0, 0, 0, 0, 0, 0]
    
    println("Before copy:")
    println("Source array: ${srcArr}")
    println("Destination array: ${dstArr}")
    
    // Copy source array to destination array
    srcArr.copyTo(dstArr)
    
    println("After copy:")
    println("Source array: ${srcArr}")
    println("Destination array: ${dstArr}")
}
```

Output:

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

Function: Copies a segment of data from the current array to the target array.

Parameters:

- dst: [Array](core_package_structs.md#struct-arrayt)\<T> - The destination array.
- srcStart: [Int64](core_package_intrinsics.md#int64) - The starting index in the source array (this array) for copying, with valid range [0, this.size).
- dstStart: [Int64](core_package_intrinsics.md#int64) - The starting index in the destination array for writing, with valid range [0, dst.size).
- copyLen: [Int64](core_package_intrinsics.md#int64) - The length of data to copy. Requirements: copyLen + srcStart < this.size, copyLen + dstStart < dst.size.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if copyLen is less than 0.
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if parameters don't satisfy the specified ranges.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let new = [0, 0, 0, 0, 0, 0]
    arr.copyTo(new, 2, 2, 4)
    println(new)
}
```

Output:

```text
[0, 0, 2, 3, 4, 5]
```

### func fill(T)

```cangjie
public func fill(value: T): Unit
```

Function: Replaces all elements in the current array with the specified value.

Parameters:

- value: T - The target value for replacement.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Before fill: ${arr}")
    
    // Replace all elements with 0
    arr.fill(0)
    
    println("After fill: ${arr}")
    
    // Create another array and partially fill elements
    let arr2 = [1, 2, 3, 4, 5]
    println("Before partial fill: ${arr2}")
    
    // Only fill elements from index 1 to 3
    arr2[1..4].fill(-1)
    
    println("After partial fill: ${arr2}")
}
```

Output:

```text
Before fill: [1, 2, 3, 4, 5]
After fill: [0, 0, 0, 0, 0]
Before partial fill: [1, 2, 3, 4, 5]
After partial fill: [1, -1, -1, -1, 5]
```

### func filter((T) -> Bool)

```cangjie
public func filter(predicate: (T) -> Bool): Array<T> 
```

Function: Returns a new array containing elements that satisfy the given predicate.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - A new array containing elements that satisfy the predicate.

### func filterMap\<R>((T) -> ?R)

```cangjie
public func filterMap<R>(transform: (T) -> ?R): Array<R>
```

Function: Performs both filtering and mapping operations, returning a new array.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> ?R - The given transformation function. A return value of Some corresponds to predicate being true in filter, while None indicates false.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<R> - A new array after filtering and mapping.

### func flatMap\<R>((T) -> Array\<R>)

```cangjie
public func flatMap<R>(transform: (T) -> Array<R>): Array<R>
```

Function: Applies a transformation closure (transform) to each element in the array, where the closure returns an array, then flattens and concatenates all returned arrays into a single result array.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- transform: (T) -> [Array](core_package_structs.md#struct-arrayt)\<R> - The given transformation function.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<R> - A new array after "map" and "flatten" operations.

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
- operation: (R, T) -> R - The given computation function.

Returns:

- R - The final computed value.

### func forEach((T) -> Unit)

```cangjie
public func forEach(action: (T) -> Unit): Unit
```

Function: Iterates through all elements and executes the given action.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- action: (T) -> [Unit](../../core/core_package_api/core_package_intrinsics.md#unit) - The given action function.

### func get(Int64)

```cangjie
public func get(index: Int64): Option<T>
```

Function: Retrieves the element at the specified index in the array.

The result is wrapped in [Option](core_package_enums.md#enum-optiont). Returns None if the index is out of bounds.

Alternatively, the [] operator can be used to access elements, which throws an exception on out-of-bounds access.

Parameters:

- index: [Int64](core_package_intrinsics.md#int64) - The index of the element to retrieve.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<T> - The value at the specified index in the current array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2]
    let num = arr.get(0)
    println(num)
}
```

Output:

```text
Some(0)
```

### func intersperse(T)

```cangjie
public func intersperse(separator: T): Array<T>
```

Function: Returns a new array with the given element inserted between every two existing elements.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- separator: T - The given element.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - A new array.

### func map\<R>((T)->R)

```cangjie
public func map<R>(transform: (T)->R): Array<R>
```

Function: Maps all elements of type T in the current array to type R using the transform function, forming a new array.

Parameters:

- transform: (T)->R - The mapping function.

Returns:

- [Array](./core_package_structs.md#struct-arrayt)\<R> - A new array consisting of mapped elements.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Increment each element by 1
    let mappedArr = arr.map({value => value + 1})
    
    println("Mapped array (each element + 1): ${mappedArr}")
    
    // Convert integer array to string array
    let strArr = arr.map({value => "Number: ${value}"})
    
    println("String array: ${strArr}")
}
```

Output:

```text
Original array: [1, 2, 3, 4, 5]
Mapped array (each element + 1): [2, 3, 4, 5, 6]
String array: [Number: 1, Number: 2, Number: 3, Number: 4, Number: 5]
```

### func none((T) -> Bool)

```cangjie
public func none(predicate: (T) -> Bool): Bool
```

Function: Determines whether none of the elements in the array satisfy the given condition.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- predicate: (T) -> [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The given condition.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether none of the elements satisfy the condition.

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

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T> - The computation result.

### func repeat(Int64)

```cangjie
public func repeat(n: Int64): Array<T>
```

Function: Repeats the current array a specified number of times to form a new array.

Parameters:

- n: [Int64](core_package_intrinsics.md#int64) - The number of repetitions.

Returns:

- [Array](./core_package_structs.md#struct-arrayt)\<T> - A new array formed by repeating the current array n times.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if n is less than or equal to 0.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3]
    
    println("Original array: ${arr}")
    
    // Repeat the array 3 times
    let repeatedArr = arr.repeat(3)
    
    println("Repeated array (3 times): ${repeatedArr}")
    
    // Repeat a string array
    let strArr = ["Hello", "World"]
    let repeatedStrArr = strArr.repeat(2)
    
    println("Repeated string array (2 times): ${repeatedStrArr}")
}
```

Output:

```text
Original array: [1, 2, 3]
Repeated array (3 times): [1, 2, 3, 1, 2, 3, 1, 2, 3]
Repeated string array (2 times): [Hello, World, Hello, World]
```

### func reverse()

```cangjie
public func reverse(): Unit
```

Function: Reverses the order of elements in the array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Reverse the array
    arr.reverse()
    
    println("Reversed array: ${arr}")
    
    // Reverse a string array
    let strArr = ["Hello", "World", "Cangjie"]
    println("Original string array: ${strArr}")
    
    strArr.reverse()
    
    println("Reversed string array: ${strArr}")
}
```

Output:

```text
Original array: [1, 2, 3, 4, 5]
Reversed array: [5, 4, 3, 2, 1]
Original string array: [Hello, World, Cangjie]
Reversed string array: [Cangjie, World, Hello]
```

### func skip(Int64)

```cangjie
public func skip(count: Int64): Array<T>
```

Function: Skips a specified number of elements and returns a new array.

Throws an exception if count is less than 0. When count equals 0, no elements are skipped, returning a new array with all elements. When count is greater than 0 but less than the array size, skips the first count elements and returns a new array with the remaining elements. When count is greater than or equal to the array size, returns an empty array.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to skip.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - A new array with specified elements skipped.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if count < 0.### func slice(Int64, Int64)

```cangjie
public func slice(start: Int64, len: Int64): Array<T>
```

Function: Obtains an array slice.

> **Note:**
>
> The slice does not copy the array data but references a specific interval of the original data.

Parameters:

- start: [Int64](core_package_intrinsics.md#int64) - The starting position of the slice. The value must be greater than or equal to 0, and start + len must be less than or equal to the length of the current [Array](core_package_structs.md#struct-arrayt) instance.
- len: [Int64](core_package_intrinsics.md#int64) - The length of the slice. The value must be greater than 0.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - Returns the sliced array.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if the parameters do not meet the specified value ranges.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    println("Original array: ${arr}")
    
    // Obtain a slice starting from index 2 with a length of 4
    let slice = arr.slice(2, 4)
    
    println("Slice from index 2, length 4: ${slice}")
    
    // Verify the slice is a reference to the original array
    slice[0] = -1
    println("After modifying slice:")
    println("Original array: ${arr}")
    println("Slice: ${slice}")
}
```

Execution Result:

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

Function: Splits the array at the specified position `mid`.

The resulting two arrays are slices of the original array, with value ranges [0, mid) and [mid, this.size).

Parameters:

- mid: [Int64](core_package_intrinsics.md#int64) - The split position. The value range is [0, this.size].

Returns:

- ([Array](./core_package_structs.md#struct-arrayt)\<T>, [Array](./core_package_structs.md#struct-arrayt)\<T>) - Two slices obtained by splitting the original array.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if `mid` is less than 0 or greater than `this.size`.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Split the array at index 3
    let (left, right) = arr.splitAt(3)
    
    println("Left slice: ${left}")
    println("Right slice: ${right}")
    
    // Verify the slices are references to the original array
    left[0] = -1
    println("After modifying left slice:")
    println("Original array: ${arr}")
    println("Left slice: ${left}")
    println("Right slice: ${right}")
}
```

Execution Result:

```text
Original array: [0, 1, 2, 3, 4, 5]
Left slice: [0, 1, 2]
Right slice: [3, 4, 5]
After modifying left slice:
Original array: [-1, 1, 2, 3, 4, 5]
Left slice: [-1, 1, 2]
Right slice: [3, 4, 5]
```

### func step(Int64)

```cangjie
public func step(count: Int64): Array<T>
```

Function: Extracts elements from the array at specified intervals and returns a new array.

Throws an exception if `count` is less than or equal to 0.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The extraction interval.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - A new array containing elements extracted from the source array at the specified interval.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if `count <= 0`.

### func swap(Int64, Int64)

```cangjie
public func swap(index1: Int64, index2: Int64): Unit
```

Function: Swaps two elements at specified positions.

No swap occurs if `index1` and `index2` point to the same position.

Parameters:

- index1: [Int64](core_package_intrinsics.md#int64) - One of the indices of the elements to swap. The value range is [0, this.size).
- index2: [Int64](core_package_intrinsics.md#int64) - The other index of the elements to swap. The value range is [0, this.size).

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if `index1` or `index2` is less than 0 or greater than or equal to `this.size`.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Swap elements at indices 1 and 3
    arr.swap(1, 3)
    
    println("After swapping indices 1 and 3: ${arr}")
    
    // Swap elements at the same index (no change expected)
    arr.swap(2, 2)
    
    println("After swapping index 2 with itself: ${arr}")
}
```

Execution Result:

```text
Original array: [1, 2, 3, 4, 5]
After swapping indices 1 and 3: [1, 4, 3, 2, 5]
After swapping index 2 with itself: [1, 4, 3, 2, 5]
```

### func take(Int64)

```cangjie
public func take(count: Int64): Array<T>
```

Function: Extracts a specified number of elements from the array and returns a new array.

Throws an exception if `count` is less than 0. If `count` is 0, returns an empty array. If `count` is greater than 0 but less than the source array size, extracts the first `count` elements and returns a new array. If `count` is greater than or equal to the array size, extracts all elements and returns a new array.


> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of elements to extract.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - Returns a new array containing the specified number of elements.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if `count < 0`.

### operator func \[](Int64)

```cangjie
public operator func [](index: Int64): T
```

Function: Retrieves the value at the specified array index.

Throws an exception if `index` is out of bounds. Alternatively, the `get` function can be used to retrieve elements at specified indices, which returns `None` if `index` is out of bounds.

Parameters:

- index: [Int64](core_package_intrinsics.md#int64) - The index of the value to retrieve. The value range is [0, [Int64](core_package_intrinsics.md#int64).Max].

Returns:

- T - The value at the specified index in the array.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if `index` is less than 0 or greater than or equal to the array length.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [10, 20, 30, 40, 50]
    
    println("Array: ${arr}")
    
    // Retrieve the element at index 2
    let element = arr[2]
    
    println("Element at index 2: ${element}")
    
    // Note: Accessing out-of-bounds elements throws IndexOutOfBoundsException
    // Only normal access is demonstrated here
}
```

Execution Result:

```text
Array: [10, 20, 30, 40, 50]
Element at index 2: 30
```

### operator func \[](Int64, T)

```cangjie
public operator func [](index: Int64, value!: T): Unit
```

Function: Modifies the value at the specified array index.

Parameters:

- index: [Int64](core_package_intrinsics.md#int64) - The index of the value to modify. The value range is [0, [Int64](core_package_intrinsics.md#int64).Max].
- value!: T - The target value to set.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if `index` is less than 0 or greater than or equal to the array length.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Modify the element at index 2
    arr[2] = 100
    
    println("Array after setting index 2 to 100: ${arr}")
    
    // Modify the element at index 0
    arr[0] = -1
    
    println("Array after setting index 0 to -1: ${arr}")
}
```

Execution Result:

```text
Original array: [1, 2, 3, 4, 5]
Array after setting index 2 to 100: [1, 2, 100, 4, 5]
Array after setting index 0 to -1: [-1, 2, 100, 4, 5]
```

### operator func \[](Range\<Int64>)

```cangjie
public operator func [](range: Range<Int64>): Array<T>
```

Function: Obtains an array slice based on the specified range.

> **Note:**
>
> 1. If the parameter `range` is constructed using the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor, the following behaviors apply:
>    - The `start` value is the value passed to the constructor itself, unaffected by the `hasStart` value during construction.
>    - If `hasEnd` is `false`, the `end` value is not applied, and the array slice includes elements up to the last element of the original array, regardless of the `isClosed` value during construction.
> 2. The step size of `range` must be 1.

Parameters:

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - The range of the slice. The range must not exceed the array bounds.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The array slice.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if the step size of `range` is not 1.
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if the range is invalid.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    let slice = arr[1..4]
    arr[3] = 10
    println(slice)
}
```

Execution Result:

```text
[1, 2, 10]
```

### operator func \[](Range\<Int64>, Array\<T>)

```cangjie
public operator func [](range: Range<Int64>, value!: Array<T>): Unit
```

Function: Assigns a specified array to a continuous range of elements in this array.

The length of the range must match the size of the target array `value`.

> **Note:**
>
> 1. If the parameter `range` is constructed using the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor, the following behaviors apply:
>    - The `start` value is the value passed to the constructor itself, unaffected by the `hasStart` value during construction.
>    - If `hasEnd` is `false`, the `end` value is not applied, and the array slice includes elements up to the last element of the original array, regardless of the `isClosed` value during construction.
> 2. The step size of `range` must be 1.

Parameters:

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - The range of elements to modify. The range must not exceed the array bounds.
- value!: [Array](core_package_structs.md#struct-arrayt)\<T> - The target values to assign.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if the step size of `range` is not 1 or if the range length does not match the `value` length.
- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if the range is invalid.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [0, 1, 2, 3, 4, 5]
    arr[1..3] = [10, 11]
    println(arr)
}
```

Execution Result:

```text
[0, 10, 11, 3, 4, 5]
```

### extend\<T> Array\<T>

```cangjie
extend<T> Array<T>
```

Function: Extends the [Array](core_package_structs.md#struct-arrayt)\<T> type.

#### func enumerate()

```cangjie
public func enumerate(): Array<(Int64, T)>
```

Function: Retrieves an array with indices.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<([Int64](../../core/core_package_api/core_package_intrinsics.md#int64), T)> - Returns a new array with indices.

#### func zip\<R>(Array\<R>)

```cangjie
public func zip<R>(other: Array<R>): Array<(T, R)>
```

Function: Merges two arrays into a new array (length determined by the shorter array).


> **Note：**
>
> Unsupported platform：OpenHarmony

Parameters:

- other: [Array](core_package_structs.md#struct-arrayt)\<R> - One of the arrays to merge.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<(T, R)> - Returns a new array.### extend\<T> Array\<T> <: Collection\<T>

```cangjie
extend<T> Array<T> <: Collection<T>
```

Function: Implements the [Collection](core_package_interfaces.md#interface-collectiont) interface for the [Array](core_package_structs.md#struct-arrayt)\<T> type.

Parent Types:

- [Collection](core_package_interfaces.md#interface-collectiont)\<T>

#### prop size

```cangjie
public prop size: Int64
```

Function: Gets the number of elements.

Type: [Int64](core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Array: ${arr}")
    println("Size of array: ${arr.size}")
    
    // Create an empty array
    let emptyArr: Array<Int64> = []
    
    println("Empty array: ${emptyArr}")
    println("Size of empty array: ${emptyArr.size}")
    
    // Create an array containing strings
    let strArr = ["Hello", "World", "Cangjie", "Language"]
    
    println("String array: ${strArr}")
    println("Size of string array: ${strArr.size}")
}
```

Output:

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

Function: Determines whether the array is empty.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the array is empty, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Array: ${arr}")
    println("Is array empty? ${arr.isEmpty()}")
    
    // Create an empty array
    let emptyArr: Array<Int64> = []
    
    println("Empty array: ${emptyArr}")
    println("Is empty array empty? ${emptyArr.isEmpty()}")
    
    // Create an array containing strings
    let strArr = ["Hello", "World"]
    
    println("String array: ${strArr}")
    println("Is string array empty? ${strArr.isEmpty()}")
}
```

Output:

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

Function: Gets an iterator for the current array, used to traverse the array.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<T> - An iterator for the current array.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Array: ${arr}")
    
    // Get the iterator for the array
    let iter = arr.iterator()
    
    println("Using iterator to traverse the array:")
    
    // Traverse the array using the iterator
    while (true) {
        match (iter.next()) {
            case Some(value) => println("Element: ${value}")
            case None => break
        }
    }
    
    // Create another array and demonstrate other iterator usages
    let arr2 = ["Hello", "World", "Cangjie"]
    let iter2 = arr2.iterator()
    
    println("\nSecond array: ${arr2}")
    println("Using iterator with for-in loop:")
    
    // Alternatively, use a for-in loop to traverse the iterator
    for (element in iter2) {
        println("Element: ${element}")
    }
}
```

Output:

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

Function: Creates a new [Array](core_package_structs.md#struct-arrayt) instance by copying the current [Array](core_package_structs.md#struct-arrayt) instance.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - A new [Array](core_package_structs.md#struct-arrayt) instance obtained by copying.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    
    println("Original array: ${arr}")
    
    // Use the toArray() method to create a copy of the array
    let copiedArr = arr.toArray()
    
    println("Copied array: ${copiedArr}")
    
    // Verify that the copied array is independent
    copiedArr[0] = 10
    println("After modifying copied array:")
    println("Original array: ${arr}")
    println("Copied array: ${copiedArr}")
    
    // Create an array containing strings and test toArray()
    let strArr = ["Hello", "World", "Cangjie"]
    let copiedStrArr = strArr.toArray()
    
    println("\nString array: ${strArr}")
    println("Copied string array: ${copiedStrArr}")
    
    // Verify that the copied string array is independent
    copiedStrArr[0] = "Hi"
    println("After modifying copied string array:")
    println("Original string array: ${strArr}")
    println("Copied string array: ${copiedStrArr}")
}
```

Output:

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

Function: Extends the [Equatable](core_package_interfaces.md#interface-equatablet)\<[Array](core_package_structs.md#struct-arrayt)\<T>> interface implementation for the [Array](core_package_structs.md#struct-arrayt)\<T> type, supporting equality comparison operations.

Parent Types:

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Array](#struct-arrayt)\<T>>

#### func contains(T)

```cangjie
public func contains(element: T): Bool
```

Function: Checks whether the current array contains the specified element.

Parameters:

- element: T - The target element to search for.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the element exists, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4]
    println(arr.contains(1))
    return 0
}
```

Output:

```text
true
```

#### func indexOf(Array\<T>)

```cangjie
public func indexOf(elements: Array<T>): Option<Int64>
```

Function: Returns the first position where the subarray `elements` appears in the array. If the array does not contain this subarray, returns None.

> **Note:**
>
> When the type of T is [Int64](core_package_intrinsics.md#int64), the variadic parameter syntax sugar version of this function may cause ambiguity with `public func indexOf(element: T, fromIndex: Int64): Option<Int64>`. According to priority, when the number of parameters is 2, `public func indexOf(element: T, fromIndex: Int64): Option<Int64>` will be called first.

Parameters:

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - The target subarray to locate.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The first position where the subarray `elements` appears in the array. If the array does not contain this subarray, returns None.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4]
    let subArr = [2, 3]
    println(arr.indexOf(subArr))
    return 0
}
```

Output:

```text
Some(1)
```

#### func indexOf(Array\<T>, Int64)

```cangjie
public func indexOf(elements: Array<T>, fromIndex: Int64): Option<Int64>
```

Function: Returns the first position where the subarray `elements` appears in the array after `fromIndex`. If not found, returns None.

The function checks the range of `fromIndex`. If `fromIndex` is less than 0, it is treated as 0, and the entire array is searched. If `fromIndex` is greater than or equal to the size of the array, the result is None.

Parameters:

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - The target subarray to locate.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The starting position for the search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The first position where the subarray `elements` appears in the array after `fromIndex`. If not found, returns None.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4, 2, 3]
    let subArr = [2, 3]
    println(arr.indexOf(subArr, 3))
    return 0
}
```

Output:

```text
Some(4)
```

#### func indexOf(T)

```cangjie
public func indexOf(element: T): Option<Int64>
```

Function: Gets the first position where `element` appears in the array. If the array does not contain this element, returns None.

Parameters:

- element: T - The target element to locate.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The first position where `element` appears in the array. If the array does not contain this element, returns None.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5]
    
    println("Array: ${arr}")
    
    // Find the first occurrence of element 2
    let index1 = arr.indexOf(2)
    println("First occurrence of 2: ${index1}")
    
    // Find the first occurrence of element 6 (does not exist)
    let index2 = arr.indexOf(6)
    println("First occurrence of 6: ${index2}")
    
    // Create an array containing strings and test indexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie"]
    
    println("\nString array: ${strArr}")
    
    // Find the first occurrence of the string "Hello"
    let strIndex1 = strArr.indexOf("Hello")
    println("First occurrence of \"Hello\": ${strIndex1}")
}
```

Output:

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

Function: Returns the first position where `element` appears in the array after `fromIndex`. If not found, returns None.

The function will search starting from index `fromIndex`. If `fromIndex` is less than 0, the search will start from position 0. If `fromIndex` is greater than or equal to the size of the array, the result is None.

Parameters:

- element: T - The target element to locate.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The starting position for the search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The first position where `element` appears in the array after `fromIndex`. If not found, returns None.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5]
    
    println("Array: ${arr}")
    
    // Find the first occurrence of element 2 starting from index 2
    let index1 = arr.indexOf(2, 2)
    println("First occurrence of 2 starting from index 2: ${index1}")
    
    // Find the first occurrence of element 2 starting from index 5 (does not exist)
    let index2 = arr.indexOf(2, 5)
    println("First occurrence of 2 starting from index 5: ${index2}")
    
    // Create an array containing strings and test indexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie"]
    
    println("\nString array: ${strArr}")
    
    // Find the first occurrence of the string "Hello" starting from index 1
    let strIndex = strArr.indexOf("Hello", 1)
    println("First occurrence of \"Hello\" starting from index 1: ${strIndex}")
}
```

Output:

```text
Array: [1, 2, 3, 4, 2, 5]
First occurrence of 2 starting from index 2: Some(4)
First occurrence of 2 starting from index 5: None

String array: [Hello, World, Hello, Cangjie]
First occurrence of "Hello" starting from index 1: Some(2)
```

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 4, 2, 3]
    let subArr = [2, 3]
    println(arr.lastIndexOf(subArr, 3))
    return 0
}
```

Output:

```text
Some(4)
```

#### func lastIndexOf(Array\<T>)

```cangjie
public func lastIndexOf(elements: Array<T>): Option<Int64>
```

Function: Returns the last position where the subarray `elements` appears in the array. If the array does not contain this subarray, returns None.

Parameters:

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - The target subarray to locate.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The last position where the subarray `elements` appears in the array. If the array does not contain this subarray, returns None.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 2, 3, 4, 2, 3]
    let subArr = [2, 3]
    
    println("Array: ${arr}")
    println("Sub-array: ${subArr}")
    
    // Find the last occurrence of the subarray [2, 3]
    let lastIndex = arr.lastIndexOf(subArr)
    println("Last occurrence of [2, 3]: ${lastIndex}")
    
    // Find a non-existent subarray
    let notExist = [5, 6]
    let notExistIndex = arr.lastIndexOf(notExist)
    println("Last occurrence of [5, 6]: ${notExistIndex}")
}
```

Output:

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

Function: Searches backward starting from `fromIndex` and returns the last position where the subarray `elements` appears in the array. If the array does not contain this subarray, returns None.

The function checks the range of `fromIndex`. If `fromIndex` is less than 0, the search will start from position 0. If `fromIndex` is greater than or equal to the size of the array, the result is None.

Parameters:

- elements: [Array](core_package_structs.md#struct-arrayt)\<T> - The target subarray to locate.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The starting position for the search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The last position where the subarray `elements` appears in the array when searching backward from `fromIndex`. If the array does not contain this subarray, returns None.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 2, 3, 4, 3, 3]
    let subArr = [2, 3]
    
    println("Array: ${arr}")
    println("Sub-array: ${subArr}")
    
    // Search backward from index 4 to find the last occurrence of sub-array [2, 3]
    let lastIndex = arr.lastIndexOf(subArr, 4)
    println("Last occurrence of [2, 3] starting from index 4: ${lastIndex}")
    
    // Search backward from index 2 to find the last occurrence of sub-array [2, 3]
    let lastIndex2 = arr.lastIndexOf(subArr, 2)
    println("Last occurrence of [2, 3] starting from index 2: ${lastIndex2}")
}
```

Execution Result:

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

Function: Returns the last occurrence position of `element` in the array. Returns None if the element does not exist in the array.

Parameters:

- element: T - The target element to locate.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The last occurrence position of `element` in the array. Returns None if the element does not exist.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5, 2]
    
    println("Array: ${arr}")
    
    // Find the last occurrence position of element 2
    let lastIndex = arr.lastIndexOf(2)
    println("Last occurrence of 2: ${lastIndex}")
    
    // Find the last occurrence position of element 6 (does not exist)
    let notExistIndex = arr.lastIndexOf(6)
    println("Last occurrence of 6: ${notExistIndex}")
    
    // Create a string array and test lastIndexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie", "Hello"]
    
    println("\nString array: ${strArr}")
    
    // Find the last occurrence position of string "Hello"
    let strLastIndex = strArr.lastIndexOf("Hello")
    println("Last occurrence of \"Hello\": ${strLastIndex}")
}
```

Execution Result:

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

Function: Searches backward starting from `fromIndex` and returns the last occurrence position of `element` in the array. Returns None if the element does not exist.

The function checks the range of `fromIndex`. If `fromIndex` is less than 0, it is treated as 0, and the entire array is searched. If `fromIndex` is greater than or equal to the array size, the result is None.

Parameters:

- element: T - The target element to locate.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The starting position for the search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - The last occurrence position of `element` when searching backward from `fromIndex`. Returns None if the element does not exist.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 2, 5, 3]
    
    println("Array: ${arr}")
    
    // Search backward from index 5 to find the last occurrence of element 2
    let lastIndex = arr.lastIndexOf(2, 5)
    println("Last occurrence of 2 starting from index 5: ${lastIndex}")
    
    // Search backward from index 3 to find the last occurrence of element 2
    let lastIndex2 = arr.lastIndexOf(2, 3)
    println("Last occurrence of 2 starting from index 3: ${lastIndex2}")
    
    // Create a string array and test lastIndexOf
    let strArr = ["Hello", "World", "Hello", "Cangjie", "Hello"]
    
    println("\nString array: ${strArr}")
    
    // Search backward from index 2 to find the last occurrence of string "Hello"
    let strLastIndex = strArr.lastIndexOf("Hello", 2)
    println("Last occurrence of \"Hello\" starting from index 2: ${strLastIndex}")
}
```

Execution Result:

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

Function: Removes the prefix.

If the beginning of the current array exactly matches the prefix, the prefix is removed. The return value is a slice of the current array after removing the prefix.

Parameters:

- prefix: [Array](./core_package_structs.md#struct-arrayt)\<T> - The prefix to be removed.

Returns:

- [Array](./core_package_structs.md#struct-arrayt)\<T> - The slice of the original array after removing the prefix.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 1, 2, 3].removePrefix([1, 2])
    println(arr)
    return 0
}
```

Execution Result:

```text
[1, 2, 3]
```

#### func removeSuffix(Array\<T>)

```cangjie
public func removeSuffix(suffix: Array<T>): Array<T>
```

Function: Removes the suffix.

If the end of the current array exactly matches the suffix, the suffix is removed. The return value is a slice of the current array after removing the suffix.

Parameters:

- suffix: [Array](./core_package_structs.md#struct-arrayt)\<T> - The suffix to be removed.

Returns:

- [Array](./core_package_structs.md#struct-arrayt)\<T> - The slice of the original array after removing the suffix.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 3, 2, 3].removeSuffix([2, 3])
    println(arr)
    return 0
}
```

Execution Result:

```text
[1, 2, 3]
```

#### func trimEnd(Array\<T>)

```cangjie
public func trimEnd(set: Array<T>): Array<T>
```

Function: Trims the current array by removing elements from the end that are in the specified set `set`, until the first element not in `set` is encountered, and returns the slice of the current array.

Parameters:

- set: [Array](core_package_structs.md#struct-arrayt)\<T> - The set of elements to be removed.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The trimmed array slice.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [2, 1, 2, 2, 3].trimEnd([2, 3])
    println(arr)
    return 0
}
```

Execution Result:

```text
[2, 1]
```

#### func trimEnd((T)->Bool)

```cangjie
public func trimEnd(predicate: (T)->Bool): Array<T>
```

Function: Trims the current array by removing elements from the end that satisfy the filtering condition, until the first element that does not satisfy the condition is encountered, and returns the slice of the current array.

Parameters:

- predicate: (T)->[Bool](./core_package_intrinsics.md#bool) - The filtering condition.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The trimmed array slice.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 4, 3, 2, 1]
    
    println("Original array: ${arr}")
    
    // Remove all elements less than 4 from the end
    let trimmedArr = arr.trimEnd({x => x < 4})
    println("Array after trimming elements less than 4 from the end: ${trimmedArr}")
    
    // Create a string array and test trimEnd
    let strArr = ["a", "b", "c", "d", "c", "b", "a"]
    
    println("\nString array: ${strArr}")
    
    // Remove all elements not equal to "c" from the end
    let trimmedStrArr = strArr.trimEnd({s => s != "c"})
    println("String array after trimming elements not equal to \"c\" from the end: ${trimmedStrArr}")
}
```

Execution Result:

```text
Original array: [1, 2, 3, 4, 5, 4, 3, 2, 1]
Array after trimming elements less than 4 from the end: [1, 2, 3, 4, 5, 4]

String array: [a, b, c, d, c, b, a]
String array after trimming elements not equal to "c" from the end: [a, b, c, d, c]
```

#### func trimStart(Array\<T>)

```cangjie
public func trimStart(set: Array<T>): Array<T>
```

Function: Trims the current array by removing elements from the start that are in the specified set `set`, until the first element not in `set` is encountered, and returns the slice of the current array.

Parameters:

- set: [Array](core_package_structs.md#struct-arrayt)\<T> - The set of elements to be removed.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The trimmed array slice.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [1, 2, 1, 3, 1].trimStart([1, 2])
    println(arr)
    return 0
}
```

Execution Result:

```text
[3, 1]
```

#### func trimStart((T)->Bool)

```cangjie
public func trimStart(predicate: (T)->Bool): Array<T>
```

Function: Trims the current array by removing elements from the start that satisfy the filtering condition, until the first element that does not satisfy the condition is encountered, and returns the slice of the current array.

Parameters:

- predicate: (T)->[Bool](./core_package_intrinsics.md#bool) - The filtering condition.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<T> - The trimmed array slice.

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5, 4, 3, 2, 1]
    
    println("Original array: ${arr}")
    
    // Remove all elements less than 4 from the start
    let trimmedArr = arr.trimStart({x => x < 4})
    println("Array after trimming elements less than 4 from the start: ${trimmedArr}")
    
    // Create a string array and test trimStart
    let strArr = ["a", "b", "c", "d", "c", "b", "a"]
    
    println("\nString array: ${strArr}")
    
    // Remove all elements not equal to "c" from the start
    let trimmedStrArr = strArr.trimStart({s => s != "c"})
    println("String array after trimming elements not equal to \"c\" from the start: ${trimmedStrArr}")
}
```

Execution Result:

```text
Original array: [1, 2, 3, 4, 5, 4, 3, 2, 1]
Array after trimming elements less than 4 from the start: [4, 5, 4, 3, 2, 1]

String array: [a, b, c, d, c, b, a]
String array after trimming elements not equal to "c" from the start: [c, d, c, b, a]
```

#### operator func !=(Array\<T>)

```cangjie
public operator const func !=(that: Array<T>): Bool
```

Function: Determines whether the current instance is not equal to the specified [Array](core_package_structs.md#struct-arrayt)\<T> instance.

Parameters:

- that: [Array](core_package_structs.md#struct-arrayt)\<T> - Another [Array](core_package_structs.md#struct-arrayt)\<T> instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal; otherwise, returns false.

Example:

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
    
    // Comparing equal arrays
    println("arr1 != arr2: ${arr1 != arr2}")
    
    // Comparing unequal arrays (different elements)
    println("arr1 != arr3: ${arr1 != arr3}")
    
    // Comparing unequal arrays (different lengths)
    println("arr1 != arr4: ${arr1 != arr4}")
    
    // Creating string arrays and testing the != operator
    let strArr1 = ["Hello", "World"]
    let strArr2 = ["Hello", "World"]
    let strArr3 = ["Hello", "Cangjie"]
    
    println("\nString array 1: ${strArr1}")
    println("String array 2: ${strArr2}")
    println("String array 3: ${strArr3}")
    
    // Comparing equal string arrays
    println("strArr1 != strArr2: ${strArr1 != strArr2}")
    
    // Comparing unequal string arrays
    println("strArr1 != strArr3: ${strArr1 != strArr3}")
}
```

Execution result:

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
public operator const func ==(that: Array<T>): Bool
```

Function: Determines whether the current instance is equal to the specified [Array](core_package_structs.md#struct-arrayt)\<T> instance.

Two [Array](core_package_structs.md#struct-arrayt)\<T> instances are considered equal if all their elements are equal.

Parameters:

- that: [Array](core_package_structs.md#struct-arrayt)\<T> - Another [Array](core_package_structs.md#struct-arrayt)\<T> instance to compare with the current instance.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if equal, otherwise false.

Example:

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
    
    // Comparing equal arrays
    println("arr1 == arr2: ${arr1 == arr2}")
    
    // Comparing unequal arrays (different elements)
    println("arr1 == arr3: ${arr1 == arr3}")
    
    // Comparing unequal arrays (different lengths)
    println("arr1 == arr4: ${arr1 == arr4}")
    
    // Creating string arrays and testing the == operator
    let strArr1 = ["Hello", "World"]
    let strArr2 = ["Hello", "World"]
    let strArr3 = ["Hello", "Cangjie"]
    
    println("\nString array 1: ${strArr1}")
    println("String array 2: ${strArr2}")
    println("String array 3: ${strArr3}")
    
    // Comparing equal string arrays
    println("strArr1 == strArr2: ${strArr1 == strArr2}")
    
    // Comparing unequal string arrays
    println("strArr1 == strArr3: ${strArr1 == strArr3}")
}
```

Execution result:

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

Function: Extends the [Array](core_package_structs.md#struct-arrayt)\<T> type with the [ToString](core_package_interfaces.md#interface-tostring) interface, supporting string conversion operations.

Parent Type:

- [ToString](core_package_interfaces.md#interface-tostring)

#### func toString()

```cangjie
public func toString(): String
```

Function: Converts the array to an output-ready string.

The string format resembles "[1, 2, 3, 4, 5]"

Returns:

- [String](core_package_structs.md#struct-string) - The converted string.

Example:

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
    
    // Create a 2D array and test toString()
    let arr4 = [[1, 2], [3, 4], [5, 6]]
    
    println("\n2D array: ${arr4}")
    println("toString() result: ${arr4.toString()}")
}
```

Execution Result:

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

### extend\<T> Array\<Array\<T>>

```cangjie
extend<T> Array<Array<T>>
```

Function: Extends 2D arrays with methods to flatten them into 1D arrays.

#### func flatten()

```cangjie
public func flatten(): Array<T>
```

Function: Flattens the current 2D array into a 1D array.

For example, converts [[1, 2], [3, 4]] to [1, 2, 3, 4].

Returns:

- [Array](./core_package_structs.md#struct-arrayt)\<T> - The flattened 1D array.

Example:

<!-- verify -->
```cangjie
main(): Int64 {
    let arr = [[1, 2], [3, 4]].flatten()
    println(arr)
    return 0
}
```

Execution Result:

```text
[1, 2, 3, 4]
```

## struct CPointerHandle\<T> where T <: CType

```cangjie
public struct CPointerHandle<T> where T <: CType {
    public let array: Array<T>
    public let pointer: CPointer<T>
    public init()
    public init(ptr: CPointer<T>, arr: Array<T>)
}
```

Function: Represents the raw pointer of an [Array](core_package_structs.md#struct-arrayt), where the generic parameter must satisfy the [CType](core_package_interfaces.md#interface-ctype) constraint.

### let array

```cangjie
public let array: Array<T>
```

Function: The [Array](core_package_structs.md#struct-arrayt) instance corresponding to the raw pointer.

Type: [Array](core_package_structs.md#struct-arrayt)\<T>

Example:

<!-- verify -->
```cangjie
main() {
    let arr = [1, 2, 3, 4, 5]
    // Obtain a CPointerHandle instance via acquireArrayRawData
    let handle = unsafe { acquireArrayRawData(arr) }
    
    // Get the array itself
    let arrItself = handle.array
    // Modify one element and verify if it's the same array
    arrItself[0] = 2

    // Check the value
    println("The value is ${arrItself}, confirming it's the original array")
}
```

Execution Result:

```text
The value is [2, 2, 3, 4, 5], confirming it's the original array
```

### let pointer

```cangjie
public let pointer: CPointer<T>
```

Function: Gets the raw pointer corresponding to the specified [Array](core_package_structs.md#struct-arrayt).

Type: [CPointer](core_package_intrinsics.md#cpointert)\<T>

Example:

<!-- verify -->
```cangjie
main() {
    let arr: Array<Int64> = [1, 2, 3, 4]
    // Get CPointerHandle
    let cptrHandle: CPointerHandle<Int64> = unsafe { acquireArrayRawData(arr) }
    // Get the pointer
    let cptr: CPointer<Int64> = cptrHandle.pointer

    // Read the value at the pointer's index, here getting the third element's value
    let num: Int64 = unsafe { cptr.read(2) }
    println("The third element of the array is ${num} ")

    // Release CPointerHandle
    unsafe { releaseArrayRawData<Int64>(cptrHandle) }
}
```

Execution Result:

```text
The third element of the array is 3
```

### init() <sup>(deprecated)</sup>

```cangjie
public init()
```

Function: Constructs a default [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype) instance with a null raw pointer and an empty Cangjie array.

> **Note:**
>
> This constructor will be deprecated in future versions. Use the [acquireArrayRawData](./core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype) function to create CPointerHandle instances instead.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a default CPointerHandle instance
    // Note: This constructor is marked as deprecated and will be removed in future versions
    let handle = CPointerHandle<Int64>()
    
    println("Created a default CPointerHandle instance")
    println("The raw pointer is null and the Cangjie array is empty")
    
    // In practice, use acquireArrayRawData to create CPointerHandle instances
}
```

Execution Result:

```text
Created a default CPointerHandle instance
The raw pointer is null and the Cangjie array is empty
```

### init(CPointer\<T>, Array\<T>) <sup>(deprecated)</sup>

```cangjie
public init(ptr: CPointer<T>, arr: Array<T>)
```

Function: Initializes a [CPointerHandle](core_package_structs.md#struct-cpointerhandlet-where-t--ctype) with the provided [CPointer](core_package_intrinsics.md#cpointert) and [Array](core_package_structs.md#struct-arrayt).

Parameters:

- ptr: [CPointer](core_package_intrinsics.md#cpointert)\<T> - The array's raw pointer.
- arr: [Array](core_package_structs.md#struct-arrayt)\<T> - The corresponding Cangjie array.

> **Note:**
>
> This constructor will be deprecated in future versions. Use the [acquireArrayRawData](./core_package_funcs.md#func-acquirearrayrawdatatarrayt-where-t--ctype) function to create CPointerHandle instances instead.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an integer array
    let arr = [1, 2, 3, 4, 5]

    // Create a pointer
    let sizeofInt64: UIntNative = 8
    var p1 = unsafe { malloc(sizeofInt64) }
    var ptr = unsafe { CPointer<Int64>(p1) }
    
    // Initialize a CPointerHandle instance with the pointer and array
    // Note: This constructor is marked as deprecated and will be removed in future versions
    // In practice, use acquireArrayRawData to create CPointerHandle instances
    let handle = CPointerHandle(ptr, arr)
    
    // Get the original array via handle
    let arr1 = handle.array

    // Free the pointer
    unsafe { free(p1) }
    println(arr1)
}

foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit
```

Execution Result:

```text
[1, 2, 3, 4, 5]
```

## struct CPointerResource\<T> where T <: CType

```cangjie
public struct CPointerResource<T> <: Resource where T <: CType {
    public let value: CPointer<T>
}
```

Function: This struct represents the resource management type for [CPointer](core_package_intrinsics.md#cpointert). Its instances can be obtained via the `asResource` member function of [CPointer](core_package_intrinsics.md#cpointert).

Parent Type:

- [Resource](core_package_interfaces.md#interface-resource)

### let value

```cangjie
public let value: CPointer<T>
```

Function: The [CPointer](core_package_intrinsics.md#cpointert)\<T> instance managed by this resource.

Type: [CPointer](core_package_intrinsics.md#cpointert)\<T>

Example:

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

Execution Result:

```text
10
true
```

### func close()

```cangjie
public func close(): Unit
```

Function: Releases the content pointed to by the managed [CPointer](core_package_intrinsics.md#cpointert)\<T> instance.

Example:

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

Execution Result:

```text
10
true
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Checks whether the pointer's content has been released.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if released.

Example:

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

Execution Result:

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

Function: This struct represents the resource management type for [CString](core_package_intrinsics.md#cstring). Its instances can be obtained through the member function `asResource` of [CString](core_package_intrinsics.md#cstring).

Parent Types:

- [Resource](core_package_interfaces.md#interface-resource)

### let value

```cangjie
public let value: CString
```

Function: Represents the [CString](core_package_intrinsics.md#cstring) resource managed by the current instance.

Type: [CString](core_package_intrinsics.md#cstring)

Example:

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    // ctr is automatically released when the try block ends
    try (r = ctrResource) {
        var str = r.value.toString()
        println(str)
    }
    println(ctrResource.isClosed())
}
```

Output:

```text
Hello
true
```

### func close()

```cangjie
public func close(): Unit
```

Function: Releases the content pointed to by the [CString](core_package_intrinsics.md#cstring) instance managed by the current instance.

Example:

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    var str = ctrResource.value.toString()
    println(str)
    ctrResource.close()
    println(ctrResource.isClosed())
}
```

Output:

```text
Hello
true
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Determines whether the string has been released.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if released.

Example:

<!-- verify -->
```cangjie
main() {
    var ctr = unsafe { LibC.mallocCString("Hello") }
    var ctrResource: CStringResource = ctr.asResource()
    // ctr is automatically released when the try block ends
    try (r = ctrResource) {
        var str = r.value.toString()
        println(str)
    }
    println(ctrResource.isClosed())
}
```

Output:

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

Function: This struct provides a default hash algorithm implementation.

It can use a series of write functions to input instances of different data types and compute their combined hash value.

Parent Types:

- [Hasher](core_package_interfaces.md#interface-hasher)

### init(Int64)

```cangjie
public init(res!: Int64 = 0)
```

Function: Constructor, creates a [DefaultHasher](core_package_structs.md#struct-defaulthasher).

Parameters:

- res!: [Int64](core_package_intrinsics.md#int64) - Initial hash value, defaults to 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance with default initial value 0
    var hasher1 = DefaultHasher()
    println("Created DefaultHasher with default initial value: 0")
    
    // Create a DefaultHasher instance with custom initial value
    var hasher2 = DefaultHasher(res: 12345)
    println("Created DefaultHasher with custom initial value: 12345")
    
    // Perform operations with hasher
    hasher1.write(42)
    hasher2.write(42)
    
    let result1 = hasher1.finish()
    let result2 = hasher2.finish()
    
    println("Hash result 1: ${result1}")
    println("Hash result 2: ${result2}")
}
```

Output:

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

Function: Obtains the result of the hash operation.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The result of the hash operation.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write some data
    hasher.write(42)
    hasher.write("Hello")
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result: ${result}")
}
```

Output:

```text
Hash result: -2412057441983859926
```

### func reset()

```cangjie
public mut func reset(): Unit
```

Function: Resets the hash value to 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write some data and get the hash result
    hasher.write(42)
    let result1 = hasher.finish()
    println("Hash result 1: ${result1}")
    
    // Reset the hasher
    hasher.reset()
    
    // Write the same data again and get the hash result
    hasher.write(42)
    let result2 = hasher.finish()
    println("Hash result 2 (after reset): ${result2}")
}
```

Output:

```text
Hash result 1: -7046029254386353089
Hash result 2 (after reset): -7046029254386353089
```

### func write(Bool)

```cangjie
public mut func write(value: Bool): Unit
```

Function: Passes the [Bool](core_package_intrinsics.md#bool) value to be hashed through this function, then performs combined hash operations.

Parameters:

- value: [Bool](core_package_intrinsics.md#bool) - The value to be hashed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write boolean values
    hasher.write(true)
    hasher.write(false)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for boolean values: ${result}")
}
```

Output:

```text
Hash result for boolean values: -8244754741327405940
```

### func write(Float16)

```cangjie
public mut func write(value: Float16): Unit
```

Function: Passes the [Float16](core_package_intrinsics.md#float16) value to be hashed through this function, then performs combined hash operations.

Parameters:

- value: [Float16](core_package_intrinsics.md#float16) - The value to be hashed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write Float16 value
    let f16Value: Float16 = 3.14
    hasher.write(f16Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Float16 value: ${result}")
}
```

Output:

```text
Hash result for Float16 value: -1791342501213198195
```

### func write(Float32)

```cangjie
public mut func write(value: Float32): Unit
```

Function: Passes the [Float32](core_package_intrinsics.md#float32) value to be hashed through this function, then performs combined hash operations.

Parameters:

- value: [Float32](core_package_intrinsics.md#float32) - The value to be hashed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write Float32 value
    let f32Value: Float32 = 3.14159
    hasher.write(f32Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Float32 value: ${result}")
}
```

Output:

```text
Hash result for Float32 value: 7713830965842221811
```

### func write(Float64)

```cangjie
public mut func write(value: Float64): Unit
```

Function: Passes the [Float64](core_package_intrinsics.md#float64) value to be hashed through this function, then performs combined hash operations.

Parameters:

- value: [Float64](core_package_intrinsics.md#float64) - The value to be hashed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write Float64 value
    let f64Value: Float64 = 3.141592653589793
    hasher.write(f64Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Float64 value: ${result}")
}
```

Output:

```text
Hash result for Float64 value: 6866262051846751989
```

### func write(Int16)

```cangjie
public mut func write(value: Int16): Unit
```

Function: Passes the [Int16](core_package_intrinsics.md#int16) value to be hashed through this function, then performs combined hash operations.

Parameters:

- value: [Int16](core_package_intrinsics.md#int16) - The value to be hashed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write Int16 value
    let i16Value: Int16 = 1234
    hasher.write(i16Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Int16 value: ${result}")
}
```

Output:

```text
Hash result for Int16 value: -7046029254386351897
```

### func write(Int32)

```cangjie
public mut func write(value: Int32): Unit
```

Function: Passes the [Int32](core_package_intrinsics.md#int32) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [Int32](core_package_intrinsics.md#int32) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write an Int32 value
    let i32Value: Int32 = 123456
    hasher.write(i32Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Int32 value: ${result}")
}
```

Execution Result:

```text
Hash result for Int32 value: -7046029254386229675
```

### func write(Int64)

```cangjie
public mut func write(value: Int64): Unit
```

Function: Passes the [Int64](core_package_intrinsics.md#int64) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [Int64](core_package_intrinsics.md#int64) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write an Int64 value
    let i64Value: Int64 = 123456789
    hasher.write(i64Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Int64 value: ${result}")
}
```

Execution Result:

```text
Hash result for Int64 value: -7046029254262896342
```

### func write(Int8)

```cangjie
public mut func write(value: Int8): Unit
```

Function: Passes the [Int8](core_package_intrinsics.md#int8) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [Int8](core_package_intrinsics.md#int8) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write an Int8 value
    let i8Value: Int8 = 123
    hasher.write(i8Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Int8 value: ${result}")
}
```

Execution Result:

```text
Hash result for Int8 value: -7046029254386353008
```

### func write(Rune)

```cangjie
public mut func write(value: Rune): Unit
```

Function: Passes the [Rune](core_package_intrinsics.md#rune) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [Rune](core_package_intrinsics.md#rune) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a Rune value
    let runeValue: Rune = 'A'
    hasher.write(runeValue)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for Rune value: ${result}")
}
```

Execution Result:

```text
Hash result for Rune value: -7046029254386353066
```

### func write(String)

```cangjie
public mut func write(value: String): Unit
```

Function: Passes the [String](core_package_structs.md#struct-string) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [String](core_package_structs.md#struct-string) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a string value
    hasher.write("Hello, World!")
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for string value: ${result}")
}
```

Execution Result:

```text
Hash result for string value: 6543264553144952043
```

### func write(UInt16)

```cangjie
public mut func write(value: UInt16): Unit
```

Function: Passes the [UInt16](core_package_intrinsics.md#uint16) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [UInt16](core_package_intrinsics.md#uint16) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a UInt16 value
    let u16Value: UInt16 = 1234
    hasher.write(u16Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for UInt16 value: ${result}")
}
```

Execution Result:

```text
Hash result for UInt16 value: -7046029254386351897
```

### func write(UInt32)

```cangjie
public mut func write(value: UInt32): Unit
```

Function: Passes the [UInt32](core_package_intrinsics.md#uint32) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [UInt32](core_package_intrinsics.md#uint32) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a UInt32 value
    let u32Value: UInt32 = 123456
    hasher.write(u32Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for UInt32 value: ${result}")
}
```

Execution Result:

```text
Hash result for UInt32 value: -7046029254386229675
```

### func write(UInt64)

```cangjie
public mut func write(value: UInt64): Unit
```

Function: Passes the [UInt64](core_package_intrinsics.md#uint64) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [UInt64](core_package_intrinsics.md#uint64) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a UInt64 value
    let u64Value: UInt64 = 123456789
    hasher.write(u64Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for UInt64 value: ${result}")
}
```

Execution Result:

```text
Hash result for UInt64 value: -7046029254262896342
```

### func write(UInt8)

```cangjie
public mut func write(value: UInt8): Unit
```

Function: Passes the [UInt8](core_package_intrinsics.md#uint8) value to be hashed through this function, then performs hash combination operations.

Parameters:

- value: [UInt8](core_package_intrinsics.md#uint8) - The value to be processed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a DefaultHasher instance
    var hasher = DefaultHasher()
    
    // Write a UInt8 value
    let u8Value: UInt8 = 123
    hasher.write(u8Value)
    
    // Get the hash result
    let result = hasher.finish()
    println("Hash result for UInt8 value: ${result}")
}
```

Execution Result:

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

Function: [Duration](core_package_structs.md#struct-duration) represents a time interval, providing common static instances and functionalities for calculation and comparison.

> **Note:**
>
> - [Duration](core_package_structs.md#struct-duration) ranges from [Duration](core_package_structs.md#struct-duration).Min to [Duration](core_package_structs.md#struct-duration).Max, represented numerically as [-2<sup>63</sup>, 2<sup>63</sup>) (in seconds), with nanosecond precision.
> - Each time unit in [Duration](core_package_structs.md#struct-duration) is represented as an integer. If the actual value is not an integer, it is rounded toward the smaller absolute value. For example, when calling the `toHours` method on a [Duration](core_package_structs.md#struct-duration) instance representing `1 hour 30 minutes 46 seconds`, it will return 1 instead of 1.5 or 2.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)
- [Hashable](core_package_interfaces.md#interface-hashable)
- [Comparable](core_package_interfaces.md#interface-comparablet)\<[Duration](#struct-duration)>

### static const Max

```cangjie
public static const Max: Duration = Duration(0x7FFF_FFFF_FFFF_FFFF, 999999999)
```

Function: Represents the maximum time interval as a [Duration](core_package_structs.md#struct-duration) instance.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Use the Duration.Max static constant
    let maxDuration = Duration.Max
    println("Maximum duration: ${maxDuration}")
}
```

Execution Result:

```text
Maximum duration: 106751991167300d15h30m7s999ms999us999ns
```

### static const Min

```cangjie
public static const Min: Duration = Duration(-0x8000_0000_0000_0000, 0)
```

Function: Represents the minimum time interval as a [Duration](core_package_structs.md#struct-duration) instance.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Use the Duration.Min static constant
    let minDuration = Duration.Min
    println("Minimum duration: ${minDuration}")
}
```

Execution Result:

```text
Minimum duration: -106751991167300d15h30m8s
```

### static const Zero

```cangjie
public static const Zero: Duration = Duration(0, 0)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 0-nanosecond time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.Zero static constant
    let zeroDuration = Duration.Zero
    println("Zero duration: ${zeroDuration}")
}
```

Output:

```text
Zero duration: 0s
```

### static const day

```cangjie
public static const day: Duration = Duration(24 * 60 * 60, 0)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-day time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.day static constant
    let oneDay = Duration.day
    println("One day duration: ${oneDay}")
    
    // Performing calculations with a 1-day duration
    let twoDays = oneDay + oneDay
    println("Two days duration: ${twoDays}")
}
```

Output:

```text
One day duration: 1d
Two days duration: 2d
```

### static const hour

```cangjie
public static const hour: Duration = Duration(60 * 60, 0)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-hour time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.hour static constant
    let oneHour = Duration.hour
    println("One hour duration: ${oneHour}")
    
    // Calculating how many hours are in a day
    let hoursInDay = Duration.day / oneHour
    println("Hours in a day: ${hoursInDay}")
}
```

Output:

```text
One hour duration: 1h
Hours in a day: 24.000000
```

### static const microsecond

```cangjie
public static const microsecond: Duration = Duration(0, 1000u32)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-microsecond time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.microsecond static constant
    let oneMicrosecond = Duration.microsecond
    println("One microsecond duration: ${oneMicrosecond}")
    
    // Calculating how many microseconds are in a millisecond
    let microsecondsInMillisecond = Duration.millisecond / oneMicrosecond
    println("Microseconds in a millisecond: ${microsecondsInMillisecond}")
}
```

Output:

```text
One microsecond duration: 1us
Microseconds in a millisecond: 1000.000000
```

### static const millisecond

```cangjie
public static const millisecond: Duration = Duration(0, 1000000u32)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-millisecond time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.millisecond static constant
    let oneMillisecond = Duration.millisecond
    println("One millisecond duration: ${oneMillisecond}")
    
    // Calculating how many milliseconds are in a second
    let millisecondsInSecond = Duration.second / oneMillisecond
    println("Milliseconds in a second: ${millisecondsInSecond}")
}
```

Output:

```text
One millisecond duration: 1ms
Milliseconds in a second: 1000.000000
```

### static const minute

```cangjie
public static const minute: Duration = Duration(60, 0)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-minute time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.minute static constant
    let oneMinute = Duration.minute
    println("One minute duration: ${oneMinute}")
    
    // Calculating how many minutes are in an hour
    let minutesInHour = Duration.hour / oneMinute
    println("Minutes in an hour: ${minutesInHour}")
}
```

Output:

```text
One minute duration: 1m
Minutes in an hour: 60.000000
```

### static const nanosecond

```cangjie
public static const nanosecond: Duration = Duration(0, 1)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-nanosecond time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.nanosecond static constant
    let oneNanosecond = Duration.nanosecond
    println("One nanosecond duration: ${oneNanosecond}")
    
    // Calculating how many nanoseconds are in a microsecond
    let nanosecondsInMicrosecond = Duration.microsecond / oneNanosecond
    println("Nanoseconds in a microsecond: ${nanosecondsInMicrosecond}")
}
```

Output:

```text
One nanosecond duration: 1ns
Nanoseconds in a microsecond: 1000.000000
```

### static const second

```cangjie
public static const second: Duration = Duration(1, 0)
```

Function: Represents a [Duration](core_package_structs.md#struct-duration) instance with a 1-second time interval.

Type: [Duration](core_package_structs.md#struct-duration)

Example:

<!-- verify -->
```cangjie
main() {
    // Using the Duration.second static constant
    let oneSecond = Duration.second
    println("One second duration: ${oneSecond}")
    
    // Calculating how many seconds are in a minute
    let secondsInMinute = Duration.minute / oneSecond
    println("Seconds in a minute: ${secondsInMinute}")
}
```

Output:

```text
One second duration: 1s
Seconds in a minute: 60.000000
```

### func abs()

```cangjie
public func abs(): Duration
```

Function: Returns a new [Duration](core_package_structs.md#struct-duration) instance whose value is the absolute value of the current [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The result of taking the absolute value of the current [Duration](core_package_structs.md#struct-duration) instance.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown if the current [Duration](core_package_structs.md#struct-duration) instance equals [Duration](core_package_structs.md#struct-duration).Min, as taking the absolute value would exceed the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Creating a duration using Duration.second
    let tenSeconds = Duration.second * 10
    println("Ten seconds duration: ${tenSeconds}")
    
    // Creating a negative duration (via subtraction)
    let zeroDuration = Duration.Zero
    let negativeDuration = zeroDuration - tenSeconds
    println("Negative duration: ${negativeDuration}")
    
    // Using abs() to get the absolute value
    let absoluteDuration = negativeDuration.abs()
    println("Absolute duration: ${absoluteDuration}")
}
```

Output:

```text
Ten seconds duration: 10s
Negative duration: -10s
Absolute duration: 10s
```

### func compare(Duration)

```cangjie
public func compare(rhs: Duration): Ordering
```

Function: Compares the current [Duration](core_package_structs.md#struct-duration) instance with another [Duration](core_package_structs.md#struct-duration) instance. Returns [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).GT if greater, [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).EQ if equal, or [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering).LT if less.

Parameters:

- rhs: [Duration](core_package_structs.md#struct-duration) - The [Duration](core_package_structs.md#struct-duration) instance to compare with.

Returns:

- [Ordering](../../core/core_package_api/core_package_enums.md#enum-ordering) - The comparison result between the current [Duration](core_package_structs.md#struct-duration) instance and `rhs`.

Example:

<!-- verify -->
```cangjie
main() {
    // Creating two different durations
    let duration1 = Duration.second * 5  // 5 seconds
    let duration2 = Duration.second * 10  // 10 seconds
    
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Using compare() to compare the two durations
    let comparison = duration1.compare(duration2)
    println("Comparison result: ${comparison}")
    
    // Checking different comparison results
    if (comparison == Ordering.LT) {
        println("Duration 1 is less than Duration 2")
    } else if (comparison == Ordering.EQ) {
        println("Duration 1 is equal to Duration 2")
    } else if (comparison == Ordering.GT) {
        println("Duration 1 is greater than Duration 2")
    }
}
```

Output:

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

Function: Gets the hash value of the current [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The hash value of the current [Duration](core_package_structs.md#struct-duration) instance.

Example:

<!-- verify -->
```cangjie
main() {
    // Creating a duration
    let duration = Duration.second * 30  // 30 seconds
    println("Duration: ${duration}")
    
    // Using hashCode() to get the hash value
    let hash = duration.hashCode()
    println("Hash code: ${hash}")
    
    // Creating another identical duration
    let sameDuration = Duration.second * 30  // 30 seconds
    let sameHash = sameDuration.hashCode()
    println("Same duration hash code: ${sameHash}")
    
    // Verifying that identical durations have the same hash code
    if (hash == sameHash) {
        println("Same durations have the same hash code")
    }
    
    // Creating a different duration
    let differentDuration = Duration.minute * 1  // 1 minute
    let differentHash = differentDuration.hashCode()
    println("Different duration: ${differentDuration}")
    println("Different duration hash code: ${differentHash}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in days.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in days.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (3 days and 5 hours)
    let duration = Duration.day * 3 + Duration.hour * 5
    println("Duration: ${duration}")
    
    // Use toDays() to get the number of days
    let days = duration.toDays()
    println("Days: ${days}")
    
    // Create a smaller duration (5 hours)
    let smallDuration = Duration.hour * 5
    println("Small duration: ${smallDuration}")
    let smallDays = smallDuration.toDays()
    println("Days in small duration: ${smallDays}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in hours.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in hours.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (2 days and 3 hours)
    let duration = Duration.day * 2 + Duration.hour * 3
    println("Duration: ${duration}")
    
    // Use toHours() to get the number of hours
    let hours = duration.toHours()
    println("Hours: ${hours}")
    
    // Create a smaller duration (30 minutes)
    let smallDuration = Duration.minute * 30
    println("Small duration: ${smallDuration}")
    let smallHours = smallDuration.toHours()
    println("Hours in small duration: ${smallHours}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in microseconds.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in microseconds.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the size of the [Duration](core_package_structs.md#struct-duration) instance in microseconds exceeds the range of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (5 seconds)
    let duration = Duration.second * 5
    println("Duration: ${duration}")
    
    // Use toMicroseconds() to get the number of microseconds
    let microseconds = duration.toMicroseconds()
    println("Microseconds: ${microseconds}")
    
    // Create a smaller duration (500 milliseconds)
    let smallDuration = Duration.millisecond * 500
    println("Small duration: ${smallDuration}")
    let smallMicroseconds = smallDuration.toMicroseconds()
    println("Microseconds in small duration: ${smallMicroseconds}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in milliseconds.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in milliseconds.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the size of the [Duration](core_package_structs.md#struct-duration) instance in milliseconds exceeds the range of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (3 seconds)
    let duration = Duration.second * 3
    println("Duration: ${duration}")
    
    // Use toMilliseconds() to get the number of milliseconds
    let milliseconds = duration.toMilliseconds()
    println("Milliseconds: ${milliseconds}")
    
    // Create a smaller duration (500000 microseconds)
    let smallDuration = Duration.microsecond * 500000
    println("Small duration: ${smallDuration}")
    let smallMilliseconds = smallDuration.toMilliseconds()
    println("Milliseconds in small duration: ${smallMilliseconds}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in minutes.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in minutes.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (2 hours)
    let duration = Duration.hour * 2
    println("Duration: ${duration}")
    
    // Use toMinutes() to get the number of minutes
    let minutes = duration.toMinutes()
    println("Minutes: ${minutes}")
    
    // Create a smaller duration (30 seconds)
    let smallDuration = Duration.second * 30
    println("Small duration: ${smallDuration}")
    let smallMinutes = smallDuration.toMinutes()
    println("Minutes in small duration: ${smallMinutes}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in nanoseconds, rounded toward zero.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in nanoseconds.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the size of the [Duration](core_package_structs.md#struct-duration) instance in nanoseconds exceeds the range of [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (2 seconds)
    let duration = Duration.second * 2
    println("Duration: ${duration}")
    
    // Use toNanoseconds() to get the number of nanoseconds
    let nanoseconds = duration.toNanoseconds()
    println("Nanoseconds: ${nanoseconds}")
    
    // Create a smaller duration (500 microseconds)
    let smallDuration = Duration.microsecond * 500
    println("Small duration: ${smallDuration}")
    let smallNanoseconds = smallDuration.toNanoseconds()
    println("Nanoseconds in small duration: ${smallNanoseconds}")
}
```

Output:

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

Function: Gets the integer value of the current [Duration](core_package_structs.md#struct-duration) instance in seconds.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the current [Duration](core_package_structs.md#struct-duration) instance in seconds.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration (3 minutes)
    let duration = Duration.minute * 3
    println("Duration: ${duration}")
    
    // Use toSeconds() to get the number of seconds
    let seconds = duration.toSeconds()
    println("Seconds: ${seconds}")
    
    // Create a smaller duration (500 milliseconds)
    let smallDuration = Duration.millisecond * 500
    println("Small duration: ${smallDuration}")
    let smallSeconds = smallDuration.toSeconds()
    println("Seconds in small duration: ${smallSeconds}")
}
```

Output:

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

Function: Gets the string representation of the current [Duration](core_package_structs.md#struct-duration) instance, formatted as "1d2h3m4s5ms6us7ns", representing "1 day 2 hours 3 minutes 4 seconds 5 milliseconds 6 microseconds 7 nanoseconds". Units with a value of 0 are omitted. Specifically, if all units are 0, returns "0s".

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation of the current [Duration](core_package_structs.md#struct-duration) instance.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a complex duration
    let duration = Duration.day * 2 + Duration.hour * 3 + Duration.minute * 30 + 
                   Duration.second * 45 + Duration.millisecond * 123 + 
                   Duration.microsecond * 456 + Duration.nanosecond * 789
    println("Duration: ${duration}")
    
    // Use toString() to get the string representation
    let durationString = duration.toString()
    println("String representation: ${durationString}")
    
    // Create a simple duration
    let simpleDuration = Duration.hour * 2
    println("Simple duration: ${simpleDuration}")
    let simpleString = simpleDuration.toString()
    println("Simple string representation: ${simpleString}")
}
```

Output:

```text
Duration: 2d3h30m45s123ms456us789ns
String representation: 2d3h30m45s123ms456us789ns
Simple duration: 2h
Simple string representation: 2h
```

### operator func !=(Duration)

```cangjie
public operator func !=(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is not equal to `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is not equal to `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two identical durations
    let duration1 = Duration.second * 30
    let duration2 = Duration.second * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Use != operator to compare the two durations
    if (duration1 != duration2) {
        println("Duration 1 is not equal to Duration 2")
    } else {
        println("Duration 1 is equal to Duration 2")
    }
    
    // Create two different durations
    let duration3 = Duration.minute * 1
    println("Duration 3: ${duration3}")
    
    // Use != operator to compare different durations
    if (duration1 != duration3) {
        println("Duration 1 is not equal to Duration 3")
    } else {
        println("Duration 1 is equal to Duration 3")
    }
}
```

Output:

```text
Duration 1: 30s
Duration 2: 30s
Duration 1 is equal to Duration 2
Duration 3: 1m
Duration 1 is not equal to Duration 3
```

### operator func *(Float64)

```cangjie
public operator func *(r: Float64): Duration
```

Function: Implements multiplication between [Duration](core_package_structs.md#struct-duration) type and [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type, i.e., [Duration](core_package_structs.md#struct-duration) * [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) operation.

Parameters:

- r: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The right operand of multiplication.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The product of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the multiplication result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration
    let duration = Duration.second * 10
    println("Original duration: ${duration}")
    
    // Multiply with Float64 using * operator
    let multipliedDuration = duration * 2.5
    println("Multiplied duration: ${multipliedDuration}")
    
    // Multiply with Float64 (value less than 1)
    let dividedDuration = duration * 0.5
    println("Divided duration: ${dividedDuration}")
}
```

Output:

```text
Original duration: 10s
Multiplied duration: 25s
Divided duration: 5s
```

### operator func *(Int64)

```cangjie
public operator func *(r: Int64): Duration
```

Function: Implements multiplication between [Duration](core_package_structs.md#struct-duration) type and [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type, i.e., [Duration](core_package_structs.md#struct-duration) * [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) operation.

Parameters:

- r: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The right operand of multiplication.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The product of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the multiplication result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration
    let duration = Duration.minute * 5
    println("Original duration: ${duration}")
    
    // Multiply with Int64 using * operator
    let multipliedDuration = duration * 3
    println("Multiplied duration: ${multipliedDuration}")
    
    // Multiply with Int64
    let dividedDuration = duration * 2
    println("Multiplied duration (2): ${dividedDuration}")
}
```

Output:

```text
Original duration: 5m
Multiplied duration: 15m
Multiplied duration (2): 10m
```

### operator func +(Duration)

```cangjie
public operator func +(r: Duration): Duration
```

Function: Implements addition between [Duration](core_package_structs.md#struct-duration) types, i.e., [Duration](core_package_structs.md#struct-duration) + [Duration](core_package_structs.md#struct-duration) operation.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - The right operand of addition.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The sum of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the addition result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Add two durations using + operator
    let sumDuration = duration1 + duration2
    println("Sum duration: ${sumDuration}")
    
    // Create more durations and add them
    let duration3 = Duration.second * 45
    println("Duration 3: ${duration3}")
    let totalDuration = duration1 + duration2 + duration3
    println("Total duration: ${totalDuration}")
}
```

Output:

```text
Duration 1: 2h
Duration 2: 30m
Sum duration: 2h30m
Duration 3: 45s
Total duration: 2h30m45s
```

### operator func -(Duration)

```cangjie
public operator func -(r: Duration): Duration
```

Function: Implements subtraction between [Duration](core_package_structs.md#struct-duration) types, i.e., [Duration](core_package_structs.md#struct-duration) - [Duration](core_package_structs.md#struct-duration) operation.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - The right operand of subtraction.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The difference between the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the subtraction result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.hour * 3
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Subtract two durations using - operator
    let diffDuration = duration1 - duration2
    println("Difference duration: ${diffDuration}")
    
    // Create more durations and perform subtraction
    let duration3 = Duration.second * 45
    println("Duration 3: ${duration3}")
    let resultDuration = duration1 - duration2 - duration3
    println("Result duration: ${resultDuration}")
}
```

Output:

```text
Duration 1: 3h
Duration 2: 30m
Difference duration: 2h30m
Duration 3: 45s
Result duration: 2h29m15s
```

### operator func /(Duration)

```cangjie
public operator func /(r: Duration): Float64
```

Function: Implements division between [Duration](core_package_structs.md#struct-duration) types, i.e., [Duration](core_package_structs.md#struct-duration) / [Duration](core_package_structs.md#struct-duration) operation.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - The divisor.

Returns:

- [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The quotient of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `r` equals [Duration](core_package_structs.md#struct-duration).Zero.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Divide two durations using / operator
    let quotient = duration1 / duration2
    println("Quotient: ${quotient}")
    
    // Create more durations and perform division
    let duration3 = Duration.second * 45
    let duration4 = Duration.second * 15
    println("Duration 3: ${duration3}")
    println("Duration 4: ${duration4}")
    let quotient2 = duration3 / duration4
    println("Quotient 2: ${quotient2}")
}
```

Output:

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
public operator func /(r: Float64): Duration
```

Function: Implements division between [Duration](core_package_structs.md#struct-duration) type and [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) type, i.e., [Duration](core_package_structs.md#struct-duration) / [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) operation.

Parameters:

- r: [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) - The divisor.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The quotient of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `r` equals 0.
- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the division result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration
    let duration = Duration.hour * 2
    println("Original duration: ${duration}")
    
    // Divide with Float64 using / operator
    let dividedDuration = duration / 2.0
    println("Divided duration: ${dividedDuration}")
    
    // Divide with Float64 (value greater than 1)
    let smallerDuration = duration / 4.0
    println("Smaller duration: ${smallerDuration}")
}
```

Output:

```text
Original duration: 2h
Divided duration: 1h
Smaller duration: 30m
```

### operator func /(Int64)

```cangjie
public operator func /(r: Int64): Duration
```

Function: Implements division between [Duration](core_package_structs.md#struct-duration) type and [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type, i.e., [Duration](core_package_structs.md#struct-duration) / [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) operation.

Parameters:

- r: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The divisor.

Returns:

- [Duration](core_package_structs.md#struct-duration) - The quotient of the [Duration](core_package_structs.md#struct-duration) instance and `r`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `r` equals 0.
- [ArithmeticException](../../core/core_package_api/core_package_exceptions.md#class-arithmeticexception) - Thrown when the division result exceeds the representable range of [Duration](core_package_structs.md#struct-duration).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a duration
    let duration = Duration.hour * 3
    println("Original duration: ${duration}")
    
    // Divide with Int64 using / operator
    let dividedDuration = duration / 3
    println("Divided duration: ${dividedDuration}")
    
    // Divide with Int64 (value greater than 1)
    let smallerDuration = duration / 6
    println("Smaller duration: ${smallerDuration}")
}
```

Output:

```text
Original duration: 3h
Divided duration: 1h
Smaller duration: 30m
```

### operator func <(Duration)

```cangjie
public operator func <(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is less than `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is less than `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.minute * 30
    let duration2 = Duration.hour * 1
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Compare two durations using < operator
    if (duration1 < duration2) {
        println("Duration 1 is less than Duration 2")
    } else {
        println("Duration 1 is not less than Duration 2")
    }
    
    // Create identical durations and compare
    let duration3 = Duration.minute * 30
    println("Duration 3: ${duration3}")
    
    if (duration1 < duration3) {
        println("Duration 1 is less than Duration 3")
    } else {
        println("Duration 1 is not less than Duration 3")
    }
}
```

Output:

```text
Duration 1: 30m
Duration 2: 1h
Duration 1 is less than Duration 2
Duration 3: 30m
Duration 1 is not less than Duration 3
```

### operator func <=(Duration)

```cangjie
public operator func <=(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is less than or equal to `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is less than or equal to `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.minute * 30
    let duration2 = Duration.hour * 1
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Compare two durations using <= operator
    if (duration1 <= duration2) {
        println("Duration 1 is less than or equal to Duration 2")
    } else {
        println("Duration 1 is not less than or equal to Duration 2")
    }
    
    // Create identical durations and compare
    let duration3 = Duration.minute * 30
    println("Duration 3: ${duration3}")
    
    if (duration1 <= duration3) {
        println("Duration 1 is less than or equal to Duration 3")
    } else {
        println("Duration 1 is not less than or equal to Duration 3")
    }
    
    // Create a smaller duration and compare
    let duration4 = Duration.minute * 20
    println("Duration 4: ${duration4}")
    
    if (duration1 <= duration4) {
        println("Duration 1 is less than or equal to Duration 4")
    } else {
        println("Duration 1 is not less than or equal to Duration 4")
    }
}
```

Output:

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
public operator func ==(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is equal to `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is equal to `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two identical durations
    let duration1 = Duration.minute * 30
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Compare two durations using == operator
    if (duration1 == duration2) {
        println("Duration 1 is equal to Duration 2")
    } else {
        println("Duration 1 is not equal to Duration 2")
    }
    
    // Create different durations and compare
    let duration3 = Duration.hour * 1
    println("Duration 3: ${duration3}")
    
    if (duration1 == duration3) {
        println("Duration 1 is equal to Duration 3")
    } else {
        println("Duration 1 is not equal to Duration 3")
    }
}
```

Execution Result:

```text
Duration 1: 30m
Duration 2: 30m
Duration 1 is equal to Duration 2
Duration 3: 1h
Duration 1 is not equal to Duration 3
```

### operator func >(Duration)

```cangjie
public operator func >(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is greater than `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is greater than `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Compare the two durations using the > operator
    if (duration1 > duration2) {
        println("Duration 1 is greater than Duration 2")
    } else {
        println("Duration 1 is not greater than Duration 2")
    }
    
    // Create identical durations and compare
    let duration3 = Duration.hour * 2
    println("Duration 3: ${duration3}")
    
    if (duration1 > duration3) {
        println("Duration 1 is greater than Duration 3")
    } else {
        println("Duration 1 is not greater than Duration 3")
    }
}
```

Execution Result:

```text
Duration 1: 2h
Duration 2: 30m
Duration 1 is greater than Duration 2
Duration 3: 2h
Duration 1 is not greater than Duration 3
```

### operator func >=(Duration)

```cangjie
public operator func >=(r: Duration): Bool
```

Function: Determines whether the current [Duration](core_package_structs.md#struct-duration) instance is greater than or equal to `r`.

Parameters:

- r: [Duration](core_package_structs.md#struct-duration) - A [Duration](core_package_structs.md#struct-duration) instance.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` or `false`. Returns `true` if the current [Duration](core_package_structs.md#struct-duration) instance is greater than or equal to `r`; otherwise, returns `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two durations
    let duration1 = Duration.hour * 2
    let duration2 = Duration.minute * 30
    println("Duration 1: ${duration1}")
    println("Duration 2: ${duration2}")
    
    // Compare the two durations using the >= operator
    if (duration1 >= duration2) {
        println("Duration 1 is greater than or equal to Duration 2")
    } else {
        println("Duration 1 is not greater than or equal to Duration 2")
    }
    
    // Create identical durations and compare
    let duration3 = Duration.hour * 2
    println("Duration 3: ${duration3}")
    
    if (duration1 >= duration3) {
        println("Duration 1 is greater than or equal to Duration 3")
    } else {
        println("Duration 1 is not greater than or equal to Duration 3")
    }
    
    // Create a smaller duration and compare
    let duration4 = Duration.hour * 3
    println("Duration 4: ${duration4}")
    
    if (duration1 >= duration4) {
        println("Duration 1 is greater than or equal to Duration 4")
    } else {
        println("Duration 1 is not greater than or equal to Duration 4")
    }
}
```

Execution Result:

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
public struct LibC
```

Function: Provides commonly used C interfaces in Cangjie, such as allocating and freeing heap [CType](core_package_interfaces.md#interface-ctype) instances.

### static func free\<T>(CPointer\<T>) where T <: CType

```cangjie
public unsafe static func free<T>(p: CPointer<T>): Unit where T <: CType
```

Function: Frees the heap memory pointed to by pointer p.

Parameters:

- p: [CPointer](core_package_intrinsics.md#cpointert)\<T> - Represents the memory address to be freed.

Example:

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

Output:

```text
8
```

### static func free(CString)

```cangjie
public unsafe static func free(cstr: CString): Unit
```

Function: Frees a C-style string.

Parameters:

- cstr: [CString](core_package_intrinsics.md#cstring) - The C-style string to be freed.

Example:

<!-- verify -->
```cangjie
main() {
    var str = unsafe { LibC.mallocCString("I like Cangjie") }
    println(str)
    unsafe { LibC.free(str) }
}
```

Output:

```text
I like Cangjie
```

### static func mallocCString(String)

```cangjie
public unsafe static func mallocCString(str: String): CString
```

Function: Allocates a C-style string with identical character content from a [String](core_package_structs.md#struct-string).

The constructed C-style string will be null-terminated ('\0'). In exceptional cases such as insufficient system memory, the returned string pointer may be null, so null pointer checks are required before use.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The Cangjie string used to construct the C string.

Returns:

- [CString](core_package_intrinsics.md#cstring) - The newly constructed C-style string.

Exceptions:

- [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) - Thrown when memory is insufficient.

Example:

<!-- verify -->
```cangjie
main() {
    var str = unsafe { LibC.mallocCString("I like Cangjie") }
    println(str)
    unsafe { LibC.free(str) }
}
```

Output:

```text
I like Cangjie
```

### static func malloc\<T>(Int64) where T <: CType

```cangjie
public static func malloc<T>(count!: Int64 = 1): CPointer<T> where T <: CType
```

Function: Allocates a specified number of `T` instances on the heap and returns their starting pointer.

The allocated memory length is [sizeOf](core_package_funcs.md#func-sizeoft-where-t--ctype)\<T>() * [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet).

Parameters:

- count!: [Int64](core_package_intrinsics.md#int64) - An optional parameter, defaulting to 1, representing the number of T-type instances to allocate.

Returns:

- [CPointer](core_package_intrinsics.md#cpointert)\<T> - The allocated pointer of type T.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when the input parameter is negative.

Example:

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

Output:

```text
8
```

## struct Range\<T> where T <: Countable\<T> & Comparable\<T> & Equatable\<T>

```cangjie
public struct Range<T> <: Iterable<T> where T <: Countable<T> & Comparable<T> & Equatable<T> {
    public let end: T
    public let hasEnd: Bool
    public let hasStart: Bool
    public let isClosed: Bool
    public let start: T
    public let step: Int64
    public const init(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool)
}
```

Function: This class represents a range type, used to denote a sequence of `T` with fixed bounds and step size, requiring `T` to be countable and ordered.

Range types have corresponding literal representations with the following formats:

- Left-closed right-open interval: `start..end : step`, representing a range from start (inclusive) to end (exclusive) with step size [step](#let-step).
- Closed interval: `start..=end : step`, representing a range from start (inclusive) to end (inclusive) with step size [step](#let-step).

> **Note:**
>
> - When [step](#let-step) > 0 and start >= end, or [step](#let-step) < 0 and start <= end, this [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instance will be an empty range.
> - When [step](#let-step) > 0 and start > end, or [step](#let-step) < 0 and start < end, this [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instance will be an empty range.

Parent Types:

- [Iterable](core_package_interfaces.md#interface-iterablee)\<T>

### let end

```cangjie
public let end: T
```

Function: Represents the end value.

Type: T

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance
    let range = Range<Int32>(1, 10, 1, true, false, false)
    
    // Access the end property
    println("Range end value: ${range.end}")
}
```

Output:

```text
Range end value: 10
```

### let hasEnd

```cangjie
public let hasEnd: Bool
```

Function: Indicates whether the end value is included.

Type: [Bool](core_package_intrinsics.md#bool)

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance with an end value
    let rangeWithEnd = Range<Int32>(1, 10, 1, true, true, false)
    
    // Access the hasEnd property
    println("Range has end value: ${rangeWithEnd.hasEnd}")
    
    // Create a Range instance without an end value
    let rangeWithoutEnd = Range<Int32>(1, 10, 1, true, false, false)
    
    // Access the hasEnd property
    println("Range without end value: ${rangeWithoutEnd.hasEnd}")
}
```

Output:

```text
Range has end value: true
Range without end value: false
```

### let hasStart

```cangjie
public let hasStart: Bool
```

Function: Indicates whether the start value is included.

Type: [Bool](core_package_intrinsics.md#bool)

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance with a start value
    let rangeWithStart = Range<Int32>(1, 10, 1, true, true, false)
    
    // Access the hasStart property
    println("Range has start value: ${rangeWithStart.hasStart}")
    
    // Create a Range instance without a start value
    let rangeWithoutStart = Range<Int32>(1, 10, 1, false, true, false)
    
    // Access the hasStart property
    println("Range without start value: ${rangeWithoutStart.hasStart}")
}
```

Output:

```text
Range has start value: true
Range without start value: false
```

### let isClosed

```cangjie
public let isClosed: Bool
```

Function: Indicates the interval closure status. true represents a closed interval (inclusive), false represents a left-closed right-open interval.

Type: [Bool](core_package_intrinsics.md#bool)

Example:

<!-- verify -->
```cangjie
main() {
    // Create a closed Range instance
    let closedRange = Range<Int32>(1, 10, 1, true, true, true)
    
    // Access the isClosed property
    println("Closed range: ${closedRange.isClosed}")
    
    // Create an open Range instance
    let openRange = Range<Int32>(1, 10, 1, true, true, false)
    
    // Access the isClosed property
    println("Open range: ${openRange.isClosed}")
}
```

Output:

```text
Closed range: true
Open range: false
```

### let start

```cangjie
public let start: T
```

Function: Represents the start value.

Type: T

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance
    let range = Range<Int32>(5, 15, 1, true, true, false)
    
    // Access the start property
    println("Range start value: ${range.start}")
}
```

Output:

```text
Range start value: 5
```

### let step

```cangjie
public let step: Int64
```

Function: Represents the step size.

Type: [Int64](core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance with step size 2
    let range = Range<Int32>(1, 10, 2, true, true, false)
    
    // Access the step property
    println("Range step value: ${range.step}")
}
```

Output:

```text
Range step value: 2
```

### init(T, T, Int64, Bool, Bool, Bool)

```cangjie
public const init(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool)
```

Function: Creates a [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) sequence using this constructor.

Parameters:

- start: T - The start value.
- end: T - The end value.
- step: [Int64](core_package_intrinsics.md#int64) - The step size, which cannot be 0.
- hasStart: [Bool](core_package_intrinsics.md#bool) - Whether there is a start value.
- hasEnd: [Bool](core_package_intrinsics.md#bool) - Whether there is an end value.
- isClosed: [Bool](core_package_intrinsics.md#bool) - true represents a closed interval, false represents a left-closed right-open interval.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when [step](#let-step) equals 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance using the constructor
    let range = Range<Int32>(1, 10, 1, true, true, false)
    
    println("Range start: ${range.start}")
    println("Range end: ${range.end}")
    println("Range step: ${range.step}")
    println("Has start: ${range.hasStart}")
    println("Has end: ${range.hasEnd}")
    println("Is closed: ${range.isClosed}")
}
```

Output:

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

Function: Determines whether the range is empty.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if empty, otherwise false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a non-empty Range instance
    let nonEmptyRange = Range<Int32>(1, 10, 1, true, true, false)
    println("Non-empty range is empty: ${nonEmptyRange.isEmpty()}")
    
    // Create an empty Range instance (start >= end and step > 0)
    let emptyRange = Range<Int32>(10, 5, 1, true, true, false)
    println("Empty range is empty: ${emptyRange.isEmpty()}")
}
```

Output:

```text
Non-empty range is empty: false
Empty range is empty: true
```

### func iterator()

```cangjie
public func iterator(): Iterator<T>
```

Function: Gets the iterator for the current range.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<T> - The iterator for the current range.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance
    let range = Range<Int32>(1, 5, 1, true, false, false)
    
    // Use a for loop to iterate over the Range (Range implements the Iterable interface)
    println("Range values:")
    for (value in range) {
        println("${value}")
    }
}
```

Output:

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

Function: Extends the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T> type with the [Equatable](core_package_interfaces.md#interface-equatablet)\<[Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T>> interface.

Parent Types:

- [Equatable](core_package_interfaces.md#interface-equatablet)\<[Range](#struct-ranget-where-t--countablet--comparablet--equatablet)\<T>>

#### operator func ==(Range\<T>)

```cangjie
public operator func ==(that: Range<T>): Bool
```

Function: Determines whether two [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instances are equal.

Two [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instances are equal if they represent the same interval, i.e., their `start`, `end`, [step](#let-step), and `isClosed` values are equal.

Parameters:

- that: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<T> - The Range instance to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - true if equal, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    // Create two identical Range instances
    let range1 = Range<Int32>(1, 5, 1, true, false, false)
    let range2 = Range<Int32>(1, 5, 1, true, false, false)
    
    // Use the == operator to compare the two Range instances
    if (range1 == range2) {
        println("Range1 is equal to Range2")
    } else {
        println("Range1 is not equal to Range2")
    }
    
    // Create a different Range instance
    let range3 = Range<Int32>(1, 6, 1, true, false, false)
    
    // Use the == operator to compare two different Range instances
    if (range1 == range3) {
        println("Range1 is equal to Range3")
    } else {
        println("Range1 is not equal to Range3")
    }
}
```

Output:

```text
Range1 is equal to Range2
Range1 is not equal to Range3
```

### extend\<T> Range\<T> <: Hashable where T <: Hashable & Countable\<T> & Comparable\<T> & Equatable\<T>

```cangjie
extend<T> Range<T> <: Hashable where T <: Hashable & Countable<T> & Comparable<T> & Equatable<T>
```

Function: Extends the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) type with the [Hashable](core_package_interfaces.md#interface-hashable) interface, supporting hash value computation.

Parent Types:

- [Hashable](core_package_interfaces.md#interface-hashable)

#### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash value, which is a combined hash computation of `start`, `end`, [step](#let-step), and `isClosed`.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The hash value.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Range instance
    let range = Range<Int32>(1, 5, 1, true, false, false)
    
    // Get the hash value
    let hash = range.hashCode()
    println("Range hash code: ${hash}")
    
    // Create another identical Range instance
    let sameRange = Range<Int32>(1, 5, 1, true, false, false)
    let sameHash = sameRange.hashCode()
    println("Same range hash code: ${sameHash}")
    
    // Verify that identical Range instances have the same hash code
    if (hash == sameHash) {
        println("Same ranges have the same hash code")
    }
}
```

Output:

```text
Range hash code: -198835925178762
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

Function: This struct represents Cangjie strings and provides a series of string operations including construction, searching, concatenation, etc.

> **Note:**
>
> - The `String` type only supports UTF-8 encoding.
> - For memory optimization of `String` objects, the length of `String` is limited to `4GB`, meaning the maximum length of `String` does not exceed [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Parent Types:

- [Collection](core_package_interfaces.md#interface-collectiont)\<Byte>
- [Comparable](core_package_interfaces.md#interface-comparablet)\<[String](#struct-string)>
- [Hashable](core_package_interfaces.md#interface-hashable)
- [ToString](core_package_interfaces.md#interface-tostring)

### static const empty

```cangjie
public static const empty: String = String()
```

Function: Creates and returns an empty string.

Type: [String](core_package_structs.md#struct-string)

Example:

<!-- verify -->
```cangjie
main() {
    // Create an empty string using String.empty
    let emptyString = String.empty
    println("Empty string: '${emptyString}'")
    println("Empty string length: ${emptyString.size}")
}
```

Output:

```text
Empty string: ''
Empty string length: 0
```

### prop size

```cangjie
public prop size: Int64
```

Function: Gets the byte length of the string after UTF-8 encoding.

Type: [Int64](core_package_intrinsics.md#int64)

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    println("String: '${str}'")
    
    // Get the byte length of the string
    let size = str.size
    println("String size (bytes): ${size}")
    
    // Create an empty string
    let emptyStr = String.empty
    println("Empty string size: ${emptyStr.size}")
}
```

Output:

```text
String: 'Hello, 世界'
String size (bytes): 13
Empty string size: 0
```

### init()

```cangjie
public const init()
```

Function: Constructs an empty string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an empty string
    let str = String()
    println("String: '${str}'")
    
    // Get the byte length of the string
    let size = str.size
    println("String size (bytes): ${size}")
}
```

Output:

```text
String: ''
String size (bytes): 0
```

### init(Array\<Rune>)

```cangjie
public init(value: Array<Rune>)
```

Function: Constructs a string from an array of characters, where the string content consists of all characters in the array.

Parameters:

- value: [Array](core_package_structs.md#struct-arrayt)\<Rune> - The character array used to construct the string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a Rune array
    let runes = [r'H', r'e', r'l', r'l', r'o', r' ', r'世', r'界']
    
    // Use the init(Array<Rune>) constructor to create a string
    let str = String(runes)
    
    println("String from Rune array: '${str}'")
    println("String size: ${str.size}")
}
```

Output:

```text
String from Rune array: 'Hello 世界'
String size: 12
```

### init(Collection\<Rune>)

```cangjie
public init(value: Collection<Rune>)
```

Function: Constructs a string from a collection of characters, where the string content consists of all characters in the collection.

Parameters:

- value: [Collection](core_package_interfaces.md#interface-collectiont)\<Rune> - The character collection used to construct the string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create an Array<Rune> as a Collection<Rune>
    let runeArray: Array<Rune> = [r'H', r'e', r'l', r'l', r'o', r' ', r'世', r'界']
    
    // Use the init(Collection<Rune>) constructor to create a string
    let str = String(runeArray)
    
    println("String from Collection<Rune>: '${str}'")
    println("String size: ${str.size}")
}
```

Output:

```text
String from Collection<Rune>: 'Hello 世界'
String size: 12
```

### static func checkUtf8Encoding(Array\<UInt8>)

```cangjie
public static func checkUtf8Encoding(data: Array<UInt8>): Bool
```

Function: Checks whether a Byte array conforms to UTF-8 encoding.

Parameters:

- data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array used to construct the string.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the Byte array conforms to UTF-8 encoding; otherwise, returns false.

### static func fromUtf8(Array\<UInt8>)

```cangjie
public static func fromUtf8(utf8Data: Array<UInt8>): String
```

Function: Constructs a string from a UTF-8 encoded byte array.

Parameters:

- utf8Data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array used to construct the string.

Returns:

- [String](core_package_structs.md#struct-string) - The constructed string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when the input does not conform to UTF-8 sequence rules or when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a UTF-8 encoded byte array representing "Hello 世界"
    let utf8Bytes = [72u8, 101u8, 108u8, 108u8, 111u8, 32u8, 228u8, 184u8, 150u8, 231u8, 149u8, 140u8]
    
    // Use the fromUtf8 function to create a string
    let str = String.fromUtf8(utf8Bytes)
    
    println("String from UTF-8 bytes: '${str}'")
    println("String size: ${str.size}")
}
```

Output:

```text
String from UTF-8 bytes: 'Hello 世界'
String size: 12
```

### static func fromUtf8Unchecked(Array\<UInt8>)

```cangjie
public unsafe static  func fromUtf8Unchecked(utf8Data: Array<UInt8>): String
```

Function: Constructs a string from a byte array.

Compared to the [fromUtf8](core_package_structs.md#static-func-fromutf8arrayuint8) function, fromUtf8Unchecked does not perform UTF-8 rule checks on the byte array, so the constructed string is not guaranteed to be valid and may result in unexpected exceptions. Unless performance is a critical concern, prefer using the safe fromUtf8 function.

Parameters:

- utf8Data: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array used to construct the string.

Returns:

- [String](core_package_structs.md#struct-string) - The constructed string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a UTF-8 encoded byte array representing "Hello 世界"
    let utf8Bytes = [72u8, 101u8, 108u8, 108u8, 111u8, 32u8, 228u8, 184u8, 150u8, 231u8, 149u8, 140u8]
    
    // Use the fromUtf8Unchecked function to create a string (without UTF-8 validation)
    let str = unsafe { String.fromUtf8Unchecked(utf8Bytes) }
    
    println("String from UTF-8 bytes (unchecked): '${str}'")
    println("String size: ${str.size}")
}
```

Output:

```text
String from UTF-8 bytes (unchecked): 'Hello 世界'
String size: 12
```

### static func join(Array\<String>, String)

```cangjie
public static func join(strArray: Array<String>, delimiter!: String = String.empty): String
```

Function: Joins all strings in a string list with a specified delimiter.

Parameters:

- strArray: [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - The array of strings to be joined. Returns an empty string if the array is empty.
- delimiter!: [String](core_package_structs.md#struct-string) - The intermediate string used for joining, with a default value of [String](core_package_structs.md#struct-string).empty.

Returns:

- [String](core_package_structs.md#struct-string) - The newly concatenated string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    var arr = ["I", "like", "Cangjie"]
    var str = String.join(arr, delimiter: " ")
    println(str)
}
```

Output:

```text
I like Cangjie
```

### static func withRawData(Array\<UInt8>)

```cangjie
public static unsafe func withRawData(rawData: Array<UInt8>): String
```

Function: Constructs a string from a byte array.

Compared to the [fromUtf8Unchecked](core_package_structs.md#static-func-fromutf8uncheckedarrayuint8) function, withRawData does not copy the array but directly uses the input array to construct the string.

> **Note:**
>
> Users should ensure:
>
> 1. rawData is never modified after string construction.
> 2. rawData conforms to UTF-8 encoding.
>
> Otherwise, the program behavior is undefined.
>
> Unless performance is a critical concern, prefer using the safe fromUtf8 function.

Parameters:

- rawData: [Array](core_package_structs.md#struct-arrayt)\<[UInt8](core_package_intrinsics.md#uint8)> - The byte array used to construct the string.

Returns:

- [String](core_package_structs.md#struct-string) - The constructed string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string whose length exceeds [the maximum value of UInt32](./core_package_intrinsics.md#uint32).

### func clone()

```cangjie
public func clone(): String
```

Function: Returns a copy of the original string.

Returns:

- [String](core_package_structs.md#struct-string) - The newly copied string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let originalStr = "Hello, 世界"
    
    // Use the clone function to create a copy of the string
    let clonedStr = originalStr.clone()
    
    println("Original string: '${originalStr}'")
    println("Cloned string: '${clonedStr}'")
    println("Are they equal? ${originalStr == clonedStr}")
}
```

Output:

```text
Original string: 'Hello, 世界'
Cloned string: 'Hello, 世界'
Are they equal? true
```

### func compare(String)

```cangjie
public func compare(str: String): Ordering
```

Function: Compares the current string with the specified string lexicographically.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to be compared.

Returns:

- [Ordering](core_package_enums.md#enum-ordering) - Returns an enum value [Ordering](core_package_enums.md#enum-ordering) indicating the result. [Ordering](core_package_enums.md#enum-ordering).GT means the current string is lexicographically greater than str, [Ordering](core_package_enums.md#enum-ordering).LT means the current string is lexicographically less than str, and [Ordering](core_package_enums.md#enum-ordering).EQ means the two strings are lexicographically equal.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if invalid UTF-8 encoding exists in the raw data of either string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for comparison
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"
    
    // Compare strings using the compare function
    let result1 = str1.compare(str2)
    let result2 = str2.compare(str1)
    let result3 = str1.compare(str3)
    
    println("Comparing '${str1}' to '${str2}': ${result1}")
    println("Comparing '${str2}' to '${str1}': ${result2}")
    println("Comparing '${str1}' to '${str3}': ${result3}")
}
```

Output:

```text
Comparing 'apple' to 'banana': Ordering.LT
Comparing 'banana' to 'apple': Ordering.GT
Comparing 'apple' to 'apple': Ordering.EQ
```

### func contains(String)

```cangjie
public func contains(str: String): Bool
```

Function: Determines whether the original string contains the substring str.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The substring to search for.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the substring str is found in the original string, otherwise returns false. Specifically, if str is an empty string, returns true.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Check if the string contains specific substrings
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

Output:

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

Function: Returns the number of occurrences of substring str in the original string.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The substring to search for.

Returns:

- [Int64](core_package_intrinsics.md#int64) - The number of occurrences. If str is an empty string, returns the number of Runes in the original string plus one.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello, 世界, Hello"
    
    // Count occurrences of substrings in the string
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

Output:

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

Function: Determines whether the original string ends with the suffix string.

Parameters:

- suffix: [String](core_package_structs.md#struct-string) - The suffix string to check.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string str is a suffix of the original string, otherwise returns false. Specifically, if str is an empty string, returns true.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "Hello, 世界"
    let str2 = "world"
    let str3 = ""
    
    // Check if strings end with specific suffixes
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

Output:

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
public func equalsIgnoreAsciiCase(that: String): Bool
```

Function: Determines whether the current string is equal to the specified string, ignoring ASCII case.

Parameters:

- that: [String](./core_package_structs.md#struct-string) - The string to compare.

Returns:

- [Bool](./core_package_intrinsics.md#bool) - Returns true if the current string is equal to the specified string, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "Hello"
    let str2 = "HELLO"
    let str3 = "hello"
    let str4 = "Hello, World"
    let str5 = "Hello, world"
    let str6 = "Hello, 世界"
    let str7 = "HELLO, 世界"
    
    // Check if strings are equal (ignoring ASCII case)
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

Output:

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

Function: Returns the UTF-8 encoded byte value at the specified index in the string.

Parameters:

- index: [Int64](core_package_intrinsics.md#int64) - The index of the byte to retrieve.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Byte](core_package_types.md#type-byte)> - Returns the UTF-8 encoded byte value at the specified index. If index is less than 0 or greater than or equal to the string length, returns [Option](core_package_enums.md#enum-optiont)\<[Byte](core_package_types.md#type-byte)>.None.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Get byte values at specified indices
    let byte1 = str.get(0)  // ASCII code of 'H'
    let byte2 = str.get(7)  // First byte of UTF-8 encoding for '世'
    let byte3 = str.get(100)  // Out-of-bounds index
    
    println("String: '${str}'")
    println("Byte at index 0: ${byte1}")
    println("Byte at index 7: ${byte2}")
    println("Byte at index 100: ${byte3}")
}
```

Output:

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

Function: Retrieves the hash code of the string.

Returns:

- [Int64](core_package_intrinsics.md#int64) - Returns the hash code of the string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Get the hash code
    let hashCode = str.hashCode()
    println("hashCode: ${hashCode}")
}
```

Output:

```text
hashCode: -255291815105879447
```

### func indexOf(Byte)

```cangjie
public func indexOf(b: Byte): Option<Int64>
```

Function: Retrieves the index of the first occurrence of the specified byte b in the original string.

Parameters:

- b: [Byte](core_package_types.md#type-byte) - The byte to search for.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the byte is found, returns the index of its first occurrence. If the byte is not found, returns [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)>.None.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Find the first occurrence of 'l'
    let index1 = str.indexOf(108u8)  // ASCII code of 'l' is 108
    
    // Find the first occurrence of '世'
    let index2 = str.indexOf(228u8)  // First byte of UTF-8 encoding for '世' is 228
    
    // Find a non-existent character
    let index3 = str.indexOf(122u8)  // ASCII code of 'z' is 122
    
    println("String: '${str}'")
    println("Index of 'l' (108u8): ${index1}")
    println("Index of '世' first byte (228u8): ${index2}")
    println("Index of 'z' (122u8): ${index3}")
}
```

Output:

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

Function: Searches for the first occurrence of the specified byte starting from the given index in the original string.

Parameters:

- b: [Byte](core_package_types.md#type-byte) - The byte to search for.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The index to start searching from.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the byte is found, returns the index of its first occurrence. Otherwise, returns `None`. Specifically, if fromIndex is less than 0, it is treated as 0. If fromIndex is greater than or equal to the string length, returns [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)>.None.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello"
    
    // Find the first occurrence of 'l' starting from index 3
    let index1 = str.indexOf(108u8, 3)  // ASCII code of 'l' is 108
    
    // Find the first occurrence of 'H' starting from index 1
    let index2 = str.indexOf(72u8, 1)  // ASCII code of 'H' is 72
    
    // Find a non-existent character
    let index3 = str.indexOf(122u8, 0)  // ASCII code of 'z' is 122
    
    println("String: '${str}'")
    println("Index of 'l' (108u8) from index 3: ${index1}")
    println("Index of 'H' (72u8) from index 1: ${index2}")
    println("Index of 'z' (122u8) from index 0: ${index3}")
}
```

Output:

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

Function: Returns the starting index of the first occurrence of the specified string `str` in the original string.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to search for.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the original string contains `str`, returns the index of its first occurrence; if `str` is not found, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello, 世界"
    
    // Find the first occurrence of substring "Hello"
    let index1 = str.indexOf("Hello")
    
    // Find the first occurrence of substring "世界"
    let index2 = str.indexOf("世界")
    
    // Search for a non-existent substring
    let index3 = str.indexOf("World")
    
    println("String: '${str}'")
    println("Index of 'Hello': ${index1}")
    println("Index of '世界': ${index2}")
    println("Index of 'World': ${index3}")
}
```

Output:

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

Function: Searches for the first occurrence of the specified string `str` in the original string starting from the specified index `fromIndex`, and returns its starting index.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to search for.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The index from which to start the search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the search is successful, returns the index of the first occurrence of `str`; otherwise, returns `None`. Specifically, if `str` is an empty string and `fromIndex` is greater than 0, returns `None`; otherwise, returns `Some(0)`. If `fromIndex` is negative, it is treated as 0. If `fromIndex` is greater than or equal to the length of the original string, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello, 世界"
    
    // Find the first occurrence of substring "Hello" starting from index 1
    let index1 = str.indexOf("Hello", 1)
    
    // Find the first occurrence of substring "llo" starting from index 5
    let index2 = str.indexOf("llo", 5)
    
    // Search for a non-existent substring starting from index 0
    let index3 = str.indexOf("World", 0)
    
    println("String: '${str}'")
    println("Index of 'Hello' from index 1: ${index1}")
    println("Index of 'llo' from index 5: ${index2}")
    println("Index of 'World' from index 0: ${index3}")
}
```

Output:

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

Function: Determines whether the string is an ASCII string. Returns `true` if the string is empty or contains no non-ASCII characters.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the string is ASCII, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "Hello, 世界"
    let str3 = ""
    let str4 = "123456"
    
    // Check if strings are ASCII
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

Output:

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

Function: Determines whether the string is empty or all its Runes are ASCII whitespace characters (including: 0x09, 0x10, 0x11, 0x12, 0x13, 0x20).

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the string is empty or contains only ASCII whitespace, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = ""
    let str2 = "   "
    let str3 = "\t\n\r"
    let str4 = "Hello"
    let str5 = " \t\n\r "
    
    // Check if strings are empty or contain only ASCII whitespace
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

Output:

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

Function: Determines whether the original string is an empty string.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns `true` if the string is empty, otherwise `false`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = ""
    let str2 = "Hello"
    let str3 = " "
    
    // Check if strings are empty
    let isEmpty1 = str1.isEmpty()
    let isEmpty2 = str2.isEmpty()
    let isEmpty3 = str3.isEmpty()
    
    println("String 1: '${str1}', is empty: ${isEmpty1}")
    println("String 2: '${str2}', is empty: ${isEmpty2}")
    println("String 3: '${str3}', is empty: ${isEmpty3}")
}
```

Output:

```text
String 1: '', is empty: true
String 2: 'Hello', is empty: false
String 3: ' ', is empty: false
```

### func iterator()

```cangjie
public func iterator(): Iterator<Byte>
```

Function: Returns a UTF-8 encoded byte iterator for the string, which can be used in `for-in` loops.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<[Byte](core_package_types.md#type-byte)> - A UTF-8 encoded byte iterator for the string.

Example:

<!-- verify -->
```cangjie
main() {
    var str = "abc"

    /* Iterator elements are UTF-8 encoded bytes of each character */
    for (i in str) {
        println(i)
    }
}
```

Output:

```text
97
98
99
```

### func lastIndexOf(Byte)

```cangjie
public func lastIndexOf(b: Byte): Option<Int64>
```

Function: Returns the index of the last occurrence of the specified byte `b` in the original string.

Parameters:

- b: [Byte](core_package_types.md#type-byte) - The byte to search for.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the original string contains the byte, returns the index of its last occurrence; otherwise, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Find the last occurrence of character 'l'
    let lastIndex1 = str.lastIndexOf(108u8)  // ASCII code for 'l' is 108
    
    // Find the last occurrence of the first byte of '世'
    let lastIndex2 = str.lastIndexOf(228u8)  // First UTF-8 byte of '世' is 228
    
    // Search for a non-existent character
    let lastIndex3 = str.lastIndexOf(122u8)  // ASCII code for 'z' is 122
    
    println("String: '${str}'")
    println("Last index of 'l' (108u8): ${lastIndex1}")
    println("Last index of '世' first byte (228u8): ${lastIndex2}")
    println("Last index of 'z' (122u8): ${lastIndex3}")
}
```

Output:

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

Function: Searches backward from the specified index `fromIndex` in the original string for the last occurrence of the specified UTF-8 encoded byte `b`, and returns its index.

Parameters:

- b: [Byte](core_package_types.md#type-byte) - The byte to search for.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The index from which to start the backward search.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the search is successful, returns the index of the last occurrence of the byte; otherwise, returns `None`. If `fromIndex` is negative, it is treated as 0. If `fromIndex` is greater than or equal to the length of the original string, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello"
    
    // Find the last occurrence of 'l' starting from index 10
    let lastIndex1 = str.lastIndexOf(108u8, 10)  // ASCII code for 'l' is 108
    
    // Find the last occurrence of 'H' starting from index 5
    let lastIndex2 = str.lastIndexOf(72u8, 5)  // ASCII code for 'H' is 72
    
    // Search for a non-existent character starting from index 5
    let lastIndex3 = str.lastIndexOf(122u8, 5)  // ASCII code for 'z' is 122
    
    println("String: '${str}'")
    println("Last index of 'l' (108u8) from index 10: ${lastIndex1}")
    println("Last index of 'H' (72u8) from index 5: ${lastIndex2}")
    println("Last index of 'z' (122u8) from index 5: ${lastIndex3}")
}
```

Output:

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

Function: Returns the starting index of the last occurrence of the specified string `str` in the original string.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to search for.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - If the original string contains `str`, returns the index of its last occurrence; otherwise, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello, 世界"
    
    // Find the last occurrence of substring "Hello"
    let lastIndex1 = str.lastIndexOf("Hello")
    
    // Find the last occurrence of substring "世界"
    let lastIndex2 = str.lastIndexOf("世界")
    
    // Search for a non-existent substring
    let lastIndex3 = str.lastIndexOf("World")
    
    println("String: '${str}'")
    println("Last index of 'Hello': ${lastIndex1}")
    println("Last index of '世界': ${lastIndex2}")
    println("Last index of 'World': ${lastIndex3}")
}
```

Output:

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

Function: Searches backward from the specified index in the original string to get the starting index of the last occurrence of the specified string str.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string to search for.
- fromIndex: [Int64](core_package_intrinsics.md#int64) - The index to start the search from.

Returns:

- [Option](core_package_enums.md#enum-optiont)\<[Int64](core_package_intrinsics.md#int64)> - Returns `None` if the string does not occur at or after position fromIndex. Specifically, when str is an empty string, returns `None` if fromIndex > 0, otherwise returns `Some(0)`. If fromIndex < 0, it is treated as 0. If fromIndex ≥ the length of the original string, returns `None`.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, Hello, 世界"
    
    // Find the last occurrence of substring "Hello" starting from index 6
    let lastIndex1 = str.lastIndexOf("Hello", 6)
    
    // Find the last occurrence of substring "llo" starting from index 6
    let lastIndex2 = str.lastIndexOf("llo", 6)
    
    // Search for a non-existent substring starting from index 10
    let lastIndex3 = str.lastIndexOf("World", 10)
    
    println("String: '${str}'")
    println("Last index of 'Hello' from index 6: ${lastIndex1}")
    println("Last index of 'llo' from index 6: ${lastIndex2}")
    println("Last index of 'World' from index 10: ${lastIndex3}")
}
```

Output:

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

Function: Splits the original string using string str as a delimiter. This function does not immediately split the string but returns an iterator that performs the actual splitting operation when traversed.

If str does not appear in the original string, returns a string iterator of size 1 containing only the original string.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string delimiter.
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - Removes empty strings from the split result. Default is false.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - An iterator of split strings.

Example:

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

Output:

```text
I
like
Cangjie
```

### func lazySplit(String, Int64, Bool)

```cangjie
public func lazySplit(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Iterator<String>
```

Function: Splits the original string using string str as a delimiter. This function does not immediately split the string but returns an iterator that performs the actual splitting operation when traversed.

- When maxSplit = 0, returns an empty string iterator.
- When maxSplit = 1, returns a string iterator of size 1 containing only the original string.
- When maxSplit < 0, returns the fully split string iterator.
- When maxSplit > the number of fully split substrings, returns the fully split string iterator.
- If str does not appear in the original string, returns a string iterator of size 1 containing only the original string.
- If str is empty, splits by each character. If both the original string and delimiter are empty, returns an empty string iterator.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The string delimiter.
- maxSplits: [Int64](core_package_intrinsics.md#int64) - Maximum number of splits (maxSplit substrings).
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - Removes empty strings from the split result. Default is false.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - An iterator of split strings.

Example:

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

Output:

```text
I
like Cangjie
```

### func lines()

```cangjie
public func lines(): Iterator<String>
```

Function: Returns an iterator of lines in the string, each separated by line terminators (`\n`, `\r`, or `\r\n`). The line terminators are not included in the result.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<[String](core_package_structs.md#struct-string)> - An iterator of lines in the string.

Example:

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

Output:

```text
I
like
Cangjie
```

### func padEnd(Int64, String)

```cangjie
public func padEnd(totalWidth: Int64, padding!: String = " "): String
```

Function: Left-aligns the original string to the specified length. If the original string's length is less than the specified length, pads the right side with the specified string.

If the specified length is less than the string length, returns the string itself (no truncation). If the specified length is greater, pads the right side with the padding string. If padding length > 1, the resulting string may exceed the specified length.

Parameters:

- totalWidth: [Int64](core_package_intrinsics.md#int64) - The target length after padding. Must be ≥ 0.
- padding!: [String](core_package_structs.md#struct-string) - The string used for right padding when length is insufficient.

Returns:

- [String](core_package_structs.md#struct-string) - The padded string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if totalWidth < 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "World"
    
    // Use padEnd for right padding
    let padded1 = str1.padEnd(10, padding: "-")
    let padded2 = str2.padEnd(10, padding: " ")
    let padded3 = str1.padEnd(3, padding: "-")  // Length < original string
    
    println("Original string 1: '${str1}'")
    println("Padded string 1: '${padded1}'")
    println("Original string 2: '${str2}'")
    println("Padded string 2: '${padded2}'")
    println("String padded to smaller width: '${padded3}'")
}
```

Output:

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

Function: Right-aligns the original string to the specified length. If the original string's length is less than the specified length, pads the left side with the specified string.

If the specified length is less than the string length, returns the string itself (no truncation). If the specified length is greater, pads the left side with the padding string. If padding length > 1, the resulting string may exceed the specified length.

Parameters:

- totalWidth: [Int64](core_package_intrinsics.md#int64) - The target length after padding. Must be ≥ 0.
- padding!: [String](core_package_structs.md#struct-string) - The string used for left padding when length is insufficient.

Returns:

- [String](core_package_structs.md#struct-string) - The padded string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if totalWidth < 0.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "World"
    
    // Use padStart for left padding
    let padded1 = str1.padStart(10, padding: "-")
    let padded2 = str2.padStart(10, padding: " ")
    let padded3 = str1.padStart(3, padding: "-")  // Length < original string
    
    println("Original string 1: '${str1}'")
    println("Padded string 1: '${padded1}'")
    println("Original string 2: '${str2}'")
    println("Padded string 2: '${padded2}'")
    println("String padded to smaller width: '${padded3}'")
}
```

Output:

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

Function: Gets the raw byte array of the string encoded in UTF-8.

> **Note:**
>
> Users should not modify the obtained array, as this would violate string immutability.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[Byte](core_package_types.md#type-byte)> - The raw byte array corresponding to the current string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string
    let str = "Hello, 世界"
    
    // Get the raw byte array
    let rawData = unsafe { str.rawData() }
    
    println("String: '${str}'")
    println("Raw data length: ${rawData.size}")
    println("Raw data bytes:")
    for (i in 0..rawData.size) {
        println("  Index ${i}: ${rawData[i]}")
    }
}
```

Output:

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

Function: Removes the specified prefix from the string.

Parameters:

- prefix: [String](core_package_structs.md#struct-string) - The prefix to remove.

Returns:

- [String](core_package_structs.md#struct-string) - The new string after prefix removal.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = "Hello"
    
    // Use removePrefix to remove prefixes
    let removed1 = str1.removePrefix("Hello")
    let removed2 = str2.removePrefix("Hello")
    let removed3 = str3.removePrefix("Hello")
    let removed4 = str1.removePrefix("World")  // Non-existent prefix
    
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

Output:

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

Function: Removes the specified suffix from a string.

Parameters:

- suffix: [String](core_package_structs.md#struct-string) - The suffix to be removed.

Returns:

- [String](core_package_structs.md#struct-string) - The new string with the suffix removed.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = "World"
    
    // Use removeSuffix function to remove suffixes
    let removed1 = str1.removeSuffix("World")
    let removed2 = str2.removeSuffix("世界")
    let removed3 = str3.removeSuffix("World")
    let removed4 = str1.removeSuffix("Hello")  // Non-existent suffix
    
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

Output:

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

Function: Replaces occurrences of a substring with another string.

Parameters:

- old: [String](core_package_structs.md#struct-string) - The substring to be replaced.
- new: [String](core_package_structs.md#struct-string) - The replacement string.

Returns:

- [String](core_package_structs.md#struct-string) - The new string after replacement.

Exceptions:

- [OutOfMemoryError](core_package_exceptions.md#class-outofmemoryerror) - Thrown if memory allocation fails during operation.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello, World"
    let str2 = "Hello, Hello, World"
    let str3 = "Hello"
    
    // Use replace function
    let replaced1 = str1.replace("World", "Cangjie")
    let replaced2 = str2.replace("Hello", "Hi")
    let replaced3 = str3.replace("World", "Cangjie")  // Non-existent substring
    let replaced4 = str1.replace("Hello", "")  // Replace with empty string
    
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

Output:

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

Function: Returns an iterator over the Unicode runes of the string.

Returns:

- [Iterator](core_package_classes.md#class-iteratort)\<Rune> - A Rune iterator for the string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if illegal characters are encountered during iteration.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a multilingual string
    let str = "Hello, 世界"
    
    // Get Rune iterator
    let runesIter = str.runes()
    
    println("String: '${str}'")
    println("Runes:")
    
    // Iterate and print each rune
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

Output:

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

Function: Splits the string using a delimiter, optionally removing empty entries.

Returns a single-element array containing the original string if the delimiter isn't found.

Parameters:

- str: [String](core_package_structs.md#struct-string) - The delimiter string.
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - Whether to remove empty strings from results (default: false).

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - The resulting string array.

Example:

<!-- verify -->
```cangjie
main() {
    let str = "apple,banana,,cherry,dates"
    
    // Split keeping empty strings
    let result1 = str.split(",", removeEmpty: false)
    
    // Split removing empty strings
    let result2 = str.split(",", removeEmpty: true)
    
    println("Original string: '${str}'")
    println("Split with empty strings kept:")
    for (i in 0..result1.size) {
        println("  Element ${i}: '${result1[i]}'")
    }
    
    println("Split with empty strings removed:")
    for (i in 0..result2.size) {
        println("  Element ${i}: '${result2[i]}'")
    }
}
```

Output:

```text
Original string: 'apple,banana,,cherry,dates'
Split with empty strings kept:
  Element 0: 'apple'
  Element 1: 'banana'
  Element 2: ''
  Element 3: 'cherry'
  Element 4: 'dates'
Split with empty strings removed:
  Element 0: 'apple'
  Element 1: 'banana'
  Element 2: 'cherry'
  Element 3: 'dates'
```

### func split(String, Int64, Bool)

```cangjie
public func split(str: String, maxSplits: Int64, removeEmpty!: Bool = false): Array<String>
```

Function: Splits the string with a maximum split count and optional empty entry removal.

Special cases:

- maxSplit = 0: Returns empty array
- maxSplit = 1: Returns original string
- Negative maxSplit: Performs complete split
- Empty delimiter: Splits by characters

Parameters:

- str: [String](core_package_structs.md#struct-string) - The delimiter string.
- maxSplits: [Int64](core_package_intrinsics.md#int64) - Maximum number of splits.
- removeEmpty!: [Bool](core_package_intrinsics.md#bool) - Remove empty strings (default: false).

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[String](core_package_structs.md#struct-string)> - The resulting string array.

Example:

<!-- verify -->
```cangjie
main() {
    let str = "one,two,three,four,five"
    
    let result1 = str.split(",", 3)  // Max 3 splits
    let result2 = str.split(",", 1)  // Max 1 split
    let result3 = str.split(",", -1) // Complete split
    
    println("Original string: '${str}'")
    println("Split with maxSplits = 3:")
    for (i in 0..result1.size) {
        println("  Element ${i}: '${result1[i]}'")
    }
    
    println("Split with maxSplits = 1:")
    for (i in 0..result2.size) {
        println("  Element ${i}: '${result2[i]}'")
    }
    
    println("Split with maxSplits = -1:")
    for (i in 0..result3.size) {
        println("  Element ${i}: '${result3[i]}'")
    }
}
```

Output:

```text
Original string: 'one,two,three,four,five'
Split with maxSplits = 3:
  Element 0: 'one'
  Element 1: 'two'
  Element 2: 'three,four,five'
Split with maxSplits = 1:
  Element 0: 'one,two,three,four,five'
Split with maxSplits = -1:
  Element 0: 'one'
  Element 1: 'two'
  Element 2: 'three'
  Element 3: 'four'
  Element 4: 'five'
```

### func startsWith(String)

```cangjie
public func startsWith(prefix: String): Bool
```

Function: Checks if the string starts with the specified prefix.

Parameters:

- prefix: [String](core_package_structs.md#struct-string) - The prefix to check.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the string starts with the prefix. Empty prefix always returns true.

Example:

<!-- verify -->
```cangjie
main() {
    let str1 = "Hello, World"
    let str2 = "Hello, 世界"
    let str3 = ""
    
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

Output:

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

Function: Returns the UTF-8 encoded byte array of the string.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[Byte](core_package_types.md#type-byte)> - The UTF-8 byte array.

Example:

<!-- verify -->
```cangjie
main() {
    let str = "Hello, 世界"
    let byteArray = str.toArray()
    
    println("String: '${str}'")
    println("Byte array size: ${byteArray.size}")
    println("Byte array elements:")
    for (i in 0..byteArray.size) {
        println("  Index ${i}: ${byteArray[i]}")
    }
}
```

Output:

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

Function: Converts all ASCII uppercase letters in the string to ASCII lowercase letters.

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "Hello, World"
    let str2 = "CANGJIE Programming"
    let str3 = "123ABC456"
    let str4 = "你好World"
    
    // Use toAsciiLower function to convert ASCII uppercase letters to lowercase
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

Execution result:

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

Function: Capitalizes the string in title case.

This function only converts ASCII English characters. When an English character is the first character in the string or the preceding character is not an English character, the character is capitalized; other English characters are converted to lowercase.

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "hello world"
    let str2 = "CANGJIE programming"
    let str3 = "123abc456"
    let str4 = "你好world"
    
    // Use toAsciiTitle function to convert strings to title case
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

Execution result:

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

Function: Converts all ASCII lowercase letters in the string to ASCII uppercase letters.

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "Hello, World"
    let str2 = "cangjie programming"
    let str3 = "123abc456"
    let str4 = "你好world"
    
    // Use toAsciiUpper function to convert ASCII lowercase letters to uppercase
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

Execution result:

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

Function: Gets the Rune array of the string. If the original string is empty, returns an empty array.

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<Rune> - The Rune array of the string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string containing both English and Chinese characters
    let str = "Hello, 世界"
    
    // Use toRuneArray function to get the Rune array of the string
    let runeArray = str.toRuneArray()
    
    println("String: '${str}'")
    println("Rune array size: ${runeArray.size}")
    println("Rune array elements:")
    for (i in 0..runeArray.size) {
        println("  Index ${i}: ${runeArray[i]}")
    }
}
```

Execution result:

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

Function: Returns the string itself.

Returns:

- [String](core_package_structs.md#struct-string) - The string itself.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a string for testing
    let str = "Hello, World"
    
    // Use toString function to get the string itself
    let strSelf = str.toString()
    
    println("Original string: '${str}'")
    println("String from toString(): '${strSelf}'")
    println("Are they equal? ${str == strSelf}")
}
```

Execution result:

```text
Original string: 'Hello, World'
String from toString(): 'Hello, World'
Are they equal? true
```

### func trimAscii()

```cangjie
public func trimAscii(): String
```

Function: Removes leading and trailing substrings composed of ASCII whitespace characters from the original string.

ASCII whitespace characters include characters with ASCII codes in the range [0x09, 0x0D] and the character with ASCII code 0x20. Specific characters are listed in the table below.

| Character Description | ASCII Code |
| --- | --- |
| Horizontal tab (\t, HT) | 0x09 |
| Line feed (\n, LF) | 0x0A |
| Vertical tab (\v, VT) | 0x0B |
| Form feed (\f, FF) | 0x0C |
| Carriage return (\r, CR) | 0x0D |
| Space (Space) | 0x20 |

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "  Hello, World  "
    let str2 = "\t\n Hello, 世界 \r\n"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "
    
    // Use trimAscii function to remove leading and trailing ASCII whitespace characters
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

Execution result:

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

Function: Removes trailing substrings composed of ASCII whitespace characters from the original string.

ASCII whitespace characters include characters with ASCII codes in the range [0x09, 0x0D] and the character with ASCII code 0x20. Specific characters are listed in [trimAscii()](#func-trimascii).

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "Hello, World  "
    let str2 = "Hello, 世界\t\n\r"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "
    
    // Use trimAsciiEnd function to remove trailing ASCII whitespace characters
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

Execution result:

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

Function: Removes leading substrings composed of ASCII whitespace characters from the original string.

ASCII whitespace characters include characters with ASCII codes in the range [0x09, 0x0D] and the character with ASCII code 0x20. Specific characters are listed in [trimAscii()](#func-trimascii).

Returns:

- [String](core_package_structs.md#struct-string) - The converted new string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create several strings for testing
    let str1 = "  Hello, World"
    let str2 = "\t\n\rHello, 世界"
    let str3 = "Hello"
    let str4 = "   \t\n\r  "
    
    // Use trimAsciiStart function to remove leading ASCII whitespace characters
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

Execution result:

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

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the end that satisfy the predicate condition, until encountering the first [Rune](./core_package_intrinsics.md#rune) character that does not satisfy the condition.

Parameters:

- predicate: ([Rune](./core_package_intrinsics.md#rune))->[Bool](./core_package_intrinsics.md#bool) - The filtering condition.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd({c => c == r'2'})
    println(subStr)
}
```

Execution Result:

```text
141
```

### func trimEnd(Array\<Rune>)

```cangjie
public func trimEnd(set: Array<Rune>): String
```

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the end that are present in the set, until encountering the first [Rune](./core_package_intrinsics.md#rune) character not in the set.

Parameters:

- set: [Array](./core_package_structs.md#struct-arrayt)\<[Rune](./core_package_intrinsics.md#rune)> - The collection of characters to be removed.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd([r'1', r'2'])
    println(subStr)
}
```

Execution Result:

```text
14
```

### func trimEnd(String)

```cangjie
public func trimEnd(set: String): String
```

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the end that are present in the set, until encountering the first [Rune](./core_package_intrinsics.md#rune) character not in the set.

Parameters:

- set: [String](./core_package_structs.md#struct-string) - The collection of characters to be removed.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    var str = "14122"
    var subStr = str.trimEnd("12")
    println(subStr)
}
```

Execution Result:

```text
14
```

### func trimStart((Rune)->Bool)

```cangjie
public func trimStart(predicate: (Rune)->Bool): String
```

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the start that satisfy the predicate condition, until encountering the first [Rune](./core_package_intrinsics.md#rune) character that does not satisfy the condition.

Parameters:

- predicate: ([Rune](./core_package_intrinsics.md#rune))->[Bool](./core_package_intrinsics.md#bool) - The filtering condition.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "123456789"
    
    // Use trimStart to remove characters from the start that satisfy the condition
    // Here we remove all leading digits less than '5'
    let trimmed = str.trimStart({c => c < r'5'})
    
    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

Execution Result:

```text
Original string: '123456789'
Trimmed string: '56789'
```

### func trimStart(Array\<Rune>)

```cangjie
public func trimStart(set: Array<Rune>): String
```

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the start that are present in the set, until encountering the first [Rune](./core_package_intrinsics.md#rune) character not in the set.

Example: "12241".trimStart([r'1', r'2']) = "41".

Parameters:

- set: [Array](./core_package_structs.md#struct-arrayt)\<[Rune](./core_package_intrinsics.md#rune)> - The collection of characters to be removed.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "12241"
    
    // Use trimStart to remove leading characters present in the array
    // Here we remove all leading '1' and '2' characters
    let trimmed = str.trimStart([r'1', r'2'])
    
    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

Execution Result:

```text
Original string: '12241'
Trimmed string: '41'
```

### func trimStart(String)

```cangjie
public func trimStart(set: String): String
```

Function: Trims the current string by removing [Rune](./core_package_intrinsics.md#rune) characters from the start that are present in the set, until encountering the first [Rune](./core_package_intrinsics.md#rune) character not in the set.

Example: "12241".trimStart("12") = "41".

Parameters:

- set: [String](./core_package_structs.md#struct-string) - The collection of characters to be removed.

Returns:

- [String](./core_package_structs.md#struct-string) - The newly trimmed string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "12241"
    
    // Use trimStart to remove leading characters present in the string
    // Here we remove all leading '1' and '2' characters
    let trimmed = str.trimStart("12")
    
    println("Original string: '${str}'")
    println("Trimmed string: '${trimmed}'")
}
```

Execution Result:

```text
Original string: '12241'
Trimmed string: '41'
```

### operator func !=(String)

```cangjie
public operator const func !=(right: String): Bool
```

Function: Determines whether two strings are not equal.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The [String](core_package_structs.md#struct-string) instance to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if not equal, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "Hello"
    let str3 = "World"
    
    // Use != operator to compare strings
    let result1 = str1 != str2
    let result2 = str1 != str3
    
    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 != str2: ${result1}")
    println("str1 != str3: ${result2}")
}
```

Execution Result:

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

Function: Repeats the original string [count](../../collection/collection_package_api/collection_package_function.md#func-counttiterablet) times.

Parameters:

- count: [Int64](core_package_intrinsics.md#int64) - The number of repetitions.

Returns:

- [String](core_package_structs.md#struct-string) - Returns the new string after repetition.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string exceeding the maximum length of [UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "Hello"
    
    // Use * operator to repeat the string
    let repeated1 = str * 3
    let repeated2 = str * 0
    let repeated3 = str * 1
    
    println("Original string: '${str}'")
    println("str * 3: '${repeated1}'")
    println("str * 0: '${repeated2}'")
    println("str * 1: '${repeated3}'")
}
```

Execution Result:

```text
Original string: 'Hello'
str * 3: 'HelloHelloHello'
str * 0: ''
str * 1: 'Hello'
```

### operator func +(String)

```cangjie
public operator const func +(right: String): String
```

Function: Concatenates two strings by appending the right string to the end of the original string.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to append.

Returns:

- [String](core_package_structs.md#struct-string) - Returns the concatenated string.

Exceptions:

- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown when attempting to construct a string exceeding the maximum length of [UInt32](./core_package_intrinsics.md#uint32).

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "World"
    let str3 = ", "
    
    // Use + operator to concatenate strings
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

Execution Result:

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
public operator const func <(right: String): Bool
```

Function: Compares two strings lexicographically.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to compare.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the original string is lexicographically smaller than right, false otherwise.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"
    
    // Use < operator to compare strings
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

Execution Result:

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
public operator const func <=(right: String): Bool
```

Function: Compares the lexicographical order of two strings.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the original string is lexicographically less than or equal to `right`, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "apple"
    let str2 = "banana"
    let str3 = "apple"
    
    // Compare strings using <= operator
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

Output:

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
public operator const func ==(right: String): Bool
```

Function: Determines whether two strings are equal.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the strings are equal, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "Hello"
    let str2 = "Hello"
    let str3 = "World"
    
    // Compare strings using == operator
    let result1 = str1 == str2
    let result2 = str1 == str3
    
    println("String 1: '${str1}'")
    println("String 2: '${str2}'")
    println("String 3: '${str3}'")
    println("str1 == str2: ${result1}")
    println("str1 == str3: ${result2}")
}
```

Output:

```text
String 1: 'Hello'
String 2: 'Hello'
String 3: 'World'
str1 == str2: true
str1 == str3: false
```

### operator func >(String)

```cangjie
public operator const func >(right: String): Bool
```

Function: Compares the lexicographical order of two strings.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the original string is lexicographically greater than `right`, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "banana"
    let str2 = "apple"
    let str3 = "banana"
    
    // Compare strings using > operator
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

Output:

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
public operator const func >=(right: String): Bool
```

Function: Compares the lexicographical order of two strings.

Parameters:

- right: [String](core_package_structs.md#struct-string) - The string to compare with.

Returns:

- [Bool](core_package_intrinsics.md#bool) - Returns true if the original string is lexicographically greater than or equal to `right`, otherwise returns false.

Example:

<!-- verify -->
```cangjie
main() {
    // Create test strings
    let str1 = "banana"
    let str2 = "apple"
    let str3 = "banana"
    
    // Compare strings using >= operator
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

Output:

```text
String 1: 'banana'
String 2: 'apple'
String 3: 'banana'
str1 >= str2: true
str2 >= str1: false
str1 >= str3: true
```

### operator func [](Int64)

```cangjie
public operator const func [](index: Int64): Byte
```

Function: Returns the UTF-8 encoded byte at the specified index.

Parameters:

- index: [Int64](core_package_intrinsics.md#int64) - The index of the UTF-8 byte to retrieve.

Returns:

- [Byte](core_package_types.md#type-byte) - The UTF-8 encoded byte at the specified index.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if index is less than 0 or greater than or equal to the string length.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "Hello, 世界"
    
    // Retrieve bytes using [] operator
    let byte1 = str[0]
    let byte2 = str[7]
    
    println("String: '${str}'")
    println("str[0]: ${byte1}")
    println("str[7]: ${byte2}")
    
    // Note: Will throw exception if index is out of bounds
    // let byte3 = str[100]  // This line would throw an exception
}
```

Output:

```text
String: 'Hello, 世界'
str[0]: 72
str[7]: 228
```

### operator func [](Range\<Int64>)

```cangjie
public operator const func [](range: Range<Int64>): String
```

Function: Returns a substring slice based on the given range.

> **Note:**
>
> 1. If the `range` parameter is constructed using the [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) constructor:
>    - The `start` value is exactly what was passed to the constructor, unaffected by the `hasStart` parameter.
>    - When `hasEnd` is false, the `end` value is ignored (regardless of the `isClosed` parameter), and the substring extends to the end of the original string.
> 2. The step size of the range must be 1.

Parameters:

- range: [Range](core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](core_package_intrinsics.md#int64)> - The range for the substring.

Returns:

- [String](core_package_structs.md#struct-string) - The substring slice.

Exceptions:

- [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) - Thrown if the range exceeds the string boundaries.
- [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) - Thrown if range.[step](#let-step) is not 1 or if range boundaries don't align with character boundaries.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a test string
    let str = "Hello, 世界"
    
    // Get substring slices using [] operator
    let slice1 = str[0..5]  // First 5 characters
    let slice2 = str[7..]   // From index 7 to end
    
    println("String: '${str}'")
    println("str[0..5]: '${slice1}'")
    println("str[7..]: '${slice2}'")
    
    // Note: Will throw exception if range is invalid
    // let slice3 = str[0..100]  // This line would throw an exception
}
```

Output:

```text
String: 'Hello, 世界'
str[0..5]: 'Hello'
str[7..]: '世界'
```