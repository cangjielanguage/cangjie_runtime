/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file The file contains implementation of statistical calculations required for benchmark analysis.
 */
package std.unittest

import std.collection.*
import std.math.*
import std.math
import std.random.Random
import std.sort.SortExtension
import std.sync.*
import std.unittest.common.DataStrategy
import std.unittest.diff.AssertPrintable
import std.unittest.prop_test.ShrinkHelpers

/**
 * kde calculation method is adaptive, so it has different values of parameters (bandwidth, next grid step, etc) in different points of the grid
 * class KdeParamsState stores and updates them
 */
protected class KdeParamsState {
    /**
     * invariant - everything (mainly gridPoint) in this algorithm moves only from left to right, this is important to maintain the time complexity of the algorithm
     * to quickly find the closest (less or equal) to the current gridPoint value in data, the algorithm stores it in a separate variable (gridPointClosestLessEqIndexInData)
     * (thanks to the invariant it is easy to update at each step)
     */
    var gridPointClosestLessEqIndexInData: Int64 = -1
    private var bandwidth: Float64
    private var windowStartIndex: Int64 = 0
    private var windowFinishIndex: Int64 = 0
    private let maxBandwidth: Float64

    // data must be sorted
    KdeParamsState(
        private let data: ArrayList<Float64>,
        private let kdeThroughput: Float64,
        private let minBandwidth: Float64,
        private let tmp: Float64
    ) {
        this.bandwidth = minBandwidth
        this.maxBandwidth = max(minBandwidth, tmp)
    }

    /**
     * when calcualtion kde, only points in "window" are taken into account
     * point is in window, when it is not more then MaxWindowCenterDiff away from the window center (current gridPoint)
     * by default maxWindowCenterDiff is equal to bandwidth
     */
    private func getMaxWindowCenterDiff(): Float64 {
        bandwidth
    }

    /**
     * invariant - window borders moves only to right
     * for maxWindowCenterDiff = bandwidth and bandwidth = (distance to kth closest) * const it is always true
     * in other case the contribution to kde of ignored points on the window boundaries for the most types of kernels is very small
     */
    private func updateWindowBorders(gridPoint: Float64) {
        let maxWindowCenterDiff = getMaxWindowCenterDiff()
        var (minWindowValue, maxWindowValue) = (gridPoint - maxWindowCenterDiff, gridPoint + maxWindowCenterDiff)

        while (windowStartIndex < data.size - 1 && data[windowStartIndex] < minWindowValue) {
            windowStartIndex += 1
        }
        while (windowFinishIndex < data.size - 1 && data[windowFinishIndex] < maxWindowValue) {
            windowFinishIndex += 1
        }
    }

    /**
     * we need to update gridPointClosestLessEqIndexInData when we change gridPoint
     * because of the invariant gridPoint moves only from left to right so as gridPointClosestLessEqIndexInData
     */
    private func getNextGridPointClosestLessEqIndexInData(gridPoint: Float64): Int64 {
        while (gridPointClosestLessEqIndexInData < data.size - 1 && data[gridPointClosestLessEqIndexInData + 1] <=
                gridPoint) {
            gridPointClosestLessEqIndexInData += 1
        }
        gridPointClosestLessEqIndexInData
    }

    // finds the distance from the current gridPoint to the k-th nearest point in data
    private func getKthClosestNeighbourDist(gridPoint: Float64, k: Int64): Float64 {
        var closestLessEqIndex = gridPointClosestLessEqIndexInData
        var closestMoreIndex = gridPointClosestLessEqIndexInData + 1
        var p = 0
        var pthClosest = gridPoint
        while (p < k && closestLessEqIndex >= 0 && closestMoreIndex < data.size) {
            if (closestLessEqIndex < 0) {
                pthClosest = data[closestMoreIndex]
                closestMoreIndex += 1
            } else if (closestMoreIndex >= data.size) {
                pthClosest = data[closestLessEqIndex]
                closestLessEqIndex -= 1
            } else {
                let lessEqCandidate = data[closestLessEqIndex]
                let moreCandidate = data[closestMoreIndex]
                if (gridPoint - lessEqCandidate > moreCandidate - gridPoint) {
                    pthClosest = data[closestMoreIndex]
                    closestMoreIndex += 1
                } else {
                    pthClosest = data[closestLessEqIndex]
                    closestLessEqIndex -= 1
                }
            }
            p += 1
        }
        abs(gridPoint - pthClosest)
    }

