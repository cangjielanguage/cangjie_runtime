// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_EXCEPTION_H
#define MRT_EXCEPTION_H

#include <vector>
#include <memory>

#include "CalleeSavedRegisterContext.h"
#include "Common/StackType.h"
#include "Common/TypeDef.h"
#include "Common/NativeAllocator.h"
#include "EhFrameInfo.h"

#if defined(CANGJIE_SANITIZER_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

namespace MapleRuntime {
// Restore the register context before jumping to the Cangjie code.
extern "C" void RestoreContextForEH();
// Use the register information in stackmap to restore correlative registers layer by layer.
extern "C" uintptr_t MRT_RestoreContext(CalleeSavedRegisterContext& context);

extern "C" uintptr_t MRT_GetTopManagedPC();

enum class SofStackFlag : uint64_t {
    NOT_FOLDED = 0,
    TOP_FOLDED = 1,
    BOTTOM_FOLDED = 2,
};

// The data structure of exception handling at runtime. In addition to package the exception object,
// it can also package some data used in exception handling at runtime.
class ExceptionWrapper {
public:
    enum class ExceptionType {
        UNKNOWN = 0,
        OUT_OF_MEMORY = 1,
        STACK_OVERFLOW = 2,
        ARITHMETIC = 3,
        INCOMPATIBILE_PACKAGE = 4,
        LOCAL_REGION_OUT_OF_MEMORY = 5,
    };

    ExceptionWrapper()
        : exceptionRef(nullptr), isCaught(false), typeIndex(0), landingPad(0), throwingOOME(false),
          throwingSOFFramePc(nullptr), adjustedSize(0), fatalException(false), message(nullptr), messageLength(0),
          topManagedPC(0)
    {
    }

    ~ExceptionWrapper()
    {
        exceptionRef = nullptr;
        landingPad = 0;
        if (message != nullptr) {
            free(message);
            message = nullptr;
        }
    }

    void SetExceptionRef(const ExceptionRef exRef) { exceptionRef = exRef; }

    void ClearInfo()
    {
        exceptionRef = nullptr;
        isCaught = false;
        typeIndex = 0;
        landingPad = 0;
        throwingOOME = false;
        throwingSOFFramePc = nullptr;
        adjustedSize = 0;
        fatalException = false;
        ehFrameInfos.clear();
        liteFrameInfos.clear();
        if (message != nullptr) {
            free(message);
            message = nullptr;
        }
        messageLength = 0;
    }

    const ExceptionRef& GetExceptionRef() const { return exceptionRef; }

    ExceptionRef& GetExceptionRef() { return exceptionRef; }

    void SetTopManagedPC(const uintptr_t ptr) { topManagedPC = ptr; }

    uintptr_t GetTopManagedPC() const { return topManagedPC; }

#ifdef INTERPRETER_ENABLED
    void SetCurrentCatchFunctionPC(const uintptr_t ptr) { currentCatchFunctionPC = ptr; }

    uintptr_t GetCurrentCatchFunctionPC() const { return currentCatchFunctionPC; }
#endif
    void SetIsCaught(bool caught) { isCaught = caught; }

    bool IsCaught() const { return isCaught; }

    void SetTypeIndex(uint32_t index) { typeIndex = index; }

    uint32_t GetTypeIndex() const { return typeIndex; }

    void SetLandingPad(uintptr_t addr) { landingPad = addr; }

    uintptr_t GetLandingPad() const { return landingPad; }

    void SetThrowingOOME(bool oom) { throwingOOME = oom; }

    bool IsThrowingOOME() const { return throwingOOME; }

    void SetThrowingSOFFramePc(void* sof) { throwingSOFFramePc = sof; }

    bool IsThrowingSOFE() const { return throwingSOFFramePc; }

    void SetAdjustedStackSize(uint32_t size) { adjustedSize = size; }

    void SetFatalException(bool fatal) { fatalException = fatal; }

    bool IsFatalException() const { return fatalException; }

