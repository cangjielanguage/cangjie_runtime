// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_STACK_MAP_TABLE_H
#define MRT_STACK_MAP_TABLE_H

#include "StackMap/StackMapTypeDef.h"
#include "CangjieRuntime.h"
#include "Base/LogFile.h"

namespace MapleRuntime {
using VarValue = U32;
using BitLen = U32;
using VarPair = std::pair<VarValue, BitLen>;
using DerivedPtrPair = std::pair<U32, U32>;

class BitsManager {
public:
    BitsManager() = default;
    BitsManager(U8* ptr, U32 pos) : addr(ptr), bitPos(pos) {}
    BitsManager(const BitsManager& other) : addr(other.addr), bitPos(other.bitPos) {}
    BitsManager& operator=(const BitsManager& other)
    {
        if (this == &other) {
            return *this;
        }
        addr = other.addr;
        bitPos = other.bitPos;
        return *this;
    }
    BitsManager(BitsManager&& other) : addr(other.addr), bitPos(other.bitPos)
    {
        other.addr = nullptr;
        other.bitPos = 0;
    }
    BitsManager& operator=(BitsManager&& other)
    {
        if (this == &other) {
            return *this;
        }
        addr = other.addr;
        bitPos = other.bitPos;
        other.addr = nullptr;
        other.bitPos = 0;
        return *this;
    }
    ~BitsManager() { addr = nullptr; }