    /**
     * the main difference between different kde counting methods is mostly the bandwidth size and grid
     * the main purpose of this kde calculation algorithm is to work with bootstrap samples from benchmarks
     * i.e. 1) data often take the same values 2) algorithm need to have high accuracy in the points of data clustering 3) algorithm must work fast not in the points of data clustering
     * so in the algorithm is implemented adaptive kde, with the size of bandwidth proportional to distance to the sqrt(data.size) closest point in data
     * and adaptive grid with gridStep proportional to bandwidth
     * (sqrt(data.size) is empirically selected so that the algorithm works well on both sparse data and dense data)
     * in points of data clustering bandwidth and step will be small, so many points will be considered
     * on the other side not in the points of data clustering bandwidth and step will be big, so will be considered much less points
     */
    private func getNextBandwidth(gridPoint: Float64): Float64 {
        let k = Int64(ceil(sqrt(Float64(data.size))) + 1)
        var bandwidth = getKthClosestNeighbourDist(gridPoint, k)
        //so that bandwidth is not zeroed and the algorithm is not stuck in place in the end we compare with non-zero minBandwidth
        clamp(2.0 * bandwidth * kdeThroughput, minBandwidth, maxBandwidth)
    }

    func getGridStep(): Float64 {
        bandwidth
    }

    // main function to update parameters on each step
    func update(gridPoint: Float64) {
        // 1) update the auxiliary index gridPointClosestLessEqIndexInData to maintain time complexety
        gridPointClosestLessEqIndexInData = getNextGridPointClosestLessEqIndexInData(gridPoint)
        // 2) count bandwidth in gridPoint (it depends on the distance to data points)
        bandwidth = getNextBandwidth(gridPoint)
        // 3) update the borders of the new window (points from data that will be taken into account when calculating kde at this point)
        updateWindowBorders(gridPoint)
    }

    func getBandwidth(): Float64 {
        bandwidth
    }

    func getWindow(): (Int64, Int64) {
        (windowStartIndex, windowFinishIndex)
    }
}

protected class Sample {
    protected Sample(let data: ArrayList<Float64>) {
        // sorted to easily get percentiles
        this.data.removeIf { x => x.isNaN() }
        this.data.sort()
    }

    protected prop size: Int64 {
        get() { data.size }
    }

    protected func mean(): Float64 {
        let sum = data |> fold(0.0) { a, b => a + b }
        sum / Float64(data.size)
    }

    protected func percentile(ratio: Float64): Float64 {
        if (this.data.size == 0) {
            return Float64.NaN
        }
        let x = clamp(Float64(this.data.size - 1) * ratio, 0.0, Float64(this.data.size - 1))
        (this.data[Int64(ceil(x))] + this.data[Int64(floor(x))]) / 2.0
    }

    protected static func create(data: ArrayList<Float64>): Sample {
        Sample(data)
    }

    protected func stddev(): Float64 {
        let avg = mean()
        let sumSquared = data.iterator().fold(0.0) { acc, p => (p - avg)**2.0 + acc }
        sqrt(sumSquared / Float64(data.size))
    }

    protected func irq(): Float64 {
        this.percentile(0.75) - this.percentile(0.25)
    }

    protected func skewness(): Float64 {
        let avg = mean()
        let sumCubic = data.iterator().fold(0.0) { acc, p => (p - avg)**3.0 + acc }
        sumCubic / Float64(data.size) / stddev()**3.0
    }

