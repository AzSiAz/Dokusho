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

/// AppDatabase lets the application access the database.
///
/// It applies the pratices recommended at
/// <https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md>
struct AppDatabase {
    /// Creates an `AppDatabase`, and make sure the database schema is ready.
    init(_ dbWriter: DatabaseWriter) throws {
        self.database = dbWriter
        try migrator.migrate(dbWriter)
    }

    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections>
    let database: DatabaseWriter

    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("init_state") { db in
            Logger.migration.info("Using init_state migration")

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

        return migrator
    }
}

extension AppDatabase {
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

extension AppDatabase {
    /// The database for the application
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
            
            var config = Configuration()
            config.prepareDatabase { db in
                db.trace { print($0) }
            }

            let dbPool = try DatabasePool(path: dbURL.path, configuration: config)

            return try AppDatabase(dbPool)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
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

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .makeEmpty() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

extension Query where Request.DatabaseContext == AppDatabase {
    /// Convenience initializer for requests that feed from `AppDatabase`.
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
