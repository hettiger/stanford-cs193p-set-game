//
//  ClassicCardView.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

/// - TODO: Fix random drawing issues on shapes that have been resized (e.g. when cards were dealt)
struct ClassicCardView: View {
    @ObservedObject
    var game = ClassicSET.shared

    var card: ClassicSET.Card
    var numberOfSelectedCards = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius(for: geometry.size))
                    .foregroundColor(backgroundColor)
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                VStack(spacing: vStackSpacing(for: geometry.size)) {
                    ForEach(0 ..< card.number.rawValue) { _ in
                        ClassicShapeView(shape: card.shape, shading: card.shading)
                            .foregroundColor(card.color.value)
                            .aspectRatio(shapeAspect.ratio, contentMode: .fit)
                    }
                }
                .padding(cardPadding(for: geometry.size))
                // TODO: Stop showing hint per default
                .opacity(game.hint.contains(card) ? 1 : 0.2)
                RoundedRectangle(cornerRadius: cornerRadius(for: geometry.size))
                    .strokeBorder(strokeColor(for: card))
                    .aspectRatio(DrawingConstants.cardAspect.ratio, contentMode: .fit)
                    .foregroundColor(.clear)
            }
        }
        .aspectRatio(DrawingConstants.cardAspect.ratio, contentMode: .fit)
    }

    // MARK: - Drawing Constants

    let backgroundColor = Color.white

    var shapeAspect: (width: CGFloat, height: CGFloat, ratio: CGFloat) {
        let maxNumberOfShapes: CGFloat = 3
        let width: CGFloat = DrawingConstants.cardAspect.width
        let height: CGFloat = DrawingConstants.cardAspect.height / maxNumberOfShapes
        return (width, height, width / height)
    }

    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = {
        let radius: CGFloat = 2
        return (color: .black, radius, x: radius / 2, y: radius / 2)
    }()

    func cornerRadius(for size: CGSize) -> CGFloat {
        size.width / 180 * 25.0
    }

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

    func strokeColor(for card: ClassicSET.Card) -> Color {
        switch (card.isSelected, card.isMatched, numberOfSelectedCards) {
        case (true, false, ...2): return .accentColor
        case (true, false, 3...): return .red
        case (true, true, 3...): return .green
        default: return .clear
        }
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
