// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_CJTHREAD_H
#define MRT_CJTHREAD_H

#include <stdbool.h>
#include <atomic>
#ifdef __OHOS__
#include <vector>
#endif
#include <limits.h>
#include "schedule.h"
#include "list.h"
#include "thread.h"
#include "cjthread_context.h"
#include "Mutator/Mutator.h"
#include "base.h"

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

#define CJTHREAD_KEYS_MAX 9
#define CJTHREAD_ARG_ALIGN (16)
#define CJTHREAD_INIT_ID (ULLONG_MAX)

#define CJTHREAD_SANITIZER_CONTEXT_OFFSET (16)

/**
* @brief The address is aligned upward.
* @param addr     [IN] Value to be aligned.
* @param align    [IN] Number of bytes to be aligned.
*/
#define STACK_ADDR_ALIGN_UP(addr, align) ((((uintptr_t)(addr) + (uintptr_t)((align) - 1)) & ~(uintptr_t)((align) - 1)))

/**
* @brief The address is aligned downwards.
* @param addr     [IN] Value to be aligned.
* @param align    [IN] Number of bytes to be aligned.
*/
#define STACK_ADDR_ALIGN_DOWN(addr, align) ((((uintptr_t)(addr)) & ~(uintptr_t)((align) - 1)))

/**
 * @brief Internal management structure of cjthread local variables
 */
struct CJThreadKeyInternal {
    std::atomic<unsigned int> count;
    std::atomic<uintptr_t> keyDestructor[CJTHREAD_KEYS_MAX];
};

/**
 * @brief Structure of the cjthread stack
 * low address--------------------------------high address
 * -----------------------------------------
 * |              |                        |
 * | protect page |      cjthread stack   |
 * |              |                        |
 * -----------------------------------------
 */
struct CJThreadStack {
    char *protectAddr;                 /* low address of the stack protection page */
    size_t totalSize;                  /* totalSize includes protection page size, stack size */
    char *stackTopAddr;                /* stack top address */
    char *stackGuard;                  /* threshold for determining stack overflow. It is
                                        * stackTopAddr+Stack_REVERSED(a certain number of bytes
                                        * are reserved) */
    char *stackBaseAddr;               /* Stack bottom address of the applied stack.
                                        * It equals stackTopAddr+stackSize. Note: The address
                                        * range is an open interval. An address smaller than
                                        * stackBaseAddr belongs to the stack, and an address
                                        * equal to stackBaseAddr does not belong to the stack. */
    size_t stackSize;                  /* Specifies the stack size for creating a cjthread,
                                        * excluding the stack protection size. */
    char *cjthreadStackBaseAddr;       /* Actual stack bottom of cjthread stack. It is equal
                                        * to stackAddr+stackAlign and is 16 bytes down. */
    unsigned int stackGrowCnt;         /* whether to enable cjthread stack scaling.
                                        * The value 0 indicates that stack scaling is enabled,
                                        * and other values indicate that disabled. */
};

struct StackInfo {
    unsigned long long stackLimit = 0ULL;
    unsigned long long lastLeaveFrame = 0ULL;
};

/**
 * @brief cjthread allocation type
 */
enum CJThreadBuf {
    LOCAL_BUF,      /* The local cache control block is preferentially used. */
    GLOBAL_BUF,     /* The global cache control block is preferentially used. */
    NO_BUF          /* The cache control block is not used. cjthread0 only. */
};

/**
 * @brief Internal structure of cjthread attributes
 * @attention The size of the structure cannot exceed ATTR_MAX_SIZE
 */
struct CJThreadAttrInner {
    size_t stackSize;                          /* stack size */
    bool cjFromC;                              /* create cjthread directly from side C */
    bool named;
    char name[CJTHREAD_NAME_SIZE];             /* cjthread name */
    bool hasSpecificData;
    void *specificData[CJTHREAD_KEYS_MAX];     /* local data */
};

/**
 * @brief cjthread structure
 */
