// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.
#include "InterpreterSpecific.h"
#ifdef INTERPRETER_ENABLED

#include "Base/LogFile.h"
#include "CjScheduler.h"
#include "Common/BaseObject.h"
#include "Common/ScopedObjectAccess.h"
#include "Common/StackType.h"
#include "Common/TypeDef.h"
#include "ExceptionManager.inline.h"
#include "Heap/Barrier/Barrier.h"
#include "Heap/Collector/Collector.h"
#include "Interpreter/RTInterface.h"
#include "LoaderManager.h"
#include "Mutator/Mutator.h"
#include "Mutator/ThreadLocal.h"
#include "ObjectManager.inline.h"
#include "ObjectModel/MArray.h"
#include "ObjectModel/MClass.h"
#include "StackManager.h"
#include "TypeInfoManager.h"
#include "dlfcn.h"
#include <cstdint>
#include <cstring>

namespace MapleRuntime {

extern "C" void CJ_MCC_StackGrowStub(...);
extern "C" void CJ_MCC_I2NStub(...);
extern "C" void CJ_MCC_I2NStubEnd(...);
extern "C" FuncPtr* CJ_MCC_GetMTable(TypeInfo* ti, TypeInfo* itf);
extern "C" TypeInfo* CJ_MCC_GetMethodOuterTI(TypeInfo* ti, TypeInfo* itf, U64 index);
extern "C" void CJ_MCC_UpdateVMT(TypeInfo* ti, TypeInfo* itf, ExtensionData* extensionData);

namespace {
static_assert(sizeof(uintptr_t) == sizeof(MAddress), "uintptr_t must be able to carry MAddress");

MAddress ToMAddress(uintptr_t address)
{
    return static_cast<MAddress>(address);
}
} // namespace

struct {
    bool initialized = false;
    INT_InterpreterInterface interpreterInterface;

    void initialize(INT_InterpreterInterface& value)
    {
        interpreterInterface = value;
        initialized = true;
    }

    operator bool()
    {
        return initialized;
    }

    INT_InterpreterInterface* operator->()
    {
        if (initialized) {
            return &interpreterInterface;
        }
        LOG(RTLOG_FATAL, "Usage of uninitialized interpreter interface\n");
        return nullptr;
    }
} g_interpreterInterface;

uint32_t GetFrameSize(uintptr_t fp)
{
    assert(g_interpreterInterface.initialized);
    DLOG(INTERPRETER, "GetFrameSize(fp=%p)", fp);

    auto framePointer = reinterpret_cast<DYN_FramePointer>(fp);
    return g_interpreterInterface->getFrameSize(framePointer);
}

void FillInterpretedFrameInfo(uintptr_t fp, uintptr_t ip, INT_InterpretedFrameInfo* fInfo)
{
    assert(g_interpreterInterface.initialized); // interpreter frame can exist only if interface is enabled

    auto framePointer = reinterpret_cast<DYN_FramePointer>(fp);
    auto instructionPointer = reinterpret_cast<DYN_InstructionPointer>(ip);

    DLOG(INTERPRETER, "FillInterpretedFrameInfo(fp=%p, ip=%p)", framePointer, instructionPointer);
    g_interpreterInterface->frameInfoProvider(instructionPointer, framePointer, fInfo);
}

void FillInterpretedFrameDesc(uint64_t functionHandle, uint64_t position, StackTraceElement& ste)
{
    assert(g_interpreterInterface.initialized); // interpreter frame can exist only if interface is enabled

    INT_InterpretedFrameDesc fDesc;

    INT_FunctionHandle fuh = reinterpret_cast<INT_FunctionHandle>(functionHandle);
    INT_BytecodePos pos = reinterpret_cast<INT_BytecodePos>(position);

    DLOG(INTERPRETER, "FillInterpretedFrameDesc(fuh=%p, bcPos=%p)", fuh, pos);
    g_interpreterInterface->frameDescProvider(fuh, pos, &fDesc);

    ste.lineNumber = static_cast<int64_t>(fDesc.lineNumber);
    ste.methodName = fDesc.methodName; // copying assignment
    ste.className = fDesc.className;   // copying assignment
    ste.fileName = fDesc.fileName;     // copying assignment

    fDesc.freeResources(fDesc.methodName, fDesc.className, fDesc.fileName);
}

void IterateFramesWithState(
    DYN_CJThreadSpecificData cjThreadData, void (*callback)(DYN_VisitingState, void*), void* ctx)
{
    if (g_interpreterInterface) {
        g_interpreterInterface->iterateFramesWithState(cjThreadData, callback, ctx);
    }
}

INT_FrameDesc toFrameDesc(FrameInfo frameInfo)
{
    return {
        .fp = frameInfo.GetMachineFrame().GetFA(),
        .ip = frameInfo.GetMachineFrame().GetIP(),
    };
}

void VisitInterpreterFrameRootsExpansion(DYN_VisitingState state, FrameInfo frameDesc, DYN_RootVisitor stackPtrVisitor,
    DYN_DerivedPtrVisitor derivedPtrVisitor)
{
    if (g_interpreterInterface) {
        INT_FrameDesc fd = toFrameDesc(frameDesc);
        g_interpreterInterface->visitFrameRootsExpansion(state, fd, stackPtrVisitor, derivedPtrVisitor);
    }
}

void VisitInterpreterFrameRootsMarking(DYN_VisitingState state, FrameInfo frameDesc, DYN_RootVisitor rootVisitor)
{
    if (g_interpreterInterface) {
        INT_FrameDesc fd = toFrameDesc(frameDesc);
        g_interpreterInterface->visitFrameRootsMarking(state, fd, rootVisitor);
    }
}

void VisitInterpreterFrameRootsAdjusting(
    DYN_VisitingState state, FrameInfo frameDesc, DYN_RootVisitor rootVisitor, DYN_DerivedPtrVisitor derivedPtrVisitor)
{
    if (g_interpreterInterface) {
        INT_FrameDesc fd = toFrameDesc(frameDesc);
        g_interpreterInterface->visitFrameRootsAdjusting(state, fd, rootVisitor, derivedPtrVisitor);
    }
}

void VisitInterpreterGlobalRoots(DYN_RootVisitor visitor)
{
    if (g_interpreterInterface) {
        g_interpreterInterface->visitGlobalRoots(visitor);
    }
}

void InterpreterCJThreadStart(DYN_CJThreadSpecificData* dataField)
{
    if (g_interpreterInterface) {
        g_interpreterInterface->cjThreadOnStart(dataField);
    }
}

void InterpreterCJThreadDestroy(DYN_CJThreadSpecificData* dataField)
{
    if (g_interpreterInterface) {
        g_interpreterInterface->cjThreadOnDestroy(dataField);
    }
}

DYN_CJThreadHandle NewCJThread(void* execute, DYN_ObjRef future, void* scheduler)
{
    DLOG(INTERPRETER, "NewCJThread: execute=%p, future=%p, scheduler=%p", execute, future, scheduler);
    return MCC_NewCJThread(execute, future, scheduler);
}

void VisitRootFromInterpreter(DYN_RootVisitor _visitor, DYN_Placeholder _placeholder)
{
    const RootVisitor* visitor = static_cast<const RootVisitor*>(_visitor);
    ObjectRef* placeholder = static_cast<ObjectRef*>(_placeholder);

    DLOG(INTERPRETER, "VisitRootFromInterpreter: visitor=[%p], placeholder=[%p]", (void*)visitor, (void*)placeholder);

    (*visitor)(*placeholder);
}

void VisitDerivedPtrFromInterpreter(
    DYN_DerivedPtrVisitor _visitor, DYN_Placeholder _basePtrHolder, DYN_Placeholder _derivedPtrHolder)
{
    const DerivedPtrVisitor* visitor = static_cast<const DerivedPtrVisitor*>(_visitor);
    BasePtrType* basePtrLocation = static_cast<BasePtrType*>(_basePtrHolder);
    DerivedPtrType* derivedPtrLocation = static_cast<DerivedPtrType*>(_derivedPtrHolder);

    DLOG(INTERPRETER, "VisitDerivedPtrFromInterpreter: visitor=[%p], placeholder=[%p]", (void*)visitor,
        (void*)derivedPtrLocation);

    (*visitor)(*basePtrLocation, *derivedPtrLocation);
}

struct DYN_TypeInfo* TypeInfoProvider(const char* sig)
{
    DLOG(INTERPRETER, "TypeInfoProvider: %s", sig);
    auto* result =
        reinterpret_cast<struct DYN_TypeInfo*>(LoaderManager::GetInstance()->FindTypeInfoFromLoadedFiles(sig));
    DLOG(INTERPRETER, "FindTypeInfoFromLoadedFiles(%s) return %p", sig, result);

