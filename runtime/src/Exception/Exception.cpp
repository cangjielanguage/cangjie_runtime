// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Mutator/Mutator.h"
#include "Exception.h"

#include "Base/LogFile.h"
#include "Base/Macros.h"
#include "Base/Panic.h"
#include "StackManager.h"
#include "ExceptionCApi.h"
#include "Interpreter/InterpreterEHFrameInfo.h"
#include "Interpreter/InterpreterSpecific.h"
#include "Mutator/MutatorManager.h"
#include "UnwindStack/EhStackInfo.h"
#include "schedule.h"

namespace MapleRuntime {
// Use the prologue info in stackmap to restore the registers layer by layer.
// Return the capture point address.
extern "C" uintptr_t MRT_RestoreContext(CalleeSavedRegisterContext& context)
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    eWrapper.RestoreContext(context);
    auto tls = MRT_GetThreadLocalData();
#if defined(__x86_64__)
    if (context.r15 != tls) {
        context.r15 = tls;
    }
#elif defined(__aarch64__)
    if (context.x28 != tls) {
        context.x28 = tls;
    }
#elif defined(__arm__)
    (void)tls;
#endif
    return eWrapper.GetLandingPad();
}

extern "C" uintptr_t MRT_GetTopManagedPC()
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    return eWrapper.GetTopManagedPC();
}

void ExceptionWrapper::RestoreContext(CalleeSavedRegisterContext& context)
{
#ifdef GENERAL_ASAN_SUPPORT_INTERFACE
#if defined(__x86_64__)
    auto oldRsp = context.rsp;
#elif defined(__aarch64__)
    auto oldRsp = context.sp;
#elif defined(__arm__)
    auto oldRsp = context.sp;
#endif
#endif
    for (const auto& framePtr : ehFrameInfos) {
        DLOG(EXCEPTION, "RestoreContext: fa=%p, ip=%p, funcName=%s, isCatchException=%s",
            framePtr->GetFA(), framePtr->GetIP(), framePtr->GetFunctionName().GetStr(),
            framePtr->IsCatchException() ? "true" : "false");
        if (framePtr->IsCatchException()) {
#ifdef INTERPRETER_ENABLED
            Mutator* mutator = Mutator::GetMutator();
            if (mutator != nullptr) {
                mutator->GetExceptionWrapper().SetCurrentCatchFunctionPC(
                    reinterpret_cast<uintptr_t>(framePtr->GetIP()));
            }
#endif
            break;
        }

        if (framePtr->GetIP() == throwingSOFFramePc) {
            framePtr->RestoreToCallerContext(context, adjustedSize);
            adjustedSize = 0;
        } else {
            framePtr->RestoreToCallerContext(context);
        }
    }
#ifdef GENERAL_ASAN_SUPPORT_INTERFACE
#if defined(__x86_64__)
    Sanitizer::HandleNoReturn(oldRsp, context.rsp);
#elif defined(__aarch64__)
    Sanitizer::HandleNoReturn(oldRsp, context.sp);
#elif defined(__arm__)
    Sanitizer::HandleNoReturn(oldRsp, context.sp);
#endif
#endif
}

void ExceptionHandling::BuildEHFrameInfo()
{
    EHStackInfo ehStackInfo;
    ehStackInfo.FillInStackTrace();
    std::vector<FrameInfo>& stackInfo = ehStackInfo.GetStack();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    if (UNLIKELY(ENABLE_LOG(EXCEPTION))) {
        DLOG(EXCEPTION, "build eh stack");
        DLOG(EXCEPTION, "FrameInfos\tsize : %zu", stackInfo.size());
        DLOG(EXCEPTION, "layer\tFrameType\tFA\t\tIP\t\tStartProc\tLSDAStart\t");
        for (int i = 0; i < stackInfo.size(); ++i) {
            DLOG(EXCEPTION, "#%x\t%x\t\t%x\t%x\t0x%x\t0x%x", i, stackInfo[i].GetFrameType(),
                stackInfo[i].mFrame.GetFA(), stackInfo[i].mFrame.GetIP(),
                reinterpret_cast<uintptr_t>(stackInfo[i].GetStartProc()),
                reinterpret_cast<uintptr_t>(stackInfo[i].GetLsdaProc()));
        }
    }
#endif
    std::vector<std::unique_ptr<IEHFrameInfo>>& ehFrameInfos = eWrapper->GetEHFrameInfos();
    for (const auto& frame : stackInfo) {
        if (ProcessEHFrame(frame, ehFrameInfos)) {
            break;
        }
    }

    if (UNLIKELY(ENABLE_LOG(EXCEPTION))) {
        DLOG(EXCEPTION, "parse eh stack");
        DLOG(EXCEPTION, "EHFrameInfos size : %zu", ehFrameInfos.size());
        DLOG(EXCEPTION, "Layer\tFA\t\tIP\t\tTTpyeIndex\t\tLandingPad\tCatch\t");
        for (size_t i = 0; i < ehFrameInfos.size(); ++i) {
            DLOG(EXCEPTION, "#%zx\t%x\t%x\t%x\t0x%p\t%x", i, ehFrameInfos[i]->GetFA(), ehFrameInfos[i]->GetIP(),
                ehFrameInfos[i]->GetTTypeIndex(), reinterpret_cast<void*>(ehFrameInfos[i]->GetLandingPad()),
                ehFrameInfos[i]->IsCatchException());
        }
    }
}

