/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@Intrinsic
func Int64Less(a: Int64, b: Int64): Bool

@Intrinsic
func Int64Greater(a: Int64, b: Int64): Bool

@Intrinsic
func Int64LessOrEqual(a: Int64, b: Int64): Bool

@Intrinsic
func Int64GreaterOrEqual(a: Int64, b: Int64): Bool

@Intrinsic
func Int64Equal(a: Int64, b: Int64): Bool

@Intrinsic
func Int64NotEqual(a: Int64, b: Int64): Bool

@Intrinsic
func Int32Less(a: Int32, b: Int32): Bool

@Intrinsic
func Int32Greater(a: Int32, b: Int32): Bool

@Intrinsic
func Int32LessOrEqual(a: Int32, b: Int32): Bool

@Intrinsic
func Int32GreaterOrEqual(a: Int32, b: Int32): Bool

@Intrinsic
func Int32Equal(a: Int32, b: Int32): Bool

@Intrinsic
func Int32NotEqual(a: Int32, b: Int32): Bool

@Intrinsic
func Int16Less(a: Int16, b: Int16): Bool

@Intrinsic
func Int16Greater(a: Int16, b: Int16): Bool

@Intrinsic
func Int16LessOrEqual(a: Int16, b: Int16): Bool

@Intrinsic
func Int16GreaterOrEqual(a: Int16, b: Int16): Bool

@Intrinsic
func Int16Equal(a: Int16, b: Int16): Bool

@Intrinsic
func Int16NotEqual(a: Int16, b: Int16): Bool

@Intrinsic
func Int8Less(a: Int8, b: Int8): Bool

@Intrinsic
func Int8Greater(a: Int8, b: Int8): Bool

@Intrinsic
func Int8LessOrEqual(a: Int8, b: Int8): Bool

@Intrinsic
func Int8GreaterOrEqual(a: Int8, b: Int8): Bool

@Intrinsic
func Int8Equal(a: Int8, b: Int8): Bool

@Intrinsic
func Int8NotEqual(a: Int8, b: Int8): Bool

