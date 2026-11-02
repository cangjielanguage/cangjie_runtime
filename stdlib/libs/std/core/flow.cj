/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

func composition<T1, T2, T3>(f: (T1) -> T2, g: (T2) -> T3): (T1) -> T3 {
    return {x: T1 => g(f(x))}
}

exclave func composition<T1, T2, T3>(f: ((T1) -> T2) @local?, g: ((T2) -> T3) @local?): ((T1) -> T3) @local? {
    return {x: T1 => g(f(x))}
}

