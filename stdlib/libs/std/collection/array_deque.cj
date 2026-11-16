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
 * This file defines ArrayDeque and related classes.
 */
package std.collection

public class ArrayDeque<T> <: Deque<T> {
    // The array used to store the elements of the queue.
    var _data: Array<T>

    // The default capacity of the array.
    private static const DEFAULT_CAPACITY: Int64 = 8

    protected var _version: Int64 = 0

    var _head: Int64 = 0
    var _tail: Int64 = 0

    public init() {
        _data = Array<T>(DEFAULT_CAPACITY, repeat: unsafe { zeroValue<T>() })
    }

    public init(capacity: Int64) {
        if (capacity < 0) {
            throw IllegalArgumentException("Invalid capacity '${capacity}': expected a non-negative value.")
        }
        let cap = if (capacity < DEFAULT_CAPACITY) {
            DEFAULT_CAPACITY
        } else {
            capacity
        }
        _data = Array<T>(cap, repeat: unsafe { zeroValue<T>() })
    }

    public prop size: Int64 {
        get() {
            if (_head > _tail) {
                return _data.size - _head + _tail
            }
            return _tail - _head
        }
    }

    public prop first: ?T {
        get() {
            if (_head == _tail) {
                return None
            }
            return unsafe { _data.getUnchecked(_head) }
        }
    }

    public prop last: ?T {
        get() {
            if (_head == _tail) {
                return None
            }
            if (_tail == 0) {
                return unsafe { _data.getUnchecked(_data.size - 1) }
            }
            return unsafe { _data.getUnchecked(_tail - 1) }
        }
    }

    public prop capacity: Int64 {
        get() {
            return _data.size
        }
    }

    public func isEmpty(): Bool {
        return _head == _tail
    }

    @OverflowWrapping
    public func addFirst(element: T): Unit {
        _head = if (_head == 0) {
            _data.size - 1
        } else {
            _head - 1
        }
        _data[_head] = element
        if (_head == _tail) {
            grow(_data.size + 1, full: true)
        }
        incModCount()
    }

    @OverflowWrapping
    public func addLast(element: T): Unit {
        let tail = _tail
        let capacity = _data.size
        unsafe { _data.setUnchecked(tail, element) }
        let newTail = if (tail == capacity - 1) {
            0
        } else {
            tail + 1
        }
        _tail = newTail

        if (newTail == _head) {
            grow(capacity + 1, full: true)
        }
        _version++
    }

    @OverflowWrapping
    public func removeFirst(): ?T {
        if (_head == _tail) {
            return None
        }
        let res = unsafe { _data.getUnchecked(_head) }
        unsafe { _data.setUnchecked(_head, zeroValue<T>()) }

        _head = if (_head == _data.size - 1) {
            0
        } else {
            _head + 1
        }

        incModCount()
        return res
    }

    @OverflowWrapping
    public func removeLast(): ?T {
        if (_head == _tail) {
            return None
        }

        _tail = if (_tail == 0) {
            _data.size - 1
        } else {
            _tail - 1
        }

        let res = unsafe { _data.getUnchecked(_tail) }
        unsafe { _data.setUnchecked(_tail, zeroValue<T>()) }
        incModCount()
        return res
    }

    private func grow(minCapacity: Int64, full!: Bool = false): Unit {
        let oldCapacity: Int64 = _data.size
        var newCapacity: Int64 = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity
        }
        let newArr: Array<T> = Array<T>(newCapacity, repeat: unsafe { zeroValue<T>() })
        let newSize: Int64 = if (full) {
            _data.size
        } else {
            size
        }

        if (_head < _tail) {
            _data.copyTo(newArr, 0, _head, _tail - _head)
        } else if (newSize != 0) {
            let count = _data.size - _head
            _data.copyTo(newArr, _head, 0, count)
            _data.copyTo(newArr, 0, count, _tail)
        }
        _head = 0
        _tail = newSize
        _data = newArr
    }

    @OverflowWrapping
    public func toArray(): Array<T> {
        if (_head <= _tail) {
            return _data[_head.._tail].clone()
        }
        let newArr = Array<T>(size, repeat: unsafe { zeroValue<T>() })
        let length = _data.size - _head
        _data.copyTo(newArr, _head, 0, length)
        _data.copyTo(newArr, 0, length, _tail)
        return newArr
    }

    @OverflowWrapping
    public func clear(): Unit {
        while (_head != _tail) {
            unsafe { _data.setUnchecked(_head, zeroValue<T>()) }
            _head = if (_head == _data.size - 1) {
                0
            } else {
                _head + 1
            }
        }
        _head = 0
        _tail = 0
        incModCount()
    }

    public func reserve(additional: Int64): Unit {
        let free = _data.size - size
        if (additional <= free) {
            return
        }
        grow(size + additional)
        incModCount()
    }

    @Frozen
    public func iterator(): Iterator<T> {
        return ArrayDequeIterator<T>(this)
    }

    @OverflowWrapping
    private func incModCount(): Unit {
        _version++
    }
}

private class ArrayDequeIterator<T> <: Iterator<T> {
    private var myData: ArrayDeque<T>
    private var myIndex: Int64
    private let lockVersion: Int64

    init(data: ArrayDeque<T>) {
        myData = data
        lockVersion = data._version
        myIndex = data._head
    }

    @Frozen
    public func next(): ?T {
        if (myData._version != lockVersion) {
            throw ConcurrentModificationException()
        }
        if (myIndex == myData._tail) {
            return None
        }
        let res = unsafe { myData._data.getUnchecked(myIndex) }
        myIndex = if (myIndex == myData._data.size - 1) {
            0
        } else {
            myIndex + 1
        }
        return res
    }
}

extend<T> ArrayDeque<T> <: ToString where T <: ToString {
    public func toString(): String {
        return collectionToString<ArrayDeque<T>, T>(this)
    }
}
