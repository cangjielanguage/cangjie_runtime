// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef COMMON_ALIAS_SRC
#define COMMON_ALIAS_SRC

extern "C" MRT_EXPORT ObjRef CJ_MCC_OnFinalizerCreated(ObjRef ref) __attribute__((alias("MCC_OnFinalizerCreated")));
extern "C" MRT_EXPORT void CJ_MCC_AddLocalFinalizer(ObjectPtr obj)
    __attribute__((alias("MCC_AddLocalFinalizer")));
extern "C" MRT_EXPORT void CJ_MCC_RemoveLocalFinalizer(ObjectPtr obj)
    __attribute__((alias("MCC_RemoveLocalFinalizer")));
extern "C" MRT_EXPORT void CJ_MCC_WriteRefField(const ObjectPtr ref, const ObjectPtr obj, RefField<false>* field)
    __attribute__((alias("MCC_WriteRefField")));

extern "C" MRT_EXPORT void CJ_MCC_WriteStructField(const ObjectPtr obj, MAddress dst, size_t dstLen,
                                                   MAddress src, size_t srcLen)
    __attribute__((alias("MCC_WriteStructField")));

extern "C" MRT_EXPORT void CJ_MCC_WriteStaticRef(const ObjectPtr ref, RefField<false>* field)
    __attribute__((alias("MCC_WriteStaticRef")));
extern "C" MRT_EXPORT void CJ_MCC_WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen,
                                                    const GCTib gcTib) __attribute__((alias("MCC_WriteStaticStruct")));
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                                     RefField<false>* field)
    __attribute__((alias("MCC_MaybeLocalWriteRef")));
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteStruct(const ObjectPtr obj, MAddress dst, size_t dstLen,
                                                        MAddress src, size_t srcLen, GCTib gctib)
    __attribute__((alias("MCC_MaybeLocalWriteStruct")));
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteGeneric(const ObjectPtr obj, void* fieldPtr,
                                                          const ObjectPtr src, size_t size)
    __attribute__((alias("MCC_MaybeLocalWriteGeneric")));
extern "C" MRT_EXPORT void CJ_MCC_DemodeWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                                  RefField<false>* field)
    __attribute__((alias("MCC_DemodeWriteRef")));
extern "C" MRT_EXPORT void CJ_MCC_AtomicWriteReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                                       MemoryOrder order)
    __attribute__((alias("MCC_AtomicWriteReference")));

extern "C" MRT_EXPORT __attribute__((alias("MCC_AtomicReadReference")))
    ObjectPtr CJ_MCC_AtomicReadReference(const ObjectPtr obj, RefField<true>* field, MemoryOrder order);

extern "C" MRT_EXPORT ObjectPtr CJ_MCC_AtomicSwapReference(const ObjectPtr ref, const ObjectPtr obj,
                                                           RefField<true>* field, MemoryOrder order)
    __attribute__((alias("MCC_AtomicSwapReference")));
extern "C" MRT_EXPORT bool CJ_MCC_AtomicCompareAndSwapReference(const ObjectPtr oldRef, const ObjectPtr newRef,
                                                                const ObjectPtr obj, RefField<true>* field,
                                                                MemoryOrder succOrder, MemoryOrder failOrder)
    __attribute__((alias("MCC_AtomicCompareSwapReference")));