    U32 GetBits(U32 bitLen) const
    {
        U32 bitsMask = static_cast<U32>((1ULL << bitLen) - 1);
        return ((ConnectBytesToU64() >> bitPos) & bitsMask);
    }
    ATTR_NO_INLINE BitsManager GetNext(U32 bitsLen) const
    {
        U32 addrStep = bitsLen >> BITS_SHIFT_PER_BYTE;
        constexpr U32 bitsMask = (1 << BITS_SHIFT_PER_BYTE) - 1;
        U32 bitPosStep = bitsLen & bitsMask;
        U8* nextAddr = addr + addrStep;
        U32 nextBitPos = bitPos + bitPosStep;
        if (nextBitPos >= BITS_NUM_PER_BYTE) {
            ++nextAddr;
            nextBitPos -= BITS_NUM_PER_BYTE;
        }
        return BitsManager(nextAddr, nextBitPos);
    }

private:
    // we don't use reinterpret_cast<U64*> because of the effect of big-endien.
    U64 ConnectBytesToU64() const
    {
        constexpr U32 len = sizeof(U32) / sizeof(U8) + 1;
        U64 value = 0;
        U32 shiftSteps = 0;
        for (U32 i = 0; i < len; ++i, shiftSteps += BITS_NUM_PER_BYTE) {
            value |= static_cast<U64>(addr[i]) << shiftSteps;
        }
        return value;
    }
    static constexpr U32 BITS_NUM_PER_BYTE = 8;
    static constexpr U32 BITS_SHIFT_PER_BYTE = 3;
    static constexpr U32 BITS_NUM_HALF_BYTE = BITS_NUM_PER_BYTE >> 1;
    static constexpr U16 HALF_BYTE_MASK = (1 << BITS_NUM_HALF_BYTE) - 1;
    U8* addr{ nullptr };
    U32 bitPos{ 0 };
};

// VarInt has two section
// |   tag  |         payload               |
// | 4 bits | 8/16/24/32 bits depends on tag|
// e.g  varInt = 0b0101 GetValue() = {3, 4}
// varInt = 0b1100 00010001 GetValue() = {0x11, 12}
// varInt = 0b1101 00010001 00010001 GetValue() = {0x1111, 20}
// varInt = 0b1110 00010001 00010001 00010001 GetValue() = {0x111111, 28}
// varInt = 0b1111 00010001 00010001 00010001 00010001 GetValue() = {0x11111111, 36}
class VarInt {
public:
    enum TagType : U8 {
        MAX_VALID_VALUE = 11, // When the tag is no greater than 11, the valid value is tag.
        VAR_VALUE8 = 12,      // When the tag is equal to 12, the valid value is 8 bits of varValue.
        VAR_VALUE16 = 13,     // When the tag is equal to 13, the valid value is 16 bits of varValue.
        VAR_VALUE24 = 14,     // When the tag is equal to 14, the valid value is 24 bits of varValue.
        VAR_VALUE32 = 15,     // When the tag is equal to 15, the valid value is 32 bits of varValue.
    };
    enum BitsLen : U32 {
        TAG_LEN = 4,
        FIRST_STEP_VAR_BITS = 8,
        SECOND_STEP_VAR_BITS = 16,
        THIRD_STEP_VAR_BITS = 24,
        FORTH_STEP_VAR_BITS = 32,
    };
    VarInt() = delete;
    VarInt(U8* ptr, U32 pos) : bits(ptr, pos) {}
    explicit VarInt(const BitsManager& bitsManager) : bits(bitsManager) {}
    explicit VarInt(BitsManager&& bitsManager) : bits(bitsManager) {}
    ~VarInt() = default;
    ATTR_NO_INLINE VarPair GetValue() const
    {
        uint8_t tag = static_cast<uint8_t>(bits.GetBits(TAG_LEN));
        if (tag <= MAX_VALID_VALUE) {
            return std::make_pair(static_cast<VarValue>(tag), TAG_LEN);
        }
        if (tag == VAR_VALUE8) {
            VarValue value = GetPayload(FIRST_STEP_VAR_BITS);
            return std::make_pair(value, TAG_LEN + FIRST_STEP_VAR_BITS);
        }
        if (tag == VAR_VALUE16) {
            VarValue value = GetPayload(SECOND_STEP_VAR_BITS);
            return std::make_pair(value, TAG_LEN + SECOND_STEP_VAR_BITS);
        }
        if (tag == VAR_VALUE24) {
            uint32_t value = GetPayload(THIRD_STEP_VAR_BITS);
            return std::make_pair(value, TAG_LEN + THIRD_STEP_VAR_BITS);
        }
        VarValue value = GetPayload(FORTH_STEP_VAR_BITS);
        return std::make_pair(value, TAG_LEN + FORTH_STEP_VAR_BITS);
    }

private:
    VarValue GetPayload(BitsLen bitsLen) const
    {
        BitsManager payload = bits.GetNext(TAG_LEN);
        return payload.GetBits(bitsLen);
    }
    BitsManager bits;
};

class TableAPI {
public:
    TableAPI() = default;
    TableAPI(U8* tableAddrStart, U32 tableBitStart) : tableBits(tableAddrStart, tableBitStart) {}
    explicit TableAPI(const BitsManager& bits) : tableBits(bits) {}
    explicit TableAPI(BitsManager&& bits) : tableBits(bits) {}
    virtual ~TableAPI() = default;
    BitsManager GetNextTable() const { return nextTable; };

protected:
    ATTR_NO_INLINE BitsManager ResolveHeader(U32 headerInfo[], U32 size)
    {
        BitsManager cur(tableBits);
        for (U32 i = 0; i < size; ++i) {
            VarInt varInt(cur);
            VarPair headerPair = varInt.GetValue();
            VarValue value = headerPair.first;
            headerInfo[i] = value;
            cur = cur.GetNext(headerPair.second);
        }
        return cur;
    }
    BitsManager tableBits;
    U32 rowBitsLen{ 0 };
    BitsManager data;
    BitsManager nextTable;
};

struct PrologueRegisterClosure {
    PrologueRegisterClosure() = default;
    PrologueRegisterClosure(PrologueRegisterClosure&& other)
        : calleeSaved(std::move(other.calleeSaved)), offset(std::move(other.offset)) {}
    PrologueRegisterClosure& operator=(PrologueRegisterClosure&& other)
    {
        if (this == &other) {
            return *this;
        }
        calleeSaved = std::move(other.calleeSaved);
        offset = std::move(other.offset);
        return *this;
    }

