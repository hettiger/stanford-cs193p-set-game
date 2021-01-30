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

    private var selection: Cards { cards.filter(\.isSelected) }

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
                    isSET(cards) ? (cards[0], cards[1], cards[2]) : nil
                }

            DispatchQueue.main.async {
                callback(sets)
            }
        }
    }

    /// Returns true if number of `cards` is 3 and all of the `cards` features,
    /// looked at one-by-one, are the same on each card, or, are different on each card.
    func isSET(_ cards: Cards) -> Bool {
        guard cards.count == 3 else { return false }
        let colors = Set(cards.map(\.color))
        let numbers = Set(cards.map(\.number))
        let shapes = Set(cards.map(\.shape))
        let shades = Set(cards.map(\.shading))
        return ![colors.count, numbers.count, shapes.count, shades.count].contains(2)
    }

    mutating func deal() {
        // Bail out if there are no undealt cards
        guard let firstUndealtCardIndex = cards.firstIndex(where: { !$0.isDealt })
        else { return }

        // Deal 12 cards if there are no dealt cards yet; then bail out.
        guard firstUndealtCardIndex != cards.startIndex
        else { setValue(true, forKey: \.isDealt, of: Array(cards.prefix(12))); return }

        // Deal 3 cards
        let cardsToBeDealt = Array(cards[firstUndealtCardIndex...].prefix(3))
        setValue(true, forKey: \.isDealt, of: cardsToBeDealt)

        // Swap dealt cards with `selection` if it is a SET
        guard isSET(selection) else { return }
        for (setCard, dealtCard)
            in [Card: Card](uniqueKeysWithValues: zip(selection, cardsToBeDealt))
        {
            let setIndex = cards.firstIndex(of: setCard)!
            let dealtIndex = cards.firstIndex(of: dealtCard)!
            cards.swapAt(setIndex, dealtIndex)
        }
    }

    mutating func select(_ selectedCard: Card) {
        switch selection.count {
        case 1 ... 2 where selection.contains(selectedCard):
            setValue(false, forKey: \.isSelected, of: [selectedCard])
        case 0 ... 1:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
        case 2:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
            setValue(isSET(selection), forKey: \.isMatched, of: selection + [selectedCard])
        case 3 where isSET(selection) && selection.contains(selectedCard):
            setValue(false, forKey: \.isSelected, of: selection)
        case 3:
            setValue(false, forKey: \.isSelected, of: selection)
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
