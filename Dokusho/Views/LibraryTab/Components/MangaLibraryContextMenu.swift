//
//  MangaLibraryContextMenu.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import SwiftUI

struct MangaLibraryContextMenu: View {
    @ObservedObject var manga: MangaEntity

    var count: Int

    var body: some View {
        if count != 0 {
            Button(action: { markAllChapterAs(newSatus: .read) }) {
                Text("Mark as read")
            }
        }
        
        if count == 0 {
            Button(action: { markAllChapterAs(newSatus: .unread) }) {
                Text("Mark as unread")
            }
        }
    }
    
    func markAllChapterAs(newSatus: ChapterStatus) {
        manga.managedObjectContext?.perform {
            manga
                .chapters?.filter { $0.isUnread }
                .forEach { $0.markAs(newStatus: newSatus) }
            
            manga.lastUserAction = .now
            
            try? manga.managedObjectContext?.save()
        }
    }
}
