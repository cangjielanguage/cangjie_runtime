/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.net

import std.sync.*

@When[backend == "cjnative"]
type ActualPlatformSocket = DopraOtherSocketImpl

@When[backend == "cjnative" && os != "Windows"]
type ActualTcpPlatformSocket = DopraTcpSocketImpl

@When[backend == "cjnative" && os == "Windows"]
type ActualTcpPlatformSocket = DopraOtherSocketImpl

// here we repeat the generic instantiation trick to avoid virtual invocation
// for read(), write() and accept()
// so the generic type parameter is also required here
// This type should be never used as generic argument, only as a super-type
abstract class DopraSocketImpl<Self> <: PlatformSocket<Self> where Self <: PlatformSocket<Self> {
    protected var address: ?SockAddr = None // this is used in accept to not allocate it every time
    private var isIPv6 = false
    protected DopraSocketImpl(protected var _handle: AtomicInt64) {}
    protected mut prop handle: Int64 {
        get() {
            _handle.load()
        }
        set(v) {
            _handle.store(v)
        }
    }
    public override func connect(
        localAddress: ?SocketAddress,
        address: SocketAddress,
        timeout: ?Duration
    ): Unit {
        let newHandle = unsafe {
            var cRemote = SockAddr(address)
            let cLocal = try {
                sockAddrOptional(localAddress)
            } catch (e: Exception) {
                cRemote.free()
                throw e
            }
            try {
                match (timeout) {
                    case None => CJ_MRT_SockConnect(handle, cLocal, inout cRemote)
                    case Some(timeout) => CJ_MRT_SockConnectTimeout(handle, cLocal, inout cRemote,
                        toDopraTimeout(timeout))
                }
            } finally {
                cRemote.free()
                if (!cLocal.isNull()) {
                    cLocal.read().free()
                }
                LibC.free(cLocal)
            }
        }

        if (newHandle == -1) {
            socketProcessErrno(ErrnoLabel.Connect)
        }

        this.handle = newHandle
        onHandleReplaced(newHandle)
    }

    protected func onHandleReplaced(newHandle: Int64): Unit

    private unsafe func sockAddrOptional(addr: ?SocketAddress): CPointer<SockAddr> {
        match (addr) {
            case Some(addr) =>
                let ptr = LibC.malloc<SockAddr>()
                if (ptr.isNull()) {
                    throw SocketException("Memory malloc failed.")
                }
                ptr.write(SockAddr(addr))
                return ptr
            case None => return CPointer()
        }
    }

    public override func disconnect(): Unit {
        let rc = unsafe { CJ_MRT_SockDisconnect(handle, isIPv6) }
        if (rc != 0) {
            throw SocketException("Socket disconnect() failed.")
        }
    }

    public override func bindListen(
        address: SocketAddress,
        backlogSize: ?Int32,
        ignoreAlreadyBound!: Bool
    ): Unit {
        match {
            case address.family == AddressFamily.INET6 => this.isIPv6 = true
            case _ => ()
        }
        unsafe {
            var cLocal = LibC.malloc<SockAddr>()
            if (cLocal.isNull()) {
                throw SocketException("Memory malloc failed.")
            }
            cLocal.write(SockAddr(address))

            let newHandle = try {
                CJ_MRT_SockBind(handle, cLocal, backlogSize ?? -1)
            } finally {
                if (cLocal.isNotNull()) {
                    let buffer = cLocal.read()
                    buffer.free()
                    LibC.free(cLocal)
                }
            }

            if (newHandle == -1) {
                if (isSocketErrorInvalidArgument(getSocketError()) && ignoreAlreadyBound) {
                    return
                }
                socketProcessErrno(ErrnoLabel.Bind)
            } else {
                this.handle = newHandle
                onHandleReplaced(newHandle)
            }
        }
    }

