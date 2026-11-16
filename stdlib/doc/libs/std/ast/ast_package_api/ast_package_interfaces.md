# 接口

## interface ToBytes

```cangjie
public interface ToBytes {
    func toBytes(): Array<UInt8>
}
```

功能：提供对应类型的序列化功能。

### func toBytes()

```cangjie
func toBytes(): Array<UInt8>
```

功能：提供对应类型的序列化功能。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - 序列化后的字节序列。

示例：

<!-- verify -->
```cangjie
import std.ast.*

public class A <: ToBytes {
    let a: Int32 = 10
    let b: Int64 = 20
    public func toBytes(): Array<UInt8> {
        var b1: Array<UInt8> = [UInt8(this.a)]
        var b2: Array<UInt8> = [UInt8(this.b)]
        return b1.concat(b2)
    }
}

main() {
    let a = A()

    // 输出 toBytes() 的结果
    println("a.toBytes(): ${a.toBytes()}")
}
```

运行结果：

```text
a.toBytes(): [10, 20]
```

## interface ToTokens

```cangjie
public interface ToTokens {
    func toTokens(): Tokens
}
```

功能：实现对应类型的实例到 [Tokens](ast_package_classes.md#class-tokens) 类型转换的接口，作为支持 `quote` 插值操作必须实现的接口。

### func toTokens()

```cangjie
func toTokens(): Tokens
```

功能：实现对应类型的实例到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

public class A <: ToTokens {
    let a: Int32 = 10
    let b: Int64 = 20
    public func toTokens(): Tokens {
        a.toTokens() + b.toTokens()
    }
}

main() {
    let a = A()

    // 输出 toTokens() 的结果
    println("a.toTokens().dump():")
    a.toTokens().dump()
}
```

运行结果：

```text
a.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 10, fileID: 21, line: 50, column: 26
description: integer_literal, token_id: 139, token_literal_value: 20, fileID: 21, line: 40, column: 26
```

### extend\<T> Array\<T> <: ToTokens

```cangjie
extend<T> Array<T> <: ToTokens
```

功能：实现 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<T> 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换，仅支持数值类型、[Rune](../../core/core_package_api/core_package_intrinsics.md#rune) 类型、[Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型、[String](../../core/core_package_api/core_package_structs.md#struct-string) 类型。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let arr: Array<Int64> = [1, 2]

    // 输出 toTokens() 的结果
    println("arr.toTokens(): ${arr.toTokens()}")
}
```

运行结果：

```text
arr.toTokens(): [1, 2]
```

### extend\<T> ArrayList\<T> <: ToTokens

```cangjie
extend<T> ArrayList<T> <: ToTokens
```

功能：实现 [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt)\<T> 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [ArrayList](../../collection/collection_package_api/collection_package_class.md#class-arraylistt) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换，目前支持的类型有 [Decl](ast_package_classes.md#class-decl)、[Node](ast_package_classes.md#class-node)、[Constructor](ast_package_classes.md#class-constructor)、[Argument](ast_package_classes.md#class-argument)、[FuncParam](ast_package_classes.md#class-funcparam)、[MatchCase](ast_package_classes.md#class-matchcase)、[Modifier](ast_package_classes.md#class-modifier)、[Annotation](ast_package_classes.md#class-annotation)、[ImportList](ast_package_classes.md#class-importlist)、[Pattern](ast_package_classes.md#class-pattern)、[TypeNode](ast_package_classes.md#class-typenode) 等。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*
import std.collection.ArrayList

main() {
    let expr0 = BinaryExpr(quote(1 + 1))
    let arr = ArrayList<Node>([expr0])

    // 输出 toTokens() 的结果
    println("arr.toTokens().dump():")
    arr.toTokens().dump()
}
```

运行结果：

```text
arr.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 1, fileID: 1, line: 5, column: 34
description: add, token_id: 12, token_literal_value: +, fileID: 1, line: 5, column: 36
description: integer_literal, token_id: 139, token_literal_value: 1, fileID: 1, line: 5, column: 38
```

### extend Bool <: ToTokens

```cangjie
extend Bool <: ToTokens
```

功能：实现 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let boolean = false

    // 输出 toTokens() 的结果
    println("boolean.toTokens().dump():")
    boolean.toTokens().dump()
}
```

运行结果：

```text
boolean.toTokens().dump():
description: bool_literal, token_id: 151, token_literal_value: false, fileID: 21, line: 141, column: 26
```

### extend Float16 <: ToTokens

```cangjie
extend Float16 <: ToTokens
```

功能：实现 [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Float16](../../core/core_package_api/core_package_intrinsics.md#float16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let float16: Float16 = 1.0625

    // 输出 toTokens() 的结果
    println("float16.toTokens().dump():")
    float16.toTokens().dump()
}
```

运行结果：

```text
float16.toTokens().dump():
description: float_literal, token_id: 141, token_literal_value: 1.062500, fileID: 21, line: 134, column: 26
```

### extend Float32 <: ToTokens

```cangjie
extend Float32 <: ToTokens
```

功能：实现 [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Float32](../../core/core_package_api/core_package_intrinsics.md#float32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let float32: Float32 = 3.14

    // 输出 toTokens() 的结果
    println("float32.toTokens().dump():")
    float32.toTokens().dump()
}
```

运行结果：

```text
float32.toTokens().dump():
description: float_literal, token_id: 141, token_literal_value: 3.140000, fileID: 21, line: 124, column: 26
```

### extend Float64 <: ToTokens

```cangjie
extend Float64 <: ToTokens
```

功能：实现 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Float64](../../core/core_package_api/core_package_intrinsics.md#float64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let float64: Float64 = 3.1415926

    // 输出 toTokens() 的结果
    println("float64.toTokens().dump():")
    float64.toTokens().dump()
}
```

运行结果：

```text
float64.toTokens().dump():
description: float_literal, token_id: 141, token_literal_value: 3.1415926, fileID: 21, line: 114, column: 26
```

### extend Int16 <: ToTokens

```cangjie
extend Int16 <: ToTokens
```

功能：实现 [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Int16](../../core/core_package_api/core_package_intrinsics.md#int16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let int16: Int16 = 42

    // 输出 toTokens() 的结果
    println("int16.toTokens().dump():")
    int16.toTokens().dump()
}
```

运行结果：

```text
int16.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 42, fileID: 21, line: 60, column: 26
```

### extend Int32 <: ToTokens

```cangjie
extend Int32 <: ToTokens
```

功能：实现 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let int32: Int32 = 42

    // 输出 toTokens() 的结果
    println("int32.toTokens().dump():")
    int32.toTokens().dump()
}
```

运行结果：

```text
int32.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 42, fileID: 21, line: 50, column: 26
```

### extend Int64 <: ToTokens

```cangjie
extend Int64 <: ToTokens
```

功能：实现 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let int64: Int64 = 2147483648

    // 输出 toTokens() 的结果
    println("int64.toTokens().dump():")
    int64.toTokens().dump()
}
```

