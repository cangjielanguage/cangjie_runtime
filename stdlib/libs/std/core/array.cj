/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

// Size arithmetic for `clone(range)`: one definition serves the plain and `@local!` bodies.
// Size is ceil(|end_ - start_| / |step|). Computing it from magnitudes
// keeps the intermediate arithmetic inside Int64 even when step is
// Int64.Max or Int64.Min, where `(end_ - start_ + step - 1) / step`
// wraps around and yields a negative size.
@Frozen
@OverflowWrapping
private func rangeCloneSize(start_: Int64, end_: Int64, step: Int64): Int64 {
    let span: Int64 = end_ - start_
    let magnitude: UInt64 = if (span < 0) {
        UInt64(-span)
    } else {
        UInt64(span)
    }
    let stride: UInt64 = if (step < 0) {
        UInt64(-(step + 1)) + 1
    } else {
        UInt64(step)
    }
    let quotient: UInt64 = magnitude / stride
    Int64(quotient + (if (quotient * stride != magnitude) { 1 } else { 0 }))
}

@ConstSafe
public struct Array<T> {
    let rawptr: RawArray<T>
    let start: Int64
    let len: Int64

    @Frozen
    func toRawArray() {
        if (len == 0) {
            return rawArrayAllocate<T>(0)
        }
        let newRawPtr = rawArrayAllocate<T>(len)
        rawArrayInitByValue(newRawPtr, len, unsafe { zeroValue<T>() })
        intrinsicBuiltInCopyTo<T>(this.rawptr, newRawPtr, this.start, 0, len)
        return newRawPtr
    }

    @Frozen
    public const init() {
        this.start = 0
        this.rawptr = rawArrayAllocate<T>(0)
        this.len = 0
    }

    @Frozen
    @When[env != "ohos"]
    public const init(this @local!) {
        exclave {
            this.start = 0
            this.rawptr = rawArrayAllocate2<T>(0)
            this.len = 0
        }
    }
    
    @Frozen
    public init(size: Int64, repeat!: T) {
        this.start = 0
        let raw = rawArrayAllocate<T>(size)
        rawArrayInitByValue(raw, size, repeat)
        this.rawptr = raw
        this.len = size
    }

    @Frozen
    @When[env != "ohos"]
    public init(this @local!, size: Int64, repeat!: T @local!) {
        exclave {
            this.start = 0
            let raw = rawArrayAllocate2<T>(size)
            rawArrayInitByValue2(raw, size, repeat)
            this.rawptr = raw
            this.len = size
        }
    }

    @Frozen
    @When[env != "ohos"]
    public init(this @local!, size: Int64, initElement: ((Int64) -> T @local!) @local?) {
        exclave {
            this.start = 0
            let raw = rawArrayAllocate2<T>(size)
            var i: Int64 = 0
            while (i < size) {
                let v: T @local! = initElement(i)
                arraySet2<T>(raw, i, v)
                i = i + 1
            }
            this.rawptr = raw
            this.len = size
        }
    }

    // Note: a lambda in `@local?` mode cannot capture `@local!` variables; the closure can only
    // reference plain/@local? captures or pure computation.
    @Frozen
    @When[env != "ohos"]
    public init(this @local?, size: Int64, initElement: ((Int64) -> T @local?) @local?) {
        exclave {
            this.start = 0
            let raw = rawArrayAllocate3<T>(size)
            var i: Int64 = 0
            while (i < size) {
                arraySet3<T>(raw, i, initElement(i))
                i = i + 1
            }
            this.rawptr = raw
            this.len = size
        }
    }

    @Frozen
    init(elements: Collection<T>) {
        this.start = 0
        let raw = rawArrayAllocate<T>(elements.size)
        arrayInitByCollection(raw, elements)
        this.rawptr = raw
        this.len = arraySize(raw)
    }

    // Dispatching the interface members (size / iterator / toArray) on a `Collection<T> @local!` is not
    // supported by the compiler: match on the concrete type to get the data; other Collection implementations report an explicit error.
    @Frozen
    @When[env != "ohos"]
    init(this @local!, elements: Collection<T> @local!) {
        exclave {
            match (elements) {
                case arr: Array<T> =>
                    let copy: Array<T> @local! = arr.clone()
                    this.rawptr = copy.rawptr
                    this.start = copy.start
                    this.len = copy.len
                case _ =>
                    throw IllegalArgumentException("Unsupported collection type for @local! Array init.")
            }
        }
    }

    @Frozen
    @When[env != "ohos"]
    init(this @local?, elements: Collection<T> @local?) {
        exclave {
            match (elements) {
                case arr: Array<T> =>
                    let copy: Array<T> @local? = arr.clone()
                    this.rawptr = copy.rawptr
                    this.start = copy.start
                    this.len = copy.len
                case _ =>
                    throw IllegalArgumentException("Unsupported collection type for @local? Array init.")
            }
        }
    }

    @Frozen
    public init(size: Int64, initElement: (Int64) -> T) {
        this.start = 0
        let raw = rawArrayAllocate<T>(size)
        arrayInitByFunction(raw, initElement)
        this.rawptr = raw
        this.len = size
    }

    @Frozen
    init(data: RawArray<T>, start: Int64, len: Int64) {
        this.rawptr = data
        this.start = start
        this.len = len
    }

    @When[env != "ohos"]
    @Frozen
    exclave init(this @local!, data: RawArray<T> @local!, start: Int64, len: Int64) {
        this.rawptr = data
        this.start = start
        this.len = len
    }
    
    @When[env != "ohos"]
    @Frozen
    exclave init(this @local?, data: RawArray<T> @local?, start: Int64, len: Int64) {
        this.rawptr = data
        this.start = start
        this.len = len
    }

    @Frozen
    public prop first: Option<T> {
        get() {
            if (this.len == 0) {
                return None
            }
            return this[0]
        }
    }

