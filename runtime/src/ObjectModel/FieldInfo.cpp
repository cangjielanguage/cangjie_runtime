// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "FieldInfo.h"
#include "Base/Log.h"
#include "Base/Globals.h"
#include "Loader/ILoader.h"
#include "Heap/Heap.h"
#include "ExceptionManager.inline.h"
#include "ObjectModel/MObject.inline.h"
#include "ObjectManager.inline.h"
namespace MapleRuntime {

U32 InstanceFieldInfo::GetModifier() const { return modifier; }

const char* InstanceFieldInfo::GetName(TypeInfo* declaringTypeInfo) const
{
    ReflectInfo* reflectInfo = declaringTypeInfo->GetReflectInfo();
    CHECK(reflectInfo != nullptr);
    U32 idx = fieldIdx;
    TypeInfo* superTi = declaringTypeInfo->GetSuperTypeInfo();
    if (superTi != nullptr) {
        idx = fieldIdx - superTi->GetFieldNum();
    }
    return reflectInfo->GetFieldName(idx);
}

inline U32 InstanceFieldInfo::GetOffset(TypeInfo* declaringTypeInfo) const
{
    CHECK(!(fieldIdx > declaringTypeInfo->GetFieldNum()));
    return declaringTypeInfo->GetFieldOffset(fieldIdx);
}

TypeInfo* InstanceFieldInfo::GetFieldType(TypeInfo* declaringTypeInfo)
{
    CHECK(!(fieldIdx > declaringTypeInfo->GetFieldNum()));
    return declaringTypeInfo->GetFieldType(fieldIdx);
}

void* InstanceFieldInfo::GetValue(TypeInfo* declaringTi, ObjRef instanceObj)
{
    CHECK(!(fieldIdx > declaringTi->GetFieldNum()));
    Uptr fieldAddr = reinterpret_cast<Uptr>(instanceObj) + TYPEINFO_PTR_SIZE + GetOffset(declaringTi);
    TypeInfo* fieldTi = GetFieldType(declaringTi);
    if (fieldTi->IsRef()) {
        return Heap::GetBarrier().ReadReference(instanceObj,
            instanceObj->GetRefField(GetOffset(declaringTi) + TYPEINFO_PTR_SIZE));
    } else if (fieldTi->IsStruct() || fieldTi->IsTuple() || fieldTi->IsEnum()) {
        MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
        MSize fieldSize = fieldTi->GetInstanceSize();
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (fieldSize == 0) {
            return obj;
        }
        void* tmp = malloc(fieldSize);
        Heap::GetBarrier().ReadStruct(reinterpret_cast<MAddress>(tmp), instanceObj, fieldAddr, fieldSize);
        Heap::GetBarrier().WriteStruct(obj, reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE, fieldSize,
            reinterpret_cast<MAddress>(tmp), fieldSize);
        free(tmp);
        return obj;
    } else if (fieldTi->IsPrimitiveType()) {
        MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE),
                     fieldTi->GetInstanceSize(),
                     reinterpret_cast<void*>(fieldAddr),
                     fieldTi->GetInstanceSize()) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
        return obj;
    } else if (fieldTi->IsVArray()) {
        // VArray is only used to store value types,
        // so we can copy the memory directly
        MSize vArraySize = fieldTi->GetFieldNum() * fieldTi->GetComponentTypeInfo()->GetInstanceSize();
        MSize size = MRT_ALIGN(vArraySize + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE), vArraySize,
                     reinterpret_cast<void*>(fieldAddr), vArraySize) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
        return obj;
    } else {
        LOG(RTLOG_FATAL, "%s not to supported", fieldTi->GetName());
    }
    return nullptr;
}

