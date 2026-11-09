/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

import std.collection.ArrayList

public func parseExpr(input: Tokens): Expr {
    /* Get node info from flatbuffer */
    let node = unsafe {
        try {
            parse(input, {
                p: CPointer<UInt8> => return CJ_AST_ParseExpr(match (MACRO_OBJECT.get()) {
                    case Some(ptr) => ptr
                    case None => CPointer<Unit>()
                }, p, CPointer<Int64>())
            })
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse expr.")
        }
    }
    /* Get decl info from flatbuffer */
    var astNode = generateExprAST(node.GetRootAsExpr())
    return astNode
}

public func parseExprFragment(input: Tokens, startFrom!: Int64 = 0): (Expr, Int64) {
    let (node, count) = unsafe {
        try {
            parseFragment(
                input,
                startFrom,
                {
                    p: CPointer<UInt8>, sizeRef: CPointer<Int64> => return CJ_AST_ParseExpr(
                        match (MACRO_OBJECT.get()) {
                            case Some(ptr) => ptr
                            case None => CPointer<Unit>()
                        }, p, sizeRef)
                }
            )
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse expr fragment.")
        }
    }
    var astNode = generateExprAST(node.GetRootAsExpr())
    return (astNode, count)
}

func generateExprAST(exprNode: Option<ASTFormat_Expr>): Expr {
    var expr = match (exprNode) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var exprBase = match (expr.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException("Expression has no base information.")
    }
    var astKind: String = exprBase.GetAstKind()
    var astNode = match (astKind) {
        case "block" => createBlock(expr)
        case "wildcard_expr" => createWildcardExpr(exprBase)
        case "call_expr" => createCallExpr(expr)
        case "paren_expr" => createParenExpr(expr)
        case "member_access_expr" => createMemberAccess(expr)
        case "optional_expr" => createOptionalExpr(expr)
        case "optional_chain_expr" => createOptionalChainExpr(expr)
        case "primitive_type_expr" => createPrimitiveTypeExpr(expr, exprBase)
        case "exclave_expr" => createExclaveExpr(expr, exprBase)
        case "return_expr" => createReturnExpr(expr)
        case "lit_const_expr" => createLitConstExpr(expr, exprBase)
        case "assign_expr" => createAssignExpr(expr)
        case "unary_expr" => createUnaryExpr(expr)
        case "while_expr" => createWhileExpr(expr)
        case "ref_expr" => createRefExpr(expr)
        case "binary_expr" => createBinaryExpr(expr)
        case "inc_or_dec_expr" => createIncOrDecExpr(expr)
        case "lambda_expr" => createLambdaExpr(expr)
        case "trailing_closure_expr" => createTrailingClosureExpr(expr)
        case "if_expr" => createIfExpr(expr)
        case "quote_expr" => createQuoteExpr(expr, exprBase)
        case "token_part" => createQuoteToken(expr)
        case "try_expr" => createTryExpr(expr, exprBase)
        case "jump_expr" => createJumpExpr(expr, exprBase)
        case "subscript_expr" => createSubscriptExpr(expr)
        case "range_expr" => createRangeExpr(expr)
        case "tuple_lit_expr" => createTupleLiteral(expr)
        case "array_lit_expr" => createArrayLiteral(expr)
        case "for_in_expr" => createForInExpr(expr)
        case "type_conv_expr" => createTypeConvExpr(expr)
        case "synchronized_expr" => createSynchronizedExpr(expr)
        case "spawn_expr" => createSpawnExpr(expr)
        case "do_while_expr" => createDoWhileExpr(expr)
        case "throw_expr" => createThrowExpr(expr)
        case "perform_expr" => createPerformExpr(expr)
        case "resume_expr" => createResumeExpr(expr)
        case "is_expr" => createIsExpr(expr)
        case "as_expr" => createAsExpr(expr)
        case "array_expr" => createArrayExpr(expr)
        case "match_expr" => createMatchExpr(expr, exprBase)
        case "let_pattern_destructor" => createLetPatternExpr(expr, exprBase)
        case "macro_expand_expr" => createMacroExpandExpr(expr)
        case _ => throw ParseASTException("Unsupported expr node kind: '${astKind}'.")
    }
    addPositionInfo(astNode, exprBase)
    return astNode
}

func createBlock(expr: ASTFormat_Expr): Expr {
    return generateBlock(expr.GetExprAsBlock())
}

