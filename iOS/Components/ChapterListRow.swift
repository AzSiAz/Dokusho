//
//  ChapterListRow.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ChapterListRow: View {
    @StateObject var vm: ChapterListVM
    @Binding var selectedChapter: MangaChapter?
    
    var chapter: MangaChapter
    var id: String { "\(chapter.id!)\(chapter.status.rawValue)" }
    
    
    var body: some View {
        HStack {
            Button(action: { selectedChapter = chapter }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(chapter.title ?? "No Title")
                        Text(chapter.dateSourceUpload?.formatted() ?? "Unknown")
                            .font(.system(size: 12))
                        if let readAt = chapter.readAt {
                            Text("Read At: \(readAt.formatted())")
                                .font(.system(size: 10))
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { print("download")}) {
                    Image(systemName: "icloud.and.arrow.down")
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 5)
        }
        .foregroundColor(chapter.status == .read ? Color.gray : Color.blue)
        .contextMenu {
            if chapter.status == .unread {
                Button(action: { vm.changeChapterStatus(for: chapter, status: .read) }) {
                    Text("Mark as read")
                }
            }
            else {
                Button(action: { vm.changeChapterStatus(for: chapter, status: .unread) }) {
                    Text("Mark as unread")
                }
            }
            
            if (vm.hasPreviousUnreadChapter(for: chapter)) {
                Button(action: { vm.changePreviousChapterStatus(for: chapter, status: .read) }) {
                    Text("Mark previous as read")
                }
            }
            else {
                Button(action: { vm.changePreviousChapterStatus(for: chapter, status: .unread) }) {
                    Text("Mark previous as unread")
                }
            }
        }
    }
}
