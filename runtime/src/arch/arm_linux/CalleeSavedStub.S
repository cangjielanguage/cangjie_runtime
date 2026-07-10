// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#define cfi_adjust_cfa_offset(off)      .cfi_adjust_cfa_offset off
#define cfi_rel_offset(reg, off)        .cfi_rel_offset reg, off
#define cfi_restore(reg)                .cfi_restore reg
#define cfi_def_cfa(reg, off)           .cfi_def_cfa reg, off
#define cfi_def_cfa_register(reg)       .cfi_def_cfa_register reg

#define StubFrameContextSize      (4 * 12)
#define StubCalleeSaveAreaSize    (4 * 4)

// caller sp  -->  | arg7         |
//                 | null         |
// callee saved    | r10          |
//                 | r9           |
//                 | r8           |
//                 | r7           |
//                 | r6           |
//                 | r5           |
// callee saved    | r4           |
//                 | null         |
//                 | null         |
//                 | lr           |
//   stub fp  -->  | caller fp    |

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    .global CalleeSavedStubFrameSize
CalleeSavedStubFrameSize:
    .word StubFrameContextSize
#endif

    .macro CalleeSavedRegistersStub, funcName, funcNameStub
    .text
    .p2align 2
    .global \funcNameStub
    .type \funcNameStub, %function
