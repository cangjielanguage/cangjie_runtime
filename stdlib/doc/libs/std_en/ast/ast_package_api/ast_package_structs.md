# Structs

## struct Position

```cangjie
public struct Position <: ToBytes {
    public let fileID: UInt32
    public let line: Int32
    public let column: Int32
    public init()
    public init(fileID: UInt32, line: Int32, column: Int32)
}
```

Function: A data structure representing position information, containing file ID, line number, and column number.

Parent Types:

- [ToBytes](ast_package_interfaces.md#interface-tobytes)

### let column

```cangjie
public let column: Int32
```

Function: Retrieves the column number information.

Type: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32)

### let fileID

```cangjie
public let fileID: UInt32
```

Function: Retrieves the file ID information.

Type: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)

### let line

```cangjie
public let line: Int32
```

Function: Retrieves the line number information.

Type: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32)

### init()

```cangjie
public init()
```

Function: Constructs a default [Position](ast_package_structs.md#struct-position) instance where all member variables `fileID`, `line`, and `column` are set to `0`.

### init(UInt32, Int32, Int32)

```cangjie
public init(fileID: UInt32, line: Int32, column: Int32)
```

Function: Constructs a [Position](ast_package_structs.md#struct-position) instance.

Parameters:

- fileID: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The file ID.
- line: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The line number.
- column: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The column number.

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints the information of the [Position](ast_package_structs.md#struct-position).

### func isEmpty()

```cangjie
public func isEmpty(): Bool
```

Function: Determines whether both the line number and column number are `0`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true when both the line number and column number are `0`.

### func toBytes()

```cangjie
public func toBytes(): Array<UInt8>
```

Function: Serializes the Position type.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - The serialized byte sequence.

### operator func !=(Position)

```cangjie
public operator func !=(r: Position): Bool
```

Function: Compares whether two [Position](ast_package_structs.md#struct-position) instances are unequal.

Parameters:

- r: [Position](ast_package_structs.md#struct-position) - Another position instance to compare with the current position.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true when the two [Position](ast_package_structs.md#struct-position) instances are not completely equal.

### operator func ==(Position)

```cangjie
public operator func ==(r: Position): Bool
```

Function: Compares whether two [Position](ast_package_structs.md#struct-position) instances are equal.

Parameters:

- r: [Position](ast_package_structs.md#struct-position) - Another position instance to compare with the current position.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true when the two [Position](ast_package_structs.md#struct-position) instances are completely equal.

## struct Token

```cangjie
public struct Token <: ToBytes {
    public let kind: TokenKind
    public let value: String
    public let pos: Position
    public var delimiterNum: UInt16 = 1
    public init()
    public init(kind: TokenKind)
    public init(kind: TokenKind, value: String)
}
```

Function: The lexical token type.

Lexical tokens are the smallest units constituting Cangjie source code. A legal list of lexical tokens can generate a syntax tree node after parsing.

Parent Types:

- [ToBytes](ast_package_interfaces.md#interface-tobytes)

### let kind

```cangjie
public let kind: TokenKind
```

Function: The type of the lexical token. Lexical token types include keywords, identifiers, operators, constant values, etc. For details, see the [TokenKind](ast_package_enums.md#enum-tokenkind) section.

Type: [TokenKind](ast_package_enums.md#enum-tokenkind)

### let pos

```cangjie
public let pos: Position
```

Function: The position information of the lexical token in the source code.

Type: [Position](ast_package_structs.md#struct-position)

### let value

```cangjie
public let value: String
```

Function: The literal value of the lexical token.

Type: [String](../../core/core_package_api/core_package_structs.md#struct-string)

### var delimiterNum

```cangjie
public var delimiterNum: UInt16 = 1
```

Function: The number of '#' symbols in a multi-line string.

Type: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)

### prop isSingleQuote

```cangjie
public mut prop isSingleQuote: Bool
```

Function: Indicates whether the lexical token is single quote.

Type: Bool

### init()

```cangjie
public init()
```

Function: Constructs a default [Token](ast_package_structs.md#struct-token) object where the [TokenKind](ast_package_enums.md#enum-tokenkind) type is `ILLEGAL`, `value` is an empty string, and all [Position](ast_package_structs.md#struct-position) member variables are set to 0.

### init(TokenKind)

```cangjie
public init(kind: TokenKind)
```

Function: Constructs a default [Token](ast_package_structs.md#struct-token) object based on the lexical token type.

Parameters:

- kind: [TokenKind](ast_package_enums.md#enum-tokenkind) - The type of the lexical token to construct.

### init(TokenKind, String)

```cangjie
public init(kind: TokenKind, value: String)
```

Function: Constructs a [Token](ast_package_structs.md#struct-token) object based on the lexical token type `kind` and the lexical token value `value`.

Parameters:

- kind: [TokenKind](ast_package_enums.md#enum-tokenkind) - The type of the lexical token to construct.
- value: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The `value` of the lexical token to construct.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the input `kind` and `value` do not match.

### func addPosition(UInt32, Int32, Int32)

```cangjie
public func addPosition(fileID: UInt32, line: Int32, column: Int32): Token
```

Function: Supplements the position information of the lexical token.

Parameters:

- fileID: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - The file ID where the [Token](ast_package_structs.md#struct-token) is located.
- line: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The line number where the [Token](ast_package_structs.md#struct-token) is located.
- column: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The column number where the [Token](ast_package_structs.md#struct-token) is located.

Returns:

- [Token](ast_package_structs.md#struct-token) - The [Token](ast_package_structs.md#struct-token) object with supplemented position information.

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints the information of the [Token](ast_package_structs.md#struct-token).

### func toBytes()

```cangjie
public func toBytes(): Array<UInt8>
```

Function: Serializes the Token type.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)> - The serialized byte sequence.

### operator func !=(Token)

```cangjie
public operator func !=(r: Token): Bool
```

Function: Determines whether two [Token](ast_package_structs.md#struct-token) objects are unequal.

Parameters:

- r: [Token](ast_package_structs.md#struct-token) - Another [Token](ast_package_structs.md#struct-token) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true when the `ID`, value, and position of the two lexical tokens are not identical.

### operator func +(Token)

```cangjie
public operator func +(r: Token): Tokens
```

Function: Adds a [Token](ast_package_structs.md#struct-token) to the current [Token](ast_package_structs.md#struct-token) to obtain a new [Tokens](ast_package_classes.md#class-tokens).

Parameters:

- r: [Token](ast_package_structs.md#struct-token) - Another [Token](ast_package_structs.md#struct-token) object to add.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units after adding new [Tokens](ast_package_classes.md#class-tokens).

### operator func +(Tokens)

```cangjie
public operator func +(r: Tokens): Tokens
```

Function: Adds a [Tokens](ast_package_classes.md#class-tokens) to the current [Token](ast_package_structs.md#struct-token) to obtain a new [Tokens](ast_package_classes.md#class-tokens).

Parameters:

- r: [Tokens](ast_package_classes.md#class-tokens) - Another collection of [Token](ast_package_structs.md#struct-token) objects to be added.

Returns:

- [Tokens](ast_package_classes.md#class-tokens) - The collection of lexical units after adding new [Tokens](ast_package_classes.md#class-tokens).

### operator func ==(Token)

```cangjie
public operator func ==(r: Token): Bool
```

Function: Determines whether two [Token](ast_package_structs.md#struct-token) objects are equal.

Parameters:

- r: [Token](ast_package_structs.md#struct-token) - Another [Token](ast_package_structs.md#struct-token) object to be compared.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if the `ID` types, values, and positions of the two lexical units are identical.