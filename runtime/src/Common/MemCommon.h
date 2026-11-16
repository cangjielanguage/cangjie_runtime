// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_MEM_COMMON_H
#define MRT_MEM_COMMON_H

#include <algorithm>
#include <mutex>
#include <thread>
#include <unordered_map>

#include "PagePool.h"

namespace MapleRuntime {
using pageID = unsigned long long;
// The maximum number of pages that PageCache can allocate
constexpr size_t MAX_NPAGES = 129;
// Calculate the page number and the starting address of the page using bitwise shift operations
constexpr size_t PAGE_SHIFT = 12;
// The maximum memory space that ThreadCache can allocate
constexpr size_t MAX_BYTES = 256 * 1024;
// Number of buckets in the free linked list of small fixed-length memory. The rule is defined in SizeManager.
constexpr size_t NFREELIST = 208;
constexpr int MIN_ALIGN_NUM = 8;

enum class AlignNum { ALIGN_8 = 8, ALIGN_16 = 16, ALIGN_128 = 128, ALIGN_1024 = 1024, ALIGN_8192 = 8 * 1024 };

enum MemberSize {
    ALING_8_BYTE = 128,
    ALING_16_BYTE = 1024,
    ALING_128_BYTE = 8 * 1024,
    ALING_1024_BYTE = 64 * 1024,
    ALING_8192_BYTE = 256 * 1024,
};

enum AlignShift { ALIGN_8_SIFT = 3, ALIGN_16_SIFT = 4, ALIGN_128_SIFT = 7, ALIGN_1024_SIFT = 10, ALIGN_8192_SIFT = 13 };

// Allocate memory resources from the system
inline void* SystemAlloc(size_t kpage)
{
    return PagePool::Instance().GetPage(kpage * MapleRuntime::MRT_PAGE_SIZE);
}

// Return a reference to the first 4 or 8 bytes of the passed-in space
inline void*& NextObj(void* obj)
{
    CHECK(obj != nullptr);
    return *(void**)obj;
}

// The free list used to store the small fixed-size memory blocks after splitting.
class FreeList {
public:
    void PushFront(void* obj)
    {
        CHECK(obj != nullptr);

        NextObj(obj) = freeList;
        freeList = obj;
        ++size;
    }
    void* PopFront()
    {
        CHECK(!Empty());

        void* obj = freeList;
        freeList = NextObj(obj);
        --size;

        return obj;
    }

    void PushAtFront(void* start, void* end, size_t n)
    {
        CHECK(start != nullptr);
        CHECK(end != nullptr);
        CHECK(n > 0);

        NextObj(end) = freeList;
        freeList = start;
        size += n;
    }

    void PopAtFront(void*& start, size_t n)
    {
        CHECK(n <= size);

        start = freeList;
        void* end = freeList;
        for (size_t i = 0; i < n - 1; ++i) {
            end = NextObj(end);
        }
        freeList = NextObj(end);
        NextObj(end) = nullptr;
        size -= n;
    }

    bool Empty() { return size == 0; }

    size_t& GetAdjustSize() { return adjustSize; }

    size_t GetSize() { return size; }

private:
    size_t size = 0;       // The number of small fixed-size memory blocks
    size_t adjustSize = 1; // The slow-start adjustment value for requesting memory from the central cache.
    void* freeList = nullptr;
};

// Calculate the alignment mapping rule for the size of the incoming object and the small fixed-size memory block.
class SizeManager {
public:
    // [1,128]                     8byte align           freelists[0,16)
    // [128+1,1024]                16byte align          freelists[16,72)
    // [1024+1,8*1024]             128byte align         freelists[72,128)
    // [8*1024+1,64*1024]          1024byte align        freelists[128,184)
    // [64*1024+1,256*1024]        8*1024byte align      freelists[184,208)
    // Calculate which free list bucket it maps to.
    static constexpr int GROUP_ARRAY[4] = { 16, 56, 56, 56 };

    static inline size_t RoundUp(size_t bytes)
    {
        if (bytes <= MemberSize::ALING_8_BYTE) {
            return RoundUp(bytes, AlignNum::ALIGN_8);
        } else if (bytes <= MemberSize::ALING_16_BYTE) {
            return RoundUp(bytes, AlignNum::ALIGN_16);
        } else if (bytes <= MemberSize::ALING_128_BYTE) {
            return RoundUp(bytes, AlignNum::ALIGN_128);
        } else if (bytes <= MemberSize::ALING_1024_BYTE) {
            return RoundUp(bytes, AlignNum::ALIGN_1024);
        } else if (bytes <= MemberSize::ALING_8192_BYTE) {
            return RoundUp(bytes, AlignNum::ALIGN_8192);
        } else {
            return -1;
        }
    }

