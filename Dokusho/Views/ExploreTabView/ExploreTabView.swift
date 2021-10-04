//
//  ContentView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 13/08/2021.
//

import SwiftUI
import MangaScraper

struct ExploreTabView: View {
    @Environment(\.managedObjectContext) var ctx
    
    @FetchRequest(
        sortDescriptors: [SourceEntity.positionOrder],
        predicate: SourceEntity.onlyActiveAndNotFavorite,
        animation: .default
    )
    var activeSources: FetchedResults<SourceEntity>
    
    @FetchRequest(
        sortDescriptors: [SourceEntity.positionOrder],
        predicate: SourceEntity.onlyFavoriteAndActive,
        animation: .default
    )
    var favoriteSources: FetchedResults<SourceEntity>
    
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Favorite") {
                    ForEach(favoriteSources) { source in
                        FavoriteSourceRowView(source: source)
                    }
                    .onMove(perform: { onMove(offsets: $0, position: $1, sources: favoriteSources) })
                }
                
                Section("Active") {
                    ForEach(activeSources) { source in
                        ActiveSourceRowView(source: source)
                    }
                    .onMove(perform: { onMove(offsets: $0, position: $1, sources: activeSources) })
                }

                Section("All Sources") {
                    ForEach(MangaScraperService.shared.list, id: \.id) { source in
                        OtherSourceRowView(src: source)
                    }
                }
            }
            .toolbar { EditButton() }
            .searchable(text: $searchText)
            .navigationTitle("Explore Source")
        }
    }
    
    @ViewBuilder
    func OtherSourceRowView(src: Source) -> some View {
        SourceRow(src: src)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toogleActive(source: src) }) {
                    Label("Activate", systemSymbol: .checkmark)
                }.tint(.purple)
            }
    }
    
    @ViewBuilder
    func ActiveSourceRowView(source: SourceEntity) -> some View {
        SourceRow(src: try! source.getSource())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toogleActive(source: source) }) {
                    Label("Deactivate", systemSymbol: .xmark)
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { toogleFavorite(source: source) }) {
                    Label("Favorite", systemSymbol: .handThumbsup)
                }.tint(.blue)
            }
    }
    
    @ViewBuilder
    func FavoriteSourceRowView(source: SourceEntity) -> some View {
        SourceRow(src: try! source.getSource())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toogleActive(source: source) }) {
                    Label("Deactivate", systemSymbol: .xmark)
                }.tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: { toogleFavorite(source: source) }) {
                    Label("UnFavorite", systemSymbol: .handThumbsdown)
                }.tint(.blue)
            }
    }
    
    @ViewBuilder
    func SourceRow(src: Source) -> some View {
        NavigationLink(destination: ExploreSourceView(source: src)) {
            HStack {
                RemoteImageCacheView(url: src.icon, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(.trailing)
                
                VStack(alignment: .leading) {
                    Text(src.name)
                    Text(src.lang.rawValue)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical)
        }
    }

    func toogleActive(source: Source) {
        withAnimation {
            try? self.ctx.performAndWait {
                let entity = SourceEntity.createFromSource(ctx: self.ctx, source: source)
                entity.active = true

                try self.ctx.save()
            }
        }
    }

    func toogleActive(source: SourceEntity) {
        withAnimation {
            try? self.ctx.performAndWait {
                source.active.toggle()
                try ctx.save()
            }
        }
    }

    func toogleFavorite(source: SourceEntity) {
        withAnimation {
            try? ctx.performAndWait {
                source.favorite.toggle()
                try ctx.save()
            }
        }
    }
    
    func onMove(offsets: IndexSet, position: Int, sources: FetchedResults<SourceEntity>) {
        try? ctx.performAndWait {
            var revisedItems: [SourceEntity] = sources.map{ $0 }

            // change the order of the items in the array
            revisedItems.move(fromOffsets: offsets, toOffset: position)

            // update the userOrder attribute in revisedItems to
            // persist the new order. This is done in reverse order
            // to minimize changes to the indices.
            for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                revisedItems[reverseIndex].position = Int16(reverseIndex)
            }
            
            try ctx.save()
        }
    }
}
