/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: Cancelable.swift
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
/// When the `Callable` is executed an instance of an object that implements this protocol will be passed to it as
/// it's only argument. The `Callable` closure can use this to monitor the `isCanceled` flag to see if it should
/// stop execution by throwing the error `ExecutorError.CallableCanceled`.
///
public protocol CancelableFuture {
    /*==========================================================================================================*/
    /// Returns `true` if the `Future` was canceled and, as a result, the `Callable` should cease execution.
    ///
    var isCanceled: Bool { get }

    /*==========================================================================================================*/
    /// Cancle the `Future`.
    ///
    func cancel()
}
