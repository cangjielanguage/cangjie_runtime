// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Barrier.inline.h"
#include "Allocator/LocalObjectUtil.h"
#include "Heap/Collector/Collector.h"
#include "Heap/Heap.h"
#include "Mutator/Mutator.h"
#include "ObjectModel/Field.inline.h"
#include "ObjectModel/RefField.inline.h"
#if defined(CANGJIE_TSAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

namespace MapleRuntime {
extern "C" void MCC_MaybeLocalWriteStruct(const ObjectPtr obj, MAddress dst, size_t dstLen, MAddress src,
    size_t srcLen, GCTib gctib);

void Barrier::WriteI8(BaseObject* obj, Field<int8_t>& field, int8_t val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteI16(BaseObject* obj, Field<int16_t>& field, int16_t val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteI32(BaseObject* obj, Field<int32_t>& field, int32_t val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteI64(BaseObject* obj, Field<int64_t>& field, int64_t val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteF32(BaseObject* obj, Field<float>& field, float val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteF64(BaseObject* obj, Field<double>& field, double val) const { field.SetFieldValue(obj, val); }

void Barrier::WriteReference(BaseObject* obj, RefField<false>& field, BaseObject* ref) const
{
    DLOG(BARRIER, "write obj %p ref-field@%p: %p => %p", obj, &field, field.GetTargetObject(), ref);
    field.SetTargetObject(ref);
}

void Barrier::WriteStruct(BaseObject* obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen) const
{
    CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), dstLen, reinterpret_cast<void*>(src), srcLen) == EOK,
                 "memcpy_s failed");
#if defined(CANGJIE_TSAN_SUPPORT)
    CHECK_EQ(srcLen, dstLen);
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dst), dstLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(src), srcLen);
#endif
}

void Barrier::WriteStaticRef(RefField<false>& field, BaseObject* ref) const
{
    DLOG(BARRIER, "write (barrier) static ref@%p: %p", &field, ref);
    field.SetTargetObject(ref);
}

void Barrier::WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, const GCTib gctib) const
{
    CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), dstLen, reinterpret_cast<void*>(src), srcLen) == EOK,
                 "memcpy_s failed");
#if defined(CANGJIE_TSAN_SUPPORT)
    size_t copyLen = (dstLen < srcLen ? dstLen : srcLen);
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dst), copyLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(src), copyLen);
#endif
}

BaseObject* Barrier::ReadReference(BaseObject* obj, RefField<false>& field) const
{
    BaseObject* toVersion = nullptr;
    if (theCollector.TryUpdateRefField(obj, field, toVersion)) {
        return toVersion;
    } else {
        BaseObject* target = field.GetTargetObject();
        return target;
    }
}

BaseObject* Barrier::ReadWeakRef(BaseObject* obj, RefField<false>& field) const
{
    BaseObject* toVersion = nullptr;
    if (theCollector.TryUpdateRefField(obj, field, toVersion)) {
        return toVersion;
    } else {
        BaseObject* target = field.GetTargetObject();
        return target;
    }
}

BaseObject* Barrier::ReadStaticRef(RefField<false>& field) const
{
    BaseObject* toVersion = nullptr;
    if (theCollector.TryUpdateRefField(nullptr, field, toVersion)) {
        DLOG(BARRIER, "read static ref@%p: 0x%zx -> %p", &field, field.GetFieldValue(), toVersion);
        return toVersion;
    } else {
        BaseObject* target = field.GetTargetObject();
        return target;
    }
}

// barrier for atomic operation.
void Barrier::AtomicWriteReference(BaseObject* obj, RefField<true>& field, BaseObject* ref, MemoryOrder order) const
{
    if (obj != nullptr) {
        DLOG(BARRIER, "atomic write obj %p<%p>(%zu) ref@%p: %#zx -> %p", obj, obj->GetTypeInfo(), obj->GetSize(),
             &field, field.GetFieldValue(), ref);
    } else {
        DLOG(BARRIER, "atomic write static ref@%p: %#zx -> %p", &field, field.GetFieldValue(), ref);
    }

    field.SetTargetObject(ref, order);
}

