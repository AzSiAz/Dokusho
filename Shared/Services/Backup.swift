//
//  Backup.swift
//  Dokusho
//
//  Created by Stef on 21/12/2021.
//

import Foundation

struct ChapterBackup: Codable {
    var id: String
    var readAt: Date
}

struct MangaBackup: Codable {
    var id: String
    var sourceId: UUID
    var readChapter: [ChapterBackup]
}

struct CollectionBackup: Codable {
    var id: UUID?
    var name: String
    var position: Int
    var mangas: [MangaBackup]
}


struct BackupTask {
    var mangaBackup: MangaBackup
    var collection: CollectionEntity
}

typealias BackupResult = Result<BackupTask, Error>
