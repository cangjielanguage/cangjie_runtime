// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "ObjectModel/MClass.h"
#include <mutex>

#include "Base/Globals.h"
#include "Common/TypeDef.h"
#include "ExceptionManager.inline.h"
#include "LoaderManager.h"
#include "Loader/ILoader.h"
#include "MClass.inline.h" // module internal header
#include "Mutator/Mutator.h"
#include "ObjectManager.inline.h"
#include "ObjectModel/ExtensionData.h"
#include "RuntimeConfig.h"
#include "TypeInfoManager.h"
#include "Utils/CycleQueue.h" // Common header
#include "Utils/Demangler.h"
#include "Flags.h"

namespace MapleRuntime {
typedef void *(*GenericiFn)(U32 size, TypeInfo* args[]);

#ifdef __arm__
const size_t TYPEINFO_PTR_SIZE = sizeof(TypeInfo*) + 4;
#else
const size_t TYPEINFO_PTR_SIZE = sizeof(TypeInfo*);
#endif

CString TypeTemplate::GetTypeInfoName(U32 argSize, TypeInfo *args[])
{
    U32 startIter;
    CString argsName;
    CString suffix;
    if (IsCFunc()) {
        startIter = 1U;
        argsName.Append("(");
        suffix.Append(CString(")->") + args[0]->GetName());
    } else {
        startIter = 0U;
        argsName.Append(CString(GetName()) + "<");
        suffix.Append(">");
    }

    if (IsVArray()) {
        TypeInfo* componentTi = args[0];
        argsName.Append(componentTi->GetName());
        argsName.Append(",");
        argsName.Append(CString(argSize));
    } else {
        for (U32 idx = startIter; idx < argSize; ++idx) {
            const char* argName = args[idx]->GetName();
            argsName.Append(argName);
            if (idx < (argSize - 1U)) {
                argsName.Append(",");
            }
        }
    }
    argsName.Append(suffix);
    return argsName;
}

void* TypeTemplate::ExecuteGenericFunc(void* genericFunc, U32 argSize, TypeInfo* args[])
{
    return ((GenericiFn)genericFunc)(argSize, args);
}

ReflectInfo* TypeInfo::GetReflectInfo()
{
    if (reflectInfo != nullptr) {
        return reflectInfo;
    }
    return reflectInfo;
}

TypeInfo* TypeTemplate::GetFieldTypeInfo(U16 fieldIdx, U32 argSize, TypeInfo* args[])
{
    GenericFunc genericFunc = GetFieldGenericFunc(fieldIdx);
    void* ret = ExecuteGenericFunc(reinterpret_cast<void*>(genericFunc), argSize, args);
    TypeInfo* fieldType = reinterpret_cast<TypeInfo*>(ret);
    return fieldType;
}

TypeInfo* TypeTemplate::GetSuperTypeInfo(U32 argSize, TypeInfo* args[])
{
    GenericFunc genericFunc = GetSuperGenericFunc();
    if (genericFunc == 0) {
        return nullptr;
    }
    void* ret = ExecuteGenericFunc(reinterpret_cast<void*>(genericFunc), argSize, args);
    TypeInfo* super = reinterpret_cast<TypeInfo*>(ret);
    return super;
}

void TypeInfo::SetFlagHasRefField() { this->flag |= FLAG_HAS_REF_FIELD; }

void TypeInfo::SetGCTib(GCTib gctib)
{
    if (gctib.IsGCTibWord()) {
        this->gctib.tag = gctib.tag;
    } else {
        this->gctib.gctib = gctib.gctib;
    }
}

void TypeInfo::SetMTableDesc(MTableDesc* desc)
{
    this->mTableDesc = desc;
    std::atomic_thread_fence(std::memory_order_seq_cst);
    // 15: The most significant bit indicates whether the mTable is initialized.
    validInheritNum = validInheritNum & ((1ULL << 15) - 1);
}

void TypeInfo::TryInitMTable()
{
    if (IsMTableDescUnInitialized()) {
        TypeInfoManager& manager = TypeInfoManager::GetTypeInfoManager();
        std::lock_guard<std::recursive_mutex> lock(manager.tiMutex);
        if (IsMTableDescUnInitialized()) {
            U64 bitmap = GetResolveBitmapFromMTableDesc();
            // Built in the TypeInfoManager arena, so the pointer stays untagged (see AllocateMTableDesc).
            MTableDesc* desc = manager.AllocateMTableDesc(bitmap);
            SetMTableDesc(desc);
            manager.RecordMTableDesc(mTableDesc);
        }
    }
}

void TypeInfo::TryInitMTableNoLock()
{
    if (IsMTableDescUnInitialized()) {
        U64 bitmap = GetResolveBitmapFromMTableDesc();
        // Built in the TypeInfoManager arena, so the pointer stays untagged (see AllocateMTableDesc).
        MTableDesc* desc = TypeInfoManager::GetTypeInfoManager().AllocateMTableDesc(bitmap);
        SetMTableDesc(desc);
        TypeInfoManager::GetTypeInfoManager().RecordMTableDesc(mTableDesc);
    }
}

// This interface mustn't be invoked locklessly.
void TypeInfo::AddMTable(TypeInfo* itf, FuncPtr* funcTable)
{
    TryInitMTableNoLock();
    MTableDesc* mTableDesc = GetMTableDesc();
    U32 itfUUID = itf->GetUUID();
    CHECK(itfUUID != 0);
    auto& mTable = mTableDesc->mTable;
    auto it = mTable.find(itfUUID);
    if (it == mTable.end()) {
        mTable[itfUUID] = funcTable;
    }
}

static bool ResolveExtensionData(TypeInfo* ti, TypeInfo* resolveTi, ExtensionData* extensionData,
                                 bool needCheckStop = false,
                                 const std::function<void(TypeInfo*)> getInterface = nullptr)
{
    U16 typeArgNum = resolveTi->GetTypeArgNum();
    TypeInfo** typeArgs = nullptr;
    TypeInfo* componentTypeInfo = resolveTi->GetComponentTypeInfo();
    if (resolveTi->IsCPointer() || resolveTi->IsArrayType()) {
        typeArgNum = 1;
        typeArgs = &componentTypeInfo;
    } else {
        typeArgs = resolveTi->GetTypeArgs();
    }
    U32 thisID = resolveTi->GetUUID();
    if (needCheckStop) {
        if (extensionData == nullptr) {
            return false;
        }
        void* targetType = extensionData->GetTargetType();
        // We've traversed all related EDs.
        auto& manager = TypeInfoManager::GetTypeInfoManager();
        auto rSourceGeneric = resolveTi->GetSourceGeneric();
        if (extensionData->TargetIsTypeInfo()) {
            auto tSourceGeneric = reinterpret_cast<TypeInfo*>(targetType)->GetSourceGeneric();
            if (tSourceGeneric == nullptr && reinterpret_cast<TypeInfo*>(targetType)->GetUUID() != thisID) {
                return false;
            }
            if (tSourceGeneric != nullptr) {
                if (rSourceGeneric == nullptr) {
                    return false;
                } else if (manager.GetTypeTemplateUUID(tSourceGeneric) !=
                           manager.GetTypeTemplateUUID(rSourceGeneric)) {
                    return false;
                } else if (reinterpret_cast<TypeInfo*>(targetType)->GetUUID() != thisID) {
                    return true;
                }
            }
        } else {
            if (rSourceGeneric == nullptr ||
                manager.GetTypeTemplateUUID(reinterpret_cast<TypeTemplate*>(targetType)) !=
                manager.GetTypeTemplateUUID(rSourceGeneric)) {
                return false;
            }
        }
    }

    // Check whether where condition matched.
    void* whereCondFn = reinterpret_cast<void*>(extensionData->GetWhereCondFn());
    // &0x1: The compiler returns the lower byte of rax, but the runtime must accept it using 64 bits.
    bool whereCondFnMatch = whereCondFn == nullptr ||
        reinterpret_cast<uintptr_t>(TypeTemplate::ExecuteGenericFunc(whereCondFn, typeArgNum, typeArgs)) & 0x1;
    if (whereCondFnMatch) {
        // Check whether target interface matched.
        TypeInfo* itf = extensionData->GetInterfaceTypeInfo(typeArgNum, typeArgs);
        if (getInterface != nullptr) {
            getInterface(itf);
        }
        if (itf) {
            ti->AddMTable(itf, extensionData->GetFuncTable());
        }
    }
    return true;
}

static void ResolveInnerExtensionDefs(TypeInfo* ti, TypeInfo* resolveTi,
                                      const std::function<void(TypeInfo*)> getInterface)
{
    // Normally, after all ExtensionDefs of the class are loaded, the branch should not enter again.
    // ExtensionDatas = [A_A, B_A, B_B, B_I1, B_I2, ..., C_A, C_B, C_C, C_I1, ...]. If this is C, and itf is I1,
    // then vExtensionDataStart is pointed to C_A, and validInheritNum is 2. Therefore, to get C_I1, we need to add
    // the offset value of ptrSize*validInheritNum.
    resolveTi->TryInitMTable();
    // The MTable of `resolveTi` has been completed already, and can be merged into MTable of `ti`.
    if (!resolveTi->IsInheritNumValid()) {
        auto& resolve_ti_mtable = resolveTi->GetMTableDesc()->mTable;
        ti->GetMTableDesc()->mTable.insert(resolve_ti_mtable.begin(), resolve_ti_mtable.end());
        return;
    }
    if (ti != resolveTi) {
        auto& resolve_ti_mtable = resolveTi->GetMTableDesc()->mTable;
        ti->GetMTableDesc()->mTable.insert(resolve_ti_mtable.begin(), resolve_ti_mtable.end());
    }

    ExtensionData** vExtensionPtr = resolveTi->GetvExtensionDataStart();
    if (vExtensionPtr == nullptr) {
        return;
    }
    U16 initIndex = resolveTi->GetValidInheritNum();
    vExtensionPtr += initIndex;
    MTableBitmap& bitmap = resolveTi->GetMTableDesc()->mTableBitmap;
    if (bitmap.tag != 0) {
        bitmap.ForEachBit(
            [ti, resolveTi, getInterface](ExtensionData* extensionData) {
                ResolveExtensionData(ti, resolveTi, extensionData, false, getInterface);
            }, vExtensionPtr);
        return;
    }
    while (true) {
        bool tag = ResolveExtensionData(ti, resolveTi, *vExtensionPtr, true, getInterface);
        if (!tag) {
            break;
        }
        ++vExtensionPtr;
    }
}

void TypeInfo::TraverseInnerExtensionDefs(const std::function<void(TypeInfo*)> getInterface)
{
    TypeInfo* curType = this;
    this->mTableDesc->pending = true;
    while (curType) {
        ResolveInnerExtensionDefs(this, curType, getInterface);
        if (curType->IsRawArray() || curType->IsVArray() || curType->IsCPointer()) {
            break;
        }
        curType = curType->GetSuperTypeInfo();
    }
    this->mTableDesc->pending = false;
}

void TypeInfo::TraverseOuterExtensionDefs(std::function<void(TypeInfo*)> getInterface)
{
    U16 typeArgNum = GetTypeArgNum();
    TypeInfo** typeArgs = nullptr;
    TypeInfo* componentTypeInfo = GetComponentTypeInfo();
    if (IsCPointer() || IsArrayType()) {
        // the generic types, includes CPointer and Array.
        // the generic parameter is used as componentTypeInfo.
        typeArgNum = 1;
        typeArgs = &componentTypeInfo;
    } else {
        typeArgs = GetTypeArgs();
    }
    LoaderManager::GetInstance()->GetLoader()->VisitExtenionData(
        [this, typeArgNum, typeArgs, getInterface](ExtensionData* extensionData) {
            uintptr_t matched = false;
            void* whereCondFn = reinterpret_cast<void*>(extensionData->GetWhereCondFn());
            if (whereCondFn == nullptr) {
                matched = true;
            } else {
                // &0x1: The compiler returns the lower byte of rax, but the runtime must accept it using 64 bits.
                matched =
                    reinterpret_cast<uintptr_t>(TypeTemplate::ExecuteGenericFunc(whereCondFn, typeArgNum, typeArgs)) &
                    0x1;
            }
            if (matched) {
                TypeInfo* itf = extensionData->GetInterfaceTypeInfo(typeArgNum, typeArgs);
                if (getInterface != nullptr) {
                    getInterface(itf);
                }
                TypeInfoManager::GetTypeInfoManager().AddTypeInfo(itf);
                this->AddMTable(itf, extensionData->GetFuncTable());
            }
            return false;
        },
        sourceGeneric);
    LoaderManager::GetInstance()->GetLoader()->EraseLazyStaticGI(uuid);
}

void TypeInfo::GetInterfaces(std::vector<TypeInfo*> &itfs)
{
    TryInitMTable();
    TraverseInnerExtensionDefs([&itfs](TypeInfo* ti) { itfs.push_back(ti); });
    if (IsGenericTypeInfo()) {
        TraverseOuterExtensionDefs([&itfs](TypeInfo* ti) { itfs.push_back(ti); });
    }
}

std::pair<FuncPtr*, bool> TypeInfo::FindMTable(U32 itfUUID)
{
    if (this->IsInheritNumValid()) {
        std::lock_guard<std::recursive_mutex> lock(mTableDesc->mTableMutex);
        if (this->IsInheritNumValid()) {
            // Why need this? Consider the following scenarios:
            // interface I1<T> {}
            // class CB<T> <: I1<T> where T <: I1<T>
            // class CA <: CB<CA> {}
            // Now, generated NonExtensionDatas = [..., CA_CB, CA_I1, ..., CB_I1] (ignore virtual functions).
            // For the CA, when the CB is traversed, the CA is I1<CA> needs to be checked.
            // In this case, IsSubType() is invoked to repeatedly generate the mTable of the CA. And The repeated
            // invoking can be quickly filtered out.
            if (mTableDesc->pending) {
                auto it = mTableDesc->mTable.find(itfUUID);
                if (it != mTableDesc->mTable.end()) {
                    return { it->second, true };
                } else {
                    return { nullptr, false };
                }
            }
            TraverseInnerExtensionDefs();
            TraverseOuterExtensionDefs();
            validInheritNum = INVALID_INHERIT_NUM;
        }
    }
    auto& mTable = mTableDesc->mTable;
    auto it = mTable.find(itfUUID);
    if (it != mTable.end()) {
        return { it->second, true };
    }
    return { nullptr, false };
}

FuncPtr* TypeInfo::GetMTable(TypeInfo* itf)
{
    if (GetUUID() == 0) {
        TypeInfoManager::GetTypeInfoManager().AddTypeInfo(this);
    }
    if (IsTempEnum() && GetSuperTypeInfo()) {
        return GetSuperTypeInfo()->GetMTable(itf);
    }
    TryInitMTable();
    if (IsMTableDescUnInitialized()) {
        LOG(RTLOG_FATAL, "mTableDesc init failed, ti: %s(%p)", GetName(), this, mTableDesc);
    }
    U32 itfUUID = itf->GetUUID();
    CHECK(itfUUID != 0);
    FuncPtr* funcTable = FindMTable(itfUUID).first;
    if (funcTable == nullptr) {
        LOG(RTLOG_FATAL, "funcTable is nullptr, ti: %s, itf: %s", GetName(), itf->GetName());
    }
    return funcTable;
}

bool TypeInfo::IsSubType(TypeInfo* typeInfo)
{
    if (GetUUID() == typeInfo->GetUUID()) {
        return true;
    }
    if (IsNothing()) {
        return true;
    }
    if ((IsTuple() && typeInfo->IsTuple()) && (GetFieldNum() == typeInfo->GetFieldNum())) {
        for (U16 idx = 0; idx < GetFieldNum(); ++idx) {
            if (!GetFieldType(idx)->IsSubType(typeInfo->GetFieldType(idx))) {
                return false;
            }
        }
        return true;
    } else if (typeInfo->IsFunc()) {
        // The function type information is stored in the `SuperClass` of the closure instance.
        // Therefore, having SuperClass and SuperClass->IsFunc are prerequisites for the instance
        // to be of the function type.
        auto super = this->GetSuperTypeInfo();
        if (!super || !super->IsFunc()) {
            return false;
        }
        // Now, `super` and `typeInfo` both are Closure type.
        // Get function type from Closure type, i.e., typeArgs[0]:
        TypeInfo* thisFuncType = super->GetTypeArgs()[0];
        TypeInfo* thatFuncType = typeInfo->GetTypeArgs()[0];
        // In addition, it is necessary to have the same number of TypeArgNum.
        U16 typeArgNum = thisFuncType->GetTypeArgNum();
        if (typeArgNum != thatFuncType->GetTypeArgNum()) {
            return false;
        }
        // Note: the first TypeArg is the return value type.
        constexpr U16 returnTypeIdx = 0;
        // The parameter type of a function is contra-variant, and the return type of a function is covariant.
        // Assume that the type of the f1 function is S1 -> T1 and the type of the f2 function is S2 -> T2,
        // f1 is a subtype of f2 if S2 <: S1 and T1 <: T2.
        if (!thisFuncType->GetTypeArgs()[returnTypeIdx]->IsSubType(thatFuncType->GetTypeArgs()[returnTypeIdx])) {
            return false;
        }
        for (U16 idx = returnTypeIdx + 1; idx < typeArgNum; ++idx) {
            if (!thatFuncType->GetTypeArgs()[idx]->IsSubType(thisFuncType->GetTypeArgs()[idx])) {
                return false;
            }
        }
        return true;
    } else if (IsClass() && typeInfo->IsClass()) {
        TypeInfo* super = GetSuperTypeInfo();
        // closure instance's super class store the func type,
        // means super class is func type, then this is func type too.
        if (super != nullptr && super->IsFunc()) {
            return false;
        }
        TypeInfo* objectTi = TypeInfoManager::GetTypeInfoManager().GetObjectTypeInfo();
        if (objectTi != nullptr && typeInfo == objectTi) {
            return true;
        }
        while (super != nullptr) {
            if (super->GetUUID() == typeInfo->GetUUID()) {
                return true;
            }
            super = super->GetSuperTypeInfo();
        }
        return false;
    } else if (typeInfo->IsInterface()) {
        if (IsTempEnum() && GetSuperTypeInfo()) {
            return GetSuperTypeInfo()->IsSubType(typeInfo);
        }
        // All types are subtypes of the Any type.
        if (typeInfo == TypeInfoManager::GetTypeInfoManager().GetAnyTypeInfo()) {
            return true;
        }
        TryInitMTable();
        U32 targetID = typeInfo->GetUUID();
        bool isSubType = FindMTable(targetID).second;
        return isSubType;
    }
    return false;
}

void ReflectInfo::SetFieldNames(FieldNames* fieldNames)
{
    fieldNamesOffset.refOffset = reinterpret_cast<Uptr>(fieldNames) - reinterpret_cast<Uptr>(&fieldNamesOffset);
}

void ReflectInfo::SetInstanceMethodInfo(U32 idx, MethodInfo* methodInfo)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceFieldInfoCnt * sizeof(DataRefOffset64<InstanceFieldInfo>);
    baseAddr += staticFieldInfoCnt * sizeof(DataRefOffset64<StaticFieldInfo>);
    baseAddr += idx * sizeof(DataRefOffset64<MethodInfo>);
    I64* addr = reinterpret_cast<I64*>(baseAddr);
    *addr = reinterpret_cast<Uptr>(methodInfo) - reinterpret_cast<Uptr>(addr);
}

