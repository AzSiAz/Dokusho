//
//  MangaCollectionPage.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import SwiftUI

struct MangaCollectionPage: View {
    var srcSVC = MangaSourceService.shared

    @State var collection: MangaCollection
    
    var vm: LibraryVM
    var fetchRequest: FetchRequest<Manga>
    var mangas: FetchedResults<Manga> { fetchRequest.wrappedValue }
    
    var columns: [GridItem] {
        var base = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base = [GridItem(.adaptive(minimum: 180, maximum: 180))]
        }
        
        return base
    }
    
    init(vm: LibraryVM, collection: MangaCollection) {
        self._collection = .init(wrappedValue: collection)
        
        self.vm = vm
        self.fetchRequest = FetchRequest<Manga>(fetchRequest: Manga.fetchMany(collection: collection))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(mangas.getFiltered(filter: collection.filter)) { manga in
                    NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: srcSVC.getSource(sourceId: manga.source)!, mangaId: manga.id!))) {
                        UnreadChapterObs(manga: manga) { count in
                            ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                                .frame(height: 180)
                                .overlay(alignment: .topTrailing) {
                                    MangaUnreadCount(count: count)
                                }
                                .contextMenu {
                                    MangaLibraryContextMenu(manga: manga, vm: vm, count: count)
                                }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("\(collection.name!) (\(mangas.getFiltered(filter: collection.filter).count))", displayMode: .inline)
    }
}
