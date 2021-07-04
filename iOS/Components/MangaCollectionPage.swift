//
//  MangaCollectionPage.swift
//  Dokusho
//
//  Created by Stephan Deumier on 02/07/2021.
//

import SwiftUI

struct MangaCollectionPage: View {
    var srcSVC = MangaSourceService.shared

    var vm: LibraryVM
    var collection: Binding<MangaCollection>
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
    
    init(vm: LibraryVM, collection: Binding<MangaCollection>) {
        self.vm = vm
        self.collection = collection
        
        self.fetchRequest = FetchRequest<Manga>(fetchRequest: Manga.fetchMany(collection: collection.wrappedValue))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.getMangas(mangas: Array(mangas), collection: collection.wrappedValue)) { manga in
                    NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: srcSVC.getSource(sourceId: manga.source)!, mangaId: manga.id!))) {
                        ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                            .frame(height: 180)
                            .overlay(alignment: .topTrailing) {
                                MangaUnreadCount(manga: manga)
                            }
                            .contextMenu {
                                MangaLibraryContextMenu(manga: manga, vm: vm)
                            }
                    }
                }
            }
        }
        .navigationBarTitle("\(collection.wrappedValue.name!) (\(vm.getMangas(mangas: Array(mangas), collection: collection.wrappedValue).count))", displayMode: .inline)
    }
}
