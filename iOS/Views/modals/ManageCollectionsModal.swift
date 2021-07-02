//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ManageCollectionsModal: View {
    var dataManager = DataManager.shared
    @State var editMode: EditMode = .inactive
    
    @State var add = false
    @State var newCollectionName = ""
    
    @FetchRequest(
        entity: MangaCollection.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MangaCollection.position, ascending: true),
            NSSortDescriptor(keyPath: \MangaCollection.name, ascending: true)
        ]
    ) var collections: FetchedResults<MangaCollection>
    
    var body: some View {
        NavigationView {
            VStack {
                if editMode.isEditing {
                    TextField("New collection name", text: $newCollectionName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .keyboardShortcut(.end, modifiers: .all)
                        .onSubmit {
                            var position: Int16
                            if let p = collections.last?.position { position = p+1 } else { position = 0 }

                            dataManager.addCollection(name: newCollectionName, position: position)
                            add.toggle()
                            newCollectionName = ""
                        }
                        .frame(alignment: .top)
                        .padding(.bottom, 0)
                }
                
                List {
                    ForEach(collections, id: \.id) { collection in
                        HStack {
                            Text("\(collection.position)")
                            Text("-")
                            Text(collection.name ?? "No Name")
                        }
                    }
                    .onMove { (base, new) in
                        dataManager.reorderCollection(from: base, to: new, within: collections)
                    }
                    .onDelete { index in
                        dataManager.deleteCollection(collection: collections[index.first!])
                    }
                }
            }
            .navigationBarTitle("Manage Collections", displayMode: .inline)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
        }
    }
}


struct ManageCollectionsModal_Previews: PreviewProvider {
    static var previews: some View {
        ManageCollectionsModal()
    }
}
