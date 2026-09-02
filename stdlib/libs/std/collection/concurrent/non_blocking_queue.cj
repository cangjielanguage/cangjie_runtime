/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.collection.concurrent

import std.sync.*
import std.collection.ArrayList

/**
 * ENTRY<E> Type defines the result of getting an element at the head of the block:
 * - BlockDone: all of the element in the block have been consumed
 * - NoEntry: there is no element in the block
 * - ELEM(E): gets the element at the head of the block successfully
 */
enum ENTRY<E> {
    | BlockDone
    | NoEntry
    | ELEM(E)
}

/**
 * PushRes Type defines the result of pushing an element into buffer[index]:
 * - BlockDone: buffer is full
 * - CONFLICT: another thread sends the element into buffer[index]
 * - SUCCEED: sends element at the buffer[index] successfully
 */
enum PushRes {
    | BlockDone
    | CONFLICT
    | SUCCEED
}

const BUF_SIZE_BITS = 7 // shift for the size of Block.
const BUF_SIZE: Int64 = 1 << BUF_SIZE_BITS // the initial size of the buffer in the block.

/**
 * Block is responsible for storing elements and contains operations such as access to elements.
 */
class Block<E> {
    let version: UInt64 // identifier of the Block

    let isExtended = AtomicBool(false) // mark whether the Block should be extended
    let next = AtomicOptionReference<Block<E>>(None)
    private let allocated = AtomicInt64(0) // index of the entry for sending next element.
    let committed = AtomicInt64(0) // justifies whether there is unfinished senders.
    let reserved = AtomicInt64(0) // index of the entry for getting next element.
    let buffer = unsafe { Array<E>(BUF_SIZE, repeat: zeroValue<E>()) } // buffer for saving the elements

    init(version: UInt64) {
        this.version = version
    }

    /**
     * Sends the @p element into the buffer.
     *
     * @param element: the element to put into the buffer
     *
     * @return:
     * - true: sends @p element into the buffer successfully
     * - false: fails to send into the buffer
     */
    func push(element: E): Bool {
        // buffer full
        if (allocated.load() >= BUF_SIZE) {
            return false
        }

        let index = allocated.fetchAdd(1)

        // buffer full
        if (index >= BUF_SIZE) {
            return false
        }

        buffer[index] = element
        committed.fetchAdd(1)

        return true
    }

    /**
     * Sends the @p element at the buffer[@p index].
     *
     * @param element: the element to put into the buffer
     * @param index: the index of the buffer to store @p element
     *
     * @return:
     * - SUCCEED: sends @p element at the buffer[@p index] successfully
     * - BlockDone: buffer full
     * - CONFLICT: another thread sends the element into buffer[@p index]
     */
    func pushAt(element: E, index: Int64): PushRes {
        // buffer full
        if (index >= BUF_SIZE) {
            return BlockDone
        }

        // Exists another thread sends the element at buffer[@p index]
        if (!allocated.compareAndSwap(index, index + 1)) {
            return CONFLICT
        }

        buffer[index] = element
        committed.fetchAdd(1)

        return SUCCEED
    }

    /**
     * Gets and removes the element at the head of the buffer.
     *
     * @return:
     * - NoEntry: if there is no element in the buffer
     * - BlockDone: if all of the entries in the buffer have been consumed
     * - ELEM(e): if gets the element e at the head of the buffer successfully
     */
    func pop(): ENTRY<E> {
        while (true) {
            let index = reserved.load()

            // all of the entries in the buffer have been consumed.
            if (index >= BUF_SIZE) {
                return BlockDone
            }

            let currentCommitted = committed.load()
            if (currentCommitted != BUF_SIZE) {
                // Retry: existing unfinished senders in this block.
                if (currentCommitted != allocated.load()) {
                    continue
                }
            }

            // there is no element in the buffer
            if (index == currentCommitted) {
                return NoEntry
            }

            // get and remove the element of buffer[index]
            if (reserved.compareAndSwap(index, index + 1)) {
                let elem = ELEM(buffer[index])
                buffer[index] = unsafe { zeroValue<E>() }
                return elem
            }
        }

        return BlockDone
    }

