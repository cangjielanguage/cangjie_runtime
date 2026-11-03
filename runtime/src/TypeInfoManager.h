// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_TYPE_INFO_MANAGER_H
#define MRT_TYPE_INFO_MANAGER_H

#include <unordered_map>

#include "ObjectModel/MClass.h"
#include "Base/SysCall.h"
#include "Base/RwLock.h"
#if defined(__linux__) || defined(hongmeng) || defined(__APPLE__)
#include <sys/mman.h>
#endif
#include "Base/HashUtils.h"
#include "Base/ImmortalWrapper.h"

namespace MapleRuntime {
class TypeGCInfo {
public:
    CString GetGCTibStr(TypeInfo* ti);
private:
    void FillTypeGCInfo(TypeInfo* ti, CString &gcTibStr, U32 &curSize);
    void FillArrayTypeGCInfo(TypeInfo* ti, CString &gcTibStr, U32 &curSize);
};
class TypeInfoManager {
    friend class TypeInfo;
public:
    // 1024: number of buckets for the hash map.
    explicit TypeInfoManager() : genericTypeInfoDescMap(1024) {}
    ~TypeInfoManager() = default;

    void Init();
    void Fini();
    void NewMMap(size_t size);
    void FreeMMap(uintptr_t address, size_t size);
    static TypeInfoManager& GetTypeInfoManager();

    TypeInfo* GetOrCreateTypeInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[]);
    void AddTypeInfo(TypeInfo* ti);
    static U32 GetTypeSize(TypeInfo* ti);
    void ParseEnumInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[], TypeInfo* ti);
    void RecordMTableDesc(MTableDesc* mTableDesc) { mTableList.push_back(mTableDesc); }
    U16 GetTypeTemplateUUID(TypeTemplate* tt);
    void FillReflectInfo(TypeTemplate* tt, TypeInfo* ti);
    void InitAnyAndObjectType();
    TypeInfo* GetAnyTypeInfo() { return anyTi; }
    TypeInfo* GetObjectTypeInfo() { return objectTi; }
private:
    // Bump allocator over the mmap'd arena: never freed before Fini(), no alignment done
    // (callers round the returned address up themselves).
    uintptr_t Allocate(size_t size);
    // Allocate and construct an MTableDesc in the same arena (see the definition) so that a real
    // MTableDesc* never carries a HWASan/TBI top-byte tag, which would look like the compiler's
    // inline bitmap marker kept in TypeInfo::mTableDesc.
    MTableDesc* AllocateMTableDesc(BIT_TYPE bitmap);
    void CalculateGCTib(TypeInfo* typeInfo);
    CString GetGCTibStr(TypeInfo* typeInfo);
    void FillOffsets(TypeInfo* newTypeInfo, TypeTemplate* tt, U32 argSize, TypeInfo* args[]);
    void AddMTable(TypeTemplate* tt, TypeInfo* newTypeInfo, U32 argSize, TypeInfo* args[]);

    enum TypeInfoStatus : uint8_t {
        TYPEINFO_NOT_CREATED = 0,
        TYPEINFO_INITING,
        TYPEINFO_INITED,
    };
    class GenericTiDesc {
    public:
        GenericTiDesc(TypeTemplate* pTypeTemplate, U32 pArgSize, TypeInfo* pArgs[])
            : tt(pTypeTemplate), argSize(pArgSize), args(pArgs), hash(computeHash()) {
        }

        GenericTiDesc(GenericTiDesc &desc)
        {
            tt = desc.tt;
            argSize = desc.argSize;
            hash = desc.hash;
            for (U32 i = 0; i < argSize; i++) {
                argsVector.push_back(desc.args[i]);
            }
            tid.store(GetTid());
        }

        GenericTiDesc& operator=(const GenericTiDesc& other) = delete;
        bool operator==(const GenericTiDesc &other) const;

        U32 GetHash() const { return hash; }

        TypeInfo* typeInfo { nullptr };
        bool IsNotCreated() { return typeInfo == nullptr; }
        bool IsIniting() { return status.load(std::memory_order_acquire) == TypeInfoStatus::TYPEINFO_INITING; }
        bool IsInited() { return status.load(std::memory_order_acquire) == TypeInfoStatus::TYPEINFO_INITED; }
        void SetTypeInfoStatus(TypeInfoStatus tiStatus) { status.store(tiStatus, std::memory_order_release); }
        TypeInfoStatus GetTypeInfoStatus() { return status.load(std::memory_order_acquire); }
        std::atomic<U32> tid = { 0 };
        U32 computeHash();
        TypeTemplate* tt;
        U32 argSize;
        TypeInfo** args;
        U32 hash;
    private:
        std::vector<TypeInfo*> argsVector = { };
        std::atomic<TypeInfoStatus> status { TypeInfoStatus::TYPEINFO_NOT_CREATED };
    };
    class GenericTiDescHashMap {
    public:
        explicit GenericTiDescHashMap(size_t numBuckets)
            : buckets(numBuckets) {}
        ~GenericTiDescHashMap()
        {
            for (auto &bucket : buckets) {
                for (auto &vec : bucket.maps) {
                    for (auto desc : vec.second) {
                        delete desc;
                        desc = nullptr;
                    }
                }
            }
            buckets.clear();
        }
        GenericTiDesc* InsertGenericTiDesc(GenericTiDesc& desc);
        GenericTiDesc* GetGenericTiDesc(GenericTiDesc& desc);
    private:
        struct Bucket {
            std::unordered_map<U32, std::vector<GenericTiDesc*>> maps;
            RwLock rwLock;
        };

        std::vector<Bucket> buckets;
    };
    GenericTiDesc* InsertGenericTiDesc(GenericTiDesc& desc);
    GenericTiDesc* GetGenericTiDesc(GenericTiDesc& desc);
    GenericTiDesc* GetTypeInfo(TypeTemplate* tt, U32 argSize, TypeInfo* args[]);
    void CreatedTypeInfo(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[]);
    void CreatedTypeInfoImpl(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[]);
    void FillRemainingField(GenericTiDesc* &tiDesc, TypeTemplate* tt, U32 argSize, TypeInfo* args[]);

    size_t mapMemory = 1 * MB; // dynamic scaling, 1mb each time.
    std::atomic<uintptr_t> position;
    std::mutex ttMutex; //  guaranteed typeTemplates insert and find atomic
    std::recursive_mutex tiMutex; //  guaranteed nonGenericTypeInfo insert and find atomic
    std::unordered_map<const char*, TypeInfo*, HashString, EqualString> nonGenericTypeInfos;
    std::unordered_map<const char*, TypeInfo*, HashString, EqualString> genericTypeInfos;
    std::unordered_map<const char*, TypeTemplate*, HashString, EqualString> typeTemplates;
    GenericTiDescHashMap genericTypeInfoDescMap;
    uintptr_t startAddress;
    uintptr_t endAddress;
    std::atomic<U32> tiUUID { 1 };
    std::atomic<U16> ttUUID { 1 };
    TypeGCInfo typeGCInfo;
    std::vector<std::pair<uintptr_t, size_t>> mmapList;
    std::vector<MTableDesc*> mTableList;
    // Record two special TypeInfo, Any is the subclass of all types,
    // and Object is the superclass of all classes.
    // Because these two classes have no special tags,
    // record these two classes during initialization.
    TypeInfo* anyTi = nullptr;
    TypeInfo* objectTi = nullptr;
};
} // namespace MapleRuntime
#endif // MRT_TYPE_INFO_MANAGER_H
