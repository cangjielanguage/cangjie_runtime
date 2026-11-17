// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.

#include "HeapVerifier.h"

#include <algorithm>
#include <cstdlib>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <limits>
#include <memory>
#include <mutex>
#include <new>
#include <unordered_set>
#include <vector>

#include "securec.h"

#include "Base/Log.h"
#include "Base/LogFile.h"
#include "Common/BaseObject.h"
#include "Common/Runtime.h"
#include "Common/ScopedObjectAccess.h"
#include "Concurrency/Concurrency.h"
#include "Heap.h"
#include "Heap/Allocator/Allocator.h"
#include "Heap/Allocator/RegionSpace.h"
#include "Heap/Collector/FinalizerProcessor.h"
#include "Mutator/MutatorManager.h"
#include "ObjectModel/MArray.h"
#include "ObjectModel/MArray.inline.h"

namespace MapleRuntime {
HeapVerifier::Mode HeapVerifier::heapVerifyMode = HeapVerifier::Mode::DISABLED;

HeapVerifier::Mode HeapVerifier::ReadModeFromEnv()
{
    const char* value = std::getenv("cjEnableHeapVerify");
    if (value == nullptr) {
        return Mode::DISABLED;
    }
    if (value[0] == '0' && value[1] == '\0') {
        return Mode::DISABLED;
    }
    if (value[0] == '1' && value[1] == '\0') {
        return Mode::PRE_GC;
    }
    if (value[0] == '2' && value[1] == '\0') {
        return Mode::POST_GC;
    }
    if (value[0] == '3' && value[1] == '\0') {
        return Mode::BOTH;
    }
    LOG(RTLOG_ERROR, "Unsupported cjEnableHeapVerify, cjEnableHeapVerify should be 0, 1, 2 or 3.\n");
    return Mode::DISABLED;
}

// Verification is serialized by the GC's ScopedSTWLock. These buffers contain
// no GC state: only their storage survives a checkpoint, never their bits.
class __attribute__((visibility("hidden"))) VerifyVisitBitmap {
public:
    ~VerifyVisitBitmap() { Release(); }

    bool Init(MAddress start, MAddress limit)
    {
        if (RegionInfo::UNIT_SIZE == 0 ||
            RegionInfo::UNIT_SIZE % (Allocator::ALLOC_ALIGN * BITS_PER_BYTE) != 0 ||
            limit < start || start % Allocator::ALLOC_ALIGN != 0 ||
            (limit - start) % RegionInfo::UNIT_SIZE != 0) {
            return false;
        }
        heapStart = start;
        unitCount = (limit - start) / RegionInfo::UNIT_SIZE;
        if (unitCount > std::numeric_limits<size_t>::max() / sizeof(Entry)) {
            return false;
        }
        if (unitCount != 0) {
            entries.reset(new (std::nothrow) Entry[unitCount]());
            if (entries == nullptr) {
                return false;
            }
        }
        return true;
    }

    bool Contains(MAddress address) const
    {
        if (address < heapStart || address % Allocator::ALLOC_ALIGN != 0) {
            return false;
        }
        size_t offset = address - heapStart;
        size_t unit = offset / RegionInfo::UNIT_SIZE;
        if (unit >= unitCount || entries == nullptr) {
            return false;
        }
        const Entry& entry = entries[unit];
        if (entry.largeVisited) {
            return offset % RegionInfo::UNIT_SIZE == 0;
        }
        size_t bit = (offset % RegionInfo::UNIT_SIZE) / Allocator::ALLOC_ALIGN;
        return entry.block != nullptr && (entry.block->bits[bit / BITS_PER_BYTE] &
            (1u << (bit % BITS_PER_BYTE))) != 0;
    }

    // Called only after region bounds and the object's layout have passed.
    bool Record(BaseObject* object)
    {
        MAddress address = reinterpret_cast<MAddress>(object);
        if (address < heapStart || address % Allocator::ALLOC_ALIGN != 0 || entries == nullptr) {
            return false;
        }
        size_t offset = address - heapStart;
        if (offset / RegionInfo::UNIT_SIZE >= unitCount) {
            return false;
        }
        Entry& entry = entries[offset / RegionInfo::UNIT_SIZE];
        if (RegionInfo::GetRegionInfoAt(address)->IsLargeRegion()) {
            entry.largeVisited = true;
            return true;
        }
        if (entry.block == nullptr) {
            entry.block = Cache::Instance().Acquire();
            if (entry.block == nullptr) {
                return false;
            }
        }
        size_t bit = (offset % RegionInfo::UNIT_SIZE) / Allocator::ALLOC_ALIGN;
        entry.block->bits[bit / BITS_PER_BYTE] |= static_cast<uint8_t>(1u << (bit % BITS_PER_BYTE));
        return true;
    }

