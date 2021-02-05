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
            cardsDeck = game.cards.filter { !$0.isDealt }
            cardsVisible = game.cards.filter(\.isVisible)
            cardsSelected = game.cards.filter(\.isSelected)
            cardsMatched = game.cards.filter(\.isMatched)

            game.sets(cardsVisible) { sets in
                self.visibleSETs = sets
            }
        }
    }

    // MARK: - Model Accessors

    private(set) var cardsDeck = Cards()
    private(set) var cardsVisible = Cards()
    private(set) var cardsSelected = Cards()
    private(set) var cardsMatched = Cards()

    var numberOfFoundSETs: Int {
        cardsMatched.count / 3
    }

    var isCheated: Bool {
        game.isCheated
    }

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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.game.deal()
        }
    }
}