void ReflectInfo::SetStaticMethodInfo(U32 idx, MethodInfo* methodInfo)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceFieldInfoCnt * sizeof(DataRefOffset64<InstanceFieldInfo>);
    baseAddr += staticFieldInfoCnt * sizeof(DataRefOffset64<StaticFieldInfo>);
    baseAddr += instanceMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += idx * sizeof(DataRefOffset64<MethodInfo>);
    I64* addr = reinterpret_cast<I64*>(baseAddr);
    *addr = reinterpret_cast<Uptr>(methodInfo) - reinterpret_cast<Uptr>(addr);
}

char* ReflectInfo::GetFieldName(U32 idx) const
{
    FieldNames* fieldNames = fieldNamesOffset.GetDataRef();
    Uptr baseAddr = reinterpret_cast<Uptr>(fieldNames) + sizeof(void*) * idx;
    I64 offset = fieldNames->fieldNameOffset[idx];
    Uptr fieldNameAddr = baseAddr + offset;
    return reinterpret_cast<char*>(fieldNameAddr);
}

StaticFieldInfo* ReflectInfo::GetStaticFieldInfo(U32 index)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceFieldInfoCnt * sizeof(DataRefOffset64<InstanceFieldInfo>);
    baseAddr += index * sizeof(DataRefOffset64<StaticFieldInfo>);
    return reinterpret_cast<DataRefOffset64<StaticFieldInfo>*>(baseAddr)->GetDataRef();
}

