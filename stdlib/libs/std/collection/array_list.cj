/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This file defines ArrayList and related classes.
 */
package std.collection

import std.math.*

/**
 * ArrayList-based Iterator.
 *
 * @since 0.18.2
 */
class ArrayListIterator<T> <: Iterator<T> {
    private var myPosition: Int64 = 0
    private let myData: ArrayList<T>
    private let initVersion: Int64

    /**
     * Initializing ArrayListIterator.
     *
     * @param data - data of ArrayList<T>.
     * @param version - version of Int64.
     *
     * @since 0.18.2
     */
    @Frozen
    init(data: ArrayList<T>) {
        myData = data
        initVersion = data.myVersion
    }

    /**
     * Returns the next element in the iteration.
     *
     * @return Option<T>.
     *
     * @throws ConcurrentModificationException if initVersion is not equal to myData.myVersion.
     *
     * @since 0.18.2
     */
    @Frozen
    @OverflowWrapping
    public func next(): Option<T> {
        if (myData.myVersion != initVersion) {
            throw ConcurrentModificationException()
        }

        if (this.myPosition < myData.size) {
            var v: Option<T> = Some(unsafe { myData.myData.getUnchecked(myPosition) })
            this.myPosition++
            return v
        } else {
            return None
        }
    }
}

/**
 * Resizable-array implementation of the Collection.
 * Implements all Collection operations, and permits all elements, including null.
 * In addition to implementing the Collection interface, this class provides methods to manipulate the size of the array that is used to store the ArrayList.
 *
 * @since 0.18.2
 */
public class ArrayList<T> <: List<T> {
    /* Defines the ArrayList myData type as Array. */
    var myData: Array<T>

    /* Defines the ArrayList size. */
    var mySize: Int64

    /* Defines the ArrayList version. */
    var myVersion: Int64 = 0

    /* Defines the ArrayList default capacity */
    private static const DEFAULT_CAPACITY: Int64 = 16

    /* Defines the capacity of the ArrayList. */
    @Frozen
    public prop capacity: Int64 {
        get() {
            this.myData.size
        }
    }

    /**
     * Initializes an empty ArrayList with the default capacity.
     *
     * @since 0.18.2
     */
    @Frozen
    public init() {
        myData = Array<T>(DEFAULT_CAPACITY, repeat: unsafe { zeroValue<T>() })
        mySize = 0
    }

    /**
     * Initializes an empty ArrayList with the specified initial capacity.
     *
     * @param capacity incoming initialized capacity.
     * @throws IllegalArgumentException if the capacity is less than 0.
     * @since 0.18.2
     */
    @Frozen
    public init(capacity: Int64) {
        mySize = 0
        let cap: Int64 = if (capacity >= 0) {
            capacity
        } else {
            throw IllegalArgumentException("Invalid capacity of ArrayList: ${capacity}.")
        }
        myData = Array<T>(cap, repeat: unsafe { zeroValue<T>() })
    }

    /**
     * Initializes an ArrayList with the specified initial size and specified initial function.
     *
     * @param size incoming initialize size.
     * @param initElement incoming initialize initElement.
     *
     * @throws IllegalArgumentException if size is negative.
     *
     * @since 0.18.2
     */
    @Frozen
    public init(size: Int64, initElement: (Int64) -> T) {
        if (size < 0) {
            throw IllegalArgumentException("Invalid size of ArrayList: ${size}.")
        }
        myData = Array<T>(size, initElement)
        mySize = size
    }

    @Frozen
    private init(elements: Array<T>) {
        myData = elements.clone()
        mySize = elements.size
    }

    /**
     * Initializes an ArrayList with the iterable of elements initial function.
     *
     * @param  elements transfer the element type collection.
     *
     * @since 0.18.2
     */
    @Frozen
    public init(elements: Collection<T>) {
        match (elements) {
            case arr: Array<T> => myData = arr.clone()
            case _ => myData = elements.toArray()
        }
        mySize = elements.size
    }

    /**
     * Statically generate an ArrayList with the specified Array.
     *
     * @param elements input element type array.
     *
     */
    @Frozen
    public static func of(elements: Array<T>): ArrayList<T> {
        return ArrayList(elements)
    }

    /**
     * Returns the raw data of the ArrayList.
     *
     * @since 0.23.3
     *
     */
    @Frozen
    public unsafe func getRawArray(): Array<T> {
        return this.myData
    }

    /**
     * Returns the element in this ArrayList as an Array.
     *
     * @throws IndexOutOfBoundsException if "mySize" is out of bound.
     */
    @Frozen
    public func toArray(): Array<T> {
        if (mySize == 0) {
            return Array<T>()
        }

        let newArr: Array<T> = Array<T>(mySize, repeat: unsafe { zeroValue<T>() })
        this.myData.copyTo(newArr, 0, 0, mySize)
        return newArr
    }

    /**
     * Gets the element at the specified location in this ArrayList.
     *
     * @param index indicates the index of the get interface.
     * @return the T type of value.
     *
     * @since 0.18.2
     */
    @Frozen
    public func get(index: Int64): ?T {
        if (index >= mySize || index < 0) {
            return Option<T>.None
        }
        return myData.get(index)
    }

    @Frozen
    public prop first: ?T {
        get() {
            get(0)
        }
    }

    @Frozen
    public prop last: ?T {
        get() {
            get(mySize - 1)
        }
    }

    /**
     * Appends the specified element to the next index of the element at the end of the ArrayList
     *
     * @param element the type of the inserted element is T.
     *
     */
    @Frozen
    public func add(element: T): Unit {
        if (mySize == myData.size) {
            grow(mySize + 1)
        }
        myData[mySize] = element
        mySize++
        myVersion++
    }

    /**
     * Adds all elements in the specified collection after the end element of this ArrayList.
     *
     * @param elements import elements of the collection type and insert them one by one.
     * @throws ConcurrentModificationException if there are some system errors.
     */
    @Frozen
    public func add(all!: Collection<T>): Unit {
        let cSize: Int64 = all.size
        if (cSize <= 0) {
            return
        }

        if (mySize + cSize > myData.size) {
            grow(mySize + cSize)
        }

        match (all) {
            case arr: Array<T> => arr.copyTo(myData, 0, mySize, cSize)
            case arr: ArrayList<T> => arr.myData.copyTo(myData, 0, mySize, cSize)
            case _ =>
                let arr = all.toArray()
                arr.copyTo(myData, 0, mySize, cSize)
        }
        mySize = mySize + cSize
        myVersion++
    }

    /**
     * Inserts the specified element at the specified position in this ArrayList.
     *
     * @param index the index of the element to insert.
     * @param element the element to insert is of type T.
     * @throws IndexOutOfBoundsException if index is out of range.
     * @since 0.18.2
     */
    @Frozen
    @OverflowWrapping
    public func add(element: T, at!: Int64): Unit {
        checkRangeInsert(at)
        if (mySize == myData.size) {
            var newCapacity: Int64 = max(mySize + (mySize >> 1), mySize + 1)
            let newArr: Array<T> = Array<T>(newCapacity, repeat: unsafe { zeroValue<T>() })
            myData.copyTo(newArr, 0, 0, at)
            myData.copyTo(newArr, at, at + 1, mySize - at)
            myData = newArr
        } else {
            myData.copyTo(myData, at, at + 1, mySize - at)
        }

        myData[at] = element
        mySize++
        myVersion++
    }

    /**
     * Inserts all of the elements in the specified Collection into this ArrayList, starting at the specified position.
     *
     * @param index the index of the element to insert.
     * @param elements the collection type element to insert.
     * @throws IndexOutOfBoundsException if index is out of bounds.
     * @since 0.18.2
     */
    @Frozen
    @OverflowWrapping
    public func add(all!: Collection<T>, at!: Int64): Unit {
        checkRangeInsert(at)
        let cSize: Int64 = all.size
        if (cSize <= 0) {
            return
        }

        if (mySize + cSize > myData.size) {
            var newCapacity: Int64 = max(mySize + (mySize >> 1), mySize + cSize)
            let newArray: Array<T> = Array<T>(newCapacity, repeat: unsafe { zeroValue<T>() })
            myData.copyTo(newArray, 0, 0, at)
            myData.copyTo(newArray, at, at + cSize, mySize - at)
            myData = newArray
        } else {
            myData.copyTo(myData, at, at + cSize, mySize - at)
        }

        match (all) {
            case arr: Array<T> => arr.copyTo(myData, 0, at, cSize)
            case arr: ArrayList<T> => arr.myData.copyTo(myData, 0, at, cSize)
            case _ =>
                let arr = all.toArray()
                arr.copyTo(myData, 0, at, cSize)
        }
        mySize = mySize + cSize
        myVersion++
    }

    /**
     * Removes an element at the specified location from this ArrayList.
     *
     * @param index remove an Index of an Element.
     * @throws IndexOutOfBoundsException if index is out of range.
     * @since 0.18.2
     */
    @Frozen
    public func remove(at!: Int64): T {
        checkRange(at)
        let len: Int64 = mySize - at - 1
        let removed = myData[at]
        myData.copyTo(myData, at + 1, at, len)
        myData[mySize - 1] = unsafe { zeroValue<T>() }
        mySize--
        myVersion++
        return removed
    }

    /**
     * Removes multiple elements at the specified location from this ArrayList.
     *
     * @param range indexs of element to remove
     *
     * @throws IllegalArgumentException if range.step is not equal to 1.
     * @throws IndexOutOfBoundsException if range.start or range.end is less than zero, or range.end is greater than mySize.
     *
     * @since 0.31.3
     */
    @Frozen
    public func remove(range: Range<Int64>): Unit {
        if (range.step != 1) {
            throw IllegalArgumentException("the value of the step should be r'1'")
        }

        var start: Int64 = range.start
        var end: Int64 = range.end
        if (range.isClosed) {
            end = end + 1
        }

        // If end is omitted, end = size of this ArrayList.
        if (!range.hasEnd) {
            end = this.mySize
        }
        // If start is omitted, start = 0.
        if (!range.hasStart) {
            start = 0
        }
        // If start >= end, do nothing.
        if (start >= end) {
            return
        }
        if (start < 0 || end < 0 || end > this.mySize) {
            throw IndexOutOfBoundsException(
                "The size of ArrayList is ${this.size}, but the start is ${start} and the end is ${end}.")
        }

        let moveLen = this.mySize - end
        let removeLen = end - start
        this.myData.copyTo(this.myData, end, start, moveLen)
        for (i in 0..removeLen) {
            this.myData[mySize - i - 1] = unsafe { zeroValue<T>() }
        }
        mySize = mySize - removeLen
        myVersion++
    }

    /**
     * Removes all of the elements of this ArrayList that satisfy the given predicate.
     *
     * @param predicate transfer the condition for determining the deletion.
     *
     * @since 0.18.2
     */
    @Frozen
    public func removeIf(predicate: (T) -> Bool): Unit {
        var i: Int64 = 0
        for (j in 0..mySize) {
            var item = myData[j]
            let lockVersion = myVersion
            let needDelete = predicate(item)
            if (myVersion != lockVersion) {
                throw ConcurrentModificationException("The predicate cannot contain a modify operation.")
            }

            if (!needDelete) {
                if (i != j) {
                    myData[i] = item
                }
                i++
            }
        }

        if (i < mySize) {
            for (j in i..mySize) {
                myData[j] = unsafe { zeroValue<T>() }
            }
        }
        mySize = i
        myVersion++
    }

    /**
     * Removes all of the elements from this ArrayList.
     *
     * @since 0.18.2
     *
     */
    @Frozen
    public func clear(): Unit {
        if (mySize > 0) {
            let zero: T = unsafe { zeroValue<T>() }
            /* Back-to-front traversal can reduce boundary checks and improve performance */
            for (i in mySize - 1..=0 : -1) {
                myData[i] = zero
            }
            mySize = 0
        }
        myVersion++
    }

    /**
     * @description Extracts elements from the ArrayList at the specified interval and returns a new ArrayList.
     * 
     * @param count the selected interval.
     * @returns a new ArrayList containing all elements extracted from the source ArrayList at intervals.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func step(count: Int64): ArrayList<T> {
        if (count <= 0) {
            throw IllegalArgumentException("Step count must be greater than 0!")
        }

        if (mySize <= 0) {
            return ArrayList<T>()
        }

        let newSize: Int64 = (mySize + count - 1) / count
        var newData: Array<T> = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })
        let oldLastIndex: Int64 = (newSize - 1) * count
        var j: Int64 = newSize - 1
        for (i in oldLastIndex..=0 : -count) {
            newData[j] = myData[i]
            j--
        }
        return ArrayList<T>(newData)
    }

    /**
     * @description Extracts a specific number of elements from the array and returns a new array.
     * 
     * @param the number of elements to take.
     * @returns a new ArrayList with the specified number of elements taken.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func take(count: Int64): ArrayList<T> {
        if (count == 0) {
            return ArrayList<T>()
        }

        if (count < 0) {
            throw IllegalArgumentException("take count must be greater than 0!")
        }
        let newSize = min(count, mySize)

        var newData: Array<T> = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })
        myData.copyTo(newData, 0, 0, newSize)
        return ArrayList<T>(newData)
    }

    /**
     * @description Skips a specific number of elements and returns a new ArrayList.
     * 
     * @param count the number of elements to skip.
     * @returns a new ArrayList with the specified number of elements skipped.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func skip(count: Int64): ArrayList<T> {
        if (count < 0) {
            throw IllegalArgumentException("skip count must be greater than 0!")
        }
        if (count == 0) {
            var newData: Array<T> = myData.clone()
            return ArrayList<T>(newData)
        }
        if (mySize - count <= 0) {
            return ArrayList<T>()
        }

        var newData: Array<T> = Array<T>(mySize - count, repeat: unsafe { zeroValue<T>() })
        myData.copyTo(newData, count, 0, mySize - count)
        return ArrayList<T>(newData)
    }

    /**
     * @description Returns a new ArrayList<T> containing elements that satisfy the filtering condition.
     * 
     * @param predicate the given condition.
     * @returns a new collection containing elements that satisfy the filtering condition.
     */
    @When[env != "ohos"]
    public func filter(predicate: (T) -> Bool): ArrayList<T> {
        if (mySize == 0) {
            return ArrayList<T>()
        }
        var newData: Array<T> = Array<T>(mySize, repeat: unsafe { zeroValue<T>() })
        var j = 0;
        for (i in 0..mySize) {
            if (predicate(myData[i])) {
                newData[j] = myData[i]
                j++
            }
        }
        return ArrayList<T>(newData.slice(0, j))
    }

    /**
     * @description Performs mapping on this ArrayList and returns a new ArrayList.
     * 
     * @param transform the given mapping function.
     * @returns a new ArrayList.
     */
    @When[env != "ohos"]
    public func map<R>(transform: (T) -> R): ArrayList<R> {
        if (mySize == 0) {
            return ArrayList<R>()
        }
        var newData: Array<R> = Array<R>(mySize, repeat: unsafe { zeroValue<R>() })
        for (i in mySize - 1..=0 : -1) {
            newData[i] = transform(myData[i])
        }
        return ArrayList<R>(newData)
    }

    /**
     * @description Performs filtering and mapping operations simultaneously, returning a new ArrayList.
     * 
     * @param transform the given mapping function.
     * @returns a new ArrayList after filtering and mapping.
     */
    @When[env != "ohos"]
    public func flatMap<R>(transform: (T) -> ArrayList<R>): ArrayList<R> {
        var newList: ArrayList<R> = ArrayList<R>()
        for (i in 0..mySize) {
            var tempData = transform(myData[i])
            newList.add(all: tempData)
        }
        return newList
    }

    /**
     * @description Applies a transformation closure (transform) to each element in the ArrayList, where the closure returns a new ArrayList
                    then "flattens" and concatenates all returned ArrayList into a single result ArrayList.
     * 
     * @param transform the given mapping function.
     * @returns the new ArrayList after being "mapped" and "flattened".
     */
    @When[env != "ohos"]
    public func filterMap<R>(transform: (T) -> ?R): ArrayList<R> {
        if (mySize == 0) {
            return ArrayList<R>()
        }
        var newData: Array<R> = Array<R>(mySize, repeat: unsafe { zeroValue<R>() })
        var j = 0;
        for (i in 0..mySize) {
            match (transform(myData[i])) {
                case Some(v) =>
                    newData[j] = v
                    j++
                case None => continue
            }
        }
        return ArrayList<R>(newData.slice(0, j))
    }

    /**
     * @description Returns a new ArrayList with the given new element inserted between every two elements.
     * 
     * @param separator the given element.
     * @returns a new ArrayList.
     */
    @When[env != "ohos"]
    public func intersperse(separator: T): ArrayList<T> {
        if (mySize < 2) {
            var newData: Array<T> = myData.clone()
            return ArrayList<T>(newData)
        }
        let newSize: Int64 = 2 * mySize - 1
        var newData: Array<T> = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })
        for (i in 0..mySize - 1) {
            newData[2 * i] = myData[i]
            newData[2 * i + 1] = separator
        }
        newData[newSize - 1] = myData[mySize - 1]
        return ArrayList<T>(newData)
    }

    /**
     * @description Iterates over all elements and performs the given operation.
     * 
     * @param action the given operation function.
     */
    @When[env != "ohos"]
    public func forEach(action: (T) -> Unit): Unit {
        for (i in 0..mySize) {
            action(myData[i])
        }
    }

    /**
     * @description Determine whether all elements in the ArrayList satisfy the condition.
     * 
     * @param predicate the given condition.
     * @returns true if all elements in the ArrayList satisfy the condition, otherwise returns false.
     */
    @When[env != "ohos"]
    public func all(predicate: (T) -> Bool): Bool {
        for (i in 0..mySize) {
            if (!predicate(myData[i])) {
                return false
            }
        }
        return true
    }

    /**
     * @description Determine whether there is any element in the ArrayList that satisfies the condition.
     * 
     * @param predicate the given condition.
     * @returns Whether there is any element that satisfies the condition.
     */
    @When[env != "ohos"]
    public func any(predicate: (T) -> Bool): Bool {
        for (i in 0..mySize) {
            if (predicate(myData[i])) {
                return true
            }
        }
        return false
    }

    /**
     * @description Determine whether all elements in the ArrayList do not satisfy the condition.
     * 
     * @param predicate the given condition.
     * @returns Whether all elements in the current ArrayList do not satisfy the condition.
     */
    @When[env != "ohos"]
    public func none(predicate: (T) -> Bool): Bool {
        for (i in 0..mySize) {
            if (predicate(myData[i])) {
                return false
            }
        }
        return true
    }

    /**
     * @description Computes from left to right using the specified initial value.
     * 
     * @param initial the given initial value of type R.
     * @param operation the given computation function.
     * @returns the final computed value.
     */
    @When[env != "ohos"]
    public func fold<R>(initial: R, operation: (R, T) -> R): R {
        var result: R = initial
        for (i in 0..mySize) {
            result = operation(result, myData[i])
        }
        return result
    }

    /**
     * @description Compute from left to right using the first element as the initial value.
     * 
     * @param operation the given computation function.
     * @returns the final computed value.
     */
    @When[env != "ohos"]
    public func reduce(operation: (T, T) -> T): Option<T> {
        if (mySize == 0) {
            return None<T>
        }
        var result: T = myData[0]
        for (i in 1..mySize) {
            result = operation(result, myData[i])
        }
        return result
    }

    /**
     * Reserves capacity for at least additional more elements to be inserted in this ArrayList.
     *
     * @param additional ensure that there is sufficient capacity. additional indicates the quantity to be added.
     *
     * @since 0.18.2
     */
    @Frozen
    public func reserve(additional: Int64): Unit {
        if (myData.size - mySize >= additional) {
            return
        }

        grow(mySize + additional)
        myVersion++
    }

    /**
     * Incoming Sort by Condition.
     *
     * @param comparator transfer the condition to be judged.
     * @param stable Whether to use stable sorting.
     *
     * @since 0.27.3
     */
    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, by!: (T, T) -> Ordering, stable!: Bool = false, descending!: Bool = false): Unit` in std.sort instead."]
    public func sortBy(stable!: Bool, comparator!: (T, T) -> Ordering): Unit {
        if (stable) {
            stableSort(this.myData[0..this.size], comparator)
        } else {
            unstableSort(this.myData[0..this.size], comparator)
        }
        myVersion++
    }

    /**
     * Incoming Sort by Condition.
     *
     * @param comparator transfer the condition to be judged.
     *
     * @since 0.27.3
     */
    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, by!: (T, T) -> Ordering, stable!: Bool = false, descending!: Bool = false): Unit` in std.sort instead."]
    public func sortBy(comparator!: (T, T) -> Ordering): Unit {
        unstableSort(this.myData[0..this.size], comparator)
        myVersion++
    }

    /**
     * Reverses the order of the elements in this ArrayList.
     *
     * @since 0.18.2
     *
     */
    @Frozen
    public func reverse(): Unit {
        var i: Int64 = 0
        var j: Int64 = mySize - 1
        while (i < j) {
            let tempJ: T = myData[j]
            myData[j] = myData[i]
            myData[i] = tempJ
            i++
            j--
        }
        myVersion++
    }

    /**
     * Operator overload slice.
     *
     * @param range transfer the range for the slice.
     *
     * @throws IllegalArgumentException if the step of range is not 1.
     * @throws IndexOutOfBoundsException if range is invalid.
     * @since 0.18.2
     *
     */
    @Frozen
    public operator func [](range: Range<Int64>): ArrayList<T> {
        return this.slice(range)
    }

    /**
     * The input parameter range is used as the index and the ArrayList corresponding to the index is returned.
     *
     * @param range transfer the range for the slice.
     *
     * @throws IllegalArgumentException if the step of range is not 1.
     * @throws IndexOutOfBoundsException if range is invalid.
     * @since 0.18.2
     */
    @Frozen
    public func slice(range: Range<Int64>): ArrayList<T> {
        return ArrayList<T>(rangeSlice(this.myData, range, this.size))
    }

    /**
     * @throws IllegalArgumentException if the step of range is not 1.
     * @throws IndexOutOfBoundsException if range is invalid.
     */
    @Frozen
    private func rangeSlice(arr: Array<T>, range: Range<Int64>, size: Int64): Array<T> {
        if (range.step != 1) {
            throw IllegalArgumentException("Illegal step ${range.step}, step should be 1.")
        }

        let start = if (range.hasStart) {
            range.start
        } else {
            0
        }

        if (start > size) {
            throw IndexOutOfBoundsException("Range start ${start} is greater than the size ${size}.")
        } else if (range.start < 0) {
            throw IndexOutOfBoundsException("Range start ${start} is less than 0.")
        }

        let end: Int64

        if (range.hasEnd) {
            if (range.isClosed) {
                if (range.end > size) {
                    throw IndexOutOfBoundsException(
                        "The closed end of the range ${range.end} is greater than or equal to the size ${size}.")
                }
                end = range.end + 1
            } else {
                if (range.end > size) {
                    throw IndexOutOfBoundsException(
                        "The opened end of the range ${range.end} is greater than the size ${size}.")
                }
                end = range.end
            }
        } else {
            end = size
        }

        if (start > end) {
            throw IndexOutOfBoundsException("The start ${start} is greater than the end ${end}.")
        }

        return arr[start..end]
    }

    /**
     * Clone a new ArrayList.
     *
     * @return new ArrayList
     *
     * @since 0.18.2
     */
    @Frozen
    public func clone(): ArrayList<T> {
        return ArrayList<T>(this)
    }

    /**
     * Operator overload get.
     * An exception is reported when no index exists.
     *
     * @param index indicates the index of the get interface.
     * @return the T type of value.
     * @throws IndexOutOfBoundsException if index is out of range.
     * @since 0.18.2
     */
    @Frozen
    public operator func [](index: Int64): T {
        checkRange(index)
        return this.myData[index]
    }

    /**
     * Operator overload set.
     * An exception is reported when no index exists.
     *
     * @param index Index value to be set.
     * @param value the T type of element.
     *
     * @since 0.18.2
     */
    @Frozen
    public operator func [](index: Int64, value!: T): Unit {
        if (index >= mySize || index < 0) {
            throw IndexOutOfBoundsException(
                "index: ${index} cannot be less than 0 or greater than the arraylist size: ${mySize}.")
        }
        unsafe { myData.setUnchecked(index, value) }
    }

    /**
     * Returns an iterator over the elements in this ArrayList in proper Collection.
     *
     * @return Iterator<T>.
     *
     * @since 0.18.2
     */
    @Frozen
    public func iterator(): Iterator<T> {
        return ArrayListIterator<T>(this)
    }

    /**
     * Check whether the size is empty. If yes, true is returned. Otherwise, false is returned.
     *
     * @return If this size is empty, true is returned. Otherwise, false is returned.
     *
     * @since 0.18.2
     */
    @Frozen
    public func isEmpty(): Bool {
        return mySize == 0
    }

    /**
     * Returns the number of elements in this ArrayList.
     *
     * @return the size.
     *
     * @since 0.18.2
     */
    @Frozen
    public prop size: Int64 {
        get() {
            return mySize
        }
    }

    /*
     * Check whether the size range is as expected.
     *
     * @param index pass in the index to be checked.
     *
     * @throws IndexOutOfBoundsException if index is less than zero or index is greater than or equal to Array size.
     *
     * @since 0.18.2
     */
    @Frozen
    private func checkRange(index: Int64): Unit {
        if (index >= mySize || index < 0) {
            throw IndexOutOfBoundsException("index: ${index}, size: ${mySize}")
        }
    }

    /*
     * Check whether the size range is as expected.
     *
     * @param index pass in the index to be checked.
     *
     * @throws IndexOutOfBoundsException if index is less than zero or index is greater than Array size.
     *
     * @since 0.18.2
     */
    @Frozen
    private func checkRangeInsert(index: Int64): Unit {
        if (index > mySize || index < 0) {
            throw IndexOutOfBoundsException("index: ${index}, size: ${mySize}")
        }
    }

    /*
     * grow capacity.
     *
     * @param minCapacity - minCapacity of Int64.
     *
     * @since 0.18.2
     */
    @Frozen
    private func grow(minCapacity: Int64, startIndex!: Int64 = 0): Unit {
        let oldCapacity: Int64 = myData.size
        var newCapacity: Int64 = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity
        }
        let newArr: Array<T> = Array<T>(newCapacity, repeat: unsafe { zeroValue<T>() })
        myData.copyTo(newArr, 0, startIndex, mySize)
        myData = newArr
    }

    protected func updateVersion(): Unit {
        myVersion++
    }
}