    void Release()
    {
        if (entries != nullptr) {
            for (size_t unit = 0; unit < unitCount; ++unit) {
                if (entries[unit].block != nullptr) {
                    Cache::Instance().Recycle(entries[unit].block);
                }
            }
            entries.reset();
        }
    }

private:
    static constexpr size_t BITS_PER_BYTE = 8;

    // UNIT_SIZE comes from the system page size and is not a constant expression.
    static size_t BitmapBytes() { return RegionInfo::UNIT_SIZE / Allocator::ALLOC_ALIGN / BITS_PER_BYTE; }

    struct Block {
        Block* next = nullptr;
        std::unique_ptr<uint8_t[]> bits;
    };

    static size_t BlockBytes() { return sizeof(Block) + BitmapBytes(); }

    struct Entry {
        Block* block = nullptr;
        bool largeVisited = false;
    };

    struct Cache {
        static Cache& Instance()
        {
            static Cache cache;
            return cache;
        }

        ~Cache()
        {
            while (head != nullptr) {
                Block* block = head;
                head = block->next;
                delete block;
            }
        }

        Block* Acquire()
        {
            Block* block = head;
            if (block != nullptr) {
                head = block->next;
                bytes -= BlockBytes();
            } else {
                block = new (std::nothrow) Block;
                if (block != nullptr) {
                    block->bits.reset(new (std::nothrow) uint8_t[BitmapBytes()]);
                    if (block->bits == nullptr) {
                        delete block;
                        return nullptr;
                    }
                }
            }
            if (block != nullptr) {
                block->next = nullptr;
                if (memset_s(block->bits.get(), BitmapBytes(), 0, BitmapBytes()) != EOK) {
                    delete block;
                    return nullptr;
                }
            }
            return block;
        }

        void Recycle(Block* block)
        {
            // Bound retained storage, not the space needed by an active scan.
            static constexpr size_t MAX_CACHED_BYTES = 1024 * 1024;
            if (BlockBytes() > MAX_CACHED_BYTES - bytes) {
                delete block;
                return;
            }
            block->next = head;
            head = block;
            bytes += BlockBytes();
        }

        Block* head = nullptr;
        size_t bytes = 0;
    };

    std::unique_ptr<Entry[]> entries;
    MAddress heapStart = 0;
    size_t unitCount = 0;
};

class __attribute__((visibility("hidden"))) Verifier {
public:
    explicit Verifier(size_t cycle) : gcCycle(cycle) {}

    bool Verify(HeapVerifier::Checkpoint checkpoint)
    {
        ScopedEnterSaferegion enterSaferegion(false);
        uint64_t startTime;
        checkRememberedEdges = checkpoint == HeapVerifier::Checkpoint::PRE_GC &&
            Heap::GetGCMode() == GCMode::GENERATIONAL;
        bool reusedSTW;
        {
            std::lock_guard<std::mutex> maintenance(Heap::GetHeap().GetFinalizerProcessor().heapMaintenanceLock);
            startTime = TimeUtil::NanoSeconds();
            // VerifyAt is called by the GC while it owns ScopedSTWLock. Thus any
            // active STW is owned by this thread, rather than a concurrent caller.
            // ScopedSTWLock alone does not stop mutators.
            reusedSTW = MutatorManager::Instance().WorldStopped();
            if (reusedSTW) {
                Scan();
            } else {
                ScopedStopTheWorld stw("heap verify");
                Scan();
            }
        }
        size_t durationUs = static_cast<size_t>((TimeUtil::NanoSeconds() - startTime) / 1000);
        // No heap addresses are consulted when recycling buffers. The caller
        // still owns the GC serialization lock, so the cache needs no new lock.
        visitedHeapObjects.Release();
        // Records own their contents; file I/O does not need a stable heap.
        FlushRecords();
        ReportSummary(checkpoint, durationUs, reusedSTW);
        return valid;
    }

private:
    void Scan()
    {
        auto& allocator = Heap::GetHeap().GetAllocator();
        MAddress limit = static_cast<RegionSpace&>(allocator).GetRegionManager().GetInactiveZone();
        if (!visitedHeapObjects.Init(allocator.GetSpaceStartAddress(), limit)) {
            Incomplete("cannot initialize visit bitmap directory");
            return;
        }
        CheckRoots();
        // Check layout for every allocation, but references only along the
        // verification graph. Unreachable allocations may retain stale fields.
        source = "reachable-heap-object";
        while (scanComplete && !pendingHeapObjects.empty()) {
            auto pending = pendingHeapObjects.back();
            pendingHeapObjects.pop_back();
            CheckReferences(pending.object, pending.size);
        }
        // Reuse validated layouts and inspect only the remaining allocations.
        if (scanComplete) {
            source = "heap-object";
            CheckHeap();
        }
    }

