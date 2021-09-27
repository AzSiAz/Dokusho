//
//  ReaderVM.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 15/06/2021.
//

import Foundation
import CoreData
import SwiftUI
import OSLog
import MangaScraper

class ReaderVM: ObservableObject {
    private var src: Source
    private var ctx = PersistenceController.shared.backgroundCtx()
    
    @Published var chapter: ChapterEntity
    @Published var images = [SourceChapterImage]()
    
    @Published var showToolBar = false
    @Published var tabIndex: SourceChapterImage = .init(index: 0, imageUrl: "")
    @Published var direction: ReadingDirection = .vertical
    @Published var showReaderDirectionChoice = false

    init(for chapter: ChapterEntity) {
        self.src = chapter.manga!.getSource()
        self.chapter = chapter
        self.direction = chapter.manga!.getDefaultReadingDirection()
    }
    
    @MainActor
    func fetchChapter() async {
        do {
            images = try await src.fetchChapterImages(mangaId: chapter.manga!.mangaId!, chapterId: chapter.chapterId!)
            tabIndex = images.first!
        } catch {
            Logger.reader.info("Error loading chapter \(self.chapter): \(error.localizedDescription)")
        }
    }
    
    func progressBarCurrent() -> Double {
        return Double(images.firstIndex { $0 == tabIndex } ?? 0) + 1
    }

    func updateChapterStatus(image: SourceChapterImage) {
        if images.last == image {
            try? ctx.performAndWait {
                guard let chapter = self.ctx.object(with: self.chapter.objectID) as? ChapterEntity else { return }
                chapter.markAs(newStatus: .read)
                chapter.manga?.lastUserAction = .now

                try self.ctx.save()
            }
        }
    }
    
    func getImagesOrderForDirection() -> [SourceChapterImage] {
        return direction == .rightToLeft ? images.reversed() : images
    }
}
