//
//  ExecutorTests.swift
//  ExecutorTests
//
//  Created by Galen Rhodes on 7/23/21.
//

import XCTest
import Rubicon
@testable import Executor

class ExecutorTests: XCTestCase {
    typealias C = (inout Cancelable) throws -> Int

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testComplete() throws {
        displayResults(futures: try Executors.GCDExecutor().executeSync(callables: getTests(seconds: 3.0)))
    }

    func testCancel() throws {
        let f: [Future<Int>] = try Executors.GCDExecutor().executeAsync(callables: getTests(seconds: 5.0))
        sleep(3)
        for x in f { x.cancel() }
        f.join()
        displayResults(futures: f)
    }

    private func getTests(count: Int = 6, seconds: Double) -> [C] {
        var ar:   [C]     = []
        let time: PGTimeT = PGTimeT(seconds * 1_000_000_000.0)

        for i in (0 ..< count) {
            ar <+ { (c: inout Cancelable) throws -> Int in
                var value:  Int     = 0
                let stopAt: PGTimeT = getSysTime(delta: time)
                var now:    PGTimeT = getSysTime()

                while now < stopAt && !c.isCancelled {
                    let x = Int.random(in: 1 ..< 5)
                    value += x
                    now = getSysTime()
                }

                if c.isCancelled {
                    print("\(i + 1) canceled!!!!!")
                    throw ExecutorError.CallableCanceled
                }
                return value
            }
        }

        return ar
    }

    private func displayResults(futures f: [Future<Int>]) {
        for i in (f.startIndex ..< f.endIndex) {
            do {
                print("\(i + 1)> \(try f[i].getResult())")
            }
            catch let e {
                print("\(i + 1)> \(e)")
            }
        }
    }

//    func testGCD() throws {
//    }
//
//    func testSingle() throws {
//    }

//    func testPerformanceExample() throws {
//        self.measure {
//        }
//    }

    #if !(os(macOS) || os(tvOS) || os(iOS) || os(watchOS))
        public static var allTests: [(String, (ExecutorTests) -> () throws -> Void)] {
            [ ("ExecutorTests", testComplete),
              ("ExecutorTests", testCancel), ]
        }
    #endif
}
