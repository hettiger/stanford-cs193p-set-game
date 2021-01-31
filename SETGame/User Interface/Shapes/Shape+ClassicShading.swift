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
            stroke(lineWidth: strokeWidth).padding(padding)
        case .striped:
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: spacing) {
                        // TODO: Fix ForEach<Range<Int>, Int, Rectangle> count (10) != its initial count (0). `ForEach(_:content:)` should only be used for *constant* data. Instead conform data to `Identifiable` or use `ForEach(_:id:content:)` and provide an explicit `id`!
                        ForEach(0 ..< stripes(for: geometry.size)) { _ in
                            Rectangle()
                        }
                    }
                    .clipShape(self)
                    self.stroke(lineWidth: strokeWidth)
                }
                .padding(padding)
            }
        }
    }

    // MARK: - Drawing Constants

    private var spacing: CGFloat { strokeWidth }
    private var padding: CGFloat { strokeWidth / 2 }
    private var strokeWidth: CGFloat { 4 }

    private func stripes(for size: CGSize) -> Int {
        Int(size.width / 1.5 / strokeWidth)
    }
}
