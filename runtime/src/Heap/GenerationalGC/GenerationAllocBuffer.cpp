// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#include "GenerationAllocBuffer.h"
#include "Allocator/MixedRegionSpace/MixedRegionSpace.h"
#include "Collector/Collector.h"
#include "Collector/FinalizerProcessor.h"
#include "Common/ScopedObjectAccess.h"
#include "Heap.h"
#include "Mutator/Mutator.h"

namespace MapleRuntime {
GenerationAllocBuffer* GenerationAllocBuffer::GetGenerationAllocBuffer()
{
    return static_cast<GenerationAllocBuffer*>(AllocBuffer::GetOrCreateAllocBuffer());
}

GenerationAllocBuffer::~GenerationAllocBuffer()
{
    MixedRegionSpace& space = MixedRegionSpace::CastDown(Heap::GetHeap().GetAllocator());
    MixedRegionManager& manager = MixedRegionSpace::CastDown(space.GetRegionManager());
    FlushSlotRegionCaches(manager);
    FlushGarbageRegionCache(manager);
}

void GenerationAllocBuffer::FlushSlotRegionCaches(MixedRegionManager& manager)
{
    RegionInfo* region = nullptr;
    while ((region = youngSlotRegionCache.TakeHeadRegionNoLock()) != nullptr) {
        region->ClearFreeSlotList();
        manager.RecycleYoungSlotRegion(region);
    }
    while ((region = oldSlotRegionCache.TakeHeadRegionNoLock()) != nullptr) {
        region->ClearFreeSlotList();
        manager.RecycleOldSlotRegion(region);
    }
}

void GenerationAllocBuffer::FlushGarbageRegionCache(MixedRegionManager& manager)
{
    RegionInfo* region = garbageRegionCache.TakeHeadRegionNoLock();
    while (region != nullptr) {
        manager.ReleaseRegion(region);
        region = garbageRegionCache.TakeHeadRegionNoLock();
    }
}

size_t GenerationAllocBuffer::CacheGarbageRegion(MixedRegionManager& manager, RegionInfo* region)
{
    const size_t regionSize = region->GetRegionSize();
    const size_t cacheLimit = IsGcThread() ? GC_GARBAGE_CACHE_LIMIT : MUTATOR_GARBAGE_CACHE_LIMIT;
    if (garbageRegionCache.GetAllocatedSize() >= cacheLimit) {
        return manager.ReleaseRegion(region);
    }
    RegionInfo::InitFreeRegion(region->GetUnitIdx(), region->GetUnitCount());
    garbageRegionCache.PrependRegionNoLock(region, RegionInfo::RegionType::FREE_REGION);
    return regionSize;
}

RegionInfo* GenerationAllocBuffer::TakeGarbageRegion(MixedRegionManager& manager, size_t totalSize)
{
    RegionInfo* best = nullptr;
    garbageRegionCache.VisitAllRegionsUntilSuccNoLock([totalSize, &best](RegionInfo* region) {
        if (region->GetRegionSize() >= totalSize &&
            (best == nullptr || region->GetRegionSize() < best->GetRegionSize())) {
            best = region;
        }
        return false;
    });
    if (best == nullptr) {
        return nullptr;
    }
    garbageRegionCache.RemoveRegionNoLock(best);
    const size_t unitCount = best->GetUnitCount();
    const size_t unitIndex = best->GetUnitIdx();
    RegionInfo::ClearUnits(unitIndex, unitCount);
    RegionInfo* region = RegionInfo::InitRegion(unitIndex, unitCount, RegionInfo::UnitRole::SMALL_SIZED_UNITS);
    GCPhase phase = Heap::GetHeap().GetGCPhase();
    if (phase == GCPhase::GC_PHASE_TRACE || phase == GCPhase::GC_PHASE_CLEAR_SATB_BUFFER ||
        phase == GCPhase::GC_PHASE_GENERATION_TRACE) {
        region->SetTraceRegionFlag(1);
    }
    manager.EnlistThreadLocalRegion(region);
    return region;
}

namespace {
// Black allocation: objects allocated from swept slot regions during GC trace/enumeration
// phases must be marked immediately, otherwise the concurrent sweep of the current cycle
// may reclaim them before any traced root references them (use-after-free).
// During generational post-trace, mark new slot objects so weak reads recognize them as live.
// NOTE: the object header (typeInfo) is not initialized yet at this point,
// so only the caller-known totalSize is used, never obj->GetSize().
// Uses the global GC phase: this path may also run on GC pool threads which have no Mutator.
void MarkAllocatedObject(MAddress addr, size_t objSize)
{
    GCPhase phase = Heap::GetHeap().GetGCPhase();
    if (LIKELY(phase != GCPhase::GC_PHASE_ENUM && phase != GCPhase::GC_PHASE_TRACE &&
               phase != GCPhase::GC_PHASE_GENERATION_ENUM && phase != GCPhase::GC_PHASE_GENERATION_TRACE &&
               phase != GCPhase::GC_PHASE_CLEAR_SATB_BUFFER &&
               phase != GCPhase::GC_PHASE_GENERATION_POST_TRACE)) {
        return;
    }
    auto* obj = reinterpret_cast<BaseObject*>(addr);
    RegionInfo* region = RegionInfo::GetRegionInfoAt(addr);
    region->MarkObject(obj, objSize);
}

MAddress AllocateFromSlotRegionCache(RegionList& cache, size_t totalSize)
{
    MAddress result = 0;
    cache.VisitAllRegionsUntilSuccNoLock([&result, totalSize](RegionInfo* region) {
        result = region->AllocateFromSlot(totalSize);
        if (result != 0) {
            MarkAllocatedObject(result, totalSize);
        }
        return result != 0;
    });
    return result;
}

RegionInfo* RemoveSmallestSlotRegion(RegionList& cache)
{
    RegionInfo* smallest = nullptr;
    size_t smallestSize = std::numeric_limits<size_t>::max();
    cache.VisitAllRegionsUntilSuccNoLock([&smallest, &smallestSize](RegionInfo* region) {
        size_t maxSlotSize = region->GetMaxSlotSize();
        if (smallest == nullptr || maxSlotSize < smallestSize) {
            smallest = region;
            smallestSize = maxSlotSize;
        }
        return false;
    });
    if (smallest != nullptr) {
        cache.RemoveRegionNoLock(smallest);
    }
    return smallest;
}
}

MAddress GenerationAllocBuffer::AllocateYoungOnNewRegion(MixedRegionManager &manager, size_t totalSize)
{
    // Get region from local cache.
    RegionInfo* r = TakeGarbageRegion(manager, totalSize);
    if (r == nullptr) {
        CJThreadPreemptOffCntAdd();
        r = manager.AllocateThreadLocalRegion();
        CJThreadPreemptOffCntSub();
    }
    // It means both local cache and global resource don't have enough regions.
    if (UNLIKELY(r == nullptr)) {
        return 0;
    }
    if (tlRegion == RegionInfo::NullRegion()) {
        tlRegion = r;
        return r->Alloc(totalSize);
    }
    // It means a compacted region is installed when allocating tl region.
    MAddress addr = tlRegion->Alloc(totalSize);
    if (addr != 0) {
        // The compacted region can be used, so we make the region allocated just now cached.
        manager.RemoveThreadLocalRegion(r);
        if (r->IsTraceRegion()) {
            r->SetTraceRegionFlag(0);
        }
        CacheGarbageRegion(manager, r);
        return addr;
    }
    // The compacted region's capacity is not enough.
    manager.RemoveThreadLocalRegion(tlRegion);
    manager.EnlistFullThreadLocalRegion(tlRegion);
    tlRegion = r;
    return r->Alloc(totalSize);
}

MAddress GenerationAllocBuffer::AllocateYoungOnSlot(MixedRegionManager &manager, size_t totalSize)
{
    if (MAddress result = AllocateFromSlotRegionCache(youngSlotRegionCache, totalSize)) {
        return result;
    }
    if (youngSlotRegionCache.GetRegionCount() > 0) {
        RegionInfo* region = RemoveSmallestSlotRegion(youngSlotRegionCache);
        if (region != nullptr) {
            DLOG(SWEEP, "re-compact sweepable region %p sweepable [%p, %p)", region, region->GetRegionStart(),
                region->GetRegionAllocPtr());
            region->ClearFreeSlotList();
            manager.RecycleYoungSlotRegion(region);
        }
    }
    RegionInfo* region = manager.GetSweptRegionList().TakeHeadRegion();
    if (region != nullptr) {
        CHECK(youngSlotRegionCache.GetRegionCount() < SLOT_REGION_CACHE_LIMIT);
        youngSlotRegionCache.PrependRegionNoLock(region, RegionInfo::RegionType::SWEEP_REGION);
        if (MAddress result = AllocateFromSlotRegionCache(youngSlotRegionCache, totalSize)) {
            return result;
        }
    }
    MAddress result = 0;
    manager.GetSweptRegionList().VisitAllRegions([&result, totalSize](RegionInfo* region) {
        if (result != 0) {
            return;
        }
        result = region->AllocateFromSlot(totalSize);
        if (result != 0) {
            MarkAllocatedObject(result, totalSize);
        }
    });
    return result;
}

MAddress GenerationAllocBuffer::AllocateYoung(size_t totalSize)
{
    MixedRegionSpace& theAllocator = MixedRegionSpace::CastDown(Heap::GetHeap().GetAllocator());
    MixedRegionManager& manager = MixedRegionSpace::CastDown(theAllocator.GetRegionManager());

    RegionInfo* tr = tlRegion;
    if (LIKELY(tr != RegionInfo::NullRegion())) {
        MAddress addr = tr->Alloc(totalSize);
        if (addr != 0) {
            return addr;
        }

        CHECK(tr->IsThreadLocalRegion());
        constexpr size_t minAvailableDivisor = 10;
        if (tr->GetAvailableSize() < (tr->GetRegionSize() / minAvailableDivisor)) {
            manager.RemoveThreadLocalRegion(tr);
            manager.EnlistFullThreadLocalRegion(tr);
            tlRegion = RegionInfo::NullRegion();
        }
    }

    // Take a new region when young space is empty, and Take slot when young space is heavy.
    if (manager.IsYoungSpaceHeavy()) {
        MAddress slot = AllocateYoungOnSlot(manager, totalSize);
        if (slot != 0) {
            return slot;
        }
    }
    return AllocateYoungOnNewRegion(manager, totalSize);
}

MAddress GenerationAllocBuffer::AllocateOld(size_t totalSize)
{
    MixedRegionSpace& theAllocator = MixedRegionSpace::CastDown(Heap::GetHeap().GetAllocator());
    MixedRegionManager& manager = MixedRegionSpace::CastDown(theAllocator.GetRegionManager());

    if (LIKELY(oldAllocRegion != RegionInfo::NullRegion())) {
        MAddress addr = oldAllocRegion->Alloc(totalSize);
        if (addr != 0) {
            return addr;
        }

        {
            manager.RemoveThreadLocalRegion(oldAllocRegion);
            manager.EnlistOldRegionList(oldAllocRegion);
            oldAllocRegion = RegionInfo::NullRegion();
        }
    }
    MAddress slot = AllocateOldOnSlot(manager, totalSize);
    if (slot != 0) { return slot; }
    return AllocateOldOnNewRegion(manager, totalSize);
}

MAddress GenerationAllocBuffer::AllocateOldOnSlot(MixedRegionManager &manager, size_t totalSize)
{
    if (MAddress result = AllocateFromSlotRegionCache(oldSlotRegionCache, totalSize)) {
        return result;
    }
    if (oldSlotRegionCache.GetRegionCount() > 0) {
        RegionInfo* region = RemoveSmallestSlotRegion(oldSlotRegionCache);
        if (region != nullptr) {
            region->ClearFreeSlotList();
            manager.RecycleOldSlotRegion(region);
        }
    }
    RegionInfo* region = manager.GetOldSweptRegionList().TakeHeadRegion();
    if (region != nullptr) {
        CHECK(oldSlotRegionCache.GetRegionCount() < SLOT_REGION_CACHE_LIMIT);
        oldSlotRegionCache.PrependRegionNoLock(region, RegionInfo::RegionType::SWEEP_REGION);
        if (MAddress result = AllocateFromSlotRegionCache(oldSlotRegionCache, totalSize)) {
            return result;
        }
    }
    MAddress result = 0;
    manager.GetOldSweptRegionList().VisitAllRegions([&totalSize, &result](RegionInfo* region) {
        if (result != 0) {
            return;
        }
        result = region->AllocateFromSlot(totalSize);
        if (result != 0) {
            MarkAllocatedObject(result, totalSize);
        }
    });
    return result;
}

MAddress GenerationAllocBuffer::AllocateOldOnNewRegion(MixedRegionManager &manager, size_t totalSize)
{
    RegionInfo* r = TakeGarbageRegion(manager, totalSize);
    if (r == nullptr) {
        CJThreadPreemptOffCntAdd();
        r = manager.AllocateThreadLocalRegion();
        CJThreadPreemptOffCntSub();
    }
    if (UNLIKELY(r == nullptr)) {
        DLOG(PROMOTE, "promote object failed");
        return 0;
    }
    r->SetOldRegionFlag(1);
    // Old region mustn't be allocated during tracing phase, so it shouldn't be tagged with tracing flag.
    CHECK(!r->IsTraceRegion());
    if (oldAllocRegion == RegionInfo::NullRegion()) {
        oldAllocRegion = r;
        return r->Alloc(totalSize);
    }
    MAddress addr = oldAllocRegion->Alloc(totalSize);
    if (addr != 0) {
        manager.RemoveThreadLocalRegion(r);
        CacheGarbageRegion(manager, r);
        return addr;
    }
    manager.RemoveThreadLocalRegion(oldAllocRegion);
    manager.EnlistOldRegionList(oldAllocRegion);
    oldAllocRegion = r;
    return r->Alloc(totalSize);
}

} // namespace MapleRuntime
