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
        Self.guardAgainstInvalidFeatureEnumerations()
        cards = Cards(Self.makeCards().shuffled(using: randomSource))
    }

    private static func guardAgainstInvalidFeatureEnumerations() {
        if [
            ColorType.allCases.count,
            NumberType.allCases.count,
            ShapeType.allCases.count,
            ShadingType.allCases.count,
        ].contains(where: { $0 != 3 }) {
            fatalError(
                "initializing SET with feature enumeration not having 3 cases is not supported"
            )
        }
    }

    private static func makeCards() -> Cards {
        var cards = Cards()
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
        return cards
    }

    /// Returns first possible SET found in `cards`
    func firstSET(_ cards: Cards) -> (Card, Card, Card)? {
        guard let set = cards.combinations(ofCount: 3).first(where: { isSET($0) })
        else { return nil }
        return (set[0], set[1], set[2])
    }

    /// Calls `callback` with all possible SETs found in `cards`
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

    /// Deals cards per the rules of SET; i.e. starts with 12 cards;
    /// continues with 3 cards until whole deck of cards is dealt;
    /// swaps dealt cards with `selection` if it is a SET.
    ///
    /// Swapping of cards may help with replacing cards in the UI.
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

    /// Handles selection of `card` per the rules of SET;
    /// i.e. manages state of `oldSelection` and `card`.
    mutating func select(_ card: Card) {
        let oldSelection = selection
        switch oldSelection.count {
        case 1 ... 2 where oldSelection.contains(card):
            setValue(false, forKey: \.isSelected, of: [card])
        case 0 ... 1:
            setValue(true, forKey: \.isSelected, of: [card])
        case 2:
            setValue(true, forKey: \.isSelected, of: [card])
            setIsMatched(for: selection)
        case 3 where isSET(oldSelection):
            deal()
            setValue(true, forKey: \.isSelected, of: [card])
            setValue(false, forKey: \.isSelected, of: oldSelection)
        case 3:
            setValue(false, forKey: \.isSelected, of: oldSelection)
            setValue(true, forKey: \.isSelected, of: [card])
        default:
            fatalError("invalid number of selected cards")
        }
    }

    private mutating func setIsMatched(for cards: Cards) {
        setValue(isSET(cards), forKey: \.isMatched, of: cards)
    }

    private mutating func setValue<Value>(
        _ value: Value,
        forKey keyPath: WritableKeyPath<Card, Value>,
        of cards: Cards
    ) {
        cards.forEach { self.cards[self.cards.firstIndex(of: $0)!][keyPath: keyPath] = value }
    }
}
