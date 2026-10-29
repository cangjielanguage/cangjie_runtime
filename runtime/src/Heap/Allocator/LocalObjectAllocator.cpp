// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#include "Allocator/LocalObjectAllocator.h"

#include "Allocator/Allocator.h"
#include "Base/CString.h"
#include "Base/Globals.h"
#include "Base/Log.h"
#include "Base/MemUtils.h"
#include "Common/NativeAllocator.h"
#include "ExceptionManager.inline.h"
#include "Heap/Heap.h"
#include "Mutator/MutatorManager.h"
#include "Mutator/Mutator.h"
#include "ObjectModel/MObject.h"

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <limits>
#include <mutex>
#include <new>
#include <vector>

namespace MapleRuntime {
class LocalObjectRootRegistry {
public:
    void AddFinalizer(BaseObject* obj);
    bool RunFinalizer(Mutator& mutator, BaseObject* obj);
    void AddLocalRoot(BaseObject* obj, RefField<false>* field);
    void VisitRegisteredObjects(
        const std::function<void(BaseObject*, LocalObjectInfo::RootKind, uint8_t)>& visitor) const;
    void VisitLocalObjectRefFields(const RootVisitor& visitor) const;
    bool RunPendingFinalizers(Mutator& mutator);

private:
    enum class FinalizerState : uint8_t {
        PENDING,
        RUNNING,
    };

    struct FinalizerEntry {
        BaseObject* obj;
        FinalizerState state;
    };

    struct LocalRootEntry {
        BaseObject* owner;
        RefField<false>* field;
    };

    void VisitOneLocalObject(BaseObject* obj, const RootVisitor& visitor) const;
    bool RunFinalizerAt(Mutator& mutator, size_t idx);

    // Compiler lowering registers each local-finalizer allocation exactly once.
    // Completed entries are removed; the order of entries is not significant.
    std::vector<FinalizerEntry> finalizers;
    std::vector<LocalRootEntry> localRoots;
};

// Native local allocator.  The active storage is a doubly-linked chunk list and
// region lifetime is represented by an explicit frame snapshot (top chunk + bump
// pointer). This keeps nested regions cheap: ending a region only rolls back the
// suffix allocated after its snapshot.
class NativeLocalObjectAllocator final : public LocalObjectAllocator {
public:
    static constexpr size_t DEFAULT_REGION_LIMIT = 256 * MB;

    explicit NativeLocalObjectAllocator(size_t regionLimit) : regionLimit(regionLimit) {}
    ~NativeLocalObjectAllocator() override = default;

    void StartRegion(Mutator& mutator, FrameAddress* ownerFA) override;
    void EndRegion(Mutator& mutator, FrameAddress* ownerFA) override;
    void EndRegionsForFrame(Mutator& mutator, FrameAddress* ownerFA) override;
    MAddress Allocate(Mutator& mutator, size_t size) override;
    size_t GetHeapAllocatedBytes() const override { return 0; }
    size_t GetAllocatedObjectBytes() const override;
    void AddFinalizer(Mutator& mutator, BaseObject* obj) override;
    void RemoveFinalizer(Mutator& mutator, BaseObject* obj) override;
    void AddLocalRoot(Mutator& mutator, BaseObject* obj, RefField<false>* field) override;
    void VisitLocalObjectRefFields(Mutator& mutator, const RootVisitor& visitor) override;
    void OnMutatorExit(Mutator& mutator) override;
    void VisitLocalObjects(const LocalObjectVisitor& visitor) const override;
    void VisitLocalRoots(const LocalObjectVisitor& visitor) const override;
    bool HasLocalObjects() const override { return true; }

private:
    struct RegionFrame;
    struct RegionChunk {
        RegionChunk* prev = nullptr;
        RegionChunk* next = nullptr;
        MAddress base = 0;
        MAddress top = 0;
        size_t capacity = 0;

        MAddress GetEnd() const { return base + capacity; }
    };

    struct RegionFrame {
        RegionFrame* prev = nullptr;
        uint8_t* top = nullptr;
        RegionChunk* chunk = nullptr;
        FrameAddress* ownerFA = nullptr;
        size_t allocatedBytes = 0;
        LocalObjectRootRegistry rootRegistry;
    };

