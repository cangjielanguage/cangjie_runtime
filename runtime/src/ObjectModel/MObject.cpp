// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Base/Log.h"
#include "MObject.inline.h"
#include "Inspector/CjAllocData.h"
namespace MapleRuntime {
MObject* MObject::NewObject(TypeInfo* ti, MSize size, AllocType allocType)
{
    auto addr = HeapManager::Allocate(size, allocType);
    if (LIKELY(addr != NULL_ADDRESS)) {
        (void)SetClassInfo(addr, ti);
    } else {
        return nullptr;
    }
#if defined(__OHOS__) && (__OHOS__ == 1)
    if (CjAllocData::GetCjAllocData()->IsRecording()) {
        CjAllocData::GetCjAllocData()->RecordAllocNodes(ti, size);
    }
#endif
    return Cast<MObject>(addr);
}

MObject* MObject::NewLocalObject(TypeInfo* ti, MSize size)
{
    auto addr = HeapManager::AllocateLocal(size);
    if (LIKELY(addr != NULL_ADDRESS)) {
        (void)SetLocalClassInfo(addr, ti);
    } else {
        return nullptr;
    }
#if defined(__OHOS__) && (__OHOS__ == 1)
    if (CjAllocData::GetCjAllocData()->IsRecording()) {
        CjAllocData::GetCjAllocData()->RecordAllocNodes(ti, size);
    }
#endif
    return Cast<MObject>(addr);
}

MObject* MObject::NewPinnedObject(TypeInfo* ti, MSize size)
{
    CHECK_DETAIL(ti->IsObjectType() == true, "must be object class.");
    auto addr = HeapManager::Allocate(size, AllocType::PINNED_OBJECT);
    if (LIKELY(addr != NULL_ADDRESS)) {
        (void)SetClassInfo(addr, ti);
    } else {
        return nullptr;
    }
#if defined(__OHOS__) && (__OHOS__ == 1)
    if (CjAllocData::GetCjAllocData()->IsRecording()) {
        CjAllocData::GetCjAllocData()->RecordAllocNodes(ti, size);
    }
#endif
    return Cast<MObject>(addr);
}

MObject* MObject::NewFinalizer(const TypeInfo* ti, MSize size)
{
    CHECK_DETAIL(ti->IsObjectType() == true, "must be object class.");
    auto addr = HeapManager::Allocate(size);
    if (LIKELY(addr != NULL_ADDRESS)) {
        (void)SetClassInfo(addr, const_cast<TypeInfo*>(ti));
        reinterpret_cast<BaseObject*>(addr)->OnFinalizerCreated();
    } else {
        return nullptr;
    }
#if defined(__OHOS__) && (__OHOS__ == 1)
    if (CjAllocData::GetCjAllocData()->IsRecording()) {
        CjAllocData::GetCjAllocData()->RecordAllocNodes(ti, size);
    }
#endif
    return Cast<MObject>(addr);
}
} // namespace MapleRuntime
