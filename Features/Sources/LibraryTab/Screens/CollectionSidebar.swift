//
//  CollectionSidebar.swift
//  Dokusho
//
//  Sidebar column of the Library on iPhone (the collapsed split): selectable
//  user collections (drives the detail column) plus dynamic collections pushed
//  into the stack. Collection creation is an explicit "+" + alert.
//

import SwiftUI
import GRDBQuery
import DataKit

struct CollectionSidebar: View {
    @Environment(\.appDatabase) var appDB
    @Binding var selectedCollectionId: MangaCollection.ID?

    @Query(DetailedMangaCollectionRequest()) var collections

    @State private var newCollectionName = ""
    @State private var showNewCollection = false
    @State private var showMassMigration = false

    var body: some View {
        List(selection: $selectedCollectionId) {
            Section("User Collection") {
                ForEach(collections) { info in
                    Label(info.mangaCollection.name, systemImage: "square.grid.2x2")
                        .badge("\(info.mangaCount)")
                        .tag(info.mangaCollection.id)
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)

                if collections.isEmpty {
                    Text("No collections yet")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Dynamic Collection") {
                NavigationLink {
                    ByGenreListPage()
                } label: {
                    Label("By Genres", systemImage: "tag")
                }

                NavigationLink {
                    BySourceListPage()
                } label: {
                    Label("By Source List", systemImage: "server.rack")
                }
            }
        }
        .navigationTitle("Collections")
        .queryObservation(.always)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    newCollectionName = ""
                    showNewCollection = true
                } label: {
                    Label("New Collection", systemImage: "plus")
                }

                Menu {
                    Button { showMassMigration = true } label: {
                        Label("Mass Migration", systemImage: "arrow.triangle.2.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

                EditButton()
            }
        }
        .alert("New Collection", isPresented: $showNewCollection) {
            TextField("Name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { newCollectionName = "" }
            Button("Create") { saveNewCollection() }
        } message: {
            Text("Enter a name for the collection")
        }
        .sheet(isPresented: $showMassMigration) { NavigationStack { MassMigrationView() } }
    }

    func saveNewCollection() {
        let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let lastPosition = (collections.last?.mangaCollection.position ?? 0) + 1

        do {
            try appDB.database.write { db in
                let collection = MangaCollection(id: UUID(), name: name, position: lastPosition)
                try collection.save(db)
            }
        } catch(let err) {
            print(err)
        }

        newCollectionName = ""
    }

    func onDelete(_ offsets: IndexSet) {
        offsets
            .map { collections[$0] }
            .forEach { collection in
                do {
                    let _ = try appDB.database.write { db in
                        try collection.mangaCollection.delete(db)
                    }
                } catch(let err) {
                    print(err)
                }
            }
    }

    func onMove(_ offsets: IndexSet, _ position: Int) {
        try? appDB.database.write { db in
            var revisedItems: [MangaCollection] = collections.map { $0.mangaCollection }
            revisedItems.move(fromOffsets: offsets, toOffset: position)

            for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
                revisedItems[reverseIndex].position = reverseIndex
                try revisedItems[reverseIndex].save(db)
            }
        }
    }
}
