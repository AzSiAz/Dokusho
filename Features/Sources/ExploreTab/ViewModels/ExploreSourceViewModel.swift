//
//  ExploreDetailViewModels.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 06/06/2021.
//

import Foundation
import SwiftUI
import MangaScraper
import DataKit
import Collections
import Common

@MainActor
@Observable
class ExploreSourceViewModel {
    private let database = AppDatabase.shared.database
    private var nextPage = 1
    private var isLoading = false
    private var initialized = false
    
    var mangas = OrderedSet<SourceSmallManga>()
    var error = false
    var type: SourceFetchType = .latest
    var selectedManga: SourceSmallManga?
    var fromSegment: Bool = false

    let scraper: Scraper
    
    init(for scraper: Scraper) {
        self.scraper = scraper
    }

    func fetchList(clean: Bool = false, typeChange: Bool = false) async {
        guard isLoading == false else { return }
        
        defer {
            self.fromSegment = false
            self.isLoading = false
        }
        
        if clean {
            nextPage = 1
            if typeChange {
                self.fromSegment = true
                self.error = false
            }
        } else {
            self.isLoading = true
            self.error = false
        }
        
        do {
            let newManga = try await type == .latest ? scraper.asSource()?.fetchLatestUpdates(page: nextPage) : scraper.asSource()?.fetchPopularManga(page: nextPage)
            
            withAnimation {
                if clean { self.mangas = OrderedSet(newManga!.mangas) }
                else { self.mangas.append(contentsOf: newManga!.mangas) }

                self.nextPage += 1
            }
        } catch {
            withAnimation {
                self.error = true
            }
        }
    }

    func initView() async {
        if !initialized && mangas.isEmpty {
            await fetchList()
            
            withAnimation {
                self.initialized = true
            }
        }
    }

    func fetchMoreIfPossible(for manga: SourceSmallManga) async {
        if mangas.last == manga {
            return await fetchList()
        }
    }
    
    func getTitle() -> String {
        return "\(scraper.name) - \(type.rawValue)"
    }
    
    func addToCollection(smallManga: SourceSmallManga, collection: MangaCollection) async {
        guard let sourceManga = try? await scraper.asSource()?.fetchMangaDetail(id: smallManga.id) else { return }

        do {
            try await database.write { db -> Void in
                guard var manga = try Manga.all().forMangaId(smallManga.id, self.scraper.id).fetchOne(db) else {
                    var manga = try Manga.updateFromSource(db: db, scraper: self.scraper, data: sourceManga)
                    try manga.updateChanges(db) {
                        $0.mangaCollectionId = collection.id
                    }
                    return
                }

                try manga.updateChanges(db) {
                    $0.mangaCollectionId = collection.id
                }
            }
        } catch(let err) {
            print(err)
        }
    }
}
