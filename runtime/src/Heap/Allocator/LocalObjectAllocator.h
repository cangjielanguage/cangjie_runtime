// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_LOCAL_OBJECT_ALLOCATOR_H
#define MRT_LOCAL_OBJECT_ALLOCATOR_H

#include <cstddef>
#include <functional>

#include "Common/BaseObject.h"
#include "Common/TypeDef.h"
#include "ObjectModel/RefField.h"

namespace MapleRuntime {
struct FrameAddress;
class Mutator;

// Metadata exposed to inspection/debugging clients while a local region is
// stopped-the-world.  The dump layer must not depend on a concrete allocator
// region type, so only stable ownership and layout information is exported.
struct LocalObjectInfo {
    Mutator* ownerMutator = nullptr;
    FrameAddress* ownerFrame = nullptr;
    MAddress regionBase = 0;
    size_t regionSize = 0;
    bool isLargeRegion = false;
    // Used only by VisitLocalRoots.  VisitLocalObjects leaves this at
    // LOCAL_OBJECT.  Keeping the root source kind in the allocator metadata
    // prevents the dump layer from confusing stack roots with registry roots.
    enum class RootKind : uint8_t {
        LOCAL_OBJECT,
        FINALIZER,
    } rootKind = RootKind::LOCAL_OBJECT;
    // Finalizer state is meaningful only when rootKind == FINALIZER.
    // Values are PENDING=0, RUNNING=1, DONE=2.
    uint8_t finalizerState = 0;
};

using LocalObjectVisitor = std::function<void(Mutator&, BaseObject*, const LocalObjectInfo&)>;

// Abstracts local object allocation from the backing storage.
// A local region is a lifetime boundary. A backend may allocate one or more
// non-contiguous backing blocks/arenas inside the same local region, and
// EndRegion must reclaim all allocations made since the matching StartRegion.
class LocalObjectAllocator {
public:
    static LocalObjectAllocator* InitLocalObjectAllocator();

    virtual ~LocalObjectAllocator() = default;

    // Starts a local allocation region for the mutator. The backend owns any
    // region metadata it stores in Mutator. Failure to create the region
    // metadata is fatal; this method never returns a failure status.
    virtual void StartRegion(Mutator& mutator, FrameAddress* ownerFA) = 0;

    // Ends the current local allocation region and releases all local objects
    // allocated in that region.
    virtual void EndRegion(Mutator& mutator, FrameAddress* ownerFA) = 0;

    // Ends all local allocation regions owned by a managed frame during exception unwind.
    virtual void EndRegionsForFrame(Mutator& mutator, FrameAddress* ownerFA) = 0;

    // Allocates an object payload block in the current local region. Returns 0 on
    // allocation failure.
    virtual MAddress Allocate(Mutator& mutator, size_t size) = 0;

    // Native-backed local objects are outside the tracing heap, so this is
    // always 0. It is not part of tracing-heap live bytes.
    virtual size_t GetHeapAllocatedBytes() const = 0;

    // Returns the memory accounted to active local regions across all mutators.
    // Native-backed regions report the full capacity of chunks that are no
    // longer allocation frontiers and the used [base, top) prefix of each
    // mutator's current chunk. This is the value reported by the memory info
    // API (getAllocatedLocalObjectSize) and is not part of getAllocatedHeapSize.
    virtual size_t GetAllocatedObjectBytes() const = 0;

    // Registers an object whose finalizer should run before the current local
    // region is reclaimed.
    virtual void AddFinalizer(Mutator& mutator, BaseObject* obj) = 0;

    // Finalizes and removes a registered object when the compiler determines
    // that its local live range has ended.
    virtual void RemoveFinalizer(Mutator& mutator, BaseObject* obj) = 0;

    // Registers one local-to-heap reference slot. The root visitor updates the
    // slot in place when its heap target moves.
    virtual void AddLocalRoot(Mutator& mutator, BaseObject* obj, RefField<false>* field) = 0;

    // Visits registered local-to-heap reference fields directly.
    virtual void VisitLocalObjectRefFields(Mutator& mutator, const RootVisitor& visitor) = 0;

    // Releases all per-mutator resources (regions, caches, metadata) when the
    // mutator is destroyed or reset. Regions still alive at this point (e.g.
    // abnormal thread exit) are reclaimed without running finalizers, because
    // running user code during teardown can re-enter the runtime.
    virtual void OnMutatorExit(Mutator& mutator) = 0;
    // Visits every object currently allocated in local regions.
    virtual void VisitLocalObjects(const LocalObjectVisitor& visitor) const
    {
        (void)visitor;
    }

    // Visits objects registered as local roots/finalizers.  This is separate
    // from VisitLocalObjects because the registry is not an object inventory.
    virtual void VisitLocalRoots(const LocalObjectVisitor& visitor) const
    {
        (void)visitor;
    }

    virtual bool HasLocalObjects() const { return false; }
};
} // namespace MapleRuntime

#endif // MRT_LOCAL_OBJECT_ALLOCATOR_H
