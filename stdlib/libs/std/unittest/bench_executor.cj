/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.collection.*
import std.convert.Formattable
import std.math.abs
import std.math.sqrt
import std.random.Random
import std.runtime.ProcessorInfo
import std.runtime.getProcessorCount
import std.unittest.common.PrettyText


protected type BenchRawMeasurement = (Float64, Float64, Float64)

class BenchExecutor<T> <: Executor {
    var step = 0

    BenchExecutor(
        private let strategy: DataStrategyProcessor<T>,
        private let measurement: Measurement,
        private let doRun: (T, Int64, Int64, Int64, Measurement) -> Float64
    ) {
    }

    public func execute(suiteInfo: TestSuiteReportInfo, tcase: TestCaseResult, configuration: Configuration): Unit {

        let progress = ProgressOutput(configuration)
        let benchRunner = BenchRunner(configuration, progress)
        strategy.nextIteration(configuration)
        
        let measurementInfo = configuration.get(KeyMeasurementInfo.measurementInfo).getOrThrow()
        while (true) {
            let result = strategy.processNextWith(configuration) {
                v, inputs => runSingle(v, inputs, suiteInfo, tcase.caseId, tcase.caseInfo, benchRunner, progress,
                    configuration, step)
            }

            match (result) {
                case Success(result) =>
                    step += 1
                    tcase.add(result)
                    if (let Bench(benchmarkResult) <- result.info) {
                        benchmarkResult.printSummary(progress, measurementInfo)
                    }
                case Failure(input, failure) =>
                    tcase.add(failure)
                    break
                case NoItems => break
                case StrategyError(e) =>
                    tcase.add(strategyErrorAsResult(e, ArgumentDescription(None, step, 0, None)))
            }
        }
    }

    func runSingle(
        value: T, inputs: Array<InputParameter>, suiteInfo: TestSuiteReportInfo, caseId: TestCaseId, caseInfo: TestCaseReportInfo,
        benchRunner: BenchRunner, progress: ProgressOutput, configuration: Configuration, step: Int64
    ): RunStepResult {
        let args = formatArgs(inputs)
        let tags = if (configuration.showTags && let Some(string) <- tagsToString(caseInfo.merge(suiteInfo).tags)) {
            " ${string}"
        } else {
            ""
        }
        progress.println {
            "Starting the benchmark `${caseId.suiteId.suiteName}.${caseId.caseName}(${args?.toString() ?? ""})`${tags}."
        }

        let mockOptForBenchEnabled = configuration.get(KeyOptimizeMocksForBench.optimizeMocksForBench) ?? false

        benchRunner.benchmark = if (mockOptForBenchEnabled) {
            MockBenchWrapper<T>(value, caseId.caseName, measurement, doRun)
        } else {
            SimpleBenchWrapper<T>(value, measurement, doRun)
        }

        benchRunner.measurements = ArrayList()
        let stepKind = CaseStep(ArgumentDescription(args, step, 0, None))
        Framework.runStepBody(stepKind, StepInfo.Bench(BenchmarkResult(benchRunner.measurements)), caseId.caseName) {
            benchRunner.runBench()
        }
    }

    private func formatArgs(inputs: Array<InputParameter>): ?PrettyText {
        if (inputs.isNoArg()) {
            return None
        }
        let sb = StringBuilder()
        for (i in 0..inputs.size) {
            // skip empty unit strategy
            if (inputs[i].name.isEmpty()) {
                continue
            }

            if (inputs[i].repr.size < 15) {
                sb.append(inputs[i].repr)
            } else {
                sb.append("${inputs[i].name}[${inputs[i].position}]")
            }
            if (i < inputs.size - 1) {
                sb.append(',')
            }
        }
        match (sb.toString()) {
            case "" => None
            case argString => PrettyText(argString)
        }
    }
}

protected struct StatisticsSample {
    let _kde: ArrayList<(Float64, Float64)> = ArrayList<(Float64, Float64)>()
    protected StatisticsSample(let sample: Sample) {}

    protected init() {
        this(Sample(ArrayList()))
    }

