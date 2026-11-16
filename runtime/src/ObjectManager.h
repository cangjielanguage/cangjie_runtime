// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_OBJECT_MANAGER_H
#define MRT_OBJECT_MANAGER_H

// object model components
#include "ObjectModel/MArray.h"
#include "ObjectModel/MClass.h"
#include "ObjectModel/MObject.h"

// Note: general field accessor is a common facility

namespace MapleRuntime {
//  Motivation: all interfaces related to object model implementation should have a separated control plane
class ObjectManager {
public:
    // used to regulate accepted fixed width element type
    enum class ArrayElemBits : U32 { ELEM_8B = 8, ELEM_16B = 16, ELEM_32B = 32, ELEM_64B = 64 };

    // Runtime module lifetime interfaces
    void Init() const {};
    void Fini() const {};

    static inline ObjRef NewObject(const TypeInfo* ti, MSize size, AllocType allocType = AllocType::MOVEABLE_OBJECT);
    static inline ObjRef NewLocalObject(const TypeInfo* ti, MSize size);
    static inline ObjRef NewWeakRefObject(const TypeInfo* ti, MSize size,
                                          AllocType allocType = AllocType::MOVEABLE_OBJECT);
    static inline ObjRef NewPinnedObject(const TypeInfo* ti, MSize size, bool isFinalizer);
    static inline ObjRef NewFinalizer(const TypeInfo* ti, MSize size);

    static inline GCTib GetGCInfo(const TypeInfo* ti);

    // general (slow) interface for array creation
    static inline ArrayRef NewArray(MIndex nElems, const TypeInfo* arrayTi,
                                    AllocType allocType = AllocType::MOVEABLE_OBJECT);
    static inline ArrayRef NewLocalArray(MIndex nElems, const TypeInfo* arrayTi);

    // create object array: it needs special care.
    static inline ArrayRef NewObjArray(MIndex nElems, const TypeInfo* arrayTi,
                                       AllocType allocType = AllocType::MOVEABLE_OBJECT);
    static inline ArrayRef NewLocalObjArray(MIndex nElems, const TypeInfo* arrayTi);

    static inline ArrayRef NewKnownWidthArray(MIndex nElems, const TypeInfo* arrayTi, ArrayElemBits elemBits,
                                              AllocType allocType = AllocType::MOVEABLE_OBJECT);
    static inline ArrayRef NewLocalKnownWidthArray(
        MIndex nElems, const TypeInfo* arrayTi, ArrayElemBits elemBits);
};
} // namespace MapleRuntime

#endif // MRT_OBJECT_MANAGER_H
