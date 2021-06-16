//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation

class ReaderVM: ObservableObject {
    var src: Source
    
    @Published var chapter: SourceChapter
    @Published var manga: SourceManga
    @Published var tabIndex = 0
    @Published var showToolBar = true
    @Published var chapterImages: [SourceChapterImage]?
    @Published var error = false

    init(for chapter: SourceChapter, in manga: SourceManga, with source: Source) {
        self.src = source
        self.chapter = chapter
        self.manga = manga
    }
    
    func fetchChapter() async {
        do {
            chapterImages = try await src.fetchChapterImages(mangaId: manga.id, chapterId: chapter.id)
            tabIndex = 0
        } catch {
            self.error = true
        }
    }
}
