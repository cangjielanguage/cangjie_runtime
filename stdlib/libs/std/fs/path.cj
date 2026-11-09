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
 * This file defines Path related classes.
 */
package std.fs

public func canonicalize(path: String): Path {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)
    if (!exists(path)) {
        throw FSException("Failed to canonicalize path '${path}': path does not exist or permission denied.")
    }

    return Path(processPathHeader(path, Path.canonicalizePath(path)))
}

@When[env != "ohos"]
public func canonicalize(path: String @local!): Path @local! {
    exclave {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)
        if (!exists(path)) {
            throw FSException("Failed to canonical: the input path `${path}` may not exist or permission denied!")
        }
        Path(processPathHeader(path, Path.canonicalizePath(path))) @local!
    }
}

public func canonicalize(path: Path): Path {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    let rawPath = path.toString()
    if (!exists(rawPath)) {
        throw FSException("Failed to canonicalize path '${path}': path does not exist or permission denied.")
    }
    return Path(processPathHeader(rawPath, Path.canonicalizePath(rawPath)))
}

@When[env != "ohos"]
public func canonicalize(path: Path @local!): Path @local! {
    exclave {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)
        let rawPath = path._rawPath
        if (!exists(rawPath)) {
            throw FSException("Failed to canonical: the input path `${rawPath}` may not exist or permission denied!")
        }
        Path(processPathHeader(rawPath, Path.canonicalizePath(rawPath))) @local!
    }
}

@When[os != "Windows"]
const PATH_SEPARATOR = "/"
@When[os == "Windows"]
const PATH_SEPARATOR = "\\"
@When[os != "Windows"]
const PATH_LISTSEPARATOR = ":"
@When[os == "Windows"]
const PATH_LISTSEPARATOR = ";"
@When[os != "Windows"]
const PATH_SEPARATOR_BYTE = b'/'
@When[os == "Windows"]
const PATH_SEPARATOR_BYTE = b'\\'
@When[os != "Windows"]
const isWindows = false
@When[os == "Windows"]
const isWindows = true

public struct Path <: Equatable<Path> & Hashable & ToString {
    let _rawPath: String

    public static const Separator: String = PATH_SEPARATOR
    public static const ListSeparator: String = PATH_LISTSEPARATOR

