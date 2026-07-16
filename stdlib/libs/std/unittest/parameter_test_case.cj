/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.random.Random
import std.unittest.prop_test.RandomSource

extend Configuration {
    mut prop random: ?RandomSource {
        get() { get<RandomSource>(KeyRandom.random) }
        set(value) {
            match (value) {
                case None =>
                    remove<RandomSource>(KeyRandom.random)
                case Some(v) =>
                    set<RandomSource>(KeyRandom.random, v)
            }
            return
        }
    }

    @OverflowWrapping
    func initRandom() {
        let random = if (let Some(seed) <- get(KeyRandomSeed.randomSeed)) {
            Random(UInt64(seed))
        } else {
            Random()
        }
        set(KeyRandomSeed.randomSeed, Int64(random.seed))
        set<RandomSource>(KeyRandom.random, random)
    }

    prop generationSteps: Int64 {
        get() { get(KeyGenerationSteps.generationSteps) ?? 200 }
    }
    prop reductionSteps: Int64 {
        get() { get(KeyReductionSteps.reductionSteps) ?? 200 }
    }
}
