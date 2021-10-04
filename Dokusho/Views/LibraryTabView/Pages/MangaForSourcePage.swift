//
//  MangaForSourcePage.swift
//  Dokusho
//
//  Created by Stef on 04/10/2021.
//

import SwiftUI
import MangaScraper

struct MangaForSourcePage: View {
    @FetchRequest var mangas: FetchedResults<MangaEntity>
    @State var selectedManga: MangaEntity?
    
    var columns: [GridItem] = [GridItem(.adaptive(minimum: 120, maximum: 120))]
    var sourceName: String
    
    init(sourceId: UUID) {
        self.sourceName = MangaScraperService.shared.getSource(sourceId: sourceId)!.name
        
        self._mangas = .init(sortDescriptors: [MangaEntity.nameOrder], predicate: MangaEntity.sourcePredicate(sourceId: sourceId), animation: .easeIn)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(mangas) { manga in
                    MangaCardView(manga: manga)
                        .onTapGesture { selectedManga = manga }
                }
            }
            .navigationTitle("\(sourceName) (\(mangas.count))")
            .navigationBarTitleDisplayMode(.automatic)
            .sheetSizeAware(item: $selectedManga, content: { manga in
                MangaDetailView(mangaId: manga.mangaId!, src: manga.sourceId, isInCollectionPage: true)
            })
        }
    }
}
