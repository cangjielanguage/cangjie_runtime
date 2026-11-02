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
 * This is a library for File.
 */
package std.fs

import std.io.*

const SEEK_SET: Int32 = 0 /* Seek from beginning of file.  */
const SEEK_CUR: Int32 = 1 /* Seek from current position.  */
const SEEK_END: Int32 = 2 /* Seek from end of file.  */

const READ_ONLY: Int32 = 0
const WRITE_ONLY: Int32 = 1
const APPEND: Int32 = 2
const READ_WRITE: Int32 = 3

public enum OpenMode <: ToString & Equatable<OpenMode> {
    | Read      // O_RDONLY
    | Write     // O_WRONLY | O_CREAT | O_TRUNC
    | Append    // O_WRONLY | O_CREAT | O_APPEND
    | ReadWrite // O_RDWR | O_CREAT

    public operator func ==(other: OpenMode): Bool {
        return match ((this, other)) {
            case (Read, Read)           => true
            case (Write, Write)         => true
            case (Append, Append)       => true
            case (ReadWrite, ReadWrite) => true
            case _                      => false
        }
    }

    public operator func !=(other: OpenMode): Bool {
        return !(this == other)
    }

    public func toString(): String {
        return match (this) {
            case Read      => "Read"
            case Write     => "Write"
            case Append    => "Append"
            case ReadWrite => "ReadWrite"
        }
    }
}

// FD numbers are indexes into the FD table.
// Unix/Linux use the Int type for handle, while Windows use HANDLE type.
// HANDLE is typedef'd void *, which is really just a 32-bit index, only for more opaque.
public struct FileDescriptor <: Copyable {
    var _fileHandle: IntNative = InvalidHandle

    public prop fileHandle: IntNative {
        get() {
            _fileHandle
        }
    }

    @When[env != "ohos"]
    public prop fileHandle: IntNative @local? {
        get() {
            _fileHandle
        }
    }
}

public class File <: Resource & IOStream & Seekable {
    private var _fileInfo: FileInfo
    private var _openMode: OpenMode
    var _fileDescriptor: FileDescriptor
    private var _canRead: Bool = true
    private var _canWrite: Bool = true
    private var _canSeek: Bool = true

    @When[env != "ohos"]
    ~init(this @local?) {
        if (isHandleValid(_fileDescriptor._fileHandle)) {
            unsafe { CJ_FS_CloseFile(_fileDescriptor._fileHandle) }
            _fileDescriptor._fileHandle = InvalidHandle
        }
    }

    @When[env == "ohos"]
    ~init() {
        if (isHandleValid(_fileDescriptor._fileHandle)) {
            unsafe { CJ_FS_CloseFile(_fileDescriptor._fileHandle) }
            _fileDescriptor._fileHandle = InvalidHandle
        }
    }

    /**
     * Constructors
     *
     * @param path - The file path.
     * @param mode - The open mode.
     *
     * @throws IllegalArgumentException - If path is empty or path contains null character.
     * @throws FSException - If the file does not exist while operation is open,
     * the file already exists while operation is create,
     * the parent directory of the file does not exist,
     * or other reasons caused fail to open file.
     */
    public init(path: String, mode: OpenMode) {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

        let filePath: Path = Path(path)
        let parent = filePath.parent
        if (!parent.isEmpty() && !exists(parent)) {
            throw FSException("Cannot open file: parent directory '${parent}' does not exist.")
        }
        // Because `filePath` may not exist before `openFile` is executed, `FileInfo` does not check whether the path exists.
        _fileDescriptor = FileDescriptor()
        _fileInfo = FileInfo(filePath, false)
        _openMode = mode
        openFile()
    }

    @When[env != "ohos"]
    public exclave init(this @local!, path: String @local!, mode: OpenMode @local!) {
        PathValidator.throwIfEmptyOrContainsNullByte("path", path, true)

        let filePath: Path @local! = Path(path) @local!
        let parent = filePath.parent
        if (!parent.isEmpty() && !exists(parent)) {
            throw FSException("Cannot open file: parent directory '${parent}' does not exist.")
        }
        _fileDescriptor = FileDescriptor()
        _fileInfo = FileInfo(filePath, false)
        _openMode = mode
        openFile()
    }

    /**
     * Constructors
     *
     * @param path - The file path.
     * @param mode - The open mode.
     *
     * @throws IllegalArgumentException - If path is empty or contains null character.
     * @throws FSException - If the file does not exist while operation is open,
     * the file already exists while operation is create,
     * the parent directory of the file does not exist,
     * or other reasons caused fail to open file.
     */
    public init(path: Path, mode: OpenMode) {
        this(path.toString(), mode)
    }

