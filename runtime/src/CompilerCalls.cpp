// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "CompilerCalls.h"

#include "Base/CString.h"
#include "Base/Log.h"
#include "Base/LogFile.h"
#include "Common/BaseObject.h"
#include "ObjectModel/FieldInfo.h"

// module interfaces
#include "ObjectManager.inline.h"
#include "ObjectModel/MethodInfo.h"
#if defined(CANGJIE_SANITIZER_SUPPORT) || defined(CANGJIE_GWPASAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#if defined(CANGJIE_SANITIZER_SUPPORT)
#include "timer.h"
#endif
#if defined(__linux__) || defined(hongmeng) || defined(__APPLE__)
#include "SignalManager.h"
#endif
#include "Common/ScopedObjectAccess.h"
#include "ExceptionManager.inline.h"
#include "Heap/Barrier/Barrier.h"
#include "Heap/Collector/CollectorResources.h"
#include "Heap/Heap.h"
#include "HeapManager.inline.h"
#include "LoaderManager.h"
#include "TypeInfoManager.h"
#include "ObjectModel/Field.inline.h"
#include "ObjectModel/RefField.inline.h"
#ifdef _WIN64
#include "Mutator/MutatorManager.h"
#include "Mutator/ThreadLocal.h"
#endif
#include "Sync/Sync.h"
#include "UnwindStack/GcStackInfo.h"
#include "CpuProfiler/CpuProfiler.h"
#ifdef __OHOS__
#include "schedule.h"
#include "Base/SpinLock.h"
#include <dlfcn.h>
#endif

namespace MapleRuntime {

static bool IsGlobalStruct(const ObjectPtr basePtr, MAddress field)
{
#if defined(__aarch64__) && !defined(__ANDROID__)
    // On aarch64, flag of the global variable is recorded on the highest bit of "field".
    // This has no impact on the consistency of versions.
    constexpr uintptr_t globalFlag = 1ULL << 63;
    return (static_cast<uintptr_t>(field) & globalFlag) != 0;
#else
    // On other platforms, base pointer of the field with value "1" means it's a global struct.
    constexpr uintptr_t globalFlag = 0x1;
    return (reinterpret_cast<uintptr_t>(basePtr) & globalFlag) != 0;
#endif
}
#if defined(CANGJIE_SANITIZER_SUPPORT)
// These interfaces are used to detect whether the acquireArrayRawData is released in time.
class PinnedArrayRecorder {
public:
    PinnedArrayRecorder() = default;
    size_t RegisterBtInfo(void* rawPtr, Mutator* mutator, const std::vector<uint64_t>& stackInfo)
    {
        std::lock_guard<std::mutex> lg(safeMutex);
        auto it = stackInfos.find(rawPtr);
        if (it == stackInfos.end()) {
            std::unordered_map<Mutator*, std::vector<std::vector<uint64_t>>> mutatorStackMap {
                { mutator, std::vector<std::vector<uint64_t>>({ stackInfo }) }
            };
            stackInfos.emplace(rawPtr, mutatorStackMap);
            return 0;
        } else {
            auto& mutatorStackMap = it->second;
            auto mutatorIt = mutatorStackMap.find(mutator);
            if (mutatorIt == mutatorStackMap.end()) {
                mutatorStackMap.insert({ mutator, std::vector<std::vector<uint64_t>>({ stackInfo }) });
                return 0;
            } else {
                auto& vec = mutatorIt->second;
                size_t pos = vec.size();
                vec.push_back(stackInfo);
                return pos;
            }
        }
    }

    void RemoveBtInfo(void* rawPtr, Mutator* mutator, const std::vector<uint64_t>& stackInfo)
    {
        std::lock_guard<std::mutex> lg(safeMutex);
        auto it = stackInfos.find(rawPtr);
        if (it == stackInfos.end()) {
            std::vector<StackTraceElement> stackTraces;
            StackManager::GetStackTraceByLiteFrameInfos(stackInfo, stackTraces);
            LOG(RTLOG_ERROR, "Call too many releaseArrayRawData");
            for (const auto& ste : stackTraces) {
                LOG(RTLOG_ERROR, "\t at %s%s%s(%s:%ld)", ste.className.Str(),
                    ste.className.Length() > 0 ? "." : "", ste.methodName.Str(), ste.fileName.Str(),
                    ste.lineNumber);
            }
            return;
        }
        auto& mutatorStackMap = it->second;
        auto mutatorIt = mutatorStackMap.find(mutator);
        if (mutatorIt == mutatorStackMap.end()) {
            std::vector<StackTraceElement> stackTraces;
            StackManager::GetStackTraceByLiteFrameInfos(stackInfo, stackTraces);
            LOG(RTLOG_ERROR, "Call too many releaseArrayRawData");
            for (const auto& ste : stackTraces) {
                LOG(RTLOG_ERROR, "\t at %s%s%s(%s:%ld)", ste.className.Str(),
                    ste.className.Length() > 0 ? "." : "", ste.methodName.Str(), ste.fileName.Str(),
                    ste.lineNumber);
            }
            return;
        }
        auto& vec = mutatorIt->second;
        vec.pop_back();
        if (vec.empty()) {
            mutatorStackMap.erase(mutatorIt);
        }
    }

    bool CheckStackInfo(void* rawPtr, Mutator* mutator, size_t pos, std::vector<StackTraceElement>& stackTraces)
    {
        std::lock_guard<std::mutex> lg(safeMutex);
        auto rawPtrIt = stackInfos.find(rawPtr);
        if (rawPtrIt == stackInfos.end()) {
            return true;
        }
        auto& mutatorStackMap = rawPtrIt->second;
        auto mutatorIt = mutatorStackMap.find(mutator);
        if (mutatorIt == mutatorStackMap.end()) {
            return true;
        }
        auto& vec = mutatorIt->second;
        if (pos >= vec.size()) {
            return true;
        }
        std::vector<uint64_t>& frames = vec[pos];
        StackManager::GetStackTraceByLiteFrameInfos(frames, stackTraces);
        return false;
    }
private:
    std::mutex safeMutex;
    std::unordered_map<void*, std::unordered_map<Mutator*, std::vector<std::vector<uint64_t>>>> stackInfos;
};

PinnedArrayRecorder pinnedArrayRecorder;

struct DataClosure {
    void* rawPtr = nullptr;
    Mutator* mutator = nullptr;
    size_t pos = 0;
};

void RawPtrCheckerTimerEntry(void* arg)
{
    DataClosure* dataClosure = reinterpret_cast<DataClosure*>(arg);
    void* rawPtr = dataClosure->rawPtr;
    Mutator* mutator = dataClosure->mutator;
    size_t pos = dataClosure->pos;
    NativeAllocator::NativeFree(dataClosure, sizeof(DataClosure));
    std::vector<StackTraceElement> stackTraces;
    if (!pinnedArrayRecorder.CheckStackInfo(rawPtr, mutator, pos, stackTraces)) {
        LOG(RTLOG_ERROR, "acquireArrayRawData lasted too long");
        for (const auto& ste : stackTraces) {
            LOG(RTLOG_ERROR, "\t at %s%s%s(%s:%ld) misses releaseArrayRawData", ste.className.Str(),
                ste.className.Length() > 0 ?
                "." : "", ste.methodName.Str(), ste.fileName.Str(), ste.lineNumber);
        }
    }
}
#endif
// runtime interfaces provided to compiler for code generation.
// The compiler should only call MCC_* to access runtime functions.
// MCC_* calls follows C standard calling convention.

extern "C" ObjRef MCC_NewObject(const TypeInfo* klass, MSize size)
{
    DCHECK(size == (AlignUp<size_t>(klass->GetInstanceSize(), 8) + TYPEINFO_PTR_SIZE)); // 8-byte alignment
    ObjRef obj = ObjectManager::NewObject(klass, size);
    if (obj == nullptr) {
        VLOG(REPORT, "Allocating object %s (%zu B) failed and throw OutOfMemoryError", klass->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObject return nullptr");
    }
    return obj;
}

extern "C" ObjRef MCC_NewWeakRefObject(const TypeInfo* klass, MSize size)
{
    DCHECK(size == (AlignUp<size_t>(klass->GetInstanceSize(), 8) + TYPEINFO_PTR_SIZE)); // 8-byte alignment
    ObjRef obj = ObjectManager::NewWeakRefObject(klass, size);
    if (obj == nullptr) {
        VLOG(REPORT, "Allocating weak reference %s (%zu B) failed and throw OutOfMemoryError", klass->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewWeakRefObject return nullptr");
    }
    return obj;
}

extern "C" ObjRef MCC_NewPinnedObject(const TypeInfo* klass, MSize size, bool isFinalizer)
{
    DCHECK(size == (AlignUp<size_t>(klass->GetInstanceSize(), 8) + TYPEINFO_PTR_SIZE)); // 8-byte alignment
    ObjRef obj = ObjectManager::NewPinnedObject(klass, size, isFinalizer);
    if (obj == nullptr) {
        VLOG(REPORT, "Allocating object %s (%zu B) failed and throw OutOfMemoryError", klass->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewPinnedObject return nullptr");
    }
    return obj;
}

extern "C" ObjRef MCC_NewFinalizer(const TypeInfo* klass, MSize size)
{
    DCHECK(size == (AlignUp<size_t>(klass->GetInstanceSize(), 8) + TYPEINFO_PTR_SIZE)); // 8-byte alignment
    ObjRef obj = ObjectManager::NewFinalizer(klass, size);
    if (obj == nullptr) {
        VLOG(REPORT, "Allocating object with ~init %s (%zu B) failed and throw OutOfMemoryError",
            klass->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewFinalizer return nullptr");
    }
    return obj;
}

extern "C" ObjRef MCC_OnFinalizerCreated(ObjRef ref)
{
    ref->OnFinalizerCreated();
    return ref;
}
extern "C" ArrayRef MCC_NewArray(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewArray(static_cast<MIndex>(nElems), arrayInfo);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewArray return nullptr");
    }
    return array;
}

extern "C" ArrayRef MCC_NewObjArray(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewObjArray(nElems, arrayInfo);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObjArray return nullptr");
    }
    return array;
}

extern "C" ArrayRef MCC_NewArray8(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_8B);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray return nullptr");
    }
    return array;
}

extern "C" ArrayRef MCC_NewArray16(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_16B);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray(16B) return nullptr");
    }
    return array;
}

extern "C" ArrayRef MCC_NewArray32(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_32B);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray(32B) return nullptr");
    }
    return array;
}

extern "C" ArrayRef MCC_NewArray64(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_64B);
    if (array == nullptr) {
        VLOG(REPORT, "Allocating array %s length %zu failed and throw OutOfMemoryError", arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray(64B) return nullptr");
    }
    return array;
}