MethodInfo* ReflectInfo::GetInstanceMethodInfo(U32 index) const
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceFieldInfoCnt * sizeof(DataRefOffset64<InstanceFieldInfo>);
    baseAddr += staticFieldInfoCnt * sizeof(DataRefOffset64<StaticFieldInfo>);
    baseAddr += index * sizeof(DataRefOffset64<MethodInfo>);
    return reinterpret_cast<DataRefOffset64<MethodInfo>*>(baseAddr)->GetDataRef();
}

MethodInfo* ReflectInfo::GetStaticMethodInfo(U32 index)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceFieldInfoCnt * sizeof(DataRefOffset64<InstanceFieldInfo>);
    baseAddr += staticFieldInfoCnt * sizeof(DataRefOffset64<StaticFieldInfo>);
    baseAddr += instanceMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += index * sizeof(DataRefOffset64<MethodInfo>);
    return reinterpret_cast<DataRefOffset64<MethodInfo>*>(baseAddr)->GetDataRef();
}

static void* GetAnnotations(Uptr annotationMethod, TypeInfo* arrayTi)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    U32 size = arrayTi->GetInstanceSize();
    MSize objSize = MRT_ALIGN(size + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    MObject* obj = ObjectManager::NewObject(arrayTi, objSize, AllocType::RAW_POINTER_OBJECT);
    if (obj == nullptr) {
        ExceptionManager::OutOfMemory();
        return nullptr;
    }
    if (annotationMethod == 0) {
        return obj;
    }
    ArgValue values;
    uintptr_t structRet[ARRAY_STRUCT_SIZE];
    values.AddReference(reinterpret_cast<BaseObject*>(structRet));
    uintptr_t threadData = MapleRuntime::MRT_GetThreadLocalData();
#if defined(__aarch64__)
    ApplyCangjieMethodStub(values.GetData(), reinterpret_cast<void*>(values.GetStackSize()),
                           reinterpret_cast<void*>(annotationMethod), reinterpret_cast<void*>(threadData), structRet);
#else
    ApplyCangjieMethodStub(values.GetData(), values.GetStackSize(), annotationMethod, threadData);
#endif
    Heap::GetBarrier().WriteStruct(obj, reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE,
        size, reinterpret_cast<Uptr>(structRet), size);
    AllocBuffer* buffer = AllocBuffer::GetAllocBuffer();
    if (buffer != nullptr) {
        buffer->CommitRawPointerRegions();
    }
    return obj;
}

