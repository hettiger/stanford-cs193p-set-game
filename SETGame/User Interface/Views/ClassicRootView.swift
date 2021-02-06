//
//  ClassicRootView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct ClassicRootView: View {
    @ObservedObject
    var game = ClassicSET.shared

    var body: some View {
        NavigationView {
            ClassicGameView()
                .navigationBarTitle("SET", displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Text("Score: \(game.numberOfFoundSETs)")
                            .foregroundColor(.secondary)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("New Game") {
                            withAnimation(.easeInOut(duration: animationDuration.newGame)) {
                                game.startNewGame()
                            }
                        }
                        .foregroundColor(.accentColor)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Cheat (\(game.visibleSETs.count))") {
                            withAnimation(.linear(duration: animationDuration.cheat)) {
                                game.cheat()
                            }
                        }
                        Spacer()
                        Button("Deal Cards") {
                            withAnimation(.easeInOut(duration: animationDuration.deal)) {
                                game.deal()
                            }
                        }
                        .disabled(game.cardsDeck.isEmpty)
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: animationDuration.initialDeal)) {
                    game.deal()
                }
            }
        }
    }

    // MARK: - Drawing Constants

    let backgroundColor = Color(UIColor.secondarySystemBackground)

    var animationDuration: (newGame: Double, cheat: Double, deal: Double, initialDeal: Double) {
        let fn = DrawingConstants.animationDuration
        return (fn(4), fn(1), fn(3), fn(8))
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClassicRootView()
            ClassicRootView()
                .preferredColorScheme(.dark)
        }
    }
}
