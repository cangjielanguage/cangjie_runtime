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
 * This file defines TreeMap.
 */
package std.collection

const DEGREE: Int64 = 6
const MIN_ENTRY_SIZE: Int64 = DEGREE - 1
const MAX_ENTRY_SIZE: Int64 = 2 * DEGREE - 1
const MIN_CHILD_SIZE: Int64 = DEGREE
const MAX_CHILD_SIZE: Int64 = 2 * DEGREE

public class TreeMap<K, V> <: OrderedMap<K, V> where K <: Comparable<K> {
    /* The number of entries in the TreeMap. */
    private var _size: Int64 = 0

    /* Modified treemap version. */
    private var modCount: Int64 = 0

    /* Root node of the current TreeMap. */
    private var root: Node<K, V>

    /**
     * Initializes an empty TreeMap.
     *
     * @since 0.43.1
     */
    public init() {
        this.root = Node<K, V>(Node<K, V>.nullNode())
    }

    /**
     * Initializes a TreeMap with an incoming iterator for initialization.
     *
     * @since 0.43.1
     */
    public init(elements: Collection<(K, V)>) {
        this.root = Node<K, V>(Node<K, V>.nullNode())
        for (i in elements) {
            this.add(i[0], i[1])
        }
    }

    /**
     * Initializes a TreeMap with an incoming list for initialization.
     *
     * @param elements an incoming list is initialized.
     *
     * @since 0.43.1
     */
    public init(elements: Array<(K, V)>) {
        this.root = Node<K, V>(Node<K, V>.nullNode())
        for (i in elements) {
            this.add(i[0], i[1])
        }
    }

    /**
     * Initializes a TreeMap with an incoming size and an initial element for initialization.
     *
     * @param size the size of the incoming initial element.
     * @param initElement an incoming initElement is initialized.
     *
     * @throws IllegalArgumentException if size is less than zero
     *
     * @since 0.43.1
     */
    public init(size: Int64, initElement: (Int64) -> (K, V)) {
        if (size < 0) {
            throw IllegalArgumentException("Invalid size of TreeMap: ${size}.")
        } else {
            this.root = Node<K, V>(Node<K, V>.nullNode())
            for (i in 0..size) {
                let element: (K, V) = initElement(i)
                this.add(element[0], element[1])
            }
        }
    }

    /**
     * Returns the value to which the specified key is mapped.
     *
     * @param key transfer key to obtain the value.
     * @return the value corresponding to the return key is encapsulated with Option.
     *
     * @since 0.43.1
     */
    public func get(key: K): ?V {
        let sr = searchEntry(this.root, key)
        return match (sr.replaceNode) {
            case Some(v) => v.getEntry(sr.index).getOrThrow().value
            case None => None
        }
    }

    /**
     * Checks whether the mapping relationship corresponding to the specified key exists in this mapping.
     *
     * @param key transfer the key to be judged.
     * @return bool returns true if exists; otherwise, false.
     *
     * @since 0.43.1
     */
    public func contains(key: K): Bool {
        searchEntry(this.root, key).replaceNode.isSome()
    }

    /**
     * Checks whether the mapping relationship corresponding to the collection key exists in this mapping.
     *
     * @param keys transfer the collection key to be judged.
     * @return bool returns true if exists; otherwise, false.
     *
     * @since 0.43.1
     */
    public func contains(all!: Collection<K>): Bool {
        for (key in all where !this.contains(key)) {
            return false
        }
        return true
    }

    /**
     * Associates the specified @p value with the specified @p key in this map.
     * If you map a mapping that previously contained a key, the old value is replaced.
     *
     * @param key the key to put.
     * @param value the value to assign.
     * @return If the key exists before the assignment, the value before the assignment is encapsulated with Option.
     * Otherwise, return to Option<V>.None
     *
     * @since 0.43.1
     */
    public func add(key: K, value: V): Option<V> {
        //If the root node is full, split the root node.
        if (this.root.entrySize == MAX_ENTRY_SIZE) {
            //Create a node as the new root node after splitting. The original root node becomes the left node.
            let newNode: Node<K, V> = Node<K, V>(Node<K, V>.nullNode())
            newNode.insertChild(0, this.root)
            this.root._parent = newNode
            splitNode(newNode, this.root, 0)
            this.root = newNode
        }
        //Insert Node.
        return inserEntry(this.root, TreeMapEntry<K, V>(key, value))
    }

    /**
     * Transfer specified elements for traversal and assign values in sequence.
     * If you map a mapping that previously contained a key, the old value is replaced.
     *
     * @param elements the element passing in for traversal assignment.
     *
     * @since 0.43.1
     */
    public func add(all!: Collection<(K, V)>): Unit {
        for ((k, v) in all) {
            this.add(k, v)
        }
    }

    /**
     * Removes the key-value pair corresponding to the key based on the specified key from this mapping, if one exists.
     *
     * @param key pass in the key to be deleted.
     * @return removed element
     *
     * @since 0.43.1
     */
    public func remove(key: K): Option<V> {
        if (this.isEmpty()) {
            return None
        }
        if (let Some(_) <- get(key)) {
            return deleteEntry(this.root, key)
        } else {
            return None
        }
    }

    /**
     * Traverse the set of transferred keys and delete them based on the traversal result.
     *
     * @param keys pass in the collection to traverse.
     *
     * @since 0.43.1
     */
    public func remove(all!: Collection<K>): Unit {
        for (key in all) {
            this.remove(key)
        }
    }

    /**
     * Transfer a lambda expression and delete the corresponding key value if the condition is met.
     *
     * @param predicate transfer a lambda expression for judgment.
     *
     * @since 0.43.1
     */
    public func removeIf(predicate: (K, V) -> Bool): Unit {
        var sr: SearchResult<K, V> = getFirstEntry()
        while (let Some(node) <- sr.replaceNode) {
            let item: TreeMapEntry<K, V> = node.getEntry(sr.index).getOrThrow()
            let lockVersion = this.modCount
            let needDelete = predicate(item.key, item.value)
            if (this.modCount != lockVersion) {
                throw ConcurrentModificationException("The predicate cannot contain a modify operation.")
            }
            let ssr = successor(sr)
            match (ssr.replaceNode) {
                case Some(v) =>
                    let key = v.getEntry(ssr.index).getOrThrow().key
                    if (needDelete) {
                        deleteEntry(node, item.key)
                        sr = searchEntry(this.root, key)
                    } else {
                        sr = ssr
                    }
                case None =>
                    if (needDelete) {
                        deleteEntry(node, item.key)
                    }
                    break
            }
        }
    }

