//
//  File.swift
//  Dokusho
//
//  Created by Stephan Deumier on 15/04/2022.
//

import Foundation
import MangaScraper

class ExploreTabVM: ObservableObject {
    var database = AppDatabase.shared.database
    
    @Published var searchText: String = ""
    
    func onlyGetThirdPartyScraper(favorite: [Scraper], active: [Scraper]) -> [Source] {
        return MangaScraperService.shared.list
            .filter { src in return !active.contains(where: { scraper in src.id == scraper.id }) }
            .filter { src in return !favorite.contains(where: { scraper in src.id == scraper.id }) }
    }
    
    func toogleActive(source: Source) {
        do {
            try database.write { db in
                let scraper = try Scraper.fetchOne(db, id: source.id)
                if var scraper = scraper {
                    scraper.isActive.toggle()
                    scraper.position = 99999
                    try scraper.save(db)
                } else {
                    var scraper = Scraper(from: source)
                    scraper.isActive = true
                    scraper.position = 99999
                    try scraper.save(db)
                }
            }
        } catch(let err) {
            print(err)
        }
    }

    func toogleFavorite(source: Source) {
        do {
            try database.write { db in
                let scraper = try Scraper.fetchOne(db, id: source.id)
                if var scraper = scraper {
                    scraper.isFavorite.toggle()
                    scraper.position = 99999
                    try scraper.save(db)
                } else {
                    var scraper = Scraper(from: source)
                    scraper.isFavorite = true
                    scraper.position = 99999
                    try scraper.save(db)
                }
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func onMove(scrapers: [Scraper], offsets: IndexSet, position: Int) {
        do {
            var sc = scrapers

            try database.write { db in
                // change the order of the items in the array
                sc.move(fromOffsets: offsets, toOffset: position)

                try sc
                    .enumerated()
                    .forEach { d in
                        var scraper = d.element
                        scraper.position = d.offset;

                        try scraper.save(db)
                    }
            }
        } catch(let err) {
            print(err)
        }
    }
}
