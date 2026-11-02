// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "CjHeapData.h"
#include <cerrno>
#include <cstdint>
#include <Common/BaseObject.h>
#include <Common/Runtime.h>
#include <Common/ScopedObjectAccess.h>
#include <Heap/Collector/TaskQueue.h>
#include <Heap/Collector/TracingCollector.h>
#include <sys/time.h>

#include "ObjectModel/MArray.inline.h"
#include "Common/BaseObject.h"
#include "Common/StackType.h"
#include "Concurrency/ConcurrencyModel.h"
#include "Heap/Heap.h"
#include "Heap/Allocator/RegionSpace.h"
#include "ObjectModel/RefField.h"
#include "Sync/Sync.h"
#include "UnwindStack/PrintStackInfo.h"
#include "UnwindStack/StackInfo.h"
#include "UnwindStack/StackMetadataHelper.h"
#include <Mutator/MutatorManager.h>
#include "Heap/Allocator/LocalObjectUtil.h"

namespace MapleRuntime {
static bool g_oomIsTrigged = false;
// Enable only after the heap-dump parser supports local-object records (1.0.3).
static bool g_enableLocalObjectDump = false;

void CjHeapData::SerializedIdWrapper::Init(size_t maxCapacity, MAddress startAddr, bool force4Byte)
{
#if SIZE_MAX <= UINT32_MAX
    (void)maxCapacity;
    (void)force4Byte;
    use4ByteId = true;
#else
    use4ByteId = force4Byte || (maxCapacity <= static_cast<size_t>(CjHeapData::HEAP_SIZE_THRESHOLD_4GB));
#endif
    heapStartAddr = (use4ByteId && !force4Byte) ? startAddr : 0;
}

void CjHeapData::SerializedIdWrapper::WriteId(CjHeapData& heapData, u8 value) const
{
    if (use4ByteId) {
        heapData.AddU4(static_cast<CjHeapData::u4>(value));
    } else {
        heapData.AddU8(value);
    }
}

bool CjHeapData::SerializedIdWrapper::Use4ByteId() const
{
    return use4ByteId;
}

MAddress CjHeapData::SerializedIdWrapper::GetHeapStartAddr() const
{
    return heapStartAddr;
}

void CjHeapData::WriteHeap()
{
    WriteFixedHeader();
    WriteString();
    WriteStackTrace();
    WriteStartThread();
    WriteHeapDump();
}