    /**
     * Clear all key-value pairs.
     *
     * @since 0.43.1
     */
    public func clear(): Unit {
        this._size = 0
        this.modCount++
        this.root = Node<K, V>(Node<K, V>.nullNode())
    }

    /**
     * Copy a TreeMap.
     *
     * @return a clone value of TreeMap.
     *
     * @since 0.43.1
     */
    public func clone(): TreeMap<K, V> {
        return TreeMap<K, V>(this)
    }

    private func newTraversalDeque(): ArrayDeque<Node<K, V>> {
        var deque = ArrayDeque<Node<K, V>>()
        deque.addLast(this.root)
        return deque
    }

    private func appendChildren(deque: ArrayDeque<Node<K, V>>, node: Node<K, V>): Unit {
        if (!node.isLeaf()) {
            var childs = node.children
            for (i in 0..childs.size) {
                deque.addLast(childs[i])
            }
        }
    }

    private func traverseEntries(visit: (K, V) -> Bool): Bool {
        let curNode: Node<K, V> = this.root
        var deque = ArrayDeque<Node<K, V>>()
        deque.addLast(curNode)
        while (!deque.isEmpty()) {
            var node = deque.removeFirst().getOrThrow()
            for (i in 0..node.entries.size) {
                var key = node.entries[i].key
                var value = node.entries[i].value
                if (visit(key, value)) {
                    return true
                }
            }
            if (!node.isLeaf()) {
                var childs = node.children
                for (i in 0..childs.size) {
                    deque.addLast(childs[i])
                }
            }
        }
        return false
    }

    private func collectMappedEntries<R>(transform: (K, V) -> (K, R)): Array<(K, R)> {
        var deque = newTraversalDeque()
        var arr: Array<(K, R)> = unsafe { Array<(K, R)>(this.size, repeat: zeroValue<(K, R)>()) }
        var index = 0
        while (!deque.isEmpty()) {
            var node = deque.removeFirst().getOrThrow()
            for (i in 0..node.entries.size) {
                var key = node.entries[i].key
                var value = node.entries[i].value
                arr[index] = transform(key, value)
                index++
            }
            appendChildren(deque, node)
        }
        return arr.slice(0, index)
    }

    private func collectFilteredEntries(predicate: (K, V) -> Bool): Array<(K, V)> {
        var deque = newTraversalDeque()
        var arr: Array<(K, V)> = unsafe { Array<(K, V)>(this.size, repeat: zeroValue<(K, V)>()) }
        var index = 0
        while (!deque.isEmpty()) {
            var node = deque.removeFirst().getOrThrow()
            for (i in 0..node.entries.size) {
                var key = node.entries[i].key
                var value = node.entries[i].value
                if (predicate(key, value)) {
                    arr[index] = (key, value)
                    index++
                }
            }
            appendChildren(deque, node)
        }
        return arr.slice(0, index)
    }

    /**
     * @description Performs mapping on this TreeMap and returns a new TreeMap.
     *
     * @param transform the given mapping function.
     * @returns a new TreeMap.
     */
    @When[env != "ohos"]
    public func mapValues<R>(transform: (K, V) -> R): TreeMap<K, R> {
        return TreeMap<K, R>(collectMappedEntries<R> {key: K, value: V => (key, transform(key, value))})
    }

    /**
     * @description Performs mapping on this TreeMap and returns a new TreeMap.
     *
     * @param transform the given mapping function.
     * @returns a new TreeMap.
     */
    @When[env != "ohos"]
    public func mapValues<R>(transform: (V) -> R): TreeMap<K, R> {
        return TreeMap<K, R>(collectMappedEntries<R> {key: K, value: V => (key, transform(value))})
    }

    /**
     * @description Returns a new TreeMap<K, V> containing key-value pairs that satisfy the filtering condition.
     *
     * @param predicate the given mapping function.
     * @returns a new collection of key-value pairs that satisfy the filtering condition.
     */
    @When[env != "ohos"]
    public func filter(predicate: (K, V) -> Bool): TreeMap<K, V> {
        return TreeMap<K, V>(collectFilteredEntries(predicate))
    }

    /**
     * @description Iterates over all key-value pairs and performs the given operation.
     *
     * @param action the given operation function.
     */
    @When[env != "ohos"]
    public func forEach(action: (K, V) -> Unit): Unit {
        let _ = traverseEntries {key: K, value: V =>
            action(key, value)
            false
        }
    }

    /**
     * @description Determine whether all key-value pairs in the TreeMap satisfy the condition.
     *
     * @param predicate the given condition.
     * @returns true if all key-value pairs in the TreeMap satisfy the condition, otherwise returns false.
     */
    @When[env != "ohos"]
    public func all(predicate: (K, V) -> Bool): Bool {
        return !traverseEntries {key: K, value: V => !predicate(key, value)}
    }

    /**
     * @description Determine whether there is any key-value pair in the TreeMap that satisfies the condition.
     *
     * @param predicate the given condition.
     * @returns Whether there is any key-value pair that satisfies the condition.
     */
    @When[env != "ohos"]
    public func any(predicate: (K, V) -> Bool): Bool {
        return traverseEntries {key: K, value: V => predicate(key, value)}
    }

    /**
     * @description Determine whether all key-value pairs in the TreeMap do not satisfy the condition.
     *
     * @param predicate the given condition.
     * @returns Whether all key-value pairs in the current TreeMap do not satisfy the condition.
     */
    @When[env != "ohos"]
    public func none(predicate: (K, V) -> Bool): Bool {
        return !traverseEntries {key: K, value: V => predicate(key, value)}
    }

