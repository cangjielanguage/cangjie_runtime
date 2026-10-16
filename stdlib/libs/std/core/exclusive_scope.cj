/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * The execution of the input function @param fn occupies the underlying OS thread exclusively.
 * When executing @param fn, a switch from the cangjie thread stack to the OS thread stack will occur,
 * and the underlying OS thread cannot be preempted by other cangjie threads.
 * After @param fn returns, it will switch back to the cangjie thread stack,
 * and the preemption will be permitted.
 * 
 * @param fn The function to be executed exclusively.
 * @return The return value of @param fn.
 * @throws ExclusiveScopeException if an exception occurs during execution.
 */
@When[env != "ohos"]
public func exclusiveScope<T>(fn: () -> T): T {
    let caught = exclusiveScopeImpl<T>(fn)
    if (caught.ok) {
        return match (caught.payload) {
            case v: T => v
            case _ => throw Error() // unreachable
        }
    }

    match (caught.payload) {
        case e: Exception => throw ExclusiveScopeException(e)
        case e: Error => throw e
        case _ => throw Error() // unreachable
    }
}

struct ExclusiveScopeResult {
    let payload: Any
    let ok: Bool

    init(payload: Any, ok: Bool) {
        this.payload = payload
        this.ok = ok
    }
}

func catchResult<T>(fn: () -> T): ExclusiveScopeResult {
    try {
        ExclusiveScopeResult(fn(), true)
    } catch (e: Exception) {
        ExclusiveScopeResult(e, false)
    } catch (e: Error) {
        ExclusiveScopeResult(e, false)
    }
}

@Intrinsic
private func exclusiveScopeImpl<T>(fn: () -> T): ExclusiveScopeResult

/**
 * Custom exception class to wrap exceptions thrown in an exclusive scope.
 * This exception preserves the original exception's stack trace and information.
 * It is thrown when an exception occurs within an exclusive scope execution.
 */
@When[env != "ohos"]
public class ExclusiveScopeException <: Exception {
    ExclusiveScopeException(cause: Exception) {
        super(cause)
    }

    protected override func getClassName(): String {
        return "ExclusiveScopeException"
    }

    /*
    * Returns a string representation of the exception including its stack trace.
    * This method overrides the base toString method to provide detailed information
    * about the wrapped exception.
    *
     * @return A string representation of the exception with its stack trace
     */
    public override func toString(): String {
        let className: String = getClassName()
        if (let Some(cause) <- causedBy) {
            return "${className}: ${cause.toString()}"
        }
        return className
    }
}