    void CjHeapData::ProcessHeap()
{
    enableLocalObjectDump = g_enableLocalObjectDump;
    ProcessRootGlobal();
    ProcessRootLocal();
    ProcessRootConcurrencyModel();
    ProcessRootFinalizer();
    (void)LookupStringId("reserved");
    (void)LookupStringId("RefFields");
    (void)LookupStringId("ValueField");
    //  dump object contents
    auto dumpVisitor = [this](BaseObject* obj) { ProcessHeapObject(obj); };
    bool ret = Heap::GetHeap().ForEachObj(dumpVisitor, false);
    CHECK_E(UNLIKELY(!ret), "theAllocator.ForEachObj() in DumpHeap() return false.");
    if (!enableLocalObjectDump) {
        return;
    }
    RegionSpace& space = reinterpret_cast<RegionSpace&>(Heap::GetHeap().GetAllocator());
    space.GetLocalObjectAllocator().VisitLocalObjects(
        [this](Mutator& mutator, BaseObject* obj, const LocalObjectInfo& info) {
            hasLocalObjects = true;
            ProcessLocalObject(mutator, obj, info);
        });
}

void CjHeapData::InitSerializedIdWrapper()
{
    Heap& heap = Heap::GetHeap();
    RegionSpace& space = reinterpret_cast<RegionSpace&>(heap.GetAllocator());
    enableLocalObjectDump = g_enableLocalObjectDump;
    bool force4Byte = enableLocalObjectDump && space.GetLocalObjectAllocator().HasLocalObjects();
    // Decide the ID domain before processing any record.  A local region may
    // contain an object that is not reachable from a root, so relying on the
    // later object visitor to flip this flag would make the first heap IDs use
    // the wrong (heap-offset) encoding.
    hasLocalObjects = force4Byte;
    serializedIdWrapper.Init(heap.GetMaxCapacity(), heap.GetStartAddress(), force4Byte);
    if (force4Byte) {
        // GetObjectId advances this seed before assigning the first ID.
        objectIdSeed = 0;
    }
}

void CjHeapData::DumpHeap(bool needStopTheWorld)
{
    // step1 - open file
    CString specifiedPath;
    if (dumpAfterOOM && !g_oomIsTrigged) {
        LOG(RTLOG_INFO, "OOM DumpHeap dumpAfterOOM");
        g_oomIsTrigged = true;
        Logger::GetLogger().GetLogPath("cjHeapDumpLog", specifiedPath);
        auto pid = MapleRuntime::GetPid();
        CString dumpFile = CString("cj_OOM_pid") + CString(pid) + CString(".dat");
#if defined(_WIN64)
        const char* separator = "\\";
#else
        const char* separator = "/";
#endif
        if (specifiedPath.IsEmpty()) {
            // dump to current path
            fp = fopen(dumpFile.Str(), "wb");
            LOG(RTLOG_INFO, "Heap dump log is writing into .%s%s ...\n", separator, dumpFile.Str());
            PRINT_INFO("Heap dump log is writing into .%s%s ...\n", separator, dumpFile.Str());
        } else {
            // dump to specified path
            dumpFile = specifiedPath + separator + dumpFile;
            fp = fopen(dumpFile.Str(), "wb");
            LOG(RTLOG_INFO, "Heap dump log is writing into %s ...\n", dumpFile.Str());
            PRINT_INFO("Heap dump log is writing into %s ...\n", dumpFile.Str());
        }
    } else {
        // dump for cjprof
        fp = fopen("item_data.dat.cache", "wb");
    }

    if (!fp) {
        LOG(RTLOG_ERROR, "Failed to open heap dump file, stop dumping heap info, %s", strerror(errno));
        return;
    }
    // step2 - write file
    if (needStopTheWorld) {
        ScopedStopTheWorld scopedStopTheWorld("dump heap to file");
        InitSerializedIdWrapper();
        size_t allocatedSize = Heap::GetHeap().GetAllocatedSize();
        // 40: Statistical ratio of heap size to object count, used to estimate container capacity
        const size_t estimateSize = 40;
        dumpObjects.reserve(allocatedSize / estimateSize);
        ProcessHeap();
        WriteHeap();
    } else {
        InitSerializedIdWrapper();
        size_t allocatedSize = Heap::GetHeap().GetAllocatedSize();
        // 40: Statistical ratio of heap size to object count, used to estimate container capacity
        const size_t estimateSize = 40;
        dumpObjects.reserve(allocatedSize / estimateSize);
        ProcessHeap();
        WriteHeap();
    }

    // step3 - close file
    int ret = fclose(fp);
    fp = nullptr;
    if (ret) {
        LOG(RTLOG_ERROR, "Fail to close file when dump heap data finished, %s", strerror(errno));
    }
    if (!dumpAfterOOM) {
        const int strLen = 20;
        char* str = static_cast<char*>(NativeAllocator::NativeAlloc(strLen * sizeof(char)));
        sprintf_s(str, strLen, "%s", "item_data.dat.cache");
        ret = rename(str, "item_data.dat");
        NativeAllocator::NativeFree(str, strLen * sizeof(char));
        if (ret) {
            LOG(RTLOG_ERROR, "Fail to rename file when dump heap data finished, %s", strerror(errno));
        }
    }
}

bool CjHeapData::DumpHeap(int fd, bool needStopTheWorld)
{
    int copyfd = dup(fd);
    if (copyfd == -1) {
        LOG(RTLOG_ERROR, "Failed to open heap dump file, stop dumping heap info, %s", strerror(errno));
    }
    fp = fdopen(copyfd, "wb");
    if (fp == nullptr) {
        close(copyfd);
        LOG(RTLOG_ERROR, "Failed to open heap dump file, stop dumping heap info, %s", strerror(errno));
        return false;
    }

    if (needStopTheWorld) {
        ScopedStopTheWorld scopedStopTheWorld("dump heap to fd");
        InitSerializedIdWrapper();
        size_t allocatedSize = Heap::GetHeap().GetAllocatedSize();
        // 40: Statistical ratio of heap size to object count, used to estimate container capacity
        const size_t estimateSize = 40;
        dumpObjects.reserve(allocatedSize / estimateSize);
        ProcessHeap();
        WriteHeap();
    } else {
        InitSerializedIdWrapper();
        size_t allocatedSize = Heap::GetHeap().GetAllocatedSize();
        // 40: Statistical ratio of heap size to object count, used to estimate container capacity
        const size_t estimateSize = 40;
        dumpObjects.reserve(allocatedSize / estimateSize);
        ProcessHeap();
        WriteHeap();
    }

    // fclose will close fd
    // if fclose success, no need to close fd.
    // if fclose failed, close fd to prevent resource leakage.
    int ret = fclose(fp);
    fp = nullptr;
    if (ret) {
        close(copyfd);
        LOG(RTLOG_ERROR, "Fail to close file when dump heap data finished, %s", strerror(errno));
        return false;
    }
    return true;
}

void CjHeapData::ProcessHeapObject(BaseObject* obj)
{
    if (obj == nullptr) {
        return;
    }

    DumpObject dumpObject = { obj, 0, 0, 0 };

    if (obj->IsRawArray()) {
        MArray* mArray = reinterpret_cast<MArray*>(obj);
        TypeInfo* componentTypeInfo = mArray->GetComponentTypeInfo();
        if (componentTypeInfo->IsPrimitiveType()) {
            dumpObject.tag = TAG_PRIMITIVE_ARRAY_DUMP;
            auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
            if (regionInfo->IsLargeRegion()) {
                dumpObject.tag = TAG_LARGE_PRIMITIVE_ARRAY_DUMP;
            } else if (regionInfo->IsUnmovableFromRegion()) {
                dumpObject.tag = TAG_UNMOVABLE_PRIMITIVE_ARRAY_DUMP;
            }
            dumpObjects.push_back(dumpObject);
        } else if (componentTypeInfo->IsStructType()) {
            dumpObject.tag = TAG_STRUCT_ARRAY_DUMP;
            auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
            if (regionInfo->IsLargeRegion()) {
                dumpObject.tag = TAG_LARGE_STRUCT_ARRAY_DUMP;
            } else if (regionInfo->IsUnmovableFromRegion()) {
                dumpObject.tag = TAG_UNMOVABLE_STRUCT_ARRAY_DUMP;
            }
            dumpObjects.push_back(dumpObject);
            ProcessStructClass(obj->GetTypeInfo());
            return;
        } else if (componentTypeInfo->IsObjectType() ||
                   componentTypeInfo->IsArrayType() ||
                   componentTypeInfo->IsInterface()) {
                dumpObject.tag = TAG_OBJECT_ARRAY_DUMP;
                auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
                if (regionInfo->IsLargeRegion()) {
                    dumpObject.tag = TAG_LARGE_OBJECT_ARRAY_DUMP;
                } else if (regionInfo->IsUnmovableFromRegion()) {
                    dumpObject.tag = TAG_UNMOVABLE_OBJECT_ARRAY_DUMP;
                }
                dumpObjects.push_back(dumpObject);
        } else {
            LOG(RTLOG_ERROR, "array object %p has wrong component type", mArray);
        }
    } else if (obj->GetTypeInfo()->IsVaildType()) {
        dumpObject.tag = TAG_INSTANCE_DUMP;
        auto regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        if (regionInfo->IsPinnedRegion()) {
            dumpObject.tag = TAG_PINNED_INSTANCE_DUMP;
        } else if (regionInfo->IsLargeRegion()) {
            dumpObject.tag = TAG_LARGE_INSTANCE_DUMP;
        } else if (regionInfo->IsUnmovableFromRegion()) {
            dumpObject.tag = TAG_UNMOVABLE_INSTANCE_DUMP;
        }
        dumpObjects.push_back(dumpObject);
    } else {
        LOG(RTLOG_ERROR, "object %p has wrong component type", obj);
        return;
    }
    ProcessRootClass(obj->GetTypeInfo());
}

void CjHeapData::ProcessLocalObject(Mutator& mutator, BaseObject* obj, const LocalObjectInfo& info)
{
    (void)mutator;
    if (obj == nullptr || obj->GetTypeInfo() == nullptr || !obj->GetTypeInfo()->IsVaildType()) {
        return;
    }
    DumpObject dumpObject { obj, TAG_INSTANCE_DUMP, 0, 0 };
    if (obj->IsRawArray()) {
        TypeInfo* componentTypeInfo = obj->GetTypeInfo()->GetComponentTypeInfo();
        if (componentTypeInfo == nullptr) {
            return;
        }
        if (componentTypeInfo->IsPrimitiveType()) {
            dumpObject.tag = info.isLargeRegion ? TAG_LARGE_PRIMITIVE_ARRAY_DUMP : TAG_PRIMITIVE_ARRAY_DUMP;
        } else if (componentTypeInfo->IsStructType()) {
            dumpObject.tag = info.isLargeRegion ? TAG_LARGE_STRUCT_ARRAY_DUMP : TAG_STRUCT_ARRAY_DUMP;
            dumpObjects.push_back(dumpObject);
            ProcessStructClass(obj->GetTypeInfo());
            return;
        } else if (componentTypeInfo->IsObjectType() || componentTypeInfo->IsArrayType() ||
                   componentTypeInfo->IsInterface()) {
            dumpObject.tag = info.isLargeRegion ? TAG_LARGE_OBJECT_ARRAY_DUMP : TAG_OBJECT_ARRAY_DUMP;
        } else {
            LOG(RTLOG_ERROR, "local array object %p has wrong component type", obj);
            return;
        }
    } else {
        dumpObject.tag = info.isLargeRegion ? TAG_LARGE_INSTANCE_DUMP : TAG_INSTANCE_DUMP;
    }
    dumpObjects.push_back(dumpObject);
    ProcessRootClass(obj->GetTypeInfo());
}

void CjHeapData::ProcessRootClass(TypeInfo* klass)
{
    if (dumpClassMap.find(klass) == dumpClassMap.end()) {
        dumpClassMap.insert(std::pair<TypeInfo*, CjHeapDataStringId>(
            klass,
            LookupStringId(klass->GetName() == nullptr ? "defaultLambda" :
                                                         klass->GetName()))); // lamda obj has null name
    }
}

void CjHeapData::ProcessStructClass(TypeInfo* klass)
{
    if (dumpStructClassMap.find(klass) == dumpStructClassMap.end()) {
        dumpStructClassMap.insert(std::pair<TypeInfo*, CjHeapDataStringId>(
            klass,
            LookupStringId(klass->GetName() == nullptr ? "defaultStructLamda" :
                                                         klass->GetName()))); // lamda obj has null name
    }
}
void CjHeapData::ProcessStacktrace(RecordStackInfo* recordStackInfo)
{
    std::vector<FrameInfo*> framesInStack = recordStackInfo->stacks;
    if (stacktraces.emplace(recordStackInfo, traceSerialNum++).second) {
        CString threadIdx = CString(threadId);
        LookupStringId(threadName);
        for (size_t i = 0; i < framesInStack.size(); ++i) {
            FrameInfo* frame = framesInStack[i];
            CjHeapDataStringId funcNameId = -1;
            CjHeapDataStringId fileNameId = -1;
            if (frame->GetFrameType() == FrameType::MANAGED) {
                funcNameId = LookupStringId(frame->GetFuncName().Str());
                fileNameId = LookupStringId(frame->GetFileName().Str());
            } else {
                Os::Loader::BinaryInfo binInfo;
                (void)Os::Loader::GetBinaryInfoFromAddress(frame->mFrame.GetIP(), &binInfo);
                fileNameId = LookupStringId(CString(binInfo.filePathName).Str());
                funcNameId = LookupStringId(CString(binInfo.symbolName).Str());
            }
            frames.insert(std::pair<FrameInfo*, CjHeapDataStackFrameId>(frame, frameId++));
            frameFuncNames.insert(std::pair<FrameInfo*, CjHeapDataStringId>(frame, funcNameId));
            frameFileNames.insert(std::pair<FrameInfo*, CjHeapDataStringId>(frame, fileNameId));
        }
    }
}

void CjHeapData::ProcessRootLocal()
{
    const bool localObjectDumpEnabled = enableLocalObjectDump;
    MutatorManager::Instance().VisitAllMutatorsExceptFinalizer([this, localObjectDumpEnabled](Mutator &mutator) {
        if (!mutator.IsVaildCJThread()) {
            return;
        }
        threadId = static_cast<uint32_t>(mutator.GetCJThreadId());
        if (mutator.GetCJThreadName() == nullptr) {
            threadName = CString("defaultName") + CString(threadId);
        } else {
            threadName = CString(mutator.GetCJThreadName());
        }
        RecordStackInfo* recordStackInfo = new RecordStackInfo(&(mutator.GetUnwindContext()), threadId, threadName);
        recordStackInfo->FillInStackTrace();

        ProcessStacktrace(recordStackInfo);
        RootVisitor rootVisitor = [this, recordStackInfo, localObjectDumpEnabled](ObjectRef &objRef) {
            BaseObject* obj = objRef.object;
            if (obj == nullptr || (!Heap::IsHeapAddress(obj) &&
                (!localObjectDumpEnabled || !IsLocalObject(obj)))) {
                return;
            }
            FrameInfo* currentFrame = recordStackInfo->GetCurrentFramePtr();
            CjHeapDataStackFrameId frameId = (currentFrame != nullptr && frames.find(currentFrame) != frames.end())
                ? frames[currentFrame] : 0;
            DumpObject dumpObject = {obj,
                TAG_ROOT_LOCAL,
                threadId,
                static_cast<u4>(frameId)
            };
            dumpObjects.push_back(dumpObject);
        };
        recordStackInfo->VisitStackRoots(rootVisitor, mutator);
    });
    if (!localObjectDumpEnabled) {
        return;
    }
    RegionSpace& space = reinterpret_cast<RegionSpace&>(Heap::GetHeap().GetAllocator());
    space.GetLocalObjectAllocator().VisitLocalRoots(
        [this](Mutator& owner, BaseObject* obj, const LocalObjectInfo& info) {
            if (obj == nullptr) {
                return;
            }
            const u1 tag = info.rootKind == LocalObjectInfo::RootKind::FINALIZER
                ? TAG_LOCAL_FINALIZER : TAG_ROOT_LOCAL_OBJECT;
            dumpObjects.push_back({ obj, tag, static_cast<u4>(owner.GetCJThreadId()), 0, info.finalizerState });
        });
}

void CjHeapData::ProcessRootGlobal()
{
    RefFieldVisitor visitor = [this](RefField<>& refField) {
        BaseObject* obj = Heap::GetBarrier().ReadStaticRef(refField);
        if (obj == nullptr || !Heap::IsHeapAddress(obj)) {
            return;
        }
        DumpObject dumpObject = { obj, TAG_ROOT_GLOBAL, 0, 0 };
        dumpObjects.push_back(dumpObject);
    };
    Heap::GetHeap().VisitStaticRoots(visitor);
}

void CjHeapData::ProcessRootConcurrencyModel()
{
    RootVisitor visitor = [this](ObjectRef& objRef) {
        BaseObject* obj = objRef.object;
        if (obj == nullptr || !Heap::IsHeapAddress(obj)) {
            return;
        }
        DumpObject dumpObject = { obj, TAG_ROOT_UNKNOWN, 0, 0 };
        dumpObjects.push_back(dumpObject);
    };
    Runtime::Current().GetConcurrencyModel().VisitGCRoots(&visitor);
}

void CjHeapData::ProcessRootFinalizer()
{
    RootVisitor visitor = [this](ObjectRef& objRef) {
        BaseObject* obj = objRef.object;
        if (obj == nullptr || !Heap::IsHeapAddress(obj)) {
            return;
        }
        DumpObject dumpObject = { obj, TAG_ROOT_UNKNOWN, 0, 0 };
        dumpObjects.push_back(dumpObject);
    };
    Heap::GetHeap().GetFinalizerProcessor().VisitGCRoots(visitor);
}

void CjHeapData::WriteHeapDump()
{
    const size_t reservedObjSize = 24;
    buffer.reserve(dumpObjects.size() * reservedObjSize);
    WriteRecordHeader(TAG_HEAP_DUMP, kCjHeapDataTime);
    WriteAllClass();
    WriteAllStructClass();
    WriteAllObjects();
    ModifyLength();
    EndRecord();
}
/*
 * Record thread info:
 *     RecordHeader header;
 *     u4 thread serial number
 *     ID thread object ID
 *     u4 stack trace serial number
 *     ID thread name string ID
 */
void CjHeapData::WriteStartThread()
{
    for (auto trace = stacktraces.begin(); trace != stacktraces.end(); trace++) {
        WriteRecordHeader(TAG_START_THREAD, kCjHeapDataTime);
        AddU4(trace->first->GetStackTid());
        AddID(threadObjectId++);
        AddU4(trace->second);
        CString threadNameAll = trace->first->GetThreadName();
        AddID(LookupStringId(threadNameAll));
        ModifyLength();
        EndRecord();
    }
}

void CjHeapData::WriteAllClass()
{
    for (const auto& klassInfo : dumpClassMap) {
        WriteClass(klassInfo.first, klassInfo.second, TAG_CLASS_DUMP);
    }
}

void CjHeapData::WriteAllStructClass()
{
    for (const auto& klassInfo : dumpStructClassMap) {
        WriteStructClass(klassInfo.first, klassInfo.second, TAG_CLASS_DUMP);
    }
}

void CjHeapData::WriteAllObjects()
{
    for (auto& objectInfo : dumpObjects) {
        switch (objectInfo.tag) {
            case TAG_ROOT_THREAD_OBJECT:
                WriteThreadObjectRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, 0);
                break;
            case TAG_ROOT_LOCAL:
                WriteLocalRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum);
                break;
            case TAG_ROOT_LOCAL_OBJECT:
                WriteLocalObjectRoot(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum);
                break;
            case TAG_LOCAL_FINALIZER:
                WriteLocalFinalizer(objectInfo.obj, objectInfo.tag, objectInfo.threadId, objectInfo.frameNum,
                                    objectInfo.finalizerState);
                break;
            case TAG_ROOT_GLOBAL:
                WriteGlobalRoot(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_ROOT_UNKNOWN:
                WriteUnknownRoot(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_OBJECT_ARRAY_DUMP:
            case TAG_LARGE_OBJECT_ARRAY_DUMP:
            case TAG_UNMOVABLE_OBJECT_ARRAY_DUMP:
                WriteObjectArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_STRUCT_ARRAY_DUMP:
            case TAG_LARGE_STRUCT_ARRAY_DUMP:
            case TAG_UNMOVABLE_STRUCT_ARRAY_DUMP:
                WriteStructArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_PRIMITIVE_ARRAY_DUMP:
            case TAG_LARGE_PRIMITIVE_ARRAY_DUMP:
            case TAG_UNMOVABLE_PRIMITIVE_ARRAY_DUMP:
                WritePrimitiveArray(objectInfo.obj, objectInfo.tag);
                break;
            case TAG_INSTANCE_DUMP:
            case TAG_PINNED_INSTANCE_DUMP:
            case TAG_LARGE_INSTANCE_DUMP:
            case TAG_UNMOVABLE_INSTANCE_DUMP:
                WriteInstance(objectInfo.obj, objectInfo.tag);
                break;
            default:
                break;
        }
    }
}
/*
 * Record Global Root Info:
 *     u1 tag;     //denoting the type of this sub-record
 *     ID objId;   // object ID
 */
void CjHeapData::WriteGlobalRoot(BaseObject*& obj, const u1 tag)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
}

