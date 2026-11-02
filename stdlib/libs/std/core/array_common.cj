/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@Frozen
@OverflowWrapping
private func arrayInitByCollection<T>(array: RawArray<T>, elements: Collection<T>): RawArray<T> {
    var i: Int64 = 0
    let it: Iterator<T> = elements.iterator()
    while (true) {
        match (it.next()) {
            case Some(v) => arraySet(array, i, v)
            case None => break
        }
        i = i + 1
    }
    return array
}

/**
 * Constructs a RawArray with the specified initial size and specified initial function.
 */
@Frozen
@OverflowWrapping
private func arrayInitByFunction<T>(array: RawArray<T>, initElement: (Int64) -> T): RawArray<T> {
    var i: Int64 = 0
    while (i < arraySize(array)) {
        arraySet(array, i, initElement(i))
        i++
    }
    return array
}

@Frozen
func toArray<T>(raw: RawArray<T>): Array<T> {
    if (arraySize(raw) == 0) {
        return Array<T>()
    }
    return Array<T>(raw, 0, arraySize(raw))
}
@Frozen
@When[env != "ohos"]
exclave func toArray<T>(raw: RawArray<T> @local!): Array<T> @local! {
    if (arraySize(raw) == 0) {
        return Array<T>()
    }
    return Array<T>(raw, 0, arraySize(raw))
}
@Frozen
@When[env != "ohos"]
exclave func toArray<T>(raw: RawArray<T> @local?): Array<T> @local? {
    if (arraySize(raw) == 0) {
        // Empty result keeps the @local? mode without the removed no-arg @local? ctor:
        // build from a freshly allocated zero-length local RawArray.
        return Array<T>(rawArrayAllocate3<T>(0), 0, 0)
    }
    return Array<T>(raw, 0, arraySize(raw))
}

