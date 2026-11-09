// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_MAC_ALIAS_H
#define MRT_MAC_ALIAS_H

extern "C" MRT_EXPORT ObjRef CJ_MCC_OnFinalizerCreated(ObjRef ref);
__asm__(".global _CJ_MCC_OnFinalizerCreated\n\t.set _CJ_MCC_OnFinalizerCreated, _MCC_OnFinalizerCreated");
extern "C" MRT_EXPORT void CJ_MCC_AddLocalFinalizer(ObjectPtr obj);
__asm__(".global _CJ_MCC_AddLocalFinalizer\n\t.set _CJ_MCC_AddLocalFinalizer, _MCC_AddLocalFinalizer");
extern "C" MRT_EXPORT void CJ_MCC_RemoveLocalFinalizer(ObjectPtr obj);
__asm__(".global _CJ_MCC_RemoveLocalFinalizer\n\t.set _CJ_MCC_RemoveLocalFinalizer, _MCC_RemoveLocalFinalizer");
extern "C" MRT_EXPORT void CJ_MCC_WriteRefField(const ObjectPtr ref, const ObjectPtr obj, RefField<false>* field);
__asm__(".global _CJ_MCC_WriteRefField\n\t.set _CJ_MCC_WriteRefField, _MCC_WriteRefField");
extern "C" MRT_EXPORT void CJ_MCC_WriteStructField(const ObjectPtr obj, MAddress dst, size_t dstLen, MAddress src,
                                                   size_t srcLen);
__asm__(".global _CJ_MCC_WriteStructField\n\t.set _CJ_MCC_WriteStructField, _MCC_WriteStructField");
extern "C" MRT_EXPORT void CJ_MCC_WriteStaticRef(const ObjectPtr ref, RefField<false>* field);
__asm__(".global _CJ_MCC_WriteStaticRef\n\t.set _CJ_MCC_WriteStaticRef, _MCC_WriteStaticRef");
extern "C" MRT_EXPORT void CJ_MCC_WriteStaticStruct(MAddress dst, size_t dstLen, MAddress src, size_t srcLen,
                                                    const GCTib gcTib);
__asm__(".global _CJ_MCC_WriteStaticStruct\n\t.set _CJ_MCC_WriteStaticStruct, _MCC_WriteStaticStruct");
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                                      RefField<false>* field);
__asm__(".global _CJ_MCC_MaybeLocalWriteRef\n\t.set _CJ_MCC_MaybeLocalWriteRef, _MCC_MaybeLocalWriteRef");
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteStruct(const ObjectPtr obj, MAddress dst, size_t dstLen,
                                                        MAddress src, size_t srcLen, GCTib gctib);
__asm__(".global _CJ_MCC_MaybeLocalWriteStruct\n\t.set _CJ_MCC_MaybeLocalWriteStruct, "
        "_MCC_MaybeLocalWriteStruct");
extern "C" MRT_EXPORT void CJ_MCC_MaybeLocalWriteGeneric(const ObjectPtr obj, void* fieldPtr,
                                                          const ObjectPtr src, size_t size);
__asm__(".global _CJ_MCC_MaybeLocalWriteGeneric\n\t.set _CJ_MCC_MaybeLocalWriteGeneric, "
        "_MCC_MaybeLocalWriteGeneric");
extern "C" MRT_EXPORT void CJ_MCC_DemodeWriteRef(const ObjectPtr value, const ObjectPtr obj,
                                                  RefField<false>* field);
__asm__(".global _CJ_MCC_DemodeWriteRef\n\t.set _CJ_MCC_DemodeWriteRef, _MCC_DemodeWriteRef");

extern "C" MRT_EXPORT void CJ_MCC_AtomicWriteReference(const ObjectPtr ref, const ObjectPtr obj, RefField<true>* field,
                                                       MemoryOrder order);
__asm__(".global _CJ_MCC_AtomicWriteReference\n\t.set _CJ_MCC_AtomicWriteReference, _MCC_AtomicWriteReference");

