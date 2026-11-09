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
 * This file defines FileInfo classes.
 */
package std.fs

import std.time.*

public struct FileInfo <: Equatable<FileInfo> {
    var _path: Path

    public init(path: Path) {
        this(path, true)
    }
    @When[env != "ohos"]
    public exclave init(this @local!, path: Path @local!) {
        this(path, true)
    }

    public init(path: String) {
        this(Path(path), true)
    }
    @When[env != "ohos"]
    public exclave init(this @local!, path: String @local!) {
        this(Path(path) @local!, true)
    }

    /**
     * @throws FSException if path is invalid
     */
    init(path: Path, isCheckPath: Bool) {
        if (isCheckPath && !exists(path)) {
            throw FSException("Invalid argument 'path': '${path}' does not exist.")
        }
        _path = toAbsolutePath(path)
    }
    @When[env != "ohos"]
    exclave init(this @local!, path: Path @local!, isCheckPath: Bool) {
        if (isCheckPath && !exists(path)) {
            throw FSException("The input path `${path}` does not exist.")
        }
        _path = toAbsolutePath(path)
    }

    public prop name: String {
        get() {
            _path.fileName
        }
    }
    @When[env != "ohos"]
    public prop name: String @local? {
        get() {
            exclave {
                _path.fileName
            }
        }
    }

    public prop parentDirectory: Option<FileInfo> {
        get() {
            let parent = _path.parent
            if (!parent.toString().isEmpty() && !isRootPath(_path.toString())) {
                return FileInfo(parent)
            }
            return None
        }
    }

    public prop path: Path {
        get() {
            _path
        }
    }
    @When[env != "ohos"]
    public prop path: Path @local? {
        get() {
            _path
        }
    }

    /**
     * @throws FSException if system failed to get creation time
     */
    public prop creationTime: DateTime {
        get() {
            let time = callNativeFunc(CJ_FS_GetCreationTime, "Failed to get creation time.")
            return DateTime.ofEpoch(second: time, nanosecond: 0)
        }
    }

    /**
     * @throws FSException if system failed to get last access time
     */
    public prop lastAccessTime: DateTime {
        get() {
            let time = callNativeFunc(CJ_FS_GetLastAccessTime, "Failed to get last access time.")
            return DateTime.ofEpoch(second: time, nanosecond: 0)
        }
    }

    /**
     * @throws FSException if system failed to get last modification time
     */
    public prop lastModificationTime: DateTime {
        get() {
            let time = callNativeFunc(CJ_FS_GetLastModificationTime, "Failed to get last modification time.")
            return DateTime.ofEpoch(second: time, nanosecond: 0)
        }
    }

    /**
     * @throws FSException if memory copy failed or get directory/file size failed
     */
    public prop size: Int64 {
        get() {
            return callNativeFunc(CJ_FS_PathSize, "Failed to get file size.")
        }
    }
    @When[env != "ohos"]
    public prop size: Int64 @local? {
        get() {
            callNativeFunc(CJ_FS_PathSize, "Failed to get file size.")
        }
    }

