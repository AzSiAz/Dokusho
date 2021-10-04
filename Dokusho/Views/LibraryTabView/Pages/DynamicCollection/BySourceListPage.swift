//
//  BySourceListPage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper

struct BySourceListPage: View {
    @SectionedFetchRequest<UUID, MangaEntity>(sectionIdentifier: \.sourceId, sortDescriptors: [MangaEntity.nameOrder], predicate: nil) var sources
    
    var body: some View {
        List {
            ForEach(sources) { source in
                NavigationLink(destination: MangaForSourcePage(sourceId: source.id)) {
                    let name = MangaScraperService.shared.getSource(sourceId: source.id)?.name
                    Text("\(name ?? "No name") (\(source.count))")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("By Sources")
    }
}
