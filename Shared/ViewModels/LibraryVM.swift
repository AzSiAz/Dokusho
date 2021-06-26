//
//  LibraryVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 22/06/2021.
//

import Foundation

@MainActor
class LibraryVM: ObservableObject {
    @Published var libState: LibraryState
    
    init(libState: LibraryState) {
        self.libState = libState
    }
    
    func getMangas(collection: MangaCollection) -> [Manga] {
        guard collection.mangas?.count != 0 else { return [] }
        
        guard let mangas = collection.mangas as? Set<Manga> else { return [] }
        
        return mangas.sorted { $0.title! < $1.title! }
    }
}
