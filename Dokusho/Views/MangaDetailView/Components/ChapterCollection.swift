//
//  ChapterCollection.swift
//  ChapterCollection
//
//  Created by Stephan Deumier on 20/07/2021.
//

import SwiftUI
import CoreData

struct ChapterCollection: View {
    @FetchRequest var chapters: FetchedResults<ChapterEntity>
    
    @Binding var selectedChapter: ChapterEntity?
    @StateObject var vm: ChapterListVM
    
    init(manga: NSManagedObjectID, selectedChaper: Binding<ChapterEntity?>, ascendingOrder: Bool, filter: ChapterStatusFilter) {
        self._selectedChapter = selectedChaper
        self._vm = .init(wrappedValue: .init(mangaOId: manga))
        self._chapters = .init(sortDescriptors: [ChapterEntity.positionOrder(order: ascendingOrder ? .forward : .reverse)], predicate: ChapterEntity.chaptersListForMangaPredicate(manga: manga, filter: filter))
    }
    
    var body: some View {
        if let chapter = vm.nextUnreadChapter(chapters: chapters) {
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
}