    private init(path: String, mode: OpenMode, fd: FileHandle) {
        if (!isHandleValid(fd)) {
            throw FSException("Invalid file handle: ${fd}.")
        }
        let filePath: Path = Path(path)
        _fileDescriptor = FileDescriptor()
        _fileInfo = FileInfo(filePath, false)
        _openMode = mode
        fileHandle = fd
    }

    public prop info: FileInfo {
        get() {
            _fileInfo
        }
    }

    public prop fileDescriptor: FileDescriptor {
        get() {
            _fileDescriptor
        }
    }

    mut prop fileHandle: FileHandle {
        get() {
            _fileDescriptor._fileHandle
        }
        set(v) {
            _fileDescriptor._fileHandle = v
        }
    }
    @When[env != "ohos"]
    mut prop fileHandle: FileHandle @local! {
        get() {
            exclave { _fileDescriptor._fileHandle }
        }
        set(v) {
            exclave { _fileDescriptor._fileHandle = v }
        }
    }

    public prop length: Int64 {
        get() {
            getsize()
        }
    }

    @When[env != "ohos"]
    public prop length: Int64 @local! {
        get() {
            getsize()
        }
    }

    public func setLength(length: Int64): Unit {
        if (length < 0) {
            throw IllegalArgumentException("Invalid argument 'length': ${length}.")
        }
        checkCanTruncate()

        unsafe {
            let resultPtr = CJ_FS_Truncate(_fileDescriptor.fileHandle, length)
            if (resultPtr.isNull()) {
                throw FSException("Failed to truncate file '${_fileInfo.path}': native function returned null.")
            }
            let result = resultPtr.read()
            LibC.free(resultPtr)

            try {
                if (result.rtnCode != 0) {
                    throw FSException("Failed to truncate file '${_fileInfo.path}': ${result.msg}.")
                }
            } finally {
                LibC.free(result.msg) // it's safe to free(NULL)
            }
        }
    }

    /**
     * Read data from file.
     *
     * @param buffer - Read data from file to the byte array.
     *
     * @return Int64 - Size of the data be read.
     *
     * @throws IllegalArgumentException - If buffer is empty.
     * @throws FSException - If the file to read is not opened,
     *      or the file does not have the read permission
     *      or failed to read file
     */
    public func read(buffer: Array<Byte>): Int64 {
        checkCanRead()
        if (buffer.size == 0) {
            throw IllegalArgumentException("Invalid argument 'buffer': buffer is empty.")
        }
        var readBytes: Int64 = directRead(buffer)
        if (readBytes == 0) {
            return 0
        } else if (readBytes < 0) {
            throw FSException("Failed to read file '${_fileInfo.path}': read ${readBytes} bytes.")
        }
        return readBytes
    }
    @When[env != "ohos"]
    public exclave func read(this @local!, buffer: Array<Byte> @local!): Int64 {
        checkCanRead()
        if (buffer.size == 0) {
            throw IllegalArgumentException("Invalid argument 'buffer': buffer is empty.")
        }
        var readBytes: Int64 = directRead(buffer)
        if (readBytes == 0) {
            return 0
        } else if (readBytes < 0) {
            throw FSException("Failed to read file '${_fileInfo.path}': read ${readBytes} bytes.")
        }
        return readBytes
    }

    /**
     * @throws FSException if system failed to write the file
     * @throws FSException if file is not opened
     * @throws FSException if the file is not allowed to write
     */
    public func write(buffer: Array<Byte>): Unit {
        if (!isHandleValid(fileHandle)) {
            throw FSException("Cannot write to file '${_fileInfo.path}': file is not opened.")
        }
        if (!_canWrite) {
            throw FSException("Cannot write to file '${_fileInfo.path}': file does not have write permission.")
        }
        if (buffer.size == 0) {
            return
        }
        directWrite(buffer)
    }

    public func flush(): Unit {}
    @When[env != "ohos"]
    public func flush(this @local?): Unit {}

    /**
     * @throws FSException if file can not seek
     * @throws FSException if there is error in parameter
     * @throws FSException if unknown errors occurred
     */
    public func seek(sp: SeekPosition): Int64 {
        if (!canSeek()) {
            throw FSException("Cannot seek in file '${_fileInfo.path}': file does not support seeking.")
        }
        var (whence, offset): (Int32, Int64) = match (sp) {
            case Current(cOffset) => (SEEK_CUR, cOffset)
            case Begin(bOffset) => (SEEK_SET, bOffset)
            case End(eOffset) => (SEEK_END, eOffset)
        }
        var val: Int64 = unsafe { CJ_FS_Seek(fileHandle, whence, offset) }
        if (val < 0) {
            throw FSException("Failed to seek in file '${_fileInfo.path}': error code ${0 - val}.")
        }
        return val
    }