@Intrinsic
func UInt64Less(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt64Greater(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt64LessOrEqual(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt64GreaterOrEqual(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt64Equal(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt64NotEqual(a: UInt64, b: UInt64): Bool

@Intrinsic
func UInt32Less(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt32Greater(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt32LessOrEqual(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt32GreaterOrEqual(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt32Equal(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt32NotEqual(a: UInt32, b: UInt32): Bool

@Intrinsic
func UInt16Less(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt16Greater(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt16LessOrEqual(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt16GreaterOrEqual(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt16Equal(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt16NotEqual(a: UInt16, b: UInt16): Bool

@Intrinsic
func UInt8Less(a: UInt8, b: UInt8): Bool

@Intrinsic
func UInt8Greater(a: UInt8, b: UInt8): Bool

@Intrinsic
func UInt8LessOrEqual(a: UInt8, b: UInt8): Bool

@Intrinsic
func UInt8GreaterOrEqual(a: UInt8, b: UInt8): Bool

@Intrinsic
func UInt8Equal(a: UInt8, b: UInt8): Bool

@Intrinsic
func UInt8NotEqual(a: UInt8, b: UInt8): Bool

@Intrinsic
func Float16Less(a: Float16, b: Float16): Bool

@Intrinsic
func Float16Greater(a: Float16, b: Float16): Bool

@Intrinsic
func Float16LessOrEqual(a: Float16, b: Float16): Bool

@Intrinsic
func Float16GreaterOrEqual(a: Float16, b: Float16): Bool

@Intrinsic
func Float16Equal(a: Float16, b: Float16): Bool

@Intrinsic
func Float16NotEqual(a: Float16, b: Float16): Bool

@Intrinsic
func Float32Less(a: Float32, b: Float32): Bool

@Intrinsic
func Float32Greater(a: Float32, b: Float32): Bool

@Intrinsic
func Float32LessOrEqual(a: Float32, b: Float32): Bool

@Intrinsic
func Float32GreaterOrEqual(a: Float32, b: Float32): Bool

@Intrinsic
func Float32Equal(a: Float32, b: Float32): Bool

@Intrinsic
func Float32NotEqual(a: Float32, b: Float32): Bool

@Intrinsic
func Float64Less(a: Float64, b: Float64): Bool

@Intrinsic
func Float64Greater(a: Float64, b: Float64): Bool

@Intrinsic
func Float64LessOrEqual(a: Float64, b: Float64): Bool

@Intrinsic
func Float64GreaterOrEqual(a: Float64, b: Float64): Bool

@Intrinsic
func Float64Equal(a: Float64, b: Float64): Bool

@Intrinsic
func Float64NotEqual(a: Float64, b: Float64): Bool

public enum Ordering {
    LT | GT | EQ
}

public interface Less<T> {
    operator func <(other: T): Bool
}

public interface Greater<T> {
    operator func >(other: T): Bool
}

public interface LessOrEqual<T> {
    operator func <=(other: T): Bool
}

public interface GreaterOrEqual<T> {
    operator func >=(other: T): Bool
}

public interface Comparable<T> <: Equatable<T> & Less<T> & Greater<T> & LessOrEqual<T> & GreaterOrEqual<T> {
    func compare(other: T): Ordering

    operator func ==(other: T): Bool {
        return match (this.compare(other)) {
            case EQ => true
            case _ => false
        }
    }

    operator func <(other: T): Bool {
        return match (this.compare(other)) {
            case LT => true
            case _ => false
        }
    }

    operator func >(other: T): Bool {
        return match (this.compare(other)) {
            case GT => true
            case _ => false
        }
    }

    operator func <=(other: T): Bool {
        return match (this.compare(other)) {
            case LT | EQ => true
            case _ => false
        }
    }

    operator func >=(other: T): Bool {
        return match (this.compare(other)) {
            case GT | EQ => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    func compare(this @local?, other: T @local?): Ordering {
        throw UnimplementedException("Current Type does not implement 'compare' method for its @local? instance")
    }

    @When[env != "ohos"]
    operator func ==(this @local?, other: T @local?): Bool {
        return match (this.compare(other)) {
            case EQ => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    operator func <(this @local?, other: T @local?): Bool {
        return match (this.compare(other)) {
            case LT => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    operator func >(this @local?, other: T @local?): Bool {
        return match (this.compare(other)) {
            case GT => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    operator func <=(this @local?, other: T @local?): Bool {
        return match (this.compare(other)) {
            case LT | EQ => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    operator func >=(this @local?, other: T @local?): Bool {
        return match (this.compare(other)) {
            case GT | EQ => true
            case _ => false
        }
    }
}

extend Ordering <: ToString {
    public func toString(): String {
        return match (this) {
            case GT => "Ordering.GT"
            case LT => "Ordering.LT"
            case EQ => "Ordering.EQ"
        }
    }

    @When[env != "ohos"]
    public func toString(this @local?): String @local! {
        exclave {
            return match (this) {
                case GT => "Ordering.GT"
                case LT => "Ordering.LT"
                case EQ => "Ordering.EQ"
            }
        }
    }
}

/**
 * The relationship between Orderings is: Ordering.LT < Ordering.EQ < Ordering.GT
 */
extend Ordering <: Comparable<Ordering> {
    public func compare(other: Ordering): Ordering {
        return match ((this, other)) {
            case (LT, LT) | (EQ, EQ) | (GT, GT) => EQ
            case (LT, EQ) | (LT, GT) | (EQ, GT) => LT
            case _ => GT
        }
    }

    @When[env != "ohos"]
    public func compare(this @local?, other: Ordering @local?): Ordering {
        return match ((this, other)) {
            case (LT, LT) | (EQ, EQ) | (GT, GT) => EQ
            case (LT, EQ) | (LT, GT) | (EQ, GT) => LT
            case _ => GT
        }
    }

    @When[env != "ohos"]
    public operator func ==(this @local?, other: Ordering @local?): Bool {
        return match ((this, other)) {
            case (LT, LT) | (EQ, EQ) | (GT, GT) => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    public operator func !=(this @local?, other: Ordering @local?): Bool {
        !(this == other)
    }

    @When[env != "ohos"]
    public operator func <(this @local?, other: Ordering @local?): Bool {
        return match ((this, other)) {
            case (LT, EQ) | (LT, GT) | (EQ, GT) => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    public operator func >(this @local?, other: Ordering @local?): Bool {
        return match ((this, other)) {
            case (GT, EQ) | (GT, LT) | (EQ, LT) => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    public operator func <=(this @local?, other: Ordering @local?): Bool {
        return match ((this, other)) {
            case (LT, LT) | (EQ, EQ) | (GT, GT) | (LT, EQ) | (LT, GT) | (EQ, GT) => true
            case _ => false
        }
    }

    @When[env != "ohos"]
    public operator func >=(this @local?, other: Ordering @local?): Bool {
        return match ((this, other)) {
            case (LT, LT) | (EQ, EQ) | (GT, GT) | (EQ, LT) | (GT, EQ) | (GT, LT) => true
            case _ => false
        }
    }
}

extend IntNative <: Comparable<IntNative> {
    public func compare(other: IntNative): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: IntNative @local?): Ordering {
        let a: IntNative = this
        let b: IntNative = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: IntNative @local!): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: IntNative @local!): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: IntNative @local?): Bool {
        let a: IntNative = this
        let b: IntNative = other
        a >= b
    }

}

extend Int64 <: Comparable<Int64> {
    public func compare(other: Int64): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @When[env != "ohos"]
    public func compare(this @local?, other: Int64 @local?): Ordering {
        let a: Int64 = this
        let b: Int64 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Int64 @local!): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Int64 @local!): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Int64 @local?): Bool {
        let a: Int64 = this
        let b: Int64 = other
        a >= b
    }


    @Frozen
    public operator func <(other: Int64): Bool {
        return Int64Less(this, other)
    }

    @Frozen
    public operator func >(other: Int64): Bool {
        return Int64Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Int64): Bool {
        return Int64LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Int64): Bool {
        return Int64GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Int64): Bool {
        return Int64Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Int64): Bool {
        return Int64NotEqual(this, other)
    }
}

extend Int32 <: Comparable<Int32> {
    public func compare(other: Int32): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Int32): Bool {
        return Int32Less(this, other)
    }

    @Frozen
    public operator func >(other: Int32): Bool {
        return Int32Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Int32): Bool {
        return Int32LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Int32): Bool {
        return Int32GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Int32): Bool {
        return Int32Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Int32): Bool {
        return Int32NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Int32 @local?): Ordering {
        let a: Int32 = this
        let b: Int32 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Int32 @local!): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Int32 @local!): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Int32 @local?): Bool {
        let a: Int32 = this
        let b: Int32 = other
        a >= b
    }

}

extend Int16 <: Comparable<Int16> {
    public func compare(other: Int16): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Int16): Bool {
        return Int16Less(this, other)
    }

    @Frozen
    public operator func >(other: Int16): Bool {
        return Int16Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Int16): Bool {
        return Int16LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Int16): Bool {
        return Int16GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Int16): Bool {
        return Int16Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Int16): Bool {
        return Int16NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Int16 @local?): Ordering {
        let a: Int16 = this
        let b: Int16 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Int16 @local!): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Int16 @local!): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Int16 @local?): Bool {
        let a: Int16 = this
        let b: Int16 = other
        a >= b
    }

}

extend Int8 <: Comparable<Int8> {
    public func compare(other: Int8): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Int8): Bool {
        return Int8Less(this, other)
    }

    @Frozen
    public operator func >(other: Int8): Bool {
        return Int8Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Int8): Bool {
        return Int8LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Int8): Bool {
        return Int8GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Int8): Bool {
        return Int8Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Int8): Bool {
        return Int8NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Int8 @local?): Ordering {
        let a: Int8 = this
        let b: Int8 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Int8 @local!): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Int8 @local!): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Int8 @local?): Bool {
        let a: Int8 = this
        let b: Int8 = other
        a >= b
    }

}

extend UIntNative <: Comparable<UIntNative> {
    public func compare(other: UIntNative): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: UIntNative @local?): Ordering {
        let a: UIntNative = this
        let b: UIntNative = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: UIntNative @local!): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: UIntNative @local!): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: UIntNative @local?): Bool {
        let a: UIntNative = this
        let b: UIntNative = other
        a >= b
    }

}

extend UInt64 <: Comparable<UInt64> {
    public func compare(other: UInt64): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: UInt64): Bool {
        return UInt64Less(this, other)
    }

    @Frozen
    public operator func >(other: UInt64): Bool {
        return UInt64Greater(this, other)
    }

    @Frozen
    public operator func <=(other: UInt64): Bool {
        return UInt64LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: UInt64): Bool {
        return UInt64GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: UInt64): Bool {
        return UInt64Equal(this, other)
    }

    @Frozen
    public operator func !=(other: UInt64): Bool {
        return UInt64NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: UInt64 @local?): Ordering {
        let a: UInt64 = this
        let b: UInt64 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: UInt64 @local!): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: UInt64 @local!): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: UInt64 @local?): Bool {
        let a: UInt64 = this
        let b: UInt64 = other
        a >= b
    }

}

extend UInt32 <: Comparable<UInt32> {
    public func compare(other: UInt32): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: UInt32): Bool {
        return UInt32Less(this, other)
    }

    @Frozen
    public operator func >(other: UInt32): Bool {
        return UInt32Greater(this, other)
    }

    @Frozen
    public operator func <=(other: UInt32): Bool {
        return UInt32LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: UInt32): Bool {
        return UInt32GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: UInt32): Bool {
        return UInt32Equal(this, other)
    }

    @Frozen
    public operator func !=(other: UInt32): Bool {
        return UInt32NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: UInt32 @local?): Ordering {
        let a: UInt32 = this
        let b: UInt32 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: UInt32 @local!): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: UInt32 @local!): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: UInt32 @local?): Bool {
        let a: UInt32 = this
        let b: UInt32 = other
        a >= b
    }

}

extend UInt16 <: Comparable<UInt16> {
    public func compare(other: UInt16): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: UInt16): Bool {
        return UInt16Less(this, other)
    }

    @Frozen
    public operator func >(other: UInt16): Bool {
        return UInt16Greater(this, other)
    }

    @Frozen
    public operator func <=(other: UInt16): Bool {
        return UInt16LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: UInt16): Bool {
        return UInt16GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: UInt16): Bool {
        return UInt16Equal(this, other)
    }

    @Frozen
    public operator func !=(other: UInt16): Bool {
        return UInt16NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: UInt16 @local?): Ordering {
        let a: UInt16 = this
        let b: UInt16 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: UInt16 @local!): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: UInt16 @local!): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: UInt16 @local?): Bool {
        let a: UInt16 = this
        let b: UInt16 = other
        a >= b
    }

}

extend UInt8 <: Comparable<UInt8> {
    public func compare(other: UInt8): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: UInt8): Bool {
        return UInt8Less(this, other)
    }

    @Frozen
    public operator func >(other: UInt8): Bool {
        return UInt8Greater(this, other)
    }

    @Frozen
    public operator func <=(other: UInt8): Bool {
        return UInt8LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: UInt8): Bool {
        return UInt8GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: UInt8): Bool {
        return UInt8Equal(this, other)
    }

    @Frozen
    public operator func !=(other: UInt8): Bool {
        return UInt8NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: UInt8 @local?): Ordering {
        let a: UInt8 = this
        let b: UInt8 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: UInt8 @local!): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: UInt8 @local!): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: UInt8 @local?): Bool {
        let a: UInt8 = this
        let b: UInt8 = other
        a >= b
    }

}

extend Float16 <: Comparable<Float16> {
    public func compare(other: Float16): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Float16): Bool {
        return Float16Less(this, other)
    }

    @Frozen
    public operator func >(other: Float16): Bool {
        return Float16Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Float16): Bool {
        return Float16LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Float16): Bool {
        return Float16GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Float16): Bool {
        return Float16Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Float16): Bool {
        return Float16NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Float16 @local?): Ordering {
        let a: Float16 = this
        let b: Float16 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Float16 @local!): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Float16 @local!): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Float16 @local?): Bool {
        let a: Float16 = this
        let b: Float16 = other
        a >= b
    }

}

