/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@FastNative
foreign func strcmp(source: CPointer<UInt8>, target: CPointer<UInt8>): Int32

@FastNative
foreign func strncmp(source: CPointer<UInt8>, target: CPointer<UInt8>, cmpSize: UIntNative): Int32

@FastNative
foreign func strcasecmp(source: CPointer<UInt8>, target: CPointer<UInt8>): Int32

@Intrinsic
func convertCStr2Ptr(cs: CString): CPointer<UInt8>

@OverflowWrapping
func createStrFromCPointer(cp: CPointer<UInt8>): String {
    if (cp.isNull()) {
        return String()
    }
    var len: Int64 = unsafe { Int64(strlen(cp)) }
    return String(cp, len)
}

@When[env != "ohos"]
@OverflowWrapping
exclave func createStrLocalFromCPointer(cp: CPointer<UInt8>): String @local! {
    if (cp.isNull()) {
        return String()
    }
    var len: Int64 = unsafe { Int64(strlen(cp)) }
    return String(cp, len) @local!
}

extend CString <: ToString {
    public func getChars(): CPointer<UInt8> {
        return convertCStr2Ptr(this)
    }

    public func isNull(): Bool {
        return getChars().isNull()
    }

    public func size(): Int64 {
        let chars = getChars()
        if (chars.isNull()) {
            return 0
        }
        let len = unsafe { strlen(chars) }
        return Int64(len)
    }

    public func isEmpty(): Bool {
        return size() == 0
    }

    public func isNotEmpty(): Bool {
        return !isEmpty()
    }

    public func startsWith(prefix: CString): Bool {
        let chars = getChars()
        if (chars.isNull()) {
            return false
        }
        let prefixChars = prefix.getChars()
        if (prefixChars.isNull()) {
            return false
        }
        let len = unsafe { strlen(chars) }
        let prefixLen = unsafe { strlen(prefixChars) }
        if (len < prefixLen) {
            return false
        }
        let cmpRet = unsafe { CJ_CORE_StringMemcmp(chars, prefixChars, prefixLen) }
        return cmpRet == 0
    }

    public func endsWith(suffix: CString): Bool {
        let chars = getChars()
        if (chars.isNull()) {
            return false
        }
        let suffixChars = suffix.getChars()
        if (suffixChars.isNull()) {
            return false
        }
        let len = unsafe { strlen(chars) }
        let suffixLen = unsafe { strlen(suffixChars) }
        if (len < suffixLen) {
            return false
        }
        let cmpRet = unsafe { strncmp(chars + Int64(len - suffixLen), suffixChars, suffixLen) }
        return cmpRet == 0
    }

    public func equals(other: CString): Bool {
        let chars = getChars()
        let otherChars = other.getChars()
        if (chars.isNull()) {
            return otherChars.isNull()
        }
        if (otherChars.isNull()) {
            return false
        }
        let cmpRet = unsafe { strcmp(chars, otherChars) }
        return cmpRet == 0
    }

    public func equalsLower(other: CString): Bool {
        let chars = getChars()
        let otherChars = other.getChars()
        if (chars.isNull()) {
            return otherChars.isNull()
        }
        if (otherChars.isNull()) {
            return false
        }
        let cmpRet = unsafe { strcasecmp(chars, otherChars) }
        return cmpRet == 0
    }

    /**
     * @throws IndexOutOfBoundsException if beginIndex is greater than the size of string.
     * @throws IllegalMemoryException if memory malloc or memcpy_s fails.
     */
    public func subCString(beginIndex: UIntNative): CString {
        var len = UIntNative(size())
        if (beginIndex > len) {
            throw IndexOutOfBoundsException(
                "Index out of bounds: begin index '${beginIndex}' is greater than CString size '${len}'.")
        }
        return subCString(beginIndex, len - beginIndex)
    }

    /*
     * @throws IndexOutOfBoundsException if beginIndex is greater than the size of string.
     * @throws IllegalMemoryException if memory malloc or memcpy_s fails.
     */
    public func subCString(beginIndex: UIntNative, subLen: UIntNative): CString {
        var buffer = CPointer<UInt8>()
        var len = UIntNative(size())
        if (beginIndex > len) {
            throw IndexOutOfBoundsException(
                "Index out of bounds: begin index '${beginIndex}' is greater than CString size '${len}'.")
        } else if (beginIndex == len || subLen == 0) {
            return CString(buffer)
        }
        var actualLen = len - beginIndex
        if (actualLen > subLen) {
            actualLen = subLen
        }
        unsafe {
            buffer = LibC.malloc(count: Int64(actualLen + 1))
            if (buffer.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in CString::subCString.")
            }
            var rc = memcpy_s(buffer, actualLen + 1, getChars() + Int64(beginIndex), actualLen)

            // The 'actualLen' cannot be guaranteed to be copied to the end. Therefore, '\ 0' cannot be
            // guaranteed by copying 'actualLen + 1'. Therefore, the end needs to be added.
            if (rc != 0) {
                LibC.free(buffer)
                throw IllegalMemoryException("Failed to copy memory in subCString: error code '${rc}'.")
            }
            buffer.write(Int64(actualLen), UInt8(0))
        }
        return CString(buffer)
    }

    /*
     * @throws Exception if self is null or str is null
     */
    public func compare(str: CString): Int32 {
        let chars = getChars()
        if (chars.isNull() || str.isNull()) {
            throw IllegalMemoryException("CString values to compare cannot be null.")
        }
        let ret = unsafe { strcmp(chars, str.getChars()) }
        if (ret > 0) {
            return 1
        }
        if (ret < 0) {
            return -1
        }
        return 0
    }

    /*
     * @throws IllegalMemoryException if memcpy_s fails.
     */
    public func toString(): String {
        let chars = getChars()
        if (chars.isNull()) {
            return String()
        }
        let len = unsafe { Int64(strlen(chars)) }
        if (len == 0) {
            return String()
        }
        let data: Array<UInt8> = Array<UInt8>(len, repeat: 0)
        if (len < STRING_C_THRESHOLD) {
            var i: Int64 = 0
            while (i < len) {
                data[i] = unsafe { chars.read(i) }
                i++
            }
        } else {
            unsafe {
                let rawData: CPointerHandle<UInt8> = acquireArrayRawData(data)
                // If the length of the string is greater than the safe length of the safe function,
                // it needs to be copied multiple times.
                var remain = len
                var offset = 0
                while (remain >= SECUREC_MEM_MAX_LEN) {
                    var rc = memcpy_s(rawData.pointer + offset, UIntNative(SECUREC_MEM_MAX_LEN), chars + offset,
                        UIntNative(SECUREC_MEM_MAX_LEN))
                    if (rc != 0) {
                        releaseArrayRawData(rawData)
                        throw IllegalMemoryException("Failed to copy memory in toString: error code '${rc}'.")
                    }
                    offset += SECUREC_MEM_MAX_LEN
                    remain -= SECUREC_MEM_MAX_LEN
                }
                if (remain > 0) {
                    var rc = memcpy_s(rawData.pointer + offset, UIntNative(remain), chars + offset, UIntNative(remain))
                    if (rc != 0) {
                        releaseArrayRawData(rawData)
                        throw IllegalMemoryException("Failed to copy memory in toString: error code '${rc}'.")
                    }
                }
                releaseArrayRawData(rawData)
            }
        }
        checkInvalid(data.rawptr, data.start, data.start + data.size)
        return String(data)
    }

    public func asResource(): CStringResource {
        return CStringResource(this)
    }
}

public struct CStringResource <: Resource {
    public let value: CString
    private let isFree: Box<Bool> = Box(false)

    init(p: CString) {
        this.value = p
    }

    public func isClosed(): Bool {
        return isFree.value
    }

    public func close(): Unit {
        if (isFree.value) {
            return
        }
        unsafe { LibC.free(value.getChars()) }
        isFree.value = true
    }
}
