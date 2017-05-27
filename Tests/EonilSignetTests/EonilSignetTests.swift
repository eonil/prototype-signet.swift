//
//  main.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/27.
//  Copyright © 2017 Eonil. All rights reserved.
//

import XCTest
import EonilSignet

class EonilSignetTests: XCTestCase {
    func testBasics() {
        typealias Station<T> = MutableChannel<T>
        typealias Transmitter<T> = TransmittableChannel<T>

        do {
            let st1 = Station<Int>(100)
            let ch2 = Transmitter<String>("")
            let ch3 = Transmitter<Float>(0.0)
            let ch4 = Transmitter<Float>(1.0)

            ch2.watch(st1) { "0\($0 * 2)0" }
            ch3.watch(ch2) { (Float($0) ?? 0.0) / 3 }
            ch4.watch(ch3)

            st1.state = (200)
            assert(st1.state == 200)
            assert(ch2.state == "04000")
            assert(ch3.state == 4000/3)
            assert(ch4.state == 4000/3)

            ch2.unwatch()
            st1.state = (300)
            assert(st1.state == 300)
            assert(ch2.state == "04000")
            assert(ch3.state == 4000/3)
            assert(ch4.state == 4000/3)
        }
        do {
            let st1 = Station<Int>(111)
            let ch2 = Transmitter<Int>(999)
            //
            // Uses same source channels.
            // Same channel will be registered only once.
            // So state propagation will happen only once.
            //
            ch2.watch(st1, st1) { $0 + $1 }
            var emissionCount = 0
            ch2.delegate = { _ in
                emissionCount += 1
            }
            st1.state = 200
            assert(emissionCount == 1)
            assert(ch2.state == 400)
        }
        do {
            let st1 = Station<Int>(1)
            let st2 = Station<Int>(2)
            let ch3 = Transmitter<Int>(999)
            ch3.watch(st1, st2) { $0 + $1 }
            var emissionCount = 0
            ch3.delegate = { _ in
                emissionCount += 1
            }
            st1.state = (100)
            assert(emissionCount == 1)
            assert(ch3.state == 102)

            st2.state = (200)
            assert(emissionCount == 2)
            assert(ch3.state == 300)
        }
    }
}
