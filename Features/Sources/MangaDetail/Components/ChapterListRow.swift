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
    @Environment(ReaderManager.self) var readerManager

    @Bindable var vm: ChapterListVM

    var chapter: Chapter
    var chapters: [Chapter]
    
    public init(vm: ChapterListVM, chapter: Chapter, chapters: [Chapter]) {
        self.chapter = chapter
        self.chapters = chapters
        self._vm = .init(wrappedValue: vm)
    }
    
    public var body: some View {
        HStack {
            if let url = chapter.externalUrl {
                Link(destination: url) {
                    Content()
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            } else {
                Button(action: {
                    readerManager.selectChapter(chapter: chapter, manga: vm.manga, scraper: vm.scraper, chapters: chapters)
                }) {
                    Content()
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            }
        }
        .foregroundColor(chapter.readAt != nil ? Color.gray : Color.blue)
        .contextMenu { ChapterRowContextMenu() }
    }
    
    @ViewBuilder
    func Content() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chapter.title ?? "")
                Text(chapter.uploadedAt?.formatted() ?? "")
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
        if (chapter.readAt != nil) {
            Button(action: { vm.changeChapterStatus(for: chapter) }) {
                Text("Mark as read")
            }
        }
        else {
            Button(action: { vm.changeChapterStatus(for: chapter) }) {
                Text("Mark as unread")
            }
        }

        if vm.hasPreviousUnreadChapter(for: chapter, chapters: chapters) {
            Button(action: { vm.changePreviousChapterStatus(for: chapter, in: chapters) }) {
                Text("Mark previous as read")
            }
        }
        else {
            Button(action: { vm.changePreviousChapterStatus(for: chapter, in: chapters) }) {
                Text("Mark previous as unread")
            }
        }
    }
}
