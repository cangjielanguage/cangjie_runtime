# 类

## class Annotation

```cangjie
public class Annotation <: Node {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示编译器内置的注解节点。

一个 [Annotation](ast_package_classes.md#class-annotation) 节点：`@CallingConv[xxx]`, `@Attribute[xxx]`, `@When[condition]`等。

父类型：

- [Node](#class-node)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

功能：获取或设置 [Annotation](ast_package_classes.md#class-annotation) 中的参数序列，如 `@CallingConv[xxx]` 中的 `xxx`。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop at

```cangjie
public mut prop at: Token
```

功能：获取或设置 [Annotation](ast_package_classes.md#class-annotation) 节点中的 `@` 操作符或 `@!` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `@` 操作符或 `@!` 操作符时，抛出异常。

### prop attributes

```cangjie
public mut prop attributes: Tokens
```

功能：获取或设置 `Attribute` 中设置的属性值，仅用于 `@Attribute`，如 `@Attribute[xxx]` 中的 `xxx`。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop condition

```cangjie
public mut prop condition: Expr
```

功能：获取或设置条件编译中的条件表达式，用于 `@When`，如 `@When[xxx]` 中的 `xxx`。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [Annotation](ast_package_classes.md#class-annotation) 节点中没有条件表达式时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [Annotation](ast_package_classes.md#class-annotation) 节点的标识符，如 `@CallingConv[xxx]` 中的 `CallingConv`。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Annotation](ast_package_classes.md#class-annotation) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Annotation 对象
    let annotation = Annotation()

    // 设置 Annotation 的属性
    annotation.identifier = Token(TokenKind.IDENTIFIER, "Anno")

    // 输出 Annotation 节点转化成的 Tokens
    println("annotation.toTokens(): ${annotation.toTokens()}")
}
```

运行结果：

```text
annotation.toTokens(): @Anno
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：根据输入的词法单元，构造一个 [Annotation](ast_package_classes.md#class-annotation) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [Annotation](ast_package_classes.md#class-annotation) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [Annotation](ast_package_classes.md#class-annotation) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 Annotation 对象
    let annotation = Annotation(quote(@!Anno))

    // 输出 Annotation 节点转化成的 Tokens
    println("annotation.toTokens(): ${annotation.toTokens()}")
}
```

运行结果：

```text
annotation.toTokens(): @!Anno
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 Annotation 对象
    let annotation = Annotation(quote(@!Anno))

    // 输出 Annotation 节点转化成的 Tokens
    println("annotation.toTokens(): ${annotation.toTokens()}")
}
```

运行结果：

```text
annotation.toTokens(): @!Anno
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Annotation) {
        println("Visiting Annotation")
    }
}

main(): Unit {
    let annotation = Annotation(quote(@!Anno))

    // 对 Annotation 节点进行遍历
    annotation.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Annotation
```

## class Argument

```cangjie
public class Argument <: Node {
    public init()
}
```

功能：表示函数调用的实参节点。

例如 `foo(arg:value)` 中的 `arg:value`。

父类型：

- [Node](#class-node)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [Argument](ast_package_classes.md#class-argument) 节点中的操作符 ":"，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 操作符时，抛出异常。

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [Argument](ast_package_classes.md#class-argument) 节点中的表达式，如 `arg:value` 中的 `value`。

类型：[Expr](ast_package_classes.md#class-expr)

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [Argument](ast_package_classes.md#class-argument) 节点中的标识符，如 `arg:value` 中的 `arg`，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当获取和设置的 [Token](ast_package_structs.md#struct-token) 类型不是 [IDENTIFIER](ast_package_enums.md#identifier) 标识符或 [Token](ast_package_structs.md#struct-token) 的字面量值是空时，抛出异常。

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [Argument](ast_package_classes.md#class-argument) 节点中的关键字 `inout`，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Argument](ast_package_classes.md#class-argument) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Argument 对象
    let argument = Argument()
    argument.expr = RefExpr(quote(value))

    // 将 Argument 转化为 Tokens 并输出
    println("argument.toTokens(): ${argument.toTokens()}")
}
```

运行结果：

```text
argument.toTokens(): value
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let argument = Argument()
    let identifierToken = Token(TokenKind.IDENTIFIER, "arg")
    let colonToken = Token(TokenKind.COLON, ":")

    // 设置 Argument 的属性
    argument.identifier = identifierToken
    argument.colon = colonToken
    argument.expr = RefExpr(quote(value))

    // 将 Argument 转化为 Tokens 并输出
    println("argument.toTokens(): ${argument.toTokens()}")
}
```

运行结果：

```text
argument.toTokens(): arg: value
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Argument) {
        println("Visiting Argument")
    }
}

main(): Unit {
    let argument = Argument()
    argument.expr = RefExpr(quote(value))

    // 使用自定义访问器遍历 Argument 节点
    argument.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Argument
```

## class ArrayLiteral

```cangjie
public class ArrayLiteral <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) 字面量节点。

[ArrayLiteral](ast_package_classes.md#class-arrayliteral) 节点：使用格式 `[element1, element2, ... , elementN]` 表示， 每个 `element` 是一个表达式。

父类型：

- [Expr](#class-expr)

### prop elements

```cangjie
public mut prop elements: ArrayList<Expr>
```

功能：获取或设置 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 中的表达式列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

功能：获取或设置 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 中的 "["。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "[" 时，抛出异常。

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

功能：获取或设置 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 中的 "]"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "]" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ArrayLiteral 对象
    let arrayLiteral = ArrayLiteral()

    // 设置 ArrayLiteral 的属性
    arrayLiteral.lSquare = Token(TokenKind.LSQUARE, "[")
    arrayLiteral.rSquare = Token(TokenKind.RSQUARE, "]")

    println("arrayLiteral.toTokens(): ${arrayLiteral.toTokens()}")
}
```

运行结果：

```text
arrayLiteral.toTokens(): []
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ArrayLiteral 对象
    let arrayLiteral = ArrayLiteral(quote([1, 2, 3]))

    println("arrayLiteral.toTokens(): ${arrayLiteral.toTokens()}")
}
```

运行结果：

```text
arrayLiteral.toTokens(): [1, 2, 3]
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let arrayLiteral = ArrayLiteral()

    // 设置数组字面量的属性
    arrayLiteral.lSquare = Token(TokenKind.LSQUARE, "[")
    arrayLiteral.rSquare = Token(TokenKind.RSQUARE, "]")
    arrayLiteral.elements.add(RefExpr(quote(item)))

    // 转化为 Tokens 并输出
    println("arrayLiteral.toTokens(): ${arrayLiteral.toTokens()}")
}
```

运行结果：

```text
arrayLiteral.toTokens(): [item]
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ArrayLiteral) {
        println("Visiting ArrayLiteral")
    }
}

main(): Unit {
    let arrayLiteral = ArrayLiteral(quote([1, 2]))

    // 使用自定义访问器遍历 ArrayLiteral 节点
    arrayLiteral.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ArrayLiteral
```

## class AsExpr

```cangjie
public class AsExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个类型检查表达式。

一个 [AsExpr](ast_package_classes.md#class-asexpr) 表达式：`e as T`，类型为 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<T>。其中 e 可以是任何类型的表达式，T 可以是任何类型。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [AsExpr](ast_package_classes.md#class-asexpr) 节点中的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [AsExpr](ast_package_classes.md#class-asexpr) 节点中的 `as` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `as` 操作符时，抛出异常。

### prop shiftType

```cangjie
public mut prop shiftType: TypeNode
```

功能：获取或设置 [AsExpr](ast_package_classes.md#class-asexpr) 节点中的目标类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [AsExpr](ast_package_classes.md#class-asexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 AsExpr 对象
    let asExpr = AsExpr()

    // 设置 AsExpr 的属性
    asExpr.expr = RefExpr(quote(x))
    asExpr.keyword = Token(TokenKind.AS, "as")
    asExpr.shiftType = RefType(quote(A))

    println("asExpr.toTokens(): ${asExpr.toTokens()}")
}
```

运行结果：

```text
asExpr.toTokens(): x as A
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [AsExpr](ast_package_classes.md#class-asexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [AsExpr](ast_package_classes.md#class-asexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [AsExpr](ast_package_classes.md#class-asexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 AsExpr 对象
    let asExpr = AsExpr(quote(value as Int64))

    println("asExpr.toTokens(): ${asExpr.toTokens()}")
}
```

运行结果：

```text
asExpr.toTokens(): value as Int64
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 AsExpr 对象
    let asExpr = AsExpr(quote(value as Int64))

    // 转化为 Tokens 并输出
    println("asExpr.toTokens(): ${asExpr.toTokens()}")
}
```

运行结果：

```text
asExpr.toTokens(): value as Int64
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: AsExpr) {
        println("Visiting AsExpr")
    }
}