BaseObject* Barrier::AtomicSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* newRef,
                                         MemoryOrder order) const
{
    MAddress oldValue = field.Exchange(newRef, order);
    RefField<> oldField(oldValue);
    BaseObject* oldRef = ReadReference(nullptr, oldField);
    DLOG(BARRIER, "atomic swap obj %p<%p>(%zu) ref-field@%p: old %#zx(%p), new %#zx(%p)", obj, obj->GetTypeInfo(),
         obj->GetSize(), &field, oldValue, oldRef, field.GetFieldValue(), newRef);
    return oldRef;
}

BaseObject* Barrier::AtomicReadReference(BaseObject* obj, RefField<true>& field, MemoryOrder order) const
{
    RefField<false> tmpField(field.GetFieldValue(order));
    if (theCollector.IsOldPointer(tmpField)) {
        BaseObject* toVersion = ReadReference(nullptr, tmpField);
        field.SetTargetObject(toVersion);
        DLOG(BARRIER, "atomic read obj %p ref@%p: %#zx -> %p", obj, &field, tmpField.GetFieldValue(), toVersion);
        return toVersion;
    }

    BaseObject* target = tmpField.GetTargetObject();
    DLOG(BARRIER, "atomic read obj %p ref@%p: %#zx -> %p", obj, &field, tmpField.GetFieldValue(), target);
    return target;
}

bool Barrier::CompareAndSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* oldRef, BaseObject* newRef,
                                      MemoryOrder succOrder, MemoryOrder failOrder) const
{
    MAddress oldFieldValue = field.GetFieldValue(std::memory_order_seq_cst);
    RefField<false> oldField(oldFieldValue);
    BaseObject* oldVersion = ReadReference(nullptr, oldField);
    (void)oldVersion;
    bool res = field.CompareExchange(oldRef, newRef, succOrder, failOrder);
    DLOG(BARRIER, "cas %u for obj %p reffield@%p: old %#zx->%p, expect %p, new %p", res, obj, &field, oldFieldValue,
         oldVersion, oldRef, newRef);
    return res;
}

void Barrier::CopyRefArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize, BaseObject* srcObj, MAddress srcField,
                           MIndex srcSize) const
{
    CHECK_DETAIL(memmove_s(reinterpret_cast<void*>(dstField), dstSize, reinterpret_cast<void*>(srcField), srcSize) ==
                     EOK,
                 "memmove_s failed");
#if defined(CANGJIE_TSAN_SUPPORT)
    size_t copyLen = (dstSize < srcSize ? dstSize : srcSize);
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dstField), copyLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(srcField), copyLen);
#endif
}

void Barrier::CopyStructArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize, BaseObject* srcObj,
                              MAddress srcField, MIndex srcSize) const
{
    CHECK_DETAIL(memmove_s(reinterpret_cast<void*>(dstField), dstSize, reinterpret_cast<void*>(srcField), srcSize) ==
                     EOK,
                 "memmove_s failed");
#if defined(CANGJIE_TSAN_SUPPORT)
    size_t copyLen = (dstSize < srcSize ? dstSize : srcSize);
    Sanitizer::TsanWriteMemoryRange(reinterpret_cast<void*>(dstField), copyLen);
    Sanitizer::TsanReadMemoryRange(reinterpret_cast<void*>(srcField), copyLen);
#endif
}

void Barrier::ReadStruct(MAddress dst, BaseObject* obj, MAddress src, size_t size) const
{
    size_t dstSize = size;
    size_t srcSize = size;
    if (obj != nullptr) {
        obj->ForEachRefInStruct(
            [this, obj](RefField<false>& field) {
                // MAddress bias = reinterpret_cast<MAddress>(&field) - reinterpret_cast<MAddress>(src);
                // RefField<false>* dstField = reinterpret_cast<RefField<false>*>(dst + bias);
                BaseObject* fromVersion = field.GetTargetObject();
                (void)fromVersion;
                BaseObject* toVersion = nullptr;
                theCollector.TryUpdateRefField(obj, field, toVersion);
            },
            src, src + size);
    }

    CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), dstSize, reinterpret_cast<void*>(src), srcSize) == EOK,
                 "read struct memcpy_s failed");
}