extern "C" MRT_EXPORT ObjectPtr CJ_MCC_AtomicReadReference(const ObjectPtr ref, const ObjectPtr obj,
                                                           RefField<true>* field, MemoryOrder order);
__asm__(".global _CJ_MCC_AtomicReadReference\n\t.set _CJ_MCC_AtomicReadReference, _MCC_AtomicReadReference");

extern "C" MRT_EXPORT ObjectPtr CJ_MCC_AtomicSwapReference(const ObjectPtr ref, const ObjectPtr obj,
                                                           RefField<true>* field, MemoryOrder order);
__asm__(".global _CJ_MCC_AtomicSwapReference\n\t.set _CJ_MCC_AtomicSwapReference, _MCC_AtomicSwapReference");

extern "C" MRT_EXPORT bool CJ_MCC_AtomicCompareAndSwapReference(const ObjectPtr oldRef, const ObjectPtr newRef,
                                                                const ObjectPtr obj, RefField<true>* field,
                                                                MemoryOrder succOrder, MemoryOrder failOrder);
__asm__(
    ".global _CJ_MCC_AtomicCompareAndSwapReference\n\t.set _CJ_MCC_AtomicCompareAndSwapReference,"
    "_MCC_AtomicCompareSwapReference");
extern "C" MRT_EXPORT void CJ_MCC_InvokeGCImpl(bool sync);
__asm__(".global _CJ_MCC_InvokeGCImpl\n\t.set _CJ_MCC_InvokeGCImpl, _MCC_InvokeGCImpl");
extern "C" MRT_EXPORT ssize_t CJ_MCC_GetRealHeapSize();
__asm__(
    ".global _CJ_MCC_GetRealHeapSize\n\t.set _CJ_MCC_GetRealHeapSize, "
    "_MCC_GetRealHeapSize");
extern "C" MRT_EXPORT size_t CJ_MCC_GetAllocatedHeapSize();
__asm__(".global _CJ_MCC_GetAllocatedHeapSize\n\t.set _CJ_MCC_GetAllocatedHeapSize, _MCC_GetAllocatedHeapSize");
extern "C" MRT_EXPORT size_t CJ_MCC_GetAllocatedLocalObjectSize();
__asm__(".global _CJ_MCC_GetAllocatedLocalObjectSize\n\t.set _CJ_MCC_GetAllocatedLocalObjectSize,"
        " _MCC_GetAllocatedLocalObjectSize");
extern "C" MRT_EXPORT size_t CJ_MCC_GetMaxHeapSize();
__asm__(".global _CJ_MCC_GetMaxHeapSize\n\t.set _CJ_MCC_GetMaxHeapSize, _MCC_GetMaxHeapSize");
extern "C" MRT_EXPORT size_t CJ_MCC_GetCJThreadNumber();
__asm__(".global _CJ_MCC_GetCJThreadNumber\n\t.set _CJ_MCC_GetCJThreadNumber, _MCC_GetCJThreadNumber");
extern "C" MRT_EXPORT size_t CJ_MCC_GetBlockingCJThreadNumber();
__asm__(
    ".global _CJ_MCC_GetBlockingCJThreadNumber\n\t.set _CJ_MCC_GetBlockingCJThreadNumber, "
    "_MCC_GetBlockingCJThreadNumber");
