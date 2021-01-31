//
//  ClassicGameView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct ClassicGameView: View {
    @ObservedObject var game = ClassicSET.shared

    @State
    var numberOfDealtCards = 0

    var body: some View {
        Grid(game.cards.filter(\.isVisible), desiredAspectRatio: cardAspectRatio) { card, index in
            ZStack {
                ClassicCardView(card: card)
                    .onTapGesture(count: 1) { game.select(card) }
                    // TODO: Stop showing hint per default
                    .opacity(game.hint.contains(card) ? 1 : 0.5)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(card.isSelected ? isSelectedColor : Color.clear)
                    .aspectRatio(cardAspectRatio, contentMode: .fit)
                    .foregroundColor(.clear)
            }
            .padding()
            .transition(AnyTransition.asymmetric(
                insertion: AnyTransition
                    .move(edge: .bottom)
                    .combined(with: .scale(scale: 0, anchor: .bottom))
                    .animation(
                        Animation.easeInOut.delay(animationDelay(for: index))
                    ),
                removal: AnyTransition
                    .move(edge: .top)
                    .combined(with: .scale(scale: 0, anchor: .top))
            ))
            .onAppear { numberOfDealtCards += 1 }
            .onDisappear { numberOfDealtCards -= 1 }
        }
    }

    // MARK: - Drawing Constants

    let cardAspectRatio: CGFloat = 5 / 8
    let cornerRadius: CGFloat = 25.0
    let isSelectedColor = Color.accentColor

    func animationDelay(for index: Int) -> Double {
        Double(index - numberOfDealtCards) * 0.3
    }
}

struct ClassicGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicSET.shared.deal()
        return ClassicGameView()
    }
}