struct CJThread {
    struct Dulink schdDulink;                /* Global scheduling queue for cjthreads link to  */
    struct Thread *thread;                   /* The current thread. Note that the offset of
                                              * this field in the structure is used in the
                                              * cjthread_context assembly. Therefore, do not
                                              * change the offset. */
    struct CJThreadContext context;          /* The cjthread context. Note that the offset of
                                              * this field in the structure is used in the
                                              * cjthread_context assembly. Therefore, do not
                                              * change the offset. */
    std::atomic<CJThreadState> state;        /* cjthread state */
    MapleRuntime::Mutator *mutator;          /* mutator, use for gc */
    struct Schedule *schedule;               /* scheduler */
    struct Dulink allCJThreadDulink;         /* Global manafement queue connected to all cjthreads */
    struct Dulink cjSingleModeThreadDulink;
    struct CJThreadStack stack;              /* cjthread stack */
    CJThreadFunc func;
    void *argStart;                          /* The header of the cjthread stack is used to
                                              * store parameters, pointing to the start address
                                              of the parameters. */
    unsigned int argSize;
    int result;
    void *localData[CJTHREAD_KEYS_MAX];      /* cjthread local data */
    struct Thread *boundThread;              /* bound thread of cjthread */
    unsigned int preemptOffCnt;              /* the count bit to disable the preemption
                                              * function of the current cjthread. If the
                                              * value is not 0, preemption is prohibited. */
    unsigned int exclusiveScopeCnt;          /* != 0 ⇒ in exclusiveScope; OS thread pinned */
    int coErrno;                             /* error code */
    bool isLuaCJThread;
    unsigned long long int id;               /* cjthread id. The offset of this field in the
                                              * structure is used for lock optimization in llvm.
                                              Do not change it. */
    char name[CJTHREAD_NAME_SIZE];           /* cjthread name */
    bool isCJThread0;
#ifdef __OHOS__
    std::vector<unsigned long long> threadStackTopList;
#endif
};

/**
 * @brief lua cjthread is only used in lua2cj
 */
struct LuaCJThread {
    CJThreadHandle cjthread;
    LuaCJThreadFunc func;
    void *arg;
    void *result;
    struct Semaphore sem;
    int state;
    struct CJThreadAttr attrUser;
};

/**
 * @brief arg structure, which is used to transfer parameters of CJThreadAlloc.
 */
struct ArgAttr {
    const void *argStart;                   /* arg pointer */
    size_t argSize;                         /* arg length */
};

/**
 * @brief Stack structure, which stores partial stack information.
 */
struct StackAttr {
    size_t stackSizeAlign;                  /* Size of the cjthread stack to be allocated,
                                             * which needs to be page aligned. */
    bool stackGrow;                         /* Whether to enable stack scaling. */
};

/**
 * @brief Release the memory of the cjthread.
 * @par Description: Releases the memory of the cjthread, including the stack memory and the
 * internal memory of the cjthread structure.
 * @param cjthread    [IN] cjthread to be released
 * @retval none.
 */
void CJThreadMemFree(struct CJThread *cjthread);

/**
 * @brief Put the cjthread control block into the free list.
 * @par Description: Release the cjthread control block to the free list.
 * @param cjthread    [IN] cjthread to be operated
 * @param reuse    [IN] Whether to reuse
 * @retval none.
 */
void CJThreadFree(struct CJThread *cjthread, bool reuse);

/**
 * @brief Allocate cjthread control blocks.
 * @par Description: Allocates space for the cjthread control block, initializes the cjthread
 * stack information, and initializes the parameter start address and other fields.
 * @attention allocates extra space for the cjthread control block for 16-byte alignment.
 * @param schedule    [IN] Home scheduling framework.
 * @param argStart    [IN] Start address of the cjthread parameter.
 * @param argSize    [IN] Number of cjthread parameters.
 * @param stackSize    [IN] Size of the cjthread stack.
 * @param coBuf    [IN] If co_buf is true, search for the cache control block in the current
 * processor and increase the cjthread count.
 * If co_buf is false, malloc is performed directly and the cjthread count is not increased.
* @retval cjthread
 */
