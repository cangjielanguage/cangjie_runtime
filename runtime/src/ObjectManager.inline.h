// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_OBJECT_MANAGER_INLINE_H
#define MRT_OBJECT_MANAGER_INLINE_H

// inlined object model functions
// common headers
// inter-module headers
#include "ExceptionManager.h"

// module internal headers
#include "ObjectManager.h"
#include "ObjectModel/MArray.inline.h"
#include "ObjectModel/MClass.inline.h"
#include "ObjectModel/MObject.inline.h"

namespace MapleRuntime {
inline ObjRef ObjectManager::NewObject(const TypeInfo* ti, MSize size, AllocType allocType)
{
    CHECK_DETAIL(ti != nullptr, "ti is nullptr");
    auto obj = MObject::NewObject(const_cast<TypeInfo*>(ti), size, allocType);
    return static_cast<ObjRef>(obj);
}

inline ObjRef ObjectManager::NewLocalObject(const TypeInfo* ti, MSize size)
{
    CHECK_DETAIL(ti != nullptr, "ti is nullptr");
    auto obj = MObject::NewLocalObject(const_cast<TypeInfo*>(ti), size);
    return static_cast<ObjRef>(obj);
}

inline ObjRef ObjectManager::NewWeakRefObject(const TypeInfo* ti, MSize size, AllocType allocType)
{
    CHECK_DETAIL(ti != nullptr, "klass is nullptr");
    auto obj = MObject::NewObject(const_cast<TypeInfo*>(ti), size, allocType);
    return static_cast<ObjRef>(obj);
}

inline ObjRef ObjectManager::NewPinnedObject(const TypeInfo* ti, MSize size, bool isFinalizer)
{
    CHECK_DETAIL(ti != nullptr, "ti is nullptr");
    auto obj = MObject::NewPinnedObject(const_cast<TypeInfo*>(ti), size);
    if (isFinalizer && obj != nullptr) {
        static_cast<ObjRef>(obj)->OnFinalizerCreated();
    }
    return static_cast<ObjRef>(obj);
}

inline ObjRef ObjectManager::NewFinalizer(const TypeInfo* ti, MSize size)
{
    CHECK_DETAIL(ti != nullptr, "ti is nullptr");
    auto obj = MObject::NewFinalizer(ti, size);
    return static_cast<ObjRef>(obj);
}

inline GCTib ObjectManager::GetGCInfo(const TypeInfo* ti) { return ti->GetGCTib(); }

// general array creation
inline ArrayRef ObjectManager::NewArray(MIndex nElems, const TypeInfo* arrayTi, AllocType allocType)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    return MArray::NewArray(nElems, *const_cast<TypeInfo*>(arrayTi), allocType);
}

inline ArrayRef ObjectManager::NewLocalArray(MIndex nElems, const TypeInfo* arrayTi)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    return MArray::NewLocalArray(nElems, *const_cast<TypeInfo*>(arrayTi));
}

inline ArrayRef ObjectManager::NewObjArray(MIndex nElems, const TypeInfo* arrayTi, AllocType allocType)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    return MArray::NewRefArray(nElems, *const_cast<TypeInfo*>(arrayTi), allocType);
}

inline ArrayRef ObjectManager::NewLocalObjArray(MIndex nElems, const TypeInfo* arrayTi)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    return MArray::NewLocalRefArray(nElems, *const_cast<TypeInfo*>(arrayTi));
}

inline ArrayRef ObjectManager::NewKnownWidthArray(MIndex nElems, const TypeInfo* arrayTi, ArrayElemBits elemBits,
                                                  AllocType allocType)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    constexpr U32 bitsToByte = 3;
    // Note here we need Bytes instead of Bits
    return MArray::NewKnownWidthArray(nElems, *const_cast<TypeInfo*>(arrayTi),
                                      (static_cast<U32>(elemBits) >> bitsToByte), allocType);
}

inline ArrayRef ObjectManager::NewLocalKnownWidthArray(
    MIndex nElems, const TypeInfo* arrayTi, ArrayElemBits elemBits)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    constexpr U32 bitsToByte = 3;
    return MArray::NewLocalKnownWidthArray(
        nElems, *const_cast<TypeInfo*>(arrayTi), (static_cast<U32>(elemBits) >> bitsToByte));
}
} // namespace MapleRuntime

#endif // MRT_OBJECT_MANAGER_INLINE_H
