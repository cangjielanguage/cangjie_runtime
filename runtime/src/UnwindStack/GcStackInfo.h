// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_GC_STACKINFO_H
#define MRT_GC_STACKINFO_H

#include "Base/LogFile.h"
#include "StackInfo.h"
#include "StackMap/StackMapTypeDef.h"

namespace MapleRuntime {
#define TRACE_STACK_MAX_DEPTH 15

struct VerifyStackRootContext;

class GCStackInfo : public StackInfo {
public:
    explicit GCStackInfo(const UnwindContext* context = nullptr) : StackInfo(context)
    {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
        DLOG(UNWIND, "GC Stack Info");
        DLOG(UNWIND, "TopContext : %x", context);
        if (context != nullptr) {
            DLOG(UNWIND, "Top Context ip : %x Top Context fa : %x", context->frameInfo.mFrame.GetIP(),
                 context->frameInfo.mFrame.GetFA());
        }
#endif
    }

    ~GCStackInfo() override = default;
    void FillInStackTrace() override;
    void VisitStackRoots(const RootVisitor& func, Mutator& mutator) const;
    bool VisitStackRootsForVerify(
        const RootVisitor& func, Mutator& mutator, VerifyStackRootContext& context) const;
    void VisitHeapReferencesOnStack(const RootVisitor& rootVisitor, const DerivedPtrVisitor& derivedPtrVisitor,
                                    Mutator& mutator) const;
private:
    template<bool forVerify>
    bool VisitStackRootsImpl(const RootVisitor& func, Mutator& mutator, VerifyStackRootContext* context) const;
};

class RecordStackInfo : public GCStackInfo {
public:
    explicit RecordStackInfo(const UnwindContext* context = nullptr, uint32_t threadId = 0,
                             CString threadname = nullptr, int threadState = -1)
        : GCStackInfo(context), tid(threadId), name(threadname), state(threadState) {}
    ~RecordStackInfo() override
    {
        for (auto f:stacks) {
            if (f==nullptr) {
                break;
            }
            delete f;
            f = nullptr;
        }
    }
    uint32_t GetStackTid() { return tid; }
    CString GetThreadName() { return name; }
    int GetThreadState() { return state; }
    FrameInfo* GetCurrentFramePtr() { return currentFramePtr; }
    void FillInStackTrace() override;
    void VisitStackRoots(const RootVisitor &func, Mutator &mutator);

    std::vector<FrameInfo* > stacks;

private:
    uint32_t tid = 0;
    CString name;
    FrameInfo* currentFramePtr = nullptr;
    int state;
};

class CJThreadStackInfo : public GCStackInfo {
public:
    explicit CJThreadStackInfo(const UnwindContext* context = nullptr, uint32_t pMaxStrSize = 0)
        : GCStackInfo(context), maxStrSize(pMaxStrSize) {}

    ~CJThreadStackInfo() override = default;

    void FillInStackTrace() override;
    void GetInfoFromStackTrace(uint32_t* framePcArr, char** funcNameArr, char** fileNameArr, uint32_t* lineNumbersArr);
    char* GetFuncOrFileNameStr(CString originName);
    int GetRealStackSize() { return realStackSize; }
    int GetFilledStackSize() { return filledStackSize; }

private:
    uint32_t maxStrSize;
    int filledStackSize = 0;
    int realStackSize = -1;
    int stackSkipThreshold = 2;
};

extern "C" MRT_EXPORT int CJ_MCC_InitCJthreadStackInfo(uint32_t maxStrSize, void *mut, uint32_t* framePcArr,
                            char** funcNameArr, char** fileNameArr, uint32_t* lineNumberArr);
int InitCJThreadStackInfoFromCurrFunc(uint32_t maxStrSize, uint32_t* framePcArr, char** funcNameArr,
                                      char** fileNameArr, uint32_t* lineNumberArr);

} // namespace MapleRuntime
#endif // MRT_GC_STACKINFO_H