    @Frozen
    public prop last: Option<T> {
        get() {
            if (this.len == 0) {
                return None
            }
            return this[len - 1]
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop first: Option<T> @local! {
        get() {
            exclave {
                if (this.len == 0) {
                    return None<T>
                }
                Some<T>(arrayGetUnchecked2<T>(this.rawptr, start))
            }
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop first: Option<T> @local? {
        get() {
            exclave {
                if (this.len == 0) {
                    return None<T>
                }
                Some<T>(arrayGetUnchecked3<T>(this.rawptr, start))
            }
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop last: Option<T> @local! {
        get() {
            exclave {
                if (this.len == 0) {
                    return None<T>
                }
                Some<T>(arrayGetUnchecked2<T>(this.rawptr, start + this.len - 1))
            }
        }
    }

    @Frozen
    @When[env != "ohos"]
    public prop last: Option<T> @local? {
        get() {
            exclave {
                if (this.len == 0) {
                    return None<T>
                }
                Some<T>(arrayGetUnchecked3<T>(this.rawptr, start + this.len - 1))
            }
        }
    }

    /**
     * @return slice of this Array
     * @throws IndexOutOfBoundsException if `start` is negative, or `len` is negative,
     *         or `start + len` is greater than the size of array.
     */
    @Frozen
    public func slice(start: Int64, len: Int64): Array<T> {
        if (start < 0 || len < 0 || (start + len) > this.len) {
            throw IndexOutOfBoundsException(arraySliceOutOfBoundsExceptionMessage(this.len, start, len))
        }
        return Array(this.rawptr, this.start + start, len)
    }

    @Frozen
    @When[env != "ohos"]
    public func slice(this @local!, start: Int64, len: Int64): Array<T> @local! {
        if (start < 0 || len < 0 || start > this.len || len > this.len - start) {
            throw IndexOutOfBoundsException(arraySliceOutOfBoundsExceptionMessage(this.len, start, len))
        }
        exclave {
            Array(this.rawptr, this.start + start, len)
        }
    }

    @Frozen
    @When[env != "ohos"]
    public func slice(this @local?, start: Int64, len: Int64): Array<T> @local? {
        if (start < 0 || len < 0 || start > this.len || len > this.len - start) {
            throw IndexOutOfBoundsException(arraySliceOutOfBoundsExceptionMessage(this.len, start, len))
        }
        exclave {
            Array(this.rawptr, this.start + start, len)
        }
    }

    @OverflowWrapping
    @Frozen
    public func get(index: Int64): Option<T> {
        if (UInt64(index) >= UInt64(this.len)) {
            return None<T>
        }
        return Some<T>(arrayGetUnchecked(this.rawptr, start + index))
    }

    @OverflowWrapping
    @Frozen
    @When[env != "ohos"]
    public func get(this @local!, index: Int64): Option<T> @local! {
        exclave {
            if (UInt64(index) >= UInt64(this.len)) {
                return None<T>
            }
            Some<T>(arrayGetUnchecked2<T>(this.rawptr, start + index))
        }
    }

    @OverflowWrapping
    @Frozen
    @When[env != "ohos"]
    public func get(this @local?, index: Int64): Option<T> @local? {
        exclave {
            if (UInt64(index) >= UInt64(this.len)) {
                return None<T>
            }
            Some<T>(arrayGetUnchecked3<T>(this.rawptr, start + index))
        }
    }

    /**
     * @throws IndexOutOfBoundsException if `index` is negative or
     *         greater than or equal to the size of array.
     */
    @Frozen
    @OverflowWrapping
    public operator func [](index: Int64): T {
        // Using type conversion to replace typical bounds checking,
        // if (index < 0 || index >= this.len), to a single comparison.
        // The negative value of index will be converted to a large positive number
        // when `index` and `this.len` are interpreted as UInt64 and will trigger the exception.
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        return arrayGetUnchecked(this.rawptr, start + index)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public operator func [](this @local!, index: Int64): T @local! {
        // Using type conversion to replace typical bounds checking,
        // if (index < 0 || index >= this.len), to a single comparison.
        // The negative value of index will be converted to a large positive number
        // when `index` and `this.len` are interpreted as UInt64 and will trigger the exception.
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        exclave { arrayGetUnchecked2<T>(this.rawptr, start + index) }
    }
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave operator func [](this @local?, index: Int64): T @local? {
        // Using type conversion to replace typical bounds checking,
        // if (index < 0 || index >= this.len), to a single comparison.
        // The negative value of index will be converted to a large positive number
        // when `index` and `this.len` are interpreted as UInt64 and will trigger the exception.
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        return arrayGetUnchecked3(this.rawptr, start + index)
    }

    /**
     * @throws IndexOutOfBoundsException if `index` is negative or
     *         greater than or equal to the size of array.
     */
    @Frozen
    @OverflowWrapping
    public operator func [](index: Int64, value!: T): Unit {
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        return arraySetUnchecked(this.rawptr, start + index, value)
    }

    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public operator func [](this @local!, index: Int64, value!: T @local!): Unit {
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        exclave { arraySet2<T>(this.rawptr, start + index, value) }
    }

    /**
     * @throws IllegalArgumentException if the `step` of `range` is not equal to 1.
     * @throws IndexOutOfBoundsException if the `range` is invalid for this array.
     */
    @Frozen
    public operator func [](range: Range<Int64>): Array<T> {
        return rangeSlice(range, this.len)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave operator func [](this @local!, range: Range<Int64>): Array<T> @local! {
        rangeSlice(range, this.len)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave operator func [](this @local?, range: Range<Int64>): Array<T> @local? {
        rangeSlice(range, this.len)
    }

    @Frozen
    public func fill(value: T): Unit {
        for (i in 0..this.len) {
            arraySetUnchecked(this.rawptr, this.start + i, value)
        }
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func fill(this @local!, value: T @local!): Unit {
        for (i in 0..this.len) {
            arraySetUnchecked2<T>(this.rawptr, this.start + i, value)
        }
    }

    /**
     * @throws IllegalArgumentException if the `step` of `range` is not equal to 1,
     *         or the size of `value` is not equal to the length of `range`.
     * @throws IndexOutOfBoundsException if `range` is invalid for this array.
     */
    @Frozen
    public operator func [](range: Range<Int64>, value!: Array<T>): Unit {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }

        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(
                arrayRangeOutOfBoundsExceptionMessage(this.len, range.start, range.end, range.step, range.hasStart,
                    range.hasEnd, range.isClosed))
        }
        let rangeSize = end_ - start_
        if (rangeSize != value.size) {
            throw IllegalArgumentException(arrayInvalidRangeSizeExceptionMessage(value.size, rangeSize))
        }

        intrinsicBuiltInCopyTo<T>(value.rawptr, this.rawptr, value.start, this.start + start_, rangeSize)
    }

    @Frozen
    @When[env != "ohos"]
    public operator func [](this @local!, range: Range<Int64>, value!: Array<T> @local!): Unit {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }
        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(arrayRangeOutOfBoundsExceptionMessage(this.len, range.start, range.end, range.step, range.hasStart, range.hasEnd, range.isClosed))
        }
        let rangeSize = end_ - start_
        if (rangeSize != value.size) {
            throw IllegalArgumentException(arrayInvalidRangeSizeExceptionMessage(value.size, rangeSize))
        }
        exclave {
            intrinsicBuiltInCopyTo2<T>(value.rawptr, this.rawptr, value.start, this.start + start_, rangeSize)
        }
    }

    /** Reverse array elements in place. */
    @Frozen
    @OverflowWrapping
    public func reverse(): Unit {
        var i: Int64 = start
        var j: Int64 = start + len - 1
        while (i < j) {
            let tmp: T = arrayGet(rawptr, i)
            arraySet(rawptr, i, arrayGet(rawptr, j))
            arraySet(rawptr, j, tmp)
            i = i + 1
            j = j - 1
        }
    }

    /** Reverse array elements in place. */
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func reverse(this @local!): Unit {
        var i: Int64 = start
        var j: Int64 = start + len - 1
        while (i < j) {
            let tmp: T @local! = arrayGetUnchecked2(rawptr, i)
            arraySetUnchecked2(rawptr, i, arrayGetUnchecked2(rawptr, j))
            arraySetUnchecked2(rawptr, j, tmp)
            i = i + 1
            j = j - 1
        }
    }

    /**
     * Special processing is performed for 0 in the following cases:
     * When Range is 0..(excluding 0..=)(that is, start=0, hasStart=true, hasStop=false, isClosed=false)
     * If the array or buffer is empty, an empty array or buffer is returned.
     * When Range is 0..0(excluding 0..=0)(that is, start=0, hasStart=true, stop=0, hasStop=true, isClosed=false)
     * If the array or buffer is empty, an empty array or buffer is returned.
     * For other ranges, start and end out-of-bounds check is performed normally,
     * including the range that is actually empty.
     *
     * @param range
     * @param size Size of the collection
     *
     * @return Parameters of start*stop*step*offset.
     * @since 0.25.2
     *
     * @throws IllegalArgumentException if the `step` of `range` is not equal to 1.
     * @throws IndexOutOfBoundsException if the `range` is invalid for this array.
     */
    @Frozen
    private func rangeSlice(range: Range<Int64>, _: Int64): Array<T> {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }

        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(
                arrayRangeOutOfBoundsExceptionMessage(this.len, range.start, range.end, range.step, range.hasStart,
                    range.hasEnd, range.isClosed))
        }
        return Array<T>(this.rawptr, this.start + start_, end_ - start_)
    }

    @When[env != "ohos"]
    @Frozen
    private func rangeSlice(this @local!, range: Range<Int64>, _: Int64): Array<T> @local! {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }
        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(arrayRangeOutOfBoundsExceptionMessage(
                this.len, range.start, range.end, range.step, range.hasStart, range.hasEnd, range.isClosed))
        }
        exclave {
            Array<T>(this.rawptr, this.start + start_, end_ - start_)
        }
    }

    @When[env != "ohos"]
    @Frozen
    private func rangeSlice(this @local?, range: Range<Int64>, _: Int64): Array<T> @local? {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }
        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(arrayRangeOutOfBoundsExceptionMessage(
                this.len, range.start, range.end, range.step, range.hasStart, range.hasEnd, range.isClosed))
        }
        exclave {
            Array<T>(this.rawptr, this.start + start_, end_ - start_)
        }
    }

