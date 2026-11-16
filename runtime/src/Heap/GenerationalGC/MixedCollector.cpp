// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information


#include "MixedCollector.h"
#include "Allocator/MixedRegionSpace/MixedRegionSpace.h"
#include "Heap/GcThreadPool.h"
#include "Heap/HeapWork.h"
#include "Heap.h"
#include "GenerationConstants.h"
#include "RememberSet.h"

namespace MapleRuntime {

void MixedCollector::ProcessFinalizers()
{
    std::function<bool(BaseObject*)> finalizable = [this](BaseObject* obj) { return !IsMarkedObject(obj); };
    FinalizerProcessor& fp = collectorResources.GetFinalizerProcessor();
    fp.EnqueueFinalizables(finalizable, snapshotFinalizerNum);
    fp.Notify();
}

void MixedCollector::UpdateGCStats()
{
    GenerationalGCStats& stats = static_cast<GenerationalGCStats&>(GetGCStats());
    stats.Dump();
    MixedRegionSpace& space = static_cast<MixedRegionSpace&>(theAllocator);
    MixedRegionManager& manager = MixedRegionSpace::CastDown(space.GetRegionManager());
    const size_t maxCapacity = theAllocator.GetMaxCapacity();
    const size_t youngCapacity = std::min(maxCapacity / YOUNG_GEN_CAPACITY_DIVISOR,
                                          YOUNG_CAPACITY_FOR_MIXED_MAX);
    const size_t minThreshold = youngCapacity * MIN_MIXED_THRESHOLD_NUM / MIN_MIXED_THRESHOLD_DEN;
    const size_t maxThreshold = maxCapacity * MAX_MIXED_THRESHOLD_NUM / MAX_MIXED_THRESHOLD_DEN;
    const size_t used = manager.GetUsedRegionSize();
    const size_t predicted = static_cast<size_t>(stats.RefreshAllocationSpeed(TimeUtil::NanoSeconds()) *
        PREDICT_WINDOW_MS * TimeUtil::MilliSeconds());
    const size_t headroom = maxThreshold > used ? maxThreshold - used : 0;
    const size_t oldThreshold = stats.GetMixedThreshold();
    stats.SetMixedThreshold(std::max(used + std::min(predicted, headroom), minThreshold));
    VLOG(REPORT, "all used size %zu, update mixed threshold %zu -> %zu", used, oldThreshold,
         stats.GetMixedThreshold());
}

void MixedCollector::DoGarbageCollection()
{
    TraceHeap();
    PostTrace();
    ConcurrentSweep();
    Preforward();

    ForwardFromSpace();
    TransitionToGCPhase(GCPhase::GC_PHASE_GENERATION_IDLE, true);
    MergeResurrectExportObjects();
    PostResolveCycleTask();
    FlipTagID();
    ForwardDataManager::GetForwardDataManager().SetTagID(currentTagID);

    CollectSmallSpace();
    ForwardDataManager::GetForwardDataManager().UnbindPreviousLiveInfo();
}

void MixedCollector::EnumRefFieldRoot(RefField<>& field, RootSet& rootSet) const
{
    RefField<> oldField(field);
    // if field is already tagged currently, it is also already enumerated.
    if (IsCurrentPointer(oldField)) {
        rootSet.push_back(oldField.GetTargetObject());
        return;
    }

    BaseObject* latest = nullptr;
    if (IsOldPointer(oldField)) {
        BaseObject* targetObj = oldField.GetTargetObject();
        latest = FindLatestVersion(targetObj);
    } else {
        latest = oldField.GetTargetObject();
    }

    // target object could be null or non-heap for some static variable.
    if (!IsTargetAddress(latest)) {
        DLOG(ENUM, "skip invalid mixed field ref %p: %#zx -> %p", &field, oldField.GetFieldValue(), latest);
        return;
    }
    CHECK_DETAIL(latest->IsValidObject(), "Enum static root %p(%p) encounters invalid object", latest, &field);
    RefField<> newField = GetAndTryTagRefField(latest);
    if (oldField.GetFieldValue() == newField.GetFieldValue()) {
        DLOG(ENUM, "enum mixed static ref@%p: %#zx -> %p<%p>(%zu)", &field, oldField.GetFieldValue(), latest,
             latest->GetTypeInfo(), latest->GetSize());
    } else if (field.CompareExchange(oldField.GetFieldValue(), newField.GetFieldValue())) {
        DLOG(ENUM, "enum mixed static ref@%p: %#zx=>%#zx -> %p<%p>(%zu)", &field, oldField.GetFieldValue(),
             newField.GetFieldValue(), latest, latest->GetTypeInfo(), latest->GetSize());
    } else {
        DLOG(ENUM, "enum mixed static ref@%p: %#zx -> %p<%p>(%zu)", &field, oldField.GetFieldValue(), latest,
             latest->GetTypeInfo(), latest->GetSize());
    }
    rootSet.push_back(latest);
}

void MixedCollector::EnumRememberedRoots(RootSet& rootSet) const
{
    (void)rootSet;
    RememberSet::Instance().VisitRememberedSlots([this](uintptr_t slotAddr) {
        RefField<>* field = reinterpret_cast<RefField<>*>(slotAddr);
        RefField<> oldField(*field);
        // if field is already tagged currently, it is also already enumerated.
        if (IsCurrentPointer(oldField)) {
            return;
        }

        BaseObject* latest = nullptr;
        if (IsOldPointer(oldField)) {
            BaseObject* targetObj = oldField.GetTargetObject();
            latest = FindLatestVersion(targetObj);
        } else {
            latest = oldField.GetTargetObject();
        }

        // target object could be null or non-heap for some static variable.
        if (!IsTargetAddress(latest)) {
            DLOG(ENUM, "skip invalid mixed field ref %p: %#zx -> %p", field, oldField.GetFieldValue(), latest);
            return;
        }
        RefField<> newField = GetAndTryTagRefField(latest);
        if (oldField.GetFieldValue() == newField.GetFieldValue()) {
            DLOG(ENUM, "enum fix static ref@%p: %#zx -> %p<%p>(%zu)", field, oldField.GetFieldValue(), latest,
                latest->GetTypeInfo(), latest->GetSize());
        } else if (field->CompareExchange(oldField.GetFieldValue(), newField.GetFieldValue())) {
            DLOG(ENUM, "enum fix static ref@%p: %#zx=>%#zx -> %p<%p>(%zu)", field, oldField.GetFieldValue(),
                newField.GetFieldValue(), latest, latest->GetTypeInfo(), latest->GetSize());
        } else {
            DLOG(ENUM, "enum fix static ref@%p: %#zx -> %p<%p>(%zu)", field, oldField.GetFieldValue(), latest,
                latest->GetTypeInfo(), latest->GetSize());
        }
    });
}

void MixedCollector::EnumAndTagRawRoot(ObjectRef& ref, RootSet& rootSet) const
{
    RefField<>& refField = reinterpret_cast<RefField<>&>(ref);
    RefField<> oldField(refField);
    CHECK_DETAIL(!IsOldPointer(oldField), "EnumAndTagRawRoot failed: Invalid root: %zx", oldField.GetFieldValue());
    if (IsCurrentPointer(oldField)) {
        rootSet.push_back(oldField.GetTargetObject());
        DLOG(ENUM, "[MIXED] enum raw root @%p: %#zx %p(%zu)", &ref, oldField.GetFieldValue(),
             oldField.GetTargetObject());
        return;
    }
    BaseObject* root = oldField.GetTargetObject();
    if (Heap::IsHeapAddress(root)) {
        CHECK_DETAIL(root->IsValidObject(),
                     "[MIXED] Enum and tag runtime root %p(%p) encounters invalid object", root, &ref);
        RefField<> newField = GetAndTryTagRefField(root);
        if (oldField.GetFieldValue() == newField.GetFieldValue()) {
            DLOG(ENUM, "[MIXED] enum raw root @%p: %p(%zu)", &ref, root, root->GetSize());
        } else if (refField.CompareExchange(oldField.GetFieldValue(), newField.GetFieldValue())) {
            DLOG(ENUM, "[MIXED] enum raw ref@%p: %#zx=>%#zx -> %p<%p>(%zu)", &refField, oldField.GetFieldValue(),
                 newField.GetFieldValue(), root, root->GetTypeInfo(), root->GetSize());
        } else {
            DLOG(ENUM, "[MIXED] enum raw ref@%p: %#zx -> %p<%p>(%zu)", &refField, oldField.GetFieldValue(), root,
                 root->GetTypeInfo(), root->GetSize());
        }
        rootSet.push_back(root);
    } else {
        DLOG(ENUM, "[MIXED] skip young invalid ref@%p: %#zx -> %p", &refField, oldField.GetFieldValue(), root);
    }
}

RefField<> MixedCollector::GetAndTryTagRefField(BaseObject* target) const
{
    if (IsFromObject(target)) {
        return RefField<>(target, 1, currentTagID);
    } else {
        return RefField<>(target);
    }
}

BaseObject* MixedCollector::ForwardObject(BaseObject* fromVersion)
{
    return YoungCollector::ForwardObject(fromVersion);
}

bool MixedCollector::IsTargetAddress(const BaseObject* obj) const
{
    return Heap::IsHeapAddress(obj);
}

void MixedCollector::AssembleCandidates()
{
    reinterpret_cast<MixedRegionSpace&>(theAllocator).AssembleMixedCandidates();
}

class OldSweepTask : public HeapWork {
public:
    OldSweepTask(RegionList* sweepable, RegionList& swept, RegionManager& manager)
        : sweepableRegionList(sweepable), sweptRegionList(swept), regionManager(manager) {}

