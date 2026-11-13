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
// CJ_MCC_ExclusiveScope — ARM32
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
// ABI: void CJ_MCC_ExclusiveScope(void* sret, void* fn, void* ti, void* code, uintptr_t destSp)
//      ARM32: r0=sret, r1=fn, r2=ti, r3=code, destSp at [r11+16]
//      Cangjie call: r0=sret, r1=fn, r2=ti, blx code
//
// Callee-saved NOP: do not clobber r4–r10. sret/fn/ti stay in arg regs.
// ------------------------------------------------------------------------------

// CJ exclusive stub frame (heap stack):
//   0x00  r11 (fp)
//   0x04  lr
//   0x08  padding
//
// OS bridge frame:
//   0x00  saved r11 = stub FA
//   0x04  lr = managed caller LR
//   0x08  padding
//
// 16-byte SP alignment is required for 128-bit NEON load/store.

#define ExclusiveScopeFrameSize     16

    .text
    .align 2
    .global CJ_MCC_ExclusiveScope
    .type CJ_MCC_ExclusiveScope, %function
CJ_MCC_ExclusiveScope:
    .cfi_startproc
    sub     sp, sp, #ExclusiveScopeFrameSize
    str     r11, [sp, #0]
    str     lr, [sp, #4]
    cfi_adjust_cfa_offset(ExclusiveScopeFrameSize)
    cfi_rel_offset(r11, 0)
    cfi_rel_offset(lr, 4)
    mov     r11, sp
    cfi_def_cfa_register(r11)

    // r0=sret, r1=fn, r2=ti, r3=code. destSp is the fifth arg at [r11+16].

    // Red-zone / align for bridge frame on OS stack, then switch SP.
    ldr     r12, [r11, #16]
    sub     r12, r12, #64
    bic     r12, r12, #15
    mov     sp, r12

    // Build OS bridge frame: saved r11 = stub FA; lr = managed caller LR.
    sub     sp, sp, #ExclusiveScopeFrameSize
    str     r11, [sp, #0]
    str     lr, [sp, #4]
    mov     r11, sp

    // catchResult(sret, fn, ti). r0/r1/r2 are already the Cangjie call.
    blx     r3

    // Post-call PC: exclusive bridge identity for IsExclusiveBridgeFrame.
    .global unwindPCForExclusiveStub
unwindPCForExclusiveStub:

    // Tear down bridge frame.
    mov     sp, r11
    ldr     r11, [sp, #0]
    ldr     lr, [sp, #4]
    add     sp, sp, #ExclusiveScopeFrameSize

    // Restore heap SP and return.
    mov     sp, r11
    ldr     r11, [sp, #0]
    ldr     lr, [sp, #4]
    add     sp, sp, #ExclusiveScopeFrameSize
    cfi_adjust_cfa_offset(-ExclusiveScopeFrameSize)
    cfi_restore(r11)
    cfi_restore(lr)
    bx      lr

    .cfi_endproc
    .size CJ_MCC_ExclusiveScope, .-CJ_MCC_ExclusiveScope
