// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_SCHEDULE_H
#define MRT_SCHEDULE_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "log.h"
#include "mid.h"
#include "cjthread_context.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

/*
 * error code range:
 * schedule.cpp  : 0x000 - 0x0FF
 * processor.cpp : 0x100 - 0x1FF
 * cjthread.cpp  : 0x200 - 0x2FF
 * thread.cpp    : 0x300 - 0x3FF
 * schdpoll.cpp  : 0x400 - 0x4FF
 */

/**
* @brief 0x10040000 The schedule parameter is invalid
*/
#define ERRNO_SCHD_ATTR_INVALID ((MID_SCHEDULE) | 0x000)

/**
* @brief 0x10040001 schedule init failed
*/
#define ERRNO_SCHD_INIT_FAILED ((MID_SCHEDULE) | 0x001)

/**
* @brief 0x10040002 alloc memory failed
*/
#define ERRNO_SCHD_MALLOC_FAILED ((MID_SCHEDULE) | 0x002)

/**
* @brief 0x10040003 not in cjthread0 context
*/
#define ERRNO_SCHD_NOT_CJTHREAD0 ((MID_SCHEDULE) | 0x003)

/**
* @brief 0x10040004 scheduler exit failed
*/
#define ERRNO_SCHD_EXIT_FAILED ((MID_SCHEDULE) | 0x004)

/**
* @brief 0x10040005 schedule uninit
*/
#define ERRNO_SCHD_UNINITED ((MID_SCHEDULE) | 0x005)

/**
* @brief 0x10040006 Multiple registrations are not allowed
*/
#define ERRNO_SCHD_HOOK_REGISTED ((MID_SCHEDULE) | 0x006)

/**
* @brief 0x10040007 the operation is not allowed because the scheduling framework is in
* the running state.
*/
#define ERRNO_SCHD_IS_RUNNING ((MID_SCHEDULE) | 0x007)

/**
* @brief 0x10040008 the parameters of hooks are invalid
*/
#define ERRNO_SCHD_HOOK_INVLAID ((MID_SCHEDULE) | 0x008)

/**
* @brief 0x10040009 the scheduling framework is invalid when the interface is used
*/
#define ERRNO_SCHD_INVALID ((MID_SCHEDULE) | 0x009)

/**
* @brief 0x1004000A operations in the non-running state
*/
#define ERRNO_SCHED_SUSPEND_WHEN_NOT_RUNNING ((MID_SCHEDULE) | 0x00A)

/**
* @brief 0x1004000B operations in the non-suspending state
*/
#define ERRNO_SCHED_RESUME_WHEN_NOT_SUSPENDING ((MID_SCHEDULE) | 0x00B)

/**
* @brief 0x10040100 failed to insert the stolen task into the local queue.
*/
#define ERRNO_SCHD_LOCAL_QUEUE_PUSH_FAILED ((MID_SCHEDULE) | 0x100)

/**
* @brief 0x10040101 invalid processor status.
*/
#define ERRNO_SCHD_PROCESSOR_STATE_INVALID ((MID_SCHEDULE) | 0x101)

/**
* @brief 0x10040102 failed to obtain the processor.
*/
#define ERRNO_SCHD_PROCESSOR_GET_FAILED ((MID_SCHEDULE) | 0x102)

/**
* @brief 0x10040200 cjthread failed to allocate space
*/
#define ERRNO_SCHD_CJTHREAD_ALLOC_FAILED ((MID_SCHEDULE) | 0x200)

/**
* @brief 0x10040201 cjthread key is full
*/
#define ERRNO_SCHD_CJTHREAD_KEY_FULL ((MID_SCHEDULE) | 0x201)

/**
* @brief 0x10040202 cjthread key is invalid
*/
#define ERRNO_SCHD_CJTHREAD_KEY_INVALID ((MID_SCHEDULE) | 0x202)

/**
* @brief 0x10040203 cjthread arg is invalid
*/
#define ERRNO_SCHD_CJTHREAD_ARG_INVALID ((MID_SCHEDULE) | 0x203)

/**
* @brief 0x10040204 cjthread state is invalid
*/
#define ERRNO_SCHD_CJTHREAD_STATE_INVALID ((MID_SCHEDULE) | 0x204)

/**
* @brief 0x10040205 cjthread is nullptr
*/
#define ERRNO_SCHD_CJTHREAD_NULL ((MID_SCHEDULE) | 0x205)

/**
* @brief 0x10040206 cjthread attr stack size is invalid
*/
#define ERRNO_SCHD_CJTHREAD_STACK_SIZE_INVALID ((MID_SCHEDULE) | 0x206)

/**
* @brief 0x10040207 cjthread is bound to thread
*/
#define ERRNO_SCHD_CJTHREAD_HAS_BEEN_BOUND_TO_THREAD ((MID_SCHEDULE) | 0x207)

/**
* @brief 0x10040208 cjthread is not bound to thread
*/
#define ERRNO_SCHD_CJTHREAD_NOT_BOUND_TO_THREAD ((MID_SCHEDULE) | 0x208)

/**
* @brief 0x10040301 cjthread failed to allocate memory
*/
#define ERRNO_SCHD_THREAD_ALLOC_FAILED ((MID_SCHEDULE) | 0x301)

/**
* @brief 0x10040302 cjthread0 failed to allocate memory
*/
#define ERRNO_SCHD_THREAD_CJTHREAD0_ALLOC_FAILED ((MID_SCHEDULE) | 0x302)

/**
* @brief 0x10040303 failed to create thread
*/
#define ERRNO_SCHD_THREAD_CREATE_FAILED ((MID_SCHEDULE) | 0x303)

/**
* @brief 0x10040304 cjthread0 is invalid
*/
#define ERRNO_SCHD_CJTHREAD0_INVALID ((MID_SCHEDULE) | 0x304)

/**
* @brief 0x10040305 processor is invalid
*/
#define ERRNO_SCHD_PROCESSOR_INVALID ((MID_SCHEDULE) | 0x305)

/**
* @brief 0x10040306 processor is not null when thread stopped
*/
#define ERRNO_SCHD_PROCESSOR_NOT_NULL ((MID_SCHEDULE) | 0x306)

/**
* @brief 0x10040307 g_cjthread is different from thread->cjthread0 when thread stopped
*/
#define ERRNO_SCHD_GCJTHREAD_NOT_EXCEPTED ((MID_SCHEDULE) | 0x307)

/**
* @brief 0x10040308 thread core binding failed
*/
#define ERRNO_SCHD_CORE_BIND_FAILED ((MID_SCHEDULE) | 0x308)

/**
* @brief 0x10040304 The callback function of OHOS is nullptr
*/
#define ERRNO_SCHD_EVENT_HANDLER_FUNC_NULL ((MID_SCHEDULE) | 0x309)

/**
* @brief 0x10040401 arg is invalid
*/
#define ERRNO_SCHD_ARG_INVALID ((MID_SCHEDULE) | 0x401)

/**
* @brief 0x10040402 preempt cnt is invalid
*/
#define ERRNO_SCHD_PREEMPT_CNT_INVALID ((MID_SCHEDULE) | 0x402)

/**
* @brief 0x10040403 stack grow failed
*/
#define ERRNO_SCHD_CJTHREAD_STACK_EXPAND_FAILED ((MID_SCHEDULE) | 0x403)

/**
* @brief 0x10040404 stackGrow cnt is invalid
*/
#define ERRNO_SCHD_STACKGROW_CNT_INVALID ((MID_SCHEDULE) | 0x404)

/**
* @brief 0x10040404 kevent failed
*/
#define ERRNO_SCHD_KEVENT_FAILED ((MID_SCHEDULE) | 0x405)

/**
* @brief 0x10040501 get env failed
*/
#define ERRNO_SCHD_GET_ENV_FAILED ((MID_SCHEDULE) | 0x501)