    @When[env != "ohos"]
    public func seek(this @local!, sp: SeekPosition): Int64 {
        if (!canSeek()) {
            throw FSException("Cannot seek in file '${_fileInfo.path}': file does not support seeking.")
        }
        var (whence, offset): (Int32, Int64) = match (sp) {
            case Current(cOffset) => (SEEK_CUR, cOffset)
            case Begin(bOffset) => (SEEK_SET, bOffset)
            case End(eOffset) => (SEEK_END, eOffset)
        }
        var val: Int64 = unsafe { CJ_FS_Seek(_fileDescriptor._fileHandle, whence, offset) }
        if (val < 0) {
            throw FSException("Failed to seek in file '${_fileInfo.path}': error code ${0 - val}.")
        }
        return val
    }

    @When[env != "ohos"]
    private func canSeek(this @local?): Bool {
        if (isClosed()) {
            return false
        }
        return _canSeek
    }

    @When[env == "ohos"]
    private func canSeek(): Bool {
        if (isClosed()) {
            return false
        }
        return _canSeek
    }

    public func canRead(): Bool {
        if (isClosed()) {
            return false
        }
        return _canRead
    }

    public func canWrite(): Bool {
        if (isClosed()) {
            return false
        }
        return _canWrite
    }

    /**
     * @throws FSException if system failed to close file
     */
    public func close(): Unit {
        if (!isHandleValid(fileHandle)) {
            return
        }
        flush()

        /* Call the close() in the C Language */
        if (unsafe { CJ_FS_CloseFile(fileHandle) } < 0) {
            throw FSException("Failed to close file '${_fileInfo.path}'.")
        }
        fileHandle = InvalidHandle
    }

    @When[env != "ohos"]
    public exclave func close(this @local!): Unit {
        if (!isHandleValid(fileHandle)) {
            return
        }
        flush()

        /* Call the close() in the C Language */
        if (unsafe { CJ_FS_CloseFile(fileHandle) } < 0) {
            throw FSException("Failed to close file '${_fileInfo.path}'.")
        }
        fileHandle = InvalidHandle
    }