    /**
     * Gets the element at the head of the buffer.
     *
     * @return
     * - NoEntry: if there is no element in the buffer
     * - BlockDone: if all of the entries in the buffer have been consumed
     * - ELEM(e): if gets the element e at the head of the buffer successfully
     */
    func front(): ENTRY<E> {
        while (true) {
            let index = reserved.load()

            // all of the entries in the buffer have been consumed.
            if (index >= BUF_SIZE) {
                return BlockDone
            }

            let currentCommitted = committed.load()
            if (currentCommitted != BUF_SIZE) {
                // Retry: existing unfinished senders in this block.
                if (currentCommitted != allocated.load()) {
                    continue
                }
            }

            // there is no element in the buffer.
            if (index == currentCommitted) {
                return NoEntry
            }

            // get the element of buffer[index].
            return ELEM(buffer[index])
        }

        return BlockDone
    }

    func getAllocated(): (UInt64, Int64) {
        return (version, allocated.load())
    }

    func getReserved(): (UInt64, Int64) {
        return (version, reserved.load())
    }
}

@Deprecated[message: "Use ConcurrentLinkedQueue instead."]
public type NonBlockingQueue<E> = ConcurrentLinkedQueue<E>

/**
 * NonBlockingQueue is an unbounded nonblocking concurrent queue.
 */
public class ConcurrentLinkedQueue<E> <: Collection<E> {
    private let front: AtomicReference<Block<E>>
    private let rear: AtomicReference<Block<E>>

    /**
     * The default method to initialize the concurrent queue.
     */
    public init() {
        let block = Block<E>(0)
        front = AtomicReference<Block<E>>(block)
        rear = AtomicReference<Block<E>>(block)
    }

    /**
     * Initialize the queue by putting all the element in @p elements into the queue.
     */
    @Deprecated[message: "Use the other version of `init` instead."]
    public init(elements: Collection<E>) {
        this()
        for (element in elements) {
            enqueue(element)
        }
    }

    /**
     * Returns the number of elements in the NonBlockingQueue.
     *
     * It ensures to return the accurate number of elements in the NonBlockingQueue in sequential.
     * Note that getting 'size' prop is not atomic!
     * So, if elements are added or removed during execution of getting 'size',
     * the 'size' may be inaccurate.
     */
    public prop size: Int64 {
        get() {
            let headBlock = front.load()
            let tailBlock = rear.load()
            let (headBlockVersion, headBlockReserved) = headBlock.getReserved()
            let (tailBlockVersion, tailBlockAllocated) = tailBlock.getAllocated()
            let currentBlockSize = tailBlockAllocated - headBlockReserved
            let completedBlockSize = Int64(tailBlockVersion - headBlockVersion) << BUF_SIZE_BITS
            return currentBlockSize + completedBlockSize
        }
    }

    /**
     * Sends the element @p element to the tail of the queue.
     *
     * @param element: the element to send into the queue.
     *
     * @return:
     * - true: if @p element is successfully pushed at the tail of the queue.
     *
     * Note that the NonBlockingQueue 'enqueue' will never return 'false'.
     */
    @Deprecated[message: "Use member function `func addIfAbsent(key: K, value: V): ?V` instead."]
    public func enqueue(element: E): Bool {
        add(element)
    }

    public func add(element: E): Bool {
        while (true) {
            let tailBlock = rear.load()
            if (tailBlock.push(element)) {
                return true
            }
            newBlock(tailBlock, rear)
        }
        return false
    }