    enum class Type : U32 { CALLEE_REGISTER, OFFSET };
    ~PrologueRegisterClosure() = default;
    void RecordCalleeSaved(RegSlotsMap& regSlotsMap, uintptr_t base) const
    {
        size_t size = calleeSaved.size();
        for (size_t i = 0; i < size; ++i) {
            regSlotsMap.Insert(
                Register::ResolveCalleeSaved(calleeSaved[i]),
                reinterpret_cast<SlotAddress>(static_cast<intptr_t>(base) + (static_cast<intptr_t>(offset[i] * COEF))));
        }
    }

#if defined(__APPLE__) && defined(__aarch64__)
    constexpr static intptr_t COEF = -8;
#elif defined(__aarch64__)
    constexpr static intptr_t COEF = 8;
#elif defined(__arm__)
    constexpr static intptr_t COEF = -4;
#else
    constexpr static intptr_t COEF = -8;
#endif
    std::vector<U32> calleeSaved;
    std::vector<U32> offset;
};

using PrologueVisitor = std::function<void(PrologueRegisterClosure::Type, U32)>;
// Prologue Table : 1 columns
// | VarInt   |  the first row is a varInt that records the bit map of callee-saved register.
// | VarInt[] |  the next n rows is a varInt matrix that records the offset of the slot saving callee-saved register.
class PrologueVarInt {
public:
    PrologueVarInt(U8* ptr, U32 bitPos, const PrologueVisitor& visitor) : prologue(ptr, bitPos)
    {
        ResolvePrologue(visitor);
    }
    explicit PrologueVarInt(const BitsManager& bitsManager, const PrologueVisitor& visitor) : prologue(bitsManager)
    {
        ResolvePrologue(visitor);
    }

    ~PrologueVarInt() = default;

    BitsManager GetNextTable() const { return nextTable; }

private:
    void ResolvePrologue(const PrologueVisitor& visitor)
    {
        VarInt regBits(prologue);
        VarPair varPair = regBits.GetValue();
        U32 bitMap = varPair.first;
        U32 bitLen = varPair.second;
        U32 size = 0;
        for (U32 i = 0; bitMap != 0; ++i, bitMap >>= 1) {
            constexpr U32 bitMask = 0x1;
            if ((bitMap & bitMask) == 0) {
                continue;
            }
            if (LIKELY(visitor != nullptr)) {
                visitor(PrologueRegisterClosure::Type::CALLEE_REGISTER, i);
            }
            ++size;
        }
        BitsManager offsetBitManager = prologue.GetNext(bitLen);
        for (U32 i = 0; i < size; ++i) {
            VarInt offsetVarInt(offsetBitManager);
            VarPair offsetPair = offsetVarInt.GetValue();
            if (LIKELY(visitor != nullptr)) {
                visitor(PrologueRegisterClosure::Type::OFFSET, offsetPair.first);
            }
            offsetBitManager = offsetBitManager.GetNext(offsetPair.second);
        }
        nextTable = offsetBitManager;
    }
    BitsManager prologue;
    BitsManager nextTable;
};

// Register Table Header : 2 columns
// | VarInt num |  VarInt bitLength |
// |     @1     |        @2         |
// ----------------------------------
// Register Table : 1 columns
// | num * bitMap |
// bitMap represents the active registers, and it is encoded in different ways according to the hardware platform.
// Get the encoding ways in stackMap_aarch64.h and stackMap_X86.h
// num is from @1, the bit length of bitMap is from @2
class RegTable : public TableAPI {
public:
    RegTable() = default;
    RegTable(U8* tableAddrStart, U32 tableBitStart) : TableAPI(tableAddrStart, tableBitStart) { Init(); }
    explicit RegTable(const BitsManager& bits) : TableAPI(bits) { Init(); }
    explicit RegTable(BitsManager&& bits) : TableAPI(bits) { Init(); }
    ~RegTable() = default;

    U32 GetActiveRegBits(U32 row) const { return data.GetNext(row * rowBitsLen).GetBits(headerInfo[BITS_LEN]); }

private:
    void Init()
    {
        data = ResolveHeader(headerInfo, HEADER_COL_NUM);
        rowBitsLen = headerInfo[BITS_LEN];
        nextTable = data.GetNext(rowBitsLen * headerInfo[RECORD_NUM]);
    }
    enum HeaderColTag {
        RECORD_NUM = 0,
        BITS_LEN,
        HEADER_COL_NUM,
    };
    U32 headerInfo[HEADER_COL_NUM]{ 0 };
};

// Slot Table Header : 3 columns
// | VarInt num | VarInt bitLength | VarInt bitLength |
// |      @1    |        @2        |        @3        |
// ----------------------------------------------------
// Slot Table : 2 columns
// | baseOffset | bitmap |
// baseOffset is compressed signed integer which represents the basic offset of all slots with respect to stack bottom.
// bitmap represents the slot in stack
// e.g. baseOffset = 0b10111000 (-72) bitmap = 0b11
// then we resolve them as :
// ((-72) + 0) * 8 = -576, ((-72) + 1) * 8 = -568
class SlotTable : public TableAPI {
public:
    SlotTable() = default;
    SlotTable(U8* tableAddrStart, U32 tableBitStart, U32 format) : TableAPI(tableAddrStart, tableBitStart),
        slotFormat(format) { Init(); }
    SlotTable(const BitsManager& bits, U32 format) : TableAPI(bits), slotFormat(format) { Init(); }
    SlotTable(BitsManager&& bits, U32 format) : TableAPI(bits), slotFormat(format) { Init(); }
    ~SlotTable() = default;

