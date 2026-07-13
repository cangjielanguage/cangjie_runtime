// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_STACK_TYPE_H
#define MRT_STACK_TYPE_H

#include <cstdint>

#include "Base/CString.h"
#include "Base/Log.h"
#include "Base/Types.h"
#include "Common/Dataref.h"
#include "TypeDef.h"

namespace MapleRuntime {
// Since the linker interface has not been enabled, some functions are first replaced by the
// unwind library interface. The libunwind library can be installed by the following command.
//      sudo apt-get install libunwind-dev
#define USE_LIBUNWIND 0

const uint64_t STACK_UNWIND_STEP_MAX = INT_MAX;

enum class FrameType {
    UNKNOWN = 0,
    MANAGED = 1,
    N2C_STUB = 2,
    C2N_STUB = 3,
    RUNTIME = 4,
    SAFEPOINT = 5,
    C2R_STUB = 6,
    NATIVE = 7,
    STACKGROW = 8,
    EXSLUSIVE = 9,
};

enum class StackMode {
    EH = 0,
    GC = 1,
    PRINT = 2,
};

enum class UnwindContextStatus {
    UNKNOWN = 0,
    RELIABLE = 1,
    RISKY = 2,
    // The purpose is to distinguish whether the signal is a Cangjie signal,
    // but it does not actually solve the problem.
    SIGNAL_STATUS = 3,
};

// this data struct matches the machine frame layout for both aarch64 and arm.
//                 |  ...           |
//                 |  ...           |
//                 |  lr to caller  | return address for this frame
//        fp  -->  |  caller fp     |
//                 |  ...           |
//        sp  -->  |  ...           |
struct FrameAddress {
    FrameAddress* callerFrameAddress;
    const uint32_t* returnAddress;
};

// N2CSlotData is a helper for retrieving previous managed context.
// this data struct should match the layout defined in r2c_stub
struct N2CSlotData {
    const uint32_t* pc;
    FrameAddress* fa;
    UnwindContextStatus status;
};

// Data structure when the runtime part is used for stack information.
struct StackTraceElement {
    CString className;
    CString methodName;
    CString fileName;
    int64_t lineNumber;
};

// Stack data structure used to return data of the arrayRef type to the cangjie code.
struct StackTraceData {
    ArrayRef className;
    ArrayRef methodName;
    ArrayRef fileName;
    int64_t lineNumber;
};

// Thread snapshot structure used to return data of the arrayRef type to cangjie code.
struct ThreadSnapshot {
    ArrayRef name;
    int64_t id;
    ArrayRef stackTrace;
    int64_t state;
};

class FrameInfo;

// Minimal stack information data structure, used for fast stack back,
// no need to parse other data
class MachineFrame {
public:
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    MachineFrame(FrameAddress* pFa, const uint32_t* pIp, const uint64_t* pPtrAuthRAMod = nullptr)
        : fa(pFa), ip(pIp), ptrAuthRAMod(pPtrAuthRAMod) {}

    MachineFrame() : fa(nullptr), ip(nullptr), ptrAuthRAMod(nullptr) {}
#else
    MachineFrame(FrameAddress* pFa, const uint32_t* pIp) : fa(pFa), ip(pIp) {}

    MachineFrame() : fa(nullptr), ip(nullptr) {}
#endif

    MachineFrame(const MachineFrame& mFrame)
    {
        this->fa = mFrame.fa;
        this->ip = mFrame.ip;
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
        this->ptrAuthRAMod = mFrame.ptrAuthRAMod;
#endif
    }

    MachineFrame& operator=(const MachineFrame& mFrame)
    {
        if (this != &mFrame) {
            this->fa = mFrame.fa;
            this->ip = mFrame.ip;
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
            this->ptrAuthRAMod = mFrame.ptrAuthRAMod;
#endif
        }
        return *this;
    }

    virtual ~MachineFrame()
    {
        fa = nullptr;
        ip = nullptr;
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
        ptrAuthRAMod = nullptr;
#endif
    }

    inline const uint32_t* GetIP() const { return ip; }

    inline FrameAddress* GetFA() const { return fa; }

    inline void SetIP(const uint32_t* addr) { this->ip = addr; }

    inline void SetFA(FrameAddress* frameAddress) { this->fa = frameAddress; }

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    inline const uint64_t* GetPtrAuthRAMod() const { return ptrAuthRAMod; }
    inline void SetPtrAuthRAMod(const uint64_t* pacRAModifier) { this->ptrAuthRAMod = pacRAModifier; }
#endif

    bool IsRuntimeFrame() const;

    bool IsN2CStubFrame() const;

    bool IsC2NStubFrame() const;

    bool IsC2RStubFrame() const;

    bool IsExclusiveStubFrame() const;

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    bool IsC2NExceptionStubFrame() const;
#endif

    bool IsStackGrowStubFrame() const;

    bool IsSafepointHandlerStubFrame() const;

    bool IsAnchorFrame(const uint32_t* anchorFA) const;

