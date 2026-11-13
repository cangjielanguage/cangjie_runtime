// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_SCHEDULE_RENAME_H
#define MRT_SCHEDULE_RENAME_H

#ifdef MRT_USE_CJTHREAD_RENAME
#define CANGJIE
#endif
#include "schedule_rename_part2.h"

#ifdef CANGJIE

/* schdfd */
#define SchdfdInit                               CJ_SchdfdInit
#define SchdfdIncref                             CJ_SchdfdIncref
#define SchdfdDecref                             CJ_SchdfdDecref
#define SchdfdRegister                           CJ_SchdfdRegister
#define SchdfdWakeall                            CJ_SchdfdWakeAll
#define SchdfdNetpollAdd                         CJ_SchdfdNetpollAdd
#define SchdfdDeregister                         CJ_SchdfdDeregister
#define SchdfdWait                               CJ_SchdfdWait
#define SchdfdWaitTimeout                        CJ_SchdfdWaitTimeout
#define SchdfdWaitInlock                         CJ_SchdfdWaitInlock
#define SchdfdReadTimeout                        CJ_SchdfdReadTimeout
#define SchdfdWriteTimeout                       CJ_SchdfdWriteTimeout
#define SchdfdWaitInlockTimeout                  CJ_SchdfdWaitInlockTimeout
#define SchdfdLock                               CJ_SchdfdLock
#define SchdfdUnlock                             CJ_SchdfdUnlock
#define SchdfdRegisterAndNetpollAdd              CJ_SchdfdRegisterAndNetpollAdd
#define SchdfdPdPut                              CJ_SchdfdPdPut
#define SchdfdPdRemove                           CJ_SchdfdPdRemove
#define g_keepAliceCfg                           CJ_GKeepAliceCfg
/* windows api */
#define g_iocpCompleteSkipFlag                   CJ_GIocpCompleteSkipFlag
#define SchdfdUpdateIocpOperationInlock          CJ_SchdfdUpdateIocpOperationInlock
#define SchdfdIocpWaitInlock                     CJ_SchdfdIocpWaitInlock
#define SchdfdCheckIocpCompleteSkip              CJ_SchdfdSCheckIocpCompleteSkipFlag
#define SchdfdUseSkipIocp                        CJ_SchdfdUseSkipIocp
#define SchdfdFdValidCheck                       CJ_SchdfdValidCheck

/* sock */
#define g_sockErrno                              CJ_GSockErrno
#define g_sockCommHooks                          CJ_GSockCommHooks
#define g_mswsockHooks                           CJ_GMswsockHooks

