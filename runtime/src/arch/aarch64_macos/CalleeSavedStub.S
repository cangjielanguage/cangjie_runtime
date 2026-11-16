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

.macro CalleeSavedRegistersStub, funcName
    .cfi_startproc
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

    bl   _\funcName
    str  x0,  [sp, #StubCalleeSaveAreaSize+0x48]

    bl   _MRT_GetThreadLocalData
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
    ret
    .cfi_endproc
.endm

.macro LocalRegionStub, funcName
    .cfi_startproc
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
    bl   _\funcName

    bl   _MRT_GetThreadLocalData
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
    ret
    .cfi_endproc
.endm

.macro CalleeSavedRegistersStubNew, funcName
    .cfi_startproc
    ldp  x29, x30, [sp], #16
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

    bl   _\funcName
    str  x0,  [sp, #StubCalleeSaveAreaSize+0x48]

    bl   _MRT_GetThreadLocalData
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
    ret
    .cfi_endproc
.endm



    .global _unwindPCForC2RStubStart
_unwindPCForC2RStubStart:

    .text
    .align 2
    .global _CJ_MCC_NewObject
_CJ_MCC_NewObject:
    CalleeSavedRegistersStubNew MCC_NewObject

    .text
    .align 2
    .global _CJ_MCC_NewWeakRefObject
_CJ_MCC_NewWeakRefObject:
    CalleeSavedRegistersStub MCC_NewWeakRefObject

    .text
    .align 2
    .global _CJ_MCC_NewFinalizer
_CJ_MCC_NewFinalizer:
    CalleeSavedRegistersStubNew MCC_NewFinalizer

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
    .global _CJ_SchedulePreemptCheckStub
_CJ_SchedulePreemptCheckStub:
    CalleeSavedRegistersStub CJ_SchedulePreemptCheck

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
