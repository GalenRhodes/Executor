/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: LockPool.swift
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

class LockPoolItem {
    let lock:     Conditional = Conditional()
    var useCount: Int         = 0
}

fileprivate let MaxLocks: Int            = 100
fileprivate var lockIndx: Int            = 0
fileprivate var lockPool: [LockPoolItem] = []
fileprivate let lockLock: MutexLock      = MutexLock()

func getSharedLock() -> Conditional {
    lockLock.withLock {
        let idx = nextLockIndex()
        while idx >= lockPool.count  { lockPool <+ LockPoolItem() }
        let lpi = lockPool[idx]
        lpi.useCount += 1
        return lpi.lock
    }
}

func releaseSharedLock(_ lock: Conditional) {
    lockLock.withLock {
        guard let lpi = lockPool.first(where: { $0.lock === lock }) else { return }
        lpi.useCount -= 1
        lockPool.removeAll { $0.useCount <= 0 }
        if lockIndx >= lockPool.count { lockIndx = 0 }
    }
}

fileprivate func nextLockIndex() -> Int {
    let i = lockIndx
    lockIndx = ((lockIndx + 1) % MaxLocks)
    return i
}