void InstanceFieldInfo::SetValue(TypeInfo* declaringTypeInfo, ObjRef instanceObj, ObjRef newValue)
{
    TypeInfo* fieldTi = GetFieldType(declaringTypeInfo);
    Uptr fieldAddr = reinterpret_cast<Uptr>(instanceObj) + TYPEINFO_PTR_SIZE + GetOffset(declaringTypeInfo);
    if (fieldTi->IsRef()) {
        Heap::GetBarrier().WriteReference(instanceObj,
            instanceObj->GetRefField(TYPEINFO_PTR_SIZE + GetOffset(declaringTypeInfo)), newValue);
    } else if (fieldTi->IsStruct() || fieldTi->IsTuple() || fieldTi->IsEnum()) {
        MSize fieldSize = fieldTi->GetInstanceSize();
        if (fieldSize == 0) {
            return;
        }
        void* tmp = malloc(fieldSize);
        Heap::GetBarrier().ReadStruct(reinterpret_cast<MAddress>(tmp), instanceObj,
            reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE, fieldSize);
        Heap::GetBarrier().WriteStruct(instanceObj, fieldAddr, fieldSize,
            reinterpret_cast<MAddress>(tmp), fieldSize);
        free(tmp);
    } else if (fieldTi->IsPrimitiveType()) {
        MSize size = fieldTi->GetInstanceSize();
        if (memcpy_s(reinterpret_cast<void*>(fieldAddr), size,
                     reinterpret_cast<void*>(reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE), size) != EOK) {
            LOG(RTLOG_ERROR, "SetValue memcpy_s fail");
        }
    } else if (fieldTi->IsVArray()) {
        // VArray is only used to store value types,
        // so we can copy the memory directly
        MSize vArraySize = fieldTi->GetFieldNum() * fieldTi->GetComponentTypeInfo()->GetInstanceSize();
        if (memcpy_s(reinterpret_cast<void*>(fieldAddr), vArraySize,
                     reinterpret_cast<void*>(reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE),
                     vArraySize) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
    } else {
        LOG(RTLOG_FATAL, "%s not to supported", fieldTi->GetName());
    }
}

void* InstanceFieldInfo::GetAnnotations(TypeInfo* arrayTi)
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

void* StaticFieldInfo::GetValue()
{
    TypeInfo* fieldTi = GetFieldType();
    if (fieldTi->IsRef()) {
        RefField<false>* refField = reinterpret_cast<RefField<false>*>(addr);
        return Heap::GetBarrier().ReadStaticRef(*refField);
    } else if (fieldTi->IsStruct() || fieldTi->IsTuple() || fieldTi->IsEnum()) {
        MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
        MSize fieldSize = fieldTi->GetInstanceSize();
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (fieldSize == 0) {
            return obj;
        }
        Heap::GetBarrier().WriteStruct(obj, reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE,
            fieldSize, addr, fieldSize);
        return obj;
    } else if (fieldTi->IsPrimitiveType()) {
        MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE),
                     fieldTi->GetInstanceSize(),
                     reinterpret_cast<void*>(addr),
                     fieldTi->GetInstanceSize()) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
        return obj;
    } else if (fieldTi->IsVArray()) {
        // VArray is only used to store value types,
        // so we can copy the memory directly
        MSize vArraySize = fieldTi->GetFieldNum() * fieldTi->GetComponentTypeInfo()->GetInstanceSize();
        MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + vArraySize, TYPEINFO_PTR_SIZE);
        MObject* obj = ObjectManager::NewObject(fieldTi, size);
        if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE), vArraySize,
                     reinterpret_cast<void*>(addr), vArraySize) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
        return obj;
    } else {
        LOG(RTLOG_FATAL, "%s not to supported", fieldTi->GetName());
    }
    return nullptr;
}

void StaticFieldInfo::SetValue(ObjRef newValue)
{
    TypeInfo* fieldTi = GetFieldType();
    if (fieldTi->IsRef()) {
        RefField<>* rootField = reinterpret_cast<RefField<>*>(addr);
        Heap::GetBarrier().WriteStaticRef(*rootField, newValue);
    } else if (fieldTi->IsStruct() || fieldTi->IsTuple() || fieldTi->IsEnum()) {
        MSize fieldSize = fieldTi->GetInstanceSize();
        if (fieldSize == 0) {
            return;
        }
        Heap::GetBarrier().WriteStaticStruct(addr, fieldSize,
            reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE, fieldSize, fieldTypeInfo->GetGCTib());
    } else if (fieldTi->IsPrimitiveType()) {
        MSize size = fieldTi->GetInstanceSize();
        if (memcpy_s(reinterpret_cast<void*>(addr), size,
                     reinterpret_cast<void*>(reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE), size) != EOK) {
            LOG(RTLOG_ERROR, "SetValue memcpy_s fail");
        }
    } else if (fieldTi->IsVArray()) {
        // VArray is only used to store value types,
        // so we can copy the memory directly
        MSize vArraySize = fieldTi->GetFieldNum() * fieldTi->GetComponentTypeInfo()->GetInstanceSize();
        if (memcpy_s(reinterpret_cast<void*>(addr), vArraySize,
                     reinterpret_cast<void*>(reinterpret_cast<Uptr>(newValue) + TYPEINFO_PTR_SIZE),
                     vArraySize) != EOK) {
            LOG(RTLOG_ERROR, "GetValue memcpy_s fail");
        }
    } else {
        LOG(RTLOG_FATAL, "%s not to supported", fieldTi->GetName());
    }
}

