//
//  GridView.swift
//  SETGame
//
//  Created by Martin Hettiger on 31.01.21.
//

import SwiftUI

struct Grid<Item: Identifiable, ItemView: View>: View where Item: Hashable {
    var items: [Item]
    var desiredAspectRatio: Double
    var viewForItem: (Item, Int) -> ItemView

    init(
        _ items: [Item],
        desiredAspectRatio: CGFloat = 1,
        viewForItem: @escaping (Item, Int) -> ItemView
    ) {
        self.items = items
        self.desiredAspectRatio = Double(desiredAspectRatio)
        self.viewForItem = viewForItem
    }

    var body: some View {
        GeometryReader { geometry in
            let layout = GridLayout(
                itemCount: items.count,
                nearAspectRatio: desiredAspectRatio,
                in: geometry.size
            )
            let (width, height) = (layout.itemSize.width, layout.itemSize.height)
            ForEach(items) { item in
                let index = items.firstIndex(of: item)!
                let position = layout.location(ofItemAt: index)
                viewForItem(item, index).frame(width: width, height: height).position(position)
            }
        }
    }
}

struct Grid_Previews: PreviewProvider {
    static var previews: some View {
        let game = ClassicSET.shared
        game.deal()
        return Grid(game.cards.filter(\.isVisible)) { card, _ in
            ClassicCardView(card: card).padding()
        }
    }
}
