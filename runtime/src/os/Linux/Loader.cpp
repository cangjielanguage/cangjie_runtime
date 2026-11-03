// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

// The Android 6 APK-path backfill below reads arbitrary offsets and file sizes
// inside the APK. On 32-bit ABIs (armeabi-v7a) bionic's default off_t is only
// 32 bits, so offsets/sizes beyond 2 GiB would wrap in pread()/fstat() and make
// the container lookup silently fail (it falls back to the original path).
// Force 64-bit file offsets for this translation unit before any header is
// included: off_t becomes 64 bits, and pread/fstat/stat resolve to their 64-bit
// variants. On 64-bit ABIs off_t is already 64 bits, so this is a no-op.
#if defined(__ANDROID__) && !defined(_FILE_OFFSET_BITS)
#define _FILE_OFFSET_BITS 64
#endif

#include "os/Loader.h"

#include <dlfcn.h>
#if defined(__ANDROID__)
#include <elf.h>
#include <fcntl.h>
#include <link.h>
#include <sys/stat.h>
#include <unistd.h>
#include <algorithm>
#include <cerrno>
#include <cstdint>
#include <cstring>
#include <memory>
#include <mutex>
#include <utility>
#include <vector>
#endif

#include "Base/Log.h"
#if defined(__ANDROID__)
static_assert(sizeof(off_t) >= 8,
    "_FILE_OFFSET_BITS=64 must yield a 64-bit off_t on this target");