    protected func acceptImpl(timeout: ?Duration): (Int64, SocketNet) {
        var address = ensureAddress()

        unsafe {
            let accepted = match (timeout) {
                case Some(timeout) => CJ_MRT_SockAcceptTimeout(handle, inout address, toDopraTimeout(timeout))
                case None => CJ_MRT_SockAccept(handle, inout address)
            }

            if (accepted == -1) {
                socketProcessErrno(ErrnoLabel.Accept)
            }

            let net = match {
                case address.family == AF_UNIX => SocketNet.UNIX
                case _ => SocketNet.TCP
            }

            return (accepted, net)
        }
    }

    private func ensureAddress(): SockAddr {
        // we don't need any synchronization here because accept() can't be invoked concurrently
        // that is guarded in SocketCommon
        match (this.address) {
            case Some(address) => address
            case None => createAddress() // slowpath
        }
    }

    private func createAddress(): SockAddr {
        let new = SockAddr()
        this.address = new
        new
    }

    public open override func shutdown(): Unit {
        // we don't need special synchronization here because nether shutdown
        // nor dispose are never invoked concurrently
        unsafe { CJ_MRT_SockShutdown(handle) }
    }

    public override func detectLocalAddress(): ?SocketAddress {
        getLocalAddress(handle)
    }

    public override func detectRemoteAddress(): ?SocketAddress {
        getRemoteAddress(handle)
    }

    /**
     * Read the specified socket option writing the result to value buffer
     * of the specified valueLength (in bytes).
     * Before invoking this function valueLength should be initialized with the buffer size
     * After invoking this function valueLength will contain the actual result
     * size in bytes.
     *
     * Throws an exception if failed (when getsockopt returns -1).
     */
    public override unsafe func getSocketOption(
        level: Int32,
        option: Int32,
        value: CPointer<Unit>,
        valueLength: CPointer<UIntNative>
    ): Unit {
        if (valueLength.isNull()) {
            throw SocketException("Null pointer check failed.")
        }

        let length32 = LibC.malloc<Int32>()
        if (length32.isNull()) {
            throw SocketException("Failed to allocate memory.")
        }
        length32.write((Int32(valueLength.read())))

        let rc = CJ_SockOptionGet(handle, level, option, value, length32)
        valueLength.write(UIntNative(length32.read()))
        LibC.free(length32)

        if (rc != 0) {
            let message = formatError(CJ_SockErrnoGet())
            throw SocketException("Failed to get socket option '${option}': ${message}.")
        }
    }

    /**
     * Write the specified socket option from value buffer having valueLength
     * size in bytes.
     *
     * Throws an exception if failed (when setsockopt returns -1).
     */
    public override unsafe func setSocketOption(
        level: Int32,
        option: Int32,
        value: CPointer<Unit>,
        valueLength: UIntNative
    ): Unit {
        let rc = CJ_SockOptionSet(handle, level, option, value, Int32(valueLength))
        if (rc != 0) {
            let message = formatError(CJ_SockErrnoGet())
            throw SocketException("Failed to set socket option '${option}': ${message}.")
        }
    }

    /**
     * Read the specified socket option returning it's value as IntNative result.
     *
     * Throws an exception if failed (when getsockopt returns -1) or if the result
     * has size different from IntNative.
     */
    public override func getSocketOptionIntNative(
        level: Int32,
        option: Int32
    ): IntNative {
        unsafe {
            let rc = IntNative(CJ_GetOptionInt(handle, level, option))
            if (rc == -1) {
                let message = formatError(CJ_SockErrnoGet())
                throw SocketException("Failed to get socket option '${option}': ${message}.")
            }
            return rc
        }
    }

    /**
     * Write a numeric IntNative value to the specified socket option.
     *
     * Throws an exception if failed (when setsockopt returns -1), for example
     * when the option size is different from IntNative.
     */
    public override func setSocketOptionIntNative(
        level: Int32,
        option: Int32,
        value: IntNative
    ): Unit {
        unsafe {
            let rc = CJ_SetOptionInt(handle, level, option, Int32(value))
            if (rc != 0) {
                let message = formatError(CJ_SockErrnoGet())
                throw SocketException("Failed to set socket option '${option}': ${message}.")
            }
        }
    }

    public override func setKeepAlive(config: ?SocketKeepAliveConfig): Bool {
        if (let Some(_) <- tryConfigureKeepAlive(config)) {
            return false
        }

        return true
    }