    /**
     * Gets and removes the head of the queue.
     *
     * @return:
     * - Some(v): if gets and removes the element at the head of the queue successfully.
     * - None: if the queue is empty.
     */
    @Deprecated[message: "Use member function `public func remove(): Option<E>` instead."]
    public func dequeue(): Option<E> {
        remove()
    }

    public func remove(): Option<E> {
        while (true) {
            let headBlock = front.load()
            match (headBlock.pop()) {
                case BlockDone =>
                    if (!nextBlock(headBlock, front, rear)) {
                        return None
                    }
                case NoEntry => break
                case ELEM(e) => return Some(e)
            }
        }
        return None
    }

    /**
     * Gets the head of the queue, but does not remove it.
     *
     * @return:
     * - Some(v): if gets the element at the head of the queue successfully.
     * - None: the queue is empty, and fails to get the head of the queue.
     *
     * Note: calling 'head()' can still get the head of the queue.
     */
    @Deprecated[message: "Use member function `public func peek(): Option<E>` instead."]
    public func head(): Option<E> {
        peek()
    }

    public func peek(): Option<E> {
        while (true) {
            let headBlock = front.load()
            let entry = headBlock.front()
            match (entry) {
                case ELEM(e) => return Some(e)
                case NoEntry => break
                case BlockDone =>
                    if (!nextBlock(headBlock, front, rear)) {
                        break
                    }
            }
        }
        return None<E>
    }

    public func isEmpty(): Bool {
        peek().isNone()
    }

    public func toArray(): Array<E> {
        let estimatedSize = size
        let arr = if (estimatedSize > 0) {
            ArrayList<E>(estimatedSize)
        } else {
            ArrayList<E>()
        }
        for (e in this) {
            arr.add(e)
        }
        return arr.toArray()
    }

    @Frozen
    public func iterator(): Iterator<E> {
        ConcurrentLinkedQueueIterator<E>(this, front.load())
    }
}

/**
 * Allocates a new block and sets 'tail' pointing to the new one.
 */
func newBlock<E>(tailBlock: Block<E>, tail: AtomicReference<Block<E>>): Unit {
    if (!tailBlock.isExtended.compareAndSwap(false, true)) {
        while (true) {
            if (let Some(_) <- tailBlock.next.load()) {
                return
            }
        }
    }

    let newBlock = Block<E>(tailBlock.version + 1)
    tailBlock.next.store(newBlock)
    tail.store(newBlock)
}

/**
 * Sets 'head' to point to the next block.
 */
func nextBlock<E>(headBlock: Block<E>, head: AtomicReference<Block<E>>, tail: AtomicReference<Block<E>>): Bool {
    if (!refEq(head.load(), headBlock)) {
        return true
    }

    if (let Some(next) <- headBlock.next.load()) {
        // Waits for ongoing allocation.
        while (refEq(headBlock, tail.load())) {}
        head.compareAndSwap(headBlock, next)
        return true
    }

    return false
}

class ConcurrentLinkedQueueIterator<E> <: Iterator<E> {
    let queue: ConcurrentLinkedQueue<E>
    var curBlock: Block<E>
    var curIndex: Int64
    var hasNext: Bool = true

    init(queue: ConcurrentLinkedQueue<E>, front: Block<E>) {
        this.queue = queue
        this.curBlock = front
        this.curIndex = curBlock.reserved.load()
    }

    @Frozen
    public func next(): ?E {
        while (hasNext) {
            if (curIndex >= BUF_SIZE && !getNextBlock() || curIndex >= curBlock.committed.load()) {
                hasNext = false
                break
            }
            let curElement = curBlock.buffer[curIndex]
            let reserved = curBlock.reserved.load()
            if (curIndex >= reserved) {
                curIndex++
                return curElement
            }
            curIndex = reserved
        }
        return None
    }

    func getNextBlock(): Bool {
        match (curBlock.next.load()) {
            case None => false
            case Some(block) =>
                curBlock = block
                curIndex = 0
                true
        }
    }
}
