//
//  View.swift
//  Dokusho
//
//  Created by Stephan Deumier on 07/07/2021.
//

import SwiftUI

extension View {
    func sheetSizeAware<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item: Identifiable, Content: View {
        if UIScreen.isLargeScreen {
            return AnyView(self.fullScreenCover(item: item, onDismiss: onDismiss) { item in
                content(item)
            })
        }
        else {
            return AnyView(self.sheet(item: item, onDismiss: onDismiss) { item in
                content(item)
            })
        }
    }

    func glowBorder(color: Color, lineWidth: Int) -> some View {
        self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
    }
}
