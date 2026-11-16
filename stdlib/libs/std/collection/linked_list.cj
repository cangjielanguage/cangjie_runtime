/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.collection

public class LinkedListNode<T> {
    var _next: ?LinkedListNode<T>
    var _prev: ?LinkedListNode<T>
    private var _item: T
    protected var _list: ?LinkedList<T>

    init(element: T, prev: ?LinkedListNode<T>, next: ?LinkedListNode<T>, belongs: ?LinkedList<T>) {
        _item = element
        _prev = prev
        _next = next
        _list = belongs
    }

    @Frozen
    public mut prop value: T {
        get() {
            checkNodeState()
            _item
        }
        set(v) {
            checkNodeState()
            _item = v
        }
    }

    @Frozen
    public prop next: Option<LinkedListNode<T>> {
        get() {
            checkNodeState()
            _next
        }
    }

    @Frozen
    public prop prev: Option<LinkedListNode<T>> {
        get() {
            checkNodeState()
            _prev
        }
    }

    @Frozen
    func insertBefore(element: T): LinkedListNode<T> {
        var node = LinkedListNode<T>(element, _prev, this, _list)
        if (let Some(prev) <- _prev) {
            prev._next = node
        } else {
            _list.getOrThrow()._head = node
        }
        _prev = Some(node)
        return node
    }

    @Frozen
    func insertAfter(element: T): LinkedListNode<T> {
        var node = LinkedListNode<T>(element, this, _next, _list)
        if (let Some(next) <- _next) {
            next._prev = node
        } else {
            _list.getOrThrow()._tail = node
        }
        _next = Some(node)
        return node
    }

    @Frozen
    func remove(): T {
        let list = _list.getOrThrow()
        if (let Some(p) <- _prev) {
            p._next = _next
        } else {
            list._head = _next
        }
        if (let Some(n) <- _next) {
            n._prev = _prev
        } else {
            list._tail = _prev
        }

        _list = None
        return _item
    }

    func reverse(): Unit {
        let tmp = _prev
        _prev = _next
        _next = tmp
    }

    private func checkNodeState() {
        if (let None <- _list) {
            throw IllegalStateException("Node does not belong to any LinkedList.")
        }
    }
}

public class LinkedList<T> <: Collection<T> {
    var _size: Int64 = 0
    var _head: ?LinkedListNode<T> = None
    var _tail: ?LinkedListNode<T> = None
    var _version: Int64 = 0

    public init() {}

    public init(elements: Collection<T>) {
        for (value in elements) {
            addLast(value)
        }
    }

    public init(elements: Array<T>) {
        for (element in elements) {
            addLast(element)
        }
    }

    public init(size: Int64, initElement: (Int64) -> T) {
        if (size < 0) {
            throw IllegalArgumentException("Invalid size '${size}': expected a non-negative value.")
        }
        for (i in 0..size) {
            addLast(initElement(i))
        }
    }

    public prop size: Int64 {
        get() {
            return _size
        }
    }

    public prop first: ?T {
        get() {
            match (_head) {
                case Some(v) => return v.value
                case _ => return None
            }
        }
    }

    public prop last: ?T {
        get() {
            match (_tail) {
                case Some(v) => return v.value
                case _ => return None
            }
        }
    }

    public prop firstNode: ?LinkedListNode<T> {
        get() {
            return _head
        }
    }

    public prop lastNode: ?LinkedListNode<T> {
        get() {
            return _tail
        }
    }

    prop version: Int64 {
        get() {
            return _version
        }
    }

    @Frozen
    public func addFirst(element: T): LinkedListNode<T> {
        let node = LinkedListNode<T>(element, None, _head, this)
        if (let Some(head) <- _head) {
            head._prev = node
        } else {
            _tail = node
        }
        _head = node
        _size++
        _version++
        return node
    }

    @Frozen
    public func addLast(element: T): LinkedListNode<T> {
        let node = LinkedListNode<T>(element, _tail, None, this)
        if (let Some(tail) <- _tail) {
            tail._next = node
        } else {
            _head = node
        }
        _tail = node
        _size++
        _version++
        return node
    }

    public func toArray(): Array<T> {
        if (size == 0) {
            return Array<T>()
        }

        let arr = Array<T>(size, repeat: unsafe { zeroValue<T>() })
        var index = size - 1
        var node = _tail.getOrThrow()
        while (true) {
            arr[index] = node.value
            index--
            node = node.prev ?? break
        }
        return arr
    }

    public func addBefore(node: LinkedListNode<T>, element: T): LinkedListNode<T> {
        checkNode(node)
        _size++
        _version++
        return node.insertBefore(element)
    }

