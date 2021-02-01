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

    var body: some View {
        switch shading {
        case .solid:
            shape.value.fill()
        case .open:
            GeometryReader { geometry in
                shape.value
                    .stroke(lineWidth: strokeWidth(for: geometry.size))
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
                    .clipShape(shape.value)
                    shape.value.stroke(lineWidth: strokeWidth(for: geometry.size))
                }
                .padding(padding(for: geometry.size))
            }
        }
    }

    // MARK: - Drawing Constants

    func spacing(for size: CGSize) -> CGFloat {
        strokeWidth(for: size)
    }

    func padding(for size: CGSize) -> CGFloat {
        strokeWidth(for: size) / 2
    }

    func strokeWidth(for size: CGSize) -> CGFloat {
        size.width / 100 * 4
    }

    func stripes(for size: CGSize) -> Int {
        Int(size.width / 1.5 / strokeWidth(for: size))
    }
}

struct ClassicShapeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClassicShapeView(
                shape: .squiggle,
                shading: .striped
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
            ClassicShapeView(
                shape: .diamond,
                shading: .open
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
            ClassicShapeView(
                shape: .capsule,
                shading: .solid
            ).frame(
                width: 200,
                height: 100,
                alignment: .center
            )
        }
    }
}