extern "C" void MCC_WriteRefField(const ObjectPtr ref, const ObjectPtr obj, RefField<false>* field)
{
    if (IsGlobalStruct(obj, reinterpret_cast<MAddress>(field))) {
        VLOG(REPORT, "found and writing a global struct ref field");
        Heap::GetBarrier().WriteStaticRef(*field, ref);
        return;
    }
    if (!Heap::IsHeapAddress(obj)) {
        field->SetTargetObject(ref);
        return;
    }
    Heap::GetBarrier().WriteReference(obj, *field, ref);
}

extern "C" void MCC_WriteStructField(ObjectPtr obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen,
                                     GCTib gctib)
{
    CHECK_DETAIL((dst != 0u && src != 0u), "MCC_WriteStructField wrong parameter, dst: %p src: %p", dst, src);
    if (IsGlobalStruct(obj, dst)) {
        Heap::GetBarrier().WriteStaticStruct(dst, dstLen, src, srcLen, gctib);
        return;
    }
    if (UNLIKELY(!Heap::IsHeapAddress(obj))) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(dst), dstLen, reinterpret_cast<void*>(src), srcLen) == EOK,
                     "memcpy_s failed");
        return;
    }
    Heap::GetBarrier().WriteStruct(obj, dst, dstLen, src, srcLen);
}

extern "C" void MCC_WriteStaticRef(const ObjectPtr ref, RefField<false>* field)
{
    Heap::GetBarrier().WriteStaticRef(*field, ref);
}

extern "C" void MCC_WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, const GCTib gcTib)
{
    CHECK_DETAIL((dst != 0u && src != 0u), "MCC_WriteStaticStruct wrong parameter, dst: %p src: %p", dst, src);
    Heap::GetBarrier().WriteStaticStruct(dst, dstLen, src, srcLen, gcTib);
}

extern "C" TypeInfo* MCC_GetObjClass(const ObjectPtr obj)
{
    // it may be better by installing load barrier.
    return obj->GetTypeInfo();
}

extern "C" TypeInfo* MCC_GetTypeForAny(const ObjectPtr obj) { return obj->GetTypeInfo(); }

extern "C" bool MCC_IsWrapperClassForAutoEnv(const TypeInfo* ti)
{
    const char* tiName = ti->GetName();
    const char* targetPattern = ":$Cw$";
    const char *p = strchr(tiName, ':');
    if (p == nullptr) {
        return false;
    } else if (strncmp(p, targetPattern, strlen(targetPattern)) == 0) {
        return true;
    } else {
        return false;
    }
}

extern "C" void CJ_MCC_ArrayCopyRef(const ObjectPtr dstObj, MAddress dstField, size_t dstSize, const ObjectPtr srcObj,
                                    MAddress srcField, size_t srcSize)
{
    if (dstSize == 0) {
        return;
    }
    MRT_ASSERT(dstSize <= SECUREC_MEM_MAX_LEN, "size too big in CJ_MCC_ArrayCopy");
    Heap::GetBarrier().CopyRefArray(dstObj, dstField, dstSize, srcObj, srcField, srcSize);
}

extern "C" void CJ_MCC_ArrayCopyStruct(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                       const ObjectPtr srcObj, MAddress srcField, size_t srcSize)
{
    if (dstSize == 0) {
        return;
    }
    MRT_ASSERT(dstSize <= SECUREC_MEM_MAX_LEN, "size too big in CJ_MCC_ArrayCopy");
    Heap::GetBarrier().CopyStructArray(dstObj, dstField, dstSize, srcObj, srcField, srcSize);
}
extern "C" void MCC_AtomicWriteReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                         MemoryOrder order)
{
    Heap::GetBarrier().AtomicWriteReference(obj, *field, ref, order);
}

extern "C" ObjectPtr MCC_AtomicReadReference(const ObjectPtr obj, RefField<true>* field, MemoryOrder order)
{
    return Heap::GetBarrier().AtomicReadReference(obj, *field, order);
}

extern "C" ObjectPtr MCC_AtomicSwapReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                             MemoryOrder order)
{
    return Heap::GetBarrier().AtomicSwapReference(obj, *field, ref, order);
}

extern "C" bool MCC_AtomicCompareSwapReference(const ObjectPtr oldRef, const ObjectPtr newRef, const ObjectPtr obj,
                                               RefField<true>* field, MemoryOrder succOrder, MemoryOrder failOrder)
{
    return Heap::GetBarrier().CompareAndSwapReference(obj, *field, oldRef, newRef, succOrder, failOrder);
}

extern "C" void MCC_InvokeGCImpl(bool sync) { HeapManager::RequestGC(GC_REASON_USER, !sync); }

extern "C" ssize_t MCC_GetRealHeapSize() { return Heap::GetHeap().GetHeapPhysicalMemorySize(); }

extern "C" size_t MCC_GetAllocatedHeapSize() { return Heap::GetHeap().GetAllocatedSize(); }

extern "C" size_t MCC_GetMaxHeapSize() { return Heap::GetHeap().GetMaxCapacity(); }

extern "C" bool MCC_IsGCRunning() { return Heap::GetHeap().IsGcStarted(); }

extern "C" bool MCC_DumpCJHeapData(int fd)
{
    ScopedEnterSaferegion enterSaferegion(false);
    CjHeapData* cjHeapData = new CjHeapData();
    CHECK_DETAIL(cjHeapData != nullptr, "new cjHeapData fail");
    bool result = cjHeapData->DumpHeap(fd);
    delete cjHeapData;
    return result;
}

extern "C" size_t MCC_GetCJThreadNumber() { return ScheduleCJThreadCountPublic(CJTHREAD_PSTATE_ALL); }

extern "C" size_t MCC_GetBlockingCJThreadNumber() { return ScheduleCJThreadCountPublic(CJTHREAD_PSTATE_BLOCKING); }

extern "C" size_t MCC_GetNativeThreadNumber() { return ScheduleRunningOSThreadCount(); }

extern "C" size_t MCC_GetGCCount() { return g_gcCount; }

extern "C" uint64_t MCC_GetGCTimeUs() { return g_gcTotalTimeUs; }

extern "C" size_t MCC_GetGCFreedSize() { return g_gcCollectedTotalBytes; }

extern "C" bool MCC_StartCpuProfiling()
{
    return CpuProfiler::GetInstance().StartCpuProfilerForFile();
}

extern "C" bool MCC_StopCpuProfiling(int fd)
{
    return CpuProfiler::GetInstance().StopCpuProfilerForFile(fd);
}

extern "C" void MCC_SetGCThreshold(uint64_t GCThreshold) { Runtime::Current().SetGCThreshold(GCThreshold); }

extern "C" void* MCC_PostThrowException(ExceptionWrapper* mExceptionWrapper)
{
    return ExceptionManager::BeginCatch(mExceptionWrapper);
}

extern "C" void MCC_ThrowException(ExceptionRef exception) { ExceptionManager::ThrowException(exception); }

extern "C" void MCC_RegisterImplicitExceptionRaisers(void* raiser)
{
    ExceptionManager& exceptionManager = Runtime::Current().GetExceptionManager();
    exceptionManager.RegisterExceptionRaiser(raiser);
}

extern "C" void* MCC_GetExceptionWrapper() { return ExceptionManager::GetExceptionWrapper(); }

extern "C" uint32_t MCC_GetExceptionTypeID() { return ExceptionManager::GetExceptionTypeID(); }

extern "C" void MCC_EndCatch(){};

extern "C" MRT_OPTIONAL_DISABLE_TAIL_CALL void MCC_ThrowStackOverflowError(uint32_t size = 0)
{
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    // get the caller return address since there is an asm stub when cfi is enabled.
    void* fp = __builtin_frame_address(0);
    void *ip = *(*reinterpret_cast<void***>(fp) + 1);
#else
    void* ip = __builtin_return_address(0);
#endif
    ExceptionManager::StackOverflow(size, ip);
}

#ifndef _WIN64
extern "C" sighandler_t CJ_MCC_SignalRegister(int sig, sighandler_t handler)
{
    return signal(sig, handler);
}
extern "C" int CJ_MCC_SignalProcMask(int how, const sigset_t* newSet, sigset_t* oldSet)
{
    return sigprocmask(how, newSet, oldSet);
}
extern "C" void CJ_MCC_SignalKill(pid_t pid, int sig)
{
    kill(pid, sig);
}
extern "C" void CJ_MCC_SignalRaise(int sig)
{
    std::raise(sig);
}
extern "C" void CJ_MCC_AddSignalHandler(int signal, struct SignalAction* sa)
{
    if (signal == SIGABRT || signal == SIGILL) {
        SignalStack::GetStacks()[signal].SetUserSigHandler(true);
    }
    // By default, block the SIGPIPE signal, and take no action on the SIGPIPE signal;
    // when the user registers a handler, unblock the SIGPIPE signal,
    // allowing the user to take action on the SIGPIPE signal.
    if (signal == SIGPIPE) {
        sigset_t set;
        CHECK_SIGNAL_CALL(sigemptyset, (&set), "sigemptyset failed in AddHandlerToSignalStack");
        CHECK_SIGNAL_CALL(sigaddset, (&set, SIGPIPE), "sigaddset failed in AddHandlerToSignalStack");
        CHECK_SIGNAL_CALL(pthread_sigmask, (SIG_UNBLOCK, &set, nullptr),
                          "pthread_sigmask failed in AddHandlerToSignalStack");
    }

    AddHandlerToSignalStack(signal, sa);
}
extern "C" void CJ_MCC_RemoveSignalHandler(int signal, bool (*fn)(int, siginfo_t*, void*))
{
    RemoveHandlerFromSignalStack(signal, fn);
}
#endif // _WIN64

