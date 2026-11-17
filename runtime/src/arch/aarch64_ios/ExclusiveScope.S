// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#define cfi_adjust_cfa_offset(off)      .cfi_adjust_cfa_offset off
#define cfi_rel_offset(reg, off)        .cfi_rel_offset reg, off
#define cfi_restore(reg)                .cfi_restore reg
#define cfi_def_cfa_register(reg)       .cfi_def_cfa_register reg

// ------------------------------------------------------------------------------
// _CJ_MCC_ExclusiveScope — AArch64
//
// CodeGen owns pin + protectAddr via CJ_MCC_ExclusiveScopeEnter/Leave and
// only calls this stub when destSp != 0. This stub:
//   1) builds the CJ exclusive stub frame on the heap stack
//   2) switches SP to destSp
//   3) builds the exclusive OS bridge and calls catchResult
//
// protectAddr and exclusiveScopeCnt are owned by Enter/Leave around the invoke.
// Exceptions are caught inside catchResult, so this stub returns normally.
//
// ABI: void _CJ_MCC_ExclusiveScope(void* sret, void* fn, void* ti, void* code, uintptr_t destSp)
//      Entry (LLVM sret): x8=sret, x0=fn, x1=ti, x2=code, x3=destSp
//      Cangjie call: x8=sret, x0=fn, x1=ti, blr code
//
// Callee-saved NOP: do not clobber x19–x28. fn/ti stay in x0/x1.
// ------------------------------------------------------------------------------

// CJ exclusive stub frame (heap stack):
//   [x29+0x00] x29,x30
//
// OS bridge frame:
//   [x29+0x00] saved x29 = stub FA | x30 = managed caller LR

#define ExclusiveScopeFrameSize     16

    .text
    .align 2
    .global _CJ_MCC_ExclusiveScope
    .cfi_sections .debug_frame
_CJ_MCC_ExclusiveScope:
    .cfi_startproc
#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    paciasp
#endif
    stp     x29, x30, [sp, #-ExclusiveScopeFrameSize]!
    cfi_adjust_cfa_offset(ExclusiveScopeFrameSize)
    cfi_rel_offset(x29, 0)
    cfi_rel_offset(x30, 8)
    mov     x29, sp
    cfi_def_cfa_register(x29)

    // x8=sret, x0=fn, x1=ti, x2=code, x3=destSp.

    // Red-zone / align for bridge frame on OS stack, then switch SP.
    sub     x3, x3, #128
    bic     x3, x3, #15
    mov     sp, x3

    // Build OS bridge frame: saved x29 = stub FA; x30 = managed caller LR.
    stp     x29, x30, [sp, #-ExclusiveScopeFrameSize]!
    mov     x29, sp

    // catchResult(sret, fn, ti). x8/x0/x1 already match.
    blr     x2

    // Post-call PC: exclusive bridge identity for IsExclusiveBridgeFrame.
    .global _unwindPCForExclusiveStub
_unwindPCForExclusiveStub:

    // Tear down bridge frame.
    mov     sp, x29
    ldp     x29, x30, [sp], #ExclusiveScopeFrameSize

    // Restore heap SP and return.
    mov     sp, x29
    ldp     x29, x30, [sp], #ExclusiveScopeFrameSize
    cfi_adjust_cfa_offset(-ExclusiveScopeFrameSize)
    cfi_restore(x29)
    cfi_restore(x30)

#if defined(ENABLE_BACKWARD_PTRAUTH_CFI)
    autiasp
#endif
    ret

    .cfi_endproc
