//
//  Squiggle.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

struct Squiggle: Shape {
    func path(in rect: CGRect) -> Path {
        let size = rect.size
        let controlPointDistance = (
            small: rect.maxX * 0.1,
            medium: rect.maxX * 0.2,
            big: rect.maxX * 0.3
        )

        var path = Path()

        path.move(to: CGPoint(x: rect.minX + controlPointDistance.small, y: rect.maxY))

        path.addCurve(
            to: CGPoint(x: size[.x, 1 / 3], y: rect.minY),
            control1: CGPoint(x: rect.minX - controlPointDistance.small, y: rect.maxY),
            control2: CGPoint(
                x: size[.x, 1 / 3] - controlPointDistance.big,
                y: rect.minY
            )
        )

        path.addCurve(
            to: CGPoint(x: size[.x, 2 / 3], y: size[.y, 1 / 3]),
            control1: CGPoint(
                x: size[.x, 1 / 3] + controlPointDistance.medium,
                y: rect.minY
            ),
            control2: CGPoint(
                x: size[.x, 2 / 3] - controlPointDistance.small,
                y: size[.y, 1 / 3]
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.maxX - controlPointDistance.small, y: rect.minY),
            control1: CGPoint(
                x: size[.x, 2 / 3] + controlPointDistance.small,
                y: size[.y, 1 / 3]
            ),
            control2: CGPoint(
                x: rect.maxX - 2 * controlPointDistance.small,
                y: rect.minY
            )
        )

        path.addCurve(
            to: CGPoint(x: size[.x, 2 / 3], y: rect.maxY),
            control1: CGPoint(x: rect.maxX + controlPointDistance.small, y: rect.minY),
            control2: CGPoint(
                x: size[.x, 2 / 3] + controlPointDistance.big,
                y: rect.maxY
            )
        )

        path.addCurve(
            to: CGPoint(x: size[.x, 1 / 3], y: size[.y, 2 / 3]),
            control1: CGPoint(
                x: size[.x, 2 / 3] - controlPointDistance.medium,
                y: rect.maxY
            ),
            control2: CGPoint(
                x: size[.x, 1 / 3] + controlPointDistance.small,
                y: size[.y, 2 / 3]
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.minX + controlPointDistance.small, y: rect.maxY),
            control1: CGPoint(
                x: size[.x, 1 / 3] - controlPointDistance.small,
                y: size[.y, 2 / 3]
            ),
            control2: CGPoint(
                x: rect.minX + 2 * controlPointDistance.small,
                y: rect.maxY
            )
        )

        path.closeSubpath()

        return path
    }
}