extern "C" ArrayRef MCC_FillInStackTraceImpl(const TypeInfo* arrayInfo, const ArrayRef excepMsg)
{
    ExceptionWrapper& eWrapper = Mutator::GetMutator()->GetExceptionWrapper();
    MIndex msgLength = excepMsg->GetLength();
    if (msgLength != 0) {
        eWrapper.SetExceptionMessage(reinterpret_cast<const char*>(excepMsg->ConvertToCArray()), msgLength);
    }
    std::vector<uint64_t>& liteFrameInfos = eWrapper.GetLiteFrameInfos();
    liteFrameInfos.clear();
    StackManager::RecordLiteFrameInfos(liteFrameInfos);
#if defined(__OHOS__) && (__OHOS__ == 1)
    auto callback = ExceptionManager::GetExceptionCallback();
    if (callback != nullptr) {
        callback();
    }
#endif
    constexpr int frameInfoPairLen = 3; // function PC and startpc form one pair in liteFrameInfos
    if (eWrapper.IsThrowingSOFE()) {
        constexpr int defaultSize = 32;
        // Frames from std::core and to be filtered out, 2 in total
        //     std$core::StackOverflowError::<init>() ()
        //     rt$ThrowStackOverflowError$real ()
        constexpr int coreOrFiltFuncSize = 2 * frameInfoPairLen;
        // 2 frames need to be filtered at top
        //     user[main]
        //     cj_entry$
        constexpr int topFiltFrameSize = 2 * frameInfoPairLen;
        auto env = std::getenv("CJ_SOF_SIZE");
        CString s(env);
        int64_t sofSize = CString::ParseNumFromEnv(s.Str());
        if (s.Str() == nullptr || (sofSize == 0 && s != "0")) {
            sofSize = defaultSize;
        }
        sofSize *= frameInfoPairLen;
        // When a stack is folded, an additional element is added behind liteFrameInfos to record the folding.
        // At this time, the size of liteFrameInfos is changed to 3n+1.
        if (sofSize > 0 &&
            liteFrameInfos.size() > static_cast<size_t>(sofSize + coreOrFiltFuncSize + topFiltFrameSize)) {
            liteFrameInfos.erase(liteFrameInfos.begin() + sofSize + coreOrFiltFuncSize, liteFrameInfos.end());
            liteFrameInfos.push_back(static_cast<uint64_t>(SofStackFlag::BOTTOM_FOLDED));
        } else if (sofSize < 0 &&
                   liteFrameInfos.size() > static_cast<size_t>(coreOrFiltFuncSize + topFiltFrameSize - sofSize)) {
            sofSize -= topFiltFrameSize;
            liteFrameInfos.erase(liteFrameInfos.begin(), liteFrameInfos.end() + sofSize);
            liteFrameInfos.push_back(static_cast<uint64_t>(SofStackFlag::TOP_FOLDED));
        }
    }
    MIndex size = liteFrameInfos.size();
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    if (UNLIKELY(ENABLE_LOG(EXCEPTION))) {
        MIndex arraySize = size;
        if (arraySize % frameInfoPairLen == 1) {
            --arraySize;
        }
        DLOG(EXCEPTION, "fill in stack info");
        DLOG(EXCEPTION, "layer\tframePC\t\tframeFuncStart\tsize : %zu", (arraySize / frameInfoPairLen));
        for (int i = 0; i < arraySize; ++i) {
            uint64_t framePC = liteFrameInfos[i];
            uint64_t frameFuncStart = liteFrameInfos[++i];
            DLOG(EXCEPTION, "#%x\t0x%x\t0x%x", ((i - 1) / frameInfoPairLen), framePC, frameFuncStart);
        }
    }
#endif

    // framePCs contains the following five Cangjie method pcs in sequence.
    // #0 core::Throwable::init()
    // #1 core::Exception::init()
    // #2 default::Func()
    // #3 user.main()
    // #4 cj_entry()
    // In the call stack visible to the user, #0 #1 #4 should be removed.
    ArrayRef array =
        ObjectManager::NewKnownWidthArray(size, arrayInfo, ObjectManager::ObjectManager::ArrayElemBits::ELEM_64B);
    if (array == nullptr) {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
        DLOG(EXCEPTION, "BuildEHFrameInfo");
#endif
        VLOG(REPORT, "Fill in stack trace %s length %zu failed and throw OutOfMemoryError",
            arrayInfo->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray return nullptr");
        return nullptr;
    }
    for (MIndex i = 0; i < size; ++i) {
        array->SetPrimitiveElement(i, static_cast<int64_t>(liteFrameInfos[i]));
    }
    return array;
}

extern "C" StackTraceData MCC_DecodeStackTraceImpl(const uint64_t ip, const uint64_t pc, const uint64_t funcDesc,
                                                   const TypeInfo* charArray)
{
    StackTraceElement stackTrace;
    {
        ScopedEnterSaferegion checkpoint(true);
        StackManager::GetStackTraceByLiteFrameInfo(ip, pc, funcDesc, stackTrace);
    }
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    DLOG(EXCEPTION, "get stack frame info");
    DLOG(EXCEPTION, "   framePc:0x%lx\t frameFuncStart:0x%lx", ip, pc);
    DLOG(EXCEPTION, "get stack frame metainfo");
    DLOG(EXCEPTION, "   ClassName  \t : \t%s", stackTrace.className.Str());
    DLOG(EXCEPTION, "   MethodName  \t : \t%s", stackTrace.methodName.Str());
    DLOG(EXCEPTION, "   FileName  \t : \t%s", stackTrace.fileName.Str());
    DLOG(EXCEPTION, "   LineNumber  \t : \t%lu", stackTrace.lineNumber);
#endif
    StackTraceData std;
    std.className = ObjectManager::NewKnownWidthArray(
        stackTrace.className.Length(), charArray, ObjectManager::ArrayElemBits::ELEM_8B, AllocType::RAW_POINTER_OBJECT);
    if (std.className != nullptr) {
        for (MIndex i = 0; i < stackTrace.className.Length(); ++i) {
            std.className->SetPrimitiveElement(i, static_cast<int8_t>(stackTrace.className[i]));
        }
    } else {
        VLOG(REPORT, "Decoding stack trace class name %s length %zu failed and throw OutOfMemoryError",
            charArray->GetName(), stackTrace.className.Length());
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray return nullptr");
    }

    std.fileName = ObjectManager::NewKnownWidthArray(
        stackTrace.fileName.Length(), charArray, ObjectManager::ArrayElemBits::ELEM_8B, AllocType::RAW_POINTER_OBJECT);
    if (std.fileName != nullptr) {
        for (MIndex i = 0; i < stackTrace.fileName.Length(); ++i) {
            std.fileName->SetPrimitiveElement(i, static_cast<int8_t>(stackTrace.fileName[i]));
        }
    } else {
        VLOG(REPORT, "Decoding stack trace file name %s length %zu failed and throw OutOfMemoryError",
            charArray->GetName(), stackTrace.fileName.Length());
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray return nullptr");
    }

    std.methodName =
        ObjectManager::NewKnownWidthArray(stackTrace.methodName.Length(), charArray,
                                          ObjectManager::ArrayElemBits::ELEM_8B, AllocType::RAW_POINTER_OBJECT);
    if (std.methodName != nullptr) {
        for (MIndex i = 0; i < stackTrace.methodName.Length(); ++i) {
            std.methodName->SetPrimitiveElement(i, static_cast<int8_t>(stackTrace.methodName[i]));
        }
    } else {
        VLOG(REPORT, "Decoding stack trace method name %s length %zu failed and throw OutOfMemoryError",
            charArray->GetName(), stackTrace.methodName.Length());
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewKnownWidthArray return nullptr");
    }

    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    std.lineNumber = stackTrace.lineNumber;
    return std;
}

// Warning: Caller MUST call `CommitRawPointerRegions` to make sure that
// the new object will be correctly tracked by gc.
static ArrayRef CreateCharArrayFromCString(const TypeInfo* charArray, CString name)
{
    ArrayRef array = ObjectManager::NewKnownWidthArray(
        name.Length(), charArray, ObjectManager::ArrayElemBits::ELEM_8B, AllocType::RAW_POINTER_OBJECT);
    if (array == nullptr) {
        ExceptionManager::CheckAndThrowPendingException("CreateCharArrayFromCString: nullptr array");
    }
    for (MIndex i = 0; i < name.Length(); ++i) {
        array->SetPrimitiveElement(i, static_cast<int8_t>(name[i]));
    }
    return array;
}

// Warning: Caller MUST call `CommitRawPointerRegions` to make sure that
// the new object will be correctly tracked by gc.
static ArrayRef CreateStackTrace(const TypeInfo* arrayStackTrace, const TypeInfo* charArray,
                                 const std::vector<FrameInfo*> &srcSracks)
{
    // fix size after discard native frame
    MSize size = 0;
    for (auto frame : srcSracks) {
        // skip native frame
        if (frame->GetFrameType() == FrameType::NATIVE) {
            continue;
        }
        size++;
    }

    ArrayRef trace = ObjectManager::NewArray(size, arrayStackTrace, AllocType::RAW_POINTER_OBJECT);
    if (trace == nullptr) {
        ExceptionManager::CheckAndThrowPendingException("CreateStackTrace: nullptr array");
    }
    int stackIndex = 0;
    for (auto frame : srcSracks) {
        // skip native frame
        if (frame->GetFrameType() == FrameType::NATIVE) {
            continue;
        }

        CString className = frame->GetPackClassName();
        CString fileName = frame->GetFileNameForTrace();
        CString methodName = frame->GetMethodName();
        uint32_t lineNumber = frame->GetLineNum();

        StackTraceData frameData;
        // fill frame
        frameData.className = CreateCharArrayFromCString(charArray, className);
        frameData.fileName = CreateCharArrayFromCString(charArray, fileName);
        frameData.methodName = CreateCharArrayFromCString(charArray, methodName);
        frameData.lineNumber = lineNumber;

        // push frame to stack array
        MSize elementSize = trace->GetElementSize();
        MAddress dstAddr = reinterpret_cast<Uptr>(trace) + MArray::GetContentOffset() + elementSize * stackIndex;
        Heap::GetBarrier().WriteStruct(trace, dstAddr, elementSize,
                                       reinterpret_cast<MAddress>(&frameData), elementSize);
        stackIndex++;
    }
    return trace;
}

static ArrayRef GetAllThreadSnapshot(const TypeInfo* arraySnapshot, const TypeInfo* arrayStackTrace,
                                     const TypeInfo* charArray)
{
    std::vector<std::unique_ptr<RecordStackInfo>> records;
    MutatorManager::Instance().VisitAllMutatorsExceptFinalizer([&records](Mutator &mutator) {
        if (!mutator.IsVaildCJThread()) {
            return;
        }
        int state = mutator.GetCJThreadState();
        if (state == 0) {  // 0: IDLE
            return;
        }

        // 4: syscall which we treat as 2:running
        state = state == 4 ? 2 : state;
        uint32_t threadId = static_cast<uint32_t>(mutator.GetCJThreadId());
        CString threadName;
        if (mutator.GetCJThreadName() != nullptr) {
            threadName = CString(mutator.GetCJThreadName());
        }

        auto record = std::make_unique<RecordStackInfo>(
            RecordStackInfo(&(mutator.GetUnwindContext()), threadId, threadName, state));
        record->FillInStackTrace();
        records.emplace_back(std::move(record));
    });

    ArrayRef allRecords = ObjectManager::NewArray(records.size(), arraySnapshot, AllocType::RAW_POINTER_OBJECT);
    if (allRecords == nullptr) {
        ExceptionManager::CheckAndThrowPendingException("GetAllThreadSnapshot: nullptr array");
    }
    int recordIndex = 0;
    for (const auto &record : records) {
        ThreadSnapshot snapshot;
        // fill thread snapshot
        snapshot.name = CreateCharArrayFromCString(charArray, record->GetThreadName());
        snapshot.id = record->GetStackTid();
        snapshot.stackTrace = CreateStackTrace(arrayStackTrace, charArray, record->stacks);
        snapshot.state = record->GetThreadState();

        // push snapshot to record array
        MSize elementSize = allRecords->GetElementSize();
        MAddress dstAddr =
            reinterpret_cast<Uptr>(allRecords) + MArray::GetContentOffset() + elementSize * recordIndex;
        Heap::GetBarrier().WriteStruct(allRecords, dstAddr, elementSize,
                                       reinterpret_cast<MAddress>(&snapshot), elementSize);
        recordIndex++;
    }

    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    return allRecords;
}

extern "C" ArrayRef MCC_GetAllThreadSnapshotImpl(const TypeInfo* arraySnapshot, const TypeInfo* arrayStackTrace,
                                                 const TypeInfo* charArray)
{
    ScopedEnterSaferegion enterSaferegion(false);
    ArrayRef allRecords = nullptr;
    if (MutatorManager::Instance().WorldStopped()) {
        allRecords = GetAllThreadSnapshot(arraySnapshot, arrayStackTrace, charArray);
    } else {
        ScopedStopTheWorld stw("dump all thread");
        allRecords = GetAllThreadSnapshot(arraySnapshot, arrayStackTrace, charArray);
    }
    return allRecords;
}

extern "C" ThreadSnapshot MCC_GetCurrentThreadSnapshotImpl(const TypeInfo* arrayStackTrace, const TypeInfo* charArray)
{
    Mutator* mutator = Mutator::GetMutator();
    CHECK_DETAIL(mutator != nullptr, "Can not get mutator");
    CHECK_DETAIL(mutator->IsVaildCJThread(), "Get invalid mutator");
    if (mutator->GetTid() == Heap::GetHeap().GetFinalizerProcessor().GetTid()) {
        LOG(RTLOG_WARNING, "Current thread is an internal finalizer thread, not a user thread. "
                           "Thread snapshot output may be difficult to interpret.");
    }
    mutator->EnterSaferegion(true);

    uint32_t threadId = static_cast<uint32_t>(mutator->GetCJThreadId());
    CString threadName;
    if (mutator->GetCJThreadName() != nullptr) {
        threadName = CString(mutator->GetCJThreadName());
    }
    int state = mutator->GetCJThreadState();
    CHECK_DETAIL(state != 0, "Get invalid thread state idle");
    // 4: syscall which we treat as 2:running
    state = state == 4 ? 2 : state;

    RecordStackInfo record(&(mutator->GetUnwindContext()), threadId, threadName, state);
    record.FillInStackTrace();

    ThreadSnapshot snapshot;
    // fill thread snapshot
    snapshot.name = CreateCharArrayFromCString(charArray, record.GetThreadName());
    snapshot.id = record.GetStackTid();
    snapshot.stackTrace = CreateStackTrace(arrayStackTrace, charArray, record.stacks);
    snapshot.state = record.GetThreadState();

    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    mutator->LeaveSaferegion();
    return snapshot;
}

static ArrayRef PinArray(const ArrayRef array)
{
    Mutator* mutator = Mutator::GetMutator();
    CHECK_DETAIL(mutator != nullptr, "Mutator has not initialized or has been fini: %p", mutator);
    CHECK_DETAIL(!mutator->InSaferegion(), "Mutator to be fini should not be in saferegion");
    // forbid gc thread to move this region.
    Heap::GetHeap().GetCollector().AddRawPointerObject(array);
    return static_cast<ArrayRef>(array);
}

// Return the raw pointer of input array object, isCopy records whether memory copy occurs.
// If GC is running, try to copy the payload of array and return the copy data pointer, isCopy set true
// If copy failed, just return the content pointer of real array, isCopy set false,
// but can't return until GC finish current work.
extern "C" void* MCC_AcquireRawData(const ArrayRef array, bool* isCopy)
{
    if (!Heap::IsHeapAddress(array)) {
        return array->ConvertToCArray();
    }
#ifdef _WIN64
    static void* unreadablePage = reinterpret_cast<void*>(0x1234);
#else
    static void* unreadablePage = MutatorManager::Instance().GetSafepointPageManager()->GetUnreadablePage();
#endif
    MRT_ASSERT(unreadablePage != nullptr, "runtime is not initialized\n");
    if (UNLIKELY(array == nullptr)) {
        return nullptr;
    }
    if (UNLIKELY(array->GetContentSize() == 0)) {
        return unreadablePage;
    }
    MRT_ASSERT(array->IsPrimitiveArray(), "Expect primitive array in MCC_AcquireRawData");
    if (isCopy != nullptr) {
        *isCopy = false;
    }
    (void)CJThreadPreemptOffCntAdd();
    ArrayRef pArray = PinArray(array);
#if defined(GENERAL_ASAN_SUPPORT_INTERFACE)
    auto* rawPtr = pArray->ConvertToCArray();
    std::vector<uint64_t> frame;
    StackManager::RecordLiteFrameInfos(frame, 4); // record 4 frames
    size_t pos = pinnedArrayRecorder.RegisterBtInfo(rawPtr, Mutator::GetMutator(), frame);
    DataClosure* dataClosure = new (NativeAllocator::NativeAlloc(sizeof(DataClosure))) DataClosure();
    if (dataClosure != nullptr) {
        dataClosure->rawPtr = rawPtr;
        dataClosure->mutator = Mutator::GetMutator();
        dataClosure->pos = pos;
        auto timer = TimerNew(30ULL * SECOND_TO_NANO_SECOND, 0, &RawPtrCheckerTimerEntry,
                              reinterpret_cast<void*>(dataClosure));
        if (timer != nullptr) {
            TimerRelease(timer);
        }
    }
#endif
#if defined(GENERAL_ASAN_SUPPORT_INTERFACE) || defined(CANGJIE_GWPASAN_SUPPORT)
    return Sanitizer::ArrayAcquireMemoryRegion(pArray, pArray->ConvertToCArray(), pArray->GetContentSize());
#else
    return pArray->ConvertToCArray();
#endif
}

// Release the raw pointer
extern "C" void MCC_ReleaseRawData(ArrayRef array, void* rawPtr)
{
    if (!Heap::IsHeapAddress(array)) {
        return;
    }
    MRT_ASSERT(array->IsPrimitiveArray(), "Expect primitive array in MCC_ReleaseRawData");
#ifdef _WIN64
    static void* unreadablePage = reinterpret_cast<void*>(0x1234);
#else
    static void* unreadablePage = MutatorManager::Instance().GetSafepointPageManager()->GetUnreadablePage();
#endif
    MRT_ASSERT(unreadablePage != nullptr, "runtime is not initialized\n");
    if (UNLIKELY(array == nullptr || rawPtr == nullptr)) {
        return;
    }
    if (rawPtr == unreadablePage) {
        return;
    }
#if defined(GENERAL_ASAN_SUPPORT_INTERFACE) || defined(CANGJIE_GWPASAN_SUPPORT)
    // sanitizer will convert alias/colorized pointer to real pointer for runtime
    rawPtr = Sanitizer::ArrayReleaseMemoryRegion(array, rawPtr, array->GetContentSize());
#endif
#if defined(GENERAL_ASAN_SUPPORT_INTERFACE)
    std::vector<uint64_t> frame;
    StackManager::RecordLiteFrameInfos(frame, 4); // record 4 frames
    pinnedArrayRecorder.RemoveBtInfo(rawPtr, Mutator::GetMutator(), frame);
#endif
    auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<uintptr_t>(rawPtr));
    (void)regionInfo->DecRawPointerObjectCount();
    (void)CJThreadPreemptOffCntSub();
}

