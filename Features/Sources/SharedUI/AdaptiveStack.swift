//
//  SidebarView.swift
//  Dokusho
//
//  Created by Stef on 22/09/2021.
//

import SwiftUI

public struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    public init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        Group {
            if sizeClass == .compact {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }
        }
    }
}
