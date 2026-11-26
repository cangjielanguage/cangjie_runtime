/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.interop.arkts

// The generated preset wrapper bodies spell the interop surface through the
// compiler-injected package imports and name their exception carriers directly
// (ForeignRuntimeException from cj_arkts_context_v1, BusinessException from
// ohos.business_exception; ExternConversionException is this package's own).
// The wrapper reference holder spells `JSValue` as a bare type, so the carrier
// declaration must be importable by name here: the single-member import below
// puts it on the file's imported-name index (a multi import would not). The
// prepared `ArkTSArray<T>` members spell their element constraint and the
// stored `JSObject` carrier the same way, so both names are single-member
// imported too.
import ohos.ark_interop
import ohos.ark_interop.JSValue
import ohos.ark_interop.JSObject
import ohos.ark_interop.JSInteropType
import cj_arkts_context_v1

// These declarations use `public foreign class` and body-less members, which
// require a compiler that accepts the ArkTS interop syntax. Build this package
// with such a compiler; an older one fails in the parse phase. Like the
// local-mode APIs, every declaration is guarded by @When[arkts_interop == "on"],
// so a build that passes `--cfg arkts_interop=off` (the default) yields an empty
// package instead of a parse error.

/**
 * `ArkTSType` is the root interface of all ArkTS interop types. The design goal
 * is a bidirectional mapping to the ArkTS `unknown` type: a value that satisfies
 * the `ArkTSType` constraint can be assigned to a variable of this type. The
 * mapping itself, and the relation that `@ArkTS`-annotated types implicitly
 * implement this interface, are not available in this release and will be
 * available in a later release.
 */
@When[arkts_interop == "on"]
@ArkTS
public interface ArkTSType {}

// The preset declarations below are the stdlib-predefined ArkTS types. The
// compiler recognises ArkTSArray<T>, ArkTSString and ArkTSType as presets only
// when the declaration belongs to this exact package; a same-name declaration
// in any other package stays an ordinary type and never receives preset
// treatment. ArkTSString is prepared as an ordinary (non-generic) wrapper and
// ArkTSArray<T> as a prepared generic wrapper: the compiler installs the
// reference storage and the wrapping constructors of both, and the compiler
// generates the ArkTSString member bodies. The ArkTSArray<T> member bodies
// below are written in this source against the hidden `T <: JSInteropType<T>`
// constraint, so every element crossing converts through the runtime contract
// (T.fromJSValue / toJSValue). An ArkTSType position in an @ArkTS foreign
// signature is not accepted yet and reports
// sema_arkts_foreign_external_type_deferred.

/**
 * `ArkTSArray<T>` is the stdlib-predefined external ArkTS type for the ArkTS
 * `T[]`/`Array<T>` object. By design an instance references an ArkTS array
 * object, so modifications performed on either the ArkTS side or the Cangjie
 * side are visible on the other side. The reference semantics is real in this
 * version: the members call through to the same array object, and the class
 * doubles as the mapped type of an `ArkTSArray<T'>` position in an @ArkTS
 * foreign signature (the wrapper stores the JSObject carrier and element
 * conversions follow the `JSInteropType` runtime contract).
 *
 * The element type carries the hidden constraint `T <: JSInteropType<T>`: the
 * types the interop runtime extends with a JSInteropType conformance (the
 * number candidates, Bool, String, Unit, and Option<T'> over a conforming T')
 * are accepted as elements, and every other type - a user class without a
 * JSInteropType conformance included - is rejected at the use site with the
 * ordinary constraint diagnostic.
 *
 * The members below are the subset shipped in this version: 12 of the 30
 * designed members, each implemented on the ArkTS side through the real
 * `Array` object. The static surface that depends on `ArkTSType` values
 * (`isArray`, `prototype`) stays deferred and will be available in a later
 * release together with the remaining designed members.
 */
@When[arkts_interop == "on"]
@ArkTS[foreignName: "Array"]
public class ArkTSArray<T> where T <: JSInteropType<T> {
    // Construction from a length: `new Array(n)` through the global Array
    // class. The elements are holes (the ArkTS semantics); reading one before
    // a write returns undefined, which no JSInteropType conformance accepts,
    // so the array behaves like its ArkTS counterpart.
    public init(arrayLength: Float64) {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let clazz = ctx.global.getProperty("Array").asClass()
        this.__cj_arkts_ref = clazz.new(ctx.number(arrayLength).toJSValue()).asObject()
    }

    // Construction from Cangjie elements: each element converts through its
    // JSInteropType conformance, then the whole list is packaged through the
    // context's array factory.
    public init(items: Array<T>) {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let jsItems = Array<JSValue>(items.size, { i => items[i].toJSValue(ctx) })
        this.__cj_arkts_ref = ctx.array(jsItems).toJSValue().asObject()
    }

    public prop length: Float64 {
        get() {
            let ctx = cj_arkts_context_v1.__cj_arkts_current()
            return Float64.fromJSValue(ctx, this.__cj_arkts_ref.getProperty("length"))
        }
    }

    // Removes and returns the last element; an empty array pops None (the
    // ArkTS pop returns undefined there).
    public func pop(): Option<T> {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let last = this.__cj_arkts_ref.callMethod("pop", Array<JSValue>())
        if (last.isNull() || last.isUndefined()) {
            return Option<T>.None
        }
        return Option<T>.Some(T.fromJSValue(ctx, last))
    }

