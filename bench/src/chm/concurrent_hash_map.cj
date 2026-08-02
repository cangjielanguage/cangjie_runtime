/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package bench.chm

import std.sync.*
import std.collection.MapEntryView
import std.collection.concurrent.ConcurrentMap

/**
 * The type of key-value. It is a tuple including:
 * - Int64: the hashcode of the K;
 * - K: the type of key;
 * - V: the type of value.
 */
type KeyValue<K, V> = (Int64, K, V)

/**
 * KVList represent a list of KeyValue type instances.
 * It is used to handle key's hash conflictions.
 */
class KVList<K, V> where K <: Equatable<K> {
    var myData: Array<KeyValue<K, V>>
    var mySize: Int64

    /**
     * INIT_ARRAY_SIZE:
     * records the initial size of the arraylist in the bucket.
     * We set INIT_ARRAY_SIZE = 2,
     * since each bucket will not store too many key-value pairs,
     * and the size of the arraylist is extensible to handle the extraordinary condition.
     * Allocating an arraylist whose size is small is efficient.
     */
    static const INIT_ARRAY_SIZE = 2

    init() {
        this(INIT_ARRAY_SIZE)
    }

    init(capacity: Int64) {
        mySize = 0
        let zero: KeyValue<K, V> = unsafe { zeroValue<KeyValue<K, V>>() }
        myData = Array<KeyValue<K, V>>(capacity, repeat: zero)
    }

    init(blist: KVList<K, V>) {
        myData = blist.myData.clone()
        mySize = blist.mySize
    }

    /* Private constructor with pre-built storage, to avoid double allocation on copy-on-write. */
    init(data: Array<KeyValue<K, V>>, size: Int64) {
        myData = data
        mySize = size
    }

    @Frozen
    @OverflowWrapping
    func contains(hash: Int64, key: K): Int64 {
        var i = 0
        while (i < mySize) {
            if (hash == myData[i][0] && key == myData[i][1]) {
                return i
            }
            i++
        }
        return -1
    }

    @Frozen
    @OverflowWrapping
    func find(hash: Int64, key: K): ?V {
        var i = 0
        while (i < mySize) {
            if (hash == myData[i][0] && key == myData[i][1]) {
                return myData[i][2]
            }
            i++
        }
        return None
    }

    @OverflowWrapping
    func copyInsert(hash: Int64, key: K, value: V): KVList<K, V> {
        let newSize = mySize + 1
        let oldCap = myData.size
        var newCap = oldCap
        if (newSize > oldCap) {
            // same growth policy as grow(): old + old>>1, at least newSize
            newCap = oldCap + (oldCap >> 1)
            if (newCap < newSize) {
                newCap = newSize
            }
        }
        let zero: KeyValue<K, V> = unsafe { zeroValue<KeyValue<K, V>>() }
        let newArr = Array<KeyValue<K, V>>(newCap, repeat: zero)
        myData.copyTo(newArr, 0, 0, mySize)
        newArr[mySize] = (hash, key, value)
        return KVList<K, V>(newArr, newSize)
    }

    func copyPut(hash: Int64, key: K, value: V): (KVList<K, V>, ?V) {
        let i = contains(hash, key)
        if (i == -1) {
            return (copyInsert(hash, key, value), None)
        } else {
            let copyList = KVList<K, V>(this)
            copyList.myData[i] = (hash, key, value)
            return (copyList, myData[i][2])
        }
    }

    func copyRemove(hash: Int64, key: K, predicate: (V) -> Bool): (KVList<K, V>, ?V) {
        // scan for the key without invoking the predicate per element,
        // then apply the predicate once on the found element (keys are unique)
        let i = contains(hash, key)
        if (i == -1) {
            return (this, None)
        }
        if (!predicate(myData[i][2])) {
            return (this, None)
        }

        let copyList = copyRemoveUnChecked(i)
        return (copyList, myData[i][2])
    }

    func copyRemoveUnChecked(idx: Int64): KVList<K, V> {
        let newSize = mySize - 1
        let zero: KeyValue<K, V> = unsafe { zeroValue<KeyValue<K, V>>() }
        let newArr = Array<KeyValue<K, V>>(myData.size, repeat: zero)
        // batch copy the two segments around the removed element instead of shifting one by one
        myData.copyTo(newArr, 0, 0, idx)
        myData.copyTo(newArr, idx + 1, idx, mySize - idx - 1)
        return KVList<K, V>(newArr, newSize)
    }

    func copyReplace(hash: Int64, key: K, predicate: (V) -> Bool, eval: (V) -> V): (KVList<K, V>, ?V) {
        // scan for the key without invoking the predicate per element,
        // then apply the predicate once on the found element (keys are unique)
        let i = contains(hash, key)
        if (i == -1) {
            return (this, None)
        }
        if (!predicate(myData[i][2])) {
            return (this, None)
        }

        // single-allocation copy instead of clone-then-write
        let zero: KeyValue<K, V> = unsafe { zeroValue<KeyValue<K, V>>() }
        let newArr = Array<KeyValue<K, V>>(myData.size, repeat: zero)
        myData.copyTo(newArr, 0, 0, mySize)
        newArr[i] = (hash, key, eval(myData[i][2]))
        return (KVList<K, V>(newArr, mySize), myData[i][2])
    }

