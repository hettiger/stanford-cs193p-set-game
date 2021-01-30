//
//  ArrayShufflingTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 30.01.21.
//

@testable import SETGame
import XCTest

class ArrayShufflingTests: XCTestCase {
    var randomSourceFake: RandomSourceFake!

    override func setUpWithError() throws {
        try super.setUpWithError()
        randomSourceFake = RandomSourceFake()
    }

    override func tearDownWithError() throws {
        randomSourceFake = nil
        try super.tearDownWithError()
    }

    func test_arrayShuffle_shufflesArrayInPlace() {
        let expectedArray = ["b", "a"]
        randomSourceFake.shuffle = { _ in expectedArray }
        var array = ["a", "b"]

        array.shuffle(using: randomSourceFake)

        XCTAssertEqual(expectedArray, array)
    }

    func test_arrayShuffled_returnsShuffledArray() {
        let expectedArray = ["b", "a"]
        randomSourceFake.shuffle = { _ in expectedArray }
        var array = ["a", "b"]

        array = array.shuffled(using: randomSourceFake)

        XCTAssertEqual(expectedArray, array)
    }
}
