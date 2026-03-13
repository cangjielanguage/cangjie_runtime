// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "TypeInfoManager.h"
#include "Base/CString.h"
#include "Base/MemUtils.h"
#include "ObjectModel/MClass.h"
#include "ObjectManager.inline.h"
#include "Sync/Sync.h"

namespace MapleRuntime {
void TypeGCInfo::FillTypeGCInfo(TypeInfo* ti, CString &gcTibStr, U32 &curSize)
{
    U32 ptrSize = sizeof(void*);
    U16 tiAlign = ti->IsRef() ? sizeof(BaseObject*) : ti->GetAlign();
    curSize = MRT_ALIGN(curSize, tiAlign);
    if (ti->IsRef()) {
        gcTibStr[curSize / ptrSize] = '1';
    } else {
        if (ti->HasRefField()) {
            CString fieldGCTibStr = GetGCTibStr(ti);
            gcTibStr.Replace(curSize / ptrSize, fieldGCTibStr);
        }
    }
    curSize += TypeInfoManager::GetTypeSize(ti);
}

void TypeGCInfo::FillArrayTypeGCInfo(TypeInfo* ti, CString &gcTibStr, U32 &curSize)
{
    U16 eleNum = ti->GetFieldNum();
    TypeInfo* componentTi = ti->GetComponentTypeInfo();
    U16 idx = 0;
    while (idx < eleNum) {
        idx++;
        if (componentTi->IsVArray()) {
            FillArrayTypeGCInfo(componentTi, gcTibStr, curSize);
            continue;
        }
        FillTypeGCInfo(componentTi, gcTibStr, curSize);
    }
}

CString TypeGCInfo::GetGCTibStr(TypeInfo* ti)
{
    U32 ptrSize = sizeof(void*);
    CString gcTibStr;
    U32 curSize = 0;
    gcTibStr = CString((ti->GetInstanceSize() + ptrSize - 1) / ptrSize, '0');
    if (!ti->HasRefField()) {
        return gcTibStr;
    }
    U16 fieldNum = ti->GetFieldNum();
    for (U16 idx = 0; idx < fieldNum; ++idx) {
        TypeInfo* fieldTi = ti->GetFieldType(idx);
        // Nothing and Unit type, size is 0
        // does not need to calculate gctib
        if (fieldTi->IsNothing() || fieldTi->IsUnit()) {
            continue;
        }
        if (fieldTi->IsVArray()) {
            FillArrayTypeGCInfo(fieldTi, gcTibStr, curSize);
        } else {
            FillTypeGCInfo(fieldTi, gcTibStr, curSize);
        }
    }
    return gcTibStr;
}

U32 TypeInfoManager::GenericTiDesc::computeHash()
{
    TypeInfoManager& mgr = TypeInfoManager::GetTypeInfoManager();
    U32 H = 1;
    auto update = [&H](U32 val) {
        H = 31 * H + val;
    };
    U32 uuidOfTT = tt->GetUUID();
    if (uuidOfTT == 0) {
        uuidOfTT = mgr.GetTypeTemplateUUID(tt);
    }
    update(uuidOfTT);

    for (U32 idx = 0; idx < argSize; idx++) {
        TypeInfo* ti = args[idx];
        if (ti->IsInitialUUID()) {
            mgr.AddTypeInfo(ti);
        }
        CHECK(!ti->IsInitialUUID());
        update(ti->uuid);
    }
    return H;
}

bool TypeInfoManager::GenericTiDesc::operator==(const GenericTiDesc &other) const
{
    if (hash != other.hash) {
        return false;
    }

    if (argSize != other.argSize) {
        return false;
    }

    TypeInfoManager& mgr = TypeInfoManager::GetTypeInfoManager();
    if (tt != other.tt) {
        U16 ttUUID = tt->GetUUID();
        U16 otherTtUUID = other.tt->GetUUID();
        if (ttUUID == 0) {
            ttUUID = mgr.GetTypeTemplateUUID(tt);
        }
        if (otherTtUUID == 0) {
            otherTtUUID = mgr.GetTypeTemplateUUID(other.tt);
        }
        if (ttUUID != otherTtUUID) {
            return false;
        }
    }

    for (U32 idx = 0; idx < argSize; idx++) {
        TypeInfo* ti = argsVector[idx];
        TypeInfo* otherTi = other.args[idx];
        if (ti->IsInitialUUID()) {
            mgr.AddTypeInfo(ti);
        }
        U32 tiUUID = ti->GetUUID();
        if (otherTi->IsInitialUUID()) {
            mgr.AddTypeInfo(otherTi);
        }
        U32 otherTiUUID = otherTi->GetUUID();
        if (tiUUID != otherTiUUID) {
            return false;
        }
    }
    return true;
}

static ImmortalWrapper<TypeInfoManager> typeInfoManager;
TypeInfoManager& TypeInfoManager::GetTypeInfoManager() { return *typeInfoManager; }

void TypeInfoManager::Init()
{
    NewMMap(mapMemory);
}

void TypeInfoManager::Fini()
{
    // release resources
    for (const auto& mTable : mTableList) {
        delete mTable.second;
    }
    mTableList.clear();
    for (const auto& m : mmapList) {
        FreeMMap(m.first, m.second);
    }
    mmapList.clear();
}

void TypeInfoManager::NewMMap(size_t size)
{
#ifdef _WIN64
    void* start = VirtualAlloc(NULL, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (start == NULL) {
        LOG(RTLOG_FATAL, "failed to initialize TypeInfoManager");
    }
#else
    void* start = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (start == MAP_FAILED) {
        LOG(RTLOG_FATAL, "failed to initialize TypeInfoManager");
    } else {
#ifndef __APPLE__
    MRT_PRCTL(start, size, "TypeInfoManager");
#endif
    }
#endif
    startAddress = reinterpret_cast<uintptr_t>(start);
    endAddress = startAddress + size;
    position = startAddress;
    mmapList.push_back(std::make_pair(startAddress, size));
}

void TypeInfoManager::FreeMMap(uintptr_t address, size_t size)
{
#ifdef _WIN64
    if (!VirtualFree(reinterpret_cast<void*>(address), 0, MEM_RELEASE)) {
        LOG(RTLOG_ERROR, "VirtualFree error for TypeInfoManager");
    }
#else
    if (munmap(reinterpret_cast<void*>(address), size) != 0) {
        LOG(RTLOG_ERROR, "munmap error for TypeInfoManager");
    }
#endif
}

void TypeInfoManager::AddTypeInfo(TypeInfo* ti)
{
    if (!ti->IsInitialUUID()) {
        return;
    }
    // Let tiDesc/typeInfoName before lock to reduce tiMutex hold time.
    const bool isGeneric = ti->IsGenericTypeInfo() && !ti->IsVArray();
    GenericTiDesc* tiDesc = nullptr;
    const char* typeInfoName = nullptr;
    if (isGeneric) {
        if (ti->IsRawArray() || ti->IsCPointer()) {
            TypeInfo* args[] = { ti->GetComponentTypeInfo() };
            tiDesc = GetTypeInfo(ti->GetSourceGeneric(), 1, args);
        } else {
            tiDesc = GetTypeInfo(ti->GetSourceGeneric(), ti->GetTypeArgNum(), ti->GetTypeArgs());
        }
    } else {
        typeInfoName = ti->GetName();
    }
    std::lock_guard<std::recursive_mutex> lock(tiMutex);
    if (!ti->IsInitialUUID()) {
        return;
    }
    // Some typeinfo generated by compiler have a validInheritNum field of 0,
    // and their mTableDesc is also 0.
    if (reinterpret_cast<uintptr_t>(ti->GetMTableDesc()) == 0) {
        // 15: The most significant bit indicates whether the mTable is initialized.
        ti->validInheritNum |= 1 << 15;
    }
    if (isGeneric) {
        bool hasExisted = false;
        if (tiDesc->typeInfo != nullptr && !tiDesc->typeInfo->IsInitialUUID()) {
            ti->SetUUID(tiDesc->typeInfo->uuid);
            tiDesc->typeInfo->TryInitMTableNoLock();
            ti->SetMTableDesc(tiDesc->typeInfo->GetMTableDesc());
            ti->SetReflectInfo(tiDesc->typeInfo->GetReflectInfo());
            hasExisted = true;
        } else {
            ti->SetUUID(tiMaxUUID.fetch_add(1));
            tiDesc->typeInfo = ti;
            ti->TryInitMTableNoLock();
            LoaderManager::GetInstance()->RecordTypeInfo(ti);
        }
        bool needRefresh = ti->NeedRefresh() && !tiDesc->IsIniting();
        tiDesc->SetTypeInfoStatus(TypeInfoStatus::TYPEINFO_INITED);
        if (UNLIKELY(needRefresh)) {
            CHECK(ti->IsObjectType());
            if (LIKELY(hasExisted)) {
                CHECK(memcpy_s(reinterpret_cast<void*>(ti), sizeof(TypeInfo) - 16U,
                               reinterpret_cast<void*>(tiDesc->typeInfo), sizeof(TypeInfo) - 16U) == EOK);
            } else {
                TypeTemplate* tt = ti->sourceGeneric;
                U16 fieldNum = tt->GetFieldNum();
                ti->SetFieldNum(fieldNum);
                U32* offsets = reinterpret_cast<U32*>(Allocate(fieldNum * sizeof(U32)));
                ti->SetOffsets(offsets);
                ti->SetFieldAddr(reinterpret_cast<TypeInfo**>(Allocate(fieldNum * TYPEINFO_PTR_SIZE)));
                FillOffsets(ti, tt, ti->GetTypeArgNum(), ti->GetTypeArgs());
                CalculateGCTib(ti);
            }
        }
    } else {
        auto it = nonGenericTypeInfos.find(typeInfoName);
        if (it != nonGenericTypeInfos.end()) {
            TypeInfo* createdTi = it->second;
            // To avoid repeated hashmap overhead, set mTable in advance.
            if (createdTi != ti) {
                CHECK(createdTi->uuid != 0);
                ti->SetUUID(createdTi->uuid);
                createdTi->TryInitMTableNoLock();
                MTableDesc* mTableDesc = createdTi->GetMTableDesc();
                ti->SetMTableDesc(mTableDesc);
            }
            return;
        }
        nonGenericTypeInfos[typeInfoName] = ti;
        ti->SetUUID(tiMaxUUID.fetch_add(1));
    }
}

U16 TypeInfoManager::GetTypeTemplateUUID(TypeTemplate* tt)
{
    U16 ttUUID = tt->GetUUID();
    if (ttUUID != 0) {
        return ttUUID;
    }
    std::lock_guard<std::mutex> lock(ttMutex);
    ttUUID = tt->GetUUID();
    if (ttUUID != 0) {
        return ttUUID;
    }
    auto res = typeTemplates.emplace(tt->GetName(), tt);
    if (!res.second) {
        ttUUID = res.first->second->GetUUID();
        tt->SetUUID(ttUUID);
        return ttUUID;
    }

    ttUUID = ttMaxUUID.fetch_add(1);
    tt->SetUUID(ttUUID);
    return ttUUID;
}
TypeInfoManager::GenericTiDesc* TypeInfoManager::InsertGenericTiDesc(GenericTiDesc& desc)
{
    return genericTypeInfoDescMap.InsertGenericTiDesc(desc);
}
TypeInfoManager::GenericTiDesc* TypeInfoManager::GetGenericTiDesc(GenericTiDesc& desc)
{
    return genericTypeInfoDescMap.GetGenericTiDesc(desc);
}

TypeInfoManager::GenericTiDesc* TypeInfoManager::GenericTiDescHashMap::GetGenericTiDesc(GenericTiDesc &desc)
{
    const U32 h = desc.GetHash();
    const size_t bucketIdx = h % buckets.size();
    auto &bucket = buckets[bucketIdx];
    bucket.rwLock.LockRead();
    auto it = bucket.maps.find(h);
    if (it != bucket.maps.end()) {
        for (auto descIt = it->second.begin(); descIt != it->second.end(); ++descIt) {
            if (**descIt == desc) {
                bucket.rwLock.UnlockRead();
                return *descIt;
            }
        }
    }
    bucket.rwLock.UnlockRead();
    return nullptr;
}

TypeInfoManager::GenericTiDesc* TypeInfoManager::GenericTiDescHashMap::InsertGenericTiDesc(GenericTiDesc &desc)
{
    const U32 h = desc.GetHash();
    const size_t bucketIdx = h % buckets.size();
    auto &bucket = buckets[bucketIdx];
    bucket.rwLock.LockWrite();
    auto it = bucket.maps.find(h);
    if (it != bucket.maps.end()) {
        for (auto descIt = it->second.begin(); descIt != it->second.end(); ++descIt) {
            if (**descIt == desc) {
                bucket.rwLock.UnlockWrite();
                return *descIt;
            }
        }
    }
    GenericTiDesc* tiDesc = new (std::nothrow) GenericTiDesc(desc);
    CHECK_DETAIL(tiDesc != nullptr, "fail to allocate GenericTiDesc");
    bucket.maps[h].push_back(tiDesc);
    bucket.rwLock.UnlockWrite();
    return tiDesc;
}

TypeInfoManager::GenericTiDesc* TypeInfoManager::GetTypeInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    GenericTiDesc desc(tt, argSize, args);
    GenericTiDesc* genericTiDesc = genericTypeInfoDescMap.GetGenericTiDesc(desc);
    if (genericTiDesc == nullptr) {
        genericTiDesc = genericTypeInfoDescMap.InsertGenericTiDesc(desc);
    }
    return genericTiDesc;
}

TypeInfo* TypeInfoManager::GetOrCreateTypeInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    auto typeInfoDesc = GetTypeInfo(tt, argSize, args);
    if (typeInfoDesc->IsInited()) {
        return typeInfoDesc->typeInfo;
    }
    const U32 currentTid = static_cast<U32>(GetTid());
    do {
        if (typeInfoDesc->IsInited()) {
            return typeInfoDesc->typeInfo;
        }
        if (typeInfoDesc->IsIniting() && typeInfoDesc->tid.load() == currentTid) {
            return typeInfoDesc->typeInfo;
        }
        if (typeInfoDesc->IsNotCreated() && typeInfoDesc->tid.load() == currentTid) {
            CreatedTypeInfo(typeInfoDesc, tt, argSize, args);
        }
    } while (true);
}

