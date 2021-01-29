//
//  SET.swift
//  SETGame
//
//  Created by Martin Hettiger on 26.01.21.
//

import Algorithms
import Foundation

struct SET<ColorType, NumberType, ShapeType, ShadingType> where
    ColorType: Hashable, ColorType: CaseIterable,
    NumberType: Hashable, NumberType: CaseIterable,
    ShapeType: Hashable, ShapeType: CaseIterable,
    ShadingType: Hashable, ShadingType: CaseIterable
{
    typealias Cards = [Card]

    struct Card: Identifiable, Hashable {
        static func == (lhs: Card, rhs: Card) -> Bool {
            lhs.id == rhs.id
        }

        let id = UUID()
        var color: ColorType
        var number: NumberType
        var shape: ShapeType
        var shading: ShadingType
        var isDealt = false
        var isSelected = false
        var isMatched = false
        var isVisible: Bool { isDealt && (!isMatched || isSelected && isMatched) }
    }

    var cardsDealt: Cards { cards.filter(\.isDealt) }
    var cardsSelected: Cards { cards.filter(\.isSelected) }
    var cardsMatched: Cards { cards.filter(\.isMatched) }
    var cardsVisible: Cards { cards.filter(\.isVisible) }

    private(set) var cards: Cards

    init(
        randomSource: RandomSource = MersenneTwisterRandomSource.shared
    ) {
        var cards = [Card]()
        for color in ColorType.allCases {
            for number in NumberType.allCases {
                for shape in ShapeType.allCases {
                    for shading in ShadingType.allCases {
                        cards.append(
                            Card(color: color, number: number, shape: shape, shading: shading)
                        )
                    }
                }
            }
        }
        self.cards = Cards(cards.shuffled(using: randomSource))
    }

    func sets(_ cards: Cards, callback: @escaping ([(Card, Card, Card)]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let sets = cards
                .combinations(ofCount: 3)
                .compactMap { cards -> (Card, Card, Card)? in
                    isMatch(cards) ? (cards[0], cards[1], cards[2]) : nil
                }

            DispatchQueue.main.async {
                callback(sets)
            }
        }
    }

    /// Returns true if number of `cards` is matching number of cases per feature;
    /// where all of the `cards` features, looked at one-by-one,
    /// are the same on each card, or, are different on each card.
    func isMatch(_ cards: Cards) -> Bool {
        guard cards.count == 3 else { return false }
        let colors = Set(cards.map(\.color))
        let numbers = Set(cards.map(\.number))
        let shapes = Set(cards.map(\.shape))
        let shades = Set(cards.map(\.shading))
        return ![colors.count, numbers.count, shapes.count, shades.count].contains(2)
    }

    mutating func deal() {
        guard let firstUndealtCardIndex = cards.firstIndex(where: { !$0.isDealt })
        else { return }

        guard firstUndealtCardIndex != cards.startIndex
        else { setValue(true, forKey: \.isDealt, of: Array(cards.prefix(12))); return }

        let lastCardToBeDealtIndex = firstUndealtCardIndex.advanced(by: 2)
        let cardsToBeDealt = Array(cards[firstUndealtCardIndex ... lastCardToBeDealtIndex])
        setValue(true, forKey: \.isDealt, of: cardsToBeDealt)
    }

    mutating func select(_ selectedCard: Card) {
        switch cardsSelected.count {
        case 0:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
        case 1 where cardsSelected.contains(selectedCard):
            setValue(false, forKey: \.isSelected, of: [selectedCard])
        case 1:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
        case 2 where cardsSelected.contains(selectedCard):
            setValue(false, forKey: \.isSelected, of: [selectedCard])
        case 2:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
            setValue(
                isMatch(cardsSelected),
                forKey: \.isMatched,
                of: cardsSelected + [selectedCard]
            )
        case 3 where isMatch(cardsSelected) && cardsSelected.contains(selectedCard):
            setValue(false, forKey: \.isSelected, of: cardsSelected)
        case 3:
            setValue(false, forKey: \.isSelected, of: cardsSelected)
            setValue(true, forKey: \.isSelected, of: [selectedCard])
        default:
            fatalError("invalid number of selected cards")
        }
    }

    private mutating func setValue<Value>(
        _ value: Value,
        forKey keyPath: WritableKeyPath<Card, Value>,
        of cards: Cards
    ) {
        for card in cards {
            self.cards[self.cards.firstIndex(of: card)!][keyPath: keyPath] = value
        }
    }
}
