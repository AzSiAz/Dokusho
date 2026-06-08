//
//  IPadRootView.swift
//  Dokusho
//
//  Unified iPad root: a single NavigationSplitView whose sidebar lists the
//  library collections (+ dynamic collections) and the app's other sections
//  (History / Explore / Settings). The detail column shows the selected item.
//  iPhone keeps the tab bar (see RootView).
//

import SwiftUI
import GRDBQuery
import DataKit
import MangaDetail
import HistoryTab
import ExploreTab
import SettingsTab

public struct IPadRootView: View {
    enum Selection: Hashable {
        case collection(MangaCollection.ID)
        case genres
        case sources
        case history
        case explore
        case settings
    }

    @Environment(\.appDatabase) var appDB
    @Query(DetailedMangaCollectionRequest()) var collections

    @State private var selection: Selection?
    @State private var newCollectionName = ""
    @State private var showNewCollection = false
    @State private var showMassMigration = false
    @State private var editMode: EditMode = .inactive

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        List(selection: $selection) {
            Section("Library") {
                ForEach(collections) { info in
                    Label(info.mangaCollection.name, systemImage: "square.grid.2x2")
                        .badge("\(info.mangaCount)")
                        .tag(Selection.collection(info.mangaCollection.id))
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)

                Label("By Genres", systemImage: "tag")
                    .tag(Selection.genres)
                Label("By Source List", systemImage: "server.rack")
                    .tag(Selection.sources)
            }

            Section {
                Label("History", systemImage: "clock")
                    .tag(Selection.history)
                Label("Explore", systemImage: "safari")
                    .tag(Selection.explore)
                Label("Settings", systemImage: "gear")
                    .tag(Selection.settings)
            }
        }
        .navigationTitle("Dokusho")
        .queryObservation(.always)
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    newCollectionName = ""
                    showNewCollection = true
                } label: {
                    Label("New Collection", systemImage: "plus")
                }

                Menu {
                    Button {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    } label: {
                        Label(editMode.isEditing ? "Done" : "Edit Collections",
                              systemImage: editMode.isEditing ? "checkmark" : "pencil")
                    }

                    Button { showMassMigration = true } label: {
                        Label("Mass Migration", systemImage: "arrow.triangle.2.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
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

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .collection(let id):
            NavigationStack {
                CollectionGridPane(collectionId: id)
                    .id(id)
                    .navigationDestination(for: DetailedMangaInList.self) { data in
                        MangaDetail(mangaId: data.manga.mangaId, scraper: data.scraper)
                    }
            }
        case .genres:
            NavigationStack { ByGenreListPage() }
        case .sources:
            NavigationStack { BySourceListPage() }
        case .history:
            HistoryTabView()
        case .explore:
            ExploreTabView()
        case .settings:
            SettingsTabView()
        case nil:
            ContentUnavailableView("Select an item", systemImage: "sidebar.left")
        }
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
