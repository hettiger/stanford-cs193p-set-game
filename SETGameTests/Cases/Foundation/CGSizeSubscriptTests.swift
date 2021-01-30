//
//  CGSizeSubscriptTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 30.01.21.
//

@testable import SETGame
import XCTest

class CGSizeSubscriptTests: XCTestCase {
    func test_subscript_x_⅓__with_60x120_size__returns_20() {
        let sut = CGSize(width: 60, height: 120)

        let length = sut[.x, 1 / 3]

        XCTAssert(length == 20)
    }

    func test_subscript_y_⅓__with_60x120_size__returns_40() {
        let sut = CGSize(width: 60, height: 120)

        let length = sut[.y, 1 / 3]

        XCTAssert(length == 40)
    }
}
