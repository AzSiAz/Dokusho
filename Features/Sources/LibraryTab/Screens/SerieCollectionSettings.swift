import Foundation
import SwiftUI
import DataKit
import Common
import SharedUI

public struct SerieCollectionSettings: View {
    @Query<OneSerieCollectionRequest> var collection: SerieCollection?
    
    @Harmony var harmony
    
    @State var collectionOrder: SerieCollection.Order
    @State var collectionFilter: SerieCollection.Filter
    @State var useList: Bool
    
    public init(collection : SerieCollection) {
        _collection = Query(OneSerieCollectionRequest(serieCollectionID: collection.id))
        _collectionOrder = .init(initialValue: collection.order)
        _collectionFilter = .init(initialValue: collection.filter)
        _useList = .init(initialValue: collection.useList)
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section("Filter") {
                    Picker("Change collection filter", selection: $collectionFilter) {
                        ForEach(SerieCollection.Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }

                Section("Order") {
                    Picker("Change collection order field", selection: $collectionOrder.field) {
                        ForEach(SerieCollection.Order.Field.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    Picker("Change collection order direction", selection: $collectionOrder.direction) {
                        ForEach(SerieCollection.Order.Direction.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                }
                
                Section("Presentation") {
                    Toggle("Show as list", isOn: $useList)
                }
            }
            .navigationTitle(Text("Modify Filter"))
            .onChange(of: $collectionFilter.wrappedValue){ updateCollectionFilter(newFilter: $1) }
            .onChange(of: $collectionOrder.field.wrappedValue) { updateCollectionOrder(direction: nil, field: $1) }
            .onChange(of: $collectionOrder.direction.wrappedValue) { updateCollectionOrder(direction: $1, field: nil) }
            .onChange(of: $useList.wrappedValue) { updateCollectionUseList(d: $1) }
        }
    }
}

extension SerieCollectionSettings {
    func updateCollectionUseList(d: Bool) {
        Task {
            guard var collection = collection else { return }

            do {
                collection.useList = d
                try await harmony.save(record: collection)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateCollectionFilter(newFilter: SerieCollection.Filter) {
        Task {
            guard var collection = collection else { return }

            do {
                collection.filter = newFilter
                try await harmony.save(record: collection)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateCollectionOrder(direction: SerieCollection.Order.Direction? = nil, field: SerieCollection.Order.Field? = nil) {
        Task {
            guard var collection = collection else { return }
            
            do {
                if let direction { collection.order.direction = direction }
                if let field { collection.order.field = field }
                try await harmony.save(record: collection)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
