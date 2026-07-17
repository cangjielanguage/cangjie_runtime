// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "ObjectModel/MClass.h"

#include "Base/Globals.h"
#include "Common/TypeDef.h"
#include "ExceptionManager.inline.h"
#include "Interpreter/Options.h"
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

#ifdef INTERPRETER_ENABLED
#include "Interpreter/RuntimeTypes.h"
#endif

namespace MapleRuntime {
#ifdef __arm__
const size_t TYPEINFO_PTR_SIZE = sizeof(TypeInfo*) + 4;
#else
const size_t TYPEINFO_PTR_SIZE = sizeof(TypeInfo*);
#endif

typedef void *(*GenericiFn)(U32 size, TypeInfo* args[]);

TypeInfo* ExtensionData::GetInterfaceTypeInfo(U32 argsNum, TypeInfo** args) const
{
    if (isInterfaceTypeInfo) {
        return interfaceTypeInfo;
    }
    void* iFn = reinterpret_cast<void*>(interfaceFn);
    TypeInfo* itf = reinterpret_cast<TypeInfo*>(TypeTemplate::ExecuteGenericFunc(iFn, argsNum, args));
    return itf;
}

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

ReflectInfo* TypeInfo::GetReflectInfo() const
{
    return reflectInfo;
}

U8 TypeInfo::GetReflectionVersion() const
{
    if (!ReflectIsEnable()) {
        return 0;
    }
    if (IsEnum() || IsTempEnum()) {
        EnumInfo* enumInfo = GetEnumInfo();
        if (enumInfo != nullptr) {
            return enumInfo->GetReflectVersion();
        }
    } else {
        ReflectInfo* reflectInfo = GetReflectInfo();
        if (reflectInfo != nullptr) {
            return reflectInfo->GetReflectVersion();
        }
    }
    return 0;
}

TypeInfo* TypeTemplate::GetFieldType(U16 fieldIdx, U32 argSize, TypeInfo* args[])
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

void TypeInfo::SetEnumDebugInfo(EnumDebugInfo* enumDebugInfo)
{
    this->enumDebugInfo = enumDebugInfo;
}

void TypeInfo::TryInitMTable()
{
    if (IsMTableDescUnInitialized()) {
        TypeInfoManager& manager = TypeInfoManager::GetTypeInfoManager();
        std::lock_guard<std::recursive_mutex> lock(manager.tiMutex);
        TryInitMTableNoLock();
    }
}

MTableDesc::MTableDesc(ArchUInt bitmap_)
{
    mTableBitmap.tag = bitmap_;
}

void TypeInfo::TryInitMTableNoLock()
{
    if (IsMTableDescUnInitialized()) {
        auto tiUUID = GetUUID();
        auto& tim = TypeInfoManager::GetTypeInfoManager();
        auto desc = tim.GetMTableDesc(tiUUID);
        if (desc == nullptr) {
            ArchUInt bitmap = GetResolveBitmapFromMTableDesc();
            desc = new (std::nothrow) MTableDesc(bitmap);
            CHECK_DETAIL(desc != nullptr, "fail to allocate MTableDesc");
            tim.RecordMTableDesc(tiUUID, desc);
        }
        SetMTableDesc(desc);
    }
}

namespace {
inline bool IsSameRootPackage(TypeInfo* itf1, TypeInfo* itf2)
{
    auto name1 = itf1->GetName();
    auto name2 = itf2->GetName();
    U32 pos = 0U;
    char ch = name1[pos];
    while (ch == name2[pos]) {
        if (ch == '.' || ch == ':') {
            return true;
        }
        ++pos;
        ch = name1[pos];
        if ((ch == ':' && name2[pos] == '.') || (ch == '.' && name2[pos] == ':')) {
            return true;
        }
    }
    return false;
}
};

/**
 * Since adding a virtual method at the end of the virtual function table of an interface/class
 * is ABI compatible, the runtime needs to update the funcTable field of ExtensionData. For
 * TypeInfo and the ExtensionData of its interface TypeInfo, it is updated by the ExtensionData
 * of the interface TypeInfo itself.
 *
 * for example,
 *
 * ** Initially, **
 *
 * `I1` is an interface defined in pkgA, and has 1 virtual method `foo`, its self's ExtensionData:
 *    { ..., .ti = I1, .interfaceTi = I1, .funcTableSize = 1, ..., .funcTablePtr = &[foo] }
 *
 * `CA` is a class defined in pkgB, and implements `I1`, ExtensionData of `CA` and `I1`:
 *    { ..., .ti = CA, .interfaceTi = I1, .funcTableSize = 1, ..., .funcTablePtr = &[foo] }
 *
 * ** Then **
 *
 * a virtual method `goo` is added to `I1`, `I1`'s ExtensionData in binary becomes:
 *    { ..., .ti = I1, .interfaceTi = I1, .funcTableSize = 2, ..., .funcTablePtr = &[foo, goo] }
 *
 * But pkgB will not be recompiled. So ExtensionData of `CA` and `I1` will be refreshed at runtime
 * as:
 *    { ..., .ti = CA, .interfaceTi = I1, .funcTableSize = 2, ..., .funcTablePtr = &[foo, goo] }
 *
 */
void TypeInfo::TryUpdateExtensionData(TypeInfo* itf, ExtensionData* extensionData)
{
    auto itfUUID = itf->GetUUID();
    if (this->GetUUID() == itfUUID) {
        return;
    }
    do {
        if (LIKELY(extensionData->IsFuncTableUpdated())) {
            return;
        }

        auto itfVExtensionDataStart = itf->GetvExtensionDataStart();
        CHECK_DETAIL(itfVExtensionDataStart != nullptr, "itfVExtensionDataStart is nullptr, ti: %s, itf: %s",
                     GetName(), itf->GetName());
        auto itfExtData = itf->IsInterface() ? *itfVExtensionDataStart
                                            : *(itfVExtensionDataStart + itf->GetValidInheritNum() - 1);
        auto ftSize = extensionData->GetFuncTableSize();
        auto itfFtSize = itfExtData->GetFuncTableSize();
        auto incrementalSize = itfFtSize - ftSize;
        if (incrementalSize == 0) {
            extensionData->SetFuncTableUpdated();
            return;
        }
        CHECK_DETAIL(incrementalSize > 0, "An incompatible module is imported.");

        if (!extensionData->TryLockFuncTable()) {
            continue;
        }

        TryInitMTable();
        TraverseInnerExtensionDefs();
        auto& mTable = mTableDesc->mTable;
        for (const auto& superTypePair : mTable) {
            auto superTi = superTypePair.second.GetSuperTi();
            // make sure super is the subtype of itf, and super is the direct super type of this type.
            if (!superTypePair.second.GetExtensionData()->IsDirect()) {
                continue;
            }
            auto edOfSuper = superTi->FindExtensionData(itf);
            if (edOfSuper) {
                if (UNLIKELY(!edOfSuper->IsFuncTableUpdated())) {
                    superTi->TryUpdateExtensionData(itf, edOfSuper);
                }
                bool hasOuterTiFast = extensionData->HasOuterTiFastPath();
                size_t newFtSize = hasOuterTiFast ? itfFtSize * sizeof(FuncPtr) + itfFtSize * sizeof(OuterTiUnion)
                                                  : itfFtSize * sizeof(FuncPtr);
                FuncPtr* newFt = reinterpret_cast<FuncPtr*>(
                    TypeInfoManager::GetTypeInfoManager().Allocate(newFtSize));
                if (ftSize > 0) {
                    CHECK(memcpy_s(reinterpret_cast<void*>(newFt),
                                   sizeof(FuncPtr) * ftSize,
                                   reinterpret_cast<void*>(extensionData->GetFuncTable()),
                                   sizeof(FuncPtr) * ftSize) == EOK);
                }
                CHECK(memcpy_s(reinterpret_cast<void*>(newFt + ftSize),
                               sizeof(FuncPtr) * incrementalSize,
                               reinterpret_cast<void*>(edOfSuper->GetFuncTable() + ftSize),
                               sizeof(FuncPtr) * incrementalSize) == EOK);
                if (!hasOuterTiFast) {
                    break;
                }
                if (ftSize > 0) {
                        CHECK(memcpy_s(reinterpret_cast<void*>(newFt + itfFtSize),
                                       sizeof(OuterTiUnion) * ftSize,
                                       reinterpret_cast<void*>(extensionData->GetFuncTable() + ftSize),
                                       sizeof(OuterTiUnion) * ftSize) == EOK);
                }
                CHECK(memset_s(reinterpret_cast<void*>(newFt + itfFtSize + ftSize),
                               sizeof(OuterTiUnion) * incrementalSize,
                               0, sizeof(OuterTiUnion) * incrementalSize) == EOK);
                extensionData->UpdateFuncTable(itfFtSize, newFt);
                break;
            }
        }
        mTable.find(itfUUID)->second.ResetAtomicInfoArray(itfFtSize);
        extensionData->SetFuncTableUpdated();
    } while (true);
}

// This interface mustn't be invoked locklessly.
void TypeInfo::AddMTable(TypeInfo* itf, ExtensionData* extensionData)
{
    TryInitMTableNoLock();
    U32 itfUUID = itf->GetUUID();
    CHECK(itfUUID != 0);
    auto& mTable = GetMTableDesc()->mTable;
    auto it = mTable.find(itfUUID);
    if (it == mTable.end()) {
        mTable.emplace(itfUUID, InheritFuncTable(extensionData, itf, extensionData->GetFuncTableSize()));
    }
}

static bool ResolveExtensionData(
    TypeInfo* ti, TypeInfo* resolveTi, ExtensionData* extensionData, bool needCheckStop = false,
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
        TypeInfo* extItf = extensionData->GetInterfaceTypeInfo(typeArgNum, typeArgs);
        if (getInterface != nullptr) {
            getInterface(extItf);
        }
        ti->AddMTable(extItf, extensionData);
    }
    return true;
}