    // The parameters represents a half-open range [start_, end_)
    @Frozen
    private const func isLegal(start_: Int64, end_: Int64): Bool {
        0 <= start_ && start_ <= end_ && end_ <= this.len
    }

    @When[env != "ohos"]
    @Frozen
    const func isLegal(this @local?, start_: Int64, end_: Int64): Bool {
        0 <= start_ && start_ <= end_ && end_ <= this.len
    }

    // normalize Range<Int64> to half-open range [start, end)
    @Frozen
    @OverflowWrapping
    private const func normalize(range: Range<Int64>): (Int64, Int64) {
        var start = if (range.hasStart) {
            range.start
        } else {
            0
        }
        var end = if (range.hasEnd) {
            range.end
        } else {
            this.len
        }
        if (range.isClosed && range.hasEnd) {
            end += if (range.step > 0) {
                1
            } else {
                -1
            }
        }
        return (start, end)
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    const func normalize(this @local?, range: Range<Int64>): (Int64, Int64) {
        var start = if (range.hasStart) {
            range.start
        } else {
            0
        }
        var end = if (range.hasEnd) {
            range.end
        } else {
            this.len
        }
        if (range.isClosed && range.hasEnd) {
            end += if (range.step > 0) {
                1
            } else {
                -1
            }
        }
        return (start, end)
    }

    // keep for compatibility - do not remove
    private const func rangeToString(range: Range<Int64>): String {
        let start = if (range.hasStart) {
            range.start
        } else {
            0
        }
        let end = if (range.hasEnd) {
            range.end
        } else {
            this.len
        }
        match ((range.step > 0, range.isClosed)) {
            case (true, true) => "[${start}, ${end}]"
            case (true, false) => "[${start}, ${end})"
            case (false, true) => "[${end}, ${start}]"
            case (false, false) => "(${end}, ${start}]"
        }
    }

    private const func rangeToString(this @local?, range: Range<Int64>): String {
        let start = if (range.hasStart) {
            range.start
        } else {
            0
        }
        let end = if (range.hasEnd) {
            range.end
        } else {
            this.len
        }
        match ((range.step > 0, range.isClosed)) {
            case (true, true) => "[${start}, ${end}]"
            case (true, false) => "[${start}, ${end})"
            case (false, true) => "[${end}, ${start}]"
            case (false, false) => "(${end}, ${start}]"
        }
    }

    /** Dummy function, used for function overloading check. */
    @Frozen
    public func clone(): Array<T> {
        if (len == 0) {
            return Array<T>()
        }
        let newRawPtr = rawArrayAllocate<T>(len)
        rawArrayInitByValue(newRawPtr, len, unsafe { zeroValue<T>() })
        intrinsicBuiltInCopyTo<T>(this.rawptr, newRawPtr, this.start, 0, len)
        return Array<T>(newRawPtr, 0, len)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func clone(this @local!): Array<T> @local! {
        if (len == 0) {
            Array<T>()
        } else {
            let newRawPtr = rawArrayAllocate2<T>(len)
            rawArrayInitByValue2(newRawPtr, len, unsafe { zeroValue2<T>() })
            intrinsicBuiltInCopyTo2<T>(this.rawptr, newRawPtr, this.start, 0, len)
            Array<T>(newRawPtr, 0, len)
        }
    }

    @Frozen
    @When[env != "ohos"]
    public func clone(this @local?): Array<T> @local? {
        exclave {
            if (len == 0) {
                Array<T>()
            } else {
                let raw = rawArrayAllocate3<T>(len)
                intrinsicBuiltInCopyTo3<T>(this.rawptr, raw, this.start, 0, len)
                Array<T>(raw, 0, len)
            }
        }
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func toArray(this @local?): Array<T> @local? {
        this.clone()
    }

    /*
     * @throws IndexOutOfBoundsException if the `range` is invalid for this array.
     */
    @Frozen
    @OverflowWrapping
    public func clone(range: Range<Int64>): Array<T> {
        let (start_, end_): (Int64, Int64) = normalize(range)
        let step = range.step
        if ((step > 0 && !isLegal(start_, end_)) || (step < 0 && !isLegal(end_ + 1, start_ + 1))) {
            throw IndexOutOfBoundsException(
                arrayRangeOutOfBoundsExceptionMessage(this.len, range.start, range.end, range.step, range.hasStart,
                    range.hasEnd, range.isClosed))
        }

        let arr: Array<T> = this
        // Size is ceil(|end_ - start_| / |step|). Computing it from magnitudes
        // keeps the intermediate arithmetic inside Int64 even when step is
        // Int64.Max or Int64.Min, where `(end_ - start_ + step - 1) / step`
        // wraps around and yields a negative size.
        let span: Int64 = end_ - start_
        let magnitude: UInt64 = if (span < 0) {
            UInt64(-span)
        } else {
            UInt64(span)
        }
        let stride: UInt64 = if (step < 0) {
            UInt64(-(step + 1)) + 1
        } else {
            UInt64(step)
        }
        let quotient: UInt64 = magnitude / stride
        let newSize: Int64 = Int64(quotient + (if (quotient * stride != magnitude) { 1 } else { 0 }))
        if (step == 1 && newSize != 0) {
            var newArr: Array<T> = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })
            intrinsicBuiltInCopyTo<T>(this.rawptr, newArr.rawptr, this.start + start_, 0, newSize)
            return newArr
        }
        return Array<T>(newSize, {i: Int64 => arr[start_ + step * i]})
    }

    /**
     * @throws IndexOutOfBoundsException if the `range` is invalid for this array.
     */
    @Frozen
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func clone(this @local!, range: Range<Int64>): Array<T> @local! {
        let (start_, end_): (Int64, Int64) = normalize(range)
        let step = range.step
        if ((step > 0 && !isLegal(start_, end_)) || (step < 0 && !isLegal(end_ + 1, start_ + 1))) {
            throw IndexOutOfBoundsException(arrayRangeOutOfBoundsExceptionMessage(
                this.len, range.start, range.end, range.step, range.hasStart, range.hasEnd, range.isClosed))
        }
        let newSize: Int64 = rangeCloneSize(start_, end_, step)
        if (step == 1 && newSize != 0) {
            var newArr: Array<T> @local! = Array<T>(newSize, repeat: unsafe { zeroValue2<T>() })
            intrinsicBuiltInCopyTo2<T>(this.rawptr, newArr.rawptr, this.start + start_, 0, newSize)
            newArr
        } else {
            var newArr: Array<T> @local! = Array<T>(newSize, repeat: unsafe { zeroValue2<T>() })
            for (i in 0..newSize) {
                arraySet2<T>(
                    newArr.rawptr, i, arrayGetUnchecked2<T>(this.rawptr, this.start + start_ + step * i)
                )
            }
            newArr
        }
    }

    /*
     * @throws IllegalArgumentException if `copyLen` is negative.
     * @throws IndexOutOfBoundsException if `srcStart` or `dstStart` is negative, or `srcStart` is
     *         greater or equal to the size of this array, or `dstStart` is greater or equal to
     *         the size of `dst`, or `copyLen` is out of bounds.
     */
    @Frozen
    public func copyTo(dst: Array<T>, srcStart: Int64, dstStart: Int64, copyLen: Int64): Unit {
        if (copyLen == 0) {
            return
        }
        if (copyLen < 0) {
            throw IllegalArgumentException("Invalid argument 'copyLen': expected a non-negative value, got '${copyLen}'.")
        }
        if (srcStart < 0 || dstStart < 0) {
            throw IndexOutOfBoundsException("Index out of bounds: negative index, srcStart is '${srcStart}', dstStart is '${dstStart}'.")
        }
        if (srcStart >= this.len) {
            throw IndexOutOfBoundsException("Index out of bounds: srcStart '${srcStart}' is greater than or equal to array size '${this.len}'.")
        }
        if (dstStart >= dst.size) {
            throw IndexOutOfBoundsException("Index out of bounds: dstStart '${dstStart}' is greater than or equal to target array size '${dst.size}'.")
        }
        if (copyLen > this.len - srcStart || copyLen > dst.size - dstStart) {
            throw IndexOutOfBoundsException("Copy length out of bounds: copyLen is '${copyLen}', but available source length is '${this.len - srcStart}' and available destination length is '${dst.size - dstStart}'.")
        }
        intrinsicBuiltInCopyTo<T>(this.rawptr, dst.rawptr, this.start + srcStart, dst.start + dstStart, copyLen)
    }
    
    @Frozen
    @When[env != "ohos"]
    public exclave func copyTo(this @local!, dst: Array<T> @local!, srcStart: Int64, dstStart: Int64, copyLen: Int64): Unit {
        if (copyLen == 0) {
            return
        }
        if (copyLen < 0) {
            throw IllegalArgumentException("Invalid argument 'copyLen': expected a non-negative value, got '${copyLen}'.")
        }
        if (srcStart < 0 || dstStart < 0) {
            throw IndexOutOfBoundsException("Index out of bounds: negative index, srcStart is '${srcStart}', dstStart is '${dstStart}'.")
        }
        if (srcStart >= this.len) {
            throw IndexOutOfBoundsException("Index out of bounds: srcStart '${srcStart}' is greater than or equal to array size '${this.len}'.")
        }
        if (dstStart >= dst.size) {
            throw IndexOutOfBoundsException("Index out of bounds: dstStart '${dstStart}' is greater than or equal to target array size '${dst.size}'.")
        }
        if (copyLen > this.len - srcStart || copyLen > dst.size - dstStart) {
            throw IndexOutOfBoundsException("Copy length out of bounds: copyLen is '${copyLen}', but available source length is '${this.len - srcStart}' and available destination length is '${dst.size - dstStart}'.")
        }
        intrinsicBuiltInCopyTo2<T>(this.rawptr, dst.rawptr, this.start + srcStart, dst.start + dstStart, copyLen)
    }

    @Frozen
    public func copyTo(dst: Array<T>): Unit {
        if (this.len == 0) {
            return
        }
        if (dst.size < this.len) {
            throw IllegalArgumentException("Destination array size '${dst.size}' is less than source array size '${this.len}'.")
        }
        intrinsicBuiltInCopyTo<T>(this.rawptr, dst.rawptr, this.start, dst.start, this.len)
    }
    
    @Frozen
    @When[env != "ohos"]
    public func copyTo(this @local!, dst: Array<T> @local!): Unit {
        exclave {
        if (this.len == 0) {
            return
        }
        if (dst.size < this.len) {
            throw IllegalArgumentException("Destination array size '${dst.size}' is less than source array size '${this.len}'.")
        }
        intrinsicBuiltInCopyTo2<T>(this.rawptr, dst.rawptr, this.start, dst.start, this.len)
        }
    }

    /*
     * Returns a new Array concat this and that
     *
     * `other` will be copied to the new array
     *
     * returns a new array, size is `this.size + that.size`
     */
    @Frozen
    public func concat(other: Array<T>): Array<T> {
        if (this.len == 0) {
            return other.clone()
        }
        if (other.len == 0) {
            return this.clone()
        }
        let newSize = this.len + other.len
        let newArr = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })

        intrinsicBuiltInCopyTo<T>(this.rawptr, newArr.rawptr, this.start, 0, this.len)
        intrinsicBuiltInCopyTo<T>(other.rawptr, newArr.rawptr, other.start, this.len, other.len)
        newArr
    }

    @Frozen
    @When[env != "ohos"]
    public func concat(this @local!, other: Array<T> @local!): Array<T> @local! {
        exclave {
            if (this.len == 0) {
                return other.clone()
            }
            if (other.len == 0) {
                return this.clone()
            }
            let newSize = this.len + other.len
            let newArr: Array<T> @local! = Array<T>(newSize, repeat: unsafe { zeroValue2<T>() })
            intrinsicBuiltInCopyTo2<T>(this.rawptr, newArr.rawptr, this.start, 0, this.len)
            intrinsicBuiltInCopyTo2<T>(other.rawptr, newArr.rawptr, other.start, this.len, other.len)
            newArr
        }
    }

    @Frozen
    @OverflowWrapping
    protected unsafe func getUnchecked(index: Int64): T {
        return arrayGetUnchecked(this.rawptr, start + index)
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    protected unsafe func getUnchecked(this @local!, index: Int64): T @local! {
        exclave { arrayGetUnchecked2<T>(this.rawptr, start + index) }
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    protected unsafe func getUnchecked(this @local?, index: Int64): T @local? {
        exclave { arrayGetUnchecked3<T>(this.rawptr, start + index) }
    }

    @Frozen
    @OverflowWrapping
    protected unsafe func setUnchecked(index: Int64, element: T): Unit {
        return arraySetUnchecked(this.rawptr, start + index, element)
    }

    @When[env != "ohos"]
    @Frozen
    @OverflowWrapping
    protected exclave unsafe func setUnchecked(this @local!, index: Int64, element: T @local!): Unit {
        return arraySetUnchecked2(this.rawptr, start + index, element)
    }

    @Frozen
    public func swap(index1: Int64, index2: Int64): Unit {
        if (index1 < 0 || len <= index1) {
            throw IllegalArgumentException("Invalid argument 'index1': index '${index1}' is out of bounds, array size is '${len}'.")
        }
        if (index2 < 0 || len <= index2) {
            throw IllegalArgumentException("Invalid argument 'index2': index '${index2}' is out of bounds, array size is '${len}'.")
        }
        if (index1 == index2) {
            return
        }
        let tmp = arrayGetUnchecked(this.rawptr, start + index1)
        arraySetUnchecked(this.rawptr, start + index1, arrayGetUnchecked(this.rawptr, start + index2))
        arraySetUnchecked(this.rawptr, start + index2, tmp)
    }

    @Frozen
    @When[env != "ohos"]
    public exclave func swap(this @local!, index1: Int64, index2: Int64): Unit {
        if (index1 < 0 || len <= index1) {
            throw IllegalArgumentException("Index1 is less than 0 or not less than the size of this array.")
        }
        if (index2 < 0 || len <= index2) {
            throw IllegalArgumentException("Index2 is less than 0 or not less than the size of this array.")
        }
        if (index1 == index2) {
            return
        }
        let tmp: T @local! = arrayGetUnchecked2(this.rawptr, start + index1)
        arraySetUnchecked2(this.rawptr, start + index1, arrayGetUnchecked2(this.rawptr, start + index2))
        arraySetUnchecked2(this.rawptr, start + index2, tmp)
    }

    @Frozen
    public func splitAt(mid: Int64): (Array<T>, Array<T>) {
        if (mid < 0 || this.len < mid) {
            throw IllegalArgumentException("Invalid argument 'mid': value '${mid}' is out of bounds, array size is '${this.len}'.")
        }
        if (this.len == 0) {
            return (this, this)
        }
        let left = Array<T>(this.rawptr, this.start, mid)
        let right = Array<T>(this.rawptr, this.start + mid, this.len - mid)
        return (left, right)
    }

    @Frozen
    @When[env != "ohos"]
    public func splitAt(this @local!, mid: Int64): (Array<T>, Array<T>) @local! {
        exclave {
            if (mid < 0 || this.len < mid) {
                throw IllegalArgumentException("Mid is less than 0 or not less than the size of this array.")
            }
            if (this.len == 0) {
                return (this, this)
            }
            let left: Array<T> @local! = Array<T>(this.rawptr, this.start, mid)
            let right: Array<T> @local! = Array<T>(this.rawptr, this.start + mid, this.len - mid)
            (left, right)
        }
    }

    @Frozen
    public func repeat(n: Int64): Array<T> {
        if (n <= 0) {
            throw IllegalArgumentException("Invalid argument 'n': expected a positive value, got '${n}'.")
        }
        if (this.len == 0) {
            return this
        }
        let newLen = this.len * n
        let newRawPtr = rawArrayAllocate<T>(newLen)
        rawArrayInitByValue(newRawPtr, newLen, unsafe { zeroValue<T>() })
        for (i in 0..n) {
            intrinsicBuiltInCopyTo<T>(this.rawptr, newRawPtr, this.start, this.len * i, this.len)
        }
        return Array<T>(newRawPtr, 0, newLen)
    }

    @Frozen
    @When[env != "ohos"]
    public func repeat(this @local!, n: Int64): Array<T> @local! {
        exclave {
            if (n <= 0) {
                throw IllegalArgumentException("N is less than or equal to 0.")
            }
            if (this.len == 0) {
                return this
            }
            let newLen = this.len * n
            let newRawPtr = rawArrayAllocate2<T>(newLen)
            rawArrayInitByValue2(newRawPtr, newLen, unsafe { zeroValue2<T>() })
            var i: Int64 = 0
            while (i < n) {
                intrinsicBuiltInCopyTo2<T>(this.rawptr, newRawPtr, this.start, this.len * i, this.len)
                i = i + 1
            }
            Array<T>(newRawPtr, 0, newLen)
        }
    }

    @Frozen
    public func map<R>(transform: (T) -> R): Array<R> {
        return Array<R>(this.len, {idx => transform(this[idx])})
    }

    @Frozen
    @When[env != "ohos"]
    public func map<R>(this @local!, transform: ((T @local!) -> R @local!) @local?): Array<R> @local! {
        exclave {
            let newRawPtr = rawArrayAllocate2<R>(this.len)
            rawArrayInitByValue2(newRawPtr, this.len, unsafe { zeroValue2<R>() })
            var i: Int64 = 0
            while (i < this.len) {
                let v: T @local! = arrayGetUnchecked2<T>(this.rawptr, start + i)
                let r: R @local! = transform(v)
                arraySet2<R>(newRawPtr, i, r)
                i = i + 1
            }
            Array<R>(newRawPtr, 0, this.len)
        }
    }

    /**
     * @description Extracts elements from the array at specified intervals and returns a new array.
     * 
     * @param count the interval for selection.
     * @returns a new array containing all elements extracted from the source array at intervals.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func step(count: Int64): Array<T> {
        if (count <= 0) {
            throw IllegalArgumentException("Invalid argument 'count': expected a positive value, got '${count}'.")
        }

        if (len > 0) {
            let newSize: Int64 = (len - 1) / count + 1
            var newRawPtr = rawArrayAllocate<T>(newSize)
            rawArrayInitByValue(newRawPtr, newSize, unsafe { zeroValue<T>() })
            let oldLastIndex: Int64 = (newSize - 1) * count
            var j: Int64 = newSize - 1
            for (i in oldLastIndex..=0 : -count) {
                let value = unsafe { getUnchecked(i) }
                arraySet(newRawPtr, j, value)
                j--
            }
            return Array<T>(newRawPtr, 0, newSize)
        }
        return Array<T>()
    }

    @When[env != "ohos"]
    public func step(this @local!, count: Int64): Array<T> @local! {
        exclave {
            if (count <= 0) {
                throw IllegalArgumentException("Step count must be greater than 0!")
            }

            if (len == 0) {
                return Array<T>()
            }
            let newSize: Int64 = (len - 1) / count + 1
            var newRawPtr = rawArrayAllocate2<T>(newSize)
            rawArrayInitByValue2(newRawPtr, newSize, unsafe { zeroValue2<T>() })
            let oldLastIndex: Int64 = (newSize - 1) * count
            var j: Int64 = newSize - 1
            for (i in oldLastIndex..=0 : -count) {
                let value: T @local! = arrayGetUnchecked2<T>(this.rawptr, start + i)
                arraySet2<T>(newRawPtr, j, value)
                j--
            }
            Array<T>(newRawPtr, 0, newSize)
        }
    }

    /**
     * @description Extracts a specific number of elements from the array and returns a new array.
     * 
     * @param count the number of elements to take.
     * @returns a new array with the specified number of elements taken.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func take(count: Int64): Array<T> {
        if (count == 0) {
            return Array<T>()
        }
        if (count < 0) {
            throw IllegalArgumentException("Invalid argument 'count': expected a non-negative value, got '${count}'.")
        }
        let newLen = min(count, this.len)
        let newRawPtr = rawArrayAllocate<T>(newLen)
        rawArrayInitByValue(newRawPtr, newLen, unsafe { zeroValue<T>() })
        intrinsicBuiltInCopyTo<T>(this.rawptr, newRawPtr, this.start, 0, newLen)
        return Array<T>(newRawPtr, 0, newLen)
    }

    @When[env != "ohos"]
    public func take(this @local!, count: Int64): Array<T> @local! {
        exclave {
            if (count == 0) {
                return Array<T>()
            }
            if (count < 0) {
                throw IllegalArgumentException("take count must be greater than 0!")
            }
            let newLen = min(count, this.len)
            let newRawPtr = rawArrayAllocate2<T>(newLen)
            rawArrayInitByValue2(newRawPtr, newLen, unsafe { zeroValue2<T>() })
            intrinsicBuiltInCopyTo2<T>(this.rawptr, newRawPtr, this.start, 0, newLen)
            Array<T>(newRawPtr, 0, newLen)
        }
    }

    /**
     * @description Skips a specific number of elements and returns a new array.
     * 
     * @param count the number of elements to skip.
     * @returns a new array with the specified number of elements skipped.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func skip(count: Int64): Array<T> {
        if (count < 0) {
            throw IllegalArgumentException("Invalid argument 'count': expected a non-negative value, got '${count}'.")
        }
        if (count == 0) {
            return Array(this.toRawArray(), this.start, this.len)
        }
        let newLen = this.len - count
        if (newLen <= 0) {
            return Array<T>()
        }

        let newRawPtr = rawArrayAllocate<T>(newLen)
        rawArrayInitByValue(newRawPtr, newLen, unsafe { zeroValue<T>() })
        intrinsicBuiltInCopyTo<T>(this.rawptr, newRawPtr, this.start + count, 0, newLen)
        return Array<T>(newRawPtr, 0, newLen)
    }

    @When[env != "ohos"]
    public func skip(this @local!, count: Int64): Array<T> @local! {
        exclave {
            if (count < 0) {
                throw IllegalArgumentException("skip count must be greater than 0!")
            }
            let newLen = this.len - count
            if (newLen <= 0) {
                return Array<T>()
            }

            let newRawPtr = rawArrayAllocate2<T>(newLen)
            rawArrayInitByValue2(newRawPtr, newLen, unsafe { zeroValue2<T>() })
            intrinsicBuiltInCopyTo2<T>(this.rawptr, newRawPtr, this.start + count, 0, newLen)
            Array<T>(newRawPtr, 0, newLen)
        }
    }

    /**
     * @description Returns a new array containing elements that satisfy the filtering condition.
     * 
     * @param predicate the given condition.
     * @returns a new array containing elements that satisfy the filtering condition.
     */
    @When[env != "ohos"]
    public func filter(predicate: (T) -> Bool): Array<T> {
        if (this.len == 0) {
            return Array<T>()
        }
        var newRawPtr = rawArrayAllocate<T>(this.len)
        rawArrayInitByValue(newRawPtr, this.len, unsafe { zeroValue<T>() })
        var t = 0
        for (i in 0..this.len) {
            let value = unsafe { getUnchecked(i) }
            if (predicate(value)) {
                arraySet(newRawPtr, t, value)
                t++
            }
        }
        return Array<T>(newRawPtr, 0, t)
    }

    @When[env != "ohos"]
    public func filter(this @local!, predicate: ((T @local?) -> Bool) @local?): Array<T> @local! {
        exclave {
            if (this.len == 0) {
                return Array<T>()
            }
            var newRawPtr = rawArrayAllocate2<T>(this.len)
            rawArrayInitByValue2(newRawPtr, this.len, unsafe { zeroValue2<T>() })
            var t = 0
            var i: Int64 = 0
            while (i < this.len) {
                let value: T @local! = arrayGetUnchecked2<T>(this.rawptr, start + i)
                if (predicate(value)) {
                    arraySet2<T>(newRawPtr, t, value)
                    t++
                }
                i = i + 1
            }
            Array<T>(newRawPtr, 0, t)
        }
    }

    /**
     * @description Applies a transformation closure (transform) to each element in the array, where the closure returns an array, then "flattens" and concatenates all returned arrays into a single result array.
     * 
     * @param transform the given mapping function.
     * @returns the new array after being "mapped" and "flattened".
     */
    @When[env != "ohos"]
    public func flatMap<R>(transform: (T) -> Array<R>): Array<R> {
        var result: Array<R> = Array<R>()
        for (i in 0..this.len) {
            result = result.concat(transform(unsafe { getUnchecked(i) }))
        }
        return result
    }

    @When[env != "ohos"]
    public func flatMap<R>(this @local!, transform: ((T @local!) -> Array<R> @local!) @local?): Array<R> @local! {
        exclave {
            // Amortised linear: grow the buffer geometrically and copy only the newly appended run.
            // Concatenating one element at a time re-allocated the whole result and re-copied its
            // prefix every round, so the total copy volume was O(n^2) and the process ran out of
            // room at n=2000 (SIGSEGV in Array copy).
            var result: Array<R> @local! = Array<R>(0, repeat: unsafe { zeroValue2<R>() })
            var used: Int64 = 0
            var i: Int64 = 0
            while (i < this.len) {
                let value: T @local! = arrayGetUnchecked2<T>(this.rawptr, start + i)
                let part: Array<R> @local! = transform(value)
                let sz: Int64 = part.len
                if (sz > 0) {
                    let need: Int64 = used + sz
                    if (need > result.len) {
                        var cap: Int64 = if (result.len == 0) { sz } else { result.len }
                        while (cap < need) {
                            cap = cap + (cap >> 1) + 1
                        }
                        let grown: Array<R> @local! = Array<R>(cap, repeat: unsafe { zeroValue2<R>() })
                        if (used > 0) {
                            intrinsicBuiltInCopyTo2<R>(result.rawptr, grown.rawptr, result.start, 0, used)
                        }
                        result = grown
                    }
                    intrinsicBuiltInCopyTo2<R>(part.rawptr, result.rawptr, part.start, used, sz)
                    used = need
                }
                i = i + 1
            }
            if (used == result.len) {
                result
            } else {
                // Trim to the logical length so the caller never observes the spare capacity.
                let exact: Array<R> @local! = Array<R>(used, repeat: unsafe { zeroValue2<R>() })
                if (used > 0) {
                    intrinsicBuiltInCopyTo2<R>(result.rawptr, exact.rawptr, result.start, 0, used)
                }
                exact
            }
        }
    }

    /**
     * @description Performs filtering and mapping operations simultaneously, returning a new array.
     * 
     * @param transform the given mapping function. If the function's return value is Some, it corresponds to the filter's predicate being true; 
              otherwise, it is false.
     * @returns a new array after filtering and mapping.
     */
    @When[env != "ohos"]
    public func filterMap<R>(transform: (T) -> ?R): Array<R> {
        if (this.len == 0) {
            return Array<R>()
        }

        let newRawPtr = rawArrayAllocate<R>(this.len)
        rawArrayInitByValue(newRawPtr, this.len, unsafe { zeroValue<R>() })
        var j = 0
        for (i in 0..this.len) {
            let value = unsafe { getUnchecked(i) }
            match (transform(value)) {
                case Some(v) =>
                    arraySet(newRawPtr, j, v)
                    j++
                case None => continue
            }
        }
        return Array<R>(newRawPtr, 0, j)
    }

    @When[env != "ohos"]
    public func filterMap<R>(this @local!, transform: ((T @local!) -> Option<R> @local!) @local?): Array<R> @local! {
        exclave {
            if (this.len == 0) {
                return Array<R>()
            }

            let newRawPtr = rawArrayAllocate2<R>(this.len)
            rawArrayInitByValue2(newRawPtr, this.len, unsafe { zeroValue2<R>() })
            var j = 0
            var i: Int64 = 0
            while (i < this.len) {
                let value: T @local! = arrayGetUnchecked2<T>(this.rawptr, start + i)
                let transformed: Option<R> @local! = transform(value)
                if (let Some(v) <- transformed) {
                    arraySet2<R>(newRawPtr, j, v)
                    j++
                }
                i = i + 1
            }
            Array<R>(newRawPtr, 0, j)
        }
    }

    /**
     * @description Returns a new array with the given element inserted between every two elements.
     * 
     * @param separator the given element.
     * @returns a new array.
     */
    @When[env != "ohos"]
    public func intersperse(separator: T): Array<T> {
        if (this.len < 2) {
            return this.clone()
        }
        let newSize: Int64 = 2 * this.len - 1
        let newRawPtr = rawArrayAllocate<T>(newSize)
        rawArrayInitByValue(newRawPtr, newSize, unsafe { zeroValue<T>() })

        for (i in 0..this.len - 1) {
            arraySet(newRawPtr, 2*i, unsafe { getUnchecked(i) })
            arraySet(newRawPtr, 2*i + 1, separator)
        }
        arraySet(newRawPtr, newSize - 1, unsafe { getUnchecked(this.len - 1) })
        return Array<T>(newRawPtr,0,newSize)
    }

    @When[env != "ohos"]
    public func intersperse(this @local!, separator: T @local!): Array<T> @local! {
        exclave {
            if (this.len < 2) {
                return this.clone()
            }
            let newSize: Int64 = 2 * this.len - 1
            let newRawPtr = rawArrayAllocate2<T>(newSize)
            rawArrayInitByValue2(newRawPtr, newSize, unsafe { zeroValue2<T>() })

            for (i in 0..this.len - 1) {
                arraySet2<T>(newRawPtr, 2*i, arrayGetUnchecked2<T>(this.rawptr, start + i))
                arraySet2<T>(newRawPtr, 2*i + 1, separator)
            }
            arraySet2<T>(newRawPtr, newSize - 1, arrayGetUnchecked2<T>(this.rawptr, start + this.len - 1))
            Array<T>(newRawPtr,0,newSize)
        }
    }

    /**
     * @description Iterates over all elements and performs the given operation.
     * 
     * @param action the given operation function.
     */
    @When[env != "ohos"]
    public func forEach(action: (T) -> Unit): Unit {
        for (i in 0..this.len) {
            action(unsafe{ getUnchecked(i) })
        }
    }

    @When[env != "ohos"]
    public exclave func forEach(this @local!, action: ((T @local!) -> Unit) @local?): Unit {
        var i: Int64 = 0
        while (i < this.len) {
            action(arrayGetUnchecked2<T>(this.rawptr, start + i))
            i = i + 1
        }
    }

    /**
     * @description Determine whether all elements in the array satisfy the condition.
     * 
     * @param predicate the given condition.
     * @returns true if all elements in the array satisfy the condition, otherwise returns false.
     */
    @When[env != "ohos"]
    public func all(predicate: (T) -> Bool): Bool {
        for (i in 0..this.len) {
            if (!predicate(unsafe { getUnchecked(i) })) {
                return false
            }
        }
        return true
    }

    @When[env != "ohos"]
    public func all(this @local?, predicate: ((T @local?) -> Bool) @local?): Bool {
        var i: Int64 = 0
        while (i < this.len) {
            if (!predicate(arrayGetUnchecked3<T>(this.rawptr, start + i))) {
                return false
            }
            i = i + 1
        }
        true
    }

    /**
     * @description Determine whether all elements in the array satisfy the condition.
     * 
     * @param predicate the given condition.
     * @returns Whether there is any element that satisfies the condition.
     */
    @When[env != "ohos"]
    public func any(predicate: (T) -> Bool): Bool {
        for (i in 0..this.len) {
            if (predicate(unsafe{getUnchecked(i)})) {
                return true
            }
        }
        return false
    }

    @When[env != "ohos"]
    public func any(this @local?, predicate: ((T @local?) -> Bool) @local?): Bool {
        var i: Int64 = 0
        while (i < this.len) {
            if (predicate(arrayGetUnchecked3<T>(this.rawptr, start + i))) {
                return true
            }
            i = i + 1
        }
        false
    }

    /**
     * @description Determine whether all elements in the array do not satisfy the condition.
     * 
     * @param separator the given element.
     * @returns a new array.
     */
    @When[env != "ohos"]
    public func none(predicate: (T) -> Bool): Bool {
        for (i in 0..this.len) {
            if (predicate(unsafe{getUnchecked(i)})) {
                return false
            }
        }
        return true
    }

    @When[env != "ohos"]
    public func none(this @local?, predicate: ((T @local?) -> Bool) @local?): Bool {
        var i: Int64 = 0
        while (i < this.len) {
            if (predicate(arrayGetUnchecked3<T>(this.rawptr, start + i))) {
                return false
            }
            i = i + 1
        }
        true
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
        for (i in 0..this.len) {
            result = operation(result, unsafe{getUnchecked(i)})
        }
        return result
    }

    @When[env != "ohos"]
    public func fold<R>(this @local!, initial: R @local!, operation: ((R @local!, T @local!) -> R @local!) @local?): R @local! {
        exclave {
            var result: R @local! = initial
            var i: Int64 = 0
            while (i < this.len) {
                result = operation(result, arrayGetUnchecked2<T>(this.rawptr, start + i))
                i = i + 1
            }
            result
        }
    }

    /**
     * @description Compute from left to right using the first element as the initial value.
     * 
     * @param operation the given computation function.
     * @returns the computation result.
     */
    @When[env != "ohos"]
    public func reduce(operation: (T, T) -> T): Option<T> {
        if (this.len == 0) {
            return None<T>
        }
        var result: T = unsafe{getUnchecked(0)}
        for (i in 1..this.len) {
            result = operation(result, unsafe{getUnchecked(i)})
        }
        return result
    }

}

extend<T> Array<T> {
    /**
     * @description Merges two arrays into a new array (the length depends on the shorter array).
     * 
     * @param other one of the arrays to be merged.
     * @returns a new array.
     */
    @When[env != "ohos"]
    public func zip<R>(other: Array<R>): Array<(T, R)> {
        let newSize: Int64 = min(this.len, other.size)
        if (newSize == 0) {
            return Array<(T, R)>()
        }
        let newRawPtr = rawArrayAllocate<(T,R)>(newSize)
        rawArrayInitByValue(newRawPtr, newSize, unsafe { zeroValue<(T,R)>() })
        for (i in newSize - 1..=0 : -1) {
            arraySet(newRawPtr,i,unsafe{(getUnchecked(i),other.getUnchecked(i))})
        }
        return Array<(T,R)>(newRawPtr,0,newSize)
    }

    /**
     * @description Used to obtain an array with indices.
     * 
     * @returns a new array with indices.
     */
    @When[env != "ohos"]
    public func enumerate(): Array<(Int64, T)> {
        if (this.len == 0) {
            return Array<(Int64, T)>()
        }
        let newRawPtr = rawArrayAllocate<(Int64,T)>(this.len)
        rawArrayInitByValue(newRawPtr, this.len, unsafe { zeroValue<(Int64,T)>() })
        for (i in this.len - 1..=0 : -1) {
            arraySet(newRawPtr,i,(i,unsafe{getUnchecked(i)}))
        }
        return Array<(Int64,T)>(newRawPtr,0,this.len)
    }

}

extend<T> Array<Array<T>> {
    @Frozen
    public func flatten(): Array<T> {
        var newLen = 0
        for (i in 0..this.len) {
            newLen += this[i].len
        }
        let newRawPtr = rawArrayAllocate<T>(newLen)
        rawArrayInitByValue(newRawPtr, newLen, unsafe { zeroValue<T>() })

        var newIdx = 0
        for (i in 0..this.len) {
            intrinsicBuiltInCopyTo<T>(this[i].rawptr, newRawPtr, this[i].start, newIdx, this[i].len)
            newIdx += this[i].len
        }
        return Array<T>(newRawPtr, 0, newLen)
    }

}

private func rangeToString(arraySize: Int64, start: Int64, end: Int64,
    step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool): String {
    let rangeStart = if (hasStart) {
        start
    } else {
        0
    }
    let rangeEnd = if (hasEnd) {
        end
    } else {
        arraySize
    }
    match ((step > 0, isClosed)) {
        case (true, true) => "[${rangeStart}, ${rangeEnd}]"
        case (true, false) => "[${rangeStart}, ${rangeEnd})"
        case (false, true) => "[${rangeEnd}, ${rangeStart}]"
        case (false, false) => "(${rangeEnd}, ${rangeStart}]"
    }
}

private func arraySliceOutOfBoundsExceptionMessage(arraySize: Int64, sliceStart: Int64, sliceLength: Int64): String {
    "Slice out of bounds: start is '${sliceStart}', length is '${sliceLength}', but array size is '${arraySize}'."
}

private func arrayIndexOutOfBoundsExceptionMessage(arraySize: Int64, index: Int64): String {
    "Index out of bounds: index is '${index}', but array size is '${arraySize}'."
}

private func arrayRangeOutOfBoundsExceptionMessage(
    arraySize: Int64, start: Int64, end: Int64, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool): String {
    "Range out of bounds: range is '${rangeToString(arraySize, start, end, step, hasStart, hasEnd, isClosed)}', but array size is '${arraySize}'."
}

private func arrayInvalidRangeSizeExceptionMessage(arraySize: Int64, rangeSize: Int64): String {
    "Array size '${arraySize}' does not match range size '${rangeSize}'."
}

private func arrayInvalidRangeStepExceptionMessage(rangeStep: Int64): String {
    "Array slice step must be 1, got '${rangeStep}'."
}

public interface Copyable {}

@When[env != "ohos"]
extend<T> Array<T> where T <: Copyable {

    @Frozen
    @OverflowWrapping
    public operator func [](this @local?, index: Int64, value!: T): Unit {
        // Using type conversion to replace typical bounds checking,
        // if (index < 0 || index >= this.len), to a single comparison.
        // The negative value of index will be converted to a large positive number
        // when `index` and `this.len` are interpreted as UInt64 and will trigger the exception.
        if (UInt64(index) >= UInt64(this.len)) {
            throw IndexOutOfBoundsException(arrayIndexOutOfBoundsExceptionMessage(this.len, index))
        }
        arraySetUnchecked3<T>(this.rawptr, start + index, value)
    }

    @Frozen
    public operator func [](this @local?, range: Range<Int64>, value!: Array<T> @local?): Unit {
        if (range.step != 1) {
            throw IllegalArgumentException(arrayInvalidRangeStepExceptionMessage(range.step))
        }
        let (start_, end_): (Int64, Int64) = normalize(range)
        if (!isLegal(start_, end_)) {
            throw IndexOutOfBoundsException(arrayRangeOutOfBoundsExceptionMessage(
                this.len, range.start, range.end, range.step, range.hasStart, range.hasEnd, range.isClosed))
        }
        let rangeSize = end_ - start_
        if (rangeSize != value.size) {
            throw IllegalArgumentException(arrayInvalidRangeSizeExceptionMessage(value.size, rangeSize))
        }
        intrinsicBuiltInCopyTo3<T>(value.rawptr, this.rawptr, value.start, this.start + start_, rangeSize)
    }

    @Frozen
    public func fill(this @local?, value: T): Unit {
        for (i in 0..this.len) {
            arraySet3<T>(this.rawptr, this.start + i, value)
        }
    }

    @Frozen
    public func copyTo(this @local?, dst: Array<T> @local?): Unit {
        if (this.len == 0) {
            return
        }
        if (dst.size < this.len) {
            throw IllegalArgumentException("Destination array size '${dst.size}' is less than source array size '${this.len}'.")
        }
        intrinsicBuiltInCopyTo3<T>(this.rawptr, dst.rawptr, this.start, dst.start, this.len)
    }

    @Frozen
    public func copyTo(this @local?, dst: Array<T> @local?, srcStart: Int64, dstStart: Int64, copyLen: Int64): Unit {
        if (copyLen == 0) {
            return
        }
        if (copyLen < 0) {
            throw IllegalArgumentException("Invalid argument 'copyLen': expected a non-negative value, got '${copyLen}'.")
        }
        if (srcStart < 0 || dstStart < 0) {
            throw IndexOutOfBoundsException("Index out of bounds: negative index, srcStart is '${srcStart}', dstStart is '${dstStart}'.")
        }
        if (srcStart >= this.len) {
            throw IndexOutOfBoundsException("Index out of bounds: srcStart '${srcStart}' is greater than or equal to array size '${this.len}'.")
        }
        if (dstStart >= dst.size) {
            throw IndexOutOfBoundsException("Index out of bounds: dstStart '${dstStart}' is greater than or equal to target array size '${dst.size}'.")
        }
        if (copyLen > this.len - srcStart || copyLen > dst.size - dstStart) {
            throw IndexOutOfBoundsException("Copy length out of bounds: copyLen is '${copyLen}', but available source length is '${this.len - srcStart}' and available destination length is '${dst.size - dstStart}'.")
        }
        intrinsicBuiltInCopyTo3<T>(this.rawptr, dst.rawptr, this.start + srcStart, dst.start + dstStart, copyLen)
    }

    @Frozen
    public func swap(this @local?, index1: Int64, index2: Int64): Unit {
        if (index1 < 0 || this.len <= index1) {
            throw IllegalArgumentException("Index1 is less than 0 or not less than the size of this array.")
        }
        if (index2 < 0 || this.len <= index2) {
            throw IllegalArgumentException("Index2 is less than 0 or not less than the size of this array.")
        }
        if (index1 == index2) {
            return
        }
        let tmp = arrayGetUnchecked3<T>(this.rawptr, this.start + index1)
        arraySet3<T>(this.rawptr, this.start + index1, arrayGetUnchecked3<T>(this.rawptr, this.start + index2))
        arraySet3<T>(this.rawptr, this.start + index2, tmp)
    }

    @Frozen
    @OverflowWrapping
    public func reverse(this @local?): Unit {
        var i: Int64 = this.start
        var j: Int64 = this.start + this.len - 1
        while (i < j) {
            let tmp = arrayGetUnchecked3<T>(this.rawptr, i)
            arraySet3<T>(this.rawptr, i, arrayGetUnchecked3<T>(this.rawptr, j))
            arraySet3<T>(this.rawptr, j, tmp)
            i = i + 1
            j = j - 1
        }
    }

    @Frozen
    @OverflowWrapping
    protected unsafe func setUnchecked(this @local?, index: Int64, element: T): Unit {
        arraySetUnchecked3<T>(this.rawptr, this.start + index, element)
    }

    @Frozen
    internal func cloneToLocal(this @local?): Array<T> @local! {
        exclave {
            if (len == 0) {
                Array<T>()
            } else {
                let newRawPtr = rawArrayAllocate2<T>(len)
                rawArrayInitByValue2(newRawPtr, len, unsafe { zeroValue2<T>() })
                intrinsicBuiltInCopyTo3<T>(this.rawptr, newRawPtr, this.start, 0, len)
                Array<T>(newRawPtr, 0, len)
            }
        }
    }

}