    /**
     * @description Computes from left to right using the specified initial value.
     *
     * @param initial the given initial value of type R.
     * @param operation the given computation function.
     * @returns the final computed value.
     */
    @When[env != "ohos"]
    public func fold<R>(initial: R, operation: (R, K, V) -> R): R {
        var result = initial
        let curNode: Node<K, V> = this.root
        var deque = ArrayDeque<Node<K, V>>()
        deque.addLast(curNode)
        while (!deque.isEmpty()) {
            var node = deque.removeFirst().getOrThrow()
            for (i in 0..node.entries.size) {
                var key = node.entries[i].key
                var value = node.entries[i].value
                result = operation(result, key, value)
            }
            if (!node.isLeaf()) {
                var childs = node.children
                for (i in 0..childs.size) {
                    deque.addLast(childs[i])
                }
            }
        }
        return result
    }

    /**
     * @description Compute from left to right using the first value as the initial value.
     *
     * @param operation the given computation function.
     * @returns the final computed value.
     */
    @When[env != "ohos"]
    public func reduce(operation: (V, V) -> V): Option<V> {
        if (this.size <= 0) {
            return None<V>
        }
        let curNode: Node<K, V> = this.root
        var result = curNode.entries[0].value
        for (i in 1..curNode.entries.size) {
            var value = curNode.entries[i].value
            result = operation(result, value)
        }
        var deque = ArrayDeque<Node<K, V>>()
        if (!curNode.isLeaf()) {
            var childs = curNode.children
            for (i in 0..childs.size) {
                deque.addLast(childs[i])
            }
        }
        while (!deque.isEmpty()) {
            var node = deque.removeFirst().getOrThrow()
            for (i in 0..node.entries.size) {
                var value = node.entries[i].value
                result = operation(result, value)
            }
            if (!node.isLeaf()) {
                var childs = node.children
                for (i in 0..childs.size) {
                    deque.addLast(childs[i])
                }
            }
        }
        return result
    }

    /**
     * An exception is reported when the get operator is overloaded and the key does not exist.
     *
     * @param key transfer the value for judgment.
     * @return the value corresponding to the key.
     *
     * @throws NoneValueException if value does not exist.
     *
     * @since 0.43.1
     */
    public operator func [](key: K): V {
        return match (this.get(key)) {
            case None => throw NoneValueException("Value does not exist!")
            case Some(val) => val
        }
    }

    /**
     * The operator overloads the set. If the key does not exist, an exception is reported.
     *
     * @param key transfer the value for judgment.
     * @param value transfer the value to be set.
     *
     * @since 0.43.1
     */
    public operator func [](key: K, value!: V): Unit {
        this.add(key, value)
    }

    /**
     * Returns the Set view of all keys in this TreeMap.
     *
     * @return the Set view of the keys.
     *
     * @since 0.43.1
     */
    public func keys(): EquatableCollection<K> {
        return TreeMapKeys<K, V>(this)
    }

    /**
     * Returns the Set view of all values in this TreeMap.
     *
     * @return the list view of the values.
     *
     * @since 0.43.1
     */
    public func values(): Collection<V> {
        return TreeMapValues<K, V>(this)
    }

    /**
     * Returns sizes of key-value.
     *
     * @return sizes of key-value.
     *
     * @since 0.43.1
     */
    public prop size: Int64 {
        get() {
            return this._size
        }
    }

    /**
     * Check whether the size is empty. If yes, true is returned. Otherwise, false is returned.
     *
     * @return bool if yes, true is returned. Otherwise, false is returned.
     *
     * @since 0.43.1
     */
    public func isEmpty(): Bool {
        return this.root.isEmpty()
    }

    /**
     * Get an iterator.
     *
     * @return type is iterator, which contains key and value.
     *
     * @since 0.43.1
     */
    @Frozen
    public func iterator(): Iterator<(K, V)> {
        let node = TreeMapEntryView(this, getFirstEntry())
        return TreeMapIterator<K, V>(node)
    }

    /**
     * Gets the first node of the TreeMap.
     *
     * @return If the first node exists, the key-value pair stored on the first node is returned. Otherwise, None is returned.
     *
     * @since 0.43.1
     */
    public prop first: ?(K, V) {
        get() {
            let sr: SearchResult<K, V> = getFirstEntry()
            match (sr.replaceNode) {
                case Some(v) =>
                    let item = v.getEntry(sr.index).getOrThrow()
                    return (item.key, item.value)
                case None => None
            }
        }
    }

    /**
     * Delete the first node of the TreeMap.
     *
     * @return If there is a first node, return the deletion and return the key-value pair it stores; Otherwise, None is returned.
     *
     * @since 0.43.1
     */
    public func removeFirst(): ?(K, V) {
        let sr: SearchResult<K, V> = getFirstEntry()
        match (sr.replaceNode) {
            case Some(v) =>
                let item = v.getEntry(sr.index).getOrThrow()
                deleteEntry(v, item.key)
                return (item.key, item.value)
            case None => None
        }
    }

    /**
     * Gets the last node of the TreeMap.
     *
     * @return If the last node exists, the key-value pair stored on the first node is returned. Otherwise, None is returned.
     *
     * @since 0.43.1
     */
    public prop last: ?(K, V) {
        get() {
            let sr: SearchResult<K, V> = getLastEntry()
            match (sr.replaceNode) {
                case Some(v) =>
                    let entry = v.getEntry(sr.index).getOrThrow()
                    return (entry.key, entry.value)
                case None => None
            }
        }
    }

    /**
     * Delete the last node of the TreeMap.
     *
     * @return If there is a last node, return the deletion and return the key-value pair it stores; Otherwise, None is returned.
     *
     * @since 0.43.1
     */
    public func removeLast(): ?(K, V) {
        let sr: SearchResult<K, V> = getLastEntry()
        match (sr.replaceNode) {
            case Some(v) =>
                let item = v.getEntry(sr.index).getOrThrow()
                deleteEntry(v, item.key)
                return (item.key, item.value)
            case None => None
        }
    }