static void ResolveInnerExtensionDefs(
    TypeInfo* ti, TypeInfo* resolveTi, const std::function<void(TypeInfo*)> getInterface)
{
    // Normally, after all ExtensionDefs of the class are loaded, the branch should not enter again.
    // ExtensionDatas = [A_A, B_A, B_B, B_I1, B_I2, ..., C_A, C_B, C_C, C_I1, ...]. If this is C, and itf is I1,
    // then vExtensionDataStart is pointed to C_A, and validInheritNum is 2. Therefore, to get C_I1, we need to add
    // the offset value of ptrSize*validInheritNum.
    resolveTi->TryInitMTable();
    // The MTable of `resolveTi` has been completed already, and can be merged into MTable of `ti`.
    if (!resolveTi->GetMTableDesc()->NeedResolveInner()) {
        if (ti == resolveTi) {
            return;
        }
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
    if (ti == resolveTi) {
        // update mtable
        U16 cnt = 0;
        while (cnt < initIndex) {
            ResolveExtensionData(ti, resolveTi, *vExtensionPtr, true, getInterface);
            ++vExtensionPtr;
            ++cnt;
        }
    } else {
        vExtensionPtr += initIndex;
    }
    MTableBitmap& bitmap = resolveTi->GetMTableDesc()->mTableBitmap;
    if (bitmap.tag != 0) {
        bitmap.ForEachBit(
            [ti, resolveTi, getInterface](ExtensionData* extensionData) {
                ResolveExtensionData(ti, resolveTi, extensionData, false, getInterface);
            }, vExtensionPtr);
        return;
    }
    while (true) {
        auto res = ResolveExtensionData(ti, resolveTi, *vExtensionPtr, true, getInterface);
        if (!res) {
            break;
        }
        ++vExtensionPtr;
    }
}

void TypeInfo::TraverseInnerExtensionDefs(const std::function<void(TypeInfo*)> getInterface)
{
    if (!this->mTableDesc->needsResolveInner) {
        return;
    }
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
    this->mTableDesc->needsResolveInner = false;
}

void TypeInfo::TraverseOuterExtensionDefs(const std::function<void(TypeInfo*)> getInterface)
{
    if (!this->mTableDesc->NeedResolveOuter()) {
        return;
    }
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
    LoaderManager::GetInstance()->GetLoader()->VisitExtensionData(this,
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
                TypeInfo* extItf = extensionData->GetInterfaceTypeInfo(typeArgNum, typeArgs);
                if (getInterface != nullptr) {
                    getInterface(extItf);
                }
                TypeInfoManager::GetTypeInfoManager().AddTypeInfo(extItf);
                this->AddMTable(extItf, extensionData);
            }
            return false;
        },
        sourceGeneric);
    this->mTableDesc->needsResolveOuter = false;
}

