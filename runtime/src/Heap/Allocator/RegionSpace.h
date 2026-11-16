// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_REGION_SPACE_H
#define MRT_REGION_SPACE_H

#include <cassert>
#include <list>
#include <map>
#include <set>
#include <thread>
#include <vector>

#include "AllocUtil.h"
#include "Allocator.h"
#include "ExceptionManager.h"
#include "LocalObjectAllocator.h"
#include "Mutator/Mutator.h"
#include "RegionManager.h"
#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

namespace MapleRuntime {
// RegionSpace aims to be the API for other components of runtime
// the complication of implementation is delegated to RegionManager
// allocator should not depend on any assumptions on the details of RegionManager
class RegionSpace : public Allocator {
public:
    static size_t ToAllocSize(size_t objSize)
    {
        size_t size = objSize + HEADER_SIZE;
        return RoundUp<size_t>(size, ALLOC_ALIGN);
    }

    static size_t GetAllocSize(const BaseObject& obj)
    {
        size_t objSize = obj.GetSize();
        return ToAllocSize(objSize);
    }

    static RegionManager* CreateRegionManager()
    {
        RegionManager* regionMgr = new (std::nothrow) RegionManager();
        CHECK_DETAIL(regionMgr != nullptr, "CANGJIE RUNTIME create region manager failed");
        return regionMgr;
    }
    static void DestroyRegionManager(RegionManager* regionMgr)
    {
        CHECK_DETAIL(regionMgr != nullptr, "CANGJIE RUNTIME destroy a null region manager");
        delete regionMgr;
    }
    RegionSpace() : regionManager(*CreateRegionManager()) {}
    explicit RegionSpace(RegionManager* manager)
        : regionManager(manager != nullptr ? *manager : *CreateRegionManager()) {}
    ATTR_NO_INLINE ~RegionSpace() override
    {
        if (localObjectAllocator != nullptr) {
            delete localObjectAllocator;
            localObjectAllocator = nullptr;
        }
        if (allocBufferManager != nullptr) {
            delete allocBufferManager;
            allocBufferManager = nullptr;
        }
#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
        Sanitizer::OnHeapDeallocated(map->GetBaseAddr(), map->GetMappedSize());
#endif
        MemMap::DestroyMemMap(map);
        DestroyRegionManager(&regionManager);
    }

    void Init(const HeapParam&) override;

    MAddress Allocate(size_t size, AllocType allocType) override;

    RegionManager& GetRegionManager() const noexcept { return regionManager; }

    LocalObjectAllocator& GetLocalObjectAllocator() noexcept
    {
        CHECK_DETAIL(localObjectAllocator != nullptr, "local object allocator is not initialized");
        return *localObjectAllocator;
    }

    MAddress GetSpaceStartAddress() const override { return reservedStart; }

    MAddress GetSpaceEndAddress() const override { return reservedEnd; }

    size_t GetCurrentCapacity() const override { return GetRegionManager().GetInactiveZone() - reservedStart; }
    size_t GetMaxCapacity() const override { return reservedEnd - reservedStart; }

    inline size_t GetRecentAllocatedSize() const { return GetRegionManager().GetRecentAllocatedSize(); }

    // size of objects survived in previous gc.
    inline size_t GetSurvivedSize() const { return GetRegionManager().GetSurvivedSize(); }

    size_t GetUsedPageSize() const override { return GetRegionManager().GetUsedRegionSize(); }

    inline size_t GetTargetSize() const
    {
        double heapUtilization = CangjieRuntime::GetHeapParam().heapUtilization;
        return static_cast<size_t>(GetUsedPageSize() / heapUtilization);
    }

    size_t AllocatedBytes() const override { return GetRegionManager().GetAllocatedSize(); }

    size_t LargeObjectBytes() const override { return GetRegionManager().GetLargeObjectSize(); }

    size_t FromSpaceSize() const { return GetRegionManager().GetFromSpaceSize(); }

    size_t PinnedSpaceSize() const { return GetRegionManager().GetPinnedSpaceSize(); }

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    bool IsHeapObject(MAddress addr) const override;
#endif

    // info dump
    void GetInstances(const TypeInfo*, bool, size_t, std::vector<MObject*>&) const {}
    void ClassInstanceNum(std::map<CString, long>&) const {}

