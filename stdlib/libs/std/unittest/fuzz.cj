/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.random.Random
import std.collection.ArrayList
import std.unittest.prop_test.*
import std.math.*

@C
struct UInt8Entry {
    UInt8Entry(let left!: UInt8 = 0, let right!: UInt8 = 0) {}
}

@C
struct UInt16Entry {
    UInt16Entry(let left!: UInt16 = 0, let right!: UInt16 = 0) {}
}

@C
struct UInt32Entry {
    UInt32Entry(let left!: UInt32 = 0, let right!: UInt32 = 0) {}
}

@C
struct UInt64Entry {
    UInt64Entry(let left!: UInt64 = 0, let right!: UInt64 = 0) {}
}

@C
struct Float32Entry {
    Float32Entry(let left!: Float32 = 0.0, let right!: Float32 = 0.0) {}
}

@C
struct Float64Entry {
    Float64Entry(let left!: Float64 = 0.0, let right!: Float64 = 0.0) {}
}

foreign func CJ_MICROFUZZ_FLIP_BIT_FLOAT(value: Float32, bit: UInt8): Float32

foreign func CJ_MICROFUZZ_FLIP_BIT_DOUBLE(value: Float64, bit: UInt8): Float64

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT8(result: CPointer<UInt8Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT16(result: CPointer<UInt16Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT32(result: CPointer<UInt32Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT64(result: CPointer<UInt64Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FLOAT(result: CPointer<Float32Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_DOUBLE(result: CPointer<Float64Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT8(key: UInt8, result: CPointer<UInt8Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT16(key: UInt16, result: CPointer<UInt16Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT32(key: UInt32, result: CPointer<UInt32Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT64(key: UInt64, result: CPointer<UInt64Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_FLOAT(key: Float32, result: CPointer<Float32Entry>): Unit

foreign func CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_DOUBLE(key: Float64, result: CPointer<Float64Entry>): Unit

foreign func CJ_MICROFUZZ_ENABLE_TRACE(): Unit

foreign func CJ_MICROFUZZ_DISABLE_TRACE(): Unit

foreign func CJ_MICROFUZZ_RESET_LOCAL_COVERAGE_INFO(): Unit

foreign func CJ_MICROFUZZ_RESET_ALL_COVERAGE_INFO(): Unit

foreign func CJ_MICROFUZZ_HAS_NEW_COVERAGE(): Bool

foreign func CJ_MICROFUZZ_IS_INITIALIZED(): Bool

foreign func CJ_MICROFUZZ_GLOBAL_EDGE_COVERAGE_EST(): Float64

foreign func CJ_MICROFUZZ_SET_DBG_CALLBACK(callback: CFunc<(CString, CString, UInt64, UInt64) -> Unit>): Unit

func currentCoverageEst() {
    unsafe { CJ_MICROFUZZ_GLOBAL_EDGE_COVERAGE_EST() }
}

interface Torcable<T> {
    static func randomRecentEntry(): ?(T, T)
    static func randomRecentValueComparedTo(value: T): ?T
    static func nextFrom(random: Random): T
    static func suggestedFrom(random: Random): T
    func isZero(): Bool
    func bitFlip(at: UInt8): T
    operator func+(_: UInt8): T
    operator func-(_: UInt8): T
}

extend UInt8 <: Torcable<UInt8> {
    public static func randomRecentEntry(): ?(UInt8, UInt8) {
        var cEntry = UInt8Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT8(inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: UInt8): ?UInt8 {
        var cEntry = UInt8Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT8(value, inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): UInt8 {
        random.nextUInt8()
    }
    public static func suggestedFrom(random: Random): UInt8 {
        random.suggestUInt8()
    }
    public func isZero() { this == 0 }
    public func bitFlip(at: UInt8): UInt8 {
        this ^ (1 << (at % 8))
    }
}

extend UInt16 <: Torcable<UInt16> {
    public static func randomRecentEntry(): ?(UInt16, UInt16) {
        var cEntry = UInt16Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT16(inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: UInt16): ?UInt16 {
        var cEntry = UInt16Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT16(value, inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): UInt16 {
        random.nextUInt16()
    }
    public static func suggestedFrom(random: Random): UInt16 {
        random.suggestUInt16()
    }
    public func isZero() { this == 0 }
    public func bitFlip(at: UInt8): UInt16 {
        this ^ (1 << (at % 16))
    }

    @OverflowWrapping
    public operator func+(arg: UInt8): UInt16 { this + UInt16(arg) }
    @OverflowWrapping
    public operator func-(arg: UInt8): UInt16 { this - UInt16(arg) }

}

extend UInt32 <: Torcable<UInt32> {
    public static func randomRecentEntry(): ?(UInt32, UInt32) {
        var cEntry = UInt32Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT32(inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: UInt32): ?UInt32 {
        var cEntry = UInt32Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT32(value, inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): UInt32 {
        random.nextUInt32()
    }
    public static func suggestedFrom(random: Random): UInt32 {
        random.suggestUInt32()
    }
    public func isZero() { this == 0 }
    public func bitFlip(at: UInt8): UInt32 {
        this ^ (1 << (at % 32))
    }

    @OverflowWrapping
    public operator func+(arg: UInt8): UInt32 { this + UInt32(arg) }
    @OverflowWrapping
    public operator func-(arg: UInt8): UInt32 { this - UInt32(arg) }
}
extend UInt64 <: Torcable<UInt64> {
    public static func randomRecentEntry(): ?(UInt64, UInt64) {
        var cEntry = UInt64Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_UINT64(inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: UInt64): ?UInt64 {
        var cEntry = UInt64Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_UINT64(value, inout cEntry) }
        if (cEntry.left == 0 && cEntry.right == 0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): UInt64 { random.nextUInt64() }
    public static func suggestedFrom(random: Random): UInt64 {
        random.suggestUInt64()
    }
    public func isZero() { this == 0 }
    public func bitFlip(at: UInt8): UInt64 {
        this ^ (1 << (at % 64))
    }

    @OverflowWrapping
    public operator func+(arg: UInt8): UInt64 { this + UInt64(arg) }
    @OverflowWrapping
    public operator func-(arg: UInt8): UInt64 { this - UInt64(arg) }
}

extend Float32 <: Torcable<Float32> {
    public static func randomRecentEntry(): ?(Float32, Float32) {
        var cEntry = Float32Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FLOAT(inout cEntry) }
        if (cEntry.left.isZero() && cEntry.right.isZero()) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: Float32): ?Float32 {
        var cEntry = Float32Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_FLOAT(value, inout cEntry) }
        if (cEntry.left == 0.0 && cEntry.right == 0.0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): Float32 {
        random.nextFloat32()
    }
    public static func suggestedFrom(random: Random): Float32 {
        random.suggestFloat32()
    }
    public func isZero() { this == 0.0 }
    public func bitFlip(at: UInt8): Float32 {
        unsafe { CJ_MICROFUZZ_FLIP_BIT_FLOAT(this, at) }
    }

    @OverflowWrapping
    public operator func+(arg: UInt8): Float32 { this + Float32(arg) }
    @OverflowWrapping
    public operator func-(arg: UInt8): Float32 { this - Float32(arg) }
}

extend Float64 <: Torcable<Float64> {
    public static func randomRecentEntry(): ?(Float64, Float64) {
        var cEntry = Float64Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_DOUBLE(inout cEntry) }
        if (cEntry.left.isZero() && cEntry.right.isZero()) { return None }
        return (cEntry.left, cEntry.right)
    }
    public static func randomRecentValueComparedTo(value: Float64): ?Float64 {
        var cEntry = Float64Entry()
        unsafe { CJ_MICROFUZZ_RANDOM_RECENT_CMP_VALUE_FOR_KEY_DOUBLE(value, inout cEntry) }
        if (cEntry.left == 0.0 && cEntry.right == 0.0) { return None }
        if (cEntry.left == value) { return cEntry.right }
        if (cEntry.right == value) { return cEntry.left }
        return None
    }
    public static func nextFrom(random: Random): Float64 {
        random.nextFloat64()
    }
    public static func suggestedFrom(random: Random): Float64 {
        random.suggestFloat64()
    }
    public func isZero() { this == 0.0 }
    public func bitFlip(at: UInt8): Float64 {
        unsafe { CJ_MICROFUZZ_FLIP_BIT_DOUBLE(this, at) }
    }

    @OverflowWrapping
    public operator func+(arg: UInt8): Float64 { this + Float64(arg) }
    @OverflowWrapping
    public operator func-(arg: UInt8): Float64 { this - Float64(arg) }
}


enum Mutation<T> where T <: Torcable<T> {
    | Drop
    | Insert(T)
    | ReplaceWith(T)
    | BitFlip(UInt8)
    | Add(UInt8)
    | Sub(UInt8)

    @OverflowWrapping
    func apply(at: Int64, values: ArrayList<T>): Unit {
        match (this) {
            case Drop => values.remove(at: at)
            case Insert(v) => values.add(v, at: at)
            case ReplaceWith(v) =>
                values[at] = v
            case BitFlip(bits) =>
                values[at] = values[at].bitFlip(bits)
            case Add(v) =>
                values[at] += v
            case Sub(v) =>
                values[at] -= v
        }
    }
}

class Mutator {
    Mutator(let random!: Random = Random()) {}

    func randomRecentValue<T>(): ?T where T <: Torcable<T> & ToString {
        let entry = T.randomRecentEntry() ?? return None
        if (random.nextBool()) {
            return entry[0]
        } else {
            return entry[1]
        }
    }

    func randomRecentCmp<T>(value: T): ?T where T <: Torcable<T> & ToString {
        match (T.randomRecentValueComparedTo(value)) {
            case Some(operand) => return operand
            case _ => randomRecentValue<T>()
        }
    }

    private func pickRandomMutation<T>(value: T): Mutation<T> where T <: Torcable<T> & ToString {
        match (random.nextUInt8(12)) {
            case 0 | 1 | 2 | 3 => // ~1/3
                let rep = randomRecentCmp<T>(value) ?? return pickRandomMutation<T>(value)
                ReplaceWith(rep)
            case 4 | 5 => // ~1/6
                ReplaceWith(T.suggestedFrom(random))
            case 6 | 7 => // ~1/6
                BitFlip(random.nextUInt8())
            case 8 => // ~1/12
                Add(random.nextUInt8(31) + 1)
            case 9 => // ~1/12
                Sub(random.nextUInt8(31) + 1)
            case 10 => // ~1/12
                Insert(value) // duplication
            case 11 => // ~1/12
                Drop
            case _ => throw Exception("Logic error: pickRandomMutation")
        }
    }

    func randomMutation<T>(temperature: UInt8, value: T): ?Mutation<T> where T <: Torcable<T> & ToString {
        if (random.nextUInt8() >= temperature) { return None }
        return pickRandomMutation<T>(value)
    }
}

private class MutatingRandomValueStream<T> where T <: Torcable<T> & ToString & Hashable & Equatable<T> {
    MutatingRandomValueStream(let values!: ArrayList<T> = ArrayList()) {}
    var currentIndex = 0

    func nextUniform(random: Random): T {
        let index = currentIndex
        currentIndex++
        while (index >= values.size) {
            values.add(T.nextFrom(random))
        }
        return values[index]
    }

    func next(random: Random, temperature: UInt8, mutator: Mutator): T {
        let index = currentIndex
        currentIndex++
        while (currentIndex >= values.size) {
            values.add(T.suggestedFrom(random))
        }
        mutator.randomMutation(temperature, values[index])?.apply(index, values)
        while (currentIndex >= values.size) {
            values.add(T.suggestedFrom(random))
        }
        return values[index]
    }

    func reset(): MutatingRandomValueStream<T> {
        MutatingRandomValueStream(values: values.clone())
    }

    func freeze(): MutatingRandomValueStream<T> {
        MutatingRandomValueStream(values: values)
    }
}

class CovRandomSource <: RandomSource {
    private let inner: Random

    private CovRandomSource(
        let seed!: UInt64,
        let temperature!: UInt8,
        private let valuesInt8!: MutatingRandomValueStream<UInt8>,
        private let valuesInt16!: MutatingRandomValueStream<UInt16>,
        private let valuesInt32!: MutatingRandomValueStream<UInt32>,
        private let valuesInt64!: MutatingRandomValueStream<UInt64>,
        private let valuesFloat32!: MutatingRandomValueStream<Float32>,
        private let valuesFloat64!: MutatingRandomValueStream<Float64>,
        private let mutator!: Mutator
    ) {
        this.inner = Random(seed)
    }

    init(seed!: UInt64, temperature!: UInt8 = 0, mutator!: Mutator = Mutator(random: Random(seed))) {
        this(
            seed: seed, temperature: temperature,
            valuesInt8: MutatingRandomValueStream(),
            valuesInt16: MutatingRandomValueStream(),
            valuesInt32: MutatingRandomValueStream(),
            valuesInt64: MutatingRandomValueStream(),
            valuesFloat32: MutatingRandomValueStream(),
            valuesFloat64: MutatingRandomValueStream(),
            mutator: mutator
        )
    }

    func copy(seed!: UInt64 = this.seed, temperature!: UInt8 = this.temperature): CovRandomSource {
        CovRandomSource(
            seed: seed, temperature: temperature,
            valuesInt8: valuesInt8.reset(), valuesInt16: valuesInt16.reset(),
            valuesInt32: valuesInt32.reset(), valuesInt64: valuesInt64.reset(),
            valuesFloat32: valuesFloat32.reset(), valuesFloat64: valuesFloat64.reset(),
            mutator: mutator
        )
    }

    func freeze(): CovRandomSource {
        CovRandomSource(
            seed: seed, temperature: 0,
            valuesInt8: valuesInt8.freeze(), valuesInt16: valuesInt16.freeze(),
            valuesInt32: valuesInt32.freeze(), valuesInt64: valuesInt64.freeze(),
            valuesFloat32: valuesFloat32.freeze(), valuesFloat64: valuesFloat64.freeze(),
            mutator: mutator
        )
    }

    public override func suggestBool(): Bool {
        return nextBool()
    }

    public override func suggestUInt8(): UInt8 {
        let result = valuesInt8.next(inner, temperature, mutator)
        return result
    }
    public override func suggestUInt16(): UInt16 {
        return valuesInt16.next(inner, temperature, mutator)
    }
    public override func suggestUInt32(): UInt32 {
        return valuesInt32.next(inner, temperature, mutator)
    }
    public override func suggestUInt64(): UInt64 {
        return valuesInt64.next(inner, temperature, mutator)
    }

    @OverflowWrapping
    public override func suggestInt8(): Int8 {
        Int8(suggestUInt8())
    }

    @OverflowWrapping
    public override func suggestInt16(): Int16 {
        Int16(suggestUInt16())
    }

    @OverflowWrapping
    public override func suggestInt32(): Int32 {
        Int32(suggestUInt32())
    }

    @OverflowWrapping
    public override func suggestInt64(): Int64 {
        Int64(suggestUInt64())
    }

    public override func nextFloat16(): Float16 {
        return Float16(valuesFloat32.nextUniform(inner))
    }
    public override func nextFloat32(): Float32 {
        return valuesFloat32.nextUniform(inner)
    }
    public override func nextFloat64(): Float64 {
        return valuesFloat64.nextUniform(inner)
    }

    @OverflowWrapping
    public override func suggestFloat16(): Float16 {
        return Float16(suggestFloat32())
    }
    public override func suggestFloat32(): Float32 {
        return valuesFloat32.next(inner, temperature, mutator)
    }
    public override func suggestFloat64(): Float64 {
        return valuesFloat64.next(inner, temperature, mutator)
    }

    private var gaussian = GaussianGenerator(0.0, 1.0)
    public override func nextGaussianFloat64(mean!: Float64 = 0.0, sigma!: Float64 = 1.0): Float64 {
        if (gaussian.mean != mean || gaussian.sigma != sigma) {
            this.gaussian = GaussianGenerator(mean, sigma)
        }
        return gaussian.next(this)
    }

    public override func nextUInt8(): UInt8 {
        valuesInt8.nextUniform(inner)
    }
    public override func nextUInt16(): UInt16 {
        valuesInt16.nextUniform(inner)
    }
    public override func nextUInt32(): UInt32 {
        valuesInt32.nextUniform(inner)
    }
    public override func nextUInt64(): UInt64 {
        valuesInt64.nextUniform(inner)
    }
}

class GaussianGenerator {
    var cached: ?Float64 = Option.None
    GaussianGenerator(let mean: Float64, let sigma: Float64) {}

    func next(random: RandomSource): Float64 {
        if (let Some(cached) <- this.cached) {
            this.cached = None
            return cached
        }
        var u1: Float64 = random.nextFloat64()
        let u2 = random.nextFloat64()

        let mag = sigma * sqrt(-2.0 * log(u1))
        let z0 = mag * cos(2.0 * Float64.GetPI()) + mean
        let z1 = mag * sin(2.0 * Float64.GetPI()) + mean
        this.cached = z1
        return z0
    }
}

class CoverageInfo {
    static func newCoverageDiscovered(): Bool {
        unsafe { CJ_MICROFUZZ_HAS_NEW_COVERAGE() }
    }
}
