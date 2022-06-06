//
//  GlowBorder.swift
//  Dokusho
//
//  Created by Stef on 24/11/2021.
//

import SwiftUI

public struct GlowBorder: ViewModifier {
    var color: Color
    var lineWidth: Int
    
    public func body(content: Content) -> some View {
        applyShadow(content: AnyView(content), lineWidth: lineWidth)
    }
    
    func applyShadow(content: AnyView, lineWidth: Int) -> AnyView {
        if lineWidth == 0 {
            return content
        } else {
            return applyShadow(content: AnyView(content.shadow(color: color, radius: 1)), lineWidth: lineWidth - 1)
        }
    }
}
