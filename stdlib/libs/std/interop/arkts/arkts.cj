/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.interop.arkts

// These declarations use `public foreign class` and body-less members, which
// require a compiler that accepts the ArkTS interop syntax. Build this package
// with such a compiler; an older one fails in the parse phase.

/**
 * `ArkTSType` is the root interface of all ArkTS interop types. The design goal
 * is a bidirectional mapping to the ArkTS `unknown` type: a value that satisfies
 * the `ArkTSType` constraint can be assigned to a variable of this type. The
 * mapping itself, and the relation that `@ArkTS`-annotated types implicitly
 * implement this interface, are not available in this release and will be
 * available in a later release.
 */
@ArkTS
public interface ArkTSType {}

// The preset declarations below are the stdlib-predefined ArkTS types. The
// compiler recognises ArkTSArray<T>, ArkTSString and ArkTSType as presets only
// when the declaration belongs to this exact package; a same-name declaration
// in any other package stays an ordinary type and never receives the deferral
// diagnostic. The reference semantics and the member-level conversion are
// compiler-generated glue code, not part of these declarations: an
// ArkTSArray<T'>/ArkTSString/ArkTSType position in an @ArkTS foreign signature
// is not accepted yet and reports
// sema_arkts_foreign_external_type_deferred.

/**
 * `ArkTSArray<T>` is the stdlib-predefined external ArkTS type for the ArkTS
 * `T[]`/`Array<T>` object. By design an instance references an ArkTS array
 * object, so modifications performed on either the ArkTS side or the Cangjie
 * side are visible on the other side; that reference semantics is not
 * available in this release and will be available in a later release.
 *
 * The members below are the subset shipped in this version: 14 of the 30
 * designed members. They are declared without bodies in the foreign class
 * bound to ArkTS `Array`, and the rest will be available in a later release.
 * Every member is implemented on the ArkTS side.
 */
@ArkTS[foreignName: "Array"]
public foreign class ArkTSArray<T> {
    public init(arrayLength: Float64)
    public init(@RestParam items: Array<T>)
    public static func isArray(arg: ArkTSType): Bool
    public static prop prototype: ArkTSArray<ArkTSType>
    public prop length: Float64
    public func pop(): Option<T>
    public func push(@RestParam items: Array<T>): Float64
    public func join(separator!: Option<String> = None): String
    public func reverse(): ArkTSArray<T>
    public func shift(): Option<T>
    public func unshift(@RestParam items: Array<T>): Float64
    public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSArray<T>
    public func indexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
    public func lastIndexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64
}

/**
 * `ArkTSString` is the stdlib-predefined external ArkTS type corresponding to
 * the ArkTS `string`. It is a handle to a JS string value and can carry either
 * a primitive string or a `String` wrapper object. By design an instance
 * carries the value by reference, so crossing the boundary does not copy the
 * string contents and the string operations run on the ArkTS side with the
 * same reference semantics as `ArkTSArray<T>`. `charAt`/`toString` necessarily
 * copy the contents into a Cangjie `String`; `slice`/`substring`/
 * `toUpperCase`/`toLowerCase` return a primitive JS string, carried by the
 * returned `ArkTSString` handle. That reference semantics is not available in
 * this release and will be available in a later release.
 *
 * The members below are the subset shipped in this version: 11 of the 47
 * designed members, declared without bodies, under the same package and name
 * contract as `ArkTSArray<T>`; the rest will be available in a later release.
 */
@ArkTS[foreignName: "String"]
public foreign class ArkTSString {
    public init(value!: Option<String> = None)
    public prop length: Float64
    public func charAt(pos: Float64): String
    public func charCodeAt(pos: Float64): Float64
    public func indexOf(searchString: String, position!: Option<Float64> = None): Float64
    public func lastIndexOf(searchString: String, position!: Option<Float64> = None): Float64
    public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSString
    public func substring(start: Float64, end!: Option<Float64> = None): ArkTSString
    public func toUpperCase(): ArkTSString
    public func toLowerCase(): ArkTSString
    public func toString(): String
}

/**
 * `ArkTSFunc<F>` maps the ArkTS function types: `F` is a Cangjie function type
 * whose parameter and return types satisfy the `ArkTSType` constraint.
 */

// The constraints below are not expressible in the current source language and
// remain compiler-builtin behaviors:
// - the parent type `Function` does not exist in stdlib yet, so the
//   inheritance `ArkTSFunc<F> <: Function` cannot be declared;
// - the constraint that `F` is a Cangjie function type satisfying the
//   `ArkTSType` constraint is checked by the compiler, not by a where-clause;
// - construction via `ArkTSFunc<F>(f)` and direct call of the value are
//   compiler-builtin behaviors (like `CFunc<F>`). A Cangjie function type is
//   not an ArkTS-compatible type, so the compiler special-cases this
//   constructor instead of treating it as an ordinary foreign member.
@ArkTS
public foreign class ArkTSFunc<F> {
    public init(f: F)
}

/**
 * `ArkTSFuncWithThis<ThisT, F>` maps the ArkTS function types that declare a
 * `this` parameter: `ThisT` is the mapped type of that ArkTS `this` parameter
 * and `F` is a Cangjie function type satisfying the `ArkTSType` constraint. The
 * value is not directly callable.
 *
 * Like `ArkTSFunc<F>` it is special-cased by the compiler. It has no public
 * constructor: its values come only from `@HasThis`-annotated `foreign func`
 * declarations, and `bind` returns a callable `ArkTSFunc<F>` bound to
 * `thisArg`.
 */
@ArkTS
public foreign class ArkTSFuncWithThis<ThisT, F> {
    public func bind(thisArg: ThisT): ArkTSFunc<F>
}
