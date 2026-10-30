/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * Implementing this interface allows an object to be the target of the "for-in loop" expression.
 */
public interface Iterable<E> {
    /* Returns an iterator over elements of type E. */
    func iterator(): Iterator<E>

    @When[env != "ohos"]
    func iterator(this @local!): Iterator<E> @local! {
        throw IllegalStateException("Current Type does not implement 'iterator' method for its @local! instance")
    }
    @When[env != "ohos"]
    func iterator(this @local?): Iterator<E> @local? {
        throw IllegalStateException("Current Type does not implement 'iterator' method for its @local? instance")
    }
}

/**
 * An iterator over a collection.
 */
public abstract class Iterator<T> <: Iterable<T> {
    public func next(): Option<T>
    @When[env != "ohos"]
    public open func next(this @local!): ?T @local! {
        throw IllegalStateException("Current Iterator does not implement 'next' method for its @local! instance")
    }
    @When[env != "ohos"]
    public open func next(this @local?): ?T @local? {
        throw IllegalStateException("Current Iterator does not implement 'next' method for its @local? instance")
    }

    @Frozen
    public init() {}
    @Frozen
    @When[env != "ohos"]
    public exclave init(this @local!) {}
    @Frozen
    @When[env != "ohos"]
    public exclave init(this @local?) {}

    /*
     * Iterator.
     *
     * @return Iterator<T> Return Iterator<T>.
     */
    @Frozen
    public func iterator(): Iterator<T> { this }
    @Frozen
    @When[env != "ohos"]
    public func iterator(this @local!): Iterator<T> @local! { this }
    @Frozen
    @When[env != "ohos"]
    public func iterator(this @local?): Iterator<T> @local? { this }
}

class FilterIterator<T> <: Iterator<T> {
    private let predicate: (T) -> Bool
    private let it: Iterator<T>

    /*
     * Filteriterator initialization constructor.
     *
     * @param it Iterable.
     * @param predicate Predicate.
     *
     */
    init(it: Iterator<T>, predicate: (T) -> Bool) {
        this.it = it
        this.predicate = predicate
    }

    /*
     * Iterator next value.
     *
     * @return Option<T> The return type of Option<T>.
     */
    public func next(): Option<T> {
        while (let Some(value) <- it.next()) {
            /* Value returns if the condition is met, otherwise continues. */
            if (predicate(value)) {
                return Some(value)
            }
        }
        return None
    }
}

class MapIterator<T, R> <: Iterator<R> {
    private let transform: (T) -> R
    private let it: Iterator<T>

    /*
     * Tranform Iterator to anther type.
     *
     * @param it Iterable.
     * @param transform Transform func.
     *
     * @return The return type of Option<R>.
     */
    @Frozen
    init(it: Iterator<T>, transform: (T) -> R) {
        this.it = it
        this.transform = transform
    }

    /*
     * Get MapIterator next.
     *
     * @return Option<R> The return type of Option<R>.
     */
    @Frozen
    public func next(): Option<R> {
        return match (it.next()) {
            case Some(value) => Some(transform(value))
            case _ => None
        }
    }
}

class StepIterator<T> <: Iterator<T> {
    private let _count: Int64
    private let it: Iterator<T>
    private var index: Int64 = 0

    /*
     * Iterator.
     *
     * @param it Step count elements in Iterable<T>.
     * @param count Step count elements.
     * @throws IllegalArgumentException if count is less than zero.
     *
     */
    init(it: Iterator<T>, count: Int64) {
        if (count <= 0) {
            throw IllegalArgumentException("Step count must be greater than 0!")
        }
        this.it = it
        this._count = count
        this.index = count
    }

    /*
     * Get StepIterator next.
     *
     * @return Option<T> Return value.
     */
    public func next(): Option<T> {
        while (let Some(v) <- it.next()) {
            if (index < _count) {
                index++
                continue
            }
            index = 1
            return Some(v)
        }
        return None
    }
}

class SkipIterator<T> <: Iterator<T> {
    private var _count: Int64
    private let it: Iterator<T>

    /*
     * Skip count elements in Iterable<T>
     *
     * @param it Iterable.
     * @param count Skip count elements.
     * @throws IllegalArgumentException if count is less than zero.
     *
     */
    init(it: Iterator<T>, count: Int64) {
        if (count < 0) {
            throw IllegalArgumentException("Skip count cannot less than 0!")
        }
        this.it = it
        this._count = count
    }

    /*
     * Get SkipIterator next.
     *
     * @return Option<T> Return Option<T>.
     */
    public func next(): Option<T> {
        /**
         * The Iterator was going to skip count times when
         * it is consumed for the first time.
         */
        while (_count > 0) {
            match (it.next()) {
                case None => return None
                case _ => _count--
            }
        }
        return it.next()
    }
}