/**
* @brief 0x10040502 failed to operate trace dl
*/
#define ERRNO_SCHD_TRACE_DL_FAILED ((MID_SCHEDULE) | 0x502)

/**
* @brief 0x10040503 trace has already started
*/
#define ERRNO_SCHD_TRACE_ALREADY_START ((MID_SCHEDULE) | 0x503)

/**
* @brief 0x10040504 scheduler type is wrong
*/
#define ERRNO_SCHD_WRONG_TYPE ((MID_SCHEDULE) | 0x504)

/**
* @brief 0x10040505 something wrong with ui thread
*/
#define ERRNO_SCHD_UITHREAD_ERROR ((MID_SCHEDULE) | 0x505)

/**
* @brief 0x10040506 cjthread park failed
*/
#define ERRNO_SCHD_CJTHREAD_PARK_FAILED ((MID_SCHEDULE) | 0x506)

/**
* @brief The flag bit is set to - 1 when preemption is triggered.
*/
#define PREEMPT_DO_FLAG ((uintptr_t)-1)

/**
* @brief The scheduler creates the returned handle.
*/
typedef void *ScheduleHandle;

/**
* @brief Handle returned by cjthread creation.
*/
typedef void *CJThreadHandle;

/**
* @brief Function prototype of the incoming cjthread
*/
typedef void *(*CJThreadFunc)(void *, unsigned int);

/**
* @brief Function prototype of the incoming cjthread(lua2cj)
*/
typedef void *(*LuaCJThreadFunc)(void *);

/**
* @brief cjthread Local Variable Index Type
*/
typedef unsigned int CJThreadKey;

/**
* @brief Destruction Function of Local Variable of cjthread
*/
typedef void (*DestructorFunc)(void *);

/**
* @brief Callback function transferred to CJThreadPark
*/
typedef int (*ParkCallbackFunc)(void *, CJThreadHandle);

/**
* @brief Hook function for scheduling cjthread (for Cangjie GC).
* For details about the registration, see #CJThreadSchdHookRegister.
*/
typedef uintptr_t (*SchdCJThreadHookFunc)(void);

/**
* @brief Hook function when the cjthread status is switched (for Cangjie GC only).
* For details about the registration, see #CJThreadStateHookRegister.
*/
typedef uintptr_t (*SchdCJThreadStateHookFunc)(void*);

/**
* @brief Hook function for mutator destructor (dedicated to Cangjie GC).
* For details about the registration, see #CJThreadDestructorHookRegister.
*/
typedef void (*SchdDestructorHookFunc)(void *);

/**
* @brief Hook function for mutator destructor (dedicated to Cangjie GC).
* For details about the registration, see #CJThreadGetMutatorStatusHookRegister.
*/
typedef bool (*SchdMutatorStatusHookFunc)(void *);

/**
 * @brief Callback function for accessing the global cjthread control linked list
 * (dedicated for Cangjie GC)
 * @param  void* [in] Start address of the incoming cjthread stack
 * @param  void* [in] Defined transparent input parameter
 */
typedef void (*AllCJThreadListProcFunc)(void *, void *);

/**
* @brief This parameter is used to obtain the value of the tls variable in the tls dynamic
* scheme. For details about the registration, see #ScheduleGetTlsHookRegister.
*/
typedef uintptr_t *(*GetTlsHookFunc)(void);

/**
* @brief Hook type registered in the scheduling framework
*/
enum CJThreadSchdHook {
    SCHD_STOP = 0,
    SCHD_CREATE_MUTATOR = 1,
    SCHD_DESTROY_MUTATOR = 2,
    SCHD_PREEMPT_REQ = 3,
    SCHD_NEW_MUTATOR = 4,
    SCHD_HOOK_BUTT = 5
};

/**
* @brief Hook function when the cjthread state is switched
*/
enum CJThreadStateHook {
    CJTHREAD_BEFORE_PARK = 0,
    CJTHREAD_AFTER_PARK = 1,
    CJTHREAD_BEFORE_RESCHED = 2,
    CJTHREAD_AFTER_RESCHED = 3,
    CJTHREAD_STATE_HOOK_BUTT = 4
};

/**
 * @brief Maximum length of a cjthread name.
 */
#define CJTHREAD_NAME_SIZE             32

/**
 * @brief Maximum size of the cjthread stack.
 */
#define CJTHREAD_MAX_STACK_SIZE        1073741824     /* 1GB */

/**
 * @brief CJThread information structure
 */
struct CJThreadInfo {
    char name[CJTHREAD_NAME_SIZE];              /* cjthread name */
    int state;                                  /* cjthread state */
    unsigned int argSize;                       /* cjthread arg size */
    unsigned int processorId;                   /* processor id */
    unsigned int tid;                           /* thread id */
    void *argStart;                             /* arg start position */
    unsigned long sp;                           /* sp of the cjthread */
    unsigned long pc;                           /* pc of the cjthread */
    unsigned long long id;                      /* cjthread id */
    unsigned long long pthreadId;               /* pthread id */
    struct CJThreadContext context;             /* Context information recorded during the
                                                 * last dispatch of the cjthread */
};

/**
 * @brief Maximum number of bytes that can be used by the attr structure
 */
#define ATTR_MAX_SIZE 128

/**
 * @brief CJThread attribute structure
 */
struct CJThreadAttr {
    char attr[ATTR_MAX_SIZE];
};

/**
 * @brief CJThread local variable key-value pair structure, used for external parameter transfer.
 */
struct CJThreadSpecificDataInner {
    CJThreadKey key;
    void *value;
};

/**
 * @brief Create cjthread reason
 */
enum CJThreadCreateSource {
    CJTHREAD_CREATE_SOURCE_DEFAULT = 0,     /* create cjthread from general use scenarios */
    CJTHREAD_CREATE_SOURCE_SIGNAL = 1,      /* create cjthread from signal */
    CJTHREAD_CREATE_SOURCE_FINALIZER = 2,      /* create cjthread from finalizer */
};

/**
 * @brief Lua cjthread state
 */
enum LuaCJThreadState {
    LUA_CJTHREAD_INIT,
    LUA_CJTHREAD_SUSPENDING,
    LUA_CJTHREAD_RUNNING,
    LUA_CJTHREAD_DONE,
};

/**
 * @brief Schedule type
 */
enum ScheduleType {
    SCHEDULE_DEFAULT = 0,               /* default scheduler */
    SCHEDULE_UI_THREAD,                 /* scheduler for UI thread */
    SCHEDULE_FOREIGN_THREAD,            /* scheduler for foreign thread */
    SCHEDULE_EXCLUSIVE                  /* scheduler for exclusive scope */
};

/**
 * @brief schedule attribute structure
 */
struct ScheduleAttr {
    char attr[ATTR_MAX_SIZE];
};

#define TRACE_TYPE_SCHEDULE (0x0100)
#define TRACE_TYPE_RUNTIME (0x0200)
#define TRACE_TYPE_ALL (0xff00)

/**
 * @brief Trace event type. The most significant eight bits indicate the event type,
 * and the least significant eight bits are used to store the event.
 * TRACE_TYPE_CLOSE = 0x0,                    // 0000 0000 0000 0000
 * TRACE_TYPE_SCHEDULE = 0x0100,              // 0000 0001 0000 0000
 * TRACE_TYPE_RUNTIME = 0x0200,               // 0000 0010 0000 0000
 * TRACE_TYPE_ALL = 0xff00,                   // 1111 1111 0000 0000
 * */