    func searchNearestEntryView(array: ArrayList<K>, key: K, forward!: Bool): TreeMapEntryView<K, V> {
        var (left, right, mid) = (0, array.size - 1, 0)

        while (left <= right) {
            mid = left + (right - left) / 2
            if (array[mid] < key) {
                left = mid + 1
            } else if (array[mid] > key) {
                right = mid - 1
            } else {
                break
            }
        }

        let result = if (forward && left < array.size && array[left] > key) {
            array[left]
        } else if (!forward && right >= 0 && array[right] < key) {
            array[right]
        } else {
            return TreeMapEntryView<K, V>(this, SearchResult<K, V>(-1, None))
        }
        return TreeMapEntryView<K, V>(this, searchEntry(this.root, result))
    }
    /**
     * Generate an iterator in positive order from the current node to the end of the bound node.
     *
     * @param bound - Passed key
     * @param inclusive: indicates whether the input key is included. The default value is true, indicating that the input key is included.
     *
     * @return value Iterator<(K, V)> - Returns an iterator in positive order from the current node to the end of the bound.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     * @since 0.43.1
     */
    public func backward(mark: K, inclusive!: Bool = true): Iterator<(K, V)> {
        var entry = this.searchEntry(this.root, mark)
        return match (entry.replaceNode) {
            case Some(_) => BackwardIterator(TreeMapEntryView(this, entry), mark, inclusive)
            case None =>
                if (mark > last.getOrThrow()[0]) {
                    BackwardIterator(TreeMapEntryView(this, getLastEntry()), mark, true)
                } else if (mark > first.getOrThrow()[0]) {
                    let view: TreeMapEntryView<K, V> = searchNearestEntryView(this.keys() |> collectArrayList, mark,
                        forward: false)
                    BackwardIterator(view, mark, true)
                } else {
                    BackwardIterator(TreeMapEntryView(this, getFirstEntry()), mark, false)
                }
        }
    }

    /**
     * Generate an iterator in positive order from the current node to the end of the bound node.
     *
     * @param bound - Passed key
     * @param inclusive: indicates whether the input key is included. The default value is true, indicating that the input key is included.
     *
     * @return value Iterator<(K, V)> - Returns an iterator in positive order from the current node to the end of the bound.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     * @since 0.43.1
     */
    public func forward(mark: K, inclusive!: Bool = true): Iterator<(K, V)> {
        var entry = this.searchEntry(this.root, mark)
        return match (entry.replaceNode) {
            case Some(_) => ForwardIterator(TreeMapEntryView(this, entry), mark, inclusive)
            case None =>
                if (mark < this.first.getOrThrow()[0]) {
                    ForwardIterator(TreeMapEntryView(this, getFirstEntry()), mark, true)
                } else if (mark <= this.last.getOrThrow()[0]) {
                    let view: TreeMapEntryView<K, V> = searchNearestEntryView(this.keys() |> collectArrayList, mark,
                        forward: true)
                    ForwardIterator(view, mark, true)
                } else {
                    ForwardIterator(TreeMapEntryView(this, getLastEntry()), mark, false)
                }
        }
    }

    /* Obtains the number of modification times. */
    func version(): Int64 {
        return this.modCount
    }

    /* Obtains the smallest node. */
    func getFirstEntry(): SearchResult<K, V> {
        if (this.root.isEmpty()) {
            return SearchResult<K, V>(-1, None)
        }
        var curNode: Node<K, V> = this.root
        while (!curNode.isLeaf()) {
            curNode = curNode.getChild(0).getOrThrow()
        }
        return SearchResult<K, V>(0, curNode)
    }

    /* Obtains the largest node. */
    func getLastEntry(): SearchResult<K, V> {
        if (this.root.isEmpty()) {
            return SearchResult<K, V>(-1, None)
        }
        var curNode: Node<K, V> = this.root
        while (!curNode.isLeaf()) {
            curNode = curNode.getChild(curNode.entrySize).getOrThrow()
        }
        return SearchResult<K, V>(curNode.entrySize - 1, curNode)
    }

    /* Query the node location. */
    func searchEntry(node: ?Node<K, V>, key: K): SearchResult<K, V> {
        if (let Some(node) <- node) {
            var sr: SearchResult<K, V> = node.searchEntry(key)
            return match (sr.replaceNode) {
                case Some(_) => sr
                case None =>
                    if (root.isLeaf()) {
                        sr
                    } else {
                        searchEntry(node.getChild(sr.index), key)
                    }
            }
        }
        return SearchResult<K, V>(-1, None)
    }

    func searchEntryFromRoot(key: K): SearchResult<K, V> {
        return searchEntry(this.root, key)
    }

    /* Insert a node. */
    func inserEntry(node: Node<K, V>, entry: TreeMapEntry<K, V>): Option<V> {
        //Query the location to be inserted.
        let sr: SearchResult<K, V> = node.searchEntry(entry.key)
        match (sr.replaceNode) {
            case Some(node) =>
                let tmp = node.getEntry(sr.index).getOrThrow()
                let oldValue = tmp.value
                tmp.value = entry.value
                return oldValue
            case None =>
                //If the node is a leaf node, directly insert the node.
                if (node.isLeaf()) {
                    this._size++
                    this.modCount++
                    node.insertEntry(sr.index, entry)
                    return None
                }
                //Find the child node and determine whether to split it.
                var childNode: Node<K, V> = node.getChild(sr.index).getOrThrow()
                if (childNode.entrySize == MAX_ENTRY_SIZE) {
                    splitNode(node, childNode, sr.index)
                    match (node.searchEntry(entry.key).replaceNode) {
                        case Some(node) =>
                            let tmp = node.getEntry(sr.index).getOrThrow()
                            let oldValue = tmp.value
                            tmp.value = entry.value
                            return oldValue
                        case None => ()
                    }
                    if (entry.key > node.getEntry(sr.index).getOrThrow().key) {
                        childNode = node.getChild(sr.index + 1).getOrThrow()
                    }
                }
                return inserEntry(childNode, entry)
        }
    }

