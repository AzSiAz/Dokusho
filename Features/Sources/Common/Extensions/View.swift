//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI

fileprivate struct SizePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public extension View {
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
    
    
    func addPinchAndPan(isZooming: Binding<Bool>) -> some View {
        self.modifier(PinchAndPanImage(isZooming: isZooming))
    }
    
    func readSize(global: Bool = false, onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: global ? geometryProxy.frame(in: .global).size : geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