void TypeInfoManager::CreatedTypeInfoImpl(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    CString typeInfoName = tt->GetTypeInfoName(argSize, args);
    TypeInfo* newTypeInfo = reinterpret_cast<TypeInfo*>(Allocate(sizeof(TypeInfo)));
    size_t nameSize = typeInfoName.Length() + 1;
    uintptr_t nameAddr = Allocate(nameSize);
    MapleRuntime::MemoryCopy(nameAddr, nameSize, reinterpret_cast<uintptr_t>(typeInfoName.Str()), nameSize);
    newTypeInfo->SetName(reinterpret_cast<const char*>(nameAddr));

    newTypeInfo->SetType(tt->GetType());
    newTypeInfo->SetFlag(tt->GetFlag());
    newTypeInfo->SetValidInheritNum(tt->GetValidInheritNum());
    newTypeInfo->SetvExtensionDataStart(tt->GetvExtensionDataStart());
    newTypeInfo->SetSourceGeneric(tt);
    // genericArgs
    size_t genericArgsSize = argSize * sizeof(TypeInfo*);
    uintptr_t genericArgsAddr = Allocate(genericArgsSize);
    MapleRuntime::MemoryCopy(genericArgsAddr, genericArgsSize, reinterpret_cast<uintptr_t>(args), genericArgsSize);
    newTypeInfo->SetGenericArgs(reinterpret_cast<TypeInfo**>(genericArgsAddr));
    tiDesc->typeInfo = newTypeInfo;
    tiDesc->SetTypeInfoStatus(TypeInfoStatus::TYPEINFO_INITING);

    U16 fieldNum = tt->GetFieldNum();
    U16 typeArgNum = tt->GetTypeArgNum();
    if (tt->IsCFunc()) {
        typeArgNum = argSize;
    } else if (tt->IsTuple() || tt->IsFunc() || tt->IsRawArray()) {
        fieldNum = argSize;
        typeArgNum = argSize;
    } else if (tt->IsVArray()) {
        LOG(RTLOG_FATAL, "Instantiate TypeInfo for VArray is not supported");
    }

    U32 ptrSize = sizeof(void*);
    newTypeInfo->SetFieldNum(fieldNum);
    newTypeInfo->SetTypeArgNum(typeArgNum);
    if (tt->IsArrayType() || tt->IsCPointer()) {
        // args stores the component typeInfo of the array or cpointer.
        TypeInfo* componentTypeTi = args[0];
        newTypeInfo->SetComponentTypeInfo(componentTypeTi);
        newTypeInfo->SetInstanceSize(ptrSize);
        newTypeInfo->SetAlign(ptrSize);
        AddTypeInfo(newTypeInfo);
        tiDesc->SetTypeInfoStatus(TypeInfoStatus::TYPEINFO_INITED);
        return;
    } else if (tt->IsCFunc()) {
        newTypeInfo->SetInstanceSize(ptrSize);
        newTypeInfo->SetAlign(ptrSize);
        return;
    }
    U32* offsets = reinterpret_cast<U32*>(Allocate(fieldNum * sizeof(U32)));
    newTypeInfo->SetOffsets(offsets);
    newTypeInfo->SetFieldAddr(reinterpret_cast<TypeInfo**>(Allocate(fieldNum * TYPEINFO_PTR_SIZE)));
}

