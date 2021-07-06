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
        .navigationBarTitle("\(collection.name!) \(mangas.getFiltered(filter: collection.filter).count))", displayMode: .inline)
    }
}

extension FetchedResults where Element == Manga {
    func getFiltered(filter: MangaCollection.Filter) -> [Element] {
        let sort = SortDescriptor(\Manga.lastChapterUpdate, order: .reverse)
        
        switch filter {
            case .all:
                return self.sorted(using: sort)
            case .read:
                return self
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        
                        return chapters.allSatisfy { !($0.status == .unread) }
                    }
                    .sorted(using: sort)
            case .unread:
                return self
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        return chapters.contains { $0.status == .unread }
                    }
                    .sorted(using: sort)
        }
    }
}