extern "C" MRT_EXPORT size_t CJ_MCC_GetNativeThreadNumber();
__asm__(".global _CJ_MCC_GetNativeThreadNumber\n\t.set _CJ_MCC_GetNativeThreadNumber, _MCC_GetNativeThreadNumber");
extern "C" MRT_EXPORT size_t CJ_MCC_GetGCCount();
__asm__(".global _CJ_MCC_GetGCCount\n\t.set _CJ_MCC_GetGCCount, _MCC_GetGCCount");
extern "C" MRT_EXPORT uint64_t CJ_MCC_GetGCTimeUs();
__asm__(".global _CJ_MCC_GetGCTimeUs\n\t.set _CJ_MCC_GetGCTimeUs, _MCC_GetGCTimeUs");
extern "C" MRT_EXPORT bool CJ_MCC_IsGCRunning();
__asm__(".global _CJ_MCC_IsGCRunning\n\t.set _CJ_MCC_IsGCRunning, _MCC_IsGCRunning");
extern "C" MRT_EXPORT size_t CJ_MCC_GetGCFreedSize();
__asm__(".global _CJ_MCC_GetGCFreedSize\n\t.set _CJ_MCC_GetGCFreedSize, _MCC_GetGCFreedSize");
extern "C" MRT_EXPORT size_t CJ_MCC_StartCpuProfiling();
__asm__(".global _CJ_MCC_StartCpuProfiling\n\t.set _CJ_MCC_StartCpuProfiling, _MCC_StartCpuProfiling");
extern "C" MRT_EXPORT size_t CJ_MCC_StopCpuProfiling(int fd);
__asm__(".global _CJ_MCC_StopCpuProfiling\n\t.set _CJ_MCC_StopCpuProfiling, _MCC_StopCpuProfiling");
extern "C" MRT_EXPORT void CJ_MCC_SetGCThreshold(uint64_t GCThreshold);
__asm__(".global _CJ_MCC_SetGCThreshold\n\t.set _CJ_MCC_SetGCThreshold, _MCC_SetGCThreshold");
extern "C" MRT_EXPORT void* CJ_MCC_PostThrowException(ExceptionWrapper* mExceptionWrapper);
__asm__(".global _CJ_MCC_PostThrowException\n\t.set _CJ_MCC_PostThrowException, _MCC_PostThrowException");
extern "C" MRT_EXPORT void CJ_MCC_ThrowException(ExceptionRef exception);
__asm__(".global _CJ_MCC_ThrowException\n\t.set _CJ_MCC_ThrowException, _MCC_ThrowException");
extern "C" MRT_EXPORT void CJ_MCC_RegisterImplicitExceptionRaisers(void* raiser);
__asm__(
    ".global _CJ_MCC_RegisterImplicitExceptionRaisers\n\t.set _CJ_MCC_RegisterImplicitExceptionRaisers, "
    "_MCC_RegisterImplicitExceptionRaisers");
extern "C" MRT_EXPORT void* CJ_MCC_GetExceptionWrapper();
__asm__(".global _CJ_MCC_GetExceptionWrapper\n\t.set _CJ_MCC_GetExceptionWrapper, _MCC_GetExceptionWrapper");
extern "C" MRT_EXPORT uint32_t CJ_MCC_GetExceptionTypeID();
__asm__(".global _CJ_MCC_GetExceptionTypeID\n\t.set _CJ_MCC_GetExceptionTypeID, _MCC_GetExceptionTypeID");
extern "C" MRT_EXPORT void CJ_MCC_EndCatch();
__asm__(".global _CJ_MCC_EndCatch\n\t.set _CJ_MCC_EndCatch, _MCC_EndCatch");
extern "C" MRT_EXPORT ArrayRef CJ_MCC_FillInStackTraceImpl(const TypeInfo* arrayInfo, const ArrayRef exceptionMessage);
__asm__(".global _CJ_MCC_FillInStackTraceImpl\n\t.set _CJ_MCC_FillInStackTraceImpl, _MCC_FillInStackTraceImpl");
extern "C" MRT_EXPORT void CJ_MCC_ReleaseRawData(ArrayRef array, void* rawPtr);
__asm__(".global _CJ_MCC_ReleaseRawData\n\t.set _CJ_MCC_ReleaseRawData, _MCC_ReleaseRawData");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetObjClass(const ObjectPtr obj);
__asm__(".global _CJ_MCC_GetObjClass\n\t.set _CJ_MCC_GetObjClass, _MCC_GetObjClass");

