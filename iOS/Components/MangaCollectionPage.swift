//
//  MangaCollectionPage.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import SwiftUI

struct MangaCollectionPage: View {
    @EnvironmentObject var sourcesSvc: MangaSourceService
    @StateObject private var vm = VM()
    
    var fetchRequest: FetchRequest<Manga>
    var mangas: FetchedResults<Manga> { fetchRequest.wrappedValue }
    var collection: MangaCollection
    
    var columns: [GridItem] {
        var base = [
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base.append(contentsOf: base)
            base.append(contentsOf: [
                GridItem(.fixed(120)),
                GridItem(.fixed(120)),
                GridItem(.fixed(120)),
            ])
        }
        
        return base
    }
    
    init(collection: MangaCollection) {
        self.collection = collection
        self.fetchRequest = FetchRequest<Manga>(fetchRequest: Manga.fetchMany(collection: collection))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(mangas.getFiltered(filter: collection.filter)) { manga in
                    UnreadChapterObs(manga: manga) { count in
                        ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .overlay(alignment: .topTrailing) { MangaUnreadCount(count: count) }
                            .contextMenu { MangaLibraryContextMenu(manga: manga, count: count) }
                            .onTapGesture { vm.selectManga(for: manga) }
                            .frame(height: 180)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .sheetSizeAware(item: $vm.selectedManga) { manga in
            MangaDetailView(vm: .init(for: sourcesSvc.getSource(sourceId: manga.source)!, mangaId: manga.id!))
        }
        .id(collection.id)
        .navigationBarTitle("\(collection.name!) (\(mangas.getFiltered(filter: collection.filter).count))", displayMode: .inline)
    }
}

private class VM: ObservableObject {
    @Published var selectedManga: Manga?
    
    func selectManga(for manga: Manga) {
        selectedManga = manga
    }
}