enum LoadPackageStatus {
    LOAD_FAIL = 0,
    HAS_MULTI_PACKAGE = 1,
    // file with the same package name is loaded multiple times.
    LOAD_PACKAGE_REPEATED = 2,
    // file with the same name is loaded multiple times.
    LOAD_FILENAME_REPEATED = 3
};

extern "C" void* MCC_LoadPackage(const char* path)
{
    if (path == nullptr || *path == '\0') {
        return reinterpret_cast<void*>(LOAD_FAIL);
    }
    LoaderManager* loaderMgr = LoaderManager::GetInstance();
    if (loaderMgr->FileHasLoaded(path)) {
        return reinterpret_cast<void*>(LOAD_FILENAME_REPEATED);
    }
    if (LoadCJLibrary(path) != E_OK) {
        return reinterpret_cast<void*>(LOAD_FAIL);
    }
    if (loaderMgr->GetPackageInfoByPath(path) == nullptr) {
        loaderMgr->RemovePackageInfo(path);
        return reinterpret_cast<void*>(LOAD_PACKAGE_REPEATED);
    }
    if (loaderMgr->FileHasMultiPackage(path)) {
        loaderMgr->RemovePackageInfo(path);
        return reinterpret_cast<void*>(HAS_MULTI_PACKAGE);
    }
    if (InitCJLibrary(path) != E_OK) {
        return reinterpret_cast<void*>(LOAD_FAIL);
    }
    return loaderMgr->GetPackageInfoByPath(path);
}

extern "C" PackageInfo* MCC_GetPackageByQualifiedName(const char* packageName)
{
    if (packageName == nullptr || *packageName == '\0') {
        return nullptr;
    }
    return LoaderManager::GetInstance()->GetPackageInfoByName(packageName);
}

extern "C" const char* MCC_GetPackageVersion(PackageInfo* packageInfo)
{
    return packageInfo->GetVersion();
}

