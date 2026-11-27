/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.interop.arkts

// This package defines the root interface of the ArkTS interop type system. The declaration is guarded by
// @When[arkts_interop == "on"], so a build with the condition off produces an empty package.

/**
 * `ArkTSType` is the root interface of all ArkTS interop types. It has no members; a value that satisfies
 * the `ArkTSType` constraint can be assigned to a variable of this type.
 */
@When[arkts_interop == "on"]
@ArkTS
public interface ArkTSType {}
