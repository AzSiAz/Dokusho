//
//  NavigationLink.swift
//  Dokusho
//
//  Created by Stef on 27/04/2022.
//

import SwiftUI

public extension View {
    func navigate<Destination: View>(
        isActive: Binding<Bool>,
        destination: Destination?
    ) -> some View {
        background(
            NavigationLink(
                destination: destination,
                isActive: isActive,
                label: EmptyView.init
            )
            .hidden()
        )
    }
}
public extension View {
    func navigate<Item, Destination: View>(
        item: Binding<Item?>,
        destination: (Item) -> Destination
    ) -> some View {
        navigate(
            isActive: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            destination: Group {
                if let item = item.wrappedValue {
                    destination(item)
                }
            }
        )
    }
}