void* StaticFieldInfo::GetAnnotations(TypeInfo* arrayTi)
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

// FieldInitializer namespace implementation
namespace FieldInitializer {
// Forward declarations for helper functions
BaseObject* FieldToAny(ObjRef obj, TypeInfo* fieldTi, U32 offset);
BaseObject* StructLikeToAny(ObjRef obj, TypeInfo* fieldTi, Uptr fieldAddr);
BaseObject* PrimitiveToAny(TypeInfo* fieldTi, Uptr fieldAddr);
BaseObject* VArrayToAny(TypeInfo* fieldTi, Uptr fieldAddr);

bool SetPrimitiveField(ObjRef obj, Uptr argAddr, TypeInfo* argType, ObjRef argObj)
{
    MSize fieldSize = argType->GetInstanceSize();
    if (fieldSize == 0) {
        return true;
    }
    if (memcpy_s(reinterpret_cast<void*>(argAddr), fieldSize,
                 reinterpret_cast<void*>(reinterpret_cast<Uptr>(argObj) + TYPEINFO_PTR_SIZE),
                 fieldSize) != EOK) {
        LOG(RTLOG_ERROR, "FieldInitializer: memcpy_s failed for primitive field");
        return false;
    }
    return true;
}

bool SetStructField(ObjRef obj, Uptr argAddr, TypeInfo* argType, ObjRef argObj)
{
    MSize fieldSize = argType->GetInstanceSize();
    if (fieldSize == 0) {
        return true;
    }

    void* tmp = malloc(fieldSize);
    if (tmp == nullptr) {
        LOG(RTLOG_ERROR, "FieldInitializer: malloc failed for struct field");
        return false;
    }

    Heap::GetBarrier().ReadStruct(reinterpret_cast<MAddress>(tmp), argObj,
        reinterpret_cast<Uptr>(argObj) + TYPEINFO_PTR_SIZE, fieldSize);
    Heap::GetBarrier().WriteStruct(obj, argAddr, fieldSize, reinterpret_cast<MAddress>(tmp), fieldSize);

    free(tmp);
    return true;
}

bool SetVArrayField(ObjRef obj, Uptr argAddr, TypeInfo* argType, ObjRef argObj)
{
    MSize vArraySize = argType->GetFieldNum() * argType->GetComponentTypeInfo()->GetInstanceSize();
    if (vArraySize == 0) {
        return true;
    }
    if (memcpy_s(reinterpret_cast<void*>(argAddr), vArraySize,
                 reinterpret_cast<void*>(reinterpret_cast<Uptr>(argObj) + TYPEINFO_PTR_SIZE),
                 vArraySize) != EOK) {
        LOG(RTLOG_ERROR, "FieldInitializer: memcpy_s failed for VArray field");
        return false;
    }
    return true;
}

void SetFieldFromArgs(ObjRef obj, TypeInfo* ti, void* args)
{
    CJRawArray* cjRawArray = nullptr;
    if (!Heap::IsHeapAddress(args)) {
        cjRawArray = static_cast<CJArray*>(args)->rawPtr;
    } else {
        RefField<false> oldField(reinterpret_cast<MAddress>(args));
        cjRawArray = reinterpret_cast<CJRawArray*>(Heap::GetBarrier().ReadReference(nullptr, oldField));
    }
    U64 argCnt = cjRawArray->len;
    ObjRef rawArray = reinterpret_cast<ObjRef>(cjRawArray);
    RefField<false>* refField = reinterpret_cast<RefField<false>*>(&(cjRawArray->data));

    for (U64 idx = 0; idx < argCnt; ++idx) {
        ObjRef argObj = static_cast<ObjRef>(Heap::GetBarrier().ReadReference(rawArray, *refField));
        TypeInfo* argType = ti->GetFieldType(idx);
        U32 offset = ti->GetFieldOffset(idx);

        // For enum and temp enum, skip the first element (the tag).
        // For option-like-ref enum, the first element in the fields is a placeholder, so need skip too.
        if ((ti->IsEnum() || ti->IsTempEnum()) && !ti->IsZeroSizedEnum()) {
            argType = ti->GetFieldType(idx + 1);
            offset = ti->GetFieldOffset(idx + 1);
        }

        Uptr argAddr = reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE + offset;

        bool success = true;
        if (argType->IsRef()) {
            obj->StoreRef(offset + TYPEINFO_PTR_SIZE, argObj);
        } else if (argType->IsStruct() || argType->IsTuple() || argType->IsEnum()) {
            success = SetStructField(obj, argAddr, argType, argObj);
        } else if (argType->IsPrimitiveType()) {
            success = SetPrimitiveField(obj, argAddr, argType, argObj);
        } else if (argType->IsVArray()) {
            // VArray is only used to store value types,
            // so we can copy the memory directly
            success = SetVArrayField(obj, argAddr, argType, argObj);
        } else {
            LOG(RTLOG_FATAL, "FieldInitializer: %s type not supported", argType->GetName());
        }

        if (!success) {
            LOG(RTLOG_ERROR, "FieldInitializer: failed to set field at index %zu", idx);
        }

        refField++;
    }
}

ObjRef CreateEnumObject(TypeInfo* ti, MSize size)
{
    TypeInfo* enumTi = ti->GetSuperTypeInfo();
    EnumInfo* enumInfo = enumTi->GetEnumInfo();
    CHECK_DETAIL(enumInfo != nullptr, "FieldInitializer: enumInfo is nullptr");

    // For EnumKind1, the object's TypeInfo should be the constructor's TypeInfo of the enum.
    // For other enum kind, the object's TypeInfo should be the enum's TypeInfo.
    ObjRef obj = nullptr;
    if (enumInfo->IsEnumKind1()) {
        obj = ObjectManager::NewObject(ti, size, AllocType::RAW_POINTER_OBJECT);
    } else {
        obj = ObjectManager::NewObject(enumTi, size, AllocType::RAW_POINTER_OBJECT);
    }
    if (obj == nullptr) {
        VLOG(REPORT, "FieldInitializer: new enum object failed and throw OutOfMemoryError");
        ExceptionManager::CheckAndThrowPendingException("ObjectManager::NewObject return nullptr");
    }

    // For zero-sized enum and option-like-ref enum, the object has no tag.
    if (obj != nullptr && !ti->IsZeroSizedEnum() && !ti->IsOptionLikeRefEnum()) {
        SetEnumTag(obj, ti);
    }

    return obj;
}

void SetElementFromObject(ArrayRef array, ObjRef obj, TypeInfo* ti, U16 fieldNum)
{
    for (int idx = 0; idx < fieldNum; idx++) {
        TypeInfo* fieldTi = ti->GetFieldType(idx);
        U32 offset = ti->GetFieldOffset(idx);

        // For enum and temp enum, skip the first element (the tag).
        // For option-like-ref enum, the first element in the fields is a placeholder, so need skip too.
        if ((ti->IsEnum() || ti->IsTempEnum()) && !ti->IsZeroSizedEnum()) {
            fieldTi = ti->GetFieldType(idx + 1);
            offset = ti->GetFieldOffset(idx + 1);
        }

        BaseObject* fieldObj = FieldToAny(obj, fieldTi, offset);

        if (fieldObj != nullptr) {
            array->SetRefElement(idx, fieldObj);
        } else {
            LOG(RTLOG_ERROR, "FieldInitializer: Failed to create field object at index %d", idx);
        }
    }
}

BaseObject* FieldToAny(ObjRef obj, TypeInfo* fieldTi, U32 offset)
{
    Uptr fieldAddr = reinterpret_cast<Uptr>(obj) + TYPEINFO_PTR_SIZE + offset;
    if (fieldTi->IsRef()) {
        return Heap::GetBarrier().ReadReference(obj, obj->GetRefField(offset + TYPEINFO_PTR_SIZE));
    } else if (fieldTi->IsStruct() || fieldTi->IsTuple() || fieldTi->IsEnum()) {
        return StructLikeToAny(obj, fieldTi, fieldAddr);
    } else if (fieldTi->IsPrimitiveType()) {
        return PrimitiveToAny(fieldTi, fieldAddr);
    } else if (fieldTi->IsVArray()) {
        return VArrayToAny(fieldTi, fieldAddr);
    } else {
        LOG(RTLOG_FATAL, "FieldInitializer: %s type not supported", fieldTi->GetName());
        return nullptr;
    }
}

BaseObject* StructLikeToAny(ObjRef obj, TypeInfo* fieldTi, Uptr fieldAddr)
{
    MSize fieldSize = fieldTi->GetInstanceSize();
    MSize size = MRT_ALIGN(fieldSize + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    BaseObject* fieldObj = ObjectManager::NewObject(fieldTi, size, AllocType::RAW_POINTER_OBJECT);

    if (fieldSize == 0) {
        return fieldObj;
    }

    void* tmp = malloc(fieldSize);
    if (tmp == nullptr) {
        LOG(RTLOG_ERROR, "FieldInitializer: malloc failed for struct field");
        return nullptr;
    }

    Heap::GetBarrier().ReadStruct(reinterpret_cast<MAddress>(tmp), obj, fieldAddr, fieldSize);
    Heap::GetBarrier().WriteStruct(fieldObj, reinterpret_cast<Uptr>(fieldObj) + TYPEINFO_PTR_SIZE, fieldSize,
        reinterpret_cast<MAddress>(tmp), fieldSize);

    free(tmp);
    return fieldObj;
}

BaseObject* PrimitiveToAny(TypeInfo* fieldTi, Uptr fieldAddr)
{
    MSize size = MRT_ALIGN(fieldTi->GetInstanceSize() + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    BaseObject* fieldObj = ObjectManager::NewObject(fieldTi, size, AllocType::RAW_POINTER_OBJECT);
    if (fieldTi->GetInstanceSize() == 0) {
        return fieldObj;
    }
    if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(fieldObj) + TYPEINFO_PTR_SIZE),
                 fieldTi->GetInstanceSize(),
                 reinterpret_cast<void*>(fieldAddr),
                 fieldTi->GetInstanceSize()) != EOK) {
        LOG(RTLOG_ERROR, "FieldInitializer: memcpy_s failed for primitive field");
    }