    private func tryConfigureKeepAlive(keepAliveConf: ?SocketKeepAliveConfig): ?Int32 {
        let cfg = match (keepAliveConf) {
            case Some(keepAliveConf) =>
                let idle = keepAliveConf.idle.toSeconds().toUInt32In(min: 1)
                let interval = keepAliveConf.interval.toSeconds().toUInt32In(min: 1)

                SockKeepAliveCfgS(keep_alive: 1, idle: idle, interval: interval, count: keepAliveConf.count)
            case None => SockKeepAliveCfgS(keep_alive: 0, idle: 0, interval: 0, count: 0)
        }

        unsafe {
            let pConfig = LibC.malloc<SockKeepAliveCfgS>()
            if (pConfig.isNull()) {
                throw SocketException("Failed to malloc SockKeepAliveCfgS.")
            }
            pConfig.write(cfg)
            let retCode = CJ_SockKeepAliveSet(handle, pConfig)
            LibC.free(pConfig)

            if (retCode != 0) {
                return CJ_SockErrnoGet()
            }
        }

        return None
    }

    // we can't make it abstract so we have to implement it
    // it should be never invoked
    public static redef func create(
        _: SocketNet,
        _: AddressFamily,
        _: SocketMode
    ): Self {
        throw Exception("Internal error: this method should never be invoked.")
    }

    protected static func createSocket(
        net: SocketNet,
        kind: AddressFamily,
        mode: SocketMode
    ): Int64 {
        let sockType = match (mode) {
            case StreamingMode => SocketType.STREAM
            case DatagramMode => SocketType.DATAGRAM
            case SequentialMode => throw SocketException("SEQ_PACK is not supported.")
        }
        let domain = match {
            case kind == AddressFamily.INET => SocketDomain.IPV4
            case kind == AddressFamily.INET6 => SocketDomain.IPV6
            case kind == AddressFamily.UNIX => SocketDomain.UNIX
            case _ => throw SocketException("Unsupported kind: '${kind}'.")
        }
        unsafe {
            try (netName = LibC.mallocCString(net.toString()).asResource()) {
                if (netName.value.isNull()) {
                    throw SocketException("MallocCString failed.")
                }
                let handle = CJ_MRT_SockCreate(domain.val, sockType.val, ProtocolType.Unspecified.val, netName.value)
                if (handle == -1) {
                    socketProcessErrno(ErrnoLabel.CreateSock)
                }

                return handle
            }
        }

        throw Exception("Internal error: unreachable!")
    }

    static func toDopraTimeout(timeout: Duration): UInt64 {
        UInt64(timeout.toNanoseconds()).atLeast(1) // timeout of zero is not allowed on Dopra
    }
}

// Specialized version of socket impl for TCP. Should be never used for other types.
// Doesn't support send/receive, only read/write
class DopraTcpSocketImpl <: DopraSocketImpl<DopraTcpSocketImpl> {
    private init(_handle: AtomicInt64) {
        super(_handle)
    }

    public override func write(buffer: Array<Byte>, timeout: ?Duration): Unit {
        let written = match (writeImpl(buffer, 0)) {
            case BytesTransferred(count) => Int64(count)
            case EOF | RetryAgain => 0
        }

        if (written == buffer.size) {
            return
        }

        writeSlowpath(buffer, timeout, written)
    }

    @OverflowWrapping
    private func writeImpl(buffer: Array<Byte>, offset: Int64): DopraAsyncResult {
        let bytesRemaining = buffer.size - offset
        let batchSize = match {
            case bytesRemaining <= 0 => return DopraAsyncResult.BytesTransferred(0)
            case bytesRemaining > Int64(Int32.Max) => Int32.Max
            case _ => Int32(bytesRemaining)
        }

        unsafe {
            let handleTmp = handle
            let bufCp = acquireArrayRawData(buffer)
            let written = CJ_MRT_SockSendNonBlock(handleTmp, bufCp.pointer + offset, UInt32(batchSize), 0)
            releaseArrayRawData(bufCp)

            match {
                case written >= 0 => BytesTransferred(UInt32(written))
                case CJ_SockErrnoGet() == ERRNO_SOCK_EAGAIN => RetryAgain
                case _ => socketProcessErrno(ErrnoLabel.Write)
            }
        }
    }