extern "C" MRT_EXPORT TypeTemplate* CJ_MCC_GetTypeTemplate(char* name);
__asm__(".global _CJ_MCC_MCC_GetTypeTemplate\n\t.set _CJ_MCC_GetTypeTemplate, _MCC_GetTypeTemplate");

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetOrCreateTypeInfoForReflect(TypeTemplate* tt, void* args);
__asm__(".global _CJ_MCC_GetOrCreateTypeInfoForReflect\n\t.set _CJ_MCC_GetOrCreateTypeInfoForReflect, "
    "_MCC_GetOrCreateTypeInfoForReflect");

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetTypeForAny(const ObjectPtr obj);
__asm__(".global _CJ_MCC_GetTypeForAny\n\t.set _CJ_MCC_GetTypeForAny, _MCC_GetTypeForAny");

extern "C" MRT_EXPORT bool MCC_IsWrapperClassForAutoEnv(const TypeInfo* ti);
__asm__(".global _CJ_MCC_IsWrapperClassForAutoEnv\n\t.set _CJ_MCC_IsWrapperClassForAutoEnv, "
    "_MCC_IsWrapperClassForAutoEnv");

extern "C" MRT_EXPORT void* CJ_MCC_LoadPackage(const char* path);
__asm__(".global _CJ_MCC_LoadPackage\n\t.set _CJ_MCC_LoadPackage, _MCC_LoadPackage");

extern "C" MRT_EXPORT PackageInfo* CJ_MCC_GetPackageByQualifiedName(const char* packageName);
__asm__(".global _CJ_MCC_GetPackageByQualifiedName\n\t.set _CJ_MCC_GetPackageByQualifiedName, "
    "_MCC_GetPackageByQualifiedName");

extern "C" MRT_EXPORT const char* CJ_MCC_GetPackageVersion(PackageInfo* packageInfo);
__asm__(".global _CJ_MCC_GetPackageVersion\n\t.set _CJ_MCC_GetPackageVersion, _MCC_GetPackageVersion");

extern "C" MRT_EXPORT void* CJ_MCC_GetSubPackages(PackageInfo* packageInfo);
__asm__(".global _CJ_MCC_GetSubPackages\n\t.set _CJ_MCC_GetSubPackages, _MCC_GetSubPackages");

extern "C" MRT_EXPORT char* CJ_MCC_GetPackageName(PackageInfo* packageInfo);
__asm__(".global _CJ_MCC_GetPackageName\n\t.set _CJ_MCC_GetPackageName, _MCC_GetPackageName");
extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfTypeInfos(PackageInfo* packageInfo);
__asm__(".global _CJ_MCC_GetPackageNumOfTypeInfos\n\t.set _CJ_MCC_GetPackageNumOfTypeInfos, _MCC_GetNumOfTypeInfos");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetPackageTypeInfo(PackageInfo* packageInfo, U32 index);
__asm__(".global _CJ_MCC_GetPackageTypeInfo\n\t.set _CJ_MCC_GetPackageTypeInfo, _MCC_GetPackageTypeInfo");

extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfGlobalMethodInfos(PackageInfo* packageInfo);
__asm__(
    ".global _CJ_MCC_GetPackageNumOfGlobalMethodInfos\n\t.set _CJ_MCC_GetPackageNumOfGlobalMethodInfos, "
    "_MCC_GetPackageNumOfGlobalMethodInfos");
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetPackageGlobalMethodInfo(PackageInfo* packageInfo, U32 index);
__asm__(
    ".global _CJ_MCC_GetPackageGlobalMethodInfo\n\t.set _CJ_MCC_GetPackageGlobalMethodInfo, "
    "_MCC_GetPackageGlobalMethodInfo");

