import Foundation
import SerieScraper

public extension Serie {
    enum Status: String, Codable {
        case complete = "Complete", ongoing = "Ongoing", unknown = "Unknown"
        
        public init(rawValue: SourceSerieCompletion) {
            switch(rawValue) {
            case .complete: self = .complete
            case .ongoing: self = .ongoing
            case .unknown: self = .unknown
            }
        }
    }
    
    enum Kind: String, Codable {
        case manga = "Manga", manhua = "Manhua", manhwa = "Manhwa", doujinshi = "Doujinshi", unknown = "Unknown"
        
        public init(rawValue: SourceSerieType) {
            switch(rawValue) {
            case .doujinshi: self = .doujinshi
            case .manga: self = .manga
            case .manhua: self = .manhua
            case .manhwa: self = .manhwa
            case .unknown: self = .unknown
            }
        }
    }
    
    
    enum ReaderDirection: String, Codable, CaseIterable {
        case rightToLeft = "Right to Left (Manga)"
        case leftToRight = "Left to Right (Manhua)"
        case vertical = "Vertical (Webtoon, no gaps)"
        
        public init(from: SourceSerieType) {
            switch from {
                case .manga: self = .rightToLeft
                case .manhua: self = .leftToRight
                case .manhwa: self = .vertical
                case .doujinshi: self = .rightToLeft
                default: self = .rightToLeft
            }
        }
    }
}