    private func writeSlowpath(buffer: Array<Byte>, timeout: ?Duration, writtenBefore: Int64): Unit {
        var bytesWritten = writtenBefore
        while (bytesWritten < buffer.size) {
            unsafe {
                match (writeImpl(buffer, bytesWritten)) {
                    case EOF => socketProcessErrno(ErrnoLabel.Write)
                    case BytesTransferred(count) =>
                        bytesWritten += Int64(count)
                        continue
                    case RetryAgain => ()
                }

                let waitCode = match (timeout) {
                    case None => CJ_MRT_SockWaitSend(handle)
                    case Some(timeout) => CJ_MRT_SockWaitSendTimeout(handle, toDopraTimeout(timeout))
                }

                if (waitCode == 0) {
                    continue
                } else {
                    socketProcessErrno(ErrnoLabel.Write)
                }
            }
        }
    }

    public override func read(buffer: Array<UInt8>, timeout: ?Duration): ?Int64 {
        match (readImpl(buffer)) {
            case EOF => None
            case BytesTransferred(bytesRead) => Int64(bytesRead)
            case RetryAgain => readSlowpath(buffer, timeout)
        }
    }

    @OverflowWrapping
    private func readImpl(buffer: Array<UInt8>): DopraAsyncResult {
        unsafe {
            let handleTmp = handle
            let size: Int32 = if (buffer.size > Int64(Int32.Max)) {
                Int32.Max
            } else {
                Int32(buffer.size)
            }

            let bufCp = acquireArrayRawData(buffer)
            let result = CJ_MRT_SockRecvNonBlock(handleTmp, bufCp.pointer, UInt32(size), 0)
            releaseArrayRawData(bufCp)

            match {
                case result > 0 => DopraAsyncResult.BytesTransferred(UInt32(result))
                case result == 0 => DopraAsyncResult.EOF
                case CJ_SockErrnoGet() == ERRNO_SOCK_EAGAIN => DopraAsyncResult.RetryAgain
                case _ => socketProcessErrno(ErrnoLabel.Read)
            }
        }
    }

    private func readSlowpath(buffer: Array<UInt8>, timeout: ?Duration): ?Int64 {
        var readLen: UInt32 = 0

        while (true) {
            unsafe {
                match (readImpl(buffer)) {
                    case EOF => return None
                    case BytesTransferred(count) =>
                        readLen = count
                        break
                    case RetryAgain => ()
                }
                let waitCode = match (timeout) {
                    case None => CJ_MRT_SockWaitRecv(handle)
                    case Some(timeout) => CJ_MRT_SockWaitRecvTimeout(handle, toDopraTimeout(timeout))
                }

                if (waitCode != 0) {
                    socketProcessErrno(ErrnoLabel.Read)
                }
            }
        }

        return Int64(readLen)
    }

    public override func accept(timeout: ?Duration): ?DopraTcpSocketImpl {
        let (h, _) = acceptImpl(timeout)
        return DopraTcpSocketImpl(AtomicInt64(h))
    }

    public override func send(_: Array<Byte>, _: ?Duration, _: SocketAddress): Int64 {
        throw UnsupportedException()
    }

    public override func receiveFrom(_: Array<UInt8>, _: ?Duration): ?(SocketAddress, Int64) {
        throw UnsupportedException()
    }

    public override unsafe func dispose(): Unit {
        address?.free()
        CJ_MRT_SockClose(handle)
        handle = -1
    }

    protected override func onHandleReplaced(_: Int64): Unit {}

    public static redef func create(
        net: SocketNet,
        kind: AddressFamily,
        mode: SocketMode
    ): DopraTcpSocketImpl {
        return DopraTcpSocketImpl(AtomicInt64(createSocket(net, kind, mode)))
    }
}

class DopraOtherSocketImpl <: DopraSocketImpl<DopraOtherSocketImpl> {
    private let socketBufferPtr: CPointer<SocketBuffer>

