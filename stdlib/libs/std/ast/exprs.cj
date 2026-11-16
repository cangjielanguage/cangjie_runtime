/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

import std.collection.ArrayList

public open class Expr <: Node {
    init() {
        super()
    }
    public open func toTokens(): Tokens {
        Tokens()
    }
    public open func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
    }

    protected open func dump(_: UInt16): String {
        ""
    }
    protected open func precedence(): Int64 {
        return 0x7FFF_FFFF_FFFF_FFFF
    }
}

public class Block <: Expr {
    init(lCurl: Token, nodes: ArrayList<Node>, rCurl: Token, unsafe_: Token) {
        super()
        this.lCurl_ = lCurl
        this.nodes_ = nodes
        this.rCurl_ = rCurl
        this.unsafe_ = unsafe_
    }
    public init() {
        super()
    }
    private var lCurl_: Token = Token()
    private var nodes_: ArrayList<Node> = ArrayList<Node>()
    private var rCurl_: Token = Token()
    private var unsafe_: Token = Token()
    public mut prop lBrace: Token {
        get() {
            lCurl_
        }
        set(v) {
            checkTokenType(v, LCURL)
            lCurl_ = v
        }
    }
    public mut prop nodes: ArrayList<Node> {
        get() {
            nodes_
        }
        set(v) {
            nodes_ = v
        }
    }
    public mut prop rBrace: Token {
        get() {
            rCurl_
        }
        set(v) {
            checkTokenType(v, RCURL)
            rCurl_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        if (isValidToken(unsafe_)) {
            ret.append(unsafe_)
        }
        if (isValidToken(lCurl_)) {
            ret.append(lCurl_).append(Token(NL).addPosition(lCurl_.pos.fileID, lCurl_.pos.line, lCurl_.pos.column + 1))
        }
        for (n in nodes_) {
            ret.append(n.toTokens())
            if (ret[ret.size - 1].kind != NL) {
                ret.append(Token(NL).addPosition(n.endPos))
            }
        }
        if (isValidToken(rCurl_)) {
            var rCurlPos = rCurl_.pos
            // if last pos of ret equal to rcurl.pos, refresh rcurl.pos, for lexer will delete rcurl when see pos equal to node.endPos
            if (ret[ret.size - 1].pos == rCurlPos) {
                rCurlPos = Position(rCurlPos.fileID, rCurlPos.line, rCurlPos.column + 1)
            }
            ret.append((rCurl_).addPosition(rCurlPos))
            ret.append(Token(NL).addPosition(rCurlPos.fileID, rCurlPos.line, rCurlPos.column + 1))
        }
        return ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (node in nodes_) {
            node.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "Block {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        for (i in 0..nodes_.size) {
            ret += getIndent(currentIndent) + "-nodes: ${i}, "
            ret += nodes_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class BinaryExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as BinaryExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.lExpr_ = v.lExpr_
                    this.op_ = v.op_
                    this.rExpr_ = v.rExpr_
                case None => throw ASTException("Cannot construct the 'BinaryExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'BinaryExpr' node.")
        }
    }
    init(leftExpr: Expr, op: Token, rightExpr: Expr) {
        super()
        this.lExpr_ = leftExpr
        this.op_ = op
        this.rExpr_ = rightExpr
    }
    public init() {
        super()
    }
    private var lExpr_: Expr = Expr()
    private var rExpr_: Expr = Expr()
    private var op_: Token = Token()
    public mut prop leftExpr: Expr {
        get() {
            lExpr_
        }
        set(v) {
            lExpr_ = v
        }
    }
    public mut prop op: Token {
        get() {
            op_
        }
        set(v) {
            op_ = v
        }
    }
    public mut prop rightExpr: Expr {
        get() {
            rExpr_
        }
        set(v) {
            rExpr_ = v
        }
    }

    protected func precedence(): Int64 {
        return op_.kind.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        if (op_.kind == EXP || op_.kind == COALESCING || op_.kind.isNonAssociative()) {
            addParen(ret, lExpr_, this)
        } else {
            addParen(ret, lExpr_, this, addOnEqualPred: false)
        }
        if (ret.size > 1 && (ret[ret.size - 1].kind == TokenKind.NL)) {
            ret = ret.remove(ret.size - 1)
        }
        ret.append(op_)
        if (op_.kind == EXP || op_.kind == COALESCING) {
            addParen(ret, rExpr_, this, addOnEqualPred: false)
        } else {
            addParen(ret, rExpr_, this)
        }
        return ret
    }
    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        lExpr_.traverse(v)
        rExpr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "BinaryExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-leftExpr: "
        ret += lExpr_.dump(currentIndent)
        ret += getTokenIndent("-op", op_, currentIndent)
        ret += getIndent(currentIndent) + "-rightExpr: "
        ret += rExpr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class UnaryExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as UnaryExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.expr_ = v.expr_
                    this.op_ = v.op_
                case None => throw ASTException("Cannot construct the 'UnaryExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'UnaryExpr' node.")
        }
    }
    init(op: Token, expr: Expr) {
        super()
        this.expr_ = expr
        this.op_ = op
    }
    public init() {
        super()
    }
    private var expr_: Expr = Expr()
    private var op_: Token = Token()
    public mut prop op: Token {
        get() {
            op_
        }
        set(v) {
            op_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    protected func precedence(): Int64 {
        return NOT.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        ret.append(op_)
        addParen(ret, expr_, this, addOnEqualPred: false)
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "UnaryExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-op", op_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class IsExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as IsExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.expr_ = v.expr_
                    this.op_ = v.op_
                    this.shiftType_ = v.shiftType
                case None => throw ASTException("Cannot construct the 'IsExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'IsExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(expr: Expr, op: Token, shiftType: TypeNode) {
        super()
        this.expr_ = expr
        this.op_ = op
        this.shiftType_ = shiftType
    }
    private var expr_: Expr = Expr()
    private var op_: Token = Token(TokenKind.IS)
    private var shiftType_: TypeNode = TypeNode()
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop keyword: Token {
        get() {
            op_
        }
        set(v) {
            checkTokenType(v, IS)
            op_ = v
        }
    }
    public mut prop shiftType: TypeNode {
        get() {
            shiftType_
        }
        set(v) {
            shiftType_ = v
        }
    }
    protected func precedence(): Int64 {
        return op_.kind.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        addParen(ret, expr_, this)
        ret.append(op_).append(shiftType_.toTokens())
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        shiftType_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "IsExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getTokenIndent("-keyword", op_, currentIndent)
        ret += getIndent(currentIndent) + "-shiftType: "
        ret += shiftType_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class AsExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as AsExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.expr_ = v.expr_
                    this.op_ = v.op_
                    this.shiftType_ = v.shiftType
                case None => throw ASTException("Cannot construct the 'AsExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'AsExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(expr: Expr, op: Token, ty: TypeNode) {
        super()
        this.expr_ = expr
        this.op_ = op
        this.shiftType_ = ty
    }
    private var expr_: Expr = Expr()
    private var op_: Token = Token(TokenKind.AS)
    private var shiftType_: TypeNode = TypeNode()
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop keyword: Token {
        get() {
            op_
        }
        set(v) {
            checkTokenType(v, AS)
            op_ = v
        }
    }
    public mut prop shiftType: TypeNode {
        get() {
            shiftType_
        }
        set(v) {
            shiftType_ = v
        }
    }
    protected func precedence(): Int64 {
        return op_.kind.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        addParen(ret, expr_, this)
        ret.append(op_).append(shiftType_.toTokens())
        ret
    }
    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        shiftType_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "AsExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getTokenIndent("-keyword", op_, currentIndent)
        ret += getIndent(currentIndent) + "-shiftType: "
        ret += shiftType_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ParenExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ParenExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.lParen_ = v.lParen_
                    this.expr_ = v.expr_
                    this.rParen_ = v.rParen_
                case None => throw ASTException("Cannot construct the 'ParenExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ParenExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(lParen: Token, expr: Expr, rParen: Token) {
        super()
        this.lParen_ = lParen
        this.expr_ = expr
        this.rParen_ = rParen
    }
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var expr_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop parenthesizedExpr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }

    public func toTokens(): Tokens {
        Tokens().append(lParen_).append(expr_).append(rParen_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ParenExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class LitConstExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as LitConstExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.literal_ = v.literal_
                case None => throw ASTException("Cannot construct the 'LitConstExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'LitConstExpr' node.")
        }
    }
    init(literal: Token) {
        super()
        this.literal_ = literal
    }
    public init() {
        super()
    }
    private var literal_: Token = Token()
    public mut prop literal: Token {
        get() {
            literal_
        }
        set(v) {
            literal_ = v
        }
    }
    public func toTokens(): Tokens {
        let pos = literal_.pos
        if (literal_.kind == TokenKind.UNIT_LITERAL) {
            return Tokens()
                .append(Token(TokenKind.LPAREN).addPosition(pos))
                .append(Token(TokenKind.RPAREN).addPosition(pos.fileID, pos.line, pos.column + 1))
        }
        if ((literal_.kind == TokenKind.INTEGER_LITERAL || literal_.kind == TokenKind.FLOAT_LITERAL) &&
            literal_.value.size > 1 && literal_.value[0] == 45) { // 45 is r'-'
            return Tokens()
                .append(Token(TokenKind.SUB).addPosition(pos))
                .append(Token(literal_.kind, literal_.value[1..]).addPosition(pos.fileID, pos.line, pos.column + 1))
        }
        return Tokens().append(literal_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "LitConstExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-literal", literal_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

// Appends "<...>" type arguments and synthesizes missing comma tokens between adjacent type nodes.
private func appendExprTypeArguments(ret: Tokens, lAngle: Token, typeArgs: ArrayList<TypeNode>, commas: Tokens,
    rAngle: Token): Tokens {
    if (!typeArgs.isEmpty()) {
        ret.append(lAngle)
        for (i in 0..typeArgs.size) {
            ret.append(typeArgs[i].toTokens())
            if (i != typeArgs.size - 1) {
                let comma = commas.tryGet(i) ?? Token(TokenKind.COMMA)
                ret.append(comma)
            }
        }
        ret.append(rAngle)
    }
    ret
}

public class RefExpr <: Expr {
    init(identifier: Token, lAngle: Token, typeArgs: ArrayList<TypeNode>, commas: Tokens, rAngle: Token) {
        identifier_ = identifier
        lAngle_ = lAngle
        typeArgs_ = typeArgs
        commas_ = commas
        rAngle_ = rAngle
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as RefExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.identifier_ = v.identifier_
                    this.lAngle_ = checkValid(v.lAngle_)
                    this.typeArgs_ = v.typeArgs_
                    this.commas_ = v.commas_
                    this.rAngle_ = checkValid(v.rAngle_)
                case None => throw ASTException("Cannot construct the 'RefExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'RefExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var identifier_: Token = Token()
    private var lAngle_: Token = Token(TokenKind.LT)
    private var typeArgs_: ArrayList<TypeNode> = ArrayList<TypeNode>()
    private var commas_: Tokens = Tokens()
    private var rAngle_: Token = Token(TokenKind.GT)
    public mut prop identifier: Token {
        get() {
            identifier_
        }
        set(v) {
            identifier_ = v
        }
    }
    public mut prop lAngle: Token {
        get() {
            lAngle_
        }
        set(v) {
            checkTokenType(v, LT)
            lAngle_ = v
        }
    }
    public mut prop typeArguments: ArrayList<TypeNode> {
        get() {
            typeArgs_
        }
        set(v) {
            typeArgs_ = v
        }
    }
    public mut prop commas: Tokens {
        get() {
            commas_
        }
        set(v) {
            checkTokensType(v, COMMA)
            commas_ = v
        }
    }
    public mut prop rAngle: Token {
        get() {
            rAngle_
        }
        set(v) {
            checkTokenType(v, GT)
            rAngle_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(identifier_)
        appendExprTypeArguments(ret, lAngle_, typeArgs_, commas, rAngle_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (arg in typeArgs_) {
            arg.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "RefExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-identifier", identifier_, currentIndent)
        for (i in 0..typeArgs_.size) {
            ret += getIndent(currentIndent) + "typeArguments: ${i}, "
            ret += typeArgs_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ReturnExpr <: Expr {
    init(keyWord: Token, expr: Option<Expr>) {
        keyWord_ = keyWord
        expr_ = expr
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ReturnExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.expr_ = v.expr_
                case None => throw ASTException("Cannot construct the 'ReturnExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ReturnExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var keyWord_: Token = Token(TokenKind.RETURN)
    private var expr_: Option<Expr> = None<Expr>
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, RETURN)
            keyWord_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            match (expr_) {
                case Some(v) => v
                case None => throw ASTException("'ReturnExpr' has no return value.")
            }
        }
        set(v) {
            expr_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(keyWord_)
        match (expr_) {
            case Some(v) => ret.append(v.toTokens())
            case None => ()
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        match (expr_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ReturnExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        match (expr_) {
            case Some(v) =>
                ret += getIndent(currentIndent) + "-expr: "
                ret += v.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ThrowExpr <: Expr {
    init(keyWord: Token, expr: Expr) {
        keyWord_ = keyWord
        expr_ = expr
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ThrowExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.expr_ = v.expr_
                case None => throw ASTException("Cannot construct the 'ThrowExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ThrowExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var keyWord_: Token = Token(TokenKind.THROW)
    private var expr_: Expr = Expr()
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, THROW)
            keyWord_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(keyWord_).append(expr_.toTokens())
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ThrowExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class PerformExpr <: Expr {
    init(keyWord: Token, expr: Expr) {
        keyWord_ = keyWord
        expr_ = expr
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as PerformExpr) {
                case Some(v) =>
                    this.keyWord_ = v.keyWord_
                    this.expr_ = v.expr_
                case None => throw ASTException("Cannot construct the 'PerformExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'PerformExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var keyWord_: Token = Token(TokenKind.PERFORM)
    private var expr_: Expr = Expr()
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, PERFORM)
            keyWord_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(keyWord_).append(expr_.toTokens())
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "PerformExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ResumeExpr <: Expr {
    init(resume_: Token, with_: Option<Token>, withExpr_: Option<Expr>, throwing_: Option<Token>, throwingExpr_: Option<Expr>) {
        this.resume_ = resume_
        this.with_ = with_
        this.withExpr_ = withExpr_
        this.throwing_ = throwing_
        this.throwingExpr_ = throwingExpr_
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ResumeExpr) {
                case Some(v) =>
                    this.resume_ = v.resume_
                    this.with_ = v.with_
                    this.withExpr_ = v.withExpr_
                    this.throwing_ = v.throwing_
                    this.throwingExpr_ = v.throwingExpr_
                case None => throw ASTException("Cannot construct the 'ResumeExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ResumeExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var resume_: Token = Token(TokenKind.RESUME)
    private var with_: Option<Token> = None<Token>
    private var withExpr_: Option<Expr> = None<Expr>
    private var throwing_: Option<Token> = None<Token>
    private var throwingExpr_: Option<Expr> = None<Expr>
    public mut prop keywordR : Token {
        get() {
            resume_
        }
        set(v) {
            checkTokenType(v, RESUME)
            resume_ = v
        }
    }
    public mut prop keywordW : Option<Token> {
        get() {
            with_
        }
        set(v) {
            match (v) {
                case Some(token) => checkTokenType(token, WITH)
                case None => ()
            }
            with_ = v
        }
    }
    public mut prop withExpr: Option<Expr> {
        get() {
            withExpr_
        }
        set(v) {
            withExpr_ = v
        }
    }
    public mut prop keywordT : Option<Token> {
        get() {
            throwing_
        }
        set(v) {
            match (v) {
                case Some(token) => checkTokenType(token, THROWING)
                case None => ()
            }
            throwing_ = v
        }
    }
    public mut prop throwingExpr: Option<Expr> {
        get() {
            throwingExpr_
        }
        set(v) {
            throwingExpr_ = v
        }
    }
    public func toTokens(): Tokens {
        var tokens = Tokens().append(resume_)
        match (with_) {
            case Some(v) => tokens.append(v)
            case None => ()
        }
        match (withExpr_) {
            case Some(v) => tokens.append(v.toTokens())
            case None => ()
        }
        match (throwing_) {
            case Some(v) => tokens.append(v)
            case None => ()
        }
        match (throwingExpr_) {
            case Some(v) => tokens.append(v.toTokens())
            case None => ()
        }
        tokens
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        match(withExpr_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        match(throwingExpr_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ResumeExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keywordR", resume_, currentIndent)
        match(with_) {
            case Some(v) => ret += getTokenIndent("-keywordW", v, currentIndent)
            case None => ()
        }
        match(withExpr_) {
            case Some(v) =>
                ret += getIndent(currentIndent) + "-withExpr: "
                ret += v.dump(currentIndent)
            case None => ()
        }
        match(throwing_) {
            case Some(v) => ret += getTokenIndent("-keywordT", v, currentIndent)
            case None => ()
        }
        match(throwingExpr_) {
            case Some(v) =>
                ret += getIndent(currentIndent) + "-throwingExpr: "
                ret += v.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class AssignExpr <: Expr {
    init(lexpr: Expr, assign: Token, rexpr: Expr) {
        lexpr_ = lexpr
        assign_ = assign
        rexpr_ = rexpr
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as AssignExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.assign_ = v.assign_
                    this.lexpr_ = v.lexpr_
                    this.rexpr_ = v.rexpr_
                case None => throw ASTException("Cannot construct the 'AssignExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'AssignExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var assign_: Token = Token(TokenKind.ASSIGN)
    private var lexpr_: Expr = Expr()
    private var rexpr_: Expr = Expr()
    public mut prop assign: Token {
        get() {
            assign_
        }
        set(v) {
            checkTokenTypeAssign(v)
            assign_ = v
        }
    }
    public mut prop leftExpr: Expr {
        get() {
            lexpr_
        }
        set(v) {
            lexpr_ = v
        }
    }
    public mut prop rightExpr: Expr {
        get() {
            rexpr_
        }
        set(v) {
            rexpr_ = v
        }
    }

    protected func precedence(): Int64 {
        return assign_.kind.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret = Tokens()
        addParen(ret, lexpr_, this)
        ret.append(assign_)
        addParen(ret, rexpr_, this)
        return ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        lexpr_.traverse(v)
        rexpr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "AssignExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-leftExpr: "
        ret += lexpr_.dump(currentIndent)
        ret += getTokenIndent("-assign", assign_, currentIndent)
        ret += getIndent(currentIndent) + "-rightExpr: "
        ret += rexpr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class CallExpr <: Expr {
    init(callSuffix: Expr, lParen: Token, args: ArrayList<Argument>, rParen: Token) {
        super()
        this.postfixExpr_ = callSuffix
        this.lParen_ = lParen
        this.args_ = args
        this.rParen_ = rParen
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as CallExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.postfixExpr_ = v.postfixExpr_
                    this.lParen_ = v.lParen_
                    this.args_ = v.args_
                    this.rParen_ = v.rParen_
                    this.modal_ = v.modal_
                case None => throw ASTException("Cannot construct the 'CallExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'CallExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var postfixExpr_: Expr = Expr()
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var args_: ArrayList<Argument> = ArrayList<Argument>()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var modal_: ModalInfo = ModalInfo()
    public mut prop modal: ModalInfo {
        get() { modal_ }
        set(v) { modal_ = v }
    }
    public mut prop callFunc: Expr {
        get() {
            postfixExpr_
        }
        set(v) {
            postfixExpr_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop arguments: ArrayList<Argument> {
        get() {
            args_
        }
        set(v) {
            args_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }

    protected func precedence(): Int64 {
        return rParen_.kind.opPrecedence()
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        if (postfixExpr_ is OptionalExpr) {
            ret.append(postfixExpr_)
        } else {
            addParen(ret, postfixExpr_, this, addOnEqualPred: false)
        }
        if (ret.size > 1 && (ret[ret.size - 1].kind == TokenKind.NL)) {
            ret = ret.remove(ret.size - 1)
        }
        ret.append(lParen_)
        ret.append(arguments.toTokens())
        ret.append(rParen_)
        ret.append(modal_.toTokens())
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        postfixExpr_.traverse(v)
        for (arg in args_) {
            arg.traverse(v)
        }
        modal_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "CallExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-callFunc: "
        ret += postfixExpr_.dump(currentIndent)
        for (i in 0..args_.size) {
            ret += getIndent(currentIndent) + "-arguments: ${i}, "
            ret += args_[i].dump(currentIndent)
        }
        ret += modal_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class MemberAccess <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as MemberAccess) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.postfixExpr_ = v.postfixExpr_
                    this.dot_ = v.dot_
                    this.ident_ = v.ident_
                    this.lAngle_ = checkValid(v.lAngle_)
                    this.typeArgs_ = v.typeArgs_
                    this.commas_ = v.commas_
                    this.rAngle_ = checkValid(v.rAngle_)
                case None => throw ASTException("Cannot construct the 'MemberAccess' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'MemberAccess' node.")
        }
    }
    public init() {
        super()
    }
    init(postfixExpr: Expr, dot: Token, ident: Token, lAngle: Token, typeArgs: ArrayList<TypeNode>, commas: Tokens,
        rAngle: Token) {
        postfixExpr_ = postfixExpr
        dot_ = dot
        ident_ = ident
        lAngle_ = lAngle
        typeArgs_ = typeArgs
        commas_ = commas
        rAngle_ = rAngle
    }
    private var postfixExpr_: Expr = Expr()
    private var dot_: Token = Token(TokenKind.DOT)
    private var ident_: Token = Token()
    private var lAngle_: Token = Token(TokenKind.LT)
    private var typeArgs_: ArrayList<TypeNode> = ArrayList<TypeNode>()
    private var commas_: Tokens = Tokens()
    private var rAngle_: Token = Token(TokenKind.GT)

    public mut prop baseExpr: Expr {
        get() {
            postfixExpr_
        }
        set(v) {
            postfixExpr_ = v
        }
    }
    public mut prop dot: Token {
        get() {
            dot_
        }
        set(v) {
            checkTokenType(v, DOT)
            dot_ = v
        }
    }
    public mut prop field: Token {
        get() {
            ident_
        }
        set(v) {
            ident_ = v
        }
    }
    public mut prop lAngle: Token {
        get() {
            lAngle_
        }
        set(v) {
            checkTokenType(v, LT)
            lAngle_ = v
        }
    }
    public mut prop typeArguments: ArrayList<TypeNode> {
        get() {
            typeArgs_
        }
        set(v) {
            typeArgs_ = v
        }
    }
    public mut prop commas: Tokens {
        get() {
            commas_
        }
        set(v) {
            checkTokensType(v, COMMA)
            commas_ = v
        }
    }
    public mut prop rAngle: Token {
        get() {
            rAngle_
        }
        set(v) {
            checkTokenType(v, GT)
            rAngle_ = v
        }
    }

    protected func precedence(): Int64 {
        return dot_.kind.opPrecedence()
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        if (postfixExpr_ is OptionalExpr) {
            ret.append(postfixExpr_)
        } else {
            addParen(ret, postfixExpr_, this, addOnEqualPred: false)
        }
        ret.append(dot_).append(ident_)
        appendExprTypeArguments(ret, lAngle_, typeArgs_, commas, rAngle_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        postfixExpr_.traverse(v)
        for (arg in typeArgs_) {
            arg.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "MemberAccess {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-baseExpr: "
        ret += postfixExpr_.dump(currentIndent)
        ret += getTokenIndent("-dot", dot_, currentIndent)
        ret += getTokenIndent("-field", ident_, currentIndent)
        for (i in 0..typeArgs_.size) {
            ret += getIndent(currentIndent) + "-typeArguments: ${i}, "
            ret += typeArgs_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class IfExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as IfExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.if_ = v.if_
                    this.lParen_ = v.lParen_
                    this.cond_ = v.cond_
                    this.rParen_ = v.rParen_
                    this.else_ = checkValid(v.else_)
                    this.ifBlock_ = v.ifBlock_
                    this.elseExpr_ = v.elseExpr_
                case None => throw ASTException("Cannot construct the 'IfExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'IfExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(keyWords: Token, lParen: Token, cond: Expr, rParen: Token, ifBlock: Block, elseTk: Token,
        elseExpr: Option<Expr>) {
        if_ = keyWords
        lParen_ = lParen
        cond_ = cond
        rParen_ = rParen
        else_ = elseTk
        ifBlock_ = ifBlock
        elseExpr_ = elseExpr
    }
    private var if_: Token = Token()
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var cond_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var else_: Token = Token()
    private var ifBlock_: Block = Block()
    private var elseExpr_: Option<Expr> = None<Expr>
    public mut prop keywordI: Token {
        get() {
            if_
        }
        set(v) {
            checkTokenType(v, IF)
            if_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop condition: Expr {
        get() {
            cond_
        }
        set(v) {
            cond_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop ifBlock: Block {
        get() {
            ifBlock_
        }
        set(v) {
            ifBlock_ = v
        }
    }
    public mut prop keywordE: Token {
        get() {
            else_
        }
        set(v) {
            checkTokenType(v, ELSE)
            else_ = v
        }
    }
    public mut prop elseExpr: Expr {
        get() {
            match (elseExpr_) {
                case Some(v) => v
                case None => throw ASTException("'IfExpr' has no else branch.")
            }
        }
        set(v) {
            elseExpr_ = Some(v)
        }
    }
    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
            .append(if_)
            .append(lParen_)
            .append(cond_.toTokens())
            .append(rParen_)
            .append(ifBlock_.toTokens())
        match (elseExpr_) {
            case Some(v) => ret.append(else_).append(v.toTokens())
            case None => ()
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        cond_.traverse(v)
        ifBlock_.traverse(v)
        match (elseExpr_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "IfExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keywordI", if_, currentIndent)
        ret += getIndent(currentIndent) + "-condition: "
        ret += cond_.dump(currentIndent)
        ret += getIndent(currentIndent) + "-ifBlock: "
        ret += ifBlock_.dump(currentIndent)
        match (elseExpr_) {
            case Some(v) =>
                ret += getTokenIndent("-keywordE", else_, currentIndent)
                ret += getIndent(currentIndent) + "-elseExpr: "
                ret += v.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class LetPatternExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as LetPatternExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.key_ = v.key_
                    this.pattern_ = v.pattern_
                    this.backArrow_ = v.backArrow_
                    this.expr_ = v.expr_
                case None => throw ASTException("Cannot construct the 'LetPatternExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'LetPatternExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(key: Token, pattern: Pattern, backArrow: Token, expr: Expr) {
        key_ = key
        pattern_ = pattern
        backArrow_ = backArrow
        expr_ = expr
    }
    private var key_: Token = Token(TokenKind.LET)
    private var pattern_: Pattern = Pattern()
    private var backArrow_: Token = Token(TokenKind.BACKARROW)
    private var expr_: Expr = Expr()
    public mut prop keyword: Token {
        get() {
            key_
        }
        set(v) {
            checkTokenType(v, LET)
            key_ = v
        }
    }
    public mut prop pattern: Pattern {
        get() {
            pattern_
        }
        set(v) {
            pattern_ = v
        }
    }
    public mut prop backArrow: Token {
        get() {
            backArrow_
        }
        set(v) {
            checkTokenType(v, BACKARROW)
            backArrow_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(key_).append(pattern_).append(backArrow_).append(expr_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        pattern_.traverse(v)
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "LetPatternExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", key_, currentIndent)
        ret += getIndent(currentIndent) + "-pattern: "
        ret += pattern_.dump(currentIndent)
        ret += getTokenIndent("-backArrow", backArrow_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class MatchExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as MatchExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.lParen_ = checkValid(v.lParen_)
                    this.selector_ = v.selector_
                    this.rParen_ = checkValid(v.rParen_)
                    this.lCurl_ = v.lCurl_
                    this.matchCases_ = v.matchCases_
                    this.rCurl_ = v.rCurl_
                case None => throw ASTException("Cannot construct the 'MatchExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'MatchExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(keyWord: Token, lParen: Token, selector: Option<Expr>, rParen: Token, lCurl: Token,
        matchCases: ArrayList<MatchCase>, rCurl: Token) {
        keyWord_ = keyWord
        lParen_ = lParen
        selector_ = selector
        rParen_ = rParen
        lCurl_ = lCurl
        matchCases_ = matchCases
        rCurl_ = rCurl
    }
    private var keyWord_: Token = Token(TokenKind.MATCH)
    private var lParen_: Token = Token()
    private var selector_: Option<Expr> = None<Expr>
    private var rParen_: Token = Token()
    private var lCurl_: Token = Token(TokenKind.LCURL)
    private var matchCases_: ArrayList<MatchCase> = ArrayList<MatchCase>()
    private var rCurl_: Token = Token(TokenKind.RCURL)
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, MATCH)
            keyWord_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop selector: Expr {
        get() {
            match (selector_) {
                case Some(v) => v
                case None => throw ASTException("'MatchExpr' has no value to be matched.")
            }
        }
        set(v) {
            selector_ = Some(v)
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop lBrace: Token {
        get() {
            lCurl_
        }
        set(v) {
            checkTokenType(v, LCURL)
            lCurl_ = v
        }
    }
    public mut prop matchCases: ArrayList<MatchCase> {
        get() {
            matchCases_
        }
        set(v) {
            matchCases_ = v
        }
    }
    public mut prop rBrace: Token {
        get() {
            rCurl_
        }
        set(v) {
            checkTokenType(v, RCURL)
            rCurl_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(keyWord_)
        match (selector_) {
            case Some(v) => ret.append(lParen_).append(v).append(rParen_)
            case None => ()
        }
        ret
            .append(lCurl_)
            .append(Token(TokenKind.NL).addPosition(lCurl_.pos.fileID, lCurl_.pos.line, lCurl_.pos.column + 1))
        ret.append(matchCases_.toTokens()).append(rCurl_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        match (selector_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        for (mc in matchCases) {
            mc.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "MatchExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        match (selector_) {
            case Some(v) =>
                ret += getIndent(currentIndent) + "-selector: "
                ret += v.dump(currentIndent)
            case None => ()
        }
        for (i in 0..matchCases_.size) {
            ret += getIndent(currentIndent) + "-matchCases: ${i}, "
            ret += matchCases_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class WhileExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as WhileExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.lParen_ = v.lParen_
                    this.cond_ = v.cond_
                    this.rParen_ = v.rParen_
                    this.block_ = v.block_
                case None => throw ASTException("Cannot construct the 'WhileExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'WhileExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(keyWord: Token, lParen: Token, cond: Expr, rParen: Token, block: Block) {
        keyWord_ = keyWord
        lParen_ = lParen
        cond_ = cond
        rParen_ = rParen
        block_ = block
    }
    private var keyWord_: Token = Token(TokenKind.WHILE)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var cond_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var block_: Block = Block()
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, WHILE)
            keyWord_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop condition: Expr {
        get() {
            cond_
        }
        set(v) {
            cond_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop block: Block {
        get() {
            block_
        }
        set(v) {
            block_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        ret.append(keyWord_).append(lParen_).append(cond_.toTokens()).append(rParen_).append(block_.toTokens())
        return ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        cond_.traverse(v)
        block_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "WhileExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        ret += getIndent(currentIndent) + "-condition: "
        ret += cond_.dump(currentIndent)
        ret += getIndent(currentIndent) + "-block: "
        ret += block_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class DoWhileExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as DoWhileExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.do_ = v.do_
                    this.block_ = v.block_
                    this.while_ = v.while_
                    this.lParen_ = v.lParen_
                    this.cond_ = v.cond_
                    this.rParen_ = v.rParen_
                case None => throw ASTException("Cannot construct the 'DoWhileExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'DoWhileExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(do_: Token, block: Block, while_: Token, lParen: Token, cond: Expr, rParen: Token) {
        this.do_ = do_
        this.lParen_ = lParen
        this.cond_ = cond
        this.rParen_ = rParen
        this.block_ = block
        this.while_ = while_
    }
    private var do_: Token = Token(TokenKind.DO)
    private var block_: Block = Block()
    private var while_: Token = Token(TokenKind.WHILE)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var cond_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    public mut prop keywordD: Token {
        get() {
            do_
        }
        set(v) {
            checkTokenType(v, DO)
            do_ = v
        }
    }
    public mut prop block: Block {
        get() {
            block_
        }
        set(v) {
            block_ = v
        }
    }
    public mut prop keywordW: Token {
        get() {
            while_
        }
        set(v) {
            checkTokenType(v, WHILE)
            while_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop condition: Expr {
        get() {
            cond_
        }
        set(v) {
            cond_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        ret.append(do_).append(block_).append(while_).append(lParen_).append(cond_).append(rParen_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        block_.traverse(v)
        cond_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "DoWhileExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keywordD", do_, currentIndent)
        ret += getIndent(currentIndent) + "-block: "
        ret += block_.dump(currentIndent)
        ret += getTokenIndent("-keywordW", while_, currentIndent)
        ret += getIndent(currentIndent) + "-condition: "
        ret += cond_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class LambdaExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as LambdaExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.lCurl_ = v.lCurl_
                    this.funcParams_ = v.funcParams_
                    this.db_arrow_ = checkValid(v.db_arrow_)
                    this.nodes_ = v.nodes_
                    this.rCurl_ = v.rCurl_
                    this.mockSupported_ = v.mockSupported_
                case None => throw ASTException("Cannot construct the 'LambdaExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'LambdaExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(lCurl: Token, params: ArrayList<FuncParam>, db_arrow: Token, nodes: ArrayList<Node>, rCurl: Token,
        mockSupported: Bool) {
        lCurl_ = lCurl
        funcParams_ = params
        db_arrow_ = db_arrow
        nodes_ = nodes
        rCurl_ = rCurl
        mockSupported_ = mockSupported
    }
    private var lCurl_: Token = Token(TokenKind.LCURL)
    private var funcParams_: ArrayList<FuncParam> = ArrayList<FuncParam>()
    private var db_arrow_: Token = Token()
    private var nodes_: ArrayList<Node> = ArrayList<Node>()
    private var rCurl_: Token = Token(TokenKind.RCURL)
    private var mockSupported_: Bool = false
    public mut prop lBrace: Token {
        get() {
            lCurl_
        }
        set(v) {
            checkTokenType(v, LCURL)
            lCurl_ = v
        }
    }
    public mut prop funcParams: ArrayList<FuncParam> {
        get() {
            funcParams_
        }
        set(v) {
            funcParams_ = v
        }
    }
    public mut prop doubleArrow: Token {
        get() {
            db_arrow_
        }
        set(v) {
            checkTokenType(v, DOUBLE_ARROW)
            db_arrow_ = v
        }
    }
    public mut prop nodes: ArrayList<Node> {
        get() {
            nodes_
        }
        set(v) {
            nodes_ = v
        }
    }
    public mut prop rBrace: Token {
        get() {
            rCurl_
        }
        set(v) {
            checkTokenType(v, RCURL)
            rCurl_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret: Tokens = Tokens()
        if (mockSupported_) {
            ret.append(Token(TokenKind.AT))
            ret.append(Token(TokenKind.IDENTIFIER, "EnsurePreparedToMock"))
        }
        ret.append(lCurl_)
        ret.append(funcParams.toTokens())
        if (isValidPosition(db_arrow_)) {
            ret.append(db_arrow_)
            if (nodes_.size != 0) {
                let arrowPos = db_arrow_.pos
                ret.append(Token(NL).addPosition(arrowPos.fileID, arrowPos.line, arrowPos.column + 1))
            }
        }
        for (n in nodes_) {
            ret.append(n)
            if (ret[ret.size - 1].kind != NL) {
                ret.append(Token(NL).addPosition(n.endPos))
            }
        }
       ret.append(rCurl_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (param in funcParams_) {
            param.traverse(v)
        }
        for (node in nodes_) {
            node.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "LambdaExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        for (i in 0..funcParams_.size) {
            ret += getIndent(currentIndent) + "-funcParams: ${i}, "
            ret += funcParams_[i].dump(currentIndent)
        }
        ret += getTokenIndent("-doubleArrow", db_arrow_, currentIndent)
        for (i in 0..nodes_.size) {
            ret += getIndent(currentIndent) + "-nodes: ${i}, "
            ret += nodes_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class SpawnExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as SpawnExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.lParen_ = checkValid(v.lParen_)
                    this.context_ = v.context_
                    this.rParen_ = checkValid(v.rParen_)
                    this.task_ = v.task_
                case None => throw ASTException("Cannot construct the 'SpawnExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'SpawnExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(keyWord: Token, lParen: Token, context: Option<Expr>, rParen: Token, task: LambdaExpr) {
        keyWord_ = keyWord
        lParen_ = lParen
        context_ = context
        rParen_ = rParen
        task_ = task
    }
    private var keyWord_: Token = Token(TokenKind.SPAWN)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var context_: Option<Expr> = None<Expr>
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var task_: LambdaExpr = LambdaExpr()
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, SPAWN)
            keyWord_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop threadContext: Expr {
        get() {
            match (context_) {
                case Some(v) => v
                case None => throw ASTException("'SpawnExpr' has no thread context.")
            }
        }
        set(v) {
            context_ = Some(v)
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop lambdaExpr: LambdaExpr {
        get() {
            task_
        }
        set(v) {
            task_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(keyWord_)
        match (context_) {
            case Some(v) => ret.append(lParen_).append(v).append(rParen_)
            case None => ()
        }
        ret.append(task_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        match (context_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        lambdaExpr.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "SpawnExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyWord_, currentIndent)
        match (context_) {
            case Some(node) =>
                ret += getIndent(currentIndent) + "-threadContext: "
                ret += node.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(currentIndent) + "-lambdaExpr: "
        ret += task_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class SynchronizedExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as SynchronizedExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyWord_ = v.keyWord_
                    this.lParen_ = v.lParen_
                    this.mutex_ = v.mutex_
                    this.rParen_ = v.rParen_
                    this.block_ = v.block_
                case None => throw ASTException("Cannot construct the 'SynchronizedExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'SynchronizedExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(keyWord: Token, lParen: Token, mutex: Expr, rParen: Token, block: Block) {
        keyWord_ = keyWord
        lParen_ = lParen
        mutex_ = mutex
        rParen_ = rParen
        block_ = block
    }
    private var keyWord_: Token = Token(TokenKind.SYNCHRONIZED)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var mutex_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var block_: Block = Block()
    public mut prop keyword: Token {
        get() {
            keyWord_
        }
        set(v) {
            checkTokenType(v, SYNCHRONIZED)
            keyWord_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop structuredMutex: Expr {
        get() {
            mutex_
        }
        set(v) {
            mutex_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop block: Block {
        get() {
            block_
        }
        set(v) {
            block_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(keyWord_).append(lParen_).append(mutex_).append(rParen_).append(block_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        mutex_.traverse(v)
        block_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "SynchronizedExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-structuredMutex: "
        ret += mutex_.dump(currentIndent)
        ret += getIndent(currentIndent) + "-block: "
        ret += block_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class TrailingClosureExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as TrailingClosureExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.expr_ = v.expr_
                    this.lambda_ = v.lambda_
                case None => throw ASTException("Cannot construct the 'TrailingClosureExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'TrailingClosureExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(expr: Expr, lambda: LambdaExpr) {
        expr_ = expr
        lambda_ = lambda
    }
    private var expr_: Expr = Expr()
    private var lambda_: LambdaExpr = LambdaExpr()
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop lambdaExpr: LambdaExpr {
        get() {
            lambda_
        }
        set(v) {
            lambda_ = v
        }
    }

    public func toTokens(): Tokens {
        expr_.toTokens().append(lambda_.toTokens())
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        lambda_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "TrailingClosureExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(currentIndent) + "-lambdaExpr: "
        ret += lambda_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class TypeConvExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as TypeConvExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.type_ = v.type_
                    this.lParen_ = v.lParen_
                    this.expr_ = v.expr_
                    this.rParen_ = v.rParen_
                case None => throw ASTException("Cannot construct the 'TypeConvExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'TypeConvExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(ty: PrimitiveType, lParen: Token, expr: Expr, rParen: Token) {
        type_ = ty
        lParen_ = lParen
        expr_ = expr
        rParen_ = rParen
    }
    private var type_: PrimitiveType = PrimitiveType()
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var expr_: Expr = Expr()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    public mut prop targetType: PrimitiveType {
        get() {
            type_
        }
        set(v) {
            type_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(type_.toTokens()).append(lParen_).append(expr_.toTokens()).append(rParen_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        type_.traverse(v)
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "TypeConvExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-targetType: "
        ret += type_.dump(currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ForInExpr <: Expr {
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ForInExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.for_ = v.for_
                    this.lParen_ = v.lParen_
                    this.pattern_ = v.pattern_
                    this.in_ = v.in_
                    this.expr_ = v.expr_
                    this.where_ = checkValid(v.where_)
                    this.patternGuard_ = v.patternGuard_
                    this.rParen_ = v.rParen_
                    this.block_ = v.block_
                case None => throw ASTException("Cannot construct the 'ForInExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ForInExpr' node.")
        }
    }
    public init() {
        super()
    }
    init(for_: Token, lParen: Token, pattern: Pattern, in_: Token, expr: Expr, where_: Token,
        patternGuard: Option<Expr>, rParen: Token, block: Block) {
        this.for_ = for_
        this.lParen_ = lParen
        this.pattern_ = pattern
        this.in_ = in_
        this.expr_ = expr
        this.where_ = where_
        this.patternGuard_ = patternGuard
        this.rParen_ = rParen
        this.block_ = block
    }

    private var for_: Token = Token(TokenKind.FOR)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var pattern_: Pattern = Pattern()
    private var in_: Token = Token(TokenKind.IN)
    private var expr_: Expr = Expr()
    private var where_: Token = Token()
    private var patternGuard_: Option<Expr> = None<Expr>
    private var rParen_: Token = Token(TokenKind.RPAREN)
    private var block_: Block = Block()
    public mut prop keywordF: Token {
        get() {
            for_
        }
        set(v) {
            checkTokenType(v, FOR)
            for_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop pattern: Pattern {
        get() {
            pattern_
        }
        set(v) {
            pattern_ = v
        }
    }
    public mut prop keywordI: Token {
        get() {
            in_
        }
        set(v) {
            checkTokenType(v, IN)
            in_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    public mut prop keywordW: Token {
        get() {
            where_
        }
        set(v) {
            checkTokenType(v, WHERE)
            where_ = v
        }
    }
    public mut prop patternGuard: Expr {
        get() {
            match (patternGuard_) {
                case Some(v) => v
                case None => throw ASTException("'ForInExpr' has no pattern guard.")
            }
        }
        set(v) {
            patternGuard_ = Some(v)
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public mut prop block: Block {
        get() {
            block_
        }
        set(v) {
            block_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(for_).append(lParen_).append(pattern_).append(in_).append(expr_)
        match (patternGuard_) {
            case Some(v) => ret.append(where_).append(v)
            case None => ()
        }
        ret.append(rParen_).append(block_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        pattern_.traverse(v)
        expr_.traverse(v)
        match (patternGuard_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        block_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ForInExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keywordF", for_, currentIndent)
        ret += getIndent(currentIndent) + "-pattern: "
        ret += pattern_.dump(currentIndent)
        ret += getTokenIndent("-keywordI", in_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        match (patternGuard_) {
            case Some(node) =>
                ret += getTokenIndent("-keywordW", where_, currentIndent)
                ret += getIndent(currentIndent) + "-patternGuard: "
                ret += node.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(currentIndent) + "-block: "
        ret += block_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class PrimitiveTypeExpr <: Expr {
    public init(kind: Tokens) {
        if (kind.size == 0) {
            throw ASTException("Cannot construct the 'PrimitiveTypeExpr' node: input is empty.")
        }
        keyword_ = kind[0]
        checkPrimitiveType(keyword_)
        this.begin_ = keyword_.pos
        this.end_ = Position(begin_.fileID, begin_.line, begin_.column + Int32(keyword_.value.size))
    }
    public init() {
    }
    init(kind: Token) {
        keyword_ = kind
    }
    private var keyword_: Token = Token()
    private var modal_: ModalInfo = ModalInfo()
    public mut prop keyword: Token {
        get() {
            keyword_
        }
        set(v) {
            checkPrimitiveType(v)
            keyword_ = v
        }
    }
    public mut prop modal: ModalInfo {
        get() { modal_ }
        set(v) { modal_ = v }
    }
    public func toTokens(): Tokens {
        Tokens().append(keyword_).append(modal_.toTokens())
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        modal_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "PrimitiveTypeExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyword_, currentIndent)
        ret += modal_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ExclaveExpr <: Expr {
    init(`exclave`: Token, block: Block) {
        this.exclave_ = `exclave`
        this.block_ = block
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ExclaveExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.exclave_ = v.exclave_
                    this.block_ = v.block_
                case None => throw ASTException("Cannot construct the 'ExclaveExpr' node.")
            }
        } catch (_: ParseASTException) {
            throw ASTException("Cannot construct the 'ExclaveExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var exclave_: Token = Token(TokenKind.EXCLAVE)
    private var block_: Block = Block()
    public mut prop keyword: Token {
        get() {
            exclave_
        }
        set(v) {
            checkTokenType(v, EXCLAVE)
            exclave_ = v
        }
    }
    /** The executable Block enclosed by exclave, distinct from a declaration Body. */
    public mut prop block: Block {
        get() {
            block_
        }
        set(v) {
            block_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(exclave_).append(block_)
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        block_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ExclaveExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-exclave", exclave_, currentIndent)
        ret += getIndent(currentIndent) + "-block: "
        ret += block_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class ArrayLiteral <: Expr {
    init(lSquare: Token, elements: ArrayList<Expr>, commas: Tokens, rSquare: Token) {
        lSquare_ = lSquare
        elements_ = elements
        commas_ = commas
        rSquare_ = rSquare
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as ArrayLiteral) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.lSquare_ = v.lSquare_
                    this.elements_ = v.elements_
                    this.rSquare_ = v.rSquare_
                    this.commas_ = v.commas_
                case None => throw ASTException("Cannot construct the 'ArrayLiteral' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'ArrayLiteral' node.")
        }
    }
    public init() {
        super()
    }
    private var lSquare_: Token = Token(TokenKind.LSQUARE)
    private var elements_: ArrayList<Expr> = ArrayList<Expr>()
    private var commas_: Tokens = Tokens()
    private var rSquare_: Token = Token(TokenKind.RSQUARE)
    public mut prop lSquare: Token {
        get() {
            lSquare_
        }
        set(v) {
            checkTokenType(v, LSQUARE)
            lSquare_ = v
        }
    }
    public mut prop elements: ArrayList<Expr> {
        get() {
            elements_
        }
        set(v) {
            elements_ = v
        }
    }
    public mut prop rSquare: Token {
        get() {
            rSquare_
        }
        set(v) {
            checkTokenType(v, RSQUARE)
            rSquare_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(lSquare_)
        if (elements_.isEmpty()) {
            return ret.append(rSquare_)
        }
        if (commas_.size == 0) {
            commas_ = Tokens(Array(elements_.size - 1, repeat: Token(TokenKind.COMMA)))
        }
        for (i in 0..elements_.size - 1) {
            ret.append(elements_[i]).append(commas_[i])
        }
        ret.append(elements_[elements_.size - 1])
        ret.append(rSquare_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (elem in elements_) {
            elem.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "ArrayLiteral {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += dumpNodes("-elements", elements_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class TupleLiteral <: Expr {
    init(lParen: Token, elements: ArrayList<Expr>, commas: Tokens, rParen: Token) {
        lParen_ = lParen
        elements_ = elements
        rParen_ = rParen
        commas_ = commas
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as TupleLiteral) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.lParen_ = v.lParen_
                    this.elements_ = v.elements_
                    this.rParen_ = v.rParen_
                    this.commas_ = v.commas_
                case None => throw ASTException("Cannot construct the 'TupleLiteral' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'TupleLiteral' node.")
        }
    }
    public init() {
        super()
    }
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var elements_: ArrayList<Expr> = ArrayList<Expr>()
    private var commas_: Tokens = Tokens()
    private var rParen_: Token = Token(TokenKind.RPAREN)
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop elements: ArrayList<Expr> {
        get() {
            elements_
        }
        set(v) {
            elements_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(lParen_)
        if (elements_.isEmpty()) {
            return ret.append(rParen_)
        }
        if (commas_.size == 0) {
            commas_ = Tokens(Array(elements_.size - 1, repeat: Token(TokenKind.COMMA)))
        }
        for (i in 0..elements_.size - 1) {
            ret.append(elements_[i]).append(commas_[i])
        }
        ret.append(elements_[elements_.size - 1]).append(rParen_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (elem in elements_) {
            elem.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "TupleLiteral {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += dumpNodes("-elements", elements_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class RangeExpr <: Expr {
    init(start: Option<Expr>, rangeOp: Token, end: Option<Expr>, colon: Token, step: Option<Expr>) {
        start_ = start
        rangeOp_ = rangeOp
        endExpr_ = end
        colon_ = colon
        step_ = step
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as RangeExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.start_ = v.start_
                    this.rangeOp_ = v.rangeOp_
                    this.endExpr_ = v.endExpr_
                    this.colon_ = checkValid(v.colon_)
                    this.step_ = v.step_
                case None => throw ASTException("Cannot construct the 'RangeExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'RangeExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var start_: Option<Expr> = Expr()
    private var rangeOp_: Token = Token()
    private var endExpr_: Option<Expr> = Expr()
    private var colon_: Token = Token()
    private var step_: Option<Expr> = None<Expr>
    public mut prop start: Expr {
        get() {
            match (start_) {
                case Some(v) => v
                case None => throw ASTException("'RangeExpr' has no start.")
            }
        }
        set(v) {
            start_ = v
        }
    }
    public mut prop op: Token {
        get() {
            rangeOp_
        }
        set(v) {
            rangeOp_ = v
        }
    }
    public mut prop end: Expr {
        get() {
            match (endExpr_) {
                case Some(v) => v
                case None => throw ASTException("'RangeExpr' has no end.")
            }
        }
        set(v) {
            endExpr_ = v
        }
    }
    public mut prop colon: Token {
        get() {
            colon_
        }
        set(v) {
            checkTokenType(v, COLON)
            colon_ = v
        }
    }
    public mut prop step: Expr {
        get() {
            match (step_) {
                case Some(v) => v
                case None => throw ASTException("'RangeExpr' has no step.")
            }
        }
        set(v) {
            step_ = Some(v)
        }
    }

    protected func precedence(): Int64 {
        return rangeOp_.kind.opPrecedence()
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        match (start_) {
            case Some(start) => addParen(ret, start, this)
            case None => ()
        }
        ret.append(rangeOp_)
        match (endExpr_) {
            case Some(end) => addParen(ret, end, this)
            case None => ()
        }
        match (step_) {
            case Some(step) =>
                ret.append(colon_)
                addParen(ret, step, this)
            case None => ()
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        match (start_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        match (endExpr_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        match (step_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "RangeExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        match (start_) {
            case Some(node) =>
                ret += getIndent(currentIndent) + "-start: "
                ret += node.dump(currentIndent)
            case None => ()
        }
        ret += getTokenIndent("-op", rangeOp_, currentIndent)
        match (endExpr_) {
            case Some(node) =>
                ret += getIndent(currentIndent) + "-end: "
                ret += node.dump(currentIndent)
            case None => ()
        }
        match (step_) {
            case Some(node) =>
                ret += getTokenIndent("-colon", colon_, currentIndent)
                ret += getIndent(currentIndent) + "-step: "
                ret += node.dump(currentIndent)
            case None => ()
        }

        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class SubscriptExpr <: Expr {
    init(postfixExpr: Expr, lSquare: Token, index: ArrayList<Expr>, rSquare: Token) {
        postfixExpr_ = postfixExpr
        lSquare_ = lSquare
        index_ = index
        rSquare_ = rSquare
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as SubscriptExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.postfixExpr_ = v.postfixExpr_
                    this.lSquare_ = v.lSquare_
                    this.index_ = v.index_
                    this.rSquare_ = v.rSquare_
                case None => throw ASTException("Cannot construct the 'SubscriptExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'SubscriptExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var postfixExpr_: Expr = Expr()
    private var lSquare_: Token = Token(TokenKind.LSQUARE)
    private var index_: ArrayList<Expr> = ArrayList<Expr>()
    private var rSquare_: Token = Token(TokenKind.RSQUARE)
    public mut prop baseExpr: Expr {
        get() {
            postfixExpr_
        }
        set(v) {
            postfixExpr_ = v
        }
    }
    public mut prop lSquare: Token {
        get() {
            lSquare_
        }
        set(v) {
            checkTokenType(v, LSQUARE)
            lSquare_ = v
        }
    }
    public mut prop indexList: ArrayList<Expr> {
        get() {
            index_
        }
        set(v) {
            index_ = v
        }
    }
    public mut prop rSquare: Token {
        get() {
            rSquare_
        }
        set(v) {
            checkTokenType(v, RSQUARE)
            rSquare_ = v
        }
    }

    protected func precedence(): Int64 {
        return lSquare_.kind.opPrecedence()
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        if (postfixExpr_ is OptionalExpr) {
            ret.append(postfixExpr_)
        } else {
            addParen(ret, postfixExpr_, this, addOnEqualPred: false)
        }
        // for '\n[0] or ';[0]', delete r'\n' or r';'
        if (ret.size > 1 && (ret[ret.size - 1].kind == TokenKind.NL || ret[ret.size - 1].kind == TokenKind.SEMI)) {
            ret = ret.remove(ret.size - 1)
        }
        ret.append(lSquare_)
        for (i in 0..index_.size) {
            ret.append(index_[i])
            if (i != index_.size - 1) {
                ret.append(Token(TokenKind.COMMA))
            }
        }
        ret.append(rSquare_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        postfixExpr_.traverse(v)
        for (idenx in index_) {
            idenx.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "SubscriptExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-baseExpr: "
        ret += postfixExpr_.dump(currentIndent)
        for (i in 0..index_.size) {
            ret += getIndent(currentIndent) + "-indexList: ${i}, "
            ret += index_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class JumpExpr <: Expr {
    public init(kind: Tokens) {
        if (kind.size == 0) {
            throw ASTException("Cannot construct the 'JumpExpr' node: input is empty.")
        }
        kind_ = kind[0]
        if (kind_.kind != BREAK && kind_.kind != CONTINUE) {
            throw ASTException("Cannot construct the 'JumpExpr' node: expected 'BREAK' or 'CONTINUE' token.")
        }
        this.begin_ = kind_.pos
        this.end_ = Position(begin_.fileID, begin_.line, begin_.column + Int32(kind_.value.size))
    }
    public init() {
    }
    private var kind_: Token = Token()
    public mut prop keyword: Token {
        get() {
            kind_
        }
        set(v) {
            if (v.kind != BREAK && v.kind != CONTINUE) {
                throw ASTException("Illegal token kind: expected 'BREAK' or 'CONTINUE', got '${v.kind}'.")
            }
            kind_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(kind_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "JumpExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", kind_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class IncOrDecExpr <: Expr {
    init(kind: Token, expr: Expr) {
        op_ = kind
        expr_ = expr
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as IncOrDecExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.op_ = v.op_
                    this.expr_ = v.expr_
                case None => throw ASTException("Cannot construct the 'IncOrDecExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'IncOrDecExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var op_: Token = Token()
    private var expr_: Expr = Expr()
    public mut prop op: Token {
        get() {
            op_
        }
        set(v) {
            op_ = v
        }
    }
    public mut prop expr: Expr {
        get() {
            expr_
        }
        set(v) {
            expr_ = v
        }
    }
    protected func precedence(): Int64 {
        return op_.kind.opPrecedence()
    }

    public func toTokens(): Tokens {
        var ret = Tokens()
        addParen(ret, expr_, this)
        ret.append(op_)
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        expr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "IncOrDecExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-op", op_, currentIndent)
        ret += getIndent(currentIndent) + "-expr: "
        ret += expr_.dump(currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class Handler {
    init(handle_: Token, commandPattern: Pattern, handleBlock: Block) {
        this.handle_ = handle_
        this.commandPattern_ = commandPattern
        this.handleBlock_ = handleBlock
    }
    internal var handle_: Token = Token(TokenKind.HANDLE)
    internal var commandPattern_: Pattern = Pattern()
    internal var handleBlock_: Block = Block()
}


public class TryExpr <: Expr {
    init(try_: Token, resourceSpecLParen: Token, resourceSpec: ArrayList<VarDecl>, resourceSpecCommas: Tokens,
        resourceSpecRParen: Token, tryBlock: Block, catches: Tokens, catchLParens: Tokens, catchRParens: Tokens,
        patterns: ArrayList<Pattern>, catchBlocks: ArrayList<Block>, finally_: Token, finallyBlock: Option<Block>, handlers: ArrayList<Handler>) {
        this.try_ = try_
        this.resourceSpecLParen_ = resourceSpecLParen
        this.resourceSpec_ = resourceSpec
        this.resourceSpecCommas_ = resourceSpecCommas
        this.resourceSpecRParen_ = resourceSpecRParen
        this.tryBlock_ = tryBlock
        this.catches_ = catches
        this.catchLParens_ = catchLParens
        this.catchRParens_ = catchRParens
        this.patterns_ = patterns
        this.catchBlocks_ = catchBlocks
        this.finally_ = finally_
        this.finallyBlock_ = finallyBlock
        this.handlers_ = handlers
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as TryExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.try_ = v.try_
                    this.resourceSpecLParen_ = checkValid(v.resourceSpecLParen_)
                    this.resourceSpec_ = v.resourceSpec_
                    this.resourceSpecCommas_ = v.resourceSpecCommas_
                    this.resourceSpecRParen_ = checkValid(v.resourceSpecRParen_)
                    this.tryBlock_ = v.tryBlock_
                    this.catches_ = v.catches_
                    this.catchLParens_ = v.catchLParens_
                    this.catchRParens_ = v.catchRParens_
                    this.patterns_ = v.patterns_
                    this.catchBlocks_ = v.catchBlocks_
                    this.finally_ = checkValid(v.finally_)
                    this.finallyBlock_ = v.finallyBlock_
                    this.handlers_ = v.handlers_
                case None => throw ASTException("Cannot construct the 'TryExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'TryExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var try_: Token = Token(TokenKind.TRY)
    private var resourceSpecLParen_: Token = Token(TokenKind.LPAREN)
    private var resourceSpec_: ArrayList<VarDecl> = ArrayList<VarDecl>()
    private var resourceSpecCommas_: Tokens = Tokens()
    private var resourceSpecRParen_: Token = Token(TokenKind.RPAREN)
    private var tryBlock_: Block = Block()
    private var catches_: Tokens = Tokens()
    private var catchLParens_: Tokens = Tokens()
    private var catchRParens_: Tokens = Tokens()
    private var patterns_: ArrayList<Pattern> = ArrayList<Pattern>()
    private var catchBlocks_: ArrayList<Block> = ArrayList<Block>()
    private var finally_: Token = Token()
    private var finallyBlock_: Option<Block> = None<Block>
    private var handlers_: ArrayList<Handler> = ArrayList<Handler>()
    public mut prop keywordT: Token {
        get() {
            try_
        }
        set(v) {
            checkTokenType(v, TRY)
            try_ = v
        }
    }
    public mut prop resourceSpec: ArrayList<VarDecl> {
        get() {
            resourceSpec_
        }
        set(v) {
            resourceSpec_ = v
        }
    }
    public mut prop tryBlock: Block {
        get() {
            tryBlock_
        }
        set(v) {
            tryBlock_ = v
        }
    }
    public mut prop keywordsC: Tokens {
        get() {
            catches_
        }
        set(v) {
            checkTokensType(v, CATCH)
            catches_ = v
        }
    }
    public mut prop catchPatterns: ArrayList<Pattern> {
        get() {
            patterns_
        }
        set(v) {
            patterns_ = v
        }
    }
    public mut prop catchBlocks: ArrayList<Block> {
        get() {
            catchBlocks_
        }
        set(v) {
            catchBlocks_ = v
        }
    }
    public mut prop handlers: ArrayList<Handler> {
        get() {
            handlers_
        }
        set(v) {
            handlers_ = v
        }
    }
    public mut prop keywordF: Token {
        get() {
            finally_
        }
        set(v) {
            checkTokenType(v, FINALLY)
            finally_ = v
        }
    }
    public mut prop finallyBlock: Block {
        get() {
            match (finallyBlock_) {
                case Some(v) => v
                case None => throw ASTException("'TryExpr' has no finally block.")
            }
        }
        set(v) {
            finallyBlock_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(try_)
        if (!resourceSpec_.isEmpty()) {
            ret.append(resourceSpecLParen_)
            for (i in 0..resourceSpec_.size - 1) {
                let comma = resourceSpecCommas_.tryGet(i) ?? Token(TokenKind.COMMA)
                ret.append(resourceSpec_[i]).append(comma)
            }
            ret.append(resourceSpec_[resourceSpec_.size - 1]).append(resourceSpecRParen_)
        }
        ret.append(tryBlock_)
        ret.remove(ret.size - 1)
        for (i in 0..handlers_.size) {
            let handle_ = handlers_[i].handle_
            ret.append(handle_).append(Token(TokenKind.LPAREN)).append(handlers_[i].commandPattern_).append(Token(TokenKind.RPAREN)).append(handlers_[i].handleBlock_)
        }
        if (!patterns_.isEmpty()) {
            for (i in 0..patterns_.size) {
                let catch_ = catches_.tryGet(i) ?? Token(TokenKind.CATCH)
                let lparen = catchLParens_.tryGet(i) ?? Token(TokenKind.LPAREN)
                let rparen = catchRParens_.tryGet(i) ?? Token(TokenKind.RPAREN)
                ret.append(catch_).append(lparen).append(patterns_[i]).append(rparen).append(catchBlocks_[i])
            }
        }
        match (finallyBlock_) {
            case Some(v) => ret.append(finally_).append(v)
            case None => ()
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (res in resourceSpec_) {
            res.traverse(v)
        }
        tryBlock_.traverse(v)
        for (handler_ in handlers_) {
            handler_.commandPattern_.traverse(v)
            handler_.handleBlock_.traverse(v)
        }
        for (i in 0..patterns_.size) {
            patterns_[i].traverse(v)
            catchBlocks_[i].traverse(v)
        }
        match (finallyBlock_) {
            case Some(node) => node.traverse(v)
            case None => ()
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "TryExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keywordT", try_, currentIndent)
        for (i in 0..resourceSpec_.size) {
            ret += getIndent(currentIndent) + "-resourceSpec: ${i}, "
            ret += resourceSpec_[i].dump(currentIndent)
        }
        ret += getIndent(currentIndent) + "-tryBlock: "
        ret += tryBlock_.dump(currentIndent)
        for (i in 0..handlers_.size) {
            let handle_ = handlers_[i].handle_
            ret += getTokenIndent("-keywordsH", handle_, currentIndent, index: i)
            ret += getIndent(currentIndent) + "-commandPattern: ${i}, "
            ret += handlers_[i].commandPattern_.dump(currentIndent)
            ret += getIndent(currentIndent) + "-handleBlocks: ${i}, "
            ret += handlers_[i].handleBlock_.dump(currentIndent)
        }
        for (i in 0..patterns_.size) {
            let catch_ = catches_.tryGet(i) ?? Token(TokenKind.CATCH)
            ret += getTokenIndent("-keywordsC", catch_, currentIndent, index: i)
            ret += getIndent(currentIndent) + "-catchPatterns: ${i}, "
            ret += patterns_[i].dump(currentIndent)
            ret += getIndent(currentIndent) + "-catchBlocks: ${i}, "
            ret += catchBlocks_[i].dump(currentIndent)
        }
        match (finallyBlock_) {
            case Some(node) =>
                ret += getTokenIndent("-keywordF", finally_, currentIndent)
                ret += getIndent(currentIndent) + "-finallyBlock: "
                ret += node.dump(currentIndent)
            case None => ()
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class OptionalExpr <: Expr {
    public init() {
        super()
    }
    // we construct a MemberAccess to help parse OptionalExpr because compiler can't parse OptionalExpr directly.
    public init(inputs: Tokens) {
        let memberAccess: MemberAccess
        try {
            memberAccess = MemberAccess(inputs.append(quote(.b)))
        } catch (e: ASTException) {
            throw ASTException("Cannot construct the 'OptionalExpr' node.")
        }
        match (memberAccess.baseExpr as OptionalExpr) {
            case Some(v) =>
                this.begin_ = v.beginPos
                this.end_ = v.endPos
                this.baseExpr_ = v.baseExpr_
                this.quest_ = v.quest_
            case None => throw ASTException("Cannot construct the 'OptionalExpr' node.")
        }
    }
    init(baseExpr: Expr, quest: Token) {
        super()
        baseExpr_ = baseExpr
        quest_ = quest
    }

    private var baseExpr_: Expr = Expr()
    private var quest_: Token = Token(TokenKind.QUEST)
    public mut prop baseExpr: Expr {
        get() {
            baseExpr_
        }
        set(v) {
            baseExpr_ = v
        }
    }
    public mut prop quest: Token {
        get() {
            quest_
        }
        set(v) {
            checkTokenType(v, QUEST)
            quest_ = v
        }
    }
    protected func precedence(): Int64 {
        return quest_.kind.opPrecedence()
    }
    public func toTokens(): Tokens {
        var ret = Tokens()
        addParen(ret, baseExpr_, this)
        ret.append(quest_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        baseExpr_.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "OptionalExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-baseExpr: "
        ret += baseExpr_.dump(currentIndent)
        ret += getTokenIndent("-quest", quest_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class QuoteToken <: Expr {
    init(tokens: Tokens) {
        super()
        tokens_ = tokens
    }
    private var tokens_: Tokens = Tokens()
    public mut prop tokens: Tokens {
        get() {
            tokens_
        }
        set(v) {
            tokens_ = v
        }
    }
    public func toTokens(): Tokens {
        tokens_
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "QuoteToken {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        for (i in 0..tokens_.size) {
            ret += getTokenIndent("-tokens[${i}]", tokens_[i], currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class QuoteExpr <: Expr {
    init(keyword: Token, lParen: Token, exprs: ArrayList<Expr>, rParen: Token) {
        keyword_ = keyword
        lParen_ = lParen
        exprs_ = exprs
        rParen_ = rParen
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as QuoteExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.keyword_ = v.keyword_
                    this.lParen_ = v.lParen_
                    this.exprs_ = v.exprs_
                    this.rParen_ = v.rParen_
                case None => throw ASTException("Cannot construct the 'QuoteExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'QuoteExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var keyword_: Token = Token(TokenKind.QUOTE)
    private var lParen_: Token = Token(TokenKind.LPAREN)
    private var exprs_: ArrayList<Expr> = ArrayList<Expr>()
    private var rParen_: Token = Token(TokenKind.RPAREN)

    public mut prop keyword: Token {
        get() {
            keyword_
        }
        set(v) {
            checkTokenType(v, QUOTE)
            keyword_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop exprs: ArrayList<Expr> {
        get() {
            exprs_
        }
        set(v) {
            exprs_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(keyword_).append(lParen_)
        for (expr in exprs_) {
            match (expr) {
                case dollarRef: RefExpr where dollarRef.identifier.kind == TokenKind.DOLLAR_IDENTIFIER => ret.append(
                    dollarRef)
                case qt: QuoteToken => ret.append(qt)
                case parenExpr: ParenExpr =>
                    ret.append(Token(TokenKind.DOLLAR))
                       .append(expr)
                case _ => ret
                    .append(Token(TokenKind.DOLLAR))
                    .append(Token(TokenKind.LPAREN))
                    .append(expr)
                    .append(Token(TokenKind.RPAREN))
            }
        }
        ret.append(rParen_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        for (expr in exprs_) {
            expr.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "QuoteExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyword_, currentIndent)
        for (i in 0..exprs_.size) {
            ret += getIndent(currentIndent) + "-exprs: ${i}, "
            ret += exprs_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class WildcardExpr <: Expr {
    public init(keyword: Tokens) {
        if (keyword.size == 0) {
            throw ASTException("Cannot construct the 'WildcardExpr' node: input is empty.")
        }
        keyword_ = keyword[0]
        checkTokenType(keyword_, WILDCARD)
        this.begin_ = keyword_.pos
        this.end_ = Position(begin_.fileID, begin_.line, begin_.column + Int32(keyword_.value.size))
    }
    public init() {
        super()
    }
    private var keyword_: Token = Token(TokenKind.WILDCARD)
    public mut prop keyword: Token {
        get() {
            keyword_
        }
        set(v) {
            checkTokenType(v, WILDCARD)
            keyword_ = v
        }
    }
    public func toTokens(): Tokens {
        Tokens().append(keyword_)
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "WildcardExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-keyword", keyword_, currentIndent)
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class VArrayExpr <: Expr {
    init(ty: VArrayType, lParen: Token, args: ArrayList<Argument>, rParen: Token) {
        ty_ = ty
        lParen_ = lParen
        args_ = args
        rParen_ = rParen
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as VArrayExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.ty_ = v.ty_
                    this.lParen_ = checkValid(v.lParen_)
                    this.args_ = v.args_
                    this.rParen_ = checkValid(v.rParen_)
                case None => throw ASTException("Cannot construct the 'VArrayExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'VArrayExpr' node.")
        }
    }
    public init() {
        super()
    }
    private var ty_: VArrayType = VArrayType()
    private var lParen_: Token = Token()
    private var args_: ArrayList<Argument> = ArrayList<Argument>()
    private var rParen_: Token = Token()
    public mut prop vArrayType: VArrayType {
        get() {
            ty_
        }
        set(v) {
            ty_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop arguments: ArrayList<Argument> {
        get() {
            args_
        }
        set(v) {
            args_ = v
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(ty_)
        if (isValidPosition(lParen_)) {
            ret.append(lParen_)
        }
        ret.append(arguments.toTokens())
        if (isValidPosition(rParen_)) {
            ret.append(rParen_)
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        ty_.traverse(v)
        for (arg in args_) {
            arg.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "VArrayExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getIndent(currentIndent) + "-vArrayType: "
        ret += ty_.dump(currentIndent)
        for (i in 0..args_.size) {
            ret += getIndent(currentIndent) + "-arguments: ${i}, "
            ret += args_[i].dump(currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

public class MacroExpandExpr <: Expr {
    init(at: Token, fullIdentifier: Token, identifier: Token, lSquare: Token, macroAttrs: Tokens, rSquare: Token,
        lParen: Token, macroInputs: Tokens, rParen: Token, macroInputDecl: Option<Decl>, hasParenthesis: Bool) {
        at_ = at
        pkgIdentifier_ = fullIdentifier
        identifier_ = identifier
        lSquare_ = lSquare
        macroAttrs_ = macroAttrs
        rSquare_ = rSquare
        lParen_ = lParen
        macroInputs_ = macroInputs
        rParen_ = rParen
        macroInputDecl_ = macroInputDecl
        hasParenthesis_ = hasParenthesis
    }
    public init(inputs: Tokens) {
        try {
            match (parseExpr(inputs) as MacroExpandExpr) {
                case Some(v) =>
                    this.begin_ = v.beginPos
                    this.end_ = v.endPos
                    this.at_ = v.at_
                    this.pkgIdentifier_ = v.pkgIdentifier_
                    this.identifier_ = v.identifier_
                    this.lSquare_ = checkValid(v.lSquare_)
                    this.macroAttrs_ = v.macroAttrs_
                    this.rSquare_ = checkValid(v.rSquare_)
                    this.lParen_ = checkValid(v.lParen_)
                    this.macroInputs_ = v.macroInputs_
                    this.rParen_ = checkValid(v.rParen_)
                    this.macroInputDecl_ = v.macroInputDecl_
                    this.hasParenthesis_ = v.hasParenthesis_
                case None => throw ASTException("Cannot construct the 'MacroExpandExpr' node.")
            }
        } catch (e: ParseASTException) {
            throw ASTException("Cannot construct the 'MacroExpandExpr' node.")
        }
    }
    public init() {}
    private var at_: Token = Token(TokenKind.AT)
    private var pkgIdentifier_: Token = Token()
    private var identifier_: Token = Token()
    private var lSquare_: Token = Token()
    private var macroAttrs_: Tokens = Tokens()
    private var rSquare_: Token = Token()
    private var lParen_: Token = Token()
    private var macroInputs_: Tokens = Tokens()
    private var rParen_: Token = Token()
    private var macroInputDecl_: Option<Decl> = None<Decl>
    private var hasParenthesis_: Bool = false

    public mut prop at: Token {
        get() {
            at_
        }
        set(v) {
            checkTokenType(v, AT)
            at_ = v
        }
    }
    public mut prop identifier: Token {
        get() {
            pkgIdentifier_
        }
        set(v) {
            pkgIdentifier_ = v
        }
    }

    public mut prop lSquare: Token {
        get() {
            lSquare_
        }
        set(v) {
            checkTokenType(v, LSQUARE)
            lSquare_ = v
        }
    }
    public mut prop macroAttrs: Tokens {
        get() {
            macroAttrs_
        }
        set(v) {
            macroAttrs_ = v
        }
    }
    public mut prop rSquare: Token {
        get() {
            rSquare_
        }
        set(v) {
            checkTokenType(v, RSQUARE)
            rSquare_ = v
        }
    }
    public mut prop lParen: Token {
        get() {
            lParen_
        }
        set(v) {
            checkTokenType(v, LPAREN)
            lParen_ = v
        }
    }
    public mut prop macroInputs: Tokens {
        get() {
            macroInputs_
        }
        set(v) {
            macroInputs_ = v
            macroInputDecl_ = try {
                Some(parseDecl(v))
            } catch (_: ParseASTException | ASTException) {
                None
            }
        }
    }
    public mut prop rParen: Token {
        get() {
            rParen_
        }
        set(v) {
            checkTokenType(v, RPAREN)
            rParen_ = v
        }
    }
    public func toTokens(): Tokens {
        var ret = Tokens().append(at)
        let identArray = pkgIdentifier_.value.split(".")
        let identPos = pkgIdentifier_.pos
        var identColumn = identPos.column
        for (i in 0..identArray.size - 1) {
            let identifier = identArray[i]
            ret = ret + Token(TokenKind.IDENTIFIER, identifier).addPosition(identPos)
            identColumn = identColumn + Int32(identifier.size)
            ret = ret + Token(TokenKind.DOT).addPosition(identPos.fileID, identPos.line, identColumn)
            identColumn++
        }
        if (identArray.size > 0) {
            let identifier = identArray[identArray.size - 1]
            ret = ret + Token(TokenKind.IDENTIFIER, identifier).addPosition(identPos.fileID, identPos.line, identColumn)
        }
        if (isValidToken(lSquare_) && isValidToken(rSquare_)) {
            ret.append(lSquare_).append(macroAttrs_).append(rSquare_)
        }
        if (isValidToken(lParen_) && isValidToken(rParen_)) {
            ret.append(lParen_).append(macroInputs_).append(rParen_)
        } else {
            match (macroInputDecl_) {
                case Some(v) => ret.append(Token(NL)).append(v)
                case None => ()
            }
        }
        ret
    }

    public func traverse(v: Visitor): Unit {
        v.visit(this)
        super.traverse(v)
        if (v.needBreakTraverse()) {
            return
        }
        if (let Some(decl) <- macroInputDecl_) {
            decl.traverse(v)
        }
        return
    }

    protected func dump(indent: UInt16): String {
        var ret: String = "MacroExpandExpr {\n"
        currentIndent = indent
        if (indent != 0 || beginNode) {
            currentIndent++
        }
        ret += getTokenIndent("-packageIdentifier", pkgIdentifier_, currentIndent)
        ret += getTokenIndent("-identifier", identifier_, currentIndent)

        for (i in 0..macroAttrs_.size) {
            ret += getTokenIndent("-macroAttrs:${i}", macroAttrs_[i], currentIndent)
        }
        for (i in 0..macroInputs_.size) {
            ret += getTokenIndent("-macroInputs:${i}", macroInputs_[i], currentIndent)
        }
        ret += getIndent(indent) + "}\n"
        ret
    }
}

func addParen(ret: Tokens, innerExpr: Expr, thisExpr: Expr, addOnEqualPred!: Bool = true) {
    let ifAddParen: Bool
    if (addOnEqualPred) {
        ifAddParen = innerExpr.precedence() <= thisExpr.precedence()
    } else {
        ifAddParen = innerExpr.precedence() < thisExpr.precedence()
    }

    if (ifAddParen) {
        ret.append(Token(TokenKind.LPAREN))
        ret.append(innerExpr.toTokens())
        ret.append(Token(TokenKind.RPAREN))
    } else {
        ret.append(innerExpr.toTokens())
    }
}