enum TraceEvent {
    TRACE_EV_NONE = 0x0000,                   // 0000 0000 0000 0000 undefined event
    TRACE_EV_BATCH = 0x0301,                  // 0000 0011 0000 0001 traceBuf batch processing [pid, timestamp]
    TRACE_EV_FREQUENCY = 0x0302,              // 0000 0011 0000 0010 CPU clock frequency [frequency (ticks per second)]
    // 0000 0011 0000 0011 call stack event [stack id, number of PCs,array of {PC,func string ID,file string ID,line}]
    TRACE_EV_STACK = 0x0303,
    TRACE_EV_STRING = 0x0304,                 // 0000 0011 0000 0100 string event [StringId, length, string]
    TRACE_EV_PROC_WAKE = 0x0105,              // 0000 0001 0000 0101 processor wake [timestamp, threadId]
    TRACE_EV_PROC_STOP = 0x0106,              // 0000 0001 0000 0110 processor sleep [timestamp]
    TRACE_EV_CJTHREAD_CREATE = 0x0107,        // 0000 0001 0000 0111 cjthread create [timestamp, CJThreadId, stackId]
    TRACE_EV_CJTHREAD_START = 0x0108,         // 0000 0001 0000 1000 cjthread execute start [timestamp, CJThreadId]
    TRACE_EV_CJTHREAD_END = 0x0109,           // 0000 0001 0000 1001 cjthread execute end [timestamp, stackId]
    TRACE_EV_CJTHREAD_RESCHED = 0x010A,       // 0000 0001 0000 1010 cjthread reschedule [timestamp, stackId]
    TRACE_EV_CJTHREAD_SLEEP = 0x010B,         // 0000 0001 0000 1011 cjthread sleep [timestamp, stackId]
    TRACE_EV_CJTHREAD_BLOCK = 0x010C,         // 0000 0001 0000 1100 cjthread block [timestamp, stackId]
    TRACE_EV_CJTHREAD_UNBLOCK = 0x010D,       // 0000 0001 0000 1101 cjthread unblock [timestamp, CJThreadId, stackId]
    TRACE_EV_CJTHREAD_BLOCK_SYNC = 0x010E,    // 0000 0001 0000 1110 cjthread block fro sync [timestamp, stackId]
    TRACE_EV_CJTHREAD_BLOCK_NET = 0x010F,     // 0000 0001 0000 1111 cjthread block for net [timestamp, stackId]
    TRACE_EV_CJTHREAD_SYSCALL = 0x0110,       // 0000 0001 0001 0000 cjthread syscall start [timestamp, stackId]
    TRACE_EV_CJTHREAD_SYSEXIT = 0x0111,       // 0000 0001 0001 0001 cjthread syscall end [timestamp, CJThreadId]
    TRACE_EV_GC_START = 0x0212,               // 0000 0010 0001 0010 GC start [timestamp]
    TRACE_EV_GC_DONE = 0x0213,                // 0000 0010 0001 0011 GC end [timestamp]
    TRACE_EV_COUNT = 0x0014,                  // 0000 0000 0001 0100 count evnet
};

enum TraceStackFrames {
    TRACE_STACK_0,
    TRACE_STACK_1,
    TRACE_STACK_2,
    TRACE_STACK_3,
    TRACE_STACK_4,
    TRACE_STACK_5,
    TRACE_STACK_6,
    TRACE_STACK_7,
    TRACE_STACK_8,
    TRACE_STACK_9,
    TRACE_STACK_10,
};

enum SpecialStackId {
    UNKNOWN = 1,
    CJTHREAD_EXIT = 2,
    CJTHREAD_RESCHED = 3,
    CJTHREAD_NET_BLOCK = 4,
    CJTHREAD_NET_UNBLOCK = 5,
    CJTHREAD_UNBLOCK = 6,
    OTHERS,
};

enum TraceArgNum {
    TRACE_ARGS_0,
    TRACE_ARGS_1,
    TRACE_ARGS_2,
};

/**
 * @brief Type of callback function for SchdPoll
 */
typedef unsigned int (*SchdpollNotifyFunc)(int fd, int event, void *arg);

/**
 * @brief Handle obtained by registering FD with SchdPoll
 */
typedef void* PollHandle;

/**
 * @brief Function use for posting task to event handler system.
 */
typedef bool (*PostTaskFunc)(void* taskFunc);

/**
 * @brief Function use for checking for higher priority tasks.
 */
typedef bool (*HasHigherPriorityTaskFunc)();

/* Update designate stackInfo */
typedef void(*UpdateStackInfoFunc)(unsigned long long, void*, unsigned int);

/**
 * @brief Register PostTask function and HasHigherPriorityTask function of event handler
 * to global scheduler manager.
 * @param pFunc  [IN] The PostTask function
 * @param hFunc  [IN] The HasHigherPriorityTask function
 */
void RegisterEventHandlerCallbacks(PostTaskFunc pFunc, HasHigherPriorityTaskFunc hFunc);

/**
 * @brief Register UpdateStackInfo Func to global scheduler manager.
 * @param uFunc  [IN] The UpdateStackInfoFunc function
 */
void CJRegisterStackInfoCallbacks(UpdateStackInfoFunc uFunc);

/**
 * @brief Register UIThread arkVM to global scheduler manager.
 * @param vm  [IN] The arkVM in UIThread
 */
void CJRegisterArkVMInRuntime(unsigned long long vm);

/**
* @brief Default cjthread parameter assignment.
* @par Description: Assign a default value to the attrUser cjthread attribute.
* @attention
* Before performing the #CJThreadAttr operation, call this API to initialize related structures.
* @param attrUser    [IN] cjthread attribute structure.
 */
void CJThreadAttrInit(struct CJThreadAttr *attrUser);

/**
 * @brief set cjthread name
 * @param  attrUser   [IN]  cjthread attr
 * @param  name       [IN]  name
 * @retval 0 or error code
 */
int CJThreadAttrNameSet(struct CJThreadAttr *attrUser, const char *name);

/**
 * @brief set cjthread stack size
 * @par set cjthread stack size. If size is 0, use default stack size
 * @param  attrUser   [IN]  cjthread attr
 * @param  size       [IN]  stack size
 */
void CJThreadAttrStackSizeSet(struct CJThreadAttr *attrUser, unsigned int size);

/**
 * @brief set cjthread attr from C side
 * @param  attrUser   [IN]  cjthread attr
 * @param  flag       [IN]  true indicates that the cj function needs to be invoked
 */
void CJThreadAttrCjFromCSet(struct CJThreadAttr *attrUser, bool flag);

/**
 * @brief Sets the key pair value of the cjthread local variable.
 * @par Description: Sets the key pair value of the cjthread local variable (local_data)
 * based on the input key pair number and key pair value.
 * @param attrUser    [IN] cjthread attribute structure.
 * @param num         [IN] Number of key pairs.
 * @param data        [IN] Key pair-value structure array.
 * @retval If the setting is successful, 0 is returned. If the quantity is abnormal,
 * -1 is returned. If the memset_s fails, error is returned.
 */
int CJThreadAttrSpecificSet(struct CJThreadAttr *attrUser, unsigned int num, struct CJThreadSpecificDataInner* data);

/**
 * @brief Create a exclusive cjthread. This interface must be invoked in the cjthread context.
 * @par Description: Creates a cjthread and returns its handle. created cjthread will not enters
 * the run schedule queue, but bind to it's os thread
  * @param func              [IN] User-defined cjthread execution function.
 * @param argStart          [IN] Parameter start address of the cjthread function.
 * @param argSize           [IN] Parameter length of the cjthread function.
 * @retval If the operation is successful, the handle of the cjthread is returned.
 * NULL indicates that the cjthread fails to be created.
 */
CJThreadHandle ExclusiveCJThreadNew(CJThreadFunc func,
                                    const void *argStart, unsigned int argSize);

