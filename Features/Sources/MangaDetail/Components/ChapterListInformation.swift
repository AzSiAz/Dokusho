//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import GRDBQuery
import DataKit
import Reader

public struct ChapterListInformation: View {
    @Environment(ReaderManager.self) var readerManager
    
//    @GRDBQuery.Query<MangaChaptersRequest> var chapters: [MangaChapterDB]
    
    var serie: Serie
    var scraper: Scraper
    
    public init(serie: Serie, scraper: Scraper) {
        self.serie = serie
        self.scraper = scraper
//        _chapters = Query(MangaChaptersRequest(manga: manga))
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
            
            ChapterCollections()
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    func ChapterCollections() -> some View {
        Group {
//            if let chapter = vm.nextUnreadChapter(chapters: chapters) {
//                Group {
//                    if let url = chapter.externalUrl {
//                        Link(destination: url) {
//                            NextUnreadChapter()
//                        }
//                    } else {
//                        Button(action: { readerManager.selectChapter(chapter: chapter, manga: vm.manga, scraper: vm.scraper, chapters: chapters) }) {
//                            NextUnreadChapter()
//                        }
//                    }
//                }
//                .buttonStyle(.bordered)
//                .controlSize(.large)
//                .padding(.horizontal)
//            }

//            ForEach(chapters) { chapter in
//                ChapterListRow(vm: vm, chapter: chapter, chapters: chapters)
//            }
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
