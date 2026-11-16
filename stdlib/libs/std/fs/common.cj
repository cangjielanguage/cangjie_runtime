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

public func copy(sourcePath: Path, to!: Path, overwrite!: Bool = false): Unit {
    PathValidator.throwIfEmptyOrContainsNullByte("sourcePath", sourcePath, true)
    PathValidator.throwIfEmptyOrContainsNullByte("to", to, true)
    if (sourcePath == to) {
        throw FSException("Invalid argument: 'sourcePath' and 'to' refer to the same path '${sourcePath}'.")
    }

    let fileInfo = FileInfo(sourcePath)
    let destInfo = if (exists(to)) {
        Some(FileInfo(to))
    } else {
        Option<FileInfo>.None
    }

    if (fileInfo.isRegular()) {
        if (let Some(info) <- destInfo) {
            if (!overwrite) {
                throw FSException("Cannot copy to '${to}': destination path already exists.")
            } else if (!info.isRegular()) {
                throw FSException("Cannot copy to '${to}': source '${sourcePath}' is a regular file but destination already exists and is not a file.")
            }
        }
        return File.copy(sourcePath._rawPath, to._rawPath, overwrite)
    } else if (fileInfo.isDirectory()) {
        if (let Some(info) <- destInfo) {
            if (!overwrite) {
                throw FSException("Cannot copy to '${to}': destination path already exists.")
            } else if (!info.isDirectory()) {
                throw FSException("Cannot copy to '${to}': source '${sourcePath}' is a directory but destination already exists and is not a directory.")
            }
        }
        return Directory.copy(sourcePath._rawPath, to._rawPath, overwrite)
    } else if (fileInfo.isSymbolicLink()) {
        if (let Some(info) <- destInfo) {
            if (!overwrite) {
                throw FSException("Cannot copy to '${to}': destination path already exists.")
            } else if (!info.isSymbolicLink()) {
                throw FSException("Cannot copy to '${to}': source '${sourcePath}' is a symbolic link but destination already exists and is not a symbolic link.")
            } else {
                remove(to)
            }
        }
        let target = SymbolicLink.readFrom(fileInfo._path)
        SymbolicLink.create(to, to: target)
        return
    }
    throw FSException("Cannot copy '${sourcePath}': unsupported file type.")
}

public func copy(sourcePath: String, to!: String, overwrite!: Bool = false): Unit {
    copy(Path(sourcePath), to: Path(to), overwrite: overwrite)
}

public func remove(path: Path, recursive!: Bool = false): Unit {
    remove(path._rawPath, recursive: recursive)
}

public func remove(path: String, recursive!: Bool = false): Unit {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    unsafe {
        try (cpath = LibC.mallocCString(path).asResource()) {
            let pret = CJ_FS_Remove(cpath.value, recursive)
            if (pret.isNull()) {
                throw FSException("Memory allocation failed in native code when removing '${path}'.")
            }
            let ret = pret.read()
            LibC.free(pret)
            if (ret.rtnCode == 0) {
                return
            }
            try {
                let errMessage = ret.msg.toString()
                throw FSException("Failed to remove '${path}': error code ${ret.rtnCode}, ${errMessage.trimAscii()}.")
            } finally {
                LibC.free(ret.msg)
            }
        }
    }
}

public func exists(path: Path): Bool {
    exists(path._rawPath)
}

@When[env != "ohos"]
public func exists(path: Path @local?): Bool {
    exists(path._rawPath)
}

public func exists(path: String): Bool {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    unsafe {
        let cPath = LibC.mallocCString(path)
        var ret: Int8 = CJ_FS_Exists(cPath)
        LibC.free(cPath)
        return ret == 0
    }
}

@When[env != "ohos"]
public func exists(path: String @local?): Bool {
    PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

    unsafe {
        let cPath = LibC.mallocCString(path)
        var ret: Int8 = CJ_FS_Exists(cPath)
        LibC.free(cPath)
        return ret == 0
    }
}

public func rename(sourcePath: String, to!: String, overwrite!: Bool = false): Unit {
    PathValidator.throwIfEmptyOrContainsNullByte("sourcePath", sourcePath, true)
    PathValidator.throwIfEmptyOrContainsNullByte("to", to, true)
    if (Path(sourcePath) == Path(to)) {
        throw FSException("Invalid argument: 'sourcePath' and 'to' refer to the same path '${sourcePath}'.")
    }
    if (exists(to) && !overwrite) {
        throw FSException("Cannot rename to '${to}': destination path already exists and overwrite is false.")
    }

    try (sourceCPath = unsafe { LibC.mallocCString(sourcePath).asResource() },
        destinationCPath = unsafe { LibC.mallocCString(to).asResource() }) {
        let resultptr = unsafe { CJ_FS_Rename(sourceCPath.value, destinationCPath.value) }
        if (resultptr.isNull()) {
            throw FSException("Memory allocation failed in native code when renaming '${sourcePath}' to '${to}'.")
        }
        let result = unsafe { resultptr.read() }
        unsafe { LibC.free(resultptr) }
        if (result.rtnCode == 0) {
            return
        }
        try {
            let errMessage = result.msg.toString()
            throw FSException("Failed to rename '${sourcePath}' to '${to}': error code '${result.rtnCode}', ${errMessage.trimAscii()}.")
        } finally {
            unsafe { LibC.free(result.msg) }
        }
    }
}

public func rename(sourcePath: Path, to!: Path, overwrite!: Bool = false): Unit {
    rename(sourcePath._rawPath, to: to._rawPath, overwrite: overwrite)
}

public func removeIfExists(path: Path, recursive!: Bool = false): Bool {
    if (exists(path)) {
        remove(path, recursive: recursive)
        return true
    }
    return false
}

public func removeIfExists(path: String, recursive!: Bool = false): Bool {
    removeIfExists(Path(path), recursive: recursive)
}