    __attribute__((format(printf, 3, 4)))
    static void FormatMessage(char* message, size_t capacity, const char* format, ...)
    {
        if (capacity == 0) {
            return;
        }
        message[0] = '\0';
        va_list args;
        va_start(args, format);
        int length = vsnprintf_s(message, capacity, capacity - 1, format, args);
        va_end(args);
        // SecureC returns -1 on truncation too; retain that terminated prefix.
        if (length < 0 && message[0] == '\0') {
            constexpr char fallback[] = "log formatting failed";
            size_t bytes = std::min(capacity - 1, sizeof(fallback) - 1);
            if (memcpy_s(message, capacity, fallback, bytes) != EOK) {
                message[0] = '\0';
                return;
            }
            message[bytes] = '\0';
        }
    }

    void ReportSummary(HeapVerifier::Checkpoint checkpoint, size_t durationUs, bool reusedSTW)
    {
        // Summaries bypass the detail buffer so they survive its size limit.
        char rememberedEdges[64] = {};
        if (checkRememberedEdges) {
            FormatMessage(rememberedEdges, sizeof(rememberedEdges),
                " old-to-young-edges=%zu", rememberedEdgeCount);
        }
        char summary[MAX_RECORD_SIZE];
        FormatMessage(summary, sizeof(summary),
            "checkpoint=%s %s complete=%s errors=%zu heap-objects=%zu roots=%zu stack-objects=%zu "
            "unchecked-nonheap-references=%zu time-us=%zu stw=%s%s gc-cycle=%zu",
            checkpoint == HeapVerifier::Checkpoint::PRE_GC ? "pre-GC" : "post-GC",
            valid ? "passed" : "failed", scanComplete ? "true" : "false", failureCount,
            heapObjectCount, rootCount, stackObjects.size(), uncheckedNonHeapCount, durationUs,
            reusedSTW ? "reused" : "requested", rememberedEdges, gcCycle);
        if (!valid && !ENABLE_LOG(HEAP_VERIFY)) {
            LOG(RTLOG_ERROR, "[HeapVerify] %s", summary);
        }
        VLOG(HEAP_VERIFY, "[HeapVerify] %s", summary);
    }

    // Lower bound for object and TypeInfo addresses accepted by HeapVerify.
    // This is a cheap filter, not a guarantee that an address is readable.
    static constexpr uintptr_t MIN_VALID_ADDRESS = 0x100;
    static constexpr size_t MAX_RECORD_BUFFER_SIZE = 64 * 1024;
    static constexpr size_t MAX_RECORD_SIZE = 512;

    void Incomplete(const char* reason)
    {
        scanComplete = false;
        Fail(reason, nullptr);
    }

    void Record(const char* format, ...)
    {
        if (!ENABLE_LOG(HEAP_VERIFY)) {
            return;
        }
        if (omittedRecords != 0) {
            ++omittedRecords;
            return;
        }
        char message[MAX_RECORD_SIZE] = {};
        va_list args;
        va_start(args, format);
        // count < destMax retains a terminated prefix when the record is truncated.
        int length = vsnprintf_s(message, sizeof(message), sizeof(message) - 1, format, args);
        va_end(args);
        if (length >= 0 || message[0] != '\0') {
            size_t bytes = std::strlen(message) + 1;
            if (bytes > MAX_RECORD_BUFFER_SIZE - recordBytes) {
                ++omittedRecords;
                return;
            }
            if (records == nullptr) {
                records.reset(new (std::nothrow) char[MAX_RECORD_BUFFER_SIZE]);
                if (records == nullptr) {
                    ++omittedRecords;
                    return;
                }
            }
            if (memcpy_s(records.get() + recordBytes, MAX_RECORD_BUFFER_SIZE - recordBytes, message, bytes) != EOK) {
                ++omittedRecords;
                return;
            }
            recordBytes += bytes;
        }
    }