extern "C" ObjectPtr MCC_GetSubPackages(PackageInfo* packageInfo, TypeInfo* arrayTi)
{
    std::vector<PackageInfo*> subPackages = {};
    LoaderManager::GetInstance()->GetSubPackages(packageInfo, subPackages);
    size_t subPkgCnt = subPackages.size();
    // Array<CPointer<Unit>> layout likes { Rarray<CPointer<Unit>>, Int64, Int64 }
    TypeInfo* rawArrayTi = arrayTi->GetFieldType(0); // 0: first field type RawArray<CPointer<Unit>>.ti
    ArrayRef rawArrayObj = ObjectManager::NewKnownWidthArray(subPkgCnt, rawArrayTi,
        ObjectManager::ArrayElemBits::ELEM_64B, AllocType::RAW_POINTER_OBJECT);
    for (size_t idx = 0; idx < subPkgCnt; ++idx) {
        rawArrayObj->SetPrimitiveElement(idx, reinterpret_cast<int64_t>(subPackages[idx]));
    }
    U32 size = arrayTi->GetInstanceSize();
    MSize objSize = MRT_ALIGN(size + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    MObject* obj = ObjectManager::NewObject(arrayTi, objSize, AllocType::RAW_POINTER_OBJECT);
    // set rawArray
    Heap::GetBarrier().WriteReference(obj, obj->GetRefField(TYPEINFO_PTR_SIZE), static_cast<BaseObject*>(rawArrayObj));
    CJArray* cjArray = reinterpret_cast<CJArray*>(reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE);
    cjArray->start = 0;
    cjArray->length = subPkgCnt;
    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    return obj;
}

// for package
extern "C" const char* MCC_GetPackageName(PackageInfo* packageInfo) { return packageInfo->GetPackageName(); }

extern "C" PackageInfo* MCC_GetRelatedPackageInfo(PackageInfo* packageInfo)
{
    return packageInfo->GetRelatedPackageInfo(); // todo
}

extern "C" U32 MCC_GetNumOfTypeInfos(PackageInfo* packageInfo) { return packageInfo->GetNumOfTypeInfos(); }

extern "C" TypeInfo* MCC_GetPackageTypeInfo(PackageInfo* packageInfo, U32 index)
{
    return packageInfo->GetTypeInfo(index);
}

extern "C" U32 MCC_GetPackageNumOfGlobalMethodInfos(PackageInfo* packageInfo)
{
    return packageInfo->GetNumOfGlobalMethodInfos();
}

extern "C" MethodInfo* MCC_GetPackageGlobalMethodInfo(PackageInfo* packageInfo, U32 index)
{
    return packageInfo->GetGlobalMethodInfo(index);
}

extern "C" U32 MCC_GetPackageNumOfGlobalFieldInfos(PackageInfo* packageInfo)
{
    return packageInfo->GetNumOfGlobalFieldInfos();
}

extern "C" StaticFieldInfo* MCC_GetPackageGlobalFieldInfo(PackageInfo* packageInfo, U32 index)
{
    return packageInfo->GetGlobalFieldInfo(index);
}

// for reflection, method
extern "C" const char* MCC_GetMethodName(MethodInfo* methodInfo) { return methodInfo->GetMethodName(); }

extern "C" TypeInfo* MCC_GetMethodReturnType(MethodInfo* methodInfo) { return methodInfo->GetReturnType(); }

extern "C" U32 MCC_GetMethodModifier(MethodInfo* methodInfo) { return methodInfo->GetModifier(); }

extern "C" bool MCC_MethodEntryPointIsNull(MethodInfo* methodInfo) { return methodInfo->MethodEntryPointIsNull(); }

extern "C" void* MCC_ApplyCJInstanceMethod(MethodInfo* methodInfo, ObjRef obj, void* args)
{
    if (methodInfo == nullptr) {
        DynamicMethodInfo mthInfo(obj);
        return mthInfo.ApplyCangjieMethod(args);
    }
    return methodInfo->ApplyCJMethod(obj, nullptr, args, nullptr);
}

extern "C" void* MCC_ApplyCJStaticMethod(MethodInfo* methodInfo, void* args, TypeInfo* thisTi)
{
    return methodInfo->ApplyCJMethod(nullptr, nullptr, args, thisTi);
}

extern "C" void* MCC_ApplyCJGenericInstanceMethod(MethodInfo* methodInfo, ObjRef obj, void* genericArgs, void* args)
{
    return methodInfo->ApplyCJMethod(obj, genericArgs, args, nullptr);
}

extern "C" void* MCC_ApplyCJGenericStaticMethod(MethodInfo* methodInfo, void* genericArgs,
                                                void* args, TypeInfo* thisTi)
{
    return methodInfo->ApplyCJMethod(nullptr, genericArgs, args, thisTi);
}

extern "C" U32 MCC_GetNumOfActualParameters(MethodInfo* methodInfo)
{
    return methodInfo->GetNumOfActualParameterInfos();
}
extern "C" U32 MCC_GetNumOfGenericParameters(MethodInfo* methodInfo)
{
    return methodInfo->GetNumOfGenericParameterInfos();
}

extern "C" ParameterInfo* MCC_GetActualParameterInfo(MethodInfo* methodInfo, U32 index)
{
    return methodInfo->GetActualParameterInfo(index);
}

extern "C" GenericTypeInfo* MCC_GetGenericParameterInfo(MethodInfo* methodInfo, U32 index)
{
    return methodInfo->GetGenericParameterInfo(index);
}

extern "C" bool MCC_CheckMethodActualArgs(MethodInfo* methodInfo, void* genericArgs, void* args)
{
    return methodInfo->CheckMethodActualArgs(genericArgs, args);
}

extern "C" void* MCC_GetMethodAnnotations(MethodInfo* methodInfo, TypeInfo* arrayTi)
{
    return methodInfo->GetAnnotations(arrayTi);
}

static void RepalceLastDot(char* str)
{
    char *ptr1 = str;
    char *ptr2 = str;

    while (*ptr2 != '\0') {
        if (*ptr2 == '.') {
            ptr1 = ptr2;
        }
        if ((*ptr2 == '<' || *ptr2 == ',' || *ptr2 == '>' || *(ptr2 + 1) == '\0') && *ptr1 == '.') {
            *ptr1 = ':';
            ptr1 = ptr2; // reset ptr1 to ptr2's position
        }
        ptr2++;
    }
}

extern "C" TypeInfo* MCC_GetTypeByQualifiedName(char* qualifiedName)
{
    if (qualifiedName == nullptr || *qualifiedName == '\0') {
        return nullptr;
    }
    RepalceLastDot(qualifiedName);
    return LoaderManager::GetInstance()->FindTypeInfoFromLoadedFiles(qualifiedName);
}

// class/struct/interface
extern "C" TypeInfo* MCC_GetTypeByMangledName(const char* mangledName)
{
    if (mangledName == nullptr || *mangledName == '\0') {
        return nullptr;
    }
    return LoaderManager::GetInstance()->FindTypeInfoFromLoadedFiles(mangledName);
}

extern "C" TypeTemplate* MCC_GetTypeTemplate(char* name)
{
    if (name == nullptr || *name == '\0') {
        return nullptr;
    }
    RepalceLastDot(name);
    return LoaderManager::GetInstance()->FindTypeTemplateFromLoadedFiles(name);
}

static TypeInfo* GetActualTypeFromGenericType(GenericTypeInfo* genericTi, void* args, GenericTypeInfo* genericArgs)
{
    CJArray* cjArray = static_cast<CJArray*>(args);
    TypeInfo** actualTypeInfos = reinterpret_cast<TypeInfo**>(&(cjArray->rawPtr->data));
    U64 len = genericTi->GetGenericArgsNum();
    if (len == 0) {
        return nullptr;
    }
    void* mem = calloc(len, TYPEINFO_PTR_SIZE);
    CHECK_DETAIL(mem != nullptr, "GetActualTypeFromGenericType calloc failed");
    TypeInfo** typeInfos = static_cast<TypeInfo**>(mem);
    for (U64 idx = 0; idx < len; ++idx) {
        void* genericArg = genericTi->GetGenericArg(idx);
        for (U64 argIdx = 0; argIdx < cjArray->rawPtr->len; ++argIdx) {
            if (genericArg == genericArgs->GetGenericArg(argIdx)) {
                typeInfos[idx] = actualTypeInfos[argIdx];
            }
        }
    }
    TypeInfo* ti = TypeInfoManager::GetTypeInfoManager().GetOrCreateTypeInfo(
        genericTi->GetSourceGeneric(), len, typeInfos);
    free(mem);
    mem = nullptr;
    return ti;
}

static bool CheckGenericConstraint(GenericTypeInfo* genericTi, TypeInfo* ti, void* args, GenericTypeInfo* genericArgs)
{
    for (U64 constraintIdx = 0; constraintIdx < genericTi->GetGenericConstraintNum(); ++constraintIdx) {
        TypeInfo* constraintTi = genericTi->GetGenericConstraint(constraintIdx);
        if (constraintTi->IsGeneric()) {
            constraintTi =
                GetActualTypeFromGenericType(reinterpret_cast<GenericTypeInfo*>(constraintTi), args, genericArgs);
        }
        if (constraintTi == nullptr || !ti->IsSubType(constraintTi)) {
            return false;
        }
    }
    return true;
}

extern "C" TypeInfo* MCC_GetOrCreateTypeInfoForReflect(TypeTemplate* tt, void* args)
{
    if (tt == nullptr || args == nullptr) {
        return nullptr;
    }
    CJArray* cjArray = static_cast<CJArray*>(args);
    U64 len = cjArray->rawPtr->len;
    if (len == 0) {
        return nullptr;
    }

    if (tt->IsRawArray() || tt->IsVArray() || tt->IsCPointer()) {
        if (len != 1) {
            return nullptr;
        }
    } else {
        if (tt->GetTypeArgNum() != len) {
            return nullptr;
        }
    }

    Uptr base = reinterpret_cast<Uptr>(&(cjArray->rawPtr->data));
    void* mem = calloc(len, TYPEINFO_PTR_SIZE);
    TypeInfo** typeInfos = static_cast<TypeInfo**>(mem);
    CHECK_DETAIL(mem != nullptr, "MCC_GetOrCreateTypeInfoForReflect calloc failed");
    GenericTypeInfo* genericArgs = reinterpret_cast<GenericTypeInfo*>(
        tt->GetReflectInfo()->GetDeclaringGenericTypeInfo());
    for (U64 idx = 0; idx < len; ++idx) {
        typeInfos[idx] = *reinterpret_cast<TypeInfo**>(base + idx * TYPEINFO_PTR_SIZE);
        GenericTypeInfo* genericArg = static_cast<GenericTypeInfo*>(genericArgs->GetGenericArg(idx));
        if (!CheckGenericConstraint(genericArg, typeInfos[idx], args, genericArgs)) {
            free(mem);
            mem = nullptr;
            return nullptr;
        }
    }
    TypeInfo* ti = TypeInfoManager::GetTypeInfoManager().GetOrCreateTypeInfo(tt, len, typeInfos);
    free(mem);
    mem = nullptr;
    return ti;
}

extern "C" const char* MCC_GetTypeName(TypeInfo* ti) { return ti->GetName(); }

extern "C" bool MCC_IsInterface(TypeInfo* ti) { return ti->IsInterface(); }

extern "C" bool MCC_IsClass(TypeInfo* ti) { return ti->IsClass(); }

extern "C" bool MCC_IsStruct(TypeInfo* ti) { return ti->IsStruct(); }

extern "C" bool MCC_IsPrimitive(TypeInfo* ti) { return ti->IsPrimitiveType(); }

extern "C" bool MCC_IsGeneric(TypeInfo* ti) { return ti->IsGeneric(); }

extern "C" bool MCC_IsEnum(TypeInfo* ti) { return ti->IsEnum() || ti->IsTempEnum(); }

extern "C" bool MCC_IsFunction(TypeInfo* ti)
{
    if (ti->IsFunc()) {
        return true;
    }
    auto super = ti->GetSuperTypeInfo();
    if (super == nullptr) {
        return false;
    }
    return super->IsFunc();
}

extern "C" bool MCC_IsTuple(TypeInfo* ti) { return ti->IsTuple(); }

extern "C" bool MCC_IsReflectUnsupportedType(TypeInfo* ti) { return ti->IsReflectUnsupportedType(); }

// reflect support enum
extern "C" U32 MCC_GetNumOfEnumConstructorInfos(TypeInfo* ti)
{
    if (!ti->IsEnum() && !ti->IsTempEnum()) {
        return 0;
    }
    return ti->GetNumOfEnumCtor();
}

extern "C" EnumCtorInfo* MCC_GetEnumConstructorInfo(TypeInfo* ti, U32 idx)
{
    return ti->GetEnumCtor(idx);
}

extern "C" const char* MCC_GetEnumConstructorName(EnumCtorInfo* ti)
{
    return ti->GetName();
}

extern "C" EnumCtorInfo* MCC_GetEnumConstructorInfoFromAny(ObjRef obj)
{
    TypeInfo* ti = obj->GetTypeInfo();
    if (!ti->IsEnum() && !ti->IsTempEnum()) {
        return nullptr;
    }
    EnumInfo* enumInfo = ti->GetEnumInfo();
    if (ti->IsEnumCtor()) {
        enumInfo = ti->GetSuperTypeInfo()->GetEnumInfo();
    }

    I32 tag = FieldInitializer::GetEnumTag(obj, ti);
    return enumInfo->GetEnumCtor(tag);
}

extern "C" bool MCC_IsBox(TypeInfo* ti)
{
    return ti->IsBoxClass();
}

extern "C" TypeInfo** MCC_GetTypeArgs(TypeInfo* ti)
{
    return ti->GetTypeArgs();
}

// reflect support function
extern "C" U32 MCC_GetNumOfFunctionSignatureTypes(TypeInfo* funcTi)
{
    TypeInfo* ti = nullptr;
    auto super = funcTi->GetSuperTypeInfo();
    if (funcTi->IsFunc()) {
        ti = funcTi;
    } else if (super != nullptr && super->IsFunc()) {
        ti = super;
    } else {
        return 0;
    }

    // Now, `super` both are Closure type.
    // Get function type from Closure type, i.e., typeArgs[0]:
    TypeInfo* funcType = ti->GetTypeArgs()[0];
    U16 typeArgNum = funcType->GetTypeArgNum();

    return typeArgNum;
}

extern "C" TypeInfo** MCC_GetFunctionSignatureTypes(TypeInfo* funcTi)
{
    TypeInfo* ti = nullptr;
    auto super = funcTi->GetSuperTypeInfo();
    if (funcTi->IsFunc()) {
        ti = funcTi;
    } else if (super != nullptr && super->IsFunc()) {
        ti = super;
    } else {
        return nullptr;
    }

    // Now, `super` both are Closure type.
    // Get function type from Closure type, i.e., typeArgs[0]:
    TypeInfo* funcType = ti->GetTypeArgs()[0];

    TypeInfo** params = funcType->GetTypeArgs();
    return params;
}

// for tuple
extern "C" U32 MCC_GetNumOfFieldTypes(TypeInfo* ti)
{
    U32 num = ti->GetFieldNum();
    if ((ti->IsEnum() || ti->IsTempEnum()) && !ti->IsZeroSizedEnum()) {
        if (ti->IsOptionLikeUnassociatedCtor()) {
            return num - 2;
        }
        return num - 1;
    }
    return num;
}

extern "C" TypeInfo** MCC_GetFieldTypes(TypeInfo* ti)
{
    TypeInfo** fieldTypes = ti->GetFieldTypes();
    if ((ti->IsEnum() || ti->IsTempEnum()) && !ti->IsZeroSizedEnum()) {
        if (ti->IsOptionLikeUnassociatedCtor()) {
            // The unassociated constructor in option-like enum, don't have field,
            // but its fieldtypes has two placeholder, so return nullptr.
            return nullptr;
        }
        // skip the tag
        return fieldTypes + 1;
    }
    return fieldTypes;
}

// MCC_NewAndInitEnumTupleObject - Creates and initializes objects for enum and tuple types
// This function is specifically designed to handle object creation for:
// 1. Enum types (including temporary enums)
// 2. Tuple types
extern "C" ObjRef MCC_NewAndInitEnumTupleObject(TypeInfo* ti, void* args)
{
    if (args == nullptr) {
        return nullptr;
    }
    MSize size = MRT_ALIGN(ti->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    ObjRef obj = nullptr;

    if (ti->IsEnum() || ti->IsTempEnum()) {
        obj = FieldInitializer::CreateEnumObject(ti, size);
    } else if (ti->IsTuple()) {
        obj = ObjectManager::NewObject(ti, size, AllocType::RAW_POINTER_OBJECT);
        if (obj == nullptr) {
            VLOG(REPORT, "MCC_NewAndInitEnumTupleObject new tuple object failed and throw OutOfMemoryError");
            ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObject return nullptr");
        }
    } else {
        LOG(RTLOG_FATAL, "MCC_NewAndInitEnumTupleObject: unsupported type %s", ti->GetName());
    }

    if (obj == nullptr) {
        VLOG(REPORT, "Allocating object %s (%zu B) failed and throw OutOfMemoryError",
             ti->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("MCC_NewAndInitEnumTupleObject: Object creation failed");
        return nullptr;
    }

    // Parse fields from args and store them into obj.
    FieldInitializer::SetFieldFromArgs(obj, ti, args);
    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    return obj;
}

extern "C" ObjRef MCC_GetAssociatedValues(ObjRef obj, TypeInfo* arrayTi)
{
    TypeInfo* ti = obj->GetTypeInfo();
    U16 fieldNum = ti->GetFieldNum();
    // For enum and temp enum, except zero-sized enum, fields include the tag,
    // but the tag is not part of associated values, need skip the tag.
    // Option-like-ref enum has no tag, but the first element in the fields is a placeholder, so need skip too.
    if (ti->IsEnum() || ti->IsTempEnum()) {
        if (!ti->IsEnumCtor()) {
            // The object's TypeInfo(ti) is the enum's TypeInfo.
            // Read the tag, and get constructor's TypeInfo based on the tag.
            EnumInfo* enumInfo = ti->GetEnumInfo();
            I32 tag = FieldInitializer::GetEnumTag(obj, ti);
            ti = enumInfo->GetCtorTypeInfo(tag);
            fieldNum = ti->GetFieldNum();
        }
        if (!ti->IsZeroSizedEnum()) {
            if (ti->IsOptionLikeUnassociatedCtor()) {
                // 2: the unassociated constructor in option-like enum, fieldtypes has two element,
                //    they are placeholder, not part of associatd values, need skip them.
                fieldNum -= 2;
            } else {
                fieldNum -= 1;
            }
        }
    }

    TypeInfo* rawArrayTi = arrayTi->GetFieldType(0);
    ArrayRef array = ObjectManager::NewArray(fieldNum, rawArrayTi, AllocType::RAW_POINTER_OBJECT);
    if (array == nullptr) {
        VLOG(REPORT, "MCC_GetAssociatedValues new array failed and throw OutOfMemoryError");
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewArray return nullptr");
    }
    // Extract fields from obj and put them into array.
    FieldInitializer::SetElementFromObject(array, obj, ti, fieldNum);

    U32 size = arrayTi->GetInstanceSize();
    MSize arrayObjSize = MRT_ALIGN(size + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    ObjRef arrayObj = ObjectManager::NewObject(arrayTi, arrayObjSize, AllocType::RAW_POINTER_OBJECT);
    if (arrayObj == nullptr) {
        VLOG(REPORT, "MCC_GetAssociatedValues new object failed and throw OutOfMemoryError");
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObject return nullptr");
    }
    Heap::GetBarrier().WriteReference(
        arrayObj, arrayObj->GetRefField(TYPEINFO_PTR_SIZE), static_cast<BaseObject*>(array));
    CJArray* cjArray = reinterpret_cast<CJArray*>(reinterpret_cast<Uptr>(arrayObj) + TYPEINFO_PTR_SIZE);
    cjArray->start = 0;
    cjArray->length = fieldNum;
    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    return arrayObj;
}

// @deprecated
extern "C" U32 MCC_GetQualifiedNameLength(TypeInfo* ti) { return 0; }
// @deprecated
extern "C" void MCC_GetQualifiedName(TypeInfo* ti, char* qualifiedName) {}

// member functions
extern "C" U32 MCC_GetNumOfInstanceMethodInfos(TypeInfo* ti)
{
    return ti->GetNumOfInstanceMethodInfos();
}

extern "C" MethodInfo* MCC_GetInstanceMethodInfo(TypeInfo* ti, U32 index)
{
    return ti->GetInstanceMethodInfo(index);
}

// static member functions
extern "C" U32 MCC_GetNumOfStaticMethodInfos(TypeInfo* ti)
{
    return ti->GetNumOfStaticMethodInfos();
}

extern "C" MethodInfo* MCC_GetStaticMethodInfo(TypeInfo* ti, U32 index)
{
    return ti->GetStaticMethodInfo(index);
}

// member variables
extern "C" U32 MCC_GetNumOfInstanceFieldInfos(TypeInfo* ti)
{
    return ti->GetNumOfInstanceFieldInfos();
}

extern "C" InstanceFieldInfo* MCC_GetInstanceFieldInfo(TypeInfo* ti, U32 index)
{
    return ti->GetInstanceFieldInfo(index);
}

// static member functions
extern "C" U32 MCC_GetNumOfStaticFieldInfos(TypeInfo* ti)
{
    return ti->GetNumOfStaticFieldInfos();
}

extern "C" StaticFieldInfo* MCC_GetStaticFieldInfo(TypeInfo* ti, U32 index)
{
    return ti->GetStaticFieldInfo(index);
}

extern "C" U32 MCC_GetTypeInfoModifier(TypeInfo* ti) { return ti->GetModifier(); }


extern "C" TypeInfo* MCC_GetSuperTypeInfo(TypeInfo* ti) { return ti->GetSuperTypeInfo(); }

extern "C" U32 MCC_GetNumOfInterface(TypeInfo* ti)
{
    return LoaderManager::GetInstance()->GetNumOfInterface(ti);
}

extern "C" TypeInfo* MCC_GetInterface(TypeInfo* ti, U32 idx)
{
    return LoaderManager::GetInstance()->GetInterface(ti, idx);
}

// field
extern "C" const char* MCC_GetInstanceFieldName(InstanceFieldInfo* fieldInfo, TypeInfo* declaringTypeInfo)
{
    return fieldInfo->GetName(declaringTypeInfo);
}

extern "C" const char* MCC_GetStaticFieldName(StaticFieldInfo* fieldInfo) { return fieldInfo->GetName(); }

extern "C" TypeInfo* MCC_GetInstanceFieldType(InstanceFieldInfo* fieldInfo, TypeInfo* declaringTypeInfo)
{
    return fieldInfo->GetFieldType(declaringTypeInfo);
}

extern "C" TypeInfo* MCC_GetStaticFieldType(StaticFieldInfo* fieldInfo) { return fieldInfo->GetFieldType(); }

extern "C" U32 MCC_GetInstanceFieldModifier(InstanceFieldInfo* fieldInfo) { return fieldInfo->GetModifier(); }

extern "C" U32 MCC_GetStaticFieldModifier(StaticFieldInfo* fieldInfo) { return fieldInfo->GetModifier(); }

extern "C" void* MCC_GetInstanceFieldValue(InstanceFieldInfo* fieldInfo, TypeInfo* declaringTypeInfo, ObjRef obj)
{
    return fieldInfo->GetValue(declaringTypeInfo, obj);
}

extern "C" void MCC_SetInstanceFieldValue(InstanceFieldInfo* fieldInfo, TypeInfo* declaringTypeInfo,
                                          ObjRef obj, ObjRef newValue)
{
    fieldInfo->SetValue(declaringTypeInfo, obj, newValue);
}

extern "C" void* MCC_GetStaticFieldValue(StaticFieldInfo* fieldInfo) { return fieldInfo->GetValue(); }

extern "C" void MCC_SetStaticFieldValue(StaticFieldInfo* fieldInfo, ObjRef newValue)
{
    fieldInfo->SetValue(newValue);
}

extern "C" void* MCC_GetInstanceFieldAnnotations(InstanceFieldInfo* fieldInfo, TypeInfo* arrayTi)
{
    return fieldInfo->GetAnnotations(arrayTi);
}

extern "C" void* MCC_GetStaticFieldAnnotations(StaticFieldInfo* fieldInfo, TypeInfo* arrayTi)
{
    return fieldInfo->GetAnnotations(arrayTi);
}

// for reflect, parameter
extern "C" const char* MCC_GetParameterName(ParameterInfo* parameterInfo) { return parameterInfo->GetName(); }

extern "C" U32 MCC_GetParameterIndex(ParameterInfo* parameterInfo) { return parameterInfo->GetIndex(); }

extern "C" TypeInfo* MCC_GetParameterType(ParameterInfo* parameterInfo) { return parameterInfo->GetType(); }

extern "C" void* MCC_GetParameterAnnotations(ParameterInfo* parameterInfo, TypeInfo* arrayTi)
{
    return parameterInfo->GetAnnotations(arrayTi);
}

extern "C" ObjectPtr CJ_MCC_ReadRefField(const ObjectPtr obj, RefField<false>* field)
{
    if (IsGlobalStruct(obj, reinterpret_cast<MAddress>(field))) {
        return Heap::GetBarrier().ReadStaticRef(*field);
    }
    return Heap::GetBarrier().ReadReference(obj, *field);
}

extern "C" ObjectPtr CJ_MCC_ReadWeakRef(const ObjectPtr obj, RefField<false>* field)
{
    return Heap::GetBarrier().ReadWeakRef(obj, *field);
}
extern "C" void CJ_MCC_ReadStructField(MAddress dstPtr, ObjectPtr obj, MAddress srcField, size_t size, GCTib gctib)
{
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    if (Heap::IsHeapAddress((void*)dstPtr)) {
        LOG(RTLOG_FATAL, "dstPtr is in heap");
    }
#endif
    if (size == 0) {
        return;
    }
    if (IsGlobalStruct(obj, srcField)) {
        Heap::GetBarrier().ReadStaticStruct(dstPtr, srcField, size, gctib);
        return;
    }
    Heap::GetBarrier().ReadStruct(dstPtr, obj, srcField, size);
}
extern "C" ObjectPtr CJ_MCC_ReadStaticRef(RefField<false>* field)
{
    return Heap::GetBarrier().ReadStaticRef(*field);
}
extern "C" void CJ_MCC_ReadStaticStruct(MAddress dstPtr, size_t dstSize, MAddress srcPtr, size_t srcSize, GCTib gctib)
{
    Heap::GetBarrier().ReadStaticStruct(dstPtr, srcPtr, dstSize, gctib);
}
extern "C" void* MCC_GetTypeInfoAnnotations(TypeInfo* cls, TypeInfo* arrayTi) { return cls->GetAnnotations(arrayTi); }

// for generic
extern "C" TypeInfo* CJ_MCC_GetOrCreateTypeInfo(TypeTemplate* typeTemplate, U32 argSize, TypeInfo* typeArgs[])
{
    return TypeInfoManager::GetTypeInfoManager().GetOrCreateTypeInfo(typeTemplate, argSize, typeArgs);
}

extern "C" bool CJ_MCC_IsSubType(TypeInfo* typeInfo, TypeInfo* superTypeInfo)
{
    if (typeInfo == nullptr || superTypeInfo == nullptr) {
        return false;
    }
    if (typeInfo == superTypeInfo) {
        return true;
    }

    bool isSub = typeInfo->IsSubType(superTypeInfo);
    return isSub;
}

static bool IsTupleTypeOf(ObjectPtr obj, TypeInfo* typeInfo, TypeInfo* targetTypeInfo)
{
    // targetTypeInfo may not be of the tuple type. In this case, false is returned.
    if (!targetTypeInfo->IsTuple()) {
        return false;
    }
    TypeInfo* ti = typeInfo;
    U32 base = 0;
    if (typeInfo == nullptr) {
        ti = obj->GetTypeInfo();
        // 8: typeInfo offset
        base = 8;
    }
    if (ti == nullptr) {
        LOG(RTLOG_FATAL, "IsTupleTypeOf: get typeInfo failed");
    }
    if (ti->GetUUID() == targetTypeInfo->GetUUID()) {
        return true;
    }
    if (ti->GetFieldNum() != targetTypeInfo->GetFieldNum()) {
        return false;
    }
    for (U16 idx = 0; idx < ti->GetFieldNum(); ++idx) {
        TypeInfo* fieldTypeInfo = ti->GetFieldType(idx);
        TypeInfo* fieldTargetTI = targetTypeInfo->GetFieldType(idx);
        U32 offset = ti->GetFieldOffset(idx) + base;
        ObjectPtr curObj = nullptr;
        if (fieldTargetTI->IsRef()) {
            if (!fieldTypeInfo->IsClass() && !fieldTypeInfo->IsInterface()) {
                return false;
            }
            if (Heap::IsHeapAddress(obj)) {
                curObj = Heap::GetBarrier().ReadReference(obj, obj->GetRefField(offset));
            } else {
                curObj = obj->GetRefField(offset).GetTargetObject();
            }
            TypeInfo* curti = curObj->GetTypeInfo();
            if (!curti->IsSubType(fieldTargetTI)) {
                return false;
            }
        } else if (fieldTargetTI->IsTuple()) {
            curObj = reinterpret_cast<ObjectPtr>(reinterpret_cast<Uptr>(obj) + offset);
            if (!IsTupleTypeOf(curObj, fieldTypeInfo, fieldTargetTI)) {
                return false;
            }
        } else if (!fieldTypeInfo->IsSubType(fieldTargetTI)) {
            return false;
        }
    }
    return true;
}

extern "C" bool CJ_MCC_IsTupleTypeOf(ObjectPtr obj, TypeInfo* typeInfo, TypeInfo* targetTypeInfo)
{
    if (obj == nullptr || targetTypeInfo == nullptr) {
        return false;
    }
    return IsTupleTypeOf(obj, typeInfo, targetTypeInfo);
}

extern "C" void CJ_MCC_WriteGeneric(const ObjectPtr obj, void* fieldPtr, const ObjectPtr src, size_t size)
{
    if (src == nullptr || size == 0) {
        return;
    }
    Heap::GetBarrier().WriteGeneric(obj, fieldPtr, src, size);
}

extern "C" void CJ_MCC_AssignGeneric(ObjectPtr dst, ObjectPtr src, TypeInfo* typeInfo)
{
    size_t instanceSize = typeInfo->GetInstanceSize();
    if (instanceSize == 0) {
        return;
    }
    if (!typeInfo->HasRefField()) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(dst) + TYPEINFO_PTR_SIZE),
                              instanceSize,
                              reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(src) + TYPEINFO_PTR_SIZE),
                              instanceSize) == EOK,
                     "MCC_AssignGeneric memcpy_s failed");
    } else {
        MAddress dstAddr = reinterpret_cast<MAddress>(dst) + TYPEINFO_PTR_SIZE;
        Heap::GetBarrier().WriteGeneric(dst, reinterpret_cast<void*>(dstAddr), src, instanceSize);
    }
}

