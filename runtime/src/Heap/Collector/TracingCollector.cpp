// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#include "TracingCollector.h"

#include "Common/Runtime.h"
#include "Concurrency/Concurrency.h"
#include "Heap/Allocator/AllocBuffer.h"
#include "ObjectModel/RefField.inline.h"

namespace MapleRuntime {
const size_t TracingCollector::MAX_MARKING_WORK_SIZE = 16; // fork task if bigger
const size_t TracingCollector::MIN_MARKING_WORK_SIZE = 8;  // forbid forking task if smaller

// Fill gc roots entry to buckets
void StaticRootTable::RegisterRoots(StaticRootArray* addr, U32 size)
{
    std::lock_guard<std::mutex> lock(gcRootsLock);
    gcRootsBuckets.insert(std::pair<StaticRootArray*, U32>(addr, size));
    totalRootsCount += size;
}

void StaticRootTable::UnregisterRoots(StaticRootArray* addr, U32 size)
{
    std::lock_guard<std::mutex> lock(gcRootsLock);
    auto iter = gcRootsBuckets.find(addr);
    if (iter != gcRootsBuckets.end()) {
        gcRootsBuckets.erase(iter);
        totalRootsCount -= size;
    }
}

void StaticRootTable::VisitRoots(const RefFieldVisitor& visitor)
{
    std::lock_guard<std::mutex> lock(gcRootsLock);
    U32 gcRootsSize = 0;
    std::unordered_set<RefField<>*> visitedSet;
    for (auto iter = gcRootsBuckets.begin(); iter != gcRootsBuckets.end(); iter++) {
        gcRootsSize = iter->second;
        StaticRootArray* array = iter->first;
        for (USize i = 0; i < gcRootsSize; i++) {
            RefField<>* root = array->content[i];
            // make sure to visit each static root only once time.
            if (!visitedSet.insert(root).second) {
                continue;
            }
            visitor(*root);
        }
    }
}

void ExportRootTable::VisitGCRoots(const RootVisitor& visitor)
{
    std::lock_guard<std::mutex> lock(tableMutex);
    for (auto &rootInfo : exportRoots) {
        visitor(reinterpret_cast<ObjectRef&>(rootInfo.exportObj));
    }
}
class ConcurrentMarkingWork : public HeapWork {
public:
    ConcurrentMarkingWork(TracingCollector& tc, GCThreadPool* pool, TracingCollector::WorkStack&& stack)
        : collector(tc), threadPool(pool), workStack(std::move(stack))
    {}

    // create concurrent mark task without thread pool.
    ConcurrentMarkingWork(TracingCollector& tc, TracingCollector::WorkStack&& stack)
        : collector(tc), threadPool(nullptr), workStack(std::move(stack))
    {}

    ~ConcurrentMarkingWork() override { threadPool = nullptr; }

    // when parallel is enabled, fork new task if work stack overflow.
    void TryForkTask()
    {
        size_t size = workStack.size();
        if (size > TracingCollector::MIN_MARKING_WORK_SIZE) {
            bool doFork = false;
            size_t newSize = 0;
            if (size > TracingCollector::MAX_MARKING_WORK_SIZE) {
                newSize = size >> 1; // give 1/2 the stack to the thread pool as a new work task
                doFork = true;
            } else if (size > TracingCollector::MIN_MARKING_WORK_SIZE && threadPool->GetWaitingThreadNumber() > 0) {
                constexpr uint8_t shiftForEight = 3;
                newSize = size >> shiftForEight; // give 1/8 the stack to the thread pool as a new work task
                doFork = true;
            }

            if (doFork) {
                TracingCollector::WorkStackBuf* hSplit = workStack.split(newSize);
                threadPool->AddWork(
                    new ConcurrentMarkingWork(collector, threadPool, TracingCollector::WorkStack(hSplit)));
            }
        }
    }