/*
 * Record Unknown Root Info:
 *     u1 tag;     // denoting the type of this sub-record
 *     ID objId;   // object ID
 */
void CjHeapData::WriteUnknownRoot(BaseObject*& obj, const u1 tag)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
}

/*
 * Record Local Root Info:
 *     u1 tag;         // denoting the type of this sub-record
 *     ID objId;       // object ID
 *     u4 threadIdx;   // thread serial number
 *     u4 frame;       // frame number in stack trace (-1 for empty)
 */
void CjHeapData::WriteLocalRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    AddU4(tid);
    AddU4(depth);
}

/*
 * Local allocator scan source:
 *     u1 tag;     // TAG_ROOT_LOCAL_OBJECT
 *     ID objId;
 *     u4 threadIdx;
 *     u4 frame;
 */
void CjHeapData::WriteLocalObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    AddU4(tid);
    AddU4(depth);
}

/*
 * Local finalizer root:
 *     u1 tag;     // TAG_LOCAL_FINALIZER
 *     ID objId;
 *     u4 threadIdx;
 *     u4 frame;
 *     u1 state;   // PENDING=0, RUNNING=1
 */
void CjHeapData::WriteLocalFinalizer(BaseObject*& obj, const u1 tag, const u4 tid, const u4 depth,
                                     const u1 state)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    AddU4(tid);
    AddU4(depth);
    AddU1(state);
}

