# Functions

## func dumpHeapData(Path)

```cangjie
public func dumpHeapData(path: Path): Unit
```

Function: Generates heap memory snapshot information and writes it to a file at the specified path.

Parameters:

- path: [Path](../../fs/fs_package_api/fs_package_structs.md/#struct-path) - The file path where the heap memory snapshot will be written.

Exceptions:

- MemoryInfoException - Thrown when heap memory snapshot generation fails.

## func GC(Bool) <sup>(deprecated)</sup>

```cangjie
public func GC(heavy!: Bool = false): Unit
```

Function: Executes [GC](runtime_package_funcs.md#func-gcbool-deprecated).

> **Note:**
>
> This will be deprecated in future versions. Use [gc](runtime_package_funcs.md#func-gcbool) instead.

Parameters:

- heavy!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The intensity of [GC](runtime_package_funcs.md#func-gcbool-deprecated) execution. If true, execution will be slower but more memory will be collected. Default value is false.

## func gc(Bool)

```cangjie
public func gc(heavy!: Bool = false): Unit
```

Function: Executes [gc](runtime_package_funcs.md#func-gcbool).

Parameters:

- heavy!: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The intensity of [gc](runtime_package_funcs.md#func-gcbool) execution. If true, execution will be slower but more memory will be collected. Default value is false.

## func getAllocatedHeapSize()

```cangjie
public func getAllocatedHeapSize(): Int64
```

Function: Gets the allocated heap size of Cangjie in bytes.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The allocated heap size of Cangjie in bytes.

<!--Del_sink-->
## func getAllocatedLocalObjectSize()

```cangjie
public func getAllocatedLocalObjectSize(): Int64
```

Function: Obtains the memory size accounted to active local regions, in bytes.

The memory usage of local objects is not counted in the result of [getAllocatedHeapSize](runtime_package_funcs.md#func-getallocatedheapsize).

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The memory size accounted to active local regions, in bytes.

Example:

<!-- verify -->
```cangjie
import std.runtime.*

main(): Unit {
    // The return value accounts each active backing chunk: the current allocation chunk counts
    // only its used prefix (the unused tail is excluded), while other chunks count at full
    // capacity; the value varies with allocation behavior and has no stable fixed value, so
    // only its non-negativity is verified here
    let size = getAllocatedLocalObjectSize()
    println("Local region size >= 0: ${size >= 0}")
}
```

Output:

```text
Local region size >= 0: true
```

<!--DelEnd_sink-->
## func getBlockingThreadCount()

```cangjie
public func getBlockingThreadCount(): Int64
```

Function: Gets the count of blocked Cangjie threads.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of blocked Cangjie threads.

## func getGCCount()

```cangjie
public func getGCCount(): Int64
```

Function: Gets the count of triggered GC operations.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of triggered GC operations.

## func getGCFreedSize()

```cangjie
public func getGCFreedSize(): Int64
```

Function: Gets the size of memory successfully reclaimed after GC in bytes.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of memory successfully reclaimed after GC in bytes.

## func getGCTime()

```cangjie
public func getGCTime(): Int64
```

Function: Gets the total time consumed by GC operations in microseconds.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The total time consumed by GC operations in microseconds.

## func getMaxHeapSize()

```cangjie
public func getMaxHeapSize(): Int64
```

Function: Gets the maximum available heap size for Cangjie in bytes.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The maximum available heap size for Cangjie in bytes.

## func getNativeThreadCount()

```cangjie
public func getNativeThreadCount(): Int64
```

Function: Gets the count of physical threads.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of physical threads.

## func getProcessorCount()

```cangjie
public func getProcessorCount(): Int64
```

Function: Gets the count of processors.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The count of processors.

## func getThreadCount()

```cangjie
public func getThreadCount(): Int64
```

Function: Gets the current count of Cangjie threads.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The current count of Cangjie threads.

## func getUsedHeapSize()

```cangjie
public func getUsedHeapSize(): Int64
```

Function: On Linux platforms, gets the actual physical memory size occupied by the Cangjie heap in bytes. On Windows and macOS platforms, gets the actual physical memory size occupied by the Cangjie process in bytes.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The actual physical memory size occupied by the Cangjie heap or process in bytes.

## func SetGCThreshold(UInt64) <sup>(deprecated)</sup>

```cangjie
public func SetGCThreshold(value: UInt64): Unit
```

Function: Modifies the memory threshold (in KB) for triggering [GC](runtime_package_funcs.md#func-gcbool-deprecated). When the Cangjie heap size exceeds this value, [GC](runtime_package_funcs.md#func-gcbool-deprecated) will be triggered.

> **Note:**
>
> This will be deprecated in future versions. Use [setGCThreshold(UInt64)](./runtime_package_funcs.md#func-setgcthresholduint64) instead.

Parameters:

- value: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The memory threshold for triggering [GC](runtime_package_funcs.md#func-gcbool-deprecated).

Example:
Set the desired GC memory threshold to 2MB.

```cangjie
import std.runtime.*
main() {
  SetGCThreshold(2048)
}
```

## func setGCThreshold(UInt64)

```cangjie
public func setGCThreshold(value: UInt64): Unit
```

Function: Modifies the memory threshold (in KB) for triggering [gc](runtime_package_funcs.md#func-gcbool). When the Cangjie heap size exceeds this value, [gc](runtime_package_funcs.md#func-gcbool) will be triggered.

Parameters:

- value: [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) - The memory threshold for triggering [gc](runtime_package_funcs.md#func-gcbool).

Example:
Set the desired gc memory threshold to 2MB.

```cangjie
import std.runtime.*
main() {
  setGCThreshold(2048)
}
```

## func startCPUProfiling()

```cangjie
public func startCPUProfiling(): Unit
```

Function: Starts CPU profiler tracing.

> **Note:**
>
> [startCPUProfiling](./runtime_package_funcs.md/#func-startcpuprofiling) and [stopCPUProfiling(Path)](./runtime_package_funcs.md#func-stopcpuprofilingpath) must be called in pairs.

Exceptions:

- ProfilingInfoException - Thrown if [startCPUProfiling](./runtime_package_funcs.md/#func-startcpuprofiling) is called again without first calling [stopCPUProfiling(Path)](./runtime_package_funcs.md#func-stopcpuprofilingpath).

## func stopCPUProfiling(Path)

```cangjie
public func stopCPUProfiling(path: Path): Unit
```

Function: Stops CPU profiler tracing and writes the records to a file at the specified path.

> **Note:**
>
> [startCPUProfiling](./runtime_package_funcs.md/#func-startcpuprofiling) and [stopCPUProfiling(Path)](./runtime_package_funcs.md#func-stopcpuprofilingpath) must be called in pairs.

Parameters:

- path: [Path](../../fs/fs_package_api/fs_package_structs.md/#struct-path) - The file path where the profiling records will be written.

Exceptions:

- ProfilingInfoException - Thrown if [stopCPUProfiling(Path)](./runtime_package_funcs.md#func-stopcpuprofilingpath) is called without first calling [startCPUProfiling](./runtime_package_funcs.md/#func-startcpuprofiling).