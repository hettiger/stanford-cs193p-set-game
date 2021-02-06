//
//  DrawingConstants.swift
//  SETGame
//
//  Created by Martin Hettiger on 01.02.21.
//

import SwiftUI

enum DrawingConstants {
    static var cardAspect: (width: CGFloat, height: CGFloat, ratio: CGFloat) {
        let width: CGFloat = 5
        let height: CGFloat = 8
        return (width, height, width / height)
    }

    /// Returns baseline animation duration multiplied by `x`
    static func animationDuration(x: Double) -> Double {
        x * 0.3
    }
}