/*
 * This TakeIterator class is used to yields the first `count` elements in Iterable<T>.
 * Slice Iterable<T> is like array[0..count]
 * If count < 0, an exception is throw.
 */
class TakeIterator<T> <: Iterator<T> {
    private var _count: Int64
    private let it: Iterator<T>

    /*
     * Take count elements in Iterable<T>.
     *
     * @param it Iterable.
     * @param count Take count elements.
     * @throws IllegalArgumentException if count is less than zero.
     *
     */
    init(it: Iterator<T>, count: Int64) {
        if (count < 0) {
            throw IllegalArgumentException("Take count cannot less than 0!")
        }
        this.it = it
        this._count = count
    }

    /*
     * Get TakeIterator next.
     *
     * @return Option<T> Return value.
     */
    public func next(): Option<T> {
        /** The Iterator is used up after being consumed count times. */
        if (_count == 0) {
            return None
        }
        _count--
        return it.next()
    }
}

class ConcatIterator<T> <: Iterator<T> {
    private let it: Iterator<T>
    private let other: Iterator<T>

    /** Whether it is used up. */
    private var itOver: Bool = false

    /*
     * Concat two Iterables.
     *
     * @param it Iterable.
     * @param other Iterable.
     *
     */
    init(it: Iterator<T>, other: Iterator<T>) {
        this.it = it
        this.other = other
    }

    /*
     * Get concatIterator next.
     *
     * @return other Return Option<T>.
     */
    public func next(): Option<T> {
        if (itOver) {
            return other.next()
        }

        match (it.next()) {
            case Some(value) => return Some(value)
            case _ =>
                itOver = true
                return other.next()
        }
    }
}

class FlatMapIterator<T, R> <: Iterator<R> {
    private var subIt: Option<Iterator<R>> = None
    private let transform: (T) -> Iterable<R>
    private let it: Iterator<T>

    /*
     * All elements are converted to Iterator<R> by transform func.
     *
     * @param it Iterable.
     * @param transform Transform func.
     *
     * @return Option<R> The return type of Option<R>.
     */
    init(it: Iterable<T>, transform: (T) -> Iterable<R>) {
        this.it = it.iterator()
        this.transform = transform
    }

    /*
     * Get FlatMap Iterator next.
     *
     * @return Option<R> The return type of Option<R>.
     */
    public func next(): Option<R> {
        /**
         * Check whether subIt is consumed.
         * If yes, return the resulting value.
         * If not, reset subIt and continue to check from the beginning.
         */
        while (true) {
            match (subIt) {
                case Some(result) => match (result.next()) {
                    case Some(v) => return Some(v)
                    case _ => ()
                }
                case _ => ()
            }

            match (it.next()) {
                case Some(sub) => subIt = Some(transform(sub).iterator())
                case _ => return None
            }
        }
        return None
    }
}

class ZipIterator<T, R> <: Iterator<(T, R)> {
    private let itt: Iterator<T>
    private let itr: Iterator<R>

    /*
     * Iterator.
     *
     * @param itt Used to zip one Iterables.
     * @param itr Used to zip one Iterables.
     *
     */
    init(itt: Iterator<T>, itr: Iterator<R>) {
        this.itt = itt
        this.itr = itr
    }

    /*
     * Get Iterator next.
     *
     * @return Option<T*R> Return value.
     */
    public func next(): Option<(T, R)> {
        match ((itt.next(), itr.next())) {
            case (Some(t), Some(r)) => return Some((t, r))
            case _ => return None
        }
    }
}

class EnumerateIterator<T> <: Iterator<(Int64, T)> {
    /** The record of the index when EnumerateIterator run next. */
    private var index: Int64 = -1
    private let it: Iterator<T>

    /*
     * Iterable with index.
     *
     * @param it Iterable.
     *
     */
    init(it: Iterator<T>) {
        this.it = it
    }

    /*
     * Get Iterator next.
     *
     * @return Option<Int64*T> Return value.
     */
    public func next(): Option<(Int64, T)> {
        return match (it.next()) {
            case Some(value) =>
                index++
                Some((index, value))
            case _ => return None
        }
    }
}

class FilterMapIterator<T, R> <: Iterator<R> {
    private let transform: (T) -> Option<R>
    private let it: Iterator<T>

    init(it: Iterator<T>, transform: (T) -> Option<R>) {
        this.it = it
        this.transform = transform
    }

    public func next(): Option<R> {
        while (let Some(t) <- it.next()) {
            match (transform(t)) {
                case Some(r) => return Some(r)
                case _ => continue
            }
        }
        return None
    }
}

class InspectIterator<T> <: Iterator<T> {
    private let action: (T) -> Unit
    private let it: Iterator<T>

    init(it: Iterator<T>, action: (T) -> Unit) {
        this.it = it
        this.action = action
    }

    public func next(): Option<T> {
        match (it.next()) {
            case Some(value) =>
                action(value)
                return Some(value)
            case _ => ()
        }
        return None
    }
}

