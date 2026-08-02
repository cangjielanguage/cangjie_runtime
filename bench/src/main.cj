/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package bench

import std.collection.concurrent.*
import std.collection.HashMap
import std.collection.MapEntryView
import std.random.Random
import std.sync.AtomicInt64
import std.sync.AtomicReference
import std.sync.AtomicOptionReference
import std.time.*

const N: Int64 = 1000000
const ROUNDS: Int64 = 7

/* Pseudo-random keys with a fixed seed: reproducible and, unlike identity keys,
 * hash to buckets with realistic collisions (Poisson at load factor 1). */
func genKeys(seed: UInt64): Array<Int64> {
    let rng = Random(seed)
    let keys = Array<Int64>(N, repeat: 0)
    for (i in 0..N) {
        keys[i] = rng.nextInt64()
    }
    return keys
}

let KEYS: Array<Int64> = genKeys(42)
let MISS_KEYS: Array<Int64> = genKeys(0x5EED)

func benchAdd(): Int64 {
    let map = ConcurrentHashMap<Int64, Int64>(N * 2)
    let start = MonoTime.now()
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchGet(): Int64 {
    let map = ConcurrentHashMap<Int64, Int64>(N * 2)
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    var sum: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let v = map.get(KEYS[i])
        if (let Some(x) <- v) {
            sum += x
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchGetMiss(): Int64 {
    let map = ConcurrentHashMap<Int64, Int64>(N * 2)
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    var found: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        if (map.get(MISS_KEYS[i]).isSome()) {
            found++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchRemove(): Int64 {
    let map = ConcurrentHashMap<Int64, Int64>(N * 2)
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    let start = MonoTime.now()
    for (i in 0..N) {
        map.remove(KEYS[i])
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchHashMapAdd(): Int64 {
    let map = HashMap<Int64, Int64>(N * 2)
    let start = MonoTime.now()
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchHashMapGet(): Int64 {
    let map = HashMap<Int64, Int64>(N * 2)
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    var sum: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let v = map.get(KEYS[i])
        if (let Some(x) <- v) {
            sum += x
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

// ---- micro probes for hot-spot location ----

func probeHashCode(): Int64 {
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        acc += i.hashCode()
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeAtomicLoad(): Int64 {
    let ref = AtomicInt64(0)
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        acc += ref.load()
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

// simulate KVList.find: linear scan over (hash, key, value) tuples in a small bucket
func probeTupleScan(): Int64 {
    let m = 8
    let arr = Array<(Int64, Int64, Int64)>(m, repeat: (0, 0, 0))
    for (i in 0..m) {
        arr[i] = (i, i, i)
    }
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let h = i & (m - 1)
        var j = 0
        var found = false
        while (j < m) {
            if (arr[j][0] == h) {
                acc += arr[j][2]
                found = true
                break
            }
            j++
        }
        if (!found) {
            acc++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

// same scan shape over plain Int64 arrays (parallel hashes/keys/values)
func probeScanParallelWhile(): Int64 {
    let m = 8
    let hashes = Array<Int64>(m, repeat: 0)
    let values = Array<Int64>(m, repeat: 0)
    for (i in 0..m) {
        hashes[i] = i
        values[i] = i
    }
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let h = i & (m - 1)
        var j = 0
        var found = false
        while (j < m) {
            if (hashes[j] == h) {
                acc += values[j]
                found = true
                break
            }
            j++
        }
        if (!found) {
            acc++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

// same scan shape over struct arrays
struct ScanEntry {
    let hash: Int64
    let key: Int64
    let value: Int64

    init(hash: Int64, key: Int64, value: Int64) {
        this.hash = hash
        this.key = key
        this.value = value
    }
}

func probeScanStructWhile(): Int64 {
    let m = 8
    let arr = Array<ScanEntry>(m, repeat: ScanEntry(0, 0, 0))
    for (i in 0..m) {
        arr[i] = ScanEntry(i, i, i)
    }
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let h = i & (m - 1)
        var j = 0
        var found = false
        while (j < m) {
            if (arr[j].hash == h) {
                acc += arr[j].value
                found = true
                break
            }
            j++
        }
        if (!found) {
            acc++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeOptionWrap(): Int64 {
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let o: ?Int64 = Some(i)
        if (let Some(x) <- o) {
            acc += x
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeGenericAtomicLoad(): Int64 {
    let obj = Object()
    let ref = AtomicReference<Object>(obj)
    let optRef = AtomicOptionReference<Object>(Some(obj))
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        ref.load()
        if (optRef.load().isSome()) {
            acc++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeFetchAdd(): Int64 {
    let ref = AtomicInt64(0)
    let start = MonoTime.now()
    for (i in 0..N) {
        ref.fetchAdd(1)
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeArrayWrite(): Int64 {
    let arr = Array<(Int64, Int64, Int64)>(8, repeat: (0, 0, 0))
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        arr[0] = (i, i, i)
        acc += arr[0][0]
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeArrayWriteGeneric(): Int64 {
    let obj = Object()
    let arr = Array<(Int64, Object, Object)>(8, repeat: (0, obj, obj))
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        arr[0] = (i, obj, obj)
        acc += arr[0][0]
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func probeClosureAlloc(): Int64 {
    var acc: Int64 = 0
    let start = MonoTime.now()
    for (i in 0..N) {
        let f = {x: Int64 => true}
        if (f(0)) {
            acc++
        }
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

/* Functional / compatibility self-test for the std ConcurrentHashMap. */
func stdMapTests(): Bool {
    // 1. empty map basics
    let m = ConcurrentHashMap<Int64, Int64>(16)
    if (m.size != 0 || !m.isEmpty()) { return false }
    if (m.get(1).isSome()) { return false }
    if (m.contains(1)) { return false }

    // 2. add / overwrite / get / contains / size
    if (m.add(1, 10).isSome()) { return false }
    if (let Some(v) <- m.add(1, 20)) {
        if (v != 10) { return false }
    } else { return false }
    if (let Some(v) <- m.get(1)) {
        if (v != 20) { return false }
    } else { return false }
    if (!m.contains(1)) { return false }
    if (m.size != 1) { return false }

    // 3. resize + remove-all: exercises migration, the pre-table fallback and
    //    must NOT return stale values for removed keys (regression for the
    //    "drop empty bucket" optimization)
    let r = ConcurrentHashMap<Int64, Int64>(16)
    for (i in 0..1000) {
        if (r.add(i, i).isSome()) { return false }
    }
    if (r.size != 1000) { return false }
    for (i in 0..1000) {
        if (let Some(v) <- r.get(i)) {
            if (v != i) { return false }
        } else { return false }
    }
    for (i in 0..1000) {
        if (let Some(v) <- r.remove(i)) {
            if (v != i) { return false }
        } else { return false }
    }
    if (r.size != 0) { return false }
    for (i in 0..1000) {
        if (r.get(i).isSome()) { return false }
    }

    // 4. addIfAbsent
    let a = ConcurrentHashMap<Int64, Int64>()
    if (a.addIfAbsent(1, 100).isSome()) { return false }
    if (let Some(v) <- a.addIfAbsent(1, 200)) {
        if (v != 100) { return false }
    } else { return false }
    if (a.size != 1) { return false }

    // 5. replace(key, value)
    let p = ConcurrentHashMap<Int64, Int64>()
    p.add(1, 5)
    if (let Some(v) <- p.replace(1, 6)) {
        if (v != 5) { return false }
    } else { return false }
    if (p.replace(2, 6).isSome()) { return false }
    if (let Some(v) <- p.get(1)) {
        if (v != 6) { return false }
    } else { return false }

    // 6. replace with predicate + eval
    p.replace(1, {v: Int64 => v > 3}, {v: Int64 => v + 1})
    if (let Some(v) <- p.get(1)) {
        if (v != 7) { return false }
    } else { return false }
    p.replace(1, {v: Int64 => v > 100}, {v: Int64 => v + 1}) // predicate false
    if (let Some(v) <- p.get(1)) {
        if (v != 7) { return false }
    } else { return false }

    // 7. remove with predicate (reject then accept)
    p.remove(1, {v: Int64 => v > 100}) // rejected
    if (!p.contains(1)) { return false }
    p.remove(1, {v: Int64 => v > 6}) // accepted
    if (p.contains(1)) { return false }

    // 8. entryView add / update / remove
    let e = ConcurrentHashMap<Int64, Int64>()
    e.entryView(7) {ev: MapEntryView<Int64, Int64> => ev.value = Some(70)}
    if (let Some(v) <- e.get(7)) {
        if (v != 70) { return false }
    } else { return false }
    e.entryView(7) {ev: MapEntryView<Int64, Int64> => ev.value = Some(71)}
    if (let Some(v) <- e.get(7)) {
        if (v != 71) { return false }
    } else { return false }
    e.entryView(7) {ev: MapEntryView<Int64, Int64> => ev.value = None}
    if (e.get(7).isSome()) { return false }

    // 9. iterator
    let it = ConcurrentHashMap<Int64, Int64>(16)
    for (i in 0..100) {
        it.add(i, i)
    }
    var cnt: Int64 = 0
    let iter = it.iterator()
    while (let Some(kv) <- iter.next()) {
        cnt++
        if (kv[1] != kv[0]) { return false }
    }
    if (cnt != 100) { return false }

    // 10. multi-threaded add: 2 threads x 50000 distinct keys, then verify
    let mt = ConcurrentHashMap<Int64, Int64>(100000)
    let futA = spawn { =>
        for (i in 0..50000) {
            mt.add(i, i)
        }
    }
    let futB = spawn { =>
        for (i in 50000..100000) {
            mt.add(i, i)
        }
    }
    futA.get()
    futB.get()
    if (mt.size != 100000) { return false }
    for (i in 0..100000 : 10000) {
        if (mt.get(i).isNone()) { return false }
    }

    return true
}

func median(times: Array<Int64>): Int64 {
    // insertion sort on a small array
    let sorted = times.clone()
    for (i in 1..sorted.size) {
        let key = sorted[i]
        var j = i - 1
        while (j >= 0 && sorted[j] > key) {
            sorted[j + 1] = sorted[j]
            j--
        }
        sorted[j + 1] = key
    }
    return sorted[sorted.size / 2]
}

func runCase(name: String, bench: () -> Int64): Unit {
    var times = Array<Int64>(ROUNDS, repeat: 0)
    for (r in 0..ROUNDS) {
        times[r] = bench()
    }
    let med = median(times)
    println("${name}: median=${med} ns, per-op=${med / N} ns/op")
}

main() {
    // functional / compatibility self-test first: both the std and the
    // optimized implementation must pass the identical checks
    let stdOk = stdMapTests()
    let replOk = replMapTests()
    println("std map functional tests: ${stdOk}")
    println("repl map functional tests: ${replOk}")
    if (!stdOk || !replOk) {
        println("FUNCTIONAL TESTS FAILED")
        return
    }

    // warmup
    benchAdd()
    benchGet()
    benchGetMiss()
    benchRemove()

    println("Cangjie ConcurrentHashMap<Int64, Int64> benchmark (N=${N})")
    runCase("add", benchAdd)
    runCase("get(hit)", benchGet)
    runCase("get(miss)", benchGetMiss)
    runCase("remove", benchRemove)

    println("")
    println("Control: std.collection.HashMap (non-concurrent)")
    runCase("hm.add", benchHashMapAdd)
    runCase("hm.get", benchHashMapGet)

    println("")
    println("Replica (bench.chm, copy of std source, pre-optimization)")
    runCase("repl.add", benchReplAdd)
    runCase("repl.get", benchReplGet)
    runCase("repl.getMiss", benchReplGetMiss)
    runCase("repl.remove", benchReplRemove)

    println("")
    println("Micro probes (per-op over N=${N})")
    runCase("probe.hashCode", probeHashCode)
    runCase("probe.atomicLoad", probeAtomicLoad)
    runCase("probe.tupleScan", probeTupleScan)
    runCase("probe.parallelScan", probeScanParallelWhile)
    runCase("probe.structScan", probeScanStructWhile)
    runCase("probe.optionWrap", probeOptionWrap)
    runCase("probe.genericAtomic", probeGenericAtomicLoad)
    runCase("probe.fetchAdd", probeFetchAdd)
    runCase("probe.arrayWrite", probeArrayWrite)
    runCase("probe.arrayWriteGeneric", probeArrayWriteGeneric)
    runCase("probe.closureAlloc", probeClosureAlloc)
}
