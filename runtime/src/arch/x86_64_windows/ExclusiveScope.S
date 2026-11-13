// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// ------------------------------------------------------------------------------
// CJ_MCC_ExclusiveScope — Windows x64
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
//      Win64: rcx=sret, rdx=fn, r8=ti, r9=code, destSp at [rbp+0x30]
//      Cangjie call: rcx=sret, rdx=fn, r8=ti, call *code
//
// Callee-saved NOP: do not clobber rbx/rdi/rsi/r12–r15. sret/fn/ti stay in arg regs.
// ------------------------------------------------------------------------------

// CJ exclusive stub frame (heap stack):
//   [rbp]     saved rbp | return addr
//
// OS bridge frame:
//   [rbp]  saved rbp = stub FA | return addr = managed caller RA

    .text
    .p2align 4, 0x90
    .def CJ_MCC_ExclusiveScope
    .scl 2
    .type 32
    .endef
    .global CJ_MCC_ExclusiveScope
CJ_MCC_ExclusiveScope:
    .seh_proc CJ_MCC_ExclusiveScope

    pushq   %rbp
    .seh_pushreg %rbp
    movq    %rsp, %rbp
    .seh_setframe %rbp, 0
    .seh_endprologue

    // rcx=sret, rdx=fn, r8=ti, r9=code. destSp is the fifth arg at 0x30(%rbp).

    // Red-zone / align for bridge frame on OS stack, then switch SP.
    movq    0x30(%rbp), %rax
    subq    $128, %rax
    andq    $-16, %rax
    movq    %rax, %rsp

    // Build OS bridge frame: saved rbp = stub FA; RA = managed caller.
    pushq   8(%rbp)
    pushq   %rbp
    movq    %rsp, %rbp

    // catchResult(sret, fn, ti). rcx/rdx/r8 are already the Cangjie call.
    subq    $32, %rsp
    callq   *%r9
    // Post-call PC: exclusive bridge identity for IsExclusiveBridgeFrame.
    .global unwindPCForExclusiveStub
unwindPCForExclusiveStub:
    addq    $32, %rsp

    // Tear down bridge frame.
    movq    %rbp, %rsp
    popq    %rbp                    // restore CJ exclusive stub fa into %rbp
    addq    $8, %rsp                // discard bridge return address

    // Restore heap SP (stub FA) and return.
    movq    %rbp, %rsp
    popq    %rbp
    retq

    .seh_endproc