extern "C" MRT_EXPORT void CJ_MCC_InvokeGCImpl(bool sync) __attribute__((alias("MCC_InvokeGCImpl")));
extern "C" MRT_EXPORT ssize_t CJ_MCC_GetRealHeapSize()
    __attribute__((alias("MCC_GetRealHeapSize")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetAllocatedHeapSize() __attribute__((alias("MCC_GetAllocatedHeapSize")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetAllocatedLocalObjectSize()
    __attribute__((alias("MCC_GetAllocatedLocalObjectSize")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetMaxHeapSize() __attribute__((alias("MCC_GetMaxHeapSize")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetCJThreadNumber() __attribute__((alias("MCC_GetCJThreadNumber")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetBlockingCJThreadNumber() __attribute__((alias("MCC_GetBlockingCJThreadNumber")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetNativeThreadNumber() __attribute__((alias("MCC_GetNativeThreadNumber")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetGCCount() __attribute__((alias("MCC_GetGCCount")));
extern "C" MRT_EXPORT bool CJ_MCC_IsGCRunning() __attribute__((alias("MCC_IsGCRunning")));
extern "C" MRT_EXPORT uint64_t CJ_MCC_GetGCTimeUs() __attribute__((alias("MCC_GetGCTimeUs")));
extern "C" MRT_EXPORT size_t CJ_MCC_GetGCFreedSize() __attribute__((alias("MCC_GetGCFreedSize")));
extern "C" MRT_EXPORT size_t CJ_MCC_StartCpuProfiling() __attribute__((alias("MCC_StartCpuProfiling")));
extern "C" MRT_EXPORT size_t CJ_MCC_StopCpuProfiling(int fd) __attribute__((alias("MCC_StopCpuProfiling")));
extern "C" MRT_EXPORT void CJ_MCC_SetGCThreshold(uint64_t GCThreshold) __attribute__((alias("MCC_SetGCThreshold")));
extern "C" MRT_EXPORT void* CJ_MCC_PostThrowException(ExceptionWrapper* mExceptionWrapper)
    __attribute__((alias("MCC_PostThrowException")));

#if !defined(ENABLE_BACKWARD_PTRAUTH_CFI)
extern "C" MRT_EXPORT MRT_OPTIONAL_BRANCH_PROTECT_NONE
void CJ_MCC_ThrowException(ExceptionRef exception) __attribute__((alias("MCC_ThrowException")));
#endif

extern "C" MRT_EXPORT void CJ_MCC_RegisterImplicitExceptionRaisers(void* raiser)
    __attribute__((alias("MCC_RegisterImplicitExceptionRaisers")));
extern "C" MRT_EXPORT void* CJ_MCC_GetExceptionWrapper() __attribute__((alias("MCC_GetExceptionWrapper")));
extern "C" MRT_EXPORT uint32_t CJ_MCC_GetExceptionTypeID() __attribute__((alias("MCC_GetExceptionTypeID")));
extern "C" MRT_EXPORT void CJ_MCC_EndCatch() __attribute__((alias("MCC_EndCatch")));

extern "C" MRT_EXPORT ArrayRef CJ_MCC_FillInStackTraceImpl(const TypeInfo* arrayInfo, const ArrayRef exceptionMessage)
    __attribute__((alias("MCC_FillInStackTraceImpl")));
extern "C" MRT_EXPORT void CJ_MCC_ReleaseRawData(ArrayRef array, void* rawPtr)
    __attribute__((alias("MCC_ReleaseRawData")));

extern "C" MRT_EXPORT TypeTemplate* CJ_MCC_GetTypeTemplate(char* name) __attribute__((alias("MCC_GetTypeTemplate")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetOrCreateTypeInfoForReflect(TypeTemplate* tt, void* args)
    __attribute__((alias("MCC_GetOrCreateTypeInfoForReflect")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetObjClass(const ObjectPtr obj) __attribute__((alias("MCC_GetObjClass")));

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetTypeForAny(const ObjectPtr obj) __attribute__((alias("MCC_GetTypeForAny")));

extern "C" MRT_EXPORT bool CJ_MCC_IsWrapperClassForAutoEnv(TypeInfo* ti)
    __attribute__((alias("MCC_IsWrapperClassForAutoEnv")));

// for dynamic loader
extern "C" MRT_EXPORT void* CJ_MCC_LoadPackage(const char* path) __attribute__((alias("MCC_LoadPackage")));

extern "C" MRT_EXPORT PackageInfo* CJ_MCC_GetPackageByQualifiedName(const char* packageName)
    __attribute__((alias("MCC_GetPackageByQualifiedName")));

extern "C" MRT_EXPORT const char* CJ_MCC_GetPackageVersion(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetPackageVersion")));

extern "C" MRT_EXPORT void* CJ_MCC_GetSubPackages(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetSubPackages")));

extern "C" MRT_EXPORT PackageInfo* CJ_MCC_GetRelatedPackageInfo(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetRelatedPackageInfo")));

extern "C" MRT_EXPORT char* CJ_MCC_GetPackageName(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetPackageName")));
extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfTypeInfos(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetNumOfTypeInfos")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetPackageTypeInfo(PackageInfo* packageInfo, U32 index)
    __attribute__((alias("MCC_GetPackageTypeInfo")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfGlobalMethodInfos(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetPackageNumOfGlobalMethodInfos")));
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetPackageGlobalMethodInfo(PackageInfo* packageInfo, U32 index)
    __attribute__((alias("MCC_GetPackageGlobalMethodInfo")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfGlobalFieldInfos(PackageInfo* packageInfo)
    __attribute__((alias("MCC_GetPackageNumOfGlobalFieldInfos")));
extern "C" MRT_EXPORT InstanceFieldInfo* CJ_MCC_GetPackageGlobalFieldInfo(PackageInfo* packageInfo, U32 index)
    __attribute__((alias("MCC_GetPackageGlobalFieldInfo")));

// for reflect, method
extern "C" MRT_EXPORT const char* CJ_MCC_GetMethodName(MethodInfo* methodInfo)
    __attribute__((alias("MCC_GetMethodName")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetMethodReturnType(MethodInfo* methodInfo)
    __attribute__((alias("MCC_GetMethodReturnType")));
extern "C" MRT_EXPORT U32 CJ_MCC_GetMethodModifier(MethodInfo* methodInfo)
    __attribute__((alias("MCC_GetMethodModifier")));
extern "C" MRT_EXPORT U32 CJ_MCC_MethodEntryPointIsNull(MethodInfo* methodInfo)
    __attribute__((alias("MCC_MethodEntryPointIsNull")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfActualParameters(MethodInfo* methodInfo)
    __attribute__((alias("MCC_GetNumOfActualParameters")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfGenericParameters(MethodInfo* methodInfo)
    __attribute__((alias("MCC_GetNumOfGenericParameters")));

extern "C" MRT_EXPORT ParameterInfoRef CJ_MCC_GetActualParameterInfo(MethodInfo* methodInfo, U32 index)
    __attribute__((alias("MCC_GetActualParameterInfo")));

extern "C" MRT_EXPORT GenericTypeInfo* CJ_MCC_GetGenericParameterInfo(MethodInfo* methodInfo, U32 index)
    __attribute__((alias("MCC_GetGenericParameterInfo")));

extern "C" MRT_EXPORT GenericTypeInfo* CJ_MCC_CheckMethodActualArgs(MethodInfo* methodInfo,
    void* genericArgs, void* args) __attribute__((alias("MCC_CheckMethodActualArgs")));

// for reflect, field
extern "C" MRT_EXPORT const char* CJ_MCC_GetInstanceFieldName(InstanceFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetInstanceFieldName")));
extern "C" MRT_EXPORT const char* CJ_MCC_GetStaticFieldName(StaticFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetStaticFieldName")));

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetInstanceFieldType(InstanceFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetInstanceFieldType")));

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetStaticFieldType(InstanceFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetStaticFieldType")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetInstanceFieldModifier(InstanceFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetInstanceFieldModifier")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetStaticFieldModifier(InstanceFieldInfo* fieldInfo)
    __attribute__((alias("MCC_GetStaticFieldModifier")));

extern "C" MRT_EXPORT void CJ_MCC_SetInstanceFieldValue(InstanceFieldInfo* fieldInfo, ObjRef obj, ObjRef newValue)
    __attribute__((alias("MCC_SetInstanceFieldValue")));
extern "C" MRT_EXPORT void CJ_MCC_SetStaticFieldValue(InstanceFieldInfo* fieldInfo, ObjRef value)
    __attribute__((alias("MCC_SetStaticFieldValue")));

// reflect, class/struct
// for find
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_getTypeByQualifiedName(const char* qualifiedName)
    __attribute__((alias("MCC_GetTypeByQualifiedName")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetTypeByMangledName(const char* mangledName)
    __attribute__((alias("MCC_GetTypeByMangledName")));
extern "C" MRT_EXPORT const char* CJ_MCC_GetTypeName(TypeInfo* ti) __attribute__((alias("MCC_GetTypeName")));
extern "C" MRT_EXPORT bool CJ_MCC_IsClass(TypeInfo* ti) __attribute__((alias("MCC_IsClass")));
extern "C" MRT_EXPORT bool CJ_MCC_IsInterface(TypeInfo* ti) __attribute__((alias("MCC_IsInterface")));
extern "C" MRT_EXPORT bool CJ_MCC_IsStruct(TypeInfo* ti) __attribute__((alias("MCC_IsStruct")));
extern "C" MRT_EXPORT bool CJ_MCC_IsPrimitive(TypeInfo* ti) __attribute__((alias("MCC_IsPrimitive")));
extern "C" MRT_EXPORT bool CJ_MCC_IsGeneric(TypeInfo* ti) __attribute__((alias("MCC_IsGeneric")));
extern "C" MRT_EXPORT bool CJ_MCC_IsEnum(TypeInfo* ti) __attribute__((alias("MCC_IsEnum")));
extern "C" MRT_EXPORT bool CJ_MCC_IsFunction(TypeInfo* ti) __attribute__((alias("MCC_IsFunction")));
extern "C" MRT_EXPORT bool CJ_MCC_IsTuple(TypeInfo* ti) __attribute__((alias("MCC_IsTuple")));
extern "C" MRT_EXPORT bool CJ_MCC_IsReflectUnsupportedType(TypeInfo* ti)
    __attribute__((alias("MCC_IsReflectUnsupportedType")));

extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetFunctionSignatureTypes(TypeInfo* funcTi)
    __attribute__((alias("MCC_GetFunctionSignatureTypes")));
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfFunctionSignatureTypes(TypeInfo* funcTi)
    __attribute__((alias("MCC_GetNumOfFunctionSignatureTypes")));

// for enum
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfEnumConstructorInfos(TypeInfo* ti)
    __attribute__((alias("MCC_GetNumOfEnumConstructorInfos")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetEnumConstructorInfo(TypeInfo* ti, U32 idx)
    __attribute__((alias("MCC_GetEnumConstructorInfo")));
extern "C" MRT_EXPORT const char* CJ_MCC_GetEnumConstructorName(EnumCtorInfo* ti)
    __attribute__((alias("MCC_GetEnumConstructorName")));
extern "C" MRT_EXPORT EnumCtorInfo* CJ_MCC_GetEnumConstructorInfoFromAny(ObjRef obj)
    __attribute__((alias("MCC_GetEnumConstructorInfoFromAny")));
extern "C" MRT_EXPORT bool CJ_MCC_IsBox(TypeInfo* ti)
    __attribute__((alias("MCC_IsBox")));
extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetTypeArgs(TypeInfo* ti)
    __attribute__((alias("MCC_GetTypeArgs")));

// for tuple
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfFieldTypes(TypeInfo* ti)
    __attribute__((alias("MCC_GetNumOfFieldTypes")));
extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetFieldTypes(TypeInfo* ti)
    __attribute__((alias("MCC_GetFieldTypes")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetQualifiedNameLength(TypeInfo* ti)
    __attribute__((alias("MCC_GetQualifiedNameLength")));
extern "C" MRT_EXPORT void CJ_MCC_GetQualifiedName(TypeInfo* ti, char* qualifiedName)
    __attribute__((alias("MCC_GetQualifiedName")));
extern "C" MRT_EXPORT U32 CJ_MCC_GetTypeInfoModifier(TypeInfo* ti) __attribute__((alias("MCC_GetTypeInfoModifier")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetSuperTypeInfo(TypeInfo* ti) __attribute__((alias("MCC_GetSuperTypeInfo")));

extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInterface(TypeInfo* ti)
    __attribute__((alias("MCC_GetNumOfInterface")));

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetInterface(TypeInfo* ti, U32 index)
    __attribute__((alias("MCC_GetInterface")));

// InstanceMemberFunctionInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInstanceMethodInfos(TypeInfo* cls)
    __attribute__((alias("MCC_GetNumOfInstanceMethodInfos")));
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetInstanceMethodInfo(TypeInfo* cls, U32 index)
    __attribute__((alias("MCC_GetInstanceMethodInfo")));

// StaticMemberFunctionInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfStaticMethodInfos(TypeInfo* cls)
    __attribute__((alias("MCC_GetNumOfStaticMethodInfos")));
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetStaticMethodInfo(TypeInfo* cls, U32 index)
    __attribute__((alias("MCC_GetStaticMethodInfo")));

// InstanceMemberVariableInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInstanceFieldInfos(TypeInfo* cls)
    __attribute__((alias("MCC_GetNumOfInstanceFieldInfos")));
extern "C" MRT_EXPORT InstanceFieldInfo* CJ_MCC_GetInstanceFieldInfo(TypeInfo* cls, U32 index)
    __attribute__((alias("MCC_GetInstanceFieldInfo")));

// StaticMemberVariableInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfStaticFieldInfos(TypeInfo* cls)
    __attribute__((alias("MCC_GetNumOfStaticFieldInfos")));
extern "C" MRT_EXPORT StaticFieldInfo* CJ_MCC_GetStaticFieldInfo(TypeInfo* cls, U32 index)
    __attribute__((alias("MCC_GetStaticFieldInfo")));

// reflect, parameter
extern "C" MRT_EXPORT const char* CJ_MCC_GetParameterName(ParameterInfoRef parameterInfo)
    __attribute__((alias("MCC_GetParameterName")));
extern "C" MRT_EXPORT U32 CJ_MCC_GetParameterIndex(ParameterInfoRef parameterInfo)
    __attribute__((alias("MCC_GetParameterIndex")));
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetParameterType(ParameterInfoRef parameterInfo)
    __attribute__((alias("MCC_GetParameterType")));
#endif
