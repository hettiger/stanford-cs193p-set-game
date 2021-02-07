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
            game.sets(cardsVisible) { sets, cards in
                guard self.cardsVisible == cards else { return }
                self.visibleSETs = sets
            }
        }
    }

    // MARK: - Model Accessors

    var cardsDeck: Cards { game.cards.filter { !$0.isDealt } }
    var cardsVisible: Cards { game.cards.filter(\.isVisible) }
    var cardsSelected: Cards { game.cards.filter(\.isSelected) }
    var cardsMatched: Cards { game.cards.filter(\.isMatched) }

    var numberOfFoundSETs: Int { cardsMatched.count / 3 }
    var isCheated: Bool { game.isCheated }

    @Published
    private(set) var visibleSETs = [Cards]()

    // MARK: - Intents

    func select(_ card: Card) {
        game.select(card)
    }

    func deal() {
        game.deal()
    }

    func cheat() {
        game.cheat()
    }

    func startNewGame() {
        game = Game()
        game.deal()
    }
}
