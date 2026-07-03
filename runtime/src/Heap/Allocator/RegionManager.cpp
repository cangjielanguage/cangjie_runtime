// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Allocator/RegionManager.h"

#include <cmath>
#include <unistd.h>

#include "Allocator/RegionSpace.h"
#include "Base/CString.h"
#include "Collector/Collector.h"
#include "Collector/CopyCollector.h"
#include "Common/ScopedObjectAccess.h"
#include "Heap.h"
#include "Mutator/Mutator.inline.h"
#include "Mutator/MutatorManager.h"
#include "ObjectModel/RefField.inline.h"
#if defined(CANGJIE_TSAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#include "Sync/Sync.h"

namespace MapleRuntime {
uintptr_t RegionInfo::UnitInfo::totalUnitCount = 0;
uintptr_t RegionInfo::UnitInfo::heapStartAddress = 0;

static size_t GetPageSize() noexcept
{
    size_t pageSize = 0;
#if defined(_WIN64)
    SYSTEM_INFO systeminfo;
    GetSystemInfo(&systeminfo);
    if (systeminfo.dwPageSize != 0) {
        pageSize = systeminfo.dwPageSize;
    } else {
        // default page size is 4KB if get system page size failed.
        pageSize = 4 * KB;
    }
#elif defined(__APPLE__)
    pageSize = static_cast<size_t>(sysconf(_SC_PAGESIZE));
#else
    pageSize = static_cast<size_t>(getpagesize());
#endif
    return pageSize;
}

// System default page size
const size_t MRT_PAGE_SIZE = GetPageSize();
const size_t AllocatorUtils::ALLOC_PAGE_SIZE = MapleRuntime::MRT_PAGE_SIZE;
// region unit size: same as system page size
const size_t RegionInfo::UNIT_SIZE = MapleRuntime::MRT_PAGE_SIZE;
// regarding a object as a large object when the size is greater than 32KB or one page size,
// depending on the system page size.
const size_t RegionInfo::LARGE_OBJECT_DEFAULT_THRESHOLD = MapleRuntime::MRT_PAGE_SIZE > (32 * KB) ?
                                                            MapleRuntime::MRT_PAGE_SIZE : 32 * KB;
// max size of per region is 128KB.
const size_t RegionManager::MAX_UNIT_COUNT_PER_REGION = (128 * KB) / MapleRuntime::MRT_PAGE_SIZE;
// size of huge page is 2048KB.
const size_t RegionManager::HUGE_PAGE = (2048 * KB) / MapleRuntime::MRT_PAGE_SIZE;;

class ForwardTask : public HeapWork {
public:
    ForwardTask(RegionManager& manager, RegionList& fromSpace)
        : regionManager(manager), fromRegionList(fromSpace) {}

    ~ForwardTask() = default;