    private init(
        socketBufferPtr: CPointer<SocketBuffer>,
        _handle: AtomicInt64
    ) {
        super(_handle)
        this.socketBufferPtr = socketBufferPtr
    }

    public override func write(buffer: Array<Byte>, timeout: ?Duration): Unit {
        let writeSize = buffer.size
        var writeToBufferSize: Int64 = 0
        while (writeToBufferSize < writeSize) {
            let bufferOnceSize: Int64 = if (writeSize - writeToBufferSize < Int64(SOCK_WRITE_BUFFER_SIZE)) {
                writeSize - writeToBufferSize
            } else {
                Int64(SOCK_WRITE_BUFFER_SIZE)
            }
            var copyLen: Int32 = 0
            unsafe {
                let bufCp = acquireArrayRawData(buffer)
                // bufCp.pointer copy to socketBufferPtr
                copyLen = CJ_SOCKET_BufferWCopy(socketBufferPtr, bufCp.pointer + writeToBufferSize,
                    Int64(SOCK_WRITE_BUFFER_SIZE), Int32(bufferOnceSize))
                releaseArrayRawData(bufCp)
            }
            if (copyLen == 0) {
                SocketException.throwClosedException()
            } else if (copyLen < 0) {
                throw SocketException("Failed to write data: socket copy error.")
            }
            writeToBufferSize += bufferOnceSize
            var bufferSentSize: Int64 = 0
            while (bufferSentSize < bufferOnceSize) {
                let timeoutNano = timeout?.toNanoseconds() ?? -1
                let writeLen = unsafe {
                    CJ_SOCKET_BufferWrite(socketBufferPtr, UIntNative(bufferSentSize),
                        Int32(bufferOnceSize - bufferSentSize), timeoutNano, 0)
                }
                if (writeLen == 0) {
                    SocketException.throwClosedException()
                } else if (writeLen < 0) {
                    socketProcessErrno(ErrnoLabel.Write)
                }
                bufferSentSize += Int64(writeLen)
            }
        }
    }

    public override func read(buffer: Array<UInt8>, timeout: ?Duration): ?Int64 {
        let timeoutNano = timeout?.toNanoseconds() ?? -1
        let readLen: Int32 = unsafe { CJ_SOCKET_BufferRead(socketBufferPtr, 0, Int32(buffer.size), timeoutNano, 0) } // offset 0
        if (readLen < 0) {
            socketProcessErrno(ErrnoLabel.Read)
        }
        if (readLen == 0) {
            return 0
        } else {
            var copyLen: Int32 = 0
            unsafe {
                let bufCp = acquireArrayRawData(buffer)
                // socketBufferPtr copy to bufCp.pointer
                copyLen = CJ_SOCKET_BufferRCopy(socketBufferPtr, bufCp.pointer, buffer.size, readLen)
                releaseArrayRawData(bufCp)
            }
            if (copyLen == 0) {
                return None
            } else if (copyLen < 0) {
                throw SocketException("Failed to read data: socket copy error.")
            }
            return Int64(copyLen)
        }
    }

    public override func accept(timeout: ?Duration): ?DopraOtherSocketImpl {
        let (h, net) = acceptImpl(timeout)
        let buffer = try {
            createBuffer(h, net)
        } catch (e: Exception) {
            unsafe { CJ_MRT_SockClose(h) }
            throw e
        }
        return DopraOtherSocketImpl(buffer, AtomicInt64(h))
    }

    public override func receiveFrom(buffer: Array<UInt8>, timeout: ?Duration): ?(SocketAddress, Int64) {
        if (buffer.size == 0) {
            throw SocketException("The buffer is empty.")
        }
        let (address, readLen) = unsafe {
            var addr = SockAddr()
            try {
                let timeoutNano = timeout?.toNanoseconds() ?? -1
                let r = CJ_SOCKET_BufferRecvFrom(socketBufferPtr, 0, Int32(buffer.size), timeoutNano, inout addr, 0)
                if (r < 0) {
                    socketProcessErrno(ErrnoLabel.Read)
                }
                // Can not get address if timeout
                (addr.toSocketAddress(), r)
            } finally {
                addr.free()
            }
        }

        var copyLen: Int32 = 0
        unsafe {
            let bufCp = acquireArrayRawData(buffer)

            // socketBufferPtr copy to bufCp.pointer
            copyLen = CJ_SOCKET_BufferRCopy(socketBufferPtr, bufCp.pointer, buffer.size, readLen)
            releaseArrayRawData(bufCp)
            if (copyLen < 0) {
                throw SocketException("Failed to receive data: socket copy error.")
            }
        }

        return (address, Int64(readLen))
    }

