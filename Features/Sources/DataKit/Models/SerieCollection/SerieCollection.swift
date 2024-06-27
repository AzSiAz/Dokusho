import Foundation
import SwiftData

@Model
public class SerieCollection: Identifiable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var position: Int
    public var useList: Bool
    public var filter: Filter
    public var order: Order

    public init(name: String, position: Int, useList: Bool = false, filter: Filter = .all, order: Order = .init()) {
        self.id = UUID()
        self.name = name
        self.position = position
        self.useList = useList
        self.filter = filter
        self.order = order
    }
}
