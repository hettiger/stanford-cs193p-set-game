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
        Grid(
            game.cardsVisible,
            desiredAspectRatio: DrawingConstants.cardAspect.ratio
        ) { card, index in
            ClassicCardView(card: card)
                .onTapGesture(count: 1) { game.select(card) }
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
