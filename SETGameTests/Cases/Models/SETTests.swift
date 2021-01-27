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

    // MARK: - Cards

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

    func test_selection_is_none() {
        XCTAssert(sut.selection == .none)
    }

    // MARK: - Dealing Cards

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

    // MARK: - Selecting and Deselecting Cards

    func test_when_one_card_is_selected_cards_contains_one_card_with_is_selected_set_to_true() {
        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 1)
    }

    func test_when_one_card_is_selected_selection_is_one() {
        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .one(sut.cards[0]))
    }

    func test_when_one_card_is_selected_twice_cards_contains_no_cards_with_is_selected_set_to_true(
    ) {
        sut.select(sut.cards[0])
        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 0)
    }

    func test_when_one_card_is_selected_twice_selection_is_none() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .none)
    }

    func test_when_two_cards_are_selected_cards_contains_two_cards_with_is_selected_set_to_true() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        XCTAssert(sut.cards.filter(\.isSelected).count == 2)
    }

    func test_when_two_cards_are_selected_selection_is_two() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        XCTAssert(sut.selection == .two(sut.cards[0], sut.cards[1]))
    }

    func test_when_two_cards_are_selected_and_one_card_is_selected_cards_contains_one_card_with_is_selected_set_to_true(
    ) {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 1)
    }

    func test_when_two_cards_are_selected_and_one_card_is_selected_again_selection_is_one() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .one(sut.cards[1]))
    }

    func test_when_three_cards_are_selected_cards_contains_three_cards_with_is_selected_set_to_true(
    ) {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])
        sut.select(sut.cards[2])

        XCTAssert(sut.cards.filter(\.isSelected).count == 3)
    }

    func test_when_three_cards_are_selected_selection_is_three() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])
        sut.select(sut.cards[2])

        XCTAssert(sut.selection == .three(sut.cards[0], sut.cards[1], sut.cards[2]))
    }
}
