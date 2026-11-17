// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_SATB_BUFFER_H
#define MRT_SATB_BUFFER_H

#include "Base/Panic.h"
#include "Common/PagePool.h"
#include "Common/MarkWorkStack.h"
#include "Heap/Allocator/RegionInfo.h"
namespace MapleRuntime {
// snapshot at the beginning buffer
// mainly used to buffer modified field of mutator write
class SatbBuffer {
public:
    static constexpr size_t INITIAL_PAGES = 64;    // 64 pages of initial satb buffer
    static constexpr size_t CACHE_LINE_ALIGN = 64; // for most hardware platfrom, the cache line is 64-byte aigned.
    static SatbBuffer& Instance() noexcept;
    class Node {
        friend class SatbBuffer;

    public:
        Node() : top(objectContainer), next(nullptr) {}
        ~Node() = default;
        bool IsEmpty() const { return reinterpret_cast<size_t>(top) == reinterpret_cast<size_t>(objectContainer); }
        bool IsFull() const
        {
            static_assert((sizeof(Node) % sizeof(BaseObject**)) == 0, "Satb node must be aligned");
            return top == &objectContainer[CONTAINER_CAPACITY];
        }
        void Clear()
        {
            size_t size = reinterpret_cast<Uptr>(top) - reinterpret_cast<Uptr>(objectContainer);
            CHECK_DETAIL((memset_s(objectContainer, sizeof(objectContainer), 0, size) == EOK),
                         "SATB node clear failed, bytes: %zu, capacity: %zu", size, sizeof(objectContainer));
            top = objectContainer;
        }
        void Push(const BaseObject* obj)
        {
            std::lock_guard<std::mutex> lg(syncLock);
            *top = const_cast<BaseObject*>(obj);
            top++;
        }
        template<typename T>
        void GetObjects(T& stack)
        {
            MRT_ASSERT(top <= &objectContainer[CONTAINER_CAPACITY], "invalid node");
            std::lock_guard<std::mutex> lg(syncLock);
            BaseObject** head = objectContainer;
            while (head != top) {
                stack.push_back(*head);
                head++;
            }
            Clear();
        }

    private:
#if defined(_WIN64)
        static constexpr size_t CONTAINER_CAPACITY = 69;
#elif defined(__aarch64__) || defined(__arm__)
        static constexpr size_t CONTAINER_CAPACITY = 64;
#else
        static constexpr size_t CONTAINER_CAPACITY = 65;
#endif
        std::mutex syncLock;
        BaseObject** top;
        Node* next;
        BaseObject* objectContainer[CONTAINER_CAPACITY] = { nullptr };
    };

    static constexpr size_t NODE_SIZE = sizeof(Node);
    struct Page {
        Page(Page* n, size_t bytes) : next(n), length(bytes) {}
        Page* next = nullptr;
        size_t length = 0;
    };

    // there is no need to use LL/SC to avoid ABA problem, because Nodes are all unique.
    template<typename T>
    class LockFreeList {
        friend class SatbBuffer;

    public:
        LockFreeList() : head(nullptr) {}
        ~LockFreeList() = default;

        void Reset() { head = nullptr; }

        void Push(T* n)
        {
            T* old = head.load(std::memory_order_relaxed);
            do {
                n->next = old;
            } while (!head.compare_exchange_weak(old, n, std::memory_order_release, std::memory_order_relaxed));
        }

        T* Pop()
        {
            T* old = head.load(std::memory_order_relaxed);
            do {
                if (old == nullptr) {
                    return nullptr;
                }
            } while (!head.compare_exchange_weak(old, old->next, std::memory_order_release, std::memory_order_relaxed));
            old->next = nullptr;
            return old;
        }

        T* PopAll()
        {
            T* old = head.load(std::memory_order_relaxed);
            while (!head.compare_exchange_weak(old, nullptr, std::memory_order_release, std::memory_order_relaxed)) {
            };
            return old;
        }

    private:
        std::atomic<T*> head;
    };

    template<typename T>
    class LockedList {
        friend class SatbBuffer;

    public:
        LockedList() : head(nullptr) {}
        ~LockedList() = default;

        void Reset()
        {
            std::lock_guard<std::mutex> lg(safeLock);
            head = nullptr;
        }

        void Push(T* n)
        {
            std::lock_guard<std::mutex> lg(safeLock);
            n->next = head;
            head = n;
        }

        T* Pop()
        {
            std::lock_guard<std::mutex> lg(safeLock);
            if (head == nullptr) {
                return nullptr;
            }
            T* old = head;
            T* next = head->next;
            head = next;
            return old;
        }

        T* PopAll()
        {
            std::lock_guard<std::mutex> lg(safeLock);
            T* old = head;
            head = nullptr;
            return old;
        }

    private:
        std::mutex safeLock;
        T* head;
    };

