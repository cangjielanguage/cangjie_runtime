// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_MIXED_REGION_MANAGER_H
#define MRT_MIXED_REGION_MANAGER_H
#include "Allocator/RegionList.h"
#include "Allocator/RegionManager.h"
#include "GenerationalGC/GenerationConstants.h"
#include "GenerationalGC/RememberSet.h"
namespace MapleRuntime {

class MixedRegionManager : public RegionManager {
public:
    MixedRegionManager() : RegionManager(), sweepableYoungRegionList("sweepable young region list"),
        sweepableOldRegionList("sweepable old region list"), sweptYoungRegionList("swept young region list"),
        sweptOldRegionList("old swept region list"), oldRegionList("old region list"),
        oldFromRegionList("old from region list"), ghostOldFromRegionList("ghost old from region list"),
        discreteForwardingRegionList("discretely forwarding region list"),
        ghostPromoteRegionList("ghost promote region list") {}
    ~MixedRegionManager() override = default;
    void AssembleYoungRegions()
    {
        constexpr size_t sweptSplitRatioDivisor = 3;
        size_t unitCount = recentFullRegionList.GetUnitCount();
        size_t youngRegionSize = std::min(Heap::GetHeap().GetMaxCapacity() / YOUNG_GEN_CAPACITY_DIVISOR,
                                          YOUNG_GEN_MAX_SIZE);
        size_t sweptAllocatedSize = sweptYoungRegionList.GetAllocatedSize();
        bool shouldSplit = ShouldSplit(unitCount) && sweptAllocatedSize <= youngRegionSize / sweptSplitRatioDivisor;
        if (!shouldSplit) {
            fromRegionList.MergeRegionList(recentFullRegionList, RegionInfo::RegionType::FROM_REGION);
        } else {
            RegionList tmpMovable("movable regions cache");
            RegionList tmpSwept("swept regions cache");
            recentFullRegionList.SplitList(tmpMovable, tmpSwept, GetMovableThreshold());
            MovePromotedRegions(tmpSwept);
            fromRegionList.MergeRegionList(tmpMovable, RegionInfo::RegionType::FROM_REGION);
            sweepableYoungRegionList.MergeRegionList(tmpSwept, RegionInfo::RegionType::SWEEP_REGION);
        }
        fromRegionList.VisitAllRegions([](RegionInfo* region) { region->ClearLiveInfo(); });
        sweepableYoungRegionList.VisitAllRegions([](RegionInfo* region) { region->ClearLiveInfo(); });
    }
    void AssembleMixedRegions()
    {
        AssembleYoungRegions();
        AssembleOldRegions();
    }
    size_t ClassifyYoungRegions();
    bool RoutePromoteRegion(RegionInfo* fromRegion);
    void PromoteRegion(RegionInfo* fromRegion);
    // Promote a whole region without copying its objects. This is usable for
    // large regions and can be extended to small regions when appropriate.
    void PromoteRegionInPlace(RegionInfo* region);
    void ForwardFromSpace(GCThreadPool* threadPool) override;
    size_t CollectRegion(RegionInfo* region) override;
    size_t CollectLargeGarbage();
    void MergeOldLargeRegionList(RegionList& regions)
    {
        recentLargeRegionList.MergeRegionList(regions, RegionInfo::RegionType::LARGE_REGION);
    }
    void EnlistOldRegionList(RegionInfo* region) noexcept
    {
        region->SetOldRegionFlag(1);
        oldRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
    }
    RegionList& GetSweepableRegionList() { return sweepableYoungRegionList; }
    RegionList& GetSweepableOldRegionList() { return sweepableOldRegionList; }
    RegionList& GetSweptRegionList() { return sweptYoungRegionList; }
    RegionList& GetOldSweptRegionList() { return sweptOldRegionList; }
    void EnlistThreadLocalRegion(RegionInfo* region)
    {
        tlRegionList.PrependRegion(region, RegionInfo::RegionType::THREAD_LOCAL_REGION);
    }
    size_t GetYoungUsedSize() const
    {
        size_t youngUnitCount = unmovableFromRegionList.GetUnitCount() + recentFullRegionList.GetUnitCount() +
            recentLargeRegionList.GetUnitCount() + recentPinnedRegionList.GetUnitCount() +
            rawPointerPinnedRegionList.GetUnitCount() + largeTraceRegions.GetUnitCount() +
            fullTraceRegions.GetUnitCount() + tlRegionList.GetUnitCount() + fromRegionList.GetUnitCount() +
            sweepableYoungRegionList.GetUnitCount() + sweptYoungRegionList.GetUnitCount() +
            discreteForwardingRegionList.GetUnitCount();
        return youngUnitCount * RegionInfo::UNIT_SIZE;
    }
    void RecycleYoungSlotRegion(RegionInfo* region)
    {
        recentFullRegionList.PrependRegion(region, RegionInfo::RegionType::RECENT_FULL_REGION);
    }
    void RecycleOldSlotRegion(RegionInfo* region)
    {
        oldRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
    }
    bool IsYoungSpaceHeavy() const;
    BaseObject* PromoteObject(BaseObject* fromObj, RegionInfo* ghostFromRegion);
    void DumpRegionStats(const char* msg, bool dumpToError = false) const override;
    void PrepareYoungFromRegionList()
    {
        // All DispelGhostFromRegion must happen before PrepareForwardableRegion.
        // Even if it is young gc, we also need to handle ghost region in old space,
        // because they may be reclaimed and be taken into young space.
        ghostFromRegionList.VisitAllGhostRegions([](RegionInfo* region) {
            DLOG(REGION, "dispel ghost from region %p@[%#zx, %#zx)", region, region->GetRegionStart(),
                 region->GetRegionEnd());
            region->DispelGhostFromRegion();
        });

        ghostPromoteRegionList.VisitAllGhostRegions([](RegionInfo* region) {
            DLOG(REGION, "dispel ghost promote region %p@[%#zx, %#zx)", region, region->GetRegionStart(),
                 region->GetRegionEnd());
            region->DispelGhostFromRegion();
        });

        ghostOldFromRegionList.VisitAllGhostRegions([](RegionInfo* region) {
            DLOG(REGION, "dispel ghost old region %p@[%#zx, %#zx)", region, region->GetRegionStart(),
                 region->GetRegionEnd());
            region->DispelGhostFromRegion();
        });

        fromRegionList.VisitAllRegions([](RegionInfo* region) {
            DLOG(REGION, "prepare from region %p@[%#zx+%zu, %#zx)", region, region->GetRegionStart(),
                 region->GetLiveByteCount(), region->GetRegionEnd());
            region->PrepareForwardableRegion();
        });

        fromRegionList.CopyListTo(ghostFromRegionList);

        discreteForwardingRegionList.VisitAllRegions([](RegionInfo* region) {
            DLOG(REGION, "prepare promote region %p@[%#zx+%zu, %#zx)", region, region->GetRegionStart(),
                 region->GetLiveByteCount(), region->GetRegionEnd());
            region->PrepareForwardableRegion();
        });
        discreteForwardingRegionList.CopyListTo(ghostPromoteRegionList);
    }
    void PrepareMixedFromRegionList()
    {
        PrepareYoungFromRegionList();
        oldFromRegionList.VisitAllRegions([](RegionInfo* region) {
            DLOG(REGION, "prepare old region %p@[%#zx+%zu, %#zx)", region, region->GetRegionStart(),
                 region->GetLiveByteCount(), region->GetRegionEnd());
            region->PrepareForwardableRegion();
        });
        oldFromRegionList.CopyListTo(ghostOldFromRegionList);
    }
    void PrepareFromRegionList(bool isFull) override
    {
        if (isFull) {
            PrepareMixedFromRegionList();
        } else {
            PrepareYoungFromRegionList();
        }
    }
    bool RequestForRegion(size_t size, bool isLoose) override
    {
        if (!isLoose) {
            return true;
        }

        Heap& heap = Heap::GetHeap();
        const size_t gcStartAllocated = heap.GetCollector().GetGCStats().liveBytesBeforeGC;
        if (gcStartAllocated != 0) {
            const size_t currentAllocated = GetAllocatedSize();
            const size_t growthLimit = gcStartAllocated * GROWTH_LIMIT_NUM / GROWTH_LIMIT_DEN;
            if (currentAllocated > growthLimit || size > growthLimit - currentAllocated) {
                return false;
            }
        }
        return true;
    }
    void CheckGC() override
    {
        if (IsGcThread()) {
            return;
        }
        Heap& heap = Heap::GetHeap();

        if (heap.IsGcStarted()) {
            return;
        }
        GenerationalGCStats& stats = static_cast<GenerationalGCStats&>(heap.GetCollector().GetGCStats());
        size_t maxCapacity = heap.GetMaxCapacity();
        size_t youngCapacity = std::min(maxCapacity / YOUNG_GEN_CAPACITY_DIVISOR, YOUNG_GEN_MAX_SIZE);
        size_t maxYoungThreshold = youngCapacity * MAX_YOUNG_THRESHOLD_NUM / MAX_YOUNG_THRESHOLD_DEN;
        size_t maxMixedThreshold = maxCapacity * MAX_MIXED_THRESHOLD_NUM / MAX_MIXED_THRESHOLD_DEN;
        size_t youngUsedSize = GetYoungUsedSize();
        size_t allUsedSize = GetUsedRegionSize();
        bool mixedReached = allUsedSize >= stats.GetMixedThreshold();
        bool youngReached = youngUsedSize >= stats.GetYoungThreshold();
        if (mixedReached) {
            bool async = allUsedSize < maxMixedThreshold;
            heap.GetCollector().RequestGC(async ? GC_REASON_MIXED : GC_REASON_FORCE, async);
        } else if (youngReached) {
            bool async = youngUsedSize < maxYoungThreshold;
            heap.GetCollector().RequestGC(async ? GC_REASON_HEU : GC_REASON_HEU_EAGER, async);
        }
    }
    size_t GetAllocatedSize() const override
    {
        size_t total = RegionManager::GetAllocatedSize();
        total += sweepableYoungRegionList.GetAllocatedSize();
        total += sweepableOldRegionList.GetAllocatedSize();
        total += sweptYoungRegionList.GetAllocatedSize();
        total -= GetFreeSlotTotalSize(sweptYoungRegionList);
        total += sweptOldRegionList.GetAllocatedSize();
        total -= GetFreeSlotTotalSize(sweptOldRegionList);
        total += oldRegionList.GetAllocatedSize();
        total += oldFromRegionList.GetAllocatedSize();
        total += discreteForwardingRegionList.GetAllocatedSize();
        return total;
    }
    size_t GetUsedUnitCount() const override
    {
        size_t total = RegionManager::GetUsedUnitCount();
        total += sweepableYoungRegionList.GetUnitCount();
        total += sweepableOldRegionList.GetUnitCount();
        total += sweptYoungRegionList.GetUnitCount();
        total += sweptOldRegionList.GetUnitCount();
        total += oldRegionList.GetUnitCount();
        total += oldFromRegionList.GetUnitCount();
        total += discreteForwardingRegionList.GetUnitCount();
        return total;
    }
    void AddRawPointerObject(BaseObject* obj) override
    {
        RegionInfo* region = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        region->IncRawPointerObjectCount();
        if (region->IsFromRegion()) {
            if (region->IsOldRegion()) {
                if (oldFromRegionList.TryDeleteRegion(region, RegionInfo::RegionType::FROM_REGION,
                                                      RegionInfo::RegionType::SWEEP_REGION)) {
                    GCPhase phase = Heap::GetHeap().GetGCPhase();
                    CHECK(phase != GCPhase::GC_PHASE_FORWARD && phase != GCPhase::GC_PHASE_PREFORWARD &&
                          phase != GCPhase::GC_PHASE_GENERATION_FORWARD &&
                          phase != GCPhase::GC_PHASE_GENERATION_PREFORWARD);
                    if (phase == GCPhase::GC_PHASE_POST_TRACE || phase == GCPhase::GC_PHASE_GENERATION_POST_TRACE) {
                        region->ClearGhostRegionBit();
                        DLOG(TRACE, "dynamiclly pin old region %p [%p, %p) and clear ghost bit at phase %u",
                            region, region->GetRegionStart(), region->GetRegionEnd(), phase);
                    } else {
                        DLOG(TRACE, "dynamiclly pin old region %p [%p, %p) and keep ghost bit at phase %u",
                            region, region->GetRegionStart(), region->GetRegionEnd(), phase);
                    }
                    sweepableOldRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
                }
            } else {
                if (fromRegionList.TryDeleteRegion(region, RegionInfo::RegionType::FROM_REGION,
                                                   RegionInfo::RegionType::SWEEP_REGION)) {
                    GCPhase phase = Heap::GetHeap().GetGCPhase();
                    CHECK(phase != GCPhase::GC_PHASE_FORWARD && phase != GCPhase::GC_PHASE_PREFORWARD &&
                          phase != GCPhase::GC_PHASE_GENERATION_FORWARD &&
                          phase != GCPhase::GC_PHASE_GENERATION_PREFORWARD);
                    if (phase == GCPhase::GC_PHASE_POST_TRACE || phase == GCPhase::GC_PHASE_GENERATION_POST_TRACE) {
                        region->ClearGhostRegionBit();
                        DLOG(TRACE, "dynamiclly pin young region %p [%p, %p) and clear ghost bit at phase %u",
                            region, region->GetRegionStart(), region->GetRegionEnd(), phase);
                    } else {
                        DLOG(TRACE, "dynamiclly pin young region %p [%p, %p) and keep ghost bit at phase %u",
                            region, region->GetRegionStart(), region->GetRegionEnd(), phase);
                    }
                    sweepableYoungRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
                }
            }
        } else {
            CHECK(region->GetRegionType() != RegionInfo::RegionType::LONE_FROM_REGION);
        }
        // Region may be moved from from region list to promote region list, so it must be double checked
        // after from region
        if (region->IsFromPromoteRegion() && discreteForwardingRegionList.TryDeleteRegion(region,
            RegionInfo::RegionType::FROM_PROMOTE_REGION, RegionInfo::RegionType::SWEEP_REGION)) {
            GCPhase phase = Heap::GetHeap().GetGCPhase();
            CHECK(phase != GCPhase::GC_PHASE_FORWARD && phase != GCPhase::GC_PHASE_PREFORWARD &&
                phase != GCPhase::GC_PHASE_GENERATION_FORWARD &&
                phase != GCPhase::GC_PHASE_GENERATION_PREFORWARD);
            if (phase == GCPhase::GC_PHASE_POST_TRACE || phase == GCPhase::GC_PHASE_GENERATION_POST_TRACE) {
                region->ClearGhostRegionBit();
                DLOG(TRACE, "dynamiclly pin promoted region %p [%p, %p) and clear ghost bit at phase %u",
                    region, region->GetRegionStart(), region->GetRegionEnd(), phase);
            } else {
                DLOG(TRACE, "dynamiclly pin promoted region %p [%p, %p) and keep ghost bit at phase %u",
                    region, region->GetRegionStart(), region->GetRegionEnd(), phase);
            }
            sweepableYoungRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
        }
    }

private:
    void MovePromotedRegions(RegionList& source)
    {
        RegionInfo* region = source.GetHeadRegion();
        while (region != nullptr) {
            RegionInfo* next = region->GetNextRegion();
            if (region->IsPromoted()) {
                source.RemoveRegionNoLock(region);
                discreteForwardingRegionList.PrependRegion(region, RegionInfo::RegionType::FROM_PROMOTE_REGION);
            }
            region = next;
        }
    }

