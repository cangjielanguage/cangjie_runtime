// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#include "PrintStackInfo.h"

#include "Common/StackType.h"

namespace MapleRuntime {
void PrintStackInfo::FillInStackTrace()
{
    UnwindContext uwContext;
    // Top unwind context can only be runtime or Cangjie context.
    CheckTopUnwindContextAndInit(uwContext);
    while (!uwContext.frameInfo.mFrame.IsAnchorFrame(anchorFA)) {
        AnalyseAndSetFrameType(uwContext);

        FrameType currentFrameType = uwContext.frameInfo.GetFrameType();
        if (currentFrameType == FrameType::MANAGED) {
            stack.emplace_back(uwContext.frameInfo);
        }
#ifdef INTERPRETER_ENABLED
        if (currentFrameType == FrameType::INTERPRETER) {
            stack.emplace_back(uwContext.frameInfo);
        }
#endif

        UnwindContext caller;
        lastFrameType = uwContext.frameInfo.GetFrameType();
#ifndef _WIN64
        if (uwContext.UnwindToCallerContext(caller) == false) {
#else
        if (uwContext.UnwindToCallerContext(caller, uwCtxStatus) == false) {
#endif
            return;
        }
        uwContext = caller;
    }
}

void PrintStackInfo::PrintStackTrace() const
{
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    size_t frameSize = stack.size();
    for (size_t i = 0; i < frameSize; ++i) {
        stack[i].PrintFrameInfo(i);
    }
#endif
}

#if defined(__IOS__)
CString PrintStackInfo::GetStackTraceString()
{
    UnwindContext uwContext;
    // Top unwind context can only be runtime or Cangjie context.
    CheckTopUnwindContextAndInit(uwContext);
    while (!uwContext.frameInfo.mFrame.IsAnchorFrame(anchorFA)) {
        AnalyseAndSetFrameType(uwContext);
        stack.emplace_back(uwContext.frameInfo);

        UnwindContext caller;
        lastFrameType = uwContext.frameInfo.GetFrameType();
        if (uwContext.UnwindToCallerContext(caller) == false) {
            break;
        }
        uwContext = caller;
    }

    CString res;
    size_t frameSize = stack.size();
    for (size_t i = 0; i < frameSize; ++i) {
        res.Append(stack[i].GetFrameInfo(i));
    }
    return res;
}
#endif
} // namespace MapleRuntime
