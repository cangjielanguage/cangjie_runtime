// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "Base/Types.h"
#include "Common/TypeDef.h"
#if defined(_WIN64)
#define NOGDI
#include <windows.h>
#endif
#include "Collector/CopyCollector.h"
#include "Common/ScopedObjectAccess.h"
#include "Concurrency/ConcurrencyModel.h"
#include "Heap/Collector/FinalizerProcessor.h"
#include "Heap/WCollector/WCollector.h"
#include "ObjectModel/RefField.inline.h"
#include "MutatorManager.h"
#include "StackManager.h"
#include "ExceptionManager.h"
#include "schedule.h"
#ifdef _WIN64
#include "WinModuleManager.h"
#endif
#include "CpuProfiler/CpuProfiler.h"
#include "Base/LogFile.h"
#include "Interpreter/InterpreterSpecific.h"

namespace MapleRuntime {
extern "C" uintptr_t MRT_GetThreadLocalData()
{
    uintptr_t tlDataAddr = reinterpret_cast<uintptr_t>(ThreadLocal::GetThreadLocalData());
#if defined(__aarch64__)
    if (Heap::GetHeap().IsGcStarted()) {
        // Since the TBI(top bit ignore) feature in Aarch64,
        // set gc phase to high 8-bit of ThreadLocalData Address for gc barrier fast path.
        // 56: make gcphase value shift left 56 bit to set the high 8-bit
        tlDataAddr = tlDataAddr | (static_cast<uint64_t>(Heap::GetHeap().GetGCPhase()) << 56);
    }
#endif
    return tlDataAddr;
}

extern "C" bool MRT_EnterSaferegion(bool updateUnwindContext)
{
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return false;
    }
    return mutator->EnterSaferegion(updateUnwindContext);
}

extern "C" bool MRT_LeaveSaferegion()
{
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return false;
    }
    return mutator->LeaveSaferegion();
}

extern "C" void MRT_SetGrowFlag(bool flag)
{
    if (!CJThreadSetStackGrow(flag)) {
        return;
    }
    LOG(RTLOG_ERROR, "Set flag of GROWStack faild.");
}

extern "C" intptr_t MRT_StackGrow(intptr_t frameBase, uint32_t adjustedSize, void* ip)
{
    // arm32 only do stack check and try to throw StackOverFlow Expection.
#ifdef __arm__
    if (adjustedSize != 0) {
        LOG(RTLOG_FAIL, "Unsupported stack grow for arm32");
    }
    uintptr_t threadData = MRT_GetThreadLocalData();
    uint32_t protectAddr = reinterpret_cast<uint32_t>(reinterpret_cast<ThreadLocalData*>(threadData)->protectAddr);
    // for runtime we could not add sp asm, keep a PRESERVE_SIZE to avoid stepping on illegal memory
    constexpr uint32_t PRESERVE_SIZE = 256;
    if (protectAddr >= frameBase - PRESERVE_SIZE) {
        void* fa = __builtin_frame_address(0);
        static_cast<FrameAddress*>(fa)->returnAddress = static_cast<uint32_t*>(ip);
        ExceptionManager::StackOverflow(adjustedSize, ip);
        return 0;
    }
    return 0;
#else
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return false;
    }
    return mutator->FixExtendedStack(frameBase, adjustedSize, ip);
#endif
}

extern "C" void MRT_FreeOldStack(intptr_t offset)
{
    if (offset == 0) { return; }
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return;
    }
    CJThreadOldStackFree(reinterpret_cast<void*>(mutator->GetStackTopAddr()), mutator->GetStackSize());
    mutator->SetStackTopAddr(reinterpret_cast<uintptr_t>(CJThreadStackAddrGet()));
    mutator->SetStackSize(CJThreadStackSizeGet());
    mutator->SetStackBaseAddr(reinterpret_cast<uintptr_t>(CJThreadStackBaseAddrGet()));
}

extern "C" void MRT_SetStackGrow(bool enableStackScale)
{
    if (ThreadLocal::GetThreadType() == ThreadType::FP_THREAD) {
        return;
    }
    if (!CJThreadSetStackGrow(enableStackScale)) {
        return;
    } else {
#if not defined (__OHOS__) && not defined (_WIN64)
        LOG(RTLOG_ERROR, "CJThread Set StackScale failed");
#endif
    }
}

