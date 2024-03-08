import Foundation

public struct SerieCollection: Identifiable, Equatable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var position: Int
    public var useList: Bool
    public var filter: Filter
    public var order: Order
    
    public var archivedRecordData: Data?

    public init(name: String, position: Int, useList: Bool = false, filter: Filter = .all, order: Order = .init()) {
        self.id = UUID()
        self.name = name
        self.position = position
        self.useList = useList
        self.filter = filter
        self.order = order
    }
}