    void SetExceptionType(ExceptionType type) { exceptionType = type; }

    ExceptionType GetExceptionType() const { return exceptionType; }

    void SetExceptionMessage(const char* ptr, size_t len)
    {
        if (message != nullptr) {
            free(message);
        }
        if (ptr == nullptr) {
            message = nullptr;
            messageLength = 0;
            return;
        }
        message = static_cast<char*>(malloc(len + 1));
        if (UNLIKELY(message == nullptr)) {
            LOG(RTLOG_FATAL, "Exception message init failed");
        }
        CHECK_DETAIL(memcpy_s(message, len, ptr, len) == EOK, "memcpy_s failed");
        message[len] = '\0';
        messageLength = len + 1;
    }

    const char* GetExceptionMessage() const { return message; }

    size_t GetExceptionMessageLength() const { return messageLength; }

    const char* GetExceptionTypeName() const
    {
        constexpr const char* nameTable[] = {
            "Exception",
            "OutOfMemoryError",
            "StackOverflowError",
            "ArithmeticException",
            "IncompatiblePackageException",
            "LocalRegionOutOfMemoryError",
        };
        return nameTable[static_cast<uint8_t>(exceptionType)];
    }

    std::vector<uint64_t>& GetLiteFrameInfos() { return liteFrameInfos; }

    void ClearEHFrameInfos() { ehFrameInfos.clear(); }

    std::vector<std::unique_ptr<IEHFrameInfo>>& GetEHFrameInfos() { return ehFrameInfos; }

    void Reset()
    {
        isCaught = false;
        typeIndex = 0;
        landingPad = 0;
        ClearEHFrameInfos();
        topManagedPC = 0;
    }

    void RestoreContext(CalleeSavedRegisterContext& context);

private:
    ExceptionRef exceptionRef;
    bool isCaught;
    uint32_t typeIndex;
    uintptr_t landingPad;

    // Mark whether the current status is throwing oom.
    bool throwingOOME;
    // Mark whether the current status is throwing sof.
    void* throwingSOFFramePc;
    uint32_t adjustedSize;
    // Mark whether the exception is fatal.
    bool fatalException;

    // Mark the exception type that is throwing from runtime
    ExceptionType exceptionType = ExceptionType::UNKNOWN;

    // frame info vector
    std::vector<std::unique_ptr<IEHFrameInfo>> ehFrameInfos;
    // stack trace pc and function start pc. vector layout is as follows.
    // function1 pc
    // function1 startpc
    // function2 pc
    // function2 startpc
    // ...
    std::vector<uint64_t> liteFrameInfos;
    char* message;
    size_t messageLength;
    uintptr_t topManagedPC;
#ifdef INTERPRETER_ENABLED
    // PC of function which caught exception
    uintptr_t currentCatchFunctionPC = 0;
#endif
};

class ExceptionHandling {
public:
    ExceptionHandling() = delete;
    explicit ExceptionHandling(ExceptionWrapper& mExceptionWrapper, void* context = nullptr)
        : eWrapper(&mExceptionWrapper), sigContext(context)
    {
        BuildEHFrameInfo();
        ChangeEHStackInfoLR();
    }
    ~ExceptionHandling()
    {
        eWrapper = nullptr;
        sigContext = nullptr;
    }

    // Unwind to build stack frame info.
    void BuildEHFrameInfo();
    // Change lr value on the managed stack by landing pad value.
    void ChangeEHStackInfoLR() const;

private:
    bool IsFromSignal() const { return sigContext != nullptr; }
    bool ProcessEHFrame(const FrameInfo& frame, std::vector<std::unique_ptr<IEHFrameInfo>>& ehFrameInfos);

    FrameInfo lastRuntimeFrame;
    ExceptionWrapper* eWrapper;
    // If the value is not empty, it means that an exception is thrown in the signal.
    void* sigContext;
};
} // namespace MapleRuntime
#endif // MRT_EXCEPTION_H
