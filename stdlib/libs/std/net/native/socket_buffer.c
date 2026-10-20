/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include "socket_buffer.h"
#include <stdatomic.h>
#include <stdbool.h>
#include <stdlib.h>
#include "securec.h"

#ifndef MAX_MALLOC_SIZE
#define MAX_MALLOC_SIZE 2147483647 /* max 2 GB */
#endif

#ifdef __arm__
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Watomic-alignment"
#endif

typedef struct SockBuffer {
    int32_t rBufSize;
    int32_t wBufSize;
    char* rBuf;
    char* wBuf;
    atomic_llong handle;
    atomic_int count;
} SocketBuffer;

extern void* CJ_SOCKET_MallocWithInit(size_t size)
{
    if (size == 0 || size > MAX_MALLOC_SIZE) {
        return NULL;
    }
    return calloc(1, size);
}

extern SocketBuffer* CJ_SOCKET_BufferInit(long long handle, int32_t rBufSize, int32_t wBufSize)
{
    if (handle == -1 || rBufSize <= 0 || wBufSize <= 0) {
        return NULL;
    }
    SocketBuffer* sockBuf = (SocketBuffer*)CJ_SOCKET_MallocWithInit(sizeof(SocketBuffer));
    if (sockBuf == NULL) {
        return NULL;
    }
    sockBuf->rBuf = (char*)CJ_SOCKET_MallocWithInit((size_t)rBufSize);
    if (sockBuf->rBuf == NULL) {
        free(sockBuf);
        return NULL;
    }
    sockBuf->wBuf = (char*)CJ_SOCKET_MallocWithInit((size_t)wBufSize);
    if (sockBuf->wBuf == NULL) {
        free(sockBuf->rBuf);
        free(sockBuf);
        return NULL;
    }
    atomic_init(&sockBuf->handle, handle);
    atomic_init(&sockBuf->count, 1);
    sockBuf->rBufSize = rBufSize;
    sockBuf->wBufSize = wBufSize;
    return sockBuf;
}

static void CJ_SocketFreeWrapperBuffer(SocketBuffer* sockBuf)
{
    char* itemR = sockBuf->rBuf;
    sockBuf->rBuf = NULL;
    sockBuf->rBufSize = 0;
    char* itemW = sockBuf->wBuf;
    sockBuf->wBuf = NULL;
    sockBuf->wBufSize = 0;
    free(itemR);
    free(itemW);
    free(sockBuf);
}

/**
 * Atomically replaces only the socket handle inside the buffer.
 *
 * The previous way of updating the handle (a whole-struct copy from Cangjie:
 * read the SocketBuffer, set handle, write it back) also rewrote the `count`
 * refcount with a stale snapshot. SocketHolder deliberately allows a read{}
 * session (e.g. receiveFrom, which does CJ_SocketIncreaseRef and blocks in
 * recvfrom) to run concurrently with a write{} session (e.g. connect, which
 * calls onHandleReplaced). An IncreaseRef landing between the whole-struct
 * read and write was overwritten by the stale count, so the reader's own
 * DecreaseRef reached 0 and freed the SocketBuffer while the Cangjie socket
 * was still alive: every later operation was use-after-free and the process
 * crashed with heap corruption (SIGSEGV/SIGABRT).
 *
 * Only the handle field is atomic here, so the refcount is never touched.
 */
extern void CJ_SOCKET_BufferSetHandle(SocketBuffer* sockBuf, long long newHandle)
{
    atomic_store_explicit(&sockBuf->handle, newHandle, memory_order_release);
}

static bool CJ_SocketIncreaseRef(SocketBuffer* sockBuf)
{
    int item = atomic_fetch_add(&sockBuf->count, 1);
    long long handle = atomic_load(&sockBuf->handle);
    if (handle == -1 || item == 0) {
        atomic_fetch_sub(&sockBuf->count, 1);
        return true;
    }
    return false;
}

