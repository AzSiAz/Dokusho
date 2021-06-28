//
//  ManageCollectionsModal.swift
//  Dokusho (iOS)
//
//  Created by Stephan Deumier on 26/06/2021.
//

import SwiftUI

struct ManageCollectionsModal: View {
    @EnvironmentObject var lib: LibraryState
    
    @State var add = false
    @State var newCollectionName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if add {
                    VStack {
                        TextField("New collection name", text: $newCollectionName)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .onSubmit {
                                lib.addCollection(name: newCollectionName)
                                add.toggle()
                                newCollectionName = ""
                            }
                    }
                    .frame(alignment: .top)
                }
                
                List {
                    ForEach(lib.collections, id: \.id) { col in
                        if (col.name != nil) {
                            HStack {
                                Text(col.name!)
                                Spacer()
                                Button(action: { lib.deleteCollection(collection: col) }) {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Manage Collections", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { add.toggle() }) {
                        Text(add ? "Done" : "Add")
                    }
                }
            }
        }
    }
}


struct ManageCollectionsModal_Previews: PreviewProvider {
    static var previews: some View {
        ManageCollectionsModal()
            .environmentObject(LibraryState.init(context: PersistenceController(inMemory: true).container.viewContext))
    }
}
