/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * Some local-mode adapter defaults use this exception to report that a
 * concrete type has not provided the required method. For example,
 * `ToString.toString(this @local?)` throws it when not overridden.
 */
@When[local_mode_api == "on"]
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