static bool CJ_SocketDecreaseRef(SocketBuffer* sockBuf)
{
    int item = atomic_fetch_sub(&sockBuf->count, 1);
    if (item == 1) {
        atomic_store(&sockBuf->handle, -1);
        CJ_SocketFreeWrapperBuffer(sockBuf);
        return true;
    }
    return false;
}

static int32_t CJ_SOCKET_ClampWindowSize(size_t bufOff, int32_t requestedSize, int32_t bufSize)
{
    if (requestedSize <= 0 || bufSize <= 0) {
        return 0;
    }
    if (bufOff >= (size_t)bufSize) {
        return 0;
    }
    size_t remaining = (size_t)bufSize - bufOff;
    if ((size_t)requestedSize > remaining) {
        return (int32_t)remaining;
    }
    return requestedSize;
}

extern int32_t CJ_SOCKET_BufferRead(
    SocketBuffer* sockBuf, size_t bufOff, int32_t readSize, int64_t timeout, int32_t flags)
{
    if (CJ_SocketIncreaseRef(sockBuf)) {
        return 0;
    }
    long long handle = atomic_load(&sockBuf->handle);
    int32_t maxReadSize = CJ_SOCKET_ClampWindowSize(bufOff, readSize, sockBuf->rBufSize);
    if (maxReadSize == 0) {
        (void)CJ_SocketDecreaseRef(sockBuf);
        return 0;
    }
    int32_t recvLen = 0;
    if (timeout < 0) {
        recvLen = CJ_MRT_SockRecv(handle, (const char*)sockBuf->rBuf + bufOff, (unsigned int)maxReadSize, flags);
    } else {
        recvLen = CJ_MRT_SockRecvTimeout(
            handle, (const char*)sockBuf->rBuf + bufOff, (unsigned int)maxReadSize, flags, (uint64_t)timeout);
    }
    if (CJ_SocketDecreaseRef(sockBuf)) {
        return 0; // This affects subsequent operations. Therefore, return 0 directly.
    }
    return recvLen;
}

extern int32_t CJ_SOCKET_BufferRecvFrom(
    SocketBuffer* sockBuf, size_t bufOff, int32_t readSize, int64_t timeout, struct SockAddr* addr, int32_t flags)
{
    if (CJ_SocketIncreaseRef(sockBuf)) {
        return 0;
    }
    long long handle = atomic_load(&sockBuf->handle);
    int32_t maxReadSize = CJ_SOCKET_ClampWindowSize(bufOff, readSize, sockBuf->rBufSize);
    if (maxReadSize == 0) {
        (void)CJ_SocketDecreaseRef(sockBuf);
        return 0;
    }
    int32_t recvLen = 0;

    recvLen = CJ_MRT_SockRecvfromTimeout(
        handle, (void*)sockBuf->rBuf + bufOff, (unsigned int)maxReadSize, flags, addr, (uint64_t)timeout);

    if (CJ_SocketDecreaseRef(sockBuf)) {
        return 0; // This affects subsequent operations. Therefore, return 0 directly.
    }
    return recvLen;
}

extern int32_t CJ_SOCKET_BufferWrite(
    SocketBuffer* sockBuf, size_t bufOff, int32_t writeSize, int64_t timeout, int32_t flags)
{
    if (CJ_SocketIncreaseRef(sockBuf)) {
        return 0;
    }
    long long handle = atomic_load(&sockBuf->handle);
    int32_t maxWriteSize = CJ_SOCKET_ClampWindowSize(bufOff, writeSize, sockBuf->wBufSize);
    if (maxWriteSize == 0) {
        (void)CJ_SocketDecreaseRef(sockBuf);
        return 0;
    }
    int32_t sendLen = 0;
    if (timeout < 0) {
        sendLen = CJ_MRT_SockSend(handle, (const char*)sockBuf->wBuf + bufOff, (unsigned int)maxWriteSize, flags);
    } else {
        sendLen = CJ_MRT_SockSendTimeout(
            handle, (const char*)sockBuf->wBuf + bufOff, (unsigned int)maxWriteSize, flags, (uint64_t)timeout);
    }
    (void)CJ_SocketDecreaseRef(sockBuf); // The value 0 is not returned because subsequent operations are not affected.
    return sendLen;
}

