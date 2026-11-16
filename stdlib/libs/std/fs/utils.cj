/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file The file declares several util functions.
 */
package std.fs

const NULL_BYTE = "\0"
const DOT_CHAR = r'.'
const CURRENT_PATH_STRING = "."
const PATH_MAX_SIZE = 4096

type FileHandle = IntNative

@When[os != "Windows"]
let InvalidHandle: FileHandle = -1

@When[os != "Windows"]
const SLASH_CHAR = "/"

@When[os != "Windows"]
const SLASH_STRING = "/"

@When[os != "Windows"]
const CURRENT_DIRECTORY_STRING = "./"

@When[os != "Windows"]
const ROOT_DIRECTORY_STRING = "/"

@When[os != "Windows"]
const DOS_PATH_SLASH_LOCATION = 0

@When[os != "Windows"]
const UNC_PATH_SLASH_LOCATION = 0

@When[os != "Windows"]
let TMP_DIR = "/tmpDirXXXXXX\0".toArray()

@When[os != "Windows"]
let TMP_FILE = "/tmpFileXXXXXX\0".toArray()

/**
 * Before calling this function, call func checkPath to verify @param path.
 */
@When[env != "ohos" && os != "Windows"]
func isAbsolutePath(path: String @local?): Bool {
    path.size > 0 && isSlash(path[0])
}

@When[env == "ohos" && os != "Windows"]
func isAbsolutePath(path: String): Bool {
    path.size > 0 && isSlash(path[0])
}

@When[os != "Windows"]
func toAbsolutePath(path: Path): Path {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    let raw = path.toString()
    if (isAbsolutePath(raw)) {
        return path
    }
    return canonicalize(Path(CURRENT_PATH_STRING)).join(raw)
}

@When[env != "ohos" && os != "Windows"]
func toAbsolutePath(path: Path @local!): Path @local! {
    exclave {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

        let raw = path._rawPath
        if (isAbsolutePath(raw)) {
            return path
        }
        canonicalize(Path(".") @local!).join(raw)
    }
}

@When[os != "Windows"]
func isSlash(byte: Byte) {
    return byte == b'/'
}

@When[os != "Windows"]
func isRootPath(path: String) {
    return path == "/"
}

@When[os != "Windows"]
func containsSlash(path: String): Bool {
    return path.contains(SLASH_CHAR)
}

@When[os != "Windows"]
func isHandleValid(fileHandle: FileHandle): Bool {
    return fileHandle > 0
}

@When[os != "Windows"]
func skipEndSlash(path: String): Int64 {
    var lastLetterIdx = path.size - 1
    while (lastLetterIdx >= 0 && isSlash(path[lastLetterIdx])) {
        lastLetterIdx--
    }
    return lastLetterIdx
}

@When[os != "Windows"]
func processPathHeader(_: String, canonicalPath: Array<Byte>): String {
    return String.fromUtf8(canonicalPath)
}

@When[env != "ohos" && os != "Windows"]
func processPathHeader(_: String @local?, canonicalPath: Array<Byte> @local!): String @local! {
    exclave {
        String.fromUtf8(canonicalPath)
    }
}

@When[os == "Windows"]
let InvalidHandle: FileHandle = 0

@When[os == "Windows"]
const SLASH_CHAR = "\\"

@When[os == "Windows"]
const SLASH_STRING = "\\"

@When[os == "Windows"]
const CURRENT_DIRECTORY_STRING = ".\\"

@When[os == "Windows"]
const ROOT_DIRECTORY_STRING = "\\"

@When[os == "Windows"]
let TMP_DIR = "\\tmpDirXXXXXX\0".toArray()

@When[os == "Windows"]
let TMP_FILE = "\\tmpFileXXXXXX\0".toArray()

@When[os == "Windows"]
const DOS_PATH_PREFIX = "\\\\?\\"

@When[os == "Windows"]
const UNC_PACH_PREFIX = "\\\\.\\"

@When[os == "Windows"]
func isAbsolutePath(path: String @local?): Bool {
    // The size of path is 3 when path == "[a-z | A-Z]:\\xxxx"
    // "/xxx" or "\\xxx" is absolute path
    ((path.size >= 3) && path[0].isAsciiLetter() && (path[1] == b':') && isSlash(path[2])) ||
        (path.size >= 1 && isSlash(path[0]))
}

@When[os == "Windows"]
func toAbsolutePath(path: Path): Path {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    let raw = path.toString()
    if (isAbsolutePath(raw) || raw.size == 2 && raw[1] == b':') {
        return path
    }
    if (raw.size > 1 && raw[1] == b':') {
        return canonicalize(Path(CURRENT_PATH_STRING)).join(raw[2..])
    }
    return canonicalize(Path(CURRENT_PATH_STRING)).join(raw)
}