    func copyEntryView(hash: Int64, key: K, fn: (entryView: MapEntryView<K, V>) -> Unit): (KVList<K, V>, ?V, ?Int64) {
        let i = contains(hash, key)
        var entryView = if (i == -1) {
            ConcurrentHashMapEntryView<K, V>(key, None)
        } else {
            ConcurrentHashMapEntryView<K, V>(key, myData[i][2])
        }

        fn(entryView)

        match ((i == -1, entryView.value)) {
            // nothing to do
            case (true, None) => return (this, None, None)
            // add
            case (true, Some(v)) => return (copyInsert(hash, key, v), v, 1)
            // remove
            case (false, None) => return (copyRemoveUnChecked(i), None, -1)
            case (false, Some(v)) =>
                // nothing to do
                if (!entryView.update) {
                    return (this, v, None)
                }
                // replace
                let copyList = KVList<K, V>(this)
                copyList.myData[i] = (hash, key, v)
                return (copyList, v, None)
        }
    }

    /**
     * Migrate the elements, whose hash % (mask + 1) == index, of the current bucket into a new KVList.
     */
    @OverflowWrapping
    func migrate(mask: Int64, index: Int64): KVList<K, V> {
        let copyList = KVList<K, V>()
        var i = 0
        while (i < mySize) {
            if ((myData[i][0] & mask) == index) {
                copyList.append(myData[i])
            }
            i++
        }
        return copyList
    }

    prop size: Int64 {
        get() {
            mySize
        }
    }

    @Frozen
    operator func [](index: Int64): KeyValue<K, V> {
        myData[index]
    }

    @OverflowWrapping
    func appendUncheck(element: KeyValue<K, V>) {
        myData[mySize] = element
        mySize++
    }

    func grow(): Unit {
        let oldCapacity: Int64 = myData.size
        var newCapacity: Int64 = oldCapacity + (oldCapacity >> 1)
        let zero: KeyValue<K, V> = unsafe { zeroValue<KeyValue<K, V>>() }
        let newArr = Array<KeyValue<K, V>>(newCapacity, repeat: zero)
        myData.copyTo(newArr, 0, 0, mySize)
        myData = newArr
    }

    @OverflowWrapping
    private func append(element: KeyValue<K, V>) {
        if (mySize == myData.size) {
            grow()
        }
        myData[mySize] = element
        mySize++
    }

    @OverflowWrapping
    private func contains(hash: Int64, key: K, predicate: (V) -> Bool): Int64 {
        var i = 0
        while (i < mySize) {
            if (hash == myData[i][0] && key == myData[i][1] && predicate(myData[i][2])) {
                return i
            }
            i++
        }
        return -1
    }
}

/**
 * FindKey<V> Type defines the result of searching a key-value pair in a bucket:
 * - FIND(v): finds the specified key-value pair whose value is r'v'
 * - NotFind: does not find the specified key-value pair
 * - NotMigrate: means that the key-value pairs in such bucket are waiting for migration
 */
enum FindKey<V> {
    | FIND(V)
    | NotFind
    | NotMigrate
}

struct Bucket<K, V> where K <: Equatable<K> {
    /**
     * The reference of the arraylist in the bucket.
     */
    let atomic_ref_entries = AtomicOptionReference(None<KVList<K, V>>)

    /**
     * Returns the value associated with @p key.
     */
    @Frozen
    func find(hash: Int64, key: K): FindKey<V> {
        if (let Some(entries) <- refList()) {
            if (let Some(v) <- entries.find(hash, key)) {
                return FIND(v)
            }
            return NotFind
        }
        return NotMigrate
    }

    func copyAddIfAbsent(hash: Int64, key: K, value: V): ?V {
        if (let Some(entries) <- refList()) {
            if (let Some(v) <- entries.find(hash, key)) {
                return v
            }
            let copyEntries = entries.copyInsert(hash, key, value)
            atomic_ref_entries.store(copyEntries)
        } else {
            let copyEntries = KVList<K, V>()
            copyEntries.appendUncheck((hash, key, value))
            atomic_ref_entries.store(copyEntries)
        }
        return None
    }

    func copyPut(hash: Int64, key: K, value: V): ?V {
        var copyEntries: KVList<K, V>
        var ret = None<V>
        if (let Some(entries) <- refList()) {
            (copyEntries, ret) = entries.copyPut(hash, key, value)
            atomic_ref_entries.store(copyEntries)
        } else {
            copyEntries = KVList<K, V>()
            copyEntries.appendUncheck((hash, key, value))
            atomic_ref_entries.store(copyEntries)
        }
        return ret
    }