#ifdef INTERPRETER_ENABLED
void Mutator::InitInterpreterPart()
{
    if (isRuntimeMutator) {
        return;
    }

    DLOG(INTERPRETER, "[Mutator] init interpreter part for cjThread %p\n", this);
    InterpreterCJThreadStart(&(this->interpreterCJThreadData));
}

void Mutator::DestroyInterpreterPart()
{
    if (isRuntimeMutator) {
        return;
    }

    DLOG(INTERPRETER, "[Mutator] destruct interpreter part for cjThread %p\n", this);
    InterpreterCJThreadDestroy(&(this->interpreterCJThreadData));
}
#endif

void Mutator::InitProtectStackAddr()
{
#if defined(_WIN64)
    _TEB* teb = NtCurrentTeb();
    stackBoundAddr = reinterpret_cast<void*>(reinterpret_cast<NT_TIB64*>(teb)->StackLimit);
#elif defined(__APPLE__)
    stackBoundAddr = pthread_get_stackaddr_np(pthread_self());
#else
    pthread_attr_t attr;
    pthread_t thread = pthread_self();
    CHECK_PTHREAD_CALL(pthread_getattr_np, (thread, &attr), "get thread attr failed");
    uintptr_t sSize = 0;
    CHECK_PTHREAD_CALL(pthread_attr_getstack, (&attr, &stackBoundAddr, &sSize), "get thread stack attr failed");
    CHECK_PTHREAD_CALL(pthread_attr_destroy, (&attr), "destroy pthread attr");
#endif
    size_t reversedSize = Runtime::Current().GetConcurrencyModel().GetReservedStackSize();
    ThreadLocal::SetProtectAddr(reinterpret_cast<uint8_t*>(reinterpret_cast<uintptr_t>(stackBoundAddr) + reversedSize));
}

void Mutator::ResetMutator()
{
    rawObject.object = nullptr;
    if (satbNode != nullptr) {
        SatbBuffer::Instance().RetireNode(satbNode);
        satbNode = nullptr;
    }
    if (!localFinalizers.empty()) {
        Heap::GetHeap().GetFinalizerProcessor().RegisterFinalizers(localFinalizers);
    }
    uwContext.Reset();
    exceptionWrapper.ClearInfo();
}

void Mutator::SetManagedContext(bool isManagedContext)
{
    inManagedContext.store(isManagedContext, std::memory_order_release);
}

void Mutator::HandleSuspensionRequest()
{
    for (;;) {
        SetInSaferegion(SAFE_REGION_TRUE);
        if (HasSuspensionRequest(SUSPENSION_FOR_GC_PHASE)) {
            TransitionGCPhase(true);
        } else if (HasSuspensionRequest(SUSPENSION_FOR_CPU_PROFILE)) {
            TransitionToCpuProfile(true);
        } else if (HasSuspensionRequest(SUSPENSION_FOR_SYNC)) {
            SuspendForSync();
            if (HasSuspensionRequest(SUSPENSION_FOR_GC_PHASE)) {
                TransitionGCPhase(true);
            } else if (HasSuspensionRequest(SUSPENSION_FOR_CPU_PROFILE)) {
                TransitionToCpuProfile(true);
            }
        } else if (HasPreemptRequest()) {
            SuspendForPreempt();
        } else if (HasSuspensionRequest(SUSPENSION_FOR_EXIT)) {
            while (true) {
                sleep(INT_MAX);
            }
        }
        SetInSaferegion(SAFE_REGION_FALSE);
        if (MutatorManager::Instance().SyncTriggered()) {
            // entering this branch means a second request has been broadcasted, we need to reset this flag to avoid
            // missing the request. And this must be after the behaviour that set saferegion state to false, because
            // we need to make sure that the mutator can always perceive the gc request when the mutator is not in
            // safe region.
            SetSuspensionFlag(SUSPENSION_FOR_SYNC);
        }
        // Leave saferegion if current mutator has no suspend request, otherwise try again
        if (LIKELY(!HasAnySuspensionRequest() && !HasObserver())) {
            return;
        }
    }
}

