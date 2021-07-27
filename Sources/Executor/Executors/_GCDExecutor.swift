/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: _GCDExecutor.swift
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

class _GCDExecutor<R>: AnyExecutor<R> {
    private lazy var queue: DispatchQueue = getQueue()
    private var current: [Future<R>] = []

    override func localShutdown() {
        for f in current { f.cancel() }
        current.removeAll()
    }

    func getQueue() -> DispatchQueue { DispatchQueue(label: uuid, qos: .userInitiated, attributes: [ .concurrent ], autoreleaseFrequency: .workItem) }

    override func exec(callable c: @escaping Callable<R>) -> Future<R> {
        let f = Future<R>(callable: c)
        current <+ f
        queue.async {
            f.execute()
            self.remove(f)
        }
        return f
    }

    private func remove(_ future: Future<R>) { lock.withLock { current.removeAll { $0 === future } } }

    static func == (lhs: _GCDExecutor, rhs: _GCDExecutor) -> Bool { lhs === rhs }
}
