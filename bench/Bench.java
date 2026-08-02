/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

import java.util.concurrent.ConcurrentHashMap;
import java.util.Random;

public class Bench {
    static final int N = 1_000_000;
    static final int ROUNDS = 7;

    // Same reproducible pseudo-random keys as the Cangjie benchmark
    static long[] keys = genKeys(42);
    static long[] missKeys = genKeys(0x5EED);

    static long[] genKeys(long seed) {
        Random rng = new Random(seed);
        long[] ks = new long[N];
        for (int i = 0; i < N; i++) ks[i] = rng.nextLong();
        return ks;
    }

    static long benchAdd() {
        var map = new ConcurrentHashMap<Long, Long>(N * 2);
        long t0 = System.nanoTime();
        for (int i = 0; i < N; i++) map.put(keys[i], (long) i);
        return System.nanoTime() - t0;
    }

    static long benchGet() {
        var map = new ConcurrentHashMap<Long, Long>(N * 2);
        for (int i = 0; i < N; i++) map.put(keys[i], (long) i);
        long sum = 0;
        long t0 = System.nanoTime();
        for (int i = 0; i < N; i++) {
            Long v = map.get(keys[i]);
            if (v != null) sum += v;
        }
        return System.nanoTime() - t0;
    }

    static long benchGetMiss() {
        var map = new ConcurrentHashMap<Long, Long>(N * 2);
        for (int i = 0; i < N; i++) map.put(keys[i], (long) i);
        long found = 0;
        long t0 = System.nanoTime();
        for (int i = 0; i < N; i++) {
            if (map.get(missKeys[i]) != null) found++;
        }
        return System.nanoTime() - t0;
    }

    static long benchRemove() {
        var map = new ConcurrentHashMap<Long, Long>(N * 2);
        for (int i = 0; i < N; i++) map.put(keys[i], (long) i);
        long t0 = System.nanoTime();
        for (int i = 0; i < N; i++) map.remove(keys[i]);
        return System.nanoTime() - t0;
    }

    static long median(long[] times) {
        long[] s = times.clone();
        for (int i = 1; i < s.length; i++) {
            long key = s[i];
            int j = i - 1;
            while (j >= 0 && s[j] > key) { s[j + 1] = s[j]; j--; }
            s[j + 1] = key;
        }
        return s[s.length / 2];
    }

    interface BenchFn { long run(); }

    static void runCase(String name, BenchFn bench) {
        long[] times = new long[ROUNDS];
        for (int r = 0; r < ROUNDS; r++) times[r] = bench.run();
        long med = median(times);
        System.out.printf("%s: median=%d ns, per-op=%d ns/op%n", name, med, med / N);
    }

    public static void main(String[] args) {
        benchAdd(); benchGet(); benchGetMiss(); benchRemove(); // warmup

        System.out.println("Java ConcurrentHashMap<Long, Long> benchmark (N=" + N + ")");
        runCase("add", () -> benchAdd());
        runCase("get(hit)", () -> benchGet());
        runCase("get(miss)", () -> benchGetMiss());
        runCase("remove", () -> benchRemove());
    }
}