    /**
     * Like copyPut, but takes the bucket list loaded by tryGetBucket,
     * avoiding a second atomic read of the bucket reference.
     */
    func copyPutWith(hash: Int64, key: K, value: V, entries: ?KVList<K, V>): ?V {
        if (let Some(es) <- entries) {
            let (copyEntries, ret) = es.copyPut(hash, key, value)
            atomic_ref_entries.store(copyEntries)
            return ret
        }
        let copyEntries = KVList<K, V>()
        copyEntries.appendUncheck((hash, key, value))
        atomic_ref_entries.store(copyEntries)
        return None
    }

    func copyRemove(hash: Int64, key: K, predicate: (V) -> Bool): ?V {
        if (let Some(entries) <- refList()) {
            let (copyEntries, ret) = entries.copyRemove(hash, key, predicate)
            atomic_ref_entries.store(copyEntries)
            return ret
        }
        return None
    }

    /**
     * Like copyRemove, but takes the bucket list loaded by tryGetBucket,
     * avoiding a second atomic read of the bucket reference.
     *
     * @p allowDrop: when true and the bucket becomes empty, the list is dropped
     * (stored as None) to avoid an allocation. This is only safe when the table
     * has no previous table to fall back to; otherwise a None bucket would make
     * readers look up the stale previous table.
     */
    func copyRemoveWith(hash: Int64, key: K, predicate: (V) -> Bool, entries: ?KVList<K, V>, allowDrop: Bool): ?V {
        if (let Some(es) <- entries) {
            if (allowDrop && es.size == 1) {
                let i = es.contains(hash, key)
                if (i == 0 && predicate(es[i][2])) {
                    atomic_ref_entries.store(None)
                    return es[i][2]
                }
                return None
            }
            let (copyEntries, ret) = es.copyRemove(hash, key, predicate)
            if (allowDrop && copyEntries.size == 0) {
                atomic_ref_entries.store(None)
            } else {
                atomic_ref_entries.store(copyEntries)
            }
            return ret
        }
        return None
    }

    func copyReplace(hash: Int64, key: K, predicate: (V) -> Bool, eval: (V) -> V): ?V {
        if (let Some(entries) <- refList()) {
            let (copyEntries, ret) = entries.copyReplace(hash, key, predicate, eval)
            atomic_ref_entries.store(copyEntries)
            return ret
        }
        return None
    }

    func copyEntryView(hash: Int64, key: K, fn: (entryView: MapEntryView<K, V>) -> Unit): (?V, ?Int64) {
        let entries = match (refList()) {
            case Some(es) => es
            case None => KVList<K, V>()
        }
        let (copyEntries, value, resize) = entries.copyEntryView(hash, key, fn)
        atomic_ref_entries.store(copyEntries)
        return (value, resize)
    }

    /**
     * Migrate the the elements, whose hash % (mask + 1) == index, of @p optEntries into the current bucket.
     */
    func migrate(optEntries: ?KVList<K, V>, mask: Int64, index: Int64): Unit {
        if (refList().isSome()) {
            return
        }

        if (let Some(entries) <- optEntries) {
            let copyEntries = entries.migrate(mask, index)
            atomic_ref_entries.store(copyEntries) // substitute the arraylist of the bucket to 'copyEntries'
        }
    }

    func refList(): ?KVList<K, V> {
        return atomic_ref_entries.load()
    }
}

/**
 * MutexLockGroup is a set of reentrant mutexes for bucket updating in ConcurrentHashMap.
 */
class MutexLockGroup {
    let mutexes: Array<Mutex>
    private let mod: Int64

    init(cap: Int64) {
        mutexes = Array<Mutex>(cap, {_ => Mutex()})
        mod = cap - 1
    }

    func lock(index: Int64): Unit {
        mutexes[(index & mod)].lock()
    }

    func unlock(index: Int64): Unit {
        mutexes[(index & mod)].unlock()
    }
}

/**
 * HNode is the definition of the hash table,
 * which is a core component of the ConcurrentHashMap.
 */
class HNode<K, V> where K <: Hashable & Equatable<K> {
    /* The collection of the buckets of the hash table */
    let buckets: Array<Bucket<K, V>>
    /* Freeze flags mark whether the corresponding bucket is frozen */
    var freezeFlags: Array<Bool>
    let lockG: MutexLockGroup
    let version: Int64
    let migratingIndex = AtomicInt64(0)
    let migratedIndex = AtomicInt64(0)
    /**
     * The reference of the previous hash table,
     * which is the current hash table before the latest size extension.
     */
    let pre: AtomicOptionReference<HNode<K, V>>

    init(capacity: Int64, refPre: ?HNode<K, V>, lockG: MutexLockGroup, version: Int64) {
        let zero = unsafe { zeroValue<Bucket<K, V>>() }
        buckets = Array<Bucket<K, V>>(capacity, repeat: zero)
        for (i in 0..capacity) {
            buckets[i] = Bucket<K, V>()
        }
        freezeFlags = Array<Bool>(capacity, repeat: false)
        this.lockG = lockG
        this.version = version
        this.pre = AtomicOptionReference(refPre)
    }

