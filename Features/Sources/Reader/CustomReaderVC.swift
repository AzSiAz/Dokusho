//
//  File.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import UIKit
import DataKit


public class CustomReaderVC: UIViewController {
    let manga: Manga
    let scraper: Scraper
    let closeReader: () -> Void
    var chapter: MangaChapter
    var chapterList: [MangaChapter]
    
    public init(manga: Manga, scraper: Scraper, chapter: MangaChapter, chapterList: [MangaChapter], closeReader: @escaping () -> Void) {
        self.manga = manga
        self.scraper = scraper
        self.chapter = chapter
        self.chapterList = chapterList
        self.closeReader = closeReader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
