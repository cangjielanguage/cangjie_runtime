// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "PostTraceBarrier.h"

#include "Mutator/Mutator.h"
#include "ObjectModel/MArray.h"
#include "ObjectModel/RefField.inline.h"
#if defined(CANGJIE_TSAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

namespace MapleRuntime {
BaseObject* PostTraceBarrier::ReadReference(BaseObject* obj, RefField<false>& field) const
{
    RefField<> tmpField(field);
    if (tmpField.IsTagged()) {
        CHECK(theCollector.IsCurrentPointer(tmpField));
    }
    return tmpField.GetTargetObject();
}

BaseObject* PostTraceBarrier::ReadStaticRef(RefField<false>& field) const { return ReadReference(nullptr, field); }

BaseObject* PostTraceBarrier::ReadWeakRef(BaseObject* obj, RefField<false>& field) const
{
    RefField<> tmpField(field);
    if (tmpField.IsTagged()) {
        CHECK(theCollector.IsCurrentPointer(tmpField));
    }
    BaseObject* referent = tmpField.GetTargetObject();
    if (referent == nullptr || !theCollector.IsTargetAddress(referent)) {
        return referent;
    }
    RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(referent));
    size_t offset = regionInfo->GetAddressOffset(reinterpret_cast<MAddress>(referent));
    if (regionInfo->IsMarkedObject(offset)) {
        return referent;
    }
    // Complete weak-reference promotion if the referent has not been marked yet.
    if (regionInfo->IsLoadedWeakRef(offset)) {
        if (!regionInfo->MarkObject(referent)) {
            regionInfo->AddLiveByteCount(referent->GetSize());
        }
        return referent;
    }
    // Objects in retained allocation regions do not need a mark for this collection.
    if (!regionInfo->IsWgcCollectionRegion()) {
        return referent;
    }
    void** referentAddr = reinterpret_cast<void**>(reinterpret_cast<uintptr_t>(obj) + TYPEINFO_PTR_SIZE);
    DLOG(BARRIER, "update referent@%p: 0x%zx -> %p", referentAddr, *referentAddr, nullptr);
    *referentAddr = nullptr; // set referent field as null
    return nullptr;
}

void PostTraceBarrier::ReadStruct(MAddress dst, BaseObject* obj, MAddress src, size_t size) const
{
    LocalRefFieldContainer refFields;
    if (obj != nullptr) {
        obj->ForEachRefInStruct(
            [this, obj, &refFields, dst, src, size](RefField<false>& field) {
                if (reinterpret_cast<MAddress>(&field) < src || reinterpret_cast<MAddress>(&field) >= (src + size)) {
                    return;
                }
                (void)ReadReference(obj, field);
                MAddress offset = reinterpret_cast<MAddress>(&field) - src;
                refFields.Push(reinterpret_cast<RefField<>*>(dst + offset));
            },
            src, src + size);
    }

    CHECK(memcpy_s(reinterpret_cast<void*>(dst), size, reinterpret_cast<void*>(src), size) == EOK);
    refFields.VisitRefField([this](RefField<>& dstRef) {
        BaseObject* target = nullptr;
        if (theCollector.IsCurrentPointer(dstRef)) {
            theCollector.TryUntagRefField(nullptr, dstRef, target);
        }
    });
}

void PostTraceBarrier::ReadStaticStruct(MAddress dst, MAddress src, size_t size, const GCTib gctib) const
{
    LocalRefFieldContainer refFields;
    gctib.ForEachBitmapWordInRange(
        src,
        [this, &refFields, dst, src](RefField<>& srcField) {
            (void)ReadReference(nullptr, srcField);
            MAddress offset = reinterpret_cast<MAddress>(&srcField) - src;
            refFields.Push(reinterpret_cast<RefField<>*>(dst + offset));
        },
        src, src + size);

    CHECK(memcpy_s(reinterpret_cast<void*>(dst), size, reinterpret_cast<void*>(src), size) == EOK);
    refFields.VisitRefField([this](RefField<>& dstRef) {
        BaseObject* target = nullptr;
        if (theCollector.IsCurrentPointer(dstRef)) {
            theCollector.TryUntagRefField(nullptr, dstRef, target);
        }
    });
}