void TypeInfo::GetInterfaces(std::vector<TypeInfo*> &itfs)
{
    TryInitMTable();
    TraverseInnerExtensionDefs();
    if (IsGenericTypeInfo()) {
        TraverseOuterExtensionDefs();
    }
    for (const auto& pair : mTableDesc->mTable) {
        auto super = pair.second.GetSuperTi();
        if (super->IsInterface()) {
            itfs.emplace_back(super);
        }
    }
}

ExtensionData* TypeInfo::FindExtensionDataRecursively(TypeInfo* itf)
{
    if (this->GetUUID() == itf->GetUUID() || IsSameRootPackage(this, itf)) {
        return nullptr;
    }

    std::lock_guard<std::recursive_mutex> lock(mTableDesc->mTableMutex);
    for (const auto& pair : mTableDesc->mTable) {
        if (pair.first == GetUUID()) {
            // Avoid infinite recursion. The mTAble may contain itself.
            continue;
        }
        auto super = pair.second.GetSuperTi();
        auto found = super->FindExtensionData(itf, true);
        if (found) {
            // This won't cause the issue of iterator invalidation since the function will exit immediately.
            mTableDesc->mTable.emplace(itf->GetUUID(), InheritFuncTable(found, itf, found->GetFuncTableSize()));
            return found;
        }
    }
    return nullptr;
}

