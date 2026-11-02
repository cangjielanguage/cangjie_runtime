/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This is a library for interface InputStream and OutputStream.
 */
package std.io

const DEFAULT_BUFFER_CAPACITY: Int64 = 4096
/**
 * Represents an input stream of bytes from some source and provides a way to read and consume them.
 *
 * A stream could be created for a file, a network socket or a bytes blob in memory.
 * It could also generate bytes on demand, for example a random bytes stream.
 *
 * Some streams read couldn't be undone: once you read bytes, you can get them back.
 */
public interface InputStream {
    /**
     * Read bytes to the buffer waiting for the incoming data if necessary, at least one byte or report the end.
     *
     * Depending on the underlying implementation it may read as much bytes as possible to fit the buffer size
     * or may only read bytes that are already available.
     * It is not guaranteed that this function reads exact buffer size bytes but it may do.
     *
     * @params buffer where write bytes to
     *
     * @return number of bytes read and copied to the buffer (never zero) or 0 when end of stream reached
     */
    func read(buffer: Array<Byte>): Int64
    @When[env != "ohos"]
    func read(this @local!, buffer: Array<Byte> @local!): Int64 {
        throw Exception()
    }
}

/**
 * This interface is used to construct an output stream.
 */
public interface OutputStream {
    /**
     * Write from buffer to the OutputStream.
     *
     * @params buffer - Will write to the OutputStream from the buffer.
     */
    func write(buffer: Array<Byte>): Unit
    @When[env != "ohos"]
    func write(this @local!, buffer: Array<Byte> @local!): Unit {
        throw Exception()
    }

    /**
     * Flush the OutputStream.
     */
    func flush(): Unit {}
}

/**
 * Represents a duplex stream that is both InputStream and OutputStream.
 */
public interface IOStream <: InputStream & OutputStream {}

/**
 * This interface provides a cursor that can be moved through the stream.
 */
public interface Seekable {
    /**
     * Seek to an offset, in bytes, in a stream.
     *
     * @params sp - Start position of the offset and size of the offset.
     *
     * @return the number of bytes in the stream from the beginning of the data to the cursor position.
     */
    func seek(sp: SeekPosition): Int64
    @When[env != "ohos"]
    func seek(this @local!, sp: SeekPosition): Int64 {
        throw Exception()
    }

    /**
     * @return the position of the current cursor in the stream.
     */
    prop position: Int64 {
        get() {
            seek(Current(0))
        }
    }
    @When[env != "ohos"]
    prop position: Int64 @local! {
        get() {
            exclave {seek(Current(0))}
        }
    }

    /**
     * @return the number of data bytes from the current cursor position to the end of the file.
     */
    prop remainLength: Int64 {
        get() {
            let oldPos = this.seek(Current(0))
            let length = this.seek(End(0))
            if (length != oldPos) {
                this.seek(Begin(oldPos))
            }

            length - oldPos
        }
    }
    @When[env != "ohos"]
    prop remainLength: Int64 @local! {
        get() {
            exclave {
                let oldPos = this.seek(Current(0))
                let length = this.seek(End(0))
                if (length != oldPos) {
                    this.seek(Begin(oldPos))
                }

                length - oldPos
            }
        }
    }

    /**
     * @return the number of bytes from the file header to the file trailer.
     */
    prop length: Int64 {
        get() {
            let oldPos = this.seek(Current(0))
            let length = this.seek(End(0))
            if (length != oldPos) {
                this.seek(Begin(oldPos))
            }

            length
        }
    }
    @When[env != "ohos"]
    prop length: Int64 @local! {
        get() {
            exclave {
                let oldPos = this.seek(Current(0))
                let length = this.seek(End(0))
                if (length != oldPos) {
                    this.seek(Begin(oldPos))
                }

                length
            }
        }
    }
}
