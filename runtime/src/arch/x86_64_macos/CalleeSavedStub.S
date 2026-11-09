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

.macro CalleeSavedRegistersStub, funcName
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

    callq   _\funcName
    movq    %rax, -8(%rbp)

    callq   _MRT_GetThreadLocalData
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
.endm

.macro LocalRegionStub, funcName
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
    callq   _\funcName

    callq   _MRT_GetThreadLocalData
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
.endm

.global _unwindPCForC2RStubStart
_unwindPCForC2RStubStart:

    .text
    .align 2
    .global _CJ_MCC_NewObject
_CJ_MCC_NewObject:
    CalleeSavedRegistersStub MCC_NewObject

    .text
    .align 2
    .global _CJ_MCC_NewWeakRefObject
_CJ_MCC_NewWeakRefObject:
    CalleeSavedRegistersStub MCC_NewWeakRefObject

    .text
    .align 2
    .global _CJ_MCC_NewFinalizer
_CJ_MCC_NewFinalizer:
    CalleeSavedRegistersStub MCC_NewFinalizer

    .text
    .align 2
    .global _CJ_MCC_NewObjArray
_CJ_MCC_NewObjArray:
    CalleeSavedRegistersStub MCC_NewObjArray

    .text
    .align 2
    .global _CJ_MCC_NewArray
_CJ_MCC_NewArray:
    CalleeSavedRegistersStub MCC_NewArray

    .text
    .align 2
    .global _CJ_MCC_NewArray8
_CJ_MCC_NewArray8:
    CalleeSavedRegistersStub MCC_NewArray8

    .text
    .align 2
    .global _CJ_MCC_NewArray16
_CJ_MCC_NewArray16:
    CalleeSavedRegistersStub MCC_NewArray16

    .text
    .align 2
    .global _CJ_MCC_NewArray32
_CJ_MCC_NewArray32:
    CalleeSavedRegistersStub MCC_NewArray32

    .text
    .align 2
    .global _CJ_MCC_NewArray64
_CJ_MCC_NewArray64:
    CalleeSavedRegistersStub MCC_NewArray64

    .text
    .align 2
    .global _CJ_MCC_InvokeGC
_CJ_MCC_InvokeGC:
    CalleeSavedRegistersStub MCC_InvokeGCImpl

    .text
    .align 2
    .global _CJ_MCC_FillInStackTrace
_CJ_MCC_FillInStackTrace:
    CalleeSavedRegistersStub MCC_FillInStackTraceImpl

    .text
    .align 2
    .global _CJ_MCC_DecodeStackTrace
_CJ_MCC_DecodeStackTrace:
    CalleeSavedRegistersStub MCC_DecodeStackTraceImpl

    .text
    .align 2
    .global _CJ_MCC_GetAllThreadSnapshot
_CJ_MCC_GetAllThreadSnapshot:
    CalleeSavedRegistersStub MCC_GetAllThreadSnapshotImpl

    .text
    .align 2
    .global _CJ_MCC_GetCurrentThreadSnapshot
_CJ_MCC_GetCurrentThreadSnapshot:
    CalleeSavedRegistersStub MCC_GetCurrentThreadSnapshotImpl

    .text
    .align 2
    .global _CJ_MCC_AcquireRawData
_CJ_MCC_AcquireRawData:
    CalleeSavedRegistersStub MCC_AcquireRawData

    .text
    .align 2
    .global _CJ_MCC_FutureWait
_CJ_MCC_FutureWait:
    CalleeSavedRegistersStub MRT_FutureWait

    .text
    .align 2
    .global _CJ_MCC_MutexLock
_CJ_MCC_MutexLock:
    CalleeSavedRegistersStub MCC_MutexLock

    .text
    .align 2
    .global _CJ_MCC_MutexLockSlowPath
_CJ_MCC_MutexLockSlowPath:
    CalleeSavedRegistersStub MCC_MutexLockSlowPath

    .text
    .align 2
    .global _CJ_MCC_MonitorWait
_CJ_MCC_MonitorWait:
    CalleeSavedRegistersStub MCC_MonitorWait

    .text
    .align 2
    .global _CJ_MCC_MultiConditionMonitorWait
_CJ_MCC_MultiConditionMonitorWait:
    CalleeSavedRegistersStub MCC_MultiConditionMonitorWait

    .text
    .align 2
    .global _CJ_MRT_Sleep
_CJ_MRT_Sleep:
    CalleeSavedRegistersStub MRT_Sleep

    .text
    .align 2
    .global _CJ_MRT_ThreadWait
_CJ_MRT_ThreadWait:
    CalleeSavedRegistersStub MRT_ThreadWait

    .text
    .align 2
    .global _CJ_MRT_ThreadResumeAndWait
_CJ_MRT_ThreadResumeAndWait:
    CalleeSavedRegistersStub MRT_ThreadResumeAndWait

    .text
    .align 2
    .global _CJ_MRT_ThreadReady
_CJ_MRT_ThreadReady:
    CalleeSavedRegistersStub MRT_ThreadReady

    .text
    .align 2
    .global _CJ_MCC_NewPinnedObject
_CJ_MCC_NewPinnedObject:
    CalleeSavedRegistersStub MCC_NewPinnedObject

    .text
    .align 2
    .global _CJ_MCC_ApplyCJInstanceMethod
_CJ_MCC_ApplyCJInstanceMethod:
    CalleeSavedRegistersStub MCC_ApplyCJInstanceMethod

    .text
    .align 2
    .global _CJ_MCC_ApplyCJStaticMethod
