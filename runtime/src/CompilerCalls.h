// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_COMPILER_CALLS_H
#define MRT_COMPILER_CALLS_H

#include "Cangjie.h"
#include "Common/BaseObject.h"
#include "Common/StackType.h"
#include "Common/TypeDef.h"
#include "ObjectModel/Field.h"
#include "ObjectModel/FieldInfo.h"
#include "ObjectModel/MClass.h"
#include "ObjectModel/MethodInfo.h"
#include "ObjectModel/PackageInfo.h"
#include "ObjectModel/RefField.h"
#ifndef _WIN64
#include "Signal/SignalStack.h"
#endif

// runtime interfaces provided to compiler for code generation.
// The compiler should only call MCC_* to access runtime functions.
// MCC_* calls follows C standard calling convention.
namespace MapleRuntime {
// create new objects
extern "C" ObjRef MCC_NewObject(const TypeInfo* classInfo, MSize size);
extern "C" ObjRef MCC_NewPinnedObject(const TypeInfo* classInfo, MSize size, bool isFinalizer);
extern "C" ObjRef MCC_NewFinalizer(const TypeInfo* classInfo, MSize size);
extern "C" ObjRef MCC_OnFinalizerCreated(ObjRef ref);
extern "C" ObjRef MCC_NewPinnedObject(const TypeInfo* classInfo, MSize size, bool isFinalizer);
extern "C" void MCC_WriteRefField(const ObjectPtr ref, const ObjectPtr obj, RefField<false>* field);
extern "C" void MCC_WriteStructField(const ObjectPtr obj, MAddress dst, size_t dstLen, MAddress src, size_t srcLen,
                                     GCTib gctib);
extern "C" void MCC_WriteStaticRef(const ObjectPtr ref, RefField<false>* field);
extern "C" void MCC_WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen, const GCTib gcTib);
extern "C" MRT_EXPORT void MCC_MaybeLocalWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                                  RefField<false>* field);
extern "C" MRT_EXPORT void MCC_MaybeLocalWriteStruct(const ObjectPtr obj, MAddress dst, size_t dstLen,
                                                     MAddress src, size_t srcLen, GCTib gctib);
extern "C" MRT_EXPORT void MCC_MaybeLocalWriteGeneric(const ObjectPtr obj, void* fieldPtr,
                                                       const ObjectPtr src, size_t size);
extern "C" MRT_EXPORT void MCC_DemodeWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                               RefField<false>* field);
extern "C" void MCC_AtomicWriteReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                         MemoryOrder order);
extern "C" ObjectPtr MCC_AtomicReadReference(const ObjectPtr obj, RefField<true>* field, MemoryOrder order);
extern "C" ObjectPtr MCC_AtomicSwapReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                             MemoryOrder order);
extern "C" bool MCC_AtomicCompareSwapReference(const ObjectPtr oldRef, const ObjectPtr newRef, const ObjectPtr obj,
                                               RefField<true>* field, MemoryOrder succOrder, MemoryOrder failOrder);

extern "C" TypeInfo* MCC_GetObjClass(const ObjectPtr obj);

extern "C" TypeInfo* MCC_GetTypeForAny(const ObjectPtr obj);

extern "C" bool MCC_IsWrapperClassForAutoEnv(const TypeInfo* ti);

// Called to trigger one gc task in managed code
extern "C" void MCC_InvokeGCImpl(bool sync);

extern "C" ssize_t MCC_GetRealHeapSize();
extern "C" size_t MCC_GetAllocatedHeapSize();
extern "C" size_t MCC_GetAllocatedLocalObjectSize();
extern "C" size_t MCC_GetMaxHeapSize();
extern "C" bool MCC_DumpCJHeapData(int fd);

extern "C" size_t MCC_GetCJThreadNumber();
extern "C" size_t MCC_GetBlockingCJThreadNumber();
extern "C" size_t MCC_GetNativeThreadNumber();

extern "C" size_t MCC_GetGCCount();
extern "C" uint64_t MCC_GetGCTimeUs();
extern "C" size_t MCC_GetGCFreedSize();
extern "C" bool MCC_IsGCRunning();

extern "C" bool MCC_StartCpuProfiling();
extern "C" bool MCC_StopCpuProfiling(int fd);
// for general array allocation
extern "C" ArrayRef MCC_NewArray(const TypeInfo* arrayInfo, MIndex nElems);

// for object array allocation
extern "C" ArrayRef MCC_NewObjArray(const TypeInfo* arrayInfo, MIndex nElems);

