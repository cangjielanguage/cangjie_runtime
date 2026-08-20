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
 * This file defines zone info reader.
 */

package std.time

import std.binary.*
import std.io.*

// -1: failed, (>= 0): file size
foreign func CJ_TIME_GetFileSize(path: CPointer<Byte>, pathLen: Int64): Int64
// -1: failed, (>= 0): number of read bytes
foreign func CJ_TIME_ReadAllBytesFromFile(path: CPointer<Byte>, pathLen: Int64, buf: CPointer<Byte>, bufLen: Int64): Int64

/**
 * @throws Exception if the length of source is less than or equal to zero
 * @throws InvalidDataException if fileSize is less than zero
 * @throws InvalidDataException if readNum is not equal to fileSize
 * @throws IllegalMemoryException if failed to call loadFromTZData(cjvm).
 */
func loadTimeZone(name: String, source: String): TimeZone {
    return TimeZone.loadFromTZData(name, loadTZifData(name, source))
}

/**
 * @throws Exception if the length of source is less than or equal to zero
 * @throws InvalidDataException if fileSize is less than zero
 * @throws InvalidDataException if readNum is not equal to fileSize
 */
func loadTZifData(name: String, source: String): Array<UInt8> {
    let srcLen = source.size
    if (srcLen <= 0) {
        throw InvalidDataException("invalid timezone source")
    }
    let path = source + SLASH_CHAR + name
    return loadTZifData(path)
}

func loadTZifData(path: String): Array<UInt8> {
    readZoneInfoFile(path, false)
}

func readZoneInfoFile(path: String, keepTerminator: Bool): Array<UInt8> {
    unsafe {
        let cPath: CPointerHandle<UInt8> = acquireArrayRawData(path.rawData())
        let pathLen: Int64 = path.size
        let fileSize = CJ_TIME_GetFileSize(cPath.pointer, pathLen)
        releaseArrayRawData(cPath)
        if (fileSize < 0) {
            throw InvalidDataException("An error occurred when accessing file `${path}`!")
        }
        let bufLen: Int64 = fileSize + 1
        var arr: Array<UInt8> = Array<UInt8>(fileSize + 1, repeat: 0)

        let cPath2: CPointerHandle<UInt8> = acquireArrayRawData(path.rawData())
        var arrPtr: CPointerHandle<UInt8> = acquireArrayRawData(arr)
        var readNum = CJ_TIME_ReadAllBytesFromFile(cPath2.pointer, pathLen, arrPtr.pointer, bufLen)
        releaseArrayRawData(arrPtr)
        releaseArrayRawData(cPath2)
        if (readNum != fileSize) {
            throw InvalidDataException("An error occurred when reading data from file `${path}`!")
        }
        if (keepTerminator) {
            arr
        } else {
            arr.slice(0, fileSize)
        }
    }
}

func loadTimeZoneFromTzData(name: String, source: String): TimeZone {
    return TimeZone.loadFromTZData(name, loadTZData(name, source))
}

func loadTZData(name: String, path: String): Array<UInt8> {
    unsafe {
        let arr = readZoneInfoFile(path, true)
        var buffer = ByteBuffer(arr)
        // do not need the first 12 bytes,so move the buffer's read position forward by 12 bytes to skip them
        buffer.seek(Begin(12))
        // next 4 bytes is the byte offset where the timezone index starts
        var indexOffsetArr = Array<Byte>(4, repeat: 0)
        // next 4 bytes is the byte offset where the actual, concatenated TZif data block begins
        var dataOffsetArr = Array<Byte>(4, repeat: 0)
        buffer.read(indexOffsetArr)
        buffer.read(dataOffsetArr)
        var indexOffset = Int32.readBigEndian(indexOffsetArr)
        var dataOffset = Int32.readBigEndian(dataOffsetArr)
        buffer.seek(Begin(Int64(indexOffset)))

        while (buffer.position < Int64(dataOffset)) {
            // Each timezone ID in the index is stored in a fixed-size 40-byte field
            var tempArr = Array<Byte>(40, repeat: 0)
            buffer.read(tempArr)
            var currentId = String.fromUtf8(tempArr).trimEnd([r"\u{0}"])
            // next 4 bytes is the offset of this specific timezone's data relative to the start of the main data block
            var zoneDataOffsetArr = Array<Byte>(4, repeat: 0)
            // next 4 bytes is the length of this specific timezone's TZif data.
            var zoneDataLengthArr = Array<Byte>(4, repeat: 0)
            buffer.read(zoneDataOffsetArr)
            buffer.read(zoneDataLengthArr)
            // unused 4 bytes,skip
            buffer.seek(Current(4))
            var zoneDataOffset = Int32.readBigEndian(zoneDataOffsetArr)
            var zoneDataLength = Int32.readBigEndian(zoneDataLengthArr)
            if (currentId == name) {
                var zoneData = Array<Byte>(Int64(zoneDataLength), repeat: 0)
                arr.copyTo(zoneData, Int64(dataOffset + zoneDataOffset), 0, Int64(zoneDataLength))
                return zoneData
            }
        }
        throw InvalidDataException("An error occurred when accessing file `${path}`!")
    }
}