    void Reset()
    {
        fa = nullptr;
        ip = nullptr;
    }

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    CString DumpMachineFrame() const;

    void Dump(const CString msg) const;
#endif

    // return SUCC or FINISH only, do not return FAIL.
    // caller assures this frame is a normal frame.
    // we name the direct caller frame in machine stack with "machine caller".
#ifdef _WIN64
    bool UnwindToCallerMachineFrame(FrameInfo& caller, UnwindContextStatus& status) const;
#else
    bool UnwindToCallerMachineFrame(MachineFrame& caller) const;
#endif

    friend class FrameInfo;

protected:
    // fa: frame address of this frame, for now this is frame pointer
    FrameAddress* fa;

    // ip: instruction pointer, the value in PC register when unwinding this frame,
    // which points to the instruction when control flow returns from callee to this frame.
    const uint32_t* ip;
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    const uint64_t* ptrAuthRAMod;
#endif
};

class FrameInfo {
public:
    FrameInfo() : startProc(nullptr), lsdaStart(nullptr), fType(FrameType::UNKNOWN) {}

    explicit FrameInfo(const uint32_t* pStartProc)
        : startProc(pStartProc), lsdaStart(nullptr), fType(FrameType::UNKNOWN)
    {}

    explicit FrameInfo(const MachineFrame& machineFrame, FrameType type = FrameType::UNKNOWN)
        : mFrame(machineFrame), startProc(nullptr), lsdaStart(nullptr), fType(type)
    {}

    FrameInfo(const FrameInfo& frame)
    {
        this->mFrame = frame.mFrame;
        this->startProc = frame.startProc;
        this->lsdaStart = frame.lsdaStart;
        this->fType = frame.fType;
    }

    virtual FrameInfo& operator=(const FrameInfo& frame)
    {
        if (this != &frame) {
            this->mFrame = frame.mFrame;
            this->startProc = frame.startProc;
            this->lsdaStart = frame.lsdaStart;
            this->fType = frame.fType;
        }
        return *this;
    }

    virtual ~FrameInfo() { Reset(); }

    void Reset() noexcept
    {
        mFrame.Reset();
        startProc = nullptr;
        lsdaStart = nullptr;
        fType = FrameType::UNKNOWN;
    }

    void SetFrameType(FrameType type) { fType = type; }

    const uint32_t* GetStartProc() const { return startProc; }

    const uint8_t* GetLsdaProc() const { return lsdaStart; }

    FrameType GetFrameType() const { return fType; }

    MachineFrame GetMachineFrame() const { return mFrame; }

    // Get startProc and lsdaStart by parsing the ip.
    void ResolveProcInfo();

    // print this frame symbol
    virtual void PrintFrameInfo(uint32_t frameIdx = 0) const;
#if defined(__IOS__)
    CString GetFrameInfo(uint32_t frameIdx = 0) const;
#endif

    const CString GetFuncName() const;
    const CString GetMethodName() const;
    const CString GetPackClassName() const;
    const CString GetFileName() const;
    const CString GetFileNameForTrace() const;
    uint32_t GetLineNum() const;
    uint32_t GetFramePc() const;

    // On the x86 architecture, at the entry of each function, a fixed offset
    // address of the starting position of the function is pushed onto the
    // stack at the fixed offset position of fp.
    // start_pc:   push   %rbp
    //             mov    %rsp,%rbp
    //             callq  0x401a8d <start_pc+9>
    // start_pc+9: sub    $0x18,%rsp
    //             ...
    // stack layout
    // high address   caller ip
    //                rbp       ===>  FrameAddress fa
    //                start_pc+9
    // low address    ...
    static uint32_t* GetFuncStartPCFromFrameAddress(FrameAddress* fa)
    {
        return reinterpret_cast<uint32_t*>(*(reinterpret_cast<uint64_t*>(fa) - 1) - START_PC_OFFSET_IN_STACK);
    }

    const uint32_t* GetFuncStartPC() const
    {
#if defined(_WIN64)
        return startProc;
#else
        return reinterpret_cast<const uint32_t*>(*(reinterpret_cast<ArchUInt*>(mFrame.fa) - 1) -
                                                 START_PC_OFFSET_IN_STACK);
#endif
    }

    // Basic ip and fa information data structure.
    MachineFrame mFrame;

protected:
    const uint32_t* startProc;
    const uint8_t* lsdaStart;
    FrameType fType;

#if defined(__x86_64__)
    static constexpr uint32_t START_PC_OFFSET_IN_STACK = 9;
#elif defined(__arm__)
    // 12 means: After execute stmdb sp!,{pc}, the difference between the pc stored by sp
    // and the pc of the function entry
    static constexpr uint32_t START_PC_OFFSET_IN_STACK = 12;
#else
    static constexpr uint32_t START_PC_OFFSET_IN_STACK = 0;
#endif
};

class SigHandlerFrameinfo : public FrameInfo {
public:
    SigHandlerFrameinfo() : FrameInfo() {}
    explicit SigHandlerFrameinfo(const uint32_t* pStartProc) : FrameInfo(pStartProc) {}
    explicit SigHandlerFrameinfo(const MachineFrame& machineFrame, FrameType type = FrameType::UNKNOWN)
        : FrameInfo(machineFrame, type)
    {}

