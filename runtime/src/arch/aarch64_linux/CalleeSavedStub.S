// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#define cfi_adjust_cfa_offset(off)      .cfi_adjust_cfa_offset off
#define cfi_rel_offset(reg, off)        .cfi_rel_offset reg, off
#define cfi_restore(reg)                .cfi_restore reg
#define cfi_def_cfa_register(reg)       .cfi_def_cfa_register reg

////////////////////////////////////////////////////////////////////////////////
// CalleeSavedRegistersStub simply forwards arguments passed by runtime, i.e., arguments for compiled method are passed
// according to C/C++ calling convention, which usually means efficiency.
////////////////////////////////////////////////////////////////////////////////

#define StubFrameContextSize      (8 * 14)
#define StubCalleeSaveAreaSize (8 * 4)

// the frame layout of stack(growing downwards) after MCC_C2NStub frame is built looks like:

// caller sp  -->  | arg7         |
// callee saved    | avalid null  |
//                 | x28          |
//                 | x27          |
//                 | x26          |
//                 | x25          |
//                 | x24          |
//                 | x23          |
//                 | x22          |
//                 | x21          |
//                 | x20          |
// callee saved    | x19          |
//                 | x30          |
//   stub fp  -->  | caller fp    |
//                 |  ...         |
//                 | arg10        |
//                 | arg9         |
//                 | arg8         |
//   stub sp  -->  | arg7         | <== MCC_C2NStub frame ends at here

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    .global CalleeSavedStubFrameSize
CalleeSavedStubFrameSize:
    .quad StubFrameContextSize
#endif

    .macro CalleeSavedRegistersStub, funcName, funcNameStub
    .text
    .align 2
    .global \funcNameStub
    .type \funcNameStub, @function
