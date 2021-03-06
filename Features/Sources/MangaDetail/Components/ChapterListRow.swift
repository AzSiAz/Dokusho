//
//  ChapterListRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI
import DataKit
import Reader


public struct ChapterListRow: View {
    @EnvironmentObject var readerManager: ReaderManager
    @ObservedObject var vm: ChapterListVM

    var chapter: MangaChapter
    var chapters: [MangaChapter]
    
    public init(vm: ChapterListVM, chapter: MangaChapter, chapters: [MangaChapter]) {
        self.chapter = chapter
        self.chapters = chapters
        self._vm = .init(wrappedValue: vm)
    }
    
    public var body: some View {
        HStack {
            if let url = chapter.externalUrl {
                Link(destination: URL(string: url)!) {
                    Content()
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            } else {
                Button(action: { readerManager.selectChapter(chapter: chapter, manga: vm.manga, scraper: vm.scraper, chapters: chapters) }) {
                    Content()
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            }
        }
        .foregroundColor(chapter.status == .read ? Color.gray : Color.blue)
        .contextMenu { ChapterRowContextMenu() }
    }
    
    @ViewBuilder
    func Content() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chapter.title)
                Text(chapter.dateSourceUpload.formatted())
                    .font(.system(size: 12))
                if let readAt = chapter.readAt {
                    Text("Read At: \(readAt.formatted())")
                        .font(.system(size: 10))
                }
            }
        }
        
        Spacer()
        
        if chapter.externalUrl != nil {
            Image(systemName: "arrow.up.forward.app")
        } else {
            Button(action: { print("download")}) {
                Image(systemName: "icloud.and.arrow.down")
            }
        }
    }
    
    @ViewBuilder
    func ChapterRowContextMenu() -> some View {
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