    // kernel density estimation
    protected func kde(kdeThroughput: Float64): ArrayList<(Float64, Float64)> {

        // you can add additional kernels in the future
        func gaussianKernel(distance: Float64, bandwidth: Float64): Float64 {
            let pi = Float64.getPI()
            return (1.0 / (bandwidth * (2.0 * pi) ** 0.5)) * exp(-0.5 * (distance / bandwidth) ** 2)
        }

        // function to count kde using the selected kernel at the point
        func getGridPointKde(gridPoint: Float64, kdeParamsState: KdeParamsState,
            kernelFunction: (distance: Float64, bandwith: Float64) -> Float64): Float64 {
            var gridPointKdeSum = 0.0
            let (windowStartIndex, windowFinishIndex) = kdeParamsState.getWindow()
            for (dataPointIndex in windowStartIndex..windowFinishIndex) {
                let dataPoint = data[dataPointIndex]
                let distance = abs(gridPoint - dataPoint)
                gridPointKdeSum += kernelFunction(distance, kdeParamsState.getBandwidth())
            }
            return gridPointKdeSum / Float64(data.size)
        }

        /**
         * the algorithm itself

         * we need an approximate understanding of the range to determine the minimum bandwidth so the minimum length of the step
         * (the size of the step depends on the distance to some data point, then if in data there are many points with the same value we will loop forever without minBandwith)
         * (at the same time we have a boostrap sample, so it's very likely)
         */
        let irq = max(irq(), 0.01)
        let stddev = stddev()

        // values for the minimum are taken from the previous algorithm and selected empirically
        // in fact the first one is taken such that there are not too many points in grid, and the second value is a Silverman rule
        let baseRange = min(stddev, irq / 1.34)
        let minBandwidth = max(kdeThroughput * baseRange / (pow(Float64(data.size), 1.0 / 5.0)), 0.00001)

        // almost always data is either not skewed at all or skewed right.
        // so we only need to care about outliers on the right
        let startGridPoint = max(this.percentile(0.1) - 2.0 * baseRange - minBandwidth, this.data[0])
        let endGridPoint = min(max(this.percentile(0.90) + 2.0 * baseRange + minBandwidth, this.percentile(0.95)), this.data.last.getOrThrow())
        let range = endGridPoint - startGridPoint
        let maxBandwidth = range / 15.0

        // result is array of pairs (gridPoint, kde) that will then be displayed on the final chart
        var result = ArrayList<(Float64, Float64)>()

        // initialize params
        let kdeParamsState = KdeParamsState(data, kdeThroughput, minBandwidth, maxBandwidth)

        // main cycle
        var gridPoint = startGridPoint
        while (gridPoint < endGridPoint) {
            kdeParamsState.update(gridPoint)
            result.add((gridPoint, getGridPointKde(gridPoint, kdeParamsState, gaussianKernel)))
            gridPoint = gridPoint + kdeParamsState.getGridStep()
        }
        kdeParamsState.update(gridPoint)
        result.add((endGridPoint, getGridPointKde(endGridPoint, kdeParamsState, gaussianKernel)))
        return result
    }
}

protected class Measurements {
    protected Measurements(
        private let data: Array<(Float64,Float64)>
    ) {}

    protected var slopes: Sample = Sample(ArrayList())
    protected var mainSlope: Float64 = 0.0
    protected var intercept: Float64 = 0.0
    protected var errorEst: Float64 = 0.0
    protected var r2: Float64 = 0.0

    // Calculates mean slope according to ordinary least squares linear regression.
    protected func calculateMean(): This {
        let sumx = data.iterator().map { p => p[0] }.sum()
        let sumy = data.iterator().map { p => p[1] }.sum()
        let sumx2 = data.iterator().map { p => p[0] * p[0] }.sum()
        let sumxy = data.iterator().map { p => p[0] * p[1] }.sum()

        let n = Float64(data.size)

        this.mainSlope = (n * sumxy - sumx * sumy) / (n * sumx2 - sumx * sumx)

        this.intercept = (sumy - this.mainSlope * sumx) / n

        // we know apriori that under our model negative intercept or slope should not be possible
        // so we fall back to regressing to a line with zero intercept or zero slope in that case
        // choosing the one with lower MSE
        if (mainSlope < 0.0 || intercept < 0.0) {
            let slope = sumxy / sumx2
            let zeroInterceptMSE = data.iterator().map { p: (Float64, Float64) => pow(p[1] - p[0] * slope, 2) }.sum() /
                Float64(data.size)

            let intercept = sumy / n
            let zeroSlopeMSE = data.iterator().map { p: (Float64, Float64) => pow(p[1] - intercept, 2) }.sum() / Float64(
                data.size)

            if (zeroSlopeMSE < zeroInterceptMSE) {
                this.intercept = intercept
                this.mainSlope = 0.0
            } else {
                this.intercept = 0.0
                this.mainSlope = slope
            }
        }

        let sumres = data.iterator().map { p => pow(p[0] * mainSlope + intercept - p[1], 2.0) }.sum()
        let sumtot = data.iterator().map { p => pow(sumy / n - p[1], 2.0) }.sum()
        this.r2 = 1.0 - sumres / sumtot

        this
    }
}

interface AsFloat {
    func asFloat(): Float64
}

extend Float64 <: AsFloat {
    public func asFloat(): Float64 {
        this
    }
}

extend<T> Iterator<T> where T <: AsFloat {
    func sum(): Float64 {
        this.map{ x => x.asFloat() }.fold(0.0) { acc, p => acc + p }
    }
}
