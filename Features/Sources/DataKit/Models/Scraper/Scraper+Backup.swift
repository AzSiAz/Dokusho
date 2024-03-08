//
//  File.swift
//  
//
//  Created by Stephan Deumier on 23/12/2023.
//

import Foundation

public extension Scraper {
    init(backup: Backup.V2) {
        self.id = backup.id
        self.name = backup.name
        self.icon = backup.icon
        self.language = backup.language
        self.isActive = backup.isActive
        self.position = backup.position
    }

    init(backup: Backup.V1, icon: URL, language: Language = .unknown) {
        self.id = backup.id
        self.name = backup.name
        self.isActive = backup.isActive
        self.position = backup.position
        self.icon = icon
        self.language = language
    }
    
    struct Backup {
        public struct V1: Codable {
            public var id: UUID
            public var name: String
            public var position: Int?
            public var isFavorite: Bool
            public var isActive: Bool
        }
        
        public struct V2: Codable {
            public var id: UUID
            public var name: String
            public var icon: URL
            public var isActive: Bool
            public var position: Int?
            public var language: Language
            
            public init(id: UUID, name: String, icon: URL, isActive: Bool, position: Int? = nil, language: Language) {
                self.id = id
                self.name = name
                self.icon = icon
                self.isActive = isActive
                self.position = position
                self.language = language
            }
        }
    }
}