ExtensionData* TypeInfo::FindExtensionData(TypeInfo* itf, bool searchRecursively)
{
    TryInitMTable();
    auto itfUUID = itf->GetUUID();
    if (!mTableDesc->IsFullyHandled()) {
        std::lock_guard<std::recursive_mutex> lock(mTableDesc->mTableMutex);
        if (!mTableDesc->IsFullyHandled()) {
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
                    return it->second.GetExtensionData();
                } else {
                    return itf->IsInterface() && searchRecursively ? FindExtensionDataRecursively(itf) : nullptr;
                }
            }
            TraverseInnerExtensionDefs();
            TraverseOuterExtensionDefs();
        }
    }
    auto& mTable = mTableDesc->mTable;
    auto it = mTable.find(itfUUID);
    if (it != mTable.end()) {
        return it->second.GetExtensionData();
    }
    return itf->IsInterface() && searchRecursively ? FindExtensionDataRecursively(itf) : nullptr;
}

FuncPtr* TypeInfo::GetMTable(TypeInfo* itf)
{
    if (GetUUID() == 0) {
        TypeInfoManager::GetTypeInfoManager().AddTypeInfo(this);
    }
    if (UNLIKELY(IsTempEnum() && GetSuperTypeInfo())) {
        return GetSuperTypeInfo()->GetMTable(itf);
    }
    // Fast path: mTable ready and entry found with func table already updated
    if (LIKELY(!IsMTableDescUnInitialized() && mTableDesc->IsFullyHandled())) {
        const U32 itfUUID = itf->GetUUID();
        auto it = mTableDesc->mTable.find(itfUUID);
        if (it != mTableDesc->mTable.end()) {
            ExtensionData* ed = it->second.GetExtensionData();
            if (LIKELY(ed->IsFuncTableUpdated())) {
                return ed->GetFuncTable();
            }
        }
    }
    auto extensionData = FindExtensionData(itf, true);
    if (UNLIKELY(extensionData == nullptr)) {
        LOG(RTLOG_FATAL, "extensionData is nullptr, ti: %s, itf: %s", GetName(), itf->GetName());
    }
    if (UNLIKELY(!extensionData->IsFuncTableUpdated())) {
        TryUpdateExtensionData(itf, extensionData);
    }
    FuncPtr* funcTable = extensionData->GetFuncTable();
    CHECK(funcTable);
    return funcTable;
}