void TypeInfoManager::FillRemainingField(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    if (tt->IsArrayType() || tt->IsCFunc()) {
        return;
    }
    TypeInfo* newTypeInfo = tiDesc->typeInfo;
    FillOffsets(newTypeInfo, tt, argSize, args);
    CalculateGCTib(newTypeInfo);
    TypeInfo* super = tt->GetSuperTypeInfo(argSize, args);
    newTypeInfo->SetSuperTypeInfo(super);
    AddTypeInfo(newTypeInfo);
    AddMTable(tt, newTypeInfo, argSize, args);
    if (tt->ReflectInfoIsNull()) {
        tiDesc->SetTypeInfoStatus(TypeInfoStatus::TYPEINFO_INITED);
        return;
    }
    if (tt->IsEnum() || tt->IsTempEnum()) {
        ParseEnumInfo(tt, argSize, args, newTypeInfo);
    } else {
        FillReflectInfo(tt, newTypeInfo);
    }
    tiDesc->SetTypeInfoStatus(TypeInfoStatus::TYPEINFO_INITED);
}

// Helper method to copy parameter information
void TypeInfoManager::CopyParameterInfos(MethodInfo* ttMethodInfo, MethodInfo* tiMethodInfo)
{
    U16 actualParamNum = ttMethodInfo->GetNumOfActualParameterInfos();
    if (actualParamNum == 0) {
        return;
    }
    uintptr_t paramInfosAddr = Allocate(sizeof(ParameterInfo) * actualParamNum);
    Uptr ttParamInfoStart = ttMethodInfo->GetActualParameterInfos();
    MapleRuntime::MemoryCopy(paramInfosAddr, sizeof(ParameterInfo) * actualParamNum,
        ttParamInfoStart, sizeof(ParameterInfo) * actualParamNum);
    ParameterInfo* tiParamInfos = reinterpret_cast<ParameterInfo*>(paramInfosAddr);
    tiMethodInfo->SetActualParameterInfos(reinterpret_cast<Uptr>(tiParamInfos));
    for (U32 paraIdx = 0; paraIdx < actualParamNum; ++paraIdx) {
        ParameterInfo* ttParamInfo = ttMethodInfo->GetActualParameterInfo(paraIdx, true);
        ParameterInfo* tiParamInfo = tiMethodInfo->GetActualParameterInfo(paraIdx, true);
        tiParamInfo->SetName(ttParamInfo->GetName());
    }
}

