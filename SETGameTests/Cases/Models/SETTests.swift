//
//  SETTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 26.01.21.
//

import Algorithms
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

    func test_when_no_cards_have_been_dealt_deal_sets_first_12_cards_to_be_dealt() {
        sut.deal()

        XCTAssert(sut.cards.prefix(12).filter(\.isDealt).count == 12)
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

    func test_when_match_is_selected_corresponding_cards_are_marked_to_be_matched() {
        randomSourceFake.shuffle = { _ in
            [
                OriginalSET.Card(color: .green, number: .one, shape: .diamond, shading: .open),
                OriginalSET.Card(color: .purple, number: .two, shape: .oval, shading: .solid),
                OriginalSET.Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            ]
        }
        sut = OriginalSET(randomSource: randomSourceFake)

        sut.select(sut.cards[0])
        sut.select(sut.cards[1])
        sut.select(sut.cards[2])

        XCTAssert(sut.cards.filter(\.isMatched).count == 3)
    }

    // MARK: - Selection Is Match Check

    func test_when_selection_is_none_is_match_returns_false() {
        XCTAssert(sut.selection.isMatch == false)
    }

    func test_when_selection_is_one_is_match_returns_false() {
        sut.select(sut.cards[0])

        XCTAssert(sut.selection.isMatch == false)
    }

    func test_when_selection_is_two_is_match_returns_false() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        XCTAssert(sut.selection.isMatch == false)
    }

    func test_when_selection_is_three_returns_true_on_1080_of_all_possible_combinations() {
        let cardCombinations = sut.cards.combinations(ofCount: 3)
        var sets = Set<Set<OriginalSET.Card>>()
        for cards in cardCombinations {
            let selection = OriginalSET.Selection.three(cards[0], cards[1], cards[2])
            if selection.isMatch {
                sets.insert(Set([cards[0], cards[1], cards[2]]))
            }
        }
        XCTAssert(sets.count == 1080)
    }
}
