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
    }

    typealias Cards = [Card]

    struct Card: Hashable {
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
}