/**
 * @brief Create a cjthread. This interface must be invoked in the cjthread context.
 * @par Description: Creates a cjthread and returns its handle. The size of the cjthread
 * stack is automatically aligned to the page size. When the scheduler is started, the
 * cjthread automatically enters the run queue.
 * @attention
 * The maximum size of the cjthread stack is 1 GB. If the size set in attr exceeds 1 GB,
 * an error is reported and NULL is returned.
 * @param targetSchedule    [IN] Scheduler to which the cjthread belongs.
 * @param attrUser          [IN] Startup attribute structure of the cjthread,
 * including the cjthread name and stack size. If NULL is input, the default parameter is
 * used. For details, see #CJThreadAttrInit.
 * @param func              [IN] User-defined cjthread execution function.
 * @param argStart          [IN] Parameter start address of the cjthread function.
 * @param argSize           [IN] Parameter length of the cjthread function.
 * @retval If the operation is successful, the handle of the cjthread is returned.
 * NULL indicates that the cjthread fails to be created.
 */
CJThreadHandle CJThreadNew(ScheduleHandle schedule, const struct CJThreadAttr *attrUser,
                           CJThreadFunc func, const void *argStart, unsigned int argSize,
                           CJThreadCreateSource createSource = CJTHREAD_CREATE_SOURCE_DEFAULT);

/**
 * @brief Create a cjthread from outside the scheduling framework to the scheduler.
 * This interface can be invoked from outside the scheduling framework.
 * @par Description: Creates a cjthread and returns its handle. The size of the cjthread
 * stack is automatically aligned to the page size. When the scheduler is started, the
 * cjthread automatically enters the run queue.
 * @attention
 * The maximum size of the cjthread stack is 1 GB. If the size set in attr exceeds 1 GB,
 * an error is reported and NULL is returned.
 * @param targetSchedule    [IN] Scheduler to which the cjthread belongs.
 * @param attr              [IN] Startup attribute structure of the cjthread, including the
 * cjthread name and stack size.
 * @param func              [IN] User-defined cjthread execution function.
 * @param argStart          [IN] Parameter start address of the cjthread function.
 * @param argSize           [IN] Parameter length of the cjthread function.
 * @retval If the operation is successful, the handle of the cjthread is returned.
 * NULL indicates that the cjthread fails to be created.
 */
CJThreadHandle CJThreadNewToSchedule(ScheduleHandle schedule, const struct CJThreadAttr *attr,
                                     CJThreadFunc func, const void *argStart, unsigned int argSize,
                                     CJThreadCreateSource createSource = CJTHREAD_CREATE_SOURCE_DEFAULT);

/**
 * @brief Creates a cjthread to the default scheduler. This interface can be invoked from
 * outside the scheduling framework.
 * @par Description: Creates a cjthread and returns its handle. The size of the cjthread
 * stack is automatically aligned to the page size. When the scheduler is started, the
 * cjthread automatically enters the run queue.
 * @attention
 * 1. The maximum size of the cjthread stack is 1 GB. If the size set in attr exceeds 1 GB,
 * an error is reported and NULL is returned.
 * @param attr     [IN] Startup attribute structure of the cjthread, including the cjthread
 * name and stack size.
 * @param func     [IN] User-defined cjthread execution function.
 * @param argStart [IN] Parameter start address of the cjthread function.
 * @param argSize  [IN] Parameter length of the cjthread function.
 * @retval If the operation is successful, the handle of the cjthread is returned.
 * NULL indicates that the cjthread fails to be created.
 */
CJThreadHandle CJThreadNewToDefault(const struct CJThreadAttr *attr, CJThreadFunc func,
                                    const void *argStart, unsigned int argSize);

/**
 * @brief Preempts and puts the current cjthread back to the running queue.
 * @par Description: used for signal preemption. Stack overflow is not included, and the
 * preemption flag is not checked.
 */
void CJThreadPreemptResched(void);

/**
 * @brief Add the cjthread to the running queue.
 * @par Add the specified cjthread to the running queue under the processor. If the cjthread
 * is not in the context, add the cjthread to the global running queue.
 * @param readyCJThread    [IN] cjthread to be added to the running queue.
 */
void CJThreadReady(CJThreadHandle readyCJThread);

/**
 * @brief Make the current thread wait
 * @par Description: Park the current thread
 */
void CJThreadWait(void);

/**
 * @brief Park the current thread and schedule another one
 * @par Description: The current thread is parked and the next thread is scheduled for execution.
 * These operations are done one after the other.
 * @param readyCJThread    [IN] cjthread to to be added to the running queue.
 */
void CJThreadResumeAndWait(CJThreadHandle readyCJThread);

/**
 * @brief Obtain the ID of the current cjthread.
 * @par Description: Obtain the ID of the current cjthread. The ID is greater than or equal
 * to 1 and less than U64_MAX.
 * @attention must be called in cjthread context
 * @retval Returns the ID of the current cjthread. Returns 0 if not in cjthread context
 */
unsigned long long int CJThreadId(void);

/**
 * @brief Obtain the handle of the current cjthread.
 * @par Description: Obtains the handle of the current cjthread.
 * @attention must be called in cjthread context
 * @retval Returns the handle of the current cjthread. Returns NULL if not in cjthread context
 */
CJThreadHandle CJThreadGetHandle(void);

/**
 * @brief Obtain the ID of a specified cjthread.
 * @par Description: Obtain the ID of a specified cjthread. The ID is greater than or equal
 * to 1 and less than U64_MAX.
 * @attention: Ensure that the cjthread corresponding to the handle is still being executed.
 * @param handle    [IN] Handle of the cjthread.
 * @retval Returns the ID of the cjthread.
 */
unsigned long long int CJThreadGetId(CJThreadHandle handle);

// This interface cannot be exposed externally.
void CJThreadSetId(struct CJThread *cjthread, unsigned long long id);

/**
 * @brief Set the name of the cjthread.
 * @par Description: Set the name of the cjthread. When the length of the input name exceeds
 * the limit, only the prefix of the name is truncated.
 * @attention: Ensure that the cjthread corresponding to the handle is still being executed.
 * @param handle [IN] Handle of the cjthread.
 * @param name   [IN] cjthread name.
 * @param len    [IN] Length of the cjthread name.
 */
void CJThreadSetName(CJThreadHandle handle, const char *name, size_t len);

/**
 * @brief Obtain the name of the current cjthread.
 * @par Description: Obtains the name of the current cjthread.
 * @attention must be called in cjthread context
 * @retval Returns the name of the current cjthread. Returns 0 if not in cjthread context
 */
char* CJThreadGetName(void* cjthreadPtr);

/**
 * @brief Obtain the state of the current cjthread.
 * @par Description: Obtains the state of the current cjthread.
 * @attention must be called in cjthread context
 * @retval Returns the state of the current cjthread. Returns -1 if not in cjthread context
 */
int CJThreadGetState(void* cjthreadPtr);

/**
 * @brief Default scheduler parameter assignment.
 * @par Description: Assign a default value to the attrUser scheduler attribute.(The default
 * stack size is used. The number of processors is the same as the number of cores. Stack
 * protection is disabled and stack capacity expansion is enabled.)
 * @param usrAttr [IN] Scheduler attribute.
 * @retval If the operation is successful, 0 is returned. If the operation fails, an error
 * code is returned.
 */
int ScheduleAttrInit(struct ScheduleAttr *usrAttr);

/**
 * @brief Initialize scheduler attributes with the specified concurrency parameters.
 * @param usrAttr      [IN] Scheduler attributes to be initialized.
 * @param param        [IN] Concurrency parameters, including the default thread stack size
 * (thStackSize, in KB), the default cjthread stack size (coStackSize, in KB), and the number
 * of processors (processorNum).
 * @param stackProtect [IN] Whether to enable stack protection.
 * @param stackGrow    [IN] Whether to enable stack capacity expansion.
 * @retval If the operation is successful, 0 is returned. If the operation fails, an error
 * code is returned.
 */
int ScheduleAttrInitWithParams(struct ScheduleAttr *usrAttr, const ConcurrencyParam param,
                               bool stackProtect, bool stackGrow);

