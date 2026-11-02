// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <iostream>
#include <unistd.h>
#include <cstring>
#include <sstream>
#include <pthread.h>
#include "Mutator/MutatorManager.h"
#include "UnwindStack/StackMetadataHelper.h"
#include "ObjectModel/MArray.inline.h"
#include "FileStream.h"
#include "CjHeapData.h"
#include "HeapSnapshotJsonSerializer.h"

namespace MapleRuntime {

bool CjHeapDataForIDE::Serialize()
{
    ScopedStopTheWorld scopedStopTheWorld("serialize heap data");
    ProcessHeap();
    HeapProfilerStream* stream = &MapleRuntime::HeapProfilerStream::GetInstance();
    stream->SetContext(DUMPHEAPSNAPSHOT);
    writer = new StreamWriter(stream);
    writer->WriteChar('{');
    SerializeFixedHeader();
    SerializeString();
    SerializeAllClassLoad();
    SerializeAllStructClassLoad();
    SerializeStackTrace();
    SerializeStartThread();
    SerializeHeapDump();
    writer->WriteChar('}');
    writer->End();
    stream->SetContext(END);
    writer->WriteString("{\"id\":");
    writer->WriteString(stream->GetMessageID());
    writer->WriteString(",\"result\":{}");
    writer->End();
    delete writer;
    writer = nullptr;
    return true;
}

void CjHeapDataForIDE::SerializeFixedHeader()
{
    const u4 idSize = sizeof(u4);
    struct timeval timeNow {};
    gettimeofday(&timeNow, nullptr);
    const uint64_t msecsTime = (timeNow.tv_sec * 1000) + (timeNow.tv_usec / 1000);
    const uint32_t timeHigh = static_cast<uint32_t>(msecsTime >> 32);
    const uint32_t timeLow = static_cast<uint32_t>(msecsTime & 0xFFFFFFFF);
    writer->WriteString("\\\"HEADER\\\":[");
    writer->WriteNumber(idSize);
    writer->WriteChar(',');
    writer->WriteNumber(timeHigh);
    writer->WriteChar(',');
    writer->WriteNumber(timeLow);
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeString()
{
    writer->WriteString("\\\"STRING\\\":[");
    bool isFirstElement = true;
    for (const auto& string : strings) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        writer->WriteChar('[');
        CjHeapDataStringId id = string.second;
        writer->WriteNumber(GetId(id));
        writer->WriteChar(',');
        CString str = string.first;
        str.ReplaceAll("/", "\\");
        writer->WriteContinueString("\\\"");
        writer->WriteString(str);
        writer->WriteContinueString("\\\"");
        writer->WriteChar(']');
    }
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeAllClassLoad()
{
    writer->WriteContinueString("\\\"CLASSLOAD\\\":[");
    bool isFirstElement = true;
    for (const auto& klassInfo : dumpClassMap) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        SerializeClassLoad(klassInfo.first, klassInfo.second, TAG_CLASS_LOAD);
    }
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeAllClass()
{
    writer->WriteContinueString("\\\"CLASS\\\":[");
    bool isFirstElement = true;
    for (const auto& klassInfo : dumpClassMap) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        SerializeClass(klassInfo.first, klassInfo.second, TAG_CLASS_DUMP);
    }
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeAllStructClass()
{
    writer->WriteContinueString("\\\"STRUCTCLASS\\\":[");
    bool isFirstElement = true;
    for (const auto& klassInfo : dumpStructClassMap) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        SerializeStructClass(klassInfo.first, klassInfo.second, TAG_CLASS_DUMP);
    }
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeClassLoad(TypeInfo* ti, CjHeapDataStringId klassId, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataStringId>(ti)));
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataStringId>(klassId)));
    writer->WriteChar(']');
}