    struct MutatorData {
        Mutator* ownerMutator = nullptr;
        RegionChunk* regionData = nullptr;
        RegionChunk* currentChunk = nullptr;
        uint8_t* regionTop = nullptr;
        RegionFrame* currentFrame = nullptr;
    };

    static constexpr size_t DEFAULT_CHUNK_SIZE = 4 * KB;

    ALWAYS_INLINE MutatorData* GetData(const Mutator& mutator) const
    {
        return static_cast<MutatorData*>(mutator.GetLocalObjectAllocatorData());
    }
    MutatorData* CreateData(Mutator& mutator);
    RegionChunk* AllocateChunk(RegionFrame& frame, size_t minSize);
    void ReleaseChunk(RegionChunk* chunk);
    void AppendActiveChunk(MutatorData& data, RegionChunk* chunk);
    void DetachActiveSuffix(MutatorData& data, RegionChunk* snapshotChunk);
    void VisitObjectsInFrame(Mutator& mutator, const MutatorData& data, const RegionFrame& frame,
                             const RegionFrame* child, const LocalObjectVisitor& visitor) const;
    void VisitObjectsInChunk(Mutator& mutator, const RegionFrame& frame, const RegionChunk& chunk,
                             MAddress begin, MAddress end,
                             const LocalObjectVisitor& visitor) const;
    RegionFrame* FindFrameOfObject(MutatorData& data, BaseObject* obj) const;
    void VisitRootsInFrame(MutatorData& data, RegionFrame& frame, const LocalObjectVisitor& visitor) const;
    ALWAYS_INLINE MAddress TryAllocate(MutatorData& data, size_t size);
    bool IsAllocationWithinFrameLimit(const RegionFrame& frame, size_t size) const;
    void RunFinalizers(Mutator& mutator, RegionFrame& frame);
    void EndTopFrame(Mutator& mutator, MutatorData& data);

