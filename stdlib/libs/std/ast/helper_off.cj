/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

// Stub counterparts of helper_on.cj, active only when local_mode_api is
// disabled. Call sites never need to know about conditional compilation.

// ---------------------------------------------------------------------------
// FuncDecl
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func copyModalFrom(_: FuncDecl, _: FuncDecl): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: FuncDecl, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func appendThisParamTokens(_: FuncDecl, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: FuncDecl, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: FuncDecl, _: UInt16): String {
    return ""
}

// ---------------------------------------------------------------------------
// CallExpr
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func copyModalFrom(_: CallExpr, _: CallExpr): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: CallExpr, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: CallExpr, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: CallExpr, _: UInt16): String {
    return ""
}

// ---------------------------------------------------------------------------
// PrimitiveTypeExpr
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func appendModalTokens(_: PrimitiveTypeExpr, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: PrimitiveTypeExpr, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: PrimitiveTypeExpr, _: UInt16): String {
    return ""
}

// ---------------------------------------------------------------------------
// Type nodes
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func copyModalFrom(_: PrimitiveType, _: PrimitiveType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: PrimitiveType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: PrimitiveType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: PrimitiveType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: RefType, _: RefType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: RefType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: RefType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: RefType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: QualifiedType, _: QualifiedType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: QualifiedType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: QualifiedType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: QualifiedType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: ParenType, _: ParenType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: ParenType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: ParenType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: ParenType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: TupleType, _: TupleType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: TupleType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: TupleType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: TupleType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: ThisType, _: ThisType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: ThisType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: ThisType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: ThisType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: PrefixType, _: PrefixType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: PrefixType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: PrefixType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: PrefixType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: FuncType, _: FuncType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: FuncType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: FuncType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: FuncType, _: UInt16): String {
    return ""
}

@When[local_mode_api == "off"]
func copyModalFrom(_: VArrayType, _: VArrayType): Unit {}

@When[local_mode_api == "off"]
func appendModalTokens(_: VArrayType, _: Tokens): Unit {}

@When[local_mode_api == "off"]
func traverseModal(_: VArrayType, _: Visitor): Unit {}

@When[local_mode_api == "off"]
func dumpModal(_: VArrayType, _: UInt16): String {
    return ""
}

// ---------------------------------------------------------------------------
// Parser-side helpers
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func buildModalFrom(_: CallExpr, _: ASTFormat_CallExpr): Unit {}

@When[local_mode_api == "off"]
func buildModalFrom(_: PrimitiveTypeExpr, _: ASTFormat_PrimitiveTypeExpr): Unit {}

@When[local_mode_api == "off"]
func buildModalFrom(_: FuncDecl, _: ASTFormat_FuncDecl, _: ASTFormat_FuncBody): Unit {}

@When[local_mode_api == "off"]
func buildModalFrom(_: TypeNode, _: ASTFormat_TypeBase): Unit {}

@When[local_mode_api == "off"]
func createThisParamDecl(_: ASTFormat_Decl): Decl {
    throw ParseASTException("Unsupported decl node kind: 'this_param'.")
}

@When[local_mode_api == "off"]
func createExclaveExpr(_: ASTFormat_Expr, _: ASTFormat_NodeBase): Expr {
    throw ParseASTException("Unsupported expr node kind: 'exclave_expr'.")
}

// ---------------------------------------------------------------------------
// TokenKind
// ---------------------------------------------------------------------------

@When[local_mode_api == "off"]
func eqKindVariant(_: TokenKind, _: TokenKind): Bool {
    return false
}

@When[local_mode_api == "off"]
func kindToStringVariant(_: TokenKind): String {
    return "INVALID_TOKENKIND"
}

@When[local_mode_api == "off"]
func getTokenIDVariant(_: TokenKind): UInt16 {
    return 162
}

@When[local_mode_api == "off"]
func getVariantPatterns(): Array<(TokenKind, String, String)> {
    return []
}

@When[local_mode_api == "off"]
func getVariantExprKinds(): Array<String> {
    return []
}
