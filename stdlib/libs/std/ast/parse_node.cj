/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

import std.collection.ArrayList

let EXPR_LIST: Array<String> = [
    "block",
    "wildcard_expr",
    "call_expr",
    "paren_expr",
    "member_access_expr",
    "optional_expr",
    "primitive_type_expr",
    "lit_const_expr",
    "interpolation_expr",
    "unary_expr",
    "assign_expr",
    "binary_expr",
    "while_expr",
    "ref_expr",
    "inc_or_dec_expr",
    "optional_chain_expr",
    "return_expr",
    "str_interpolation_expr",
    "subscript_expr",
    "is_expr",
    "as_expr",
    "range_expr",
    "array_lit_expr",
    "array_expr",
    "tuple_lit_expr",
    "match_expr",
    "if_expr",
    "let_pattern_destructor",
    "token_part",
    "quote_expr",
    "try_expr",
    "jump_expr",
    "lambda_expr",
    "trailing_closure_expr",
    "for_in_expr",
    "do_while_expr",
    "type_conv_expr",
    "throw_expr",
    "perform_expr",
    "resume_expr",
    "spawn_expr",
    "synchronized_expr",
    "macro_expand_expr",
    "exclave_expr"
]
let DECL_LIST: Array<String> = [
    "main_decl",
    "func_decl",
    "macro_decl",
    "class_decl",
    "interface_decl",
    "enum_decl",
    "struct_decl",
    "type_alias_decl",
    "primary_ctor_decl",
    "var_decl",
    "prop_decl",
    "extend_decl",
    "func_param",
    "var_with_pattern_decl",
    "macro_expand_decl"
]
let TYPE_LIST: Array<String> = [
    "ref_type",
    "qualified_type",
    "option_type",
    "constant_type",
    "varray_type",
    "primitive_type",
    "paren_type",
    "func_type",
    "tuple_type",
    "this_type"
]
let PATTERN_LIST: Array<String> = [
    "var_pattern",
    "const_pattern",
    "tuple_pattern",
    "enum_pattern",
    "var_or_enum_pattern",
    "type_pattern",
    "except_type_pattern",
    "effect_type_pattern",
    "wildcard_pattern"
]

public func parseProgram(input: Tokens): Program {
    let node = unsafe {
        try {
            parse(input, {
                p: CPointer<UInt8> => return CJ_AST_ParseTopLevel(match (MACRO_OBJECT.get()) {
                    case Some(ptr) => ptr
                    case None => CPointer<Unit>()
                }, p)
            })
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse program.")
        }
    }
    return match (createProgram(node.GetRootAsFile()) as Program) {
        case Some(v) => v
        case None => throw ParseASTException("Failed to obtain the 'Program' node.")
    }
}

func addPositionInfo(node: Node, nodeBase: ASTFormat_NodeBase) {
    var begin = nodeBase.GetBegin()
    var end = nodeBase.GetEnd()
    var astKind: String = nodeBase.GetAstKind()
    node.beginPos = Position(begin.fileId, begin.line, begin.column)
    node.endPos = Position(end.fileId, end.line, end.column)
    node.astKind = astKind
}

