// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_WCOLLECTOR_H
#define MRT_WCOLLECTOR_H
#include <unordered_map>

#include "Allocator/RegionSpace.h"
#include "Collector/CopyCollector.h"
#include "Heap/Heap.h"
namespace MapleRuntime {

class RegionForwardTable {
public:
    explicit RegionForwardTable(RegionSpace& space) : theSpace(space) {}

    // if object is not relocated (forwarded or compacted), return nullptr.
    BaseObject* RouteObject(BaseObject* old)
    {
        BaseObject* toAddress = theSpace.RouteObject(old);
        return toAddress;
    }

    // if region is compacted, return false.
    bool RouteRegion(RegionInfo* region) { return theSpace.GetRegionManager().RouteRegion(region); }

    void PrepareForwardTable(bool isFull = true)
    {
        DLOG(FORWARD, "reset fwd table");
        theSpace.PrepareFromSpace(isFull);

        ForwardDataManager::GetForwardDataManager().ClearPreviousForwardData();
    }

    RegionSpace& theSpace;
};

using CrossRefHandler = void(*)(BaseObject*, BaseObject*);

class WCollector : public CopyCollector {
public:
    explicit WCollector(Allocator& allocator, CollectorResources& resources)
        : CopyCollector(allocator, resources), fwdTable(reinterpret_cast<RegionSpace&>(allocator))
    {
        collectorType = CollectorType::SMOOTH_COLLECTOR;
    }

    ~WCollector() override = default;

    void Init() override { ForwardDataManager::GetForwardDataManager().InitializeForwardData(); }

    void MarkNewObject(BaseObject* obj) override;

    bool ShouldIgnoreRequest(GCRequest& request) override;
    bool MarkObject(BaseObject* obj) const override;
    bool ResurrectObject(BaseObject* obj, size_t offset, RegionInfo* regionInfo) override;

    void EnumRefFieldRoot(RefField<>& ref, RootSet& rootSet) const override;
    void TraceRefField(BaseObject* obj, RefField<>& ref, WorkStack& workStack) const;
    void TraceObjectRefFields(BaseObject* obj, WorkStack& workStack) override;
    BaseObject* GetAndTryTagObj(BaseObject* obj, RefField<>& field) override;
    BaseObject* ForwardObject(BaseObject* fromVersion) override;
    void PostResolveCycleTask();
    void PrepareCycleRef()
    {
        std::lock_guard<std::mutex> lg(cycleWorkStackMtx);
        cycleRefWorkStack.insert(discoveredExternObjects.begin(), discoveredExternObjects.end());
        discoveredExternObjects.clear();
    }
    void MergeResurrectExportObjects()
    {
        std::lock_guard<std::mutex> lg(resurrectExportMtx);
        resurrectedExportObjectes.insert(resurrectedExportObjectesForwardPhase.begin(),
            resurrectedExportObjectesForwardPhase.end());
        resurrectedExportObjectesForwardPhase.clear();
    }
    void FlipTagID() { currentTagID ^= 1; }
    uint16_t GetCurrentTagID() override { return currentTagID; }
    uint16_t GetPreviousTagID() const { return currentTagID ^ 1; }

    // note this api is not atomic, caller should take care of this.
    bool IsOldPointer(RefField<>& ref) const override { return ref.IsTagged() && ref.GetTagID() == GetPreviousTagID(); }

    // note this api is not atomic, caller should take care of this.
    bool IsCurrentPointer(RefField<>& ref) const override { return ref.IsTagged() && ref.GetTagID() == currentTagID; }

    void AddRawPointerObject(BaseObject* obj) override
    {
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        space.AddRawPointerObject(obj);
    }

    void RemoveRawPointerObject(BaseObject* obj) override
    {
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        space.RemoveRawPointerObject(obj);
    }

    void ResolveCycleRef() override;

    // BaseObject* ForwardFixRefField(RefField<>& field) const;
    BaseObject* ForwardUpdateRawRef(ObjectRef& ref);

    bool IsFromObject(BaseObject* obj) const override
    {
        // filter const string object.
        if (Heap::IsHeapAddress(obj)) {
            auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<uintptr_t>(obj));
            return regionInfo->IsMovableRegion();
        }