void CjHeapDataForIDE::SerializeAllStructClassLoad()
{
    writer->WriteContinueString("\\\"STRUCTCLASSLOAD\\\":[");
    bool isFirstElement = true;
    for (const auto& klassInfo : dumpStructClassMap) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        SerializeClassLoad(klassInfo.first, klassInfo.second, TAG_CLASS_LOAD);
    }
    writer->WriteChar(']');
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeStackFrame(FrameInfo& frame, uint32_t frameIdx)
{
    writer->WriteChar('[');
    if (frameIdx > 0 && frame.GetFrameType() == FrameType::NATIVE) {
        return;
    }
    if (frame.GetFrameType() == FrameType::MANAGED) {
        StackMetadataHelper stackMetadataHelper(frame);
        methodName = frame.GetFuncName();
        fileName = frame.GetFileName();
        lineNumber = stackMetadataHelper.GetLineNumber();
    } else {
        Os::Loader::BinaryInfo binInfo;
        (void)Os::Loader::GetBinaryInfoFromAddress(frame.mFrame.GetIP(), &binInfo);
        fileName = CString(binInfo.filePathName);
        methodName = CString(binInfo.symbolName);
    }
    writer->WriteNumber(frames[&frame]);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(LookupStringId(methodName.Str())));
    writer->WriteChar(',');
    writer->WriteNumber(GetId(LookupStringId(fileName.Str())));
    writer->WriteChar(',');
    writer->WriteNumber(reinterpret_cast<u4>(lineNumber));
    writer->WriteChar(']');
}


void CjHeapDataForIDE::SerializeStackTrace()
{
    bool isFirstElement = true;
    for (auto trace = stacktraces.begin(); trace != stacktraces.end(); trace++) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        // 10: Default Limit Max Dump Depth as 10 frames
        size_t size = 10;
        size_t depth = trace->first->stacks.size() > size ? size : trace->first->stacks.size();
        std::vector<FrameInfo*> stack = trace->first->stacks;
        writer->WriteContinueString("\\\"STACKFRAME\\\":[");
        for (size_t i = 0; i < depth; ++i) {
            if (i != 0) {
                writer->WriteChar(',');
            }
            SerializeStackFrame(*stack[i], i);
        }
        writer->WriteChar(']');
        writer->WriteChar(',');
        writer->WriteContinueString("\\\"STACKTRACE\\\":[");
        writer->WriteNumber(trace->second);
        writer->WriteChar(',');
        writer->WriteNumber(trace->first->GetStackTid());
        writer->WriteChar(',');
        writer->WriteNumber(depth);
        writer->WriteChar(',');
        writer->WriteChar('[');
        for (size_t i = 0; i < depth; ++i) {
            if (i != 0) {
                writer->WriteChar(',');
            }
            writer->WriteNumber(frames[stack[i]]);
        }
        writer->WriteChar(']');
        writer->WriteChar(']');
    }
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeStartThread()
{
    bool isFirstElement = true;
    for (auto trace = stacktraces.begin(); trace != stacktraces.end(); trace++) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        writer->WriteContinueString("\\\"STARTTHREAD\\\":[");
        writer->WriteNumber(trace->first->GetStackTid());
        writer->WriteChar(',');
        writer->WriteNumber(GetId(threadObjectId++));
        writer->WriteChar(',');
        writer->WriteNumber(trace->second);
        writer->WriteChar(',');
        CString threadNameAll = trace->first->GetThreadName();
        writer->WriteNumber(GetId(LookupStringId(threadNameAll)));
        writer->WriteChar(']');
    }
    writer->WriteChar(',');
}

void CjHeapDataForIDE::SerializeHeapDump()
{
    SerializeAllClass();
    SerializeAllStructClass();
    SerializeAllObjects();
}