    void FlushRecords()
    {
        for (size_t offset = 0; offset < recordBytes;) {
            const char* record = records.get() + offset;
            VLOG(HEAP_VERIFY, "[HeapVerify] %s", record);
            offset += std::strlen(record) + 1;
        }
        if (omittedRecords != 0) {
            VLOG(HEAP_VERIFY, "[HeapVerify] detail buffer limit=%zu bytes; omitted-records=%zu gc-cycle=%zu",
                MAX_RECORD_BUFFER_SIZE, omittedRecords, gcCycle);
        }
    }

    // Build diagnostic text only; failure state and log routing belong to Fail.
    void FormatFailureMessage(char* message, size_t capacity, const char* reason, const BaseObject* object,
                              MAddress field, MAddress target) const
    {
        if (field != 0 && object == nullptr) {
            FormatMessage(message, capacity,
                "%s source=%s; root reference slot at %p contains object address %p",
                reason, source, reinterpret_cast<void*>(field), reinterpret_cast<void*>(target));
        } else if (field != 0 && target != 0) {
            FormatMessage(message, capacity,
                "%s source=%s; reference slot at %p in object %p contains object address %p",
                reason, source, reinterpret_cast<void*>(field), object, reinterpret_cast<void*>(target));
        } else if (field != 0) {
            // The slot failed its boundary check, so its contents were not read.
            FormatMessage(message, capacity,
                "%s source=%s; reference slot at %p is outside object %p",
                reason, source, reinterpret_cast<void*>(field), object);
        } else if (object != nullptr) {
            FormatMessage(message, capacity,
                "%s source=%s; checked address %p", reason, source, object);
        } else {
            FormatMessage(message, capacity, "%s source=%s", reason, source);
        }
        if (rootContext != nullptr) {
            size_t used = std::strlen(message);
            FormatMessage(message + used, capacity - used,
                "; root from mutator %p", rootContext->mutator);
            used = std::strlen(message);
            if (rootContext->pc != 0) {
                FormatMessage(message + used, capacity - used,
                    "; stackmap pc %p frame %p", reinterpret_cast<void*>(rootContext->pc),
                    reinterpret_cast<void*>(rootContext->frame));
                used = std::strlen(message);
            }
            if (rootContext->location == VerifyStackRootContext::Location::STACK_SLOT) {
                FormatMessage(message + used, capacity - used,
                    ", stack slot offset %d", static_cast<int>(rootContext->slotOffset));
            } else if (rootContext->location == VerifyStackRootContext::Location::REGISTER) {
                FormatMessage(message + used, capacity - used,
                    ", register %s (saved slot above)", GetRegisterName(rootContext->reg));
            }
        } else if (stackOwner != nullptr) {
            size_t used = std::strlen(message);
            FormatMessage(message + used, capacity - used,
                "; while scanning stack objects of mutator %p", stackOwner);
        }
    }

    void Fail(const char* reason, const BaseObject* object, MAddress field = 0, MAddress target = 0)
    {
        valid = false;
        ++failureCount;
        // Leave room for the cycle suffix in the bounded dedicated record.
        constexpr size_t cycleSuffixSize = sizeof("; gc-cycle=") + std::numeric_limits<size_t>::digits10 + 1;
        char message[MAX_RECORD_SIZE - cycleSuffixSize];
        FormatFailureMessage(message, sizeof(message), reason, object, field, target);
        // Prefer the configured dedicated file. Fall back to Runtime ERROR
        // when its path is absent or could not be opened.
        if (!ENABLE_LOG(HEAP_VERIFY)) {
            LOG(RTLOG_ERROR, "[HeapVerify] %s; gc-cycle=%zu", message, gcCycle);
        }
        Record("%s; gc-cycle=%zu", message, gcCycle);
    }

    // TypeInfo is metadata, not a heap object. Do only cheap pointer-shape
    // checks here, rejecting addresses below MIN_VALID_ADDRESS before dereferencing;
    // walking metadata mappings or loaded images would add a
    // linear cost to every object and race native image unload. This does not
    // establish readability: subsequent field checks still trust the address.
    static bool IsPlausibleTypeInfoPointer(const TypeInfo* typeInfo)
    {
        uintptr_t address = reinterpret_cast<uintptr_t>(typeInfo);
        // TypeInfoManager::Allocate only guarantees alignment on ARM32. On
        // other targets its byte-granular arena can produce valid unaligned TI.
#ifdef __arm__
        return address >= MIN_VALID_ADDRESS && address % alignof(TypeInfo) == 0;
#else
        return address >= MIN_VALID_ADDRESS;
#endif
    }

