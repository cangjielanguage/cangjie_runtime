/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.net

@C
struct SocketBuffer {
    let rBufSize: Int32 = 0
    let wBufSize: Int32 = 0
    let rBuf: CPointer<Byte> = CPointer<Byte>()
    let wBuf: CPointer<Byte> = CPointer<Byte>()
    var handle: Int64 = -1 // sizeof atomic_llong is 8
    let count: Int32 = 1 // sizeof atomic_int is 4
}

foreign {
    func CJ_SOCKET_BufferInit(handle: Int64, rBufSize: Int32, wBufSize: Int32): CPointer<SocketBuffer>

    func CJ_SOCKET_BufferRead(sockBuf: CPointer<SocketBuffer>, bufOff: UIntNative, readSize: Int32, timeout: Int64,
        flags: Int32): Int32

    func CJ_SOCKET_BufferRecvFrom(sockBuf: CPointer<SocketBuffer>, bufOff: UIntNative, readSize: Int32, timeout: Int64,
        source: CPointer<SockAddr>, flags: Int32): Int32

    func CJ_SOCKET_BufferWrite(sockBuf: CPointer<SocketBuffer>, bufOff: UIntNative, writeSize: Int32, timeout: Int64,
        flags: Int32): Int32

    func CJ_SOCKET_BufferSendto(sockBuf: CPointer<SocketBuffer>, bufOff: UIntNative, writeSize: Int32, timeout: Int64,
        dest: CPointer<SockAddr>, flags: Int32): Int32

    func CJ_SOCKET_BufferRCopy(sockBuf: CPointer<SocketBuffer>, arrBuf: CPointer<Byte>, bufLen: Int64, copyLen: Int32): Int32

    func CJ_SOCKET_BufferWCopy(sockBuf: CPointer<SocketBuffer>, arrBuf: CPointer<Byte>, bufLen: Int64, copyLen: Int32): Int32

    func CJ_SOCKET_BufferClose(sockBuf: CPointer<SocketBuffer>, handle: Int64): Int32

    func CJ_SOCKET_BufferSetHandle(sockBuf: CPointer<SocketBuffer>, newHandle: Int64): Unit
}
