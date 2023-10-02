//
//  Persistence.swift
//  Dokusho
//
//  Created by Stephan Deumier on 17/08/2021.
//
import SwiftUI
import GRDB
import GRDBQuery
import OSLog
import MangaScraper
import Common

public struct AppDatabase {
    public init(_ dbWriter: DatabaseWriter) throws {
        self.database = dbWriter
        try migrator.migrate(dbWriter)
    }

    public let database: DatabaseWriter

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
//        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        Logger.migration.info("Registering init_state migration")
        migrator.registerMigration("init_state") { db in
            try db.create(table: "mangaCollection") { t in
                t.column("id", .text).primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("name", .text).notNull()
                t.column("position", .integer).notNull()
                t.column("filter", .text).notNull()
                t.column("order", .text).notNull()
            }

            try db.create(table: "scraper") { t in
                t.column("id", .text).primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("name", .text).notNull().indexed()
                t.column("position", .integer)
                t.column("isFavorite", .boolean).notNull().defaults(to: false).indexed()
                t.column("isActive", .boolean).notNull().defaults(to: false).indexed()
            }
            
            try db.create(table: "manga") { t in
                t.column("id", .text).notNull().primaryKey()
                t.column("title", .text).notNull().indexed()
                t.column("cover", .text).notNull().defaults(to: URL(string: "https://via.placeholder.com/240x300")!)
                t.column("synopsis", .text).notNull().defaults(to: "No Synopsis")
                t.column("mangaId", .text).notNull().indexed()
                t.column("status", .text).notNull().indexed()
                t.column("type", .text).notNull().indexed()
                t.column("alternateTitles", .text).indexed()
                t.column("genres", .text).indexed()
                t.column("authors", .text).indexed()
                t.column("artists", .text).indexed()
                t.column("mangaCollectionId", .text).indexed().references("mangaCollection", onDelete: .cascade, onUpdate: .cascade)
                t.column("scraperId", .text).indexed().references("scraper", onDelete: .setNull, onUpdate: .cascade)
                t.uniqueKey(["scraperId", "mangaId"], onConflict: .replace)
            }

            try db.create(table: "mangaChapter") { t in
                t.column("id", .text).notNull().primaryKey()
                t.column("chapterId", .text).notNull()
                t.column("title", .text).notNull().defaults(to: "No Title")
                t.column("dateSourceUpload", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("position", .integer).notNull()
                t.column("readAt", .datetime)
                t.column("status", .text).notNull()
                t.column("mangaId", .integer).notNull().indexed().references("manga", onDelete: .cascade, onUpdate: .cascade)
            }
        }
        
        Logger.migration.info("Registering update_index migration")
        migrator.registerMigration("update_index") { db in
            try db.create(index: "mangaChapter_status", on: "mangaChapter", columns: ["status"])
            try db.create(index: "mangaChapter_readAt", on: "mangaChapter", columns: ["readAt"])
            try db.create(index: "mangaChapter_position", on: "mangaChapter", columns: ["position"])
            try db.create(index: "mangaChapter_dateSourceUpload", on: "mangaChapter", columns: ["dateSourceUpload"])
        }
        
        Logger.migration.info("Registering update_mangaChapter_table migration")
        migrator.registerMigration("update_mangaChapter_table") { db in
            try db.alter(table: "mangaChapter") { t in
                t.add(column: "externalUrl", .text)
            }
        }
        
        Logger.migration.info("Registering  migration")
        migrator.registerMigration("add_useList_to_mangaCollection") { db in
            try db.alter(table: "mangaCollection") { t in
                t.add(column: "useList", .boolean).notNull().defaults(to: "false")
            }
        }

        return migrator
    }
}

public extension AppDatabase {
    func createUiDataIfEmpty() throws {
        try database.write { db in
            if try MangaCollection.all().isEmpty(db) {
                try createUITestMangaCollection(db)
            }
            
            if try Scraper.all().isEmpty(db) {
                try createUITestScraper(db)
            }
        }
    }

    static let uiTestMangaCollection = [
        MangaCollection(id: UUID(), name: "Reading", position: 1),
        MangaCollection(id: UUID(), name: "To Read", position: 2),
        MangaCollection(id: UUID(), name: "Special", position: 3),
        MangaCollection(id: UUID(), name: "Done", position: 4),
        MangaCollection(id: UUID(), name: "Paper", position: 5),
    ]
    
    static let uiTestScraper = [
        Scraper(id: UUID(), name: "Favorite", isFavorite: true, isActive: true),
        Scraper(id: UUID(), name: "Active", isFavorite: false, isActive: true),
    ]

    private func createUITestMangaCollection(_ db: Database) throws {
        try AppDatabase.uiTestMangaCollection.forEach { _ = try $0.inserted(db) }
    }
    
    private func createUITestScraper(_ db: Database) throws {
        try AppDatabase.uiTestMangaCollection.forEach { _ = try $0.inserted(db) }
    }
}

public extension AppDatabase {
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            let fileManager = FileManager()

            let folderURL = fileManager
                .containerURL(forSecurityApplicationGroupIdentifier: "group.tech.azsiaz.Dokusho")?
                .appendingPathComponent("database", isDirectory: true)

            guard let folderURL = folderURL else { throw "Folder not existing" }
            
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            Logger.persistence.info("Db is \(dbURL.path)")

            let dbPool = try DatabasePool(path: dbURL.path, configuration: .init())

            return try AppDatabase(dbPool)
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Creates an empty database for SwiftUI previews
    static func makeEmpty() -> AppDatabase {
        return try! AppDatabase(DatabaseQueue())
    }
    
    /// Creates a database full of data for SwiftUI previews
    static func uiTest() -> AppDatabase {
        let appDatabase = makeEmpty()
        try! appDatabase.createUiDataIfEmpty()

        return appDatabase
    }
}

public extension Query where Request.DatabaseContext == AppDatabase {
    /// Convenience initializer for requests that feed from `AppDatabase`.
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
