//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI
import SwiftUIX

struct LibraryTabView: View {
    @Environment(\.managedObjectContext) var ctx
    
    @FetchRequest(sortDescriptors: [CollectionEntity.positionOrder], predicate: nil, animation: .default)
    var collections: FetchedResults<CollectionEntity>

    @StateObject var vm: LibraryVM = .init()

    @State var editMode: EditMode = .inactive
    @State var newCollectionName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(collections) { collection in
                    NavigationLink(destination: CollectionPage(collection: collection)) {
                        Label("\(collection.getName()) (\(collection.mangas?.count ?? 0))", systemImage: "square.grid.2x2")
                            .padding(.vertical)
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
                
                if editMode.isEditing {
                    TextField(text: $newCollectionName)
                        .submitLabel(.done)
                        .onSubmit(saveNewCollection)
                        .padding(.vertical)
                }
            }
            .id(editMode)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Collections")
            .environment(\.editMode, $editMode)
        }
    }
    
    func saveNewCollection() {
        let lastPosition = (collections.last?.position ?? 0) + 1
        
        try? ctx.performAndWait {
            let _ = CollectionEntity(ctx: ctx, name: newCollectionName, position: Int(lastPosition))
            try ctx.save()
        }
        
        newCollectionName = ""
    }
    
    func onDelete(_ offsets: IndexSet) {
        offsets
            .map { collections[$0] }
            .forEach { collection in
                ctx.perform {
                    ctx.delete(collection)
                }
            }
    }
    
    func onMove(_ offsets: IndexSet, _ position: Int) {
        try? ctx.performAndWait {
            var revisedItems: [CollectionEntity] = collections.map{ $0 }

            // change the order of the items in the array
            revisedItems.move(fromOffsets: offsets, toOffset: position)

            // update the userOrder attribute in revisedItems to
            // persist the new order. This is done in reverse order
            // to minimize changes to the indices.
            for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                revisedItems[reverseIndex].position = Int16(reverseIndex)
            }
            
            try ctx.save()
        }
    }
}