#define SockErrnoSet                             CJ_SockErrnoSet
#define SockErrnoGet                             CJ_SockErrnoGet
#define SockCommHooksReg                         CJ_SockCommHooksReg
#define SockStrToNetType                         CJ_SockStrToNetType
#define SockHandleParse                          CJ_SockHandleParse
#define SockCreate                               CJ_MRT_SockCreate
#define SockBind                                 CJ_MRT_SockBind
#define SockListen                               CJ_MRT_SockListen
#define SockAcceptTimeout                        CJ_MRT_SockAcceptTimeout
#define SockAccept                               CJ_MRT_SockAccept
#define SockConnectTimeout                       CJ_MRT_SockConnectTimeout
#define SockConnect                              CJ_MRT_SockConnect
#define SockDisconnect                           CJ_MRT_SockDisconnect
#define SockSendTimeout                          CJ_MRT_SockSendTimeout
#define SockSend                                 CJ_MRT_SockSend
#define SockSendNonBlock                         CJ_MRT_SockSendNonBlock
#define SockWaitSendTimeout                      CJ_MRT_SockWaitSendTimeout
#define SockWaitSend                             CJ_MRT_SockWaitSend
#define SockRecvTimeout                          CJ_MRT_SockRecvTimeout
#define SockRecv                                 CJ_MRT_SockRecv
#define SockRecvNonBlock                         CJ_MRT_SockRecvNonBlock
#define SockWaitRecvTimeout                      CJ_MRT_SockWaitRecvTimeout
#define SockWaitRecv                             CJ_MRT_SockWaitRecv
#define SockClose                                CJ_MRT_SockClose
#define SockShutdown                             CJ_MRT_SockShutdown
#define SockKeepAliveSet                         CJ_SockKeepAliveSet
#define SockAddrGet                              CJ_SockAddrGet
#define SockLocalAddrGet                         CJ_MRT_SockLocalAddrGet
#define SockPeerAddrGet                          CJ_MRT_SockPeerAddrGet
#define SockSendtoTimeout                        CJ_SockSendtoTimeout
#define SockSendto                               CJ_MRT_SockSendto
#define SockSendtoNonBlock                       CJ_MRT_SockSendtoNonBlock
#define SockRecvfromTimeout                      CJ_MRT_SockRecvfromTimeout
#define SockRecvfrom                             CJ_SockRecvfrom
#define SockRecvfromNonBlock                     CJ_MRT_SockRecvfromNonBlock
#define SockOptionSet                            CJ_SockOptionSet
#define SockOptionGet                            CJ_SockOptionGet
#define SockAddrGetGeneral                       CJ_SockAddrGetGeneral
#define SockOptionSetGeneral                     CJ_SockOptionSetGeneral
#define SockOptionGetGeneral                     CJ_SockOptionGetGeneral
#define SockCloseGeneral                         CJ_MRT_SockCloseGeneral
#define SockShutdownGeneral                      CJ_SockShutdownGeneral
#define SockRecvGeneral                          CJ_SockRecvGeneral
#define SockSendGeneral                          CJ_SockSendGeneral
#define SockSendGeneral                          CJ_SockSendGeneral
#define SockSendtoGeneral                        CJ_SockSendtoGeneral
#define SockRecvfromGeneral                      CJ_SockRecvfromGeneral
#define SockSendNonBlockGeneral                  CJ_SockSendNonBlockGeneral
#define SockRecvNonBlockGeneral                  CJ_MRT_SockRecvNonBlockGeneral
#define SockSendtoNonBlockGeneral                CJ_MRT_SockSendtoNonBlockGeneral
#define SockRecvfromNonBlockGeneral              CJ_SockRecvfromNonBlockGeneral
#define SockWinStartup                           CJ_SockWinStartup
#define SockLoadMswsockHooks                     CJ_SockLoadMswsockHooks
#define SockMswsockHooksReg                      CJ_SockMswsockHooksReg
#define SockWinInit                              CJ_SockWinInit
#define SockGetLocalDefaultAddr                  CJ_SockGetLocalDefaultAddr

/* tcpsock */
#define TcpsockBind                              CJ_TcpsockBind
#define TcpsockBindListen                        CJ_TcpsockBindListen
#define TcpsockAccept                            CJ_TcpsockAccept
#define TcpsockConnect                           CJ_TcpsockConnect
#define TcpsockCreate                            CJ_TcpsockCreate
#define TcpsockBindConnect                       CJ_TcpsockBindConnect
#define TcpsockKeepAliveSet                      CJ_TcpsockKeepAliveSet
#define TcpsockInit                              CJ_MRT_TcpsockInit
#define TcpsockAcceptSuccessLogWrite             CJ_TcpsockAcceptSuccessLogWrite
#define TcpsockRegisterSocketHooks               CJ_TcpsockRegisterSocketHooks
#define TcpsockWait                              CJ_TcpsockWait
#define TcpsockWaitSend                          CJ_TcpsockWaitSend
#define TcpsockWaitRecv                          CJ_TcpsockWaitRecv
/* windows api */
#define ConnectBindLocal                         CJ_ConnectBindLocal
#define TcpsockAcceptCoreInlock                  CJ_TcpsockAcceptCoreInlock

/* domainsock */
#define DomainsockCreate                         CJ_DomainsockCreate
#define DomainsockBind                           CJ_DomainsockBind
#define DomainsockBindListen                     CJ_DomainsockBindListen
#define DomainsockAccept                         CJ_DomainsockAccept
#define DomainsockConnect                        CJ_DomainsockConnect
#define DomainsockBindConnect                    CJ_DomainsockBindConnect
#define DomainsockInit                           CJ_MRT_DomainsockInit

/* udpsock */
#define UdpsockCreate                            CJ_UdpsockCreate
#define UdpsockBind                              CJ_UdpsockBind
#define UdpsockBindNoListen                      CJ_UdpsockBindNoListen
#define UdpsockConnect                           CJ_UdpsockConnect
#define UdpsockDisconnect                        CJ_UdpsockDisconnect
#define UdpsockBindConnect                       CJ_UdpsockBindConnect
#define UdpsockRegisterSocketHooks               CJ_UdpsockRegisterSocketHooks
#define UdpsockInit                              CJ_MRT_UdpsockInit

/* log */
#define g_logFunc                                CJ_GLogFunc
#define g_logEnable                              CJ_GLogEnable
#define g_logLevel                               CJ_GLogLevel

#define ErrorLeverString                         CJ_ErrorLeverString
#define LogWrite                                 CJ_LogWrite
#define LogRegister                              CJ_LogRegister
#define LogInfoWritable                          CJ_LogInfoWritable

