//
//  File.swift
//  
//
//  Created by Stephan Deumier on 07/10/2023.
//

import Foundation
import DataKit
import SwiftUI

struct SourceListScreen: View {
    @Harmony var harmony

    @Environment(ScraperService.self) var scraperService
    
    @Query(ScrapersRequest(filter: .all)) var scrapers: [Scraper]

    var body: some View {
        Group {
            if scrapers.isEmpty {
                ContentUnavailableView("No scrapers", systemImage: "globe", description: Text("No scraper available in app"))
            } else {
                List {
                    Section("Active") {
                        ForEach(scrapers.filter({ $0.isActive })) { scraper in
                            Row(scraper: scraper)
                        }
                    }
                    
                    Section("Not active") {
                        ForEach(scrapers.filter({ !$0.isActive })) { scraper in
                            Row(scraper: scraper)
                        }
                    }
                }
            }
        }
        .navigationTitle("Available Scrapers")
        .task { await scraperService.upsertAllSource(in: harmony) }
    }
    
    @ViewBuilder
    func Row(scraper: Scraper) -> some View {
        SourceRow(scraper: scraper)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: { toggleIsActive(scraper) }) {
                    Label(scraper.isActive ? "Deactivate" : "Activate", systemImage: scraper.isActive ? "eye.slash" : "eye")
                }
                .tint(scraper.isActive ? .red : .blue)
            }
    }
    
    func toggleIsActive(_ scraper: Scraper) {
        var sc = scraper
        sc.toggleIsActive()
        
        Task { [sc] in
            try? await harmony.save(record: sc)
        }
    }
}