    protected init(cap: Int64) {
        this(Sample(ArrayList(cap)))
    }

    protected func isEmpty(): Bool {
        sample.data.isEmpty()
    }

    protected func append(data: Float64) {
        sample.data.add(data)
    }

    protected func finish() {
        sample.data.removeIf { x => x.isNaN() }
        sample.data.sort()
    }

    protected prop mean: Float64 { get() {
        sample.mean()
    }}

    protected prop median: Float64 { get() {
        sample.percentile(0.5)
    }}

    protected prop lowerBound: Float64 { get() {
        sample.percentile(0.01)
    }}

    protected prop upperBound: Float64 { get() {
        sample.percentile(0.99)
    }}

    private func update() {
        if (_kde.isEmpty()) {
            _kde.add(all: sample.kde(0.6))
        }
    }

    protected prop kde: ArrayList<(Float64, Float64)> { get() {
        update()
        _kde
    }}

    protected prop mode: Float64 { get () {
        kde.iterator().maxBy{ a => a[1] }[0]
    }}

    // second mode to detect multimodality
    protected func mode2(): Float64 {
        let (modeIdx, (mode, modeDensity)) = kde.iterator().enumerate().maxBy{ a => a[1][1] }

        let kdeCopy = _kde.clone()

        // remove points related to main mode
        for (direction in [1, -1]) {
            var i = modeIdx + direction
            var localMin = modeDensity
            while (i < kdeCopy.size && i >= 0) {
                let (val, density) = kdeCopy[i]
                if (density < localMin) {
                    localMin = density
                }
                if (density > localMin * 2.0) {
                    break
                }

                kdeCopy[i] = (val, 0.0)
                i += direction
            }
        }
        kdeCopy[modeIdx] = (mode, 0.0)

        // find mode of remaining distribution
        let (mode2, density2) = kdeCopy.iterator().maxBy{ a => a[1] }

        // if the second mode is big enough
        if (density2 / modeDensity > 0.15) {
            mode2
        } else {
            Float64.NaN
        }
    }
}

private let BOOTSTRAP_ITERATIONS: Int64 = 2000
private let BOOTSTRAP_PARALLEL: Int64 = 8
private let EXPECTED_CAP: Int64 = BOOTSTRAP_ITERATIONS / BOOTSTRAP_PARALLEL

protected enum SeparateGc <: ToString {
    | AllPoints
    | GCOnly
    | WithoutGCOnly

    public func toString() {
        match(this) {
            case AllPoints => "all"
            case GCOnly => "only GC"
            case WithoutGCOnly => "no GC"
        }
    }

    protected func hasSeparation() {
        match (this) {
            case AllPoints => false
            case GCOnly | WithoutGCOnly => true
        }
    }

    protected func toFilter(): (BenchRawMeasurement) -> Bool {
        match (this) {
            case AllPoints => { x => true }
            case GCOnly => { x => x[2] >= 1.0 }
            case WithoutGCOnly => { x => x[2] == 0.0 }
        }
    }
}

protected class BenchmarkResult {
    protected var finished = false

    protected var bootstrapped: BootstrapResult = BootstrapResult(AllPoints)

    protected prop median: Float64 { get() {
        bootstrapped.resultSample.sample.percentile(0.5)
    }}
    protected prop medianCI99: Float64 { get() {
        (bootstrapped.medianStats.sample.percentile(0.99) - bootstrapped.medianStats.sample.percentile(0.01)) / 2.0
    }}

    protected prop mean: Float64 { get() {
        bootstrapped.resultSample.sample.mean()
    }}
    protected prop meanCI99: Float64 { get() {
        (bootstrapped.meanStats.sample.percentile(0.99) - bootstrapped.meanStats.sample.percentile(0.01)) / 2.0
    }}

    protected prop overhead: Float64 { get() {
        bootstrapped.overhead.sample.percentile(0.5)
    }}

    protected prop mainResult: Float64 { get() {
        median
    }}

    protected prop errorEst: Float64 { get () {
        if (meanCI99 < 0.000001) { 0.0 } else { meanCI99 }
    }}