/* netpoll */
#define g_epollRegister                         CJ_GEpollRegister

#define NetpollExit                             CJ_NetpollExit
#define NetpollFnRegister                       CJ_NetpollFnRegister
#define NetpollFnUnregister                     CJ_NetpollFnUnregister
#define NetpollCreateImpl                       CJ_NetpollCreateImpl
#define NetpollCreate                           CJ_NetpollCreate
#define NetpollAdd                              CJ_NetpollAdd
#define NetpollDel                              CJ_NetpollDel
#define NetpollWait                             CJ_NetpollWait
#define NetpollInnerFd                          CJ_NetpollInnerFd
#define NetpollMetaDataInit                     CJ_NetpollMetaDataInit

/* cjthread */
#define g_cjthread                              CJ_GCJThread
#define g_schedule                              CJ_GSchedule
#define g_scheduleList                          CJ_GScheduleList
#define g_preemptFlag                           CJ_GPreemptFlag
#define g_cjthreadStackReservedSize             CJ_GCJThreadStackReservedSize

#define GetCJThreadScheduler                   CJ_GetCJThreadScheduler
#define RebindCJThread                         CJ_RebindCJThread
#define CJThreadMemFree                        CJ_CJThreadMemFree
#define CJThreadFree                           CJ_CJThreadFree
#define CJThreadNewId                          CJ_CJThreadNewId
#define CJThreadInit                           CJ_CJThreadInit
#define CJThreadMemAlloc                       CJ_CJThreadMemAlloc
#define CJThreadAlloc                          CJ_CJThreadAlloc
#define CJThreadMexit                          CJ_CJThreadMexit
#define CJThreadExit                           CJ_CJThreadExit
#define CJThreadEntry                          CJ_CJThreadEntry
#define CJThreadEntryInitMutator               CJ_CJThreadEntryInitMutator
#define CJThreadMake                           CJ_CJThreadMake
#define CJThread0Make                          CJ_CJThread0Make
#define CJThreadAttrCheck                      CJ_CJThreadAttrCheck
#define CJThreadNew                            CJ_CJThreadNew
#define CJThreadNewToSchedule                  CJ_CJThreadNewToSchedule
#define CJThreadNewToDefault                   CJ_CJThreadNewToDefault
#define CJThreadSchdHookRegister               CJ_CJThreadSchdHookRegister
#define CJThreadeStateHookRegister             CJ_CJThreadStateHookRegister
#define CJThreadMpark                          CJ_CJThreadMpark
#define CJThreadPark                           CJ_CJThreadPark
#define CJThreadWait                           CJ_CJThreadWait
#define CJThreadResumeAndWait                  CJ_CJThreadResumeAndWait
#define CJThreadMresched                       CJ_CJThreadMresched
#define CJThreadResched                        CJ_CJThreadResched
#define CJThreadPreemptResched                 CJ_CJThreadPreemptResched
#define CJThreadReady                          CJ_CJThreadReady
#define CJThreadAddBatch                       CJ_CJThreadAddBatch
#define CJThreadId                             CJ_CJThreadId
#define CJThreadGetId                          CJ_CJThreadGetId
#define CJThreadGetHandle                      CJ_CJThreadGetHandle
#define CJThreadSetName                        CJ_CJThreadSetName
#define CJThreadGetInfo                        CJ_CJThreadGetInfo
#define CJThreadStackReversedSet               CJ_CJThreadStackReversedSet
#define CJThreadStackReversedGet               CJ_CJThreadStackReversedGet
#define CJThreadStackGuardExpand               CJ_CJThreadStackGuardExpand
#define CJThreadStackGuardRecover              CJ_CJThreadStackGuardRecover
#define CJThreadAttrInit                       CJ_CJThreadAttrInit
#define CJThreadAttrStackSizeSet               CJ_CJThreadAttrStackSizeSet
#define CJThreadAttrNameSet                    CJ_CJThreadAttrNameSet
#define CJThreadAttrCjFromCSet                 CJ_CJThreadAttrCJFromCSet
#define CJThreadNewSetLocalData                CJ_CJThreadNewSetLocalData
#define CJThreadNewSetAttr                     CJ_CJThreadNewSetAttr
#define CJThreadAttrSpecificSet                CJ_CJThreadAttrSpecificSet
#define CJBindOSThread                         CJ_BindOSThread
#define CJUnbindOSThread                       CJ_UnbindOSThread
#define CJThreadStackGuardGet                  CJ_CJThreadStackGuardGet
#define CJThreadStackSizeGet                   CJ_CJThreadStackSizeGet
#define CJThreadStackAddrGet                   CJ_CJThreadStackAddrGet
#define CJThreadStackBaseAddrGet               CJ_CJThreadStackBaseAddrGet
#define CJThreadStackSizeGetByCJThrd           CJ_CJThreadStackSizeGetByCJThrd
#define CJThreadStackAddrGetByCJThrd           CJ_CJThreadStackAddrGetByCJThrd
#define CJThreadStackBaseAddrGetByCJThrd       CJ_CJThreadStackBaseAddrGetByCJThrd
#define CJThreadPreemptOffCntAdd               CJ_CJThreadPreemptOffCntAdd
#define CJThreadPreemptOffCntSub               CJ_CJThreadPreemptOffCntSub
#define CJThreadAndArgsMemAlloc                CJ_CJThreadAndArgsMemAlloc
#define CJThreadStackMemAlloc                  CJ_CJThreadStackMemAlloc
#define CJThreadStackMemFree                   CJ_CJThreadStackMemFree
#define CJThreadStackAttrInit                  CJ_CJThreadStackAttrInit
#define CJThreadDestructorHookRegister         CJ_CJThreadDestructorHookRegister
#define CJThreadGetMutatorStatusHookRegister   CJ_CJThreadGetMutatorStatusHookRegister
#define CJThreadGetMutator                     CJ_CJThreadGetMutator
#define CJThreadSetMutator                     CJ_CJThreadSetMutator