extern "C" MRT_EXPORT U32 CJ_MCC_GetPackageNumOfGlobalFieldInfos(PackageInfo* packageInfo);
__asm__(
    ".global _CJ_MCC_GetPackageNumOfGlobalFieldInfos\n\t.set _CJ_MCC_GetPackageNumOfGlobalFieldInfos, "
    "_MCC_GetPackageNumOfGlobalFieldInfos");
extern "C" MRT_EXPORT InstanceFieldInfo* CJ_MCC_GetPackageGlobalFieldInfo(PackageInfo* packageInfo, U32 index);
__asm__(
    ".global _CJ_MCC_GetPackageGlobalFieldInfo\n\t.set _CJ_MCC_GetPackageGlobalFieldInfo, "
    "_MCC_GetPackageGlobalFieldInfo");

// for reflect, method
extern "C" MRT_EXPORT const char* CJ_MCC_GetMethodName(MethodInfo* methodInfo);
__asm__(".global _CJ_MCC_GetMethodName\n\t.set _CJ_MCC_GetMethodName, _MCC_GetMethodName");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetMethodReturnType(MethodInfo* methodInfo);
__asm__(".global _CJ_MCC_GetMethodReturnType\n\t.set _CJ_MCC_GetMethodReturnType, _MCC_GetMethodReturnType");
extern "C" MRT_EXPORT U32 CJ_MCC_GetMethodModifier(MethodInfo* methodInfo);
__asm__(".global _CJ_MCC_GetMethodModifier\n\t.set _CJ_MCC_GetMethodModifier, _MCC_GetMethodModifier");
extern "C" MRT_EXPORT U32 CJ_MCC_MethodEntryPointIsNull(MethodInfo* methodInfo);
__asm__(".global _CJ_MCC_MethodEntryPointIsNull\n\t.set _CJ_MCC_MethodEntryPointIsNull, _MCC_MethodEntryPointIsNull");

extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfActualParameters(MethodInfo* methodInfo);
__asm__(".global _CJ_MCC_GetNumOfActualParameters\n\t.set _CJ_MCC_GetNumOfActualParameters, "
    "_MCC_GetNumOfActualParameters");

extern "C" MRT_EXPORT ParameterInfoRef CJ_MCC_GetActualParameterInfo(MethodInfo* methodInfo, U32 index);
__asm__(".global _CJ_MCC_GetActualParameterInfo\n\t.set _CJ_MCC_GetActualParameterInfo, _MCC_GetActualParameterInfo");

extern "C" MRT_EXPORT GenericTypeInfo* CJ_MCC_GetGenericParameterInfo(MethodInfo* methodInfo, U32 index);
__asm__(".global _CJ_MCC_GetGenericParameterInfo\n\t.set _CJ_MCC_GetGenericParameterInfo, "
    "_MCC_GetGenericParameterInfo");

extern "C" MRT_EXPORT GenericTypeInfo* CJ_MCC_CheckMethodActualArgs(MethodInfo* methodInfo,
    void* genericArgs, void* args);
__asm__(".global _CJ_MCC_CheckMethodActualArgs\n\t.set _CJ_MCC_CheckMethodActualArgs, "
    "_MCC_CheckMethodActualArgs");

// for reflect, field
extern "C" MRT_EXPORT const char* CJ_MCC_GetInstanceFieldName(InstanceFieldInfo* fieldInfo);
__asm__(".global _CJ_MCC_GetInstanceFieldName\n\t.set _CJ_MCC_GetInstanceFieldName, _MCC_GetInstanceFieldName");

extern "C" MRT_EXPORT const char* CJ_MCC_GetStaticFieldName(StaticFieldInfo fieldInfo);
__asm__(".global _CJ_MCC_GetStaticFieldName\n\t.set _CJ_MCC_GetStaticFieldName, _MCC_GetStaticFieldName");

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetInstanceFieldType(InstanceFieldInfo* fieldInfo);
__asm__(".global _CJ_MCC_GetInstanceFieldType\n\t.set _CJ_MCC_GetInstanceFieldType, _MCC_GetInstanceFieldType");

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetStaticFieldType(InstanceFieldInfo* fieldInfo);
__asm__(".global _CJ_MCC_GetStaticFieldType\n\t.set _CJ_MCC_GetStaticFieldType, _MCC_GetStaticFieldType");