TypeInfo* TypeInfo::GetMethodOuterTI(TypeInfo* itf, U64 index)
{
    U32 itfUUID = itf->GetUUID();
    if (this == itf || this->GetUUID() == itfUUID) {
        return this;
    }
    TypeInfo* superTi = GetSuperTypeInfo();
    if (UNLIKELY(IsTempEnum() && superTi != nullptr)) {
        return superTi->GetMethodOuterTI(itf, index);
    }
    if (UNLIKELY(IsMTableDescUnInitialized() || !mTableDesc->IsFullyHandled())) {
        (void)FindExtensionData(itf, true);
    }
    auto& mTable = mTableDesc->mTable;
    auto it = mTable.find(itfUUID);
    if (it == mTable.end()) {
        LOG(RTLOG_FATAL, "expected interface %s is not in class %s", itf->GetName(), GetName());
        return nullptr;
    }
    auto* outerTi = it->second.GetCachedTypeInfo(index);
    if (LIKELY(outerTi != nullptr)) {
        return outerTi;
    }
    auto* ed = it->second.GetExtensionData();
    CHECK(ed != nullptr);
    outerTi = ed->GetOuterTi(this, index);
    if (outerTi != nullptr) {
        it->second.SetCachedTypeInfo(index, outerTi);
        return outerTi;
    }
    // Cache miss and GetOuterTi returned null: resolve by walking supers.
    FuncPtr* funcTable = ed->GetFuncTable();
    FuncPtr funcPtr = funcTable[index];
    for (const auto& superTypePair : mTable) {
        ExtensionData* thisEdSuper = superTypePair.second.GetExtensionData();
        if (!thisEdSuper->IsTargetHasSameSourceWith(this)) {
            continue;
        }
        TypeInfo* superTi = superTypePair.second.GetSuperTi();
        if (superTi == this || superTi->GetUUID() == GetUUID()) {
            continue;
        }
        auto* superEdItf = superTi->FindExtensionData(itf);
        if (superEdItf == nullptr) {
            continue;
        }
        FuncPtr funcPtrInSuper = superEdItf->GetFuncTable()[index];
        if (funcPtrInSuper == nullptr) {
            continue;
        }
        if (funcPtrInSuper == funcPtr) {
            TypeInfo* res = superTi->GetMethodOuterTI(itf, index);
            it->second.SetCachedTypeInfo(index, res);
            return res;
        }
        if (thisEdSuper->IsDirect()) {
            break;
        }
    }
    it->second.SetCachedTypeInfo(index, this);
    return this;
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
        CHECK(objectTi != nullptr);
        if (typeInfo == objectTi) {
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
        bool isSubType = FindExtensionData(typeInfo, true) != nullptr;
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

static U8 GetReflectVersionFromModifier(U32 modifier)
{
    U8 version = 0;
    if (modifier & MODIFIER_REFLECT_VER_BIT1) {
        version |= 1;
    }
    if (modifier & MODIFIER_REFLECT_VER_BIT2) {
        version |= 2;
    }
    if (modifier & MODIFIER_REFLECT_VER_BIT3) {
        version |= 4;
    }
    return version;
}

U8 ReflectInfo::GetReflectVersion() const
{
    return GetReflectVersionFromModifier(GetModifier());
}

U8 EnumInfo::GetReflectVersion() const
{
    return GetReflectVersionFromModifier(GetModifier());
}

static void* GetAnnotations(Uptr annotationMethod, TypeInfo* arrayTi)
{
    CHECK_DETAIL(arrayTi != nullptr, "arrayTi is nullptr");
    ScopedAllocBuffer scopedAllocBuffer;
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
    return obj;
}

bool TypeInfo::ReflectIsEnable() const { return static_cast<bool>(flag & FLAG_REFLECTION); }

bool TypeTemplate::ReflectIsEnable() const { return static_cast<bool>(flag & FLAG_REFLECTION); }

bool TypeTemplate::IsEnumCtor() const
{
    if (!IsEnum() && !IsTempEnum()) {
        return false;
    }
    // The current SDK emits enum constructor with empty enumInfo,
    // so enumInfo == nullptr indicates an enum constructor.
    // Earlier versions emitted enum constructor with non-empty enumInfo and
    // MODIFIER_ENUM_CTOR flag set in the modifier; such cases are not handled
    // here and would be misidentified as the enum itself.
    if (enumInfo == nullptr) {
        return true;
    }
    return false;
}

void* ReflectInfo::GetAnnotations(TypeInfo* arrayTi)
{
    return MapleRuntime::GetAnnotations(annotationMethod, arrayTi);
}

U32 TypeInfo::GetModifier() const
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return MODIFIER_INVALID;
    }
    if (IsEnum()) {
        return enumInfo != nullptr ? enumInfo->GetModifier() : MODIFIER_INVALID;
    } else {
        ReflectInfo* reflectInfo = GetReflectInfo();
        return reflectInfo != nullptr ? reflectInfo->GetModifier() : MODIFIER_INVALID;
    }
}
bool TypeInfo::IsEnumCtor() const
{
    if (!IsEnum() && !IsTempEnum()) {
        return false;
    }
    // The current SDK emits enum constructor with empty enumInfo,
    // so enumInfo == nullptr indicates an enum constructor.
    // Earlier versions emitted enum constructor with non-empty enumInfo and
    // MODIFIER_ENUM_CTOR flag set in the modifier; such cases are not handled
    // here and would be misidentified as the enum itself.
    if (enumInfo == nullptr) {
        return true;
    }
    return false;
}