运行结果：

```text
int64.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 2147483648, fileID: 21, line: 40, column: 26
```

### extend Int8 <: ToTokens

```cangjie
extend Int8 <: ToTokens
```

功能：实现 [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Int8](../../core/core_package_api/core_package_intrinsics.md#int8) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let int8: Int8 = 127

    // 输出 toTokens() 的结果
    println("int8.toTokens().dump():")
    int8.toTokens().dump()
}
```

运行结果：

```text
int8.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 127, fileID: 21, line: 70, column: 26
```

### extend Rune <: ToTokens

```cangjie
extend Rune <: ToTokens
```

功能：实现 [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Rune](../../core/core_package_api/core_package_intrinsics.md#rune) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let rune: Rune = 'X'

    // 输出 toTokens() 的结果
    println("rune.toTokens().dump():")
    rune.toTokens().dump()
}
```

运行结果：

```text
rune.toTokens().dump():
description: char_literal, token_id: 146, token_literal_value: X, fileID: 21, line: 148, column: 26
```

### extend String <: ToTokens

```cangjie
extend String <: ToTokens
```

功能：实现 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [String](../../core/core_package_api/core_package_structs.md#struct-string) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let string: String = "hello world"

    // 输出 toTokens() 的结果
    println("string.toTokens().dump():")
    string.toTokens().dump()
}
```

运行结果：

```text
string.toTokens().dump():
description: double_quoted_string_literal, token_id: 147, token_literal_value: hello world, fileID: 21, line: 204, column: 16
```

### extend Token <: ToTokens

```cangjie
extend Token <: ToTokens
```

功能：实现 [Token](ast_package_structs.md#struct-token) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Token](ast_package_structs.md#struct-token) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let token: Token = Token(TokenKind.AT, "@")

    // 输出 toTokens() 的结果
    println("token.toTokens().dump():")
    token.toTokens().dump()
}
```