#endif
namespace MapleRuntime {
namespace Os {
void* Loader::LoadBinaryFile(const char* path)
{
    if (path == nullptr) {
        return nullptr;
    }
    void* handler = dlopen(path, RTLD_NOW | RTLD_GLOBAL);
    if (handler == nullptr) {
        LOG(RTLOG_ERROR, dlerror());
    }
    return handler;
}

int Loader::UnloadBinaryFile(void* handler)
{
    if (handler == nullptr) {
        return -1;
    }
    int ret = dlclose(handler);
    return ret;
}

void* Loader::FindSymbol(void* handler, const char* symbolName)
{
    if (symbolName == nullptr) {
        return nullptr;
    }
    // handler can be nullptr
    return dlsym(handler, symbolName);
}

int Loader::GetBinaryInfoFromAddress(const void* address, BinaryInfo* binInfo)
{
    if (address == nullptr) {
        return 0;
    }
    Dl_info dlInfo;
    int ret = dladdr(address, &dlInfo);
    if (!ret) {
        return 0;
    }
    binInfo->filePathName = const_cast<char*>(dlInfo.dli_fname);
    binInfo->symbolName = const_cast<char*>(dlInfo.dli_sname);
    return ret;
}
#if defined(__ANDROID__)
namespace {
constexpr size_t kModuleProbeSize = 4096;
constexpr size_t kMaxModulePathLen = 2048;
constexpr uint64_t kMaxCentralDirectorySize = 32ull * 1024ull * 1024ull;
constexpr uint64_t kMaxCentralDirectoryEntries = 200000;
constexpr size_t kMaxContainerCacheEntries = 8;
constexpr unsigned char kFirstPrintableAscii = 0x20;  // chars below this are control characters
constexpr unsigned char kAsciiDelete = 0x7f;
constexpr uint16_t kZipEncryptedFlag = 0x0001;
constexpr uint32_t kZipCentralDirectorySignature = 0x02014b50;
constexpr uint32_t kZipLocalHeaderSignature = 0x04034b50;
constexpr uint32_t kZipEndOfCentralDirectorySignature = 0x06054b50;
constexpr uint32_t kZip64EndOfCentralDirectoryLocatorSignature = 0x07064b50;
constexpr uint32_t kZip64EndOfCentralDirectorySignature = 0x06064b50;
constexpr size_t kZipLocalHeaderSize = 30;
constexpr uint16_t kZip64ExtraFieldId = 0x0001;
constexpr uint16_t kZip16Sentinel = 0xffff;          // field value means "see Zip64"
constexpr uint32_t kZip32Sentinel = 0xffffffff;      // field value means "see Zip64"
constexpr uint64_t kZipCentralDirectoryHeaderSize = 46;

struct ModuleImage {
    const uint8_t* start = nullptr;
    size_t fileBytes = 0;
};

struct ImageSearchCtx {
    uintptr_t target = 0;
    ModuleImage image;
};

struct ContainerEntry {
    CString name;
    uint64_t localHeaderOffset = 0;
    uint64_t uncompressedSize = 0;
};

struct ContainerIndex {
    dev_t dev = 0;
    ino_t ino = 0;
    uint64_t size = 0;
    time_t mtime = 0;
    std::vector<ContainerEntry> entries;
};

std::mutex gContainerCacheMutex;
std::vector<std::pair<CString, std::shared_ptr<ContainerIndex>>> gContainerCache;

uint16_t ReadLe16(const uint8_t* p)
{
    return static_cast<uint16_t>(static_cast<uint16_t>(p[0]) | (static_cast<uint16_t>(p[1]) << 8));
}

uint32_t ReadLe32(const uint8_t* p)
{
    return static_cast<uint32_t>(p[0]) | (static_cast<uint32_t>(p[1]) << 8) |
        (static_cast<uint32_t>(p[2]) << 16) | (static_cast<uint32_t>(p[3]) << 24);
}

uint64_t ReadLe64(const uint8_t* p)
{
    return static_cast<uint64_t>(ReadLe32(p)) | (static_cast<uint64_t>(ReadLe32(p + 4)) << 32);
}

bool PreadExact(int fd, void* buffer, size_t length, uint64_t offset)
{
    uint8_t* out = static_cast<uint8_t*>(buffer);
    size_t done = 0;
    while (done < length) {
        ssize_t n = pread(fd, out + done, length - done, static_cast<off_t>(offset + done));
        if (n < 0) {
            if (errno == EINTR) {
                continue;
            }
            return false;
        }
        if (n == 0) {
            return false;
        }
        done += static_cast<size_t>(n);
    }
    return true;
}

int FindImageCallback(struct dl_phdr_info* info, size_t, void* data)
{
    ImageSearchCtx* ctx = static_cast<ImageSearchCtx*>(data);
    if (ctx == nullptr || info == nullptr || info->dlpi_phdr == nullptr) {
        return 0;
    }
    for (size_t i = 0; i < static_cast<size_t>(info->dlpi_phnum); ++i) {
        const ElfW(Phdr)* ph = info->dlpi_phdr + i;
        if (ph->p_type != PT_LOAD || ph->p_memsz == 0) {
            continue;
        }
        uintptr_t start = static_cast<uintptr_t>(info->dlpi_addr) + static_cast<uintptr_t>(ph->p_vaddr);
        uintptr_t end = start + static_cast<uintptr_t>(ph->p_memsz);
        if (end < start || ctx->target < start || ctx->target >= end) {
            continue;
        }
        // The module containing the metadata address was found. Locate the segment mapped
        // from file offset 0; only that segment can be compared with the file header.
        for (size_t j = 0; j < static_cast<size_t>(info->dlpi_phnum); ++j) {
            const ElfW(Phdr)* first = info->dlpi_phdr + j;
            if (first->p_type != PT_LOAD || first->p_offset != 0) {
                continue;
            }
            if ((first->p_flags & PF_R) == 0 || first->p_filesz < sizeof(ElfW(Ehdr))) {
                return 1;
            }
            uintptr_t imageStart =
                static_cast<uintptr_t>(info->dlpi_addr) + static_cast<uintptr_t>(first->p_vaddr);
            ctx->image.start = reinterpret_cast<const uint8_t*>(imageStart);
            ctx->image.fileBytes = static_cast<size_t>(first->p_filesz);
            return 1;
        }
        return 1;
    }
    return 0;
}

bool ResolveModuleImage(const void* address, ModuleImage* out)
{
    if (address == nullptr || out == nullptr) {
        return false;
    }
    ImageSearchCtx ctx;
    ctx.target = reinterpret_cast<uintptr_t>(address);
    dl_iterate_phdr(FindImageCallback, &ctx);
    if (ctx.image.start == nullptr || ctx.image.fileBytes < sizeof(ElfW(Ehdr))) {
        return false;
    }
    *out = ctx.image;
    return true;
}

bool IsSafeEntryName(const CString& name)
{
    if (name.IsEmpty() || name[0] == '/' || name.Find('\\') != -1 || name.Find("..") != -1) {
        return false;
    }
    // Reject control characters (including NUL, CR/LF, ESC) so an abnormal ZIP
    // entry name cannot pollute or forge the log line it is later printed into.
    const char* str = name.Str();
    for (size_t i = 0; i < name.Length(); ++i) {
        unsigned char c = static_cast<unsigned char>(str[i]);
        if (c < kFirstPrintableAscii || c == kAsciiDelete) {
            return false;
        }
    }
    return true;
}

bool ReadZip64Field(const uint8_t* extra, size_t end, size_t* cur, size_t width, uint64_t* out)
{
    if (*cur > end || width > end - *cur) {
        return false;
    }
    *out = (width == 8) ? ReadLe64(extra + *cur) : ReadLe32(extra + *cur);
    *cur += width;
    return true;
}

bool ParseZip64Extra(const uint8_t* extra, size_t extraLen, bool needUncompressed, bool needCompressed,
    bool needOffset, bool needDisk, uint64_t* uncompressed, uint64_t* compressed, uint64_t* localOffset,
    uint32_t* diskStart)
{
    size_t pos = 0;
    while (pos + 4 <= extraLen) {
        uint16_t fieldId = ReadLe16(extra + pos);
        uint16_t fieldSize = ReadLe16(extra + pos + 2);
        pos += 4;
        if (pos + fieldSize > extraLen) {
            return false;
        }
        if (fieldId != kZip64ExtraFieldId) {
            pos += fieldSize;
            continue;
        }
        size_t cur = pos;
        size_t end = pos + fieldSize;
        if (needUncompressed && !ReadZip64Field(extra, end, &cur, 8, uncompressed)) {
            return false;
        }
        if (needCompressed && !ReadZip64Field(extra, end, &cur, 8, compressed)) {
            return false;
        }
        if (needOffset && !ReadZip64Field(extra, end, &cur, 8, localOffset)) {
            return false;
        }
        if (needDisk) {
            uint64_t disk = 0;
            if (!ReadZip64Field(extra, end, &cur, 4, &disk)) {
                return false;
            }
            *diskStart = static_cast<uint32_t>(disk);
        }
        return true;
    }
    return false;
}

bool ReadCentralDirectoryInfo(int fd, uint64_t fileSize, uint64_t* entryCount, uint64_t* cdSize,
    uint64_t* cdOffset)
{
    if (entryCount == nullptr || cdSize == nullptr || cdOffset == nullptr || fileSize < 22) {
        return false;
    }
    // EOCD is at least 22 bytes; its trailing comment is at most 0xffff bytes.
    const uint64_t kTailMax = 22 + 65535;
    uint64_t tailSize64 = std::min(fileSize, kTailMax);
    size_t tailSize = static_cast<size_t>(tailSize64);
    std::vector<uint8_t> tail(tailSize);
    if (!PreadExact(fd, tail.data(), tailSize, fileSize - tailSize64)) {
        return false;
    }
    int64_t eocdRel = -1;
    for (int64_t i = static_cast<int64_t>(tailSize) - 22; i >= 0; --i) {
        if (ReadLe32(tail.data() + static_cast<size_t>(i)) != kZipEndOfCentralDirectorySignature) {
            continue;
        }
        uint16_t commentLen = ReadLe16(tail.data() + static_cast<size_t>(i) + 20);
        if (static_cast<uint64_t>(i) + 22 + commentLen <= tailSize64) {
            eocdRel = i;
            break;
        }
    }
    if (eocdRel < 0) {
        return false;
    }
    uint64_t eocdOffset = fileSize - tailSize64 + static_cast<uint64_t>(eocdRel);
    // EOCD fixed fields: entries-on-this-disk(2 @8), entries-total(2 @10),
    // central-directory-size(4 @12), central-directory-offset(4 @16), comment-len(2 @20).
    uint16_t entryCount16 = ReadLe16(tail.data() + static_cast<size_t>(eocdRel) + 10);
    uint32_t cdSize32 = ReadLe32(tail.data() + static_cast<size_t>(eocdRel) + 12);
    uint32_t cdOffset32 = ReadLe32(tail.data() + static_cast<size_t>(eocdRel) + 16);
    *entryCount = entryCount16;
    *cdSize = cdSize32;
    *cdOffset = cdOffset32;

    // Sentinel values mean the real value lives in the Zip64 record.
    if (entryCount16 == kZip16Sentinel || cdSize32 == kZip32Sentinel || cdOffset32 == kZip32Sentinel) {
        if (eocdOffset < 20) {
            return false;
        }
        uint8_t locator[20];
        if (!PreadExact(fd, locator, sizeof(locator), eocdOffset - 20) ||
            ReadLe32(locator) != kZip64EndOfCentralDirectoryLocatorSignature) {
            return false;
        }
        // Zip64 locator: sig(4) disk-with-zip64-eocd(4) zip64-eocd-offset(8 @8) total-disks(4 @16).
        uint64_t zip64Offset = ReadLe64(locator + 8);
        uint8_t record[56];
        if (zip64Offset > fileSize || fileSize - zip64Offset < sizeof(record) ||
            !PreadExact(fd, record, sizeof(record), zip64Offset) ||
            ReadLe32(record) != kZip64EndOfCentralDirectorySignature) {
            return false;
        }
        // Zip64 EOCD: entries-on-disk(8 @24), entries-total(8 @32), cd-size(8 @40), cd-offset(8 @48).
        *entryCount = ReadLe64(record + 32);
        *cdSize = ReadLe64(record + 40);
        *cdOffset = ReadLe64(record + 48);
    }
    return true;
}

bool ParseCentralDirectory(const uint8_t* cd, size_t cdSize, uint64_t entryCount,
    std::vector<ContainerEntry>* entries)
{
    if (cd == nullptr || entries == nullptr) {
        return false;
    }
    size_t pos = 0;
    uint64_t parsed = 0;
    while (pos + kZipCentralDirectoryHeaderSize <= cdSize && parsed < entryCount) {
        // Central directory header is 46 bytes fixed:
        // sig(4) verMade(2) verNeed(2) flags(2 @8) method(2 @10) mtime(2 @12) mdate(2 @14)
        // crc(4 @16) compressedSize(4 @20) uncompressedSize(4 @24) nameLen(2 @28) extraLen(2 @30)
        // commentLen(2 @32) diskStart(2 @34) intAttr(2 @36) extAttr(4 @38) localOffset(4 @42).
        const uint8_t* p = cd + pos;
        if (ReadLe32(p) != kZipCentralDirectorySignature) {
            return false;
        }
        uint16_t flags = ReadLe16(p + 8);
        uint16_t method = ReadLe16(p + 10);
        uint64_t compressed = ReadLe32(p + 20);
        uint64_t uncompressed = ReadLe32(p + 24);
        uint16_t nameLen = ReadLe16(p + 28);
        uint16_t extraLen = ReadLe16(p + 30);
        uint16_t commentLen = ReadLe16(p + 32);
        uint16_t disk16 = ReadLe16(p + 34);
        uint64_t localOffset = ReadLe32(p + 42);
        uint64_t total = kZipCentralDirectoryHeaderSize + nameLen + extraLen + commentLen;
        if (total > static_cast<uint64_t>(cdSize - pos)) {
            return false;
        }

        bool needUncompressed = uncompressed == kZip32Sentinel;
        bool needCompressed = compressed == kZip32Sentinel;
        bool needOffset = localOffset == kZip32Sentinel;
        bool needDisk = disk16 == kZip16Sentinel;
        if (needUncompressed || needCompressed || needOffset || needDisk) {
            uint32_t disk32 = disk16;
            if (!ParseZip64Extra(p + kZipCentralDirectoryHeaderSize + nameLen, extraLen, needUncompressed,
                needCompressed, needOffset, needDisk, &uncompressed, &compressed, &localOffset, &disk32)) {
                pos += static_cast<size_t>(total);
                ++parsed;
                continue;
            }
            if (needDisk && disk32 != 0) {
                pos += static_cast<size_t>(total);
                ++parsed;
                continue;
            }
        }
        if (!needDisk && disk16 != 0) {
            pos += static_cast<size_t>(total);
            ++parsed;
            continue;
        }

        if ((flags & kZipEncryptedFlag) == 0 && method == 0 && nameLen > 0 && uncompressed > 0) {
            CString name;
            name.EnsureSpace(nameLen);
            name.Append(reinterpret_cast<const char*>(p + kZipCentralDirectoryHeaderSize), nameLen);
            // Deliberately no extension/name filter: the mapped entry may have any
            // name (Android maps stored, page-aligned entries via "container!/entry"
            // regardless of suffix), and filtering here could drop the real entry or
            // shrink a genuine duplicate match into a false unique one. The checks
            // above plus the later ELF magic and content comparison decide identity;
            // uniqueness is judged over every entry that passes them.
            if (IsSafeEntryName(name)) {
                ContainerEntry entry;
                entry.name = name;
                entry.localHeaderOffset = localOffset;
                entry.uncompressedSize = uncompressed;
                entries->push_back(entry);
            }
        }
        pos += static_cast<size_t>(total);
        ++parsed;
    }
    return parsed == entryCount;
}

bool LoadCentralDirectory(int fd, uint64_t fileSize, std::vector<ContainerEntry>* entries)
{
    if (entries == nullptr) {
        return false;
    }
    uint64_t entryCount = 0;
    uint64_t cdSize = 0;
    uint64_t cdOffset = 0;
    if (!ReadCentralDirectoryInfo(fd, fileSize, &entryCount, &cdSize, &cdOffset)) {
        return false;
    }
    if (entryCount == 0 || entryCount > kMaxCentralDirectoryEntries || cdSize == 0 ||
        cdSize > kMaxCentralDirectorySize || cdOffset > fileSize || cdSize > fileSize - cdOffset) {
        return false;
    }
    std::vector<uint8_t> cd(static_cast<size_t>(cdSize));
    if (!PreadExact(fd, cd.data(), cd.size(), cdOffset)) {
        return false;
    }
    entries->clear();
    entries->reserve(static_cast<size_t>(std::min<uint64_t>(entryCount, 4096)));  // cap upfront memory
    return ParseCentralDirectory(cd.data(), cd.size(), entryCount, entries);
}

bool GetContainerIndex(const char* path, int fd, const struct stat& st,
    std::shared_ptr<const ContainerIndex>* out)
{
    if (path == nullptr || out == nullptr || st.st_size < 0) {
        return false;
    }
    CString key(path);
    uint64_t fileSize = static_cast<uint64_t>(st.st_size);
    auto findCached = [&key](dev_t dev, ino_t ino, uint64_t size, time_t mtime) {
        std::shared_ptr<const ContainerIndex> found;
        for (auto it = gContainerCache.begin(); it != gContainerCache.end(); ++it) {
            if (it->first == key && it->second->dev == dev && it->second->ino == ino &&
                it->second->size == size && it->second->mtime == mtime) {
                found = it->second;
                break;
            }
        }
        return found;
    };
    {
        std::lock_guard<std::mutex> lock(gContainerCacheMutex);
        auto cached = findCached(st.st_dev, st.st_ino, fileSize, st.st_mtime);
        if (cached != nullptr) {
            *out = cached;
            return true;
        }
    }

    std::shared_ptr<ContainerIndex> index = std::make_shared<ContainerIndex>();
    index->dev = st.st_dev;
    index->ino = st.st_ino;
    index->size = fileSize;
    index->mtime = st.st_mtime;
    if (!LoadCentralDirectory(fd, fileSize, &index->entries) || index->entries.empty()) {
        return false;
    }

    {
        std::lock_guard<std::mutex> lock(gContainerCacheMutex);
        auto cached = findCached(index->dev, index->ino, index->size, index->mtime);
        if (cached != nullptr && !cached->entries.empty()) {
            *out = cached;
            return true;
        }
        if (gContainerCache.size() >= kMaxContainerCacheEntries) {
            gContainerCache.erase(gContainerCache.begin());
        }
        gContainerCache.emplace_back(key, index);
    }
    *out = index;
    return true;
}

bool FilePrefixMatchesImage(const char* path, const ModuleImage& image, size_t probeLen)
{
    if (path == nullptr || path[0] != '/' || image.start == nullptr || probeLen == 0 ||
        probeLen > kModuleProbeSize) {
        return false;
    }
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) {
        return false;
    }
    struct stat st;
    uint8_t buffer[kModuleProbeSize];
    bool same = false;
    if (fstat(fd, &st) == 0 && S_ISREG(st.st_mode) && st.st_size >= 0 &&
        static_cast<uint64_t>(st.st_size) >= probeLen && PreadExact(fd, buffer, probeLen, 0)) {
        same = memcmp(buffer, image.start, probeLen) == 0;
    }
    close(fd);
    return same;
}

bool EntryDataMatches(int fd, uint64_t fileSize, const ContainerEntry& entry, const ModuleImage& image,
    size_t probeLen, uint8_t* buffer)
{
    uint8_t localHeader[kZipLocalHeaderSize];
    const uint64_t kLocalHeaderSize = static_cast<uint64_t>(kZipLocalHeaderSize);
    if (entry.localHeaderOffset > fileSize || kLocalHeaderSize > fileSize - entry.localHeaderOffset) {
        return false;
    }
    if (!PreadExact(fd, localHeader, kZipLocalHeaderSize, entry.localHeaderOffset) ||
        ReadLe32(localHeader) != kZipLocalHeaderSignature) {
        return false;
    }
    // Local file header is 30 bytes fixed; nameLen @26, extraLen @28, data starts after 30 + name + extra.
    uint16_t localNameLen = ReadLe16(localHeader + 26);
    uint16_t localExtraLen = ReadLe16(localHeader + 28);
    uint64_t afterHeader = entry.localHeaderOffset + kLocalHeaderSize;
    if (static_cast<uint64_t>(localNameLen) + static_cast<uint64_t>(localExtraLen) > fileSize - afterHeader) {
        return false;
    }
    uint64_t dataOffset = afterHeader + static_cast<uint64_t>(localNameLen) + static_cast<uint64_t>(localExtraLen);
    if (dataOffset > fileSize || static_cast<uint64_t>(probeLen) > fileSize - dataOffset) {
        return false;
    }
    if (!PreadExact(fd, buffer, probeLen, dataOffset)) {
        return false;
    }
    return memcmp(buffer, ELFMAG, SELFMAG) == 0 && memcmp(buffer, image.start, probeLen) == 0;
}

bool FindContainerEntry(const char* path, const ModuleImage& image, size_t probeLen, CString* entryName)
{
    if (path == nullptr || entryName == nullptr || probeLen == 0 || probeLen > kModuleProbeSize) {
        return false;
    }
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) {
        return false;
    }
    struct stat st;
    if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size < 0) {
        close(fd);
        return false;
    }
    std::shared_ptr<const ContainerIndex> index;
    if (!GetContainerIndex(path, fd, st, &index)) {
        close(fd);
        return false;
    }

