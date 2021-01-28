//
//  SET.swift
//  SETGame
//
//  Created by Martin Hettiger on 26.01.21.
//

import Foundation

struct SET<ColorType, NumberType, ShapeType, ShadingType> where
    ColorType: Hashable, ColorType: CaseIterable,
    NumberType: Hashable, NumberType: CaseIterable,
    ShapeType: Hashable, ShapeType: CaseIterable,
    ShadingType: Hashable, ShadingType: CaseIterable
{
    enum Selection: Hashable {
        case none
        case one(Card)
        case two(Card, Card)
        case three(Card, Card, Card)

        /// Returns true if is selection of three cards where all of the selected cards features,
        /// looked at one-by-one, are the same on each card, or, are different on each card.
        var isMatch: Bool {
            switch self {
            case let .three(cardA, cardB, cardC):
                let colors = Set([cardA.color, cardB.color, cardC.color])
                let numbers = Set([cardA.number, cardB.number, cardC.number])
                let shapes = Set([cardA.shape, cardB.shape, cardC.shape])
                let shades = Set([cardA.shading, cardB.shading, cardC.shading])
                return ![colors.count, numbers.count, shapes.count, shades.count].contains(2)
            default:
                return false
            }
        }
    }

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
    }

    private var randomSource: RandomSource
    private(set) var selection = Selection.none
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
        self.randomSource = randomSource
    }

    mutating func deal() {
        for index in Array(cards.indices).shuffled(using: randomSource).prefix(12) {
            cards[index].isDealt = true
        }
    }

    mutating func select(_ selectedCard: Card) {
        switch selection {
        case .none:
            setValue(true, forKey: \.isSelected, of: [selectedCard])
            selection = .one(selectedCard)
        case let .one(card) where card == selectedCard:
            setValue(false, forKey: \.isSelected, of: [selectedCard])
            selection = .none
        case let .one(card):
            setValue(true, forKey: \.isSelected, of: [selectedCard])
            selection = .two(card, selectedCard)
        case let .two(cardA, cardB) where cardA == selectedCard || cardB == selectedCard:
            setValue(false, forKey: \.isSelected, of: [selectedCard])
            selection = .one(cardB)
        case let .two(cardA, cardB):
            setValue(true, forKey: \.isSelected, of: [selectedCard])
            selection = .three(cardA, cardB, selectedCard)
        default:
            break
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
