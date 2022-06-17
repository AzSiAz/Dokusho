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

class ExploreSourceVM: ObservableObject {
    private let database = AppDatabase.shared.database
    private var nextPage = 1
    private var inited = false
    private var isLoading = false
    
    @Published var mangas = OrderedSet<SourceSmallManga>()
    @Published var error = false
    @Published var type: SourceFetchType = .latest
    @Published var selectedManga: SourceSmallManga?
    @Published var fromRefresher: Bool = false
    @Published var fromSegment: Bool = false
    
    let scraper: Scraper
    
    init(for scraper: Scraper) {
        self.scraper = scraper
    }
    

    func fetchList(clean: Bool = false) async {
        guard isLoading == false else { return }
        self.isLoading = true

        if clean {
            nextPage = 1
        }
        
        await asyncChange {
            self.error = false
        }
        
        do {
            let newManga = try await type == .latest ? scraper.asSource()?.fetchLatestUpdates(page: nextPage) : scraper.asSource()?.fetchPopularManga(page: nextPage)
            
            await asyncChange {
                if clean { self.mangas = OrderedSet(newManga!.mangas) }
                else { self.mangas.append(contentsOf: newManga!.mangas) }

                self.nextPage += 1
                self.isLoading = false
            }
        } catch {
            await animateAsyncChange {
                self.error = true
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
    
    func refresh() async {
        await animateAsyncChange {
            self.fromRefresher = true
        }

        await fetchList(clean: true)
            
        await asyncChange {
            self.fromRefresher = false
        }
    }
    
    func segmentChange(type: SourceFetchType? = nil) {
        withAnimation {
            fromSegment = true
        }

        Task {
            await fetchList(clean: true)
            
            await asyncChange {
                self.fromSegment = false
            }
        }
    }
    
    func initView() async {
        if !inited && mangas.isEmpty {
            await fetchList()
            
            await asyncChange {
                self.inited = true
            }
        }
    }
}