    public func addAfter(node: LinkedListNode<T>, element: T): LinkedListNode<T> {
        checkNode(node)
        _size++
        _version++
        return node.insertAfter(element)
    }

    @Frozen
    public func remove(node: LinkedListNode<T>): T {
        checkNode(node)
        _size--
        _version++
        return node.remove()
    }

    public func removeIf(predicate: (T) -> Bool): Unit {
        var node = _head
        while (let Some(n) <- node) {
            node = n.next
            let lockVersion = _version
            let needDelete = predicate(n.value)
            if (_version != lockVersion) {
                throw ConcurrentModificationException("The predicate cannot contain a modify operation.")
            }
            if (needDelete) {
                _size--
                _version++
                n.remove()
            }
        }
    }

    /**
     * @description Extracts elements from the linked list at the specified interval and returns a new linked list.
     *
     * @param count the selected interval.
     * @returns a new LinkedList containing all elements extracted from the source LinkedList at intervals.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func step(count: Int64): LinkedList<T> {
        if (count <= 0) {
            throw IllegalArgumentException("Invalid step count '${count}': expected a positive value.")
        }
        var result: LinkedList<T> = LinkedList<T>()
        if (size == 0) {
            return result
        }
        var node = _head
        var position = 0
        while (let Some(n) <- node) {
            if (position % count == 0) {
                result.addLast(n.value)
            }
            position++
            node = n.next
        }
        return result
    }

    /**
     * @description Extracts a specific number of elements from the linked list and returns a new linked list.
     *
     * @param count the number of elements to take.
     * @returns a new linked list with the specified number of elements taken.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func take(count: Int64): LinkedList<T> {
        if (count == 0) {
            return LinkedList<T>()
        }

        if (count < 0) {
            throw IllegalArgumentException("Invalid take count '${count}': expected a non-negative value.")
        }
        var result: LinkedList<T> = LinkedList<T>()
        let newSize = min(count, _size)
        var node = _head
        for (_ in 0..newSize) {
            result.addLast(node.getOrThrow().value)
            node = node.getOrThrow().next
        }
        return result
    }

    /**
     * @description Skips a specific number of elements and returns a new linked list.
     *
     * @param count the number of elements to skip.
     * @returns a new linked list with the specified number of elements skipped.
     * @throws IllegalArgumentException, if count < 0.
     */
    @When[env != "ohos"]
    public func skip(count: Int64): LinkedList<T> {
        if (count < 0) {
            throw IllegalArgumentException("Invalid skip count '${count}': expected a non-negative value.")
        }
        if (size - count <= 0) {
            return LinkedList<T>()
        }
        var result: LinkedList<T> = LinkedList<T>()
        var node = _head
        for (_ in 0..count) {
            node = node.getOrThrow().next
        }
        for (_ in count..size) {
            result.addLast(node.getOrThrow().value)
            node = node.getOrThrow().next
        }
        return result
    }

    /**
     * @description Returns a new linked list containing elements that satisfy the filtering condition.
     *
     * @param predicate the given condition.
     * @returns a new linked list containing elements that satisfy the filtering condition.
     */
    @When[env != "ohos"]
    public func filter(predicate: (T) -> Bool): LinkedList<T> {
        if (size == 0) {
            return LinkedList<T>()
        }
        var result: LinkedList<T> = LinkedList<T>()
        var node = _head
        while (let Some(n) <- node) {
            var v = n.value
            if (predicate(v)) {
                result.addLast(v)
            }
            node = n.next
        }
        return result
    }

    /**
     * @description Returns a new linked list containing elements that satisfy the filtering condition.
     *
     * @param transform the given mapping function.
     * @returns a new linked list.
     */
    @When[env != "ohos"]
    public func map<R>(transform: (T) -> R): LinkedList<R> {
        if (size == 0) {
            return LinkedList<R>()
        }
        var result: LinkedList<R> = LinkedList<R>()
        var node = _head
        while (let Some(n) <- node) {
            result.addLast(transform(n.value))
            node = n.next
        }
        return result
    }

    /**
     * @description Applies a transformation closure (transform) to each element in the linked list. The closure returns a new linked list
                    and then all returned linked lists are "flattened" and concatenated into a single resulting linked list.
     *
     * @param transform the given mapping function.
     * @returns the new linked list after being "mapped" and "flattened".
     */
    @When[env != "ohos"]
    public func flatMap<R>(transform: (T) -> LinkedList<R>): LinkedList<R> {
        var result = LinkedList<R>()

        var node = _head
        while (let Some(n) <- node) {
            let newList = transform(n.value)
            var newNode = newList._head
            while (let Some(t) <- newNode) {
                result.addLast(t.value)
                newNode = t.next
            }
            node = n.next
        }
        return result
    }

