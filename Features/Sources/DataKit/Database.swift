import Foundation
import Harmony
import SwiftUI

public extension DatabaseMigrator {
    static var dokushoMigration: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
//        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("00000001_scraper_table") { db in
            try db.create(table: "scraper") { t in
                t.column("id", .text).notNull().primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("name", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("isActive", .boolean).notNull()
                t.column("position", .integer)
                t.column("language", .text).notNull()
            }
        }
        
        migrator.registerMigration("00000002_serie_collection_table") { db in
            try db.create(table: "serieCollection") { t in
                t.column("id", .text).notNull().primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("name", .text).notNull()
                t.column("position", .integer).notNull()
                t.column("useList", .boolean).notNull()
                t.column("filter", .text).notNull()
                t.column("order", .jsonText).notNull()
            }
        }

        migrator.registerMigration("00000003_serie_table") { db in
            try db.create(table: "serie") { t in
                t.column("id", .text).notNull().primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("internalID", .text).notNull()
                t.column("title", .text).notNull().indexed()
                t.column("cover", .text).notNull()
                t.column("synopsis", .text).notNull()
                t.column("alternateTitles", .jsonText).notNull()
                t.column("genres", .jsonText).notNull()
                t.column("authors", .jsonText).notNull()
                t.column("status", .text).notNull().indexed()
                t.column("kind", .text).notNull().indexed()
                t.column("readerDirection", .text).notNull()

                t.column("scraperID", .text).references("scraper", onDelete: .setNull, onUpdate: .cascade).indexed()
                t.column("collectionID", .text).references("serieCollection", onDelete: .setNull, onUpdate: .cascade).indexed()

                t.uniqueKey(["internalID", "scraperID"], onConflict: .ignore)
            }
        }

        migrator.registerMigration("00000004_serie_chapter_table") { db in
            try db.create(table: "serieChapter") { t in
                t.column("id", .text).notNull().primaryKey(onConflict: .ignore, autoincrement: false)
                t.column("internalID", .text).notNull()
                t.column("title", .text).notNull()
                t.column("subTitle", .text)
                t.column("uploadedAt", .date).notNull()
                t.column("volume", .double)
                t.column("chapter", .double).notNull()
                t.column("readAt", .date)
                t.column("progress", .integer)
                t.column("externalUrl", .text)

                t.column("serieID", .text).references("serie", onDelete: .cascade, onUpdate: .cascade).indexed()

                t.uniqueKey(["internalID", "serieID"], onConflict: .ignore)
            }
        }
        
        return migrator
    }
}

private struct DatabaseReaderKey: EnvironmentKey {
    /// The default dbQueue is an empty in-memory database
    static var defaultValue: DatabaseReader { try! DatabaseQueue() }
}

extension EnvironmentValues {
    public var dbQueue: DatabaseReader {
        get { self[DatabaseReaderKey.self] }
        set { self[DatabaseReaderKey.self] = newValue }
    }
}

public extension Query where Request.DatabaseContext == DatabaseReader {
    /// Creates a `Query`, given an initial `Queryable` request that
    /// uses `DatabaseQueue` as a `DatabaseContext`.
    init(_ request: Request) {
        self.init(request, in: \.dbQueue)
    }

    /// Creates a `Query`, given a SwiftUI binding to a `Queryable`
    /// request that uses `DatabaseQueue` as a `DatabaseContext`.
    init(_ request: Binding<Request>) {
        self.init(request, in: \.dbQueue)
    }

    /// Creates a `Query`, given a ``Queryable`` request that uses
    /// `DatabaseQueue` as a `DatabaseContext`.
    init(constant request: Request) {
        self.init(constant:request, in: \.dbQueue)
    }
}