    // run concurrent marking task.
    void Execute(size_t) override
    {
        size_t nNewlyMarked = 0;
        // loop until work stack empty.
        for (;;) {
            if (workStack.empty()) {
                break;
            }
            // get next object from work stack.
            BaseObject* obj = workStack.back();
            workStack.pop_back();

            // skip dangling object (such as: object already released).
            DCHECK(obj->IsValidObject());

            bool wasMarked = collector.MarkObject(obj);
            if (!wasMarked) {
                nNewlyMarked++;
                if (!obj->HasRefField()) {
                    continue;
                }
                // Skip marking the weakRef itself, but trace its children node
                if (UNLIKELY(obj->IsWeakRef())) {
                    RefField<>* referentField = reinterpret_cast<RefField<>*>((uintptr_t)obj + TYPEINFO_PTR_SIZE);
                    BaseObject* referent = collector.GetAndTryTagObj(obj, *referentField);
                    if (referent != nullptr) {
                        DLOG(TRACE, "trace weakref obj %p ref@%p: 0x%zx", obj, &referent, referent);
                        collector.TraceObjectRefFields(reinterpret_cast<BaseObject*>(referent), workStack);
                        WeakRefBuffer::Instance().Insert(obj); // record live weakref objects
                    } // If referent is set to none, the corresponding weakref does not need to be recorded.
                } else {
                    collector.TraceObjectRefFields(obj, workStack);
                }
            }
            // try to fork new task if needed.
            if (threadPool != nullptr) {
                TryForkTask();
            }
        } // end of mark loop.
        // newly marked statistics.
        (void)collector.markedObjectCount.fetch_add(nNewlyMarked, std::memory_order_relaxed);
    }

private:
    TracingCollector& collector;
    GCThreadPool* threadPool;
    TracingCollector::WorkStack workStack;
};

class ExportRootsTracingWork : public HeapWork {
public:
    ExportRootsTracingWork(TracingCollector& tc, TracingCollector::WorkStack&& stack)
        : collector(tc),  workStack(std::move(stack)) {}
    void Execute(size_t) override
    {
        size_t nNewlyMarked = 0;
        // loop until work stack empty.
        for (;;) {
            if (workStack.empty()) {
                break;
            }
            // get next object from work stack.
            BaseObject* obj = workStack.back();
            workStack.pop_back();

            // skip dangling object (such as: object already released).
            DCHECK(obj->IsValidObject());

            bool wasMarked = collector.MarkObject(obj);
            if (!wasMarked) {
                collector.DFSTraceExportObject(obj);
            }
            // try to fork new task if needed.
        } // end of mark loop.
        // newly marked statistics.
        (void)collector.markedObjectCount.fetch_add(nNewlyMarked, std::memory_order_relaxed);
    }
private:
    TracingCollector& collector;
    TracingCollector::WorkStack workStack;
};
void TracingCollector::VisitStackRoots(const RootVisitor& visitor, RegSlotsMap& regSlotsMap, const FrameInfo& frame,
                                       Mutator& mutator)
{
    uintptr_t startIP = reinterpret_cast<uintptr_t>(frame.GetStartProc());
    uintptr_t frameIP = reinterpret_cast<uintptr_t>(frame.mFrame.GetIP());
    uintptr_t frameAddress = reinterpret_cast<uintptr_t>(frame.mFrame.GetFA());
    StackMapBuilder builder = StackMapBuilder(startIP, frameIP, frameAddress);
    RootMap rootMap = builder.Build<RootMap>();
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    DLOG(ENUM, "visit frame 0x%zx-@0x%zx, fp 0x%zx", startIP, frameIP, frameAddress);
    auto gcInfo = GCInfoNode::BuildNodeForTrace(startIP, frameIP, frame.mFrame.GetFA());
    auto slotDebugFunc = [&gcInfo](SlotBias off, const BaseObject* root) {
        if (Heap::GetHeap().GetAllocator().IsHeapObject(reinterpret_cast<MAddress>(root))) {
            gcInfo.InsertSlotRoots<true>(off, root);
        } else {
            gcInfo.InsertSlotRoots<false>(off, root);
        }
    };
    auto regDebugFunc = [&gcInfo](RegisterNum i, const BaseObject* root) {
        if (Heap::GetHeap().GetAllocator().IsHeapObject(reinterpret_cast<MAddress>(root))) {
            gcInfo.InsertRegRoot<true>(i, root);
        } else {
            gcInfo.InsertRegRoot<false>(i, root);
        }
    };
#else
    SlotDebugVisitor slotDebugFunc = nullptr;
    RegDebugVisitor regDebugFunc = nullptr;
#endif
    if (rootMap.IsValid()) {
        rootMap.VisitSlotRoots(visitor, slotDebugFunc);
        if (!rootMap.VisitRegRoots(visitor, regDebugFunc, regSlotsMap)) {
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
            mutator.PushFrameInfoForTrace(gcInfo);
#endif
            LOG(RTLOG_FATAL, "wrong reg info, start ip: %p frame pc: %p", reinterpret_cast<void*>(startIP),
                reinterpret_cast<void*>(frameIP));
        }
    }
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    mutator.PushFrameInfoForTrace(gcInfo);
#endif
    rootMap.RecordCalleeSaved(regSlotsMap);
}

void TracingCollector::VisitHeapReferencesOnStack(const RootVisitor& rootVisitor,
                                                  const DerivedPtrVisitor& derivedPtrVisitor, RegSlotsMap& regSlotsMap,
                                                  const FrameInfo& frame, Mutator& mutator)
{
    uintptr_t startIP = reinterpret_cast<uintptr_t>(frame.GetStartProc());
    uintptr_t frameIP = reinterpret_cast<uintptr_t>(frame.mFrame.GetIP());
    uintptr_t frameAddress = reinterpret_cast<uintptr_t>(frame.mFrame.GetFA());
    StackMapBuilder builder = StackMapBuilder(startIP, frameIP, frameAddress);
    HeapReferenceMap heapMap = builder.Build<HeapReferenceMap>();
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    auto infoNode = GCInfoNodeForFix::BuildNodeForFix(startIP, frameIP, frame.mFrame.GetFA());
    auto slotDebugFunc = [&infoNode](SlotBias off, const BaseObject* root) {
        if (Heap::GetHeap().GetAllocator().IsHeapObject(reinterpret_cast<MAddress>(root))) {
            infoNode.InsertSlotRoots<true>(off, root);
        } else {
            infoNode.InsertSlotRoots<false>(off, root);
        }
    };
    auto regDebugFunc = [&infoNode](RegisterNum i, const BaseObject* root) {
        if (Heap::GetHeap().GetAllocator().IsHeapObject(reinterpret_cast<MAddress>(root))) {
            infoNode.InsertRegRoot<true>(i, root);
        } else {
            infoNode.InsertRegRoot<false>(i, root);
        }
    };
    auto derivedPtrDebugFunc = [&infoNode](BasePtrType basePtr, DerivedPtrType derivedPtr) {
        infoNode.InsertDerivedPtrRef(basePtr, derivedPtr);
    };
#else
    RegDebugVisitor regDebugFunc = nullptr;
    SlotDebugVisitor slotDebugFunc = nullptr;
    DerivedPtrDebugVisitor derivedPtrDebugFunc = nullptr;
#endif
    DLOG(ENUM, "visit heap-ref 0x%zx-@0x%zx, fp 0x%zx", startIP, frameIP, frameAddress);
    if (heapMap.IsValid()) {
        if (!heapMap.VisitRegRoots(rootVisitor, regDebugFunc, regSlotsMap)) {
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
            mutator.PushFrameInfoForFix(infoNode);
#endif
            LOG(RTLOG_FATAL, "wrong reg info, start ip: %p frame pc: %p", reinterpret_cast<void*>(startIP),
                reinterpret_cast<void*>(frameIP));
        }
        heapMap.VisitSlotRoots(rootVisitor, slotDebugFunc);
        // VisitDerivedPtr must be invoked after VisitRegRoots and VisitSlotRoots;
        heapMap.VisitDerivedPtr(derivedPtrVisitor, derivedPtrDebugFunc, regSlotsMap);
    }
#if defined(GCINFO_DEBUG) && GCINFO_DEBUG
    mutator.PushFrameInfoForFix(infoNode);
#endif
    heapMap.RecordCalleeSaved(regSlotsMap);
}

void TracingCollector::RecordStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
{
    RegRoot::RecordStubCalleeSaved(regSlotsMap, fp);
}

#ifdef __arm__
void TracingCollector::RecordC2NStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
{
    RegRoot::RecordC2NStubCalleeSaved(regSlotsMap, fp);
}

void TracingCollector::RecordExclusiveStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
{
    RegRoot::RecordExclusiveStubCalleeSaved(regSlotsMap, fp);
}
#endif

void TracingCollector::RecordStubAllRegister(RegSlotsMap& regSlotsMap, Uptr fp)
{
    RegRoot::RecordStubAllRegister(regSlotsMap, fp);
}

void TracingCollector::EnumConcurrencyModelRoots(RootSet& rootSet) const
{
    RootVisitor visitor = [&rootSet, this](ObjectRef& root) { EnumAndTagRawRoot(root, rootSet); };
    Runtime::Current().GetConcurrencyModel().VisitGCRoots(&visitor);
}

void TracingCollector::EnumStaticRoots(RootSet& rootSet) const
{
    const RefFieldVisitor& visitor = [&rootSet, this](RefField<>& root) { EnumRefFieldRoot(root, rootSet); };
    VisitStaticRoots(visitor);
}

void TracingCollector::MergeMutatorRoots(WorkStack& workStack)
{
    MutatorManager& mutatorManager = MutatorManager::Instance();
    // hold mutator list lock to freeze mutator liveness, otherwise may access dead mutator fatally
    mutatorManager.MutatorManagementWLock();
    theAllocator.VisitAllocBuffers([&workStack](AllocBuffer& buffer) { buffer.MergeRoots(workStack); });
    mutatorManager.MutatorManagementWUnlock();
}

void TracingCollector::EnumAllExportRoots(RootSet &foreignRootsSet)
{
    Heap::GetHeap().VisitAllExportRoots([&foreignRootsSet, this](ObjectRef& root) {
        EnumAndTagRawRoot(root, foreignRootsSet);
    });
}
void TracingCollector::DoEnumeration(WorkStack& workStack, WorkStack& foreignRootsSet)
{
    ScopedEntryTrace trace("CJRT_GC_ENUM");
    EnumAllCommonRoots(GetThreadPool(), workStack);
    EnumAllExportRoots(foreignRootsSet);
}

void TracingCollector::AddExportObjectsTracingWork(RootSet &exportRoots)
{
    if (exportRoots.empty()) {
        return;
    }
    GCThreadPool* threadPool = GetThreadPool();
    threadPool->AddWork(new (std::nothrow) ExportRootsTracingWork(*this, std::move(exportRoots)));
}

void TracingCollector::TracingImpl(WorkStack& workStack, WorkStack& foreignRootsSet, bool parallel)
{
    if (workStack.empty()) {
        return;
    }

    // enable parallel marking if we have thread pool.
    GCThreadPool* threadPool = GetThreadPool();
    MRT_ASSERT(threadPool != nullptr, "thread pool is null");
    if (parallel) { // parallel marking.
        threadPool->Start();
        // add work fails, let mainGC run init task & fork tasks to poolThread for workload balance
        if (!AddConcurrentTracingWork(workStack)) {
            ConcurrentMarkingWork markTask(*this, threadPool, std::move(workStack));
            markTask.Execute(0);
        }
        threadPool->WaitFinish();
    } else {
        // serial marking with a single mark task.
        ConcurrentMarkingWork markTask(*this, std::move(workStack));
        markTask.Execute(0);
        threadPool->DrainWorkQueue(); // drain stack roots task
    }
    AddExportObjectsTracingWork(foreignRootsSet);
    threadPool->WaitFinish();
}

bool TracingCollector::AddConcurrentTracingWork(RootSet& rs)
{
    GCThreadPool* threadPool = GetThreadPool();
    size_t threadCount = threadPool->GetMaxActiveThreadNum() + 1;
    if (rs.size() <= threadCount * MIN_MARKING_WORK_SIZE) {
        return false; // too less init tasks, which may lead to workload imbalance, add work rejected
    }
    const size_t chunkSize = std::min(rs.size() / threadCount + 1, MIN_MARKING_WORK_SIZE);
    // Split the current work stack into work tasks.
    while (!rs.empty()) {
        TracingCollector::WorkStackBuf* hSplit = rs.split(chunkSize);
        threadPool->AddWork(new (std::nothrow) ConcurrentMarkingWork(*this, threadPool, WorkStack(hSplit)));
    }
    return true;
}

void TracingCollector::FindUselessExternObjects()
{
    auto it = discoveredExternObjects.begin();
    while (it != discoveredExternObjects.end()) {
        auto& ls = it->second;
        auto listIt = ls.begin();
        auto listEnd = ls.end();
        while (listIt != listEnd) {
            if (IsMarkedObject(*listIt)) {
                listIt = ls.erase(listIt);
            } else {
                MarkObject(*listIt);
                listIt++;
            }
        }
        it++;
    }
}
void TracingCollector::DoTracing(WorkStack& workStack, WorkStack& foreignRootsSet)
{
    ScopedEntryTrace trace("CJRT_GC_TRACE");
    MRT_PHASE_TIMER("DoTracing");
    VLOG(REPORT, "roots size: %zu", workStack.size());

    GCThreadPool* threadPool = GetThreadPool();
    MRT_ASSERT(threadPool != nullptr, "null thread pool");

    // use fewer threads and lower priority for concurrent mark.
    const int32_t stwWorkers = threadPool->GetMaxActiveThreadNum();
    const int32_t maxWorkers = GetGCThreadCount(true) - 1;
    if (maxWorkers > 0) {
        threadPool->SetMaxActiveThreadNum(maxWorkers);
#if defined(__linux__) || defined(hongmeng)
        threadPool->SetPriority(GCPoolThread::GC_THREAD_CONCURRENT_PRIORITY);
#endif
    }
#if defined(__linux__) || defined(hongmeng)
    GCPoolThread::SetThreadPriority(MapleRuntime::GetTid(), GCPoolThread::GC_THREAD_CONCURRENT_PRIORITY);
#endif
    VLOG(REPORT, "Concurrent mark with %u threads, workStack: %zu", (maxWorkers + 1), workStack.size());

    {
        MRT_PHASE_TIMER("Concurrent marking");
        TracingImpl(workStack, foreignRootsSet, maxWorkers > 0);
    }

    {
        MRT_PHASE_TIMER("Concurrent re-marking");
        ConcurrentReMark(workStack, maxWorkers > 0);
    }

    {
        MRT_PHASE_TIMER("identify useless extern ref");
        FindUselessExternObjects();
    }

    {
        MRT_PHASE_TIMER("concurrent resurrection");
        DoResurrection(workStack);
    }

    // restore thread pool max workers and priority after concurrent marking.
    if (maxWorkers > 0) {
        threadPool->SetMaxActiveThreadNum(stwWorkers);
#if defined(__linux__) || defined(hongmeng)
        threadPool->SetPriority(GCPoolThread::GC_THREAD_STW_PRIORITY);
#endif
    }
#if defined(__linux__) || defined(hongmeng)
    GCPoolThread::SetThreadPriority(MapleRuntime::GetTid(), GCPoolThread::GC_THREAD_STW_PRIORITY);
#endif
    VLOG(REPORT, "mark %zu objects", markedObjectCount.load(std::memory_order_relaxed));
}

bool TracingCollector::MarkSatbBuffer(WorkStack& workStack)
{
    MRT_PHASE_TIMER("MarkSatbBuffer");
    if (!workStack.empty()) {
        workStack.clear();
    }

    constexpr uint64_t maxIterationTime = 120ULL * 1000 * 1000 * 1000; // 2 mins.
    constexpr uint64_t maxIterationLoopNum = 1000;
    auto visitSatbObj = [this, &workStack]() {
        WorkStack remarkStack;
        auto func = [&remarkStack](Mutator& mutator) {
            const SatbBuffer::Node* node = mutator.GetSatbBufferNode();
            if (node != nullptr) {
                const_cast<SatbBuffer::Node*>(node)->GetObjects(remarkStack);
            }
        };
        MutatorManager::Instance().VisitAllMutators(func);
        SatbBuffer::Instance().GetRetiredObjects(remarkStack);

        while (!remarkStack.empty()) {
            BaseObject* obj = remarkStack.back();
            remarkStack.pop_back();
            if (Heap::IsHeapAddress(obj) && !this->IsMarkedObject(obj)) {
                workStack.push_back(obj);
                DLOG(TRACE, "satb buffer add obj %p", obj);
            }
        }
    };

    visitSatbObj();
    uint64_t iterationCnt = 0;
    uint64_t iterationStartTime = TimeUtil::NanoSeconds();
    do {
        if (++iterationCnt > maxIterationLoopNum && (TimeUtil::NanoSeconds() - iterationStartTime) > maxIterationTime) {
            ScopedStopTheWorld stw("MarkSatbBuffer timeout", true, GCPhase::GC_PHASE_CLEAR_SATB_BUFFER);
            VLOG(REPORT, "MarkSatbBuffer is done for timeout");
            GCThreadPool* threadPool = GetThreadPool();
            WorkStack tmp;
            TracingImpl(workStack, tmp, (workStack.size() > MAX_MARKING_WORK_SIZE) || (threadPool->GetWorkCount() > 0));
            return workStack.empty();
        }
        if (LIKELY(!workStack.empty())) {
            GCThreadPool* threadPool = GetThreadPool();
            WorkStack tmp;
            TracingImpl(workStack, tmp, (workStack.size() > MAX_MARKING_WORK_SIZE) || (threadPool->GetWorkCount() > 0));
        }
        visitSatbObj();
        if (workStack.empty()) {
            TransitionToGCPhase(GCPhase::GC_PHASE_CLEAR_SATB_BUFFER, true);
            visitSatbObj();
        }
    } while (!workStack.empty());
    return true;
}

void TracingCollector::ConcurrentReMark(WorkStack& remarkStack, bool parallel)
{
    CHECK_DETAIL(MarkSatbBuffer(remarkStack), "not cleared\n");
}

void TracingCollector::DoResurrection(WorkStack& workStack)
{
    workStack.clear();
    RootVisitor func = [&workStack, this](ObjectRef& ref) {
        RefField<>& refField = reinterpret_cast<RefField<>&>(ref);
        RefField<> tmpField(refField);
        BaseObject* finalizerObj = tmpField.GetTargetObject();
        if (!IsMarkedObject(finalizerObj)) {
            DLOG(TRACE, "resurrectable obj @%p:%p", &ref, finalizerObj);
            workStack.push_back(finalizerObj);
        }
        RefField<> newField = GetAndTryTagRefField(finalizerObj);
        if (tmpField.GetFieldValue() != newField.GetFieldValue() &&
            refField.CompareExchange(tmpField.GetFieldValue(), newField.GetFieldValue())) {
            DLOG(FIX, "tag finalizer %p@%p -> %#zx", finalizerObj, &ref, newField.GetFieldValue());
        }
    };
    snapshotFinalizerNum = collectorResources.GetFinalizerProcessor().VisitFinalizers(func);

    size_t resurrectdObjects = 0;
    while (!workStack.empty()) {
        BaseObject* obj = workStack.back();
        workStack.pop_back();

        // skip if the object already marked.
        RegionInfo* regionInfo = RegionInfo::GetRegionInfoAt(reinterpret_cast<MAddress>(obj));
        size_t offset = regionInfo->GetAddressOffset(reinterpret_cast<MAddress>(obj));
        if (regionInfo->IsSurvivedObject(offset)) {
            continue;
        }

        ++resurrectdObjects;
        ResurrectObject(obj, offset, regionInfo);

        // try to copy object child refs into work stack.
        if (obj->HasRefField()) {
            TraceObjectRefFields(obj, workStack);
        }
    }
    markedObjectCount.fetch_add(resurrectdObjects, std::memory_order_relaxed);
    VLOG(REPORT, "resurrected objects %zu", resurrectdObjects);
}

void TracingCollector::Init() {}

void TracingCollector::Fini() { Collector::Fini(); }

void TracingCollector::EnumFinalizerProcessorRoots(RootSet& rootSet) const
{
    RootVisitor visitor = [this, &rootSet](ObjectRef& root) { EnumAndTagRawRoot(root, rootSet); };
    collectorResources.GetFinalizerProcessor().VisitGCRoots(visitor);
}

void TracingCollector::EnumAllSurrectedExportRoots(RootSet &rootSet)
{
    {
        std::lock_guard<std::mutex> lg(resurrectExportMtx);
        for (auto* obj : resurrectedExportObjectes) {
            rootSet.push_back(obj);
        }
    }
    std::lock_guard<std::mutex> lg(cycleWorkStackMtx);
    auto it = cycleRefWorkStack.begin();
    while (it != cycleRefWorkStack.end()) {
        BaseObject* exportObj = it->first;
        rootSet.push_back(exportObj);
        for (auto &externObj : it->second) {
            rootSet.push_back(externObj);
        }
        it++;
    }
}

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
void TracingCollector::DumpHeap(const CString& tag)
{
    MRT_ASSERT(MutatorManager::Instance().WorldStopped(), "Not In STW");
    DLOG(FRAGMENT, "DumpHeap %s", tag.Str());
    // dump roots
    DumpRoots(FRAGMENT);
    // dump object contents
    auto dumpVisitor = [](BaseObject* obj) { obj->DumpObject(FRAGMENT); };
    bool ret = Heap::GetHeap().ForEachObj(dumpVisitor, false);
    CHECK_E(UNLIKELY(!ret), "theAllocator.ForEachObj() in DumpHeap() return false.");

    // dump object types
    DLOG(FRAGMENT, "Print Type information");
    std::set<TypeInfo*> classinfoSet;
    auto assembleClassInfoVisitor = [&classinfoSet](BaseObject* obj) {
        TypeInfo* classInfo = obj->GetTypeInfo();
        // No need to check the result of insertion, because there are multiple-insertions.
        (void)classinfoSet.insert(classInfo);
    };
    ret = Heap::GetHeap().ForEachObj(assembleClassInfoVisitor, false);
    CHECK_E(UNLIKELY(!ret), "theAllocator.ForEachObj()#2 in DumpHeap() return false.");

    for (auto it = classinfoSet.begin(); it != classinfoSet.end(); it++) {
        TypeInfo* classInfo = *it;
        DLOG(FRAGMENT, "%p %s", classInfo, classInfo->GetName());
    }
    DLOG(FRAGMENT, "Dump Allocator");
}

ATTR_NO_SANITIZE_ADDRESS
void TracingCollector::DumpRoots(LogType logType)
{
    RootVisitor rootVisitor = [this, logType](ObjectRef& ref) {
        auto obj = ref.object;
        if (obj == nullptr) {
            return;
        }
        DLOG(logType, "%p Fast Check %d Accurate Check %d", obj,
             theAllocator.IsHeapAddress(reinterpret_cast<MAddress>(obj)),
             theAllocator.IsHeapObject(reinterpret_cast<MAddress>(obj)));
    };

    DLOG(logType, "stack roots");
    MutatorManager::Instance().VisitAllMutators(
        [&rootVisitor](Mutator& mutator) { mutator.VisitMutatorRoots(rootVisitor); });

    DLOG(logType, "finalizer processor roots");
    VisitFinalizerRoots(rootVisitor);

    RefFieldVisitor refFieldVisitor = [this, logType](RefField<>& ref) {
        auto obj = ref.GetTargetObject();
        if (obj == nullptr) {
            return;
        }
        DLOG(logType, "%p Fast Check %d Accurate Check %d", obj,
             theAllocator.IsHeapAddress(reinterpret_cast<MAddress>(obj)),
             theAllocator.IsHeapObject(reinterpret_cast<MAddress>(obj)));
    };

    DLOG(logType, "static fields");
    VisitStaticRoots(refFieldVisitor);

    DLOG(logType, "Dump GCRoots end");
}
#endif

void TracingCollector::PreGarbageCollection(bool isConcurrent)
{
    VLOG(REPORT, "Begin GC log. GCReason: %s, Current allocated %s, Current threshold %s, current tag %u",
         g_gcRequests[gcReason].name, Pretty(Heap::GetHeap().GetAllocatedSize()).Str(),
         Pretty(Heap::GetHeap().GetCollector().GetGCStats().GetThreshold()).Str(), GetCurrentTagID());

    // SatbBuffer should be initialized before concurrent enumeration.
    SatbBuffer::Instance().Init();
    // prepare thread pool.
    GCThreadPool* threadPool = GetThreadPool();
    const int32_t threadCount = GetGCThreadCount(isConcurrent);
    MRT_ASSERT(threadCount >= 1, "unexpected thread count");
#if defined(__linux__) || defined(hongmeng)
    threadPool->SetPriority(GCPoolThread::GC_THREAD_STW_PRIORITY);
#endif
    threadPool->SetMaxActiveThreadNum(threadCount);

    GetGCStats().reason = gcReason;
    GetGCStats().async = !g_gcRequests[gcReason].IsSyncGC();
    GetGCStats().isConcurrentMark = isConcurrent;
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    DumpBeforeGC();
#endif
    TRACE_COUNT("CJRT_pre_GC_HeapSize", Heap::GetHeap().GetAllocatedSize());
}

void TracingCollector::PostGarbageCollection(uint64_t gcIndex)
{
    // release pages in PagePool
    TransitionToGCPhase(GCPhase::GC_PHASE_RECLAIM_SATB_NODE, true);
    SatbBuffer::Instance().ReclaimALLPages();
    PagePool::Instance().Trim();
    collectorResources.NotifyGCFinished(gcIndex);

#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
    DumpAfterGC();
#endif
}

void TracingCollector::DFSTraceExportObject(BaseObject *exportObj)
{
    WorkStack workStack;
    workStack.push_back(exportObj);
    std::list<BaseObject*> externObjs;
    while (!workStack.empty()) {
        BaseObject* obj = workStack.back();
        workStack.pop_back();
        obj->ForEachRefField([&workStack, obj, this, &externObjs](RefField<>& field) {
            (void)obj;
            RefField<> oldField(field);
            if (IsCurrentPointer(oldField)) {
                BaseObject* targetObj = oldField.GetTargetObject();
                if (IsMarkedObject(targetObj)) {
                    return;
                }
                if (targetObj->GetTypeInfo()->IsForeignType()) {
                    workStack.push_back(targetObj);
                    externObjs.push_back(targetObj);
                } else if (!MarkObject(targetObj)) {
                    workStack.push_back(targetObj);
                }
                return;
            }

            BaseObject* latest = nullptr;
            if (IsOldPointer(oldField)) {
                BaseObject* targetObj = oldField.GetTargetObject();
                latest = FindLatestVersion(targetObj);
            } else {
                latest = field.GetTargetObject();
            }

            // target object could be null or non-heap for some static variable.
            if (!Heap::IsHeapAddress(latest)) {
                return;
            }
            CHECK(latest->IsValidObject());

            RefField<> newField = GetAndTryTagRefField(latest);
            if (oldField.GetFieldValue() == newField.GetFieldValue()) {
                DLOG(TRACE, "trace obj %p ref@%p: %p<%p>(%zu)", obj, &field, latest, latest->GetTypeInfo(),
                     latest->GetSize());
            } else if (field.CompareExchange(oldField.GetFieldValue(), newField.GetFieldValue())) {
                DLOG(TRACE, "trace obj %p ref@%p: %#zx => %#zx->%p<%p>(%zu)", obj, &field, oldField.GetFieldValue(),
                     newField.GetFieldValue(), latest, latest->GetTypeInfo(), latest->GetSize());
            }

            if (IsMarkedObject(latest)) {
                return;
            }
            if (latest->GetTypeInfo()->IsForeignType()) {
                workStack.push_back(latest);
                externObjs.push_back(latest);
            } else {
                if (!MarkObject(latest)) {
                    workStack.push_back(latest);
                }
            }
        });
    }
    std::lock_guard<std::mutex> lg(externMtx);
    discoveredExternObjects[exportObj] = externObjs;
}
void TracingCollector::EnumAllCommonRoots(GCThreadPool* threadPool, RootSet& rootSet)
{
    MRT_ASSERT(threadPool != nullptr, "thread pool is null");

    const size_t threadCount = threadPool->GetMaxThreadNum() + 1;
    RootSet rootSetsInstance[threadCount];
    RootSet* rootSets = rootSetsInstance; // work_around the crash of clang parser

    // task to enum static field roots.
    threadPool->AddWork(new (std::nothrow)
                            LambdaWork([this, rootSets](size_t workerID) { EnumStaticRoots(rootSets[workerID]); }));

    // task to enum cj future objects
    threadPool->AddWork(new (std::nothrow) LambdaWork(
        [this, rootSets](size_t workerID) { EnumConcurrencyModelRoots(rootSets[workerID]); }));

    // task to enum finalizer roots.
    threadPool->AddWork(new (std::nothrow) LambdaWork(
        [this, rootSets](size_t workerID) { EnumFinalizerProcessorRoots(rootSets[workerID]); }));

    threadPool->AddWork(new (std::nothrow) LambdaWork(
        [this, rootSets](size_t workerID) { EnumAllSurrectedExportRoots(rootSets[workerID]); }));
    threadPool->Start();
    threadPool->WaitFinish();

    MergeMutatorRoots(rootSet);

    for (size_t i = 0; i < threadCount; ++i) {
        rootSet.insert(rootSets[i]);
    }
    VLOG(REPORT, "Total roots: %zu(exclude stack roots)", rootSet.size());
}

void TracingCollector::VisitStaticRoots(const RefFieldVisitor& visitor) const
{
    Heap::GetHeap().VisitStaticRoots(visitor);
}

void TracingCollector::VisitFinalizerRoots(const RootVisitor& visitor) const
{
    collectorResources.GetFinalizerProcessor().VisitGCRoots(visitor);
}

void TracingCollector::UpdateGCStats()
{
    RegionSpace& space = reinterpret_cast<RegionSpace&>(theAllocator);
    GCStats& gcStats = GetGCStats();
    gcStats.Dump();

    size_t oldThreshold = gcStats.heapThreshold;
    size_t liveBytes = space.AllocatedBytes();
    size_t heapSize = space.GetMaxCapacity();
    size_t recentBytes = space.GetRecentAllocatedSize();

    // 2 / 3: when live bytes is over 2/3 heap size, the async allocation need to be closed.
    if (liveBytes > heapSize * 2 / 3) {
        space.EnableAsyncAllocation(false);
    } else {
        space.EnableAsyncAllocation(true);
    }
    // 4 ways to estimate heap next threshold.
#if defined (__OHOS__)
    constexpr double lowUtilGrowth = 1.8;
    constexpr double lowUtilRatio = 0.25;
    double heapGrowth = liveBytes < heapSize * lowUtilRatio ?
        lowUtilGrowth : 1 + (CangjieRuntime::GetHeapParam().heapGrowth);
#else
    double heapGrowth = 1 + (CangjieRuntime::GetHeapParam().heapGrowth);
#endif
    size_t threshold1 = liveBytes * heapGrowth;
    size_t threshold2 = oldThreshold * heapGrowth;
    size_t threshold3 = liveBytes * 1.2 / (1.0 + gcStats.garbageRatio);
    size_t threshold4 = space.GetTargetSize();
    size_t newThreshold = 0;
    uint64_t gcInterval = CangjieRuntime::GetGCParam().gcInterval;
    // 2 : We regard the half of heap size as a limit because of copying algorithm.
    if (liveBytes < oldThreshold && oldThreshold < (heapSize / 2)) {
#if defined (__OHOS__)
        // When the ulitization is low, we can give the old threshold a larger weight to compute average value.
        // 1, 4, 2, 1: These are the weights of the different parameters.
        // 8: It is the total weight.
        newThreshold = (threshold1 * 1 + threshold2 * 4 + threshold3 * 2 + threshold4 * 1) / 8;
        // 2s: We set the max waiting time to 2s to avoid memory increasing too fast.
        auto maxAdaptiveInterval = static_cast<uint64_t>(2) * MapleRuntime::SECOND_TO_NANO_SECOND;
        uint64_t gcAdaptiveInterval = static_cast<uint64_t>((newThreshold - liveBytes) / gcStats.collectionRate / MB);
        gcAdaptiveInterval = std::min(gcAdaptiveInterval, maxAdaptiveInterval);
        gcInterval = std::max(gcInterval, gcAdaptiveInterval);
#else
        // 4: Computing arithmetic mean
        newThreshold = (threshold1 + threshold2 + threshold3 + threshold4) / 4;
#endif
    } else {
        // When the ulitization is high, we try to avoid threshold increasing and give it a small weight.
        // 2, 1, 2, 3: These are the weights of the different parameters.
        // 8: It is the total weight.
        newThreshold = (threshold1 * 2 + threshold2 * 1 + threshold3 * 2 + threshold4 * 3) / 8;
    }
    // 0.98: make sure new threshold does not exceed reasonable limit.
    newThreshold = std::min(newThreshold, static_cast<size_t>(space.GetMaxCapacity() * 0.98));
    gcStats.heapThreshold = std::min(newThreshold, CangjieRuntime::GetGCParam().gcThreshold);
    g_gcRequests[GC_REASON_HEU].SetMinInterval(gcInterval);
    VLOG(REPORT, "live bytes %zu (survived %zu, recent-allocated %zu), update gc threshold %zu -> %zu", liveBytes,
         liveBytes - recentBytes, recentBytes, oldThreshold, gcStats.heapThreshold);
    TRACE_COUNT("CJRT_post_GC_HeapSize", Heap::GetHeap().GetAllocatedSize());
}
} // namespace MapleRuntime
