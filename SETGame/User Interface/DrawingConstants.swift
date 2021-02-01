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
}