    /**
     * @throws FSException if cPath is invalid or symbol not linked
     */
    public func isSymbolicLink(): Bool {
        return callNativeFunc(CJ_FS_IsLink)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func isRegular(): Bool {
        return callNativeFunc(CJ_FS_IsFile)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func isDirectory(): Bool {
        return callNativeFunc(CJ_FS_IsDir)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func isReadOnly(): Bool {
        return callNativeFunc(CJ_FS_IsReadOnly)
    }

    public func isHidden(): Bool {
        let fileName = canonicalize(_path).fileName
        if (fileName.isEmpty()) {
            throw FSException("File name is empty.")
        }
        return fileName[0] == b'.'
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func canExecute(): Bool {
        // _wstat in implementation do not accept "\\\\?\\" as it's argument
        return callNativeFunc(CJ_FS_CanExecute, shouldFixLongPath: false)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func canRead(): Bool {
        return callNativeFunc(CJ_FS_CanRead)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    public func canWrite(): Bool {
        return callNativeFunc(CJ_FS_CanWrite)
    }

    /**
     * @throws FSException if cPath is invalid
     * @throws FSException if operation not permitted on Windows
     * Processes running as a privileged user may bypass this permission setting.
     */
    public func setExecutable(executable: Bool): Bool {
        return callNativeFunc(CJ_FS_SetExecutable, executable)
    }

    /**
     * @throws FSException if cPath is invalid
     * @throws FSException if operation not permitted on Windows
     * Processes running as a privileged user may bypass this permission setting.
     */
    public func setReadable(readable: Bool): Bool {
        return callNativeFunc(CJ_FS_SetReadable, readable)
    }

    /**
     * @throws FSException if cPath is invalid
     * @throws FSException if operation not permitted on Windows
     */
    public func setWritable(writable: Bool): Bool {
        // _wstat in implementation do not accept "\\\\?\\" as it's argument
        return callNativeFunc(CJ_FS_SetWritable, writable, shouldFixLongPath: false)
    }

    /**
     * @throws FSException if cPath is invalid
     */
    @When[env != "ohos"]
    private func callNativeFunc(this @local?, nativeFunction: CFunc<(CString) -> Int8>, shouldFixLongPath!: Bool = true): Bool {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath = LibC.mallocCString(pathStr)
            var ret: Int8 = nativeFunction(cPath)
            LibC.free(cPath)
            if (ret < 0) {
                throw FSException("Native function error return ${ret}.")
            }
            return ret > 0
        }
    }

    @When[env == "ohos"]
    private func callNativeFunc(nativeFunction: CFunc<(CString) -> Int8>, shouldFixLongPath!: Bool = true): Bool {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath = LibC.mallocCString(pathStr)
            var ret: Int8 = nativeFunction(cPath)
            LibC.free(cPath)
            if (ret < 0) {
                throw FSException("Failed to get file information for '${pathStr}': native function returned '${ret}'.")
            }
            return ret > 0
        }
    }

    /**
     * @throws FSException if cPath is invalid
     * @throws FSException if operation not permitted on Windows
     */
    @When[env != "ohos"]
    private func callNativeFunc(this @local?, nativeFunction: CFunc<(CString, Bool) -> Int8>, flag: Bool,
        shouldFixLongPath!: Bool = true): Bool {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath = LibC.mallocCString(pathStr)
            let ret: Int8 = nativeFunction(cPath, flag)
            LibC.free(cPath)
            if (ret == -1) {
                throw FSException("Native function error return ${ret}.")
            } else if (ret == -4) {
                throw FSException("Operation not permitted!")
            } else if (ret == -2) {
                throw FSException("Invalid argument!")
            }
            return ret > 0
        }
    }

    @When[env == "ohos"]
    private func callNativeFunc(nativeFunction: CFunc<(CString, Bool) -> Int8>, flag: Bool,
        shouldFixLongPath!: Bool = true): Bool {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath = LibC.mallocCString(pathStr)
            let ret: Int8 = nativeFunction(cPath, flag)
            LibC.free(cPath)
            if (ret == -1) {
                throw FSException("Failed to set permission for '${pathStr}': native function returned '${ret}'.")
            } else if (ret == -4) {
                throw FSException("Cannot set permission on '${pathStr}': operation not permitted.")
            } else if (ret == -2) {
                throw FSException("Failed to set permission for '${pathStr}': invalid argument.")
            }
            return ret > 0
        }
    }

    /**
     * @throws FSException if `nativeFunction` returns negative error code
     */
    @When[env != "ohos"]
    private func callNativeFunc(this @local?, nativeFunction: CFunc<(CString) -> Int64>, msg: String, shouldFixLongPath!: Bool = true): Int64 {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath: CString = LibC.mallocCString(pathStr)
            let ret: Int64 = nativeFunction(cPath)
            LibC.free(cPath)
            if (ret < 0) {
                throw FSException("${msg} Native function return ${ret}.")
            }
            return ret
        }
    }

    @When[env == "ohos"]
    private func callNativeFunc(nativeFunction: CFunc<(CString) -> Int64>, msg: String, shouldFixLongPath!: Bool = true): Int64 {
        unsafe {
            let raw = _path.toString()
            let pathStr = if (shouldFixLongPath) {
                fixLongPath(raw)
            } else {
                raw
            }
            let cPath: CString = LibC.mallocCString(pathStr)
            let ret: Int64 = nativeFunction(cPath)
            LibC.free(cPath)
            if (ret < 0) {
                throw FSException("${msg} for '${pathStr}': error code '${ret}'.")
            }
            return ret
        }
    }

    public operator func ==(other: FileInfo): Bool {
        return _path == other.path
    }
}