func generateBlock(blockOption: Option<ASTFormat_Block>): Block {
    var block = match (blockOption) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var lCurl: Token = Token()
    if (isValidPosition(block.GetLeftCurlPos())) {
        lCurl = Token(TokenKind.LCURL).addPosition(block.GetLeftCurlPos())
    }
    var body = block.GetBody()
    var size = body.size
    var nodes: ArrayList<Node> = ArrayList<Node>()
    for (i in 0..size) {
        nodes.add(generateNode(body[i]))
    }
    var rCurl: Token = Token()
    if (isValidPosition(block.GetRightCurlPos())) {
        rCurl = Token(TokenKind.RCURL).addPosition(block.GetRightCurlPos())
    }
    var unSafe = Token()
    if (block.GetIsUnsafe()) {
        unSafe = Token(TokenKind.UNSAFE).addPosition(block.GetUnsafePos())
    }
    return Block(lCurl, nodes, rCurl, unSafe)
}

func createBinaryExpr(expr: ASTFormat_Expr): Expr {
    var biExpr = match (expr.GetExprAsBinaryExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var lexpr = generateExprAST(biExpr.GetLeftExpr())
    var rexpr = generateExprAST(biExpr.GetRightExpr())
    var op = Token(getTokenKind(biExpr.GetOperatorKind())).addPosition(biExpr.GetOperatorPos())
    return BinaryExpr(lexpr, op, rexpr)
}

func createUnaryExpr(expr: ASTFormat_Expr): Expr {
    var unExpr = match (expr.GetExprAsUnaryExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var childExpr = generateExprAST(unExpr.GetExpr())
    var op = Token(getTokenKind(unExpr.GetOperatorKind())).addPosition(unExpr.GetOperatorPos())
    return UnaryExpr(op, childExpr)
}

func createIsExpr(expr: ASTFormat_Expr): Expr {
    var isExpr = match (expr.GetExprAsIsExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var exprNode = generateExprAST(isExpr.GetExpr())
    var op = Token(TokenKind.IS).addPosition(isExpr.GetIsPos())
    var ty = generateTypeAST(isExpr.GetIsType())
    return IsExpr(exprNode, op, ty)
}

func createAsExpr(expr: ASTFormat_Expr): Expr {
    var asExpr = match (expr.GetExprAsAsExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var exprNode = generateExprAST(asExpr.GetExpr())
    var op = Token(TokenKind.AS).addPosition(asExpr.GetAsPos())
    var ty = generateTypeAST(asExpr.GetAsType())
    return AsExpr(exprNode, op, ty)
}

func createParenExpr(expr: ASTFormat_Expr): Expr {
    var parenExpr = match (expr.GetExprAsParenExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var childExpr = generateExprAST(parenExpr.GetExpr())
    var lParen = Token(TokenKind.LPAREN).addPosition(parenExpr.GetLeftParenPos())
    var rParen = Token(TokenKind.RPAREN).addPosition(parenExpr.GetRightParenPos())
    return ParenExpr(lParen, childExpr, rParen)
}

func createLitConstExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var litExpr = match (expr.GetExprAsLitConstExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var litConstKind = TokenKindHelper.getLiteralConstKind(litExpr.GetLiteralConstKind())
    if (litConstKind == TokenKind.STRING_LITERAL) {
        // Determine the TokenKind Based on StringKind
        litConstKind = TokenKindHelper.getStringKind(litExpr.GetStringKind())
        if (litExpr.GetIsSingleQuote() && litConstKind == TokenKind.STRING_LITERAL) {
            litConstKind = TokenKind.SINGLE_QUOTED_STRING_LITERAL
        }
    }
    var literal = Token(litConstKind, litExpr.GetLiteral()).addPosition(exprBase.GetBegin())
    if (litConstKind == TokenKind.UNIT_LITERAL) {
        literal = Token(TokenKind.UNIT_LITERAL).addPosition(exprBase.GetBegin())
    }
    literal.delimiterNum = litExpr.GetDelimiterNum()
    literal.isSingleQuote = litExpr.GetIsSingleQuote()
    return LitConstExpr(literal)
}

func createCallExpr(expr: ASTFormat_Expr): Expr {
    var callExpr = match (expr.GetExprAsCallExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var childExpr = generateExprAST(callExpr.GetBaseFunc())
    var lParen = Token(TokenKind.LPAREN).addPosition(callExpr.GetLeftParenPos())
    let argSrc = callExpr.GetArgs()
    var args = ArrayList<Argument>(argSrc.size, {i => createArgument(argSrc[i])})
    var rParen = Token(TokenKind.RPAREN).addPosition(callExpr.GetRightParenPos())
    var call = CallExpr(childExpr, lParen, args, rParen)
    call.modal = createModalInfo(callExpr.GetModal())
    return call
}

func createRefExpr(expr: ASTFormat_Expr): Expr {
    return generateRefExpr(expr.GetExprAsRefExpr())
}

func generateRefExpr(ref: Option<ASTFormat_RefExpr>) {
    var refExpr = match (ref) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var identifier = match (refExpr.GetRef()) {
        case Some(v) => match (v.GetIdentifier()) {
            case "this" => Token(TokenKind.THIS).addPosition(v.GetIdentifierPos())
            case "super" => Token(TokenKind.SUPER).addPosition(v.GetIdentifierPos())
            case _ =>
                if (refExpr.GetIsQuoteDollar()) {
                    Token(TokenKind.DOLLAR_IDENTIFIER, "$" + v.GetIdentifier()).addPosition(v.GetIdentifierPos())
                } else {
                    Token(TokenKind.IDENTIFIER, v.GetIdentifier()).addPosition(v.GetIdentifierPos())
                }
        }
        case None => throw ParseASTException("'RefExpr' has no reference.")
    }

    var lAngle = Token(TokenKind.LT).addPosition(refExpr.GetLeftAnglePos())
    var typeArgs: ArrayList<TypeNode> = ArrayList<TypeNode>()
    var typeArgument = refExpr.GetTypeArguments()
    let commas = Tokens()
    for (i in 0..typeArgument.size) {
        typeArgs.add(generateTypeAST(typeArgument[i]))
        match (typeArgument[i]?.GetBase()?.GetCommaPos()) {
            case Some(position) where isValidPosition(position) => commas.append(
                Token(TokenKind.COMMA).addPosition(position))
            case _ => ()
        }
    }
    var rAngle = Token(TokenKind.GT).addPosition(refExpr.GetRightAnglePos())
    return RefExpr(identifier, lAngle, typeArgs, commas, rAngle)
}

func createReturnExpr(expr: ASTFormat_Expr): Expr {
    var retExpr = match (expr.GetExprAsReturnExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.RETURN).addPosition(retExpr.GetReturnPos())
    var exprNode = try {
        Some<Expr>(generateExprAST(retExpr.GetExpr()))
    } catch (e: ParseASTException) {
        None<Expr>
    }
    return ReturnExpr(keyWord, exprNode)
}

func createThrowExpr(expr: ASTFormat_Expr): Expr {
    var throwExpr = match (expr.GetExprAsThrowExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.THROW).addPosition(getNodeBeginPos(throwExpr.GetBase()))
    var exprNode = generateExprAST(throwExpr.GetExpr())
    return ThrowExpr(keyWord, exprNode)
}

func createPerformExpr(expr: ASTFormat_Expr): Expr {
    var performExpr = match (expr.GetExprAsPerformExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.PERFORM).addPosition(getNodeBeginPos(performExpr.GetBase()))
    var exprNode = generateExprAST(performExpr.GetExpr())
    return PerformExpr(keyWord, exprNode)
}

func createResumeExpr(expr: ASTFormat_Expr): Expr {
    var resumeExpr = match(expr.GetExprAsResumeExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var resume_ = Token(TokenKind.RESUME).addPosition(getNodeBeginPos(resumeExpr.GetBase()))
    var with_ = None<Token>
    var withExpr_ = None<Expr>
    match(resumeExpr.GetWithExpr()) {
        case Some(v) =>
            with_ = Some(Token(TokenKind.WITH).addPosition(resumeExpr.GetWithPos()))
            withExpr_ = Some(generateExprAST(resumeExpr.GetWithExpr()))
        case None => ()
    }
    var throwing_ = None<Token>
    var throwingExpr_ = None<Expr>
    match(resumeExpr.GetThrowingExpr()) {
        case Some(v) =>
            throwing_ = Some(Token(TokenKind.THROWING).addPosition(resumeExpr.GetThrowingPos()))
            throwingExpr_ = Some(generateExprAST(resumeExpr.GetThrowingExpr()))
        case None => ()
    }
    return ResumeExpr(resume_, with_, withExpr_, throwing_, throwingExpr_)
}

func createAssignExpr(expr: ASTFormat_Expr): Expr {
    var assignExpr = match (expr.GetExprAsAssignExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var lexpr = generateExprAST(assignExpr.GetLeftValue())
    var rexpr = generateExprAST(assignExpr.GetRightExpr())
    var op = Token(getTokenKind(assignExpr.GetAssignOp())).addPosition(assignExpr.GetAssignPos())
    return AssignExpr(lexpr, op, rexpr)
}

func createMemberAccess(expr: ASTFormat_Expr): Expr {
    var ma = match (expr.GetExprAsMemberAccess()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var postfixExpr = generateExprAST(ma.GetBaseExpr())
    var dot = Token(TokenKind.DOT).addPosition(ma.GetDotPos())
    var ident = Token(TokenKind.IDENTIFIER, ma.GetField()).addPosition(ma.GetFieldPos())
    var lAngle = Token(TokenKind.LT).addPosition(ma.GetLeftAnglePos())
    var typeArgs: ArrayList<TypeNode> = ArrayList<TypeNode>()
    var typeArgument = ma.GetTypeArguments()
    let commas = Tokens()
    for (i in 0..typeArgument.size) {
        typeArgs.add(generateTypeAST(typeArgument[i]))
        match (typeArgument[i]?.GetBase()?.GetCommaPos()) {
            case Some(position) where isValidPosition(position) => commas.append(
                Token(TokenKind.COMMA).addPosition(position))
            case _ => ()
        }
    }
    var rAngle = Token(TokenKind.GT).addPosition(ma.GetRightAnglePos())
    return MemberAccess(postfixExpr, dot, ident, lAngle, typeArgs, commas, rAngle)
}

func createOptionalExpr(expr: ASTFormat_Expr): Expr {
    var oe = match (expr.GetExprAsOptionalExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var baseExpr = generateExprAST(oe.GetBaseExpr())
    var quest = Token(TokenKind.QUEST).addPosition(oe.GetQuestPos())
    return OptionalExpr(baseExpr, quest)
}

func createOptionalChainExpr(expr: ASTFormat_Expr): Expr {
    var oce = match (expr.GetExprAsOptionalChainExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    return generateExprAST(oce.GetExpr())
}

func createIfExpr(expr: ASTFormat_Expr): Expr {
    var ie = match (expr.GetExprAsIfExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var ifTk = Token(TokenKind.IF).addPosition(ie.GetIfPos())
    var elseTk = Token()
    if (ie.GetHasElse()) {
        elseTk = Token(TokenKind.ELSE).addPosition(ie.GetElsePos())
    }
    var lParen = Token(TokenKind.LPAREN).addPosition(ie.GetLeftParenPos())
    var cond = generateExprAST(ie.GetCondExpr())
    var rParen = Token(TokenKind.RPAREN).addPosition(ie.GetRightParenPos())
    var ifBlock = generateBlock(ie.GetBody())
    var elseExpr = try {
        Some<Expr>(generateExprAST(ie.GetElseBody()))
    } catch (e: ParseASTException) {
        None<Expr>
    }
    return IfExpr(ifTk, lParen, cond, rParen, ifBlock, elseTk, elseExpr)
}

func createLetPatternExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase) {
    var letTk = Token(TokenKind.LET).addPosition(exprBase.GetBegin())
    var letPattern = expr.GetExprAsLetPatternDestructor().getOrThrow()
    var pattern = generatePatternAST(letPattern.GetPatterns()[0])
    var backArrow = Token(TokenKind.BACKARROW).addPosition(letPattern.GetBackarrowPos())
    var exprNode = generateExprAST(letPattern.GetInitializer())
    let bitOrs = Tokens()
    return LetPatternExpr(letTk, pattern, backArrow, exprNode)
}

func generateMatchCase(mc: Option<ASTFormat_MatchCase>) {
    var matchCase = match (mc) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var base = match (matchCase.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.CASE).addPosition(base.GetBegin())
    let patSrc = matchCase.GetPatterns()
    var patterns = ArrayList<Pattern>(patSrc.size, {i => generatePatternAST(patSrc[i])})
    let bitOrs = Tokens()
    for (bitOrPos in matchCase.GetBitOrPosVec()) {
        bitOrs.append(Token(TokenKind.BITOR).addPosition(bitOrPos))
    }
    var whereTk = Token()
    var patternGuard = try {
        var pg = generateExprAST(matchCase.GetPatternguard())
        whereTk = Token(TokenKind.WHERE).addPosition(matchCase.GetIfPos())
        Some<Expr>(pg)
    } catch (e: ParseASTException) {
        None<Expr>
    }
    var arrow = Token(TokenKind.DOUBLE_ARROW).addPosition(matchCase.GetArrowPos())
    var block = generateBlock(matchCase.GetExprOrDecls())
    return MatchCase(keyWord, patterns, bitOrs, whereTk, patternGuard, arrow, block)
}

func generateMatchCaseOther(mco: Option<ASTFormat_MatchCaseOther>) {
    var matchCaseOther = match (mco) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var base = match (matchCaseOther.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.CASE).addPosition(base.GetBegin())
    // in matchCaseOther, a boolean-typed conditional expression is mandatory
    var expr = Some<Expr>(generateExprAST(matchCaseOther.GetMatchExpr()))
    var arrow = Token(TokenKind.DOUBLE_ARROW).addPosition(matchCaseOther.GetArrowPos())
    var block = generateBlock(matchCaseOther.GetExprOrDecls())
    return MatchCase(keyWord, expr, arrow, block)
}

func createMatchExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var me = match (expr.GetExprAsMatchExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord: Token = Token(TokenKind.MATCH).addPosition(exprBase.GetBegin())
    var lParen: Token = Token()
    var rParen: Token = Token()
    var selector: Option<Expr> = None<Expr>
    // in pattern matching mode, () and selector are needed
    if (me.GetMatchMode()) {
        lParen = Token(TokenKind.LPAREN).addPosition(me.GetLeftParenPos())
        rParen = Token(TokenKind.RPAREN).addPosition(me.GetRightParenPos())
        selector = Some<Expr>(generateExprAST(me.GetSelector()))
    }
    var lCurl = Token(TokenKind.LCURL).addPosition(me.GetLeftCurlPos())
    var matchcases: ArrayList<MatchCase> = ArrayList<MatchCase>()
    // matchCases and matchCaseOthers cannot be not empty at the same time
    for (mc in me.GetMatchCases()) {
        matchcases.add(generateMatchCase(mc))
    }
    for (mco in me.GetMatchCaseOthers()) {
        matchcases.add(generateMatchCaseOther(mco))
    }
    var rCurl = Token(TokenKind.RCURL).addPosition(me.GetRightCurlPos())
    return MatchExpr(keyWord, lParen, selector, rParen, lCurl, matchcases, rCurl)
}

func createWhileExpr(expr: ASTFormat_Expr): Expr {
    var whileExpr = match (expr.GetExprAsWhileExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.WHILE).addPosition(whileExpr.GetWhilePos())
    var lParen = Token(TokenKind.LPAREN).addPosition(whileExpr.GetLeftParenPos())
    var cond = generateExprAST(whileExpr.GetCondExpr())
    var rParen = Token(TokenKind.RPAREN).addPosition(whileExpr.GetRightParenPos())
    var block = generateBlock(whileExpr.GetBody())
    return WhileExpr(keyWord, lParen, cond, rParen, block)
}

func createDoWhileExpr(expr: ASTFormat_Expr): Expr {
    var doWhileExpr = match (expr.GetExprAsDoWhileExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var doTK: Token = Token(TokenKind.DO).addPosition(doWhileExpr.GetDoPos())
    var block = generateBlock(doWhileExpr.GetBody())
    var whileTK: Token = Token(TokenKind.WHILE).addPosition(doWhileExpr.GetWhilePos())
    var lParen = Token(TokenKind.LPAREN).addPosition(doWhileExpr.GetLeftParenPos())
    var cond = generateExprAST(doWhileExpr.GetCondExpr())
    var rParen = Token(TokenKind.RPAREN).addPosition(doWhileExpr.GetRightParenPos())
    return DoWhileExpr(doTK, block, whileTK, lParen, cond, rParen)
}

func createLambdaExpr(lambdaExpr: ASTFormat_LambdaExpr): LambdaExpr {
    var funcBody = match (lambdaExpr.GetBody()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var funcParams: ArrayList<FuncParam> = generateFuncParams(funcBody)
    var blockNode = match (funcBody.GetBody()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var base = match (lambdaExpr.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var lCurl = Token(TokenKind.LCURL).addPosition(base.GetBegin())
    var nodes: ArrayList<Node> = ArrayList<Node>()
    var body = blockNode.GetBody()
    for (i in 0..body.size) {
        nodes.add(generateNode(body[i]))
    }
    var doubleArrow = Token()
    if (isValidPosition(funcBody.GetArrowPos())) {
        doubleArrow = Token(TokenKind.DOUBLE_ARROW).addPosition(funcBody.GetArrowPos())
    }
    var rCurl = Token(TokenKind.RCURL).addPosition(blockNode.GetRightCurlPos())
    return LambdaExpr(lCurl, funcParams, doubleArrow, nodes, rCurl, lambdaExpr.GetMockSupported())
}

func createLambdaExpr(expr: ASTFormat_Expr): Expr {
    var lambdaExpr = match (expr.GetExprAsLambdaExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    return createLambdaExpr(lambdaExpr)
}

func createSpawnExpr(expr: ASTFormat_Expr): Expr {
    var spawnExpr = match (expr.GetExprAsSpawnExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.SPAWN).addPosition(spawnExpr.GetSpawnPos())
    var lParen = Token()
    var rParen = Token()
    var context: Option<Expr> = None<Expr>
    if (spawnExpr.GetHasArg()) {
        lParen = Token(TokenKind.LPAREN).addPosition(spawnExpr.GetLeftParenPos())
        context = try {
            Some<Expr>(generateExprAST(spawnExpr.GetSpawnArgExpr()))
        } catch (e: ParseASTException) {
            None<Expr>
        }
        rParen = Token(TokenKind.RPAREN).addPosition(spawnExpr.GetRightParenPos())
    }
    var task = match (generateExprAST(spawnExpr.GetTaskExpr()) as LambdaExpr) {
        case Some(v) => v
        case None => throw ParseASTException("The task of 'SpawnExpr' is not a 'LambdaExpr'.")
    }
    return SpawnExpr(keyWord, lParen, context, rParen, task)
}

func createSynchronizedExpr(expr: ASTFormat_Expr): Expr {
    var syncExpr = match (expr.GetExprAsSynchronizedExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyWord = Token(TokenKind.SYNCHRONIZED).addPosition(syncExpr.GetSyncPos())
    var lParen = Token(TokenKind.LPAREN).addPosition(syncExpr.GetLeftParenPos())
    var mutex = generateExprAST(syncExpr.GetMutexExpr())
    var rParen = Token(TokenKind.RPAREN).addPosition(syncExpr.GetRightParenPos())
    var block = generateBlock(syncExpr.GetBody())
    return SynchronizedExpr(keyWord, lParen, mutex, rParen, block)
}

func createTrailingClosureExpr(expr: ASTFormat_Expr): Expr {
    var trailExpr = match (expr.GetExprAsTrailingClosureExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var exprNode = generateExprAST(trailExpr.GetExpr())
    var lambdaExpr = createLambdaExpr(trailExpr.GetLambda().getOrThrow())
    return TrailingClosureExpr(exprNode, lambdaExpr)
}

func createTypeConvExpr(expr: ASTFormat_Expr): Expr {
    var typeConvExpr = match (expr.GetExprAsTypeConvExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }

    var ty = (generateTypeAST(typeConvExpr.GetType()) as PrimitiveType).getOrThrow()
    var lParen = Token(TokenKind.LPAREN).addPosition(typeConvExpr.GetLeftParenPos())
    var exprNode = generateExprAST(typeConvExpr.GetExpr())
    var rParen = Token(TokenKind.RPAREN).addPosition(typeConvExpr.GetRightParenPos())
    return TypeConvExpr(ty, lParen, exprNode, rParen)
}

func createForInExpr(expr: ASTFormat_Expr): Expr {
    var forInExpr = match (expr.GetExprAsForInExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var forTk = Token(TokenKind.FOR).addPosition(getNodeBeginPos(forInExpr.GetBase()))
    var lParen = Token(TokenKind.LPAREN).addPosition(forInExpr.GetLeftParenPos())
    var pattern = generatePatternAST(forInExpr.GetPattern())
    var inTk = Token(TokenKind.IN).addPosition(forInExpr.GetInPos())
    var inExpr = generateExprAST(forInExpr.GetInExpr())
    var whereTk = Token()
    var patternGuard = try {
        var pg = generateExprAST(forInExpr.GetPatternGuard())
        whereTk = Token(TokenKind.WHERE).addPosition(forInExpr.GetIfPos())
        Some<Expr>(pg)
    } catch (e: ParseASTException) {
        None<Expr>
    }
    var rParen = Token(TokenKind.RPAREN).addPosition(forInExpr.GetRightParenPos())
    var block = generateBlock(forInExpr.GetBody())
    return ForInExpr(forTk, lParen, pattern, inTk, inExpr, whereTk, patternGuard, rParen, block)
}

func createPrimitiveTypeExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var primitiveTypeExpr = match (expr.GetExprAsPrimitiveTypeExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let typeKind = primitiveTypeExpr.GetKind()
    let beginPos = exprBase.GetBegin()
    var kind = Token(TokenKindHelper.getPrimitiveTypeTokenKind(typeKind)).addPosition(beginPos)
    var primExpr = PrimitiveTypeExpr(kind)
    primExpr.modal = createModalInfo(primitiveTypeExpr.GetModal())
    return primExpr
}

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

func createArrayLiteral(expr: ASTFormat_Expr): Expr {
    var arrayLiteral = match (expr.GetExprAsArrayLit()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let lSquare: Token = Token(TokenKind.LSQUARE).addPosition(arrayLiteral.GetLeftCurlPos())
    let childs = arrayLiteral.GetChildren()
    var elements = ArrayList<Expr>(childs.size, {i => generateExprAST(childs[i])})
    let rSquare: Token = Token(TokenKind.RSQUARE).addPosition(arrayLiteral.GetRightCurlPos())
    var commas = Tokens()
    for (pos in arrayLiteral.GetCommaPosVec()) {
        commas.append(Token(COMMA).addPosition(pos))
    }
    return ArrayLiteral(lSquare, elements, commas, rSquare)
}

func createTupleLiteral(expr: ASTFormat_Expr): Expr {
    var tupleLiteral = match (expr.GetExprAsTupleLit()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let lParen: Token = Token(TokenKind.LPAREN).addPosition(tupleLiteral.GetLeftParenPos())
    let childs = tupleLiteral.GetChildren()
    var elements = ArrayList<Expr>(childs.size, {i => generateExprAST(childs[i])})
    let rParen: Token = Token(TokenKind.RPAREN).addPosition(tupleLiteral.GetRightParenPos())
    var commas = Tokens()
    for (pos in tupleLiteral.GetCommaPosVec()) {
        commas.append(Token(COMMA).addPosition(pos))
    }
    return TupleLiteral(lParen, elements, commas, rParen)
}

func createRangeExpr(expr: ASTFormat_Expr): Expr {
    var rangeExpr = match (expr.GetExprAsRangeExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var start = try {
        Some<Expr>(generateExprAST(rangeExpr.GetStartExpr()))
    } catch (e: ParseASTException) {
        None<Expr>
    }
    var kind = TokenKind.RANGEOP
    if (rangeExpr.GetIsClosed()) {
        kind = TokenKind.CLOSEDRANGEOP
    }
    var rangeOp = Token(kind).addPosition(rangeExpr.GetRangePos())
    var stop = try {
        Some<Expr>(generateExprAST(rangeExpr.GetStopExpr()))
    } catch (e: ParseASTException) {
        None<Expr>
    }
    var colon: Token = Token()
    var step = try {
        var stepExpr = generateExprAST(rangeExpr.GetStepExpr())
        colon = Token(TokenKind.COLON).addPosition(rangeExpr.GetColonPos())
        Some<Expr>(stepExpr)
    } catch (e: ParseASTException) {
        None<Expr>
    }
    return RangeExpr(start, rangeOp, stop, colon, step)
}

func createSubscriptExpr(expr: ASTFormat_Expr): Expr {
    var subscriptExpr = match (expr.GetExprAsSubscriptExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var postfixExpr = generateExprAST(subscriptExpr.GetBaseExpr())
    var lSquare: Token = Token(TokenKind.LSQUARE).addPosition(subscriptExpr.GetLeftSquarePos())
    let childs = subscriptExpr.GetIndexExprs()
    var elements = ArrayList<Expr>(childs.size, {i => generateExprAST(childs[i])})
    var rSquare: Token = Token(TokenKind.RSQUARE).addPosition(subscriptExpr.GetRightSquarePos())
    return SubscriptExpr(postfixExpr, lSquare, elements, rSquare)
}

func createJumpExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var jumpExpr = match (expr.GetExprAsJumpExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var tk = TokenKind.BREAK
    if (!jumpExpr.GetIsBreak()) {
        tk = TokenKind.CONTINUE
    }
    var kind = Tokens().append(Token(tk).addPosition(exprBase.GetBegin()))
    return JumpExpr(kind)
}

func createIncOrDecExpr(expr: ASTFormat_Expr): Expr {
    var incOrDecExpr = match (expr.GetExprAsIncOrDecExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var kind = Token(getTokenKind(incOrDecExpr.GetOperatorKind())).addPosition(incOrDecExpr.GetOperatorPos())
    var exprNode = generateExprAST(incOrDecExpr.GetExpr())
    return IncOrDecExpr(kind, exprNode)
}

func createTryExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var tryExpr = match (expr.GetExprAsTryExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var tryToken: Token = Token(TokenKind.TRY).addPosition(exprBase.GetBegin())
    let childs = tryExpr.GetResourceSpec()
    var resourceSpec = ArrayList<VarDecl>(childs.size, {i => createVarDeclNode(childs[i])})
    var resourceSpecLParen = Token(TokenKind.LPAREN)
    if (isValidPosition(tryExpr.GetResourceSpecLparenPos())) {
        resourceSpecLParen = resourceSpecLParen.addPosition(tryExpr.GetResourceSpecLparenPos())
    }
    var resourceSpecRParen = Token(TokenKind.RPAREN)
    if (isValidPosition(tryExpr.GetResourceSpecRparenPos())) {
        resourceSpecRParen = resourceSpecRParen.addPosition(tryExpr.GetResourceSpecRparenPos())
    }
    var resourceSpecCommas = Tokens()
    for (commaPos in tryExpr.GetResourceSpecCommaPosVec() where isValidPosition(commaPos)) {
        resourceSpecCommas.append(Token(TokenKind.COMMA).addPosition(commaPos))
    }
    var tryBlock = generateBlock(tryExpr.GetTryBlock())
    var catchPatterns = ArrayList<Pattern>(tryExpr.GetCatchPatterns().size)
    var catches = Tokens()
    for (pos in tryExpr.GetCatchPosVec() where isValidPosition(pos)) {
        catches.append(Token(TokenKind.CATCH).addPosition(pos))
    }
    var catchLParens = Tokens()
    for (pos in tryExpr.GetCatchLeftParenPosVec() where isValidPosition(pos)) {
        catchLParens.append(Token(TokenKind.LPAREN).addPosition(pos))
    }
    var catchRParens = Tokens()
    for (pos in tryExpr.GetCatchRightParenPosVec() where isValidPosition(pos)) {
        catchRParens.append(Token(TokenKind.RPAREN).addPosition(pos))
    }
    for (cp in tryExpr.GetCatchPatterns()) {
        catchPatterns.add(generatePatternAST(cp))
    }
    let catchBlocks = tryExpr.GetCatchBlocks()
    var cbs: ArrayList<Block> = ArrayList<Block>(catchBlocks.size, {i => generateBlock(catchBlocks[i])})
    var handlers = ArrayList<Handler>(tryExpr.GetHandlers().size);
    for (item in tryExpr.GetHandlers()) {
        var fbHandler = match (item) {
            case Some(v) => v
            case None => throw ParseASTException("Failed to get a handler in 'TryExpr'.")
        }
        var handle_ = Token(TokenKind.HANDLE).addPosition(fbHandler.GetHandlerPos())
        var commandPattern = generatePatternAST(fbHandler.GetCommandPattern())
        var handleBlock = generateBlock(fbHandler.GetHandleBlock())
        var handler = Handler(handle_, commandPattern, handleBlock)
        handlers.add(handler)
    }
    var finTk = Token()
    var finallyBlock = try {
        var fb = generateBlock(tryExpr.GetFinallyBlock())
        finTk = Token(TokenKind.FINALLY).addPosition(tryExpr.GetFinallyPos())
        Some<Block>(fb)
    } catch (e: ParseASTException) {
        None<Block>
    }
    return TryExpr(tryToken, resourceSpecLParen, resourceSpec, resourceSpecCommas, resourceSpecRParen, tryBlock, catches,
        catchLParens, catchRParens, catchPatterns, cbs, finTk, finallyBlock, handlers)
}

func createQuoteExpr(expr: ASTFormat_Expr, exprBase: ASTFormat_NodeBase): Expr {
    var quoteExpr = match (expr.GetExprAsQuoteExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let lParen: Token = Token(TokenKind.LPAREN).addPosition(quoteExpr.GetLeftParenPos())
    let childs = quoteExpr.GetExprs()
    var elements = ArrayList<Expr>(childs.size, {i => generateExprAST(childs[i])})
    let rParen: Token = Token(TokenKind.RPAREN).addPosition(quoteExpr.GetRightParenPos())
    var keyword: Token = Token(TokenKind.QUOTE).addPosition(exprBase.GetBegin())
    return QuoteExpr(keyword, lParen, elements, rParen)
}

func createQuoteToken(expr: ASTFormat_Expr): Expr {
    var tkp = match (expr.GetExprAsTokenPart()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var tks = Tokens()
    for (tk in tkp.GetTokens()) {
        match (tk) {
            case Some(v) => 
                let isSingle = v.GetIsSingleQuote()
                var tokenKind = getTokenKind(v.GetKind())
                if (tokenKind == STRING_LITERAL && isSingle == true) {
                    tokenKind = SINGLE_QUOTED_STRING_LITERAL
                }
                var token = Token(tokenKind, v.GetValue()).addPosition(v.GetPos())
                token.delimiterNum = UInt16(v.GetDelimiterNum())
                token.isSingleQuote = isSingle
                if (v.GetHasEscape()) {
                    tks.append(Token(TokenKind.ILLEGAL, "\\", v.GetPos().fileId, v.GetPos().line, v.GetPos().column - 1))
                }
                tks.append(token)
            case None => ()
        }
    }
    return QuoteToken(tks)
}

func createWildcardExpr(exprBase: ASTFormat_NodeBase): Expr {
    var keyword: Tokens = Tokens().append(Token(TokenKind.WILDCARD).addPosition(exprBase.GetBegin()))
    return WildcardExpr(keyword)
}

func createArrayExpr(expr: ASTFormat_Expr): Expr {
    var arrayExpr = match (expr.GetExprAsArrayExpr()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var ty = match (generateTypeAST(arrayExpr.GetType()) as VArrayType) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var lParen: Token = Token(TokenKind.LPAREN).addPosition(arrayExpr.GetLeftParenPos())
    var args: ArrayList<Argument> = ArrayList<Argument>()
    for (arg in arrayExpr.GetArgs()) {
        args.add(createArgument(arg))
    }
    var rParen: Token = Token(TokenKind.RPAREN).addPosition(arrayExpr.GetRightParenPos())
    return VArrayExpr(ty, lParen, args, rParen)
}

func createMacroExpandExpr(expr: ASTFormat_Expr) {
    var me = match (expr.GetExprAsMacroExpandExpr()) {
        case Some(v) => v
        case None => throw ParseASTException("Failed to get the 'MacroExpandExpr' node.")
    }
    return match (createMacroExpand(me.GetInvocation()) as Expr) {
        case Some(v) => v
        case None => throw ParseASTException("Failed to create the 'MacroExpandExpr' node.")
    }
}
