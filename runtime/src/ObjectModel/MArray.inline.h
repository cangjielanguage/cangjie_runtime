// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_MARRAY_INLINE_H
#define MRT_MARRAY_INLINE_H

#include "Inspector/CjAllocData.h"
// model interface
#include "ExceptionManager.h"
#include "Heap/Barrier/Barrier.inline.h"
#include "Heap/Heap.h"
#include "HeapManager.inline.h"
// module internal interfaces
#include "MArray.h"
#include "MClass.inline.h"

namespace MapleRuntime {
constexpr MOffset MArray::GetContentOffset() { return sizeof(MArray); }

inline MIndex MArray::GetLength() const { return length; }

inline void MArray::SetLength(MIndex number) { length = number; }

inline U8* MArray::ConvertToCArray() const
{
    return reinterpret_cast<uint8_t*>(reinterpret_cast<Uptr>(this) + MArray::GetContentOffset());
}

inline MIndex MArray::GetMArraySize() const { return (MArray::GetContentOffset() + GetContentSize()); }

inline MSize MArray::GetElementSize() const
{
    TypeInfo* componentTypeInfo = GetComponentTypeInfo();
    if (componentTypeInfo->IsRef()) {
        return sizeof(BaseObject*);
    }
    return componentTypeInfo->GetComponentSize();
}

inline MIndex MArray::GetContentSize() const
{
    auto len = GetLength();
    auto elementSize = GetElementSize();
    return elementSize * len;
}

inline bool MArray::IsPrimitiveArray() const
{
    TypeInfo* componentTypeInfo = GetTypeInfo()->GetComponentTypeInfo();
    return componentTypeInfo == nullptr ? false : componentTypeInfo->IsPrimitiveType();
}

inline ObjectPtr MArray::GetRefElement(MIndex index)
{
    RefField<>& ref = GetRefField(MArray::GetContentOffset() + RefField<>::GetSize() * index);
    return Heap::GetBarrier().ReadReference(this, ref);
}

inline void MArray::SetRefElement(MIndex index, const ObjectPtr mObj)
{
    RefField<>& ref = GetRefField(MArray::GetContentOffset() + RefField<>::GetSize() * index);
    Heap::GetBarrier().WriteReference(this, ref, mObj);
}

template<typename T>
inline T MArray::GetPrimitiveElement(MIndex index) const
{
    Field<T>& field = GetField<T>(MArray::GetContentOffset() + GetElementSize() * index);
    // normally we do not barrier for reading primitive fields.
    return field.GetFieldValue();
}

template<typename T>
inline void MArray::SetPrimitiveElement(MIndex index, T value)
{
    Field<T>& field = GetField<T>(MArray::GetContentOffset() + GetElementSize() * index);
    Heap::GetBarrier().WriteField(this, field, value);
}

static inline MIndex CalculateArraySize(MIndex nElems, const U32 elemBytes)
{
    if (elemBytes == 0) {
        return static_cast<U64>(MArray::GetContentOffset());
    }
    U64 maxLength = (MAX_ARRAY_SIZE - MArray::GetContentOffset()) / elemBytes;
    U64 totalSize = static_cast<U64>(nElems) * elemBytes + static_cast<U64>(MArray::GetContentOffset());
    if (UNLIKELY(nElems >= maxLength)) {
        // check overflow
        return MAX_ARRAY_SIZE;
    }
    return static_cast<MIndex>(totalSize);
}

inline MArray* MArray::NewArray(MIndex nElems, TypeInfo& arrayClass, AllocType allocType)
{
    DCHECK_D(arrayClass.IsArrayType(), "Expect an array type");
    MArray* newArray = nullptr;
    if (arrayClass.GetComponentTypeInfo()->IsObjectType()) {
        newArray = NewRefArray(nElems, arrayClass, allocType);
    } else {
        // component is value type
        auto elem = arrayClass.GetSuperTypeInfo();
        auto elemBits = sizeof(void*);
        if (!elem->IsRef()) {
            elemBits = arrayClass.GetSuperTypeInfo()->GetComponentSize();
        }
        newArray = NewKnownWidthArray(nElems, arrayClass, elemBits, allocType);
    }
    return newArray;
}

inline MArray* MArray::NewRefArray(MIndex nElems, TypeInfo& arrayClass, AllocType allocType)
{
    return NewKnownWidthArray(nElems, arrayClass, RefField<>::GetSize(), allocType);
}

inline MArray* MArray::NewKnownWidthArray(MIndex nElems, TypeInfo& arrayClass, const U32 elemBytes, AllocType allocType)
{
    DCHECK_D(arrayClass.IsArrayType(), "Expect an array type");
    MIndex arraySize = CalculateArraySize(nElems, elemBytes);
    if (UNLIKELY(arraySize == MAX_ARRAY_SIZE || arraySize > Heap::GetHeap().GetMaxCapacity())) {
        ExceptionManager::OutOfMemory();
        return nullptr;
    }
    auto address = HeapManager::Allocate(arraySize, allocType);
    if (LIKELY(address != NULL_ADDRESS)) {
        MArray* newArray = reinterpret_cast<MArray*>(SetClassInfo(address, &arrayClass));
        newArray->SetLength(nElems);
#if defined(__OHOS__) && (__OHOS__ == 1)
        if (CjAllocData::GetCjAllocData()->IsRecording()) {
            CjAllocData::GetCjAllocData()->RecordAllocNodes(&arrayClass, arraySize);
        }
#endif
        return newArray;
    }
    return nullptr;
}

inline MArray* MArray::NewLocalArray(MIndex nElems, TypeInfo& arrayClass)
{
    DCHECK_D(arrayClass.IsArrayType(), "Expect an array type");
    if (arrayClass.GetComponentTypeInfo()->IsObjectType()) {
        return NewLocalRefArray(nElems, arrayClass);
    }

    auto elem = arrayClass.GetSuperTypeInfo();
    auto elemBytes = sizeof(void*);
    if (!elem->IsRef()) {
        elemBytes = arrayClass.GetSuperTypeInfo()->GetComponentSize();
    }
    return NewLocalKnownWidthArray(nElems, arrayClass, elemBytes);
}

inline MArray* MArray::NewLocalRefArray(MIndex nElems, TypeInfo& arrayClass)
{
    return NewLocalKnownWidthArray(nElems, arrayClass, RefField<>::GetSize());
}

inline MArray* MArray::NewLocalKnownWidthArray(MIndex nElems, TypeInfo& arrayClass, const U32 elemBytes)
{
    DCHECK_D(arrayClass.IsArrayType(), "Expect an array type");
    MIndex arraySize = CalculateArraySize(nElems, elemBytes);
    if (UNLIKELY(arraySize == MAX_ARRAY_SIZE || arraySize > Heap::GetHeap().GetMaxCapacity())) {
        ExceptionManager::OutOfMemory();
        return nullptr;
    }
    auto address = HeapManager::AllocateLocal(arraySize);
    if (LIKELY(address != NULL_ADDRESS)) {
        MArray* newArray = reinterpret_cast<MArray*>(SetLocalClassInfo(address, &arrayClass));
        newArray->SetLength(nElems);
#if defined(__OHOS__) && (__OHOS__ == 1)
        if (CjAllocData::GetCjAllocData()->IsRecording()) {
            CjAllocData::GetCjAllocData()->RecordAllocNodes(&arrayClass, arraySize);
        }
#endif
        return newArray;
    }
    return nullptr;
}
} // namespace MapleRuntime
#endif // MRT_MARRAY_INLINE_H
