import Foundation
import GRDB
import SerieScraper

public struct Scraper: Identifiable, Equatable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var icon: URL
    public var isActive: Bool
    public var position: Int?
    public var language: Language
    
    public var archivedRecordData: Data?
    
    public init(id: UUID, name: String, icon: URL, isActive: Bool, language: Language, position: Int?) {
        self.id = id
        self.name = name
        self.icon = icon
        self.language = language
        self.isActive = isActive
        self.position = position
    }

    public init(source: Source, isActive: Bool = false, position: Int? = nil) {
        self.id = source.id
        self.name = source.name
        self.icon = source.icon
        self.language = Language(from: source.language)
        self.isActive = isActive
        self.position = position
    }

    public mutating func update(source: Source) {
        if (self.name != source.name) { self.name = source.name }
        if (self.icon != source.icon) { self.icon = source.icon }
        if (self.language != Language(from: source.language)) { self.language = Language(from: source.language) }
    }
    
    public mutating func toggleIsActive() {
        self.isActive.toggle()
    }
}
