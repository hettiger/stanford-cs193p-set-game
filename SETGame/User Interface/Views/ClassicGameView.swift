//
//  ClassicGameView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct ClassicGameView: View {
    @ObservedObject var game = ClassicSET.shared

    var body: some View {
        Grid(game.cards.filter(\.isVisible), desiredAspectRatio: cardAspectRatio) { card in
            ZStack {
                ClassicCardView(card: card)
                    .onTapGesture(count: 1) {
                        game.select(card)
                    }
                    .opacity(game.hint.contains(card) ? 1 : 0.5)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(card.isSelected ? isSelectedColor : Color.clear)
                    .aspectRatio(cardAspectRatio, contentMode: .fit)
                    .foregroundColor(.clear)
            }
            .padding()
        }
    }

    // MARK: - Drawing Constants

    let cardAspectRatio: CGFloat = 5 / 8
    let cornerRadius: CGFloat = 25.0
    let isSelectedColor = Color.accentColor
}

struct ClassicGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicGameView()
    }
}