    /**
     * @description Performs filtering and mapping operations simultaneously, returning a new LinkedList.
     *
     * @param transform the given mapping function
     * @returns a new linked list.
     */
    @When[env != "ohos"]
    public func filterMap<R>(transform: (T) -> ?R): LinkedList<R> {
        if (size == 0) {
            return LinkedList<R>()
        }
        var result: LinkedList<R> = LinkedList<R>()
        var node = _head
        while (let Some(n) <- node) {
            match (transform(n.value)) {
                case Some(v) => result.addLast(v)
                case None =>
                    node = n.next
                    continue
            }
            node = n.next
        }
        return result
    }

    /**
     * @description Returns a new LinkedList with the given new element inserted between every two elements.
     *
     * @param separator the given element.
     * @returns a new linked list.
     */
    @When[env != "ohos"]
    public func intersperse(separator: T): LinkedList<T> {
        if (size == 0) {
            return LinkedList<T>()
        }
        var result = LinkedList<T>()
        var node = _head.getOrThrow()
        for (_ in 0..size - 1) {
            result.addLast(node.value)
            result.addLast(separator)
            node = node.next.getOrThrow()
        }
        result.addLast(node.value)
        return result
    }

    /**
     * @description Iterates over all elements and performs the given operation.
     *
     * @param action the given operation function.
     */
    @When[env != "ohos"]
    public func forEach(action: (T) -> Unit): Unit {
        var node = _head
        while (let Some(n) <- node) {
            action(n.value)
            node = n.next
        }
    }

    /**
     * @description Determine whether all elements in the linked list satisfy the condition.
     *
     * @param predicate the given condition.
     * @returns true if all elements in this linked list satisfy the condition, otherwise returns false.
     */
    @When[env != "ohos"]
    public func all(predicate: (T) -> Bool): Bool {
        var node = _head
        while (let Some(n) <- node) {
            if (predicate(n.value)) {
                node = n.next
                continue
            } else {
                return false
            }
        }
        return true
    }

    /**
     * @description Determine whether there is any element in this linked list that satisfies the condition.
     *
     * @param predicate the given condition.
     * @returns Whether there is any element that satisfies the condition.
     */
    @When[env != "ohos"]
    public func any(predicate: (T) -> Bool): Bool {
        var node = _head
        while (let Some(n) <- node) {
            if (predicate(n.value)) {
                return true
            } else {
                node = n.next
                continue
            }
        }
        return false
    }