/*
 * Record Thread Object Root Info:
 *     u1 tag;             // denoting the type of this sub-record
 *     ID threadObjId;     // thread object ID
 *     u4 threadIdx;       // thread serial number
 *     u4 stackTraceIdx;   // stack trace serial number
 *
 */
void CjHeapData::WriteThreadObjectRoot(BaseObject*& obj, const u1 tag, const u4 tid, const u4 stackTraceIdx)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    AddU4(tid);
    AddU4(stackTraceIdx);
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
void CjHeapData::WriteObjectArray(BaseObject*& obj, const u1 tag)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    // take array length and content.
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    MIndex arrayLengthVal = mArray->GetLength();
    RefField<>* arrayContent = reinterpret_cast<RefField<>*>(mArray->ConvertToCArray());
    std::vector<BaseObject*> elements(arrayLengthVal);
    for (MIndex i = 0; i < arrayLengthVal; ++i) {
        elements[i] = arrayContent[i].GetTargetObject();
    }
    AddU4(static_cast<u4>(arrayLengthVal));
    AddU4(obj->GetTypeInfo()->GetUUID());
    AddObjectIdList(elements);
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

void CjHeapData::WriteStructArray(BaseObject*& obj, const u1 tag)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    u4 num = 0;
    std::vector<BaseObject*> elements;

    RefFieldVisitor visitor = [&elements, &num](RefField<>& arrayContent) {
        elements.push_back(arrayContent.GetTargetObject());
        num++;
    };

    // take array length and content.
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    MIndex arrayLengthVal = mArray->GetLength();
    TypeInfo* componentTypeInfo = mArray->GetComponentTypeInfo();
    GCTib gcTib = componentTypeInfo->GetGCTib();
    MAddress contentAddr = reinterpret_cast<Uptr>(mArray) + MArray::GetContentOffset();
    if (componentTypeInfo->HasRefField()) {
        elements.reserve(arrayLengthVal);
        for (MIndex i = 0; i < arrayLengthVal; ++i) {
            gcTib.ForEachBitmapWord(contentAddr, visitor);
            contentAddr += mArray->GetElementSize();
        }
    }
    AddU4(arrayLengthVal);
    AddU4(num);
    AddU4(obj->GetTypeInfo()->GetUUID());
    AddObjectIdList(elements);
}

