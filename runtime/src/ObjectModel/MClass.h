// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_MCLASS_H
#define MRT_MCLASS_H

#include <functional>
#include <mutex>
#include <unordered_map>

#include "Base/AtomicSpinLock.h"
#include "Common/TypeDef.h"
#include "Interpreter/Options.h"
#include "MethodInfo.h"
#include "FieldInfo.h"
#include "Flags.h"
#include "PackageInfo.h"

namespace MapleRuntime {
class ExtensionData;
class BaseFile;
constexpr U8 BITS_FOR_REF = 1;
constexpr U8 REF_BIT_MASK = 1;
// for arm32: 1 << 31. for aarch64 or x86_64: 1 << 63.
constexpr ArchUInt SIGN_BIT =  (ArchUInt)1 << (sizeof(void*) * 8 - 1);
constexpr U16 INVALID_INHERIT_NUM = (1 << 15) - 1;

extern const size_t TYPEINFO_PTR_SIZE;

union MTableBitmap {
    using LargeBitmap = std::pair<U32, U8[]>;
    ArchUInt shortBitmap;
    LargeBitmap* largeBitmap;
    ArchUInt tag;

    void ForEachBit(const std::function<void(ExtensionData*)>& visitor, ExtensionData** vExtensionPtr)
    {
        bool isSmallBitmap = tag & SIGN_BIT;
        if (isSmallBitmap) {
            ArchUInt bitInfo = shortBitmap & (~SIGN_BIT);
            while (LIKELY(bitInfo != 0)) {
                if (bitInfo & 0x1) {
                    visitor(*vExtensionPtr);
                }
                bitInfo >>= 1;
                ++vExtensionPtr;
            }
        } else {
            U8* bitmaps = largeBitmap->second;
            for (U32 i = 0; i < largeBitmap->first; ++i) {
                U8 bitInfo = bitmaps[i];
                while (LIKELY(bitInfo != 0)) {
                    if (bitInfo & 0x1) {
                        visitor(*vExtensionPtr);
                    }
                    bitInfo >>= 1;
                    ++vExtensionPtr;
                }
            }
        }
    }
};

class InheritFuncTable {
public:
    InheritFuncTable() = delete;
    InheritFuncTable(const InheritFuncTable& other)
        : superExtensionData(other.superExtensionData),
          superTypeInfo(other.superTypeInfo),
          cachedTypeInfos(other.cachedTypeInfos)
    {}
    InheritFuncTable& operator=(const InheritFuncTable& other)
    {
        if (this == &other) {
            return *this;
        }
        superExtensionData = other.superExtensionData;
        superTypeInfo = other.superTypeInfo;
        cachedTypeInfos = other.cachedTypeInfos;
        return *this;
    }

    InheritFuncTable(InheritFuncTable&& other)
    {
        superExtensionData = other.superExtensionData;
        superTypeInfo = other.superTypeInfo;
        cachedTypeInfos = std::move(other.cachedTypeInfos);
        other.superExtensionData = nullptr;
        other.superTypeInfo = nullptr;
    }
    InheritFuncTable& operator=(InheritFuncTable&& other)
    {
        if (this == &other) {
            return *this;
        }
        superExtensionData = other.superExtensionData;
        superTypeInfo = other.superTypeInfo;
        cachedTypeInfos = std::move(other.cachedTypeInfos);
        other.superExtensionData = nullptr;
        other.superTypeInfo = nullptr;
        return *this;
    }
    InheritFuncTable(ExtensionData* ed, TypeInfo* super, size_t sz)
        : superExtensionData(ed), superTypeInfo(super), cachedTypeInfos(sz) {}
    ExtensionData* GetExtensionData() const { return superExtensionData; }
    TypeInfo* GetSuperTi() const { return superTypeInfo; }
    void ResetAtomicInfoArray(size_t size) { cachedTypeInfos = AtomicTypeInfoArray(size); }
    TypeInfo* GetCachedTypeInfo(size_t index) const { return cachedTypeInfos.Get(index); }
    void SetCachedTypeInfo(size_t index, TypeInfo* ti) { cachedTypeInfos.Set(index, ti); }
private:
    class AtomicTypeInfoArray {
    public:
        AtomicTypeInfoArray() = default;
        AtomicTypeInfoArray(const AtomicTypeInfoArray& other) : cacheSize(other.cacheSize)
        {
            if (cacheSize == 0) {
                typeInfos = nullptr;
                return;
            }
            typeInfos = new (std::nothrow) std::atomic<TypeInfo*>[cacheSize];
            if (UNLIKELY(typeInfos == nullptr)) {
                LOG(RTLOG_FATAL, "copy construct func table memory failed, size %zu", cacheSize);
            }
            for (size_t i = 0; i < cacheSize; ++i) {
                TypeInfo* ti = other.typeInfos[i].load(std::memory_order_relaxed);
                typeInfos[i].store(ti, std::memory_order_relaxed);
            }
        }

