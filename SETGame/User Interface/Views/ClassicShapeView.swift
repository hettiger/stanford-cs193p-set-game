//
//  ClassicShapeView.swift
//  SETGame
//
//  Created by Martin Hettiger on 01.02.21.
//

import SwiftUI

struct ClassicShapeView: View {
    var shape: ClassicSET.ShapeType
    var shading: ClassicSET.ShadingType
    var strokeWidth: CGFloat

    var body: some View {
        switch shading {
        case .solid:
            shape.value.fill()
        case .open:
            GeometryReader { _ in
                shape.value
                    .stroke(lineWidth: strokeWidth)
                    .padding(padding)
            }
        case .striped:
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: spacing) {
                        ForEach(0 ..< stripes(for: geometry.size), id: \.self) { _ in
                            Rectangle()
                        }
                    }
                    .clipShape(shape.value)
                    shape.value.stroke(lineWidth: strokeWidth)
                }
                .padding(padding)
            }
        }
    }

    // MARK: - Drawing Constants

    var spacing: CGFloat { strokeWidth }
    var padding: CGFloat { strokeWidth / 2 }

    func stripes(for size: CGSize) -> Int {
        Int(size.width / 1.5 / strokeWidth)
    }
}

struct ClassicShapeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClassicShapeView(
                shape: .squiggle,
                shading: .striped,
                strokeWidth: 4
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
            ClassicShapeView(
                shape: .diamond,
                shading: .open,
                strokeWidth: 4
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
            ClassicShapeView(
                shape: .capsule,
                shading: .solid,
                strokeWidth: 4
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
        }
    }
}
