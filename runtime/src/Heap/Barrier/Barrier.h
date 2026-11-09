// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_BARRIER_H
#define MRT_BARRIER_H

#include "Common/BaseObject.h"
#include "ObjectModel/Field.h"
#include "ObjectModel/MClass.h"

namespace MapleRuntime {
class Collector;
// Barrier is the base class to define read/write barriers.
class Barrier {
public:
    explicit Barrier(Collector& collector) : theCollector(collector) {}
    virtual ~Barrier() {}

    // barriers for maple runtime. they can be override as needed.
    virtual void WriteI8(BaseObject* obj, Field<int8_t>& field, int8_t val) const;
    virtual void WriteI16(BaseObject* obj, Field<int16_t>& field, int16_t val) const;
    virtual void WriteI32(BaseObject* obj, Field<int32_t>& field, int32_t val) const;
    virtual void WriteI64(BaseObject* obj, Field<int64_t>& field, int64_t val) const;
    virtual void WriteF32(BaseObject* obj, Field<float>& field, float val) const;
    virtual void WriteF64(BaseObject* obj, Field<double>& field, double val) const;

    virtual BaseObject* ReadReference(BaseObject* obj, RefField<false>& field) const;
    virtual BaseObject* ReadStaticRef(RefField<false>& field) const;
    virtual BaseObject* ReadWeakRef(BaseObject* obj, RefField<false>& field) const;
    virtual void ReadStruct(MAddress dst, BaseObject* obj, MAddress src, size_t size) const;
    virtual void ReadStaticStruct(MAddress dst, MAddress src, size_t size, const GCTib gctib) const;

    virtual void WriteReference(BaseObject* obj, RefField<false>& field, BaseObject* ref) const;
    virtual void WriteStaticRef(RefField<false>& field, BaseObject* ref) const;
    virtual void WriteStruct(BaseObject* obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen) const;
    virtual void WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, const GCTib gctib) const;

    virtual void CopyRefArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize,
                              BaseObject* srcObj, MAddress srcField, MIndex srcSize) const;
    virtual void CopyStructArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize,
                              BaseObject* srcObj, MAddress srcField, MIndex srcSize) const;

    virtual BaseObject* AtomicReadReference(BaseObject* obj, RefField<true>& field,
                                            MemoryOrder order) const;

    virtual void AtomicWriteReference(BaseObject* obj, RefField<true>& field, BaseObject* ref, MemoryOrder order) const;
    virtual BaseObject* AtomicSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* ref,
                                            MemoryOrder order) const;
    virtual bool CompareAndSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* oldRef, BaseObject* newRef,
                                         MemoryOrder succOrder, MemoryOrder failOrder) const;

    // helper for delegation
    template<typename T>
    inline void WriteField(BaseObject* obj, Field<T>& field, T val) const;

    virtual void WriteGeneric(const ObjectPtr obj, void* fieldPtr, const ObjectPtr src, size_t size) const;
    virtual void ReadGeneric(const ObjectPtr dstPtr, ObjectPtr obj, void* fieldPtr, size_t size) const;

protected:
    void ReadGenericToLocalObject(const ObjectPtr dstObj, void* fieldPtr, size_t size) const;
    void ReadGenericFromLocalObject(const ObjectPtr dstObj, ObjectPtr obj, void* fieldPtr, size_t size) const;

    class LocalRefFieldContainer {
    public:
        // multi-thread unsafe.
        void Push(RefField<>* ref)
        {
            if (size >= CACHE_CAPACITY) {
                excessive.push_back(ref);
            } else {
                cache[size] = ref;
            }
            size++;
        }
        void VisitRefField(const RefFieldVisitor &visitor)
        {
            size_t cacheSize = size < CACHE_CAPACITY ? size : CACHE_CAPACITY;
            for (size_t i = 0; i != cacheSize; ++i) {
                visitor(*cache[i]);
            }
            for (auto* ref : excessive) {
                visitor(*ref);
            }
        }
    private:
        static constexpr size_t CACHE_CAPACITY = 10;
        RefField<>* cache[CACHE_CAPACITY]{ nullptr };
        size_t size{ 0 };
        std::vector<RefField<>*> excessive;
    };
    Collector& theCollector;
};
} // namespace MapleRuntime
#endif // ~MRT_BARRIER_H
