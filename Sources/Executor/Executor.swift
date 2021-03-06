/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: Executor.swift
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
/// The `Executor` protocol.
///
public protocol Executor: AnyObject {
    associatedtype R

    /*==========================================================================================================*/
    /// Returns `true` if the `Executor` is active and running.
    ///
    var isActive: Bool { get }

    /*==========================================================================================================*/
    /// Shuts down the `Executor` and releases all resources. All scheduled and executing `Future`s will be
    /// canceled. After calling this method the property `isActive` will return `false` and attempting to execute
    /// any new `Callable`s will cause an `ExecutorError.ExecutorNotRunning` error to be thrown.
    ///
    func shutdown()

    /*==========================================================================================================*/
    /// Schedules a single `Callable` for execution and returns it's `Future` immediately.
    /// 
    /// - Parameter callable: The `Callable`.
    /// - Returns: The `Future` for the `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    func executeAsync(callable: @escaping Callable<R>) throws -> Future<R>

    /*==========================================================================================================*/
    /// Schedules a single `Callable` for execution and blocks until execution has completed either successfully,
    /// by being canceled, or by throwing an error. Once the execution has completed this method will unblock and
    /// return the `Callable`'s `Future`.
    /// 
    /// - Parameter callable: The `Callable`.
    /// - Returns: The `Future` for the `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    func executeSync(callable: @escaping Callable<R>) throws -> Future<R>

    /*==========================================================================================================*/
    /// Schedules a array of `Callable`s for execution and returns their `Future`s immediately.
    /// 
    /// - Parameter callables: An array of `Callable`s.
    /// - Returns: An array of `Future`s for each `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    func executeAsync(callables: [Callable<R>]) throws -> [Future<R>]

    /*==========================================================================================================*/
    /// Schedules a array of `Callable`s for execution and blocks until execution of ALL of them has completed
    /// either successfully, by being canceled, or by throwing an error. Once the execution has completed this
    /// method will unblock and returns their `Future`s.
    /// 
    /// - Parameter callables: An array of `Callable`s.
    /// - Returns: An array of `Future`s for each `Callable`.
    /// - Throws: `ExecutorError.ExecutorNotRunning` if the executor is not active.
    ///
    func executeSync(callables: [Callable<R>]) throws -> [Future<R>]
}
