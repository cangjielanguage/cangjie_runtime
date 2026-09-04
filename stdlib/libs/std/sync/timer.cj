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
 * This file defines the Timer class.
 */
package std.sync

import std.time.MonoTime

const TIMER_BLOCK_BUFFER_SIZE = 1 << 7 // the initial size of the buffer in the TimerBlock.
const TIMER_LIST_DEFAULT_CAPACITY = 16 // the initial capacity of TimerList

/**
 * Timer is used to execute a specified task one or more times at a specified time point or after a specified interval.
 * 1. Each Timer creates a new thread to execute the task associated with the Timer.
 * 2. A Timer can be bound to only one task during initialization and cannot be reset after initialization.
 * 3. A Timer ends its lifetime when the task associated with the Timer finish or are cancelled.
 *    The Timer can then be reclaimed by the GC.
 *    On the other hand, a Timer will not be reclaimed by GC in any case until the associated task have finished
 *    or are actively cancelled, ensuring that the associated task will be executed.
 * 4. If the system is busy, the task triggering time may be affected.
 *    The Timer does not ensure that the task triggering time is punctual.
 *    Timer ensures that tasks are executed if the trigger time of the task is less than or equal tothe current time.
 *    Subsequent tasks will be postponed.
 * 5. Timer does not actively catch the exception thrown by the associated task.
 *    As long as the task has exceptions that are not caught, the Timer will be invalid.
 */
public class Timer <: Equatable<Timer> & Hashable {
    private static let INSTANCE_ID = AtomicInt64(1)
    private let id = INSTANCE_ID.fetchAdd(1)

    private let scheduler: TimerScheduler
    let task: () -> ?Duration
    var endTime: MonoTime
    var isEnabled = true

    init(delay: Duration, task: () -> ?Duration) {
        let realDelay = if (delay > Duration.Zero) {
            delay
        } else {
            Duration.Zero
        }

        this.scheduler = TimerScheduler.getScheduler(id)
        this.task = task
        try {
            this.endTime = MonoTime.now() + realDelay
        } catch (e: ArithmeticException) {
            this.endTime = MonoTime.now() + realDelay / 2
        }

        this.scheduler.add(this)
    }

    /**
     * Create a timer, the number of times the associated task is scheduled to run depends on its return value.
     * If @p delay duration is less than `Duration.Zero`, the associated task will be scheduled to run immediately.
     * If @p task return `Option.None`, the timer will stop to schedule the task to run,
     * if `Option.Some(v)` and `v > Duration.Zero`, the minimum interval before the next run will be set to v,
     * otherwise, the associated task will be scheduled to run immediately.
     *
     * @param delay The time from now until the associated task is scheduled to run for the first time.
     * @param task Associated task that are scheduled to run by the timer.
     *
     * @return A Timer instance.
     */
    public static func after(delay: Duration, task: () -> Option<Duration>): Timer {
        Timer(delay, task)
    }

    /**
     * Create a disposable timer, the associated task will be scheduled to run only once.
     * If @p delay duration is less than `Duration.Zero`, the associated task will be scheduled to run immediately.
     *
     * @param delay The time from now until the associated task is scheduled to run for the first time.
     * @param task Associated task that are scheduled to run by the timer.
     */
    public static func once(delay: Duration, task: () -> Unit): Timer {
        Timer(delay) {
            task()
            None
        }
    }

    /**
     * Create a periodic timer, the associated task will be scheduled to run repeatedly.
     * If @p delay duration is less than `Duration.Zero`, the associated task will be scheduled to run immediately.
     *
     * @param delay The time from now until the associated task is scheduled to run for the first time.
     * @param interval The minimum interval between two execution times of the associated task.
     * @param task Associated task that are scheduled to run by the timer.
     * @param style The catchup style, default is Burst.
     *
     * @throw IllegalArgumentException if @p interval is less than or equal to `Duration.Zero`.
     */
    public static func repeat(delay: Duration, interval: Duration, task: () -> Unit, style!: CatchupStyle = Burst): Timer {
        if (interval <= Duration.Zero) {
            throw IllegalArgumentException("Interval cannot be less than or equal to Duration.Zero.")
        }

        let nextTick = match (style) {
            case Delay => delayStyleTick(interval)
            case Burst => burstStyleTick(delay, interval)
            case Skip => skipStyleTick(delay, interval)
        }

        Timer(delay) {
            task()
            nextTick()
        }
    }

