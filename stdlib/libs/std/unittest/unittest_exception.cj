/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

public open class UnittestException <: Exception {
    init() {
        super()
    }

    init(message: String) {
        super(message)
    }

    protected open override func getClassName(): String {
        return "UnittestException"
    }
}

class ErrorWrapperException <: Exception {
    init(error: Error) {
        super(error.getStackTraceMessage())
    }

    protected override func getClassName(): String {
        return "ErrorWrapperException"
    }

    public override func toString(): String {
        return this.message
    }
}

public class UnittestTimeoutException <: Exception {
    init() {
        super()
    }

    protected open override func getClassName(): String {
        return "UnittestTimeoutException"
    }
}

public class UnittestCliOptionsFormatException <: UnittestException {
    init(optionName: String, actual!: String, expected!: String) {
        super(
            "Wrong ${optionName} option argument format. " +
            "Provided: ${actual}. " +
            expected
        )
    }

    init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        return "UnittestCliOptionsFormatException"
    }
}