#define LuaFuncWrap                            CJ_LuaFuncWrap
#define CJThreadCreate                         CJ_CJThreadCreate
#define CJThreadYieldCallback                  CJ_CJThreadYieldCallback
#define CJThreadYield                          CJ_CJThreadYield
#define CJThreadResume                         CJ_CJThreadResume
#define CJThreadStateGet                       CJ_CJThreadStateGet
#define CJThreadDestroy                        CJ_CJThreadDestroy
#define CJThreadResultGet                      CJ_CJThreadResultGet
#define CJThreadGetArg                         CJ_CJThreadGetArg
#define CJThreadStackAdjust                    CJ_CJThreadStackAdjust
#define CJThreadStackGrow                      CJ_CJThreadStackGrow
#define CJThreadOldStackFree                   CJ_CJThreadOldStackFree
#define CJThreadSetStackGrow                   CJ_CJThreadSetStackGrow

#define GetUIThreadStackTop                    CJ_GetUIThreadStackTop
#define PopUIThreadStackTop                    CJ_PopUIThreadStackTop
#define PushUIThreadStackTop                   CJ_PushUIThreadStackTop
#define CJRegisterSubStackInfoCallbacks        CJ_CJRegisterSubStackInfoCallbacks
#define CJRegisterExternalVMInRuntime          CJ_CJRegisterExternalVMInRuntime

/* cjthread_key */
#define g_cjthreadKeys                         CJ_GCJThreadKeys

#define CJThreadKeyCreateInner                 CJ_CJThreadKeyCreateInner
#define CJThreadSetspecificInner               CJ_CJThreadSetSpecificInner
#define CJThreadGetspecificInner               CJ_CJThreadGetSpecificInner
#define CJThreadKeysClean                      CJ_CJThreadKeysClean

/* processor */
#define g_randSeed                              CJ_GRandSeed