    /**
     * Create a periodic timer, the associated task will be scheduled to run repeatedly.
     * If @p delay time point is less than now, the associated task will be scheduled to run immediately.
     *
     * @param period Maximum duration for which the associated task can be scheduled since @p delay.
     * @param delay The time from now until the associated task is scheduled to run for the first time.
     * @param interval The minimum interval between two execution times of the associated task.
     * @param task Associated task that are scheduled to run by the timer.
     * @param style The catchup style, default is Burst.
     *
     * @throw IllegalArgumentException when the @p period is less than or equal to `Duration.Zero`,
     *                                 or @p interval is less than or equal to `Duration.Zero`.
     */
    public static func repeatDuring(period: Duration, delay: Duration, interval: Duration, task: () -> Unit,
        style!: CatchupStyle = Burst): Timer {
        if (period <= Duration.Zero) {
            throw IllegalArgumentException("Period cannot be less than or equal to Duration.Zero.")
        }
        if (interval <= Duration.Zero) {
            throw IllegalArgumentException("Interval cannot be less than or equal to Duration.Zero.")
        }

        let innerTick = match (style) {
            case Delay => delayStyleTick(interval)
            case Burst => burstStyleTick(delay, interval)
            case Skip => skipStyleTick(delay, interval)
        }
        let nextTick = tickDuring(delay, period, innerTick)

        Timer(delay) {
            task()
            nextTick()
        }
    }

    /**
     * Create a periodic timer, the associated task will be scheduled to run repeatedly.
     * If @p delay duration is less than `Duration.Zero`, the associated task will be scheduled to run immediately.
     *
     * @param count Number of times the associated task is scheduled to run.
     * @param delay The time from now until the associated task is scheduled to run for the first time.
     * @param interval The minimum interval between two execution times of the associated task.
     * @param task Associated task that are scheduled to run by the timer.
     * @param style The catchup style, default is Burst.
     *
     * @throw IllegalArgumentException when @p count is less than or equal to 0,
     *                                 or @p interval is less than or equal to `Duration.Zero`.
     */
    public static func repeatTimes(count: Int64, delay: Duration, interval: Duration, task: () -> Unit,
        style!: CatchupStyle = Burst): Timer {
        if (count <= 0) {
            throw IllegalArgumentException("Count cannot be less than or equal to 0.")
        }
        if (interval <= Duration.Zero) {
            throw IllegalArgumentException("Interval cannot be less than or equal to Duration.Zero.")
        }

        let innerTick = match (style) {
            case Delay => delayStyleTick(interval)
            case Burst => burstStyleTick(delay, interval)
            case Skip => skipStyleTick(delay, interval)
        }
        let nextTick = tickTimes(count, innerTick)

        Timer(delay) {
            task()
            nextTick()
        }
    }

    /**
     * Cancel the timer, the associated task will no longer be scheduled to run.
     * If the associated task is running when calling `cancel`, cancel will not interrupt the current run.
     * The method does not block the current thread.
     * Calling `cancel` more than once is equal to calling only once.
     */
    public func cancel(): Unit {
        // Thread security does not need to be considered.
        // Because the impact of repeatedly setting disable and increasing the number of cancels by 1 is controllable.
        if (isEnabled) {
            isEnabled = false
            scheduler.addCancelCount()
        }
    }

    /**
     * Check if the two Timer instances are the same one actually.
     */
    public operator func ==(other: Timer): Bool {
        refEq(this, other)
    }

    /**
     * Check if the two Timer instances are different actually.
     */
    public operator func !=(other: Timer): Bool {
        !refEq(this, other)
    }

    /**
     * Return the instance id as the hash code of the timer.
     */
    public func hashCode(): Int64 {
        return id
    }

    func reload(duration: Duration): Unit {
        endTime = MonoTime.now() + duration
        scheduler.add(this)
    }
}

/**
 * The catchup style of the periodic timer.
 */
public enum CatchupStyle {
    | Delay
    | Burst
    | Skip
}

/**
 * CatchupStyle Delay, ticks at fix interval after previous task completed.
 *
 * Looks like:
 *      Time: |    1    |    2    |    3    |    4    |    5    |    6    |    7    |    8    |
 * Tick Time: |  delay  | task ---| very very long task ---| task ---| task ---| task ---| task ---|
 */
func delayStyleTick(interval: Duration): () -> ?Duration {
    return {=> interval}
}

/**
 * CatchupStyle Burst, ticks at fix interval, will tick as fast as possible until caught up.
 *
 * Looks like:
 *      Time: |    1    |    2    |    3    |    4    |    5    |    6    |    7    |    8    |
 * Tick Time: |  delay  | task ---| very very long task | task | task | task | task | task ---|
 */
