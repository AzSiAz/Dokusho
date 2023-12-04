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
                            SourceRow(scraper: scraper)
                        }
                    }
                    
                    Section("Not active") {
                        ForEach(scrapers.filter({ !$0.isActive })) { scraper in
                            SourceRow(scraper: scraper)
                        }
                    }
                }
            }
        }
        .navigationTitle("Available Scrapers")
        .task { await scraperService.upsertAllSource(in: harmony) }
    }
}