extern int32_t CJ_SOCKET_BufferSendto(SocketBuffer* sockBuf, size_t bufOff, int32_t writeSize, int64_t timeout,
    const struct SockAddr* addr, int32_t flags)
{
    if (CJ_SocketIncreaseRef(sockBuf)) {
        return 0;
    }
    long long handle = atomic_load(&sockBuf->handle);
    int32_t maxWriteSize = CJ_SOCKET_ClampWindowSize(bufOff, writeSize, sockBuf->wBufSize);
    if (maxWriteSize == 0) {
        (void)CJ_SocketDecreaseRef(sockBuf);
        return 0;
    }
    int32_t sendLen =
        CJ_MRT_SockSendto(handle, (const char*)sockBuf->wBuf + bufOff, (unsigned int)maxWriteSize, flags, addr);

    (void)CJ_SocketDecreaseRef(sockBuf); // The value 0 is not returned because subsequent operations are not affected.
    return sendLen;
}

extern int32_t CJ_SOCKET_BufferRCopy(SocketBuffer* sockBuf, const char* arrBuf, int64_t bufLen, int32_t copyLen)
{
    if (CJ_SocketIncreaseRef(sockBuf) || bufLen <= 0 || copyLen <= 0) {
        return 0;
    }
    if (copyLen > sockBuf->rBufSize || (int64_t)copyLen > bufLen) {
        (void)CJ_SocketDecreaseRef(sockBuf);
        return -1;
    }
    int32_t ret = memcpy_s((void*)arrBuf, (size_t)bufLen, sockBuf->rBuf, (size_t)copyLen);
    (void)CJ_SocketDecreaseRef(sockBuf); // The value 0 is not returned because subsequent operations are not affected.
    if (ret == EOK) {
        return copyLen;
    }
    return -1;
}

extern int32_t CJ_SOCKET_BufferWCopy(SocketBuffer* sockBuf, const char* arrBuf, int64_t bufLen, int32_t copyLen)
{
    if (CJ_SocketIncreaseRef(sockBuf) || bufLen <= 0 || copyLen <= 0) {
        return 0;
    }
    if (copyLen > sockBuf->wBufSize || (int64_t)copyLen > bufLen) {
        if (CJ_SocketDecreaseRef(sockBuf)) {
            return 0;
        }
        return -1;
    }
    int32_t ret = memcpy_s((void*)sockBuf->wBuf, (size_t)sockBuf->wBufSize, arrBuf, (size_t)copyLen);
    if (CJ_SocketDecreaseRef(sockBuf)) {
        return 0; // This affects subsequent operations. Therefore, return 0 directly.
    }
    if (ret == EOK) {
        return copyLen;
    }
    return -1;
}

/**
 * Does close socket and derecare refcount causing memory removal if necessary.
 * The knownHandle different from -1 makes this function only work
 * if the handle is the same (sockBuf.handle = knownHandle)
 * when knownHandle = -1, this function does always do work.
 * After invoking this function, sockBuf.handle is set to -1 (unless knownHandle doesn't match).
 * @return 0 on success, -1 if handle doesn't match
 */
extern int32_t CJ_SOCKET_BufferClose(SocketBuffer* sockBuf, long long knownHandle)
{
    long long handle;
    if (knownHandle == -1) {
        // we always take handle from sockBuf
        handle = atomic_exchange(&sockBuf->handle, -1);
    } else if (!atomic_compare_exchange_strong(&sockBuf->handle, &knownHandle, -1)) {
        return -1; // handle doesn't match so we abort
    } else {
        // handle matches and we got it swapped
        handle = knownHandle;
    }
    if (handle == -1) {
        return 0;
    }
    int32_t ret = CJ_MRT_SockClose(handle);
    (void)CJ_SocketDecreaseRef(sockBuf); // The value 0 is not returned because subsequent operations are not affected.
    return ret;
}

#ifdef __arm__
#pragma GCC diagnostic pop
#endif