    void EnsureGoodNode(Node*& node)
    {
        if (node == nullptr) {
            node = freeNodes.Pop();
        } else if (node->IsFull()) {
            // means current node is full
            retiredNodes.Push(node);
            node = freeNodes.Pop();
        } else {
            // not null & have slots
            return;
        }
        if (node == nullptr) {
            // there is no free nodes in the freeNodes list
            Page* page = GetPages(MapleRuntime::MRT_PAGE_SIZE);
            Node* list = ConstructFreeNodeList(page, MapleRuntime::MRT_PAGE_SIZE);
            if (list == nullptr) {
                return;
            }
            node = list;
            Node* cur = list->next;
            node->next = nullptr;
            CHECK_DETAIL(node->IsEmpty(), "Get an unempty node from new page");
            while (cur != nullptr) {
                Node* next = cur->next;
                freeNodes.Push(cur);
                cur = next;
            }
        } else {
            CHECK_DETAIL(node->IsEmpty(), "get an unempty node from free nodes");
        }
    }
    bool ShouldEnqueue(const BaseObject* obj);

    // must not have thread racing
    void Init()
    {
        Node* head = retiredNodes.PopAll();
        while (head != nullptr) {
            Node* oldHead = head;
            head = head->next;
            oldHead->Clear();
            freeNodes.Push(oldHead);
        }

        if (freeNodes.head == nullptr) {
            size_t initalBytes = INITIAL_PAGES * MapleRuntime::MRT_PAGE_SIZE;
            Page* page = GetPages(initalBytes);
            Node* list = ConstructFreeNodeList(page, initalBytes);
            freeNodes.head = list;
        }
    }

    void RetireNode(Node* node) noexcept { retiredNodes.Push(node); }

    void Fini() { ReclaimALLPages(); }

    template<typename T>
    void GetRetiredObjects(T& stack)
    {
        Node* head = retiredNodes.PopAll();
        while (head != nullptr) {
            head->GetObjects(stack);
            Node* oldHead = head;
            head = head->next;
            oldHead->Clear();
            freeNodes.Push(oldHead);
        }
    }

    void ClearBuffer()
    {
        Node* head = retiredNodes.PopAll();
        while (head != nullptr) {
            Node* oldHead = head;
            head = head->next;
            oldHead->Clear();
            freeNodes.Push(oldHead);
        }
    }

    // it can be invoked only if no mutator points to any node.
    void ReclaimALLPages()
    {
        freeNodes.Reset();
        retiredNodes.Reset();
        Page* list = arena.PopAll();
        if (list == nullptr) {
            return;
        }
        while (list != nullptr) {
            Page* next = list->next;
            PagePool::Instance().ReturnPage(reinterpret_cast<uint8_t*>(list), list->length);
            list = next;
        }
    }

private:
    Page* GetPages(size_t bytes)
    {
        Page* page = new (PagePool::Instance().GetPage(bytes)) Page(nullptr, bytes);
        page->next = nullptr;
        arena.Push(page);
        return page;
    }

    Node* ConstructFreeNodeList(const Page* page, size_t bytes) const
    {
        MAddress start = reinterpret_cast<MAddress>(page) + RoundUp(sizeof(Page), CACHE_LINE_ALIGN);
        MAddress end = reinterpret_cast<MAddress>(page) + bytes;
        Node* cur = nullptr;
        Node* head = nullptr;
        while (start <= (end - NODE_SIZE)) {
            Node* node = new (reinterpret_cast<void*>(start)) Node();
            if (cur == nullptr) {
                cur = node;
                head = node;
            } else {
                cur->next = node;
                cur = node;
            }
            start += NODE_SIZE;
        }
        return head;
    }

    LockedList<Page> arena;        // arena of allocatable area, first area is 64 * 4k = 256k, the rest is 4k
    LockedList<Node> freeNodes;    // free nodes, mutator will acquire nodes from this list to record old value writes
    LockedList<Node> retiredNodes; // has been filled by mutator, ready for scan
};

class WeakRefBuffer {
public:
    static WeakRefBuffer& Instance() noexcept;
    void ClearWeakRefBuffer()
    {
        for (BaseObject* obj : refObjBuffer) {
            RefField<>* referentField = reinterpret_cast<RefField<>*>((uintptr_t)obj + TYPEINFO_PTR_SIZE);
            Heap::GetBarrier().ReadWeakRef(obj, *referentField);
        }
        refObjBuffer.clear();
    }
    // insert weakref obj into buffer
    void Insert(BaseObject* obj)
    {
        std::lock_guard<std::mutex> lock(mtx); // For potential concurrency problems
        refObjBuffer.insert(obj);
    }
private:
    std::unordered_set<BaseObject*> refObjBuffer;
    std::mutex mtx;
};
} // namespace MapleRuntime

#endif // MRT_SATB_BUFFER_H