func generateNode(n: Option<ASTFormat_Node>): Node {
    var node = match (n) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var nodeBase = match (node.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var astKind: String = nodeBase.GetAstKind()
    if (EXPR_LIST.contains(astKind)) {
        return generateExprAST(node.GetRootAsExpr())
    }
    if (DECL_LIST.contains(astKind)) {
        return generateDeclAST(node.GetRootAsDecl())
    }
    if (PATTERN_LIST.contains(astKind)) {
        return generatePatternAST(node.GetRootAsPattern())
    }
    var astNode = match (astKind) {
        case "file" => createProgram(node.GetRootAsFile())
        case "features_directive" => createFeatureHeader(node.GetRootAsFeaturesDirective()) ?? throw ParseASTException("Failed to parse the '${astKind}' node.")
        case "package_spec" => createPackageHeader(node.GetRootAsPackageSpec())
        case "import_spec" => createImportList(node.GetRootAsImportSpec())
        case _ => throw ParseASTException("Unsupported node kind: '${astKind}'.")
    }
    addPositionInfo(astNode, nodeBase)
    return astNode
}

func createAnnotation(anno: Option<ASTFormat_Annotation>): Annotation {
    var annotation = match (anno) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let atKind = if (annotation.GetIsCompileTimeVisible()) {
        TokenKind.AT_EXCL
    } else {
        TokenKind.AT
    }
    var at = Token(atKind).addPosition(getNodeBeginPos(annotation.GetBase()))
    var identifier = Token(TokenKind.IDENTIFIER, annotation.GetIdentifier()).addPosition(annotation.GetIdentPos())
    var lSquare = Token(TokenKind.LSQUARE).addPosition(annotation.GetLeftSquarePos())
    var rSquare = Token(TokenKind.RSQUARE).addPosition(annotation.GetRightSquarePos())
    var args: ArrayList<Argument> = ArrayList<Argument>()
    for (arg in annotation.GetArgs()) {
        args.add(createArgument(arg))
    }
    var attrs: Tokens = Tokens()
    for (attr in annotation.GetAttrs()) {
        attrs.append(Token(TokenKind.IDENTIFIER, attr.getOrThrow()))
    }
    var cond = match (annotation.GetCondExpr()) {
        case Some(v) => Some<Expr>(generateExprAST(annotation.GetCondExpr()))
        case None => None<Expr>
    }
    return Annotation(at, identifier, lSquare, args, rSquare, attrs, cond)
}

func createModifier(modifier: Option<ASTFormat_Modifier>): Modifier {
    var mod = match (modifier) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var kind = Token(getTokenKind(mod.GetKind())).addPosition(getNodeBeginPos(mod.GetBase()))
    return Modifier(kind)
}

func createArgument(arg: Option<ASTFormat_FuncArg>): Argument {
    var argument = match (arg) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var nodeBase = match (argument.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var inout_: Token = Token()
    if (argument.GetWithInout()) {
        inout_ = Token(TokenKind.INOUT).addPosition(nodeBase.GetBegin())
    }
    var identifier: Token = Token(TokenKind.IDENTIFIER, argument.GetName()).addPosition(argument.GetNamePos())
    var colon: Token = Token()
    if (isValidPosition(argument.GetColonPos())) {
        colon = Token(TokenKind.COLON).addPosition(argument.GetColonPos())
    }
    var expr: Expr = generateExprAST(argument.GetExpr())
    var comma: Token = Token()
    if (isValidPosition(argument.GetCommaPos())) {
        comma = Token(TokenKind.COMMA).addPosition(argument.GetCommaPos())
    }
    var argumentObj = Argument(inout_, identifier, colon, expr, comma)
    addPositionInfo(argumentObj, nodeBase)
    return argumentObj
}

func generateGenericParamTk(gp: Option<ASTFormat_GenericParamDecl>): (Token, Token) {
    var genericParam = match (gp) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var ident = match (genericParam.GetBase()) {
        case Some(v) => Token(TokenKind.IDENTIFIER, v.GetIdentifier()).addPosition(v.GetIdentifierPos())
        case None => throw ParseASTException()
    }
    var comma: Token = Token()
    if (isValidPosition(genericParam.GetCommaPos())) {
        comma = Token(TokenKind.COMMA).addPosition(genericParam.GetCommaPos())
    }
    return (ident, comma)
}

func createGenericParam(gic: Option<ASTFormat_Generic>): Option<GenericParam> {
    var generic = match (gic) {
        case Some(v) => v
        case None => return None
    }
    if (generic.GetTypeParameters().isEmpty()) {
        return None
    }
    var lAngle: Token = Token()
    if (isValidPosition(generic.GetLeftAnglePos())) {
        lAngle = Token(TokenKind.LT).addPosition(generic.GetLeftAnglePos())
    }
    var idents: Tokens = Tokens()
    var commas: Tokens = Tokens()
    for (gp in generic.GetTypeParameters()) {
        var (ident, comma) = generateGenericParamTk(gp)
        idents.append(ident)
        if (isValidToken(comma)) {
            commas.append(comma)
        }
    }
    var rAngle: Token = Token()
    if (isValidPosition(generic.GetRightAnglePos())) {
        rAngle = Token(TokenKind.GT).addPosition(generic.GetRightAnglePos())
    }
    return Some(GenericParam(lAngle, idents, rAngle, commas))
}

func createGenericConstraint(flag: Bool, cons: Option<ASTFormat_GenericConstraint>): GenericConstraint {
    var constraint = match (cons) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var keyword = Token()
    if (flag) {
        keyword = Token(TokenKind.WHERE).addPosition(constraint.GetWherePos())
    }
    var ty: TypeNode = createRefType(constraint.GetType(), ASTFormat_NodeBase(Array<UInt8>(0, repeat: 0), 0))
    var upbound: Token = Token(TokenKind.UPPERBOUND).addPosition(constraint.GetOperatorPos())
    var upperBounds: ArrayList<TypeNode> = ArrayList<TypeNode>()
    for (ups in constraint.GetUpperBound()) {
        match (generateTypeAST(ups) as TypeNode) {
            case Some(v) => upperBounds.add(v)
            case None => throw ParseASTException()
        }
    }
    let bitAnds = Tokens()
    for (bitAndPos in constraint.GetBitAndPosVec()) {
        bitAnds.append(Token(TokenKind.BITAND).addPosition(bitAndPos))
    }
    return GenericConstraint(keyword, ty, upbound, upperBounds, bitAnds)
}

func createMacroExpand(nodeInvocation: Option<ASTFormat_MacroInvocation>, isDecl!: Bool = false,
    isFuncParam!: Bool = false): Node {
    var invocation = match (nodeInvocation) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var pos = invocation.GetAtPos()
    var key = Token(TokenKind.AT).addPosition(pos)
    var packageIdentifier: Token = Token(TokenKind.IDENTIFIER, invocation.GetFullName()).addPosition(
        invocation.GetIdentifierPos())
    var identifier = Token(TokenKind.IDENTIFIER, invocation.GetIdentifier()).addPosition(invocation.GetIdentifierPos())
    var lSquare: Token = Token()
    var rSquare: Token = Token()
    var lParen: Token = Token()
    var rParen: Token = Token()
    if (isValidPosition(invocation.GetLeftSquarePos())) {
        lSquare = Token(TokenKind.LSQUARE).addPosition(invocation.GetLeftSquarePos())
    }
    if (isValidPosition(invocation.GetRightSquarePos())) {
        rSquare = Token(TokenKind.RSQUARE).addPosition(invocation.GetRightSquarePos())
    }
    if (isValidPosition(invocation.GetLeftParenPos())) {
        lParen = Token(TokenKind.LPAREN).addPosition(invocation.GetLeftParenPos())
    }
    if (isValidPosition(invocation.GetRightParenPos())) {
        rParen = Token(TokenKind.RPAREN).addPosition(invocation.GetRightParenPos())
    }
    var attrs = Tokens()
    for (tk in invocation.GetAttrs()) {
        match (tk) {
            case Some(v) => attrs.append(Token(getTokenKind(v.GetKind()), v.GetValue()).addPosition(v.GetPos()))
            case None => ()
        }
    }
    var inputs = Tokens()
    for (tk in invocation.GetArgs()) {
        match (tk) {
            case Some(v) => inputs.append(Token(getTokenKind(v.GetKind()), v.GetValue()).addPosition(v.GetPos()))
            case None => ()
        }
    }
    var hasParenthesis = invocation.GetHasParenthesis()
    var isCompileTimeVisible = invocation.GetIsCompileTimeVisible()
    var macroInputDecl: Option<Decl> = try {
        Some(generateDeclAST(invocation.GetDecl()))
    } catch (e: ParseASTException) {
        None<Decl>
    }
    if (isDecl) {
        let m = MacroExpandDecl(key, packageIdentifier, identifier, lSquare, attrs, rSquare, lParen, inputs, rParen,
            macroInputDecl, hasParenthesis, isCompileTimeVisible)
        if (isCompileTimeVisible) {
            return processCustomAnnotationLikeMacro(macroInputDecl, m)
        }
        return m
    } else if (isFuncParam) {
        let m = MacroExpandParam(key, packageIdentifier, identifier, lSquare, attrs, rSquare, lParen, inputs, rParen,
            macroInputDecl, hasParenthesis, isCompileTimeVisible)
        if (isCompileTimeVisible) {
            return processCustomAnnotationLikeMacro(macroInputDecl, m)
        }
        return m
    }
    return MacroExpandExpr(key, packageIdentifier, identifier, lSquare, attrs, rSquare, lParen, inputs, rParen,
        macroInputDecl, hasParenthesis)
}

func processCustomAnnotationLikeMacro(macroInputDecl: Option<Decl>, macroNode: Decl) {
    match (macroInputDecl) {
        case Some(v) =>
            v.annotations.add(createCustomAnnotation(macroNode), at: 0)
            return v
        case None => throw ParseASTException("Cannot create the macro extend declaration.")
    }
}

func getPackageIdentToken(s: String): Token {
    let isPkgIdent = s.contains(".") || s.contains("-") || s.contains(" ")
    Token(if (isPkgIdent) {
        TokenKind.PACKAGE_IDENTIFIER
    } else {
        TokenKind.IDENTIFIER
    }, s)
}

func getPackagePrefixes(prefixPaths: Array<Option<String>>, prefixPoses: Array<ASTFormat_Position>,
    prefixDotPoses: Array<ASTFormat_Position>): (Tokens, Tokens) {
    if (prefixPaths.size != prefixPoses.size || prefixPaths.size != prefixDotPoses.size) {
        throw ParseASTException()
    }
    var paths = Tokens()
    for (i in 0..prefixPaths.size) {
        match (prefixPaths[i]) {
            case Some(v) => paths.append(
                getPackageIdentToken(v).addPosition(prefixPoses[i].fileId, prefixPoses[i].line, prefixPoses[i].column))
            case None => throw ParseASTException()
        }
    }
    var dots = Tokens()
    for (pos in prefixDotPoses) {
        dots.append(Token(TokenKind.DOT, ".", pos.fileId, pos.line, pos.column))
    }
    (paths, dots)
}

func isSamePos(pos1: ASTFormat_Position, pos2: ASTFormat_Position) {
    return pos1.fileId == pos2.fileId && pos1.line == pos2.line && pos1.column == pos2.column
}
func createFeatureHeader(ftrHeader: Option<ASTFormat_FeaturesDirective>): Option<FeaturesDirective> {
    return match (ftrHeader) {
        case Some(v) =>
            let annos = v.GetAnnotations()
            let annotations = ArrayList<Annotation>(annos.size, {i => createAnnotation(annos[i])})
            let keyword = Token(TokenKind.FEATURES, "features").addPosition(v.GetFeaturesPos())
            let featuresSet = createFeaturesSet(v.GetFeaturesSet())
            FeaturesDirective(annotations, keyword, featuresSet)
        case _ => None
    }
}

func createFeaturesSet(ftrSet: Option<ASTFormat_FeaturesSet>): FeaturesSet {
    return match (ftrSet) {
        case Some(v) => 
            let lCurl = Token(TokenKind.LCURL).addPosition(v.GetLCurlPos())
            let content = createFeatureContent(v.GetContent())
            let commaPoses = v.GetCommaPoses()
            let commas = Tokens()
            for (pos in commaPoses) {
                commas.append(Token(TokenKind.COMMA).addPosition(pos))
            }
            let rCurl = Token(TokenKind.RCURL).addPosition(v.GetRCurlPos())
            FeaturesSet(lCurl, content, commas, rCurl)
        case _ => throw ParseASTException()
    }
}
 
func createFeatureContent(ftrContent: Array<Option<ASTFormat_FeatureId>>): ArrayList<FeatureId> {
    let ret = ArrayList<FeatureId>(ftrContent.size)
    for (item in ftrContent) {
        match (item) {
            case Some(v) =>
                let idents = v.GetIdentifiers()
                let identPoses = v.GetIdentPoses()
                let dotPoses = v.GetDotPoses()
                let identifiers = Tokens()
                let dots = Tokens()
                for (idx in 0..idents.size) {
                    identifiers.append(Token(TokenKind.IDENTIFIER, idents[idx] ?? throw ParseASTException()).addPosition(identPoses[idx]))
                    if (idx < dotPoses.size) {
                        let pos = nodePositionToPosition(dotPoses[idx])
                        dots.append(Token(TokenKind.DOT).addPosition(pos))
                    }
                }
                ret.add(FeatureId(identifiers, dots))
            case None => throw ParseASTException()
        }
    }
    return ret
}
 
func nodePositionToPosition(node: ASTFormat_Position): Position {
    return Position(node.fileId, node.line, node.column)
}

func createPackageHeader(pkgHeader: Option<ASTFormat_PackageSpec>): PackageHeader {
    return match (pkgHeader) {
        case Some(v) =>
            let kind = match (v.GetAccessible()) {
                case ASTFormat_AccessibleKind.AccessibleKind_ACCESSIBLE_PUBLIC => TokenKind.PUBLIC
                case ASTFormat_AccessibleKind.AccessibleKind_ACCESSIBLE_PROTECTED => TokenKind.PROTECTED
                case _ => TokenKind.INTERNAL
            }
            let beginPos = getNodeBeginPos(v.GetBase())
            let accessible = if (isSamePos(v.GetMacroPos(), beginPos) || isSamePos(v.GetPackagePos(), beginPos)) {
                Token()
            } else {
                Token(kind).addPosition(beginPos)
            }
            let macroPos = v.GetMacroPos()
            let macroKey = if (isValidPosition(macroPos)) {
                Token(TokenKind.MACRO).addPosition(macroPos)
            } else {
                Token()
            } 
            let keyword: Token = Token(TokenKind.PACKAGE).addPosition(v.GetPackagePos())
            let (prefixPaths, prefixDots) = getPackagePrefixes(v.GetPrefixPaths(), v.GetPrefixPoses(),
                v.GetPrefixDotPoses())
            let packageIdentifier: Token = getPackageIdentToken(v.GetPackageName()).addPosition(v.GetPackageNamePos())
            // prefixPaths[0] and prefixDots[0] would be orgnization name and position of double colon if double colon exists
            if (v.GetHasDoubleColon()) {
                PackageHeader(accessible, macroKey, keyword, prefixPaths[0],
                    Token(TokenKind.DOUBLE_COLON).addPosition(prefixDots[0].pos.fileID, prefixDots[0].pos.line,
                        prefixDots[0].pos.column), prefixPaths[1..], prefixDots[1..], packageIdentifier)
            } else {
                PackageHeader(accessible, macroKey, keyword, Token(), Token(), prefixPaths, prefixDots,
                    packageIdentifier)
            }
        case None => PackageHeader(true)
    }
}

func createImportContent(content: Option<ASTFormat_ImportContent>): ImportContent {
    match (content) {
        case Some(v) =>
            let kind = match (v.GetKind()) {
                case ImportKind_IMPORT_SINGLE => ImportKind.Single
                case ImportKind_IMPORT_ALIAS => ImportKind.Alias
                case ImportKind_IMPORT_ALL => ImportKind.All
                case ImportKind_IMPORT_MULTI => ImportKind.Multi
            }
            let (prefixPaths, prefixDots) = getPackagePrefixes(v.GetPrefixPaths(), v.GetPrefixPoses(),
                v.GetPrefixDotPoses())
            let identPos = v.GetIdentifierPos()
            let identifier = if (let ImportKind.All <- kind) {
                Token(TokenKind.MUL, "*", identPos.fileId, identPos.line, identPos.column)
            } else {
                getPackageIdentToken(v.GetIdentifier()).addPosition(identPos.fileId, identPos.line, identPos.column)
            }
            var importAlias = Tokens()
            if (let ImportKind.Alias <- kind) {
                let asPos = v.GetAsPos()
                importAlias.append(Token(TokenKind.AS, "as", asPos.fileId, asPos.line, asPos.column))
                let asIdentPos = v.GetAsIdentifierPos()
                importAlias.append(
                    Token(TokenKind.IDENTIFIER, v.GetAsIdentifier(), asIdentPos.fileId, asIdentPos.line,
                        asIdentPos.column))
            }
            var items: ArrayList<ImportContent> = ArrayList<ImportContent>()
            var commas = Tokens()
            var lCurl = Token()
            var rCurl = Token()
            if (let ImportKind.Multi <- kind) {
                let vItems = v.GetItems()
                items = ArrayList<ImportContent>(vItems.size, {i => createImportContent(vItems[i])})
                for (pos in v.GetCommaPoses()) {
                    commas.append(Token(TokenKind.COMMA, ",", pos.fileId, pos.line, pos.column))
                }
                var lCurlPos = v.GetLeftCurlPos()
                lCurl = Token(TokenKind.LCURL, "{", lCurlPos.fileId, lCurlPos.line, lCurlPos.column)
                var rCurlPos = v.GetRightCurlPos()
                rCurl = Token(TokenKind.RCURL, "}", rCurlPos.fileId, rCurlPos.line, rCurlPos.column)
            }
            // prefixPaths[0] and prefixDots[0] would be orgnization name and position of double colon if double colon exists
            if (v.GetHasDoubleColon()) {
                ImportContent(kind, prefixPaths[0],
                    Token(TokenKind.DOUBLE_COLON).addPosition(prefixDots[0].pos.fileID, prefixDots[0].pos.line,
                        prefixDots[0].pos.column), prefixPaths[1..], prefixDots[1..], identifier, importAlias, lCurl, items,
                    commas, rCurl)
            } else {
                ImportContent(kind, Token(), Token(), prefixPaths, prefixDots, identifier, importAlias, lCurl, items,
                    commas, rCurl)
            }
        case None => throw ParseASTException()
    }
}

func createImportList(imports: Option<ASTFormat_ImportSpec>): ImportList {
    var imp = match (imports) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    let kind = match (imp.GetReExport()) {
        case ReExportKind_REEXPORT_PUBLIC => TokenKind.PUBLIC
        case ReExportKind_REEXPORT_PROTECTED => TokenKind.PROTECTED
        case ReExportKind_REEXPORT_INTERNAL => TokenKind.INTERNAL
        case _ => TokenKind.PRIVATE
    }
    let beginPos = getNodeBeginPos(imp.GetBase())
    let reExportToken = if (!isSamePos(imp.GetImportPos(), beginPos)) {
        Token(kind).addPosition(beginPos)
    } else {
        Token()
    }
    var import_: Token = Token(TokenKind.IMPORT).addPosition(imp.GetImportPos())
    var content = if (let Some(v) <- imp.GetContent()) {
        createImportContent(v)
    } else {
        throw ParseASTException()
    }
    ImportList(reExportToken, import_, content)
}

func createProgram(file: Option<ASTFormat_File>): Program {
    var f = match (file) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var ftrDirective: Option<FeaturesDirective> = createFeatureHeader(f.GetFeature())
    var pkgHeader: PackageHeader = createPackageHeader(f.GetPackage())
    let importSrc = f.GetImports()
    var imports: ArrayList<ImportList> = ArrayList<ImportList>(importSrc.size, {i => createImportList(importSrc[i])})
    let declSrc = f.GetDecls()
    var decls: ArrayList<Decl> = ArrayList<Decl>(declSrc.size, {i => generateDeclAST(declSrc[i])})
    return Program(pkgHeader, imports, decls, ftrDirective)
}

func createConstructor(decl: Option<ASTFormat_Decl>): Constructor {
    var d = match (decl) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var db = match (d.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var nb = match (db.GetBase()) {
        case Some(v) => v
        case None => throw ParseASTException()
    }
    var astKind: String = nb.GetAstKind()
    var annos: ArrayList<Annotation> = ArrayList<Annotation>()
    if (astKind == "macro_expand_decl") {
        return createConstructorLikeMacroExpand(d)
    }
    var ident = Token(TokenKind.IDENTIFIER, db.GetIdentifier()).addPosition(db.GetIdentifierPos())
    for (anno in db.GetAnnotations()) {
        annos.add(createAnnotation(anno))
    }
    if (astKind == "var_decl") {
        return Constructor(annos, ident)
    }
    var funcBody = match (d.GetDeclAsFuncDecl()) {
        case Some(v) => v.GetFuncBody()
        case None => throw ParseASTException()
    }
    var paramList = match (funcBody) {
        case Some(v) => v.GetParamList().getOrThrow()
        case None => throw ParseASTException()
    }
    var lParen = Token(TokenKind.LPAREN).addPosition(paramList.GetLeftParenPos())
    var params_: ArrayList<TypeNode> = ArrayList<TypeNode>()
    let commas = Tokens()
    var params = paramList.GetParams()
    for (i in 0..params.size) {
        let param = params[i].getOrThrow()
        var ty = match (param.GetBase()) {
            case Some(v) => generateTypeAST(v.GetType())
            case None => throw ParseASTException("Cannot get the parameter from the enum constructor.")
        }
        params_.add(ty)

        let commaPos = param.GetCommaPos()
        if (isValidPosition(commaPos)) {
            commas.append(Token(TokenKind.COMMA).addPosition(commaPos))
        }
    }
    var rParen = Token(TokenKind.RPAREN).addPosition(paramList.GetRightParenPos())
    return Constructor(annos, ident, lParen, params_, commas, rParen)
}

func createArgumentTokens(m: Decl): Tokens {
    var argTokens = Tokens()
    argTokens.append(m.identifier)
    let isCompileTimeVisible = match (m as MacroExpandDecl) {
        case Some(v) =>
            argTokens.append(v.lSquare)
            argTokens.append(v.macroAttrs)
            argTokens.append(v.rSquare)
            v.isCompileTimeVisible_
        case None => match (m as MacroExpandParam) {
            case Some(v) =>
                argTokens.append(v.lSquare)
                argTokens.append(v.macroAttrs)
                argTokens.append(v.rSquare)
                v.isCompileTimeVisible_
            case None => throw ParseASTException()
        }
    }
    let at = if (isCompileTimeVisible) {
        Token(TokenKind.AT_EXCL).addPosition(m.keyword.pos)
    } else {
        Token(TokenKind.AT).addPosition(m.keyword.pos)
    }
    return at + argTokens
}

func createCustomAnnotation(m: Decl): Annotation {
    let argTokens = createArgumentTokens(m)

    let node = unsafe {
        try {
            parse(argTokens, {p: CPointer<UInt8> => return CJ_AST_ParseAnnotationArguments(p)})
        } catch (e: Exception) {
            throw ParseASTException("Failed to parse the custom annotation.")
        }
    }
    createAnnotation(node.GetRootAsAnnotation())
}

func createConstructorLikeMacroExpand(decl: ASTFormat_Decl): Constructor {
    var md = createMacroExpandDecl(decl)
    if (md is MacroExpandDecl) {
        // annotation(@Anno) and MacroExpandDecl(@Macro) are syntactically similar, need convert to Constructor.
        return createConstructorWithAt(md)
    } else {
        return createConstructorWithAtExcl(md)
    }
}

func createConstructorWithAt(decl: Decl): Constructor {
    var annos: ArrayList<Annotation> = ArrayList<Annotation>()
    var ident = decl.identifier
    var lParen = Token(TokenKind.LPAREN)
    let commas = Tokens()
    var params = ArrayList<TypeNode>()
    var rParen = Token(TokenKind.RPAREN)
    var macroNode = match (decl as MacroExpandDecl) {
        case Some(v) =>
            annos.add(all: v.annotations)
            annos.add(createCustomAnnotation(v))
            v
        case None => throw ParseASTException()
    }
    while (true) {
        if (!(macroNode.macroInputDecl is MacroExpandDecl)) {
            ident = macroNode.macroInputDecl.identifier
            break
        }
        macroNode = match (macroNode.macroInputDecl as MacroExpandDecl) {
            case Some(v) =>
                annos.add(createCustomAnnotation(v))
                v
            case None => throw ParseASTException()
        }
    }
    let enumConstructor = match (macroNode.macroInputDecl as FuncDecl) {
        case Some(v) =>
            ident = v.identifier
            lParen = v.lParen
            for (p in v.funcParams) {
                params.add(p.paramType)
            }
            lParen = v.lParen
            annos.add(all: v.annotations)
            Constructor(annos, ident, lParen, params, commas, rParen)
        case None => match (macroNode.macroInputDecl as VarDecl) {
            case Some(v) =>
                annos.add(all: v.annotations)
                Constructor(annos, v.identifier)
            case None => throw ParseASTException()
        }
    }
    return enumConstructor
}

func createConstructorWithAtExcl(decl: Decl): Constructor {
    match (decl as FuncDecl) {
        case Some(v) =>
            var params: ArrayList<TypeNode> = ArrayList<TypeNode>()
            for (p in v.funcParams) {
                params.add(p.paramType)
            }
            return Constructor(v.annotations, v.identifier, v.lParen, params, Tokens(), v.rParen)
        case None => match (decl as VarDecl) {
            case Some(v) => return Constructor(v.annotations, v.identifier)
            case None => throw ParseASTException()
        }
    }
}