    SlotBias GetBaseOffset(U32 row) const
    {
        U32 unsignedValue = data.GetNext(row * rowBitsLen).GetBits(headerInfo[BASE_OFF_BITS_LEN]);
        switch (headerInfo[BASE_OFF_BITS_LEN]) {
            case SIGNED8:
                return static_cast<SlotBias>(static_cast<I8>(unsignedValue));
            case SIGNED16:
                return static_cast<SlotBias>(static_cast<I16>(unsignedValue));
            case SIGNED32:
                return static_cast<SlotBias>(static_cast<I32>(unsignedValue));
            default:
                LOG(RTLOG_FATAL, "wrong base offset bits length: %u at row: %u", headerInfo[BASE_OFF_BITS_LEN], row);
                return static_cast<SlotBias>(unsignedValue);
        }
    }
    std::vector<SlotBits> GetSlotBitMap(U32 row) const
    {
        if (slotFormat != PURE_COMPRESSED_STACKMAP) {
            return GetWAHSlotBitMap(row);
        }
        // regular bits length : 32 bits
        constexpr U32 regularSlotBitsLen = 32;
        constexpr U32 regularShiftBits = 5;
        constexpr U32 bitMask = (1 << regularShiftBits) - 1;
        U32 bitMapLen = headerInfo[BIT_MAP_BITS_LEN];
        U32 size = bitMapLen >> regularShiftBits;
        U32 resident = bitMapLen & bitMask;
        if (resident != 0) {
            size++;
        }
        std::vector<SlotBits> buffer(size);
        BitsManager bitMapBits = data.GetNext(row * rowBitsLen + headerInfo[BASE_OFF_BITS_LEN]);
        for (U32 i = 0; i < size - 1; ++i, bitMapBits = bitMapBits.GetNext(regularSlotBitsLen)) {
            buffer[i] = bitMapBits.GetBits(regularSlotBitsLen);
        }
        if (resident == 0) {
            buffer[size - 1] = bitMapBits.GetBits(regularSlotBitsLen);
        } else {
            buffer[size - 1] = bitMapBits.GetBits(resident);
        }
        size_t validSize = size;
        for (U32 i = size - 1; i != 0; i--) {
            if (buffer[i] != 0) {
                break;
            }
            validSize--;
        }
        buffer.resize(validSize);
        return buffer;
    }
    U32 slotFormat;
private:
    void Init()
    {
        data = ResolveHeader(headerInfo, HEADER_COL_NUM);
        rowBitsLen = headerInfo[BASE_OFF_BITS_LEN] + headerInfo[BIT_MAP_BITS_LEN];
        nextTable = data.GetNext(headerInfo[RECORD_NUM] * rowBitsLen);
    }
    // WAHSlotBit is decompressed into a vector which value has 3 types:
    // | bit31 | bit30 | bit29...bit0 |
    // |   0   |   1   |    varInt    |  ====> (varInt * 31) bits of 1
    // |   0   |   0   |    varInt    |  ====> (varInt * 31) bits of 0
    // |   1   |       RawData        |  ====> 31 valid bits data.
    std::vector<SlotBits> GetWAHSlotBitMap(U32 row) const
    {
        U32 remainLen = headerInfo[BIT_MAP_BITS_LEN];
        BitsManager bitMapBits = data.GetNext(row * rowBitsLen + headerInfo[BASE_OFF_BITS_LEN]);
        std::vector<SlotBits> result;
        U32 isPureVal;
        U32 isAllRef;
        VarValue cnts;
        constexpr U32 PureValWidth = 31;
        constexpr U32 PureValMask = 1 << PureValWidth;
        constexpr U32 CompressTagBitPos = 30;
        while (remainLen != 0) {
            isPureVal = bitMapBits.GetBits(1);
            bitMapBits = bitMapBits.GetNext(1);
            remainLen--;
            if (isPureVal) {
                U32 pureValBits = std::min(remainLen, PureValWidth);
                result.push_back(bitMapBits.GetBits(pureValBits) | PureValMask);
                bitMapBits = bitMapBits.GetNext(pureValBits);
                remainLen -= pureValBits;
            } else {
                // bits are paddings when remain bits are less than shortest varInt bits + 1
                if (remainLen < VarInt::TAG_LEN + 1) {
                    break;
                }
                isAllRef = bitMapBits.GetBits(1);
                bitMapBits = bitMapBits.GetNext(1);
                remainLen--;

                VarInt varInt(bitMapBits);
                VarPair varIntPair = varInt.GetValue();
                cnts = varIntPair.first;
                bitMapBits = bitMapBits.GetNext(varIntPair.second);
                remainLen -= varIntPair.second;
                // Cnts == 0 means we are in paddings
                if (cnts == 0) {
                    break;
                }
                result.push_back(cnts |= (isAllRef << CompressTagBitPos));
            }
        }
        return result;
    }
    enum HeaderColTag {
        RECORD_NUM = 0,
        BASE_OFF_BITS_LEN,
        BIT_MAP_BITS_LEN,
        HEADER_COL_NUM,
    };