func burstStyleTick(delay: Duration, interval: Duration): () -> ?Duration {
    // the `lastTime' should be at `delay`
    let lastTime: Box<MonoTime>
    try {
        lastTime = Box<MonoTime>(MonoTime.now() + delay)
    } catch (e: ArithmeticException) {
        // delay is too large, timer will never tick
        return {=> None}
    }

    return {
        =>
            let now = MonoTime.now()

        // calculate the next tick time
            let nextTime = lastTime.value + interval

        // `nextTime - now` is the next interval
            if (nextTime >= now) {
                lastTime.value = nextTime
                return nextTime - now
            }

        // catchup step by step
            lastTime.value = nextTime
        // tick immediately
            return Duration.Zero
    }
}

/**
 * CatchupStyle Skip, ticks at fix interval, will skip the ticks until caught up.
 *
 * Looks like:
 *      Time: |    1    |    2    |    3    |    4    |    5    |    6    |    7    |    8    |
 * Tick Time: |  delay  | task ---| very very long task | task -| task ---| task ---| task ---|
 */
func skipStyleTick(delay: Duration, interval: Duration): () -> ?Duration {
    // `previousTick` starts at the first delayed tick.
    let previousTick: Box<MonoTime>
    try {
        previousTick = Box<MonoTime>(MonoTime.now() + delay)
    } catch (e: ArithmeticException) {
        // delay is too large, timer will never tick
        return {=> None}
    }

    return {
        =>
            let currentTime = MonoTime.now()

            var scheduledTick = previousTick.value + interval

            if (scheduledTick >= currentTime) {
                previousTick.value = scheduledTick
                return scheduledTick - currentTime
            }

            while (scheduledTick < currentTime) {
                scheduledTick += interval
            }
            previousTick.value = scheduledTick - interval

        // tick immediately
            return Duration.Zero
    }
}

func tickDuring(delay: Duration, period: Duration, nextTick: () -> ?Duration): () -> ?Duration {
    let firstTickTime: MonoTime
    try {
        firstTickTime = MonoTime.now() + delay
    } catch (e: ArithmeticException) {
        // delay is too large, timer will never tick
        return {=> None}
    }
    let finalTime: MonoTime
    try {
        finalTime = firstTickTime + period
    } catch (e: ArithmeticException) {
        // tick until cancel
        return {=> nextTick()}
    }

    return {
        =>
            let now = MonoTime.now()
        // last tick time <= finalTime
            if (now > finalTime) {
                return None
            }

            if (let Some(interval) <- nextTick()) {
                if (now + interval > finalTime) {
                    return None
                }
                return interval
            }
            return None
    }
}

func tickTimes(count: Int64, nextTick: () -> ?Duration): () -> ?Duration {
    let cnt = Box<Int64>(1)
    return {
        =>
            if (cnt.value >= count) {
                return None
            }
            cnt.value++
            nextTick()
    }
}

class TimerScheduler {
    private static const SCHEDULER_COUNT = 64
    private static let schedulers: Array<TimerScheduler>
    static init() {
        schedulers = Array<TimerScheduler>(SCHEDULER_COUNT) {_ => TimerScheduler()}
    }
    static func getScheduler(id: Int64) {
        if (id < 0) {
            schedulers[(0 - id) % SCHEDULER_COUNT]
        } else {
            schedulers[id % SCHEDULER_COUNT]
        }
    }

    private let queue = TimerQueue()
    private var heap = TimerHeap()
    private let monitor = Monitor()
    private let isRunning = AtomicBool(false)
    private let cancelCount = AtomicInt64(0)

    func add(timer: Timer) {
        if (MonoTime.now() >= timer.endTime) {
            execute(timer)
            return
        }
        synchronized(monitor) {
            queue.add(timer)
            monitor.notify()
        }
        start()
    }

    private func start() {
        if (!isRunning.compareAndSwap(false, true)) {
            return
        }
        spawn {
            while (true) {
                consume()
                schedule()
                let count = cancelCount.load()
                // Refer to the general implementation in the industry for determining whether to clear the cancelled Timers.
                if (count > heap.size / 4 && count > 10) {
                    clearCancelledTimers()
                }
            }
        }
    }

    private func consume() {
        while (let Some(t) <- queue.remove()) {
            heap.add(t)
        }
    }