    bool CheckTypeInfo(BaseObject* object, TypeInfo*& typeInfo)
    {
        // CheckLayout establishes the object header boundary before this read.
        typeInfo = object->GetTypeInfo();
        if (typeInfo == nullptr) {
            Fail("invalid object state", object);
            return false;
        }
        if (!IsPlausibleTypeInfoPointer(typeInfo)) {
            Fail("invalid type info", object);
            return false;
        }
        // Kind is the first TypeInfo field inspected. It filters corrupt
        // metadata, but cannot establish that an arbitrary pointer is readable.
        if (!typeInfo->IsVaildType()) {
            Fail("invalid type info", object);
            return false;
        }
        return true;
    }

    void CheckHeap()
    {
        auto& allocator = Heap::GetHeap().GetAllocator();
        auto& manager = static_cast<RegionSpace&>(allocator).GetRegionManager();
        MAddress limit = manager.GetInactiveZone();
        for (MAddress address = allocator.GetSpaceStartAddress(); address < limit;) {
            auto* region = RegionInfo::GetRegionInfoAt(address);
            MAddress end = region->GetRegionEnd();
            if (end <= address || end > limit) {
                Fail("invalid region boundary", reinterpret_cast<BaseObject*>(address));
                scanComplete = false;
                break;
            }
            if (!region->IsValidRegion() || region->IsGarbageRegion()) {
                address = end;
                continue;
            }
            if (region->IsLargeRegion()) {
                CheckAllocation(reinterpret_cast<BaseObject*>(address), end);
                address = end;
                continue;
            }
            MAddress allocatedEnd = region->GetRegionAllocPtr();
            if (allocatedEnd < address || allocatedEnd > end) {
                Fail("invalid allocation boundary", reinterpret_cast<BaseObject*>(address));
                scanComplete = false;
            } else {
                CheckRegion(address, allocatedEnd, end);
            }
            address = end;
        }
    }

    void CheckRegion(MAddress address, MAddress end, MAddress regionEnd)
    {
        while (address < end) {
            if (sizeof(FreeSlotNode) > end - address) {
                Fail("truncated allocation header", reinterpret_cast<BaseObject*>(address));
                scanComplete = false;
                break;
            }
            auto* slot = FreeSlotNode::Cast(address);
            bool freeSlot = slot->IsValidSlot();
            size_t size = freeSlot ? slot->slotSize :
                CheckAllocation(reinterpret_cast<BaseObject*>(address), end);
            // A trailing free slot can extend beyond allocPtr after sweeping.
            MAddress bound = freeSlot ? regionEnd : end;
            if (size == 0 || size > bound - address || size % Allocator::ALLOC_ALIGN != 0) {
                // A damaged size cannot safely locate the next allocation.
                // Continue with the next region rather than guessing a header.
                Fail("invalid allocation stride", reinterpret_cast<BaseObject*>(address));
                scanComplete = false;
                break;
            }
            address += size;
        }
    }

    // The array header must fit before its length is read. Validate the 64-bit
    // length before narrowing it to size_t, including on ARM32.
    size_t CheckArraySize(BaseObject* object, TypeInfo* typeInfo, size_t availableBytes)
    {
        if (MArray::GetContentOffset() > availableBytes) {
            Fail("array header outside boundary", object);
            return 0;
        }
        TypeInfo* component = typeInfo->GetComponentTypeInfo();
        if (!IsPlausibleTypeInfoPointer(component) || !component->IsVaildType()) {
            Fail("invalid array component type", object);
            return 0;
        }
        size_t elementSize = component->IsRef() ? sizeof(BaseObject*) : component->GetComponentSize();
        MIndex length = reinterpret_cast<MArray*>(object)->GetLength();
        if (elementSize != 0 && length > (std::numeric_limits<size_t>::max() - MArray::GetContentOffset()) /
            elementSize) {
            Fail("array size overflow", object);
            return 0;
        }
        return MArray::GetContentOffset() + elementSize * static_cast<size_t>(length);
    }

