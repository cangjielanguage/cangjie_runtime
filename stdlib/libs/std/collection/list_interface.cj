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
    prop first: ?T
    prop last: ?T
    func get(index: Int64): ?T

    operator func [](index: Int64): T

    // Keep new receiver-mode members after existing members to preserve dispatch slots.
    @When[local_mode_api == "on"]
    func get(this @local!, index: Int64): ?T @local! {
        throw UnimplementedException("Current Type does not implement 'get' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func get(this @local?, index: Int64): ?T @local? {
        throw UnimplementedException("Current Type does not implement 'get' method for its @local? instance")
    }
    @When[local_mode_api == "on"]
    operator func [](this @local!, index: Int64): T @local! {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    operator func [](this @local?, index: Int64): T @local? {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local? instance")
    }
    @When[local_mode_api == "on"]
    prop first: ?T @local! {
        get() {
            throw UnimplementedException("Current Type does not implement 'first' property for its @local! instance")
        }
    }
    @When[local_mode_api == "on"]
    prop first: ?T @local? {
        get() {
            throw UnimplementedException("Current Type does not implement 'first' property for its @local? instance")
        }
    }
    @When[local_mode_api == "on"]
    prop last: ?T @local! {
        get() {
            throw UnimplementedException("Current Type does not implement 'last' property for its @local! instance")
        }
    }
    @When[local_mode_api == "on"]
    prop last: ?T @local? {
        get() {
            throw UnimplementedException("Current Type does not implement 'last' property for its @local? instance")
        }
    }
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
    @When[local_mode_api == "on"]
    func add(this @local!, element: T @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func add(this @local!, all!: Collection<T> @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func add(this @local!, element: T @local!, at!: Int64): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func add(this @local!, all!: Collection<T> @local!, at!: Int64): Unit {
        throw UnimplementedException("Current Type does not implement 'add' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func remove(this @local!, at!: Int64): T @local! {
        throw UnimplementedException("Current Type does not implement 'remove' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func remove(this @local!, range: Range<Int64>): Unit {
        throw UnimplementedException("Current Type does not implement 'remove' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func removeIf(this @local!, predicate: ((T @local!) -> Bool) @local?): Unit {
        throw UnimplementedException("Current Type does not implement 'removeIf' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    func clear(this @local!): Unit {
        throw UnimplementedException("Current Type does not implement 'clear' method for its @local! instance")
    }
    @When[local_mode_api == "on"]
    operator func [](this @local!, index: Int64, value!: T @local!): Unit {
        throw UnimplementedException("Current Type does not implement '[]' method for its @local! instance")
    }
}
