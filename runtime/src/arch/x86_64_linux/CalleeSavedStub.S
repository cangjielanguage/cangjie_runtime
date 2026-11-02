// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// stub need to be 16-byte aligned, so we should use (8 * even numbers)
#define CalleeSavedRegistersStubFrameSize           (8 * 8)

////////////////////////////////////////////////////////////////////////////////
// CalleeSavedRegistersStub simply forwards arguments passed by runtime, i.e., arguments for compiled method are passed
// according to C/C++ calling convention, which usually means efficiency.
////////////////////////////////////////////////////////////////////////////////
// the frame layout of stack(growing downwards) after CalleeSavedRegistersStub frame is built looks like:
//                 |  ...         |
//                 |  ra          | return address for the caller of CalleeSavedRegistersStub
// caller rbp  --> |  rbp         |
//                 |  ...         |
//                 | ra           |
//   stub rbp  --> | caller rbp   | <==CalleeSavedRegistersStub Start
// callee register | %r15         |
//                 | %r14         |
//                 | %r13         |
//                 | %r12         |
//                 | %rbx         |
// arg0            | %rdi         |
// arg1            | %rsi         |
//                 | null         |
// 16-byte aligned | null         | <==CalleeSavedRegistersStubFrameSize, CalleeSavedRegistersStub frame ends at here

    .macro CalleeSavedRegistersStub, funcName, funcNameStub
    .text
    .align 2
    .global \funcNameStub
    .type \funcNameStub, @function
\funcNameStub:
    .cfi_startproc
    pushq   %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register %rbp
    subq    $CalleeSavedRegistersStubFrameSize, %rsp

    movq    %r15, -8(%rbp)
    movq    %r14, -16(%rbp)
    movq    %r13, -24(%rbp)
    movq    %r12, -32(%rbp)
    movq    %rbx, -40(%rbp)
    .cfi_rel_offset %rbx, -40
    .cfi_rel_offset %r12, -32
    .cfi_rel_offset %r13, -24
    .cfi_rel_offset %r14, -16
    .cfi_rel_offset %r15, -8

    callq   \funcName
    movq    %rax, -8(%rbp)

    callq   MRT_GetThreadLocalData@PLT
    movq    %rax,  %r15

    // Restore the value of rsp before coping arg6, arg7...
    addq    $CalleeSavedRegistersStubFrameSize, %rsp

    movq    -8(%rbp),  %rax
    movq    -16(%rbp), %r14
    movq    -24(%rbp), %r13
    movq    -32(%rbp), %r12
    movq    -40(%rbp), %rbx

    popq    %rbp
    .cfi_def_cfa %rsp, 8
    retq
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
    pushq   %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register %rbp
    subq    $CalleeSavedRegistersStubFrameSize, %rsp

    movq    %r15, -8(%rbp)
    movq    %r14, -16(%rbp)
    movq    %r13, -24(%rbp)
    movq    %r12, -32(%rbp)
    movq    %rbx, -40(%rbp)
    .cfi_rel_offset %rbx, -40
    .cfi_rel_offset %r12, -32
    .cfi_rel_offset %r13, -24
    .cfi_rel_offset %r14, -16
    .cfi_rel_offset %r15, -8

    movq    0(%rbp), %rdi
    callq   \funcName

    callq   MRT_GetThreadLocalData@PLT
    movq    %rax,  %r15

    addq    $CalleeSavedRegistersStubFrameSize, %rsp

    movq    -16(%rbp), %r14
    movq    -24(%rbp), %r13
    movq    -32(%rbp), %r12
    movq    -40(%rbp), %rbx

    popq    %rbp
    .cfi_def_cfa %rsp, 8
    retq
    .cfi_endproc
    .size \funcNameStub, .-\funcNameStub
    .endm

.global unwindPCForC2RStubStart
unwindPCForC2RStubStart:
CalleeSavedRegistersStub MCC_NewObject CJ_MCC_NewObject
CalleeSavedRegistersStub MCC_NewWeakRefObject CJ_MCC_NewWeakRefObject
CalleeSavedRegistersStub MCC_NewFinalizer CJ_MCC_NewFinalizer
CalleeSavedRegistersStub MCC_NewObjArray CJ_MCC_NewObjArray
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