/**
 * The `ArrayList` conforms `Equatable` interface where `T` is `Equatable`
 *
 * @since 0.18.2
 */
extend<T> ArrayList<T> <: Equatable<ArrayList<T>> where T <: Equatable<T> {
    /** overloaded determination == method. */
    @Frozen
    public operator func ==(other: ArrayList<T>): Bool {
        if (this.size != other.size) {
            return false
        }
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in this.size - 1..=0 : -1) {
            if (unsafe { this.myData.getUnchecked(i) != other.myData.getUnchecked(i) }) {
                return false
            }
        }
        return true
    }

    /** overloaded determination != method. */
    @Frozen
    public operator func !=(other: ArrayList<T>): Bool {
        return !(this == other)
    }

    @Frozen
    public func contains(element: T): Bool {
        if (this.size == 0) {
            return false
        }

        for (i in this) {
            if (i == element) {
                return true
            }
        }

        return false
    }
}

extend<T> ArrayList<T> where T <: Comparable<T> {
    /**
     * Sort data in ascending order.
     *
     * @param stable Whether to use stable sorting
     *
     * @since 0.27.3
     */
    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, stable!: Bool = false, descending!: Bool = false): Unit where T <: Comparable<T>` in std.sort instead."]
    public func sort(stable!: Bool): Unit {
        this.sortBy(stable: stable) {lhs: T, rhs: T => lhs.compare(rhs)}
    }

    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, stable!: Bool = false, descending!: Bool = false): Unit where T <: Comparable<T>` in std.sort instead."]
    public func sort(): Unit {
        this.sortBy() {lhs: T, rhs: T => lhs.compare(rhs)}
    }

    /**
     * Sort data in descending order.
     *
     * @param stable Whether to use stable sorting
     *
     * @since 0.27.3
     */
    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, stable!: Bool = false, descending!: Bool = false): Unit where T <: Comparable<T>` in std.sort instead."]
    public func sortDescending(stable!: Bool): Unit {
        this.sortBy(stable: stable) {lhs: T, rhs: T => rhs.compare(lhs)}
    }

    @Frozen
    @Deprecated[message: "Use global function `public func sort<T>(data: ArrayList<T>, stable!: Bool = false, descending!: Bool = false): Unit where T <: Comparable<T>` in std.sort instead."]
    public func sortDescending(): Unit {
        this.sortBy() {lhs: T, rhs: T => rhs.compare(lhs)}
    }
}

extend<T> ArrayList<T> <: ToString where T <: ToString {
    @Frozen
    public func toString(): String {
        return collectionToString<ArrayList<T>, T>(this)
    }
}

extend<T> ArrayList<T> {
    /**
     * @description Merges two ArrayList into a new ArrayList (the length depends on the shorter ArrayList).
     * 
     * @param other one of the ArrayList to be merged.
     * @returns a new ArrayList.
     */
    @When[env != "ohos"]
    public func zip<R>(other: ArrayList<R>): ArrayList<(T, R)> {
        let newSize: Int64 = min(mySize, other.size)
        if (newSize == 0) {
            return ArrayList<(T, R)>()
        }
        var newData: Array<(T, R)> = Array<(T, R)>(newSize, repeat: unsafe { zeroValue<(T, R)>() })
        for (i in newSize - 1..=0 : -1) {
            newData[i] = (myData[i], other[i])
        }
        return ArrayList<(T, R)>(newData)
    }

    /**
     * @description Used to obtain an ArrayList with indices.
     * 
     * @returns a new ArrayList with indices.
     */
    @When[env != "ohos"]
    public func enumerate(): ArrayList<(Int64, T)> {
        if (mySize == 0) {
            return ArrayList<(Int64, T)>()
        }
        var newData: Array<(Int64, T)> = Array<(Int64, T)>(mySize, repeat: unsafe { zeroValue<(Int64, T)>() })
        for (i in mySize - 1..=0 : -1) {
            newData[i] = (i, myData[i])
        }
        return ArrayList<(Int64, T)>(newData)
    }
}

@Frozen
func collectionToString<C, T>(col: C): String where C <: Collection<T>, T <: ToString {
    if (col.size == 0) {
        return "[]"
    }

    let sb = StringBuilder("[")
    let it = col.iterator()
    var tmp: T = it.next().getOrThrow()
    while (let Some(next) <- it.next()) {
        sb.append(tmp)
        unsafe { sb.appendFromUtf8Unchecked(", ".toArray()) }
        tmp = next
    }
    sb.append(tmp)
    sb.append(r']')
    return sb.toString()
}

@Frozen
func max(a: Int64, b: Int64): Int64 {
    return if (a >= b) {
        a
    } else {
        b
    }
}

func stableSort<T>(data: Array<T>, compare: (T, T) -> Ordering): Unit {
    if (data.size < 2) {
        return
    }
    data.timSort(compare)
}
// Temporary code, deleted when @Deprecated ends
extend<T> Array<T> {
    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    private func shortSort(start: Int64, finish: Int64, compare: (T, T) -> Ordering): Unit {
        let span = this.size
        if (span <= 8) {
            if (span <= 1) {
                return
            } else if (span == 2) {
                this.compareSwap2(start, finish, compare)
            } else if (span == 3) {
                this.compareSwap3(start, start + 1, finish, compare)
            } else {
                insertionSort(start, finish, compare)
            }
        } else {
            var scratch = TempArray(span, this[start])
            let runLength = getSequenceLength(start, finish, scratch, compare)
            if (runLength == span) {
                return
            }
            binaryInsertionSort(start, finish, compare, runLength)
        }
    }

    @OverflowWrapping
    private func maybeMerge(
        runStarts: Array<Int64>,
        runLengths: Array<Int64>,
        runTop: Int64,
        scratch: TempArray<T>,
        compare: (T, T) -> Ordering
    ): Int64 {
        var index: Int64 = runTop
        while (index > 0) {
            var runLength: Int64 = index - 1
            let currentStart = runStarts[runLength]
            let nextStart = runStarts[runLength + 1]
            let currentLength = runLengths[runLength]
            let nextLength = runLengths[runLength + 1]
            if (runLength == 0) {
                if (currentLength <= nextLength) {
                    this.merge(currentStart, currentLength, nextStart, nextLength, scratch, compare)
                    runLengths[runLength] = currentLength + nextLength
                    index--
                }
                break
            }

            let selected = runStarts[runLength - 1]
            let leftBound = runLengths[runLength - 1]
            if (leftBound <= currentLength + nextLength) {
                if (leftBound < nextLength) {
                    this.merge(selected, leftBound, currentStart, currentLength, scratch, compare)
                    runLengths[runLength - 1] = leftBound + currentLength
                    runStarts[runLength] = nextStart
                    runLengths[runLength] = nextLength
                    index--
                } else {
                    this.merge(currentStart, currentLength, nextStart, nextLength, scratch, compare)
                    runLengths[runLength] = currentLength + nextLength
                    index--
                }
            } else if (currentLength <= nextLength) {
                this.merge(currentStart, currentLength, nextStart, nextLength, scratch, compare)
                runLengths[runLength] = currentLength + nextLength
                index--
            } else {
                break
            }
        }
        return index
    }

    @OverflowWrapping
    private func mergeAll(
        runStarts: Array<Int64>,
        runLengths: Array<Int64>,
        runTop: Int64,
        scratch: TempArray<T>,
        compare: (T, T) -> Ordering
    ): Unit {
        var index: Int64 = runTop
        while (index > 0) {
            var runLength: Int64 = index - 1
            let currentStart = runStarts[runLength]
            let nextStart = runStarts[runLength + 1]
            let currentLength = runLengths[runLength]
            let nextLength = runLengths[runLength + 1]
            if (runLength == 0) {
                this.merge(currentStart, currentLength, nextStart, nextLength, scratch, compare)
                break
            }

            let selected = runStarts[runLength - 1]
            let leftBound = runLengths[runLength - 1]
            if (leftBound < nextLength) {
                this.merge(selected, leftBound, currentStart, currentLength, scratch, compare)
                runLengths[runLength - 1] = leftBound + currentLength
                runStarts[runLength] = nextStart
                runLengths[runLength] = nextLength
                index--
            } else {
                this.merge(currentStart, currentLength, nextStart, nextLength, scratch, compare)
                runLengths[runLength] = currentLength + nextLength
                index--
            }
        }
    }

    @OverflowWrapping
    private func merge(
        start1: Int64,
        len1: Int64,
        start2: Int64,
        len2: Int64,
        scratch: TempArray<T>,
        compare: (T, T) -> Ordering
    ): Unit {
        var s1 = start1
        var l1 = len1
        var s2 = start2
        var l2 = len2
        var lt = this.queryLT(this[s1 + l1 - 1], s2, l2, compare, true)
        l2 = lt - s2
        if (l2 == 0) {
            return
        }

        var gt = this.queryGT(this[s2], s1, l1, compare, false)
        l1 = l1 - (gt - s1)
        s1 = gt
        if (l1 == 0) {
            return
        }

        if (l1 == 1) {
            let t0 = this[s1]
            this.copyTo(this, s2, s2 - 1, l2)
            this[s1 + l2] = t0
        } else if (l2 == 1) {
            let t0 = this[s2]
            this.copyTo(this, s1, s1 + 1, l1)
            this[s1] = t0
        } else if (l1 <= l2) {
            mergeFromLeft(s1, l1, s2, l2, scratch, compare)
        } else {
            mergeFromRight(s1, l1, s2, l2, scratch, compare)
        }
    }

    @OverflowWrapping
    private func mergeFromLeft(
        start1: Int64,
        len1: Int64,
        start2: Int64,
        len2: Int64,
        scratch: TempArray<T>,
        compare: (T, T) -> Ordering
    ) {
        let buffer = scratch.getArray(len1)
        this.copyTo(buffer, start1, 0, len1)
        var ti = start1
        var s1 = 0
        var l1 = len1
        var s2 = start2
        var l2 = len2
        this[ti] = this[s2]
        ti++
        s2++
        l2--
        var c1 = 0
        var c2 = 0
        var shouldStopPartition = false
        while (true) {
            c1 = 0
            c2 = 0
            shouldStopPartition = false
            var savedFirst = buffer[s1]
            var savedSecond = this[s2]
            while (true) {
                match (compare(savedFirst, savedSecond)) {
                    case GT =>
                        this[ti] = savedSecond
                        ti++
                        s2++
                        l2--
                        c2++
                        c1 = 0
                        if (l2 == 0) {
                            shouldStopPartition = true
                            break
                        }
                        if (c2 > 4) {
                            break
                        }

                        savedSecond = this[s2]
                    case _ =>
                        this[ti] = savedFirst
                        ti++
                        s1++
                        l1--
                        c1++
                        c2 = 0
                        if (l1 == 1) {
                            shouldStopPartition = true
                            break
                        }
                        if (c1 > 4) {
                            break
                        }

                        savedFirst = buffer[s1]
                }
            }
            if (shouldStopPartition) {
                break
            }
            shouldStopPartition = false
            while (true) {
                var candidate = this[s2]
                c1 = buffer.queryGT(candidate, s1, l1, compare, false) - s1
                match (c1) {
                    case 0 => this[ti] = candidate
                    case 1 =>
                        this[ti] = buffer[s1]
                        this[ti + 1] = candidate
                    case 2 =>
                        this[ti] = buffer[s1]
                        this[ti + 1] = buffer[s1 + 1]
                        this[ti + 2] = candidate
                    case _ =>
                        buffer.copyTo(this, s1, ti, c1)
                        this[ti + c1] = candidate
                }
                ti = ti + c1 + 1
                s1 += c1
                l1 -= c1
                s2++
                l2--
                if (l1 == 1 || l2 == 0) {
                    shouldStopPartition = true
                    break
                }
                candidate = buffer[s1]
                c2 = this.queryLT(candidate, s2, l2, compare, false) - s2
                match (c2) {
                    case 0 => this[ti] = candidate
                    case 1 =>
                        this[ti] = this[s2]
                        this[ti + 1] = candidate
                    case 2 =>
                        this[ti] = this[s2]
                        this[ti + 1] = this[s2 + 1]
                        this[ti + 2] = candidate
                    case _ =>
                        this.copyTo(this, s2, ti, c2)
                        this[ti + c2] = candidate
                }
                ti = ti + c2 + 1
                s2 += c2
                l2 -= c2
                s1++
                l1--
                if (l2 == 0 || l1 == 1) {
                    shouldStopPartition = true
                    break
                }
                if (c1 < 4 || c2 < 4) {
                    break
                }
            }
            if (shouldStopPartition) {
                break
            }
        }
        if (l2 == 0) {
            buffer.copyTo(this, s1, ti, l1)
        }
        if (l1 == 1) {
            this.copyTo(this, s2, ti, l2)
            this[ti + l2] = buffer[s1]
        }
    }

    @OverflowWrapping
    private func mergeFromRight(
        start1: Int64,
        len1: Int64,
        start2: Int64,
        len2: Int64,
        scratch: TempArray<T>,
        compare: (T, T) -> Ordering
    ) {
        let buffer = scratch.getArray(len2)
        this.copyTo(buffer, start2, 0, len2)
        var ti = start2 + len2 - 1
        var s1 = start1 + len1 - 1
        var l1 = len1
        var s2 = len2 - 1
        var l2 = len2
        this[ti] = this[s1]
        ti--
        s1--
        l1--
        var c1 = 0
        var c2 = 0
        var shouldStopPartition = false
        while (true) {
            c1 = 0
            c2 = 0
            shouldStopPartition = false
            var savedFirst = this[s1]
            var savedSecond = buffer[s2]
            while (true) {
                match (compare(savedFirst, savedSecond)) {
                    case GT =>
                        this[ti] = savedFirst
                        ti--
                        s1--
                        l1--
                        c1++
                        c2 = 0
                        if (l1 == 0) {
                            shouldStopPartition = true
                            break
                        }
                        if (c1 > 4) {
                            break
                        }

                        savedFirst = this[s1]
                    case _ =>
                        this[ti] = savedSecond
                        ti--
                        s2--
                        l2--
                        c2++
                        c1 = 0
                        if (l2 == 1) {
                            shouldStopPartition = true
                            break
                        }
                        if (c2 > 4) {
                            break
                        }
                        savedSecond = buffer[s2]
                }
            }
            if (shouldStopPartition) {
                break
            }
            shouldStopPartition = false
            while (true) {
                var candidate = this[s1]
                let lt = buffer.queryLT(candidate, 0, l2, compare, true)
                c2 = l2 - lt
                match (c2) {
                    case 0 => this[ti] = candidate
                    case 1 =>
                        this[ti] = buffer[s2]
                        this[ti - 1] = candidate
                    case 2 =>
                        this[ti] = buffer[s2]
                        this[ti - 1] = buffer[s2 - 1]
                        this[ti - 2] = candidate
                    case _ =>
                        buffer.copyTo(this, lt, ti - c2 + 1, c2)
                        this[ti - c2] = candidate
                }
                ti = ti - c2 - 1
                s2 -= c2
                l2 -= c2
                s1--
                l1--
                if (l2 == 1 || l1 == 0) {
                    shouldStopPartition = true
                    break
                }
                candidate = buffer[s2]
                let gt = this.queryGT(candidate, start1, l1, compare, true)
                c1 = s1 - gt + 1
                match (c1) {
                    case 0 => this[ti] = candidate
                    case 1 =>
                        this[ti] = this[s1]
                        this[ti - 1] = candidate
                    case 2 =>
                        this[ti] = this[s1]
                        this[ti - 1] = this[s1 - 1]
                        this[ti - 2] = candidate
                    case _ =>
                        this.copyTo(this, gt, ti - c1 + 1, c1)
                        this[ti - c1] = candidate
                }
                ti = ti - c1 - 1
                s1 -= c1
                l1 -= c1
                s2--
                l2--
                if (l1 == 0 || l2 == 1) {
                    shouldStopPartition = true
                    break
                }
                if (c1 < 4 || c2 < 4) {
                    break
                }
            }
            if (shouldStopPartition) {
                break
            }
        }
        if (l1 == 0) {
            buffer.copyTo(this, 0, ti - l2 + 1, l2)
        }
        if (l2 == 1) {
            this.copyTo(this, start1, start1 + 1, l1)
            this[start1] = buffer[s2]
        }
    }

    @OverflowWrapping
    func timSort(compare: (T, T) -> Ordering): Unit {
        if (this.size <= 64) {
            shortSort(0, this.size - 1, compare)
            return
        }

        // init temp data
        let mrl = this.getMinRunLength()
        var scratch = TempArray(this.size, this[0])
        let stackLen = Int64(log2(Float64(this.size) / Float64(mrl) + 2.0)) + 1
        let runStarts = Array<Int64>(stackLen, repeat: 0)
        let runLengths = Array<Int64>(stackLen, repeat: 0)
        var runTop = -1

        var start: Int64 = 0
        while (start < this.size) {
            let length = this.size - start
            var seqLen = length
            if (length > 1) {
                seqLen = getSequenceLength(start, this.size - 1, scratch, compare)
                if (seqLen < mrl) {
                    if (length < mrl) {
                        binaryInsertionSort(start, start + length - 1, compare, seqLen)
                        seqLen = length
                    } else {
                        binaryInsertionSort(start, start + mrl - 1, compare, seqLen)
                        seqLen = mrl
                    }
                }
            }
            runTop++
            runStarts[runTop] = start
            runLengths[runTop] = seqLen
            start = start + seqLen
            runTop = this.maybeMerge(runStarts, runLengths, runTop, scratch, compare)
        }
        this.mergeAll(runStarts, runLengths, runTop, scratch, compare)
    }
}
// Temporary code, deleted when @Deprecated ends
class TempArray<T> {
    private var data: Array<T>
    private let zero: T
    private let max: Int64

    init(runLength: Int64, z: T) {
        this.data = Array<T>()
        this.max = runLength >> 1
        this.zero = z
    }

    @OverflowWrapping
    func getArray(runLength: Int64): Array<T> {
        if (data.size >= runLength) {
            return this.data
        }
        var expandedSize = data.size * 2
        if (expandedSize < runLength) {
            expandedSize = runLength
        }
        if (expandedSize > this.max) {
            expandedSize = this.max
        }
        this.data = Array<T>(expandedSize, repeat: this.zero)
        return this.data
    }
}

func unstableSort<T>(data: Array<T>, compare: (T, T) -> Ordering): Unit {
    if (data.size < 2) {
        return
    }
    data.introSort(0, data.size - 1, data.depth(), compare)
}

// Temporary code, deleted when @Deprecated ends
extend<T> Array<T> {
    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    // end - begin >= 1
    @OverflowWrapping
    private func getPartition(start: Int64, finish: Int64, compare: (T, T) -> Ordering): (Int64, Int64) {
        let span: Int64 = finish - start + 1
        let middle: Int64 = (span >> 1) + start
        if (span >= 64) {
            let quarter: Int64 = span >> 2
            this.compareSwap3(start, start + quarter, middle, compare)
            this.compareSwap3(middle, middle + quarter, finish, compare)
        }
        this.compareSwap3(start, middle, finish, compare)
        let pivotValue: T = this[middle]

        let scratch = this[finish]
        this[finish] = pivotValue
        this[middle] = scratch
        var pivotEqualCount = 0
        var left = start
        var right = finish - 1

        var firstEqual: Int64 = left
        while (left < right) {
            let leftValue = this[left]
            match (compare(leftValue, pivotValue)) {
                case LT => left++
                case EQ =>
                    pivotEqualCount++
                    firstEqual = left
                    left++
                    break
                case GT =>
                    var shouldStopPartition = false
                    while (left < right) {
                        let rightValue = this[right]
                        match (compare(pivotValue, rightValue)) {
                            case LT => right--
                            case EQ =>
                                pivotEqualCount++
                                this[left] = rightValue
                                this[right] = leftValue
                                right--
                                firstEqual = left
                                left++
                                shouldStopPartition = true
                                break
                            case GT =>
                                this[left] = rightValue
                                this[right] = leftValue
                                left++
                                right--
                                break
                        }
                    }
                    if (shouldStopPartition) {
                        break
                    }
            }
        }

        while (left < right) {
            var leftValue: T = pivotValue
            while (left < right) {
                leftValue = this[left]
                match (compare(leftValue, pivotValue)) {
                    case LT => left++
                    case EQ =>
                        pivotEqualCount++
                        left++
                    case GT => break
                }
            }
            var rightValue: T = pivotValue
            while (left < right) {
                rightValue = this[right]
                match (compare(pivotValue, rightValue)) {
                    case LT => right--
                    case EQ =>
                        pivotEqualCount++
                        break
                    case GT => break
                }
            }
            if (left >= right) {
                break
            }
            this[left] = rightValue
            this[right] = leftValue
            left++
            right--
        }

        match (compare(this[left], pivotValue)) {
            case GT => ()
            case _ => left++
        }
        this.swap(left, finish)
        if (left - firstEqual >= pivotEqualCount * pivotEqualCount) {
            return (left - 1, left + 1)
        } else {
            let upper = left
            left = firstEqual
            right = upper - 1
            while (left < right) {
                var rightValue: T = pivotValue
                while (left < right) {
                    rightValue = this[right]
                    match (compare(pivotValue, rightValue)) {
                        case EQ => right--
                        case _ => break
                    }
                }
                var leftValue: T = pivotValue
                while (left < right) {
                    leftValue = this[left]
                    match (compare(leftValue, pivotValue)) {
                        case EQ => break
                        case _ => left++
                    }
                }
                if (left >= right) {
                    break
                }
                this[left] = rightValue
                this[right] = leftValue
                left++
                right--
            }
            match (compare(this[left], pivotValue)) {
                case EQ => left--
                case _ => ()
            }
            return (left, upper + 1)
        }
    }

    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    func introSort(start: Int64, finish: Int64, depth: Int64, compare: (T, T) -> Ordering): Unit {
        var left: Int64 = start
        var right: Int64 = finish
        var remainingDepth: Int64 = depth
        while (left < right) {
            let span = right - left + 1
            if (span <= 16) {
                if (span == 1) {
                    return
                } else if (span == 2) {
                    this.compareSwap2(left, right, compare)
                } else if (span == 3) {
                    this.compareSwap3(left, left + 1, right, compare)
                } else {
                    this.insertionSort(left, right, compare)
                }
                return
            }
            if (remainingDepth == 0) {
                this.heapSort(left, right, compare)
                return
            }
            remainingDepth--
            let (lower, upper) = this.getPartition(left, right, compare)

            // Let the smaller side do recursion
            // Let the bigger side do loop
            if (lower - left < right - upper) {
                this.introSort(left, lower, remainingDepth, compare)
                left = upper
            } else {
                this.introSort(upper, right, remainingDepth, compare)
                right = lower
            }
        }
    }
}

// Temporary code, deleted when @Deprecated ends
extend<T> Array<T> {
    func compareSwap2(i1: Int64, i2: Int64, compare: (T, T) -> Ordering) {
        let leftItem: T = this[i1]
        let left: T = this[i2]
        match (compare(leftItem, left)) {
            case GT =>
                this[i1] = left
                this[i2] = leftItem
            case _ => ()
        }
    }

    func compareSwap3(i1: Int64, i2: Int64, i3: Int64, compare: (T, T) -> Ordering) {
        var leftItem: T = this[i1]
        var left: T = this[i2]
        var rightItem: T = this[i3]
        if (compare(leftItem, left) == GT) {
            var scratch = leftItem
            leftItem = left
            left = scratch
        }

        if (compare(rightItem, leftItem) == LT) {
            this[i1] = rightItem
            this[i2] = leftItem
            this[i3] = left
        } else if (compare(rightItem, left) == LT) {
            this[i1] = leftItem
            this[i2] = rightItem
            this[i3] = left
        } else {
            this[i1] = leftItem
            this[i2] = left
            this[i3] = rightItem
        }
    }

    @OverflowWrapping
    func getMinRunLength() {
        var runLength = this.size
        var rightBound: Int64 = 0
        while (runLength >= 64) {
            rightBound = rightBound | (runLength & 1)
            runLength = runLength >> 1
        }
        return runLength + rightBound
    }

    @OverflowWrapping
    func depth(): Int64 {
        var x: Int64 = this.size
        var res: Int64 = 0
        while (x >= 1) {
            res++
            x >>= 1
        }
        return res * 2
    }

    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    func insertionSort(start: Int64, finish: Int64, compare: (T, T) -> Ordering): Unit {
        var idx: Int64 = start + 1
        while (idx <= finish) {
            var candidate = this[idx]
            var scan = idx - 1
            while (scan >= start) {
                var scratch = this[scan]
                match (compare(scratch, candidate)) {
                    case GT => this[scan + 1] = scratch
                    case _ => break
                }
                scan--
            }
            this[scan + 1] = candidate
            idx++
        }
    }

    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    // end - begin >= 1
    @OverflowWrapping
    func getSequenceLength(start: Int64, finish: Int64, scratch: TempArray<T>, compare: (T, T) -> Ordering): Int64 {
        var left: Int64 = start
        var equalCount: Int64 = 1
        var ascending: Bool = true

        match (compare(this[left], this[left + 1])) {
            case LT => ascending = true
            case GT => ascending = false
            case EQ =>
                equalCount++
                left++
                while (left + 1 <= finish) {
                    match (compare(this[left], this[left + 1])) {
                        case LT =>
                            ascending = true
                            break
                        case GT =>
                            ascending = false
                            break
                        case EQ =>
                            equalCount++
                            left++
                    }
                }
        }
        if (left >= finish) {
            return equalCount
        } else if (finish - left == 1) {
            if (ascending) {
                return equalCount + 1
            } else {
                let rightValue = this[finish]
                this.copyTo(this, start, start + 1, equalCount)
                this[start] = rightValue
                return equalCount + 1
            }
        }
        left++
        var runLength: Int64 = 1
        if (ascending) {
            while (left + 1 <= finish) {
                match (compare(this[left], this[left + 1])) {
                    case GT => break
                    case _ =>
                        runLength++
                        left++
                }
            }
            return equalCount + runLength
        } else {
            while (left + 1 <= finish) {
                match (compare(this[left], this[left + 1])) {
                    case GT =>
                        runLength++
                        left++
                    case _ => break
                }
            }

            if (equalCount == 1) {
                var idx = start
                var scan = start + runLength // start + equalCount + runLength - 1
                while (idx < scan) {
                    this.swap(idx, scan)
                    idx++
                    scan--
                }
                return equalCount + runLength
            } else {
                var idx = start + equalCount
                var scan = idx + runLength - 1
                while (idx < scan) {
                    this.swap(idx, scan)
                    idx++
                    scan--
                }
            }

            if (equalCount == 2) {
                let savedFirst = this[start]
                let savedSecond = this[start + 1]
                if (runLength == 1) {
                    this[start] = this[start + 2]
                    this[start + 1] = savedFirst
                    this[start + 2] = savedSecond
                } else if (runLength == 2) {
                    this[start] = this[start + 2]
                    this[start + 1] = this[start + 3]
                    this[start + 2] = savedFirst
                    this[start + 3] = savedSecond
                } else {
                    this.copyTo(this, start + 2, start, runLength)
                    this[start + equalCount + runLength - 2] = savedFirst
                    this[start + equalCount + runLength - 1] = savedSecond
                }
            } else {
                if (runLength == 1) {
                    let t = this[start + equalCount]
                    this.copyTo(this, start, start + 1, equalCount)
                    this[start] = t
                } else if (runLength == 2) {
                    let savedFirst = this[start + equalCount]
                    let savedSecond = this[start + equalCount + 1]
                    this.copyTo(this, start, start + 2, equalCount)
                    this[start] = savedFirst
                    this[start + 1] = savedSecond
                } else {
                    if (runLength < equalCount) {
                        let buffer = scratch.getArray(runLength)
                        this.copyTo(buffer, start + equalCount, 0, runLength)
                        this.copyTo(this, start, start + runLength, equalCount)
                        buffer.copyTo(this, 0, start, runLength)
                    } else {
                        let buffer = scratch.getArray(equalCount)
                        this.copyTo(buffer, start, 0, equalCount)
                        this.copyTo(this, start + equalCount, start, runLength)
                        buffer.copyTo(this, 0, start + runLength, equalCount)
                    }
                }
            }
            return equalCount + runLength
        }
    }

    // the original relative positions of equal elements are not guaranteed.
    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    func binaryInsertionSort(start: Int64, finish: Int64, compare: (T, T) -> Ordering, runLength: Int64) {
        var idx = start + runLength
        while (idx <= finish) {
            let candidate = this[idx]
            let leftBound = this.binaryQueryGT(candidate, start, idx - start, compare)
            let moveCount = idx - leftBound
            if (moveCount == 0) {
                idx++
                continue
            }
            match (moveCount) {
                case 1 => this[idx] = this[idx - 1]
                case 2 =>
                    this[idx] = this[idx - 1]
                    this[idx - 1] = this[idx - 2]
                case _ => this.copyTo(this, leftBound, leftBound + 1, moveCount)
            }
            this[leftBound] = candidate
            idx++
        }
    }

    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    func heapify(start: Int64, finish: Int64, root: Int64, compare: (T, T) -> Ordering): Unit {
        var parentIndex: Int64 = root
        var childIndex = (parentIndex << 1) + 1 // parentIndex * 2 + 1
        while (start + childIndex <= finish) {
            let selected = if (start + childIndex + 1 <= finish) {
                let s1 = this[start + childIndex]
                let s2 = this[start + childIndex + 1]
                match (compare(s1, s2)) {
                    case LT =>
                        childIndex++
                        s2
                    case _ => s1
                }
            } else {
                this[start + childIndex]
            }
            let parent = this[start + parentIndex]
            match (compare(parent, selected)) {
                case LT =>
                    this[start + parentIndex] = selected
                    this[start + childIndex] = parent
                case _ => return
            }
            parentIndex = childIndex
            childIndex = (parentIndex << 1) + 1
        }
    }

    // the value range of the parameter: 0 <= begin < end <= array.size - 1
    @OverflowWrapping
    func heapSort(start: Int64, finish: Int64, compare: (T, T) -> Ordering): Unit {
        let span = finish - start + 1
        var idx = (span >> 1) - 1

        while (idx >= 0) {
            this.heapify(start, finish, idx, compare)
            idx--
        }
        idx = finish
        while (idx > start) {
            this.swap(start, idx)

            this.heapify(start, idx - 1, 0, compare)
            idx--
        }
    }

    // The queried position is just greater than and equal the previous value.
    @OverflowWrapping
    func binaryQueryGT(candidate: T, start: Int64, span: Int64, compare: (T, T) -> Ordering): Int64 {
        var leftBound = start
        var rightBound = start + span
        while (leftBound < rightBound) {
            let middleIndex = leftBound + ((rightBound - leftBound) >> 1)
            match (compare(candidate, this[middleIndex])) {
                case LT => rightBound = middleIndex
                case _ => leftBound = middleIndex + 1
            }
        }
        return leftBound
    }

    // The queried position is just less than and equal the next value.
    @OverflowWrapping
    func binaryQueryLT(candidate: T, start: Int64, span: Int64, compare: (T, T) -> Ordering): Int64 {
        var leftBound = start
        var rightBound = start + span
        while (leftBound < rightBound) {
            let middleIndex = leftBound + ((rightBound - leftBound) >> 1)
            match (compare(candidate, this[middleIndex])) {
                case GT => leftBound = middleIndex + 1
                case _ => rightBound = middleIndex
            }
        }
        return leftBound
    }

    // The queried position is just greater than and equal the previous value.
    @OverflowWrapping
    func queryGT(candidate: T, start: Int64, span: Int64, compare: (T, T) -> Ordering, rightBound: Bool) {
        var gallopLimit = span
        if (rightBound) {
            let finish = start + span - 1
            if (span > 64) {
                let gallopProbe = Int64(sqrt(Float64(span)))
                match (compare(candidate, this[finish - gallopProbe])) {
                    case LT => return this.binaryQueryGT(candidate, start, span - gallopProbe, compare)
                    case _ => gallopLimit = gallopProbe
                }
            }
            var offset = 1
            var previousOffset = 0
            while (offset < gallopLimit) {
                let t = this[finish - offset]
                match (compare(candidate, t)) {
                    case LT =>
                        previousOffset = offset
                        offset = (offset << 1) + 1
                    case _ => break
                }
            }
            if (offset > gallopLimit) {
                offset = gallopLimit
            }
            return this.binaryQueryGT(candidate, start + span - offset, offset - previousOffset, compare)
        } else {
            if (span > 64) {
                let gallopProbe = Int64(sqrt(Float64(span)))
                match (compare(candidate, this[start + gallopProbe])) {
                    case LT => gallopLimit = gallopProbe
                    case _ => return this.binaryQueryGT(candidate, start + gallopProbe, span - gallopProbe, compare)
                }
            }
            var offset = 1
            var previousOffset = 0
            while (offset < gallopLimit) {
                let t = this[start + offset]
                match (compare(candidate, t)) {
                    case LT => break
                    case _ =>
                        previousOffset = offset
                        offset = (offset << 1) + 1
                }
            }
            if (offset > gallopLimit) {
                offset = gallopLimit
            }
            return this.binaryQueryGT(candidate, start + previousOffset, offset - previousOffset, compare)
        }
    }

    // The queried position is just less than and equal the next value.
    @OverflowWrapping
    func queryLT(candidate: T, start: Int64, span: Int64, compare: (T, T) -> Ordering, rightBound: Bool) {
        var gallopLimit = span
        if (rightBound) {
            let finish = start + span - 1
            if (span > 64) {
                let gallopProbe = Int64(sqrt(Float64(span)))
                match (compare(candidate, this[finish - gallopProbe])) {
                    case GT => gallopLimit = gallopProbe
                    case _ => return this.binaryQueryLT(candidate, start, span - gallopProbe, compare)
                }
            }
            var offset = 1
            var previousOffset = 0
            while (offset < gallopLimit) {
                let t = this[finish - offset]
                match (compare(candidate, t)) {
                    case GT => break
                    case _ =>
                        previousOffset = offset
                        offset = (offset << 1) + 1
                }
            }
            if (offset > gallopLimit) {
                offset = gallopLimit
            }
            return this.binaryQueryLT(candidate, start + span - offset, offset - previousOffset, compare)
        } else {
            if (span > 64) {
                let gallopProbe = Int64(sqrt(Float64(span)))
                match (compare(candidate, this[start + gallopProbe])) {
                    case GT => return this.binaryQueryLT(candidate, start + gallopProbe, span - gallopProbe, compare)
                    case _ => gallopLimit = gallopProbe
                }
            }
            var offset = 1
            var previousOffset = 0
            while (offset < gallopLimit) {
                let t = this[start + offset]
                match (compare(candidate, t)) {
                    case GT =>
                        previousOffset = offset
                        offset = (offset << 1) + 1
                    case _ => break
                }
            }
            if (offset > gallopLimit) {
                offset = gallopLimit
            }
            return this.binaryQueryLT(candidate, start + previousOffset, offset - previousOffset, compare)
        }
    }
}
