//
//  model.swift
//  DokushoWidgetExtension
//
//  Created by Stef on 05/10/2021.
//

import WidgetKit

struct SmallMangaEntry {
    let cover: Data
    let title: String
    
    init(title: String, cover: String) {
        if let url = URL(string: cover), let cover = try? Data(contentsOf: url) {
            self.cover = cover
        } else {
            self.cover = Data()
        }
        
        self.title = title
    }
    
    static func fromMangaEntity(for mangas: [MangaEntity]) -> [SmallMangaEntry] {
        return mangas.map { (manga: MangaEntity) -> SmallMangaEntry in
            return SmallMangaEntry(title: manga.title ?? "", cover: manga.cover?.absoluteString ?? "")
            
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ChooseCollectionIntent
    let mangas: [SmallMangaEntry]
}