    // because the base offset is a signed integar, so the bits length must be 8 or 16 or 32.
    enum BaseOffsetType {
        SIGNED8 = 8,
        SIGNED16 = 16,
        SIGNED32 = 32,
    };
    U32 headerInfo[HEADER_COL_NUM]{ 0 };
};

// Line Number Table Header : 2 columns
// | VarInt num |  VarInt bitLength |
// |     @1     |        @2         |
// ----------------------------------
// Line Number Table : 1 columns
// | num * lineNumber |
// lineNumber is compressed bits that represent the line number of the file
// num is from @1, the bit length of lineNumber is from @2
class LineNumTable : public TableAPI {
public:
    LineNumTable() = default;
    LineNumTable(U8* tableAddrStart, U32 tableBitStart) : TableAPI(tableAddrStart, tableBitStart) { Init(); }
    explicit LineNumTable(const BitsManager& bits) : TableAPI(bits) { Init(); }
    explicit LineNumTable(BitsManager&& bits) : TableAPI(bits) { Init(); }
    ~LineNumTable() = default;
    U32 GetLineNumber(U32 row) const { return data.GetNext(row * rowBitsLen).GetBits(headerInfo[LINE_NUM_BITS_LEN]); }

private:
    void Init()
    {
        data = ResolveHeader(headerInfo, HEADER_COL_NUM);
        rowBitsLen = headerInfo[LINE_NUM_BITS_LEN];
        nextTable = data.GetNext(rowBitsLen * headerInfo[RECORD_NUM]);
    }
    enum HeaderTag {
        RECORD_NUM = 0,
        LINE_NUM_BITS_LEN,
        HEADER_COL_NUM,
    };
    U32 headerInfo[HEADER_COL_NUM]{ 0 };
};

struct IdxSet {
    IdxSet() : regIdx(0), slotIdx(0), lineNumIdx(0), derivedPtrIdx(0), stackRegIdx(0), stackSlotIdx(0) {}
    IdxSet(U32 reg, U32 slot, U32 lineNum, U32 derivePtr, U32 stackReg, U32 stackSlot)
        : regIdx(reg), slotIdx(slot), lineNumIdx(lineNum), derivedPtrIdx(derivePtr),
          stackRegIdx(stackReg), stackSlotIdx(stackSlot) {}
    IdxSet(U32 reg, U32 slot, U32 lineNum, U32 derivePtr)
        : regIdx(reg), slotIdx(slot), lineNumIdx(lineNum), derivedPtrIdx(derivePtr),
          stackRegIdx(0), stackSlotIdx(0) {}
    U32 regIdx;
    U32 slotIdx;
    U32 lineNumIdx;
    U32 derivedPtrIdx;
    U32 stackRegIdx;
    U32 stackSlotIdx;
};

class StackMapTable : public TableAPI {
public:
    StackMapTable(U8* tableAddrStart, U32 tableBitStart) : TableAPI(tableAddrStart, tableBitStart) { Init(); }
    explicit StackMapTable(const BitsManager& bits) : TableAPI(bits) { Init(); }
    explicit StackMapTable(BitsManager&& bits) : TableAPI(bits) { Init(); }
    ~StackMapTable() = default;
    IdxSet GetIdxSet(Uptr startPC, Uptr framePC) const
    {
        U32 recordNum = headerInfo[RECORD_NUM];
        if (recordNum == 0) {
            return IdxSet();
        }
        // 32 bits is enough.
        U32 targetPCOff = static_cast<U32>(framePC - startPC);
        U32 left = 0;
        U32 right = recordNum - 1;
        U32 leftPCOff = PCAt(left);
        if (leftPCOff == targetPCOff) {
            if (CangjieRuntime::stackGrowConfig == StackGrowConfig::STACK_GROW_ON) {
                return IdxSet(RegIdxAt(left), SlotIdxAt(left), LineNumIdxAt(left),
                    DerivePtrIdxAt(left), StackRegIdxAt(left), StackSlotIdxAt(left));
            } else {
                return IdxSet(RegIdxAt(left), SlotIdxAt(left), LineNumIdxAt(left), DerivePtrIdxAt(left));
            }
        }
        U32 rightPCOff = PCAt(right);
        if (rightPCOff == targetPCOff) {
            if (CangjieRuntime::stackGrowConfig == StackGrowConfig::STACK_GROW_ON) {
                return IdxSet(RegIdxAt(right), SlotIdxAt(right), LineNumIdxAt(right),
                    DerivePtrIdxAt(right), StackRegIdxAt(right), StackSlotIdxAt(right));
            } else {
                return IdxSet(RegIdxAt(right), SlotIdxAt(right), LineNumIdxAt(right), DerivePtrIdxAt(right));
            }
        }
        if (targetPCOff < leftPCOff || targetPCOff > rightPCOff) {
            DLOG(ENUM, "stack map is empty in this frame");
            return IdxSet();
        }
        while (left <= right) {
            // left + right won't exceed the limit of 32 bits.
            U32 mid = (left + right) >> 1;
            U32 midPCOff = PCAt(mid);
            if (midPCOff == targetPCOff) {
                if (CangjieRuntime::stackGrowConfig == StackGrowConfig::STACK_GROW_ON) {
                    return IdxSet(RegIdxAt(mid), SlotIdxAt(mid), LineNumIdxAt(mid),
                        DerivePtrIdxAt(mid), StackRegIdxAt(mid), StackSlotIdxAt(mid));
                } else {
                    return IdxSet(RegIdxAt(mid), SlotIdxAt(mid), LineNumIdxAt(mid), DerivePtrIdxAt(mid));
                }
            } else if (midPCOff < targetPCOff) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return IdxSet();
    }

    U32 GetRegBitsLen() const { return headerInfo[REG_BITS_LEN]; }
    U32 GetSlotBitsLen() const { return headerInfo[SLOT_BITS_LEN]; }

private:
    void Init()
    {
        if (CangjieRuntime::stackGrowConfig == StackGrowConfig::STACK_GROW_ON) {
            data = ResolveHeader(headerInfo, HEADER_COL_NUM).GetNext(headerInfo[PADDING_BITS_LEN]);
            rowBitsLen = PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN] +
                headerInfo[LINE_NUM_BITS_LEN] + headerInfo[DERIVE_PTR_BITS_LEN] +
                headerInfo[STACK_REG_BITS_LEN] + headerInfo[STACK_SLOT_BITS_LEN];
            nextTable = data.GetNext(rowBitsLen * headerInfo[RECORD_NUM]);
        } else {
            data = ResolveHeader(headerInfo, HEADER_COL_NUM - STACK_ITEM_NUM).GetNext(headerInfo[PADDING_BITS_LEN -
                                                                                                 STACK_ITEM_NUM]);
            rowBitsLen = PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN] +
                headerInfo[LINE_NUM_BITS_LEN] + headerInfo[DERIVE_PTR_BITS_LEN];
            nextTable = data.GetNext(rowBitsLen * headerInfo[RECORD_NUM]);
        }
    }
    U32 PCAt(U32 row) const
    {
        auto bitsManager = data.GetNext(row * rowBitsLen);
        return bitsManager.GetBits(PC_OFF_BITS);
    }
    U32 RegIdxAt(U32 row) const
    {
        auto bitsManager = data.GetNext(row * rowBitsLen + PC_OFF_BITS);
        return bitsManager.GetBits(headerInfo[REG_BITS_LEN]);
    }
    U32 SlotIdxAt(U32 row) const
    {
        auto bitsManager = data.GetNext(row * rowBitsLen + PC_OFF_BITS + headerInfo[REG_BITS_LEN]);
        return bitsManager.GetBits(headerInfo[SLOT_BITS_LEN]);
    }
    U32 LineNumIdxAt(U32 row) const
    {
        U32 skipBitsLen = row * rowBitsLen + PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN];
        auto bitsManager = data.GetNext(skipBitsLen);
        return bitsManager.GetBits(headerInfo[LINE_NUM_BITS_LEN]);
    }
    U32 DerivePtrIdxAt(U32 row) const
    {
        U32 skipBitsLen = row * rowBitsLen + PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN] +
            headerInfo[LINE_NUM_BITS_LEN];
        auto bitsManager = data.GetNext(skipBitsLen);
        return bitsManager.GetBits(headerInfo[DERIVE_PTR_BITS_LEN]);
    }
    U32 StackRegIdxAt(U32 row) const
    {
        U32 skipBitsLen = row * rowBitsLen + PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN] +
            headerInfo[LINE_NUM_BITS_LEN] + headerInfo[DERIVE_PTR_BITS_LEN];
        auto bitsManager = data.GetNext(skipBitsLen);
        return bitsManager.GetBits(headerInfo[STACK_REG_BITS_LEN]);
    }
    U32 StackSlotIdxAt(U32 row) const
    {
        U32 skipBitsLen = row * rowBitsLen + PC_OFF_BITS + headerInfo[REG_BITS_LEN] + headerInfo[SLOT_BITS_LEN] +
            headerInfo[LINE_NUM_BITS_LEN] + headerInfo[DERIVE_PTR_BITS_LEN] + headerInfo[STACK_REG_BITS_LEN];
        auto bitsManager = data.GetNext(skipBitsLen);
        return bitsManager.GetBits(headerInfo[STACK_SLOT_BITS_LEN]);
    }
    enum HeaderColTag : U32 {
        RECORD_NUM = 0,
        REG_BITS_LEN,
        SLOT_BITS_LEN,
        LINE_NUM_BITS_LEN,
        DERIVE_PTR_BITS_LEN,
        STACK_REG_BITS_LEN,
        STACK_SLOT_BITS_LEN,
        PADDING_BITS_LEN,
        HEADER_COL_NUM,
    };
    static constexpr U32 STACK_ITEM_NUM = 2;
    static constexpr U32 PC_OFF_BITS = 32;
    U32 headerInfo[HEADER_COL_NUM]{ 0 };
};

