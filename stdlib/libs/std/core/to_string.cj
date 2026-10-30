/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * This file introduces 'ToString' interface, which has a 'toString' function declaration.
 * 'toString' function is used to provide string representation for various types.
 * For primitive types, we provide standard toString implementation. For composite types
 * or user-defined types, they have to to implement toString function by themselves.
 */
public interface ToString {
    func toString(): String

    /**
     * Returns a String @local! bound to the caller's region.
     * Default implementation throws; concrete types bound to `local!`
     * (e.g. via `append<T>(this @local!, v: T @local?)`) should override
     * this to return a real `local!` String.
     */
    @When[env != "ohos"]
    func toString(this @local?): String @local! {
        throw UnimplementedException("Current Type does not implement 'toString' method for its @local? instance")
    }
}

extend Int64 <: ToString {
    @OverflowWrapping
    public func toString(): String {
        let (numLen, unum, buffer) = if (this < 0) {
            let unum = UInt64(-this)
            let numLen = 1 + calcNumLen(unum)
            let buffer = Array<Byte>(numLen, repeat: 0)
            buffer[0] = b'-'
            (numLen, unum, buffer)
        } else {
            let numLen = calcNumLen(UInt64(this))
            (numLen, UInt64(this), Array<Byte>(numLen, repeat: 0))
        }
        numberToString(unum, numLen, buffer)
        return String(buffer)
    }
    @OverflowWrapping
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let (numLen, unum, buffer) = if (this < 0) {
            let unum = UInt64(-this)
            let numLen = 1 + calcNumLen(unum)
            let buffer = Array<Byte>(numLen, repeat: 0) @local!
            buffer[0] = b'-'
            (numLen, unum, buffer)
        } else {
            let numLen = calcNumLen(UInt64(this))
            (numLen, UInt64(this), Array<Byte>(numLen, repeat: 0) @local!)
        }
        numberToString(unum, numLen, buffer)
        String(buffer) @local!
    }
}

extend IntNative <: ToString {
    @OverflowWrapping
    public func toString(): String {
        return Int64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Int64(this).toString()
    }
}

extend Int32 <: ToString {
    public func toString(): String {
        return Int64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Int64(this).toString()
    }
}

extend Int16 <: ToString {
    public func toString(): String {
        return Int64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Int64(this).toString()
    }
}

extend Int8 <: ToString {
    public func toString(): String {
        return Int64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Int64(this).toString()
    }
}

extend UInt64 <: ToString {
    public func toString(): String {
        let numLen = calcNumLen(this)
        let buffer = Array<Byte>(numLen, repeat: 0)
        numberToString(this, numLen, buffer)
        return String(buffer)
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let numLen = calcNumLen(this)
        let buffer = Array<Byte>(numLen, repeat: 0) @local!
        numberToString(this, numLen, buffer)
        String(buffer) @local!
    }
}

extend UIntNative <: ToString {
    @OverflowWrapping
    public func toString(): String {
        return UInt64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        UInt64(this).toString()
    }
}

extend UInt32 <: ToString {
    public func toString(): String {
        return UInt64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        UInt64(this).toString()
    }
}

extend UInt16 <: ToString {
    public func toString(): String {
        return UInt64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        UInt64(this).toString()
    }
}

extend UInt8 <: ToString {
    public func toString(): String {
        return UInt64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        UInt64(this).toString()
    }
}

extend Float64 <: ToString {
    public func toString(): String {
        let p: CPointer<UInt8> = unsafe { CJ_CORE_Float64ToCPointer(this) }
        if (p.isNull()) {
            return String()
        }
        let s: String = unsafe { createStrFromCPointer(p) }
        unsafe { LibC.free(p) }
        return s
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let p: CPointer<UInt8> = unsafe { CJ_CORE_Float64ToCPointer(this) }
        if (p.isNull()) {
            return String()
        }
        let s: String @local! = unsafe { createStrLocalFromCPointer(p) }
        unsafe { LibC.free(p) }
        return s
    }
}

extend Float32 <: ToString {
    public func toString(): String {
        return Float64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Float64(this).toString()
    }
}

extend Float16 <: ToString {
    public func toString(): String {
        return Float64(this).toString()
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        Float64(this).toString()
    }
}

extend Bool <: ToString {
    public func toString(): String {
        return if (this) {
            "true"
        } else {
            "false"
        }
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        if (this) {
            "true"
        } else {
            "false"
        }
    }
}

extend Rune <: ToString {
    public func toString(): String {
        return String([this])
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        let m: Array<Rune> @local! = [this]
        return String(m)
    }
}

extend Unit <: ToString {
    public func toString(): String {
        return "()"
    }
    @When[env != "ohos"]
    public exclave func toString(this @local?): String @local! {
        "()"
    }
}