    // The caller establishes the readable range before examining a header. In
    // particular, a non-heap address alone is never evidence of an object.
    size_t CheckLayout(BaseObject* object, MAddress end, bool heapObject)
    {
        MAddress begin = reinterpret_cast<MAddress>(object);
        if (begin < MIN_VALID_ADDRESS) {
            Fail("invalid object address", object, 0, begin);
            return 0;
        }
        if (begin % alignof(BaseObject) != 0 || begin > end || TYPEINFO_PTR_SIZE > end - begin) {
            Fail("object header outside boundary or misaligned", object);
            return 0;
        }
        TypeInfo* typeInfo = nullptr;
        if (!CheckTypeInfo(object, typeInfo)) {
            return 0;
        }
        GCTib gcTib = typeInfo->GetGCTib();
        if (!typeInfo->IsArrayType() && typeInfo->HasRefField() &&
            !gcTib.IsGCTibWord() && gcTib.gctib == nullptr) {
            Fail("missing reference layout", object);
            return 0;
        }

        size_t expectedSize;
        if (typeInfo->IsArrayType()) {
            expectedSize = CheckArraySize(object, typeInfo, end - begin);
            if (expectedSize == 0) {
                return 0;
            }
        } else {
            size_t instanceSize = typeInfo->GetInstanceSize();
            if (instanceSize > std::numeric_limits<size_t>::max() - TYPEINFO_PTR_SIZE) {
                Fail("object size overflow", object);
                return 0;
            }
            expectedSize = TYPEINFO_PTR_SIZE + instanceSize;
        }
        if (expectedSize == 0 || expectedSize > std::numeric_limits<size_t>::max() - Allocator::ALLOC_ALIGN) {
            Fail("invalid object size", object);
            return 0;
        }
        // Stack allocations need not include the allocator's trailing padding.
        size_t boundedSize = heapObject ? RoundUp<size_t>(expectedSize, Allocator::ALLOC_ALIGN) : expectedSize;
        if (boundedSize > end - begin) {
            Fail("object layout or boundary mismatch", object);
            return 0;
        }
        return expectedSize;
    }

    size_t CheckAllocation(BaseObject* object, MAddress end)
    {
        ++heapObjectCount;
        if (visitedHeapObjects.Contains(reinterpret_cast<MAddress>(object))) {
            // The same stable snapshot already validated this layout. Read
            // only the size needed to locate the next allocation; CheckRegion
            // still checks the resulting stride before advancing.
            return RegionSpace::GetAllocSize(*object);
        }
        size_t size = CheckLayout(object, end, true);
        if (size != 0) {
            return RegionSpace::ToAllocSize(RoundUp<size_t>(size, Allocator::ALLOC_ALIGN));
        }
        return 0;
    }

    void CheckReferences(BaseObject* object, size_t size, Mutator* owner = nullptr)
    {
        MAddress begin = reinterpret_cast<MAddress>(object);
        RegionInfo* rememberedRegion = nullptr;
        if (checkRememberedEdges && owner == nullptr && !object->IsWeakRef()) {
            RegionInfo* region = RegionInfo::GetRegionInfoAt(begin);
            if (region->IsOldRegion()) {
                rememberedRegion = region;
            }
        }
        object->ForEachRefField([this, object, begin, size, owner, rememberedRegion](RefField<>& field) {
            if (!scanComplete) {
                return;
            }
            MAddress address = reinterpret_cast<MAddress>(&field);
            if (address < begin + TYPEINFO_PTR_SIZE || address > begin + size ||
                sizeof(field) > begin + size - address) {
                Fail("reference field outside object layout", object, address);
                return;
            }
            RefField<> reference(field);
            if (CheckTarget(object, address, reference, owner) && rememberedRegion != nullptr) {
                CheckRememberedEdge(object, address, reference, *rememberedRegion);
            }
        });
    }

    // CheckTarget has accepted this heap target; tagged routes are excluded
    // because the original field still contains the pre-resolution address.
    void CheckRememberedEdge(BaseObject* object, MAddress field, RefField<> reference, RegionInfo& sourceRegion)
    {
        if (reference.IsTagged()) {
            return;
        }
        // Derive the edge from the actual field value and region generation flags,
        // independently of the remembered-set bit that is checked below.
        BaseObject* target = reference.GetTargetObject();
        if (RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(target))->IsOldRegion()) {
            return;
        }
        ++rememberedEdgeCount;
        size_t slotIndex = (field - sourceRegion.GetRegionStart()) / RegionInfo::RSET_SLOT_SIZE;
        if (!sourceRegion.IsRSetSlotMarked(slotIndex)) {
            const char* previousSource = source;
            source = "reachable-old-to-young";
            Fail("old-to-young reference missing remembered-set slot", object, field,
                reinterpret_cast<MAddress>(target));
            source = previousSource;
        }
    }