        AtomicTypeInfoArray& operator=(const AtomicTypeInfoArray& other)
        {
            if (this == &other) {
                return *this;
            }
            cacheSize = other.cacheSize;
            if (cacheSize == 0) {
                typeInfos = nullptr;
                return *this;
            }
            typeInfos = new (std::nothrow) std::atomic<TypeInfo*>[cacheSize];
            if (UNLIKELY(typeInfos == nullptr)) {
                LOG(RTLOG_FATAL, "copy assign func table memory failed, size %zu", cacheSize);
            }
            for (size_t i = 0; i < cacheSize; ++i) {
                TypeInfo* ti = other.typeInfos[i].load(std::memory_order_relaxed);
                typeInfos[i].store(ti, std::memory_order_relaxed);
            }
            return *this;
        }

        AtomicTypeInfoArray(AtomicTypeInfoArray&& other)
        {
            cacheSize = other.cacheSize;
            typeInfos = other.typeInfos;
            other.cacheSize = 0;
            other.typeInfos = nullptr;
        }

        AtomicTypeInfoArray& operator=(AtomicTypeInfoArray&& other)
        {
            if (this == &other) {
                return *this;
            }
            cacheSize = other.cacheSize;
            typeInfos = other.typeInfos;
            other.cacheSize = 0;
            other.typeInfos = nullptr;
            return *this;
        }

        explicit AtomicTypeInfoArray(size_t size) : cacheSize(size)
        {
            if (size == 0) {
                typeInfos = nullptr;
                return;
            }
            typeInfos = new (std::nothrow) std::atomic<TypeInfo*>[size];
            if (UNLIKELY(typeInfos == nullptr)) {
                LOG(RTLOG_FATAL, "allocation func table memory failed, cache size %zu", size);
            }
            for (size_t i = 0; i < size; ++i) {
                typeInfos[i].store(nullptr, std::memory_order_relaxed);
            }
        }

        ~AtomicTypeInfoArray()
        {
            if (typeInfos != nullptr) {
                delete[] typeInfos;
            }
        }
        TypeInfo* Get(size_t index) const
        {
            return typeInfos[index].load(std::memory_order_acquire);
        }
        void Set(size_t index, TypeInfo* ti)
        {
            typeInfos[index].store(ti, std::memory_order_release);
        }
    private:
        size_t cacheSize{ 0 };
        std::atomic<TypeInfo*>* typeInfos{ nullptr };
    };

    ExtensionData* superExtensionData { nullptr };
    TypeInfo* superTypeInfo { nullptr };
    // The size of this array is the same as the virtual function count in this extension data.
    AtomicTypeInfoArray cachedTypeInfos;
};
struct MTableDesc {
    std::unordered_map<U32, InheritFuncTable> mTable;
    MTableBitmap mTableBitmap;
    std::recursive_mutex mTableMutex;
    bool pending = false;
    bool needsResolveInner = true;
    bool needsResolveOuter = true;
    explicit MTableDesc(ArchUInt bitmap_);
    MTableDesc() = delete;
    bool IsFullyHandled() const { return !NeedResolveInner() && !NeedResolveOuter(); };
    inline bool NeedResolveInner() const { return needsResolveInner; }
    inline bool NeedResolveOuter() const { return needsResolveOuter; }
};

typedef TypeInfo* (*GenericFunc)(TypeInfo**);
struct ShortGCTib {
    ArchUInt bitmap; // lower 63 bits are valid, each bit indicates 8-byte width, 1:ref, 0:no-ref

