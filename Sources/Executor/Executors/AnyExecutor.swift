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

public class AnyExecutor<R>: Executor {
    public typealias R = R

    public var isActive: Bool { lock.withLock { activeState } }

    //@f:0
    let uuid:        String      = UUID().uuidString
    let lock:        Conditional = Conditional()
    var hashValue:   Int         { uuid.hashValue }
    var activeState: Bool        = true
    //@f:1

    init() {}

    deinit { shutdown() }

    public func executeAsync(callable c: @escaping Callable<R>) throws -> Future<R> {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            return exec(callable: c)
        }
    }

    public func executeSync(callable c: @escaping Callable<R>) throws -> Future<R> {
        let f = try executeAsync(callable: c)
        f.join()
        return f
    }

    public func executeAsync(callables c: [Callable<R>]) throws -> [Future<R>] {
        try lock.withLock {
            guard activeState else { throw ExecutorError.ExecutorNotRunning }
            var out: [Future<R>] = []
            for o in c { out <+ exec(callable: o) }
            return out
        }
    }

    public func executeSync(callables c: [Callable<R>]) throws -> [Future<R>] {
        let out: [Future<R>] = try executeAsync(callables: c)
        out.join()
        return out
    }

    public func shutdown() {
        guard lock.tryLock() else {
            print("Lock is still being held!")
            return
        }
        defer {
            lock.broadcast()
            lock.unlock()
        }
        localShutdown()
        activeState = false
    }

    func localShutdown() {}

    func hash(into hasher: inout Hasher) { hasher.combine(uuid) }

    func exec(callable c: @escaping Callable<R>) -> Future<R> { fatalError("exec(callable:) - Not Implemented.") }
}
