# ConcurrentHashMap 性能基准与优化验证

针对 Issue #2645（ConcurrentHashMap 的 `add()`/`get()`/`remove()` 性能问题）的性能基准工程，
同时用于验证 `stdlib/libs/std/collection/concurrent/concurrent_hash_map.cj` 中的优化。

## 内容

- `src/main.cj`：基准主程序。测量 `std.collection.concurrent.ConcurrentHashMap`（安装 SDK 中的实现）的
  `add` / `get(hit)` / `get(miss)` / `remove` 性能，并输出同语言的对照组
  `std.collection.HashMap` 与各微基准探针；启动时先运行功能/兼容自测。
- `src/chm_bench.cj`：对优化实现（`bench.chm` 包）的相同基准与功能自测。
- `src/chm/concurrent_hash_map.cj`：**优化后的实现源码副本**（包名 `bench.chm`，
  与合入到标准库的改动一致），用于与 SDK 预编译的未优化实现做同进程对比。
- `Bench.java`：Java 参照基准（JDK `java.util.concurrent.ConcurrentHashMap`），
  使用与 Cangjie 侧相同的种子生成同一组随机键。

## 运行方式

### Cangjie 侧

需要本机安装仓颉 SDK（`cjc`/`cjpm`），并配置好 `CANGJIE_HOME` 与 `PATH`（参考 SDK 的 `envsetup`）。

```shell
cjpm build
./target/release/bin/main.exe     # Windows
# 或 Linux/macOS: ./target/release/bin/main
```

输出示例（N=1000000，7 轮取中位数）：

```
std map functional tests: true
repl map functional tests: true
Cangjie ConcurrentHashMap<Int64, Int64> benchmark (N=1000000)
add:      median=... ns, per-op=... ns/op   # std（SDK 预编译，未优化）
get(hit): median=... ns, per-op=... ns/op
...
Replica (bench.chm, 优化实现)
repl.add:      median=... ns, per-op=... ns/op
repl.get:      median=... ns, per-op=... ns/op
...
```

`add/get/getMiss/remove`（std）与 `repl.add/repl.get/repl.getMiss/repl.remove`（优化实现）
为同一进程内的同配置对比，可直接计算优化前后的提升比例。

> 说明：`cjpm.toml` 中 `compile-option = "-O2"` 是保证对比公平的关键——
> 默认 `-O0` 会让调用方代码产生约 10 倍的额外开销，掩盖真实差距。

### Java 侧

```shell
javac Bench.java
java Bench
```

### 多线程正确性

`main()` 启动时执行的 `stdMapTests()` / `replMapTests()` 包含多线程并发 `add`（2 线程 × 5 万键）与
扩容/迁移、谓词删除、`entryView`、迭代器等用例，两个实现必须全部通过。

## 实测结果（Windows x86_64，JDK 21，仓颉 SDK 1.1.3，N=1000000，随机键，capacity=2N）

| 操作 | std（未优化） | 优化实现 | 提升 |
|---|---|---|---|
| add | ~920 ns/op | ~880 ns/op | ~4% |
| get(hit) | ~310 ns/op | ~228 ns/op | **~26%** |
| get(miss) | ~290 ns/op | ~202 ns/op | **~31%** |
| remove | ~2090 ns/op | ~1650 ns/op | **~21%** |

> 另注：Issue 中"比 Java 慢 20 多倍"的结论在 `-O0` 编译下成立（且被放大）；
> 在 `-O2` 下差距约为 7~30 倍，其中读路径的差距主要来自并发原语与调用链开销。
