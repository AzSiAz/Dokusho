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
    @Environment(\.modelContext) var ctx
    @Environment(ScraperService.self) var scraperService
    
    @Query var scrapers: [Scraper]

    var body: some View {
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
        .navigationTitle("Available Sources")
        .task(id: scrapers) { scraperService.upsertAllSource() }
    }
}
