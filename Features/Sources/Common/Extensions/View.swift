//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


public extension View {
    func glowBorder(color: Color, lineWidth: Int) -> some View {
        self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
    }
    
    
    func addPinchAndPan() -> some View {
        self.modifier(PinchAndPanImage())
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
