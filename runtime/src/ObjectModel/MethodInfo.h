// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_METHOD_INFO_H
#define MRT_METHOD_INFO_H

#include "Common/TypeDef.h"
#include "Common/Dataref.h"
#include "ArgValue.h"
#include "ObjectModel/Flags.h"

namespace MapleRuntime {
class TypeInfo;
class GenericTypeInfo;
class ATTR_PACKED(4) ParameterInfo {
public:
    U32 GetIndex() { return idx; }
    const char* GetName() { return name.GetDataRef(); }
    void SetName(const char* paraName);
    TypeInfo* GetType() { return type; }
    void SetType(TypeInfo* ti) { type = ti; }
    void* GetAnnotations(TypeInfo* arrayTi);
    void SetGeneric() { isGeneric = 1; }
    bool IsGeneric() { return isGeneric == 1; }
private:
    DataRefOffset64<char> name;
    U32 idx;
    // The member does not exist in the IR, use the alignment bits to mark para is generic, likes "T"
    U32 isGeneric;
    TypeInfo* type;
    Uptr annotationMethod;
};

class ATTR_PACKED(4) GenericParameterInfo {
public:
    GenericTypeInfo* GetType() { return type; }
private:
    GenericTypeInfo* type;
};

struct CJRawArray {
    TypeInfo* ti;
    U64 len;
    void* data;
};

struct CJArray {
    CJRawArray* rawPtr;
    U64 start;
    U64 length;
};

class ScopedAllocBuffer {
public:
    ScopedAllocBuffer() {}
    ~ScopedAllocBuffer();
};

class ATTR_PACKED(4) MethodInfo {
public:
    U32 GetModifier() { return modifier; }
    bool MethodEntryPointIsNull() { return entryPoint == 0; }
    const char* GetMethodName() { return name.GetDataRef(); }
    void SetMethodName(const char* methodName);
    ParameterInfo* GetActualParameterInfo(U32 index, bool isFromTypeTemplate = false);
    GenericTypeInfo* GetGenericParameterInfo(U32 index);
    void* GetAnnotations(TypeInfo* arrayTi);
    TypeInfo* GetReturnType();
    U16 GetNumOfActualParameterInfos() { return actualParametersCnt; }
    U16 GetNumOfGenericParameterInfos() { return genericParametersCnt; }
    void SetDeclaringTypeInfo(TypeInfo* declaringTypeInfo) { declaringTi = declaringTypeInfo; }
    void SetActualParameterInfos(Uptr actualParaInfosAddr);
    void SetGenericParameterInfos(Uptr genericParamInfosAddr);

    Uptr GetActualParameterInfos() { return reinterpret_cast<Uptr>(actualParameterInfos.GetDataRef()); }
    Uptr GetGenericParameterInfos() { return reinterpret_cast<Uptr>(genericParameterInfos.GetDataRef()); }

    void* ApplyCJMethod(ObjRef instanceObj, void* genericArgs, void* actualArgs, TypeInfo* thisTi);
    bool CheckMethodActualArgs(void* genericArgsArray, void* actualArgsArray);
private:
    void* MemoryAlloc(size_t cnt, size_t size);
    void MemoryFree(void* ptr);
    void* GetEntryPoint();
    TypeInfo* GetActualTypeFromGenericType(GenericTypeInfo* genericTi, void* genericArgs);
    TypeInfo* GetActualTypeFromGenericTypeImpl(GenericTypeInfo* genericTi, void* genericArgs);
    Value ApplyCJMethodImpl(ArgValue* argValues, void* sret, void** sretSlot);
    void PrepareSRet(ArgValue *argValues, void*& sret, void**& sretSlot, TypeInfo* retType);
    void PrepareCJMethodActualArgs(ArgValue* argValues, void* actualArgsArray, void *genericArgsArray);
    void PrepareCJMethodGenericArgs(ArgValue* argValues, void *genericArgsArray);
    void AddCJArg(ArgValue* argValues, TypeInfo* argType, ObjRef argObj);
    bool IsStaticMethod() { return static_cast<bool>(modifier & MODIFIER_STATIC); }
    bool HasSRet();
    bool HasSRetNotGeneric() { return static_cast<bool>(modifier & MODIFIER_HAS_SRET0); }
    bool HasSRetWithGeneric() { return static_cast<bool>(modifier & MODIFIER_HAS_SRET1); }
    bool HasSRetWithKnowGenericStruct() { return static_cast<bool>(modifier & MODIFIER_HAS_SRET2); }
    bool HasSRetWithUnknowGenericStruct() { return static_cast<bool>(modifier & MODIFIER_HAS_SRET3); }
    void* RetValueToAny(Value ret, void* sret, TypeInfo* retType);
    bool IsInitializer() { return CString(GetMethodName()) == "init"; }
    bool CheckGenericConstraint(GenericTypeInfo* genericTi, TypeInfo* ti, void* genericArgsArray);

    DataRefOffset64<char> name;
    U32 modifier;
    U16 actualParametersCnt;
    U16 genericParametersCnt;
    Uptr entryPoint;
    TypeInfo* returnType;
    Uptr annotationMethod;
    TypeInfo* declaringTi;
    DataRefOffset64<ParameterInfo> actualParameterInfos;
    DataRefOffset64<GenericParameterInfo> genericParameterInfos;
};

// MethodInfo information is stored in the Closure object. To optimize code size, no additional metadata
// is added to store MethodInfo. DynamicMethodInfo parses the Closure object during execution
// to construct MethodInfo for function calls.
class DynamicMethodInfo {
public:
    explicit DynamicMethodInfo(ObjRef obj);
    void* ApplyCangjieMethod(void* args);
private:
    U32 parameterCount;
    ObjRef instanceObj;
    TypeInfo* functionTi;
    Uptr entryPoint;
    TypeInfo* returnType;
    TypeInfo** parameterTypes;
};

} // namespace MapleRuntime
#endif // MRT_METHOD_INFO_H
