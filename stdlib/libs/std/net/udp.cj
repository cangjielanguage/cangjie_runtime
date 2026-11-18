/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.net

/*
 * Represents a UDP datagram socket.
 *
 * Once an instance is created, it is not yet bound so should be bound explicitly via bind().
 * Unlike TCP, a UDP socket may remain unconnected and work without pairing to any remote address handling
 * multiple peers at the same time.
 * However, a UDP socket could be optionally paired via connect() that generally doesn't involve any negotiation so "connecting" to
 * a non-existing address could compelte successfully. A created pairing (after connect invocation) could be terminated via disconnect().
 *
 * UDP protocol does only allow sending and receiving datagrams at most of 64Kib long.
 *
 * Instances of this type should be explicitly closed even when the bind() hasn't been invoked.
 *
 * @see DatagramSocket for more details on how do datagram sockets work.
 */
public class UdpSocket <: DatagramSocket {
    private let impl: SocketCommon<ActualPlatformSocket>

    /**
     * Creates an unbound UDP socket ready to bind at the specified port
     *
     * The default address is 0.0.0.0 what means every IP address of current machine,
     * this is more suitable for a server that can be connected from the local network
     * using localhost address (127.0.0.1) or from outside using corresponding address.
     * Therefore, this address (0.0.0.0) shall not be used as the destination address,
     * so it is necessary to specify an address in a particular network when calling
     * `connect` or `sendTo`. In other words, needs to select the network
     * through which to communicate. Linux, however, able to resolve network on its own,
     * in case of acting with 0.0.0.0 real address resolves in network of other side
     * (source address copies to destination address or vice versa), however,
     * do not rely on it in case of a portable app because windows does not support it.
     */
    public init(bindAt!: UInt16) {
        this(bindAt: IPSocketAddress(IPv4Address.unspecified, bindAt))
    }

    /**
     * Creates an unbound UDP socket ready to bind at the specified interface/port
     */
    public init(bindAt!: SocketAddress) {
        checkAddress(bindAt, "bindAt")
        impl = SocketCommon(SocketNet.UDP, bindAt.family, DatagramMode)
        impl.localAddress = bindAt
    }

    /**
     * Remote address the socket is connected to or `None` if the socket is unconnected.
     *
     * @throws SocketException is the socket is already closed.
     */
    public override prop remoteAddress: ?SocketAddress {
        get() {
            impl.remoteAddress
        }
    }

    /**
     * Local address the socket will be or is currently bound at.
     *
     * @throws SocketException is the socket is already closed.
     */
    public override prop localAddress: SocketAddress {
        get() {
            impl.localAddress ?? SocketException.notYetBoundNeedBind()
        }
    }

    /**
     * Receive/ReceiveFrom operation time limit or `None` for infinite read attempts.
     * The value specified here is actually the minimal amount of time before a read operation cancelled.
     * The actual time is not guaranteed but it will be never cancelled earlier than the specified timeout value.
     * If the duration is too big than it can be bumped to the infinite. When it's too small then if will be bumped to the minimal clock granularity.
     *
     * The default value is None.
     * @throws IllegalArgumentException if the specified timeout duration is negative.
     */
    public override mut prop receiveTimeout: ?Duration {
        get() {
            impl.readTimeout
        }
        set(timeout) {
            impl.readTimeout = timeout?.throwIfNegative("Receive timeout").toNanosecondGranularity()
        }
    }