    public func isClosed(): Bool {
        return !isHandleValid(fileHandle)
    }
    @When[env != "ohos"]
    public func isClosed(this @local?): Bool {
        return !isHandleValid(_fileDescriptor._fileHandle)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     */
    public static func create(path: Path): File {
        return create(path.toString())
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     */
    public static func create(path: String): File {
        if (exists(path)) {
            throw FSException("Cannot create file: '${path}' already exists.")
        }
        return File(path, Write)
    }

    /**
     * @throws FSException if failed to create the temporary file or directoryPath is invalid.
     * @throws IllegalArgumentException while path contains null character or path is empty.
     */
    public static func createTemp(directoryPath: String): File {
        return createTemp(Path(directoryPath))
    }

    /**
     * @throws FSException if failed to create the temporary file or directoryPath is invalid.
     * @throws IllegalArgumentException while path contains null character or path is empty.
     */
    public static func createTemp(directoryPath: Path): File {
        var utf8View = unsafe { canonicalize(directoryPath).toString().rawData() }

        // Append r'/' + "tmpfile" + Six random characters and r'\0'
        var appendStrUtf8View = TMP_FILE
        var tempArrSize = utf8View.size + appendStrUtf8View.size
        var tempArr = Array<Byte>(tempArrSize, repeat: 0)
        utf8View.copyTo(tempArr, 0, 0, utf8View.size)
        appendStrUtf8View.copyTo(tempArr, 0, utf8View.size, appendStrUtf8View.size)
        var ret: FileHandle = InvalidHandle
        unsafe {
            var arrPtr: CPointerHandle<Byte> = acquireArrayRawData(tempArr)
            ret = CJ_FS_CreateTempFile(arrPtr.pointer)
            releaseArrayRawData(arrPtr)
            if (!isHandleValid(ret)) {
                throw FSException("Failed to create temporary file.")
            }
        }
        var tempPath = String.fromUtf8(tempArr.slice(0, tempArrSize - 1))
        return File(tempPath, ReadWrite, ret)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     */
    static func copy(sourcePath: String, destinationPath: String, overwrite: Bool): Unit {
        if (overwrite) {
            callNativeFunc(sourcePath, destinationPath, CJ_FS_CopyREF,
                "Failed to copy file from '${sourcePath}' to '${destinationPath}'")
            return
        }

        try (srcFile = File(sourcePath, Read), dstFile = File(destinationPath, Write)) {
            copy(srcFile, to: dstFile)
        }
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     */
    public static func readFrom(path: Path): Array<Byte> {
        File.readFrom(path.toString())
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if file read failed
     * @throws FSException if system failed to close file
     */
    public static func readFrom(path: String): Array<Byte> {
        var file = File(path, Read)
        try {
            return readToEnd(file)
        } finally {
            file.close()
        }
    }

    @When[env != "ohos"]
    public static exclave func readFrom(path: String @local!): Array<Byte> @local! {
        var file = File(path, Read) @local!
        try {
            readToEnd(file)
        } finally {
            file.close()
        }
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if system failed to close file.
     */
    public static func writeTo(path: Path, buffer: Array<Byte>): Unit {
        writeTo(path.toString(), buffer)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if system failed to close file.
     */
    public static func writeTo(path: String, buffer: Array<Byte>): Unit {
        writeTo(path, buffer, Write)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if system failed to close file
     */
    public static func appendTo(path: Path, buffer: Array<Byte>): Unit {
        appendTo(path.toString(), buffer)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if system failed to close file
     */
    public static func appendTo(path: String, buffer: Array<Byte>): Unit {
        writeTo(path, buffer, OpenMode.Append)
    }

    /**
     * @throws FSException while path is empty.
     * @throws IllegalArgumentException while path contains null character.
     * @throws FSException if system failed to close file
     */
    private static func writeTo(path: String, buffer: Array<Byte>, mode: OpenMode): Unit {
        var file = File(path, mode)
        try {
            file.write(buffer)
        } finally {
            file.close()
        }
    }

    /*
     * private functions
     */

    /**
     * Open file according to options.
     *
     * @throws FSException if check parameter is invalid or failed to get offset
     * @throws FSException if failed to open file
     * @throws FSException if file does not exist when operation is open
     * @throws FSException if file already exists when operation is create
     * @throws FSException if path is invalid
     */
    @When[env != "ohos"]
    private func openFile(this @local?): Unit {
        let isExists = exists(_fileInfo.path)
        let (r, w, s, openMode): (Bool, Bool, Bool, Int32) = match ((_openMode, isExists)) {
            case (Read, false)        => throw FSException("Cannot open file '${_fileInfo.path}': file does not exist or permission denied.")
            case (Read, _)            => (true, false, true, READ_ONLY)
            case (Write, _)           => (false, true, true, WRITE_ONLY)
            case (OpenMode.Append, _) => (false, true, false, APPEND)
            case (ReadWrite, _)       => (true, true, true, READ_WRITE)
        }
        _canRead = r
        _canWrite = w
        _canSeek = s
        var fsInfoCp: CPointer<FsInfo>
        var fsInfo: FsInfo
        var fsInfoErrMsg = ""

        let pathStr = _fileInfo.path.toString()
        unsafe {
            let cPath = LibC.mallocCString(pathStr)
            fsInfoCp = CJ_FS_OpenFile(cPath, openMode)
            LibC.free(cPath)
            if (fsInfoCp.isNull()) {
                throw FSException("Failed to open file '${_fileInfo.path}'.")
            }
            fsInfo = fsInfoCp.read()
            LibC.free(fsInfoCp)
            try {
                fsInfoErrMsg = fsInfo.msg.toString()
            } finally {
                LibC.free(fsInfo.msg)
            }
            _fileDescriptor._fileHandle = fsInfo.fd
        }
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            var errMsg = "Failed to open file '${_fileInfo.path}'."
            if (fsInfoErrMsg != "") {
                errMsg += " ${fsInfoErrMsg}."
            }
            throw FSException(errMsg)
        }
    }

    @When[env == "ohos"]
    private func openFile(): Unit {
        let isExists = exists(_fileInfo.path)
        let (r, w, s, openMode): (Bool, Bool, Bool, Int32) = match ((_openMode, isExists)) {
            case (Read, false)        => throw FSException("Cannot open file '${_fileInfo.path}': file does not exist or permission denied.")
            case (Read, _)            => (true, false, true, READ_ONLY)
            case (Write, _)           => (false, true, true, WRITE_ONLY)
            case (OpenMode.Append, _) => (false, true, false, APPEND)
            case (ReadWrite, _)       => (true, true, true, READ_WRITE)
        }
        _canRead = r
        _canWrite = w
        _canSeek = s
        var fsInfoCp: CPointer<FsInfo>
        var fsInfo: FsInfo
        var fsInfoErrMsg = ""

        let pathStr = _fileInfo.path.toString()
        unsafe {
            let cPath = LibC.mallocCString(pathStr)
            fsInfoCp = CJ_FS_OpenFile(cPath, openMode)
            LibC.free(cPath)
            if (fsInfoCp.isNull()) {
                throw FSException("Failed to open file '${pathStr}'.")
            }
            fsInfo = fsInfoCp.read()
            LibC.free(fsInfoCp)
            try {
                fsInfoErrMsg = fsInfo.msg.toString()
            } finally {
                LibC.free(fsInfo.msg)
            }
            _fileDescriptor._fileHandle = fsInfo.fd
        }
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            var errMsg = "Failed to open file '${pathStr}'."
            if (fsInfoErrMsg != "") {
                errMsg += " ${fsInfoErrMsg}."
            }
            throw FSException(errMsg)
        }
    }

    private func getsize(this @local?): Int64 {
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            return -1
        }
        unsafe {
            return CJ_FS_GetFileSize(_fileDescriptor._fileHandle)
        }
    }

    /**
     * @throws FSException if the file to read is not opened
     * @throws FSException if the file does not have the read permission
     */
    @When[env != "ohos"]
    private func checkCanRead(this @local?): Unit {
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            throw FSException("Cannot read file '${_fileInfo.path}': file is not opened.")
        }
        if (!_canRead) {
            throw FSException("Cannot read file '${_fileInfo.path}': file does not have read permission.")
        }
    }

    @When[env == "ohos"]
    private func checkCanRead(): Unit {
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            throw FSException("Cannot read file '${_fileInfo.path}': file is not opened.")
        }
        if (!_canRead) {
            throw FSException("Cannot read file '${_fileInfo.path}': file does not have read permission.")
        }
    }

    /**
     * @throws FSException if the file to truncate is not opened
     * @throws FSException if the file does not have the write permission
     */
    @When[env != "ohos"]
    private func checkCanTruncate(this @local?): Unit {
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            throw FSException("Cannot truncate file '${_fileInfo.path}': file is not opened.")
        }
        match (_openMode) {
            case Write | ReadWrite => ()
            case _ => throw FSException("Cannot truncate file '${_fileInfo.path}': file does not have write permission.")
        }
    }

    @When[env == "ohos"]
    private func checkCanTruncate(): Unit {
        if (!isHandleValid(_fileDescriptor._fileHandle)) {
            throw FSException("Cannot truncate file '${_fileInfo.path}': file is not opened.")
        }
        match (_openMode) {
            case Write | ReadWrite => ()
            case _ => throw FSException("Cannot truncate file '${_fileInfo.path}': file does not have write permission.")
        }
    }

    /**
     * Read from the file directly and write into buffer.
     *
     * @param buffer - Read to the buffer from the file
     *
     * @return Length successfully written into the array buffer
     * @since 0.17.4
     */
    @When[env != "ohos"]
    private func directRead(this @local?, buffer: Array<Byte> @local?): Int64 {
        unsafe {
            let bufPtr: CPointerHandle<Byte> @local? = acquireArrayRawData(buffer)
            let readSize: Int64 = CJ_FS_FileRead(_fileDescriptor._fileHandle, bufPtr.pointer, UIntNative(buffer.size))
            releaseArrayRawData(bufPtr)
            return readSize
        }
    }

    @When[env == "ohos"]
    private func directRead(buffer: Array<Byte>): Int64 {
        unsafe {
            let bufPtr: CPointerHandle<Byte> = acquireArrayRawData(buffer)
            let readSize: Int64 = CJ_FS_FileRead(_fileDescriptor._fileHandle, bufPtr.pointer, UIntNative(buffer.size))
            releaseArrayRawData(bufPtr)
            return readSize
        }
    }

    /**
     * Write the array to the file and return the bytes successfully written into the file.
     *
     * @param buffer – The buffer will be written to the file
     *
     * @since 0.17.4
     *
     * @throws FSException if system failed to write the file
     */
    private func directWrite(buffer: Array<Byte>): Unit {
        unsafe {
            let bufSize: Int64 = buffer.size
            var bufPtr: CPointerHandle<Byte> = acquireArrayRawData(buffer)
            let writeSuccess: Bool = CJ_FS_FileWrite(fileHandle, bufPtr.pointer, UIntNative(bufSize))
            releaseArrayRawData(bufPtr)
            if (!writeSuccess) {
                throw FSException("Failed to write to file '${_fileInfo.path}'.")
            }
        }
    }
}
