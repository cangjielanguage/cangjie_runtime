// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_CJ_HEAP_DATA_IDE_H
#define MRT_CJ_HEAP_DATA_IDE_H
#include <fstream>
#include <climits>
#include <sstream>
#include <unordered_map>
#include "FileStream.h"
#include "Base/CString.h"
#include "Inspector/CjHeapData.h"
#include "securec.h"

namespace MapleRuntime {
class CjHeapDataForIDE : public CjHeapData {
public:
    using CjHeapDataIDForIDE = u4;
    bool Serialize();
    void SerializeFixedHeader();
    void SerializeString();
    void SerializeRecordHeader(const u1 tag, const u4 time);
    void SerializeAllClassLoad();
    void SerializeAllStructClassLoad();
    void SerializeAllClass();
    void SerializeAllStructClass();
    void SerializeStackTrace();
    void SerializeStartThread();
    void SerializeHeapDump();
    void SerializeStackFrame(FrameInfo& frame, uint32_t frameIdx);
    void SerializeClassLoad(TypeInfo* klass, CjHeapDataStringId klassId, const u1 tag);
    void SerializeAllObjects();
    void SerializeGlobalRoot(BaseObject*& obj, const u1 tag);
    void SerializeUnknownRoot(BaseObject*& obj, const u1 tag);
    void SerializeLocalRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth);
    void SerializeLocalObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth);
    void SerializeLocalFinalizer(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth, const u1 state);
    void SerializeThreadObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 stackTraceIdx);
    void SerializeObjectArray(BaseObject*& obj, const u1 tag);
    void SerializeStructArray(BaseObject*& obj, const u1 tag);
    void SerializePrimitiveArray(BaseObject*& obj, const u1 tag);
    void SerializeInstance(BaseObject*& obj, const u1 tag);
    void SerializeClass(TypeInfo* klass, CjHeapDataStringId klassId, const u1 tag);
    void SerializeStructClass(TypeInfo* klass, CjHeapDataStringId klassId, const u1 tag);
    u4 GetId(CjHeapDataStringId klassId);
    u4 GetObjectId(BaseObject* obj);
    I8 GetObjType(BaseObject* obj);
private:
    StreamWriter* writer = nullptr;
    std::unordered_map<CjHeapDataStringId, u4> stringIdxMap;
    u4 stringIdx = 0;
    std::unordered_map<BaseObject*, u4> objectIdxMap;
    u4 objectIdx = 0;
};
}
#endif