void Mutator::SuspendForSync()
{
    ClearSuspensionFlag(SUSPENSION_FOR_SYNC);
    // wait until StartTheWorld
    int curCount = static_cast<int>(MutatorManager::Instance().GetSyncFutexWordValue());
    // Avoid losing wake-ups
    if (curCount > 0) {
#if defined(_WIN64) || defined(__APPLE__)
        MutatorManager::Instance().MutatorWait();
#else
        int* countAddr = MutatorManager::Instance().GetSyncFutexWord();
        // FUTEX_WAIT may fail when gc thread wakes up all threads before the current thread reaches this position.
        // But it is not important because there won't be data race between the current thread and the gc thread,
        // and it also won't be frozen since gc thread also modifies the value at countAddr before its waking option.
        (void)Futex(countAddr, FUTEX_WAIT, curCount);
#endif
    }
}

#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
void Mutator::CreateCurrentGCInfo() { gcInfos.CreateCurrentGCInfo(); }
#endif

void Mutator::VisitStackRoots(const RootVisitor& func)
{
    MutatorLock();
    // the stack doesn't include managed frame, skip it.
    if (!IsManagedContext()) {
        MutatorUnlock();
        return;
    }
    IncObserver();
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    CreateCurrentGCInfo();
#endif
    StackManager::VisitStackRoots(uwContext, func, *this);
    VisitRawObjects(func);
    DecObserver();
    MutatorUnlock();
}

void Mutator::VisitExceptionRoots(const RootVisitor& func)
{
    func(reinterpret_cast<ObjectRef&>(exceptionWrapper.GetExceptionRef()));
}

void Mutator::VisitRawObjects(const RootVisitor& func)
{
    if (rawObject.object != nullptr) {
        func(rawObject);
    }
}

void Mutator::VisitHeapReferencesOnStack(const RootVisitor& rootVisitor, const DerivedPtrVisitor& derivedPtrVisitor)
{
    MutatorLock();
    // the stack doesn't include managed frame, skip it.
    if (!IsManagedContext()) {
        MutatorUnlock();
        return;
    }
    IncObserver();
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    CreateCurrentGCInfo();
#endif
    StackManager::VisitHeapReferencesOnStack(uwContext, rootVisitor, derivedPtrVisitor, *this);
    VisitRawObjects(rootVisitor);
    DecObserver();
    MutatorUnlock();
}

void Mutator::VisitHeapReferences(const RootVisitor& rootVisitor, const DerivedPtrVisitor& derivedPtrVisitor)
{
    VisitHeapReferencesOnStack(rootVisitor, derivedPtrVisitor);
    VisitExceptionRoots(rootVisitor);
}

Mutator* Mutator::GetMutator() noexcept
{
    Mutator* mutator = ThreadLocal::GetMutator();
    if (mutator == nullptr) {
        mutator = ConcurrencyModel::GetMutator();
    }
    return mutator;
}

void Mutator::StackGuardExpand() const
{
    // Expand stack boundary when StackOverflowError occurs
    if (!IsRuntimeThread()) {
        CJThreadStackGuardExpand();
        if (Runtime::Current().GetConcurrencyModel().GetStackGuardCheckFlag()) {
            void* topAddr = reinterpret_cast<uint8_t*>(CJThreadStackAddrGet()) - MapleRuntime::MRT_PAGE_SIZE;
#ifdef _WIN64
            DWORD oldProt = 0;
            int ret = VirtualProtect(topAddr, MapleRuntime::MRT_PAGE_SIZE, PAGE_READWRITE, &oldProt);
            if (ret == 0) {
                LOG(RTLOG_ERROR, "Enable stack protect page failed");
            }
#else
            int ret = mprotect(topAddr, MapleRuntime::MRT_PAGE_SIZE, PROT_READ | PROT_WRITE);
            if (ret != 0) {
                LOG(RTLOG_ERROR, "Enable stack protect page failed");
            }
#endif
        }
    } else {
        ThreadLocal::SetProtectAddr(static_cast<uint8_t*>(stackBoundAddr));
    }
}

void Mutator::StackGuardRecover() const
{
    // Recover stack boundary when StackOverflowError has been caught
    if (!IsRuntimeThread()) {
        CJThreadStackGuardRecover();
        if (Runtime::Current().GetConcurrencyModel().GetStackGuardCheckFlag()) {
            void* topAddr = reinterpret_cast<uint8_t*>(CJThreadStackAddrGet()) - MapleRuntime::MRT_PAGE_SIZE;
#ifdef _WIN64
            DWORD oldProt = 0;
            int ret = VirtualProtect(topAddr, MapleRuntime::MRT_PAGE_SIZE, PAGE_NOACCESS, &oldProt);
            if (ret == 0) {
                LOG(RTLOG_ERROR, "Disable stack protect page failed");
            }
#else
            int ret = mprotect(topAddr, MapleRuntime::MRT_PAGE_SIZE, PROT_NONE);
            if (ret != 0) {
                LOG(RTLOG_ERROR, "Disable stack protect page failed");
            }
#endif
        }
    } else {
        size_t reversedSize = Runtime::Current().GetConcurrencyModel().GetReservedStackSize();
        ThreadLocal::SetProtectAddr(
            reinterpret_cast<uint8_t*>(reinterpret_cast<uintptr_t>(stackBoundAddr) + reversedSize));
    }
}