/**
 * @brief Set scheduler attributes and default cjthread stack size
 * @param  usrAttr          [IN]  scheduler attributes
 * @param  size             [IN]  cjthread stack size
 * @retval 0 or error code
 */
int ScheduleAttrCostackSizeSet(struct ScheduleAttr *usrAttr, unsigned int size);

/**
 * @brief Set the scheduler attribute, that is, the default thread stack size.
 * @attention 1. The value of size must be greater than or equal to the value of
 * PTHREAD_STACK_MIN. 16 x 1024 bytes for x86 and 128 x 1024 bytes for ARM.
 * 2. The size must be an integer multiple of the system page size.
 * If the preceding conditions are not met, the default thread stack size is used to create
 * a thread.
 * @param usrAttr [IN] Scheduler attribute.
 * @param size    [IN] Stack size
 * @retval 0 or error code
 */
int ScheduleAttrThstackSizeSet(struct ScheduleAttr *usrAttr, unsigned int size);

/**
 * @brief Set the scheduler attribute, that is, the number of processors.
 * @param usrAttr [IN] Scheduler attribute.
 * @param num     [IN] Quantity
 * @retval 0 or error code
 */
int ScheduleAttrProcessorNumSet(struct ScheduleAttr *usrAttr, unsigned int num);

/**
 * @brief Set the scheduler attribute and whether to enable stack protection.
 * @param usrAttr [IN] Scheduler attribute.
 * @param open    [IN] Whether to enable
 * @retval 0 or error code
 */
int ScheduleAttrStackProtectSet(struct ScheduleAttr *usrAttr, bool open);

/**
 * @brief Set the scheduler attribute and whether to enable stack scaling.
 * @param usrAttr [IN] Scheduler attribute.
 * @param open    [IN] Whether to enable
 * @retval 0 or error code
 */
int ScheduleAttrStackGrowSet(struct ScheduleAttr *usrAttr, bool open);

/**
 * @brief Initialize a scheduler.
 * @par Description: Creates a scheduler instance and initializes the cjthread control block,
 * thread control block, and processor group of the scheduler.
 * @attention supports multiple schedulers. Each time ScheduleNew changes the thread local
 * variable g_schedule. Therefore, this method needs to be invoked in an independent thread.
 * Only one default scheduler can be created. Other schedulers can create multiple instances
 * only when the default scheduler is enabled.
 * @param scheduleType    [IN] Create a specified scheduler.
 * @param userAttr        [IN] Attribute structure for creating a new scheduler. If NULL is
 * input, the default attribute is used. For details, see #ScheduleAttrInit.
 * @retval Pointer to the scheduler
 */
ScheduleHandle ScheduleNew(ScheduleType scheduleType, const struct ScheduleAttr *userAttr);

/**
 * @brief Initialize schedule netpoll.
 */
int ScheduleNetpollInit();

/**
* @brief Start the scheduler.
* @par Description: Activate the state of the scheduler and find a dispatchable cjthread
 * for context switching.
 * @retval 0 or error code
 */
int ScheduleStart(void);

/**
 * @brief Start the scheduler without sleeping
 * @attention This function needs to be executed on the thread where the scheduler is created,
 * and this method is used only for non-default schedulers.
 * @par Description: Activate the scheduler status, search for a dispatchable cjthread for
 * context switching, and return immediately when no dispatchable cjthread exists or the
 * startup time exceeds timeout.
 * @param timeout     [IN] Timeout interval
 * @retval The scheduler returns 0 after the execution is complete. If the execution fails,
 * an error code is returned.
 */
int ScheduleStartNoWait(unsigned long long timeout);

/**
 * @brief Key for creating a cjthread variable, which can be transferred to the destruction function.
 * @par Description: Creates the key of a cjthread variable. Destructor is the destruction
 * function of the variable. The destruction function is invoked when the cjthread ends.
 * @attention If NULL is input to the destruction function, the user manages the memory and
 * is responsible for free of the local variables of the cjthread. If the destroy function
 * is passed, the cjthread is responsible for destroying the local variables of the cjthread.
 * When the association ends, if the local variable of the association is stored as a non-null
 * pointer and the registered function is not null, the destruction function is called. Be careful
 * not to mix up. Do not let the cjthread free again after the user frees the memory.
 * @param key         [OUT] Obtained thread local variable key
 * @param destructor  [IN] Destructor
 * @retval 0 or error code
 */
int CJThreadKeyCreateInner(CJThreadKey *key, DestructorFunc destructor);

/**
 * @brief Sets the cjthread variable.
 * @attention key must be the value after CJThreadKeyCreateInner is initialized.
 * Uninitialized keys are not allowed.
 * @param key      [IN] Local variable key of the thread to be set
 * @param value    [IN] Local variable value of the thread to be set
 * @retval 0 or error code
 */
int CJThreadSetspecificInner(CJThreadKey key, void *value);

/**
 * @brief Obtain the cjthread variable of the corresponding key value.
 * @attention key must be the value after CJThreadKeyCreateInner is initialized.
 * Uninitialized keys are not allowed.
 * @param key    [IN] Expected thread local variable key
 * @retval If the operation is successful, the pointer to the corresponding data is returned.
 * If the operation fails, the null pointer is returned.
 */
void *CJThreadGetspecificInner(CJThreadKey key);

/**
 * @brief Register the hook triggered when the cjthread is scheduled.
 * @par Description: Hook triggered when the dispatching cjthread is registered
 * type indicates the type of the registered hook. For details, see the definition of the
 * CJThreadSchdHook enumeration. The hooks registered with the scheduling framework are
 * invoked at different times.
 * @attention This interface must be invoked after ScheduleNew and before ScheduleStart.
 * @param func     [IN] Callback function
 * @param type     [IN] Enumeration corresponding to the trigger position
 * @retval 0 or error code
 */
int CJThreadSchdHookRegister(SchdCJThreadHookFunc func, CJThreadSchdHook type);

/**
 * @brief Register the hook triggered when the cjthread status is switched.
 * @par Description: Register the hook triggered when the cjthread state is switched.
 * type: type of the registered hook. For details, see the definition of the
 * CJThreadStateHook enumeration. The hooks registered with the scheduling framework are
 * invoked at different times.
 * @attention This interface must be invoked after ScheduleNew and before ScheduleStart.
 * @param func    [IN] Callback function
 * @param type    [IN] Enumeration corresponding to the trigger position
 * @retval 0 or error code
 */
int CJThreadStateHookRegister(SchdCJThreadStateHookFunc func, CJThreadStateHook type);

#ifdef __OHOS__
/**
 * @brief Get bottom of physical thread stack
 * @attention Only use in OHOS, and only for the spawn(Main) to Native func
 * @retval success for bottom of stack, 0 for fail or not in OHOS
 */
unsigned long long GetThreadStackTop();

/**
 * @brief Get last bottom of physical thread stack from threadStackTopList
 * @attention Only use in OHOS, and only for the spawn(Main) to Native func
 * @retval success for bottom of stack, 0 for fail or not in OHOS
 */
unsigned long long GetUIThreadStackTop();

/**
  * @brief Add bottom of physical thread stack in threadStackTopList
  * @attention Only use in OHOS, and only for the spawn(Main) to Native func
  * @param  stackTop  thread stack top address
  */
void PushUIThreadStackTop(unsigned long long stackTop);

/**
 * @brief Remove the last bottom of physical thread stack from threadStackTopList.
 * @attention Only use in OHOS, and only for the spawn(Main) to Native func
 */
void PopUIThreadStackTop();
#endif

/**
 * @brief Stop the scheduling framework.
 * @par Description: This API stops the scheduling framework. This interface cannot be
 * invoked outside the scheduling framework.
 * @attention This interface depends on the preemption mechanism and can be used only when
 * the scheduling framework can preemption. This interface is a blocking interface and is
 * blocked until all threads stop working. The blocking time does not exceed the time for
 * triggering a preemption. This interface suspends all working threads but does not exit.
 * The thread exits with the process. Do not invoke this method in a cjthread of a
 * non-default scheduler to close the scheduler to which the cjthread belongs.
 * @param scheduleHandle    [IN] Handle of the scheduler to be paused
 */
