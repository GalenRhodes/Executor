/*****************************************************************************************************************************//**
 *     PROJECT: Executor
 *    FILENAME: ExecutorError.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 23, 2021
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

public enum ExecutorError: Error {
    /*==========================================================================================================*/
    /// This should not ever happen.
    ///
    case NoResults
    /*==========================================================================================================*/
    /// Thrown if you attempt to schedule a Callable on an Executor that is not active.
    ///
    case ExecutorNotRunning
    /*==========================================================================================================*/
    /// Thrown either by a Callable that detects it's Future was canceled during execution or when attempting to
    /// get the results from a future that was canceled.
    ///
    case CallableCanceled
}