extern "C" void CJ_MCC_WriteGenericPayload(ObjectPtr dst, MAddress srcField, size_t srcSize)
{
    TypeInfo* typeInfo = dst->GetTypeInfo();
    if (srcSize == 0) {
        return;
    }

    if (!typeInfo->HasRefField()) {
        CHECK_DETAIL(memcpy_s(reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(dst) + TYPEINFO_PTR_SIZE),
                              GENERIC_PAYLOAD_SIZE,
                              reinterpret_cast<void*>(srcField),
                              srcSize) == EOK,
                     "MCC_WriteGenericPayload memcpy_s failed");
    } else {
        MAddress dstAddr = reinterpret_cast<MAddress>(dst) + TYPEINFO_PTR_SIZE;
        Heap::GetBarrier().WriteStruct(dst, dstAddr, srcSize, srcField, srcSize);
    }
}

extern "C" void CJ_MCC_ReadGeneric(const ObjectPtr dstPtr, ObjectPtr obj, void* fieldPtr, size_t size)
{
    if (size == 0) {
        return;
    }
    if (IsGlobalStruct(obj, reinterpret_cast<MAddress>(fieldPtr))) {
        constexpr size_t stackCache = 256;
        if (size < stackCache) {
            char stackMem[stackCache]{ 0 };
            Heap::GetBarrier().ReadStaticStruct(reinterpret_cast<MAddress>(stackMem),
                reinterpret_cast<MAddress>(fieldPtr), size, dstPtr->GetGCTib());
            Heap::GetBarrier().ReadGeneric(dstPtr, nullptr, stackMem, size);
            return;
        } else {
            char* nativeHeapMem = (char*)malloc(size);
            CHECK_DETAIL(nativeHeapMem != nullptr, "malloc failed when read generic %p -> %p(%p) size %zu",
                         dstPtr, obj, fieldPtr, size);
            Heap::GetBarrier().ReadStaticStruct(reinterpret_cast<MAddress>(nativeHeapMem),
                reinterpret_cast<MAddress>(fieldPtr), size, dstPtr->GetGCTib());
            Heap::GetBarrier().ReadGeneric(dstPtr, nullptr, nativeHeapMem, size);
            free(nativeHeapMem);
            return;
        }
    }
    Heap::GetBarrier().ReadGeneric(dstPtr, obj, fieldPtr, size);
}