void ScheduleStop(ScheduleHandle scheduleHandle);

/**
 * @brief The scheduling framework stops.
 * @par Description: This API stops the scheduling framework. This interface can be invoked
 * outside the scheduling framework.
 * @attention This interface depends on the preemption mechanism and can be used only when
 * preemption is enabled in the scheduling framework. This interface is a blocking interface.
 * The interface is blocked until all threads stop working. The blocking time does not exceed
 * the time when a preemption is triggered. This interface suspends all working threads but
 * does not exit. The thread exits with the process.
 * @param scheduleHandle    [IN] Handle of the scheduler to be paused
 * @retval 0 or error code
 */
int ScheduleStopOutside(ScheduleHandle scheduleHandle);

/**
 * @brief Free a non-default scheduler.
 * @param scheduleHandle    [IN] Handle of the scheduler to be freed
 */
void ScheduleNonDefaultFree(ScheduleHandle scheduleHandle);

/**
 * @brief Traverse the global cjthread control list and call the input function hook
 * (specific function for Cangjie GC).
 * @par Description: Traverse the global cjthread control list and call the function hook
 * of the input parameter for the cjthread whose status is not CJTHREAD_IDLE and input
 * parameter address is not NULL.
 * @param visitor    [IN] Function hook transferred by the user
 * @param handle     [IN] User-defined handle
 */
void ScheduleAllCJThreadVisit(AllCJThreadListProcFunc visitor, void *handle);

/**
 * @brief Traverse the global cjthread control list and call the input function hook
 * (specific function for Cangjie GC).
 * @par Description: Traverse the global cjthread control list and invoke the function hook
 * of the input parameter for the cjthread whose status is not CJTHREAD_IDLE and mutator is
 * not NULL.
 * @param visitor    [IN] Function hook transferred by the user
 * @param handle     [IN] User-defined handle
 */
void ScheduleAllCJThreadVisitMutator(AllCJThreadListProcFunc visitor, void *handle);

/**
 * @brief Preemption detection function
 * @par Description: The preemption detection function is provided to check whether the
 * current cjthread can be preempted. If the preemption conditions are met, preemption occurs.
 * This interface is provided for the Cangjie side to implement collaborative preemption.
 * This interface is invoked at the detection point in the function header and loop.
 * @attention This function must be called in the context of the cjthread.
 */
void SchedulePreemptCheck(void);

/**
 * @brief Modify the reserved stack size.
 * @par Description: Modify the size of the reserved stack. The default size of the reserved
 * stack is 4 KB. You can use this function to increase the size. The unit is byte.
 * This interface needs to be invoked before ScheduleNew.
 * @retval 0 or error code
 */
int CJThreadStackReversedSet(uintptr_t size);

/**
 * @brief Obtain the reserved stack size.
 * @par Description: Obtains the current reserved stack size, which is used to calculate
 * the new stack size during stack expansion. The default reserved stack size is 4 KB.
 * @retval Reserved stack size
 */
uintptr_t CJThreadStackReversedGet(void);

/**
 * @brief Extend the stack boundary of the cjthread.
 * @par Description: This function is used for the stack overflow processing mechanism of
 * the warehouse. After a stack overflow exception occurs, the stack boundary needs to be
 * extended to the processing function.
 */
void CJThreadStackGuardExpand(void);

/**
 * @brief Restore the stack boundary of the cjthread.
 * @par Description: This function is used for the exception try catch mechanism of Cangjie.
 * After the stack overflow exception is caught, the stack boundary needs to be restored.
 */
void CJThreadStackGuardRecover(void);

#ifndef MRT_MACOS

/**
 * @brief Listen to the fd and invoke the callback function when an event occurs.
 * @param fd     [IN] Listened FD
 * @param events [IN] Listened events
 * @param func   [IN] Callback function
 * @param arg    [IN] Parameter of the callback function
 * @retval If the operation is successful, PollHandle is returned. If the operation fails,
 * NULL is returned.
 */
PollHandle SchdpollNotifyAdd(int fd, int events, SchdpollNotifyFunc func, void *arg);

/**
 * @ingroup schdpoll
 * @brief Cancel the listening on the FD.
 * @param fd     [IN] Listened FD
 * @param pd     [IN] fd Handle registered using #SchdpollNotifyAdd
 * @retval 0 or error code
 */
int SchdpollNotifyDel(int fd, PollHandle pd);

#endif

/**
 * @brief Check whether there are any cjthreads in the scheduling framework.
 * @param scheduleHandle     [IN] Handle of the scheduler
 * @retval If a cjthread exists, true is returned. Otherwise, false is returned.
 */
bool ScheduleAnyCJThread(ScheduleHandle scheduleHandle);

/**
 * @brief Check whether there is any cjthread or timer in the scheduling framework.
 * @par Description: This command is used to check whether any cjthread or timer exists
 * in the scheduling framework. If the cjthread or timer is suspended, the cjthread control
 * block is reclaimed.
 * @retval If the value exists, true is returned. Otherwise, false is returned.
 */
bool ScheduleAnyCJThreadOrTimer(void);

/**
 * @brief Suspend the scheduler. Created cjthreads continue to run to end, but new
 * cjthreads are not allowed
 * @retval 0 or -1
 */
int ScheduleSuspend(void);

/**
 * @brief Resume the scheduler. Allow cjthread creation to continue
 * @retval 0 or -1
 */
int ScheduleResume(void);

/**
 * @brief Bind a cjthread to a thread. In this case, the operation cjthread can only run on
 * this thread, and the corresponding thread can only run this cjthread.
 * @retval 0 or -1
 */
int CJBindOSThread(void);

/**
 * @brief Unbind a cjthread from a thread. In this case, the operation cjthread can run on
 * any thread, and the corresponding thread can run any cjthread.
 * @retval 0 or -1
 */
int CJUnbindOSThread(void);

/**
 * @brief Obtains the stack guard of the current cjthread.
 * @retval If the operation fails, NULL is returned. If the operation succeeds, the pointer
 * of the stack guard is returned.
 */
void *CJThreadStackGuardGet(void);

/**
 * @brief Gets the stack addr of the current cjthread. Used for Cangjie to process native
 * stack out-of-bounds check.
 * @retval If the operation fails, NULL is returned. If the operation succeeds, the pointer
 * of stack addr is returned.
 */
void *CJThreadStackAddrGet(void);
 
/**
 * @brief Obtain the stackBaseAddr of the current cjthread, that is, the initial rsp of the
 * cjthread. Used for capacity expansion of the warehouse stack.
 * @attention The relationship between rbp and stackBaseAddr of the first frame of the cjthread:
 * @attention x86_64: rbp = stackBaseAddr - 16
 * @attention arm64: x29 = stackBaseAddr - 16
 * @attention Windows: rbp = stackBaseAddr - 48
 * @retval If the operation fails, NULL is returned. If the operation succeeds, the pointer
 * of stackBaseAddr is returned.
 */
void *CJThreadStackBaseAddrGet(void);
 
/**
 * @brief Get the stackSize of the current cjthread. It is used for the expansion of the
 * warehouse stack to release the old stack.
 * @retval If the request is successful, the value of stackSize is returned. If the request
 * fails, -1 is returned.
 */
size_t CJThreadStackSizeGet(void);

/**
 * @brief Obtains the stack addr of the target cjthread. If the parameter is empty, obtains
 * the stack addr of the current cjthread.
 * @retval If the operation fails, NULL is returned. If the operation succeeds, the pointer
 * of stack addr is returned.
 */
void *CJThreadStackAddrGetByCJThrd(struct CJThread *cjthread);