void CjHeapDataForIDE::SerializeAllObjects()
{
    writer->WriteContinueString("\\\"OBJECTS\\\":[");
    bool isFirstElement = true;
    for (auto& objectInfo : dumpObjects) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        switch (objectInfo.tag) {
            case TAG_ROOT_THREAD_OBJECT:
                SerializeThreadObjectRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, 0);
                break;
            case TAG_ROOT_LOCAL:
                SerializeLocalRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum);
                break;
            case TAG_ROOT_LOCAL_OBJECT:
                SerializeLocalObjectRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum);
                break;
            case TAG_LOCAL_FINALIZER:
                SerializeLocalFinalizer(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum,
                                        objectInfo.finalizerState);
                break;
            case TAG_ROOT_GLOBAL:
                SerializeGlobalRoot(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_ROOT_UNKNOWN:
                SerializeUnknownRoot(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_OBJECT_ARRAY_DUMP:
            case TAG_LARGE_OBJECT_ARRAY_DUMP:
            case TAG_UNMOVABLE_OBJECT_ARRAY_DUMP:
                SerializeObjectArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_STRUCT_ARRAY_DUMP:
            case TAG_LARGE_STRUCT_ARRAY_DUMP:
            case TAG_UNMOVABLE_STRUCT_ARRAY_DUMP:
                SerializeStructArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_PRIMITIVE_ARRAY_DUMP:
            case TAG_LARGE_PRIMITIVE_ARRAY_DUMP:
            case TAG_UNMOVABLE_PRIMITIVE_ARRAY_DUMP:
                SerializePrimitiveArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_INSTANCE_DUMP:
            case TAG_PINNED_INSTANCE_DUMP:
            case TAG_LARGE_INSTANCE_DUMP:
            case TAG_UNMOVABLE_INSTANCE_DUMP:
                SerializeInstance(objectInfo.obj, objectInfo.tag);
                break;
            default:
                break;
        }
    }
    writer->WriteChar(']');
}

/*
 * Record Global Root Info:
 *     u1 tag;     //denoting the type of this sub-record
 *     ID objId;   // object ID
 */
void CjHeapDataForIDE::SerializeGlobalRoot(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    CjHeapDataID objAddr = (reinterpret_cast<CjHeapDataID>(obj));
    u4 id = GetObjectId(obj);
    CString name = obj->GetTypeInfo()->GetName();
    writer->WriteNumber(id);
    writer->WriteChar(']');
}

/*
 * Record Unknown Root Info:
 *     u1 tag;     // denoting the type of this sub-record
 *     ID objId;   // object ID
 */
void CjHeapDataForIDE::SerializeUnknownRoot(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    CjHeapDataID objAddr = (reinterpret_cast<CjHeapDataID>(obj));
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(']');
}

/*
 * Record Local Root Info:
 *     u1 tag;         // denoting the type of this sub-record
 *     ID objId;       // object ID
 *     u4 threadIdx;   // thread serial number
 *     u4 frame;       // frame number in stack trace (-1 for empty)
 */
void CjHeapDataForIDE::SerializeLocalRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    CjHeapDataID objAddr = (reinterpret_cast<CjHeapDataID>(obj));
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    writer->WriteNumber(tid);
    writer->WriteChar(',');
    writer->WriteNumber(depth);
    writer->WriteChar(']');
}

void CjHeapDataForIDE::SerializeLocalObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth)
{
    SerializeLocalRoot(obj, tag, tid, depth);
}

void CjHeapDataForIDE::SerializeLocalFinalizer(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth,
                                               const u1 state)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    writer->WriteNumber(GetObjectId(obj));
    writer->WriteChar(',');
    writer->WriteNumber(tid);
    writer->WriteChar(',');
    writer->WriteNumber(depth);
    writer->WriteChar(',');
    writer->WriteNumber(state);
    writer->WriteChar(']');
}

/*
 * Record Thread Object Root Info:
 *     u1 tag;             // denoting the type of this sub-record
 *     ID threadObjId;     // thread object ID
 *     u4 threadIdx;       // thread serial number
 *     u4 stackTraceIdx;   // stack trace serial number
 *
 */
void CjHeapDataForIDE::SerializeThreadObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 stackTraceIdx)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    CjHeapDataID objAddr = (reinterpret_cast<CjHeapDataID>(obj));
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    writer->WriteNumber(tid);
    writer->WriteChar(',');
    writer->WriteNumber(stackTraceIdx);
    writer->WriteChar(']');
}

/*
 * Record Class Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID classObjId;   // class object ID
 *     u4 size;         // instance size (in bytes)
 */