// Helper method to copy method information
void TypeInfoManager::CopyMethodInfo(MethodInfo* ttMethodInfo, MethodInfo* tiMethodInfo, TypeInfo* ti)
{
    MapleRuntime::MemoryCopy(reinterpret_cast<uintptr_t>(tiMethodInfo), sizeof(MethodInfo),
        reinterpret_cast<uintptr_t>(ttMethodInfo), sizeof(MethodInfo));
    tiMethodInfo->SetDeclaringTypeInfo(ti);
    tiMethodInfo->SetMethodName(ttMethodInfo->GetMethodName());
    tiMethodInfo->SetGenericParameterInfos(reinterpret_cast<Uptr>(ttMethodInfo->GetGenericParameterInfos()));
    CopyParameterInfos(ttMethodInfo, tiMethodInfo);
}

void TypeInfoManager::FillReflectInfo(TypeTemplate *tt, TypeInfo *ti)
{
    ReflectInfo* ttReflectInfo = tt->GetReflectInfo();
    if (!tt->ReflectIsEnable()) {
        ti->SetReflectInfo(ttReflectInfo);
        return;
    }
    if (ttReflectInfo == nullptr) {
        return;
    }
    size_t reflectInfoSize = sizeof(ReflectInfo);
    reflectInfoSize += ttReflectInfo->GetNumOfInstanceFieldInfos() * sizeof(DataRefOffset64<InstanceFieldInfo>);
    reflectInfoSize += ttReflectInfo->GetNumOfStaticFieldInfos() * sizeof(DataRefOffset64<StaticFieldInfo>);
    reflectInfoSize += ttReflectInfo->GetNumOfInstanceMethodInfos() * sizeof(DataRefOffset64<MethodInfo>);
    reflectInfoSize += ttReflectInfo->GetNumOfStaticMethodInfos() * sizeof(DataRefOffset64<MethodInfo>);
    uintptr_t reflectInfoAddr = Allocate(reflectInfoSize);
    MapleRuntime::MemoryCopy(reflectInfoAddr, reflectInfoSize,
        reinterpret_cast<uintptr_t>(ttReflectInfo), reflectInfoSize);
    // The fieldInfo does not need to be copied,
    // and the fieldInfo obtained directly from the reflectInfo in TypeTemplate
    ReflectInfo* tiReflectInfo = reinterpret_cast<ReflectInfo*>(reflectInfoAddr);
    tiReflectInfo->SetFieldNames(ttReflectInfo->GetFieldNames());
    tiReflectInfo->SetDeclaringGenericTypeInfo(reinterpret_cast<GenericTypeInfo*>(
            ttReflectInfo->GetDeclaringGenericTypeInfo()));
    for (U32 idx = 0; idx < ttReflectInfo->GetNumOfInstanceMethodInfos(); ++idx) {
        uintptr_t methodInfoAddr = Allocate(sizeof(MethodInfo));
        MethodInfo* ttMethodInfo = ttReflectInfo->GetInstanceMethodInfo(idx);
        MethodInfo* tiMethodInfo = reinterpret_cast<MethodInfo*>(methodInfoAddr);
        CopyMethodInfo(ttMethodInfo, tiMethodInfo, ti);
        tiReflectInfo->SetInstanceMethodInfo(idx, tiMethodInfo);
    }

    for (U32 idx = 0; idx < ttReflectInfo->GetNumOfStaticMethodInfos(); ++idx) {
        uintptr_t methodInfoAddr = Allocate(sizeof(MethodInfo));
        MethodInfo* ttMethodInfo = ttReflectInfo->GetStaticMethodInfo(idx);
        MethodInfo* tiMethodInfo = reinterpret_cast<MethodInfo*>(methodInfoAddr);
        CopyMethodInfo(ttMethodInfo, tiMethodInfo, ti);
        tiReflectInfo->SetStaticMethodInfo(idx, tiMethodInfo);
    }
    ti->SetReflectInfo(tiReflectInfo);
}