    size_t ReclaimGarbageMemory(bool releaseAll) override
    {
        size_t dirtyHeapBefore = GetRegionManager().GetDirtyUnitCount() * RegionInfo::UNIT_SIZE;
        {
            MRT_PHASE_TIMER("ReclaimGarbageRegions");
            GetRegionManager().ReclaimGarbageRegions();
        }

        MRT_PHASE_TIMER("ReleaseGarbageMemory");
        if (releaseAll) {
            return GetRegionManager().ReleaseGarbageRegions(0);
        } else {
            size_t dirtyHeapAfter = GetRegionManager().GetDirtyUnitCount() * RegionInfo::UNIT_SIZE;
            // estimation of additional heap memory that was used since last GC
            size_t dirtyHeapUsed = dirtyHeapAfter > dirtyHeapBefore ? dirtyHeapAfter - dirtyHeapBefore : 0;
            
            size_t sizeAfter = GetRegionManager().GetAllocatedSize();
            double cachedRatio = 1.0 / CangjieRuntime::GetHeapParam().heapUtilization - 1.0;

            // Release memory to OS only when it was not used since previous GC and is over heapUtilization threshold.
            // It is important for avoiding the case where before GC we request more memory from OS
            // then GC happens and releases memory, and then we need to request same memory from OS again.
            size_t targetCachedSize =
                std::max(dirtyHeapUsed, static_cast<size_t>(sizeAfter * cachedRatio));
            return GetRegionManager().ReleaseGarbageRegions(targetCachedSize);
        }
    }
#if defined(__EULER__)
    void TryReclaimGarbageMemory() override
    {
        double cachedRatio = GetRegionManager().GetCacheRatio();
        if (cachedRatio == 1.0) { // 1.0 is the default value
            return;
        }
        {
            MRT_PHASE_TIMER("TryReclaimGarbageRegions");
            GetRegionManager().ReclaimGarbageRegions();
        }
        MRT_PHASE_TIMER("TryReleaseGarbageMemory");
        size_t size = GetRegionManager().GetAllocatedSize();
        size_t targetCachedSize = static_cast<size_t>(size * cachedRatio);
        GetRegionManager().ReleaseGarbageRegions(targetCachedSize);
        return;
    }
#endif
    bool ForEachObj(const std::function<void(BaseObject*)>& visitor, bool safe) const override
    {
        if (UNLIKELY(safe)) {
            GetRegionManager().ForEachObjSafe(visitor);
        } else {
            GetRegionManager().ForEachObjUnsafe(visitor);
        }
        return true;
    }

    // Return the garbage size of from space.
    size_t RefineFromSpace()
    {
        MRT_PHASE_TIMER("ExemptFromRegions");
        return GetRegionManager().ExemptFromRegions();
    }

    BaseObject* RouteObject(BaseObject* fromObj) { return GetRegionManager().RouteObject(fromObj); }

    void PrepareFromSpace(bool isFull) { GetRegionManager().PrepareFromRegionList(isFull); }

    void ClearAllLiveInfo() { GetRegionManager().ClearAllLiveInfo(); }

    virtual void ForwardFromSpace(GCThreadPool* threadPool)
    {
        MRT_PHASE_TIMER("ForwardFromRegions");
        GetRegionManager().ForwardFromSpace(threadPool);
    }

    virtual size_t CollectLargeGarbage() { return GetRegionManager().CollectLargeGarbage(); }

    size_t CollectPinnedGarbage() { return GetRegionManager().CollectPinnedGarbage(); }

    void CollectFromSpaceGarbage()
    {
        GetRegionManager().CollectFromSpaceGarbage();
        GetRegionManager().ReassembleFromSpace();
    }

    void AssembleGarbageCandidates(bool collectAll = false)
    {
        GetRegionManager().AssembleSmallGarbageCandidates();
        GetRegionManager().AssemblePinnedGarbageCandidates(collectAll);
        GetRegionManager().AssembleLargeGarbageCandidates();
    }

    void DumpRegionStats(const char* msg, bool dumpToError = false) const
    {
        GetRegionManager().DumpRegionStats(msg, dumpToError);
    }

    void CountLiveObject(const BaseObject* obj) { GetRegionManager().CountLiveObject(obj); }

    void PrepareTrace() { GetRegionManager().PrepareTrace(); }
    void FeedHungryBuffers() override;

    static bool MarkObject(const BaseObject* obj)
    {
        RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        return regionInfo->MarkObject(obj);
    }

    static bool IsMarkedObject(const BaseObject* obj)
    {
        RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        return regionInfo->IsMarkedObject(obj);
    }

    static bool ShouldEnqueue(const BaseObject* obj)
    {
        RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        if (regionInfo->IsTraceRegion()) {
            return false;
        }
        size_t offset = regionInfo->GetAddressOffset(reinterpret_cast<MAddress>(obj));
        if (regionInfo->IsMarkedObject(offset)) {
            return false;
        }
        return !regionInfo->EnqueueObject(obj, offset);
    }

    static bool IsResurrectedObject(const BaseObject* obj)
    {
        RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        return regionInfo->IsResurrectedObject(obj);
    }

    void AddRawPointerObject(BaseObject* obj) { GetRegionManager().AddRawPointerObject(obj); }

    void RemoveRawPointerObject(BaseObject* obj) { GetRegionManager().RemoveRawPointerObject(obj); }

    friend class Allocator;

protected:
    RegionManager& regionManager;
    virtual MAddress TryAllocateOnce(size_t allocSize, AllocType allocType);

private:
    enum class TryAllocationThreshold {
        RESCHEDULE = 3,
        TRIGGER_OOM = 5,
    };
    bool ShouldRetryAllocation(size_t& tryTimes, size_t size) const;
    MAddress reservedStart = 0;
    MAddress reservedEnd = 0;
    LocalObjectAllocator* localObjectAllocator = nullptr;
    MemMap* map{ nullptr };
};
} // namespace MapleRuntime
#endif // MRT_REGION_SPACE_H