    mutable std::mutex activeDataMtx;
    std::vector<MutatorData*> activeData;
    const size_t regionLimit;
};

constexpr size_t NativeLocalObjectAllocator::DEFAULT_CHUNK_SIZE;

namespace {
void RunLocalObjectFinalizer(Mutator& mutator, BaseObject* obj)
{
    TypeInfo* classInfo = reinterpret_cast<MObject*>(obj)->GetTypeInfo();
    FuncRef finalizerMethod = classInfo->GetFinalizeMethod();
    CHECK_DETAIL(finalizerMethod != nullptr, "%p has no finalize method", obj);
    void (*finalizer)(BaseObject*, TypeInfo*) = reinterpret_cast<void (*)(BaseObject*, TypeInfo*)>(finalizerMethod);

    bool oldManagedContext = mutator.IsManagedContext();
    mutator.SetManagedContext(true);
    DLOG(FINALIZE, "tid %u finalize local object %p", mutator.GetTid(), obj);
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
    ExecuteCangjieStub(obj, obj->GetTypeInfo(), 0, reinterpret_cast<void*>(finalizer),
                       reinterpret_cast<void*>(threadData), 0);
    mutator.SetManagedContext(oldManagedContext);

    if (ExceptionManager::HasFatalException()) {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
        ExceptionManager::DumpException();
#endif
        LOG(RTLOG_FATAL, "FatalException happened in local finalizer");
    }
    ExceptionManager::ClearPendingException();
}
}

void LocalObjectRootRegistry::AddFinalizer(BaseObject* obj)
{
    if (obj == nullptr) {
        return;
    }
    finalizers.push_back({ obj, FinalizerState::PENDING });
}

bool LocalObjectRootRegistry::RunFinalizer(Mutator& mutator, BaseObject* obj)
{
    if (obj == nullptr) {
        return false;
    }
    for (size_t idx = 0; idx < finalizers.size(); ++idx) {
        if (finalizers[idx].obj == obj) {
            return RunFinalizerAt(mutator, idx);
        }
    }
    return false;
}

void LocalObjectRootRegistry::AddLocalRoot(BaseObject* obj, RefField<false>* field)
{
    if (obj == nullptr || field == nullptr) {
        return;
    }
    for (const LocalRootEntry& localRoot : localRoots) {
        if (localRoot.field == field) {
            return;
        }
    }
    localRoots.push_back({ obj, field });
}

void LocalObjectRootRegistry::VisitRegisteredObjects(
    const std::function<void(BaseObject*, LocalObjectInfo::RootKind, uint8_t)>& visitor) const
{
    for (size_t idx = 0; idx < localRoots.size(); ++idx) {
        BaseObject* obj = localRoots[idx].owner;
        if (obj == nullptr) {
            continue;
        }
        bool wasReported = false;
        for (size_t prev = 0; prev < idx; ++prev) {
            if (localRoots[prev].owner == obj) {
                wasReported = true;
                break;
            }
        }
        if (!wasReported) {
            visitor(obj, LocalObjectInfo::RootKind::LOCAL_OBJECT, 0);
        }
    }
    for (const FinalizerEntry& entry : finalizers) {
        if (entry.obj != nullptr) {
            visitor(entry.obj, LocalObjectInfo::RootKind::FINALIZER,
                    static_cast<uint8_t>(entry.state));
        }
    }
}

void LocalObjectRootRegistry::VisitLocalObjectRefFields(const RootVisitor& visitor) const
{
    for (const LocalRootEntry& localRoot : localRoots) {
        RefField<false>* field = localRoot.field;
        if (field == nullptr || !Heap::IsHeapAddress(field->GetTargetObject())) {
            continue;
        }
        visitor(reinterpret_cast<ObjectRef&>(*field));
    }
    for (const FinalizerEntry& entry : finalizers) {
        // RUNNING finalizers remain scan sources while user code executes,
        // so a re-entrant GC can still trace and update their heap fields.
        VisitOneLocalObject(entry.obj, visitor);
    }
}

void LocalObjectRootRegistry::VisitOneLocalObject(BaseObject* obj, const RootVisitor& visitor) const
{
    if (obj == nullptr) {
        return;
    }
    obj->ForEachRefField([&visitor](RefField<>& field) {
        BaseObject* target = field.GetTargetObject();
        if (target == nullptr || !Heap::IsHeapAddress(target)) {
            return;
        }
        visitor(reinterpret_cast<ObjectRef&>(field));
    });
}

bool LocalObjectRootRegistry::RunPendingFinalizers(Mutator& mutator)
{
    bool ranFinalizer = false;
    size_t idx = 0;
    while (idx < finalizers.size()) {
        if (finalizers[idx].state != FinalizerState::PENDING) {
            ++idx;
            continue;
        }
        if (RunFinalizerAt(mutator, idx)) {
            ranFinalizer = true;
            // The last entry was moved to idx. Process it before advancing.
            continue;
        }
        ++idx;
    }
    return ranFinalizer;
}

bool LocalObjectRootRegistry::RunFinalizerAt(Mutator& mutator, size_t idx)
{
    CHECK_DETAIL(idx < finalizers.size(), "invalid local finalizer index %zu", idx);
    if (finalizers[idx].state != FinalizerState::PENDING) {
        return false;
    }

    BaseObject* finalizerObj = finalizers[idx].obj;
    finalizers[idx].state = FinalizerState::RUNNING;
    RunLocalObjectFinalizer(mutator, finalizerObj);

    // User code may register or finish other finalizers and thereby reallocate
    // or reorder the vector. Locate this RUNNING entry again before removing it.
    size_t completedIdx = idx;
    if (completedIdx >= finalizers.size() || finalizers[completedIdx].obj != finalizerObj) {
        completedIdx = finalizers.size();
        for (size_t currentIdx = 0; currentIdx < finalizers.size(); ++currentIdx) {
            if (finalizers[currentIdx].obj == finalizerObj &&
                finalizers[currentIdx].state == FinalizerState::RUNNING) {
                completedIdx = currentIdx;
                break;
            }
        }
    }
    CHECK_DETAIL(completedIdx < finalizers.size() &&
                     finalizers[completedIdx].state == FinalizerState::RUNNING,
                 "local finalizer registry lost running entry %p", finalizerObj);
    if (completedIdx != finalizers.size() - 1) {
        finalizers[completedIdx] = finalizers.back();
    }
    finalizers.pop_back();
    return true;
}

LocalObjectAllocator* LocalObjectAllocator::InitLocalObjectAllocator()
{
    size_t regionLimit = NativeLocalObjectAllocator::DEFAULT_REGION_LIMIT;
    const char* env = std::getenv("cjLocalRegionMaxSize");
    if (env != nullptr) {
        size_t configuredLimit = CString::ParseSizeFromEnv(env);
        if (configuredLimit == 0 || configuredLimit > std::numeric_limits<size_t>::max() / KB) {
            LOG(RTLOG_ERROR, "Unsupported cjLocalRegionMaxSize parameter: %s. Use the default limit instead.", env);
        } else {
            regionLimit = configuredLimit * KB;
        }
    }
    LocalObjectAllocator* localObjectAllocator = new (std::nothrow) NativeLocalObjectAllocator(regionLimit);
    VLOG(LOCAL_REGION, "use native local object allocator with per-region limit %zu B", regionLimit);
    CHECK_DETAIL(localObjectAllocator != nullptr, "new local object allocator failed");
    return localObjectAllocator;
}

NativeLocalObjectAllocator::MutatorData* NativeLocalObjectAllocator::CreateData(Mutator& mutator)
{
    MutatorData* data = GetData(mutator);
    if (data != nullptr) {
        return data;
    }
    data = new (std::nothrow) MutatorData();
    CHECK_DETAIL(data != nullptr, "new native local mutator data failed");
    data->ownerMutator = &mutator;
    mutator.SetLocalObjectAllocatorData(data);
    std::lock_guard<std::mutex> lock(activeDataMtx);
    activeData.push_back(data);
    return data;
}

NativeLocalObjectAllocator::RegionChunk* NativeLocalObjectAllocator::AllocateChunk(RegionFrame& frame,
                                                                                   size_t minSize)
{
    if (minSize > std::numeric_limits<size_t>::max() - (Allocator::ALLOC_ALIGN - 1U)) {
        ExceptionManager::LocalRegionOutOfMemory();
        return nullptr;
    }
    size_t alignedSize = RoundUp<size_t>(minSize, Allocator::ALLOC_ALIGN);
    if (UNLIKELY(!IsAllocationWithinFrameLimit(frame, alignedSize))) {
        VLOG(LOCAL_REGION, "native local region limit reached: frame %p, used %zu B, request %zu B, limit %zu B",
             &frame, frame.allocatedBytes, alignedSize, regionLimit);
        ExceptionManager::LocalRegionOutOfMemory();
        return nullptr;
    }
    size_t capacity = std::max(DEFAULT_CHUNK_SIZE, alignedSize);
    void* memory = NativeAllocator::NativeAlloc(capacity);
    if (memory == nullptr) {
        return nullptr;
    }
    // NativeAllocator may return a chunk recycled from its thread cache.  A
    // local object allocation only initializes its object header here, so a
    // new chunk must not expose fields left by an earlier local region.
    MemorySet(reinterpret_cast<uintptr_t>(memory), capacity, 0, capacity);
    RegionChunk* chunk = new (std::nothrow) RegionChunk();
    if (chunk == nullptr) {
        NativeAllocator::NativeFree(memory, capacity);
        return nullptr;
    }
    chunk->base = reinterpret_cast<MAddress>(memory);
    chunk->capacity = capacity;
    chunk->top = chunk->base;
    return chunk;
}

void NativeLocalObjectAllocator::AppendActiveChunk(MutatorData& data, RegionChunk* chunk)
{
    CHECK_DETAIL(chunk != nullptr, "append null native chunk");
    chunk->prev = data.currentChunk;
    chunk->next = nullptr;
    if (data.currentChunk != nullptr) {
        data.currentChunk->next = chunk;
    } else {
        data.regionData = chunk;
    }
    data.currentChunk = chunk;
    data.regionTop = reinterpret_cast<uint8_t*>(chunk->top);
}

void NativeLocalObjectAllocator::ReleaseChunk(RegionChunk* chunk)
{
    CHECK_DETAIL(chunk != nullptr, "release null native chunk");
    NativeAllocator::NativeFree(reinterpret_cast<void*>(chunk->base), chunk->capacity);
    delete chunk;
}

void NativeLocalObjectAllocator::StartRegion(Mutator& mutator, FrameAddress* ownerFA)
{
    MutatorData* data = CreateData(mutator);
    RegionFrame* frame = new (std::nothrow) RegionFrame();
    CHECK_DETAIL(frame != nullptr, "new native local region frame failed");

    frame->prev = data->currentFrame;
    frame->top = data->regionTop;
    frame->chunk = data->currentChunk;
    frame->ownerFA = ownerFA;

    // A frame only records the current allocation position. Allocate() creates
    // a chunk lazily when the first allocation cannot use the active chunk.
    data->currentFrame = frame;
    VLOG(LOCAL_REGION, "StartNativeLocalRegion: mutator %p, frame %p, ownerFA %p, chunk %p, top %p", &mutator,
         frame, ownerFA, data->currentChunk, reinterpret_cast<void*>(data->regionTop));
}

ALWAYS_INLINE MAddress NativeLocalObjectAllocator::TryAllocate(MutatorData& data, size_t size)
{
    if (size > std::numeric_limits<size_t>::max() - (Allocator::ALLOC_ALIGN - 1U)) {
        return 0;
    }
    size = RoundUp<size_t>(size, Allocator::ALLOC_ALIGN);
    RegionChunk* chunk = data.currentChunk;
    if (chunk == nullptr) {
        return 0;
    }
    MAddress addr = RoundUp<MAddress>(chunk->top, Allocator::ALLOC_ALIGN);
    MAddress end = chunk->GetEnd();
    if (addr > end || size > end - addr) {
        return 0;
    }
    chunk->top = addr + size;
    data.regionTop = reinterpret_cast<uint8_t*>(chunk->top);
    return addr;
}

bool NativeLocalObjectAllocator::IsAllocationWithinFrameLimit(const RegionFrame& frame, size_t size) const
{
    return size <= regionLimit && frame.allocatedBytes <= regionLimit - size;
}

MAddress NativeLocalObjectAllocator::Allocate(Mutator& mutator, size_t size)
{
    MutatorData* data = GetData(mutator);
    if (data == nullptr || data->currentFrame == nullptr) {
        LOG(RTLOG_ERROR, "alloc native local object without local object region");
        return 0;
    }
    RegionFrame& frame = *data->currentFrame;
    MAddress addr = TryAllocate(*data, size);
    if (addr != 0) {
        size_t allocSize = RoundUp<size_t>(size, Allocator::ALLOC_ALIGN);
        frame.allocatedBytes += allocSize;
        return addr;
    }
    RegionChunk* chunk = AllocateChunk(frame, size);
    if (chunk == nullptr) {
        return 0;
    }
    AppendActiveChunk(*data, chunk);
    addr = TryAllocate(*data, size);
    CHECK_DETAIL(addr != 0, "native local allocation failed after adding chunk");
    size_t allocSize = RoundUp<size_t>(size, Allocator::ALLOC_ALIGN);
    frame.allocatedBytes += allocSize;
    VLOG(LOCAL_REGION, "AllocNativeLocalObject: mutator %p, chunk %p, obj %p, objSize %zu", &mutator, chunk,
         reinterpret_cast<void*>(addr), size);
    return addr;
}

void NativeLocalObjectAllocator::RunFinalizers(Mutator& mutator, RegionFrame& frame)
{
    while (frame.rootRegistry.RunPendingFinalizers(mutator)) {
    }
}

void NativeLocalObjectAllocator::DetachActiveSuffix(MutatorData& data, RegionChunk* snapshotChunk)
{
    RegionChunk* chunk = data.currentChunk;
    while (chunk != snapshotChunk) {
        CHECK_DETAIL(chunk != nullptr, "native region snapshot chunk not found");
        RegionChunk* prev = chunk->prev;
        ReleaseChunk(chunk);
        chunk = prev;
    }
    if (snapshotChunk == nullptr) {
        data.regionData = nullptr;
        data.currentChunk = nullptr;
        data.regionTop = nullptr;
        return;
    }
    data.currentChunk = snapshotChunk;
    data.regionTop = reinterpret_cast<uint8_t*>(snapshotChunk->top);
    snapshotChunk->next = nullptr;
}

void NativeLocalObjectAllocator::EndRegion(Mutator& mutator, FrameAddress* ownerFA)
{
    MutatorData* data = GetData(mutator);
    if (data == nullptr || data->currentFrame == nullptr) {
        LOG(RTLOG_WARNING, "end native local region without active region");
        return;
    }
    RegionFrame* frame = data->currentFrame;
    if (ownerFA != nullptr && frame->ownerFA != ownerFA) {
        RegionFrame* targetFrame = frame->prev;
        while (targetFrame != nullptr && targetFrame->ownerFA != ownerFA) {
            targetFrame = targetFrame->prev;
        }
        if (targetFrame == nullptr) {
            LOG(RTLOG_WARNING, "skip native local region end for mismatched frame: ownerFA %p target %p",
                frame->ownerFA, ownerFA);
            return;
        }
        VLOG(LOCAL_REGION, "EndNativeLocalRegion across frame boundary: top ownerFA %p, target ownerFA %p",
             frame->ownerFA, ownerFA);
        while (data->currentFrame != nullptr) {
            bool reachedTarget = data->currentFrame == targetFrame;
            EndTopFrame(mutator, *data);
            if (reachedTarget) {
                return;
            }
        }
        return;
    }
    EndTopFrame(mutator, *data);
}

void NativeLocalObjectAllocator::EndTopFrame(Mutator& mutator, MutatorData& data)
{
    RegionFrame* frame = data.currentFrame;
    CHECK_DETAIL(frame != nullptr, "end native top frame without active frame");
    RunFinalizers(mutator, *frame);
    DetachActiveSuffix(data, frame->chunk);
    // Chunks appended by this frame have been released above and are cleared
    // when AllocateChunk obtains them again.  The snapshot chunk remains
    // active, however: rolling its bump pointer back would otherwise expose
    // this frame's old object bytes to the next nested local region.
    if (frame->chunk != nullptr) {
        MAddress begin = reinterpret_cast<MAddress>(frame->top);
        MAddress end = frame->chunk->top;
        CHECK_DETAIL(begin >= frame->chunk->base && begin <= end && end <= frame->chunk->GetEnd(),
                     "invalid native local rollback range [%p, %p) in chunk %p",
                     reinterpret_cast<void*>(begin), reinterpret_cast<void*>(end), frame->chunk);
        if (begin != end) {
            MemorySet(begin, end - begin, 0, end - begin);
        }
    }
    data.regionTop = frame->top;
    data.currentChunk = frame->chunk;
    if (data.currentChunk != nullptr) {
        data.currentChunk->top = reinterpret_cast<MAddress>(frame->top);
    }
    data.currentFrame = frame->prev;
    delete frame;
}

void NativeLocalObjectAllocator::EndRegionsForFrame(Mutator& mutator, FrameAddress* ownerFA)
{
    if (ownerFA == nullptr) {
        return;
    }
    MutatorData* data = GetData(mutator);
    while (data != nullptr && data->currentFrame != nullptr && data->currentFrame->ownerFA == ownerFA) {
        EndTopFrame(mutator, *data);
    }
}

void NativeLocalObjectAllocator::VisitLocalObjects(const LocalObjectVisitor& visitor) const
{
    if (!visitor) {
        return;
    }
    CHECK_DETAIL(MutatorManager::Instance().WorldStopped(), "native local object visit requires STW");
    std::lock_guard<std::mutex> lock(activeDataMtx);
    for (MutatorData* data : activeData) {
        if (data == nullptr || data->ownerMutator == nullptr) {
            continue;
        }
        std::vector<RegionFrame*> frames;
        for (RegionFrame* frame = data->currentFrame; frame != nullptr; frame = frame->prev) {
            frames.push_back(frame);
        }
        for (size_t idx = frames.size(); idx > 0; --idx) {
            RegionFrame* frame = frames[idx - 1];
            RegionFrame* child = idx > 1 ? frames[idx - 2] : nullptr;
            VisitObjectsInFrame(*data->ownerMutator, *data, *frame, child, visitor);
        }
    }
}

void NativeLocalObjectAllocator::VisitObjectsInFrame(Mutator& mutator, const MutatorData& data,
                                                     const RegionFrame& frame, const RegionFrame* child,
                                                     const LocalObjectVisitor& visitor) const
{
    RegionChunk* beginChunk = frame.chunk == nullptr ? data.regionData : frame.chunk;
    MAddress begin = frame.chunk == nullptr ?
        (beginChunk == nullptr ? 0 : beginChunk->base) : reinterpret_cast<MAddress>(frame.top);
    RegionChunk* endChunk = child == nullptr ? data.currentChunk : child->chunk;
    MAddress end = child == nullptr ?
        (endChunk == nullptr ? 0 : endChunk->top) : reinterpret_cast<MAddress>(child->top);
    if (beginChunk == nullptr || endChunk == nullptr) {
        return;
    }

    for (RegionChunk* chunk = beginChunk; chunk != nullptr; chunk = chunk->next) {
        MAddress chunkBegin = chunk == beginChunk ? begin : chunk->base;
        MAddress chunkEnd = chunk == endChunk ? end : chunk->top;
        if (chunkBegin > chunkEnd || chunkBegin < chunk->base || chunkEnd > chunk->top) {
            LOG(RTLOG_ERROR, "invalid native local frame range [%p, %p) in chunk %p",
                reinterpret_cast<void*>(chunkBegin), reinterpret_cast<void*>(chunkEnd), chunk);
            return;
        }
        VisitObjectsInChunk(mutator, frame, *chunk, chunkBegin, chunkEnd, visitor);
        if (chunk == endChunk) {
            return;
        }
    }
    LOG(RTLOG_ERROR, "native local frame end chunk %p is not reachable from begin chunk %p", endChunk, beginChunk);
}

void NativeLocalObjectAllocator::VisitObjectsInChunk(Mutator& mutator, const RegionFrame& frame,
                                                     const RegionChunk& chunk, MAddress begin, MAddress end,
                                                     const LocalObjectVisitor& visitor) const
{
    MAddress cursor = begin;
    while (cursor < end) {
        BaseObject* obj = reinterpret_cast<BaseObject*>(cursor);
        size_t objSize = obj->GetSize();
        if (objSize == 0 || objSize > end - cursor) {
            LOG(RTLOG_ERROR, "invalid local object size %zu at %p in chunk %p", objSize,
                reinterpret_cast<void*>(cursor), &chunk);
            break;
        }
        LocalObjectInfo info { &mutator, frame.ownerFA, chunk.base, chunk.capacity,
                               chunk.capacity > DEFAULT_CHUNK_SIZE };
        visitor(mutator, obj, info);
        cursor = RoundUp<MAddress>(cursor + objSize, Allocator::ALLOC_ALIGN);
    }
}

NativeLocalObjectAllocator::RegionFrame* NativeLocalObjectAllocator::FindFrameOfObject(
    MutatorData& data, BaseObject* obj) const
{
    if (obj == nullptr) {
        return nullptr;
    }
    MAddress address = reinterpret_cast<MAddress>(obj);
    RegionFrame* child = nullptr;
    for (RegionFrame* frame = data.currentFrame; frame != nullptr; child = frame, frame = frame->prev) {
        RegionChunk* beginChunk = frame->chunk == nullptr ? data.regionData : frame->chunk;
        MAddress begin = frame->chunk == nullptr ?
            (beginChunk == nullptr ? 0 : beginChunk->base) : reinterpret_cast<MAddress>(frame->top);
        RegionChunk* endChunk = child == nullptr ? data.currentChunk : child->chunk;
        MAddress end = child == nullptr ?
            (endChunk == nullptr ? 0 : endChunk->top) : reinterpret_cast<MAddress>(child->top);
        if (beginChunk == nullptr || endChunk == nullptr) {
            continue;
        }
        for (RegionChunk* chunk = beginChunk; chunk != nullptr; chunk = chunk->next) {
            MAddress chunkBegin = chunk == beginChunk ? begin : chunk->base;
            MAddress chunkEnd = chunk == endChunk ? end : chunk->top;
            if (chunkBegin > chunkEnd || chunkBegin < chunk->base || chunkEnd > chunk->top) {
                LOG(RTLOG_ERROR, "invalid native local frame range [%p, %p) while locating object %p",
                    reinterpret_cast<void*>(chunkBegin), reinterpret_cast<void*>(chunkEnd), obj);
                return nullptr;
            }
            if (address >= chunkBegin && address < chunkEnd) {
                return frame;
            }
            if (chunk == endChunk) {
                break;
            }
        }
    }
    return nullptr;
}

void NativeLocalObjectAllocator::VisitLocalRoots(const LocalObjectVisitor& visitor) const
{
    if (!visitor) {
        return;
    }
    CHECK_DETAIL(MutatorManager::Instance().WorldStopped(), "native local root visit requires STW");
    std::lock_guard<std::mutex> lock(activeDataMtx);
    for (MutatorData* data : activeData) {
        if (data == nullptr || data->ownerMutator == nullptr) {
            continue;
        }
        for (RegionFrame* frame = data->currentFrame; frame != nullptr; frame = frame->prev) {
            VisitRootsInFrame(*data, *frame, visitor);
        }
    }
}

void NativeLocalObjectAllocator::VisitRootsInFrame(MutatorData& data, RegionFrame& frame,
                                                   const LocalObjectVisitor& visitor) const
{
    frame.rootRegistry.VisitRegisteredObjects(
        [&data, &frame, &visitor](BaseObject* obj, LocalObjectInfo::RootKind rootKind, uint8_t finalizerState) {
            LocalObjectInfo info;
            info.ownerMutator = data.ownerMutator;
            info.ownerFrame = frame.ownerFA;
            info.rootKind = rootKind;
            info.finalizerState = finalizerState;
            visitor(*data.ownerMutator, obj, info);
        });
}

void NativeLocalObjectAllocator::AddFinalizer(Mutator& mutator, BaseObject* obj)
{
    if (obj == nullptr) {
        return;
    }
    MutatorData* data = GetData(mutator);
    RegionFrame* frame = data == nullptr ? nullptr : data->currentFrame;
    if (frame == nullptr) {
        LOG(RTLOG_ERROR, "add native local finalizer without current frame: obj %p", obj);
        return;
    }
    frame->rootRegistry.AddFinalizer(obj);
}

void NativeLocalObjectAllocator::RemoveFinalizer(Mutator& mutator, BaseObject* obj)
{
    if (obj == nullptr) {
        return;
    }
    MutatorData* data = GetData(mutator);
    RegionFrame* frame = data == nullptr ? nullptr : data->currentFrame;
    if (frame == nullptr) {
        LOG(RTLOG_ERROR, "remove native local finalizer without current frame: obj %p", obj);
        return;
    }
    (void)frame->rootRegistry.RunFinalizer(mutator, obj);
}

void NativeLocalObjectAllocator::AddLocalRoot(Mutator& mutator, BaseObject* obj, RefField<false>* field)
{
    if (obj == nullptr || field == nullptr) {
        return;
    }
    MutatorData* data = GetData(mutator);
    CHECK_DETAIL(data != nullptr && data->currentFrame != nullptr,
                 "add native local root without current frame: obj %p, field %p", obj, field);
    RegionFrame* frame = FindFrameOfObject(*data, obj);
    frame->rootRegistry.AddLocalRoot(obj, field);
}

void NativeLocalObjectAllocator::VisitLocalObjectRefFields(Mutator& mutator, const RootVisitor& visitor)
{
    MutatorData* data = GetData(mutator);
    if (data == nullptr) {
        return;
    }
    for (RegionFrame* frame = data->currentFrame; frame != nullptr; frame = frame->prev) {
        frame->rootRegistry.VisitLocalObjectRefFields(visitor);
    }
}

size_t NativeLocalObjectAllocator::GetAllocatedObjectBytes() const
{
    CHECK_DETAIL(MutatorManager::Instance().WorldStopped(), "native local allocated bytes query requires STW");
    size_t total = 0;
    std::lock_guard<std::mutex> lock(activeDataMtx);
    for (MutatorData* data : activeData) {
        if (data == nullptr) {
            continue;
        }
        for (RegionChunk* chunk = data->regionData; chunk != nullptr; chunk = chunk->next) {
            size_t accountedBytes = chunk == data->currentChunk
                ? static_cast<size_t>(chunk->top - chunk->base)
                : chunk->capacity;
            total += accountedBytes;
        }
    }
    return total;
}

void NativeLocalObjectAllocator::OnMutatorExit(Mutator& mutator)
{
    MutatorData* data = GetData(mutator);
    if (data == nullptr) {
        return;
    }
    RegionChunk* chunk = data->regionData;
    while (chunk != nullptr) {
        RegionChunk* next = chunk->next;
        NativeAllocator::NativeFree(reinterpret_cast<void*>(chunk->base), chunk->capacity);
        delete chunk;
        chunk = next;
    }
    while (data->currentFrame != nullptr) {
        RegionFrame* frame = data->currentFrame;
        data->currentFrame = frame->prev;
        delete frame;
    }
    {
        std::lock_guard<std::mutex> lock(activeDataMtx);
        auto it = std::find(activeData.begin(), activeData.end(), data);
        if (it != activeData.end()) {
            *it = activeData.back();
            activeData.pop_back();
        }
    }
    mutator.SetLocalObjectAllocatorData(nullptr);
    delete data;
}
} // namespace MapleRuntime