bool TypeInfo::ReflectIsEnable() const { return static_cast<bool>(flag & FLAG_REFLECTION); }

bool TypeTemplate::ReflectIsEnable() const { return static_cast<bool>(flag & FLAG_REFLECTION); }

void* ReflectInfo::GetAnnotations(TypeInfo* arrayTi)
{
    return MapleRuntime::GetAnnotations(annotationMethod, arrayTi);
}

U32 TypeInfo::GetModifier()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return MODIFIER_INVALID;
    }
    return GetReflectInfo()->GetModifier();
}

U32 TypeInfo::GetNumOfInstanceFieldInfos()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    if (IsGenericTypeInfo()) {
        return GetSourceGeneric()->GetReflectInfo()->GetNumOfInstanceFieldInfos();
    }
    return GetReflectInfo()->GetNumOfInstanceFieldInfos();
}

InstanceFieldInfo* TypeInfo::GetInstanceFieldInfo(U32 index)
{
    if (IsGenericTypeInfo()) {
        return GetSourceGeneric()->GetReflectInfo()->GetInstanceFieldInfo(index);
    }
    return GetReflectInfo()->GetInstanceFieldInfo(index);
}

U32 TypeInfo::GetNumOfStaticFieldInfos()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    if (IsGenericTypeInfo()) {
        return GetSourceGeneric()->GetReflectInfo()->GetNumOfStaticFieldInfos();
    }
    return GetReflectInfo()->GetNumOfStaticFieldInfos();
}