extern "C" MRT_EXPORT U32 CJ_MCC_GetInstanceFieldModifier(InstanceFieldInfo* fieldInfo);
__asm__(".global _CJ_MCC_GetInstanceFieldModifier\n\t.set _CJ_MCC_GetInstanceFieldModifier, "
    "_MCC_GetInstanceFieldModifier");

extern "C" MRT_EXPORT U32 CJ_MCC_GetStaticFieldModifier(InstanceFieldInfo* fieldInfo);
__asm__(".global _CJ_MCC_GetStaticFieldModifier\n\t.set _CJ_MCC_GetStaticFieldModifier, _MCC_GetStaticFieldModifier");

extern "C" MRT_EXPORT void CJ_MCC_SetInstanceFieldValue(InstanceFieldInfo* fieldInfo, ObjRef obj, ObjRef newValue);
__asm__(".global _CJ_MCC_SetInstanceFieldValue\n\t.set _CJ_MCC_SetInstanceFieldValue, _MCC_SetInstanceFieldValue");
extern "C" MRT_EXPORT void CJ_MCC_SetStaticFieldValue(InstanceFieldInfo* fieldInfo, ObjRef value);
__asm__(".global _CJ_MCC_SetStaticFieldValue\n\t.set _CJ_MCC_SetStaticFieldValue, _MCC_SetStaticFieldValue");

// reflect, parameter
extern "C" MRT_EXPORT const char* CJ_MCC_GetParameterName(ParameterInfoRef parameterInfo);
__asm__(".global _CJ_MCC_GetParameterName\n\t.set _CJ_MCC_GetParameterName, _MCC_GetParameterName");
extern "C" MRT_EXPORT U32 CJ_MCC_GetParameterIndex(ParameterInfoRef parameterInfo);
__asm__(".global _CJ_MCC_GetParameterIndex\n\t.set _CJ_MCC_GetParameterIndex, _MCC_GetParameterIndex");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetParameterType(ParameterInfoRef parameterInfo);
__asm__(".global _CJ_MCC_GetParameterType\n\t.set _CJ_MCC_GetParameterType, _MCC_GetParameterType");

// for of<a: Any>
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetTypeForAny(const ObjectPtr obj);
__asm__(".global _CJ_MCC_GetTypeForAny\n\t.set _CJ_MCC_GetTypeForAny, _MCC_GetTypeForAny");

// reflect, class/struct
// for find
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_getTypeByQualifiedName(const char* qualifiedName);
__asm__(".global _CJ_MCC_getTypeByQualifiedName\n\t.set _CJ_MCC_getTypeByQualifiedName, _MCC_GetTypeByQualifiedName");

extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetTypeByMangledName(const char* mangledName);
__asm__(".global _CJ_MCC_GetTypeByMangledName\n\t.set _CJ_MCC_GetTypeByMangledName, _MCC_GetTypeByMangledName");