void Mutator::InitStackInfo(ThreadLocalData* threadData)
{
    CJThread* cjthread = reinterpret_cast<CJThread*>(threadData->cjthread);
    SetStackTopAddr(reinterpret_cast<uintptr_t>(CJThreadStackAddrGetByCJThrd(cjthread)));
    SetStackSize(CJThreadStackSizeGetByCJThrd(cjthread));
    SetStackBaseAddr(reinterpret_cast<uintptr_t>(CJThreadStackBaseAddrGetByCJThrd(cjthread)));
}

bool Mutator::IsStackAddr(uintptr_t addr)
{
    if (addr > GetStackTopAddr() && addr < GetStackTopAddr() + GetStackSize()) {
        return true;
    } else {
        return false;
    }
}

void Mutator::RecordStackPtrs(std::set<BaseObject**>& resSet)
{
    // The pointer on the stack to be fixed has two sources:
    //     1. the non-escaped heap pointer (from heap stackmap), these pointer are assigned to the stack.
    //     2. the stack pointer (from stack stackmap).
    // The stack pointer and the pointer on the heap obtained after ref trace are placed in the <resSet> for fix.

    // The non-escaped heap pointer points to an object,
    //     so they need to be traced to ensure that all pointers are fixed.
    // These pointers will be collected in the <rootList>.
    std::stack<BaseObject**, std::deque<BaseObject**, StdContainerAllocator<BaseObject**, STACK_PTR>>> rootList;
    StackPtrVisitor traceAndFixPtrVisitor = [&rootList, this](ObjectRef& oldStackAddr) {
        if (IsStackAddr(reinterpret_cast<uintptr_t>(oldStackAddr.object))) {
            rootList.push(reinterpret_cast<BaseObject**>(&oldStackAddr));
        }
    };
    // The stack pointer does not require ref trace.
    StackPtrVisitor fixPtrVisitor = [&resSet, this](ObjectRef& oldStackAddr) {
        if (IsStackAddr(reinterpret_cast<uintptr_t>(oldStackAddr.object))) {
            resSet.insert(reinterpret_cast<BaseObject**>(&oldStackAddr));
        }
    };
    // The Derived pointer does not require ref trace.
    DerivedPtrVisitor derivedPtrVisitor =
        [&resSet, this](BasePtrType basePtr __attribute__((unused)), DerivedPtrType& derivedPtr) {
        if (IsStackAddr(reinterpret_cast<uintptr_t>(reinterpret_cast<ObjectRef&>(derivedPtr).object))) {
            resSet.insert(reinterpret_cast<BaseObject**>(&derivedPtr));
        }
    };
    StackManager::VisitStackPtrMap(uwContext, traceAndFixPtrVisitor, fixPtrVisitor, derivedPtrVisitor, *this);

    // Ref trace on non-escaped heap pointers.
    RefFieldVisitor refVisitor = [&rootList, this](RefField<>& oldRefFieldAddr) {
        // Check whether the address is on the stack.
        if (IsStackAddr(reinterpret_cast<uintptr_t>(oldRefFieldAddr.GetTargetObject()))) {
            rootList.push(reinterpret_cast<BaseObject**>(&oldRefFieldAddr));
        }
    };
    for (;;) {
        if (rootList.empty()) {
            break;
        }
        // get next object from work stack.
        BaseObject** objSlot = rootList.top();
        rootList.pop();
        resSet.insert(objSlot);
        BaseObject* obj = *objSlot;
        if (!obj->IsValidObject() || !obj->HasRefField()) {
            continue;
        } else {
            obj->ForEachRefField(refVisitor);
        }
    }
}