/**
 * @brief Obtain the stackBaseAddr of the target cjthread. If the parameter is empty, obtain
 * the stackBaseAddr of the current cjthread.
 * @attention The relationship between rbp and stackBaseAddr of the first frame of the cjthread is:
 * @attention x86_64: rbp = stackBaseAddr - 16
 * @attention arm64: x29 = stackBaseAddr - 16
 * @attention Windows: rbp = stackBaseAddr - 48
 * @retval If the operation fails, NULL is returned. If the operation succeeds, the pointer
 * of stackBaseAddr is returned.
 */
void *CJThreadStackBaseAddrGetByCJThrd(struct CJThread *cjthread);

/**
 * @brief Obtains the stackSize of the target cjthread. If the parameter is empty, obtains
 * the stackSize of the current cjthread.
 * @retval If the request is successful, the value of stackSize is returned. If the request
 * fails, -1 is returned.
 */
size_t CJThreadStackSizeGetByCJThrd(struct CJThread *cjthread);

/**
 * @brief After this interface is invoked, the current cjthread does not preempt.
 * @retval 0 or error code
 */
int CJThreadPreemptOffCntAdd(void);

/**
 * @brief After this interface is invoked, the current cjtrhead allows preemption.
 * @retval 0 or error code
 */
int CJThreadPreemptOffCntSub(void);

/**
 * @brief Register the hook function for releasing cjthread control blocks.
 * @par Register the hook triggered when scheduling a cjthread. This interface must be
 * invoked after ScheduleNew and before ScheduleStart.
 * @retval 0 or error code
 */
int CJThreadDestructorHookRegister(SchdDestructorHookFunc func);

/**
 * @brief Register the hook function for obtaining the mutator status.
 * @par Register the hook triggered when scheduling a cjthread. This interface must be
 * invoked after ScheduleNew and before ScheduleStart.
 * @retval 0 or error code
 */
int CJThreadGetMutatorStatusHookRegister(SchdMutatorStatusHookFunc func);

/**
 * @brief Get the mutator of the current cjthread.
 * @par Get the mutator of the current cjthread.
 * @retval Mutator pointer
 */
void *CJThreadGetMutator(void);

/**
 * @brief get scheduler of current cjthread
 * @retval return mutator for success，NULL for fail.
 */
void* GetCJThreadScheduler();

/**
 * @brief rebind cjthread and the cjthread0 of scheduler.
 * @param cjthread: the cjthread that will be rebinded.
 */
void RebindCJThread(void* cjthread);

/**
 * @brief set scheduler state
 */
void SetSchedulerState(int state);

/**
 * @brief Set the mutator of the current cjthread
 * @par Set the mutator of the current cjthread
 * @attention The set mutator is cleared only when the cjthread is released.
 * @retval 0 or error code
 */
int CJThreadSetMutator(void *mutator);

/**
 * @brief Check whether the scheduler is running.
 * @param  scheduleHandle       [IN] schedule handle
 * @retval True is returned for the running status. Otherwise, false is returned.
 */
bool ScheduleIsRunning(ScheduleHandle scheduleHandle);

/**
 * @brief Use the tls dynamic scheme to obtain the value of the tls variable.
 * @par Register the hook for obtaining the TLS offset. This interface must be invoked
 * before ScheduleNew.
 * @retval 0 or error code
 */
int ScheduleGetTlsHookRegister(GetTlsHookFunc func);

/**
 * @brief Set the owning scheduler for the current thread.
 * @param  schedule   [IN] schedule
 * @retval 0 or error code
 */
void ScheduleSetToCurrentThread(ScheduleHandle schedule);

/**
 * @brief Create a cjthread. After the cjthread is created, it can be started only after
 * #CJThreadResume. Used only for lua2cj.
 * @attention The return value can be used only for the lua2cj interface. The returned
 * CJThreadHandle is in the
 * When the process ends, call #CJThreadDestroy to manually release the call.
 * @param attrUser    [IN] Startup attribute structure of the cjthread, including the
 * cjthread name and stack size.
 * @param func        [IN] Function to be run in the subchapter.
 * @param arg         [IN] Parameter of the sub-thread running function, which is transferred
 * by reference. The second parameter of CJThreadFunc is the pointer length by default.
 * @retval cjthread
 */
CJThreadHandle CJThreadCreate(const struct CJThreadAttr *attrUser, LuaCJThreadFunc func, void *arg);

/**
 * @brief Yield the current cjthread and wakes up the main thread from #CJThreadResume.
 * Used only for lua2cj.
 * @attention can only be used for cjthreads created by the #CJThreadCreate interface.
 * It can only be called in the context of a cjthread.
 * @retval 0 or error code
 */
int CJThreadYield(void);

/**
 * @brief Wakes up a specified cjthread that is not started or suspended. and block the
 * current thread. Used only for lua2cj.
 * @attention can only be used for cjthreads created by the #CJThreadCreate interface.
 * @param cjthread [IN] Subcjthread to be switched to.
 * @retval 0 or error code
 */
int CJThreadResume(CJThreadHandle cjthread);

/**
 * @brief Obtain the cjthread status. Used only for lua2cj.
 * @attention can only be used for cjthreads created by the #CJThreadCreate interface.
 * @param cjthread    [IN] cjthread whose status is to be obtained.
 * @retval If the operation is successful, the cjthread status is returned. For details,
 * see #LuaCJThreadState. If the operation fails, an error code is returned.
 */
int CJThreadStateGet(CJThreadHandle cjthread);

/**
 * @brief Release the cjthread, which should be called before or after the cjthread
 * execution starts. Used only for lua2cj.
 * @attention can only be used for cjthreads created by the #CJThreadCreate interface.
 * The cjthread cannot be accessed after execution. Only
 * Invoke the cjthread before or after the cjthread is started to avoid leakage of
 * cjthread resources.
 * @param cjthread    [IN] cjthread to be released.
 * @retval 0 or error code
 */
int CJThreadDestroy(CJThreadHandle cjthread);

/**
 * @brief Obtain the cjthread execution result. This interface must be invoked after the
 * cjthread execution is complete. Used only for lua2cj.
 * @attention can only be used for cjthreads created by the #CJThreadCreate interface.
 * @param cjthread [IN] cjthread for obtaining the execution result.
 * @retval 0 or error code
 */
void *CJThreadResultGet(CJThreadHandle cjthread);

/**
 * @brief get the processor id
 */
unsigned int ProcessorId(void);

/**
 * @brief Check whether the current processor can spin.
 */
bool ProcessorCanSpin(void);

/**
 * @brief Obtains the number of processors in all existing schedulers.
 */
unsigned int ScheduleGetProcessorNum(void);

/**
 * @brief Pointer to the start position of a parameter.
 */
void *CJThreadGetArg(void);

/**
 * @brief Stops the current cjthread and puts the cjthread back to the end of the run queue.
 */
int CJThreadResched(void);

/**
 * @brief If many tasks are pending, the current cjthread is stopped and the cjthread is
 * put back to the end of the running queue.
 */
int CJThreadTryResched(void);

/**
 * @brief Enables or disables the scaling function of the current cjthread stack.
 * (This function is dedicated for C.)
 * @par Description: Stack scaling is not allowed in the warehouse function called by c.
 * This interface temporarily enables or disables the current cjthread stack scaling function.
 * @attention This interface can be invoked only in the context of cjthread. If stack scaling
 * is disabled globally, this interface does not take effect.
 * @param enableStackGrow    [IN] Indicates whether to enable stack scaling.
 * @retval 0 or error code
 */
int CJThreadSetStackGrow(bool enableStackGrow);

#ifdef __OHOS__
/**
 * @brief store sp of UI Thread
 *
 * @param sp
 */
void StoreNativeSPForUIThread(void* sp);

/**
 * @brief get sp of UI Thread
 */