@When[env != "ohos" && os == "Windows"]
func toAbsolutePath(path: Path @local!): Path @local! {
    exclave {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

        let raw = path._rawPath
        if (isAbsolutePath(raw) || raw.size == 2 && raw[1] == b':') {
            return path
        }
        if (raw.size > 1 && raw[1] == b':') {
            return canonicalize(Path(".") @local!).join(raw[2..])
        }
        canonicalize(Path(".") @local!).join(raw)
    }
}

@When[os == "Windows"]
func isSlash(c: Rune) {
    return c == r'/' || c == r'\\'
}

@When[os == "Windows"]
func isSlash(b: Byte) {
    return b == b'/' || b == b'\\'
}

@When[os == "Windows"]
func isRootPath(path: String) {
    getRootLen(path) == path.size
}

@When[os == "Windows"]
func containsSlash(path: String): Bool {
    // windows can use r'/' or r'\\', so use r'\\' to convert.
    var tempPath = path.replace("/", SLASH_CHAR)
    return tempPath.contains(SLASH_CHAR)
}

@When[os == "Windows"]
func lastIndexOfSlash(path: String): Option<Int64> {
    // windows can use r'/' or r'\\', so use r'\\' to convert.
    var tempPath = path.replace("/", SLASH_CHAR)
    return tempPath.lastIndexOf(SLASH_CHAR)
}

func getParent(path: String): Path {
    let rootLen = getRootLen(path)
    // skip trailing slashes
    // end point to the first non slash rune from end, or rootLen - 1
    var end = path.size - 1
    while (end >= rootLen) {
        if (!isSlash(path[end])) {
            break
        }
        end--
    }
    // find last slash
    while (end >= rootLen) {
        if (isSlash(path[end])) {
            break
        }
        end--
    }
    // skip ending slashes
    while (end >= rootLen) {
        if (!isSlash(path[end])) {
            break
        }
        end--
    }
    return Path(path[..end + 1])
}

@When[env != "ohos"]
func getParent(path: String @local!): Path @local! {
    exclave {
        let rootLen = getRootLen(path)
        var end = path.size - 1
        while (end >= rootLen) {
            if (!isSlash(path[end])) {
                break
            }
            end--
        }
        while (end >= rootLen) {
            if (isSlash(path[end])) {
                break
            }
            end--
        }
        while (end >= rootLen) {
            if (!isSlash(path[end])) {
                break
            }
            end--
        }
        var sb = StringBuilder() @local!
        sb.append(path[..end + 1])
        Path(sb.toString()) @local!
    }
}

func getFileName(path: String): String {
    let rootLen = getRootLen(path)
    var end = path.size - 1
    while (end >= rootLen) {
        if (!isSlash(path[end])) {
            break
        }
        end--
    }
    var start = end
    while (start >= rootLen) {
        if (isSlash(path[start])) {
            return path[start + 1..end + 1]
        }
        start--
    }
    path[rootLen..end + 1]
}

@When[env != "ohos"]
exclave func getFileName(path: String @local?): String @local! {
    let rootLen = getRootLen(path)
    var end = path.size - 1
    while (end >= rootLen) {
        if (!isSlash(path[end])) {
            break
        }
        end--
    }
    var start = end
    while (start >= rootLen) {
        if (isSlash(path[start])) {
            var sb = StringBuilder() @local!
            sb.append(path[start + 1..end + 1])
            return sb.toString()
        }
        start--
    }
    var sb = StringBuilder() @local!
    sb.append(path[rootLen..end + 1])
    sb.toString()
}

@When[env != "ohos" && os != "Windows"]
func getRootLen(path: String @local?): Int64 {
    if (path.size > 0 && isSlash(path[0])) {
        return 1
    }
    0
}

@When[env == "ohos" && os != "Windows"]
func getRootLen(path: String): Int64 {
    if (path.size > 0 && isSlash(path[0])) {
        return 1
    }
    0
}

