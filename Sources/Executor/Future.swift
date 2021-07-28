/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: Future.swift
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
/// The shared private conditional lock(s).
///
fileprivate let sharedLock: Conditional = Conditional()

/*==============================================================================================================*/
/// A `Callable` closure gets wrapped inside an instance of `Future` which controls it's execution and handles
/// it's result or error.
///
open class Future<R>: CancelableFuture {
    //@f:0
    /*==========================================================================================================*/
    /// The `Callable`.
    ///
    public   let callable:    Callable<R>
    /*==========================================================================================================*/
    /// Returns `true` if the `Future` has been canceled.
    ///
    public   var isCanceled:  Bool        { lock.withLock { state == .Canceled } }
    /*==========================================================================================================*/
    /// The state of the Future.
    ///
    public   var futureState: FutureState { lock.withLock { state } }
    internal var state:       FutureState = .Scheduled
    private  var result:      R?          = nil
    private  var error:       Error?      = nil
    private  let lock:        Conditional
    //@f:1

    init(callable: @escaping Callable<R>) {
        self.lock = sharedLock
        self.callable = callable
    }

    deinit { cancel() }

    /*==========================================================================================================*/
    /// Get the results returned from the Future executing the `Callable`. Calling this method will block until
    /// the `Future` has been executed and either completed, thrown an error, or been canceled.
    /// 
    /// - Returns: The result from the `Future`'s execution of the `Callable`.
    /// - Throws: Any error thrown by the `Callable` or `ExecutorError.CallableCanceled` if the `Future` was
    ///           canceled.
    ///
    public func getResult() throws -> R {
        try lock.withLock {
            while value(state, isOneOf: .Scheduled, .Executing) { lock.broadcastWait() }
            guard state != .Canceled else { throw ExecutorError.CallableCanceled }
            guard error == nil else { throw error! }
            guard let r = result else { throw ExecutorError.NoResults }
            return r
        }
    }

    /*==========================================================================================================*/
    /// Blocks the calling thread until the `Future` was completed execution or been canceled.
    ///
    public func join() { lock.withLock { while value(state, isOneOf: .Scheduled, .Executing) { lock.broadcastWait() } } }

    /*==========================================================================================================*/
    /// Cancels the `Future`. If the `Future` has already completed or already been canceled then calling this
    /// method does nothing.
    ///
    public func cancel() {
        lock.withLock {
            guard value(state, isOneOf: .Scheduled, .Executing) else { return }
            state = .Canceled
        }
    }

    func execute() {
        lock.withLock {
            guard state == .Scheduled else { return }
            state = .Executing
        }
        do {
            var c: CancelableFuture = self
            result = try callable(&c)
            lock.withLock { state = .Finished }
        }
        catch ExecutorError.CallableCanceled {
            // Make sure the state is set correctly if it isn't already but otherwise ignore.
            lock.withLock { state = .Canceled }
        }
        catch let e {
            lock.withLock {
                error = e
                state = .Error
            }
        }
    }
}

extension Collection {
    /*==========================================================================================================*/
    /// Blocks the calling thread until ALL of the `Future`s in the collection have completed execution or been
    /// canceled.
    ///
    @inlinable public func join<R>() where Element == Future<R> {
        forEach { $0.join() }
    }

    /*==========================================================================================================*/
    /// Cancels ALL of the Futures in this collection.
    ///
    @inlinable public func cancel<R>() where Element == Future<R> {
        forEach { $0.cancel() }
    }
}