void PostTraceBarrier::WriteReference(BaseObject* obj, RefField<false>& field, BaseObject* ref) const
{
    RefField<> tmpField(field);
    CHECK(!theCollector.IsOldPointer(tmpField));
    DLOG(BARRIER, "write obj %p ref-field@%p: %#zx -> %p", obj, &field, tmpField.GetFieldValue(), ref);
    RefField<> newField = theCollector.GetAndTryTagRefField(ref);
    field.SetFieldValue(newField.GetFieldValue());
}

void PostTraceBarrier::WriteStaticRef(RefField<false>& field, BaseObject* ref) const
{
    RefField<> newField = theCollector.GetAndTryTagRefField(ref);
    field.SetFieldValue(newField.GetFieldValue());
}

void PostTraceBarrier::WriteStruct(BaseObject* obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen) const
{
    CHECK(obj != nullptr);
    CHECK(memcpy_s(reinterpret_cast<void*>(dst), dstLen, reinterpret_cast<void*>(src), srcLen) == EOK);

    if (obj != nullptr) {
        obj->ForEachRefInStruct(
            [=](RefField<>& refField) {
                RefField<> oldField(refField);
                MAddress oldValue = oldField.GetFieldValue();
                BaseObject* latestVerison = ReadReference(nullptr, oldField);
                RefField<> newField = theCollector.GetAndTryTagRefField(latestVerison);
                if (oldValue != newField.GetFieldValue()) {
                    refField.CompareExchange(oldValue, newField.GetFieldValue());
                }
            },
            dst, dst + dstLen);
    }

#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dst), dstLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(src), srcLen);
#endif
}

void PostTraceBarrier::WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen,
                                         const GCTib gctib) const
{
    CHECK(memcpy_s(reinterpret_cast<void*>(dst), dstLen, reinterpret_cast<void*>(src), srcLen) == EOK);

    gctib.ForEachBitmapWord(dst, [=](RefField<>& refField) {
        RefField<> oldField(refField);
        MAddress oldValue = oldField.GetFieldValue();
        BaseObject* untagged = ReadReference(nullptr, oldField);
        RefField<> newField = theCollector.GetAndTryTagRefField(untagged);
        if (oldValue != newField.GetFieldValue()) {
            refField.CompareExchange(oldValue, newField.GetFieldValue());
        }
    });
    DLOG(TRACE, "write static struct@[%#zx, %#zx) with [%#zx, %#zx)", dst, dst + dstLen, src, src + srcLen);

#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dst), dstLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(src), srcLen);
#endif
}

BaseObject* PostTraceBarrier::AtomicReadReference(BaseObject* obj, RefField<true>& field, MemoryOrder order) const
{
    BaseObject* target = nullptr;
    RefField<false> oldField(field.GetFieldValue(order));
    if (theCollector.IsCurrentPointer(oldField)) {
        target = oldField.GetTargetObject();
        DLOG(TBARRIER, "atomic read obj %p ref@%p: %#zx -> %p", obj, &field, oldField.GetFieldValue(), target);
        return target;
    }

    BaseObject* toVersion = nullptr;
    // note TryUpdateRefField and TryUntagRefField are all atomic operations.
    if (theCollector.TryUpdateRefField(obj, reinterpret_cast<RefField<false>&>(field), toVersion)) {
        DLOG(TBARRIER, "iatomic read obj %p ref@%p: %#zx -> %p", obj, &field, oldField.GetFieldValue(), toVersion);
        return toVersion;
    }

    if (theCollector.TryUntagRefField(obj, reinterpret_cast<RefField<false>&>(field), target)) {
        DLOG(TBARRIER, "jatomic read obj %p ref@%p: %#zx -> %p", obj, &field, oldField.GetFieldValue(), target);
        return target;
    }

    target = ReadReference(nullptr, oldField);
    DLOG(TBARRIER, "katomic read obj %p ref@%p: %#zx -> %p", obj, &field, oldField.GetFieldValue(), target);
    return target;
}