    void ForEachBitmapWord(MAddress fieldAddr, const RefFieldVisitor& visitor) const
    {
        ArchUInt gcInfo = bitmap & (~SIGN_BIT);
        while (LIKELY(gcInfo != 0)) {
            if (gcInfo & REF_BIT_MASK) {
                visitor(*reinterpret_cast<RefField<>*>(fieldAddr));
            }
            gcInfo >>= BITS_FOR_REF;
            fieldAddr += sizeof(RefField<>);
        }
    }
    void ForEachBitmapWordInRange(MAddress baseAddr, const RefFieldVisitor& visitor, MAddress rangeStart,
                                  MAddress rangeEnd) const
    {
        ArchUInt gcInfo = bitmap & (~SIGN_BIT);
        U32 startPos = (rangeStart - baseAddr) / sizeof(RefField<>);
        gcInfo >>= startPos;

        MAddress fieldAddr = rangeStart;
        while (LIKELY(gcInfo != 0)) {
            if (fieldAddr >= rangeEnd) {
                return;
            }
            if (gcInfo & REF_BIT_MASK) {
                visitor(*reinterpret_cast<RefField<>*>(fieldAddr));
            }
            gcInfo >>= BITS_FOR_REF;
            fieldAddr += sizeof(RefField<>);
        }
    }
};

struct StdGCTib {
    static constexpr U32 BITS_PER_BYTE = 8;
    static constexpr U32 REFS_PER_BIT_WORD = ((sizeof(U8) * BITS_PER_BYTE) / BITS_FOR_REF);
    // Number of bitmap words.
    U32 nBitmapWords;

    // An array of bitmap words. Length is `nBitmapWords`.
    U8 bitmapWords[];

    void VisitRefField(U8& bitmapWord, MAddress& fieldAddr, const RefFieldVisitor& visitor) const
    {
        U8 wordBits = bitmapWord & REF_BIT_MASK;
        if (wordBits != 0) {
            visitor(*reinterpret_cast<RefField<>*>(fieldAddr));
        }
        // go next ref word.
        bitmapWord >>= BITS_FOR_REF;
        fieldAddr += sizeof(RefField<>);
    }
    void VisitAllField(U8 &bitmapWord, MAddress &fieldAddr, const RefFieldVisitor &visitor) const
    {
        visitor(*reinterpret_cast<RefField<> *>(fieldAddr));

        // go next ref word.
        bitmapWord >>= BITS_FOR_REF;
        fieldAddr += sizeof(RefField<>);
    }
    void ForEachBitmapWord(MAddress contentAddr, const RefFieldVisitor& visitor) const
    {
        const U8* bitmaps = bitmapWords;

        // start address of fields.
        MAddress baseAddr = contentAddr;
        // for each bitmap word.
        for (U32 i = 0; i < nBitmapWords; ++i) {
            U8 bitmapWord = bitmaps[i];
            MAddress fieldAddr = baseAddr;

            // for each bit in bitmap.
            while (LIKELY(bitmapWord != 0)) {
                VisitRefField(bitmapWord, fieldAddr, visitor);
            }
            // go next bitmap word.
            baseAddr += (sizeof(RefField<>) * REFS_PER_BIT_WORD);
        }
    }
    void ForEachBitmapWordInRange(MAddress contentAddr, const RefFieldVisitor& visitor, MAddress rangeStart,
                                  MAddress rangeEnd) const
    {
        const U8* bitmaps = bitmapWords;
        size_t mapWordSize = (sizeof(RefField<>) * REFS_PER_BIT_WORD);
        U32 startIndex = (rangeStart - contentAddr) / mapWordSize;
        // start address of fields.
        MAddress baseAddr = startIndex * mapWordSize + contentAddr;
        // for each bitmap word.
        for (U32 i = startIndex; i < nBitmapWords; ++i) {
            U8 bitmapWord = bitmaps[i];
            MAddress fieldAddr = baseAddr;
            // Make sure each fieldAddr visited is no less then rangeStart addr
            if (i == startIndex && bitmapWord != 0) {
                bitmapWord >>= ((rangeStart - baseAddr) / sizeof(RefField<>));
                fieldAddr = rangeStart;
            }
            // for each bit in bitmap.
            while (LIKELY(bitmapWord != 0)) {
                if (fieldAddr >= rangeEnd) {
                    return;
                }
                VisitRefField(bitmapWord, fieldAddr, visitor);
            }

            // go next bitmap word.
            baseAddr += (sizeof(RefField<>) * REFS_PER_BIT_WORD);
        }
    }
};

union GCTib {
    ArchUInt tag;           // 1: bitmap, 0: gctib
    ShortGCTib bitmap; // each bit indicates 8-byte width, 1:ref, 0:no-ref
    StdGCTib* gctib;   // valid only when highest bit is 0.

