// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_GENERATION_POST_TRACE_BARRIER_H
#define MRT_GENERATION_POST_TRACE_BARRIER_H

#include "RSetUpdateBarrier.h"
#include "WCollector/PostTraceBarrier.h"

namespace MapleRuntime {

class GenerationPostTraceBarrier : public PostTraceBarrier {
public:
    explicit GenerationPostTraceBarrier(Collector& collector) : PostTraceBarrier(collector) {}

    BaseObject* ReadWeakRef(BaseObject* obj, RefField<false>& field) const override;

    void WriteReference(BaseObject* obj, RefField<false>& field, BaseObject* ref) const override
    {
        PostTraceBarrier::WriteReference(obj, field, ref);
        rsetUpdateBarrier_.WriteReference(obj, &field, ref);
    }

    void WriteStruct(BaseObject* obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen) const override;
    void AtomicWriteReference(BaseObject* obj, RefField<true>& field, BaseObject* ref,
                              MemoryOrder order) const override;
    BaseObject* AtomicSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* ref,
                                    MemoryOrder order) const override;
    bool CompareAndSwapReference(BaseObject* obj, RefField<true>& field, BaseObject* oldRef, BaseObject* newRef,
                                 MemoryOrder succOrder, MemoryOrder failOrder) const override;
    void CopyStructArray(BaseObject* dstObj, MAddress dstField, MIndex dstSize, BaseObject* srcObj, MAddress srcField,
                         MIndex srcSize) const override;

private:
    mutable RSetUpdateBarrier rsetUpdateBarrier_;
};

} // namespace MapleRuntime

#endif // MRT_GENERATION_POST_TRACE_BARRIER_H
