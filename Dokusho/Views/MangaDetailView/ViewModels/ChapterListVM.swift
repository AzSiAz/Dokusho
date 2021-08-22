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
    private var ctx = PersistenceController.shared.backgroundCtx()
    
    var manga: MangaEntity
    
    @Published var error: Error?

    init(manga: MangaEntity) {
        self.manga = manga
    }

    func changeChapterStatus(for chapterId: NSManagedObjectID, status: ChapterStatus) {
        try? ctx.performAndWait {
            guard let chapter = ctx.object(with: chapterId) as? ChapterEntity else { return }
            chapter.markAs(newStatus: status)
            try ctx.save()
        }
    }

    func changePreviousChapterStatus(for chapterId: NSManagedObjectID, status: ChapterStatus) {
        guard let source = manga.source else { return }
        
        try? ctx.performAndWait {
            guard let chapter = ctx.object(with: chapterId) as? ChapterEntity else { return }
            let chapters = ChapterEntity.chaptersForManga(ctx: ctx, manga: manga, source: source)
            
            chapters
                .filter { status == .unread ? !$0.isUnread : $0.isUnread }
                .filter { chapter.position < $0.position }
                .forEach { $0.markAs(newStatus: status) }
            
            try ctx.save()
        }
    }

    func hasPreviousUnreadChapter(for chapter: ChapterEntity) -> Bool {
        guard let source = manga.source else { return false }

        return ChapterEntity.chaptersForManga(ctx: ctx, manga: manga, source: source)
            .filter { chapter.position < $0.position }
            .contains { $0.isUnread }
    }

    func nextUnreadChapter() -> ChapterEntity? {
        guard let source = manga.source else { return nil }
        
        return ChapterEntity.chaptersForManga(ctx: ctx, manga: manga, source: source)
            .sorted(using: SortDescriptor(\ChapterEntity.position, order: .reverse))
            .first { $0.isUnread }
    }
}
