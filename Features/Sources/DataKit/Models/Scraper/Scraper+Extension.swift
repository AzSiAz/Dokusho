import Foundation
import SerieScraper
import Common
import SwiftUI

public extension Scraper {
    enum Language: Int, Codable, CaseIterable, Labelized {
        case all = 0, english = 1, french = 2, japanese = 3, unknown = 4
        
        public init(from: SourceLanguage) {
            switch from {
            case .fr: self = .french
            case .en: self = .english
            case .jp: self = .japanese
            case .all: self = .all
            }
        }
        
        public func label() -> LocalizedStringKey {
            switch self {
            case .all: "All"
            case .english: "English"
            case .french: "French"
            case .japanese: "Japanese"
            case .unknown: "Unknown"
            }
        }
    }
    
    enum Auth: Codable { case key(apiKey: String), user(username: String, password: String) }
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, isActive, position, language
    }
}
