import Foundation
import MangaScraper

public extension Scraper {
    enum Language: String, Codable, CaseIterable {
        case all = "All", english = "English", french = "French", japanese = "Japanese", unknown = "Unknown"
        
        init(from: SourceLanguage) {
            switch from {
            case .fr: self = .french
            case .en: self = .english
            case .jp: self = .japanese
            case .all: self = .all
            }
        }
    }
    
    enum Auth: Codable { case key(apiKey: String), user(username: String, password: String) }
}