    func freeze(index: Int64) {
        lockG.lock(index)
        freezeFlags[index] = true
        lockG.unlock(index)
    }

    /**
     * Gets the value associated with @p key from the hash table.
     */
    @OverflowWrapping
    @Frozen
    func getValue(hash: Int64, key: K): Option<V> {
        let index = hash & (buckets.size - 1)

        /*
         * Looks up the bucket of the current hash table firstly; when the bucket is
         * None it means its elements have not been migrated from the previous table,
         * so fall back to the previous table.
         */
        if (let Some(entries) <- buckets[index].refList()) {
            return entries.find(hash, key)
        }
        if (let Some(preHT) <- pre.load()) {
            return match (preHT.buckets[hash & (preHT.buckets.size - 1)].find(hash, key)) {
                case FIND(v) => Some(v)
                case _ => None<V>
            }
        }
        return None<V>
    }

    /**
     * Migrates the elements from the previous hash table to buckets[@p index] of the current hash table.
     */
    @OverflowWrapping
    func migrate(start: Int64, end: Int64, step: Int64): Unit {
        if (let Some(preHT) <- pre.load()) {
            lockG.lock(start)
            for (index in start..end : step) {
                if (buckets[index].refList().isSome()) {
                    continue
                }
                let preIndex = index & (preHT.buckets.size - 1) // Index of bucket remains to be migrated
                preHT.freeze(preIndex)
                buckets[index].migrate(preHT.buckets[preIndex].refList(), buckets.size - 1, index)
            }
            lockG.unlock(start)
        }
    }

    /**
     * Prepares the bucket for updating.
     * Returns (entries, ready):
     * - ready == false: the bucket is frozen, caller should reload head and retry;
     * - ready == true: the bucket is ready; entries are the bucket list
     *   (None means the bucket is currently empty). The bucket lock is held
     *   until the caller calls unlock.
     */
    @OverflowWrapping
    func tryGetBucket(index: Int64): (?KVList<K, V>, Bool) {
        lockG.lock(index)
        if (freezeFlags[index]) {
            lockG.unlock(index)
            return (None, false)
        }

        if (let Some(entries) <- buckets[index].refList()) {
            return (Some(entries), true)
        }

        if (let Some(preHT) <- pre.load()) {
            let preIndex = index & (preHT.buckets.size - 1) // Index of bucket remains to be migrated
            preHT.freeze(preIndex)
            buckets[index].migrate(preHT.buckets[preIndex].refList(), buckets.size - 1, index)
        }

        return (buckets[index].refList(), true)
    }
}

class ConcurrentHashMapEntryView<K, V> <: MapEntryView<K, V> {
    let _key: K
    var _value: ?V
    var update: Bool = false

    ConcurrentHashMapEntryView(key: K, value: ?V) {
        this._key = key
        this._value = value
    }

    public prop key: K {
        get() {
            _key
        }
    }

    public mut prop value: ?V {
        get() {
            _value
        }
        set(val) {
            this.update = true
            this._value = val
        }
    }
}

/**
 * The definition of the ConcurrentHashMap with load factor 1.
 * Load factor is 1, indicating that the number of buckets in the ConcurrentHashMap equals to
 * the number of key-value pairs usually.
 * And if the number of key-value pairs is greater than the number of buckets in the ConcurrentHashMap,
 * capacity expansion will occur.
 */
public class ConcurrentHashMap<K, V> <: ConcurrentMap<K, V> & Collection<(K, V)> where K <: Hashable & Equatable<K> {
    /* default number of the buckets */
    private static const DEFAULT_CAPACITY: Int64 = 16

    /* Max size of buckets and concurrencyLevel */
    private static const MAX_SIZE: Int64 = 4611686018427387904

    /**
     * By default, we use 16 reentrant mutexes to synchronize
     * different threads modifying the same bucket.
     * It means that up to 16 threads are allowed to update ConcurrentHashMap concurrently.
     */
    private static const DEFAULT_CONCUR_LEVEL: Int64 = 16

    /* counts: using 16 atomic uint64 variables to count the number of key-value pairs in concurrent hashmap */
    private let counts = Array<AtomicInt64>(1 << COUNT_SIZE, {_ => AtomicInt64(0)})
    /* COUNT_SIZE: the bits of the size of 'counts' array, counts.size = 1 << COUNT_SIZE */
    private static const COUNT_SIZE = 4

    /* version number of the current HNode */
    let curHNodeVersion = AtomicInt64(0)

    /* head: points to the current HNode */
    let head: AtomicReference<HNode<K, V>>

    /* group of locks to avoid two threads modifying the same bucket */
    let lockG: Array<MutexLockGroup>

