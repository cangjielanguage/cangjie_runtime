// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_STACK_MANAGER_H
#define MRT_STACK_MANAGER_H

#include <map>

#include "Common/StackType.h"
#include "Common/TypeDef.h"
#include "StackMap/StackMap.h"
#include "UnwindStack/StackInfo.h"

namespace MapleRuntime {
struct VerifyStackRootContext;

class StackManager {
public:
    StackManager();
    ~StackManager() = default;

    // runtime required lifecycle interfaces
    void Init();
    void Fini() const;

#ifdef __arm__
    static uint32_t rtStartAddr;
    static uint32_t rtEndAddr;
    static uint32_t cjThreadStartAddr;
    static uint32_t cjThreadEndAddr;
    static uint32_t coreSoStartAddr;
    static uint32_t coreSoEndAddr;
    static uint32_t cjcSoStartAddr;
    static uint32_t cjcSoEndAddr;
    static uint32_t traceSoStartAddr;
    static uint32_t traceSoEndAddr;
#else
    static uint64_t rtStartAddr;
    static uint64_t rtEndAddr;
    static uint64_t cjThreadStartAddr;
    static uint64_t cjThreadEndAddr;
    static uint64_t coreSoStartAddr;
    static uint64_t coreSoEndAddr;
    static uint64_t cjcSoStartAddr;
    static uint64_t cjcSoEndAddr;
    static uint64_t traceSoStartAddr;
    static uint64_t traceSoEndAddr;

    #ifdef INTERPRETER_ENABLED
    static uint64_t interpreterSoStartAddr;
    static uint64_t interpreterSoEndAddr;
    #endif
#endif

    // debug interface for runtime to get all stack trace.
    static void PrintStackTrace(UnwindContext* unContext = nullptr);

    static void PrintSignalStackTrace(UnwindContext* uwContext, uintptr_t pc, uintptr_t fa);

    static void PrintStackTraceForCpuProfile(UnwindContext* unContext, unsigned long long int cjThreadId);

    static void RecordLiteFrameInfos(std::vector<uint64_t>& liteFrameInfos, size_t steps = STACK_UNWIND_STEP_MAX);

    static void GetStackTraceByLiteFrameInfos(const std::vector<uint64_t>& liteFrameInfos,
                                              std::vector<StackTraceElement>& stackTrace);

    static void GetStackTraceByLiteFrameInfo(const uint64_t ip, const uint64_t pc, const uint64_t funcDesc,
                                             StackTraceElement& ste);

    // visit GC roots of current managed thread for tracing GC.
    static void VisitStackRoots(const UnwindContext& topFrame, const RootVisitor& func, Mutator& mutator);
    __attribute__((visibility("hidden"))) static bool VisitStackRootsForVerify(
        const UnwindContext& topFrame, const RootVisitor& func, Mutator& mutator, VerifyStackRootContext& context);
    static void VisitHeapReferencesOnStack(const UnwindContext& topFrame, const RootVisitor& rootVisitor,
                                           const DerivedPtrVisitor& derivedPtrVisitor, Mutator& mutator);

    static void VisitStackPtrMap(const UnwindContext& topFrame, const StackPtrVisitor& traceAndFixPtrVisitor,
                                 const StackPtrVisitor& fixPtrVisitor, const DerivedPtrVisitor& derivedPtrVisitor,
                                 Mutator& mutator);

    static void InitStackGrowConfig();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    static std::vector<FrameInfo> GetCurrentStack(StackMode mode);
#endif

    static bool IsRuntimeFrame(Uptr pc);
#ifdef INTERPRETER_ENABLED
    /**
     * @brief Initialize the interpreter code address range.
     * @param libName Interpreter library name used for path-based lookup on Linux and macOS.
     * @param symbol Symbol inside the interpreter image used for Mach-O lookup on iOS.
     */
    static void InitAddressScopeForInterpreter(const char* libName, const void* symbol);

    static bool IsInterpreterCodeAddr(Uptr pc);
#endif
    friend class MachineFrame;

private:
    // Initialize the so load address defined below.
    void InitAddressScope();
};

void InitAddressScopeForCJthreadTrace();

} // namespace MapleRuntime

#endif // MRT_STACK_MANAGER_H
