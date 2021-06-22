//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation
import CoreData

class ReaderVM: ObservableObject {
    var src: Source
    var ctx: NSManagedObjectContext
    
    @Published var chapter: MangaChapter
    @Published var tabIndex = 0
    @Published var showToolBar = true
    @Published var chapterImages: [SourceChapterImage]?
    @Published var error = false

    init(for chapter: MangaChapter, with source: Source, context ctx: NSManagedObjectContext) {
        self.src = source
        self.chapter = chapter
        self.ctx = ctx
    }
    
    func fetchChapter() async {
        do {
            chapterImages = try await src.fetchChapterImages(mangaId: chapter.manga!.sourceId!, chapterId: chapter.sourceId!)
            tabIndex = 0
        } catch {
            self.error = true
        }
    }
    
    func saveProgress(_ status: MangaChapter.Status) {
        chapter.status = status
        try? ctx.save()
    }
}