    /* Split a node. */
    func splitNode(node: Node<K, V>, splitNode: Node<K, V>, index: Int64) {
        //Right node after splitting
        var rightNode: Node<K, V> = Node<K, V>(node)
        //Distribute the element to the right node
        for (i in DEGREE..MAX_ENTRY_SIZE) {
            rightNode.entries.add(splitNode.entries[i])
        }
        var midEntry: TreeMapEntry<K, V> = splitNode.entries[DEGREE - 1]
        for (i in MAX_ENTRY_SIZE - 1..DEGREE - 2 : -1) {
            splitNode.entries.remove(at: i)
        }
        //If the node to be split is not a leaf node, assign the child to the right node.
        if (!splitNode.isLeaf()) {
            for (i in DEGREE..MAX_CHILD_SIZE) {
                let child = splitNode.children[i]
                rightNode.children.add(child)
                child._parent = rightNode
            }
            for (i in MAX_CHILD_SIZE - 1..DEGREE - 1 : -1) {
                splitNode.children.remove(at: i)
            }
        }
        //Raise the split element to the parent node.
        node.insertEntry(midEntry)
        node.insertChild(index + 1, rightNode)
    }

    /* Delete a node. */
    func deleteEntry(node: Node<K, V>, key: K): Option<V> {
        //Query the location of the element to be deleted
        var sr: SearchResult<K, V> = node.searchEntry(key)
        match (sr.replaceNode) {
            case Some(v) =>
                let oldValue: V
                //If the node is not a leaf node, search for the previous node.
                if (!v.isLeaf()) {
                    //Find the previous element of the deleted element
                    var psr = predecessor(sr)
                    //Swap the position of the predecessor element and the deleted element
                    if (let Some(rNode) <- psr.replaceNode) {
                        let entry = node.getEntry(sr.index).getOrThrow()
                        let rEntry = rNode.getEntry(psr.index).getOrThrow()
                        let key = entry.key
                        let value = entry.value
                        entry.reset(rEntry.key, rEntry.value)
                        rEntry.reset(key, value)
                        sr = psr
                    }
                }

                //Deletes an element.
                var curNode = sr.replaceNode.getOrThrow()
                oldValue = curNode.getEntry(sr.index).getOrThrow().value
                curNode.deleteEntry(sr.index)
                this._size--
                this.modCount++
                //If the number of node elements after deletion is less than the minimum number of elements
                while (curNode.entrySize < MIN_ENTRY_SIZE) {
                    //If the current node is the root node, the loop ends.
                    if (curNode._parent.isNone()) {
                        break
                    }
                    //Find the parent node of the current node.
                    let psr: SearchResult<K, V> = parentOf(curNode)
                    let parent: Node<K, V> = psr.replaceNode.getOrThrow()
                    var broNode: ?Node<K, V> = Node<K, V>.nullNode()
                    //If there is a left brother, and the left brother has an extra element, borrow an element from him.
                    if (psr.index > 0 && parent.getChild(psr.index - 1).getOrThrow().entrySize > MIN_ENTRY_SIZE) {
                        broNode = parent.getChild(psr.index - 1).getOrThrow()
                        curNode.insertEntry(0, parent.getEntry(psr.index - 1).getOrThrow())
                        parent.deleteEntry(psr.index - 1)
                        parent.insertEntry(psr.index - 1,
                            broNode.getOrThrow().getEntry(broNode.getOrThrow().entrySize - 1).getOrThrow())
                        if (broNode?.isLeaf() == false) {
                            let child = broNode.getOrThrow().getChild(broNode.getOrThrow().entrySize).getOrThrow()
                            curNode.insertChild(0, child)
                            child._parent = curNode
                            broNode?.deleteChild(broNode.getOrThrow().entrySize)
                        }
                        broNode?.deleteEntry(broNode.getOrThrow().entrySize - 1)
                        continue
                    }
                    //If there is a right brother, and the right brother has an extra element, borrow an element from him.
                    if (psr.index < parent.childrenSize - 1 && parent.getChild(psr.index + 1).getOrThrow().entrySize >
                        MIN_ENTRY_SIZE) {
                        broNode = parent.getChild(psr.index + 1).getOrThrow()
                        curNode.insertEntry(curNode.entrySize, parent.getEntry(psr.index).getOrThrow())
                        parent.deleteEntry(psr.index)
                        parent.insertEntry(psr.index, broNode.getOrThrow().getEntry(0).getOrThrow())
                        if (broNode?.isLeaf() == false) {
                            let child = broNode.getOrThrow().getChild(0).getOrThrow()
                            curNode.insertChild(curNode.entrySize, child)
                            child._parent = curNode
                            broNode?.deleteChild(0)
                        }
                        broNode?.deleteEntry(0)
                        continue
                    }
                    //Left and right brothers do not have redundant elements. Merge left and right brothers and parent nodes.
                    if (psr.index > 0) {
                        //There's left brother
                        broNode = parent.getChild(psr.index - 1).getOrThrow()
                        broNode?.insertEntry(parent.getEntry(psr.index - 1).getOrThrow())
                        for (i in 0..curNode.entrySize) {
                            broNode?.insertEntry(broNode.getOrThrow().entrySize, curNode.getEntry(i).getOrThrow())
                        }
                        if (!curNode.isLeaf()) {
                            for (i in 0..curNode.childrenSize) {
                                let child = curNode.getChild(i).getOrThrow()
                                broNode?.insertChild(broNode.getOrThrow().childrenSize, child)
                                child._parent = broNode
                            }
                        }
                        parent.deleteEntry(psr.index - 1)
                        parent.deleteChild(psr.index)
                    } else {
                        //There's a right brother
                        broNode = parent.getChild(psr.index + 1).getOrThrow()
                        curNode.insertEntry(parent.getEntry(psr.index).getOrThrow())
                        for (i in 0..broNode.getOrThrow().entrySize) {
                            curNode.insertEntry(curNode.entrySize, broNode.getOrThrow().getEntry(i).getOrThrow())
                        }
                        for (i in broNode.getOrThrow().entrySize - 1..-1 : -1) {
                            broNode?.deleteEntry(i)
                        }
                        if (broNode?.isLeaf() == false) {
                            for (i in 0..broNode.getOrThrow().childrenSize) {
                                let child = broNode.getOrThrow().getChild(i).getOrThrow()
                                curNode.insertChild(curNode.childrenSize, child)
                                child._parent = curNode
                            }
                        }
                        parent.deleteEntry(psr.index)
                        parent.deleteChild(psr.index + 1)
                    }
                    //If the parent node of the current node is the root node and there is no element left, the current node is the new root node.
                    if (parent._parent.isNone() && parent.isEmpty()) {
                        this.root = if (broNode.getOrThrow().isEmpty()) {
                            curNode
                        } else {
                            broNode.getOrThrow()
                        }
                        this.root._parent = Node<K, V>.nullNode()
                        break
                    }
                    curNode = parent
                }
                return oldValue
            case None => deleteEntry(node.getChild(sr.index).getOrThrow(), key)
        }
    }