@When[os == "Windows"]
func getRootLen(path: String @local?): Int64 {
    let raw = unsafe { path.rawData() }
    // "c:" || "c:\\"
    if (raw.size > 1 && raw[1] == b':') {
        if (raw.size > 2 && isSlash(raw[2])) {
            return 3
        }
        return 2
    }
    // "\\\\?\\UNC\\" || "\\\\.\\UNC\\"
    if (raw.size > 7 && (raw[..8].equalsIgnoreCaseAndSlash("\\\\?\\UNC\\") ||
        raw[..8].equalsIgnoreCaseAndSlash("\\\\.\\UNC\\"))) {
        return countSeparator(raw, idx: 8, cnt: 2)
    }
    // "\\\\?\\" || "\\\\.\\"
    if (raw.size > 3 && (raw[..4].equalsIgnoreCaseAndSlash("\\\\?\\") || raw[..4].equalsIgnoreCaseAndSlash("\\\\.\\"))) {
        return countSeparator(raw, idx: 4, cnt: 1)
    }
    if (isSlash(raw[0])) {
        // "\\\\" UNC path
        if (raw.size > 1 && isSlash(raw[1])) {
            return countSeparator(raw, idx: 2, cnt: 2)
        }
        // "\\"
        return 1
    }
    return 0
}

@When[os == "Windows"]
func countSeparator(path: Array<Byte> @local?, idx!: Int64, cnt!: Int64): Int64 {
    var n = cnt
    for (i in idx..path.size where isSlash(path[i])) {
        n--
        if (n == 0) {
            return i + 1
        }
    }
    return path.size
}

@When[os == "Windows"]
func isHandleValid(fileHandle: FileHandle): Bool {
    return fileHandle != InvalidHandle
}

@When[os == "Windows"]
func skipEndSlash(path: String): Int64 {
    var lastLetterIdx = path.size - 1
    while (lastLetterIdx >= 0 && isSlash(path[lastLetterIdx])) {
        if (lastLetterIdx - 1 >= 0 && path[lastLetterIdx - 1] == b':') {
            break
        }
        lastLetterIdx--
    }
    return lastLetterIdx
}

// DOS device paths : Incoming DOS device paths normalize return DOS device paths
// UNC paths : Incoming UNC paths normalize return UNC paths
// not DOS device paths, not UNC paths
@When[os == "Windows"]
func processPathHeader(rawPath: String, canonicalPath: Array<Byte>): String {
    if (rawPath.startsWith(DOS_PATH_PREFIX)) {
        return String.fromUtf8(canonicalPath)
    } else if (rawPath.startsWith(UNC_PACH_PREFIX)) {
        canonicalPath[2] = b'.'
        return String.fromUtf8(canonicalPath)
    } else {
        return String.fromUtf8(canonicalPath[4..])
    }
}

@When[env != "ohos" && os == "Windows"]
func processPathHeader(rawPath: String @local?, canonicalPath: Array<Byte> @local!): String @local! {
    exclave {
        if (rawPath.startsWith(DOS_PATH_PREFIX)) {
            return String.fromUtf8(canonicalPath)
        } else if (rawPath.startsWith(UNC_PACH_PREFIX)) {
            canonicalPath[2] = b'.'
            return String.fromUtf8(canonicalPath)
        } else {
            return String.fromUtf8(canonicalPath[4..])
        }
    }
}

// Some WIN API do not accept normal path longer than 260 bytes (including the ending '\0').
// So when path is too long, we add "\\\\?\\" to DOS path, "\\\\?\\UNC" to UNC path.
// Meanwhile, we replace '/' with '\\', since some WIN API do not accept long path with both '\\' and '/'.
@When[os == "Windows"]
func fixLongPath(path: String): String {
    if (path.size < 259) {
        return path
    }
    let raw = unsafe { path.rawData() }
    // "c:" || "c:\\"
    if (raw.size > 1 && raw[1] == b':') {
        return concatPath("\\\\?\\", path)
    }
    // "\\\\?\\UNC\\" || "\\\\.\\UNC\\"
    if (raw.size > 7 && (raw[..8].equalsIgnoreCaseAndSlash("\\\\?\\UNC\\") ||
        raw[..8].equalsIgnoreCaseAndSlash("\\\\.\\UNC\\"))) {
        return path
    }
    // "\\\\?\\" || "\\\\.\\"
    if (raw.size > 3 && (raw[..4].equalsIgnoreCaseAndSlash("\\\\?\\") || raw[..4].equalsIgnoreCaseAndSlash("\\\\.\\"))) {
        return path
    }
    if (isSlash(raw[0])) {
        // "\\\\" UNC path
        if (raw.size > 1 && isSlash(raw[1])) {
            return concatPath("\\\\?\\UNC", path[1..])
        }
    }
    return path
}