    /**
     * @description Determine whether all elements in this linked list do not satisfy the condition.
     *
     * @param predicate the given condition.
     * @returns Whether all elements in the current linked list do not satisfy the condition.
     */
    @When[env != "ohos"]
    public func none(predicate: (T) -> Bool): Bool {
        var node = _head
        while (let Some(n) <- node) {
            if (predicate(n.value)) {
                return false
            } else {
                node = n.next
                continue
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
        var node = _head
        while (let Some(n) <- node) {
            result = operation(result, n.value)
            node = n.next
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
        if (size == 0) {
            return None<T>
        }
        var node = _head
        var result: T = node.getOrThrow().value
        node = node.getOrThrow().next
        while (let Some(n) <- node) {
            result = operation(result, n.value)
            node = n.next
        }
        return result
    }

    public func clear(): Unit {
        var node = _head
        while (let Some(n) <- node) {
            node = n._next
            n._next = None
            n._prev = None
            n._list = None
        }
        _size = 0
        _head = None
        _tail = None
        _version++
    }

    public func reverse(): Unit {
        _version++
        var node = _head
        while (let Some(n) <- node) {
            node = n.next
            n.reverse()
        }
        let tmp = _head
        _head = _tail
        _tail = tmp
    }

    @Frozen
    public func isEmpty(): Bool {
        return _size == 0
    }

    @Frozen
    public func iterator(): Iterator<T> {
        return LinkedListIterator<T>(this, _head, false)
    }

    @Frozen
    public func removeFirst(): ?T {
        if (let Some(v) <- _head) {
            _version++
            _size--
            return v.remove()
        }

        return None
    }

    @Frozen
    public func removeLast(): ?T {
        if (let Some(v) <- _tail) {
            _version++
            _size--
            return v.remove()
        }

        return None
    }

    public func nodeAt(index: Int64): Option<LinkedListNode<T>> {
        if (index < 0 || index >= _size) {
            return None
        }

        if (index > (_size >> 1)) {
            var count = _size - index - 1
            var node = _tail
            while (count > 0) {
                node = node.getOrThrow().prev
                count--
            }
            return node
        } else {
            var count = index
            var node = _head
            while (count > 0) {
                node = node.getOrThrow().next
                count--
            }
            return node
        }
    }

    public func splitOff(node: LinkedListNode<T>): LinkedList<T> {
        checkNode(node)
        _version++

        var subList = LinkedList<T>()
        subList._head = node
        subList._tail = this._tail
        subList._size = 1
        node._list = subList

        var cursor = node
        while (let Some(n) <- cursor.next) {
            subList._size++
            n._list = subList
            cursor = n
        }

        this._tail = node.prev
        node._prev = None
        match (this._tail) {
            case Some(v) => v._next = None
            case None => this._head = None
        }

        this._size = this._size - subList._size
        return subList
    }

    public func forward(mark: LinkedListNode<T>): Iterator<T> {
        if (let Some(_) <- mark._list) {
            return LinkedListIterator<T>(this, mark, false)
        } else {
            throw IllegalStateException("Node does not belong to any LinkedList.")
        }
    }

    public func backward(mark: LinkedListNode<T>): Iterator<T> {
        if (let Some(_) <- mark._list) {
            return LinkedListIterator<T>(this, mark, true)
        } else {
            throw IllegalStateException("Node does not belong to any LinkedList.")
        }
    }

    private func checkNode(node: LinkedListNode<T>) {
        if (let Some(v) <- node._list) {
            if (refEq(this, v)) {
                return
            }
        }
        throw IllegalArgumentException("The node is not a member of this LinkedList.")
    }
}

extend<T> LinkedList<T> {
    /**
     * @description Merges two LinkedList into a new LinkedList (the length depends on the shorter linked list).
     *
     * @param other one of the linked lists to be merged.
     * @returns a new linked list.
     */
    @When[env != "ohos"]
    public func zip<R>(other: LinkedList<R>): LinkedList<(T, R)> {
        var result = LinkedList<(T, R)>()

        var node1 = _head
        var node2 = other._head

        while (let Some(n) <- node1 && let Some(t) <- node2) {
            result.addLast((n.value, t.value))
            node1 = n.next
            node2 = t.next
        }
        return result
    }

    /**
     * @description Used to obtain a linked list with indices.
     *
     * @returns a new LinkedList with indices.
     */
    @When[env != "ohos"]
    public func enumerate(): LinkedList<(Int64, T)> {
        var result = LinkedList<(Int64, T)>()
        var node = _head
        var i = 0
        while (let Some(n) <- node) {
            result.addLast((i, n.value))
            node = n.next
            i++
        }
        return result
    }
}

extend<T> LinkedList<T> <: ToString where T <: ToString {
    public func toString(): String {
        return collectionToString<LinkedList<T>, T>(this)
    }
}

extend<T> LinkedList<T> <: Equatable<LinkedList<T>> where T <: Equatable<T> {
    /** overloaded determination == method. */
    public operator func ==(right: LinkedList<T>): Bool {
        if (refEq(this, right)) {
            return true
        }
        if (this.size != right.size) {
            return false
        } else if (this.size == 0) {
            return true
        }

        var thisCursor = this._head
        var rightCursor = right._head

        while (let (Some(l), Some(r)) <- (thisCursor, rightCursor)) {
            if (l.value == r.value) {
                thisCursor = l.next
                rightCursor = r.next
            } else {
                return false
            }
        }

        return true
    }

    /** overloaded determination != method. */
    public operator func !=(right: LinkedList<T>): Bool {
        return !(this == right)
    }
}

class LinkedListIterator<T> <: Iterator<T> {
    private let _lockVersion: Int64
    private let _data: LinkedList<T>
    private var _currentNode: LinkedListNode<T>
    private let _backward: Bool

    init(data: LinkedList<T>, node: ?LinkedListNode<T>, backward: Bool) {
        _lockVersion = data.version
        _data = data
        _currentNode = LinkedListNode<T>(unsafe { zeroValue<T>() }, node, node, data)
        _backward = backward
    }

    @Frozen
    public func next(): Option<T> {
        if (_lockVersion != _data.version) {
            throw ConcurrentModificationException()
        }
        if (_backward) {
            _currentNode = _currentNode.prev ?? return None
            return _currentNode.value
        } else {
            _currentNode = _currentNode.next ?? return None
            return _currentNode.value
        }
    }
}
