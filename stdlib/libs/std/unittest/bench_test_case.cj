/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.collection.*
import std.time.DateTime
import std.random.Random
import std.math.*
import std.core
import std.runtime.*
import std.runtime
import std.convert.Formattable
import std.sort.*
import std.sync.*

// upper limit on number of saved measurements to keep reasonable statistics calculation time and memory cost
const MEASUREMENTS_LIMIT = 500
const DEFAULT_BATCHES_AMOUNT = 200.0
const MAX_BATCH_SIZE = 2 ** 60
// Currently in Cangjie minimal possible size of object is 8 because every object on heap has to store pointer to metadata
const MIN_OBJECT_SIZE = 8.0

// Threshold to detect that GC taking a lot of time so that it can infuence results of benchmarks
const BIG_GC_THRESHOLD_NS = 50000.0


struct WarmupInfo {
    var executedBatches = 0
    var aggregateRuns = 0
    var aggregateStartBatchOverhead = 0.0
    var aggregateLoopOverheap = 0.0
    var batchMemoryOverhead = 0.0
    var benchmark: BenchmarkWrapper = EmptyBenchmark()
    var estimation = 0.0
    var gcCount = 0
    var overallAllocated = 0.0
    WarmupInfo(var warmupGC: ExplicitGcType) {}

    prop allocatedPerIteration: Float64 { get () {
        Float64(overallAllocated - batchMemoryOverhead * Float64(executedBatches)) / Float64(aggregateRuns)
    }}

    var ema = Ema(0)
    var emaGC = Ema(5)

    private mut func runMultipleAndEstimateTime(times: Int64, maxMeasureBatch: Int64): Float64 {
        let baseWithRun = benchmark.timeLoopOnce(times, times, maxMeasureBatch)
        let baseLoopOnly = benchmark.timeLoopOnce(0, times, maxMeasureBatch)
        let base = benchmark.timeLoopOnce(0, 0, maxMeasureBatch)

        aggregateLoopOverheap += baseLoopOnly - base
        aggregateStartBatchOverhead += base
        aggregateRuns += times
        executedBatches += 1

        max((baseWithRun - baseLoopOnly)/Float64(times), 0.001)
    }

    func avgIterTime(): Float64 {
        let overheadPerIteration = max(aggregateLoopOverheap / Float64(aggregateRuns), 0.0)
        estimation + overheadPerIteration * 2.0
    }

    private func memory(): Float64 {
        Float64(getGCFreedSize() + getAllocatedHeapSize())
    }

    private mut func beforeWarmup() {
        gcCount = getGCCount()
        // ideally this should be zero, however with current implementation of generics
        // there is an overhead to call our benchmark loop lambda
        let benchmark = benchmark
        let overhead = measureInternal(Runtime(AllocatedMemory)) {
            for (i in 0..20) {
                benchmark.measureLoopOnce(0, 0, 1)
            }
        }
        batchMemoryOverhead = overhead / 20.0
        overallAllocated = memory()
    }

    private mut func finishWarmup() {
        overallAllocated = memory() - overallAllocated
        gcCount = getGCCount() - gcCount
    
        estimation = ema.result

        overallAllocated -= batchMemoryOverhead * Float64(executedBatches * 3) // there are three calls for each batch
    }

    // for small allocation heavy benchmarks it is essential that we finish warmup
    // with same GC strategy that will be active during benchmark
    private mut func chooseWarmupGC() {
        let allocatedSoFar = memory() - overallAllocated - batchMemoryOverhead * Float64(executedBatches * 3)
        if (Float64(allocatedSoFar) / Float64(aggregateRuns) > MIN_OBJECT_SIZE) {
            warmupGC = Heavy
        }
    }

