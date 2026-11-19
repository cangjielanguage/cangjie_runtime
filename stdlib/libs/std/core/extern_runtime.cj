/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/** Returns the payload of @p e. The compiler desugars a call into the member access e.payload. */
@Intrinsic
func getExtern<T>(e: Extern<T>): Any where T <: ForeignRuntime<T>

/** Sets the payload of @p e. The compiler desugars a call into the assignment e.payload = payload. */
@Intrinsic
func setExtern<T>(e: Extern<T>, payload: Any): Unit where T <: ForeignRuntime<T>

/**
 * A value of the foreign runtime @p T, e.g. a handle to an object of another language.
 *
 * Member accesses e.f, index accesses e[i], calls e(a1, ..., an), and updates e.f = v and e[i] = v on a value e of type
 * Extern<T> are dynamic: the compiler desugars them into calls to the corresponding static functions of @p T. An
 * expression of type U used where Extern<T> is expected is implicitly converted with T.toExtern<U>.
 */
public struct Extern<T> where T <: ForeignRuntime<T> {
    /**
     * The representation of the foreign value, chosen by @p T. It is only accessed through getExtern and setExtern,
     * because a member access on a value of type Extern<T> is otherwise a dynamic operation.
     */
    private var payload: Any = ()

    /** Creates a foreign value represented by @p payload. */
    public Extern(payload: Any) {
        setExtern(this, payload)
    }

    /** Returns the representation of @p e, for use by implementations of ForeignRuntime. */
    public static func getPayload(e: Extern<T>): Any {
        getExtern(e)
    }
}

/** The operations of a foreign runtime, implemented by @p T for its values of type Extern<T>. */
public interface ForeignRuntime<T> where T <: ForeignRuntime<T> {
    /**
     * Returns the member @p field of @p e. Used for e.f.
     *
     * @throws ExternMemberAccessException if @p e has no member @p field.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func memberAccess(e: Extern<T>, field: String): Extern<T>

    /**
     * Returns the element of @p e at @p index. Used for e[i]; e[i1, ..., in] is rejected.
     *
     * @throws ExternIndexedAccessException if @p e has no element at @p index.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func indexedAccess(e: Extern<T>, index: Any): Extern<T>

    /**
     * Sets the member @p field of @p e to @p value. Used for e.f = v.
     *
     * @throws ExternMemberAccessException if the member @p field of @p e can't be set.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func memberUpdate(e: Extern<T>, field: String, value: Any): Unit

    /**
     * Sets the element of @p e at @p index to @p value. Used for e[i] = v.
     *
     * @throws ExternIndexedAccessException if the element of @p e at @p index can't be set.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func indexedUpdate(e: Extern<T>, index: Any, value: Any): Unit

    /**
     * Calls @p e with the arguments @p args and returns the result. Used for e(a1, ..., an); e.f(a1, ..., an) calls
     * the result of e.f.
     *
     * @throws ExternFunctionAccessException if @p e is not callable.
     * @throws ExternFunctionCallException if the arguments are wrong.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func functionCall(e: Extern<T>, args: Array<Any>): Extern<T>

    /**
     * Converts @p h to a Cangjie value of type @p R. It is never called implicitly.
     *
     * @throws ExternConversionException if @p h can't be represented as a value of type @p R.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func fromExtern<R>(h: Extern<T>): R

    /**
     * Converts @p v to a foreign value. Used for the implicit conversion of a value of type R where Extern<T> is
     * expected.
     *
     * @throws ExternConversionException if @p v can't be represented in the foreign runtime.
     * @throws ForeignRuntimeException if the foreign runtime throws an exception.
     */
    static func toExtern<R>(v: R): Extern<T>
}

/** Thrown when a member of a foreign value can't be accessed. */
public class ExternMemberAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternMemberAccessException" }
}

/** Thrown when a foreign value is not callable. */
public class ExternFunctionAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternFunctionAccessException" }
}

/** Thrown when a foreign value is called with wrong arguments. */
public class ExternFunctionCallException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternFunctionCallException" }
}

/** Thrown when an element of a foreign value can't be accessed. */
public class ExternIndexedAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternIndexedAccessException" }
}

/** Thrown when a value can't be converted between Cangjie and a foreign runtime. */
public class ExternConversionException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternConversionException" }
}

/** Thrown when a foreign runtime fails. */
public class ForeignRuntimeException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ForeignRuntimeException" }
}