struct CJThread *CJThreadAlloc(struct Schedule *schedule, struct ArgAttr *argAttr,
                               struct StackAttr *stackAttr, CJThreadBuf coBuf,
                               CJThreadCreateSource createSource = CJTHREAD_CREATE_SOURCE_DEFAULT);

/**
 * @brief Invoke the registered destructor to clear the local variables of the cjthread.
 * cjthread is the cjthread to be cleared.
 * @par When a non-null pointer is stored in a local variable and a registered function is not
 * null, the function is called.
 * @attention Do not mix. Do not let the cjthread free again after the user frees the memory.
 * @param cjthread    [IN] cjthread pointer
 */
void CJThreadKeysClean(struct CJThread *cjthread);

struct CJThread* CJThreadBuild(ScheduleHandle schedule, const struct CJThreadAttr *attrUser, CJThreadFunc func,
                               const void *argStart, unsigned int argSize, CJThreadCreateSource createSource);

/**
 * @brief Add cjthreads to the queue in batches.
 * @par is used to invoke the netpoll function to add cjthreads to the running queue in batches.
 * The cjthread queue has been set to the ready state before this function is invoked.
 * @param list    [IN] List of cjthreads added to the queue
 * @param num    [IN] Number of cjthreads added to the queue
 * @retval 0 or error code
 */
int CJThreadAddBatch(CJThreadHandle *list, unsigned int num);

/**
 * @brief Generate cjthread0 context
 * @param  cjthread0        [IN]  cjthread0
 */
void CJThread0Make(struct CJThread *cjthread0);

/**
 * @brief Park the current cjthread, execute the callback function, schedule the next cjthread.
 * @par Park the current cjthread, go to cjthread0, and execute the callback function. If the
 * callback function returns 0, the callback function is successful. Schedule the next cjthread.
 * If the return value of the callback function is not 0, the callback function fails and the
 * previous cjthread is rolled back.
 * @param func    [IN] Callback executed before the cjthread stops
 * @param waitReason    [IN] Reason for park, which is used for trace.
 * @param arg    [IN] Input callback parameter
 * @retval 0 or error code
 */
int CJThreadPark(ParkCallbackFunc func, TraceEvent waitReason, void *arg);

/**
 * @brief Apply for the cjthread stack memory.
 * @param schedule    [IN] Scheduler to which the cjthread belongs
 * @param cjthread    [IN] cjthread structure
 * @param stackSizeAlign    [IN] New stack size (page alignment)
 * @param totalSize    [OUT] Total size of the cjthread stack memory. If stackProtect is not
 * enabled, the value is equal to stackSizeAlign. An extra page of memory is displayed when
 * stackProtect is enabled.
 * @retval stack address
 */
char *CJThreadStackMemAlloc(struct Schedule *schedule, struct CJThread *cjthread,
                            size_t stackSizeAlign, size_t *totalSize);

/**
 * @brief Free cjthread stack
 * @param  cjthread         [IN]  cjthread
 * @param  stackTopAddr     [IN]  stack start address
 * @param  stackTotalSize   [IN]  stack total size
 */
void CJThreadStackMemFree(struct CJThread *cjthread, char *stackTopAddr, size_t stackTotalSize);

/**
 * @brief Adjust the cjthread stack and replace the old cjthread stack with the new one.
 * @param cjthread [IN] cjthread structure
 * @param newStackSizeAlign[IN] New stack size (page alignment)
 * @retval If the operation is successful, the offsets of the new stack and old stack are
 * returned. If the operation fails, -1 is returned.
 */
intptr_t CJThreadStackAdjust(struct CJThread *cjthread, size_t newStackSizeAlign);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif
#endif /* MRT_CJTHREAD_H */
