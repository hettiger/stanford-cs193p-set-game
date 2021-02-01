//
//  Shape+ClassicShading.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

extension Shape {
    @ViewBuilder
    func shading(_ type: ClassicSET.ShadingType) -> some View {
        switch type {
        case .solid:
            fill()
        case .open:
            GeometryReader { geometry in
                stroke(lineWidth: strokeWidth(for: geometry.size))
                    .padding(padding(for: geometry.size))
            }
        case .striped:
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: spacing(for: geometry.size)) {
                        ForEach(0 ..< stripes(for: geometry.size), id: \.self) { _ in
                            Rectangle()
                        }
                    }
                    .clipShape(self)
                    self.stroke(lineWidth: strokeWidth(for: geometry.size))
                }
                .padding(padding(for: geometry.size))
            }
        }
    }

    // MARK: - Drawing Constants

    private func spacing(for size: CGSize) -> CGFloat {
        strokeWidth(for: size)
    }

    private func padding(for size: CGSize) -> CGFloat {
        strokeWidth(for: size) / 2
    }

    private func strokeWidth(for size: CGSize) -> CGFloat {
        size.width / 100 * 4
    }

    private func stripes(for size: CGSize) -> Int {
        Int(size.width / 1.5 / strokeWidth(for: size))
    }
}
