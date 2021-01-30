//
//  CGSize+Subscript.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

extension CGSize {
    enum Axis {
        case x, y
    }

    /// Returns the `axis` length of `self` multiplied with a given `factor`.
    ///
    /// This is useful if you need e.g. ⅓ of the width of `self`. (`self[.x, 1/3]`)
    ///
    /// - Parameters:
    ///   - axis: provides the whole length.
    ///   - factor: forms a product with the axis length.
    subscript(axis: Axis, factor: CGFloat) -> CGFloat {
        switch axis {
        case .x: return width * factor
        case .y: return height * factor
        }
    }
}
