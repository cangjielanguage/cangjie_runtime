/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef PROCESS_FFI_UNIX_H
#define PROCESS_FFI_UNIX_H

#include <stdint.h>
#include <sys/types.h>
#include "process_ffi.h"

#ifdef __cplusplus
extern "C" {
#endif

void FreeTwoDimensionalArray(char** strArray);
char** GetCurrentProcessEnvironment(int32_t pid);

/*
 * Non-blocking waitpid(WNOHANG) wrapper used by the timeout-correct
 * SubProcess.wait(timeout:). See process_ffi_unix.c for the contract.
 */
int32_t CJ_OS_WaitSubProcessExitNonBlocking(int32_t pid, int64_t* exitCode);

#ifdef __cplusplus
} // extern "C"
#endif
#endif // PROCESS_FFI_UNIX_H