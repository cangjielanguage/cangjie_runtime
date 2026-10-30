/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

public enum Option<T> {
    Some(T)
    | None

    /*
     * @throws NoneValueException if the value of Option is None
     */
    @Frozen
    public func getOrThrow(): T {
        match (this) {
            case Some(v) => v
            case None => throw NoneValueException()
        }
    }

    /*
     * @throws NoneValueException if the value of Option is None
     */
    @Frozen
    @When[env != "ohos"]
    public exclave func getOrThrow(this @local!): T @local! {
        match (this) {
            case Some(v) => v
            case None => throw NoneValueException()
        }
    }

    /*
     * @throws input Exception if the value of Option is None
     */
    @Frozen
    public func getOrThrow(exception: () -> Exception): T {
        match (this) {
            case Some(v) => v
            case None => throw exception()
        }
    }

    /*
     * @throws input Exception if the value of Option is None
     */
    @Frozen
    @When[env != "ohos"]
    public exclave func getOrThrow(this @local!, exception: () -> Exception): T @local! {
        match (this) {
            case Some(v) => v
            case None => throw exception()
        }
    }

    @Frozen
    public func getOrDefault(other: () -> T): T {
        match (this) {
            case Some(v) => v
            case None => other()
        }
    }

    @Frozen
    public func isNone(): Bool {
        match (this) {
            case None => true
            case Some(_) => false
        }
    }

    @Frozen
    @When[env != "ohos"]
    public func isNone(this @local?): Bool {
        match (this) {
            case None => true
            case Some(_) => false
        }
    }

    @Frozen
    public func isSome(): Bool {
        match (this) {
            case Some(_) => true
            case None => false
        }
    }

    @Frozen
    @When[env != "ohos"]
    public func isSome(this @local?): Bool {
        match (this) {
            case Some(_) => true
            case None => false
        }
    }

    public func map<R>(transform: (T) -> R): Option<R> {
        match (this) {
            case Some(v) => Some(transform(v))
            case None => None
        }
    }

    public func filter(predicate: (T) -> Bool): Option<T> {
        let v = this ?? return None
        if (predicate(v)) {
            return v
        }
        return None
    }

    public func flatMap<R>(transform: (T) -> Option<R>): Option<R> {
        match (this) {
            case Some(v) => transform(v)
            case None => None
        }
    }
}

public func ifSome<T>(o: Option<T>, action: (T) -> Unit): Unit {
    match (o) {
        case Some(v) => action(v)
        case None => ()
    }
}

public func ifNone<T>(o: Option<T>, action: () -> Unit): Unit {
    match (o) {
        case Some(v) => ()
        case None => action()
    }
}

extend<T> Option<T> <: Equatable<Option<T>> where T <: Equatable<T> {
    @Frozen
    public operator func ==(other: Option<T>): Bool {
        return match ((this, other)) {
            case (Some(v1), Some(v2)) => v1 == v2
            case (None, None) => true
            case _ => false
        }
    }

    @Frozen
    public operator func !=(other: Option<T>): Bool {
        return !(this == other)
    }
}

extend<T> Option<T> <: ToString where T <: ToString {
    public func toString(): String {
        match (this) {
            case Some(s) => "Some(${s})"
            case None => "None"
        }
    }
    // toString(this @local?) is not implemented (open defect, localized 2026-10-16): a generic
    // `Option<T> @local!` match-unpack yields a corrupted payload reference; GC scanning reports
    // "heap object must not reference local object" -> SIGABRT. Construction and predicates
    // (isSome/getOrThrow) are fine; only generic match-unpack triggers it; non-generic
    // (Option<String>) is fine. Repro: exclave func f<T>(o: Option<T> @local!) { match (o) { case Some(v) => 1; case _ => 0 } }
}

extend<T> Option<T> <: Hashable where T <: Hashable {
    public func hashCode(): Int64 {
        return match (this) {
            case Some(v) => v.hashCode()
            case None => 0
        }
    }

    @When[env != "ohos"]
    public func hashCode(this @local?): Int64 {
        return match (this) {
            case Some(v) => v.hashCode()
            case None => 0
        }
    }
}

extend<T> Option<Option<T>> {
    public func flatten(): Option<T> {
        match (this) {
            case Some(o) => o
            case None => None
        }
    }
}
