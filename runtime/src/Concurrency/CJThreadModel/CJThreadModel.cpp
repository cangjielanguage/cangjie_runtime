// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "CJThreadModel.h"

#include <pthread.h>
#include <thread>

#include "Base/Log.h"
#include "Base/LogFile.h"
#include "Cki.h"
#include "Exception/ExceptionCApi.h"
#include "LoaderManager.h"
#include "Mutator/MutatorManager.h"
#if defined(CANGJIE_TSAN_SUPPORT)
#include "Sanitizer/SanitizerInterface.h"
#endif
#include "schedule.h"

namespace MapleRuntime {
extern "C" void MRT_VisitorCaller(void* argPtr, void* handle)
{
    ObjectRef& ref = reinterpret_cast<ObjectRef&>(reinterpret_cast<LWTData*>(argPtr)->obj);
    (*reinterpret_cast<RootVisitor*>(handle))(ref);
    ObjectRef& map = reinterpret_cast<ObjectRef&>(reinterpret_cast<LWTData*>(argPtr)->threadObject);
    (*reinterpret_cast<RootVisitor*>(handle))(map);
}

// External interface for adapting to concurrent tasks
extern "C" uintptr_t MRT_CreateMutator()
{
    Mutator* mutator = MutatorManager::Instance().CreateMutator();
    ThreadLocalData* threadData = reinterpret_cast<ThreadLocalData*>(MRT_GetThreadLocalData());
    MRT_PreRunManagedCode(mutator, 1, threadData); // one layer call chain
    return 0;
}

extern "C" uintptr_t MRT_TransitMutatorToExit()
{
    MutatorManager::Instance().TransitMutatorToExit();
    return 0;
}

extern "C" void MRT_DestroyMutator(void* mutator)
{
    MutatorManager::Instance().DestroyMutator(reinterpret_cast<Mutator*>(mutator));
}

extern "C" bool MRT_CheckMutatorStatus(void* mutator)
{
    Mutator *curMutator = reinterpret_cast<Mutator*>(mutator);
    auto status = curMutator->GetUnwindContext().GetUnwindContextStatus();
    if (status == UnwindContextStatus::RISKY && curMutator->InSaferegion()) {
        curMutator->SetSuspensionFlag(Mutator::SuspensionType::SUSPENSION_FOR_EXIT);

        status = curMutator->GetUnwindContext().GetUnwindContextStatus();
        if (status != UnwindContextStatus::RISKY || !curMutator->InSaferegion()) {
            curMutator->ClearSuspensionFlag(Mutator::SuspensionType::SUSPENSION_FOR_EXIT);
            return false;
        }

        return true;
    }
    return false;
}

static void RegisterCJThreadHooks()
{
    (void)CJThreadSchdHookRegister(MRT_StopGCWork, SCHD_STOP);
    (void)CJThreadSchdHookRegister(MRT_CreateMutator, SCHD_CREATE_MUTATOR);
    (void)CJThreadSchdHookRegister(MRT_TransitMutatorToExit, SCHD_DESTROY_MUTATOR);
    (void)CJThreadSchdHookRegister(MRT_GetSafepointProtectedPage, SCHD_PREEMPT_REQ);
    (void)CJThreadDestructorHookRegister(MRT_DestroyMutator);
    (void)CJThreadGetMutatorStatusHookRegister(MRT_CheckMutatorStatus);
    LogRegister(MRT_DumpLog, ENABLE_LOG(LogType::CJTHREAD), LogFile::GetLogLevel());
}

static bool GetStackGuardFlagEnv()
{
    const char* env = std::getenv("MRT_STACK_CHECK");
    if (env != nullptr) {
        if (CString::ParseFlagFromEnv(env)) {
            return true;
        }
        LOG(RTLOG_ERROR, "unsupported MRT_STACK_CHECK. Should set variable to 1 or true or TRUE\n");
    }
    return false;
}

// ConcurrencyParam.processorNum set the processor number of scheduler, it is set as following ways:
// 1. User can set the environment variable 'cjProcessorNum' firstly.
// 2. If the variable 'cjProcessorNum' is invalid, set it by return value of hardware_concurrency().
// 3. If not, use a default value of 8 to set it finally.
void CJThreadModel::Init(const ConcurrencyParam param, ScheduleType scheduleType)
{
    ScheduleAttr attr;
    stackGuardCheck = GetStackGuardFlagEnv();
    ScheduleAttrInitWithParams(&attr, param, stackGuardCheck, scheduleType != SCHEDULE_UI_THREAD);

    ScheduleGetTlsHookRegister((GetTlsHookFunc)MRT_GetThreadLocalData);

    // should not use system page size to calculate reserved stack size,
    // because the page size could be different in different system.
#ifdef _WIN64
    constexpr uint32_t reservedStackSize = 24 * KB;
#else
    constexpr uint32_t reservedStackSize = 8 * KB;
#endif
    CJThreadStackReversedSet(reservedStackSize);
    scheduler = ScheduleNew(scheduleType, &attr);
    Cki::CreateCKI();

#if defined(CANGJIE_TSAN_SUPPORT)
    Sanitizer::TsanInitialize();
#endif
    RegisterCJThreadHooks();
}

void CJThreadModel::VisitGCRoots(RootVisitor* visitorHandle)
{
    ScheduleAllCJThreadVisit(MRT_VisitorCaller, visitorHandle);
}

// Get current mutator from tls
Mutator* ConcurrencyModel::GetMutator()
{
    if (!IsRuntimeThread()) {
        return reinterpret_cast<Mutator*>(CJThreadGetMutator());
    } else {
        return ThreadLocal::GetMutator();
    }
}

void ConcurrencyModel::SetMutator(Mutator* mutator) { CJThreadSetMutator(mutator); }
} // namespace MapleRuntime
