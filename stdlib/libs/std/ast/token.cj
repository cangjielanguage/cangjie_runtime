/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

public struct Token <: ToBytes {
    /**
         Fields
     */
    public let kind: TokenKind
    public let value: String
    public let pos: Position
    public var delimiterNum: UInt16 = 1 // Delimiter r'#' number for raw string.
    private var isSingleQuote_ = false
    public mut prop isSingleQuote: Bool {
        get() {
            isSingleQuote_
        }
        set(v) {
            if (kind == TokenKind.SINGLE_QUOTED_STRING_LITERAL && v == false) {
                throw IllegalArgumentException(
                "TokenKind '${getTokenKindValue(kind)}' does not match 'isSingleQuote'.")
            }
            isSingleQuote_ = v
        }
    }

    /**
         Constructors
     */
    // Create an token with default value.
    public init() {
        kind = TokenKind.ILLEGAL
        value = ""
        pos = Position()
    }

    // Create a new token without value, position from enumerated type token.
    public init(kind: TokenKind) {
        this.kind = kind
        value = getTokenLiteral(kind)
        pos = Position()
        if (kind == SINGLE_QUOTED_STRING_LITERAL) {
            this.isSingleQuote_ = true
        }
    }

    // Create a new token with empty position from token kind and token value.
    public init(kind: TokenKind, value: String) {
        // Forbid illegal init such as Token(TokenKind.ADD, "foo")
        if (!checkKindValue(kind, value)) {
            throw IllegalArgumentException(
                "TokenKind '${getTokenKindValue(kind)}' does not match value '${value}'.")
        }
        this.kind = kind
        this.value = value
        pos = Position()
        if (kind == SINGLE_QUOTED_STRING_LITERAL) {
            this.isSingleQuote_ = true
        }
    }

    // Create a new token from token kind, value, fileID, line, column.
    init(k: TokenKind, v: String, f: UInt32, l: Int32, c: Int32, isSingleQuote!: Bool = false) {
        kind = k
        value = v
        pos = Position(f, l, c)
        this.isSingleQuote_ = isSingleQuote
    }

    public func addPosition(fileID: UInt32, line: Int32, column: Int32): Token {
        return Token(this.kind, this.value, fileID, line, column, isSingleQuote: this.isSingleQuote_)
    }

    func addPosition(position: ASTFormat_Position) {
        return Token(this.kind, this.value, position.fileId, position.line, position.column, isSingleQuote: this.isSingleQuote_)
    }

    func addPosition(position: Position) {
        return Token(this.kind, this.value, position.fileID, position.line, position.column, isSingleQuote: this.isSingleQuote_)
    }

    // Returns true if and only if the two token's kind id, value, position are identical.
    // XXX: Bound check.
    public operator func ==(r: Token): Bool {
        return this.kind == r.kind && this.value == r.value && this.pos == r.pos
    }

    // Returns true if and only if the two token's kind id, value, position are not identical.
    public operator func !=(r: Token): Bool {
        return !(this == r)
    }

    // Token + Tokens => Tokens
    public operator func +(r: Tokens): Tokens {
        var l: Tokens = Tokens(Array<Token>(1, repeat: this))
        return l + r
    }

    // Token + Token => Tokens
    public operator func +(r: Token): Tokens {
        var l: Tokens = Tokens(Array<Token>(1, repeat: this))
        return l + r
    }

    // Print the information of this token.
    public func dump(): Unit {
        let kv: String = getTokenKindValue(kind)
        let id: UInt16 = getTokenID(kind)
        print("description: ${kv}, token_id: ${id}, ")
        if (this.kind == TokenKind.NL) {
            print("token_literal_value: \\n, ")
        } else {
            print("token_literal_value: ${value}, ")
        }
        pos.dump()
    }

    public func toBytes(): Array<UInt8> {
        var kindId: UInt16 = getTokenID(this.kind)
        var b1: Array<UInt8> = castUInt16ToBytes(kindId)
        var b2: Array<UInt8> = castStringToBytes(this.value)
        var b12: Array<UInt8> = concatBytes(b1, b2)
        var b3: Array<UInt8> = this.pos.toBytes()
        var b23: Array<UInt8> = concatBytes(b12, b3)
        let isSingle: UInt16 = if (this.isSingleQuote) {
            1
        } else {
            0
        }
        var b4: Array<UInt8> = castUInt16ToBytes(isSingle)
        if (getTokenKind(kindId) == TokenKind.MULTILINE_RAW_STRING) {
            var b5: Array<UInt8> = castUInt16ToBytes(this.delimiterNum)
            var b45: Array<UInt8> = concatBytes(b4, b5)
            return concatBytes(b23, b45)
        }
        return concatBytes(b23, b4)
    }

    func toBytes(arr: Array<UInt8>, start1: Int64) {
        var start = start1
        let kindId: UInt16 = getTokenID(this.kind)
        start = castUInt16ToBytes(arr, start, kindId)
        start = castStringToBytes(arr, start, this.value)
        start = this.pos.toBytes(arr, start)
        let isSingle: UInt16 = if (this.isSingleQuote) {
            1
        } else {
            0
        }
        start = castUInt16ToBytes(arr, start, isSingle)
        if (getTokenKind(kindId) == TokenKind.MULTILINE_RAW_STRING) {
            start = castUInt16ToBytes(arr, start, this.delimiterNum)
        }
        return start
    }

    func getSize() {
        let kindId: UInt16 = getTokenID(this.kind)
        let size_kind = 2
        let size_len = 4
        let size_value = this.value.size
        let size_pos = this.pos.getSize()
        var size = size_kind + size_len + size_value + size_pos
        let size_is_single = 2
        size += size_is_single
        if (getTokenKind(kindId) == TokenKind.MULTILINE_RAW_STRING) {
            let size_delimiterNum = 2
            size += size_delimiterNum
        }
        return size
    }
}

func refreshPos(token: Token, f: UInt32, l: Int32, c: Int32): Token {
    var tk: Token
    if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
        let pos = getMacroPosition(macroObjPtr)
        tk = Token(token.kind, token.value, pos[0], pos[1], pos[2])
        tk.delimiterNum = token.delimiterNum
        tk.isSingleQuote = token.isSingleQuote
        return tk
    }
    tk = Token(token.kind, token.value, f, l, c)
    tk.delimiterNum = token.delimiterNum
    tk.isSingleQuote = token.isSingleQuote
    return tk
}