#define ProcessorGlobalWrite                    CJ_ProcessorGlobalWrite
#define ProcessorLocalWriteBatch                CJ_ProcessorLocalWriteBatch
#define ProcessorGlobalRead                     CJ_ProcessorGlobalRead
#define ProcessorLocalRead                      CJ_ProcessorLocalRead
#define ProcessorLocalWrite                     CJ_ProcessorLocalWrite
#define ProcessorQueueSteal                     CJ_ProcessorQueueSteal
#define ProcessorCJThreadSteal                  CJ_ProcessorCJThreadSteal
#define ProcessorRelease                        CJ_ProcessorRelease
#define ProcessorStopWithLastCheck              CJ_ProcessorStopWithLastCheck
#define RandSeedInit                            CJ_RandSeedInit
#define RandomPseudo                            CJ_RandomPseudo
#define ProcessorTimerSteal                     CJ_ProcessorTimerSteal
#define ProcessorSteal                          CJ_ProcessorSteal
#define ProcessorSearchingSteal                 CJ_ProcessorSearchingSteal
#define ProcessorSearchingGlobal                CJ_ProcessorSearchingGlobal
#define ProcessorTimerCheck                     CJ_ProcessorTimerCheck
#define ProcessorCJThreadGet                    CJ_ProcessorCJThreadGet
#define ProcessorSchedule                       CJ_ProcessorSchedule
#define ProcessorInit                           CJ_ProcessorInit
#define ProcessorFree                           CJ_ProcessorFree
#define ProcessorNonDefaultScheduleWake         CJ_ProcessorNonDefaultScheduleWake
#define ProcessorWake                           CJ_ProcessorWake
#define ProcessorAlloc                          CJ_ProcessorAlloc
#define ProcessorThreadExit                     CJ_ProcessorThreadExit
#define ProcessorGetspecific                    CJ_ProcessorGetSpecific
#define ProcessorSetspecific                    CJ_ProcessorSetSpecific
#define ProcessorGetInfoAll                     CJ_ProcessorGetInfoAll
#define ProcessorFreelistPush                   CJ_ProcessorFreelistPush
#define ProcessorFreelistPop                    CJ_ProcessorFreelistPop
#define ProcessorFreelistPut                    CJ_ProcessorFreelistPut
#define ProcessorFreelistGet                    CJ_ProcessorFreelistGet
#define ProcessorStartBoundCJThread             CJ_ProcessorStartBoundCJThread
#define ProcessorStopBoundCJThread              CJ_ProcessorStopBoundCJThread
#define ProcessorNewId                          CJ_ProcessorNewId
#define ProcessorId                             CJ_ProcessorId
#define ProcessorCanSpin                        CJ_ProcessorCanSpin

/* schdpoll */
#define SchdpollInit                            CJ_SchdpollInit
#define SchdpollAdd                             CJ_SchdpollAdd
#define SchdpollDel                             CJ_SchdpollDel
#define SchdpollWaitPark                        CJ_SchdpollWaitPark
#define SchdpollWait                            CJ_SchdpollWait
#define SchdpollReady                           CJ_SchdpollReady
#define SchdpollAcquireCallback                 CJ_SchdpollAcquireCallback
#define SchdpollAcquire                         CJ_SchdpollAcquire
#define SchdpollCallbackCJThread                CJ_SchdpollCallbackCJThread
#define SchdpollNotifyCallback                  CJ_SchdpollNotifyCallback
#define SchdpollCallbackAdd                     CJ_SchdpollCallbackAdd
#define SchdpollNotifyAdd                       CJ_SchdpollNotifyAdd
#define SchdpollNotifyDel                       CJ_SchdpollNotifyDel
#define SchdpollInnerFd                         CJ_SchdpollInnerFd
#define SchdpollFreePd                          CJ_SchdpollFreePd

/* schedule */
#define g_schdAttr                              CJ_GSchdAttr
#define g_scheduleManager                       CJ_GScheduleManager
#define g_timerHookFunc                         CJ_GTimerHookFunc
#define g_pageSize                              CJ_GPageSize
#define g_tryExit                               CJ_GTryExit