    /* Search for the predecessor node. */
    func predecessor(sr: SearchResult<K, V>): SearchResult<K, V> {
        var curSr = sr
        var curNode = sr.replaceNode.getOrThrow()
        //If the current node is a leaf node
        if (curNode.isLeaf()) {
            //If the current node does not have redundant elements, query upwards.
            while (curSr.index < 1 && curNode._parent.isSome()) {
                curSr = parentOf(curNode)
                curNode = curSr.replaceNode.getOrThrow()
            }
            //Find the top-most parent node.
            if (curSr.index < 1) {
                //If the predecessor node is not found, there is no.
                return SearchResult<K, V>(-1, None)
            }

            return SearchResult<K, V>(curSr.index - 1, curNode)
        }
        //If the current node is a non-leaf node, it must have a left child.
        var leftChild = curNode.getChild(sr.index).getOrThrow()
        //If the left child is a leaf node, the rightmost element is returned, otherwise the loop looks for its rightmost child.
        while (!leftChild.isLeaf()) {
            leftChild = leftChild.getChild(leftChild.childrenSize - 1).getOrThrow()
        }
        return SearchResult<K, V>(leftChild.entrySize - 1, leftChild)
    }

    /* Query the successor node. */
    func successor(sr: SearchResult<K, V>): SearchResult<K, V> {
        var curSr = sr
        var curNode = sr.replaceNode.getOrThrow()
        //If the current node is a leaf node
        if (curNode.isLeaf()) {
            //If the current node has extra elements, the next one is returned.
            if (curSr.index < curNode.entrySize - 1) {
                return SearchResult<K, V>(curSr.index + 1, curNode)
            }

            if (curNode._parent.isNone()) {
                return SearchResult<K, V>(-1, None)
            }

            curSr = parentOf(curNode)
            curNode = curSr.replaceNode.getOrThrow()
            //If the current node does not have redundant elements, query upwards.
            while (curSr.index > curNode.entrySize - 1 && curNode._parent.isSome()) {
                curSr = parentOf(curNode)
                curNode = curSr.replaceNode.getOrThrow()
            }
            //Find the top-most parent node
            if (curSr.index > curNode.entrySize - 1) {
                //If the successor node is not found, then there is no.
                return SearchResult<K, V>(-1, None)
            }

            return SearchResult<K, V>(curSr.index, curNode)
        }
        //If the current node is a non-leaf node, it must have a right child.
        var rightChild = curNode.getChild(curSr.index + 1).getOrThrow()
        //If the right child is a leaf node, the leftmost element is returned, otherwise the loop looks for its leftmost child.
        while (!rightChild.isLeaf()) {
            rightChild = rightChild.getChild(0).getOrThrow()
        }

        return SearchResult<K, V>(0, rightChild)
    }

    /* Find the parent node of a node. */
    func parentOf(node: Node<K, V>): SearchResult<K, V> {
        let parent = node._parent
        var index = 0
        for (i in 0..parent.getOrThrow().childrenSize) {
            if (parent.getOrThrow().getChild(i).getOrThrow().quickEquals(node)) {
                index = i
                break
            }
        }

        return SearchResult<K, V>(index, parent)
    }

    public func entryView(k: K): MapEntryView<K, V> {
        let sr = searchEntry(this.root, k)
        return TreeMapEntryView(this, sr, key: k)
    }
}

extend<K, V> TreeMap<K, V> <: ToString where V <: ToString, K <: ToString & Comparable<K> {
    /**
     * Returns the string form of a TreeMap
     *
     * @since 0.43.1
     */
    public func toString(): String {
        let size: Int64 = this.size
        if (size == 0) {
            return "[]"
        }
        let emptyString: String = String.empty
        let elementSize: Int64 = (size << 1) + 1
        let stringArray: Array<String> = Array<String>(elementSize, repeat: emptyString)
        stringArray[0] = "["
        var index: Int64 = 1
        for ((k, v) in this) {
            stringArray[index] = "(${k}, ${v})"
            stringArray[index + 1] = ", "
            index += 2
        }
        stringArray[elementSize - 1] = "]"
        return String.join(stringArray)
    }
}

extend<K, V> TreeMap<K, V> <: Equatable<TreeMap<K, V>> where V <: Equatable<V> {
    /**
     * Compares whether two TreeMaps are equal.
     *
     * @param that Another TreeMap instance.
     * @return If two TreeMaps are equal, true is returned. Otherwise, false is returned.
     *
     * @since 0.43.1
     */
    public operator func ==(right: TreeMap<K, V>): Bool {
        if (refEq(this, right)) {
            return true
        }

        if (this.size != right.size) {
            return false
        }

        for ((leftKey, leftValue) in this) {
            var a = match (right.get(leftKey)) {
                case Some(v) => v
                case None => return false
            }
            if (a != leftValue) {
                return false
            }
        }

        return true
    }

    /**
     * Compares whether two TreeMaps are not equal.
     *
     * @param that Another TreeMap instance.
     * @return If two TreeMaps are equal, false is returned. Otherwise, true is returned.
     *
     * @since 0.43.1
     */
    public operator func !=(right: TreeMap<K, V>): Bool {
        return !(this == right)
    }
}

