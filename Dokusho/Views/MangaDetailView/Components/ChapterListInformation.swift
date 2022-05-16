//
//  ChapterList.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI
import GRDBQuery
import DataKit
import OldReader

struct ChapterListInformation: View {
    @EnvironmentObject var readerManager: ReaderManager
    
    @Query<MangaChaptersRequest> var chapters: [MangaChapter]
    @StateObject var vm: ChapterListVM
    
    var manga: Manga
    var scraper: Scraper
    
    init(manga: Manga, scraper: Scraper) {
        self.manga = manga
        self.scraper = scraper
        _vm = .init(wrappedValue: .init(manga: manga, scraper: scraper))
        _chapters = Query(MangaChaptersRequest(manga: manga))
    }

    var body: some View {
        LazyVStack {
            HStack {
                Text("Chapter List")
                    .font(.title3)
                
                Spacer()
                
                HStack {
                    ChaptersButton(filter: $chapters.filterAll, order: $chapters.ascendingOrder)
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
            if let chapter = vm.nextUnreadChapter(chapters: chapters) {
                Group {
                    if let url = chapter.externalUrl {
                        Link(destination: URL(string: url)!) {
                            NextButtonContent()
                        }
                    } else {
                        Button(action: { readerManager.selectChapter(chapter: chapter, manga: vm.manga, scraper: vm.scraper, chapters: chapters) }) {
                            NextButtonContent()
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            ForEach(chapters) { chapter in
                ChapterListRow(vm: vm, chapter: chapter, chapters: chapters)
            }
        }
    }
    
    @ViewBuilder
    func NextButtonContent() -> some View {
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