    mut func warmupDuration(warmupTime: Duration, maxMeasureBatch: Int64, explicitGC: ExplicitGcType) {
        beforeWarmup()
        let targetTime = Float64(warmupTime.toNanoseconds())

        var aggregateTime = 0.0
        var n = 0
        // use exponential moving average to prevent single abnormal result
        // on last warmup iteration to ruin some subsequent calculations
        // which can cause benchmark to work for too long
        ema = Ema(5)
        let start = TimeNow().measure()
        var elapsed = 0.0
        do {
            n = n * 12 / 10 + 1  // ~20% increase

            if (let Auto <- warmupGC && aggregateTime > Float64(warmupTime.toNanoseconds()) / 2.0) {
                // select GC strategy for second half of warmup, 
                // based on information of the first half
                chooseWarmupGC()
            }
            let warmupGC = warmupGC
            let gcDur = measureInternal(TimeNow()) { warmupGC.invoke() }
            if (let Heavy <- warmupGC) {
                emaGC.append(gcDur)
            }

            let estimation = runMultipleAndEstimateTime(n, maxMeasureBatch)
            // If estimation is that small then most likely result will be zero so we can speed up things.
            // Now, with blackBox it almost never happen, but there are cases where due to CPU speculative execution
            // for sufficiently small benchmark, actually executing code can take same time as not executing it.
            if (estimation <= 0.0001) {
                if (n > 1000000000) {
                    break
                }

                n = n * 10
            }
            aggregateTime += estimation * Float64(n)
            elapsed = TimeNow().measure() - start
            ema.append(estimation)
        } while (aggregateTime < targetTime && elapsed < targetTime*2.0)


        finishWarmup()
    }

    mut func warmupFixed(warmupCount: Int64, minMeasureBatch: Int64, maxMeasureBatch: Int64) {
        beforeWarmup()

        let batches = min(max(warmupCount / minMeasureBatch, 1), MEASUREMENTS_LIMIT)
        ema = Ema(batches / 2 + 1)
        for (i in 0..batches) {
            if (let Auto <- warmupGC && i > batches / 2) {
                chooseWarmupGC()
            }
            warmupGC.invoke()
            ema.append(runMultipleAndEstimateTime(warmupCount/batches, maxMeasureBatch))
        }

        finishWarmup()
    }
}

func measureInternal<T>(m: T, f:() -> Unit): Float64 where T <: Measurement{
    m.setup()
    let x = m.measure()
    f()
    m.measure() - x
}

@When[env != "ohos"]
func waitGCFinish() {
    if (isGCRunning()) {
        let gcCount = getGCCount()
        while (getGCCount() <= gcCount) {}
    }
}

@When[env == "ohos"]
func waitGCFinish() { }

class BenchRunner {
    var benchmark: BenchmarkWrapper = EmptyBenchmark()
    var measurements: ArrayList<BenchRawMeasurement> = ArrayList()
    var explicitGC: ExplicitGcType = Auto
    private var targetDuration: Duration = Duration.second
    private var minBatches: Int64 = 100
    private var batchSize: Range<Int64> = 1..MAX_BATCH_SIZE
    private var maxMeasureBatch = MAX_BATCH_SIZE
    private var warmupInfo = WarmupInfo(Auto)
    private var random = Random()
    var isRunning: Bool = false

    // whether we need full gc to be invoked before next benchmark
    private static var needFullGc = true
    
    private static var memoryDiff = unsafe { zeroValue<MemoryInfo>() } // prevent cyclic dependency

    public BenchRunner(let configuration: Configuration, let progress: ProgressOutput) {
        if (configuration.get<Measurement>(KeyMeasurement.measurement).isSome()) {
            let warning = "Warning: configuring measurement via @Configure[measurement: <Measurement>] is deprecated and not used any more. " +
                "Use @Measure macro instead."
            println(warning)
        }
    }

    private func warmupFixedSize(warmupCount: Int64) {
        if (warmupCount < 0 ) {
            throw IllegalArgumentException("Number of warmup iterations must be non negative")
        }
        if (warmupCount == 0) {
            if (maxMeasureBatch >= MAX_BATCH_SIZE) {
                throw IllegalArgumentException("if 'warmup' parameter is zero then 'batchSize' must be specified")
            }
            progress.println { "    Warmup disabled." }

            let avgBatchSize = Float64(batchSize.end + batchSize.start) / 2.0
            warmupInfo.estimation = Float64(targetDuration.toNanoseconds())/ avgBatchSize / Float64(minBatches)
            warmupInfo.aggregateRuns = 1
            warmupInfo.executedBatches = 1
        } else {
            progress.println { "    Warming up for ${warmupCount} iterations." }
            warmupInfo.warmupFixed(warmupCount, batchSize.start, batchSize.end)
        }
    }