    /**
     * Send/SendTo operation time limit or `None` for infinite read attempts.
     *
     * The value specified here is actually the minimal amount of time before a write operation cancelled.
     * The actual time is not guaranteed but it will be never cancelled earlier than the specified timeout value.
     * If the duration is too big than it can be bumped to the infinite. When it's too small then if will be bumped to the minimal clock granularity.
     *
     * The default value is None.
     * @throws IllegalArgumentException if the specified timeout duration is negative.
     */
    public override mut prop sendTimeout: ?Duration {
        get() {
            impl.writeTimeout
        }
        set(timeout) {
            impl.writeTimeout = timeout?.throwIfNegative("Send timeout").toNanosecondGranularity()
        }
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
     * Bind UDP socket at local port
     */
    public func bind(): Unit {
        impl.bind(None)
    }

    /**
     * Configure the socket to only work with the specified remote peer address. To undo this action use disconnect()
     * Note that the remote address should always have the same address family as local at which the socket is bound: for example, both IPv4.
     *
     * After invoking this function with a particular address, function send will use the preset address. Functions send/sendTo may throw exceptions if
     * ICMP abnormal responses are recieved. We will also never receive any messages from other peers (they will be just filtered out).
     * Invoking disconnect() reverts the filter to the initial state so it will be possible to send message to any recipients again.
     *
     * This function should be only invoked after bind()
     *
     * @throws IllegalArgumentException if remote address has wrong kind.
     * @throws SocketException if the socket is not bound.
     * @throws SocketException if the connection cannot be established.
     */
    public func connect(remote: SocketAddress): Unit {
        throwIfIPv4ZeroOnWindows(remote)
        checkAddress(remote, "remote")

        if (remote.family != localAddress.family) {
            throw IllegalArgumentException(
                "Invalid argument 'remote': expected same address family as local " +
                    "'${localAddress.family}', got '${remote.family}'.")
        }

        impl.connectToRemote(remote)
    }

    /**
     * Reverts the effect of connect() function so we can send and receive to/from any address again.
     * This function makes no effect if invoked multiple times or if we invoke disconnect without connect invocation.
     */
    public func disconnect(): Unit {
        impl.disconnect()
    }

    /**
     * Receive the next datagram into the specified buffer waiting for data if needed.
     *
     * Returns a pair of the datagram sender address and the actual size of received datagram, possibly zero
     * or a value greater than the passed buffer size.
     *
     * Unlike read in streams, this function requires a buffer of proper size (big enough),
     * otherwise a datagram that is bigger than the provided buffer will be
     * truncated and the returned datagram size will be greater that the buffer size.
     *
     * @throws SocketException if buffer is empty or if it is not possible to read the data.
     * @throws SocketException if not bound or already closed
     * @throws SocketTimeoutException if reading time has expired.
     */
    public override func receiveFrom(buffer: Array<Byte>): (SocketAddress, Int64) {
        impl.receiveFrom(buffer) ?? SocketException.throwClosedException()
    }

    /**
     * Sends datagram of the payload to the specified recipient address.
     *
     * It also may block in this function invocation if there is not enough
     * output buffer space available for some reason. Depending on the underlying
     * implementation, it may also silently discard a datagram in this case.
     *
     * @throws SocketException if payload size is larger than allowed by platform.
     * @throws SocketException if connect was preliminary called and abnormal ICMP was received.
     */
    public override func sendTo(recipient: SocketAddress, payload: Array<Byte>): Unit {
        throwIfIPv4ZeroOnWindows(
            recipient as IPSocketAddress ?? throw IllegalArgumentException(
                "Invalid argument 'recipient': expected same address family as local " +
                    "'${localAddress.family}', got '${recipient.family}'."))

        if (payload.size > 65507) {
            throw SocketException("Cannot send datagram larger than 65507 bytes.")
        }
        if (recipient.family != impl.kind) {
            throw IllegalArgumentException(
                "Invalid argument 'recipient': expected same address family as local " +
                    "'${localAddress.family}', got '${recipient.family}'.")
        }

        impl.send(payload, recipient)
    }

    /**
     * Send a message with the specified payload to the peer with preconfigured address.
     * This only works if address has been specified using `connect() ` otherwise will fail immediately.
     *
     * In other aspects, it works the same as regular `sendTo(recipient,payload).
     *
     * @throws SocketException if not connected, not bound or already closed
     * @throws SocketException if payload size is larger than allowed by platform.
     * @throws SocketException if connect was preliminary called and abnormal ICMP was received.
     */
    public func send(payload: Array<Byte>): Unit {
        if (OS == "macOS") {
            impl.write(payload)
        } else {
            sendTo(remoteAddress ?? SocketException.notYetConnected(), payload)
        }
    }

    /**
     * Receive a datagram message from the preconfigured peer address.
     * This only works if the address has been specified via connect() otherwise will fail.
     * In other aspects, it works the same as regular `receiveFrom(buffer).
     *
     * @throws SocketException if buffer is empty or if it is not possible to read the data.
     * @throws SocketException if not connected, not bound or already closed
     */
    public func receive(buffer: Array<Byte>): Int64 {
        let _ = impl.remoteAddress ?? SocketException.notYetConnected()
        let (_, size) = receiveFrom(buffer)
        return size
    }

    /**
     * When binding socket to a local port, try to reuse it even if it's already used and bound.
     *
     * Please note that there are limitations on when ports could be reused. Behaviour of this option
     * is system-dependant (e.g. this option is unavailable on Windows).
     */
    @When[os != "Windows"]
    public mut prop reusePort: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT)
        }
        set(reuse) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT, reuse)
        }
    }

    @When[os == "Windows"]
    @Deprecated
    public mut prop reusePort: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT)
        }
        set(reuse) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEPORT, reuse)
        }
    }

    /**
     * When binding socket, try to reuse the address even if it's already used and bound. This property configures SO_REUSEADDR.
     * This is especially useful when doing multicasting. Behaviour of this option is system-dependant.
     * Please consult with SO_REUSEADDR/SOCK_REUSEADDR documentation before using.
     */
    public mut prop reuseAddress: Bool {
        get() {
            impl.getSocketOptionBool(SOL_SOCKET, SOCK_REUSEADDR)
        }
        set(reuse) {
            impl.setSocketOptionBool(SOL_SOCKET, SOCK_REUSEADDR, reuse)
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
     * See SocketOptions for popular option constants.
     *
     * Throws an exception if failed (when setsockopt returns -1).
     */
    public func setSocketOption(level: Int32, option: Int32, value: CPointer<Unit>, valueLength: UIntNative): Unit {
        unsafe { impl.setSocketOption(level, option, value, valueLength) }
    }

    /**
     * Read the specified socket option returning it's value as IntNative result.
     *
     * See SocketOptions for popular option constants.
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
     * See SocketOptions for popular option constants.
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
     * See SocketOptions for popular option constants.
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
     * See SocketOptions for popular option constants.
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
        "UdpSocket(${impl.toString()})"
    }

    private static func checkAddress(address: SocketAddress, name: String): SocketAddress {
        if (!(address is IPSocketAddress)) {
            throw IllegalArgumentException(
                "Invalid argument '${name}': expected either IPv4 or IPv6 but got '${address.family}': ${address}.")
        }
        return address
    }
}
