// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_PAGEALLOCATOR_H
#define MRT_PAGEALLOCATOR_H

#include <pthread.h>
#if defined(__linux__) || defined(hongmeng) || defined(__APPLE__)
#include <sys/mman.h>
#endif
#include <atomic>
#include <cstdint>
#include <mutex>

#include "Base/Globals.h"
#include "Base/LogFile.h"
#include "Common/RunType.h"
#include "PagePool.h"

namespace MapleRuntime {
// when there is a need to use PageAllocator to manage
// the memory for a specific data structure, please add
// a new type
enum AllocationTag : uint32_t {
    // alllocation type for std container
    FINALIZER_PROCESSOR, // manage the std container in FinalizerProcessor
    ALLOCATOR,           // for Allocator
    MUTATOR_LIST,        // for mutator list
    GC_WORK_STACK,       // for gc mark and write barrier
    GC_TASK_QUEUE,       // for gc task queue
    STACK_PTR,           // for stack in stack_grow
    // more to come
    MAX_ALLOCATION_TAG
};

// constants and utility function
class AllocatorUtils {
public:
    AllocatorUtils() = delete;
    AllocatorUtils(const AllocatorUtils&) = delete;
    AllocatorUtils(AllocatorUtils&&) = delete;
    AllocatorUtils& operator=(const AllocatorUtils&) = delete;
    AllocatorUtils& operator=(AllocatorUtils&&) = delete;
    ~AllocatorUtils() = delete;
    static const size_t ALLOC_PAGE_SIZE;
    static constexpr uint32_t LOG_ALLOC_ALIGNMENT = 3;
    static constexpr uint32_t ALLOC_ALIGNMENT = 1 << LOG_ALLOC_ALIGNMENT;
};

// Allocator manages page allocation and deallocation
class PageAllocator {
    // slots in a page are managed as a linked list
    struct Slot {
        Slot* next = nullptr;
    };

    // pages are linked to each other as double-linked list.
    // the free slot list and other infomation are also in
    // the page header
    class Page {
        friend class PageAllocator;

    public:
        // get a slot from the free slot list
        inline void* Allocate()
        {
            void* result = nullptr;
            if (header != nullptr) {
                result = reinterpret_cast<void*>(header);
                header = header->next;
                --free;
            }
            return result;
        }

        // return a slot to the free slot list
        inline void Deallocate(void* slot)
        {
            Slot* cur = reinterpret_cast<Slot*>(slot);
            cur->next = header;
            header = cur;
            ++free;
        }

        inline bool Available() const { return free != 0; }

        inline bool Empty() const { return free == total; }

    private:
        Page* prev = nullptr;
        Page* next = nullptr;
        Slot* header = nullptr;
        uint16_t free = 0;
        uint16_t total = 0;
    };

public:
    PageAllocator() : nonFull(nullptr), totalPages(0), slotSize(0), slotAlignment(0) {}

    explicit PageAllocator(uint16_t size) : nonFull(nullptr), totalPages(0), slotSize(size)
    {
        slotAlignment = MapleRuntime::AlignUp<uint16_t>(size, AllocatorUtils::ALLOC_ALIGNMENT);
    }

    ~PageAllocator() = default;

    void Destroy() { DestroyList(nonFull); }

    void Init(uint16_t size)
    {
        slotSize = size;
        slotAlignment = MapleRuntime::AlignUp<uint16_t>(size, AllocatorUtils::ALLOC_ALIGNMENT);
    }

    // allocation entrypoint
    void* Allocate()
    {
        void* result = nullptr;
        {
            std::lock_guard<std::mutex> guard(allocLock);

            if (nonFull == nullptr) {
                Page* cur = CreatePage();
                InitPage(*cur);
                nonFull = cur;
                ++totalPages;
                LOG(RTLOG_DEBUG, "\ttotal pages mapped: %u, slot_size: %u", totalPages, slotSize);
            }

            result = nonFull->Allocate();

            if (!(nonFull->Available())) {
                // move from nonFull to full
                Page* cur = nonFull;
                RemoveFromList(nonFull, *cur);
            }
        }
        if (result != nullptr) {
            CHECK_DETAIL(memset_s(result, slotSize, 0, slotSize) == EOK, "memset_s fail");
        }
        return result;
    }

