//
//  View.swift
//  Dokusho
//
//  Created by Stephan Deumier on 07/07/2021.
//

import SwiftUI

extension View {
    
    func sheetSizeAware<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item: Identifiable, Content: View {
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            return AnyView(self.fullScreenCover(item: item) { item in
                content(item)
            })
        }
        else {
            return AnyView(self.sheet(item: item) { item in
                content(item)
            })
        }
    }
}

extension UIScreen {
    static func isLargeScreen() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }
}