main(): Unit {
    let asExpr = AsExpr(quote(a as Int32))

    // 使用自定义访问器遍历 AsExpr 节点
    asExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting AsExpr
```

## class AssignExpr

```cangjie
public class AssignExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示赋值表达式节点。

用于将左操作数的值修改为右操作数的值。一个 [AssignExpr](ast_package_classes.md#class-assignexpr) 节点：`a = b`。

父类型：

- [Expr](#class-expr)

### prop assign

```cangjie
public mut prop assign: Token
```

功能：获取或设置 [AssignExpr](ast_package_classes.md#class-assignexpr) 节点中的赋值操作符（如 `=` 等）。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是赋值操作符时，抛出异常。

### prop leftExpr

```cangjie
public mut prop leftExpr: Expr
```

功能：获取或设置 [AssignExpr](ast_package_classes.md#class-assignexpr) 节点中的左操作数。

类型：[Expr](ast_package_classes.md#class-expr)

### prop rightExpr

```cangjie
public mut prop rightExpr: Expr
```

功能：获取或设置 [AssignExpr](ast_package_classes.md#class-assignexpr) 节点中的右操作数。

类型：[Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [AssignExpr](ast_package_classes.md#class-assignexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 AssignExpr 对象
    let assignExpr = AssignExpr()

    // 设置 AssignExpr 的属性
    assignExpr.leftExpr = RefExpr(quote(a))
    assignExpr.assign = Token(TokenKind.ASSIGN, "=")
    assignExpr.rightExpr = RefExpr(quote(b))

    println("assignExpr.toTokens(): ${assignExpr.toTokens()}")
}
```

运行结果：

```text
assignExpr.toTokens(): a = b
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [AssignExpr](ast_package_classes.md#class-assignexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [AssignExpr](ast_package_classes.md#class-assignexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [AssignExpr](ast_package_classes.md#class-assignexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 AssignExpr 对象
    let assignExpr = AssignExpr(quote(x = 10))

    println("assignExpr.toTokens(): ${assignExpr.toTokens()}")
}
```

运行结果：

```text
assignExpr.toTokens(): x = 10
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let assignExpr = AssignExpr()

    // 设置 AssignExpr 的属性
    assignExpr.leftExpr = RefExpr(quote(x))
    assignExpr.assign = Token(TokenKind.ASSIGN, "=")
    assignExpr.rightExpr = LitConstExpr(quote(42))

    // 转化为 Tokens 并输出
    println("assignExpr.toTokens(): ${assignExpr.toTokens()}")
}
```

运行结果：

```text
assignExpr.toTokens(): x = 42
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: AssignExpr) {
        println("Visiting AssignExpr")
    }
}

main(): Unit {
    let assignExpr = AssignExpr(quote(x = 10))

    // 使用自定义访问器遍历 AssignExpr 节点
    assignExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting AssignExpr
```

## class BinaryExpr

```cangjie
public class BinaryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个二元操作表达式节点。

一个 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点：`a + b`, `a - b` 等。

父类型：

- [Expr](#class-expr)

### prop leftExpr

```cangjie
public mut prop leftExpr: Expr
```

功能：获取或设置 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点中操作符左侧的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

功能：获取或设置 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点中的二元操作符。

类型：[Token](ast_package_structs.md#struct-token)

### prop rightExpr

```cangjie
public mut prop rightExpr: Expr
```

功能：获取或设置 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点中操作符右侧的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 BinaryExpr 对象
    let binaryExpr = BinaryExpr()

    // 设置 BinaryExpr 的属性
    binaryExpr.leftExpr = RefExpr(quote(x))
    binaryExpr.op = Token(TokenKind.ADD, "+")
    binaryExpr.rightExpr = RefExpr(quote(y))

    println("binaryExpr.toTokens(): ${binaryExpr.toTokens()}")
}
```

运行结果：

```text
binaryExpr.toTokens(): x + y
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 BinaryExpr 对象
    let binaryExpr = BinaryExpr(quote(5 + 3))

    println("binaryExpr.toTokens(): ${binaryExpr.toTokens()}")
}
```

运行结果：

```text
binaryExpr.toTokens(): 5 + 3
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 BinaryExpr 对象
    let binaryExpr = BinaryExpr()

    // 设置 BinaryExpr 的属性
    binaryExpr.leftExpr = RefExpr(quote(a))
    binaryExpr.op = Token(TokenKind.MUL, "*")
    binaryExpr.rightExpr = RefExpr(quote(b))

    // 转化为 Tokens 并输出
    println("binaryExpr.toTokens(): ${binaryExpr.toTokens()}")
}
```

运行结果：

```text
binaryExpr.toTokens(): a * b
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: BinaryExpr) {
        println("Visiting BinaryExpr")
    }
}

main(): Unit {
    let binaryExpr = BinaryExpr(quote(1 + 1))

    // 使用自定义访问器遍历 BinaryExpr 节点
    binaryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting BinaryExpr
```

## class Block

```cangjie
public class Block <: Expr {
    public init()
}
```

功能：表示块节点。

[Block](ast_package_classes.md#class-block) 由一对匹配的大括号及其中可选的表达式声明序列组成的结构，简称 “块”。

父类型：

- [Expr](#class-expr)

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [Block](ast_package_classes.md#class-block) 的 "{"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "{" 时，抛出异常。

### prop nodes

```cangjie
public mut prop nodes: ArrayList<Node>
```

功能：获取或设置 [Block](ast_package_classes.md#class-block) 中的表达式或声明序列。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Node](ast_package_classes.md#class-node)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [Block](ast_package_classes.md#class-block) 的 "}"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "}" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Block](ast_package_classes.md#class-block) 对象。

> **说明：**
>
> [Block](ast_package_classes.md#class-block) 节点无法脱离表达式或声明节点单独存在，因此不提供其他的构造函数。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Block 对象
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")

    // 转化为 Tokens 并输出
    println("block.toTokens(): ${block.toTokens()}")
}
```

运行结果：

```text
block.toTokens(): {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")
    let expr = CallExpr(quote(foo()))
    block.nodes.add(expr)

    // 转化为 Tokens 并输出
    println("block.toTokens(): ${block.toTokens()}")
}
```

运行结果：

```text
block.toTokens(): {
    foo()
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Block) {
        println("Visiting Block")
    }
}

main(): Unit {
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 Block 节点
    block.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Block
```

## class Body

```cangjie
public class Body <: Node {
    public init(decls: ArrayList<Decl>)
    public init()
}
```

功能：表示 Class 类型、 Struct 类型、 Interface 类型以及扩展中由 `{}` 和内部的一组声明节点组成的结构。

父类型：

- [Node](#class-node)

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

功能：获取或设置 [Body](ast_package_classes.md#class-body) 内的声明节点集合。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 `{` 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `{` 词法单元时，抛出异常。

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 `}` 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `}` 词法单元时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Body](ast_package_classes.md#class-body) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Body 对象
    let body = Body()

    // 设置 Body 的属性
    body.lBrace = Token(TokenKind.LCURL, "{")
    body.rBrace = Token(TokenKind.RCURL, "}")

    println("body.toTokens(): ${body.toTokens()}")
}
```

运行结果：

```text
body.toTokens(): {
}
```

### init(ArrayList\<Decl>)

```cangjie
public init(decls: ArrayList<Decl>)
```

功能：构造一个 [Body](ast_package_classes.md#class-body) 对象。

参数：

- decls: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)> - 将要构造 [Body](ast_package_classes.md#class-body) 类型的声明列表。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 创建声明列表
    let decls = ArrayList<Decl>()
    // 将变量声明添加到列表中
    decls.add(VarDecl(quote(let x: Int64 = 10)))

    // 使用声明列表创建 Body 对象
    let body = Body(decls)
    // 输出转换后的 Tokens
    println("body.toTokens(): ${body.toTokens()}")
}
```

运行结果：

```text
body.toTokens(): {
    let x: Int64 = 10
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 Body 对象
    let body = Body()
    // 将变量声明添加到 Body 中
    body.decls.add(VarDecl(quote(let x: Int64 = 10)))
    // 将函数声明添加到 Body 中
    body.decls.add(FuncDecl(quote(func foo() {})))

    // 设置左右花括号
    body.lBrace = Token(TokenKind.LCURL, "{")
    body.rBrace = Token(TokenKind.RCURL, "}")

    // 转换为 Tokens 并输出
    println("body.toTokens(): ${body.toTokens()}")
}
```

运行结果：

```text
body.toTokens(): {
    let x: Int64 = 10
    func foo() {
    }
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

class MyVisitor <: Visitor {
    public override func visit(_: Body) {
        println("Visiting Body")
    }
}

main(): Unit {
    // 构造一个默认的 Body 对象
    let body = Body()

    // 设置 Body 的属性
    body.lBrace = Token(TokenKind.LCURL, "{")
    body.rBrace = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 Body 节点
    body.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Body
```

## class CallExpr

```cangjie
public class CallExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示函数调用节点。

一个 [CallExpr](ast_package_classes.md#class-callexpr) 节点包括一个表达式后面紧跟参数列表，例如 `foo(100)`。

父类型：

- [Expr](#class-expr)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

功能：获取或设置 [CallExpr](ast_package_classes.md#class-callexpr) 节点中函数参数。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop callFunc

```cangjie
public mut prop callFunc: Expr
```

功能：获取或设置 [CallExpr](ast_package_classes.md#class-callexpr) 节点中的函数调用节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [CallExpr](ast_package_classes.md#class-callexpr) 节点中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [CallExpr](ast_package_classes.md#class-callexpr) 节点中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [CallExpr](ast_package_classes.md#class-callexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 CallExpr 对象
    let callExpr = CallExpr()

    // 设置 CallExpr 的属性
    callExpr.callFunc = RefExpr(quote(bar))
    callExpr.lParen = Token(TokenKind.LPAREN, "(")
    callExpr.rParen = Token(TokenKind.RPAREN, ")")

    println("callExpr.toTokens(): ${callExpr.toTokens()}")
}
```

运行结果：

```text
callExpr.toTokens(): bar()
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [CallExpr](ast_package_classes.md#class-callexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [CallExpr](ast_package_classes.md#class-callexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [CallExpr](ast_package_classes.md#class-callexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 CallExpr 对象
    let callExpr = CallExpr(quote(foo(10, "hello")))

    // 转化为 Tokens 并输出
    println("callExpr.toTokens(): ${callExpr.toTokens()}")
}
```

运行结果：

```text
callExpr.toTokens(): foo(10, "hello")
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 CallExpr 对象
    let callExpr = CallExpr()

    // 设置 CallExpr 的属性
    callExpr.callFunc = RefExpr(quote(bar))
    callExpr.lParen = Token(TokenKind.LPAREN, "(")
    callExpr.rParen = Token(TokenKind.RPAREN, ")")

    // 创建第一个参数并添加到调用表达式中
    let arg1 = Argument()
    arg1.expr = LitConstExpr(quote(true))
    callExpr.arguments.add(arg1)

    // 创建第二个参数并添加到调用表达式中
    let arg2 = Argument()
    arg2.expr = LitConstExpr(quote(3.14))
    callExpr.arguments.add(arg2)

    // 转化为 Tokens 并输出
    println("callExpr.toTokens(): ${callExpr.toTokens()}")
}
```

运行结果：

```text
callExpr.toTokens(): bar(true, 3.14)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: CallExpr) {
        println("Visiting CallExpr")
    }
}

main(): Unit {
    let callExpr = CallExpr(quote(foo(42)))

    // 使用自定义访问器遍历 CallExpr 节点
    callExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting CallExpr
```

## class ClassDecl

```cangjie
public class ClassDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：类定义节点。

类的定义使用 `class` 关键字，定义依次为：可缺省的修饰符、class 关键字、class 名、可选的类型参数、是否指定父类或父接口、可选的泛型约束、类体的定义。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

功能：获取或设置 [ClassDecl](ast_package_classes.md#class-classdecl) 节点的类体。

类型：[Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

功能：获取或设置 [ClassDecl](ast_package_classes.md#class-classdecl) 节点的父类或父接口声明中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

功能：获取或设置 [ClassDecl](ast_package_classes.md#class-classdecl) 节点的父类或者父接口。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 `<:` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ClassDecl](ast_package_classes.md#class-classdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ClassDecl 对象
    let classDecl = ClassDecl()

    // 设置 ClassDecl 的属性
    classDecl.keyword = Token(TokenKind.CLASS, "class")
    classDecl.identifier = Token(TokenKind.IDENTIFIER, "A")
    classDecl.body = Body()

    println("classDecl.toTokens(): ${classDecl.toTokens()}")
}
```

运行结果：

```text
classDecl.toTokens(): class A {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ClassDecl](ast_package_classes.md#class-classdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ClassDecl](ast_package_classes.md#class-classdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ClassDecl](ast_package_classes.md#class-classdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ClassDecl 对象
    let classDecl = ClassDecl(quote(class MyClass {}))

    // 转化为 Tokens 并输出
    println("classDecl.toTokens(): ${classDecl.toTokens()}")
}
```

运行结果：

```text
classDecl.toTokens(): class MyClass {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 ClassDecl 对象
    let classDecl = ClassDecl()

    // 设置 ClassDecl 的属性
    classDecl.keyword = Token(TokenKind.CLASS, "class")
    classDecl.identifier = Token(TokenKind.IDENTIFIER, "A")
    let varDecl = VarDecl(quote(let x: Int64 = 10))
    classDecl.body = Body(ArrayList<Decl>([varDecl]))

    // 转化为 Tokens 并输出
    println("classDecl.toTokens(): ${classDecl.toTokens()}")
}
```

运行结果：

```text
classDecl.toTokens(): class A {
    let x: Int64 = 10
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ClassDecl) {
        println("Visiting ClassDecl")
    }
}

main(): Unit {
    // 从 Tokens 创建 ClassDecl 对象
    let classDecl = ClassDecl(quote(class Test {}))

    // 使用自定义访问器遍历 ClassDecl 节点
    classDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ClassDecl
```

## class CommandTypePattern

```cangjie
public class CommandTypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示一个带有类型注解的命令模式，例如：`pattern: Type1 | Type2 | ...`。

一个 [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) 节点的示例：
`someCommand: Effect`

父类型：

- [Pattern](ast_package_classes.md#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置用于分隔模式与类型的冒号（`:`）标记。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 如果提供的标记不是冒号，则抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置冒号（`:`）之前的命令模式。

类型：[Pattern](ast_package_classes.md#class-pattern)

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

功能：获取或设置冒号后面的类型节点列表，例如：`String | Int | Float`。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构建一个默认的 [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 CommandTypePattern 对象
    let commandTypePattern = CommandTypePattern()

    // 设置 CommandTypePattern 的属性
    commandTypePattern.colon = Token(TokenKind.COLON, ":")
    commandTypePattern.pattern = WildcardPattern()
    commandTypePattern.types = ArrayList<TypeNode>([RefType(quote(Eff))])

    // 转化为 Tokens 并输出
    println("commandTypePattern.toTokens(): ${commandTypePattern.toTokens()}")
}
```

运行结果：

```text
commandTypePattern.toTokens(): _: Eff
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：从标记流中构建一个 [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) — 要解析为 `CommandTypePattern` 节点的标记集合。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 如果输入的标记无法解析为有效的 `CommandTypePattern` 节点，则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 CommandTypePattern 对象
    let commandTypePattern = CommandTypePattern(quote(e: MyEffect))

    // 转化为 Tokens 并输出
    println("commandTypePattern.toTokens(): ${commandTypePattern.toTokens()}")
}
```

运行结果：

```text
commandTypePattern.toTokens(): e: MyEffect
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 CommandTypePattern 对象
    let commandTypePattern = CommandTypePattern()

    // 设置 CommandTypePattern 的属性
    commandTypePattern.colon = Token(TokenKind.COLON, ":")
    commandTypePattern.pattern = WildcardPattern()
    commandTypePattern.types = ArrayList<TypeNode>([RefType(quote(Eff))])

    // 转化为 Tokens 并输出
    println("commandTypePattern.toTokens(): ${commandTypePattern.toTokens()}")
}
```

运行结果：

```text
commandTypePattern.toTokens(): _: Eff
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: CommandTypePattern) {
        println("Visiting CommandTypePattern")
    }
}

main(): Unit {
    // 从 Tokens 创建 CommandTypePattern 对象
    let commandTypePattern = CommandTypePattern(quote(e: MyEffect))

    // 使用自定义访问器遍历 CommandTypePattern 节点
    commandTypePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting CommandTypePattern
```

## class ConstPattern

```cangjie
public class ConstPattern <: Pattern {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示常量模式节点。

常量模式可以是整数字面量、字符字节字面量、浮点数字面量、字符字面量、布尔字面量、字符串字面量等字面量，如 `case 1 => 0` 中的 `1`。

父类型：

- [Pattern](#class-pattern)

### prop litConstExpr

```cangjie
public mut prop litConstExpr: LitConstExpr
```

功能：获取或设置 [ConstPattern](ast_package_classes.md#class-constpattern) 节点中的字面量表达式。

类型：[LitConstExpr](ast_package_classes.md#class-litconstexpr)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ConstPattern](ast_package_classes.md#class-constpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ConstPattern 对象
    let constPattern = ConstPattern()

    // 设置 ConstPattern 的属性
    constPattern.litConstExpr = LitConstExpr(quote(1))

    println("constPattern.toTokens(): ${constPattern.toTokens()}")
}
```

运行结果：

```text
constPattern.toTokens(): 1
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ConstPattern](ast_package_classes.md#class-constpattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ConstPattern](ast_package_classes.md#class-constpattern) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ConstPattern](ast_package_classes.md#class-constpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ConstPattern 对象
    let constPattern = ConstPattern(quote(42))

    // 输出转换后的 Tokens
    println("constPattern.toTokens(): ${constPattern.toTokens()}")
}
```

运行结果：

```text
constPattern.toTokens(): 42
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ConstPattern 对象
    let constPattern = ConstPattern()

    // 设置 ConstPattern 的属性
    constPattern.litConstExpr = LitConstExpr(quote(3.14))

    // 转化为 Tokens 并输出
    println("constPattern.toTokens(): ${constPattern.toTokens()}")
}
```

运行结果：

```text
constPattern.toTokens(): 3.14
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ConstPattern) {
        println("Visiting ConstPattern")
    }
}

main(): Unit {
    // 从 Tokens 创建 ConstPattern 对象
    let constPattern = ConstPattern(quote(100))

    // 使用自定义访问器遍历ConstPattern节点
    constPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ConstPattern
```

## class Constructor

```cangjie
public class Constructor <: Node {
    public init()
}
```

功能：表示 `enum` 类型中的 [Constructor](ast_package_classes.md#class-constructor) 节点。

一个 [Constructor](ast_package_classes.md#class-constructor) 节点：enum TimeUnit { Year | Month([Float32](../../core/core_package_api/core_package_intrinsics.md#float32), [Float32](../../core/core_package_api/core_package_intrinsics.md#float32))} 中的 Year 和 Month([Float32](../../core/core_package_api/core_package_intrinsics.md#float32), [Float32](../../core/core_package_api/core_package_intrinsics.md#float32))。

> **说明：**
>
> [Constructor](ast_package_classes.md#class-constructor) 可以没有参数，也可以有一组不同类型的参数。

父类型：

- [Node](#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

功能：获取或设置作用于 [Constructor](ast_package_classes.md#class-constructor) 节点的注解列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [Constructor](ast_package_classes.md#class-constructor) 的标识符词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [Constructor](ast_package_classes.md#class-constructor) 节点中的 "(" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [Constructor](ast_package_classes.md#class-constructor) 节点中的 ")" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

功能：获取或设置 [Constructor](ast_package_classes.md#class-constructor) 节点可选的参数类型节点的集合。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Constructor](ast_package_classes.md#class-constructor) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Constructor 对象
    let constructor = Constructor()

    // 设置 Constructor 的属性
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Con")

    // 转化为 Tokens 并输出
    println("constructor.toTokens(): ${constructor.toTokens()}")
}
```

运行结果：

```text
constructor.toTokens(): Con
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Constructor 对象
    let constructor = Constructor()

    // 设置 Constructor 的属性
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Year")

    // 转化为 Tokens 并输出
    println("constructor.toTokens(): ${constructor.toTokens()}")
}
```

运行结果：

```text
constructor.toTokens(): Year
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Constructor) {
        println("Visiting Constructor")
    }
}

main(): Unit {
    // 构造一个默认的 Constructor 对象
    let constructor = Constructor()

    // 设置 Constructor 的属性
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Month")

    // 使用自定义访问器遍历 Constructor 节点
    constructor.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Constructor
```

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

功能：所有声明节点的父类，继承自 [Node](ast_package_classes.md#class-node) 节点，提供了所有声明节点的通用接口。

> **说明：**
>
> 类定义、接口定义、函数定义、变量定义、枚举定义、结构体定义、扩展定义、类型别名定义、宏定义等都属于 [Decl](ast_package_classes.md#class-decl) 节点。

父类型：

- [Node](#class-node)

### var annotations_

```cangjie
protected var annotations_: ArrayList<Annotation> = ArrayList<Annotation>()
```

功能：获取或设置作用于 [Decl](ast_package_classes.md#class-decl) 节点的注解列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### var identifier_

```cangjie
protected var identifier_: Token = Token()
```

功能：获取或设置声明节点的标识符，如 `class foo {}` 中的 `foo`。

类型：[Token](ast_package_structs.md#struct-token)

### var keyword_

```cangjie
protected var keyword_: Token = Token()
```

功能：获取或设置声明节点的关键字。

类型：[Token](ast_package_structs.md#struct-token)

### var modifiers_

```cangjie
protected var modifiers_: ArrayList<Modifier> = ArrayList<Modifier>()
```

功能：获取或设置节点的修饰符列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Modifier](ast_package_classes.md#class-modifier)>

### var node

```cangjie
protected var node: Node = Expr()
```

功能：获取或设置[Decl](ast_package_classes.md#class-decl) 节点的形参节点。

类型：[Node](ast_package_classes.md#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

功能：获取或设置作用于 [Decl](ast_package_classes.md#class-decl) 节点的注解列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop constraintCommas

```cangjie
public mut prop constraintCommas: Tokens
```

功能：获取或设置 [Decl](ast_package_classes.md#class-decl) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop genericConstraint

```cangjie
public mut prop genericConstraint: ArrayList<GenericConstraint>
```

功能：获取或设置声明节点的泛型约束，可能为空，如 `func foo<T>() where T <: Comparable<T> {}` 中的 `where T <: Comparable<T>`。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[GenericConstraint](ast_package_classes.md#class-genericconstraint)>

### prop genericParam

```cangjie
public mut prop genericParam: GenericParam
```

功能：获取或设置形参列表，类型形参列表由 `<>` 括起，多个类型形参之间用逗号分隔。

类型：[GenericParam](ast_package_classes.md#class-genericparam)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当节点未定义类型形参列表时，抛出异常。

### prop identifier

```cangjie
public mut open prop identifier: Token
```

功能：获取或设置声明节点的标识符，如 `class foo {}` 中的 `foo`。

类型：[Token](ast_package_structs.md#struct-token)

### prop isGenericDecl

```cangjie
public mut prop isGenericDecl: Bool
```

功能：判断是否是一个泛型节点。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是一个泛型节点为 true；反之为 false。

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置声明节点的关键字。

类型：[Token](ast_package_structs.md#struct-token)

### prop modifiers

```cangjie
public mut prop modifiers: ArrayList<Modifier>
```

功能：获取或设置节点的修饰符列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Modifier](ast_package_classes.md#class-modifier)>

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

功能：将当前语法树节点转化为树形结构的形态并进行打印。语法树节点的树形结构将按照以下形式进行输出：

- `-` 字符串：表示当前节点的公共属性， 如 `-keyword` , `-identifier`。
- 节点属性后紧跟该节点的具体类型， 如 `-declType: PrimitiveType` 表示节点类型是一个 [PrimitiveType](ast_package_classes.md#class-primitivetype) 节点。
- 每个类型使用大括号表示类型的作用区间。

语法树输出的详细格式请参见[语法树节点打印](../ast_samples/dump.md)。

参数：

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 格式化输出的缩进空格数量。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 格式化输出内容。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 在子类中调用
extend FuncDecl {
    public func myDump() {
        dump(1)
    }
}

main(): Unit {
    // 创建 Decl 的子类
    let decl = FuncDecl(quote(func foo() {}))

    println("decl.myDump(): ${decl.myDump()}")
}
```

运行结果：

```text
decl.myDump(): FuncDecl {
    -keyword: Token {
      value: "func"
      kind: FUNC
      pos: 12: 31
    }
    -identifier: Token {
      value: "foo"
      kind: IDENTIFIER
      pos: 12: 36
    }
    -block: Block {
    }
  }
```

### func getAttrs()

```cangjie
public func getAttrs(): Tokens
```

功能：获取当前节点的属性（一般通过内置的 `Attribute` 来设置某个声明设置属性值）。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 当前节点的属性。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Decl 节点
    let decl = ClassDecl(quote(@Attribute[attr1, attr2] class A {}))

    // 获取 Decl 节点属性值
    println("decl.getAttrs(): ${decl.getAttrs()}")
}
```

运行结果：

```text
decl.getAttrs(): attr1 attr2
```

### func hasAttr(String)

```cangjie
public func hasAttr(attr: String): Bool
```

功能：判断当前节点是否具有某个属性（一般通过内置的 `Attribute` 来设置某个声明的属性值）。

参数：

- attr: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 将要判断是否存在于该节点的属性。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 当前节点具有该属性时，返回 true；反之，返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Decl 节点
    let decl = ClassDecl(quote(@Attribute[attr1, attr2] class A {}))

    // 判断 Decl 节点是否有对应属性值
    println("decl.hasAttr(\"attr1\"): ${decl.hasAttr("attr1")}")
    println("decl.hasAttr(\"attr2\"): ${decl.hasAttr("attr2")}")
    println("decl.hasAttr(\"attr3\"): ${decl.hasAttr("attr3")}")
}
```

运行结果：

```text
decl.hasAttr("attr1"): true
decl.hasAttr("attr2"): true
decl.hasAttr("attr3"): false
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 创建 Decl 节点
    let decl = ClassDecl(quote(class A {}))

    // 转化为 Tokens 并输出
    println("decl.toTokens(): ${decl.toTokens()}")
}
```

运行结果：

```text
decl.toTokens(): class A {
}
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Decl) {
        breakTraverse()
        println("Visiting Decl")
    }
}

main(): Unit {
    // 创建 Decl 节点（以 ClassDecl 为例）
    let decl = ClassDecl(quote(class A {}))

    // 使用自定义访问器遍历 Decl 节点
    decl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Decl
```

## class DoWhileExpr

```cangjie
public class DoWhileExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `do-while` 表达式。

父类型：

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 中的块表达式。

类型：[Block](ast_package_classes.md#class-block)

### prop condition

```cangjie
public mut prop condition: Expr
```

功能：获取或设置关键字 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 中的条件表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keywordD

```cangjie
public mut prop keywordD: Token
```

功能：获取或设置 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 节点中 `do` 关键字，其中 keywordD 中的 D 为关键字 `do` 的首字母大写，代表关键字 `do` 。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `do` 关键字时，抛出异常。

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

功能：获取或设置 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 节点中 `while` 关键字，其中 keywordW 中的 W 为关键字 `while` 的首字母大写，代表关键字 `while` 。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `while` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 中 `while` 关键字之后的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 中 `while` 关键字之后的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 DoWhileExpr 对象
    let doWhileExpr = DoWhileExpr()

    // 设置 DoWhileExpr 的属性
    doWhileExpr.keywordD = Token(TokenKind.DO, "do")
    doWhileExpr.keywordW = Token(TokenKind.WHILE, "while")
    doWhileExpr.lParen = Token(TokenKind.LPAREN, "(")
    doWhileExpr.rParen = Token(TokenKind.RPAREN, ")")
    doWhileExpr.condition = RefExpr(quote(flag))
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")
    doWhileExpr.block = block

    // 转化为 Tokens 并输出
    println("doWhileExpr.toTokens(): ${doWhileExpr.toTokens()}")
}
```

运行结果：

```text
doWhileExpr.toTokens(): do {
}
while(flag)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 DoWhileExpr 对象
    let doWhileExpr = DoWhileExpr(quote(do {} while (true)))

    // 转化为 Tokens 并输出
    println("doWhileExpr.toTokens(): ${doWhileExpr.toTokens()}")
}
```

运行结果：

```text
doWhileExpr.toTokens(): do {
}
while(true)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 DoWhileExpr 对象
    let doWhileExpr = DoWhileExpr()

    // 设置 DoWhileExpr 的属性
    doWhileExpr.keywordD = Token(TokenKind.DO, "do")
    doWhileExpr.keywordW = Token(TokenKind.WHILE, "while")
    doWhileExpr.lParen = Token(TokenKind.LPAREN, "(")
    doWhileExpr.rParen = Token(TokenKind.RPAREN, ")")
    doWhileExpr.condition = RefExpr(quote(flag))
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")
    doWhileExpr.block = block

    // 转化为 Tokens 并输出
    println("doWhileExpr.toTokens(): ${doWhileExpr.toTokens()}")
}
```

运行结果：

```text
doWhileExpr.toTokens(): do {
}
while(flag)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: DoWhileExpr) {
        println("Visiting DoWhileExpr")
    }
}

main(): Unit {
    let doWhileExpr = DoWhileExpr(quote(do {} while (false)))

    // 使用自定义访问器遍历 DoWhileExpr 节点
    doWhileExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting DoWhileExpr
```

## class EnumDecl

```cangjie
public class EnumDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个 `Enum` 定义节点。

Enum 的定义使用 `enum` 关键字，定义依次为：可缺省的修饰符、enum 关键字、enum 名、可选的类型参数、是否指定父接口、可选的泛型约束、enum 体的定义。

父类型：

- [Decl](#class-decl)

### prop constructors

```cangjie
public mut prop constructors: ArrayList<Constructor>
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点内 constructor 的成员。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Constructor](ast_package_classes.md#class-constructor)>

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点内除 constructor 的其他成员。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop ellipsis

```cangjie
public mut prop ellipsis: Token
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点中可选的 `...` 词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元类型。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `...` 词法单元时，抛出异常。

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点的 `{` 词法单元类型。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `{` 词法单元类型时，抛出异常。

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点的 `}` 词法单元类型。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `}` 词法单元类型时，抛出异常。

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点的父接口声明中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

功能：获取或设置 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点的父接口。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 `<:` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [EnumDecl](ast_package_classes.md#class-enumdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 EnumDecl 对象
    let enumDecl = EnumDecl()

    // 设置 EnumDecl 的属性
    enumDecl.keyword = Token(TokenKind.ENUM, "enum")
    enumDecl.identifier = Token(TokenKind.IDENTIFIER, "status")
    let constructor = Constructor()
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Active")
    enumDecl.constructors.add(constructor)
    enumDecl.lBrace = Token(TokenKind.LCURL, "{")
    enumDecl.rBrace = Token(TokenKind.RCURL, "}")

    // 转化为 Tokens 并输出
    println("enumDecl.toTokens(): ${enumDecl.toTokens()}")
}
```

运行结果：

```text
enumDecl.toTokens(): enum status {
    Active
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [EnumDecl](ast_package_classes.md#class-enumdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [EnumDecl](ast_package_classes.md#class-enumdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [EnumDecl](ast_package_classes.md#class-enumdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 EnumDecl 对象
    let enumDecl = EnumDecl(quote(enum Color { Red | Green | Blue }))

    // 转化为 Tokens 并输出
    println("enumDecl.toTokens(): ${enumDecl.toTokens()}")
}
```

运行结果：

```text
enumDecl.toTokens(): enum Color {
    Red
    | Green
    | Blue
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 EnumDecl 对象
    let enumDecl = EnumDecl()

    // 设置 EnumDecl 的属性
    enumDecl.keyword = Token(TokenKind.ENUM, "enum")
    enumDecl.identifier = Token(TokenKind.IDENTIFIER, "status")
    let constructor = Constructor()
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Active")
    enumDecl.constructors.add(constructor)

    // 创建函数声明
    let funcDecl = FuncDecl(quote(func getValue(): Int64 { 0 }))
    // 将函数声明添加到EnumDecl中
    enumDecl.decls.add(funcDecl)

    // 设置左右花括号
    enumDecl.lBrace = Token(TokenKind.LCURL, "{")
    enumDecl.rBrace = Token(TokenKind.RCURL, "}")

    // 转化为 Tokens 并输出
    println("enumDecl.toTokens(): ${enumDecl.toTokens()}")
}
```

运行结果：

```text
enumDecl.toTokens(): enum status {
    Active
    func getValue(): Int64 {
        0
    }
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: EnumDecl) {
        println("Visiting EnumDecl")
    }
}

main(): Unit {
    let enumDecl = EnumDecl(quote(enum Status { Pending | Completed }))

    // 使用自定义访问器遍历 EnumDecl 节点
    enumDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting EnumDecl
```

## class EnumPattern

```cangjie
public class EnumPattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示 enum 模式节点。

用于匹配 enum 的 `constructor`， 如 `case Year(n) => 1` 中的 `Year(n)`。

父类型：

- [Pattern](#class-pattern)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop constructor

```cangjie
public mut prop constructor: Expr
```

功能：获取或设置 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点中的构造器表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点中的 "(" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

功能：获取或设置 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点中有参构造器内的模式节点列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点中的 ")" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [EnumPattern](ast_package_classes.md#class-enumpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 EnumPattern 对象
    let enumPattern = EnumPattern()

    // 设置 EnumPattern 的属性
    enumPattern.constructor = RefExpr(quote(Status))
    enumPattern.lParen = Token(TokenKind.LPAREN, "(")
    enumPattern.rParen = Token(TokenKind.RPAREN, ")")
    let pattern = WildcardPattern()
    enumPattern.patterns.add(pattern)

    // 转化为 Tokens 并输出
    println("enumPattern.toTokens(): ${enumPattern.toTokens()}")
}
```

运行结果：

```text
enumPattern.toTokens(): Status(_)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [EnumPattern](ast_package_classes.md#class-enumpattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [EnumPattern](ast_package_classes.md#class-enumpattern) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [EnumPattern](ast_package_classes.md#class-enumpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 EnumPattern 对象
    let enumPattern = EnumPattern(quote(Point(x, y)))

    // 转化为 Tokens 并输出
    println("enumPattern.toTokens(): ${enumPattern.toTokens()}")
}
```

运行结果：

```text
enumPattern.toTokens(): Point(x, y)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 EnumPattern 对象
    let enumPattern = EnumPattern()

    // 设置 EnumPattern 的属性
    enumPattern.constructor = RefExpr(quote(Status))
    enumPattern.lParen = Token(TokenKind.LPAREN, "(")
    enumPattern.rParen = Token(TokenKind.RPAREN, ")")

    // 创建模式
    let pattern = WildcardPattern()
    // 将模式添加到 EnumPattern 中
    enumPattern.patterns.add(pattern)

    // 转化为 Tokens 并输出
    println("enumPattern.toTokens(): ${enumPattern.toTokens()}")
}
```

运行结果：

```text
enumPattern.toTokens(): Status(_)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: EnumPattern) {
        println("Visiting EnumPattern")
    }
}

main(): Unit {
    // 从 Tokens 创建 EnumPattern 对象
    let enumPattern = EnumPattern(quote(Error(code)))

    // 使用自定义访问器遍历 EnumPattern 节点
    enumPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting EnumPattern
```

## class ExceptTypePattern

```cangjie
public class ExceptTypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示一个用于异常模式状态下的节点。

例如 `e: Exception1 | Exception2`。

父类型：

- [Pattern](#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 节点中的 ":" 操作符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 操作符时，抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 节点中的模式节点。

类型：[Pattern](ast_package_classes.md#class-pattern)

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

功能：获取或设置 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 节点中有类型列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ExceptTypePattern 对象
    let exceptTypePattern = ExceptTypePattern()

    // 设置 ExceptTypePattern 的属性
    exceptTypePattern.colon = Token(TokenKind.COLON, ":")
    exceptTypePattern.pattern = WildcardPattern()
    let ioExceptionType = RefType(quote(IOException))
    exceptTypePattern.types.add(ioExceptionType)

    // 转化为 Tokens 并输出
    println("exceptTypePattern.toTokens(): ${exceptTypePattern.toTokens()}")
}
```

运行结果：

```text
exceptTypePattern.toTokens(): _: IOException
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ExceptTypePattern 对象
    let exceptTypePattern = ExceptTypePattern(quote(e: IOException))

    // 转化为 Tokens 并输出
    println("exceptTypePattern.toTokens(): ${exceptTypePattern.toTokens()}")
}
```

运行结果：

```text
exceptTypePattern.toTokens(): e: IOException
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 ExceptTypePattern 对象
    let exceptTypePattern = ExceptTypePattern()

    // 设置 ExceptTypePattern 的属性
    exceptTypePattern.colon = Token(TokenKind.COLON, ":")
    exceptTypePattern.pattern = WildcardPattern()

    // 创建第一个类型
    let ioExceptionType = RefType(quote(IOException))
    // 创建第二个类型
    let fileExceptionType = RefType(quote(FileException))

    // 将类型添加到 ExceptTypePattern 中
    exceptTypePattern.types.add(ioExceptionType)
    exceptTypePattern.types.add(fileExceptionType)

    // 转化为 Tokens 并输出
    println("exceptTypePattern.toTokens(): ${exceptTypePattern.toTokens()}")
}
```

运行结果：

```text
exceptTypePattern.toTokens(): _: IOException | FileException
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ExceptTypePattern) {
        println("Visiting ExceptTypePattern")
    }
}

main(): Unit {
    // 从 Tokens 创建 ExceptTypePattern 对象
    let exceptTypePattern = ExceptTypePattern(quote(err: RuntimeException))

    // 使用自定义访问器遍历 ExceptTypePattern 节点
    exceptTypePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ExceptTypePattern
```

## class Expr

```cangjie
public open class Expr <: Node {}
```

功能：所有表达式节点的父类，继承自 [Node](ast_package_classes.md#class-node) 节点。

表达式节点的 `toTokens` 方法会根据操作符优先级添加括号，例如已有一个 [BinaryExpr](ast_package_classes.md#class-binaryexpr) 节点 a \* b, 用户将左表达式内容 a 修改为 a + 1，修改后 `toTokens` 方法会为左表达式添加括号，`toTokens` 输出为 (a + 1) \* b。

父类型：

- [Node](#class-node)

### func dump(UInt16)

```cangjie
protected open func dump(_: UInt16): String
```

功能：将当前语法树节点转化为树形结构的形态并进行打印，需要被子类重写。

参数：

- _: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 格式化输出的缩进空格数量。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 格式化输出内容。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 在子类中调用
extend BinaryExpr {
    public func myDump() {
        dump(1)
    }
}

main(): Unit {
    // 创建 Expr 的子类
    let expr = BinaryExpr(quote(1 + 1))

    println("expr.myDump(): ${expr.myDump()}")
}
```

运行结果：

```text
expr.myDump(): BinaryExpr {
    -leftExpr: LitConstExpr {
      -literal: Token {
        value: "1"
        kind: INTEGER_LITERAL
        pos: 12: 33
      }
    }
    -op: Token {
      value: "+"
      kind: ADD
      pos: 12: 35
    }
    -rightExpr: LitConstExpr {
      -literal: Token {
        value: "1"
        kind: INTEGER_LITERAL
        pos: 12: 37
      }
    }
  }
```

### func precedence()

```cangjie
protected open func precedence(): Int64
```

功能：返回当前表达式节点的优先级。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 当前表达式节点的优先级。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 在子类中调用
extend BinaryExpr {
    public func myPrecedence(): Int64 {
        precedence()
    }
}

main(): Unit {
    // 创建 Expr 的子类
    let binaryExpr1 = BinaryExpr(quote(1 + 1))
    let binaryExpr2 = BinaryExpr()
    binaryExpr2.leftExpr = binaryExpr1
    binaryExpr2.op = Token(TokenKind.MUL, "*")
    binaryExpr2.rightExpr = LitConstExpr(quote(5))

    // 输出内外 Expr 的优先级
    println("binaryExpr1.myPrecedence(): ${binaryExpr1.myPrecedence()}")
    println("binaryExpr2.myPrecedence(): ${binaryExpr2.myPrecedence()}")

    // 由于内层 Expr 低于外层，自动添加了括号
    println("binaryExpr2.toTokens(): ${binaryExpr2.toTokens()}")
}
```

运行结果：

```text
binaryExpr1.myPrecedence(): 12
binaryExpr2.myPrecedence(): 13
binaryExpr2.toTokens(): (1 + 1) * 5
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Expr 节点
    let expr = BinaryExpr(quote(1 + 1))

    // 转化为 Tokens 并输出
    println("expr.toTokens(): ${expr.toTokens()}")
}
```

运行结果：

```text
expr.toTokens(): 1 + 1
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Expr) {
        breakTraverse()
        println("Visiting Expr")
    }
}

main(): Unit {
    // 创建 Expr 节点（以 BinaryExpr 为例）
    let expr = BinaryExpr(quote(1 + 1))

    // 使用自定义访问器遍历 Expr 节点
    expr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Expr
```

## class ExtendDecl

```cangjie
public class ExtendDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个扩展定义节点。

扩展的定义使用 `extend` 关键字，扩展定义依次为：extend 关键字、扩展类型、是否指定父接口、可选的泛型约束、扩展体的定义。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

功能：获取或设置 [ExtendDecl](ast_package_classes.md#class-extenddecl) 节点的类体。

类型：[Body](ast_package_classes.md#class-body)

### prop extendType

```cangjie
public mut prop extendType: TypeNode
```

功能：获取或设置被扩展的类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop identifier

```cangjie
public mut override prop identifier: Token
```

功能：[ExtendDecl](ast_package_classes.md#class-extenddecl) 节点继承 [Decl](ast_package_classes.md#class-decl) 节点，但是不支持 `identifier` 属性，使用时会抛出异常。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当使用 `identifier` 属性时，抛出异常。

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

功能：获取或设置 [ExtendDecl](ast_package_classes.md#class-extenddecl) 节点的父接口声明中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

功能：获取或设置 [ExtendDecl](ast_package_classes.md#class-extenddecl) 节点的父接口。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 `<:` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ExtendDecl](ast_package_classes.md#class-extenddecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ExtendDecl 对象
    let extendDecl = ExtendDecl()

    // 设置 ExtendDecl 的属性
    extendDecl.extendType = RefType(quote(B))

    let body = Body()
    let funcDecl = FuncDecl(quote(func bar() { println("Hello from bar") }))
    body.decls.add(funcDecl)
    extendDecl.body = body

    // 转化为 Tokens 并输出
    println("extendDecl.toTokens(): ${extendDecl.toTokens()}")
}
```

运行结果：

```text
extendDecl.toTokens(): B {
    func bar() {
        println("Hello from bar")
    }
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ExtendDecl](ast_package_classes.md#class-extenddecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ExtendDecl](ast_package_classes.md#class-extenddecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ExtendDecl](ast_package_classes.md#class-extenddecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ExtendDecl 对象
    let extendDecl = ExtendDecl(quote(extend A { func foo() {} }))

    // 转化为 Tokens 并输出
    println("extendDecl.toTokens(): ${extendDecl.toTokens()}")
}
```

运行结果：

```text
extendDecl.toTokens(): extend A {
    func foo() {
    }
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ExtendDecl 对象
    let extendDecl = ExtendDecl()

    // 设置 ExtendDecl 的属性
    extendDecl.extendType = RefType(quote(B))

    let body = Body()
    let funcDecl = FuncDecl(quote(func bar() { println("Hello from bar") }))
    body.decls.add(funcDecl)
    extendDecl.body = body

    // 转化为 Tokens 并输出
    println("extendDecl.toTokens(): ${extendDecl.toTokens()}")
}
```

运行结果：

```text
extendDecl.toTokens(): B {
    func bar() {
        println("Hello from bar")
    }
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ExtendDecl) {
        println("Visiting ExtendDecl")
    }
}

main(): Unit {
    // 从 Tokens 创建 ExtendDecl 对象
    let extendDecl = ExtendDecl(quote(extend A { func foo() {} }))

    // 使用自定义访问器遍历 ExtendDecl 节点
    extendDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ExtendDecl
```

## class FeatureId

```cangjie
public class FeatureId <: Node {
    public init()
}
```

功能：表示一个 feature id。

> **注意:**
>
> Feature 声明必须以 `features`，其次是 feature id 列表，Feature 声明必须出现在源文件的包名声明之前。
> feature id 由标识符组成，标识符之间用点号分隔。feature id 不能用反引号转义。

父类型:

- [Node](#class-node)

### prop dots

```cangjie
public mut prop dots: Tokens
```

功能：获取或设置 feature 的点号。例如：`features user.define.sample`。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是一组 `.`。

### prop identifiers

```cangjie
public mut prop identifiers: Tokens
```

功能：获取或设置 [FeatureId](ast_package_classes.md#class-featureid) 节点的标识符。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是一组标识符。

### init()

```cangjie
public init()
```

功能：构造一个 [FeatureId](ast_package_classes.md#class-featureid) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FeatureId 对象
    let featureId = FeatureId()

    // 设置 FeatureId 的属性
    featureId.identifiers = quote(ftr)

    // 转化为 Tokens 并输出
    println("featureId.toTokens(): ${featureId.toTokens()}")
}
```

运行结果：

```text
featureId.toTokens(): ftr
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：转换当前的抽象语法树节点为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换出来的 [Tokens](ast_package_classes.md#class-tokens) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FeatureId 对象
    let featureId = FeatureId()

    // 设置 FeatureId 的属性
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)

    // 转化为 Tokens 并输出
    println("featureId.toTokens(): ${featureId.toTokens()}")
}
```

运行结果：

```text
featureId.toTokens(): a.b.c
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。要提前终止子节点遍历，请重写 `visit` 函数并调用 `breakTraverse` 函数来终止遍历行为。参见 [自定义访问函数遍历 AST 对象](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - 一个 [Visitor](ast_package_classes.md#class-visitor) 类型实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeatureId) {
        println("Visiting FeatureId")
    }
}

main(): Unit {
    // 构造一个默认的 FeatureId 对象
    let featureId = FeatureId()

    // 设置 FeatureId 的属性
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)

    // 使用自定义访问器遍历 FeatureId 节点
    featureId.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeatureId
```

## class FeaturesDirective

```cangjie
public class FeaturesDirective <: Node {
    public init(inputs: Tokens)
    public init()
}
```

功能：feature directive 节点对象。

> **注意：**
>
> Features 声明必须以关键字 `features` 开头，后跟 [features set](#class-featuresset)，并且必须出现在源文件的包头之前。

父类型：

- [Node](#class-node)

### prop annotations

```cangjie
public mut prop annotations: ArrayList<Annotation>
```

功能：获取或设置在 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 上的注解。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Annotation](ast_package_classes.md#class-annotation)>

### prop featuresSet

```cangjie
public mut prop featuresSet: FeaturesSet
```

功能：获取或设置 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 节点里的 features 名称。

类型：[FeaturesSet](ast_package_classes.md#class-featuresset)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 节点里的 `features` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 在配置的不是关键字时抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FeaturesDirective 对象
    let featuresDirective = FeaturesDirective()

    // 设置 FeaturesDirective 的属性
    featuresDirective.keyword = Token(TokenKind.FEATURES, "features")
    let featuresSet = FeaturesSet()
    let featureId = FeatureId()
    featureId.identifiers = quote(ftr)
    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")
    featuresDirective.featuresSet = featuresSet

    // 转化为 Tokens 并输出
    println("featuresDirective.toTokens(): ${featuresDirective.toTokens()}")
}
```

运行结果：

```text
featuresDirective.toTokens(): features { ftr }
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 用于构造 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 节点的词法单元集合。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 无法构造 [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 的时候抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 用 Tokens 创建一个 FeaturesDirective 对象
    let featuresDirective = FeaturesDirective(quote(features {a, b.c}))

    // 转化为 Tokens 并输出
    println("featuresDirective.toTokens(): ${featuresDirective.toTokens()}")
}
```

运行结果：

```text
featuresDirective.toTokens(): features { a, b.c }
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：转换一个语法树节点为 [Tokens](ast_package_classes.md#class-tokens)。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换好的 [Tokens](ast_package_classes.md#class-tokens) 类型对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FeaturesDirective 对象
    let featuresDirective = FeaturesDirective()

    // 设置 FeaturesDirective 的属性
    featuresDirective.keyword = Token(TokenKind.FEATURES, "features")
    let featuresSet = FeaturesSet()
    let featureId = FeatureId()
    featureId.identifiers = quote(ftr)
    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")
    featuresDirective.featuresSet = featuresSet

    // 转化为 Tokens 并输出
    println("featuresDirective.toTokens(): ${featuresDirective.toTokens()}")
}
```

运行结果：

```text
featuresDirective.toTokens(): features { ftr }
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。要提前终止子节点遍历，请重写 `visit` 函数并调用 `breakTraverse` 函数来终止遍历行为。参见 [自定义访问函数遍历 AST 对象](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - 一个 [Visitor](ast_package_classes.md#class-visitor) 类型实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeaturesDirective) {
        println("Visiting FeaturesDirective")
    }
}

main(): Unit {
    // 用 Tokens 创建一个 FeaturesDirective 对象
    let featuresDirective = FeaturesDirective(quote(features {a, b.c}))

    // 使用自定义访问器遍历 FeaturesDirective 节点
    featuresDirective.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeaturesDirective
```

## class FeaturesSet

```cangjie
public class FeaturesSet <: Node {
    public init()
}
```

功能：一组 features 名称。

> **注意：**
>
> featuresSet 必须开被 `{}` 包裹。featuresSet 包含一组 [featureId](ast_package_classes.md#class-featureid)。

父类型：

- [Node](#class-node)

### prop commas

```cangjie
public mut prop commas: Tokens 
```

功能：获取或设置在 [FeaturesSet](ast_package_classes.md#class-featuresset) 节点里的一组 `,`。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当配置的不是一组 `,` 时抛出异常。

### prop content

```cangjie
public mut prop content: ArrayList<FeatureId> 
```

功能：获取或设置在 [FeaturesSet](ast_package_classes.md#class-featuresset) 节点里的一组 feature id。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[featuresId](ast_package_classes.md#class-featureid)>

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当配置的不是一组 feature id 时抛出异常。

### prop lCurl

```cangjie
public mut prop lCurl: Token
```

功能：获取或设置在 [FeaturesSet](ast_package_classes.md#class-featuresset) 节点里的 `{` 。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当配置的不是 `{` 时抛出异常。

### prop rCurl

```cangjie
public mut prop rCurl: Token
```

功能：获取或设置在 [FeaturesSet](ast_package_classes.md#class-featuresset) 节点里的 `}` 。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当配置的不是 `}` 时抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [FeaturesSet](ast_package_classes.md#class-featuresset) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FeaturesSet 对象
    let featuresSet = FeaturesSet()

    // 设置 FeaturesSet 的属性
    let featureId = FeatureId()
    featureId.identifiers = quote(ftr)

    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")

    // 转化为 Tokens 并输出
    println("featuresSet.toTokens(): ${featuresSet.toTokens()}")
}
```

运行结果：

```text
featuresSet.toTokens(): { ftr }
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：转换一个语法树节点为 [Tokens](ast_package_classes.md#class-tokens)。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换好的 [Tokens](ast_package_classes.md#class-tokens) 类型对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FeaturesSet 对象
    let featuresSet = FeaturesSet()

    // 设置 FeaturesSet 的属性
    let featureId = FeatureId()
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)

    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")

    // 转化为 Tokens 并输出
    println("featuresSet.toTokens(): ${featuresSet.toTokens()}")
}
```

运行结果：

```text
featuresSet.toTokens(): { a.b.c }
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。要提前终止子节点遍历，请重写 `visit` 函数并调用 `breakTraverse` 函数来终止遍历行为。参见 [自定义访问函数遍历 AST 对象](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - 一个 [Visitor](ast_package_classes.md#class-visitor) 类型实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeaturesSet) {
        println("Visiting FeaturesSet")
    }
}

main(): Unit {
    // 构造一个默认的 FeaturesSet 对象
    let featuresSet = FeaturesSet()

    // 设置 FeaturesSet 的属性
    let featureId = FeatureId()
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)
    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 FeaturesSet 节点
    featuresSet.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeaturesSet
```

## class ForInExpr

```cangjie
public class ForInExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `for-in` 表达式。

[ForInExpr](ast_package_classes.md#class-forinexpr) 类型中，关键字 `for` 之后是 [Pattern](ast_package_classes.md#class-pattern), 此后是一个 `in` 关键字和表达式节点，最后是一个执行循环体 [Block](ast_package_classes.md#class-block)。

父类型：

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的循环体。

类型：[Block](ast_package_classes.md#class-block)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keywordF

```cangjie
public mut prop keywordF: Token
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的关键字 `for`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `for` 关键字时，抛出异常。

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的关键字 `in`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `in` 关键字时，抛出异常。

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的关键字 `where`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `where` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中关键字 `for` 后的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的 [Pattern](ast_package_classes.md#class-pattern) 节点。

类型：[Pattern](ast_package_classes.md#class-pattern)

### prop patternGuard

```cangjie
public mut prop patternGuard: Expr
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的 `patternGuard` 条件表达式。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [ForInExpr](ast_package_classes.md#class-forinexpr) 节点中不存在 `patternGuard` 表达式时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [ForInExpr](ast_package_classes.md#class-forinexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ForInExpr](ast_package_classes.md#class-forinexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ForInExpr 对象
    let forInExpr = ForInExpr()

    // 设置 ForInExpr 的属性
    forInExpr.keywordF = Token(TokenKind.FOR, "for")
    forInExpr.pattern = VarPattern(Token(TokenKind.IDENTIFIER, "x"))
    forInExpr.keywordI = Token(TokenKind.IN, "in")
    forInExpr.expr = RefExpr(quote(arr))

    // 创建块
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")

    // 添加一个表达式节点
    let expr = CallExpr(quote(foo()))
    block.nodes.add(expr)
    forInExpr.block = block

    // 转化为 Tokens 并输出
    println("forInExpr.toTokens(): ${forInExpr.toTokens()}")
}
```

运行结果：

```text
forInExpr.toTokens(): for(x in arr) {
    foo()
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ForInExpr](ast_package_classes.md#class-forinexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ForInExpr](ast_package_classes.md#class-forinexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ForInExpr](ast_package_classes.md#class-forinexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ForInExpr 对象
    let forInExpr = ForInExpr(quote(for (i in 1..10) { println(i) }))

    // 转化为 Tokens 并输出
    println("forInExpr.toTokens(): ${forInExpr.toTokens()}")
}
```

运行结果：

```text
forInExpr.toTokens(): for(i in 1 .. 10) {
    println(i)
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ForInExpr 对象
    let forInExpr = ForInExpr()

    // 设置 ForInExpr 的属性
    forInExpr.keywordF = Token(TokenKind.FOR, "for")
    forInExpr.pattern = VarPattern(Token(TokenKind.IDENTIFIER, "x"))
    forInExpr.keywordI = Token(TokenKind.IN, "in")
    forInExpr.expr = RefExpr(quote(arr))

    // 创建块
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")

    // 添加一个表达式节点
    let expr = CallExpr(quote(foo()))
    block.nodes.add(expr)
    forInExpr.block = block

    // 转化为 Tokens 并输出
    println("forInExpr.toTokens(): ${forInExpr.toTokens()}")
}
```

运行结果：

```text
forInExpr.toTokens(): for(x in arr) {
    foo()
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ForInExpr) {
        println("Visiting ForInExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 ForInExpr 对象
    let forInExpr = ForInExpr(quote(for (i in 1..10) { println(i) }))

    // 使用自定义访问器遍历 ForInExpr 节点
    forInExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ForInExpr
```

## class FuncDecl

```cangjie
public class FuncDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个函数定义节点。

由可选的函数修饰符，关键字 `func` ，函数名，可选的类型形参列表，函数参数，可缺省的函数返回类型来定义一个函数，函数定义时必须有函数体，函数体是一个块。

父类型：

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的函数体。

类型：[Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的冒号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是冒号时，抛出异常。

### prop declType

```cangjie
public mut prop declType: TypeNode
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的函数返回类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的函数返回类型是一个缺省值时，抛出异常。

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的函数参数。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop overloadOp

```cangjie
public mut prop overloadOp: Tokens
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的重载操作符。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [FuncDecl](ast_package_classes.md#class-funcdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FuncDecl 对象
    let funcDecl = FuncDecl()

    // 设置 FuncDecl 的属性
    funcDecl.keyword = Token(TokenKind.FUNC, "func")
    funcDecl.identifier = Token(TokenKind.IDENTIFIER, "foo")
    funcDecl.lParen = Token(TokenKind.LPAREN, "(")
    funcDecl.rParen = Token(TokenKind.RPAREN, ")")

    // 创建函数体
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")
    funcDecl.block = block

    // 转化为 Tokens 并输出
    println("funcDecl.toTokens(): ${funcDecl.toTokens()}")
}
```

运行结果：

```text
funcDecl.toTokens(): func foo() {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [FuncDecl](ast_package_classes.md#class-funcdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [FuncDecl](ast_package_classes.md#class-funcdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [FuncDecl](ast_package_classes.md#class-funcdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 FuncDecl 对象
    let funcDecl = FuncDecl(quote(func add(a: Int64, b: Int64): Int64 { return a + b }))

    // 转化为 Tokens 并输出
    println("funcDecl.toTokens(): ${funcDecl.toTokens()}")
}
```

运行结果：

```text
funcDecl.toTokens(): func add(a: Int64, b: Int64): Int64 {
    return a + b
}
```

### func isConst()

```cangjie
public func isConst(): Bool
```

功能：判断是否是一个 `Const` 类型的节点。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是一个 `Const` 类型的节点返回 true；反之，返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let funcDecl1 = FuncDecl(quote(func foo() { println("Hello") }))
    let funcDecl2 = FuncDecl(quote(const func bar() { println("World") }))

    println("funcDecl1.isConst(): ${funcDecl1.isConst()}")
    println("funcDecl2.isConst(): ${funcDecl2.isConst()}")
}
```

运行结果：

```text
funcDecl1.isConst(): false
funcDecl2.isConst(): true
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FuncDecl 对象
    let funcDecl = FuncDecl()

    // 设置 FuncDecl 的属性
    funcDecl.keyword = Token(TokenKind.FUNC, "func")
    funcDecl.identifier = Token(TokenKind.IDENTIFIER, "foo")
    funcDecl.lParen = Token(TokenKind.LPAREN, "(")
    funcDecl.rParen = Token(TokenKind.RPAREN, ")")
    funcDecl.colon = Token(TokenKind.COLON, ":")
    funcDecl.declType = PrimitiveType(quote(Int64))

    // 创建函数参数
    let param = FuncParam(quote(x: Int64))

    funcDecl.funcParams = ArrayList<FuncParam>([param])

    // 创建函数体
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")
    let expr = BinaryExpr(quote(x + 1))
    block.nodes.add(expr)
    funcDecl.block = block

    // 转化为 Tokens 并输出
    println("funcDecl.toTokens(): ${funcDecl.toTokens()}")
}
```

运行结果：

```text
funcDecl.toTokens(): func foo(x: Int64): Int64 {
    x + 1
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncDecl) {
        println("Visiting FuncDecl")
    }
}

main(): Unit {
    // 从 Tokens 创建 FuncDecl 对象
    let funcDecl = FuncDecl(quote(func foo() { println("Hello") }))

    // 使用自定义访问器遍历 FuncDecl 节点
    funcDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncDecl
```

## class FuncParam

```cangjie
public open class FuncParam <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示函数参数节点，包括非命名参数和命名参数。

一个 [FuncParam](ast_package_classes.md#class-funcparam) 节点： `func foo(a: Int64, b: Float64) {...}` 中的 `a: Int64` 和 `b: Float64`。

父类型：

- [Decl](#class-decl)

### prop assign

```cangjie
public mut prop assign: Token
```

功能：获取或设置具有默认值的函数参数中的 `=`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `=` 时，抛出异常。

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置置形参中的 ":"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 时，抛出异常。

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置具有默认值的函数参数的变量初始化节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当函数参数没有进行初始化时，抛出异常。

### prop not

```cangjie
public mut prop not: Token
```

功能：获取或设置命名形参中的 `!`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `!` 时，抛出异常。

### prop paramType

```cangjie
public mut prop paramType: TypeNode
```

功能：获取或设置函数参数的类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [FuncParam](ast_package_classes.md#class-funcparam) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FuncParam 对象
    let funcParam = FuncParam()

    // 设置 FuncParam 的属性
    funcParam.identifier = Token(TokenKind.IDENTIFIER, "b")
    funcParam.colon = Token(TokenKind.COLON, ":")
    funcParam.paramType = PrimitiveType(quote(Float32))
    funcParam.assign = Token(TokenKind.ASSIGN, "=")
    funcParam.expr = RefExpr(quote(defaultValue))

    // 转化为 Tokens 并输出
    println("funcParam.toTokens(): ${funcParam.toTokens()}")
}
```

运行结果：

```text
funcParam.toTokens(): b: Float32 = defaultValue
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [FuncParam](ast_package_classes.md#class-funcparam) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [FuncParam](ast_package_classes.md#class-funcparam) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [FuncParam](ast_package_classes.md#class-funcparam) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 FuncParam 对象
    let funcParam = FuncParam(quote(a: Int64))

    println("funcParam.toTokens(): ${funcParam.toTokens()}")
}
```

运行结果：

```text
funcParam.toTokens(): a: Int64
```

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

功能：将当前语法树节点转化为树形结构的形态并进行打印。

参数：

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 格式化输出的缩进空格数量。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 格式化输出内容。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 在子类中调用
class MyParam <: FuncParam {
    public init(input: Tokens) {
        super(input)
    }
    public func myDump(): String {
        dump(1)
    }
}

main(): Unit {
    // 创建 FuncParam 的子类
    let param = MyParam(quote(a: Int64))

    println("param.myDump(): ${param.myDump()}")
}
```

运行结果：

```text
param.myDump(): FuncParam {
    -identifier: Token {
      value: "a"
      kind: IDENTIFIER
      pos: 15: 31
    }
    -colon: Token {
      value: ":"
      kind: COLON
      pos: 15: 32
    }
    -paramType: PrimitiveType {
      -keyword: Token {
        value: "Int64"
        kind: INT64
        pos: 15: 34
      }
    }
  }
```

### func isMemberParam()

```cangjie
public func isMemberParam(): Bool
```

功能：当前的函数参数是否是主构造函数中的参数。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 布尔类型，如果是主构造函数中的参数，返回 `true`。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造主构造函数节点
    let decl = PrimaryCtorDecl(quote(MyParam(a: Int64, let v: Int64) {}))

    println("decl.funcParams[0].isMemberParam(): ${decl.funcParams[0].isMemberParam()}")
    println("decl.funcParams[1].isMemberParam(): ${decl.funcParams[1].isMemberParam()}")
}
```

运行结果：

```text
decl.funcParams[0].isMemberParam(): false
decl.funcParams[1].isMemberParam(): true
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FuncParam 对象
    let funcParam = FuncParam()

    // 设置 FuncParam 的属性
    funcParam.identifier = Token(TokenKind.IDENTIFIER, "b")
    funcParam.colon = Token(TokenKind.COLON, ":")
    funcParam.paramType = PrimitiveType(quote(Float32))
    funcParam.assign = Token(TokenKind.ASSIGN, "=")
    funcParam.expr = RefExpr(quote(defaultValue))

    // 转化为 Tokens 并输出
    println("funcParam.toTokens(): ${funcParam.toTokens()}")
}
```

运行结果：

```text
funcParam.toTokens(): b: Float32 = defaultValue
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncParam) {
        println("Visiting FuncParam")
    }
}

main(): Unit {
    // 从 Tokens 创建 FuncParam 对象
    let funcParam = FuncParam(quote(b!: Float64))

    // 使用自定义访问器遍历 FuncParam 节点
    funcParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncParam
```

## class FuncType

```cangjie
public class FuncType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示函数类型节点。

由函数的参数类型和返回类型组成，参数类型与返回类型之间用 `->` 分隔，如：`(Int32) -> Unit`。

父类型：

- [TypeNode](#class-typenode)

### prop arrow

```cangjie
public mut prop arrow: Token
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点参数类型与返回类型之间的 `->`的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `->`的词法单元时，抛出异常。

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点的中的关键字 `CFunc` 的词法单元，若不是一个 `CFunc` 类型，则获取一个 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点的 "(" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop returnType

```cangjie
public mut prop returnType: TypeNode
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 返回类型节点。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点的 ")" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

功能：获取或设置 [FuncType](ast_package_classes.md#class-functype) 节点中函数的参数类型列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [FuncType](ast_package_classes.md#class-functype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 FuncType 对象
    let funcType = FuncType()

    // 设置 FuncType 的属性
    funcType.lParen = Token(TokenKind.LPAREN, "(")
    funcType.rParen = Token(TokenKind.RPAREN, ")")
    funcType.arrow = Token(TokenKind.ARROW, "->")

    // 设置参数类型
    let paramTypes = ArrayList<TypeNode>()
    funcType.types = paramTypes

    // 设置返回类型
    funcType.returnType = RefType(quote(String))

    // 转化为 Tokens 并输出
    println("funcType.toTokens(): ${funcType.toTokens()}")
}
```

运行结果：

```text
funcType.toTokens(): () -> String
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [FuncType](ast_package_classes.md#class-functype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [FuncType](ast_package_classes.md#class-functype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [FuncType](ast_package_classes.md#class-functype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 FuncType 对象
    let funcType = FuncType(quote((Int32, Float64) -> String))

    // 转化为 Tokens 并输出
    println("funcType.toTokens(): ${funcType.toTokens()}")
}
```

运行结果：

```text
funcType.toTokens(): (Int32, Float64) -> String
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 FuncType 对象
    let funcType = FuncType()

    // 设置 FuncType 的属性
    funcType.lParen = Token(TokenKind.LPAREN, "(")
    funcType.rParen = Token(TokenKind.RPAREN, ")")
    funcType.arrow = Token(TokenKind.ARROW, "->")

    // 设置参数类型
    let paramTypes = ArrayList<TypeNode>()
    paramTypes.add(PrimitiveType(quote(Int64)))
    paramTypes.add(PrimitiveType(quote(Bool)))
    funcType.types = paramTypes

    // 设置返回类型
    funcType.returnType = RefType(quote(String))

    // 转化为 Tokens 并输出
    println("funcType.toTokens(): ${funcType.toTokens()}")
}
```

运行结果：

```text
funcType.toTokens(): (Int64, Bool) -> String
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncType) {
        println("Visiting FuncType")
    }
}

main(): Unit {
    // 从 Tokens 创建 FuncType 对象
    let funcType = FuncType(quote((Int32) -> Unit))

    // 使用自定义访问器遍历 FuncType 节点
    funcType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncType
```

## class GenericConstraint

```cangjie
public class GenericConstraint <: Node {
    public init()
}
```

功能：表示一个泛型约束节点。

一个 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点：`interface Enumerable<U> where U <: Bounded {}` 中的 `where U <: Bounded`。

> **说明：**
>
> 通过 `where` 之后的 `<:` 运算符来声明，由一个下界与一个上界来组成。其中 `<:` 左边称为约束的下界，下界只能为类型变元。`<:` 右边称为约束上界，约束上界可以为类型。

父类型：

- [Node](#class-node)

### prop bitAnds

```cangjie
public mut prop bitAnds: Tokens
```

功能：获取或设置 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点中关键字 `where` 词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `where` 关键字时，抛出异常。

### prop typeArgument

```cangjie
public mut prop typeArgument: TypeNode
```

功能：获取或设置 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点中的约束下界。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点中的 `<:` 运算符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 运算符时，抛出异常。

### prop upperBounds

```cangjie
public mut prop upperBounds: ArrayList<TypeNode>
```

功能：获取或设置 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 节点约束上界的 [TypeNode](ast_package_classes.md#class-typenode) 类型节点的集合。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [GenericConstraint](ast_package_classes.md#class-genericconstraint) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 GenericConstraint 对象
    let genericConstraint = GenericConstraint()

    // 设置 GenericConstraint 的属性
    genericConstraint.keyword = Token(TokenKind.WHERE, "where")
    genericConstraint.typeArgument = RefType(quote(U))
    genericConstraint.upperBound = Token(TokenKind.UPPERBOUND, "<:")

    let upperBounds = ArrayList<TypeNode>()
    upperBounds.add(RefType(quote(Bound)))
    genericConstraint.upperBounds = upperBounds

    // 转化为 Tokens 并输出
    println("genericConstraint.toTokens(): ${genericConstraint.toTokens()}")
}
```

运行结果：

```text
genericConstraint.toTokens(): where U <: Bound
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 构造一个默认的 GenericConstraint 对象
    let genericConstraint = GenericConstraint()

    // 设置 GenericConstraint 的属性
    genericConstraint.keyword = Token(TokenKind.WHERE, "where")
    genericConstraint.typeArgument = RefType(quote(U))
    genericConstraint.upperBound = Token(TokenKind.UPPERBOUND, "<:")

    let upperBounds = ArrayList<TypeNode>()
    upperBounds.add(RefType(quote(Bound)))
    genericConstraint.upperBounds = upperBounds

    // 转化为 Tokens 并输出
    println("genericConstraint.toTokens(): ${genericConstraint.toTokens()}")
}
```

运行结果：

```text
genericConstraint.toTokens(): where U <: Bound
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: GenericConstraint) {
        println("Visiting GenericConstraint")
    }
}

main(): Unit {
    // 构造一个默认的 GenericConstraint 对象
    let genericConstraint = GenericConstraint()

    // 设置 GenericConstraint 的属性
    genericConstraint.keyword = Token(TokenKind.WHERE, "where")
    genericConstraint.typeArgument = RefType(quote(U))
    genericConstraint.upperBound = Token(TokenKind.UPPERBOUND, "<:")

    let upperBounds = ArrayList<TypeNode>()
    upperBounds.add(RefType(quote(Bound)))
    genericConstraint.upperBounds = upperBounds

    // 使用自定义访问器遍历 GenericConstraint 节点
    genericConstraint.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting GenericConstraint
```

## class GenericParam

```cangjie
public class GenericParam <: Node {
    public init(parameters: Tokens)
    public init()
}
```

功能：表示一个类型形参节点。

一个 [GenericParam](ast_package_classes.md#class-genericparam) 节点：`<T1, T2, T3>`。

> **说明：**
>
> 类型形参用 `<>` 括起并用 "," 分隔多个类型形参名称。

父类型：

- [Node](#class-node)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [GenericParam](ast_package_classes.md#class-genericparam) 节点中的左尖括号词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop parameters

```cangjie
public mut prop parameters: Tokens
```

功能：获取或设置 [GenericParam](ast_package_classes.md#class-genericparam) 节点中的类型形参的 [Tokens](ast_package_classes.md#class-tokens) 类型，可能为空，如 `<T1, T2, T3>` 中的 `T1` `T2` 和 `T3`。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [GenericParam](ast_package_classes.md#class-genericparam) 节点中的右尖括号词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [GenericParam](ast_package_classes.md#class-genericparam) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 GenericParam 对象
    let genericParam = GenericParam()

    // 设置 GenericParam 的属性
    genericParam.lAngle = Token(TokenKind.LT, "<")
    genericParam.rAngle = Token(TokenKind.GT, ">")
    genericParam.parameters = quote(A B)

    // 转化为 Tokens 并输出
    println("genericParam.toTokens(): ${genericParam.toTokens()}")
}
```

运行结果：

```text
genericParam.toTokens(): < A, B >
```

### init(Tokens)

```cangjie
public init(parameters: Tokens)
```

功能：构造一个 [GenericParam](ast_package_classes.md#class-genericparam) 对象。

参数：

- parameters: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [GenericParam](ast_package_classes.md#class-genericparam) 的类型形参的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造 GenericParam
    let genericParam = GenericParam(quote(T U V))

    // 转化为 Tokens 并输出
    println("genericParam.toTokens(): ${genericParam.toTokens()}")
}
```

运行结果：

```text
genericParam.toTokens(): < T, U, V >
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 GenericParam 对象
    let genericParam = GenericParam()

    // 设置 GenericParam 的属性
    genericParam.lAngle = Token(TokenKind.LT, "<")
    genericParam.rAngle = Token(TokenKind.GT, ">")
    genericParam.parameters = quote(A B)

    // 转化为 Tokens 并输出
    println("genericParam.toTokens(): ${genericParam.toTokens()}")
}
```

运行结果：

```text
genericParam.toTokens(): < A, B >
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: GenericParam) {
        println("Visiting GenericParam")
    }
}

main(): Unit {
    // 使用 Tokens 构造 GenericParam
    let genericParam = GenericParam(quote(T, U))

    // 使用自定义访问器遍历 GenericParam 节点
    genericParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting GenericParam
```

## class Handler

```cangjie
public class Handler {}
```

功能：表示一个 `handle` 子句，其中包含一个命令模式和要执行的代码块。

一个 [Handler](ast_package_classes.md#class-handler) 节点的示例：
`handle (e: Command<Unit>) { ... }`

## class IfExpr

```cangjie
public class IfExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示条件表达式。

可以根据判定条件是否成立来决定执行哪条代码分支。一个 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中 `if` 是关键字，`if` 之后是一个小括号，小括号内可以是一个表达式或者一个 `let` 声明的解构匹配，接着是一个 [Block](ast_package_classes.md#class-block)，[Block](ast_package_classes.md#class-block) 之后是可选的 `else` 分支。 `else` 分支以 `else` 关键字开始，后接新的 `if` 表达式或一个 [Block](ast_package_classes.md#class-block)。

父类型：

- [Expr](#class-expr)

### prop condition

```cangjie
public mut prop condition: Expr
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中的 `if` 后的条件表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop elseExpr

```cangjie
public mut prop elseExpr: Expr
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中 `else` 分支节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当前 [IfExpr](ast_package_classes.md#class-ifexpr) 节点没有 else 分支节点。

### prop ifBlock

```cangjie
public mut prop ifBlock: Block
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中的 `if` 后的 block 节点。

类型：[Block](ast_package_classes.md#class-block)

### prop keywordE

```cangjie
public mut prop keywordE: Token
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中 `else` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `else` 关键字时，抛出异常。

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中的 `if` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `if` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中的 `if` 后的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [IfExpr](ast_package_classes.md#class-ifexpr) 节点中的 `if` 后的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IfExpr](ast_package_classes.md#class-ifexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 IfExpr 对象
    let ifExpr = IfExpr()

    // 设置 IfExpr 的属性
    ifExpr.keywordI = Token(TokenKind.IF, "if")
    ifExpr.lParen = Token(TokenKind.LPAREN, "(")
    ifExpr.rParen = Token(TokenKind.RPAREN, ")")
    ifExpr.condition = RefExpr(quote(cond))

    // 创建 if 块
    let ifBlock = Block()
    ifBlock.lBrace = Token(TokenKind.LCURL, "{")
    ifBlock.rBrace = Token(TokenKind.RCURL, "}")
    let expr1 = LitConstExpr(quote(1))
    ifBlock.nodes.add(expr1)
    ifExpr.ifBlock = ifBlock

    // 转化为 Tokens 并输出
    println("ifExpr.toTokens(): ${ifExpr.toTokens()}")
}
```

运行结果：

```text
ifExpr.toTokens(): if(cond) {
    1
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [IfExpr](ast_package_classes.md#class-ifexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [IfExpr](ast_package_classes.md#class-ifexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [IfExpr](ast_package_classes.md#class-ifexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造 IfExpr
    let ifExpr = IfExpr(quote(if (x > 0) { println("Positive") } else { println("Negative") }))

    // 转化为 Tokens 并输出
    println("ifExpr.toTokens(): ${ifExpr.toTokens()}")
}
```

运行结果：

```text
ifExpr.toTokens(): if(x > 0) {
    println("Positive")
}
else {
    println("Negative")
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 IfExpr 对象
    let ifExpr = IfExpr()

    // 设置 IfExpr 的属性
    ifExpr.keywordI = Token(TokenKind.IF, "if")
    ifExpr.lParen = Token(TokenKind.LPAREN, "(")
    ifExpr.rParen = Token(TokenKind.RPAREN, ")")
    ifExpr.condition = RefExpr(quote(condition))

    // 创建 if 块
    let ifBlock = Block()
    ifBlock.lBrace = Token(TokenKind.LCURL, "{")
    ifBlock.rBrace = Token(TokenKind.RCURL, "}")
    let expr1 = CallExpr(quote(println("Condition is true")))
    ifBlock.nodes.add(expr1)
    ifExpr.ifBlock = ifBlock

    // 转化为 Tokens 并输出
    println("ifExpr.toTokens(): ${ifExpr.toTokens()}")
}
```

运行结果：

```text
ifExpr.toTokens(): if(condition) {
    println("Condition is true")
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IfExpr) {
        println("Visiting IfExpr")
    }
}

main(): Unit {
    // 使用 Tokens 构造 IfExpr
    let ifExpr = IfExpr(quote(if (a < b) { println(a) } else { println(b) }))

    // 使用自定义访问器遍历 IfExpr 节点
    ifExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting IfExpr
```

## class ImportContent

```cangjie
public class ImportContent <: Node {
    public init()
}
```

功能：表示一个包导入声明节点的具体声明内容，如 `import pkg.a.b` 中的 `pkg.a.b`。

父类型：

- [Node](#class-node)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中的 "," 词法单元序列，只有 `importKind` 为 `ImportKind.Multi` 时非空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中被导入的项，它可能是包中的顶层定义或声明，也可能是子包的名字。

类型：[Token](ast_package_structs.md#struct-token)

### prop importAlias

```cangjie
public mut prop importAlias: Tokens
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中导入的定义或声明的别名词法单元序列，只有 `importKind` 为 `ImportKind.Alias` 时非空。如：`import packageName.xxx as yyy` 中的 `as yyy`。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop importKind

```cangjie
public mut prop importKind: ImportKind
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中导入类型。

类型：[ImportKind](ast_package_enums.md#enum-importkind)

### prop items

```cangjie
public mut prop items: ArrayList<ImportContent>
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中被导入的所有项，只有 `importKind` 为 `ImportKind.Multi` 时非空。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[ImportContent](ast_package_classes.md#class-importcontent)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中的 `{` 操作符词法单元，只有 `importKind` 为 `ImportKind.Multi` 时非空。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `{` 操作符时，抛出异常。

### prop orgName

```cangjie
public mut prop orgName: Token
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中代表组织名的词法单元，setter 会检查 orgSeparator 是否为 "::" 词法单元，若为空则同时设置其为 "::" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 内容为空字符串时抛出异常。

### prop orgSeparator

```cangjie
public mut prop orgSeparator: Token
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中的 "::" 词法单元，setter 会检查 orgName 内容是否为空字符串，若有则抛异常。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "::" 时，或 orgName 内容为空字符串时抛出异常。

### prop prefixDots

```cangjie
public mut prop prefixDots: Tokens
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中完整包名中用于分隔每层子包的词法单元序列，可能为空。如 `import a.b.c` 中的两个 "."。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "." 词法单元序列时，抛出异常。

### prop prefixPaths

```cangjie
public mut prop prefixPaths: Tokens
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中完整包名的前缀部分的词法单元序列，可能为空。如 `import a.b.c` 中的 `a` 和 `b`。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [ImportContent](ast_package_classes.md#class-importcontent) 节点中的 `}` 操作符词法单元，只有 `importKind` 为 `ImportKind.Multi` 时非空。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `}` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ImportContent](ast_package_classes.md#class-importcontent) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ImportContent 对象
    let importContent = ImportContent()

    // 设置 ImportContent 的属性
    importContent.importKind = ImportKind.Single
    importContent.prefixPaths = quote(std collection)
    importContent.prefixDots = quote(. .)
    importContent.identifier = Token(TokenKind.IDENTIFIER, "ArrayList")

    // 转化为 Tokens 并输出
    println("importContent.toTokens(): ${importContent.toTokens()}")
}
```

运行结果：

```text
importContent.toTokens(): std.collection.ArrayList
```

### func isImportAlias()

```cangjie
public func isImportAlias(): Bool
```

功能：判断 [ImportContent](ast_package_classes.md#class-importcontent) 节点是否对导入项取了别名。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - [ImportContent](ast_package_classes.md#class-importcontent) 节点是否对导入项取了别名。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个别名导入的 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.Alias
    importContent.importAlias = quote(as myAlias)

    println("importContent.isImportAlias(): ${importContent.isImportAlias()}")
}
```

运行结果：

```text
importContent.isImportAlias(): true
```

### func isImportAll()

```cangjie
public func isImportAll(): Bool
```

功能：判断 [ImportContent](ast_package_classes.md#class-importcontent) 节点是否为全导入。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - [ImportContent](ast_package_classes.md#class-importcontent) 节点是否为全导入。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个全导入的 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.All

    println("importContent.isImportAll(): ${importContent.isImportAll()}")
}
```

运行结果：

```text
importContent.isImportAll(): true
```

### func isImportMulti()

```cangjie
public func isImportMulti(): Bool
```

功能：判断 [ImportContent](ast_package_classes.md#class-importcontent) 节点是否导入了多个顶级定义或声明。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - [ImportContent](ast_package_classes.md#class-importcontent) 节点是否导入了多个顶级定义或声明。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个多导入的 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.Multi

    println("importContent.isImportMulti(): ${importContent.isImportMulti()}")
}
```

运行结果：

```text
importContent.isImportMulti(): true
```

### func isImportSingle()

```cangjie
public func isImportSingle(): Bool
```

功能：判断 [ImportContent](ast_package_classes.md#class-importcontent) 节点是否为单导入。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - [ImportContent](ast_package_classes.md#class-importcontent) 节点是否为单导入。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个单导入的 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.Single

    println("importContent.isImportSingle(): ${importContent.isImportSingle()}")
}
```

运行结果：

```text
importContent.isImportSingle(): true
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ImportContent 对象
    let importContent = ImportContent()

    // 设置 ImportContent 的属性
    importContent.importKind = ImportKind.Single
    importContent.orgName = Token(TokenKind.IDENTIFIER, "ORG")
    importContent.orgSeparator = Token(TokenKind.DOUBLE_COLON, "::")
    importContent.prefixPaths = quote(std collection)
    importContent.prefixDots = quote(.)
    importContent.identifier = Token(TokenKind.IDENTIFIER, "ArrayList")

    // 转化为 Tokens 并输出
    println("importContent.toTokens(): ${importContent.toTokens()}")
}
```

运行结果：

```text
importContent.toTokens(): ORG :: std.collection.ArrayList
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ImportContent) {
        println("Visiting ImportContent")
    }
}

main(): Unit {
    // 构造一个默认的 ImportContent 对象
    let importContent = ImportContent()

    // 设置 ImportContent 的属性
    importContent.importKind = ImportKind.Single
    importContent.orgName = Token(TokenKind.IDENTIFIER, "ORG")
    importContent.orgSeparator = Token(TokenKind.DOUBLE_COLON, "::")
    importContent.prefixPaths = quote(std collection)
    importContent.prefixDots = quote(.)
    importContent.identifier = Token(TokenKind.IDENTIFIER, "ArrayList")

    // 使用自定义访问器遍历 ImportContent 节点
    importContent.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ImportContent
```

## class ImportList

```cangjie
public class ImportList <: Node {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示包导入节点。

一个 [ImportList](ast_package_classes.md#class-importlist) 节点: `import moduleName.packageName.foo as bar`。

> **说明：**
>
> 导入节点以可选的访问性修饰符（`public/protected/internal/private`）加关键字 `import` 开头。以 `import pkga.pkgb.item` 为例，`pkga.pkgb` 为导入的顶级定义或声明所在的包的名字，`item` 为导入的顶级定义或声明。

父类型：

- [Node](#class-node)

### prop content

```cangjie
public mut prop content: ImportContent
```

功能：获取或设置 [ImportList](ast_package_classes.md#class-importlist) 节点中的被导入的具体项。如 `import a.b.c` 中的 `a.b.c` 部分。

类型：[ImportContent](ast_package_classes.md#class-importcontent)

### prop keywordI

```cangjie
public mut prop keywordI: Token
```

功能：获取或设置 [ImportList](ast_package_classes.md#class-importlist) 节点中的 `import` 关键字的词法单元，`I` 为关键字首字母。

类型：[Token](ast_package_structs.md#struct-token)

### prop modifier

```cangjie
public mut prop modifier: Token
```

功能：获取或设置 [ImportList](ast_package_classes.md#class-importlist) 节点中的修饰符，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ImportList](ast_package_classes.md#class-importlist) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ImportList 对象
    let importList = ImportList()

    // 设置 ImportList 的属性
    importList.keywordI = Token(TokenKind.IMPORT, "import")

    // 创建并设置 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.Single
    importContent.prefixPaths = quote(std collection)
    importContent.prefixDots = quote(.)
    importContent.identifier = Token(TokenKind.IDENTIFIER, "ArrayList")

    importList.content = importContent

    // 转化为 Tokens 并输出
    println("importList.toTokens(): ${importList.toTokens()}")
}
```

运行结果：

```text
importList.toTokens(): import std.collection.ArrayList
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ImportList](ast_package_classes.md#class-importlist) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ImportList](ast_package_classes.md#class-importlist) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens)) 序列。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ImportList](ast_package_classes.md#class-importlist) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造 ImportList
    let importList = ImportList(quote(import std.collection.*))

    // 转化为 Tokens 并输出
    println("importList.toTokens(): ${importList.toTokens()}")
}
```

运行结果：

```text
importList.toTokens(): import std.collection.*
```

### func isImportMulti()

```cangjie
public func isImportMulti(): Bool
```

功能：判断 [ImportList](ast_package_classes.md#class-importlist) 节点是否导入了多个顶级定义或声明。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果 [ImportList](ast_package_classes.md#class-importlist) 节点导入了多个顶级定义或声明，返回 true；反之，返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let singleImport = ImportList(quote(import std.ast.RefType))
    let multiImport = ImportList(quote(import std.ast.{RefType, CallExpr}))

    println("singleImport.isImportMulti(): ${singleImport.isImportMulti()}")
    println("multiImport.isImportMulti(): ${multiImport.isImportMulti()}")
}
```

运行结果：

```text
singleImport.isImportMulti(): false
multiImport.isImportMulti(): true
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ImportList 对象
    let importList = ImportList()

    // 设置 ImportList 的属性
    importList.keywordI = Token(TokenKind.IMPORT, "import")

    // 创建并设置 ImportContent
    let importContent = ImportContent()
    importContent.importKind = ImportKind.Single
    importContent.prefixPaths = quote(std collection)
    importContent.prefixDots = quote(.)
    importContent.identifier = Token(TokenKind.IDENTIFIER, "ArrayList")
    importList.content = importContent

    // 转化为 Tokens 并输出
    println("importList.toTokens(): ${importList.toTokens()}")
}
```

运行结果：

```text
importList.toTokens(): import std.collection.ArrayList
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ImportList) {
        println("Visiting ImportList")
    }
}

main(): Unit {
    // 用 Tokens 创建 ImportList
    let importList = ImportList(quote(import std.ast.RefType as RT))

    // 使用自定义访问器遍历 ImportList 节点
    importList.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ImportList
```

## class IncOrDecExpr

```cangjie
public class IncOrDecExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示包含自增操作符（`++`）或自减操作符（`--`）的表达式。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 中的表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

功能：获取或设置 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 中的操作符。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 IncOrDecExpr 对象
    let incOrDecExpr = IncOrDecExpr()

    // 设置 IncOrDecExpr 的属性
    incOrDecExpr.expr = RefExpr(quote(counter))
    incOrDecExpr.op = Token(TokenKind.DECR, "--")

    // 转化为 Tokens 并输出
    println("incOrDecExpr.toTokens(): ${incOrDecExpr.toTokens()}")
}
```

运行结果：

```text
incOrDecExpr.toTokens(): counter --
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造 IncOrDecExpr
    let incExpr = IncOrDecExpr(quote(x++))

    // 转化为 Tokens 并输出
    println("incExpr.toTokens(): ${incExpr.toTokens()}")
}
```

运行结果：

```text
incExpr.toTokens(): x ++
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 IncOrDecExpr 对象
    let incOrDecExpr = IncOrDecExpr()

    // 设置 IncOrDecExpr 的属性
    incOrDecExpr.expr = RefExpr(quote(counter))
    incOrDecExpr.op = Token(TokenKind.INCR, "++")

    // 转化为 Tokens 并输出
    println("incOrDecExpr.toTokens(): ${incOrDecExpr.toTokens()}")
}
```

运行结果：

```text
incOrDecExpr.toTokens(): counter ++
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IncOrDecExpr) {
        println("Visiting IncOrDecExpr")
    }
}

main(): Unit {
    // 使用 Tokens 构造 IncOrDecExpr
    let incOrDecExpr = IncOrDecExpr(quote(x--))

    // 使用自定义访问器遍历 IncOrDecExpr 节点
    incOrDecExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting IncOrDecExpr
```

## class InterfaceDecl

```cangjie
public class InterfaceDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示接口定义节点。

接口的定义使用 `interface` 关键字，接口定义依次为：可缺省的修饰符、interface 关键字、接口名、可选的类型参数、是否指定父接口、可选的泛型约束、接口体的定义。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

功能：获取或设置 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 节点的类体。

类型：[Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

功能：获取或设置 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 节点的父接口声明中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

功能：获取或设置 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 节点的父接口。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 `<:` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 InterfaceDecl 对象
    let interfaceDecl = InterfaceDecl()

    // 设置 InterfaceDecl 的属性
    interfaceDecl.identifier = Token(TokenKind.IDENTIFIER, "Shape")
    interfaceDecl.keyword = Token(TokenKind.INTERFACE, "interface")

    // 创建并设置 body
    let body = Body()
    let funcDecl = FuncDecl(quote(func area(): Float64))
    body.decls.add(funcDecl)
    interfaceDecl.body = body

    // 转化为 Tokens 并输出
    println("interfaceDecl.toTokens(): ${interfaceDecl.toTokens()}")
}
```

运行结果：

```text
interfaceDecl.toTokens(): interface Shape {
    func area(): Float64
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Tokens 构造 InterfaceDecl
    let interfaceDecl = InterfaceDecl(quote(interface MyInterface { func foo(): Int64 }))

    // 转化为 Tokens 并输出
    println("interfaceDecl.toTokens(): ${interfaceDecl.toTokens()}")
}
```

运行结果：

```text
interfaceDecl.toTokens(): interface MyInterface {
    func foo(): Int64
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 InterfaceDecl 对象
    let interfaceDecl = InterfaceDecl()

    // 设置 InterfaceDecl 的属性
    interfaceDecl.identifier = Token(TokenKind.IDENTIFIER, "Shape")
    interfaceDecl.keyword = Token(TokenKind.INTERFACE, "interface")

    // 创建并设置 body
    let body = Body()
    let funcDecl = FuncDecl(quote(func area(): Float64))
    body.decls.add(funcDecl)
    interfaceDecl.body = body

    // 转化为 Tokens 并输出
    println("interfaceDecl.toTokens(): ${interfaceDecl.toTokens()}")
}
```

运行结果：

```text
interfaceDecl.toTokens(): interface Shape {
    func area(): Float64
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: InterfaceDecl) {
        println("Visiting InterfaceDecl")
    }
}

main(): Unit {
    // 使用 Tokens 构造 InterfaceDecl
    let interfaceDecl = InterfaceDecl(quote(interface MyInterface { func foo(): Int64 }))

    // 使用自定义访问器遍历 InterfaceDecl 节点
    interfaceDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting InterfaceDecl
```

## class IsExpr

```cangjie
public class IsExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个类型检查表达式。

一个 [IsExpr](ast_package_classes.md#class-isexpr) 表达式：`e is T`，类型为 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)。其中 e 可以是任何类型的表达式，T 可以是任何类型。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [IsExpr](ast_package_classes.md#class-isexpr) 节点中的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [IsExpr](ast_package_classes.md#class-isexpr) 节点中的 `is` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `is` 操作符时，抛出异常。

### prop shiftType

```cangjie
public mut prop shiftType: TypeNode
```

功能：获取或设置 [IsExpr](ast_package_classes.md#class-isexpr) 节点中的目标类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [IsExpr](ast_package_classes.md#class-isexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 IsExpr 对象
    let isExpr = IsExpr()

    // 设置 IsExpr 的属性
    isExpr.expr = RefExpr(quote(x))
    isExpr.keyword = Token(TokenKind.IS)
    isExpr.shiftType = PrimitiveType(quote(Int8))

    // 转化为 Tokens 并输出
    println("isExpr.toTokens(): ${isExpr.toTokens()}")
}
```

运行结果：

```text
isExpr.toTokens(): x is Int8
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [IsExpr](ast_package_classes.md#class-isexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [IsExpr](ast_package_classes.md#class-isexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [IsExpr](ast_package_classes.md#class-isexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 IsExpr 对象
    let isExpr = IsExpr(quote(x is String))

    // 转化为 Tokens 并输出
    println("isExpr.toTokens(): ${isExpr.toTokens()}")
}
```

运行结果：

```text
isExpr.toTokens(): x is String
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 IsExpr 对象
    let isExpr = IsExpr(quote(x is String))

    // 转化为 Tokens 并输出
    println("isExpr.toTokens(): ${isExpr.toTokens()}")
}
```

运行结果：

```text
isExpr.toTokens(): x is String
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IsExpr) {
        println("Visiting IsExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 IsExpr 对象
    let isExpr = IsExpr(quote(x is String))

    // 使用自定义访问器遍历 IsExpr 节点
    isExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting IsExpr
```

## class JumpExpr

```cangjie
public class JumpExpr <: Expr {
    public init(kind: Tokens)
    public init()
}
```

功能：表示循环表达式的循环体中的 `break` 和 `continue`。

父类型：

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置关键字。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [JumpExpr](ast_package_classes.md#class-jumpexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 JumpExpr 对象
    let jumpExpr = JumpExpr()

    // 设置 JumpExpr 的属性
    jumpExpr.keyword = Token(TokenKind.BREAK)

    // 转化为 Tokens 并输出
    println("jumpExpr.toTokens(): ${jumpExpr.toTokens()}")
}
```

运行结果：

```text
jumpExpr.toTokens(): break
```

### init(Tokens)

```cangjie
public init(kind: Tokens)
```

功能：构造一个 [JumpExpr](ast_package_classes.md#class-jumpexpr) 对象。

参数：

- kind: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [JumpExpr](ast_package_classes.md#class-jumpexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [JumpExpr](ast_package_classes.md#class-jumpexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 JumpExpr 对象
    let jumpExpr = JumpExpr(quote(break))

    // 转化为 Tokens 并输出
    println("jumpExpr.toTokens(): ${jumpExpr.toTokens()}")
}
```

运行结果：

```text
jumpExpr.toTokens(): break
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 JumpExpr 对象
    let jumpExpr = JumpExpr(quote(break))

    // 转化为 Tokens 并输出
    println("jumpExpr.toTokens(): ${jumpExpr.toTokens()}")
}
```

运行结果：

```text
jumpExpr.toTokens(): break
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: JumpExpr) {
        println("Visiting JumpExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 JumpExpr 对象
    let jumpExpr = JumpExpr(quote(break))

    // 使用自定义访问器遍历 JumpExpr 节点
    jumpExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting JumpExpr
```

## class LambdaExpr

```cangjie
public class LambdaExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `Lambda` 表达式，是一个匿名的函数。

一个 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 节点有两种形式，一种是有形参的，例如 `{a: Int64 => e1; e2 }`，另一种是无形参的，例如 `{ => e1; e2 }`。

父类型：

- [Expr](#class-expr)

### prop doubleArrow

```cangjie
public mut prop doubleArrow: Token
```

功能：获取或设置 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 中的 `=>`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `=>` 操作符时，抛出异常。

### prop funcParams

```cangjie
public mut prop funcParams:  ArrayList<FuncParam>
```

功能：获取或设置 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 中的参数列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 中的 "{"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "{" 时，抛出异常。

### prop nodes

```cangjie
public mut prop nodes: ArrayList<Node>
```

功能：获取或设置 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 中的表达式或声明节点。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Node](ast_package_classes.md#class-node)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 中的 "}"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "}" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 LambdaExpr 对象
    let lambdaExpr = LambdaExpr()

    // 设置 LambdaExpr 的属性
    lambdaExpr.lBrace = Token(TokenKind.LCURL)
    lambdaExpr.rBrace = Token(TokenKind.RCURL)
    lambdaExpr.doubleArrow = Token(TokenKind.DOUBLE_ARROW)
    let funcParams = ArrayList<FuncParam>()
    funcParams.add(FuncParam(quote(x: Int64)))
    lambdaExpr.funcParams = funcParams
    let nodes = ArrayList<Node>()
    nodes.add(BinaryExpr(quote(x + 1)))
    lambdaExpr.nodes = nodes

    // 转化为 Tokens 并输出
    println("lambdaExpr.toTokens(): ${lambdaExpr.toTokens()}")
}
```

运行结果：

```text
lambdaExpr.toTokens(): { x: Int64 =>
    x + 1
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LambdaExpr 对象
    let lambdaExpr = LambdaExpr(quote({x: Int64 => x + 1}))

    // 转化为 Tokens 并输出
    println("lambdaExpr.toTokens(): ${lambdaExpr.toTokens()}")
}
```

运行结果：

```text
lambdaExpr.toTokens(): { x: Int64 =>
    x + 1
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LambdaExpr 对象
    let lambdaExpr = LambdaExpr(quote({x: Int64 => x + 1}))

    // 转化为 Tokens 并输出
    println("lambdaExpr.toTokens(): ${lambdaExpr.toTokens()}")
}
```

运行结果：

```text
lambdaExpr.toTokens(): { x: Int64 =>
    x + 1
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LambdaExpr) {
        println("Visiting LambdaExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 LambdaExpr 对象
    let lambdaExpr = LambdaExpr(quote({x: Int64 => x + 1}))

    // 使用自定义访问器遍历 LambdaExpr 节点
    lambdaExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting LambdaExpr
```

## class LetPatternExpr

```cangjie
public class LetPatternExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `let` 声明的解构匹配节点。

一个 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点：`if (let Some(v) <- x)` 中的 `let Some(v) <- x`。

父类型：

- [Expr](#class-expr)

### prop backArrow

```cangjie
public mut prop backArrow: Token
```

功能：获取或设置 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点中 `<-` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<-` 操作符时，抛出异常。

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点中 `<-` 操作符之后的表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点中 `let` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `let` 关键字时，抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点中 `let` 之后的 pattern。

类型：[Pattern](ast_package_classes.md#class-pattern)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 LetPatternExpr 对象
    let letPatternExpr = LetPatternExpr()

    // 设置 LetPatternExpr 的属性
    letPatternExpr.keyword = Token(TokenKind.LET)
    letPatternExpr.pattern = EnumPattern(quote(Some(v)))
    letPatternExpr.backArrow = Token(TokenKind.BACKARROW)
    letPatternExpr.expr = RefExpr(quote(x))

    // 转化为 Tokens 并输出
    println("letPatternExpr.toTokens(): ${letPatternExpr.toTokens()}")
}
```

运行结果：

```text
letPatternExpr.toTokens(): let Some(v) <- x
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LetPatternExpr 对象
    let letPatternExpr = LetPatternExpr(quote(let Some(v) <- x))

    // 转化为 Tokens 并输出
    println("letPatternExpr.toTokens(): ${letPatternExpr.toTokens()}")
}
```

运行结果：

```text
letPatternExpr.toTokens(): let Some(v) <- x
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LetPatternExpr 对象
    let letPatternExpr = LetPatternExpr(quote(let Some(v) <- x))

    // 转化为 Tokens 并输出
    println("letPatternExpr.toTokens(): ${letPatternExpr.toTokens()}")
}
```

运行结果：

```text
letPatternExpr.toTokens(): let Some(v) <- x
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LetPatternExpr) {
        println("Visiting LetPatternExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 LetPatternExpr 对象
    let letPatternExpr = LetPatternExpr(quote(let Some(v) <- x))

    // 使用自定义访问器遍历 LetPatternExpr 节点
    letPatternExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting LetPatternExpr
```

## class LitConstExpr

```cangjie
public class LitConstExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个常量表达式节点。

一个 [LitConstExpr](ast_package_classes.md#class-litconstexpr) 表达式：`"abc"`，`123` 等。

父类型：

- [Expr](#class-expr)

### prop literal

```cangjie
public mut prop literal: Token
```

功能：获取或设置 [LitConstExpr](ast_package_classes.md#class-litconstexpr) 节点中的字面量。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [LitConstExpr](ast_package_classes.md#class-litconstexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 LitConstExpr 对象
    let litConstExpr = LitConstExpr()

    // 设置 LitConstExpr 的属性
    litConstExpr.literal = Token(TokenKind.INTEGER_LITERAL, "123")

    // 转化为 Tokens 并输出
    println("litConstExpr.toTokens(): ${litConstExpr.toTokens()}")
}
```

运行结果：

```text
litConstExpr.toTokens(): 123
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [LitConstExpr](ast_package_classes.md#class-litconstexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [LitConstExpr](ast_package_classes.md#class-litconstexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LitConstExpr 对象
    let litConstExpr = LitConstExpr(quote(123))

    // 转化为 Tokens 并输出
    println("litConstExpr.toTokens(): ${litConstExpr.toTokens()}")
}
```

运行结果：

```text
litConstExpr.toTokens(): 123
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 LitConstExpr 对象
    let litConstExpr = LitConstExpr(quote(123))

    // 转化为 Tokens 并输出
    println("litConstExpr.toTokens(): ${litConstExpr.toTokens()}")
}
```

运行结果：

```text
litConstExpr.toTokens(): 123
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LitConstExpr) {
        println("Visiting LitConstExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 LitConstExpr 对象
    let litConstExpr = LitConstExpr(quote(123))

    // 使用自定义访问器遍历 LitConstExpr 节点
    litConstExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting LitConstExpr
```

## class MacroDecl

```cangjie
public class MacroDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个宏定义节点。

一个 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点：`public macro M(input: Tokens): Tokens {...}`。

父类型：

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的函数体。

类型：[Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的冒号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是冒号时，抛出异常。

### prop declType

```cangjie
public mut prop declType: TypeNode
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的函数返回类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的函数返回类型是一个缺省值时，抛出异常。

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的参数。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MacroDecl](ast_package_classes.md#class-macrodecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MacroDecl 对象
    let macroDecl = MacroDecl()

    // 设置 MacroDecl 的属性
    macroDecl.keyword = quote(macro)[0]
    macroDecl.identifier = quote(testMacro)[0]
    macroDecl.lParen = Token(TokenKind.LPAREN)
    let param1 = FuncParam(quote(a: Tokens))
    let param2 = FuncParam(quote(b: Tokens))
    macroDecl.funcParams = ArrayList<FuncParam>([param1, param2])
    macroDecl.rParen = Token(TokenKind.RPAREN)
    macroDecl.colon = Token(TokenKind.COLON)
    macroDecl.declType = RefType(quote(Tokens))
    macroDecl.block = Block()

    // 转化为 Tokens 并输出
    println("macroDecl.toTokens(): ${macroDecl.toTokens()}")
}
```

运行结果：

```text
macroDecl.toTokens(): macro testMacro(a: Tokens, b: Tokens): Tokens
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MacroDecl](ast_package_classes.md#class-macrodecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MacroDecl](ast_package_classes.md#class-macrodecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MacroDecl](ast_package_classes.md#class-macrodecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MacroDecl 对象
    let macroDecl = MacroDecl(quote(public macro M(input: Tokens): Tokens {}))

    // 转化为 Tokens 并输出
    println("macroDecl.toTokens(): ${macroDecl.toTokens()}")
}
```

运行结果：

```text
macroDecl.toTokens(): public macro M(input: Tokens): Tokens {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MacroDecl 对象
    let macroDecl = MacroDecl(quote(public macro M(input: Tokens): Tokens {}))

    // 转化为 Tokens 并输出
    println("macroDecl.toTokens(): ${macroDecl.toTokens()}")
}
```

运行结果：

```text
macroDecl.toTokens(): public macro M(input: Tokens): Tokens {
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroDecl) {
        println("Visiting MacroDecl")
    }
}

main(): Unit {
    // 从 Tokens 创建 MacroDecl 对象
    let macroDecl = MacroDecl(quote(public macro M(input: Tokens): Tokens {}))

    // 使用自定义访问器遍历 MacroDecl 节点
    macroDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MacroDecl
```

## class MacroExpandDecl

```cangjie
public class MacroExpandDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示宏调用节点。

一个 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 节点： `@M class A {}`。

父类型：

- [Decl](#class-decl)

### prop fullIdentifier

```cangjie
public mut prop fullIdentifier: Token
```

功能：获取或设置宏调用节点的完整标识符，如 `@pkg.m class a{}` 中的 `pkg.m`。

类型：[Token](ast_package_structs.md#struct-token)

### prop identifier

```cangjie
public override mut prop identifier: Token
```

功能：该属性继承自 [Decl](ast_package_classes.md#class-decl) 节点，表示宏调用节点的标识符，如 `@pkg.m class a{}` 中的 `m`。

类型：[Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 宏调用的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 属性宏调用的 "["。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "[" 时，抛出异常。

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 属性宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop macroInputDecl

```cangjie
public mut prop macroInputDecl: Decl
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 中的声明节点。

类型：[Decl](ast_package_classes.md#class-decl)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MacroExpandDecl](ast_package_classes.md#class-macrodecl) 节点中没有声明节点时，抛出异常。

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 宏调用的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

功能：获取或设置 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 属性宏调用的 "]"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "]" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MacroExpandDecl 对象
    let macroExpandDecl = MacroExpandDecl()

    // 设置 MacroExpandDecl 的属性
    macroExpandDecl.keyword = quote(@)[0]
    macroExpandDecl.fullIdentifier = quote(testMacro)[0]
    macroExpandDecl.macroAttrs = quote(123)
    macroExpandDecl.lSquare = Token(LSQUARE)
    macroExpandDecl.rSquare = Token(RSQUARE)
    macroExpandDecl.lParen = Token(LPAREN)
    macroExpandDecl.rParen = Token(RPAREN)
    macroExpandDecl.macroInputs = Tokens()
    macroExpandDecl.macroInputDecl = FuncDecl(quote(func test() {}))

    // 转化为 Tokens 并输出
    println("macroExpandDecl.toTokens(): ${macroExpandDecl.toTokens()}")
}
```

运行结果：

```text
macroExpandDecl.toTokens(): @testMacro[123](func test() {
}
)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    // 从 Tokens 创建 MacroExpandDecl 对象
    let macroExpandDecl = MacroExpandDecl(quote(@M class A {}))

    // 转化为 Tokens 并输出
    println("macroExpandDecl.toTokens(): ${macroExpandDecl.toTokens()}")
}
```

运行结果：

```text
macroExpandDecl.toTokens(): @M
class A {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MacroExpandDecl 对象
    let macroExpandDecl = MacroExpandDecl(quote(@M class A {}))

    // 转化为 Tokens 并输出
    println("macroExpandDecl.toTokens(): ${macroExpandDecl.toTokens()}")
}
```

运行结果：

```text
macroExpandDecl.toTokens(): @M
class A {
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandDecl) {
        println("Visiting MacroExpandDecl")
    }
}

main() {
    // 从 Tokens 创建 MacroExpandDecl 对象
    let macroExpandDecl = MacroExpandDecl(quote(@M class A {}))

    // 使用自定义访问器遍历 MacroExpandDecl 节点
    macroExpandDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MacroExpandDecl
```

## class MacroExpandExpr

```cangjie
public class MacroExpandExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示宏调用节点。

一个 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 节点： `@M (a is Int64)`。

父类型：

- [Expr](#class-expr)

### prop at

```cangjie
public mut prop at: Token
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 节点中的 `@` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `@` 操作符时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置宏调用节点的标识符。

类型：[Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 宏调用的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 属性宏调用的 "["。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "[" 时，抛出异常。

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 属性宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 宏调用的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

功能：获取或设置 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 属性宏调用的 "]"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "]" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MacroExpandExpr 对象
    let macroExpandExpr = MacroExpandExpr()

    // 设置 MacroExpandExpr 的属性
    macroExpandExpr.at = Token(TokenKind.AT)
    macroExpandExpr.identifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandExpr.lParen = Token(TokenKind.LPAREN)
    macroExpandExpr.rParen = Token(TokenKind.RPAREN)
    macroExpandExpr.lSquare = Token(TokenKind.LSQUARE)
    macroExpandExpr.rSquare = Token(TokenKind.RSQUARE)
    macroExpandExpr.macroAttrs = quote(123)
    macroExpandExpr.macroInputs = quote(a is Int64)

    // 转化为 Tokens 并输出
    println("macroExpandExpr.toTokens(): ${macroExpandExpr.toTokens()}")
}
```

运行结果：

```text
macroExpandExpr.toTokens(): @M[123](a is Int64)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MacroExpandExpr 对象
    let macroExpandExpr = MacroExpandExpr(quote(@M (a is Int64)))

    // 转化为 Tokens 并输出
    println("macroExpandExpr.toTokens(): ${macroExpandExpr.toTokens()}")
}
```

运行结果：

```text
macroExpandExpr.toTokens(): @M(a is Int64)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MacroExpandExpr 对象
    let macroExpandExpr = MacroExpandExpr(quote(@M (a is Int64)))

    // 转化为 Tokens 并输出
    println("macroExpandExpr.toTokens(): ${macroExpandExpr.toTokens()}")
}
```

运行结果：

```text
macroExpandExpr.toTokens(): @M(a is Int64)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandExpr) {
        println("Visiting MacroExpandExpr")
    }
}

main(): Unit {
    // 从 Tokens 创建 MacroExpandExpr 对象
    let macroExpandExpr = MacroExpandExpr(quote(@M (a is Int64)))

    // 使用自定义访问器遍历 MacroExpandExpr 节点
    macroExpandExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MacroExpandExpr
```

## class MacroExpandParam

```cangjie
public class MacroExpandParam <: FuncParam {
    public init()
}
```

功能：表示宏调用节点。

一个 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 节点： `func foo (@M a: Int64)` 中的 `@M a: Int64`。

父类型：

- [FuncParam](#class-funcparam)

### prop fullIdentifier

```cangjie
public mut prop fullIdentifier: Token
```

功能：获取或设置宏调用节点的完整标识符，如 `func bar (@pkg.m a: Int64)` 中的 `pkg.m`。

类型：[Token](ast_package_structs.md#struct-token)

### prop identifier

```cangjie
public override mut prop identifier: Token
```

功能：该属性继承自 [Decl](ast_package_classes.md#class-decl) 节点，表示宏调用节点的标识符，如 `func bar (@pkg.m a: Int64)` 中的 `m`。

类型：[Token](ast_package_structs.md#struct-token)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 宏调用的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 属性宏调用的 "["。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "[" 时，抛出异常。

### prop macroAttrs

```cangjie
public mut prop macroAttrs: Tokens
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 属性宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop macroInputDecl

```cangjie
public mut prop macroInputDecl: Decl
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 中的声明节点。

类型：[Decl](ast_package_classes.md#class-decl)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 节点中没有声明节点时，抛出异常。

### prop macroInputs

```cangjie
public mut prop macroInputs: Tokens
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 宏调用的输入。

类型：[Tokens](ast_package_classes.md#class-tokens)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 宏调用的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

功能：获取或设置 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 属性宏调用的 "]"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "]" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MacroExpandParam 对象
    let macroExpandParam = MacroExpandParam()

    // 设置 MacroExpandParam 的属性
    macroExpandParam.keyword = Token(TokenKind.AT, "@")
    macroExpandParam.fullIdentifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.identifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.lSquare = Token(TokenKind.LSQUARE)
    macroExpandParam.rSquare = Token(TokenKind.RSQUARE)
    macroExpandParam.macroAttrs = quote(123)
    macroExpandParam.macroInputs = quote(a: Int64)

    // 转化为 Tokens 并输出
    println("macroExpandParam.toTokens(): ${macroExpandParam.toTokens()}")
}
```

运行结果：

```text
macroExpandParam.toTokens(): @M[123]
a: Int64
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MacroExpandParam 对象
    let macroExpandParam = MacroExpandParam()

    // 设置 MacroExpandParam 的属性
    macroExpandParam.keyword = Token(TokenKind.AT, "@")
    macroExpandParam.fullIdentifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.identifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.lSquare = Token(TokenKind.LSQUARE)
    macroExpandParam.rSquare = Token(TokenKind.RSQUARE)
    macroExpandParam.macroAttrs = quote(123)
    macroExpandParam.macroInputs = quote(a: Int64)

    // 转化为 Tokens 并输出
    println("macroExpandParam.toTokens(): ${macroExpandParam.toTokens()}")
}
```

运行结果：

```text
macroExpandParam.toTokens(): @M[123]
a: Int64
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandParam) {
        println("Visiting MacroExpandParam")
    }
}

main(): Unit {
    // 构造一个默认的 MacroExpandParam 对象
    let macroExpandParam = MacroExpandParam()

    // 设置 MacroExpandParam 的属性
    macroExpandParam.keyword = Token(TokenKind.AT, "@")
    macroExpandParam.identifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.macroInputs = quote(any)

    // 使用自定义访问器遍历 MacroExpandParam 节点
    macroExpandParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MacroExpandParam
```

## class MacroMessage

```cangjie
public class MacroMessage {}
```

功能：记录内层宏发送的信息。

### func getBool(String)

```cangjie
public func getBool(key: String): Bool
```

功能：获取对应 key 值的 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型信息。

参数：

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 用于检索的关键字的名字。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回存在 key 值对应的 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型的信息。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当不存在 key 值对应的 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型的信息时，抛出异常。

示例：

<!-- run -macro0-->
<!-- cfg="--compile-macro" -->
```cangjie
// 宏定义
macro package M

import std.ast.*
import std.collection.ArrayList

public macro inner(input: Tokens) {
    // 向外层宏发送 Bool 类型消息
    setItem("TrueFromInner", true)
    setItem("FalseFromInner", false)
    return input
}

public macro outer(input: Tokens) {
    // 获取名为 inner 的内层宏所发送的全部消息
    let messages = getChildMessages("inner")

    // 获取内层宏发送的 Bool 消息
    let msg0 = messages[0].getBool("TrueFromInner")
    let msg1 = messages[0].getBool("FalseFromInner")

    // 输出两个 Bool 类型消息
    println("Message 0 from inner-macro: ${msg0}")
    println("Message 1 from inner-macro: ${msg1}")
    return input
}
```

<!-- run -macro0-->
<!-- cfg="--debug-macro" -->
```cangjie
// 宏调用
import M.*

@outer(@inner(var a = 1))

main() {
}
```

运行结果：

```text
Message 0 from inner-macro: true
Message 1 from inner-macro: false
```

### func getInt64(String)

```cangjie
public func getInt64(key: String): Int64
```

功能：获取对应 key 值的 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型信息。

参数：

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 用于检索的关键字的名字。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 返回存在 key 值对应的 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型的信息。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当不存在 key 值对应的 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型的信息时，抛出异常。

示例：

<!-- run -macro1-->
<!-- cfg="--compile-macro" -->
```cangjie
// 宏定义
macro package M

import std.ast.*
import std.collection.ArrayList

public macro inner(input: Tokens) {
    // 向外层宏发送 Int64 类型消息
    setItem("Int64FromInner", 100)
    return input
}

public macro outer(input: Tokens) {
    // 获取名为 inner 的内层宏所发送的全部消息
    let messages = getChildMessages("inner")

    // 获取内层宏发送的 Int64 消息
    let msg = messages[0].getInt64("Int64FromInner")

    // 输出 Int64 类型消息
    println("Message from inner-macro: ${msg}")
    return input
}
```

<!-- run -macro1-->
<!-- cfg="--debug-macro" -->
```cangjie
// 宏调用
import M.*

@outer(@inner(var a = 1))

main() {
}
```

运行结果：

```text
Message from inner-macro: 100
```

### func getString(String)

```cangjie
public func getString(key: String): String
```

功能：获取对应 key 值的 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型信息。

参数：

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 用于检索的关键字的名字。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 返回存在 key 值对应的 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型的信息。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当不存在 key 值对应的 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型的信息时，抛出异常。

示例：

<!-- run -macro2-->
<!-- cfg="--compile-macro" -->
```cangjie
// 宏定义
macro package M

import std.ast.*
import std.collection.ArrayList

public macro inner(input: Tokens) {
    // 向外层宏发送 String 类型消息
    setItem("StringFromInner", "message")
    return input
}

public macro outer(input: Tokens) {
    // 获取名为 inner 的内层宏所发送的全部消息
    let messages = getChildMessages("inner")

    // 获取内层宏发送的 String 消息
    let msg = messages[0].getString("StringFromInner")

    // 输出 String 类型消息
    println("Message from inner-macro: ${msg}")
    return input
}
```

<!-- run -macro2-->
<!-- cfg="--debug-macro" -->
```cangjie
// 宏调用
import M.*

@outer(@inner(var a = 1))

main() {
}
```

运行结果：

```text
Message from inner-macro: message
```

### func getTokens(String)

```cangjie
public func getTokens(key: String): Tokens
```

功能：获取对应 key 值的 [Tokens](ast_package_classes.md#class-tokens) 类型信息。

参数：

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 用于检索的关键字的名字。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 返回存在 key 值对应的 [Tokens](ast_package_classes.md#class-tokens) 类型的信息。

异常：

- [Exception](../../core/core_package_api/core_package_exceptions.md#class-exception) - 当不存在 key 值对应的 [Tokens](ast_package_classes.md#class-tokens) 类型的信息时，抛出异常。

示例：

<!-- run -macro3-->
<!-- cfg="--compile-macro" -->
```cangjie
// 宏定义
macro package M

import std.ast.*
import std.collection.ArrayList

public macro inner(input: Tokens) {
    // 向外层宏发送 Tokens 类型消息
    setItem("TokensFromInner", quote(1 + 1))
    return input
}

public macro outer(input: Tokens) {
    // 获取名为 inner 的内层宏所发送的全部消息
    let messages = getChildMessages("inner")

    // 获取内层宏发送的 Tokens 消息
    let msg = messages[0].getTokens("TokensFromInner")

    // 输出 Tokens 类型消息
    println("Message from inner-macro: ${msg}")
    return input
}
```

<!-- run -macro3-->
<!-- cfg="--debug-macro" -->
```cangjie
// 宏调用
import M.*

@outer(@inner(var a = 1))

main() {
}
```

运行结果：

```text
Message from inner-macro: 1 + 1
```

### func hasItem(String)

```cangjie
public func hasItem(key: String): Bool
```

功能：检查是否有 key 值对应的相关信息。

参数：

- key: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 用于检索的关键字名字。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 若存在 key 值对应的相关信息，返回 true；反之，返回 false。

示例：

<!-- run -macro4-->
<!-- cfg="--compile-macro" -->
```cangjie
// 宏定义
macro package M

import std.ast.*
import std.collection.ArrayList

public macro inner(input: Tokens) {
    // 向外层宏发送 Int64 类型消息
    setItem("Int64FromInner", 100)
    return input
}

public macro outer(input: Tokens) {
    // 获取名为 inner 的内层宏所发送的全部消息
    let messages = getChildMessages("inner")

    // 判断内层宏是否发送了对应的消息
    let result = messages[0].hasItem("Int64FromInner")
    println("messages[0].hasItem(\"Int64FromInner\"): ${result}")
    return input
}
```

<!-- run -macro4-->
<!-- cfg="--debug-macro" -->
```cangjie
// 宏调用
import M.*

@outer(@inner(var a = 1))

main() {
}
```

运行结果：

```text
messages[0].hasItem("Int64FromInner"): true
```

## class MainDecl

```cangjie
public class MainDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个 `main` 函数定义节点。

一个 [MainDecl](ast_package_classes.md#class-maindecl) 节点：`main() {}`。

父类型：

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的函数体。

类型：[Block](ast_package_classes.md#class-block)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的冒号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是冒号时，抛出异常。

### prop declType

```cangjie
public mut prop declType: TypeNode
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的函数返回类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MainDecl](ast_package_classes.md#class-maindecl) 节点的函数返回类型是一个缺省值时，抛出异常。

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的函数参数。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MainDecl](ast_package_classes.md#class-maindecl) 节点的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MainDecl](ast_package_classes.md#class-maindecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MainDecl 对象
    let mainDecl = MainDecl()

    // 设置 MainDecl 的属性
    mainDecl.keyword = quote(main)[0]
    mainDecl.colon = Token(TokenKind.COLON)
    mainDecl.declType = PrimitiveType(quote(Unit))
    mainDecl.funcParams = ArrayList<FuncParam>()
    mainDecl.lParen = Token(TokenKind.LPAREN)
    mainDecl.rParen = Token(TokenKind.RPAREN)

    // 设置代码块
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL)
    block.rBrace = Token(TokenKind.RCURL)
    mainDecl.block = block

    // 转化为 Tokens 并输出
    println("mainDecl.toTokens(): ${mainDecl.toTokens()}")
}
```

运行结果：

```text
mainDecl.toTokens(): main(): Unit {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MainDecl](ast_package_classes.md#class-maindecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MainDecl](ast_package_classes.md#class-maindecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MainDecl](ast_package_classes.md#class-maindecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MainDecl 对象
    let mainDecl = MainDecl(quote(main() { println("Hello World") }))

    // 转化为 Tokens 并输出
    println("mainDecl.toTokens(): ${mainDecl.toTokens()}")
}
```

运行结果：

```text
mainDecl.toTokens(): main() {
    println("Hello World")
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 MainDecl 对象
    let mainDecl = MainDecl(quote(main() { println("Hello World") }))

    // 通过toTokens()将实例输出
    println("mainDecl.toTokens(): ${mainDecl.toTokens()}")
}
```

运行结果：

```text
mainDecl.toTokens(): main() {
    println("Hello World")
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MainDecl) {
        println("Visiting MainDecl")
    }
}

main(): Unit {
    // 从 Tokens 创建 MainDecl 对象
    let mainDecl = MainDecl(quote(main() { println("Hello World") }))

    // 使用自定义访问器遍历 MainDecl 节点
    mainDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MainDecl
```

## class MatchCase

```cangjie
public class MatchCase <: Node {
    public init()
}
```

功能：表示 `match` 表达式中的一个 `case` 节点。

一个 [MatchCase](ast_package_classes.md#class-matchcase) 节点：`case failScore where score > 0 => 0`。

> **说明：**
>
> - [MatchCase](ast_package_classes.md#class-matchcase) 以关键字 `case` 开头，后跟 [Expr](ast_package_classes.md#class-expr) 或者一个或多个由 `|` 分隔的相同种类的 `pattern`，一个可选的 `patternguard`，一个 `=>` 和一系列声明或表达式。
> - 该节点与 [MatchExpr](ast_package_classes.md#class-matchexpr) 存在强绑定关系。

父类型：

- [Node](#class-node)

### prop arrow

```cangjie
public mut prop arrow: Token
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中的 `=>` 操作符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `=>` 操作符时，抛出异常。

### prop bitOrs

```cangjie
public mut prop bitOrs: Tokens
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中的 `|` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `|` 词法单元序列时，抛出异常。

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中的一系列声明或表达式节点。

类型：[Block](ast_package_classes.md#class-block)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中位于 case 后的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MatchCase](ast_package_classes.md#class-matchcase) 节点中不存在表达式节点时，抛出异常。

### prop keywordC

```cangjie
public mut prop keywordC: Token
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 内的 `case` 关键字的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `case` 关键字时，抛出异常。

### prop keywordW

```cangjie
public mut prop keywordW: Token
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中可选的关键字 `where` 的词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `where` 关键字时，抛出异常。

### prop patternGuard

```cangjie
public mut prop patternGuard: Expr
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中可选的 pattern guard 表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [MatchCase](ast_package_classes.md#class-matchcase) 节点中不存在 pattern guard 表达式时，抛出异常。

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

功能：获取或设置 [MatchCase](ast_package_classes.md#class-matchcase) 中位于 case 后的 `pattern` 列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MatchCase](ast_package_classes.md#class-matchcase) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MatchCase 对象
    let matchCase = MatchCase()

    // 设置 MatchCase 的属性
    matchCase.keywordC = Token(CASE)
    matchCase.expr = BinaryExpr(quote(a > 1))

    // 设置代码块
    let block = Block()
    block.nodes.add(LitConstExpr(quote(true)))
    matchCase.block = block

    // 转化为 Tokens 并输出
    println("matchCase.toTokens(): ${matchCase.toTokens()}")
}
```

运行结果：

```text
matchCase.toTokens(): case a > 1 => true
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MatchCase 对象
    let matchCase = MatchCase()

    // 设置 MatchCase 的属性
    matchCase.keywordC = Token(CASE)
    matchCase.expr = BinaryExpr(quote(a > 1))

    // 设置代码块
    let block = Block()
    block.nodes.add(LitConstExpr(quote(true)))
    matchCase.block = block

    // 转化为 Tokens 并输出
    println("matchCase.toTokens(): ${matchCase.toTokens()}")
}
```

运行结果：

```text
matchCase.toTokens(): case a > 1 => true
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MatchCase) {
        println("Visiting MatchCase")
    }
}

main(): Unit {
    // 构造一个默认的 MatchCase 对象
    let matchCase = MatchCase()

    // 设置 MatchCase 的属性
    matchCase.keywordC = Token(CASE)
    matchCase.expr = BinaryExpr(quote(a > 1))

    // 设置代码块
    let block = Block()
    block.nodes.add(LitConstExpr(quote(true)))
    matchCase.block = block

    // 使用自定义访问器遍历 MatchCase 节点
    matchCase.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MatchCase
```

## class MatchExpr

```cangjie
public class MatchExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示模式匹配表达式实现模式匹配。

模式匹配表达式分为带 selector 的 `match` 表达式和不带 selector 的 `match` 表达式。

父类型：

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 节点中 `match` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `matcch` 关键字时，抛出异常。

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 之后的 "{"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "{" 时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 之后的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop matchCases

```cangjie
public mut prop matchCases: ArrayList<MatchCase>
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 内的 `matchCase`, `matchCase` 以关键字 `case` 开头，后跟一个或者多个由 [Pattern](ast_package_classes.md#class-pattern) 或 [Expr](ast_package_classes.md#class-expr)节点，具体见 [MatchCase](ast_package_classes.md#class-matchcase)。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[MatchCase](ast_package_classes.md#class-matchcase)>

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 之后的 "}"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "}" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [MatchExpr](ast_package_classes.md#class-matchexpr) 之后的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop selector

```cangjie
public mut prop selector: Expr
```

功能：获取或设置关键字 `match` 之后的 [Expr](ast_package_classes.md#class-expr)。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当该表达式是一个不带 selector 的 `match` 表达式时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MatchExpr](ast_package_classes.md#class-matchexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MatchExpr 对象
    let matchExpr = MatchExpr()

    // 设置 MatchExpr 的属性
    matchExpr.keyword = Token(TokenKind.MATCH)
    matchExpr.lBrace = Token(TokenKind.LCURL)
    matchExpr.rBrace = Token(TokenKind.RCURL)
    matchExpr.lParen = Token(TokenKind.LPAREN)
    matchExpr.rParen = Token(TokenKind.RPAREN)
    matchExpr.matchCases = ArrayList<MatchCase>()
    matchExpr.selector = RefExpr(quote(x))

    let matchCase = MatchCase()
    matchCase.keywordC = Token(CASE)
    matchCase.expr = WildcardExpr()
    let block = Block()
    block.nodes.add(LitConstExpr(quote(true)))
    matchCase.block = block
    matchExpr.matchCases.add(matchCase)

    // 转化为 Tokens 并输出
    println("matchExpr.toTokens(): ${matchExpr.toTokens()}")
}
```

运行结果：

```text
matchExpr.toTokens(): match(x) {
    case _ => true
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MatchExpr](ast_package_classes.md#class-matchexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MatchExpr](ast_package_classes.md#class-matchexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MatchExpr](ast_package_classes.md#class-matchexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MatchExpr 对象
    let matchExpr = MatchExpr(quote(match (x) { case _ => 2 }))

    // 转化为 Tokens 并输出
    println("matchExpr.toTokens(): ${matchExpr.toTokens()}")
}
```

运行结果：

```text
matchExpr.toTokens(): match(x) {
    case _ => 2
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 MatchExpr 对象
    let matchExpr = MatchExpr(quote(match (x) { case _ => 2 }))

    // 调用 toTokens 方法将 MatchExpr 转化为 Tokens
    let tokens = matchExpr.toTokens()

    // 转化为 Tokens 并输出
    println("matchExpr.toTokens(): ${matchExpr.toTokens()}")
}
```

运行结果：

```text
matchExpr.toTokens(): match(x) {
    case _ => 2
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MatchExpr) {
        println("Visiting MatchExpr")
    }
}

main(): Unit {
    // 创建一个 MatchExpr 对象
    let matchExpr = MatchExpr(quote(match (x) { case _ => 2 }))

    // 使用自定义访问器遍历 MatchExpr 节点
    matchExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MatchExpr
```

## class MemberAccess

```cangjie
public class MemberAccess <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示成员访问表达式。

可以用于访问 class、interface、struct 等类型的成员。一个 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点的形式为 `T.a`，`T` 为成员访问表达式的主体，`a` 表示成员的名字。

父类型：

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点的成员访问表达式主体。

类型：[Expr](ast_package_classes.md#class-expr)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop dot

```cangjie
public mut prop dot: Token
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点中的 "."。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "." 词法单元类型时，抛出异常。

### prop field

```cangjie
public mut prop field: Token
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点成员的名字。

类型：[Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点中的左尖括号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点中的右尖括号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

功能：获取或设置 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点中的实例化类型。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [MemberAccess](ast_package_classes.md#class-memberaccess) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 MemberAccess 对象
    let memberAccess = MemberAccess()

    // 设置 MemberAccess 的属性
    memberAccess.baseExpr = RefExpr(quote(obj))
    memberAccess.dot = Token(TokenKind.DOT)
    memberAccess.field = Token(TokenKind.IDENTIFIER, "field")
    memberAccess.commas = quote(,)
    memberAccess.lAngle = Token(TokenKind.LT)
    memberAccess.rAngle = Token(TokenKind.GT)
    memberAccess.typeArguments = ArrayList<TypeNode>()

    // 转化为 Tokens 并输出
    println("memberAccess.toTokens(): ${memberAccess.toTokens()}")
}
```

运行结果：

```text
memberAccess.toTokens(): obj.field
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [MemberAccess](ast_package_classes.md#class-memberaccess) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [MemberAccess](ast_package_classes.md#class-memberaccess) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [MemberAccess](ast_package_classes.md#class-memberaccess) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 MemberAccess 对象
    let memberAccess = MemberAccess(quote(obj.field))

    // 转化为 Tokens 并输出
    println("memberAccess.toTokens(): ${memberAccess.toTokens()}")
}
```

运行结果：

```text
memberAccess.toTokens(): obj.field
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 MemberAccess 对象
    let memberAccess = MemberAccess(quote(obj.field))

    // 转化为 Tokens 并输出
    println("memberAccess.toTokens(): ${memberAccess.toTokens()}")
}
```

运行结果：

```text
memberAccess.toTokens(): obj.field
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MemberAccess) {
        println("Visiting MemberAccess")
    }
}

main(): Unit {
    // 创建一个 MemberAccess 对象
    let memberAccess = MemberAccess(quote(obj.field))

    // 使用自定义访问器遍历 MemberAccess 节点
    memberAccess.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MemberAccess
```

## class Modifier

```cangjie
public class Modifier <: Node {
    public init(keyword: Token)
    public init()
}
```

功能：表示该定义具备某些特性，通常放在定义处的最前端。

一个 [Modifier](ast_package_classes.md#class-modifier) 节点：`public func foo()` 中的 `public`。

父类型：

- [Node](#class-node)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [Modifier](ast_package_classes.md#class-modifier) 节点中的修饰符词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Modifier](ast_package_classes.md#class-modifier) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Modifier 对象
    let modifier = Modifier()

    // 设置 Modifier 的属性
    modifier.keyword = Token(TokenKind.PUBLIC, "public")

    // 转化为 Tokens 并输出
    println("modifier.toTokens(): ${modifier.toTokens()}")
}
```

运行结果：

```text
modifier.toTokens(): public
```

### init(Token)

```cangjie
public init(keyword: Token)
```

功能：构造一个 [Modifier](ast_package_classes.md#class-modifier) 对象。

参数：

- keyword: [Token](ast_package_structs.md#struct-token) - 将要构造 [Modifier](ast_package_classes.md#class-modifier) 类型的词法单元。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 Token 构造 Modifier 对象
    let modifier = Modifier(Token(TokenKind.PUBLIC, "public"))

    // 转化为 Tokens 并输出
    println("modifier.toTokens(): ${modifier.toTokens()}")
}
```

运行结果：

```text
modifier.toTokens(): public
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 Modifier 对象
    let token = Token(TokenKind.PUBLIC, "public")
    let modifier = Modifier(token)

    // 转化为 Tokens 并输出
    println("modifier.toTokens(): ${modifier.toTokens()}")
}
```

运行结果：

```text
modifier.toTokens(): public
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Modifier) {
        println("Visiting Modifier")
    }
}

main(): Unit {
    // 创建一个 Modifier 对象
    let modifier = Modifier(Token(TokenKind.PUBLIC, "public"))

    // 使用自定义访问器遍历 Modifier 节点
    modifier.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Modifier
```

## class Node

```cangjie
sealed abstract class Node <: ToTokens {}
```

功能：所有仓颉语法树节点的父类。

该类提供了所有数据类型通用的操作接口。

父类型：

- [ToTokens](ast_package_interfaces.md#interface-totokens)

### prop beginPos

```cangjie
public mut prop beginPos: Position
```

功能：获取或设置当前节点的起始的位置信息。

类型：[Position](ast_package_structs.md#struct-position)

### prop endPos

```cangjie
public mut prop endPos: Position
```

功能：获取或设置当前节点的终止的位置信息。

类型：[Position](ast_package_structs.md#struct-position)

### func dump()

```cangjie
public func dump(): Unit
```

功能：将当前语法树节点转化为树形结构的形态并进行打印。

语法树节点的树形结构将按照以下形式进行输出：

- `-` 字符串：表示当前节点的公共属性， 如 `-keyword` , `-identifier`。
- 节点属性后紧跟该节点的具体类型， 如 `-declType: PrimitiveType` 表示节点类型是一个 [PrimitiveType](ast_package_classes.md#class-primitivetype) 节点。
- 每个类型使用大括号表示类型的作用区间。

语法树输出的详细格式请参见[语法树节点打印](../ast_samples/dump.md)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 Node 子类对象 (使用 IfExpr 作为示例)
    let ifExpr = IfExpr()

    // 设置 IfExpr 的条件
    ifExpr.condition = LitConstExpr(quote(true))
    ifExpr.keywordI = Token(TokenKind.IF)

    // 设置代码块
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL)
    block.rBrace = Token(TokenKind.RCURL)
    ifExpr.ifBlock = block

    // 调用 dump 方法输出节点信息
    ifExpr.dump()
}
```

运行结果：

```text
IfExpr {
  -keywordI: Token {
    value: "if"
    kind: IF
    pos: 9: 23
  }
  -condition: LitConstExpr {
    -literal: Token {
      value: "true"
      kind: BOOL_LITERAL
      pos: 8: 43
    }
  }
  -ifBlock: Block {
  }
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 Node 子类对象 (使用 IfExpr 作为示例)
    let node = IfExpr(quote(if (x > 0) { x = x + 1 } else { x = x - 1 }))

    // 输出 Tokens 信息
    println("node.toTokens(): ${node.toTokens()}")
}
```

运行结果：

```text
node.toTokens(): if(x > 0) {
    x = x + 1
}
else {
    x = x - 1
}
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Node) {
        breakTraverse()
        println("Visiting Node")
    }
}

main(): Unit {
    // 创建 Node 节点（以 ClassDecl 为例）
    let node = ClassDecl(quote(class A {}))

    // 使用自定义访问器遍历 Node 节点
    node.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Node
```

## class OptionalExpr

```cangjie
public class OptionalExpr <: Expr {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示一个带有问号操作符的表达式节点。

一个 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 节点：`a?.b, a?(b), a?[b]` 中的 `a?`。

父类型：

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

功能：获取或设置 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop quest

```cangjie
public mut prop quest: Token
```

功能：获取或设置 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 中的问号操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是问号操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 OptionalExpr 对象
    let optionalExpr = OptionalExpr()

    // 设置 OptionalExpr 的属性
    optionalExpr.baseExpr = RefExpr(quote(a))
    optionalExpr.quest = Token(TokenKind.QUEST)

    // 转化为 Tokens 并输出
    println("optionalExpr.toTokens(): ${optionalExpr.toTokens()}")
}
```

运行结果：

```text
optionalExpr.toTokens(): a?
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [OptionalExpr](ast_package_classes.md#class-optionalexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 OptionalExpr 对象
    let optionalExpr = OptionalExpr(quote(a?))

    // 转化为 Tokens 并输出
    println("optionalExpr.toTokens(): ${optionalExpr.toTokens()}")
}
```

运行结果：

```text
optionalExpr.toTokens(): a?
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 OptionalExpr 对象
    let optionalExpr = OptionalExpr(quote(a?))

    // 转化为 Tokens 并输出
    println("optionalExpr.toTokens(): ${optionalExpr.toTokens()}")
}
```

运行结果：

```text
optionalExpr.toTokens(): a?
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: OptionalExpr) {
        println("Visiting OptionalExpr")
    }
}

main(): Unit {
    // 创建一个 OptionalExpr 对象
    let optionalExpr = OptionalExpr(quote(a?))

    // 使用自定义访问器遍历 OptionalExpr 节点
    optionalExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting OptionalExpr
```

## class PackageHeader

```cangjie
public class PackageHeader <: Node {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示包声明节点。

一个 [PackageHeader](ast_package_classes.md#class-packageheader) 节点: `package define` 或者 `macro package define`。

> **说明：**
>
> 包声明以关键字 `package` 或 `macro package` 开头，后面紧跟包名，且包声明必须在源文件的首行。

父类型：

- [Node](#class-node)

### prop accessible

```cangjie
public mut prop accessible: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中的访问性修饰符的词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### prop keywordM

```cangjie
public mut prop keywordM: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中的 `macro` 关键字的词法单元（`M` 为关键字首字母，下同），可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `macro` 关键字时，抛出异常。

### prop keywordP

```cangjie
public mut prop keywordP: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中的 `package` 关键字的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `package` 关键字时，抛出异常。

### prop orgName

```cangjie
public mut prop orgName: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中代表组织名的词法单元，setter 会检查 orgSeparator 是否为 "::" 词法单元，若为空则同时设置其为 "::" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 内容为空字符串时抛出异常。

### prop orgSeparator

```cangjie
public mut prop orgSeparator: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中的 "::" 词法单元，setter 会检查 orgName 内容是否为空字符串，若有则抛异常。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "::" 时，或 orgName 内容为空字符串时抛出异常。

### prop packageIdentifier

```cangjie
public mut prop packageIdentifier: Token
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中当前包的名字，如果当前包为 root 包，即为完整包名，若当前包为子包，则为最后一个 "." 后的名字。

类型：[Token](ast_package_structs.md#struct-token)

### prop prefixDots

```cangjie
public mut prop prefixDots: Tokens
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中完整包名中用于分隔每层子包的词法单元序列，可能为空。如 `package a.b.c` 中的两个 "."。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "." 词法单元序列时，抛出异常。

### prop prefixPaths

```cangjie
public mut prop prefixPaths: Tokens
```

功能：获取或设置 [PackageHeader](ast_package_classes.md#class-packageheader) 节点中完整包名的前缀部分的词法单元序列，可能为空。如 `package a.b.c` 中的 `a` 和 `b`。

类型：[Tokens](ast_package_classes.md#class-tokens)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PackageHeader](ast_package_classes.md#class-packageheader) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PackageHeader 对象
    let packageHeader = PackageHeader()

    // 设置 PackageHeader 的属性
    packageHeader.keywordP = Token(TokenKind.PACKAGE)
    packageHeader.packageIdentifier = Token(TokenKind.IDENTIFIER, "myPackage")
    packageHeader.accessible = Token(TokenKind.PUBLIC)

    // 转化为 Tokens 并输出
    println("packageHeader.toTokens(): ${packageHeader.toTokens()}")
}
```

运行结果：

```text
packageHeader.toTokens(): package myPackage
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [PackageHeader](ast_package_classes.md#class-packageheader) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PackageHeader](ast_package_classes.md#class-packageheader) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens)) 序列。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PackageHeader](ast_package_classes.md#class-packageheader) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 PackageHeader 对象
    let packageHeader = PackageHeader(quote(package myPackage))

    // 转化为 Tokens 并输出
    println("packageHeader.toTokens(): ${packageHeader.toTokens()}")
}
```

运行结果：

```text
packageHeader.toTokens(): package myPackage
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 PackageHeader 对象
    let packageHeader = PackageHeader(quote(package myPackage))

    // 转化为 Tokens 并输出
    println("packageHeader.toTokens(): ${packageHeader.toTokens()}")
}
```

运行结果：

```text
packageHeader.toTokens(): package myPackage
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PackageHeader) {
        println("Visiting PackageHeader")
    }
}

main(): Unit {
    // 创建一个 PackageHeader 对象
    let packageHeader = PackageHeader(quote(package myPackage))

    // 使用自定义访问器遍历 PackageHeader 节点
    packageHeader.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PackageHeader
```

## class ParenExpr

```cangjie
public class ParenExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个括号表达式节点，是指使用圆括号括起来的表达式。

一个 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点：`(1 + 2)`。

父类型：

- [Expr](#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop parenthesizedExpr

```cangjie
public mut prop parenthesizedExpr: Expr
```

功能：获取或设置 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点中由圆括号括起来的子表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ParenExpr](ast_package_classes.md#class-parenexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ParenExpr 对象
    let parenExpr = ParenExpr()

    // 设置 ParenExpr 的属性
    parenExpr.lParen = Token(TokenKind.LPAREN)
    parenExpr.parenthesizedExpr = LitConstExpr(quote(1))
    parenExpr.rParen = Token(TokenKind.RPAREN)

    // 转化为 Tokens 并输出
    println("parenExpr.toTokens(): ${parenExpr.toTokens()}")
}
```

运行结果：

```text
parenExpr.toTokens(): (1)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ParenExpr](ast_package_classes.md#class-parenexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ParenExpr](ast_package_classes.md#class-parenexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ParenExpr](ast_package_classes.md#class-parenexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ParenExpr 对象
    let parenExpr = ParenExpr(quote((1 + 2)))

    // 转化为 Tokens 并输出
    println("parenExpr.toTokens(): ${parenExpr.toTokens()}")
}
```

运行结果：

```text
parenExpr.toTokens(): (1 + 2)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 ParenExpr 对象
    let parenExpr = ParenExpr(quote((1 + 2)))

    // 转化为 Tokens 并输出
    println("parenExpr.toTokens(): ${parenExpr.toTokens()}")
}
```

运行结果：

```text
parenExpr.toTokens(): (1 + 2)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ParenExpr) {
        println("Visiting ParenExpr")
    }
}

main(): Unit {
    // 创建一个 ParenExpr 对象
    let parenExpr = ParenExpr(quote((1 + 2)))

    // 使用自定义访问器遍历 ParenExpr 节点
    parenExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ParenExpr
```

## class ParenType

```cangjie
public class ParenType <: TypeNode {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示括号类型节点。

例如 `var a: (Int64)` 中的 `(Int64)`。

父类型：

- [TypeNode](#class-typenode)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [ParenType](ast_package_classes.md#class-parentype) 节点中的 "(" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop parenthesizedType

```cangjie
public mut prop parenthesizedType: TypeNode
```

功能：获取或设置 [ParenType](ast_package_classes.md#class-parentype) 节点中括起来的类型，如 `(Int64)` 中的 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [ParenType](ast_package_classes.md#class-parentype) 节点中的 ")" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ParenType](ast_package_classes.md#class-parentype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ParenType 对象
    let parenType = ParenType()

    // 设置 ParenType 的属性
    parenType.lParen = Token(TokenKind.LPAREN)
    parenType.parenthesizedType = PrimitiveType(quote(Int8))
    parenType.rParen = Token(TokenKind.RPAREN)

    // 转化为 Tokens 并输出
    println("parenType.toTokens(): ${parenType.toTokens()}")
}
```

运行结果：

```text
parenType.toTokens(): (Int8)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ParenType](ast_package_classes.md#class-parentype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ParenType](ast_package_classes.md#class-parentype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ParenType](ast_package_classes.md#class-parentype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ParenType 对象
    let parenType = ParenType(quote((Int32)))

    // 转化为 Tokens 并输出
    println("parenType.toTokens(): ${parenType.toTokens()}")
}
```

运行结果：

```text
parenType.toTokens(): (Int32)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 ParenType 对象
    let parenType = ParenType(quote((Int32)))

    // 转化为 Tokens 并输出
    println("parenType.toTokens(): ${parenType.toTokens()}")
}
```

运行结果：

```text
parenType.toTokens(): (Int32)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ParenType) {
        println("Visiting ParenType")
    }
}

main(): Unit {
    // 创建一个 ParenType 对象
    let parenType = ParenType(quote((Int32)))

    // 使用自定义访问器遍历 ParenType 节点
    parenType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ParenType
```

## class Pattern

```cangjie
public open class Pattern <: Node {}
```

功能：所有模式匹配节点的父类，继承自 [Node](ast_package_classes.md#class-node) 节点。

父类型：

- [Node](#class-node)

### func dump(UInt16)

```cangjie
protected open func dump(_: UInt16): String
```

功能：将当前语法树节点转化为树形结构的形态并进行打印，需要被子类重写。

参数：

- _: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 格式化输出的缩进空格数量。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 格式化输出内容。

示例：

<!-- verify -->
```cangjie
import std.ast.*

extend VarPattern {
    public func myDump() {
        dump(4)
    }
}

main(): Unit {
    // 创建一个 Pattern 子类对象 (使用 VarPattern 作为示例)
    let pattern = VarPattern(quote(e)[0])

    // 调用 dump 方法输出节点信息
    let result = pattern.myDump()
    println("Pattern dump result: ${result}")
}
```

运行结果：

```text
Pattern dump result: VarPattern {
          -identifier: Token {
            value: "e"
            kind: IDENTIFIER
            pos: 11: 36
          }
        }
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 Pattern 子类对象 (使用 VarPattern 作为示例)
    let pattern = VarPattern(quote(e)[0])

    // 输出 Pattern 节点转化成的 Tokens
    println("pattern.toTokens(): ${pattern.toTokens()}")
}
```

运行结果：

```text
pattern.toTokens(): e
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Pattern) {
        breakTraverse()
        println("Visiting Pattern")
    }
}

main(): Unit {
    // 创建 Pattern 节点（以 VarPattern 为例）
    let pattern = VarPattern(quote(e)[0])

    // 使用自定义访问器遍历 Pattern 节点
    pattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Pattern
```

## class PerformExpr

```cangjie
public class PerformExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个 `perform` 表达式节点。

一个 [PerformExpr](ast_package_classes.md#class-performexpr) 节点示例：`perform Eff()`。

父类型：

- [Expr](ast_package_classes.md#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [PerformExpr](ast_package_classes.md#class-performexpr) 节点中的表达式部分。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [PerformExpr](ast_package_classes.md#class-performexpr) 节点中的 `perform` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当给定的 [Token](ast_package_structs.md#struct-token) 不是 `perform` 关键字时抛出。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PerformExpr](ast_package_classes.md#class-performexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PerformExpr 对象
    let performExpr = PerformExpr()

    // 设置 PerformExpr 的属性
    performExpr.keyword = Token(TokenKind.PERFORM)
    performExpr.expr = CallExpr(quote(Effect()))

    // 转化为 Tokens 并输出
    println("performExpr.toTokens(): ${performExpr.toTokens()}")
}
```

运行结果：

```text
performExpr.toTokens(): perform Effect()
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：从提供的词法单元构造一个 [PerformExpr](ast_package_classes.md#class-performexpr) 对象。

> **注意:**
>
> 编译时需要添加 `--experimental` 和 `--enable-eh` 编译选项以支持 `Effect Handlers` 特性。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) — 要解析为 [PerformExpr](ast_package_classes.md#class-performexpr) 节点的词法单元集合。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当输入的 [Tokens](ast_package_classes.md#class-tokens) 无法解析为 [PerformExpr](ast_package_classes.md#class-performexpr) 节点时，或编译未开启 `Effect Handlers` 实验特性时抛出。

示例：

<!-- verify -->
<!-- cfg="--enable-eh --experimental" -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 PerformExpr 对象
    let performExpr = PerformExpr(quote(perform Effect()))

    // 转化为 Tokens 并输出
    println("performExpr.toTokens(): ${performExpr.toTokens()}")
}
```

运行结果：

```text
performExpr.toTokens(): perform Effect()
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PerformExpr 对象
    let performExpr = PerformExpr()

    // 设置 PerformExpr 的属性
    performExpr.keyword = Token(TokenKind.PERFORM)
    performExpr.expr = CallExpr(quote(Eff()))

    // 转化为 Tokens 并输出
    println("performExpr.toTokens(): ${performExpr.toTokens()}")
}
```

运行结果：

```text
performExpr.toTokens(): perform Eff()
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PerformExpr) {
        println("Visiting PerformExpr")
    }
}

main(): Unit {
    // 构造一个默认的 PerformExpr 对象
    let performExpr = PerformExpr()

    // 设置 PerformExpr 的属性
    performExpr.keyword = Token(TokenKind.PERFORM)
    performExpr.expr = CallExpr(quote(Effect()))

    // 使用自定义访问器遍历 PerformExpr 节点
    performExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PerformExpr
```

## class PrefixType

```cangjie
public class PrefixType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示带问号的前缀类型节点。

例如 `var a : ?A` 中的 `?A`。

父类型：

- [TypeNode](#class-typenode)

### prop baseType

```cangjie
public mut prop baseType: TypeNode
```

功能：获取或设置 [PrefixType](ast_package_classes.md#class-prefixtype) 节点中的类型节点，如 `var a: ?A` 中的 `A`。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop prefixOps

```cangjie
public mut prop prefixOps: Tokens
```

功能：获取或设置 [PrefixType](ast_package_classes.md#class-prefixtype) 节点中前缀操作符集合。

类型：[Tokens](ast_package_classes.md#class-tokens)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PrefixType](ast_package_classes.md#class-prefixtype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PrefixType 对象
    let prefixType = PrefixType()

    // 设置 PrefixType 的属性
    prefixType.prefixOps = quote(?)
    prefixType.baseType = PrimitiveType(quote(Int8))

    // 转化为 Tokens 并输出
    println("prefixType.toTokens(): ${prefixType.toTokens()}")
}
```

运行结果：

```text
prefixType.toTokens(): ?Int8
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [PrefixType](ast_package_classes.md#class-prefixtype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PrefixType](ast_package_classes.md#class-prefixtype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PrefixType](ast_package_classes.md#class-prefixtype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 PrefixType 对象
    let prefixType = PrefixType(quote(?Int32))

    // 转化为 Tokens 并输出
    println("prefixType.toTokens(): ${prefixType.toTokens()}")
}
```

运行结果：

```text
prefixType.toTokens(): ?Int32
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 PrefixType 对象
    let prefixType = PrefixType(quote(?Int32))

    // 转化为 Tokens 并输出
    println("prefixType.toTokens(): ${prefixType.toTokens()}")
}
```

运行结果：

```text
prefixType.toTokens(): ?Int32
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrefixType) {
        println("Visiting PrefixType")
    }
}

main(): Unit {
    // 创建一个 PrefixType 对象
    let prefixType = PrefixType(quote(?Int32))

    // 使用自定义访问器遍历 PrefixType 节点
    prefixType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PrefixType
```

## class PrimaryCtorDecl

```cangjie
public class PrimaryCtorDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个主构造函数节点。

主构造函数节点由修饰符，主构造函数名，形参列表和主构造函数体构成。

父类型：

- [Decl](#class-decl)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 节点的主构造函数体。

类型：[Block](ast_package_classes.md#class-block)

### prop funcParams

```cangjie
public mut prop funcParams: ArrayList<FuncParam>
```

功能：获取或设置 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 节点的参数。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[FuncParam](ast_package_classes.md#class-funcparam)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 节点的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 节点的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl()

    // 设置 PrimaryCtorDecl 的属性
    primaryCtorDecl.identifier = quote(Ctor)[0]
    primaryCtorDecl.lParen = Token(TokenKind.LPAREN)
    primaryCtorDecl.rParen = Token(TokenKind.RPAREN)

    // 设置参数
    let param1 = FuncParam(quote(x: Int8))
    primaryCtorDecl.funcParams = ArrayList<FuncParam>([param1])

    // 设置代码块
    let block = Block()
    block.lBrace = Token(TokenKind.LCURL)
    block.rBrace = Token(TokenKind.RCURL)
    primaryCtorDecl.block = block

    // 转化为 Tokens 并输出
    println("primaryCtorDecl.toTokens(): ${primaryCtorDecl.toTokens()}")
}
```

运行结果：

```text
primaryCtorDecl.toTokens(): Ctor(x: Int8) {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl(quote(Ctor(x: Int8) { super(x) }))

    // 转化为 Tokens 并输出
    println("primaryCtorDecl.toTokens(): ${primaryCtorDecl.toTokens()}")
}
```

运行结果：

```text
primaryCtorDecl.toTokens(): Ctor(x: Int8) {
    super(x)
}
```

### func isConst()

```cangjie
public func isConst(): Bool
```

功能：判断是否是一个 `Const` 类型的节点。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 当前节点为 `Const` 类型的节点时，返回 true；反之，返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl()

    println("primaryCtorDecl.isConst(): ${primaryCtorDecl.isConst()}")
}
```

运行结果：

```text
primaryCtorDecl.isConst(): false
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl(quote(Ctor(x: Int8) { super(x) }))

    // 转化为 Tokens 并输出
    println("primaryCtorDecl.toTokens(): ${primaryCtorDecl.toTokens()}")
}
```

运行结果：

```text
primaryCtorDecl.toTokens(): Ctor(x: Int8) {
    super(x)
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimaryCtorDecl) {
        println("Visiting PrimaryCtorDecl")
    }
}

main(): Unit {
    // 创建一个 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl(quote(Ctor(x: Int8) { super(x) }))

    // 使用自定义访问器遍历 PrimaryCtorDecl 节点
    primaryCtorDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PrimaryCtorDecl
```

## class PrimitiveType

```cangjie
public class PrimitiveType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个基本类型节点。

例如数值类型，[Rune](../../core/core_package_api/core_package_intrinsics.md#rune) 类型，布尔类型等。

父类型：

- [TypeNode](#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置构造 [PrimitiveType](ast_package_classes.md#class-primitivetype) 类型的关键字，如 [Int8](../../core/core_package_api/core_package_intrinsics.md#int8)。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PrimitiveType](ast_package_classes.md#class-primitivetype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PrimitiveType 对象
    let primitiveType = PrimitiveType()

    // 设置 PrimitiveType 的属性
    primitiveType.keyword = Token(TokenKind.INT8, "Int8")

    // 输出 PrimitiveType 节点转化成的 Tokens
    println("primitiveType.toTokens(): ${primitiveType.toTokens()}")
}
```

运行结果：

```text
primitiveType.toTokens(): Int8
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [PrimitiveType](ast_package_classes.md#class-primitivetype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PrimitiveType](ast_package_classes.md#class-primitivetype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PrimitiveType](ast_package_classes.md#class-primitivetype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 quote 宏创建 Tokens
    let tokens = quote(Int8)

    // 使用 Tokens 构造 PrimitiveType 对象
    let primitiveType = PrimitiveType(tokens)

    // 输出 PrimitiveType 节点转化成的 Tokens
    println("primitiveType.toTokens(): ${primitiveType.toTokens()}")
}
```

运行结果：

```text
primitiveType.toTokens(): Int8
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 PrimitiveType 对象
    let primitiveType = PrimitiveType(quote(Int8))

    // 输出 PrimitiveType 节点转化成的 Tokens
    println("primitiveType.toTokens(): ${primitiveType.toTokens()}")
}
```

运行结果：

```text
primitiveType.toTokens(): Int8
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimitiveType) {
        println("Visiting PrimitiveType")
    }
}

main(): Unit {
    // 创建一个 PrimitiveType 对象
    let primitiveType = PrimitiveType(quote(Int8))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrimitiveType 节点
    primitiveType.traverse(visitor)
}
```

运行结果：

```text
Visiting PrimitiveType
```

## class PrimitiveTypeExpr

```cangjie
public class PrimitiveTypeExpr <: Expr {
    public init(kind: Tokens)
    public init()
}
```

功能：表示基本类型表达式节点。

[PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 节点：编译器内置的基本类型作为表达式出现在节点中。如 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64).toSting() 中的 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)。

父类型：

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 中的基本类型关键字。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PrimitiveTypeExpr 对象
    let primitiveTypeExpr = PrimitiveTypeExpr()

    // 设置 PrimitiveTypeExpr 的属性
    primitiveTypeExpr.keyword = Token(TokenKind.INT8, "Int8")

    // 输出 PrimitiveTypeExpr 节点转化成的 Tokens
    println("primitiveTypeExpr.toTokens(): ${primitiveTypeExpr.toTokens()}")
}
```

运行结果：

```text
primitiveTypeExpr.toTokens(): Int8
```

### init(Tokens)

```cangjie
public init(kind: Tokens)
```

功能：构造一个 [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 对象。

参数：

- kind: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 quote 宏创建 Tokens
    let tokens = quote(Int8)

    // 使用 Tokens 构造 PrimitiveTypeExpr 对象
    let primitiveTypeExpr = PrimitiveTypeExpr(tokens)

    // 输出 PrimitiveTypeExpr 节点转化成的 Tokens
    println("primitiveTypeExpr.toTokens(): ${primitiveTypeExpr.toTokens()}")
}
```

运行结果：

```text
primitiveTypeExpr.toTokens(): Int8
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 PrimitiveTypeExpr 对象
    let primitiveTypeExpr = PrimitiveTypeExpr(quote(Int8))

    // 输出 PrimitiveTypeExpr 节点转化成的 Tokens
    println("primitiveTypeExpr.toTokens(): ${primitiveTypeExpr.toTokens()}")
}
```

运行结果：

```text
primitiveTypeExpr.toTokens(): Int8
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimitiveTypeExpr) {
        println("Visiting PrimitiveTypeExpr")
    }
}

main(): Unit {
    // 创建一个 PrimitiveTypeExpr 对象
    let primitiveTypeExpr = PrimitiveTypeExpr(quote(Int8))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrimitiveTypeExpr 节点
    primitiveTypeExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting PrimitiveTypeExpr
```

## class Program

```cangjie
public class Program <: Node {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个仓颉源码文件节点。

一个仓颉源码文件节点主要包括包定义节点，包导入节点和 TopLevel 作用域内的所有声明节点。

> **说明：**
>
> 任何一个仓颉源码文件都可以被解析为一个 [Program](ast_package_classes.md#class-program) 类型。

父类型：

- [Node](#class-node)

### prop decls

```cangjie
public mut prop decls: ArrayList<Decl>
```

功能：获取或设置仓颉源码文件中 TopLevel 作用域内定义的声明节点列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Decl](ast_package_classes.md#class-decl)>

### prop featuresDirective

```cangjie
public mut prop featuresDirective: Option<FeaturesDirective>
```

功能：获取或设置仓颉源码文件中 `TopLevel` 作用域内定义的 `features` 声明节点。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[FeaturesDirective](ast_package_classes.md#class-featuresdirective)>

### prop importLists

```cangjie
public mut prop importLists: ArrayList<ImportList>
```

功能：获取或设置仓颉源码文件中包导入节点 [ImportList](ast_package_classes.md#class-importlist) 的列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[ImportList](ast_package_classes.md#class-importlist)>

### prop packageHeader

```cangjie
public mut prop packageHeader: PackageHeader
```

功能：获取或设置仓颉源码文件中包的声明节点 [PackageHeader](ast_package_classes.md#class-packageheader)。

类型：[PackageHeader](ast_package_classes.md#class-packageheader)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Program](ast_package_classes.md#class-program) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 Program 对象
    let program = Program()

    // 设置 Program 的属性
    program.packageHeader = PackageHeader(quote(package test))
    program.importLists = ArrayList<ImportList>()
    program.decls = ArrayList<Decl>()

    // 转化为 Tokens 并输出
    println("program.toTokens(): ${program.toTokens()}")
}
```

运行结果：

```text
program.toTokens(): package test
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [Program](ast_package_classes.md#class-program) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [Program](ast_package_classes.md#class-program) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens)) 序列。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为一个文件节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 Program 对象
    let program = Program(quote(let a = 1))

    // 转化为 Tokens 并输出
    println("program.toTokens(): ${program.toTokens()}")
}
```

运行结果：

```text
program.toTokens(): let a = 1
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 Program 对象
    let program = Program(quote(let a = 1))

    // 转化为 Tokens 并输出
    println("program.toTokens(): ${program.toTokens()}")
}
```

运行结果：

```text
program.toTokens(): let a = 1
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Program) {
        println("Visiting Program")
    }
}

main(): Unit {
    // 创建一个 Program 对象
    let program = Program(quote(let a = 1))

    // 使用自定义访问器遍历 Program 节点
    program.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Program
```

## class PropDecl

```cangjie
public class PropDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个属性定义节点。

一个 [PropDecl](ast_package_classes.md#class-propdecl) 节点：`prop X: Int64 { get() { 0 } }`。

父类型：

- [Decl](#class-decl)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的冒号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是冒号时，抛出异常。

### prop declType

```cangjie
public mut prop declType : TypeNode
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的返回类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop getter

```cangjie
public mut prop getter: FuncDecl
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的 getter 函数。

类型：[FuncDecl](ast_package_classes.md#class-funcdecl)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [PropDecl](ast_package_classes.md#class-propdecl) 节点不存在 getter 函数时，抛出异常。

### prop lBrace

```cangjie
public mut prop lBrace: Token
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的 "{"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "{" 时，抛出异常。

### prop rBrace

```cangjie
public mut prop rBrace: Token
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的 "}"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "}" 时，抛出异常。

### prop setter

```cangjie
public mut prop setter: FuncDecl
```

功能：获取或设置 [PropDecl](ast_package_classes.md#class-propdecl) 节点的 setter 函数。

类型：[FuncDecl](ast_package_classes.md#class-funcdecl)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [PropDecl](ast_package_classes.md#class-propdecl) 节点不存在 setter 函数时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [PropDecl](ast_package_classes.md#class-propdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 PropDecl 对象
    let propDecl = PropDecl()

    // 设置 PropDecl 的属性
    propDecl.keyword = quote(prop)[0]
    propDecl.identifier = quote(testProp)[0]
    propDecl.colon = Token(TokenKind.COLON)
    propDecl.declType = PrimitiveType(quote(Int8))

    propDecl.lBrace = Token(TokenKind.LCURL)
    propDecl.rBrace = Token(TokenKind.RCURL)

    // 转化为 Tokens 并输出
    println("propDecl.toTokens(): ${propDecl.toTokens()}")
}
```

运行结果：

```text
propDecl.toTokens(): prop testProp: Int8 {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [PropDecl](ast_package_classes.md#class-propdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [PropDecl](ast_package_classes.md#class-propdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [PropDecl](ast_package_classes.md#class-propdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 PropDecl 对象
    let propDecl = PropDecl(quote(prop x: Int32 { get() { 0 } }))

    // 转化为 Tokens 并输出
    println("propDecl.toTokens(): ${propDecl.toTokens()}")
}
```

运行结果：

```text
propDecl.toTokens(): prop x: Int32 {
    get() {
        0
    }
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 PropDecl 对象
    let propDecl = PropDecl(quote(prop x: Int32 { get() { 0 } }))

    // 转化为 Tokens 并输出
    println("propDecl.toTokens(): ${propDecl.toTokens()}")
}
```

运行结果：

```text
propDecl.toTokens(): prop x: Int32 {
    get() {
        0
    }
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PropDecl) {
        println("Visiting PropDecl")
    }
}

main(): Unit {
    // 创建一个 PropDecl 对象
    let propDecl = PropDecl(quote(prop x: Int32 { get() { 0 } }))

    // 使用自定义访问器遍历 PropDecl 节点
    propDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PropDecl
```

## class QualifiedType

```cangjie
public class QualifiedType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个用户自定义成员类型。

例如 `var a : T.a` 中的 `T.a`, 其中 T 是包名，a 是从 T 包中导入的类型。

父类型：

- [TypeNode](#class-typenode)

### prop baseType

```cangjie
public mut prop baseType: TypeNode
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点的成员访问类型主体，如 `var a : T.a` 中的 `T`。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop dot

```cangjie
public mut prop dot: Token
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点中的 "." 。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "." 词法单元时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点成员的标识符，如 `var a : T.a` 中的 `a`。

类型：[Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点中的左尖括号词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点中的右尖括号词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

功能：获取或设置 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点中的实例化类型的列表，如 `T.a<Int32>` 中的 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32)，列表可能为空。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 QualifiedType 对象
    let qualifiedType = QualifiedType()

    // 设置 QualifiedType 的属性
    qualifiedType.baseType = RefType(quote(Package))
    qualifiedType.identifier = Token(TokenKind.IDENTIFIER, "Type")
    qualifiedType.dot = Token(TokenKind.DOT)
    qualifiedType.commas = quote(,)
    qualifiedType.lAngle = Token(TokenKind.LT)
    qualifiedType.rAngle = Token(TokenKind.GT)
    qualifiedType.typeArguments = ArrayList<TypeNode>()

    // 转化为 Tokens 并输出
    println("qualifiedType.toTokens(): ${qualifiedType.toTokens()}")
}
```

运行结果：

```text
qualifiedType.toTokens(): Package.Type
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [QualifiedType](ast_package_classes.md#class-qualifiedtype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 QualifiedType 对象
    let qualifiedType = QualifiedType(quote(Package.Type))

    // 转化为 Tokens 并输出
    println("qualifiedType.toTokens(): ${qualifiedType.toTokens()}")
}
```

运行结果：

```text
qualifiedType.toTokens(): Package.Type
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 QualifiedType 对象
    let qualifiedType = QualifiedType(quote(Package.Type))

    // 转化为 Tokens 并输出
    println("qualifiedType.toTokens(): ${qualifiedType.toTokens()}")
}
```

运行结果：

```text
qualifiedType.toTokens(): Package.Type
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QualifiedType) {
        println("Visiting QualifiedType")
    }
}

main(): Unit {
    // 创建一个 QualifiedType 对象
    let qualifiedType = QualifiedType(quote(Package.Type))

    // 使用自定义访问器遍历 QualifiedType 节点
    qualifiedType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting QualifiedType
```

## class QuoteExpr

```cangjie
public class QuoteExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `quote` 表达式节点。

一个 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 节点： `quote(var ident = 0)`。

父类型：

- [Expr](#class-expr)

### prop exprs

```cangjie
public mut prop exprs: ArrayList<Expr>
```

功能：获取或设置 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 中由 `()` 括起的内部引用表达式节点。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 的 `quote` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `quote` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 QuoteExpr 对象
    let quoteExpr = QuoteExpr()

    // 设置 QuoteExpr 的属性
    quoteExpr.keyword = Token(TokenKind.QUOTE)
    quoteExpr.lParen = Token(TokenKind.LPAREN)
    quoteExpr.rParen = Token(TokenKind.RPAREN)
    quoteExpr.exprs = ArrayList<Expr>()

    // 转化为 Tokens 并输出
    println("quoteExpr.toTokens(): ${quoteExpr.toTokens()}")
}
```

运行结果：

```text
quoteExpr.toTokens(): quote()
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [QuoteExpr](ast_package_classes.md#class-quoteexpr) 节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 QuoteExpr 对象
    let quoteExpr = QuoteExpr(quote(quote(x + 1)))

    // 转化为 Tokens 并输出
    println("quoteExpr.toTokens(): ${quoteExpr.toTokens()}")
}
```

运行结果：

```text
quoteExpr.toTokens(): quote(x + 1)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个带实际值的 QuoteExpr 对象
    let quoteExpr = QuoteExpr(quote(quote(x + 1)))

    // 转化为 Tokens 并输出
    println("quoteExpr.toTokens(): ${quoteExpr.toTokens()}")
}
```

运行结果：

```text
quoteExpr.toTokens(): quote(x + 1)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QuoteExpr) {
        println("Visiting QuoteExpr")
    }
}

main(): Unit {
    // 创建一个 QuoteExpr 对象
    let quoteExpr = QuoteExpr(quote(quote(x + 1)))

    // 使用自定义访问器遍历 QuoteExpr 节点
    quoteExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting QuoteExpr
```

## class QuoteToken

```cangjie
public class QuoteToken <: Expr {}
```

功能：表示 `quote` 表达式节点内任意合法的 `token`。

父类型：

- [Expr](#class-expr)

### prop tokens

```cangjie
public mut prop tokens: Tokens
```

功能：获取 [QuoteToken](ast_package_classes.md#class-quotetoken) 内的 [Tokens](ast_package_classes.md#class-tokens)。

类型：[Tokens](ast_package_classes.md#class-tokens)

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 使用 quote 宏创建 Tokens
    let tokens = quote(quote(x + 1))

    // 使用 Tokens 构造 QuoteExpr 对象
    let quoteExpr = QuoteExpr(tokens)

    // 获取一个 QuoteToken 对象
    let quoteToken = quoteExpr.exprs[0]

    // 转化为 Tokens 并输出
    println("quoteToken.toTokens(): ${quoteToken.toTokens()}")
}
```

运行结果：

```text
quoteToken.toTokens(): x + 1
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QuoteToken) {
        println("Visiting QuoteToken")
    }
}

main(): Unit {
    // 创建一个 QuoteToken 对象
    let tokens = quote(quote(x + 1))
    let quoteExpr = QuoteExpr(tokens)
    let quoteToken = quoteExpr.exprs[0]

    // 使用自定义访问器遍历 QuoteToken 节点
    quoteToken.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting QuoteToken
```

## class RangeExpr

```cangjie
public class RangeExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示包含区间操作符的表达式。

[RangeExpr](ast_package_classes.md#class-rangeexpr) 节点：存在两种 [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 操作符：`..` 和 `..=`，分别用于创建左闭右开和左闭右闭的 [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 实例。它们的使用方式分别为 `start..end:step` 和 `start..=end:step`。

父类型：

- [Expr](#class-expr)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中的 ":" 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 操作符时，抛出异常。

### prop end

```cangjie
public mut prop end: Expr
```

功能：获取或设置 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中的终止值。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 终止表达式省略。只有在 [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> 类型的实例用在下标操作符 `[]` 为空的场景。

### prop op

```cangjie
public mut prop op: Token
```

功能：获取或设置 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中的 [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet) 的操作符。

类型：[Token](ast_package_structs.md#struct-token)

### prop start

```cangjie
public mut prop start: Expr
```

功能：获取或设置 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中的起始值。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 起始表达式省略。只有在 [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> 类型的实例用在下标操作符 `[]` 为空的场景。

### prop step

```cangjie
public mut prop step: Expr
```

功能：获取或设置 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中序列中前后两个元素之间的差值。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [RangeExpr](ast_package_classes.md#class-rangeexpr) 中未设置序列前后两个元素之间的差值时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [RangeExpr](ast_package_classes.md#class-rangeexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 RangeExpr 对象
    let rangeExpr = RangeExpr()

    // 设置 RangeExpr 的属性
    rangeExpr.start = LitConstExpr(quote(1))
    rangeExpr.end = LitConstExpr(quote(5))
    rangeExpr.op = Token(TokenKind.RANGEOP)

    // 转化为 Tokens 并输出
    println("rangeExpr.toTokens(): ${rangeExpr.toTokens()}")
}
```

运行结果：

```text
rangeExpr.toTokens(): 1 .. 5
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [RangeExpr](ast_package_classes.md#class-rangeexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [RangeExpr](ast_package_classes.md#class-rangeexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [RangeExpr](ast_package_classes.md#class-rangeexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 RangeExpr 对象
    let rangeExpr = RangeExpr(quote(1..5))

    // 转化为 Tokens 并输出
    println("rangeExpr.toTokens(): ${rangeExpr.toTokens()}")
}
```

运行结果：

```text
rangeExpr.toTokens(): 1 .. 5
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let rangeExpr = RangeExpr(quote(2..=10:2))

    // 转化为 Tokens 并输出
    println("rangeExpr.toTokens(): ${rangeExpr.toTokens()}")
}
```

运行结果：

```text
rangeExpr.toTokens(): 2 ..= 10: 2
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RangeExpr) {
        println("Visiting RangeExpr")
    }
}

main(): Unit {
    let rangeExpr = RangeExpr(quote(1..10))

    // 使用自定义访问器遍历 RangeExpr 节点
    rangeExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RangeExpr
```

## class RefExpr

```cangjie
public class RefExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示引用一个声明的表达式节点。

一个 [RefExpr](ast_package_classes.md#class-refexpr) 节点：`var b = a + 1` 中的 `a` 是一个 [RefExpr](ast_package_classes.md#class-refexpr)。

父类型：

- [Expr](#class-expr)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [RefExpr](ast_package_classes.md#class-refexpr) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [RefExpr](ast_package_classes.md#class-refexpr) 节点中的自定义类型的标识符。

类型：[Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [RefExpr](ast_package_classes.md#class-refexpr) 节点中的左尖括号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [RefExpr](ast_package_classes.md#class-refexpr) 节点中的右尖括号。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

功能：获取或设置 [RefExpr](ast_package_classes.md#class-refexpr) 节点中的实例化类型。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [RefExpr](ast_package_classes.md#class-refexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 RefExpr 对象
    let refExpr = RefExpr()

    // 设置 RefExpr 的属性
    refExpr.identifier = Token(TokenKind.IDENTIFIER, "myRef")

    // 转化为 Tokens 并输出
    println("refExpr.toTokens(): ${refExpr.toTokens()}")
}
```

运行结果：

```text
refExpr.toTokens(): myRef
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [RefExpr](ast_package_classes.md#class-refexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [RefExpr](ast_package_classes.md#class-refexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [RefExpr](ast_package_classes.md#class-refexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 RefExpr 对象
    let refExpr = RefExpr(quote(myRef))

    // 转化为 Tokens 并输出
    println("refExpr.toTokens(): ${refExpr.toTokens()}")
}
```

运行结果：

```text
refExpr.toTokens(): myRef
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let refExpr = RefExpr(quote(testRef))

    // 转化为 Tokens 并输出
    println("refExpr.toTokens(): ${refExpr.toTokens()}")
}
```

运行结果：

```text
refExpr.toTokens(): testRef
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RefExpr) {
        println("Visiting RefExpr")
    }
}

main(): Unit {
    let refExpr = RefExpr(quote(myRef))

    // 使用自定义访问器遍历 RefExpr 节点
    refExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RefExpr
```

## class RefType

```cangjie
public class RefType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个非基础类型节点。

例如用户通过 `class`、`struct`、`enum` 等定义的自定义类型，以及 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)、[String](../../core/core_package_api/core_package_structs.md#struct-string) 等内置类型都可以使用 [RefType](ast_package_classes.md#class-reftype) 表示。例如 `var a : A` 中的 `A`。

父类型：

- [TypeNode](#class-typenode)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [RefType](ast_package_classes.md#class-reftype) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置构造 [RefType](ast_package_classes.md#class-reftype) 类型的关键字，如 `var a : A = A()` 中的 `A`。

类型：[Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [RefType](ast_package_classes.md#class-reftype) 节点中的左尖括号词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [RefType](ast_package_classes.md#class-reftype) 节点中的右尖括号词法单元，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### prop typeArguments

```cangjie
public mut prop typeArguments: ArrayList<TypeNode>
```

功能：获取或设置 [RefType](ast_package_classes.md#class-reftype) 节点中的实例化类型的列表，可能为空，如 `var a : Array<Int32>` 中的 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32)。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [RefType](ast_package_classes.md#class-reftype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 RefType 对象
    let refType = RefType()

    // 设置 RefType 的属性
    refType.identifier = Token(TokenKind.IDENTIFIER, "MyType")

    // 转化为 Tokens 并输出
    println("refType.toTokens(): ${refType.toTokens()}")
}
```

运行结果：

```text
refType.toTokens(): MyType
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [RefType](ast_package_classes.md#class-reftype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [RefType](ast_package_classes.md#class-reftype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [RefType](ast_package_classes.md#class-reftype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 RefType 对象
    let refType = RefType(quote(MyType))

    // 转化为 Tokens 并输出
    println("refType.toTokens(): ${refType.toTokens()}")
}
```

运行结果：

```text
refType.toTokens(): MyType
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let refType = RefType(quote(TestType))

    // 转化为 Tokens 并输出
    println("refType.toTokens(): ${refType.toTokens()}")
}
```

运行结果：

```text
refType.toTokens(): TestType
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RefType) {
        println("Visiting RefType")
    }
}

main(): Unit {
    let refType = RefType(quote(MyType))

    // 使用自定义访问器遍历 RefType 节点
    refType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RefType
```

## class ResumeExpr

```cangjie
public class ResumeExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个 `resume` 表达式节点，可选包含 `with` 和 `throwing` 子句。

一个 [ResumeExpr](ast_package_classes.md#class-resumeexpr) 节点示例：
`resume r with 42`。

父类型：

- [Expr](ast_package_classes.md#class-expr)

### prop keywordR

```cangjie
public mut prop keywordR: Token
```

功能：获取或设置 `resume` 关键字的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当提供的 [Token](ast_package_structs.md#struct-token) 不是 `resume` 关键字时抛出。

### prop keywordT

```cangjie
public mut prop keywordT: Option<Token>
```

功能：获取或设置 `throwing` 关键字的词法单元（如果存在）。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)>

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当提供的 [Token](ast_package_structs.md#struct-token) 不是 `throwing` 关键字时抛出。

### prop keywordW

```cangjie
public mut prop keywordW: Option<Token>
```

功能：获取或设置 `with` 关键字的词法单元（如果存在）。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)>

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当提供的 [Token](ast_package_structs.md#struct-token) 不是 `with` 关键字时抛出。

### prop throwingExpr

```cangjie
public mut prop throwingExpr: Option<Expr>
```

功能：获取或设置 `throwing` 关键字之后的表达式。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Expr](ast_package_classes.md#class-expr)>

### prop withExpr

```cangjie
public mut prop withExpr: Option<Expr>
```

功能：获取或设置 `with` 关键字之后的表达式。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Expr](ast_package_classes.md#class-expr)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ResumeExpr](ast_package_classes.md#class-resumeexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ResumeExpr 对象
    let resumeExpr = ResumeExpr()

    // 设置 ResumeExpr 的属性
    resumeExpr.throwingExpr = Some(CallExpr(quote(Exception("Error from effect"))))
    resumeExpr.keywordT = Token(TokenKind.THROWING, "throwing")

    // 转化为 Tokens 并输出
    println("resumeExpr.toTokens(): ${resumeExpr.toTokens()}")
}
```

运行结果：

```text
resumeExpr.toTokens(): resume throwing Exception("Error from effect")
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：从词法单元流构造一个 [ResumeExpr](ast_package_classes.md#class-resumeexpr) 对象。

> **注意:**
>
> 编译时需要添加 `--experimental` 和 `--enable-eh` 编译选项以支持 `Effect Handlers` 特性。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) — 要解析为 [ResumeExpr](ast_package_classes.md#class-resumeexpr) 节点的词法单元集合。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) — 当输入的 [Tokens](ast_package_classes.md#class-tokens) 无法解析为 [ResumeExpr](ast_package_classes.md#class-resumeexpr) 节点时，或编译未开启 `Effect Handlers` 实验特性时抛出。

示例：

<!-- verify -->
<!-- cfg="--enable-eh --experimental" -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ResumeExpr 对象
    let resumeExpr = ResumeExpr(quote(resume throwing Exception("Error from effect")))

    // 转化为 Tokens 并输出
    println("resumeExpr.toTokens(): ${resumeExpr.toTokens()}")
}
```

运行结果：

```text
resumeExpr.toTokens(): resume throwing Exception("Error from effect")
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ResumeExpr 对象
    let resumeExpr = ResumeExpr()

    // 设置 ResumeExpr 的属性
    resumeExpr.throwingExpr = Some(CallExpr(quote(Exception())))
    resumeExpr.keywordT = Token(TokenKind.THROWING, "throwing")

    // 转化为 Tokens 并输出
    println("resumeExpr.toTokens(): ${resumeExpr.toTokens()}")
}
```

运行结果：

```text
resumeExpr.toTokens(): resume throwing Exception()
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ResumeExpr) {
        println("Visiting ResumeExpr")
    }
}

main(): Unit {
    // 构造一个默认的 ResumeExpr 对象
    let resumeExpr = ResumeExpr()

    // 设置 ResumeExpr 的属性
    resumeExpr.throwingExpr = Some(CallExpr(quote(Exception())))
    resumeExpr.keywordT = Token(TokenKind.THROWING, "throwing")

    // 使用自定义访问器遍历 ResumeExpr 节点
    resumeExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ResumeExpr
```

## class ReturnExpr

```cangjie
public class ReturnExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `return` 表达式节点。

一个 [ReturnExpr](ast_package_classes.md#class-returnexpr) 节点：`return 1`。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [ReturnExpr](ast_package_classes.md#class-returnexpr) 节点中的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [ReturnExpr](ast_package_classes.md#class-returnexpr) 节点没有表达式时，抛出异常。

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [ReturnExpr](ast_package_classes.md#class-returnexpr) 节点中的关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `return` 关键字时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ReturnExpr](ast_package_classes.md#class-returnexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ReturnExpr 对象
    let returnExpr = ReturnExpr()

    // 设置 ReturnExpr 的属性
    returnExpr.expr = LitConstExpr(quote(42))

    // 转化为 Tokens 并输出
    println("returnExpr.toTokens(): ${returnExpr.toTokens()}")
}
```

运行结果：

```text
returnExpr.toTokens(): return 42
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ReturnExpr](ast_package_classes.md#class-returnexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ReturnExpr](ast_package_classes.md#class-returnexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ReturnExpr](ast_package_classes.md#class-returnexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ReturnExpr 对象
    let returnExpr = ReturnExpr(quote(return 100))

    // 转化为 Tokens 并输出
    println("returnExpr.toTokens(): ${returnExpr.toTokens()}")
}
```

运行结果：

```text
returnExpr.toTokens(): return 100
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let returnExpr = ReturnExpr(quote(return "hello"))

    // 转化为 Tokens 并输出
    println("returnExpr.toTokens(): ${returnExpr.toTokens()}")
}
```

运行结果：

```text
returnExpr.toTokens(): return "hello"
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ReturnExpr) {
        println("Visiting ReturnExpr")
    }
}

main(): Unit {
    let returnExpr = ReturnExpr(quote(return))

    // 使用自定义访问器遍历 ReturnExpr 节点
    returnExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ReturnExpr
```

## class SpawnExpr

```cangjie
public class SpawnExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `Spawn` 表达式。

一个 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 节点由 `spawn` 关键字和一个不包含形参的闭包组成，例如：`spawn { add(1, 2) }`。

父类型：

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中的 `spawn` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `spawn` 关键字时，抛出异常。

### prop lambdaExpr

```cangjie
public mut prop lambdaExpr: LambdaExpr
```

功能：获取或设置 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中的不含形参的闭包。

类型：[LambdaExpr](ast_package_classes.md#class-lambdaexpr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop threadContext

```cangjie
public mut prop threadContext: Expr
```

功能：获取或设置 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中的线程上下文环境表达式。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 中不含有上下文表达式时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 SpawnExpr 对象
    let spawnExpr = SpawnExpr()

    // 设置 SpawnExpr 的属性
    spawnExpr.lambdaExpr = LambdaExpr(quote({ => println("New thread") }))

    // 转化为 Tokens 并输出
    println("spawnExpr.toTokens(): ${spawnExpr.toTokens()}")
}
```

运行结果：

```text
spawnExpr.toTokens(): spawn { =>
    println("New thread")
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [SpawnExpr](ast_package_classes.md#class-spawnexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 SpawnExpr 对象
    let spawnExpr = SpawnExpr(quote(spawn { add(1, 2) }))

    // 转化为 Tokens 并输出
    println("spawnExpr.toTokens(): ${spawnExpr.toTokens()}")
}
```

运行结果：

```text
spawnExpr.toTokens(): spawn { add(1, 2)
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let spawnExpr = SpawnExpr(quote(spawn { add(1, 2) }))

    // 转化为 Tokens 并输出
    println("spawnExpr.toTokens(): ${spawnExpr.toTokens()}")
}
```

运行结果：

```text
spawnExpr.toTokens(): spawn { add(1, 2)
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SpawnExpr) {
        println("Visiting SpawnExpr")
    }
}

main(): Unit {
    let spawnExpr = SpawnExpr(quote(spawn { add(1, 2) }))

    // 使用自定义访问器遍历 SpawnExpr 节点
    spawnExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SpawnExpr
```

## class StructDecl

```cangjie
public class StructDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个 `Struct` 节点。

Struct 的定义使用 `struct` 关键字，定义依次为：可缺省的修饰符、struct 关键字、struct 名、可选的类型参数、是否指定父接口、可选的泛型约束、struct 体的定义。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public mut prop body: Body
```

功能：获取或设置 [StructDecl](ast_package_classes.md#class-structdecl) 节点的类体。

类型：[Body](ast_package_classes.md#class-body)

### prop superTypeBitAnds

```cangjie
public mut prop superTypeBitAnds: Tokens
```

功能：获取或设置 [StructDecl](ast_package_classes.md#class-structdecl) 节点的父接口声明中的 `&` 操作符的词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 `&` 词法单元序列时，抛出异常。

### prop superTypes

```cangjie
public mut prop superTypes: ArrayList<TypeNode>
```

功能：获取或设置 [StructDecl](ast_package_classes.md#class-structdecl) 节点的父接口。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### prop upperBound

```cangjie
public mut prop upperBound: Token
```

功能：获取或设置 `<:` 操作符。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `<:` 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [StructDecl](ast_package_classes.md#class-structdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 StructDecl 对象
    let structDecl = StructDecl()

    // 设置 StructDecl 的属性
    structDecl.identifier = Token(TokenKind.IDENTIFIER, "Point")
    structDecl.keyword = Token(TokenKind.STRUCT)
    structDecl.body = Body()

    // 转化为 Tokens 并输出
    println("structDecl.toTokens(): ${structDecl.toTokens()}")
}
```

运行结果：

```text
structDecl.toTokens(): struct Point {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [StructDecl](ast_package_classes.md#class-structdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [StructDecl](ast_package_classes.md#class-structdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [StructDecl](ast_package_classes.md#class-structdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 StructDecl 对象
    let structDecl = StructDecl(quote(struct Person { let name: String }))

    // 转化为 Tokens 并输出
    println("structDecl.toTokens(): ${structDecl.toTokens()}")
}
```

运行结果：

```text
structDecl.toTokens(): struct Person {
    let name: String
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let structDecl = StructDecl(quote(struct Data { let value: Int64 }))

    // 转化为 Tokens 并输出
    println("structDecl.toTokens(): ${structDecl.toTokens()}")
}
```

运行结果：

```text
structDecl.toTokens(): struct Data {
    let value: Int64
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: StructDecl) {
        println("Visiting StructDecl")
    }
}

main(): Unit {
    let structDecl = StructDecl(quote(struct Test {}))

    // 使用自定义访问器遍历 StructDecl 节点
    structDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting StructDecl
```

## class SubscriptExpr

```cangjie
public class SubscriptExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示索引访问表达式。

[SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 节点：用于那些支持索引访问的类型（包括 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) 类型和 `Tuple` 类型）通过下标来访问其具体位置的元素，如 `arr[0]`。

父类型：

- [Expr](#class-expr)

### prop baseExpr

```cangjie
public mut prop baseExpr: Expr
```

功能：获取或设置 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 中的表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop indexList

```cangjie
public mut prop indexList: ArrayList<Expr>
```

功能：获取或设置 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 中的索引表达式序列。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lSquare

```cangjie
public mut prop lSquare: Token
```

功能：获取或设置 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 中的 "["。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "[" 时，抛出异常。

### prop rSquare

```cangjie
public mut prop rSquare: Token
```

功能：获取或设置 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 中的 "]"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "]" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 SubscriptExpr 对象
    let subscriptExpr = SubscriptExpr()

    // 设置 SubscriptExpr 的属性
    subscriptExpr.baseExpr = RefExpr(quote(arr))
    subscriptExpr.indexList = ArrayList<Expr>([LitConstExpr(quote(0))])

    // 转化为 Tokens 并输出
    println("subscriptExpr.toTokens(): ${subscriptExpr.toTokens()}")
}
```

运行结果：

```text
subscriptExpr.toTokens(): arr[0]
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 SubscriptExpr 对象
    let subscriptExpr = SubscriptExpr(quote(arr[1]))

    // 转化为 Tokens 并输出
    println("subscriptExpr.toTokens(): ${subscriptExpr.toTokens()}")
}
```

运行结果：

```text
subscriptExpr.toTokens(): arr[1]
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let subscriptExpr = SubscriptExpr(quote(data[2]))

    // 转化为 Tokens 并输出
    println("subscriptExpr.toTokens(): ${subscriptExpr.toTokens()}")
}
```

运行结果：

```text
subscriptExpr.toTokens(): data[2]
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SubscriptExpr) {
        println("Visiting SubscriptExpr")
    }
}

main(): Unit {
    let subscriptExpr = SubscriptExpr(quote(arr[0]))

    // 使用自定义访问器遍历 SubscriptExpr 节点
    subscriptExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SubscriptExpr
```

## class SynchronizedExpr

```cangjie
public class SynchronizedExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `synchronized` 表达式。

一个 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 节点由 `synchronized` 关键字和 `StructuredMutex` 对以及后面的代码块组成, 例如 `synchronized(m) { foo() }`。

父类型：

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 修饰的代码块。

类型：[Block](ast_package_classes.md#class-block)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 中的 `synchronized` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `synchronized` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop structuredMutex

```cangjie
public mut prop structuredMutex: Expr
```

功能：获取或设置 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 中的 `StructuredMutex` 的对象。

类型：[Expr](ast_package_classes.md#class-expr)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 SynchronizedExpr 对象
    let synchronizedExpr = SynchronizedExpr()

    // 设置 SynchronizedExpr 的属性
    synchronizedExpr.structuredMutex = RefExpr(quote(lock))

    let block = Block()
    block.lBrace = Token(TokenKind.LCURL)
    block.rBrace = Token(TokenKind.RCURL)
    synchronizedExpr.block = block

    // 转化为 Tokens 并输出
    println("synchronizedExpr.toTokens(): ${synchronizedExpr.toTokens()}")
}
```

运行结果：

```text
synchronizedExpr.toTokens(): synchronized(lock) {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 SynchronizedExpr 对象
    let synchronizedExpr = SynchronizedExpr(quote(synchronized(mutex) { }))

    // 转化为 Tokens 并输出
    println("synchronizedExpr.toTokens(): ${synchronizedExpr.toTokens()}")
}
```

运行结果：

```text
synchronizedExpr.toTokens(): synchronized(mutex) {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let synchronizedExpr = SynchronizedExpr(quote(synchronized(obj) { }))

    // 转化为 Tokens 并输出
    println("synchronizedExpr.toTokens(): ${synchronizedExpr.toTokens()}")
}
```

运行结果：

```text
synchronizedExpr.toTokens(): synchronized(obj) {
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SynchronizedExpr) {
        println("Visiting SynchronizedExpr")
    }
}

main(): Unit {
    let synchronizedExpr = SynchronizedExpr(quote(synchronized(lock) { }))

    // 使用自定义访问器遍历 SynchronizedExpr 节点
    synchronizedExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SynchronizedExpr
```

## class ThisType

```cangjie
public class ThisType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `This` 类型节点。

父类型：

- [TypeNode](#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [ThisType](ast_package_classes.md#class-thistype) 节点关键字 `This` 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ThisType](ast_package_classes.md#class-thistype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ThisType 对象
    let thisType = ThisType()

    // 转化为 Tokens 并输出
    println("thisType.toTokens(): ${thisType.toTokens()}")
}
```

运行结果：

```text
thisType.toTokens(): This
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ThisType](ast_package_classes.md#class-thistype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ThisType](ast_package_classes.md#class-thistype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ThisType](ast_package_classes.md#class-thistype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ThisType 对象
    let thisType = ThisType(quote(This))

    // 转化为 Tokens 并输出
    println("thisType.toTokens(): ${thisType.toTokens()}")
}
```

运行结果：

```text
thisType.toTokens(): This
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let thisType = ThisType(quote(This))

    // 转化为 Tokens 并输出
    println("thisType.toTokens(): ${thisType.toTokens()}")
}
```

运行结果：

```text
thisType.toTokens(): This
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ThisType) {
        println("Visiting ThisType")
    }
}

main(): Unit {
    let thisType = ThisType(quote(This))

    // 使用自定义访问器遍历 ThisType 节点
    thisType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ThisType
```

## class ThrowExpr

```cangjie
public class ThrowExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `throw` 表达式节点。

一个 [ThrowExpr](ast_package_classes.md#class-throwexpr) 节点：`throw Exception()`。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [ThrowExpr](ast_package_classes.md#class-throwexpr) 节点中的表达式节点。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [ThrowExpr](ast_package_classes.md#class-throwexpr) 节点中的关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `throw` 关键字时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [ThrowExpr](ast_package_classes.md#class-throwexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 ThrowExpr 对象
    let throwExpr = ThrowExpr()

    // 设置 ThrowExpr 的属性
    throwExpr.expr = CallExpr(quote(Exception("Error message")))

    // 转化为 Tokens 并输出
    println("throwExpr.toTokens(): ${throwExpr.toTokens()}")
}
```

运行结果：

```text
throwExpr.toTokens(): throw Exception("Error message")
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [ThrowExpr](ast_package_classes.md#class-throwexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [ThrowExpr](ast_package_classes.md#class-throwexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [ThrowExpr](ast_package_classes.md#class-throwexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 ThrowExpr 对象
    let throwExpr = ThrowExpr(quote(throw Exception("Error message")))

    // 转化为 Tokens 并输出
    println("throwExpr.toTokens(): ${throwExpr.toTokens()}")
}
```

运行结果：

```text
throwExpr.toTokens(): throw Exception("Error message")
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let throwExpr = ThrowExpr(quote(throw Exception("Error message")))

    // 转化为 Tokens 并输出
    println("throwExpr.toTokens(): ${throwExpr.toTokens()}")
}
```

运行结果：

```text
throwExpr.toTokens(): throw Exception("Error message")
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ThrowExpr) {
        println("Visiting ThrowExpr")
    }
}

main(): Unit {
    let throwExpr = ThrowExpr(quote(throw Exception("Error message")))

    // 使用自定义访问器遍历 ThrowExpr 节点
    throwExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ThrowExpr
```

## class Tokens

```cangjie
public open class Tokens <: ToString & Iterable<Token> & ToBytes {
    protected var tokens: ArrayList<Token> = ArrayList<Token>(0)
    public init()
    public init(tokArray: Array<Token>)
    public init(tokArrayList: ArrayList<Token>)
}
```

功能：对 [Token](ast_package_structs.md#struct-token) 序列进行封装的类型。

父类型：

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Iterable](../../core/core_package_api/core_package_interfaces.md#interface-iterablee)\<[Token](ast_package_structs.md#struct-token)>
- [ToBytes](ast_package_interfaces.md#interface-tobytes)

### var tokens

```cangjie
protected var tokens: ArrayList<Token> = ArrayList<Token>(0)
```

功能：获取或设置内部以[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)>格式存储的全部[Token](ast_package_structs.md#struct-token)。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)>

### prop size

```cangjie
public open prop size: Int64
```

功能：获取 [Tokens](ast_package_classes.md#class-tokens) 对象中 [Token](ast_package_structs.md#struct-token) 类型的数量。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [Tokens](ast_package_classes.md#class-tokens) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = Tokens()

    // 添加 token
    tokens.append(Token(TokenKind.IDENTIFIER, "hello"))
    tokens.append(Token(TokenKind.IDENTIFIER, "world"))

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): hello world
```

### init(Array\<Token>)

```cangjie
public init(tokArray: Array<Token>)
```

功能：构造一个 [Tokens](ast_package_classes.md#class-tokens) 对象。

参数：

- tokArray: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Token](ast_package_structs.md#struct-token)> - 一组包含 [Token](ast_package_structs.md#struct-token) 的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt) 类型。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Array<Token>
    let arr = [Token(TokenKind.AT, "@"), Token(TokenKind.IDENTIFIER, "test")]

    // 使用 Array<Token> 构造 Tokens
    let tokens = Tokens(arr)

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @test
```

### init(ArrayList\<Token>)

```cangjie
public init(tokArrayList: ArrayList<Token>)
```

功能：构造一个 [Tokens](ast_package_classes.md#class-tokens) 对象。

参数：

- tokArrayList: [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Token](ast_package_structs.md#struct-token)> - 一组包含 [Token](ast_package_structs.md#struct-token) 的 [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt) 类型。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

main(): Unit {
    // 创建 ArrayList<Token>
    let arr = ArrayList<Token>([Token(TokenKind.AT, "@"), Token(TokenKind.IDENTIFIER, "test")])

    // 使用 ArrayList<Token> 构造 Tokens
    let tokens = Tokens(arr)

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @test
```

### func append(Node)

```cangjie
public func append(node: Node): Tokens
```

功能：将当前的 [Tokens](ast_package_classes.md#class-tokens) 与传入节点所转换得到的 [Tokens](ast_package_classes.md#class-tokens) 进行拼接。

参数：

- node: [Node](ast_package_classes.md#class-node) - 待拼接的 [Node](ast_package_classes.md#class-node) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 拼接后的 [Tokens](ast_package_classes.md#class-tokens) 类型。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M)
    tokens.append(ClassDecl(quote(class A {})))

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @M class A {
}
```

### func append(Token)

```cangjie
public open func append(token: Token): Tokens
```

功能：将当前的 [Tokens](ast_package_classes.md#class-tokens) 与传入的 [Token](ast_package_structs.md#struct-token) 进行拼接。

参数：

- token: [Token](ast_package_structs.md#struct-token) - 待拼接的 [Token](ast_package_structs.md#struct-token) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 拼接后的 [Tokens](ast_package_classes.md#class-tokens) 类型。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = Tokens()
    let token = Token(TokenKind.IDENTIFIER, "test")

    // 追加 token
    let result = tokens.append(token)
    println("result.toString(): ${result.toString()}")
}
```

运行结果：

```text
result.toString(): test
```

### func append(Tokens)

```cangjie
public open func append(tokens: Tokens): Tokens
```

功能：在当前的 [Tokens](ast_package_classes.md#class-tokens) 后追加传入的 [Tokens](ast_package_classes.md#class-tokens) 进行拼接（该接口性能较其他拼接函数表现更好）。

参数：

- tokens: [Tokens](ast_package_classes.md#class-tokens) - 待拼接的 [Tokens](ast_package_classes.md#class-tokens) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 拼接后的 [Tokens](ast_package_classes.md#class-tokens) 类型。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = Tokens()

    // 追加 tokens
    let toks = quote(123)
    let result = tokens.append(toks)
    println("result.toString(): ${result.toString()}")
}
```

运行结果：

```text
result.toString(): 123
```

### func concat(Tokens)

```cangjie
public func concat(tokens: Tokens): Tokens
```

功能：将当前的 [Tokens](ast_package_classes.md#class-tokens) 与传入的 [Tokens](ast_package_classes.md#class-tokens) 进行拼接，返回新的 [Tokens](ast_package_classes.md#class-tokens) 实例。

参数：

- tokens: [Tokens](ast_package_classes.md#class-tokens) - 待拼接的 [Tokens](ast_package_classes.md#class-tokens) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 拼接后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens1 = quote(@M)
    let tokens2 = quote(class A {})
    let tokens = tokens1.concat(tokens2)

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @M class A { }
```

### func dump()

```cangjie
public func dump(): Unit
```

功能：将 [Tokens](ast_package_classes.md#class-tokens) 内所有 [Token](ast_package_structs.md#struct-token) 的信息打印出来。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M)

    // 输出 tokens
    println("tokens.dump():")
    tokens.dump()
}
```

运行结果：

```text
tokens.dump():
description: at, token_id: 51, token_literal_value: @, fileID: 1, line: 5, column: 24
description: identifier, token_id: 137, token_literal_value: M, fileID: 1, line: 5, column: 25
```

### func get(Int64)

```cangjie
public open func get(index: Int64): Token
```

功能：通过索引值获取 [Token](ast_package_structs.md#struct-token) 元素。

参数：

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 待索引的数值。

返回值：

- [Token](ast_package_structs.md#struct-token) - 指定索引的 [Token](ast_package_structs.md#struct-token)。

异常：

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - 当 `index` 无效时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M)

    println("tokens.get(1).dump():")
    tokens.get(1).dump()
}
```

运行结果：

```text
tokens.get(1).dump():
description: identifier, token_id: 137, token_literal_value: M, fileID: 1, line: 5, column: 25
```

### func iterator()

```cangjie
public func iterator(): TokensIterator
```

功能：获取 [Tokens](ast_package_classes.md#class-tokens) 对象中的一个迭代器对象。

返回值：

- [TokensIterator](ast_package_classes.md#class-tokensiterator) - [Tokens](ast_package_classes.md#class-tokens) 对象的迭代器对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(hello world)

    // 获取迭代器
    let iter = tokens.iterator()

    // 获取下一个 token
    let nextToken = iter.next()
    match (nextToken) {
        case Some(token) => println("Next token: ${token.value}")
        case None => println("No more tokens")
    }
}
```

运行结果：

```text
Next token: hello
```

### func remove(Int64)

```cangjie
public func remove(index: Int64): Tokens
```

功能：删除指定位置的 [Token](ast_package_structs.md#struct-token) 对象。

参数：

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 被删除的 [Token](ast_package_structs.md#struct-token) 的索引。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 删除指定位置的 [Token](ast_package_structs.md#struct-token) 后的 [Tokens](ast_package_classes.md#class-tokens) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = quote(hello world)

    println("tokens.toString() before remove: ${tokens.toString()}")

    // 删除位置为 1 的 tokens
    tokens.remove(1)

    println("tokens.toString() after remove: ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString() before remove: hello world
tokens.toString() after remove: hello
```

### func toBytes()

```cangjie
public func toBytes(): Array<UInt8>
```

功能：Tokens 类型的序列化。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - 序列化后的字节序列。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = quote(&)

    // 序列化为 Array<UInt8> 后输出
    println("tokens.toBytes(): ${tokens.toBytes()}")
}
```

运行结果：

```text
tokens.toBytes(): [1, 0, 0, 0, 22, 0, 1, 0, 0, 0, 38, 1, 0, 0, 0, 4, 0, 0, 0, 24, 0, 0, 0, 0, 0]
```

### func toString()

```cangjie
public func toString(): String
```

功能：将 [Tokens](ast_package_classes.md#class-tokens) 转化为 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 转化后的字符串。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M)

    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @M
```

### operator func +(Token)

```cangjie
public operator func +(r: Token): Tokens
```

功能：使用当前 [Tokens](ast_package_classes.md#class-tokens) 与另一个 [Token](ast_package_structs.md#struct-token) 相加以获取新的 [Tokens](ast_package_classes.md#class-tokens) 实例。

参数：

- r: [Token](ast_package_structs.md#struct-token) - 待操作的另一个 [Token](ast_package_structs.md#struct-token) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 新拼接 [Tokens](ast_package_classes.md#class-tokens) 后的词法单元集合。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens1 = quote(@)
    let token = Token(TokenKind.IDENTIFIER, "M")
    let tokens = tokens1 + token

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @M
```

### operator func +(Tokens)

```cangjie
public operator func +(r: Tokens): Tokens
```

功能：使用当前 [Tokens](ast_package_classes.md#class-tokens) 与 [Tokens](ast_package_classes.md#class-tokens) 相加以获取新的 [Tokens](ast_package_classes.md#class-tokens) 实例。

参数：

- r: [Tokens](ast_package_classes.md#class-tokens) - 待操作的一组 [Tokens](ast_package_classes.md#class-tokens) 对象。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 新拼接 [Tokens](ast_package_classes.md#class-tokens) 后的词法单元集合。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens1 = quote(@M)
    let tokens2 = quote(class A {})
    let tokens = tokens1 + tokens2

    // 输出 tokens
    println("tokens.toString(): ${tokens.toString()}")
}
```

运行结果：

```text
tokens.toString(): @M class A { }
```

### operator func \[](Int64)

```cangjie
public operator func [](index: Int64): Token
```

功能：操作符重载，通过索引值获取对应 [Token](ast_package_structs.md#struct-token)。

参数：

- index: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 待索引的数值。

返回值：

- [Token](ast_package_structs.md#struct-token) - 返回索引对应的 [Token](ast_package_structs.md#struct-token)。

异常：

- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - 当 `index` 无效时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M)

    println("tokens[1].dump():")
    tokens[1].dump()
}
```

运行结果：

```text
tokens[1].dump():
description: identifier, token_id: 137, token_literal_value: M, fileID: 1, line: 5, column: 25
```

### operator func \[](Range\<Int64>)

```cangjie
public open operator func [](range: Range<Int64>): Tokens
```

功能：操作符重载，通过 `range` 获取对应 [Tokens](ast_package_classes.md#class-tokens) 切片。

参数：

- range: [Range](../../core/core_package_api/core_package_structs.md#struct-ranget-where-t--countablet--comparablet--equatablet)\<[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)> - 待索引的切片范围。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 返回切片索引对应的 [Tokens](ast_package_classes.md#class-tokens)。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `range.step` 不等于 1 时，抛出异常。
- [IndexOutOfBoundsException](../../core/core_package_api/core_package_exceptions.md#class-indexoutofboundsexception) - 当 range 无效时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(@M class A {})

    // 输出 Tokens 切片
    println("tokens[2..].toString(): ${tokens[2..].toString()}")
}
```

运行结果：

```text
tokens[2..].toString(): class A { }
```

## class TokensIterator

```cangjie
public class TokensIterator <: Iterator<Token> {
    public init(tokens: Tokens)
}
```

功能：实现 [Tokens](ast_package_classes.md#class-tokens) 的迭代器功能。

父类型：

- [Iterator](../../core/core_package_api/core_package_classes.md#class-iteratort)\<[Token](ast_package_structs.md#struct-token)>

### init(Tokens)

```cangjie
public init(tokens: Tokens)
```

功能：构造一个 [TokensIterator](ast_package_classes.md#class-tokensiterator) 对象。

参数：

- tokens: [Tokens](ast_package_classes.md#class-tokens) - 传入 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(hello world)

    // 获取迭代器
    let iter = TokensIterator(tokens)

    // 获取下一个 token
    let nextToken = iter.next()
    match (nextToken) {
        case Some(token) => println("Next token: ${token.value}")
        case None => println("No more tokens")
    }
}
```

运行结果：

```text
Next token: hello
```

### func next()

```cangjie
public func next(): Option<Token>
```

功能：获取迭代器中的下一个值。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> - 返回 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> 类型，当遍历结束后，返回 None。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tokens = quote(hello world)
    let iter = TokensIterator(tokens)

    // 获取下一个 token
    let nextToken = iter.next()
    match (nextToken) {
        case Some(token) => println("Next token: ${token.value}")
        case None => println("No more tokens")
    }
}
```

运行结果：

```text
Next token: hello
```

### func peek()

```cangjie
public func peek(): Option<Token>
```

功能：获取迭代器中的当前值。

返回值：

- [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> - 返回 [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[Token](ast_package_structs.md#struct-token)> 类型，当遍历结束后，返回 None。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(hello world)

    // 获取迭代器
    let iter = TokensIterator(tokens)

    iter.next()
    let curToken = iter.peek()
    match (curToken) {
        case Some(token) => println("Current token: ${token.value}")
        case None => println("No more tokens")
    }
}
```

运行结果：

```text
Current token: hello
```

### func seeing(TokenKind)

```cangjie
public func seeing(kind: TokenKind): Bool
```

功能：判断当前节点的 [Token](ast_package_structs.md#struct-token) 类型是否是传入的类型。

参数：

- kind: [TokenKind](ast_package_enums.md#enum-tokenkind) - 需要判断的 [TokenKind](ast_package_enums.md#enum-tokenkind) 类型。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果当前节点的 [TokenKind](ast_package_enums.md#enum-tokenkind) 与传入类型相同，返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建 Tokens
    let tokens = quote(hello world)

    // 获取迭代器
    let iter = TokensIterator(tokens)

    iter.next()
    println("iter.seeing(TokenKind.IDENTIFIER): ${iter.seeing(TokenKind.IDENTIFIER)}")
}
```

运行结果：

```text
iter.seeing(TokenKind.IDENTIFIER): true
```

## class TrailingClosureExpr

```cangjie
public class TrailingClosureExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示尾随 `Lambda` 节点。

一个 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 节点将 lambda 表达式放在函数调用的尾部，括号外面，如 `f(a){ i => i * i }`。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 中的表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop lambdaExpr

```cangjie
public mut prop lambdaExpr: LambdaExpr
```

功能：获取或设置 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 中的尾随 lambda。

类型：[LambdaExpr](ast_package_classes.md#class-lambdaexpr)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TrailingClosureExpr 对象
    let trailingClosureExpr = TrailingClosureExpr()

    // 设置 TrailingClosureExpr 的属性
    trailingClosureExpr.expr = CallExpr(quote(f(a)))
    trailingClosureExpr.lambdaExpr = LambdaExpr(quote({x => x + 1}))

    // 转化为 Tokens 并输出
    println("trailingClosureExpr.toTokens(): ${trailingClosureExpr.toTokens()}")
}
```

运行结果：

```text
trailingClosureExpr.toTokens(): f(a) { x =>
    x + 1
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TrailingClosureExpr 对象
    let trailingClosureExpr = TrailingClosureExpr(quote(f(a){ i => i * i }))

    // 转化为 Tokens 并输出
    println("trailingClosureExpr.toTokens(): ${trailingClosureExpr.toTokens()}")
}
```

运行结果：

```text
trailingClosureExpr.toTokens(): f(a) { i =>
    i * i
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let trailingClosureExpr = TrailingClosureExpr(quote(f(a){ i }))

    // 转化为 Tokens 并输出
    println("trailingClosureExpr.toTokens(): ${trailingClosureExpr.toTokens()}")
}
```

运行结果：

```text
trailingClosureExpr.toTokens(): f(a) { i
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TrailingClosureExpr) {
        println("Visiting TrailingClosureExpr")
    }
}

main(): Unit {
    let trailingClosureExpr = TrailingClosureExpr(quote(f(a){ i => i * i }))

    // 使用自定义访问器遍历 TrailingClosureExpr 节点
    trailingClosureExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TrailingClosureExpr
```

## class TryExpr

```cangjie
public class TryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `try` 表达式节点。

`try` 表达式包括三个部分：`try` 块，`catch` 块和 `finally` 块。

父类型：

- [Expr](#class-expr)

### prop catchBlocks

```cangjie
public mut prop catchBlocks: ArrayList<Block>
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中的 Catch 块。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Block](ast_package_classes.md#class-block)>

### prop catchPatterns

```cangjie
public mut prop catchPatterns: ArrayList<Pattern>
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中通过模式匹配的方式匹配待捕获的异常序列。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop finallyBlock

```cangjie
public mut prop finallyBlock: Block
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中的关键字 `Finally` 块。

类型：[Block](ast_package_classes.md#class-block)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [TryExpr](ast_package_classes.md#class-tryexpr) 节点无 `Finally` 块节点时，抛出异常。

### prop handlers

```cangjie
public mut prop handlers: ArrayList<Handler>
```

功能：获取或设置 `Handler` 节点列表。

类型： [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Handler](ast_package_classes.md#class-handler)>

### prop keywordF

```cangjie
public mut prop keywordF: Token
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中的 `finally` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `finally` 关键字时，抛出异常。

### prop keywordsC

```cangjie
public mut prop keywordsC: Tokens
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中的关键字 `catch`。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `catch` 关键字时，抛出异常。

### prop keywordT

```cangjie
public mut prop keywordT: Token
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中的 `try` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `try` 关键字时，抛出异常。

### prop resourceSpec

```cangjie
public mut prop resourceSpec: ArrayList<VarDecl>
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中 Try-with-resources 类型表达式的实例化对象序列。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[VarDecl](ast_package_classes.md#class-vardecl)>

### prop tryBlock

```cangjie
public mut prop tryBlock: Block
```

功能：获取或设置 [TryExpr](ast_package_classes.md#class-tryexpr) 中由表达式与声明组成的块。

类型：[Block](ast_package_classes.md#class-block)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TryExpr](ast_package_classes.md#class-tryexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TryExpr 对象
    let tryExpr = TryExpr()

    // 设置 TryExpr 的属性
    tryExpr.keywordT = Token(TokenKind.TRY, "try")

    // 设置 try Block
    let blockT = Block()
    blockT.lBrace = Token(TokenKind.LCURL)
    blockT.rBrace = Token(TokenKind.RCURL)
    blockT.nodes = ArrayList<Node>([parseExpr(quote(throw Exception("I am an Exception!")))])
    tryExpr.tryBlock = blockT

    // 设置关键字
    tryExpr.keywordF = Token(TokenKind.FINALLY, "finally")

    // 设置 finally Block
    let blockF = Block()
    blockF.lBrace = Token(TokenKind.LCURL)
    blockF.rBrace = Token(TokenKind.RCURL)
    blockF.nodes = ArrayList<Node>([parseExpr(quote(println("I am an Exception!")))])
    tryExpr.finallyBlock = blockF

    // 转化为 Tokens 并输出
    println("tryExpr.toTokens(): ${tryExpr.toTokens()}")
}
```

运行结果：

```text
tryExpr.toTokens(): try {
    throw Exception("I am an Exception!")
} finally {
    println("I am an Exception!")
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TryExpr](ast_package_classes.md#class-tryexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TryExpr](ast_package_classes.md#class-tryexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TryExpr](ast_package_classes.md#class-tryexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TryExpr 对象
    let inputs = quote(try {
        throw Exception("I am an Exception!")
    } catch (e: Exception) {
        println(e)
    })
    let tryExpr = TryExpr(inputs)

    // 转化为 Tokens 并输出
    println("tryExpr.toTokens(): ${tryExpr.toTokens()}")
}
```

运行结果：

```text
tryExpr.toTokens(): try {
    throw Exception("I am an Exception!")
} catch(e: Exception) {
    println(e)
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tryExpr = TryExpr(
        quote(try {
        throw Exception("I am an Exception!")
    } catch (e: Exception) {
        println(e)
    }))

    // 转化为 Tokens 并输出
    println("tryExpr.toTokens(): ${tryExpr.toTokens()}")
}
```

运行结果：

```text
tryExpr.toTokens(): try {
    throw Exception("I am an Exception!")
} catch(e: Exception) {
    println(e)
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TryExpr) {
        println("Visiting TryExpr")
    }
}

main(): Unit {
    let tryExpr = TryExpr(
        quote(try {
        throw Exception("I am an Exception!")
    } catch (e: Exception) {
        println(e)
    }))

    // 使用自定义访问器遍历 TryExpr 节点
    tryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TryExpr
```

## class TupleLiteral

```cangjie
public class TupleLiteral <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示元组字面量节点。

[TupleLiteral](ast_package_classes.md#class-tupleliteral) 节点：使用格式 `(expr1, expr2, ... , exprN)` 表示，每个 `expr` 是一个表达式。

父类型：

- [Expr](#class-expr)

### prop elements

```cangjie
public mut prop elements: ArrayList<Expr>
```

功能：获取或设置 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 中的表达式列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Expr](ast_package_classes.md#class-expr)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TupleLiteral 对象
    let tupleLiteral = TupleLiteral()

    // 设置 TupleLiteral 的属性
    tupleLiteral.elements = ArrayList<Expr>([LitConstExpr(quote(1))])

    // 转化为 Tokens 并输出
    println("tupleLiteral.toTokens(): ${tupleLiteral.toTokens()}")
}
```

运行结果：

```text
tupleLiteral.toTokens(): (1)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TupleLiteral](ast_package_classes.md#class-tupleliteral) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TupleLiteral 对象
    let tupleLiteral = TupleLiteral(quote((1, 2)))

    // 转化为 Tokens 并输出
    println("tupleLiteral.toTokens(): ${tupleLiteral.toTokens()}")
}
```

运行结果：

```text
tupleLiteral.toTokens(): (1, 2)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tupleLiteral = TupleLiteral(quote(("a", "b")))

    // 转化为 Tokens 并输出
    println("tupleLiteral.toTokens(): ${tupleLiteral.toTokens()}")
}
```

运行结果：

```text
tupleLiteral.toTokens(): ("a", "b")
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TupleLiteral) {
        println("Visiting TupleLiteral")
    }
}

main(): Unit {
    let tupleLiteral = TupleLiteral(quote((1, 2)))

    // 使用自定义访问器遍历 TupleLiteral 节点
    tupleLiteral.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TupleLiteral
```

## class TuplePattern

```cangjie
public class TuplePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示 Tuple 模式节点。

用于 `tuple` 值的匹配，如 `case ("Bob", age) => 1` 中的 `("Bob", age)`。

父类型：

- [Pattern](#class-pattern)

### prop commas

```cangjie
public mut prop commas: Tokens
```

功能：获取或设置 [TuplePattern](ast_package_classes.md#class-tuplepattern) 节点中的 "," 词法单元序列，可能为空。

类型：[Tokens](ast_package_classes.md#class-tokens)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Tokens](ast_package_classes.md#class-tokens) 不是 "," 词法单元序列时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [TuplePattern](ast_package_classes.md#class-tuplepattern) 节点中的 "(" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop patterns

```cangjie
public mut prop patterns: ArrayList<Pattern>
```

功能：获取或设置 [TuplePattern](ast_package_classes.md#class-tuplepattern) 节点中的一组 [Pattern](ast_package_classes.md#class-pattern) 节点。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Pattern](ast_package_classes.md#class-pattern)>

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [TuplePattern](ast_package_classes.md#class-tuplepattern) 节点中的 ")" 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TuplePattern](ast_package_classes.md#class-tuplepattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TuplePattern 对象
    let tuplePattern = TuplePattern()

    // 设置 TuplePattern 的属性
    tuplePattern.patterns = ArrayList<Pattern>([VarPattern(Token(TokenKind.IDENTIFIER, "a"))])

    // 转化为 Tokens 并输出
    println("tuplePattern.toTokens(): ${tuplePattern.toTokens()}")
}
```

运行结果：

```text
tuplePattern.toTokens(): (a)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TuplePattern](ast_package_classes.md#class-tuplepattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TuplePattern](ast_package_classes.md#class-tuplepattern) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TuplePattern](ast_package_classes.md#class-tuplepattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TuplePattern 对象
    let tuplePattern = TuplePattern(quote((a, b)))

    // 转化为 Tokens 并输出
    println("tuplePattern.toTokens(): ${tuplePattern.toTokens()}")
}
```

运行结果：

```text
tuplePattern.toTokens(): (a, b)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tuplePattern = TuplePattern(quote((x, y)))

    // 转化为 Tokens 并输出
    println("tuplePattern.toTokens(): ${tuplePattern.toTokens()}")
}
```

运行结果：

```text
tuplePattern.toTokens(): (x, y)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TuplePattern) {
        println("Visiting TuplePattern")
    }
}

main(): Unit {
    let tuplePattern = TuplePattern(quote((a, b)))

    // 使用自定义访问器遍历 TuplePattern 节点
    tuplePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TuplePattern
```

## class TupleType

```cangjie
public class TupleType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示元组类型节点。

例如 `var a : (Int64, Int32)` 中的 `(Int64, Int32)`。

父类型：

- [TypeNode](#class-typenode)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [TupleType](ast_package_classes.md#class-tupletype) 节点中的 "(" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [TupleType](ast_package_classes.md#class-tupletype) 节点中的 ")" 词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop types

```cangjie
public mut prop types: ArrayList<TypeNode>
```

功能：获取或设置 [TupleType](ast_package_classes.md#class-tupletype) 节点中的类型节点列表。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[TypeNode](ast_package_classes.md#class-typenode)>

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TupleType](ast_package_classes.md#class-tupletype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TupleType 对象
    let tupleType = TupleType()

    // 设置 TupleType 的属性
    tupleType.types = ArrayList<TypeNode>([PrimitiveType(quote(Int64))])

    // 转化为 Tokens 并输出
    println("tupleType.toTokens(): ${tupleType.toTokens()}")
}
```

运行结果：

```text
tupleType.toTokens(): (Int64)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TupleType](ast_package_classes.md#class-tupletype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TupleType](ast_package_classes.md#class-tupletype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TupleType](ast_package_classes.md#class-tupletype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TupleType 对象
    let tupleType = TupleType(quote((Int64, String)))

    // 转化为 Tokens 并输出
    println("tupleType.toTokens(): ${tupleType.toTokens()}")
}
```

运行结果：

```text
tupleType.toTokens(): (Int64, String)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let tupleType = TupleType(quote((Bool, Float64)))

    // 转化为 Tokens 并输出
    println("tupleType.toTokens(): ${tupleType.toTokens()}")
}
```

运行结果：

```text
tupleType.toTokens(): (Bool, Float64)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TupleType) {
        println("Visiting TupleType")
    }
}

main(): Unit {
    let tupleType = TupleType(quote((Int64, String)))

    // 使用自定义访问器遍历 TupleType 节点
    tupleType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TupleType
```

## class TypeAliasDecl

```cangjie
public class TypeAliasDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示类型别名节点。

一个 [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 节点： `type Point2D = Float64`。

> **说明：**
>
> 该节点中 `type` 作为关键字，紧跟任意的合法标识符，其后的 `type` 是任意的 top-level 可见的类型，标识符和 `type` 之间使用 `=` 进行连接。

父类型：

- [Decl](#class-decl)

### prop aliasType

```cangjie
public mut prop aliasType: TypeNode
```

功能：获取或设置将要别名的类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop assign

```cangjie
public mut prop assign: Token
```

功能：获取或设置标识符和 `type` 之间的 `=`。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `=` 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TypeAliasDecl 对象
    let typeAliasDecl = TypeAliasDecl()

    // 设置 TypeAliasDecl 的属性
    typeAliasDecl.keyword = Token(TokenKind.TYPE, "type")
    typeAliasDecl.identifier = Token(TokenKind.IDENTIFIER, "MyType")
    typeAliasDecl.assign = Token(TokenKind.ASSIGN, "=")
    typeAliasDecl.aliasType = PrimitiveType(quote(Float64))

    // 转化为 Tokens 并输出
    println("typeAliasDecl.toTokens(): ${typeAliasDecl.toTokens()}")
}
```

运行结果：

```text
typeAliasDecl.toTokens(): type MyType = Float64
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TypeAliasDecl 对象
    let typeAliasDecl = TypeAliasDecl(quote(type Alias = Int64))

    // 转化为 Tokens 并输出
    println("typeAliasDecl.toTokens(): ${typeAliasDecl.toTokens()}")
}
```

运行结果：

```text
typeAliasDecl.toTokens(): type Alias = Int64
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let typeAliasDecl = TypeAliasDecl(quote(type MyString = String))

    // 转化为 Tokens 并输出
    println("typeAliasDecl.toTokens(): ${typeAliasDecl.toTokens()}")
}
```

运行结果：

```text
typeAliasDecl.toTokens(): type MyString = String
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeAliasDecl) {
        println("Visiting TypeAliasDecl")
    }
}

main(): Unit {
    let typeAliasDecl = TypeAliasDecl(quote(type Test = Int64))

    // 使用自定义访问器遍历 TypeAliasDecl 节点
    typeAliasDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeAliasDecl
```

## class TypeConvExpr

```cangjie
public class TypeConvExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示类型转换表达式。

用于实现若干数值类型间的转换。一个 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 节点：`Int8(32)`。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 中进行类型转化的原始表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop targetType

```cangjie
public mut prop targetType: PrimitiveType
```

功能：获取或设置 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 中将要转换到的目标类型。

类型：[PrimitiveType](ast_package_classes.md#class-primitivetype)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 TypeConvExpr 对象
    let typeConvExpr = TypeConvExpr()

    // 设置 TypeConvExpr 的属性
    typeConvExpr.targetType = PrimitiveType(quote(Int8))
    typeConvExpr.expr = LitConstExpr(quote(42))

    // 转化为 Tokens 并输出
    println("typeConvExpr.toTokens(): ${typeConvExpr.toTokens()}")
}
```

运行结果：

```text
typeConvExpr.toTokens(): Int8(42)
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 TypeConvExpr 对象
    let typeConvExpr = TypeConvExpr(quote(Int8(42)))

    // 转化为 Tokens 并输出
    println("typeConvExpr.toTokens(): ${typeConvExpr.toTokens()}")
}
```

运行结果：

```text
typeConvExpr.toTokens(): Int8(42)
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let typeConvExpr = TypeConvExpr(quote(Int8(42)))

    // 转化为 Tokens 并输出
    println("typeConvExpr.toTokens(): ${typeConvExpr.toTokens()}")
}
```

运行结果：

```text
typeConvExpr.toTokens(): Int8(42)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeConvExpr) {
        println("Visiting TypeConvExpr")
    }
}

main(): Unit {
    let typeConvExpr = TypeConvExpr(quote(Int8(42)))

    // 使用自定义访问器遍历 TypeConvExpr 节点
    typeConvExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeConvExpr
```

## class TypeNode

```cangjie
public open class TypeNode <: Node {}
```

功能：所有类型节点的父类，继承自 [Node](ast_package_classes.md#class-node)。

父类型：

- [Node](#class-node)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [TypeNode](ast_package_classes.md#class-typenode) 节点中的操作符 ":"，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 操作符时，抛出异常。

### prop typeParameterName

```cangjie
public mut prop typeParameterName: Token
```

功能：获取或设置类型节点的参数，如：`(p1:Int64, p2:Int64)` 中的 `p1` 和 `p2`，可能为 [ILLEGAL](ast_package_enums.md#illegal) 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### func dump(UInt16)

```cangjie
protected open func dump(indent: UInt16): String
```

功能：将当前语法树节点转化为树形结构的形态并进行打印。

参数：

- indent: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 格式化输出的缩进空格数量。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 格式化输出内容。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 在子类中调用
extend FuncType {
    public func myDump() {
        dump(1)
    }
}

main(): Unit {
    // 创建 TypeNode 的子类
    let typeNode = FuncType(quote(() -> Unit))

    println("typeNode.myDump(): ${typeNode.myDump()}")
}
```

运行结果：

```text
typeNode.myDump(): FuncType {
    -ARROW: Token {
      value: "->"
      kind: ARROW
      pos: 12: 38
    }
    -returnType: PrimitiveType {
      -keyword: Token {
        value: "Unit"
        kind: UNIT
        pos: 12: 41
      }
    }
  }
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 创建一个 TypeNode 子类对象 (使用 FuncType 作为示例)
    let typeNode = FuncType(quote((Int64) -> Float64))

    // 输出 Tokens 信息
    println("typeNode.toTokens(): ${typeNode.toTokens()}")
}
```

运行结果：

```text
typeNode.toTokens(): (Int64) -> Float64
```

### func traverse(Visitor)

```cangjie
public open func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeNode) {
        breakTraverse()
        println("Visiting TypeNode")
    }
}

main(): Unit {
    // 创建 TypeNode 节点（以 FuncType 为例）
    let typeNode = FuncType(quote((Int64) -> Float64))

    // 使用自定义访问器遍历 TypeNode 节点
    typeNode.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeNode
```

## class TypePattern

```cangjie
public class TypePattern <: Pattern {
    public init()
    public init(inputs: Tokens)
}
```

功能：表示类型模式节点。

用于判断一个值的运行时类型是否是某个类型的子类型，如 `case b: Base => 0` 中的 `b: Base`。

父类型：

- [Pattern](#class-pattern)

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [TypePattern](ast_package_classes.md#class-typepattern) 节点中的 ":" 操作符的词法单元节点。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ":" 操作符时，抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置 [TypePattern](ast_package_classes.md#class-typepattern) 节点中的模式节点。

类型：[Pattern](ast_package_classes.md#class-pattern)

### prop patternType

```cangjie
public mut prop patternType: TypeNode
```

功能：获取或设置 [TypePattern](ast_package_classes.md#class-typepattern) 节点中的待匹配的模式类型节点。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [TypePattern](ast_package_classes.md#class-typepattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let typePattern = TypePattern()

    // 设置待匹配的模式类型节点
    typePattern.patternType = PrimitiveType(quote(Int64))

    // 设置类型节点的参数
    typePattern.pattern = VarPattern(Token(TokenKind.IDENTIFIER, "a"))

    // 输出 TypePattern 节点转化成的 Tokens
    println("typePattern.toTokens(): ${typePattern.toTokens()}")
}
```

运行结果：

```text
typePattern.toTokens(): a: Int64
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [TypePattern](ast_package_classes.md#class-typepattern) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [TypePattern](ast_package_classes.md#class-typepattern) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [TypePattern](ast_package_classes.md#class-typepattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let inputs = quote(b: Base)
    let typePattern = TypePattern(inputs)

    // 输出 TypePattern 节点转化成的 Tokens
    println("typePattern.toTokens(): ${typePattern.toTokens()}")
}
```

运行结果：

```text
typePattern.toTokens(): b: Base
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let typePattern = TypePattern(quote(i: Int64))

    // 输出 TypePattern 节点转化成的 Tokens
    println("typePattern.toTokens(): ${typePattern.toTokens()}")
}
```

运行结果：

```text
typePattern.toTokens(): i: Int64
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypePattern) {
        println("Visiting TypePattern")
    }
}

main(): Unit {
    let typePattern = TypePattern(quote(i: Int64))

    // 对 TypePattern 节点进行遍历
    typePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypePattern
```

## class UnaryExpr

```cangjie
public class UnaryExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示一个一元操作表达式节点。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 节点中的操作数。

类型：[Expr](ast_package_classes.md#class-expr)

### prop op

```cangjie
public mut prop op: Token
```

功能：获取或设置 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 节点中的一元操作符。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let unaryExpr = UnaryExpr()

    // 设置一元表达式操作符
    unaryExpr.op = Token(TokenKind.NOT, "!")

    // 设置操作数
    unaryExpr.expr = parseExpr(quote(true))

    // 输出 UnaryExpr 节点转化成的 Tokens
    println("unaryExpr.toTokens(): ${unaryExpr.toTokens()}")
}
```

运行结果：

```text
unaryExpr.toTokens(): ! true
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [UnaryExpr](ast_package_classes.md#class-unaryexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let inputs = quote(!false)
    let unaryExpr = UnaryExpr(inputs)

    // 输出 UnaryExpr 节点转化成的 Tokens
    println("unaryExpr.toTokens(): ${unaryExpr.toTokens()}")
}
```

运行结果：

```text
unaryExpr.toTokens(): ! false
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let inputs = quote(!false)
    let unaryExpr = UnaryExpr(inputs)

    // 输出 UnaryExpr 节点转化成的 Tokens
    println("unaryExpr.toTokens(): ${unaryExpr.toTokens()}")
}
```

运行结果：

```text
unaryExpr.toTokens(): ! false
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: UnaryExpr) {
        println("Visiting UnaryExpr")
    }
}

main(): Unit {
    let unaryExpr = UnaryExpr(quote(!true))

    // 对 UnaryExpr 节点进行遍历
    unaryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting UnaryExpr
```

## class VarDecl

```cangjie
public class VarDecl <: Decl {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示变量定义节点。

一个 [VarDecl](ast_package_classes.md#class-vardecl) 节点: `var a: String`，`var b: Int64 = 1`。

> **说明：**
>
> 变量的定义主要包括如下几个部分：修饰符、关键字、patternsMaybeIrrefutable、变量类型和变量初始值。

父类型：

- [Decl](#class-decl)

### prop assign

```cangjie
public mut prop assign: Token
```

功能：获取或设置 [VarDecl](ast_package_classes.md#class-vardecl) 节点中的赋值操作符的位置信息。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是赋值操作符时，抛出异常。

### prop colon

```cangjie
public mut prop colon: Token
```

功能：获取或设置 [VarDecl](ast_package_classes.md#class-vardecl) 节点中的冒号位置信息。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是冒号时，抛出异常。

### prop declType

```cangjie
public mut prop declType: TypeNode
```

功能：获取或设置 [VarDecl](ast_package_classes.md#class-vardecl) 节点的变量类型。

类型：[TypeNode](ast_package_classes.md#class-typenode)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [VarDecl](ast_package_classes.md#class-vardecl) 节点没有声明变量类型时，抛出异常。

### prop expr

```cangjie
public mut prop expr: Expr
```

功能：获取或设置 [VarDecl](ast_package_classes.md#class-vardecl) 节点的变量初始化节点。

类型：[Expr](ast_package_classes.md#class-expr)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [VarDecl](ast_package_classes.md#class-vardecl) 节点没有对变量进行初始化时，抛出异常。

### prop pattern

```cangjie
public mut prop pattern: Pattern
```

功能：获取或设置 [VarDecl](ast_package_classes.md#class-vardecl) 节点的 pattern 节点。

类型：[Pattern](ast_package_classes.md#class-pattern)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当 [VarDecl](ast_package_classes.md#class-vardecl) 节点没有声明 pattern 节点时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VarDecl](ast_package_classes.md#class-vardecl) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VarDecl 对象
    let varDecl = VarDecl()

    // 设置 VarDecl 的属性
    varDecl.keyword = Token(TokenKind.VAR, "var")
    varDecl.identifier = Token(TokenKind.IDENTIFIER, "counter")
    varDecl.assign = Token(TokenKind.ASSIGN, "=")
    varDecl.expr = parseExpr(quote(0))

    // 转化为 Tokens 并输出
    println("varDecl.toTokens(): ${varDecl.toTokens()}")
}
```

运行结果：

```text
varDecl.toTokens(): var counter = 0
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [VarDecl](ast_package_classes.md#class-vardecl) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [VarDecl](ast_package_classes.md#class-vardecl) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VarDecl](ast_package_classes.md#class-vardecl) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 VarDecl 对象
    let varDecl = VarDecl(quote(var name = "test"))

    // 转化为 Tokens 并输出
    println("varDecl.toTokens(): ${varDecl.toTokens()}")
}
```

运行结果：

```text
varDecl.toTokens(): var name = "test"
```

### func isConst()

```cangjie
public func isConst(): Bool
```

功能：判断是否是一个 `Const` 类型的节点。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 是一个 `Const` 类型的节点返回 true；反之，返回 false。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varDecl = VarDecl(quote(const pi = 3.14))

    println("varDecl.isConst(): ${varDecl.isConst()}")
}
```

运行结果：

```text
varDecl.isConst(): true
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varDecl = VarDecl(quote(var age = 25))

    // 转化为 Tokens 并输出
    println("varDecl.toTokens(): ${varDecl.toTokens()}")
}
```

运行结果：

```text
varDecl.toTokens(): var age = 25
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarDecl) {
        println("Visiting VarDecl")
    }
}

main(): Unit {
    let varDecl = VarDecl(quote(var a = 0))

    // 使用自定义访问器遍历 VarDecl 节点
    varDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarDecl
```

## class VarOrEnumPattern

```cangjie
public class VarOrEnumPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

功能：表示当模式的标识符为 `Enum` 构造器时的节点。

例如 `case RED` 中的 `RED` 为 `Enum` 构造器。

父类型：

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 节点中的标识符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VarOrEnumPattern 对象
    let varOrEnumPattern = VarOrEnumPattern()

    // 设置 VarOrEnumPattern 的属性
    varOrEnumPattern.identifier = Token(TokenKind.IDENTIFIER, "GREEN")

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): GREEN
```

### init(Token)

```cangjie
public init(identifier: Token)
```

功能：构造一个 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 对象。

参数：

- identifier: [Token](ast_package_structs.md#struct-token) - 将要构造 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 类型的词法单元。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Token 创建 VarOrEnumPattern 对象
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "BLUE"))

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): BLUE
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "YELLOW"))

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): YELLOW
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarOrEnumPattern) {
        println("Visiting VarOrEnumPattern")
    }
}

main(): Unit {
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "PURPLE"))

    // 使用自定义访问器遍历 VarOrEnumPattern 节点
    varOrEnumPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarOrEnumPattern
```

## class VarPattern

```cangjie
public class VarPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

功能：表示绑定模式节点。

使用一个合法的标识符表示，如 `for (i in 1..10)` 中的 `i`。

父类型：

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [VarPattern](ast_package_classes.md#class-varpattern) 节点中的标识符符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VarPattern](ast_package_classes.md#class-varpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VarPattern 对象
    let varPattern = VarPattern()

    // 设置 VarPattern 的属性
    varPattern.identifier = Token(TokenKind.IDENTIFIER, "index")

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): index
```

### init(Token)

```cangjie
public init(identifier: Token)
```

功能：构造一个 [VarPattern](ast_package_classes.md#class-varpattern) 对象。

参数：

- identifier: [Token](ast_package_structs.md#struct-token) - 将要构造 [VarPattern](ast_package_classes.md#class-varpattern) 类型的词法单元。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VarPattern](ast_package_classes.md#class-varpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Token 创建 VarPattern 对象
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "item"))

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): item
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "value"))

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): value
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarPattern) {
        println("Visiting VarPattern")
    }
}

main(): Unit {
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "name"))

    // 使用自定义访问器遍历 VarPattern 节点
    varPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarPattern
```

## class VArrayExpr

```cangjie
public class VArrayExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `VArray` 的实例节点。

一个 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 节点：`let arr: VArray<Int64, $5> = VArray<Int64, $5>({ i => i })` 中的 `VArray<Int64, $5>({ i => i })`。

父类型：

- [Expr](#class-expr)

### prop arguments

```cangjie
public mut prop arguments: ArrayList<Argument>
```

功能：获取或设置 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 中的中的初始化参数序列。

类型：[ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<[Argument](ast_package_classes.md#class-argument)>

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 中的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 中的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### prop vArrayType

```cangjie
public mut prop vArrayType: VArrayType
```

功能：获取或设置 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 的 VArray 类型节点。

类型：[VArrayType](ast_package_classes.md#class-varraytype)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VArrayExpr 对象
    let varrayExpr = VArrayExpr()

    // 设置 VArrayExpr 的属性
    varrayExpr.lParen = Token(TokenKind.LPAREN, "(")
    varrayExpr.rParen = Token(TokenKind.RPAREN, ")")

    let argument = Argument()
    argument.expr = parseExpr(quote({ i => i }))
    varrayExpr.arguments.add(argument)
    varrayExpr.vArrayType = VArrayType(quote(VArray<Int32, \$5>))

    // 转化为 Tokens 并输出
    println("varrayExpr.toTokens(): ${varrayExpr.toTokens()}")
}
```

运行结果：

```text
varrayExpr.toTokens(): VArray < Int32, $5 >({ i =>
    i
})
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VArrayExpr](ast_package_classes.md#class-varrayexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 VArrayExpr 对象
    let varrayExpr = VArrayExpr(quote(VArray<Int64, \$5>({ i => i })))

    // 转化为 Tokens 并输出
    println("varrayExpr.toTokens(): ${varrayExpr.toTokens()}")
}
```

运行结果：

```text
varrayExpr.toTokens(): VArray < Int64, $5 >({ i =>
    i
})
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varrayExpr = VArrayExpr(quote(VArray<Int64, \$5>(repeat: 0)))

    // 转化为 Tokens 并输出
    println("varrayExpr.toTokens(): ${varrayExpr.toTokens()}")
}
```

运行结果：

```text
varrayExpr.toTokens(): VArray < Int64, $5 >(repeat: 0)
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VArrayExpr) {
        println("Visiting VArrayExpr")
    }
}

main(): Unit {
    let varrayExpr = VArrayExpr(quote(VArray<Int64, \$5>({ i => i })))

    // 使用自定义访问器遍历 VArrayExpr 节点
    varrayExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VArrayExpr
```

## class VArrayType

```cangjie
public class VArrayType <: TypeNode {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `VArray` 类型节点。

使用泛型 `VArray<T, size: Int64>` 表示 `VArray` 类型。

父类型：

- [TypeNode](#class-typenode)

### prop dollar

```cangjie
public mut prop dollar: Token
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点中的操作符 `$` 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `$` 词法单元时，抛出异常。

### prop elementTy

```cangjie
public mut prop elementTy: TypeNode
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点中的类型变元节点，如 `VArray<Int16, $0>` 中的 [Int16](../../core/core_package_api/core_package_intrinsics.md#int16)。

类型：[TypeNode](ast_package_classes.md#class-typenode)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点的关键字 `VArray` 的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### prop lAngle

```cangjie
public mut prop lAngle: Token
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点左尖括号的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是左尖括号时，抛出异常。

### prop rAngle

```cangjie
public mut prop rAngle: Token
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点右尖括号的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是右尖括号时，抛出异常。

### prop size

```cangjie
public mut prop size: Token
```

功能：获取或设置 [VArrayType](ast_package_classes.md#class-varraytype) 节点中类型长度的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VArrayType](ast_package_classes.md#class-varraytype) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VArrayType 对象
    let varrayType = VArrayType()

    // 设置 VArrayType 的属性
    varrayType.dollar = Token(TokenKind.DOLLAR, "$")
    varrayType.keyword = Token(TokenKind.VARRAY, "VArray")
    varrayType.elementTy = PrimitiveType(quote(Int32))
    varrayType.size = Token(TokenKind.INTEGER_LITERAL, "10")

    // 转化为 Tokens 并输出
    println("varrayType.toTokens(): ${varrayType.toTokens()}")
}
```

运行结果：

```text
varrayType.toTokens(): VArray < Int32, $10 >
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [VArrayType](ast_package_classes.md#class-varraytype) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [VArrayType](ast_package_classes.md#class-varraytype) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VArrayType](ast_package_classes.md#class-varraytype) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 VArrayType 对象
    let varrayType = VArrayType(quote(VArray<Int64, \$5>))

    // 转化为 Tokens 并输出
    println("varrayType.toTokens(): ${varrayType.toTokens()}")
}
```

运行结果：

```text
varrayType.toTokens(): VArray < Int64, $5 >
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varrayType = VArrayType(quote(VArray<Int64, \$5>))

    // 转化为 Tokens 并输出
    println("varrayType.toTokens(): ${varrayType.toTokens()}")
}
```

运行结果：

```text
varrayType.toTokens(): VArray < Int64, $5 >
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VArrayType) {
        println("Visiting VArrayType")
    }
}

main(): Unit {
    let varrayType = VArrayType(quote(VArray<Int64, \$5>))

    // 使用自定义访问器遍历 VArrayType 节点
    varrayType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VArrayType
```

## class VarOrEnumPattern

```cangjie
public class VarOrEnumPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

功能：表示当模式的标识符为 `Enum` 构造器时的节点。

例如 `case RED` 中的 `RED` 为 `Enum` 构造器。

父类型：

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 节点中的标识符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VarOrEnumPattern 对象
    let varOrEnumPattern = VarOrEnumPattern()

    // 设置 VarOrEnumPattern 的属性
    varOrEnumPattern.identifier = Token(TokenKind.IDENTIFIER, "GREEN")

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): GREEN
```

### init(Token)

```cangjie
public init(identifier: Token)
```

功能：构造一个 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 对象。

参数：

- identifier: [Token](ast_package_structs.md#struct-token) - 将要构造 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 类型的词法单元。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Token 创建 VarOrEnumPattern 对象
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "BLUE"))

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): BLUE
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "YELLOW"))

    // 转化为 Tokens 并输出
    println("varOrEnumPattern.toTokens(): ${varOrEnumPattern.toTokens()}")
}
```

运行结果：

```text
varOrEnumPattern.toTokens(): YELLOW
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarOrEnumPattern) {
        println("Visiting VarOrEnumPattern")
    }
}

main(): Unit {
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "PURPLE"))

    // 使用自定义访问器遍历 VarOrEnumPattern 节点
    varOrEnumPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarOrEnumPattern
```

## class VarPattern

```cangjie
public class VarPattern <: Pattern {
    public init(identifier: Token)
    public init()
}
```

功能：表示绑定模式节点。

使用一个合法的标识符表示，如 `for (i in 1..10)` 中的 `i`。

父类型：

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public mut prop identifier: Token
```

功能：获取或设置 [VarPattern](ast_package_classes.md#class-varpattern) 节点中的标识符符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

### init()

```cangjie
public init()
```

功能：构造一个默认的 [VarPattern](ast_package_classes.md#class-varpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 VarPattern 对象
    let varPattern = VarPattern()

    // 设置 VarPattern 的属性
    varPattern.identifier = Token(TokenKind.IDENTIFIER, "index")

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): index
```

### init(Token)

```cangjie
public init(identifier: Token)
```

功能：构造一个 [VarPattern](ast_package_classes.md#class-varpattern) 对象。

参数：

- identifier: [Token](ast_package_structs.md#struct-token) - 将要构造 [VarPattern](ast_package_classes.md#class-varpattern) 类型的词法单元。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [VarPattern](ast_package_classes.md#class-varpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Token 创建 VarPattern 对象
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "item"))

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): item
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "value"))

    // 转化为 Tokens 并输出
    println("varPattern.toTokens(): ${varPattern.toTokens()}")
}
```

运行结果：

```text
varPattern.toTokens(): value
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarPattern) {
        println("Visiting VarPattern")
    }
}

main(): Unit {
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "name"))

    // 使用自定义访问器遍历 VarPattern 节点
    varPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarPattern
```

## class Visitor

```cangjie
public abstract class Visitor {}
```

功能：一个抽象类，其内部默认定义了访问不同类型 AST 节点访问（`visit`）函数。

> **说明：**
>
> - `visit` 函数搭配 `traverse` 一起使用，可实现对节点的访问和修改, 所有 `visit` 函数都有默认为空的实现，可以按需实现需要的 `visit` 方法。
> - 该类需要被继承使用，并允许子类重新定义访问函数。
> - 对于有父类的节点类型，`traverse` 函数的遍历顺序为先遍历当前节点，再遍历父类节点，最后遍历子节点。对于无父类的节点类型，`traverse` 函数先遍历当前节点，再遍历子节点。

### func breakTraverse()

```cangjie
public func breakTraverse(): Unit
```

功能：用于重写 `visit` 函数中，通过调用该函数来终止继续遍历子节点的行为。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ClassDecl) {
        println("Visiting ClassDecl")
    }

    public override func visit(_: FuncDecl) {
        println("Visiting FuncDecl")

        // 在 FuncDecl 层级停止遍历
        breakTraverse()
    }

    public override func visit(_: FuncParam) {
        // 不会遍历到
        println("Visiting FuncParam")
    }
}

main(): Unit {
    // 创建一个内含 FuncDecl 和 FuncParam 的 ClassDecl 实例
    let classDecl = ClassDecl(quote(
        class A {
            func foo(a: Int64) {}
        }
    ))

    // 使用自定义访问器遍历 ClassDecl 节点
    classDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ClassDecl
Visiting FuncDecl
```

### func needBreakTraverse()

```cangjie
protected func needBreakTraverse(): Bool
```

功能：用于判断是否需要停止遍历。

> **注意:**
>
> 该函数会在判断需要停止遍历后将用于判断的标记位重置，因此若在先调用 `breakTraverse()` 的情况下调用该函数，可能导致上一次 `breakTraverse()` 失效，影响遍历的停止。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - true 表示需要停止遍历，反之表示不需要停止。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ClassDecl) {
        println("Visiting ClassDecl")
        // 由于 needBreakTraverse() 函数有副作用
        // 这里仅作演示，不建议这样使用
        breakTraverse()
        if (needBreakTraverse()) {
            println("Need to break")
            breakTraverse()
        }
    }
}

main(): Unit {
    // 创建一个内含 FuncDecl 和 FuncParam 的 ClassDecl 实例
    let classDecl = ClassDecl(quote(
        class A {
            func foo(a: Int64) {}
        }
    ))

    // 使用自定义访问器遍历 ClassDecl 节点
    classDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ClassDecl
Need to break
```

### func visit(Annotation)

```cangjie
protected open func visit(_: Annotation): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Annotation](ast_package_classes.md#class-annotation) - [Annotation](ast_package_classes.md#class-annotation) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Annotation) {
        println("Visiting Annotation")
    }
}

main(): Unit {
    let annotation = Annotation(quote(@!Anno))

    // 对 Annotation 节点进行遍历
    annotation.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Annotation
```

### func visit(Argument)

```cangjie
protected open func visit(_: Argument): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Argument](ast_package_classes.md#class-argument) - [Argument](ast_package_classes.md#class-argument) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Argument) {
        println("Visiting Argument")
    }
}

main(): Unit {
    let argument = Argument()
    argument.expr = RefExpr(quote(value))

    // 使用自定义访问器遍历 Argument 节点
    argument.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Argument
```

### func visit(ArrayLiteral)

```cangjie
protected open func visit(_: ArrayLiteral): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ArrayLiteral](ast_package_classes.md#class-arrayliteral) - [ArrayLiteral](ast_package_classes.md#class-arrayliteral) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ArrayLiteral) {
        println("Visiting ArrayLiteral")
    }
}

main(): Unit {
    let arrayLiteral = ArrayLiteral(quote([1, 2]))

    // 使用自定义访问器遍历 ArrayLiteral 节点
    arrayLiteral.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ArrayLiteral
```

### func visit(AsExpr)

```cangjie
protected open func visit(_: AsExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [AsExpr](ast_package_classes.md#class-asexpr) - [AsExpr](ast_package_classes.md#class-asexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: AsExpr) {
        println("Visiting AsExpr")
    }
}

main(): Unit {
    let asExpr = AsExpr(quote(a as Int32))

    // 使用自定义访问器遍历 AsExpr 节点
    asExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting AsExpr
```

### func visit(AssignExpr)

```cangjie
protected open func visit(_: AssignExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [AssignExpr](ast_package_classes.md#class-assignexpr) - [AssignExpr](ast_package_classes.md#class-assignexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: AssignExpr) {
        println("Visiting AssignExpr")
    }
}

main(): Unit {
    let assignExpr = AssignExpr(quote(x = 10))

    // 使用自定义访问器遍历 AssignExpr 节点
    assignExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting AssignExpr
```

### func visit(BinaryExpr)

```cangjie
protected open func visit(_: BinaryExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [BinaryExpr](ast_package_classes.md#class-binaryexpr) - [BinaryExpr](ast_package_classes.md#class-binaryexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: BinaryExpr) {
        println("Visiting BinaryExpr")
    }
}

main(): Unit {
    let binaryExpr = BinaryExpr(quote(1 + 1))

    // 使用自定义访问器遍历 BinaryExpr 节点
    binaryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting BinaryExpr
```

### func visit(Block)

```cangjie
protected open func visit(_: Block): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Block](ast_package_classes.md#class-block) - [Block](ast_package_classes.md#class-block) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Block) {
        println("Visiting Block")
    }
}

main(): Unit {
    let block = Block()

    // 设置 Block 的属性
    block.lBrace = Token(TokenKind.LCURL, "{")
    block.rBrace = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 Block 节点
    block.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Block
```

### func visit(Body)

```cangjie
protected open func visit(_: Body): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Body](ast_package_classes.md#class-body) - [Body](ast_package_classes.md#class-body) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.*

class MyVisitor <: Visitor {
    public override func visit(_: Body) {
        println("Visiting Body")
    }
}

main(): Unit {
    // 创建 Body 对象
    let body = Body()

    // 设置 Body 的属性
    body.lBrace = Token(TokenKind.LCURL, "{")
    body.rBrace = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 Body 节点
    body.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Body
```

### func visit(CallExpr)

```cangjie
protected open func visit(_: CallExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [CallExpr](ast_package_classes.md#class-callexpr) - [CallExpr](ast_package_classes.md#class-callexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: CallExpr) {
        println("Visiting CallExpr")
    }
}

main(): Unit {
    let callExpr = CallExpr(quote(foo(42)))

    // 使用自定义访问器遍历CallExpr节点
    callExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting CallExpr
```

### func visit(ClassDecl)

```cangjie
protected open func visit(_: ClassDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ClassDecl](ast_package_classes.md#class-classdecl) - [ClassDecl](ast_package_classes.md#class-classdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ClassDecl) {
        println("Visiting ClassDecl")
    }
}

main(): Unit {
    let classDecl = ClassDecl(quote(class Test {}))

    // 使用自定义访问器遍历 ClassDecl 节点
    classDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ClassDecl
```

### func visit(CommandTypePattern)

```cangjie
protected open func visit(_: CommandTypePattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) - [CommandTypePattern](ast_package_classes.md#class-commandtypepattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: CommandTypePattern) {
        println("Visiting CommandTypePattern")
    }
}

main(): Unit {
    let commandTypePattern = CommandTypePattern(quote(e: MyEffect))

    // 使用自定义访问器遍历 CommandTypePattern 节点
    commandTypePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting CommandTypePattern
```

### func visit(ConstPattern)

```cangjie
protected open func visit(_: ConstPattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ConstPattern](ast_package_classes.md#class-constpattern) - [ConstPattern](ast_package_classes.md#class-constpattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ConstPattern) {
        println("Visiting ConstPattern")
    }
}

main(): Unit {
    let constPattern = ConstPattern(quote(100))

    // 使用自定义访问器遍历ConstPattern节点
    constPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ConstPattern
```

### func visit(Constructor)

```cangjie
protected open func visit(_: Constructor): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Constructor](ast_package_classes.md#class-constructor) - [Constructor](ast_package_classes.md#class-constructor) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Constructor) {
        println("Visiting Constructor")
    }
}

main(): Unit {
    // 创建 Constructor 对象
    let constructor = Constructor()
    // 设置标识符为 Month
    constructor.identifier = Token(TokenKind.IDENTIFIER, "Month")

    // 使用自定义访问器遍历 Constructor 节点
    constructor.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Constructor
```

### func visit(Decl)

```cangjie
protected open func visit(_: Decl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Decl](ast_package_classes.md#class-decl) - [Decl](ast_package_classes.md#class-decl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Decl) {
        breakTraverse()
        println("Visiting Decl")
    }
}

main(): Unit {
    // 创建 Decl 节点（以 ClassDecl 为例）
    let decl = ClassDecl(quote(class A {}))

    // 使用自定义访问器遍历 Decl 节点
    decl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Decl
```

### func visit(DoWhileExpr)

```cangjie
protected open func visit(_: DoWhileExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) - [DoWhileExpr](ast_package_classes.md#class-dowhileexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: DoWhileExpr) {
        println("Visiting DoWhileExpr")
    }
}

main(): Unit {
    let doWhileExpr = DoWhileExpr(quote(do {} while (false)))

    // 使用自定义访问器遍历 DoWhileExpr 节点
    doWhileExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting DoWhileExpr
```

### func visit(EnumDecl)

```cangjie
protected open func visit(_: EnumDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [EnumDecl](ast_package_classes.md#class-enumdecl) - [EnumDecl](ast_package_classes.md#class-enumdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: EnumDecl) {
        println("Visiting EnumDecl")
    }
}

main(): Unit {
    let enumDecl = EnumDecl(quote(enum Status { Pending | Completed }))

    // 使用自定义访问器遍历 EnumDecl 节点
    enumDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting EnumDecl
```

### func visit(EnumPattern)

```cangjie
protected open func visit(_: EnumPattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [EnumPattern](ast_package_classes.md#class-enumpattern) - [EnumPattern](ast_package_classes.md#class-enumpattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: EnumPattern) {
        println("Visiting EnumPattern")
    }
}

main(): Unit {
    let enumPattern = EnumPattern(quote(Error(code)))

    // 使用自定义访问器遍历 EnumPattern 节点
    enumPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting EnumPattern
```

### func visit(ExceptTypePattern)

```cangjie
protected open func visit(_: ExceptTypePattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) - [ExceptTypePattern](ast_package_classes.md#class-excepttypepattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ExceptTypePattern) {
        println("Visiting ExceptTypePattern")
    }
}

main(): Unit {
    let exceptTypePattern = ExceptTypePattern(quote(err: RuntimeException))

    // 使用自定义访问器遍历 ExceptTypePattern 节点
    exceptTypePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ExceptTypePattern
```

### func visit(Expr)

```cangjie
protected open func visit(_: Expr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Expr](ast_package_classes.md#class-expr) - [Expr](ast_package_classes.md#class-expr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Expr) {
        breakTraverse()
        println("Visiting Expr")
    }
}

main(): Unit {
    // 创建 Expr 节点（以 BinaryExpr 为例）
    let expr = BinaryExpr(quote(1 + 1))

    // 使用自定义访问器遍历 Expr 节点
    expr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Expr
```

### func visit(ExtendDecl)

```cangjie
protected open func visit(_: ExtendDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ExtendDecl](ast_package_classes.md#class-extenddecl) - [ExtendDecl](ast_package_classes.md#class-extenddecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ExtendDecl) {
        println("Visiting ExtendDecl")
    }
}

main(): Unit {
    let extendDecl = ExtendDecl(quote(extend A { func foo() {} }))

    // 对 ExtendDecl 节点进行遍历
    extendDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ExtendDecl
```

### func visit(FeatureId)

```cangjie
protected open func visit(_: FeatureId): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FeatureId](ast_package_classes.md#class-featureid) - [FeatureId](ast_package_classes.md#class-featureid) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeatureId) {
        println("Visiting FeatureId")
    }
}

main(): Unit {
    // 构造一个默认的 FeatureId 对象
    let featureId = FeatureId()

    // 设置 FeatureId 的属性
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)

    // 使用自定义访问器遍历 FeatureId 节点
    featureId.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeatureId
```

### func visit(FeaturesDirective)

```cangjie
protected open func visit(_: FeaturesDirective): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FeaturesDirective](ast_package_classes.md#class-featuresdirective) - [FeaturesDirective](ast_package_classes.md#class-featuresdirective) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeaturesDirective) {
        println("Visiting FeaturesDirective")
    }
}

main(): Unit {
    // 用 Tokens 创建一个 FeaturesDirective 对象
    let featuresDirective = FeaturesDirective(quote(features {a, b.c}))

    // 使用自定义访问器遍历 FeaturesDirective 节点
    featuresDirective.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeaturesDirective
```

### func visit(FeaturesSet)

```cangjie
protected open func visit(_: FeaturesSet): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FeaturesSet](ast_package_classes.md#class-featuresset) - [FeaturesSet](ast_package_classes.md#class-featuresset) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FeaturesSet) {
        println("Visiting FeaturesSet")
    }
}

main(): Unit {
    // 构造一个默认的 FeaturesSet 对象
    let featuresSet = FeaturesSet()

    // 设置 FeaturesSet 的属性
    let featureId = FeatureId()
    featureId.identifiers = quote(a b c)
    featureId.dots = quote(. .)
    featuresSet.content = ArrayList<FeatureId>([featureId])
    featuresSet.lCurl = Token(TokenKind.LCURL, "{")
    featuresSet.rCurl = Token(TokenKind.RCURL, "}")

    // 使用自定义访问器遍历 FeaturesSet 节点
    featuresSet.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FeaturesSet
```

### func visit(ForInExpr)

```cangjie
protected open func visit(_: ForInExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ForInExpr](ast_package_classes.md#class-forinexpr) - [ForInExpr](ast_package_classes.md#class-forinexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ForInExpr) {
        println("Visiting ForInExpr")
    }
}

main(): Unit {
    let forInExpr = ForInExpr(quote(for (i in 1..10) { println(i) }))

    // 使用自定义访问器遍历 ForInExpr 节点
    forInExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ForInExpr
```

### func visit(FuncDecl)

```cangjie
protected open func visit(_: FuncDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FuncDecl](ast_package_classes.md#class-funcdecl) - [FuncDecl](ast_package_classes.md#class-funcdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncDecl) {
        println("Visiting FuncDecl")
    }
}

main(): Unit {
    let funcDecl = FuncDecl(quote(func foo() { println("Hello") }))

    // 使用自定义访问器遍历 FuncDecl 节点
    funcDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncDecl
```

### func visit(FuncParam)

```cangjie
protected open func visit(_: FuncParam): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FuncParam](ast_package_classes.md#class-funcparam) - [FuncParam](ast_package_classes.md#class-funcparam) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncParam) {
        println("Visiting FuncParam")
    }
}

main(): Unit {
    let funcParam = FuncParam(quote(b!: Float64))

    // 使用自定义访问器遍历 FuncParam 节点
    funcParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncParam
```

### func visit(FuncType)

```cangjie
protected open func visit(_: FuncType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [FuncType](ast_package_classes.md#class-functype) - [FuncType](ast_package_classes.md#class-functype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: FuncType) {
        println("Visiting FuncType")
    }
}

main(): Unit {
    let funcType = FuncType(quote((Int32) -> Unit))

    // 使用自定义访问器遍历 FuncType 节点
    funcType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting FuncType
```

### func visit(GenericConstraint)

```cangjie
protected open func visit(_: GenericConstraint): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [GenericConstraint](ast_package_classes.md#class-genericconstraint) - [GenericConstraint](ast_package_classes.md#class-genericconstraint) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: GenericConstraint) {
        println("Visiting GenericConstraint")
    }
}

main(): Unit {
    let genericConstraint = GenericConstraint()

    // 使用自定义访问器遍历 GenericConstraint 节点
    genericConstraint.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting GenericConstraint
```

### func visit(GenericParam)

```cangjie
protected open func visit(_: GenericParam): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [GenericParam](ast_package_classes.md#class-genericparam) - [GenericParam](ast_package_classes.md#class-genericparam) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: GenericParam) {
        println("Visiting GenericParam")
    }
}

main(): Unit {
    let genericParam = GenericParam(quote(T, U))

    // 使用自定义访问器遍历 GenericParam 节点
    genericParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting GenericParam
```

### func visit(IfExpr)

```cangjie
protected open func visit(_: IfExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [IfExpr](ast_package_classes.md#class-ifexpr) - [IfExpr](ast_package_classes.md#class-ifexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IfExpr) {
        println("Visiting IfExpr")
    }
}

main(): Unit {
    let ifExpr = IfExpr(quote(if (a < b) { println(a) } else { println(b) }))

    // 使用自定义访问器遍历 IfExpr 节点
    ifExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting IfExpr
```

### func visit(ImportContent)

```cangjie
protected open func visit(_: ImportContent): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ImportContent](ast_package_classes.md#class-importcontent) - [ImportContent](ast_package_classes.md#class-importcontent) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ImportContent) {
        println("Visiting ImportContent")
    }
}

main(): Unit {
    let importContent = ImportContent()

    // 使用自定义访问器遍历 ImportContent 节点
    importContent.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ImportContent
```

### func visit(ImportList)

```cangjie
protected open func visit(_: ImportList): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ImportList](ast_package_classes.md#class-importlist) - [ImportList](ast_package_classes.md#class-importlist) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ImportList) {
        println("Visiting ImportList")
    }
}

main(): Unit {
    let importList = ImportList(quote(import std.ast.RefType as RT))

    // 使用自定义访问器遍历 ImportList 节点
    importList.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ImportList
```

### func visit(IncOrDecExpr)

```cangjie
protected open func visit(_: IncOrDecExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) - [IncOrDecExpr](ast_package_classes.md#class-incordecexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IncOrDecExpr) {
        println("Visiting IncOrDecExpr")
    }
}

main(): Unit {
    let incOrDecExpr = IncOrDecExpr(quote(x--))

    // 使用自定义访问器遍历 IncOrDecExpr 节点
    incOrDecExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting IncOrDecExpr
```

### func visit(InterfaceDecl)

```cangjie
protected open func visit(_: InterfaceDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [InterfaceDecl](ast_package_classes.md#class-interfacedecl) - [InterfaceDecl](ast_package_classes.md#class-interfacedecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: InterfaceDecl) {
        println("Visiting InterfaceDecl")
    }
}

main(): Unit {
    let interfaceDecl = InterfaceDecl(quote(interface MyInterface { func foo(): Int64 }))

    // 使用自定义访问器遍历 InterfaceDecl 节点
    interfaceDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting InterfaceDecl
```

### func visit(IsExpr)

```cangjie
protected open func visit(_: IsExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [IsExpr](ast_package_classes.md#class-isexpr) - [IsExpr](ast_package_classes.md#class-isexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: IsExpr) {
        println("Visiting IsExpr")
    }
}

main(): Unit {
    // 创建一个 IsExpr 对象
    let isExpr = IsExpr(quote(x is String))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 IsExpr 节点
    isExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting IsExpr
```

### func visit(JumpExpr)

```cangjie
protected open func visit(_: JumpExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [JumpExpr](ast_package_classes.md#class-jumpexpr) - [JumpExpr](ast_package_classes.md#class-jumpexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: JumpExpr) {
        println("Visiting JumpExpr")
    }
}

main(): Unit {
    // 创建一个 JumpExpr 对象
    let jumpExpr = JumpExpr(quote(break))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 JumpExpr 节点
    jumpExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting JumpExpr
```

### func visit(LambdaExpr)

```cangjie
protected open func visit(_: LambdaExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [LambdaExpr](ast_package_classes.md#class-lambdaexpr) - [LambdaExpr](ast_package_classes.md#class-lambdaexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LambdaExpr) {
        println("Visiting LambdaExpr")
    }
}

main(): Unit {
    // 创建一个 LambdaExpr 对象
    let lambdaExpr = LambdaExpr(quote({x: Int => x + 1}))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 LambdaExpr 节点
    lambdaExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting LambdaExpr
```

### func visit(LetPatternExpr)

```cangjie
protected open func visit(_: LetPatternExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) - [LetPatternExpr](ast_package_classes.md#class-letpatternexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LetPatternExpr) {
        println("Visiting LetPatternExpr")
    }
}

main(): Unit {
    // 创建一个 LetPatternExpr 对象
    let letPatternExpr = LetPatternExpr(quote(let Some(v) <- x))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 LetPatternExpr 节点
    letPatternExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting LetPatternExpr
```

### func visit(LitConstExpr)

```cangjie
protected open func visit(_: LitConstExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [LitConstExpr](ast_package_classes.md#class-litconstexpr) - [LitConstExpr](ast_package_classes.md#class-litconstexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: LitConstExpr) {
        println("Visiting LitConstExpr")
    }
}

main(): Unit {
    // 创建一个 LitConstExpr 对象
    let litConstExpr = LitConstExpr(quote(123))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 LitConstExpr 节点
    litConstExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting LitConstExpr
```

### func visit(MacroDecl)

```cangjie
protected open func visit(_: MacroDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MacroDecl](ast_package_classes.md#class-macrodecl) - [MacroDecl](ast_package_classes.md#class-macrodecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroDecl) {
        println("Visiting MacroDecl")
    }
}

main(): Unit {
    // 创建一个 MacroDecl 对象
    let macroDecl = MacroDecl(quote(public macro M(input: Tokens): Tokens {}))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MacroDecl 节点
    macroDecl.traverse(visitor)
}
```

运行结果：

```text
Visiting MacroDecl
```

### func visit(MacroExpandDecl)

```cangjie
protected open func visit(_: MacroExpandDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) - [MacroExpandDecl](ast_package_classes.md#class-macroexpanddecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

// 自定义访问者实现
class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandDecl) {
        println("Visiting MacroExpandDecl")
    }
}

main() {
    // 创建一个宏展开声明节点
    let macroExpandDecl = MacroExpandDecl(quote(@M class A {}))
    // 创建自定义访问者
    let visitor = MyVisitor()
    // 遍历节点
    macroExpandDecl.traverse(visitor)
}
```

运行结果：

```text
Visiting MacroExpandDecl
```

### func visit(MacroExpandExpr)

```cangjie
protected open func visit(_: MacroExpandExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) - [MacroExpandExpr](ast_package_classes.md#class-macroexpandexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandExpr) {
        println("Visiting MacroExpandExpr")
    }
}

main(): Unit {
    // 创建一个 MacroExpandExpr 对象
    let macroExpandExpr = MacroExpandExpr(quote(@M (a is Int64)))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MacroExpandExpr 节点
    macroExpandExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting MacroExpandExpr
```

### func visit(MacroExpandParam)

```cangjie
protected open func visit(_: MacroExpandParam): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) - [MacroExpandParam](ast_package_classes.md#class-macroexpandparam) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MacroExpandParam) {
        println("Visiting MacroExpandParam")
    }
}

main(): Unit {
    // 构造一个默认的 MacroExpandParam 对象
    let macroExpandParam = MacroExpandParam()

    // 设置 MacroExpandParam 的属性
    macroExpandParam.keyword = Token(TokenKind.AT, "@")
    macroExpandParam.identifier = Token(TokenKind.IDENTIFIER, "M")
    macroExpandParam.macroInputs = quote(any)

    // 使用自定义访问器遍历 MacroExpandParam 节点
    macroExpandParam.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting MacroExpandParam
```

### func visit(MainDecl)

```cangjie
protected open func visit(_: MainDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MainDecl](ast_package_classes.md#class-maindecl) - [MainDecl](ast_package_classes.md#class-maindecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MainDecl) {
        println("Visiting MainDecl")
    }
}

main(): Unit {
    // 创建一个 MainDecl 对象
    let mainDecl = MainDecl(quote(main() { println("Hello World") }))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MainDecl 节点
    mainDecl.traverse(visitor)
}
```

运行结果：

```text
Visiting MainDecl
```

### func visit(MatchCase)

```cangjie
protected open func visit(_: MatchCase): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MatchCase](ast_package_classes.md#class-matchcase) - [MatchCase](ast_package_classes.md#class-matchcase) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MatchCase) {
        println("Visiting MatchCase")
    }
}

main(): Unit {
    // 通过init()创建一个空的 MatchCase 实例
    let matchCase = MatchCase()

    // 为实例的各个属性赋值
    matchCase.keywordC = Token(CASE)
    matchCase.expr = BinaryExpr(quote(a > 1))

    // 设置代码块
    let block = Block()
    block.nodes.add(LitConstExpr(quote(true)))
    matchCase.block = block

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MatchCase 节点
    matchCase.traverse(visitor)
}
```

运行结果：

```text
Visiting MatchCase
```

### func visit(MatchExpr)

```cangjie
protected open func visit(_: MatchExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MatchExpr](ast_package_classes.md#class-matchexpr) - [MatchExpr](ast_package_classes.md#class-matchexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MatchExpr) {
        println("Visiting MatchExpr")
    }
}

main(): Unit {
    // 创建一个 MatchExpr 对象
    let matchExpr = MatchExpr(quote(match (x) { case _ => 2 }))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MatchExpr 节点
    matchExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting MatchExpr
```

### func visit(MemberAccess)

```cangjie
protected open func visit(_: MemberAccess): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [MemberAccess](ast_package_classes.md#class-memberaccess) - [MemberAccess](ast_package_classes.md#class-memberaccess) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: MemberAccess) {
        println("Visiting MemberAccess")
    }
}

main(): Unit {
    // 创建一个 MemberAccess 对象
    let memberAccess = MemberAccess(quote(obj.field))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 MemberAccess 节点
    memberAccess.traverse(visitor)
}
```

运行结果：

```text
Visiting MemberAccess
```

### func visit(Modifier)

```cangjie
protected open func visit(_: Modifier): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Modifier](ast_package_classes.md#class-modifier) - [Modifier](ast_package_classes.md#class-modifier) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Modifier) {
        println("Visiting Modifier")
    }
}

main(): Unit {
    // 创建一个 Modifier 对象
    let modifier = Modifier(Token(TokenKind.PUBLIC, "public"))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 Modifier 节点
    modifier.traverse(visitor)
}
```

运行结果：

```text
Visiting Modifier
```

### func visit(Node)

```cangjie
protected open func visit(_: Node): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Node](ast_package_classes.md#class-node) - [Node](ast_package_classes.md#class-node) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Node) {
        breakTraverse()
        println("Visiting Node")
    }
}

main(): Unit {
    // 创建 Node 节点（以 ClassDecl 为例）
    let node = ClassDecl(quote(class A {}))

    // 使用自定义访问器遍历 Node 节点
    node.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Node
```

### func visit(OptionalExpr)

```cangjie
protected open func visit(_: OptionalExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [OptionalExpr](ast_package_classes.md#class-optionalexpr) - [OptionalExpr](ast_package_classes.md#class-optionalexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: OptionalExpr) {
        println("Visiting OptionalExpr")
    }
}

main(): Unit {
    // 创建一个 OptionalExpr 对象
    let optionalExpr = OptionalExpr(quote(a?))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 OptionalExpr 节点
    optionalExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting OptionalExpr
```

### func visit(PackageHeader)

```cangjie
protected open func visit(_: PackageHeader): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PackageHeader](ast_package_classes.md#class-packageheader) - [PackageHeader](ast_package_classes.md#class-packageheader) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PackageHeader) {
        println("Visiting PackageHeader")
    }
}

main(): Unit {
    // 创建一个 PackageHeader 对象
    let packageHeader = PackageHeader(quote(package myPackage))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PackageHeader 节点
    packageHeader.traverse(visitor)
}
```

运行结果：

```text
Visiting PackageHeader
```

### func visit(ParenExpr)

```cangjie
protected open func visit(_: ParenExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ParenExpr](ast_package_classes.md#class-parenexpr) - [ParenExpr](ast_package_classes.md#class-parenexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ParenExpr) {
        println("Visiting ParenExpr")
    }
}

main(): Unit {
    // 创建一个 ParenExpr 对象
    let parenExpr = ParenExpr(quote((1 + 2)))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 ParenExpr 节点
    parenExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting ParenExpr
```

### func visit(ParenType)

```cangjie
protected open func visit(_: ParenType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ParenType](ast_package_classes.md#class-parentype) - [ParenType](ast_package_classes.md#class-parentype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ParenType) {
        println("Visiting ParenType")
    }
}

main(): Unit {
    // 创建一个 ParenType 对象
    let parenType = ParenType(quote((Int32)))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 ParenType 节点
    parenType.traverse(visitor)
}
```

运行结果：

```text
Visiting ParenType
```

### func visit(Pattern)

```cangjie
protected open func visit(_: Pattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Pattern](ast_package_classes.md#class-pattern) - [Pattern](ast_package_classes.md#class-pattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Pattern) {
        breakTraverse()
        println("Visiting Pattern")
    }
}

main(): Unit {
    // 创建 Pattern 节点（以 VarPattern 为例）
    let pattern = VarPattern(quote(e)[0])

    // 使用自定义访问器遍历 Pattern 节点
    pattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting Pattern
```

### func visit(PerformExpr)

```cangjie
protected open func visit(_: PerformExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PerformExpr](ast_package_classes.md#class-performexpr) - [PerformExpr](ast_package_classes.md#class-performexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PerformExpr) {
        println("Visiting PerformExpr")
    }
}

main(): Unit {
    // 构造一个默认的 PerformExpr 对象
    let performExpr = PerformExpr()

    // 设置 PerformExpr 的属性
    performExpr.keyword = Token(TokenKind.PERFORM)
    performExpr.expr = CallExpr(quote(Effect()))

    // 使用自定义访问器遍历 PerformExpr 节点
    performExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting PerformExpr
```

### func visit(PrefixType)

```cangjie
protected open func visit(_: PrefixType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PrefixType](ast_package_classes.md#class-prefixtype) - [PrefixType](ast_package_classes.md#class-prefixtype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrefixType) {
        println("Visiting PrefixType")
    }
}

main(): Unit {
    // 创建一个 PrefixType 对象
    let prefixType = PrefixType(quote(?Int32))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrefixType 节点
    prefixType.traverse(visitor)
}
```

运行结果：

```text
Visiting PrefixType
```

### func visit(PrimaryCtorDecl)

```cangjie
protected open func visit(_: PrimaryCtorDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) - [PrimaryCtorDecl](ast_package_classes.md#class-primaryctordecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimaryCtorDecl) {
        println("Visiting PrimaryCtorDecl")
    }
}

main(): Unit {
    // 创建一个 PrimaryCtorDecl 对象
    let primaryCtorDecl = PrimaryCtorDecl(quote(Ctor(x: Int8) { super(x) }))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrimaryCtorDecl 节点
    primaryCtorDecl.traverse(visitor)
}
```

运行结果：

```text
Visiting PrimaryCtorDecl
```

### func visit(PrimitiveType)

```cangjie
protected open func visit(_: PrimitiveType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PrimitiveType](ast_package_classes.md#class-primitivetype) - [PrimitiveType](ast_package_classes.md#class-primitivetype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimitiveType) {
        println("Visiting PrimitiveType")
    }
}

main(): Unit {
    // 创建一个 PrimitiveType 对象
    let primitiveType = PrimitiveType(quote(Int8))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrimitiveType 节点
    primitiveType.traverse(visitor)
}
```

运行结果：

```text
Visiting PrimitiveType
```

### func visit(PrimitiveTypeExpr)

```cangjie
protected open func visit(_: PrimitiveTypeExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) - [PrimitiveTypeExpr](ast_package_classes.md#class-primitivetypeexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PrimitiveTypeExpr) {
        println("Visiting PrimitiveTypeExpr")
    }
}

main(): Unit {
    // 创建一个 PrimitiveTypeExpr 对象
    let primitiveTypeExpr = PrimitiveTypeExpr(quote(Int8))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PrimitiveTypeExpr 节点
    primitiveTypeExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting PrimitiveTypeExpr
```

### func visit(Program)

```cangjie
protected open func visit(_: Program): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [Program](ast_package_classes.md#class-program) - [Program](ast_package_classes.md#class-program) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: Program) {
        println("Visiting Program")
    }
}

main(): Unit {
    // 创建一个 Program 对象
    let program = Program(quote(let a = 1))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 Program 节点
    program.traverse(visitor)
}
```

运行结果：

```text
Visiting Program
```

### func visit(PropDecl)

```cangjie
protected open func visit(_: PropDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [PropDecl](ast_package_classes.md#class-propdecl) - [PropDecl](ast_package_classes.md#class-propdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: PropDecl) {
        println("Visiting PropDecl")
    }
}

main(): Unit {
    // 创建一个 PropDecl 对象
    let propDecl = PropDecl(quote(prop x: Int32 { get() { 0 } }))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 PropDecl 节点
    propDecl.traverse(visitor)
}
```

运行结果：

```text
Visiting PropDecl
```

### func visit(QualifiedType)

```cangjie
protected open func visit(_: QualifiedType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [QualifiedType](ast_package_classes.md#class-qualifiedtype) - [QualifiedType](ast_package_classes.md#class-qualifiedtype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QualifiedType) {
        println("Visiting QualifiedType")
    }
}

main(): Unit {
    // 创建一个 QualifiedType 对象
    let qualifiedType = QualifiedType(quote(Package.Type))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 QualifiedType 节点
    qualifiedType.traverse(visitor)
}
```

运行结果：

```text
Visiting QualifiedType
```

### func visit(QuoteExpr)

```cangjie
protected open func visit(_: QuoteExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [QuoteExpr](ast_package_classes.md#class-quoteexpr) - [QuoteExpr](ast_package_classes.md#class-quoteexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QuoteExpr) {
        println("Visiting QuoteExpr")
    }
}

main(): Unit {
    // 创建一个 QuoteExpr 对象
    let quoteExpr = QuoteExpr(quote(quote(x + 1)))

    // 创建自定义访问器
    let visitor = MyVisitor()

    // 遍历 QuoteExpr 节点
    quoteExpr.traverse(visitor)
}
```

运行结果：

```text
Visiting QuoteExpr
```

### func visit(QuoteToken)

```cangjie
protected open func visit(_: QuoteToken): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [QuoteToken](ast_package_classes.md#class-quotetoken) - [QuoteToken](ast_package_classes.md#class-quotetoken) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: QuoteToken) {
        println("Visiting QuoteToken")
    }
}

main(): Unit {
    // 创建一个 QuoteToken 对象
    let tokens = quote(quote(x + 1))
    let quoteExpr = QuoteExpr(tokens)
    let quoteToken = quoteExpr.exprs[0]

    // 使用自定义访问器遍历 QuoteToken 节点
    quoteToken.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting QuoteToken
```

### func visit(RangeExpr)

```cangjie
protected open func visit(_: RangeExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [RangeExpr](ast_package_classes.md#class-rangeexpr) - [RangeExpr](ast_package_classes.md#class-rangeexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RangeExpr) {
        println("Visiting RangeExpr")
    }
}

main(): Unit {
    let rangeExpr = RangeExpr(quote(1..10))

    // 对 RangeExpr 节点进行遍历
    rangeExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RangeExpr
```

### func visit(RefExpr)

```cangjie
protected open func visit(_: RefExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [RefExpr](ast_package_classes.md#class-refexpr) - [RefExpr](ast_package_classes.md#class-refexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RefExpr) {
        println("Visiting RefExpr")
    }
}

main(): Unit {
    let refExpr = RefExpr(quote(myRef))

    // 对 RefExpr 节点进行遍历
    refExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RefExpr
```

### func visit(RefType)

```cangjie
protected open func visit(_: RefType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [RefType](ast_package_classes.md#class-reftype) - [RefType](ast_package_classes.md#class-reftype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: RefType) {
        println("Visiting RefType")
    }
}

main(): Unit {
    let refType = RefType(quote(MyType))

    // 对 RefType 节点进行遍历
    refType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting RefType
```

### func visit(ResumeExpr)

```cangjie
protected open func visit(_: ResumeExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ResumeExpr](ast_package_classes.md#class-resumeexpr) - [ResumeExpr](ast_package_classes.md#class-resumeexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ResumeExpr) {
        println("Visiting ResumeExpr")
    }
}

main(): Unit {
    // 构造一个默认的 ResumeExpr 对象
    let resumeExpr = ResumeExpr()

    // 设置 ResumeExpr 的属性
    resumeExpr.throwingExpr = Some(CallExpr(quote(Exception())))
    resumeExpr.keywordT = Token(TokenKind.THROWING, "throwing")

    // 使用自定义访问器遍历 ResumeExpr 节点
    resumeExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ResumeExpr
```

### func visit(ReturnExpr)

```cangjie
protected open func visit(_: ReturnExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ReturnExpr](ast_package_classes.md#class-returnexpr) - [ReturnExpr](ast_package_classes.md#class-returnexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ReturnExpr) {
        println("Visiting ReturnExpr")
    }
}

main(): Unit {
    let returnExpr = ReturnExpr(quote(return))

    // 对 ReturnExpr 节点进行遍历
    returnExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ReturnExpr
```

### func visit(SpawnExpr)

```cangjie
protected open func visit(_: SpawnExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [SpawnExpr](ast_package_classes.md#class-spawnexpr) - [SpawnExpr](ast_package_classes.md#class-spawnexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SpawnExpr) {
        println("Visiting SpawnExpr")
    }
}

main(): Unit {
    let spawnExpr = SpawnExpr(quote(spawn { add(1, 2) }))

    // 对 SpawnExpr 节点进行遍历
    spawnExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SpawnExpr
```

### func visit(StructDecl)

```cangjie
protected open func visit(_: StructDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [StructDecl](ast_package_classes.md#class-structdecl) - [StructDecl](ast_package_classes.md#class-structdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: StructDecl) {
        println("Visiting StructDecl")
    }
}

main(): Unit {
    let structDecl = StructDecl(quote(struct Test {}))

    // 对 StructDecl 节点进行遍历
    structDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting StructDecl
```

### func visit(SubscriptExpr)

```cangjie
protected open func visit(_: SubscriptExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) - [SubscriptExpr](ast_package_classes.md#class-subscriptexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SubscriptExpr) {
        println("Visiting SubscriptExpr")
    }
}

main(): Unit {
    let subscriptExpr = SubscriptExpr(quote(arr[0]))

    // 对 SubscriptExpr 节点进行遍历
    subscriptExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SubscriptExpr
```

### func visit(SynchronizedExpr)

```cangjie
protected open func visit(_: SynchronizedExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) - [SynchronizedExpr](ast_package_classes.md#class-synchronizedexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: SynchronizedExpr) {
        println("Visiting SynchronizedExpr")
    }
}

main(): Unit {
    let synchronizedExpr = SynchronizedExpr(quote(synchronized(lock) { }))

    // 对 SynchronizedExpr 节点进行遍历
    synchronizedExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting SynchronizedExpr
```

### func visit(ThisType)

```cangjie
protected open func visit(_: ThisType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ThisType](ast_package_classes.md#class-thistype) - [ThisType](ast_package_classes.md#class-thistype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ThisType) {
        println("Visiting ThisType")
    }
}

main(): Unit {
    let thisType = ThisType(quote(This))

    // 对 ThisType 节点进行遍历
    thisType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ThisType
```

### func visit(ThrowExpr)

```cangjie
protected open func visit(_: ThrowExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [ThrowExpr](ast_package_classes.md#class-throwexpr) - [ThrowExpr](ast_package_classes.md#class-throwexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: ThrowExpr) {
        println("Visiting ThrowExpr")
    }
}

main(): Unit {
    let throwExpr = ThrowExpr(quote(throw Exception("Error message")))

    // 对 ThrowExpr 节点进行遍历
    throwExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting ThrowExpr
```

### func visit(TrailingClosureExpr)

```cangjie
protected open func visit(_: TrailingClosureExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) - [TrailingClosureExpr](ast_package_classes.md#class-trailingclosureexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TrailingClosureExpr) {
        println("Visiting TrailingClosureExpr")
    }
}

main(): Unit {
    let trailingClosureExpr = TrailingClosureExpr(quote(f(a){ i => i * i }))

    // 对 TrailingClosureExpr 节点进行遍历
    trailingClosureExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TrailingClosureExpr
```

### func visit(TryExpr)

```cangjie
protected open func visit(_: TryExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TryExpr](ast_package_classes.md#class-tryexpr) - [TryExpr](ast_package_classes.md#class-tryexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TryExpr) {
        println("Visiting TryExpr")
    }
}

main(): Unit {
    let tryExpr = TryExpr(
        quote(try {
        throw Exception("I am an Exception!")
    } catch (e: Exception) {
        println(e)
    }))

    // 对 TryExpr 节点进行遍历
    tryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TryExpr
```

### func visit(TupleLiteral)

```cangjie
protected open func visit(_: TupleLiteral): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TupleLiteral](ast_package_classes.md#class-tupleliteral) - [TupleLiteral](ast_package_classes.md#class-tupleliteral) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TupleLiteral) {
        println("Visiting TupleLiteral")
    }
}

main(): Unit {
    let tupleLiteral = TupleLiteral(quote((1, 2)))

    // 对 TupleLiteral 节点进行遍历
    tupleLiteral.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TupleLiteral
```

### func visit(TuplePattern)

```cangjie
protected open func visit(_: TuplePattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TuplePattern](ast_package_classes.md#class-tuplepattern) - [TuplePattern](ast_package_classes.md#class-tuplepattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TuplePattern) {
        println("Visiting TuplePattern")
    }
}

main(): Unit {
    let tuplePattern = TuplePattern(quote((a, b)))

    // 对 TuplePattern 节点进行遍历
    tuplePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TuplePattern
```

### func visit(TupleType)

```cangjie
protected open func visit(_: TupleType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TupleType](ast_package_classes.md#class-tupletype) - [TupleType](ast_package_classes.md#class-tupletype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TupleType) {
        println("Visiting TupleType")
    }
}

main(): Unit {
    let tupleType = TupleType(quote((Int64, String)))

    // 对 TupleType 节点进行遍历
    tupleType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TupleType
```

### func visit(TypeAliasDecl)

```cangjie
protected open func visit(_: TypeAliasDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) - [TypeAliasDecl](ast_package_classes.md#class-typealiasdecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeAliasDecl) {
        println("Visiting TypeAliasDecl")
    }
}

main(): Unit {
    let typeAliasDecl = TypeAliasDecl(quote(type Test = Int64))

    // 对 TypeAliasDecl 节点进行遍历
    typeAliasDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeAliasDecl
```

### func visit(TypeConvExpr)

```cangjie
protected open func visit(_: TypeConvExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) - [TypeConvExpr](ast_package_classes.md#class-typeconvexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeConvExpr) {
        println("Visiting TypeConvExpr")
    }
}

main(): Unit {
    let typeConvExpr = TypeConvExpr(quote(Int8(42)))

    // 对 TypeConvExpr 节点进行遍历
    typeConvExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeConvExpr
```

### func visit(TypeNode)

```cangjie
protected open func visit(_: TypeNode): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TypeNode](ast_package_classes.md#class-typenode) - [TypeNode](ast_package_classes.md#class-typenode) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypeNode) {
        breakTraverse()
        println("Visiting TypeNode")
    }
}

main(): Unit {
    // 创建 TypeNode 节点（以 FuncType 为例）
    let typeNode = FuncType(quote((Int64) -> Float64))

    // 使用自定义访问器遍历 TypeNode 节点
    typeNode.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypeNode
```

### func visit(TypePattern)

```cangjie
protected open func visit(_: TypePattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [TypePattern](ast_package_classes.md#class-typepattern) - [TypePattern](ast_package_classes.md#class-typepattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: TypePattern) {
        println("Visiting TypePattern")
    }
}

main(): Unit {
    let typePattern = TypePattern(quote(i: Int64))

    // 对 TypePattern 节点进行遍历
    typePattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting TypePattern
```

### func visit(UnaryExpr)

```cangjie
protected open func visit(_: UnaryExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [UnaryExpr](ast_package_classes.md#class-unaryexpr) - [UnaryExpr](ast_package_classes.md#class-unaryexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: UnaryExpr) {
        println("Visiting UnaryExpr")
    }
}

main(): Unit {
    let unaryExpr = UnaryExpr(quote(!true))

    // 对 UnaryExpr 节点进行遍历
    unaryExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting UnaryExpr
```

### func visit(VarDecl)

```cangjie
protected open func visit(_: VarDecl): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [VarDecl](ast_package_classes.md#class-vardecl) - [VarDecl](ast_package_classes.md#class-vardecl) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarDecl) {
        println("Visiting VarDecl")
    }
}

main(): Unit {
    let varDecl = VarDecl(quote(var a = 0))

    // 对 VarDecl 节点进行遍历
    varDecl.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarDecl
```

### func visit(VarOrEnumPattern)

```cangjie
protected open func visit(_: VarOrEnumPattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) - [VarOrEnumPattern](ast_package_classes.md#class-varorenumpattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarOrEnumPattern) {
        println("Visiting VarOrEnumPattern")
    }
}

main(): Unit {
    let varOrEnumPattern = VarOrEnumPattern(Token(TokenKind.IDENTIFIER, "PURPLE"))

    // 对 VarOrEnumPattern 节点进行遍历
    varOrEnumPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarOrEnumPattern
```

### func visit(VarPattern)

```cangjie
protected open func visit(_: VarPattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [VarPattern](ast_package_classes.md#class-varpattern) - [VarPattern](ast_package_classes.md#class-varpattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VarPattern) {
        println("Visiting VarPattern")
    }
}

main(): Unit {
    let varPattern = VarPattern(Token(TokenKind.IDENTIFIER, "name"))

    // 对 VarPattern 节点进行遍历
    varPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VarPattern
```

### func visit(VArrayExpr)

```cangjie
protected open func visit(_: VArrayExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [VArrayExpr](ast_package_classes.md#class-varrayexpr) - [VArrayExpr](ast_package_classes.md#class-varrayexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VArrayExpr) {
        println("Visiting VArrayExpr")
    }
}

main(): Unit {
    let varrayExpr = VArrayExpr(quote(VArray<Int64, \$5>({ i => i })))

    // 对 VArrayExpr 节点进行遍历
    varrayExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VArrayExpr
```

### func visit(VArrayType)

```cangjie
protected open func visit(_: VArrayType): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [VArrayType](ast_package_classes.md#class-varraytype) - [VArrayType](ast_package_classes.md#class-varraytype) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: VArrayType) {
        println("Visiting VArrayType")
    }
}

main(): Unit {
    let varrayType = VArrayType(quote(VArray<Int64, \$5>))

    // 对 VArrayType 节点进行遍历
    varrayType.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting VArrayType
```

### func visit(WhileExpr)

```cangjie
protected open func visit(_: WhileExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [WhileExpr](ast_package_classes.md#class-whileexpr) - [WhileExpr](ast_package_classes.md#class-whileexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WhileExpr) {
        println("Visiting WhileExpr")
    }
}

main(): Unit {
    let whileExpr = WhileExpr(quote(while(true) {}))

    // 对 WhileExpr 节点进行遍历
    whileExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WhileExpr
```

### func visit(WildcardExpr)

```cangjie
protected open func visit(_: WildcardExpr): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [WildcardExpr](ast_package_classes.md#class-wildcardexpr) - [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WildcardExpr) {
        println("Visiting WildcardExpr")
    }
}

main(): Unit {
    let wildcardExpr = WildcardExpr(quote(_))

    // 对 WildcardExpr 节点进行遍历
    wildcardExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WildcardExpr
```

### func visit(WildcardPattern)

```cangjie
protected open func visit(_: WildcardPattern): Unit
```

功能：定义访问节点时的操作，需要重写。

参数：

- _: [WildcardPattern](ast_package_classes.md#class-wildcardpattern) - [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 类型的被遍历节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WildcardPattern) {
        println("Visiting WildcardPattern")
    }
}

main(): Unit {
    let wildcardPattern = WildcardPattern(quote(_))

    // 对 WildcardPattern 节点进行遍历
    wildcardPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WildcardPattern
```

## class WhileExpr

```cangjie
public class WhileExpr <: Expr {
    public init(inputs: Tokens)
    public init()
}
```

功能：表示 `while` 表达式。

`while` 是关键字，`while` 之后是一个小括号，小括号内可以是一个表达式或者一个 `let` 声明的解构匹配，接着是一个 [Block](ast_package_classes.md#class-block) 节点。

父类型：

- [Expr](#class-expr)

### prop block

```cangjie
public mut prop block: Block
```

功能：获取或设置 [WhileExpr](ast_package_classes.md#class-whileexpr) 中的块节点。

类型：[Block](ast_package_classes.md#class-block)

### prop condition

```cangjie
public mut prop condition: Expr
```

功能：获取或设置关键字 [WhileExpr](ast_package_classes.md#class-whileexpr) 中的条件表达式。

类型：[Expr](ast_package_classes.md#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取或设置 [WhileExpr](ast_package_classes.md#class-whileexpr) 节点中 `while` 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 `while` 关键字时，抛出异常。

### prop lParen

```cangjie
public mut prop lParen: Token
```

功能：获取或设置 [WhileExpr](ast_package_classes.md#class-whileexpr) 中 `while` 关键字之后的 "("。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "(" 时，抛出异常。

### prop rParen

```cangjie
public mut prop rParen: Token
```

功能：获取或设置 [WhileExpr](ast_package_classes.md#class-whileexpr) 中 `while` 关键字之后的 ")"。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 ")" 时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [WhileExpr](ast_package_classes.md#class-whileexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 WhileExpr 对象
    let whileExpr = WhileExpr()

    // 设置 WhileExpr 的属性
    whileExpr.keyword = Token(TokenKind.WHILE, "while")
    whileExpr.condition = parseExpr(quote(true))
    whileExpr.lParen = Token(TokenKind.LPAREN, "(")
    whileExpr.rParen = Token(TokenKind.RPAREN, ")")

    let block = Block()
    block.lBrace = Token(TokenKind.LCURL)
    block.rBrace = Token(TokenKind.RCURL)
    whileExpr.block = block

    // 转化为 Tokens 并输出
    println("whileExpr.toTokens(): ${whileExpr.toTokens()}")
}
```

运行结果：

```text
whileExpr.toTokens(): while(true) {
}
```

### init(Tokens)

```cangjie
public init(inputs: Tokens)
```

功能：构造一个 [WhileExpr](ast_package_classes.md#class-whileexpr) 对象。

参数：

- inputs: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [WhileExpr](ast_package_classes.md#class-whileexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [WhileExpr](ast_package_classes.md#class-whileexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 WhileExpr 对象
    let whileExpr = WhileExpr(quote(while(true) {}))

    // 转化为 Tokens 并输出
    println("whileExpr.toTokens(): ${whileExpr.toTokens()}")
}
```

运行结果：

```text
whileExpr.toTokens(): while(true) {
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let whileExpr = WhileExpr(quote(while(x < 10) { x++ }))

    // 转化为 Tokens 并输出
    println("whileExpr.toTokens(): ${whileExpr.toTokens()}")
}
```

运行结果：

```text
whileExpr.toTokens(): while(x < 10) {
    x ++
}
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WhileExpr) {
        println("Visiting WhileExpr")
    }
}

main(): Unit {
    let whileExpr = WhileExpr(quote(while(true) {}))

    // 使用自定义访问器遍历 WhileExpr 节点
    whileExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WhileExpr
```

## class WildcardExpr

```cangjie
public class WildcardExpr <: Expr {
    public init(keyword: Tokens)
    public init()
}
```

功能：表示通配符表达式节点。

父类型：

- [Expr](#class-expr)

### prop keyword

```cangjie
public mut prop keyword: Token
```

功能：获取 [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 的 "_" 关键字。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "_" 关键字时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 WildcardExpr 对象
    let wildcardExpr = WildcardExpr()

    // 设置 WildcardExpr 的属性
    wildcardExpr.keyword = Token(TokenKind.WILDCARD, "_")

    // 转化为 Tokens 并输出
    println("wildcardExpr.toTokens(): ${wildcardExpr.toTokens()}")
}
```

运行结果：

```text
wildcardExpr.toTokens(): _
```

### init(Tokens)

```cangjie
public init(keyword: Tokens)
```

功能：构造一个 [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 对象。

参数：

- keyword: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 类型的词法单元集合 ([Tokens](ast_package_classes.md#class-tokens))。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [WildcardExpr](ast_package_classes.md#class-wildcardexpr) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 WildcardExpr 对象
    let wildcardExpr = WildcardExpr(quote(_))

    // 转化为 Tokens 并输出
    println("wildcardExpr.toTokens(): ${wildcardExpr.toTokens()}")
}
```

运行结果：

```text
wildcardExpr.toTokens(): _
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let wildcardExpr = WildcardExpr(quote(_))

    // 转化为 Tokens 并输出
    println("wildcardExpr.toTokens(): ${wildcardExpr.toTokens()}")
}
```

运行结果：

```text
wildcardExpr.toTokens(): _
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WildcardExpr) {
        println("Visiting WildcardExpr")
    }
}

main(): Unit {
    let wildcardExpr = WildcardExpr(quote(_))

    // 使用自定义访问器遍历 WildcardExpr 节点
    wildcardExpr.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WildcardExpr
```

## class WildcardPattern

```cangjie
public class WildcardPattern <: Pattern {
    public init(keyword: Tokens)
    public init()
}
```

功能：表示通配符模式节点。

使用下划线 "_" 表示，可以匹配任意值。

父类型：

- [Pattern](#class-pattern)

### prop wildcard

```cangjie
public mut prop wildcard: Token
```

功能：获取或设置 [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 节点中的 "_" 操作符的词法单元。

类型：[Token](ast_package_structs.md#struct-token)

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当设置的 [Token](ast_package_structs.md#struct-token) 不是 "_" 操作符时，抛出异常。

### init()

```cangjie
public init()
```

功能：构造一个默认的 [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 对象。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 构造一个默认的 WildcardPattern 对象
    let wildcardPattern = WildcardPattern()

    // 设置 WildcardPattern 的属性
    wildcardPattern.wildcard = Token(TokenKind.WILDCARD, "_")

    // 转化为 Tokens 并输出
    println("wildcardPattern.toTokens(): ${wildcardPattern.toTokens()}")
}
```

运行结果：

```text
wildcardPattern.toTokens(): _
```

### init(Tokens)

```cangjie
public init(keyword: Tokens)
```

功能：构造一个 [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 对象。

参数：

- keyword: [Tokens](ast_package_classes.md#class-tokens) - 将要构造 [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 类型的词法单元集合（[Tokens](ast_package_classes.md#class-tokens)）。

异常：

- [ASTException](ast_package_exceptions.md#class-astexception) - 当输入的 [Tokens](ast_package_classes.md#class-tokens) 类型无法构造为 [WildcardPattern](ast_package_classes.md#class-wildcardpattern) 节点时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    // 从 Tokens 创建 WildcardPattern 对象
    let wildcardPattern = WildcardPattern(quote(_))

    // 转化为 Tokens 并输出
    println("wildcardPattern.toTokens(): ${wildcardPattern.toTokens()}")
}
```

运行结果：

```text
wildcardPattern.toTokens(): _
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将当前语法树节点转化为 [Tokens](ast_package_classes.md#class-tokens) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转化后的 [Tokens](ast_package_classes.md#class-tokens) 类型节点。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main(): Unit {
    let wildcardPattern = WildcardPattern(quote(_))

    // 转化为 Tokens 并输出
    println("wildcardPattern.toTokens(): ${wildcardPattern.toTokens()}")
}
```

运行结果：

```text
wildcardPattern.toTokens(): _
```

### func traverse(Visitor)

```cangjie
public func traverse(v: Visitor): Unit
```

功能：遍历当前语法树节点及其子节点。若要提前终止子节点遍历，可重写 `visit` 函数并调用 `breakTraverse` 函数。请参见[自定义访问函数遍历 AST 对象示例](../ast_samples/traverse.md)。

参数：

- v: [Visitor](ast_package_classes.md#class-visitor) - [Visitor](ast_package_classes.md#class-visitor) 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.ast.*

class MyVisitor <: Visitor {
    public override func visit(_: WildcardPattern) {
        println("Visiting WildcardPattern")
    }
}

main(): Unit {
    let wildcardPattern = WildcardPattern(quote(_))

    // 使用自定义访问器遍历 WildcardPattern 节点
    wildcardPattern.traverse(MyVisitor())
}
```

运行结果：

```text
Visiting WildcardPattern
```
