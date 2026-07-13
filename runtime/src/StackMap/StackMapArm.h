// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_STACKMAP_ARM_H
#define MRT_STACKMAP_ARM_H
#include <stdint.h>
#include <unordered_map>

#include "StackMap/StackMapTypeDef.h"

namespace MapleRuntime {
class RegRoot {
public:
    RegRoot() = default;
    explicit RegRoot(RegBits bits) : regBits(bits) {}
    ~RegRoot() = default;

    RegRoot(const RegRoot& other) : regBits(other.regBits) {}
    RegRoot(RegRoot&& other) : regBits(other.regBits) { other.regBits = 0; }
    RegRoot& operator=(const RegRoot& other)
    {
        if (this == &other) {
            return *this;
        }
        regBits = other.regBits;
        return *this;
    }
    RegRoot& operator=(RegRoot&& other)
    {
        if (this == &other) {
            return *this;
        }
        regBits = other.regBits;
        other.regBits = 0;
        return *this;
    }

    static void RecordStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
    {
        constexpr Uptr slotLength = 4;
        constexpr Uptr calleeSavedAreaOffset = 4 * 4;
        Uptr slotAddr = fp + calleeSavedAreaOffset;
        static constexpr RegisterId calleeSavedRegiser[] = { R4, R5, R6, R7, R8, R9, R10};
        for (auto reg : calleeSavedRegiser) {
            regSlotsMap.Insert(reg, reinterpret_cast<SlotAddress>(slotAddr));
            slotAddr += slotLength;
        }
    }

    static void RecordC2NStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
    {
        constexpr Uptr slotLength = 4;
        // arm32 C2NStub stores extra metadata ahead of the callee-saved area.
        constexpr Uptr calleeSavedAreaOffset = 4 * 6;
        Uptr slotAddr = fp + calleeSavedAreaOffset;
        static constexpr RegisterId calleeSavedRegiser[] = { R4, R5, R6, R7, R8, R9, R10};
        for (auto reg : calleeSavedRegiser) {
            regSlotsMap.Insert(reg, reinterpret_cast<SlotAddress>(slotAddr));
            slotAddr += slotLength;
        }
    }

    static void RecordExclusiveStubCalleeSaved(RegSlotsMap& regSlotsMap, Uptr fp)
    {
        constexpr Uptr slotLength = 4;
        // arm32 ExclusiveScope reserves an N2CSlotData area ahead of the callee-saved registers.
        constexpr Uptr calleeSavedAreaOffset = 4 * 5;
        Uptr slotAddr = fp + calleeSavedAreaOffset;
        static constexpr RegisterId calleeSavedRegiser[] = { R4, R5, R6, R7, R8, R9, R10};
        for (auto reg : calleeSavedRegiser) {
            regSlotsMap.Insert(reg, reinterpret_cast<SlotAddress>(slotAddr));
            slotAddr += slotLength;
        }
    }

    static void RecordStubAllRegister(RegSlotsMap& regSlotsMap, Uptr fp)
    {
        constexpr Uptr slotLength = 4;
        constexpr Uptr registersAreaOffset = 4 * 4;
        Uptr slotAddr = fp + registersAreaOffset;
        for (RegisterNum i = R4; i <= R10; ++i, slotAddr += slotLength) {
            regSlotsMap.Insert(i, reinterpret_cast<SlotAddress>(slotAddr));
        }
    }

    bool VisitGCRoots(const RootVisitor& visitor, const RegDebugVisitor& debugFunc, RegSlotsMap& regSlotsMap,
                      std::list<Uptr>* rootsList = nullptr) const
    {
        RegBits bits = regBits;
        for (RegisterNum i = 0; bits != 0; ++i, bits >>= 1) {
            if ((bits & LOWEST_BIT) == 0) {
                continue;
            }
            if (!regSlotsMap.VisitSingleSlotsRoot(visitor, debugFunc, i, rootsList)) {
                return false;
            }
        }
        return true;
    }

    static void RecordRegs(RegSlotsMap& regSlotsMap, Uptr fp)
    {
        RecordStubAllRegister(regSlotsMap, fp);
    }

private:
    static constexpr RegBits LOWEST_BIT = 0x1;
    RegBits regBits{ 0 };
};
} // namespace MapleRuntime
#endif // MRT_STACKMAP_ARM_H