/*
 * Record Primitive Array Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID arrObjId;     // array object
 *     u4 num;          // number of elements
 *     u1 type;         // element type
 */

void CjHeapData::WritePrimitiveArray(BaseObject*& obj, const u1 tag)
{
    MSize componentSize = obj->GetTypeInfo()->GetComponentSize();
    if (componentSize == 0) {
        return;
    }
    AddU1(tag);
    AddID(GetObjectId(obj));
    MArray* mArray = reinterpret_cast<MArray*>(obj);
    AddU4(mArray->GetLength());
    switch (componentSize) {
        // bool:1 bytes
        case 1:
            AddU1(BOOLEAN);
            break;
        // short:2 bytes
        case 2:
            AddU1(SHORT);
            break;
        // int:4 bytes
        case 4:
            AddU1(INT);
            break;
        // long:8 bytes
        case 8:
            AddU1(LONG);
            break;
        default:
            break;
    }
}

/*
 * Record StructClass Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID classObjId;   // class object ID (from uuid)
 *     ID classNameId;  // class name string ID
 *     u4 size;         // instance size (in bytes)
 */
void CjHeapData::WriteStructClass(TypeInfo* klass, CjHeapDataStringId klassId, const u1 tag)
{
    AddU1(tag);
    AddU4(klass->GetUUID());
    AddStringId(klassId);
    TypeInfo* componentKlass = klass->GetComponentTypeInfo();
    // No alignment required
    u4 size = componentKlass->GetInstanceSize();
    AddU4(size);
}

