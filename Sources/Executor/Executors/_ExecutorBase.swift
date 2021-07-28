/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: _Base.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 28, 2021
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

class _ExecutorBase<R>: AnyExecutor<R> {
    override init() { super.init() }

    override func executeAsync(callable c: @escaping Callable<R>) throws -> Future<R> {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            return exec(callable: c)
        }
    }

    override func executeAsync(callables c: [Callable<R>]) throws -> [Future<R>] {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            return c.map { exec(callable: $0) }
        }
    }

    override func shutdown() {
        lock.withLock {
            localShutdown()
            activeState = false
        }
    }

    func localShutdown() {}

    func exec(callable c: @escaping Callable<R>) -> Future<R> { fatalError("exec(callable:) - Not Implemented.") }
}
