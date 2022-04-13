//
//  ChapterCollection.swift
//  ChapterCollection
//
//  Created by Stephan Deumier on 20/07/2021.
//

import SwiftUI
import GRDBQuery

struct ChapterCollection: View {
    @Query<MangaChaptersRequest> var chapters: [MangaChapter]
    @StateObject var vm: ChapterListVM
    
    init(manga: Manga, scraper: Scraper, ascendingOrder: Bool, filter: ChapterStatusFilter) {
        _vm = .init(wrappedValue: .init(manga: manga, scraper: scraper))
        _chapters = Query(MangaChaptersRequest(manga: manga, order: ascendingOrder ? .ASC : .DESC, filter: filter))
    }
    
    var body: some View {
        Group {
            if let chapter = vm.nextUnreadChapter(chapters: chapters) {
                Group {
                    if let url = chapter.externalUrl {
                        Link(destination: URL(string: url)!) {
                            self.nextButtonContent
                        }
                    } else {
                        Button(action: { vm.selectedChapter = chapter }) {
                            self.nextButtonContent
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.horizontal)
            }

            ForEach(chapters) { chapter in
                ChapterListRow(vm: vm, selectedChapter: $vm.selectedChapter, chapter: chapter)
                    .contextMenu {
                        if chapter.isUnread {
                            Button(action: { vm.changeChapterStatus(for: chapter, status: .read) }) {
                                Text("Mark as read")
                            }
                        }
                        else {
                            Button(action: { vm.changeChapterStatus(for: chapter, status: .unread) }) {
                                Text("Mark as unread")
                            }
                        }

                        if vm.hasPreviousUnreadChapter(for: chapter, chapters: chapters) {
                            Button(action: { vm.changePreviousChapterStatus(for: chapter, status: .read, in: chapters) }) {
                                Text("Mark previous as read")
                            }
                        }
                        else {
                            Button(action: { vm.changePreviousChapterStatus(for: chapter, status: .unread, in: chapters) }) {
                                Text("Mark previous as unread")
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $vm.selectedChapter) { chapter in
            ReaderView(vm: .init(manga: vm.manga, chapter: chapter, scraper: vm.scraper, chapters: chapters))
        }
    }
    
    @ViewBuilder
    var nextButtonContent: some View {
        Text("Read next unread chapter")
            .frame(minWidth: 0, maxWidth: .infinity)
    }
}

