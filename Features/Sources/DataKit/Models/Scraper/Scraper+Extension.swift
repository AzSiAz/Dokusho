import Foundation
import SerieScraper
import GRDB
import Common
import SwiftUI

public extension Scraper {
    enum Language: Int, Codable, CaseIterable, DatabaseValueConvertible, Labelized {
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


/// GRDB extension
extension Scraper: FetchableRecord, PersistableRecord {}

extension Scraper: TableRecord {
    public static var databaseTableName: String = "scraper"

    public static let series = hasMany(Serie.self)

    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let name = Column(CodingKeys.name)
        public static let icon = Column(CodingKeys.icon)
        public static let isActive = Column(CodingKeys.isActive)
        public static let position = Column(CodingKeys.position)
        public static let language = Column(CodingKeys.language)
    }

    public static let databaseSelection: [SQLSelectable] = [
        Columns.id,
        Columns.name,
        Columns.icon,
        Columns.isActive,
        Columns.position,
        Columns.language
    ]
}

public extension DerivableRequest<Scraper> {
    func onlyActive(_ bool: Bool = true) -> Self {
        filter(RowDecoder.Columns.isActive == bool)
    }

    func orderByPosition() -> Self {
        order(
            RowDecoder.Columns.position.ascNullsLast,
            RowDecoder.Columns.name.collating(.localizedCaseInsensitiveCompare).asc
        )
    }
}