    // This checks region/allocation bounds, not membership in an object-start
    // index. In particular, aligned interior pointers can still pass.
    MAddress GetHeapObjectEnd(BaseObject* object)
    {
        MAddress address = reinterpret_cast<MAddress>(object);
        if (address < MIN_VALID_ADDRESS || address % Allocator::ALLOC_ALIGN != 0 ||
            !Heap::IsHeapAddress(address)) {
            return 0;
        }
        auto& space = static_cast<RegionSpace&>(Heap::GetHeap().GetAllocator());
        MAddress limit = space.GetRegionManager().GetInactiveZone();
        if (address >= limit) {
            return 0;
        }
        auto* region = RegionInfo::GetRegionInfoAt(address);
        MAddress start = region->GetRegionStart();
        MAddress end = region->GetRegionEnd();
        if (!region->IsValidRegion() || region->IsGarbageRegion() || start > address ||
            end <= address || end > limit) {
            return 0;
        }
        if (region->IsLargeRegion()) {
            return address == start && TYPEINFO_PTR_SIZE <= end - address ? end : 0;
        }
        MAddress allocatedEnd = region->GetRegionAllocPtr();
        if (allocatedEnd < start || allocatedEnd > end || address >= allocatedEnd ||
            sizeof(FreeSlotNode) > allocatedEnd - address ||
            FreeSlotNode::Cast(address)->IsValidSlot()) {
            return 0;
        }
        return allocatedEnd;
    }

    void CheckNonHeapTarget(BaseObject* target, Mutator* owner)
    {
        // Follow stack objects only from their owning mutator's roots, as GC
        // does. Image constants and native scheduler handles also occur here;
        // neither may be dereferenced as an arbitrary BaseObject.
        if (owner != nullptr && owner->IsStackAddr(reinterpret_cast<MAddress>(target))) {
            if (stackObjects.insert(target).second) {
                pendingStackObjects.push_back(target);
            }
        } else {
            ++uncheckedNonHeapCount;
        }
    }

    // True only for a heap target whose layout has passed this snapshot's
    // checks; callers may then inspect its generation for RSet verification.
    bool CheckTarget(const BaseObject* holder, MAddress field, RefField<> reference, Mutator* owner = nullptr)
    {
        if (!scanComplete) {
            return false;
        }
        BaseObject* target = reference.GetTargetObject();
        if (target == nullptr) {
            return false;
        }
        MAddress rawTarget = reinterpret_cast<MAddress>(target);
        if (rawTarget < MIN_VALID_ADDRESS) {
            Fail("invalid object address", holder, field, rawTarget);
            return false;
        }
        if (!Heap::IsHeapAddress(rawTarget)) {
            CheckNonHeapTarget(target, owner);
            return false;
        }
        // FindToVersion may prepare GC routes or assert on dead references.
        // Diagnostics must only consult an already recorded route.
        if (reference.IsTagged()) {
            auto* ghost = RegionInfo::GetGhostFromRegionAt(rawTarget);
            if (ghost != nullptr) {
                target = ghost->FindRecordedRouteForVerify(target);
                if (target == nullptr) {
                    Fail("tagged reference has no recorded live route", holder, field, rawTarget);
                    return false;
                }
            }
        }
        // The entire traversal runs in one stable snapshot. An address enters
        // this bitmap only after its region and layout have passed, so shared
        // references need neither another region lookup nor another layout scan.
        if (visitedHeapObjects.Contains(reinterpret_cast<MAddress>(target))) {
            return true;
        }
        MAddress end = GetHeapObjectEnd(target);
        if (end == 0) {
            Fail("reference target is not an active heap object", holder, field, rawTarget);
            return false;
        }
        size_t size = CheckLayout(target, end, true);
        if (size == 0) {
            return false;
        }
        if (!visitedHeapObjects.Record(target)) {
            Incomplete("cannot allocate visit bitmap block");
            return false;
        }
        // Leaf objects still need validation and deduplication, but have no
        // outgoing references to put on the work stack.
        if (target->HasRefField()) {
            pendingHeapObjects.push_back({ target, size });
        }
        return true;
    }

    void CheckRoots()
    {
        Heap& heap = Heap::GetHeap();
        source = "static-root";
        RefFieldVisitor staticVisitor = [this](RefField<>& field) {
            ++rootCount;
            CheckTarget(nullptr, reinterpret_cast<MAddress>(&field), RefField<>(field));
        };
        heap.VisitStaticRoots(staticVisitor);

        RootVisitor rootVisitor = [this](ObjectRef& root) {
            ++rootCount;
            // Generic roots may carry encoded fields (for example finalizer
            // lists), while VisitMutatorRoots supplies raw object pointers.
            RefField<> reference(reinterpret_cast<MAddress>(root.object));
            CheckTarget(nullptr, reinterpret_cast<MAddress>(&root), reference);
        };
        source = "export-root";
        heap.VisitAllExportRoots(rootVisitor);
        source = "concurrency-root";
        Runtime::Current().GetConcurrencyModel().VisitGCRoots(&rootVisitor);
        source = "finalizer-root";
        heap.GetFinalizerProcessor().VisitGCRoots(rootVisitor);
        source = "mutator-root";
        MutatorManager::Instance().VisitAllMutators([this](Mutator& mutator) { CheckMutatorRoots(mutator); });
    }