#define SetSchedulerState                       CJ_SetSchedulerState
#define ScheduleAttributeGet                    CJ_ScheduleAttributeGet
#define ScheduleAttrInit                        CJ_ScheduleAttrInit
#define ScheduleAttrCostackSizeSet              CJ_ScheduleAttrCostackSizeSet
#define ScheduleAttrThstackSizeSet              CJ_ScheduleAttrThstackSizeSet
#define ScheduleAttrProcessorNumSet             CJ_ScheduleAttrProcessorNumSet
#define ScheduleAttrStackProtectSet             CJ_ScheduleAttrStackProtectSet
#define ScheduleAttrStackGrowSet                CJ_ScheduleAttrStackGrowSet
#define ScheduleAttrRegisterFuncSet             CJ_ScheduleAttrRegisterFuncSet
#define ScheduleRecursiveLockCreate             CJ_ScheduleRecursiveLockCreate
#define ScheduleProcessorInit                   CJ_ScheduleProcessorInit
#define ScheduleThreadInit                      CJ_ScheduleThreadInit
#define ScheduleGfreelistInit                   CJ_ScheduleGfreelistInit
#define ScheduleCJThreadInit                    CJ_ScheduleCJThreadInit
#define ScheduleThread0Init                     CJ_ScheduleThread0Init
#define ScheduleAttrCheck                       CJ_ScheduleAttrCheck
#define ScheduleAlloc                           CJ_ScheduleAlloc
#define ScheduleThread0Fini                     CJ_ScheduleThread0Fini
#define ScheduleCJThreadFini                    CJ_ScheduleCJThreadFini
#define ScheduleThreadFini                      CJ_ScheduleThreadFini
#define ScheduleFree                            CJ_ScheduleFree
#define ScheduleFini                            CJ_ScheduleFini
#define ScheduleManagerInit                     CJ_ScheduleManagerInit
#define ScheduleManagerDestroy                  CJ_ScheduleManagerDestroy
#define ScheduleNew                             CJ_ScheduleNew
#define ScheduleNetpollInit                     CJ_ScheduleNetpollInit
#define ScheduleNetpollDestroy                  CJ_ScheduleNetpollDestroy
#define ScheduleStart                           CJ_ScheduleStart
#define ScheduleExistTask                       CJ_ScheduleExistTask
#define ScheduleStartNoWait                     CJ_ScheduleStartNoWait
#define ScheduleNonDefaultThreadExit            CJ_ScheduleNonDefaultThreadExit
#define ScheduleThreadsFree                     CJ_ScheduleThreadsFree
#define ScheduleProcessorFree                   CJ_ScheduleProcessorFree
#define ScheduleSchmonExit                      CJ_ScheduleSchmonExit
#define ScheduleCJThreadFree                    CJ_ScheduleCJThreadFree
#define ScheduleNetpollExit                     CJ_ScheduleNetpollExit
#define ScheduleAnyCJThreadRunning              CJ_ScheduleAnyCJThreadRunning
#define ScheduleNonDefaultFree                  CJ_ScheduleNonDefaultFree
#define ScheduleProcessorSkipFFI                CJ_ScheduleProcessorSkipFFI
#define ScheduleAllNonDefaultExit               CJ_ScheduleAllNonDefaultExit
#define ScheduleProcessorExit                   CJ_ScheduleProcessorExit
#define ScheduleExitMode                        CJ_ScheduleExitMode
#define ScheduleStop                            CJ_ScheduleStop
#define ScheduleStopOutside                     CJ_ScheduleStopOutside
#define ScheduleTryExit                         CJ_ScheduleTryExit
#define ScheduleClean                           CJ_ScheduleClean
#define ScheduleGlobalWrite                     CJ_ScheduleGlobalWrite
#define ScheduleAnyCJThread                     CJ_ScheduleAnyCJThread
#define ScheduleCJThreadCount                   CJ_ScheduleCJThreadCount
#define ScheduleCJThreadCountPublic             CJ_ScheduleCJThreadCountPublic
#define ScheduleRunningOSThreadCount            CJ_ScheduleRunningOSThreadCount
#define SchdProcessorHookRegister               CJ_SchdProcessorHookRegister
#define SchdSchmonHookRegister                  CJ_SchdSchmonHookRegister
#define SchdExitHookRegister                    CJ_SchdExitHookRegister
#define SchdCheckExistenceHookRegister          CJ_SchdCheckExistenceHookRegister
#define SchdCheckReadyHookRegister              CJ_SchdCheckReadyHookRegister
#define ScheduleTimerHookRegister               CJ_ScheduleTimerHookRegister
#define ScheduleGfreelistPush                   CJ_ScheduleGfreelistPush
#define ScheduleGfreelistPop                    CJ_ScheduleGfreelistPop
#define ScheduleGfreelistGet                    CJ_ScheduleGfreelistGet
#define ScheduleListAdd                         CJ_ScheduleListAdd
#define ScheduleListRemove                      CJ_ScheduleListRemove
#define ScheduleAllThreadListAdd                CJ_ScheduleAllThreadListAdd
#define ScheduleAllCJThreadListAdd              CJ_ScheduleAllCJThreadListAdd
#define ScheduleAllCJThreadListRemove           CJ_ScheduleAllCJThreadListRemove
#define ScheduleAllCJThreadVisitImpl            CJ_ScheduleAllCJThreadVisitImpl
#define ScheduleAllCJThreadVisit                CJ_ScheduleAllCJThreadVisit
#define ScheduleAllCJThreadVisitMutator         CJ_ScheduleAllCJThreadVisitMutator
#define ScheduleAnyCJThreadOrTimer              CJ_ScheduleAnyCJThreadOrTimer
#define ScheduleLockAll                         CJ_ScheduleLockAll
#define ScheduleUnlockAll                       CJ_ScheduleUnlockAll
#define ScheduleSuspend                         CJ_ScheduleSuspend
#define ScheduleResume                          CJ_ScheduleResume
#define SchedulePreemptCheck                    CJ_SchedulePreemptCheck
#define ScheduleIsRunning                       CJ_ScheduleIsRunning
#define ScheduleSetToCurrentThread              CJ_ScheduleSetToCurrentThread
#define ScheduleGetProcessorNum                 CJ_ScheduleGetProcessorNum
#define ScheduleTraceDlclose                    CJ_ScheduleTraceDlclose
#define ScheduleStartTrace                      CJ_ScheduleStartTrace
#define ScheduleStopTrace                       CJ_ScheduleStopTrace
#define ScheduleDumpTrace                       CJ_ScheduleDumpTrace
#define ScheduleGetTraceReader                  CJ_ScheduleGetTraceReader
#define ScheduleTraceEventOrigin                CJ_ScheduleTraceEventOrigin
#define ScheduleTraceEvent                      CJ_ScheduleTraceEvent

