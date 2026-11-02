// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_MOBJECT_H
#define MRT_MOBJECT_H

#include "Common/BaseObject.h"

namespace MapleRuntime {
// MObject is the peer structure of MArray, thus not "the" generic structure for runtime.
// refer to BaseObject instead.
class ATTR_PACKED(4) MObject : public BaseObject {
public:
    static MObject* NewFinalizer(const TypeInfo* ti, MSize size);

    // no need to retrieve object size via class metadata, i.e. GetInstanceSize().
    static MObject* NewObject(TypeInfo* ti, MSize objectSize, AllocType);
    static MObject* NewLocalObject(TypeInfo* ti, MSize objectSize);
    static MObject* NewPinnedObject(TypeInfo* ti, MSize objectSize);

    // inlined functions
    // Property query
    inline bool IsSubType(TypeInfo& ti);
    inline bool IsArray() const;
    inline bool IsPrimitiveArray() const;
    inline bool IsStructArray() const;

    // Field access
    template<typename T>
    inline T Load(size_t offset) const;
    template<typename T>
    inline void Store(size_t offset, T value);
    inline MObject* LoadRef(size_t offset);
    inline void StoreRef(size_t offset, MObject* value);

    // Type conversion: need to be safe enough
    template<typename T0, typename T1>
    static inline T0* Cast(T1 o);

    template<typename T0, typename T1>
    static inline T0* CastNonNull(T1 o);

private:
    MObject() = delete;
    ~MObject() = delete;
    MObject(MObject&&) = delete;
    MObject& operator=(MObject&&) = delete;
}; // class MObject
} // namespace MapleRuntime
#endif // MRT_MOBJECT_H