    bool IsGCTibWord() const
    {
#ifdef __arm__
        // arm32 only use gctib pointer.
        return false;
#else
        return static_cast<bool>(tag & SIGN_BIT); // 63: Use 64-bit sign bit as flag.
#endif
    }

    void ForEachBitmapWord(MAddress contentAddr, const RefFieldVisitor& visitor) const
    {
        if (IsGCTibWord()) {
            bitmap.ForEachBitmapWord(contentAddr, visitor);
        } else {
            gctib->ForEachBitmapWord(contentAddr, visitor);
        }
    }

    void ForEachBitmapWordInRange(MAddress contentAddr, const RefFieldVisitor& visitor, MAddress rangeStart,
                                  MAddress rangeEnd) const
    {
#ifdef __arm__
        rangeStart = ((rangeStart + 3) & (~3)); // 3: upper aligned to 4
#else
        rangeStart = ((rangeStart + 7) & (~7)); // 7: upper aligned to 8
#endif
        if (rangeStart >= rangeEnd) {
            return;
        }
        if (IsGCTibWord()) {
            bitmap.ForEachBitmapWordInRange(contentAddr, visitor, rangeStart, rangeEnd);
        } else {
            gctib->ForEachBitmapWordInRange(contentAddr, visitor, rangeStart, rangeEnd);
        }
    }
};

struct FieldNames {
    I64 fieldNameOffset[0];
};

class ReflectInfo {
public:
    inline U32 GetModifier() const { return modifier; }
    char* GetFieldName(U32 idx) const;
    FieldNames* GetFieldNames() { return fieldNamesOffset.GetDataRef(); }
    void SetFieldNames(FieldNames* fieldNames);
    void SetInstanceMethodInfo(U32 idx, MethodInfo* methodInfo);
    void SetStaticMethodInfo(U32 idx, MethodInfo* methodInfo);

    inline U32 GetNumOfInstanceFieldInfos() const { return instanceFieldInfoCnt; }
    inline U32 GetNumOfStaticFieldInfos() const { return staticFieldInfoCnt; }
    inline U32 GetNumOfInstanceMethodInfos() const { return instanceMethodCnt; }
    inline U32 GetNumOfStaticMethodInfos() const { return staticMethodCnt; }

    InstanceFieldInfo* GetInstanceFieldInfo(U32 index);
    StaticFieldInfo* GetStaticFieldInfo(U32 index);
    MethodInfo* GetInstanceMethodInfo(U32 index) const;
    MethodInfo* GetStaticMethodInfo(U32 index);
    void* GetDeclaringGenericTypeInfo() { return genericTypeInfo; }

    void SetDeclaringGenericTypeInfo(GenericTypeInfo* ti) { genericTypeInfo = ti; }

    void* GetAnnotations(TypeInfo* arrayTi);
    U8 GetReflectVersion() const;
private:
    Uptr GetBaseAddr() const { return reinterpret_cast<Uptr>(base); }
    DataRefOffset64<FieldNames> fieldNamesOffset;
    U32 modifier;
    U16 instanceFieldInfoCnt;
    U16 staticFieldInfoCnt;
    U32 instanceMethodCnt;
    U32 staticMethodCnt;
    Uptr annotationMethod;
    void* genericTypeInfo;
    Uptr base[0];
};

class EnumCtorInfo {
public:
    const char* GetName() { return name.GetDataRef(); }
    FuncPtr* GetCtorFn() const { return enumCtorFn; }
    TypeInfo* GetTypeInfo() const { return typeInfo; }

    void SetName(const char* pName);
    void SetTypeInfo(TypeInfo* ti) { typeInfo = ti; }
private:
    DataRefOffset64<char> name;
    union {
        FuncPtr* enumCtorFn;
        TypeInfo* typeInfo;
    };
};

struct EnumDebugInfo {
    DataRefOffset64<EnumCtorInfo> enumCtorInfos;
    U32 modifier;
    U32 enumCtorInfoCnt;