bool ExceptionHandling::ProcessEHFrame(const FrameInfo& frame, std::vector<std::unique_ptr<IEHFrameInfo>>& ehFrameInfos)
{
    if (frame.GetFrameType() == FrameType::MANAGED) {
        ehFrameInfos.push_back(std::make_unique<EHFrameInfo>(frame, *eWrapper));
        if (!ehFrameInfos.back()->IsCatchException()) {
            return false;
        }
        eWrapper->SetIsCaught(true);
        eWrapper->SetTypeIndex(ehFrameInfos.back()->GetTTypeIndex() & 0xFFFFFFFF);
        eWrapper->SetLandingPad(ehFrameInfos.back()->GetLandingPad());
        return true;
    }
#ifdef __arm__
    if (frame.GetFrameType() == FrameType::STACKGROW) {
        return false;
    }
#endif
#ifdef INTERPRETER_ENABLED
    auto frameType = frame.GetFrameType();
    if (frameType == FrameType::INTERPRETER) {
        ehFrameInfos.push_back(std::make_unique<InterpreterEHFrameInfo>(frame, GetCommonInterpreterLandingPad()));
        eWrapper->SetIsCaught(true);
        eWrapper->SetTypeIndex(0);
        eWrapper->SetLandingPad(ehFrameInfos.back()->GetLandingPad());
        return true;
    }
    if (UNLIKELY(frameType == FrameType::INTERPRETER_I2I || frameType == FrameType::INTERPRETER_I2N ||
        frameType == FrameType::INTERPRETER_C2I)) {
        LOG(RTLOG_FATAL, "should not reach here: did not met interpreted frame before I2I/I2N/C2I frame");
        return false;
    }
#endif
    lastRuntimeFrame = frame;
    return false;
}

void ExceptionHandling::ChangeEHStackInfoLR() const
{
    std::vector<std::unique_ptr<IEHFrameInfo>>& ehFrameInfos = eWrapper->GetEHFrameInfos();
    if (UNLIKELY(ehFrameInfos.size() == 0)) {
        LOG(RTLOG_ERROR, "There are no one managed frame in the stack block.");
        return;
    }

    DLOG(EXCEPTION, "ExceptionHandling::ChangeEHStackInfoLR");

    if (!eWrapper->IsCaught()) {
        const uint32_t* addr = ehFrameInfos.back()->GetFA()->returnAddress;
        DLOG(EXCEPTION, "  Exception is not caught, landing pad set to %p", addr);
        eWrapper->SetLandingPad(reinterpret_cast<uintptr_t>(const_cast<uint32_t*>(addr)));
    }

    eWrapper->SetTopManagedPC(
        reinterpret_cast<uintptr_t>(const_cast<uint32_t*>(lastRuntimeFrame.mFrame.GetFA()->returnAddress)));

    DLOG(EXCEPTION, "  Top managed PC = %p", eWrapper->GetTopManagedPC());

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    auto mod = reinterpret_cast<uint64_t>(lastRuntimeFrame.mFrame.GetFA()) +
        GetRuntimeFrameSize((MachineFrame&)lastRuntimeFrame.mFrame);
    auto pc = PtrauthSignWithInstAkey(reinterpret_cast<Uptr>(RestoreContextForEH), reinterpret_cast<Uptr>(mod));
    lastRuntimeFrame.mFrame.GetFA()->returnAddress = reinterpret_cast<uint32_t*>(pc);
#else
    lastRuntimeFrame.mFrame.GetFA()->returnAddress = reinterpret_cast<uint32_t*>(RestoreContextForEH);
#endif

    DLOG(EXCEPTION, "  Last runtime frame (fa=%p, ip=%p) redirected to RestoreContextForEH",
        lastRuntimeFrame.mFrame.GetFA(), lastRuntimeFrame.mFrame.GetIP());
}
} // namespace MapleRuntime
