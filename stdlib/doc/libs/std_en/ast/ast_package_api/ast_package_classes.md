# Classes

## class Annotation

```cangjie
public class Annotation <: Node {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a compiler-built-in annotation node.

An [Annotation](ast_package_classes.md#class-annotation) node: `@CallingConv[xxx]`, `@Attribute[xxx]`, `@When[condition]`, etc.

Parent Type:

- [Node](#class-node)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

Function: Gets or sets the parameter sequence in [Annotation](ast_package_classes.md#class-annotation), such as `xxx` in `@CallingConv[xxx]`.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop at

```cangjie
public mut prop at: Token
```

Function: Gets or sets the `@` or `@!` operator in the [Annotation](ast_package_classes.md#class-annotation) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not an `@` or `@!` operator.

### prop attributes

```cangjie
public mut prop attributes: Tokens
```

Function: Gets or sets the attribute values set in `Attribute`, used only for `@Attribute`, such as `xxx` in `@Attribute[xxx]`.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop condition

```cangjie
public mut prop condition: Expr
```

Function: Gets or sets the conditional expression in conditional compilation, used for `@When`, such as `xxx` in `@When[xxx]`.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when there is no conditional expression in the [Annotation](ast_package_classes.md#class-annotation) node.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the identifier of the [Annotation](ast_package_classes.md#class-annotation) node, such as `CallingConv` in `@CallingConv[xxx]`.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [Annotation](ast_package_classes.md#class-annotation) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [Annotation](ast_package_classes.md#class-annotation) object from input tokens.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [Annotation](ast_package_classes.md#class-annotation) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [Annotation](ast_package_classes.md#class-annotation) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class Argument

```cangjie
public class Argument <: Node {
    public init()
}
```

Function: Represents a function call argument node.

For example, `arg:value` in `foo(arg:value)`.

Parent Type:

- [Node](#class-node)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the ":" operator in the [Argument](ast_package_classes.md#class-argument) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) token.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a ":" operator.

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression in the [Argument](ast_package_classes.md#class-argument) node, such as `value` in `arg:value`.

Type: [Expr](ast_package_classes.md#class-expr)

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the identifier in the [Argument](ast_package_classes.md#class-argument) node, such as `arg` in `arg:value`, which may be an [ILLEGAL](ast_package_enums.md#illegal) token.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the get/set [Token](ast_package_structs.md#struct-token) type is not an [IDENTIFIER](ast_package_enums.md#identifier) or the token's literal value is empty.

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `inout` keyword in the [Argument](ast_package_classes.md#class-argument) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) token.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [Argument](ast_package_classes.md#class-argument) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class ArrayLiteral

```cangjie
public class ArrayLiteral <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) literal node.

