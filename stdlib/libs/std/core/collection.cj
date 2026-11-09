/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
   The root interface in the collection hierarchy.
   A collection represents a group of objects, known as its elements.
   Some collections allow duplicate elements and others do not.
   Some are ordered and others unordered.
   This interface is typically used to pass collections around and manipulate them where maximum generality is desired.
 */
public interface Collection<T> <: Iterable<T> {
    // Returns the number of elements in this collection.
    prop size: Int64

    // Returns true if this collection contains no elements.
    func isEmpty(): Bool

    func toArray(): Array<T> {
        return Array<T>(this)
    }

    @When[env != "ohos"]
    func isEmpty(this @local?): Bool {
        throw UnimplementedException("Current Type does not implement 'isEmpty' method for its @local? instance")
    }

    @When[env != "ohos"]
    func toArray(this @local?): Array<T> @local? {
        throw UnimplementedException("Current Type does not implement 'toArray' method for its @local? instance")
    }
    @When[env != "ohos"]
    func toArray(this @local!): Array<T> @local! {
        throw UnimplementedException("Current Type does not implement 'toArray' method for its @local! instance")
    }
}
