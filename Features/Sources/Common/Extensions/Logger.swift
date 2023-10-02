//
//  Logger.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import Foundation
import OSLog

public extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let persistence = Logger(subsystem: subsystem, category: "db")
    static let migration = Logger(subsystem: subsystem, category: "db.migration")
    static let reader = Logger(subsystem: subsystem, category: "reader")
    static let backup = Logger(subsystem: subsystem, category: "backup")
    static let libraryUpdater = Logger(subsystem: subsystem, category: "library.updater")
}