extend Float32 <: Comparable<Float32> {
    public func compare(other: Float32): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Float32): Bool {
        return Float32Less(this, other)
    }

    @Frozen
    public operator func >(other: Float32): Bool {
        return Float32Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Float32): Bool {
        return Float32LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Float32): Bool {
        return Float32GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Float32): Bool {
        return Float32Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Float32): Bool {
        return Float32NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Float32 @local?): Ordering {
        let a: Float32 = this
        let b: Float32 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Float32 @local!): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Float32 @local!): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Float32 @local?): Bool {
        let a: Float32 = this
        let b: Float32 = other
        a >= b
    }

}

extend Float64 <: Comparable<Float64> {
    public func compare(other: Float64): Ordering {
        match {
            case this < other => Ordering.LT
            case this > other => Ordering.GT
            case _ => Ordering.EQ
        }
    }

    @Frozen
    public operator func <(other: Float64): Bool {
        return Float64Less(this, other)
    }

    @Frozen
    public operator func >(other: Float64): Bool {
        return Float64Greater(this, other)
    }

    @Frozen
    public operator func <=(other: Float64): Bool {
        return Float64LessOrEqual(this, other)
    }

    @Frozen
    public operator func >=(other: Float64): Bool {
        return Float64GreaterOrEqual(this, other)
    }

    @Frozen
    public operator func ==(other: Float64): Bool {
        return Float64Equal(this, other)
    }

    @Frozen
    public operator func !=(other: Float64): Bool {
        return Float64NotEqual(this, other)
    }
    @When[env != "ohos"]
    public func compare(this @local?, other: Float64 @local?): Ordering {
        let a: Float64 = this
        let b: Float64 = other
        match {
            case a < b => Ordering.LT
            case a > b => Ordering.GT
            case _ => Ordering.EQ
        }
    }
    @When[env != "ohos"]
    public operator func ==(this @local!, other: Float64 @local!): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func ==(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a == b
    }
    @When[env != "ohos"]
    public operator func !=(this @local!, other: Float64 @local!): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func !=(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a != b
    }
    @When[env != "ohos"]
    public operator func <(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a < b
    }
    @When[env != "ohos"]
    public operator func >(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a > b
    }
    @When[env != "ohos"]
    public operator func <=(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a <= b
    }
    @When[env != "ohos"]
    public operator func >=(this @local?, other: Float64 @local?): Bool {
        let a: Float64 = this
        let b: Float64 = other
        a >= b
    }

}

@Frozen
public func max<T>(a: T, b: T, others: Array<T>): T where T <: Comparable<T> {
    var max = if (a > b) { a } else { b }
    if (others.size == 0) {
        return max
    }
    for (item in others) {
        if (max < item) {
            max = item
        }
    }
    return max
}

@Frozen
public func min<T>(a: T, b: T, others: Array<T>): T where T <: Comparable<T> {
    var min = if (a < b) { a } else { b }
    if (others.size == 0) {
        return min
    }
    for (item in others) {
        if (min > item) {
            min = item
        }
    }
    return min
}
