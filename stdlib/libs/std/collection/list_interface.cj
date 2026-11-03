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
 * This file defines ReadOnlyList and List interface.
 */
package std.collection

public interface ReadOnlyList<T> <: Collection<T> {
    // The plain `first`/`last` properties carry throwing default bodies so that a plain receiver
    // resolves to the plain property instead of being captured by the `@local?` overload below.
    @When[env != "ohos"]
    prop first: ?T {
        get() {
            throw UnimplementedException("Current Type does not implement 'first' property")
        }
    }
    @When[env != "ohos"]
    prop last: ?T {
        get() {
            throw UnimplementedException("Current Type does not implement 'last' property")
        }
    }
    func get(index: Int64): ?T
    @When[env != "ohos"]
    func get(this @local!, index: Int64): ?T @local! {
        throw UnimplementedException("Current Type does not implement 'get' method for its @local! instance")
    }
    @When[env != "ohos"]
    func get(this @local?, index: Int64): ?T @local? {
        throw UnimplementedException("Current Type does not implement 'get' method for its @local? instance")
    }
    operator func [](index: Int64): T
    @When[env != "ohos"]
    operator func [](this @local!, index: Int64): T @local! {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local! instance")
    }
    @When[env != "ohos"]
    operator func [](this @local?, index: Int64): T @local? {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local? instance")
    }
    @When[env != "ohos"]
    prop first: ?T @local! {
        get() {
            throw UnimplementedException("Current Type does not implement 'first' property for its @local! instance")
        }
    }
    @When[env != "ohos"]
    prop first: ?T @local? {
        get() {
            throw UnimplementedException("Current Type does not implement 'first' property for its @local? instance")
        }
    }
    @When[env != "ohos"]
    prop last: ?T @local! {
        get() {
            throw UnimplementedException("Current Type does not implement 'last' property for its @local! instance")
        }
    }
    @When[env != "ohos"]
    prop last: ?T @local? {
        get() {
            throw UnimplementedException("Current Type does not implement 'last' property for its @local? instance")
        }
    }

    @When[env == "ohos"]
    prop first: ?T

    @When[env == "ohos"]
    prop last: ?T
}

public interface List<T> <: ReadOnlyList<T> {
    func add(element: T): Unit
    func add(all!: Collection<T>): Unit
    func add(element: T, at!: Int64): Unit
    func add(all!: Collection<T>, at!: Int64): Unit
    func remove(at!: Int64): T
    func remove(range: Range<Int64>): Unit
    func removeIf(predicate: (T) -> Bool): Unit
    func clear(): Unit
    operator func [](index: Int64, value!: T): Unit
    @When[env != "ohos"]
    func add(this @local!, element: T @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[env != "ohos"]
    func add(this @local!, all!: Collection<T> @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[env != "ohos"]
    func add(this @local!, element: T @local!, at!: Int64): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[env != "ohos"]
    func add(this @local!, all!: Collection<T> @local!, at!: Int64): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[env != "ohos"]
    func remove(this @local!, at!: Int64): T @local! {
        throw UnimplementedException("Current Type does not implement 'remove' method for its @local! instance")
    }
    @When[env != "ohos"]
    func remove(this @local!, range: Range<Int64>): Unit {
        throw UnimplementedException("Current Type does not implement 'remove' method for its @local! instance")
    }
    @When[env != "ohos"]
    func removeIf(this @local!, predicate: ((T @local!) -> Bool) @local?): Unit {
        throw UnimplementedException("Current Type does not implement 'removeIf' method for its @local! instance")
    }
    @When[env != "ohos"]
    func clear(this @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'clear' method for its @local! instance")
    }
    @When[env != "ohos"]
    operator func [](this @local!, index: Int64, value!: T @local!): Unit {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local! instance")
    }
}