    /**
     * concurrencyLevel is the number of reentrant mutexes to synchronize
     * different threads updating the same bucket.
     * It indicates the maximum number of threads allowed to update ConcurrentHashMap concurrently.
     * Two threads updating bucket[i] is synchronized by reentrant mutex j,
     * if and only if (i % concurrencyLevel == j).
     *
     * It does not mean that a greater concurrencyLevel is better.
     * The concurrencyLevel specifies the number of reentrant mutexes for updating ConcurrentHashMap concurrently.
     * A greater concurrencyLevel will cause greater memory overhead.
     */
    let concurrencyLevel: Int64

    /************************ Public Methods *******************************/
    /**
     * Create a ConcurrentHashMap, whose initial capacity is DEFAULT_CAPACITY (=16) and
     * concurrencyLevel is @p concurrencyLevel.
     * The default concurrencyLevel is DEFAULT_CONCUR_LEVEL (=16).
     *
     * @param concurrencyLevel: the number of reentrant mutexes for synchronization.
     */
    public init(concurrencyLevel!: Int64 = DEFAULT_CONCUR_LEVEL) {
        let lockCnt = tableSizeFor(concurrencyLevel)
        this.lockG = Array<MutexLockGroup>(2, {_ => MutexLockGroup(lockCnt)})
        this.concurrencyLevel = lockCnt
        this.head = AtomicReference(HNode<K, V>(DEFAULT_CAPACITY, None, lockG[0], 0))
    }

    /**
     * Create a ConcurrentHashMap, whose initial capacity is @p capacity and
     * concurrencyLevel is @p concurrencyLevel.
     * The default concurrencyLevel is DEFAULT_CONCUR_LEVEL (=16).
     *
     * @param capacity: initial capacity of the ConcurrentHashMap;
     * @param concurrencyLevel: the number of reentrant mutexes for synchronization.
     *
     * @throws IllegalArgumentException if capacity is less than zero.
     */
    public init(capacity: Int64, concurrencyLevel!: Int64 = DEFAULT_CONCUR_LEVEL) {
        if (capacity < 0) {
            throw IllegalArgumentException("Invalid size of Concurrent HashMap: ${capacity}.")
        }

        let lockCnt = tableSizeFor(concurrencyLevel)
        this.lockG = Array<MutexLockGroup>(2, {_ => MutexLockGroup(lockCnt)})
        this.concurrencyLevel = lockCnt
        this.head = AtomicReference(HNode<K, V>(tableSizeFor(capacity), None, lockG[0], 0))
    }

    /**
     * Create a ConcurrentHashMap with an incoming list for initialization.
     *
     * @param elements: an incoming list is initialized;
     * @param concurrencyLevel: the number of reentrant mutexes for synchronization.
     */
    public init(elements: Collection<(K, V)>, concurrencyLevel!: Int64 = DEFAULT_CONCUR_LEVEL) {
        let lockCnt = tableSizeFor(concurrencyLevel)
        this.lockG = Array<MutexLockGroup>(2, {_ => MutexLockGroup(lockCnt)})
        this.concurrencyLevel = lockCnt
        this.head = AtomicReference(HNode<K, V>(tableSizeFor(elements.size), None, lockG[0], 0))
        for ((k, v) in elements) {
            this.add(k, v)
        }
    }

    /**
     * Create a ConcurrentHashMap with an incoming list for initialization.
     *
     * @param elements: an incoming list is initialized;
     * @param concurrencyLevel: the number of reentrant mutexes for synchronization.
     */
    public init(size: Int64, initElement: (Int64) -> (K, V), concurrencyLevel!: Int64 = DEFAULT_CONCUR_LEVEL) {
        if (size < 0) {
            throw IllegalArgumentException("Invalid size of Concurrent HashMap: ${size}.")
        }

        let lockCnt = tableSizeFor(concurrencyLevel)
        this.lockG = Array<MutexLockGroup>(2, {_ => MutexLockGroup(lockCnt)})
        this.concurrencyLevel = lockCnt
        this.head = AtomicReference(HNode<K, V>(tableSizeFor(size), None, lockG[0], 0))
        for (i in 0..size) {
            let (key, value) = initElement(i)
            this.add(key, value)
        }
    }

    /**
     * Returns the value associated with @p key.
     *
     * @param key: transfer key to obtain the value.
     * @return: the value corresponding to the return key is encapsulated with option.
     */
    @Frozen
    public func get(key: K): ?V {
        let hash = key.hashCode()
        return head.load().getValue(hash, key)
    }

    /**
     * Checks whether the mapping relationship corresponding to the specified key exists in this mapping.
     *
     * @param key: transfers the key to be judged.
     * @return: returns true if exists; otherwise, false.
     */
    @Frozen
    public func contains(key: K): Bool {
        return match (get(key)) {
            case None => false
            case _ => true
        }
    }

