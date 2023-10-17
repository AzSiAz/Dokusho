//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import DataKit
import Reader

public struct ChapterListInformation: View {
    @Environment(ReaderManager.self) var readerManager
    
    @Query var chapters: [SerieChapter]
    
    @Bindable var serie: Serie
    @Bindable var scraper: Scraper
    
    public init(serie: Serie, scraper: Scraper) {
        self.serie = serie
        self.scraper = scraper
        self._chapters = .init(.chaptersForSerie(serieId: serie.internalId!, scraperId: scraper.id))
    }

    public var body: some View {
        LazyVStack {
            HStack {
                Text("Chapter List")
                    .font(.title3)
                
                Spacer()
                
                HStack {
//                    ChaptersButton(filter: $chapters.filterAll, order: $chapters.ascendingOrder)
                }
            }
            .frame(height: 24)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            
            chapterCollections
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    var chapterCollections: some View {
        Group {
            if let chapter = nextUnreadChapter(chapters: chapters) {
                Group {
                    if let url = chapter.externalUrl {
                        Link(destination: url) {
                            NextUnreadChapter()
                        }
                    } else {
                        Button(action: { readerManager.selectChapter(chapter: chapter, serie: serie, scraper: scraper, chapters: chapters) }) {
                            NextUnreadChapter()
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            ForEach(chapters) { chapter in
                ChapterListRow(serie: serie, scraper: scraper, chapter: chapter)
            }
        }
    }
    
    @ViewBuilder
    func NextUnreadChapter() -> some View {
        Text("Read next unread chapter")
            .frame(minWidth: 0, maxWidth: .infinity)
    }
    
    @ViewBuilder
    func ChaptersButton(filter: Binding<Bool>, order: Binding<Bool>) -> some View {
        Button(action: { filter.wrappedValue.toggle() }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .resizable()
                .scaledToFit()
                .symbolVariant(filter.wrappedValue == true ? .none : .fill)
        }
        .padding(.trailing, 5)
        
        Button(action: { order.wrappedValue.toggle() }) {
            Image(systemName: "chevron.up.chevron.down")
                .resizable()
                .scaledToFit()
        }
    }
}

private extension ChapterListInformation {
    func nextUnreadChapter(chapters: [SerieChapter]) -> SerieChapter? {
        return chapters
            .lazy
            .sorted { $0.volume ?? 0 < $1.volume ?? 0 }
            .sorted { $0.chapter ?? 0 < $1.chapter ?? 0 }
            .first { $0.readAt == nil }
    }
}
