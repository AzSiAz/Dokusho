//
//  ExploreDetailViewModels.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 06/06/2021.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class ExploreSourceVM: ObservableObject {
    let src: Source
    var nextPage = 1

    @Published var mangas = [SourceSmallManga]()
    @Published var error = false
    @Published var type: SourceFetchType = .latest
    
    init(for source: Source) {
        self.src = source
    }
    
    func fetchList(clean: Bool = false) async {
        if clean {
            mangas = []
            nextPage = 1
        }
        
        self.error = false
        
        do {
            let newManga = try await type == .latest ? src.fetchLatestUpdates(page: nextPage) : src.fetchPopularManga(page: nextPage)

            self.mangas.append(contentsOf: newManga.mangas)
            self.nextPage += 1
        } catch {
            self.error = true
        }
    }
    
    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        if mangas.last == manga {
            return await fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(src.name) - \(type.rawValue)"
    }
    
    func buildMangaDetailVM(ctx: NSManagedObjectContext, manga: SourceSmallManga) -> MangaDetailVM {
        return MangaDetailVM(for: src, mangaId: manga.id, context: ctx)
    }
}
