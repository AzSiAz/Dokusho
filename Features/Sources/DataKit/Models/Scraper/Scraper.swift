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
