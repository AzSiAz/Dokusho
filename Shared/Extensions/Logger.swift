//
//  Logger.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 05/06/2021.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let reader = Logger(subsystem: subsystem, category: "reader")
    static let backup = Logger(subsystem: subsystem, category: "backup")
}
