//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation

enum LibraryFilter: CaseIterable {
    case all
    case read
    case unread
    
    func isNotAll() -> Bool {
        return !(self == .all)
    }
}

@MainActor
class LibraryVM: ObservableObject {
    @Published var libState: LibraryState
    
    @Published var libFilter: LibraryFilter = .unread
    @Published var searchText: String = ""
    
    init(libState: LibraryState) {
        self.libState = libState
    }
    
    func getMangas(collection: MangaCollection) -> [Manga] {
        guard collection.mangas?.count != 0 else { return [] }
        
        guard let mangas = collection.mangas as? Set<Manga> else { return [] }
        
        switch libFilter {
            case .all:
                return mangas.sorted { $0.title! < $1.title! }
            case .read:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }

                        return chapters.allSatisfy { rawChapter in
                            guard let chapter = rawChapter as? MangaChapter else { return false }
                            return !chapter.status.isUnread()
                        }
                    }
                    .sorted { $0.title! < $1.title! }
            case .unread:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        return chapters.contains { rawChapter in
                            guard let chapter = rawChapter as? MangaChapter else { return false }
                            return chapter.status.isUnread()
                        }
                    }
                    .sorted { $0.title! < $1.title! }
                    
        }
    }
    
    func changeFilter(newFilterState: LibraryFilter) {
        self.libFilter = newFilterState
    }
}