/**
 * Parse time zone information formated (TZif) data.
 *
 * @param data TZif data formated with RFC8536.
 * @return a List containing a number of LocalTime, a List containing a number of TransTime and extend zone name.
 *
 * @throws InvalidDataException
 *
 * @since 0.18.4
 */
func parseTZinfoData(data: Array<UInt8>): (Array<LocalTime>, Array<TransTime>, String) {
    var arrReader = ArrReader(data)

    /*
     * Now we start to read and parse header of TZif data.
     * A TZif header is structured as follows (the lengths of multi-octet fields are shown in parentheses):
     * +---------------+---+
     * |  magic    (4) |ver|
     * +---------------+---+---------------------------------------+
     * |           [unused - reserved for future use] (15)         |
     * +---------------+---------------+---------------+-----------+
     * |  isutcnt  (4) |  isstdcnt (4) |  leapcnt  (4) |
     * +---------------+---------------+---------------+
     * |  timecnt  (4) |  typecnt  (4) |  charcnt  (4) |
     * +---------------+---------------+---------------+
     */
    let (isUTCnt, isStdCnt, leapCnt, timeCnt, typeCnt, charCnt) = (0, 1, 2, 3, 4, 5)
    var (version, fields) = parseHeader(arrReader)

    /*
     * If the version of TZif data is 2 or 3, we can only discard the data block of Version 1.
     * In the version 1 data block, time values are 32 bits (TIME_SIZE = 4 octets).
     * The data block is structured as follows (the lengths of multi-octet fields are shown in parentheses):
     * +---------------------------------------------------------+
     * |  transition times          (timecnt x TIME_SIZE)        |
     * +---------------------------------------------------------+
     * |  transition types          (timecnt)                    |
     * +---------------------------------------------------------+
     * |  local time type records   (typecnt x 6)                |
     * +---------------------------------------------------------+
     * |  time zone designations    (charcnt)                    |
     * +---------------------------------------------------------+
     * |  leap-second records       (leapcnt x (TIME_SIZE + 4))  |
     * +---------------------------------------------------------+
     * |  standard/wall indicators  (isstdcnt)                   |
     * +---------------------------------------------------------+
     * |  UT/local indicators       (isutcnt)                    |
     * +---------------------------------------------------------+
     */
    var timeSize = 4
    if (version > 1) {
        arrReader.skip(
            fields[timeCnt] * timeSize + fields[timeCnt] + fields[typeCnt] * 6 + fields[charCnt] + fields[leapCnt] * (4 +
                timeSize) + fields[isStdCnt] + fields[isUTCnt])

        /*
         * In the version 2+ data block, present only in version 2 and 3 files,
         * time values are 64 bits (TIME_SIZE = 8 octets).
         */
        timeSize = 8

        /*
         * Although the version 1 and 2+ headers have the same format, magic number, and version fields,
         * their count fields may differ, because the version 1 data can be a subset of the version 2+ data.
         * So we need to re-read the header to get the right information.
         */
        (version, fields) = parseHeader(arrReader)
    }

    var transTimes = arrReader.getNext(fields[timeCnt] * timeSize)
    var transTypes = arrReader.getNext(fields[timeCnt])
    var typeRecords = arrReader.getNext(fields[typeCnt] * 6)
    var zoneDes = arrReader.getNext(fields[charCnt])
    arrReader.getNext(fields[leapCnt] * (timeSize + 4))
    arrReader.getNext(fields[isStdCnt])
    arrReader.getNext(fields[isUTCnt])

    let zoneNum = fields[typeCnt]
    var zones: Array<LocalTime> = parseZones(zoneNum, typeRecords, zoneDes)
    if (zones.size <= 0) {
        throw InvalidDataException("Failed to parse the timezone file.")
    }
    let timeNum = fields[timeCnt]
    var TransTime: Array<TransTime> = parseZoneTrans(timeNum, zoneNum, transTimes, transTypes, timeSize)

    /*
     * The TZif footer is structured as follows (the lengths of multi-octet fields are shown in parentheses):
     * +---+--------------------+---+
     * | NL|  TZ string (0...)  |NL |
     * +---+--------------------+---+
     */
    var footer = ""
    let last = arrReader.getLast()
    let asciiCodeOfLn: UInt8 = b'\n'
    if (version == 1) {
        if (last.size == 0) {
            return (zones, TransTime, footer)
        }
        throw InvalidDataException("Failed to parse the timezone file.")
    }
    if (last.size > 2 && last[0] == asciiCodeOfLn && last[last.size - 1] == asciiCodeOfLn) {
        footer = itos(last[1..last.size - 1], false)
        if (footer == "") {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
    }
    return (zones, TransTime, footer)
}

func parseHeader(arrReader: ArrReader): (Int64, Array<Int64>) {
    let magic = arrReader.getNext(4)
    if (magic != [b'T', b'Z', b'i', b'f']) {
        throw InvalidDataException("Failed to parse the timezone file.")
    }

    var version: Int64
    match (arrReader.getNext(1)[0]) {
        case b'\0' => version = 1
        case b'2' => version = 2
        case b'3' => version = 3
        case _ => throw InvalidDataException("Failed to parse the timezone file.")
    }
    arrReader.getNext(15) /* Unused 15 bytes */
    return (version, parseFields(arrReader))
}

/**
 * Parses fields except magic and version in the header.
 *
 * @param reader a DataReader need to be parsed fields except magic and version in the header.
 * @param fields an array used to storage fields that parsed by this function.
 * @return true if no anything wrong occured, otherwise false.
 *
 * @throws InvalidDataException
 *
 * @since 0.19.3
 */
@OverflowWrapping
func parseFields(arrReader: ArrReader): Array<Int64> {
    let fields = Array<Int64>(6, repeat: 0)
    let fieldCnt = 6
    for (i in 0..fieldCnt) {
        fields[i] = Int64(Int32((UInt32(arrReader.arr[arrReader.index + 3]) | (UInt32(arrReader.arr[arrReader.index + 2]) <<
            8) | (UInt32(arrReader.arr[arrReader.index + 1]) << 16) | (UInt32(arrReader.arr[arrReader.index]) << 24))))
        arrReader.skip(4) // Jump 4 bytes of one UInt32
    }

    let (isUTCnt, isStdCnt, leapCnt, timeCnt, typeCnt, charCnt) = (0, 1, 2, 3, 4, 5)
    let maxTransitions = 20000
    let maxTypes = 256
    let maxChars = 100000

    if (fields[timeCnt] > maxTransitions) {
        throw InvalidDataException("Failed to parse the timezone file: timeCnt exceeds maximum.")
    }
    if (fields[typeCnt] > maxTypes) {
        throw InvalidDataException("Failed to parse the timezone file: typeCnt exceeds maximum.")
    }
    if (fields[charCnt] > maxChars) {
        throw InvalidDataException("Failed to parse the timezone file: charCnt exceeds maximum.")
    }
    if (fields[leapCnt] > maxTransitions) {
        throw InvalidDataException("Failed to parse the timezone file: leapCnt exceeds maximum.")
    }
    if (fields[isStdCnt] > maxTypes) {
        throw InvalidDataException("Failed to parse the timezone file: isStdCnt exceeds maximum.")
    }
    if (fields[isUTCnt] > maxTypes) {
        throw InvalidDataException("Failed to parse the timezone file: isUTCnt exceeds maximum.")
    }

    return fields
}

/**
 * Parses zones of data block of TZif data. Each record has the following format (the lengths of multi-octet
 * fields are shown in parentheses):
 * +---------------+---+---+
 * |  utoff (4)    |dst|idx|
 * +---------------+---+---+
 *
 * @param zoneNum the number of records, the "typecnt" field in the header.
 * @param typeRecords a series of six-octet records specifying a local time type, which stored in data block of TZif.
 * @param zoneDes a series of octets constituting an array of NUL-terminated (0x00) time zone designation strings,
 * which stored in data block of TZif.
 * @return a Result containing an array of LocalTime parsed from @p typeRecords, or an Exception.
 *
 * @since 0.19.3
 */
@OverflowWrapping
func parseZones(zoneNum: Int64, typeRecords: Array<UInt8>, zoneDes: Array<UInt8>): Array<LocalTime> {
    if (zoneNum <= 0) {
        throw InvalidDataException("Failed to parse the timezone file.")
    }
    var zonedata = ArrReader(typeRecords)
    var zone = Array<LocalTime>(zoneNum, {_ => LocalTime()})
    let minUTOff = -89999
    let maxUTOff = 93599
    for (i in 0..zoneNum) {
        let utoffArr = zonedata.getNext(4)
        let utoff = Int32((UInt32(utoffArr[3])) | (UInt32(utoffArr[2]) << 8) | (UInt32(utoffArr[1]) << 16) | (UInt32(utoffArr[0]) <<
            24))
        if (Int64(utoff) < minUTOff || Int64(utoff) > maxUTOff) {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
        zone[i].offset = utoff
        let dst = (zonedata.getNext(1))[0]
        zone[i].isDST = dst != 0
        let idx = (zonedata.getNext(1))[0]
        if (Int64(idx) >= zoneDes.size) {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
        zone[i].des = itos(zoneDes[Int64(idx)..zoneDes.size], true)
    }
    return zone
}

/*
 * The string returned must be an ASCII string,
 * so we use the unsafe String.fromUtf8Unchecked method.
 * @throws InvalidDataException if failed to parse timezone.
 */
func itos(arr: Array<UInt8>, canNul: Bool): String {
    for (i in 0..arr.size) {
        if (arr[i] == 0x00) {
            if (!canNul) {
                return ""
            }
            return unsafe { String.fromUtf8Unchecked(arr[..i]) }
        }
        if (!arr[i].isAsciiWhiteSpace() && !arr[i].isAsciiGraphic()) {
            throw InvalidDataException(
                "Failed to parse the timezone file, since ${arr[i]} is not a supported ASCII code.")
        }
    }
    return unsafe { String.fromUtf8Unchecked(arr) }
}

/**
 * Parses transition times of data block of TZif data.
 *
 * @param timeNum the number of records, the "timecnt" field in the header.
 * @param zoneNum the number of records, the "typecnt" field in the header.
 * @param transTimes a series of four- or eight-octet UNIX leap-time values sorted in strictly ascending order,
 * which stored in data block of TZif.
 * @param transTypes a series of one-octet unsigned integers specifying the type of local time of the corresponding
 * transition time, which stored in data block of TZif.
 * @param stdInd a series of one-octet values indicating whether the transition times associated with local time
 * types were specified as standard time or wall-clock time, which stored in data block of TZif.
 * @param utInd a series of one-octet values indicating whether the transition times associated with local time
 * types were specified as UT or local time, which stored in data block of TZif.
 * @param is64 a Bool indicates whether each record is four- or eight-byte.
 * @return a Result containing an array of TransTime parsed from @p transTimes, or an Exception.
 *
 * @since 0.19.3
 */
@OverflowWrapping
func parseZoneTrans(
    timeNum: Int64,
    zoneNum: Int64,
    transTimes: Array<UInt8>,
    transTypes: Array<UInt8>,
    timeSize: Int64
): Array<TransTime> {
    var transArr = Array<TransTime>(timeNum, {_ => TransTime()})
    let ttReader = ArrReader(transTimes)
    if (timeNum == 0) {
        return Array<TransTime>(1, repeat: TransTime(Int64.Min, 0))
    }

    var prevTrans: Int64 = Int64.Min
    for (i in 0..timeNum) {
        if (timeSize == 4) {
            let when = ttReader.getNext(4)
            transArr[i].trans = Int64(Int32((UInt32(when[3])) | (UInt32(when[2]) << 8) | (UInt32(when[1]) << 16) | (UInt32(when[0]) <<
                24)))
        } else if (timeSize == 8) {
            let when = ttReader.getNext(8)
            transArr[i].trans = Int64((UInt64(when[7])) | (UInt64(when[6]) << 8) | (UInt64(when[5]) << 16) | (UInt64(when[4]) <<
                24) | (UInt64(when[3]) << 32) | (UInt64(when[2]) << 40) | (UInt64(when[1]) << 48) | (UInt64(when[0]) <<
                56))
        } else {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
        if (Int64(transTypes[i]) >= zoneNum) {
            throw InvalidDataException("Failed to parse the timezone file: transition type index out of range.")
        }
        if (i > 0 && transArr[i].trans <= prevTrans) {
            throw InvalidDataException(
                "Failed to parse the timezone file: transition times must be strictly increasing.")
        }
        prevTrans = transArr[i].trans
        transArr[i].index = transTypes[i]
    }
    return transArr
}

class ArrReader {
    var arr: Array<UInt8>
    var index: Int64 = 0

    init(arr: Array<UInt8>) {
        this.arr = arr
    }

    func skip(len: Int64): Unit {
        index += len
        if (index >= arr.size) {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
    }

    func getNext(len: Int64): Array<UInt8> {
        var subArr = Array<UInt8>()
        try {
            subArr = arr.slice(index, len)
            index += len
        } catch (_) {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
        return subArr
    }

    func getLast(): Array<UInt8> {
        var subArr = Array<UInt8>()
        try {
            subArr = arr.slice(index, arr.size - index)
            index = arr.size
        } catch (_) {
            throw InvalidDataException("Failed to parse the timezone file.")
        }
        return subArr
    }
}