// DerivedPtrTable doesn't have header info, the bits length is the same as stack map table.
class DerivedPtrTable : public TableAPI {
public:
    DerivedPtrTable() = default;
    explicit DerivedPtrTable(const BitsManager& bits, U32 regBits, U32 slotBits)
        : TableAPI(bits), regBitsLen(regBits), slotBitsLen(slotBits) { Init(); }
    explicit DerivedPtrTable(BitsManager&& bits, U32 regBits, U32 slotBits)
        : TableAPI(bits), regBitsLen(regBits), slotBitsLen(slotBits) { Init(); }
    ~DerivedPtrTable() = default;
    DerivedPtrPair GetDerivePair(U32 row) const
    {
        BitsManager rowBits = data.GetNext(row * rowBitsLen);
        return std::make_pair(rowBits.GetBits(regBitsLen), rowBits.GetNext(regBitsLen).GetBits(slotBitsLen));
    }

private:
    void Init()
    {
        data = ResolveHeader(headerInfo, HEADER_COL_NUM);
        rowBitsLen = regBitsLen + slotBitsLen;
    }
    enum HeaderTag {
        RECORD_NUM = 0,
        HEADER_COL_NUM,
    };
    U32 headerInfo[HEADER_COL_NUM];
    U32 regBitsLen = 0;
    U32 slotBitsLen = 0;
};
} // namespace MapleRuntime
#endif // ~MRT_STACK_MAP_TABLE_H