bool TypeInfo::IsOptionLikeRefEnum()
{
    if (!IsEnum() && !IsTempEnum()) {
        return false;
    }
    EnumInfo* enumInfo = GetEnumInfo();
    if (IsEnumCtor()) {
        enumInfo = GetSuperTypeInfo()->GetEnumInfo();
    }
    if (!enumInfo->IsEnumKind2()) {
        return false;
    }
    if (!GetFieldType(0)->IsBool()) {
        return true;
    }
    return false;
}

bool TypeInfo::IsZeroSizedEnum()
{
    if (!IsEnum() && !IsTempEnum()) {
        return false;
    }
    if (IsEnumCtor()) {
        return GetInstanceSize() == 0;
    }
    EnumInfo* enumInfo = GetEnumInfo();
    if (!enumInfo->IsEnumKind0()) {
        return false;
    }
    U32 ctorNum = enumInfo->GetNumOfEnumCtor();
    if (ctorNum != 1) {
        return false;
    }
    TypeInfo* ctorTypeInfo = enumInfo->GetCtorTypeInfo(0);
    if (ctorTypeInfo->GetInstanceSize() == 0) {
        return true;
    }
    return false;
}

bool TypeInfo::IsOptionLikeUnassociatedCtor()
{
    if (!IsEnumCtor()) {
        return false;
    }
    EnumInfo* enumInfo = GetSuperTypeInfo()->GetEnumInfo();
    if (!enumInfo->IsEnumKind2()) {
        return false;
    }
    U32 num = enumInfo->GetNumOfEnumCtor();
    for (U32 idx = 0; idx < num; idx++) {
        TypeInfo* ctorTi = enumInfo->GetCtorTypeInfo(idx);
        if (ctorTi->GetUUID() == GetUUID()) {
            CString ctorName = CString(enumInfo->GetEnumCtor(idx)->GetName());
            return ctorName.StartWith("N$_");
        }
    }
    return false;
}

bool TypeInfo::IsEnumKind1()
{
    if (!IsEnum() && !IsTempEnum()) {
        return false;
    }
    EnumInfo* enumInfo = nullptr;
    if (IsEnumCtor()) {
        enumInfo = GetSuperTypeInfo()->GetEnumInfo();
    } else {
        enumInfo = GetEnumInfo();
    }
    CHECK_DETAIL(enumInfo != nullptr, "EnumInfo is nullptr.");
    return enumInfo->IsEnumKind1();
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
    if (IsEnum() || IsTempEnum()) {
        return GetEnumInfo()->GetNumOfInstanceMethodInfos();
    }
    return GetReflectInfo()->GetNumOfInstanceMethodInfos();
}

U32 TypeInfo::GetNumOfStaticMethodInfos()
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    if (IsEnum() || IsTempEnum()) {
        return GetEnumInfo()->GetNumOfStaticMethodInfos();
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
    if (IsEnum() || IsTempEnum()) {
        return GetEnumInfo()->GetInstanceMethodInfo(index);
    }
    return GetReflectInfo()->GetInstanceMethodInfo(index);
}

MethodInfo* TypeInfo::GetStaticMethodInfo(U32 index)
{
    if (IsEnum() || IsTempEnum()) {
        return GetEnumInfo()->GetStaticMethodInfo(index);
    }
    return GetReflectInfo()->GetStaticMethodInfo(index);
}

U32 TypeInfo::GetNumOfEnumCtor()
{
    CHECK_DETAIL(IsEnum() || IsTempEnum(), "To get the number of constructors, but the type is not Enum.");
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        return 0;
    }
    return GetEnumInfo()->GetNumOfEnumCtor();
}

EnumCtorInfo* TypeInfo::GetEnumCtor(U32 idx)
{
    CHECK_DETAIL(IsEnum() || IsTempEnum(), "To get the Enum's constructor, but the type is not Enum.");
    return GetEnumInfo()->GetEnumCtor(idx);
}

