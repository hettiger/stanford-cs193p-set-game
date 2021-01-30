//
//  ClassicCardView.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

struct ClassicCardView: View {
    var card: ClassicSET.Card

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(backgroundColor)
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                VStack(spacing: vStackSpacing(for: geometry.size)) {
                    ForEach(0 ..< card.number.rawValue) { _ in
                        card.shape
                            .foregroundColor(card.color.value)
                            .aspectRatio(shapeAspectRatio, contentMode: .fit)
                    }
                }
                .padding(cardPadding(for: geometry.size))
            }
        }
        .aspectRatio(cardAspectRatio, contentMode: .fit)
    }

    // MARK: - Drawing Constants

    let cornerRadius: CGFloat = 25.0
    let shapeAspectRatio: CGFloat = 5 / (8 / 3)
    let cardAspectRatio: CGFloat = 5 / 8
    let backgroundColor = Color.white

    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = {
        let radius: CGFloat = 2
        return (color: .black, radius, x: radius / 2, y: radius / 2)
    }()

    func vStackSpacing(for size: CGSize) -> CGFloat {
        size.height * 1 / 24
    }

    func cardPadding(for size: CGSize) -> EdgeInsets {
        EdgeInsets(
            top: size.height * 1 / 8,
            leading: size.width * 1 / 8,
            bottom: size.height * 1 / 8,
            trailing: size.width * 1 / 8
        )
    }
}

struct ClassicCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClassicCardView(card: ClassicSET.Card(
                color: .red, number: .three, shape: .squiggle, shading: .striped
            ))
                .padding(80)
                .preferredColorScheme(.dark)
            ClassicCardView(card: ClassicSET.Card(
                color: .purple, number: .two, shape: .diamond, shading: .solid
            ))
                .padding(80)
            ClassicCardView(card: ClassicSET.Card(
                color: .green, number: .one, shape: .capsule, shading: .open
            ))
                .padding(80)
                .preferredColorScheme(.dark)
        }
    }
}
