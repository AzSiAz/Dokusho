import Foundation
import SwiftData

@Model
public class MangaCollection {
    @Attribute(.unique)
    public var id: UUID

    public var name: String
    public var position: Int
    public var useList: Bool?
    public var filter: Filter
    public var order: Order
    
    @Relationship(inverse: \Manga.collection)
    public var mangas: [Manga] = []
    
    public init(
        id: UUID,
        name: String,
        position: Int,
        useList: Bool? = false,
        filter: Filter = .all,
        order: Order = .init()
    ) {
        self.id = id
        self.name = name
        self.position = position
        self.useList = useList
        self.filter = filter
        self.order = order
    }
}