    EnumCtorInfo* GetEnumCtor(U32 idx) const;
    void SetEnumCtors(void* ctors);
};

class EnumInfo {
public:
    inline U32 GetModifier() const { return enumDebugInfo.modifier; }
    inline U32 GetNumOfEnumCtor() const { return enumDebugInfo.enumCtorInfoCnt; }
    inline U32 GetNumOfInstanceMethodInfos() const { return instanceMethodCnt; }
    inline U32 GetNumOfStaticMethodInfos() const { return staticMethodCnt; }
    EnumCtorInfo* GetEnumCtor(U32 idx) const;
    TypeInfo* GetCtorTypeInfo(U32 idx) const;
    void* GetAnnotations(TypeInfo* arrayTi);
    void* GetCtorAnnotations(U32 idx, TypeInfo* arrayTi);
    MethodInfo* GetInstanceMethodInfo(U32 index) const;
    MethodInfo* GetStaticMethodInfo(U32 index);
    Uptr GetCtorAnnotationMethod(U32 index) const;
    void SetInstanceMethodInfo(U32 idx, MethodInfo* methodInfo);
    void SetStaticMethodInfo(U32 idx, MethodInfo* methodInfo);

    void SetCtorInfoNum(U32 num) { enumDebugInfo.enumCtorInfoCnt = num; }
    void SetParsed() { enumDebugInfo.modifier |= MODIFIER_ENUM_PARSED; }
    bool IsParsed() const { return (enumDebugInfo.modifier & MODIFIER_ENUM_PARSED) != 0; }
    bool IsEnumKind0() const { return (enumDebugInfo.modifier & MODIFIER_ENUM_KIND0) != 0; }
    bool IsEnumKind1() const { return (enumDebugInfo.modifier & MODIFIER_ENUM_KIND1) != 0; }
    bool IsEnumKind2() const { return (enumDebugInfo.modifier & MODIFIER_ENUM_KIND2) != 0; }
    bool IsEnumCtor() const { return (enumDebugInfo.modifier & MODIFIER_ENUM_CTOR) != 0; }
    EnumDebugInfo* GetEnumDebugInfo() { return &enumDebugInfo; }
    void* GetDeclaringGenericTypeInfo() { return genericTypeInfo; }
    void SetDeclaringGenericTypeInfo(GenericTypeInfo* ti) { genericTypeInfo = ti; }
    U8 GetReflectVersion() const;
private:
    Uptr GetBaseAddr() const { return reinterpret_cast<Uptr>(base); }
    EnumDebugInfo enumDebugInfo;
    U32 instanceMethodCnt;
    U32 staticMethodCnt;
    Uptr annotationMethod;
    void* genericTypeInfo;
    Uptr base[0];
};

class TypeTemplate {
public:
    inline bool IsRawArray() const;
    inline bool IsVArray() const;
    inline bool IsArrayType() const;
    inline bool IsWeakRefType() const;
    inline bool IsObjectType() const;
    inline bool IsPrimitiveType() const;
    inline bool IsInterface() const;
    inline bool IsClass() const;
    inline bool IsStruct() const;
    inline bool IsNothing() const;
    inline bool IsTuple() const;
    inline bool IsEnum() const;
    inline bool IsTempEnum() const;
    inline bool IsCString() const;
    inline bool IsCPointer() const;
    inline bool IsCFunc() const;
    inline bool IsFunc() const;
    inline bool IsRef() const;
    inline bool HasRefField() const;
    inline bool HasFinalizer() const;
    inline bool HasExtPart() const;
    inline const char* GetName() const;
    inline I8 GetType() const { return type; }
    inline I8 GetFlag() const { return flag; }
    inline U16 GetFieldNum() const { return fieldNum; }
    inline U16 GetTypeArgNum() const { return typeArgsNum; }
    inline U16 GetValidInheritNum() const { return validInheritNum; }
    inline ExtensionData** GetvExtensionDataStart() const { return vExtensionDataStart; }
    inline U16 GetUUID() const { return uuid.load(); }
    inline void SetUUID(U16 id);
    inline EnumInfo* GetEnumInfo();
    inline EnumDebugInfo* GetEnumDebugInfo();
    inline bool ReflectInfoIsNull() const;
    bool ReflectIsEnable() const;
    bool IsEnumCtor() const;

