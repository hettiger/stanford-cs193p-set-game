//
//  SETFake.swift
//  SETGameTests
//
//  Created by Martin Hettiger on 28.01.21.
//

import Foundation
@testable import SETGame

typealias SETFake = SET<ColorTypeFake, NumberTypeFake, ShapeTypeFake, ShadingTypeFake>

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
