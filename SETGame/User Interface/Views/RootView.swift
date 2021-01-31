//
//  RootView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct RootView: View {
    @ObservedObject
    var game = ClassicSET.shared

    @State
    var isPresentedMissingImplementationAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Rectangle().foregroundColor(backgroundColor)
                ClassicGameView()
                    .navigationBarItems(
                        leading: Text("Score"),
                        trailing: Button("New Game") {
                            withAnimation(.easeInOut) {
                                game.startNewGame()
                            }
                        }
                        .foregroundColor(.accentColor)
                    )
                    .navigationBarTitle("SET", displayMode: .inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button("Hint (Total SETs visible)") {
                                isPresentedMissingImplementationAlert = true
                            }
                            Spacer()
                            Button("Deal Cards") {
                                withAnimation(.easeInOut) {
                                    game.deal()
                                }
                            }
                        }
                    }
                    .foregroundColor(.secondary)
                    .alert(isPresented: $isPresentedMissingImplementationAlert, content: {
                        Alert(
                            title: Text("Missing Implementation"),
                            message: Text("Still working on this; please be patient."),
                            dismissButton: .default(Text("OK"))
                        )
                    })
            }
        }
    }

    // MARK: - Drawing Constants

    let backgroundColor = Color(UIColor.secondarySystemBackground)
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView()
            RootView()
                .preferredColorScheme(.dark)
        }
    }
}