// for array allocation with known const element sizes.
extern "C" ArrayRef MCC_NewArray8(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewArray16(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewArray32(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewArray64(const TypeInfo* classInfo, MIndex nElems);

extern "C" void* MCC_PostThrowException(ExceptionWrapper* mExceptionWrapper);
extern "C" void MCC_ThrowException(ExceptionRef exception);
extern "C" void MCC_RegisterImplicitExceptionRaisers(void* raiser);
extern "C" void* MCC_GetExceptionWrapper();
extern "C" uint32_t MCC_GetExceptionTypeID();
extern "C" void MCC_EndCatch();

extern "C" void MCC_ThrowStackOverflowError(uint32_t size);

extern "C" ArrayRef MCC_FillInStackTraceImpl(const TypeInfo* arrayInfo, const ArrayRef excepMsg);
extern "C" StackTraceData MCC_DecodeStackTraceImpl(const uint64_t ip, const uint64_t pc, const uint64_t funcDesc,
                                                   const TypeInfo* charArray);
extern "C" MRT_EXPORT ArrayRef MCC_GetAllThreadSnapshotImpl(const TypeInfo* arraySnapshot,
                                                            const TypeInfo* arrayStackTrace,
                                                            const TypeInfo* charArray);
extern "C" MRT_EXPORT ThreadSnapshot MCC_GetCurrentThreadSnapshotImpl(const TypeInfo* arrayStackTrace,
                                                                      const TypeInfo* charArray);

enum ReleaseMode : int {
    SYNC = 0, // copy back the content and then free the buffer
    DISCARD,  // do not copy back the content, just free the buffer
};

extern "C" void* MCC_AcquireRawData(const ArrayRef array, bool* isCopy);
extern "C" void MCC_ReleaseRawData(ArrayRef array, void* rawPtr);

extern "C" MRT_EXPORT int32_t __ccc_personality_v0();

// Add prefix "CJ_" to MCC_*.
extern "C" MRT_EXPORT void CJ_MCC_C2NStub(...);
extern "C" MRT_EXPORT void CJ_MCC_N2CStub(...);
extern "C" MRT_EXPORT void CJ_MCC_StackGrowStub(...);
extern "C" MRT_EXPORT void* CJ_MCC_ExclusiveScope(...);
extern "C" MRT_EXPORT ArrayRef CJ_MCC_DecodeStackTrace(const ArrayRef pcArray, const TypeInfo* steObjInfo,
                                                       const TypeInfo* steArrayInfo, const TypeInfo* charArrayInfo);
extern "C" MRT_EXPORT ArrayRef CJ_MCC_GetAllThreadSnapshot(const TypeInfo* arraySnapshot,
                                                           const TypeInfo* arrayStackTrace,
                                                           const TypeInfo* charArray);
extern "C" MRT_EXPORT ThreadSnapshot CJ_MCC_GetCurrentThreadSnapshot(const TypeInfo* arrayStackTrace,
                                                                     const TypeInfo* charArray);
extern "C" MRT_EXPORT void CJ_MCC_HandleSafepoint(...);

#ifdef _WIN64
extern "C" MRT_EXPORT void CJ_MCC_ThrowStackOverflowError();
#else
#ifdef __APPLE__
extern "C" MRT_EXPORT void CJ_MCC_ThrowStackOverflowError(uint32_t size);
__asm__(
    ".global _CJ_MCC_ThrowStackOverflowError\n\t.set _CJ_MCC_ThrowStackOverflowError, _MCC_ThrowStackOverflowError");
#elif !defined(ENABLE_BACKWARD_PTRAUTH_CFI)
extern "C" MRT_EXPORT MRT_OPTIONAL_DISABLE_TAIL_CALL MRT_OPTIONAL_BRANCH_PROTECT_NONE
void CJ_MCC_ThrowStackOverflowError(uint32_t size) __attribute__((alias("MCC_ThrowStackOverflowError")));
#endif
extern "C" MRT_EXPORT sighandler_t CJ_MCC_SignalRegister(int sig, sighandler_t handler);
extern "C" MRT_EXPORT int CJ_MCC_SignalProcMask(int how, const sigset_t* newSet, sigset_t* oldSet);
extern "C" MRT_EXPORT void CJ_MCC_SignalKill(pid_t pid, int sig);
extern "C" MRT_EXPORT void CJ_MCC_SignalRaise(int sig);
extern "C" MRT_EXPORT void CJ_MCC_AddSignalHandler(int signal, struct SignalAction* sa);
extern "C" MRT_EXPORT void CJ_MCC_RemoveSignalHandler(int signal, bool (*fn)(int, siginfo_t*, void*));
#endif

extern "C" MRT_EXPORT void CJ_MCC_ArrayCopy(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                            const ObjectPtr srcObj, MAddress srcField, size_t srcSize);
extern "C" MRT_EXPORT void CJ_MCC_ArrayCopyRef(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                               const ObjectPtr srcObj, MAddress srcField, size_t srcSize);
extern "C" MRT_EXPORT void CJ_MCC_ArrayCopyStruct(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                                  const ObjectPtr srcObj, MAddress srcField, size_t srcSize);
extern "C" MRT_EXPORT ObjectPtr CJ_MCC_ReadRefField(const ObjectPtr obj, RefField<false>* field);
extern "C" MRT_EXPORT ObjectPtr CJ_MCC_ReadWeakRef(const ObjectPtr obj, RefField<false>* field);
extern "C" MRT_EXPORT void CJ_MCC_ReadStructField(MAddress dstPtr, ObjectPtr obj, MAddress srcField, size_t size,
                                                  GCTib gctib);
extern "C" MRT_EXPORT ObjectPtr CJ_MCC_ReadStaticRef(RefField<false>* field);
extern "C" MRT_EXPORT void CJ_MCC_ReadStaticStruct(MAddress dstPtr, size_t dstSize, MAddress srcPtr, size_t srcSize,
                                                   GCTib gctib);
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetOrCreateTypeInfo(TypeTemplate* typeTemplate, U32 argSize,
                                                           TypeInfo* typeArgs[]);
extern "C" MRT_EXPORT bool CJ_MCC_IsSubType(TypeInfo* typeInfo, TypeInfo* superTypeInfo);
extern "C" MRT_EXPORT bool CJ_MCC_IsTupleTypeOf(ObjectPtr obj, TypeInfo* typeInfo, TypeInfo* targetTypeInfo);
extern "C" MRT_EXPORT void CJ_MCC_WriteGeneric(const ObjectPtr obj, void* fieldPtr, const ObjectPtr src, size_t size);
extern "C" MRT_EXPORT void CJ_MCC_AssignGeneric(ObjectPtr dst, ObjectPtr src, TypeInfo* typeInfo);
extern "C" MRT_EXPORT void CJ_MCC_AssignLocalGeneric(ObjectPtr dst, ObjectPtr src, TypeInfo* typeInfo);
extern "C" MRT_EXPORT void CJ_MCC_WriteGenericPayload(ObjectPtr dst, MAddress srcField, size_t srcSize);
extern "C" MRT_EXPORT void CJ_MCC_ReadGeneric(const ObjectPtr dstPtr, ObjectPtr obj, void* fieldPtr, size_t size);
extern "C" MRT_EXPORT FuncPtr* CJ_MCC_GetMTable(TypeInfo* ti, TypeInfo* itf);
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetMethodOuterTI(TypeInfo* ti, TypeInfo* itf, U64 index);
extern "C" MRT_EXPORT void CJ_MCC_UpdateVMT(TypeInfo* ti, TypeInfo* itf, ExtensionData* extensionData);
extern "C" MRT_EXPORT void CJ_MCC_ArrayCopyGeneric(const ObjectPtr dstObj, MAddress dstField, size_t dstSize,
                                                   const ObjectPtr srcObj, MAddress srcField, size_t srcSize);
extern "C" MRT_EXPORT void CJ_MCC_CopyStructField(BaseObject* dstBase, void* dstField, size_t dstLen,
                                                  BaseObject* srcBase, void* srcField, size_t srcLen);

extern "C" void CJ_MCC_IVCallInstrumentation(TypeInfo* cls, const char* callBaseKey);
// interop
extern "C" MRT_EXPORT void CJ_MCC_CrossAccessBarrier(U64 cjExport);
extern "C" MRT_EXPORT U64 CJ_MCC_CreateExportHandle(BaseObject* obj);
extern "C" MRT_EXPORT BaseObject* CJ_MCC_GetExportedRef(U64 id);
extern "C" MRT_EXPORT void CJ_MCC_RemoveExportedRef(U64 id);
extern "C" MRT_EXPORT void CJ_MRT_RolveCycleRef();
#ifdef __OHOS__
extern "C" void* CJ_MRT_ARKTS_CreateEngine();
extern "C" void CJ_MRT_RegisterExceptionCallback(void(*callback)());
#endif

// local region
// start region when enter a cj func
extern "C" MRT_EXPORT void MCC_StartLocalRegion(FrameAddress* ownerFA);
// end region when finish a cj func or exclave
extern "C" MRT_EXPORT void MCC_EndLocalRegion(FrameAddress* ownerFA);
// Compiler contract: Add registers exactly once in the object's owning currentFrame.
// Pair Remove with Add in that same currentFrame, before the frame is closed.
// Runtime Remove also locates the owning active frame if an inner region is active.
extern "C" MRT_EXPORT void MCC_AddLocalFinalizer(ObjectPtr obj);
extern "C" MRT_EXPORT void MCC_RemoveLocalFinalizer(ObjectPtr obj);
// alloc local region object
extern "C" ObjRef MCC_NewLocalObject(const TypeInfo* classInfo, MSize size);
extern "C" ObjRef MCC_NewLocalFinalizer(const TypeInfo* classInfo, MSize size);

extern "C" ArrayRef MCC_NewLocalArray(const TypeInfo* arrayInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewLocalObjArray(const TypeInfo* arrayInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewLocalArray8(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewLocalArray16(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewLocalArray32(const TypeInfo* classInfo, MIndex nElems);
extern "C" ArrayRef MCC_NewLocalArray64(const TypeInfo* classInfo, MIndex nElems);

extern "C" ObjRef MCC_NewLocalGenericObject(const TypeInfo* klass, MSize size);
extern "C" ArrayRef MCC_NewLocalGenericArray(const TypeInfo* arrayInfo, MIndex nElems);

extern "C" ObjRef MCC_NewLocalWeakRefObject(const TypeInfo* klass, MSize size);

#ifdef __APPLE__
#include "MacAlias.h"
#else
#include "CommonAlias.h"
#endif

} // namespace MapleRuntime

#endif // MRT_COMPILER_CALLS_H
