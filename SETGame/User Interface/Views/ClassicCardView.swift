//
//  ClassicCardView.swift
//  SETGame
//
//  Created by Martin Hettiger on 30.01.21.
//

import SwiftUI

struct ClassicCardView: View {
    @ObservedObject
    var game = ClassicSET.shared

    var card: ClassicSET.Card

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                emptyCard(for: geometry.size)
                VStack(spacing: vStackSpacing(for: geometry.size)) {
                    ForEach(0 ..< card.number.rawValue) { _ in
                        ClassicShapeView(
                            shape: card.shape,
                            shading: card.shading,
                            strokeWidth: strokeWidth(for: geometry.size)
                        )
                        .foregroundColor(card.color.value)
                        .aspectRatio(shapeAspect.ratio, contentMode: .fit)
                    }
                }
                .padding(cardPadding(for: geometry.size))
                .opacity(opacity)
                selectionHighlighting(for: geometry.size)
            }
        }
        .aspectRatio(DrawingConstants.cardAspect.ratio, contentMode: .fit)
    }

    func emptyCard(for size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius(for: size))
            .foregroundColor(backgroundColor)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    @ViewBuilder
    func selectionHighlighting(for size: CGSize) -> some View {
        if card.isSelected {
            RoundedRectangle(cornerRadius: cornerRadius(for: size))
                .strokeBorder(
                    strokeColor(for: card),
                    lineWidth: strokeWidth(for: size)
                )
                .aspectRatio(DrawingConstants.cardAspect.ratio, contentMode: .fit)
                .foregroundColor(.clear)
                .transition(.identity)
        }
    }

    // MARK: - Drawing Constants

    let backgroundColor = Color.white

    var shapeAspect: (width: CGFloat, height: CGFloat, ratio: CGFloat) {
        let maxNumberOfShapes: CGFloat = 3
        let width: CGFloat = DrawingConstants.cardAspect.width
        let height: CGFloat = DrawingConstants.cardAspect.height / maxNumberOfShapes
        return (width, height, width / height)
    }

    var opacity: Double {
        guard game.isCheated, let hint = game.visibleSETs.first else { return 1 }
        return hint.contains(card) ? 1 : 0.2
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
        switch (card.isSelected, card.isMatched, game.cardsSelected.count) {
        case (true, false, ...2): return .accentColor
        case (true, false, 3...): return .red
        case (true, true, 3...): return .green
        default: return .clear
        }
    }

    func strokeWidth(for size: CGSize) -> CGFloat {
        size.width / 120 * 4
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
