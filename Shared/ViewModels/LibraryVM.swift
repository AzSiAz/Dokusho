//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation

//@MainActor
class LibraryVM: ObservableObject {
    @Published var libState: LibraryState

    @Published var searchText: String = ""
    
    init(libState: LibraryState) {
        self.libState = libState
    }
    
    func getMangas(collection: MangaCollection) -> [Manga] {
        guard collection.mangas?.count != 0 else { return [] }
        guard let mangas = collection.mangas as? Set<Manga> else { return [] }
        
        let sort = SortDescriptor(\Manga.lastChapterUpdate, order: .reverse)
        
        switch collection.filter {
            case .all:
                return mangas.sorted(using: sort)
            case .read:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }

                        return chapters.allSatisfy { rawChapter in
                            guard let chapter = rawChapter as? MangaChapter else { return false }
                            return !chapter.status.isUnread()
                        }
                    }
                    .sorted(using: sort)
            case .unread:
                return mangas
                    .filter { manga in
                        guard let chapters = manga.chapters else { return false }
                        return chapters.contains { rawChapter in
                            guard let chapter = rawChapter as? MangaChapter else { return false }
                            return chapter.status.isUnread()
                        }
                    }
                    .sorted(using: sort)
        }
    }
    
    func changeFilter(collection: MangaCollection, newFilterState: MangaCollection.Filter) {
        collection.filter = newFilterState
        
        libState.saveLibraryState()
    }
}