/* windows global value */
#define g_localTlsOffset                        CJ_GLocalTlsOffset

/* tls dynmic */
#define ScheduleGetTlsHookRegister              CJ_ScheduleGetTlsHookRegister
#define g_getTlsFunc                            CJ_GGetTlsFunc

/* schmon */
#define SchmonPreemptSyscall                    CJ_SchmonPreemptSyscall
#define SchmonPreemptRunning                    CJ_SchmonPreemptRunning
#define SchmonProcessorPreemptCheck             CJ_SchmonProcessorPreemptCheck
#define SchmonCheckAllprocessors                CJ_SchmonCheckAllProcessors
#define SchmonRemovelistClear                   CJ_SchmonRemovelistClear
#define SchmonCJThreadPoolClean                CJ_SchmonCJThreadPoolClean
#define SchmonEntry                             CJ_SchmonEntry
#define SchmonStart                             CJ_SchmonStart

/* thread */
#define ThreadSleep                              CJ_ThreadSleep
#define ThreadWakeIfSleeping                     CJ_ThreadWakeIfSleeping
#define ThreadCoreBind                           CJ_ThreadCoreBind
#define ThreadPreemptFlagInit                    CJ_ThreadPreemptFlagInit
#define ThreadEntry                              CJ_ThreadEntry
#define ThreadOsnew                              CJ_ThreadOsNew
#define ThreadCreate                             CJ_ThreadCreate
#define ThreadFromSchedule                       CJ_ThreadFromSchedule
#define ThreadAlloc                              CJ_ThreadAlloc
#define ThreadAllocBindProcessor                 CJ_ThreadAllocBindProcessor
#define ThreadStop                               CJ_ThreadStop
#define ThreadBindProcessor                      CJ_ThreadBindProcessor

/* cjthread_context.S */
#define CJThreadMcall                           CJ_CJThreadMcall
#define CJThreadMcallNosave                     CJ_CJThreadMcallNosave
#define CJThreadExecute                         CJ_CJThreadExecute
#define CJThreadContextInit                     CJ_CJThreadContextInit
#define CJThreadContextGet                      CJ_CJThreadContextGet
#define CJThreadContextSet                      CJ_CJThreadContextSet

/* timer */
#define g_timerNum                               CJ_GTimerNum

#define TimerDeadlineCheck                       CJ_TimerDeadlineCheck
#define TimerShiftUp                             CJ_TimerShiftUp
#define TimerShiftDown                           CJ_TimerShiftDown
#define TimerDoAdd                               CJ_TimerDoAdd
#define TimerHeapInit                            CJ_TimerHeapInit
#define TimerUpdateTimer0Ddl                     CJ_TimerUpdateTimer0Ddl
#define TimerRemove                              CJ_TimerRemove
#define TimerHeapTopAdjust                       CJ_TimerHeapTopAdjust
#define TimerAdd                                 CJ_TimerAdd
#define TimerStopAheadStateAdjust                CJ_TimerStopAheadStateAdjust
#define TimerStopStateAdjust                     CJ_TimerStopStateAdjust
#define TimerStop                                CJ_TimerStop
#define TimerResetDoChange                       CJ_TimerResetDoChange
#define TimerResetHeapAdjust                     CJ_TimerResetHeapAdjust
#define TimerResetStatusAdjust                   CJ_TimerResetStatusAdjust
#define TimerReset                               CJ_TimerReset
#define TimerTriggerHeapStateAdjust              CJ_TimerTriggerHeapStateAdjust
#define TimerTriggerHeapAdjust                   CJ_TimerTriggerHeapAdjust
#define TimerTimer0Run                           CJ_TimerTimer0Run
#define TimerTimer0StateAdjust                   CJ_TimerTimer0StateAdjust
#define TimerTimer0StateAdjustAndRun             CJ_TimerTimer0StateAdjustAndRun
#define TimerStoppedWaitingAdjust                CJ_TimerStoppedWaitingAdjust
#define TimerStoppedStateAdjust                  CJ_TimerStoppedStateAdjust
#define TimerStoppedClear                        CJ_TimerStoppedClear
#define TimerTriggerNowCheck                     CJ_TimerTriggerNowCheck
#define TimerTrigger                             CJ_TimerTrigger
#define TimerHeapInitAndAdd                      CJ_TimerHeapInitAndAdd
#define TimerInit                                CJ_TimerInit
#define TimerNew                                 CJ_TimerNew
#define TimerSleepCoreadyCallback                CJ_TimerSleepCoreadyCallback
#define TimerSleepCoparkCallback                 CJ_TimerSleepCoparkCallback
#define TimerSleep                               CJ_TimerSleep
#define TimerTryStop                             CJ_TimerTryStop
#define TimerExit                                CJ_TimerExit
#define TimerSchmonCheck                         CJ_TimerSchmonCheck
#define TimerCheckReady                          CJ_TimerCheckReady
#define TimerNum                                 CJ_TimerNum
#define ScheduleTimerHookInit                    CJ_ScheduleTimerHookInit
#define TimerRelease                             CJ_TimerRelease
#define TimerGetHeap                             CJ_TimerGetHeap
#define TimerStoppedDoRemove                     CJ_TimerStoppedDoRemove

