/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@When[env != "ohos"]
public class LocalRegionOutOfMemoryError <: Error {
    init() {
        super()
    }

    init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        return "LocalRegionOutOfMemoryError"
    }
}
