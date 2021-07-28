/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: AnyExecutor.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 27, 2021
 *
  * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//*****************************************************************************************************************************/

import Foundation
import CoreFoundation
import Rubicon

/*==============================================================================================================*/
/// A base class that all `Executor`s should inherit from. Provides basic functionality that is shared by all of
/// the stock `Executor`s.
///
open class AnyExecutor<R>: Executor, Hashable {
    //@f:0
    open var isActive:  Bool { lock.withLock { activeState } }
    open var hashValue: Int  { uuid.hashValue }

    let uuid:        String      = UUID().uuidString
    let lock:        Conditional = Conditional()
    var activeState: Bool        = true
    //@f:1

    /*==========================================================================================================*/
    /// Default constructor.
    ///
    public init() {}

    deinit { shutdown() }

    /*==========================================================================================================*/
    /// Schedules a single `Callable` for execution and returns it's `Future` immediately.
    /// 
    /// - Parameter callable: The `Callable`.
    /// - Returns: The `Future` for the `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    open func executeAsync(callable c: @escaping Callable<R>) throws -> Future<R> {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            return exec(callable: c)
        }
    }

    /*==========================================================================================================*/
    /// Schedules a single `Callable` for execution and blocks until execution has completed either successfully,
    /// by being canceled, or by throwing an error. Once the execution has completed this method will unblock and
    /// return the `Callable`'s `Future`.
    /// 
    /// - Parameter callable: The `Callable`.
    /// - Returns: The `Future` for the `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    open func executeSync(callable c: @escaping Callable<R>) throws -> Future<R> {
        let f = try executeAsync(callable: c)
        f.join()
        return f
    }

    /*==========================================================================================================*/
    /// Schedules a array of `Callable`s for execution and returns their `Future`s immediately.
    /// 
    /// - Parameter callables: An array of `Callable`s.
    /// - Returns: An array of `Future`s for each `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    open func executeAsync(callables c: [Callable<R>]) throws -> [Future<R>] {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            var out: [Future<R>] = []
            for o in c { out <+ exec(callable: o) }
            return out
        }
    }

    /*==========================================================================================================*/
    /// Schedules a array of `Callable`s for execution and blocks until execution of ALL of them has completed
    /// either successfully, by being canceled, or by throwing an error. Once the execution has completed this
    /// method will unblock and returns their `Future`s.
    /// 
    /// - Parameter callables: An array of `Callable`s.
    /// - Returns: An array of `Future`s for each `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    open func executeSync(callables c: [Callable<R>]) throws -> [Future<R>] {
        let out: [Future<R>] = try executeAsync(callables: c)
        out.join()
        return out
    }

    /*==========================================================================================================*/
    /// Shuts down the `Executor` and releases all resources. All scheduled and executing `Future`s will be
    /// canceled. After calling this method the property `isActive` will return `false` and attempting to execute
    /// any new `Callable`s will cause an `ExecutorError.ExecutorNotRunning` error to be thrown.
    ///
    open func shutdown() {
        lock.withLock {
            localShutdown()
            activeState = false
        }
    }

    open func hash(into hasher: inout Hasher) { hasher.combine(uuid) }

    func exec(callable c: @escaping Callable<R>) -> Future<R> { fatalError("exec(callable:) - Not Implemented.") }

    func localShutdown() {}

    public static func == (lhs: AnyExecutor<R>, rhs: AnyExecutor<R>) -> Bool { lhs === rhs }
}