    return result;
}

DYN_TypeTemplate FindTypeTemplate(const char* mangledName)
{
    DLOG(INTERPRETER, "FindTypeTemplate: %s", mangledName);
    DYN_TypeTemplate result = LoaderManager::GetInstance()->FindTypeTemplateFromLoadedFiles(mangledName);
    DLOG(INTERPRETER, "FindTypeTemplateFromLoadedFiles(%s) return %p", mangledName, result);

    return result;
}

struct DYN_TypeInfo* GetOrCreateTypeInfo(
    DYN_TypeTemplate typeTemplate, uint32_t typeArgsCount, struct DYN_TypeInfo** typeArgs)
{
    DLOG(INTERPRETER, "GetOrCreateTypeInfo: template=%p size=%u", typeTemplate, typeArgsCount);

    return reinterpret_cast<struct DYN_TypeInfo*>(TypeInfoManager::GetTypeInfoManager().GetOrCreateTypeInfo(
        static_cast<TypeTemplate*>(typeTemplate), typeArgsCount, reinterpret_cast<TypeInfo**>(typeArgs)));
}

uint32_t GetInstanceSize(struct DYN_TypeInfo* typeInfoPtr)
{
    TypeInfo* ti = reinterpret_cast<TypeInfo*>(typeInfoPtr);
    DLOG(INTERPRETER, "GetInstanceSize: %s", ti->GetName());
    return ti->GetInstanceSize();
}

DYN_FuncPtr* GetMTable(struct DYN_TypeInfo* ti, struct DYN_TypeInfo* itf)
{
    DLOG(INTERPRETER, "GetMTable: ti=%p, itf=%p", ti, itf);
    return reinterpret_cast<DYN_FuncPtr*>(
        CJ_MCC_GetMTable(reinterpret_cast<TypeInfo*>(ti), reinterpret_cast<TypeInfo*>(itf)));
}

struct DYN_TypeInfo* GetMethodOuterTI(struct DYN_TypeInfo* ti, struct DYN_TypeInfo* itf, uint64_t index)
{
    DLOG(INTERPRETER, "GetMethodOuterTI: ti=%p, itf=%p, index=%llu", ti, itf, static_cast<unsigned long long>(index));
    return reinterpret_cast<struct DYN_TypeInfo*>(
        CJ_MCC_GetMethodOuterTI(reinterpret_cast<TypeInfo*>(ti), reinterpret_cast<TypeInfo*>(itf), index));
}

void UpdateVMT(struct DYN_TypeInfo* ti, struct DYN_TypeInfo* itf, struct DYN_ExtensionData* extensionData)
{
    DLOG(INTERPRETER, "UpdateVMT: ti=%p, itf=%p, extensionData=%p", ti, itf, extensionData);
    CJ_MCC_UpdateVMT(reinterpret_cast<TypeInfo*>(ti), reinterpret_cast<TypeInfo*>(itf),
        reinterpret_cast<ExtensionData*>(extensionData));
}

uint32_t GetTypeInfoUUID(struct DYN_TypeInfo* ti)
{
    TypeInfo* typeInfo = reinterpret_cast<TypeInfo*>(ti);
    DLOG(INTERPRETER, "GetTypeInfoUUID: ti=%p", ti);
    return typeInfo->GetUUID();
}

DYN_ObjRef ObjectAllocate(struct DYN_TypeInfo* tpe)
{
    TypeInfo* typeInfo = reinterpret_cast<TypeInfo*>(tpe);
    MSize size = AlignUp<MSize>(typeInfo->GetInstanceSize(), 8) + sizeof(TypeInfo*);

    ObjRef obj = ObjectManager::NewObject(typeInfo, size);

    DLOG(INTERPRETER, "ObjectAllocate: type=%p (%s), addr=%p, size=%u", tpe, typeInfo->GetName(), obj, size);

    return (DYN_ObjRef)obj;
}

DYN_ObjRef ArrayAllocate(struct DYN_TypeInfo* tpe, uint64_t size)
{
    TypeInfo* typeInfo = reinterpret_cast<TypeInfo*>(tpe);

    ArrayRef arr = ObjectManager::NewArray(size, typeInfo);
    DLOG(INTERPRETER, "ArrayAllocate: type=%p, addr=%p, size=%u", tpe, arr, size);

    return (DYN_ObjRef)arr;
}

void SafePoint()
{
    DLOG(INTERPRETER, "SafePoint");

    ScopedEnterSaferegion gcpoint(true);
}

int IsPendingSafePoint(DYN_ThreadLocalData tlData)
{
    if (tlData == nullptr) {
        LOG(RTLOG_ERROR, "[Interpreter] IsPendingSafePoint called with null DYN_ThreadLocalData");
        return 0;
    }
    ThreadLocalData* threadLocalData = reinterpret_cast<ThreadLocalData*>(tlData);
    return threadLocalData->safepointState != 0 ? 1 : 0;
}

void ThrowException(DYN_ObjRef exception)
{
    ExceptionRef exceptionRef = static_cast<ExceptionRef>(exception);
    DLOG(INTERPRETER, "ThrowException: exception=%p, type=%s", exceptionRef,
        (exceptionRef != nullptr && exceptionRef->GetTypeInfo() != nullptr) ?
        exceptionRef->GetTypeInfo()->GetName() : "<null>");

    ExceptionManager::ThrowException(exceptionRef);
}

void ThrowOutOfMemoryError()
{
    DLOG(INTERPRETER, "ThrowOutOfMemoryError");
    ExceptionManager::OutOfMemory();
    ExceptionManager::ThrowPendingException();
}

DYN_ObjRef GetPendingException()
{
    ExceptionRef ref = ExceptionManager::GetPendingException();

    DLOG(INTERPRETER, "GetPendingException: %p", ref);
    return static_cast<DYN_ObjRef>(ref);
}

DYN_ObjRef GetAndClearPendingException()
{
    auto ref = GetPendingException();

    ExceptionManager::ClearPendingException();
    DLOG(INTERPRETER, "GetAndClearPendingException: %p", ref);

    return ref;
}

int InstanceOf(DYN_ObjRef ref, struct DYN_TypeInfo* ti)
{
    DLOG(INTERPRETER, "InstanceOf: ref=%p, typeInfo=%p", ref, ti);

    MObject* obj = static_cast<MObject*>(ref);
    TypeInfo* tinfo = reinterpret_cast<TypeInfo*>(ti);

    DLOG(INTERPRETER, "  obj type is %s", obj->GetTypeInfo()->GetName());
    DLOG(INTERPRETER, "  type to check is %s", tinfo->GetName());

    return obj->IsSubType(*tinfo) ? 1 : 0;
}

int IsSubType(struct DYN_TypeInfo* typeInfo, struct DYN_TypeInfo* superTypeInfo)
{
    DLOG(INTERPRETER, "IsSubType: ti=%p, sti=%p", typeInfo, superTypeInfo);
    if (typeInfo == nullptr || superTypeInfo == nullptr) {
        return 0;
    }
    if (typeInfo == superTypeInfo) {
        return 1;
    }

    TypeInfo* tInfo = reinterpret_cast<TypeInfo*>(typeInfo);
    TypeInfo* sInfo = reinterpret_cast<TypeInfo*>(superTypeInfo);
    return tInfo->IsSubType(sInfo) ? 1 : 0;
}

DYN_ObjRef ReadStaticField(DYN_FieldRef source)
{
    DLOG(INTERPRETER, "ReadStaticField %p", source);

    BaseObject* res = Heap::GetBarrier().ReadStaticRef(*static_cast<RefField<false>*>(source));
    return static_cast<DYN_ObjRef>(res);
}

void WriteStaticField(DYN_FieldRef destination, DYN_ObjRef new_value)
{
    DLOG(INTERPRETER, "WriteStaticField %p %p", destination, new_value);

    Heap::GetBarrier().WriteStaticRef(*static_cast<RefField<false>*>(destination), static_cast<BaseObject*>(new_value));
}

DYN_ObjRef ReadInstanceField(DYN_ObjRef source, DYN_FieldRef field)
{
    DLOG(INTERPRETER, "ReadInstanceField %p %p", source, field);

    RefField<false>& ref = *static_cast<RefField<false>*>(field);
    BaseObject* res = Heap::GetBarrier().ReadReference(static_cast<BaseObject*>(source), ref);
    return static_cast<DYN_ObjRef>(res);
}

void WriteInstanceField(DYN_ObjRef destination, DYN_FieldRef field, DYN_ObjRef new_value)
{
    DLOG(INTERPRETER, "WriteInstanceField %p %p %p", destination, field, new_value);
    RefField<false>& ref = *static_cast<RefField<false>*>(field);
    Heap::GetBarrier().WriteReference(static_cast<BaseObject*>(destination), ref, static_cast<BaseObject*>(new_value));
}

DYN_ObjRef GetArrayElement(DYN_ObjRef source, U64 index)
{
    DLOG(INTERPRETER, "GetArrayElement %p %llu", source, index);
    MArray* array = static_cast<MArray*>(source);
    return static_cast<DYN_ObjRef>(array->GetRefElement(index));
}

void SetArrayElement(DYN_ObjRef source, U64 index, DYN_ObjRef new_value)
{
    DLOG(INTERPRETER, "SetArrayElement %p %llu %p", source, index, new_value);
    MArray* array = static_cast<MArray*>(source);
    array->SetRefElement(index, static_cast<BaseObject*>(new_value));
}

void ReadStructFieldOfObjectImpl(MAddress dstPtr, DYN_ObjRef obj, MAddress srcField, size_t size)
{
    DLOG(INTERPRETER, "ReadStructFieldOfObject %p %p %p %zu", dstPtr, obj, srcField, size);
    if (size == 0) {
        return;
    }
    Heap::GetHeap().GetBarrier().ReadStruct(dstPtr, static_cast<BaseObject*>(obj), srcField, size);
}

void ReadStructFieldOfObject(uintptr_t dstPtr, DYN_ObjRef obj, uintptr_t srcField, size_t size)
{
    ReadStructFieldOfObjectImpl(ToMAddress(dstPtr), obj, ToMAddress(srcField), size);
}

void WriteStructFieldOfObjectImpl(DYN_ObjRef obj, MAddress dst, MAddress src, size_t size)
{
    DLOG(INTERPRETER, "WriteStructFieldOfObject %p %p %p %zu", obj, dst, src, size);
    CHECK_DETAIL((dst != 0u && src != 0u), "MCC_WriteStructField wrong parameter, dst: %p src: %p", dst, src);
    if (UNLIKELY(!Heap::IsHeapAddress(obj))) {
        CHECK_DETAIL(
            memcpy_s(reinterpret_cast<void*>(dst), size, reinterpret_cast<void*>(src), size) == EOK, "memcpy_s failed");
        return;
    }
    Heap::GetBarrier().WriteStruct(static_cast<BaseObject*>(obj), dst, size, src, size);
}

void WriteStructFieldOfObject(DYN_ObjRef obj, uintptr_t dst, uintptr_t src, size_t size)
{
    WriteStructFieldOfObjectImpl(obj, ToMAddress(dst), ToMAddress(src), size);
}

void ReadStaticStructFieldImpl(MAddress dstPtr, size_t dstSize, MAddress srcPtr, size_t srcSize, DYN_GCTib tib)
{
    DLOG(INTERPRETER, "ReadStaticStructField dst=%p size=%zu src=%p size=%zu tib_val=%zx", dstPtr, dstSize, srcPtr,
        srcSize, static_cast<size_t>(tib.raw));

    GCTib gcTib = *reinterpret_cast<GCTib*>(&tib);
    Heap::GetHeap().GetBarrier().ReadStaticStruct(dstPtr, srcPtr, dstSize, gcTib);
}

void ReadStaticStructField(uintptr_t dstPtr, size_t dstSize, uintptr_t srcPtr, size_t srcSize, DYN_GCTib tib)
{
    ReadStaticStructFieldImpl(ToMAddress(dstPtr), dstSize, ToMAddress(srcPtr), srcSize, tib);
}

void WriteStaticStructFieldImpl(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, DYN_GCTib tib)
{
    DLOG(INTERPRETER, "WriteStaticStructField dst=%p size=%zu src=%p size=%zu tib_val=%zx", dst, dstLen, src, srcLen,
        static_cast<size_t>(tib.raw));

    CHECK_DETAIL((dst != 0u && src != 0u), "WriteStaticStructField wrong parameter, dst: %p src: %p", dst, src);

    GCTib gcTib = *reinterpret_cast<GCTib*>(&tib);
    Heap::GetBarrier().WriteStaticStruct(dst, dstLen, src, srcLen, gcTib);
}

void WriteStaticStructField(uintptr_t dst, size_t dstLen, uintptr_t src, size_t srcLen, DYN_GCTib tib)
{
    WriteStaticStructFieldImpl(ToMAddress(dst), dstLen, ToMAddress(src), srcLen, tib);
}

void ReadGenericField(DYN_ObjRef dst, DYN_ObjRef srcObj, uintptr_t srcField, size_t size)
{
    DLOG(INTERPRETER, "ReadGenericField dst=%p srcObj=%p srcField=%p size=%zu", dst, srcObj, srcField, size);

    if (size == 0) {
        return;
    }

    Heap::GetBarrier().ReadGeneric(
        static_cast<BaseObject*>(dst), static_cast<BaseObject*>(srcObj), reinterpret_cast<void*>(srcField), size);
}

void WriteGenericField(DYN_ObjRef dstObj, uintptr_t dstField, DYN_ObjRef src, size_t size)
{
    DLOG(INTERPRETER, "WriteGenericField dstObj=%p dstField=%p src=%p size=%zu", dstObj, dstField, src, size);

    if (src == nullptr || size == 0) {
        return;
    }

    Heap::GetBarrier().WriteGeneric(
        static_cast<BaseObject*>(dstObj), reinterpret_cast<void*>(dstField), static_cast<BaseObject*>(src), size);
}

DYN_ThreadLocalData GetThreadLocalData()
{
    return reinterpret_cast<DYN_ThreadLocalData>(MRT_GetThreadLocalData());
}

int IsActiveGCPhase(DYN_ThreadLocalData tld)
{
    ThreadLocalData* threadLocalData = static_cast<ThreadLocalData*>(tld);
    if (threadLocalData == nullptr) {
        return 0;
    }
    Mutator* mutator = threadLocalData->mutator;
    if (mutator == nullptr) {
        return 0;
    }
    return mutator->GetMutatorPhase() >= GCPhase::GC_PHASE_ENUM ? 1 : 0;
}

DYN_ExceptionWrapper GetExceptionWrapper()
{
    DLOG(INTERPRETER, "GetExceptionWrapper");
    return static_cast<DYN_ExceptionWrapper>(ExceptionManager::GetExceptionWrapper());
}

extern "C" uintptr_t GetCurrentCatchFunctionPC()
{
    Mutator* mutator = Mutator::GetMutator();
    if (mutator == nullptr) {
        return 0;
    }
    ExceptionWrapper& eWrapper = mutator->GetExceptionWrapper();
    return eWrapper.GetCurrentCatchFunctionPC();
}

void* PostThrowException(DYN_ExceptionWrapper exception_wrapper)
{
    DLOG(INTERPRETER, "PostThrowException %p", exception_wrapper);
    ExceptionWrapper* wrapper = static_cast<ExceptionWrapper*>(exception_wrapper);
    return ExceptionManager::BeginCatch(wrapper);
}

void NativeLogger(int logLevel, char* tag, char* message)
{
    const char* logTag = tag != nullptr ? tag : "interpreter";
    const char* logMessage = message != nullptr ? message : "(null)";
    VLOG(static_cast<LogType>(logLevel), "[%s] %s", logTag, logMessage);
}

size_t ComputeCJThreadDataOffset()
{
    union MutatorTmpContainer {
        MutatorTmpContainer()
        {
        }
        ~MutatorTmpContainer()
        {
        }
        Mutator mutator;
    } tmp;
    const auto* mutatorAddress = reinterpret_cast<const uint8_t*>(&tmp.mutator);
    const auto* cjThreadDataAddress = reinterpret_cast<const uint8_t*>(&tmp.mutator.interpreterCJThreadData);
    return static_cast<size_t>(cjThreadDataAddress - mutatorAddress);
}

void LogInterpreterParam(const InterpreterParam& interpreterParam)
{
    const char* libName = interpreterParam.interpreterLibName;
    const int argsCount = interpreterParam.interpreterArgsCount;
    INT_InterpreterArgs args = interpreterParam.interpreterArgs;

    VLOG(INTERPRETER, "Interpreter parameter:\n\tInterpreter library: %s\n\tInterpreter arguments count: %d",
        libName != nullptr ? libName : "(null)", argsCount);
    if (args != nullptr && argsCount > 0) {
        for (int i = 0; i < argsCount; ++i) {
            VLOG(INTERPRETER, "\tInterpreter argument #%d: %s", i, args[i] != nullptr ? args[i] : "(null)");
        }
    }
}

bool IsValidInterpreterLibName(const char* libName)
{
    if (libName == nullptr || std::strlen(libName) == 0) {
        DLOG(INTERPRETER, "interpreter library name is empty, interpreter could not be initialized");
        return false;
    }
    return true;
}

void* LoadInterpreterLibrary(const char* libName)
{
#if defined(__OHOS__)
    return LoaderManager::GetInstance()->LoadInterpreter(libName);
#else
    return dlopen(libName, RTLD_LAZY);
#endif
}

INT_InitInterpreter ResolveInterpreterInit(void* interpreterLibHandle)
{
    void* sym = dlsym(interpreterLibHandle, "interpreter_bridge_init");
    if (sym == nullptr) {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
        const char* error = dlerror();
        DLOG(INTERPRETER, "dlsym interpreter_bridge_init failed: %s", error != nullptr ? error : "unknown error");
#endif
        return nullptr;
    }
    return reinterpret_cast<INT_InitInterpreter>(sym);
}

DYN_CJNativeInterface CreateCJNativeInterface(void* symbolHandle)
{
    DYN_I2NStubFn i2nStub = reinterpret_cast<DYN_I2NStubFn>(&CJ_MCC_I2NStub);

    DYN_CJNativeInterface cjnativeInterface = {
        .version = DYN_CJNATIVE_INTERFACE_VERSION,
        .appLibHandle = symbolHandle,
        .carrierSpecificOffset = offsetof(ThreadLocalData, mutator),
        .cjThreadSpecificOffset = ComputeCJThreadDataOffset(),
        .newCJThread = &NewCJThread,
        .typeInfo = &TypeInfoProvider,
        .typeTemplate = &FindTypeTemplate,
        .getOrCreateTypeInfo = &GetOrCreateTypeInfo,
        .getInstanceSize = &GetInstanceSize,
        .getMTable = &GetMTable,
        .getMethodOuterTI = &GetMethodOuterTI,
        .updateVMT = &UpdateVMT,
        .getTypeInfoUUID = &GetTypeInfoUUID,
        .objectAlloc = &ObjectAllocate,
        .arrayAlloc = &ArrayAllocate,
        .safePoint = &SafePoint,
        .isPendingSafePoint = &IsPendingSafePoint,
        .throwException = &ThrowException,
        .throwOom = &ThrowOutOfMemoryError,
        .getPendingException = &GetPendingException,
        .getAndClearPendingException = &GetAndClearPendingException,
        .getExceptionWrapper = &GetExceptionWrapper,
        .postThrowException = &PostThrowException,
        .getCurrentCatchFunctionPc = &GetCurrentCatchFunctionPC,
        .instanceOf = &InstanceOf,
        .isSubType = &IsSubType,
        .visitRootFromInterpreter = &VisitRootFromInterpreter,
        .visitDerivedPtrFromInterpreter = &VisitDerivedPtrFromInterpreter,
        .readStaticField = &ReadStaticField,
        .writeStaticField = &WriteStaticField,
        .readInstanceField = &ReadInstanceField,
        .writeInstanceField = &WriteInstanceField,
        .readStructField = &ReadStructFieldOfObject,
        .writeStructField = &WriteStructFieldOfObject,
        .readStaticStructField = &ReadStaticStructField,
        .writeStaticStructField = &WriteStaticStructField,
        .readGenericField = &ReadGenericField,
        .writeGenericField = &WriteGenericField,
        .arrayBodyOffset = static_cast<size_t>(MArray::GetContentOffset()),
        .getArrayRefElement = &GetArrayElement,
        .setArrayRefElement = &SetArrayElement,
        .getThreadLocalData = &GetThreadLocalData,
        .isActiveGcPhase = &IsActiveGCPhase,
        .stackGrowStub = reinterpret_cast<DYN_StackGrowStubFn>(&CJ_MCC_StackGrowStub),
        .i2nStub = i2nStub,
        .nativeLogger = &NativeLogger,
    };
    return cjnativeInterface;
}

RTErrorCode InitializeInterpreterInterface(
    INT_InitInterpreter init, DYN_CJNativeInterface& cjnativeInterface, const InterpreterParam& interpreterParam)
{
    INT_InterpreterInterface interpreterInterface{};
    interpreterInterface.version = INT_INTERPRETER_INTERFACE_VERSION;

    int code = init(&interpreterInterface, &cjnativeInterface, interpreterParam.interpreterArgsCount,
        interpreterParam.interpreterArgs);
    if (code != 0) {
        DLOG(INTERPRETER, "interpreter_bridge_init failed, return code: %d", code);
        return E_FAILED;
    }
    if (interpreterInterface.version != INT_INTERPRETER_INTERFACE_VERSION) {
        DLOG(INTERPRETER, "unsupported interpreter interface version: %lld, expected: %d",
            static_cast<long long>(interpreterInterface.version), INT_INTERPRETER_INTERFACE_VERSION);
        return E_FAILED;
    }
    g_interpreterInterface.initialize(interpreterInterface);
    return E_OK;
}

RTErrorCode InitInterpreter(const InterpreterParam& interpreterParam)
{
    LogInterpreterParam(interpreterParam);
    const char* libName = interpreterParam.interpreterLibName;
    if (!IsValidInterpreterLibName(libName)) {
        return E_ARGS;
    }

    void* interpreterLibHandle = LoadInterpreterLibrary(libName);
    if (interpreterLibHandle == nullptr) {
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
        const char* error = dlerror();
        DLOG(INTERPRETER, "interpreter library could not be loaded: %s, error: %s",
            libName, error != nullptr ? error : "unknown error");
#endif
        return E_FAILED;
    }

    INT_InitInterpreter init = ResolveInterpreterInit(interpreterLibHandle);
    if (init == nullptr) {
        return E_FAILED;
    }

    StackManager::InitAddressScopeForInterpreter(libName, reinterpret_cast<const void*>(init));

    DYN_CJNativeInterface cjnativeInterface = CreateCJNativeInterface(interpreterParam.appLibHandle);
    return InitializeInterpreterInterface(init, cjnativeInterface, interpreterParam);
}

bool IsC2IStubAddr(const uintptr_t address)
{
    if (!g_interpreterInterface) {
        return false;
    }
    bool res = g_interpreterInterface->c2iStubStartAddr <= address && address < g_interpreterInterface->c2iStubEndAddr;
    DLOG(INTERPRETER, "Checking c2i virtual executor borders: is %p in [%p, %p)? -- %s", address,
        g_interpreterInterface->c2iStubStartAddr, g_interpreterInterface->c2iStubEndAddr, res ? "true" : "false");
    return res;
}

bool IsI2IAdapterStartAddr(const uintptr_t address)
{
    if (!g_interpreterInterface) {
        return false;
    }
    bool res =
        g_interpreterInterface->i2iAdapterStartAddr <= address && address < g_interpreterInterface->i2iAdapterEndAddr;
    DLOG(INTERPRETER, "Checking i2i function borders: is %p in [%p, %p)? -- %s", address,
        g_interpreterInterface->i2iAdapterStartAddr, g_interpreterInterface->i2iAdapterEndAddr, res ? "true" : "false");
    return res;
}

bool IsI2NStubAddr(const uintptr_t address)
{
    uintptr_t i2nStubStartAddr = reinterpret_cast<uintptr_t>(&CJ_MCC_I2NStub);
    uintptr_t i2nStubEndAddr = reinterpret_cast<uintptr_t>(&CJ_MCC_I2NStubEnd);
    bool res = i2nStubStartAddr <= address && address < i2nStubEndAddr;
    DLOG(INTERPRETER, "Checking I2N stub borders: is %p in [%p, %p)? -- %s", address, i2nStubStartAddr, i2nStubEndAddr,
        res ? "true" : "false");
    return res;
}

uintptr_t GetCommonInterpreterLandingPad()
{
    if (!g_interpreterInterface) {
        return 0;
    }
    DLOG(INTERPRETER, "GetCommonInterpreterLandingPad: %p", g_interpreterInterface->landingPad);
    return reinterpret_cast<uintptr_t>(g_interpreterInterface->landingPad);
}

} // namespace MapleRuntime

#endif // INTERPRETER_ENABLED
