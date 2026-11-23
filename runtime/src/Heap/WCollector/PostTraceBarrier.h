// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_POST_TRACE_BARRIER_H
#define MRT_POST_TRACE_BARRIER_H

#include "IdleBarrier.h"

namespace MapleRuntime {
// WGC weak reads require stable candidate metadata until the Preforward pause.
class PostTraceBarrier : public IdleBarrier {
public:
    explicit PostTraceBarrier(Collector& collector) : IdleBarrier(collector) {}

    BaseObject* ReadReference(BaseObject* obj, RefField<false>& field) const override;
    BaseObject* ReadStaticRef(RefField<false>& field) const override;
    BaseObject* ReadWeakRef(BaseObject* obj, RefField<false>& field) const override;
    void ReadStruct(MAddress dst, BaseObject* obj, MAddress src, size_t size) const override;
    void ReadStaticStruct(MAddress dst, MAddress src, size_t size, const GCTib gctib) const override;

    void WriteReference(BaseObject* obj, RefField<false>& field, BaseObject* ref) const override;
    void WriteStruct(BaseObject* obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen) const override;
    void WriteStaticRef(RefField<false>& field, BaseObject* ref) const override;
    void WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, const GCTib gctib) const override;

    BaseObject* AtomicReadReference(BaseObject* obj, RefField<true>& field, MemoryOrder order) const override;
    void AtomicWriteReference(BaseObject* obj, RefField<true>& field, BaseObject* ref,
                              MemoryOrder order) const override;
    BaseObject* AtomicSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* ref,
                                    MemoryOrder order) const override;
    bool CompareAndSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* oldRef, BaseObject* newRef,
                                 MemoryOrder succOrder, MemoryOrder failOrder) const override;

    void CopyStructArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize, BaseObject* srcObj, MAddress srcField,
                         MIndex srcSize) const override;
};
} // namespace MapleRuntime
#endif // MRT_MARK_BARRIER_H