    SigHandlerFrameinfo(const SigHandlerFrameinfo& frame) : FrameInfo(frame) {}
    SigHandlerFrameinfo& operator=(const SigHandlerFrameinfo& frame)
    {
        if (this != &frame) {
            this->mFrame = frame.GetMachineFrame();
            this->startProc = frame.GetStartProc();
            this->lsdaStart = frame.GetLsdaProc();
            this->fType = frame.GetFrameType();
        }
        return *this;
    }
    SigHandlerFrameinfo& operator=(const FrameInfo& frame) override
    {
        if (this != &frame) {
            this->mFrame = frame.GetMachineFrame();
            this->startProc = frame.GetStartProc();
            this->lsdaStart = frame.GetLsdaProc();
            this->fType = frame.GetFrameType();
        }
        return *this;
    }
    ~SigHandlerFrameinfo() override { Reset(); }

    void PrintFrameInfo(uint32_t frameIdx = 0) const override;
};

// N2CFrame is a stub frame constructed by native code to invoke compiled methods. N2CFrame saves
// its managed caller context as it is for unwinding. N2CStub is implemented in n2cStub.S.
// Runtime code must be always compiled with -fno-omit-frame-pointer to maintain standard frame layout according to ABI.
class N2CFrame : public MachineFrame {
public:
    N2CFrame() : MachineFrame() {}
    ~N2CFrame() override = default;
    N2CFrame(FrameAddress* pFa, const uint32_t* pIp) : MachineFrame(pFa, pIp) {}

    static N2CSlotData* GetSlotData(FrameAddress* fa)
    {
#if defined __aarch64__ || defined (__arm__)  // todo
        return reinterpret_cast<N2CSlotData*>(fa + OFFSET_FOR_UNWIND_DATA);
#else
        return reinterpret_cast<N2CSlotData*>(reinterpret_cast<N2CSlotData*>(fa) + OFFSET_FOR_UNWIND_DATA);
#endif
    }

    N2CSlotData* GetSlotData() const { return GetSlotData(this->fa); }

private:
#if defined __aarch64__ || defined (__arm__)  // todo
    static constexpr int64_t OFFSET_FOR_UNWIND_DATA = 1;
#else
    static constexpr int64_t OFFSET_FOR_UNWIND_DATA = -1;
#endif
};

// This class contains all stacks except native stacks, including cangjie and runtime and C2N Stub
// and R2C Stub.
class UnwindContext {
public:
    UnwindContext() : status(UnwindContextStatus::UNKNOWN) {}

    explicit UnwindContext(const MachineFrame& mFrame) : frameInfo(mFrame), status(UnwindContextStatus::UNKNOWN) {}

    UnwindContext(const UnwindContext& frame)
    {
        frameInfo = frame.frameInfo;
        status = frame.GetUnwindContextStatus();
    }

    UnwindContext& operator=(const UnwindContext& frame)
    {
        if (this != &frame) {
            this->frameInfo = frame.frameInfo;
            this->anchorFA = frame.anchorFA;
            this->status = frame.GetUnwindContextStatus();
        }
        return *this;
    }

    virtual ~UnwindContext() { anchorFA = nullptr; }

    void Reset()
    {
        frameInfo.Reset();
        anchorFA = nullptr;
        status = UnwindContextStatus::UNKNOWN;
    }

    void SetUnwindContextStatus(UnwindContextStatus unwindContextStatus) { this->status = unwindContextStatus; }

    UnwindContextStatus GetUnwindContextStatus() const { return status; }

    static void RestoreUnwindContextFromN2CStub(FrameAddress* fa);

#ifdef _WIN64
    bool UnwindToCallerContext(UnwindContext& caller, UnwindContextStatus& uwCtxStatus) const;
#else
    // Get caller managed frame
    bool UnwindToCallerContext(UnwindContext& caller) const;
    bool UnwindToCallerContextFromN2CStub(UnwindContext& caller) const;
#endif

    void GoIntoManagedCode();
    void GoIntoNativeCode(const uint32_t* pc, void* fa);

    FrameInfo frameInfo;

    // Use to save anchorFA stored in tls.
    uint32_t* anchorFA = nullptr;

protected:
    UnwindContextStatus status;
};

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
void InitPtrAuthRAMod(FrameInfo& callerFrameInfo, FrameInfo& calleeFrameInfo);
uint64_t GetRuntimeFrameSize(MachineFrame &mFrame);
#endif

inline void MRT_Check(bool ok, const CString& msg) { CHECK_DETAIL(ok, msg.Str()); }
} // namespace MapleRuntime
#endif // MRT_STACK_TYPE_H
