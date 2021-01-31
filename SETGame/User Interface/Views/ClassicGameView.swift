//
//  ClassicGameView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct ClassicGameView: View {
    @ObservedObject
    var game = ClassicSET.shared

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
                    .strokeBorder(strokeColor(for: card))
                    .aspectRatio(cardAspectRatio, contentMode: .fit)
                    .foregroundColor(.clear)
            }
            .padding()
            .transition(transition(for: index))
            .onAppear { numberOfDealtCards += 1 }
            .onDisappear { numberOfDealtCards -= 1 }
        }
        .onAppear {
            withAnimation {
                game.deal()
            }
        }
    }

    // MARK: - Drawing Constants

    let cardAspectRatio: CGFloat = 5 / 8
    let cornerRadius: CGFloat = 25.0

    func strokeColor(for card: ClassicSET.Card) -> Color {
        switch (card.isSelected, card.isMatched, game.cards.filter(\.isSelected).count) {
        case (true, false, ...2): return .accentColor
        case (true, false, 3...): return .red
        case (true, true, 3...): return .green
        default: return .clear
        }
    }

    func transition(for index: Int) -> AnyTransition {
        let delay = Double(index - numberOfDealtCards) * 0.3
        return AnyTransition.asymmetric(
            insertion: AnyTransition
                .move(edge: .bottom)
                .combined(with: .scale(scale: 0, anchor: .bottom))
                .animation(
                    Animation.easeInOut.delay(delay)
                ),
            removal: AnyTransition
                .move(edge: .top)
                .combined(with: .scale(scale: 0, anchor: .top))
        )
    }
}

struct ClassicGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicSET.shared.deal()
        return ClassicGameView()
    }
}