extern "C" FuncPtr* CJ_MCC_GetMTable(TypeInfo* ti, TypeInfo* itf)
{
    return ti->GetMTable(itf);
}

extern "C" TypeInfo* CJ_MCC_GetMethodOuterTI(TypeInfo* ti, TypeInfo* itf, U64 index)
{
    return ti->GetMethodOuterTI(itf, index);
}

extern "C" void CJ_MCC_UpdateVMT(TypeInfo* ti, TypeInfo* itf, ExtensionData* extensionData)
{
    if (UNLIKELY(!extensionData->IsFuncTableUpdated())) {
        return ti->TryUpdateExtensionData(itf, extensionData);
    }
}

extern "C" ObjRef MCC_NewGenericObject(const TypeInfo* klass, MSize size)
{
    ObjRef obj = ObjectManager::NewObject(klass, size);
    if (obj == nullptr) {
        VLOG(REPORT, "Allocation generic object %s (%zu B) failed and throw OutOfMemoryError", klass->GetName(), size);
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObject return nullptr");
    }
    return obj;
}

extern "C" ArrayRef MCC_NewArrayGeneric(const TypeInfo* arrayInfo, MIndex nElems)
{
    ArrayRef array = nullptr;
    if (!arrayInfo->IsArrayType()) {
        return array;
    }
    TypeInfo* componentTypeInfo = arrayInfo->GetComponentTypeInfo();
    I8 type = componentTypeInfo->GetType();
    switch (type) {
        case TypeKind::TYPE_KIND_CLASS:
        case TypeKind::TYPE_KIND_EXPORTED_REF:
        case TypeKind::TYPE_KIND_FOREIGN_PROXY:
        case TypeKind::TYPE_KIND_WEAKREF_CLASS:
        case TypeKind::TYPE_KIND_INTERFACE:
        case TypeKind::TYPE_KIND_TEMP_ENUM:
        case TypeKind::TYPE_KIND_RAWARRAY:
        case TypeKind::TYPE_KIND_FUNC: {
            array = ObjectManager::NewObjArray(nElems, arrayInfo);
            break;
        }
        case TypeKind::TYPE_KIND_UNIT:
        case TypeKind::TYPE_KIND_NOTHING:
        case TypeKind::TYPE_KIND_VARRAY:
        case TypeKind::TYPE_KIND_TUPLE:
        case TypeKind::TYPE_KIND_STRUCT:
        case TypeKind::TYPE_KIND_ENUM: {
            array = ObjectManager::NewArray(nElems, arrayInfo);
            break;
        }
        case TypeKind::TYPE_KIND_BOOL:
        case TypeKind::TYPE_KIND_UINT8:
        case TypeKind::TYPE_KIND_INT8: {
            array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_8B);
            break;
        }
        case TypeKind::TYPE_KIND_UINT16:
        case TypeKind::TYPE_KIND_INT16:
        case TypeKind::TYPE_KIND_FLOAT16: {
            array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_16B);
            break;
        }
        case TypeKind::TYPE_KIND_UINT32:
        case TypeKind::TYPE_KIND_INT32:
        case TypeKind::TYPE_KIND_RUNE:
        case TypeKind::TYPE_KIND_FLOAT32: {
            array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_32B);
            break;
        }
        case TypeKind::TYPE_KIND_INT_NATIVE:
        case TypeKind::TYPE_KIND_UINT_NATIVE:
        case TypeKind::TYPE_KIND_UINT64:
        case TypeKind::TYPE_KIND_INT64:
        case TypeKind::TYPE_KIND_FLOAT64:
        case TypeKind::TYPE_KIND_CSTRING:
        case TypeKind::TYPE_KIND_CPOINTER:
        case TypeKind::TYPE_KIND_CFUNC: {
            array = ObjectManager::NewKnownWidthArray(nElems, arrayInfo, ObjectManager::ArrayElemBits::ELEM_64B);
            break;
        }
        default:
            break;
    }
    if (array == nullptr) {
        VLOG(REPORT, "Allocation generic array %s length %zu failed and throw OutOfMemoryError",
             arrayInfo->GetName(), nElems);
        ExceptionManager::CheckAndThrowPendingException("NewArrayGeneric return nullptr");
    }
    return array;
}