\funcNameStub:
    .cfi_startproc
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    paciasp
#endif
    stp  x29, x30, [sp,  #-StubFrameContextSize]!
    cfi_adjust_cfa_offset (StubFrameContextSize)
    cfi_rel_offset (x29, 0)
    cfi_rel_offset (x30, 8)

    mov  x29, sp
    cfi_def_cfa_register (sp)

    // save all used callee-saved registers.
    stp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_rel_offset (x19, StubCalleeSaveAreaSize)
    cfi_rel_offset (x20, StubCalleeSaveAreaSize+8)

    stp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_rel_offset (x21, StubCalleeSaveAreaSize+0x10)
    cfi_rel_offset (x22, StubCalleeSaveAreaSize+0x18)

    stp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_rel_offset (x23, StubCalleeSaveAreaSize+0x20)
    cfi_rel_offset (x24, StubCalleeSaveAreaSize+0x28)

    stp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_rel_offset (x25, StubCalleeSaveAreaSize+0x30)
    cfi_rel_offset (x26, StubCalleeSaveAreaSize+0x38)

    stp  x27, x28, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_rel_offset (x27, StubCalleeSaveAreaSize+0x40)
    cfi_rel_offset (x28, StubCalleeSaveAreaSize+0x48)

    bl   \funcName
    str  x0,  [sp, #StubCalleeSaveAreaSize+0x48]

    bl   MRT_GetThreadLocalData
    mov  x28, x0

    // restore all used callee-saved registers.
    ldp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_restore (x19)
    cfi_restore (x20)
    ldp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_restore (x21)
    cfi_restore (x22)
    ldp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_restore (x23)
    cfi_restore (x24)
    ldp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_restore (x25)
    cfi_restore (x26)
    ldr  x27, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_restore (x27)
    ldr  x0,  [sp, #StubCalleeSaveAreaSize+0x48]
    cfi_restore (x0)

    ldp  x29, x30, [sp], #StubFrameContextSize
    cfi_adjust_cfa_offset (-StubFrameContextSize)
    cfi_restore (x29)
    cfi_restore (x30)
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    // x30 is signed in ExceptionHandling::ChangeEHStackInfoLR.
    autiasp
#endif
    ret
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm

    .macro LocalRegionStub, funcName, funcNameStub
    .text
    .align 2
    .global \funcNameStub
    .type \funcNameStub, @function
\funcNameStub:
    .cfi_startproc
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    paciasp
#endif
    stp  x29, x30, [sp,  #-StubFrameContextSize]!
    cfi_adjust_cfa_offset (StubFrameContextSize)
    cfi_rel_offset (x29, 0)
    cfi_rel_offset (x30, 8)

    mov  x29, sp
    cfi_def_cfa_register (sp)

    stp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_rel_offset (x19, StubCalleeSaveAreaSize)
    cfi_rel_offset (x20, StubCalleeSaveAreaSize+8)
    stp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_rel_offset (x21, StubCalleeSaveAreaSize+0x10)
    cfi_rel_offset (x22, StubCalleeSaveAreaSize+0x18)
    stp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_rel_offset (x23, StubCalleeSaveAreaSize+0x20)
    cfi_rel_offset (x24, StubCalleeSaveAreaSize+0x28)
    stp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_rel_offset (x25, StubCalleeSaveAreaSize+0x30)
    cfi_rel_offset (x26, StubCalleeSaveAreaSize+0x38)
    stp  x27, x28, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_rel_offset (x27, StubCalleeSaveAreaSize+0x40)
    cfi_rel_offset (x28, StubCalleeSaveAreaSize+0x48)

    ldr  x0, [x29]
    bl   \funcName

    bl   MRT_GetThreadLocalData
    mov  x28, x0

    ldp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_restore (x19)
    cfi_restore (x20)
    ldp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_restore (x21)
    cfi_restore (x22)
    ldp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_restore (x23)
    cfi_restore (x24)
    ldp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_restore (x25)
    cfi_restore (x26)
    ldr  x27, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_restore (x27)

    ldp  x29, x30, [sp], #StubFrameContextSize
    cfi_adjust_cfa_offset (-StubFrameContextSize)
    cfi_restore (x29)
    cfi_restore (x30)
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    autiasp
#endif
    ret
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm

    .macro CalleeSavedRegistersStubNew, funcName, funcNameStub
    .text
    .align 2
    .global \funcNameStub
    .type \funcNameStub, @function
\funcNameStub:
    .cfi_startproc
    ldr x30, [sp], #16
    stp  x29, x30, [sp,  #-StubFrameContextSize]!
    cfi_adjust_cfa_offset (StubFrameContextSize)
    cfi_rel_offset (x29, 0)
    cfi_rel_offset (x30, 8)

    mov  x29, sp
    cfi_def_cfa_register (sp)

    // save all used callee-saved registers.
    stp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_rel_offset (x19, StubCalleeSaveAreaSize)
    cfi_rel_offset (x20, StubCalleeSaveAreaSize+8)

    stp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_rel_offset (x21, StubCalleeSaveAreaSize+0x10)
    cfi_rel_offset (x22, StubCalleeSaveAreaSize+0x18)

    stp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_rel_offset (x23, StubCalleeSaveAreaSize+0x20)
    cfi_rel_offset (x24, StubCalleeSaveAreaSize+0x28)

    stp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_rel_offset (x25, StubCalleeSaveAreaSize+0x30)
    cfi_rel_offset (x26, StubCalleeSaveAreaSize+0x38)

    stp  x27, x28, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_rel_offset (x27, StubCalleeSaveAreaSize+0x40)
    cfi_rel_offset (x28, StubCalleeSaveAreaSize+0x48)

    bl   \funcName
    str  x0,  [sp, #StubCalleeSaveAreaSize+0x48]

    bl   MRT_GetThreadLocalData
    mov  x28, x0

    // restore all used callee-saved registers.
    ldp  x19, x20, [sp, #StubCalleeSaveAreaSize]
    cfi_restore (x19)
    cfi_restore (x20)
    ldp  x21, x22, [sp, #StubCalleeSaveAreaSize+0x10]
    cfi_restore (x21)
    cfi_restore (x22)
    ldp  x23, x24, [sp, #StubCalleeSaveAreaSize+0x20]
    cfi_restore (x23)
    cfi_restore (x24)
    ldp  x25, x26, [sp, #StubCalleeSaveAreaSize+0x30]
    cfi_restore (x25)
    cfi_restore (x26)
    ldr  x27, [sp, #StubCalleeSaveAreaSize+0x40]
    cfi_restore (x27)
    ldr  x0,  [sp, #StubCalleeSaveAreaSize+0x48]
    cfi_restore (x0)

    ldp  x29, x30, [sp], #StubFrameContextSize
    cfi_adjust_cfa_offset (-StubFrameContextSize)
    cfi_restore (x29)
    cfi_restore (x30)
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    // x30 is signed in ExceptionHandling::ChangeEHStackInfoLR.
    autiasp
#endif
    ret
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm


    .global unwindPCForC2RStubStart
unwindPCForC2RStubStart:
    CalleeSavedRegistersStubNew MCC_NewObject CJ_MCC_NewObject
    CalleeSavedRegistersStub MCC_NewWeakRefObject CJ_MCC_NewWeakRefObject
    CalleeSavedRegistersStub MCC_NewObjArray CJ_MCC_NewObjArray
    CalleeSavedRegistersStubNew MCC_NewFinalizer CJ_MCC_NewFinalizer
    CalleeSavedRegistersStub MCC_NewArray CJ_MCC_NewArray
    CalleeSavedRegistersStub MCC_NewArray8 CJ_MCC_NewArray8
    CalleeSavedRegistersStub MCC_NewArray16 CJ_MCC_NewArray16
    CalleeSavedRegistersStub MCC_NewArray32 CJ_MCC_NewArray32
    CalleeSavedRegistersStub MCC_NewArray64 CJ_MCC_NewArray64
    CalleeSavedRegistersStub MCC_InvokeGCImpl CJ_MCC_InvokeGC
    CalleeSavedRegistersStub MCC_FillInStackTraceImpl CJ_MCC_FillInStackTrace
    CalleeSavedRegistersStub MCC_DecodeStackTraceImpl CJ_MCC_DecodeStackTrace
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
    CalleeSavedRegistersStub MRT_ThreadWait CJ_MRT_ThreadWait
    CalleeSavedRegistersStub MRT_ThreadResumeAndWait CJ_MRT_ThreadResumeAndWait
    CalleeSavedRegistersStub MRT_ThreadReady CJ_MRT_ThreadReady
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
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    CalleeSavedRegistersStub MCC_ThrowException CJ_MCC_ThrowException
    CalleeSavedRegistersStub MCC_ThrowStackOverflowError CJ_MCC_ThrowStackOverflowError
#endif
    LocalRegionStub MCC_StartLocalRegion CJ_MCC_StartLocalRegion
    LocalRegionStub MCC_EndLocalRegion CJ_MCC_EndLocalRegion
    CalleeSavedRegistersStub MCC_NewLocalObject CJ_MCC_NewLocalObject
    CalleeSavedRegistersStub MCC_NewLocalFinalizer CJ_MCC_NewLocalFinalizer
    CalleeSavedRegistersStub MCC_NewLocalArray CJ_MCC_NewLocalArray
    CalleeSavedRegistersStub MCC_NewLocalObjArray CJ_MCC_NewLocalObjArray
    CalleeSavedRegistersStub MCC_NewLocalArray8 CJ_MCC_NewLocalArray8
    CalleeSavedRegistersStub MCC_NewLocalArray16 CJ_MCC_NewLocalArray16
    CalleeSavedRegistersStub MCC_NewLocalArray32 CJ_MCC_NewLocalArray32
    CalleeSavedRegistersStub MCC_NewLocalArray64 CJ_MCC_NewLocalArray64
    CalleeSavedRegistersStub MCC_NewLocalGenericObject CJ_MCC_NewLocalGenericObject
    CalleeSavedRegistersStub MCC_NewLocalGenericArray CJ_MCC_NewLocalGenericArray
    CalleeSavedRegistersStub MCC_NewLocalWeakRefObject CJ_MCC_NewLocalWeakRefObject
    .global unwindPCForC2RStubEnd
unwindPCForC2RStubEnd:
