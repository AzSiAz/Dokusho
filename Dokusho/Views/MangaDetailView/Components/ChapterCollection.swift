//
//  ChapterCollection.swift
//  ChapterCollection
//
//  Created by Stephan Deumier on 20/07/2021.
//

import SwiftUI

struct ChapterCollection: View {
    @FetchRequest(sortDescriptors: [ChapterEntity.positionOrder()], predicate: nil, animation: .default)
    var chapters: FetchedResults<ChapterEntity>
    
    @Binding var selectedChapter: ChapterEntity?
    @StateObject var vm: ChapterListVM
    
    var body: some View {
        if let chapter = vm.nextUnreadChapter() {
            Button(action: { selectedChapter = chapter }) {
                Text("Read next unread chapter")
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal)
        }

        ForEach(chapters) { chapter in
            ChapterListRow(vm: vm, chapter: chapter, selectedChapter: $selectedChapter)
                .contextMenu {
                    if chapter.isUnread {
                        Button(action: { vm.changeChapterStatus(for: chapter.objectID, status: .read) }) {
                            Text("Mark as read")
                        }
                    }
                    else {
                        Button(action: { vm.changeChapterStatus(for: chapter.objectID, status: .unread) }) {
                            Text("Mark as unread")
                        }
                    }

                    if vm.hasPreviousUnreadChapter(for: chapter) {
                        Button(action: { vm.changePreviousChapterStatus(for: chapter.objectID, status: .read) }) {
                            Text("Mark previous as read")
                        }
                    }
                    else {
                        Button(action: { vm.changePreviousChapterStatus(for: chapter.objectID, status: .unread) }) {
                            Text("Mark previous as unread")
                        }
                    }
                }
        }
    }
}

