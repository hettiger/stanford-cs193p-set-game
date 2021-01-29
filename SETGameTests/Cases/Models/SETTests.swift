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

    // MARK: - State

    func withCard(_ card: SETFake.Card) {
        withCards([card])
    }

    func withCards(_ cards: [SETFake.Card]) {
        randomSourceFake.shuffle = { _ in
            cards
        }
        sut = SETFake(randomSource: randomSourceFake)
    }

    func withThreeNonMatchingCardsSelected() {
        withCards([
            SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
            SETFake.Card(color: .green, number: .two, shape: .oval, shading: .solid),
            SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            SETFake.Card(color: .purple, number: .three, shape: .squiggle, shading: .striped),
        ])
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])
        sut.select(sut.cards[2])
    }

    // MARK: - Cards

    func test_cards__returns_all_possible_card_combinations() {
        XCTAssert(sut.cards.count == 81)
    }

    func test_cards__returns_cards_in_random_order() {
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

    func test_cards__returns_only_cards_that_are_not_dealt_yet() {
        XCTAssert(sut.cards.filter(\.isDealt).count == 0)
    }

    func test_cards__returns_only_cards_that_are_not_selected_yet() {
        XCTAssert(sut.cards.filter(\.isSelected).count == 0)
    }

    func test_cards__returns_only_cards_that_are_not_matched_yet() {
        XCTAssert(sut.cards.filter(\.isMatched).count == 0)
    }

    func test_cards__returns_only_cards_that_are_not_visible_yet() {
        XCTAssert(sut.cards.filter(\.isVisible).count == 0)
    }

    // MARK: - Selection

    func test_selection__returns_none() {
        XCTAssert(sut.selection == .none)
    }

    // MARK: - Selection Is Match Check

    func test_selection_isMatch__returns_false() {
        XCTAssert(sut.selection.isMatch == false)
    }

    func test_selection_isMatch__with_selection_one__returns_false() {
        sut.select(sut.cards[0])

        XCTAssert(sut.selection.isMatch == false)
    }

    func test_selection_isMatch__with_selection_two__returns_false() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        XCTAssert(sut.selection.isMatch == false)
    }

    func test_selection_isMatch__with_selection_three_and_cards_matching__returns_true() {
        let selection = SETFake.Selection.three(
            SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
            SETFake.Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped)
        )

        XCTAssert(selection.isMatch == true)
    }

    func test_selection_isMatch__with_selection_three_and_cards_not_matching__returns_false() {
        let selection = SETFake.Selection.three(
            SETFake.Card(color: .green, number: .one, shape: .diamond, shading: .open),
            SETFake.Card(color: .green, number: .two, shape: .oval, shading: .solid),
            SETFake.Card(color: .red, number: .three, shape: .squiggle, shading: .striped)
        )

        XCTAssert(selection.isMatch == false)
    }

    // MARK: - Visible SETs

    func test_visibleSETs__with_all_cards_being_visible__calls_back_with_1080_SETs_on_main_thread() {
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

    // MARK: - Dealing Cards

    func test_deal__sets_first_12_cards_to_be_dealt() {
        sut.deal()

        XCTAssert(sut.cards.filter(\.isDealt).count == 12)
        XCTAssert(sut.cards.prefix(12).filter(\.isDealt).count == 12)
    }

    func test_deal__with_dealt_cards__sets_first_3_undealt_cards_to_be_dealt() {
        let expectedCount = 12 + 3
        sut.deal()

        sut.deal()

        XCTAssert(sut.cards.filter(\.isDealt).count == expectedCount)
        XCTAssert(sut.cards.prefix(expectedCount).filter(\.isDealt).count == expectedCount)
    }

    // MARK: - Card Visibility

    func test_card_isVisible__with_selected_card__returns_false() {
        sut.select(sut.cards[0])

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_card_isVisible__with_matched_card__returns_false() {
        var card = sut.cards[0]
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_card_isVisible__with_dealt_card__returns_true() {
        sut.deal()

        XCTAssert(sut.cards[0].isVisible == true)
    }

    func test_card_isVisible__with_dealt_and_selected_card__returns_true() {
        sut.deal()
        sut.select(sut.cards[0])

        XCTAssert(sut.cards[0].isVisible == true)
    }

    func test_card_isVisible__with_dealt_and_matched_card__returns_false() {
        var card = sut.cards[0]
        card.isDealt = true
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == false)
    }

    func test_card_isVisible__with_dealt_matched_and_selected_card__returns_true() {
        var card = sut.cards[0]
        card.isDealt = true
        card.isSelected = true
        card.isMatched = true
        withCard(card)

        XCTAssert(sut.cards[0].isVisible == true)
    }

    // MARK: - Selecting and Deselecting Cards

    func test_select__sets_card_isSelected_to_true() {
        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 1)
        XCTAssert(sut.cards[0].isSelected == true)
    }

    func test_select__sets_selection_to_one() {
        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .one(sut.cards[0]))
    }

    func test_select_card_twice__with_selected_card__sets_card_isSelected_to_false() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 0)
    }

    func test_select_card_twice__with_selected_card__sets_selection_to_none() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .none)
    }

    func test_select_another_card__with_selected_card__sets_another_card_isSelected_to_true() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[1])

        XCTAssert(sut.cards.filter(\.isSelected).count == 2)
        XCTAssert(sut.cards[0].isSelected == true)
        XCTAssert(sut.cards[1].isSelected == true)
    }

    func test_select_another_card__with_selected_card__sets_selection_to_two() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[1])

        XCTAssert(sut.selection == .two(sut.cards[0], sut.cards[1]))
    }

    func test_select_card_twice__with_two_cards_selected__sets_card_isSelected_to_false() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[0])

        XCTAssert(sut.cards.filter(\.isSelected).count == 1)
        XCTAssert(sut.cards[0].isSelected == false)
    }

    func test_select_card_twice__with_two_cards_selected__sets_selection_to_one() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .one(sut.cards[1]))
    }

    func test_select_another_card__with_two_cards_selected__sets_card_isSelected_to_true() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[2])

        XCTAssert(sut.cards.filter(\.isSelected).count == 3)
        XCTAssert(sut.cards[0].isSelected == true)
        XCTAssert(sut.cards[1].isSelected == true)
        XCTAssert(sut.cards[2].isSelected == true)
    }

    func test_select_another_card__with_two_cards_selected__sets_selection_to_three() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[2])

        XCTAssert(sut.selection == .three(sut.cards[0], sut.cards[1], sut.cards[2]))
    }

    func test_select_matching_card__with_two_matching_cards_selected__sets_all_three_cards_isMatched_to_true(
    ) {
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
        XCTAssert(sut.cards[0].isMatched == true)
        XCTAssert(sut.cards[1].isMatched == true)
        XCTAssert(sut.cards[2].isMatched == true)
    }

    func test_select_another_card__with_three_non_matching_cards_selected__sets_another_card_isSelected_to_true_and_other_cards_isSelected_to_false(
    ) {
        withThreeNonMatchingCardsSelected()
        let anotherCard = sut.cards[3]

        sut.select(anotherCard)

        XCTAssert(sut.cards.prefix(3).filter(\.isSelected).count == 0)
        XCTAssert(sut.cards.last!.isSelected == true)
        XCTAssert(sut.selection == .one(anotherCard))
    }

    func test_select_another_card__with_three_non_matching_cards_selected__sets_selection_to_one() {
        withThreeNonMatchingCardsSelected()
        let anotherCard = sut.cards[3]

        sut.select(anotherCard)

        XCTAssert(sut.selection == .one(anotherCard))
    }

    func test_select_card_twice__with_three_non_matching_cards_selected__sets_other_cards_isSelected_to_false(
    ) {
        withThreeNonMatchingCardsSelected()

        sut.select(sut.cards[0])

        XCTAssert(sut.cards.suffix(2).filter(\.isSelected).count == 0)
        XCTAssert(sut.cards.first!.isSelected == true)
    }

    func test_select_card_twice__with_three_non_matching_cards_selected__sets_selection_to_one() {
        withThreeNonMatchingCardsSelected()

        sut.select(sut.cards[0])

        XCTAssert(sut.selection == .one(sut.cards[0]))
    }
}
