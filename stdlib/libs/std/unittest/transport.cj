/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.binary.BigEndianOrder
import std.collection.*
import std.io.IOException
import std.net.*
import std.unittest.common.*
import std.env.atExit

/**
 * Timeout on connection between worker and main.
 */
private const CONNECTION_TIMEOUT_S = 10

/**
 * Timeout on message send for worker/main.
 */
private const WRITE_TIMEOUT_S = 10
private let OUTPUT_DELIMITER: String = "\t<-%#&->\t"
private const INT8_BYTES = 8

private class ExecutionResultPartIterator <: Iterator<ExecutionResultPart> {
    ExecutionResultPartIterator(private let socket: TcpSocket, let limit!: ?UInt64 = None) {}

    private func read(size: Int64): ?Array<UInt8> {
        if (size <= 0) {
            return []
        }

        let buffer = Array<UInt8>(size, repeat: 0u8)
        var pointer = 0

        while (let readSize <- socket.read(buffer[pointer..]) && readSize > 0) {
            pointer += readSize
            if (pointer == size) { return buffer }
        }

        if (pointer == 0) { return None }
        if (pointer != size) { throw Exception("Premature end of the stream") }
        return buffer
    }

    private var receivedCount = 0u64

    @OverflowSaturating
    public func next(): ?ExecutionResultPart {
        match (limit) {
            case Some(l) where receivedCount >= l => return None
            case _ => ()
        }
        let resultSizeBytes = try {
            read(INT8_BYTES) ?? return None
        } catch (e: IOException) {
            socket.close()
            return None
        }

        let resultSize = Int64.readBigEndian(resultSizeBytes)

        let dmsBytes = try {
            read(resultSize) ?? return None
        } catch (e: IOException) {
            socket.close()
            return None
        }

        let dms = DataModelStruct.fromJsonBytes(dmsBytes)
        receivedCount++
        return ExecutionResultPart.deserialize(dms)
    }
}

class TransportChannel <: Resource {
    TransportChannel(private let socket: TcpSocket, private let outputReporter: TestOutputReporter,
        private let isMain!: Bool = false) {
        socket.writeTimeout = Duration.second * WRITE_TIMEOUT_S
    }

    public func isClosed() {
        socket.isClosed()
    }

    public func close(): Unit {
        socket.close()
    }

    func send(part: ExecutionResultPart): Unit {
        let payload = part.serializeInternal().asStruct().toJsonBytes()
        let payloadSizeBytes = Array<UInt8>(INT8_BYTES, repeat: 0u8)
        payload.size.writeBigEndian(payloadSizeBytes)
        try {
            socket.write(payloadSizeBytes)
            socket.write(payload)
            socket.flush()
        } catch (e: IOException) {
            close()
        }
    }

    /**
     * @return lazy messages recieved by the channel.
     */
    func receive(limit!: ?UInt64 = None): Iterator<ExecutionResultPart> {
        return ExecutionResultPartIterator(socket, limit: limit)
    }

    func delimitOutput(): Unit {
        if (outputReporter.capture) {
            print(OUTPUT_DELIMITER, flush: true)
            eprint(OUTPUT_DELIMITER, flush: true)
        }
    }
}

enum Transport <: Resource {
    | TChannel(TransportChannel)
    | TMain(TransportMain)

    public func close(): Unit {
        match (this) {
            case TChannel(t) => t.close()
            case TMain(t) => t.close()
        }
    }

    public func isClosed(): Bool {
        match (this) {
            case TChannel(t) => t.isClosed()
            case TMain(t) => t.isClosed()
        }
    }

    prop channel: ?TransportChannel {
        get() {
            match (this) {
                case TChannel(channel) => channel
                case _ => None
            }
        }
    }

    prop manager: ?TransportMain {
        get() {
            match (this) {
                case TMain(manager) => manager
                case _ => None
            }
        }
    }

    static func fromDefaultConfiguration(): Transport {
        let outputReporter = TestOutputReporter.fromDefaultConfiguration()

        let transport = match (TestProcessKind.fromDefaultConfiguration()) {
            case Main => TMain(TransportMain.fromDefaultConfiguration())
            case Worker(_, _, _, port) =>
                let socket = TcpSocket("127.0.0.1", port) // Currently, it's supported to run workers only on local machine.
                socket.connect(timeout: Duration.second * CONNECTION_TIMEOUT_S)
                TChannel(TransportChannel(socket, outputReporter))
        }

        atExit { transport.close() }
        transport
    }
}

class TransportMain <: Resource {
    private TransportMain(private let socket: TcpServerSocket, private let outputReporter: TestOutputReporter) {}

    public func close(): Unit {
        socket.close()
    }

    public func isClosed(): Bool {
        socket.isClosed()
    }

    prop port: UInt16 {
        get() {
            (socket.localAddress as IPSocketAddress).getOrThrow().port
        }
    }

    /**
     * Accepts connection from any worker and return the communication channel with it.
     */
    func accept(): TransportChannel {
        TransportChannel(socket.accept(timeout: Duration.second * CONNECTION_TIMEOUT_S), outputReporter, isMain: true)
    }

    static func fromDefaultConfiguration(): TransportMain {
        let socket = TcpServerSocket(bindAt: 0u16) // Use system-assigned port from the dynamic range.
        socket.bind()
        TransportMain(socket, TestOutputReporter.fromDefaultConfiguration())
    }
}

struct WorkerOutput {
    WorkerOutput(let stdout: Array<Byte>, let stderr: Array<Byte>) {}

    prop stdouts: Array<String> {
        get() {
            stdout.split(OUTPUT_DELIMITER) |> map { it => String.fromUtf8(it) } |> collectArray
        }
    }

    prop stderrs: Array<String> {
        get() {
            stderr.split(OUTPUT_DELIMITER) |> map { it => String.fromUtf8(it) } |> collectArray
        }
    }

    prop captured: Array<CapturedOutput> {
        get() {
            let outs = stdouts
            let errs = stderrs
            if (outs.size != errs.size) {
                throw IllegalStateException("${outs.size} != ${errs.size}")
            }

            outs |> zip(errs) |> map<(String, String), CapturedOutput> { pair =>
                CapturedOutput(pair[0], pair[1])
            } |> collectArray
        }
    }
}