void TypeInfoManager::InitAnyAndObjectType()
{
    if (anyTi == nullptr) {
        auto it = nonGenericTypeInfos.find(CString("std.core:Any").Str());
        if (it != nonGenericTypeInfos.end()) {
            anyTi = it->second;
        }
    }

    if (objectTi == nullptr) {
        auto it = nonGenericTypeInfos.find(CString("std.core:Object").Str());
        if (it != nonGenericTypeInfos.end()) {
            objectTi = it->second;
        }
    }
}

void TypeInfoManager::CreatedTypeInfo(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    CreatedTypeInfoImpl(tiDesc, tt, argSize, args);
    if (tiDesc->IsIniting()) {
        FillRemainingField(tiDesc, tt, argSize, args);
    }
}

bool TypeInfoManager::IsEnumInfoReady(TypeTemplate* tt, TypeInfo* ti)
{
    if (ti->GetEnumInfo() != nullptr && ti->GetEnumInfo()->IsParsed()) {
        return true;
    }
    return false;
}

EnumInfo* TypeInfoManager::AllocateEnumInfo(EnumInfo* ttEnumInfo)
{
    size_t enumInfoSize = sizeof(EnumInfo);
    enumInfoSize += ttEnumInfo->GetNumOfInstanceMethodInfos() * sizeof(DataRefOffset64<MethodInfo>);
    enumInfoSize += ttEnumInfo->GetNumOfStaticMethodInfos() * sizeof(DataRefOffset64<MethodInfo>);
    // In early versions of enumInfo, there was no enum constructor's annotations field.
    // To ensure compatibility, enum constructor's annotations are processed only when
    // the reflect version is >= 2.
    if (ttEnumInfo->GetReflectVersion() >= 2) {
        enumInfoSize += ttEnumInfo->GetNumOfEnumCtor() * sizeof(Uptr);
    }
    uintptr_t enumInfoAddr = Allocate(enumInfoSize);
    MapleRuntime::MemoryCopy(enumInfoAddr, enumInfoSize,
        reinterpret_cast<uintptr_t>(ttEnumInfo), enumInfoSize);
    return reinterpret_cast<EnumInfo*>(enumInfoAddr);
}

EnumDebugInfo* TypeInfoManager::AllocateEnumDebugInfo(EnumInfo* ttEnumInfo)
{
    size_t enumDebugInfoSize = sizeof(EnumDebugInfo);
    uintptr_t enumDebugInfoAddr = Allocate(enumDebugInfoSize);
    MapleRuntime::MemoryCopy(enumDebugInfoAddr, enumDebugInfoSize,
        reinterpret_cast<uintptr_t>(ttEnumInfo), enumDebugInfoSize);
    return reinterpret_cast<EnumDebugInfo*>(enumDebugInfoAddr);
}

