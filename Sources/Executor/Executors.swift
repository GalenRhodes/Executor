/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: Executors.swift
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

public struct Executors {
    /*==========================================================================================================*/
    /// Creates and returns an `Executor` that uses a fixed number of thread to execute the `Callable`s.
    /// 
    /// - Parameter count: The number of threads to use. Must be greater than or equal to 1. No more than this
    ///                    many threads will be created.
    /// - Returns: The `Executor`.
    ///
    public static func FixedSizeThreadPoolExecutor<R>(count: Int) -> AnyExecutor<R> { _FixedSizeThreadPoolExecutor<R>(count: count) }

    /*==========================================================================================================*/
    /// Creates and returns an `Executor` that creates a single
    /// <code>[concurrent](https://developer.apple.com/documentation/dispatch/dispatchqueue/attributes/2300052-concurrent)</code>
    /// <code>[DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue)</code> to execute
    /// the `Callable`s.
    /// 
    /// - Returns: The `Executor`.
    ///
    public static func GCDExecutor<R>() -> AnyExecutor<R> { _GCDExecutor<R>() }

    /*==========================================================================================================*/
    /// The same as `GCDExecutor` except that the
    /// <code>[DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue)</code> will not be
    /// a
    /// <code>[concurrent](https://developer.apple.com/documentation/dispatch/dispatchqueue/attributes/2300052-concurrent)</code>
    /// queue.
    /// 
    /// - Returns: The `Executor`.
    ///
    public static func SingleThreadExecutor<R>() -> AnyExecutor<R> { _SingleThreadExecutor<R>() }
}