U32 TypeInfo::GetNumOfInstanceMethodInfos()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    return GetReflectInfo()->GetNumOfInstanceMethodInfos();
}

U32 TypeInfo::GetNumOfStaticMethodInfos()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    return GetReflectInfo()->GetNumOfStaticMethodInfos();
}

InstanceFieldInfo* ReflectInfo::GetInstanceFieldInfo(U32 index)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += index * sizeof(DataRefOffset64<InstanceFieldInfo>);
    return reinterpret_cast<DataRefOffset64<InstanceFieldInfo>*>(baseAddr)->GetDataRef();
}

StaticFieldInfo* TypeInfo::GetStaticFieldInfo(U32 index)
{
    if (IsGenericTypeInfo()) {
        return GetSourceGeneric()->GetReflectInfo()->GetStaticFieldInfo(index);
    }
    return GetReflectInfo()->GetStaticFieldInfo(index);
}

MethodInfo* TypeInfo::GetInstanceMethodInfo(U32 index)
{
    return GetReflectInfo()->GetInstanceMethodInfo(index);
}

MethodInfo* TypeInfo::GetStaticMethodInfo(U32 index)
{
    return GetReflectInfo()->GetStaticMethodInfo(index);
}

void* TypeInfo::GetAnnotations(TypeInfo* arrayTi) { return GetReflectInfo()->GetAnnotations(arrayTi); }