        return false;
    }

    bool IsGhostFromObject(BaseObject* obj) const override
    {
        // filter const string object.
        if (Heap::IsHeapAddress(obj)) {
            return RegionInfo::InGhostFromRegion(obj);
        }

        return false;
    }

    bool IsUnmovableFromObject(BaseObject* obj) const override;

    // this is called when caller assures from-object/from-region still exists.
    BaseObject* GetForwardPointer(BaseObject* fromObj, RegionInfo* region)
    {
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        return space.GetRegionManager().RouteObject(fromObj, region);
    }

    BaseObject* FindToVersion(BaseObject* obj) const override
    {
        // Non-heap (e.g. local) addresses are not in the unit table.
        if (obj == nullptr || !Heap::IsHeapAddress(obj)) {
            return nullptr;
        }
        RegionInfo* fromRegionInfo = RegionInfo::GetGhostFromRegionAt(reinterpret_cast<MAddress>(obj));
        if (fromRegionInfo == nullptr) {
            return nullptr;
        }
        return FindToVersion(obj, fromRegionInfo);
    }

protected:
    BaseObject* FindToVersion(BaseObject* obj, RegionInfo* fromRegionInfo) const
    {
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        return space.GetRegionManager().RouteObject(obj, fromRegionInfo);
    }

    BaseObject* ForwardObjectImpl(BaseObject* obj, RegionInfo* ghostFromRegion);
    BaseObject* ForwardObjectExclusive(BaseObject* obj) override;

    bool TryUntagRefField(BaseObject* obj, RefField<>& field, BaseObject*& target) const override;

    virtual BaseObject* TryForwardObject(BaseObject* fromVersion);
    BaseObject* TryForwardObject(BaseObject* fromVersion, RegionInfo* fromRegion);

    bool TryUpdateRefField(BaseObject* obj, RefField<>& field, BaseObject*& newRef) const override;
    bool TryForwardRefField(BaseObject* obj, RefField<>& field, BaseObject*& newRef) const override;

    RefField<> GetAndTryTagRefField(BaseObject* target) const override
    {
        if (IsFromObject(target)) {
            return RefField<>(target, 1, currentTagID);
        } else {
            return RefField<>(target);
        }
    }

    void CollectLargeGarbage()
    {
        MRT_PHASE_TIMER("Collect large garbage");
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        GCStats& stats = GetGCStats();
        stats.largeSpaceSize = space.LargeObjectBytes();
        stats.largeGarbageSize = space.CollectLargeGarbage();
        stats.collectedBytes += stats.largeGarbageSize;
    }

    void CollectPinnedGarbage()
    {
        MRT_PHASE_TIMER("Collect pinned garbage");
        RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
        GCStats& stats = GetGCStats();
        stats.pinnedSpaceSize = space.PinnedSpaceSize();
        stats.pinnedGarbageSize = space.CollectPinnedGarbage();
        stats.collectedBytes += stats.pinnedGarbageSize;
    }

    void CollectSmallSpace();

    void DoGarbageCollection() override;
    void ProcessFinalizers() override;
    void EnumAndTagRawRoot(ObjectRef& ref, RootSet& rootSet) const override;

protected:
    virtual void TraceHeap();
    virtual void PostTrace();
    virtual void Preforward();
    void PreforwardConcurrencyModelRoots();
    void PreforwardAllExportFromRoots();
    void PreforwardFinalizerProcessorRoots();
    void PreforwardDiscoveredExternObjects();
    void PreforwardAllResurrectExportFromObjects();
    // gc index 0 or 1 is used to distinguish previous gc and current gc.
    static uint16_t currentTagID;
    RegionForwardTable fwdTable;

private:
    template<bool forward>
    bool TryUpdateRefFieldImpl(BaseObject* obj, RefField<>& ref, BaseObject*& oldRef, BaseObject*& newRef) const;
    CrossRefHandler GetCrossRefHandler(BaseObject* foreignProxy);
};
} // namespace MapleRuntime
#endif // ~MRT_WCOLLECTOR_H
