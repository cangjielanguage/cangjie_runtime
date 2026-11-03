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
 * This file defines some utility functions.
 */

package std.io

let BLOCK_SIZE = 4096

/**
 * SeekPosition  is the position of the cursor in the file.
 */
public enum SeekPosition {
    | Current(Int64) /* < current position. */
    | Begin(Int64) /* < begin position of the file. */
    | End(Int64) /* < end position of the file. */
}

public func readString<T>(from: T): String where T <: InputStream & Seekable {
    var data = Array<Byte>(from.remainLength, repeat: 0)
    return try {
        from.read(data)
        String.fromUtf8(data)
    } catch (e: IllegalArgumentException) {
        throw ContentFormatException(e.message)
    }
}

public unsafe func readStringUnchecked<T>(from: T): String where T <: InputStream & Seekable {
    var data = Array<Byte>(from.remainLength, repeat: 0)
    from.read(data)
    String.fromUtf8Unchecked(data)
}

public func readToEnd<T>(from: T): Array<Byte> where T <: InputStream & Seekable {
    let sum = from.length
    const MAX_DIRECT_ALLOC_SIZE: Int64 = 1 << 30  // 1 GB
    if (sum <= 0 || sum > MAX_DIRECT_ALLOC_SIZE) {
        let tempSize: Int64 = BLOCK_SIZE
        let temp: Array<Byte> = Array<Byte>(tempSize, repeat: 0)
        var buffer: ByteBuffer = ByteBuffer(tempSize)

        while (true) {
            let readLen = from.read(temp)
            if (readLen == 0) {
                break
            } else if (readLen == tempSize) {
                buffer.write(temp)
            } else {
                buffer.write(temp.slice(0, readLen))
            }
        }

        var res: Array<Byte> = Array<Byte>(buffer.length, repeat: 0)
        buffer.read(res)
        return res
    }

    let arr: Array<Byte> = Array<Byte>(sum, repeat: 0)
    let onceMax = 1 << 30
    var readSize = 0
    var emptySize = arr.size
    while (readSize < sum) {
        let oneSize = if (emptySize > onceMax) {
            onceMax
        } else {
            emptySize
        }

        let len = from.read(arr.slice(readSize, oneSize))
        if (len == 0) {
            break
        }
        readSize += len
        emptySize -= len
    }

    arr.slice(0, readSize)
}

@When[env != "ohos"]
public exclave func readToEnd<T>(from: T @local!): Array<Byte> @local! where T <: InputStream & Seekable {
    let sum = from.length
    const MAX_DIRECT_ALLOC_SIZE: Int64 = 1 << 30  // 1 GB
    if (sum <= 0 || sum > MAX_DIRECT_ALLOC_SIZE) {
        let tempSize: Int64 = BLOCK_SIZE
        let temp: Array<Byte> @local! = Array<Byte>(tempSize, repeat: 0)
        var buffer: ByteBuffer @local! = ByteBuffer(tempSize)

        while (true) {
            let readLen = from.read(temp)
            if (readLen == 0) {
                break
            } else if (readLen == tempSize) {
                buffer.write(temp)
            } else {
                buffer.write(temp.slice(0, readLen))
            }
        }

        var res: Array<Byte> @local! = Array<Byte>(buffer.length, repeat: 0)
        buffer.read(res)
        return res
    }

    let arr: Array<Byte> @local! = Array<Byte>(sum, repeat: 0)
    let onceMax = 1 << 30
    var readSize = 0
    var emptySize = arr.size
    while (readSize < sum) {
        let oneSize = if (emptySize > onceMax) {
            onceMax
        } else {
            emptySize
        }

        let len = from.read(arr.slice(readSize, oneSize))
        if (len == 0) {
            break
        }
        readSize += len
        emptySize -= len
    }

    arr.slice(0, readSize)
}

public func copy(from: InputStream, to!: OutputStream): Int64 {
    let tempArr = Array<Byte>(BLOCK_SIZE, repeat: 0)
    var readCount = 0
    while (true) {
        let readRet = from.read(tempArr)
        if (readRet > 0) {
            to.write(tempArr.slice(0, readRet))
        } else {
            break
        }
        readCount += readRet
    }

    readCount
}
