//
//  LibraryView.swift
//  Dokusho
//
//  Created by Stephan Deumier on 31/05/2021.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.managedObjectContext) var coreDataCtx
    @EnvironmentObject var sourcesSvc: MangaSourceService

    @StateObject var vm: LibraryVM

    @State var showSettings = false
    
    var columns: [GridItem] {
        var base = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            base = [GridItem(.adaptive(minimum: 180, maximum: 180))]
        }
        
        return base
    }
    
    var body: some View {
        NavigationView {
            TabView {
                ForEach(vm.libState.collections) { collection in
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(vm.getMangas(collection: collection)) { manga in
                                NavigationLink(destination: MangaDetailView(vm: MangaDetailVM(for: sourcesSvc.getSource(sourceId: manga.source)!, mangaId: manga.id!, context: coreDataCtx, libState: vm.libState))) {
                                    ImageWithTextOver(title: manga.title!, imageUrl: manga.cover!)
                                        .frame(height: 180)
                                }
                            }
                        }
                    }
                    .tabItem {
                        Text(collection.name ?? "Default")
                    }
                    .navigationBarTitle(collection.name!)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toolbar {
                ToolbarItem {
                    Image(systemName: "gear")
                        .onTapGesture {
                            showSettings.toggle()
                        }
                }
            }
            .sheet(isPresented: $showSettings) {
                ManageCollectionsModal()
                    .environmentObject(vm.libState)
            }
        }
        .navigationTitle("Library")
    }
}

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
                    ForEach(lib.collections) { col in
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

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(vm: .init(libState: LibraryState(context: PersistenceController.init(inMemory: true).container.viewContext)))
    }
}