    // deallocation entrypoint
    void Deallocate(void* slot)
    {
        Page* cur = reinterpret_cast<Page*>(
            MapleRuntime::AlignDown<uintptr_t>(reinterpret_cast<uintptr_t>(slot), AllocatorUtils::ALLOC_PAGE_SIZE));

        std::lock_guard<std::mutex> guard(allocLock);
        if (!(cur->Available())) {
            // move from full to nonFull
            AddToList(nonFull, *cur);
        }
        cur->Deallocate(slot);
        if (cur->Empty()) {
            RemoveFromList(nonFull, *cur);
            DestroyPage(*cur);
            --totalPages;
            LOG(RTLOG_DEBUG, "\ttotal pages mapped: %u, slot_size: %u", totalPages, slotSize);
        }
    }

private:
    // get a page from os
    static inline Page* CreatePage() { return reinterpret_cast<Page*>(PagePool::Instance().GetPage()); }

    // return the page to os
    static inline void DestroyPage(Page& page)
    {
        CHECK_DETAIL(page.free == page.total, "\t destroy page in use: total = %u, free = %u", page.total, page.free);
        DLOG(ALLOC, "\t destroy page %p total = %u, free = %u", &page, page.total, page.free);
        PagePool::Instance().ReturnPage(reinterpret_cast<uint8_t*>(&page));
    }

    // construct the data structure of a new allocated page
    void InitPage(Page& page)
    {
        page.prev = nullptr;
        page.next = nullptr;
        constexpr uint32_t offset = MapleRuntime::AlignUp<uint32_t>(sizeof(Page), AllocatorUtils::ALLOC_ALIGNMENT);
        page.free = (AllocatorUtils::ALLOC_PAGE_SIZE - offset) / slotAlignment;
        page.total = page.free;
        CHECK_DETAIL(page.free >= 1, "use the wrong allocator! slot size = %u", slotAlignment);

        char* start = reinterpret_cast<char*>(&page);
        char* end = start + AllocatorUtils::ALLOC_PAGE_SIZE - 1;
        char* slot = start + offset;
        page.header = reinterpret_cast<Slot*>(slot);
        Slot* prevSlot = page.header;
        while (true) {
            slot += slotAlignment;
            char* slotEnd = slot + slotAlignment - 1;
            if (slotEnd > end) {
                break;
            }

            Slot* cur = reinterpret_cast<Slot*>(slot);
            prevSlot->next = cur;
            prevSlot = cur;
        }

        DLOG(ALLOC,
             "new page start = %p, end = %p, slot header = %p, total slots = %u, slot size = %u, sizeof(Page) = %u",
             start, end, page.header, page.total, slotAlignment, sizeof(Page));
    }

    // linked-list management
    inline void AddToList(Page*& list, Page& page) const
    {
        if (list != nullptr) {
            list->prev = &page;
        }
        page.next = list;
        list = &page;
    }

    inline void RemoveFromList(Page*& list, Page& page) const
    {
        Page* prev = page.prev;
        Page* next = page.next;
        if (&page == list) {
            list = next;
            if (next != nullptr) {
                next->prev = nullptr;
            }
        } else {
            prev->next = next;
            if (next != nullptr) {
                next->prev = prev;
            }
        }
        page.next = nullptr;
        page.prev = nullptr;
    }

    inline void DestroyList(Page*& list)
    {
        Page* cur = nullptr;
        while (list != nullptr) {
            cur = list;
            list = list->next;
            DestroyPage(*cur);
        }
    }

    Page* nonFull;
    std::mutex allocLock;
    uint32_t totalPages;
    uint16_t slotSize;
    uint16_t slotAlignment;
};

// Utility class used for StdContainerAllocator
// It has lots of PageAllocators, each for different slot size,
// so all allocation sizes can be handled by this bridge class.
class AggregateAllocator {
public:
    static constexpr uint32_t MAX_ALLOCATORS = 53;

    ATTR_NO_INLINE MRT_EXPORT static AggregateAllocator& Instance(AllocationTag tag);

    AggregateAllocator()
    {
        for (uint32_t i = 0; i < MAX_ALLOCATORS; ++i) {
            allocator[i].Init(static_cast<uint16_t>(RUNTYPE_RUN_IDX_TO_SIZE(i)));
        }
    }
    ~AggregateAllocator() = default;