    public init(rawPath: String) {
        _rawPath = rawPath
    }
    @When[env != "ohos"]
    public exclave init(this @local!, rawPath: String @local!) {
        _rawPath = rawPath
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public prop parent: Path {
        get() {
            PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
            return getParent(_rawPath)
        }
    }
    @When[env != "ohos"]
    public prop parent: Path @local! {
        get() {
            exclave {
                PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
                getParent(_rawPath)
            }
        }
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public prop fileName: String {
        get() {
            PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
            return getFileName(_rawPath)
        }
    }
    @When[env != "ohos"]
    public prop fileName: String @local? {
        get() {
            exclave {
                PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
                getFileName(_rawPath)
            }
        }
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public prop extensionName: String {
        get() {
            PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
            let name = this.fileName
            if (let Some(dot) <- name.lastIndexOf(b'.')) {
                return name[dot + 1..]
            }
            return ""
        }
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public prop fileNameWithoutExtension: String {
        get() {
            PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
            let name = this.fileName
            if (let Some(dot) <- name.lastIndexOf(b'.')) {
                return name[..dot]
            }
            return name
        }
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public func isAbsolute(): Bool {
        PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
        return isAbsolutePath(_rawPath)
    }
    @When[env != "ohos"]
    public func isAbsolute(this @local?): Bool {
        PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
        isAbsolutePath(_rawPath)
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public func isRelative(): Bool {
        PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)
        return !isAbsolutePath(_rawPath)
    }

    @When[env != "ohos"]
    private func checkWindowsSpecialPrefix(this @local?, path: String @local?): Unit {
        if (!isWindows) {
            return
        }
        let specialPrefix = #"\??\"#
        if (path.size < specialPrefix.size) {
            return
        }
        for (i in 0..(path.size - specialPrefix.size + 1)) {
            var matched = true
            for (j in 0..specialPrefix.size) {
                if (path[i + j] != specialPrefix[j]) {
                    matched = false
                    break
                }
            }
            if (matched) {
                throw IllegalArgumentException("Invalid path '${path}': cannot contain '${specialPrefix}'.")
            }
        }
    }

    @When[env == "ohos"]
    private func checkWindowsSpecialPrefix(path: String): Unit {
        if (!isWindows) {
            return
        }
        let specialPrefix = #"\??\"#
        if (path.contains(specialPrefix)) {
            throw IllegalArgumentException("Invalid path '${path}': cannot contain '${specialPrefix}'.")
        }
    }

    /**
     * @throws IllegalArgumentException while rawpath or path contains null character, or rawpath is empty.
     * @throws FSException if path is an absolute path.
     */
    public func join(path: String): Path {
        PathValidator.throwIfContainsNullByte("path", path, true)
        PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)

        if (path.isEmpty()) {
            if (isSlash(_rawPath[_rawPath.size - 1])) {
                return this
            }
            return Path(String.join([_rawPath, SLASH_STRING]))
        }
        if (isAbsolutePath(path)) {
            throw FSException("Invalid argument 'path': '${path}' cannot be an absolute path.")
        }
        var newPath = if (isSlash(_rawPath[_rawPath.size - 1])) {
            String.join([_rawPath, path])
        } else {
            String.join([_rawPath, path], delimiter: SLASH_STRING)
        }
        checkWindowsSpecialPrefix(newPath)
        return Path(newPath)
    }

    @When[env != "ohos"]
    public func join(this @local!, path: String @local!): Path @local! {
        exclave {
            PathValidator.throwIfContainsNullByte("path", path, true)
            PathValidator.throwIfEmptyOrContainsNullByte("path", _rawPath, false)

            if (path.isEmpty()) {
                if (isSlash(_rawPath[_rawPath.size - 1])) {
                    return this
                }
                var sb = StringBuilder() @local!
                sb.append(_rawPath)
                sb.append(SLASH_STRING)
                return Path(sb.toString()) @local!
            }
            if (isAbsolutePath(path)) {
                throw FSException("The input path `${path}` cannot be an absolute path!")
            }
            var sb = StringBuilder() @local!
            sb.append(_rawPath)
            if (!isSlash(_rawPath[_rawPath.size - 1])) {
                sb.append(SLASH_STRING)
            }
            sb.append(path)
            let newPath = sb.toString()
            checkWindowsSpecialPrefix(newPath)
            Path(newPath) @local!
        }
    }

    /**
     * @throws IllegalArgumentException while path contains null character,
     * or path is empty.
     */
    public func join(path: Path): Path {
        return join(path.toString())
    }

    @When[env != "ohos"]
    public func join(this @local!, path: Path @local!): Path @local! {
        exclave {
            join(path._rawPath)
        }
    }

    public func isEmpty(): Bool {
        _rawPath.isEmpty()
    }
    @When[env != "ohos"]
    public func isEmpty(this @local?): Bool {
        _rawPath.isEmpty()
    }

    private func checkWindowsMiddleVolumeName(path: String): Bool {
        if (!isWindows) {
            return false
        }
        if (let Some(indexOfColon) <- path.indexOf(":")) {
            if (indexOfColon <= 1) {
                return false
            }
            if (let Some(indexOfSeparator) <- path.indexOf("/") && indexOfSeparator < indexOfColon) {
                return true
            }
            if (let Some(indexOfSeparator) <- path.indexOf("\\") && indexOfSeparator < indexOfColon) {
                return true
            }
        }
        return false
    }

    private func checkWindowsLeadingVolumeName(path: String): Bool {
        if (!isWindows) {
            return false
        }
        if (let Some(indexOfColon) <- path.indexOf(":")) {
            if (indexOfColon == 1) {
                return true
            }
        }
        return false
    }

    public func normalize(): Path {
        if (_rawPath.isEmpty()) {
            return Path(".")
        }
        // dst string
        let newPath = Array<Byte>(_rawPath.size, repeat: 0)
        // find root
        var rootLen = getRootLen(_rawPath)
        // normalize root
        for (i in 0..rootLen) {
            if (isSlash(_rawPath[i])) {
                newPath[i] = PATH_SEPARATOR_BYTE
            } else {
                newPath[i] = _rawPath[i]
            }
        }
        // only root
        if (_rawPath.size == rootLen) {
            return unsafe { Path(String.fromUtf8Unchecked(newPath[..rootLen])) }
        }

        var (left, right, newIdx) = (rootLen, rootLen, rootLen)
        // _rawPath[left..right] point to a part between two separators
        while (right < _rawPath.size) {
            // inside a part, just go on
            if (!isSlash(_rawPath[right])) {
                right++
                continue
            }
            // end of a part, process the part
            newIdx = normalizePart(_rawPath[left..right], newPath, right - left, newIdx, rootLen)
            right++
            left = right
        }
        // process the last part
        if (left < right) {
            newIdx = normalizePart(_rawPath[left..right], newPath, right - left, newIdx, rootLen)
        }
        // if the result is empty, return "."
        if (newIdx == 0) {
            return Path(".")
        }
        let newPathString = unsafe { String.fromUtf8Unchecked(newPath[..newIdx]) }
        checkWindowsSpecialPrefix(newPathString)
        if (checkWindowsMiddleVolumeName(_rawPath) && checkWindowsLeadingVolumeName(newPathString)) {
            return Path(".\\${newPathString}")
        }
        return Path(newPathString)
    }

    func normalizePart(part: String, newPath: Array<Byte>, partlen: Int64, newPathIdx: Int64, rootLen: Int64): Int64 {
        var newIdx = newPathIdx
        return match (part) {
            case "" | "." => newPathIdx
            case ".." => processDotDot(newPath, newIdx, rootLen)
            case _ =>
                var newIdx = newPathIdx
                // append a separator
                if (newIdx != rootLen) {
                    newPath[newIdx] = PATH_SEPARATOR_BYTE
                    newIdx++
                }
                unsafe { part.rawData() }.copyTo(newPath, 0, newIdx, partlen)
                newIdx + partlen
        }
    }

    // revert the prev part
    // newIdx point to the next position to be written
    func processDotDot(newPath: Array<Byte>, newIdx: Int64, rootLen: Int64): Int64 {
        if (newIdx == rootLen) {
            // if it's first byte after root, and the root ends with a slash, just ignore the ../ part
            // if there's a leading slash, it must have been writen to newPath
            if (rootLen > 0 && isSlash(newPath[rootLen - 1])) {
                return newIdx
            } else {
                // if it's first byte, and there's no slash before, append .. to newPath
                newPath[newIdx] = b'.'
                newPath[newIdx + 1] = b'.'
                return newIdx + 2
            }
        }
        // find the prev part: newPath[(prev + 1)..newIdx]
        var prev = newIdx - 1
        var skipPrevSlash = false
        while (prev >= rootLen) {
            if (isSlash(newPath[prev])) {
                skipPrevSlash = true
                break
            }
            prev--
        }
        // now prev point to the last separator before prev part
        // if prev part is ".."，append "/.."
        if (prev + 3 == newIdx && newPath[prev + 1] == b'.' && newPath[prev + 2] == b'.') {
            newPath[newIdx] = PATH_SEPARATOR_BYTE
            newPath[newIdx + 1] = b'.'
            newPath[newIdx + 2] = b'.'
            return newIdx + 3
        }
        return if (skipPrevSlash) {
            prev
        } else {
            prev + 1
        }
    }

    public operator func ==(other: Path): Bool {
        this.normalize()._rawPath == other.normalize()._rawPath
    }

    public func hashCode(): Int64 {
        return this.normalize()._rawPath.hashCode()
    }

    public func toString(): String {
        return _rawPath
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        _rawPath.toString()
    }

    /**
     * @throws FSException if cPath is invalid
     */
    static func canonicalizePath(pathStr: String): Array<Byte> {
        unsafe {
            var realPathArr = Array<Byte>(PATH_MAX_SIZE, repeat: 0)
            let cPath = LibC.mallocCString(pathStr)
            var arrPtr: CPointerHandle<Byte> = acquireArrayRawData(realPathArr)
            let resultptr = CJ_FS_NormalizePath(cPath, arrPtr.pointer)
            releaseArrayRawData(arrPtr)
            LibC.free(cPath)
            if (resultptr.isNull()) {
                throw FSException("Memory allocation failed in native code.")
            }
            let result = resultptr.read()
            LibC.free(resultptr)
            let availLen = result.rtnCode
            if (availLen <= 0) {
                try {
                    let errMessage = result.msg.toString()
                    throw FSException("Failed to canonicalize path '${pathStr}': error code '${result.rtnCode}', ${errMessage.trimAscii()}.")
                } finally {
                    LibC.free(result.msg)
                }
            }
            realPathArr.slice(0, availLen)
        }
    }

    @When[env != "ohos"]
    static func canonicalizePath(pathStr: String @local!): Array<Byte> @local! {
        exclave {
            unsafe {
                var realPathArr: Array<Byte> @local! = Array<Byte>(PATH_MAX_SIZE, repeat: 0)
                let cPath = LibC.mallocCString(pathStr)
                let arrPtr: CPointerHandle<Byte> @local? = acquireArrayRawData(realPathArr)
                let resultptr = CJ_FS_NormalizePath(cPath, arrPtr.pointer)
                releaseArrayRawData(arrPtr)
                LibC.free(cPath)
                if (resultptr.isNull()) {
                    throw FSException("Failed malloc in C code!")
                }
                let result = resultptr.read()
                LibC.free(resultptr)
                let availLen = result.rtnCode
                if (availLen <= 0) {
                    try {
                        let errMessage = result.msg.toString()
                        throw FSException("Failed to canonical path `${pathStr}` return ${result.rtnCode}: \"${errMessage.trimAscii()}\".")
                    } finally {
                        LibC.free(result.msg)
                    }
                }
                realPathArr.slice(0, availLen)
            }
        }
    }
}

class PathValidator {
    private init() {} // static class

    @When[env != "ohos"]
    static func throwIfEmpty(name: String, path: String @local?, isInput: Bool): Unit {
        if (path.isEmpty()) {
            throw IllegalArgumentException(generateExceptionMessage(name, "cannot be empty", isInput))
        }
    }

    @When[env == "ohos"]
    static func throwIfEmpty(name: String, path: String, isInput: Bool): Unit {
        if (path.isEmpty()) {
            throw IllegalArgumentException(generateExceptionMessage(name, "cannot be empty", isInput))
        }
    }

    static func throwIfContainsNullByte(name: String, path: String, isInput: Bool): Unit {
        if (path.contains(NULL_BYTE)) {
            throw IllegalArgumentException(generateExceptionMessage(name, "value '${unsafe { path.rawData() }}' contains null character", isInput))
        }
    }

    @When[env != "ohos"]
    static func throwIfContainsNullByte(name: String, path: String @local?, isInput: Bool): Unit {
        for (i in 0..path.size) {
            if (path[i] == 0) {
                let bytes = Array<Byte>(path.size, repeat: 0)
                for (j in 0..path.size) {
                    bytes[j] = path[j]
                }
                throw IllegalArgumentException(
                    generateExceptionMessage(name, "value '${bytes}' contains null character", isInput))
            }
        }
    }

    @When[env != "ohos"]
    static func throwIfEmptyOrContainsNullByte(name: String, path: Path @local?, isInput: Bool): Unit {
        throwIfEmptyOrContainsNullByte(name, path.toString(), isInput)
    }

    @When[env != "ohos"]
    static func throwIfEmptyOrContainsNullByte(name: String, path: String @local?, isInput: Bool): Unit {
        throwIfEmpty(name, path, isInput)
        throwIfContainsNullByte(name, path, isInput)
    }

    @When[env == "ohos"]
    static func throwIfEmptyOrContainsNullByte(name: String, path: String, isInput: Bool): Unit {
        throwIfEmpty(name, path, isInput)
        throwIfContainsNullByte(name, path, isInput)
    }

    @When[env == "ohos"]
    static func throwIfEmptyOrContainsNullByte(name: String, path: Path, isInput: Bool): Unit {
        throwIfEmptyOrContainsNullByte(name, path.toString(), isInput)
    }

    private static func generateExceptionMessage(name: String, postfix: String, isInput: Bool): String {
        let sb = StringBuilder("Invalid argument '")
        sb.append(name)
        sb.append("': ")
        sb.append(postfix)
        sb.append('.')
        return sb.toString()
    }
}
