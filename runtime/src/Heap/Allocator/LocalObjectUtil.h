// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_LOCAL_OBJECT_UTIL_H
#define MRT_LOCAL_OBJECT_UTIL_H

#include "Common/BaseObject.h"
#include "Mutator/Mutator.h"

namespace MapleRuntime {
inline bool IsLocalObject(BaseObject* obj)
{
    return obj != nullptr && obj->IsLocalObject();
}

// Barrier-only fast check using the current mutator's local allocation state.
// GC and debug checks use IsLocalObject directly instead.
inline bool IsLocalObjectForBarrier(BaseObject* obj)
{
    Mutator* mutator = Mutator::GetMutator();
    if (LIKELY(mutator == nullptr || !mutator->IsLocalModeEnabled())) {
        return false;
    }
    return obj != nullptr && obj->IsLocalObject();
}
} // namespace MapleRuntime

#endif // MRT_LOCAL_OBJECT_UTIL_H