_CJ_MCC_ApplyCJStaticMethod:
    CalleeSavedRegistersStub MCC_ApplyCJStaticMethod

    .text
    .align 2
    .global _CJ_MCC_ApplyCJGenericInstanceMethod
_CJ_MCC_ApplyCJGenericInstanceMethod:
    CalleeSavedRegistersStub MCC_ApplyCJGenericInstanceMethod

.text
    .align 2
    .global _CJ_MCC_ApplyCJGenericStaticMethod
_CJ_MCC_ApplyCJGenericStaticMethod:
    CalleeSavedRegistersStub MCC_ApplyCJGenericStaticMethod

    .text
    .align 2
    .global _CJ_MCC_GetMethodAnnotations
_CJ_MCC_GetMethodAnnotations:
    CalleeSavedRegistersStub MCC_GetMethodAnnotations

    .text
    .align 2
    .global _CJ_MCC_GetInstanceFieldAnnotations
_CJ_MCC_GetInstanceFieldAnnotations:
    CalleeSavedRegistersStub MCC_GetInstanceFieldAnnotations

    .text
    .align 2
    .global _CJ_MCC_GetStaticFieldAnnotations
_CJ_MCC_GetStaticFieldAnnotations:
    CalleeSavedRegistersStub MCC_GetStaticFieldAnnotations

    .text
    .align 2
    .global _CJ_MCC_GetParameterAnnotations
_CJ_MCC_GetParameterAnnotations:
    CalleeSavedRegistersStub MCC_GetParameterAnnotations

    .text
    .align 2
    .global _CJ_MCC_GetTypeInfoAnnotations
_CJ_MCC_GetTypeInfoAnnotations:
    CalleeSavedRegistersStub MCC_GetTypeInfoAnnotations

    .text
    .align 2
    .global _CJ_MCC_GetInstanceFieldValue
_CJ_MCC_GetInstanceFieldValue:
    CalleeSavedRegistersStub MCC_GetInstanceFieldValue

    .text
    .align 2
    .global _CJ_MCC_GetStaticFieldValue
_CJ_MCC_GetStaticFieldValue:
    CalleeSavedRegistersStub MCC_GetStaticFieldValue

    .text
    .align 2
    .global _CJ_MCC_NewArrayGeneric
_CJ_MCC_NewArrayGeneric:
    CalleeSavedRegistersStub MCC_NewArrayGeneric

    .text
    .align 2
    .global _CJ_MCC_DumpCJHeapData
_CJ_MCC_DumpCJHeapData:
    CalleeSavedRegistersStub MCC_DumpCJHeapData

    .text
    .align 2
    .global _CJ_MCC_NewAndInitEnumTupleObject
_CJ_MCC_NewAndInitEnumTupleObject:
    CalleeSavedRegistersStub MCC_NewAndInitEnumTupleObject

    .text
    .align 2
    .global _CJ_MCC_GetAssociatedValues
_CJ_MCC_GetAssociatedValues:
    CalleeSavedRegistersStub MCC_GetAssociatedValues

    .text
    .align 2
    .global _CJ_MCC_StartLocalRegion
_CJ_MCC_StartLocalRegion:
    LocalRegionStub MCC_StartLocalRegion

    .text
    .align 2
    .global _CJ_MCC_EndLocalRegion
_CJ_MCC_EndLocalRegion:
    LocalRegionStub MCC_EndLocalRegion

    .text
    .align 2
    .global _CJ_MCC_NewLocalObject
_CJ_MCC_NewLocalObject:
    CalleeSavedRegistersStub MCC_NewLocalObject

    .text
    .align 2
    .global _CJ_MCC_NewLocalFinalizer
_CJ_MCC_NewLocalFinalizer:
    CalleeSavedRegistersStub MCC_NewLocalFinalizer

    .text
    .align 2
    .global _CJ_MCC_NewLocalArray
_CJ_MCC_NewLocalArray:
    CalleeSavedRegistersStub MCC_NewLocalArray

    .text
    .align 2
    .global _CJ_MCC_NewLocalObjArray
_CJ_MCC_NewLocalObjArray:
    CalleeSavedRegistersStub MCC_NewLocalObjArray

    .text
    .align 2
    .global _CJ_MCC_NewLocalArray8
_CJ_MCC_NewLocalArray8:
    CalleeSavedRegistersStub MCC_NewLocalArray8

    .text
    .align 2
    .global _CJ_MCC_NewLocalArray16
_CJ_MCC_NewLocalArray16:
    CalleeSavedRegistersStub MCC_NewLocalArray16

    .text
    .align 2
    .global _CJ_MCC_NewLocalArray32
_CJ_MCC_NewLocalArray32:
    CalleeSavedRegistersStub MCC_NewLocalArray32

    .text
    .align 2
    .global _CJ_MCC_NewLocalArray64
_CJ_MCC_NewLocalArray64:
    CalleeSavedRegistersStub MCC_NewLocalArray64

    .text
    .align 2
    .global _CJ_MCC_NewLocalGenericObject
_CJ_MCC_NewLocalGenericObject:
    CalleeSavedRegistersStub MCC_NewLocalGenericObject

    .text
    .align 2
    .global _CJ_MCC_NewLocalGenericArray
_CJ_MCC_NewLocalGenericArray:
    CalleeSavedRegistersStub MCC_NewLocalGenericArray

    .text
    .align 2
    .global _CJ_MCC_NewLocalWeakRefObject
_CJ_MCC_NewLocalWeakRefObject:
    CalleeSavedRegistersStub MCC_NewLocalWeakRefObject

.global _unwindPCForC2RStubEnd
_unwindPCForC2RStubEnd:
