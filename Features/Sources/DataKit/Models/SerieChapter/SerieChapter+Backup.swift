//
//  File.swift
//  
//
//  Created by Stephan Deumier on 22/03/2024.
//

import Foundation

public extension SerieChapter {
    init(backup: Backup.V1, serieID: Serie.ID, subTitle: String = "", chapter: Float, volume: Float) {
        self.id = UUID()
        self.internalID = backup.chapterId
        self.title = backup.title
        self.subTitle = subTitle
        self.uploadedAt = backup.dateSourceUpload
        self.chapter = chapter
        self.volume = volume
        if let url = backup.externalUrl { self.externalUrl = URL(string: url) }
        self.progress = nil
        self.readAt = backup.readAt
        self.serieID = serieID
    }
    
    struct Backup {
        public struct V1: Codable {
            public enum Status: String, CaseIterable, Codable, DatabaseValueConvertible {
                case unread, read
                
                func inverse() -> Status {
                    switch self {
                    case .unread:
                        return .read
                    case .read:
                        return .unread
                    }
                }
            }
            
            public var id: String
            public var chapterId: String
            public var title: String
            public var dateSourceUpload: Date
            public var position: Int
            public var readAt: Date?
            public var status: Status
            public var mangaId: UUID
            public var externalUrl: String?
        }
        
        public typealias V2 = SerieChapter
    }
}