FuncRef TypeInfo::GetFinalizeMethod() const
{
    if (GetTypeArgNum() == 0) {
        return finalizerMethod;
    } else {
        return GetSourceGeneric()->GetFinalizeMethod();
    }
}

void EnumInfo::SetEnumCtors(void* ctors)
{
    enumCtorInfos.refOffset = reinterpret_cast<Uptr>(ctors) - reinterpret_cast<Uptr>(this);
}

void* EnumInfo::GetAnnotations(TypeInfo* arrayTi)
{
    return MapleRuntime::GetAnnotations(annotationMethod, arrayTi);
}

MethodInfo* EnumInfo::GetInstanceMethodInfo(U32 index) const
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += index * sizeof(DataRefOffset64<MethodInfo>);
    return reinterpret_cast<DataRefOffset64<MethodInfo>*>(baseAddr)->GetDataRef();
}

MethodInfo* EnumInfo::GetStaticMethodInfo(U32 index)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += index * sizeof(DataRefOffset64<MethodInfo>);
    return reinterpret_cast<DataRefOffset64<MethodInfo>*>(baseAddr)->GetDataRef();
}

void EnumCtorInfo::SetName(const char* pName)
{
    name.refOffset = reinterpret_cast<Uptr>(pName) - reinterpret_cast<Uptr>(this);
}
} // namespace MapleRuntime