void* GetNativeSPForUIThread();

/**
 * @brief update arkvm stackInfo
 *
 * @param arkvm
 */
void UpdateArkVMStackInfo(unsigned long long arkvm);

/**
 * @brief Check whether the current thread is a foreign thread.
 */
bool IsForeignThread();
#endif

/**
 * @brief cjthread stack expansion
 * @par Description: Triggers the stack expansion of the current cjthread. Allocates a new
 * cjthread stack and copies the contents of the old stack to the new stack.
 * @attention This interface can be invoked only in the context of the current cjthread.
 * If the configured stack size is not greater than the current stack size, stack capacity expansion is not triggered.
 * @attention After the stack pointer is switched, the memory allocated to the old stack
 * cannot be accessed after this interface is called. The memory allocated to the old stack
 * is copied to the new stack and can be accessed.
 * @param stackSize    [IN] 0 indicates that the size of the stack is twice the size of the
 * original stack. The remaining numbers specify the stack size. The maximum stack size is 1 GB.
 * @retval If the operation is successful, the offsets of the new stack and old stack are
 * returned. If the operation fails, - 1 is returned. If the stack is not expanded, 0 is returned.
 */
intptr_t CJThreadStackGrow(size_t stackSize);

/**
 * @brief Release the old cjthread stack
 * @par Used to release the old cjthread stack after stack expansion is triggered.
 * @attention This interface can be invoked only in the context of the current cjthread.
 * @param stackAddr    [IN] Start address of the old stack memory
 * @param stackSize    [IN] Total size of the old stack memory.
 */
void CJThreadOldStackFree(void *stackAddr, size_t stackSize);

/* Externally presented cjthread status information, which is differentiated from internal status. */
enum CJthreadStatePublic {
    CJTHREAD_PSTATE_ALL,         /* Include all states except for non IDEL states */
    CJTHREAD_PSTATE_RUNNING,     /* running, ready, syscall */
    CJTHREAD_PSTATE_BLOCKING,    /* parking */
};

/**
 * @ingroup schedule
 * @brief Obtain the total number of cjthreads in the scheduling framework. Different from
 * ScheduleCJThreadCountForCJDB, this function needs to be locked.
 * @retval If g_scheduleManager is not initialized, 0xffffffff is returned. The sum of the
 * number of cjthreads in the corresponding states of all existing schedulers is returned.
 * @param state     [IN] Corresponding status of the number of cjthreads to be counted
 */
unsigned long long ScheduleCJThreadCountPublic(CJthreadStatePublic state);

/**
 * @ingroup schedule
 * @brief Obtain the number of running OS threads in the scheduling framework.
 * @retval If g_scheduleManager is not initialized, 0xffffffff is returned. The total number
 * of running OS threads is returned.
 */
unsigned int ScheduleRunningOSThreadCount(void);

/**
 * @ingroup The scheduler provides the trace enable method for external systems.
 * @brief The trace is loaded as a dynamic library on demand. This method is provided for
 * external systems to load the dynamic library. The trace method is registered and the trace
 * function is enabled.
 * @param traceType    [IN] Trace type. Enable one or more types of collection.
 * @see
 */
bool ScheduleStartTrace(unsigned short traceType);

/**
 * @ingroup The scheduler provides the method for disabling trace.
 * @brief The trace is loaded as a dynamic library on demand. This method is provided to
 * disable the trace function and dynamic library.
 */
bool ScheduleStopTrace(void);

/**
 * @ingroup The scheduler provides the trace data output interface for external systems.
 * @brief The scheduler provides the trace data output interface externally.
 * @param len     [OUT] Byte array length
 * @retval NULL or charArrayPointer
 */
unsigned char *ScheduleDumpTrace(int *len);

/**
 * @ingroup The scheduler provides an interface for recording trace events externally.
 * @brief The scheduler provides the interface for recording trace events externally.
 * @attention The events that need to store the call stack must be in the context of the
 * cjthread. Ensure that the number of argNum is the same as the number of input extra
 * parameters.
 * @param event    [IN] Event type
 * @param skip     [IN] When skip is greater than or equal to 0, the call stack needs to be
 * stored. The value indicates the number of layers to be returned to the stack.
 * @param cjthread [IN] Obtains the mutator. If the value is empty, stacking is not required.
 * @param argNum   [IN] Number of extra parameters, indicating the number of parameters of args
 * @param ...      [IN] Additional parameters
 */
void ScheduleTraceEvent(TraceEvent event, int skip, struct CJThread *cjthread, int argNum, ...);

#ifdef CANGJIE_SANITIZER_SUPPORT
/**
 * @brief acquire sanitizer context from specific cjthread
 * @retval return sanitizer context (asan: fake stack, tsan: race state) if success or nullptr
 */
void* CJThreadGetSanitizerContext(void* cjthread);

/**
 * @brief set sanitizer context to specific cjthread
 */
void CJThreadSetSanitizerContext(void* cjthread, void* state);
#endif
#if defined(CANGJIE_TSAN_SUPPORT)
/**
 * @brief get processor handle from current cjthread
 * @retval return processor handle if success, return nullptr if failed
 */
void* ProcessorGetHandle(void);
#endif

void CJThreadGetInfo(struct CJThread *cjthread, struct CJThreadInfo *cjthreadInfo);
void RunResolveCycle(void* funcPtr);

/**
 * @brief handle some foreign-cj thread when a foreign os thread exit.
 */
void CJForeignThreadExit(CJThreadHandle foreignCJThread);
#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif

/**
 * @brief Obtain the total number of cjthreads in the scheduling framework, which is used by
 * the CJDB and is not locked during signal processing.
 * @retval If g_scheduleManager is not initialized, 0xffffffff is returned. Otherwise, the
 * sum of the number of cjthreads for all existing schedulers is returned.
 * @attention
 * 1. Displayed in C++ format for debugger.
 */
unsigned long long CJ_MRT_GetCJThreadNumberUnsafe(void);

/**
 * @brief Obtain information about all running and to-be-running cjthreads.
 * @par Description: Obtain the cjthread information in the current running, then obtain the
 * cjthread information in the global running queue, and finally obtain the cjthread
 * information in the local running queue of each processor.
 * @attention
 * 1. This method is not locked. Therefore, ensure that no other processor is scheduled when
 *    invoking this method.
 * 2. Failed to obtain the cjthread that has been parked.
 * 3. If the value of processor id in the cjthread information is unsigned int max, it
 *    indicates that the cjthread does not have a processor.
 * 4. Displayed in C++ format for debugger.
 * 5. cjthreadBufPtr must be of the void* type.
 * @param cjthreadBufPtr   [IN] Pointer to the buffer for loading cjthread information.
 * @param num              [IN] A maximum of num processes can be obtained.
 * @retval Return the number of cjthread information obtained.
 */
int CJ_MRT_GetAllCJThreadInfo(void *cjthreadBufPtr, unsigned int num);

#ifdef __IOS__
/**
 * @brief Maximum length of a cjthread stack string.
 */
#define CJTHREAD_STACK_STRING_SIZE             2048

/**
 * @brief Obtain stack trace string about all running cjthreads.
 * @attention
 * 1. This method is not locked. Therefore, ensure that no other processor is scheduled when
 *    invoking this method.
 * 2. cjStackTraceBufPtr must be of the void* type.
 * 3. The capacity of string buffer within the cjStackTraceBufPtr must be greater than
 *    CJTHREAD_STACK_STRING_SIZE.
 * @param cjthreadBufPtr   [IN] Pointer to the buffer for saving the stack trace.
 * @param num              [IN] A maximum of num processes can be obtained.
 * @retval Return the number of stack trace obtained.
 */
int CJ_MRT_GetAllCJThreadStackTrace(void *cjStackTraceBufPtr, unsigned int num);
#endif

#endif /* MRT_SCHEDULE_H */
