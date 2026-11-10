/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@ConstSafe
public struct Range<T> <: Iterable<T> where T <: Countable<T> & Comparable<T> & Equatable<T> {
    public let start: T
    public let end: T
    public let step: Int64
    public let hasStart: Bool
    public let hasEnd: Bool
    public let isClosed: Bool

    /*
     * @throws IllegalArgumentException if the value of the step is equal to zero
     */
    @Frozen
    public const init(start: T, end: T, step: Int64, hasStart: Bool, hasEnd: Bool, isClosed: Bool) {
        if (step == 0) {
            throw IllegalArgumentException("Invalid argument 'step': must be non-zero.")
        }
        this.start = start
        this.end = end
        this.step = step
        this.hasStart = hasStart
        this.hasEnd = hasEnd
        this.isClosed = isClosed
    }

    @Frozen
    public func iterator(): Iterator<T> {
        return RangeIterator<T>(start, last(), step, isEmpty())
    }

    public const func isEmpty(): Bool {
        if (isClosed) {
            if (step > 0) {
                return start > end
            }
            return start < end
        } else {
            if (step > 0) {
                return start >= end
            }
            return start <= end
        }
    }

    /**
     * Calculates the last value contained in this range (may not equal `start`).
     *
     * Note: this function has a sensible value only for non-empty ranges.
     */
    @OverflowWrapping
    private const func last() {
        if (step != 1 && step != -1) {
            let (lower, upper, absStep) = if (step > 0) {
                (start, end, step)
            } else {
                (end, start, -step)
            }
            let gap = UInt64(upper.position() - lower.position())
            let rem = Int64(gap % UInt64(absStep))
            if (rem != 0) {
                if (step > 0) {
                    return end.next(-rem)
                } else {
                    return end.next(rem)
                }
            }
        }
        if (isClosed) {
            end
        } else {
            end.next(-step)
        }
    }
}

@When[env != "ohos"]
extend<T> Range<T> <: Copyable where T <: Copyable {}

public class RangeIterator<T> <: Iterator<T> where T <: Countable<T> & Comparable<T> & Equatable<T> {
    private let _last: T
    private let _step: Int64

    private var cur: T
    private var hasNext: Bool

    init(first: T, last: T, step: Int64, isEmpty: Bool) {
        this._last = last
        this._step = step

        this.cur = first
        this.hasNext = !isEmpty
    }

    @Frozen
    public func next(): Option<T> {
        var res = cur
        if (hasNext) {
            hasNext = res != _last
            cur = cur.next(_step)
            return Some<T>(res)
        }
        return None<T>
    }
}