/*
 * Record Class Info:
 *     u1 tag;          // denoting the type of this sub-record
 *     ID classObjId;   // class object ID (from uuid)
 *     ID classNameId;  // class name string ID
 *     u4 size;         // instance size (in bytes)
 */
void CjHeapData::WriteClass(TypeInfo* klass, CjHeapDataStringId klassId, const u1 tag)
{
    AddU1(tag);
    AddU4(klass->GetUUID());
    AddStringId(klassId);
    // 8-byte alignment
    if (!klass->IsObjectType()) {
        AddU4(0);
        return;
    }
    u4 size = AlignUp<u4>((klass->GetInstanceSize() + TYPEINFO_PTR_SIZE), alignment);
    // 8 bytes for each field
    AddU4(size);
}

/*
 * Record Instance Info:
 *     u1 tag;           // denoting the type of this sub-record
 *     ID objId;         // object ID
 *     ID classObjId;    // class object ID
 *     u4 num;           // number of ref fields
 *     VAL entry[];      // ref contents in instance field values (this class, followed by super class, etc)
 */
void CjHeapData::WriteInstance(BaseObject*& obj, const u1 tag)
{
    AddU1(tag);
    AddID(GetObjectId(obj));
    AddU4(obj->GetTypeInfo()->GetUUID());
    u4 num = 0;
    std::vector<BaseObject*> elements;

    RefFieldVisitor visitor = [&elements, &num](RefField<>& fieldAddr) {
        elements.push_back(fieldAddr.GetTargetObject());
        num++;
    };

    TypeInfo* currentClass = obj->GetTypeInfo();
    if (obj->HasRefField()) {
        elements.reserve(obj->GetTypeInfo()->GetFieldNum());
        GCTib gcTib = currentClass->GetGCTib();
        MAddress objAddr = reinterpret_cast<MAddress>(obj) + TYPEINFO_PTR_SIZE;
        gcTib.ForEachBitmapWord(objAddr, visitor);
    }
    AddU4(num);
    AddObjectIdList(elements);
}

/*
 * Record String Info:
 *     u1 tag;     // TAG_STRING_IN_UTF8
 *     u4 length;  // stringId + UTF8 bytes
 *     u4 id;      // ID for this string
 *     u1 str[];   // UTF8 characters for string (NOT NULL terminated)
 */
void CjHeapData::WriteString()
{
    for (const auto& string : strings) {
        AddU1(TAG_STRING_IN_UTF8);
        CjHeapDataStringId id = string.second;
        const CString str = string.first;
        AddU4(static_cast<u4>(sizeof(SerializedStringId) + str.Length()));
        AddStringId(id);
        AddU1List(reinterpret_cast<const uint8_t*>(str.Str()), str.Length());
        EndRecord();
    }
}

/*
 * Record Stack Frame Info:
 *     RecordHeader header;
 *     ID frameId;      // stack frame ID
 *     ID methodNameId; // method name string ID
 *     ID srcFileNameId;   // source file name string ID
 *     u4 line;         // line number(>0: line number, 0: no line information available, -1: unknown
 *     location)
 */
void CjHeapData::WriteStackFrame(FrameInfo& frame, uint32_t frameIdx)
{
    if (frameIdx > 0 && frame.GetFrameType() == FrameType::NATIVE) {
        return;
    }
    if (frame.GetFrameType() == FrameType::MANAGED) {
        StackMetadataHelper stackMetadataHelper(frame);
        lineNumber = stackMetadataHelper.GetLineNumber();
    }
    WriteRecordHeader(TAG_STACK_FRAME, kCjHeapDataTime);
    AddStringId(frames[&frame]);
    AddStringId(frameFuncNames[&frame]);
    AddStringId(frameFileNames[&frame]);
    AddU4(reinterpret_cast<u4>(lineNumber));
    ModifyLength();
    EndRecord();
}

/*
 * Record Stack Trace Info:
 *     RecordHeader header;
 *     u4 stackTraceIdx;   // stack trace serial number
 *     u4 threadIdx;    // thread serial number
 *     u4 frameNum;     // number of frames
 *     ID frames[];     // series of stack frame ID's
 */
void CjHeapData::WriteStackTrace()
{
    for (auto trace = stacktraces.begin(); trace != stacktraces.end(); trace++) {
        auto env = std::getenv("DumpStackDepth");
        // 10: Default Limit Max Dump Depth as 10 frames
        size_t size = CString::ParseNumFromEnv(env) == 0 ? 10 : CString::ParseNumFromEnv(env);
        size_t depth = trace->first->stacks.size() > size ? size : trace->first->stacks.size();
        std::vector<FrameInfo*> stack = trace->first->stacks;
        for (size_t i = 0; i < depth; ++i) {
            WriteStackFrame(*stack[i], i);
        }
        WriteRecordHeader(TAG_STACK_TRACE, kCjHeapDataTime);
        AddU4(trace->second);
        AddU4(trace->first->GetStackTid());
        AddU4(depth);
        for (size_t i = 0; i < depth; ++i) {
            AddStringId(frames[stack[i]]);
        }
        ModifyLength();
        EndRecord();
    }
}