    CString GetTypeInfoName(U32 argSize, TypeInfo* args[]);
    ReflectInfo* GetReflectInfo() const { return reflectInfo; }
    TypeInfo* GetFieldType(U16 fieldIdx, U32 argSize, TypeInfo* args[]);
    TypeInfo* GetSuperTypeInfo(U32 argSize, TypeInfo* args[]);
    FuncRef GetFinalizeMethod() const { return finalizerMethod; }
    static void* ExecuteGenericFunc(void* genericFunc, U32 argSize, TypeInfo* args[]);
private:
    GenericFunc GetFieldGenericFunc(U16 idx) const { return fieldFns[idx]; }
    GenericFunc GetSuperGenericFunc() const { return superFn; }
    TypeTemplate() = delete;
    ~TypeTemplate() = delete;
    const char* name;
    I8 type;
    I8 flag; // hasRefField, hasFinalize, future, mutex, monitor, waitQueue, reflection, use 0-6 bit
    U16 fieldNum;
    U16 typeArgsNum;
    // The member does not exist in the IR, use the alignment bits to record the UUID in runtime.
    std::atomic<U16> uuid;
    const GenericFunc* fieldFns;
    const GenericFunc superFn;
    FuncRef finalizerMethod;
    // This union stores different type information based on the type:
    // - For non-enum types: uses reflectInfo
    // - For enum types with reflection enabled: uses enumInfo
    // - For enum types with reflection disabled: uses enumDebugInfo
    union {
        ReflectInfo* reflectInfo;
        EnumInfo* enumInfo;
        EnumDebugInfo* enumDebugInfo;
    };
    ExtensionData **vExtensionDataStart;
    U16 validInheritNum;
};

// Class is a generalization of type information
#ifdef __arm__
class TypeInfo {
#else
class ATTR_PACKED(4) TypeInfo {
#endif
    friend class TypeInfoManager;
#ifdef INTERPRETER_ENABLED
    friend struct TypeInfoLayoutCheck;
#endif
public:
    // property/field query
    inline GCTib GetGCTib() const;
    inline MSize GetInstanceSize() const;     // for instance class, in Bytes
    inline MSize GetComponentSize() const;    // for array class, in Bytes

    // Type category query
    inline bool IsObjectType() const;
    inline bool IsRawArray() const;
    inline bool IsVArray() const;
    inline bool IsWeakRefType() const;
    inline bool IsForeignType() const;
    inline bool IsExportedType() const;
    inline bool IsArrayType() const;
    inline bool IsStructType() const;
    inline bool IsPrimitiveType() const;
    inline bool IsVaildType() const;
    inline bool IsInterface() const;
    inline bool IsClass() const;
    inline bool IsSyncClass() const;
    inline bool IsStruct() const;
    inline bool IsNothing() const;
    inline bool IsUnit() const;
    inline bool IsBool() const;
    inline bool IsTuple() const;
    inline bool IsEnum() const;
    inline bool IsTempEnum() const;
    inline bool IsCString() const;
    inline bool IsCPointer() const;
    inline bool IsFunc() const;
    inline bool IsFloat16() const;
    inline bool IsFloat32() const;
    inline bool IsFloat64() const;
    inline bool IsCFunc() const;
    inline bool IsRef() const;
    inline bool IsUnknownSize() const; // mark structs with unknown compile-time size
    inline bool IsGenericTypeInfo() const; // mark generic instantiation TypeInfo
    inline bool IsGeneric() const; // mark a type of GenericTypeInfo, for reflect
    inline bool IsReflectUnsupportedType() const;
    inline bool HasRefField() const;
    inline bool HasFinalizer() const;
    inline bool IsInitialUUID() const;
    inline I8 GetFlags() const;
    inline I8 GetType() const;
    inline U16 GetAlign() const;
    inline U16 GetFieldNum() const;
    inline U32* GetFieldOffsets() const;
    inline U16 GetValidInheritNum() const;