    private func warmupAndEstimate() {
        warmupInfo.benchmark = this.benchmark
        if (let Some(warmupCount) <- configuration.get<Int64>(KeyWarmup.warmup)) {
            return warmupFixedSize(warmupCount)
        }

        let warmupTime = configuration.get<Duration>(KeyWarmup.warmup) ?? Duration.second
        progress.println { "    Warming up for ${printDuration(warmupTime)}."}

        warmupInfo.warmupDuration(warmupTime, maxMeasureBatch, explicitGC)
    }

    private func ensureFullGcIfNecessary() {
        waitGCFinish()
        if (!needFullGc) {
            return
        }

        // runs GC internally
        memoryDiff = memoryStats.updateAndDiff(from: 0)
    }

    private func preWarmupConfig() {
        this.explicitGC = configuration.get(KeyExplicitGC.explicitGC) ?? ExplicitGcType.Auto
        warmupInfo = WarmupInfo(this.explicitGC) // reset info

        this.targetDuration = configuration.get(KeyMinDuration.minDuration) ?? Duration.second * 5
        let minBatches = configuration.get(KeyMinBatches.minBatches) ?? 10
        this.minBatches = max(minBatches, 1)

        if (let Some(range) <- configuration.get<Range<Int64>>(KeyBatchSize.batchSize)) {
            this.maxMeasureBatch = range.end
            this.batchSize = max(range.start, 1)..range.end
        }
        if (let Some(size) <- configuration.get<Int64>(KeyBatchSize.batchSize)) {
            this.maxMeasureBatch = size
            this.batchSize = size..=size
        }
        if (this.batchSize.end <= 0){
            throw IllegalArgumentException("batchSize must be positive")
        }
    }

    // Runs warmup and based on various warmup measurements selects best values for various parameters
    func warmupAndConfigure(): Unit {
        preWarmupConfig()

        waitGCFinish()

        warmupAndEstimate()
        
        let gcPerInv = Float64(warmupInfo.gcCount) / Float64(warmupInfo.aggregateRuns)

        if (let Auto <- this.explicitGC) {
            let noGC = warmupInfo.allocatedPerIteration < MIN_OBJECT_SIZE && warmupInfo.gcCount == 0
            let alwaysGC = gcPerInv > 0.5
            let measuresGCInfo = (benchmark.measurement as Runtime)?.measuresGC() == Some(true)
            if (noGC || alwaysGC || measuresGCInfo) {
                this.explicitGC = Disabled
            } else {
                this.explicitGC = Heavy
            }
        }

        if (warmupInfo.gcCount > 0) {
            needFullGc = true
        }

    }

    func runBench() {
        // invoke gc here so that we have cleaned heap before next run
        // otherwise GC can be triggered on bench warmup polluting the results
        ensureFullGcIfNecessary()

        if (isRunning == true) {
            throw IllegalStateException("It is not allowed to run benchmark inside another benchmark")
        }
        isRunning = true
        try {
            runBenchInner()
        } finally {
            isRunning = false
        }

        let gcBatches = measurements.iterator().filter{ x => x[2] >= 1.0 }.count()
        let gcRatio = Float64(gcBatches) / Float64(measurements.size)
        let badBatches = measurements.iterator().filter{ x => x[2] > 1.99 }.count()

        // due to some issues in runtime this causes a lot of false positives
        // so for now warn only from 2 bad measurements
        let gcTwiceWarn = (!explicitGC.waitsForFinish() && badBatches >= 2)
            || (explicitGC.waitsForFinish() && gcBatches >= 1)

        if (gcTwiceWarn) {
            progress.println {
"""
Warning: GC was invoked twice during some of the batches. This can significantly affect final results.
         It is recommended to either increase heap size limit using cjHeapSize enviroment variable,
         increase default GC interval using cjGCInterval environment variable
         or reduce benchmark duration with minDuration parameter of @Configure macro.
"""
            }
        }

        let tooLongGc = gcRatio > 0.2 && memoryDiff.gcTimeNs > BIG_GC_THRESHOLD_NS
        if (tooLongGc) {
            progress.println {
"""
Warning: Too many objects survive GC which causes unexpectedly long GC times.
         Results might have been significantly affected by it. See documentation for more details and potential causes.
"""
            }
        }
    }

