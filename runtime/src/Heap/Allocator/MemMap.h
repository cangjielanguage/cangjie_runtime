// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_ALLOC_MEM_MAP_H
#define MRT_ALLOC_MEM_MAP_H

#ifdef _WIN64
#include <handleapi.h>
#include <memoryapi.h>
#else
#include <sys/mman.h>
#endif
#include "AllocUtil.h"
#include "Common/TypeDef.h"

namespace MapleRuntime {
class MemMap {
public:
#ifdef _WIN64
    static constexpr int MAP_PRIVATE = 2;
    static constexpr int MAP_FIXED = 0x10;
    static constexpr int MAP_ANONYMOUS = 0x20;
    static constexpr int PROT_NONE = 0;
    static constexpr int PROT_READ = 1;
    static constexpr int PROT_WRITE = 2;
    static constexpr int PROT_EXEC = 4;
    static constexpr int DEFAULT_MEM_FLAGS = MAP_PRIVATE | MAP_ANONYMOUS;
#else
    static constexpr int DEFAULT_MEM_FLAGS = MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE;
#endif
    static constexpr int DEFAULT_MEM_PROT = PROT_READ | PROT_WRITE;

    struct Option {         // optional args for mem map
        const char* tag;    // name to identify the mapped memory
        void* reqBase;      // a hint to mmap about start addr, not guaranteed
        unsigned int flags; // mmap flags
        int prot;           // initial access flags
        bool protAll;       // applying prot to all pages in range
    };
    // by default, it tries to map memory in low addr space, with a random start
    static constexpr Option DEFAULT_OPTIONS = { "maple_unnamed", nullptr, DEFAULT_MEM_FLAGS, DEFAULT_MEM_PROT, false };

    // the only way to get a MemMap
    static MemMap* MapMemory(size_t reqSize, size_t initSize, const Option& opt = DEFAULT_OPTIONS);

#ifdef _WIN64
    static void CommitMemory(void* addr, size_t size);
#endif

    // destroy a MemMap
    static void DestroyMemMap(MemMap*& memMap) noexcept
    {
        if (memMap != nullptr) {
            delete memMap;
            memMap = nullptr;
        }
    }

    void* GetBaseAddr() const { return memBaseAddr; }
    void* GetCurrEnd() const { return memCurrEndAddr; }
    void* GetMappedEndAddr() const { return memMappedEndAddr; }
    size_t GetCurrSize() const { return memCurrSize; }
    size_t GetMappedSize() const { return memMappedSize; }

    ~MemMap();
    MemMap(const MemMap& that) = delete;
    MemMap(MemMap&& that) = delete;
    MemMap& operator=(const MemMap& that) = delete;
    MemMap& operator=(MemMap&& that) = delete;

private:
#if defined(__APPLE__)
    static void* MapMemoryOnApple(void* reqBase, size_t reqSize, size_t initSize, const Option& opt);
#endif
    static bool ProtectMemInternal(void* addr, size_t size, int prot);

    void* memBaseAddr;      // start of the mapped memory
    void* memCurrEndAddr;   // end of the memory **in use**
    void* memMappedEndAddr; // end of the mapped memory, always >= currEndAddr
    size_t memCurrSize;     // size of the memory **in use**
    size_t memMappedSize;   // size of the mapped memory, always >= currSize

    // MemMap is created via factory method
    MemMap(void* baseAddr, size_t initSize, size_t mappedSize);
}; // class MemMap
} // namespace MapleRuntime
#endif // MRT_ALLOC_MEM_MAP_H