    // choose appropriate allocation to allocate
    void* Allocate(size_t size)
    {
        uint32_t alignedSize = MapleRuntime::AlignUp(static_cast<uint32_t>(size), AllocatorUtils::ALLOC_ALIGNMENT);
        if (alignedSize <= RUN_ALLOC_LARGE_SIZE) {
            uint32_t index = RUNTYPE_SIZE_TO_RUN_IDX(alignedSize);
            return allocator[index].Allocate();
        } else {
            return PagePool::Instance().GetPage(size);
        }
    }

    ATTR_NO_INLINE void Deallocate(void* p, size_t size)
    {
        uint32_t alignedSize = MapleRuntime::AlignUp(static_cast<uint32_t>(size), AllocatorUtils::ALLOC_ALIGNMENT);
        if (alignedSize <= RUN_ALLOC_LARGE_SIZE) {
            uint32_t index = RUNTYPE_SIZE_TO_RUN_IDX(alignedSize);
            allocator[index].Deallocate(p);
        } else {
            PagePool::Instance().ReturnPage(reinterpret_cast<uint8_t*>(p), size);
        }
    }

private:
    PageAllocator allocator[MAX_ALLOCATORS];
};

// Allocator used to take control of memory allocation for std containers.
// It uses AggregateAllocator to dispatch the memory operation to appropriate PageAllocator.
template<class T, AllocationTag cat>
class StdContainerAllocator {
public:
    using size_type = size_t;
    using difference_type = ptrdiff_t;
    using pointer = T*;
    using const_pointer = const T*;
    using reference = T&;
    using const_reference = const T&;
    using value_type = T;

    using propagate_on_container_copy_assignment = std::false_type;
    using propagate_on_container_move_assignment = std::true_type;
    using propagate_on_container_swap = std::true_type;

    template<class Up>
    struct rebind {
        using other = StdContainerAllocator<Up, cat>;
    };

    StdContainerAllocator() = default;
    ~StdContainerAllocator() = default;

    template<class U>
    StdContainerAllocator(const StdContainerAllocator<U, cat>&) {}

    StdContainerAllocator(const StdContainerAllocator<T, cat>&) {}

    StdContainerAllocator(StdContainerAllocator<T, cat>&&) {}

    StdContainerAllocator<T, cat>& operator=(const StdContainerAllocator<T, cat>&) { return *this; }

    StdContainerAllocator<T, cat>& operator=(StdContainerAllocator<T, cat>&&) { return *this; }

    pointer address(reference x) const { return std::addressof(x); }

    const_pointer address(const_reference x) const { return std::addressof(x); }

    pointer allocate(size_type n, const void* hint __attribute__((unused)) = 0)
    {
        pointer result = static_cast<pointer>(AggregateAllocator::Instance(cat).Allocate(sizeof(T) * n));
        return result;
    }

    void deallocate(pointer p, size_type n) { AggregateAllocator::Instance(cat).Deallocate(p, sizeof(T) * n); }

    size_type max_size() const { return static_cast<size_type>(~0) / sizeof(value_type); }

    void construct(pointer p, const_reference val) { ::new (reinterpret_cast<void*>(p)) value_type(val); }

    template<class Up, class... Args>
    void construct(Up* p, Args&&... args)
    {
        ::new (reinterpret_cast<void*>(p)) Up(std::forward<Args>(args)...);
    }

    void destroy(pointer p) { p->~value_type(); }
};
// vector::swap requires that the allocator defined by ourselves should be comparable during compiling period,
// so we overload operator == and return true.
template<typename Tp, AllocationTag tag>
inline bool operator==(const StdContainerAllocator<Tp, tag>&, const StdContainerAllocator<Tp, tag>&) noexcept
{
    return true;
}
template<typename Tp, AllocationTag tag>
inline bool operator!=(const StdContainerAllocator<Tp, tag>&, const StdContainerAllocator<Tp, tag>&) noexcept
{
    return false;
}

#ifdef __APPLE__
template<typename T>
using ManagedList = std::list<T>;
#else
template<typename T>
using ManagedList = std::list<T, StdContainerAllocator<T, FINALIZER_PROCESSOR>>;
#endif
} // namespace MapleRuntime
#endif
