import Foundation
import SerieScraper
import GRDB
import SwiftUI
import Common

public extension Serie {
    typealias InternalID = String
    
    enum Status: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
        case complete = 0, ongoing = 1, unknown = 2
        
        public init(_ from: SourceSerieCompletion) {
            switch(from) {
            case .complete: self = .complete
            case .ongoing: self = .ongoing
            case .unknown: self = .unknown
            }
        }
        
        public func label() -> LocalizedStringKey {
            switch self {
            case .complete: "Complete"
            case .ongoing: "Ongoing"
            case .unknown: "Unknown"
            }
        }
    }
    
    enum Kind: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
        case manga = 0, manhua = 1, manhwa = 2, doujinshi = 3, unknown = 4, lightNovel = 5
        
        public init(_ from: SourceSerieType) {
            switch(from) {
            case .doujinshi: self = .doujinshi
            case .manga: self = .manga
            case .manhua: self = .manhua
            case .manhwa: self = .manhwa
            case .lightNovel: self = .lightNovel
            case .unknown: self = .unknown
            }
        }
        
        public func label() -> LocalizedStringKey {
            switch self {
            case .manga: "Manga"
            case .manhua: "Manhua"
            case .manhwa: "Manhwa"
            case .doujinshi: "Doujinshi"
            case .unknown: "Unknown"
            case .lightNovel: "Light Novel"
            }
        }
    }
    
    
    enum ReaderDirection: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
        case rightToLeft = 0, leftToRight = 1, vertical = 3
        
        public init(_ from: SourceSerieType) {
            switch from {
                case .manga: self = .rightToLeft
                case .manhua: self = .leftToRight
                case .manhwa: self = .vertical
                case .doujinshi: self = .rightToLeft
                default: self = .rightToLeft
            }
        }
        
        public init(from: Kind) {
            switch from {
            case .manga: self = .rightToLeft
            case .manhua: self = .leftToRight
            case .manhwa: self = .vertical
            case .doujinshi: self = .rightToLeft
            default: self = .rightToLeft
            }
        }
        
        public func label() -> LocalizedStringKey {
            switch self {
            case .rightToLeft: "Right to Left (Manga)"
            case .leftToRight: "Left to Right (Manhua)"
            case .vertical: "Vertical (Webtoon, no gaps)"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, internalID, title, cover, synopsis, alternateTitles, genres, authors, status, kind, readerDirection, scraperID, collectionID
    }
}