struct TreeMapEntryView<K, V> <: MapEntryView<K, V> where K <: Comparable<K> {
    let map: TreeMap<K, V>
    var curNode: SearchResult<K, V>
    var lockVersion: Int64
    var _key: ?K
    init(map: TreeMap<K, V>, curNode: SearchResult<K, V>, key!: ?K = None) {
        this.map = map
        this.curNode = curNode
        this.lockVersion = map.version()
        this._key = key
    }

    /*
     * Gets the key of the node.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     */
    public prop key: K {
        get() {
            if (lockVersion != this.map.version()) {
                throw ConcurrentModificationException()
            }

            return if (let Some(node) <- curNode.replaceNode) {
                let entry = node.getEntry(curNode.index).getOrThrow()
                entry.key
            } else {
                this._key.getOrThrow()
            }
        }
    }

    /*
     * Gets or modify the key of the node.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     */
    public mut prop value: ?V {
        get() {
            if (lockVersion != this.map.version()) {
                throw ConcurrentModificationException()
            }

            return match (curNode.replaceNode) {
                case Some(node) =>
                    let entry = node.getEntry(curNode.index).getOrThrow()
                    entry.value
                case None => None
            }
        }
        set(v) {
            if (lockVersion != this.map.version()) {
                throw ConcurrentModificationException()
            }

            if (v.isNone()) {
                map.remove(key)
                lockVersion = this.map.version()
                curNode = SearchResult<K, V>(-1, None)
            } else {
                match (curNode.replaceNode) {
                    case Some(node) =>
                        let entry = node.getEntry(curNode.index).getOrThrow()
                        entry.value = v.getOrThrow()
                    case None =>
                        map.add(key, v.getOrThrow())
                        curNode = this.map.searchEntryFromRoot(_key.getOrThrow())
                }
                lockVersion = this.map.version()
            }
        }
    }

    func nextNode(): TreeMapEntryView<K, V> {
        let sr = this.map.successor(curNode)
        return TreeMapEntryView<K, V>(this.map, sr)
    }

    func prevNode(): TreeMapEntryView<K, V> {
        let sr = this.map.predecessor(curNode)
        return TreeMapEntryView<K, V>(this.map, sr)
    }

    func isSome(): Bool {
        return curNode.replaceNode.isSome()
    }
}

class ForwardIterator<K, V> <: Iterator<(K, V)> where K <: Comparable<K> {
    private var curNode: TreeMapEntryView<K, V>
    private var key: K
    private var inclusive: Bool

    /**
     * Initialize the iterator and transfer the treemap.
     *
     * @param map the treemap to be transferred.
     *
     * @since 0.43.1
     */
    init(node: TreeMapEntryView<K, V>, key: K, inclusive: Bool) {
        this.curNode = if (inclusive || !node.isSome()) {
            node
        } else {
            node.nextNode()
        }
        this.key = key
        this.inclusive = inclusive
    }

    /**
     * Iterate over the nodes of the treemap. The return type is Option, which contains key and value.
     *
     * @return type is Option, which contains key and value.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     * @since 0.43.1
     */
    @Frozen
    public func next(): Option<(K, V)> {
        checkVersion(curNode)
        if (curNode.isSome()) {
            let item = curNode
            curNode = curNode.nextNode()
            return match (item.value) {
                case Some(value) => (item.key, value)
                case None => None
            }
        }
        return None
    }
}

class BackwardIterator<K, V> <: Iterator<(K, V)> where K <: Comparable<K> {
    private var curNode: TreeMapEntryView<K, V>
    private var key: K
    private var inclusive: Bool

    /**
     * Initialize the iterator and transfer the treemap.
     *
     * @param map the treemap to be transferred.
     *
     * @since 0.43.1
     */
    init(node: TreeMapEntryView<K, V>, key: K, inclusive: Bool) {
        this.curNode = if (inclusive || !node.isSome()) {
            node
        } else {
            node.prevNode()
        }
        this.key = key
        this.inclusive = inclusive
    }

    /**
     * Iterate over the nodes of the treemap. The return type is Option, which contains key and value.
     *
     * @return type is Option, which contains key and value.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.map.version()".
     *
     * @since 0.43.1
     */
    @Frozen
    public func next(): Option<(K, V)> {
        checkVersion(curNode)
        if (curNode.isSome()) {
            let item = curNode
            curNode = curNode.prevNode()
            return match (item.value) {
                case Some(value) => (item.key, value)
                case None => None
            }
        }
        return None
    }
}

func checkVersion<K, V>(node: TreeMapEntryView<K, V>) where K <: Comparable<K> {
    if (node.lockVersion != node.map.version()) {
        throw ConcurrentModificationException()
    }
}

/**
 * This class is a collection of K types of treemap and is suitable for stripping key-value pair types.
 *
 * @since 0.43.1
 */
class TreeMapKeys<K, V> <: EquatableCollection<K> where K <: Comparable<K> {
    private let map: TreeMap<K, V>
    public init(m: TreeMap<K, V>) {
        this.map = m
    }

    /**
     * Returns sizes of key-value.
     *
     * @return sizes of key-value.
     *
     * @since 0.43.1
     */
    public prop size: Int64 {
        get() {
            this.map.size
        }
    }

    /**
     * Check whether the size is empty. If yes, true is returned. Otherwise, false is returned.
     *
     * @return bool if yes, true is returned. Otherwise, false is returned.
     *
     * @since 0.43.1
     */
    public func isEmpty(): Bool {
        return this.map.isEmpty()
    }

    /**
     * Checks whether the mapping relationship corresponding to the specified key exists in this mapping.
     *
     * @param element transfer the key to be judged.
     * @return bool returns true if exists; otherwise, false.
     *
     * @since 0.43.1
     */
    public func contains(element: K): Bool {
        return this.map.contains(element)
    }

    /**
     * Checks whether the mapping relationship corresponding to the collection key exists in this mapping.
     *
     * @param elements transfer the collection key to be judged.
     * @return bool returns true if exists; otherwise, false.
     *
     * @since 0.43.1
     */
    public func contains(all!: Collection<K>): Bool {
        return this.map.contains(all: all)
    }

