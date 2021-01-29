//
//  SETFake.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 28.01.21.
//

import Foundation
@testable import SETGame

typealias SETFake = SET<ColorTypeFake, NumberTypeFake, ShapeTypeFake, ShadingTypeFake>

extension SETFake {
    var cardsDealt: Cards { cards.filter(\.isDealt) }
    var cardsSelected: Cards { cards.filter(\.isSelected) }
    var cardsMatched: Cards { cards.filter(\.isMatched) }
    var cardsVisible: Cards { cards.filter(\.isVisible) }
}

enum ColorTypeFake: Hashable, CaseIterable {
    case red, green, purple
}

enum NumberTypeFake: Hashable, CaseIterable {
    case one, two, three
}

enum ShapeTypeFake: Hashable, CaseIterable {
    case diamond, squiggle, oval
}

enum ShadingTypeFake: Hashable, CaseIterable {
    case solid, striped, open
}