extern "C" MRT_EXPORT const char* CJ_MCC_GetTypeName(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetTypeName\n\t.set _CJ_MCC_GetTypeName, _MCC_GetTypeName");

extern "C" MRT_EXPORT bool CJ_MCC_IsClass(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsClass\n\t.set _CJ_MCC_IsClass, _MCC_IsClass");

extern "C" MRT_EXPORT bool CJ_MCC_IsInterface(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsInterface\n\t.set _CJ_MCC_IsInterface, _MCC_IsInterface");

extern "C" MRT_EXPORT bool CJ_MCC_IsStruct(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsStruct\n\t.set _CJ_MCC_IsStruct, _MCC_IsStruct");

extern "C" MRT_EXPORT bool CJ_MCC_IsPrimitive(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsPrimitive\n\t.set _CJ_MCC_IsPrimitive, _MCC_IsPrimitive");

extern "C" MRT_EXPORT bool CJ_MCC_IsGeneric(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsGeneric\n\t.set _CJ_MCC_IsGeneric, _MCC_IsGeneric");

extern "C" MRT_EXPORT bool CJ_MCC_IsEnum(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsEnum\n\t.set _CJ_MCC_IsEnum, _MCC_IsEnum");

extern "C" MRT_EXPORT bool CJ_MCC_IsFunction(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsFunction\n\t.set _CJ_MCC_IsFunction, _MCC_IsFunction");

extern "C" MRT_EXPORT bool CJ_MCC_IsTuple(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsTuple\n\t.set _CJ_MCC_IsTuple, _MCC_IsTuple");

extern "C" MRT_EXPORT bool CJ_MCC_IsReflectUnsupportedType(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsReflectUnsupportedType\n\t.set _CJ_MCC_IsReflectUnsupportedType, "
    "_MCC_IsReflectUnsupportedType");

// for function
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfFunctionSignatureTypes(TypeInfo* funcTi);
__asm__(
    ".global _CJ_MCC_GetNumOfFunctionSignatureTypes\n\t.set _CJ_MCC_GetNumOfFunctionSignatureTypes, "
    "_MCC_GetNumOfFunctionSignatureTypes");
extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetFunctionSignatureTypes(TypeInfo* funcTi);
__asm__(
    ".global _CJ_MCC_GetFunctionSignatureTypes\n\t.set _CJ_MCC_GetFunctionSignatureTypes, "
    "_MCC_GetFunctionSignatureTypes");

// for enum
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfEnumConstructorInfos(TypeInfo* ti);
__asm__(
    ".global _CJ_MCC_GetNumOfEnumConstructorInfos\n\t.set _CJ_MCC_GetNumOfEnumConstructorInfos, "
    "_MCC_GetNumOfEnumConstructorInfos");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetEnumConstructInfo(TypeInfo* ti, U32 idx);
__asm__(".global _CJ_MCC_GetEnumConstructorInfo\n\t.set _CJ_MCC_GetEnumConstructorInfo, _MCC_GetEnumConstructorInfo");
extern "C" MRT_EXPORT const char* CJ_MCC_GetEnumConstructorName(EnumCtorInfo* ti);
__asm__(".global _CJ_MCC_GetEnumConstructorName\n\t.set _CJ_MCC_GetEnumConstructorName, _MCC_GetEnumConstructorName");
extern "C" MRT_EXPORT EnumCtorInfo* CJ_MCC_GetEnumConstructorInfoFromAny(ObjRef obj);
__asm__(
    ".global _CJ_MCC_GetEnumConstructorInfoFromAny\n\t.set _CJ_MCC_GetEnumConstructorInfoFromAny, "
    "_MCC_GetEnumConstructorInfoFromAny");
extern "C" MRT_EXPORT bool CJ_MCC_IsBox(TypeInfo* ti);
__asm__(".global _CJ_MCC_IsBox\n\t.set _CJ_MCC_IsBox, _MCC_IsBox");
extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetTypeArgs(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetTypeArgs\n\t.set _CJ_MCC_GetTypeArgs, _MCC_GetTypeArgs");

// for tuple
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfFieldTypes(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetNumOfFieldTypes\n\t.set _CJ_MCC_GetNumOfFieldTypes, _MCC_GetNumOfFieldTypes");
extern "C" MRT_EXPORT TypeInfo** CJ_MCC_GetFieldTypes(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetFieldTypes\n\t.set _CJ_MCC_GetFieldTypes, _MCC_GetFieldTypes");

extern "C" MRT_EXPORT U32 CJ_MCC_GetQualifiedNameLength(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetQualifiedNameLength\n\t.set _CJ_MCC_GetQualifiedNameLength, _MCC_GetQualifiedNameLength");
extern "C" MRT_EXPORT void CJ_MCC_GetQualifiedName(TypeInfo* ti, char* qualifiedName);
__asm__(".global _CJ_MCC_GetQualifiedName\n\t.set _CJ_MCC_GetQualifiedName, _MCC_GetQualifiedName");
extern "C" MRT_EXPORT U32 CJ_MCC_GetTypeInfoModifier(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetTypeInfoModifier\n\t.set _CJ_MCC_GetTypeInfoModifier, _MCC_GetTypeInfoModifier");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetSuperTypeInfo(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetSuperTypeInfo\n\t.set _CJ_MCC_GetSuperTypeInfo, _MCC_GetSuperTypeInfo");

extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInterface(TypeInfo* ti);
__asm__(".global _CJ_MCC_GetNumOfInterface\n\t.set _CJ_MCC_GetNumOfInterface, _MCC_GetNumOfInterface");
extern "C" MRT_EXPORT TypeInfo* CJ_MCC_GetInterface(TypeInfo* ti, U32 index);
__asm__(".global _CJ_MCC_GetInterface\n\t.set _CJ_MCC_GetInterface, _MCC_GetInterface");

// InstanceMemberFunctionInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInstanceMethodInfos(TypeInfo* ti);
__asm__(
    ".global _CJ_MCC_GetNumOfInstanceMethodInfos\n\t.set "
    "_CJ_MCC_GetNumOfInstanceMethodInfos, _MCC_GetNumOfInstanceMethodInfos");
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetInstanceMethodInfo(TypeInfo* ti, U32 index);
__asm__(
    ".global _CJ_MCC_GetInstanceMethodInfo\n\t.set _CJ_MCC_GetInstanceMethodInfo, "
    "_MCC_GetInstanceMethodInfo");

// StaticMemberFunctionInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfStaticMethodInfos(TypeInfo* ti);
__asm__(
    ".global _CJ_MCC_GetNumOfStaticMethodInfos\n\t.set _CJ_MCC_GetNumOfStaticMethodInfos, "
    "_MCC_GetNumOfStaticMethodInfos");
extern "C" MRT_EXPORT MethodInfo* CJ_MCC_GetStaticMethodInfo(TypeInfo* ti, U32 index);
__asm__(
    ".global _CJ_MCC_GetStaticMethodInfo\n\t.set _CJ_MCC_GetStaticMethodInfo, "
    "_MCC_GetStaticMethodInfo");

// InstanceMemberVariableInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfInstanceFieldInfos(TypeInfo* ti);
__asm__(
    ".global _CJ_MCC_GetNumOfInstanceFieldInfos\n\t.set "
    "_CJ_MCC_GetNumOfInstanceFieldInfos, _MCC_GetNumOfInstanceFieldInfos");
extern "C" MRT_EXPORT InstanceFieldInfo* CJ_MCC_GetInstanceFieldInfo(TypeInfo* ti, U32 index);
__asm__(
    ".global _CJ_MCC_GetInstanceFieldInfo\n\t.set _CJ_MCC_GetInstanceFieldInfo, "
    "_MCC_GetInstanceFieldInfo");

// StaticMemberVariableInfos
extern "C" MRT_EXPORT U32 CJ_MCC_GetNumOfStaticFieldInfos(TypeInfo* ti);
__asm__(
    ".global _CJ_MCC_GetNumOfStaticFieldInfos\n\t.set _CJ_MCC_GetNumOfStaticFieldInfos, "
    "_MCC_GetNumOfStaticFieldInfos");
extern "C" MRT_EXPORT StaticFieldInfo* CJ_MCC_GetStaticFieldInfo(TypeInfo* ti, U32 index);
__asm__(
    ".global _CJ_MCC_GetStaticFieldInfo\n\t.set _CJ_MCC_GetStaticFieldInfo, "
    "_MCC_GetStaticFieldInfo");

#endif
