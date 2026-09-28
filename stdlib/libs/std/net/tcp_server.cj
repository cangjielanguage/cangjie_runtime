/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.net

/**
 * TCP server socket providing a way to listen for TCP incoming connections.
 *
 * Once created, could be configured via corresponding properties (e.g. reusePort) or setSocketOptionXX functions.
 *
 * To start listening, use bind() function that does bind socket on a local port and start listening for connections.
 *
 * Receiving an incoming connection is provided via accept() function that does wait for the next connection or returns immediately
 * if there is already pending connection.
 *
 * Instances of this type should be explicitly closed even when the bind() hasn't been invoked.
 */
public class TcpServerSocket <: ServerSocket {
    private let impl: SocketCommon<ActualTcpPlatformSocket>
    private var backlogSize_: Int32 = SOCKET_DEFAULT_BACKLOG

    /**
     * Local address the socket will be or is currently bound at.
     *
     * @throws SocketException is the socket is already closed.
     */
    public override prop localAddress: SocketAddress {
        get() {
            impl.localAddress ?? SocketException.notYetBound()
        }
    }

    /**
     * Creates a TCP server socket that is not yet bound so client can't connects until we do bind()
     * bindAt specifies the local port to bind at or zero to bind at a random free local port
     */
    public init(bindAt!: UInt16) {
        this(bindAt: IPSocketAddress(IPv4Address.unspecified, bindAt))
    }

    /**
     * Creates a TCP server socket that is not yet bound so clients can't connect until we do bind()
     * bindAt specifies the local address to bind at, possibly with zero port to bind at a random free local port
     */
    public init(bindAt!: SocketAddress) {
        checkAddress(bindAt, "bindAt")

        impl = SocketCommon(SocketNet.TCP, bindAt.family, SocketMode.StreamingMode)
        impl.localAddress = bindAt

        setSocketOptionBool(SOL_SOCKET, SOCK_REUSEADDR, true)
    }

