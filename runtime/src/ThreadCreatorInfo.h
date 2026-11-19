// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_THREAD_CREATOR_INFO_H
#define MRT_THREAD_CREATOR_INFO_H

#include <cstdint>

#include "schedule.h"

namespace MapleRuntime {

// Identity of the creator frame: the same three values an ordinary frame's pcArray
// triple carries (ip / funcStart / funcDesc; see StackInfo.cpp
// ExtractLiteFrameInfoFromStack for how ordinary frames store them), captured verbatim
// at spawn time on the
// parent thread, copied into the child cjthread's tail fields before publish, and
// copied again into the exception's pcArray at fill time. Pure values: no runtime-owned
// memory, no lifetime coupling with any thread; the funcDesc points into module memory
// and therefore shares the module-lifetime semantics of every ordinary frame triple.
struct CreatorFrameInfo {
    uintptr_t ip;         // call-site return address (the spawn call instruction); 0 = not captured
    uintptr_t funcStart;  // creator function start (stack-map lookup base)
    uint64_t funcDesc;    // creator frame FuncDesc pointer value
};

// Captures the creator frame on the parent thread at the MCC entries: bounded unwind
// to the first MANAGED frame, then a verbatim copy of its identity triple. No decoding
// and no lookup happen here - the values are decoded at print time, like every other
// frame. Returns ip == 0 when capture is given up (interpreter caller, unreliable
// unwind context, no valid frame, or unresolved FuncDesc); the next spawn retries.
CreatorFrameInfo CaptureCreator();

// Returns the current cjthread's creator frame; ip == 0 when absent
// (main/CFFI threads, capture given up, or non-spawn creation paths).
CreatorFrameInfo CJThreadGetCreatorFrame();

} // namespace MapleRuntime

#ifdef __cplusplus
extern "C" {
#endif

// Runtime-internal creation helper used only by the two MCC entries. Kept out of the
// public schedule.h. creatorFrame points to a parent-stack CreatorFrameInfo (or nullptr):
// the three values are copied into the child's tail fields inside this synchronous call
// before publish; the pointer itself is never stored (the parent stack object dies on
// return). Defined in cjthread.cpp where struct CJThread is visible.
CJThreadHandle CJThreadNewWithCreator(ScheduleHandle schedule, const struct CJThreadAttr *attrUser,
                                      CJThreadFunc func, const void *argStart, unsigned int argSize,
                                      CJThreadCreateSource createSource, const void *creatorFrame);

#ifdef __cplusplus
}
#endif

#endif // MRT_THREAD_CREATOR_INFO_H
