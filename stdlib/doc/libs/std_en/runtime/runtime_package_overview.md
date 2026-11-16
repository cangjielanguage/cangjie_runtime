# std.runtime

## Function Overview

The runtime package facilitates interaction with the program's runtime environment, providing a series of functions and variables for controlling, managing, and monitoring program execution.

The Cangjie language employs an automatic garbage collection mechanism for memory management. The runtime package offers functionalities such as manual garbage collection triggering, garbage collection threshold configuration, and memory statistics retrieval for garbage collection tuning and monitoring.

## API List

### Functions

| Function Name | Description |
| ------------- | ----------- |
| [dumpHeapData(Path)](./runtime_package_api/runtime_package_funcs.md#func-dumpheapdatapath) | Generates heap memory snapshot information and writes it to a file at the specified path. |
| [GC(Bool) <sup>(deprecated)</sup>](./runtime_package_api/runtime_package_funcs.md#func-gcbool-deprecated) | Executes garbage collection. |
| [gc(Bool)](./runtime_package_api/runtime_package_funcs.md#func-gcbool) | Executes garbage collection. |
| [getAllocatedHeapSize](./runtime_package_api/runtime_package_funcs.md#func-getallocatedheapsize) | Retrieves the allocated heap size in bytes for the Cangjie heap. |
| [getBlockingThreadCount](./runtime_package_api/runtime_package_funcs.md#func-getblockingthreadcount) | Gets the count of blocked Cangjie threads. |
| [getGCCount](./runtime_package_api/runtime_package_funcs.md#func-getgccount) | Retrieves the number of garbage collection triggers. |
| [getGCFreedSize](./runtime_package_api/runtime_package_funcs.md#func-getgcfreedsize) | Gets the amount of memory successfully reclaimed after garbage collection, in bytes. |
| [getGCTime](./runtime_package_api/runtime_package_funcs.md#func-getgctime) | Retrieves the total garbage collection duration in microseconds. |
| [getMaxHeapSize](./runtime_package_api/runtime_package_funcs.md#func-getmaxheapsize) | Gets the maximum available size of the Cangjie heap in bytes. |
| [getNativeThreadCount](./runtime_package_api/runtime_package_funcs.md#func-getnativethreadcount) | Retrieves the count of physical threads. |
| [getProcessorCount](./runtime_package_api/runtime_package_funcs.md#func-getprocessorcount) | Gets the number of processors. |
| [getThreadCount](./runtime_package_api/runtime_package_funcs.md#func-getthreadcount) | Retrieves the current count of Cangjie threads. |
| [getUsedHeapSize](./runtime_package_api/runtime_package_funcs.md#func-getusedheapsize) | On Linux platforms: gets the actual physical memory usage of the Cangjie heap in bytes. On Windows and macOS platforms: gets the actual physical memory usage of the Cangjie process in bytes. |
| [SetGCThreshold(UInt64) <sup>(deprecated)</sup>](./runtime_package_api/runtime_package_funcs.md#func-setgcthresholduint64-deprecated) | Modifies the user-defined memory threshold for garbage collection triggering (in KB). When the Cangjie heap size exceeds this value, garbage collection is triggered. |
| [setGCThreshold(UInt64)](./runtime_package_api/runtime_package_funcs.md#func-setgcthresholduint64) | Modifies the user-defined memory threshold for garbage collection triggering (in KB). When the Cangjie heap size exceeds this value, garbage collection is triggered. |
| [startCPUProfiling](./runtime_package_api/runtime_package_funcs.md#func-startcpuprofiling) | Initiates CPU profiler tracing. |
| [stopCPUProfiling(Path)](./runtime_package_api/runtime_package_funcs.md#func-stopcpuprofilingpath) | Stops CPU profiler tracing and writes the records to a file at the specified path. |

### Structures

| Structure Name | Description |
| ------------- | ----------- |
| [MemoryInfo <sup>(deprecated)</sup>](./runtime_package_api/runtime_package_structs.md#struct-memoryinfo-deprecated) | Provides interfaces for retrieving heap memory statistics. |
| [ProcessorInfo <sup>(deprecated)</sup>](./runtime_package_api/runtime_package_structs.md#struct-processorinfo-deprecated) | Provides interfaces for retrieving processor information. |
| [ThreadInfo <sup>(deprecated)</sup>](./runtime_package_api/runtime_package_structs.md#struct-threadinfo-deprecated) | Provides interfaces for retrieving Cangjie thread statistics. |