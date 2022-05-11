//
//  ReaderPageManager.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 3/15/22.
//
import UIKit
import DataKit

protocol ReaderPageManager {
    var delegate: ReaderPageManagerDelegate? { get set }
    var chapter: MangaChapter? { get set }
    var pages: [Page] { get set }
    var readingMode: MangaViewer? { get set }

    func attach(toParent parent: UIViewController)
    func remove()

    func setChapter(chapter: MangaChapter, startPage: Int, scraper: Scraper)
    func move(toPage: Int)

    func willTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

extension ReaderPageManager {
    func setChapter(chapter: MangaChapter, startPage: Int = 0, scraper: Scraper) {
        setChapter(chapter: chapter, startPage: startPage, scraper: scraper)
    }
}

protocol ReaderPageManagerDelegate: AnyObject {
    var chapter: MangaChapter { get set }
    var chapterList: [MangaChapter] { get set }

    func didMove(toPage page: Int)
    func pagesLoaded()
    func move(toChapter chapter: MangaChapter)
}