    inline TypeInfo** GetFieldTypes() const { return fields; }
    inline TypeInfo* GetFieldType(U16 idx) const;
    inline TypeInfo* GetComponentTypeInfo() const;
    inline U16 GetTypeArgNum() const { return typeArgsNum; }
    inline U32 GetFieldOffset(U16 idx) const { return fieldOffsets[idx]; }
    inline TypeInfo** GetTypeArgs() const { return typeArgs; }
    inline TypeTemplate* GetSourceGeneric() const;
    inline ExtensionData** GetvExtensionDataStart() const;

    inline bool IsFutureClass() const;
    inline bool IsMonitorClass() const;
    inline bool IsMutexClass() const;
    inline bool IsWaitQueueClass() const;
    inline bool HasExtPart() const;
    inline bool IsBoxClass() const;
    U32 GetModifier() const;
    bool IsEnumCtor() const;
    bool IsOptionLikeRefEnum();
    bool IsZeroSizedEnum();
    bool IsOptionLikeUnassociatedCtor();
    bool IsEnumKind1();
    bool ReflectIsEnable() const;
    bool ReflectInfoIsNull() const;
    ReflectInfo* GetReflectInfo() const;
    U8 GetReflectionVersion() const;

    inline const char* GetName() const;
    FuncRef GetFinalizeMethod() const;

    // for reflection
    U32 GetNumOfInstanceMethodInfos();
    MethodInfo* GetInstanceMethodInfo(U32 index);

    U32 GetNumOfStaticMethodInfos();
    MethodInfo* GetStaticMethodInfo(U32 index);

    U32 GetNumOfInstanceFieldInfos();
    InstanceFieldInfo* GetInstanceFieldInfo(U32 index);

    U32 GetNumOfStaticFieldInfos();
    StaticFieldInfo* GetStaticFieldInfo(U32 index);

    U32 GetNumOfEnumCtor();
    EnumCtorInfo* GetEnumCtor(U32 idx);

    PackageInfo* GetPackageInfo();
    void* GetAnnotations(TypeInfo* arrayTi);
    inline EnumInfo* GetEnumInfo() const;
    // for generic
    void SetName(const char* name) { this->typeInfoName = name; }
    void SetType(I8 kindType) { this->type = kindType; }
    void SetFlag(I8 f) { this->flag = f; }
    void SetFieldNum(U16 num) { this->fieldNum = num; }
    void SetTypeArgNum(I8 num) { this->typeArgsNum = num; }
    void SetUUID(U32 id) { this->uuid = id; }
    void SetMTableDesc(MTableDesc* desc);
    void SetGenericArgs(TypeInfo** args) { this->typeArgs = args; }
    void SetFieldAddr(TypeInfo** types) { this->fields = types; }
    void SetFieldType(U16 idx, TypeInfo* fieldType) { this->fields[idx] = fieldType; }
    void SetSuperTypeInfo(TypeInfo* super) { this->superTypeInfo = super; }
    void SetOffsets(U32* offsets) { this->fieldOffsets = offsets; }
    void SetSourceGeneric(TypeTemplate* tt) { this->sourceGeneric = tt; }
    void SetAlign(U8 alignment) { this->align = alignment; }
    void SetInstanceSize(U32 size) { this->instanceSize = size; }
    void SetGCTib(GCTib gctib);
    void SetComponentTypeInfo(TypeInfo* ti) { this->componentTypeInfo = ti; }
    void SetValidInheritNum(U16 num) { this->validInheritNum = num | (1 << 15); }
    bool IsSubType(TypeInfo* superTypeInfo);
    void SetFlagHasRefField();
    void SetReflectInfo(ReflectInfo* info) { this->reflectInfo = info; }
    void SetvExtensionDataStart(ExtensionData **ptr) { this->vExtensionDataStart = ptr; }
    void SetEnumInfo(EnumInfo* ei) { this->enumInfo = ei; }
    void SetEnumDebugInfo(EnumDebugInfo* enumDebugInfo);
    MTableDesc* GetMTableDesc() const { return mTableDesc; }
    void AddMTable(TypeInfo* ti, ExtensionData* extensionData);
    FuncPtr* GetMTable(TypeInfo* itf);
    TypeInfo* GetMethodOuterTI(TypeInfo* itf, U64 index);
    U32 GetUUID();
    inline U32 GetClassSize() const;
    inline TypeInfo* GetSuperTypeInfo() const;                     // it can be null
    struct RAIISpinLock {
        RAIISpinLock(AtomicSpinLock& pLock) : lock(pLock) { lock.Lock(); }
        ~RAIISpinLock() { lock.Unlock(); }
        AtomicSpinLock& lock;
    };
    void TryInitMTable();
    void TryInitMTableNoLock();
    void GetInterfaces(std::vector<TypeInfo*> &itfs);
    bool NeedRefresh();
    void TryUpdateExtensionData(TypeInfo* itf, ExtensionData* extensionData);
private:
    TypeInfo() = delete;
    ~TypeInfo() = delete;

