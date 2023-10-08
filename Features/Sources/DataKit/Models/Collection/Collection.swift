import Foundation
import SwiftData

@Model
public class Collection {
    public var name: String
    public var position: Int
    public var useList: Bool?
    public var filter: Filter
    public var order: Order

    @Relationship(deleteRule: .nullify, inverse: \Manga.collection)
    public var mangas: [Manga] = []

    public init(
        name: String,
        position: Int,
        useList: Bool? = false,
        filter: Filter = .all,
        order: Order = .init()
    ) {
        self.name = name
        self.position = position
        self.useList = useList
        self.filter = filter
        self.order = order
    }
}