/* basetime */
#define CurrentNanotimeGet                       CJ_CurrentNanotimeGet
#define CurrentCPUTicks                          CJ_CurrentCPUTicks

/* waitqueue */
#define WaitqueueNew                             CJ_WaitqueueNew
#define WaitqueueParkUnlock                      CJ_WaitqueueParkUnlock
#define WaitqueueCallback                        CJ_WaitqueueCallback
#define WaitqueuePark                            CJ_WaitqueuePark
#define WaitqueueWakeOne                         CJ_WaitqueueWakeOne
#define WaitqueueWakeAll                         CJ_WaitqueueWakeAll
#define WaitqueueDelete                          CJ_WaitqueueDelete
#define WaitqueueNodeNew                         CJ_WaitqueueNodeNew
#define WaitqueuePush                            CJ_WaitqueuePush
#define WaitqueueCallbackCheck                   CJ_WaitqueueCallbackCheck
#define WaitqueueWakePreparation                 CJ_WaitqueueWakePreparation
#define WaitqueueGetWaitNum                      CJ_WaitqueueGetWaitNum

/* syscall_impl */
#define SyscallEnter                             CJ_SyscallEnter
#define SyscallFastExit                          CJ_SyscallFastExit
#define SyscallExit0                             CJ_SyscallExit0
#define SyscallExit                              CJ_SyscallExit

/* syscall_linux */
#define SyscallRead                              CJ_SyscallRead
#define SyscallWrite                             CJ_SyscallWrite
#define SyscallReadv                             CJ_SyscallReadv
#define SyscallWritev                            CJ_SyscallWritev
#define SyscallClose                             CJ_SyscallClose
#define SyscallFcntl                             CJ_SyscallFcntl
#define SyscallDup                               CJ_SyscallDup
#define SyscallDup3                              CJ_SyscallDup3
#define SyscallSleep                             CJ_SyscallSleep
#define SyscallUsleep                            CJ_SyscallUsleep
#define SyscallNanosleep                         CJ_SyscallNanoSleep
#define SyscallConnect                           CJ_SyscallConnect
#define SyscallRecv                              CJ_SyscallRecv
#define SyscallRecvfrom                          CJ_SyscallRecvFrom
#define SyscallRecvmsg                           CJ_SyscallRecvMsg
#define SyscallSend                              CJ_SyscallSend
#define SyscallSendto                            CJ_SyscallSendTo
#define SyscallSendmsg                           CJ_SyscallSendMsg
#define SyscallGetsockopt                        CJ_SyscallGetSockOpt
#define SyscallSetsockopt                        CJ_SyscallSetSockOpt
#define SyscallGetaddrinfo                       CJ_SyscallGetAddrInfo
#define SyscallGetnameinfo                       CJ_SyscallGetNameInfo
#define SyscallFreeaddrinfo                      CJ_SyscallFreeAddrInfo
#define SyscallOpen                              CJ_SyscallOpen
#define SyscallDup2                              CJ_SyscallDup2
#define SyscallPoll                              CJ_SyscallPoll
#define SyscallSelect                            CJ_SyscallSelect

#endif

/**
 * @ingroup mid
 * @brief generate module number
 * @param  x   [IN]  module number
 */
#define MID_MAKE(x) ((0x1000 + (x)) << 16)

#endif // MRT_SCHEDULE_RENAME_H