    void TraverseInnerExtensionDefs(const std::function<void(TypeInfo*)> getInterface = nullptr);
    void TraverseOuterExtensionDefs(const std::function<void(TypeInfo*)> getInterface = nullptr);
    // find ExtensionData of this TypeInfo and itf
    ExtensionData* FindExtensionData(TypeInfo* itf, bool searchRecursively = false);
    ExtensionData* FindExtensionDataRecursively(TypeInfo* itf);
    // 0: functable, 1: is_sub_type
    std::pair<FuncPtr*, bool> FindMTable(U32 itfUUID);

    inline bool IsMTableDescUnInitialized() {

        return (mTableDesc == nullptr) || (validInheritNum >> 15 == 1)
        // mtable bitmap optimization will be enabled for non-ARM architectures.
#ifndef __arm__
               || (reinterpret_cast<uintptr_t>(mTableDesc) >> 63 == 1)
#endif
            ;
    }
    // This function must be called before mTableDesc is overwritten.
    inline ArchUInt GetResolveBitmapFromMTableDesc()
    {
        return reinterpret_cast<uintptr_t>(mTableDesc);
    }

    const char* typeInfoName;
    I8 type;
    U8 flag; // hasRefField, hasFinalize, monitor, waitQueue, use 0-3 bit
    U16 fieldNum;
    union {
        MSize instanceSize;
        MSize componentSize;
    };
    GCTib gctib;
    U32 uuid;
    U8 align;
    I8 typeArgsNum;
    // During initialization, it indicates the number of valid classes in the virtual table. During running, it is
    // updated to calculate the start position of the interface extensiondef search.
    // INVALID_INHERIT_NUM: invalid value.
    U16 validInheritNum;
    U32* fieldOffsets;
    union {
        TypeTemplate* sourceGeneric;
        FuncRef finalizerMethod;
    };
    TypeInfo **typeArgs;
    TypeInfo **fields;
    union {
        TypeInfo* superTypeInfo;
        TypeInfo* componentTypeInfo;
    };
    ExtensionData **vExtensionDataStart;
    MTableDesc* mTableDesc;
    // This union stores different type information based on the type:
    // - For non-enum types: uses reflectInfo
    // - For enum types with reflection enabled: uses enumInfo
    // - For enum types with reflection disabled: uses enumDebugInfo
    union {
        ReflectInfo* reflectInfo;
        EnumInfo* enumInfo;
        EnumDebugInfo* enumDebugInfo;
    };
};

class GenericTypeInfo {
public:
    const char* GetName() const { return name; }
    inline const char* GetSourceGenericName();
    U8 GetGenericArgsNum() { return genericArgsNum; }
    U32 GetGenericConstraintNum() { return genericConstraintNum; }
    TypeInfo* GetGenericConstraint(U32 idx) { return genericConstraints[idx]; }
    void* GetGenericArg(U8 idx) { return genericArgs[idx]; }
    bool IsGenericCustom() { return type == TypeKind::TYPE_KIND_GENERIC_CUSTOM; }
    bool IsGeneric() { return type == TypeKind::TYPE_KIND_GENERIC_TI; }
    TypeTemplate* GetSourceGeneric() { return tt; }
private:
    const char* name;
    I8 type;
    U8 genericArgsNum;
    U16 __attribute__((unused)) slot;
    U32 genericConstraintNum;
    union {
        TypeInfo** genericArgs;
        TypeInfo** genericConstraints;
    };
    TypeTemplate* tt;
};
} // namespace MapleRuntime
#endif // MRT_MCLASS_H