void* TypeInfo::GetAnnotations(TypeInfo* arrayTi)
{
    if ((IsGenericTypeInfo() && !GetSourceGeneric()->ReflectIsEnable()) || !ReflectIsEnable()) {
        // reflect is not enabled, return empty array.
        return MapleRuntime::GetAnnotations(0, arrayTi);
    }
    if (IsEnum() || IsTempEnum()) {
        if (!IsEnumCtor()) {
            return GetEnumInfo()->GetAnnotations(arrayTi);
        }
        EnumInfo* ei = GetSuperTypeInfo()->GetEnumInfo();
        if (ei == nullptr) {
            return MapleRuntime::GetAnnotations(0, arrayTi);
        }
        if (ei->GetReflectVersion() < 2) {
            // Versions earlier than 2 do not support getting enum constructor's annotations.
            return MapleRuntime::GetAnnotations(0, arrayTi);
        }
        U32 num = ei->GetNumOfEnumCtor();
        if (IsGenericTypeInfo()) {
            EnumInfo* sourceEi = GetSuperTypeInfo()->GetSourceGeneric()->GetEnumInfo();
            if (sourceEi == nullptr) {
                return MapleRuntime::GetAnnotations(0, arrayTi);
            }
            for (U32 idx = 0; idx < num; idx++) {
                if (ei->GetCtorTypeInfo(idx)->GetUUID() == GetUUID()) {
                    return sourceEi->GetCtorAnnotations(idx, arrayTi);
                }
            }
            return MapleRuntime::GetAnnotations(0, arrayTi);
        }
        for (U32 idx = 0; idx < num; idx++) {
            if (ei->GetCtorTypeInfo(idx)->GetUUID() == GetUUID()) {
                return ei->GetCtorAnnotations(idx, arrayTi);
            }
        }
        return MapleRuntime::GetAnnotations(0, arrayTi);
    }
    return GetReflectInfo()->GetAnnotations(arrayTi);
}

FuncRef TypeInfo::GetFinalizeMethod() const
{
    if (GetTypeArgNum() == 0) {
        return finalizerMethod;
    } else {
        return GetSourceGeneric()->GetFinalizeMethod();
    }
}

bool TypeInfo::NeedRefresh()
{
    // TypeInfo refresh is exclusively required for classes with type arguments.
    if (type != TypeKind::TYPE_KIND_CLASS || typeArgsNum == 0) {
        return false;
    }

    // For class:
    // 1) if this TypeInfo has the same number of fields with its TypeTemplate, it means no
    // need to be refreshed.
    if (GetFieldNum() == GetSourceGeneric()->GetFieldNum()) {
        return false;
    }
    // 2) if its TypeInfo does not set extension part bit, it may be compiled by previous SDK,
    // so always refresh the TypeInfo for correctness.
    if (!HasExtPart()) {
        return true;
    }
    // 3) if this TypeInfo does not have extension part, refresh the TypeInfo.
    auto typeExt = LoaderManager::GetInstance()->GetLoader()->GetTypeExt(this);
    if (typeExt == nullptr) {
        return true;
    }
    // 4) if its TypeInfo has extension part, but the first byte of content is `0`, it means the
    // TypeInfo needs to be refreshed.
    if (*reinterpret_cast<uint8_t*>(typeExt->content) == 0) {
        return true;
    }
    return false;
}

EnumCtorInfo* EnumInfo::GetEnumCtor(U32 idx) const
{
    CHECK(idx < GetNumOfEnumCtor());
    EnumCtorInfo* enumCtorInfo = enumDebugInfo.enumCtorInfos.GetDataRef();
    return enumCtorInfo + idx;
}

TypeInfo* EnumInfo::GetCtorTypeInfo(U32 idx) const
{
    CHECK(idx < GetNumOfEnumCtor());
    EnumCtorInfo* enumCtorInfo = GetEnumCtor(idx);
    return enumCtorInfo->GetTypeInfo();
}

EnumCtorInfo* EnumDebugInfo::GetEnumCtor(U32 idx) const
{
    CHECK(idx < enumCtorInfoCnt);
    EnumCtorInfo* enumCtorInfo = enumCtorInfos.GetDataRef();
    return enumCtorInfo + idx;
}

