//
//  ClassicSET.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

class ClassicSET: ObservableObject {
    typealias Game = SET<ColorType, NumberType, ShapeType, ShadingType>
    typealias Card = Game.Card
    typealias Cards = [Card]

    enum ColorType: Hashable, CaseIterable {
        case red, green, purple

        var value: Color {
            switch self {
            case .red: return .red
            case .green: return .green
            case .purple: return .purple
            }
        }
    }

    enum NumberType: Int, Hashable, CaseIterable {
        case one = 1, two, three
    }

    enum ShapeType: Hashable, CaseIterable {
        case diamond, squiggle, capsule

        var value: AnyShape {
            switch self {
            case .diamond: return AnyShape(Diamond())
            case .squiggle: return AnyShape(Squiggle())
            case .capsule: return AnyShape(Capsule())
            }
        }
    }

    enum ShadingType: Hashable, CaseIterable {
        case solid, striped, open
    }

    static var shared = ClassicSET()

    // MARK: - Model

    @Published
    private var game = Game() {
        didSet {
            cardsVisible = game.cards.filter(\.isVisible)
            cardsSelected = game.cards.filter(\.isSelected)
            cardsMatched = game.cards.filter(\.isMatched)

            game.sets(cardsVisible) { sets in
                self.numberOfVisibleSETs = sets.count
            }
        }
    }

    // MARK: - Model Accessors

    var cardsVisible = Cards()
    var cardsSelected = Cards()
    var cardsMatched = Cards()

    var numberOfFoundSETs: Int {
        cardsMatched.count / 3
    }

    var hint: Cards {
        guard let firstSET = game.firstSET(cardsVisible) else { return [] }
        return [firstSET.0, firstSET.1, firstSET.2]
    }

    @Published
    private(set) var numberOfVisibleSETs = 0

    // MARK: - Intents

    func select(_ card: Card) {
        game.select(card)
    }

    func deal() {
        game.deal()
    }

    func startNewGame() {
        game = Game()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.game.deal()
        }
    }
}