    /**
     * Add a new key value to the map. If the key already exists,
     * the value will be overwritten and the overwritten value will be returned.
     *
     * @param key: the key to put;
     * @param value: the value to put.
     *
     * @return:
     * - None: if @p key does not exist before putting;
     * - Some(v): if @p key associated with v before putting.
     */
    @Deprecated[message: "Use member function `public func add(key: K, value: V): ?V` instead."]
    public func put(key: K, value: V): ?V {
        return addInternal(key, value)
    }

    @Frozen
    public func add(key: K, value: V): ?V {
        return addInternal(key, value)
    }

    /**
     * Associates the specified @p value with the specified @p key in this concurrent map,
     * if @p key does not in the concurrent map, before calling this method.
     * Otherwise, just returns the value that @p key maps to and does nothing.
     *
     * Such method is atomic (linearizable) in concurrency.
     *
     * @param key: the key to put.
     * @param value: the value to assign.
     *
     * @return:
     * - Some(v): if the pair of @p key and v exists before putting;
     * - None: if @p key does not exist in the concurrent map.
     */
    @Deprecated[message: "Use member function `public func addIfAbsent(key: K, value: V): ?V` instead."]
    public func putIfAbsent(key: K, value: V): ?V {
        addIfAbsent(key, value)
    }

    @Frozen
    public func addIfAbsent(key: K, value: V): ?V {
        let hash = key.hashCode()
        var curHT = head.load()
        tryResize(hash, curHT)
        var ret = None<V>
        var index = hash & (curHT.buckets.size - 1)

        if (let Some(v) <- curHT.getValue(hash, key)) {
            return Some(v)
        }

        while (true) {
            let (_, ready) = curHT.tryGetBucket(index)
            if (ready) {
                ret = curHT.buckets[index].copyAddIfAbsent(hash, key, value)
                curHT.lockG.unlock(index)
                break
            }
            curHT = head.load()
            index = hash & (curHT.buckets.size - 1)
        }

        countInc(ret, hash)
        return ret
    }

    /**
     * Removes the key-value pair corresponding to @p key from this mapping, if one exists.
     *
     * @param key: pass in the key to be deleted.
     *
     * @return:
     * - Some(v): where the pair of @p key and v is the removed element;
     * - None: where @p key does not exist in the concurrent map.
     */
    public func remove(key: K): ?V {
        return removeInternal(key, {_ => true})
    }

    /**
     * Removes the pair of @p key and value, where predicate(value) = true holds,
     * from this concurrent map.
     * Otherwise, just returns 'false' and does nothing.
     *
     * @param key: the key of the key-value pair to be deleted.
     * @param predicate: the function justifies whether the pair of @p key and value should be removed.
     *
     * @return:
     * - Some(v): if exists the pair of @p key and v in concurrent map;
     * - None: if @p key does not in this concurrent map.
     */
    @Deprecated[message: "Use member function `public func entryView(K, (MapEntryView<K, V>) -> Unit)` instead."]
    public func remove(key: K, predicate: (V) -> Bool): ?V {
        return removeInternal(key, predicate)
    }

    /**
     * Replaces the value associated with @p key to @p value,
     * if there exists a pair of @p key and some value v in the concurrent hashmap.
     * Otherwise, just returns 'Option<V>.None' and does nothing.
     *
     * @param key: the key of the key-value pair, whose value needs to be replaced.
     * @param value: the value to be replaced.
     *
     * @return:
     * - Some(v): if the pair of @p key and v exists in concurrent map before invoking this method.
     * - None: if @p key is not in the concurrent map.
     */
    @Frozen
    public func replace(key: K, value: V): ?V {
        return replaceInternel(key, {_ => true}, {_ => value})
    }

    /**
     * Replaces the value associated with @p key to eval(v),
     * if there exists a pair of @p key and v in the concurrent hashmap.
     * Otherwise, just returns 'Option<V>.None' and does nothing.
     *
     * Such method is atomic (linearizable) in concurrency.
     *
     * @param key: the key to put.
     * @param eval: function to evaluate the value to put.
     * @p eval evaluates the value according to the old value v.
     *
     * @return:
     * - Some(v): if the pair of @p key and v exists in concurrent map before invoking this method.
     * - None: if @p key is not in the concurrent map.
     */
    @Deprecated[message: "Use member function `public func entryView(key: K, fn: (MapEntryView<K, V>)->Unit): ?V` instead."]
    public func replace(key: K, eval: (V) -> V): ?V {
        return replaceInternel(key, {_ => true}, eval)
    }

    /**
     * Replaces the value associated with @p key to eval(v),
     * if the pair of @p key and v in the concurrent map, and @p predicate(v) holds.
     *
     * Such method is atomic (linearizable) in concurrency.
     *
     * @param key: the key of the key-value pair, whose value needs to be replaced.
     * @param predicate: the function justifies whether @p key-v pair in the concurrent map should be replaced.
     * @param eval: the function evaluates the new value to replace the old value.
     *
     * @return:
     * - Some(v): if the pair of @p key and v exists in concurrent map before replacing;
     * - None: if @p key does not exist in concurrent map.
     */
    @Deprecated[message: "Use member function `public func entryView(key: K, fn: (MapEntryView<K, V>)->Unit): ?V` instead."]
    public func replace(key: K, predicate: (V) -> Bool, eval: (V) -> V): ?V {
        return replaceInternel(key, predicate, eval)
    }