    ~OldSweepTask() override = default;

    void Execute(size_t) override
    {
        RegionInfo* region = sweepableRegionList->TakeHeadRegionNoLock();
        while (region != nullptr) {
            RegionInfo* next = sweepableRegionList->TakeHeadRegionNoLock();
            if (region->GetLiveByteCount() == 0) {
                RememberSet::Instance().RemoveRegion(region);
                region->ResetRSetCardTable();
                regionManager.CollectRegion(region);
                region = next;
                continue;
            }
            region->SweepRegion();
            region->ClearLiveInfo();
            sweptRegionList.PrependRegion(region, RegionInfo::RegionType::SWEEP_REGION);
            region = next;
        }
        delete sweepableRegionList;
    }

private:
    RegionList* sweepableRegionList;
    RegionList& sweptRegionList;
    RegionManager& regionManager;
};

void MixedCollector::ClearDeadObjectRSetSlots()
{
    MRT_PHASE_TIMER("Clear dead object RSet slots");
    MixedRegionSpace& space = static_cast<MixedRegionSpace&>(theAllocator);
    MixedRegionManager& manager = MixedRegionSpace::CastDown(space.GetRegionManager());
    manager.GetOldSweptRegionList().VisitAllRegions([](RegionInfo* region) {
        region->VisitAllObjects([region](BaseObject* object) {
            const uintptr_t start = reinterpret_cast<uintptr_t>(object);
            // Finalizable objects and their children may survive through resurrection only.
            if (!region->IsSurvivedObject(start - region->GetRegionStart())) {
                region->ClearRSetSlots(start, RegionSpace::GetAllocSize(*object));
            }
        });
    });
}

void MixedCollector::ConcurrentSweep()
{
    YoungCollector::ConcurrentSweep();
    GCThreadPool* threadPool = GetThreadPool();
    if (threadPool == nullptr) {
        return;
    }
    MixedRegionSpace& space = static_cast<MixedRegionSpace&>(theAllocator);
    MixedRegionManager& manager = MixedRegionSpace::CastDown(space.GetRegionManager());
    constexpr size_t regionsPerTask = 10;
    while (true) {
        RegionList* local = new (std::nothrow) RegionList("old sweep task regions");
        CHECK_DETAIL(local != nullptr, "failed to allocate old sweep task list");
        if (!manager.GetSweepableOldRegionList().SplitByRegionCount(*local, regionsPerTask)) {
            delete local;
            break;
        }
        HeapWork* task = new (std::nothrow) OldSweepTask(local, manager.GetOldSweptRegionList(), manager);
        CHECK_DETAIL(task != nullptr, "failed to allocate old sweep task");
        threadPool->AddWork(task);
    }
}

void MixedCollector::ResetForwardingData()
{
    fwdTable.PrepareForwardTable(true);
}

} // namespace MapleRuntime