    public override func send(buffer: Array<Byte>, timeout: ?Duration, destination: SocketAddress): Int64 {
        var copyLen: Int32 = 0
        unsafe {
            let bufCp = acquireArrayRawData(buffer)
            // bufCp.pointer copy to socketBufferPtr
            copyLen = CJ_SOCKET_BufferWCopy(socketBufferPtr, bufCp.pointer, Int64(SOCK_WRITE_BUFFER_SIZE),
                Int32(buffer.size))
            releaseArrayRawData(bufCp)
        }
        if (copyLen == 0) {
            SocketException.throwClosedException()
        } else if (copyLen < 0) {
            throw SocketException("Failed to write data: socket copy error.")
        } else {
            let writeLen = unsafe {
                var addr = SockAddr(destination)

                let timeoutNano = timeout?.toNanoseconds() ?? -1
                let r = CJ_SOCKET_BufferSendto(socketBufferPtr, 0, Int32(buffer.size), timeoutNano, inout addr, 0)
                addr.free()
                r
            }

            if (writeLen < 0) {
                socketProcessErrno(ErrnoLabel.Write)
            }

            return Int64(writeLen)
        }
    }

    public override func shutdown(): Unit {
        super.shutdown()
    }

    public override unsafe func dispose(): Unit {
        address?.free()
        CJ_SOCKET_BufferClose(socketBufferPtr, handle) // does CJ_MRT_SockClose inside
    }

    public static redef func create(
        net: SocketNet,
        kind: AddressFamily,
        mode: SocketMode
    ): DopraOtherSocketImpl {
        let handle = createSocket(net, kind, mode)
        let buffer = try {
            createBuffer(handle, net)
        } catch (e: Exception) {
            unsafe { CJ_MRT_SockClose(handle) }
            throw e
        }

        return DopraOtherSocketImpl(buffer, AtomicInt64(handle))
    }

    private static func createBuffer(handle: Int64, net: SocketNet): CPointer<SocketBuffer> {
        let readBufferSize = match (net) {
            case TCP => SOCK_READ_BUFFER_SIZE
            case UDP | UNIX => 0xffffi32
        }
        let writeBufferSize = match (net) {
            case TCP => SOCK_WRITE_BUFFER_SIZE
            case UDP | UNIX => 0xffffi32
        }

        let buffer = unsafe { CJ_SOCKET_BufferInit(handle, readBufferSize, writeBufferSize) }
        if (buffer.isNull()) {
            throw SocketException("Failed to create socket buffer.")
        }

        return buffer
    }

    protected override func onHandleReplaced(newHandle: Int64): Unit {
        // Replace ONLY the handle field, atomically. The previous implementation
        // copied the whole SocketBuffer C struct (read -> set handle -> write
        // back), which also rewrote the `count` REFCOUNT with a stale snapshot.
        // SocketHolder allows a read{} session (receiveFrom: native
        // CJ_SocketIncreaseRef, possibly blocked in recvfrom) to run concurrently
        // with this write{} session (connect): an increment landing between the
        // whole-struct read and write was silently discarded, so the reader's own
        // CJ_SocketDecreaseRef then freed the SocketBuffer while this socket was
        // still alive. Every subsequent operation was use-after-free and the
        // process crashed with heap corruption (SIGSEGV/SIGABRT).
        unsafe { CJ_SOCKET_BufferSetHandle(socketBufferPtr, newHandle) }
    }
}

enum DopraAsyncResult {
    | BytesTransferred(UInt32)
    | RetryAgain
    | EOF
}
