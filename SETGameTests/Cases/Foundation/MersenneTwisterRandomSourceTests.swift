//
//  MersenneTwisterRandomSourceTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 30.01.21.
//

@testable import SETGame
import XCTest

class MersenneTwisterRandomSourceTests: XCTestCase {
    func test_randomInt__returns_random_integers_in_range() {
        let sut = MersenneTwisterRandomSource()
        let range = 2 ... 5
        var results = Set<Int>()

        for _ in 1 ... 100 {
            let result = sut.randomInt(in: range)
            XCTAssertTrue(range.contains(result))
            results.insert(result)
        }

        XCTAssertGreaterThan(results.count, 1)
    }

    func test_shuffled__returns_shuffled_array() {
        let sut = MersenneTwisterRandomSource(seed: 1_234_567_890)
        let expectedArray = [0, 1, 7, 6, 2, 5, 8, 3, 4, 9]
        let array = Array(0 ... 9)

        XCTAssertEqual(expectedArray, sut.shuffled(array))
    }
}
