// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.

#ifndef MRT_HEAP_VERIFIER_H
#define MRT_HEAP_VERIFIER_H

#include <cstddef>
#include <cstdint>

namespace MapleRuntime {

class Mutator;

// Stack root provenance borrowed during one mutator-root callback.
// Non-stackmap roots carry only the mutator, with Location::NONE. No history.
struct VerifyStackRootContext {
    enum class Location { NONE, STACK_SLOT, REGISTER };

    const Mutator* mutator = nullptr;
    uintptr_t pc = 0;
    uintptr_t frame = 0;
    Location location = Location::NONE;
    int32_t slotOffset = 0;
    uint32_t reg = 0;

    void ClearFrame()
    {
        pc = frame = 0;
        location = Location::NONE;
    }
};

class HeapVerifier {
public:
    enum class Checkpoint { PRE_GC, POST_GC };

    // cjEnableHeapVerify: 0 disables, 1 checks before GC, 2 checks after GC,
    // 3 checks before and after GC. The default path does not scan the heap.
    static void Init();
    static bool IsEnabled();

    // Internal GC checkpoints, called while the collector owns ScopedSTWLock.
    // Verify allocated layouts and references reachable from roots, including
    // stack objects. Reuse an active STW or stop the world before scanning.
    // gcCycle is the completed GC count + 1, stable through both checkpoints.
    static bool VerifyAt(Checkpoint checkpoint, size_t gcCycle);

private:
    enum class Mode : unsigned int { DISABLED = 0, PRE_GC = 1, POST_GC = 2, BOTH = 3 };
    static Mode ReadModeFromEnv();
    // Initialized during HeapImpl::Init before GC and Finalizer threads start;
    // the value is read-only for the remainder of the process lifetime.
    static Mode heapVerifyMode;
};

} // namespace MapleRuntime

#endif // MRT_HEAP_VERIFIER_H