    void CheckMutatorRoots(Mutator& mutator)
    {
        if (!scanComplete) {
            return;
        }
        VerifyStackRootContext context;
        RootVisitor visitor = [this, &mutator, &context](ObjectRef& root) {
            ++rootCount;
            rootContext = &context;
            CheckTarget(nullptr, reinterpret_cast<MAddress>(&root), RefField<>(root.object), &mutator);
            rootContext = nullptr;
        };
        if (!mutator.VisitRootsForVerify(visitor, context)) {
            rootContext = &context;
            Incomplete("invalid or unsupported stack root metadata");
            rootContext = nullptr;
            return;
        }
        // Local-to-heap roots are encoded fields, unlike raw stack roots.
        RootVisitor localVisitor = [this, &mutator, &context](ObjectRef& root) {
            ++rootCount;
            rootContext = &context;
            CheckTarget(nullptr, reinterpret_cast<MAddress>(&root),
                RefField<>(reinterpret_cast<MAddress>(root.object)), &mutator);
            rootContext = nullptr;
        };
        mutator.VisitLocalObjectAllocatorRoots(localVisitor);
        CheckStackObjects(mutator);
    }

    void CheckStackObjects(Mutator& mutator)
    {
        // Do not recurse on the native stack or nest VisitAllMutators.
        // Deduplication covers cycles and shared stack objects.
        MAddress start = mutator.GetStackTopAddr();
        size_t stackSize = mutator.GetStackSize();
        if (stackSize > std::numeric_limits<MAddress>::max() - start) {
            Incomplete("invalid mutator stack boundary");
            pendingStackObjects.clear();
            return;
        }
        source = "stack-object";
        stackOwner = &mutator;
        while (scanComplete && !pendingStackObjects.empty()) {
            BaseObject* object = pendingStackObjects.back();
            pendingStackObjects.pop_back();
            size_t size = CheckLayout(object, start + stackSize, false);
            if (size != 0) {
                CheckReferences(object, size, &mutator);
            }
        }
        stackOwner = nullptr;
        source = "mutator-root";
    }

    struct PendingHeapObject {
        BaseObject* object;
        size_t size;
    };
    // Heap visits use independent per-unit bits, never the GC's mark bitmap.
    // Non-heap objects do not participate in the allocation walk or these bits.
    VerifyVisitBitmap visitedHeapObjects;
    std::unordered_set<BaseObject*> stackObjects;
    std::vector<BaseObject*> pendingStackObjects;
    std::vector<PendingHeapObject> pendingHeapObjects;
    const char* source { "heap-object" };
    const size_t gcCycle;
    // Only valid during the synchronous root callback; never stored with pending objects.
    const VerifyStackRootContext* rootContext = nullptr;
    const Mutator* stackOwner = nullptr;
    bool valid { true };
    bool scanComplete { true };
    size_t failureCount { 0 };
    size_t heapObjectCount { 0 };
    size_t rootCount { 0 };
    size_t uncheckedNonHeapCount { 0 };
    size_t rememberedEdgeCount { 0 };
    bool checkRememberedEdges { false };
    std::unique_ptr<char[]> records;
    size_t recordBytes { 0 };
    size_t omittedRecords { 0 };
};

void HeapVerifier::Init()
{
    Mode mode = ReadModeFromEnv();
    heapVerifyMode = mode;
    if (mode != Mode::DISABLED) {
        const char* checkpoints = mode == Mode::PRE_GC ? "before" :
            (mode == Mode::POST_GC ? "after" : "before and after");
        VLOG(HEAP_VERIFY, "[HeapVerify] mode=%u; heap will be checked %s each GC",
            static_cast<unsigned int>(mode), checkpoints);
    }
}

bool HeapVerifier::IsEnabled()
{
    return heapVerifyMode != Mode::DISABLED;
}

bool HeapVerifier::VerifyAt(Checkpoint checkpoint, size_t gcCycle)
{
    Mode mode = heapVerifyMode;
    if (mode == Mode::DISABLED || (mode == Mode::PRE_GC && checkpoint == Checkpoint::POST_GC) ||
        (mode == Mode::POST_GC && checkpoint == Checkpoint::PRE_GC)) {
        return true;
    }
    Verifier verifier(gcCycle);
    return verifier.Verify(checkpoint);
}
} // namespace MapleRuntime