class IntersperseIterator<T> <: Iterator<T> {
    private let separator: T
    private let it: Iterator<T>
    private var item: ?T
    private var isInsert = false

    init(it: Iterator<T>, separator: T) {
        this.it = it
        this.separator = separator
        this.item = it.next()
    }

    public func next(): Option<T> {
        if (isInsert) {
            isInsert = false
            item = it.next()
            if (item.isNone()) {
                return None
            }
            return Some(separator)
        }
        isInsert = true
        return item
    }
}

extend<T> Iterator<T> where T <: Equatable<T> {
    @Frozen
    public func contains(element: T): Bool {
        for (item in this.iterator()) {
            if (item == element) {
                return true
            }
        }
        return false
    }
}

extend<T> Iterator<T> where T <: Comparable<T> {
    public func max(): Option<T> {
        var result: Option<T> = None
        for (item in this.iterator()) {
            match (result) {
                case Some(value) =>
                    if (item > value) {
                        result = Some(item)
                    }
                case _ => result = Some(item)
            }
        }
        return result
    }

    public func min(): Option<T> {
        var result: Option<T> = None
        for (item in this.iterator()) {
            match (result) {
                case Some(value) =>
                    if (item < value) {
                        result = Some(item)
                    }
                case _ => result = Some(item)
            }
        }
        return result
    }
}

extend<T> Iterator<T> {
    @Frozen
    public func zip<R>(it: Iterator<R>): Iterator<(T, R)> {
        return ZipIterator<T, R>(this, it)
    }

    @Frozen
    public func enumerate(): Iterator<(Int64, T)> {
        return EnumerateIterator<T>(this)
    }

    @Frozen
    public func filter(predicate: (T) -> Bool): Iterator<T> {
        return FilterIterator<T>(this, predicate)
    }

    @Frozen
    public func filterMap<R>(transform: (T) -> Option<R>): Iterator<R> {
        return FilterMapIterator<T, R>(this, transform)
    }

    @Frozen
    public func map<R>(transform: (T) -> R): Iterator<R> {
        return MapIterator<T, R>(this, transform)
    }

    @Frozen
    public func step(count: Int64): Iterator<T> {
        return StepIterator<T>(this, count)
    }

    @Frozen
    public func skip(count: Int64): Iterator<T> {
        return SkipIterator<T>(this, count)
    }

    @Frozen
    public func take(count: Int64): Iterator<T> {
        return TakeIterator<T>(this, count)
    }

    @Frozen
    public func concat(other: Iterator<T>): Iterator<T> {
        return ConcatIterator<T>(this, other)
    }

    @Frozen
    public func inspect(action: (T) -> Unit): Iterator<T> {
        return InspectIterator<T>(this, action)
    }

    @Frozen
    public func flatMap<R>(transform: (T) -> Iterator<R>): Iterator<R> {
        return FlatMapIterator<T, R>(this, transform)
    }

    @Frozen
    public func intersperse(separator: T): Iterator<T> {
        return IntersperseIterator<T>(this, separator)
    }

    @Frozen
    public func all(predicate: (T) -> Bool): Bool {
        for (item in this) {
            if (!predicate(item)) {
                return false
            }
        }
        return true
    }

    @Frozen
    public func any(predicate: (T) -> Bool): Bool {
        for (item in this) {
            if (predicate(item)) {
                return true
            }
        }
        return false
    }

    @Frozen
    public func none(predicate: (T) -> Bool): Bool {
        for (item in this) {
            if (predicate(item)) {
                return false
            }
        }
        return true
    }

    @Frozen
    public func isEmpty(): Bool {
        return match (this.next()) {
            case None => true
            case _ => false
        }
    }

    @Frozen
    public func count(): Int64 {
        var count: Int64 = 0
        for (_ in this) {
            count++
        }
        return count
    }

    @Frozen
    public func forEach(action: (T) -> Unit): Unit {
        for (item in this) {
            action(item)
        }
    }

    @Frozen
    public func first(): Option<T> {
        return this.next()
    }

    @Frozen
    public func last(): Option<T> {
        var result: Option<T> = None
        for (item in this) {
            result = Some(item)
        }
        return result
    }

    @Frozen
    public func at(n: Int64): Option<T> {
        if (n < 0) {
            return None
        }
        var i: Int64 = 0
        for (item in this) {
            if (i == n) {
                return Some(item)
            }
            i++
        }
        return None
    }

    @Frozen
    public func reduce(operation: (T, T) -> T): Option<T> {
        var it = this.iterator()
        var result: T = it.next() ?? return None
        while (let Some(value) <- it.next()) {
            result = operation(result, value)
        }
        return result
    }

    @Frozen
    public func fold<R>(initial: R, operation: (R, T) -> R): R {
        var result: R = initial
        for (item in this) {
            result = operation(result, item)
        }
        return result
    }
}
