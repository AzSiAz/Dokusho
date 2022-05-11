//
//  File.swift
//
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI
import DataKit

public struct CustomReaderView: UIViewControllerRepresentable {
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
    
    public func makeUIViewController(context: Context) -> CustomReaderVC {
        let viewController = CustomReaderVC(manga: manga, scraper: scraper, chapter: chapter, chapterList: chapterList, closeReader: closeReader)
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: CustomReaderVC, context: Self.Context) {}
    
    public func makeCoordinator() -> Self.Coordinator { Coordinator() }
    
    public class Coordinator {
       var parentObserver: NSKeyValueObservation?
   }
}
