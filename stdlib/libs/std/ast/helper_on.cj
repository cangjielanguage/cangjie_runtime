/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

// Helpers that exist only when local_mode_api is enabled. Every function here
// has a counterpart with the same signature in helper_off.cj, so that call
// sites never need to know about conditional compilation.

// ---------------------------------------------------------------------------
// FuncDecl
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func copyModalFrom(dst: FuncDecl, src: FuncDecl): Unit {
    dst.modal = src.modal
    dst.thisParam = src.thisParam
}

@When[local_mode_api == "on"]
func appendModalTokens(src: FuncDecl, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func appendThisParamTokens(src: FuncDecl, to: Tokens): Unit {
    match (src.thisParam) {
        case Some(tp) => to.append(tp.toTokens())
        case None => ()
    }
}

@When[local_mode_api == "on"]
func traverseModal(src: FuncDecl, v: Visitor): Unit {
    src.modal.traverse(v)
    match (src.thisParam) {
        case Some(node) => node.traverse(v)
        case None => ()
    }
}

@When[local_mode_api == "on"]
func dumpModal(src: FuncDecl, indent: UInt16): String {
    var ret = src.modal.dump(indent)
    match (src.thisParam) {
        case Some(node) =>
            ret += getIndent(indent) + "-thisParam: "
            ret += node.dump(indent)
        case None => ()
    }
    return ret
}

// ---------------------------------------------------------------------------
// CallExpr
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func copyModalFrom(dst: CallExpr, src: CallExpr): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: CallExpr, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: CallExpr, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: CallExpr, indent: UInt16): String {
    return src.modal.dump(indent)
}

// ---------------------------------------------------------------------------
// PrimitiveTypeExpr
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func appendModalTokens(src: PrimitiveTypeExpr, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: PrimitiveTypeExpr, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: PrimitiveTypeExpr, indent: UInt16): String {
    return src.modal.dump(indent)
}

// ---------------------------------------------------------------------------
// Type nodes
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func copyModalFrom(dst: PrimitiveType, src: PrimitiveType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: PrimitiveType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: PrimitiveType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: PrimitiveType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: RefType, src: RefType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: RefType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: RefType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: RefType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: QualifiedType, src: QualifiedType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: QualifiedType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: QualifiedType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: QualifiedType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: ParenType, src: ParenType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: ParenType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: ParenType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: ParenType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: TupleType, src: TupleType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: TupleType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: TupleType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: TupleType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: ThisType, src: ThisType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: ThisType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: ThisType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: ThisType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: PrefixType, src: PrefixType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: PrefixType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: PrefixType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: PrefixType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: FuncType, src: FuncType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: FuncType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: FuncType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: FuncType, indent: UInt16): String {
    return src.modal.dump(indent)
}

@When[local_mode_api == "on"]
func copyModalFrom(dst: VArrayType, src: VArrayType): Unit {
    dst.modal = src.modal
}

@When[local_mode_api == "on"]
func appendModalTokens(src: VArrayType, to: Tokens): Unit {
    to.append(src.modal.toTokens())
}

@When[local_mode_api == "on"]
func traverseModal(src: VArrayType, v: Visitor): Unit {
    src.modal.traverse(v)
}

@When[local_mode_api == "on"]
func dumpModal(src: VArrayType, indent: UInt16): String {
    return src.modal.dump(indent)
}

// ---------------------------------------------------------------------------
// Parser-side helpers
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func buildModalFrom(call: CallExpr, callExpr: ASTFormat_CallExpr): Unit {
    call.modal = createModalInfo(callExpr.GetModal())
}

@When[local_mode_api == "on"]
func buildModalFrom(primExpr: PrimitiveTypeExpr, primitiveTypeExpr: ASTFormat_PrimitiveTypeExpr): Unit {
    primExpr.modal = createModalInfo(primitiveTypeExpr.GetModal())
}

@When[local_mode_api == "on"]
func buildModalFrom(funcDeclNode: FuncDecl, fd: ASTFormat_FuncDecl, fb: ASTFormat_FuncBody): Unit {
    funcDeclNode.modal = createModalInfo(fd.GetModal())
    match (createThisParam(fb.GetParamList())) {
        case Some(tp) => funcDeclNode.thisParam = Some<ThisParam>(tp)
        case None => ()
    }
}

@When[local_mode_api == "on"]
func buildModalFrom(astNode: TypeNode, tyBase: ASTFormat_TypeBase): Unit {
    setNodeModal(astNode, createModalInfo(tyBase.GetModal()))
}

@When[local_mode_api == "on"]
func createThisParamDecl(decl: ASTFormat_Decl): Decl {
    var tp = match (decl.GetDeclAsThisParam()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var thisTok = Token(TokenKind.THIS).addPosition(tp.GetThisPos())
    var modal = createModalInfo(tp.GetModal())
    var comma = Token()
    if (isValidPosition(tp.GetCommaPos())) {
        comma = Token(TokenKind.COMMA).addPosition(tp.GetCommaPos())
    }
    return ThisParam(thisTok, modal, comma)
}

@When[local_mode_api == "on"]
func createExclaveExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var exclaveExpr = match (expr.GetExprAsExclaveExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var exclaveToken = Token(TokenKind.EXCLAVE).addPosition(exclaveExpr.GetExclavePos())
    var block = generateBlock(exclaveExpr.GetBody())
    var node = ExclaveExpr(exclaveToken, block)
    return node
}

// ---------------------------------------------------------------------------
// TokenKind
// ---------------------------------------------------------------------------

@When[local_mode_api == "on"]
func eqKindVariant(left: TokenKind, right: TokenKind): Bool {
    match (left) {
        case TokenKind.EXCLAVE => match (right) {
            case TokenKind.EXCLAVE => true
            case _ => false
        }
        case TokenKind.DEMODE => match (right) {
            case TokenKind.DEMODE => true
            case _ => false
        }
        case _ => false
    }
}

@When[local_mode_api == "on"]
func kindToStringVariant(tk: TokenKind): String {
    match (tk) {
        case TokenKind.EXCLAVE => return "EXCLAVE"
        case TokenKind.DEMODE => return "DEMODE"
        case _ => return "INVALID_TOKENKIND"
    }
}

@When[local_mode_api == "on"]
func getTokenIDVariant(tk: TokenKind): UInt16 {
    match (tk) {
        case TokenKind.EXCLAVE => return 165
        case TokenKind.DEMODE => return 166
        case _ => return 162
    }
}

@When[local_mode_api == "on"]
func getVariantPatterns(): Array<(TokenKind, String, String)> {
    return [
        (TokenKind.EXCLAVE, "exclave", "exclave"),
        (TokenKind.DEMODE, "demode", "demode"),
    ]
}

@When[local_mode_api == "on"]
func getVariantExprKinds(): Array<String> {
    return ["exclave_expr"]
}
