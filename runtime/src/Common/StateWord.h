// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_STATE_WORD_H
#define MRT_STATE_WORD_H
#include <atomic>
#include <type_traits>

#include "Base/Log.h"
#include "Common/TypeDef.h"

namespace MapleRuntime {
class TypeInfo;
class ObjectState {
public:
    // Forwarding: object is now being exclusively forwarded by some gc thread or mutator.
    // Forwarded: object is forwarded, thus has 2 versions: from-version and to-verison.
    enum ObjectStateCode : uint8_t {
        NORMAL = 0, // default state, not-forwarded.
        LOCKED = 1,

        // states for object from-version, which is now being forwarded/locked by gc/mutator.
        FORWARDING = 2,

        // states for object from-version which has been forwarded.
        FORWARDED = 3,

        // Local objects do not participate in GC forwarding or object locking.
        LOCAL_OBJECT = 4,
    };

    static constexpr size_t STATE_BIT_COUNT = 3;

    // constructure and destructure
    ObjectState() { SetStateBits(0); }
    ObjectState(uint16_t word) : stateBits(word) {}
    ObjectState(ObjectStateCode state) : stateBits(static_cast<uint16_t>(state)) {}
    ObjectState(const ObjectState& state) = default;

    ~ObjectState() = default;

    ObjectState AtomicGetObjectState() const { return ObjectState(AtomicGetStateBits()); }

    ObjectStateCode GetStateCode() const { return static_cast<ObjectStateCode>(stateCode); }
    void SetStateCode(ObjectStateCode state) { stateCode = static_cast<uint16_t>(state); }

    bool IsForwardableState() const { return GetStateCode() == NORMAL; }
    bool IsLockedState() const { return GetStateCode() == LOCKED; }
    bool IsForwardedState() const { return GetStateCode() == FORWARDED; }
    bool IsLocalObject() const { return GetStateCode() == LOCAL_OBJECT; }

    union {
        struct {
            // The low bits encode the object state.
            uint16_t stateCode : STATE_BIT_COUNT;
        };
        uint16_t stateBits;
    };

    uint16_t GetStateBits() const { return stateBits; }
    uint16_t AtomicGetStateBits() const { return __atomic_load_n(&stateBits, __ATOMIC_ACQUIRE); }

    void SetStateBits(uint16_t newState) { stateBits = newState; }
    void AtomicSetStateBits(uint16_t newState) { __atomic_store_n(&stateBits, newState, __ATOMIC_RELEASE); }

    bool CompareExchangeStateBits(uint16_t expected, uint16_t newState)
    {
#if defined(__x86_64__)
        bool success =
            __atomic_compare_exchange_n(&stateBits, &expected, newState, true, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);
#else
        // due to "Spurious Failure" of compare_exchange_weak, compare_exchange_strong is chosen.
        bool success =
            __atomic_compare_exchange_n(&stateBits, &expected, newState, false, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE);
#endif
        return success;
    }
};

class StateWord {
public:
    static constexpr size_t ADDRESS_BIT_COUNT = 48;
    static constexpr uint64_t ADDRESS_ALIGN_MASK = 8 - 1;

    static constexpr size_t LOW_ADDRESS_BIT_COUNT = 32;
    static constexpr uint64_t LOW_ADDRESS_SHIFT = 0;
    static constexpr uint64_t LOW_ADDRESS_MASK = (1ull << LOW_ADDRESS_BIT_COUNT) - 1;

    static constexpr size_t HIGH_ADDRESS_BIT_COUNT = 16;
    static constexpr uint64_t HIGH_ADDRESS_SHIFT = 32;
    static constexpr uint64_t HIGH_ADDRESS_MASK = (1ull << HIGH_ADDRESS_BIT_COUNT) - 1;

    TypeInfo* GetTypeInfo() const
    {
#ifdef __arm__
        uint32_t address = this->typeInfo;
#else
        uintptr_t low = this->typeInfoLow32;
        uintptr_t high = this->typeInfoHigh16;
        uintptr_t address = (high << HIGH_ADDRESS_SHIFT) | low;
#endif
        return reinterpret_cast<TypeInfo*>(address);
    }

    void SetTypeInfo(TypeInfo* newTypeInfo)
    {
        uintptr_t address = reinterpret_cast<uintptr_t>(newTypeInfo);
#ifdef __arm__
        this->typeInfo = reinterpret_cast<uint32_t>(address);
#else
        this->typeInfoLow32 = (address >> LOW_ADDRESS_SHIFT) & LOW_ADDRESS_MASK;
        this->typeInfoHigh16 = (address >> HIGH_ADDRESS_SHIFT) & HIGH_ADDRESS_MASK;
#endif
    }

    void InitializeLocal(TypeInfo* newTypeInfo)
    {
        SetTypeInfo(newTypeInfo);
        SetStateCode(ObjectState::LOCAL_OBJECT);
    }

    bool IsValidStateWord() const { return GetTypeInfo() != nullptr; }
    StateWord GetStateWord() const
    {
#ifdef __arm__
        return StateWord(typeInfo, GetObjectState());
#else
        return StateWord(typeInfoLow32, typeInfoHigh16, GetObjectState());
#endif
    }

    ObjectState GetObjectState() const { return objectState.AtomicGetObjectState(); }
    ObjectState::ObjectStateCode GetStateCode() const { return objectState.GetStateCode(); }

    bool IsForwardableState() const { return objectState.IsForwardableState(); }
    bool IsForwardedState() const { return objectState.IsForwardedState(); }
    bool IsLocalObject() const { return objectState.IsLocalObject(); }

    bool IsLockedWord() const { return objectState.IsLockedState(); }
    void SetStateCode(ObjectState::ObjectStateCode state) { objectState.SetStateCode(state); }

    bool TryLockStateWord(const ObjectState current)
    {
        if (current.IsLockedState()) {
            return false;
        }
        return objectState.CompareExchangeStateBits(current.GetStateBits(), ObjectState::LOCKED);
    }

    void UnlockStateWord(const ObjectState newState)
    {
        do {
            ObjectState current = objectState.AtomicGetObjectState();
            CHECK(current.IsLockedState());
            if (objectState.CompareExchangeStateBits(current.GetStateBits(), newState.GetStateBits())) {
                return;
            }
        } while (true);
    }

private:
#ifdef __arm__
    explicit StateWord(uint32_t typeInfoValue, ObjectState state)
        : typeInfo(typeInfoValue), padding(0), objectState(state)
    {
        (void)padding;
    }
#else
    explicit StateWord(uint32_t low32, uint16_t hi16, ObjectState state)
        : typeInfoLow32(low32), typeInfoHigh16(hi16), objectState(state)
    {}
#endif

    // for type info.
#ifdef __arm__
    uint32_t typeInfo;
    uint16_t padding;
    ObjectState objectState;
#else
    uint32_t typeInfoLow32;
    uint16_t typeInfoHigh16;
    ObjectState objectState;
#endif
};

static_assert(std::is_trivially_copyable<StateWord>::value, "StateWord must support whole-header initialization");
static_assert(sizeof(StateWord) == sizeof(uint64_t), "illegal size of StateBits");
} // namespace MapleRuntime
#endif // MRT_STATE_WORD_H
