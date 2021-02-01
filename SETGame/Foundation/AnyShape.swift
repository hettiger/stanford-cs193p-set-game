//
//  AnyShape.swift
//  SETGame
//
//  Created by Martin Hettiger on 01.02.21.
//

import SwiftUI

struct AnyShape: Shape {
    private var makePath: (CGRect) -> Path

    init<ShapeType: Shape>(_ shape: ShapeType) {
        makePath = shape.path
    }

    func path(in rect: CGRect) -> Path {
        makePath(rect)
    }
}