void TypeInfoManager::SetEnumConstructors(EnumDebugInfo* enumDebugInfo, EnumInfo* ttEnumInfo,
                                          U32 argSize, TypeInfo* args[])
{
    U32 enumCtorNum = ttEnumInfo->GetNumOfEnumCtor();
    size_t sizeOfEnumCtors = enumCtorNum * sizeof(EnumCtorInfo);
    uintptr_t enumCtorInfoAddr = Allocate(sizeOfEnumCtors);
    MapleRuntime::MemoryCopy(enumCtorInfoAddr, sizeOfEnumCtors,
        reinterpret_cast<uintptr_t>(ttEnumInfo->GetEnumCtor(0)), sizeOfEnumCtors);
    enumDebugInfo->SetEnumCtors(reinterpret_cast<void*>(enumCtorInfoAddr));

    for (U32 idx = 0; idx < enumCtorNum; ++idx) {
        EnumCtorInfo* ctor = enumDebugInfo->GetEnumCtor(idx);
        ctor->SetName(ttEnumInfo->GetEnumCtor(idx)->GetName());
        void* fn = reinterpret_cast<void*>(ctor->GetCtorFn());
        if (fn == nullptr) {
            continue;
        }
        TypeInfo* enumTi = reinterpret_cast<TypeInfo*>(TypeTemplate::ExecuteGenericFunc(fn, argSize, args));
        ctor->SetTypeInfo(enumTi);
    }
}

void TypeInfoManager::SetMethodInfos(EnumInfo* enumInfo, EnumInfo* ttEnumInfo, TypeInfo* ti)
{
    for (U32 idx = 0; idx < ttEnumInfo->GetNumOfInstanceMethodInfos(); ++idx) {
        uintptr_t methodInfoAddr = Allocate(sizeof(MethodInfo));
        MethodInfo* ttMethodInfo = ttEnumInfo->GetInstanceMethodInfo(idx);
        MethodInfo* tiMethodInfo = reinterpret_cast<MethodInfo*>(methodInfoAddr);
        CopyMethodInfo(ttMethodInfo, tiMethodInfo, ti);
        enumInfo->SetInstanceMethodInfo(idx, tiMethodInfo);
    }

    for (U32 idx = 0; idx < ttEnumInfo->GetNumOfStaticMethodInfos(); ++idx) {
        uintptr_t methodInfoAddr = Allocate(sizeof(MethodInfo));
        MethodInfo* ttMethodInfo = ttEnumInfo->GetStaticMethodInfo(idx);
        MethodInfo* tiMethodInfo = reinterpret_cast<MethodInfo*>(methodInfoAddr);
        CopyMethodInfo(ttMethodInfo, tiMethodInfo, ti);
        enumInfo->SetStaticMethodInfo(idx, tiMethodInfo);
    }
}

void TypeInfoManager::ParseEnumInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[], TypeInfo* ti)
{
#ifdef __arm__
    return;
#endif
    EnumInfo* ttEnumInfo = tt->GetEnumInfo();
    if (ttEnumInfo == nullptr || IsEnumInfoReady(tt, ti) || tt->IsEnumCtor()) {
        return;
    }
    if (!tt->ReflectIsEnable()) {
        EnumDebugInfo* enumDebugInfo = AllocateEnumDebugInfo(ttEnumInfo);
        ti->SetEnumDebugInfo(enumDebugInfo);
        SetEnumConstructors(enumDebugInfo, ttEnumInfo, argSize, args);
        return;
    }
    EnumInfo* enumInfo = AllocateEnumInfo(ttEnumInfo);
    SetEnumConstructors(enumInfo->GetEnumDebugInfo(), ttEnumInfo, argSize, args);
    if (!tt->ReflectIsEnable() || ttEnumInfo->GetReflectVersion() == 0) {
        enumInfo->SetParsed();
        ti->SetEnumInfo(enumInfo);
        return;
    }
    enumInfo->SetDeclaringGenericTypeInfo(reinterpret_cast<GenericTypeInfo*>(
        ttEnumInfo->GetDeclaringGenericTypeInfo()));
    SetMethodInfos(enumInfo, ttEnumInfo, ti);
    enumInfo->SetParsed();
    ti->SetEnumInfo(enumInfo);
}

void TypeInfoManager::AddMTable(TypeTemplate* tt, TypeInfo* newTypeInfo, U32 argSize, TypeInfo* args[])
{
    LoaderManager::GetInstance()->GetLoader()->VisitExtensionData(newTypeInfo,
        [argSize, args, newTypeInfo, this](ExtensionData* extensionData) {
        void* whereCondFn = reinterpret_cast<void*>(extensionData->GetWhereCondFn());
        uintptr_t matched = false;
        if (whereCondFn == nullptr) {
            matched = true;
        } else {
            // &0x1: The compiler returns the lower byte of rax, but the runtime must accept it using 64 bits.
            matched = reinterpret_cast<uintptr_t>(TypeTemplate::ExecuteGenericFunc(whereCondFn, argSize, args)) & 0x1;
        }
        if (matched) {
            TypeInfo* itf = extensionData->GetInterfaceTypeInfo(argSize, args);
            AddTypeInfo(itf);
            newTypeInfo->AddMTable(itf, extensionData);
        }
        return false;
        }, tt);
}

