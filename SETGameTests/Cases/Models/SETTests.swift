//
//  SETTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 26.01.21.
//

@testable import SETGame
import XCTest

typealias OriginalSET = SET<ColorTypeFake, NumberTypeFake, ShapeTypeFake, ShadingTypeFake>

enum ColorTypeFake: Hashable, CaseIterable {
    case red, green, purple
}

enum NumberTypeFake: Hashable, CaseIterable {
    case one, two, three
}

enum ShapeTypeFake: Hashable, CaseIterable {
    case diamond, squiggle, oval
}

enum ShadingTypeFake: Hashable, CaseIterable {
    case solid, striped, open
}

class SETTests: XCTestCase {
    var randomSourceFake: RandomSourceFake!
    var sut: OriginalSET!
    
    override func setUp() {
        super.setUp()
        randomSourceFake = RandomSourceFake()
        sut = OriginalSET(randomSource: randomSourceFake)
    }
    
    override func tearDown() {
        randomSourceFake = nil
        sut = nil
        super.tearDown()
    }
    
    func test_it_initializes_with_cards_for_all_possible_combinations() {
        XCTAssert(sut.cards.count == 81)
    }
    
    func test_cards_are_in_random_order() {
        var expectedCards = [OriginalSET.Card]()
        
        randomSourceFake.shuffle = { cards in
            let cards = cards as! [OriginalSET.Card]
            XCTAssert(cards.count == 81)
            expectedCards = [cards[10], cards[11], cards[12]]
            return expectedCards
        }
        
        sut = OriginalSET(randomSource: randomSourceFake)
        
        XCTAssert(sut.cards.count == 3)
        XCTAssert(expectedCards == sut.cards)
    }
}
