// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <cerrno>
#include "cjthread.h"
#include "thread.h"
#include "processor.h"
#include "schedule_impl.h"
#if defined(CANGJIE_ASAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

void SyscallEnter(void)
{
    struct CJThread *cjthread;
    struct Processor *processor;
    struct Thread *thread;
    cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return;
    }
    // Pinned by exclusiveScope: keep the processor, do not switch context on exit.
    if (cjthread->exclusiveScopeCnt.load() != 0) {
        return;
    }
    ScheduleTraceEvent(TRACE_EV_CJTHREAD_SYSCALL, TRACE_STACK_10, nullptr, 0);
    thread = static_cast<struct Thread *>(cjthread->thread);
    processor = static_cast<struct Processor *>(thread->processor);
    atomic_store(&cjthread->state, CJTHREAD_SYSCALL);
    atomic_store(&processor->state, PROCESSOR_SYSCALL);
    processor->thread = nullptr;
    thread->oldProcessor = processor;
    thread->processor = nullptr;
}

bool SyscallFastExit(struct Processor *oldProcessor)
{
    struct CJThread *cjthread;
    struct Thread *thread;
    ProcessorState expected = PROCESSOR_SYSCALL;
    cjthread = CJThreadGet();
    thread = static_cast<struct Thread *>(cjthread->thread);
    // If the status of the processor remains unchanged, rebind it.
    if (oldProcessor != nullptr && oldProcessor->state == PROCESSOR_SYSCALL &&
        atomic_compare_exchange_strong(&oldProcessor->state, &expected, PROCESSOR_RUNNING)) {
        thread->processor = reinterpret_cast<void *>(oldProcessor);
        oldProcessor->thread = thread;
        ScheduleTraceEvent(TRACE_EV_CJTHREAD_SYSEXIT, -1, nullptr, 1,
                           CJThreadGetId(static_cast<CJThreadHandle>(cjthread)));
        ScheduleTraceEvent(TRACE_EV_CJTHREAD_START, -1, nullptr, 1,
                           CJThreadGetId(static_cast<CJThreadHandle>(cjthread)));
        return true;
    }
    return false;
}

void *SyscallExit0(struct CJThread *cjthread)
{
    struct Thread *thread;
    struct Processor *processor;
    thread = static_cast<struct Thread *>(CJThreadGet()->thread);
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanEndSwitchThreadContext(CJThreadGet());
#endif
    atomic_store(&cjthread->state, CJTHREAD_READY);
    processor = ProcessorAlloc(cjthread->schedule, nullptr);
    // If there are no idle processors, join the global running queue.
    if (processor == nullptr) {
        ScheduleTraceEvent(TRACE_EV_CJTHREAD_SYSEXIT, -1, nullptr, 1,
                           CJThreadGetId(static_cast<CJThreadHandle>(cjthread)));
        thread->cjthread = nullptr;
        cjthread->thread = nullptr;
        ScheduleGlobalWrite(&cjthread, 1);
        ThreadStop(cjthread->schedule);
    } else {
        thread->processor = static_cast<void *>(processor);
        processor->thread = thread;
        ProcessorLocalWrite(cjthread);
        ScheduleTraceEvent(TRACE_EV_CJTHREAD_SYSEXIT, -1, nullptr, 1,
                           CJThreadGetId(static_cast<CJThreadHandle>(cjthread)));
        ScheduleTraceEvent(TRACE_EV_CJTHREAD_START, -1, nullptr, 1,
                           CJThreadGetId(static_cast<CJThreadHandle>(cjthread)));
    }
    ProcessorSchedule();
    return nullptr;
}

void SyscallExit(void)
{
    struct CJThread *cjthread;
    struct Processor *oldProcessor;
    struct Thread *thread;
    cjthread = CJThreadGet();
    if (cjthread == nullptr) {
        return;
    }
    // Mirrors SyscallEnter; the pin count cannot change in between.
    if (cjthread->exclusiveScopeCnt.load() != 0) {
        return;
    }
    thread = static_cast<struct Thread *>(cjthread->thread);
    oldProcessor = static_cast<struct Processor *>(thread->oldProcessor);
    // Quick route: The previously bound processor is still in syscall state.
    if (SyscallFastExit(oldProcessor)) {
        atomic_store(&cjthread->state, CJTHREAD_RUNNING);
        return;
    }
#ifdef CANGJIE_ASAN_SUPPORT
    MapleRuntime::Sanitizer::AsanStartSwitchThreadContext(cjthread, ThreadGet()->cjthread0);
#endif
    CJThreadMcall(reinterpret_cast<void *>(SyscallExit0), CJThreadAddr());
}

#ifdef __cplusplus
}
#endif