//
//  ChapterListRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ChapterListRow: View {
    @EnvironmentObject var readerManager: ReaderManager
    @ObservedObject var vm: ChapterListVM

    var chapter: MangaChapter
    
    var body: some View {
        HStack {
            if let url = chapter.externalUrl {
                Link(destination: URL(string: url)!) {
                    content
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            } else {
                Button(action: { readerManager.selectChapter(chapter: chapter, manga: vm.manga, scraper: vm.scraper) }) {
                    content
                }
                .buttonStyle(.plain)
                .padding(.vertical, 5)
            }
        }
        .foregroundColor(chapter.status == .read ? Color.gray : Color.blue)
        .fullScreenCover(item: $readerManager.selectedChapter) { data in
            ReaderView(vm: .init(manga: data.manga, chapter: data.chapter, scraper: data.scraper), readerManager: readerManager)
        }
    }
    
    @ViewBuilder
    var content: some View {
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
}