void CjHeapDataForIDE::SerializeClass(TypeInfo* ti, CjHeapDataStringId klassId, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataStringId>(ti)));
    writer->WriteChar(',');
    // 8-byte alignment
    if (!ti->IsObjectType()) {
        writer->WriteNumber(0);
        writer->WriteChar(']');
        return;
    }
    u4 size = AlignUp<u4>((ti->GetInstanceSize() + TYPEINFO_PTR_SIZE), alignment);
    // 8 bytes for each field
    writer->WriteNumber(size);
    writer->WriteChar(']');
}

/*
 * Record Object Array Info:
 *     u1 tag;             // denoting the type of this sub-record
 *     ID arrObjId;        // array object ID
 *     u4 num;             // number of elements
 *     ID arrClassObjId;   // array class object ID
 *     ID elements[num];   // elements
 *
 */
void CjHeapDataForIDE::SerializeObjectArray(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    CjHeapDataID objAddr = (reinterpret_cast<CjHeapDataID>(obj));
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    u4 num = 0;
    std::stack<u4> VAL;
    RefFieldVisitor visitor = [&VAL, &num, this](RefField<>& arrayContent) {
        VAL.push(GetObjectId(arrayContent.GetTargetObject()));
        num++;
    };
    // take array length and content.
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    MIndex arrayLengthVal = mArray->GetLength();
    RefField<>* arrayContent = reinterpret_cast<RefField<>*>(mArray->ConvertToCArray());
    // for each object in array.
    for (MIndex i = 0; i < arrayLengthVal; ++i) {
        visitor(arrayContent[i]);
    }
    writer->WriteNumber(num);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataID>(obj->GetTypeInfo())));
    writer->WriteChar(',');
    writer->WriteChar('[');
    bool isFirstElement = true;
    while (!VAL.empty()) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        u4 val = VAL.top();
        VAL.pop();
        writer->WriteNumber(val);
    }
    writer->WriteChar(']');
    writer->WriteChar(']');
}

/*
 * Record struct Array Info:
 *     u1 tag;             // denoting the type of this sub-record
 *     ID arrObjId;        // array object ID
 *     u4 componentNum;        // component Num
 *     u4 num;             // number of ref fields
 *     ID arrClassObjId;   // array class object ID
 *     ID elements[num];   // elements
 *
 */

void CjHeapDataForIDE::SerializeStructArray(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    u4 num = 0;
    std::stack<u4> VAL;
    RefFieldVisitor visitor = [&VAL, &num, this](RefField<>& arrayContent) {
        VAL.push(GetObjectId(arrayContent.GetTargetObject()));
        num++;
    };
    // take array length and content.
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    MIndex arrayLengthVal = mArray->GetLength();
    TypeInfo* componentTypeInfo = mArray->GetComponentTypeInfo();
    GCTib gcTib = componentTypeInfo->GetGCTib();
    MAddress contentAddr = reinterpret_cast<Uptr>(mArray) + MArray::GetContentOffset();
    if (componentTypeInfo->HasRefField()) {
        for (MIndex i = 0; i < arrayLengthVal; ++i) {
            gcTib.ForEachBitmapWord(contentAddr, visitor);
            contentAddr += mArray->GetElementSize();
        }
    }

    writer->WriteNumber(arrayLengthVal);
    writer->WriteChar(',');
    writer->WriteNumber(num);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataID>(obj->GetTypeInfo())));
    writer->WriteChar(',');
    writer->WriteChar('[');
    bool isFirstElement = true;
    while (!VAL.empty()) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        u4 val = VAL.top();
        VAL.pop();
        writer->WriteNumber(val);
    }
    writer->WriteChar(']');
    writer->WriteChar(']');
}

/*
 * Record Primitive Array Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID arrObjId;     // array object
 *     u4 num;          // number of elements
 *     u1 type;         // element type
 */

void CjHeapDataForIDE::SerializePrimitiveArray(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    writer->WriteNumber(mArray->GetLength());
    writer->WriteChar(',');
    MSize componentSize = obj->GetTypeInfo()->GetComponentSize();
    switch (componentSize) {
        // bool:1 bytes
        case 1:
            writer->WriteNumber(BOOLEAN);
            break;
        // short:2 bytes
        case 2:
            writer->WriteNumber(SHORT);
            break;
        // int:4 bytes
        case 4:
            writer->WriteNumber(INT);
            break;
        // long:8 bytes
        case 8:
            writer->WriteNumber(LONG);
            break;
        default:
            break;
    }
    writer->WriteChar(']');
}