    /**
     * When binding socket, try to reuse the address even if it's already used and bound. This property configures SO_REUSEADDR.
     * This is usually makes sense when we are binding and there are still opened connections remaining from the previous socket.
     * Such old sockets are usually hanging in TIME_WAIT state and may prevent us from binding a new server socket.
     * Enabled by default
     * Behaviour of this option is system-dependant. Please consult with SO_REUSEADDR/SOCK_REUSEADDR documentation before using.
     */
    public mut prop reuseAddress: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEADDR)
        }
        set(enabled) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEADDR, enabled)
        }
    }

    /**
     * When binding socket to a local port, try to reuse it even if it's already used and bound.
     *
     * Please note that there are limitations on when ports could be reused. Behaviour of this option
     * is system-dependant (e.g. this option is unavailable on Windows).
     * Please consult with SO_REUSEPORT documentation before using.
     *
     * This option could be only modified before binding and will fail
     * after a successful bind() invocation.
     */
    @When[os != "Windows"]
    public mut prop reusePort: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT)
        }
        set(enabled) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT, enabled)
        }
    }

    @When[os == "Windows"]
    @Deprecated
    public mut prop reusePort: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT)
        }
        set(enabled) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT, enabled)
        }
    }

    /**
     * SO_SNDBUF option, providing a way to specify hint for the underlying
     * native socket implementation about the desired outgoing buffer size.
     *
     * Changing this option is not guaranteed to have any effect since it's
     * completely up to the operating system.
     *
     * Reading this property could also provide non-realistic values on some systems in
     * some cases so no logic should strictly rely on this value.
     *
     * @throws IllegalArgumentException if the specified buffer size is negative or 0.
     */
    public mut prop sendBufferSize: Int64 {
        get() { impl.getSendBufferSize() }
        set(newSize) { impl.setSendBufferSize(newSize) }
    }

    /**
     * SO_RCVBUF option, providing a way to specify hint for the underlying
     * native socket implementation about the desired receive buffer size.
     *
     * Changing this option is not guaranteed to have any effect since it's
     * completely up to the operating system.
     *
     * Reading this property could also provide non-realistic values on some systems in
     * some cases so no logic should strictly rely on this value.
     *
     * @throws IllegalArgumentException if the specified buffer size is negative or 0.
     */
    public mut prop receiveBufferSize: Int64 {
        get() { impl.getReceiveBufferSize() }
        set(newSize) { impl.setReceiveBufferSize(newSize) }
    }

    /**
     * Network interface name to bind to.
     * This option is a hint for the operating system that may decide to ignore the value
     * or reject an attempt to configure it.
     */
    public mut prop bindToDevice: ?String {
        get() {
            impl.bindToDevice
        }
        set(newDevice) {
            impl.bindToDevice = newDevice
        }
    }

    /**
     * Configure incoming connections backlog size. This only works before binding socket.
     * Changing this value is not guaranteed to be actually applied since the operating system may decide to
     * change or bump it, or simply ignore.
     **/
    public mut prop backlogSize: Int64 {
        get() {
            Int64(backlogSize_)
        }
        set(newSize) {
            impl.checkNotBound()
            impl.checkNotClosed()
            backlogSize_ = match {
                case newSize <= 0 => throw IllegalArgumentException("Backlog size must be positive, got '${newSize}'.")
                case newSize >= Int64(Int32.Max) => Int32.Max - 1
                case _ => Int32(newSize)
            }
        }
    }

    /**
     * Bind TCP socket on a local port. Depending on [reusePort] and [reuseAddress] flag, it may fail if the port is already occupied
     * or when there are connections remaining from the previously bound socket.
     * This function also does listen just after binding creating an incoming connections queue that could be accessed via "accept()" function.
     */
    public override func bind(): Unit {
        impl.bind(backlogSize_)
    }

    /**
     * Accept a client TCP socket, waiting for one if there are no pending connection requests.
     *
     * The OS implementation usually provides an incoming connection requests queue (called backlog),
     * so calling accept() does takes a candidate from the queue
     * or wait until we get some request if the queue is empty.
     *
     * Usually, a TCP client is waiting for connection until we get it from server.accept() function. If the server don't
     * get it in time then the client may fail to connect with error (e.g. connection timeout error). If the backlog queue is full
     * due to the missing accept() invocations then the operating system usually start rejecting new incoming connections that don't fit
     * the backlog queue capacity.
     * This fact could be used for backpressure control so if a server detects that no requests could be processed for some reason
     * then it may stop doing accept() to keep client in the queue and limit workload.
     *
     * The specified timeout is applied to accept operation
     * @throws SocketTimeoutException when the specified timeout is over
     * @throws IllegalArgumentException if the specified timeout duration is negative.
     */
    public override func accept(timeout!: ?Duration): TcpSocket {
        let accepted = impl.accept(timeout) ?? SocketException.throwClosedException()
        return TcpSocket(accepted)
    }

    /**
     * Accept a client TCP socket, waiting for one if there are no pending connection requests.
     *
     * The OS implementation usually provides an incoming connection requests queue (called backlog),
     * so calling accept() does takes a candidate from the queue
     * or wait until we get some request if the queue is empty.
     *
     * Usually, a TCP client is waiting for connection until we get it from server.accept() function. If the server don't
     * get it in time then the client may fail to connect with error (e.g. connection timeout error). If the backlog queue is full
     * due to the missing accept() invocations then the operating system usually start rejecting new incoming connections that don't fit
     * the backlog queue capacity.
     * This fact could be used for backpressure control so if a server detects that no requests could be processed for some reason
     * then it may stop doing accept() to keep client in the queue and limit workload.
     */
    public override func accept(): TcpSocket {
        accept(timeout: None)
    }

    /**
     * Close the socket releasing all resources. All operations except for close() and isClose() are no longer available.
     * This function is reentrant.
     **/
    public override func close(): Unit {
        impl.close()
    }

    /**
     * Checks whether this socket has been explicitly closed via close()
     **/
    public override func isClosed(): Bool {
        impl.isClosed()
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
    public func getSocketOption(level: Int32, option: Int32, value: CPointer<Unit>, valueLength: CPointer<UIntNative>): Unit {
        unsafe { impl.getSocketOption(level, option, value, valueLength) }
    }

    /**
     * Write the specified socket option from value buffer having valueLength
     * size in bytes.
     *
     * Throws an exception if failed (when setsockopt returns -1).
     */
    public func setSocketOption(level: Int32, option: Int32, value: CPointer<Unit>, valueLength: UIntNative): Unit {
        unsafe { impl.setSocketOption(level, option, value, valueLength) }
    }

    /**
     * Read the specified socket option returning it's value as IntNative result.
     *
     * Throws an exception if failed (when getsockopt returns -1) or if the result
     * has size different from IntNative.
     */
    public func getSocketOptionIntNative(level: Int32, option: Int32): IntNative {
        impl.getSocketOptionIntNative(level, option)
    }

    /**
     * Write a numeric IntNative value to the specified socket option.
     *
     * Throws an exception if failed (when setsockopt returns -1), for example
     * when the option size is different from IntNative.
     */
    public func setSocketOptionIntNative(level: Int32, option: Int32, value: IntNative): Unit {
        impl.setSocketOptionIntNative(level, option, value)
    }

    /**
     * Read the specified socket option returning it's value as a boolean value
     * converting it from an IntNative.
     *
     * The conversion is defined as 0 => false, other values => true.
     *
     * Throws an exception if failed (when getsockopt returns -1) or if the result
     * has size different from IntNative.
     */
    public func getSocketOptionBool(level: Int32, option: Int32): Bool {
        impl.getSocketOptionBool(level, option)
    }

    /**
     * Write a boolean value to the specified socket option converting it to IntNative.
     *
     * The conversion is defined as false => 0, true => 1
     *
     * Throws an exception if failed (when setsockopt returns -1), for example
     * when the option size is different from IntNative.
     */
    public func setSocketOptionBool(level: Int32, option: Int32, value: Bool): Unit {
        impl.setSocketOptionBool(level, option, value)
    }

    public override func toString(): String {
        "TcpServerSocket(${impl.toString()})"
    }

    private static func checkAddress(address: SocketAddress, name: String): SocketAddress {
        if (!(address is IPSocketAddress)) {
            throw IllegalArgumentException(
                "Invalid argument '${name}': expected either IPv4 or IPv6 but got '${address.family}': ${address}.")
        }
        return address
    }
}