    // Appends every item at the end and returns the new length.
    public func push(items: Array<T>): Float64 {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let jsItems = Array<JSValue>(items.size, { i => items[i].toJSValue(ctx) })
        let length = this.__cj_arkts_ref.callMethod("push", jsItems)
        return Float64.fromJSValue(ctx, length)
    }

    // Joins the elements into a string; the separator defaults to "," in
    // ArkTS when the argument is omitted (None).
    public func join(separator!: Option<String> = None): String {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let args = match (separator) {
            case Option.Some(sep) => [ctx.string(sep).toJSValue()]
            case Option.None => Array<JSValue>()
        }
        let joined = this.__cj_arkts_ref.callMethod("join", args)
        return String.fromJSValue(ctx, joined)
    }

    // Reverses in place; the returned wrapper references the same array.
    public func reverse(): ArkTSArray<T> {
        let reversed = this.__cj_arkts_ref.callMethod("reverse", Array<JSValue>())
        return ArkTSArray<T>(reversed.asObject(), ())
    }

    // Removes and returns the first element; an empty array shifts None.
    public func shift(): Option<T> {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let first = this.__cj_arkts_ref.callMethod("shift", Array<JSValue>())
        if (first.isNull() || first.isUndefined()) {
            return Option<T>.None
        }
        return Option<T>.Some(T.fromJSValue(ctx, first))
    }

    // Inserts every item at the front and returns the new length.
    public func unshift(items: Array<T>): Float64 {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let jsItems = Array<JSValue>(items.size, { i => items[i].toJSValue(ctx) })
        let length = this.__cj_arkts_ref.callMethod("unshift", jsItems)
        return Float64.fromJSValue(ctx, length)
    }

    // Extracts a section into a new array; the optional bounds forward up to
    // the last Some exactly like the generated wrappers do (None is the
    // ArkTS `undefined` end).
    public func slice(start!: Option<Float64> = None, end!: Option<Float64> = None): ArkTSArray<T> {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let args = match ((start, end)) {
            case (Option.Some(s), Option.Some(e)) => [ctx.number(s).toJSValue(), ctx.number(e).toJSValue()]
            case (Option.Some(s), Option.None) => [ctx.number(s).toJSValue()]
            case _ => Array<JSValue>()
        }
        let section = this.__cj_arkts_ref.callMethod("slice", args)
        return ArkTSArray<T>(section.asObject(), ())
    }

    // First index of the search element (strict equality on the ArkTS side);
    // -1.0 when absent. The optional start index is forwarded up to the last
    // Some.
    public func indexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64 {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let element = searchElement.toJSValue(ctx)
        let args = match (fromIndex) {
            case Option.Some(from) => [element, ctx.number(from).toJSValue()]
            case Option.None => [element]
        }
        let index = this.__cj_arkts_ref.callMethod("indexOf", args)
        return Float64.fromJSValue(ctx, index)
    }

    // Last index of the search element (strict equality on the ArkTS side);
    // -1.0 when absent. The optional start index is forwarded up to the last
    // Some.
    public func lastIndexOf(searchElement: T, fromIndex!: Option<Float64> = None): Float64 {
        let ctx = cj_arkts_context_v1.__cj_arkts_current()
        let element = searchElement.toJSValue(ctx)
        let args = match (fromIndex) {
            case Option.Some(from) => [element, ctx.number(from).toJSValue()]
            case Option.None => [element]
        }
        let index = this.__cj_arkts_ref.callMethod("lastIndexOf", args)
        return Float64.fromJSValue(ctx, index)
    }
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
@When[arkts_interop == "on"]
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
@When[arkts_interop == "on"]
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
@When[arkts_interop == "on"]
@ArkTS
public foreign class ArkTSFuncWithThis<ThisT, F> {
    // A class without an explicit constructor receives the compiler's
    // implicit public default constructor. For this generic foreign carrier
    // that constructor is instantiated in the erased form (G0_E) but has no
    // lowerable body, so the built package references a symbol it never
    // defines and fails to relocate when the dynamic library loads. Declaring
    // a private bodyless constructor suppresses the implicit one and keeps
    // the documented "no public constructor" surface: values still come only
    // from @HasThis foreign func declarations.
    private init()

    public func bind(thisArg: ThisT): ArkTSFunc<F>
}

// ============================================================================
// ExternConversionException: the documented conversion exception
//
// Cross-boundary conversion failures need a named exception whose message
// distinguishes "type mismatch" from "invalid value". The authoritative design
// defines ExternConversionException together with the Extern mechanism, whose
// provider this toolchain does not ship yet; this declaration is that facade -
// a bare exception type whose name and single-String constructor are the
// compiler-side contract the generated conversion points throw. No conversion
// logic lives here.
//
// The declaration lives in this package, not in the `arkts.lang` facade, on
// purpose: the preset wrapper bodies generated for the types above are part of
// this package and name this exception directly, while `arkts.lang` publicly
// imports this package (`public import std.interop.arkts.*`) and re-exports the
// name to applications. Hosting it in the facade instead would force the
// preset wrappers to import `arkts.lang`, a same-package cycle through the
// facade's own dependency on this package.
// ============================================================================
@When[arkts_interop == "on"]
public class ExternConversionException <: Exception {
    public init(message: String) {
        super(message)
    }
}