#ifdef __arm__
void TypeInfoManager::CalculateGCTib(TypeInfo* typeInfo)
{
    CString gcTibStr = typeGCInfo.GetGCTibStr(typeInfo);
    size_t len = gcTibStr.Length();
    GCTib gcTib;
    constexpr uint8_t alignSize = sizeof(uint64_t);
    // create StdGCTib
    U16 num = MRT_ALIGN(gcTibStr.Length(), alignSize) / alignSize;
    U16 needSpace = sizeof(U32) + sizeof(U8) * num;
    StdGCTib* stdGCTib = reinterpret_cast<StdGCTib*>(Allocate(needSpace));
    stdGCTib->nBitmapWords = num;
    U8 value = 0;
    size_t curIdx = 0;
    for (size_t idx = 0; idx < len; ++idx) {
        if (gcTibStr[idx] == '1') {
            value |= 1 << (idx % alignSize);
        }
        if ((idx + 1) % alignSize == 0) {
            stdGCTib->bitmapWords[curIdx++] = value;
            value = 0;
        }
    }
    if (len % alignSize != 0) {
        stdGCTib->bitmapWords[curIdx] = value;
    }
    gcTib.gctib = stdGCTib;
    typeInfo->SetGCTib(gcTib);
}
#else
void TypeInfoManager::CalculateGCTib(TypeInfo* typeInfo)
{
    CString gcTibStr = typeGCInfo.GetGCTibStr(typeInfo);
    size_t len = gcTibStr.Length();
    GCTib gcTib;
    constexpr uint8_t bitmapWordLength = 64;
    constexpr uint8_t alignSize = sizeof(uint64_t);
    if (len < bitmapWordLength) {
        U64 value = 0;
        for (size_t idx = 0; idx < len; ++idx) {
            if (gcTibStr[idx] == '1') {
                value |= (U64)1 << idx;
            }
        }
        value |= (U64)1 << (bitmapWordLength - 1);
        gcTib.tag = value;
        typeInfo->SetGCTib(gcTib);
    } else {
        // create StdGCTib
        // NOTE: If length is not divided by alignSize, special processing
        // is required for the assignment of num and bitmapWords.
        U16 num = gcTibStr.Length() / alignSize;
        U16 needSpace = sizeof(U32) + sizeof(U8) * num;
        StdGCTib* stdGCTib = reinterpret_cast<StdGCTib*>(Allocate(needSpace));
        stdGCTib->nBitmapWords = num;
        U8 value = 0;
        size_t curIdx = 0;
        for (size_t idx = 0; idx < len; ++idx) {
            if (gcTibStr[idx] == '1') {
                value |= 1 << (idx % alignSize);
            }
            if ((idx + 1) % alignSize == 0) {
                stdGCTib->bitmapWords[curIdx++] = value;
                value = 0;
            }
        }
        gcTib.gctib = stdGCTib;
        typeInfo->SetGCTib(gcTib);
    }
}
#endif

void TypeInfoManager::FillOffsets(TypeInfo* newTypeInfo, TypeTemplate* tt, U32 argSize, TypeInfo* args[])
{
    U32 instanceSize = 0;
    U8 align = 1; // If the field is empty, align is 1.
    bool hasRefField = false;
    U32 offset = 0;
    U32* offsets = newTypeInfo->GetFieldOffsets();
    if (tt->IsTuple() || tt->IsFunc()) {
        for (U32 fieldIdx = 0; fieldIdx < argSize; ++fieldIdx) {
            TypeInfo* fieldTi = args[fieldIdx];
            newTypeInfo->SetFieldType(fieldIdx, fieldTi);
            // Nothing and Unit type, size is 0
            if (fieldTi->IsNothing() || fieldTi->IsUnit()) {
                continue;
            }
            if (fieldTi->IsRef() || fieldTi->HasRefField()) {
                hasRefField = true;
            }
            U8 fieldTiAlign = fieldTi->IsRef() ? sizeof(BaseObject*) : fieldTi->GetAlign();
            offset = MRT_ALIGN(offset, fieldTiAlign);
            offsets[fieldIdx] = offset;
            align = align > fieldTiAlign ? align : fieldTiAlign;
            offset += TypeInfoManager::GetTypeSize(fieldTi);
        }
    } else {
        U32 fieldNum = tt->GetFieldNum();
        for (U16 fieldIdx = 0; fieldIdx < fieldNum; ++fieldIdx) {
            TypeInfo* fieldTi = tt->GetFieldType(fieldIdx, argSize, args);
            newTypeInfo->SetFieldType(fieldIdx, fieldTi);
            // Nothing and Unit type, size is 0
            if (fieldTi->IsNothing() || fieldTi->IsUnit()) {
                continue;
            }
            if (fieldTi->IsRef() || fieldTi->HasRefField()) {
                hasRefField = true;
            }
            U8 fieldTiAlign = fieldTi->IsRef() ? sizeof(BaseObject*) : fieldTi->GetAlign();
            offset = MRT_ALIGN(offset, fieldTiAlign);
            offsets[fieldIdx] = offset;
            align = align > fieldTiAlign ? align : fieldTiAlign;
            offset += TypeInfoManager::GetTypeSize(fieldTi);
        }
    }
    if (hasRefField) {
        newTypeInfo->SetFlagHasRefField();
    }
    if (newTypeInfo->IsRef()) {
        newTypeInfo->SetAlign(TYPEINFO_PTR_SIZE);
    } else {
        newTypeInfo->SetAlign(align);
    }
    instanceSize = MRT_ALIGN(offset, align);
    if (newTypeInfo->IsSyncClass()) {
        newTypeInfo->SetInstanceSize(CJFuture::SYNC_OBJECT_SIZE - 8); // the size of sync object payload
    } else {
        newTypeInfo->SetInstanceSize(instanceSize);
    }
}

