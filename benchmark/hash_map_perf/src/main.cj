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
 * HashMap contains/remove 性能基准测试。
 * 用于验证 Issue #588（HashMap.remove/contains 相比 Java17 慢 450%）的性能优化效果。
 *
 * 运行方式：
 *   cd benchmark/hash_map_perf
 *   cjpm build && ./target/release/bin/main.exe
 */
package hash_map_perf
import std.collection.*
import std.time.*
import std.convert.*

/**
 * 执行 rounds 轮计时，返回最小耗时（毫秒），降低系统噪声影响。
 */
func bench(rounds: Int64, f: () -> Unit): Int64 {
    var best: Int64 = Int64.Max
    for (_ in 0..rounds) {
        let start = MonoTime.now()
        f()
        let end = MonoTime.now()
        let ms = Int64((end - start).toMilliseconds())
        if (ms < best) {
            best = ms
        }
    }
    return best
}

/**
 * HashMap.contains 命中查找基准（Int64 值类型 key）。
 */
func benchContains(size: Int64): Int64 {
    let m = HashMap<Int64, Int64>()
    for (i in 0..size) {
        m.add(i, i)
    }
    // 预热
    for (i in 0..size) {
        m.contains(i)
    }
    return bench(8, { => for (i in 0..size) {
        if (!m.contains(i)) {
            throw Exception("contains miss")
        }
    }})
}

/**
 * HashMap.contains 未命中查找基准（Int64 值类型 key）。
 */
func benchContainsMiss(size: Int64): Int64 {
    let m = HashMap<Int64, Int64>()
    for (i in 0..size) {
        m.add(i, i)
    }
    let startOffset: Int64 = 100_000_000
    // 预热
    for (i in 0..size) {
        m.contains(startOffset + i)
    }
    return bench(8, { => for (i in 0..size) {
        if (m.contains(startOffset + i)) {
            throw Exception("contains should miss")
        }
    }})
}

/**
 * HashMap.remove 删除全部 key 基准（Int64 值类型 key）。
 */
func benchRemove(size: Int64): Int64 {
    return bench(8, { =>
        let m = HashMap<Int64, Int64>()
        for (i in 0..size) {
            m.add(i, i)
        }
        for (i in 0..size) {
            if (!m.remove(i).isSome()) {
                throw Exception("remove miss")
            }
        }
    })
}

/**
 * HashMap.add 插入全部 key 基准（Int64 值类型 key，含扩容）。
 */
func benchAdd(size: Int64): Int64 {
    return bench(8, { =>
        let m = HashMap<Int64, Int64>()
        for (i in 0..size) {
            m.add(i, i)
        }
    })
}

/**
 * HashMap.contains 命中查找基准（String 引用类型 key）。
 */
func benchContainsString(size: Int64): Int64 {
    let m = HashMap<String, Int64>()
    for (i in 0..size) {
        m.add("key${i}", i)
    }
    let keys = Array<String>(size, repeat: "")
    for (i in 0..size) {
        keys[i] = "key${i}"
    }
    // 预热
    for (i in 0..size) {
        m.contains(keys[i])
    }
    return bench(4, { => for (i in 0..size) {
        if (!m.contains(keys[i])) {
            throw Exception("contains miss")
        }
    }})
}

/**
 * HashMap.remove 删除全部 key 基准（String 引用类型 key）。
 */
func benchRemoveString(size: Int64): Int64 {
    return bench(4, { =>
        let m = HashMap<String, Int64>()
        for (i in 0..size) {
            m.add("key${i}", i)
        }
        let keys = Array<String>(size, repeat: "")
        for (i in 0..size) {
            keys[i] = "key${i}"
        }
        for (i in 0..size) {
            if (!m.remove(keys[i]).isSome()) {
                throw Exception("remove miss")
            }
        }
    })
}

main() {
    let size: Int64 = 1_000_000
    println("== HashMap performance benchmark (size=${size}) ==")
    println("BENCH contains ${size} hits: ${benchContains(size)} ms")
    println("BENCH contains ${size} misses: ${benchContainsMiss(size)} ms")
    println("BENCH remove ${size}: ${benchRemove(size)} ms")
    println("BENCH add ${size}: ${benchAdd(size)} ms")
    println("BENCH containsStr ${size} hits: ${benchContainsString(size)} ms")
    println("BENCH removeStr ${size}: ${benchRemoveString(size)} ms")
}
