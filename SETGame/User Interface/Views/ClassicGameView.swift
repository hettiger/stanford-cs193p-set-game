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

    var body: some View {
        Grid(
            game.cardsVisible,
            desiredAspectRatio: DrawingConstants.cardAspect.ratio
        ) { card in
            ClassicCardView(card: card)
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: 0.9)) { game.select(card) }
                }
                .padding()
                .transition(.offset(randomOffScreenOffset))
        }
    }

    var randomOffScreenOffset: CGSize {
        let screen = (width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        var factor: CGFloat { CGFloat([-1, 1].randomElement()!) }
        return CGSize(width: factor * screen.width, height: factor * screen.height)
    }
}

struct ClassicGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicSET.shared.deal()
        return ClassicGameView()
    }
}