U32 TypeInfoManager::GetTypeSize(TypeInfo* ti)
{
    I8 type = ti->GetType();
    switch (type) {
        case TypeKind::TYPE_KIND_NOTHING:
        case TypeKind::TYPE_KIND_UNIT:
            return 0;
        case TypeKind::TYPE_KIND_BOOL:
        case TypeKind::TYPE_KIND_RUNE:
        case TypeKind::TYPE_KIND_UINT8:
        case TypeKind::TYPE_KIND_UINT16:
        case TypeKind::TYPE_KIND_UINT32:
        case TypeKind::TYPE_KIND_UINT64:
        case TypeKind::TYPE_KIND_UINT_NATIVE:
        case TypeKind::TYPE_KIND_INT8:
        case TypeKind::TYPE_KIND_INT16:
        case TypeKind::TYPE_KIND_INT32:
        case TypeKind::TYPE_KIND_INT64:
        case TypeKind::TYPE_KIND_INT_NATIVE:
        case TypeKind::TYPE_KIND_FLOAT16:
        case TypeKind::TYPE_KIND_FLOAT32:
        case TypeKind::TYPE_KIND_FLOAT64:
        case TypeKind::TYPE_KIND_CSTRING:
        case TypeKind::TYPE_KIND_CPOINTER:
        case TypeKind::TYPE_KIND_CFUNC: {
            return ti->GetInstanceSize();
        }
        case TypeKind::TYPE_KIND_CLASS:
        case TypeKind::TYPE_KIND_EXPORTED_REF:
        case TypeKind::TYPE_KIND_FOREIGN_PROXY:
        case TypeKind::TYPE_KIND_WEAKREF_CLASS:
        case TypeKind::TYPE_KIND_INTERFACE:
        case TypeKind::TYPE_KIND_TEMP_ENUM:
        case TypeKind::TYPE_KIND_RAWARRAY:
        case TypeKind::TYPE_KIND_FUNC: {
            return sizeof(BaseObject*);
        }
        case TypeKind::TYPE_KIND_ENUM: {
            U16 fieldNum = ti->GetFieldNum();
            // The FE is to record the empty struct, and set instanceSize to 1.
            if (fieldNum == 0) {
                return ti->GetInstanceSize();
            }
            U32 totalSize = 0;
            for (U16 idx = 0; idx < fieldNum; ++idx) {
                TypeInfo* fieldTi = ti->GetFieldType(idx);
                // skip Nothing and Unit type, because size is 0
                if (fieldTi->IsNothing() || fieldTi->IsUnit()) {
                    continue;
                }
                U8 fieldTiAlign = fieldTi->IsRef() ? sizeof(BaseObject*) : fieldTi->GetAlign();
                totalSize = MRT_ALIGN(totalSize, fieldTiAlign);
                totalSize += GetTypeSize(fieldTi);
            }
            return MRT_ALIGN(totalSize, ti->GetAlign());
        }
        case TypeKind::TYPE_KIND_TUPLE:
        case TypeKind::TYPE_KIND_STRUCT: {
            U16 fieldNum = ti->GetFieldNum();
            U32 totalSize = 0;
            for (U16 idx = 0; idx < fieldNum; ++idx) {
                TypeInfo* fieldTi = ti->GetFieldType(idx);
                // skip Nothing and Unit type, because size is 0
                if (fieldTi->IsNothing() || fieldTi->IsUnit()) {
                    continue;
                }
                U8 fieldTiAlign = fieldTi->IsRef() ? sizeof(BaseObject*) : fieldTi->GetAlign();
                totalSize = MRT_ALIGN(totalSize, fieldTiAlign);
                totalSize += GetTypeSize(fieldTi);
            }
            return MRT_ALIGN(totalSize, ti->GetAlign());
        }
        case TypeKind::TYPE_KIND_VARRAY: {
            U16 fieldNum = ti->GetFieldNum();
            TypeInfo* componentTi = ti->GetComponentTypeInfo();
            U16 align = componentTi->GetAlign();
            U32 totalSize = 0;
            for (U16 idx = 0; idx < fieldNum; ++idx) {
                totalSize = MRT_ALIGN(totalSize, align);
                totalSize += GetTypeSize(componentTi);
            }
            return MRT_ALIGN(totalSize, align);
        }
        default:
            LOG(RTLOG_FATAL, "TypeInfoManager::GetTypeSize no type matched type: %d", type);
    }
    return 0;
}

uintptr_t TypeInfoManager::Allocate(size_t size)
{
// TypeInfo related content needs four-byte aligned to prevent fields from being overwritten incorrectly.
#ifdef __arm__
    size = MRT_ALIGN(size, sizeof(uint32_t));
#endif
    uintptr_t addr = position.fetch_add(size);
    if (addr + size > endAddress) {
        NewMMap(mapMemory);
        addr = position.fetch_add(size);
    }
    return addr;
}
} // namespace MapleRuntime
