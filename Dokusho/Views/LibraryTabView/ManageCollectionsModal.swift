//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ManageCollectionsModal: View {
    @State var editMode: EditMode = .inactive
    
    @State var add = false
    @State var newCollectionName = ""
    
    @FetchRequest(
        entity: CollectionEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CollectionEntity.position, ascending: true),
            NSSortDescriptor(keyPath: \CollectionEntity.name, ascending: true)
        ]
    ) var collections: FetchedResults<CollectionEntity>
    
    var body: some View {
        NavigationView {
            VStack {
                if editMode.isEditing {
                    TextField("New collection name", text: $newCollectionName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .submitLabel(.done)
                        .onSubmit(of: .text) {
//                            let position = (collections.last?.position ?? 0) + 1
//                            DataManager.shared.addCollection(name: newCollectionName, position: position)

                            add.toggle()
                            newCollectionName = ""
                        }
                        .frame(alignment: .top)
                        .padding(.bottom, 0)
                }
                List {
                    ForEach(collections) { collection in
                        HStack {
                            Text("\(collection.position) - \(collection.name ?? "No Name")")
                        }
                    }
                    .onMove { (base, new) in
//                        DataManager.shared.reorderCollection(from: base, to: new, within: collections)
                    }
                    .onDelete { index in
//                        DataManager.shared.deleteCollection(collection: collections[index.first!])
                    }
                }
            }
            .navigationBarTitle("Manage Collections", displayMode: .inline)
            .toolbar { EditButton() }
            .environment(\.editMode, $editMode)
        }
    }
}


struct ManageCollectionsModal_Previews: PreviewProvider {
    static var previews: some View {
        ManageCollectionsModal()
    }
}