    public func entryView(key: K, fn: (MapEntryView<K, V>) -> Unit): ?V {
        return entryViewInternal(key, fn)
    }

    /**
     * An exception is reported when the get operator is overloaded and the key does not exist.
     *
     * @param key: transfers the value for judgment.
     * @return: the value corresponding to the key.
     *
     * @throws NoneValueException if @p key does not exist.
     */
    public operator func [](key: K): V {
        return match (this.get(key)) {
            case None => throw NoneValueException("Value does not exist!\n")
            case Some(val) => val
        }
    }

    /**
     * The operator overloads the set. If the key does not exist, an exception is reported.
     *
     * @param key: transfers the value for judgment.
     * @param value: transfers the value to be set.
     */
    public operator func [](key: K, value!: V): Unit {
        this.add(key, value)
    }

    /**
     * Returns sizes of key-value.
     *
     * @return: size of key-value.
     */
    public prop size: Int64 {
        get() {
            var cnt: Int64 = 0
            for (i in 0..(1 << COUNT_SIZE)) {
                cnt += counts[i].load()
            }
            return cnt
        }
    }

    /**
     * Check whether the size is empty. If yes, true is returned. Otherwise, false is returned.
     *
     * @return: if yes, true is returned. Otherwise, false is returned.
     */
    public func isEmpty(): Bool {
        return (size == 0)
    }

    /**
     * Returns iterator of Concurrent Hashmap.
     *
     * @return: iterator of Concurrent Hashmap.
     */
    @Frozen
    public func iterator(): ConcurrentHashMapIterator<K, V> {
        return ConcurrentHashMapIterator<K, V>(this)
    }

    /************************ Private Methods *******************************/
    @OverflowWrapping
    private func addInternal(key: K, value: V): ?V {
        let hash = key.hashCode()
        var curHT = head.load()
        tryResize(hash, curHT)
        var ret = None<V>
        var index = hash & (curHT.buckets.size - 1)
        while (true) {
            let (entries, ready) = curHT.tryGetBucket(index)
            if (ready) {
                ret = curHT.buckets[index].copyPutWith(hash, key, value, entries)
                curHT.lockG.unlock(index)
                break
            }
            curHT = head.load()
            index = hash & (curHT.buckets.size - 1)
        }
        countInc(ret, hash)
        return ret
    }

    @OverflowWrapping
    private func replaceInternel(key: K, predicate: (V) -> Bool, eval: (V) -> V): ?V {
        let hash = key.hashCode()
        var ret = None<V>
        var curHT = head.load()
        var index = hash & (curHT.buckets.size - 1)
        while (true) {
            let (_, ready) = curHT.tryGetBucket(index)
            if (ready) {
                ret = curHT.buckets[index].copyReplace(hash, key, predicate, eval)
                curHT.lockG.unlock(index)
                break
            }
            curHT = head.load()
            index = hash & (curHT.buckets.size - 1)
        }
        return ret
    }

    @OverflowWrapping
    private func removeInternal(key: K, predicate: (V) -> Bool): Option<V> {
        let hash = key.hashCode()
        var ret = None<V>
        var curHT = head.load()
        var index = hash & (curHT.buckets.size - 1)
        while (true) {
            let (entries, ready) = curHT.tryGetBucket(index)
            if (ready) {
                // dropping an emptied bucket to None is only safe when the table has
                // no previous table to fall back to (see copyRemoveWith)
                let allowDrop = curHT.pre.load().isNone()
                ret = curHT.buckets[index].copyRemoveWith(hash, key, predicate, entries, allowDrop)
                curHT.lockG.unlock(index)
                break
            }
            curHT = head.load()
            index = hash & (curHT.buckets.size - 1)
        }
        if (ret.isSome()) {
            counts[hash & (counts.size - 1)].fetchSub(1)
        }
        return ret
    }

    func entryViewInternal(key: K, fn: (MapEntryView<K, V>) -> Unit): ?V {
        let hash = key.hashCode()
        var curHT = head.load()
        tryResize(hash, curHT) // maybe add
        var ret = None<V>
        var resize = None<Int64>
        var index = hash & (curHT.buckets.size - 1)

        while (true) {
            let (_, ready) = curHT.tryGetBucket(index)
            if (ready) {
                (ret, resize) = curHT.buckets[index].copyEntryView(hash, key, fn)
                curHT.lockG.unlock(index)
                break
            }
            curHT = head.load()
            index = hash & (curHT.buckets.size - 1)
        }

        if (let Some(v) <- resize) {
            counts[hash & (counts.size - 1)].fetchAdd(v)
        }
        return ret
    }

