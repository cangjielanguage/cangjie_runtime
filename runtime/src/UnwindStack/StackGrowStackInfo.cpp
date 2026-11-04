// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "StackGrowStackInfo.h"

#include <stack>

#include "Collector/TracingCollector.h"
#include "Common/StackType.h"
#include "Interpreter/InterpreterSpecific.h"

namespace MapleRuntime {
void StackGrowStackInfo::FillInStackTrace()
{
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return;
    }
    UnwindContext uwContext;
    // Top unwind context can only be runtime or Cangjie context.
    CheckTopUnwindContextAndInit(uwContext);

#ifdef _WIN64
    // The offset on the window is unchanged.
    const uintptr_t firstFrameBaseOffset = 48;
    while (reinterpret_cast<uintptr_t>(uwContext.frameInfo.mFrame.GetFA()) !=
           mutator->GetStackBaseAddr() - firstFrameBaseOffset) {
#else
    // [rbp] of CJ_CJThreadEntry is 0x0.
    while (reinterpret_cast<uintptr_t>(uwContext.frameInfo.mFrame.GetFA()) != 0) {
#endif
        AnalyseAndSetFrameType(uwContext);
        stack.emplace_back(uwContext.frameInfo);
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

void StackGrowStackInfo::RecordStackPtrsImpl(const StackPtrVisitor& traceAndFixPtrVisitor,
                                             const StackPtrVisitor& fixPtrVisitor,
                                             const DerivedPtrVisitor& derivedPtrVisitor,
                                             RegSlotsMap& regSlotsMap,
                                             const FrameInfo& frame, Mutator& mutator)
{
    uintptr_t startIP = reinterpret_cast<uintptr_t>(frame.GetStartProc());
    uintptr_t frameIP = reinterpret_cast<uintptr_t>(frame.mFrame.GetIP());
    uintptr_t frameAddress = reinterpret_cast<uintptr_t>(frame.mFrame.GetFA());
    StackPtrMap stackPtrMap = StackMapBuilder(startIP, frameIP, frameAddress).Build<StackPtrMap>();
    if (stackPtrMap.IsValid()) {
        if (!stackPtrMap.VisitReg(traceAndFixPtrVisitor, fixPtrVisitor, nullptr, regSlotsMap)) {
            LOG(RTLOG_FATAL, "wrong reg info, start ip: %p frame pc: %p", reinterpret_cast<void*>(startIP),
                reinterpret_cast<void*>(frameIP));
        }
        stackPtrMap.VisitSlot(traceAndFixPtrVisitor, fixPtrVisitor, nullptr);
        stackPtrMap.VisitDerivedPtr(derivedPtrVisitor, regSlotsMap);
    }
    stackPtrMap.RecordCalleeSaved(regSlotsMap);
}

void StackGrowStackInfo::RecordStackPtrs(const StackPtrVisitor& traceAndFixPtrVisitor,
                                         const StackPtrVisitor& fixPtrVisitor,
                                         const DerivedPtrVisitor& derivedPtrVisitor, Mutator& mutator)
{
    RegSlotsMap regSlotsMap;
    for (const auto& frame : stack) {
        ObjectRef* rbp = reinterpret_cast<ObjectRef*>(frame.GetMachineFrame().GetFA());
        fixPtrVisitor(*rbp);

        switch (frame.GetFrameType()) {
            case FrameType::MANAGED: {
                RecordStackPtrsImpl(traceAndFixPtrVisitor, fixPtrVisitor, derivedPtrVisitor,
                                    regSlotsMap, frame, mutator);
                break;
            }
            case FrameType::C2R_STUB:
            case FrameType::C2N_STUB:
            case FrameType::EXSLUSIVE:
#ifdef INTERPRETER_ENABLED
            case FrameType::INTERPRETER_C2I:
#endif
                // Bridge frames save the caller's callee-saved registers. Use these slots
                // when resolving register roots in the managed frames above the bridge.
                RegRoot::RecordStubCalleeSaved(regSlotsMap, reinterpret_cast<Uptr>(frame.mFrame.GetFA()));
                break;
            case FrameType::STACKGROW:
                RegRoot::RecordRegs(regSlotsMap, reinterpret_cast<Uptr>(frame.mFrame.GetFA()));
                break;
            default: {
                break;
            }
        }
    }

#ifdef INTERPRETER_ENABLED
    auto expansionStackVisitor = [&](DYN_VisitingState state) {
        for (const auto& frame : stack) {
            switch (frame.GetFrameType()) {
                case FrameType::INTERPRETER:
                    VisitInterpreterFrameRootsExpansion(state, frame,
                        &traceAndFixPtrVisitor, &fixPtrVisitor, &derivedPtrVisitor);
                    break;
                default: {
                    break;
                }
            }
        }
    };

    IterateFramesWithState(mutator.interpreterCJThreadData, [](DYN_VisitingState state, void* ctx) {
        auto closure = reinterpret_cast<decltype(expansionStackVisitor)*>(ctx);
        (*closure)(state);
    }, &expansionStackVisitor);
#endif
}
} // namespace MapleRuntime