    protected prop errorEstPercent: Float64 { get() {
        let result = this.median
        let error = this.errorEst
        if (error == 0.0 && result == 0.0) {
            0.0
        } else {
            error / result * 100.0
        }
    }}

    protected BenchmarkResult(var data: ArrayList<BenchRawMeasurement>) {}

    protected func calculate(measurement: MeasurementInfo) {
        if (finished) { return }

        bootstrap(measurement)

        finished = true
    }

    private func bootstrap(measurement: MeasurementInfo) {
        let workers = min(getProcessorCount(), BOOTSTRAP_PARALLEL)

        let gcBatches = data.iterator().filter{ x => x[2] >= 1.0}.count()
        let badBatches = Float64(data.iterator().filter{ x => x[2] > 1.99}.count())
        let gcRatio = Float64(gcBatches) / Float64(data.size)
        let separateGcPollution = if (data.size <= 20 || measurement.name.startsWith("Runtime")) {
            // not much points to separate. And benchmark likely big enough for that to not matter.
            // Also no need to separate runtime impact if user was explicitly measuring it.
            AllPoints
        } else if (gcRatio > 0.8 && gcBatches > 3) {
            // almost all batches with GC so use them for main result
            GCOnly
        } else if (gcRatio < 0.6 && gcBatches > 0) {
            // enough batches without GC so use them for main result
            WithoutGCOnly
        } else {
            AllPoints
        }

        bootstrapped = (0..workers) |>
            map { _ => ArrayList<BenchRawMeasurement>(data.size) } |>
            mapParallelOrdered(workers) { subsample =>
                let results = BootstrapResult(separateGcPollution)
                let random = Random()
                for (_ in 0..BOOTSTRAP_ITERATIONS / workers) {
                    subsample.clear()
                    for (_ in 0..data.size) {
                        let p = random.nextInt64(data.size)
                        subsample.add(data[p])
                    }
                    results.appendStatisticsFromSample(subsample)
                }
                results
            } |>
            fold(BootstrapResult(separateGcPollution)) { a, b => a.join(b) }

        bootstrapped.finish(data)
    }

    func printSummary(progress: ProgressOutput, measurementInfo: MeasurementInfo) {
        let converter = measurementInfo.conversionTable
        this.calculate(measurementInfo)

        let plusMinus = if (isConsoleUtf8) { "±" } else { "+/-" }

        let table: PrettyTable = PrettyTable(sep: " ", separateColumnsNames: false, leftAligneAll: true, minColumnWidth: 1)
        table.addColumns(["percentiles: ", "[", "10%", "50%", "90%", "95%", "99%", "]"])
        table.nextRow()
        table.addCell("time:        ")
        table.addCell("[")
        table.addCell(converter.toString(bootstrapped.resultSample.sample.percentile(0.10)))
        table.addCell(converter.toString(bootstrapped.resultSample.sample.percentile(0.50)))
        table.addCell(converter.toString(bootstrapped.resultSample.sample.percentile(0.90)))
        table.addCell(converter.toString(bootstrapped.resultSample.sample.percentile(0.95)))
        table.addCell(converter.toString(bootstrapped.resultSample.sample.percentile(0.99)))
        table.addCell("]")

        let pp = TerminalPrettyPrinter.fromDefaultConfiguration()
        pp.append(table)

        progress.println{
            "  mean:           " +
            converter.toString(bootstrapped.meanStats.sample.percentile(0.01)) + " .. " +
            converter.toString(bootstrapped.meanStats.sample.percentile(0.99)) + "  " +
            "Err " + plusMinus + (errorEstPercent).format(".1") + "%"
        }

        progress.println{
            "  median:         " +
            converter.toString(bootstrapped.resultSample.sample.percentile(0.01)) + " .. " +
            converter.toString(bootstrapped.resultSample.sample.percentile(0.99))
        }

        let r2Low = bootstrapped.r2Stats.sample.percentile(0.01)
        let r2High = bootstrapped.r2Stats.sample.percentile(0.99)
        progress.println{
            "  R²:             " +
            r2Low.format(".3").toString() + " .. " + r2High.format(".3").toString()
        }

        progress.println{
            "  stddev:         " +
            converter.toString(bootstrapped.meanStats.sample.stddev())
        }

        progress.println{""}
    }
}

