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
                            withAnimation { game.startNewGame() }
                        }
                        .foregroundColor(.accentColor)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Cheat (\(game.visibleSETs.count))") {
                            withAnimation { game.cheat() }
                        }
                        Spacer()
                        Button("Deal Cards") {
                            withAnimation { game.deal() }
                        }
                        .disabled(game.cardsDeck.isEmpty)
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Drawing Constants

    let backgroundColor = Color(UIColor.secondarySystemBackground)
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