void Barrier::ReadStaticStruct(MAddress dst, MAddress src, size_t size, const GCTib gctib) const
{
    size_t dstSize = size;
    size_t srcSize = size;
    CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), dstSize, reinterpret_cast<void*>(src), srcSize) == EOK,
                 "read struct memcpy_s failed");
    gctib.ForEachBitmapWord(dst, [this](RefField<>& refField) {
        BaseObject* toVersion = nullptr;
        theCollector.TryUpdateRefField(nullptr, refField, toVersion);
    });
}

void Barrier::WriteGeneric(const ObjectPtr obj, void* fieldPtr, const ObjectPtr src, size_t size) const
{
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    if (UNLIKELY(IsLocalObject(obj) || IsLocalObject(src))) {
        LOG(RTLOG_FATAL, "Barrier::WriteGeneric does not support local object: obj %p, src %p", obj, src);
    }
#endif
    if ((obj != nullptr && !obj->HasRefField()) || (!Heap::IsHeapAddress(obj) && !Heap::IsHeapAddress(src))) {
        CHECK_DETAIL(memcpy_s(fieldPtr, size,
                              reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(src) + TYPEINFO_PTR_SIZE),
                              size) == EOK,
                     "WriteGeneric memcpy_s failed");
#if defined(CANGJIE_TSAN_SUPPORT)
        if (Heap::IsHeapAddress(src)) {
            Sanitizer::TsanReadMemoryRange(
                reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(src) + TYPEINFO_PTR_SIZE), size);
        }
        if (Heap::IsHeapAddress(obj)) {
            Sanitizer::TsanWriteMemoryRange(fieldPtr, size);
        }
#endif
    } else if (!Heap::IsHeapAddress(obj) && Heap::IsHeapAddress(src)) {
        MAddress dstAddr = reinterpret_cast<MAddress>(fieldPtr);
        MAddress srcAddr = reinterpret_cast<MAddress>(src) + TYPEINFO_PTR_SIZE;
        ReadStruct(dstAddr, src, srcAddr, size);
    } else if ((Heap::IsHeapAddress(obj) && !Heap::IsHeapAddress(src))||
        (Heap::IsHeapAddress(obj) && Heap::IsHeapAddress(src))) {
        MAddress dstAddr = reinterpret_cast<MAddress>(fieldPtr);
        MAddress srcAddr = reinterpret_cast<MAddress>(src) + TYPEINFO_PTR_SIZE;
        WriteStruct(obj, dstAddr, size, srcAddr, size);
    }
}
void Barrier::ReadGeneric(const ObjectPtr dstObj, ObjectPtr obj, void* fieldPtr, size_t size) const
{
    bool dstIsHeap = Heap::IsHeapAddress(dstObj);
    bool objIsHeap = Heap::IsHeapAddress(obj);

    if (!dstIsHeap && IsLocalObjectForBarrier(dstObj)) {
        ReadGenericToLocalObject(dstObj, fieldPtr, size);
        return;
    }

    if (!objIsHeap && IsLocalObjectForBarrier(obj)) {
        ReadGenericFromLocalObject(dstObj, obj, fieldPtr, size);
        return;
    }

    if (!dstIsHeap && !objIsHeap) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(dstObj) + TYPEINFO_PTR_SIZE),
                              size, fieldPtr, size) == EOK,
                     "ReadGeneric memcpy_s failed");
    } else if (!dstIsHeap && objIsHeap) {
        MAddress dstAddr = reinterpret_cast<MAddress>(dstObj) + TYPEINFO_PTR_SIZE;
        MAddress srcAddr = reinterpret_cast<MAddress>(fieldPtr);
        ReadStruct(dstAddr, obj, srcAddr, size);
    } else {
        MAddress dstAddr = reinterpret_cast<MAddress>(dstObj) + TYPEINFO_PTR_SIZE;
        MAddress srcAddr = reinterpret_cast<MAddress>(fieldPtr);
        WriteStruct(dstObj, dstAddr, size, srcAddr, size);
    }
}