extend<T> Iterator<T> {
    func minBy<K>(f: (T) -> K): T where K <: Comparable<K> {
        var current = this.next().getOrThrow()
        var key = f(current)
        for (e in this) {
            let new_key = f(e)
            if (new_key < key) {
                key = new_key
                current = e
            }
        }

        current
    }

    func maxBy<K>(f: (T) -> K): T where K <: Comparable<K> {
        var current = this.next().getOrThrow()
        var key = f(current)
        for (e in this) {
            let new_key = f(e)
            if (new_key > key) {
                key = new_key
                current = e
            }
        }

        current
    }
}


protected class BootstrapResult {
    protected let meanStats = StatisticsSample(EXPECTED_CAP)
    protected let meanOverheadStats = StatisticsSample(EXPECTED_CAP)
    protected let medianStats = StatisticsSample(EXPECTED_CAP)
    protected let medianOverheadStats = StatisticsSample(EXPECTED_CAP)
    protected let r2Stats = StatisticsSample(EXPECTED_CAP)
    let buffer = ArrayList<Float64>()
    let buffer2 = ArrayList<Float64>()

    // if we excluded measurements polluted by GC, do a separate analysis with all points included
    protected var allPoints: ?BootstrapResult = None
    protected var resultSample = StatisticsSample()

    protected BootstrapResult(
        let separateGc: SeparateGc
    ){
        if (separateGc.hasSeparation()) {
            allPoints = default()
        }
    }

    protected prop overhead: StatisticsSample {
        get() {
            let medianOH = medianOverheadStats.median
            let medianIrq = medianOverheadStats.sample.irq()
            let meanOH = meanOverheadStats.mean
            let meanIrq = meanOverheadStats.sample.irq()
            // Choose better estimation of overhead based on their IRQ.
            // It is necessary because for cases with heteroschedasticity, 
            // median estimation is much better because it is a robust estimator.
            // But for good cases where OLS is the best linear regression estimator,
            // OLS based bootstrapped distribution of overhead is also the best.
            if (abs(meanOH - medianOH) < medianIrq/2.0 && medianIrq > meanIrq) {
                meanOverheadStats
            } else {
                medianOverheadStats
            }
        }
    }

    private static func default(): BootstrapResult {
        BootstrapResult(AllPoints)
    }

    protected func join(other: BootstrapResult): BootstrapResult {
        meanStats.sample.data.add(all: other.meanStats.sample.data)
        meanOverheadStats.sample.data.add(all: other.meanOverheadStats.sample.data)
        medianStats.sample.data.add(all: other.medianStats.sample.data)
        medianOverheadStats.sample.data.add(all: other.medianOverheadStats.sample.data)
        r2Stats.sample.data.add(all: other.r2Stats.sample.data)
        allPoints?.join(other.allPoints.getOrThrow())
        this
    }

    protected func finish(rawData: ArrayList<BenchRawMeasurement>): Unit {
        var f = None<Future<Unit>>
        if (let Some(all) <- allPoints) {
            f = spawn { all.finish(rawData) }
        }
        
        meanStats.finish()
        meanOverheadStats.finish()
        medianStats.finish()
        medianOverheadStats.finish()
        r2Stats.finish()

        resultSample = valuesSample(rawData)
        f?.get()
    }

