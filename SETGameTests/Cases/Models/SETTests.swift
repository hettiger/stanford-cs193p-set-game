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
        let set = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]
        let extraCards = Array(sut.cards[1 ... 20])
        withCards(set + extraCards)
        sut.deal()
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

    // MARK: - Is SET Check

    func test_isSET__without_cards__returns_false() {
        XCTAssert(sut.isSET([]) == false)
    }

    func test_isSET__with_one_card__returns_false() {
        XCTAssert(sut.isSET([sut.cards[0]]) == false)
    }

    func test_isSET__with_two_cards__returns_false() {
        XCTAssert(sut.isSET([sut.cards[0], sut.cards[1]]) == false)
    }

    func test_isSET__with_three_matching_cards__returns_true() {
        let cards = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]

        XCTAssert(sut.isSET(cards) == true)
    }

    func test_isSET__with_three_non_matching_cards__returns_false() {
        let cards = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .green, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]

        XCTAssert(sut.isSET(cards) == false)
    }

    // MARK: - Finding SETs

    func test_firstSET__with_no_sets_in_cards__returns_nil() {
        XCTAssert(sut.firstSET([]) == nil)
    }

    func test_firstSET__with_all_cards__returns_one_set() {
        XCTAssert((sut.firstSET(sut.cards) as Any) is (Card, Card, Card))
    }

    func test_sets__with_all_cards__calls_back_with_1080_SETs_on_main_thread() {
        let exp = expectation(description: "sets calls callback with result")

        var actualSETs: [(Card, Card, Card)]!
        var thread: Thread!
        sut.sets(sut.cards) { result in
            actualSETs = result
            thread = Thread.current
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
        XCTAssert(actualSETs.count == 1080)
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

    func test_deal__with_dealt_cards_and_SET_selected__sets_first_3_undealt_cards_to_be_dealt_and_swaps_them_individually_with_the_SET_cards(
    ) {
        func cardToIndex(card: Card) -> Int { sut.cards.firstIndex(of: card)! }
        let set = [
            Card(color: .green, number: .one, shape: .diamond, shading: .open),
            Card(color: .purple, number: .two, shape: .oval, shading: .solid),
            Card(color: .red, number: .three, shape: .squiggle, shading: .striped),
        ]
        let expectedCardsToBeDealt = Array(sut.cards[11 ... 13])
        var dealtCards = Array(sut.cards[1 ... 9]) // 9 cards
        dealtCards.insert(set[0], at: 0) // + 1 card
        dealtCards.insert(set[1], at: 4) // + 1 card
        dealtCards.insert(set[2], at: 5) // + 1 card = 12 cards for initial deal
        withCards(dealtCards + expectedCardsToBeDealt)
        sut.deal()
        set.forEach { card in sut.select(card) }
        let expectedIndices = set.map(cardToIndex)
        let expectedSETIndices = expectedCardsToBeDealt.map(cardToIndex)

        sut.deal()
        let actualIndices = expectedCardsToBeDealt.map(cardToIndex)
        let actualSETIndices = set.map(cardToIndex)

        XCTAssert(expectedIndices == actualIndices)
        XCTAssert(expectedSETIndices == actualSETIndices)
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

    func test_select_card_twice__with_three_matching_cards_selected__deals_3_more_cards() {
        withThreeMatchingCardsSelected()

        sut.select(sut.cards[0])

        XCTAssert(sut.cardsDealt.count == 12 + 3)
    }

    func test_select_another_card__with_three_matching_cards_selected__deals_3_more_cards() {
        withThreeMatchingCardsSelected()
        let anotherCard = sut.cards[3]

        sut.select(anotherCard)

        XCTAssert(sut.cardsDealt.count == 12 + 3)
    }
}
