//
//  SourceRowWithSwipeView.swift
//  SourceRowWithSwipeView
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI

struct SourceRowWithSwipeView: View {
    @Environment(\.managedObjectContext) var ctx
    @ObservedObject var source: SourceEntity
    
    var body: some View {
        SourceRowView(source: source)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    withAnimation {
                        ctx.perform {
                            $source.active.wrappedValue.toggle()
                            try? ctx.save()
                        }
                    }
                }) {
                    Label(source.active ? "Deactive" : "Active",
                          systemImage: source.active ? "xmark" : "checkmark")
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: {
                    withAnimation {
                        ctx.perform {
                            $source.favorite.wrappedValue.toggle()
                            try? ctx.save()
                        }
                    }
                }) {
                    Label(source.favorite ? "Unfavorite" : "Favorite",
                          systemImage: source.favorite ? "hand.thumbsdown" : "hand.thumbsup")
                }.tint(.blue)
            }
    }
}