    /**
     * Returns iterator of treemap.
     *
     * @return iterator of treemap.
     *
     * @since 0.43.1
     */
    @Frozen
    public func iterator(): Iterator<K> {
        return map.iterator().map<K> {i: (K, V) => i[0]}
    }
}

/**
 * This class is a collection of V types of treemaps and is suitable for stripping key-value pair types.
 *
 * @since 0.43.1
 */
class TreeMapValues<K, V> <: Collection<V> where K <: Comparable<K> {
    private let map: TreeMap<K, V>

    public init(m: TreeMap<K, V>) {
        this.map = m
    }

    /**
     * Returns sizes of values.
     *
     * @return sizes of values.
     *
     * @since 0.43.1
     */
    public prop size: Int64 {
        get() {
            return this.map.size
        }
    }

    /**
     * Check whether the size is empty. If yes, true is returned. Otherwise, false is returned.
     *
     * @return bool if yes, true is returned. Otherwise, false is returned.
     *
     * @since 0.43.1
     */
    public func isEmpty(): Bool {
        return this.map.isEmpty()
    }

    /**
     * Returns value Iterator<T> - Iterator<T> type, which can be traversed using an iterator.
     *
     * @return the value corresponding to the return key is encapsulated with Option.
     *
     * @since 0.43.1
     */
    @Frozen
    public func iterator(): Iterator<V> {
        return map.iterator().map<V> {i: (K, V) => i[1]}
    }
}

/**
 * This is a treemap iterator used to iterate effects.
 *
 * @since 0.43.1
 */
class TreeMapIterator<K, V> <: Iterator<(K, V)> where K <: Comparable<K> {
    private var curNode: TreeMapEntryView<K, V>

    /**
     * Initialize the iterator and transfer the treemap.
     *
     * @param map the treemap to be transferred.
     *
     * @since 0.43.1
     */
    public init(node: TreeMapEntryView<K, V>) {
        this.curNode = node
    }

    /**
     * Iterate over the nodes of the treemap. The return type is Option, which contains key and value.
     *
     * @return type is Option, which contains key and value.
     *
     * @throws ConcurrentModificationException if lockVersion is not equal to "this.data.version()".
     *
     * @since 0.43.1
     */
    @Frozen
    public func next(): Option<(K, V)> {
        checkVersion(curNode)
        if (curNode.isSome()) {
            let item = curNode
            curNode = curNode.nextNode()
            return (item.key, item.value.getOrThrow())
        }
        return None
    }
}

class Node<K, V> where K <: Comparable<K> {
    var entries: ArrayList<TreeMapEntry<K, V>>
    var _parent: ?Node<K, V>
    var children: ArrayList<Node<K, V>>

    static func nullNode(): ?Node<K, V> {
        return None<Node<K, V>>
    }

    init(parent: ?Node<K, V>) {
        this._parent = parent
        this.entries = ArrayList<TreeMapEntry<K, V>>()
        this.children = ArrayList<Node<K, V>>()
    }

    func isLeaf(): Bool {
        return this.children.size == 0
    }

    prop entrySize: Int64 {
        get() {
            this.entries.size
        }
    }

    prop childrenSize: Int64 {
        get() {
            this.children.size
        }
    }

    func quickEquals(that: Node<K, V>): Bool {
        refEq(this, that)
    }

    func isEmpty(): Bool {
        return entrySize == 0
    }

    func searchEntry(key: K): SearchResult<K, V> {
        if (entrySize == 0) {
            return SearchResult(0, None)
        }
        var begin: Int64 = 0
        var end: Int64 = entrySize - 1
        var mid: Int64 = 0
        while (begin < end) {
            mid = begin + ((end - begin) >> 1)
            let midKey: K = this.entries[mid].key
            if (key == midKey) {
                break
            } else if (key > midKey) {
                begin = mid + 1
            } else {
                end = mid - 1
            }
        }
        return if (begin < end) {
            SearchResult<K, V>(mid, this)
        } else if (begin == end) {
            let midKey: K = this.entries[begin].key
            if (key == midKey) {
                SearchResult<K, V>(begin, this)
            } else if (key > midKey) {
                SearchResult<K, V>(begin + 1, None)
            } else {
                SearchResult<K, V>(begin, None)
            }
        } else {
            SearchResult<K, V>(begin, None)
        }
    }

    func getEntry(index: Int64): Option<TreeMapEntry<K, V>> {
        return entries.get(index)
    }

    func insertEntry(entry: TreeMapEntry<K, V>): Option<V> {
        var sr = searchEntry(entry.key)
        match (sr.replaceNode) {
            case Some(v) =>
                let tmp = v.entries[sr.index]
                let oldValue = tmp.value
                tmp.value = entry.value
                return oldValue
            case None =>
                this.entries.add(entry, at: sr.index)
                return Option<V>.None
        }
    }

    func insertEntry(index: Int64, entry: TreeMapEntry<K, V>): Unit {
        this.entries.add(entry, at: index)
    }

    func deleteEntry(index: Int64): Unit {
        this.entries.remove(at: index)
    }

    func getChild(index: Int64): ?Node<K, V> {
        return this.children.get(index)
    }

    func deleteChild(index: Int64): Unit {
        this.children.remove(at: index)
    }

    func insertChild(index: Int64, node: Node<K, V>) {
        this.children.add(node, at: index)
    }
}

struct SearchResult<K, V> where K <: Comparable<K> {
    private var _index: Int64
    private var _replaceNode: ?Node<K, V>

    init(index: Int64, node: ?Node<K, V>) {
        this._replaceNode = node
        this._index = index
    }

    prop index: Int64 {
        get() {
            this._index
        }
    }

    prop replaceNode: ?Node<K, V> {
        get() {
            this._replaceNode
        }
    }
}

class TreeMapEntry<K, V> where K <: Comparable<K> {
    private var _key: K
    private var _value: V

    init(key: K, value: V) {
        this._key = key
        this._value = value
    }

    prop key: K {
        get() {
            _key
        }
    }

    mut prop value: V {
        get() {
            _value
        }
        set(v) {
            this._value = v
        }
    }

    func reset(key: K, value: V) {
        this._key = key
        this._value = value
    }
}