    return fieldObj;
}

BaseObject* VArrayToAny(TypeInfo* fieldTi, Uptr fieldAddr)
{
    // VArray is only used to store value types, so we can copy the memory directly
    MSize vArraySize = fieldTi->GetFieldNum() * fieldTi->GetComponentTypeInfo()->GetInstanceSize();
    MSize size = MRT_ALIGN(vArraySize + TYPEINFO_PTR_SIZE, TYPEINFO_PTR_SIZE);
    BaseObject* fieldObj = ObjectManager::NewObject(fieldTi, size, AllocType::RAW_POINTER_OBJECT);
    if (vArraySize == 0) {
        return fieldObj;
    }
    if (memcpy_s(reinterpret_cast<void*>(reinterpret_cast<Uptr>(fieldObj) + TYPEINFO_PTR_SIZE), vArraySize,
                 reinterpret_cast<void*>(fieldAddr), vArraySize) != EOK) {
        LOG(RTLOG_ERROR, "FieldInitializer: memcpy_s failed for VArray field");
    }

    return fieldObj;
}

I32 GetEnumTag(ObjRef obj, TypeInfo* ti)
{
    EnumInfo* enumInfo = ti->GetEnumInfo();
    if (ti->IsEnumCtor()) {
        enumInfo = ti->GetSuperTypeInfo()->GetEnumInfo();
    }

    I32 tag = 0;
    if (ti->IsZeroSizedEnum()) {
        tag = 0;
    } else if (ti->IsOptionLikeRefEnum()) {
        U32 ctorNum = enumInfo->GetNumOfEnumCtor();
        auto field = obj->LoadRef(TYPEINFO_PTR_SIZE);
        for (U32 idx = 0; idx < ctorNum; idx++) {
            TypeInfo* ctorTi = enumInfo->GetCtorTypeInfo(idx);
            if ((ctorTi->IsOptionLikeUnassociatedCtor() && field == nullptr) ||
                (!ctorTi->IsOptionLikeUnassociatedCtor() && field != nullptr)) {
                tag = static_cast<I32>(idx);
                break;
            }
        }
    } else if (enumInfo->IsEnumKind2()) {
        // EnumKind2's tag type is bool.
        tag = obj->Load<I8>(TYPEINFO_PTR_SIZE);
    } else {
        tag = obj->Load<I32>(TYPEINFO_PTR_SIZE);
    }
    return tag;
}

void SetEnumTag(ObjRef obj, TypeInfo* typeInfo)
{
    TypeInfo* enumTi = typeInfo->GetSuperTypeInfo();
    EnumInfo* enumInfo = enumTi->GetEnumInfo();
    CHECK_DETAIL(enumInfo != nullptr, "FieldInitializer: enumInfo is nullptr");
    U32 num = enumInfo->GetNumOfEnumCtor();
    for (U32 idx = 0; idx < num; idx++) {
        TypeInfo* ctorTypeInfo = enumInfo->GetCtorTypeInfo(idx);
        if (typeInfo->GetUUID() == ctorTypeInfo->GetUUID()) {
            obj->Store(TYPEINFO_PTR_SIZE, static_cast<I32>(idx));
            break;
        }
    }
}
} // namespace FieldInitializer
} // namespace MapleRuntime
