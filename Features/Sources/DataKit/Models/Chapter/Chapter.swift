//
//  File.swift
//  
//
//  Created by Stephan Deumier on 08/10/2023.
//

import Foundation
import SwiftData

@Model
public class Chapter {
    public var chapterId: String?
    public var title: String?
    public var subTitle: String?
    public var uploadedAt: Date?
    public var volume: Float?
    public var chapter: Float?
    public var readAt: Date?
    public var status: Status?
    public var externalUrl: URL?
    
    @Relationship()
    public var manga: Manga?
    
    init(chapterId: String? = nil, title: String? = nil, subTitle: String? = nil, uploadedAt: Date? = nil, volume: Float? = nil, chapter: Float? = nil, readAt: Date? = nil, status: Status? = nil, externalUrl: URL? = nil, manga: Manga? = nil) {
        self.chapterId = chapterId
        self.title = title
        self.subTitle = subTitle
        self.uploadedAt = uploadedAt
        self.volume = volume
        self.chapter = chapter
        self.readAt = readAt
        self.status = status
        self.externalUrl = externalUrl
        self.manga = manga
    }
    
    public init(from data: SourceChapter) {
        self.chapterId = data.id
        self.title = data.name
        self.subTitle = data.subTitle
        self.uploadedAt = data.dateUpload
        self.chapter = data.chapter
        self.volume = data.volume
        self.status = .unread
        self.externalUrl = data.externalUrl
    }
}

public extension Chapter {
    enum Status: String, Codable, CaseIterable {
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
}