intptr_t Mutator::FixExtendedStack(intptr_t frameBase, uint32_t adjustedSize, void* ip)
{
    if (!IsRuntimeThread()) {
#if defined(_WIN64)
        stackGrowFrameSize = adjustedSize;
#endif
        intptr_t stackOffset;
        // When frameBase is 0, it is actively invoked in the FFI. In this case, the stack is expanded to the maximum.
        // When frameBase != 0, the stack check is invoked. In this case, the stack is expanded by two times by default.
        // Check whether the stack expansion meets the requirements.
        // Otherwise, the stack expansion continues to reach the limit.
#ifdef INTERPRETER_ENABLED
        uintptr_t currentIp = reinterpret_cast<uintptr_t>(ip);
        bool isInInterpreter = StackManager::IsInterpreterCodeAddr(currentIp);
#endif
        if (frameBase == 0) {
            stackOffset = CJThreadStackGrow(CJTHREAD_MAX_STACK_SIZE);
            if (stackOffset == 0 || stackOffset == -1) {
                return 0;
            }
#ifdef INTERPRETER_ENABLED
        } else if (isInInterpreter) {
            // The interpreter stack-grow path passes the full size that must fit below the caller
            // frame base after StackGrowStub passes execution into the prologue of interpreted method.
            DLOG(INTERPRETER, "Stack overflow happened in interpreter, stack size: %zu", stackSize);
            const uintptr_t* stubFrameBase = reinterpret_cast<const uintptr_t*>(frameBase);
            uintptr_t interpFrameBase = *stubFrameBase;

            size_t requiredSp = interpFrameBase - GetFrameSize(interpFrameBase);
            size_t newSize = stackSize + stackSize;
            while (stackBaseAddr - requiredSp > newSize - CJThreadStackReversedGet()) {
                newSize += newSize;
            }
            DLOG(INTERPRETER, "   try to grow stack size: %zu -> %zu", stackSize, newSize);
            stackOffset = CJThreadStackGrow(newSize);
            if (stackOffset == -1 || stackOffset == 0) {
                DLOG(INTERPRETER, "       stack overflow at %p", ip);
                ExceptionManager::StackOverflow(adjustedSize, ip);
                return 0;
            }
#endif // INTERPRETER_ENABLED
        } else {
            UnwindContext& stackGrowContext = Mutator::GetMutator()->GetUnwindContext();
            UnwindContext caller;
#ifdef _WIN64
            UnwindContextStatus ucs = stackGrowContext.GetUnwindContextStatus();
            stackGrowContext.frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo, ucs);
#else
            stackGrowContext.frameInfo.mFrame.UnwindToCallerMachineFrame(caller.frameInfo.mFrame);
#endif
            caller.frameInfo.ResolveProcInfo();
#ifdef __APPLE__
            FuncDescRef funcDesc = MFuncDesc::GetFuncDesc(caller.frameInfo.mFrame.GetFA());
#else
            FuncDescRef funcDesc = MFuncDesc::GetFuncDesc(reinterpret_cast<Uptr>(caller.frameInfo.GetFuncStartPC()));
#endif
            Uptr* stackMapEntry = funcDesc->GetStackMap();
            uint32_t validPos = 0;
            uint32_t frameSize = EHFrameInfo::ReadVarInt(&stackMapEntry, validPos);
#if defined(__x86_64__)
            // 8 is the slot length of returnaddr.
            uint64_t callerSp = *reinterpret_cast<intptr_t*>(frameBase) - frameSize + 8;
#elif defined(__aarch64__)
            uint64_t callerSp = *reinterpret_cast<intptr_t*>(frameBase) - frameSize;
#elif defined(__arm__)
            uint64_t callerSp = *reinterpret_cast<intptr_t*>(frameBase) - frameSize;
#endif
            size_t newSize = stackSize + stackSize;
            while (stackBaseAddr - callerSp > newSize - CJThreadStackReversedGet()) {
                newSize += newSize;
            }
            stackOffset = CJThreadStackGrow(newSize);
            if (stackOffset == -1 || stackOffset == 0) {
                ExceptionManager::StackOverflow(adjustedSize, ip);
                return 0;
            }
        }

        // Visits the stackmap and records all pointers to be fixed to the resSet.
        std::set<BaseObject**> resSet;
        RecordStackPtrs(resSet);

        // Fix All pointers recorded in resSet.
        intptr_t* newStackAddr;
        const int byteSize = 8;
        for (BaseObject** oldAddr : resSet) {
            newStackAddr = reinterpret_cast<intptr_t*>(oldAddr + stackOffset / byteSize);
            *newStackAddr += stackOffset;
        }

        uwContext.anchorFA = reinterpret_cast<uint32_t*>(reinterpret_cast<uintptr_t>(uwContext.anchorFA) + stackOffset);

        return stackOffset;
    }
    return 0;
}

