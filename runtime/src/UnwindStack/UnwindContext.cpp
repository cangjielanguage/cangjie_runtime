// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Base/LogFile.h"
#include "Common/StackType.h"

namespace MapleRuntime {

#ifndef _WIN64
bool UnwindContext::UnwindToCallerContextFromN2CStub(UnwindContext& caller) const
{
    N2CSlotData* n2cSlotData = N2CFrame::GetSlotData(frameInfo.mFrame.GetFA());
    if (n2cSlotData->status == UnwindContextStatus::RISKY ||
        n2cSlotData->status == UnwindContextStatus::SIGNAL_STATUS ||
        n2cSlotData->status == UnwindContextStatus::UNKNOWN) {
        caller.frameInfo.mFrame.SetFA(n2cSlotData->fa);
        caller.frameInfo.mFrame.SetIP(n2cSlotData->pc);
    } else if (n2cSlotData->status == UnwindContextStatus::RELIABLE) {
        frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo.mFrame);
    }

    caller.SetUnwindContextStatus(UnwindContextStatus::RELIABLE);
    return true;
}

bool UnwindContext::UnwindToCallerContext(UnwindContext& caller) const
{
    DLOG(UNWIND, "UnwindToCallerContext");
    DLOG(UNWIND, "Current UnwindContext status : %p",
         static_cast<std::underlying_type<UnwindContextStatus>::type>(status));
    DLOG(UNWIND, "FrameInfo->FA\t%p", frameInfo.mFrame.GetFA());
    DLOG(UNWIND, "FrameInfo->IP\t%p", frameInfo.mFrame.GetIP());
    DLOG(UNWIND, "FrameInfoType\t%d", frameInfo.GetFrameType());
    DLOG(UNWIND, "FrameInfo->lsda\t%p", reinterpret_cast<uintptr_t>(frameInfo.GetLsdaProc()));
    DLOG(UNWIND, "FrameInfo->startProc\t%p", reinterpret_cast<uintptr_t>(frameInfo.GetStartProc()));
    if (frameInfo.GetFrameType() == FrameType::N2C_STUB) {
        UnwindToCallerContextFromN2CStub(caller);
    } else if (frameInfo.GetFrameType() == FrameType::EXCLUSIVE) {
        UnwindExclusiveBridgeToCaller(caller);
    } else {
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
        auto res = frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo.mFrame);
        if (res) {
            InitPtrAuthRAMod(caller.frameInfo, (FrameInfo&)frameInfo);
        }
        return res;
#else
        return frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo.mFrame);
#endif
    }

    return true;
}

#else
// In Windows, the time is based on the same stack unwind logic,
// except that the rbp recorded in the slot is used for jump during N2CStub.
bool UnwindContext::UnwindToCallerContext(UnwindContext& caller, UnwindContextStatus& uwCtxStatus) const
{
    DLOG(UNWIND, "UnwindToCallerContext");
    DLOG(UNWIND, "Current UnwindContext status : %p",
         static_cast<std::underlying_type<UnwindContextStatus>::type>(status));
    DLOG(UNWIND, "FrameInfo->FA\t%p", frameInfo.mFrame.GetFA());
    DLOG(UNWIND, "FrameInfo->IP\t%p", frameInfo.mFrame.GetIP());
    DLOG(UNWIND, "FrameInfoType\t%d", frameInfo.GetFrameType());
    DLOG(UNWIND, "FrameInfo->lsda\t%p", reinterpret_cast<uintptr_t>(frameInfo.GetLsdaProc()));
    DLOG(UNWIND, "FrameInfo->startProc\t%p", reinterpret_cast<uintptr_t>(frameInfo.GetStartProc()));
    if (frameInfo.GetFrameType() == FrameType::N2C_STUB) {
        N2CSlotData* n2cSlotData = N2CFrame::GetSlotData(frameInfo.mFrame.GetFA());
        if (n2cSlotData->status == UnwindContextStatus::RISKY ||
            n2cSlotData->status == UnwindContextStatus::SIGNAL_STATUS ||
            n2cSlotData->status == UnwindContextStatus::UNKNOWN) {
            caller.frameInfo.mFrame.SetFA(n2cSlotData->fa);
            caller.frameInfo.mFrame.SetIP(n2cSlotData->pc);
        } else if (n2cSlotData->status == UnwindContextStatus::RELIABLE) {
            frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo, uwCtxStatus);
        }
        caller.SetUnwindContextStatus(UnwindContextStatus::RELIABLE);
        return true;
    } else if (frameInfo.GetFrameType() == FrameType::EXCLUSIVE) {
        UnwindExclusiveBridgeToCaller(caller);
    } else {
    return frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo, uwCtxStatus);
    }
    return true;
}
#endif

void UnwindContext::UnwindExclusiveBridgeToCaller(UnwindContext& caller) const
{
    FrameAddress* stubFa = frameInfo.mFrame.GetFA()->callerFrameAddress;
    caller.frameInfo.mFrame.SetFA(stubFa->callerFrameAddress);
    caller.frameInfo.mFrame.SetIP(stubFa->returnAddress);
    caller.SetUnwindContextStatus(UnwindContextStatus::RELIABLE);
}

void UnwindContext::GoIntoManagedCode()
{
    frameInfo.mFrame.SetIP(nullptr);
    frameInfo.mFrame.SetFA(nullptr);
    status = UnwindContextStatus::RELIABLE;
}

void UnwindContext::GoIntoNativeCode(const uint32_t* pc, void* fa)
{
    frameInfo.mFrame.SetIP(pc);
    frameInfo.mFrame.SetFA(reinterpret_cast<FrameAddress*>(fa));
    status = UnwindContextStatus::RISKY;
}
} // namespace MapleRuntime
