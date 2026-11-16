# Functions

## func assertParentContext(String)

```cangjie
public func assertParentContext(parentMacroName: String): Unit
```

Function: Checks whether the current macro invocation is nested within a specific macro invocation. If the check fails, the compiler will generate an error message.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- parentMacroName: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the outer macro invocation to be checked.

## func cangjieLex(String)

```cangjie
public func cangjieLex(code: String): Tokens
```

Function: Converts a string into a [Tokens](ast_package_classes.md#class-tokens) object.

Parameters:

- code: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be lexically parsed.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The lexically parsed [Tokens](ast_package_classes.md#class-tokens).

Exceptions:

- [IllegalMemoryException](../../core/core_package_api/core_package_exceptions.md#class-illegalmemoryexception) - Thrown when memory allocation fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the input code cannot be correctly parsed into [Tokens](ast_package_classes.md#class-tokens).

## func cangjieLex(String, Bool)

```cangjie
public func cangjieLex(code: String, truncated: Bool): Tokens
```

Function: Converts a string into a [Tokens](ast_package_classes.md#class-tokens) object.

Parameters:

- code: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string to be lexically parsed.
- truncated: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether to remove the Token([END](ast_package_enums.md#end)) from the parsed [Tokens](ast_package_classes.md#class-tokens).

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The lexically parsed [Tokens](ast_package_classes.md#class-tokens).

Exceptions:

- [IllegalMemoryException](../../core/core_package_api/core_package_exceptions.md#class-illegalmemoryexception) - Thrown when memory allocation fails.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the input code cannot be correctly parsed into [Tokens](ast_package_classes.md#class-tokens).

## func compareTokens(Tokens, Tokens)

```cangjie
public func compareTokens(tokens1: Tokens, tokens2: Tokens): Bool
```

Function: Compares whether two [Tokens](ast_package_classes.md#class-tokens) are identical.

Parameters:

- tokens1: [Tokens](ast_package_classes.md#class-tokens) - The first [Tokens](ast_package_classes.md#class-tokens) to compare.
- tokens2: [Tokens](ast_package_classes.md#class-tokens) - The second [Tokens](ast_package_classes.md#class-tokens) to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [Tokens](ast_package_classes.md#class-tokens) have identical content (excluding line breaks, terminators, and position information).

## func diagReport(DiagReportLevel, Tokens, String, String)

```cangjie
public func diagReport(level: DiagReportLevel, tokens: Tokens, message: String, hint: String): Unit
```

Function: Error reporting interface that outputs diagnostic messages during the macro expansion phase of compilation, supporting `WARNING` and `ERROR` severity levels.

> **Note:**
>
> - When the severity level is `ERROR`, this interface will terminate the compilation process but not the macro expansion process. It is recommended to immediately return or throw an exception after calling this interface to terminate macro expansion.
> - This interface follows the cjc standard error reporting format, displaying the source code line containing the tokens with squiggly underlines. The message is shown on the first line, and the hint is displayed below the squiggly underlines.
> - The referenced source code content is currently determined based on the start position of the first [Token](ast_package_structs.md#struct-token) and the end position of the last [Token](ast_package_structs.md#struct-token), without verifying consistency of intermediate [Token](ast_package_structs.md#struct-token) positions.
> - This interface is ineffective when called outside the macro expansion process. See [example code](../ast_samples/report.md#non-macro-expansion-call-example).

Parameters:

- level: [DiagReportLevel](ast_package_enums.md#enum-diagreportlevel) - The severity level of the diagnostic message.
- tokens: [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) corresponding to the referenced source code in the diagnostic message.
- message: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The main diagnostic message.
- hint: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Supplementary hint information.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) contain the following errors:
    - The input [Tokens](ast_package_classes.md#class-tokens) is empty;
    - The [Token](ast_package_structs.md#struct-token) in the input [Tokens](ast_package_classes.md#class-tokens) come from different source files;
    - The position of the first [Token](ast_package_structs.md#struct-token) in the input [Tokens](ast_package_classes.md#class-tokens) is earlier than the last [Token](ast_package_structs.md#struct-token);
    - The position range of [Token](ast_package_structs.md#struct-token) in the input [Tokens](ast_package_classes.md#class-tokens) exceeds the position range of the macro invocation.

## func getChildMessages(String)

```cangjie
public func getChildMessages(children:String): ArrayList<MacroMessage>
```

Function: Retrieves messages sent by specific nested macros.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- children: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the nested macro whose messages are to be received.

Returns:

- [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[MacroMessage](ast_package_classes.md#class-macromessage)> - Returns a set of [MacroMessage](ast_package_classes.md#class-macromessage) objects.

## func getTokenKind(UInt16)

```cangjie
public func getTokenKind(no: UInt16): TokenKind
```

Function: Converts a token kind number into a [TokenKind](ast_package_enums.md#enum-tokenkind).

Parameters:

- no: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number to be converted.

Returns:

- [TokenKind](ast_package_enums.md#enum-tokenkind) - The [TokenKind](ast_package_enums.md#enum-tokenkind) corresponding to the token kind number.

> **Note:**
>
> Currently, [SINGLE_QUOTED_STRING_LITERAL](ast_package_enums.md#single_quoted_string_literal) and [STRING_LITERAL](ast_package_enums.md#string_literal) share the number 147. Inputting 147 will only return [STRING_LITERAL](ast_package_enums.md#string_literal). Other [TokenKind](ast_package_enums.md#enum-tokenkind) do not share numbers.

## func insideParentContext(String)

```cangjie
public func insideParentContext(parentMacroName: String): Bool
```

Function: Checks whether the current macro invocation is nested within a specific macro invocation and returns a boolean value.

> **Note:**
>
> - In nested macro scenarios, inner macros can communicate with outer macros by sending key/value pairs. When an inner macro executes, it sends information to the outer macro by calling the standard library function [setItem](ast_package_funcs.md#func-setitemstring-bool). Subsequently, when the outer macro executes, it retrieves messages (a set of key/value pairs) from each inner macro by calling the standard library function [getChildMessages](ast_package_funcs.md#func-getchildmessagesstring).
> - This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- parentMacroName: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the outer macro invocation to be checked.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the current macro is nested within the specified macro invocation.

## func parseDecl(Tokens, String)

```cangjie
public func parseDecl(input: Tokens, astKind!: String = ""): Decl
```

Function: Parses a set of lexical units to obtain a [Decl](ast_package_classes.md#class-decl) type node.

> **Note:**
>
> This function does not support parsing [FuncParam](ast_package_classes.md#class-funcparam) types.
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.
- astKind!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Specifies the type of node to parse. Valid values are: `PrimaryCtorDecl` and `PropMemberDecl`.
    - `PrimaryCtorDecl`: Parses the primary constructor.
    - `PropMemberDecl`: Parses the getter and setter functions of a prop declaration.

Returns:

- [Decl](ast_package_classes.md#class-decl) - A [Decl](ast_package_classes.md#class-decl) type node.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [Decl](ast_package_classes.md#class-decl) node. The exception includes error message information.

Examples:

1. The following code demonstrates a case where `astKind` is set to `PropMemberDecl`. In this scenario, `parseDecl` can be used to parse the getter and setter functions of a `prop`, with the result being of type `FuncDecl` (if `astKind` is not set, parsing will fail due to the absence of the `func` keyword).

    ```cangjie
    import std.ast.*

    main() {
        let getter = quote( get() { _val } )
        let setter = quote( set(v) { _val = v })
        let getterDecl = parseDecl(getter, astKind: "PropMemberDecl")
        let setterDecl = parseDecl(setter, astKind: "PropMemberDecl")
        println((getterDecl as FuncDecl).getOrThrow().block.toTokens())
        println((setterDecl as FuncDecl).getOrThrow().block.toTokens())
    }
    ```

    Output:

    ```text
    {
        _val
    }

    {
        _val = v
    }
    ```

2. The following code demonstrates a case where `astKind` is set to `PrimaryCtorDecl`. In this scenario, `parseDecl` can be used to parse the primary constructor node, with the result being of type `PrimaryCtorDecl` (if `astKind` is not set, parsing will fail due to the absence of the `func` keyword).

    ```cangjie
    import std.ast.*

    main() {
        let ctor = quote(
            Point(var x: Int32, var y: Int32) {}
        )
        let ctorDecl = parseDecl(ctor, astKind: "PrimaryCtorDecl")
        println(ctorDecl is PrimaryCtorDecl)
        println(ctorDecl.toTokens())
    }
    ```

    Output:

    ```text
    true
    Point(var x: Int32, var y: Int32) {
    }
    ```

## func parseDeclFragment(Tokens, Int64)

```cangjie
public func parseDeclFragment(input: Tokens, startFrom!: Int64 = 0): (Decl, Int64)
```

Function: Parses a set of lexical units to obtain a [Decl](ast_package_classes.md#class-decl) type node and the index for continued parsing.

> **Note:**
>
> This function does not support parsing [FuncParam](ast_package_classes.md#class-funcparam), [PropDecl](ast_package_classes.md#class-propdecl), or [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) types.
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.
- startFrom!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The starting position.

Returns:

- ([Decl](ast_package_classes.md#class-decl), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The syntax tree node and the position for continued parsing.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [Decl](ast_package_classes.md#class-decl) node. The exception includes error message information.

## func parseExpr(Tokens)

```cangjie
public func parseExpr(input: Tokens): Expr
```

Function: Parses a set of lexical units to obtain an [Expr](ast_package_classes.md#class-expr) type node.

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.

Returns:

- [Expr](ast_package_classes.md#class-expr) - An [Expr](ast_package_classes.md#class-expr) type node.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into an [Expr](ast_package_classes.md#class-expr) node. The exception includes error message information.

## func parseExprFragment(Tokens, Int64)

```cangjie
public func parseExprFragment(input: Tokens, startFrom!: Int64 = 0): (Expr, Int64)
```

Function: This function is Used to parse a set of lexical units and obtain a node of type [Expr](ast_package_classes.md#class-expr) along with the index for continued parsing.

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.
- startFrom!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The starting position.

Returns:

- ([Expr](ast_package_classes.md#class-expr), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The syntax tree node and the position for continued parsing.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into an [Expr](ast_package_classes.md#class-expr) node. The exception includes error message information.

## func parsePattern(Tokens)

```cangjie
public func parsePattern(input: Tokens): Pattern
```

Function: Used to parse a set of lexical units and obtain a node of type [Pattern](ast_package_classes.md#class-pattern).

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.

Returns:

- [Pattern](ast_package_classes.md#class-pattern) - A node of type [Pattern](ast_package_classes.md#class-pattern).

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [Pattern](ast_package_classes.md#class-pattern) node. The exception includes error message information.

## func parsePatternFragment(Tokens, Int64)

```cangjie
public func parsePatternFragment(input: Tokens, startFrom!: Int64 = 0): (Pattern, Int64)
```

Function: Used to parse a set of lexical units and obtain a node of type [Pattern](ast_package_classes.md#class-pattern) along with the index for continued parsing.

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.
- startFrom!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The starting position.

Returns:

- ([Pattern](ast_package_classes.md#class-pattern), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The syntax tree node and the position for continued parsing.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [Pattern](ast_package_classes.md#class-pattern) node. The exception includes error message information.

## func parseProgram(Tokens)

```cangjie
public func parseProgram(input: Tokens): Program
```

Function: Used to parse the source code of a single Cangjie file and obtain a node of type [Program](ast_package_classes.md#class-program).

> **Note:**
>
> Expanded Cangjie macro code must not contain package declarations or import statements. When using this function, if the input source code contains package declarations or import statements, the output [Program](ast_package_classes.md#class-program) node will also include them (in the [packageHeader](ast_package_classes.md#prop-packageheader) and [importLists](ast_package_classes.md#prop-importlists) properties). Therefore, this node cannot be directly returned as [Tokens](ast_package_classes.md#class-tokens) in macro functions.

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`, with a default value of 128KB on Linux and Windows, 1MB on macOS, OHOS, and Android, and 2MB for sanitizer-enabled builds). When the nesting level of expressions or declarations in the source code to be parsed is too deep, a Segmentation fault may occur due to insufficient stack space. In this case, the issue can be resolved by increasing the value of `cjStackSize`, for example:
>
> ```shell
> export cjStackSize=1gb
> ```
>
> `cjStackSize` supports the units kb (KB), mb (MB), and gb (GB). The valid range is [64KB, 1GB] on Linux, macOS, OHOS, and Android, and [128KB, 1GB] on Windows. Values outside the range are invalid, and the default value will be used instead.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.

Returns:

- [Program](ast_package_classes.md#class-program) - A node of type [Program](ast_package_classes.md#class-program).

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [Program](ast_package_classes.md#class-program) node. The exception includes error message information.

## func parseType(Tokens)

```cangjie
public func parseType(input: Tokens): TypeNode
```

Function: Used to parse a set of lexical units and obtain a node of type [TypeNode](ast_package_classes.md#class-typenode).

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.

Returns:

- [TypeNode](ast_package_classes.md#class-typenode) - A node of type [TypeNode](ast_package_classes.md#class-typenode).

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [TypeNode](ast_package_classes.md#class-typenode) node.

## func parseTypeFragment(Tokens, Int64)

```cangjie
public func parseTypeFragment(input: Tokens, startFrom!: Int64 = 0): (TypeNode, Int64)
```

Function: Used to parse a set of lexical units and obtain a node of type [TypeNode](ast_package_classes.md#class-typenode) along with the index for continued parsing.

> **Note:**
>
> The parsing process is limited by the Cangjie thread stack size (controlled by the environment variable `cjStackSize`). Source code with excessively deep nesting may cause a Segmentation fault, which can be resolved by increasing the value of `cjStackSize`. For details, see the description of `parseProgram`.

Parameters:

- input: [Tokens](ast_package_classes.md#class-tokens) - The lexical units of the source code to be parsed.
- startFrom!: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The starting position.

Returns:

- ([TypeNode](ast_package_classes.md#class-typenode), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The syntax tree node and the position for continued parsing.

Exceptions:

- [ParseASTException](ast_package_exceptions.md#class-parseastexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [TypeNode](ast_package_classes.md#class-typenode) node.

## func setItem(String, Bool)

```cangjie
public func setItem(key: String, value: Bool): Unit
```

Function: Inner macros use this interface to send [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type information to outer macros.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The keyword used to retrieve the information.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type information to be sent.

## func setItem(String, Int64)

```cangjie
public func setItem(key: String, value: Int64): Unit
```

Function: Inner macros use this interface to send [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type information to outer macros.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The keyword used to retrieve the information.
- value: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type information to be sent.

## func setItem(String, String)

```cangjie
public func setItem(key: String, value: String): Unit
```

Function: Inner macros use this interface to send [String](../../core/core_package_api/core_package_structs.md#struct-string) type information to outer macros.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The keyword used to retrieve the information.
- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The [String](../../core/core_package_api/core_package_structs.md#struct-string) type information to be sent.

## func setItem(String, Tokens)

```cangjie
public func setItem(key: String, value: Tokens): Unit
```

Function: Inner macros use this interface to send [Tokens](ast_package_classes.md#class-tokens) type information to outer macros.

> **Note:**
>
> This function can only be called directly as a function and cannot be assigned to variables, used as arguments, or returned as values.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The keyword used to retrieve the information.
- value: [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) type information to be sent.