\funcNameStub:
    .cfi_startproc

    sub  sp, sp, #StubFrameContextSize
    str  r11, [sp]
    str  lr, [sp, #4]
    cfi_adjust_cfa_offset (StubFrameContextSize)
    cfi_rel_offset (r11, 0)
    cfi_rel_offset (lr, 4)

    mov  r11, sp
    cfi_def_cfa_register (sp)

    // save all used callee-saved registers.
    str  r4, [sp, #StubCalleeSaveAreaSize]
    str  r5, [sp, #StubCalleeSaveAreaSize+4]
    str  r6, [sp, #StubCalleeSaveAreaSize+8]
    str  r7, [sp, #StubCalleeSaveAreaSize+12]
    str  r8, [sp, #StubCalleeSaveAreaSize+16]
    str  r9, [sp, #StubCalleeSaveAreaSize+20]
    str  r10, [sp, #StubCalleeSaveAreaSize+24]
    cfi_rel_offset(r4, StubCalleeSaveAreaSize)
    cfi_rel_offset(r5, StubCalleeSaveAreaSize+4)
    cfi_rel_offset(r6, StubCalleeSaveAreaSize+8)
    cfi_rel_offset(r7, StubCalleeSaveAreaSize+12)
    cfi_rel_offset(r8, StubCalleeSaveAreaSize+16)
    cfi_rel_offset(r9, StubCalleeSaveAreaSize+20)
    cfi_rel_offset(r10, StubCalleeSaveAreaSize+24)

    bl  \funcName

    // restore all used callee-saved registers.
    ldr  r4, [sp, #StubCalleeSaveAreaSize]
    ldr  r5, [sp, #StubCalleeSaveAreaSize+4]
    ldr  r6, [sp, #StubCalleeSaveAreaSize+8]
    ldr  r7, [sp, #StubCalleeSaveAreaSize+12]
    ldr  r8, [sp, #StubCalleeSaveAreaSize+16]
    ldr  r9, [sp, #StubCalleeSaveAreaSize+20]
    ldr  r10, [sp, #StubCalleeSaveAreaSize+24]
    cfi_restore(r4)
    cfi_restore(r5)
    cfi_restore(r6)
    cfi_restore(r7)
    cfi_restore(r8)
    cfi_restore(r9)
    cfi_restore(r10)

    ldr  r11, [sp]
    ldr  lr, [sp, #4]
    add  sp, sp, #StubFrameContextSize
    cfi_adjust_cfa_offset (-StubFrameContextSize)
    cfi_restore(r11)
    cfi_restore(lr)

    bx lr
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm

#define StubFrameContextSizeForStackArgs    (4 * 20)
#define StubCalleeSaveAreaSizeForStackArgs  (4 * 12)
#define StubFrameAddrAreaSizeForStackArgs   (4 * 8)

// caller sp  -->  | arg7         |
//                 | null         |
// callee saved    | r10          |
//                 | r9           |
//                 | r8           |
//                 | r7           |
//                 | r6           |
//                 | r5           |
// callee saved    | r4           |
//                 | null         |
//                 | null         |
//                 | lr           |
//   stub fp  -->  | caller fp    |
//                 | arg11        |
//                 | arg10        |
//                 | arg9         |
//                 | arg8         |
//                 | arg7         |
//                 | arg6         |
//                 | arg5         |
//   stub sp  -->  | arg4         |

    .macro CalleeSavedRegistersAndStackArgsStub, funcName, funcNameStub
    .text
    .p2align 2
    .global \funcNameStub
    .type \funcNameStub, %function
\funcNameStub:
    .cfi_startproc

    sub  sp, sp, #StubFrameContextSizeForStackArgs
    str  r11, [sp, #StubFrameAddrAreaSizeForStackArgs]
    str  lr, [sp, #StubFrameAddrAreaSizeForStackArgs+4]
    cfi_adjust_cfa_offset (StubFrameContextSizeForStackArgs)
    cfi_rel_offset (r11, StubFrameAddrAreaSizeForStackArgs)
    cfi_rel_offset (lr, StubFrameAddrAreaSizeForStackArgs+4)

    add  r11, sp, #StubFrameAddrAreaSizeForStackArgs
    cfi_def_cfa (r11, StubCalleeSaveAreaSizeForStackArgs)

    // save all used callee-saved registers.
    str  r4, [sp, #StubCalleeSaveAreaSizeForStackArgs]
    str  r5, [sp, #StubCalleeSaveAreaSizeForStackArgs+4]
    str  r6, [sp, #StubCalleeSaveAreaSizeForStackArgs+8]
    str  r7, [sp, #StubCalleeSaveAreaSizeForStackArgs+12]
    str  r8, [sp, #StubCalleeSaveAreaSizeForStackArgs+16]
    str  r9, [sp, #StubCalleeSaveAreaSizeForStackArgs+20]
    str  r10, [sp, #StubCalleeSaveAreaSizeForStackArgs+24]
    cfi_rel_offset(r4, 16)
    cfi_rel_offset(r5, 20)
    cfi_rel_offset(r6, 24)
    cfi_rel_offset(r7, 28)
    cfi_rel_offset(r8, 32)
    cfi_rel_offset(r9, 36)
    cfi_rel_offset(r10, 40)

    // save extra parameters stored on stack. Fixed quntity is 8 temporarily.
    // r10 <- previous sp
    add  r10, sp, #StubFrameContextSizeForStackArgs
    // r4 <- caller fp
    ldr  r4, [sp, #StubFrameAddrAreaSizeForStackArgs]
    mov  r12, sp
    mov  r9, #0
.L_copy:
    cmp  r4, r10
    bls  .L_copy_end
    cmp  r9, #4
    bge  .L_copy_end
    ldr  r5, [r10]
    ldr  r6, [r10, #4]
    str  r5, [r12]
    str  r6, [r12, #4]
    add  r12, r12, #8
    add  r10, r10, #8
    add  r9, r9, #1
    b  .L_copy
.L_copy_end:

    bl  \funcName

    // restore all used callee-saved registers.
    ldr  r4, [sp, #StubCalleeSaveAreaSizeForStackArgs]
    ldr  r5, [sp, #StubCalleeSaveAreaSizeForStackArgs+4]
    ldr  r6, [sp, #StubCalleeSaveAreaSizeForStackArgs+8]
    ldr  r7, [sp, #StubCalleeSaveAreaSizeForStackArgs+12]
    ldr  r8, [sp, #StubCalleeSaveAreaSizeForStackArgs+16]
    ldr  r9, [sp, #StubCalleeSaveAreaSizeForStackArgs+20]
    ldr  r10, [sp, #StubCalleeSaveAreaSizeForStackArgs+24]
    cfi_restore(r4)
    cfi_restore(r5)
    cfi_restore(r6)
    cfi_restore(r7)
    cfi_restore(r8)
    cfi_restore(r9)
    cfi_restore(r10)

    ldr  r11, [sp, #StubFrameAddrAreaSizeForStackArgs]
    ldr  lr, [sp, #StubFrameAddrAreaSizeForStackArgs+4]
    add  sp, sp, #StubFrameContextSizeForStackArgs
    cfi_adjust_cfa_offset (-StubFrameContextSizeForStackArgs)
    cfi_restore(r11)
    cfi_restore(lr)

    bx lr
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm

    .global unwindPCForC2RStubStart
unwindPCForC2RStubStart:
    CalleeSavedRegistersStub MCC_NewObject CJ_MCC_NewObject
    CalleeSavedRegistersStub MCC_NewWeakRefObject CJ_MCC_NewWeakRefObject
    CalleeSavedRegistersStub MCC_NewObjArray CJ_MCC_NewObjArray
    CalleeSavedRegistersStub MCC_NewFinalizer CJ_MCC_NewFinalizer
    CalleeSavedRegistersStub MCC_NewArray CJ_MCC_NewArray
    CalleeSavedRegistersStub MCC_NewArray8 CJ_MCC_NewArray8
    CalleeSavedRegistersStub MCC_NewArray16 CJ_MCC_NewArray16
    CalleeSavedRegistersStub MCC_NewArray32 CJ_MCC_NewArray32
    CalleeSavedRegistersStub MCC_NewArray64 CJ_MCC_NewArray64
    CalleeSavedRegistersStub MCC_InvokeGCImpl CJ_MCC_InvokeGC
    CalleeSavedRegistersStub MCC_FillInStackTraceImpl CJ_MCC_FillInStackTrace
    CalleeSavedRegistersStub MCC_GetAllThreadSnapshotImpl CJ_MCC_GetAllThreadSnapshot
    CalleeSavedRegistersStub MCC_GetCurrentThreadSnapshotImpl CJ_MCC_GetCurrentThreadSnapshot
    CalleeSavedRegistersStub CJ_SchedulePreemptCheck CJ_SchedulePreemptCheckStub
    CalleeSavedRegistersStub MCC_AcquireRawData CJ_MCC_AcquireRawData
    CalleeSavedRegistersStub MRT_FutureWait CJ_MCC_FutureWait
    CalleeSavedRegistersStub MCC_MutexLock CJ_MCC_MutexLock
    CalleeSavedRegistersStub MCC_MutexLockSlowPath CJ_MCC_MutexLockSlowPath
    CalleeSavedRegistersStub MCC_MonitorWait CJ_MCC_MonitorWait
    CalleeSavedRegistersStub MCC_MultiConditionMonitorWait CJ_MCC_MultiConditionMonitorWait
    CalleeSavedRegistersStub MRT_Sleep CJ_MRT_Sleep
    CalleeSavedRegistersStub MCC_NewPinnedObject CJ_MCC_NewPinnedObject
    CalleeSavedRegistersStub MCC_ApplyCJInstanceMethod CJ_MCC_ApplyCJInstanceMethod
    CalleeSavedRegistersStub MCC_ApplyCJStaticMethod CJ_MCC_ApplyCJStaticMethod
    CalleeSavedRegistersStub MCC_ApplyCJGenericInstanceMethod CJ_MCC_ApplyCJGenericInstanceMethod
    CalleeSavedRegistersStub MCC_ApplyCJGenericStaticMethod CJ_MCC_ApplyCJGenericStaticMethod
    CalleeSavedRegistersStub MCC_GetMethodAnnotations CJ_MCC_GetMethodAnnotations
    CalleeSavedRegistersStub MCC_GetInstanceFieldAnnotations CJ_MCC_GetInstanceFieldAnnotations
    CalleeSavedRegistersStub MCC_GetStaticFieldAnnotations CJ_MCC_GetStaticFieldAnnotations
    CalleeSavedRegistersStub MCC_GetParameterAnnotations CJ_MCC_GetParameterAnnotations
    CalleeSavedRegistersStub MCC_GetTypeInfoAnnotations CJ_MCC_GetTypeInfoAnnotations
    CalleeSavedRegistersStub MCC_GetInstanceFieldValue CJ_MCC_GetInstanceFieldValue
    CalleeSavedRegistersStub MCC_GetStaticFieldValue CJ_MCC_GetStaticFieldValue
    CalleeSavedRegistersStub MCC_NewArrayGeneric CJ_MCC_NewArrayGeneric
    CalleeSavedRegistersStub MCC_DumpCJHeapData CJ_MCC_DumpCJHeapData
    CalleeSavedRegistersStub MCC_NewAndInitEnumTupleObject CJ_MCC_NewAndInitEnumTupleObject
    CalleeSavedRegistersStub MCC_GetAssociatedValues CJ_MCC_GetAssociatedValues
    CalleeSavedRegistersAndStackArgsStub MCC_DecodeStackTraceImpl CJ_MCC_DecodeStackTrace
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    CalleeSavedRegistersStub MCC_ThrowException CJ_MCC_ThrowException
    CalleeSavedRegistersStub MCC_ThrowStackOverflowError CJ_MCC_ThrowStackOverflowError
#endif
    .global unwindPCForC2RStubEnd
unwindPCForC2RStubEnd: