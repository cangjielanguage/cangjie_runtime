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
static_assert(sizeof(off_t) >= sizeof(uint64_t),
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

// Structural constants shared by more than one function of the ZIP lookup below.
// Offsets with a single user are defined next to that user instead.
constexpr size_t kEocdSize = 22;                    // EOCD fixed part; its comment follows
constexpr size_t kZip64ValueFieldWidth = 8;         // 64-bit values inside the Zip64 extra

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

// Composes `width` little-endian bytes into one value; the sized wrappers below
// are its only callers and keep the read sites' types explicit.
uint64_t ReadLe(const uint8_t* bytes, size_t width)
{
    constexpr size_t kBitsPerByte = 8;
    uint64_t value = 0;
    for (size_t i = 0; i < width; ++i) {
        value |= static_cast<uint64_t>(bytes[i]) << (kBitsPerByte * i);
    }
    return value;
}

uint16_t ReadLe16(const uint8_t* p)
{
    return static_cast<uint16_t>(ReadLe(p, sizeof(uint16_t)));
}

uint32_t ReadLe32(const uint8_t* p)
{
    return static_cast<uint32_t>(ReadLe(p, sizeof(uint32_t)));
}

uint64_t ReadLe64(const uint8_t* p)
{
    return ReadLe(p, sizeof(uint64_t));
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
    *out = (width == kZip64ValueFieldWidth) ? ReadLe64(extra + *cur) : ReadLe32(extra + *cur);
    *cur += width;
    return true;
}

bool ParseZip64Extra(const uint8_t* extra, size_t extraLen, bool needUncompressed, bool needCompressed,
    bool needOffset, bool needDisk, uint64_t* uncompressed, uint64_t* compressed, uint64_t* localOffset,
    uint32_t* diskStart)
{
    // Zip64 extra header: field id(2) + size(2); disk-start is the only 32-bit field.
    constexpr size_t kZip64ExtraHeaderSize = 4;
    constexpr size_t kZip64DiskFieldWidth = 4;
    size_t pos = 0;
    while (pos + kZip64ExtraHeaderSize <= extraLen) {
        uint16_t fieldId = ReadLe16(extra + pos);
        uint16_t fieldSize = ReadLe16(extra + pos + sizeof(uint16_t));
        pos += kZip64ExtraHeaderSize;
        if (pos + fieldSize > extraLen) {
            return false;
        }
        if (fieldId != kZip64ExtraFieldId) {
            pos += fieldSize;
            continue;
        }
        size_t cur = pos;
        size_t end = pos + fieldSize;
        if (needUncompressed && !ReadZip64Field(extra, end, &cur, kZip64ValueFieldWidth, uncompressed)) {
            return false;
        }
        if (needCompressed && !ReadZip64Field(extra, end, &cur, kZip64ValueFieldWidth, compressed)) {
            return false;
        }
        if (needOffset && !ReadZip64Field(extra, end, &cur, kZip64ValueFieldWidth, localOffset)) {
            return false;
        }
        if (needDisk) {
            uint64_t disk = 0;
            if (!ReadZip64Field(extra, end, &cur, kZip64DiskFieldWidth, &disk)) {
                return false;
            }
            *diskStart = static_cast<uint32_t>(disk);
        }
        return true;
    }
    return false;
}

// Scans the file tail backwards for the last EOCD whose comment still fits
// inside the tail. Returns its offset relative to the tail start, or -1.
int64_t FindEocdInTail(const uint8_t* tail, size_t tailSize)
{
    constexpr size_t kEocdCommentLenOffset = 20;  // comment length field inside the EOCD
    for (int64_t i = static_cast<int64_t>(tailSize - kEocdSize); i >= 0; --i) {
        if (ReadLe32(tail + static_cast<size_t>(i)) != kZipEndOfCentralDirectorySignature) {
            continue;
        }
        uint16_t commentLen = ReadLe16(tail + static_cast<size_t>(i) + kEocdCommentLenOffset);
        if (static_cast<uint64_t>(i) + kEocdSize + commentLen <= tailSize) {
            return i;
        }
    }
    return -1;
}

// Resolves EOCD sentinel fields from the Zip64 locator and Zip64 EOCD record.
// Any read/bounds/signature failure fails the whole lookup: no fallback to the
// 32-bit values.
bool ReadZip64EndOfCentralDirectory(int fd, uint64_t eocdOffset, uint64_t fileSize, uint64_t* entryCount,
    uint64_t* cdSize, uint64_t* cdOffset)
{
    // Structural constants of the Zip64 locator and EOCD record (offsets are
    // relative to the start of the owning record).
    constexpr size_t kZip64LocatorSize = 20;
    constexpr size_t kZip64LocatorEocdOffset = 8;
    constexpr size_t kZip64RecordSize = 56;
    constexpr size_t kZip64EntryCountOffset = 32;
    constexpr size_t kZip64CdSizeOffset = 40;
    constexpr size_t kZip64CdStartOffset = 48;
    if (eocdOffset < kZip64LocatorSize) {
        return false;
    }
    uint8_t locator[kZip64LocatorSize];
    if (!PreadExact(fd, locator, sizeof(locator), eocdOffset - kZip64LocatorSize) ||
        ReadLe32(locator) != kZip64EndOfCentralDirectoryLocatorSignature) {
        return false;
    }
    // Zip64 locator: sig(4) disk-with-zip64-eocd(4) zip64-eocd-offset(8 @8) total-disks(4 @16).
    uint64_t zip64Offset = ReadLe64(locator + kZip64LocatorEocdOffset);
    uint8_t record[kZip64RecordSize];
    if (zip64Offset > fileSize || fileSize - zip64Offset < sizeof(record) ||
        !PreadExact(fd, record, sizeof(record), zip64Offset) ||
        ReadLe32(record) != kZip64EndOfCentralDirectorySignature) {
        return false;
    }
    // Zip64 EOCD: entries-on-disk(8 @24), entries-total(8 @32), cd-size(8 @40), cd-offset(8 @48).
    *entryCount = ReadLe64(record + kZip64EntryCountOffset);
    *cdSize = ReadLe64(record + kZip64CdSizeOffset);
    *cdOffset = ReadLe64(record + kZip64CdStartOffset);
    return true;
}

bool ReadCentralDirectoryInfo(int fd, uint64_t fileSize, uint64_t* entryCount, uint64_t* cdSize,
    uint64_t* cdOffset)
{
    // EOCD field offsets used only here; kEocdSize itself is shared with the tail scan.
    constexpr uint16_t kEocdMaxCommentLen = 65535;
    constexpr size_t kEocdEntryCountOffset = 10;  // entries-total field inside the EOCD
    constexpr size_t kEocdCdSizeOffset = 12;      // central-directory size field inside the EOCD
    constexpr size_t kEocdCdStartOffset = 16;     // central-directory offset field inside the EOCD
    if (entryCount == nullptr || cdSize == nullptr || cdOffset == nullptr || fileSize < kEocdSize) {
        return false;
    }
    // EOCD is at least 22 bytes; its trailing comment is at most 0xffff bytes.
    const uint64_t kTailMax = kEocdSize + kEocdMaxCommentLen;
    uint64_t tailSize64 = std::min(fileSize, kTailMax);
    size_t tailSize = static_cast<size_t>(tailSize64);
    std::vector<uint8_t> tail(tailSize);
    if (!PreadExact(fd, tail.data(), tailSize, fileSize - tailSize64)) {
        return false;
    }
    int64_t eocdRel = FindEocdInTail(tail.data(), tailSize);
    if (eocdRel < 0) {
        return false;
    }
    // EOCD fixed fields: entries-on-this-disk(2 @8), entries-total(2 @10),
    // central-directory-size(4 @12), central-directory-offset(4 @16), comment-len(2 @20).
    uint16_t entryCount16 = ReadLe16(tail.data() + static_cast<size_t>(eocdRel) + kEocdEntryCountOffset);
    uint32_t cdSize32 = ReadLe32(tail.data() + static_cast<size_t>(eocdRel) + kEocdCdSizeOffset);
    uint32_t cdOffset32 = ReadLe32(tail.data() + static_cast<size_t>(eocdRel) + kEocdCdStartOffset);
    *entryCount = entryCount16;
    *cdSize = cdSize32;
    *cdOffset = cdOffset32;

    // Sentinel values mean the real value lives in the Zip64 record.
    if (entryCount16 == kZip16Sentinel || cdSize32 == kZip32Sentinel || cdOffset32 == kZip32Sentinel) {
        uint64_t eocdOffset = fileSize - tailSize64 + static_cast<uint64_t>(eocdRel);
        return ReadZip64EndOfCentralDirectory(fd, eocdOffset, fileSize, entryCount, cdSize, cdOffset);
    }
    return true;
}

// Central directory header is 46 bytes fixed:
// sig(4) verMade(2) verNeed(2) flags(2 @8) method(2 @10) mtime(2 @12) mdate(2 @14)
// crc(4 @16) compressedSize(4 @20) uncompressedSize(4 @24) nameLen(2 @28) extraLen(2 @30)
// commentLen(2 @32) diskStart(2 @34) intAttr(2 @36) extAttr(4 @38) localOffset(4 @42).
struct CentralDirectoryHeader {
    uint16_t flags;
    uint16_t method;
    uint64_t compressed;
    uint64_t uncompressed;
    uint16_t nameLen;
    uint16_t extraLen;
    uint16_t commentLen;
    uint16_t diskStart;
    uint64_t localOffset;
};

void ReadCentralDirectoryHeader(const uint8_t* p, CentralDirectoryHeader* h)
{
    // Central directory header field offsets, relative to the header start.
    constexpr size_t kCdFlagsOffset = 8;
    constexpr size_t kCdMethodOffset = 10;
    constexpr size_t kCdCompressedSizeOffset = 20;
    constexpr size_t kCdUncompressedSizeOffset = 24;
    constexpr size_t kCdNameLenOffset = 28;
    constexpr size_t kCdExtraLenOffset = 30;
    constexpr size_t kCdCommentLenOffset = 32;
    constexpr size_t kCdDiskStartOffset = 34;
    constexpr size_t kCdLocalHeaderOffset = 42;
    h->flags = ReadLe16(p + kCdFlagsOffset);
    h->method = ReadLe16(p + kCdMethodOffset);
    h->compressed = ReadLe32(p + kCdCompressedSizeOffset);
    h->uncompressed = ReadLe32(p + kCdUncompressedSizeOffset);
    h->nameLen = ReadLe16(p + kCdNameLenOffset);
    h->extraLen = ReadLe16(p + kCdExtraLenOffset);
    h->commentLen = ReadLe16(p + kCdCommentLenOffset);
    h->diskStart = ReadLe16(p + kCdDiskStartOffset);
    h->localOffset = ReadLe32(p + kCdLocalHeaderOffset);
}

// Resolves the header's ZIP64 sentinel fields in place and decides whether the
// entry is usable. Returns false to skip this entry (not the whole archive): a
// malformed ZIP64 extra, or the entry starts on a nonzero disk.
bool EntryIsUsable(const uint8_t* p, CentralDirectoryHeader* h)
{
    bool needUncompressed = h->uncompressed == kZip32Sentinel;
    bool needCompressed = h->compressed == kZip32Sentinel;
    bool needOffset = h->localOffset == kZip32Sentinel;
    bool needDisk = h->diskStart == kZip16Sentinel;
    if (needUncompressed || needCompressed || needOffset || needDisk) {
        uint32_t disk32 = h->diskStart;
        if (!ParseZip64Extra(p + kZipCentralDirectoryHeaderSize + h->nameLen, h->extraLen, needUncompressed,
            needCompressed, needOffset, needDisk, &h->uncompressed, &h->compressed, &h->localOffset, &disk32)) {
            return false;  // malformed ZIP64 extra: skip the entry, not the archive
        }
        if (needDisk && disk32 != 0) {
            return false;  // entry starts on another disk of a multi-part archive
        }
    }
    if (!needDisk && h->diskStart != 0) {
        return false;  // entry starts on another disk of a multi-part archive
    }
    return true;
}

// Collects the entry when it is a structurally valid load candidate: not
// encrypted, stored, with a non-empty safe name and payload.
void MaybeCollectEntry(const uint8_t* p, const CentralDirectoryHeader& h, std::vector<ContainerEntry>* entries)
{
    if ((h.flags & kZipEncryptedFlag) != 0 || h.method != 0 || h.nameLen == 0 || h.uncompressed == 0) {
        return;
    }
    CString name;
    name.EnsureSpace(h.nameLen);
    name.Append(reinterpret_cast<const char*>(p + kZipCentralDirectoryHeaderSize), h.nameLen);
    // Deliberately no extension/name filter: the mapped entry may have any
    // name (Android maps stored, page-aligned entries via "container!/entry"
    // regardless of suffix), and filtering here could drop the real entry or
    // shrink a genuine duplicate match into a false unique one. The checks
    // above plus the later ELF magic and content comparison decide identity;
    // uniqueness is judged over every entry that passes them.
    if (!IsSafeEntryName(name)) {
        return;
    }
    ContainerEntry entry;
    entry.name = name;
    entry.localHeaderOffset = h.localOffset;
    entry.uncompressedSize = h.uncompressed;
    entries->push_back(entry);
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
        const uint8_t* p = cd + pos;
        if (ReadLe32(p) != kZipCentralDirectorySignature) {
            return false;
        }
        CentralDirectoryHeader h;
        ReadCentralDirectoryHeader(p, &h);
        uint64_t total = kZipCentralDirectoryHeaderSize + h.nameLen + h.extraLen + h.commentLen;
        if (total > static_cast<uint64_t>(cdSize - pos)) {
            return false;
        }
        if (!EntryIsUsable(p, &h)) {
            pos += static_cast<size_t>(total);
            ++parsed;
            continue;
        }
        MaybeCollectEntry(p, h, entries);
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
    constexpr size_t kMaxReserveEntries = 4096;  // cap the entry vector's upfront allocation
    entries->reserve(static_cast<size_t>(std::min<uint64_t>(entryCount, kMaxReserveEntries)));
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
    // Local file header field offsets, relative to the header start.
    constexpr size_t kLocalHeaderNameLenOffset = 26;
    constexpr size_t kLocalHeaderExtraLenOffset = 28;
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
    uint16_t localNameLen = ReadLe16(localHeader + kLocalHeaderNameLenOffset);
    uint16_t localExtraLen = ReadLe16(localHeader + kLocalHeaderExtraLenOffset);
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

    constexpr size_t kContainerEntrySeparatorLen = 2;  // "!/" between container path and entry name
    size_t reportedLen = reportedPath.Length();
    if (reportedLen > kMaxModulePathLen || entryName.Length() > kMaxModulePathLen ||
        reportedLen + kContainerEntrySeparatorLen + entryName.Length() >= kMaxModulePathLen) {
        fail("too_long");
        return;
    }
    CString canonical;
    canonical.EnsureSpace(reportedLen + kContainerEntrySeparatorLen + entryName.Length());
    canonical.Append(reportedPath);
    canonical.Append("!/");
    canonical.Append(entryName);
    binInfo->filePathName = FixedCString(canonical.Str());
    LOG(RTLOG_INFO, "resolve module path: %s -> %s", reportedPath.Str(), canonical.Str());
}
#endif

} // namespace Os
} // namespace MapleRuntime