    func runBenchInner(): Unit {
        // do warmup and estimate the benchmark time
        warmupAndConfigure()

        let (batchRange, batchCount) = calcBatchSize()
        this.measurements.reserve(min(batchCount, MEASUREMENTS_LIMIT) - this.measurements.size)

        progress.println {
            let batch = Float64(batchRange.start)
            let measurementInfo = configuration.get(KeyMeasurementInfo.measurementInfo) ?? TimeNow().info
            let execTime = Duration.nanosecond * (batch + Float64(batchRange.end) / 2.0) * batchCount * warmupInfo.avgIterTime()
            "    Starting measurements of ${batchCount} batches. Measuring ${measurementInfo.name}.\n" +
                "    Max batch size: ${batchRange.end}, estimated execution time: ${printDuration(execTime)}."
        }

        maxMeasureBatch = this.batchSize.start
        let maxBatch = batchRange.end.ceilTo(maxMeasureBatch)
        let benchExecTime: Duration

        if (batchCount < 50 || (benchmark.measurement as Runtime)?.measuresGC() == Some(true)) {
            benchExecTime = doMacroBench(maxBatch, batchCount)
        } else {
            benchExecTime = doMicroBench(maxBatch, batchCount)
        }
        
        // add some overhead calculations to collect at least some overhead statistics if not enough normal batches
        for (i in min(batchCount, 10 - this.batchSize.start * 10 / maxBatch)..10) {
            runMultipleAndMeasure(0, maxBatch) 
        }

        progress.println {
            "Finished in ${printDuration(benchExecTime)}. Analysing results:"
 	    }
    }

    @OverflowWrapping
    private func doMicroBench(maxBatch: Int64, batchCount: Int64): Duration {
        let max = Float64(maxBatch)
        let avgStep = max / Float64(batchCount)
        let expectedGCTime = Duration.nanosecond * warmupInfo.emaGC.result * batchCount

        // run couple of times on max to ensure that runtime requested all required memory from OS.
        // Otherwise some allocations can cause page faults if new memory is requested from OS
        for (i in 0..2) {
            explicitGC.invoke()
            runMultipleAndMeasure(maxBatch, maxBatch)
        }
        this.measurements.clear()
        
        let start = DateTime.now()
        for (i in 0..batchCount/2) {

            // this way of invoking GC and changing batch size is necessary to average out the effects
            // of changing the batch size itself, and effects of memory usage that depends on batch size
            // Otherwise it is possible to get different results depending on whether batch size increasing or decreasing
            explicitGC.invoke()

            let idx = Float64(i*2)
            var batch = max - avgStep * idx
            runMultipleAndMeasure(Int64(batch |> round), maxBatch)

            batch = avgStep * Float64(idx + 1.0)
            runMultipleAndMeasure(Int64(batch |> round), maxBatch)
            // sanity check
            if (i*2 > minBatches && DateTime.now() - start > targetDuration * 4 + expectedGCTime && targetDuration > Duration.Zero) {
                break
            }
        }
        return DateTime.now() - start
    }

    @OverflowWrapping
    private func doMacroBench(max: Int64, batchCount: Int64): Duration{
        let avgStep = Float64(max) / Float64(batchCount)
        let expectedGCTime = Duration.nanosecond * warmupInfo.emaGC.result * batchCount
        let start = DateTime.now()

        explicitGC.invoke()
        runMultipleAndMeasure(0, 0)
        this.measurements.clear()

        var batch = 0.0
        for (i in 0..batchCount) {
            batch += avgStep

            explicitGC.invoke()
            runMultipleAndMeasure(Int64(batch |> ceil), max)

            // sanity check
            if (i > minBatches && DateTime.now() - start > targetDuration * 4 + expectedGCTime && targetDuration > Duration.Zero) {
                break
            }
        }
        return DateTime.now() - start
    }

    func calcBatchSize(): (Range<Int64>, Int64) {
        let targetDurationNs = max(Float64(targetDuration.toNanoseconds()), 0.0)
        
        let avgOneIterationTime = warmupInfo.avgIterTime()

        // how many batches if executing batches with sizes 1,2,3..N
        // it would be a solution to the quadratic equation: (estimation+overhead*2)*N^2 = duration
        let batchesFrom1ToN = targetDurationNs / avgOneIterationTime |> sqrt |> ceil

        // apply all of the constraints on amount of batches
        let batches = max(min(batchesFrom1ToN, DEFAULT_BATCHES_AMOUNT), Float64(minBatches))

        let avgBatchSize = if (targetDurationNs > 0.0) {
            targetDurationNs / avgOneIterationTime / batches
        } else if (this.batchSize.end >= MAX_BATCH_SIZE) {
            throw IllegalArgumentException("if 'minDuration' parameter is zero then 'batchSize' must be specified")
        } else {
            Float64(this.batchSize.end) / 2.0
        }

        // apply all of the constraints on batch size
        let maxBatchSize = Int64(ceil((avgBatchSize - 1.0) * 2.0 + 1.0))
        let range = 1..=max(maxBatchSize, this.batchSize.start)

        let finalAvgBatchSize = Float64(range.start + range.end) / 2.0
        let finalBatches = max(targetDurationNs / avgOneIterationTime / finalAvgBatchSize, Float64(minBatches))

        (range, Int64(ceil(finalBatches)))
    }

