import Foundation
import SwiftData
import SerieScraper

@Model
public class Scraper {
    @Attribute(.unique)
    public var id: UUID
    public var name: String
    public var icon: URL
    public var isActive: Bool
    public var position: Int
    public var language: Language

    @Attribute(.allowsCloudEncryption)
    var auth: Auth?

    public init(source: Source, isActive: Bool = false, position: Int = 9999) {
        self.id = source.id
        self.name = source.name
        self.icon = source.icon
        self.language = Language(from: source.language)
        self.isActive = isActive
        self.position = position
    }

    public func update(source: Source) {
        if (self.name != source.name) { self.name = source.name }
        if (self.icon != source.icon) { self.icon = source.icon }
        if (self.language != Language(from: source.language)) { self.language = Language(from: source.language) }
    }
}
