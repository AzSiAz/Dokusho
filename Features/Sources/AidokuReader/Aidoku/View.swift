//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI
import DataKit

public struct AidokuReaderViewController: UIViewControllerRepresentable {    
    let manga: Manga
    let scraper: Scraper
    let chapter: MangaChapter
    let chapterList: [MangaChapter]
    let closeReader: () -> Void
    
    public init(manga: Manga, scraper: Scraper, chapter: MangaChapter, chapterList: [MangaChapter], closeReader: @escaping () -> Void) {
        self.manga = manga
        self.scraper = scraper
        self.chapterList = chapterList
        self.chapter = chapter
        self.closeReader = closeReader
    }
    
    public func makeUIViewController(context: Context) -> ReaderNavigationController {
        let viewController = ReaderViewController(manga: manga, scraper: scraper, chapter: chapter, chapterList: chapterList, closeReader: closeReader)
        let nv = ReaderNavigationController(rootViewController: viewController)
        nv.modalPresentationStyle = .fullScreen

        return nv
    }
    
    public func updateUIViewController(_ uiViewController: ReaderNavigationController, context: Self.Context) {}
    
    public func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
    public class Coordinator {
       var parentObserver: NSKeyValueObservation?
   }
}