    uint64_t fileSize = static_cast<uint64_t>(st.st_size);
    uint8_t buffer[kModuleProbeSize];
    CString match;
    bool multiple = false;
    for (size_t i = 0; i < index->entries.size(); ++i) {
        const ContainerEntry& entry = index->entries[i];
        if (entry.uncompressedSize < probeLen) {
            continue;
        }
        if (!EntryDataMatches(fd, fileSize, entry, image, probeLen, buffer)) {
            continue;
        }
        if (!match.IsEmpty()) {
            multiple = true;  // more than one entry matches: fail open, stop probing
            break;
        }
        match = entry.name;
    }
    close(fd);

    if (multiple) {
        LOG(RTLOG_WARNING, "resolve module path ambiguous: path=%s", path);
        return false;
    }
    if (match.IsEmpty()) {
        return false;
    }
    *entryName = match;
    return true;
}
} // namespace

void Loader::CanonicalizeModulePath(const void* address, BinaryInfo* binInfo)
{
    if (address == nullptr || binInfo == nullptr || binInfo->filePathName.IsEmpty()) {
        return;
    }
    const char* reported = binInfo->filePathName.Str();
    if (reported == nullptr || reported[0] != '/') {
        return;
    }
    if (strstr(reported, "!/") != nullptr) {
        return;
    }
    // Keep a copy: assigning binInfo->filePathName below overwrites the FixedCString
    // buffer that "reported" points into.
    CString reportedPath(reported);
    const auto fail = [&reportedPath](const char* reason) {
        LOG(RTLOG_INFO, "resolve module path fail: path=%s reason=%s", reportedPath.Str(), reason);
    };

    ModuleImage image;
    if (!ResolveModuleImage(address, &image)) {
        fail("no_image");
        return;
    }
    size_t probeLen = std::min(kModuleProbeSize, image.fileBytes);
    if (probeLen < sizeof(ElfW(Ehdr))) {
        fail("image_too_small");
        return;
    }

    if (FilePrefixMatchesImage(reportedPath.Str(), image, probeLen)) {
        return;
    }

    CString entryName;
    if (!FindContainerEntry(reportedPath.Str(), image, probeLen, &entryName)) {
        fail("no_unique_entry");
        return;
    }

    size_t reportedLen = reportedPath.Length();
    if (reportedLen > kMaxModulePathLen || entryName.Length() > kMaxModulePathLen ||
        reportedLen + 2 + entryName.Length() >= kMaxModulePathLen) {
        fail("too_long");
        return;
    }
    CString canonical;
    canonical.EnsureSpace(reportedLen + 2 + entryName.Length());
    canonical.Append(reportedPath);
    canonical.Append("!/");
    canonical.Append(entryName);
    binInfo->filePathName = FixedCString(canonical.Str());
    LOG(RTLOG_INFO, "resolve module path: %s -> %s", reportedPath.Str(), canonical.Str());
}
#endif

} // namespace Os
} // namespace MapleRuntime
