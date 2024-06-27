import Foundation
import SwiftData
import SerieScraper

@Model
public class Scraper: Identifiable, Equatable, Hashable {
    public var scraperId: UUID = UUID()
    public var name: String
    public var icon: URL
    public var isActive: Bool = false
    public var position: Int = 9999
    public var language: Language = Language.unknown
    
    public init(scraperId: UUID, name: String, icon: URL, isActive: Bool, language: Language, position: Int?) {
        self.scraperId = scraperId
        self.name = name
        self.icon = icon
        self.language = language
        self.isActive = isActive
        if let position { self.position = position }
    }

    public init(source: Source, isActive: Bool = false, position: Int? = nil) {
        self.scraperId = source.id
        self.name = source.name
        self.icon = source.icon
        self.language = Language(from: source.language)
        self.isActive = isActive
        if let position { self.position = position }
    }

    public func update(source: Source) {
        if (self.name != source.name) { self.name = source.name }
        if (self.icon != source.icon) { self.icon = source.icon }
        if (self.language != Language(from: source.language)) { self.language = Language(from: source.language) }
    }
    
    public func toggleIsActive() {
        self.isActive.toggle()
    }
}