    private func runMultipleAndMeasure(t: Int64, max: Int64) {
        var times = min(t.ceilTo(maxMeasureBatch), max) // to fix rounding errors
    
        let gcCount = getGCCount()
        let dur = benchmark.measureLoopOnce(times, max, this.batchSize.end)
        waitGCFinish()

        let gcPolluted = getGCCount() - gcCount
        let result = (Float64(times), dur, Float64(gcPolluted))

        if (measurements.size > MEASUREMENTS_LIMIT) {
            let randomIdx = abs(random.nextInt64()) % measurements.size
            measurements[randomIdx] = result
        } else {
            measurements.add(result)
        }
    }
}

extend Int64 {
    func ceilTo(target: Int64): Int64 {
        Int64(ceil(Float64(this) / Float64(target)) * Float64(target)) 
    }
}

let gcFinished = AtomicBool(false)
var notifier: ?Notifier = None
class Notifier {
    ~init() {
        gcFinished.store(true)
    }
}

// Exponential moving average
// While number of added elements is less than maxLength it works exactly like regular average
protected struct Ema {
    protected var result: Float64 = 0.0
    private var currentLength: Float64 = 0.0
    protected Ema(let maxLength: Int64) {}

    protected mut func reset() {
        result = 0.0
        currentLength = 0.0
    }

    protected func reachedMax(): Bool {
        currentLength >= Float64(maxLength - 1)
    }

    protected mut func append(next: Float64) {
        result = (result * currentLength + next) / (currentLength + 1.0)
        currentLength = min(currentLength + 1.0, Float64(maxLength - 1))
    }
}

/**
 * Used to specify how GC is invoked by the test framework in benchmarks.
 * See std.runtime.gc(heavy: bool) for details about types of GC invocations
 */
public enum ExplicitGcType <: ToString {
    /**
     * GC will not be explicitly invoked by the framework.
     */
    | Disabled
    /**
     * runtime.gc(heavy: false) is invoked before most of measurement batches 
     * to try to evenly distribute GC impact between batches.
     * Will *not* wait for the end of GC before starting a measurement
     */
    | Light
    /**
     * runtime.gc(heavy: true) is invoked before most measurement batches.
     * Before starting a measurement it will busy-wait until GC and finalizers are finished.
     *
     * This variant produces the most stable and consistent results so it is more suitable option
     * for most common usecases of benchmarks.
     * However it completely excludes most effects of GC so results might not 
     * exactly represent real world performance for some allocation heavy benchmarks.
     */
    | Heavy
    /**
     * Framework automatically selects best option based on warmup results.
     * Current logic is to use Heavy if otherwise GC would have been called during benchmark.
     * and Disabled variant otherwise.
     */
    | Auto

    func waitsForFinish(): Bool {
        match(this) {
            case Heavy => true
            case _ => false
        }
    }

    func invoke() {
        match (this) {
            case Light where isGcEnabled => gc(heavy: false)
            case Heavy where isGcEnabled =>
                // This logic relies on implementation detail of cangjie runtime.
                // Currently finalizers are invoked in the order of their creation.
                // So our notifying finalizer will be called last, and this code expects that.
                gcFinished.store(false)
                notifier = Notifier()
                let before = getGCCount()
                notifier = None
                gc(heavy: true)
                // GC most likely will run on different CPU
                // so do busy wait to keep current CPU warmed up
                while (getGCCount() <= before) {}
                while (!gcFinished.load()) {}
            case _ => ()
        }
    }

    public func toString(): String {
        match (this) {
            case Disabled => "Disabled"
            case Light => "Light"
            case Heavy => "Heavy"
            case Auto => "Auto"
        }
    }
}
