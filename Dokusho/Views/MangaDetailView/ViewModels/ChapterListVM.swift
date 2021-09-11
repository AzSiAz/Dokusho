//
//  ChapterListVM.swift
//  Dokusho
//
//  Created by Stephan Deumier on 04/07/2021.
//

import Foundation
import CoreData
import SwiftUI

class ChapterListVM: ObservableObject {
    private var ctx = PersistenceController.shared.container.viewContext
    
    var manga: MangaEntity
    
    @Published var error: Error?

    init(mangaOId: NSManagedObjectID) {
        self.manga = ctx.object(with: mangaOId) as! MangaEntity
    }

    func changeChapterStatus(for chapter: ChapterEntity, status: ChapterStatus) {
        try? ctx.performAndWait {
            chapter.markAs(newStatus: status)
            manga.lastUserAction = .now

            try ctx.save()
        }
    }

    func changePreviousChapterStatus(for chapter: ChapterEntity, status: ChapterStatus, in: FetchedResults<ChapterEntity>) {
        guard let source = manga.source else { return }
        
        try? ctx.performAndWait {
            let chapters = ChapterEntity.chaptersForManga(ctx: ctx, manga: manga.objectID, source: source.objectID)
            
            chapters
                .filter { status == .unread ? !$0.isUnread : $0.isUnread }
                .filter { chapter.position < $0.position }
                .forEach { $0.markAs(newStatus: status) }
            
            manga.lastUserAction = .now

            try ctx.save()
        }
    }

    func hasPreviousUnreadChapter(for chapter: ChapterEntity, chapters: FetchedResults<ChapterEntity>) -> Bool {
        guard let source = manga.source else { return false }
        
        return ChapterEntity.chaptersForManga(ctx: ctx, manga: manga.objectID, source: source.objectID)
            .filter { chapter.position < $0.position }
            .contains { $0.isUnread }
    }

    func nextUnreadChapter(chapters: FetchedResults<ChapterEntity>) -> ChapterEntity? {       
        return chapters
            .sorted(using: SortDescriptor(\ChapterEntity.position, order: .reverse))
            .first { $0.isUnread }
    }
}
