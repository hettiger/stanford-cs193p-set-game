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

    @State
    var isPresentedMissingImplementationAlert = false

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
                            withAnimation {
                                game.startNewGame()
                            }
                        }
                        .foregroundColor(.accentColor)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Hint (\(game.visibleSETs.count))") {
                            isPresentedMissingImplementationAlert = true
                        }
                        Spacer()
                        Button("Deal Cards") {
                            withAnimation {
                                game.deal()
                            }
                        }
                    }
                }
                .alert(isPresented: $isPresentedMissingImplementationAlert, content: {
                    Alert(
                        title: Text("Missing Implementation"),
                        message: Text("Still working on this; please be patient."),
                        dismissButton: .default(Text("OK"))
                    )
                })
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