    static inline size_t Index(size_t bytes)
    {
        // Determine the index of the free list bucket corresponding to the size of the incoming object.
        if (bytes <= MemberSize::ALING_8_BYTE) {
            return Index(bytes, ALIGN_8_SIFT);
        } else if (bytes <= MemberSize::ALING_16_BYTE) {
            return Index(bytes - MemberSize::ALING_8_BYTE, ALIGN_16_SIFT) + GROUP_ARRAY[0];
        } else if (bytes <= MemberSize::ALING_128_BYTE) {
            return Index(bytes - MemberSize::ALING_16_BYTE, ALIGN_128_SIFT) +
                GROUP_ARRAY[1] + GROUP_ARRAY[0];
        } else if (bytes <= MemberSize::ALING_1024_BYTE) {
            return Index(bytes - MemberSize::ALING_128_BYTE, ALIGN_1024_SIFT) +
                GROUP_ARRAY[2] + GROUP_ARRAY[1] + GROUP_ARRAY[0];
        } else if (bytes <= MemberSize::ALING_8192_BYTE) {
            return Index(bytes - MemberSize::ALING_1024_BYTE, ALIGN_8192_SIFT) +
                GROUP_ARRAY[3] + GROUP_ARRAY[2] + GROUP_ARRAY[1] + GROUP_ARRAY[0];
        } else {
            return -1;
        }
    }

    // The upper and lower limits of the number of small fixed-size memory block,
    //     that ThreadCache can batch-fetch from the central cache at one time.
    static size_t LimitSize(size_t alignBytes)
    {
        CHECK(alignBytes != 0);
        constexpr int underLimit = 2;
        constexpr int upperLimit = 512;

        // [2, 512], the upper limit of the number of objects to be batch-moved (slow start)
        // For large objects (up to 256KB), the lower limit for a single batch is 2 objects
        // For small objects (down to 8 bytes), the upper limit for a single batch is 512 objects
        size_t num = MAX_BYTES / alignBytes;
        if (num < underLimit) {
            num = underLimit;
        }
        if (num > upperLimit) {
            num = upperLimit;
        }

        return num;
    }

    static size_t CalculatePageNum(size_t alignBytes)
    {
        size_t num = LimitSize(alignBytes);
        size_t npage = num * alignBytes;

        npage >>= PAGE_SHIFT;
        if (npage == 0) {
            npage = 1;
        }

        return npage;
    }

private:
    static inline size_t RoundUp(size_t bytes, AlignNum alignment)
    {
        size_t alignNum = static_cast<size_t>(alignment);
        return ((bytes + alignNum - 1) & ~(alignNum - 1));
    }

    static inline size_t Index(size_t bytes, size_t alignShift)
    {
        return ((bytes + (1 << alignShift) - 1) >> alignShift) - 1;
    }
};

// Span manages a large block of memory in units of pages.
struct Span {
    size_t pageNum = 0; // number of page
    pageID pageId = 0;  // page if of first page
    Span* next = nullptr;
    Span* prev = nullptr;
    size_t useCount = 0;
    void* freeBlocks = nullptr;
    bool isUse = false;
};

// The doubly linked circular list with a header node for managing spans.
class SpanList {
public:
    SpanList()
    {
        head->prev = head;
        head->next = head;
    }

    ~SpanList()
    {
        while (!Empty()) {
            Span* span = PopFront();
            delete span;
        }
        delete head;
    }

    void Insert(Span* pos, Span* newSpan)
    {
        CHECK(pos != nullptr);
        CHECK(newSpan != nullptr);
        Span* prev = pos->prev;
        prev->next = newSpan;
        newSpan->prev = prev;
        newSpan->next = pos;
        pos->prev = newSpan;
    }

    void Erase(Span* pos)
    {
        CHECK(pos != nullptr);
        CHECK(pos != head); // The sentinel header node must not be deleted.
        Span* prev = pos->prev;
        Span* next = pos->next;
        prev->next = next;
        next->prev = prev;
    }

    Span* Begin() { return head->next; }

    Span* End() { return head; }

    bool Empty() { return Begin() == head; }

    Span* PopFront()
    {
        CHECK(!Empty());

        Span* ret = Begin();
        Erase(Begin());
        return ret;
    }

    void PushFront(Span* span)
    {
        CHECK(span != nullptr);

        Insert(Begin(), span);
    }

    std::mutex& GetSpanListMutex() { return mtx; }

private:
    Span* head = new Span;
    std::mutex mtx;
};
} // namespace MapleRuntime
#endif