    @OverflowWrapping
    private func tryResize(hash: Int64, curHT: HNode<K, V>): Unit {
        let sz = curHT.buckets.size
        if ((counts[hash & (counts.size - 1)].load() << COUNT_SIZE) < sz) {
            return
        }
        /* Migrate all elements in previous hashtable, before resizing */
        var i = curHT.migratingIndex.fetchAdd(1)
        var migrateCnt = 0
        while (i < concurrencyLevel) {
            curHT.migrate(i, sz, concurrencyLevel)
            migrateCnt++
            i = curHT.migratingIndex.fetchAdd(1)
        }
        curHT.migratedIndex.fetchAdd(migrateCnt)
        let newVersion = curHT.version + 1
        if (!curHNodeVersion.compareAndSwap(curHT.version, newVersion)) {
            return // There exists a thread allocating new hashtable, returns
        }
        while (curHT.migratedIndex.load() < concurrencyLevel) {}
        /* Allocate new hashtable */
        curHT.pre.store(None<HNode<K, V>>)
        head.store(HNode<K, V>(sz << 1, Some(curHT), lockG[newVersion & 1], newVersion))
    }

    /*
     * Returns a power of two size for the given target capacity.
     *
     * @return target capacity.
     *
     * @since 0.18.4
     */
    private static func tableSizeFor(cap: Int64): Int64 {
        if (cap <= DEFAULT_CAPACITY) {
            return DEFAULT_CAPACITY
        }
        if (cap < MAX_SIZE) {
            var n: Int64 = cap - 1
            n |= n >> 1
            n |= n >> 2
            n |= n >> 4
            n |= n >> 8
            n |= n >> 16
            n |= n >> 32
            return n + 1
        } else {
            return MAX_SIZE
        }
    }

    private func countInc(ret: ?V, hash: Int64): Unit {
        if (ret.isNone()) {
            counts[hash & (counts.size - 1)].fetchAdd(1);
        }
    }
}

/**
 * The Iterator of the ConcurrentHashMap.
 * It is not atomic and does not ensure to iterator a snapshot of the ConcurrentHashMap in concurrency.
 * The best way to iterate the ConcurrentHashMap is in the condition, where there is no other threads executing concurrently.
 */
public class ConcurrentHashMapIterator<K, V> <: Iterator<(K, V)> where K <: Hashable & Equatable<K> {
    /* The reference of the current hash table */
    private let curHT: HNode<K, V>

    /* The index of buckets array in the current iteration */
    private var curBucketIndex: Int64 = 0

    /* The reference of the bucket in the current iteration */
    // private var curEntries: Option<ArrayList<KeyValue<K, V>>> = None
    private var curEntries: ?KVList<K, V> = None

    /* The index of the arraylist in the 'curEntries' in the current iteration */
    private var entriesIndex: Int64 = 0

    public init(cmap: ConcurrentHashMap<K, V>) {
        curHT = cmap.head.load()
        latestValidBucket(0) // Sets the cursor to the next element
    }

    /**
     * Returns the current element, and sets pointer to the next element.
     * - Some(val): if the current element is val;
     * - None: if there is no element in the collection.
     */
    @Frozen
    public func next(): Option<(K, V)> {
        if (let Some(entries) <- curEntries) {
            let val = entries[entriesIndex] // Gets the current element
            nextElement() // Sets the cursor to the next element
            return Some((val[1], val[2]))
        }
        return None<(K, V)>
    }

    private func nextElement() {
        if (let Some(entries) <- curEntries) {
            for (i in (entriesIndex + 1)..entries.size) {
                if (predicate(entries[i][0], curBucketIndex)) {
                    entriesIndex = i
                    return
                }
            }
        }

        let start = curBucketIndex + 1
        latestValidBucket(start)
    }

    private func latestValidBucket(start: Int64) {
        for (i in start..curHT.buckets.size) {
            let optEntries = curHT.buckets[i].refList()
            if (let Some(entries) <- optEntries) {
                if (validBucket(i, entries)) {
                    return
                }
            } else if (let Some(preHT) <- curHT.pre.load()) {
                let preIndex = i & (preHT.buckets.size - 1)
                if (let Some(preEntries) <- preHT.buckets[preIndex].refList()) {
                    if (validBucket(i, preEntries)) {
                        return
                    }
                }
            }
        }
        curBucketIndex = curHT.buckets.size
        curEntries = None
    }

    private func validBucket(index: Int64, entries: KVList<K, V>): Bool {
        for (i in 0..entries.size) {
            if (predicate(entries[i][0], index)) {
                curBucketIndex = index
                curEntries = entries
                entriesIndex = i
                return true
            }
        }
        return false
    }

    @OverflowWrapping
    private func predicate(hash: Int64, index: Int64): Bool {
        return ((hash & (curHT.buckets.size - 1)) == index)
    }
}