/*
 * Record Struct Class Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID classObjId;   // class object ID
 *     u4 size;         // instance size (in bytes)
 */
void CjHeapDataForIDE::SerializeStructClass(TypeInfo* ti, CjHeapDataStringId klassId, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataStringId>(ti)));
    TypeInfo* componentKlass = ti->GetComponentTypeInfo();
    // No alignment required
    u4 size = componentKlass->GetInstanceSize();
    writer->WriteChar(',');
    writer->WriteNumber(size);
    writer->WriteChar(']');
}

/*
 * Record Instance Info:
 *     u1 tag;           // denoting the type of this sub-record
 *     ID objId;         // object ID
 *     ID classObjId;    // class object ID
 *     u4 num;           // number of ref fields
 *     VAL entry[];      // ref contents in instance field values (this class, followed by super class, etc)
 */
void CjHeapDataForIDE::SerializeInstance(BaseObject*& obj, const u1 tag)
{
    writer->WriteChar('[');
    writer->WriteNumber(tag);
    writer->WriteChar(',');
    writer->WriteNumber(GetObjType(obj));
    writer->WriteChar(',');
    u4 id = GetObjectId(obj);
    writer->WriteNumber(id);
    writer->WriteChar(',');
    writer->WriteNumber(GetId(reinterpret_cast<CjHeapDataID>(obj->GetTypeInfo())));
    writer->WriteChar(',');
    u4 num = 0;
    std::stack<u4> VAL;
    RefFieldVisitor visitor = [&VAL, &num, this](RefField<>& fieldAddr) {
        VAL.push(GetObjectId(fieldAddr.GetTargetObject()));
        num++;
    };
    TypeInfo* currentClass = obj->GetTypeInfo();
    if (obj->HasRefField()) {
        GCTib gcTib = currentClass->GetGCTib();
        MAddress objAddr = reinterpret_cast<MAddress>(obj) + TYPEINFO_PTR_SIZE;
        gcTib.ForEachBitmapWord(objAddr, visitor);
    }
    writer->WriteNumber(num);
    writer->WriteChar(',');
    writer->WriteChar('[');
    bool isFirstElement = true;
    while (!VAL.empty()) {
        if (!isFirstElement) {
            writer->WriteChar(',');
        } else {
            isFirstElement = false;
        }
        u4 val = VAL.top();
        VAL.pop();
        writer->WriteNumber(val);
    }
    writer->WriteChar(']');
    writer->WriteChar(']');
}

CjHeapData::u4 CjHeapDataForIDE::GetId(CjHeapDataStringId klassId)
{
    if (stringIdxMap.find(klassId) == stringIdxMap.end()) {
        stringIdxMap[klassId] = ++stringIdx;
    }
    return stringIdxMap[klassId];
}

CjHeapData::u4 CjHeapDataForIDE::GetObjectId(BaseObject* obj)
{
    if (!enableLocalObjectDump) {
        return GetId(reinterpret_cast<CjHeapDataID>(obj));
    }
    if (obj == nullptr) {
        return static_cast<u4>(CjHeapData::NULL_OBJECT_ID);
    }
    auto it = objectIdxMap.find(obj);
    if (it != objectIdxMap.end()) {
        return it->second;
    }
    // Keep object IDs separate from string IDs and reserve zero for null.
    u4 id = ++objectIdx;
    if (id == 0 || id == static_cast<u4>(CjHeapData::NULL_OBJECT_ID)) {
        id = ++objectIdx;
    }
    objectIdxMap.emplace(obj, id);
    return id;
}

I8 CjHeapDataForIDE::GetObjType(BaseObject* obj)
{
    I8 objType = TypeKind::TYPE_KIND_NOTHING;
    if (obj != nullptr) {
        TypeInfo* typeInfo = obj->GetTypeInfo();
        if (typeInfo != nullptr) {
            objType = typeInfo->GetType();
        }
    }
    return objType;
}
}
