/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

@Intrinsic
func getExtern<T>(e: Extern<T>): Any where T <: ForeignRuntime<T>

@Intrinsic
func setExtern<T>(e: Extern<T>, payload: Any): Unit where T <: ForeignRuntime<T>

public struct Extern<T> where T <: ForeignRuntime<T> {
    private var payload: Any = ()

    public Extern(payload: Any) {
        setExtern(this, payload)
    }

    public static func getPayload(e: Extern<T>): Any {
        getExtern(e)
    }
}

public interface ForeignRuntime<T> where T <: ForeignRuntime<T> {
    static func memberAccess(e: Extern<T>, field: String): Extern<T>
    static func indexedAccess(e: Extern<T>, arg: Any): Extern<T>

    static func memberUpdate(e: Extern<T>, field: String, value: Any): Unit
    static func indexedUpdate(e: Extern<T>, field: Any, value: Any): Unit

    static func functionCall(e: Extern<T>, args: Array<Any>): Extern<T>

    static func fromExtern<R>(h: Extern<T>): R
    static func toExtern<R>(v: R): Extern<T>
}

public class ExternMemberAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternMemberAccessException" }
}

public class ExternFunctionAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternFunctionAccessException" }
}

public class ExternFunctionCallException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternFunctionCallException" }
}

public class ExternIndexedAccessException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternIndexedAccessException" }
}

public class ExternConversionException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ExternConversionException" }
}

public class ForeignRuntimeException <: Exception {
    public init() { super() }
    public init(message: String) { super(message) }
    protected override func getClassName(): String { "ForeignRuntimeException" }
}
