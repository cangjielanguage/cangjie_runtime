/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package bench

import bench.chm.ConcurrentHashMap
import std.collection.MapEntryView
import std.time.*

/* Functional / compatibility self-test for the optimized replica (bench.chm).
 * The body is identical to stdMapTests() in main.cj; both must pass. */
func replMapTests(): Bool {
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

func benchReplAdd(): Int64 {
    let map = ConcurrentHashMap<Int64, Int64>(N * 2)
    let start = MonoTime.now()
    for (i in 0..N) {
        map.add(KEYS[i], i)
    }
    let end = MonoTime.now()
    return (end - start).toNanoseconds()
}

func benchReplGet(): Int64 {
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

func benchReplGetMiss(): Int64 {
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

func benchReplRemove(): Int64 {
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