void EnumDebugInfo::SetEnumCtors(void* ctors)
{
    enumCtorInfos.refOffset = reinterpret_cast<Uptr>(ctors) - reinterpret_cast<Uptr>(this);
}

void* EnumInfo::GetAnnotations(TypeInfo* arrayTi)
{
    return MapleRuntime::GetAnnotations(annotationMethod, arrayTi);
}

void* EnumInfo::GetCtorAnnotations(U32 idx, TypeInfo* arrayTi)
{
    return MapleRuntime::GetAnnotations(GetCtorAnnotationMethod(idx), arrayTi);
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

Uptr EnumInfo::GetCtorAnnotationMethod(U32 index) const
{
    CHECK(index < GetNumOfEnumCtor());
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += staticMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += index * sizeof(Uptr);
    return *reinterpret_cast<Uptr*>(baseAddr);
}

void EnumInfo::SetInstanceMethodInfo(U32 idx, MethodInfo* methodInfo)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += idx * sizeof(DataRefOffset64<MethodInfo>);
    I64* addr = reinterpret_cast<I64*>(baseAddr);
    *addr = reinterpret_cast<Uptr>(methodInfo) - reinterpret_cast<Uptr>(addr);
}

void EnumInfo::SetStaticMethodInfo(U32 idx, MethodInfo* methodInfo)
{
    Uptr baseAddr = GetBaseAddr();
    baseAddr += instanceMethodCnt * sizeof(DataRefOffset64<MethodInfo>);
    baseAddr += idx * sizeof(DataRefOffset64<MethodInfo>);
    I64* addr = reinterpret_cast<I64*>(baseAddr);
    *addr = reinterpret_cast<Uptr>(methodInfo) - reinterpret_cast<Uptr>(addr);
}
void EnumCtorInfo::SetName(const char* pName)
{
    name.refOffset = reinterpret_cast<Uptr>(pName) - reinterpret_cast<Uptr>(this);
}

#ifdef INTERPRETER_ENABLED
struct TypeInfoLayoutCheck {
    // Static layout checks: DYN_TypeInfo is a binary mirror of TypeInfo.
    static void CheckInterpreterMirror()
    {
        static_assert(sizeof(DYN_TypeInfo) == sizeof(TypeInfo), "DYN_TypeInfo size must match TypeInfo");
        static_assert(__builtin_offsetof(DYN_TypeInfo, typeInfoName) == __builtin_offsetof(TypeInfo, typeInfoName),
            "typeInfoName offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, type) == __builtin_offsetof(TypeInfo, type), "type offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, flag) == __builtin_offsetof(TypeInfo, flag), "flag offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, fieldNum) == __builtin_offsetof(TypeInfo, fieldNum),
            "fieldNum offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, instanceSize) == __builtin_offsetof(TypeInfo, instanceSize),
            "instanceSize offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, gctib) == __builtin_offsetof(TypeInfo, gctib), "gctib offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, uuid) == __builtin_offsetof(TypeInfo, uuid), "uuid offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, align) == __builtin_offsetof(TypeInfo, align), "align offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, typeArgsNum) == __builtin_offsetof(TypeInfo, typeArgsNum),
            "typeArgsNum offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, validInheritNum) == __builtin_offsetof(TypeInfo, validInheritNum),
            "validInheritNum offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, fieldOffsets) == __builtin_offsetof(TypeInfo, fieldOffsets),
            "fieldOffsets offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, finalizerMethod) == __builtin_offsetof(TypeInfo, finalizerMethod),
            "finalizerMethod offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, typeArgs) == __builtin_offsetof(TypeInfo, typeArgs),
            "typeArgs offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, fields) == __builtin_offsetof(TypeInfo, fields), "fields offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, superTypeInfo) == __builtin_offsetof(TypeInfo, superTypeInfo),
            "superTypeInfo offset mismatch");
        static_assert(
            __builtin_offsetof(DYN_TypeInfo, vExtensionDataStart) == __builtin_offsetof(TypeInfo, vExtensionDataStart),
            "vExtensionDataStart offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, mTableDesc) == __builtin_offsetof(TypeInfo, mTableDesc),
            "mTableDesc offset mismatch");
        static_assert(__builtin_offsetof(DYN_TypeInfo, reflectOrDebugInfo) == __builtin_offsetof(TypeInfo, reflectInfo),
            "reflectInfo offset mismatch");
    }
};
#endif

} // namespace MapleRuntime