运行结果：

```text
token.toTokens().dump():
description: at, token_id: 51, token_literal_value: @, fileID: 1, line: 4, column: 24
```

### extend Tokens <: ToTokens

```cangjie
extend Tokens <: ToTokens
```

功能：实现 [Tokens](ast_package_classes.md#class-tokens) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [Tokens](ast_package_classes.md#class-tokens) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let tokens: Tokens = quote(1 + 1)

    // 输出 toTokens() 的结果
    println("tokens.toTokens().dump():")
    tokens.toTokens().dump()
}
```

运行结果：

```text
tokens.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 1, fileID: 1, line: 4, column: 32
description: add, token_id: 12, token_literal_value: +, fileID: 1, line: 4, column: 34
description: integer_literal, token_id: 139, token_literal_value: 1, fileID: 1, line: 4, column: 36
```

### extend UInt16 <: ToTokens

```cangjie
extend UInt16 <: ToTokens
```

功能：实现 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let uint16: UInt16 = 65535

    // 输出 toTokens() 的结果
    println("uint16.toTokens().dump():")
    uint16.toTokens().dump()
}
```

运行结果：

```text
uint16.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 65535, fileID: 21, line: 91, column: 26
```

### extend UInt32 <: ToTokens

```cangjie
extend UInt32 <: ToTokens
```

功能：实现 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let uint32: UInt32 = 4294967295

    // 输出 toTokens() 的结果
    println("uint32.toTokens().dump():")
    uint32.toTokens().dump()
}
```

运行结果：

```text
uint32.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 4294967295, fileID: 21, line: 84, column: 26
```

### extend UInt64 <: ToTokens

```cangjie
extend UInt64 <: ToTokens
```

功能：实现 [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [UInt64](../../core/core_package_api/core_package_intrinsics.md#uint64) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let uint64: UInt64 = 4294967295

    // 输出 toTokens() 的结果
    println("uint64.toTokens().dump():")
    uint64.toTokens().dump()
}
```

运行结果：

```text
uint64.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 4294967295, fileID: 21, line: 77, column: 26
```

### extend UInt8 <: ToTokens

```cangjie
extend UInt8 <: ToTokens
```

功能：实现 [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

父类型：

- [ToTokens](#interface-totokens)

#### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：实现 [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) 类型到 [Tokens](ast_package_classes.md#class-tokens) 类型的转换。

返回值：

- [Tokens](ast_package_classes.md#class-tokens) - 转换后的 [Tokens](ast_package_classes.md#class-tokens)。

示例：

<!-- verify -->
```cangjie
import std.ast.*

main() {
    let uint8: UInt8 = 255

    // 输出 toTokens() 的结果
    println("uint8.toTokens().dump():")
    uint8.toTokens().dump()
}
```

运行结果：

```text
uint8.toTokens().dump():
description: integer_literal, token_id: 139, token_literal_value: 255, fileID: 21, line: 98, column: 26
```
