/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

import std.collection.ArrayList

public func parseType(input: Tokens): TypeNode {
    /* Get node info from flatbuffer */
    let node = unsafe {
        try {
            parse(input, {
                p: CPointer<UInt8> => return CJ_AST_ParseType(match (MACRO_OBJECT.get()) {
                    case Some(ptr) => ptr
                    case None => CPointer<Unit>()
                }, p, CPointer<Int64>())
            })
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse type.")
        }
    }
    /* Get decl info from flatbuffer */
    var astNode = generateTypeAST(node.GetRootAsType())
    return astNode
}

public func parseTypeFragment(input: Tokens, startFrom!: Int64 = 0): (TypeNode, Int64) {
    let (node, count) = unsafe {
        try {
            parseFragment(
                input,
                startFrom,
                {
                    p: CPointer<UInt8>, sizeRef: CPointer<Int64> => return CJ_AST_ParseType(
                        match (MACRO_OBJECT.get()) {
                            case Some(ptr) => ptr
                            case None => CPointer<Unit>()
                        }, p, sizeRef)
                }
            )
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse type fragment.")
        }
    }
    var astNode = generateTypeAST(node.GetRootAsType())
    return (astNode, count)
}

func generateTypeAST(tyNode: Option<ASTFormat_Type>): TypeNode {
    var ty = match (tyNode) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var tyBase = match (ty.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var nodeBase = match (tyBase.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var astKind: String = nodeBase.GetAstKind()
    var begin = nodeBase.GetBegin()
    var end = nodeBase.GetEnd()
    var astNode = match (astKind) {
        case "ref_type" => createRefType(ty.GetTypeAsRefType(), nodeBase)
        case "qualified_type" => createQualifiedType(ty, nodeBase)
        case "option_type" => createPrefixType(ty, nodeBase)
        case "varray_type" => createVArrayType(ty, nodeBase)
        case "primitive_type" => createPrimitiveType(ty, nodeBase)
        case "paren_type" => createParenType(ty, nodeBase)
        case "func_type" => createFuncType(ty, nodeBase)
        case "tuple_type" => createTupleType(ty, nodeBase)
        case "this_type" => createThisType(ty, nodeBase)
        case _ => throw ParseASTException("Unsupported type node kind: '${astKind}'.")
    }
    astNode.beginPos = Position(begin.fileId, begin.line, begin.column)
    astNode.endPos = Position(end.fileId, end.line, end.column)
    astNode.astKind = astKind
    astNode.modal = createModalInfo(tyBase.GetModal())
    return astNode
}

func createPrimitiveType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var primitiveType = match (tyNode.GetTypeAsPrimitiveType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeBase = primitiveType.GetBase() ?? throw ParseASTException()
    var typeName: Token = Token(TokenKind.IDENTIFIER, typeBase.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
    let colon: Token = Token(TokenKind.COLON).addPosition(typeBase.GetColonPos())
    // for named parameter types x: Type, type position is in type_pos, otherwise, just use begin
    let typePosition = if (isValidPosition(typeBase.GetTypePos())) {
        typeBase.GetTypePos()
    } else {
        nodeBase.GetBegin()
    }
    var kind: Token = Token(TokenKindHelper.getPrimitiveTypeTokenKind(primitiveType.GetKind())).addPosition(
        typePosition)
    return PrimitiveType(typeName, colon, kind)
}

func createRefType(tyNode: Option<ASTFormat_RefType>, nodeBase: ASTFormat_NodeBase): TypeNode {
    var refType = match (tyNode) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (refType.GetBase()) {
        case Some(v) =>
            if (!v.GetTypeParameterName().isEmpty()) {
                Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
            } else {
                Token(TokenKind.IDENTIFIER, v.GetTypeParameterName())
            }
        case None => throw ParseASTException()
    }
    let colon: Token = match (refType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var identifier: Token = match (refType.GetRef()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetIdentifier()).addPosition(v.GetIdentifierPos())
        case None => throw ParseASTException()
    }
    var lAngle: Token = Token(TokenKind.LT).addPosition(refType.GetLeftAnglePos())
    var types: ArrayList<TypeNode> = ArrayList<TypeNode>(refType.GetTypeArguments().size)
    let commas = Tokens()
    for (tp in refType.GetTypeArguments()) {
        types.add(generateTypeAST(tp))
        match (tp?.GetBase()?.GetCommaPos()) {
            case Some(position) where isValidPosition(position) => commas.append(
                Token(TokenKind.COMMA).addPosition(position))
            case _ => ()
        }
    }
    var rAngle: Token = Token(TokenKind.GT).addPosition(refType.GetRightAnglePos())
    return RefType(typeName, colon, identifier, lAngle, types, commas, rAngle)
}

func createQualifiedType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var qualifiedType = match (tyNode.GetTypeAsQualifiedType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (qualifiedType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (qualifiedType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var baseTy = match (qualifiedType.GetBaseType()) {
        case Some(v) => generateTypeAST(v)
        case None => throw ParseASTException()
    }
    var dot: Token = Token(TokenKind.DOT).addPosition(qualifiedType.GetDotPos())
    var identifier: Token = Token(TokenKind.IDENTIFIER, qualifiedType.GetField()).addPosition(
        qualifiedType.GetFieldPos())
    var lAngle: Token = Token(TokenKind.LT).addPosition(qualifiedType.GetLeftAnglePos())
    var types: ArrayList<TypeNode> = ArrayList<TypeNode>(qualifiedType.GetTypeArguments().size)
    let commas = Tokens()
    for (tp in qualifiedType.GetTypeArguments()) {
        types.add(generateTypeAST(tp))
        match (tp?.GetBase()?.GetCommaPos()) {
            case Some(position) where isValidPosition(position) => commas.append(
                Token(TokenKind.COMMA).addPosition(position))
            case _ => ()
        }
    }
    var rAngle: Token = Token(TokenKind.GT).addPosition(qualifiedType.GetRightAnglePos())
    return QualifiedType(typeName, colon, baseTy, dot, identifier, lAngle, types, commas, rAngle)
}

func createParenType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var parenType = match (tyNode.GetTypeAsParenType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (parenType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (parenType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var lParen: Token = Token(TokenKind.LPAREN).addPosition(parenType.GetLeftParenPos())
    var ty: TypeNode = generateTypeAST(parenType.GetType())
    var rParen: Token = Token(TokenKind.RPAREN).addPosition(parenType.GetRightParenPos())
    return ParenType(typeName, colon, lParen, ty, rParen)
}

func createTupleType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var tupleType = match (tyNode.GetTypeAsTupleType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (tupleType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (tupleType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var lParen: Token = Token(TokenKind.LPAREN).addPosition(tupleType.GetLeftParenPos())
    let fieldSrc = tupleType.GetFieldTypes()
    var types: ArrayList<TypeNode> = ArrayList<TypeNode>(fieldSrc.size, {i => generateTypeAST(fieldSrc[i])})

    var rParen: Token = Token(TokenKind.RPAREN).addPosition(tupleType.GetRightParenPos())
    var commas = Tokens()
    for (pos in tupleType.GetCommaPosVector()) {
        commas.append(Token(TokenKind.COMMA).addPosition(pos))
    }
    return TupleType(typeName, colon, lParen, types, commas, rParen)
}

func createThisType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var thisType = match (tyNode.GetTypeAsThisType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeBase = thisType.GetBase() ?? throw ParseASTException()
    var typeName: Token = Token(TokenKind.IDENTIFIER, typeBase.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
    let colon: Token = Token(TokenKind.COLON).addPosition(typeBase.GetColonPos())
    // for named parameter types x: Type, type position is in type_pos, otherwise, just use begin
    let typePosition = if (isValidPosition(typeBase.GetTypePos())) {
        typeBase.GetTypePos()
    } else {
        nodeBase.GetBegin()
    }
    var keyword: Token = Token(TokenKind.THISTYPE).addPosition(typePosition)
    return ThisType(typeName, colon, keyword)
}

func createFuncType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var funcType = match (tyNode.GetTypeAsFuncType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (funcType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (funcType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var token = Token()
    var lParen: Token = Token(TokenKind.LPAREN).addPosition(funcType.GetLeftParenPos())
    var types: ArrayList<TypeNode> = ArrayList<TypeNode>(funcType.GetParamTypes().size)
    let commas = Tokens()
    for (tp in funcType.GetParamTypes()) {
        types.add(generateTypeAST(tp))
        match (tp?.GetBase()?.GetCommaPos()) {
            case Some(position) where isValidPosition(position) => commas.append(
                Token(TokenKind.COMMA).addPosition(position))
            case _ => ()
        }
    }
    var rParen: Token = Token(TokenKind.RPAREN).addPosition(funcType.GetRightParenPos())
    var arrow: Token = Token(TokenKind.ARROW).addPosition(funcType.GetArrowPos())
    var retTy: TypeNode = generateTypeAST(funcType.GetRetType())
    return FuncType(typeName, colon, token, lParen, types, commas, rParen, arrow, retTy)
}

func createVArrayType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var vArrayType = match (tyNode.GetTypeAsVArrayType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (vArrayType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (vArrayType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var keyword: Token = Token(TokenKind.VARRAY).addPosition(vArrayType.GetVarrayPos())
    var lAngle: Token = Token(TokenKind.LT).addPosition(vArrayType.GetLeftAnglePos())
    var ty: TypeNode = generateTypeAST(vArrayType.GetTypeArgument())
    var constantTy = match (vArrayType.GetConstantType()) {
        case Some(v) => v.GetTypeAsConstantType().getOrThrow()
        case None => throw ParseASTException()
    }
    var dollar: Token = Token(TokenKind.DOLLAR).addPosition(constantTy.GetDollarPos())
    var constant = generateExprAST(constantTy.GetConstantExpr())
    var size = match (constant as LitConstExpr) {
        case Some(v) => v.literal
        case None => throw ParseASTException()
    }
    var rAngle: Token = Token(TokenKind.GT).addPosition(vArrayType.GetRightAnglePos())
    return VArrayType(typeName, colon, keyword, lAngle, ty, dollar, size, rAngle)
}

func createPrefixType(tyNode: ASTFormat_Type, nodeBase: ASTFormat_NodeBase): TypeNode {
    var prefixType = match (tyNode.GetTypeAsOptionType()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var typeName: Token = match (prefixType.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetTypeParameterName()).addPosition(nodeBase.GetBegin())
        case None => throw ParseASTException()
    }
    let colon: Token = match (prefixType.GetBase()) {
        case Some(v) => Token(TokenKind.COLON).addPosition(v.GetColonPos())
        case _ => throw ParseASTException()
    }
    var tks: Tokens = Tokens()
    for (pos in prefixType.GetQuestVector()) {
        tks.append(Token(TokenKind.QUEST).addPosition(pos))
    }
    var ty = generateTypeAST(prefixType.GetComponentType())
    return PrefixType(typeName, colon, tks, ty)
}