void PostTraceBarrier::AtomicWriteReference(BaseObject* obj, RefField<true>& field, BaseObject* newRef,
                                            MemoryOrder order) const
{
    RefField<> oldField(field.GetFieldValue(order));
    MAddress oldValue = oldField.GetFieldValue();
    (void)oldValue;
    RefField<> newField = theCollector.GetAndTryTagRefField(newRef);
    field.SetFieldValue(newField.GetFieldValue(), order);
    if (obj != nullptr) {
        DLOG(TBARRIER, "atomic write obj %p<%p>(%zu) ref@%p: %#zx -> %#zx", obj, obj->GetTypeInfo(), obj->GetSize(),
             &field, oldValue, newField.GetFieldValue());
    } else {
        DLOG(TBARRIER, "atomic write static ref@%p: %#zx -> %#zx", &field, oldValue, newField.GetFieldValue());
    }
}

BaseObject* PostTraceBarrier::AtomicSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* newRef,
                                                  MemoryOrder order) const
{
    RefField<> newField = theCollector.GetAndTryTagRefField(newRef);
    MAddress oldValue = field.Exchange(newField.GetFieldValue(), order);
    RefField<> oldField(oldValue);
    BaseObject* oldRef = ReadReference(nullptr, oldField);
    DLOG(TRACE, "atomic swap obj %p<%p>(%zu) ref-field@%p: old %#zx(%p), new %#zx(%p)", obj, obj->GetTypeInfo(),
         obj->GetSize(), &field, oldValue, oldRef, field.GetFieldValue(), newRef);
    return oldRef;
}

bool PostTraceBarrier::CompareAndSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* oldRef,
                                               BaseObject* newRef, MemoryOrder succOrder, MemoryOrder failOrder) const
{
    MAddress oldFieldValue = field.GetFieldValue(std::memory_order_seq_cst);
    RefField<false> oldField(oldFieldValue);
    BaseObject* oldVersion = ReadReference(nullptr, oldField);
    RefField<> newField = theCollector.GetAndTryTagRefField(newRef);
    while (oldVersion == oldRef) {
        if (field.CompareExchange(oldFieldValue, newField.GetFieldValue(), succOrder, failOrder)) {
            return true;
        }
        oldFieldValue = field.GetFieldValue(std::memory_order_seq_cst);
        RefField<false> oldField(oldFieldValue);
        oldVersion = ReadReference(nullptr, oldField);
    }
    return false;
}

void PostTraceBarrier::CopyStructArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize, BaseObject* srcObj,
                                       MAddress srcField, MIndex srcSize) const
{
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    if (!dstObj->HasRefField()) {
        LOG(RTLOG_FATAL, "array %p doesn't have class-type element\n", dstObj);
        return;
    }
    if (!(static_cast<MArray*>(dstObj)->GetComponentTypeInfo()->IsStructType())) {
        LOG(RTLOG_FATAL, "array %p type is not struct type", dstObj);
        return;
    }
#endif
    bool inHeap = Heap::IsHeapAddress(srcObj);
    RefFieldVisitor srcVisitor = [this](RefField<false>& field) {
        RefField<> oldField(field);
        RefField<> toBeUpdated(oldField);
        BaseObject* target = ReadReference(nullptr, toBeUpdated);
        RefField<> newField = theCollector.GetAndTryTagRefField(target);
        if (newField.GetFieldValue() != oldField.GetFieldValue()) {
            field.CompareExchange(oldField.GetFieldValue(), newField.GetFieldValue());
        }
    };
    MArray* srcArray = static_cast<MArray*>(srcObj);
    if (!inHeap) {
        srcArray->ForEachRefFieldInRange(srcVisitor, srcField, srcField + srcSize);
    }
    CHECK_DETAIL(memmove_s(reinterpret_cast<void*>(dstField), dstSize, reinterpret_cast<void*>(srcField), srcSize) ==
                     EOK,
                 "memmove_s failed");

#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dstField), dstSize);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(srcField), srcSize);
#endif
}
} // namespace MapleRuntime