extern "C" void CJ_MCC_ArrayCopyGeneric(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                        const ObjectPtr srcObj, MAddress srcField, size_t srcSize)
{
    if (dstSize == 0) {
        return;
    }
    MRT_ASSERT(dstSize <= SECUREC_MEM_MAX_LEN, "size too big in MCC_ArrayCopyGeneric");
    TypeInfo* arrayInfo = srcObj->GetTypeInfo();

    TypeInfo* componentTypeInfo = arrayInfo->GetComponentTypeInfo();
    I8 type = componentTypeInfo->GetType();
    if (componentTypeInfo->IsStructType() && !componentTypeInfo->HasRefField()) {
        CHECK_DETAIL(memmove_s(reinterpret_cast<void*>(dstField), dstSize,
                               reinterpret_cast<void*>(srcField), srcSize) == EOK,
                     "MCC_ArrayCopyGeneric memmove_s failed");
        return;
    }
    switch (type) {
        case TypeKind::TYPE_KIND_CLASS:
        case TypeKind::TYPE_KIND_EXPORTED_REF:
        case TypeKind::TYPE_KIND_FOREIGN_PROXY:
        case TypeKind::TYPE_KIND_WEAKREF_CLASS:
        case TypeKind::TYPE_KIND_INTERFACE:
        case TypeKind::TYPE_KIND_TEMP_ENUM:
        case TypeKind::TYPE_KIND_RAWARRAY:
        case TypeKind::TYPE_KIND_FUNC: {
            Heap::GetBarrier().CopyRefArray(dstObj, dstField, dstSize, srcObj, srcField, srcSize);
            break;
        }
        case TypeKind::TYPE_KIND_UNIT:
        case TypeKind::TYPE_KIND_BOOL:
        case TypeKind::TYPE_KIND_INT8:
        case TypeKind::TYPE_KIND_UINT8:
        case TypeKind::TYPE_KIND_NOTHING:
        case TypeKind::TYPE_KIND_UINT16:
        case TypeKind::TYPE_KIND_INT16:
        case TypeKind::TYPE_KIND_FLOAT16:
        case TypeKind::TYPE_KIND_UINT32:
        case TypeKind::TYPE_KIND_INT32:
        case TypeKind::TYPE_KIND_RUNE:
        case TypeKind::TYPE_KIND_FLOAT32:
        case TypeKind::TYPE_KIND_UINT64:
        case TypeKind::TYPE_KIND_INT64:
        case TypeKind::TYPE_KIND_FLOAT64:
        case TypeKind::TYPE_KIND_INT_NATIVE:
        case TypeKind::TYPE_KIND_UINT_NATIVE:
        case TypeKind::TYPE_KIND_CSTRING:
        case TypeKind::TYPE_KIND_CPOINTER:
        case TypeKind::TYPE_KIND_CFUNC:
        case TypeKind::TYPE_KIND_VARRAY: {
            CHECK_DETAIL(memmove_s(reinterpret_cast<void*>(dstField), dstSize,
                                   reinterpret_cast<void*>(srcField), srcSize) == EOK,
                         "MCC_ArrayCopyGeneric memmove_s failed");
            break;
        }
        case TypeKind::TYPE_KIND_TUPLE:
        case TypeKind::TYPE_KIND_STRUCT:
        case TypeKind::TYPE_KIND_ENUM: {
            Heap::GetBarrier().CopyStructArray(dstObj, dstField, dstSize, srcObj, srcField, srcSize);
            break;
        }
        default:
            break;
    }
}

extern "C" void CJ_MCC_CopyStructField(BaseObject* dstBase, void* dstField, size_t dstLen,
                                       BaseObject* srcBase, void* srcField, size_t srcLen) {}

extern "C" int32_t __ccc_personality_v0() { return 0; }
// @deprecated
extern "C" void CJ_MCC_IVCallInstrumentation(TypeInfo* cls, const char* callBaseKey) {}

void CJ_MCC_CrossAccessBarrier(U64 cjExport)
{
    Heap::GetHeap().CrossAccessBarrier(cjExport);
}

U64 CJ_MCC_CreateExportHandle(BaseObject *obj)
{
    U64 id = Heap::GetHeap().RegisterExportRoot(obj);
    return id;
}

BaseObject* CJ_MCC_GetExportedRef(U64 id)
{
    return Heap::GetHeap().GetExportObject(id);
}
void CJ_MCC_RemoveExportedRef(U64 id)
{
    Heap::GetHeap().RemoveExportObject(id);
}

extern "C" uintptr_t CJ_MCC_GetJSLambdaAddr(const ObjectPtr obj)
{
    ObjectPtr currentObj = obj;
    // offset of realAutoEnvObj in instance data (func1: 8 bytes + func2: 8 bytes)
    constexpr size_t realAutoEnvObjOffset = 16;

    // Loop to check if it's a wrapper class, if so, get realAutoEnvObj until finding a non-wrapper class
    while (MCC_IsWrapperClassForAutoEnv(currentObj->GetTypeInfo())) {
        currentObj = Heap::GetBarrier().ReadReference(currentObj,
            currentObj->GetRefField(TYPEINFO_PTR_SIZE + realAutoEnvObjOffset));
    }

    // Access func1 directly from currentObj
    uintptr_t func1 = *reinterpret_cast<uintptr_t*>(reinterpret_cast<Uptr>(currentObj) + TYPEINFO_PTR_SIZE);
    return func1;
}

#if defined(__OHOS__)
void* ARKTS_CreateEngine = nullptr;
void* ARKTS_UpdateStackInfo = nullptr;
void* ARKTS_GetContext = nullptr;
bool g_hasFindArkTSFunctions = false;
bool FindArkTSFunctions()
{
    static SpinLock spinLock;
    ScopedEnterSpinLock scopedEnterSpinLock(spinLock);
    if (g_hasFindArkTSFunctions) {
        return true;
    }
    void* handler = dlopen("libark_interop.z.so", RTLD_NOW | RTLD_GLOBAL);
    if (handler == nullptr) {
        return false;
    }
    ARKTS_CreateEngine = dlsym(handler, "ARKTS_CreateEngine");
    if (ARKTS_CreateEngine == nullptr) {
        return false;
    }
    ARKTS_UpdateStackInfo = dlsym(handler, "ARKTS_UpdateStackInfo");
    if (ARKTS_UpdateStackInfo == nullptr) {
        return false;
    }
    ARKTS_GetContext = dlsym(handler, "ARKTS_GetContext");
    if (ARKTS_GetContext == nullptr) {
        return false;
    }
    g_hasFindArkTSFunctions = true;
    return true;
}

extern "C" void* CJ_MRT_ARKTS_CreateEngine()
{
    if (!FindArkTSFunctions()) {
        LOG(RTLOG_ERROR, "Failed to find arkts functions.");
        return nullptr;
    }
    auto res = ((void* (*)())ARKTS_CreateEngine)();
    if (res == nullptr) {
        LOG(RTLOG_ERROR, "Failed to create arkts engine.");
        return res;
    }
    auto arkVm = ((unsigned long long (*)(void*))ARKTS_GetContext)(res);
    if (arkVm == 0) {
        LOG(RTLOG_ERROR, "Failed to get arkvm.");
        return res;
    }
    RegisterArkVMInRuntime(arkVm);
    RegisterStackInfoCallbacks(((UpdateStackInfoFunc)ARKTS_UpdateStackInfo));

    return res;
}

extern "C" void CJ_MRT_RegisterExceptionCallback(void(*callback)())
{
    ExceptionManager::RegisterExceptionCallback(callback);
}
#endif
} // namespace MapleRuntime
