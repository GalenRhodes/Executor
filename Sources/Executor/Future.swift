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

fileprivate let sharedLock: Conditional = Conditional()

open class Future<R>: CancelableFuture {
    //@f:0
    public   let callable:    Callable<R>
    public   var isCanceled:  Bool        { lock.withLock { state == .Canceled } }
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

    public func getResult() throws -> R {
        try lock.withLock {
            while value(state, isOneOf: .Scheduled, .Executing) { lock.broadcastWait() }
            guard state != .Canceled else { throw ExecutorError.CallableCanceled }
            guard error == nil else { throw error! }
            guard let r = result else { throw ExecutorError.NoResults }
            return r
        }
    }

    public func join() { lock.withLock { while value(state, isOneOf: .Scheduled, .Executing) { lock.broadcastWait() } } }

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
    @inlinable public func join<R>() where Element == Future<R> {
        forEach { $0.join() }
    }
}
