// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// ------------------------------------------------------------------------------
// CJ_MCC_ExclusiveScope
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
//      SysV x86_64: rdi=sret, rsi=fn, rdx=ti, rcx=code, r8=destSp
//      Cangjie call: rdi=sret, rsi=fn, rdx=ti, call *code
//
// Callee-saved NOP: do not clobber rbx/r12–r15. sret/fn/ti stay in arg regs.
// ------------------------------------------------------------------------------

// CJ exclusive stub frame (heap stack):
//   [rbp]     saved rbp | return addr
//
// OS bridge frame:
//   [rbp]  saved rbp = stub FA | return addr = managed caller RA

    .text
    .align 2
    .global CJ_MCC_ExclusiveScope
    .type CJ_MCC_ExclusiveScope, @function
CJ_MCC_ExclusiveScope:
    .cfi_startproc

    pushq   %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register %rbp

    // rdi=sret, rsi=fn, rdx=ti, rcx=code, r8=destSp.

    // Red-zone / align for bridge frame on OS stack, then switch SP.
    subq    $128, %r8
    andq    $-16, %r8
    movq    %r8, %rsp

    // Build OS bridge frame: saved rbp = stub FA; RA = managed caller.
    pushq   8(%rbp)
    pushq   %rbp
    movq    %rsp, %rbp

    // catchResult(sret, fn, ti). rdi/rsi/rdx are already the Cangjie call.
    callq   *%rcx
    // Post-call PC: exclusive bridge identity for IsExclusiveBridgeFrame.
    .global unwindPCForExclusiveStub
unwindPCForExclusiveStub:

    // Tear down bridge frame.
    movq    %rbp, %rsp
    popq    %rbp                    // restore CJ exclusive stub fa into %rbp
    addq    $8, %rsp                // discard bridge return address

    // Restore heap SP (stub FA) and return.
    movq    %rbp, %rsp
    popq    %rbp
    .cfi_def_cfa %rsp, 8
    retq

    .cfi_endproc
    .size CJ_MCC_ExclusiveScope, .-CJ_MCC_ExclusiveScope