    // bootstrap actual values distribution accounting for batch size and overhead
    protected func valuesSample(rawData: ArrayList<BenchRawMeasurement>): StatisticsSample {
        let result = ArrayList<Float64>()

        let overhead = overhead.sample

        let mean = meanStats.sample

        let N1 = overhead.mean()
        let N2 = mean.mean()

        let stddev1 = overhead.stddev()
        let stddev2 = medianStats.sample.stddev()
        let gcRatio = rawData.iterator().map{ x => x[2] }.sum() / Float64(rawData.size)

        let random = Random()
        for (_ in 0..BOOTSTRAP_ITERATIONS) {
            let offset = overhead.data.size / 5 // remove overhead outliers
            
            let overheadIdx = try { random.nextInt64(overhead.data.size - 2 * offset) + offset } catch (_: Exception) { 0 }

            let overhead_sample = max(overhead.data[overheadIdx], 0.0)

            let meanIdx = try { random.nextInt64(mean.data.size) } catch (_: Exception) { 0 }

            let mean_sample = mean.data[meanIdx]
            
            let batch = rawData[random.nextInt64(rawData.size)]
            if (!separateGc.toFilter()(batch)) { continue }


            // The main idea here is that when batch size is small then most of the dispersion
            // is explained by deviation in overhead.
            // So here we assume that our measured distribution is a sum of overhead distribution
            // and batchSize*<distribution we want to bootstrap>
            // Under such assumption we know that mean of sum of distributions = sum of means
            // However those are most likely not normal distributions so we can't use
            // formula for variance of sum of normal distributions.
            // Moreover if distribution is multimodal then such assumption do not work at all.
            // So instead in practice stddev of sum = sum of stddevs assumption works very well.
            // At least it gives expected results if there are two very distinct modes in our distribution.

            // sampled mean of measured distribution
            let N = overhead_sample + batch[0] * mean_sample
            let b = (batch[1] - N)
            let variance1 = stddev1
            let variance2 = batch[0] * stddev2

            // ratio of how much of variance comes from the variance of actual benchmark
            let b2 = b * variance2 / (variance2 + variance1)

            let value = mean_sample + b2/batch[0]
            if (!value.isNaN()) {
                result.add(value)
            } else {
                result.add(mean_sample)
            }
        }

        StatisticsSample(Sample(result))
    }

    protected func appendStatisticsFromSample(subsample: ArrayList<BenchRawMeasurement>): Unit {
        allPoints?.appendStatisticsFromSample(subsample)

        let filtered = subsample.iterator().filter(separateGc.toFilter()).map{ x => (x[0], x[1]) } |> collectArray
        if (filtered.size < 5 || filtered.size < subsample.size/10) {
            return
        }

        let (median, overheadMedian) = medianRegression(filtered)
        if (!median.isNaN()) {
            this.medianStats.append(median)
            this.medianOverheadStats.append(overheadMedian)
        }

        let (mean, meanOverhead, r2) = olsRegression(filtered)
        if (!mean.isNaN()) {
            this.meanStats.append(mean)
            this.meanOverheadStats.append(meanOverhead)
            this.r2Stats.append(r2)
        }
    }

    private func olsRegression(subsample: Array<(Float64, Float64)>): (Float64, Float64, Float64) {
        let result = Measurements(subsample).calculateMean()
        (result.mainSlope, result.intercept, result.r2)
    }

    // Uses shrinked version of Theil-Sen linear regression for sqrt(n) random points.
    // It produces much worse results, but it is compensated by bootstrapping.
    // Otherwise it has unacceptable performance when used together with bootstrapping.   
    private func medianRegression(subsample: Array<(Float64, Float64)>): (Float64, Float64) {
        // reduce allocation pressure
        let slopes = buffer
        let intercepts = buffer2
        slopes.clear()
        intercepts.clear()

        // use only sqrt points for suitable performance
        let sqrtSlice = 0..max(Int64(sqrt(Float64(subsample.size))), min(subsample.size, 15))

        for (i in sqrtSlice) {
            let (x1, y1) = subsample[i]
            for (j in sqrtSlice) {
                let (x2, y2) = subsample[j]
                if (abs(x1 - x2) > 0.0001) {
                    let slope = (y1 - y2) / (x1 - x2)
                    let yat0 = abs(y2 - x2 * slope) - 0.001
                    if (yat0 > y2 || yat0 > y1) {
                        // do not include nonsensical values that are impossible under our model
                        continue
                    }
                    slopes.add(slope)
                    intercepts.add(y1 - x1 * slope)
                }
            }
        }
        let slope = Sample(slopes).percentile(0.5)
        let intercept = Sample(intercepts).percentile(0.5)
        (slope, intercept)
    }
}