inline void CheckAndPush(BaseObject* obj, std::set<BaseObject*>& rootSet, std::stack<BaseObject*>& rootStack)
{
    if (rootSet.insert(obj).second && obj->IsValidObject() && obj->HasRefField()) {
        rootStack.push(obj);
    }
}

inline void Mutator::GcPhaseEnum(GCPhase newPhase)
{
    std::set<BaseObject*> rootSet;
    std::stack<BaseObject*> rootStack;
    RefFieldVisitor refVisitor = [&rootSet, &rootStack, this](RefField<>& refFieldAddr) {
        BaseObject* obj = refFieldAddr.GetTargetObject();
        if (Heap::IsHeapAddress(obj)) {
            AllocBuffer* buffer = AllocBuffer::GetOrCreateAllocBuffer();
            buffer->PushRoot(obj);
            DLOG(ENUM, "enum stack root RefField @%p: %p", &refFieldAddr, obj);
        } else if (IsStackAddr(reinterpret_cast<uintptr_t>(obj))) {
            CheckAndPush(obj, rootSet, rootStack);
        }
    };

    RootVisitor visitor = [&rootSet, &rootStack, this, &refVisitor](ObjectRef& root) {
        BaseObject* obj = root.object;
        if (Heap::IsHeapAddress(obj)) {
            AllocBuffer* buffer = AllocBuffer::GetOrCreateAllocBuffer();
            buffer->PushRoot(obj);
            DLOG(ENUM, "enum stack root @%p: %p", &root, obj);
        } else if (IsStackAddr(reinterpret_cast<uintptr_t>(obj))) {
            CheckAndPush(obj, rootSet, rootStack);
        }
        while (!rootStack.empty()) {
            BaseObject* obj = rootStack.top();
            rootStack.pop();
            obj->ForEachRefField(refVisitor);
        }
    };
    VisitMutatorRoots(visitor);
}

inline void Mutator::ForwardLocalFinalizers(Collector& collector)
{
    WCollector& wcollector = reinterpret_cast<WCollector&>(collector);
    RootVisitor visitor = [&wcollector](ObjectRef& root) { wcollector.ForwardUpdateRawRef(root); };
    for (BaseObject*& obj : localFinalizers) {
        visitor(reinterpret_cast<ObjectRef&>(obj));
    }
}

inline void Mutator::GCPhasePreForward(GCPhase newPhase)
{
    std::set<BaseObject*> rootSet;
    std::set<void*> rootFieldSet;
    std::stack<BaseObject*> rootStack;
    Collector& collector = reinterpret_cast<Collector&>(Heap::GetHeap().GetCollector());
    RefFieldVisitor refVisitor = [&rootSet, &rootFieldSet, &rootStack, &collector, this](RefField<>& refFieldAddr) {
        BaseObject* oldObj = refFieldAddr.GetTargetObject();
        if (Heap::IsHeapAddress(oldObj) && collector.IsGhostFromObject(oldObj) &&
            !collector.IsUnmovableFromObject(oldObj)) {
            if (!rootFieldSet.insert((void*)(&refFieldAddr)).second) { return; }
            BaseObject* toObj = collector.ForwardObject(oldObj);
            if (oldObj != toObj) { refFieldAddr.SetTargetObject(toObj); }
        } else if (IsStackAddr(reinterpret_cast<uintptr_t>(oldObj))) {
            CheckAndPush(oldObj, rootSet, rootStack);
        }
    };

    RootVisitor visitor = [&rootSet, &rootFieldSet, &rootStack, &collector, this, &refVisitor](ObjectRef& root) {
        BaseObject* oldObj = root.object;
        if (Heap::IsHeapAddress(oldObj) && collector.IsGhostFromObject(oldObj) &&
            !collector.IsUnmovableFromObject(oldObj)) {
            if (!rootFieldSet.insert((void*)(&root)).second) { return; }
            BaseObject* toObj = collector.ForwardObject(oldObj);
            if (oldObj != toObj) { root.object = toObj; }
        } else if (IsStackAddr(reinterpret_cast<uintptr_t>(oldObj))) {
            CheckAndPush(oldObj, rootSet, rootStack);
        }
        while (!rootStack.empty()) {
            BaseObject* obj = rootStack.top();
            rootStack.pop();
            obj->ForEachRefField(refVisitor);
        }
    };

    DerivedPtrVisitor derivedPtrVisitor = [&collector](BasePtrType basePtr, DerivedPtrType& derivedPtr) {
        BaseObject* fromVersion = reinterpret_cast<BaseObject*>(basePtr);
        if (!Heap::IsHeapAddress(fromVersion) || !collector.IsGhostFromObject(fromVersion) ||
            collector.IsUnmovableFromObject(fromVersion)) {
            return;
        }
        BaseObject* toVersion = collector.FindLatestVersion(fromVersion);
        if (fromVersion != toVersion) {
            DerivedPtrType toDerived = reinterpret_cast<BasePtrType>(toVersion) + (derivedPtr - basePtr);
            derivedPtr = toDerived;
        }
    };
    VisitHeapReferences(visitor, derivedPtrVisitor);
    ForwardLocalFinalizers(collector);
}