[ArrayLiteral](ast_package_classes.md#class-arrayliteral) node: Expressed in the format `[element1, element2, ... , elementN]`, where each `element` is an expression.

Parent Type:

- [Expr](#class-expr)

### prop elements

```cangjie
public mut prop elements: ArrayList<Expr>
```

Function: Gets or sets the expression list in [ArrayLiteral](ast_package_classes.md#class-arrayliteral).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

Function: Gets or sets the "[" in [ArrayLiteral](ast_package_classes.md#class-arrayliteral).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a "[".

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

Function: Gets or sets the "]" in [ArrayLiteral](ast_package_classes.md#class-arrayliteral).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a "]".

### init()

```cangjie
public init()
```

Function: Constructs a default [ArrayLiteral](ast_package_classes.md#class-arrayliteral) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [ArrayLiteral](ast_package_classes.md#class-arrayliteral) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ArrayLiteral](ast_package_classes.md#class-arrayliteral) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [ArrayLiteral](ast_package_classes.md#class-arrayliteral) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class AsExpr

```cangjie
public class AsExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a type-checking expression.

An [AsExpr](ast_package_classes.md#class-asexpr) expression: `e as T`, of type [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>. Here, `e` can be any type of expression, and `T` can be any type.

Parent Type:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression node in the [AsExpr](ast_package_classes.md#class-asexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `as` operator in the [AsExpr](ast_package_classes.md#class-asexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not an `as` operator.

### prop shiftType

```cangjie
public mut prop shiftType: TypeNode
```

Function: Gets or sets the target type in the [AsExpr](ast_package_classes.md#class-asexpr) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

Function: Constructs a default [AsExpr](ast_package_classes.md#class-asexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [AsExpr](ast_package_classes.md#class-asexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [AsExpr](ast_package_classes.md#class-asexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [AsExpr](ast_package_classes.md#class-asexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class AssignExpr

```cangjie
public class AssignExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an assignment expression node.

Used to modify the value of the left operand to the value of the right operand. An [AssignExpr](ast_package_classes.md#class-assignexpr) node: `a = b`.

Parent Type:

- [Expr](#class-expr)

### prop assign

```cangjie
public mut prop assign: Token
```

Function: Gets or sets the assignment operator (e.g., `=`) in the [AssignExpr](ast_package_classes.md#class-assignexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not an assignment operator.

### prop leftExpr

```cangjie
public mut prop leftExpr: Expr
```

Function: Gets or sets the left operand in the [AssignExpr](ast_package_classes.md#class-assignexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop rightExpr

```cangjie
public mut prop rightExpr: Expr
```

Function: Gets or sets the right operand in the [AssignExpr](ast_package_classes.md#class-assignexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

Function: Constructs a default [AssignExpr](ast_package_classes.md#class-assignexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [AssignExpr](ast_package_classes.md#class-assignexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [AssignExpr](ast_package_classes.md#class-assignexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [AssignExpr](ast_package_classes.md#class-assignexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class BinaryExpr

```cangjie
public class BinaryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a binary operation expression node.

A [BinaryExpr](ast_package_classes.md#class-binaryexpr) node: `a + b`, `a - b`, etc.

Parent Type:

- [Expr](#class-expr)

### prop leftExpr

```cangjie
public mut prop leftExpr: Expr
```

Function: Gets or sets the expression node on the left side of the operator in the [BinaryExpr](ast_package_classes.md#class-binaryexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

Function: Gets or sets the binary operator in the [BinaryExpr](ast_package_classes.md#class-binaryexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

### prop rightExpr

```cangjie
public mut prop rightExpr: Expr
```

Function: Gets or sets the expression node on the right side of the operator in the [BinaryExpr](ast_package_classes.md#class-binaryexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

Function: Constructs a default [BinaryExpr](ast_package_classes.md#class-binaryexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [BinaryExpr](ast_package_classes.md#class-binaryexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [BinaryExpr](ast_package_classes.md#class-binaryexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [BinaryExpr](ast_package_classes.md#class-binaryexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Block

```cangjie
public class Block <: Expr {
    public init()
}
```

Function: Represents a block node.

A [Block](ast_package_classes.md#class-block) is a structure consisting of a pair of matching curly braces and an optional sequence of expression declarations within them, referred to as a "block."

Parent Type:

- [Expr](#class-expr)

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the "{" in the [Block](ast_package_classes.md#class-block).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "{".

### prop nodes

```cangjie
public mut prop nodes: ArrayList<Node>
```

Function: Gets or sets the sequence of expressions or declarations within the [Block](ast_package_classes.md#class-block).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Node](ast_package_classes.md#class-node)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the "}" in the [Block](ast_package_classes.md#class-block).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "}".

### init()

```cangjie
public init()
```

Function: Constructs a default [Block](ast_package_classes.md#class-block) object.

> **Note:**
>
> A [Block](ast_package_classes.md#class-block) node cannot exist independently of expression or declaration nodes, so no other constructors are provided.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Body

```cangjie
public class Body <: Node {
    public init(decls: ArrayList<Decl>)
    public init()
}
```

Function: Represents the structure composed of `{}` and a set of internal declaration nodes within Class types, Struct types, Interface types, and extensions.

Parent Type:

- [Node](#class-node)

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

Function: Gets or sets the collection of declaration nodes within the [Body](ast_package_classes.md#class-body).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the `{` lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `{` lexical unit.

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the `}` lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `}` lexical unit.

### init()

```cangjie
public init()
```

Function: Constructs a default [Body](ast_package_classes.md#class-body) object.

### init(ArrayList\<Decl>)

```cangjie
public init(decls: ArrayList<Decl>)
```

Function: Constructs a [Body](ast_package_classes.md#class-body) object.

Parameters:

- decls: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)> - The declaration list to construct the [Body](ast_package_classes.md#class-body) type.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class CallExpr

```cangjie
public class CallExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a function call node.

A [CallExpr](ast_package_classes.md#class-callexpr) node includes an expression followed by a parameter list, e.g., `foo(100)`.

Parent Type:

- [Expr](#class-expr)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

Function: Gets or sets the function parameters in the [CallExpr](ast_package_classes.md#class-callexpr) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop callFunc

```cangjie
public mut prop callFunc: Expr
```

Function: Gets or sets the function call node in the [CallExpr](ast_package_classes.md#class-callexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in the [CallExpr](ast_package_classes.md#class-callexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

<!--Del_sink-->
### prop modal

```cangjie
public mut prop modal: ModalInfo
```

Function: Gets or sets the modal type after the constructor call in the [CallExpr](ast_package_classes.md#class-callexpr) node, that is, the local modal type, such as `@ local!` in `C() @ local!`.

Type: [ModalInfo](ast_package_classes.md#class-modalinfo)

> **Note:**
>
> The local mode is an experimental feature and requires both the `--experimental` and `--enable-local-mode` compiler options. When no mode is annotated, this property is an empty [ModalInfo](ast_package_classes.md#class-modalinfo) object (that is, [isEmpty](ast_package_classes.md#func-isempty) returns `true`).
<!--DelEnd_sink-->
### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in the [CallExpr](ast_package_classes.md#class-callexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [CallExpr](ast_package_classes.md#class-callexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [CallExpr](ast_package_classes.md#class-callexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [CallExpr](ast_package_classes.md#class-callexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [CallExpr](ast_package_classes.md#class-callexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ClassDecl

```cangjie
public class ClassDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Class definition node.

Class definitions use the `class` keyword, consisting of: optional modifiers, the `class` keyword, class name, optional type parameters, optional parent class or interface specification, optional generic constraints, and class body definition.

Parent Type:

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

Function: Gets or sets the class body of the [ClassDecl](ast_package_classes.md#class-classdecl) node.

Type: [Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexical units in the parent class or interface declaration of the [ClassDecl](ast_package_classes.md#class-classdecl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `&` lexical units.

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

Function: Gets or sets the parent class or interface of the [ClassDecl](ast_package_classes.md#class-classdecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not the `<:` operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [ClassDecl](ast_package_classes.md#class-classdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ClassDecl](ast_package_classes.md#class-classdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ClassDecl](ast_package_classes.md#class-classdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [ClassDecl](ast_package_classes.md#class-classdecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class CommandTypePattern

```cangjie
public class CommandTypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents a command pattern with type annotations, e.g.: `pattern: Type1 | Type2 | ...`.

An example of a [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) node:
`someCommand: Effect`

Parent Type:

- [Pattern](ast_package_classes.md#class-pattern)

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Function: Gets or sets the command pattern before the colon (`:`).

Type: [Pattern](ast_package_classes.md#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the colon (`:`) token used to separate the pattern from types.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown if the provided token is not a colon.

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

Function: Gets or sets the list of type nodes after the colon, e.g.: `String | Int | Float`.

Type: [ArrayList\<TypeNode>](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

Function: Constructs a default [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) object from a token stream.

Parameters:

* `inputs`: [Tokens](ast_package_classes.md#class-tokens) — The collection of tokens to be parsed into a `CommandTypePattern` node.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown if the input tokens cannot be parsed into a valid `CommandTypePattern` node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ConstPattern

```cangjie
public class ConstPattern <: Pattern {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a constant pattern node.

A constant pattern can be an integer literal, character/byte literal, floating-point literal, character literal, boolean literal, string literal, etc., such as `1` in `case 1 => 0`.

Parent Type:

- [Pattern](#class-pattern)

### prop litConstExpr

```cangjie
public mut prop litConstExpr: LitConstExpr
```

Function: Gets or sets the literal expression in the [ConstPattern](ast_package_classes.md#class-constpattern) node.

Type: [LitConstExpr](ast_package_classes.md#class-litconstexpr)

### init()

```cangjie
public init()
```

Function: Constructs a default [ConstPattern](ast_package_classes.md#class-constpattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ConstPattern](ast_package_classes.md#class-constpattern) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ConstPattern](ast_package_classes.md#class-constpattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [ConstPattern](ast_package_classes.md#class-constpattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Constructor

```cangjie
public class Constructor <: Node {
    public init()
}
```

Function: Represents a [Constructor](ast_package_classes.md#class-constructor) node in an `enum` type.

A [Constructor](ast_package_classes.md#class-constructor) node: In `enum TimeUnit { Year | Month([Float32](../../core/core_package_api/core_package_intrinsics.md#float32), [Float32](../../core/core_package_api/core_package_intrinsics.md#float32))}`, `Year` and `Month([Float32](../../core/core_package_api/core_package_intrinsics.md#float32), [Float32](../../core/core_package_api/core_package_intrinsics.md#float32))` are constructors.

> **Note:**
>
> A [Constructor](ast_package_classes.md#class-constructor) may have no parameters or a set of parameters of different types.

Parent Type:

- [Node](#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

Function: Gets or sets the list of annotations applied to the [Constructor](ast_package_classes.md#class-constructor) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the identifier lexical unit of the [Constructor](ast_package_classes.md#class-constructor).

Type: [Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" lexical unit in the [Constructor](ast_package_classes.md#class-constructor) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" lexical unit in the [Constructor](ast_package_classes.md#class-constructor) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

Function: Gets or sets the optional collection of parameter type nodes for the [Constructor](ast_package_classes.md#class-constructor) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [Constructor](ast_package_classes.md#class-constructor) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Decl

```cangjie
public open class Decl <: Node {
    protected var annotations_: ArrayList<Annotation> = ArrayList<Annotation>()
    protected var modifiers_: ArrayList<Modifier> = ArrayList<Modifier>()
    protected var keyword_: Token = Token()
    protected var identifier_: Token = Token()
    protected var node: Node = Expr()
}
```

Function: The parent class of all declaration nodes, inheriting from the [Node](ast_package_classes.md#class-node) class, providing common interfaces for all declaration nodes.

> **Note:**
>
> Class definitions, interface definitions, function definitions, variable definitions, enum definitions, struct definitions, extension definitions, type alias definitions, macro definitions, etc., all belong to the [Decl](ast_package_classes.md#class-decl) node.

Parent Type:

- [Node](#class-node)

### var annotations_

```cangjie
protected var annotations_: ArrayList<Annotation> = ArrayList<Annotation>()
```

Function: Gets or sets the list of annotations applied to the [Decl](ast_package_classes.md#class-decl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### var identifier_

```cangjie
protected var identifier_: Token = Token()
```

Function: Gets or sets the identifier of the declaration node, such as `foo` in `class foo {}`.

Type: [Token](ast_package_structs.md#struct-token)

### var keyword_

```cangjie
protected var keyword_: Token = Token()
```

Function: Gets or sets the keyword of the declaration node.

Type: [Token](ast_package_structs.md#struct-token)

### var modifiers_

```cangjie
protected var modifiers_: ArrayList<Modifier> = ArrayList<Modifier>()
```

Function: Gets or sets the modifier list of the node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Modifier](ast_package_classes.md#class-modifier)>

### var node

```cangjie
protected var node: Node = Expr()
```

Function: Gets or sets the parameter node of the [Decl](ast_package_classes.md#class-decl) node.

Type: [Node](ast_package_classes.md#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

Function: Gets or sets the list of annotations applied to the [Decl](ast_package_classes.md#class-decl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop constraintCommas

```cangjie
public mut prop constraintCommas: Tokens
```

Function: Gets or sets the sequence of "," lexical units in the [Decl](ast_package_classes.md#class-decl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop genericConstraint

```cangjie
public mut prop genericConstraint: ArrayList<GenericConstraint>
```

Function: Gets or sets the generic constraints of the declaration node, which may be empty, such as `where T <: Comparable<T>` in `func foo<T>() where T <: Comparable<T> {}`.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[GenericConstraint](ast_package_classes.md#class-genericconstraint)>

### prop genericParam

```cangjie
public mut prop genericParam: GenericParam
```

Function: Gets or sets the parameter list. The type parameter list is enclosed in `<>`, with multiple type parameters separated by commas.

Type: [GenericParam](ast_package_classes.md#class-genericparam)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the node does not define a type parameter list.

### prop identifier

```cangjie
public mut open prop identifier: Token
```

Function: Gets or sets the identifier of the declaration node, such as `foo` in `class foo {}`.

Type: [Token](ast_package_structs.md#struct-token)

### prop isGenericDecl

```cangjie
public mut prop isGenericDecl: Bool
```

Function: Determines whether the node is a generic node.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a generic node; otherwise, false.

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the keyword of the declaration node.

Type: [Token](ast_package_structs.md#struct-token)

### prop modifiers

```cangjie
public mut prop modifiers: ArrayList<Modifier>
```

Function: Gets or sets the modifier list of the node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Modifier](ast_package_classes.md#class-modifier)>

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

Function: Converts the current syntax tree node into a tree structure and prints it. The tree structure of the syntax tree node will be output in the following format:

- `-` string: Represents the public attributes of the current node, such as `-keyword`, `-identifier`.
- The node attribute is followed by the specific type of the node, such as `-declType: PrimitiveType` indicating the node type is a [PrimitiveType](ast_package_classes.md#class-primitivetype) node.
- Each type uses braces to denote its scope.

For detailed syntax tree output format, see [Syntax Tree Node Printing](../ast_samples/dump.md).

Parameters:

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number of indentation spaces for formatted output.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted output content.

### func getAttrs()

```cangjie
public func getAttrs(): Tokens
```

Function: Gets the attributes of the current node (typically set via the built-in `Attribute` to assign attribute values to a declaration).

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The attributes of the current node.

### func hasAttr(String)

```cangjie
public func hasAttr(attr: String): Bool
```

Function: Determines whether the current node has a specific attribute (typically set via the built-in `Attribute` to assign attribute values to a declaration).

Parameters:

- attr: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The attribute to check for presence in the current node.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the current node has the attribute; otherwise, false.

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class DoWhileExpr

```cangjie
public class DoWhileExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `do-while` expression.

Parent Type:

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the block expression within [DoWhileExpr](ast_package_classes.md#class-dowhileexpr).

Type: [Block](ast_package_classes.md#class-block)

### prop condition

```cangjie
public mut prop condition: Expr
```

Function: Gets or sets the conditional expression within the [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) keyword.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keywordD

```cangjie
public mut prop keywordD: Token
```

Function: Gets or sets the `do` keyword in the [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) node, where the 'D' in keywordD is the capitalized first letter of the keyword `do`, representing the `do` keyword.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `do` keyword.

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

Function: Gets or sets the `while` keyword in the [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) node, where the 'W' in keywordW is the capitalized first letter of the keyword `while`, representing the `while` keyword.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `while` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" after the `while` keyword in [DoWhileExpr](ast_package_classes.md#class-dowhileexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" after the `while` keyword in [DoWhileExpr](ast_package_classes.md#class-dowhileexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class EnumDecl

```cangjie
public class EnumDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an `Enum` definition node.

Enum definitions use the `enum` keyword, defined in order as: optional modifiers, enum keyword, enum name, optional type parameters, whether to specify parent interfaces, optional generic constraints, and enum body definitions.

Parent Type:

- [Decl](#class-decl)

### prop constructors

```cangjie
public mut prop constructors: ArrayList<Constructor>
```

Function: Gets or sets the constructor members within the [EnumDecl](ast_package_classes.md#class-enumdecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Constructor](ast_package_classes.md#class-constructor)>

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

Function: Gets or sets other members within the [EnumDecl](ast_package_classes.md#class-enumdecl) node excluding constructors.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop ellipsis

```cangjie
public mut prop ellipsis: Token
```

Function: Gets or sets the optional `...` lexical unit in the [EnumDecl](ast_package_classes.md#class-enumdecl) node, which may be of the [ILLEGAL](ast_package_enums.md#illegal) lexical unit type.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `...` lexical unit.

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the `{` lexical unit type in the [EnumDecl](ast_package_classes.md#class-enumdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `{` lexical unit type.

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the `}` lexical unit type in the [EnumDecl](ast_package_classes.md#class-enumdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `}` lexical unit type.

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexical units in the parent interface declaration of the [EnumDecl](ast_package_classes.md#class-enumdecl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Tokens](ast_package_classes.md#class-tokens) is not the `&` lexical unit sequence.

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

Function: Gets or sets the parent interfaces of the [EnumDecl](ast_package_classes.md#class-enumdecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `<:` operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [EnumDecl](ast_package_classes.md#class-enumdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [EnumDecl](ast_package_classes.md#class-enumdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [EnumDecl](ast_package_classes.md#class-enumdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [EnumDecl](ast_package_classes.md#class-enumdecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class EnumPattern

```cangjie
public class EnumPattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents an enum pattern node.

Used to match enum `constructors`, such as `Year(n)` in `case Year(n) => 1`.

Parent Type:

- [Pattern](#class-pattern)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Function: Gets or sets the "," lexical unit sequence in the [EnumPattern](ast_package_classes.md#class-enumpattern) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Tokens](ast_package_classes.md#class-tokens) is not the "," lexical unit sequence.

### prop constructor

```cangjie
public mut prop constructor: Expr
```

Function: Gets or sets the constructor expression node in the [EnumPattern](ast_package_classes.md#class-enumpattern) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" lexical unit in the [EnumPattern](ast_package_classes.md#class-enumpattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

Function: Gets or sets the list of pattern nodes within the parameterized constructor in the [EnumPattern](ast_package_classes.md#class-enumpattern) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" lexical unit in the [EnumPattern](ast_package_classes.md#class-enumpattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [EnumPattern](ast_package_classes.md#class-enumpattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [EnumPattern](ast_package_classes.md#class-enumpattern) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [EnumPattern](ast_package_classes.md#class-enumpattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [EnumPattern](ast_package_classes.md#class-enumpattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ExceptTypePattern

```cangjie
public class ExceptTypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents a node for exception pattern states.

Example: `e: Exception1 | Exception2`.

Parent Types:

- [Pattern](#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the ":" operator lexical unit in the [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a ":" operator.

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Function: Gets or sets the pattern node in the [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) node.

Type: [Pattern](ast_package_classes.md#class-pattern)

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

Function: Gets or sets the type list in the [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

<!--Del_sink-->
## class ExclaveExpr

```cangjie
public class ExclaveExpr <: Expr {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents an `exclave` expression node, that is, the `exclave { ... }` block expression.

> **Note:**
>
> The `exclave` expression is related to the local mode. The local mode is an experimental feature and requires both the `--experimental` and `--enable-local-mode` compiler options.

Parent Type:

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the block in the [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) node.

Type: [Block](ast_package_classes.md#class-block)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `exclave` keyword in the [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `exclave` keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - the lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) object.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as an [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Return Value:

- [Tokens](ast_package_classes.md#class-tokens) - the converted [Tokens](ast_package_classes.md#class-tokens) node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.
<!--DelEnd_sink-->
## class Expr

```cangjie
public open class Expr <: Node {}
```

Function: The parent class of all expression nodes, inheriting from the [Node](ast_package_classes.md#class-node) node.

The `toTokens` method of expression nodes adds parentheses based on operator precedence. For example, given a [BinaryExpr](ast_package_classes.md#class-binaryexpr) node a \* b, if the left expression a is modified to a + 1, the `toTokens` method will add parentheses to the left expression, outputting (a + 1) \* b.

Parent Types:

- [Node](#class-node)

### func dump(UInt16)

```cangjie
protected open func dump(_: UInt16): String
```

Function: Converts the current syntax tree node into a tree structure format and prints it. Must be overridden by subclasses.

Parameters:

- _: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number of indentation spaces for formatted output.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted output content.

### func precedence()

```cangjie
protected open func precedence(): Int64
```

Function: Returns the precedence of the current expression node.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) -The precedence of the current expression node.

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ExtendDecl

```cangjie
public class ExtendDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an extension definition node.

Extension definitions use the `extend` keyword, followed by the extended type, optional parent interface specification, optional generic constraints, and the extension body definition.

Parent Types:

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

Function: Gets or sets the class body of the [ExtendDecl](ast_package_classes.md#class-extenddecl) node.

Type: [Body](ast_package_classes.md#class-body)

### prop extendType

```cangjie
public mut prop extendType: TypeNode
```

Function: Gets or sets the type being extended.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop identifier

```cangjie
public mut override prop identifier: Token
```

Function: The [ExtendDecl](ast_package_classes.md#class-extenddecl) node inherits from the [Decl](ast_package_classes.md#class-decl) node but does not support the `identifier` property. An exception is thrown when used.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the `identifier` property is used.

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexical units in the parent interface declaration of the [ExtendDecl](ast_package_classes.md#class-extenddecl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `&` lexical units.

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

Function: Gets or sets the parent interfaces of the [ExtendDecl](ast_package_classes.md#class-extenddecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `<:` operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [ExtendDecl](ast_package_classes.md#class-extenddecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [ExtendDecl](ast_package_classes.md#class-extenddecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [ExtendDecl](ast_package_classes.md#class-extenddecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [ExtendDecl](ast_package_classes.md#class-extenddecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.
## class FeatureId

```cangjie
public class FeatureId <: Node {
    public init()
}
```

Function: Represents a feature name node.

> **Note:**
>
> Feature identifier consists of usual identifiers which separe by dots. Feature name can not be escaped by backticks.

Parent Type:

- [Node](#class-node)

### prop dots

Function: Gets or sets the lexical unit sequence of the dots separating identifiers in the feature name in the [FeatureId](ast_package_classes.md#class-featureid) node. For example, the two "." in `features { user.define.sample }`.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "." lexical units.

### prop identifiers

Function: Gets of sets the identifiers of the [FeatureId](ast_package_classes.md#class-featureid) node.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "IDENTIFIER" lexical units.

### init()

```cangjie
public init()
```

Function: Constructs a default [FeaturesSet](ast_package_classes.md#class-featuresset) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate child node traversal early, override the `visit` function and call the `breakTraverse` function to terminate traversal behavior. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class FeaturesDirective

```cangjie
public class FeaturesDirective <: Node {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a features directive node.

A [FeaturesDirective](ast_package_classes.md#class-featuresdirective) node: `feature define`.

> **Note:**
>
> Features directive declaration must start with keyword `features`, followed by the [features set](), and must appear before the package header of the source file.

Parent Type:

- [Node](#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

Function: Gets or sets the list of annotations applied to the [FeaturesDirective](ast_package_classes.md#class-featuresdirective) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop featuresSet

```cangjie
public mut prop featuresSet: FeaturesSet
```

Function: Gets or sets the [FeaturesDirective](ast_package_classes.md#class-featuresdirective) node with features names.

Type: [FeaturesSet](ast_package_classes.md#class-featuresset)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `features` keyword lexical unit in the [FeaturesDirective](ast_package_classes.md#class-featuresdirective) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `features` keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [FeaturesDirective](ast_package_classes.md#class-featuresdirective) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [FeaturesDirective](ast_package_classes.md#class-featuresdirective) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) sequence used to construct the [PackageHeader](ast_package_classes.md#class-featuresdirective) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PackageHeader](ast_package_classes.md#class-featuresdirective) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate child node traversal early, override the `visit` function and call the `breakTraverse` function to terminate traversal behavior. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class FeaturesSet

```cangjie
public class FeaturesSet <: Node {
    public init()
}
```

Function: Represents a features set which contains names of featurs.

A [FeaturesSet](ast_package_classes.md#class-featuresset) node: `features set define`.

> **Note:**
>
> Features set must start with `{` and end with `}`. Features set contains set of [featuresId](ast_package_classes.md#class-featureid).

Parent Type:

- [Node](#class-node)

### prop commas

```cangjie
public mut prop commas: Tokens 
```

Function: Gets or sets the sequence of `,` lexical units in the [MemberAccess](ast_package_classes.md#class-memberaccess) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop content

```cangjie
public mut prop content: ArrayList<FeatureId> 
```

Function: Gets of sets the content of the [FeaturesSet](ast_package_classes.md#class-featureset) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[featuresId](ast_package_classes.md#class-featureid)>

### prop lCurl

```cangjie
public mut prop lCurl: Token
```

Function: Gets or sets the `{` in the [FeaturesSet](ast_package_classes.md#class-featureset) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `{`.

### prop rCurl

```cangjie
public mut prop rCurl: Token
```

Function: Gets or sets the `}` in the [FeaturesSet](ast_package_classes.md#class-featureset) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `}`.

### init()

```cangjie
public init()
```

Function: Constructs a default [FeaturesSet](ast_package_classes.md#class-featuresset) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate child node traversal early, override the `visit` function and call the `breakTraverse` function to terminate traversal prematurely. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ForInExpr

```cangjie
public class ForInExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `for-in` expression.

In the [ForInExpr](ast_package_classes.md#class-forinexpr) type, the keyword `for` is followed by a [Pattern](ast_package_classes.md#class-pattern), then an `in` keyword and an expression node, and finally a loop body [Block](ast_package_classes.md#class-block).

Parent Types:

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the loop body in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Block](ast_package_classes.md#class-block)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop keywordF

```cangjie
public mut prop keywordF: Token
```

Function: Gets or sets the `for` keyword in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `for` keyword.

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

Function: Gets or sets the `in` keyword in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not an `in` keyword.

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

Function: Gets or sets the `where` keyword in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `where` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" after the `for` keyword in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a "(".

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Function: Gets or sets the [Pattern](ast_package_classes.md#class-pattern) node in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Pattern](ast_package_classes.md#class-pattern)

### prop patternGuard

```cangjie
public mut prop patternGuard: Expr
```

Function: Gets or sets the `patternGuard` conditional expression in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the `patternGuard` expression does not exist in the [ForInExpr](ast_package_classes.md#class-forinexpr) node.

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in [ForInExpr](ast_package_classes.md#class-forinexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [ForInExpr](ast_package_classes.md#class-forinexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ForInExpr](ast_package_classes.md#class-forinexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [ForInExpr](ast_package_classes.md#class-forinexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ForInExpr](ast_package_classes.md#class-forinexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class FuncDecl

```cangjie
public class FuncDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a function declaration node.

Defined by optional function modifiers, the `func` keyword, function name, optional type parameter list, function parameters, and optional return type. A function declaration must include a function body, which is a block.

Parent Type:

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

Purpose: Gets or sets the function body of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

Purpose: Gets or sets the colon token of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a colon.

### prop declType

```cangjie
public mut prop declType: TypeNode
```

Purpose: Gets or sets the return type of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the return type of the [FuncDecl](ast_package_classes.md#class-funcdecl) node is a default value.

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

Purpose: Gets or sets the function parameters of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Purpose: Gets or sets the "(" token of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

<!--Del_sink-->
### prop modal

```cangjie
public mut prop modal: ModalInfo
```

Purpose: Gets or sets the modal type before the function keyword of the [FuncDecl](ast_package_classes.md#class-funcdecl) node, that is, the local modal type, such as `@ local?` in the nested function definition `@ local? func length(): Int64 { ... }`. It is different from the modal type written after a parameter type or return type: only nested functions support annotating a mode before the `func` keyword, which is used to declare that the nested function can capture outer non-`Copyable` variables of `@ local?`.

Type: [ModalInfo](ast_package_classes.md#class-modalinfo)

> **Note:**
>
> The local mode is an experimental feature and requires both the `--experimental` and `--enable-local-mode` compiler options. When no mode is annotated, this property is an empty [ModalInfo](ast_package_classes.md#class-modalinfo) object.
<!--DelEnd_sink-->
### prop overloadOp

```cangjie
public mut prop overloadOp: Tokens
```

Purpose: Gets or sets the overload operator of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Purpose: Gets or sets the ")" token of the [FuncDecl](ast_package_classes.md#class-funcdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

<!--Del_sink-->
### prop thisParam

```cangjie
public mut prop thisParam: Option<ThisParam>
```

Purpose: Gets or sets the explicit `this` parameter of the [FuncDecl](ast_package_classes.md#class-funcdecl) node, that is, `this @ local!` in the parameter list of a member function or constructor. When no `this` parameter is declared, this property is `None`.

Type: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[ThisParam](ast_package_classes.md#class-thisparam)>
<!--DelEnd_sink-->
### init()

```cangjie
public init()
```

Purpose: Constructs a default [FuncDecl](ast_package_classes.md#class-funcdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [FuncDecl](ast_package_classes.md#class-funcdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [FuncDecl](ast_package_classes.md#class-funcdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [FuncDecl](ast_package_classes.md#class-funcdecl) node.

### func isConst()

```cangjie
public func isConst(): Bool
```

Purpose: Determines whether the node is of `Const` type.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a `Const` type node; otherwise, returns `false`.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class FuncParam

```cangjie
public open class FuncParam <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a function parameter node, including both named and unnamed parameters.

A [FuncParam](ast_package_classes.md#class-funcparam) node: In `func foo(a: Int64, b: Float64) {...}`, `a: Int64` and `b: Float64` are [FuncParam](ast_package_classes.md#class-funcparam) nodes.

Parent Type:

- [Decl](#class-decl)

### prop assign

```cangjie
public mut prop assign: Token
```

Purpose: Gets or sets the `=` token for function parameters with default values.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `=`.

### prop colon

```cangjie
public mut prop colon: Token
```

Purpose: Gets or sets the ":" token in the parameter.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ":".

### prop expr

```cangjie
public mut prop expr: Expr
```

Purpose: Gets or sets the variable initialization node for function parameters with default values.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the function parameter is not initialized.

### prop not

```cangjie
public mut prop not: Token
```

Purpose: Gets or sets the `!` token for named parameters.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `!`.

### prop paramType

```cangjie
public mut prop paramType: TypeNode
```

Purpose: Gets or sets the type of the function parameter.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [FuncParam](ast_package_classes.md#class-funcparam) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [FuncParam](ast_package_classes.md#class-funcparam) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [FuncParam](ast_package_classes.md#class-funcparam) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [FuncParam](ast_package_classes.md#class-funcparam) node.

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

Purpose: Converts the current syntax tree node into a tree-structured format and prints it.

Parameters:

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number of indentation spaces for formatted output.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted output content.

### func isMemberParam()

```cangjie
public func isMemberParam(): Bool
```

Purpose: Determines whether the current function parameter is a parameter in the primary constructor.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a parameter in the primary constructor.

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class FuncType

```cangjie
public class FuncType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a function type node.

Composed of function parameter types and return type, separated by `->`, e.g., `(Int32) -> Unit`.

Parent Type:

- [TypeNode](#class-typenode)

### prop arrow

```cangjie
public mut prop arrow: Token
```

Purpose: Gets or sets the `->` token between parameter types and return type in the [FuncType](ast_package_classes.md#class-functype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `->`.

### prop commas

```cangjie
public mut prop commas: Tokens
```

Purpose: Gets or sets the sequence of "," tokens in the [FuncType](ast_package_classes.md#class-functype) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," tokens.

### prop keyword

```cangjie
public mut prop keyword: Token
```

Purpose: Gets or sets the `CFunc` keyword token in the [FuncType](ast_package_classes.md#class-functype) node. If it is not a `CFunc` type, returns an [ILLEGAL](ast_package_enums.md#illegal) token.

Type: [Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Purpose: Gets or sets the "(" token in the [FuncType](ast_package_classes.md#class-functype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Purpose: Gets or sets the ")" token in the [FuncType](ast_package_classes.md#class-functype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop returnType

```cangjie
public mut prop returnType: TypeNode
```

Purpose: Gets or sets the return type node of the [FuncType](ast_package_classes.md#class-functype) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

Purpose: Gets or sets the list of parameter types in the [FuncType](ast_package_classes.md#class-functype) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Purpose: Constructs a default [FuncType](ast_package_classes.md#class-functype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [FuncType](ast_package_classes.md#class-functype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [FuncType](ast_package_classes.md#class-functype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [FuncType](ast_package_classes.md#class-functype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class GenericConstraint

```cangjie
public class GenericConstraint <: Node {
    public init()
}
```

Function: Represents a generic constraint node.

A [GenericConstraint](ast_package_classes.md#class-genericconstraint) node: `where U <: Bounded` in `interface Enumerable<U> where U <: Bounded {}`.

> **Note:**
>
> Declared via the `<:` operator after `where`, consisting of a lower bound and an upper bound. The left side of `<:` is called the constraint's lower bound, which can only be a type variable. The right side of `<:` is called the constraint's upper bound, which can be a type.

Parent Type:

- [Node](#class-node)

### prop bitAnds

```cangjie
public mut prop bitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexemes in the [GenericConstraint](ast_package_classes.md#class-genericconstraint) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `&` lexemes.

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `where` keyword lexeme in the [GenericConstraint](ast_package_classes.md#class-genericconstraint) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexeme.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `where` keyword.

### prop typeArgument

```cangjie
public mut prop typeArgument: TypeNode
```

Function: Gets or sets the constraint's lower bound in the [GenericConstraint](ast_package_classes.md#class-genericconstraint) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator in the [GenericConstraint](ast_package_classes.md#class-genericconstraint) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `<:` operator.

### prop upperBounds

```cangjie
public mut prop upperBounds: ArrayList<TypeNode>
```

Function: Gets or sets the collection of [TypeNode](ast_package_classes.md#class-typenode) type nodes representing the constraint's upper bounds in the [GenericConstraint](ast_package_classes.md#class-genericconstraint) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [GenericConstraint](ast_package_classes.md#class-genericconstraint) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class GenericParam

```cangjie
public class GenericParam <: Node {
    public init(parameters: Tokens)
    public init()
}
```

Function: Represents a type parameter node.

A [GenericParam](ast_package_classes.md#class-genericparam) node: `<T1, T2, T3>`.

> **Note:**
>
> Type parameters are enclosed in `<>` and separated by "," for multiple type parameter names.

Parent Type:

- [Node](#class-node)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Function: Gets or sets the left angle bracket lexeme in the [GenericParam](ast_package_classes.md#class-genericparam) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop parameters

```cangjie
public mut prop parameters: Tokens
```

Function: Gets or sets the [Tokens](ast_package_classes.md#class-tokens) type representing the type parameters in the [GenericParam](ast_package_classes.md#class-genericparam) node, which may be empty, such as `T1`, `T2`, and `T3` in `<T1, T2, T3>`.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Function: Gets or sets the right angle bracket lexeme in the [GenericParam](ast_package_classes.md#class-genericparam) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### init()

```cangjie
public init()
```

Function: Constructs a default [GenericParam](ast_package_classes.md#class-genericparam) object.

### init(Tokens)

```cangjie
public init(parameters: Tokens)
```

Function: Constructs a [GenericParam](ast_package_classes.md#class-genericparam) object.

Parameters:

- parameters: [Tokens](ast_package_classes.md#class-tokens) - The lexeme collection ([Tokens](ast_package_classes.md#class-tokens)) of type parameters to construct the [GenericParam](ast_package_classes.md#class-genericparam).

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Handler

```cangjie
public class Handler {
}
```

Function: Represents a `handle` clause containing a command pattern and the code block to be executed.

An example of a [Handler](ast_package_classes.md#class-handler) node:
`handle (e: Command<Unit>) { ... }`

## class IfExpr

```cangjie
public class IfExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a conditional expression.

Determines which code branch to execute based on whether the condition is met. In an [IfExpr](ast_package_classes.md#class-ifexpr) node, `if` is a keyword, followed by parentheses containing either an expression or a `let` declaration for destructuring matching, then a [Block](ast_package_classes.md#class-block), followed by an optional `else` branch. The `else` branch starts with the `else` keyword, followed by a new `if` expression or a [Block](ast_package_classes.md#class-block).

Parent Type:

- [Expr](#class-expr)

### prop condition

```cangjie
public mut prop condition: Expr
```

Function: Gets or sets the condition expression after `if` in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop elseExpr

```cangjie
public mut prop elseExpr: Expr
```

Function: Gets or sets the `else` branch node in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the current [IfExpr](ast_package_classes.md#class-ifexpr) node has no `else` branch node.

### prop ifBlock

```cangjie
public mut prop ifBlock: Block
```

Function: Gets or sets the `block` node after `if` in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Block](ast_package_classes.md#class-block)

### prop keywordE

```cangjie
public mut prop keywordE: Token
```

Function: Gets or sets the `else` keyword in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `else` keyword.

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

Function: Gets or sets the `if` keyword in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `if` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" after `if` in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" after `if` in the [IfExpr](ast_package_classes.md#class-ifexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [IfExpr](ast_package_classes.md#class-ifexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [IfExpr](ast_package_classes.md#class-ifexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexeme collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [IfExpr](ast_package_classes.md#class-ifexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [IfExpr](ast_package_classes.md#class-ifexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ImportContent

```cangjie
public class ImportContent <: Node {
    public init()
}
```

Function: Represents the specific declaration content of a package import statement node, such as `pkg.a.b` in import `pkg.a.b`.

Parent Type:

- [Node](#class-node)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Function: Gets or sets the sequence of "," lexemes in the [ImportContent](ast_package_classes.md#class-importcontent) node, which is non-empty only when `importKind` is `ImportKind.Multi`.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexemes.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the imported item in the [ImportContent](ast_package_classes.md#class-importcontent) node, which may be a top-level definition or declaration in the package or the name of a subpackage.

Type: [Token](ast_package_structs.md#struct-token)

### prop importAlias

```cangjie
public mut prop importAlias: Tokens
```

Function: Gets or sets the sequence of lexemes representing the alias of the imported definition or declaration in the [ImportContent](ast_package_classes.md#class-importcontent) node, which is non-empty only when `importKind` is `ImportKind.Alias`. For example, `as yyy` in `import packageName.xxx as yyy`.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop importKind

```cangjie
public mut prop importKind: ImportKind
```

Function: Gets or sets the import type in the [ImportContent](ast_package_classes.md#class-importcontent) node.

Type: [ImportKind](ast_package_enums.md#enum-importkind)

### prop items

```cangjie
public mut prop items: ArrayList<ImportContent>
```

Function: Gets or sets all imported items in the [ImportContent](ast_package_classes.md#class-importcontent) node, which is non-empty only when `importKind` is `ImportKind.Multi`.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[ImportContent](ast_package_classes.md#class-importcontent)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the "{" operator lexeme in the [ImportContent](ast_package_classes.md#class-importcontent) node, which is non-empty only when `importKind` is `ImportKind.Multi`.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "{" operator.

### prop orgName

```cangjie
public mut prop orgName: Token
```

Function: Gets or sets the lexical unit representing organization name in the [ImportContent](ast_package_classes.md#class-importcontent) node, setter would check if orgSeparator is "::" operator lexeme, set it to "::" if not.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) has a value of empty string.

### prop orgSeparator

```cangjie
public mut prop orgSeparator: Token
```

Function: Gets or sets the "::" operator lexeme in the [ImportContent](ast_package_classes.md#class-importcontent) node, setter would check if orgName has a value of empty string, throw exception if it does.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "::" operator or orgName has a value of empty string.

### prop prefixPaths

```cangjie
public mut prop prefixPaths: Tokens
```

Function: Gets or sets the sequence of lexemes representing the prefix part of the full package name in the [ImportContent](ast_package_classes.md#class-importcontent) node, which may be empty. For example, `a` and `b` in `import a.b.c`.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop prefixDots

```cangjie
public mut prop prefixDots: Tokens
```

Function: Gets or sets the sequence of lexemes used to separate each subpackage level in the full package name in the [ImportContent](ast_package_classes.md#class-importcontent) node, which may be empty. For example, the two "." in `import a.b.c`.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "." lexemes.

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the "}" operator lexeme in the [ImportContent](ast_package_classes.md#class-importcontent) node, which is non-empty only when `importKind` is `ImportKind.Multi`.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "}" operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [ImportContent](ast_package_classes.md#class-importcontent) object.

### func isImportAlias()

```cangjie
public func isImportAlias(): Bool
```

Function: Determines whether the [ImportContent](ast_package_classes.md#class-importcontent) node has an alias for the imported item.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Whether the [ImportContent](ast_package_classes.md#class-importcontent) node has an alias for## class ImportList

### func isImportAll()

```cangjie
public func isImportAll(): Bool
```

Function: Determines whether the [ImportContent](ast_package_classes.md#class-importcontent) node is a wildcard import.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Indicates whether the [ImportContent](ast_package_classes.md#class-importcontent) node is a wildcard import.

### func isImportMulti()

```cangjie
public func isImportMulti(): Bool
```

Function: Determines whether the [ImportContent](ast_package_classes.md#class-importcontent) node imports multiple top-level definitions or declarations.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Indicates whether the [ImportContent](ast_package_classes.md#class-importcontent) node imports multiple top-level definitions or declarations.

### func isImportSingle()

```cangjie
public func isImportSingle(): Bool
```

Function: Determines whether the [ImportContent](ast_package_classes.md#class-importcontent) node is a single import.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Indicates whether the [ImportContent](ast_package_classes.md#class-importcontent) node is a single import.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class ImportList

```cangjie
public class ImportList <: Node {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a package import node.

An [ImportList](ast_package_classes.md#class-importlist) node: `import moduleName.packageName.foo as bar`.

> **Note:**
>
> An import node begins with an optional accessibility modifier (`public/protected/internal/private`) followed by the `import` keyword. Taking `import pkga.pkgb.item` as an example, `pkga.pkgb` is the package name containing the top-level definition or declaration being imported, and `item` is the top-level definition or declaration being imported.

Parent Type:

- [Node](#class-node)

### prop content

```cangjie
public mut prop content: ImportContent
```

Function: Gets or sets the specific item being imported in the [ImportList](ast_package_classes.md#class-importlist) node. For example, the `a.b.c` part in `import a.b.c`.

Type: [ImportContent](ast_package_classes.md#class-importcontent)

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

Function: Gets or sets the lexical unit of the `import` keyword in the [ImportList](ast_package_classes.md#class-importlist) node, where `I` is the first letter of the keyword.

Type: [Token](ast_package_structs.md#struct-token)

### prop modifier

```cangjie
public mut prop modifier: Token
```

Function: Gets or sets the modifier in the [ImportList](ast_package_classes.md#class-importlist) node, which may be a lexical unit of [ILLEGAL](ast_package_enums.md#illegal).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [ImportList](ast_package_classes.md#class-importlist) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [ImportList](ast_package_classes.md#class-importlist) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The sequence of lexical unit collections ([Tokens](ast_package_classes.md#class-tokens)) to be constructed into an [ImportList](ast_package_classes.md#class-importlist) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into an [ImportList](ast_package_classes.md#class-importlist) node.

### func isImportMulti()

```cangjie
public func isImportMulti(): Bool
```

Function: Determines whether the [ImportList](ast_package_classes.md#class-importlist) node imports multiple top-level definitions or declarations.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the [ImportList](ast_package_classes.md#class-importlist) node imports multiple top-level definitions or declarations; otherwise, returns false.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class IncOrDecExpr

```cangjie
public class IncOrDecExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an expression containing the increment operator (`++`) or decrement operator (`--`).

Parent Type:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression in the [IncOrDecExpr](ast_package_classes.md#class-incordecexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

Function: Gets or sets the operator in the [IncOrDecExpr](ast_package_classes.md#class-incordecexpr).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to be constructed into an [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into an [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class InterfaceDecl

```cangjie
public class InterfaceDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an interface definition node.

An interface definition uses the `interface` keyword. The interface definition consists of: an optional modifier, the `interface` keyword, the interface name, optional type parameters, optional parent interface specification, optional generic constraints, and the interface body definition.

Parent Type:

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

Function: Gets or sets the class body of the [InterfaceDecl](ast_package_classes.md#class-interfacedecl) node.

Type: [Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexical units in the parent interface declaration of the [InterfaceDecl](ast_package_classes.md#class-interfacedecl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `&` lexical units.

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

Function: Gets or sets the parent interfaces of the [InterfaceDecl](ast_package_classes.md#class-interfacedecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `<:` operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [InterfaceDecl](ast_package_classes.md#class-interfacedecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [InterfaceDecl](ast_package_classes.md#class-interfacedecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to be constructed into an [InterfaceDecl](ast_package_classes.md#class-interfacedecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into an [InterfaceDecl](ast_package_classes.md#class-interfacedecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class IsExpr

```cangjie
public class IsExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a type-checking expression.

An [IsExpr](ast_package_classes.md#class-isexpr) expression: `e is T`, with type [Bool](../../core/core_package_api/core_package_intrinsics.md#bool). Here, `e` can be any type of expression, and `T` can be any type.

Parent Type:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression node in the [IsExpr](ast_package_classes.md#class-isexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `is` operator in the [IsExpr](ast_package_classes.md#class-isexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `is` operator.

### prop shiftType

```cangjie
public mut prop shiftType: TypeNode
```

Function: Gets or sets the target type in the [IsExpr](ast_package_classes.md#class-isexpr) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

Function: Constructs a default [IsExpr](ast_package_classes.md#class-isexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [IsExpr](ast_package_classes.md#class-isexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to be constructed into an [IsExpr](ast_package_classes.md#class-isexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into an [IsExpr](ast_package_classes.md#class-isexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class JumpExpr

```cangjie
public class JumpExpr <: Expr {
    public init(kind: Tokens)
    public init()
}
```

Purpose: Represents `break` and `continue` statements within loop expression bodies.

Parent Types:

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Purpose: Gets or sets the keyword.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [JumpExpr](ast_package_classes.md#class-jumpexpr) object.

### init(Tokens)

```cangjie
public init(kind: Tokens)
```

Purpose: Constructs a [JumpExpr](ast_package_classes.md#class-jumpexpr) object.

Parameters:

- kind: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [JumpExpr](ast_package_classes.md#class-jumpexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [JumpExpr](ast_package_classes.md#class-jumpexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class LambdaExpr

```cangjie
public class LambdaExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a `Lambda` expression, which is an anonymous function.

A [LambdaExpr](ast_package_classes.md#class-lambdaexpr) node has two forms: one with parameters (e.g., `{a: Int64 => e1; e2 }`) and one without (e.g., `{ => e1; e2 }`).

Parent Types:

- [Expr](#class-expr)

### prop doubleArrow

```cangjie
public mut prop doubleArrow: Token
```

Purpose: Gets or sets the `=>` in [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `=>` operator.

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

Purpose: Gets or sets the parameter list in [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Purpose: Gets or sets the "{" in [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "{".

### prop nodes

```cangjie
public mut prop nodes: ArrayList<Node>
```

Purpose: Gets or sets the expression or declaration nodes in [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Node](ast_package_classes.md#class-node)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Purpose: Gets or sets the "}" in [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "}".

### init()

```cangjie
public init()
```

Purpose: Constructs a default [LambdaExpr](ast_package_classes.md#class-lambdaexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [LambdaExpr](ast_package_classes.md#class-lambdaexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [LambdaExpr](ast_package_classes.md#class-lambdaexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [LambdaExpr](ast_package_classes.md#class-lambdaexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class LetPatternExpr

```cangjie
public class LetPatternExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a destructuring pattern matching node in a `let` declaration.

A [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) node: `let Some(v) <- x` in `if (let Some(v) <- x)`.

Parent Types:

- [Expr](#class-expr)

### prop backArrow

```cangjie
public mut prop backArrow: Token
```

Purpose: Gets or sets the `<-` operator in [LetPatternExpr](ast_package_classes.md#class-letpatternexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `<-` operator.

### prop expr

```cangjie
public mut prop expr: Expr
```

Purpose: Gets or sets the expression following the `<-` operator in [LetPatternExpr](ast_package_classes.md#class-letpatternexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Purpose: Gets or sets the `let` keyword in [LetPatternExpr](ast_package_classes.md#class-letpatternexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `let` keyword.

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Purpose: Gets or sets the pattern following `let` in [LetPatternExpr](ast_package_classes.md#class-letpatternexpr).

Type: [Pattern](ast_package_classes.md#class-pattern)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor).

## class LitConstExpr

```cangjie
public class LitConstExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a constant expression node.

A [LitConstExpr](ast_package_classes.md#class-litconstexpr) expression: `"abc"`, `123`, etc.

Parent Types:

- [Expr](#class-expr)

### prop literal

```cangjie
public mut prop literal: Token
```

Purpose: Gets or sets the literal in [LitConstExpr](ast_package_classes.md#class-litconstexpr).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [LitConstExpr](ast_package_classes.md#class-litconstexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [LitConstExpr](ast_package_classes.md#class-litconstexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [LitConstExpr](ast_package_classes.md#class-litconstexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ParenExpr](ast_package_classes.md#class-parenexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) Instance of a type.

## class MacroDecl

```cangjie
public class MacroDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a macro definition node.

A [MacroDecl](ast_package_classes.md#class-macrodecl) node: `public macro M(input: Tokens): Tokens {...}`.

Parent Type:

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the function body of the [MacroDecl](ast_package_classes.md#class-macrodecl) node.

Type: [Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the colon of the [MacroDecl](ast_package_classes.md#class-macrodecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not a colon.

### prop declType

```cangjie
public mut prop declType: TypeNode
```

Function: Gets or sets the return type of the [MacroDecl](ast_package_classes.md#class-macrodecl) node's function.

Type: [TypeNode](ast_package_classes.md#class-typenode)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the return type of the [MacroDecl](ast_package_classes.md#class-macrodecl) node's function is a default value.

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

Function: Gets or sets the parameters of the [MacroDecl](ast_package_classes.md#class-macrodecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" of the [MacroDecl](ast_package_classes.md#class-macrodecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" of the [MacroDecl](ast_package_classes.md#class-macrodecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [MacroDecl](ast_package_classes.md#class-macrodecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MacroDecl](ast_package_classes.md#class-macrodecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [MacroDecl](ast_package_classes.md#class-macrodecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [MacroDecl](ast_package_classes.md#class-macrodecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class MacroExpandDecl

```cangjie
public class MacroExpandDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a macro expansion node.

A [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) node: `@M class A {}`.

Parent Type:

- [Decl](#class-decl)

### prop fullIdentifier

```cangjie
public mut prop fullIdentifier: Token
```

Function: Gets or sets the complete identifier of the macro invocation node, such as `pkg.m` in `@pkg.m class a{}`.

Type: [Token](ast_package_structs.md#struct-token)

### prop identifier

```cangjie
public override mut prop identifier: Token 
```

Function: This property is inherited from the [Decl](ast_package_classes.md#class-decl) node and represents the identifier of the macro invocation node, such as `m` in `@pkg.m class a{}`.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

Function: Gets or sets the "[" token for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "[".

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

Function: Gets or sets the input for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) attribute macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop macroInputDecl

```cangjie
public mut prop macroInputDecl: Decl
```

Function: Gets or sets the declaration node within [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl).

Type: [Decl](ast_package_classes.md#class-decl)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when no declaration node exists in the [MacroExpandDecl](ast_package_classes.md#class-macrodecl) node.

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

Function: Gets or sets the input for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

Function: Gets or sets the "]" token for [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "]".

### init()

```cangjie
public init()
```

Function: Constructs a default [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class MacroExpandExpr

```cangjie
public class MacroExpandExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a macro expansion node.

A [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) node: `@M (a is Int64)`.

Parent Type:

- [Expr](#class-expr)

### prop at

```cangjie
public mut prop at: Token
```

Function: Gets or sets the `@` operator in the [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not the `@` operator.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the identifier of the macro expansion node.

Type: [Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

Function: Gets or sets the "[" token for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "[".

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

Function: Gets or sets the input for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) attribute macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

Function: Gets or sets the input for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

Function: Gets or sets the "]" token for [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "]".

### init()

```cangjie
public init()
```

Function: Constructs a default [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class MacroExpandParam

```cangjie
public class MacroExpandParam <: FuncParam {
    public init()
}
```

Function: Represents a macro expansion node.

A [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) node: `@M a: Int64` within `func foo (@M a: Int64)`.

Parent Type:

- [FuncParam](#class-funcparam)

### prop fullIdentifier

```cangjie
public mut prop fullIdentifier: Token
```

Function: Gets or sets the complete identifier of the macro invocation node, such as `pkg.m` in `func bar (@pkg.m a: Int64)`.	 

Type: [Token](ast_package_structs.md#struct-token) 

### prop identifier 

```cangjie 
public override mut prop identifier: Token 
``` 

Function: This property is inherited from the [Decl](ast_package_classes.md#class-decl) node, representing the identifier of the macro invocation node, such as `m` in `func bar (@pkg.m a: Int64)`.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

Function: Gets or sets the "[" token for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "[".

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

Function: Gets or sets the input for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) attribute macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop macroInputDecl

```cangjie
public mut prop macroInputDecl: Decl
```

Function: Gets or sets the declaration node within [MacroExpandParam](ast_package_classes.md#class-macroexpandparam).

Type: [Decl](ast_package_classes.md#class-decl)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when no declaration node exists in the [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) node.

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

Function: Gets or sets the input for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) macro invocation.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

Function: Gets or sets the "]" token for [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) attribute macro invocation.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "]".

### init()

```cangjie
public init()
```

Function: Constructs a default [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class MacroMessage

```cangjie
public class MacroMessage {}
```

Function: Records messages sent by inner macros.

### func getBool(String)

```cangjie
public func getBool(key: String): Bool
```

Function: Retrieves the [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type information corresponding to the given key.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the keyword used for retrieval.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns the [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type information corresponding to the given key.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Throws an exception when no [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) type information corresponds to the given key.

### func getInt64(String)

```cangjie
public func getInt64(key: String): Int64
```

Function: Retrieves the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type information corresponding to the given key.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the keyword used for retrieval.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Returns the [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type information corresponding to the given key.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Throws an exception when no [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) type information corresponds to the given key.

### func getString(String)

```cangjie
public func getString(key: String): String
```

Function: Retrieves the [String](../../core/core_package_api/core_package_structs.md#struct-string) type information corresponding to the given key.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the keyword used for retrieval.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - Returns the [String](../../core/core_package_api/core_package_structs.md#struct-string) type information corresponding to the given key.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Throws an exception when no [String](../../core/core_package_api/core_package_structs.md#struct-string) type information corresponds to the given key.

### func getTokens(String)

```cangjie
public func getTokens(key: String): Tokens
```

Function: Retrieves the [Tokens](ast_package_classes.md#class-tokens) type information corresponding to the given key.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the keyword used for retrieval.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - Returns the [Tokens](ast_package_classes.md#class-tokens) type information corresponding to the given key.

Exceptions:

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - Throws an exception when no [Tokens](ast_package_classes.md#class-tokens) type information corresponds to the given key.

### func hasItem(String)

```cangjie
public func hasItem(key: String): Bool
```

Function: Checks whether there is information corresponding to the given key.

Parameters:

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The name of the keyword used for retrieval.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if information corresponding to the key exists; otherwise, returns false.

## class MainDecl

```cangjie
public class MainDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `main` function definition node.

A [MainDecl](ast_package_classes.md#class-maindecl) node: `main() {}`.

Parent Type:

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the function body of the [MainDecl](ast_package_classes.md#class-maindecl) node.

Type: [Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the colon of the [MainDecl](ast_package_classes.md#class-maindecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not a colon.

### prop declType

```cangjie
public mut prop declType: TypeNode
```

Function: Gets or sets the return type of the [MainDecl](ast_package_classes.md#class-maindecl) node's function.

Type: [TypeNode](ast_package_classes.md#class-typenode)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the return type of the [MainDecl](ast_package_classes.md#class-maindecl) node's function is a default value.

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

Function: Gets or sets the function parameters of the [MainDecl](ast_package_classes.md#class-maindecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" of the [MainDecl](ast_package_classes.md#class-maindecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" of the [MainDecl](ast_package_classes.md#class-maindecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [MainDecl](ast_package_classes.md#class-maindecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MainDecl](ast_package_classes.md#class-maindecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [MainDecl](ast_package_classes.md#class-maindecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed into a [MainDecl](ast_package_classes.md#class-maindecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

<!--Del_sink-->
## class ModalInfo

```cangjie
public class ModalInfo {}
```

Function: Represents a modal type node, that is, the `@ ~local`, `@ local?`, or `@ local!` annotation in source code.

A [ModalInfo](ast_package_classes.md#class-modalinfo) node stores the tokens contained in the annotation (the `@` operator, the `local` identifier, and the mode marker `~`/`!`/`?`) and the corresponding mode value of [ASTMode](ast_package_enums.md#enum-astmode). A modal type can be attached to nodes such as type nodes ([TypeNode](ast_package_classes.md#class-typenode)), [CallExpr](ast_package_classes.md#class-callexpr), [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr), [FuncDecl](ast_package_classes.md#class-funcdecl), and [ThisParam](ast_package_classes.md#class-thisparam).

> **Note:**
>
> The local mode is an experimental feature and requires both the `--experimental` and `--enable-local-mode` compiler options.

### prop at

```cangjie
public mut prop at: Token
```

Function: Gets or sets the `@` operator in the [ModalInfo](ast_package_classes.md#class-modalinfo) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "@" operator.

### prop local

```cangjie
public mut prop local: Token
```

Function: Gets or sets the `local` identifier in the [ModalInfo](ast_package_classes.md#class-modalinfo) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not an identifier, or its value is not "local".

### prop marker

```cangjie
public mut prop marker: Token
```

Function: Gets or sets the mode marker in the [ModalInfo](ast_package_classes.md#class-modalinfo) node, that is, `~` in `@ ~local`, `!` in `@ local!`, or `?` in `@ local?`.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "~", "!", or "?" operator.

### prop mode

```cangjie
public mut prop mode: ASTMode
```

Function: Gets or sets the mode of the [ModalInfo](ast_package_classes.md#class-modalinfo) node.

Type: [ASTMode](ast_package_enums.md#enum-astmode)

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether the current [ModalInfo](ast_package_classes.md#class-modalinfo) node has no mode annotated.

Return Value:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - `true` if no mode is annotated (the mode is `MODAL_NONE`), otherwise `false`.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type. Returns empty [Tokens](ast_package_classes.md#class-tokens) when no mode is annotated.

Return Value:

- [Tokens](ast_package_classes.md#class-tokens) - the converted [Tokens](ast_package_classes.md#class-tokens) node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. This node has no child nodes. It is not visited when no mode is annotated (that is, [isEmpty](#func-isempty) returns `true`). If `breakTraverse` is called during the visit, the stop request does not affect the traversal of the owner's other child nodes.

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.
<!--DelEnd_sink-->
## class MatchCase

```cangjie
public class MatchCase <: Node {
    public init()
}
```

Function: Represents a `case` node within a `match` expression.

A [MatchCase](ast_package_classes.md#class-matchcase) node: `case failScore where score > 0 => 0`.

> **Note:**
>
> - [MatchCase](ast_package_classes.md#class-matchcase) starts with the keyword `case`, followed by an [Expr](ast_package_classes.md#class-expr) or one or more `patterns` of the same kind separated by `|`, an optional `patternguard`, a `=>`, and a series of declarations or expressions.
> - This node has a strong binding relationship with [MatchExpr](ast_package_classes.md#class-matchexpr).

Parent Type:

- [Node](#class-node)

### prop arrow

```cangjie
public mut prop arrow: Token
```

Function: Gets or sets the `=>` operator lexical unit in [MatchCase](ast_package_classes.md#class-matchcase).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `=>` operator.

### prop bitOrs

```cangjie
public mut prop bitOrs: Tokens
```

Function: Gets or sets the sequence of `|` operator lexical units in [MatchCase](ast_package_classes.md#class-matchcase), which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `|` lexical units.

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the series of declaration or expression nodes in [MatchCase](ast_package_classes.md#class-matchcase).

Type: [Block](ast_package_classes.md#class-block)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression node following `case` in [MatchCase](ast_package_classes.md#class-matchcase).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when no expression node exists in the [MatchCase](ast_package_classes.md#class-matchcase) node.

### prop keywordC

```cangjie
public mut prop keywordC: Token
```

Function: Gets or sets the `case` keyword lexical unit within [MatchCase](ast_package_classes.md#class-matchcase).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `case` keyword.

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

Function: Gets or sets the optional `where` keyword lexical unit in [MatchCase](ast_package_classes.md#class-matchcase), which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not the `where` keyword.

### prop patternGuard

```cangjie
public mut prop patternGuard: Expr
```

Function: Gets or sets the optional pattern guard expression node in [MatchCase](ast_package_classes.md#class-matchcase).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when no pattern guard expression exists in the [MatchCase](ast_package_classes.md#class-matchcase) node.

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

Function: Gets or sets the list of `patterns` following `case` in [MatchCase](ast_package_classes.md#class-matchcase).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### init()

```cangjie
public init()
```

Function: Constructs a default [MatchCase](ast_package_classes.md#class-matchcase) object.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class MatchExpr

```cangjie
public class MatchExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a pattern matching expression that implements pattern matching.

Pattern matching expressions are divided into `match` expressions with a selector and those without a selector.

Parent Type:

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `match` keyword in the [MatchExpr](ast_package_classes.md#class-matchexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a `match` keyword.

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the "{" following the [MatchExpr](ast_package_classes.md#class-matchexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "{".

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" following the [MatchExpr](ast_package_classes.md#class-matchexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop matchCases

```cangjie
public mut prop matchCases: ArrayList<MatchCase>
```

Function: Gets or sets the `matchCase` within the [MatchExpr](ast_package_classes.md#class-matchexpr). A `matchCase` starts with the `case` keyword, followed by one or more [Pattern](ast_package_classes.md#class-pattern) or [Expr](ast_package_classes.md#class-expr) nodes. For details, see [MatchCase](ast_package_classes.md#class-matchcase).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[MatchCase](ast_package_classes.md#class-matchcase)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the "}" following the [MatchExpr](ast_package_classes.md#class-matchexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "}".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" following the [MatchExpr](ast_package_classes.md#class-matchexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop selector

```cangjie
public mut prop selector: Expr
```

Function: Gets or sets the [Expr](ast_package_classes.md#class-expr) following the `match` keyword.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the expression is a `match` expression without a selector.

### init()

```cangjie
public init()
```

Function: Constructs a default [MatchExpr](ast_package_classes.md#class-matchexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MatchExpr](ast_package_classes.md#class-matchexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [MatchExpr](ast_package_classes.md#class-matchexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [MatchExpr](ast_package_classes.md#class-matchexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class MemberAccess

```cangjie
public class MemberAccess <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a member access expression.

Can be used to access members of types such as class, interface, and struct. A [MemberAccess](ast_package_classes.md#class-memberaccess) node takes the form `T.a`, where `T` is the subject of the member access expression, and `a` represents the name of the member.

Parent Type:

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

Function: Gets or sets the subject of the member access expression in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Function: Gets or sets the sequence of "," lexical units in the [MemberAccess](ast_package_classes.md#class-memberaccess) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop dot

```cangjie
public mut prop dot: Token
```

Function: Gets or sets the "." in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a "." lexical unit type.

### prop field

```cangjie
public mut prop field: Token
```

Function: Gets or sets the name of the member in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Function: Gets or sets the left angle bracket in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Function: Gets or sets the right angle bracket in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

Function: Gets or sets the instantiation type in the [MemberAccess](ast_package_classes.md#class-memberaccess) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [MemberAccess](ast_package_classes.md#class-memberaccess) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [MemberAccess](ast_package_classes.md#class-memberaccess) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [MemberAccess](ast_package_classes.md#class-memberaccess) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [MemberAccess](ast_package_classes.md#class-memberaccess) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Modifier

```cangjie
public class Modifier <: Node {
    public init(keyword: Token)
    public init()
}
```

Function: Indicates that a definition possesses certain characteristics, typically placed at the forefront of the definition.

A [Modifier](ast_package_classes.md#class-modifier) node: `public func foo()` where `public` is the modifier.

Parent Type:

- [Node](#class-node)

### prop keyword(Token)

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the modifier lexical unit in the [Modifier](ast_package_classes.md#class-modifier) node.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [Modifier](ast_package_classes.md#class-modifier) object.

### init(Token)

```cangjie
public init(keyword: Token)
```

Function: Constructs a [Modifier](ast_package_classes.md#class-modifier) object.

Parameters:

- keyword: [Token](ast_package_structs.md#struct-token) - The lexical unit used to construct the [Modifier](ast_package_classes.md#class-modifier) type.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Node

```cangjie
abstract sealed class Node <: ToTokens {}
```

Function: The parent class of all Cangjie syntax tree nodes.

This class provides common operation interfaces for all data types.

Parent Type:

- [ToTokens](ast_package_interfaces.md#interface-totokens)

### prop beginPos

```cangjie
public mut prop beginPos: Position
```

Function: Gets or sets the starting position information of the current node.

Type: [Position](ast_package_structs.md#struct-position)

### prop endPos

```cangjie
public mut prop endPos: Position
```

Function: Gets or sets the ending position information of the current node.

Type: [Position](ast_package_structs.md#struct-position)

### func dump()

```cangjie
public func dump(): Unit
```

Function: Converts the current syntax tree node into a tree structure and prints it.

The tree structure of the syntax tree node will be output in the following format:

- `-` string: Represents the public attributes of the current node, such as `-keyword`, `-identifier`.
- The node attribute is immediately followed by the specific type of the node, such as `-declType: PrimitiveType`, indicating the node type is a [PrimitiveType](ast_package_classes.md#class-primitivetype) node.
- Each type uses braces to denote the scope of the type.

For detailed syntax tree output format, see [Syntax Tree Node Printing](../ast_samples/dump.md).

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class OptionalExpr

```cangjie
public class OptionalExpr <: Expr {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents an expression node with a question mark operator.

An [OptionalExpr](ast_package_classes.md#class-optionalexpr) node: The `a?` in expressions like `a?.b`, `a?(b)`, `a?[b]`.

Parent Type:

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

Function: Gets or sets the expression node of the [OptionalExpr](ast_package_classes.md#class-optionalexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop quest

```cangjie
public mut prop quest: Token
```

Function: Gets or sets the question mark operator in the [OptionalExpr](ast_package_classes.md#class-optionalexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a question mark operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [OptionalExpr](ast_package_classes.md#class-optionalexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs an [OptionalExpr](ast_package_classes.md#class-optionalexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [OptionalExpr](ast_package_classes.md#class-optionalexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as an [OptionalExpr](ast_package_classes.md#class-optionalexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class PackageHeader

```cangjie
public class PackageHeader <: Node {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a package declaration node.

A [PackageHeader](ast_package_classes.md#class-packageheader) node: `package define` or `macro package define`.

> **Note:**
>
> Package declarations must start with the keyword `package` or `macro package`, followed by the package name, and must appear on the first line of the source file.

Parent Type:

- [Node](#class-node)

### prop accessible

```cangjie
public mut prop accessible: Token
```

Function: Gets or sets the accessibility modifier lexical unit in the [PackageHeader](ast_package_classes.md#class-packageheader) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

### prop keywordM

```cangjie
public mut prop keywordM: Token
```

Function: Gets or sets the `macro` keyword lexical unit in the [PackageHeader](ast_package_classes.md#class-packageheader) node (`M` is the first letter of the keyword, same below), which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `macro` keyword.

### prop keywordP

```cangjie
public mut prop keywordP: Token
```

Function: Gets or sets the `package` keyword lexical unit in the [PackageHeader](ast_package_classes.md#class-packageheader) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `package` keyword.

### prop orgName

```cangjie
public mut prop orgName: Token
```

Function: Gets or sets the lexical unit representing organization name in the [PackageHeader](ast_package_classes.md#class-packageheader) node, setter would check if orgSeparator is "::" operator lexeme, set it to "::" if not.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) has a value of empty string.

### prop orgSeparator

```cangjie
public mut prop orgSeparator: Token
```

Function: Gets or sets the "::" operator lexeme in the [PackageHeader](ast_package_classes.md#class-packageheader) node, setter would check if orgName has a value of empty string, throw exception if it does.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "::" operator or orgName has a value of empty string.

### prop prefixPaths

```cangjie
public mut prop prefixPaths: Tokens
```

Function: Gets or sets the lexical unit sequence of the prefix part of the full package name in the [PackageHeader](ast_package_classes.md#class-packageheader) node, which may be empty. For example, `a` and `b` in `package a.b.c`.

Type: [Tokens](ast_package_classes.md#class-tokens)

### prop prefixDots

```cangjie
public mut prop prefixDots: Tokens
```

Function: Gets or sets the lexical unit sequence of the dots separating each subpackage in the full package name in the [PackageHeader](ast_package_classes.md#class-packageheader) node, which may be empty. For example, the two "." in `package a.b.c`.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "." lexical units.

### prop packageIdentifier

```cangjie
public mut prop packageIdentifier: Token
```

Function: Gets or sets the name of the current package in the [PackageHeader](ast_package_classes.md#class-packageheader) node. If the current package is the root package, this is the full package name; if it is a subpackage, it is the name after the last ".".

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [PackageHeader](ast_package_classes.md#class-packageheader) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PackageHeader](ast_package_classes.md#class-packageheader) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) sequence used to construct the [PackageHeader](ast_package_classes.md#class-packageheader) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PackageHeader](ast_package_classes.md#class-packageheader) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ParenExpr

```cangjie
public class ParenExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a parenthesized expression node, which is an expression enclosed in parentheses.

A [ParenExpr](ast_package_classes.md#class-parenexpr) node: `(1 + 2)`.

Parent Type:

- [Expr](#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in the [ParenExpr](ast_package_classes.md#class-parenexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop parenthesizedExpr

```cangjie
public mut prop parenthesizedExpr: Expr
```

Function: Gets or sets the subexpression enclosed in parentheses in the [ParenExpr](ast_package_classes.md#class-parenexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in the [ParenExpr](ast_package_classes.md#class-parenexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [ParenExpr](ast_package_classes.md#class-parenexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ParenExpr](ast_package_classes.md#class-parenexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ParenExpr](ast_package_classes.md#class-parenexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ParenExpr](ast_package_classes.md#class-parenexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ParenType

```cangjie
public class ParenType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a parenthesized type node.

For example, `(Int64)` in `var a: (Int64)`.

Parent Type:

- [TypeNode](#class-typenode)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" lexical unit in the [ParenType](ast_package_classes.md#class-parentype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop parenthesizedType

```cangjie
public mut prop parenthesizedType: TypeNode
```

Function: Gets or sets the enclosed type in the [ParenType](ast_package_classes.md#class-parentype) node, such as [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) in `(Int64)`.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" lexical unit in the [ParenType](ast_package_classes.md#class-parentype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [ParenType](ast_package_classes.md#class-parentype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ParenType](ast_package_classes.md#class-parentype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ParenType](ast_package_classes.md#class-parentype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ParenType](ast_package_classes.md#class-parentype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Pattern

```cangjie
public open class Pattern <: Node {}
```

Function: The parent class of all pattern matching nodes, inherits from the [Node](ast_package_classes.md#class-node) class.

Parent Type:

- [Node](#class-node)

### func dump(UInt16)

```cangjie
protected open func dump(_: UInt16): String
```

Function: Converts the current syntax tree node into a tree structure format and prints it. Needs to be overridden by subclasses.

Parameters:

- _: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number of indentation spaces for formatted output.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted output content.

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class PerformExpr

```cangjie
public class PerformExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `perform` expression node.

An example of a [PerformExpr](ast_package_classes.md#class-performexpr) node: `perform Eff()`.

Parent Types:

- [Expr](ast_package_classes.md#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression part within the [PerformExpr](ast_package_classes.md#class-performexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `perform` keyword within the [PerformExpr](ast_package_classes.md#class-performexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the given [Token](ast_package_structs.md#struct-token) is not a `perform` keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [PerformExpr](ast_package_classes.md#class-performexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PerformExpr](ast_package_classes.md#class-performexpr) object from provided lexical tokens.

Parameters:

* `inputs`: [Tokens](ast_package_classes.md#class-tokens) — The collection of lexical tokens to be parsed into a [PerformExpr](ast_package_classes.md#class-performexpr) node.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be parsed into a [PerformExpr](ast_package_classes.md#class-performexpr) node, or compile options for `Effect Handlers` experimental features not given.

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class PrefixType

```cangjie
public class PrefixType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a prefix type node with a question mark.

For example, `?A` in `var a : ?A`.

Parent Type:

- [TypeNode](#class-typenode)

### prop baseType

```cangjie
public mut prop baseType: TypeNode
```

Function: Gets or sets the type node within the [PrefixType](ast_package_classes.md#class-prefixtype) node, such as `A` in `var a: ?A`.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop prefixOps

```cangjie
public mut prop prefixOps: Tokens
```

Function: Gets or sets the collection of prefix operators in the [PrefixType](ast_package_classes.md#class-prefixtype) node.

Type: [Tokens](ast_package_classes.md#class-tokens)

### init()

```cangjie
public init()
```

Function: Constructs a default [PrefixType](ast_package_classes.md#class-prefixtype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PrefixType](ast_package_classes.md#class-prefixtype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [PrefixType](ast_package_classes.md#class-prefixtype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PrefixType](ast_package_classes.md#class-prefixtype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class PrimaryCtorDecl

```cangjie
public class PrimaryCtorDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a primary constructor node.

A primary constructor node consists of modifiers, the primary constructor name, parameter list, and constructor body.

Parent Type:

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the constructor body of the [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) node.

Type: [Block](ast_package_classes.md#class-block)

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

Function: Gets or sets the parameters of the [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token of the [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token of the [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) node.

### func isConst()

```cangjie
public func isConst(): Bool
```

Function: Determines whether the node is of `Const` type.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the current node is of `Const` type; otherwise, returns false.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class PrimitiveType

```cangjie
public class PrimitiveType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a primitive type node.

For example, numeric types, [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) type, boolean type, etc.

Parent Type:

- [TypeNode](#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the keyword used to construct the [PrimitiveType](ast_package_classes.md#class-primitivetype) type, such as [Int8](../../core/core_package_api/core_package_intrinsics.md#int8).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [PrimitiveType](ast_package_classes.md#class-primitivetype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PrimitiveType](ast_package_classes.md#class-primitivetype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [PrimitiveType](ast_package_classes.md#class-primitivetype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PrimitiveType](ast_package_classes.md#class-primitivetype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class PrimitiveTypeExpr

```cangjie
public class PrimitiveTypeExpr <: Expr {
    public init(kind: Tokens)
    public init()
}
```

Function: Represents a primitive type expression node.

[PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) node: Compiler-built primitive types appear as expressions in the node. For example, [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) in [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).toSting().

Parent Type:

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the primitive type keyword in the [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

<!--Del_sink-->
### prop modal

```cangjie
public mut prop modal: ModalInfo
```

Function: Gets or sets the modal type in the [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) node, that is, the local modal type, such as `@ local!` in `Int64 @ local!`. When no mode is annotated, it is an empty [ModalInfo](ast_package_classes.md#class-modalinfo) object.

Type: [ModalInfo](ast_package_classes.md#class-modalinfo)
<!--DelEnd_sink-->
### init()

```cangjie
public init()
```

Function: Constructs a default [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) object.

### init(Tokens)

```cangjie
public init(kind: Tokens)
```

Function: Constructs a [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) object.

Parameters:

- kind: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Throws an exception when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class Program

```cangjie
public class Program <: Node {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a Cangjie source code file node.

A Cangjie source code file node primarily includes package definition nodes, package import nodes, and all declaration nodes within the TopLevel scope.

> **Note:**
>
> Any Cangjie source code file can be parsed into a [Program](ast_package_classes.md#class-program) type.

Parent Type:

- [Node](#class-node)

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

Function: Gets or sets the list of declaration nodes defined within the TopLevel scope of the Cangjie source code file.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop featuresDirective

```cangjie
public mut prop featuresDirective: Option<FeaturesDirective>
```

Function: Gets or sets the features directive node defined within the TopLevel scope of the Cangjie source code file.

Type: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FeaturesDirective](ast_package_classes.md#class-featuresdirective)>

### prop importLists

```cangjie
public mut prop importLists: ArrayList<ImportList>
```

Function: Gets or sets the list of package import nodes [ImportList](ast_package_classes.md#class-importlist) in the Cangjie source code file.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[ImportList](ast_package_classes.md#class-importlist)>

### prop packageHeader

```cangjie
public mut prop packageHeader: PackageHeader
```

Function: Gets or sets the package declaration node [PackageHeader](ast_package_classes.md#class-packageheader) in the Cangjie source code file.

Type: [PackageHeader](ast_package_classes.md#class-packageheader)

### init()

```cangjie
public init()
```

Function: Constructs a default [Program](ast_package_classes.md#class-program) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [Program](ast_package_classes.md#class-program) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The sequence of lexical unit collections ([Tokens](ast_package_classes.md#class-tokens)) to construct the [Program](ast_package_classes.md#class-program) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a file node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class PropDecl

```cangjie
public class PropDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a property declaration node.

A [PropDecl](ast_package_classes.md#class-propdecl) node: `prop X: Int64 { get() { 0 } }`.

Parent Type:

- [Decl](#class-decl)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the colon in the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a colon.

### prop declType

```cangjie
public mut prop declType : TypeNode
```

Function: Gets or sets the return type of the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop getter

```cangjie
public mut prop getter: FuncDecl
```

Function: Gets or sets the getter function of the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [FuncDecl](ast_package_classes.md#class-funcdecl)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [PropDecl](ast_package_classes.md#class-propdecl) node does not have a getter function.

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

Function: Gets or sets the "{" in the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "{".

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

Function: Gets or sets the "}" in the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "}".

### prop setter

```cangjie
public mut prop setter: FuncDecl
```

Function: Gets or sets the setter function of the [PropDecl](ast_package_classes.md#class-propdecl) node.

Type: [FuncDecl](ast_package_classes.md#class-funcdecl)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [PropDecl](ast_package_classes.md#class-propdecl) node does not have a setter function.

### init()

```cangjie
public init()
```

Function: Constructs a default [PropDecl](ast_package_classes.md#class-propdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [PropDecl](ast_package_classes.md#class-propdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [PropDecl](ast_package_classes.md#class-propdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [PropDecl](ast_package_classes.md#class-propdecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class QualifiedType

```cangjie
public class QualifiedType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a user-defined member type.

For example, `T.a` in `var a : T.a`, where T is the package name and a is the type imported from package T.

Parent Type:

- [TypeNode](#class-typenode)

### prop baseType

```cangjie
public mut prop baseType: TypeNode
```

Function: Gets or sets the member access type subject in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, such as `T` in `var a : T.a`.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Function: Gets or sets the sequence of "," lexical units in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop dot

```cangjie
public mut prop dot: Token
```

Function: Gets or sets the "." in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a "." lexical unit.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the identifier of the member in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, such as `a` in `var a : T.a`.

Type: [Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Function: Gets or sets the left angle bracket lexical unit in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Function: Gets or sets the right angle bracket lexical unit in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

Function: Gets or sets the list of instantiated types in the [QualifiedType](ast_package_classes.md#class-qualifiedtype) node, such as [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) in `T.a<Int32>`. The list may be empty.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [QualifiedType](ast_package_classes.md#class-qualifiedtype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [QualifiedType](ast_package_classes.md#class-qualifiedtype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [QualifiedType](ast_package_classes.md#class-qualifiedtype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [QualifiedType](ast_package_classes.md#class-qualifiedtype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of type [Tokens](ast_package_classes.md#class-tokens).

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of type [Visitor](ast_package_classes.md#class-visitor).

## class QuoteExpr

```cangjie
public class QuoteExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `quote` expression node.

A [QuoteExpr](ast_package_classes.md#class-quoteexpr) node example: `quote(var ident = 0)`.

Parent Type:

- [Expr](#class-expr)

### prop exprs

```cangjie
public mut prop exprs: ArrayList<Expr>
```

Function: Gets or sets the internally quoted expression nodes enclosed by `()` within the [QuoteExpr](ast_package_classes.md#class-quoteexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `quote` keyword of the [QuoteExpr](ast_package_classes.md#class-quoteexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `quote` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token in the [QuoteExpr](ast_package_classes.md#class-quoteexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token in the [QuoteExpr](ast_package_classes.md#class-quoteexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [QuoteExpr](ast_package_classes.md#class-quoteexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [QuoteExpr](ast_package_classes.md#class-quoteexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [QuoteExpr](ast_package_classes.md#class-quoteexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be converted into a [QuoteExpr](ast_package_classes.md#class-quoteexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of type [Tokens](ast_package_classes.md#class-tokens).

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of type [Visitor](ast_package_classes.md#class-visitor).

## class QuoteToken

```cangjie
public class QuoteToken <: Expr {}
```

Purpose: Represents any valid `token` within a `quote` expression node.

Parent Type:

- [Expr](#class-expr)

### prop tokens

```cangjie
public mut prop tokens: Tokens
```

Purpose: Retrieves the [Tokens](ast_package_classes.md#class-tokens) contained within a [QuoteToken](ast_package_classes.md#class-quotetoken).

Type: [Tokens](ast_package_classes.md#class-tokens)

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of [Tokens](ast_package_classes.md#class-tokens) type.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class RangeExpr

```cangjie
public class RangeExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents an expression containing range operators.

[RangeExpr](ast_package_classes.md#class-rangeexpr) Node: There are two [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) operators: `..` and `..=`, used to create left-closed-right-open and left-closed-right-closed [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) instances, respectively. Their usage formats are `start..end:step` and `start..=end:step`.

Parent Type:

- [Expr](#class-expr)

### prop colon

```cangjie
public mut prop colon: Token
```

Purpose: Gets or sets the ":" operator in [RangeExpr](ast_package_classes.md#class-rangeexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a ":" operator.

### prop end

```cangjie
public mut prop end: Expr
```

Purpose: Gets or sets the end value in [RangeExpr](ast_package_classes.md#class-rangeexpr).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - End expression omitted. Only occurs when [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> type instances are used in empty subscript operator `[]` scenarios.

### prop op

```cangjie
public mut prop op: Token
```

Purpose: Gets or sets the [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) operator in [RangeExpr](ast_package_classes.md#class-rangeexpr).

Type: [Token](ast_package_structs.md#struct-token)

### prop start

```cangjie
public mut prop start: Expr
```

Purpose: Gets or sets the start value in [RangeExpr](ast_package_classes.md#class-rangeexpr).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Start expression omitted. Only occurs when [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> type instances are used in empty subscript operator `[]` scenarios.

### prop step

```cangjie
public mut prop step: Expr
```

Purpose: Gets or sets the difference between consecutive elements in the sequence within [RangeExpr](ast_package_classes.md#class-rangeexpr).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the step value between sequence elements is not set in [RangeExpr](ast_package_classes.md#class-rangeexpr).

### init()

```cangjie
public init()
```

Purpose: Constructs a default [RangeExpr](ast_package_classes.md#class-rangeexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [RangeExpr](ast_package_classes.md#class-rangeexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [RangeExpr](ast_package_classes.md#class-rangeexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [RangeExpr](ast_package_classes.md#class-rangeexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of [Tokens](ast_package_classes.md#class-tokens) type.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class RefExpr

```cangjie
public class RefExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents an expression node that references a declaration.

A [RefExpr](ast_package_classes.md#class-refexpr) node: In `var b = a + 1`, `a` is a [RefExpr](ast_package_classes.md#class-refexpr).

Parent Type:

- [Expr](#class-expr)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Purpose: Gets or sets the sequence of "," lexical units in [RefExpr](ast_package_classes.md#class-refexpr) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Purpose: Gets or sets the identifier of a custom type in [RefExpr](ast_package_classes.md#class-refexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Purpose: Gets or sets the left angle bracket in [RefExpr](ast_package_classes.md#class-refexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Purpose: Gets or sets the right angle bracket in [RefExpr](ast_package_classes.md#class-refexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

Purpose: Gets or sets the instantiation types in [RefExpr](ast_package_classes.md#class-refexpr) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Purpose: Constructs a default [RefExpr](ast_package_classes.md#class-refexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [RefExpr](ast_package_classes.md#class-refexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [RefExpr](ast_package_classes.md#class-refexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [RefExpr](ast_package_classes.md#class-refexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of [Tokens](ast_package_classes.md#class-tokens) type.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class RefType

```cangjie
public class RefType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Purpose: Represents a non-primitive type node.

For example, user-defined types via `class`, `struct`, `enum`, etc., as well as built-in types like [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) and [String](../../core/core_package_api/core_package_structs.md#struct-string) can be represented using [RefType](ast_package_classes.md#class-reftype). Example: `A` in `var a : A`.

Parent Type:

- [TypeNode](#class-typenode)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Purpose: Gets or sets the sequence of "," lexical units in [RefType](ast_package_classes.md#class-reftype) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop identifier

```cangjie
public mut prop identifier: Token
```

Purpose: Gets or sets the keyword used to construct [RefType](ast_package_classes.md#class-reftype), such as `A` in `var a : A = A()`.

Type: [Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Purpose: Gets or sets the left angle bracket lexical unit in [RefType](ast_package_classes.md#class-reftype) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Purpose: Gets or sets the right angle bracket lexical unit in [RefType](ast_package_classes.md#class-reftype) node, which may be an [ILLEGAL](ast_package_enums.md#illegal) lexical unit.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

Purpose: Gets or sets the list of instantiation types in [RefType](ast_package_classes.md#class-reftype) node, which may be empty. Example: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) in `var a : Array<Int32>`.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Purpose: Constructs a default [RefType](ast_package_classes.md#class-reftype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Purpose: Constructs a [RefType](ast_package_classes.md#class-reftype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [RefType](ast_package_classes.md#class-reftype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [RefType](ast_package_classes.md#class-reftype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of [Tokens](ast_package_classes.md#class-tokens) type.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class ResumeExpr

```cangjie
public class ResumeExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `resume` expression node, optionally containing `with` and `throwing` clauses.

A [ResumeExpr](ast_package_classes.md#class-resumeexpr) node example:
`resume r with 42`.

Parent Types:

- [Expr](ast_package_classes.md#class-expr)

### prop keywordR

```cangjie
public mut prop keywordR: Token
```

Function: Gets or sets the lexical token for the `resume` keyword.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `resume` keyword.

### prop keywordW

```cangjie
public mut prop keywordW: Option<Token>
```

Function: Gets or sets the lexical token for the `with` keyword (if present).

Type: [Option\<Token>](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `with` keyword.

### prop withExpr

```cangjie
public mut prop withExpr: Option<Expr>
```

Function: Gets or sets the expression following the `with` keyword.

Type: [Option\<Expr>](ast_package_classes.md#class-expr)

### prop keywordT

```cangjie
public mut prop keywordT: Option<Token>
```

Function: Gets or sets the lexical token for the `throwing` keyword (if present).

Type: [Option\<Token>](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `throwing` keyword.

### prop throwingExpr

```cangjie
public mut prop throwingExpr: Option<Expr>
```

Function: Gets or sets the expression following the `throwing` keyword.

Type: Option\<[Expr](ast_package_classes.md#class-expr)>

### init()

```cangjie
public init()
```

Function: Constructs a default [ResumeExpr](ast_package_classes.md#class-resumeexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ResumeExpr](ast_package_classes.md#class-resumeexpr) object from a token stream.

Parameters:

* `inputs`: [Tokens](ast_package_classes.md#class-tokens) — A collection of tokens to be parsed as a [ResumeExpr](ast_package_classes.md#class-resumeexpr) node.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) — Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be parsed as a valid [ResumeExpr](ast_package_classes.md#class-resumeexpr) node, or compile options for `Effect Handlers` experimental features not given.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Purpose: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted node of [Tokens](ast_package_classes.md#class-tokens) type.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class ReturnExpr

```cangjie
public class ReturnExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `return` expression node.

A [ReturnExpr](ast_package_classes.md#class-returnexpr) node: `return 1`.

Parent Type:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression node within the [ReturnExpr](ast_package_classes.md#class-returnexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [ReturnExpr](ast_package_classes.md#class-returnexpr) node lacks an expression.

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the keyword in the [ReturnExpr](ast_package_classes.md#class-returnexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `return` keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [ReturnExpr](ast_package_classes.md#class-returnexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ReturnExpr](ast_package_classes.md#class-returnexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ReturnExpr](ast_package_classes.md#class-returnexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [ReturnExpr](ast_package_classes.md#class-returnexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class SpawnExpr

```cangjie
public class SpawnExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `Spawn` expression.

A [SpawnExpr](ast_package_classes.md#class-spawnexpr) node consists of the `spawn` keyword and a parameterless closure, e.g., `spawn { add(1, 2) }`.

Parent Type:

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `spawn` keyword in the [SpawnExpr](ast_package_classes.md#class-spawnexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `spawn` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in the [SpawnExpr](ast_package_classes.md#class-spawnexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop lambdaExpr

```cangjie
public mut prop lambdaExpr: LambdaExpr
```

Function: Gets or sets the parameterless closure in the [SpawnExpr](ast_package_classes.md#class-spawnexpr).

Type: [LambdaExpr](ast_package_classes.md#class-lambdaexpr)

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in the [SpawnExpr](ast_package_classes.md#class-spawnexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### prop threadContext

```cangjie
public mut prop threadContext: Expr
```

Function: Gets or sets the thread context environment expression in the [SpawnExpr](ast_package_classes.md#class-spawnexpr).

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [SpawnExpr](ast_package_classes.md#class-spawnexpr) lacks a context expression.

### init()

```cangjie
public init()
```

Function: Constructs a default [SpawnExpr](ast_package_classes.md#class-spawnexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [SpawnExpr](ast_package_classes.md#class-spawnexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [SpawnExpr](ast_package_classes.md#class-spawnexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [SpawnExpr](ast_package_classes.md#class-spawnexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class StructDecl

```cangjie
public class StructDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `Struct` node.

Struct definitions use the `struct` keyword, followed by: optional modifiers, the `struct` keyword, the struct name, optional type parameters, optional parent interface specification, optional generic constraints, and the struct body definition.

Parent Type:

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

Function: Gets or sets the class body of the [StructDecl](ast_package_classes.md#class-structdecl) node.

Type: [Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

Function: Gets or sets the sequence of `&` operator lexical tokens in the parent interface declaration of the [StructDecl](ast_package_classes.md#class-structdecl) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Tokens](ast_package_classes.md#class-tokens) is not a sequence of `&` lexical tokens.

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

Function: Gets or sets the parent interfaces of the [StructDecl](ast_package_classes.md#class-structdecl) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

Function: Gets or sets the `<:` operator.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `<:` operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [StructDecl](ast_package_classes.md#class-structdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [StructDecl](ast_package_classes.md#class-structdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [StructDecl](ast_package_classes.md#class-structdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [StructDecl](ast_package_classes.md#class-structdecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class SubscriptExpr

```cangjie
public class SubscriptExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents an index access expression.

[SubscriptExpr](ast_package_classes.md#class-subscriptexpr) node: Used for types that support index access (including [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) types and `Tuple` types) to access elements at specific positions via subscripts, e.g., `arr[0]`.

Parent Type:

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

Function: Gets or sets the expression in the [SubscriptExpr](ast_package_classes.md#class-subscriptexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop indexList

```cangjie
public mut prop indexList: ArrayList<Expr
```

Function: Gets or sets the sequence of index expressions in the [SubscriptExpr](ast_package_classes.md#class-subscriptexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

Function: Gets or sets the "[" in the [SubscriptExpr](ast_package_classes.md#class-subscriptexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "[".

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

Function: Gets or sets the "]" in the [SubscriptExpr](ast_package_classes.md#class-subscriptexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "]".

### init()

```cangjie
public init()
```

Function: Constructs a default [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class SynchronizedExpr

```cangjie
public class SynchronizedExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `synchronized` expression.

A [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) node consists of the `synchronized` keyword, a `StructuredMutex` pair, and the following code block, e.g., `synchronized(m) { foo() }`.

Parent Types:

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the code block modified by [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

Type: [Block](ast_package_classes.md#class-block)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `synchronized` keyword in [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `synchronized` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop structuredMutex

```cangjie
public mut prop structuredMutex: Expr
```

Function: Gets or sets the `StructuredMutex` object in [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

Function: Constructs a default [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

<!--Del_sink-->
## class ThisParam

```cangjie
public class ThisParam <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents the explicit `this` parameter node of a function or constructor, that is, `this @ local!` in the parameter list of a member function or constructor.

> **Note:**
>
> The `this` parameter is related to the local mode. The local mode is an experimental feature and requires both the `--experimental` and `--enable-local-mode` compiler options.

Parent Type:

- [Decl](#class-decl)

### prop comma

```cangjie
public mut prop comma: Token
```

Function: Gets or sets the parameter separator "," in the [ThisParam](ast_package_classes.md#class-thisparam) node, which may be a lexical unit of [ILLEGAL](ast_package_enums.md#illegal).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ",".

### prop modal

```cangjie
public mut prop modal: ModalInfo
```

Function: Gets or sets the modal type on `this` in the [ThisParam](ast_package_classes.md#class-thisparam) node, that is, `@ local!` in `this @ local!`.

Type: [ModalInfo](ast_package_classes.md#class-modalinfo)

### prop this

```cangjie
public mut prop `this`: Token
```

Function: Gets or sets the `this` keyword in the [ThisParam](ast_package_classes.md#class-thisparam) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the "this" keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [ThisParam](ast_package_classes.md#class-thisparam) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ThisParam](ast_package_classes.md#class-thisparam) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - the lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [ThisParam](ast_package_classes.md#class-thisparam) object.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [ThisParam](ast_package_classes.md#class-thisparam) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Return Value:

- [Tokens](ast_package_classes.md#class-tokens) - the converted [Tokens](ast_package_classes.md#class-tokens) node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.
<!--DelEnd_sink-->
## class ThisType

```cangjie
public class ThisType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `This` type node.

Parent Types:

- [TypeNode](#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the lexical unit of the `This` keyword in the [ThisType](ast_package_classes.md#class-thistype) node.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [ThisType](ast_package_classes.md#class-thistype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ThisType](ast_package_classes.md#class-thistype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [ThisType](ast_package_classes.md#class-thistype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ThisType](ast_package_classes.md#class-thistype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class ThrowExpr

```cangjie
public class ThrowExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `throw` expression node.

A [ThrowExpr](ast_package_classes.md#class-throwexpr) node: `throw Exception()`.

Parent Types:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression node in the [ThrowExpr](ast_package_classes.md#class-throwexpr) node.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the keyword in the [ThrowExpr](ast_package_classes.md#class-throwexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `throw` keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [ThrowExpr](ast_package_classes.md#class-throwexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [ThrowExpr](ast_package_classes.md#class-throwexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [ThrowExpr](ast_package_classes.md#class-throwexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [ThrowExpr](ast_package_classes.md#class-throwexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Tokens

```cangjie
public open class Tokens <: ToString & Iterable<Token> & ToBytes {
    protected var tokens: ArrayList<Token> = ArrayList<Token>(0)
    public init()
    public init(tokArray: Array<Token>)
    public init(tokArrayList: ArrayList<Token>)
}
```

Function: A type that encapsulates a sequence of [Token](ast_package_structs.md#struct-token).

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Iterable](../../core/core_package_api/core_package_interfaces.md#interface-iterablee)\<[Token](ast_package_structs.md#struct-token)>
- [ToBytes](ast_package_interfaces.md#interface-tobytes)

### var tokens

```cangjie
protected var tokens: ArrayList<Token> = ArrayList<Token>(0)
```

Function: Gets or sets all [Token](ast_package_structs.md#struct-token) stored internally in [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)> format.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)>

### prop size

```cangjie
public open prop size: Int64
```

Function: Gets the number of [Token](ast_package_structs.md#struct-token) types in the [Tokens](ast_package_classes.md#class-tokens) object.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init()

```cangjie
public init()
```

Function: Constructs a default [Tokens](ast_package_classes.md#class-tokens) object.

### init(Array\<Token>)

```cangjie
public init(tokArray: Array<Token>)
```

Function: Constructs a [Tokens](ast_package_classes.md#class-tokens) object.

Parameters:

- tokArray: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Token](ast_package_structs.md#struct-token)> - An [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) containing a group of [Token](ast_package_structs.md#struct-token).

### init(ArrayList\<Token>)

```cangjie
public init(tokArrayList: ArrayList<Token>)
```

Function: Constructs a [Tokens](ast_package_classes.md#class-tokens) object.

Parameters:

- tokArrayList: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)> - An [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt) containing a group of [Token](ast_package_structs.md#struct-token).

### func append(Node)

```cangjie
public func append(node: Node): Tokens
```

Function: Concatenates the current [Tokens](ast_package_classes.md#class-tokens) with the [Tokens](ast_package_classes.md#class-tokens) converted from the input node.

Parameters:

- node: [Node](ast_package_classes.md#class-node) - The [Node](ast_package_classes.md#class-node) object to be concatenated.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The concatenated [Tokens](ast_package_classes.md#class-tokens) type.

### func append(Token)

```cangjie
public open func append(token: Token): Tokens
```

Function: Concatenates the current [Tokens](ast_package_classes.md#class-tokens) with the input [Token](ast_package_structs.md#struct-token).

Parameters:

- token: [Token](ast_package_structs.md#struct-token) - The [Token](ast_package_structs.md#struct-token) object to be concatenated.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The concatenated [Tokens](ast_package_classes.md#class-tokens) type.

### func append(Tokens)

```cangjie
public open func append(tokens: Tokens): Tokens
```

Function: Appends the input [Tokens](ast_package_classes.md#class-tokens) to the current [Tokens](ast_package_classes.md#class-tokens) (this interface performs better than other concatenation functions).

Parameters:

- tokens: [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) object to be concatenated.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The concatenated [Tokens](ast_package_classes.md#class-tokens) type.

### func concat(Tokens)

```cangjie
public func concat(tokens: Tokens): Tokens
```

Function: Concatenates the current [Tokens](ast_package_classes.md#class-tokens) with the input [Tokens](ast_package_classes.md#class-tokens).

Parameters:

- tokens: [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) object to be concatenated.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The concatenated [Tokens](ast_package_classes.md#class-tokens).

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints the information of all [Token](ast_package_structs.md#struct-token) in [Tokens](ast_package_classes.md#class-tokens).

### func get(Int64)

```cangjie
public open func get(index: Int64): Token
```

Function: Gets a [Token](ast_package_structs.md#struct-token) element by index.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index value.

Returns:

- [Token](ast_package_structs.md#struct-token) - The [Token](ast_package_structs.md#struct-token) at the specified index.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when `index` is invalid.

### func iterator()

```cangjie
public func iterator(): TokensIterator
```

Function: Gets an iterator object for the [Tokens](ast_package_classes.md#class-tokens) object.

Returns:

- [TokensIterator](ast_package_classes.md#class-tokensiterator) - The iterator object of the [Tokens](ast_package_classes.md#class-tokens) object.

### func remove(Int64)

```cangjie
public func remove(index: Int64): Tokens
```

Function: Removes the [Token](ast_package_structs.md#struct-token) object at the specified position.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The index of the [Token](ast_package_structs.md#struct-token) to be removed.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) object after removing the [Token](ast_package_structs.md#struct-token) at the specified position.

### func toBytes()

```cangjie
public func toBytes(): Array<UInt8>
```

Function: Serializes the Tokens type.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - The serialized byte sequence.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts [Tokens](ast_package_classes.md#class-tokens) to the [String](../../core/core_package_api/core_package_structs.md#struct-string) type.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string.

### operator func +(Token)

```cangjie
public operator func +(r: Token): Tokens
```

Function: Operator overload to obtain a new [Tokens](ast_package_classes.md#class-tokens) by adding the current [Tokens](ast_package_classes.md#class-tokens) with another [Token](ast_package_structs.md#struct-token).

Parameters:

- r: [Token](ast_package_structs.md#struct-token) - The other [Token](ast_package_structs.md#struct-token) object to be operated on.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The newly concatenated collection of lexical units after [Tokens](ast_package_classes.md#class-tokens).

### operator func +(Tokens)

```cangjie
public operator func +(r: Tokens): Tokens
```

Function: Uses the current [Tokens](ast_package_classes.md#class-tokens) to add with another [Tokens](ast_package_classes.md#class-tokens) and obtain a new [Tokens](ast_package_classes.md#class-tokens) type.

Parameters:

- r: [Tokens](ast_package_classes.md#class-tokens) - A set of [Tokens](ast_package_classes.md#class-tokens) objects to be operated on.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The newly concatenated collection of lexical units after [Tokens](ast_package_classes.md#class-tokens).

### operator func [](Int64)

```cangjie
public operator func [](index: Int64): Token
```

Function: Operator overload to retrieve the corresponding [Token](ast_package_structs.md#struct-token) via an index value.

Parameters:

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The numerical value to be indexed.

Returns:

- [Token](ast_package_structs.md#struct-token) - Returns the [Token](ast_package_structs.md#struct-token) corresponding to the index.

Exceptions:

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when `index` is invalid.

### operator func [](Range\<Int64>)

```cangjie
public open operator func [](range: Range<Int64>): Tokens
```

Function: Operator overload to retrieve the corresponding [Tokens](ast_package_classes.md#class-tokens) slice via a `range`.

Parameters:

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - The slice range to be indexed.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - Returns the [Tokens](ast_package_classes.md#class-tokens) corresponding to the slice index.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `range.step` is not equal to 1.
- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - Thrown when the range is invalid.

### class TokensIterator

```cangjie
public class TokensIterator <: Iterator<Token> {
    public init(tokens: Tokens)
}
```

Function: Implements iterator functionality for [Tokens](ast_package_classes.md#class-tokens).

Parent Types:

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<[Token](ast_package_structs.md#struct-token)>

### init(Tokens)

```cangjie
public init(tokens: Tokens)
```

Function: Constructs a [TokensIterator](ast_package_classes.md#class-tokensiterator) object.

Parameters:

- tokens: [Tokens](ast_package_classes.md#class-tokens) - Input [Tokens](ast_package_classes.md#class-tokens).

### func next()

```cangjie
public func next(): Option<Token>
```

Function: Gets the next value in the iterator.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> - Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> type. Returns None when iteration completes.

### func peek()

```cangjie
public func peek(): Option<Token>
```

Function: Gets the current value in the iterator.

Returns:

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> - Returns [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> type. Returns None when iteration completes.

### func seeing(TokenKind)

```cangjie
public func seeing(kind: TokenKind): Bool
```

Function: Determines whether the current node's [Token](ast_package_structs.md#struct-token) type matches the input type.

Parameters:

- kind: [TokenKind](ast_package_enums.md#enum-tokenkind) - The [TokenKind](ast_package_enums.md#enum-tokenkind) type to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the current node's [TokenKind](ast_package_enums.md#enum-tokenkind) matches the input type, otherwise returns false.

## class TrailingClosureExpr

```cangjie
public class TrailingClosureExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a trailing `Lambda` node.

A [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) node places the lambda expression at the end of a function call, outside parentheses, e.g., `f(a){ i => i * i }`.

Parent Types:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the expression within [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop lambdaExpr

```cangjie
public mut prop lambdaExpr: LambdaExpr
```

Function: Gets or sets the trailing lambda in [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr).

Type: [LambdaExpr](ast_package_classes.md#class-lambdaexpr)

### init()

```cangjie
public init()
```

Function: Constructs a default [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class TryExpr

```cangjie
public class TryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `try` expression node.

A `try` expression consists of three parts: `try` block, `catch` block, and `finally` block.

Parent Types:

- [Expr](#class-expr)

### prop catchBlocks

```cangjie
public mut prop catchBlocks: ArrayList<Block>
```

Function: Gets or sets the Catch blocks in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Block](ast_package_classes.md#class-block)>

### prop catchPatterns

```cangjie
public mut prop catchPatterns: ArrayList<Pattern>
```

Function: Gets or sets the sequence of patterns to match exceptions to be caught in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop finallyBlock

```cangjie
public mut prop finallyBlock: Block
```

Function: Gets or sets the `Finally` block in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [Block](ast_package_classes.md#class-block)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [TryExpr](ast_package_classes.md#class-tryexpr) node has no `Finally` block.

### prop handlers

```cangjie
public mut prop handlers: ArrayList<Handler>
```

Function: Gets or sets the list of `Handler` nodes.

Type: [ArrayList\<Handler>](ast_package_classes.md#class-handler)

### prop keywordF

```cangjie
public mut prop keywordF: Token
```

Function: Gets or sets the `finally` keyword in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `finally` keyword.

### prop keywordT

```cangjie
public mut prop keywordT: Token
```

Function: Gets or sets the `try` keyword in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `try` keyword.

### prop keywordsC

```cangjie
public mut prop keywordsC: Tokens
```

Function: Gets or sets the `catch` keywords in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `catch` keyword.

### prop resourceSpec

```cangjie
public mut prop resourceSpec: ArrayList<VarDecl>
```

Function: Gets or sets the sequence of instantiated objects in Try-with-resources expressions in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[VarDecl](ast_package_classes.md#class-vardecl)>

### prop tryBlock

```cangjie
public mut prop tryBlock: Block
```

Function: Gets or sets the block composed of expressions and declarations in [TryExpr](ast_package_classes.md#class-tryexpr).

Type: [Block](ast_package_classes.md#class-block)

### init()

```cangjie
public init()
```

Function: Constructs a default [TryExpr](ast_package_classes.md#class-tryexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TryExpr](ast_package_classes.md#class-tryexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [TryExpr](ast_package_classes.md#class-tryexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [TryExpr](ast_package_classes.md#class-tryexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class TupleLiteral

```cangjie
public class TupleLiteral <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a tuple literal node.

[TupleLiteral](ast_package_classes.md#class-tupleliteral) node: Expressed in the format `(expr1, expr2, ... , exprN)`, where each `expr` is an expression.

Parent Types:

- [Expr](#class-expr)

### prop elements

```cangjie
public mut prop elements: ArrayList<Expr>
```

Function: Gets or sets the list of expressions in [TupleLiteral](ast_package_classes.md#class-tupleliteral).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in [TupleLiteral](ast_package_classes.md#class-tupleliteral).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in [TupleLiteral](ast_package_classes.md#class-tupleliteral).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [TupleLiteral](ast_package_classes.md#class-tupleliteral) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TupleLiteral](ast_package_classes.md#class-tupleliteral) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [TupleLiteral](ast_package_classes.md#class-tupleliteral) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed as a [TupleLiteral](ast_package_classes.md#class-tupleliteral) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class TuplePattern

```cangjie
public class TuplePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents a tuple pattern node.

Used for matching `tuple` values, such as `("Bob", age)` in `case ("Bob", age) => 1`.

Parent Type:

- [Pattern](#class-pattern)

### prop commas

```cangjie
public mut prop commas: Tokens
```

Function: Gets or sets the sequence of "," lexical units in the [TuplePattern](ast_package_classes.md#class-tuplepattern) node, which may be empty.

Type: [Tokens](ast_package_classes.md#class-tokens)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Tokens](ast_package_classes.md#class-tokens) is not a sequence of "," lexical units.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" lexical unit in the [TuplePattern](ast_package_classes.md#class-tuplepattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

Function: Gets or sets a group of [Pattern](ast_package_classes.md#class-pattern) nodes in the [TuplePattern](ast_package_classes.md#class-tuplepattern) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" lexical unit in the [TuplePattern](ast_package_classes.md#class-tuplepattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [TuplePattern](ast_package_classes.md#class-tuplepattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TuplePattern](ast_package_classes.md#class-tuplepattern) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units ([Tokens](ast_package_classes.md#class-tokens)) to construct the [TuplePattern](ast_package_classes.md#class-tuplepattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [TuplePattern](ast_package_classes.md#class-tuplepattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class TupleType

```cangjie
public class TupleType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a tuple type node.

For example, `(Int64, Int32)` in `var a : (Int64, Int32)`.

Parent Type:

- [TypeNode](#class-typenode)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" lexical unit in the [TupleType](ast_package_classes.md#class-tupletype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" lexical unit in the [TupleType](ast_package_classes.md#class-tupletype) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

Function: Gets or sets the list of type nodes in the [TupleType](ast_package_classes.md#class-tupletype) node.

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

Function: Constructs a default [TupleType](ast_package_classes.md#class-tupletype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TupleType](ast_package_classes.md#class-tupletype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units ([Tokens](ast_package_classes.md#class-tokens)) to construct the [TupleType](ast_package_classes.md#class-tupletype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [TupleType](ast_package_classes.md#class-tupletype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class TypeAliasDecl

```cangjie
public class TypeAliasDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a type alias node.

A [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) node: `type Point2D = Float64`.

> **Note:**
>
> In this node, `type` is a keyword followed by any valid identifier. The subsequent `type` is any top-level visible type, connected to the identifier by `=`.

Parent Type:

- [Decl](#class-decl)

### prop aliasType

```cangjie
public mut prop aliasType: TypeNode
```

Function: Gets or sets the type to be aliased.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop assign

```cangjie
public mut prop assign: Token
```

Function: Gets or sets the `=` between the identifier and `type`.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not `=`.

### init()

```cangjie
public init()
```

Function: Constructs a default [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units ([Tokens](ast_package_classes.md#class-tokens)) to construct the [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class TypeConvExpr

```cangjie
public class TypeConvExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a type conversion expression.

Used to implement conversions between several numeric types. A [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) node: `Int8(32)`.

Parent Type:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the original expression for type conversion in the [TypeConvExpr](ast_package_classes.md#class-typeconvexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in the [TypeConvExpr](ast_package_classes.md#class-typeconvexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in the [TypeConvExpr](ast_package_classes.md#class-typeconvexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop targetType

```cangjie
public mut prop targetType: PrimitiveType
```

Function: Gets or sets the target type to convert to in the [TypeConvExpr](ast_package_classes.md#class-typeconvexpr).

Type: [PrimitiveType](ast_package_classes.md#class-primitivetype)

### init()

```cangjie
public init()
```

Function: Constructs a default [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units ([Tokens](ast_package_classes.md#class-tokens)) to construct the [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node to the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class TypeNode

```cangjie
public open class TypeNode <: Node {}
```

Function: The parent class of all type nodes, inherits from [Node](ast_package_classes.md#class-node).

Parent Types:

- [Node](#class-node)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the operator ":" in the [TypeNode](ast_package_classes.md#class-typenode), which may be a lexical unit of [ILLEGAL](ast_package_enums.md#illegal).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the ":" operator.

<!--Del_sink-->
### prop modal

```cangjie
public mut prop modal: ModalInfo
```

Function: Gets or sets the modal type at the end of the type node, that is, the local modal type, such as `@ local!` in `Array<Int64> @ local!`, which is used to specify the mode of the type. When no mode is annotated, it is an empty [ModalInfo](ast_package_classes.md#class-modalinfo) object.

Type: [ModalInfo](ast_package_classes.md#class-modalinfo)
<!--DelEnd_sink-->
### prop typeParameterName

```cangjie
public mut prop typeParameterName: Token
```

Function: Gets or sets the parameters of the type node, such as `p1` and `p2` in `(p1:Int64, p2:Int64)`, which may be a lexical unit of [ILLEGAL](ast_package_enums.md#illegal).

Type: [Token](ast_package_structs.md#struct-token)

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

Function: Converts the current syntax tree node into a tree structure and prints it.

Parameters:

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The number of indentation spaces for formatted output.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The formatted output content.

<!--Del_sink-->
### func modalTokens()

```cangjie
protected func modalTokens(): Tokens
```

Function: Gets the [Tokens](ast_package_classes.md#class-tokens) sequence corresponding to the modal annotation at the end of the type node, for subclasses to append at the end of their [toTokens](#func-totokens) implementation. Returns an empty [Tokens](ast_package_classes.md#class-tokens) when the type node has no trailing modal annotation.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The [Tokens](ast_package_classes.md#class-tokens) sequence corresponding to the modal annotation at the end of the type node.
<!--DelEnd_sink-->
## class TypePattern

```cangjie
public class TypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

Function: Represents a type pattern node.

Used to determine whether the runtime type of a value is a subtype of a certain type, such as `b: Base` in `case b: Base => 0`.

Parent Types:

- [Pattern](#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the ":" operator lexical unit node in the [TypePattern](ast_package_classes.md#class-typepattern).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the ":" operator.

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Function: Gets or sets the pattern node in the [TypePattern](ast_package_classes.md#class-typepattern).

Type: [Pattern](ast_package_classes.md#class-pattern)

### prop patternType

```cangjie
public mut prop patternType: TypeNode
```

Function: Gets or sets the pattern type node to be matched in the [TypePattern](ast_package_classes.md#class-typepattern).

Type: [TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

Function: Constructs a default [TypePattern](ast_package_classes.md#class-typepattern) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [TypePattern](ast_package_classes.md#class-typepattern) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [TypePattern](ast_package_classes.md#class-typepattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [TypePattern](ast_package_classes.md#class-typepattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class UnaryExpr

```cangjie
public class UnaryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a unary operation expression node.

Parent Types:

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the operand in the [UnaryExpr](ast_package_classes.md#class-unaryexpr).

Type: [Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

Function: Gets or sets the unary operator in the [UnaryExpr](ast_package_classes.md#class-unaryexpr).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [UnaryExpr](ast_package_classes.md#class-unaryexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [UnaryExpr](ast_package_classes.md#class-unaryexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [UnaryExpr](ast_package_classes.md#class-unaryexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [UnaryExpr](ast_package_classes.md#class-unaryexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class VArrayExpr

```cangjie
public class VArrayExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `VArray` instance node.

A [VArrayExpr](ast_package_classes.md#class-varrayexpr) node: `VArray<Int64, $5>({ i => i })` in `let arr: VArray<Int64, $5> = VArray<Int64, $5>({ i => i })`.

Parent Types:

- [Expr](#class-expr)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

Function: Gets or sets the initialization parameter sequence in the [VArrayExpr](ast_package_classes.md#class-varrayexpr).

Type: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" in the [VArrayExpr](ast_package_classes.md#class-varrayexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" in the [VArrayExpr](ast_package_classes.md#class-varrayexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not ")".

### prop vArrayType

```cangjie
public mut prop vArrayType: VArrayType
```

Function: Gets or sets the VArray type node in the [VArrayExpr](ast_package_classes.md#class-varrayexpr).

Type: [VArrayType](ast_package_classes.md#class-varraytype)

### init()

```cangjie
public init()
```

Function: Constructs a default [VArrayExpr](ast_package_classes.md#class-varrayexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [VArrayExpr](ast_package_classes.md#class-varrayexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [VArrayExpr](ast_package_classes.md#class-varrayexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [VArrayExpr](ast_package_classes.md#class-varrayexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class VArrayType

```cangjie
public class VArrayType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `VArray` type node.

Uses the generic `VArray<T, size: Int64>` to represent the `VArray` type.

Parent Types:

- [TypeNode](#class-typenode)

### prop dollar

```cangjie
public mut prop dollar: Token
```

Function: Gets or sets the `$` operator lexical unit in the [VArrayType](ast_package_classes.md#class-varraytype).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not the `$` lexical unit.

### prop elementTy

```cangjie
public mut prop elementTy: TypeNode
```

Function: Gets or sets the type parameter node in the [VArrayType](ast_package_classes.md#class-varraytype), such as [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) in `VArray<Int16, $0>`.

Type: [TypeNode](ast_package_classes.md#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `VArray` keyword lexical unit in the [VArrayType](ast_package_classes.md#class-varraytype).

Type: [Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

Function: Gets or sets the left angle bracket lexical unit in the [VArrayType](ast_package_classes.md#class-varraytype).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a left angle bracket.

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

Function: Gets or sets the right angle bracket lexical unit in the [VArrayType](ast_package_classes.md#class-varraytype).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the set [Token](ast_package_structs.md#struct-token) is not a right angle bracket.

### prop size

```cangjie
public mut prop size: Token
```

Function: Gets or sets the lexical unit representing the type length in the [VArrayType](ast_package_classes.md#class-varraytype).

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [VArrayType](ast_package_classes.md#class-varraytype) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [VArrayType](ast_package_classes.md#class-varraytype) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) to construct the [VArrayType](ast_package_classes.md#class-varraytype) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [VArrayType](ast_package_classes.md#class-varraytype) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into a [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class VarDecl

```cangjie
public class VarDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a variable declaration node.

A [VarDecl](ast_package_classes.md#class-vardecl) node: `var a: String`, `var b: Int64 = 1`.

> **Note:**
>
> Variable declaration mainly consists of the following parts: modifiers, keywords, patternsMaybeIrrefutable, variable type, and initial value.

Parent Type:

- [Decl](#class-decl)

### prop assign

```cangjie
public mut prop assign: Token
```

Function: Gets or sets the position information of the assignment operator in the [VarDecl](ast_package_classes.md#class-vardecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not an assignment operator.

### prop colon

```cangjie
public mut prop colon: Token
```

Function: Gets or sets the position information of the colon in the [VarDecl](ast_package_classes.md#class-vardecl) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a colon.

### prop declType

```cangjie
public mut prop declType: TypeNode
```

Function: Gets or sets the variable type of the [VarDecl](ast_package_classes.md#class-vardecl) node.

Type: [TypeNode](ast_package_classes.md#class-typenode)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [VarDecl](ast_package_classes.md#class-vardecl) node does not declare a variable type.

### prop expr

```cangjie
public mut prop expr: Expr
```

Function: Gets or sets the variable initialization node of the [VarDecl](ast_package_classes.md#class-vardecl) node.

Type: [Expr](ast_package_classes.md#class-expr)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [VarDecl](ast_package_classes.md#class-vardecl) node does not initialize the variable.

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

Function: Gets or sets the pattern node of the [VarDecl](ast_package_classes.md#class-vardecl) node.

Type: [Pattern](ast_package_classes.md#class-pattern)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the [VarDecl](ast_package_classes.md#class-vardecl) node does not declare a pattern node.

### init()

```cangjie
public init()
```

Function: Constructs a default [VarDecl](ast_package_classes.md#class-vardecl) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [VarDecl](ast_package_classes.md#class-vardecl) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical unit collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [VarDecl](ast_package_classes.md#class-vardecl) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [VarDecl](ast_package_classes.md#class-vardecl) node.

### func isConst()

```cangjie
public func isConst(): Bool
```

Function: Determines whether this is a `Const` type node.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a `Const` type node; otherwise, returns false.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class VarOrEnumPattern

```cangjie
public class VarOrEnumPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

Function: Represents a node where the pattern identifier is an `Enum` constructor.

For example, `RED` in `case RED` is an `Enum` constructor.

Parent Type:

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the lexical unit of the identifier in the [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) node.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) object.

### init(Token)

```cangjie
public init(identifier: Token)
```

Function: Constructs a [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) object.

Parameters:

- identifier: [Token](ast_package_structs.md#struct-token) - The lexical unit used to construct the [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class VarPattern

```cangjie
public class VarPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

Function: Represents a binding pattern node.

Expressed using a valid identifier, such as `i` in `for (i in 1..10)`.

Parent Type:

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

Function: Gets or sets the lexical unit of the identifier in the [VarPattern](ast_package_classes.md#class-varpattern) node.

Type: [Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

Function: Constructs a default [VarPattern](ast_package_classes.md#class-varpattern) object.

### init(Token)

```cangjie
public init(identifier: Token)
```

Function: Constructs a [VarPattern](ast_package_classes.md#class-varpattern) object.

Parameters:

- identifier: [Token](ast_package_structs.md#struct-token) - The lexical unit used to construct the [VarPattern](ast_package_classes.md#class-varpattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) type cannot be constructed as a [VarPattern](ast_package_classes.md#class-varpattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into the [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of the [Visitor](ast_package_classes.md#class-visitor) type.

## class Visitor

```cangjie
public abstract class Visitor {}
```

Function: An abstract class that internally defines default `visit` functions for accessing different types of AST nodes.

> **Note:**
>
> - The `visit` function is used in conjunction with `traverse` to enable node access and modification. All `visit` functions have empty default implementations and can be implemented as needed.
> - This class must be inherited and allows subclasses to redefine visitor functions.
> - For node types that have a parent class, `traverse` visits the current node first, then the parent node, and lastly the child nodes. For parentless node types, it traverses the current node first, followed by its child nodes.

### func breakTraverse()

```cangjie
public func breakTraverse(): Unit
```

Function: Used in overridden `visit` functions to terminate further traversal of child nodes by calling this function.

### func needBreakTraverse()

```cangjie
protected func needBreakTraverse(): Bool
```

Function: Determines whether traversal should be stopped.

> **Note:**
>
> - This function will reset the flag used for judgment after determining that the traversal needs to be stopped. Consequently, if this function is called after invoking `breakTraverse()`, the previous call to `breakTraverse()` may become invalid, which will affect the termination of the traversal.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if traversal should be stopped; otherwise, returns false.

### func visit(Annotation)

```cangjie
protected open func visit(_: Annotation): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [Annotation](ast_package_classes.md#class-annotation) - The traversed node of type [Annotation](ast_package_classes.md#class-annotation).

### func visit(Argument)

```cangjie
protected open func visit(_: Argument): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [Argument](ast_package_classes.md#class-argument) - The traversed node of type [Argument](ast_package_classes.md#class-argument).

### func visit(ArrayLiteral)

```cangjie
protected open func visit(_: ArrayLiteral): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [ArrayLiteral](ast_package_classes.md#class-arrayliteral) - The traversed node of type [ArrayLiteral](ast_package_classes.md#class-arrayliteral).

### func visit(AsExpr)

```cangjie
protected open func visit(_: AsExpr): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [AsExpr](ast_package_classes.md#class-asexpr) - The traversed node of type [AsExpr](ast_package_classes.md#class-asexpr).

### func visit(AssignExpr)

```cangjie
protected open func visit(_: AssignExpr): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [AssignExpr](ast_package_classes.md#class-assignexpr) - The traversed node of type [AssignExpr](ast_package_classes.md#class-assignexpr).

### func visit(BinaryExpr)

```cangjie
protected open func visit(_: BinaryExpr): Unit
```

Function: Defines operations during node access and requires overriding.

Parameters:

- _: [BinaryExpr](ast_package_classes.md#class-binaryexpr) - The traversed node of type [BinaryExpr](ast_package_classes.md#class-binaryexpr).
```### func visit(Block)

```cangjie
protected open func visit(_: Block): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Block](ast_package_classes.md#class-block) - The node being traversed of type [Block](ast_package_classes.md#class-block).

### func visit(Body)

```cangjie
protected open func visit(_: Body): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Body](ast_package_classes.md#class-body) - The node being traversed of type [Body](ast_package_classes.md#class-body).

### func visit(CallExpr)

```cangjie
protected open func visit(_: CallExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [CallExpr](ast_package_classes.md#class-callexpr) - The node being traversed of type [CallExpr](ast_package_classes.md#class-callexpr).

### func visit(ClassDecl)

```cangjie
protected open func visit(_: ClassDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ClassDecl](ast_package_classes.md#class-classdecl) - The node being traversed of type [ClassDecl](ast_package_classes.md#class-classdecl).

### func visit(CommandTypePattern)

```cangjie
protected open func visit(_: CommandTypePattern): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) - The node being traversed of type [CommandTypePattern](ast_package_classes.md#class-commandtypepattern).

### func visit(ConstPattern)

```cangjie
protected open func visit(_: ConstPattern): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ConstPattern](ast_package_classes.md#class-constpattern) - The node being traversed of type [ConstPattern](ast_package_classes.md#class-constpattern).

### func visit(Constructor)

```cangjie
protected open func visit(_: Constructor): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Constructor](ast_package_classes.md#class-constructor) - The node being traversed of type [Constructor](ast_package_classes.md#class-constructor).

### func visit(Decl)

```cangjie
protected open func visit(_: Decl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Decl](ast_package_classes.md#class-decl) - The node being traversed of type [Decl](ast_package_classes.md#class-decl).

### func visit(DoWhileExpr)

```cangjie
protected open func visit(_: DoWhileExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) - The node being traversed of type [DoWhileExpr](ast_package_classes.md#class-dowhileexpr).

### func visit(EnumDecl)

```cangjie
protected open func visit(_: EnumDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [EnumDecl](ast_package_classes.md#class-enumdecl) - The node being traversed of type [EnumDecl](ast_package_classes.md#class-enumdecl).

### func visit(EnumPattern)

```cangjie
protected open func visit(_: EnumPattern): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [EnumPattern](ast_package_classes.md#class-enumpattern) - The node being traversed of type [EnumPattern](ast_package_classes.md#class-enumpattern).

### func visit(ExceptTypePattern)

```cangjie
protected open func visit(_: ExceptTypePattern): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) - The node being traversed of type [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern).

### func visit(ExclaveExpr)

```cangjie
protected open func visit(_: ExclaveExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ExclaveExpr](ast_package_classes.md#class-exclaveexpr) - The node being traversed of type [ExclaveExpr](ast_package_classes.md#class-exclaveexpr).

### func visit(Expr)

```cangjie
protected open func visit(_: Expr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Expr](ast_package_classes.md#class-expr) - The node being traversed of type [Expr](ast_package_classes.md#class-expr).

### func visit(ExtendDecl)

```cangjie
protected open func visit(_: ExtendDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ExtendDecl](ast_package_classes.md#class-extenddecl) - The node being traversed of type [ExtendDecl](ast_package_classes.md#class-extenddecl).


### func visit(FeatureId)

```cangjie
protected open func visit(_: FeatureId): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FeatureId](ast_package_classes.md#class-featureid) - The node being traversed of type [FeatureId](ast_package_classes.md#class-featureid).

### func visit(FeaturesDirective)

```cangjie
protected open func visit(_: FeaturesDirective): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FeaturesDirective](ast_package_classes.md#class-featuresdirective) - The node being traversed of type [FeaturesDirective](ast_package_classes.md#class-featuresdirective).

### func visit(FeaturesSet)

```cangjie
protected open func visit(_: FeaturesSet): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FeaturesSet](ast_package_classes.md#class-featuresset) - The node being traversed of type [FeaturesSet](ast_package_classes.md#class-featuresset).

### func visit(ForInExpr)

```cangjie
protected open func visit(_: ForInExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ForInExpr](ast_package_classes.md#class-forinexpr) - The node being traversed of type [ForInExpr](ast_package_classes.md#class-forinexpr).

### func visit(FuncDecl)

```cangjie
protected open func visit(_: FuncDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FuncDecl](ast_package_classes.md#class-funcdecl) - The node being traversed of type [FuncDecl](ast_package_classes.md#class-funcdecl).

### func visit(FuncParam)

```cangjie
protected open func visit(_: FuncParam): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FuncParam](ast_package_classes.md#class-funcparam) - The node being traversed of type [FuncParam](ast_package_classes.md#class-funcparam).

### func visit(FuncType)

```cangjie
protected open func visit(_: FuncType): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [FuncType](ast_package_classes.md#class-functype) - The node being traversed of type [FuncType](ast_package_classes.md#class-functype).

### func visit(GenericConstraint)

```cangjie
protected open func visit(_: GenericConstraint): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [GenericConstraint](ast_package_classes.md#class-genericconstraint) - The node being traversed of type [GenericConstraint](ast_package_classes.md#class-genericconstraint).

### func visit(GenericParam)

```cangjie
protected open func visit(_: GenericParam): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [GenericParam](ast_package_classes.md#class-genericparam) - The node being traversed of type [GenericParam](ast_package_classes.md#class-genericparam).

### func visit(IfExpr)

```cangjie
protected open func visit(_: IfExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [IfExpr](ast_package_classes.md#class-ifexpr) - The node being traversed of type [IfExpr](ast_package_classes.md#class-ifexpr).

### func visit(ImportContent)

```cangjie
protected open func visit(_: ImportContent): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ImportContent](ast_package_classes.md#class-importcontent) - The node being traversed of type [ImportContent](ast_package_classes.md#class-importcontent).

### func visit(ImportList)

```cangjie
protected open func visit(_: ImportList): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ImportList](ast_package_classes.md#class-importlist) - The node being traversed of type [ImportList](ast_package_classes.md#class-importlist).

### func visit(IncOrDecExpr)

```cangjie
protected open func visit(_: IncOrDecExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) - The node being traversed of type [IncOrDecExpr](ast_package_classes.md#class-incordecexpr).

### func visit(InterfaceDecl)

```cangjie
protected open func visit(_: InterfaceDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [InterfaceDecl](ast_package_classes.md#class-interfacedecl) - The node being traversed of type [InterfaceDecl](ast_package_classes.md#class-interfacedecl).

### func visit(IsExpr)

```cangjie
protected open func visit(_: IsExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [IsExpr](ast_package_classes.md#class-isexpr) - The node being traversed of type [IsExpr](ast_package_classes.md#class-isexpr).

### func visit(JumpExpr)

```cangjie
protected open func visit(_: JumpExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [JumpExpr](ast_package_classes.md#class-jumpexpr) - The node being traversed of type [JumpExpr](ast_package_classes.md#class-jumpexpr).

### func visit(LambdaExpr)

```cangjie
protected open func visit(_: LambdaExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [LambdaExpr](ast_package_classes.md#class-lambdaexpr) - The node being traversed of type [LambdaExpr](ast_package_classes.md#class-lambdaexpr).

### func visit(LetPatternExpr)

```cangjie
protected open func visit(_: LetPatternExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) - The node being traversed of type [LetPatternExpr](ast_package_classes.md#class-letpatternexpr).

### func visit(LitConstExpr)

```cangjie
protected open func visit(_: LitConstExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [LitConstExpr](ast_package_classes.md#class-litconstexpr) - The node being traversed of type [LitConstExpr](ast_package_classes.md#class-litconstexpr).

### func visit(MacroDecl)

```cangjie
protected open func visit(_: MacroDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MacroDecl](ast_package_classes.md#class-macrodecl) - The node being traversed of type [MacroDecl](ast_package_classes.md#class-macrodecl).

### func visit(MacroExpandDecl)

```cangjie
protected open func visit(_: MacroExpandDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) - The node being traversed of type [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl).

### func visit(MacroExpandExpr)

```cangjie
protected open func visit(_: MacroExpandExpr): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) - The node being traversed of type [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr).

### func visit(MacroExpandParam)

```cangjie
protected open func visit(_: MacroExpandParam): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) - The node being traversed of type [MacroExpandParam](ast_package_classes.md#class-macroexpandparam).

### func visit(MainDecl)

```cangjie
protected open func visit(_: MainDecl): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MainDecl](ast_package_classes.md#class-maindecl) - The node being traversed of type [MainDecl](ast_package_classes.md#class-maindecl).

### func visit(MatchCase)

```cangjie
protected open func visit(_: MatchCase): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MatchCase](ast_package_classes.md#class-matchcase) - The node being traversed of type [MatchCase](ast_package_classes.md#class-matchcase).

### func visit(MatchExpr)

```cangjie
protected open func visit(_: MatchExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MatchExpr](ast_package_classes.md#class-matchexpr) - The node being traversed of type [MatchExpr](ast_package_classes.md#class-matchexpr).

### func visit(MemberAccess)

```cangjie
protected open func visit(_: MemberAccess): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [MemberAccess](ast_package_classes.md#class-memberaccess) - The node being traversed of type [MemberAccess](ast_package_classes.md#class-memberaccess).

### func visit(ModalInfo)

```cangjie
protected open func visit(_: ModalInfo): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ModalInfo](ast_package_classes.md#class-modalinfo) - The node being traversed of type [ModalInfo](ast_package_classes.md#class-modalinfo).

### func visit(Modifier)

```cangjie
protected open func visit(_: Modifier): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Modifier](ast_package_classes.md#class-modifier) - The node being traversed of type [Modifier](ast_package_classes.md#class-modifier).

### func visit(Node)

```cangjie
protected open func visit(_: Node): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Node](ast_package_classes.md#class-node) - The node being traversed of type [Node](ast_package_classes.md#class-node).

### func visit(OptionalExpr)

```cangjie
protected open func visit(_: OptionalExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [OptionalExpr](ast_package_classes.md#class-optionalexpr) - The node being traversed of type [OptionalExpr](ast_package_classes.md#class-optionalexpr).

### func visit(PackageHeader)

```cangjie
protected open func visit(_: PackageHeader): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PackageHeader](ast_package_classes.md#class-packageheader) - The node being traversed of type [PackageHeader](ast_package_classes.md#class-packageheader).

### func visit(ParenExpr)

```cangjie
protected open func visit(_: ParenExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ParenExpr](ast_package_classes.md#class-parenexpr) - The node being traversed of type [ParenExpr](ast_package_classes.md#class-parenexpr).

### func visit(ParenType)

```cangjie
protected open func visit(_: ParenType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ParenType](ast_package_classes.md#class-parentype) - The node being traversed of type [ParenType](ast_package_classes.md#class-parentype).

### func visit(Pattern)

```cangjie
protected open func visit(_: Pattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Pattern](ast_package_classes.md#class-pattern) - The node being traversed of type [Pattern](ast_package_classes.md#class-pattern).

### func visit(PerformExpr)

```cangjie
protected open func visit(_: PerformExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PerformExpr](ast_package_classes.md#class-performexpr) - The node being traversed of type [PerformExpr](ast_package_classes.md#class-performexpr).

### func visit(PrefixType)

```cangjie
protected open func visit(_: PrefixType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PrefixType](ast_package_classes.md#class-prefixtype) - The node being traversed of type [PrefixType](ast_package_classes.md#class-prefixtype).

### func visit(PrimaryCtorDecl)

```cangjie
protected open func visit(_: PrimaryCtorDecl): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) - The node being traversed of type [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl).

### func visit(PrimitiveType)

```cangjie
protected open func visit(_: PrimitiveType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PrimitiveType](ast_package_classes.md#class-primitivetype) - The node being traversed of type [PrimitiveType](ast_package_classes.md#class-primitivetype).

### func visit(PrimitiveTypeExpr)

```cangjie
protected open func visit(_: PrimitiveTypeExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) - The node being traversed of type [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr).

### func visit(Program)

```cangjie
protected open func visit(_: Program): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [Program](ast_package_classes.md#class-program) - The node being traversed of type [Program](ast_package_classes.md#class-program).

### func visit(PropDecl)

```cangjie
protected open func visit(_: PropDecl): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [PropDecl](ast_package_classes.md#class-propdecl) - The node being traversed of type [PropDecl](ast_package_classes.md#class-propdecl).

### func visit(QualifiedType)

```cangjie
protected open func visit(_: QualifiedType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [QualifiedType](ast_package_classes.md#class-qualifiedtype) - The node being traversed of type [QualifiedType](ast_package_classes.md#class-qualifiedtype).

### func visit(QuoteExpr)

```cangjie
protected open func visit(_: QuoteExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [QuoteExpr](ast_package_classes.md#class-quoteexpr) - The node being traversed of type [QuoteExpr](ast_package_classes.md#class-quoteexpr).

### func visit(QuoteToken)

```cangjie
protected open func visit(_: QuoteToken): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [QuoteToken](ast_package_classes.md#class-quotetoken) - The node being traversed of type [QuoteToken](ast_package_classes.md#class-quotetoken).

### func visit(RangeExpr)

```cangjie
protected open func visit(_: RangeExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [RangeExpr](ast_package_classes.md#class-rangeexpr) - The node being traversed of type [RangeExpr](ast_package_classes.md#class-rangeexpr).

### func visit(RefExpr)

```cangjie
protected open func visit(_: RefExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [RefExpr](ast_package_classes.md#class-refexpr) - The node being traversed of type [RefExpr](ast_package_classes.md#class-refexpr).

### func visit(RefType)

```cangjie
protected open func visit(_: RefType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [RefType](ast_package_classes.md#class-reftype) - The node being traversed of type [RefType](ast_package_classes.md#class-reftype).

### func visit(ResumeExpr)

```cangjie
protected open func visit(_: ResumeExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ResumeExpr](ast_package_classes.md#class-resumeexpr) - The node being traversed of type [ResumeExpr](ast_package_classes.md#class-resumeexpr).

### func visit(ReturnExpr)

```cangjie
protected open func visit(_: ReturnExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ReturnExpr](ast_package_classes.md#class-returnexpr) - The node being traversed of type [ReturnExpr](ast_package_classes.md#class-returnexpr).

### func visit(SpawnExpr)

```cangjie
protected open func visit(_: SpawnExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [SpawnExpr](ast_package_classes.md#class-spawnexpr) - The node being traversed of type [SpawnExpr](ast_package_classes.md#class-spawnexpr).

### func visit(StructDecl)

```cangjie
protected open func visit(_: StructDecl): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [StructDecl](ast_package_classes.md#class-structdecl) - The node being traversed of type [StructDecl](ast_package_classes.md#class-structdecl).

### func visit(SubscriptExpr)

```cangjie
protected open func visit(_: SubscriptExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) - The node being traversed of type [SubscriptExpr](ast_package_classes.md#class-subscriptexpr).

### func visit(SynchronizedExpr)

```cangjie
protected open func visit(_: SynchronizedExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) - The node being traversed of type [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr).

### func visit(ThisParam)

```cangjie
protected open func visit(_: ThisParam): Unit
```

Function: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ThisParam](ast_package_classes.md#class-thisparam) - The node being traversed of type [ThisParam](ast_package_classes.md#class-thisparam).

### func visit(ThisType)

```cangjie
protected open func visit(_: ThisType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ThisType](ast_package_classes.md#class-thistype) - The node being traversed of type [ThisType](ast_package_classes.md#class-thistype).

### func visit(ThrowExpr)

```cangjie
protected open func visit(_: ThrowExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [ThrowExpr](ast_package_classes.md#class-throwexpr) - The node being traversed of type [ThrowExpr](ast_package_classes.md#class-throwexpr).

### func visit(TrailingClosureExpr)

```cangjie
protected open func visit(_: TrailingClosureExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) - The node being traversed of type [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr).

### func visit(TryExpr)

```cangjie
protected open func visit(_: TryExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TryExpr](ast_package_classes.md#class-tryexpr) - The node being traversed of type [TryExpr](ast_package_classes.md#class-tryexpr).

### func visit(TupleLiteral)

```cangjie
protected open func visit(_: TupleLiteral): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TupleLiteral](ast_package_classes.md#class-tupleliteral) - The node being traversed of type [TupleLiteral](ast_package_classes.md#class-tupleliteral).

### func visit(TuplePattern)

```cangjie
protected open func visit(_: TuplePattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TuplePattern](ast_package_classes.md#class-tuplepattern) - The node being traversed of type [TuplePattern](ast_package_classes.md#class-tuplepattern).

### func visit(TupleType)

```cangjie
protected open func visit(_: TupleType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TupleType](ast_package_classes.md#class-tupletype) - The node being traversed of type [TupleType](ast_package_classes.md#class-tupletype).

### func visit(TypeAliasDecl)

```cangjie
protected open func visit(_: TypeAliasDecl): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) - The node being traversed of type [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl).

### func visit(TypeConvExpr)

```cangjie
protected open func visit(_: TypeConvExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) - The node being traversed of type [TypeConvExpr](ast_package_classes.md#class-typeconvexpr).

### func visit(TypeNode)

```cangjie
protected open func visit(_: TypeNode): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TypeNode](ast_package_classes.md#class-typenode) - The node being traversed of type [TypeNode](ast_package_classes.md#class-typenode).

### func visit(TypePattern)

```cangjie
protected open func visit(_: TypePattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [TypePattern](ast_package_classes.md#class-typepattern) - The node being traversed of type [TypePattern](ast_package_classes.md#class-typepattern).

### func visit(UnaryExpr)

```cangjie
protected open func visit(_: UnaryExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [UnaryExpr](ast_package_classes.md#class-unaryexpr) - The node being traversed of type [UnaryExpr](ast_package_classes.md#class-unaryexpr).

### func visit(VArrayExpr)

```cangjie
protected open func visit(_: VArrayExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [VArrayExpr](ast_package_classes.md#class-varrayexpr) - The node being traversed of type [VArrayExpr](ast_package_classes.md#class-varrayexpr).

### func visit(VArrayType)

```cangjie
protected open func visit(_: VArrayType): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [VArrayType](ast_package_classes.md#class-varraytype) - The node being traversed of type [VArrayType](ast_package_classes.md#class-varraytype).

### func visit(VarDecl)

```cangjie
protected open func visit(_: VarDecl): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [VarDecl](ast_package_classes.md#class-vardecl) - The node being traversed of type [VarDecl](ast_package_classes.md#class-vardecl).

### func visit(VarOrEnumPattern)

```cangjie
protected open func visit(_: VarOrEnumPattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) - The node being traversed of type [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern).

### func visit(VarPattern)

```cangjie
protected open func visit(_: VarPattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [VarPattern](ast_package_classes.md#class-varpattern) - The node being traversed of type [VarPattern](ast_package_classes.md#class-varpattern).

### func visit(WhileExpr)

```cangjie
protected open func visit(_: WhileExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [WhileExpr](ast_package_classes.md#class-whileexpr) - The node being traversed of type [WhileExpr](ast_package_classes.md#class-whileexpr).

### func visit(WildcardExpr)

```cangjie
protected open func visit(_: WildcardExpr): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [WildcardExpr](ast_package_classes.md#class-wildcardexpr) - The node being traversed of type [WildcardExpr](ast_package_classes.md#class-wildcardexpr).

### func visit(WildcardPattern)

```cangjie
protected open func visit(_: WildcardPattern): Unit
```

Purpose: Defines the operation when visiting a node, requires override.

Parameters:

- _: [WildcardPattern](ast_package_classes.md#class-wildcardpattern) - The node being traversed of type [WildcardPattern](ast_package_classes.md#class-wildcardpattern).

## class WhileExpr

```cangjie
public class WhileExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

Function: Represents a `while` expression.

`while` is a keyword, followed by parentheses which may contain either an expression or a destructuring `let` declaration, then a [Block](ast_package_classes.md#class-block) node.

Parent Type:

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

Function: Gets or sets the block node within [WhileExpr](ast_package_classes.md#class-whileexpr).

Type: [Block](ast_package_classes.md#class-block)

### prop condition

```cangjie
public mut prop condition: Expr
```

Function: Gets or sets the conditional expression in the [WhileExpr](ast_package_classes.md#class-whileexpr) keyword.

Type: [Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets or sets the `while` keyword in the [WhileExpr](ast_package_classes.md#class-whileexpr) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a `while` keyword.

### prop lParen

```cangjie
public mut prop lParen: Token
```

Function: Gets or sets the "(" token following the `while` keyword in [WhileExpr](ast_package_classes.md#class-whileexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not "(".

### prop rParen

```cangjie
public mut prop rParen: Token
```

Function: Gets or sets the ")" token following the `while` keyword in [WhileExpr](ast_package_classes.md#class-whileexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not ")".

### init()

```cangjie
public init()
```

Function: Constructs a default [WhileExpr](ast_package_classes.md#class-whileexpr) object.

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

Function: Constructs a [WhileExpr](ast_package_classes.md#class-whileexpr) object.

Parameters:

- inputs: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [WhileExpr](ast_package_classes.md#class-whileexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [WhileExpr](ast_package_classes.md#class-whileexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class WildcardExpr

```cangjie
public class WildcardExpr <: Expr {
    public init(keyword: Tokens)
    public init()
}
```

Function: Represents a wildcard expression node.

Parent Type:

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

Function: Gets the "_" keyword in [WildcardExpr](ast_package_classes.md#class-wildcardexpr).

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not a "_" keyword.

### init()

```cangjie
public init()
```

Function: Constructs a default [WildcardExpr](ast_package_classes.md#class-wildcardexpr) object.

### init(Tokens)

```cangjie
public init(keyword: Tokens)
```

Function: Constructs a [WildcardExpr](ast_package_classes.md#class-wildcardexpr) object.

Parameters:

- keyword: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [WildcardExpr](ast_package_classes.md#class-wildcardexpr) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [WildcardExpr](ast_package_classes.md#class-wildcardexpr) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.

## class WildcardPattern

```cangjie
public class WildcardPattern <: Pattern {
    public init(keyword: Tokens)
    public init()
}
```

Function: Represents a wildcard pattern node.

Denoted by underscore "_", which can match any value.

Parent Type:

- [Pattern](#class-pattern)

### prop wildcard

```cangjie
public mut prop wildcard: Token
```

Function: Gets or sets the "_" operator token in the [WildcardPattern](ast_package_classes.md#class-wildcardpattern) node.

Type: [Token](ast_package_structs.md#struct-token)

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the provided [Token](ast_package_structs.md#struct-token) is not an "_" operator.

### init()

```cangjie
public init()
```

Function: Constructs a default [WildcardPattern](ast_package_classes.md#class-wildcardpattern) object.

### init(Tokens)

```cangjie
public init(keyword: Tokens)
```

Function: Constructs a [WildcardPattern](ast_package_classes.md#class-wildcardpattern) object.

Parameters:

- keyword: [Tokens](ast_package_classes.md#class-tokens) - The lexical token collection ([Tokens](ast_package_classes.md#class-tokens)) used to construct the [WildcardPattern](ast_package_classes.md#class-wildcardpattern) type.

Exceptions:

- [ASTException](ast_package_exceptions.md#class-astexception) - Thrown when the input [Tokens](ast_package_classes.md#class-tokens) cannot be constructed into a [WildcardPattern](ast_package_classes.md#class-wildcardpattern) node.

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

Function: Converts the current syntax tree node into [Tokens](ast_package_classes.md#class-tokens) type.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The converted [Tokens](ast_package_classes.md#class-tokens) type node.

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

Function: Traverses the current syntax tree node and its child nodes. To terminate the traversal of child nodes early, override the `visit` function and call the `breakTraverse` function. See [Custom Visitor Function for Traversing AST Objects Example](../ast_samples/traverse.md).

Parameters:

- v: [Visitor](ast_package_classes.md#class-visitor) - An instance of [Visitor](ast_package_classes.md#class-visitor) type.
