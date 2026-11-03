# Enums

## enum DiagReportLevel

```cangjie
public enum DiagReportLevel {
    | ERROR
    | WARNING
}
```

Function: Represents the information level of error reporting interface, supporting two levels: `ERROR` and `WARNING`.

### ERROR

```cangjie
ERROR
```

Function: Constructs an enum instance representing ERROR.

### WARNING

```cangjie
WARNING
```

Function: Constructs an enum instance representing WARNING.

### func level()

```cangjie
public func level(): Int32
```

Function: Returns the integer value corresponding to the enum.

Returns:

- [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The integer value corresponding to the enum. `ERROR` returns 0, `WARNING` returns 1.

## enum ImportKind

```cangjie
public enum ImportKind <: ToString {
    | Single
    | Alias
    | All
    | Multi
}
```

Function: Represents the type of import statement.

Parent type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

### Single

```cangjie
Single
```

Function: Represents single import, e.g. `import a.b`.

### Alias

```cangjie
Alias
```

Function: Represents alias import, e.g. `import a.b as c`.

### All

```cangjie
All
```

Function: Represents wildcard import, e.g. `import a.b.*`.

### Multi

```cangjie
Multi
```

Function: Represents multiple imports, e.g. `import a.{b, c, d}`.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts [ImportKind](ast_package_enums.md#enum-importkind) type to string representation.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The converted string value of [ImportKind](ast_package_enums.md#enum-importkind).

## enum TokenKind

```cangjie
public enum TokenKind <: ToString {
    | DOT                          /*  "."           */
    | COMMA                        /*  ","           */
    | LPAREN                       /*  "("           */
    | RPAREN                       /*  ")"           */
    | LSQUARE                      /*  "["           */
    | RSQUARE                      /*  "]"           */
    | LCURL                        /*  "{"           */
    | RCURL                        /*  "}"           */
    | EXP                          /*  "**"          */
    | MUL                          /*  "*"           */
    | MOD                          /*  "%"           */
    | DIV                          /*  "/"           */
    | ADD                          /*  "+"           */
    | SUB                          /*  "-"           */
    | INCR                         /*  "++"          */
    | DECR                         /*  "--"          */
    | AND                          /*  "&&"          */
    | OR                           /*  "||"          */
    | COALESCING                   /*  "??"          */
    | PIPELINE                     /*  "|>"          */
    | COMPOSITION                  /*  "~>"          */
    | NOT                          /*  "!"           */
    | BITAND                       /*  "&"           */
    | BITOR                        /*  "|"           */
    | BITXOR                       /*  "^"           */
    | BITNOT                       /*  "~"           */
    | LSHIFT                       /*  "<<"          */
    | RSHIFT                       /*  ">>"          */
    | COLON                        /*  ":"           */
    | SEMI                         /*  ";"           */
    | ASSIGN                       /*  "="           */
    | ADD_ASSIGN                   /*  "+="          */
    | SUB_ASSIGN                   /*  "-="          */
    | MUL_ASSIGN                   /*  "*="          */
    | EXP_ASSIGN                   /*  "**="         */
    | DIV_ASSIGN                   /*  "/="          */
    | MOD_ASSIGN                   /*  "%="          */
    | AND_ASSIGN                   /*  "&&="         */
    | OR_ASSIGN                    /*  "||="         */
    | BITAND_ASSIGN                /*  "&="          */
    | BITOR_ASSIGN                 /*  "|="          */
    | BITXOR_ASSIGN                /*  "^="          */
    | LSHIFT_ASSIGN                /*  "<<="         */
    | RSHIFT_ASSIGN                /*  ">>="         */
    | ARROW                        /*  "->"          */
    | BACKARROW                    /*  "<-"          */
    | DOUBLE_ARROW                 /*  "=>"          */
    | RANGEOP                      /*  ".."          */
    | CLOSEDRANGEOP                /*  "..="         */
    | ELLIPSIS                     /*  "..."         */
    | HASH                         /*  "#"           */
    | AT                           /*  "@"           */
    | QUEST                        /*  "?"           */
    | LT                           /*  "<"           */
    | GT                           /*  ">"           */
    | LE                           /*  "<="          */
    | GE                           /*  ">="          */
    | IS                           /*  "is"          */
    | AS                           /*  "as"          */
    | NOTEQ                        /*  "!="          */
    | EQUAL                        /*  "=="          */
    | WILDCARD                     /*  "_"           */
    | INT8                         /*  "Int8"        */
    | INT16                        /*  "Int16"       */
    | INT32                        /*  "Int32"       */
    | INT64                        /*  "Int64"       */
    | INTNATIVE                    /*  "IntNative"   */
    | UINT8                        /*  "UInt8"       */
    | UINT16                       /*  "UInt16"      */
    | UINT32                       /*  "UInt32"      */
    | UINT64                       /*  "UInt64"      */
    | UINTNATIVE                   /*  "UIntNative"  */
    | FLOAT16                      /*  "Float16"     */
    | FLOAT32                      /*  "Float32"     */
    | FLOAT64                      /*  "Float64"     */
    | RUNE                         /*  "Rune"        */
    | BOOLEAN                      /*  "Bool"        */
    | NOTHING                      /*  "Nothing"     */
    | UNIT                         /*  "Unit"        */
    | STRUCT                       /*  "struct"      */
    | ENUM                         /*  "enum"        */
    | VARRAY                       /*  "VArray"      */
    | THISTYPE                     /*  "This"        */
    | PACKAGE                      /*  "package"     */
    | IMPORT                       /*  "import"      */
    | CLASS                        /*  "class"       */
    | INTERFACE                    /*  "interface"   */
    | FUNC                         /*  "func"        */
    | MACRO                        /*  "macro"       */
    | QUOTE                        /*  "quote"       */
    | DOLLAR                       /*  "$"           */
    | LET                          /*  "let"         */
    | VAR                          /*  "var"         */
    | CONST                        /*  "const"       */
    | TYPE                         /*  "type"        */
    | INIT                         /*  "init"        */
    | THIS                         /*  "this"        */
    | SUPER                        /*  "super"       */
    | IF                           /*  "if"          */
    | ELSE                         /*  "else"        */
    | CASE                         /*  "case"        */
    | TRY                          /*  "try"         */
    | CATCH                        /*  "catch"       */
    | FINALLY                      /*  "finally"     */
    | FOR                          /*  "for"         */
    | DO                           /*  "do"          */
    | WHILE                        /*  "while"       */
    | THROW                        /*  "throw"       */
    | RETURN                       /*  "return"      */
    | CONTINUE                     /*  "continue"    */
    | BREAK                        /*  "break"       */
    | IN                           /*  "in"          */
    | NOT_IN                       /*  "!in"         */
    | MATCH                        /*  "match"       */
    | WHERE                        /*  "where"       */
    | EXTEND                       /*  "extend"      */
    | WITH                         /*  "with"        */
    | PROP                         /*  "prop"        */
    | STATIC                       /*  "static"      */
    | PUBLIC                       /*  "public"      */
    | PRIVATE                      /*  "private"     */
    | INTERNAL                     /*  "internal"    */
    | PROTECTED                    /*  "protected"   */
    | OVERRIDE                     /*  "override"    */
    | REDEF                        /*  "redef"       */
    | ABSTRACT                     /*  "abstract"    */
    | SEALED                       /*  "sealed"      */
    | OPEN                         /*  "open"        */
    | FOREIGN                      /*  "foreign"     */
    | INOUT                        /*  "inout"       */
    | MUT                          /*  "mut"         */
    | UNSAFE                       /*  "unsafe"      */
    | OPERATOR                     /*  "operator"    */
    | SPAWN                        /*  "spawn"       */
    | SYNCHRONIZED                 /*  "synchronized" */
    | UPPERBOUND                   /*  "<:"          */
    | MAIN                         /*  "main"        */
    | IDENTIFIER                   /*  "x"           */
    | PACKAGE_IDENTIFIER           /*  e.g. "x-y"    */
    | INTEGER_LITERAL              /*  e.g. "1"      */
    | RUNE_BYTE_LITERAL            /*  e.g. "b'x'"   */
    | FLOAT_LITERAL                /*  e.g. "'1.0'"  */
    | COMMENT                      /*  e.g. "/*xx*/" */
    | NL                           /*  newline       */
    | END                          /*  end of file   */
    | SENTINEL                     /*  ";"           */
    | RUNE_LITERAL                 /*  e.g. "r'x'"   */
    | STRING_LITERAL               /*  e.g. ""xx""   */
    | SINGLE_QUOTED_STRING_LITERAL /*  e.g. "'xx'"   */
    | JSTRING_LITERAL              /*  e.g. "J"xx""  */
    | MULTILINE_STRING             /*  e.g. """"aaa"""" */
    | MULTILINE_RAW_STRING         /*  e.g. "#"aaa"#" */
    | BOOL_LITERAL                 /*  "true" or "false" */
    | UNIT_LITERAL                 /*  "()"          */
    | DOLLAR_IDENTIFIER            /*  e.g. "$x"     */
    | ANNOTATION                   /*  e.g. "@When"  */
    | AT_EXCL                      /*  e.g. "@!"     */
    | ILLEGAL
    | COMMON                       /*  "common"       */
    | SPECIFIC                     /*  "specific"     */
    | HANDLE                       /*  "handle"      */
    | PERFORM                      /*  "perform"     */
    | RESUME                       /*  "resume"      */
    | THROWING                     /*  "throwing"    */
    | DOUBLE_COLON                 /*  "::"          */
    | FEATURES                     /*  "features"    */
    | ...
}
```

Function: Represents all lexical structures in Cangjie compilation, including symbols, keywords, identifiers, newlines, etc.

Parent type:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

### ABSTRACT

```cangjie
ABSTRACT
```

Function: Constructs an enum instance representing `abstract`.

### ADD

```cangjie
ADD
```

Function: Constructs an enum instance representing `+`.

### ADD_ASSIGN

```cangjie
ADD_ASSIGN
```

Function: Constructs an enum instance representing `+=`.

### AND

```cangjie
AND
```

Function: Constructs an enumeration instance representing `&&`.

### AND_ASSIGN

```cangjie
AND_ASSIGN
```

Function: Constructs an enumeration instance representing `&&=`.

### ANNOTATION

```cangjie
ANNOTATION
```

Function: Constructs an enumeration instance representing *annotation*.

### ARROW

```cangjie
ARROW
```

Function: Constructs an enumeration instance representing `->`.

### AS

```cangjie
AS
```

Function: Constructs an enumeration instance representing `as`.

### ASSIGN

```cangjie
ASSIGN
```

Function: Constructs an enumeration instance representing `=`.

### AT

```cangjie
AT
```

Function: Constructs an enumeration instance representing `@`.

### AT_EXCL

```cangjie
AT_EXCL
```

Function: Constructs an enumeration instance representing `@!`.

### BACKARROW

```cangjie
BACKARROW
```

Function: Constructs an enumeration instance representing `<-`.

### BITAND

```cangjie
BITAND
```

Function: Constructs an enumeration instance representing `&`.

### BITAND_ASSIGN

```cangjie
BITAND_ASSIGN
```

Function: Constructs an enumeration instance representing `&=`.

### BITNOT

```cangjie
BITNOT
```

Function: Constructs an enumeration instance representing `~`.

### BITOR

```cangjie
BITOR
```

Function: Constructs an enumeration instance representing `|`.

### BITOR_ASSIGN

```cangjie
BITOR_ASSIGN
```

Function: Constructs an enumeration instance representing `|=`.

### BITXOR

```cangjie
BITXOR
```

Function: Constructs an enumeration instance representing `^`.

### BITXOR_ASSIGN

```cangjie
BITXOR_ASSIGN
```

Function: Constructs an enumeration instance representing `^=`.

### BOOLEAN

```cangjie
BOOLEAN
```

Function: Constructs an enumeration instance representing `bool`.

### BOOL_LITERAL

```cangjie
BOOL_LITERAL
```

Function: Constructs an enumeration instance representing *boolean literal*.

### BREAK

```cangjie
BREAK
```

Function: Constructs an enumeration instance representing `break`.

### CASE

```cangjie
CASE
```

Function: Constructs an enumeration instance representing `case`.

### CATCH

```cangjie
CATCH
```

Function: Constructs an enumeration instance representing `catch`.

### CLASS

```cangjie
CLASS
```

Function: Constructs an enumeration instance representing `class`.

### CLOSEDRANGEOP

```cangjie
CLOSEDRANGEOP
```

Function: Constructs an enumeration instance representing `..=`.

### COALESCING

```cangjie
COALESCING
```

Function: Constructs an enumeration instance representing `??`.

### COLON

```cangjie
COLON
```

Function: Constructs an enumeration instance representing `:`.

### COMMA

```cangjie
COMMA
```

Function: Constructs an enumeration instance representing `,`.

### COMMENT

```cangjie
COMMENT
```

Function: Constructs an enumeration instance representing *comment*.

### COMMON

```cangjie
COMMON
```

Function: Constructs an enumeration instance representing `common`.

### COMPOSITION

```cangjie
COMPOSITION
```

Function: Constructs an enumeration instance representing `~>`.

### CONST

```cangjie
CONST
```

Function: Constructs an enumeration instance representing `const`.

### CONTINUE

```cangjie
CONTINUE
```

Function: Constructs an enumeration instance representing `continue`.

### DECR

```cangjie
DECR
```

Function: Constructs an enumeration instance representing `--`.

### DIV

```cangjie
DIV
```

Function: Constructs an enumeration instance representing `/`.

### DIV_ASSIGN

```cangjie
DIV_ASSIGN
```

Function: Constructs an enumeration instance representing `/=`.

### DO

```cangjie
DO
```

Function: Constructs an enumeration instance representing `do`.

### DOLLAR

```cangjie
DOLLAR
```

Function: Constructs an enumeration instance representing `$`.

### DOLLAR_IDENTIFIER

```cangjie
DOLLAR_IDENTIFIER
```

Function: Constructs an enumeration instance representing *interpolated string*.

### DOT

```cangjie
DOT
```

Function: Constructs an enumeration instance representing `.`.

### DOUBLE_ARROW

```cangjie
DOUBLE_ARROW
```

Function: Constructs an enumeration instance representing `=>`.

### DOUBLE_COLON

```cangjie
DOUBLE_COLON
```

Function: Constructs an enumeration instance representing `::`.

### ELLIPSIS

```cangjie
ELLIPSIS
```

Function: Constructs an enumeration instance representing `...`.

### ELSE

```cangjie
ELSE
```

Function: Constructs an enumeration instance representing `else`.

### END

```cangjie
END
```

Function: Constructs an enumeration instance representing `EOF`.

### ENUM

```cangjie
ENUM
```

Function: Constructs an enumeration instance representing `enum`.

### EQUAL

```cangjie
EQUAL
```

Function: Constructs an enumeration instance representing `==`.

### EXP

```cangjie
EXP
```

Function: Constructs an enumeration instance representing `**`.

### EXP_ASSIGN

```cangjie
EXP_ASSIGN
```

Function: Constructs an enumeration instance representing `**=`.

### EXTEND

```cangjie
EXTEND
```

Function: Constructs an enumeration instance representing `extend`.

### FEATURES

```cangjie
FEATURES
```

Function: Constructs an enumeration instance representing `features`.

### FINALLY

```cangjie
FINALLY
```

Function: Constructs an enumeration instance representing `finally`.

### FLOAT16

```cangjie
FLOAT16
```

Function: Constructs an enumeration instance representing `float16`.

### FLOAT32

```cangjie
FLOAT32
```

Function: Constructs an enumeration instance representing `float32`.

### FLOAT64

```cangjie
FLOAT64
```

Function: Constructs an enumeration instance representing `float64`.

### FLOAT_LITERAL

```cangjie
FLOAT_LITERAL
```

Function: Constructs an enumeration instance representing *floating-point literal*.

### FOR

```cangjie
FOR
```

Function: Constructs an enumeration instance representing `for`.

### FOREIGN

```cangjie
FOREIGN
```

Function: Constructs an enumeration instance representing `foreign`.

### FUNC

```cangjie
FUNC
```

Function: Constructs an enumeration instance representing `func`.

### GE

```cangjie
GE
```

Function: Constructs an enumeration instance representing `>=`.

### GT

```cangjie
GT
```

Function: Constructs an enumeration instance representing `>`.

### HANDLE

```cangjie
HANDLE
```

Function: Construct an enumeration instance representing `handle`.

### HASH

```cangjie
HASH
```

Function: Constructs an enumeration instance representing `#`.

### IDENTIFIER

```cangjie
IDENTIFIER
```

Function: Constructs an enumeration instance representing *identifier*.

### PACKAGE_IDENTIFIER

```cangjie
PACKAGE_IDENTIFIER
```

Function: Constructs an enumeration instance representing *package identifier*.

### IF

```cangjie
IF
```

Function: Constructs an enumeration instance representing `if`.

### ILLEGAL

```cangjie
ILLEGAL
```

Function: Constructs an enumeration instance representing *illegal*.

### IMPORT

```cangjie
IMPORT
```

Function: Constructs an enumeration instance representing `import`.

### IN

```cangjie
IN
```

Function: Constructs an enumeration instance representing `in`.

### INCR

```cangjie
INCR
```

Function: Constructs an enumeration instance representing `++`.

### INIT

```cangjie
INIT
```

Function: Constructs an enumeration instance representing `init`.

### INOUT

```cangjie
INOUT
```

Function: Constructs an enumeration instance representing `inout`.

### INT16

```cangjie
INT16
```

Function: Constructs an enumeration instance representing `int16`.

### INT32

```cangjie
INT32
```

Function: Constructs an enumeration instance representing `int32`.

### INT64

```cangjie
INT64
```

Function: Constructs an enumeration instance representing `int64`.

### INT8

```cangjie
INT8
```

Function: Constructs an enumeration instance representing `int8`.

### INTEGER_LITERAL

```cangjie
INTEGER_LITERAL
```

Function: Constructs an enumeration instance representing *integer literal*.

### INTERFACE

```cangjie
INTERFACE
```

Function: Constructs an enumeration instance representing `interface`.

### INTERNAL

```cangjie
INTERNAL
```

Function: Constructs an enumeration instance representing `internal`.

### INTNATIVE

```cangjie
INTNATIVE
```

Function: Constructs an enumeration instance representing `intnative`.

### IS

```cangjie
IS
```

Function: Constructs an enumeration instance representing `is`.

### JSTRING_LITERAL

```cangjie
JSTRING_LITERAL
```

Function: Constructs an enumeration instance representing a JavaSTRING literal.

### LCURL

```cangjie
LCURL
```

Function: Constructs an enumeration instance representing `{`.

### LE

```cangjie
LE
```

Function: Constructs an enumeration instance representing `<=`.

### LET

```cangjie
LET
```

Function: Constructs an enumeration instance representing `let`.

### LPAREN

```cangjie
LPAREN
```

Function: Constructs an enumeration instance representing `(`.

### LSHIFT

```cangjie
LSHIFT
```

Function: Constructs an enumeration instance representing `<<`.

### LSHIFT_ASSIGN

```cangjie
LSHIFT_ASSIGN
```

Function: Constructs an enumeration instance representing `<<=`.

### LSQUARE

```cangjie
LSQUARE
```

Function: Constructs an enumeration instance representing `[`.

### LT

```cangjie
LT
```

Function: Constructs an enumeration instance representing `<`.

### MACRO

```cangjie
MACRO
```

Function: Constructs an enumeration instance representing `macro`.

### MAIN

```cangjie
MAIN
```

Function: Constructs an enumeration instance representing `main`.

### MATCH

```cangjie
MATCH
```

Function: Constructs an enumeration instance representing `match`.

### MOD

```cangjie
MOD
```

Function: Constructs an enumeration instance representing `%`.

### MOD_ASSIGN

```cangjie
MOD_ASSIGN
```

Function: Constructs an enumeration instance representing `%=`.

### MUL

```cangjie
MUL
```

Function: Constructs an enumeration instance representing `*`.

### MULTILINE_RAW_STRING

```cangjie
MULTILINE_RAW_STRING
```

Function: Constructs an enumeration instance representing a *multiline raw string literal*.

### MULTILINE_STRING

```cangjie
MULTILINE_STRING
```

Function: Constructs an enumeration instance representing a *multiline string literal*.

### MUL_ASSIGN

```cangjie
MUL_ASSIGN
```

Function: Constructs an enumeration instance representing `*=`.

### MUT

```cangjie
MUT
```

Function: Constructs an enumeration instance representing `mut`.

### NL

```cangjie
NL
```

Function: Constructs an enumeration instance representing a *newline character*.

### NOT

```cangjie
NOT
```

Function: Constructs an enumeration instance representing `!`.

### NOTEQ

```cangjie
NOTEQ
```

Function: Constructs an enumeration instance representing `!=`.

### NOTHING

```cangjie
NOTHING
```

Function: Constructs an enumeration instance representing `nothing`.

### NOT_IN

```cangjie
NOT_IN
```

Function: Constructs an enumeration instance representing `!in`.

### OPEN

```cangjie
OPEN
```

Function: Constructs an enumeration instance representing `open`.

### OPERATOR

```cangjie
OPERATOR
```

Function: Constructs an enumeration instance representing `operator`.

### OR

```cangjie
OR
```

Function: Constructs an enumeration instance representing `||`.

### OR_ASSIGN

```cangjie
OR_ASSIGN
```

Function: Constructs an enumeration instance representing `||=`.

### OVERRIDE

```cangjie
OVERRIDE
```

Function: Constructs an enumeration instance representing `override`.

### PACKAGE

```cangjie
PACKAGE
```

Function: Constructs an enumeration instance representing `package`.

### PERFORM

```cangjie
PERFORM
```

Function: Construct an enumeration instance representing `perform`.

### PIPELINE

```cangjie
PIPELINE
```

Function: Constructs an enumeration instance representing `|>`.

### PRIVATE

```cangjie
PRIVATE
```

Function: Constructs an enumeration instance representing `private`.

### PROP

```cangjie
PROP
```

Function: Constructs an enumeration instance representing `prop`.

### PROTECTED

```cangjie
PROTECTED
```

Function: Constructs an enumeration instance representing `protected`.

### PUBLIC

```cangjie
PUBLIC
```

Function: Constructs an enumeration instance representing `public`.

### QUEST

```cangjie
QUEST
```

Function: Constructs an enumeration instance representing `?`.

### QUOTE

```cangjie
QUOTE
```

Function: Constructs an enumeration instance representing `quote`.

### RANGEOP

```cangjie
RANGEOP
```

Function: Constructs an enumeration instance representing `..`.

### RCURL

```cangjie
RCURL
```

Function: Constructs an enum instance representing `}`.

### REDEF

```cangjie
REDEF
```

Function: Constructs an enum instance representing `redef`.

### RESUME

```cangjie
RESUME
```

Function: Construct an enum instance representing `resume`.

### RETURN

```cangjie
RETURN
```

Function: Constructs an enum instance representing `return`.

### RPAREN

```cangjie
RPAREN
```

Function: Constructs an enum instance representing `)`.

### RSHIFT

```cangjie
RSHIFT
```

Function: Constructs an enum instance representing `>>`.

### RSHIFT_ASSIGN

```cangjie
RSHIFT_ASSIGN
```

Function: Constructs an enum instance representing `>>=`.

### RSQUARE

```cangjie
RSQUARE
```

Function: Constructs an enum instance representing `]`.

### RUNE

```cangjie
RUNE
```

Function: Constructs an enum instance representing `Rune`.

### RUNE_BYTE_LITERAL

```cangjie
RUNE_BYTE_LITERAL
```

Function: Constructs an enum instance representing a *rune byte literal*.

### RUNE_LITERAL

```cangjie
RUNE_LITERAL
```

Function: Constructs an enum instance representing a *rune literal*.

### SEALED

```cangjie
SEALED
```

Function: Constructs an enum instance representing `sealed`.

### SEMI

```cangjie
SEMI
```

Function: Constructs an enum instance representing `;`.

### SENTINEL

```cangjie
SENTINEL
```

Function: Constructs an enum instance representing `;`.

### SINGLE_QUOTED_STRING_LITERAL

```cangjie
SINGLE_QUOTED_STRING_LITERAL
```

Function: Constructs an enum instance representing a *single-quoted string literal*.

### SPAWN

```cangjie
SPAWN
```

Function: Constructs an enum instance representing `spawn`.

### STATIC

```cangjie
STATIC
```

Function: Constructs an enum instance representing `static`.

### STRING_LITERAL

```cangjie
STRING_LITERAL
```

Function: Constructs an enum instance representing a *double-quoted string literal*.

### STRUCT

```cangjie
STRUCT
```

Function: Constructs an enum instance representing `struct`.

### SUB

```cangjie
SUB
```

Function: Constructs an enum instance representing `-`.

### SUB_ASSIGN

```cangjie
SUB_ASSIGN
```

Function: Constructs an enum instance representing `-=`.

### SUPER

```cangjie
SUPER
```

Function: Constructs an enum instance representing `super`.

### SYNCHRONIZED

```cangjie
SYNCHRONIZED
```

Function: Constructs an enum instance representing `synchronized`.

### SPECIFIC

```cangjie
SPECIFIC
```

Function: Constructs an enumeration instance representing `specific`.


### THIS

```cangjie
THIS
```

Function: Constructs an enum instance representing `this`.

### THISTYPE

```cangjie
THISTYPE
```

Function: Constructs an enum instance representing `This`.

### THROW

```cangjie
THROW
```

Function: Constructs an enum instance representing `throw`.

### THROWING

```cangjie
THROWING
```

Function: Construct an enum instance representing `throwing`.

### TRY

```cangjie
TRY
```

Function: Constructs an enum instance representing `try`.

### TYPE

```cangjie
TYPE
```

Function: Constructs an enum instance representing `type`.

### UINT16

```cangjie
UINT16
```

Function: Constructs an enum instance representing `uint16`.

### UINT32

```cangjie
UINT32
```

Function: Constructs an enum instance representing `uint32`.

### UINT64

```cangjie
UINT64
```

Function: Constructs an enum instance representing `uint64`.

### UINT8

```cangjie
UINT8
```

Function: Constructs an enum instance representing `uint8`.

### UINTNATIVE

```cangjie
UINTNATIVE
```

Function: Constructs an enum instance representing `uintnative`.

### UNIT

```cangjie
UNIT
```

Function: Constructs an enum instance representing `unit`.

### UNIT_LITERAL

```cangjie
UNIT_LITERAL
```

Function: Constructs an enum instance representing a `unit` literal.

### UNSAFE

```cangjie
UNSAFE
```

Function: Constructs an enum instance representing `unsafe`.

### UPPERBOUND

```cangjie
UPPERBOUND
```

Function: Constructs an enum instance representing `<:`.

### VAR

```cangjie
VAR
```

Function: Constructs an enum instance representing `var`.

### VARRAY

```cangjie
VARRAY
```

Function: Constructs an enumeration instance representing `varray`.

### WHERE

```cangjie
WHERE
```

Function: Constructs an enumeration instance representing `where`.

### WHILE

```cangjie
WHILE
```

Function: Constructs an enumeration instance representing `while`.

### WILDCARD

```cangjie
WILDCARD
```

Function: Constructs an enumeration instance representing `_`.

### WITH

```cangjie
WITH
```

Function: Constructs an enumeration instance representing `with`.

### func !=(TokenKind)

```cangjie
public operator func !=(right: TokenKind): Bool
```

Function: Overloads the inequality operator to compare two [TokenKind](ast_package_enums.md#enum-tokenkind) instances for inequality.

Parameters:

- right: [TokenKind](ast_package_enums.md#enum-tokenkind) - The enumeration instance to be compared.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Boolean type.

### func ==(TokenKind)

```cangjie
public operator func ==(right: TokenKind): Bool
```

Function: Overloads the equality operator to compare two [TokenKind](ast_package_enums.md#enum-tokenkind) instances for equality.

Parameters:

- right: [TokenKind](ast_package_enums.md#enum-tokenkind) - The enumeration instance to be compared.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Boolean type.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts the [TokenKind](ast_package_enums.md#enum-tokenkind) type into its string representation.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string value converted from [TokenKind](ast_package_enums.md#enum-tokenkind).