inline void Mutator::HandleGCPhase(GCPhase newPhase)
{
    if (newPhase == GCPhase::GC_PHASE_FINISH || newPhase == GCPhase::GC_PHASE_FORWARD) {
        std::lock_guard<std::mutex> lg(mutatorLock);
        if (satbNode != nullptr) {
            satbNode->Clear();
        }
    } else if (newPhase == GCPhase::GC_PHASE_ENUM) {
        auto& localFins = GetLocalFinalizers();
        if (!localFins.empty()) {
            Heap::GetHeap().GetFinalizerProcessor().RegisterFinalizers(localFins);
        }
        GcPhaseEnum(newPhase);
    } else if (newPhase == GCPhase::GC_PHASE_PREFORWARD) {
        GCPhasePreForward(newPhase);
    } else if (newPhase == GCPhase::GC_PHASE_CLEAR_SATB_BUFFER || newPhase == GCPhase::GC_PHASE_RECLAIM_SATB_NODE) {
        std::lock_guard<std::mutex> lg(mutatorLock);
        if (satbNode != nullptr) {
            SatbBuffer::Instance().RetireNode(satbNode);
            satbNode = nullptr;
        }
    } else if (newPhase == GCPhase::GC_PHASE_IDLE) {
        HandleGCPhaseIDLE();
    }
}

inline void Mutator::HandleGCPhaseIDLE()
{
    if (IsForeignThreadExit()) {
        ReleaseForeignThread();
    } else {
#if defined(__OHOS__) && (__OHOS__ == 1)
        if (foreignThreadInfo.allocBuffer != nullptr) {
            auto status = GetUnwindContext().GetUnwindContextStatus();
            if (status == UnwindContextStatus::RISKY) {
                foreignThreadInfo.allocBuffer->FlushRegion();
            }
        }
#endif
    }
}

void Mutator::TransitionToGCPhaseExclusive(GCPhase newPhase)
{
    HandleGCPhase(newPhase);
    SetSafepointActive(false);
    // Clear mutator's suspend request after phase transition
    ClearSuspensionFlag(SUSPENSION_FOR_GC_PHASE);
    mutatorPhase.store(newPhase, std::memory_order_release); // handshake between mutator & mainGC thread
}

inline void Mutator::HandleCpuProfile()
{
    MutatorLock();
    // the stack doesn't include managed frame, skip it.
    if (!IsManagedContext()) {
        MutatorUnlock();
        return;
    }
    IncObserver();
    StackManager::PrintStackTraceForCpuProfile(&(GetUnwindContext()), GetCJThreadId());
    DecObserver();
    MutatorUnlock();
}

void Mutator::TransitionToCpuProfileExclusive()
{
    HandleCpuProfile();
    SetSafepointActive(false);
    ClearSuspensionFlag(SUSPENSION_FOR_CPU_PROFILE);
}

void Mutator::ReleaseForeignThread()
{
    AllocBuffer* buffer = foreignThreadInfo.allocBuffer;
    foreignThreadInfo.allocBuffer = nullptr;
    if (buffer != nullptr) {
        buffer->Fini();
        delete buffer;
    }
    // We can remove foreign thread c-heap resource here.
}
} // namespace MapleRuntime
