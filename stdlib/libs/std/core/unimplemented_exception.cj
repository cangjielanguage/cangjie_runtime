/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * Thrown by local mode adapter default implementations to indicate that a
 * type has not yet provided an explicit `@local!` or `@local?` overload.
 *
 * This exception is the standard fallback for interface-level local mode
 * adaptation (e.g. `ToString.toString(this @local?)`, `Iterable.iterator`,
 * `Iterator.next`). When a concrete type does not override the local-mode
 * method, the default implementation throws `UnimplementedException` so the
 * developer immediately learns which type/method/mode is missing.
 */
@When[env != "ohos"]
public class UnimplementedException <: Exception {
    public init() {
        super("UnimplementedException")
    }

    public init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        return "UnimplementedException"
    }
}