/*
 * Record Record Header Info:
 *     u1 tag;       // denoting the type of the record
 *     u8 length;    // number of bytes that follow this field and belong to this record
 */
void CjHeapData::WriteRecordHeader(const u1 tag, const u4 time)
{
    AddU1(tag);
    // DEADDEADEADDEAD: placeholder, the actual length is filled in Func modifyLength.
    const u8 tmpLens = 0xDEADDEADEADDEAD;
    AddU8(tmpLens);
}

void CjHeapData::AddU1(const u1 value) { AddU1List(&value, 1); }

void CjHeapData::AddU2(const u2 value) { AddU2List(&value, 1); }

void CjHeapData::AddU4(const u4 value) { AddU4List(&value, 1); }

void CjHeapData::AddU8(const u8 value) { AddU8List(&value, 1); }

void CjHeapData::AddID(const u8 value)
{
    serializedIdWrapper.WriteId(*this, value);
}

void CjHeapData::AddU1List(const u1* value, size_t count)
{
    HandleAddU1(value, count);
    length += count;
}

void CjHeapData::AddU2List(const u2* value, size_t count)
{
    HandleAddU2(value, count);
    length += count * sizeof(u2);
}

void CjHeapData::AddU4List(const u4* value, size_t count)
{
    HandleAddU4(value, count);
    length += count * sizeof(u4);
}
void CjHeapData::AddU8List(const u8* value, size_t count)
{
    HandleAddU8(value, count);
    length += count * sizeof(u8);
}

enum ByteOffset {
    FIRST_BYTE = 0 * 8,
    SECOND_BYTE = 1 * 8,
    THIRD_BYTE = 2 * 8,
    FOURTH_BYTE = 3 * 8,
    FIFTH_BYTE = 4 * 8,
    SIXTH_BYTE = 5 * 8,
    SEVENTH_BYTE = 6 * 8,
    EIGHTH_BYTE = 7 * 8
};

void CjHeapData::HandleAddU1(const u1* value, size_t count) { buffer.insert(buffer.end(), value, value + count); }

void CjHeapData::HandleAddU2(const u2* value, size_t count)
{
    size_t oldSize = buffer.size();
    buffer.resize(oldSize + count * sizeof(u2));
    uint8_t* dst = buffer.data() + oldSize;
    for (size_t i = 0; i < count; ++i) {
        u2 val = *value++;
        // 0: Stores 2th byte
        dst[0] = static_cast<uint8_t>((val >> SECOND_BYTE) & 0xFF);
        // 1: Stores 1th byte
        dst[1] = static_cast<uint8_t>((val >> FIRST_BYTE) & 0xFF);
        dst += sizeof(u2);
    }
}

void CjHeapData::HandleAddU4(const u4* value, size_t count)
{
    size_t oldSize = buffer.size();
    buffer.resize(oldSize + count * sizeof(u4));
    uint8_t* dst = buffer.data() + oldSize;
    for (size_t i = 0; i < count; ++i) {
        u4 val = *value++;
        // 0: Stores 4th byte
        dst[0] = static_cast<uint8_t>((val >> FOURTH_BYTE) & 0xFF);
        // 1: Stores 3th byte
        dst[1] = static_cast<uint8_t>((val >> THIRD_BYTE) & 0xFF);
        // 2: Stores 2th byte
        dst[2] = static_cast<uint8_t>((val >> SECOND_BYTE) & 0xFF);
        // 3: Stores 1th byte
        dst[3] = static_cast<uint8_t>((val >> FIRST_BYTE) & 0xFF);
        dst += sizeof(u4);
    }
}

void CjHeapData::HandleAddU8(const u8* value, size_t count)
{
    size_t oldSize = buffer.size();
    buffer.resize(oldSize + count * sizeof(u8));
    uint8_t* dst = buffer.data() + oldSize;
    for (size_t i = 0; i < count; ++i) {
        u8 val = *value++;
        // 0: Stores 8th byte
        dst[0] = static_cast<uint8_t>((val >> EIGHTH_BYTE) & 0xFF);
        // 1: Stores 7th byte
        dst[1] = static_cast<uint8_t>((val >> SEVENTH_BYTE) & 0xFF);
        // 2: Stores 6th byte
        dst[2] = static_cast<uint8_t>((val >> SIXTH_BYTE) & 0xFF);
        // 3: Stores 5th byte
        dst[3] = static_cast<uint8_t>((val >> FIFTH_BYTE) & 0xFF);
        // 4: Stores 4th byte
        dst[4] = static_cast<uint8_t>((val >> FOURTH_BYTE) & 0xFF);
        // 5: Stores 3th byte
        dst[5] = static_cast<uint8_t>((val >> THIRD_BYTE) & 0xFF);
        // 6: Stores 2th byte
        dst[6] = static_cast<uint8_t>((val >> SECOND_BYTE) & 0xFF);
        // 7: Stores 1th byte
        dst[7] = static_cast<uint8_t>((val >> FIRST_BYTE) & 0xFF);
        dst += sizeof(u8);
    }
}

void CjHeapData::AddStringId(CjHeapData::CjHeapDataStringId value)
{
    AddU4(static_cast<SerializedStringId>(value));
}