    private func schedule(): Unit {
        if (heap.isEmpty) {
            synchronized(monitor) {
                if (queue.isEmpty()) {
                    monitor.wait()
                }
            }
            return
        }
        let timer = heap.top()
        if (!timer.isEnabled) {
            heap.poll()
            cancelCount.fetchSub(1)
            return
        }

        let time = MonoTime.now()
        if (time >= timer.endTime) {
            execute(timer)
            heap.poll()
            return
        }
        synchronized(monitor) {
            monitor.wait(timeout: timer.endTime - time)
        }
    }

    private func execute(timer: Timer) {
        spawn {
            let duration = timer.task()
            if (let Some(d) <- duration) {
                timer.reload(d)
            }
        }
    }

    func addCancelCount() {
        cancelCount.fetchAdd(1)
    }

    private func clearCancelledTimers() {
        cancelCount.store(0)
        let source = heap
        heap = TimerHeap()
        while (!source.isEmpty) {
            let timer = source.poll()
            if (timer.isEnabled) {
                heap.add(timer)
            }
        }
    }
}

class TimerHeap {
    private static const NODE_SIZE = 4

    private let data = TimerList()
    prop size: Int64 {
        get() {
            return data.size
        }
    }
    prop isEmpty: Bool {
        get() {
            return data.isEmpty()
        }
    }

    func add(e: Timer) {
        data.add(e)
        siftUp()
    }

    // This func do not have empty check, do not call this func when heap is empty
    func top(): Timer {
        data[0]
    }

    // This func do not have empty check, do not call this func when heap is empty
    func poll(): Timer {
        let top = data[0]
        data[0] = data[data.size - 1]
        data.remove(at: data.size - 1)
        siftDown()
        return top
    }

    private func siftUp() {
        var i = size - 1
        while (i > 0) {
            var parent = (i - 1) / NODE_SIZE
            if (!(data[i].endTime < data[parent].endTime)) {
                break
            }
            (data[parent], data[i]) = (data[i], data[parent])
            i = parent
        }
    }

    private func siftDown() {
        var i = 0
        while (true) {
            let childIndex = NODE_SIZE * i + 1
            if (childIndex > size - 1) {
                break
            }

            let min = getMinIndex(childIndex)
            if (!(data[min].endTime < data[i].endTime)) {
                break
            }
            (data[min], data[i]) = (data[i], data[min])
            i = min
        }
    }

    private func getMinIndex(index: Int64) {
        var min = index
        for (i in (index + 1)..(index + NODE_SIZE)) {
            if (i < size && data[i].endTime < data[min].endTime) {
                min = i
            }
        }
        return min
    }
}

/**
 * PushResult Type defines the result of pushing an element into buffer[index]:
 * - BlockDone: buffer is full
 * - Conflict: another thread sends the element into buffer[index]
 * - Succeed: sends element at the buffer[index] successfully
 */
enum PushResult {
    | BlockDone
    | Conflict
    | Succeed
}

/**
 * PopResult Type defines the result of getting an element at the head of the block:
 * - BlockDone: all of the element in the block have been consumed
 * - NoEntry: there is no element in the block
 * - Element(E): gets the element at the head of the block successfully
 */
enum PopResult {
    | BlockDone
    | NoEntry
    | Element(Timer)
}

/**
 * TimerBlock is responsible for storing elements and contains operations such as access to elements.
 */
class TimerBlock {
    let isExtended = AtomicBool(false) // mark whether the Block should be extended
    let next = AtomicOptionReference<TimerBlock>(None)
    private let allocated = AtomicInt64(0) // index of the entry for sending next element.
    let committed = AtomicInt64(0) // justifies whether there is unfinished senders.
    let reserved = AtomicInt64(0) // index of the entry for getting next element.
    let buffer = unsafe { Array<Timer>(TIMER_BLOCK_BUFFER_SIZE, repeat: zeroValue<Timer>()) } // buffer for saving the elements

    TimerBlock(let version: UInt64) {}

    func push(element: Timer): Bool {
        if (allocated.load() >= TIMER_BLOCK_BUFFER_SIZE) {
            return false
        }

        let index = allocated.fetchAdd(1)

        if (index >= TIMER_BLOCK_BUFFER_SIZE) {
            return false
        }

        buffer[index] = element
        committed.fetchAdd(1)

        return true
    }