    static size_t GetFreeSlotTotalSize(const RegionList& list)
    {
        size_t total = 0;
        std::lock_guard<std::mutex> lock(list.GetListMutex());
        for (RegionInfo* region = list.GetHeadRegion(); region != nullptr; region = region->GetNextRegion()) {
            total += region->GetTotalSlotSize();
        }
        return total;
    }
    static constexpr uint8_t PROMOTE_AGE = 3;
    static constexpr size_t SPLIT_UNIT_COUNT_THRESHOLD = 4000;
    static constexpr size_t MOVABLE_UNIT_THRESHOLD = 4000;
    bool PromoteRegionImpl(RegionInfo* fromRegion);
    bool ShouldSplit(size_t unitCount) const
    {
        return unitCount > SPLIT_UNIT_COUNT_THRESHOLD;
    }
    size_t GetMovableThreshold() const
    {
        return MOVABLE_UNIT_THRESHOLD;
    }
    void AssembleOldRegions()
    {
        RegionList resweepRegions("old regions selected for resweep");
        size_t sweptRegionCount = 0;
        {
            std::lock_guard<std::mutex> lock(sweptOldRegionList.GetListMutex());
            sweptRegionCount = sweptOldRegionList.GetRegionCount();
            constexpr size_t resweepDivisor = 2;
            const size_t resweepCount = sweptRegionCount / resweepDivisor + sweptRegionCount % resweepDivisor;
            // Swept regions are prepended after sweeping. Take the oldest half to avoid starvation.
            for (size_t i = 0; i < resweepCount; ++i) {
                RegionInfo* region = sweptOldRegionList.GetTailRegion();
                sweptOldRegionList.RemoveRegionNoLock(region);
                resweepRegions.PrependRegionNoLock(region, RegionInfo::RegionType::SWEEP_REGION);
            }
        }
        VLOG(REPORT, "mixed old resweep: selected %zu of %zu regions", resweepRegions.GetRegionCount(),
             sweptRegionCount);
        sweepableOldRegionList.MergeRegionList(resweepRegions, RegionInfo::RegionType::SWEEP_REGION);
        sweepableOldRegionList.MergeRegionList(oldRegionList, RegionInfo::RegionType::SWEEP_REGION);
        // Mixed GC traces all old regions, including those deferred from sweeping this cycle.
        sweptOldRegionList.VisitAllRegions([](RegionInfo* region) { region->ClearLiveInfo(); });
        sweepableOldRegionList.VisitAllRegions([](RegionInfo* region) { region->ClearLiveInfo(); });
    }
    RegionList sweepableYoungRegionList;
    RegionList sweepableOldRegionList;
    RegionList sweptYoungRegionList;
    RegionList sweptOldRegionList;
    RegionList oldRegionList;
    RegionList oldFromRegionList;
    RegionList ghostOldFromRegionList;
    RegionList discreteForwardingRegionList;
    RegionList ghostPromoteRegionList;
};

} // namespace MapleRuntime

#endif // MRT_MIXED_REGION_MANAGER_H
