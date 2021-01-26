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

    func test_cards_contains_all_possible_cards_combinations() {
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

        XCTAssert(expectedCards == sut.cards)
    }

    func test_cards_are_not_dealt() {
        XCTAssert(sut.cards.filter(\.isDealt).count == 0)
    }

    func test_cards_are_not_selected() {
        XCTAssert(sut.cards.filter(\.isSelected).count == 0)
    }

    func test_cards_are_not_matched() {
        XCTAssert(sut.cards.filter(\.isMatched).count == 0)
    }

    func test_state_is_no_cards_selected() {
        XCTAssert(sut.state == .noCardsSelected)
    }

    func test_when_no_cards_have_been_dealt_deal_sets_12_random_cards_to_be_dealt() {
        var didShuffleIndices = false
        
        randomSourceFake.shuffle = { indices in
            didShuffleIndices = indices is [Int]
            return indices
        }

        sut.deal()
        let dealtCards = sut.cards.filter(\.isDealt)

        XCTAssert(dealtCards.count == 12)
        XCTAssert(didShuffleIndices)
    }
}