    void Execute(size_t) override
    {
        while (true) {
            RegionInfo* region = fromRegionList.TakeHeadRegion(RegionInfo::RegionType::LONE_FROM_REGION);
            if (region == nullptr) { break; }
            regionManager.ForwardRegion(region);
        }
    }

private:
    RegionManager& regionManager;
    RegionList& fromRegionList;
};

#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
void RegionInfo::DumpRegionInfo(LogType type) const
{
    DLOG(type, "Region index: %zu, type: %s, address: 0x%zx-0x%zx, allocated(B) %zu, live(B) %zu", GetUnitIdx(),
         GetTypeName(), GetRegionStart(), GetRegionEnd(), GetRegionAllocatedSize(), GetLiveByteCount());
}

const char* RegionInfo::GetTypeName() const
{
    static constexpr const char* regionNames[] = {
        "undefined region",
        "thread local region",
        "recent fullregion",
        "from region",
        "unmovable from region",
        "to region",
        "full pinned region",
        "recent pinned region",
        "raw pointer pinned region",
        "tl raw pointer region",
        "large region",
        "recent large region",
        "garbage region",
    };
    return regionNames[static_cast<uint8_t>(GetRegionType())];
}
#endif

void RegionInfo::VisitAllObjects(const std::function<void(BaseObject*)>&& func)
{
    if (IsLargeRegion()) {
        func(reinterpret_cast<BaseObject*>(GetRegionStart()));
    } else if (IsSmallRegion()) {
        uintptr_t position = GetRegionStart();
        uintptr_t allocPtr = GetRegionAllocPtr();
        while (position < allocPtr) {
            // GetAllocSize should before call func, because object maybe destroy in compact gc.
            size_t size = RegionSpace::GetAllocSize(*reinterpret_cast<BaseObject*>(position));
            func(reinterpret_cast<BaseObject*>(position));
            position += size;
        }
    }
}

bool RegionInfo::VisitLiveObjectsUntilFalse(const std::function<bool(BaseObject*)>&& func)
{
    // no need to visit this region.
    if (GetLiveByteCount() == 0) {
        return true;
    }
    if (IsLargeRegion()) {
        return func(reinterpret_cast<BaseObject*>(GetRegionStart()));
    }
    if (IsSmallRegion()) {
        uintptr_t position = GetRegionStart();
        size_t offset = 0;
        uintptr_t allocPtr = GetRegionAllocPtr();

        while (position < allocPtr) {
            BaseObject* obj = reinterpret_cast<BaseObject*>(position);
            size_t allocSize = RegionSpace::GetAllocSize(*obj);
            position += allocSize;
            if (IsSurvivedObject(offset) && !func(obj)) { return false; }
            offset += allocSize;
        }
    }
    return true;
}

void RegionList::MergeRegionList(RegionList& srcList, RegionInfo::RegionType regionType)
{
    RegionList regionList("region list cache");
    srcList.MoveTo(regionList);
    RegionInfo* head = regionList.GetHeadRegion();
    RegionInfo* tail = regionList.GetTailRegion();
    if (head == nullptr) {
        return;
    }
    std::lock_guard<std::mutex> lock(listMutex);
    regionList.SetElementType(regionType);
    IncCounts(regionList.GetRegionCount(), regionList.GetUnitCount());
    if (listHead == nullptr) {
        listHead = head;
        listTail = tail;
    } else {
        tail->SetNextRegion(listHead);
        listHead->SetPrevRegion(tail);
        listHead = head;
    }
}

void RegionList::PrependRegion(RegionInfo* region, RegionInfo::RegionType type)
{
    std::lock_guard<std::mutex> lock(listMutex);
    PrependRegionLocked(region, type);
}

void RegionList::PrependRegionLocked(RegionInfo* region, RegionInfo::RegionType type)
{
    if (region == nullptr) {
        return;
    }

    DLOG(REGION, "list %p (%zu, %zu)+(%zu, %zu) prepend region %p@[%#zx+%zu, %#zx) type %u->%u", this,
        regionCount, unitCount, 1llu, region->GetUnitCount(), region, region->GetRegionStart(),
        region->GetRegionAllocatedSize(), region->GetRegionEnd(), region->GetRegionType(), type);

    region->SetRegionType(type);
    region->SetPrevRegion(nullptr);
    IncCounts(1, region->GetUnitCount());
    region->SetNextRegion(listHead);
    if (listHead == nullptr) {
        MRT_ASSERT(listTail == nullptr, "PrependRegion listTail is not null");
        listTail = region;
    } else {
        listHead->SetPrevRegion(region);
    }
    listHead = region;
}

void RegionList::DeleteRegionLocked(RegionInfo* del)
{
    MRT_ASSERT(listHead != nullptr && listTail != nullptr, "illegal region list");

    RegionInfo* pre = del->GetPrevRegion();
    RegionInfo* next = del->GetNextRegion();

    del->SetNextRegion(nullptr);
    del->SetPrevRegion(nullptr);

    DLOG(REGION, "list %p (%zu, %zu)-(%zu, %zu) delete region %p@[%#zx+%zu, %#zx) type %u", this,
        regionCount, unitCount, 1llu, del->GetUnitCount(),
        del, del->GetRegionStart(), del->GetRegionAllocatedSize(), del->GetRegionEnd(), del->GetRegionType());

    DecCounts(1, del->GetUnitCount());

    if (listHead == del) { // delete head
        MRT_ASSERT(pre == nullptr, "Delete Region pre is not null");
        listHead = next;
        if (listHead == nullptr) { // now empty
            listTail = nullptr;
            return;
        }
    } else {
        pre->SetNextRegion(next);
    }

    if (listTail == del) { // delete tail
        MRT_ASSERT(next == nullptr, "Delete Region next is not null");
        listTail = pre;
        if (listTail == nullptr) { // now empty
            listHead = nullptr;
            return;
        }
    } else {
        next->SetPrevRegion(pre);
    }
}

#ifdef MRT_DEBUG
void RegionList::DumpRegionList(const char* msg)
{
    DLOG(REGION, "dump region list %s", msg);
    std::lock_guard<std::mutex> lock(listMutex);
    for (RegionInfo *region = listHead; region != nullptr; region = region->GetNextRegion()) {
        DLOG(REGION, "region %p @[0x%zx+%zu, 0x%zx) units [%zu+%zu, %zu) type %u prev %p next %p", region,
            region->GetRegionStart(), region->GetRegionAllocatedSize(), region->GetRegionEnd(),
            region->GetUnitIdx(), region->GetUnitCount(), region->GetUnitIdx() + region->GetUnitCount(),
            region->GetRegionType(), region->GetPrevRegion(), region->GetNextRegion());
    }
}
#endif
inline void RegionManager::TagHugePage(RegionInfo* region, size_t num) const
{
#if defined (__linux__) || defined(__OHOS__) || defined(__ANDROID__)
    (void)madvise(reinterpret_cast<void*>(region->GetRegionStart()), num * RegionInfo::UNIT_SIZE, MADV_HUGEPAGE);
#else
    (void)region;
    (void)num;
#endif
}

inline void RegionManager::UntagHugePage(RegionInfo* region, size_t num) const
{
#if defined (__linux__) || defined(__OHOS__) || defined(__ANDROID__)
    (void)madvise(reinterpret_cast<void*>(region->GetRegionStart()), num * RegionInfo::UNIT_SIZE, MADV_NOHUGEPAGE);
#else
    (void)region;
    (void)num;
#endif
}

size_t FreeRegionManager::ReleaseGarbageRegions(size_t targetCachedSize)
{
    size_t dirtyBytes = dirtyUnitTree.GetTotalCount() * RegionInfo::UNIT_SIZE;
    if (dirtyBytes <= targetCachedSize) {
        VLOG(REPORT, "release heap garbage memory 0 bytes, cache %zu(%zu) bytes", dirtyBytes, targetCachedSize);
        return 0;
    }

    size_t releasedBytes = 0;
    while (dirtyBytes > targetCachedSize) {
        std::lock_guard<std::mutex> lock1(dirtyUnitTreeMutex);
        auto node = dirtyUnitTree.RootNode();
        if (node == nullptr) { break; }
        Index idx = node->GetIndex();
        UnitCount num = node->GetCount();
        dirtyUnitTree.ReleaseRootNode();

        std::lock_guard<std::mutex> lock2(releasedUnitTreeMutex);
        CHECK_DETAIL(releasedUnitTree.MergeInsert(idx, num, true), "tid %d: failed to release garbage units[%u+%u, %u)",
                     GetTid(), idx, num, idx + num);
        releasedBytes += (num * RegionInfo::UNIT_SIZE);
        dirtyBytes = dirtyUnitTree.GetTotalCount() * RegionInfo::UNIT_SIZE;
    }
    VLOG(REPORT, "release heap garbage memory %zu bytes, cache %zu(%zu) bytes",
         releasedBytes, dirtyBytes, targetCachedSize);
    return releasedBytes;
}

void RegionManager::SetMaxUnitCountForRegion()
{
    maxUnitCountPerRegion = CangjieRuntime::GetHeapParam().regionSize * KB / RegionInfo::UNIT_SIZE;
}

void RegionManager::SetMaxUnitCountForPinnedRegion()
{
    auto env = std::getenv("cjPinnedRegionSize");
    if (env == nullptr) {
        maxUnitCountPerPinnedRegion = maxUnitCountPerRegion;
        return;
    }
    size_t size = CString::ParseSizeFromEnv(env);
    // The minimum region size is system page size, measured in KB.
    size_t minSize = MapleRuntime::MRT_PAGE_SIZE / KB;
    if (size >= minSize && size <= CangjieRuntime::GetHeapParam().regionSize) {
        maxUnitCountPerPinnedRegion = size * KB / RegionInfo::UNIT_SIZE;
    } else {
        LOG(RTLOG_ERROR, "Unsupported cjPinnedRegionSize parameter. Valid cjPinnedRegionSize"
            "range is [%zuKB, %zuKB].\n", minSize, CangjieRuntime::GetHeapParam().regionSize);
    }
}

void RegionManager::SetLargeObjectThreshold()
{
    auto env = std::getenv("cjLargeThresholdSize");
    if (env == nullptr) {
        // default value is 32 KB
        largeObjectThreshold = 32 * KB;
    }
    size_t size = CString::ParseSizeFromEnv(env);
    // The minimum region size is system page size, measured in KB.
    size_t minSize = MapleRuntime::MRT_PAGE_SIZE / KB;
    // 64UL: The maximum region size, measured in KB, the value is 2048 KB.
    size_t maxSize = 10 * 1024UL;
    if (size >= minSize && size <= maxSize) {
        largeObjectThreshold = size * KB;
    } else if (size != 0) {
        LOG(RTLOG_ERROR, "Unsupported cjLargeThresholdSize parameter. Valid cjLargeThresholdSize"
            "range is [%zuKB, 2048KB].\n", minSize);
    }
    size_t regionSize = CangjieRuntime::GetHeapParam().regionSize * KB;
    largeObjectThreshold = largeObjectThreshold > regionSize ? regionSize :  largeObjectThreshold;
}

void RegionManager::SetGarbageThreshold()
{
    fromSpaceGarbageThreshold = CangjieRuntime::GetGCParam().garbageThreshold;
}

#if defined(__EULER__)
void RegionManager::SetCacheRatio(double minSize, double maxSize, double defaultParam)
{
    auto env = std::getenv("cjCacheRatio");
    if (env == nullptr) {
        cacheRatio = defaultParam;
        return;
    }
    double size = CString::ParsePosDecFromEnv(env);
    if (size - minSize >= 0 && maxSize - size >= 0) {
        cacheRatio = size;
        return;
    } else {
        LOG(RTLOG_ERROR, "Unsupported cjCacheRatio parameter.Valid cjCacheRatio range is [%f, %f].\n",
            minSize, maxSize);
    }
    cacheRatio = defaultParam;
}
#endif

void RegionManager::Initialize(size_t nUnit, uintptr_t regionInfoAddr)
{
    size_t metadataSize = GetMetadataSize(nUnit);
#ifdef _WIN64
    MemMap::CommitMemory(reinterpret_cast<void*>(regionInfoAddr), metadataSize);
#endif
    this->regionInfoStart = regionInfoAddr;
    this->regionHeapStart = regionInfoAddr + metadataSize;
    this->regionHeapEnd = regionHeapStart + nUnit * RegionInfo::UNIT_SIZE;
    this->inactiveZone = regionHeapStart;
    SetMaxUnitCountForRegion();
    SetMaxUnitCountForPinnedRegion();
    SetLargeObjectThreshold();
    SetGarbageThreshold();
#if defined(__EULER__)
    SetCacheRatio(0.0, 1.0, 1.0);
#endif
    // propagate region heap layout
    RegionInfo::Initialize(nUnit, regionHeapStart);
    freeRegionManager.Initialize(nUnit);
    this->exemptedRegionThreshold = CangjieRuntime::GetHeapParam().exemptionThreshold;
    DLOG(REPORT, "region info @0x%zx+%zu, heap [0x%zx, 0x%zx), unit count %zu", regionInfoAddr, metadataSize,
         regionHeapStart, regionHeapEnd, nUnit);
}

void RegionManager::ReclaimRegion(RegionInfo* region)
{
    size_t num = region->GetUnitCount();
    size_t unitIndex = region->GetUnitIdx();
    if (num >= HUGE_PAGE) {
        UntagHugePage(region, num);
    }
    DLOG(REGION, "reclaim region %p @[%#zx+%zu, %#zx) type %u", region, region->GetRegionStart(),
        region->GetRegionAllocatedSize(), region->GetRegionEnd(), region->GetRegionType());

    region->InitFreeUnits();
    freeRegionManager.AddGarbageUnits(unitIndex, num);
}

size_t RegionManager::ReleaseRegion(RegionInfo* region)
{
    size_t res = region->GetRegionSize();
    size_t num = region->GetUnitCount();
    size_t unitIndex = region->GetUnitIdx();
    if (num >= HUGE_PAGE) {
        UntagHugePage(region, num);
    }
    DLOG(REGION, "release region %p @[%#zx+%zu, %#zx) type %u", region, region->GetRegionStart(),
        region->GetRegionAllocatedSize(), region->GetRegionEnd(), region->GetRegionType());

    region->InitFreeUnits();
    RegionInfo::ReleaseUnits(unitIndex, num);
    freeRegionManager.AddReleaseUnits(unitIndex, num);
    return res;
}

void RegionManager::ReassembleFromSpace()
{
    fromRegionList.MergeRegionList(unmovableFromRegionList, RegionInfo::RegionType::FROM_REGION);
}

void RegionManager::CountLiveObject(const BaseObject* obj)
{
    RegionInfo* region = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
    region->AddLiveByteCount(obj->GetSize());
}

void RegionManager::AssembleSmallGarbageCandidates()
{
    fromRegionList.MergeRegionList(rawPointerPinnedRegionList, RegionInfo::RegionType::FROM_REGION);
    fromRegionList.MergeRegionList(recentFullRegionList, RegionInfo::RegionType::FROM_REGION);
    fromRegionList.MergeRegionList(unmovableFromRegionList, RegionInfo::RegionType::FROM_REGION);

    fromRegionList.VisitAllRegions([](RegionInfo* region) { region->ClearLiveInfo(); });
}

void RegionManager::AssembleLargeGarbageCandidates()
{
    oldLargeRegionList.MergeRegionList(recentLargeRegionList, RegionInfo::RegionType::LARGE_REGION);
    for (RegionInfo* region = oldLargeRegionList.GetHeadRegion(); region != nullptr; region = region->GetNextRegion()) {
        region->ClearLiveInfo();
    }
}

void RegionManager::AssemblePinnedGarbageCandidates(bool collectAll)
{
    oldPinnedRegionList.MergeRegionList(recentPinnedRegionList, RegionInfo::RegionType::FULL_PINNED_REGION);
    RegionInfo* region = oldPinnedRegionList.GetHeadRegion();
    while (region != nullptr) {
        RegionInfo* nextRegion = region->GetNextRegion();
        if (collectAll && (region->GetRawPointerObjectCount() > 0)) {
            oldPinnedRegionList.DeleteRegion(region);
            rawPointerPinnedRegionList.PrependRegion(region, RegionInfo::RegionType::RAW_POINTER_PINNED_REGION);
        }
        region->ClearLiveInfo();
        region = nextRegion;
    }
}
void RemoveRegionLocked(RegionList* regionList, RegionInfo* region)
{
    regionList->DeleteRegionLocked(region);
}

// forward only regions whose garbage bytes is greater than or equal to exemptedRegionThreshold.
size_t RegionManager::ExemptFromRegions()
{
    size_t forwardBytes = 0;
    size_t floatingGarbage = 0;
    size_t oldFromBytes = fromRegionList.GetUnitCount() * RegionInfo::UNIT_SIZE;
    double exempt = exemptedRegionThreshold;
    auto visitor = [this, exempt, &floatingGarbage](RegionInfo* fromRegion) {
        size_t threshold = static_cast<size_t>(exempt * fromRegion->GetRegionSize());
        size_t liveBytes = fromRegion->GetLiveByteCount();
        long rawPtrCnt = fromRegion->GetRawPointerObjectCount();
        if (liveBytes > threshold) { // ignore this region
            RegionInfo* del = fromRegion;
            DLOG(REGION, "region %p @[0x%zx+%zu, 0x%zx) exempted by forwarding: %zu units, %u live bytes", del,
                del->GetRegionStart(), del->GetRegionAllocatedSize(), del->GetRegionEnd(),
                del->GetUnitCount(), del->GetLiveByteCount());

            CHECK(del->IsFromRegion());
            RemoveRegionLocked(&fromRegionList, del);
            ExemptFromRegion(del);
            floatingGarbage += (del->GetRegionSize() - del->GetLiveByteCount());
        } else if (rawPtrCnt > 0) {
            RegionInfo* del = fromRegion;
            DLOG(REGION, "region %p @[0x%zx+%zu, 0x%zx) pinned by forwarding: %zu units, %u live bytes rawPtr cnt %u",
                del, del->GetRegionStart(), del->GetRegionAllocatedSize(), del->GetRegionEnd(),
                del->GetUnitCount(), del->GetLiveByteCount(), rawPtrCnt);
            CHECK(del->IsFromRegion());
            RemoveRegionLocked(&fromRegionList, del);
            rawPointerPinnedRegionList.PrependRegion(del, RegionInfo::RegionType::RAW_POINTER_PINNED_REGION);
            floatingGarbage += (del->GetRegionSize() - del->GetLiveByteCount());
        }
    };
    fromRegionList.VisitAllRegions(visitor);

    size_t newFromBytes = fromRegionList.GetUnitCount() * RegionInfo::UNIT_SIZE;
    size_t exemptedFromBytes = unmovableFromRegionList.GetUnitCount() * RegionInfo::UNIT_SIZE;
    VLOG(REPORT, "exempt from-space: %zu B - %zu B -> %zu B, %zu B floating garbage, %zu B to forward",
         oldFromBytes, exemptedFromBytes, newFromBytes, floatingGarbage, forwardBytes);
    return newFromBytes - forwardBytes;
}

void RegionManager::ForEachObjUnsafe(const std::function<void(BaseObject*)>& visitor) const
{
    for (uintptr_t regionAddr = regionHeapStart; regionAddr < inactiveZone;) {
        RegionInfo* region = RegionInfo::GetRegionInfoAt(regionAddr);
        regionAddr = region->GetRegionEnd();
        if (!region->IsValidRegion() || region->IsFreeRegion() || region -> IsGarbageRegion()) {
            continue;
        }
        region->VisitAllObjects([&visitor](BaseObject* object) { visitor(object); });
    }
}

void RegionManager::ForEachObjSafe(const std::function<void(BaseObject*)>& visitor) const
{
    ScopedEnterSaferegion enterSaferegion(false);
    ScopedStopTheWorld stw("visit all objects");
    ForEachObjUnsafe(visitor);
}

RegionInfo* RegionManager::TakeRegion(size_t num, RegionInfo::UnitRole type, bool expectPhysicalMem)
{
    // a chance to invoke heuristic gc.
    if (!Heap::GetHeap().IsGcStarted()) {
        Collector& collector = Heap::GetHeap().GetCollector();
        size_t threshold = collector.GetGCStats().GetThreshold();
        size_t allocated = Heap::GetHeap().GetAllocator().AllocatedBytes();
        if (allocated >= threshold) {
            DLOG(ALLOC, "request heu gc: allocated %zu, threshold %zu", allocated, threshold);
            collector.RequestGC(GC_REASON_HEU, true);
        }
    }

    // check for allocation since we do not want gc threads and mutators do any harm to each other.
    size_t size = num * RegionInfo::UNIT_SIZE;
    RequestForRegion(size);

#if !defined(__OHOS__)
    RegionInfo* head = garbageRegionList.TakeHeadRegion();
    if (head != nullptr) {
        DLOG(REGION, "take garbage region %p@[%#zx, %#zx)", head, head->GetRegionStart(), head->GetRegionEnd());
        if (head->GetUnitCount() == num) {
            auto idx = head->GetUnitIdx();
            RegionInfo::ClearUnits(idx, num);
            DLOG(REGION, "reuse garbage region %p@[%#zx, %#zx)", head, head->GetRegionStart(), head->GetRegionEnd());
            return RegionInfo::InitRegion(idx, num, type);
        } else {
            DLOG(REGION, "reclaim garbage region %p@[%#zx, %#zx)", head, head->GetRegionStart(), head->GetRegionEnd());
            ReclaimRegion(head);
        }
    }
#endif

    RegionInfo* region = freeRegionManager.TakeRegion(num, type, expectPhysicalMem);
    if (region != nullptr) {
        if (num >= HUGE_PAGE) {
            TagHugePage(region, num);
        }
        return region;
    }

    // when free regions are not enough for allocation
    if (num <= GetInactiveUnitCount()) {
        uintptr_t addr = inactiveZone.fetch_add(size);
        if (addr < regionHeapEnd - size) {
            region = RegionInfo::InitRegionAt(addr, num, type);
            size_t idx = region->GetUnitIdx();
#ifdef _WIN64
            MemMap::CommitMemory(
                reinterpret_cast<void*>(RegionInfo::GetUnitAddress(idx)), num * RegionInfo::UNIT_SIZE);
#endif
            (void)idx; // eliminate compilation warning
            DLOG(REGION, "take inactive units [%zu+%zu, %zu) at [0x%zx, 0x%zx)", idx, num, idx + num,
                 RegionInfo::GetUnitAddress(idx), RegionInfo::GetUnitAddress(idx + num));
            if (num >= HUGE_PAGE) {
                TagHugePage(region, num);
            }
            if (expectPhysicalMem) {
                RegionInfo::ClearUnits(idx, num);
            }
            return region;
        } else {
            (void)inactiveZone.fetch_sub(size);
        }
    }

    return nullptr;
}

void RegionManager::ForwardFromRegions(GCThreadPool* threadPool)
{
    if (threadPool != nullptr) {
        int32_t threadNum = threadPool->GetMaxThreadNum() + 1;
        // We won't change fromRegionList during gc, so we can use it without lock.
        size_t regionCount = fromRegionList.GetRegionCount();
        if (UNLIKELY(regionCount == 0)) {
            return;
        }

        // we start threadPool before adding work so that we can concurrently add tasks;
        threadPool->Start();
        for (int32_t i = 0; i < threadNum; ++i) {
            threadPool->AddWork(new (std::nothrow) ForwardTask(*this, fromRegionList));
        }
        threadPool->WaitFinish();
    } else {
        ForwardFromRegions();
    }
}

void RegionManager::ExemptFromRegion(RegionInfo* region)
{
    unmovableFromRegionList.PrependRegion(region, RegionInfo::RegionType::UNMOVABLE_FROM_REGION);
}

void RegionManager::ForwardFromRegions()
{
    RegionInfo* fromRegion = fromRegionList.GetHeadRegion();
    while (fromRegion != nullptr) {
        MRT_ASSERT(fromRegion->IsValidRegion(), "the head region of fromRegionList is invalid");
        RegionInfo* region = fromRegion;
        fromRegion = fromRegion->GetNextRegion();
        ForwardRegion(region);
    }

    VLOG(REPORT, "forward %zu from-region units", fromRegionList.GetUnitCount());

    AllocBuffer* allocBuffer = AllocBuffer::GetAllocBuffer();
    if (LIKELY(allocBuffer != nullptr)) {
        allocBuffer->ClearRegion(); // clear region for next GC
    }
}

size_t RegionManager::CollectFreePinnedSlots(RegionInfo* region)
{
    // traverse pinned region to reclaim free pinned objects.
    size_t start = region->GetRegionStart();
    size_t garbageSize = 0;
    region->VisitAllObjects([this, region, start, &garbageSize](BaseObject* object) {
        size_t offset = reinterpret_cast<MAddress>(object) - start;
        if (!region->IsSurvivedObject(offset)) {
            size_t objSize = object->GetSize();
            DLOG(ALLOC, "reclaim pinned obj %p<%p>(%zu)", object, object->GetTypeInfo(), objSize);
            garbageSize += objSize;
            std::lock_guard<std::mutex> lock(freePinnedSlotListMutex);
            ReleaseNativeResource(object);
            freePinnedSlotLists.PushFront(object);
        }
    });
    return garbageSize;
}

size_t RegionManager::CollectPinnedGarbage()
{
    {
        std::lock_guard<std::mutex> lock(freePinnedSlotListMutex);
        freePinnedSlotLists.Clear();
    }
    size_t garbageSize = 0;
    RegionInfo* region = oldPinnedRegionList.GetHeadRegion();
    while (region != nullptr) {
        if (region->GetLiveByteCount() == 0) {
            RegionInfo* del = region;
            region = region->GetNextRegion();
            oldPinnedRegionList.DeleteRegion(del);

            auto fixToObj = [](BaseObject* obj) { ReleaseNativeResource(obj); };
            del->VisitAllObjects(fixToObj);

            garbageSize += CollectRegion(del);
            continue;
        } else {
            garbageSize += CollectFreePinnedSlots(region);
            region = region->GetNextRegion();
        }
    }
    return garbageSize;
}

size_t RegionManager::CollectLargeGarbage()
{
    size_t garbageSize = 0;
    RegionInfo* region = oldLargeRegionList.GetHeadRegion();
    while (region != nullptr) {
        // for large region, the offset of obj is 0
        if (!region->IsSurvivedObject(0)) {
            DLOG(REGION, "reclaim large region %p@[0x%zx+%zu, 0x%zx) type %u", region, region->GetRegionStart(),
                 region->GetRegionAllocatedSize(), region->GetRegionEnd(), region->GetRegionType());

            RegionInfo* del = region;
            region = region->GetNextRegion();
            oldLargeRegionList.DeleteRegion(del);
            if (del->GetRegionSize() > RegionInfo::LARGE_OBJECT_RELEASE_THRESHOLD) {
                garbageSize += ReleaseRegion(del);
            } else {
                garbageSize += CollectRegion(del);
            }
        } else {
            region->ResetMarkBit();
            region = region->GetNextRegion();
        }
    }

    region = recentLargeRegionList.GetHeadRegion();
    while (region != nullptr) {
        region->ResetMarkBit();
        region = region->GetNextRegion();
    }

    return garbageSize;
}

#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
void RegionManager::DumpRegionInfo() const
{
    if (!ENABLE_LOG(ALLOC)) {
        return;
    }
    for (uintptr_t regionAddr = regionHeapStart; regionAddr < inactiveZone;) {
        RegionInfo* region = RegionInfo::GetRegionInfoAt(regionAddr);
        regionAddr = region->GetRegionEnd();
        if (!region->IsFreeRegion()) {
            region->DumpRegionInfo(ALLOC);
        }
    }
}
#endif

void RegionManager::DumpRegionStats(const char* msg, bool dumpToError) const
{
    size_t totalSize = regionHeapEnd - regionHeapStart;
    size_t totalUnits = totalSize / RegionInfo::UNIT_SIZE;
    size_t activeSize = inactiveZone - regionHeapStart;
    size_t activeUnits = activeSize / RegionInfo::UNIT_SIZE;

    size_t tlRegions = tlRegionList.GetRegionCount();
    size_t tlUnits = tlRegionList.GetUnitCount();
    size_t tlSize = tlUnits * RegionInfo::UNIT_SIZE;
    size_t allocTLSize = tlRegionList.GetAllocatedSize();

    size_t fromRegions = fromRegionList.GetRegionCount();
    size_t fromUnits = fromRegionList.GetUnitCount();
    size_t fromSize = fromUnits * RegionInfo::UNIT_SIZE;
    size_t allocFromSize = fromRegionList.GetAllocatedSize();

    size_t recentFullRegions = recentFullRegionList.GetRegionCount();
    size_t recentFullUnits = recentFullRegionList.GetUnitCount();
    size_t recentFullSize = recentFullUnits * RegionInfo::UNIT_SIZE;
    size_t allocRecentFullSize = recentFullRegionList.GetAllocatedSize();

    size_t garbageRegions = garbageRegionList.GetRegionCount();
    size_t garbageUnits = garbageRegionList.GetUnitCount();
    size_t garbageSize = garbageUnits * RegionInfo::UNIT_SIZE;
    size_t allocGarbageSize = garbageRegionList.GetAllocatedSize();

    size_t pinnedRegions = oldPinnedRegionList.GetRegionCount();
    size_t pinnedUnits = oldPinnedRegionList.GetUnitCount();
    size_t pinnedSize = pinnedUnits * RegionInfo::UNIT_SIZE;
    size_t allocPinnedSize = oldPinnedRegionList.GetAllocatedSize();

    size_t recentPinnedRegions = recentPinnedRegionList.GetRegionCount();
    size_t recentPinnedUnits = recentPinnedRegionList.GetUnitCount();
    size_t recentPinnedSize = recentPinnedUnits * RegionInfo::UNIT_SIZE;
    size_t allocRecentPinnedSize = recentPinnedRegionList.GetAllocatedSize();

    size_t rawPointerPinnedRegions = rawPointerPinnedRegionList.GetRegionCount();
    size_t rawPointerPinnedUnits = rawPointerPinnedRegionList.GetUnitCount();
    size_t rawPointerPinnedSize = rawPointerPinnedUnits * RegionInfo::UNIT_SIZE;
    size_t allocRawPointerPinnedSize = rawPointerPinnedRegionList.GetAllocatedSize();

    size_t largeRegions = oldLargeRegionList.GetRegionCount();
    size_t largeUnits = oldLargeRegionList.GetUnitCount();
    size_t largeSize = largeUnits * RegionInfo::UNIT_SIZE;
    size_t allocLargeSize = oldLargeRegionList.GetAllocatedSize();

    size_t recentlargeRegions = recentLargeRegionList.GetRegionCount();
    size_t recentlargeUnits = recentLargeRegionList.GetUnitCount();
    size_t recentLargeSize = recentlargeUnits * RegionInfo::UNIT_SIZE;
    size_t allocRecentLargeSize = recentLargeRegionList.GetAllocatedSize();

    size_t allHeapSize = regionHeapEnd - regionHeapStart;
    size_t allUnits = allHeapSize / RegionInfo::UNIT_SIZE;
    size_t inactiveUnits = (regionHeapEnd - inactiveZone) / RegionInfo::UNIT_SIZE;
    
    size_t usedUnitCount = GetUsedUnitCount();
    size_t usedObjSize = GetAllocatedSize();
    size_t releasedUnits = freeRegionManager.GetReleasedUnitCount();
    size_t dirtyUnits = freeRegionManager.GetDirtyUnitCount();
    size_t dirtySize = dirtyUnits * RegionInfo::UNIT_SIZE;

    size_t totalUnitCount = usedUnitCount + garbageUnits + dirtyUnits;
    size_t totalObjSize = usedObjSize + garbageSize + dirtyUnits * RegionInfo::UNIT_SIZE;

    double objectCapacity = (allHeapSize > 0) ? static_cast<double>(totalObjSize) / allHeapSize : 0.0;
    double unitCapacity = (allUnits > 0) ? static_cast<double>(totalUnitCount) / allUnits : 0.0;
    double usedObjectCapacity = (allHeapSize > 0) ? static_cast<double>(usedObjSize) / allHeapSize : 0.0;
    double usedUnitCapacity = (allUnits > 0) ? static_cast<double>(usedUnitCount) / allUnits : 0.0;
    double objFragRate = 1.0 - objectCapacity;
    double unitFragRate = 1.0 - unitCapacity;
    double usedObjFragRate = 1.0 - usedObjectCapacity;
    double usedUnitFragRate = 1.0 - usedUnitCapacity;

#define DUMP_REGION_STATS_LOG(format, ...)                  \
    do {                                                    \
        VLOG(REPORT, format, ##__VA_ARGS__);                \
        if (dumpToError) {                                  \
            LOG(RTLOG_ERROR, format, ##__VA_ARGS__);        \
        }                                                   \
    } while (false)

    DUMP_REGION_STATS_LOG("%s", msg);

    DUMP_REGION_STATS_LOG("\ttotal units: %zu (%zu B)", totalUnits, totalSize);
    DUMP_REGION_STATS_LOG("\tactive units: %zu (%zu B)", activeUnits, activeSize);
    DUMP_REGION_STATS_LOG("\tinactive units: %zu (%zu B)", inactiveUnits, inactiveUnits * RegionInfo::UNIT_SIZE);

    DUMP_REGION_STATS_LOG("\ttl-regions %zu: %zu units (%zu B, alloc %zu)", tlRegions,  tlUnits, tlSize, allocTLSize);
    DUMP_REGION_STATS_LOG("\tfrom-regions %zu: %zu units (%zu B, alloc %zu)", fromRegions,  fromUnits, fromSize,
                          allocFromSize);
    DUMP_REGION_STATS_LOG("\trecent-full regions %zu: %zu units (%zu B, alloc %zu)",
                          recentFullRegions, recentFullUnits, recentFullSize, allocRecentFullSize);
    DUMP_REGION_STATS_LOG("\tgarbage regions %zu: %zu units (%zu B, alloc %zu)",
                          garbageRegions, garbageUnits, garbageSize, allocGarbageSize);
    DUMP_REGION_STATS_LOG("\tpinned regions %zu: %zu units (%zu B, alloc %zu)",
                          pinnedRegions, pinnedUnits, pinnedSize, allocPinnedSize);
    DUMP_REGION_STATS_LOG("\trecent pinned regions %zu: %zu units (%zu B, alloc %zu)",
                          recentPinnedRegions, recentPinnedUnits, recentPinnedSize, allocRecentPinnedSize);
    DUMP_REGION_STATS_LOG("\trawPointer pinned regions %zu: %zu units (%zu B, alloc %zu)",
                          rawPointerPinnedRegions, rawPointerPinnedUnits, rawPointerPinnedSize,
                          allocRawPointerPinnedSize);
    DUMP_REGION_STATS_LOG("\tlarge-object regions %zu: %zu units (%zu B, alloc %zu)",
                          largeRegions, largeUnits, largeSize, allocLargeSize);
    DUMP_REGION_STATS_LOG("\trecent large-object regions %zu: %zu units (%zu B, alloc %zu)",
                          recentlargeRegions, recentlargeUnits, recentLargeSize, allocRecentLargeSize);
    DUMP_REGION_STATS_LOG("\tused summary: usedUnits %zu (%zu B), usedObjSize %zu B",
                          usedUnitCount, usedUnitCount * RegionInfo::UNIT_SIZE, usedObjSize);

    size_t releasedMaxBlock = freeRegionManager.GetReleasedMaxBlock();
    size_t dirtyMaxBlock = freeRegionManager.GetDirtyMaxBlock();
    size_t releasedNodeCount = freeRegionManager.GetReleasedNodeCount();
    size_t dirtyNodeCount = freeRegionManager.GetDirtyNodeCount();
    DUMP_REGION_STATS_LOG("\treleased units: %zu (%zu B), nodes: %zu, maxBlock: %zu units (%zu B)",
                          releasedUnits, releasedUnits * RegionInfo::UNIT_SIZE,
                          releasedNodeCount,
                          releasedMaxBlock, releasedMaxBlock * RegionInfo::UNIT_SIZE);
    DUMP_REGION_STATS_LOG("\tdirty units: %zu (%zu B), nodes: %zu, maxBlock: %zu units (%zu B)",
                          dirtyUnits, dirtyUnits * RegionInfo::UNIT_SIZE, dirtyNodeCount,
                          dirtyMaxBlock,
                          dirtyMaxBlock * RegionInfo::UNIT_SIZE);

    DUMP_REGION_STATS_LOG("\tgarbage+dirty summary: garbageUnits %zu (%zu B, allocObj %zu), dirtyUnits %zu (%zu B)",
                          garbageUnits, garbageSize, allocGarbageSize, dirtyUnits, dirtySize);
    DUMP_REGION_STATS_LOG("\tobjectCapacity: %.4f (totalObjSize %zu / allHeapSize %zu), objFragRate: %.4f",
                          objectCapacity, totalObjSize, allHeapSize, objFragRate);
    DUMP_REGION_STATS_LOG("\tunitCapacity: %.4f (totalUnitCount %zu / allUnits %zu), unitFragRate: %.4f",
                          unitCapacity, totalUnitCount, allUnits, unitFragRate);
    DUMP_REGION_STATS_LOG("\tusedObjectCapacity: %.4f (usedObjSize %zu / allHeapSize %zu), usedObjFragRate: %.4f",
                          usedObjectCapacity, usedObjSize, allHeapSize, usedObjFragRate);
    DUMP_REGION_STATS_LOG("\tusedUnitCapacity: %.4f (usedUnitCount %zu / allUnits %zu), usedUnitFragRate: %.4f",
                          usedUnitCapacity, usedUnitCount, allUnits, usedUnitFragRate);
#undef DUMP_REGION_STATS_LOG

    TRACE_COUNT("CJRT_GC_totalSize", totalSize);
    TRACE_COUNT("CJRT_GC_totalUnits", totalUnits);
    TRACE_COUNT("CJRT_GC_activeSize", activeSize);
    TRACE_COUNT("CJRT_GC_activeUnits", activeUnits);
    TRACE_COUNT("CJRT_GC_tlRegions", tlRegions);
    TRACE_COUNT("CJRT_GC_tlUnits", tlUnits);
    TRACE_COUNT("CJRT_GC_tlSize", tlSize);
    TRACE_COUNT("CJRT_GC_allocTLSize", allocTLSize);
    TRACE_COUNT("CJRT_GC_fromRegions", fromRegions);
    TRACE_COUNT("CJRT_GC_fromUnits", fromUnits);
    TRACE_COUNT("CJRT_GC_fromSize", fromSize);
    TRACE_COUNT("CJRT_GC_allocFromSize", allocFromSize);
    TRACE_COUNT("CJRT_GC_recentFullRegions", recentFullRegions);
    TRACE_COUNT("CJRT_GC_recentFullUnits", recentFullUnits);
    TRACE_COUNT("CJRT_GC_recentFullSize", recentFullSize);
    TRACE_COUNT("CJRT_GC_allocRecentFullSize", allocRecentFullSize);
    TRACE_COUNT("CJRT_GC_garbageRegions", garbageRegions);
    TRACE_COUNT("CJRT_GC_garbageUnits", garbageUnits);
    TRACE_COUNT("CJRT_GC_garbageSize", garbageSize);
    TRACE_COUNT("CJRT_GC_allocGarbageSize", allocGarbageSize);
    TRACE_COUNT("CJRT_GC_pinnedRegions", pinnedRegions);
    TRACE_COUNT("CJRT_GC_pinnedUnits", pinnedUnits);
    TRACE_COUNT("CJRT_GC_pinnedSize", pinnedSize);
    TRACE_COUNT("CJRT_GC_allocPinnedSize", allocPinnedSize);
    TRACE_COUNT("CJRT_GC_recentPinnedRegions", recentPinnedRegions);
    TRACE_COUNT("CJRT_GC_recentPinnedUnits", recentPinnedUnits);
    TRACE_COUNT("CJRT_GC_recentPinnedSize", recentPinnedSize);
    TRACE_COUNT("CJRT_GC_allocRecentPinnedSize", allocRecentPinnedSize);
    TRACE_COUNT("CJRT_GC_rawPointerPinnedRegions", rawPointerPinnedRegions);
    TRACE_COUNT("CJRT_GC_rawPointerPinnedUnits", rawPointerPinnedUnits);
    TRACE_COUNT("CJRT_GC_rawPointerPinnedSize", rawPointerPinnedSize);
    TRACE_COUNT("CJRT_GC_allocRawPointerPinnedSize", allocRawPointerPinnedSize);
    TRACE_COUNT("CJRT_GC_largeRegions", largeRegions);
    TRACE_COUNT("CJRT_GC_largeUnits", largeUnits);
    TRACE_COUNT("CJRT_GC_largeSize", largeSize);
    TRACE_COUNT("CJRT_GC_allocLargeSize", allocLargeSize);
    TRACE_COUNT("CJRT_GC_recentlargeRegions", recentlargeRegions);
    TRACE_COUNT("CJRT_GC_recentlargeUnits", recentlargeUnits);
    TRACE_COUNT("CJRT_GC_recentLargeSize", recentLargeSize);
    TRACE_COUNT("CJRT_GC_allocRecentLargeSize", allocRecentLargeSize);
    TRACE_COUNT("CJRT_GC_usedUnits", usedUnitCount);
    TRACE_COUNT("CJRT_GC_releasedUnits", releasedUnits);
    TRACE_COUNT("CJRT_GC_dirtyUnits", dirtyUnits);
    TRACE_COUNT("CJRT_GC_listedUnits", totalUnitCount);
    [[maybe_unused]] constexpr size_t decimalPrecision = 10000;
    TRACE_COUNT("CJRT_GC_objectCapacity", static_cast<size_t>(objectCapacity * decimalPrecision));
    TRACE_COUNT("CJRT_GC_unitCapacity", static_cast<size_t>(unitCapacity * decimalPrecision));
}

RegionInfo* RegionManager::AllocateThreadLocalRegion(bool expectPhysicalMem)
{
    RegionInfo* region = TakeRegion(maxUnitCountPerRegion, RegionInfo::UnitRole::SMALL_SIZED_UNITS, expectPhysicalMem);
    if (region != nullptr) {
        {
            GCPhase phase = Heap::GetHeap().GetCollector().GetGCPhase();
            if (phase == GC_PHASE_TRACE || phase == GC_PHASE_CLEAR_SATB_BUFFER) {
                region->SetTraceRegionFlag(1);
            }
            tlRegionList.PrependRegion(region, RegionInfo::RegionType::THREAD_LOCAL_REGION);
            DLOG(REGION, "alloc tl-region %p @[0x%zx+%zu, 0x%zx) units[%zu+%zu, %zu) type %u",
                region, region->GetRegionStart(), region->GetRegionSize(), region->GetRegionEnd(),
                region->GetUnitIdx(), region->GetUnitCount(), region->GetUnitIdx() + region->GetUnitCount(),
                region->GetRegionType());
        }
    }

    return region;
}

void RegionManager::RequestForRegion(size_t size)
{
    if (IsGcThread()) {
        // gc thread is always permitted for allocation.
        return;
    }

    Heap& heap = Heap::GetHeap();
    GCStats& gcstats = heap.GetCollector().GetGCStats();
    size_t allocatedBytes = GetAllocatedSize() - gcstats.liveBytesAfterGC;
    constexpr double pi = 3.14;
    size_t availableBytesAfterGC = heap.GetMaxCapacity() - gcstats.liveBytesAfterGC;
    double heuAllocRate = std::cos((pi / 2.0) * allocatedBytes / availableBytesAfterGC) * gcstats.collectionRate;
    // for maximum performance, choose the larger one.
    double allocRate = std::max(
        static_cast<double>(CangjieRuntime::GetHeapParam().allocationRate) * MB / SECOND_TO_NANO_SECOND, heuAllocRate);
    size_t waitTime = static_cast<size_t>(size / allocRate);
    uint64_t now = TimeUtil::NanoSeconds();
    if (prevRegionAllocTime + waitTime <= now) {
        prevRegionAllocTime = TimeUtil::NanoSeconds();
        return;
    }

    uint64_t sleepTime = std::min<uint64_t>(CangjieRuntime::GetHeapParam().allocationWaitTime,
                                  prevRegionAllocTime + waitTime - now);
    DLOG(ALLOC, "wait %zu ns to alloc %zu(B)", sleepTime, size);
    std::this_thread::sleep_for(std::chrono::nanoseconds{ sleepTime });
    prevRegionAllocTime = TimeUtil::NanoSeconds();
}

bool RegionManager::RouteOrCompactRegionImpl(RegionInfo* region)
{
    CHECK(region->IsRoutingState());
    CHECK_DETAIL(region->GetRawPointerObjectCount() <= 0, "pinned region shouldn't be moved");
    size_t fromBytes = region->GetLiveByteCount();
    AllocBuffer* buffer = AllocBuffer::GetOrCreateAllocBuffer();
    RegionInfo* toRegion1 = buffer->GetRegion();
    CHECK(region != toRegion1);
    bool result;
    if (toRegion1 == RegionInfo::NullRegion()) {
        toRegion1 = AllocateThreadLocalRegion();
        if (toRegion1 == nullptr) {
            CompactRegion(region);
            toRegion1 = region;
            result = false;
        } else {
            toRegion1->Alloc(fromBytes);
            result = true;
        }
        buffer->SetRegion(toRegion1);
        size_t toRegion1Start = toRegion1->GetRegionStart();
        region->SetRouteInfo(toRegion1Start, fromBytes);
        DLOG(FORWARD, "route region %p@[%#zx+%zu, %#zx) => %p@[%#zx~%#zx, %#zx)",
            region, region->GetRegionStart(), fromBytes, region->GetRegionEnd(), toRegion1,
            toRegion1Start, toRegion1Start + fromBytes, toRegion1->GetRegionEnd());
        return result;
    }

    size_t toRegion1Capacity = toRegion1->GetAvailableSize();
    MAddress toRegion1Addr = toRegion1->GetRegionAllocPtr();
    if (fromBytes <= toRegion1Capacity) {
        toRegion1->Alloc(fromBytes);
        region->SetRouteInfo(toRegion1Addr, fromBytes);
        DLOG(FORWARD, "route region %p@[%#zx+%zu, %#zx) => %p@[%#zx, %#zx~%#zx, %#zx)",
            region, region->GetRegionStart(), fromBytes, region->GetRegionEnd(), toRegion1,
            toRegion1->GetRegionStart(), toRegion1Addr, toRegion1Addr + fromBytes, toRegion1->GetRegionEnd());
        return true;
    }
    size_t toRegion1Waste = toRegion1Capacity;
    BaseObject* leftObject = nullptr;
    (void)region->VisitLiveObjectsUntilFalse([&toRegion1Waste, &leftObject](BaseObject* obj) {
        size_t objSz = RegionSpace::GetAllocSize(*obj);
        if (toRegion1Waste >= objSz) {
            toRegion1Waste -= objSz;
            return true;
        } else {
            leftObject = obj;
            return false;
        }
    });
    MAddress usedBytes1 = toRegion1Capacity - toRegion1Waste;
    MAddress usedBytes2 = fromBytes - usedBytes1;
    CHECK(toRegion1->IsThreadLocalRegion());
    {
        RemoveThreadLocalRegion(toRegion1);
        EnlistFullThreadLocalRegion(toRegion1);
    }

    RegionInfo* toRegion2 = AllocateThreadLocalRegion();
    CHECK(region != toRegion2);
    if (toRegion2 != nullptr) {
        toRegion1->Alloc(usedBytes1);
        CHECK(toRegion2->Alloc(usedBytes2) != 0);
        result = true;
    } else {
        CompactRegion(region, toRegion1);
        toRegion2 = region; // region is partially compacted into itself.
        result = false;
    }
    buffer->SetRegion(toRegion2);
    uint32_t toRegion2Idx = toRegion2->GetUnitIdx();
    region->SetRouteInfo(toRegion1Addr, usedBytes1, toRegion2Idx);
    DLOG(FORWARD, "route region %p@[%#zx+%zu, %#zx) => %p@[%#zx, %#zx~%#zx, %#zx) & %p@[%#zx~%#zx, %#zx)", region,
        region->GetRegionStart(), fromBytes, region->GetRegionEnd(), toRegion1, toRegion1->GetRegionStart(),
        toRegion1Addr, toRegion1Addr + usedBytes1, toRegion1->GetRegionEnd(), toRegion2,
        toRegion2->GetRegionStart(), toRegion2->GetRegionStart() + usedBytes2, toRegion2->GetRegionEnd());
    return result;
}

void RegionManager::CompactRegion(RegionInfo* region)
{
    MAddress regionStart = region->GetRegionStart();
    DLOG(REGION, "compact region %p@[%#zx+%zu, %#zx) type %u", region, regionStart,
        region->GetLiveByteCount(), region->GetRegionEnd(), region->GetRegionType());
    MAddress regionLimit = region->GetRegionAllocPtr();
    region->SetRegionAllocPtr(regionStart);
    CopyCollector& collector = reinterpret_cast<CopyCollector&>(Heap::GetHeap().GetCollector());
    for (MAddress currentPtr = regionStart; currentPtr < regionLimit;) {
        BaseObject* currentObj = reinterpret_cast<BaseObject*>(currentPtr);
        size_t size = currentObj->GetSize();
        size_t offset = currentPtr - regionStart;
        if (region->IsSurvivedObject(offset)) {
            MAddress toAddress = region->Alloc(size);
            BaseObject* toObj = reinterpret_cast<BaseObject*>(toAddress);
            DLOG(FORWARD, "compact obj %p<%p>(%zu) to %p", currentObj, currentObj->GetTypeInfo(), size, toObj);
            collector.CopyObject(*currentObj, *toObj, size);
            toObj->SetStateCode(ObjectState::NORMAL);
        }
        currentPtr += size;
    }
    std::atomic_thread_fence(std::memory_order_release);

    // clear unused space which is free after compaction.
    MAddress cur = region->GetRegionAllocPtr();
    if (regionLimit > cur) {
        size_t reclaimSize = regionLimit - cur;
        CHECK_DETAIL(memset_s(reinterpret_cast<void*>(cur), reclaimSize, 0, reclaimSize) == EOK, "clear buffer failed");
    }

    if (region->IsFromRegion()) {
        fromRegionList.TryDeleteRegion(region, RegionInfo::RegionType::FROM_REGION,
            RegionInfo::RegionType::THREAD_LOCAL_REGION);
    }
    tlRegionList.PrependRegion(region, RegionInfo::RegionType::THREAD_LOCAL_REGION);
}

void RegionManager::CompactRegion(RegionInfo* region, RegionInfo* toRegion1)
{
    MAddress regionStart = region->GetRegionStart();
    DLOG(REGION, "compact region %p@[%#zx+%zu, %#zx) type %u to region %p@%#zx:%#zx",
        region, regionStart, region->GetLiveByteCount(), region->GetRegionEnd(), region->GetRegionType(),
        toRegion1, toRegion1->GetRegionStart(), toRegion1->GetRegionAllocPtr());
    MAddress currentPtr = regionStart;
    BaseObject* currentObj = reinterpret_cast<BaseObject*>(currentPtr);
    CopyCollector& collector = reinterpret_cast<CopyCollector&>(Heap::GetHeap().GetCollector());
    while (true) {
        CHECK(currentPtr>=regionStart);
        size_t offset = currentPtr - regionStart;
        size_t size = currentObj->GetSize();
        if (region->IsSurvivedObject(offset)) {
            MAddress toAddress = toRegion1->Alloc(size);
            if (toAddress == 0) {
                break;
            }
            BaseObject* toObj = reinterpret_cast<BaseObject*>(toAddress);
            DLOG(FORWARD, "compact obj %p<%p>(%zu) to %p", currentObj, currentObj->GetTypeInfo(), size, toObj);
            collector.CopyObject(*currentObj, *toObj, size);
            toObj->SetStateCode(ObjectState::NORMAL);
            std::atomic_thread_fence(std::memory_order_release);
        }
        currentPtr += size;
        currentObj = reinterpret_cast<BaseObject*>(currentPtr);
    };

    MAddress regionLimit = region->GetRegionAllocPtr();
    region->SetRegionAllocPtr(regionStart);
    while (currentPtr < regionLimit) {
        CHECK(currentPtr >= regionStart);
        size_t offset = currentPtr - regionStart;
        BaseObject* currentObj = reinterpret_cast<BaseObject*>(currentPtr);
        size_t size = currentObj->GetSize();
        if (region->IsSurvivedObject(offset)) {
            MAddress toAddress = region->Alloc(size);
            BaseObject* toObj = reinterpret_cast<BaseObject*>(toAddress);
            DLOG(FORWARD, "compact obj %p<%p>(%zu) to %p", currentObj, currentObj->GetTypeInfo(), size, toObj);
            collector.CopyObject(*currentObj, *toObj, size);
            toObj->SetStateCode(ObjectState::NORMAL);
            std::atomic_thread_fence(std::memory_order_release);
        }
        currentPtr += size;
    }

    // clear unused space which is free after compaction.
    MAddress cur = region->GetRegionAllocPtr();
    if (regionLimit > cur) {
        size_t reclaimSize = regionLimit - cur;
        CHECK_DETAIL(memset_s(reinterpret_cast<void*>(cur), reclaimSize, 0, reclaimSize) == EOK, "clear buffer failed");
    }

    if (region->IsFromRegion()) {
        fromRegionList.TryDeleteRegion(region, RegionInfo::RegionType::FROM_REGION,
            RegionInfo::RegionType::THREAD_LOCAL_REGION);
    }
    tlRegionList.PrependRegion(region, RegionInfo::RegionType::THREAD_LOCAL_REGION);
}

void RegionManager::ForwardRegion(RegionInfo* region)
{
    CHECK_DETAIL(region->IsFromRegion() || region->IsLoneFromRegion() || (region->IsThreadLocalRegion() &&
        (region->IsRoutingState() || region->IsCompacted())), "region type %u", region->GetRegionType());

    DLOG(FORWARD, "try forward region %p @[0x%zx+%zu, 0x%zx) type %u, live bytes %u",
        region, region->GetRegionStart(), region->GetRegionAllocatedSize(), region->GetRegionEnd(),
        region->GetRegionType(), region->GetLiveByteCount());

    if (region->GetLiveByteCount() == 0) {
        CollectRegion(region);
        return;
    }

    if (!RouteRegion(region)) {
        return;
    }

    int32_t rawPointerCount = region->GetRawPointerObjectCount();
    CHECK(rawPointerCount == 0);
    Collector& collector = Heap::GetHeap().GetCollector();
    bool forwarded = region->VisitLiveObjectsUntilFalse(
        [&collector](BaseObject* obj) { return collector.ForwardObject(obj); });

    CHECK(forwarded);
    {
        region->SetRouteState(RegionInfo::RouteState::FORWARDED);
        CollectRegion(region);
    }
}

uintptr_t RegionManager::AllocPinnedFromFreeList(size_t size)
{
    std::lock_guard<std::mutex> lock(freePinnedSlotListMutex);
    GCPhase mutatorPhase = Mutator::GetMutator()->GetMutatorPhase();
    // For preventing missing mark, do not allocate object from slot list when gc phase is post trace.
    if (mutatorPhase == GCPhase::GC_PHASE_POST_TRACE) {
        return 0;
    }
    uintptr_t allocPtr = freePinnedSlotLists.PopFront(size);
    // For making bitmap comform with live object count, do not mark object repeated.
    if (allocPtr == 0 ||
        (mutatorPhase != GCPhase::GC_PHASE_ENUM &&
        mutatorPhase != GCPhase::GC_PHASE_TRACE &&
        mutatorPhase != GCPhase::GC_PHASE_CLEAR_SATB_BUFFER)) {
        return allocPtr;
    }

    // Mark new allocated pinned object.
    BaseObject* object = reinterpret_cast<BaseObject*>(allocPtr);
    (reinterpret_cast<CopyCollector*>(&Heap::GetHeap().GetCollector()))->MarkObject(object);
    return allocPtr;
}
} // namespace MapleRuntime