@When[env != "ohos" && os == "Windows"]
exclave func fixLongPath(path: String @local!): String @local! {
    if (path.size < 259) {
        return path
    }
    let raw = unsafe { path.rawData() }
    // "c:" || "c:\\"
    if (raw.size > 1 && raw[1] == b':') {
        return concatPath("\\\\?\\", path)
    }
    // "\\\\?\\UNC\\" || "\\\\.\\UNC\\"
    if (raw.size > 7 && (raw[..8].equalsIgnoreCaseAndSlash("\\\\?\\UNC\\") ||
        raw[..8].equalsIgnoreCaseAndSlash("\\\\.\\UNC\\"))) {
        return path
    }
    // "\\\\?\\" || "\\\\.\\"
    if (raw.size > 3 && (raw[..4].equalsIgnoreCaseAndSlash("\\\\?\\") || raw[..4].equalsIgnoreCaseAndSlash("\\\\.\\"))) {
        return path
    }
    if (isSlash(raw[0])) {
        // "\\\\" UNC path
        if (raw.size > 1 && isSlash(raw[1])) {
            return concatPath("\\\\?\\UNC", path[1..])
        }
    }
    path
}

@When[os == "Windows"]
func concatPath(prefix: String, old: String): String {
    let new = Array<Byte>(prefix.size + old.size, repeat: 0)
    for (i in 0..prefix.size) {
        new[i] = prefix[i]
    }
    var (oldIdx, newIdx) = (0, prefix.size)
    while (oldIdx < old.size) {
        if (old[oldIdx] == b'/') {
            new[newIdx] = b'\\'
        } else {
            new[newIdx] = old[oldIdx]
        }
        oldIdx++
        newIdx++
    }
    return unsafe { String.fromUtf8Unchecked(new) }
}

@When[env != "ohos" && os == "Windows"]
exclave func concatPath(prefix: String, old: String @local?): String @local! {
    let new: Array<Byte> @local! = Array<Byte>(prefix.size + old.size, repeat: 0)
    for (i in 0..prefix.size) {
        new[i] = prefix[i]
    }
    var (oldIdx, newIdx) = (0, prefix.size)
    while (oldIdx < old.size) {
        if (old[oldIdx] == b'/') {
            new[newIdx] = b'\\'
        } else {
            new[newIdx] = old[oldIdx]
        }
        oldIdx++
        newIdx++
    }
    unsafe { String.fromUtf8Unchecked(new) }
}

@When[os != "Windows"]
func fixLongPath(path: String): String {
    return path
}

@When[env != "ohos" && os != "Windows"]
func fixLongPath(path: String @local?): String @local? {
    path
}

func callNativeFunc(path: String, nativeFunc: CFunc<(CString) -> CPointer<FsError>>, errMsgPrefix: String): Unit {
    unsafe {
        let cPath = LibC.mallocCString(path)
        let resultptr = nativeFunc(cPath)
        if (resultptr.isNull()) {
            LibC.free(cPath)
            throw FSException("Memory allocation failed in native code.")
        }
        let result = resultptr.read()
        LibC.free(resultptr)
        LibC.free(cPath)
        if (result.rtnCode < 0) {
            try {
                let errMessage = result.msg.toString()
                throw FSException("${errMsgPrefix}: error code '${result.rtnCode}', ${errMessage.trimAscii()}.")
            } finally {
                LibC.free(result.msg)
            }
        }
    }
}

func callNativeFunc(
    path1: String,
    path2: String,
    nativeFunction: CFunc<(CString, CString) -> Int8>,
    msg: String
): Unit {
    unsafe {
        try (cPath1 = LibC.mallocCString(path1).asResource(), cPath2 = LibC.mallocCString(path2).asResource()) {
            var ret: Int8 = nativeFunction(cPath1.value, cPath2.value)
            if (ret < 0) {
                throw FSException("${msg} for paths '${path1}' and '${path2}': native function returned error code '${ret}'.")
            }
        }
    }
}

extend Array<Byte> {
    @When[os == "Windows"]
    func equalsIgnoreCaseAndSlash(this @local?, that: String): Bool {
        // size is the same, and not 0
        var (b1, b2): (Byte, Byte)
        for (i in 0..this.size) {
            b1 = this[i]
            b2 = that[i]
            if (isSlash(b1)) {
                if (!isSlash(b2)) {
                    return false
                }
                continue
            }
            if (!byteEqualsIgnoreAsciiCase(b1, b2)) {
                return false
            }
        }
        return true
    }

    func byteEqualsIgnoreAsciiCase(this @local?, b1: Byte, b2: Byte): Bool {
        if (b1 == b2) {
            return true
        }
        // b1 in 'A' ~ 'Z', and the lower case of b1 equals to b2
        if (b1 >= b'A' && b1 <= b'Z' && (b1 + 32) == b2) {
            return true
        }
        if (b2 >= b'A' && b2 <= b'Z' && (b2 + 32) == b1) {
            return true
        }
        return false
    }
}
