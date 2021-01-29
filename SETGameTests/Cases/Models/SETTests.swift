//
//  SETTests.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 26.01.21.
//

import Algorithms
@testable import SETGame
import XCTest

class SETTests: XCTestCase {
    var randomSourceFake: RandomSourceFake!
    var sut: SETFake!

    override func setUp() {
        super.setUp()
        randomSourceFake = RandomSourceFake()
        sut = SETFake(randomSource: randomSourceFake)
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
        var expectedCards = [SETFake.Card]()

        randomSourceFake.shuffle = { cards in
            let cards = cards as! [SETFake.Card]
            XCTAssert(cards.count == 81)
            expectedCards = [cards[10], cards[11], cards[12]]
            return expectedCards
        }

        sut = SETFake(randomSource: randomSourceFake)

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

        XCTAssert(sut.cards.filter(\.isDealt).count == 12)
        XCTAssert(sut.cards.prefix(12).filter(\.isDealt).count == 12)
    }

    func test_when_there_are_dealt_cards_continues_dealing_3_cards() {
        let expectedCount = 12 + 3
        sut.deal()

        sut.deal()

        XCTAssert(sut.cards.filter(\.isDealt).count == expectedCount)
        XCTAssert(sut.cards.prefix(expectedCount).filter(\.isDealt).count == expectedCount)
    }

    // MARK: - Card Visibility

    func withCard(_ card: SETFake.Card) {
        randomSourceFake.shuffle = { _ in
            [card]
        }
        sut = SETFake(randomSource: randomSourceFake)
    }

    func test_card_is_not_visible() {
        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_when_card_is_selected_card_is_not_visible() {
        sut.select(sut.cards[0])

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_when_card_is_matched_card_is_not_visible() {
        var card = sut.cards[0]
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_when_card_is_dealt_card_is_visible() {
        sut.deal()

        XCTAssert(sut.cards[0].isVisible == true)
    }

    func test_when_card_is_dealt_and_selected_card_is_visible() {
        sut.deal()
        sut.select(sut.cards[0])

        XCTAssert(sut.cards[0].isVisible == true)
    }

    func test_when_card_is_dealt_and_matched_card_is_not_visible() {
        var card = sut.cards[0]
        card.isDealt = true
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_when_card_is_dealt_matched_and_selected_card_is_visible() {
        var card = sut.cards[0]
        card.isDealt = true
        card.isSelected = true
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == true)
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
                SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
                SETFake.Card(color: .purple, number: .two, shape: .oval, shading: .solid),
                SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            ]
        }
        sut = SETFake(randomSource: randomSourceFake)

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

    func test_when_selection_is_three_and_cards_are_a_set_isMatch_returns_true() {
        let selection = SETFake.Selection.three(
            SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
            SETFake.Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped)
        )

        XCTAssert(selection.isMatch == true)
    }

    func test_when_selection_is_three_but_cards_are_not_a_set_isMatch_returns_false() {
        let selection = SETFake.Selection.three(
            SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
            SETFake.Card(color: .green, number: .two, shape: .oval, shading: .solid),
            SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped)
        )

        XCTAssert(selection.isMatch == false)
    }

    // MARK: - Visible SETs

    func test_when_all_cards_are_visible_visibleSETs_calls_back_with_1080_SETs_on_main_thread() {
        randomSourceFake.shuffle = { cards in cards.map { card in
            var card = card as! SETFake.Card
            card.isDealt = true
            return card
        }}
        sut = SETFake(randomSource: randomSourceFake)
        let exp = expectation(description: "visibleSETs calls callback with result")

        var actualVisibleSETs: [(SETFake.Card, SETFake.Card, SETFake.Card)]!
        var thread: Thread!
        sut.visibleSETs { result in
            actualVisibleSETs = result
            thread = Thread.current
            exp.fulfill()
        }

        wait(for: [exp], timeout: 2)
        XCTAssert(actualVisibleSETs.count == 1080)
        XCTAssert(thread.isMainThread == true)
    }
}
