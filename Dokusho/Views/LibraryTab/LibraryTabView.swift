//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct LibraryTabView: View {
    @FetchRequest(sortDescriptors: [CollectionEntity.positionOrder], predicate: nil, animation: .default)
    var collections: FetchedResults<CollectionEntity>

    @StateObject var vm: LibraryVM = .init()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(collections) { collection in
                    NavigationLink(destination: CollectionPage(collection: collection)) {
                        Label("\(collection.getName()) (\(collection.mangas?.count ?? 0))", systemImage: "square.grid.2x2")
                    }
                }
            }
            .toolbar(content: { AddButton(onTapGesture: { print("test") }) })
            .navigationTitle(Text("Collections"))
        }
        .navigationViewStyle(.stack)
    }
}

struct CollectionPage: View {
    @ObservedObject var collection: CollectionEntity
    
    @FetchRequest
    var mangas: FetchedResults<MangaEntity>
    
    init(collection: CollectionEntity) {
        self._collection = .init(wrappedValue: collection)
        self._mangas = .init(sortDescriptors: [MangaEntity.lastUpdate], predicate: MangaEntity.collectionPredicate(collection: collection), animation: .default)
    }
    
    var body: some View {
        List {
            ForEach(mangas) { manga in
                Text(manga.title!)
            }
        }
        .navigationTitle(collection.getName())
    }
}
