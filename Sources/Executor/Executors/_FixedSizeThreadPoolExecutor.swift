/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: _FixedSizeThreadPoolExecutor.swift
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

class _FixedSizeThreadPoolExecutor<R>: AnyExecutor<R> {
    private let count:   Int
    private var items:   [Future<R>] = []
    private var current: [Future<R>] = []
    private var threads: [ExThread]  = []

    init(count: Int) {
        guard count > 0 else { fatalError("FixedSizeThreadPoolExecutor - Thread count needs to be greater than 0.") }
        self.count = count
        super.init()
        for _ in (0 ..< count) {
            let t = ExThread(owner: self)
            t.qualityOfService = .userInitiated
            t.start()
            threads <+ t
        }
    }

    override func exec(callable c: @escaping Callable<R>) -> Future<R> {
        let f: Future<R> = Future<R>(callable: c)
        items <+ f
        return f
    }

    override func localShutdown() {
        current.forEach { $0.cancel() }
        items.forEach { $0.cancel() }
        current.removeAll()
        items.removeAll()
        threads.removeAll()
    }

    private func getItem() throws -> Future<R> {
        try lock.withLock {
            while activeState && items.isEmpty { lock.broadcastWait() }
            guard activeState else { throw InternalError() }
            guard let i = items.popFirst() else { throw InternalError() }
            current <+ i
            return i
        }
    }

    private func removeItem(_ item: Future<R>) {
        lock.withLock { current.removeAll { $0 === item } }
    }

    private struct InternalError: Error {}

    static func == (lhs: _FixedSizeThreadPoolExecutor, rhs: _FixedSizeThreadPoolExecutor) -> Bool { lhs === rhs }

    private class ExThread: Thread {
        private weak var owner: _FixedSizeThreadPoolExecutor<R>?

        init(owner: _FixedSizeThreadPoolExecutor<R>) {
            self.owner = owner
        }

        override func main() {
            while let owner = owner {
                do {
                    let item = try owner.getItem()
                    item.execute()
                    owner.removeItem(item)
                }
                catch {
                    break
                }
            }
        }
    }
}