CjHeapData::u8 CjHeapData::GetObjectId(BaseObject* obj) const
{
    if (obj == nullptr) {
        return CjHeapData::NULL_OBJECT_ID;  // Special ID for null object references
    }
    if (hasLocalObjects) {
        auto existing = objectIds.find(obj);
        if (existing != objectIds.end()) {
            return existing->second;
        }
        // A deterministic sequence and collision checks keep IDs unique across
        // heap and local objects.
        uint32_t candidate = objectIdSeed;
        do {
            candidate = candidate * 1664525U + 1013904223U;
            if (candidate == 0xFFFFFFFFU) {
                continue;
            }
        } while (!allocatedObjectIds.insert(candidate).second);
        objectIdSeed = candidate;
        objectIds.emplace(obj, candidate);
        return candidate;
    }
    if (serializedIdWrapper.Use4ByteId()) {
        MAddress objAddr = reinterpret_cast<MAddress>(obj);
        return static_cast<CjHeapData::u4>(objAddr - serializedIdWrapper.GetHeapStartAddr());
    }
    return reinterpret_cast<CjHeapData::u8>(obj);
}

void CjHeapData::AddObjectIdList(const std::vector<BaseObject*>& objects)
{
    if (serializedIdWrapper.Use4ByteId()) {
        std::vector<u4> serializedIds;
        serializedIds.reserve(objects.size());
        for (BaseObject* obj : objects) {
            serializedIds.push_back(static_cast<u4>(GetObjectId(obj)));
        }
        AddU4List(serializedIds.data(), serializedIds.size());
        return;
    }

    std::vector<u8> serializedIds;
    serializedIds.reserve(objects.size());
    for (BaseObject* obj : objects) {
        serializedIds.push_back(GetObjectId(obj));
    }
    AddU8List(serializedIds.data(), serializedIds.size());
}

void CjHeapData::EndRecord()
{
    const char* ptr = reinterpret_cast<const char*>(buffer.data());
    fwrite(ptr, length, 1, fp);
    length = 0;
    std::vector<uint8_t>().swap(buffer);
}

void CjHeapData::WriteFixedHeader()
{
    if (hasLocalObjects) {
        const char localIdent[] = "CANGJIE PROFILE 1.0.3";
        AddU1List(reinterpret_cast<const uint8_t*>(localIdent), sizeof(localIdent));
    } else {
        const char legacyIdent[] = "CANGJIE PROFILE 1.0.2";
        AddU1List(reinterpret_cast<const uint8_t*>(legacyIdent), sizeof(legacyIdent));
    }
    const u4 idSize = serializedIdWrapper.Use4ByteId() ? sizeof(u4) : sizeof(u8);
    AddU4(idSize);
    struct timeval timeNow {};
    gettimeofday(&timeNow, nullptr);
    const uint64_t msecsTime = (timeNow.tv_sec * 1000) + (timeNow.tv_usec / 1000);
    const uint32_t timeHigh = static_cast<uint32_t>(msecsTime >> 32);
    const uint32_t timeLow = static_cast<uint32_t>(msecsTime & 0xFFFFFFFF);
    AddU4(timeHigh);
    AddU4(timeLow);
    EndRecord();
}

void CjHeapData::ModifyLength()
{
    // 9: Subtract the length of the record header
    constexpr uint8_t recordHeaderLength = 9;
    uint64_t value = length - recordHeaderLength;
    // 1,2,3,4,5,6,7,8: Stores 64 bits for length
    buffer[1] = (static_cast<uint8_t>((value >> EIGHTH_BYTE) & 0xFF));
    buffer[2] = (static_cast<uint8_t>((value >> SEVENTH_BYTE) & 0xFF));
    buffer[3] = (static_cast<uint8_t>((value >> SIXTH_BYTE) & 0xFF));
    buffer[4] = (static_cast<uint8_t>((value >> FIFTH_BYTE) & 0xFF));
    buffer[5] = (static_cast<uint8_t>((value >> FOURTH_BYTE) & 0xFF));
    buffer[6] = (static_cast<uint8_t>((value >> THIRD_BYTE) & 0xFF));
    buffer[7] = (static_cast<uint8_t>((value >> SECOND_BYTE) & 0xFF));
    buffer[8] = (static_cast<uint8_t>((value >> FIRST_BYTE) & 0xFF));
}

CjHeapData::CjHeapDataStringId CjHeapData::LookupStringId(const CString& string)
{
    auto res = strings.insert(std::pair<CString, CjHeapDataStringId>(string, stringId));
    if (res.second) {
        stringId++;
    }
    return res.first->second;
}

#if defined(__OHOS__) && (__OHOS__ == 1)
pid_t CjHeapData::ForkAndDumpHeap(int fd, bool fromOOM)
{
    LOG(RTLOG_INFO, "enter ForkAndDumpHeap start to fork the child process");
    pid_t childPid = fork();
    if (childPid < 0) {
        // Fork failed
        LOG(RTLOG_ERROR, "Failed to fork child process for heap dump: %s", strerror(errno));
        return -1;
    } else if (childPid == 0) {
        // Child process - execute heap dump
        LOG(RTLOG_ERROR, "Child process started for heap dump, pid: %d", getpid());
        CjHeapData* cjHeapData = new CjHeapData(fromOOM);
        if (cjHeapData != nullptr) {
            if (fd >= 0) {
                cjHeapData->DumpHeap(fd, false);
            } else {
                cjHeapData->DumpHeap(false);
            }
            LOG(RTLOG_ERROR, "Child process completed heap dump successfully");
            delete cjHeapData;
        } else {
            LOG(RTLOG_ERROR, "Failed to allocate CjHeapData in child process");
        }

        // Exit child process
        _exit(0);
    }
    // Parent process - return child pid immediately without waiting
    LOG(RTLOG_INFO, "Forked child process %d for heap dump, parent process continues", childPid);
    return childPid;
}
#endif
} // namespace MapleRuntime
