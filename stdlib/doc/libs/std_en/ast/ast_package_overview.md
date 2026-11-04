# std.ast

## Functionality Overview

The ast package primarily contains the syntax parser for Cangjie source code and Cangjie syntax tree nodes, providing syntax parsing functions. It can parse lexical units ([Tokens](./ast_package_api/ast_package_classes.md#class-tokens)) of Cangjie source code into Abstract Syntax Tree (AST) node objects.

For iOS platform scenarios, this package only supports running on iOS 12 and above.

The Cangjie ast package provides `Macro With Context` related functions for obtaining contextual information during macro expansion. In nested macro scenarios, inner macros can call the library function [assertParentContext(String)](./ast_package_api/ast_package_funcs.md#func-assertparentcontextstring) to ensure the inner macro call is always nested within a specific outer macro call. If this function is called without being nested within the given outer macro call, it will throw an error. Additionally, the function [insideParentContext(String)](./ast_package_api/ast_package_funcs.md#func-insideparentcontextstring) checks whether an inner macro call is nested within a specific outer macro call, returning a boolean value. `Macro With Context` related functions can only be called directly as functions and cannot be assigned to variables, passed as arguments, or returned as values.

`Macro With Context` related functions include:

- [assertParentContext(String)](./ast_package_api/ast_package_funcs.md#func-assertparentcontextstring)
- [getChildMessages(String)](./ast_package_api/ast_package_funcs.md#func-getchildmessagesstring)
- [insideParentContext(String)](./ast_package_api/ast_package_funcs.md#func-insideparentcontextstring)
- [setItem(String, Bool)](./ast_package_api/ast_package_funcs.md#func-setitemstring-bool)
- [setItem(String, Int64)](./ast_package_api/ast_package_funcs.md#func-setitemstring-int64)
- [setItem(String, String)](./ast_package_api/ast_package_funcs.md#func-setitemstring-string)
- [setItem(String, Tokens)](./ast_package_api/ast_package_funcs.md#func-setitemstring-tokens)

## API List

### Functions

| Function Name | Description |
| --------------------------- | ------------------------ |
| [assertParentContext(String)](./ast_package_api/ast_package_funcs.md#func-assertparentcontextstring) | Checks whether the current macro call is within a specific macro call. If the check fails, the compiler generates an error message. |
| [cangjieLex(String)](./ast_package_api/ast_package_funcs.md#func-cangjielexstring) | Converts a string to the `Tokens` type. |
| [cangjieLex(String, Bool)](./ast_package_api/ast_package_funcs.md#func-cangjielexstring-bool) | Converts a string to the `Tokens` type. |
| [compareTokens(Tokens, Tokens)](./ast_package_api/ast_package_funcs.md#func-comparetokenstokens-tokens) | Compares whether two `Tokens` are identical. |
| [diagReport(DiagReportLevel, Tokens, String, String)](./ast_package_api/ast_package_funcs.md#func-diagreportdiagreportlevel-tokens-string-string) | Error reporting interface that outputs diagnostic messages during the macro expansion phase of compilation, supporting `WARNING` and `ERROR` levels. |
| [getChildMessages(String)](./ast_package_api/ast_package_funcs.md#func-getchildmessagesstring) | Retrieves messages sent by specific inner macros. |
| [getTokenKind(UInt16)](./ast_package_api/ast_package_funcs.md#func-gettokenkinduint16) | Converts a lexical unit type number to `TokenKind`. |
| [insideParentContext(String)](./ast_package_api/ast_package_funcs.md#func-insideparentcontextstring) | Checks whether the current macro call is within a specific macro call, returning a boolean value. |
| [parseDecl(Tokens, String)](./ast_package_api/ast_package_funcs.md#func-parsedecltokens-string) | Parses a set of lexical units to obtain a `Decl`-type node. |
| [parseDeclFragment(Tokens, Int64)](./ast_package_api/ast_package_funcs.md#func-parsedeclfragmenttokens-int64) | Parses a set of lexical units to obtain a `Decl`-type node and the index for continued parsing. |
| [parseExpr(Tokens)](./ast_package_api/ast_package_funcs.md#func-parseexprtokens) | Parses a set of lexical units to obtain an `Expr`-type node. |
| [parseExprFragment(Tokens, Int64)](./ast_package_api/ast_package_funcs.md#func-parseexprfragmenttokens-int64) | Parses a set of lexical units to obtain an `Expr`-type node and the index for continued parsing. |
| [parsePattern(Tokens)](./ast_package_api/ast_package_funcs.md#func-parsepatterntokens) | Parses a set of lexical units to obtain a `Pattern`-type node. |
| [parsePatternFragment(Tokens, Int64)](./ast_package_api/ast_package_funcs.md#func-parsepatternfragmenttokens-int64) | Parses a set of lexical units to obtain a `Pattern`-type node and the index for continued parsing. |
| [parseProgram(Tokens)](./ast_package_api/ast_package_funcs.md#func-parseprogramtokens) | Parses the source code of a single Cangjie file to obtain a `Program`-type node. |
| [parseType(Tokens)](./ast_package_api/ast_package_funcs.md#func-parsetypetokens) | Parses a set of lexical units to obtain a `TypeNode`-type node. |
| [parseTypeFragment(Tokens, Int64)](./ast_package_api/ast_package_funcs.md#func-parsetypefragmenttokens-int64) | Parses a set of lexical units to obtain a `TypeNode`-type node and the index for continued parsing. |
| [setItem(String, Bool)](./ast_package_api/ast_package_funcs.md#func-setitemstring-bool) | Inner macros use this interface to send `Bool`-type messages to outer macros. |
| [setItem(String, Int64)](./ast_package_api/ast_package_funcs.md#func-setitemstring-int64) | Inner macros use this interface to send `Int64`-type messages to outer macros. |
| [setItem(String, String)](./ast_package_api/ast_package_funcs.md#func-setitemstring-string) | Inner macros use this interface to send `String`-type messages to outer macros. |
| [setItem(String, Tokens)](./ast_package_api/ast_package_funcs.md#func-setitemstring-tokens) | Inner macros use this interface to send `Tokens`-type messages to outer macros. |

### Interfaces

| Interface Name | Description |
| --------------------------------- | ---------------------------------- |
| [ToBytes](./ast_package_api/ast_package_interfaces.md#interface-tobytes) | Provides serialization functionality for corresponding types. |
| [ToTokens](./ast_package_api/ast_package_interfaces.md#interface-totokens) | Interface for converting instances of corresponding types to `Tokens`, required for supporting quote interpolation operations. |

### Classes

| Class Name | Description |
| --------------------------------- | ---------------------------------- |
| [Annotation](./ast_package_api/ast_package_classes.md#class-annotation) | Represents compiler-built annotation nodes. |
| [Argument](./ast_package_api/ast_package_classes.md#class-argument) | Represents function call argument nodes. |
| [ArrayLiteral](./ast_package_api/ast_package_classes.md#class-arrayliteral) | Represents `Array` literal nodes. |
| [AsExpr](./ast_package_api/ast_package_classes.md#class-asexpr) | Represents a type-checking expression. |
| [AssignExpr](./ast_package_api/ast_package_classes.md#class-assignexpr) | Represents assignment expression nodes. |
| [BinaryExpr](./ast_package_api/ast_package_classes.md#class-binaryexpr) | Represents binary operation expression nodes. |
| [Block](./ast_package_api/ast_package_classes.md#class-block) | Represents block nodes. |
| [Body](./ast_package_api/ast_package_classes.md#class-body) | Represents structures composed of `{}` and internal declaration nodes in Class, Struct, Interface, and extension types. |
| [CallExpr](./ast_package_api/ast_package_classes.md#class-callexpr) | Represents function call nodes. |
| [ClassDecl](./ast_package_api/ast_package_classes.md#class-classdecl) | Class definition nodes. |
| [CommandTypePattern](./ast_package_api/ast_package_classes.md#class-commandtypepattern) | Represents a command pattern with type annotations. |
| [ConstPattern](./ast_package_api/ast_package_classes.md#class-constpattern) | Represents constant pattern nodes. |
| [Constructor](./ast_package_api/ast_package_classes.md#class-constructor) | Represents `Constructor` nodes in `enum` types. |
| [Decl](./ast_package_api/ast_package_classes.md#class-decl) | Parent class of all declaration nodes, inheriting from `Node`, providing common interfaces for all declaration nodes. |
| [DoWhileExpr](./ast_package_api/ast_package_classes.md#class-dowhileexpr) | Represents `do-while` expressions. |
| [EnumDecl](./ast_package_api/ast_package_classes.md#class-enumdecl) | Represents `Enum` definition nodes. |
| [EnumPattern](./ast_package_api/ast_package_classes.md#class-enumpattern) | Represents enum pattern nodes. |
| [ExceptTypePattern](./ast_package_api/ast_package_classes.md#class-excepttypepattern) | Represents nodes used in exception pattern states. |
| [Expr](./ast_package_api/ast_package_classes.md#class-expr) | Parent class of all expression nodes, inheriting from `Node`. |
| [ExtendDecl](./ast_package_api/ast_package_classes.md#class-extenddecl) | Represents extension definition nodes. |
| [FeatureId](./ast_package_api/ast_package_classes.md#class-featureid) | Represents a feature name node. |
| [FeaturesDirective](./ast_package_api/ast_package_classes.md#class-featuresdirective) | Represents a features directive node. |
| [FeaturesSet](./ast_package_api/ast_package_classes.md#class-featuresset) | Represents a features set which contains names of featurs. |
| [ForInExpr](./ast_package_api/ast_package_classes.md#class-forinexpr) | Represents `for-in` expressions. |
| [FuncDecl](./ast_package_api/ast_package_classes.md#class-funcdecl) | Represents function definition nodes. |
| [FuncParam](./ast_package_api/ast_package_classes.md#class-funcparam) | Represents function parameter nodes, including unnamed and named parameters. |
| [FuncType](./ast_package_api/ast_package_classes.md#class-functype) | Represents function type nodes. |
| [GenericConstraint](./ast_package_api/ast_package_classes.md#class-genericconstraint) | Represents generic constraint nodes. |
| [GenericParam](./ast_package_api/ast_package_classes.md#class-genericparam) | Represents type parameter nodes. |
| [Handler](./ast_package_api/ast_package_classes.md#class-handler) | Represents a `handle` clause. |
| [IfExpr](./ast_package_api/ast_package_classes.md#class-ifexpr) | Represents conditional expressions. |
| [ImportContent](./ast_package_api/ast_package_classes.md#class-importcontent) | Represents import items in package import nodes. |
| [ImportList](./ast_package_api/ast_package_classes.md#class-importlist) | Represents package import nodes. |
| [IncOrDecExpr](./ast_package_api/ast_package_classes.md#class-incordecexpr) | Represents expressions containing increment (`++`) or decrement (`--`) operators. |
| [InterfaceDecl](./ast_package_api/ast_package_classes.md#class-interfacedecl) | Represents interface definition nodes. |
| [IsExpr](./ast_package_api/ast_package_classes.md#class-isexpr) | Represents a type-checking expression. |
| [JumpExpr](./ast_package_api/ast_package_classes.md#class-jumpexpr) | Represents `break` and `continue` in loop expression bodies. |
| [LambdaExpr](./ast_package_api/ast_package_classes.md#class-lambdaexpr) | Represents `Lambda` expressions, which are anonymous functions. |
| [LetPatternExpr](./ast_package_api/ast_package_classes.md#class-letpatternexpr) | Represents destructuring pattern matching nodes in `let` declarations. |
| [LitConstExpr](./ast_package_api/ast_package_classes.md#class-litconstexpr) | Represents constant expression nodes. |
| [MacroDecl](./ast_package_api/ast_package_classes.md#class-macrodecl) | Represents macro definition nodes. |
| [MacroExpandDecl](./ast_package_api/ast_package_classes.md#class-macroexpanddecl) | Represents macro call nodes. |
| [MacroExpandExpr](./ast_package_api/ast_package_classes.md#class-macroexpandexpr) | Represents macro call nodes. |
| [MacroExpandParam](./ast_package_api/ast_package_classes.md#class-macroexpandparam) | Represents macro call nodes. |
| [MacroMessage](./ast_package_api/ast_package_classes.md#class-macromessage) | Records messages sent by inner macros. |
| [MainDecl](./ast_package_api/ast_package_classes.md#class-maindecl) | Represents `main` function definition nodes. |
| [MatchCase](./ast_package_api/ast_package_classes.md#class-matchcase) | Represents `case` nodes in `match` expressions. |
| [MatchExpr](./ast_package_api/ast_package_classes.md#class-matchexpr) | Represents pattern-matching expressions. |
| [MemberAccess](./ast_package_api/ast_package_classes.md#class-memberaccess) | Represents member access expressions. |
| [Modifier](./ast_package_api/ast_package_classes.md#class-modifier) | Indicates that a definition has certain characteristics, typically placed at the beginning of the definition. |
| [Node](./ast_package_api/ast_package_classes.md#class-node) | Parent class of all Cangjie syntax tree nodes. |
| [OptionalExpr](./ast_package_api/ast_package_classes.md#class-optionalexpr) | Represents expression nodes with question mark operators. |
| [PackageHeader](./ast_package_api/ast_package_classes.md#class-packageheader) | Represents package declaration nodes. |
| [ParenExpr](./ast_package_api/ast_package_classes.md#class-parenexpr) | Represents parenthesized expression nodes, which are expressions enclosed in parentheses. |
| [ParenType](./ast_package_api/ast_package_classes.md#class-parentype) | Represents parenthesized type nodes. |
| [Pattern](./ast_package_api/ast_package_classes.md#class-pattern) | Parent class of all pattern-matching nodes, inheriting from `Node`. |
| [PerformExpr](./ast_package_api/ast_package_classes.md#class-performexpr) | Represents a `perform` expression node. |
| [PrefixType](./ast_package_api/ast_package_classes.md#class-prefixtype) | Represents prefix type nodes with question marks. |
| [PrimaryCtorDecl](./ast_package_api/ast_package_classes.md#class-primaryctordecl) | Represents primary constructor nodes. |
| [PrimitiveType](./ast_package_api/ast_package_classes.md#class-primitivetype) | Represents primitive type nodes. |
| [PrimitiveTypeExpr](./ast_package_api/ast_package_classes.md#class-primitivetypeexpr) | Represents primitive type expression nodes. |
| [Program](./ast_package_api/ast_package_classes.md#class-program) | Represents Cangjie source file nodes. |
| [PropDecl](./ast_package_api/ast_package_classes.md#class-propdecl) | Represents property definition nodes. |
| [QualifiedType](./ast_package_api/ast_package_classes.md#class-qualifiedtype) | Represents user-defined member types. |
| [QuoteExpr](./ast_package_api/ast_package_classes.md#class-quoteexpr) | Represents `quote` expression nodes. |
| [QuoteToken](./ast_package_api/ast_package_classes.md#class-quotetoken) | Represents any valid `token` within `quote` expression nodes. |
| [RangeExpr](./ast_package_api/ast_package_classes.md#class-rangeexpr) | Represents expressions containing range operators. |
| [RefExpr](./ast_package_api/ast_package_classes.md#class-refexpr) | Represents expression nodes related to custom type nodes. |
| [RefType](./ast_package_api/ast_package_classes.md#class-reftype) | Represents user-defined type nodes. |
| [ResumeExpr](./ast_package_api/ast_package_classes.md#class-resumeexpr) | Represents a `resume` expression node. |
| [ReturnExpr](./ast_package_api/ast_package_classes.md#class-returnexpr) | Represents `return` expression nodes. |
| [SpawnExpr](./ast_package_api/ast_package_classes.md#class-spawnexpr) | Represents `Spawn` expressions. |
| [StructDecl](./ast_package_api/ast_package_classes.md#class-structdecl) | Represents `Struct` nodes. |
| [SubscriptExpr](./ast_package_api/ast_package_classes.md#class-subscriptexpr) | Represents index access expressions. |
| [SynchronizedExpr](./ast_package_api/ast_package_classes.md#class-synchronizedexpr) | Represents `synchronized` expressions. |
| [ThisType](./ast_package_api/ast_package_classes.md#class-thistype) | Represents `This` type nodes. |
| [ThrowExpr](./ast_package_api/ast_package_classes.md#class-throwexpr) | Represents `throw` expression nodes. |
| [Tokens](./ast_package_api/ast_package_classes.md#class-tokens) | A type that encapsulates `Token` sequences. |
| [TokensIterator](./ast_package_api/ast_package_classes.md#class-tokensiterator) | Implements iterator functionality for `Tokens`. |
| [TrailingClosureExpr](./ast_package_api/ast_package_classes.md#class-trailingclosureexpr) | Represents trailing `Lambda` nodes. |
| [TryExpr](./ast_package_api/ast_package_classes.md#class-tryexpr) | Represents `try` expression nodes. |
| [TupleLiteral](./ast_package_api/ast_package_classes.md#class-tupleliteral) | Represents tuple literal nodes. |
| [TuplePattern](./ast_package_api/ast_package_classes.md#class-tuplepattern) | Represents tuple pattern nodes. |
| [TupleType](./ast_package_api/ast_package_classes.md#class-tupletype) | Represents tuple type nodes.|
| [TypeAliasDecl](./ast_package_api/ast_package_classes.md#class-typealiasdecl) | Represents a type alias node. |
| [TypeConvExpr](./ast_package_api/ast_package_classes.md#class-typeconvexpr) | Represents a type conversion expression. |
| [TypeNode](./ast_package_api/ast_package_classes.md#class-typenode) | The parent class of all type nodes, inherits from `Node`. |
| [TypePattern](./ast_package_api/ast_package_classes.md#class-typepattern) | Represents a type pattern node. |
| [UnaryExpr](./ast_package_api/ast_package_classes.md#class-unaryexpr) | Represents a unary operation expression node. |
| [VArrayExpr](./ast_package_api/ast_package_classes.md#class-varrayexpr) | Represents an instance node of `VArray`. |
| [VArrayType](./ast_package_api/ast_package_classes.md#class-varraytype) | Represents a `VArray` type node. |
| [VarDecl](./ast_package_api/ast_package_classes.md#class-vardecl) | Represents a variable declaration node. |
| [VarOrEnumPattern](./ast_package_api/ast_package_classes.md#class-varorenumpattern) | Represents a node when the pattern identifier is an `Enum` constructor. |
| [VarPattern](./ast_package_api/ast_package_classes.md#class-varpattern) | Represents a binding pattern node. |
| [Visitor](./ast_package_api/ast_package_classes.md#class-visitor) | An abstract class that internally defines default `visit` functions for accessing different types of AST nodes. |
| [WhileExpr](./ast_package_api/ast_package_classes.md#class-whileexpr) | Represents a `while` expression. |
| [WildcardExpr](./ast_package_api/ast_package_classes.md#class-wildcardexpr) | Represents a wildcard expression node. |
| [WildcardPattern](./ast_package_api/ast_package_classes.md#class-wildcardpattern) | Represents a wildcard pattern node. |

### Enumeration

| Enumeration Name | Functionality |
| --------------------------------- | ---------------------------------- |
| [DiagReportLevel](./ast_package_api/ast_package_enums.md#enum-diagreportlevel) | Indicates the information level of error reporting interface, supporting `ERROR` and `WARNING` levels. |
| [ImportKind](./ast_package_api/ast_package_enums.md#enum-importkind) | Represents the type of import statements, including single import, alias import, full import, and multiple imports. |
| [TokenKind](./ast_package_api/ast_package_enums.md#enum-tokenkind) | Represents all lexical structures in Cangjie compilation, including symbols, keywords, identifiers, line breaks, etc. |

### Structures

| Structure Name | Functionality |
| --------------------------------- | ---------------------------------- |
| [Position](./ast_package_api/ast_package_structs.md#struct-position) | Data structure representing position information, containing file ID, line number, and column number. |
| [Token](./ast_package_api/ast_package_structs.md#struct-token) | Lexical unit type. |

### Exception Classes

| Exception Class Name | Functionality |
| --------------------------------- | ---------------------------------- |
| [ASTException](./ast_package_api/ast_package_exceptions.md#class-astexception) | Exception class for the AST library, used when exceptions occur during AST library calls. |
| [MacroContextException](./ast_package_api/ast_package_exceptions.md#class-macrocontextexception) | Context macro exception class for the AST library, used when exceptions occur in context macro-related interfaces. |
| [ParseASTException](./ast_package_api/ast_package_exceptions.md#class-parseastexception) | Parsing exception class for the AST library, used when exceptions occur during node parsing. |