    func pop(): PopResult {
        while (true) {
            let index = reserved.load()

            if (index >= TIMER_BLOCK_BUFFER_SIZE) {
                return BlockDone
            }

            let currentCommitted = committed.load()
            if (currentCommitted != TIMER_BLOCK_BUFFER_SIZE) {
                if (currentCommitted != allocated.load()) {
                    continue
                }
            }

            if (index == currentCommitted) {
                return NoEntry
            }

            if (reserved.compareAndSwap(index, index + 1)) {
                let elem = Element(buffer[index])
                buffer[index] = unsafe { zeroValue<Timer>() }
                return elem
            }
        }

        return BlockDone
    }

    func front(): PopResult {
        while (true) {
            let peekIndex = reserved.load()

            if (peekIndex >= TIMER_BLOCK_BUFFER_SIZE) {
                return BlockDone
            }

            let visibleCommitted = committed.load()
            if (visibleCommitted != TIMER_BLOCK_BUFFER_SIZE) {
                if (visibleCommitted != allocated.load()) {
                    continue
                }
            }

            if (peekIndex == visibleCommitted) {
                return NoEntry
            }

            return Element(buffer[peekIndex])
        }

        return BlockDone
    }
}

class TimerQueue {
    private let front: AtomicReference<TimerBlock>
    private let rear: AtomicReference<TimerBlock>

    init() {
        let block = TimerBlock(0)
        front = AtomicReference<TimerBlock>(block)
        rear = AtomicReference<TimerBlock>(block)
    }

    func add(element: Timer) {
        while (true) {
            let tailBlock = rear.load()
            if (tailBlock.push(element)) {
                return
            }
            newBlock(tailBlock, rear)
        }
    }

    func remove(): Option<Timer> {
        while (true) {
            let headBlock = front.load()
            match (headBlock.pop()) {
                case BlockDone =>
                    if (!nextBlock(headBlock, front, rear)) {
                        return None
                    }
                case NoEntry => break
                case Element(e) => return Some(e)
            }
        }
        return None
    }

    func peek(): Option<Timer> {
        while (true) {
            let headBlock = front.load()
            match (headBlock.front()) {
                case Element(e) => return Some(e)
                case NoEntry => break
                case BlockDone =>
                    if (!nextBlock(headBlock, front, rear)) {
                        break
                    }
            }
        }
        return None
    }

    func isEmpty(): Bool {
        peek().isNone()
    }
}

func newBlock(tailBlock: TimerBlock, tail: AtomicReference<TimerBlock>): Unit {
    if (!tailBlock.isExtended.compareAndSwap(false, true)) {
        while (tailBlock.next.load().isNone()) {}
        return
    }

    let newBlock = TimerBlock(tailBlock.version + 1)
    tailBlock.next.store(newBlock)
    tail.store(newBlock)
}

func nextBlock(headBlock: TimerBlock, head: AtomicReference<TimerBlock>, tail: AtomicReference<TimerBlock>): Bool {
    if (!refEq(head.load(), headBlock)) {
        return true
    }
    if (let Some(next) <- headBlock.next.load()) {
        while (refEq(headBlock, tail.load())) {}
        head.compareAndSwap(headBlock, next)
        return true
    }
    return false
}

class TimerList {
    private var _data: Array<Timer>
    private var _size: Int64

    init() {
        _data = Array<Timer>(TIMER_LIST_DEFAULT_CAPACITY, repeat: unsafe { zeroValue<Timer>() })
        _size = 0
    }

    func add(element: Timer): Unit {
        if (_size == _data.size) {
            grow(_size + 1)
        }
        _data[_size] = element
        _size++
    }

    // This func do not have range check, do not call this func out of range
    func remove(at!: Int64): Timer {
        let len: Int64 = _size - at - 1
        let removed = _data[at]
        _data.copyTo(_data, at + 1, at, len)
        _data[_size - 1] = unsafe { zeroValue<Timer>() }
        _size--
        return removed
    }

    // This func do not have range check, do not call this func out of range
    operator func [](index: Int64): Timer {
        return this._data[index]
    }

    // This func do not have range check, do not call this func out of range
    operator func [](index: Int64, value!: Timer): Unit {
        _data[index] = value
    }

    func isEmpty(): Bool {
        return _size == 0
    }

    prop size: Int64 {
        get() {
            return _size
        }
    }

    private func grow(minCapacity: Int64, startIndex!: Int64 = 0): Unit {
        let oldCapacity: Int64 = _data.size
        var newCapacity: Int64 = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity
        }
        let newArr: Array<Timer> = Array<Timer>(newCapacity, repeat: unsafe { zeroValue<Timer>() })
        _data.copyTo(newArr, 0, startIndex, _size)
        _data = newArr
    }
}