void Barrier::ReadGenericToLocalObject(const ObjectPtr dstObj, void* fieldPtr, size_t size) const
{
    MAddress dst = reinterpret_cast<MAddress>(dstObj) + TYPEINFO_PTR_SIZE;
    MAddress src = reinterpret_cast<MAddress>(fieldPtr);
    if (!dstObj->HasRefField()) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), size, fieldPtr, size) == EOK,
                     "ReadGeneric local destination payload memcpy_s failed");
        return;
    }

    Mutator* mutator = nullptr;
    size_t copiedUntil = 0;
    auto copyRange = [dst, src, size](size_t begin, size_t end) {
        if (begin == end) {
            return;
        }
        CHECK_DETAIL(begin < end && end <= size,
                     "invalid ReadGeneric local copy range [%zu, %zu), size: %zu", begin, end, size);
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst + begin), size - begin,
                              reinterpret_cast<void*>(src + begin), end - begin) == EOK,
                     "ReadGeneric local destination memcpy_s failed");
    };

    dstObj->GetGCTib().ForEachBitmapWordInRange(dst,
        [this, dstObj, dst, src, size, &mutator, &copiedUntil,
         &copyRange](RefField<>& dstField) {
            size_t offset = reinterpret_cast<MAddress>(&dstField) - dst;
            CHECK_DETAIL(offset >= copiedUntil && offset + sizeof(RefField<>) <= size,
                         "invalid ReadGeneric local reference offset: %zu, copiedUntil: %zu, size: %zu",
                         offset, copiedUntil, size);
            copyRange(copiedUntil, offset);

            auto* srcField = reinterpret_cast<RefField<>*>(src + offset);
            RefField<> srcSnapshot(srcField->GetFieldValue());
            // Only tagged heap refs need the read barrier.
            ObjectPtr value = srcSnapshot.GetTargetObject();
            if (value != nullptr && Heap::IsHeapAddress(value) && srcSnapshot.IsTagged()) {
                value = ReadReference(nullptr, *srcField);
            }
            if (Heap::IsHeapAddress(value)) {
                if (mutator == nullptr) {
                    mutator = Mutator::GetMutator();
                    CHECK_DETAIL(mutator != nullptr, "cannot register local generic destination without mutator: %p",
                                 dstObj);
                }
                mutator->AddLocalRoot(dstObj, &dstField);
                WriteReference(dstObj, dstField, value);
            } else {
                dstField.SetTargetObject(value);
            }
            copiedUntil = offset + sizeof(RefField<>);
        },
        dst, dst + size);
    copyRange(copiedUntil, size);
}

void Barrier::ReadGenericFromLocalObject(const ObjectPtr dstObj, ObjectPtr obj, void* fieldPtr, size_t size) const
{
    CHECK_DETAIL(Heap::IsHeapAddress(dstObj) && dstObj != nullptr && fieldPtr != nullptr,
                 "ReadGeneric local source has invalid destination: dstObj %p, obj %p, fieldPtr %p",
                 dstObj, obj, fieldPtr);
    MAddress dstAddr = reinterpret_cast<MAddress>(dstObj) + TYPEINFO_PTR_SIZE;
    if (!dstObj->HasRefField()) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dstAddr), size, fieldPtr, size) == EOK,
                     "ReadGeneric local source payload memcpy_s failed");
        return;
    }
    MCC_MaybeLocalWriteStruct(dstObj, dstAddr, size, reinterpret_cast<MAddress>(fieldPtr), size,
                              dstObj->GetGCTib());
}

} // namespace MapleRuntime