extend<T> Array<T> <: Collection<T> {
    /** Returns an iterator over the elements in this Array in proper sequence. */
    @Frozen
    public func iterator(): Iterator<T> {
        return ArrayIterator(this)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func iterator(this @local!): Iterator<T> @local! {
        ArrayIterator<T>(this) @local!
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func iterator(this @local?): Iterator<T> @local? {
        ArrayIterator<T>(this) @local?
    }

    /**
     * Call 'size' on array type variable will be processed by compiler.
     * Only call based on 'Collection' type will use this function.
     */
    @Frozen
    public prop size: Int64 {
        get() {
            return this.len
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop size: Int64 @local? {
        get() {
            this.len
        }
    }

    /** Returns true if this Array contains no elements. */
    @Frozen
    public func isEmpty(): Bool {
        return this.len == 0
    }
    @Frozen
    @When[env != "ohos"]
    public func isEmpty(this @local?): Bool {
        return this.size == 0
    }

    @Frozen
    public func toArray(): Array<T> {
        return this.clone()
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func toArray(this @local!): Array<T> @local! {
        this.clone()
    }

}


extend<T> Array<T> <: ToString where T <: ToString {
    @Frozen
    public func toString(): String {
        if (size == 0) {
            return "[]"
        }
        let sb = StringBuilder()
        sb.append(r'[')
        sb.append(this[0])
        for (i in 1..size) {
            sb.append(", ")
            sb.append(this[i])
        }
        sb.append(r']')
        return sb.toString()
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let sb: StringBuilder @local! = StringBuilder()
        sb.appendRune(r'[')
        if (size > 0) {
            sb.appendValue(this[0])
            for (i in 1..size) {
                sb.appendString(", ")
                sb.appendValue(this[i])
            }
        }
        sb.appendRune(r']')
        sb.toStringLocal()
    }
}

@ConstSafe
extend<T> Array<T> <: Equatable<Array<T>> where T <: Equatable<T> {
    @Frozen
    public const operator func ==(other: Array<T>): Bool {
        if (this.size != other.size) {
            return false
        }
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in this.size - 1..=0 : -1) {
            if (this[i] != other[i]) {
                return false
            }
        }
        return true
    }

    @Frozen
    public const operator func !=(other: Array<T>): Bool {
        return !(this == other)
    }

    @Frozen
    public func contains(element: T): Bool {
        if (this.size == 0) {
            return false
        }
        /* Back-to-front traversal can reduce boundary checks and improve performance */
        for (i in this.size - 1..=0 : -1) {
            if (this[i] == element) {
                return true
            }
        }
        return false
    }

    /**
     * Returns the index of the first occurrence of the element in the src Array.
     *
     * @params element - The target element.
     *
     * @return Index of the first occurrence of the element in the Array, or None if the the element does not occur.
     * @throws IllegalArgumentException - If the start less than 0.
     */
    @Frozen
    public func indexOf(element: T): Option<Int64> {
        if (size == 0) {
            return None
        }
        for (i in 0..size) {
            if (this[i] == element) {
                return Some(i)
            }
        }
        return None
    }

    /**
     * Returns the index of the first occurrence of the element after fromIndex in the src Array.
     *
     * @params element - The target element.
     * @params fromIndex - The start index, default 0.
     *
     * @return Index of the first occurrence of the element in the Array, or None if the the element does not occur.
     * @throws IllegalArgumentException - If the start less than 0.
     */
    @Frozen
    public func indexOf(element: T, fromIndex: Int64): Option<Int64> {
        if (size == 0 || fromIndex >= size) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in start..size) {
            if (this[i] == element) {
                return Some(i)
            }
        }
        return None
    }

    /**
     * Returns the index of the first occurrence of a subarray in this Array.
     *
     * @params elements - The target subarray.
     *
     * @return Index of the first occurrence of @p elements, or None if the subarray does not occur.
     */
    @Frozen
    public func indexOf(elements: Array<T>): Option<Int64> {
        if (this.size < elements.size) {
            return None
        }
        for (i in 0..(size - elements.size + 1)) {
            if (this[i..i + elements.size] == elements) {
                return Some(i)
            }
        }
        return None
    }

    /**
     * Returns the index of the first occurrence of a subarray at or after @p fromIndex.
     *
     * @params elements - The target subarray.
     *
     * @return Index of the first occurrence of @p elements from the starting position, or None if it does not occur.
     */
    @Frozen
    public func indexOf(elements: Array<T>, fromIndex: Int64): Option<Int64> {
        if (this.size < elements.size || fromIndex >= this.size) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in start..(size - elements.size + 1)) {
            if (this[i..i + elements.size] == elements) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(element: T): Option<Int64> {
        if (size == 0) {
            return None
        }
        for (i in size - 1..=0 : -1) {
            if (this[i] == element) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(element: T, fromIndex: Int64): Option<Int64> {
        if (size == 0 || fromIndex >= size) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in size - 1..=start : -1) {
            if (this[i] == element) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(elements: Array<T>): Option<Int64> {
        if (this.size < elements.size) {
            return None
        }
        for (i in (size - elements.size)..=0 : -1) {
            if (this[i..i + elements.size] == elements) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(elements: Array<T>, fromIndex: Int64): Option<Int64> {
        if (this.size < elements.size || fromIndex >= this.size) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in (size - elements.size)..=start : -1) {
            if (this[i..i + elements.size] == elements) {
                return Some(i)
            }
        }
        return None
    }

    /**
     * Returns a slice that dones not contain elements from the start.
     *
     * @param set - The target elements to trim.
     *
     * @return The slice of the src.
     */
    @Frozen
    @OverflowWrapping
    public func trimStart(set: Array<T>): Array<T> {
        var trim = false
        for (i in 0..this.len) {
            let elem = this[i]
            for (j in (set.len - 1)..-1 : -1) {
                if (set[j] == elem) {
                    trim = true
                    break
                }
                trim = false
            }
            if (!trim) {
                return this[i..]
            }
        }
        return Array<T>()
    }

    /**
     * Returns a slice that dones not contain elements from the end.
     *
     * @param set - The target elements to trim.
     *
     * @return The slice of the src.
     */
    @Frozen
    public func trimEnd(set: Array<T>): Array<T> {
        var trim = false
        for (i in (this.len - 1)..-1 : -1) {
            let elem = this[i]
            for (j in (set.len - 1)..-1 : -1) {
                if (set[j] == elem) {
                    trim = true
                    break
                }
                trim = false
            }
            if (!trim) {
                return this[..(i + 1)]
            }
        }
        return Array<T>()
    }

    /**
     * Returns a slice that dones not contain elements from the start.
     *
     * @param predicate - the elements satisfy the predicate should be trimmed.
     *
     * @return The slice of the src.
     */
    @Frozen
    public func trimStart(predicate: (T) -> Bool): Array<T> {
        for (i in 0..this.len) {
            if (!predicate(this[i])) {
                return this[i..]
            }
        }
        return Array<T>()
    }

    /**
     * Returns a slice that dones not contain elements from the end.
     *
     * @param predicate - the elements satisfy the predicate should be trimmed.
     *
     * @return The slice of the src.
     */
    @Frozen
    public func trimEnd(predicate: (T) -> Bool): Array<T> {
        for (i in (this.len - 1)..-1 : -1) {
            if (!predicate(this[i])) {
                return this[..(i + 1)]
            }
        }
        return Array<T>()
    }

    @Frozen
    public func removePrefix(prefix: Array<T>): Array<T> {
        if (this.size < prefix.size || prefix.size == 0) {
            return this
        }
        if (this[..prefix.size] == prefix) {
            return this[prefix.size..]
        }
        return this
    }

    @Frozen
    public func removeSuffix(suffix: Array<T>): Array<T> {
        if (this.size < suffix.size || suffix.size == 0) {
            return this
        }
        if (this[(this.size - suffix.size)..] == suffix) {
            return this[..(this.size - suffix.size)]
        }
        return this
    }
}

/**
 * Array-based Iterator.
 */
public class ArrayIterator<T> <: Iterator<T> {
    private var myData: Array<T>
    private let end: Int64
    private var myPosition: Int64

    @Frozen
    public init(data: Array<T>) {
        this.myData = data
        this.end = data.size
        this.myPosition = 0
    }

    @Frozen
    @When[env != "ohos"]
    internal exclave init(this @local!, data: Array<T> @local!) {
        this.myData = data
        this.end = data.size
        this.myPosition = 0
    }

    @Frozen
    @When[env != "ohos"]
    internal exclave init(this @local?, data: Array<T> @local?) {
        this.myData = data
        this.end = data.size
        this.myPosition = 0
    }

    /** Returns the next element in the iteration. */
    @Frozen
    @OverflowWrapping
    public func next(): Option<T> {
        if (this.myPosition < this.end) {
            var v: Option<T> = Some(this.myData[this.myPosition])
            this.myPosition++
            return v
        } else {
            return None
        }
    }

    /** Returns the next element in the iteration. */
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func next(this @local!): Option<T> @local! {
        if (this.myPosition < this.end) {
            let v: T @local! = arrayGetUnchecked2<T>(this.myData.rawptr, this.myData.start + this.myPosition)
            this.myPosition++
            return Some<T>(v)
        }
        None<T>
    }

    /** Returns the next element in the iteration. */
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func next(this @local?): Option<T> @local? {
        if (this.myPosition < this.end) {
            let v: T @local? = arrayGetUnchecked3<T>(this.myData.rawptr, this.myData.start + this.myPosition)
            this.myPosition++
            return Some<T>(v)
        }
        None<T>
    }
}

public struct CPointerHandle<T> where T <: CType {
    public let pointer: CPointer<T>
    public let array: Array<T>

    @Deprecated[message: "Use global function `public unsafe func acquireArrayRawData<T>(arr: Array<T>): CPointerHandle<T> where T <: CType` instead."]
    public init() {
        pointer = CPointer<T>()
        array = Array<T>()
    }

    @Deprecated[message: "Use global function `public unsafe func acquireArrayRawData<T>(arr: Array<T>): CPointerHandle<T> where T <: CType` instead."]
    public init(ptr: CPointer<T>, arr: Array<T>) {
        this.pointer = ptr
        this.array = arr
    }

    @When[env != "ohos"]
    internal exclave init(this @local?, ptr: CPointer<T> @local?, arr: Array<T> @local?) {
        pointer = ptr
        array = arr
    }
}

/**
 * Caution: any behavior that may allocate memory in cangjie heap or
 * trigger garbage collection between func acquireArrayRawData<T>(arr: Array<T>)
 * and func releaseArrayRawData<T>(handle: CPointerHandle<T>)
 * is permitted in case of dead lock
 */
@Frozen
public unsafe func acquireArrayRawData<T>(arr: Array<T>): CPointerHandle<T> where T <: CType {
    CPointerHandle<T>(acquireRawData<T>(arr.rawptr) + arr.start, arr)
}

@Frozen
@When[env != "ohos"]
public exclave unsafe func acquireArrayRawData<T>(arr: Array<T> @local?): CPointerHandle<T> @local? where T <: CType {
    CPointerHandle<T>(acquireRawData2<T>(arr.rawptr) + arr.start, arr)
}

@Frozen
public unsafe func releaseArrayRawData<T>(handle: CPointerHandle<T>): Unit where T <: CType {
    releaseRawData(handle.array.rawptr, handle.pointer - handle.array.start)
}

@Frozen
@When[env != "ohos"]
public unsafe func releaseArrayRawData<T>(handle: CPointerHandle<T> @local?): Unit where T <: CType {
    releaseRawData2(handle.array.rawptr, handle.pointer - handle.array.start)
}


/**
 * @local? forms not provided in this file: contains, indexOf(element) without fromIndex,
 * and `==` / `!=` (==/!= are limited by extend member shadowing).
 */
@When[env != "ohos"]
extend<T> Array<T> where T <: Equatable<T> {
    @Frozen
    public func indexOf(this @local?, element: T @local?, fromIndex: Int64): Option<Int64> {
        if (this.len == 0 || fromIndex >= this.len) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in start..this.len) {
            if (arrayGetUnchecked3<T>(this.rawptr, this.start + i) == element) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func indexOf(this @local?, elements: Array<T> @local?): Option<Int64> {
        if (this.len < elements.len) {
            return None
        }
        for (i in 0..(this.len - elements.len + 1)) {
            var matched: Bool = true
            for (j in 0..elements.len) {
                if (arrayGetUnchecked3<T>(this.rawptr, this.start + i + j) !=
                    arrayGetUnchecked3<T>(elements.rawptr, elements.start + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                return Some(i)
            }
        }
        return None
    }

    public func indexOf(this @local?, elements: Array<T> @local?, fromIndex: Int64): Option<Int64> {
        if (this.len < elements.len || fromIndex >= this.len) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        if (start > this.len - elements.len) {
            return None
        }
        for (i in start..(this.len - elements.len + 1)) {
            var matched: Bool = true
            for (j in 0..elements.len) {
                if (arrayGetUnchecked3<T>(this.rawptr, this.start + i + j) !=
                    arrayGetUnchecked3<T>(elements.rawptr, elements.start + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(this @local?, element: T @local?): Option<Int64> {
        if (this.len == 0) {
            return None
        }
        for (i in this.len - 1..=0 : -1) {
            if (arrayGetUnchecked3<T>(this.rawptr, this.start + i) == element) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(this @local?, element: T @local?, fromIndex: Int64): Option<Int64> {
        if (this.len == 0 || fromIndex >= this.len) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in this.len - 1..=start : -1) {
            if (arrayGetUnchecked3<T>(this.rawptr, this.start + i) == element) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(this @local?, elements: Array<T> @local?): Option<Int64> {
        if (this.len < elements.len) {
            return None
        }
        for (i in (this.len - elements.len)..=0 : -1) {
            var matched: Bool = true
            for (j in 0..elements.len) {
                if (arrayGetUnchecked3<T>(this.rawptr, this.start + i + j) !=
                    arrayGetUnchecked3<T>(elements.rawptr, elements.start + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                return Some(i)
            }
        }
        return None
    }

    @Frozen
    public func lastIndexOf(this @local?, elements: Array<T> @local?, fromIndex: Int64): Option<Int64> {
        if (this.len < elements.len || fromIndex >= this.len) {
            return None
        }
        let start = if (fromIndex >= 0) {
            fromIndex
        } else {
            0
        }
        for (i in (this.len - elements.len)..=start : -1) {
            var matched: Bool = true
            for (j in 0..elements.len) {
                if (arrayGetUnchecked3<T>(this.rawptr, this.start + i + j) !=
                    arrayGetUnchecked3<T>(elements.rawptr, elements.start + j)) {
                    matched = false
                    break
                }
            }
            if (matched) {
                return Some(i)
            }
        }
        return None
    }
}
