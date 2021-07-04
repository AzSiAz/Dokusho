//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation
import CoreData

class ReaderVM: ObservableObject {
    private var srcSvc = MangaSourceService.shared
    private var src: Source
    
    @Published var chapter: MangaChapter
    @Published var tabIndex = 0
    @Published var showToolBar = false
    @Published var chapterImages: [SourceChapterImage]?
    @Published var error = false

    init(for chapter: MangaChapter) {
        self.src = srcSvc.getSource(sourceId: chapter.manga!.source)!
        self.chapter = chapter
    }
    
    func fetchChapter() async {
        do {
            chapterImages = try await src.fetchChapterImages(mangaId: chapter.manga!.id!, chapterId: chapter.id!)
            tabIndex = 0
        } catch {
            self.error = true
        }
    }
    
    func saveProgress(_ status: MangaChapter.Status) {
        chapter.status = status
        // TODO: Fix
//        try? ctx.save()
    }
}
