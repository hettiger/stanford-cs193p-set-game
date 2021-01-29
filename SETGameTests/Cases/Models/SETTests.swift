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
    typealias Card = SETFake.Card

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

    func withCard(_ card: Card) {
        withCards([card])
    }

    func withCards(_ cards: [Card]) {
        randomSourceFake.shuffle = { _ in
            cards
        }
        sut = SETFake(randomSource: randomSourceFake)
    }

    func withThreeNonMatchingCardsSelected() {
        withCards([
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .green, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            Card(color: .purple, number: .three, shape: .squiggle, shading: .striped),
        ])
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])
        sut.select(sut.cards[2])
    }

    func withThreeMatchingCardsSelected() {
        withCards([
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            Card(color: .purple, number: .three, shape: .squiggle, shading: .striped),
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
        var expectedCards = [Card]()
        randomSourceFake.shuffle = { cards in
            let cards = cards as! [Card]
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

    // MARK: - Cards Dealt

    func test_cardsDealt_count__returns_0() {
        XCTAssert(sut.cardsDealt.count == 0)
    }

    func test_cardsDealt__with_12_cards_dealt__returns_12_cards() {
        sut.deal()

        XCTAssert(sut.cardsDealt == Array(sut.cards.prefix(12)))
    }

    // MARK: - Cards Selected

    func test_cardsSelected_count__returns_0() {
        XCTAssert(sut.cardsSelected.count == 0)
    }

    func test_cardsSelected__with_two_cards_selected__returns_two_cards() {
        let cards = [sut.cards[0], sut.cards[1]]
        cards.forEach { sut.select($0) }

        XCTAssert(sut.cardsSelected == cards)
    }

    // MARK: - Cards Matched

    func test_cardsMatched_count__returns_0() {
        XCTAssert(sut.cardsMatched.count == 0)
    }

    func test_cardsMatched__with_three_matching_cards_selected__returns_three_cards() {
        withThreeMatchingCardsSelected()

        XCTAssert(sut.cardsMatched == Array(sut.cards.prefix(3)))
    }

    // MARK: - Cards Visible

    func test_cardsVisible_count__returns_0() {
        XCTAssert(sut.cardsVisible.count == 0)
    }

    func test_cardsVisible__with_12_cards_visible__returns_12_cards() {
        sut.deal()

        XCTAssert(sut.cardsVisible == Array(sut.cards.prefix(12)))
    }

    // MARK: - Is Match Check

    func test_isMatch__without_cards__returns_false() {
        XCTAssert(sut.isMatch([]) == false)
    }

    func test_isMatch__with_one_card__returns_false() {
        XCTAssert(sut.isMatch([sut.cards[0]]) == false)
    }

    func test_isMatch__with_two_cards__returns_false() {
        XCTAssert(sut.isMatch([sut.cards[0], sut.cards[1]]) == false)
    }

    func test_isMatch__with_three_matching_cards__returns_true() {
        let cards = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]

        XCTAssert(sut.isMatch(cards) == true)
    }

    func test_isMatch__with_three_non_matching_cards__returns_false() {
        let cards = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .green, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]

        XCTAssert(sut.isMatch(cards) == false)
    }

    // MARK: - Visible SETs

    func test_visibleSETs__with_all_cards_being_visible__calls_back_with_1080_SETs_on_main_thread() {
        randomSourceFake.shuffle = { cards in cards.map { card in
            var card = card as! Card
            card.isDealt = true
            return card
        }}
        sut = SETFake(randomSource: randomSourceFake)
        let exp = expectation(description: "visibleSETs calls callback with result")

        var actualVisibleSETs: [(Card, Card, Card)]!
        var thread: Thread!
        sut.visibleSETs { result in
            actualVisibleSETs = result
            thread = Thread.current
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
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

    // MARK: - Card Is Visible

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

        XCTAssert(sut.cardsSelected == [sut.cards[0]])
    }

    func test_select_card_twice__with_selected_card__sets_card_isSelected_to_false() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[0])

        XCTAssert(sut.cardsSelected == [])
    }

    func test_select_another_card__with_selected_card__sets_another_card_isSelected_to_true() {
        sut.select(sut.cards[0])

        sut.select(sut.cards[1])

        XCTAssert(sut.cardsSelected == [sut.cards[0], sut.cards[1]])
    }

    func test_select_card_twice__with_two_cards_selected__sets_card_isSelected_to_false() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[0])

        XCTAssert(sut.cardsSelected == [sut.cards[1]])
    }

    func test_select_another_card__with_two_cards_selected__sets_card_isSelected_to_true() {
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[2])

        XCTAssert(sut.cardsSelected == [sut.cards[0], sut.cards[1], sut.cards[2]])
    }

    func test_select_matching_card__with_two_matching_cards_selected__sets_all_three_cards_isMatched_to_true(
    ) {
        randomSourceFake.shuffle = { _ in
            [
                Card(color: .green, number: .one, shape: .diamond, shading: .open),
                Card(color: .purple, number: .two, shape: .oval, shading: .solid),
                Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
            ]
        }
        sut = SETFake(randomSource: randomSourceFake)
        sut.select(sut.cards[0])
        sut.select(sut.cards[1])

        sut.select(sut.cards[2])

        XCTAssert(sut.cardsMatched == [sut.cards[0], sut.cards[1], sut.cards[2]])
    }

    func test_select_another_card__with_three_non_matching_cards_selected__sets_another_card_isSelected_to_true_and_other_cards_isSelected_to_false(
    ) {
        withThreeNonMatchingCardsSelected()
        let anotherCard = sut.cards[3]

        sut.select(anotherCard)

        XCTAssert(sut.cardsSelected == [sut.cards.last!])
    }

    func test_select_card_twice__with_three_non_matching_cards_selected__sets_other_cards_isSelected_to_false(
    ) {
        withThreeNonMatchingCardsSelected()

        sut.select(sut.cards[0])

        XCTAssert(sut.cardsSelected == [sut.cards[0]])
    }

    func test_select_another_card__with_three_matching_cards_selected__sets_another_card_isSelected_to_true_and_other_cards_isSelected_to_false(
    ) {
        withThreeMatchingCardsSelected()
        let anotherCard = sut.cards[3]

        sut.select(anotherCard)

        XCTAssert(sut.cardsSelected == [anotherCard])
    }

    func test_select_card_twice__with_three_matching_cards_selected__sets_all_three_cards_isSelected_to_false(
    ) {
        withThreeMatchingCardsSelected()

        sut.select(sut.cards[0])

        XCTAssert(sut.cardsSelected == [])
    }
}
